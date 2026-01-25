#!/usr/bin/env python3
"""
test_world.py

Single deterministic world-generation test.
Input:  one integer seed
Output: stable SHA-256 hash on success
"""

import sys
import json
import hashlib

# ----------------------------
# Argument handling
# ----------------------------

if len(sys.argv) != 2:
    raise SystemExit("usage: python3 test_world.py <world_seed:int>")

try:
    WORLD_SEED = int(sys.argv[1])
except ValueError:
    raise SystemExit("world_seed must be an integer")

# ----------------------------
# Import validation (fail fast)
# ----------------------------

from World import constants
from World import schema
from World.world import generate_world

# Explicit generator imports to surface missing __init__.py
from World.generate import area
from World.generate import settlement
from World.generate import structure

# ----------------------------
# Helpers
# ----------------------------

def canonicalize(obj) -> bytes:
    """
    Produce a canonical byte representation of the world.
    """
    return json.dumps(
        obj,
        sort_keys=True,
        separators=(",", ":"),
        ensure_ascii=True,
    ).encode("utf-8")


def hash_bytes(b: bytes) -> str:
    return hashlib.sha256(b).hexdigest()


# ----------------------------
# Structural assertions
# ----------------------------

def assert_world_shape(world: dict) -> None:
    # Top-level contract
    assert isinstance(world, dict)
    assert "seed" in world
    assert "areas" in world
    assert isinstance(world["areas"], list)

    # Area bounds
    area_count = len(world["areas"])
    assert constants.WORLD_MIN_AREAS <= area_count <= constants.WORLD_MAX_AREAS

    for a in world["areas"]:
        assert isinstance(a, dict)
        assert "settlements" in a
        assert isinstance(a["settlements"], list)

        settlement_count = len(a["settlements"])
        assert constants.AREA_MIN_SETTLEMENTS <= settlement_count <= constants.AREA_MAX_SETTLEMENTS

        for s in a["settlements"]:
            assert isinstance(s, dict)

            # Population
            pop = s.get("population")
            assert isinstance(pop, dict)
            assert "total" in pop
            assert constants.MIN_POPULATION <= pop["total"] <= constants.MAX_POPULATION

            # Institutions
            institutions = s.get("institutions", [])
            assert constants.INSTITUTION_MIN <= len(institutions) <= constants.INSTITUTION_MAX

            # Structures
            structures = s.get("structures", [])
            assert constants.STRUCTURE_MIN <= len(structures) <= constants.STRUCTURE_MAX


# ----------------------------
# Determinism test
# ----------------------------

world_a = generate_world(WORLD_SEED)
world_b = generate_world(WORLD_SEED)

# Schema validation must pass both times

# Structural sanity
assert_world_shape(world_a)
assert_world_shape(world_b)

# Canonical hashing
hash_a = hash_bytes(canonicalize(world_a))
hash_b = hash_bytes(canonicalize(world_b))

assert hash_a == hash_b, "☠ nondeterministic world generation detected"

# ----------------------------
# Success output
# ----------------------------

print(hash_a)