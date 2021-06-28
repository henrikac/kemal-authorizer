require "uri"

require "kemal"
require "kemal-session"
require "./user_object"

module Kemal::Authorizer
  class BaseHandler < Kemal::Handler
    def initialize(@auth_req_routes : Hash(String, Array(String)))
      load_routes
    end

    private def load_routes
      # credit to: https://github.com/kemalcr/kemal-csrf/blob/master/src/kemal-csrf.cr#L18
      @auth_req_routes.each do |route, methods|
        class_name = {{@type.name}}
        methods.each do |method|
          method_downcase = method.downcase
          @@only_routes_tree.add "#{class_name}/#{method_downcase}#{route}", "/#{method_downcase}#{route}"
        end
      end
    end
  end

  # `Kemal::Authorizer::AnonymousHandler` is a middleware that makes sure that
  # only anonymous users can visit the specified routes.
  #
  # ```
  # Kemal::Authorizer::AnonymousHandler.new({
  #   "/login" => ["GET", "POST"],
  #   "/signup" => ["GET", "POST"]
  # })
  # ```
  class AnonymousHandler < BaseHandler
    def call(context)
      return call_next(context) unless only_match?(context)

      user = context.session.object?(Kemal::Authorizer.config.user_obj_name)
      return call_next(context) if user.nil?

      context.redirect Kemal::Authorizer.config.anonymous_url
      return call_next(context)
    end
  end

  # `Kemal::Authorizer::AuthenticationHandler` is a middleware that makes sure that
  # only authenticated users can visit the specified routes.
  #
  # ```
  # Kemal::Authorizer::AuthenticationHandler.new({
  #   "/dashboard" => ["GET"],
  #   "/logout" => ["POST"]
  # })
  # ```
  #
  # If an unauthenticated user tries to visit e.g. "/dashboard" the user will
  # be redirected to "/login?next=%2Fdashboard".
  class AuthenticationHandler < BaseHandler
    def call(context)
      return call_next(context) unless only_match?(context)

      user = context.session.object?(Kemal::Authorizer.config.user_obj_name)

      if user.nil?
        login_route = Kemal::Authorizer.config.login_url
        path = context.request.path
        context.redirect "#{login_route}?next=#{URI.encode_www_form(path)}"
      end

      return call_next(context)
    end
  end

  # `Kemal::Authorizer::AuthorizationHandler` is a middleware that makes sure that
  # only authenticated admin users can visit the specified routes.
  #
  # ```
  # Kemal::Authorizer::AuthorizationHandler.new({
  #   "/admin" => ["GET"],
  # })
  # ```
  #
  # If an user that is not an admin tries to visit "/admin" the user will
  # be redirected to "/login?next=%2Fadmin".
  class AuthorizationHandler < BaseHandler
    def call(context)
      return call_next(context) unless only_match?(context)

      user = context.session.object?(Kemal::Authorizer.config.user_obj_name)

      if user.nil?
        login_route = Kemal::Authorizer.config.login_url
        path = context.request.path
        context.redirect "#{login_route}?next=#{URI.encode_www_form(path)}"
        return call_next(context)
      else
        user_type = Kemal::Authorizer.config.user_type
        return call_next(context) if user_type.cast(user).is_admin
      end

      context.response.status_code = 401
    end
  end
end
