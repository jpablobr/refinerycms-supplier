class CreateSupplierStructure < ActiveRecord::Migration

  def self.up
    create_table :supplier_posts, :id => true do |t|
      t.string :title
      t.text :body
      t.boolean :draft
      t.datetime :published_at
      t.timestamps
    end

    add_index :supplier_posts, :id

    create_table :supplier_comments, :id => true do |t|
      t.integer :supplier_post_id
      t.boolean :spam
      t.string :name
      t.string :email
      t.text :body
      t.string :state
      t.timestamps
    end

    add_index :supplier_comments, :id

    create_table :supplier_categories, :id => true do |t|
      t.string :title
      t.timestamps
    end

    add_index :supplier_categories, :id

    create_table :supplier_categories_supplier_posts, :id => false do |t|
      t.integer :supplier_category_id
      t.integer :supplier_post_id
    end

    add_index :supplier_categories_supplier_posts, [:supplier_category_id, :supplier_post_id], :name => 'index_supplier_categories_supplier_posts_on_bc_and_bp'

    load(Rails.root.join('db', 'seeds', 'refinerycms_supplier.rb').to_s)
  end

  def self.down
    UserPlugin.destroy_all({:name => "refinerycms_supplier"})

    Page.delete_all({:link_url => "/supplier"})

    drop_table :supplier_posts
    drop_table :supplier_comments
    drop_table :supplier_categories
    drop_table :supplier_categories_supplier_posts
  end

end
