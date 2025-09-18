FactoryBot.define do
  factory :questionnaire do
    name { "MyString" }
    slug { "MyString" }
    description { "MyText" }
    active { false }
    position { 1 }
    settings { "" }
  end
end
