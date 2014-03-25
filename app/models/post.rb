class Post < ActiveRecord::Base
  belongs_to :user

  def self.posting_past
    where("DATE(parse_time) < DATE(?)", Date.today)
  end

  def self.posting_today
    where("DATE(parse_time) = DATE(?)", Date.today)
  end

  def self.posting_tomorrow
    where("DATE(parse_time) = DATE(?)", Date.tomorrow)
  end

  def self.posting_future
    where("DATE(parse_time) > DATE(?)", Date.tomorrow)
  end
end
