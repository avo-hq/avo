# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

Group.delete_all
Post.delete_all
Project.delete_all
User.delete_all

groups = []
groups.push(FactoryBot.create(:group, name: 'Workers'))
groups.push(FactoryBot.create(:group, name: 'Managers'))
groups.push(FactoryBot.create(:group, name: 'Executives'))

users = []
26.times do
  users.push(FactoryBot.create(:user, group_id: groups.sample.id))
end

19.times do
  FactoryBot.create(:post, user_id: users.sample.id)
end

99.times do
  project = FactoryBot.create(:project)
  rand(1...9).times do
    project.users << users.sample
  end
  project.save
end