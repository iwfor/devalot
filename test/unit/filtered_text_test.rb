################################################################################
require File.dirname(__FILE__) + '/../test_helper'

################################################################################
class FilteredTextTest < Test::Unit::TestCase
  ################################################################################
  include PagesHelper
  include TicketsHelper
  include FilteredTextHelper

  ################################################################################
  fixtures(:filtered_texts, :projects, :users, :status_levels, :pages)

  ################################################################################
  def test_cache_doesnt_whack_body
    project = projects(:support)
    body = '[[index]]'

    ft = FilteredText.new(:body => body.dup, :allow_caching => true)
    ft.created_by = users(:admin)
    ft.updated_by = users(:admin)
    assert(ft.save)

    # Make sure the fixture was setup correctly
    assert(ft.updated_by.can_skip_sanitize?)
    assert(ft.updated_by.can_use_radius?)

    mock = OpenStruct.new(:project => project, :filtered_text => ft)
    text = render_filtered_text(mock)
    assert_equal(body, ft.body)
    assert_equal(text, ft.body_cache)
  end

  ################################################################################
  def test_plain_link_to_real_link
    ft = FilteredText.new(:body => '<a href="http://reallink">Real</a> http://fake.')
    ft.created_by = users(:admin)
    ft.updated_by = users(:admin)
    text = render_filtered_text(ft)
    assert_equal('<a href="http://reallink">Real</a> <a href="http://fake">http://fake</a>.', text)

    ft = FilteredText.new(:body => 'http://somelink/foo/bar/tes_here.html.')
    ft.created_by = users(:admin)
    ft.updated_by = users(:admin)
    text = render_filtered_text(ft)
    assert_equal('<p><a href="http://somelink/foo/bar/tes_here.html">http://somelink/foo/bar/tes_here.html</a>.</p>', text)
  end

  ################################################################################
  def link_to (*args)
    %Q(<a href="http://localhost/test/link">Link</a>)
  end

end
################################################################################
