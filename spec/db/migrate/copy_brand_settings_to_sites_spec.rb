require "rails_helper"
require Rails.root.join("db/migrate/20261011140100_copy_brand_settings_to_sites")

# Inserts the settings with SQL, like the migration reads them, since the
# `Setting` model was removed.
RSpec.describe CopyBrandSettingsToSites do
  def insert_setting(key, json)
    ActiveRecord::Base.connection.exec_insert(
      "INSERT INTO settings (key, value, created_at, updated_at) VALUES (?, ?, ?, ?)",
      "Setting", [ key, json, Time.current, Time.current ]
    )
    ActiveRecord::Base.connection.select_value("SELECT id FROM settings WHERE key = #{ActiveRecord::Base.connection.quote(key)}")
  end

  def attach_logo_to_setting(setting_id)
    blob = ActiveStorage::Blob.create_and_upload!(io: StringIO.new("logo"), filename: "logo.png", content_type: "image/png")
    ActiveRecord::Base.connection.exec_insert(
      "INSERT INTO active_storage_attachments (name, record_type, record_id, blob_id, created_at) VALUES (?, ?, ?, ?, ?)",
      "Attachment", [ "attachment", "Setting", setting_id, blob.id, Time.current ]
    )
    blob
  end

  # Attaches a real image, as the site validates its logo's dimensions.
  def attach_logo_to_site(site)
    site.logo.attach(io: File.open(Rails.root.join("spec", "assets", "images", "for-tests.jpg")),
                     filename: "for-tests.jpg", content_type: "image/jpeg")
    site.logo.blob
  end

  def settings
    ActiveRecord::Base.connection.select_rows("SELECT key, value FROM settings ORDER BY key")
  end

  def migrate(direction = :up)
    ActiveRecord::Migration.suppress_messages { described_class.new.migrate(direction) }
  end

  it "copies the brand name and whether it's displayed" do
    insert_setting("brand_name", "Acme".to_json)
    insert_setting("display_brand_name", false.to_json)

    migrate

    expect(Site.sole).to have_attributes(id: 1, name: "Acme", display_navigation_label: false, navigation_label: "Acme")
  end

  it "uses the defaults for missing settings" do
    insert_setting("display_brand_name", false.to_json)

    migrate

    expect(Site.sole).to have_attributes(name: "Tendril Tasks", display_navigation_label: false)
  end

  it "uses the default name for a blank brand name" do
    insert_setting("brand_name", " ".to_json)

    migrate

    expect(Site.sole.name).to eq("Tendril Tasks")
  end

  it "uses the defaults for settings of an unexpected type or that aren't JSON" do
    insert_setting("brand_name", 42.to_json)
    insert_setting("display_brand_name", "{")

    migrate

    expect(Site.sole).to have_attributes(name: "Tendril Tasks", display_navigation_label: true)
  end

  {
    "false" => false, "0" => false, "off" => false, "F" => false,
    "true" => true, "1" => true, "yes" => true, "" => true
  }.each do |stored, displayed|
    it "casts a display setting stored as #{stored.inspect} to #{displayed}" do
      insert_setting("display_brand_name", stored.to_json)

      migrate

      expect(Site.sole.display_navigation_label).to be(displayed)
    end
  end

  it "moves the brand logo to the site" do
    blob = attach_logo_to_setting(insert_setting("brand_logo", nil))

    migrate

    expect(Site.sole.logo.blob).to eq(blob)
    expect(ActiveStorage::Attachment.where(record_type: "Setting")).to be_empty
  end

  it "doesn't create a site without brand settings" do
    insert_setting("footer_copyright", "© Example".to_json)

    migrate

    expect(Site.count).to eq(0)
  end

  it "keeps a site and a logo that exist already, so it can run again" do
    old_blob = attach_logo_to_setting(insert_setting("brand_logo", nil))
    insert_setting("brand_name", "Old".to_json)
    new_blob = attach_logo_to_site(Site.create!(name: "New"))

    migrate

    expect(Site.sole.name).to eq("New")
    expect(Site.sole.logo.blob).to eq(new_blob)
    expect(ActiveStorage::Attachment.find_by(record_type: "Setting").blob).to eq(old_blob)
  end

  it "leaves the settings untouched for the previous version" do
    insert_setting("brand_name", "Acme".to_json)
    insert_setting("display_brand_name", true.to_json)

    expect { migrate }.not_to change { settings }
  end

  describe "rolling back" do
    it "moves the logo back to the brand logo setting" do
      setting_id = insert_setting("brand_logo", nil)
      blob = attach_logo_to_setting(setting_id)
      migrate

      migrate(:down)

      attachment = ActiveStorage::Attachment.sole
      expect(attachment).to have_attributes(record_type: "Setting", record_id: setting_id, name: "attachment", blob:)
    end

    it "creates the brand logo setting for a logo uploaded after the upgrade" do
      insert_setting("brand_name", "Acme".to_json)
      migrate
      attach_logo_to_site(Site.sole)

      migrate(:down)

      setting_id = ActiveRecord::Base.connection.select_value("SELECT id FROM settings WHERE key = 'brand_logo'")
      expect(ActiveStorage::Attachment.sole).to have_attributes(record_type: "Setting", record_id: setting_id)
    end
  end
end
