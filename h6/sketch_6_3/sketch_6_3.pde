
body {
    margin: 0;
    background: #111;
    overflow: hidden;
    font-family: Arial, sans-serif;
}

#game {
    position: relative;
    width: 100vw;
    height: 100vh;
}

#lanes {
    display: flex;
    justify-content: center;
    gap: 40px;
    margin-top: 40px;
}

.lane {
    width: 88px;
    height: 88px;
    background: #444;
    color: white;
    border-radius: 10px;
    font-size: 36px;
    display: flex;
    justify-content: center;
    align-items: center;
    touch-action: manipulation;
}


#hit-zone {
    position: absolute;
    top: 80%;            
    left: 0;
    width: 100%;
    height: 12%;    
    background: rgba(15, 255, 238, 0.18);
    border-top: 2px solid rgba(15,255,238,0.4);
    border-bottom: 2px solid rgba(15,255,238,0.06);
    pointer-events: none;
}

/* Miss flash on the hit zone */
#hit-zone.hit-miss {
    animation: missFlash 260ms ease-out;
}

@keyframes missFlash {
    0% { background: rgba(255,40,40,0.45); border-top-color: rgba(255,40,40,0.6); }
    60% { background: rgba(255,40,40,0.25); border-top-color: rgba(255,40,40,0.45); }
    100% { background: rgba(15,255,238,0.18); border-top-color: rgba(15,255,238,0.4); }
}

/* ensure notes pass visually underneath the hit marker */
#hit-zone { z-index: 500; }
.note-circle { z-index: 1; }

.container {
    background: white;
    padding: 30px;
    border-radius: 12px;
    box-shadow: 0 4px 12px rgba(0,0,0,0.1);
    width: 320px;
    text-align: center;
    position: absolute;
    top: 10px;
    left: 15%;
    transform: translateX(-50%);
}

textarea {
    width: 100%;
    height: 120px;
    font-size: 16px;
    padding: 8px;
    margin-bottom: 10px;
    border-radius: 8px;
}

button {
    width: 100%;
    padding: 10px;
    font-size: 16px;
    border-radius: 8px;
    border: none;
    background: #36383a;
    color: #0fbfff;
    cursor: pointer;
}

button:hover {
    background: #357ABD;
}

.message {
    margin-top: 10px;
    font-size: 16px;
    font-weight: bold;
    color: #000;
}

#scoreboard {
    position: fixed;
    right: 18px;
    top: 12px;
    background: rgba(0,0,0,0.55);
    color: #fff;
    padding: 8px 12px;
    border-radius: 8px;
    text-align: right;
    z-index: 2000;
    font-weight: 600;
}

#scoreboard #score { font-size: 16px; }
#scoreboard #highscore { font-size: 12px; opacity: 0.85; }

.note-circle {
    position: absolute;
    width: 64px;
    height: 64px;
    border-radius: 50%;
    display: flex;
    justify-content: center;
    align-items: center;
}

.note-arrow {
    font-size: 28px;
    color: #000;
}


.lane.hit-success {
    animation: hitFlash 220ms ease-out;
    box-shadow: 0 8px 20px rgba(255,255,255,0.06) inset;
}

@keyframes hitFlash {
    0% { background: #6ef0b8; transform: scale(1); }
    50% { background: #9ef9d0; transform: scale(1.08); }
    100% { background: #444; transform: scale(1); }
}

// Limit input to digits 1–4, spaces, and newlines
function limitInput(input) {
    input.value = input.value.replace(/[^1-4 \n]/g, "");
}

// Map numbers to lane keys
const arrowMap = {
    "1": 'd',  // Left
    "2": 'f',  // Up
    "3": 'j',  // Down
    "4": 'k'   // Right
};

// Optional colors
const circleColors = {
    "1": "#00ffd5ff",
    "2": "#44FF44",
    "3": "#0000ffff",
    "4": "#0f6626ff"
};

const activeArrows = [];
// Score tracking
let score = 0;
let highScore = parseInt(localStorage.getItem('rhythm_highscore')) || 0;
let spawningInProgress = false;

function updateScoreDisplay() {
    const s = document.getElementById('score');
    const h = document.getElementById('highscore');
    if (s) s.textContent = 'Score: ' + score;
    if (h) h.textContent = 'High: ' + highScore;
}

function changeScore(delta) {
    score = Math.max(0, score + delta);
    if (score > highScore) {
        highScore = score;
        try { localStorage.setItem('rhythm_highscore', String(highScore)); } catch (e) { /* ignore */ }
    }
    updateScoreDisplay();
}

// Start spawning arrows from multi-line input
function startSpawning() {
    const raw = document.getElementById("numberInput").value.trim();
    const messageBox = document.getElementById("message");
    const inputPanel = document.querySelector('.container');

    if (!raw) {
        messageBox.style.color = "red";
        messageBox.textContent = "✖ Please enter something";
        return;
    }
    // hide the input panel while spawning
    if (inputPanel) inputPanel.style.display = 'none';
    // mark spawning in progress (we will reset score once all notes are cleared)
    spawningInProgress = true;

    messageBox.style.color = "green";
    messageBox.textContent = "✔ Spawning arrows!";

    const lines = raw.split("\n");
    let index = 0;

    const interval = setInterval(() => {
        if (index >= lines.length) {
            clearInterval(interval);
            messageBox.textContent = "✔ All lines spawned!";
            // spawning finished (no more notes will be created)
            spawningInProgress = false;
            // show the input panel again when spawning finished
            if (inputPanel) inputPanel.style.display = '';
            return;
        }

        const line = lines[index].trim();
        if (line.length > 0) {
            const combos = line.split(/\s+/);
            combos.forEach(combo => spawnCombo(combo));
        }

        index++;
    }, 500);
}

// Spawn each number in a combo
function spawnCombo(combo) {
    combo.split("").forEach(digit => spawnArrow(digit));
}

// Spawn a single arrow
function spawnArrow(num) {
    const key = arrowMap[num];
    if (!key) return;

    // find lane by data-key case-insensitively
    const lane = getLaneByKey(key);
    const game = document.getElementById("game");

    const circle = document.createElement("div");
    circle.classList.add("note-circle");
    circle.style.backgroundColor = circleColors[num] || "#fff";

    const arrow = document.createElement("div");
    arrow.classList.add("note-arrow");
    arrow.textContent = lane.textContent;
    circle.appendChild(arrow);

    game.appendChild(circle);

    const laneRect = lane.getBoundingClientRect();
    const gameRect = game.getBoundingClientRect();
    const hitZoneRect = document.getElementById("hit-zone").getBoundingClientRect();

    const startX = laneRect.left + laneRect.width / 2 - gameRect.left;
    const startY = -50;
    // let the note travel all the way past the hit zone to below the game area
    const endY = gameRect.height + 60; // 60px past the bottom of the game

    circle.style.left = `${startX}px`;
    circle.style.top = `${startY}px`;
    circle.style.transform = "translateX(-50%)";

    // Animate falling
    const durationMs = 2000;
    const animation = circle.animate([
        { transform: `translateX(-50%) translateY(${startY}px)` },
        { transform: `translateX(-50%) translateY(${endY}px)` }
    ], {
        duration: durationMs,
        easing: "linear",
        fill: "forwards"
    });

    // Store active note
    activeArrows.push({
        element: circle,
        key: key
    });

    // Remove arrow after falling
    setTimeout(() => {
        const idx = activeArrows.findIndex(a => a.element === circle);
        if (idx !== -1) {
            // note was not hit — it's a miss
            console.log('Miss detected for note:', circle, 'index:', idx);
            triggerMissFlash();
            // penalize for miss
            changeScore(-1);
            activeArrows.splice(idx, 1);
        } else {
            // no active index — note was probably hit already
            console.log('Note already cleared (hit) before timeout:', circle);
        }
        // remove the element from DOM after it passes below the game
        if (circle && circle.parentNode) circle.parentNode.removeChild(circle);
        // if spawning has finished and there are no notes left, reset score
        if (!spawningInProgress && activeArrows.length === 0) {
            score = 0;
            updateScoreDisplay();
        }
    }, durationMs + 50);
}

// Key press listener
document.addEventListener("keydown", e => {
    const pressedKey = (e.key || '').toLowerCase();

    // iterate backwards so removing items from activeArrows doesn't skip entries
    for (let i = activeArrows.length - 1; i >= 0; i--) {
        const arrowObj = activeArrows[i];
        const rect = arrowObj.element.getBoundingClientRect();
        const hitZone = document.getElementById("hit-zone").getBoundingClientRect();

        if (pressedKey === (arrowObj.key || '').toLowerCase() &&
            rect.bottom >= hitZone.top &&
            rect.top <= hitZone.bottom) {

            // Hit detected
            // flash the corresponding lane
            const lane = getLaneByKey(arrowObj.key);
            if (lane) triggerLaneFlash(lane);

            // award points for hit
            changeScore(1);

            arrowObj.element.remove();
            activeArrows.splice(i, 1);
            console.log("Hit!", pressedKey);
            // only handle one note per key press
            // after removing a note, if there are no notes left and spawning finished, reset score
            if (!spawningInProgress && activeArrows.length === 0) {
                score = 0;
                updateScoreDisplay();
            }
            break;
        }
    }

    // Debugging: if user reports lane 3 (j) isn't working, log details when j pressed
    if (['d','f','j','k'].includes(pressedKey)) {
        const hz = document.getElementById('hit-zone').getBoundingClientRect();
        const info = activeArrows.map(a => {
            const r = a.element.getBoundingClientRect();
            return { key: a.key, top: r.top, bottom: r.bottom };
        });
        console.log('Keydown debug:', pressedKey, 'hitZone:', {top: hz.top, bottom: hz.bottom}, 'active:', info);
    }
});

// Flash animation helper for a lane element
function triggerLaneFlash(laneEl) {
    if (!laneEl) return;
    laneEl.classList.remove('hit-success');
    // force reflow so re-adding the class restarts the animation
    void laneEl.offsetWidth;
    laneEl.classList.add('hit-success');

    function onEnd(e) {
        if (e.animationName === 'hitFlash') {
            laneEl.classList.remove('hit-success');
            laneEl.removeEventListener('animationend', onEnd);
        }
    }

    laneEl.addEventListener('animationend', onEnd);
}

// Find a .lane element by its data-key attribute (case-insensitive)
function getLaneByKey(key) {
    if (!key) return null;
    const lookup = String(key).toLowerCase();
    const lanes = document.querySelectorAll('.lane');
    for (const lane of lanes) {
        const dk = (lane.getAttribute('data-key') || '').toLowerCase();
        if (dk === lookup) return lane;
    }
    return null;
}

// Trigger a brief red flash on the hit-zone to indicate a miss
function triggerMissFlash() {
    const hz = document.getElementById('hit-zone');
    if (!hz) return;
    hz.classList.remove('hit-miss');
    void hz.offsetWidth;
    hz.classList.add('hit-miss');

    function onEnd(e) {
        if (e.animationName === 'missFlash') {
            hz.classList.remove('hit-miss');
            hz.removeEventListener('animationend', onEnd);
        }
    }

    hz.addEventListener('animationend', onEnd);
}




later html:
<div class="container">
        <h2>Enter Combinations (Multiple Lines)</h2>
        <textarea id="numberInput" 
                  placeholder="Example:\n1\n12 23\n1234\n234 14"
                  oninput="limitInput(this)">
        </textarea>
        <button onclick="startSpawning()">Start</button>
        <div id="message" class="message"></div>
    </div>
	
	
later css:
@keyframes hitFlash {
    0% { background: #6ef0b8; transform: scale(1); }
    50% { background: #9ef9d0; transform: scale(1.08); }
    100% { background: #444; transform: scale(1); }
}

.lane.hit-success {
    animation: hitFlash 220ms ease-out;
    box-shadow: 0 8px 20px rgba(255,255,255,0.06) inset;
}

.note-circle {
    position: absolute;
    width: 64px;
    height: 64px;
    border-radius: 50%;
    display: flex;
    justify-content: center;
    align-items: center;
}

.note-arrow {
    font-size: 28px;
    color: #000;
}

textarea {
    width: 100%;
    height: 120px;
    font-size: 16px;
    padding: 8px;
    margin-bottom: 10px;
    border-radius: 8px;
}

button {
    width: 100%;
    padding: 10px;
    font-size: 16px;
    border-radius: 8px;
    border: none;
    background: #36383a;
    color: #0fbfff;
    cursor: pointer;
}

button:hover {
    background: #357ABD;
}

.message {
    margin-top: 10px;
    font-size: 16px;
    font-weight: bold;
    color: #000;
}

.container {
    background: white;
    padding: 30px;
    border-radius: 12px;
    box-shadow: 0 4px 12px rgba(0,0,0,0.1);
    width: 320px;
    text-align: center;
    position: absolute;
    top: 10px;
    left: 15%;
    transform: translateX(-50%);
}

/* ensure notes pass visually underneath the hit marker */
#hit-zone { z-index: 500; }
.note-circle { z-index: 1; }

@keyframes missFlash {
    0% { background: rgba(255,40,40,0.45); border-top-color: rgba(255,40,40,0.6); }
    60% { background: rgba(255,40,40,0.25); border-top-color: rgba(255,40,40,0.45); }
    100% { background: rgba(15,255,238,0.18); border-top-color: rgba(15,255,238,0.4); }
}

/* Miss flash on the hit zone */
#hit-zone.hit-miss {
    animation: missFlash 260ms ease-out;
}

