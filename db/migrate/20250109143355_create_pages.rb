class CreatePages < ActiveRecord::Migration[8.0]
  def change
    create_table :pages do |t|
      t.string :slug, index: true

      t.timestamps
    end
  end
end
