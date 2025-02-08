module Pages
  class LegalController < ApplicationController
    LEGAL_PAGES = %w[ imprint privacy-policy terms-of-service ]

    before_action :set_page, only: %i[ show destroy ]
    before_action :set_editable_page, only: %i[ edit update ]

    def show; end

    def edit
      authorize! :edit, @page
    end

    def update
      authorize! :update, @page

      if @page.update(page_params)
        flash[:notice] = "Page was successfully updated."
        redirect_to legal_path(@page.slug)
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      authorize! :destroy, @page

      @page.destroy if @page.present?
      flash[:notice] = "Page was successfully deleted."
      redirect_to root_path
    end

    private

    def set_page
      raise ActionController::RoutingError, "Not Found" unless is_legal_page

      @page = Page.find_by(slug: params[:slug])
    end

    def set_editable_page
      raise ActionController::RoutingError, "Not Found" unless is_legal_page

      @page = Page.find_or_initialize_by(slug: params[:slug])
    end

    def page_params
      params.require(:page).permit(:content)
    end

    def is_legal_page
      params[:slug].in?(LEGAL_PAGES)
    end
  end
end
