module TheComments
  module ManageActions
    extend ActiveSupport::Concern

    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # App side methods (you can overwrite them)
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    def manage
      @comments = current_user.comcoms.with_users.active.recent.page(params[:page])
      render view_context.comment_template('manage/manage')
    end

    def my_comments
      @comments = current_user.my_comments.with_users.active.recent.page(params[:page])
      render view_context.comment_template('manage/manage')
    end

    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Methods based on *current_user* helper
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    # Methods for admin

    %w[ draft published deleted ].each do |state|
      define_method state do
        @comments = current_user.comcoms.with_users.with_state(state).recent.page(params[:page])
        render view_context.comment_template('manage/manage')
      end

      define_method "total_#{ state }" do
        @comments = ::Comment.with_state(state).with_users.recent.page(params[:page])
        render view_context.comment_template('manage/manage')
      end

      define_method "my_#{ state }" do
        @comments = current_user.my_comments.with_users.with_state(state).recent.page(params[:page])
        render view_context.comment_template('manage/manage')
      end
    end

    def spam
      @comments = current_user.comcoms.with_users.where(spam: true).recent.page(params[:page])
      render view_context.comment_template('manage/manage')
    end

    def my_spam
      @comments = current_user.my_comments.with_users.where(spam: true).recent.page(params[:page])
      render view_context.comment_template('manage/manage')
    end

    def total_spam
      @comments = ::Comment.where(spam: true).with_users.recent.page(params[:page])
      render view_context.comment_template('manage/manage')
    end

    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Restricted area
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    def edit
      @comments = current_user.comcoms.where(id: params[:id]).page(params[:page])
      render view_context.comment_template('manage/manage')
    end

    def update
      comment = ::Comment.find(params[:id])
      comment.update_attributes!(patch_comment_params)
      render(layout: false, partial: view_context.comment_template('manage/comment/body'), locals: { comment: comment })
    end

    %w[ draft published deleted ].each do |state|
      define_method "to_#{ state }" do
        ::Comment.find(params[:id]).try "to_#{ state }"
        render nothing: true
      end
    end

    def to_spam
      comment = ::Comment.find(params[:id])
      comment.to_deleted
      comment.mark_as_spam
      render nothing: true
    end
  end
end
