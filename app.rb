require 'bundler/setup'
require 'sinatra/base'
require 'sinatra/respond_with'
require 'json'

require_relative './url_store'

class ShortURL < Sinatra::Base

  register Sinatra::RespondWith

  configure do
    @@store = URLStore.new
  end

  helpers do
    def base_url
      @base_url ||= "#{request.env['rack.url_scheme']}://#{request.env['HTTP_HOST']}"
    end
  end

  post '/:name?', provides: [:json] do
    begin
      name = @@store.create(params[:url], params[:name])
      respond_json url: "#{base_url}/#{name}"
    rescue URLStore::Exception => e
      exception e
    end
  end

  get '/:name', provides: [:html, :json] do
    begin
      respond_to do |f|
        f.html { redirect @@store.get(params[:name]) }
        f.json { respond_json actual_url: @@store.get(params[:name]) }
      end
    rescue URLStore::NotFoundError => e
      exception e, 404
    rescue URLStore::Exception => e
      exception e
    end
  end

  private

    def respond_json(obj)
      obj.to_json
    end

    def exception(e, code = 400)
      respond_to do |f|
        f.html { error code, e.message }
        f.json { error code, {error: e.message}.to_json }
      end
    end

end