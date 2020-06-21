require "test_helper"

describe UsersController do
  describe "index" do
    it "successfully retrieves index" do
    end
  end

  describe "show" do
    it "successfully retrieves show pages" do
    end

    it "errors when retrieving a page for a nonexistent product" do
    end
  end

  describe "create" do
    it "logs in a new user" do
    end

    it "logs in a returning user" do
    end

    it "does not create a user account for malformed github requests" do
    end
  end

  describe "logout" do
    it "removes the user from session" do
    end

    it "flashes error message when no user is logged in" do
    end
  end
end
