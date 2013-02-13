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

      def render_node(h, options)
        @h, @options = h, options
        @node = options[:node]

        if @node.draft?
          draft_comment
        elsif @node.published?
          published_comment
        else
          deleted_comment
        end
      end

      def draft_comment
        "<li class='draft'>Waiting for Moderation</li>"
      end

      def published_comment
        ns   = options[:namespace]
        url  = h.url_for(ns + [@node])
        title_field = options[:title]
        "
          <li class='published'>
            <p><b>#{@node.title}</b></p>
            <p>#{@node.raw_content}</p>
          </li>
        "
      end

      def deleted_comment
        "<li class='deleted'>DELETED</li>"
      end

      def children
        unless options[:children].blank?
          "<ol class='nested_set'>#{ options[:children] }</ol>"
        end
      end

    end
  end
end