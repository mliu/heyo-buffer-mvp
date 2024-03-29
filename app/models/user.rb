class User < ActiveRecord::Base
  has_many :posts, class_name: "Post", foreign_key: "user_id"
  has_many :queue_times, class_name: "QueueTime", foreign_key: "user_id"
  accepts_nested_attributes_for :queue_times, reject_if: :all_blank, allow_destroy: true

  def self.from_omniauth(auth)
    newUser = where(auth.slice(:provider, :uid)).first_or_initialize.tap do |user|
      user.provider = auth.provider
      user.uid = auth.uid
      user.name = auth.info.name
      user.oauth_token = auth.credentials.token
      user.oauth_expires_at = Time.at(auth.credentials.expires_at) unless auth.credentials.expires_at.nil?
      user.save!
    end
    new_access_info = newUser.facebook_oauth.exchange_access_token_info newUser.oauth_token
    logger.debug "New access info: #{new_access_info}"
    new_access_token = new_access_info["access_token"]
    new_access_expires_at = DateTime.now + new_access_info["expires"].to_i.seconds
    newUser.update_attribute(:oauth_token, new_access_token)
    newUser.update_attribute(:oauth_expires_at, new_access_expires_at)
    return newUser
  end

  def update_queue_times
    week = ["mon", "tue", "wed", "thu", "fri", "sat", "sun"]
    arr = week.select {|day| self.send day}
    Post.where(queue: true).where(posted: false).order(:queue_order).each_with_index do |post, index|
      post.update_attribute(:parse_time, self.find_queue_time(week, arr, index + 1))
    end
  end

  def find_queue_time(week, arr, count)
    Time.zone = self.time_zone
    # Get array of queue times for user
    qt = self.queue_times.to_ary
    # Get specific queue time of post
    qt_time = qt[qt.length % count]
    # Get day of post
    adjustedDay = Time.zone.now + (((count / qt.length).floor) * 86400)
    adjustedDate = Date.commercial(Date.today.in_time_zone.year, Date.today.in_time_zone.to_date.cweek, week.index(adjustedDay.strftime("%a").downcase) + 1)
    time = adjustedDate.to_time
    # Get hour
    if qt_time.ampm == "PM"
      hour = (qt_time.hour.to_i + 12) % 24
    end
    time.change(hour: hour, min: qt_time.minute)
    return time
  end

  # def self.deauth(auth)
  #   user = where(:uid, Koala::Facebook::OAuth.new("213640202163880", "07a19ab760466d7eb0eebd3950bcb39f").parse_signed_request(auth))
    
  # end

  def refresh_facebook_token
    if facebook_token_expired?
      # Get the new token
      logger.debug "Exchanging token"
      new_token = facebook_oauth.exchange_access_token_info(self.oauth_token)
      logger.debug "Refreshed token info: #{new_token}"
      logger.debug "#{new_token['expires']}"
      Time.zone = self.time_zone
      # Save the new token and its expiry over the old one
      self.update_attribute(:oauth_token, new_token['access_token']);
      self.update_attribute(:oauth_expires_at, Time.zone.now + new_token['expires'].to_i.seconds)
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