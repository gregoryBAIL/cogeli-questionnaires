class Result < ApplicationRecord
  belongs_to :questionnaire_session

  validates :product_kits, presence: true
  validates :generated_at, presence: true
end
