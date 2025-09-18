class Condition < ApplicationRecord
  belongs_to :question
  belongs_to :target_question, class_name: 'Question'

  validates :expression, presence: true

  # Parse expressions like "Q1=R1 AND Q2=R2" or use logic JSON
  def satisfied_by?(session)
    return true if expression.blank?

    # Si nous avons un logic JSON, l'utiliser
    if logic.present? && logic.is_a?(Hash)
      return evaluate_logic_condition(session)
    end

    # Sinon, utiliser l'ancienne logique d'expression
    conditions = expression.split(' AND ')
    conditions.all? do |condition|
      if condition =~ /Q(\d+)=R(\d+)/
        question_code = "Q#{$1}"
        answer_code = "R#{$2}"

        response = session.user_responses
                         .joins(:question)
                         .find_by(questions: { code: question_code })

        response&.answer_code == answer_code
      else
        true
      end
    end
  end

  private

  def evaluate_logic_condition(session)
    # Extraire le code de question depuis l'expression (ex: "QP2=RP2,RP3,RP4,RP5")
    if expression =~ /(\w+)=/
      question_code = $1

      response = session.user_responses
                       .joins(:question)
                       .find_by(questions: { code: question_code })

      if response && logic['operator'] == 'IN'
        # L'opérateur "IN" signifie que la réponse doit être dans la liste des valeurs
        logic['values'].include?(response.answer_code)
      else
        false
      end
    else
      true
    end
  end
end
