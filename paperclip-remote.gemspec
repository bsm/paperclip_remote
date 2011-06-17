# -*- encoding: utf-8 -*-
Gem::Specification.new do |s|
  s.platform = Gem::Platform::RUBY
  s.required_ruby_version = '>= 1.8.7'
  s.required_rubygems_version = ">= 1.3.6"

  s.name        = "paperclip-remote"
  s.summary     = "Plugin for Paperclip"
  s.description = "Allows to fetch attachments from remote locations"
  s.version     = '0.1.0'

  s.authors     = ["Dimitrij Denissenko"]
  s.email       = "dimitrij@blacksquaremedia.com"
  s.homepage    = "https://github.com/bsm/paperclip-remote"

  s.require_path = 'lib'
  s.files        = Dir['LICENSE', 'README.rdoc', 'lib/**/*', 'rails/**/*']

  s.add_dependency "paperclip", "~> 2.3.0"
end