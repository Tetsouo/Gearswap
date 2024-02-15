# Explanation of the SharedFunctions.lua file

# Constants

- `GRAY`, `ORANGE`, `YELLOW`, `RED` : These are color codes. They are used to change the color of the text in the game.

- `WAIT_TIME` : This is the time that the game waits between each action.

- `ignoredSpells` : list of spells to ignore.

- `mainPlayerName` and `altPlayerName` : These are the variables where you will define the names of your characters for functions that use the names for a specific purpose.

- `incapacitating_buffs_set` : This is a list of buffs that can prevent the character from performing actions. For example, if the character is 'silent', they cannot cast spells. Normally all incapacitating buffs are included, but you can add more if you wish.

# Explication de la fonction `bufferRoleForAltRdm`

Cette fonction est comme une liste de tâches pour un personnage alternatif dans le jeu quand il joue le rôle de "RDM".

Voici comment cela fonctionne :

- Le joueur donne une commande spécifique, comme "bufftank", "buffmelee", "buffrng", "curaga", ou "debuff". Chaque commande correspond à une série de sorts que le Mage Rouge va lancer.

Pour utiliser cette fonction dans le jeu, Si vous lancer vos sorts depuis votre personnage principal et que votre personnage alternatif est rdm créer une macro 
- avec comme première ligne `/t <stpc>` ou `/t <stal>`
- puis sur la deuxième ligne `/con gs c bufftank`.