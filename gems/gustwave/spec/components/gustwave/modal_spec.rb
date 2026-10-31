require "rails_helper"

RSpec.describe Gustwave::Modal, type: :component do
  it_behaves_like "a component with configurable html attributes", selector: "div"

  it "has a random id by default" do
    expect(described_class.new.id).to match(/\Amodal-[a-z0-9]{8}\z/)
  end

  it "keeps a given id" do
    expect(described_class.new(id: "delete").id).to eq "delete"
  end

  describe "root" do
    it "renders a hidden root with the modal's attributes" do
      render_inline(described_class.new(id: "modal")) { "content" }

      expect(page).to have_selector("div#modal.hidden[tabindex='-1'][aria-hidden='true'][data-modal-placement='center'][data-modal-backdrop='dynamic']")
    end

    it "passes on a placement and a backdrop" do
      render_inline(described_class.new(id: "modal", placement: :"bottom-left", backdrop: :static))

      expect(page).to have_selector("#modal[data-modal-placement='bottom-left'][data-modal-backdrop='static']")
    end

    it "raises for an unknown placement when Gustwave is strict" do
      expect { described_class.new(placement: :above) }
        .to raise_error(Gustwave::Options::UnknownValueError, /Unknown value :above for :placement/)
    end

    it "raises for an unknown backdrop when Gustwave is strict" do
      expect { described_class.new(backdrop: :sometimes) }
        .to raise_error(Gustwave::Options::UnknownValueError, /Unknown value :sometimes for :backdrop/)
    end

    it "falls back to the defaults for an unknown placement and backdrop when Gustwave isn't strict" do
      Gustwave.strict = false
      render_inline(described_class.new(id: "modal", placement: :above, backdrop: :sometimes))

      expect(page).to have_selector("#modal[data-modal-placement='center'][data-modal-backdrop='dynamic']")
    end

    [ [ :sm, "max-w-md" ], [ :md, "max-w-2xl" ], [ :lg, "max-w-4xl" ], [ :xl, "max-w-7xl" ] ].each do |size, width|
      it "sets #{width} on the dialog for size: #{size.inspect}" do
        render_inline(described_class.new(id: "modal", size:)) { "content" }

        expect(page).to have_selector("#modal > div.#{width}")
      end
    end

    it "defaults to the md size" do
      render_inline(described_class.new(id: "modal")) { "content" }

      expect(page).to have_selector("#modal > div.max-w-2xl")
    end

    it "adds the focus trap after the caller's controller" do
      render_inline(described_class.new(id: "modal", data: { controller: "cooldown" })) { "content" }

      expect(page.find("#modal")["data-controller"]).to eq "cooldown gustwave--focus-trap"
    end

    it "sets aria-labelledby only with a header" do
      render_inline(described_class.new(id: "modal")) { "content" }
      expect(page.find("#modal")["aria-labelledby"]).to be_nil

      render_inline(described_class.new(id: "modal")) { |modal| modal.with_header("Title text") }
      expect(page.find("#modal")["aria-labelledby"]).to eq "modal-title"
    end

    it "renders the header, body, footer and then the block content, in that order" do
      render_inline(described_class.new(id: "modal")) do |modal|
        modal.with_header("Title text")
        modal.with_body { "Body text" }
        modal.with_footer { "Footer text" }
        "Block text"
      end

      html = rendered_content
      expect(html.index("Title text")).to be < html.index("Body text")
      expect(html.index("Body text")).to be < html.index("Footer text")
      expect(html.index("Footer text")).to be < html.index("Block text")
    end
  end

  describe "dismissible" do
    it "is dismissible by default" do
      expect(described_class.new).to be_dismissible
    end

    [ true, nil, "true" ].each do |dismissible|
      it "is dismissible with dismissible: #{dismissible.inspect}" do
        expect(described_class.new(dismissible:)).to be_dismissible
      end
    end

    [ false, "false", "0" ].each do |dismissible|
      it "isn't dismissible with dismissible: #{dismissible.inspect}" do
        expect(described_class.new(dismissible:)).not_to be_dismissible
      end
    end

    it "renders a close button in the header by default, without the undismissible controller" do
      render_inline(described_class.new(id: "modal")) { |modal| modal.with_header("Title text") }

      expect(page).to have_selector("#modal button[data-modal-hide='modal']")
      expect(page.find("#modal")["data-controller"]).to eq "gustwave--focus-trap"
    end

    [ false, "false" ].each do |dismissible|
      context "with dismissible: #{dismissible.inspect}" do
        before do
          render_inline(described_class.new(id: "modal", dismissible:, backdrop: :dynamic)) do |modal|
            modal.with_header("Title text")
          end
        end

        it "renders no close button in the header" do
          expect(page).not_to have_selector("button[data-modal-hide]")
        end

        it "forces a static backdrop even with backdrop: :dynamic" do
          expect(page.find("#modal")["data-modal-backdrop"]).to eq "static"
        end

        it "wires the undismissible controller after the focus trap" do
          expect(page.find("#modal")["data-controller"]).to eq "gustwave--focus-trap gustwave--undismissible-modal"
        end
      end
    end
  end

  describe "#trigger_options" do
    subject(:modal) { described_class.new(id: "modal") }

    it "toggles the modal by default" do
      expect(modal.trigger_options).to eq(
        "data-modal-target" => "modal",
        "data-modal-toggle" => "modal",
        "aria-controls" => "modal",
        "aria-haspopup" => "dialog"
      )
    end

    it "shows the modal with action: :show" do
      options = modal.trigger_options(action: :show)

      expect(options).to include("data-modal-target" => "modal", "data-modal-show" => "modal", "aria-controls" => "modal")
      expect(options.keys.map(&:to_s)).not_to include("data-modal-toggle")
    end

    it "only hides the modal with action: :hide" do
      expect(modal.trigger_options(action: :hide)).to eq("data-modal-hide" => "modal")
    end

    it "raises for an unknown action when Gustwave is strict" do
      expect { modal.trigger_options(action: :open) }
        .to raise_error(Gustwave::Options::UnknownValueError, /Unknown value :open for :action/)
    end

    it "falls back to toggle for an unknown action when Gustwave isn't strict" do
      Gustwave.strict = false

      expect(modal.trigger_options(action: :open)).to include("data-modal-toggle" => "modal")
    end

    it "lets its own modal attributes win over the trigger's, given as symbols and as strings" do
      options = modal.trigger_options("data-modal-target": "other", "data-modal-toggle": "other")
      expect(options).to include("data-modal-target" => "modal", "data-modal-toggle" => "modal")
      expect(options.keys.count { it.to_s == "data-modal-target" }).to eq(1)
      expect(options.keys.count { it.to_s == "data-modal-toggle" }).to eq(1)

      options = modal.trigger_options(**{ "data-modal-target" => "other", "data-modal-hide" => "other" }, action: :hide)
      expect(options).to eq("data-modal-hide" => "modal")
    end

    it "replaces the trigger's aria-controls" do
      expect(modal.trigger_options("aria-controls": "other")).to include("aria-controls" => "modal")
      expect(modal.trigger_options("aria-controls": "other").keys.count { it.to_s == "aria-controls" }).to eq(1)
    end

    it "replaces the trigger's aria-controls inside an aria hash, keeping its other aria attributes" do
      options = modal.trigger_options(aria: { controls: "other", label: "Open" })

      expect(options).to include("aria-controls" => "modal")
      expect(options[:aria]).to eq(label: "Open")
    end

    it "returns the trigger's other attributes as they are" do
      expect(modal.trigger_options(class: "underline", data: { controller: "x" }))
        .to include(class: "underline", data: { controller: "x" }, "data-modal-target" => "modal")
    end

    it "attaches to a rendered button" do
      render_inline(Gustwave::Buttons::Default.new("Open", **modal.trigger_options(action: :show, data: { controller: "x" })))

      expect(page).to have_css("button[data-controller=x][data-modal-target=modal][data-modal-show=modal][aria-controls=modal][aria-haspopup=dialog]")
    end
  end

  describe "Gustwave::Modal.trigger_options" do
    it "returns what the instance method returns for the same id" do
      modal = described_class.new(id: "modal")

      expect(described_class.trigger_options("modal", action: :show, class: "x"))
        .to eq(modal.trigger_options(action: :show, class: "x"))
    end

    it "attaches to a rendered button, with a hide action" do
      render_inline(Gustwave::Buttons::Default.new("Close", **described_class.trigger_options("modal", action: :hide)))

      expect(page).to have_css("button[data-modal-hide=modal]")
      expect(page).not_to have_css("button[data-modal-target]")
    end
  end
end
