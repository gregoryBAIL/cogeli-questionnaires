class CreateQuestions < ActiveRecord::Migration[7.2]
  def change
    create_table :questions do |t|
      t.references :questionnaire, null: false, foreign_key: true
      t.string :code
      t.string :title
      t.text :description
      t.string :question_type
      t.string :page_name
      t.integer :position
      t.boolean :required
      t.boolean :conditional
      t.jsonb :metadata

      t.timestamps
    end
    add_index :questions, :code, unique: true
  end
end
