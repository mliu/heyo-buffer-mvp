class ChangeHoursAndMinutesInQueueTime < ActiveRecord::Migration
  def change
    remove_column :queue_times, :time
    add_column :queue_times, :hour, :string
    add_column :queue_times, :minute, :string
    add_column :queue_times, :ampm, :string
  end
end
