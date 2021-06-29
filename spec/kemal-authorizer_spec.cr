require "./spec_helper"

describe Kemal::Authorizer do
  describe "AnonymousHandler" do
    methods = ["GET", "POST"]
    handler = Kemal::Authorizer::AnonymousHandler.new({"/login" => methods})

    it "accepts anonymous users" do
      methods.each do |method|
        request = HTTP::Request.new(method, "/login")
        io_with_context = process_request(handler, request)

        client_response = HTTP::Client::Response.from_io(io_with_context, decompress: false)
        client_response.status_code.should eq SUCCESS_CODE
      end
    end

    it "redirects authenticated users" do
      methods.each do |method|
        request = HTTP::Request.new(method, "/login")
        io_with_context = process_request(handler, request, authenticated: true)

        client_response = HTTP::Client::Response.from_io(io_with_context, decompress: false)
        client_response.status_code.should eq 302
        client_response.headers.has_key?("Location").should be_true
        client_response.headers["Location"].should eq Kemal::Authorizer.config.anonymous_url
      end
    end
  end

  describe "AuthenticatedHandler" do
    methods = ["GET", "POST"]
    handler = Kemal::Authorizer::AuthenticationHandler.new({"/dashboard" => methods})

    it "redirects anonymous users to login" do
      methods.each do |method|
        request = HTTP::Request.new(method, "/dashboard")
        io_with_context = process_request(handler, request)

        client_response = HTTP::Client::Response.from_io(io_with_context, decompress: false)
        client_response.status_code.should eq 302
        client_response.headers.has_key?("Location").should be_true
        login_url = Kemal::Authorizer.config.login_url
        client_response.headers["Location"].should eq "#{login_url}?next=%2Fdashboard"
      end
    end

    it "accepts authenticated users" do
      methods.each do |method|
        request = HTTP::Request.new(method, "/dashboard")
        io_with_context = process_request(handler, request, authenticated: true)

        client_response = HTTP::Client::Response.from_io(io_with_context, decompress: false)
        client_response.status_code.should eq SUCCESS_CODE
      end
    end
  end

  describe "Authorization" do
    methods = ["GET", "POST"]
    handler = Kemal::Authorizer::AuthorizationHandler.new({"/admin" => methods})

    it "redirects anonymous users to login" do
      methods.each do |method|
        request = HTTP::Request.new(method, "/admin")
        io_with_context = process_request(handler, request)

        client_response = HTTP::Client::Response.from_io(io_with_context, decompress: false)
        client_response.status_code.should eq 302
        client_response.headers.has_key?("Location").should be_true
        login_url = Kemal::Authorizer.config.login_url
        client_response.headers["Location"].should eq "#{login_url}?next=%2Fadmin"
      end
    end

    it "blocks unauthorized users" do
      methods.each do |method|
        request = HTTP::Request.new(method, "/admin")
        io_with_context = process_request(handler, request, authenticated: true)

        client_response = HTTP::Client::Response.from_io(io_with_context, decompress: false)
        client_response.status_code.should eq 401
      end
    end

    it "accepts authorized users" do
      methods.each do |method|
        request = HTTP::Request.new(method, "/admin")
        io_with_context = process_request(handler, request, authenticated: true, authorized: true)

        client_response = HTTP::Client::Response.from_io(io_with_context, decompress: false)
        client_response.status_code.should eq SUCCESS_CODE
      end
    end
  end
end
