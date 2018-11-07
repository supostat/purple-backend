class AddRoleToUsersTable < ActiveRecord::Migration[5.2]
  def change
    change_table :users do |t|
      t.string :role, null: false
    end
  end
end
