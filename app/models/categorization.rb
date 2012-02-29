class Categorization < ActiveRecord::Base

  set_table_name 'supplier_categories_supplier_posts'
  belongs_to :supplier_post
  belongs_to :supplier_category

end