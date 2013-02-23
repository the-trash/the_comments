# coding: UTF-8
# DOC:
# We use Helper Methods for tree building,
# because it's faster than View Templates and Partials

# SECURITY note
# Prepare your data on server side for rendering
# or use h.html_escape(node.content)
# for escape potentially dangerous content
module RenderCommentsTreeHelper
  module Render 
    class << self
      attr_accessor :h, :options

      # Main Helpers
      def controller
        @options[:controller]
      end

      def t str
        controller.t str
      end

      # Render Helpers
      def visible_draft?
        controller.try(:comments_view_token) == @comment.view_token
      end

      def moderator?
        true #controller.try(:current_user).try(:comment_moderator?, @comment)
      end

      # Render Methods
      def render_node(h, options)
        @h, @options = h, options
        @comment     = options[:node]

        @max_reply_depth = options[:max_reply_depth] || TheComments.config.max_reply_depth

        if @comment.draft?
          draft_comment
        elsif @comment.published?
          published_comment
        else
          deleted_comment
        end
      end

      def draft_comment
        if visible_draft? || moderator?
          published_comment
        else
          "<li class='draft'><div class='comment'>#{ t('the_comments.waiting_for_moderation') }</div></li>"
        end
      end

      def published_comment
        anchor = h.link_to('#', '#comment_' + @comment.anchor)

        "<li class='published'>
          <div id='comment_#{@comment.anchor}' class='comment' data-comment-id='#{@comment.to_param}'>
            <p><b>#{ @comment.title }</b> #{ anchor }</p>
            <p>#{ @comment.content }</p>
            #{ controls }
          </div>

          <div class='form_holder'></div>

          #{ children }
        </li>"
      end

      def moderator_controls
        if moderator?
          to_spam  = h.link_to t('the_comments.spam'),   h.to_spam_comment_url(@comment),  remote: true, class: :to_spam,    method: :post
          to_trash = h.link_to t('the_comments.delete'), h.to_trash_comment_url(@comment), remote: true, class: :to_deleted, method: :delete, data: { confirm: t('the_comments.delete_confirm') }
          "#{ to_spam } #{ to_trash }"
        end
      end

      def controls
        reply = @comment.depth < @max_reply_depth
        reply = reply ? "<a href='#' class='reply'>#{ t('the_comments.reply') }</a>" : ''

        "<div class='controls'>
          #{ reply }
          #{ moderator_controls }
        </div>"
      end

      def children
        "<ol class='nested_set'>#{ options[:children] }</ol>"
      end

      # def deleted_comment
      #   "<li class='deleted'><div class='comment'>DELETED</div></li>"
      # end
    end
  end
end