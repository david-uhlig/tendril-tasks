class AddDescriptionPlainTextToProject < ActiveRecord::Migration[8.0]
  def change
    add_column :projects, :description_plain_text, :text
    Project.all.each do |project|
      plain_text_description = project.send(:sanitize_plain_text, project.description&.body&.to_html)
      project.update_columns(description_plain_text: plain_text_description)
    end
  end
end
