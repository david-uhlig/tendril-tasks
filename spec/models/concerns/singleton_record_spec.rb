require "rails_helper"

# Uses `Footer` as the single-row model.
RSpec.describe SingletonRecord do
  def count_queries(&)
    count = 0
    counter = ->(*, payload) { count += 1 unless payload[:name] == "SCHEMA" }
    ActiveSupport::Notifications.subscribed(counter, "sql.active_record", &)
    count
  end

  describe ".instance" do
    it "creates the record with its defaults when it doesn't exist yet" do
      expect { Footer.instance }.to change(Footer, :count).from(0).to(1)
      expect(Footer.instance).to have_attributes(id: 1, copyright: "", sitemap: {})
    end

    it "returns the existing record" do
      Footer.create!(copyright: "© Example")

      expect(Footer.instance.copyright).to eq("© Example")
    end

    it "loads the record once per request" do
      Footer.create!(copyright: "© Example")

      queries = count_queries do
        Footer.instance
        Footer.instance
      end

      expect(queries).to eq(1)
    end

    it "reloads the record after it changed" do
      Footer.instance
      Footer.find_or_create_instance.update!(copyright: "© Changed")

      expect(Footer.instance.copyright).to eq("© Changed")
    end

    it "loads the record again in the next request" do
      first_request = Footer.instance
      Current.reset

      expect(Footer.instance).not_to equal(first_request)
    end
  end

  describe ".find_or_create_instance" do
    it "returns the record from the database instead of the loaded one" do
      expect(Footer.find_or_create_instance).not_to equal(Footer.instance)
    end

    it "keeps a change that fails validation out of the loaded record" do
      Footer.create!(copyright: "© Example")
      Footer.instance

      Footer.find_or_create_instance.update(copyright: "a" * 256)

      expect(Footer.instance.copyright).to eq("© Example")
    end

    it "loads the record that another request created after it was looked up" do
      Footer.create!(copyright: "© Other request")
      allow(Footer).to receive(:find_by).and_return(nil)

      expect(Footer.find_or_create_instance.copyright).to eq("© Other request")
      expect(Footer.count).to eq(1)
    end
  end
end
