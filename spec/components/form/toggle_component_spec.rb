# frozen_string_literal: true

require "rails_helper"

RSpec.describe Form::ToggleComponent, type: :component do
  let(:site) { Site.new }

  {
    "a plain Rails builder" => ActionView::Helpers::FormBuilder,
    "Gustwave::FormBuilder" => Gustwave::FormBuilder
  }.each do |name, builder|
    context "with #{name}" do
      let(:form) { builder.new(:site, site, vc_test_controller.view_context, {}) }
      let(:row) { page.find("div.inline-flex", visible: :all) }

      before do
        render_inline(described_class.new(form, :name, false)) do |component|
          component.with_checked_state_text("On")
          component.with_unchecked_state_text("Off")
        end
      end

      it "renders Rails' hidden field and checkbox, with the texts around the switch as its labels" do
        expect(row.all(:xpath, "./label[@for='site_name']", visible: :all).map(&:text)).to eq(%w[On Off])
        expect(row).to have_selector("input[type='hidden'][name='site[name]'][value='0']", visible: :all)
        expect(row).to have_selector(
          "input[type='checkbox'][id='site_name'][name='site[name]'][value='1']", visible: :all
        )
        expect(row.all(:xpath, "./*", visible: :all).map(&:tag_name)).to eq(%w[label label label])
      end

      it "puts the checkbox directly before the track without state texts" do
        render_inline(described_class.new(form, :name, false))

        expect(page).to have_selector("label > input[type='checkbox'].peer", visible: :all)
      end

      it "checks the box when asked to" do
        render_inline(described_class.new(form, :name, false, checked: true))

        expect(page).to have_selector("input[type='checkbox'][checked]", visible: :all)
      end

      it "renders the field's label outside the switch's label" do
        render_inline(described_class.new(form, :name, "Site name"))

        expect(page).to have_no_selector("label label")
        expect(page).to have_selector("label[for='site_name']", text: "Site name")
      end

      it "marks the checkbox invalid and describes it by the error message" do
        site.errors.add(:name, "is invalid")
        render_inline(described_class.new(form, :name, "Site name"))

        checkbox = page.find("input[type='checkbox']", visible: :all)
        message = page.find("[id='#{checkbox["aria-describedby"]}']", visible: :all)
        expect(checkbox["aria-invalid"]).to eq("true")
        expect(message.text(:all)).to match(/is invalid/i)
      end
    end
  end
end
