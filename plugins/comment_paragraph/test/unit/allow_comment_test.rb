require File.dirname(__FILE__) + '/../test_helper'

class AllowCommentTest < ActiveSupport::TestCase

  def setup
    @macro = CommentParagraphPlugin::AllowComment.new
    @environment = Environment.default
    @environment.enable_plugin(CommentParagraphPlugin)

    @profile = fast_create(Community)

    @article = fast_create(TextArticle, :profile_id => profile.id, :body => 'inner')
    @article.comment_paragraph_plugin_activate = true
    @article.save!

    @comment = fast_create(Comment, :paragraph_uuid => 1, :source_id => article.id)
    @controller = mock
  end

  attr_reader :macro, :profile, :article, :controller, :comment, :environment

  should 'have a configuration' do
    assert CommentParagraphPlugin::AllowComment.configuration
  end

  should 'parse contents to include comment paragraph view' do
    content = macro.parse({:paragraph_uuid => comment.paragraph_uuid}, article.body, article)
    controller.expects(:kind_of?).with(ContentViewerController).returns(true)

    expects(:render).with({:partial => 'comment_paragraph_plugin_profile/comment_paragraph', :locals => {:paragraph_uuid => comment.paragraph_uuid, :article_id => article.id, :inner_html => article.body, :count => 1, :profile_identifier => profile.identifier} })
    instance_eval(&content)
  end

  should 'not parse contents outside content viewer controller' do
    content = macro.parse({:paragraph_uuid => comment.paragraph_uuid}, article.body, article)
    controller.expects(:kind_of?).with(ContentViewerController).returns(false)
    assert_equal 'inner', instance_eval(&content)
  end

  should 'not parse contents if comment_paragraph is not activated' do
    article.expects(:comment_paragraph_plugin_activated?).returns(false)
    content = macro.parse({:paragraph_uuid => comment.paragraph_uuid}, article.body, article)
    controller.expects(:kind_of?).with(ContentViewerController).returns(true)
    assert_equal 'inner', instance_eval(&content)
  end

end
