class CreateFooters < ActiveRecord::Migration[8.1]
  def change
    create_table :footers do |t|
      t.string :copyright, null: false, default: ""
      t.json :sitemap, null: false, default: {}
      t.timestamps

      # A single row, see `SingletonRecord`.
      t.check_constraint "id = 1", name: "footers_single_row"
      t.check_constraint "json_type(sitemap) = 'object'", name: "footers_sitemap_is_object"
    end
  end
end
