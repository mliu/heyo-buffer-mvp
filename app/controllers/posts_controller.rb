class PostsController < ApplicationController
  def new
    @post = Post.new
    Time.zone = current_user.time_zone
    @startDate = Time.current
  end

  def create
    @post = Post.new(post_params)
    @user = current_user
    Time.zone = current_user.time_zone
    if @post.save
      @post.update_attribute(:user_id, current_user.id)
      @post.update_attribute(:parse_time, DateTime.strptime(@post.buffer_time, "%m/%d/%Y %H:%M:%S %p"))
      logger.debug "Saved post with id #{@post.id}"
      logger.debug "#{@post.parse_time}"
      job = Rufus::Scheduler.singleton.schedule_at @post.read_attribute(:parse_time).to_s do
        @graph = Koala::Facebook::API.new(@user.oauth_token)
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

  def edit
    @post = Post.find(params[:id])
    Time.zone = current_user.time_zone
    @startDate = Time.current
  end

  def update
    @post = Post.find(params[:id])
    @user = current_user
    Time.zone = current_user.time_zone
    if Rufus::Scheduler.singleton.job(@post.read_attribute(:job_id)).nil?
      flash[:error] = "This post can no longer be edited!"
      redirect_to posts_path
    end
    if @post.update(post_params)
      @post.update_attribute(:parse_time, DateTime.strptime(@post.buffer_time, "%m/%d/%Y %H:%M:%S %p"))
      logger.debug "Updated post with id #{@post.id}"
      logger.debug "#{@post.parse_time}"
      Rufus::Scheduler.singleton.job(@post.read_attribute(:job_id)).unschedule
      job = Rufus::Scheduler.singleton.schedule_at @post.read_attribute(:parse_time).to_s do
        @graph = Koala::Facebook::API.new(@user.oauth_token)
        @graph.put_connections("me", "feed", message: @post.content)
        logger.debug("Posted #{@post.content} at #{@post.buffer_time}")
      end
      @post.update_attribute(:job_id, job.id)
      flash[:success] = "You've updated for post for #{@post.buffer_time}!"
      redirect_to posts_path
    else
      flash[:error] = "Unfortunately, there was an error updating your post."
      redirect_to edit_post_path(params[:id])
    end
  end

  def index
    Time.zone = current_user.time_zone
    @startDate = Time.current
    @posts_past = Post.posting_past.where(user_id: current_user.id).order(:parse_time)
    @posts_today = Post.posting_today.where(user_id: current_user.id).order(:parse_time)
    @posts_tomorrow = Post.posting_tomorrow.where(user_id: current_user.id).order(:parse_time)
    @posts_future = Post.posting_future.where(user_id: current_user.id).order(:parse_time)
  end

  private
    def post_params
      params.require(:post).permit(:content, :buffer_time)
    end
end
