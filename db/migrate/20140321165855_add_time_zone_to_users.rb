class AddTimeZoneToUsers < ActiveRecord::Migration
  def change
    add_column :users, :selected_a_time_zone, :boolean, default: false
    add_column :users, :time_zone, :string
  end
end
