"""
World/validate.py

Phase 0 validation.
Accumulates all violations of constants-defined invariants
and raises a single exception if any are found.

This module enforces finality. It does not generate, mutate,
normalize, or guess.
"""

from World import constants


class WorldValidationError(Exception):
    """Raised when one or more validation errors are detected."""

    def __init__(self, errors):
        self.errors = errors
        message = "World validation failed with the following errors:\n"
        message += "\n".join(f"- {e}" for e in errors)
        super().__init__(message)


def validate_world(world: dict) -> None:
    """
    Validate a fully generated world against constants-defined rules.
    Accumulates all errors before raising.
    """
    errors = []

    # ----------------------------
    # World-level checks
    # ----------------------------
    if not isinstance(world, dict):
        errors.append("World is not a dict.")
        raise WorldValidationError(errors)

    if "seed" not in world:
        errors.append("World missing 'seed'.")

    if "areas" not in world or not isinstance(world["areas"], list):
        errors.append("World missing 'areas' list.")
    else:
        for area in world["areas"]:
            _validate_area(area, errors)

    if errors:
        raise WorldValidationError(errors)


def _validate_area(area: dict, errors: list) -> None:
    if not isinstance(area, dict):
        errors.append("Area is not a dict.")
        return

    for key in ("id", "seed", "danger_level", "isolation", "traversal_cost", "settlements"):
        if key not in area:
            errors.append(f"Area missing key '{key}'.")

    _check_range(
        area.get("danger_level"),
        constants.AREA_DANGER_MIN,
        constants.AREA_DANGER_MAX,
        "area.danger_level",
        errors,
    )

    _check_range(
        area.get("isolation"),
        constants.AREA_ISOLATION_MIN,
        constants.AREA_ISOLATION_MAX,
        "area.isolation",
        errors,
    )

    if isinstance(area.get("settlements"), list):
        for settlement in area["settlements"]:
            _validate_settlement(settlement, errors)


def _validate_settlement(settlement: dict, errors: list) -> None:
    if not isinstance(settlement, dict):
        errors.append("Settlement is not a dict.")
        return

    for key in ("id", "type", "age", "population", "resources", "pressures", "structures"):
        if key not in settlement:
            errors.append(f"Settlement missing key '{key}'.")

    if settlement.get("type") not in constants.SETTLEMENT_TYPES:
        errors.append(f"Invalid settlement type: {settlement.get('type')}")

    _check_range(
        settlement.get("age"),
        constants.SETTLEMENT_MIN_AGE,
        constants.SETTLEMENT_MAX_AGE,
        "settlement.age",
        errors,
    )

    _validate_population(settlement.get("population"), errors)
    _validate_pressures(settlement.get("pressures"), errors)
    _validate_resources(settlement.get("resources"), errors)

    if isinstance(settlement.get("structures"), list):
        for structure in settlement["structures"]:
            _validate_structure(structure, errors)


def _validate_population(pop: dict, errors: list) -> None:
    if not isinstance(pop, dict):
        errors.append("Population is not a dict.")
        return

    total = pop.get("total")
    _check_range(
        total,
        constants.MIN_POPULATION,
        constants.MAX_POPULATION,
        "population.total",
        errors,
    )


def _validate_pressures(pressures: dict, errors: list) -> None:
    if not isinstance(pressures, dict):
        errors.append("Pressures is not a dict.")
        return

    for key in ("legitimacy", "scarcity", "unrest"):
        _check_range(
            pressures.get(key),
            constants.PRESSURE_MIN,
            constants.PRESSURE_MAX,
            f"pressures.{key}",
            errors,
        )


def _validate_resources(resources: dict, errors: list) -> None:
    if not isinstance(resources, dict):
        errors.append("Resources is not a dict.")
        return

    for name, res in resources.items():
        if not isinstance(res, dict):
            errors.append(f"Resource '{name}' is not a dict.")
            continue

        capacity = res.get("capacity")
        current = res.get("current")

        if capacity is None or current is None:
            errors.append(f"Resource '{name}' missing capacity or current.")
            continue

        if current < 0:
            errors.append(f"Resource '{name}' has negative current value.")

        if current > capacity:
            errors.append(f"Resource '{name}' current exceeds capacity.")


def _validate_structure(structure: dict, errors: list) -> None:
    if not isinstance(structure, dict):
        errors.append("Structure is not a dict.")
        return

    if structure.get("type") not in constants.STRUCTURE_TYPES:
        errors.append(f"Invalid structure type: {structure.get('type')}")

    _check_range(
        structure.get("condition"),
        constants.STRUCTURE_CONDITION_MIN,
        constants.STRUCTURE_CONDITION_MAX,
        "structure.condition",
        errors,
    )


def _check_range(value, min_v, max_v, label, errors):
    if value is None:
        errors.append(f"{label} is missing.")
        return
    if not isinstance(value, (int, float)):
        errors.append(f"{label} is not numeric.")
        return
    if value < min_v or value > max_v:
        errors.append(f"{label} out of range [{min_v}, {max_v}]: {value}")
