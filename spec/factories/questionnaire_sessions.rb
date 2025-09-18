FactoryBot.define do
  factory :questionnaire_session do
    session_token { "MyString" }
    questionnaire { nil }
    current_question { nil }
    started_at { "2025-09-18 01:37:14" }
    completed_at { "2025-09-18 01:37:14" }
    ip_address { "MyString" }
    user_agent { "MyString" }
    metadata { "" }
  end
end
