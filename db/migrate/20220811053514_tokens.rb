class Tokens < ActiveRecord::Migration[6.1]
  def change
    create_table :tokens, id: :uuid do |t|
      t.string :value, null: false
      t.belongs_to :user, index: true, type: :uuid

      t.timestamps
    end
    add_index :tokens, :value
  end
end
