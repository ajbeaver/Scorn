"""
World/constants.py

Global invariants and bounds for the Scorn world model.
Nothing in this file mutates state.
Nothing in this file depends on runtime.
If a value appears here, it is considered canon.
"""

# ----------------------------
# World Scale
# ----------------------------

WORLD_MIN_AREAS = 1
WORLD_MAX_AREAS = 16

AREA_MIN_SETTLEMENTS = 0
AREA_MAX_SETTLEMENTS = 4

# Area-level environmental multipliers.
# These are not direct costs or effects.
# They represent latent strain potential applied downstream
# (settlement generation, history biasing, simulation).
# All values are normalized multipliers in the range [0.0, 1.0].

# Traversal cost represents terrain friction and movement difficulty.
# Used to scale travel, trade, and interaction costs later.
AREA_TRAVEL_COST_MIN = 0.0
AREA_TRAVEL_COST_MAX = 1.0

# Danger represents ambient environmental threat.
# Higher values increase likelihood of disruption, decay, or stress.
# Does not encode specific events or narratives.
AREA_DANGER_MIN = 0.0
AREA_DANGER_MAX = 1.0

# Isolation represents distance and separation between settlements.
# Higher values imply reduced exchange, weaker diffusion, and less redundancy.
AREA_ISOLATION_MIN = 0.0
AREA_ISOLATION_MAX = 1.0

# ----------------------------
# Future use or erase

#MAX_SPACES_PER_WORLD = 128
#MIN_SPACES_PER_WORLD = 8

#MAX_SETTLEMENTS_PER_SPACE = 2
#MIN_SETTLEMENTS_PER_SPACE = 0


# ----------------------------
# Population
# ----------------------------


SETTLEMENT_MIN_AGE = 0
SETTLEMENT_MAX_AGE = 5000

SETTLEMENT_TYPES = [
    "outpost",
    "hamlet",
    "village",
    "town"
]

MIN_POPULATION = 0
MAX_POPULATION = 7000

# ============================================================
# LABOR MODEL CONSTANTS
# ------------------------------------------------------------
# These control how much of the healthy population can
# meaningfully contribute to labor at world initialization.
# They are multipliers, not absolutes.
# ============================================================

# Minimum fraction of healthy population able to work
# Represents subsistence-level labor capacity
LABOR_BASE_RATE = 0.4

# How strongly settlement age increases labor effectiveness
# Older settlements have infrastructure, routines, knowledge
LABOR_AGE_WEIGHT = 0.4

# How strongly isolation + traversal reduce labor effectiveness
# High friction reduces trade, specialization, coordination
LABOR_FRICTION_WEIGHT = 0.5

# ============================================================
# PRODUCTION & EFFICIENCY MODEL
# ============================================================

# Baseline production efficiency by settlement type
BASE_EFFICIENCY_BY_TYPE = {
    "outpost": 0.3,
    "hamlet": 0.5,
    "village": 0.7,
    "town": 0.9,
}

# How settlement age improves efficiency
EFFICIENCY_AGE_WEIGHT = 0.2

# How connection friction reduces efficiency
EFFICIENCY_FRICTION_WEIGHT = 0.4


#DEFAULT_POPULATION = 120

#POPULATION_GROWTH_RATE = 0.0005        # per tick (used later)
#POPULATION_DECLINE_RATE = 0.002         # starvation / collapse


# ----------------------------
# Player-Independent Needs
# ----------------------------

#HUNGER_MAX = 1.0
#THIRST_MAX = 1.0

#HUNGER_DECAY_RATE = 0.01                # per tick
#THIRST_DECAY_RATE = 0.015               # per tick

# ----------------------------
# Resources
# ----------------------------

# Canonical resource identifiers.
# Resources represent infrastructure-backed systems, not consumable stock.
RESOURCE_TYPES = [
    "water",
    "food",
    "scrap"
]

# Absolute bounds for any resource capacity.
# Actual capacities are derived per-settlement from type, population, and area strain.
RESOURCE_CAPACITY_MIN = 0
RESOURCE_CAPACITY_MAX = 10000

# Baseline per-settlement-type capacity multipliers.
# These are not guarantees, only scaling factors applied during generation.
RESOURCE_TYPE_CAPACITY_MULTIPLIER = {
    "outpost": 0.2,
    "hamlet": 0.4,
    "village": 0.7,
    "town": 1.0,
}

# Used to derive absolute capacity from population and type
RESOURCE_CAPACITY_BY_TYPE = {
    "outpost": 0.3,
    "hamlet": 0.6,
    "village": 0.8,
    "town": 1.0,
}

# Fraction of available labor that can be allocated per resource
RESOURCE_LABOR_SHARE_CAP = {
    "water": 0.4,
    "food": 0.4,
    "scrap": 0.2,
}

# Output per labor unit per tick (abstract units)
RESOURCE_LABOR_OUTPUT_RATE = {
    "water": 1.2,
    "food": 1.0,
    "scrap": 0.5,
}

# Infrastructure-limited output rate
RESOURCE_INFRA_OUTPUT_RATE = {
    "water": 1.0,
    "food": 1.0,
    "scrap": 1.0,
}

# Initial fill ratio of resource capacity at world init
INITIAL_RESOURCE_FILL_RATIO = 0.6

# Per-capita demand per tick.
# Used to compute consumption pressure during simulation and initial unmet demand.
RESOURCE_DEMAND_PER_CAPITA = {
    "water": 1.0,
    "food": 1.0,
    "scrap": 0.0,
}

# Strain sensitivity coefficients.
# Higher values mean unmet demand accumulates strain faster.
RESOURCE_STRAIN_SENSITIVITY = {
    "water": 1.2,
    "food": 1.0,
    "scrap": 0.2,
}

# Natural recovery rates when demand is met.
# Represents stabilization, repair, or replenishment capacity.
RESOURCE_STRAIN_RECOVERY = {
    "water": 0.02,
    "food": 0.01,
    "scrap": 0.005,
}

# One-tick starvation conversion factor
# Used only at world initialization
FOOD_STARVATION_FACTOR = 0.001

# Effect scaling applied downstream (simulation only).
# Defines how strongly accumulated strain impacts population or systems.
RESOURCE_STRAIN_EFFECT_SCALE = {
    "water": 1.5,
    "food": 1.0,
    "scrap": 0.3,
}


# ----------------------------
# Institutions
# ----------------------------

INSTITUTION_TYPES = [
    "archive",
    "enforcement",
    "civic",
    "religious"
]

MAX_INSTITUTIONS_PER_SETTLEMENT = 6
INSTITUTION_MAX = MAX_INSTITUTIONS_PER_SETTLEMENT

INSTITUTION_MIN = 0

INSTITUTION_CONDITION_MAX = 1.0
INSTITUTION_CONDITION_MIN = 0.0

INSTITUTION_DECAY_RATE = 0.0008

DEFAULT_INSTITUTION_POWER = {
    "archive": 0.6,
    "enforcement": 1.2,
    "civic": 1.0,
    "religious": 0.8
}

# Base labor overhead per institution, scaled by institution power
INSTITUTION_LABOR_RATE = 0.01

# Hard cap on total labor that institutions can consume
# Prevents bureaucratic collapse at world init
INSTITUTION_LABOR_CAP = 0.15

# ----------------------------
# Structures
# ----------------------------

STRUCTURE_TYPES = [
    "housing",
    "food",
    "water",
    "industrial",
    "storage",
    "transport",
]

# How many structures a settlement of a given type can support
STRUCTURE_COUNT_BY_SETTLEMENT_TYPE = {
    "outpost":  (0, 2),
    "hamlet":   (1, 6),
    "village":  (4, 12),
    "town":     (10, 30),
}

# How much production potential a structure can represent
# Used to determine size / rooms
STRUCTURE_PRODUCTION_SCALE = {
    "food":       (0.8, 1.2),
    "water":      (0.8, 1.2),
    "industrial": (0.7, 1.3),
    "storage":    (0.6, 1.1),
    "transport":  (0.5, 1.0),
    "housing":    (0.4, 0.8),
}

# Initial condition bounds before danger is applied
STRUCTURE_CONDITION_MIN = 0.5
STRUCTURE_CONDITION_MAX = 1.0

# How strongly area danger degrades condition
STRUCTURE_DANGER_CONDITION_WEIGHT = 0.5

# Room scaling (purely physical)
ROOMS_PER_STRUCTURE_UNIT = 5
ROOM_VARIANCE = 0.2

# ----------------------------
# Spatial Cost
# ----------------------------

ROOM_MIN = 1
ROOM_MAX = 20

ROOM_SIZES = [
    "tiny",
    "small",
    "medium",
    "large"
]

ROOM_TYPES_BY_STRUCTURE = {
    "residential": ["living", "sleeping", "storage"],
    "industrial": ["workshop", "storage"],
    "civic": ["assembly", "office"],
    "storage": ["storage"]
}

DISTANCE_COST_MIN = 1
DISTANCE_COST_MAX = 20

ROOM_TRAVEL_COST = 1
STRUCTURE_TRAVEL_COST = 2
SPACE_TRAVEL_COST = 5


# ----------------------------
# Pressures
# ----------------------------

PRESSURE_TYPES = [
    "unrest",
    "scarcity",
    "legitimacy"
]

PRESSURE_MIN = 0.0
PRESSURE_MAX = 1.0

UNREST_GROWTH_RATE = 0.01
UNREST_DECAY_RATE = 0.005

LEGITIMACY_DECAY_RATE = 0.002
LEGITIMACY_RECOVERY_RATE = 0.001




# ----------------------------
# Failure Thresholds
# ----------------------------

UNREST_FAILURE_THRESHOLD = 0.95
LEGITIMACY_FAILURE_THRESHOLD = 0.05
RESOURCE_FAILURE_THRESHOLD = 0.0


# ----------------------------
# Time
# ----------------------------

TICKS_PER_DAY = 1
DAYS_PER_CYCLE = 30