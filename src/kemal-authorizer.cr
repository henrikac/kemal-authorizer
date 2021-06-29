require "./**"

# `Kemal::Autrhorizer` is a module that provides a few handy `Kemal::Handler`
# that makes it easy to make routes only accessible to either anonymous, authenticated or
# authorized (administrators) users.
#
# ```
# require "kemal"
# require "kemal-session"
# require "kemal-authorizer"
#
# Kemal::Session.config do |config|
#   config.secret = "some_secret"
# end
#
# # Only anonymous users can access these routes.
# # authenticated users will be redirected to "/" (default route).
# add_handler Kemal::Authorizer::AnonymousHandler.new({
#   "/login" => ["GET", "POST"],
#   "/signup" => ["GET", "POST"]
# })
#
# # Only authenticated users can access these routes.
# # Unauthenticated users will be redirected to "/login?next=..." (default route).
# add_handler Kemal::Authorizer::AuthenticationHandler.new({
#   "/dashboard" => ["GET"],
#   "/logout" => ["POST"]
# })
#
# # Only authenticated users that `is_admin` can access this route.
# # Unauthenticated users will be redirected to "/login?next=..." (default route).
# # If the user is authenticated but not an admin then the status code will be set to 401.
# add_handler Kemal::Authorizer::AuthorizationHandler.new({
#   "/admin" => ["GET"]
# })
#
# get "/" do |env|
#   user = Kemal::Authorizer::UserStorableObject.new(1, "user@mail.com", true) # id, mail, is_admin
#   env.session.object("user", user)
#   "Home"
# end
#
# get "/login" do |env|
#   "Login"
# end
#
# get "/admin" do |env|
#   "Admin"
# end
#
# Kemal.run
# ```
#
# `Kemal::Authorizer` has a few default configurations that can changed if needed.
#
# ```
# Kemal::Authorizer.config do |config|
#   config.anonymous_url = "/"
#   config.login_url = "/login"
#   config.user_obj_name = "user" # name of the session object env.session.object(user_obj_name, obj)
#   config.user_type = Kemal::Authorizer::UserStorableObject
# end
# ```
#
# If the built-in `UserStorableObject` is not sufficient enough then it is possible to make
# a custom type and then set `config.user_type` to the new type. New StorableUser types must
# inherit from `Kemal::Authorizer::StorableUser`.
#
# ```
# require "json"

# class MyStorableUserType < Kemal::Authorizer::StorableUser
#   include JSON::Serializable
#   include Kemal::Session::StorableObject
#
#   property id : Int32
#   property name : String
#
#   def initialize(@id : Int32, @name : String); end
# end
#
# # and then
# 
# Kemal::Authorizer.config do |config|
#   config.user_type = MyStorableUserType
# end
# ```
module Kemal::Authorizer
  VERSION = "0.3.0"
end
