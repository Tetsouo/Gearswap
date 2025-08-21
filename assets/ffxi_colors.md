# FFXI/Windower Color Codes Reference

## 📋 Description

This file references the valid color codes for `windower.add_to_chat()` in FFXI/Windower.

## 🎨 Available Color Codes

### Base Colors

| Code  | Name         | Description     | Recommended Usage                 |
| ----- | ------------ | --------------- | --------------------------------- |
| `001` | White        | Standard white  | Neutral text, general information |
| `028` | Dark red     | Dark red        | Critical errors                   |
| `050` | Yellow-green | Greenish yellow | Information, debug                |
| `057` | Orange       | Standard orange | Warnings                          |
| `086` | Pale green   | Light green     | System status OK                  |
| `158` | Bright green | Brilliant green | Success, excellent                |
| `159` | Bright cyan  | Brilliant cyan  | Titles, headers                   |
| `160` | Gray         | Standard gray   | Secondary text                    |
| `167` | Red          | Standard red    | Errors, failures                  |
| `204` | Red-violet   | Purple red      | Severe errors                     |

## 🎯 Colors by Action Type

### ✨ Magic (Spells)

- **Recommended**: `159` (Bright cyan) or `050` (Yellow-green)
- **Usage**: Spells, magic, enchantments

### ⚔️ Weapon Skills

- **Recommended**: `167` (Red) or `028` (Dark red)
- **Usage**: Weapon techniques, special attacks

### 🎯 Job Abilities  

- **Recommended**: `057` (Orange) or `050` (Yellow-green)
- **Usage**: Job abilities, special abilities

### ⚙️ Equipment

- **Recommended**: `160` (Gray) or `001` (White)
- **Usage**: Equipment changes, swaps

## 📊 Performance Scale

| Performance         | Code  | Color        | Usage                   |
| ------------------- | ----- | ------------ | ----------------------- |
| Excellent (95-100%) | `158` | Bright green | Perfect performance     |
| Good (80-94%)       | `086` | Pale green   | Good performance        |
| Average (60-79%)    | `050` | Yellow-green | Acceptable performance  |
| Poor (40-59%)       | `057` | Orange       | Mediocre performance    |
| Bad (<40%)          | `167` | Red          | Problematic performance |

## 🖥️ System Colors

| Type           | Code  | Color      | Threshold |
| -------------- | ----- | ---------- | --------- |
| Memory OK      | `086` | Pale green | ≤ 2MB     |
| Memory Warning | `057` | Orange     | 2-4MB     |
| Memory Problem | `167` | Red        | > 4MB     |
| Cache Good     | `086` | Pale green | ≥ 80%     |
| Cache Average  | `057` | Orange     | 50-79%    |
| Cache Poor     | `167` | Red        | < 50%     |

## 💡 Usage Notes

1. **Testing required**: Not all codes work on all versions of FFXI/Windower
2. **Consistency**: Use the same colors for the same types of actions
3. **Readability**: Avoid colors that are too dark or too light
4. **Context**: Adapt colors according to message importance

## 🔄 Updates

Last updated: 2025-08-07
Source: Codes observed in existing GearSwap system

---

*This file should be updated with exact color codes from `assets/color.png` once analyzed.*
