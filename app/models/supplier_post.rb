require 'acts-as-taggable-on'
require 'seo_meta'

class SupplierPost < ActiveRecord::Base

  is_seo_meta if self.table_exists?

  default_scope :order => 'published_at DESC'
  #.first & .last will be reversed -- consider a with_exclusive_scope on these?

  belongs_to :author, :class_name => 'User', :foreign_key => :user_id, :readonly => true

  has_many :comments, :class_name => 'SupplierComment', :dependent => :destroy
  acts_as_taggable

  has_many :categorizations, :dependent => :destroy
  has_many :categories, :through => :categorizations, :source => :supplier_category

  acts_as_indexed :fields => [:title, :body]

  validates :title, :presence => true, :uniqueness => true
  validates :body,  :presence => true

  has_friendly_id :friendly_id_source, :use_slug => true,
                  :default_locale => (::Refinery::I18n.default_frontend_locale rescue :en),
                  :approximate_ascii => RefinerySetting.find_or_set(:approximate_ascii, false, :scoping => 'supplier'),
                  :strip_non_ascii => RefinerySetting.find_or_set(:strip_non_ascii, false, :scoping => 'supplier')

  scope :by_archive, lambda { |archive_date|
    where(['published_at between ? and ?', archive_date.beginning_of_month, archive_date.end_of_month])
  }

  scope :by_year, lambda { |archive_year|
    where(['published_at between ? and ?', archive_year.beginning_of_year, archive_year.end_of_year])
  }

  scope :all_previous, lambda { where(['published_at <= ?', Time.now.beginning_of_month]) }

  scope :live, lambda { where( "published_at <= ? and draft = ?", Time.now, false) }

  scope :previous, lambda { |i| where(["published_at < ? and draft = ?", i.published_at, false]).limit(1) }
  # next is now in << self

  def next
    SupplierPost.next(self).first
  end

  def prev
    SupplierPost.previous(self).first
  end

  def live?
    !draft and published_at <= Time.now
  end

  def category_ids=(ids)
    self.categories = ids.reject{|id| id.blank?}.collect {|c_id|
      SupplierCategory.find(c_id.to_i) rescue nil
    }.compact
  end

  def friendly_id_source
    custom_url.present? ? custom_url : title
  end

  class << self
    def next current_record
      self.send(:with_exclusive_scope) do
        where(["published_at > ? and draft = ?", current_record.published_at, false]).order("published_at ASC")
      end
    end

    def comments_allowed?
      RefinerySetting.find_or_set(:comments_allowed, true, {
        :scoping => 'supplier'
      })
    end
    
    def teasers_enabled?
      RefinerySetting.find_or_set(:teasers_enabled, true, {
        :scoping => 'supplier'
      })
    end
    
    def teaser_enabled_toggle!
      currently = RefinerySetting.find_or_set(:teasers_enabled, true, {
        :scoping => 'supplier'
      })
      RefinerySetting.set(:teasers_enabled, {:value => !currently, :scoping => 'supplier'})
    end

    def uncategorized
      SupplierPost.live.reject { |p| p.categories.any? }
    end
  end

  module ShareThis
    DEFAULT_KEY = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"

    class << self
      def key
        RefinerySetting.find_or_set(:share_this_key, SupplierPost::ShareThis::DEFAULT_KEY, {
          :scoping => 'supplier'
        })
      end

      def enabled?
        key = SupplierPost::ShareThis.key
        key.present? and key != SupplierPost::ShareThis::DEFAULT_KEY
      end
    end
  end

end
