require_relative './features_spec_helper'

describe 'ShortURL features', type: :feature do
  specify 'creating a short URL through HTML' do
    visit '/'
    fill_in 'url', with: 'example.com'
    click_button 'Go!'
    expect(find('input[name=url]').value).to match(/^http:\/\/www.example.com\/([a-zA-Z0-9]*)$/)
  end

  specify 'creating a short URL with custom name through HTML' do
    visit '/'
    fill_in 'url', with: 'example.com'
    fill_in 'name', with: 'test'
    click_button 'Go!'
    expect(find('input[name=url]').value).to eq('http://www.example.com/test')
  end

  specify 'displaying errors from backend' do
    visit '/'
    fill_in 'url', with: 'example.com'
    fill_in 'name', with: 'test.'
    click_button 'Go!'
    expect(page.body).to include('Invalid name.')
  end
end