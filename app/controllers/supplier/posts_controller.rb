module Supplier
  class PostsController < SupplierController

    before_filter :find_all_supplier_posts, :except => [:archive]
    before_filter :find_supplier_post, :only => [:show, :comment, :update_nav]
    before_filter :find_tags

    respond_to :html, :js, :rss

    def index
      # Rss feeders are greedy. Let's give them every supplier post instead of paginating.
      (@supplier_posts = SupplierPost.live.includes(:comments, :categories).all) if request.format.rss?
      respond_with (@supplier_posts) do |format|
        format.html
        format.rss
      end
    end

    def show
      @supplier_comment = SupplierComment.new
      @canonical = url_for(:locale => ::Refinery::I18n.default_frontend_locale) if canonical?

      respond_with (@supplier_post) do |format|
        format.html { present(@supplier_post) }
        format.js { render :partial => 'post', :layout => false }
      end
    end

    def comment
      if (@supplier_comment = @supplier_post.comments.create(params[:supplier_comment])).valid?
        if SupplierComment::Moderation.enabled? or @supplier_comment.ham?
          begin
            Supplier::CommentMailer.notification(@supplier_comment, request).deliver
          rescue
            logger.warn "There was an error delivering a supplier comment notification.\n#{$!}\n"
          end
        end

        if SupplierComment::Moderation.enabled?
          flash[:notice] = t('thank_you_moderated', :scope => 'supplier.posts.comments')
          redirect_to supplier_post_url(params[:id])
        else
          flash[:notice] = t('thank_you', :scope => 'supplier.posts.comments')
          redirect_to supplier_post_url(params[:id],
                                   :anchor => "comment-#{@supplier_comment.to_param}")
        end
      else
        render :action => 'show'
      end
    end

    def archive
      if params[:month].present?
        date = "#{params[:month]}/#{params[:year]}"
        @archive_date = Time.parse(date)
        @date_title = @archive_date.strftime('%B %Y')
        @supplier_posts = SupplierPost.live.by_archive(@archive_date).paginate({
                                                                               :page => params[:page],
                                                                               :per_page => RefinerySetting.find_or_set(:supplier_posts_per_page, 10)
                                                                             })
      else
        date = "01/#{params[:year]}"
        @archive_date = Time.parse(date)
        @date_title = @archive_date.strftime('%Y')
        @supplier_posts = SupplierPost.live.by_year(@archive_date).paginate({
                                                                            :page => params[:page],
                                                                            :per_page => RefinerySetting.find_or_set(:supplier_posts_per_page, 10)
                                                                          })
      end
      respond_with (@supplier_posts)
    end

    def tagged
      @tag = ActsAsTaggableOn::Tag.find(params[:tag_id])
      @tag_name = @tag.name
      @supplier_posts = SupplierPost.tagged_with(@tag_name).paginate({
                                                                     :page => params[:page],
                                                                     :per_page => RefinerySetting.find_or_set(:supplier_posts_per_page, 10)
                                                                   })
    end

    protected

    def find_supplier_post
      unless (@supplier_post = SupplierPost.find(params[:id])).try(:live?)
        if refinery_user? and current_user.authorized_plugins.include?("refinerycms_supplier")
          @supplier_post = SupplierPost.find(params[:id])
        else
          error_404
        end
      end
    end

    def find_all_supplier_posts
      @supplier_posts = SupplierPost.live.includes(:comments, :categories).paginate({
                                                                                    :page => params[:page],
                                                                                    :per_page => RefinerySetting.find_or_set(:supplier_posts_per_page, 10)
                                                                                  })
    end

    def find_tags
      @tags = SupplierPost.tag_counts_on(:tags)
    end

    def canonical?
      ::Refinery.i18n_enabled? && ::Refinery::I18n.default_frontend_locale != ::Refinery::I18n.current_frontend_locale
    end
  end
end
