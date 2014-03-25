class User < ActiveRecord::Base
  has_many :posts, class_name: "Post", foreign_key: "user_id"

  def self.from_omniauth(auth)
    newUser = where(auth.slice(:provider, :uid)).first_or_initialize.tap do |user|
      user.provider = auth.provider
      user.uid = auth.uid
      user.name = auth.info.name
      user.oauth_token = auth.credentials.token
      user.oauth_expires_at = Time.at(auth.credentials.expires_at)
      user.save!
    end

    new_access_info = newUser.facebook_oauth.exchange_access_token_info auth.credentials.token
    
    new_access_token = new_access_info["access_token"]
    new_access_expires_at = DateTime.now + new_access_info["expires"].to_i.seconds
    newUser.update_attribute(:oauth_token, new_access_token)
    newUser.update_attribute(:oauth_expires_at, new_access_expires_at)
    return newUser
  end

  # def self.deauth(auth)
  #   user = where(:uid, Koala::Facebook::OAuth.new("213640202163880", "07a19ab760466d7eb0eebd3950bcb39f").parse_signed_request(auth))
    
  # end

  def refresh_facebook_token
    if facebook_token_expired?
      # Get the new token
      logger.debug "Exchanging token"
      new_token = facebook_oauth.exchange_access_token_info self.oauth_token
      Time.zone = self.time_zone
      # Save the new token and its expiry over the old one
      self.update_attribute(:oauth_token, new_token['access_token']);
      self.update_attribute(:oauth_expires_at, Time.zone.now + new_token['expires'].to_i)
      save
    end
  end

  def facebook_token_expired?
    logger.debug "Checking expiration"
    Time.zone = self.time_zone
    # time_check = Time.zone.now + 172800
    time_check = Time.zone.now + 3600
    return time_check > self.oauth_expires_at
  end

  def facebook_oauth
    @facebook_oauth ||= Koala::Facebook::OAuth.new("213640202163880", "07a19ab760466d7eb0eebd3950bcb39f")
  end
end