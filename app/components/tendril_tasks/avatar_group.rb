# frozen_string_literal: true

module TendrilTasks
  # Use AvatarGroup to render an overlapping group of avatars.
  #
  # You can determine the TendrilTask::Avatars appearance by passing in the
  # +scheme+, +size+, +border+, and +avatar_options+.
  #
  # You can also specify the total size of the stack with the +visible_count+
  # option. If the number of passed in user objects is greater than the
  # +visible_count+, the number of visible avatars will be reduced to the
  # +visible_count-1+ and a dummy avatar indicating the number of additional
  # users will be displayed.
  #
  # Instead of passing in large users arrays, you can also specify the total
  # number of users with the +total_count+ option. To set an upper bound on the
  # number displayed on the dummy avatar, you can pass in the +max_hidden_count+
  # option.
  #
  # @param users [Array<User>] the users to be displayed.
  # @param scheme [Symbol] the scheme of the avatar.
  # @param size [Symbol] the size of the avatar.
  # @param border [Boolean] whether the avatar should have a border.
  # @param avatar_options [Hash] additional options to be passed to the +TendrilTasks::Avatar+ component.
  # @param visible_count [Integer] the number of avatars to be displayed.
  # @param total_count [Integer] the total number of users.
  # @param max_hidden_count [Integer] the maximum number of users to be displayed on the dummy avatar.
  # @param options [Hash] additional options to be passed to +Gustwave::AvatarGroup+
  class AvatarGroup < TendrilTasks::Component
    def initialize(users,
                   scheme: nil,
                   size: nil,
                   border: nil,
                   avatar_options: {},
                   visible_count: nil,
                   total_count: nil,
                   max_hidden_count: nil,
                   **options)
      options.deep_symbolize_keys!
      avatar_options.deep_symbolize_keys!
      kwargs = { scheme:, size:, border: }.compact

      @options = options
      @avatar_options = kwargs.merge!(avatar_options)
      @users = users
      @visible_count = visible_count
      @total_count = total_count || users.size
      @max_hidden_count = max_hidden_count
    end

    def render?
      users.present? && users.size > 0
    end

    def call
      displayed_users = users.first(number_of_avatars_visible)

      render Gustwave::AvatarGroup.new(**options) do
        concat render(
                 TendrilTasks::Avatar.with_collection(
                   displayed_users,
                   **avatar_options))

        if hidden_avatars?
          concat render(
                   Gustwave::AvatarText.new(
                     text: "+#{number_of_hidden_avatars}",
                     **avatar_options))
        end
      end
    end

    private

    attr_reader :options, :users, :avatar_options
    attr_reader :visible_count, :total_count, :max_hidden_count

    def number_of_avatars_visible
      @number_of_avatars_visible ||= total_count unless visible_count.present?
      @number_of_avatars_visible ||=
        if total_count == visible_count
          visible_count
        else
          [ total_count, visible_count - 1 ].min
        end
    end

    def number_of_hidden_avatars
      @number_of_hidden_avatars ||= [ total_count - number_of_avatars_visible, max_hidden_count ].compact.min
    end

    def hidden_avatars?
      number_of_hidden_avatars > 0
    end
  end
end
