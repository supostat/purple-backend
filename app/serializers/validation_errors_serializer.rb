class ValidationErrorsSerializer

  attr_reader :record

  def initialize(record)
    @record = record
  end

  def serialize
    record.errors.messages.inject({}) do |acc, field|
      acc[field[0].to_s.camelize(:lower)] = field[1]
      acc
    end
  end
end