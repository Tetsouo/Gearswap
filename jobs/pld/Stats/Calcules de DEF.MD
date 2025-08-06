# Prompt pour calculer la DEF finale d'un set

Entrées nécessaires :

- DEF nue affichée : La DEF totale en jeu sans équipement (valeur brute à poil).
- VIT de base : La VIT de base du personnage sans équipement.
- DEF des équipements : Une liste détaillée de toutes les pièces d'équipement avec leurs valeurs de DEF.
- VIT des équipements : Une liste détaillée de toutes les pièces d'équipement avec leurs valeurs de VIT.

Calculs à effectuer :

1. DEF de base (sans la contribution de la VIT) :
   DEF de base = DEF nue affichée - (VIT de base × 1.5)

2. Somme des DEF des équipements :
   Additionnez toutes les valeurs de DEF des pièces d’équipement.

3. DEF totale (base + équipements) :
   DEF totale = DEF de base + DEF des équipements

4. VIT totale (base + équipements) :
   VIT totale = VIT de base + somme des VIT des équipements

5. Contribution de la VIT à la DEF :
   Contribution VIT = VIT totale × 1.5

6. DEF finale :
   DEF finale = DEF totale + Contribution VIT

Sortie attendue :
Un résumé clair et structuré contenant :

- DEF nue
- DEF de base (sans VIT)
- DEF des équipements
- DEF totale (base + équipements)
- VIT totale
- Contribution de la VIT
- DEF finale

Exemple d’utilisation :

1. Donnez-moi les données suivantes :

   - DEF nue affichée : 541
   - VIT de base : 161
   - DEF des équipements : 145, 148, 200, 40, 30, 22, 136, 20, 11, 160, 121
   - VIT des équipements : 25, 58, 51, 15, 3, 54, 15, 20, 43, 40

2. Résultat attendu :
   Je calculerai et afficherai la DEF finale en suivant les étapes ci-dessus.

Note :
Utilisez ce prompt pour m'envoyer les informations nécessaires pour calculer la DEF finale pour n'importe quel set d'équipement.
