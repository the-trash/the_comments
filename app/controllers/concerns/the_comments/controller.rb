module TheComments
  # Base functionality of Comments Controller
  # class CommentsController < ApplicationController
  #   include TheComments::Controller
  # end
  module Controller
    extend ActiveSupport::Concern

    included do
      include TheComments::ViewToken

      # Attention! We should not set TheComments cookie before create
      skip_before_action :set_the_comments_cookies, only: [:create]

      # Spam protection
      before_action -> { @errors = [] }, only: [:create]

      before_action :ajax_requests_required,  only: [:create]
      before_action :cookies_required,        only: [:create]

      before_action :empty_trap_required,     only: [:create], if: -> { TheComments.config.empty_trap_protection }
      before_action :tolerance_time_required, only: [:create], if: -> { TheComments.config.tolerance_time_protection }

      # preparation
      before_action :define_commentable, only: [:create]

      # raise an errors
      before_action -> { return render(json: { errors: @errors }) unless @errors.blank? }, only: [:create]
    end

    # App side methods (you can overwrite them)

    def manage
      @comments = current_user.comcoms.with_users.active.recent.page(params[:page])
      render comment_template(:manage)
    end

    def my_comments
      @comments = current_user.my_comments.with_users.active.recent.page(params[:page])
      render comment_template(:manage)
    end

    # Methods based on *current_user* helper
    # Methods for admin
    %w[draft published deleted].each do |state|
      define_method "#{state}" do
        @comments = current_user.comcoms.with_users.with_state(state).recent.page(params[:page])
        render comment_template(:manage)
      end

      define_method "total_#{state}" do
        @comments = ::Comment.with_state(state).with_users.recent.page(params[:page])
        render comment_template(:manage)
      end

      define_method "my_#{state}" do
        @comments = current_user.my_comments.with_users.with_state(state).recent.page(params[:page])
        render comment_template(:manage)
      end
    end

    def spam
      @comments = current_user.comcoms.with_users.where(spam: true).recent.page(params[:page])
      render comment_template(:manage)
    end

    def my_spam
      @comments = current_user.my_comments.with_users.where(spam: true).recent.page(params[:page])
      render comment_template(:manage)
    end

    def total_spam
      @comments = ::Comment.where(spam: true).with_users.recent.page(params[:page])
      render comment_template(:manage)
    end

    # BASE METHODS

    # Public methods

    def create
      @comment = @commentable.comments.new comment_params
      if @comment.valid?
        @comment.save
        return render layout: false, partial: comment_partial(:comment), locals: { tree: @comment }
      end
      render json: { errors: @comment.errors }
    end

    # Restricted area

    def edit
      @comments = current_user.comcoms.where(id: params[:id]).page(params[:page])
      render comment_template(:manage)
    end

    def update
      comment = ::Comment.find(params[:id])
      comment.update_attributes!(patch_comment_params)
      render(layout: false, partial: comment_partial(:comment_body), locals: { comment: comment })
    end

    %w[draft published deleted].each do |state|
      define_method "to_#{state}" do
        ::Comment.find(params[:id]).try "to_#{state}"
        render nothing: true
      end
    end

    def to_spam
      comment = ::Comment.find(params[:id])
      comment.to_spam
      comment.to_deleted
      render nothing: true
    end

    private

    def comment_template template
      { template: "the_comments/#{TheComments.config.template_engine}/#{template}" }
    end

    def comment_partial partial
      "the_comments/#{TheComments.config.template_engine}/#{partial}"
    end

    def denormalized_fields
      title = @commentable.commentable_title
      url   = @commentable.commentable_url
      @commentable ? { commentable_title: title, commentable_url: url } : {}
    end

    def request_data_for_comment
      r = request
      { ip: r.ip, referer: CGI::unescape(r.referer  || 'direct_visit'), user_agent: r.user_agent }
    end

    def define_commentable
      commentable_klass = params[:comment][:commentable_type].constantize
      commentable_id    = params[:comment][:commentable_id]

      @commentable = commentable_klass.find(commentable_id)
      return render(json: { errors: [t('the_comments.undefined_commentable')] }) unless @commentable
    end

    def comment_params
      params
        .require(:comment)
        .permit(:title, :contacts, :raw_content, :parent_id)
        .merge(denormalized_fields)
        .merge(request_data_for_comment)
        .merge(tolerance_time: params[:tolerance_time].to_i)
        .merge(user: current_user, view_token: comments_view_token)
    end

    def patch_comment_params
      params
        .require(:comment)
        .permit(:title, :contacts, :raw_content, :parent_id)
    end

    # Protection hooks
    def ajax_requests_required
      unless request.xhr?
        return render(text: t('the_comments.ajax_requests_required'))
      end
    end

    def cookies_required
      if cookies[:the_comment_cookies] != TheComments::COMMENTS_COOKIES_TOKEN
        @errors << [t('the_comments.cookies'), t('the_comments.cookies_required')].join(': ')
      end
    end

    # TODO:
    # 1) inject ?
    # 2) fields can be removed on client side
    def empty_trap_required
      is_human = true
      params.slice(*TheComments.config.empty_inputs).values.each{|v| is_human = (is_human && v.blank?) }

      if !is_human
        @errors << [t('the_comments.trap'), t('the_comments.trap_message')].join(': ')
      end
    end

    def tolerance_time_required
      this_time = params[:tolerance_time].to_i
      min_time  = TheComments.config.tolerance_time.to_i

      if this_time < min_time
        tdiff   = min_time - this_time
        @errors << [t('the_comments.tolerance_time'), t('the_comments.tolerance_time_message', time: tdiff )].join(': ')
      end
    end
  end
end
