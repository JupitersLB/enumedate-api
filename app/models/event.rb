class Event < ApplicationRecord
  belongs_to :user

  validates :unit, inclusion: { in: %w[minutes hours days weeks months years] }, allow_blank: true
  validates :start_date, presence: true

  def to_h
    {
      id: id,
      title: title,
      start_date: start_date,
      unit: unit
    }
  end
end
