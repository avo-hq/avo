FactoryBot.define do
  factory :product do
    title { "MyString" }
    description { "MyText" }
    price { 1 }
    status { "MyString" }
    category { "MyString" }
  end
end
