/* Shared sound effects for the site's own games.
   - Makes simple beeps with the Web Audio API (no sound files needed).
   - Adds a speaker button (top right) and the M key to mute/unmute.
   - Shows a short "this game has sound" warning when the game opens.
   Mute is remembered for every game on the site.

   Use:  <script src="../sound.js"></script>
         SFX.play("eat");                                    // a built-in sound
         SFX.tone(440, 0.1, "square", 0.2, 880);             // or a custom beep  */
(function () {
  const KEY = "bgs-muted";
  let muted = false;
  try { muted = localStorage.getItem(KEY) === "1"; } catch (e) {}
  let ctx = null;
  function ac() {
    if (!ctx) { try { ctx = new (window.AudioContext || window.webkitAudioContext)(); } catch (e) { return null; } }
    if (ctx.state === "suspended") ctx.resume();
    return ctx;
  }
  ["keydown", "pointerdown", "touchstart"].forEach(ev => addEventListener(ev, () => { if (!muted) ac(); }, { passive: true }));

  function tone(freq, dur = 0.1, type = "square", vol = 0.15, slideTo = null, delay = 0) {
    if (muted) return;
    const c = ac(); if (!c) return;
    const t = c.currentTime + delay;
    const o = c.createOscillator(), g = c.createGain();
    o.type = type; o.frequency.setValueAtTime(freq, t);
    if (slideTo) o.frequency.exponentialRampToValueAtTime(slideTo, t + dur);
    g.gain.setValueAtTime(vol, t);
    g.gain.exponentialRampToValueAtTime(0.0001, t + dur);
    o.connect(g); g.connect(c.destination);
    o.start(t); o.stop(t + dur + 0.02);
  }
  function noise(dur = 0.2, vol = 0.2, delay = 0) {
    if (muted) return;
    const c = ac(); if (!c) return;
    const t = c.currentTime + delay;
    const buf = c.createBuffer(1, Math.floor(c.sampleRate * dur), c.sampleRate), d = buf.getChannelData(0);
    for (let i = 0; i < d.length; i++) d[i] = (Math.random() * 2 - 1) * (1 - i / d.length);
    const s = c.createBufferSource(), g = c.createGain();
    s.buffer = buf; g.gain.value = vol; s.connect(g); g.connect(c.destination); s.start(t);
  }

  const SOUNDS = {
    move:   () => tone(220, 0.03, "square", 0.05),
    rotate: () => tone(440, 0.05, "square", 0.07, 520),
    drop:   () => { tone(160, 0.08, "square", 0.15, 70); noise(0.06, 0.08); },
    land:   () => tone(120, 0.05, "triangle", 0.15),
    hold:   () => tone(330, 0.08, "triangle", 0.12, 660),
    clear:  () => [523, 659, 784].forEach((f, i) => tone(f, 0.12, "square", 0.1, null, i * 0.06)),
    tetris: () => [523, 659, 784, 1047].forEach((f, i) => tone(f, 0.16, "square", 0.12, null, i * 0.07)),
    level:  () => [392, 523, 659, 784, 1047].forEach((f, i) => tone(f, 0.1, "triangle", 0.15, null, i * 0.07)),
    eat:    () => tone(600, 0.08, "square", 0.12, 900),
    gold:   () => [880, 1175, 1568].forEach((f, i) => tone(f, 0.1, "triangle", 0.15, null, i * 0.05)),
    turn:   () => tone(300, 0.02, "square", 0.03),
    warp:   () => tone(300, 0.25, "sine", 0.18, 1200),
    flip:   () => tone(500, 0.12, "sine", 0.15, 200),
    jump:   () => tone(300, 0.12, "square", 0.1, 600),
    flap:   () => tone(500, 0.07, "triangle", 0.15, 800),
    spring: () => tone(250, 0.25, "square", 0.12, 1000),
    point:  () => { tone(988, 0.06, "square", 0.08); tone(1319, 0.12, "square", 0.08, null, 0.06); },
    merge:  () => tone(440, 0.07, "sine", 0.14, 660),
    slide:  () => tone(180, 0.04, "triangle", 0.06),
    win:    () => [523, 659, 784, 1047, 784, 1047].forEach((f, i) => tone(f, 0.15, "square", 0.12, null, i * 0.1)),
    hit:    () => { noise(0.25, 0.25); tone(150, 0.3, "sawtooth", 0.15, 50); },
    die:    () => { [400, 300, 200, 120].forEach((f, i) => tone(f, 0.15, "square", 0.12, null, i * 0.12)); },
    fall:   () => tone(700, 0.8, "sine", 0.15, 80)
  };

  function setMuted(m) {
    muted = m;
    try { localStorage.setItem(KEY, m ? "1" : "0"); } catch (e) {}
    if (btn) { btn.textContent = m ? "🔇" : "🔊"; btn.title = m ? "Sound off (M)" : "Sound on (M)"; btn.setAttribute("aria-pressed", m); }
    if (!m) ac();
  }

  let btn = null;
  function ui() {
    const css = document.createElement("style");
    css.textContent = `
      .sfx-btn { position: fixed; top: 10px; right: 10px; z-index: 9999; width: 40px; height: 40px;
        font-size: 20px; line-height: 1; background: rgba(0,0,0,.6); color: #fff; border: 1px solid rgba(255,255,255,.35);
        cursor: pointer; display: grid; place-items: center; }
      .sfx-btn:hover { background: rgba(0,0,0,.8); }
      .sfx-warn { position: fixed; top: 10px; left: 50%; transform: translateX(-50%); z-index: 9998;
        background: #111; color: #fff; border: 1px solid #9bd13b; padding: 9px 12px 9px 14px;
        font: 13px Verdana, Tahoma, Arial, sans-serif; display: flex; gap: 12px; align-items: center;
        max-width: calc(100vw - 120px); transition: opacity .4s; box-shadow: 0 4px 16px rgba(0,0,0,.5); }
      .sfx-warn button { font: inherit; font-weight: 700; padding: 4px 10px; background: #9bd13b; color: #000; border: 0; cursor: pointer; white-space: nowrap; }
      .sfx-warn button.x { background: none; color: #aaa; padding: 4px; }
    `;
    document.head.appendChild(css);
    btn = document.createElement("button");
    btn.className = "sfx-btn";
    btn.onclick = e => { setMuted(!muted); btn.blur(); e.stopPropagation(); };
    btn.addEventListener("pointerdown", e => e.stopPropagation());
    document.body.appendChild(btn);

    const warn = document.createElement("div");
    warn.className = "sfx-warn"; warn.setAttribute("role", "status");
    warn.innerHTML = `<span>🔊 Heads up: this game has sound.</span><button class="m"></button><button class="x" aria-label="Dismiss">✕</button>`;
    const mBtn = warn.querySelector(".m");
    const paint = () => mBtn.textContent = muted ? "Unmute" : "Mute";
    paint();
    mBtn.onclick = e => { setMuted(!muted); paint(); mBtn.blur(); e.stopPropagation(); };
    const hide = () => { warn.style.opacity = "0"; setTimeout(() => warn.remove(), 400); };
    warn.querySelector(".x").onclick = e => { hide(); e.stopPropagation(); };
    warn.addEventListener("pointerdown", e => e.stopPropagation());
    document.body.appendChild(warn);
    setTimeout(hide, 6000);
    setMuted(muted);
  }
  addEventListener("keydown", e => {
    if (e.key.toLowerCase() === "m" && !e.ctrlKey && !e.metaKey && !/^(INPUT|TEXTAREA)$/.test(e.target.tagName) && !e.target.isContentEditable && !window.SFX_NO_M_KEY) setMuted(!muted);
  });
  if (document.body) ui(); else addEventListener("DOMContentLoaded", ui);

  window.SFX = { play: n => SOUNDS[n] && SOUNDS[n](), tone, noise, get muted() { return muted; }, setMuted };
})();
