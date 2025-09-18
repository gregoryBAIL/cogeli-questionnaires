# Test complet avec réponse automatique pour QP9

coefficient_q = Questionnaire.find_by(slug: 'coefficient-pose')

# Créer une session avec "Tubage de conduit"
test_session = coefficient_q.questionnaire_sessions.create!(
  session_token: 'test_solin_complete_' + SecureRandom.hex(8),
  started_at: Time.current
)

# Répondre QP1 et QP2
qp1 = coefficient_q.questions.find_by(code: 'QP1')
qp2 = coefficient_q.questions.find_by(code: 'QP2')
qp9 = coefficient_q.questions.find_by(code: 'QP9')

test_session.user_responses.create!(
  question: qp1,
  answer: "Maison individuelle",
  answer_code: "RP1",
  answered_at: Time.current
)

test_session.user_responses.create!(
  question: qp2,
  answer: "Tubage de conduit",
  answer_code: "RP1",
  answered_at: Time.current
)

puts "Session créée avec QP1 et QP2 répondues"
puts "QP2 réponse: Tubage de conduit (RP1)"
puts "QP9 visible? #{qp9.visible_for?(test_session)}"

# Vérifier s'il y a déjà une réponse automatique
existing_response = test_session.user_responses.find_by(question: qp9)
puts "Réponse QP9 existante? #{existing_response ? existing_response.answer : 'Non'}"

puts "URL de test: http://localhost:3000/questions/#{qp2.id}?session_token=#{test_session.session_token}"
puts "Cliquez sur 'Continuer' sur QP2 pour tester la réponse automatique QP9"