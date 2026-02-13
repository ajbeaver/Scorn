# SCORN — Phase Roadmap & World Structure

This document defines the development phases and clarifies world structure decisions.
It is intended to be followed sequentially.

---

## Core Architectural Decisions (Locked for Now)

### 1. What is the “world map” structure?

The world map is **program-first**, not player-first.

• It exists to support simulation and traversal  
• It is not a UI artifact  
• It must be deterministic from seed  

**Canonical structure:**

World  
→ Regions  
→ Areas  
→ Structures  
→ Rooms  

Each layer:
• Has an ID derived from the world seed
• Can be generated independently
• Can be partially realized (lazy-loaded)

This allows us to simulate large worlds without instantiating everything.

---

### 2. How are settlements created?

**Settlements are generated at world bootstrap, but only as seeds.**

At world start:
• Settlement *definitions* are created (location, faction, starting resources)
• Core simulation nodes are initialized (water, population, institutions)

At runtime:
• Full structural detail (buildings, rooms, NPCs) is generated **only when entered**
• Simulation continues whether or not the player is present

This gives:
✓ Determinism  
✓ Performance  
✓ Meaningful revisits  

---

### 3. Is the current settlement map structure acceptable?

**Yes, as a simulation interface — not as a gameplay interface.**

Current settlement dicts are:
✓ Correct for physics
✗ Not suitable for traversal or UI

**Rule going forward:**
• Simulation structures stay internal
• Gameplay-facing structures are adapters/views layered on top

We do NOT refactor settlement internals yet.

---

## Phase Map

---

## Phase 0 — World Exists Without Player ✓

**Purpose**
Prove the world can run, decay, stabilize, and fail autonomously.

**Scope**
• World seed
• Settlements (simulation only)
• Resources (water, population)
• Institutions, legitimacy, unrest
• Failure states

**Out of Scope**
✗ Player
✗ Traversal
✗ NPCs
✗ UI beyond reports

**Done When**
• Multiple seeds produce different outcomes
• Failures are explainable from logs
• Watching it run is boring

---

## Phase 1 — Read-Only Player Presence

**Purpose**
Insert the player as a physical entity without influence.

**Scope**
• Player body
• Hunger / thirst / health
• Inventory (minimal)
• Death

**Rules**
• Player cannot affect settlements
• Player can observe settlement state

**Done When**
• Survival loop is playable
• Different settlements feel different
• Player death is common and fair

---

## Phase 2 — Traversal & Space

**Purpose**
Make space costly and meaningful.

**Scope**
• Regions / Areas / Structures / Rooms
• Time-based movement
• Resource cost for travel
• Loot + hazards

**Rules**
• World simulation influences space
• Player does not influence simulation

**Done When**
• Getting lost is possible
• Routes emerge naturally
• Avoidance is a strategy

---

## Phase 3 — NPCs & Factions (Indirect)

**Purpose**
Introduce social danger without RPG mechanics.

**Scope**
• NPC archetypes
• Faction presence
• Trade / threat / avoidance
• Simple lethal combat

**Rules**
• No quests
• No dialogue trees
• No alignment meters

**Done When**
• Encounters are tense
• Reading situations matters
• Exposition is unnecessary

---

## Phase 4 — Long-Term Survival

**Purpose**
Sustain play without escalation.

**Scope**
• Tool degradation
• Repairs via scrap
• Carry limits
• Risk/reward exploration

**Done When**
• Player sets their own goals
• Returning to places matters
• The game feels quietly hostile

---

## Phase 5 — Threshold of Power

**Purpose**
Make influence tempting, not mandatory.

**Scope**
• Reputation
• Recognition
• Recruitment offers

**Rules**
• Player still cannot govern
• Influence is social, not mechanical

**Done When**
• Player hesitates to accept power

---

## Phase 6 — Governance Mode (Irreversible)

**Purpose**
Flip the game into stewardship.

**Scope**
• Player opts in
• Survival fades
• Time accelerates
• Settlement mechanics exposed

**Rules**
• One-way transition
• No return to wandering

**Done When**
• Game ends via stability, tyranny, or collapse

---

## Closing Principle

Lower layers must be:
• Stable
• Boring
• Invisible

Before higher layers are added.

