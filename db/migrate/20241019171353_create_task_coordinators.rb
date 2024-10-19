class CreateTaskCoordinators < ActiveRecord::Migration[8.0]
  def change
    create_table :task_coordinators, primary_key: [ :task_id, :user_id ] do |t|
      t.references :task, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
    end
  end
end
