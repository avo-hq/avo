FactoryBot.define do
  factory :user do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    email { Faker::Internet.email }
    password { Faker::Internet.password }
    roles { { admin: false, manager: [true, false].sample, writer: [true, false].sample } }
    birthday { Faker::Date.birthday(min_age: 18, max_age: 65) }
    custom_css { ".header {\n  color: red;\n}" }
  end

  factory :team do
    name { Faker::Company.name }
    description { Faker::Lorem.paragraph(sentence_count: 4) }
  end

  factory :post do
    name { Faker::Quote.famous_last_words }
    body { Faker::Lorem.paragraphs(number: rand(4...10)).join("\n") }
    is_featured { [true, false].sample }
    published_at { Time.now - rand(10...365).days }
  end

  factory :project do
    name { Faker::Hacker.say_something_smart }
    status { [:closed, :rejected, :failed, :loading, :running, :waiting].sample }
    stage { ['Discovery', 'Ideea', 'Done', 'On hold', 'Cancelled'].sample }
    budget { Faker::Number.decimal(l_digits: 4) }
    country { Faker::Address.country_code }
    users_required { Faker::Number.between(from: 10, to: 100) }
    started_at { Time.now - rand(10...365).days }
    meta { [{ foo: 'bar', hey: 'hi' }, { bar: 'baz' }, { hoho: 'hohoho' }].sample }
  end
end
