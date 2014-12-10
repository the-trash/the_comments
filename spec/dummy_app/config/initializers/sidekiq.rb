redis_port = 6500
namespace  = 'the_comments_dummy_app'

puts "Sidekiq: try to connect to redis on port: #{ redis_port }!"

Sidekiq.configure_server do |config|
  config.redis = {
    :url => "redis://localhost:#{ redis_port }/12",
    :namespace => namespace
  }
end

Sidekiq.configure_client do |config|
  config.redis = {
    :url => "redis://localhost:#{ redis_port }/12",
    :namespace => namespace
  }
end

