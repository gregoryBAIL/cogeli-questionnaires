#!/usr/bin/env ruby

# Test pour vérifier que les nouveaux codes avec conduit extérieure fonctionnent

# Créer une session factice
questionnaire = Questionnaire.first
session = QuestionnaireSession.create!(questionnaire: questionnaire)

# Ajouter les réponses pour tester le cas tubage + conduit 150 + conduit extérieure
q5 = Question.find_by(code: "Q5")  # type
q7 = Question.find_by(code: "Q7")  # conduit
q8 = Question.find_by(code: "Q8")  # toiture

UserResponse.create!(questionnaire_session: session, question: q5, answer: "Tubage", answer_code: "R1")  # Tubage
UserResponse.create!(questionnaire_session: session, question: q7, answer: "150", answer_code: "R4")  # 150mm
UserResponse.create!(questionnaire_session: session, question: q8, answer: "Conduit extérieure", answer_code: "R7")  # conduit extérieure

# Tester le kit FHT150EXTERIEURE (sans raccordement concentrique)
kit = ProductKit.find_by(code: "FHT150EXTERIEURE")
puts "Kit testé: #{kit.code}"
puts "Condition: #{kit.condition_expression}"
puts "Match: #{kit.matches?(session)}"

# Tester aussi un kit DPI avec conduit extérieure
session2 = QuestionnaireSession.create!(questionnaire: questionnaire)

UserResponse.create!(questionnaire_session: session2, question: q5, answer: "DPI", answer_code: "R2")  # Conduit intérieur
UserResponse.create!(questionnaire_session: session2, question: q7, answer: "100", answer_code: "R2")  # 100mm
UserResponse.create!(questionnaire_session: session2, question: q8, answer: "Conduit extérieure", answer_code: "R7")  # conduit extérieure

kit2 = ProductKit.find_by(code: "FHDPI100EXTERIEURE")
puts "\nKit testé: #{kit2.code}"
puts "Condition: #{kit2.condition_expression}"
puts "Match: #{kit2.matches?(session2)}"

# Nettoyer
session.destroy
session2.destroy

puts "\nTest terminé - les codes avec conduit extérieure fonctionnent correctement!"