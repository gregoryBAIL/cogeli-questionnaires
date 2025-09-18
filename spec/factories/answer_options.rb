FactoryBot.define do
  factory :answer_option do
    question { nil }
    code { "MyString" }
    label { "MyString" }
    value { "MyString" }
    position { 1 }
    metadata { "" }
  end
end
