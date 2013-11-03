class Comment < ActiveRecord::Base
  include TheComments::Comment
  # ---------------------------------------------------
  # Define comment's avatar url
  # Usually we use Comment#user (owner of comment) to define avatar
  # @blog.comments.includes(:user) <= use includes(:user) to decrease queries count
  # comment#user.avatar_url
  # ---------------------------------------------------

  # ---------------------------------------------------
  # Simple way to define avatar url

  # def avatar_url
  #   hash = Digest::MD5.hexdigest self.id.to_s
  #   "http://www.gravatar.com/avatar/#{hash}?s=30&d=identicon"
  # end
  # ---------------------------------------------------

  # ---------------------------------------------------
  # Define your filters for content
  # Expample for: gem 'RedCloth', gem 'sanitize'
  # your personal SmilesProcessor

  # def prepare_content
  #   text = self.raw_content
  #   text = RedCloth.new(text).to_html
  #   text = SmilesProcessor.new(text)
  #   text = Sanitize.clean(text, Sanitize::Config::RELAXED)
  #   self.content = text
  # end
  # ---------------------------------------------------
end