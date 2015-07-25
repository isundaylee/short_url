require_relative './spec_helper'

describe ShortURL do
  context "requesting JSON response" do
    before :each do
      header 'ACCEPT', 'application/json'
    end

    describe "POST /:name?" do
      it "should allow creating validly named short URL" do
        post '/', name: 'test', url: 'http://example.com'
        expect(last_response).to be_ok
        response_json = JSON.parse(last_response.body)
        expect(response_json['url']).to eq('http://example.org/test')
        get "#{response_json['url']}"
        expect(JSON.parse(last_response.body)['actual_url']).to eq('http://example.com')
      end

      it "should not allow creating invalidly named short URL" do
        post '/', name: 'test.', url: 'http://example.com'
        expect(last_response.status).to eq(400)
        expect(JSON.parse(last_response.body)).to eq({'error' => 'Invalid name. '})
      end

      it "should not allow creating short URL with duplicate name" do
        post '/', name: 'test', url: 'http://example.com'
        post '/', name: 'test', url: 'http://example.com/something'
        expect(last_response.status).to eq(400)
        expect(JSON.parse(last_response.body)).to eq({'error' => 'Name already taken. '})
      end

      it "should allow creating short URL without specific name" do
        post '/', url: 'http://example.com'
        expect(last_response).to be_ok
        response_json = JSON.parse(last_response.body)
        get "#{response_json['url']}"
        expect(JSON.parse(last_response.body)['actual_url']).to eq('http://example.com')
      end

      it "should prepend http:// appropriately" do
        post '/', url: 'example.com'
        expect(last_response).to be_ok
        response_json = JSON.parse(last_response.body)
        get "#{response_json['url']}"
        expect(JSON.parse(last_response.body)['actual_url']).to eq('http://example.com')
      end

      it "should not prepend http:// when the url already has protocol component" do
        post '/', url: 'git://example.com'
        expect(last_response).to be_ok
        response_json = JSON.parse(last_response.body)
        get "#{response_json['url']}"
        expect(JSON.parse(last_response.body)['actual_url']).to eq('git://example.com')
      end
    end

    describe "GET /:name" do
      it "should return the actual URL if name exists" do
        post '/test', {url: 'http://example.com'}
        expect(last_response).to be_ok
        get '/test'
        expect(JSON.parse(last_response.body)['actual_url']).to eq('http://example.com')
      end

      it "should return 404 if name doesn't exist" do
        get '/test'
        expect(last_response.status).to eq(404)
        expect(JSON.parse(last_response.body)['error']).to eq('Name does not exist. ')
      end
    end

  end

  context "requesting HTML response" do
    before :each do
      header 'ACCEPT', 'text/html'
    end

    describe "GET /:name" do
      it "should redirect to the actual URL if name exists" do
        post '/test', {url: 'http://example.com'}, {'HTTP_ACCEPT' => 'application/json'}
        expect(last_response).to be_ok
        get '/test'
        expect(last_response).to be_redirect
        expect(last_response.location).to eq('http://example.com')
      end

      it "should return 404 if name doesn't exist" do
        get '/test'
        expect(last_response.status).to eq(404)
        expect(last_response.body).to include('Name does not exist. ')
      end
    end
  end
end
