class QueueTime < ActiveRecord::Base
  belongs_to :user

  def self.hours
    (1..12).collect{|i| "%02d" % i}
  end

  def self.minutes
    (0..59).collect{|i| "%02d" % i}
  end
end
