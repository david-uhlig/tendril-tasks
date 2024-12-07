import { Controller } from "@hotwired/stimulus"

/**
 * Connects to elements with `data-controller="deeplink"` and modifies
 * the behavior of links on mobile devices.
 * It overrides the default link behavior to redirect users to a specific
 * application URL defined by a `data-app-link` attribute.
 *
 * Key Features:
 * - Detects mobile clients using the `navigator.userAgent` property.
 * - Overrides link click events only for mobile clients.
 * - Redirects users to an application-specific URL via the `data-app-link` attribute.
 */
export default class extends Controller {
  // Static property to indicate whether the current client is a mobile device.
  static isMobile = false

  /**
   * Called when the controller instance is created. Initializes the `isMobile` property
   * to determine if the user is on a mobile device.
   */
  initialize() {
    this.constructor.isMobile = this.isMobileClient()
  }

  /**
   * Called when the controller connects to the DOM. Adds an event listener to the
   * controller's element if the user is on a mobile device.
   */
  connect() {
    // Only interfere with links on mobile clients
    if (this.constructor.isMobile) {
      this.element.addEventListener("click", (event) => {
        event.preventDefault()
        this.onClick(this.element)
      })
    }
  }

  /**
   * Handles the click event on the element. Redirects the user to the app-specific URL
   * defined in the `data-app-link` attribute.
   *
   * @param {HTMLElement} element - The HTML element that triggered the event.
   */
  onClick(element) {
    // Set by the `data-app-link` attribute
    window.location.href = element.dataset.appLink
  }

  /**
   * Determines if the current client is a mobile device.
   * Uses the `navigator.userAgent` property to identify mobile clients.
   *
   * Special Cases:
   * - Excludes Windows Phone devices (as they are considered mobile but unsupported).
   *
   * @returns {boolean} - Returns `true` if the client is a supported mobile device, otherwise `false`.
   */
  isMobileClient() {
    const userAgent = navigator.userAgent

    // Windows Phone is a mobile client, but has no Rocket Chat app.
    // Must be matched first because the UA also contains "Android".
    if (userAgent.match(/windows phone/i)) {
      return false
    }

    return !!userAgent.match(/iphone|ipad|ipod|android/i)
  }
}
