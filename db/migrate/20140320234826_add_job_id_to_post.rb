class AddJobIdToPost < ActiveRecord::Migration
  def change
    add_column :posts, :job_id, :string
  end
end
