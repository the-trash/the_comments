# gem install haml2slim --no-ri --no-rdoc
# ruby views_converter.rb

from = "./app/views/the_comments/haml"
to   = "./app/views/the_comments/slim"

`haml2slim #{from} #{to} --trace`

Dir.glob("#{to}/*.slim") do |slim_file|
  content = File.read slim_file
  content = content.gsub "haml", "slim"

  file = File.open slim_file, "w"
  file.write content
  file.close
end
