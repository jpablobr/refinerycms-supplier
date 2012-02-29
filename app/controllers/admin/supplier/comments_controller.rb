module Admin
  module Supplier
    class CommentsController < Admin::BaseController

      crudify :supplier_comment,
              :title_attribute => :name,
              :order => 'published_at DESC'

      def index
        @supplier_comments = SupplierComment.unmoderated
        render :action => 'index'
      end

      def approved
        unless params[:id].present?
          @supplier_comments = SupplierComment.approved
          render :action => 'index'
        else
          @supplier_comment = SupplierComment.find(params[:id])
          @supplier_comment.approve!
          flash[:notice] = t('approved', :scope => 'admin.supplier.comments', :author => @supplier_comment.name)
          redirect_to :action => params[:return_to] || 'index'
        end
      end

      def rejected
        unless params[:id].present?
          @supplier_comments = SupplierComment.rejected
          render :action => 'index'
        else
          @supplier_comment = SupplierComment.find(params[:id])
          @supplier_comment.reject!
          flash[:notice] = t('rejected', :scope => 'admin.supplier.comments', :author => @supplier_comment.name)
          redirect_to :action => params[:return_to] || 'index'
        end
      end

    end
  end
end