class CreateAnswerOptions < ActiveRecord::Migration[7.2]
  def change
    create_table :answer_options do |t|
      t.references :question, null: false, foreign_key: true
      t.string :code
      t.string :label
      t.string :value
      t.integer :position
      t.jsonb :metadata

      t.timestamps
    end
  end
end
