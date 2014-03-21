class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery

  before_filter :require_login
  around_filter :user_time_zone, :if => :current_user

  def user_time_zone(&block)
    Time.use_zone(current_user.time_zone, &block)
  end

  private
    def current_user
      @current_user ||= User.find(session[:user_id]) if session[:user_id]
    end

    def require_login
      unless current_user
        redirect_to root_url
      end
    end

    helper_method :current_user, :require_login
end
