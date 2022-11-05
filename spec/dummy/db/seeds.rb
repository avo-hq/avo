# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
require "securerandom"
require "open-uri"
require "faker"

ActiveStorage::Attachment.all.each { |attachment| attachment.purge }
Person.delete_all
Review.delete_all
Fish.delete_all
Course.delete_all
Course::Link.delete_all
Fish.delete_all
TeamMembership.delete_all
Team.delete_all
Comment.delete_all
Post.delete_all
Product.delete_all
# ProjectUser.delete_all
Project.delete_all
User.delete_all
['active_storage_blobs', 'active_storage_attachments', 'posts', 'projects', 'projects_users', 'team_memberships', 'teams', 'users', 'comments', 'people', 'reviews', 'courses', 'course_links', 'fish'].each do |table_name|
  ActiveRecord::Base.connection.execute("TRUNCATE #{table_name} RESTART IDENTITY CASCADE")
end

puts "Creating teams"

teams = []
teams.push(FactoryBot.create(:team, name: "Apple", url: "https://apple.com"))
teams.push(FactoryBot.create(:team, name: "Google", url: "https://google.com"))
teams.push(FactoryBot.create(:team, name: "Facebook", url: "https://facebook.com"))
teams.push(FactoryBot.create(:team, name: "Amazon", url: "https://amazon.com"))

puts "Creating users"

users = []
38.times do
  users.push(FactoryBot.create(:user, team_id: teams.sample.id))
end

User.create(
  first_name: "Avo",
  last_name: "Cado",
  email: "avo@avohq.io",
  password: (ENV["AVO_ADMIN_PASSWORD"] || :secret),
  birthday: "2020-03-28",
  roles: {
    admin: true,
    manager: false,
    writer: false
  }
)

famous_users = [
  {
    first_name: 'David Heinemeier',
    last_name: 'Hansson',
    email: 'david@hey.com'
  },
  {
    first_name: 'Chris',
    last_name: 'Oliver',
    email: 'chris@gorails.com'
  },
  {
    first_name: 'Jason',
    last_name: 'Charnes',
    email: 'jason@jasoncharnes.com'
  },
  {
    first_name: 'Jason',
    last_name: 'Swett',
    email: 'jason@benfranklinlabs.com'
  },
  {
    first_name: 'Yukihiro "Matz"',
    last_name: 'Matsumoto',
    email: 'matz@ruby.or.jp'
  },
  {
    first_name: 'Joe',
    last_name: 'Masilotti',
    email: 'joe@masilotti.com'
  },
  {
    first_name: 'Lucian',
    last_name: 'Ghinda',
    email: 'lucian@ghinda.com'
  },
  {
    first_name: 'Mike',
    last_name: 'Perham',
    email: 'mperham@gmail.com'
  },
  {
    first_name: 'Taylor',
    last_name: 'Otwell',
    email: 'taylor@laravel.com'
  },
  {
    first_name: 'Adam',
    last_name: 'Watham',
    email: 'adam@adamwathan.me'
  },
  {
    first_name: 'Jeffery',
    last_name: 'Way',
    email: 'jeffrey@laracasts.com'
  },
  {
    first_name: 'Adrian',
    last_name: 'Marin',
    email: 'adrian@adrianthedev.com'
  },
]

famous_users.reverse.each do |user|
  users.push(FactoryBot.create(:user, team_id: teams.sample.id, **user))
end

puts "Creating people"

# People and Spouses
people = FactoryBot.create_list(:person, 12)
people.each do |person|
  person.spouses << FactoryBot.create(:spouse)
  person.relatives << FactoryBot.create(:sibling)
end

puts "Creating reviews"

reviews = FactoryBot.create_list(:review, 32)
reviews.each do |review|
  reviewable = [:fish, :post, :project, :team].sample
  review.reviewable = FactoryBot.create(reviewable, created_at: Time.now - 1.day)

  review.user = users.sample

  review.save
end

puts "Creating posts"

25.times do
  post = FactoryBot.create(:post, user_id: users.sample.id)

  post.cover_photo.attach(io: URI.open("https://source.unsplash.com/random/#{[1000, 1100, 1200, 1300].sample}x#{[1000, 1100, 1200, 1300].sample}"), filename: "cover.jpg")

  puts "Creating posts comments"

  rand(0..15).times do
    post.comments << FactoryBot.create(:comment, user_id: users.sample.id)
  end
end

puts "Creating projects"

projects = []
30.times do
  projects.push(FactoryBot.create(:project))
end

puts "Assigning members to teams"

# assign users to teams
teams.each do |team|
  users.sample(11).each_with_index do |user, index|
    team.team_members << user

    membership = team.memberships.find_by user_id: user.id
    membership.update level: [:beginner, :intermediate, :advanced].sample

    if index == 0
      membership.update level: :advanced
    end
  end
end

puts "Assigining users and comments to projects"

# assign users to projects
projects.each do |project|
  users.sample(11).each do |user|
    project.users << user
  end

  rand(0..15).times do
    project.comments << FactoryBot.create(:comment, user_id: users.sample.id)
  end
end

puts "Creating courses"

# Courses and links
courses = FactoryBot.create_list(:course, 150)
courses.each do |course|
  FactoryBot.create_list(:course_link, 3, course: course)
end

puts "Creating products"

products = Product.create([
  {
    title: 'iPod',
    description: "1000 songs in your pocket",
    price: "250",
    category: "Music players",
  },
  {
    title: 'MacBook Pro',
    description: "Supercharged for pros",
    price: "2250",
    category: "Computers",
  },
  {
    title: 'Apple watch',
    description: "A heathly leap ahead",
    price: "750",
    category: "Wearables",
  },
  {
    title: 'iPhone',
    description: "A magical new way to interact with iPhone",
    price: "999",
    category: "Phones",
  },
])

['ipod.jpg', 'macbook.jpg', 'watch.jpg', 'iphone.jpg'].each_with_index do |img, index|
  file = Rails.root.join('db', 'seed_files', img)
  products[index].image.attach io: file.open, filename: img
end
