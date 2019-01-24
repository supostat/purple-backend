class CreateUserTransitions < ActiveRecord::Migration[5.2]
  def change
    create_table :user_transitions do |t|
      t.string :to_state, null: false
      t.text :metadata
      t.integer :sort_key, null: false
      t.belongs_to :user
      t.boolean :most_recent

      # If you decide not to include an updated timestamp column in your transition
      # table, you'll need to configure the `updated_timestamp_column` setting in your
      # migration class.
      t.timestamps null: false
    end

    # Foreign keys are optional, but highly recommended
    add_foreign_key :user_transitions, :users

    add_index(:user_transitions,
              [:user_id, :sort_key],
              unique: true,
              name: "index_user_transitions_parent_sort")
    add_index(:user_transitions,
              [:user_id, :most_recent],
              unique: true,
              name: "index_user_transitions_parent_most_recent")
  end
end
