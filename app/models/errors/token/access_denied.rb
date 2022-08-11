class Token::AccessDenied < EnumedateApiError
  def http_status
    401
  end

  def code
    'access_denied'
  end

  def message
    'Your token is not authorized to perform this action'
  end

  def to_hash
    {
      message: message,
      code: code
    }
  end
end