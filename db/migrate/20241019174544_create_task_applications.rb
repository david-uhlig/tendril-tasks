class CreateTaskApplications < ActiveRecord::Migration[8.0]
  def change
    create_table :task_applications, primary_key: [ :task_id, :user_id ] do |t|
      t.references :task, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.text :comment

      t.timestamps
    end
  end
end
