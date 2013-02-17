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

      def view_token
        @options[:controller].try(:comments_view_token)
      end

      def render_node(h, options)
        @h, @options = h, options
        @comment     = options[:node]

        if @comment.draft?
          draft_comment
        elsif @comment.published?
          published_comment
        else
          deleted_comment
        end
      end

      def draft_comment
        if view_token == @comment.view_token
          published_comment
        else
          "<li class='draft'><div class='comment'>Waiting for Moderation</div></li>"
        end
      end

      def published_comment
        anchor = h.link_to('#', '#' + @comment.anchor)

        "
          <li class='published'>
            <div class='comment' data-comment-id='#{@comment.to_param}'>
              <a name='#{@comment.anchor}'></a>
              <p><b>#{@comment.title}</b> #{ anchor }</p>
              <p>#{@comment.raw_content}</p>
              #{ controls }
            </div>

            <div class='form_holder'></div>

            #{ children }
          </li>
        "
      end

      def deleted_comment
        "<li class='deleted'><div class='comment'>DELETED</div></li>"
      end

      def controls
        "<div class='controls'>
          <a href='#' class='reply'>reply</a>
          <a href='#'>spam!</a>
          <a href='#'>delete</a>
        </div>"
      end

      def children
        "<ol class='nested_set'>#{ options[:children] }</ol>"
      end

    end
  end
end