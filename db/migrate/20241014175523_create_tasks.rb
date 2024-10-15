class CreateTasks < ActiveRecord::Migration[8.0]
  def change
    create_table :tasks do |t|
      t.string :title, null: false
      t.text :description, null: false
      t.datetime :published_at, default: nil

      t.timestamps

      t.index :published_at
    end
  end
end
