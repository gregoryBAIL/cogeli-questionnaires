class Questionnaire < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged

  has_many :questions, -> { order(:position) }, dependent: :destroy
  has_many :questionnaire_sessions, dependent: :destroy

  acts_as_list

  validates :name, presence: true, uniqueness: true

  scope :active, -> { where(active: true) }

  def first_question
    questions.first
  end

  def pages
    questions.pluck(:page_name).uniq.compact
  end
end
