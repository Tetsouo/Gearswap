# Configuration Guide - GearSwap Tetsouo v2.1.0

## Centralized Configuration System

**Single file configuration for all settings!**

## Main Configuration Files

**Primary configuration files:**

- `config/SETTINGS.lua` - Main system settings
- `config/CONFIG.lua` - Core configuration parameters

**Current Architecture:** 94 Lua files, 36,674 lines of code

## Player Configuration

```lua
settings.players = {
    -- Main character name
    main = 'Tetsouo',

    -- Alt character name for dual-boxing
    alt = 'Kaories',

    -- Enable dual-boxing features
    dual_box_enabled = true,
}
```

## Macro Book Configuration

### Lockstyles by Job (All 9 Jobs Supported)

```lua
settings.macros.lockstyles = {
    THF = 1,
    DNC = 2,
    WAR = 5,
    PLD = 4,
    BLM = 5,
    BRD = 6,
    BST = 7,
    DRG = 8,
    RUN = 9,
}
```

### Dual-Box Macros (Main + Alt Job)

**Complete dual-boxing system with character coordination:**

```lua
settings.macros.dual_box = {
    THF = {
        RDM = { book = 1, page = 1 },
        GEO = { book = 2, page = 1 },
        COR = { book = 3, page = 1 },
        PLD = { book = 5, page = 1 },
    },
    -- Ajoutez d'autres jobs...
}
```

### Solo Macros (Main Job + Subjob)

**Solo play configurations for single character:**

```lua
settings.macros.solo = {
    THF = {
        WAR = { book = 1, page = 1 },
        DNC = { book = 1, page = 1 },
        NIN = { book = 1, page = 1 },
        RDM = { book = 1, page = 2 },
    },
    -- Ajoutez d'autres jobs...
}
```

## How to Modify Configurations

### 1. Change Player Names

- Edit `settings.players.main` with your main character name
- Edit `settings.players.alt` with your alt character name
- Set `settings.players.dual_box_enabled = true/false`

### 2. Change Macro Books

- **Dual-boxing:** Edit `settings.macros.dual_box[YOUR_JOB][ALT_JOB]`
- **Solo:** Edit `settings.macros.solo[YOUR_JOB][SUBJOB]`
- **New jobs:** Add BRD configurations as needed

### 3. Change Lockstyles

- Edit `settings.macros.lockstyles[JOB] = SET_NUMBER`
- **All 9 jobs supported:** WAR, BLM, THF, PLD, BST, DNC, DRG, RUN, BRD

## Practical Examples

### Example 1: Add new dual-box combination

```lua
-- Add BRD + WHM -> Macro Book 7
settings.macros.dual_box.BRD.WHM = { book = 7, page = 1 }
```

### Example 2: Change WAR lockstyle

```lua
-- Change WAR lockstyle from 5 to 3
settings.macros.lockstyles.WAR = 3
```

### Example 3: Configure BRD (New in v2.1.0)

```lua
-- BRD professional song system configuration
settings.macros.lockstyles.BRD = 6
settings.macros.solo.BRD = {
    WHM = { book = 1, page = 1 },
    RDM = { book = 1, page = 2 },
}
```

### Exemple 3 : Ajouter un nouveau subjob pour DNC

```lua
-- Ajouter DNC/RDM -> Macro Book 1, Page 10
settings.macros.solo.DNC.RDM = { book = 1, page = 10 }
```

## 🔄 Appliquer les Changements

Après avoir modifié `config/settings.lua` :

1. **Rechargez GearSwap :** `//gs reload`
2. **Ou changez de job :** `//job change [job]`

## ✅ Avantages de ce Système

- **Un seul fichier** à éditer pour tout configurer
- **Pas besoin** de modifier les fichiers de jobs individuels
- **Configuration centralisée** pour tous les personnages
- **Facile à sauvegarder** et partager
- **Moins d'erreurs** de configuration

## 🆘 En Cas de Problème

Si quelque chose ne fonctionne pas :

1. Vérifiez la syntaxe Lua dans `config/settings.lua`
2. Utilisez `//gs reload` pour recharger
3. Vérifiez les messages d'erreur dans la console Windower

## 📋 Liste des Jobs Supportés

- **THF** (Thief)
- **DNC** (Dancer)
- **WAR** (Warrior)
- **PLD** (Paladin)
- **BLM** (Black Mage)
- **BRD** (Bard)
- **BST** (Beastmaster)
- **DRG** (Dragoon)
- **RUN** (Rune Fencer)

---

**Note :** Plus besoin d'éditer les fichiers `Tetsouo_[JOB].lua` ou `core/macro_manager_simple.lua` !
Tout se configure maintenant dans `config/settings.lua` ! 🎉
