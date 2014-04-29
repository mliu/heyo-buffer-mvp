class AddPostIdToQueueTime < ActiveRecord::Migration
  def change
    add_column :queue_times, :post_id, :integer
    add_column :posts, :queue, :boolean
    add_column :posts, :posted, :boolean
  end
end
