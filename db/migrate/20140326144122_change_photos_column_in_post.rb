class ChangePhotosColumnInPost < ActiveRecord::Migration
  def change
    remove_column :posts, :photo
    add_attachment :posts, :photo
  end
end
