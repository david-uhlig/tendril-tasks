class AddDescriptionPlainTextToTask < ActiveRecord::Migration[8.0]
  def change
    add_column :tasks, :description_plain_text, :text
    Task.all.each do |task|
      plain_text_description = task.send(:sanitize_plain_text, task.description&.body&.to_html)
      task.update_columns(description_plain_text: plain_text_description)
    end
  end
end
