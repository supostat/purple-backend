class ValidationErrorSerializer

  def initialize(field, messages)
    @field = field
    @messages = messages
  end

  def serialize
    {
      field: field.to_s,
      messages: @messages
    }
  end
end