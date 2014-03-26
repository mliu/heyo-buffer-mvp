class AddPageToUsers < ActiveRecord::Migration
  def change
    add_column :users, :page_token, :string
  end
end
