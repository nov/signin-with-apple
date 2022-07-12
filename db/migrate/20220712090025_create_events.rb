class CreateEvents < ActiveRecord::Migration[6.1]
  def change
    create_table :events do |t|
      t.string :identifier, null: false
      t.text :payload, null: false
      t.timestamps
      t.index :identifier, unique: true
    end
  end
end
