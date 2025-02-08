class ConvertTaskDescriptionToRichText < ActiveRecord::Migration[8.0]
  include ActionView::Helpers::TextHelper

  def up
    rename_column :tasks, :description, :description_plain
    Task.all.each do |task|
      task.update_attribute(:description, simple_format(task.description_plain))
    end
    remove_column :tasks, :description_plain
  end

  def down
    add_column :tasks, :description_plain, :text
    Task.all.each do |task|
      task.update_attribute(:description_plain, task.description.to_plain_text)
      task.description.delete
    end
    rename_column :tasks, :description_plain, :description
    change_column_null :tasks, :description, false
  end
end
