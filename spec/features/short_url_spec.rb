require_relative './features_spec_helper'

describe 'ShortURL features', type: :feature do
  specify 'creating a short URL through HTML' do
    visit '/'
    fill_in 'url', with: 'example.com'
    click_button 'Go!'
    expect(find('input[name=url]').value).to match(/^http:\/\/www.example.com\/([a-zA-Z0-9]*)$/)
  end
end