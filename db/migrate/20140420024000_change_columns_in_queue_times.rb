class ChangeColumnsInQueueTimes < ActiveRecord::Migration
  def change
    remove_column :queue_times, :post_id
    add_column :posts, :queue_order, :integer
  end
end
