FactoryBot.define do
  factory :product_kit do
    category { "MyString" }
    code { "MyString" }
    name { "MyString" }
    description { "MyText" }
    condition_expression { "MyText" }
    price { "9.99" }
    stock { 1 }
    active { false }
    metadata { "" }
  end
end
