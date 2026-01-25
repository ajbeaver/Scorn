"""
World/generate/settlement.py

Deterministic settlement construction.
No simulation, no time, no player.
"""

import random

from World import constants
from World import schema
from World import seeds


def generate_settlement(settlement_seed: int) -> dict:
    """
    Create a settlement dictionary from a seed.
    """

    rng = random.Random(settlement_seed)

    # ----------------------------
    # Core Identity
    # ----------------------------

    settlement = {
        "id": settlement_seed,
        "type": rng.choice(constants.SETTLEMENT_TYPES),
        "age": rng.randint(
            constants.SETTLEMENT_MIN_AGE,
            constants.SETTLEMENT_MAX_AGE,
        ),
        "population": {},
        "resources": {},
        "institutions": [],
        "pressures": {},
        "structures": [],
    }

    # ----------------------------
    # Population
    # ----------------------------

    base_population = rng.randint(
        constants.MIN_POPULATION,
        constants.MAX_POPULATION,
    )

    settlement["population"] = {
        "total": base_population,
        "healthy": int(base_population * rng.uniform(0.7, 0.95)),
        "injured": 0,
        "starving": 0,
        "morale": rng.uniform(0.4, 0.8),
    }

    # ----------------------------
    # Resources
    # ----------------------------

    for resource in constants.RESOURCE_TYPES:
        capacity = rng.randint(
            constants.RESOURCE_CAPACITY_MIN,
            constants.RESOURCE_CAPACITY_MAX,
        )

        settlement["resources"][resource] = {
            "capacity": capacity,
            "current": rng.uniform(0.3, 0.9) * capacity,
            "production": rng.uniform(0.5, 1.5),
            "consumption": rng.uniform(0.8, 1.2),
        }

    # ----------------------------
    # Institutions
    # ----------------------------

    institution_count = rng.randint(
        constants.INSTITUTION_MIN,
        constants.INSTITUTION_MAX,
    )

    for i in range(institution_count):
        institution_type = rng.choice(constants.INSTITUTION_TYPES)

        settlement["institutions"].append({
            "type": institution_type,
            "condition": rng.uniform(0.4, 1.0),
            "power": rng.uniform(0.5, 1.5),
            "legitimacy": rng.uniform(0.3, 0.9),
        })

    # ----------------------------
    # Pressures (Initial State)
    # ----------------------------

    for pressure in constants.PRESSURE_TYPES:
        settlement["pressures"][pressure] = rng.uniform(0.0, 0.3)

    # ----------------------------
    # Structures (Abstract)
    # ----------------------------

    structure_count = rng.randint(
        constants.STRUCTURE_MIN,
        constants.STRUCTURE_MAX,
    )

    for i in range(structure_count):
        settlement["structures"].append({
            "type": rng.choice(constants.STRUCTURE_TYPES),
            "condition": rng.uniform(0.5, 1.0),
            "rooms": rng.randint(
                constants.ROOM_MIN,
                constants.ROOM_MAX,
            ),
        })

    # ----------------------------
    # Validation (Schema Guard)
    # ----------------------------

    return settlement