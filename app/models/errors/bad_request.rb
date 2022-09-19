class BadRequest < EnumedateApiError
  def initialize(message)
    @message = message
  end

  def http_status
    400
  end

  def code
    'bad_request'
  end

  attr_reader :message

  def to_hash
    {
      message: message,
      code: code
    }
  end
end
