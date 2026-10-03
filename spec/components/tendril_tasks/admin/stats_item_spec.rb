require "rails_helper"

RSpec.describe TendrilTasks::Admin::StatsItem, type: :component do
  it "describes the label with the total and new items" do
    render_inline(described_class.new("Users", { total: 12, new: 3 }))

    expect(rendered_content).to have_selector("div > dt", text: "Users")
    expect(rendered_content).to have_selector("div > dt + dd", text: "12")
    expect(rendered_content).to have_selector("dd span", text: "+3")
  end

  it "adds the content as another description" do
    render_inline(described_class.new("Users", { total: 12, new: 0 })) { "2 admins" }

    expect(rendered_content).to have_selector("dd", count: 2)
    expect(rendered_content).to have_selector("dd + dd", text: "2 admins")
  end

  it "omits the content description without content" do
    render_inline(described_class.new("Users", { total: 12, new: 0 }))

    expect(rendered_content).to have_selector("dd", count: 1)
  end
end
