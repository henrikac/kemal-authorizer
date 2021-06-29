require "spec"
require "../src/kemal-authorizer"

# Routes in the tests does not exist and they can therefore not be reached.
# 404 will therefore be equivalent to 200 in the test cases.
SUCCESS_CODE = 404

SESSION_ID = Random::Secure.hex

Kemal::Session.config do |config|
  config.secret = "test_secret"
  config.engine = Kemal::Session::MemoryEngine.new
end

Kemal::Authorizer.config do |config|
  config.user_type = TestStorableUser
end

# credit to: https://github.com/kemalcr/kemal-csrf/blob/master/spec/spec_helper.cr#L5
def process_request(handler, request, authenticated = false, authorized = false)
  io = IO::Memory.new
  response = HTTP::Server::Response.new(io)
  context = create_context(SESSION_ID, request, response)

  session = Kemal::Session.new(context)

  if authenticated
    test_user = TestStorableUser.new
    test_user.is_admin = authorized
    session.object(Kemal::Authorizer.config.user_obj_name, test_user)
  end

  handler.call(context)
  response.close
  io.rewind
  io
end

# credit to: https://github.com/kemalcr/kemal-session/blob/master/spec/spec_helper.cr#L15
def create_context(session_id : String, request, response)
  headers = HTTP::Headers.new

  unless session_id == ""
    Kemal::Session.config.engine.create_session(session_id)

    cookies = HTTP::Cookies.new
    cookies << HTTP::Cookie.new(Kemal::Session.config.cookie_name, Kemal::Session.encode(session_id))
    cookies.add_request_headers(headers)
  end

  request.headers = headers

  return HTTP::Server::Context.new(request, response)
end

class TestStorableUser < Kemal::Authorizer::StorableUser
  include JSON::Serializable
  include Kemal::Session::StorableObject

  property id, name

  def initialize(@id : Int32 = 1, @name : String = "Alice", @is_admin : Bool = false); end
end















