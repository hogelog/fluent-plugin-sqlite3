# -*- encoding: utf-8 -*-
Gem::Specification.new do |gem|
  gem.name          = "fluent-plugin-sqlite3"
  gem.version       = "0.0.1"
  gem.authors       = ["Sunao KOMURO"]
  gem.email         = ["konbu.komuro@gmail.com"]
  gem.description   = %q{SQLite3 plugin for Fluent}
  gem.summary       = gem.description
  gem.homepage      = "https://github.com/hogelog/fluent-plugin-sqlite3"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency "fluentd"
  gem.add_dependency "sqlite3"
  gem.add_development_dependency "rake"
  gem.add_development_dependency "minitest-reporters"
end
