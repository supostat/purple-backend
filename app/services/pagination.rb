class Pagination
  def initialize(records:, per_page: 4, current_page: 1)
    @records = records
    @per_page = per_page
    @current_page = current_page
  end

  def for_load_more
    pagy = Pagy.new(count: records.count, page: current_page, items: per_page, circle: true)
    showing = pagy.offset + pagy.items
    {
      records: records.limit(showing),
      pagination: {
        count: pagy.count,
        showing: showing,
        next: pagy.next,
        page: pagy.page,
        pagy: pagy,
      },
    }
  end

  private

  attr_reader :records, :per_page, :current_page
end