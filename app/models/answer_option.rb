class AnswerOption < ApplicationRecord
  belongs_to :question
  acts_as_list scope: :question

  validates :code, presence: true
  validates :label, presence: true
end
