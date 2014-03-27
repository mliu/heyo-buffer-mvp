require 'rufus-scheduler'

# Create singleton rufus scheduler
s = Rufus::Scheduler.singleton

s.every '30s' do
  User.all.each do |user|
    user.refresh_facebook_token
  end
end