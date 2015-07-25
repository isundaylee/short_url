require 'redis'

class URLStore

  class Exception < StandardError; end

  VALID_NAME_REGEX = /^[a-zA-Z0-9_-]+$/
  VALID_GENERATED_CHARS = ('a'..'z').to_a + ('A'..'Z').to_a + ('0'..'9').to_a
  GENERATED_LENGTH = 2
  URL_PREFIX_TEST_REGEX = /^[a-zA-Z]*:\/\//

  def initialize
    # reads configuration from ENV['REDIS_URL']
    @redis = Redis.new
  end

  def self.valid_name?(name)
    !!(VALID_NAME_REGEX =~ name)
  end

  def create(url, name)
    raise Exception, 'Must provide a URL. ' if url.nil?
    raise Exception, 'Invalid name. ' unless (name.nil? || self.class.valid_name?(name))

    name ||= generate_name
    url = normalize_url(url)

    result = @redis.setnx(redis_key(name), url)

    raise Exception, 'Name already taken. ' unless result

    name
  end

  def get(name)
    raise Exception, 'Invalid name. ' if (name.nil? || !self.class.valid_name?(name))

    url = @redis.get(redis_key(name))

    raise Exception, 'Name does not exist. ' if url.nil?

    url
  end

  private
    def redis_key(name)
      "urls:#{name}"
    end

    def generate_usable_name
      while true do
        name = generate_name
        return name if @redis.get(name).nil?
      end
    end

    def generate_name
      (0...GENERATED_LENGTH).to_a.map { VALID_GENERATED_CHARS.sample }.join
    end

    def normalize_url(url)
      URL_PREFIX_TEST_REGEX =~ url ? url : "http://#{url}"
    end

end