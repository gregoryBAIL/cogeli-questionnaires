class UserResponse < ApplicationRecord
  belongs_to :questionnaire_session
  belongs_to :question

  validates :answer, presence: true
end
