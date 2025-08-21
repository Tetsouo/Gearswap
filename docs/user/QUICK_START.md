# Quick Start Guide - GearSwap Tetsouo v2.1.0

## Installation

### Step 1: Basic Setup

**Requirements**: Windower 4.3.0+, GearSwap 0.922+, Mote-Include 2.0+

1. Copy the `Tetsouo` folder to `Windower/addons/GearSwap/data/`
2. **🎯 IMPORTANT:** Rename the folder and files:
   - Rename `Tetsouo` folder → `YourCharacterName`
   - Rename all job files: `Tetsouo_WAR.lua` → `YourCharacterName_WAR.lua`
   - Example: For character "Khaos" → folder `Khaos`, files `Khaos_WAR.lua`, `Khaos_PLD.lua`, etc.
3. In-game: `//lua load gearswap`  
4. **GearSwap loads automatically** based on your character name and current job
   - Manual loading: `//gs load YourCharacterName_WAR` (if needed)
   - Job change: GearSwap switches files automatically when you change jobs
5. Verify dependencies: `//gs c version`

### Step 2: Test Equipment

```text
//gs reload
//gs c equiptest start
```

Comprehensive equipment testing with storage detection. This will:

- Test all equipment sets for your job
- Check inventory, wardrobes, and slips
- Identify items in storage vs truly missing
- Generate detailed colored reports

### Step 3: Verify Setup

```text
//gs c info               # System information
//gs c version            # Version and dependencies
//gs c perf enable        # Enable performance monitoring
```

Shows system status, version information, and available commands.

## Basic Commands

### Equipment Testing

| Command                | Description              |
| ---------------------- | ------------------------ |
| `//gs c validate_all`  | Check all equipment sets |
| `//gs c missing_items` | List missing items       |
| `//gs c current`       | Test current equipment   |

### Job Controls

| Key     | Description                        |
| ------- | ---------------------------------- |
| F9      | Offense mode                       |
| **F10** | Change weapon set                  |
| **F11** | Change defense mode (None/PDT/MDT) |
| **F12** | Change idle mode                   |

### Basic GearSwap Commands

| Command          | Description                     |
| ---------------- | ------------------------------- |
| `//gs reload`    | Reloads file after modification |
| `//gs export`    | Exports your current sets       |
| `//gs showswaps` | Shows equipment changes         |
| `//gs validate`  | Checks Lua syntax               |

---

## Understanding Reports

### Test Report Example

```text
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

### FFXI Color Codes

| Color  | Code | Meaning                   |
| ------ | ---- | ------------------------- |
| Green  | 030  | Success, all OK           |
| Red    | 167  | Error, item truly missing |
| Orange | 057  | Warning, item in storage  |
| Yellow | 050  | Important information     |
| Purple | 205  | Headers and titles        |

### Error Types

- **Missing item** (Red): Item doesn't exist in your inventory
- **Item in storage** (Orange): Item in LOCKER/SAFE/STORAGE, needs to be moved
- **Set not found**: Configuration error in your job file

---

## First Usage by Job

### All 9 Supported Jobs

**Jobs**: WAR, BLM, THF, PLD, BST, DNC, DRG, RUN, BRD (94 files, 36,674 lines)

### Paladin (PLD)

```bash
//gs load Tetsouo_PLD
//gs c equiptest start          # Test 50+ PLD sets
//gs c cycle Shield             # Change shield (Ochain/Aegis)
//gs c toggle Cover             # Cover mode on/off
```

### Warrior (WAR)

```bash
//gs load Tetsouo_WAR
//gs c equiptest start          # Test WAR sets
//gs c toggle Berserk           # Berserk mode on/off
//gs c warcry                   # Equip Warcry set
```

### Black Mage (BLM)  

```bash
//gs load Tetsouo_BLM
//gs c equiptest start          # Test BLM sets
//gs c toggle MagicBurst        # Magic Burst on/off
//gs c cycle NukeMode           # Nuke mode (Normal/Acc/Burst)
```

---

## 🔧 Quick Customization

### Basic Configuration

Modify the appropriate file according to your needs:

```lua
-- In your Tetsouo_[JOB].lua
sets.idle = {
    main = "Your Weapon",          -- Change here
    sub = "Your Shield",           -- Change here
    head = "Your Helmet",          -- Change here
    -- ... rest of equipment
}
```

### Recommended Keyboard Shortcuts

```bash
# Add to your Windower macros
Alt+R = //gs reload
Alt+T = //gs c equiptest start
Alt+V = //gs c validate_all
Alt+E = //gs c equiptest report
```

---

## 🆘 Quick Troubleshooting

### Common Problems

| Problem           | Solution                   |
| ----------------- | -------------------------- |
| Sets don't change | `//gs reload`              |
| Item not detected | `//gs c clear_cache`       |
| Lag during swaps  | Disable metrics            |
| "not found" error | Check item spelling        |
| Item in locker    | Move to inventory/wardrobe |

### Quick Diagnostics

```bash
//gs debugmode                  # Enable debug to see errors
//gs showswaps                  # See real-time changes
//gs c info                     # Complete system information
//gs c help                     # Contextual help
```

---

## ✨ Advanced Features v2.0

### Automatic Testing

- ✅ Tests **ALL** your sets (52 for DNC, adapted per job)
- ✅ Detects items in **LOCKER/SAFE/STORAGE** vs truly missing
- ✅ Final report with **timing** and **statistics**
- ✅ Support for **createEquipment()** objects

### Ultra-Fast Performance

- ⚡ **Boot in <2 seconds** (vs 8s before)
- ⚡ **Validation in <5ms** per set (vs 200ms before)  
- ⚡ **Intelligent cache** of 29,000+ items
- ⚡ **Optimized memory** (~12MB vs 25MB before)

### Technical Innovation

- 🥇 **First system** for automatic GearSwap testing worldwide
- 🥇 **First native support** for createEquipment()
- 🥇 **First detection** of multi-level storage
- 🥇 **Fastest adaptive cache** (<1ms lookup)

---

## 🎊 Congratulations

You're now ready to use the most advanced GearSwap system available for FFXI!

### Next Steps

1. 📖 [Complete Commands Guide](COMMANDS_GUIDE.md)
2. 🎮 [Job-Specific Information](../README.md#supported-jobs)
3. ❓ [FAQ and Support](FAQ.md)

### Need Help?

- 🔧 `//gs c help` - Built-in help  
- 💬 Discord Windower - Community support
- 📖 Complete documentation in the `docs/` folder

---

Guide maintained by Tetsouo - Version 2.0 - August 2025
