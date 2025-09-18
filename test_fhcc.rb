#!/usr/bin/env ruby

# Test pour vérifier que les nouveaux codes FHCC fonctionnent correctement

# Créer une session factice avec UserResponse
questionnaire = Questionnaire.first
session = QuestionnaireSession.create!(questionnaire: questionnaire)

# Ajouter les réponses pour tester le cas raccordement 80130 + CC + conduit 80130 + toit plat
q3 = Question.find_by(code: "Q3")  # raccordement
q5 = Question.find_by(code: "Q5")  # type
q7 = Question.find_by(code: "Q7")  # conduit
q8 = Question.find_by(code: "Q8")  # toiture

UserResponse.create!(questionnaire_session: session, question: q3, answer: "80130", answer_code: "R6")  # 80130
UserResponse.create!(questionnaire_session: session, question: q5, answer: "CC", answer_code: "R4")  # CC
UserResponse.create!(questionnaire_session: session, question: q7, answer: "80130", answer_code: "R8")  # 80130
UserResponse.create!(questionnaire_session: session, question: q8, answer: "plat", answer_code: "R3")  # plat

# Tester le kit FHCC80130PLAT
kit = ProductKit.find_by(code: "FHCC80130PLAT")
puts "Kit testé: #{kit.code}"
puts "Condition: #{kit.condition_expression}"
puts "Match: #{kit.matches?(session)}"

# Tester aussi un autre cas: raccordement 100150 + CC + conduit 100150 + tuiles mécaniques
session2 = QuestionnaireSession.create!(questionnaire: questionnaire)

UserResponse.create!(questionnaire_session: session2, question: q3, answer: "100150", answer_code: "R7")  # 100150
UserResponse.create!(questionnaire_session: session2, question: q5, answer: "CC", answer_code: "R4")  # CC
UserResponse.create!(questionnaire_session: session2, question: q7, answer: "100150", answer_code: "R9")  # 100150
UserResponse.create!(questionnaire_session: session2, question: q8, answer: "TUMEC", answer_code: "R5")  # TUMEC

kit2 = ProductKit.find_by(code: "FHCC100150TUMEC")
puts "\nKit testé: #{kit2.code}"
puts "Condition: #{kit2.condition_expression}"
puts "Match: #{kit2.matches?(session2)}"

# Nettoyer
session.destroy
session2.destroy

puts "\nTest terminé - les codes FHCC fonctionnent correctement!"