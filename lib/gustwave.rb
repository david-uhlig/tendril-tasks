# frozen_string_literal: true

# Gustwave is an unofficial implementation of the Flowbite UI library in
# ViewComponent.
#
# It aims to provide easily extensible, general-purpose components that can be
# fully customized and extended. Gustwave tries to stay as close to the original
# as possible without guarantees for pixel-perfect compatibility.
#
# Gustwave strictly only implements the Open Source components of Flowbite.
#
# @see https://github.com/david-uhlig/gustwave Gustwave on GitHub
# @see https://flowbite.com/docs/ Flowbite on the official website
# @see https://flowbite.com/docs/getting-started/license/ Flowbite MIT license
# @see https://tailwindcss.com/docs/ Tailwind CSS on the official website
# @see https://viewcomponent.org/ ViewComponent on the official website
module Gustwave
  # Base error class for all Gustwave-specific exceptions
  class Error < StandardError; end
end
