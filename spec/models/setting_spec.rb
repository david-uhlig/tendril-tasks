require 'rails_helper'

RSpec.describe Setting, type: :model do
  let(:setting) { create(:setting) }

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
      setting.attachments.attach(io: File.open(Rails.root.join('spec', 'assets', 'files', 'example.txt')), filename: 'example.txt', content_type: 'text/plain')
      expect(setting).to be_valid
    end

    it "is valid with multiple attachments" do
      setting.attachments.attach(io: File.open(Rails.root.join('spec', 'assets', 'files', 'example.txt')), filename: 'example.txt', content_type: 'text/plain')
      setting.attachments.attach(io: File.open(Rails.root.join('spec', 'assets', 'files', 'example.txt')), filename: 'example.txt', content_type: 'text/plain')
      expect(setting).to be_valid
    end

    it "is valid with a value and an attachment" do
      setting.value = "value"
      setting.attachments.attach(io: File.open(Rails.root.join('spec', 'assets', 'files', 'example.txt')), filename: 'example.txt', content_type: 'text/plain')
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
    end
  end

  describe "brand" do
    context ".brand_logo" do
      it "returns nil when there is no brand logo" do
        expect(Setting.brand_logo).to be_nil
      end

      it "returns the brand logo" do
        file = File.open(Rails.root.join('spec', 'assets', 'files', 'example.txt'))
        setting = create(:setting, key: "brand_logo")
        setting.attachments.attach(io: file, filename: 'example.txt', content_type: 'text/plain')
        expect(Setting.brand_logo).to eq(setting.attachments.first)
      end
    end

    context ".brand_logo=" do
      it "creates a new setting with the brand logo" do
        file = File.open(Rails.root.join('spec', 'assets', 'files', 'example.txt'))
        Setting.brand_logo = file
        expect(Setting.brand_logo).to eq(ActiveStorage::Attachment.last)
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
    end
  end
end
