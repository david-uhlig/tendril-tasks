class AddNameUsernameAvatarUrlToUser < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :name, :string, null: false, default: ""
    add_column :users, :username, :string, null: false, default: ""
    add_column :users, :avatar_url, :string, null: false, default: ""
  end
end
