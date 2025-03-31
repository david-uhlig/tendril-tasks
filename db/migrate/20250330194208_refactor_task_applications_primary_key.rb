class RefactorTaskApplicationsPrimaryKey < ActiveRecord::Migration[8.0]
  def up
    create_table :task_applications_new do |t|
      t.integer :task_id, null: false
      t.integer :user_id, null: false
      t.text :comment
      t.integer :status, default: 0
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
      t.datetime :withdrawn_at
    end

    add_index :task_applications_new, [ :task_id, :user_id ], unique: true
    add_index :task_applications_new, :task_id
    add_index :task_applications_new, :user_id

    execute <<~SQL
      INSERT INTO task_applications_new
      (task_id, user_id, comment, created_at, updated_at, withdrawn_at, status)
      SELECT task_id, user_id, comment, created_at, updated_at, withdrawn_at, status
      FROM task_applications;
    SQL

    drop_table :task_applications
    rename_table :task_applications_new, :task_applications
  end

  def down
    create_table :task_applications_old, primary_key: [ :task_id, :user_id ] do |t|
      t.integer :task_id, null: false
      t.integer :user_id, null: false
      t.text :comment
      t.integer :status, default: 0
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
      t.datetime :withdrawn_at
    end

    add_index :task_applications_old, :task_id
    add_index :task_applications_old, :user_id

    execute <<~SQL
      INSERT INTO task_applications_old
      (task_id, user_id, comment, created_at, updated_at, withdrawn_at, status)
      SELECT task_id, user_id, comment, created_at, updated_at, withdrawn_at, status
      FROM task_applications;
    SQL

    drop_table :task_applications
    rename_table :task_applications_old, :task_applications
  end
end
