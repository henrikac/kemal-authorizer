require "./spec_helper"

describe "Kemal::Authorizer" do
  describe "UserStorableObject" do
    it "is by default not admin" do
      user = Kemal::Authorizer::UserStorableObject.new(1, "user@mail.com")
      user.is_admin.should be_false
    end
  end
end
