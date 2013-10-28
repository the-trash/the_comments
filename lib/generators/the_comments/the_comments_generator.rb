class TheCommentsGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('../templates', __FILE__)
  # argument :xname, type: :string, default: :xname

  def generate_controllers
    if gen_name == 'install'
      cp_setup
      cp_models
      cp_controllers
    elsif gen_name == 'controllers'
      cp_controllers
    elsif gen_name == 'models'
      cp_models
    else
      puts 'TheComments Generator - wrong Name'
      puts 'Try to use [install|controllers]'
    end
  end

  private

  def gen_name
    name.to_s.downcase
  end

  def cp_setup
    copy_file 'the_comments.rb', 'config/initializers/the_comments.rb'
  end

  def cp_models
    copy_file 'comment.rb',               'app/models/comment.rb'
  end

  def cp_controllers
    copy_file 'comments_controller.rb', 'app/controllers/comments_controller.rb'
  end
end
