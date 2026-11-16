# frozen_string_literal: true

require "yaml"

module Gustwave
  # Test helpers for specs of apps that use Gustwave. Each helper is in its own file under
  # +gustwave/test+ and is required on its own, e.g. +require "gustwave/test/style_snapshots"+,
  # so a spec loads only the helpers it uses.
  module Test
    # Records the markup a component renders for every combination of its
    # style options and compares it to a committed YAML fixture.
    #
    # Each snapshot is split into groups. A group renders the cartesian
    # product of its axes, so put options that affect each other (e.g. a
    # border that depends on the color) into the same group and keep the
    # others apart.
    #
    # Every rendered element is recorded in document order as its tag name,
    # its other attributes sorted by name and its sorted classes. Reordering
    # classes doesn't fail a snapshot, but moving them to another element, or
    # adding, changing or dropping an attribute, does. SVG path geometry
    # (+d+) is left out. Ids from +generate_random_id+ are
    # numbered per combination, so they stay stable between runs.
    #
    # Run with +UPDATE_STYLE_SNAPSHOTS=1+ to write the fixtures instead of
    # comparing against them.
    #
    # @example spec/components/style_snapshots_spec.rb
    #   RSpec.describe "Style snapshots", type: :component do
    #     extend Gustwave::Test::StyleSnapshots
    #     self.style_snapshot_dir = Rails.root.join("spec/fixtures/style_snapshots")
    #
    #     style_snapshot Gustwave::Badge do
    #       group :color, color: %i[default red], border: [ false, true ] do |**args|
    #         Gustwave::Badge.new("New", **args)
    #       end
    #     end
    #   end
    module StyleSnapshots
      # Adds the +style_snapshot_dir+ class attribute to the example group, which names the
      # directory of the fixtures.
      #
      # @param base [Class] the example group that extends StyleSnapshots.
      # @return [void]
      def self.extended(base)
        base.class_attribute :style_snapshot_dir
      end

      # Defines an example that renders all groups of +name+ and compares the
      # result to the fixture +<style_snapshot_dir>/<name.underscore>.yml+.
      #
      # @param name [Class, String] the component, or its name, e.g. +"Gustwave::Badge"+.
      # @yield the groups to record, see Snapshot#group.
      # @return [void]
      def style_snapshot(name, &definition)
        name = name.to_s

        it "keeps the markup of #{name}" do
          snapshot = Snapshot.new(name)
          snapshot.instance_eval(&definition)
          actual = StableRandomIds.while_recording do |reset|
            snapshot.record(self, reset:) do |component, content, slots|
              render_inline(component) do |rendered|
                instance_exec(rendered, &slots) if slots
                content
              end
            end
          end
          path = Pathname(style_snapshot_dir).join("#{name.underscore}.yml")

          if ENV["UPDATE_STYLE_SNAPSHOTS"]
            FileUtils.mkdir_p(path.dirname)
            path.write(YAML.dump(actual))
          else
            expect(path).to exist, "#{path} is missing. Run with UPDATE_STYLE_SNAPSHOTS=1 to create it."
            expected = YAML.safe_load_file(path)
            message = Snapshot.diff(expected, actual)
            expect(message).to be_nil, message
          end
        end
      end

      # Numbers the ids from +generate_random_id+ while a snapshot records,
      # so they stay stable between runs.
      module StableRandomIds
        # Runs the block with the ids from +generate_random_id+ numbered from 1.
        #
        # @yieldparam reset [Proc] restarts the numbering, so each combination starts again at 1.
        # @return [Object] the value of the block.
        def self.while_recording
          Thread.current[:gustwave_style_snapshot_ids] = 0
          yield -> { Thread.current[:gustwave_style_snapshot_ids] = 0 }
        ensure
          Thread.current[:gustwave_style_snapshot_ids] = nil
        end

        # Returns an id such as +prefix-r1-postfix+ while a snapshot records, and otherwise the
        # id from HtmlAttributesHelper.
        #
        # @param prefix [String, nil] text before the id.
        # @param postfix [String, nil] text after the id.
        # @param length [Integer] the length of the id, including its +r+.
        # @param separator [String] what joins the prefix, the id and the postfix.
        # @return [String] the id.
        def generate_random_id(prefix: nil, postfix: nil, length: 8, separator: "-")
          count = Thread.current[:gustwave_style_snapshot_ids]
          return super unless count

          Thread.current[:gustwave_style_snapshot_ids] = count + 1
          [ prefix, format("r%0#{length - 1}d", count + 1), postfix ].compact_blank.join(separator)
        end
      end
      Gustwave::HtmlAttributesHelper.prepend(StableRandomIds)

      # The groups of one +style_snapshot+ and the markup each combination renders. Its +group+
      # method is what the definition block of +style_snapshot+ calls.
      class Snapshot
        # A group of combinations: its +axes+, the +content+ and +slots+ to render each with, and
        # the +builder+ that returns the component.
        Group = Struct.new(:name, :axes, :content, :slots, :builder)

        # How many changed combinations Snapshot.diff lists before it says how many more there are.
        MAX_REPORTED_DIFFERENCES = 20
        # Attributes that Snapshot#elements leaves out: +class+, which is recorded as sorted
        # classes, and +d+, the SVG path geometry.
        IGNORED_ATTRIBUTES = %w[class d].freeze

        # Describes how +actual+ differs from +expected+ combination by combination, or returns
        # nil when they match.
        #
        # @param expected [Hash{String => Array<String>}] the recorded fixture.
        # @param actual [Hash{String => Array<String>}] the markup recorded now.
        # @return [String, nil] the message for a failing example, or nil.
        def self.diff(expected, actual)
          differences = (expected.keys | actual.keys).filter_map do |key|
            next if expected[key] == actual[key]

            if !expected.key?(key) then "+ #{key} (new)"
            elsif !actual.key?(key) then "- #{key} (removed)"
            else
              "~ #{key}\n" \
                "    expected: #{expected[key].inspect}\n" \
                "    actual:   #{actual[key].inspect}"
            end
          end
          return if differences.empty?

          shown = differences.first(MAX_REPORTED_DIFFERENCES)
          more = differences.size - shown.size
          ([ "#{differences.size} #{"combination".pluralize(differences.size)} changed:" ] + shown +
            (more.positive? ? [ "… and #{more} more" ] : [])).join("\n")
        end

        # @param name [String] the component's name, which names the snapshot in errors.
        def initialize(name)
          @name = name
          @groups = []
        end

        # Registers a group that renders every combination of +axes+. The
        # block receives one combination as keyword arguments and returns the
        # component. +content+ is passed as block content, and +slots+ is
        # called with the component inside the render block, where slot
        # setters have a view context. Both blocks run in the example, so
        # they can use factories, stubs and test helpers.
        #
        # @param name [Symbol, String] the group's name, which starts each of its keys in the fixture.
        # @param content [String, nil] the block content that each combination renders with.
        # @param slots [Proc, nil] called with the component inside the render block, to set its slots.
        # @param axes [Hash{Symbol => Object}] the options to vary, each with a value or an array of values.
        # @return [void]
        def group(name, content: nil, slots: nil, **axes, &builder)
          raise ArgumentError, "group #{name.inspect} needs a block" unless builder

          @groups << Group.new(name, axes, content, slots, builder)
        end

        # Returns { "group key=value …" => ["tag attribute=\"value\": classes", …] }.
        # +reset+ is called before each combination is built.
        #
        # @param example [RSpec::Core::ExampleGroup] the example that builds each component.
        # @param reset [Proc, nil] called before each combination is built.
        # @return [Hash{String => Array<String>}] the recorded elements of each combination, by key.
        def record(example, reset: nil)
          @groups.each_with_object({}) do |group, result|
            combinations(group.axes).each do |args|
              key = [ group.name, *args.map { |k, v| "#{k}=#{v.inspect}" } ].join(" ")
              raise ArgumentError, "#{@name} records #{key} twice" if result.key?(key)

              reset&.call
              fragment = yield example.instance_exec(**args, &group.builder), group.content, group.slots
              result[key] = elements(fragment)
            end
          end
        end

        private

        def combinations(axes)
          return [ {} ] if axes.empty?

          keys = axes.keys
          values = axes.values.map { |v| v.is_a?(Array) ? v : [ v ] }
          values.first.product(*values.drop(1)).map { |combo| keys.zip(combo).to_h }
        end

        def elements(fragment)
          fragment.css("*").map do |node|
            attributes = node.attribute_nodes
                             .reject { |attribute| IGNORED_ATTRIBUTES.include?(attribute.name) }
                             .sort_by(&:name)
                             .map { |attribute| "#{attribute.name}=#{attribute.value.inspect}" }
            classes = node["class"].to_s.split.uniq.sort
            [ [ node.name, *attributes ].join(" "), (classes.join(" ") if classes.any?) ].compact.join(": ")
          end
        end
      end
    end
  end
end
