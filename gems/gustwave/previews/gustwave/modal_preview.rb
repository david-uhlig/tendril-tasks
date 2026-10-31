module Gustwave
  class ModalPreview < ViewComponent::Preview
    # http://localhost:3030/rails/view_components/gustwave/modal/default?size=lg&placement=top-left&backdrop=static
    # @param size select { choices: [sm, md, lg, xl] }
    # @param placement select { choices: [top-left, top-center, top-right, center-left, center, center-right, bottom-left, bottom-center, bottom-right] }
    # @param backdrop select { choices: [dynamic, static] }
    def default(size: :md, placement: :center, backdrop: :dynamic)
      render_with_template(locals: { size:, placement:, backdrop: })
    end

    # http://localhost:3030/rails/view_components/gustwave/modal/not_dismissible
    def not_dismissible
      render_with_template
    end

    # http://localhost:3030/rails/view_components/gustwave/modal/with_form
    def with_form
      render_with_template
    end
  end
end
