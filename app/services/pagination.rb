class Pagination
  def initialize(records:, per_page: 4, current_page: 1)
    @records = records
    @per_page = per_page
    @current_page = current_page
  end

  def for_load_more
    count = records.count
    pagy = Pagy.new(count: count, page: normalize_current_page(count, current_page, per_page), items: per_page)
    showing = pagy.offset + pagy.items
    {
      records: records.limit(showing),
      pagination: {
        count: pagy.count,
        showing: showing,
        next: pagy.next,
        page: pagy.page,
        norm: normalize_current_page(count, current_page, per_page),
      },
    }
  end

  private

  def normalize_current_page(count, current_page, per_page)
    page = current_page.to_i rescue 1
    return 1 if page == 0 || count == 0
    max_pages = count.fdiv(per_page).ceil
    if page > max_pages
      max_pages
    else
      page
    end
  end

  attr_reader :records, :per_page, :current_page
end