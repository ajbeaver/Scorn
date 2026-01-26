"""
World/generate/area.py

Deterministic area generation.
Defines traversal cost, isolation, and contained settlements.
"""

import random

from World import constants
from World.generate import settlement


def generate_area(area_seed: int) -> dict:
    """
    Create an Area from a seed.
    """

    rng = random.Random(area_seed)

    area = {
        "id": area_seed,
        "seed": area_seed,
        "traversal_cost": rng.uniform(
            constants.AREA_TRAVEL_COST_MIN,
            constants.AREA_TRAVEL_COST_MAX,
        ),
        "danger_level": rng.uniform(
            constants.AREA_DANGER_MIN,
            constants.AREA_DANGER_MAX,
        ),
        "isolation": rng.uniform(
            constants.AREA_ISOLATION_MIN,
            constants.AREA_ISOLATION_MAX,
        ),
        "settlements": [],
    }

    # ----------------------------
    # Settlement Count
    # ----------------------------

    settlement_count = rng.randint(
        constants.AREA_MIN_SETTLEMENTS,
        constants.AREA_MAX_SETTLEMENTS,
    )

    for i in range(settlement_count):
        settlement_seed = area_seed * 1000 + i
        s = settlement.generate_settlement(settlement_seed, area["isolation"], area["traversal_cost"], area["danger_level"])
        area["settlements"].append(s)

    return area