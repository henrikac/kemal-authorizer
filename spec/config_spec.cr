require "./spec_helper"

describe "Kemal::Authorizer" do
  describe "Config" do
    it "has default values set" do
      tests = [
        {
          default: Kemal::Authorizer::Config::DEFAULT_ANONYMOUS_URL,
          expected: "/"
        },
        {
          default: Kemal::Authorizer::Config::DEFAULT_LOGIN_URL,
          expected: "/login"
        },
        {
          default: Kemal::Authorizer::Config::DEFAULT_OBJ_NAME,
          expected: "user"
        },
        {
          default: Kemal::Authorizer::Config::DEFAULT_USER_TYPE,
          expected: Kemal::Authorizer::UserStorableObject
        },
      ]

      tests.each do |test|
        test[:default].should eq test[:expected]
      end
    end

    describe "INSTANCE" do
      it "returns a Kemal::Authorizer::Config object" do
        typeof(Kemal::Authorizer::Config::INSTANCE).should eq Kemal::Authorizer::Config
      end
    end

    describe "#user_type=" do
      after_each do
        Kemal::Authorizer.config.user_type = TestStorableUser
      end

      it "sets a new storable user type" do
        Kemal::Authorizer.config.user_type = NewStorableUserType

        Kemal::Authorizer.config.user_type.should eq NewStorableUserType
      end
    end
  end

  describe ".config" do
    it "returns Kemal::Authorizer::Config::INSTANCE" do
      Kemal::Authorizer.config.should be Kemal::Authorizer::Config::INSTANCE
    end

    it "yields Kemal::Authorizer::Config::INSTANCE" do
      Kemal::Authorizer.config do |config|
        config.should be Kemal::Authorizer::Config::INSTANCE
      end
    end
  end
end
