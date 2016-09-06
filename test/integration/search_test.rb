require 'test_helper'

class SearchTest < ActionDispatch::IntegrationTest

  test 'Doc search homepage' do
    visit root_path
    assert has_content?('Docs')
  end

end
