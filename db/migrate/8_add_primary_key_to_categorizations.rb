class AddPrimaryKeyToCategorizations < ActiveRecord::Migration
  def self.up
    unless ::Categorization.column_names.include?("id")
      add_column :supplier_categories_supplier_posts, :id, :primary_key
    end
  end

  def self.down
    remove_column :supplier_categories_supplier_posts, :id
  end
end

