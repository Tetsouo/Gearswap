# 🎨 Guide des Messages et Couleurs - GearSwap Tetsouo

## 🎯 Guide d'Usage des Wrappers

### Architecture du Système

Le système de messages et couleurs de GearSwap Tetsouo utilise une architecture à double wrapper pour garantir la cohérence visuelle et la maintenabilité.

```text
📁 assets/ffxi_colors.json  ←── Source de vérité des couleurs FFXI
    ↓
📁 utils/colors.lua         ←── Wrapper standardisé  
📁 utils/messages.lua       ←── Wrapper universel
    ↓
📁 jobs/*/                  ←── Utilisation dans les jobs
```

---

## 🌈 Système de Couleurs Centralisé

### Fichier Source : `assets/ffxi_colors.json`

#### Couleurs Principales Disponibles

| Code  | Nom             | Hex     | Usage Recommandé      |
| ----- | --------------- | ------- | --------------------- |
| `001` | Blanc           | #ffffff | Information générale  |
| `005` | Cyan Brillant   | #63ffff | Magie/sorts           |
| `030` | Vert Brillant   | #25ff59 | Succès                |
| `050` | Jaune Brillant  | #ffff77 | Job Abilities         |
| `057` | Orange Brillant | #ff7f5a | Avertissements        |
| `160` | Gris-Violet     | #9d9cd2 | Texte secondaire      |
| `167` | Rouge-Rose      | #ff6096 | Erreurs/Weapon Skills |
| `207` | Bleu Clair      | #99b5ff | Information bleue     |

#### Mapping par Type d'Action

```json
"action_types": {
  "magic": {"suggested_colors": ["005", "056", "006"]},
  "weaponskill": {"suggested_colors": ["167", "028"]},
  "jobability": {"suggested_colors": ["050", "057"]},
  "success": {"suggested_colors": ["030"]},
  "error": {"suggested_colors": ["167", "028"]},
  "warning": {"suggested_colors": ["057"]},
  "info": {"suggested_colors": ["001", "037", "166"]}
}
```

---

## 🛠️ Wrappers Disponibles

### 1. `utils/colors.lua` - Système Standardisé

#### Palette Principale

```lua
Colors.PALETTE = {
    SUCCESS = 030,    -- Vert (succès)
    ERROR = 167,      -- Rouge-rose (erreurs) 
    WARNING = 057,    -- Orange (avertissements)
    INFO = 050,       -- Jaune (information)
    HEADER = 160,     -- Gris-violet (headers)
    HIGHLIGHT = 005,  -- Cyan (highlight)
}
```

#### Fonctions d'Affichage

```lua
-- Headers standardisés
Colors.show_header("TITRE")
Colors.show_footer()

-- Messages de status
Colors.show_status("Message", "success")  -- ou "error", "warning"

-- Entrées de données
Colors.show_entry("Label", "Valeur")
Colors.show_category("Catégorie")

-- Couleurs dynamiques
local color = Colors.get_performance_color(85)  -- Basé sur %
local color = Colors.get_time_color(12)         -- Basé sur temps ms
```

### 2. `utils/messages.lua` - Système Universel

#### Couleurs Standardisées

```lua
MessageUtils.STANDARD_COLORS = {
    MAGIC = 005,         -- Cyan (sorts)
    ABILITY = 050,       -- Jaune (job abilities)
    WEAPONSKILL = 167,   -- Rouge-rose (weapon skills)
    SUCCESS = 030,       -- Vert (succès)
    ERROR = 167,         -- Rouge (erreurs)
    WARNING = 057,       -- Orange (avertissements)
}
```

#### Fonction Universelle

```lua
MessageUtils.universal_message(job, action_type, message, details, status, time_value, force_color)
```

**Paramètres :**

- `job` : "WAR", "BLM", etc.
- `action_type` : "Magic", "Ability", "WeaponSkill", "Status"
- `message` : Message principal
- `details` : Détails optionnels
- `status` : "Active", "Recast", "Ready"
- `time_value` : Temps en secondes
- `force_color` : Code couleur forcé

---

## 📋 Fonctions Spécialisées par Job

### Messages BLM

```lua
local MessageUtils = require('utils/messages')

-- Messages de synchronisation
MessageUtils.blm_sync_message('light', 'Fire')
MessageUtils.blm_sync_message('dark', 'Stone')

-- Messages de cast alternatif
MessageUtils.blm_alt_cast_message('cast_light', 'Fire', 'VI')
MessageUtils.blm_alt_cast_message('error_light')
```

### Messages BST

```lua
-- Erreur de resources
MessageUtils.bst_resource_error_message()

-- Messages de cooldown
MessageUtils.bst_cooldown_message('Reward', 45)
```

### Messages BRD

```lua
-- Messages génériques BRD
MessageUtils.brd_message("Setting", "Song Type", "March")
MessageUtils.brd_message("Weapon", "Main Weapon", "Carnwenhan")
```

### Messages Système (Tous Jobs)

```lua
-- Actions système
MessageUtils.system_action_message('Starting equipment test...')

-- Statistiques
MessageUtils.system_stats_message('Cache Statistics', {
    items = 29000,
    hit_rate = "99.8%"
})
```

---

## 🚫 Règles de Conformité

### ✅ À FAIRE

1. **Toujours utiliser les wrappers**

   ```lua
   local MessageUtils = require('utils/messages')
   MessageUtils.system_action_message('Mon message')
   ```

2. **Référencer les couleurs par leur nom JSON**

   ```lua
   -- Bon
   local Colors = require('utils/colors')
   windower.add_to_chat(Colors.PALETTE.SUCCESS, message)
   ```

3. **Utiliser les fonctions spécialisées**

   ```lua
   -- Pour BLM
   MessageUtils.blm_sync_message('light', newValue)
   
   -- Pour BST  
   MessageUtils.bst_cooldown_message(spell.name, recast)
   ```

### ❌ À ÉVITER

1. **Usage direct d'add_to_chat avec couleurs codées**

   ```lua
   -- Éviter
   windower.add_to_chat(167, "Message d'erreur")
   
   -- Préférer
   Colors.show_status("Message d'erreur", "error")
   ```

2. **Couleurs "magiques" codées en dur**

   ```lua
   -- Éviter
   add_to_chat(050, msg)  -- Que signifie 050 ?
   
   -- Préférer  
   MessageUtils.system_action_message(msg)  -- Couleur automatique
   ```

---

## 🔧 Exemples d'Implémentation

### Exemple Job Complet

```lua
-- Dans Tetsouo_XXX.lua
function self_command(command)
    local MessageUtils = require('utils/messages')
    
    if command == 'test' then
        -- Message d'action système
        MessageUtils.system_action_message('Executing GearSwap module tests...')
        
        -- Simulation de statistiques
        local stats = {
            modules_loaded = 12,
            cache_size = "29,000+",
            hit_rate = "99.8%"
        }
        MessageUtils.system_stats_message('Test Results', stats)
        
    elseif command:startswith('altlight') then
        -- Message spécialisé BLM
        if job == 'BLM' then
            MessageUtils.blm_alt_cast_message('cast_light', 'Fire', 'VI')
        end
        
    end
end
```

### Exemple Module Système

```lua
-- Dans core/xxxx.lua
function show_equipment_report()
    local Colors = require('utils/colors')
    
    -- Header standardisé
    Colors.show_header("EQUIPMENT REPORT")
    
    -- Catégories
    Colors.show_category("Missing Items")
    Colors.show_entry("Head", "Adhemar Bonnet +1", Colors.PALETTE.ERROR)
    Colors.show_entry("Body", "Adhemar Jacket +1", Colors.PALETTE.SUCCESS)
    
    -- Status final
    Colors.show_status("Report completed successfully", "success")
    Colors.show_footer()
end
```

---

## 📊 Conformité et Validation

### Auto-Audit

Pour vérifier la conformité de votre code :

1. **Rechercher les usages directs**

   ```bash
   grep -r "windower\.add_to_chat" jobs/
   grep -r "add_to_chat([0-9]" jobs/
   ```

2. **Vérifier les imports**

   ```bash
   grep -r "require.*messages" jobs/
   grep -r "MessageUtils\." jobs/
   ```

### Standards de Qualité

- ✅ 0 usage direct d'`add_to_chat` dans les jobs
- ✅ 0 couleur codée en dur (valeurs numériques)
- ✅ Utilisation systématique des wrappers
- ✅ Fonctions spécialisées pour chaque job
- ✅ Cohérence avec `assets/ffxi_colors.json`

---

## 🎯 Conclusion

Le système de messages et couleurs de GearSwap Tetsouo garantit :

- **Cohérence Visuelle** : Couleurs FFXI officielles
- **Maintenabilité** : Centralisation des couleurs
- **Facilité d'Usage** : Wrappers spécialisés
- **Qualité Professionnelle** : 95% de conformité

### Pour Nouveaux Jobs

1. Importer le wrapper : `local MessageUtils = require('utils/messages')`
2. Utiliser les fonctions spécialisées existantes
3. Créer de nouvelles fonctions spécialisées si nécessaire
4. Respecter la palette de couleurs centralisée

---

*Guide créé pour GearSwap Tetsouo v2.0.0*  
*Basé sur le rapport de conformité du 2025-08-18*
