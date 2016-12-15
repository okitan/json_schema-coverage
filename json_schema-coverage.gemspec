# coding: utf-8
Gem::Specification.new do |spec|
  spec.name          = "json_schema-coverage"
  spec.version       = File.read(File.expand_path("../VERSION", __FILE__))
  spec.authors       = ["okitan"]
  spec.email         = ["okitakunio@bmail.com"]

  spec.summary       = "JSON Schema test suite converage tool"
  spec.description   = "JSON Schema test suite converage tool"
  spec.homepage      = "https://github.com/okitan/json_schema-coverage"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "json_schema"
  spec.add_dependency "json_schema-faker"
  spec.add_dependency "thor"
  spec.add_dependency "multi_json"

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"

  # debug
  spec.add_development_dependency "pry"
end
