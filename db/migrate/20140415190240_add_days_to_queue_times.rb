class AddDaysToQueueTimes < ActiveRecord::Migration
  def change
    add_column :queue_times, :mon, :boolean
    add_column :queue_times, :tue, :boolean
    add_column :queue_times, :wed, :boolean
    add_column :queue_times, :thu, :boolean
    add_column :queue_times, :fri, :boolean
    add_column :queue_times, :sat, :boolean
    add_column :queue_times, :sun, :boolean
  end
end
