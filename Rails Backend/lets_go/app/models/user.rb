class User < ActiveRecord::Base
  has_secure_password
  has_many :api_keys
  has_one :status

  validates :email, presence: true, uniqueness: true
  validates :phone_number, presence: true, uniqueness: true
  validates :username, presence: true, uniqueness: true
  validates :name, presence: true

  def session_api_key
    api_keys.active.session.first_or_create
  end
end
