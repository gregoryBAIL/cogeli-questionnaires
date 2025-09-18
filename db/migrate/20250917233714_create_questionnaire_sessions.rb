class CreateQuestionnaireSessions < ActiveRecord::Migration[7.2]
  def change
    create_table :questionnaire_sessions do |t|
      t.string :session_token
      t.references :questionnaire, null: false, foreign_key: true
      t.references :current_question, null: true, foreign_key: { to_table: :questions }
      t.datetime :started_at
      t.datetime :completed_at
      t.string :ip_address
      t.string :user_agent
      t.jsonb :metadata

      t.timestamps
    end
    add_index :questionnaire_sessions, :session_token, unique: true
  end
end
