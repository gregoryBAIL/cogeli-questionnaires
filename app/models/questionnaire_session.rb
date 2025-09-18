class QuestionnaireSession < ApplicationRecord
  belongs_to :questionnaire
  belongs_to :current_question, class_name: 'Question', optional: true
  has_many :user_responses, dependent: :destroy
  has_one :result, dependent: :destroy

  before_validation :generate_session_token, on: :create

  validates :session_token, presence: true, uniqueness: true

  scope :active, -> { where(completed_at: nil) }
  scope :completed, -> { where.not(completed_at: nil) }

  def completed?
    completed_at.present?
  end

  def progress_percentage
    return 0 if user_responses.count == 0

    visible_questions = questionnaire.questions.select { |q| q.visible_for?(self) }
    (user_responses.count.to_f / visible_questions.count * 100).round
  end

  def answer_for(question)
    user_responses.find_by(question: question)
  end

  private

  def generate_session_token
    self.session_token ||= SecureRandom.urlsafe_base64(32)
  end
end
