#!/usr/bin/env ruby

# Script pour créer les nouveaux codes FHDPE sans toiture pour création extérieure

diameters = [
  ["80", "Q7=R1"],
  ["100", "Q7=R2"],
  ["130", "Q7=R3"],
  ["150", "Q7=R4"],
  ["180", "Q7=R5"],
  ["200", "Q7=R6"],
  ["250", "Q7=R7"]
]

count = 0

diameters.each do |diam, diam_condition|
  # Code FHDPE pour création extérieure sans toiture
  fhdpe_code = "FHDPE#{diam}"
  fhdpe_condition = "Q5=R3 AND #{diam_condition}"

  ProductKit.create!(
    category: "finition",
    code: fhdpe_code,
    name: "Finition haute Création de conduit extérieur #{diam}mm",
    condition_expression: fhdpe_condition,
    price: rand(100..300),
    stock: rand(10..40),
    active: true
  )

  count += 1
end

puts "#{count} nouveaux codes FHDPE créés"