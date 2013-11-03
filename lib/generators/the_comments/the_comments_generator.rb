class TheCommentsGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('../templates', __FILE__)
  # argument :xname, type: :string, default: :xname

  # > rails g the_comments NAME
  def generate_controllers
    if gen_name == 'models'
      cp_models
    elsif gen_name == 'controllers'
      cp_controllers
    elsif gen_name == 'config'
      cp_config
    elsif gen_name == 'install'
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
end
