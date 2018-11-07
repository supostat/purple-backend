class AddFirstNameAndSurnameToUsersTable < ActiveRecord::Migration[5.2]
  def change
    change_table :users do |t|
      t.string :first_name, null: false, index: true
      t.string :surname, null: false, index: true
    end
  end
end
