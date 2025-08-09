# GearSwap Job Templates

## Overview

This directory contains professional templates for creating new job configurations in the GearSwap modular system. These templates follow established best practices and provide a solid foundation for developing new job support.

## Template Files

### 1. `TEMPLATE_JOB.lua` - Main Job Configuration

The primary job file template containing:

- Core initialization functions
- Job setup and state management  
- Event handlers (precast, midcast, aftercast)
- Custom command handling
- Macro and appearance management
- Comprehensive documentation

### 2. `TEMPLATE_SET.lua` - Equipment Sets

Equipment set definition template with:

- Idle and defensive sets
- Engaged combat sets
- Precast sets (Fast Cast, Job Abilities, Weapon Skills)
- Midcast sets (spell potency)
- Job-specific specialized sets
- Movement speed integration

### 3. `TEMPLATE_FUNCTION.lua` - Advanced Job Functions

Advanced job-specific functionality template including:

- Job mechanic optimization algorithms
- Performance monitoring and tracking
- Error handling and recovery
- Utility and helper functions
- Professional logging integration

## Quick Start Guide

### Step 1: Choose Your Job

Decide which FFXI job you want to create configuration for (e.g., Corsair, Scholar, Summoner).

### Step 2: Copy Template Files

```bash
# Copy main job file
cp TEMPLATE_JOB.lua ../YourName_COR.lua

# Create job directory
mkdir -p ../jobs/cor/

# Copy equipment sets
cp TEMPLATE_SET.lua ../jobs/cor/COR_SET.lua

# Copy functions
cp TEMPLATE_FUNCTION.lua ../jobs/cor/COR_FUNCTION.lua
```

### Step 3: Replace Placeholders

Edit each file and replace all `[PLACEHOLDER]` values:

#### Common Placeholders

- `[JOB_NAME]` → Full job name (e.g., "Corsair")
- `[JOB_CODE]` → 3-letter job code (e.g., "COR")
- `[job_code]` → Lowercase job code (e.g., "cor")
- `[YOUR_NAME]` → Your name as author
- `[DATE]` → Current date

#### Job-Specific Placeholders

- `[JOB_FEATURE1]` → Main job mechanic (e.g., "Phantom Roll")
- `[JOB_ABILITY1]` → Job abilities (e.g., "Double-Up")
- `[ITEM_NAME]` → Equipment names (e.g., "Lanun Frac +3")
- `[MAGIC_TYPE]` → Magic schools (e.g., "Enfeebling Magic")

### Step 4: Customize Job Mechanics

Implement job-specific features:

1. **Equipment Sets** - Add actual gear pieces and augments
2. **Job Abilities** - Configure JA sets and timing
3. **Weapon Skills** - Optimize WS sets and selection
4. **Magic Spells** - Set up casting sets and spell logic
5. **Unique Mechanics** - Implement special job features

### Step 5: Test and Validate

```bash
# Load your job
//gs load YourName_COR

# Run tests
//gs c test

# Verify functionality
//gs validate
```

## Detailed Implementation Guide

### Equipment Sets (`COR_SET.lua`)

#### Basic Structure

```lua
-- Unique equipment variables
CorsairDice = createEquipment('Compensator', nil, 'wardrobe', {'Roll+ 3'})

-- Base sets
sets.idle = {
    main = createEquipment('Rostam'),
    -- ... more equipment
}

sets.engaged = {
    -- Melee combat gear
}

sets.precast.JA['Double-Up'] = {
    -- Job ability specific gear
}
```

#### Best Practices

- Use `createEquipment()` for all equipment objects
- Organize sets logically (idle → engaged → precast → midcast)
- Add comments explaining set purposes
- Use `set_combine()` for variations
- Define unique equipment as variables

### Job Functions (`COR_FUNCTION.lua`)

#### Core Functions Template

```lua
-- Job-specific optimization
function optimize_phantom_rolls(conditions, available_rolls)
    -- Algorithm for best roll selection
end

-- State detection
function detect_crooked_cards(roll_info)
    -- Detect Crooked Cards opportunities  
end

-- Performance tracking
local execution_times = {}

function track_performance(func_name, execution_time)
    -- Performance monitoring
end
```

#### Implementation Guidelines

- Add parameter validation to all functions
- Include comprehensive error handling
- Implement performance tracking
- Use professional logging
- Follow modular architecture patterns

### Main Job File (`YourName_COR.lua`)

#### Key Components

```lua
function job_setup()
    -- State configuration
    state.RollMode:options('Normal', 'Crooked Cards')
    
    -- Buff tracking  
    state.Buff['Double-Up'] = buffactive['double-up'] or false
    
    -- Keybindings
    send_command('bind F9 gs c cycle RollMode')
end

function job_precast(spell, action, spellMap, eventArgs)
    -- Pre-casting logic
    if spell.type == 'CorsairRoll' then
        optimize_roll_gear(spell)
    end
end
```

## Advanced Features

### State Management

Configure job-specific states for mode switching:

```lua
-- Roll optimization modes
state.RollMode:options('Conservative', 'Aggressive', 'Bust Protection')

-- Weapon configurations
state.WeaponSet = M{'Rostam', 'Fomalhaut', 'Ataktos'}

-- Combat styles
state.CombatRole:options('DD', 'Support', 'Hybrid')
```

### Buff Integration

Track job-specific buffs for gear optimization:

```lua
state.Buff['Phantom Roll'] = buffactive['phantom roll'] or false
state.Buff['Crooked Cards'] = buffactive['crooked cards'] or false
state.Buff['Triple Shot'] = buffactive['triple shot'] or false
```

### Custom Commands

Add job-specific commands for special functionality:

```lua
function job_self_command(cmdParams, eventArgs)
    if cmdParams[1] == 'rollall' then
        execute_phantom_roll_sequence()
        eventArgs.handled = true
    elseif cmdParams[1] == 'optimize' then
        optimize_current_rolls()
        eventArgs.handled = true
    end
end
```

## Testing Your Implementation

### Basic Functionality Tests

1. **Loading** - Job loads without errors
2. **Equipment** - All sets equip correctly  
3. **Commands** - Custom commands work
4. **States** - Mode cycling functions
5. **Events** - Precast/midcast/aftercast work

### Advanced Tests

```bash
# Test specific job abilities
//ja "Phantom Roll" <me>

# Test weapon skills  
//ws "Leaden Salute" <t>

# Test mode switching
//gs c cycle RollMode

# Performance test
//gs c test
```

### Validation Checklist

- [ ] All placeholders replaced
- [ ] Equipment names spelled correctly
- [ ] Job abilities configured properly
- [ ] Weapon skills optimized
- [ ] Magic spells (if applicable) set up
- [ ] Custom mechanics implemented
- [ ] Error handling included
- [ ] Performance monitoring active
- [ ] Documentation updated
- [ ] Tests pass successfully

## Common Issues and Solutions

### Issue: Equipment Not Found

**Solution**: Verify equipment names match in-game spelling exactly

### Issue: Job Abilities Not Working  

**Solution**: Check ability IDs and recast tracking

### Issue: Performance Problems

**Solution**: Use performance monitor to identify bottlenecks

### Issue: State Cycling Not Working

**Solution**: Verify state names and keybinding syntax

## Support and Resources

### Documentation

- `DEPENDENCIES.md` - Required dependencies
- `CHANGELOG.md` - Version history  
- `tests/README.md` - Testing framework
- Job-specific documentation in `jobs/[job]/` directories

### Getting Help

1. Check existing job implementations for examples
2. Review module documentation in `core/` and `utils/`
3. Use the test framework to validate functionality
4. Check performance with monitoring tools

### Contributing

When you create a successful job implementation:

1. Document any unique patterns or solutions
2. Share optimization techniques
3. Report any template improvements needed
4. Consider contributing back to the project

## Template Evolution

These templates are living documents that evolve with the system. When updating templates:

1. **Maintain Compatibility** - Existing jobs should continue working
2. **Add New Features** - Incorporate new modular capabilities  
3. **Improve Documentation** - Keep examples current and clear
4. **Update Best Practices** - Reflect learned optimizations

The templates provide a solid foundation, but each job's unique mechanics will require custom implementation. Use the templates as a starting point and adapt them to fit your specific job's needs.
