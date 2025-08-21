# Complete Command Guide - GearSwap Tetsouo v2.1.0

## Command Index

### [Test and Validation Commands](#test-validation)

### [Combat Commands (F9-F12)](#combat)  

### [Job-Specific Commands](#job-specific)

### [Basic GearSwap Commands](#gearswap-base)

### [Performance Commands](#performance)

### [Advanced Commands](#advanced)

---

## Test and Validation {#test-validation}

### Automatic Test System v2.1.0

| Command                   | Description                       | Usage Example     |
| ------------------------- | --------------------------------- | ----------------- |
| `//gs c equiptest start`  | Safe equipment analysis (instant) | Quick check       |
| `//gs c equiptest report` | Show error report                 | After tests       |
| `//gs c equiptest status` | System status                     | Check progression |

### Manual Validation

| Command                      | Description                               | Recommended Usage          |
| ---------------------------- | ----------------------------------------- | -------------------------- |
| `//gs c validate_all`        | Validates ALL sets without equipping them | Quick verification         |
| `//gs c validate_set [name]` | Validates a specific set                  | `//gs c validate_set idle` |
| `//gs c missing_items`       | Lists all missing items                   | Missing inventory          |
| `//gs c current`             | Validates currently worn equipment        | Check current gear         |
| `//gs c clear_cache`         | Clears validation cache                   | If detection issues        |
| `//gs c cache_stats`         | Cache statistics (29K items)              | Technical info             |

### Test Session Example

```bash
# 1. Launch automatic tests  
//gs c equiptest start
# ... wait for test completion (progress display) ...

# 2. View detailed report
//gs c equiptest report

# 3. If errors, view missing items
//gs c missing_items

# 4. Validate after corrections
//gs c validate_all
```

### Detailed Test Report

```text
[205] ============================
[205]   EQUIPMENT ANALYSIS v2.1.0
[205] ============================
[030] [CACHE] 29263 items indexed  
[030] [OK] System ready
[050] [SYSTEM] Direct analysis mode: ENABLED
[056] [SCAN] 52 sets detected for job: DNC
[050] [QUEUE] 52 sets scheduled for testing
[037] [TIMING] Delay between tests: 2 sec
[205] ============================

# ... test progression ...

[205] ============================  
[205]         FINAL REPORT
[205] ============================
[037] [TIMING] Total execution time: 104 sec
[050] [SUMMARY] 52 sets tested
[028] TOTAL: 1 error(s)
[057]   - 1 item(s) found in STORAGE/LOCKER  
[167] > sets.Ochain
[057]   [sub] Ochain: Item found in LOCKER - move to inventory/wardrobe to equip
[205] ============================
```

---

## Combat Commands {#combat}

### Shortcut Keys (F9-F12)

| Key     | Alternative Command        | Description                      | All Jobs |
| ------- | -------------------------- | -------------------------------- | -------- |
| **F9**  | `//gs c cycle OffenseMode` | Offense mode                     | Yes      |
| **F10** | `//gs c cycle DefenseMode` | Defense mode Physical (None/PDT) | Yes      |
| **F11** | `//gs c cycle DefenseMode` | Defense mode Magical (None/MDT)  | Yes      |
| **F12** | State Summary              | Shows current state information  | Yes      |

### Universal Combat Modes

| Command                         | Description                | Possible Values         |
| ------------------------------- | -------------------------- | ----------------------- |
| `//gs c set OffenseMode [mode]` | Force offense mode         | Normal, Acc, FullAcc    |
| `//gs c set DefenseMode [mode]` | Force defense mode         | None, PDT, MDT          |
| `//gs c set IdleMode [mode]`    | Force idle mode            | Normal, Regen, PDT, MDT |
| `//gs c set WeaponMode [mode]`  | Force weapon set           | Job dependent           |
| `//gs c toggle Kiting`          | Enable/disable Kiting mode | On/Off                  |

### Combat Usage Example

```bash
# Before difficult combat
F11                              # Activate PDT defense
//gs c toggle Kiting             # Activate fast movement

# During precision combat
F9                               # Switch to Accuracy mode  

# After combat  
F11                              # Return to None defense
F12                              # Appropriate idle mode
```

---

## Job-Specific Commands {#job-specific}

### Paladin (PLD)

#### PLD Keybinds F1-F7

| Key | Description | Command              |
| --- | ----------- | -------------------- |
| F1  | HybridMode  | Cycle PDT/Normal/MDT |
| F2  | WeaponSet   | Cycle weapons        |
| F3  | SubSet      | Cycle shields        |

#### PLD Commands

```bash
# Specialized modes
//gs c cycle Shield              # Ochain → Aegis → Priwen
//gs c toggle Cover              # Cover mode on/off
//gs c toggle Sentinel           # Sentinel mode on/off

# Action commands
//gs c enmity                    # Equip full enmity set
//gs c reprisal                  # Optimized Reprisal set
//gs c flash                     # Flash enmity set
```

### Warrior (WAR)

#### WAR Keybinds F1-F7

| Key | Description | Command              |
| --- | ----------- | -------------------- |
| F1  | WeaponSet   | Cycle weapons        |
| F2  | AmmoSet     | Cycle ammunition     |
| F7  | HybridMode  | Cycle PDT/Normal/MDT |

#### WAR Commands  

```bash
# Berserk modes
//gs c toggle Berserk            # Berserk mode on/off
//gs c toggle Retaliation        # Retaliation mode on/off

# Specialized commands  
//gs c warcry                    # Optimized Warcry set
//gs c provoke                   # Provoke enmity set
//gs c aggressor                 # Aggressor set
```

### Thief (THF)

#### THF Keybinds F1-F7

**Note**: THF keybinds need to be configured in job file.

#### THF Commands

```bash
# Treasure Hunter
//gs c toggle TH                 # TH on/off
//gs c cycle THMode              # Tag → SATA → Fulltime
//gs c set THMode Tag            # Force Tag mode

# Special modes
//gs c toggle Flee              # Flee mode on/off
//gs c sneak                     # Sneak Attack set
//gs c trick                     # Trick Attack set
```

### Black Mage (BLM)

#### BLM Keybinds F1-F7

| Key | Description    | Command                    |
| --- | -------------- | -------------------------- |
| F1  | MainLightSpell | Cycle Fire/Thunder/Aero    |
| F2  | MainDarkSpell  | Cycle Stone/Blizzard/Water |
| F3  | SubLightSpell  | Cycle light elements       |
| F4  | SubDarkSpell   | Cycle dark elements        |
| F5  | Aja            | Cycle -ja spells           |
| F6  | TierSpell      | Cycle spell tiers          |
| F7  | Storm          | Cycle storm spells         |
| F9  | CastingMode    | Normal/MagicBurst          |

#### Alt Player Commands

```bash
//gs c altlight                 # Cast light spell on alt
//gs c altdark                  # Cast dark spell on alt
```

#### BLM Commands

```bash
# Magic Burst
//gs c toggle MagicBurst         # MB on/off
//gs c cycle NukeMode            # Normal → Acc → Burst

# Elements
//gs c element [elem]            # Force element (fire/ice/etc)
//gs c cycle Element             # Cycle all elements

# Scholar arts  
//gs c scholar [art]             # Light/Dark arts
//gs c cycle ScholarArts         # Cycle arts
```

### Dancer (DNC)

#### DNC Keybinds F1-F7

**Note**: DNC keybinds need to be configured in job file.

#### DNC Commands

```bash
# Dance actions
//gs c step                      # Equip optimized Step set
//gs c flourish                  # Equip Flourish set  
//gs c waltz                     # Optimal Waltz set

# Special modes
//gs c toggle Saber              # Saber Dance on/off
//gs c cycle StepMode             # Single → Double → Triple
```

### Dragoon (DRG)

#### DRG Keybinds F1-F7

**Note**: DRG keybinds need to be configured in job file.

#### DRG Commands  

```bash
# Jump modes
//gs c toggle Jump               # Jump mode on/off
//gs c high_jump                 # High Jump set

# Wyvern
//gs c angon                     # Optimized Angon set  
//gs c breath                    # Healing Breath set
//gs c spirit_link               # Spirit Link set
```

### Rune Fencer (RUN)

#### RUN Keybinds F1-F7

**Note**: RUN keybinds need to be configured in job file.

#### RUN Commands

```bash  
# Rune management
//gs c cycle Runes              # Cycle all runes
//gs c rune [element]            # Ignis/Gelus/Flabra/Tellus/etc
//gs c rune ice                  # Force Gelus rune

# Ward modes
//gs c toggle Rayke             # Rayke mode on/off  
//gs c toggle Gambit            # Gambit mode on/off
//gs c battuta                  # Battuta set
```

### Bard (BRD)

#### BRD Keybinds F1-F7

| Key | Description    | Command                    |
| --- | -------------- | -------------------------- |
| F1  | Song Cycle     | Cycle through song modes   |
| F2  | Honor March    | Honor March song           |
| F3  | Minne/Minuet   | Cycle defensive songs      |
| F4  | Threnody       | Elemental resistance songs |
| F5  | Carol          | Elemental resistance songs |
| F6  | Refresh        | Song refresh management    |
| F7  | Party Mode     | Party vs solo song modes   |

#### BRD Advanced Commands

```bash
# Song Management
//gs c song [song_name]         # Cast specific song
//gs c refresh_songs            # Refresh all active songs
//gs c cycle SongMode           # Solo/Party/Buff modes

# Specialized Songs
//gs c threnody [element]       # Specific threnody
//gs c carol [element]          # Specific carol
//gs c ballad                   # Mage's Ballad
//gs c march                    # Victory March
//gs c minne                    # Knight's Minne
//gs c minuet                   # Sword Madrigal

# Advanced Features (6 specialized modules)
//gs c debug_songs              # BRD debug utilities
//gs c song_counter             # Display active song count
//gs c buff_manager             # Manage song buffs
```

### Beastmaster (BST)

#### BST Keybinds F1-F7

| Key | Description   | Command                |
| --- | ------------- | ---------------------- |
| F1  | AutoPetEngage | Toggle pet auto-engage |
| F2  | WeaponSet     | Cycle weapons          |
| F3  | SubSet        | Cycle sub weapons      |
| F4  | Ecosystem     | Cycle ecosystems       |
| F5  | Species       | Cycle species          |
| F6  | PetIdleMode   | Cycle pet idle modes   |
| F7  | HybridMode    | Cycle hybrid modes     |

#### BST Commands

```bash
# Alternative commands
//gs c bst_ecosystem            # Change ecosystem + update pets
//gs c bst_species              # Change species + equip broth  
//gs c display_selection_info   # Display current selection
//gs c display_broth_count      # Count available jugs

# Pet actions
//gs c reward                   # Optimized Reward set
//gs c charm                    # Charm set  
//gs c toggle Killer            # Killer effects on/off
```

---

## Basic GearSwap Commands {#gearswap-base}

### Essential Commands

| Command            | Description                 | Usage                   |
| ------------------ | --------------------------- | ----------------------- |
| `//gs load [file]` | Loads a job file            | `//gs load Tetsouo_PLD` |
| `//gs reload`      | Reloads current file        | After modifications     |
| `//gs export`      | Exports your current sets   | Backup                  |
| `//gs showswaps`   | Shows equipment changes     | Debug                   |
| `//gs debugmode`   | Enables/disables debug mode | Troubleshooting         |
| `//gs validate`    | Checks Lua syntax           | Before reload           |

### Equipment Commands

| Command                    | Description             | Example                |
| -------------------------- | ----------------------- | ---------------------- |
| `//gs equip [set]`         | Equips a set manually   | `//gs equip sets.idle` |
| `//gs equip naked`         | Removes all equipment   | Complete reset         |
| `//gs c safe_equip [set]`  | Equips after validation | Safe                   |
| `//gs c force_equip [set]` | Forces equipment        | Ignore errors          |

---

## Performance Commands {#performance}

### Performance Monitoring System

| Command               | Description                             |
| --------------------- | --------------------------------------- |
| `//gs c perf enable`  | Enables monitoring with clean interface |
| `//gs c perf disable` | Disables monitoring (data preserved)    |
| `//gs c perf report`  | Displays complete detailed report       |
| `//gs c perf reset`   | Resets all metrics to zero              |

See [Performance Monitoring Guide](PERFORMANCE_MONITORING_GUIDE.md) for complete details.

---

## Advanced Commands {#advanced}

### Debug and Development  

| Command                    | Description        | Usage           |
| -------------------------- | ------------------ | --------------- |
| `//gs c debug_equip [set]` | Detailed set debug | Developers      |
| `//gs c testcmd`           | List test commands | Debug           |
| `//gs c help`              | Contextual help    | General info    |
| `//gs c info`              | System information | Complete status |

### System Commands

| Command                | Description           | Function     |
| ---------------------- | --------------------- | ------------ |
| `//gs c clear_cache`   | Clears system cache   | If slow      |
| `//gs c rebuild_cache` | Rebuilds cache        | After update |
| `//gs c memory_usage`  | Detailed memory usage | Monitoring   |
| `//gs c performance`   | Performance stats     | Diagnostic   |

---

## Recommended Workflows

### Daily Workflow

```bash
# 1. At login
//gs reload
//gs c equiptest start

# 2. After set modifications  
//gs reload
//gs c validate_all

# 3. If errors detected
//gs c equiptest report
//gs c missing_items

# 4. Debug if necessary
//gs debugmode
//gs showswaps
```

### Debug Workflow

```bash  
# 1. Enable complete debug
//gs debugmode
//gs showswaps

# 2. Specific test
//gs c debug_equip [set_name]
//gs c validate_set [set_name]

# 3. Cache and performance
//gs c clear_cache
//gs c info

# 4. Disable debug
//gs debugmode
```

### Professional Shortcuts

```bash
# Recommended macros
Alt+R = //gs reload
Alt+T = //gs c equiptest start  
Alt+V = //gs c validate_all
Alt+E = //gs c equiptest report
Alt+I = //gs c info
Alt+H = //gs c help
```

---

## Color Codes and Messages

### Standard FFXI Colors

| Color  | Code | Usage                      |
| ------ | ---- | -------------------------- |
| Green  | 030  | Success, confirmations     |
| Red    | 167  | Critical errors            |
| Orange | 057  | Warnings, items in storage |
| Yellow | 050  | Important information      |
| Cyan   | 005  | General information        |
| Violet | 205  | Headers, titles            |
| White  | 001  | Normal text                |

### Message Types

```text
[030] Set valid, equipping in progress
[167] Item 'Excalibur' not found in inventory
[057] Item 'Ochain' found in LOCKER - move to inventory
[050] 52 sets detected for validation
[205] === TEST REPORT ===
```

---

Command guide maintained by Tetsouo - Version 2.1.0 - August 2025

## New Commands v2.1.0

### Added Universal Commands

| Command                | Description                 | Function                                |
| ---------------------- | --------------------------- | --------------------------------------- |
| `//gs c info`          | Complete system information | Status, cache, job keybinds             |
| `//gs c validate_all`  | Validation of all sets      | Complete verification without equipping |
| `//gs c missing_items` | List missing items          | Complete inventory analysis             |
| `//gs c current`       | Validates current equipment | Check currently worn gear               |
| `//gs c clear_cache`   | Clears system cache         | Reset cache                             |
| `//gs c cache_stats`   | Cache statistics            | Performance and hit rate                |
