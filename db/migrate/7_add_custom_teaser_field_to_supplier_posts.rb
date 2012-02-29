class AddCustomTeaserFieldToSupplierPosts < ActiveRecord::Migration
  def self.up
    add_column :supplier_posts, :custom_teaser, :text
  end

  def self.down
    remove_column :supplier_posts, :custom_teaser
  end
end

