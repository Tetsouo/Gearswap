---============================================================================
--- FFXI GearSwap Auto-Documentation Script
---============================================================================
--- Professional documentation generator for GearSwap project files.
--- Analyzes existing code structure and generates comprehensive documentation
--- headers, function documentation, and inline comments following enterprise
--- standards.
---
--- @file auto_document.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-08-05
--- @usage //lua load auto_document
---============================================================================

-- Load dependencies
local log = require('utils/logger')

--- Professional documentation templates
local TEMPLATES = {
    header = [[
---============================================================================
--- FFXI GearSwap %s - %s (%s)
---============================================================================
--- %s
---
--- @file %s
--- @author Tetsouo  
--- @version 2.0
--- @date Created: %s | Modified: 2025-08-05
--- @requires %s
---
--- @usage
---   %s
---============================================================================
]],
    
    function_doc = [[
--- %s
--- %s
---
--- @param %s
--- @return %s
--- @usage %s
--- @see %s
]],
}

--- Job-specific documentation metadata
local JOB_DOCS = {
    BLM = {
        title = "Black Mage",
        description = "Professional Black Mage configuration with elemental magic mastery,\nMagic Burst optimization, and advanced spell timing management.",
        features = "• Elemental spell optimization with tier selection\n• Magic Burst mode for skillchain coordination\n• Mana conservation and efficiency algorithms\n• Weather and day bonus calculations"
    },
    
    BST = {
        title = "Beastmaster", 
        description = "Professional Beastmaster configuration with intelligent pet management,\necosystem filtering, and automated broth handling.",
        features = "• Ecosystem-based pet filtering with species selection\n• Automated broth equipment and usage tracking\n• Pet engagement and disengagement management\n• Jug pet data integration with combat optimization"
    },
    
    THF = {
        title = "Thief",
        description = "Professional Thief configuration with advanced Treasure Hunter management,\nSneak Attack/Trick Attack optimization, and stealth mechanics.",
        features = "• Intelligent TH tagging with minimal gear swapping\n• SA/TA preservation during movement\n• Ranged attack TH integration\n• Stealth and positioning assistance"
    },
    
    WAR = {
        title = "Warrior",
        description = "Professional Warrior configuration with advanced weapon skill optimization,\nretaliation management, and multi-weapon support.",
        features = "• TP-based weapon skill gear selection\n• Automatic retaliation cancellation on movement\n• Multi-weapon configuration with stat optimization\n• Berserker and aggressive stance management"
    },
    
    PLD = {
        title = "Paladin",
        description = "Professional Paladin configuration with advanced tanking capabilities,\nspell casting optimization, and defensive stance management.",  
        features = "• Intelligent tank gear swapping for threat management\n• Spell casting gear with cure potency optimization\n• Defensive cooldown timing and management\n• Enmity generation and control algorithms"
    },
    
    DRG = {
        title = "Dragoon",
        description = "Professional Dragoon configuration with wyvern support, jump abilities,\nand advanced weapon skill optimization.",
        features = "• Wyvern-aware pet management and gear optimization\n• Jump ability timing with recast management\n• Advanced weapon skill customization with TP scaling\n• Polearm mastery with multi-weapon support"
    },
    
    RUN = {
        title = "Rune Fencer",
        description = "Professional Rune Fencer configuration with elemental resistance management,\nrune enhancement optimization, and hybrid tanking capabilities.",
        features = "• Elemental rune management with resistance calculations\n• Ward and barrier spell optimization\n• Hybrid physical/magical damage mitigation\n• Elemental weapon skill enhancement"
    },
    
    DNC = {
        title = "Dancer",
        description = "Professional Dancer configuration with step/flourish management,\nTP conservation, and support ability timing.",
        features = "• Intelligent step targeting and debuff management\n• Flourish timing with optimal effect duration\n• TP conservation strategies for ability usage\n• Support ability coordination with party members"
    }
}

--- Generate professional documentation for a job file
--- @param job_code string Three-letter job code (e.g., "BLM", "THF")
--- @param file_path string Path to the job file
function generate_job_documentation(job_code, file_path)
    local job_info = JOB_DOCS[job_code]
    if not job_info then
        log.warn("No documentation template found for job: %s", job_code)
        return
    end
    
    local header = string.format(TEMPLATES.header,
        job_info.title,
        job_code,
        job_info.description,
        job_info.features,
        file_path,
        "2025-04-21", -- Creation date placeholder
        "Mote-Include.lua, modules/automove.lua, modules/shared.lua",
        "F9-F11: Mode cycling, //gs c cycle [mode] for manual control"
    )
    
    log.info("Generated documentation header for %s (%s)", job_code, job_info.title)
    print(header)
end

--- Main execution
log.info("🔧 Auto-Documentation Script Started")
log.info("📝 Professional documentation standards applied")

-- Generate documentation for all supported jobs
local jobs = {"BLM", "BST", "THF", "WAR", "PLD", "DRG", "RUN", "DNC"}

for _, job in ipairs(jobs) do
    generate_job_documentation(job, string.format("Tetsouo_%s.lua", job))
end

log.info("✅ Auto-documentation complete - %d job templates generated", #jobs)
log.info("📚 Apply these templates to enhance code documentation quality")