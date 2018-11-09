class AddInvitableToUsersTable < ActiveRecord::Migration[5.2]
  def change
    change_table :users do |t|
      t.string :invitation_token, index: true, unique: true
      t.datetime :invitation_created_at
      t.datetime :invitation_sent_at
      t.datetime :invitation_accepted_at
      t.integer :invitation_limit
      t.integer :invited_by_id
      t.string :invited_by_type
    end

    # Allow null encrypted_password
    change_column_null :users, :encrypted_password, :string, true
  end
end
