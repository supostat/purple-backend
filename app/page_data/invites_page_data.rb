class InvitesPageData
  Result = Struct.new(:success, :users) do
    def success?
      success
    end
  end

  def all
    success = true
    users = User.created_by_invite

    Result.new(success, users)
  end
end
