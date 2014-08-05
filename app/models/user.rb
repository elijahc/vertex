class User < ActiveRecord::Base
  devise :omniauthable, :omniauth_providers => [:google_oauth2]

  has_and_belongs_to_many :jobs

  has_many :identities

  enum status: [:pending, :active, :revoked]

  def active_for_authentication?
    super && approved?
  end

  def inactive_message
    unless approved?
      'Your account has not been approved yet'
    else
      super
    end
  end

  def self.new_with_session(params, session)
    super.tap do |user|
    end
  end

  def self.create_with_omniauth(info)
    create(name: info['name'])
  end

  def self.find_for_google_oauth2(access_token, signed_in_resource=nil)
    data = access_token.info
    user = User.where(:email => data["email"]).first

    # Uncomment the section below if you want users to be created if they don't exist
    unless user
        user = User.create(first_name: data["first_name"],
           last_name: data["last_name"],
           email:     data["email"],
           provider:  access_token.provider,
           uid:       access_token.uid,
           password:  Devise.friendly_token[0,20],
           approved:  User.first.nil?
        )
    end
    user
  end

  def name
    "#{first_name} #{last_name}"
  end
end
