class AddPageNameToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :page_name, :string
  end
end
