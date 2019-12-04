# TechThePetiteVoiture
Projet du module Intégration de Système Electroniques (PHY4501)


## Ressources du Microcontrôleur Secondaire

Timer 0
 : Le `Timer 0` est utilisé par la routine d'attente de 50 ms `Attente` en mode 1.

Timer 1
 : Le `Timer 1` est utilisé par l'UART en mode 2.

Pile
 : La pile se trouve dans la mémoire octets `SP = 0x2F` après l'initialisation.

#### Description des données

 | Nom | Type | Ressource | Description |
 | --- | :---: | ---: | --- |
 | **LCD** |
 | LCD_Bus | octet | P2 | Bus de données pour communication avec l'écran LCD |
 | BF | bit | P2.7 | _Busy Flag_ de l'afficheur LCD |
 | RS | bit | P0.5 | _Registry Select_ du bus de contrôle du LCD |
 | RW | bit | P0.6 | _Read <span style="text-decoration: overline">Write</span>_ du bus de contrôle du LCD |
 | E | bit | P0.7 | _Enable_ du bus de contrôle du LCD |
 | **GPIO** |
 | Laser | bit | P1.2 | Broche de contrôle du laser |
 | Sirene | bit | P1.3 | Broche de contrôle de la sirène |
 | LED | bit | P1.0 | Broche de contrôle de la LED de debug |
 | | bit | P3.1 | Peut servir a la communication avec la carte principale (J6.1) |
 | | bit | P3.2 | Peut servir a la communication avec la carte principale (J6.2) |
 | | bit | P3.4 | Peut servir a la communication avec la carte principale (J6.3) |
 | **Compteurs** |
 |nb_tours | octet | 0x7F | Compte le nombre de tours de piste effectués |
 | nb_G | octet | 0x7E | Compte le nombre de touches sur la cible gauche |
 | nb_C | octet | 0x7D | Compte le nombre de touches sur la cible centre |
 | nb_D | octet | 0x7C | Compte le nombre de touches sur la cible droite | 
  
 ## Auteurs
  - bapt117
  - elomhs
  - gwenser
  - rene-INTech
 
