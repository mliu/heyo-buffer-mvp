class ParseTime < ActiveRecord::Migration
  def change
    add_column :posts, :parse_time, :datetime
  end
end
