#!/usr/bin/env ruby

# Script pour créer les codes FH avec conduit extérieure

work_types = [["T", "Tubage"], ["DPI", "Conduit intérieur"], ["CC", "Conduit concentrique"]]
diameters = ["80", "100", "130", "150", "180", "200", "250"]

count = 0

work_types.each do |type_code, type_name|
  next if type_code == "DPE"  # DPE a sa logique spéciale sans toiture

  diameters.each do |diam_conduit|
    # Conditions de base
    type_condition = case type_code
    when "T" then "Q5=R1"
    when "DPI" then "Q5=R2"
    when "CC" then "Q5=R4"
    end

    diam_conduit_condition = case diam_conduit
    when "80" then "Q7=R1"
    when "100" then "Q7=R2"
    when "130" then "Q7=R3"
    when "150" then "Q7=R4"
    when "180" then "Q7=R5"
    when "200" then "Q7=R6"
    when "250" then "Q7=R7"
    end

    # Code FH avec conduit extérieure
    if type_code == "T"
      # Pour tubage: code CC si raccordement concentrique, sinon code normal
      cc_fh_code = "FH#{type_code}#{diam_conduit}EXTERIEURECC"
      cc_condition = "#{type_condition} AND #{diam_conduit_condition} AND Q8=R7 AND (Q3=R6 OR Q3=R7)"

      ProductKit.create!(
        category: "finition",
        code: cc_fh_code,
        name: "Finition haute #{type_name} #{diam_conduit}mm conduit extérieure CC",
        condition_expression: cc_condition,
        price: rand(100..300),
        stock: rand(10..40),
        active: true
      )

      # Code normal pour tubage (sans raccordement concentrique)
      normal_fh_code = "FH#{type_code}#{diam_conduit}EXTERIEURE"
      normal_condition = "#{type_condition} AND #{diam_conduit_condition} AND Q8=R7 AND NOT (Q3=R6 OR Q3=R7)"

      ProductKit.create!(
        category: "finition",
        code: normal_fh_code,
        name: "Finition haute #{type_name} #{diam_conduit}mm conduit extérieure",
        condition_expression: normal_condition,
        price: rand(100..300),
        stock: rand(10..40),
        active: true
      )

      count += 2
    elsif type_code == "CC"
      # Pour CC: logique spéciale avec diamètres concentriques
      # Code FHCC pour raccordement 80130 -> conduit 80130
      if ["80", "100", "130", "150"].include?(diam_conduit)
        cc_80130_code = "FH#{type_code}80130EXTERIEURE"
        cc_80130_condition = "#{type_condition} AND Q7=R8 AND Q8=R7 AND Q3=R6"

        ProductKit.create!(
          category: "finition",
          code: cc_80130_code,
          name: "Finition haute #{type_name} 80130mm conduit extérieure",
          condition_expression: cc_80130_condition,
          price: rand(100..300),
          stock: rand(10..40),
          active: true
        )

        # Code FHCC pour raccordement 100150 -> conduit 100150
        cc_100150_code = "FH#{type_code}100150EXTERIEURE"
        cc_100150_condition = "#{type_condition} AND Q7=R9 AND Q8=R7 AND Q3=R7"

        ProductKit.create!(
          category: "finition",
          code: cc_100150_code,
          name: "Finition haute #{type_name} 100150mm conduit extérieure",
          condition_expression: cc_100150_condition,
          price: rand(100..300),
          stock: rand(10..40),
          active: true
        )

        count += 2
        break  # On génère seulement une fois pour CC
      end
    else
      # Pour DPI: code normal
      normal_fh_code = "FH#{type_code}#{diam_conduit}EXTERIEURE"
      normal_condition = "#{type_condition} AND #{diam_conduit_condition} AND Q8=R7"

      ProductKit.create!(
        category: "finition",
        code: normal_fh_code,
        name: "Finition haute #{type_name} #{diam_conduit}mm conduit extérieure",
        condition_expression: normal_condition,
        price: rand(100..300),
        stock: rand(10..40),
        active: true
      )

      count += 1
    end
  end
end

puts "#{count} nouveaux codes FH avec conduit extérieure créés"