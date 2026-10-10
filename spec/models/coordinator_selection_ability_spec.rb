require "rails_helper"
require "cancan/matchers"

RSpec.describe CoordinatorSelectionAbility, type: :model do
  subject(:ability) { described_class.new(user) }

  shared_examples "can search and assign coordinators" do
    it { is_expected.to be_able_to(:read, :coordinator_search_results) }
    it { is_expected.to be_able_to(:assign, :coordinator_selections) }
  end

  shared_examples "cannot search or assign coordinators" do
    it { is_expected.not_to be_able_to(:read, :coordinator_search_results) }
    it { is_expected.not_to be_able_to(:assign, :coordinator_selections) }
  end

  context "when guest" do
    let(:user) { nil }

    it_behaves_like "cannot search or assign coordinators"
  end

  context "when user without coordinatorships" do
    let(:user) { create(:user) }

    it_behaves_like "cannot search or assign coordinators"
  end

  context "when project coordinator" do
    let(:user) { create(:user).tap { |user| create(:project, coordinators: [ user ]) } }

    it_behaves_like "can search and assign coordinators"
  end

  context "when task coordinator" do
    let(:user) { create(:user).tap { |user| create(:task, coordinators: [ user ]) } }

    it_behaves_like "can search and assign coordinators"
  end

  context "when editor" do
    let(:user) { create(:user, :editor) }

    it_behaves_like "can search and assign coordinators"
  end

  context "when admin" do
    let(:user) { create(:user, :admin) }

    it_behaves_like "can search and assign coordinators"
  end
end
