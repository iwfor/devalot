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
    @project = projects(:support)
    body = '[[index]]'

    ft = FilteredText.new(:body => body.dup, :allow_caching => true)
    assert(ft.save)

    text = render_filtered_text(ft, :sanitize => false)
    assert_equal(body, ft.body)
    assert_equal(text, ft.body_cache)
  end

  ################################################################################
  def link_to (*args)
    %Q(<a href="http://localhost/test/link">Link</a>)
  end

end
################################################################################
