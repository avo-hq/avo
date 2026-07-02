# Seed data for the Avo dummy app.
#
# Loaded by both:
#   bin/rails db:seed                        # standard Rails entry point
#   bin/rails app:db:fast_seed:rebuild       # also dumps a snapshot to spec/dummy/db/fast_seed/
#
# Safe to run against an existing populated DB (the cleanup block below clears
# everything first) or a fresh one (the cleanup is a no-op on empty tables).

require "securerandom"
require "faker"

# ---- Cleanup ---------------------------------------------------------------
# Wipe any prior data + Active Storage blob files so re-running db:seed
# produces a clean slate. db:fast_seed:rebuild has already drop+create+schema:load'd
# by the time we get here, so this is a no-op for that path.

ActiveStorage::Attachment.all.find_each(&:purge)

["active_storage_blobs", "active_storage_attachments", "posts", "projects",
  "projects_users", "team_memberships", "locations", "teams", "users",
  "comments", "people", "reviews", "courses", "course_links",
  "galaxy_planet_satellites", "galaxy_planets", "fish", "playgrounds"].each do |table_name|
  ActiveRecord::Base.connection.execute("TRUNCATE #{table_name} RESTART IDENTITY CASCADE")
end

# ---- Seeding ---------------------------------------------------------------

LOCAL_COVERS = %w[iphone.jpg ipod.jpg macbook.jpg watch.jpg dummy-image.jpg].freeze
SEED_FILES_DIR = Rails.root.join("db", "seed_files")

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

# Login with this one.
users.push(User.create!(
  first_name: "Avo",
  last_name: "Cado",
  email: "hi@avohq.io",
  password: ENV["AVO_ADMIN_PASSWORD"] || :secreto,
  birthday: "2020-03-28",
  roles: {
    admin: true,
    manager: false,
    writer: false
  }
))

famous_users = [
  {first_name: "David Heinemeier", last_name: "Hansson", email: "david@hey.com"},
  {first_name: "Eric", last_name: "Berry", email: "eric@berry.sh"},
  {first_name: "Vladimir", last_name: "Dementyev", email: "palkan@evilmartians.com"},
  {first_name: "Jason", last_name: "Charnes", email: "jason@jasoncharnes.com"},
  {first_name: "Andrew", last_name: "Culver", email: "andrew.culver@gmail.com"},
  {first_name: "Yaroslav", last_name: "Shmarov", email: "yashm@outlook.com"},
  {first_name: "Jason", last_name: "Swett", email: "jason@benfranklinlabs.com"},
  {first_name: 'Yukihiro "Matz"', last_name: "Matsumoto", email: "matz@ruby.or.jp"},
  {first_name: "Joe", last_name: "Masilotti", email: "joe@masilotti.com"},
  {first_name: "Lucian", last_name: "Ghinda", email: "lucian@ghinda.com"},
  {first_name: "Mike", last_name: "Perham", email: "mperham@gmail.com"},
  {first_name: "Taylor", last_name: "Otwell", email: "taylor@laravel.com"},
  {first_name: "Adam", last_name: "Watham", email: "adam@adamwathan.me"},
  {first_name: "Jeffery", last_name: "Way", email: "jeffrey@laracasts.com"},
  {first_name: "Adrian", last_name: "Marin", email: "adrian@adrianthedev.com"}
]

famous_users.reverse_each do |user|
  users.push(FactoryBot.create(:user, team_id: teams.sample.id, **user))
end

puts "Creating people"

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

puts "Creating posts (with local cover images)"

25.times do |i|
  post = FactoryBot.create(:post, user_id: users.sample.id)
  cover_filename = LOCAL_COVERS[i % LOCAL_COVERS.size]
  cover_path = SEED_FILES_DIR.join(cover_filename)
  post.cover.attach(io: cover_path.open, filename: cover_filename)

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

teams.each do |team|
  users.sample(11).each_with_index do |user, index|
    team.team_members << user

    membership = team.memberships.find_by user_id: user.id
    membership.update level: [:beginner, :intermediate, :advanced].sample
    membership.update(level: :advanced) if index == 0
  end
end

puts "Assigning users and comments to projects"

projects.each do |project|
  project.update!(user: users.sample)

  users.sample(11).each do |user|
    project.users << user
  end

  rand(0..15).times do
    project.comments << FactoryBot.create(:comment, user_id: users.sample.id)
  end
end

puts "Creating courses + links (bulk insert)"

now = Time.current
course_rows = 150.times.map do |i|
  country = Course.countries.sample
  {
    name: "#{Faker::Educator.course_name} ##{i}",
    skills: 5.times.map { Faker::Educator.subject },
    country: country,
    city: Course.cities.stringify_keys[country].sample,
    starting_at: now,
    created_at: now,
    updated_at: now
  }
end
Course.insert_all(course_rows)

course_ids = Course.pluck(:id)
link_rows = course_ids.flat_map do |course_id|
  3.times.map do
    {
      link: Faker::Internet.url,
      course_id: course_id,
      created_at: now,
      updated_at: now
    }
  end
end
Course::Link.insert_all(link_rows)

puts "Creating planets and satellites (bulk insert)"

planets_with_moons = {
  "Mercury" => [],
  "Venus" => [],
  "Earth" => ["Moon"],
  "Mars" => ["Phobos", "Deimos"],
  "Jupiter" => ["Io", "Europa", "Ganymede", "Callisto"],
  "Saturn" => ["Titan", "Enceladus", "Mimas", "Rhea", "Iapetus"],
  "Uranus" => ["Titania", "Oberon", "Miranda", "Ariel", "Umbriel"],
  "Neptune" => ["Triton", "Nereid", "Proteus"]
}

Galaxy::Planet.insert_all(
  planets_with_moons.keys.map { |name| {name: name, created_at: now, updated_at: now} }
)

planet_ids_by_name = Galaxy::Planet.where(name: planets_with_moons.keys).pluck(:name, :id).to_h
satellite_rows = planets_with_moons.flat_map do |planet_name, moons|
  moons.map { |moon| {name: moon, planet_id: planet_ids_by_name.fetch(planet_name), created_at: now, updated_at: now} }
end
Galaxy::Planet::Satellite.insert_all(satellite_rows) if satellite_rows.any?

puts "Creating products (with local image attachments)"

products = Product.create!([
  {title: "iPod", description: "1000 songs in your pocket", price: "250", category: "Music players"},
  {title: "MacBook Pro", description: "Supercharged for pros", price: "2250", category: "Computers"},
  {title: "Apple watch", description: "A heathly leap ahead", price: "750", category: "Wearables"},
  {title: "iPhone", description: "A magical new way to interact with iPhone", price: "999", category: "Phones"}
])

%w[ipod.jpg macbook.jpg watch.jpg iphone.jpg].each_with_index do |img, index|
  file = SEED_FILES_DIR.join(img)
  products[index].image.attach(io: file.open, filename: img)
end

puts "Creating cities (bulk insert)"

city_rows = [
  {name: "New York", latitude: 40.7128, longitude: -74.0060, population: 8_400_000},
  {name: "Barcelona", latitude: 41.3851, longitude: 2.1734, population: 1_600_000},
  {name: "Bucharest", latitude: 44.4268, longitude: 26.1025, population: 1_800_000},
  {name: "Hong Kong", latitude: 22.3193, longitude: 114.1694, population: 7_500_000},
  {name: "Tokyo", latitude: 35.6762, longitude: 139.6503, population: 13_900_000},
  {name: "London", latitude: 51.5074, longitude: -0.1278, population: 9_000_000},
  {name: "Paris", latitude: 48.8566, longitude: 2.3522, population: 2_100_000},
  {name: "Berlin", latitude: 52.5200, longitude: 13.4050, population: 3_700_000},
  {name: "Rome", latitude: 41.9028, longitude: 12.4964, population: 2_800_000},
  {name: "Madrid", latitude: 40.4168, longitude: -3.7038, population: 3_200_000},
  {name: "Amsterdam", latitude: 52.3676, longitude: 4.9041, population: 900_000},
  {name: "Sydney", latitude: -33.8688, longitude: 151.2093, population: 5_300_000},
  {name: "Melbourne", latitude: -37.8136, longitude: 144.9631, population: 5_000_000},
  {name: "Singapore", latitude: 1.3521, longitude: 103.8198, population: 5_700_000},
  {name: "Dubai", latitude: 25.2048, longitude: 55.2708, population: 3_400_000},
  {name: "Mumbai", latitude: 19.0760, longitude: 72.8777, population: 20_400_000},
  {name: "São Paulo", latitude: -23.5505, longitude: -46.6333, population: 12_300_000},
  {name: "Mexico City", latitude: 19.4326, longitude: -99.1332, population: 9_200_000},
  {name: "Los Angeles", latitude: 34.0522, longitude: -118.2437, population: 4_000_000},
  {name: "Chicago", latitude: 41.8781, longitude: -87.6298, population: 2_700_000},
  {name: "Toronto", latitude: 43.6532, longitude: -79.3832, population: 2_900_000},
  {name: "Vancouver", latitude: 49.2827, longitude: -123.1207, population: 675_000},
  {name: "Stockholm", latitude: 59.3293, longitude: 18.0686, population: 975_000},
  {name: "Copenhagen", latitude: 55.6761, longitude: 12.5683, population: 800_000},
  {name: "Vienna", latitude: 48.2082, longitude: 16.3738, population: 1_900_000},
  {name: "Zurich", latitude: 47.3769, longitude: 8.5417, population: 420_000},
  {name: "Seoul", latitude: 37.5665, longitude: 126.9780, population: 9_700_000}
].map { |row| row.merge(created_at: now, updated_at: now) }

City.insert_all(city_rows)

puts "Creating store, location, event"

store = Store.create!(name: "Apple Store Prime", size: "large")

location = Location.create!(
  team: Team.find_by(name: "Apple"),
  store: store,
  name: "Apple Park - Barbecue Area",
  address: "1 Orchard Street, 12345 New York",
  size: "medium"
)

Event.create!(
  location: location,
  name: "M3 release celebration",
  event_time: DateTime.new(2023, 11, 11, 11, 11, 11),
  body: "We're celebrating the release of the new M3 chip!"
)

puts "Creating playground"

Playground.create!(
  name: "All fields playground",
  text_value: "Short text example",
  textarea_value: "Longer text area content",
  code_value: "def greet\n  'Hello from Avo'\nend",
  boolean_value: true,
  number_value: 42,
  date_value: Date.current,
  time_value: Time.zone.now.change(sec: 0),
  date_time_value: Time.zone.now.change(sec: 0),
  country_value: "US",
  hidden_token: SecureRandom.hex(4),
  password_value: "super-secret",
  select_value: "review",
  multi_select_values: %w[feature_flags automation],
  radio_value: "high",
  badge_value: "published",
  status_value: "processing",
  stars_value: 4,
  progress_value: 72,
  tags_values: %w[avo rails showcase],
  boolean_group_values: {
    email_alerts: true,
    sms_alerts: false,
    weekly_digest: true
  },
  key_value_data: {
    env: "development",
    visibility: "public"
  },
  external_image_url: "https://picsum.photos/400/240",
  gravatar_email: "avo@avohq.io",
  easy_mde_content: "## EasyMDE content",
  tiptap_content: "<p>Tiptap content</p>",
  latitude: 37.7749,
  longitude: -122.4194,
  area_coordinates: [
    [
      [-122.423, 37.778],
      [-122.415, 37.778],
      [-122.415, 37.772],
      [-122.423, 37.772],
      [-122.423, 37.778]
    ]
  ],
  array_values: ["alpha", "beta", "gamma"]
)

puts "Seeding complete"
