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
      if @params.present?
        @params.values.each do |qt|
          logger.debug "Values found for QT #{qt[:time]}"
        end
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
