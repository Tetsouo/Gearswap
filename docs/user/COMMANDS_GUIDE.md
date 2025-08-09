# 🎮 Guide Complet des Commandes - GearSwap Tetsouo v2.0

## 📋 Index des Commandes

### 🎯 [Commandes de Test et Validation](#test-validation)

### ⚔️ [Commandes de Combat (F9-F12)](#combat)  

### 🎮 [Commandes par Job](#job-specific)

### 🛠️ [Commandes GearSwap de Base](#gearswap-base)

### 📊 [Commandes de Métriques](#metriques)

### 🔧 [Commandes Avancées](#advanced)

---

## 🎯 Test et Validation {#test-validation}

### Système de Test Automatique v2.0

| Commande | Description | Exemple d'Usage |
|----------|-------------|-----------------|
| `//gs c equiptest start` | Lance le test automatique de TOUS les sets | Tests complets (2min) |
| `//gs c equiptest report` | Affiche le rapport d'erreurs détaillé | Après les tests |
| `//gs c equiptest status` | Vérifie si un test est en cours | Vérifier progression |
| `//gs c equiptest stophook` | Arrête l'analyse en cours | Si blocage |

### Validation Manuelle

| Commande | Description | Usage Recommandé |
|----------|-------------|------------------|
| `//gs c validate_all` | Valide TOUS les sets sans les équiper | Vérification rapide |
| `//gs c validate_set [nom]` | Valide un set spécifique | `//gs c validate_set idle` |
| `//gs c missing_items` | Liste tous les items manquants | Inventaire manquant |
| `//gs c current` | Valide l'équipement actuellement porté | Check équipement actuel |
| `//gs c clear_cache` | Vide le cache de validation | Si problème détection |
| `//gs c cache_stats` | Statistiques du cache (29K items) | Info technique |

### Exemple de Session de Test

```bash
# 1. Lancer les tests automatiques  
//gs c equiptest start
# ... attendre fin des tests (affichage progression) ...

# 2. Voir le rapport détaillé
//gs c equiptest report

# 3. Si des erreurs, voir items manquants
//gs c missing_items

# 4. Valider après corrections
//gs c validate_all
```

### Rapport de Test Détaillé

```text
[205] ============================
[205]   ANALYSE EQUIPEMENT v2.0
[205] ============================
[030] [CACHE] 29263 items indexes  
[030] [OK] Systeme pret
[050] [SYSTEM] Direct analysis mode: ENABLED
[056] [SCAN] 52 sets detected for job: DNC
[050] [QUEUE] 52 sets scheduled for testing
[037] [TIMING] Delay between tests: 2 sec
[205] ============================

# ... progression des tests ...

[205] ============================  
[205]         RAPPORT FINAL
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

## ⚔️ Commandes de Combat {#combat}

### Touches Raccourci (F9-F12)

| Touche | Commande Alternative | Description | Tous Jobs |
|--------|---------------------|-------------|-----------|
| **F9** | `//gs c cycle OffenseMode` | Mode offensif (Normal→Acc→FullAcc) | ✅ |
| **F10** | `//gs c cycle WeaponMode` | Change set d'armes | ✅ |
| **F11** | `//gs c cycle DefenseMode` | Mode défensif (None→PDT→MDT) | ✅ |
| **F12** | `//gs c cycle IdleMode` | Mode idle (Normal→Regen→PDT→MDT) | ✅ |

### Modes de Combat Universels

| Commande | Description | Valeurs Possibles |
|----------|-------------|-------------------|
| `//gs c set OffenseMode [mode]` | Force mode offensif | Normal, Acc, FullAcc |
| `//gs c set DefenseMode [mode]` | Force mode défensif | None, PDT, MDT |
| `//gs c set IdleMode [mode]` | Force mode idle | Normal, Regen, PDT, MDT |
| `//gs c set WeaponMode [mode]` | Force set d'armes | Dépend du job |
| `//gs c toggle Kiting` | Active/désactive mode Kiting | On/Off |

### Exemple d'Usage en Combat

```bash
# Avant combat difficile
F11                              # Active défense PDT
//gs c toggle Kiting             # Active déplacement rapide

# En combat précis
F9                               # Passe en mode Accuracy  

# Après combat  
F11                              # Retour défense None
F12                              # Mode idle approprié
```

---

## 🎮 Commandes par Job {#job-specific}

### 🛡️ Paladin (PLD)

```bash
# Modes spécialisés
//gs c cycle Shield              # Ochain → Aegis → Priwen
//gs c toggle Cover              # Mode Cover on/off
//gs c toggle Sentinel           # Mode Sentinel on/off

# Commandes d'action
//gs c enmity                    # Équipe set full enmity
//gs c reprisal                  # Set Reprisal optimisé
//gs c flash                     # Set Flash enmity
```

### ⚔️ Warrior (WAR)  

```bash
# Modes berserk
//gs c toggle Berserk            # Mode Berserk on/off
//gs c toggle Retaliation        # Mode Retaliation on/off

# Commandes spécialisées  
//gs c warcry                    # Set Warcry optimisé
//gs c provoke                   # Set Provoke enmity
//gs c aggressor                 # Set Aggressor
```

### 🗡️ Thief (THF)

```bash
# Treasure Hunter
//gs c toggle TH                 # TH on/off
//gs c cycle THMode              # Tag → SATA → Fulltime
//gs c set THMode Tag            # Force mode Tag

# Modes spéciaux
//gs c toggle Flee              # Mode Flee on/off
//gs c sneak                     # Set Sneak Attack
//gs c trick                     # Set Trick Attack
```

### 🔥 Black Mage (BLM)

```bash
# Magic Burst
//gs c toggle MagicBurst         # MB on/off
//gs c cycle NukeMode            # Normal → Acc → Burst

# Éléments
//gs c element [elem]            # Force élément (fire/ice/etc)
//gs c cycle Element             # Cycle tous les éléments

# Scholar arts  
//gs c scholar [art]             # Light/Dark arts
//gs c cycle ScholarArts         # Cycle arts
```

### 💃 Dancer (DNC)

```bash
# Actions de danse
//gs c step                      # Équipe set Step optimisé
//gs c flourish                  # Équipe set Flourish  
//gs c waltz                     # Set Waltz optimal

# Modes spéciaux
//gs c toggle Saber              # Saber Dance on/off
//gs c cycle StepMode             # Single → Double → Triple
```

### 🐉 Dragoon (DRG)  

```bash
# Modes jump
//gs c toggle Jump               # Mode Jump on/off
//gs c high_jump                 # Set High Jump

# Wyvern
//gs c angon                     # Set Angon optimisé  
//gs c breath                    # Set Healing Breath
//gs c spirit_link               # Set Spirit Link
```

### 🛡️ Rune Fencer (RUN)

```bash  
# Gestion des runes
//gs c cycle Runes              # Cycle toutes les runes
//gs c rune [element]            # Ignis/Gelus/Flabra/Tellus/etc
//gs c rune ice                  # Force rune Gelus

# Modes ward
//gs c toggle Rayke             # Mode Rayke on/off  
//gs c toggle Gambit            # Mode Gambit on/off
//gs c battuta                  # Set Battuta
```

### 🐺 Beastmaster (BST)

```bash
# Keybinds F1-F7 (optimisés v2.0)
F1                             # AutoPetEngage (On/Off)
F2                             # HybridMode (PDT/Normal)
F3                             # WeaponSet
F4                             # SubSet  
F5                             # Ecosystem (All/Aquan/Beast/etc)
F6                             # Species (All/Tiger/Crab/etc)
F7                             # PetIdleMode (MasterPDT/PetPDT)

# Commandes alternatives
//gs c bst_ecosystem            # Change ecosystem + update pets
//gs c bst_species              # Change species + equip broth  
//gs c display_selection_info   # Affiche sélection actuelle
//gs c display_broth_count      # Compte jugs disponibles

# Actions pet
//gs c reward                   # Set Reward optimisé
//gs c charm                    # Set Charm  
//gs c toggle Killer            # Killer effects on/off
```

---

## 🛠️ Commandes GearSwap de Base {#gearswap-base}

### Commandes Essentielles

| Commande | Description | Usage |
|----------|-------------|-------|
| `//gs load [fichier]` | Charge un fichier job | `//gs load Tetsouo_PLD` |
| `//gs reload` | Recharge le fichier actuel | Après modifications |
| `//gs export` | Exporte vos sets actuels | Sauvegarde |
| `//gs showswaps` | Affiche les changements d'équipement | Debug |
| `//gs debugmode` | Active/désactive le mode debug | Troubleshooting |
| `//gs validate` | Vérifie la syntaxe Lua | Avant reload |

### Commandes d'Équipement

| Commande | Description | Exemple |
|----------|-------------|---------|
| `//gs equip [set]` | Équipe un set manuellement | `//gs equip sets.idle` |
| `//gs equip naked` | Retire tout l'équipement | Reset complet |
| `//gs c safe_equip [set]` | Équipe après validation | Sécurisé |
| `//gs c force_equip [set]` | Force l'équipement | Ignore erreurs |

---

## 📊 Commandes de Métriques {#metriques}

### ⚠️ Système Désactivé par Défaut

**Note :** Les métriques sont désactivées pour éviter tout lag en combat.

| Commande | Description | État |
|----------|-------------|------|
| `//gs c metrics start` | Démarre la collecte de métriques | 🔴 Désactivé |
| `//gs c metrics stop` | Arrête la collecte | 🔴 Désactivé |
| `//gs c metrics show` | Affiche le dashboard | 🔴 Désactivé |
| `//gs c metrics export` | Exporte en JSON | 🔴 Désactivé |
| `//gs c metrics reset` | Réinitialise les métriques | 🔴 Désactivé |
| `//gs c metrics toggle` | Active/désactive | 🔴 Désactivé |
| `//gs c metrics status` | Vérifie l'état | ✅ Disponible |

### Activation des Métriques

Pour activer, modifier `core/metrics_integration.lua` :

```lua
local METRICS_ENABLED = true  -- Changer false → true
```

---

## 🔧 Commandes Avancées {#advanced}

### Debug et Développement  

| Commande | Description | Usage |
|----------|-------------|-------|
| `//gs c debug_equip [set]` | Debug détaillé d'un set | Développeurs |
| `//gs c testcmd` | Liste commandes de test | Debug |
| `//gs c help` | Aide contextuelle | Info générale |
| `//gs c info` | Informations système | Status complet |

### Commandes Système

| Commande | Description | Fonction |
|----------|-------------|----------|
| `//gs c clear_cache` | Vide le cache système | Si lenteur |
| `//gs c rebuild_cache` | Reconstruit le cache | Après update |
| `//gs c memory_usage` | Usage mémoire détaillé | Monitoring |
| `//gs c performance` | Stats de performance | Diagnostic |

---

## 💡 Workflows Recommandés

### 🌅 Workflow Quotidien

```bash
# 1. Au login
//gs reload
//gs c equiptest start

# 2. Après modifications de sets  
//gs reload
//gs c validate_all

# 3. Si erreurs détectées
//gs c equiptest report
//gs c missing_items

# 4. Debug si nécessaire
//gs debugmode
//gs showswaps
```

### 🔧 Workflow de Debug

```bash  
# 1. Activer debug complet
//gs debugmode
//gs showswaps

# 2. Test spécifique
//gs c debug_equip [nom_set]
//gs c validate_set [nom_set]

# 3. Cache et performance
//gs c clear_cache
//gs c info

# 4. Désactiver debug
//gs debugmode
```

### ⚡ Raccourcis Professionnels

```bash
# Macros recommandées
Alt+R = //gs reload
Alt+T = //gs c equiptest start  
Alt+V = //gs c validate_all
Alt+E = //gs c equiptest report
Alt+I = //gs c info
Alt+H = //gs c help
```

---

## 🎯 Codes de Couleur et Messages

### Couleurs FFXI Standards

| Couleur | Code | Utilisation |
|---------|------|-------------|
| 🟢 Vert | 030 | Succès, confirmations |
| 🔴 Rouge | 167 | Erreurs critiques |
| 🟠 Orange | 057 | Warnings, items en storage |
| 🟡 Jaune | 050 | Informations importantes |  
| 🔵 Cyan | 005 | Informations générales |
| 🟣 Violet | 205 | Headers, titres |
| ⚪ Blanc | 001 | Texte normal |

### Messages Types

```text
[030] ✓ Set valide, équipement en cours
[167] ✗ Item 'Excalibur' non trouvé dans l'inventaire
[057] ⚠ Item 'Ochain' trouvé en LOCKER - déplacer vers inventory
[050] ℹ 52 sets détectés pour validation
[205] === RAPPORT DE TEST AUTOMATIQUE ===
```

---

Guide des commandes maintenu par Tetsouo - Version 2.0 - Août 2025

## 🆕 Nouvelles Commandes v2.0

### Commandes Universelles Ajoutées

| Commande | Description | Fonction |
|----------|-------------|----------|
| `//gs c info` | Informations système complètes | Status, cache, keybinds job |
| `//gs c validate_all` | Validation de tous les sets | Vérification complète sans équiper |
| `//gs c missing_items` | Liste items manquants | Analyse inventaire complet |
| `//gs c current` | Valide équipement actuel | Check gear actuellement porté |
| `//gs c clear_cache` | Vide le cache système | Reset cache 29K items |
| `//gs c cache_stats` | Statistiques du cache | Performance et hit rate |

### BST Keybinds Réorganisés (F9 → F1)

| Ancienne Touche | Nouvelle Touche | Commande |
|-----------------|-----------------|-----------|
| F9 | **F1** | AutoPetEngage |
| - | **F5** | bst_ecosystem |
| - | **F6** | bst_species |
