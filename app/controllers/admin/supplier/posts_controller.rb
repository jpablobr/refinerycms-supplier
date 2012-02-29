module Admin
  module Supplier
    class PostsController < Admin::BaseController
      require 'will_paginate/array'
      
      crudify :supplier_post,
              :title_attribute => :title,
              :order => 'published_at DESC'
          
      def uncategorized
        @supplier_posts = SupplierPost.uncategorized.paginate({
          :page => params[:page],
          :per_page => SupplierPost.per_page
        })
      end
  
      def tags
        op =  case ActiveRecord::Base.connection.adapter_name.downcase
              when 'postgresql'
                '~*'
              else
                'LIKE'
              end
        wildcard =  case ActiveRecord::Base.connection.adapter_name.downcase
                    when 'postgresql'
                      '.*'
                    else
                      '%'
                    end
        @tags = SupplierPost.tag_counts_on(:tags).where(
            ["tags.name #{op} ?", "#{wildcard}#{params[:term].to_s.downcase}#{wildcard}"]
          ).map { |tag| {:id => tag.id, :value => tag.name}}
        render :json => @tags.flatten
      end
  
      def create
        # if the position field exists, set this object as last object, given the conditions of this class.
        if SupplierPost.column_names.include?("position")
          params[:supplier_post].merge!({
            :position => ((SupplierPost.maximum(:position, :conditions => "")||-1) + 1)
          })
        end
    
        if SupplierPost.column_names.include?("user_id")
          params[:supplier_post].merge!({
            :user_id => current_user.id
          })
        end

        if (@supplier_post = SupplierPost.create(params[:supplier_post])).valid?
          (request.xhr? ? flash.now : flash).notice = t(
            'refinery.crudify.created',
            :what => "'#{@supplier_post.title}'"
          )

          unless from_dialog?
            unless params[:continue_editing] =~ /true|on|1/
              redirect_back_or_default(admin_supplier_posts_url)
            else
              unless request.xhr?
                redirect_to :back
              else
                render :partial => "/shared/message"
              end
            end
          else
            render :text => "<script>parent.window.location = '#{admin_supplier_posts_url}';</script>"
          end
        else
          unless request.xhr?
            render :action => 'new'
          else
            render :partial => "/shared/admin/error_messages",
                   :locals => {
                     :object => @supplier_post,
                     :include_object_name => true
                   }
          end
        end
      end

      before_filter :find_all_categories,
                    :only => [:new, :edit, :create, :update]

      before_filter :check_category_ids, :only => :update

    protected
      def find_all_categories
        @supplier_categories = SupplierCategory.find(:all)
      end

      def check_category_ids
        params[:supplier_post][:category_ids] ||= []
      end
    end
  end
end
