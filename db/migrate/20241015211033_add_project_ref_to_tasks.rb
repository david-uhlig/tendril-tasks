class AddProjectRefToTasks < ActiveRecord::Migration[8.0]
  def change
    add_reference :tasks, :project, null: false, foreign_key: true, index: true
  end
end
