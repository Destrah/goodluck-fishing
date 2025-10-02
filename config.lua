Config = {};

Config.treasureItems = {
    'greendongle',
    'stolen2ctchain',
    'stolenring',
    'stolennecklace',
    'stolenoakleys',
    'aquamarine_gem',
    'hairtie',
    'regularbriefcase',
    'walkstick',
    'bands',
    'lockpick',
    'advancedlockpick',
    'shitlockpick',
    'oxy',
    'cigar',
    'emerald',
    'towrope',
}

Config.treasureItemsPlus = {
    'rollcash',
    'plastic',
    'copper',
    'aluminum',
    'iron',
    'steel',
    'rubber',
    'glass',
    'aluminumoxide',
}

Config.boats = {
    {
        label = 'Nagasaki Dinghy',
        model = 'dinghy',
        price = 1500,
    },
    {
        label = 'Shitzu Squalo',
        model = 'squalo',
        price = 1500,
    },
    {
        label = 'Dinka Marquis',
        model = 'marquis',
        price = 1500,
    },
}

Config.BaitInfo = {
    ['fresh_fishbait'] = {
        validLines = {
            "basic_fishingline",
            "adv_fishingline",
            "pro_fishingline",
            "master_fishingline",
            "illegal_fishingline",
        }
    },
    ['salt_fishbait'] = {
        validLines = {
            "pro_fishingline",
            "master_fishingline",
            "illegal_fishingline",
        }
    },
    ['shark_bait'] = {
        validLines = {
            "pro_fishingline",
            "master_fishingline",
            "illegal_fishingline",
        }
    },
    ['turtle_bait'] = {
        validLines = {
            "pro_fishingline",
            "master_fishingline",
            "illegal_fishingline",
        }
    },
}

Config.FishInfo = {
    ['salt'] = {
        ['fish_salmon'] = {
            minWeight = 8.0,
            avgWeight = 20.0,
            maxWeight = 40.0,
            minCatchDepth = 10.0,
            maxWeightDepth = 75.0,
            higherChance = 20.0,
            lowerChance = 35.0,
            avgVariation = {0.0, 1.5},
            pricePerPound = 2.784
        },
        ['fish_cod'] = {
            minWeight = 10.0,
            avgWeight = 25.0,
            maxWeight = 88.0,
            minCatchDepth = 20.0,
            maxWeightDepth = 100.0,
            higherChance = 20.0,
            lowerChance = 35.0,
            avgVariation = {0.0, 2.0},
            pricePerPound = 2.2272
        },
        ['fish_flounder'] = {
            minWeight = 3.0,
            avgWeight = 5.0,
            maxWeight = 8.5,
            minCatchDepth = 3.0,
            maxWeightDepth = 40.0,
            higherChance = 20.0,
            lowerChance = 35.0,
            avgVariation = {0.0, 1.2},
            pricePerPound = 11.136
        },
        ['fish_mackerel'] = {
            minWeight = 3.0,
            avgWeight = 5.0,
            maxWeight = 8.5,
            minCatchDepth = 3.0,
            maxWeightDepth = 15.0,
            higherChance = 20.0,
            lowerChance = 35.0,
            avgVariation = {0.0, 0.5},
            pricePerPound = 11.136
        },
        ['fish_barracuda'] = {
            minWeight = 5.5,
            avgWeight = 12.0,
            maxWeight = 22.0,
            minCatchDepth = 35.0,
            maxWeightDepth = 300.0,
            higherChance = 20.0,
            lowerChance = 35.0,
            avgVariation = {0.0, 0.5},
            pricePerPound = 4.6458
        },
        ['fish_sword'] = {
            minWeight = 40.0,
            avgWeight = 110.0,
            maxWeight = 200.0,
            minCatchDepth = 35.0,
            maxWeightDepth = 300.0,
            higherChance = 20.0,
            lowerChance = 35.0,
            avgVariation = {0.0, 0.5},
            pricePerPound = 0.522
        },
        ['fish_bluefintuna'] = {
            minWeight = 50.0,
            avgWeight = 500.0,
            maxWeight = 1350.0,
            minCatchDepth = 35.0,
            maxWeightDepth = 300.0,
            higherChance = 20.0,
            lowerChance = 35.0,
            avgVariation = {0.0, 0.5},
            pricePerPound = 0.12876
        },
    },
    ['fresh'] = {
        ['fish_bass'] = {
            minWeight = 8.0,
            avgWeight = 12.0,
            maxWeight = 20.0,
            minCatchDepth = 3.0,
            maxWeightDepth = 30.0,
            higherChance = 20.0,
            lowerChance = 35.0,
            avgVariation = {0.0, 1.5},
            pricePerPound = 2.346
        },
        ['fish_bream'] = {
            minWeight = 2.4,
            avgWeight = 5.0,
            maxWeight = 10.0,
            minCatchDepth = 3.0,
            maxWeightDepth = 20.0,
            higherChance = 20.0,
            lowerChance = 35.0,
            avgVariation = {0.0, 0.5},
            pricePerPound = 5.6304
        },
        ['fish_bluegill'] = {
            minWeight = 0.4,
            avgWeight = 1.0,
            maxWeight = 2.5,
            minCatchDepth = 3.0,
            maxWeightDepth = 15.0,
            higherChance = 20.0,
            lowerChance = 35.0,
            avgVariation = {0.0, 0.5},
            pricePerPound = 28.152
        },
        ['fish_redtail'] = {
            minWeight = 10.0,
            avgWeight = 22.0,
            maxWeight = 120.0,
            minCatchDepth = 20.0,
            maxWeightDepth = 100.0,
            higherChance = 20.0,
            lowerChance = 35.0,
            avgVariation = {0.0, 2.0},
            pricePerPound = 1.518
        },
        ['fish_walleye'] = {
            minWeight = 9.0,
            avgWeight = 14.0,
            maxWeight = 20.0,
            minCatchDepth = 3.0,
            maxWeightDepth = 30.0,
            higherChance = 20.0,
            lowerChance = 35.0,
            avgVariation = {0.0, 1.2},
            pricePerPound = 2.07
        },
        ['fish_perch'] = {
            minWeight = 0.4,
            avgWeight = 1.0,
            maxWeight = 2.5,
            minCatchDepth = 3.0,
            maxWeightDepth = 15.0,
            higherChance = 20.0,
            lowerChance = 35.0,
            avgVariation = {0.0, 0.5},
            pricePerPound = 28.152
        },
        ['fish_tilapia'] = {
            minWeight = 1.4,
            avgWeight = 2.1,
            maxWeight = 5.0,
            minCatchDepth = 3.0,
            maxWeightDepth = 15.0,
            higherChance = 20.0,
            lowerChance = 35.0,
            avgVariation = {0.0, 0.5},
            pricePerPound = 13.4136
        },
    },
    ['rare_salt'] = {
        ['fish_clown'] = {
            minWeight = 0.1,
            avgWeight = 0.5,
            maxWeight = 1.5,
            minCatchDepth = 50.0,
            maxWeightDepth = 15.0,
            higherChance = 20.0,
            lowerChance = 35.0,
            avgVariation = {0.0, 0.5},
            pricePerPound = 100.0
        },
    },
    ['rare_fresh'] = {
        ['fish_discus'] = {
            minWeight = 0.1,
            avgWeight = 0.5,
            maxWeight = 1.5,
            minCatchDepth = 20.0,
            maxWeightDepth = 15.0,
            higherChance = 20.0,
            lowerChance = 35.0,
            avgVariation = {0.0, 0.5},
            pricePerPound = 80.0
        },
    },
    ['turtle'] = {
        ['turtle'] = {
            minWeight = 50.0,
            avgWeight = 80.0,
            maxWeight = 100.0,
            minCatchDepth = 60.0,
            maxWeightDepth = 300.0,
            higherChance = 20.0,
            lowerChance = 35.0,
            avgVariation = {0.0, 0.5},
            pricePerPound = 1.8
        },
    },
    ['rare_turtle'] = {},
    ['shark'] = {
        ['fish_shark'] = {
            minWeight = 850,
            avgWeight = 1400,
            maxWeight = 1900,
            minCatchDepth = 60.0,
            maxWeightDepth = 300.0,
            higherChance = 20.0,
            lowerChance = 35.0,
            avgVariation = {0.0, 0.5},
            pricePerPound = 0.1
        },
    },
    ['rare_shark'] = {}
}