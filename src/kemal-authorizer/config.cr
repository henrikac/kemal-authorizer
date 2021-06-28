module Kemal::Authorizer
  class Config
    INSTANCE = self.new

    # Path where requests are redirected for non-anonymous users.
    @anonymous_url : String
    # Path where requests are redirected for login.
    @login_url : String
    # Name of the user session object.
    @user_obj_name : String

    property anonymous_url, login_url, user_obj_name

    # Type of UserStorableObject.
    getter user_type : Kemal::Authorizer::StorableUser.class

    def initialize
      @anonymous_url = "/"
      @login_url = "/auth/login"
      @user_obj_name = "user"
      @user_type = Kemal::Authorizer::UserStorableObject
    end

    def user_type=(new_type : Kemal::Authorizer::StorableUser.class)
      @user_type = new_type
    end
  end

  def self.config
    yield Config::INSTANCE
  end

  def self.config
    Config::INSTANCE
  end
end
