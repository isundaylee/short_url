require 'bundler/setup'
require 'sinatra/base'
require 'sinatra/respond_with'
require 'sinatra/assetpack'
require 'haml'
require 'uri'
require 'json'

require_relative './url_store'

class ShortURL < Sinatra::Base

  register Sinatra::RespondWith
  register Sinatra::AssetPack

  assets do
    css :application, [
      '/css/app.css'
    ]

    css_compression :sass
  end

  configure do
    @@store = URLStore.new
  end

  helpers do
    def base_url
      @base_url ||= "#{request.env['rack.url_scheme']}://#{request.env['HTTP_HOST']}"
    end
  end

  get '/', provides: [:html] do
    url = params[:url]

    url.nil? ? (haml :index) : (haml :show, locals: {url: url})
  end

  post '/:name?', provides: [:html, :json] do
    begin
      name = @@store.create(params[:url], params[:name])
      url = "#{base_url}/#{name}"
      respond_to do |f|
        f.html { redirect '/?url=' + CGI.escape(url) }
        f.json { respond_json url: url }
      end
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