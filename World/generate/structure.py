"""
World/generate/structure.py

Deterministic structure + room generation.
Pure construction, no simulation.
"""

import random

from World import constants
from World import schema


def generate_structure(structure_seed: int) -> dict:
    """
    Create a structure with rooms from a seed.
    """

    rng = random.Random(structure_seed)

    structure_type = rng.choice(constants.STRUCTURE_TYPES)

    structure = {
        "id": structure_seed,
        "type": structure_type,
        "condition": rng.uniform(0.5, 1.0),
        "scale": rng.choice(constants.STRUCTURE_SCALES),
        "rooms": [],
    }

    # ----------------------------
    # Room Count
    # ----------------------------

    room_count = rng.randint(
        constants.ROOM_MIN,
        constants.ROOM_MAX,
    )

    for i in range(room_count):
        room_seed = structure_seed + i + 1
        room = generate_room(room_seed, structure_type)
        structure["rooms"].append(room)

    # ----------------------------
    # Validation
    # ----------------------------

    schema.validate_structure(structure)

    return structure


def generate_room(room_seed: int, structure_type: str) -> dict:
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
        "resource_bias": rng.uniform(0.0, 1.0),
        "danger_bias": rng.uniform(0.0, 1.0),
    }

    return room