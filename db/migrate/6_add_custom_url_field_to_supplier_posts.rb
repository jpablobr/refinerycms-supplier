class AddCustomUrlFieldToSupplierPosts < ActiveRecord::Migration
  def self.up
    add_column :supplier_posts, :custom_url, :string
  end

  def self.down
    remove_column :supplier_posts, :custom_url
  end
end
