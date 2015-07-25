require_relative './spec_helper'

describe ShortURL do
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
