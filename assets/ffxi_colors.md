# FFXI/Windower Color Codes Reference

## 📋 Description

Ce fichier référence les codes couleur valides pour `windower.add_to_chat()` dans FFXI/Windower.

## 🎨 Codes Couleur Disponibles

### Couleurs de Base

| Code | Nom | Description | Usage Recommandé |
|------|-----|-------------|------------------|
| `001` | Blanc | Blanc standard | Texte neutre, informations générales |
| `028` | Rouge foncé | Rouge sombre | Erreurs critiques |
| `050` | Jaune-vert | Jaune verdâtre | Informations, debug |
| `057` | Orange | Orange standard | Avertissements |
| `086` | Vert pâle | Vert clair | Statut système OK |
| `158` | Vert brillant | Vert éclatant | Succès, excellent |
| `159` | Cyan brillant | Cyan éclatant | Titres, en-têtes |
| `160` | Gris | Gris standard | Texte secondaire |
| `167` | Rouge | Rouge standard | Erreurs, échecs |
| `204` | Rouge-violet | Rouge pourpre | Erreurs graves |

## 🎯 Couleurs par Type d'Action

### ✨ Magie (Sorts)

- **Recommandé**: `159` (Cyan brillant) ou `050` (Jaune-vert)
- **Usage**: Sorts, magie, enchantements

### ⚔️ Weapon Skills

- **Recommandé**: `167` (Rouge) ou `028` (Rouge foncé)
- **Usage**: Techniques d'armes, attaques spéciales

### 🎯 Job Abilities  

- **Recommandé**: `057` (Orange) ou `050` (Jaune-vert)
- **Usage**: Capacités de job, abilities

### ⚙️ Équipement

- **Recommandé**: `160` (Gris) ou `001` (Blanc)
- **Usage**: Changements d'équipement, swaps

## 📊 Échelle de Performance

| Performance | Code | Couleur | Usage |
|-------------|------|---------|--------|
| Excellent (95-100%) | `158` | Vert brillant | Performances parfaites |
| Bon (80-94%) | `086` | Vert pâle | Bonnes performances |
| Moyen (60-79%) | `050` | Jaune-vert | Performances acceptables |
| Faible (40-59%) | `057` | Orange | Performances médiocres |
| Mauvais (<40%) | `167` | Rouge | Performances problématiques |

## 🖥️ Couleurs Système

| Type | Code | Couleur | Seuil |
|------|------|---------|-------|
| Mémoire OK | `086` | Vert pâle | ≤ 2MB |
| Mémoire Attention | `057` | Orange | 2-4MB |
| Mémoire Problème | `167` | Rouge | > 4MB |
| Cache Bon | `086` | Vert pâle | ≥ 80% |
| Cache Moyen | `057` | Orange | 50-79% |
| Cache Mauvais | `167` | Rouge | < 50% |

## 💡 Notes d'Usage

1. **Tests requis**: Tous les codes ne fonctionnent pas sur toutes les versions de FFXI/Windower
2. **Cohérence**: Utiliser les mêmes couleurs pour les mêmes types d'actions
3. **Lisibilité**: Éviter les couleurs trop sombres ou trop claires
4. **Contexte**: Adapter les couleurs selon l'importance du message

## 🔄 Mise à Jour

Dernière mise à jour: 2025-08-07
Source: Codes observés dans le système GearSwap existant

---

*Ce fichier doit être mis à jour avec les codes couleur exacts de `assets/color.png` une fois analysé.*
