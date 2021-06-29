require "json"

require "kemal"
require "kemal-session"

module Kemal::Authorizer
  # `Kemal::Authorizer::StorableUser` must be inherited by classes that is going to be
  # used as a UserStorableObject.
  class StorableUser
    include JSON::Serializable
    include Kemal::Session::StorableObject

    property is_admin : Bool = false
  end

  # `Kemal::Authorizer::UserStorableObject` is the default type used in the different authorize handlers.
  class UserStorableObject < StorableUser
    include JSON::Serializable
    include Kemal::Session::StorableObject

    property id : Int32
    property email : String

    # Creates a new `Kemal::Authorizer::UserStorableObject`.
    # This user object is by default not admin.
    def initialize(@id : Int32, @email : String); end

    # Creates a new `Kemal::Authorizer::UserStorableObject`.
    def initialize(@id : Int32, @email : String, @is_admin : Bool); end
  end
end
