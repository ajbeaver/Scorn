WORLD_SCHEMA = {
    "meta": {
        # Immutable identity + time tracking
        "world_seed": int,
        "tick": int,
        "age": int
    },

    # Abstract traversable spaces (areas, regions, zones)
    "spaces": {
        "<space_id>": {
            "seed": int,
            "type": str,  # e.g. cavern, tunnel, surface, ruin

            # Topology + cost defines distance
            "connections": {
                "<other_space_id>": {
                    "distance": int,
                    "cost": {
                        "hunger": float,
                        "thirst": float,
                        "fatigue": float
                    }
                }
            },

            # Ambient conditions
            "environment": {
                "temperature": float,
                "hazard": float,
                "stability": float
            }
        }
    },

    # Population centers bound to spaces
    "settlements": {
        "<settlement_id>": {
            "seed": int,
            "space": "<space_id>",

            "population": {
                "total": int,
                "growth_rate": float,
                "health": float,
                "morale": float
            },

            "resources": {
                "water": {
                    "current": float,
                    "capacity": float,
                    "quality": float
                },
                "food": {
                    "current": float,
                    "capacity": float,
                    "spoilage": float
                }
            },

            "infrastructure": {
                "water_system": {
                    "condition": float,
                    "throughput": float
                },
                "shelter": {
                    "condition": float,
                    "capacity": int
                }
            },

            "institutions": {
                "<institution_id>": {
                    "type": str,
                    "power": float,
                    "condition": float
                }
            },

            "state": {
                "legitimacy": float,
                "unrest": float,
                "collapse_risk": float
            }
        }
    },

    # Mobile ideological / political entities
    "factions": {
        "<faction_id>": {
            "seed": int,
            "ideology": float,
            "cohesion": float,

            "resources": {
                "wealth": float,
                "influence": float
            },

            "relations": {
                "<other_faction_id>": float
            }
        }
    },

    # Global background forces
    "pressures": {
        "scarcity": float,
        "environmental": float,
        "political": float,
        "entropy": float
    }
}