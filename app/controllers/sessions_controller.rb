class SessionsController < ApplicationController
  skip_before_filter :require_login, only: [:index, :create]

  def index
    if current_user
      redirect_to profile_path
    end
  end

  def create
    user = User.from_omniauth(env["omniauth.auth"])
    if !user.read_attribute(:selected_a_time_zone)
      user.update_attribute(:time_zone, cookies["jstz_time_zone"])
      user.update_attribute(:selected_a_time_zone, true)
    end
    if user.queue_times.count == 0
      logger.debug "Creating automatic queuetime"
      queuetime = QueueTime.new(user_id: user.id, hour: "12", minute: "00", ampm: "PM")
      queuetime.save!
    end
    logger.debug env["omniauth.auth"]
    session[:user_id] = user.id
    flash[:success] = "You have logged in!"
    redirect_to profile_path
  end

  def show
  end

  def destroy
    session[:user_id] = nil
    flash[:success] = "See you later!"
    redirect_to root_url
  end
end
