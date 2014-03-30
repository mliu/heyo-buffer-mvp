class MovePageTokenToPosts < ActiveRecord::Migration
  def change
    remove_column :users, :page_token
    add_column :posts, :page_token, :string
  end
end
