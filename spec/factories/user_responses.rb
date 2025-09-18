FactoryBot.define do
  factory :user_response do
    questionnaire_session { nil }
    question { nil }
    answer { "MyText" }
    answer_code { "MyString" }
    answered_at { "2025-09-18 01:37:18" }
  end
end
