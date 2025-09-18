FactoryBot.define do
  factory :question do
    questionnaire { nil }
    code { "MyString" }
    title { "MyString" }
    description { "MyText" }
    question_type { "MyString" }
    page_name { "MyString" }
    position { 1 }
    required { false }
    conditional { false }
    metadata { "" }
  end
end
