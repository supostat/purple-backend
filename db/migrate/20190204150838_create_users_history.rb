class CreateUsersHistory < ActiveRecord::Migration[5.2]
  def change
    create_table :users_histories do |t|
      t.string :model_key, null: false
      t.text :old_value
      t.text :new_value
      t.references :user, null: false, index: true
      t.references :requester_user, references: :users, null: false, index: true

      t.timestamps null: false
    end
  end
end
