class UIDate
  URL_DATE_FORMAT = '%d-%m-%Y'

  def self.parse(date_param)
    Date.strptime(date_param, URL_DATE_FORMAT)
  end

  def self.parse_if_present(date_param)
    if date_param.present?
      Date.strptime(date_param, URL_DATE_FORMAT)
    end
  end

  def self.safe_parse(date_param)
    return nil unless date_param.present?
    result = nil
    begin
      result = parse(date_param)
    rescue
      #do nothing
    end
    result
  end

  def self.format(date)
    date.strftime(URL_DATE_FORMAT)
  end

  def self.safe_format(date_param)
    return nil unless date_param.present?
    result = nil
    begin
      result = format(date_param)
    rescue
      #do nothing
    end
    result
  end

  def self.assert_date_range_valid(start_date, end_date)
    day_delta = ((start_date - end_date) / 1.day).abs
    if (day_delta > 7)
      raise "invalid date range supplied #{start_date} - #{end_date}"
    end
  end
end
