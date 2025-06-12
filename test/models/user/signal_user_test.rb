require "test_helper"

class User::SignalUserTest < ActiveSupport::TestCase
  setup do
    @user = users(:david)
  end

  test "belongs to a Signal::User" do
    assert_not_nil @user.signal_user_id
    assert_equal signal_users("37s_fizzy_david"), @user.signal_user
  end
end
