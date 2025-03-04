### Résumé Global sur les Boucliers (Shields) pour Paladin

Les boucliers sont un élément central du rôle de tank du Paladin, permettant de bloquer les attaques physiques, de réduire les dégâts subis et d’améliorer la durabilité globale. Leurs performances sont influencées par la taille du bouclier, la compétence Shield Skill, le Shield Defense Bonus et les caractéristiques uniques des boucliers ultimes.

---

### Fonctionnement des Boucliers

#### Blocage d'attaque

- Les boucliers permettent de bloquer les attaques physiques provenant de l’avant du joueur.
- Aucun engagement direct avec l'ennemi n'est requis pour bloquer une attaque.
- Lorsqu'un blocage réussi se produit, les dégâts de l'attaque sont réduits selon la taille du bouclier et d'autres caractéristiques.

#### Compétence Shield Skill

La compétence Shield Skill détermine la fréquence de blocage.

- **Formule du taux de blocage :**

  `BlockRate = SizeBaseBlockRate + ((ShieldSkill - AttackerCombatSkill) × 0.2325)`

  - **SizeBaseBlockRate** : Taux de blocage de base selon la taille du bouclier.
  - **ShieldSkill** : Niveau de compétence en bouclier du joueur.
  - **AttackerCombatSkill** : Compétence de combat de l'attaquant.

- Les capacités telles que **Reprisal** et **Palisade** augmentent artificiellement le taux de blocage.

##### Exemple chiffré pour le taux de blocage :

Si un joueur a un Shield Skill de 420, que la SizeBaseBlockRate du bouclier est de 45%, et que l'AttackerCombatSkill est de 400 :

`BlockRate = 45 + ((420 - 400) × 0.2325) = 45 + (20 × 0.2325) = 49.65%`

#### Réduction des Dégâts

Le pourcentage de réduction des dégâts à chaque blocage réussi est calculé comme suit :

`PercentDamageBlocked = SizeDamageReduction + (ShieldDEF / ((max(ShieldItemLevel, 99) - 99) / 10 + 2))`

- **ShieldDEF** : La défense indiquée sur le bouclier.
  - Pour les boucliers de niveau 119 : ShieldDEF est divisé par 4.
- **FinalDamageTaken :**
  `FinalDamageTaken = (IncomingBaseDamage - ShieldDefenseBonus) × (1 - PercentDamageBlocked/100) × (1 - PDT/100)`
  - **PDT** : Réduction globale des dégâts physiques depuis l’équipement (cap à 50%).

##### Exemple chiffré pour la réduction des dégâts :

Si un joueur reçoit une attaque de 1000 points de dégâts avec un bouclier offrant 50% de SizeDamageReduction et un ShieldDEF de 40, avec un PDT de 30% :

`PercentDamageBlocked = 50 + (40 / ((119 - 99) / 10 + 2)) = 50 + (40 / 4) = 60%`
`FinalDamageTaken = 1000 × (1 - 60/100) × (1 - 30/100) = 1000 × 0.4 × 0.7 = 280 points de dégâts finaux`

#### Shield Defense Bonus

Le **Shield Defense Bonus** (ou "Extreme Guard" en version japonaise) ajoute une réduction fixe des dégâts lors d’un blocage réussi.

- Réduction fixe des dégâts en fonction du niveau du trait :

| Niveau | Job/Niveau requis   | Réduction fixe (points) |
| ------ | ------------------- | ----------------------- |
| I      | PLD77, WAR80, WHM85 | -2                      |
| II     | PLD82, WAR88, WHM95 | -4                      |
| III    | PLD88, WAR99        | -6                      |
| IV     | PLD93               | -8                      |

Pour standardiser, le terme "réduction fixe" est utilisé à travers tout le texte.

---

### Capacités augmentant les performances des boucliers

#### Reprisal

Reprisal est une capacité essentielle pour le Paladin, augmentant considérablement la fréquence et l'efficacité des blocages avec un bouclier.

- **Effets :**
  - Augmente la compétence Shield Skill de **+15 %** (multiplicateur de 1.15x).
  - Augmente le taux de blocage de **50 %** de votre taux actuel :  
    `Current block rate × 1.5`.
    - Par exemple, un taux de blocage de 30 % passe à 45 %.
    - Avec **Priwen** ou **Adamas**, le multiplicateur est de 3x (exemple : 30 % → 90 %).
  - Ne s'interrompt plus en fonction des dégâts reçus depuis la mise à jour de mai 2021, mais se termine une fois la durée écoulée.
  - **Durée :** dépend du temps restant d'effet des **spikes spells**.

#### Palisade

Palisade est une capacité améliorant la fiabilité des blocages tout en conservant l'hostilité du Paladin.

- **Effets :**
  - Augmente le taux de blocage de **30 %**.
  - Les points de job peuvent augmenter ce bonus de **+20 % supplémentaires**, pour un total de **50 %**.
  - Élimine la perte d’hostilité lors des blocages.
  - **Durée :** 60 secondes.
  - **Recast :** 5 minutes.

---

### Boucliers Standards

| Taille | Réduction de Dégâts (%) | Taux de Blocage de Base (%) |
| ------ | ----------------------- | --------------------------- |
| 1      | -20%                    | 55%                         |
| 2      | -40%                    | 40%                         |
| 3      | -50%                    | 45%                         |
| 4      | -65%                    | 30%                         |

---

### Boucliers Ultimes

| Bouclier     | Réduction de Dégâts (%) | Taux de Blocage (%) | Détails supplémentaires                            |
| ------------ | ----------------------- | ------------------- | -------------------------------------------------- |
| **Aegis**    | -75%                    | 50%                 | Ignore les limites de réduction magique, MDT -50%. |
| **Srivatsa** | -75%                    | 50%                 | Annule 5% des dégâts restants après réduction.     |
| **Ochain**   | -60%                    | \~108%              | Taux de blocage extrêmement                        |
