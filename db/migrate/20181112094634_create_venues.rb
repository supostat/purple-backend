class CreateVenues < ActiveRecord::Migration[5.2]
  def change
    create_table :venues do |t|
      t.string :name, null: false, index: true

      t.timestamps null: false
    end

    create_table(:users_venues, :id => false) do |t|
      t.references :user, index: true
      t.references :venue, index: true
    end
  end
end
