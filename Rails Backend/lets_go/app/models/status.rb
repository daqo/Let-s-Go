class Status < ActiveRecord::Base
  validates :lat, presence: {message: "must be specified"}
  validates :long, presence: {message: "must be specified"}
  validates :body, presence: {message: "must be specified"}
  validates :duration, presence: {message: "must be specified"}
  # validates :duration, inclusion: { in: %w|1200 3600 7200|,
  #  message: "%{value} is not a valid duration" }
  belongs_to :user

  default_scope where('created_at > ?', 10.minutes.ago)

  scope :expired, -> { where('created_at < ?', 10.minutes.ago) } #TODO Duration Time is Fixed!, Test it
end
