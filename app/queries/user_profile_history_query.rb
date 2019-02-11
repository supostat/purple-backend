class UserProfileHistoryQuery
  def initialize(params:)
    @params = params
  end

  def all(order: :desc)
    user_id = params.fetch(:id)
    start_date = UIDate.safe_parse(params[:start_date])
    end_date = UIDate.safe_parse(params[:end_date])
    user = User.find_by(id: user_id)
    query = user.history.includes([:requester_user]).order(created_at: order)
    if start_date.present? && end_date.present?
      query.where("created_at >= ? AND created_at <= ?", start_date.beginning_of_day, end_date.end_of_day)
    elsif start_date.present?
      query.where("created_at >= ?", start_date.beginning_of_day)
    elsif end_date.present?
      query.where("created_at <= ?", end_date.end_of_day)
    else
      query
    end
  end

  private

  attr_reader :params
end
