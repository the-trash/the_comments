module TheComments
  module Comment
    extend ActiveSupport::Concern

    included do
      scope :active, -> { with_state [:draft, :published] }
      scope :with_users, -> { includes(:user) }

      # Nested Set
      acts_as_nested_set scope: [:commentable_type, :commentable_id]

      # simple sort scopes
      include ::TheSimpleSort::Base

      # TheSortableTree
      include ::TheSortableTree::Scopes

      # Comments State Machine
      include TheComments::CommentStates

      validates :raw_content, presence: true

      # relations
      belongs_to :user
      belongs_to :holder, class_name: :User
      belongs_to :commentable, polymorphic: true

      # callbacks
      before_create :define_holder, :define_default_state, :define_anchor, :denormalize_commentable
      after_create  :update_cache_counters
      before_save   :prepare_content
    end

    def header_title
      title.present? ? title : I18n.t('the_comments.guest_name')
    end

    def user_name
      user.try(:username) || user.try(:login) || header_title
    end

    def avatar_url
      src = id.to_s
      src = title unless title.blank?
      src = contacts if !contacts.blank? && /@/ =~ contacts
      hash = Digest::MD5.hexdigest(src)
      "https://2.gravatar.com/avatar/#{hash}?s=42&d=https://identicons.github.com/#{hash}.png"
    end

    def mark_as_spam
      count = self_and_descendants.update_all({spam: true})
      update_spam_counter
      count
    end

    def mark_as_not_spam
      count = self_and_descendants.update_all({spam: false})
      update_spam_counter
      count
    end

    def to_spam
      mark_as_spam
    end

    private

    def update_spam_counter
      holder.try :update_comcoms_spam_counter
    end

    def define_anchor
      self.anchor = SecureRandom.hex[0..5]
    end

    def define_holder
      c = self.commentable
      self.holder = c.is_a?(User) ? c : c.try(:user)
    end

    def define_default_state
      self.state = TheComments.config.default_owner_state if user && user == holder
    end

    def denormalize_commentable
      self.commentable_title = commentable.try :commentable_title
      self.commentable_state = commentable.try :commentable_state
      self.commentable_url   = commentable.try :commentable_url
    end

    def prepare_content
      self.content = self.raw_content
    end

    # Warn: increment! doesn't call validation =>
    # before_validation filters doesn't work   =>
    # We have few unuseful requests
    # I impressed that I found it and reduce DB requests
    # Awesome logic pazzl! I'm really pedant :D
    def update_cache_counters
      user.try :recalculate_my_comments_counter!

      if holder
        holder.send :try, :define_denormalize_flags
        holder.increment! "#{ state }_comcoms_count"
        # holder.class.increment_counter("#{ state }_comcoms_count", holder.id)
      end

      if commentable
        commentable.send :define_denormalize_flags
        commentable.increment! "#{ state }_comments_count"
        # holder.class.increment_counter("#{ state }_comments_count", holder.id)
      end
    end
  end
end
