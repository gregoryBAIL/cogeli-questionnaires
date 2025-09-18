class CreateConditions < ActiveRecord::Migration[7.2]
  def change
    create_table :conditions do |t|
      t.references :question, null: false, foreign_key: true
      t.string :expression
      t.jsonb :logic
      t.references :target_question, null: false, foreign_key: { to_table: :questions }

      t.timestamps
    end
  end
end
