"""
World/seeds.py

Deterministic seed expansion for the Scorn world.
All procedural variation must originate here.
No randomness is allowed outside this file.
"""

import hashlib


# ----------------------------
# Core Hashing Utility
# ----------------------------

def _hash(value: str) -> int:
    """
    Convert an arbitrary string into a stable integer.
    """
    digest = hashlib.sha256(value.encode("utf-8")).hexdigest()
    return int(digest[:16], 16)


# ----------------------------
# Root Seed Expansion
# ----------------------------

def world_seed(root_seed: int) -> int:
    return _hash(f"world:{root_seed}")


def space_seed(world_seed: int, space_id: int) -> int:
    return _hash(f"space:{world_seed}:{space_id}")


def settlement_seed(space_seed: int, settlement_id: int) -> int:
    return _hash(f"settlement:{space_seed}:{settlement_id}")


def structure_seed(settlement_seed: int, structure_id: int) -> int:
    return _hash(f"structure:{settlement_seed}:{structure_id}")


def room_seed(structure_seed: int, room_id: int) -> int:
    return _hash(f"room:{structure_seed}:{room_id}")


# ----------------------------
# System Seeds
# ----------------------------

def population_seed(settlement_seed: int) -> int:
    return _hash(f"population:{settlement_seed}")


def resource_seed(settlement_seed: int, resource_type: str) -> int:
    return _hash(f"resource:{settlement_seed}:{resource_type}")


def institution_seed(settlement_seed: int, institution_type: str, index: int) -> int:
    return _hash(f"institution:{settlement_seed}:{institution_type}:{index}")


def pressure_seed(settlement_seed: int, pressure_type: str) -> int:
    return _hash(f"pressure:{settlement_seed}:{pressure_type}")


# ----------------------------
# Player Context (Future Use)
# ----------------------------

def player_spawn_seed(world_seed: int) -> int:
    return _hash(f"player_spawn:{world_seed}")


def encounter_seed(world_seed: int, tick: int) -> int:
    return _hash(f"encounter:{world_seed}:{tick}")