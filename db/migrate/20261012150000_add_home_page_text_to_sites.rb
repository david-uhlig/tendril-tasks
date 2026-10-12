# The headline and introduction on the home page. Blank means the default text
# in the visitor's language.
class AddHomePageTextToSites < ActiveRecord::Migration[8.1]
  def change
    add_column :sites, :home_title, :string
    add_column :sites, :home_title_highlight, :string
    add_column :sites, :home_introduction, :text
  end
end
