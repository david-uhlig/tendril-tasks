module Gustwave
  module Form
    class InputGroupPreview < ViewComponent::Preview
      # A leading dropdown with country flags, and a select. The menu items are buttons. The divider between the
      # dropdown and the select is the dropdown's end border plus the select's 2px light start border, both caller classes.
      def select_dropdown
        render_with_template
      end

      # A leading dropdown, "All categories", an input and a search button attached at its end.
      def dropdown
        render_with_template
      end

      # The input group's options, for trying out how they combine. The addons take the group's size, and the row stays
      # as high as the taller of control and addons. The icon toggle puts an icon inside the input.
      # @param size select { choices: [sm, md, lg] }
      # @param leading select { choices: [none, text, button, dropdown] }
      # @param trailing select { choices: [none, text, button, dropdown] }
      # @param control select { choices: [input, select] }
      # @param icon toggle
      def playground(size: :md, leading: :text, trailing: :none, control: :input, icon: false)
        render_with_template(locals: {
          size: size.to_sym,
          leading: leading.to_sym,
          trailing: trailing.to_sym,
          control: control.to_sym,
          icon: ActiveModel::Type::Boolean.new.cast(icon)
        })
      end
    end
  end
end
