module TheComments
  module User
    extend ActiveSupport::Concern

    included do
      has_many :comcoms, class_name: :Comment, foreign_key: :holder_id
    end

    def my_comments; ::Comment.where(user: self); end

    %w[draft published deleted].each do |state|
      define_method "my_#{state}_comments" do
        my_comments.with_state state
      end

      define_method "#{state}_comcoms" do
        comcoms.with_state state
      end
    end

    def my_spam_comments
      my_comments.where(spam: true)
    end

    # I think we shouldn't to have my_deleted_comments cache counter
    def recalculate_my_comments_counter!
      dcount = my_draft_comments.count
      pcount = my_published_comments.count
      update_attributes!({
        my_draft_comments_count:     dcount,
        my_published_comments_count: pcount,
        my_comments_count:           dcount + pcount
      })
    end

    def recalculate_comcoms_counters!
      update_attributes!({
        draft_comcoms_count:     draft_comcoms.count,
        published_comcoms_count: published_comcoms.count,
        deleted_comcoms_count:   deleted_comcoms.count
      })
    end

    def update_comcoms_spam_counter
      update!(spam_comcoms_count: comcoms.where(spam: true).count)
    end

    def comments_sum
      published_comments_count + draft_comments_count
    end

    def comcoms_sum
      published_comcoms_count + draft_comcoms_count
    end
  end
end
