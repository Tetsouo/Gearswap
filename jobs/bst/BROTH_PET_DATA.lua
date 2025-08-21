---============================================================================
--- FFXI GearSwap Data Module - Beastmaster Jug Pet Database
---============================================================================
--- Comprehensive database of all BST jug pets with their associated broth,
--- species classification, ecosystem categorization, and job specializations.
--- This data drives the intelligent pet selection and ecosystem management
--- systems for optimal Beastmaster performance.
---
--- Database includes 25+ jug pets across all ecosystems:
--- • **Aquan Ecosystem** - Fish, Crab species with tank/DD specializations
--- • **Amorph Ecosystem** - Acuex, Slime, Leech, Slug with diverse roles
--- • **Beast Ecosystem** - Tiger, Sheep, Rabbit, Raaz with combat focus
--- • **Bird Ecosystem** - Colibri, Hippogryph, Tulfaire with hybrid abilities
--- • **Lizard Ecosystem** - Lizard, Eft species with warrior specializations
--- • **Plantoid Ecosystem** - Funguar, Mandragora with support capabilities
--- • **Vermin Ecosystem** - Chapuli, Ladybug, Fly, Beetle, and specialist pets
---
--- Each entry contains: broth requirement, species type, ecosystem category,
--- and job specialization for intelligent pet selection algorithms.
---
--- @file jobs/bst/broth_pet_data.lua
--- @author Tetsouo
--- @version 2.0
--- @date Created: 2023-07-10 | Modified: 2025-08-05
--- @requires BST job configuration
---
--- @usage
---   local jug_data = require('jobs/bst/BROTH_PET_DATA')
---   local pet_info = jug_data[pet_name]
---
--- @see jobs/bst/BST_FUNCTION.lua for ecosystem management logic
---============================================================================

local jug_data = {
    ["Amiable Roche (Fish)"]        = { broth = "Airy Broth", species = "Fish", ecosystem = "Aquan", job = "WAR" },
    ["Jovial Edwin (Crab)"]         = { broth = "Pungent Broth", species = "Crab", ecosystem = "Aquan", job = "PLD" },
    ["Fluffy Bredo (Acuex)"]        = { broth = "Venomous Broth", species = "Acuex", ecosystem = "Amorph", job = "DRK" },
    ["Sultry Patrice (Slime)"]      = { broth = "Putrescent Broth", species = "Slime", ecosystem = "Amorph", job = "WAR" },
    ["Fatso Fargann (Leech)"]       = { broth = "C. Plasma Broth", species = "Leech", ecosystem = "Amorph", job = "WAR" },
    ["Generous Arthur (Slug)"]      = { broth = "Dire Broth", species = "Slug", ecosystem = "Amorph", job = "WAR" },
    ["Blackbeard Randy (Tiger)"]    = { broth = "Meaty Broth", species = "Tiger", ecosystem = "Beast", job = "WAR" },
    ["Rhyming Shizuna (Sheep)"]     = { broth = "Lyrical Broth", species = "Sheep", ecosystem = "Beast", job = "WAR" },
    ["Pondering Peter (Rabbit)"]    = { broth = "Vis. Broth", species = "Rabbit", ecosystem = "Beast", job = "WAR" },
    ["Vivacious Vickie (Raaz)"]     = { broth = "Tant. Broth", species = "Raaz", ecosystem = "Beast", job = "MNK" },
    ["Choral Leera (Colibri)"]      = { broth = "Glazed Broth", species = "Colibri", ecosystem = "Bird", job = "NIN/RDM" },
    ["Daring Roland (Hippogryph)"]  = { broth = "Feculent Broth", species = "Hippogryph", ecosystem = "Bird", job = "THF/BLM" },
    ["Swooping Zhivago (Tulfaire)"] = { broth = "Windy Greens", species = "Tulfaire", ecosystem = "Bird", job = "WAR" },
    ["Warlike Patrick (Lizard)"]    = { broth = "Livid Broth", species = "Lizard", ecosystem = "Lizard", job = "WAR" },
    ["Suspicious Alice (Eft)"]      = { broth = "Furious Broth", species = "Eft", ecosystem = "Lizard", job = "WAR" },
    ["Brainy Waluis (Funguar)"]     = { broth = "Crumbly Soil", species = "Funguar", ecosystem = "Plantoid", job = "WAR" },
    ["Sweet Caroline (Mandragora)"] = { broth = "Aged Humus", species = "Mandragora", ecosystem = "Plantoid", job = "MNK" },
    ["Bouncing Bertha (Chapuli)"]   = { broth = "Bubbly Broth", species = "Chapuli", ecosystem = "Vermin", job = "WAR" },
    ["Threestar Lynn (Ladybug)"]    = { broth = "Muddy Broth", species = "Ladybug", ecosystem = "Vermin", job = "THF" },
    ["Headbreaker Ken (Fly)"]       = { broth = "Blackwater Broth", species = "Fly", ecosystem = "Vermin", job = "WAR" },
    ["Energized Sefina (Beetle)"]   = { broth = "Gassy Sap", species = "Beetle", ecosystem = "Vermin", job = "WAR" },
    ["Anklebiter Jedd (Diremite)"]  = { broth = "Crackling Broth", species = "Diremite", ecosystem = "Vermin", job = "DRK/BLM" },
    ["Left-Handed Yoko (Mosquito)"] = { broth = "Heavenly Broth", species = "Mosquito", ecosystem = "Vermin", job = "DRK" },
    ["Cursed Annabelle (Antlion)"]  = { broth = "Creepy Broth", species = "Antlion", ecosystem = "Vermin", job = "WAR" },
    ["Weevil Familiar (Weevil)"]    = { broth = "T. Pristine Sap", species = "Weevil", ecosystem = "Vermin", job = "THF" },
}

return jug_data
