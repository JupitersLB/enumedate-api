class Users < ActiveRecord::Migration[6.1]
  def change
    create_table :users, id: :uuid do |t|
      t.string :name
      t.string :email, unique: true
      t.string :firebase_user_id, unique: true
      t.string :lang, default: 'en'
      t.string :time_unit, default: 'days'
      t.boolean :registered_user, default: false

      t.timestamps
    end
  end
end
