class UsersController < ApplicationController
  # def deauth
  #   User.deauth(env['signed_request'])
  # end

  def edit
    @user = current_user
  end

  def update
    @user = current_user
    @params = user_params[:queue_times_attributes]
    if @user.update(user_params)
      logger.debug "User update fine"
      logger.debug "#{@params}"
      if @user.queue_times.count == 0
        logger.debug "Creating automatic queuetime"
        queuetime = QueueTime.new(user_id: user.id, hour: "12", minute: "00", ampm: "PM")
        flash[:error] = "You must have at least one queue time"
        queuetime.save!
      end
      flash[:success] = "You've updated your profile!"
      redirect_to settings_path
    else
      flash[:error] = "There were errors updating your profile."
      redirect_to settings_path
    end
  end

    private
    def user_params
      params.require(:user).permit(:id, :time_zone, :mon, :tue, :wed, :thu, :fri, :sat, :sun, queue_times_attributes: [:id, :hour, :minute, :ampm, :_destroy])
    end
end
