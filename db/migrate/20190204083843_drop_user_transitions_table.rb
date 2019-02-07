class DropUserTransitionsTable < ActiveRecord::Migration[5.2]
  def change
    drop_table :user_transitions do |t|
      t.string :to_state, null: false
      t.text :metadata
      t.integer :sort_key, null: false
      t.belongs_to :user
      t.boolean :most_recent

      t.timestamps null: false
    end
  end
end
