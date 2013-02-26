module TheCommentsBase
  extend ActiveSupport::Concern

  included do
    # Nested Set
    attr_accessible :parent_id
    acts_as_nested_set scope: [:commentable_type, :commentable_id]

    # Comments State Machine
    include TheCommentsStates

    # TheSortableTree
    include TheSortableTree::Scopes

    attr_accessible :user, :title, :contacts, :raw_content, :view_token, :state
    attr_accessible :ip, :referer, :user_agent, :tolerance_time

    # validates :title, presence: true
    validates :raw_content, presence: true

    # relations
    belongs_to :user
    belongs_to :holder, class_name: :User
    belongs_to :commentable, polymorphic: true

    # callbacks
    before_create :define_holder, :define_anchor, :denormalize_commentable, :prepare_content
    after_create  :update_cache_counters

    def avatar_url
      src = id.to_s
      src = title unless title.blank?
      src = contacts if !contacts.blank? && /@/ =~ contacts
      hash = Digest::MD5.hexdigest(src)
      "http://www.gravatar.com/avatar/#{hash}?s=40&d=identicon"
    end

    private

    def define_anchor
      self.anchor = SecureRandom.hex[0..5]
    end

    def define_holder
      self.holder = self.commentable.user
    end

    def denormalize_commentable
      self.commentable_title = self.commentable.try :commentable_title
      self.commentable_url   = self.commentable.try :commentable_url
    end

    def prepare_content
      self.content = self.raw_content
    end

    def update_cache_counters
      self.user.try        :increment!, :draft_comments_count
      self.holder.try      :increment!, :draft_comcoms_count
      self.commentable.try :increment!, :draft_comments_count
    end
  end
end