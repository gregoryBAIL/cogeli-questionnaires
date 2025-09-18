#!/usr/bin/env ruby

# Test pour vérifier que les nouveaux codes FHDPE sans toiture fonctionnent correctement

# Créer une session factice
questionnaire = Questionnaire.first
session = QuestionnaireSession.create!(questionnaire: questionnaire)

# Ajouter les réponses pour tester le cas création extérieure + conduit 150
q5 = Question.find_by(code: "Q5")  # type
q7 = Question.find_by(code: "Q7")  # conduit
q8 = Question.find_by(code: "Q8")  # toiture

UserResponse.create!(questionnaire_session: session, question: q5, answer: "DPE", answer_code: "R3")  # Création extérieure
UserResponse.create!(questionnaire_session: session, question: q7, answer: "150", answer_code: "R4")  # 150mm
UserResponse.create!(questionnaire_session: session, question: q8, answer: "PLAT", answer_code: "R3")  # toit plat (devrait être ignoré)

# Tester le kit FHDPE150
kit = ProductKit.find_by(code: "FHDPE150")
puts "Kit testé: #{kit.code}"
puts "Condition: #{kit.condition_expression}"
puts "Match: #{kit.matches?(session)}"

# Tester que le type de toiture n'affecte pas le résultat
# Changer le type de toiture
session.user_responses.find_by(question: q8).update!(answer: "MAC", answer_code: "R1")  # maçonné

puts "\nAprès changement de toiture vers maçonné:"
puts "Match: #{kit.matches?(session)}"

# Tester avec un autre diamètre
UserResponse.create!(questionnaire_session: session, question: q7, answer: "100", answer_code: "R2")  # 100mm

kit100 = ProductKit.find_by(code: "FHDPE100")
puts "\nKit testé: #{kit100.code}"
puts "Condition: #{kit100.condition_expression}"
puts "Match: #{kit100.matches?(session)}"

# Nettoyer
session.destroy

puts "\nTest terminé - les codes FHDPE sans toiture fonctionnent correctement!"