class AddWouldRehireToUsers < ActiveRecord::Migration[5.2]
  def change
    change_table :users do |t|
      t.boolean :would_rehire, default: true, null: false
      t.index :would_rehire
    end
  end
end
