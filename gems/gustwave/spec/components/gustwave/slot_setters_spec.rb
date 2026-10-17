require "rails_helper"

# Checks that every slot has one public setter, the one ViewComponent
# generates, so no shorthand alias of a +with_+ setter sneaks back in.
RSpec.describe "Gustwave slot setters", type: :component do
  components_dir = Gustwave::Engine.root.join("app/components/gustwave").to_s
  Rails.autoloaders.main.eager_load_dir(components_dir)

  components = Gustwave::Component.descendants.select do |component|
    component.name && Object.const_source_location(component.name)&.first&.start_with?("#{components_dir}/")
  end

  it "has no public method aliasing a slot setter under another name" do
    expect(components).not_to be_empty

    aliases = components.flat_map do |component|
      component.public_instance_methods.filter_map do |method|
        original = component.instance_method(method).original_name
        next unless original.to_s.start_with?("with_") && !method.to_s.start_with?("with_")

        "#{component.name}##{method} -> #{original}"
      end
    end

    expect(aliases.uniq).to be_empty, "shorthand aliases of slot setters:\n#{aliases.uniq.join("\n")}"
  end
end
