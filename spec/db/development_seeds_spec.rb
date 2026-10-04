# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Development seeds" do
  subject(:load_seeds) { load Rails.root.join("db/seeds/development.rb") }

  it "creates users of every role, projects, tasks and applications" do
    load_seeds

    expect(User.distinct.pluck(:role)).to contain_exactly("admin", "editor", "user")
    expect(Project.count).to eq(8)
    expect(Task.count).to eq(23)
    expect(TaskApplication.count).to eq(11)
  end

  it "gives every user an existing avatar image" do
    load_seeds

    User.pluck(:avatar_url).each do |avatar_url|
      expect(Rails.public_path.join(avatar_url.delete_prefix("/"))).to exist
    end
  end

  it "embeds images in the descriptions" do
    load_seeds

    project = Project.find_by!(title: "Cargo Bike Sharing")
    expect(project.description.body.attachables).to contain_exactly(an_instance_of(ActiveStorage::Blob))
  end

  it "seeds the branding, the footer and the legal pages" do
    load_seeds

    expect(Setting.brand_name).to eq("Campus Bike Collective")
    expect(Setting.brand_logo).to be_present
    expect(Setting.footer_copyright).to include("Campus Bike Collective")
    expect(Footer::Sitemap.load).to be_valid
    expect(Page.pluck(:slug)).to match_array(Admin::LegalController::LEGAL_PAGES)
  end

  it "keeps settings changed in the admin" do
    Setting.brand_name = "Changed"

    load_seeds

    expect(Setting.brand_name).to eq("Changed")
  end

  it "is idempotent" do
    load_seeds

    expect { load_seeds }.not_to change {
      [ User.count, Project.count, Task.count, TaskApplication.count, ActiveStorage::Blob.count,
        Setting.count, Page.count ]
    }
  end
end
