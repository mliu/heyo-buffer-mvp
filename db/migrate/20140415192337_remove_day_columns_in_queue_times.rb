class RemoveDayColumnsInQueueTimes < ActiveRecord::Migration
  def change
    remove_column :queue_times, :mon, :boolean
    remove_column :queue_times, :tue, :boolean
    remove_column :queue_times, :wed, :boolean
    remove_column :queue_times, :thu, :boolean
    remove_column :queue_times, :fri, :boolean
    remove_column :queue_times, :sat, :boolean
    remove_column :queue_times, :sun, :boolean
  end
end
