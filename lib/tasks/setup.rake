namespace :setup do
  desc "Force complete database reset and seed"
  task reset_and_seed: :environment do
    puts "🗑️  Cleaning database..."

    # Destroy all data
    Result.destroy_all
    UserResponse.destroy_all
    QuestionnaireSession.destroy_all
    ProductKit.destroy_all
    Condition.destroy_all
    AnswerOption.destroy_all
    Question.destroy_all
    Questionnaire.destroy_all

    puts "✅ Database cleaned"
    puts "🌱 Running seeds..."

    # Load seeds
    load "#{Rails.root}/db/seeds.rb"

    puts "✅ Setup complete!"
    puts "📊 Final count:"
    puts "  - #{Questionnaire.count} questionnaires: #{Questionnaire.pluck(:name).join(', ')}"
    puts "  - #{Question.count} questions"
    puts "  - #{AnswerOption.count} answer options"
    puts "  - #{ProductKit.count} product kits"
  end
end