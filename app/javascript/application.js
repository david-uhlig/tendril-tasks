// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"

import * as Lexxy from "lexxy"

import "flowbite"
import "controllers"

// Configure Lexxy synchronously after the import, before the editors are registered
Lexxy.configure({
    default: {
        headings: [ "h1", "h2", "h3", "h4" ]
    }
});

/**
 * Reattach Flowbite Turbo after events like 422 Unprocessable Content
 *
 * see: https://github.com/themesberg/flowbite/issues/88#issuecomment-1962238351
 */
window.document.addEventListener("turbo:render", (_event) => {
    window.initFlowbite();
});
