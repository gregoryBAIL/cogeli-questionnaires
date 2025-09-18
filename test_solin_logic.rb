# Test de la logique conditionnelle pour QP9 (Type de solin)

coefficient_q = Questionnaire.find_by(slug: 'coefficient-pose')

# Nettoyer les anciennes sessions de test
old_sessions = QuestionnaireSession.where("session_token LIKE 'test_%'")
puts "Suppression de #{old_sessions.count} anciennes sessions de test"
old_sessions.destroy_all

# Test 1: Avec "Tubage de conduit" (RP1) - QP9 ne doit PAS apparaître
puts "\n=== Test 1: Tubage de conduit (QP9 ne doit pas apparaître) ==="

test_session1 = coefficient_q.questionnaire_sessions.create!(
  session_token: 'test_solin_tubage_' + SecureRandom.hex(6),
  started_at: Time.current
)

# Répondre QP2 avec "Tubage de conduit" (RP1)
qp2 = coefficient_q.questions.find_by(code: 'QP2')
qp9 = coefficient_q.questions.find_by(code: 'QP9')

test_session1.user_responses.create!(
  question: qp2,
  answer: "Tubage de conduit",
  answer_code: "RP1",
  answered_at: Time.current
)

puts "QP2 répondu avec: Tubage de conduit"
puts "QP9 visible? #{qp9.visible_for?(test_session1)}"

# Test 2: Avec "Ventouse" (RP6) - QP9 ne doit PAS apparaître
puts "\n=== Test 2: Ventouse (QP9 ne doit pas apparaître) ==="

test_session2 = coefficient_q.questionnaire_sessions.create!(
  session_token: 'test_solin_ventouse_' + SecureRandom.hex(6),
  started_at: Time.current
)

test_session2.user_responses.create!(
  question: qp2,
  answer: "Ventouse",
  answer_code: "RP6",
  answered_at: Time.current
)

puts "QP2 répondu avec: Ventouse"
puts "QP9 visible? #{qp9.visible_for?(test_session2)}"

# Test 3: Avec "Création concentrique" (RP2) - QP9 DOIT apparaître
puts "\n=== Test 3: Création concentrique (QP9 doit apparaître) ==="

test_session3 = coefficient_q.questionnaire_sessions.create!(
  session_token: 'test_solin_creation_' + SecureRandom.hex(6),
  started_at: Time.current
)

test_session3.user_responses.create!(
  question: qp2,
  answer: "Création concentrique < 4m",
  answer_code: "RP2",
  answered_at: Time.current
)

puts "QP2 répondu avec: Création concentrique < 4m"
puts "QP9 visible? #{qp9.visible_for?(test_session3)}"

puts "\nSessions de test créées:"
puts "Test 1 (Tubage): http://localhost:3000/questions/#{qp2.id}?session_token=#{test_session1.session_token}"
puts "Test 2 (Ventouse): http://localhost:3000/questions/#{qp2.id}?session_token=#{test_session2.session_token}"
puts "Test 3 (Création): http://localhost:3000/questions/#{qp2.id}?session_token=#{test_session3.session_token}"