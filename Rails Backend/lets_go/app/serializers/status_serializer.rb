class StatusSerializer < ActiveModel::Serializer
  attributes :id, :lat, :long, :body, :duration, :image_url
  has_one :user
end
