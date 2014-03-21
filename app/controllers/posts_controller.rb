class PostsController < ApplicationController
  def new
    @post = Post.new
    @startDate = Time.current
  end

  def create
    @post = Post.new(post_params)

    if @post.save
      job = Rufus::Scheduler.singleton.schedule DateTime.strptime(@post.buffer_time, "%m/%d/%Y %H:%M:%S    %p").strftime("%Y-%m-%d %H-%M-%S %z")
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
