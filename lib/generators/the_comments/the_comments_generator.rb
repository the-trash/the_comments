class TheCommentsGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('../templates', __FILE__)
  # argument :xname, type: :string, default: :xname

  def generate_controllers
    if gen_name == 'install'
      cp_setup
      cp_controllers
    elsif gen_name == 'controllers'
      cp_controllers
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

  def cp_controllers
    copy_file 'comments_controller.rb',               'app/controllers/comments_controller.rb'
    copy_file 'ip_black_lists_controller.rb',         'app/controllers/ip_black_lists_controller.rb'
    copy_file 'user_agent_black_lists_controller.rb', 'app/controllers/user_agent_black_lists_controller.rb'
  end
end