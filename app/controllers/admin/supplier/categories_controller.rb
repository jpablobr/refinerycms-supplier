module Admin
  module Supplier
    class CategoriesController < Admin::BaseController

      crudify :supplier_category,
              :title_attribute => :title,
              :order => 'title ASC'

    end
  end
end
