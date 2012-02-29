class SupplierController < ApplicationController

  helper :supplier_posts
  before_filter :find_page, :find_all_supplier_categories

protected

  def find_page
    @page = Page.find_by_link_url("/supplier")
  end

  def find_all_supplier_categories
    @supplier_categories = SupplierCategory.all
  end

end
