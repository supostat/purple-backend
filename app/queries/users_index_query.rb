class UsersIndexQuery
  def initialize(params:)
    @params = params
  end

  def all(order: :desc)

    query = User.includes([:roles, :work_venues, :invited_by, :disabled_by_user])
      .order(created_at: order)
    if params[:name].present?
      query = query.search_name(params[:name])
    end
    if params[:role].present?
      query = query.with_role(params[:role])
    end
    if params[:email].present?
      query = query.search_email(params[:email])
    end
    if params[:status].present?
      case params[:status]
      when User::DISABLED_STATUS
        query = query.disabled
      when User::ENABLED_STATUS
        query = query.enabled
      else
        raise "Unknown user status in query param"
      end
    end
    query
  end

  private

  attr_reader :params
end
