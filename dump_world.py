

#!/usr/bin/env python3
"""
dump_world.py

World inspection utility.
Builds a world from a single seed and prints the full JSON snapshot.
No validation, no hashing, no determinism checks.
"""

import sys
import json

# ----------------------------
# Argument handling
# ----------------------------

if len(sys.argv) != 2:
    raise SystemExit("usage: python3 dump_world.py <world_seed:int>")

try:
    WORLD_SEED = int(sys.argv[1])
except ValueError:
    raise SystemExit("world_seed must be an integer")

# ----------------------------
# Imports
# ----------------------------

from World.world import generate_world

# ----------------------------
# World generation
# ----------------------------

world = generate_world(WORLD_SEED)

# ----------------------------
# Output
# ----------------------------

print(
    json.dumps(
        world,
        indent=2,
        sort_keys=True,
    )
)