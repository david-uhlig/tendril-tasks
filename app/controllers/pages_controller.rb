# frozen_string_literal: true

class PagesController < ApplicationController
  EDITABLE_PAGES = %w[ imprint privacy-policy terms-of-service ]

  before_action :set_page, only: %i[ show destroy ]
  authorize_resource
  before_action :set_editable_page, only: %i[ edit update ]

  def show
    return render :show if @page.present?

    template = case params[:slug]
               when "home" then "pages/static/home"
               else
                 raise ActionController::RoutingError, "Not Found"
               end

    render template
  end

  def edit; end

  def update
    if @page.update(page_params)
      flash[:notice] = "Page was successfully updated."
      redirect_to page_path(@page.slug)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @page.destroy if @page.present?
    flash[:notice] = "Page was successfully deleted."
    redirect_to root_path
  end

  private

  def set_page
    @page = Page.find_by(slug: params[:slug])
  end

  def set_editable_page
    raise ActionController::RoutingError, "Not Found" unless params[:slug].in?(EDITABLE_PAGES)

    @page = Page.find_or_initialize_by(slug: params[:slug])
  end

  def page_params
    params.require(:page).permit(:content)
  end
end
