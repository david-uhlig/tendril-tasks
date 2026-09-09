# frozen_string_literal: true

module RequestHelpers
  # Evaluates the given block and expects a redirect to the login page.
  #
  # @example
  #   it "requires authentication" do
  #     require_authentication_for { get "/some_protected_route" }
  #   end
  #
  # @param block [Proc] The block to evaluate
  def require_authentication_for(&block)
    block.call if block_given?
    expect(response).to redirect_to(new_user_session_path)
  end
end
