class User < ApplicationRecord
  has_one :token, dependent: :destroy
  before_save :downcase_attrs

  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }

  def to_h
    {
      id: id,
      name: name,
      email: email
      lang: lang
      time_unit: time_unit
      registered_user: registered_user
    }
  end

  private

  def downcase_attrs
    email = email && email.strip.downcase
    name = name && name.strip.downcase
    lang = lang && lang.strip.downcase
    time_unit = time_unit && time_unit.strip.downcase
  end
end