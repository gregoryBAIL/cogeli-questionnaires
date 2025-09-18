FactoryBot.define do
  factory :result do
    questionnaire_session { nil }
    product_kits { "" }
    generated_at { "2025-09-18 01:37:26" }
    sent_by_email { false }
    email { "MyString" }
  end
end
