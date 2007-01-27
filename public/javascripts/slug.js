// See http://pmade.com/svn/oss/devalot/trunk/LICENSE
function make_slug (from_string)
{
    slug = from_string.replace(/^\s+/, '').replace(/\s+$/, '');
    slug = slug.toLowerCase();
    slug = slug.replace(/[^-a-z0-9\s_]+/g, '');
    slug = slug.replace(/\s+/g, '-');

    return slug;
}

function article_title_observer ()
{
    previous_title_slug = make_slug($title_value);
    current_title_slug  = make_slug($title_element.value || '');

    if (previous_title_slug == $slug_element.value) {
        $slug_element.value = current_title_slug;
    }

    $title_value = $title_element.value || '';
}

function setup_article_js ()
{
    $title_element = $('article_title');
    $slug_element  = $('article_slug');
    $title_value   = $title_element.value || '';
    Event.observe('article_title', 'keyup', article_title_observer);
}
