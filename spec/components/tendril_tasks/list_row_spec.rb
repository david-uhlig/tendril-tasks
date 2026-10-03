require "rails_helper"

RSpec.describe TendrilTasks::ListRow, type: :component do
  it "renders a list item with a row" do
    render_inline(described_class.new(id: "row-1"))

    expect(rendered_content).to have_selector("li#row-1 > div.flex.items-center.rounded-lg.bg-gray-50")
  end

  it "renders the leading visual, the title and the actions in order" do
    render_inline(described_class.new) do |row|
      row.leading { "<img alt='Avatar'>".html_safe }
      row.title "Jane Doe"
      "<button>Edit</button>".html_safe
    end

    expect(rendered_content).to have_selector("li > div > img[alt='Avatar'] + span.flex-1.truncate + button", text: "Edit")
    expect(rendered_content).to have_selector("span.flex-1", text: "Jane Doe")
  end

  it "renders the title from a block" do
    render_inline(described_class.new) do |row|
      row.title { "<a href='/page'>Page</a>".html_safe }
    end

    expect(rendered_content).to have_selector("span.flex-1 > a[href='/page']", text: "Page")
  end

  it "merges custom classes into the title" do
    render_inline(described_class.new) do |row|
      row.title "Jane Doe", class: "text-red-600"
    end

    expect(rendered_content).to have_selector("span.flex-1.text-red-600", text: "Jane Doe")
  end
end
