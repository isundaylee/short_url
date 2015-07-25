require 'rack/test'
require 'fakeredis/rspec'
require 'rspec'
require 'json'

require_relative '../app.rb'

ENV['RACK_ENV'] = 'test'

def app
  ShortURL
end

RSpec.configure do |config|
  config.include Rack::Test::Methods
end

