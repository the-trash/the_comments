require 'haml'
 
class ErbEngine < Haml::Engine
  def push_script(text, preserve_script, in_tag = false, preserve_tag = false,
    escape_html = false, nuke_inner_whitespace = false)
    push_text "<%= #{text.strip} %>"
  end

  def push_silent(text, can_suppress = false)
    push_text "<% #{text.strip} %>"
  end
end

def haml_to_erb(haml = "%div{ style: 'display:none'}= @user")
  ErbEngine.new(haml, :attr_wrapper => '"').render
end

p haml_to_erb