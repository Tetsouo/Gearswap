# 📖 Guide Utilisateur - GearSwap Tetsouo v2.0

## 🚀 Installation et Démarrage Rapide

### 1️⃣ **Première Utilisation**

```lua
-- Charger GearSwap dans le jeu
//lua load gearswap

-- Le système se configure automatiquement
-- Tous les jobs sont prêts à l'utilisation
```

### 2️⃣ **Configuration Personnalisée**

Modifier le fichier `config/settings.lua` pour adapter le système :

```lua
-- Exemple de personnalisation
{
    players = {
        main = "VotreNom",      -- Changez ici
        alt = "VotreAlt"        -- Changez ici  
    },
    debug = {
        enabled = false,         -- true pour voir les logs
        level = "INFO"          -- ERROR, WARN, INFO, DEBUG
    }
}
```

---

## 🎮 Jobs Supportés et Commandes

### **8 Jobs Complètement Supportés**

| Job | Touches | Commandes Chat | Spécialités |
|-----|---------|----------------|-------------|
| **BLM** | F9: Casting Mode | `//gs c cycle CastingMode` | Magic Burst, Elements |
| **BST** | F5: Ecosystem, F6: Species | `//gs c bst_ecosystem` | Pet Management |
| **DNC** | Standards GS | `//gs c cycle WeaponSet` | Flourish, Steps |
| **DRG** | F9-F11: Modes | `//gs c cycle HybridMode` | Wyvern Support |
| **PLD** | F9-F11: Modes | `//gs c cycle HybridMode` | Tank Modes |
| **RUN** | F2-F4: Modes | `//gs c cycle HybridMode` | Rune Elements |
| **THF** | Standards GS | `//gs c cycle TreasureMode` | SA/TA, TH |
| **WAR** | F5-F6: Modes | `//gs c cycle HybridMode` | Retaliation Auto |

---

## ⚙️ Système de Configuration

### **Configuration Centralisée**

Tous les paramètres sont dans `config/settings.lua`:

```lua
-- Paramètres globaux
players = { main = "Tetsouo", alt = "Kaories" }

-- Paramètres de debug
debug = { enabled = false, level = "INFO" }

-- Paramètres de mouvement
movement = { 
    threshold = 1.0,        -- Seuil de détection mouvement
    check_interval = 15     -- Interval de vérification
}

-- Paramètres par job
job_settings = {
    BST = {
        default_ecosystem = "Beast",
        auto_pet_engage = true
    },
    THF = {
        sa_ta_priority = true,
        th_fulltime = false
    }
}
```

### **Messages Colorés Configurables**

```lua
colors = {
    debug = 160,    -- Gris
    info = 050,     -- Jaune  
    warning = 057,  -- Orange
    error = 028     -- Rouge
}
```

---

## 🔧 Fonctionnalités Avancées

### **1. Système de Logging**

```lua
-- Activer le debug dans config/settings.lua
debug = { enabled = true, level = "DEBUG" }

-- Messages colorés automatiques dans le chat
-- [DEBUG] Message en gris
-- [INFO] Message en jaune
-- [WARN] Message en orange  
-- [ERROR] Message en rouge
```

### **2. Configuration par Job**

Chaque job peut avoir ses paramètres spécifiques :

```lua
-- Dans config/settings.lua
job_settings = {
    BST = {
        default_ecosystem = "Beast",
        species_filter = true,
        auto_broth = true
    },
    WAR = {
        auto_retaliation_cancel = true,
        movement_threshold = 1.5
    }
}
```

### **3. Dual-Boxing Intégré**

```lua
-- Configuration automatique pour 2 comptes
players = {
    main = "Tetsouo",   -- Compte principal
    alt = "Kaories"     -- Compte alternatif
}

-- Commandes dual-box disponibles :
// Géomancien alternatif
state.altPlayerGeo:cycle()   
state.altPlayerIndi:cycle()
```

---

## 🎯 Utilisation Par Job

### **🔥 Black Mage (BLM)**

```lua
-- Touches disponibles
F9 : Cycle Casting Mode (Normal ⇆ Magic Burst)

-- États configurables
state.CastingMode     -- Normal, MagicBurst
state.MainLightSpell  -- Fire, Thunder, Aero
state.TierSpell      -- VI, V, IV, III, II
```

### **🐾 Beastmaster (BST)**

```lua
-- Touches disponibles  
F5 : Change Ecosystem (Aquan, Beast, Bird, etc.)
F6 : Change Species (filtrée par ecosystem)
F7 : Pet Idle Mode
F9 : Auto Pet Engage

-- Système unifié ecosystem/species
-- F5 change l'écosystème et met à jour la liste des espèces
// F6 change l'espèce et équipe automatiquement la broth
```

### **🗡️ Thief (THF)**

```lua
-- Spécialités  
- SA/TA gear automatique
- TH (Treasure Hunter) intelligent
- Mouvement préserve SA/TA
- TH + SA/TA combinés pour premier hit

-- Modes disponibles
state.TreasureMode    -- None, Tag, SATA, Fulltime
state.WeaponSet      -- Vajra, Malevolence, Dagger
```

### **⚔️ Warrior (WAR)**

```lua
-- Fonctionnalités spéciales
- Annulation automatique Retaliation sur mouvement long
- TP-based Weapon Skill gear
- Support armes multiples

-- États configurables
state.HybridMode     -- PDT, Normal
state.WeaponSet     -- Ukonvasara, Chango, Shining
```

---

## 🚨 Résolution de Problèmes

### **Problèmes Courants**

#### **"Module not found"**

```lua
-- Solution: Vérifier que tous les fichiers sont présents
// Recharger GearSwap
//gs reload
```

#### **"Lockstyle ne fonctionne pas"**

```lua  
-- Délai insuffisant - automatiquement géré par le système
-- Les macros utilisent wait 20 pour éviter la perte
```

#### **"Configuration non chargée"**

```lua
-- Vérifier config/settings.lua
-- Syntaxe Lua correcte requise
// Tester le chargement:
//lua load test_modules
```

#### **"Erreurs de debug trop nombreuses"**

```lua
-- Dans config/settings.lua :
debug = { enabled = false }  -- Désactiver debug

-- Ou changer le niveau :
debug = { level = "ERROR" }  -- Seulement erreurs critiques
```

---

## 🔄 Mise à Jour et Maintenance

### **Ajouter un Nouveau Job**

1. Créer `jobs/XXX/XXX_SET.lua` (sets d'équipement)
2. Créer `jobs/XXX/XXX_FUNCTION.lua` (logique job)
3. Créer `Tetsouo_XXX.lua` (fichier principal)
4. Ajouter configuration dans `config/settings.lua`

### **Modifier la Configuration**

```lua
-- Modifier config/settings.lua
-- Recharger GearSwap: //gs reload
// Les changements sont appliqués immédiatement
```

### **Backup Automatique**

Le système maintient des backups dans `backups/` :

- `Tetsouo_*.lua.bak` - Fichiers principaux
- `SharedFunctions.lua.bak` - Ancien système

---

## 📚 Ressources et Support

### **Fichiers de Référence**

- `CLAUDE.md` - Documentation technique complète
- `config/settings.lua` - Tous les paramètres configurables
- `test_modules.lua` - Tests de validation
- `Docs/ARCHITECTURE_OVERVIEW.md` - Architecture système

### **Structure des Commandes**

```lua
// Commandes générales GearSwap
//gs reload              -- Recharger le système
//gs c cycle [mode]      -- Cycler un mode
//gs equip [set]         -- Équiper un set

// Commandes spécifiques jobs
//gs c bst_ecosystem     -- BST: Changer ecosystem  
//gs c bst_species       -- BST: Changer species
```

### **Logs et Debug**

```lua
// Activer debug temporairement
//lua req('utils/logger').set_level('DEBUG')

// Messages de test
//lua req('utils/logger').info('Test du système')
```

---

## 🎉 Fonctionnalités Bonus

### **Messages Colorés Intelligents**

- 🔵 **Bleu** : Changements d'état (Ecosystem changed to Beast)
- 🟡 **Jaune** : Informations (Equipment equipped)  
- 🟠 **Orange** : Avertissements (Invalid configuration)
- 🔴 **Rouge** : Erreurs (Module failed to load)

### **Performance Optimisée**

- Chargement lazy des modules
- Cache des configurations
- Validation automatique des paramètres
- Gestion d'erreurs robuste

### **Extensibilité Totale**

- Ajout facile de nouveaux jobs
- Système de plugins modulaire
- Configuration centralisée
- Backward compatibility garantie

---

*Guide utilisateur GearSwap Tetsouo v2.0 - Système professionnel pour FFXI*  
*Dernière mise à jour: 2025-08-05*
