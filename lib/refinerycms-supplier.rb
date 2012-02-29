require 'filters_spam'

module Refinery
  module Supplier
    autoload :Version, File.expand_path('../refinery/supplier/version', __FILE__)
    autoload :Tab, File.expand_path("../refinery/supplier/tabs", __FILE__)

    class << self
      attr_accessor :root
      def root
        @root ||= Pathname.new(File.expand_path('../../', __FILE__))
      end

      def version
        ::Refinery::Supplier::Version.to_s
      end
    end

    class Engine < Rails::Engine
      initializer 'supplier serves assets' do |app|
        app.middleware.insert_after ::ActionDispatch::Static, ::ActionDispatch::Static, "#{root}/public"
      end

      config.to_prepare do
        require File.expand_path('../refinery/supplier/tabs', __FILE__)
      end

      config.after_initialize do
        Refinery::Plugin.register do |plugin|
          plugin.pathname = root
          plugin.name = "refinerycms_supplier"
          plugin.url = {:controller => '/admin/supplier/posts', :action => 'index'}
          plugin.menu_match = /^\/?(admin|refinery)\/supplier\/?(posts|comments|categories)?/
          plugin.activity = {
            :class => SupplierPost
          }
        end
      end
    end if defined?(Rails::Engine)
  end
end
