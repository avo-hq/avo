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

Post.delete_all
Project.delete_all
TeamMembership.delete_all
Team.delete_all
User.delete_all
ActiveStorage::Attachment.all.each { |attachment| attachment.purge }
["active_storage_blobs", "active_storage_attachments", "posts", "projects", "projects_users", "team_memberships", "teams", "users"].each do |table_name|
  ActiveRecord::Base.connection.execute("TRUNCATE #{table_name} RESTART IDENTITY CASCADE")
end

teams = []
teams.push(FactoryBot.create(:team, name: "Apple", url: "https://apple.com"))
teams.push(FactoryBot.create(:team, name: "Google", url: "https://google.com"))
teams.push(FactoryBot.create(:team, name: "Facebook", url: "https://facebook.com"))
teams.push(FactoryBot.create(:team, name: "Amazon", url: "https://amazon.com"))

User.create(
  first_name: "Avo",
  last_name: "Cado",
  email: "avo@avohq.io",
  password: (ENV["AVO_ADMIN_PASSWORD"] || SecureRandom.hex),
  birthday: "2020-03-28",
  roles: {
    admin: true,
    manager: false,
    writer: false
  }
)

users = []
38.times do
  users.push(FactoryBot.create(:user, team_id: teams.sample.id))
end

25.times do
  post = FactoryBot.create(:post, user_id: users.sample.id)

  post.cover_photo.attach(io: URI.open("https://source.unsplash.com/random/#{[1000, 1100, 1200, 1300].sample}x#{[1000, 1100, 1200, 1300].sample}"), filename: "cover.jpg")
end

projects = []
30.times do
  projects.push(FactoryBot.create(:project))
end

# assign users to teams
teams.each do |team|
  users.sample(11).each_with_index do |user, index|
    team.members << user

    membership = team.memberships.find_by user_id: user.id
    membership.update level: [:beginner, :intermediate, :advanced].sample

    if index == 0
      membership.update level: :advanced
    end
  end
end

# assign users to projects
projects.each do |project|
  users.sample(11).each do |user|
    project.users << user
  end
end
