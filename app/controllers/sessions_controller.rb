class SessionsController < ApplicationController
  skip_before_filter :require_login, only: [:index, :create]

  def index
    if current_user
      redirect_to profile_path
    end
  end

  def create
    user = User.from_omniauth(env["omniauth.auth"])
    puts(env["omniauth.auth"])
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
