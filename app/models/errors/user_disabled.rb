class UserDisabled < EnumedateApiError
  def initialize(entity)
    @entity = entity
  end

  def http_status
    403
  end

  def code
    'user_disabled'
  end

  def message
    'User disabled'
  end

  def to_hash
    {
      message: message,
      code: code
    }
  end
end
