# Nouveau fichier : app/models/product_kit_calculator.rb
# Service pour calculer les kits (si vous voulez garder la logique côté serveur)
class ProductKitCalculator
  attr_reader :answers

  def initialize(answers)
    @answers = answers
  end

  def calculate
    kits = []

    # Kit ventouse
    if answers['Q2'] == 'R1'
      if answers['Q1'] == 'R2'
        kits << build_kit('Kit ventouse', 'KVD', 'Kit ventouse départ dessus', 450)
      elsif answers['Q1'] == 'R1'
        kits << build_kit('Kit ventouse', 'KVA', 'Kit ventouse départ arrière', 450)
      end
      return kits
    end

    # Raccordement
    if answers['Q3'] && answers['Q1'] && answers['Q4']
      diam = get_answer_value('Q3')
      outlet = answers['Q1'] == 'R2' ? 'D' : 'A'
      liaison = get_answer_value('Q4')

      kits << build_kit(
        'Raccordement',
        "RA#{diam}#{outlet}#{liaison}",
        "Raccordement #{diam}mm sortie #{outlet_name(outlet)} liaison #{liaison_name(liaison)}",
        250
      )
    end

    # Conduit
    if answers['Q5'] && answers['Q7'] && answers['Q6']
      type = get_answer_value('Q5')
      diam = get_answer_value('Q7')
      height = get_answer_value('Q6')

      kit = build_conduit_kit(type, diam, height)
      kits << kit if kit
    end

    # Liaison
    if needs_liaison?
      kit = build_liaison_kit
      kits << kit if kit
    end

    # Finition haute
    if answers['Q5'] && answers['Q7'] && answers['Q8']
      kit = build_finition_kit
      kits << kit if kit
    end

    # Options
    kits.concat(build_option_kits)

    kits
  end

  private

  def build_kit(category, code, name, price)
    {
      category: category,
      code: code,
      name: name,
      price: price
    }
  end

  def get_answer_value(question_id)
    # Mapper les réponses aux valeurs
    # Vous pouvez utiliser les données de la BD ici
    mapping = {
      'Q3' => { 'R1' => '80', 'R2' => '100', 'R3' => '130', 'R4' => '150', 'R5' => '180', 'R6' => '80130', 'R7' => '100150' },
      'Q4' => { 'R1' => 'P', 'R2' => '90', 'R3' => 'AD' },
      'Q5' => { 'R1' => 'T', 'R2' => 'DPI', 'R3' => 'DPE', 'R4' => 'CC' },
      'Q6' => Hash[(1..12).map { |i| ["R#{i}", i.to_s] }],
      'Q7' => { 'R1' => '80', 'R2' => '100', 'R3' => '130', 'R4' => '150', 'R5' => '180', 'R6' => '80130', 'R7' => '100150' },
      'Q8' => { 'R1' => 'CM', 'R2' => 'MET', 'R3' => 'TT', 'R4' => 'TA', 'R5' => 'TTU', 'R6' => 'TBA', 'R7' => 'CE' }
    }

    mapping[question_id][answers[question_id]]
  end

  def outlet_name(outlet)
    outlet == 'D' ? 'dessus' : 'arrière'
  end

  def liaison_name(liaison)
    case liaison
    when 'P' then 'plafond'
    when '90' then 'mur 90°'
    when 'AD' then 'direct'
    end
  end

  def build_conduit_kit(type, diam, height)
    case type
    when 'T'
      height_group = height.to_i <= 6 ? '6' : height.to_i == 7 ? '8' : height.to_i <= 9 ? '10' : '15'
      build_kit('Conduit', "CFT#{diam}-#{height_group}", "Conduit Tubage #{diam}mm #{height_group}m", 400 + height.to_i * 50)
    when 'DPI'
      build_kit('Conduit', "CFDPI#{diam}-#{height}", "Conduit intérieur #{diam}mm #{height}m", 400 + height.to_i * 50)
    when 'DPE'
      build_kit('Conduit', "CFDPE#{diam}-#{height}", "Conduit extérieur #{diam}mm #{height}m", 400 + height.to_i * 50)
    when 'CC'
      build_kit('Conduit', "CFCC#{diam}-#{height}", "Conduit concentrique #{diam}mm #{height}m", 400 + height.to_i * 50)
    end
  end

  def needs_liaison?
    answers['Q3'] && answers['Q4'] && answers['Q5'] && answers['Q7'] && answers['Q5'] != 'R4'
  end

  def build_liaison_kit
    diam_rac = get_answer_value('Q3')
    liaison = get_answer_value('Q4')
    type = get_answer_value('Q5')
    diam_conduit = get_answer_value('Q7')

    build_kit(
      'Liaison',
      "LI#{diam_rac}#{liaison}#{type}#{diam_conduit}",
      "Liaison #{diam_rac}mm vers #{type} #{diam_conduit}mm",
      150
    )
  end

  def build_finition_kit
    type = get_answer_value('Q5')
    diam = get_answer_value('Q7')
    roof = get_answer_value('Q8')

    roof_code = case roof
    when 'CM' then 'MAC'
    when 'MET' then 'MET'
    when 'TT' then 'PLAT'
    when 'TA' then 'ARDTP'
    when 'TTU' then 'TUMEC'
    when 'TBA' then 'ACIER'
    else ''
    end

    build_kit(
      'Finition haute',
      "FH#{type}#{diam}#{roof_code}",
      "Finition haute #{type} #{diam}mm #{roof}",
      200
    )
  end

  def build_option_kits
    kits = []

    # DEVRAC pour concentriques
    if ['R6', 'R7'].include?(answers['Q3'])
      diam = get_answer_value('Q3')
      kits << build_kit('Option', "DEVRAC#{diam}", "DEVRAC #{diam}", 180)
    end

    # FHREH pour conduit maçonné
    if answers['Q3'] && answers['Q8'] == 'R1'
      diam = get_answer_value('Q3')
      if ['80', '100', '130', '150'].include?(diam)
        kits << build_kit('Option', "FHREH#{diam}", "Rehausse de conduit #{diam}", 150)
      end
    end

    kits
  end
end
