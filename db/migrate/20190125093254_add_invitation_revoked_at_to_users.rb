class AddInvitationRevokedAtToUsers < ActiveRecord::Migration[5.2]
  def change
    change_table :users do |t|
      t.datetime :invitation_revoked_at
    end
  end
end
