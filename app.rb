require 'bundler/setup'
require 'sinatra/base'
require 'sinatra/respond_with'
require 'sinatra/assetpack'
require 'active_support'
require 'active_support/core_ext/object/blank'
require 'haml'
require 'coffee_script'
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

    js :application, [
      '/js/app.js'
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
      name = @@store.create(params[:url].presence, params[:name].presence)
      url = "#{base_url}/#{name}"
      respond_to do |f|
        f.html { redirect '/?url=' + CGI.escape(url) }
        f.json { respond_json url: url }
      end
    rescue URLStore::Error => e
      respond_to do |f|
        f.html { haml :index, locals: {url: params[:url], name: params[:name], error: e.message} }
        f.json { exception e }
      end
    end
  end

  get '/:name', provides: [:html, :json] do
    begin
      respond_to do |f|
        f.html { redirect @@store.get(params[:name]) }
        f.json { respond_json actual_url: @@store.get(params[:name]) }
      end
    rescue URLStore::NotFoundError => e
      exception e
    rescue URLStore::Error => e
      exception e
    end
  end

  private

    def respond_json(obj)
      obj.to_json
    end

    def exception(e)
      code = 400 if e.is_a? URLStore::ArgumentError
      code = 404 if e.is_a? URLStore::NotFoundError
      respond_to do |f|
        f.html { error code, e.message }
        f.json { error code, {error: e.message}.to_json }
      end
    end

end