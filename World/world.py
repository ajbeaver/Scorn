"""
World/world.py

World composer.
Builds a deterministic world snapshot from a single seed.
"""

import random

from World import constants
from World.generate import area
from World.validate import validate_world


def generate_world(world_seed: int) -> dict:
    """
    Create a deterministic world from a seed.
    """

    rng = random.Random(world_seed)

    world = {
        "seed": world_seed,
        "areas": [],
    }

    # ----------------------------
    # Area Count
    # ----------------------------

    area_count = rng.randint(
        constants.WORLD_MIN_AREAS,
        constants.WORLD_MAX_AREAS,
    )

    for i in range(area_count):
        area_seed = world_seed * 10_000 + i
        a = area.generate_area(area_seed)
        world["areas"].append(a)

    # ----------------------------
    # Validation
    # ----------------------------

    validate_world(world)
    return world