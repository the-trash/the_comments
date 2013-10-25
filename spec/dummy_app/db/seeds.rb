puts 'Users'

3.times do
  User.create!(username: Faker::Name.name)
  print '.'
end

puts
puts 'Posts'

User.all.each do |user|
  3.times do
    user.posts.create!(
      title:   Faker::Lorem.sentence,
      content: Faker::Lorem.paragraphs(3).join
    )
    print '.'
  end
end

puts
puts 'Comments'

users = User.all
posts = Post.all

20.times do
  user = users.sample
  post = posts.sample

  Comment.create!(
    user: user,
    commentable: post,
    title: Faker::Lorem.sentence,
    raw_content: Faker::Lorem.paragraphs(3).join,
    state: :published
  )

  print '.'
end

puts