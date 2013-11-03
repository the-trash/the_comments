module TheComments
  module Generators
    class ViewsGenerator < Rails::Generators::NamedBase
      source_root TheComments::Engine.root

      def self.banner
<<-BANNER.chomp

USAGE: [bundle exec] rails g the_comments:views NAME

> rails g the_comments:views js
> rails g the_comments:views css
> rails g the_comments:views assets

> rails g the_comments:views views
> rails g the_comments:views helper

> rails g the_comments:views all

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
        elsif param_name == 'css'
          css_copy
        elsif param_name == 'assets'
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
          puts 'TheComments View Generator - wrong Name'
          puts "Wrong params - use only [ js | css | assets | views | helper | all] values"
        end
      end

      def js_copy
        copy_file "app/assets/javascripts/the_comments.js.coffee", "app/assets/javascripts/the_comments.js.coffee"
      end

      def css_copy
        copy_file "app/assets/stylesheets/the_comments.css.scss", "app/assets/stylesheets/the_comments.css.scss"
      end

      def views_copy
        directory "app/views/the_comments", "app/views/the_comments"
      end

      def helper_copy
        copy_file "app/helpers/render_comments_tree_helper.rb", "app/helpers/render_comments_tree_helper.rb"
      end
    end
  end
end
