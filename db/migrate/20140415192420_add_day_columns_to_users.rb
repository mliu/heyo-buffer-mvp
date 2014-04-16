class AddDayColumnsToUsers < ActiveRecord::Migration
  def change    
    add_column :users, :mon, :boolean, default: true
    add_column :users, :tue, :boolean, default: true
    add_column :users, :wed, :boolean, default: true
    add_column :users, :thu, :boolean, default: true
    add_column :users, :fri, :boolean, default: true
    add_column :users, :sat, :boolean, default: true
    add_column :users, :sun, :boolean, default: true
  end
end
