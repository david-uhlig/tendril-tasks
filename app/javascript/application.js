// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "flowbite"
import "controllers"

/**
 * Reattach Flowbite Turbo after events like 422 Unprocessable Entity
 *
 * see: https://github.com/themesberg/flowbite/issues/88#issuecomment-1962238351
 */
window.document.addEventListener("turbo:render", (_event) => {
    window.initFlowbite();
});


import "trix"
import "@rails/actiontext"
