require 'test_helper'

class SearchTest < ActionDispatch::IntegrationTest

  #TODO: setup scenario dataspec configuration
  #TODO: setup scenario index data configuration

  test 'Doc search homepage' do
    visit root_path

    #verify page is loaded
    assert has_selector?('.title', text: 'Docs search test')
    assert has_selector?('#search-details .detail', text: '241 Total')

    #verify facets categories are present
    assert has_selector?('#sidebar label', text: 'Company')
    assert has_selector?('#sidebar label', text: 'Location')
    assert has_selector?('#sidebar label', text: 'Company Location')
    assert has_selector?('#sidebar label', text: 'Search Terms')


    #TODO: beware ambiguous selectors
    find('#sidebar_company_location_facet', text: 'Company Location').click


    within('#sidebar_company_location_facet') do

      #verify facets values filter links
      assert find_link('Chicago, IL (35)').visible?
      assert find_link('San Francisco, CA (16)').visible?

      #TODO: beware ambiguous selectors
      find('label.tree-toggler.plus').click

      #verify additional facets values filter links
      assert find_link('Dallas, TX (8)').visible?

    end

  end

  #TODO: scenario: more search term per crawler
  #TODO: scenario: more than one index/crawler in configuration
    #TODO:  overlapping categories

end

