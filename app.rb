require 'bundler/setup'
require 'sinatra/base'
require 'json'

require_relative './url_store'

class ShortURL < Sinatra::Base

  configure do
    @@store = URLStore.new
  end

  before do
    content_type :json
  end

  helpers do
    def base_url
      @base_url ||= "#{request.env['rack.url_scheme']}://#{request.env['HTTP_HOST']}"
    end
  end

  post '/:name?' do
    begin
      name = @@store.create(params[:url], params[:name])
      respond url: "#{base_url}/#{name}"
    rescue URLStore::Exception => e
      exception e
    end
  end

  get '/:name' do
    begin
      respond actual_url: @@store.get(params[:name])
    rescue URLStore::Exception => e
      exception e
    end
  end

  private

    def respond(obj)
      obj.to_json
    end

    def exception(e)
      error 400, {error: e.message}.to_json
    end

end