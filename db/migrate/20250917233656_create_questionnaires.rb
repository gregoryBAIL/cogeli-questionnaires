class CreateQuestionnaires < ActiveRecord::Migration[7.2]
  def change
    create_table :questionnaires do |t|
      t.string :name
      t.string :slug
      t.text :description
      t.boolean :active
      t.integer :position
      t.jsonb :settings

      t.timestamps
    end
    add_index :questionnaires, :slug, unique: true
  end
end
