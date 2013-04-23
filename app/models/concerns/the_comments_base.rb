module TheCommentsBase
  extend ActiveSupport::Concern

  included do
    # attr_accessible :parent_id
    # attr_accessible :ip, :referer, :user_agent, :tolerance_time
    # attr_accessible :user, :title, :contacts, :raw_content, :view_token, :state

    # Nested Set
    acts_as_nested_set scope: [:commentable_type, :commentable_id]

    # Comments State Machine
    include TheCommentsStates

    # TheSortableTree
    include TheSortableTree::Scopes

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
    c = self.commentable
    self.holder = c.is_a?(User) ? c : c.try(:user)
  end

  def define_default_state
    self.state = TheComments.config.default_owner_state if user && user == holder
  end

  def denormalize_commentable
    self.commentable_title = self.commentable.try :commentable_title
    self.commentable_url   = self.commentable.try :commentable_url
    self.commentable_state = self.commentable.try :state
  end

  def prepare_content
    self.content = self.raw_content
  end

  def update_cache_counters
    user.try        :recalculate_my_comments_counter!
    commentable.try :increment!, "#{state}_comments_count"
    holder.try      :increment!, "#{state}_comcoms_count"
  end
end