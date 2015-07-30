# encoding: UTF-8
Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'spree_sagepayform'
  s.version     = '1.2.14'
  s.summary     = 'Spree Sagepay Forms integration'
  s.description = 'Payment adapert for spree sagepay'
  s.required_ruby_version = '>= 1.8.7'

  s.author    = 'Douglas Mills'
  s.email     = 'slipdigital@gmail.com'
  s.homepage  = 'https://github.com/slipdigital'

  #s.files       = `git ls-files`.split("\n")
  #s.test_files  = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_path = 'lib'
  s.requirements << 'none'

  s.add_dependency 'spree_core', '~> 1.2.0'
  s.add_dependency 'activemerchant', '1.28.0'
  s.add_dependency 'sagepay_protocol3'


  s.add_development_dependency 'rspec'
  s.add_development_dependency 'capybara', '1.0.1'
  s.add_development_dependency 'factory_girl', '~> 2.6.4'
  s.add_development_dependency 'ffaker'
  s.add_development_dependency 'rspec-rails',  '~> 2.9'
  s.add_development_dependency 'sqlite3'
end
