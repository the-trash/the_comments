class TheCommentsGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('../templates', __FILE__)
  argument :controllers, type: :string, default: :controllers

  def generate_controllers
    if gen_name == 'controllers'
      copy_file 'comments_controller.rb',               'app/controllers/comments_controller.rb'
      copy_file 'ip_black_lists_controller.rb',         'app/controllers/ip_black_lists_controller.rb'
      copy_file 'user_agent_black_lists_controller.rb', 'app/controllers/user_agent_black_lists_controller.rb'
    end
  end

  private

  def gen_name
    controllers.to_s.underscore  
  end  
end
