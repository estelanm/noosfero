class AddManageEnvironmentCaptchaToAdminRole < ActiveRecord::Migration
  def self.up
    Environment.all.map(&:id).each do |id|
      role = Environment::Roles.admin(id)
      role.permissions << 'manage_environment_captcha'
      role.save!
    end
  end

  def self.down
    Environment.all.map(&:id).each do |id|
      role = Environment::Roles.admin(id)
      role.permissions -= ['manage_environment_captcha']
      role.save!
    end
  end
end
