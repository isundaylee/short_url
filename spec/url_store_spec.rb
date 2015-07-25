require_relative './spec_helper'

require 'securerandom'

describe URLStore do
  it "should auto-adapt name length" do
    # the size of charset we're using is 26+26+10=62. by default, URLStore
    # generates names with len 2. that would allow 62*62<4000 urls. therefore,
    # this tests tries to generate 5000 short URLS, therefore testing that
    # URLStore auto-increases name length.
    store = URLStore.new
    names = []
    5000.times do
      names << store.create("http://#{SecureRandom.hex}.com", nil)
    end
    lengths = names.map(&:length)


    puts '    Shortest: ' + lengths.min.to_s
    puts '    Average: ' + (1.0 * lengths.inject(:+) / lengths.size).to_s
    puts '    Longest: ' + lengths.max.to_s
  end
end
