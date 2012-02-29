class AddUserIdToSupplierPosts < ActiveRecord::Migration
  
  def self.up
    add_column :supplier_posts, :user_id, :integer
  end
  
  def self.down
    remove_column :supplier_posts, :user_id
  end
  
end