class EntityDeletionError < EnumedateApiError
  def initialize(entity)
    @entity = entity
  end

  def http_status
    500
  end

  def code
    'cannot_delete_error'
  end

  def message
    "Unable to delete #{entity.class_name} with id: #{entity.id}"
  end

  def to_hash
    {
      message: message,
      code: code
    }
  end
end
