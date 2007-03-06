################################################################################
require File.dirname(__FILE__) + '/../test_helper'

################################################################################
class FilteredTextTest < Test::Unit::TestCase
  ################################################################################
  include PagesHelper
  include TicketsHelper
  include FilteredTextHelper

  ################################################################################
  fixtures(:filtered_texts, :projects, :pages)

  ################################################################################
  def test_cache_doesnt_whack_body
    project = projects(:support)
    body = '[[index]]'

    ft = FilteredText.new(:body => body.dup, :allow_caching => true)
    assert(ft.save)

    mock = OpenStruct.new(:project => project, :filtered_text => ft)
    text = render_filtered_text(mock, :sanitize => false)
    assert_equal(body, ft.body)
    assert_equal(text, ft.body_cache)
  end

  ################################################################################
  def test_plain_link_to_real_link
    ft = FilteredText.new(:body => '<a href="http://reallink">Real</a> http://fake.')
    text = render_filtered_text(ft, :sanitize => false)
    assert_equal('<a href="http://reallink">Real</a> <a href="http://fake">http://fake</a>.', text)

    ft = FilteredText.new(:body => 'http://somelink/foo/bar/tes_here.html.')
    text = render_filtered_text(ft, :sanitize => false)
    assert_equal('<p><a href="http://somelink/foo/bar/tes_here.html">http://somelink/foo/bar/tes_here.html</a>.</p>', text)
  end

  ################################################################################
  def link_to (*args)
    %Q(<a href="http://localhost/test/link">Link</a>)
  end

end
################################################################################
