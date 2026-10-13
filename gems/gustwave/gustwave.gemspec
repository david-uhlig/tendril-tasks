# frozen_string_literal: true

require_relative "lib/gustwave/version"

Gem::Specification.new do |spec|
  spec.name = "gustwave"
  spec.version = Gustwave::VERSION
  spec.authors = [ "David Uhlig" ]
  spec.summary = "Flowbite components for Rails, built with ViewComponent"
  spec.homepage = "https://github.com/david-uhlig/gustwave"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2"

  spec.files = Dir["{app,config,lib}/**/*", "LICENSE.txt", "README.md"]

  spec.add_dependency "inline_svg"
  spec.add_dependency "nokogiri"
  spec.add_dependency "railties", ">= 8.0"
  spec.add_dependency "tailwind_merge", "~> 1.5"
  spec.add_dependency "view_component", "~> 4.0"
end
