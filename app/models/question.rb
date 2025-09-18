class Question < ApplicationRecord
  belongs_to :questionnaire
  has_many :answer_options, -> { order(:position) }, dependent: :destroy
  has_many :conditions, dependent: :destroy
  has_many :dependent_conditions,
           class_name: 'Condition',
           foreign_key: 'target_question_id',
           dependent: :destroy
  has_many :user_responses, dependent: :destroy

  acts_as_list scope: :questionnaire

  validates :code, presence: true, uniqueness: true
  validates :title, presence: true
  validates :question_type, inclusion: {
    in: %w[single_choice multiple_choice text_input number_input]
  }

  scope :on_page, ->(page) { where(page_name: page) }
  scope :required, -> { where(required: true) }
  scope :conditional, -> { where(conditional: true) }

  def visible_for?(session)
    return true unless conditional

    dependent_conditions.all? do |condition|
      condition.satisfied_by?(session)
    end
  end

  def next_question_for(session)
    questionnaire.questions
                .where('position > ?', position)
                .find { |q| q.visible_for?(session) }
  end
end
