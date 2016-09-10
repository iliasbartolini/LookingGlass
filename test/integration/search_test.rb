require 'test_helper'

class SearchTest < ActionDispatch::IntegrationTest


  #TODO: setup scenario dataspec configuration
  #TODO: setup scenario index data configuration

  test 'Should display sidebar with filters and facets' do
    visit root_path

    assert has_selector?('.title', text: 'Docs search test')

    assert_search_result_count_is('274 Total')

    assert_filter_category_is_present('Select Filter Categories')
    assert_filter_category_is_present('Indeed Filters')
    assert_filter_category_is_present('LinkedIn Filters')

    assert_filter_is_present('Company')
    assert_filter_is_present('Search Terms')
    assert_filter_is_present('Area')
    assert_filter_is_present('Company Location')


    find('#sidebar_company_location_facet', text: 'Company Location').click

    within('#sidebar_company_location_facet') do
      #verify facets values filter links
      assert find_link('Chicago, IL (35)').visible?
      assert find_link('San Francisco, CA (16)').visible?

      find('label.tree-toggler.plus').click
      assert find_link('Dallas, TX (8)').visible?
    end
  end

  test 'Search on Indeed dataset filter' do
    visit root_path

    within('#sidebar_company_location_facet') { click_link 'Chicago, IL (35)'}
    assert has_selector?('#search-details .detail', text: '35 Total')

    within('#searchtags') do
      assert has_selector?('.search-filter', text: 'Chicago, IL')
      assert has_selector?('.category', text: 'Company Location [filter]')
    end
    assert_search_result_count_is('35 Total')

    within('#searchtags') { click_link 'X' }

    assert_search_result_count_is('274 Total')
  end

  test 'Search on LinkedIn dataset filter' do
    visit root_path

    find('#sidebar_area_facet', text: 'Area').click
    within('#sidebar_area_facet') { click_link 'United Kingdom (14)'}
    assert_search_result_count_is('14 Total')

    within('#searchtags') do
      assert has_selector?('.search-filter', text: 'United Kingdom')
      assert has_selector?('.category', text: 'Area [filter]')
    end
    assert_search_result_count_is('14 Total')

    within('#searchtags') { click_link 'X' }

    assert_search_result_count_is('274 Total')
  end

  test 'Search on a common multi-dataset filter' do
    visit root_path

    find('#sidebar_company_facet', text: 'Company').click
    within('#sidebar_company_facet') { click_link 'Self-Employed (4)'}
    assert_search_result_count_is('4 Total')

    within('#searchtags') do
      assert has_selector?('.search-filter', text: 'Self-Employed')
      assert has_selector?('.category', text: 'Company [filter]')
    end

    find('#sidebar_location_facet', text: 'Location').click
    within('#sidebar_location_facet') do
      assert find_link('Alameda, CA (3)').visible?
      assert find_link('London (1)').visible?
      click_link 'London (1)'
    end

    within('#searchtags') do
      assert has_selector?('.search-filter', text: 'Self-Employed')
      assert has_selector?('.search-filter', text: 'Location')
    end
    assert_search_result_count_is('1 Total')

    within('#search_filter_company_facet') { click_link 'X' }
    assert_search_result_count_is('10 Total')

    within('#search_filter_location_facet') { click_link 'X' }
    assert_search_result_count_is('274 Total')
  end

  test 'Search query and filters combinations' do
    visit root_path

    fill_in 'q', with: 'Tool'
    find('#search-button-all').click

    assert_search_result_count_is('56 Total')

    #TODO:
    # find('#sidebar_company_facet', text: 'Company').click
    # within('#sidebar_company_facet') { click_link 'Self-Employed (4)'}
    # assert_search_result_count_is('4 Total')
    #
    # within('#searchtags') do
    #   assert has_selector?('.search-filter', text: 'Self-Employed')
    #   assert has_selector?('.category', text: 'Company [filter]')
    # end

  end


  private
  def assert_search_result_count_is(doc_count)
    assert has_selector?('#search-details .detail', text: doc_count)
  end

  def assert_filter_category_is_present(description)
    assert has_selector?('#sidebar div', text: description)
  end

  def assert_filter_is_present(description)
    assert has_selector?('#sidebar label', text: description)
  end

  ##TODO: check document displayed

  ##TODO: check text search

  #TODO: import test data
    #introduce config x.dataset.base_path
    #Load via IndexManager vs API?

  #TODO: scenario: more search term per crawler
  #TODO: scenario: more than one index/crawler in configuration
    #TODO:  overlapping categories

end

