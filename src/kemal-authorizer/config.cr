module Kemal::Authorizer
  class Config
    INSTANCE = self.new
    DEFAULT_ANONYMOUS_URL = "/"
    DEFAULT_LOGIN_URL = "/login"
    DEFAULT_OBJ_NAME = "user"
    DEFAULT_USER_TYPE = Kemal::Authorizer::UserStorableObject

    # Path where requests are redirected for non-anonymous users.
    @anonymous_url : String
    # Path where requests are redirected for login.
    @login_url : String
    # Name of the user session object.
    @user_obj_name : String
    # Type of UserStorableObject.
    @user_type : Kemal::Authorizer::StorableUser.class

    property anonymous_url, login_url, user_obj_name

    getter user_type

    def initialize
      @anonymous_url = DEFAULT_ANONYMOUS_URL
      @login_url = DEFAULT_LOGIN_URL
      @user_obj_name = DEFAULT_OBJ_NAME
      @user_type = DEFAULT_USER_TYPE
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
