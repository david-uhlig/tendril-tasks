import { Controller } from "@hotwired/stimulus"

/**
 * Plays a short, dependency-free fireworks animation on a full-viewport canvas
 * over a dimmed backdrop. The backdrop fades in before the animation starts.
 * Toward the end of the animation, i.e. once the last rocket has launched, the
 * optional modal fades in and stays visible for `modalDuration`. Once both the
 * animation and the modal are done, the backdrop fades out and the element is
 * removed.
 *
 * Connects to:
 *   <div data-controller="fireworks" class="opacity-0 bg-gray-900/50 ...">
 *     <canvas data-fireworks-target="canvas"></canvas>
 *     <div data-fireworks-target="modal" class="opacity-0 ...">...</div>
 *   </div>
 *
 * The element and the modal should start out with `opacity-0`. The controller
 * removes `opacity-0` to fade them in and adds it back to fade them out.
 *
 * Users who prefer reduced motion won't see the animation; the element is
 * removed right away.
 *
 * ### Actions:
 * - `stop`: Ends the animation early and fades out, e.g. through a key press:
 *   `keydown.esc@window->fireworks#stop`
 *
 * ### Targets:
 * - `canvas`: The canvas to draw the fireworks on.
 * - `modal` (optional): Shown toward the end of the animation.
 *
 * ### Values:
 * - `rockets` (Number): Number of rockets to launch. Default: 5.
 * - `launchInterval` (Number): Delay in milliseconds between launches. Default: 250.
 * - `particles` (Number): Number of sparks per explosion. Default: 60.
 * - `colors` (Array): Spark colors. Default: a set of festive colors.
 * - `fadeDuration` (Number): Duration in milliseconds of the backdrop and modal fades. Default: 500.
 * - `modalDuration` (Number): Time in milliseconds the modal stays fully visible. Default: 5000.
 */
export default class extends Controller {
  static targets = ["canvas", "modal"]
  static values = {
    rockets: { type: Number, default: 5 },
    launchInterval: { type: Number, default: 250 },
    particles: { type: Number, default: 100 },
    colors: {
      type: Array,
      default: ["#f43f5e", "#f59e0b", "#10b981", "#3b82f6", "#a855f7", "#ec4899", "#facc15"]
    },
    fadeDuration: { type: Number, default: 500 },
    modalDuration: { type: Number, default: 5000 }
  }

  static GRAVITY = 0.06
  static FRICTION = 0.985
  static HIDDEN_CLASS = "opacity-0"

  connect() {
    if (window.matchMedia("(prefers-reduced-motion: reduce)").matches) {
      this.element.remove()
      return
    }

    this.ctx = this.canvasTarget.getContext("2d")
    this.rockets = []
    this.sparks = []
    this.launched = 0
    this.resize = this.resize.bind(this)
    this.tick = this.tick.bind(this)

    this.resize()
    window.addEventListener("resize", this.resize)

    this.fadeIn(this.element, () => this.start())
  }

  disconnect() {
    clearTimeout(this.fadeTimer)
    clearTimeout(this.modalTimer)
    clearInterval(this.launchTimer)
    cancelAnimationFrame(this.frame)
    window.removeEventListener("resize", this.resize)
  }

  resize() {
    const ratio = window.devicePixelRatio || 1
    this.width = window.innerWidth
    this.height = window.innerHeight
    this.canvasTarget.width = this.width * ratio
    this.canvasTarget.height = this.height * ratio
    this.ctx.setTransform(ratio, 0, 0, ratio, 0, 0)
  }

  // Uses timeouts rather than `transitionend`, which never fires when
  // transitions are disabled, e.g. in tests.
  fadeIn(element, callback) {
    element.style.transitionProperty = "opacity"
    element.style.transitionDuration = `${this.fadeDurationValue}ms`
    // Force a reflow, so the browser registers the initial opacity before it changes
    element.offsetHeight
    element.classList.remove(this.constructor.HIDDEN_CLASS)
    return setTimeout(callback, this.fadeDurationValue)
  }

  fadeOut(element, callback) {
    element.classList.add(this.constructor.HIDDEN_CLASS)
    return setTimeout(callback, this.fadeDurationValue)
  }

  stop() {
    if (this.stopping) return
    this.stopping = true

    clearTimeout(this.fadeTimer)
    clearTimeout(this.modalTimer)
    clearInterval(this.launchTimer)
    cancelAnimationFrame(this.frame)
    this.fadeTimer = this.fadeOut(this.element, () => this.element.remove())
  }

  showModal() {
    if (!this.hasModalTarget) {
      this.modalDone = true
      return
    }

    this.modalTimer = this.fadeIn(this.modalTarget, () => {
      this.modalTimer = setTimeout(() => {
        this.modalDone = true
        this.stopWhenDone()
      }, this.modalDurationValue)
    })
  }

  stopWhenDone() {
    if (this.animationDone && this.modalDone) this.stop()
  }

  start() {
    this.launch()
    this.launchTimer = setInterval(() => this.launch(), this.launchIntervalValue)
    this.frame = requestAnimationFrame(this.tick)
  }

  launch() {
    if (this.launched >= this.rocketsValue) return
    this.launched++

    if (this.launched === this.rocketsValue) {
      clearInterval(this.launchTimer)
      this.showModal()
    }

    const x = this.width * (0.2 + Math.random() * 0.6)
    const targetY = this.height * (0.15 + Math.random() * 0.3)
    // Initial speed needed to reach targetY under gravity: v = sqrt(2 * g * distance)
    const vy = -Math.sqrt(2 * this.constructor.GRAVITY * (this.height - targetY))

    this.rockets.push({ x, y: this.height, vx: (Math.random() - 0.5) * 2, vy, color: this.randomColor() })
  }

  explode(rocket) {
    for (let i = 0; i < this.particlesValue; i++) {
      const angle = (Math.PI * 2 * i) / this.particlesValue
      const speed = 1.5 + Math.random() * 3
      this.sparks.push({
        x: rocket.x,
        y: rocket.y,
        vx: Math.cos(angle) * speed,
        vy: Math.sin(angle) * speed,
        alpha: 1,
        decay: 0.012 + Math.random() * 0.012,
        color: Math.random() < 0.7 ? rocket.color : this.randomColor()
      })
    }
  }

  tick() {
    const { GRAVITY, FRICTION } = this.constructor
    const ctx = this.ctx
    ctx.clearRect(0, 0, this.width, this.height)

    this.rockets = this.rockets.filter((rocket) => {
      rocket.x += rocket.vx
      rocket.y += rocket.vy
      rocket.vy += GRAVITY

      if (rocket.vy >= 0) {
        this.explode(rocket)
        return false
      }

      this.drawDot(rocket.x, rocket.y, 2.5, rocket.color, 1)
      return true
    })

    this.sparks = this.sparks.filter((spark) => {
      spark.vx *= FRICTION
      spark.vy = spark.vy * FRICTION + GRAVITY
      spark.x += spark.vx
      spark.y += spark.vy
      spark.alpha -= spark.decay

      if (spark.alpha <= 0) return false

      this.drawDot(spark.x, spark.y, 2, spark.color, spark.alpha)
      return true
    })

    const done = this.launched >= this.rocketsValue && this.rockets.length === 0 && this.sparks.length === 0
    if (done) {
      this.animationDone = true
      this.stopWhenDone()
    } else {
      this.frame = requestAnimationFrame(this.tick)
    }
  }

  drawDot(x, y, radius, color, alpha) {
    const ctx = this.ctx
    ctx.globalAlpha = alpha
    ctx.fillStyle = color
    ctx.beginPath()
    ctx.arc(x, y, radius, 0, Math.PI * 2)
    ctx.fill()
    ctx.globalAlpha = 1
  }

  randomColor() {
    return this.colorsValue[Math.floor(Math.random() * this.colorsValue.length)]
  }
}
