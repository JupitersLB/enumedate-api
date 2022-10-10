require 'securerandom'

class Token < ApplicationRecord
  belongs_to :user

  before_create :gen_tok

  include HasFirebaseToken

  attr_accessor :firebase_data

  def self.from_firebase_jwt(token)
    firebase_data = decoded_firebase_token(token)&.first
    Token.new(firebase_data: firebase_data)
  end

  def gen_tok
    self.value ||= SecureRandom.base58(36)
  end

  def is_firebase_token?
    !firebase_data.blank?
  end

  def user_from_firebase_data
    return nil unless is_firebase_token?
    (User.find_by(firebase_user_id: firebase_data['user_id']) if firebase_data['user_id']) or
      if email = (firebase_data['email'] || firebase_data.dig('firebase', 'identities', 'email')&.first)
        user = User.find_by(email: email, disabled: false)
        user
      end
  end

  def to_h
    {
      id: id,
      value: self.value
    }
  end

  def to_s
    self.value
  end
end