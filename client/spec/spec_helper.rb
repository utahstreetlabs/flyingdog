require 'rubygems'
require 'bundler'

Bundler.setup

require 'mocha_standalone'
require 'rspec'
require 'ladon'
require 'flying_dog/resources/base'

Ladon.hydra = Typhoeus::Hydra.new
Ladon.logger = Logger.new('/dev/null')

FlyingDog::ResourceBase.base_url = 'http://localhost:4071'

RSpec.configure do |config|
  config.mock_with :mocha
end
