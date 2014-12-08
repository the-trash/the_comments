module TheComments
  module Comment
    extend ActiveSupport::Concern

    included do
      scope :active, -> { with_state [:draft, :published] }
      scope :with_users, -> { includes(:user) }

      # subscribe notifications
      attr_accessor :subscribe_to_thread_flag

      # Nested Set
      acts_as_nested_set scope: [:commentable_type, :commentable_id]

      # 1. Simple sort scopes
      # 2. AntiSpam services check methods
      # 3. TheSortableTree
      # 4. Comments State Machine
      #
      include ::TheSimpleSort::Base
      include ::TheComments::AntiSpam
      include ::TheSortableTree::Scopes
      include ::TheComments::CommentStates

      validates :raw_content, presence: true

      # Relations
      belongs_to :user
      belongs_to :holder, class_name: :User
      belongs_to :commentable, polymorphic: true

      # Callbacks
      before_create :define_holder, :define_default_state, :define_anchor, :denormalize_commentable
      after_create  :update_cache_counters
      before_save   :prepare_content
    end

    def subscribe_to_thread!(current_user)
      return unless subscribe_to_thread_flag

      return subscribe_email_to_thread! unless current_user
      # subscribe_logined_user_to_thread!(current_user)
    end

    def subscribe_email_to_thread!
      email_ergexp = /\A(\S+)@(\S+)\.(\S{2,15})\z/
      _contacts    = normalize_email contacts

      if _contacts.match email_ergexp
        self.comments_subscribers.create(email: _contacts)
      end
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
      count = self_and_descendants.update_all({ spam: true })
      update_spam_counter
      count
    end

    def mark_as_not_spam
      count = self_and_descendants.update_all({ spam: false })
      update_spam_counter
      count
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

    def update_cache_counters
      user.try :recalculate_my_comments_counter!

      if holder
        holder.update_columns({
          "#{ state }_comcoms_count" => holder.send("#{ state }_comcoms_count") + 1
        })
      end

      if commentable
        commentable.update_columns({
          "#{ state }_comments_count" => commentable.send("#{ state }_comments_count") + 1
        })
      end
    end

    def normalize_email str
      str.to_s.squish.strip.gsub(/\s*/, '')
    end

  end
end
