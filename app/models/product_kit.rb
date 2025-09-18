class ProductKit < ApplicationRecord
  validates :code, presence: true, uniqueness: true
  validates :name, presence: true
  validates :category, inclusion: {
    in: %w[raccordement conduit liaison finition kit_ventouse option]
  }

  scope :active, -> { where(active: true) }
  scope :by_category, ->(cat) { where(category: cat) }

  # Évalue si ce kit correspond aux réponses
  def matches?(session)
    return false if condition_expression.blank?

    evaluate_condition(condition_expression, session)
  end

  private

  def evaluate_condition(expression, session)
    # Nettoyer l'expression
    expr = expression.strip

    # Gérer NOT en priorité
    if expr.start_with?('NOT ')
      inner_expr = expr.sub(/^NOT\s+/, '').strip
      # Enlever les parenthèses si présentes
      inner_expr = inner_expr.gsub(/^\(|\)$/, '').strip
      return !evaluate_condition(inner_expr, session)
    end

    # Enlever les parenthèses extérieures seulement si elles encapsulent toute l'expression
    while expr.start_with?('(') && expr.end_with?(')') && balanced_parentheses?(expr[1..-2])
      expr = expr[1..-2].strip
    end

    # Gérer les expressions avec AND (priorité plus haute que OR)
    if expr.include?(' AND ')
      parts = split_by_operator(expr, ' AND ')
      return parts.all? { |part| evaluate_condition(part.strip, session) }
    end

    # Gérer les expressions avec OR
    if expr.include?(' OR ')
      parts = split_by_operator(expr, ' OR ')
      return parts.any? { |part| evaluate_condition(part.strip, session) }
    end

    # Évaluer une condition simple Q#=R#
    if expr =~ /^Q(\d+)=R(\d+)$/
      question_code = "Q#{$1}"
      answer_code = "R#{$2}"

      response = session.user_responses
                       .joins(:question)
                       .find_by(questions: { code: question_code })

      return response&.answer_code == answer_code
    end

    # Si on arrive ici, condition inconnue
    Rails.logger.warn("Condition inconnue: #{expr}")
    true
  end

  def balanced_parentheses?(expr)
    count = 0
    expr.each_char do |char|
      case char
      when '('
        count += 1
      when ')'
        count -= 1
        return false if count < 0
      end
    end
    count == 0
  end

  def split_by_operator(expression, operator)
    parts = []
    current_part = ""
    paren_count = 0
    i = 0

    while i < expression.length
      char = expression[i]

      if char == '('
        paren_count += 1
        current_part += char
      elsif char == ')'
        paren_count -= 1
        current_part += char
      elsif paren_count == 0 && expression[i..i+operator.length-1] == operator
        parts << current_part.strip
        current_part = ""
        i += operator.length - 1
      else
        current_part += char
      end

      i += 1
    end

    parts << current_part.strip if current_part.present?
    parts
  end

  def self.find_matches_for(session)
    active.select { |kit| kit.matches?(session) }
  end
end
