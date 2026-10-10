require 'rails_helper'

RSpec.describe Setting, type: :model do
  let(:setting) { create(:setting) }

  def attach_image
    setting.attachment.attach(io: File.open(Rails.root.join('spec', 'assets', 'images', 'for-tests.jpg')), filename: 'for-tests.jpg', content_type: 'image/jpg')
  end

  describe "with valid attributes" do
    it "is valid with default values" do
      expect(setting).to be_valid
    end

    it "is valid with a string value" do
      setting.value = "value"
      expect(setting).to be_valid
    end

    it "is valid with a hash value" do
      setting.value = { foo: "bar" }
      expect(setting).to be_valid
    end

    it "is valid with one attachment" do
      attach_image
      expect(setting).to be_valid
    end

    it "is valid with multiple attachments" do
      attach_image
      attach_image
      expect(setting).to be_valid
    end

    it "is valid with a value and an attachment" do
      setting.value = "value"
      attach_image
      expect(setting).to be_valid
    end
  end

  describe "with invalid attributes" do
    it "is invalid without a key" do
      setting.key = nil
      expect(setting).not_to be_valid
    end

    it "is invalid with a duplicate key" do
      duplicate_setting = build(:setting, key: setting.key)
      expect(duplicate_setting).not_to be_valid
    end
  end

  context ".remove" do
    it "removes the setting" do
      setting
      expect { Setting.remove(setting.key) }.to change(Setting, :count).by(-1)
    end
  end

  context ".to_h" do
    it "returns a hash of all settings" do
      setting
      expect(Setting.to_h).to eq({ setting.key => setting.value })
    end
  end

  describe "sitemap" do
    let(:sitemap) { { "categories" =>
                        [ { "title" => "Gehe zu", "links" => [ { "title" => "Start", "href" => "/" }, { "title" => "Themen", "href" => "/projects" }, { "title" => "Aufgaben", "href" => "/tasks" } ] },
                          { "title" => "Example Apps",
                            "links" => [ { "title" => "Chat", "href" => "https://example.com" }, { "title" => "Homepage", "href" => "https://example.com/home" }, { "title" => "Terminplaner", "href" => "https://example.com/calendar" } ] } ] }
    }

    context ".footer_sitemap" do
      it "returns an empty hash when there is no footer sitemap" do
        expect(Setting.footer_sitemap).to eq({})
      end

      it "returns a fresh default each time" do
        Setting.footer_sitemap["categories"] = []
        expect(Setting.footer_sitemap).to eq({})
      end

      it "returns the footer sitemap" do
        create(:setting, key: "footer_sitemap", value: sitemap)
        expect(Setting.footer_sitemap).to eq(sitemap)
      end
    end

    context ".footer_sitemap=" do
      it "creates a new setting with the footer sitemap" do
        Setting.footer_sitemap = sitemap
        expect(Setting.footer_sitemap).to eq(sitemap)
      end
    end
  end

  describe "copyright" do
    context ".footer_copyright" do
      it "returns an empty string when there is no footer copyright" do
        expect(Setting.footer_copyright).to eq("")
      end

      it "returns the footer copyright" do
        create(:setting, key: "footer_copyright", value: "© 2021 Example")
        expect(Setting.footer_copyright).to eq("© 2021 Example")
      end
    end

    context ".footer_copyright=" do
      it "creates a new setting with the footer copyright" do
        Setting.footer_copyright = "© 2021 Example"
        expect(Setting.footer_copyright).to eq("© 2021 Example")
      end

      it "raises and keeps the footer copyright when it is too long" do
        Setting.footer_copyright = "© 2021 Example"

        expect { Setting.footer_copyright = "a" * 256 }.to raise_error(ActiveRecord::RecordInvalid)
        expect(Setting.footer_copyright).to eq("© 2021 Example")
      end
    end
  end

  describe "brand" do
    context ".brand_logo" do
      it "returns nil when there is no brand logo" do
        expect(Setting.brand_logo).to be_nil
      end

      it "returns the brand logo" do
        file = File.open(Rails.root.join('spec', 'assets', 'images', 'for-tests.jpg'))
        setting = create(:setting, key: "brand_logo")
        setting.attachment.attach(io: file, filename: 'for-tests.jpg', content_type: 'image/jpg')
        expect(Setting.brand_logo).to eq(setting.attachment.attachment)
      end
    end

    context ".brand_logo=" do
      it "creates a new setting with the brand logo" do
        file = File.open(Rails.root.join('spec', 'assets', 'images', 'for-tests.jpg'))
        Setting.save_brand_logo(file)
        expect(Setting.brand_logo).to eq(ActiveStorage::Attachment.last)
      end

      it "rejects SVG uploads" do
        Tempfile.open([ "brand-logo", ".svg" ]) do |file|
          file.write('<svg xmlns="http://www.w3.org/2000/svg" width="1" height="1"/>')
          file.rewind
          upload = ActionDispatch::Http::UploadedFile.new(
            tempfile: file,
            filename: "brand-logo.svg",
            type: "image/svg+xml"
          )

          Setting.save_brand_logo(upload)
          expect(Setting.brand_logo).to be_nil
        end
      end
    end

    context ".display_brand_name?" do
      it "returns true when display brand name is not set" do
        expect(Setting.display_brand_name?).to be_truthy
      end

      it "returns false when display brand name is set to false" do
        create(:setting, key: "display_brand_name", value: false)
        expect(Setting.display_brand_name?).to be_falsey
      end

      it "returns true when display brand name is set to true" do
        create(:setting, key: "display_brand_name", value: true)
        expect(Setting.display_brand_name?).to be_truthy
      end
    end

    context ".display_brand_name=" do
      it "creates a new setting to hide the brand name" do
        Setting.display_brand_name = false
        expect(Setting.display_brand_name?).to be_falsey
      end

      it "creates a new setting to show the brand name" do
        Setting.display_brand_name = true
        expect(Setting.display_brand_name?).to be_truthy
      end

      it "casts form values to booleans" do
        Setting.display_brand_name = "0"
        expect(Setting.display_brand_name?).to be(false)

        Setting.display_brand_name = "1"
        expect(Setting.display_brand_name?).to be(true)
      end
    end

    context ".brand_name" do
      it "returns nil when there is no brand name" do
        expect(Setting.brand_name).to be_nil
      end

      it "returns the brand name" do
        create(:setting, key: "brand_name", value: "Example")
        expect(Setting.brand_name).to eq("Example")
      end
    end

    context ".brand_name=" do
      it "creates a new setting with the brand name" do
        Setting.brand_name = "Example"
        expect(Setting.brand_name).to eq("Example")
      end

      it "casts the brand name to a string" do
        Setting.brand_name = 42
        expect(Setting.brand_name).to eq("42")
      end

      it "accepts a brand name of up to 100 characters" do
        Setting.brand_name = "a" * 100
        expect(Setting.brand_name).to eq("a" * 100)
      end

      it "raises and keeps the brand name when it is too long" do
        Setting.brand_name = "Example"

        expect { Setting.brand_name = "a" * 101 }.to raise_error(ActiveRecord::RecordInvalid)
        expect(Setting.brand_name).to eq("Example")
      end
    end
  end

  describe "caching" do
    def count_queries(&)
      count = 0
      counter = ->(*, payload) { count += 1 unless payload[:name] == "SCHEMA" }
      ActiveSupport::Notifications.subscribed(counter, "sql.active_record", &)
      count
    end

    before do
      Setting.brand_name = "Example"
      Setting.footer_copyright = "© Example"
      Current.reset
    end

    it "reads all settings with a single query" do
      queries = count_queries do
        Setting.brand_name
        Setting.display_brand_name?
        Setting.footer_copyright
        Setting.footer_sitemap
        Setting.updated_at
      end

      expect(queries).to eq(1)
    end

    it "reads a changed setting" do
      Setting.brand_name
      Setting.brand_name = "Changed"
      expect(Setting.brand_name).to eq("Changed")
    end

    it "reads a removed setting" do
      Setting.brand_name
      Setting.remove("brand_name")
      expect(Setting.brand_name).to be_nil
    end

    it "returns when a setting was last updated" do
      expect(Setting.updated_at).to eq(Setting.maximum(:updated_at))
    end
  end

  describe "concurrent saves" do
    # Simulates another request creating the setting after this one looked it
    # up: the first lookup returns a new record instead of the existing row.
    def stale_first_lookup(record)
      lookups = 0
      allow(Setting).to receive(:find_or_initialize_by).and_wrap_original do |original, **attributes|
        lookups += 1
        lookups == 1 ? record : original.call(**attributes)
      end
    end

    before do
      Setting.brand_name = "Acme"
      Current.reset
    end

    it "saves when the uniqueness validation finds the other request's setting" do
      stale_first_lookup(Setting.new(key: "brand_name"))

      Setting.brand_name = "Changed"

      expect(Setting.brand_name).to eq("Changed")
      expect(Setting.where(key: "brand_name").count).to eq(1)
    end

    it "saves when the insert hits the unique index" do
      stale_record = Setting.new(key: "brand_name")
      allow(stale_record).to receive(:save!).and_raise(ActiveRecord::RecordNotUnique)
      stale_first_lookup(stale_record)

      Setting.brand_name = "Changed"

      expect(Setting.brand_name).to eq("Changed")
      expect(Setting.where(key: "brand_name").count).to eq(1)
    end

    it "raises when the setting keeps failing to save" do
      allow(Setting).to receive(:find_or_initialize_by).and_return(Setting.new(key: "brand_name"))

      expect { Setting.brand_name = "Changed" }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end
end
