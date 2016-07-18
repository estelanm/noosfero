class OauthClientPlugin::Auth < ApplicationRecord

  attr_accessible :profile, :provider, :enabled,
    :access_token, :expires_in, :oauth_data

  belongs_to :profile, class_name: 'Profile'
  belongs_to :provider, class_name: 'OauthClientPlugin::Provider'

  validates_presence_of :profile
  validates_presence_of :provider
  validates_uniqueness_of :profile_id, scope: :provider_id

  extend ActsAsHavingSettings::ClassMethods
  acts_as_having_settings field: :data

  serialize :oauth_data, Hash

  def expires_in
    self.expires_at - Time.now
  end
  def expires_in= value
    self.expires_at = Time.now + value.to_i
  end

  def expired?
    Time.now > self.expires_at rescue true
  end
  def not_expired?
    not self.expired?
  end

end
