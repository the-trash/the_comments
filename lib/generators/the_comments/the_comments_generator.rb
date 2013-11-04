class TheCommentsGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('../templates', __FILE__)
  # argument :xname, type: :string, default: :xname

  # > rails g the_comments NAME
  def generate_controllers
    case gen_name
      when 'locales'
        cp_locales
      when 'models'
        cp_models
      when 'controllers'
        cp_controllers
      when 'config'
        cp_config
      when 'install'
        cp_config
        cp_models
        cp_controllers
      else
        puts 'TheComments Generator - wrong Name'
        puts 'Try to use [ install | config | controllers | models ]'
    end
  end

  private

  def root_path; TheComments::Engine.root; end

  def gen_name
    name.to_s.downcase
  end

  def cp_config
    copy_file "#{root_path}/config/initializers/the_comments.rb",
              "config/initializers/the_comments.rb"
  end

  def cp_models
    copy_file "#{root_path}/app/models/_templates_/comment.rb",
              "app/models/comment.rb"
  end

  def cp_controllers
    copy_file "#{root_path}/app/controllers/_templates_/comments_controller.rb",
              "app/controllers/comments_controller.rb"
  end

  def cp_locales
    copy_file "#{root_path}/config/locales/en.yml",
              "config/locales/en.the_comments.yml"

    copy_file "#{root_path}/config/locales/ru.yml",
              "config/locales/ru.the_comments.yml"
  end
end
