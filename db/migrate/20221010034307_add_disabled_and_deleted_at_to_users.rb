class AddDisabledAndDeletedAtToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :disabled, :boolean, default: false
    add_column :users, :deleted_at, :datetime
  end
end
