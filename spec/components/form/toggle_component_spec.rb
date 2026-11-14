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
      let(:toggle) { page.find("label.inline-flex") }

      before do
        render_inline(described_class.new(form, :name, false)) do |component|
          component.with_checked_state_text("On")
          component.with_unchecked_state_text("Off")
        end
      end

      it "renders exactly one label, around the switch" do
        expect(page).to have_selector("label", count: 1)
        expect(toggle[:class]).to eq("inline-flex items-center cursor-pointer")
      end

      it "renders Rails' hidden field and bare checkbox, then the texts around the track" do
        children = toggle.all(:xpath, "./*", visible: :all)

        expect(children.map(&:tag_name)).to eq(%w[input input span span span])
        expect(children[0][:type]).to eq("hidden")
        expect(children[0][:name]).to eq("site[name]")
        expect(children[0][:value]).to eq("0")
        expect(children[1][:type]).to eq("checkbox")
        expect(children[1][:id]).to eq("site_name")
        expect(children[1][:name]).to eq("site[name]")
        expect(children[1][:value]).to eq("1")
        expect(children[1][:class]).to eq("sr-only peer")
        expect(children[2].text).to eq("On")
        expect(children[3][:class]).to include("peer", "peer-checked:bg-blue-600")
        expect(children[4].text).to eq("Off")
      end

      it "puts the checkbox directly before the track without state texts" do
        render_inline(described_class.new(form, :name, false))

        expect(page).to have_selector("label > input[type='checkbox'].peer + span.peer", visible: :all)
      end

      it "checks the box when asked to" do
        render_inline(described_class.new(form, :name, false, checked: true))

        expect(page).to have_selector("input[type='checkbox'][checked]", visible: :all)
      end

      it "renders the field's label outside the switch's label" do
        render_inline(described_class.new(form, :name, "Site name"))

        expect(page).to have_no_selector("label label")
        expect(page).to have_selector("label[for='site_name']", text: "Site name", count: 1)
        expect(page).to have_selector("label", count: 2)
      end
    end
  end
end
