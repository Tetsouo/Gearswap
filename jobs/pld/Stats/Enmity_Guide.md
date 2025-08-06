# Enmity dans FFXI

## Introduction

L'**Enmity** détermine quel joueur une créature cible en combat. Elle est composée de deux types principaux qui influencent la **Total Enmity (TE)** d'un joueur.

## Types d'Enmity

### Cumulative Enmity (CE)

- **Définition** : Générée par les dégâts infligés ou certaines actions offensives.
- **Cap** : 30 000 CE.
- **Réduction** :
  - Prendre des dégâts.
  - Être la cible d'actions offensives ennemies.
  - Échapper à une attaque (ex. Utsusemi).
  - Techniques de monstres réinitialisant la haine.

### Volatile Enmity (VE)

- **Définition** : Générée par les dégâts infligés ou certaines actions offensives.
- **Cap** : 30 000 VE.
- **Réduction** :
  - Décroît avec le temps à raison de 60 VE par seconde.

## Total Enmity (TE)

- **Calcul** : TE = CE + VE.
- **Cible** : Le joueur avec le TE le plus élevé est ciblé par le monstre.

## Gain d'Enmity

### Enmity via Dégâts

- **Formule CE** : `Level Scaling Factor × 80 × Dégâts Infligés ÷ Dégâts Standards`.
- **Formule VE** : `3 × CE gagné`.
- **Exemple** : 2500 dégâts contre un monstre de niveau 99 donnent ~900 CE et 2700 VE.

### Enmity via Soins

- **Formule CE** : `HP Restaurés × Modificateur CE`.
- **Formule VE** : `6 × CE gagné`.
- **Partage** : Divisé entre les monstres dans la portée de l'enmity.

### Autres Sources

- **Actions fixes** : Utilisation de capacités spéciales ou sorts avec des valeurs d'enmity fixes.
- **Actions indirectes** : Soins ou améliorations augmentant l'enmity du joueur effectuant l'action.

## Perte d'Enmity

### Perte de CE

- **Prendre des Dégâts** : `CE perdu = 1800 × Dégâts pris ÷ HP Max`.
- **Autres Méthodes** :
  - Mana Wall : 180 CE par coup.
  - Perte d'Utsusemi : 25 CE.
  - Être affaibli : 80 CE.

### Perte de VE

- **Décroissance** : -60 VE par seconde.
- **Réinitialisation** : Certaines actions ou techniques peuvent réinitialiser VE.

## Équipement et Capacités Affectant l'Enmity

### Capacités de Job

- **Provoke** (Exemple) : Ajoute 1800 VE.
- **Collaborator/Accomplice** : Volent une partie de l'enmity d'un allié.

### Bonus d'Enmity Spéciaux

- **Sentinel Job Points** et **Divine Emblem** : Modificateurs multiplicateurs sur l'enmity générée.

### Équipement

- **Augmente/Réduit l'Enmity** : Certains équipements peuvent booster ou diminuer l'enmity générée par les actions du joueur.

## Stratégies de Tanking

### Super Tanking

- **Description** : Maintenir l'aggro sans interagir directement avec les monstres.
- **Utilisation** : Efficace pour tanking de multiples monstres en fin de jeu ou lors d'événements spécifiques.

## Ajustements Prévus

- **Révision des Dégâts Standards** : Ajuster les valeurs de base pour équilibrer l'enmity générée.
- **Modification de la Décroissance de l'Enmity** : Ajuster les taux de perte de VE et CE pour une meilleure gestion des aggro.
- **Équilibrage des Capacités et Équipements** : Assurer que les modifications n'avantagent pas trop certains jobs.

## Job Abilities et Sorts Affectant l'Enmity

### Paladin

| Nom de la JA/Sort  | CE  | VE   | Spécificités liées à l'enmity                                                                                                                                                            |
| ------------------ | --- | ---- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Invincible**     | 0   | 7200 | Ajoute 7200 VE. Offre une immunité aux attaques physiques pendant 30 secondes. Équivalent à quatre Provokes simultanés pour contrôler la haine.                                          |
| **Palisade**       | 900 | 1800 | Ajoute 900 CE et 1800 VE. Augmente la chance de bloquer avec le bouclier et élimine la perte d'enmity. Augmente le taux de blocage de +30% (jusqu'à +50% avec les JP).                   |
| **Flash (Scroll)** | 180 | 1280 | Ajoute 180 CE et 1280 VE. Aveugle temporairement un ennemi, réduisant fortement sa précision.                                                                                            |
| **Shield Bash**    | 450 | 900  | Ajoute 450 CE et 900 VE. Peut étourdir la cible, alimentant le TP des monstres. Effet instantané efficace pour interrompre les mouvements de TP des monstres.                            |
| **Rampart**        | 320 | 320  | Ajoute 320 CE et 320 VE. Réduit les dégâts subis par les membres du groupe dans la zone d'effet de -25% SDT.                                                                             |
| **Majesty**        | 0   | 340  | Ajoute 0 CE et 340 VE. Augmente la puissance des sorts de soin et réduit leur temps de recharge. Rend les sorts de soin et de protection en AoE.                                         |
| **Fealty**         | 0   | 320  | Ajoute 0 CE et 320 VE. Offre une résistance puissante à la magie affaiblissante, protégeant contre les sorts de charme et certains dégâts non élémentaires.                              |
| **Chivalry**       | 0   | 320  | Ajoute 0 CE et 320 VE. Convertit les TP en MP, augmentant l'efficacité des soins.                                                                                                        |
| **Divine Emblem**  | 0   | 320  | Ajoute 0 CE et 320 VE. Augmente de 50% l'enmity spéciale du prochain sort de magie divine. Multiplicatif avec les bonus d'enmity de l'équipement.                                        |
| **Sepulcher**      | 0   | 320  | Ajoute 0 CE et 320 VE. Baisse la précision, l'évasion, la précision magique, l'évasion magique et le gain de TP des ennemis morts-vivants de -20.                                        |
| **Cover**          | 0   | 1    | Ajoute 0 CE et 1 VE. Protège les membres du groupe en interceptant les attaques. Lors d'une interception réussie, ajoute +200 CE au Paladin et réduit l'enmity du membre couvert de 10%. |
| **Intervene**      | N/A | N/A  | Déclenche une attaque avec le bouclier, diminuant l'attaque et la précision de la cible. _(CE et VE non spécifiés)_                                                                      |

### Blue Mage (Sub Job)

| Nom de la JA/Sort  | CE  | VE   | Spécificités liées à l'enmity                                                                                                                   |
| ------------------ | --- | ---- | ----------------------------------------------------------------------------------------------------------------------------------------------- |
| **Jettatura**      | 180 | 1020 | Ajoute 180 CE et 1020 VE. Gel les ennemis dans une zone en forme de cône, réduisant leur attaque et leur précision pendant environ 2 secondes.  |
| **Blank Gaze**     | 320 | 320  | Ajoute 320 CE et 320 VE. Enlève un effet magique bénéfique d'un ennemi unique.                                                                  |
| **Geist Wall**     | 320 | 320  | Ajoute 320 CE et 320 VE. Enlève un effet magique bénéfique de tous les ennemis dans la portée de 6'.                                            |
| **Sheep Song**     | 320 | 320  | Ajoute 320 CE et 320 VE. Met tous les ennemis dans la portée au sommeil pendant 40 à 60 secondes. Peut interrompre toutes les actions ennemies. |
| **Frightful Roar** | 1   | 320  | Ajoute 1 CE et 320 VE. Réduit la défense des ennemis dans la portée de 10% pendant 3 minutes.                                                   |

### Warrior (Sub Job)

| Nom de la JA/Sort | CE  | VE   | Spécificités liées à l'enmity                                                                                                         |
| ----------------- | --- | ---- | ------------------------------------------------------------------------------------------------------------------------------------- |
| **Provoke**       | 1   | 1800 | Ajoute 1 CE et 1800 VE. Force l'ennemi à vous attaquer. Peut être utilisé pour maintenir le VE constant en l'utilisant régulièrement. |
| **Warcry**        | 0   | 320  | Ajoute 0 CE et 320 VE. Augmente la puissance d'attaque pour le groupe, génère une quantité modérée d'enmity.                          |
| **Berserk**       | 0   | 80   | Ajoute 0 CE et 80 VE. Augmente l'attaque et diminue la défense.                                                                       |
| **Defender**      | 0   | 80   | Ajoute 0 CE et 80 VE. Augmente la défense et diminue l'attaque.                                                                       |
| **Aggressor**     | 0   | 80   | Ajoute 0 CE et 80 VE. Augmente la précision et diminue l'évasion.                                                                     |

### Explications Supplémentaires

- **Invincible** : Utilisé principalement pour contrôler la haine en générant une énorme quantité de VE, garantissant que le Paladin reste la cible principale des ennemis.
- **Palisade** : Idéal pour augmenter la résistance du groupe tout en maintenant l'aggro sur le Paladin grâce à une forte génération d'enmity.
- **Flash (Scroll)** : Utile pour réduire la précision des ennemis, augmentant ainsi la survie du groupe tout en générant une quantité significative d'enmity.
- **Shield Bash** : Offre un équilibre entre génération d'enmity et contrôle des ennemis en les étourdissant.
- **Rampart** : Renforce les défenses du groupe tout en contribuant modérément à l'enmity.
- **Majesty** : Améliore les capacités de soin du groupe tout en générant une petite quantité d'enmity.
- **Fealty, Chivalry, Divine Emblem, Sepulcher** : Fournissent divers avantages défensifs et utilitaires avec une contribution constante à l'enmity.
- **Cover** : Offre une protection passive avec une génération d'enmity minimale, mais augmente significativement l'enmity lors de l'interception des attaques.
- **Intervene** : Bien que les valeurs exactes de CE et VE ne soient pas spécifiées, cette capacité est utilisée pour diminuer les attaques ennemies, ce qui peut indirectement influencer l'enmity.
- **Jettatura** : Utilisée pour contrôler les ennemis en les immobilisant temporairement tout en générant une quantité élevée de VE.
- **Blank Gaze** : Permet de retirer des effets bénéfiques des ennemis tout en générant une quantité modérée d'enmity.
- **Geist Wall** : Similaire à Blank Gaze mais affecte plusieurs ennemis dans une portée plus petite.
- **Sheep Song** : Puissant sort de contrôle des foules qui peut remplacer les étourdissements traditionnels, générant une quantité modérée d'enmity.
- **Frightful Roar** : Réduit la défense des ennemis, augmentant la menace tout en affaiblissant leurs capacités défensives.
- **Provoke** : Très efficace pour maintenir le VE du Paladin grâce à son taux de génération élevé.
- **Warcry** : Génère une quantité modérée d'enmity tout en augmentant l'attaque du groupe.
- **Berserk** : Génère une faible quantité d'enmity mais améliore l'attaque.
- **Defender** : Génère une faible quantité d'enmity tout en renforçant la défense.
- **Aggressor** : Génère une faible quantité d'enmity en augmentant la précision et en diminuant l'évasion.

### Remarques

- **Intervene** : Les valeurs de CE et VE pour cette capacité ne sont pas fournies. Il est recommandé de les tester en jeu ou de consulter des sources communautaires pour obtenir ces informations.
- **Divine Emblem** : Cette capacité a un effet multiplicatif spécial sur l'enmity, ce qui peut grandement augmenter la génération d'enmity lors de l'utilisation de sorts de magie divine.
- **Equipements Modifiant l'Enmity** : Certaines pièces d'équipement peuvent augmenter la durée ou la puissance des capacités, affectant ainsi indirectement la génération d'enmity.

## Conclusion

L'enmity est un système complexe essentiel pour la gestion des combats dans FFXI. Comprendre ses mécanismes permet aux joueurs de mieux contrôler les cibles des monstres et d'optimiser leurs rôles en groupe.

## Références

- Documentation officielle FFXI
- Discussions et tests communautaires
- [Wiki FFXI sur l'Enmity](https://www.example.com/wiki/enmity)
