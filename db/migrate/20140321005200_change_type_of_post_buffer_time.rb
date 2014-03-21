class ChangeTypeOfPostBufferTime < ActiveRecord::Migration
  def change
    change_column :posts, :buffer_time, :string
  end
end
