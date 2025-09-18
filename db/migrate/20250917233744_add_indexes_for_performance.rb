class AddIndexesForPerformance < ActiveRecord::Migration[7.2]
  def change
    add_index :questions, [:questionnaire_id, :position]
    add_index :questions, :page_name
    add_index :answer_options, [:question_id, :position]
    add_index :user_responses, [:questionnaire_session_id, :question_id],
              unique: true, name: 'index_unique_session_question'
    add_index :product_kits, :category
    add_index :questionnaire_sessions, :completed_at
  end
end
