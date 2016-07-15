class User < ActiveRecord::Base
  validates :messenger_id, uniqueness: true
end
