FactoryBot.define do
  factory :user do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    email { Faker::Internet.email }
    password { Faker::Internet.password }
    roles { {admin: false, manager: [true, false].sample, writer: [true, false].sample} }
    birthday { Faker::Date.birthday(min_age: 18, max_age: 65) }
    custom_css { ".header {\n  color: red;\n}" }
  end

  factory :team do
    name { Faker::Company.name }
    description { Faker::Lorem.paragraph(sentence_count: 4) }
    url { Faker::Internet.url }
    color { Faker::Color.hex_color }
  end

  factory :post do
    name { Faker::Quote.famous_last_words }
    body { Faker::Lorem.paragraphs(number: rand(4...10)).join("\n") }
    is_featured { [true, false].sample }
    published_at do
      if [false, true].sample
        Time.now - rand(10...365).days
      end
    end
    tag_list { ["1", "2", "five", "seven"].shuffle }
    status { ::Post.statuses.keys.sample }
  end

  factory :project do
    name { Faker::App.name }
    status { ['closed', :rejected, :failed, 'loading', :running, :waiting].sample }
    stage { ["Discovery", "Idea", "Done", "On hold", "Cancelled"].sample }
    budget { Faker::Number.decimal(l_digits: 4) }
    country { Faker::Address.country_code }
    description { Faker::Markdown.sandwich(sentences: 5) }
    users_required { Faker::Number.between(from: 10, to: 100) }
    started_at { Time.now - rand(10...365).days }
    meta { [{foo: "bar", hey: "hi"}, {bar: "baz"}, {hoho: "hohoho"}].sample }
    progress { Faker::Number.between(from: 0, to: 100) }
  end

  trait :with_files do
    after(:create) do |project|
      ["watch.jpg", "dummy-video.mp4"].each do |filename|
        file = Rails.root.join("db", "seed_files", filename)
        project.files.attach(io: file.open, filename: filename)
      end

      ["dummy-file.txt", "dummy-audio.mp3"].each do |filename|
        file = Avo::Engine.root.join("spec", "dummy", filename)
        project.files.attach(io: file.open, filename: filename)
      end
    end
  end

  factory :comment do
    body { Faker::Lorem.paragraphs(number: rand(4...10)).join(" ") }
    posted_at { Time.now - rand(10...365).days }
  end

  factory :review do
    body { Faker::Lorem.paragraphs(number: rand(4...10)).join(" ") }
  end

  factory :person do
    name { "#{Faker::Name.first_name} #{Faker::Name.last_name}" }
  end

  factory :spouse do
    name { "#{Faker::Name.first_name} #{Faker::Name.last_name}" }
    type { "Spouse" }
  end

  factory :sibling do
    name { "#{Faker::Name.first_name} #{Faker::Name.last_name}" }
    type { "Sibling" }
  end

  factory :brother do
    name { "#{Faker::Name.first_name} #{Faker::Name.last_name}" }
    type { "Brother" }
  end

  factory :fish do
    name { %w[Tilapia Salmon Trout Catfish Pangasius Carp].sample }
  end

  factory :course do
    name { Faker::Educator.unique.course_name }
    skills { [Faker::Educator.subject, Faker::Educator.subject, Faker::Educator.subject, Faker::Educator.subject, Faker::Educator.subject] }
    country { Course.countries.sample }
    city { Course.cities.stringify_keys[country].sample }
    starting_at { Time.now }
  end

  factory :course_link, class: "Course::Link" do
    link { Faker::Internet.url }
    course { create :course }
  end

  factory :city do
    name { Faker::Address.city }
    population { rand(10000..999000) }
    latitude { Faker::Address.latitude }
    longitude { Faker::Address.longitude }
    is_capital { [true, false].sample }
    features { Faker::Address.community }
    metadata { Faker::Address.community }
    # image_url { "MyString" }
    description { Faker::Address.community }
    status { ["open", "closed"].sample }
    tiny_description { Faker::Address.community }
    city_center_area { [[[10.0, 11.2], [10.5, 11.9], [10.8, 12.0], [10.0, 11.2]]].to_json }
  end

  factory :product do
    title { Faker::App.name }
    description { Faker::Lorem.paragraphs(number: rand(1...3)).join("\n") }
    price { rand(10000..999000) }
    status { "status" }
    category { ::Product.categories.values.sample }
  end
end
