# Résumé Global sur les Résistances Physiques pour Paladin

Le Paladin excelle dans la réduction des dégâts physiques grâce à une combinaison de **DEF**, **PDT**, mécaniques de boucliers, et gestion des coups critiques. Optimiser ces aspects permet de réduire efficacement les dégâts physiques subis, même contre des ennemis à Attaque élevée.

---

## 1. La DEF (Défense)

### Fonctionnement

- **DEF de base** :

  - Dépend du niveau et de la Vitalité (VIT).
  - **Formule** : `DEF de base = floor(VIT × 1.5) + ajustement selon le niveau`.

- **DEF des équipements** :

  - Ajout direct des valeurs de DEF des équipements.

- **Buffs actifs** :
  - **Protect V** :
    - Ajoute **220 DEF**.
    - Lorsqu'il est lancé par un Paladin avec **Shield Barrier**, la DEF du bouclier s’ajoute.
    - **Exemple** : Un bouclier à 130 DEF donne un total de **350 DEF**.
  - **Cocoon** (sous Blue Mage) :
    - Augmente la DEF de **50 %**.

### Impact

La DEF influe sur le ratio **Attaque/DEF** :

- **Ratio favorable (DEF > Attaque)** :
  - Réduction des dégâts subis.
- **Ratio défavorable (DEF < Attaque)** :
  - Les dégâts augmentent, mais une DEF élevée limite cet écart.

---

## 2. Mécaniques de Boucliers (Shields)

### Blocage d'attaque

- **Taux de blocage** :

  - Déterminé par la taille du bouclier et la compétence **Shield Skill**.
  - **Formule** :  
    `BlockRate = SizeBaseBlockRate + ((ShieldSkill - AttackerCombatSkill) × 0.2325)`.
  - **Exemple** :
    - Avec une Shield Skill de 420 et une SizeBaseBlockRate de 45 %, le taux de blocage atteint **49.65 %**.

- **Réduction des dégâts bloqués** :
  - **Formule** :  
    `FinalDamageTaken = (IncomingBaseDamage - ShieldDefenseBonus) × (1 - PercentDamageBlocked/100) × (1 - PDT/100)`.
  - **Exemple** :
    - Une attaque de **1000 dégâts** avec **60 % de réduction** et un **PDT de 30 %** donne un total de **280 dégâts finaux**.

### Shield Defense Bonus

Ajoute une réduction fixe lors d'un blocage réussi :

| Niveau | Job/Niveau requis   | Réduction fixe (points) |
| ------ | ------------------- | ----------------------- |
| I      | PLD77, WAR80, WHM85 | -2                      |
| II     | PLD82, WAR88, WHM95 | -4                      |
| III    | PLD88, WAR99        | -6                      |
| IV     | PLD93               | -8                      |

### Capacités augmentant les performances des boucliers

- **Reprisal** :
  - Augmente le taux de blocage de **50 %** (ou **3x** avec **Priwen** ou **Adamas**).
- **Palisade** :
  - Ajoute **30 %** de taux de blocage (+20 % via mérites).
  - Élimine la perte d'hostilité lors d'un blocage.

---

## 3. Gestion des Coups Critiques

### Réduction des critiques

- **Taux critique ennemi** :
  - Réduit par des équipements comme **Fortified Ring** ou **Warden's Ring**.
- **Dégâts critiques** :
  - La **VIT** et des bonus comme **Critical Defense Bonus** atténuent ces dégâts.

### Optimisation

- **Priorités** :
  - Contenus à haute fréquence critique (exemple : _Dynamis Divergence_).
  - Utilisez une combinaison de **DEF**, **VIT** et équipements spécifiques.

---

## 4. Stratégie d’Optimisation Globale

Pour maximiser la mitigation des dégâts physiques :

1. **Atteindre une DEF élevée** :
   - Utilisez la VIT, les équipements, et les buffs comme **Protect V**.
2. **Exploitez les mécaniques de boucliers** :
   - Capacité comme **Reprisal** et **Palisade** pour augmenter la fréquence de blocage.
3. **Gérez les critiques ennemis** :
   - Réduisez leur fréquence et leurs dégâts à l’aide d’équipements spécifiques.

---

## Conclusion

La gestion des résistances physiques pour le Paladin repose sur une synergie entre **DEF**, mécaniques de boucliers, et gestion des critiques. En combinant ces éléments, le Paladin réduit efficacement les dégâts physiques subis, même dans des situations de combat intenses contre des ennemis à forte Attaque ou haute fréquence critique.
