Gem::Specification.new do |s|
  s.name        = 'cloud-templates'
  s.version     = '0.3.0'
  s.license     = 'Apache 2.0'
  s.summary     = 'Hierarchical data templates'
  s.description = 'MVC-based templating framework for hierarchical data structures. ' \
                  'It is created to fulfil different needs of putting your entire application ' \
                  'configuration and infrastructure definition under the same roof.'
  s.authors     = ['Ivan Matylitski', 'Corrado Primier']
  s.email       = ['buffovich@gmail.com', 'cp@corradoprimier.it']
  s.files       = Dir['lib/**/*'] +
                  Dir['spec/**/*'] +
                  Dir['examples/**/*'] +
                  [
                    'LICENSE', 'Gemfile', 'NOTICE', 'README.md', 'Rakefile',
                    '.rubocop.yml', '.simplecov', 'cloud-templates.gemspec',
                    '.rspec'
                  ]
  s.executables << 'cloud-templates-runner.rb'
  s.test_files = Dir['spec/**/*'] + Dir['examples/spec/**/*']
  s.homepage    = 'https://rubygems.org/gems/cloud-templates'
  s.required_ruby_version = Gem::Requirement.new(">= 2.4.0")
  s.add_dependency('facets', '>=3.0', '~> 3')
  s.add_dependency('concurrent-ruby', '>=1.0.4', '~>1.0')
  s.add_development_dependency('rspec', '>= 3.2', '~> 3')
  s.add_development_dependency('rubocop', '~> 0.46')
  s.add_development_dependency('rubocop-rspec', '~> 1.17')
  s.add_development_dependency('byebug', '>= 9.0.5', '~> 9')
  s.add_development_dependency('yard', '~> 0.9')
  s.add_development_dependency('simplecov', '~> 0.14')
end
