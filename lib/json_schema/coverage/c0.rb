require "json_schema/coverage"

class JsonSchema::Coverage
  module C0
    def print_c0
      results = {}

      @store.each do |uri, schema|
        do_recurvively(collect_schema(from: schema, keywords: %i[ properties pattern_properties ])) do |*levels, value|
        #do_recurvively(collect_schema(from: schema, keywords: %i[ definitions properties pattern_properties ])) do |*levels, value|
          unless %i[ definitions properties pattern_properties ].include?(levels.last)
            if c0[uri]&.dig(*levels, :value)
              results["#{uri}#/#{levels.join("/")}"] = true
            else
              if c0[uri]&.dig(*levels[0..-3], :value)
                results["#{uri}#/#{levels[0..-3].join("/")}"] = true
                results["#{uri}#/#{levels.join("/")}"] = false
              else
                results["#{uri}#/#{levels.join("/")}"] = false
              end
            end
          end
        end
      end

      ok = results.select {|k, v| v }.size

      puts "C0 Coverage: #{ok}/#{results.size} -> #{ok*100.0/results.size} %"
      results.each do |key, result|
        puts "#{key}: #{result ? "OK" : "NG"}"
      end
    end

    protected
    def c0
      @c0 ||= {}
    end

    def check_c0(schema:, data:, levels: [])
      if data.is_a?(Hash)
        schema.properties.each do |name, sub_schema|
          if data.has_key?(name)
            if data[name].is_a?(Hash)
              check_c0(schema: sub_schema, data: data[name], levels: [*levels, :properties, name])
            else
              mark_c0(*levels, :properties, name)
            end
          end
        end
        schema.pattern_properties.each do |pattern, schema|
          mark_c0(*levels, :pattern_properties, pattern.source) unless data.keys.grep(pattern).empty?
        end
      else
        mark_c0(*levels)
      end
    end

    def mark_c0(*levels)
      parent, data = c0, c0

      levels.each do |key|
        data[key] ||= {}
        parent, data = data, data[key]
      end

      parent[levels.last] = { value: true }
    end
  end
end
