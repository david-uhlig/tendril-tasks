require "rails_helper"

RSpec.describe TendrilTasks::AvatarGroup, type: :component do
  # Visible avatars and the badge are the group's direct children.
  def group_items
    page.find("body > *").all(:xpath, "./*")
  end

  describe "rendering" do
    it "renders nothing without users" do
      render_inline(described_class.new([]))

      expect(rendered_content).to be_blank
    end

    it "renders an avatar for each user" do
      users = create_list(:user, 2, :with_avatar)

      render_inline(described_class.new(users))

      expect(page).to have_css("img", count: 2)
    end
  end

  context "when there are more users than the visible count" do
    let(:users) { create_list(:user, 5, :with_avatar) }

    it "renders one avatar fewer than the visible count" do
      render_inline(described_class.new(users, visible_count: 3))

      expect(page).to have_css("img", count: 2)
    end

    it "renders a single badge after the visible avatars" do
      render_inline(described_class.new(users, visible_count: 3))

      expect(group_items.size).to eq(3)
      expect(group_items.last).to have_text("+3")
    end

    it "shows the number of hidden users in the badge" do
      render_inline(described_class.new(users, visible_count: 3))

      expect(page).to have_text("+3")
    end

    it "caps the badge number at the maximum hidden count" do
      render_inline(described_class.new(users, visible_count: 3, max_hidden_count: 2))

      expect(page).to have_text("+2")
      expect(page).to have_no_text("+3")
    end

    it "counts the hidden users from the total count" do
      render_inline(described_class.new(users.first(3), visible_count: 3, total_count: 10))

      expect(page).to have_css("img", count: 2)
      expect(group_items.last).to have_text("+8")
    end
  end

  context "when there are fewer users than the visible count" do
    let(:users) { create_list(:user, 2, :with_avatar) }

    it "renders every avatar" do
      render_inline(described_class.new(users, visible_count: 3))

      expect(page).to have_css("img", count: 2)
    end

    it "renders no badge" do
      render_inline(described_class.new(users, visible_count: 3))

      expect(group_items.size).to eq(2)
    end
  end

  context "without a visible count" do
    let(:users) { create_list(:user, 5, :with_avatar) }

    it "renders every avatar" do
      render_inline(described_class.new(users))

      expect(page).to have_css("img", count: 5)
    end

    it "renders no badge" do
      render_inline(described_class.new(users))

      expect(group_items.size).to eq(5)
    end
  end
end
