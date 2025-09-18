#!/usr/bin/env ruby

# Script pour créer les nouveaux codes FHCC avec diamètres concentriques

roof_types = [
  ["MAC", "conduit maçonné", "R1"],
  ["MET", "conduit métallique", "R2"],
  ["ARDTP", "ardoise ou tuiles plates", "R4"],
  ["TUMEC", "tuiles mécaniques", "R5"],
  ["ACIER", "bac acier", "R6"],
  ["PLAT", "toit plat", "R3"]
]

count = 0

roof_types.each do |roof_code, roof_name, roof_condition|
  # Code FHCC pour raccordement 80130 -> conduit 80130
  cc_80130_code = "FHCC80130#{roof_code}"
  cc_80130_condition = "Q5=R4 AND Q7=R8 AND Q8=#{roof_condition} AND Q3=R6"

  ProductKit.create!(
    category: "finition",
    code: cc_80130_code,
    name: "Finition haute CC 80130mm #{roof_name}",
    condition_expression: cc_80130_condition,
    price: rand(100..300),
    stock: rand(10..40),
    active: true
  )

  # Code FHCC pour raccordement 100150 -> conduit 100150
  cc_100150_code = "FHCC100150#{roof_code}"
  cc_100150_condition = "Q5=R4 AND Q7=R9 AND Q8=#{roof_condition} AND Q3=R7"

  ProductKit.create!(
    category: "finition",
    code: cc_100150_code,
    name: "Finition haute CC 100150mm #{roof_name}",
    condition_expression: cc_100150_condition,
    price: rand(100..300),
    stock: rand(10..40),
    active: true
  )

  count += 2
end

puts "#{count} nouveaux codes FHCC créés"