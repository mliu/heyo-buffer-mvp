require 'rufus-scheduler'

# Create singleton rufus scheduler
s = Rufus::Scheduler.singleton

# s.every '1m' do
#   Post.where(posted: false).where("parse_time <= DATE(?)", Time.zone.now).each do |post|