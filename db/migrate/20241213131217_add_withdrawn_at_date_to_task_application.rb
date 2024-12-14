class AddWithdrawnAtDateToTaskApplication < ActiveRecord::Migration[8.0]
  def change
    add_column :task_applications, :withdrawn_at, :datetime, default: nil
  end
end
