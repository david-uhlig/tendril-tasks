require "rails_helper"

RSpec.describe Gustwave::Mapping do
  let(:base_class) do
    Class.new do
      include Gustwave::Mapping

      delegate_missing_to :proxy

      def proxy; self.class; end
    end
  end

  let(:empty_class) do
    Class.new(base_class) do
    end
  end

  let(:empty_instance) do
    empty_class.new
  end

  let(:filled_class) do
    Class.new(base_class) do
      mapping :role_to_scheme, {
        admin: :blue,
        editor: :green,
        user: :gray
      }, fallback: :user
    end
  end

  let(:filled_instance) do
    filled_class.new
  end

  let(:child_of_filled_instance) do
    Class.new(filled_class) do
    end.new
  end

  describe "#mapping" do
    describe "new mappings" do
      before(:each) do
        allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new("production"))
      end

      it "sets default" do
        empty_instance.mapping :foo_to_bar, {
          default: :blue
        }, fallback: :default
        expect(empty_instance.foo_to_bar_mapping(:invalid)).to eq(:blue)
      end

      it "auto resolves default to the first key" do
        empty_instance.mapping :foo_to_bar, {
          red: :gray,
          blue: :green,
          green: :blue
        }
        expect(empty_instance.foo_to_bar_mapping(:invalid)).to eq(:gray)
      end

      it "adds mappings" do
        empty_instance.mapping :foo_to_bar, {
          default: :blue,
          green: :green
        }, fallback: :green
        expected = {
          default: :blue,
          green: :green
        }
        expect(empty_instance.foo_to_bar_mapping).to eq(expected)
      end

      it "defines getter method" do
        empty_instance.mapping :foo_to_bar, { default: :blue }
        expect(empty_instance).to respond_to(:foo_to_bar_mapping)
      end

      it "allows empty map argument" do
        empty_instance.mapping :foo_to_bar, {}
        expect(empty_instance.foo_to_bar_mapping).to eq({})
      end

      it "returns nil as default value with empty map argument" do
        empty_instance.mapping :foo_to_bar, {}
        expect(empty_instance.foo_to_bar_mapping(:invalid)).to be_nil
      end

      it "defines custom getter method" do
        empty_instance.mapping :foo_to_bar, {}, as: :any_other_method_name
        expect(empty_instance).to respond_to(:any_other_method_name)
      end

      context "invalid arguments" do
        before(:each) do
          allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new("test"))
        end

        it "raises ArgumentError when map is not a hash" do
          expect {
            empty_instance.mapping(:invalid, "invalid")
          }.to raise_error(ArgumentError)
        end

        it "raises DefaultArgumentError when default is not a key in the map" do
          expect {
            empty_instance.mapping(:invalid, { default: :blue }, fallback: :not_in_map)
          }.to raise_error(Gustwave::Mapping::MappingErrors::DefaultArgumentError)
        end
      end
    end

    describe "overwrite existing mappings" do
      context "in same class" do
        it "overwrites mapping" do
          filled_instance.mapping :role_to_scheme, {
            blackroll: :black,
            whiteroll: :white
          }
          expected = {
            blackroll: :black,
            whiteroll: :white
          }
          expect(filled_instance.role_to_scheme_mapping).to eq(expected)
        end
      end

      context "in parent class" do
        it "overwrites mapping" do
          child_of_filled_instance.mapping(
            :role_to_scheme,
            { foo: :bar },
            fallback: :foo
          )
          expected = { foo: :bar }
          expect(child_of_filled_instance.role_to_scheme_mapping).to eq(expected)
        end

        it "keeps parent mapping" do
          child_of_filled_instance.mapping(
            :role_to_scheme,
            { foo: :bar },
            fallback: :foo
          )
          expected = {
            admin: :blue,
            editor: :green,
            user: :gray
          }
          parent_instance = child_of_filled_instance.superclass.new

          expect(parent_instance.role_to_scheme_mapping).to eq(expected)
          expect {
            parent_instance.role_to_scheme_mapping(:foo)
          }.to raise_error(Gustwave::Mapping::MappingErrors::ArgumentError)
        end
      end
    end
  end

  describe "#undef_mapping" do
    it "fails silently when mapping does not exist" do
      result = empty_instance.undef_mapping(:does_not_exist)
      expect(result).to be_nil
    end

    it "removes mapping" do
      filled_instance.undef_mapping(:role_to_scheme)
      expect(filled_instance.__mappings.key?(:role_to_scheme)).to be_falsey
    end

    it "removes getter method" do
      filled_instance.undef_mapping(:role_to_scheme)
      expect(filled_instance).not_to respond_to(:role_to_scheme_mapping)
    end

    it "removes custom getter method" do
      empty_instance.mapping(:foo_to_bar, {}, as: :any_other_method_name)
      empty_instance.undef_mapping(:foo_to_bar)
      expect(empty_instance).not_to respond_to(:any_other_method_name)
    end

    it "does not affect parent class" do
      instance = child_of_filled_instance
      instance.undef_mapping(:role_to_scheme)
      expect(instance).not_to respond_to(:role_to_scheme_mapping)
      expect(filled_instance).to respond_to(:role_to_scheme_mapping)
    end
  end

  describe "#<name>_mapping getter" do
    it "returns the hash without arguments" do
      result = filled_instance.role_to_scheme_mapping
      expected = {
        admin: :blue,
        editor: :green,
        user: :gray
      }
      expect(result).to eq(expected)
    end

    it "returns mapped value" do
      result = filled_instance.role_to_scheme_mapping(:admin)
      expect(result).to eq(:blue)
    end

    it "raises Error when key is not in the map" do
      expect {
        filled_instance.role_to_scheme_mapping(:invalid)
      }.to raise_error(Gustwave::Mapping::MappingErrors::ArgumentError)
    end

    context "in production" do
      before(:each) do
        allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new("production"))
      end

      it "returns default value when key is not in the map" do
        result = filled_instance.role_to_scheme_mapping(:invalid)
        expect(result).to eq(:gray)
      end

      it "returns nil when map is empty" do
        empty_instance.mapping :foo_to_bar, {}
        expect(empty_instance.foo_to_bar_mapping(:invalid)).to be_nil
      end
    end
  end
end
