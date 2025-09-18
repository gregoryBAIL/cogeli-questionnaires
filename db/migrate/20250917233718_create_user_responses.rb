class CreateUserResponses < ActiveRecord::Migration[7.2]
  def change
    create_table :user_responses do |t|
      t.references :questionnaire_session, null: false, foreign_key: true
      t.references :question, null: false, foreign_key: true
      t.text :answer
      t.string :answer_code
      t.datetime :answered_at

      t.timestamps
    end
  end
end
