class AddForeignKeysToTaskApplicationsAndProjectCoordinators < ActiveRecord::Migration[8.1]
  def change
    add_foreign_key :project_coordinators, :projects, if_not_exists: true
    add_foreign_key :project_coordinators, :users, if_not_exists: true
    add_foreign_key :task_applications, :tasks, if_not_exists: true
    add_foreign_key :task_applications, :users, if_not_exists: true
  end
end
