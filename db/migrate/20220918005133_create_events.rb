class CreateEvents < ActiveRecord::Migration[6.1]
  def change
    create_table :events, id: :uuid do |t|
      t.string :title
      t.datetime :start_date
      t.string :unit
      t.references :user, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
