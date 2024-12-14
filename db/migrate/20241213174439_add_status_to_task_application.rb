class AddStatusToTaskApplication < ActiveRecord::Migration[8.0]
  def change
    add_column :task_applications, :status, :integer, default: 0
  end
end
