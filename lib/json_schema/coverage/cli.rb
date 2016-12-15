require "json_schema/coverage"

require "thor"
require "multi_json"

class JsonSchema::Coverage
  class CLI < ::Thor
    default_command :coverage

    desc "coverage", "calculate coverage (default)"
    option :schema, type: :array, default: %w[ schema/**/*.json ]
    option :tests,  type: :array, default: %w[  tests/**/*.json ]
    def coverage
      store = load_schema(options[:schema].map {|schema| Dir[schema] }.flatten.uniq)
      suite = load_suite(options[:tests].map {|test| Dir[test] }.flatten.uniq)

      cov = ::JsonSchema::Coverage.new(store)

      suite.each {|tests| cov.run(tests) }

      cov.print_c0
    end

    protected
    def load_schema(files)
      store  = ::JsonSchema::DocumentStore.new

      files.each {|file| store.add_schema(::JsonSchema.parse!(::MultiJson.load(::File.read(file)))) }
      store.each {|uri, schema| schema.expand_references(store: store) }  # no lazy
      store.each {|uri, schema| schema.expand_references!(store: store) } # for circular reference

      store
    end

    def load_suite(files)
      files.map {|file| ::MultiJson.load(::File.read(file)) }
    end
  end
end
