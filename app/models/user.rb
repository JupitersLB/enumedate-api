class User < ApplicationRecord
  has_one :token, dependent: :destroy
  before_save :downcase_attrs, :check_registered_user

  validates :email, allow_blank: true, format: { with: URI::MailTo::EMAIL_REGEXP }

  def to_h
    {
      id: id,
      name: name,
      email: email,
      lang: lang,
      time_unit: time_unit,
      registered_user: registered_user,
      created_at: created_at
    }
  end

  private

  def downcase_attrs
    self.email = email && email.strip.downcase
    self.name = name && name.strip.downcase
    self.lang = lang && lang.strip.downcase
    self.time_unit = time_unit && time_unit.strip.downcase
  end

  def check_registered_user
    self.registered_user = !email.nil?
  end
end