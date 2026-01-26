"""
World/generate/settlement.py

Deterministic settlement construction.
No simulation, no time, no player.
"""

import random

from World.generate import structure

from World import constants

def generate_settlement(settlement_seed: int, area_isolation: float, area_traversal_cost: float, area_danger: float) -> dict:
    """
    Generate a settlement dict from a given seed.
    """

    rng = random.Random(settlement_seed)

    settlement_id = settlement_seed

    age = rng.randint(
        constants.SETTLEMENT_MIN_AGE,
        constants.SETTLEMENT_MAX_AGE,
    )

    age_span = (constants.SETTLEMENT_MAX_AGE - constants.SETTLEMENT_MIN_AGE) or 1
    age_ratio = (age - constants.SETTLEMENT_MIN_AGE) / age_span

    pop_ceiling = int(
        constants.MIN_POPULATION
        + age_ratio * (constants.MAX_POPULATION - constants.MIN_POPULATION)
    )
    
    base_population = rng.randint(
        constants.MIN_POPULATION,
        max(constants.MIN_POPULATION, pop_ceiling),
    )

    pop_span = (constants.MAX_POPULATION - constants.MIN_POPULATION) or 1
    pop_ratio = (base_population - constants.MIN_POPULATION) / pop_span

    connection_friction = area_isolation * area_traversal_cost

    type_weights = {}

    for settlement_type_name in constants.SETTLEMENT_TYPES:
        if settlement_type_name == "hamlet":
            weight = (
                (1 - age_ratio)
                * (1 - pop_ratio)
                * (0.5 + connection_friction)
            )
        elif settlement_type_name == "village":
            weight = (
                (1 - abs(age_ratio - 0.5))
                * (1 - abs(pop_ratio - 0.5))
            )
        elif settlement_type_name == "town":
            weight = (
                age_ratio
                * pop_ratio
                * (1 - connection_friction)
            )
        elif settlement_type_name == "city":
            weight = (
                (age_ratio ** 2)
                * (pop_ratio ** 2)
                * (1 - connection_friction)
            )
        else:
            weight = 0.0

        type_weights[settlement_type_name] = max(weight, 0.0)

    total_weight = sum(type_weights.values()) or 1.0
    roll = rng.uniform(0, total_weight)

    cumulative = 0.0
    settlement_type = None
    for name, weight in type_weights.items():
        cumulative += weight
        if roll <= cumulative:
            settlement_type = name
            break

    settlement_type = settlement_type or constants.SETTLEMENT_TYPES[0]

    resource_capacities = {}
    for resource_name in constants.RESOURCE_TYPES:
        cap_min, cap_max = constants.RESOURCE_CAPACITY_BY_TYPE[settlement_type][resource_name]
        capacity = rng.randint(cap_min, cap_max)
        resource_capacities[resource_name] = capacity

    stability_factor = max(
        0.0,
        min(
            1.0,
            (age_ratio * 0.6) + ((1.0 - connection_friction) * 0.4)
        )
    )
    healthy_population = int(base_population * stability_factor)

    health_ratio = healthy_population / base_population if base_population > 0 else 0.0

    morale = max(
        0.0,
        min(
            1.0,
            (stability_factor * 0.5) + (health_ratio * 0.5)
        )
    )

    labor_multiplier = (
        constants.LABOR_BASE_RATE
        + (age_ratio * constants.LABOR_AGE_WEIGHT)
        - (connection_friction * constants.LABOR_FRICTION_WEIGHT)
    )

    labor_multiplier = max(0.0, min(1.0, labor_multiplier))
    labor_force = int(healthy_population * labor_multiplier)

    # ------------------------------------------------------------
    # Institutional labor overhead
    # ------------------------------------------------------------

    institutions = []

    production_potential = {}

    # (REMOVED original production_potential block here)

    consumption_demand = {}
    
    total_population = base_population

    for resource_name in constants.RESOURCE_TYPES:
        per_capita = constants.RESOURCE_DEMAND_PER_CAPITA[resource_name]
        consumption_demand[resource_name] = total_population * per_capita

    resource_state = {}

    for resource_name in constants.RESOURCE_TYPES:
        capacity = resource_capacities[resource_name]
        production = production_potential.get(resource_name, 0)
        consumption = consumption_demand[resource_name]
        net_flow = production - consumption

        if net_flow >= 0:
            current = min(capacity, capacity * constants.INITIAL_RESOURCE_FILL_RATIO)
        else:
            current = min(capacity, max(0, capacity * constants.INITIAL_RESOURCE_FILL_RATIO + net_flow))

        resource_state[resource_name] = {
            "capacity": capacity,
            "current": current,
            "production": production,
            "consumption": consumption,
        }
    
    food_supply = resource_state["food"]["current"]
    food_demand = consumption_demand["food"]
    unmet_food = max(food_demand - food_supply, 0)
    food_strain = max(unmet_food - constants.FOOD_STRAIN_RECOVERY, 0)
    vulnerable_population = base_population - healthy_population
    starving_population = min(
        vulnerable_population,
        int(food_strain * constants.FOOD_STARVATION_FACTOR)
    )
    
    injured_population = vulnerable_population - starving_population

    inst_scale = max(
        0.0,
        min(
            1.0,
            (age_ratio * 0.35) + (pop_ratio * 0.35) + (stability_factor * 0.30)
        )
    )

    inst_cap = int(round(constants.INSTITUTION_MAX * inst_scale))
    institution_count = rng.randint(
        constants.INSTITUTION_MIN,
        max(constants.INSTITUTION_MIN, inst_cap),
    )

    type_bias = {
        "hamlet": {"archive": 0.25, "enforcement": 0.05, "civic": 0.10, "religious": 0.60},
        "village": {"archive": 0.30, "enforcement": 0.10, "civic": 0.25, "religious": 0.35},
        "town":   {"archive": 0.25, "enforcement": 0.25, "civic": 0.35, "religious": 0.15},
        "city":   {"archive": 0.20, "enforcement": 0.30, "civic": 0.40, "religious": 0.10},
    }

    bias = type_bias.get(settlement_type, {t: 1.0 for t in constants.INSTITUTION_TYPES})

    def _weighted_choice(weight_map: dict) -> str:
        total = sum(weight_map.values()) or 1.0
        r = rng.uniform(0.0, total)
        c = 0.0
        for k, w in weight_map.items():
            c += max(w, 0.0)
            if r <= c:
                return k
        return next(iter(weight_map.keys()))

    institutions = []
    for _ in range(institution_count):
        inst_type = _weighted_choice({t: bias.get(t, 0.0) for t in constants.INSTITUTION_TYPES})

        base_condition = rng.uniform(constants.INSTITUTION_CONDITION_MIN, constants.INSTITUTION_CONDITION_MAX)
        condition = max(
            constants.INSTITUTION_CONDITION_MIN,
            min(constants.INSTITUTION_CONDITION_MAX, base_condition * (0.6 + 0.4 * stability_factor)),
        )

        base_power = constants.DEFAULT_INSTITUTION_POWER.get(inst_type, 1.0)
        power = base_power * (0.75 + 0.25 * pop_ratio) * (0.5 + 0.5 * condition)

        legitimacy = max(0.0, min(1.0, (0.3 + 0.7 * stability_factor) * condition))

        institutions.append({
            "type": inst_type,
            "condition": condition,
            "power": power,
            "legitimacy": legitimacy,
        })


    institutional_labor_draw = 0

    for inst in institutions:
        institutional_labor_draw += (
            inst["power"] * constants.INSTITUTION_LABOR_COST_FACTOR
        )

    institutional_labor_draw = min(
        labor_force * constants.INSTITUTION_LABOR_CAP_RATIO,
        int(institutional_labor_draw),
    )

    effective_labor_force = max(
        0,
        labor_force - institutional_labor_draw,
    )

    # ------------------------------------------------------------
    # Production potential (uses AVAILABLE labor only)
    # ------------------------------------------------------------

    production_potential = {}

    for resource_name in constants.RESOURCE_TYPES:
        labor_cap = int(
            effective_labor_force * constants.RESOURCE_LABOR_SHARE_CAP[resource_name]
        )

        infra_cap = (
            resource_capacities[resource_name]
            * constants.RESOURCE_INFRA_OUTPUT_RATE[resource_name]
        )

        efficiency = max(
            0.0,
            min(
                1.0,
                constants.BASE_EFFICIENCY_BY_TYPE[settlement_type]
                + (age_ratio * constants.EFFICIENCY_AGE_WEIGHT)
                - (connection_friction * constants.EFFICIENCY_FRICTION_WEIGHT)
            )
        )

        labor_output = (
            labor_cap
            * constants.RESOURCE_LABOR_OUTPUT_RATE[resource_name]
            * efficiency
        )

        production_potential[resource_name] = min(labor_output, infra_cap)

    structures = structure.generate_structures(
        structure_seed=settlement_seed,
        settlement_type=settlement_type,
        production_potential=production_potential,
        age=age,
        danger=area_danger,
    )


    # ============================================================
    # 8. PRESSURES (INITIAL STRAIN STATE)
    # ------------------------------------------------------------
    # Pressures are derived from unmet demand and instability,
    # not randomly assigned.
    # ============================================================

    pressures = {
        # scarcity: ...
        # unrest: ...
        # legitimacy: ...
    }

    # ============================================================
    # 10. FINAL SNAPSHOT ASSEMBLY
    # ------------------------------------------------------------
    # No logic here. No RNG. No math.
    # Just freezing the computed state.
    # ============================================================

    settlement = {
        "id": settlement_id,
        "age": age,
        "type": settlement_type,
        "connection_friction": connection_friction,
        "stability_factor": stability_factor,

        "population": {
            "total": base_population,
            "healthy": healthy_population,
            "injured": injured_population,
            "starving": starving_population,
            "morale": morale,
            "available_labor": effective_labor_force,
        },

        "resources": {
            resource_name: {
                "capacity": resource_capacities[resource_name],
                "production_capacity": production_potential.get(resource_name),
                "consumption_demand": consumption_demand.get(resource_name),
            }
            for resource_name in constants.RESOURCE_TYPES
        },
        "pressures": pressures,
        "institutions": institutions,
        "structures": structures,
    }

    return settlement