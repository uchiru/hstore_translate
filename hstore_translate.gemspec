$:.push File.expand_path('../lib', __FILE__)
require 'hstore_translate/version'

Gem::Specification.new do |s|
  s.name              = 'hstore_translate'
  s.version           = HstoreTranslate::VERSION
  s.summary           = "Rails I18n library for ActiveRecord model/data translation using PostgreSQL's hstore datatype."
  s.description       = "#{s.summary} Translations are stored directly in the model table rather than shadow tables."
  s.authors           = ['Rob Worley', 'Cédric Fabianski']
  s.email             = 'cfabianski@me.com'
  s.homepage          = 'https://github.com/cfabianski/hstore_translate'
  s.platform          = Gem::Platform::RUBY
  s.license           = 'MIT'

  s.files             = Dir['lib/**/*.rb', 'README.md', 'MIT-LICENSE']
  s.test_files        = Dir['test/**/*']
  s.require_paths     = ['lib']

  s.add_dependency 'activerecord', '>= 4.1.8'

  s.add_development_dependency 'rake'
  s.add_development_dependency 'minitest', '>= 4.0'
  s.add_development_dependency 'database_cleaner'
end
