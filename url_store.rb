require 'redis'

class URLStore

  class Error < StandardError; end
  class ArgumentError < Error; end
  class NotFoundError < Error; end

  VALID_NAME_REGEX = /^[a-zA-Z0-9_-]+$/
  VALID_GENERATED_CHARS = ('a'..'z').to_a + ('A'..'Z').to_a + ('0'..'9').to_a
  GENERATED_LENGTH_START = 2
  RETRIES_EACH_LENGTH = 10
  URL_PREFIX_TEST_REGEX = /^[a-zA-Z]*:\/\//

  def initialize
    # reads configuration from ENV['REDIS_URL']
    @redis = Redis.new
  end

  def self.valid_name?(name)
    !!(VALID_NAME_REGEX =~ name)
  end

  def create(url, name)
    raise ArgumentError, 'Must provide a URL. ' if url.nil?
    raise ArgumentError, 'Invalid name. ' unless (name.nil? || self.class.valid_name?(name))

    name ||= generate_usable_name
    url = normalize_url(url)

    result = @redis.setnx(redis_key(name), url)

    raise ArgumentError, 'Name already taken. ' unless result

    name
  end

  def get(name)
    raise ArgumentError, 'Invalid name. ' if (name.nil? || !self.class.valid_name?(name))

    url = @redis.get(redis_key(name))

    raise NotFoundError, 'Name does not exist. ' if url.nil?

    url
  end

  private
    def redis_key(name)
      "urls:#{name}"
    end

    def generate_usable_name
      len = GENERATED_LENGTH_START
      while true
        RETRIES_EACH_LENGTH.times do
          name = generate_name(len)
          return name if @redis.get(redis_key(name)).nil?
        end
        len += 1
      end
    end

    def generate_name(len)
      (0...len).to_a.map { VALID_GENERATED_CHARS.sample }.join
    end

    def normalize_url(url)
      URL_PREFIX_TEST_REGEX =~ url ? url : "http://#{url}"
    end

end