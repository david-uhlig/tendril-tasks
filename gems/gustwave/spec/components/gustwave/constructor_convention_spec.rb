require "rails_helper"

# Checks every Gustwave component against the constructor convention, so new
# components are covered without opting in.
RSpec.describe "Gustwave constructor convention", type: :component do
  components_dir = Gustwave::Engine.root.join("app/components/gustwave").to_s
  Rails.autoloaders.main.eager_load_dir(components_dir)

  # The arguments of components that can't be built without any, the keyword
  # arguments a component forwards to a child component, and the options
  # whose defaults come from a derived value.
  setups = {
    Gustwave::DismissButton => { args: [ "target" ] },
    Gustwave::Dropdowns::Menus::Base => { kwargs: { id: "menu" } },
    Gustwave::Dropdowns::Menus::Generic => { kwargs: { id: "menu" } },
    Gustwave::Dropdowns::Menus::List => { kwargs: { id: "menu" } },
    Gustwave::Dropdowns::MenuItems::Dropdown => { forwards: %i[placement trigger_event] },
    Gustwave::Dropdowns::Triggers::Base => { kwargs: { menu_id: "menu" } },
    Gustwave::Dropdowns::Triggers::Button => { kwargs: { menu_id: "menu" } },
    Gustwave::Dropdowns::Triggers::Generic => { kwargs: { menu_id: "menu" } },
    Gustwave::Dropdowns::Triggers::InlineButton => { kwargs: { menu_id: "menu" } },
    Gustwave::Form::RichText::Button => { args: [ :bold ] },
    Gustwave::Form::RichText::Lexxy::Button => { args: [ :bold ] },
    Gustwave::Form::RichText::Trix::Button => { args: [ :bold ] },
    Gustwave::Form::RichText::Trix::LinkToggle => { args: [ nil ] },
    Gustwave::Form::RichText::Trix::Toolbar => { args: [ nil ] },
    Gustwave::Heading => { derived_defaults: { scheme: :default_scheme } },
    Gustwave::Icon => { args: [ :close ] },
    Gustwave::IconToast => { forwards: %i[position] },
    Gustwave::Spinner => { forwards: %i[size] }
  }

  components = Gustwave::Component.descendants.select do |component|
    component.name && Object.const_source_location(component.name)&.first&.start_with?(components_dir)
  end

  components.sort_by(&:name).each do |component|
    describe component do
      setup = setups.fetch(component, {})
      it_behaves_like "a component following the constructor convention",
                      *setup.fetch(:args, []), forwards: setup.fetch(:forwards, []),
                      derived_defaults: setup.fetch(:derived_defaults, {}), **setup.fetch(:kwargs, {})
    end
  end
end
