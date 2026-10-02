import { Controller } from "@hotwired/stimulus"

/**
 * Plays a short, dependency-free fireworks animation on a full-viewport canvas
 * over a dimmed backdrop. The backdrop fades in before the animation starts and
 * fades out after it has finished; then the element is removed.
 *
 * Connects to:
 *   <div data-controller="fireworks" class="opacity-0 bg-gray-900/50 ...">
 *     <canvas data-fireworks-target="canvas"></canvas>
 *   </div>
 *
 * The element should start out with `opacity-0` and carry the backdrop styles.
 * The controller removes `opacity-0` to fade in and adds it back to fade out.
 *
 * Users who prefer reduced motion won't see the animation; the element is
 * removed right away.
 *
 * ### Targets:
 * - `canvas`: The canvas to draw the fireworks on.
 *
 * ### Values:
 * - `rockets` (Number): Number of rockets to launch. Default: 5.
 * - `launchInterval` (Number): Delay in milliseconds between launches. Default: 250.
 * - `particles` (Number): Number of sparks per explosion. Default: 60.
 * - `colors` (Array): Spark colors. Default: a set of festive colors.
 * - `fadeDuration` (Number): Duration in milliseconds of the backdrop fade in and out. Default: 400.
 */
export default class extends Controller {
  static targets = ["canvas"]
  static values = {
    rockets: { type: Number, default: 5 },
    launchInterval: { type: Number, default: 250 },
    particles: { type: Number, default: 100 },
    colors: {
      type: Array,
      default: ["#f43f5e", "#f59e0b", "#10b981", "#3b82f6", "#a855f7", "#ec4899", "#facc15"]
    },
    fadeDuration: { type: Number, default: 500 }
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

    this.fadeIn(() => this.start())
  }

  disconnect() {
    clearTimeout(this.fadeTimer)
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
  fadeIn(callback) {
    this.element.style.transitionProperty = "opacity"
    this.element.style.transitionDuration = `${this.fadeDurationValue}ms`
    // Force a reflow, so the browser registers the initial opacity before it changes
    this.element.offsetHeight
    this.element.classList.remove(this.constructor.HIDDEN_CLASS)
    this.fadeTimer = setTimeout(callback, this.fadeDurationValue)
  }

  fadeOut(callback) {
    this.element.classList.add(this.constructor.HIDDEN_CLASS)
    this.fadeTimer = setTimeout(callback, this.fadeDurationValue)
  }

  start() {
    this.launch()
    this.launchTimer = setInterval(() => this.launch(), this.launchIntervalValue)
    this.frame = requestAnimationFrame(this.tick)
  }

  launch() {
    if (this.launched >= this.rocketsValue) {
      clearInterval(this.launchTimer)
      return
    }
    this.launched++

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
      this.fadeOut(() => this.element.remove())
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
