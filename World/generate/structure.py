"""
World/generate/structure.py

Deterministic structure + room generation.
Pure construction, no simulation.
"""

import random

from World import constants


def generate_structure(structure_seed: int, structure_type: str, scale: float, danger: float) -> dict:
    """
    Create a structure with rooms from a seed.
    """

    rng = random.Random(structure_seed)

    structure = {
        "id": structure_seed,
        "type": structure_type,
        "condition": max(0.0, 1.0 - danger),
        "scale": scale,
        "rooms": [],
    }

    # ----------------------------
    # Room Count
    # ----------------------------

    room_count = max(1, int(scale * constants.STRUCTURE_ROOMS_PER_SCALE))

    for i in range(room_count):
        room_seed = structure_seed + i + 1
        room = generate_room(room_seed, structure_type, danger)
        structure["rooms"].append(room)

    # ----------------------------
    # Validation
    # ----------------------------

    return structure


def generate_room(room_seed: int, structure_type: str, danger: float) -> dict:
    """
    Create a single room.
    """

    rng = random.Random(room_seed)

    room_type = rng.choice(
        constants.ROOM_TYPES_BY_STRUCTURE[structure_type]
    )

    room = {
        "id": room_seed,
        "type": room_type,
        "size": rng.choice(constants.ROOM_SIZES),
        "resource_bias": 1.0,
        "danger_bias": danger,
    }

    return room