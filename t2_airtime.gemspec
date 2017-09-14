$LOAD_PATH.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 't2_airtime/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 't2_airtime'
  s.version     = T2Airtime::VERSION
  s.authors     = ['matteolc']
  s.email       = ['matteo@voxbox.io']

  s.summary     = 'Wrapper methods to interface with [TransferTo](https://www.transfer-to.com/home) Airtime API'
  s.description = 'Wrapper methods to interface with [TransferTo](https://www.transfer-to.com/home) Airtime API'
  s.homepage    = 'https://github.com/matteolc/t2_airtime'
  s.license     = 'MIT'

  s.files = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']
  s.test_files = Dir['spec/**/*']

  s.add_development_dependency 'rspec-rails', '~> 3.6'
  s.add_development_dependency 'rack-cors'

  s.add_dependency 'rails', '~> 5.1.3'
  s.add_dependency 'dotenv-rails', '~> 2.2', '>= 2.2.1'
  s.add_dependency 'faraday', '0.9.1'
  s.add_dependency 'countries', '2.1.2'
end
