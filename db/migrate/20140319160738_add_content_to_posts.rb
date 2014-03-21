class AddContentToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :content, :string
    add_column :posts, :buffer_time, :datetime
  end
end
