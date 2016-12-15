require "json_schema"
require "json_schema/coverage/c0"

module JsonSchema
  class Coverage
    include C0

    def initialize(store)
      @store  = store
    end

    def run(tests)
      tests.each do |test|
        schema = resolve_schema(test["schema"])

        levels = [ schema.uri, *schema.pointer.gsub(/^#/, "").split("/") ]

        test["tests"].each do |test|
          data = test["data"]

          check_c0(schema: schema, data: data, levels: levels)
        end
      end
    end

    protected
    def collect_schema(from:, keywords:, levels: [], &block)
      return nil unless from

      schema_map = {}

      # scehma map
      (%i[ definitions properties ] & keywords).each do |keyword|
        schema = from.__send__(keyword)
        unless schema.empty?
          schema_map[keyword] ||= schema.each.with_object({}) do |(key, sub_schema), hash|
            unless sub_schema.reference # skip
              hash[key] = collect_schema(from: sub_schema, keywords: keywords)
            end
          end
        end
      end
      (%i[ pattern_properties ] & keywords).each do |keyword|
        schema = from.__send__(keyword)
        unless schema.empty?
          schema_map[keyword] ||= schema.each.with_object({}) do |(key, sub_schema), hash|
            unless sub_schema.reference # skip
              hash[key.source] = collect_schema(from: sub_schema, keywords: keywords)
            end
          end
        end
      end

      # schema or schemaArray
      (%i[ items ] & keywords)

      # bool or schema
      (%i[ additional_properties additional_items ] & keywords)

      # schema or stringArray
      (%i[ dependenies ] & keywords)

      # schemaArray
      (%i[ oneOf allOf anyOf ] & keywords)

      schema_map
    end

    def do_recurvively(hash, levels: [], &block)
      if hash.empty?
        yield(*levels, hash)
      else
        hash.map do |key, value|
          if value.is_a?(Hash)
            do_recurvively(value, levels: [*levels, key], &block)
          else
            yield(*levels, key, value)
          end
        end
      end
    end

    def resolve_schema(schema)
      if schema.has_key?("$ref")
        ::JsonReference.reference(schema["$ref"]).resolve_pointer(@store.lookup_schema(schema["$ref"].split("#").first))
      else
        ::JsonScheam::Schema.parse(schema).expand_references!()
      end
    end
  end
end
