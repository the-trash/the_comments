# Spam protection hooks for CREATE action
#
# include TheComments::SpamProtectionTraps
module TheComments
  module SpamProtectionTraps
    extend ActiveSupport::Concern

    included do
      before_action :ajax_requests_required,  only: :create
      before_action :cookies_required,        only: :create

      before_action :empty_trap_required,     only: :create, if: -> { TheComments.config.empty_trap_protection }
      before_action :tolerance_time_required, only: :create, if: -> { TheComments.config.tolerance_time_protection }
    end

    private

    # Protection hooks
    def ajax_requests_required
      unless request.xhr?
        return render(text: t('the_comments.ajax_requests_required'))
      end
    end

    def cookies_required
      if cookies[:the_comment_cookies] != comments_cookies_token
        k = t('the_comments.cookies')
        v = t('the_comments.cookies_required')
        @errors[ k ] = [ v ]
      end
    end

    # TODO:
    # 1) inject ?
    # 2) fields can be removed on client side
    def empty_trap_required
      is_human = true
      params.slice(*TheComments.config.empty_inputs).values.each{|v| is_human = (is_human && v.blank?) }

      if !is_human
        k = t('the_comments.trap')
        v = t('the_comments.trap_message')
        @errors[ k ] = [ v ]
      end
    end

    def tolerance_time_required
      this_time = params[:tolerance_time].to_i
      min_time  = TheComments.config.tolerance_time.to_i

      if this_time < min_time
        tdiff = min_time - this_time
        k = t('the_comments.tolerance_time')
        v = t('the_comments.tolerance_time_message', time: tdiff)
        @errors[ k ] = [ v ]
      end
    end
  end
end
