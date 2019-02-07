class AddDisabledToUsers < ActiveRecord::Migration[5.2]
  def change
    change_table :users do |t|
      t.datetime :disabled_at
      t.references :disabled_by_user, references: :users, index: true, null: true
    end
  end
end
