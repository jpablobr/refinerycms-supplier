module Supplier
  class CategoriesController < SupplierController

    def show
      @category = SupplierCategory.find(params[:id])
      @supplier_posts = @category.posts.live.includes(:comments, :categories).paginate({
        :page => params[:page],
        :per_page => RefinerySetting.find_or_set(:supplier_posts_per_page, 10)
      })
    end

  end
end