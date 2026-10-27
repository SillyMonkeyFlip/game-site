/* Mods menu for Minecraft Classic.
   Press K (or the MODS button) to open it. V toggles fly.
   Works by changing the game engine's settings every frame (window.noa).
   Settings are remembered in localStorage "mc-mods". */
(function () {
  const KEY = "mc-mods";
  const DEFAULTS = { speed: 1, jump: 1, gravity: "normal", airJumps: 0, fly: false, bouncy: false, slippery: false,
    fov: 70, look: "normal", reach: 10 };
  let M = { ...DEFAULTS };
  try { Object.assign(M, JSON.parse(localStorage.getItem(KEY) || "{}")); } catch (e) {}
  M.fly = false;                                   // never start a world flying
  const save = () => { try { localStorage.setItem(KEY, JSON.stringify(M)); } catch (e) {} };

  const GRAV = { normal: 1, moon: 0.3, low: 0.6, heavy: 2 };
  const LOOKS = {                                 // CSS filters on the game canvas
    normal: "", sunset: "sepia(.45) saturate(1.6) hue-rotate(-18deg) brightness(.95)",
    night: "brightness(.42) saturate(.75) hue-rotate(12deg)", bw: "grayscale(1) contrast(1.1)",
    trippy: "saturate(2.2)", retro: "contrast(1.35) saturate(1.3) sepia(.15)"
  };
  const AIR = [0, 1, 2, 3, 5, 999];

  let base = null, keys = {}, open = false;

  function ready() { return window.noa && noa.playerEntity !== undefined && window.scene && noa.entities.getMovement(noa.playerEntity); }
  function grabBase() {
    const id = noa.playerEntity, mv = noa.entities.getMovement(id), b = noa.entities.getPhysicsBody(id);
    base = { maxSpeed: mv.maxSpeed, moveForce: mv.moveForce, jumpImpulse: mv.jumpImpulse, jumpForce: mv.jumpForce,
      airJumps: mv.airJumps, standingFriction: mv.standingFriction, gravity: b.gravityMultiplier, restitution: b.restitution,
      friction: b.friction, fov: scene.activeCamera.fov, reach: noa.blockTestDistance,     };
  }

  /* applied every frame so the game can't quietly undo it */
  function apply() {
    if (!ready()) return;
    if (!base) grabBase();
    const id = noa.playerEntity, mv = noa.entities.getMovement(id), b = noa.entities.getPhysicsBody(id);
    mv.maxSpeed = base.maxSpeed * M.speed * (M.fly ? 1.6 : 1);
    mv.moveForce = base.moveForce * M.speed * (M.fly ? 1.6 : 1);
    mv.jumpImpulse = base.jumpImpulse * Math.sqrt(M.jump);
    mv.jumpForce = base.jumpForce * Math.sqrt(M.jump);
    mv.airJumps = M.airJumps;
    mv.standingFriction = M.slippery ? 0.5 : base.standingFriction;
    b.friction = M.slippery ? 0.05 : base.friction;
    b.restitution = M.bouncy ? 0.85 : base.restitution;
    scene.activeCamera.fov = (keys.zoom && noa.inputs.state.active ? 20 : M.fov) * Math.PI / 180;
    noa.blockTestDistance = M.reach;
    const cv = document.getElementById("noa-canvas");
    if (cv) cv.style.filter = M.look === "trippy" ? `saturate(2.2) hue-rotate(${(performance.now() / 15) % 360}deg)` : (LOOKS[M.look] || "");
  }
  /* the game resets gravity in its own movement code every tick (4.2 on land, less in water),
     so scale it right before the physics step instead */
  function hookPhysics() {
    if (!window.noa || noa.physics._modsHooked) return;
    const orig = noa.physics.tick.bind(noa.physics);
    noa.physics.tick = function (dt) {
      try {
        const b = noa.entities.getPhysicsBody(noa.playerEntity);
        if (M.fly) {
          b.gravityMultiplier = 0;
          const up = noa.inputs.state.jump && noa.inputs.state.active, down = keys.Shift && noa.inputs.state.active;
          const target = up ? 9 : down ? -9 : 0;
          b.velocity[1] += (target - b.velocity[1]) * 0.3;
        } else b.gravityMultiplier *= GRAV[M.gravity];
      } catch (e) {}
      return orig(dt);
    };
    noa.physics._modsHooked = true;
  }
  (function loop() { try { hookPhysics(); apply(); } catch (e) {} requestAnimationFrame(loop); })();

  function goToTop() {
    if (!ready()) return;
    const p = noa.entities.getPosition(noa.playerEntity), x = Math.floor(p[0]), z = Math.floor(p[2]);
    const top = (noa.worldHeight || 64) + 2;
    for (let y = top; y > -5; y--) {
      if (noa.world.getBlockSolidity(x, y, z)) { noa.entities.setPosition(noa.playerEntity, [p[0], y + 1.05, p[2]]); return; }
    }
  }

  /* ---------- UI ---------- */
  const css = `
  #mods-btn { position: fixed; top: 8px; right: 8px; z-index: 100000; font: 16px Minecraft, monospace; color: #fff; text-shadow: 2px 2px #3f3f3f;
    background: #6f6f6f; border: 2px solid #000; box-shadow: inset 2px 2px #aaa, inset -2px -2px #555; padding: 6px 12px; cursor: pointer; }
  #mods-btn:hover { background: #7e86c4; }
  #mods { position: fixed; inset: 0; z-index: 100002; display: none; align-items: center; justify-content: center; background: rgba(0,0,0,.7); font: 16px Minecraft, monospace; color: #fff; text-shadow: 2px 2px #3f3f3f; }
  #mods.open { display: flex; }
  #mods .box { background: rgba(20,20,20,.95); border: 2px solid #555; padding: 18px 20px; width: min(560px, calc(100vw - 24px)); max-height: calc(100vh - 24px); overflow: auto; }
  #mods h2 { font-size: 24px; text-align: center; margin: 0 0 4px; font-weight: normal; }
  #mods .sub { text-align: center; color: #aaa; font-size: 13px; margin-bottom: 14px; }
  #mods .grid { display: grid; grid-template-columns: 1fr 1fr; gap: 8px; }
  #mods .full { grid-column: 1 / -1; }
  #mods button.mb, #mods .sl { font: inherit; color: #fff; text-shadow: inherit; background: #6f6f6f; border: 2px solid #000;
    box-shadow: inset 2px 2px #aaa, inset -2px -2px #555; padding: 8px 6px; cursor: pointer; width: 100%; text-align: center; }
  #mods button.mb:hover { background: #7e86c4; }
  #mods button.mb.on { color: #ffff55; }
  #mods .sl { position: relative; cursor: default; padding: 0; height: 38px; background: #333; box-shadow: none; }
  #mods .sl input { position: absolute; inset: 0; width: 100%; height: 100%; opacity: 0; cursor: pointer; margin: 0; }
  #mods .sl .fill { position: absolute; top: 0; bottom: 0; width: 14px; background: #8b8b8b; border: 2px solid #000; box-shadow: inset 2px 2px #c6c6c6, inset -2px -2px #555; pointer-events: none; }
  #mods .sl span { position: relative; line-height: 34px; pointer-events: none; }
  #mods .tip { color: #aaa; font-size: 13px; text-align: center; margin-top: 12px; line-height: 1.5; }`;
  const st = document.createElement("style"); st.textContent = css; document.head.appendChild(st);

  const btn = document.createElement("button"); btn.id = "mods-btn"; btn.textContent = "Mods (K)";
  const wrap = document.createElement("div"); wrap.id = "mods";
  wrap.innerHTML = `<div class="box"><h2>Mods</h2><div class="sub">Changes only affect you</div><div class="grid" id="mods-grid"></div>
    <div class="tip">K opens this menu · V turns fly on and off · hold C to zoom<br>While flying: Space goes up, Shift goes down · F is the game's own fog toggle</div></div>`;
  document.body.appendChild(btn); document.body.appendChild(wrap);
  const grid = wrap.querySelector("#mods-grid");

  const pretty = { normal: "Normal", moon: "Moon", low: "Low", heavy: "Heavy", sunset: "Warm", night: "Night", bw: "Black & white", retro: "Retro", trippy: "Trippy" };
  const rows = [
    { t: "toggle", k: "fly", label: "Fly" },
    { t: "slider", k: "speed", label: "Speed", min: 1, max: 5, step: 0.5, fmt: v => v + "x" },
    { t: "slider", k: "jump", label: "Jump", min: 1, max: 5, step: 0.5, fmt: v => v + "x" },
    { t: "cycle", k: "gravity", label: "Gravity", opts: ["normal", "moon", "low", "heavy"] },
    { t: "cycle", k: "airJumps", label: "Air jumps", opts: AIR, fmt: v => v === 999 ? "Infinite" : v },
    { t: "toggle", k: "bouncy", label: "Bouncy" },
    { t: "toggle", k: "slippery", label: "Ice physics" },
    { t: "cycle", k: "look", label: "Look", opts: ["normal", "sunset", "night", "bw", "retro", "trippy"] },
    { t: "slider", k: "fov", label: "FOV", min: 30, max: 120, step: 5, fmt: v => v === 70 ? "Normal" : v },
    { t: "slider", k: "reach", label: "Reach", min: 4, max: 40, step: 1, fmt: v => v + " blocks" },
    { t: "action", label: "Go to surface", run: goToTop },
    { t: "action", label: "Reset all", run: () => { M = { ...DEFAULTS }; save(); draw(); } },
    { t: "action", label: "Done", run: () => toggle(false), full: true }
  ];
  function draw() {
    grid.innerHTML = "";
    rows.forEach(r => {
      let el;
      if (r.t === "slider") {
        el = document.createElement("div"); el.className = "sl";
        el.innerHTML = `<div class="fill"></div><span></span><input type="range" min="${r.min}" max="${r.max}" step="${r.step}" value="${M[r.k]}">`;
        const inp = el.querySelector("input"), fill = el.querySelector(".fill"), sp = el.querySelector("span");
        const paint = () => { const f = (M[r.k] - r.min) / (r.max - r.min); fill.style.left = `calc(${f * 100}% - ${f * 14}px)`; sp.textContent = r.label + ": " + r.fmt(M[r.k]); };
        inp.oninput = () => { M[r.k] = +inp.value; save(); paint(); };
        paint();
      } else {
        el = document.createElement("button"); el.className = "mb";
        if (r.t === "toggle") { el.textContent = r.label + ": " + (M[r.k] ? "ON" : "OFF"); el.classList.toggle("on", !!M[r.k]); el.onclick = () => { M[r.k] = !M[r.k]; save(); draw(); }; }
        else if (r.t === "cycle") {
          const f = r.fmt || (v => pretty[v] || v);
          el.textContent = r.label + ": " + f(M[r.k]); el.classList.toggle("on", M[r.k] !== DEFAULTS[r.k]);
          el.onclick = () => { const i = r.opts.indexOf(M[r.k]); M[r.k] = r.opts[(i + 1) % r.opts.length]; save(); draw(); };
        } else { el.textContent = r.label; el.onclick = r.run; }
      }
      if (r.full) el.classList.add("full");
      grid.appendChild(el);
    });
  }
  function toggle(on) {
    open = on === undefined ? !open : on;
    wrap.classList.toggle("open", open);
    if (open) {
      draw();
      document.exitPointerLock && document.exitPointerLock();
      if (window.noa) noa.inputs.state.active = false;
    } else {
      // leaving pointer lock opens the game's own pause menu; if it's showing, let its "Back to game" resume play
      const gm = document.getElementById("menu");
      if (gm && getComputedStyle(gm).display !== "none") return;
      if (window.noa) noa.inputs.state.active = true;
      const c = document.getElementById("noa-container");
      setTimeout(() => { c && c.requestPointerLock && c.requestPointerLock(); }, 200);
    }
  }
  btn.onclick = e => { e.stopPropagation(); toggle(true); };
  btn.onmousedown = e => e.stopPropagation();
  wrap.addEventListener("mousedown", e => { e.stopPropagation(); if (e.target === wrap) toggle(false); });

  // other game menus (chat, block picker, pause) turn input off; only react to our keys while playing or in our menu
  addEventListener("keydown", e => {
    if (e.key === "Shift") keys.Shift = true;
    if (e.key.toLowerCase() === "c") keys.zoom = true;
    if (e.repeat) return;
    const playing = window.noa && noa.inputs.state.active;
    const k = e.key.toLowerCase();
    if (k === "k" && (playing || open)) { e.preventDefault(); toggle(); }
    else if (k === "escape" && open) { e.preventDefault(); e.stopPropagation(); toggle(false); }
    else if (k === "v" && playing) { M.fly = !M.fly; save(); if (open) draw(); flash("Fly " + (M.fly ? "ON" : "OFF")); }
  }, true);
  addEventListener("keyup", e => { if (e.key === "Shift") keys.Shift = false; if (e.key.toLowerCase() === "c") keys.zoom = false; });
  addEventListener("blur", () => { keys = {}; });

  let flashEl;
  function flash(t) {
    if (!flashEl) { flashEl = document.createElement("div"); flashEl.style.cssText = "position:fixed;top:30%;left:50%;transform:translateX(-50%);z-index:100001;font:20px Minecraft,monospace;color:#ffff55;text-shadow:2px 2px #3f3f3f;pointer-events:none;transition:opacity .4s"; document.body.appendChild(flashEl); }
    flashEl.textContent = t; flashEl.style.opacity = 1; clearTimeout(flash.t); flash.t = setTimeout(() => flashEl.style.opacity = 0, 1200);
  }
})();
