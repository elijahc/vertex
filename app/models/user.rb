class User < ActiveRecord::Base
  devise :omniauthable

  has_and_belongs_to_many :jobs

  def self.find_for_google_oauth2(access_token, signed_in_resource=nil)
    data = access_token.info
    puts data
    user = User.where(:email => data["email"]).first

    # Uncomment the section below if you want users to be created if they don't exist
    unless user
        user = User.create(first_name: data["first_name"],
           last_name: data["last_name"],
           email:     data["email"],
           provider:  access_token.provider,
           uid:       access_token.uid,
           password:  Devise.friendly_token[0,20]
        )
    end
    user
  end

  def name
    "#{first_name} #{last_name}"
  end
end
