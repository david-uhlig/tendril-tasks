class CreateProjectCoordinators < ActiveRecord::Migration[8.0]
  def change
    create_table :project_coordinators, primary_key: [ :project_id, :user_id ] do |t|
      t.references :project, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
    end
  end
end
