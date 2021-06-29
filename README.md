# kemal-authorizer

This is a shard that makes it easy to make specific routes in a Kemal application only accessible to either anonymous, authenticated or authorized (administrators) users.

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     kemal-authorizer:
       github: henrikac/kemal-authorizer
   ```

2. Run `shards install`

## Usage

```crystal
require "kemal"
require "kemal-session"
require "kemal-authorizer"

Kemal::Session.config do |config|
  config.secret = "some_secret"
end

# Only anonymous users can access these routes.
# authenticated users will be redirected to "/" (default route).
add_handler Kemal::Authorizer::AnonymousHandler.new({
  "/login" => ["GET", "POST"],
  "/signup" => ["GET", "POST"]
})

# Only authenticated users can access these routes.
# Unauthenticated users will be redirected to "/login?next=..." (default route).
add_handler Kemal::Authorizer::AuthenticationHandler.new({
  "/dashboard" => ["GET"],
  "/logout" => ["POST"]
})

# Only authenticated users that `is_admin` can access this route.
# Unauthenticated users will be redirected to "/login?next=..." (default route).
# If the user is authenticated but not an admin then the status code will be set to 401.
add_handler Kemal::Authorizer::AuthorizationHandler.new({
  "/admin" => ["GET"]
})

get "/" do |env|
  user = Kemal::Authorizer::UserStorableObject.new(1, "user@mail.com", true) # id, mail, is_admin
  env.session.object("user", user)
  "Home"
end

get "/login" do |env|
  "Login"
end

get "/admin" do |env|
  "Admin"
end

Kemal.run
```

#### Configuration
`Kemal::Authorizer` has a few default configurations that can changed if needed.

```crystal
Kemal::Authorizer.config do |config|
  config.anonymous_url = "/"
  config.login_url = "/login"
  config.user_obj_name = "user" # name of the session object env.session.object(user_obj_name, obj)
  config.user_type = Kemal::Authorizer::UserStorableObject
end
```

#### Custom Handlers
You can create custom handlers by inheriting from `Kemal::Authorizer::BaseHandler`.

```crystal
class CustomHandler < Kemal::Authorizer::BaseHandler
  def call(context)
    # add custom logic
    call_next context
  end
end

add_handler CustomHandler.new({"/my/route", ["GET", "POST", "PUT"]})
```

#### Custom StorableUser
If the built-in `UserStorableObject` is not sufficient enough then it is possible to make
a custom type and then set `config.user_type` to the new type. New StorableUser types must
inherit from `Kemal::Authorizer::StorableUser`.

```crystal
require "json"

class MyStorableUserType < Kemal::Authorizer::StorableUser
  include JSON::Serializable
  include Kemal::Session::StorableObject

  property id : Int32
  property name : String

  def initialize(@id : Int32, @name : String); end
end

# and then

Kemal::Authorizer.config do |config|
  config.user_type = MyStorableUserType
end
```

## Contributing

1. Fork it (<https://github.com/henrikac/kemal-authorizer/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Henrik Christensen](https://github.com/henrikac) - creator and maintainer
