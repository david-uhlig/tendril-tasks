module ComponentTestHelpers
  include ViewComponent::TestHelpers

  # Mock current_user
  #
  # @param user [User] the user that should become current_user
  # @see https://github.com/ViewComponent/view_component/discussions/371
  def as(user)
    allow(vc_test_controller).to receive(:current_user).and_return(user)
  end
end
