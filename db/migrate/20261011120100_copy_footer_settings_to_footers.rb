# Copies the footer's copyright notice and links from the `settings` table,
# which is dropped in 0.9.0.
#
# Uses SQL instead of the models, which change or are removed in later
# versions, so this also works when upgrading several versions at once. Leaves
# the settings untouched, so the previous version keeps working while a deploy
# switches over, and doesn't replace a footer that exists already, so it can
# run again.
class CopyFooterSettingsToFooters < ActiveRecord::Migration[8.1]
  def up
    return unless table_exists?(:settings)

    # Settings store their values as JSON, e.g. `"© Example"` for the
    # copyright notice. Values of an unexpected type fall back to the defaults.
    execute <<~SQL
      INSERT INTO footers (id, copyright, sitemap, created_at, updated_at)
      SELECT 1,
             COALESCE((SELECT CASE WHEN NOT json_valid(value) THEN NULL
                                   WHEN json_type(value) = 'text' THEN json_extract(value, '$')
                              END
                       FROM settings WHERE key = 'footer_copyright'), ''),
             COALESCE((SELECT CASE WHEN NOT json_valid(value) THEN NULL
                                   WHEN json_type(value) = 'object' THEN json(value)
                              END
                       FROM settings WHERE key = 'footer_sitemap'), '{}'),
             CURRENT_TIMESTAMP,
             CURRENT_TIMESTAMP
      WHERE EXISTS (SELECT 1 FROM settings WHERE key IN ('footer_copyright', 'footer_sitemap'))
      ON CONFLICT (id) DO NOTHING
    SQL
  end

  def down
    # The settings were left untouched, and reverting `CreateFooters` drops
    # the copy.
  end
end
