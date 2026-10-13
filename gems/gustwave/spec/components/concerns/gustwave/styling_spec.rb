require "rails_helper"

RSpec.describe Gustwave::Styling do
  let(:base_class) do
    Class.new do
      include Gustwave::Styling

      delegate_missing_to :proxy

      def proxy; self.class; end
    end
  end

  let(:without_styling) do
    Class.new(base_class) do
    end.new
  end

  let(:with_styling) do
    Class.new(base_class) do
      styling :base, "bg-white text-gray-100"
      styling :scheme,
              variations: {
                none: "",
                blue: "bg-blue-500 text-white"
              }
    end.new
  end

  let(:parent_class) do
    Class.new(base_class) do
      styling :size, "w-10 h-10"
    end
  end

  let(:child_class) do
    Class.new(parent_class) do
      styling :base, "flex"
      styling :scheme,
              variations: {
                none: "",
                blue: "bg-blue-500 text-white"
              }
    end
  end

  describe "#styling" do
    # Creating and modifying styling definitions
    describe "new styling" do
      context "with short form signature" do
        it "sets default" do
          without_styling.styling(:base, "bg-white", default: :off)
          expect(without_styling.base_styling_default).to eq(:off)
        end

        it "auto resolves default to :on" do
          without_styling.styling(:base, "bg-white text-gray-100")
          expect(without_styling.base_styling_default).to eq(:on)
        end

        it "adds styling" do
          without_styling.styling(:base, "bg-white text-gray-100")
          expected = {
            on: "bg-white text-gray-100",
            off: ""
          }
          expect(without_styling.base_styling_variations).to eq(expected)
        end

        it "defines getter methods" do
          without_styling.styling(:base, "bg-white text-gray-100")
          expect(without_styling).to respond_to(:base_styling_default)
          expect(without_styling).to respond_to(:base_styling_variations)
        end

        it "invalid default value raises StylingDefaultArgumentError" do
          expect {
            without_styling.styling(:base, "bg-white text-gray-100", default: :invalid)
          }.to raise_error(Gustwave::Styling::StylingErrors::DefaultArgumentError)
        end

        it "raises ArgumentError when variation is nil" do
          expect {
            without_styling.styling(:base, nil)
          }.to raise_error(ArgumentError)
        end
      end

      context "with long form signature" do
        it "sets default" do
          without_styling.styling(
            :scheme,
            variations: {
              none: "",
              blue: "bg-blue-500 text-white",
              red: "bg-red-500 text-white"
            },
            default: :blue
          )
          expect(without_styling.scheme_styling_default).to eq(:blue)
        end

        it "auto resolves default to :default if present" do
          without_styling.styling(
            :scheme,
            variations: {
              none: "",
              default: "bg-blue-500 text-white",
              other: ""
            }
          )
          expect(without_styling.scheme_styling_default).to eq(:default)
        end

        it "auto resolves default to last variation otherwise" do
          without_styling.styling(
            :scheme,
            variations: {
              none: "",
              no_default: "bg-blue-500 text-white",
              other: ""
            }
          )
          expect(without_styling.scheme_styling_default).to eq(:other)
        end

        it "adds styling" do
          without_styling.styling(
            :scheme,
            variations: {
              none: "",
              blue: "bg-blue-500 text-white"
            },
            default: :blue
          )
          expected = {
            none: "",
            blue: "bg-blue-500 text-white"
          }
          expect(without_styling.scheme_styling_variations).to eq(expected)
        end

        it "defines getter methods" do
          without_styling.styling(
            :scheme,
            variations: {
              none: "",
              no_default: "bg-blue-500 text-white",
              other: ""
            }
          )
          expect(without_styling).to respond_to(:scheme_styling_default)
          expect(without_styling).to respond_to(:scheme_styling_variations)
        end

        it "invalid default value raises InvalidStylingDefaultVariationError" do
          expect {
            without_styling.styling(
              :scheme,
              variations: {
                none: "",
                blue: "bg-blue-500 text-white"
              },
              default: :invalid
            )
          }.to raise_error(Gustwave::Styling::StylingErrors::DefaultArgumentError)
        end

        it "raises ArgumentError when variations is empty" do
          expect {
            without_styling.styling(:scheme, variations: {})
          }.to raise_error(ArgumentError)
        end
      end
    end

    describe "merging into existing styling" do
      context "with short form signature" do
        it "keeps default" do
          with_styling.styling(:base, "text-red-200")
          expect(with_styling.base_styling_default).to eq(:on)
        end

        it "sets new default" do
          with_styling.styling(:base, default: :off)
          expect(with_styling.base_styling_default).to eq(:off)
        end

        it "keeps variations if only default is changed" do
          with_styling.styling(:base, default: :off)
          expected = {
            on: "bg-white text-gray-100",
            off: ""
          }
          expect(with_styling.base_styling_variations).to eq(expected)
        end

        it "sets new variations" do
          with_styling.styling(:base, "flex")
          expected = {
            on: "flex",
            off: ""
          }
          expect(with_styling.base_styling_variations).to eq(expected)
        end

        it "no change without changes" do
          result = with_styling.styling(:base)
          expected = {
            on: "bg-white text-gray-100",
            off: ""
          }
          expect(with_styling.base_styling_variations).to eq(expected)
        end
      end

      context "with long form signature" do
        it "keeps default" do
          with_styling.styling(
             :scheme,
             variations: {
               example: "bg-blue-500 text-white"
             }
          )
          expect(with_styling.scheme_styling_default).to eq(:blue)
        end

        it "sets new default" do
          with_styling.styling(:scheme, default: :none)
          expect(with_styling.scheme_styling_default).to eq(:none)
        end

        it "keeps variations if only default is changed" do
          with_styling.styling(:scheme, default: :none)
          expected = {
            none: "",
            blue: "bg-blue-500 text-white"
          }
          expect(with_styling.scheme_styling_variations).to eq(expected)
        end

        it "merges new variations" do
          result = with_styling.styling(
            :scheme,
            variations: {
              example: "bg-blue-500 text-white"
            }
          )
          expected = {
            none: "",
            blue: "bg-blue-500 text-white",
            example: "bg-blue-500 text-white"
          }
          expect(with_styling.scheme_styling_variations).to eq(expected)
        end

        it "replaces existing variations" do
          result = with_styling.styling(
            :scheme,
            variations: {
              none: "flex"
            }
          )
          expected = {
            none: "flex",
            blue: "bg-blue-500 text-white"
          }
          expect(with_styling.scheme_styling_variations).to eq(expected)
        end

        it "no change without changes" do
          with_styling.styling(:scheme, variations: {})
          expected = {
            none: "",
            blue: "bg-blue-500 text-white"
          }
          expect(with_styling.scheme_styling_variations).to eq(expected)
        end
      end
    end

    describe "#<styling>_styling_default getter" do
      it "returns default variation key" do
        expect(with_styling.base_styling_default).to eq(:on)
      end
    end

    describe "#<styling>_styling_variations getter" do
      it "returns styling variations" do
        expected = {
          on: "bg-white text-gray-100",
          off: ""
        }
        expect(with_styling.base_styling_variations).to eq(expected)
      end
    end

    # Error handling
    describe "error handling" do
      it "handles empty variations" do
        expect {
          without_styling.styling :scheme, variations: {}
        }.to raise_error(ArgumentError)
      end
    end
  end

  describe "#undef_styling" do
    it "removes styling" do
      with_styling.undef_styling(:base)
      expect(with_styling.__stylings.dig(:base)).to eq(nil)
    end

    it "undefs getter methods" do
      with_styling.undef_styling(:base)
      expect(with_styling).not_to respond_to(:base_styling_default)
      expect(with_styling).not_to respond_to(:base_styling_variations)
    end

    it "does not affect parent class" do
      instance = child_class.new
      expected = {
        on: "w-10 h-10",
        off: ""
      }
      expect(instance.size_styling_variations).to eq(expected)

      child_class.undef_styling(:size)
      expect(instance).not_to respond_to(:size_styling_variations)
      expect(instance).not_to respond_to(:size_styling_default)

      parent_instance = parent_class.new
      expect(parent_instance).to respond_to(:size_styling_variations)
      expect(parent_instance).to respond_to(:size_styling_default)
      expect(parent_instance.size_styling_variations).to eq(expected)
    end
  end

  describe "#compose_design" do
    # Basic functionality
    describe "basic functionality" do
      it "accepts boolean true" do
        result = with_styling.compose_design(base: true)
        expected = "bg-white text-gray-100"
        expect(result).to eq(expected)
      end

      it "accepts boolean false" do
        result = with_styling.compose_design(base: false)
        expected = nil
        expect(result).to eq(expected)
      end

      it "accepts generic string" do
        result = with_styling.compose_design(class: "text-white")
        expected = "text-white"
        expect(result).to eq(expected)
      end

      it "accepts generic string with prefixed key" do
        result = with_styling.compose_design(classy: "text-green-200")
        expected = "text-green-200"
        expect(result).to eq(expected)
      end

      it "accepts generic string with postfixed key" do
        result = with_styling.compose_design(spec_class: "text-red-200")
        expected = "text-red-200"
        expect(result).to eq(expected)
      end
    end

    # Merging behavior
    describe "merging behavior" do
      it "merges multiple stylings" do
        result = with_styling.compose_design(
          base: true,
          scheme: :blue
        )
        expected = "bg-blue-500 text-white"
        expect(result).to eq(expected)
      end

      it "merges in the correct order" do
        result = with_styling.compose_design(
          scheme: :blue,
          base: true
        )
        expected = "bg-white text-gray-100"
        expect(result).to eq(expected)
      end

      it "ignores nil values" do
        result = with_styling.compose_design(
          scheme: nil,
          base: true
        )
        expected = "bg-white text-gray-100"
        expect(result).to eq(expected)
      end

      it "merges generic and styling classes" do
        result = with_styling.compose_design(
          scheme: nil,
          class: "text-red-200 flex",
          base: true
        )
        expected = "flex bg-white text-gray-100"
        expect(result).to eq(expected)
      end
    end

    # Environment-specific behavior
    describe "environment-specific behavior" do
      context "in development" do
        before(:each) do
          allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new("development"))
        end

        it "raises an error if the styling does not exist" do
          expect {
            with_styling.compose_design(does_not_exist: true)
          }.to raise_error(Gustwave::Styling::StylingErrors::StylingArgumentError)
        end

        it "raises an error if the variation does not exist" do
          expect {
            with_styling.compose_design(base: :does_not_exist)
          }.to raise_error(Gustwave::Styling::StylingErrors::VariationArgumentError)
        end
      end

      context "in production" do
        before(:each) do
          allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new("production"))
        end

        it "ignores the styling if it doesnt exist" do
          result = with_styling.compose_design(does_not_exist: true)
          expect(result).to be_nil
        end

        it "returns the default variation if the request variation doesnt exist" do
          result = with_styling.compose_design(base: :does_not_exist)
          expected = "bg-white text-gray-100"
          expect(result).to eq(expected)
        end
      end
    end
  end
end
