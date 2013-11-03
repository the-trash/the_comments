module TheComments
  module Generators
    class ViewsGenerator < Rails::Generators::NamedBase
      source_root File.expand_path('../../../../app/views', __FILE__)

      def self.banner
<<-BANNER.chomp

bundle exec rails g the_comments:views js
bundle exec rails g the_comments:views css
bundle exec rails g the_comments:views assets

bundle exec rails g the_comments:views views
bundle exec rails g the_comments:views helper

bundle exec rails g the_comments:views all

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
        if param_name == 'js'
          js_copy          
        if param_name == 'css'
          css_copy
        if param_name == 'assets'
          js_copy; css_copy
        elsif param_name == 'views'
          views_copy
        elsif param_name == 'helper'
          helper_copy
        elsif param_name == 'all'
          js_copy
          css_copy
          views_copy
          helper_copy
        else
          puts "Wrong params - use only [ js | css | assets | views | helper | all] values"
        end
      end

      def js_copy
        copy_file "../assets/javascripts/the_comments.js.coffee", "app/assets/javascripts/the_comments.js.coffee"
      end

      def css_copy
        copy_file "../assets/stylesheets/the_comments.css.scss", "app/assets/stylesheets/the_comments.css.scss"
      end

      def views_copy
        directory "../views/the_comments", "app/views/the_comments"
      end

      def helper_copy
        copy_file "../helpers/render_comments_tree_helper.rb", "app/helpers/render_comments_tree_helper.rb"
      end
    end
  end
end
