class EnterprisesBlock < ProfileListBlock

  def default_title
    n__('{#} enterprise', '{#} enterprises', profile_count)
  end

  def help
    __('This block displays the enterprises where this user works.')
  end

  def self.description
    __('Enterprises')
  end

  def footer
    owner = self.owner
    case owner
    when Profile
      lambda do
        link_to s_('enterprises|View all'), :profile => owner.identifier, :controller => 'profile', :action => 'enterprises'
      end
    when Environment
      lambda do
        link_to s_('enterprises|View all'), :controller => 'search', :action => 'assets', :asset => 'enterprises'
      end
    else
      ''
    end
  end

  def profile_count
    if owner.kind_of?(Environment)
      owner.enterprises.count(:conditions => { :visible => true })
    else
      owner.enterprises(:visible => true).count
    end

  end

  def profile_finder
    @profile_finder ||= EnterprisesBlock::Finder.new(self)
  end

  class Finder < ProfileListBlock::Finder
    def ids
      # FIXME when owner is an environment (i.e. listing enterprises globally
      # this can become SLOW)
      if block.owner.kind_of?(Environment)
        block.owner.enterprises.all(:conditions => {:visible => true}, :limit => block.limit, :order => Noosfero::SQL.random_function).map(&:id)
      else
        block.owner.enterprises.select(&:visible).map(&:id)
      end
    end
  end

end
