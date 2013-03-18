module TheComments
  module Generators
    class ViewsGenerator < Rails::Generators::NamedBase
      source_root File.expand_path('../../../../app/views', __FILE__)

      def self.banner
<<-BANNER.chomp

bundle exec rails g the_comments:views assets
bundle exec rails g the_comments:views views
bundle exec rails g the_comments:views helper

BANNER
      end

      def copy_sortable_tree_files
        copy_gem_files
      end

      private

      def param_name
        name.downcase
      end

      def copy_gem_files
        if param_name == 'assets'
          copy_file "../assets/javascripts/the_comments", "app/assets/javascripts/the_comments"
          copy_file "../assets/stylesheets/the_comments", "app/assets/stylesheets/the_comments"
        elsif param_name == 'views'
          directory "../views/the_comments",           "app/views/the_comments"
          directory "../views/ip_black_lists",         "app/views/ip_black_lists"
          directory "../views/user_agent_black_lists", "app/views/user_agent_black_lists"
        elsif param_name == 'helper'
          copy_file "../helpers/render_comments_tree_helper.rb", "app/helpers/render_comments_tree_helper.rb"
        else
          puts "Wrong params - use only [assets | views | helper] values"
        end
      end

    end
  end
end