# Copies the brand name and whether it's displayed from the `settings` table,
# which is dropped in 0.9.0, and moves the brand logo to the site.
#
# Uses SQL instead of the models, which change or are removed in later
# versions, so this also works when upgrading several versions at once. Leaves
# the settings untouched, so the previous version keeps working while a deploy
# switches over, apart from showing the default logo. Doesn't replace a site or
# a logo that exists already, so it can run again.
class CopyBrandSettingsToSites < ActiveRecord::Migration[8.1]
  def up
    return unless table_exists?(:settings)

    # Settings store their values as JSON, e.g. `"Acme"` for the brand name.
    # Whether the name is displayed is a JSON boolean, or a string from before
    # settings were typed, which is cast like a form's check box. Blank names
    # and values of an unexpected type fall back to the defaults.
    execute <<~SQL
      INSERT INTO sites (id, name, display_navigation_label, created_at, updated_at)
      SELECT 1,
             COALESCE((SELECT CASE WHEN NOT json_valid(value) THEN NULL
                                   WHEN json_type(value) <> 'text' THEN NULL
                                   WHEN trim(json_extract(value, '$')) = '' THEN NULL
                                   ELSE json_extract(value, '$')
                              END
                       FROM settings WHERE key = 'brand_name'), 'Tendril Tasks'),
             COALESCE((SELECT CASE WHEN NOT json_valid(value) THEN NULL
                                   WHEN json_type(value) = 'true' THEN 1
                                   WHEN json_type(value) = 'false' THEN 0
                                   WHEN json_type(value) <> 'text' THEN NULL
                                   WHEN json_extract(value, '$') = '' THEN NULL
                                   WHEN lower(json_extract(value, '$')) IN ('0', 'f', 'false', 'off') THEN 0
                                   ELSE 1
                              END
                       FROM settings WHERE key = 'display_brand_name'), 1),
             CURRENT_TIMESTAMP,
             CURRENT_TIMESTAMP
      WHERE EXISTS (SELECT 1 FROM settings WHERE key IN ('brand_name', 'display_brand_name', 'brand_logo'))
      ON CONFLICT (id) DO NOTHING
    SQL

    execute <<~SQL
      UPDATE active_storage_attachments
      SET record_type = 'Site', record_id = 1, name = 'logo'
      WHERE id = (SELECT max(id) FROM active_storage_attachments
                  WHERE record_type = 'Setting' AND name = 'attachment'
                    AND record_id = (SELECT id FROM settings WHERE key = 'brand_logo'))
        AND EXISTS (SELECT 1 FROM sites WHERE id = 1)
        AND NOT EXISTS (SELECT 1 FROM active_storage_attachments
                        WHERE record_type = 'Site' AND record_id = 1 AND name = 'logo')
    SQL
  end

  # Moves the logo back to the brand logo setting, creating it if the logo was
  # uploaded after the upgrade. Other changes made since are lost, as the
  # settings were left untouched.
  def down
    return unless table_exists?(:settings)
    return unless select_value("SELECT 1 FROM active_storage_attachments WHERE record_type = 'Site' AND record_id = 1 AND name = 'logo'")

    execute <<~SQL
      INSERT INTO settings (key, created_at, updated_at)
      SELECT 'brand_logo', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
      WHERE NOT EXISTS (SELECT 1 FROM settings WHERE key = 'brand_logo')
    SQL

    execute <<~SQL
      UPDATE active_storage_attachments
      SET record_type = 'Setting',
          record_id = (SELECT id FROM settings WHERE key = 'brand_logo'),
          name = 'attachment'
      WHERE record_type = 'Site' AND record_id = 1 AND name = 'logo'
    SQL
  end
end
