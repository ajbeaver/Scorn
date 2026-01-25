# Scorn — Phase 0 Finalization (Framework-Centric)

This document replaces the previous Phase 0 checklist.

**Key correction:**  
Phase 0 guarantees must live in the *framework*, not in consumer scripts.  
Scripts like `test_world.py` and `dump_world.py` are disposable adapters. They must never encode world assumptions.

This document defines what must be fixed **inside `World/`** to properly close Phase 0.

---

## Phase 0 Contract (Re-stated)

Phase 0 is complete when:

• `generate_world(seed)` is deterministic  
• Any script can call `generate_world(seed)` and receive a valid world  
• All invariants are enforced by the framework itself  
• Consumer scripts require zero domain knowledge  

If a consumer script needs to be “updated” to handle shape changes, Phase 0 is broken.

---

## Core Rule: Authority Boundaries

Lock this permanently:

• `World/` modules define truth  
• Validators live in `World/`  
• Generators live in `World/generate/`  
• Scripts only pass a seed and receive output  

Scripts must never:
✗ enforce invariants  
✗ reshape data  
✗ know schema details  

---

## 1. Introduce a Canonical Validator Module

### Problem
Invariants are currently implicit or enforced in ad-hoc scripts.

### Required Fix
Create a **single executable validator** inside `World/`.

Recommended:
```
World/validate.py
```

### Required Functions
```
validate_world(world: dict) -> None
validate_area(area: dict) -> None
validate_settlement(settlement: dict) -> None
```

### Rules
• Validators raise exceptions on failure  
• Validators NEVER mutate data  
• Validators are deterministic  
• Validators are callable from any script  

### Wiring
`generate_world(seed)` must call `validate_world(world)` before returning.

---

## 2. Move All Invariants Into Validators

### Population Invariants
```
population is a dict
healthy + injured + starving == total
total >= 0
```

### Resource Invariants
```
0 <= current <= capacity
consumption >= 0
production >= 0
```

### Pressure Invariants
```
0.0 <= value <= 1.0
```

Applies to:
• unrest
• scarcity
• legitimacy
• morale

### Structure Invariants
```
ROOM_MIN <= rooms <= ROOM_MAX
type in STRUCTURE_TYPES
```

### Settlement Invariants
```
type in SETTLEMENT_TYPES
len(institutions) within bounds
```

No invariant belongs in a script.

---

## 3. Determinism Rules (Framework-Level)

### Required
• Every generator instantiates its own `random.Random(seed)`
• No generator uses module-level `random`
• Seed derivation must be stable and integer-only

### Forbidden
✗ global RNG  
✗ time-based entropy  
✗ implicit state  

If determinism breaks, the framework is wrong — not the script.

---

## 4. Canonical World Fingerprint (Framework-Owned)

### Problem
Hashing logic currently lives in a test script.

### Required Fix
Add to `World/`:

```
canonicalize_world(world) -> bytes
fingerprint_world(world) -> str
```

Behavior:
• JSON serialization
• sorted keys
• stable encoding
• SHA-256 output

Any script may call this.
No script should implement its own hashing.

---

## 5. Schema vs Validation (Clarified)

### Rule
Schema is descriptive. Validation is executable.

### Required Structure
• `schema.py` — declarative only (shapes, docs, intent)
• `validate.py` — executable enforcement

Generators must never call schema.
Generators may be validated only by validators.

---

## 6. Consumer Script Contract (Lock This)

Scripts such as:
• `test_world.py`
• `dump_world.py`
• future tools

May only:
```
world = generate_world(seed)
(optional) validate_world(world)
(optional) fingerprint_world(world)
print / inspect / exit
```

Scripts must never:
✗ assume field shapes  
✗ walk nested structures for correctness  
✗ “fix” bad data  

---

## Phase 0 Exit Conditions (Final)

Phase 0 is complete when:

✓ `generate_world(seed)` always returns a valid world  
✓ All invariants are enforced in `World/validate.py`  
✓ Determinism holds across repeated calls  
✓ Consumer scripts remain trivial and dumb  
✓ World generation survives refactors without script edits  

At that point, Phase 1 may begin.

---

End of Phase 0.
