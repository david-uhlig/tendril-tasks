// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"

import "trix"
import "@rails/actiontext"
import * as Lexxy from "lexxy"

import "flowbite"
import "controllers"

// Configure Lexxy synchronously after the import, before the editors are registered
Lexxy.configure({
    default: {
        headings: [ "h2", "h3", "h4" ]
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

window.document.addEventListener("trix-before-initialize", () => {
    Trix.config.blockAttributes["heading2"] = { tagName: "h2", terminal: true, breakOnReturn: true, group: 'headings' };
    Trix.config.blockAttributes["heading3"] = { tagName: "h3", terminal: true, breakOnReturn: true, group: 'headings' };
    Trix.config.blockAttributes["heading4"] = { tagName: "h4", terminal: true, breakOnReturn: true, group: 'headings' };
    Trix.config.blockAttributes["heading5"] = { tagName: "h5", terminal: true, breakOnReturn: true, group: 'headings' };
    Trix.config.blockAttributes["heading6"] = { tagName: "h6", terminal: true, breakOnReturn: true, group: 'headings' };
});
