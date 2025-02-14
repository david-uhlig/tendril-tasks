class ConvertProjectDescriptionToRichText < ActiveRecord::Migration[8.0]
  include ActionView::Helpers::TextHelper

  def up
    rename_column :projects, :description, :description_plain
    Project.all.each do |project|
      project.update_attribute(:description, simple_format(project.description_plain))
    end
    remove_column :projects, :description_plain
  end

  def down
    add_column :projects, :description_plain, :text
    Project.all.each do |project|
      project.update_attribute(:description_plain, project.description.to_plain_text)
      project.description.delete
    end
    rename_column :projects, :description_plain, :description
    change_column_null :projects, :description, false
  end
end
