# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
require 'open-uri'

Post.delete_all
Project.delete_all
Team.delete_all
User.delete_all
TeamMembership.delete_all
ActiveStorage::Attachment.all.each { |attachment| attachment.purge }

teams = []
teams.push(FactoryBot.create(:team, name: 'Apple'))
teams.push(FactoryBot.create(:team, name: 'Google'))
teams.push(FactoryBot.create(:team, name: 'Facebook'))
teams.push(FactoryBot.create(:team, name: 'Amazon'))

users = []
38.times do
  users.push(FactoryBot.create(:user, team_id: teams.sample.id))
end

25.times do
  post = FactoryBot.create(:post, user_id: users.sample.id)

  post.cover_photo.attach(io: open("https://source.unsplash.com/random/#{[1000, 1100, 1200, 1300].sample}x#{[1000, 1100, 1200, 1300].sample}"), filename: 'cover.jpg')
end

projects = []
30.times do
  projects.push(FactoryBot.create(:project))
end

# assign users to teams
teams.each do |team|
  users.shuffle[0..10].each_with_index do |user, index|
    team.members << user

    membership = team.memberships.find_by user_id: user.id
    membership.update level: [:beginner, :intermediate, :advanced].sample

    if index == 0
      membership.update level: :admin
    end
  end
end

# assign users to projects
projects.each do |project|
  users.shuffle[0..10].each do |user|
    project.users << user
  end
end
