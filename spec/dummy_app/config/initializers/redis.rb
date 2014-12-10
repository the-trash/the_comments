redis_port = 6500
$redis = Redis.new(:port => redis_port)

puts "Redis: try to run on port: #{ redis_port }!"
