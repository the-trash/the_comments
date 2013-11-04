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
        case param_name
          when 'js'
            js_copy
          when 'css'
            css_copy
          when 'assets'
            js_copy; css_copy
          when 'views'
            views_copy
          when 'helper'
            helper_copy
          when 'all'
            js_copy
            css_copy
            views_copy
            helper_copy
          else
            puts 'TheComments View Generator - wrong Name'
            puts "Wrong params - use only [ js | css | assets | views | helper | all ] values"
        end
      end

      def js_copy
        f1 = "app/assets/javascripts/the_comments.js.coffee"
        f2 = "app/assets/javascripts/the_comments_manage.js.coffee"
        copy_file f1, f1
        copy_file f2, f2
      end

      def css_copy
        f1 = "app/assets/stylesheets/the_comments.css.scss"
        copy_file f1, f1
      end

      def views_copy
        d1 = "app/views/the_comments"
        directory d1, d1
      end

      def helper_copy
        f1 = "app/helpers/render_comments_tree_helper.rb"
        copy_file f1, f1
      end
    end
  end
end
