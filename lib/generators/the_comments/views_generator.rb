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
          directory "../assets/javascripts", "app/assets/javascripts"
          directory "../assets/stylesheets", "app/assets/stylesheets"
        elsif param_name == 'views'
          directory "../views/comments", "app/views/comments"
        elsif param_name == 'helper'
          copy_file "../helpers/render_comments_tree_helper.rb", "app/helpers/render_comments_tree_helper.rb"
        else
          puts "Wrong params - use only [assets | views | helper] values"
        end
      end

    end
  end
end