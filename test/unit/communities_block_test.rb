require File.dirname(__FILE__) + '/../test_helper'

class CommunitiesBlockTest < ActiveSupport::TestCase

  should 'inherit from ProfileListBlock' do
    assert_kind_of ProfileListBlock, CommunitiesBlock.new
  end

  should 'declare its default title' do
    CommunitiesBlock.any_instance.stubs(:profile_count).returns(0)
    assert_not_equal ProfileListBlock.new.default_title, CommunitiesBlock.new.default_title
  end

  should 'describe itself' do
    assert_not_equal ProfileListBlock.description, CommunitiesBlock.description
  end

  should 'use its own finder' do
    assert_not_equal CommunitiesBlock::Finder, ProfileListBlock::Finder
    assert_kind_of CommunitiesBlock::Finder, CommunitiesBlock.new.profile_finder
  end

  should 'list owner communities' do

    block = CommunitiesBlock.new
    block.limit = 2

    owner = mock
    block.expects(:owner).at_least_once.returns(owner)

    community1 = mock; community1.stubs(:id).returns(1); community1.stubs(:visible).returns(true)
    community2 = mock; community2.stubs(:id).returns(2); community2.stubs(:visible).returns(true)
    community3 = mock; community3.stubs(:id).returns(3); community3.stubs(:visible).returns(true)

    owner.expects(:communities).returns([community1, community2, community3])
    
    block.profile_finder.expects(:pick_random).with(3).returns(2)
    block.profile_finder.expects(:pick_random).with(2).returns(0)

    Profile.expects(:find).with(3).returns(community3)
    Profile.expects(:find).with(1).returns(community1)

    assert_equal [community3, community1], block.profiles
  end

  should 'link to all communities of profile' do
    profile = Profile.new
    profile.expects(:identifier).returns("theprofile")

    block = CommunitiesBlock.new
    block.expects(:owner).returns(profile)

    expects(:link_to).with('View all', :controller => 'profile', :profile => 'theprofile', :action => 'communities')
    instance_eval(&block.footer)
  end

  should 'support environment as owner' do
    env = Environment.default
    block = CommunitiesBlock.new
    block.expects(:owner).returns(env)

    expects(:link_to).with('View all', :controller => 'search', :action => 'assets', :asset => 'communities')

    instance_eval(&block.footer)
  end

  should 'give empty footer on unsupported owner type' do
    block = CommunitiesBlock.new
    block.expects(:owner).returns(1)
    assert_equal '', block.footer
  end

  should 'list non-public communities' do
    user = create_user('testuser').person

    public_community = fast_create(Community, :environment_id => Environment.default.id)
    public_community.add_member(user)

    private_community = fast_create(Community, :environment_id => Environment.default.id, :public_profile => false)
    private_community.add_member(user)

    block = CommunitiesBlock.new
    block.expects(:owner).at_least_once.returns(user)

    assert_equivalent [public_community, private_community], block.profiles
  end

  should 'not list non-visible communities' do
    user = create_user('testuser').person

    visible_community = fast_create(Community, :environment_id => Environment.default.id)
    visible_community.add_member(user)

    not_visible_community = fast_create(Community, :environment_id => Environment.default.id, :visible => false)
    not_visible_community.add_member(user)

    block = CommunitiesBlock.new
    block.expects(:owner).at_least_once.returns(user)

    assert_equal [visible_community], block.profiles
  end

  should 'count number of owner communities' do
    user = create_user('testuser').person

    community1 = fast_create(Community, :environment_id => Environment.default.id, :visible => true)
    community1.add_member(user)

    community2 = fast_create(Community, :environment_id => Environment.default.id, :visible => true)
    community2.add_member(user)

    block = CommunitiesBlock.new
    block.expects(:owner).at_least_once.returns(user)

    assert_equal 2, block.profile_count
  end

  should 'count non-public profile communities' do
    user = create_user('testuser').person

    community_public = fast_create(Community, :environment_id => Environment.default.id, :public_profile => true)
    community_public.add_member(user)

    community_private = fast_create(Community, :public_profile => false)
    community_private.add_member(user)

    block = CommunitiesBlock.new
    block.expects(:owner).at_least_once.returns(user)

    assert_equal 2, block.profile_count
  end

  should 'not count non-visible profile communities' do
    user = create_user('testuser').person

    visible_community = fast_create(Community, :name => 'tcommunity 1', :identifier => 'comm1', :visible => true)
    visible_community.add_member(user)

    not_visible_community = fast_create(Community, :name => ' community 2', :identifier => 'comm2', :visible => false)
    not_visible_community.add_member(user)

    block = CommunitiesBlock.new
    block.expects(:owner).at_least_once.returns(user)

    assert_equal 1, block.profile_count
  end

  should 'count non-public environment communities' do
    community_public = fast_create(Community, :name => 'tcommunity 1', :identifier => 'comm1', :public_profile => true)

    community_private = fast_create(Community, :name => ' community 2', :identifier => 'comm2', :public_profile => false)

    block = CommunitiesBlock.new
    block.expects(:owner).at_least_once.returns(Environment.default)

    assert_equal 2, block.profile_count
  end

  should 'not count non-visible environment communities' do
    visible_community = fast_create(Community, :name => 'tcommunity 1', :identifier => 'comm1', :visible => true)

    not_visible_community = fast_create(Community, :name => ' community 2', :identifier => 'comm2', :visible => false)

    block = CommunitiesBlock.new
    block.expects(:owner).at_least_once.returns(Environment.default)

    assert_equal 1, block.profile_count
  end

end
