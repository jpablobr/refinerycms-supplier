module Admin
  module Supplier
    class SettingsController < Admin::BaseController

      def notification_recipients
        @recipients = SupplierComment::Notification.recipients

        if request.post?
          SupplierComment::Notification.recipients = params[:recipients]
          flash[:notice] = t('updated', :scope => 'admin.supplier.settings.notification_recipients',
                             :recipients => SupplierComment::Notification.recipients)
          unless request.xhr? or from_dialog?
            redirect_back_or_default(admin_supplier_posts_path)
          else
            render :text => "<script type='text/javascript'>parent.window.location = '#{admin_supplier_posts_path}';</script>",
                   :layout => false
          end
        end
      end

      def moderation
        enabled = SupplierComment::Moderation.toggle!
        unless request.xhr?
          redirect_back_or_default(admin_supplier_posts_path)
        else
          render :json => {:enabled => enabled},
                 :layout => false
        end
      end

      def comments
        enabled = SupplierComment.toggle!
        unless request.xhr?
          redirect_back_or_default(admin_supplier_posts_path)
        else
          render :json => {:enabled => enabled},
                 :layout => false
        end
      end
      
      def teasers
        enabled = SupplierPost.teaser_enabled_toggle!
        unless request.xhr?
          redirect_back_or_default(admin_supplier_posts_path)
        else
          render :json => {:enabled => enabled},
                 :layout => false
        end
      end

    end
  end
end