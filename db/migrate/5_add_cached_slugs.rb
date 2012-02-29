class AddCachedSlugs < ActiveRecord::Migration
  def self.up
    add_column :supplier_categories, :cached_slug, :string
    add_column :supplier_posts, :cached_slug, :string
  end

  def self.down
    remove_column :supplier_categories, :cached_slug
    remove_column :supplier_posts, :cached_slug
  end
end
