#!/usr/bin/env ruby

# Script pour ajouter la réponse "conduit extérieure" à Q8

q8 = Question.find_by(code: "Q8")

# Vérifier si R7 existe déjà
existing_r7 = q8.answer_options.find_by(code: "R7")

if existing_r7.nil?
  AnswerOption.create!(
    question: q8,
    code: "R7",
    label: "Conduit extérieure",
    position: 7
  )
  puts "Réponse \"conduit extérieure\" (R7) ajoutée à Q8"
else
  puts "R7 existe déjà: #{existing_r7.label}"
end