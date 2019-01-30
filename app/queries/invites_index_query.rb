class InvitesIndexQuery
  def initialize(params:)
    @params = params
  end

  def all(order: :desc)
    query = User.includes([:roles, :work_venues, :invited_by]).created_by_invite.order(created_at: order)
    if params[:venues].present?
      query = query.joins(:work_venues).where(users_venues: {venue_id: params[:venues]})
    end
    if params[:role].present?
      query = query.with_role(params[:role])
    end
    if params[:email].present?
      query = query.search_email(params[:email])
    end
    if params[:status].present?
      case params[:status]
      when User::INVITATION_REVOKED_STATUS
        query = query.where(invitation_token: nil).where.not(invitation_revoked_at: nil)
      when User::INVITATION_PENDING_STATUS
        query = query.invitation_not_accepted
      when User::INVITATION_ACCEPTED_STATUS
        query = query.invitation_accepted
      else
        raise "Unknown user status in query param"
      end
    end
    query
  end

  private

  attr_reader :params
end
