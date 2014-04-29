class AddDefaultToPosted < ActiveRecord::Migration
  def change
    change_column :posts, :posted, :boolean, default: false
  end
end
