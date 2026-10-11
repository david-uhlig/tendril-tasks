class CreateSites < ActiveRecord::Migration[8.1]
  def change
    create_table :sites do |t|
      t.string :name, null: false, default: "Tendril Tasks"
      t.string :tagline
      t.string :navigation_label
      t.boolean :display_navigation_label, null: false, default: true
      t.timestamps

      # A single row, see `SingletonRecord`.
      t.check_constraint "id = 1", name: "sites_single_row"
    end
  end
end
