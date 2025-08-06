# Final Fantasy XI - Mécaniques de Résistance Magique pour Paladin

## Table des Matières

- [Magic Damage Taken (MDT)](#magic-damage-taken-mdt)
- [Breath Damage Taken (BDT)](#breath-damage-taken-bdt)
- [Magic Evasion](#magic-evasion)
- [Elemental Resistance](#elemental-resistance)

---

## Magic Damage Taken (MDT)

### Définition

**Magic Damage Taken** (MDT) se réfère à la réduction des dégâts magiques subis par un joueur, spécifiquement pour les Paladins.

### Calcul

- **Dégâts Magiques** :
  - Dépend de la différence de statistiques (`dStat`) entre le lanceur et la cible.
  - Cap de réduction à -50%, mais Aegis, utilisé par les Paladins, permet une réduction jusqu'à -87.5%.

### Cap Général

- Le cap total pour la réduction des dégâts est de -87.5% pour les joueurs et leurs familiers.

---

## Breath Damage Taken (BDT)

### Définition

**Breath Damage Taken** (BDT) concerne la réduction des dégâts de souffle, qui ne sont pas considérés comme des dégâts magiques mais peuvent être élémentaires.

### Calcul

- Basé sur les HP du monstre et l'équipement spécifique à la réduction des dégâts de souffle.
- Les Paladins peuvent utiliser divers équipements pour réduire ces dégâts.
- Cap de réduction à -50%.

---

## Magic Evasion

### Définition

**Magic Evasion** est la capacité d'une cible, y compris un Paladin, à éviter ou à réduire les effets des sorts magiques.

### Fonctionnement

- Comparée à la **Magic Accuracy** du lanceur pour déterminer le **Magic Hit Rate** ou la distribution des résistances.
- Chaque point de Magic Evasion augmente la résistance par :
  - +1% pour chaque +2 Magic Evasion en dessous de 50% de résistance.
  - +2% pour chaque +2 Magic Evasion au-delà de 50% de résistance.

### Interaction avec la Résistance Élémentaire

- Une résistance élémentaire positive est requise pour une résistance complète (1/8 des dégâts).
- Une résistance élémentaire négative garantit au moins 1/2 des dégâts, empêchant les résistances complètes.

### Niveaux de Base

- Les joueurs, y compris les Paladins, ont un rang G de Magic Evasion.

---

## Elemental Resistance

### Définition

**Elemental Resistance** réduit les effets des sorts magiques en fonction de leur élément, pertinent pour les Paladins.

### Effets

- Chaque point de résistance élémentaire ajoute 1 point à la Magic Evasion pour cet élément.
- Les Paladins peuvent optimiser leur équipement pour maximiser cette résistance.

### Modifications

- Les Paladins peuvent utiliser des équipements comme Sakpata's pour augmenter leur Magic Evasion, mais doivent également considérer la résistance élémentaire pour une efficacité maximale.

### Comportements Spécifiques

- Résistance négative empêche la résistance complète.
- Certains rangs de résistance garantissent des niveaux de résistance minimum.

---

_Ce document est basé sur des sources et des tests communautaires pour Final Fantasy XI, spécifiquement adapté pour le job Paladin. Les informations peuvent évoluer avec des mises à jour du jeu._
