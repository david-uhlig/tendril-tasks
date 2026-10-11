require "rails_helper"
require Rails.root.join("db/migrate/20261011120100_copy_footer_settings_to_footers")

# Inserts the settings with SQL, like the migration reads them, since the
# `Setting` model is removed in a later version.
RSpec.describe CopyFooterSettingsToFooters do
  def insert_setting(key, json)
    ActiveRecord::Base.connection.exec_insert(
      "INSERT INTO settings (key, value, created_at, updated_at) VALUES (?, ?, ?, ?)",
      "Setting", [ key, json, Time.current, Time.current ]
    )
  end

  def settings
    ActiveRecord::Base.connection.select_rows("SELECT key, value FROM settings ORDER BY key")
  end

  def migrate
    ActiveRecord::Migration.suppress_messages { described_class.new.migrate(:up) }
  end

  let(:sitemap) { { "categories" => [ { "title" => "Community", "links" => [ { "title" => "Chat", "href" => "https://example.com" } ] } ] } }

  it "copies the copyright notice and the links" do
    insert_setting("footer_copyright", "© Example e.V.".to_json)
    insert_setting("footer_sitemap", sitemap.to_json)

    migrate

    expect(Footer.sole).to have_attributes(id: 1, copyright: "© Example e.V.", sitemap:)
  end

  it "uses the defaults for a missing setting" do
    insert_setting("footer_copyright", "© Example e.V.".to_json)

    migrate

    expect(Footer.sole).to have_attributes(copyright: "© Example e.V.", sitemap: {})
  end

  it "uses the defaults for settings of an unexpected type" do
    insert_setting("footer_copyright", { "unexpected" => true }.to_json)
    insert_setting("footer_sitemap", "unexpected".to_json)

    migrate

    expect(Footer.sole).to have_attributes(copyright: "", sitemap: {})
  end

  it "uses the defaults for settings that aren't JSON" do
    insert_setting("footer_copyright", "not JSON")
    insert_setting("footer_sitemap", "{")

    migrate

    expect(Footer.sole).to have_attributes(copyright: "", sitemap: {})
  end

  it "doesn't create a footer without footer settings" do
    insert_setting("brand_name", "Example".to_json)

    migrate

    expect(Footer.count).to eq(0)
  end

  it "keeps a footer that exists already, so it can run again" do
    insert_setting("footer_copyright", "© Old".to_json)
    Footer.create!(copyright: "© New")

    migrate

    expect(Footer.sole.copyright).to eq("© New")
  end

  it "leaves the settings untouched for the previous version" do
    insert_setting("footer_copyright", "© Example e.V.".to_json)
    insert_setting("footer_sitemap", sitemap.to_json)

    expect { migrate }.not_to change { settings }
  end
end
