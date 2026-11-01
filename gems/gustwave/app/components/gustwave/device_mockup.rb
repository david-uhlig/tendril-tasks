# frozen_string_literal: true

module Gustwave
  # Use DeviceMockup to draw a device frame around your content, such as a
  # screenshot or a live example. Matches Flowbite's device mockups.
  #
  # Examples:
  #
  # Renders a phone with the block as its screen:
  #
  #   <%= render Gustwave::DeviceMockup.new do %>
  #     <div class="size-full bg-linear-to-br from-blue-500 to-purple-600"></div>
  #   <% end %>
  #
  # Pick another device, and the light frame:
  #
  #   <%= render Gustwave::DeviceMockup.new(device: :laptop, color: :light) do %>
  #     ...
  #   <% end %>
  #
  # Compose light and dark screenshots with two images:
  #
  #   <%= render Gustwave::DeviceMockup.new(device: :iphone) do %>
  #     <%= image_tag "light.png", alt: "Dashboard", class: "dark:hidden size-full" %>
  #     <%= image_tag "dark.png", alt: "Dashboard", class: "hidden dark:block size-full" %>
  #   <% end %>
  #
  # The +none+ color renders the shapes without their colors. Add a brand color
  # by targeting the parts by name:
  #
  #   Gustwave::DeviceMockup.extend_variant :color, values: {
  #     brand: { frame: "border-brand-800 bg-brand-800", notch: "bg-brand-800" }
  #   }
  #
  # You can pass HTML attributes to the wrapper element, and your css classes
  # will be merged with its classes:
  #
  #   <%= render Gustwave::DeviceMockup.new(id: "demo", class: "my-8") do %>
  #     ...
  #   <% end %>
  #
  # @param device [Symbol] +:phone+ (default), +:iphone+, +:android+, +:tablet+, +:laptop+, +:desktop+ or +:smartwatch+.
  # @param color [Symbol] +:dark+ (default), +:light+ or +:none+.
  # @param options [Hash] HTML attributes for the wrapper element.
  class DeviceMockup < Gustwave::Component
    # The small pieces on the frame that share one color
    SIDE_PARTS = %i[notch action_button volume_up_button volume_down_button power_button crown crown_button].freeze

    part :frame, "relative mx-auto"
    part :screen, "overflow-hidden"
    part :notch, "absolute top-0 left-1/2 -translate-x-1/2 w-[148px] h-[18px] rounded-b-[1rem]"
    part :action_button, "absolute -start-[17px] top-[72px] h-[32px] w-[3px] rounded-s-lg"
    part :volume_up_button, "absolute -start-[17px] top-[124px] h-[46px] w-[3px] rounded-s-lg"
    part :volume_down_button, "absolute -start-[17px] top-[178px] h-[46px] w-[3px] rounded-s-lg"
    part :power_button, "absolute -end-[17px] top-[142px] h-[64px] w-[3px] rounded-e-lg"
    part :crown, "absolute -end-[16px] top-[40px] h-[41px] w-[6px] rounded-e-lg"
    part :crown_button, "absolute -end-[16px] top-[88px] h-[32px] w-[6px] rounded-e-lg"
    part :strap_top, "relative mx-auto rounded-t-[2.5rem] h-[63px] max-w-[133px]"
    part :strap_bottom, "relative mx-auto rounded-b-[2.5rem] h-[63px] max-w-[133px]"
    part :keyboard, "relative mx-auto rounded-b-xl rounded-t-sm h-[17px] max-w-[351px] md:h-[21px] md:max-w-[597px]"
    part :keyboard_notch, "absolute left-1/2 top-0 -translate-x-1/2 rounded-b-xl w-[56px] h-[5px] md:w-[96px] md:h-[8px]"
    part :chin, "relative mx-auto rounded-b-xl h-[24px] max-w-[301px] md:h-[42px] md:max-w-[512px]"
    part :stand, "relative mx-auto rounded-b-xl h-[55px] max-w-[83px] md:h-[95px] md:max-w-[142px]"

    # The shape of the frame and the screen
    variant :device, default: :phone, values: {
      phone: {
        frame: "border-[14px] rounded-[2.5rem] h-[600px] w-[300px]",
        screen: "rounded-[2rem] w-[272px] h-[572px] bg-white dark:bg-gray-800"
      },
      iphone: {
        frame: "border-[14px] rounded-[2.5rem] h-[600px] w-[300px] shadow-xl",
        screen: "rounded-[2rem] w-[272px] h-[572px] bg-white dark:bg-gray-800"
      },
      android: {
        frame: "border-[14px] rounded-xl h-[600px] w-[300px] shadow-xl",
        screen: "rounded-xl w-[272px] h-[572px] bg-white dark:bg-gray-800"
      },
      tablet: {
        frame: "border-[14px] rounded-[2.5rem] h-[454px] max-w-[341px] md:h-[682px] md:max-w-[512px]",
        screen: "rounded-[2rem] h-[426px] md:h-[654px] bg-white dark:bg-gray-800"
      },
      laptop: {
        frame: "border-[8px] rounded-t-xl h-[172px] max-w-[301px] md:h-[294px] md:max-w-[512px]",
        screen: "rounded-lg h-[156px] md:h-[278px] bg-white dark:bg-gray-800"
      },
      desktop: {
        frame: "border-[16px] rounded-t-xl h-[172px] max-w-[301px] md:h-[294px] md:max-w-[512px]",
        screen: "rounded-xl h-[140px] md:h-[262px]"
      },
      smartwatch: {
        frame: "border-[10px] rounded-[2.5rem] h-[213px] w-[208px]",
        screen: "rounded-[2rem] h-[193px] w-[188px]"
      }
    }

    # The colors of the pieces, by part. The +none+ color renders the shapes only.
    variant :color, default: :dark, values: {
      dark: {
        frame: "border-gray-800 dark:border-gray-800 bg-gray-800",
        **SIDE_PARTS.index_with("bg-gray-800 dark:bg-gray-800"),
        strap_top: "bg-gray-800 dark:bg-gray-700",
        strap_bottom: "bg-gray-800 dark:bg-gray-700",
        keyboard: "bg-gray-900 dark:bg-gray-700",
        chin: "bg-gray-900 dark:bg-gray-700",
        keyboard_notch: "bg-gray-800",
        stand: "bg-gray-800"
      },
      light: {
        frame: "border-gray-300 dark:border-gray-800 bg-gray-300 dark:bg-gray-800",
        **SIDE_PARTS.index_with("bg-gray-300 dark:bg-gray-800"),
        strap_top: "bg-gray-300 dark:bg-gray-700",
        strap_bottom: "bg-gray-300 dark:bg-gray-700",
        keyboard: "bg-gray-400 dark:bg-gray-700",
        chin: "bg-gray-400 dark:bg-gray-700",
        keyboard_notch: "bg-gray-300 dark:bg-gray-800",
        stand: "bg-gray-300 dark:bg-gray-800"
      }
    }

    # The pieces each device renders besides its frame and screen
    derive :elements, from: :device, values: {
      phone: %i[action_button volume_up_button volume_down_button power_button],
      iphone: %i[notch volume_up_button volume_down_button power_button],
      android: %i[notch action_button volume_up_button volume_down_button power_button],
      tablet: %i[action_button volume_up_button volume_down_button power_button],
      laptop: %i[keyboard keyboard_notch],
      desktop: %i[chin stand],
      smartwatch: %i[strap_top crown crown_button strap_bottom]
    }

    # @param device [Symbol] the device to draw, see the class documentation.
    # @param color [Symbol] +:dark+, +:light+ or +:none+.
    # @param options [Hash] HTML attributes for the wrapper element.
    def initialize(device: DEFAULT, color: DEFAULT, **options)
      select_options(device:, color:)
      @options = attributes_for(options)
    end

    private

    # Whether the device renders the piece. The implicit +none+ device has none.
    def element?(name)
      Array(derived_value(:elements)).include?(name)
    end
  end
end
