class StatusCreator
  class << self
    def create(status_data, user_id)
      ActiveRecord::Base.transaction do
        Status.where(user_id: user_id).delete_all #TODO Add Test
        Status.create(lat: status_data["lat"], long: status_data["long"], duration: status_data["duration"],
                    body: status_data["body"], image_url: User.find(user_id).phone_number.to_s, user_id: user_id)
      end
    end
  end
end