class AddDisableReasonToUsers < ActiveRecord::Migration[5.2]
  def change
    change_table :users do |t|
      t.text :disabled_reason
    end
  end
end
