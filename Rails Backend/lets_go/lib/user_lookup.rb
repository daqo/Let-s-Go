class UserLookup
  class << self
    def find_user_id_by_token(token)
      ApiKey.find_by(access_token: token).user.id
    end
  end
end