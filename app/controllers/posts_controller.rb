class PostsController < ApplicationController
  load_and_authorize_resource
  def new
    @post = Post.new
    Time.zone = current_user.time_zone
    @startDate = Time.current
    @graph = Koala::Facebook::API.new(@current_user.oauth_token)
    @page_names = []
    @page_names.push(["Post to newsfeed", 0])
    @pages = @graph.get_connections('me', 'accounts').each_with_index do |p, index|
      @page_names.push([p['name'], index + 1])
    end
  end

  def create
    @post = Post.new(post_params)
    @user = current_user
    @graph = Koala::Facebook::API.new(@current_user.oauth_token)
    Time.zone = current_user.time_zone
    if(post_params[:page_token].to_i == 0)
      if @post.save
        @post.update_attribute(:user_id, current_user.id)
        @post.update_attribute(:page_name, "your newsfeed")
        logger.debug "Saved post with id #{@post.id}"
        logger.debug "#{@post.parse_time}"
        job = Rufus::Scheduler.singleton.schedule_at @post.read_attribute(:parse_time).to_s do
          @graph = Koala::Facebook::API.new(@user.oauth_token)
          if(post_params[:photo] != "")
            @graph.put_picture(@post.photo, {message: @post.content}, "me")
          else
            @graph.put_connections("me", "feed", message: @post.content)
          end
          logger.debug("Posted #{@post.content} at #{@post.buffer_time} buffer time > #{@post.parse_time}")
        end
        @post.update_attribute(:job_id, job.id)
        flash[:success] = "You've scheduled a post on your newsfeed for #{@post.buffer_time}!"
        redirect_to profile_path
      else
        flash[:error] = "Unfortunately, there was an error scheduling your post."
        redirect_to profile_path
      end
    else
      @page = @graph.get_connections('me', 'accounts')[post_params[:page_token].to_i - 1]
      @page_token = @page["access_token"]
      @page_name = @page["name"]
      logger.debug "Pages: #{@page_token}"
      if @post.save
        @post.update_attribute(:user_id, current_user.id)
        @post.update_attribute(:page_name, @page_name)
        logger.debug "Saved post with id #{@post.id}"
        logger.debug "#{@post.parse_time}"
        job = Rufus::Scheduler.singleton.schedule_at @post.read_attribute(:parse_time).to_s do
          @graph = Koala::Facebook::API.new(@page_token)
          if(post_params[:photo] != "")
            @graph.put_picture(@post.photo, {message: @post.content}, "me")
          else
            @graph.put_wall_post(@post.content)
          end
          logger.debug("Posted #{@post.content} at #{@post.buffer_time} buffer time > #{@post.parse_time}")
        end
        @post.update_attribute(:job_id, job.id)
        flash[:success] = "You've scheduled your post for #{@post.page_name} at #{@post.buffer_time}!"
        redirect_to profile_path
      else
        flash[:error] = "Unfortunately, there was an error scheduling your post."
        redirect_to profile_path
      end
    end
  end

  def edit
    @post = Post.find(params[:id])
    Time.zone = current_user.time_zone
    @startDate = Time.current
    @graph = Koala::Facebook::API.new(@current_user.oauth_token)
    @page_names = []
    @page_names.push(["Post to newsfeed", 0])
    @pages = @graph.get_connections('me', 'accounts').each_with_index do |p, index|
      @page_names.push([p['name'], index + 1])
    end
  end

  def update
    @post = Post.find(params[:id])
    @user = current_user
    Time.zone = current_user.time_zone
    @graph = Koala::Facebook::API.new(@current_user.oauth_token)
    if Rufus::Scheduler.singleton.job(@post.read_attribute(:job_id)).nil?
      logger.debug "Nil Job"
      flash[:error] = "This post can no longer be edited!"
      redirect_to posts_path
      return
    end
    if(post_params[:page_token].to_i == 0)
      if @post.update(post_params)
        @post.update_attribute(:page_name, "your newsfeed")
        logger.debug "Updated post with id #{@post.id}"
        logger.debug "#{@post.parse_time}"
        Rufus::Scheduler.singleton.job(@post.read_attribute(:job_id)).unschedule
        job = Rufus::Scheduler.singleton.schedule_at @post.read_attribute(:parse_time).to_s do
          @graph = Koala::Facebook::API.new(@user.oauth_token)
          @graph.put_connections("me", "feed", message: @post.content)
          logger.debug("Posted #{@post.content} at #{@post.buffer_time}")
        end
        @post.update_attribute(:job_id, job.id)
        flash[:success] = "You've updated for post for your newsfeed at #{@post.buffer_time}!"
        redirect_to posts_path
      else
        flash[:error] = "Unfortunately, there was an error updating your post."
        redirect_to edit_post_path(params[:id])
      end
    else
      if @post.update(post_params)
        @page = @graph.get_connections('me', 'accounts')[post_params[:page_token].to_i - 1]
        @page_token = @page["access_token"]
        @page_name = @page["name"]
        @post.update_attribute(:page_name, @page_name)
        logger.debug "Pages: #{@page_token}"
        logger.debug "Updated post with id #{@post.id}"
        logger.debug "#{@post.parse_time}"
        Rufus::Scheduler.singleton.job(@post.read_attribute(:job_id)).unschedule
        job = Rufus::Scheduler.singleton.schedule_at @post.read_attribute(:parse_time).to_s do
          @graph = Koala::Facebook::API.new(@page_token)
          @graph.put_wall_post(@post.content)
          logger.debug("Posted #{@post.content} at #{@post.buffer_time} buffer time > #{@post.parse_time}")
        end
        @post.update_attribute(:job_id, job.id)
        flash[:success] = "You've updated for post for #{@post.page_name} at #{@post.buffer_time}!"
        redirect_to posts_path
      else
        flash[:error] = "Unfortunately, there was an error updating your post."
        redirect_to edit_post_path(params[:id])
      end
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

  def past
    Time.zone = current_user.time_zone
    @startDate = Time.current
    @posts_past = Post.posting_past.where(user_id: current_user.id).order(:parse_time)
  end

  def destroy
    @post = Post.find(params[:id])
    @post.destroy
    flash[:success] = "Post deleted!"
    redirect_to posts_path
  end

  private
    def post_params
      params.require(:post).permit(:content, :buffer_time, :parse_time, :photo, :page_token)
    end
end
