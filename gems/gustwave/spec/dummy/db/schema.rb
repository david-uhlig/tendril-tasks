# frozen_string_literal: true

ActiveRecord::Schema.define do
  create_table :action_text_rich_texts, force: true do |t|
    t.string :name, null: false
    t.text :body
    t.references :record, null: false, polymorphic: true, index: false
    t.timestamps
  end
end
