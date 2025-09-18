puts "🌱 Seeding database..."

# Check if data already exists
if Questionnaire.count > 0
  puts "⚠️  Database already seeded (#{Questionnaire.count} questionnaires found)"
  puts "✅ Skipping seed - data already exists"
  exit 0
end

# Clear existing data
Result.destroy_all
UserResponse.destroy_all
QuestionnaireSession.destroy_all
ProductKit.destroy_all
Condition.destroy_all
AnswerOption.destroy_all
Question.destroy_all
Questionnaire.destroy_all

# Créer le questionnaire Fumisterie
fumisterie = Questionnaire.create!(
  name: "Fumisterie",
  description: "Configuration de kits de fumisterie pour installation de poêles et conduits",
  active: true,
  position: 1
)

# Créer les questions
q1 = fumisterie.questions.create!(
  code: "Q1",
  title: "Sortie du poêle",
  question_type: "single_choice",
  page_name: "Le raccordement",
  position: 1,
  required: true,
  conditional: false
)

q1.answer_options.create!([
  { code: "R1", label: "ARRIERE (A)", value: "A", position: 1 },
  { code: "R2", label: "DESSUS (D)", value: "D", position: 2 }
])

q2 = fumisterie.questions.create!(
  code: "Q2",
  title: "S'agit-il d'une ventouse ?",
  question_type: "single_choice",
  page_name: "Le raccordement",
  position: 2,
  required: true,
  conditional: false
)

q2.answer_options.create!([
  { code: "R1", label: "OUI", value: "OUI", position: 1 },
  { code: "R2", label: "NON", value: "NON", position: 2 }
])

q3 = fumisterie.questions.create!(
  code: "Q3",
  title: "Diamètre de raccordement",
  question_type: "single_choice",
  page_name: "Le raccordement",
  position: 3,
  required: true,
  conditional: true
)

q3.answer_options.create!([
  { code: "R1", label: "80", value: "80", position: 1 },
  { code: "R2", label: "100", value: "100", position: 2 },
  { code: "R3", label: "130", value: "130", position: 3 },
  { code: "R4", label: "150", value: "150", position: 4 },
  { code: "R5", label: "180", value: "180", position: 5 },
  { code: "R6", label: "80130", value: "80130", position: 6 },
  { code: "R7", label: "100150", value: "100150", position: 7 }
])

# Créer la condition pour Q3
Condition.create!(
  question: q2,
  target_question: q3,
  expression: "Q2=R2"
)

q4 = fumisterie.questions.create!(
  code: "Q4",
  title: "Liaison entre CR et CF",
  question_type: "single_choice",
  page_name: "La liaison entre Conduit raccordement et conduit de fumée",
  position: 4,
  required: true,
  conditional: true
)

q4.answer_options.create!([
  { code: "R1", label: "Plafond (P)", value: "P", position: 1 },
  { code: "R2", label: "Traversée de mur (90°)", value: "90", position: 2 },
  { code: "R3", label: "Dans conduit (AD)", value: "AD", position: 3 }
])

Condition.create!(
  question: q2,
  target_question: q4,
  expression: "Q2=R2"
)

q5 = fumisterie.questions.create!(
  code: "Q5",
  title: "Type de travaux sur conduits de fumée",
  question_type: "single_choice",
  page_name: "Le conduit de fumée",
  position: 5,
  required: true,
  conditional: true
)

q5.answer_options.create!([
  { code: "R1", label: "Tubage", value: "T", position: 1 },
  { code: "R2", label: "Création de conduit intérieur", value: "DPI", position: 2 },
  { code: "R3", label: "Création de conduit extérieur", value: "DPE", position: 3 },
  { code: "R4", label: "Création de conduit concentrique", value: "CC", position: 4 }
])

Condition.create!(
  question: q2,
  target_question: q5,
  expression: "Q2=R2"
)

q6 = fumisterie.questions.create!(
  code: "Q6",
  title: "Hauteur du conduit de fumée",
  question_type: "single_choice",
  page_name: "Le conduit de fumée",
  position: 6,
  required: true,
  conditional: true
)

(1..12).each do |i|
  q6.answer_options.create!(
    code: "R#{i}",
    label: "#{i} mètre#{'s' if i > 1}",
    value: i.to_s,
    position: i
  )
end

Condition.create!(
  question: q2,
  target_question: q6,
  expression: "Q2=R2"
)

q7 = fumisterie.questions.create!(
  code: "Q7",
  title: "Diamètre intérieur du conduit de fumée",
  question_type: "single_choice",
  page_name: "Le conduit de fumée",
  position: 7,
  required: true,
  conditional: true
)

q7.answer_options.create!([
  { code: "R1", label: "80", value: "80", position: 1 },
  { code: "R2", label: "100", value: "100", position: 2 },
  { code: "R3", label: "130", value: "130", position: 3 },
  { code: "R4", label: "150", value: "150", position: 4 },
  { code: "R5", label: "180", value: "180", position: 5 },
  { code: "R6", label: "80130", value: "80130", position: 6 },
  { code: "R7", label: "100150", value: "100150", position: 7 }
])

Condition.create!(
  question: q2,
  target_question: q7,
  expression: "Q2=R2"
)

q8 = fumisterie.questions.create!(
  code: "Q8",
  title: "Type conduit ou toiture",
  question_type: "single_choice",
  page_name: "Le conduit de fumée",
  position: 8,
  required: true,
  conditional: true
)

q8.answer_options.create!([
  { code: "R1", label: "Conduit maçonné", value: "CM", position: 1 },
  { code: "R2", label: "Conduit métallique", value: "MET", position: 2 },
  { code: "R3", label: "Toiture terrasse 30-45°", value: "TT", position: 3 },
  { code: "R4", label: "Toiture ardoise ou tuiles plates", value: "TA", position: 4 },
  { code: "R5", label: "Toiture tuile", value: "TTU", position: 5 },
  { code: "R6", label: "Toiture bac acier", value: "TBA", position: 6 },
  { code: "R7", label: "Création extérieur", value: "CE", position: 7 }
])

Condition.create!(
  question: q2,
  target_question: q8,
  expression: "Q2=R2"
)

# Créer les kits produits selon la nomenclature Cogeli

# DÉFINITION DES VARIABLES DE BASE
diameters = ["80", "100", "130", "150", "180"]
concentric_diameters = ["80130", "100150"]
all_diameters = diameters + concentric_diameters
outlets = [["D", "dessus"], ["A", "arrière"]]
liaisons = [["P", "plafond"], ["90", "mur 90°"], ["D", "direct"]]
work_types = [["T", "Tubage"], ["DPI", "Conduit intérieur"], ["DPE", "Conduit extérieur"], ["CC", "Conduit concentrique"]]
heights = (1..12).to_a
roof_types = [
  ["MAC", "conduit maçonné"], ["MET", "conduit métallique"], ["ARDTP", "ardoise ou bac acier"],
  ["TUMEC", "tuiles mécaniques"], ["ACIER", "bac acier"], ["PLAT", "toit plat"], ["", "création extérieur"]
]

puts "Génération des codes RA (Raccordement)..."

# 1. CODES RA - RACCORDEMENT
all_diameters.each do |diam|
  outlets.each do |outlet_code, outlet_name|
    liaisons.each do |liaison_code, liaison_name|
      # Filtrer les liaisons pour les diamètres concentriques
      if ["80130", "100150"].include?(diam) && liaison_code == "D"
        next # Skip "D" (direct) pour les concentriques
      end

      # Générer le code RA
      ra_code = "RA#{diam}#{outlet_code}#{liaison_code}"

      # Construire la condition
      diam_condition = case diam
      when "80" then "Q3=R1"
      when "100" then "Q3=R2"
      when "130" then "Q3=R3"
      when "150" then "Q3=R4"
      when "180" then "Q3=R5"
      when "80130" then "Q3=R6" # Spécial concentrique
      when "100150" then "Q3=R7" # Spécial concentrique
      end

      outlet_condition = outlet_code == "D" ? "Q1=R2" : "Q1=R1"
      liaison_condition = case liaison_code
      when "P" then "Q4=R1"
      when "90" then "Q4=R2"
      when "D" then "Q4=R3"
      end

      condition = "#{outlet_condition} AND #{diam_condition} AND #{liaison_condition}"

      ProductKit.create!(
        category: "raccordement",
        code: ra_code,
        name: "Raccordement #{diam}mm sortie #{outlet_name} liaison #{liaison_name}",
        condition_expression: condition,
        price: rand(150..450),
        stock: rand(5..50),
        active: true
      )
    end
  end
end

puts "Génération des codes CF (Conduits)..."

# 2. CODES CF - CONDUITS selon la liste Cogeli exacte

# CFT - Tubage avec hauteurs groupées
diameters.each do |diam|
  # CFT avec hauteurs groupées selon la logique Cogeli
  [
    [6, "Q6=R1 OR Q6=R2 OR Q6=R3 OR Q6=R4 OR Q6=R5 OR Q6=R6"],
    [8, "Q6=R7"],
    [10, "Q6=R8 OR Q6=R9"],
    [15, "Q6=R10 OR Q6=R11 OR Q6=R12"]
  ].each do |height_group, height_condition|
    cf_code = "CFT#{diam}-#{height_group}"

    diam_condition = case diam
    when "80" then "Q7=R1"
    when "100" then "Q7=R2"
    when "130" then "Q7=R3"
    when "150" then "Q7=R4"
    when "180" then "Q7=R5"
    end

    condition = "Q5=R1 AND #{diam_condition} AND (#{height_condition})"

    ProductKit.create!(
      category: "conduit",
      code: cf_code,
      name: "Conduit Tubage #{diam}mm #{height_group}m",
      condition_expression: condition,
      price: rand(200..800),
      stock: rand(5..30),
      active: true
    )
  end
end

# CFDPI - Conduit intérieur (hauteurs 1-9)
["80", "100", "130", "150", "180"].each do |diam|
  (1..9).each do |height|
    cf_code = "CFDPI#{diam}-#{height}"

    diam_condition = case diam
    when "80" then "Q7=R1"
    when "100" then "Q7=R2"
    when "130" then "Q7=R3"
    when "150" then "Q7=R4"
    when "180" then "Q7=R5"
    end

    condition = "Q5=R2 AND #{diam_condition} AND Q6=R#{height}"

    ProductKit.create!(
      category: "conduit",
      code: cf_code,
      name: "Conduit intérieur #{diam}mm #{height}m",
      condition_expression: condition,
      price: rand(200..800),
      stock: rand(5..30),
      active: true
    )
  end
end

# CFDPE - Conduit extérieur (hauteurs 1-9)
["80", "100", "130", "150"].each do |diam|
  (1..9).each do |height|
    cf_code = "CFDPE#{diam}-#{height}"

    diam_condition = case diam
    when "80" then "Q7=R1"
    when "100" then "Q7=R2"
    when "130" then "Q7=R3"
    when "150" then "Q7=R4"
    end

    condition = "Q5=R3 AND #{diam_condition} AND Q6=R#{height}"

    ProductKit.create!(
      category: "conduit",
      code: cf_code,
      name: "Conduit extérieur #{diam}mm #{height}m",
      condition_expression: condition,
      price: rand(200..800),
      stock: rand(5..30),
      active: true
    )
  end
end

# CFCC - Conduit concentrique (hauteurs 1-8)
["80130", "100150"].each do |diam|
  (1..8).each do |height|
    cf_code = "CFCC#{diam}-#{height}"

    diam_condition = case diam
    when "80130" then "Q3=R6"
    when "100150" then "Q3=R7"
    end

    condition = "Q5=R4 AND #{diam_condition} AND Q6=R#{height}"

    ProductKit.create!(
      category: "conduit",
      code: cf_code,
      name: "Conduit concentrique #{diam}mm #{height}m",
      condition_expression: condition,
      price: rand(200..800),
      stock: rand(5..30),
      active: true
    )
  end
end

puts "Génération des codes LI (Liaisons)..."

# 3. CODES LI - LIAISONS (sauf pour CC)
all_diameters.each do |diam_rac|
  liaisons.each do |liaison_code, liaison_name|
    work_types.reject{|type, name| ["CC", "MET"].include?(type)}.each do |type_code, type_name| # Pas de LI pour CC et MET
      diameters.each do |diam_conduit|
        li_code = "LI#{diam_rac}#{liaison_code}#{type_code}#{diam_conduit}"

        # Conditions complexes pour les liaisons
        diam_rac_condition = case diam_rac
        when "80" then "Q3=R1"
        when "100" then "Q3=R2"
        when "130" then "Q3=R3"
        when "150" then "Q3=R4"
        when "180" then "Q3=R5"
        when "80130" then "Q3=R6"
        when "100150" then "Q3=R7"
        end

        liaison_condition = case liaison_code
        when "P" then "Q4=R1"
        when "90" then "Q4=R2"
        when "D" then "Q4=R3"
        end

        type_condition = case type_code
        when "T" then "Q5=R1"
        when "DPI" then "Q5=R2"
        when "DPE" then "Q5=R3"
        end

        diam_conduit_condition = case diam_conduit
        when "80" then "Q7=R1"
        when "100" then "Q7=R2"
        when "130" then "Q7=R3"
        when "150" then "Q7=R4"
        when "180" then "Q7=R5"
        when "80130" then "Q7=R6"
        when "100150" then "Q7=R7"
        end

        condition = "#{diam_rac_condition} AND #{liaison_condition} AND #{type_condition} AND #{diam_conduit_condition} AND NOT ((Q3=R6 OR Q3=R7) AND Q5=R4)"

        ProductKit.create!(
          category: "liaison",
          code: li_code,
          name: "Liaison #{diam_rac}mm vers #{type_name} #{diam_conduit}mm par #{liaison_name}",
          condition_expression: condition,
          price: rand(100..250),
          stock: rand(10..40),
          active: true
        )
      end
    end
  end
end

puts "Génération des codes spéciaux..."

# CODES DEVRAC - Pour raccordements concentriques
["80130", "100150"].each do |diam|
  devrac_code = "DEVRAC#{diam}"

  diam_condition = case diam
  when "80130" then "Q3=R6"
  when "100150" then "Q3=R7"
  end

  ProductKit.create!(
    category: "option",
    code: devrac_code,
    name: "DEVRAC #{diam}",
    condition_expression: diam_condition,
    price: rand(100..300),
    stock: rand(5..20),
    active: true
  )
end

# CODES FHREH - Pour raccordements standards avec conduit maçonné
["80", "100", "130", "150"].each do |diam|
  fhreh_code = "FHREH#{diam}"

  diam_condition = case diam
  when "80" then "Q3=R1"
  when "100" then "Q3=R2"
  when "130" then "Q3=R3"
  when "150" then "Q3=R4"
  end

  # Condition: raccordement standard ET conduit maçonné
  condition = "#{diam_condition} AND Q8=R1"

  ProductKit.create!(
    category: "option",
    code: fhreh_code,
    name: "Rehausse de conduit #{diam}",
    condition_expression: condition,
    price: rand(100..300),
    stock: rand(5..20),
    active: true
  )
end

puts "Génération des codes FH (Finitions Hautes)..."

# 4. CODES FH - FINITIONS HAUTES avec logique concentrique
work_types.each do |type_code, type_name|
  all_diameters.each do |diam_conduit|  # Utilise tous les diamètres incluant 80130 et 100150
    roof_types.each do |roof_code, roof_name|

      # Conditions de base
      type_condition = case type_code
      when "T" then "Q5=R1"
      when "DPI" then "Q5=R2"
      when "DPE" then "Q5=R3"
      when "CC" then "Q5=R4"
      end

      diam_conduit_condition = case diam_conduit
      when "80" then "Q7=R1"
      when "100" then "Q7=R2"
      when "130" then "Q7=R3"
      when "150" then "Q7=R4"
      when "180" then "Q7=R5"
      when "80130" then "Q7=R6"
      when "100150" then "Q7=R7"
      end

      roof_condition = case roof_code
      when "MAC" then "Q8=R1"
      when "MET" then "Q8=R2"
      when "ARDTP" then "Q8=R4"
      when "TUMEC" then "Q8=R5"
      when "ACIER" then "Q8=R6"
      when "PLAT" then "Q8=R3"
      when "" then "Q8=R7"
      end

      # LOGIQUE CONDITIONNELLE:
      # Si tubage + raccordement concentrique => seulement code CC
      # Sinon => code normal
      if type_code == "T" && roof_code != ""
        # Pour tubage: code CC si raccordement concentrique, sinon code normal
        # Exclure Création extérieur pour CC
        cc_fh_code = "FH#{type_code}#{diam_conduit}#{roof_code}CC"
        cc_condition = "#{type_condition} AND #{diam_conduit_condition} AND #{roof_condition} AND (Q3=R6 OR Q3=R7)"

        ProductKit.create!(
          category: "finition",
          code: cc_fh_code,
          name: "Finition haute #{type_name} #{diam_conduit}mm #{roof_name} CC",
          condition_expression: cc_condition,
          price: rand(100..300),
          stock: rand(10..40),
          active: true
        )

        # Code normal pour tubage (sans raccordement concentrique)
        normal_fh_code = "FH#{type_code}#{diam_conduit}#{roof_code}"
        normal_condition = "#{type_condition} AND #{diam_conduit_condition} AND #{roof_condition} AND NOT (Q3=R6 OR Q3=R7)"

        ProductKit.create!(
          category: "finition",
          code: normal_fh_code,
          name: "Finition haute #{type_name} #{diam_conduit}mm #{roof_name}",
          condition_expression: normal_condition,
          price: rand(100..300),
          stock: rand(10..40),
          active: true
        )
      elsif type_code == "DPE" && roof_code == ""
        # Pour DPE + Création Extérieure: code sans toiture
        dpe_code = "FH#{type_code}#{diam_conduit}"
        dpe_condition = "#{type_condition} AND #{diam_conduit_condition} AND #{roof_condition}"

        ProductKit.create!(
          category: "finition",
          code: dpe_code,
          name: "Finition haute #{type_name} #{diam_conduit}mm création extérieur",
          condition_expression: dpe_condition,
          price: rand(100..300),
          stock: rand(10..40),
          active: true
        )
      else
        # Pour autres types: seulement code normal
        normal_fh_code = "FH#{type_code}#{diam_conduit}#{roof_code}"
        normal_condition = "#{type_condition} AND #{diam_conduit_condition} AND #{roof_condition}"

        ProductKit.create!(
          category: "finition",
          code: normal_fh_code,
          name: "Finition haute #{type_name} #{diam_conduit}mm #{roof_name}",
          condition_expression: normal_condition,
          price: rand(100..300),
          stock: rand(10..40),
          active: true
        )
      end
    end
  end
end

# Kit ventouse (inchangé)
[
  ["KVD", "Kit ventouse départ dessus", "Q2=R1 AND Q1=R2"],
  ["KVA", "Kit ventouse départ arrière", "Q2=R1 AND Q1=R1"]
].each do |code, name, condition|
  ProductKit.create!(
    category: "kit_ventouse",
    code: code,
    name: name,
    condition_expression: condition,
    price: rand(250..500),
    stock: rand(5..20),
    active: true
  )
end


puts "✅ Seeding completed!"
puts "  - #{Questionnaire.count} questionnaires"
puts "  - #{Question.count} questions"
puts "  - #{AnswerOption.count} answer options"
puts "  - #{Condition.count} conditions"
puts "  - #{ProductKit.count} product kits"
