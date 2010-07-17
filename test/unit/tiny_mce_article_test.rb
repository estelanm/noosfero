require File.dirname(__FILE__) + '/../test_helper'

class TinyMceArticleTest < ActiveSupport::TestCase

  def setup
    Article.rebuild_index
    @profile = create_user('zezinho').person
  end
  attr_reader :profile
  
  # this test can be removed when we get real tests for TinyMceArticle 
  should 'be an article' do
    assert_subclass TextArticle, TinyMceArticle
  end

  should 'define description' do
    assert_kind_of String, TinyMceArticle.description
  end

  should 'define short description' do
    assert_kind_of String, TinyMceArticle.short_description
  end

  should 'be found when searching for articles by query' do
    tma = TinyMceArticle.create!(:name => 'test tinymce article', :body => '---', :profile => profile)
    assert_includes TinyMceArticle.find_by_contents('article'), tma
    assert_includes Article.find_by_contents('article'), tma
  end

  should 'not sanitize target attribute' do
    article = TinyMceArticle.create!(:name => 'open link in new window', :body => "open <a href='www.invalid.com' target='_blank'>link</a> in new window", :profile => profile)
    assert_tag_in_string article.body, :tag => 'a', :attributes => {:target => '_blank'}
  end

  should 'not translate & to amp; over times' do
    article = TinyMceArticle.create!(:name => 'link', :body => "<a href='www.invalid.com?param1=value&param2=value'>link</a>", :profile => profile)
    assert article.save
    assert_no_match(/&amp;amp;/, article.body)
    assert_match(/&amp;/, article.body)
  end

  should 'not escape comments from tiny mce article body' do
    article = TinyMceArticle.create!(:profile => profile, :name => 'article', :abstract => 'abstract', :body => "the <!-- comment --> article ...")
    assert_equal "the <!-- comment --> article ...", article.body
  end

  should 'convert entities characters to UTF-8 instead of ISO-8859-1' do
    article = TinyMceArticle.create!(:profile => profile, :name => 'teste ' + Time.now.to_s, :body => '<a title="inform&#225;tica">link</a>')
    assert(article.body.is_utf8?, "%s expected to be valid UTF-8 content" % article.body.inspect)
  end

  should 'fix tinymce mess with itheora comments for IE from tiny mce article body' do
    article = TinyMceArticle.create!(:profile => profile, :name => 'article', :abstract => 'abstract', :body => "the <!--–-[if IE]--> just for ie... <!--[endif]-->")
    assert_equal "the <!–-[if IE]> just for ie... <![endif]-–>", article.body
  end

  should 'not mess with <iframe and </iframe if it is from itheora' do
    article = TinyMceArticle.create!(:profile => profile, :name => 'article', :abstract => 'abstract', :body => "<iframe src='http://itheora.org'></iframe>")
    assert_equal "<iframe src=\"http://itheora.org\"></iframe>", article.body
  end

  should 'remove iframe if it is not from itheora or softwarelivre' do
    article = TinyMceArticle.create!(:profile => profile, :name => 'article', :abstract => 'abstract', :body => "<iframe src='anything'></iframe>")
    assert_equal "", article.body
  end

  should 'allow iframe if it is from stream.softwarelivre.org' do
    article = TinyMceArticle.create!(:profile => profile, :name => 'article', :abstract => 'abstract', :body => "<iframe src='http://stream.softwarelivre.org'></iframe>")
    assert_equal "<iframe src=\"http://stream.softwarelivre.org\"></iframe>", article.body
  end

  #TinymMCE convert config={"key":(.*)} in config={&quotkey&quot:(.*)}
  should 'not replace &quot with &amp;quot; when adding an Archive.org video' do
    article = TinyMceArticle.create!(:profile => profile, :name => 'article', :abstract => 'abstract', :body => "<embed flashvars='config={&quot;key&quot;:&quot;\#$b6eb72a0f2f1e29f3d4&quot;}'> </embed>")
    assert_equal "<embed flashvars=\"config={&quot;key&quot;:&quot;\#$b6eb72a0f2f1e29f3d4&quot;}\"> </embed>", article.body
  end

  should 'not sanitize html comments' do
    article = TinyMceArticle.new
    article.body = '<p><!-- <asdf> << aasdfa >>> --> <h1> Wellformed html code </h1>'
    article.valid?

    assert_match  /<!-- .* --> <h1> Wellformed html code <\/h1>/, article.body
  end

end
