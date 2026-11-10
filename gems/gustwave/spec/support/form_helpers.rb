# frozen_string_literal: true

# A record for the form specs
class FormSpecTask
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :title, :string
  attribute :due_on, :date
  attribute :project_id, :integer
  attribute :password, :string
  attribute :country, :string
  attribute :body, :string
  attribute :tags, default: -> { [] }

  validates :title, presence: true
end

# Builders and the class sets of Flowbite's input examples, shared by the
# specs of Gustwave::Form::Input, Gustwave::Form::Field and
# Gustwave::FormBuilder.
module FormSpecHelpers
  # Flowbite's "Input fields" example, i.e. the default input
  FLOWBITE_INPUT = "bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-500 " \
                   "focus:border-blue-500 block w-full p-2.5 dark:bg-gray-700 dark:border-gray-600 " \
                   "dark:placeholder-gray-400 dark:text-white dark:focus:ring-blue-500 dark:focus:border-blue-500"

  # Flowbite's "Input sizes" example
  FLOWBITE_INPUT_LARGE = "block w-full p-4 text-gray-900 border border-gray-300 rounded-lg bg-gray-50 text-base " \
                         "focus:ring-blue-500 focus:border-blue-500 dark:bg-gray-700 dark:border-gray-600 " \
                         "dark:placeholder-gray-400 dark:text-white dark:focus:ring-blue-500 dark:focus:border-blue-500"
  FLOWBITE_INPUT_SMALL = "block w-full p-2 text-gray-900 border border-gray-300 rounded-lg bg-gray-50 text-xs " \
                         "focus:ring-blue-500 focus:border-blue-500 dark:bg-gray-700 dark:border-gray-600 " \
                         "dark:placeholder-gray-400 dark:text-white dark:focus:ring-blue-500 dark:focus:border-blue-500"

  # Flowbite's "Disabled state" example
  FLOWBITE_INPUT_DISABLED = "bg-gray-100 border border-gray-300 text-gray-900 text-sm rounded-lg " \
                            "focus:ring-blue-500 focus:border-blue-500 block w-full p-2.5 cursor-not-allowed " \
                            "dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-gray-400 " \
                            "dark:focus:ring-blue-500 dark:focus:border-blue-500"

  # Flowbite's "Validation" example
  FLOWBITE_INPUT_SUCCESS = "bg-green-50 border border-green-500 text-green-900 dark:text-green-400 " \
                           "placeholder-green-700 dark:placeholder-green-500 text-sm rounded-lg " \
                           "focus:ring-green-500 focus:border-green-500 block w-full p-2.5 dark:bg-gray-700 " \
                           "dark:border-green-500"
  FLOWBITE_INPUT_ERROR = "bg-red-50 border border-red-500 text-red-900 placeholder-red-700 text-sm rounded-lg " \
                         "focus:ring-red-500 dark:bg-gray-700 focus:border-red-500 block w-full p-2.5 " \
                         "dark:text-red-500 dark:placeholder-red-500 dark:border-red-500"

  # Flowbite's "Input group" example, with the icon
  FLOWBITE_INPUT_WITH_ICON = "bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg " \
                             "focus:ring-blue-500 focus:border-blue-500 block w-full ps-10 p-2.5 dark:bg-gray-700 " \
                             "dark:border-gray-600 dark:placeholder-gray-400 dark:text-white " \
                             "dark:focus:ring-blue-500 dark:focus:border-blue-500"

  # Flowbite's "Textarea example"
  FLOWBITE_TEXTAREA = "block p-2.5 w-full text-sm text-gray-900 bg-gray-50 rounded-lg border border-gray-300 " \
                      "focus:ring-blue-500 focus:border-blue-500 dark:bg-gray-700 dark:border-gray-600 " \
                      "dark:placeholder-gray-400 dark:text-white dark:focus:ring-blue-500 dark:focus:border-blue-500"

  # Flowbite's "WYSIWYG Editor" and "Comment box" textarea examples: the frame
  # without its margin, the bars, the body next to each bar, and the textarea
  # in the frame
  FLOWBITE_TEXTAREA_FRAME = "w-full border border-gray-200 rounded-lg bg-gray-50 dark:bg-gray-700 dark:border-gray-600"
  FLOWBITE_TEXTAREA_HEADER = "flex items-center justify-between px-3 py-2 border-b border-gray-200 dark:border-gray-600"
  FLOWBITE_TEXTAREA_BODY_UNDER_HEADER = "px-4 py-2 bg-white rounded-b-lg dark:bg-gray-800"
  FLOWBITE_TEXTAREA_BODY_ABOVE_FOOTER = "px-4 py-2 bg-white rounded-t-lg dark:bg-gray-800"
  FLOWBITE_TEXTAREA_FOOTER = "flex items-center justify-between px-3 py-2 border-t dark:border-gray-600 border-gray-200"
  FLOWBITE_TEXTAREA_FRAMED = "block w-full px-0 text-sm text-gray-900 bg-white border-0 focus:ring-0 dark:bg-gray-800 " \
                             "dark:text-white dark:placeholder-gray-400"

  # Flowbite's "Select input example" is the default select, with the classes
  # of the default input. Its "Sizes" example has the small and the large one,
  # without the example's +mb-6+.
  FLOWBITE_SELECT = FLOWBITE_INPUT
  FLOWBITE_SELECT_SMALL = "block w-full p-2 text-sm text-gray-900 border border-gray-300 rounded-lg bg-gray-50 " \
                          "focus:ring-blue-500 focus:border-blue-500 dark:bg-gray-700 dark:border-gray-600 " \
                          "dark:placeholder-gray-400 dark:text-white dark:focus:ring-blue-500 dark:focus:border-blue-500"
  FLOWBITE_SELECT_LARGE = "block w-full px-4 py-3 text-base text-gray-900 border border-gray-300 rounded-lg bg-gray-50 " \
                          "focus:ring-blue-500 focus:border-blue-500 dark:bg-gray-700 dark:border-gray-600 " \
                          "dark:placeholder-gray-400 dark:text-white dark:focus:ring-blue-500 dark:focus:border-blue-500"

  # Flowbite's "Underline select" example
  FLOWBITE_SELECT_UNDERLINE = "block py-2.5 px-0 w-full text-sm text-gray-500 bg-transparent border-0 border-b-2 " \
                              "border-gray-200 appearance-none dark:text-gray-400 dark:border-gray-700 " \
                              "focus:outline-none focus:ring-0 focus:border-gray-200 peer"

  # The class set of a string, so specs compare sets and not their order.
  def class_set(classes)
    classes.to_s.split.to_set
  end

  def task(**attributes)
    FormSpecTask.new(**attributes)
  end

  def invalid_task(**attributes)
    task(**attributes).tap(&:validate)
  end

  # A form builder as +form_with+ makes it.
  def form_builder(object = task, name: :task, builder: ActionView::Helpers::FormBuilder, **options)
    builder.new(name, object, vc_test_controller.view_context, options)
  end
end

RSpec.configure do |config|
  config.include FormSpecHelpers, type: :component
end
