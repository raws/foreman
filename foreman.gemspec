# -*- encoding: utf-8 -*-
require File.expand_path("../lib/foreman/version", __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Ross Paffett"]
  gem.email         = ["ross@rosspaffett.com"]
  gem.description   = "Minecraft server wrapper"
  gem.summary       = "Minecraft server wrapper"
  gem.homepage      = "https://github.com/raws/foreman"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "foreman"
  gem.require_paths = ["lib"]
  gem.version       = Foreman::VERSION

  gem.add_dependency "eventmachine", "~> 1.0.0"
  gem.add_dependency "uuid", "~> 2.3.5"
end
