class PostsController < ApplicationController
  def new
    @post = Post.new
    @startDate = Time.current
    Time.zone = current_user.time_zone
    @graph = Koala::Facebook::API.new(current_user.oauth_token)
  end

  def create
    @post = Post.new(post_params)
    @graph = Koala::Facebook::API.new(current_user.oauth_token)
    Time.zone = current_user.time_zone
    if @post.save
      logger.debug "Saved post with id #{@post.id}"
      logger.debug"#{DateTime.strptime(@post.buffer_time, "%m/%d/%Y %H:%M:%S    %p").strftime("%Y-%m-%d %H:%M:%S ") + (Time.zone.now.time_zone.utc_offset.to_s)}"
      job = Rufus::Scheduler.singleton.schedule_at DateTime.strptime(@post.buffer_time, "%m/%d/%Y %H:%M:%S    %p").strftime("%Y-%m-%d %H:%M:%S ") + (Time.zone.now.time_zone.utc_offset.to_s) do
        @graph.put_connections("me", "feed", message: @post.content)
        logger.debug("Posted #{@post.content} at #{@post.buffer_time}")
      end
      @post.update_attribute(:job_id, job.id)
      flash[:success] = "You've scheduled your post for #{@post.buffer_time}!"
      redirect_to profile_path
    else
      flash[:error] = "Unfortunately, there was an error scheduling your post."
      redirect_to profile_path
    end
  end

  def index
    @posts = Post.where(user_id: current_user.id)
  end

  private
    def post_params
      params.require(:post).permit(:content, :buffer_time)
    end
end
