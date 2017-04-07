class EnvironmentDesignController < BoxOrganizerController

  protect 'edit_environment_design', :environment

  def filtered_available_blocks(blocks=nil)
    filtered_available_blocks = []
    blocks.each { |block| filtered_available_blocks << block unless @environment.disabled_blocks.include?(block.name) }
    filtered_available_blocks
  end

  def available_blocks
    @available_blocks ||= [ ArticleBlock, LoginBlock, RecentDocumentsBlock, EnterprisesBlock, CommunitiesBlock, LinkListBlock, FeedReaderBlock, SlideshowBlock, HighlightsBlock, CategoriesBlock, RawHTMLBlock, TagsCloudBlock ]
    @available_blocks += plugins.dispatch(:extra_blocks, :type => Environment)
  end

  def index
    available_blocks
  end

end
