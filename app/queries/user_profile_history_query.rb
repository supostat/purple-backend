class UserProfileHistoryQuery
  def initialize(params:)
    @params = params
  end

  def all(order: :desc)
    user_id = params.fetch(:id)
    starts_at = UIDate.safe_parse(params[:starts_at])
    ends_at = UIDate.safe_parse(params[:ends_at])
    user = User.find_by(id: user_id)

    query = user.history.order(created_at: order)
    if starts_at.present? && ends_at.present?
      query.where("created_at >= ? AND created_at <= ?", starts_at, ends_at)
    elsif starts_at.present?
      query.where("created_at >= ?", starts_at)
    elsif ends_at.present?
      query.where("created_at <= ?", ends_at)
    else
      query
    end
  end

  private

  attr_reader :params
end
