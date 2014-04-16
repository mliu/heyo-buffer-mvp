class ChangeDayColumnInQueueTimes < ActiveRecord::Migration
  def change
    change_column :queue_times, :mon, :boolean, default: true
    change_column :queue_times, :tue, :boolean, default: true
    change_column :queue_times, :wed, :boolean, default: true
    change_column :queue_times, :thu, :boolean, default: true
    change_column :queue_times, :fri, :boolean, default: true
    change_column :queue_times, :sat, :boolean, default: true
    change_column :queue_times, :sun, :boolean, default: true
  end
end
