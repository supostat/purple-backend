class BooleanString
  def self.parse_boolean(string)
    normalised_string = string.to_s.downcase.strip
    case normalised_string
    when "true"
      true
    when "false"
      false
    else
      raise "attempt to parse unsuported string \"#{string}\" as boolean"
    end
  end
end
