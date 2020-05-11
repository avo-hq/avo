FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    email { Faker::Internet.email }
    password { Faker::Internet.password }
    age { rand(18...50) }
    height { Faker::Number.decimal(l_digits: 2, r_digits: 2) }
    currency { 'USD' }
    country { Faker::Address.country }
    timezone { 'Romania' }
    availability { Faker::Boolean.boolean }
    description { Faker::Lorem.paragraphs(number: 2) }
    bio { "<strong>#{Faker::Lorem.paragraphs(number: 5)}<strong>" }
    story { Faker::Markdown.sandwich(sentences: 5) }
    custom_css { ".header {\n  color: red;\n}" }
    meta { {foo: 'bar', hey: 'hi'} }
    roles { {admin: true, manager: false } }
    tags { Faker::Marketing.buzzwords.split(' ') }
    starts_on { Time.now - rand(10...365).days }
  end

  factory :group do
    name { 'Users' }
  end

  factory :post do
    name { Faker::Quote.famous_last_words }
    body { Faker::Lorem.paragraphs(number: rand(4...10)).join("\n") }
    published_at { Time.now - rand(10...365).days }
  end

  factory :project do
    name { Faker::Hacker.say_something_smart }
  end
end