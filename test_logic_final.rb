#!/usr/bin/env ruby

# Test final pour vérifier la logique avec conduit extérieur

# Créer une session factice
questionnaire = Questionnaire.first
session = QuestionnaireSession.create!(questionnaire: questionnaire)

q5 = Question.find_by(code: "Q5")  # type
q7 = Question.find_by(code: "Q7")  # conduit
q8 = Question.find_by(code: "Q8")  # toiture

# Test 1: Création extérieure + diamètre 150 => doit donner FHDPE150
UserResponse.create!(questionnaire_session: session, question: q5, answer: "DPE", answer_code: "R3")  # Création extérieure
UserResponse.create!(questionnaire_session: session, question: q7, answer: "150", answer_code: "R4")  # 150mm
UserResponse.create!(questionnaire_session: session, question: q8, answer: "Conduit extérieure", answer_code: "R7")  # conduit extérieure

kit_dpe = ProductKit.find_by(code: "FHDPE150")
puts "=== Test DPE + conduit extérieur ==="
puts "Kit FHDPE150 trouvé: #{kit_dpe.present?}"
if kit_dpe
  puts "Condition: #{kit_dpe.condition_expression}"
  puts "Match: #{kit_dpe.matches?(session)}"
end

# Vérifier qu'aucun code FH avec EXTERIEURE n'existe
codes_exterieure = ProductKit.where("code LIKE ?", "%EXTERIEURE%").count
puts "\nCodes FH avec EXTERIEURE: #{codes_exterieure} (doit être 0)"

# Vérifier que R7 existe bien dans Q8
r7_exists = Question.find_by(code: "Q8").answer_options.exists?(code: "R7")
puts "R7 'Conduit extérieure' existe dans Q8: #{r7_exists}"

# Test 2: Autres types avec conduit extérieur => ne doivent rien donner
session2 = QuestionnaireSession.create!(questionnaire: questionnaire)

UserResponse.create!(questionnaire_session: session2, question: q5, answer: "Tubage", answer_code: "R1")  # Tubage
UserResponse.create!(questionnaire_session: session2, question: q7, answer: "150", answer_code: "R4")  # 150mm
UserResponse.create!(questionnaire_session: session2, question: q8, answer: "Conduit extérieure", answer_code: "R7")  # conduit extérieure

matching_kits = ProductKit.active.select { |kit| kit.matches?(session2) }
fh_matching = matching_kits.select { |kit| kit.code.start_with?("FH") }

puts "\n=== Test Tubage + conduit extérieur ==="
puts "Kits FH qui matchent: #{fh_matching.count} (doit être 0)"
fh_matching.each { |kit| puts "- #{kit.code}" }

# Nettoyer
session.destroy
session2.destroy

puts "\nTest terminé !"