class TheCommentsGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('../templates', __FILE__)
  argument :gname, type: :string, default: :install

  def generate_controllers
    if gen_name == 'install'
      cp_setup
      cp_migrations
      cp_controllers
    elsif gen_name == 'controllers'
      cp_controllers
    end
  end

  private

  def gen_name
    gname.to_s.underscore  
  end

  def cp_setup
    p 'copy config/the_comments.rb'
  end

  def cp_migrations
    p 'copy migrations'
  end

  def cp_controllers
    copy_file 'comments_controller.rb',               'app/controllers/comments_controller.rb'
    copy_file 'ip_black_lists_controller.rb',         'app/controllers/ip_black_lists_controller.rb'
    copy_file 'user_agent_black_lists_controller.rb', 'app/controllers/user_agent_black_lists_controller.rb'
  end
end
