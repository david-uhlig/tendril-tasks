import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="template"
/**
 * Use this controller to dynamically include content from a html `<template>`
 * element to a container element receiver.
 *
 * Usage:
 * - Add `data-controller="template" to the container element (or one of its parents).
 * - Add `data-template-target="receiver" to the container that receives the template.
 * - Add the action descriptor, e.g. `data-action="click->template#append"` to
 *   the HTML trigger element.
 * - Add `data-template-selector="css-selector"` to specify the css selector of
 *   the template element.
 * - Add `data-template-receiver="css-selector"` to the `data-action` element to
 *   specify the css selector of the receiving container. This overwrites
 *   `data-template-target`.
 */
export default class extends Controller {
  static targets = [ "receiver" ]

  append(event) {
    this._insertContent(event, 'append')
  }

  replace(event) {
    this._insertContent(event, 'replace')
  }

  _insertContent(event, action) {
    const element = event.currentTarget
    const selector = this._resolveSelector(element)
    if (!selector) return

    const template = this._fetchTemplate(selector)
    if (!template) return

    const receiver = this._resolveReceiver(element)
    if (!receiver) return

    const clone = template.content.cloneNode(true)
    if (action === 'append') {
      receiver.appendChild(clone)
    } else if (action === 'replace') {
      receiver.replaceWith(clone)
    }
  }

  _resolveReceiver(element) {
    const selector = element.dataset.templateReceiver

    if (selector) {
      const receiver = element.closest(selector) || document.querySelector(selector)
      if (receiver) return receiver

      this._notifyUser(`Receiver "${selector}" was not found in the document`)
      return null
    }

    if (!this.hasReceiverTarget) {
      this._notifyUser('Add `data-template-target="receiver"` to the receiving element or `data-template-receiver="css-selector"` to the `data-action` trigger element.')
      return null
    }

    return this.receiverTarget
  }

  _resolveSelector(element) {
    const selector = element.dataset.templateSelector || null
    if (!selector) {
      this._notifyUser("Please add `data-template-selector='css-selector'` to the data-action element.")
      return null
    }
    return selector
  }

  _fetchTemplate(selector) {
    const template = document.querySelector(selector)
    if (!template) {
      this._notifyUser(`No template found matching the selector "${selector}"`)
      return null
    }

    if (!(template instanceof HTMLTemplateElement)) {
      this._notifyUser(`Element "${selector}" is not a <template>`)
      return null
    }

    return template
  }

  _notifyUser(message) {
    console.error(message);
  }
}
