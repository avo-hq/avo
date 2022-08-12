FactoryBot.define do
  factory :city do
    name { "MyString" }
    population { 1 }
    is_capital { false }
    features { "MyString" }
    metadata { "" }
    image_url { "MyString" }
    description { "MyText" }
    status { "MyString" }
    tiny_description { "MyText" }
  end
end
