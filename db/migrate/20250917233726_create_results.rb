class CreateResults < ActiveRecord::Migration[7.2]
  def change
    create_table :results do |t|
      t.references :questionnaire_session, null: false, foreign_key: true
      t.jsonb :product_kits
      t.datetime :generated_at
      t.boolean :sent_by_email
      t.string :email

      t.timestamps
    end
  end
end
