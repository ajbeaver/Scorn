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

# Generation Bounds (Legacy / Generator-facing)
WORLD_MIN_AREAS = 1
WORLD_MAX_AREAS = 16

AREA_MIN_SETTLEMENTS = 0
AREA_MAX_SETTLEMENTS = 4

AREA_TRAVEL_COST_MIN = 1
AREA_TRAVEL_COST_MAX = 10

MAX_SPACES_PER_WORLD = 128
MIN_SPACES_PER_WORLD = 8

MAX_SETTLEMENTS_PER_SPACE = 2
MIN_SETTLEMENTS_PER_SPACE = 0


# ----------------------------
# Population
# ----------------------------


SETTLEMENT_MIN_AGE = 0
SETTLEMENT_MAX_AGE = 300

SETTLEMENT_TYPES = [
    "outpost",
    "hamlet",
    "village",
    "town"
]

MIN_POPULATION = 0
MAX_POPULATION = 5000

DEFAULT_POPULATION = 120

POPULATION_GROWTH_RATE = 0.0005        # per tick (used later)
POPULATION_DECLINE_RATE = 0.002         # starvation / collapse


# ----------------------------
# Player-Independent Needs
# ----------------------------

HUNGER_MAX = 1.0
THIRST_MAX = 1.0

HUNGER_DECAY_RATE = 0.01                # per tick
THIRST_DECAY_RATE = 0.015               # per tick


# ----------------------------
# Resources
# ----------------------------

RESOURCE_TYPES = [
    "water",
    "food",
    "scrap"
]

RESOURCE_CAPACITY_MIN = 0
RESOURCE_CAPACITY_MAX = 10000

DEFAULT_WATER_CAPACITY = 100
DEFAULT_FOOD_CAPACITY = 80
DEFAULT_SCRAP_CAPACITY = 20

RESOURCE_DECAY_RATE = {
    "water": 0.002,
    "food": 0.01,
    "scrap": 0.0
}


# ----------------------------
# Infrastructure
# ----------------------------

STRUCTURE_TYPES = [
    "residential",
    "industrial",
    "civic",
    "storage"
]

STRUCTURE_SCALES = [
    "small",
    "medium",
    "large"
]

STRUCTURE_MIN = 0
STRUCTURE_MAX = 12

MAX_PUMPS_PER_SETTLEMENT = 5
DEFAULT_PUMPS = 1

PUMP_CONDITION_MAX = 1.0
PUMP_CONDITION_MIN = 0.0

PUMP_DECAY_RATE = 0.001
PUMP_REPAIR_AMOUNT = 0.2


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