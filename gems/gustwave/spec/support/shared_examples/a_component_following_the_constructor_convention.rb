require "gustwave/test/styling_sandbox"

# Components should follow the constructor convention documented in
# Gustwave::Component:
# - A keyword argument named like one of the component's options is optional,
#   defaults to the declared default and is validated, i.e. it defaults to
#   +DEFAULT+ (or +false+ for a toggle that is off by default) and goes
#   through +select_options+.
# - An option whose default depends on another option takes it from a
#   +derive+d value, listed in +derived_defaults:+, e.g. Gustwave::Heading's
#   size per tag.
# - Callers can pick every option through a keyword argument, except an
#   +internal: true+ one, or one they pick through another method, listed in
#   +selected_elsewhere:+, e.g. Gustwave::Popover's +trigger_options+.
# - A keyword argument named like a common option, e.g. +tag+ or +color+, is
#   one of the component's options, unless the component forwards it to a
#   child component and lists it in +forwards:+.
#
# @param args [Array] arguments to pass to the component constructor
# @param forwards [Array<Symbol>] keyword arguments forwarded to a child component
# @param derived_defaults [Hash{Symbol => Symbol}] options and the derived values their defaults come from
# @param selected_elsewhere [Array<Symbol>] options callers pick through another method than the constructor
# @param component_class [Class] component class to test (default `described_class`)
# @param kwargs [Hash] additional keyword arguments to pass to the component constructor
RSpec.shared_examples "a component following the constructor convention" do |*args, forwards: [], derived_defaults: {}, selected_elsewhere: [], component_class: described_class, **kwargs|
  common_options = %i[tag type color size position align placement trigger_event]

  keywords = component_class.instance_method(:initialize).parameters
  required_keywords = keywords.filter_map { |type, name| name if type == :keyreq }
  keywords = keywords.filter_map { |type, name| name if type.in?(%i[key keyreq]) }
  options = component_class.option_definition.options
  option_keywords = keywords & options.keys

  build = ->(**overrides) { component_class.new(*args, **kwargs, **overrides) }

  it "makes its option keywords optional" do
    expect(option_keywords & required_keywords).to be_empty
  end

  it "declares the common option keywords it doesn't forward" do
    expect((keywords & common_options) - options.keys - forwards).to be_empty
  end

  it "forwards only keywords it takes and doesn't declare" do
    expect(forwards - (keywords - options.keys)).to be_empty
  end

  options.each_value do |option|
    next if option.internal? || selected_elsewhere.include?(option.name)

    it "lets callers pick #{option.name.inspect}" do
      current = build.call.option_value(option.name)
      other = option.boolean? ? !current : (option.values - [ current ]).first
      expect(build.call(option.name => other).option_value(option.name)).to eq(other)
    end
  end

  option_keywords.each do |name|
    option = options[name]

    if derived_defaults.key?(name)
      it "defaults #{name.inspect} to the derived #{derived_defaults[name].inspect}" do
        derived = component_class.option_definition.derived(derived_defaults[name])
        component = build.call
        other = (option.values - [ :none, component.option_value(name) ]).first
        Gustwave::Test::StylingSandbox.isolate(component_class) do
          component_class.extend_derived(derived.name, values: { component.option_value(derived.from) => other })
          expect(build.call.option_value(name)).to eq(other)
        end
      end

      it "validates #{name.inspect}" do
        expect { build.call(name => :not_a_declared_value) }
          .to raise_error(Gustwave::Options::UnknownValueError)
      end
    elsif option.boolean?
      it "defaults the #{name.inspect} toggle to the declared default" do
        expect(build.call.option_value(name)).to be(option.default)
      end
    else
      it "defaults #{name.inspect} to the declared default" do
        other = (option.values - [ option.default, build.call.option_value(name) ]).first
        Gustwave::Test::StylingSandbox.isolate(component_class) do
          component_class.extend_option(name, default: other)
          expect(build.call.option_value(name)).to eq(other)
        end
      end

      it "validates #{name.inspect}" do
        expect { build.call(name => :not_a_declared_value) }
          .to raise_error(Gustwave::Options::UnknownValueError)
      end
    end
  end
end
