require "json"

require "kemal"
require "kemal-session"

module Kemal::Authorizer
  # `Kemal::Authorizer::StorableUser` must be inherited by classes that is going to be
  # used as a UserStorableObject.
  class StorableUser
    include JSON::Serializable
    include Kemal::Session::StorableObject

    property is_admin : Bool
  end

  # `Kemal::Authorizer::UserStorableObject` is the default type used in the different authorize handlers.
  class UserStorableObject < StorableUser
    include JSON::Serializable
    include Kemal::Session::StorableObject

    property id : Int32
    property email : String

    def initialize(@id : Int32, @email : String, @is_admin : Bool); end
  end
end
