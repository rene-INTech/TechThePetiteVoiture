# TechThePetiteVoiture
Projet du module Intégration de Système Electroniques (PHY4501)


## Ressources du Microcontrôleur Secondaire

Timer 0:
Le `Timer 0` est utilisé par la routine d'attente de 50 ms `Attente` en mode 1.
Est également utilisé pour la désactivation du laser après un temps sans réception en mode 1 avec interruption 

Timer 1:
Le `Timer 1` est utilisé par l'UART en mode 2.

Pile:
La pile se trouve dans la mémoire octets `SP = 0x2F` après l'initialisation.

#### Description des données

| Nom           | Type  | Ressource | Description                                                                           |
|:--------------|:-----:|----------:|:--------------------------------------------------------------------------------------|
| **LCD**       |       |           |                                                                                       |
| LCD_Bus       | octet |        P2 | Bus de données pour communication avec l'écran LCD                                    |
| BF            |  bit  |      P2.7 | _Busy Flag_ de l'afficheur LCD                                                        |
| RS            |  bit  |      P0.5 | _Registry Select_ du bus de contrôle du LCD                                           |
| RW            |  bit  |      P0.6 | _Read <span style="text-decoration: overline">Write</span>_ du bus de contrôle du LCD |
| E             |  bit  |      P0.7 | _Enable_ du bus de contrôle du LCD                                                    |
| **GPIO**      |       |           |                                                                                       |
| Laser         |  bit  |      P1.2 | Broche de contrôle du laser                                                           |
| Sirene        |  bit  |      P1.3 | Broche de contrôle de la sirène                                                       |
| LED           |  bit  |      P1.0 | Broche de contrôle de la LED de debug (indique l'état de la commande vers le µC principal)|
| Principal     |  bit  |      P3.1 | Est à l'état haut ssi la voiture doit avancer (J6.1)                                  |
|               |  bit  |      P3.2 | Peut servir a la communication avec la carte principale (J6.2)                        |
|               |  bit  |      P3.4 | Peut servir a la communication avec la carte principale (J6.3)                        |
| **Compteurs** |       |           |                                                                                       |
| nb_tours      | octet |      0x7F | Compte le nombre de tours de piste effectués                                          |
| nb_G          | octet |      0x7E | Compte le nombre de touches sur la cible gauche                                       |
| nb_C          | octet |      0x7D | Compte le nombre de touches sur la cible centre                                       |
| nb_D          | octet |      0x7C | Compte le nombre de touches sur la cible droite                                       |
| msg_prec      | octet |      0x7B | Sauvegarde le dernier message reçu                                                    |
| FLAG_4 | bit | F0 | Vaut 1 si le timer 0 doit être réinitialisé à la reception d'un message |

#### Routines
- `LCD_Init`:
    Initialise l'écran LCD
    > Utilise le registre `R0` comme variable locale

- `Att_depart`:
    Permet d'attendre la reception du signal de départ

- `LCD_msg`:
    Permet l'envoi d'une chaîne de caractères vers le LCD
    > `DPTR` pointe le premier caractère de la chaîne

- `LCD_CODE`:
    Permet d'envoyer une commande au LCD
    > `LCD_Bus` stocke la valeur à envoyer

- `LCD_DATA`:
    Permet d'envoyer un caractère au LCD
    > `LCD_Bus` stocke la valeur à envoyer

- `LCD_BF`:
    Permet de s'assurer que le LCD ne soit pas occupé

- `Attente`:
    Routine bloquant l'exécution pendant 50 ms
    > Utilise le `Timer 0`<br>
    > Modifie la valeur de C
- `Attente_1s`:
    Routine bloquant l'exécution pendant 1s
    > Appelle la routine `Attente` 

- `Balise_depart`:
    Routine à appeler à la première réception de chaque série de "0"
    > Incrémente le compteur de tours<br>
    > Eteint le microcontrôleur après 3 tours
 
- `IT_Timer0`:
    Routine d'interruption du timer 0.
    Eteint le laser, la sirène et désactive le rechargement du timer à la réception de message et les interruptions sur ce timer

- `Debug_UART`:
    Affiche le dernier message série reçu à la suite de ce qui est sur le LCD
    > Suppose que les routines de communication au LCD fonctionnent

## Auteurs
  - [Baptou](https://github.com/bapt117)
  - [Elo](https://github.com/elomhs)
  - [El Gwengo](https://github.com/gwenser)
  - [René](https://github.com/rene-INTech)
 
