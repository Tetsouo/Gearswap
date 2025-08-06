# Guide du Système d'Inimitié pour PLD dans FFXI

## Fondamentaux de l'Inimitié

### Les Trois Types d'Inimitié

#### Inimitié Cumulative (CE)
- **Plafonnée à 30,000 CE**
- Diminue lors des dégâts reçus et actions ennemies
- **Formule de perte** : `CE perdue = 1800 × Dégâts reçus ÷ HP Maximum`

#### Inimitié Volatile (VE)
- **Plafonnée à 30,000 VE**
- Décroît de 60 VE par seconde
- **Exemple** : Provoke = 1800 VE

#### Inimitié Totale (TE)
- **TE = CE + VE (maximum 60,000)**
- Cible prioritaire = TE le plus élevé

## Gestion de l'Inimitié

### Rétention d'Inimitié

#### Équipement et Réduction
- **Cap d'Inimitié+** : +100 pour -50% de perte
- **Cap Équipement + Foe Sirvente** : -50% de perte (partagé)
- **Réduction Maximale Totale** : 75%

1 - [(1 - 0.50) × (1 - 0.50)] = 75%

#### Équipements Réduisant la Perte
- **Burtgang** : -20%
- **Chevalier's Cuisses +3** : -14%
- **Creed Collar** : -5%
- **Foe Sirvente** : Complète jusqu'au cap de 50%

#### Gestion des HP
- HP maximum élevés = moins de perte de CE
- Dégâts reçus ÷ HP maximum dans la formule

### Génération d'Inimitié

#### Capacités Principales
- **Flash** : Inimitié fixe
- **Provoke** : 1800 VE
- **Sentinel** : +100 inimitié pendant sa durée

#### Atonement (WS)
- **Dégâts** : `((CE ÷ 6) - 1) + ((VE ÷ 6) - 1)`
- Base : 300 CE / 900 VE à 1000 TP
- **Multiplicateurs TP** :
- 1000 : ×1.0
- 2000 : ×1.5
- 3000 : ×2.0

## Situations Spéciales

### Multi-Cibles

- Inimitié des soins divisée par nombre de monstres
- Soins à inimitié fixe non divisés (ex: Cure V)

### Notes Techniques
- CHR n'affecte pas l'inimitié
- Décroissance VE (-60/sec) fixe
- Bonus de job calculés séparément
