# TechThePetiteVoiture
Projet du module Intégration de Système Electroniques (PHY4501)


## Ressources du Microcontrôleur Secondaire

Le `Timer 0` est utilisé par la routine d'attente de 50 ms `Attente`.

Le `Timer 1` est utilisé par l'UART

La pile se trouve dans la mémoire octets `SP = 0x2F`

#### Description des données
 | Nom | Type | Ressource | Description |
 | --- | :---: | ---: | --- |
 | LCD_Bus | octet | P2 | Bus de données pour communication avec l'écran LCD |
 | BF | bit | P2.7 | *Busy Flag* de l'afficheur LCD |
 | RS | bit | P0.5 | *Registry Select* du bus de contrôle du LCD |
 | RW | bit | P0.6 | *Read W&#773;r&#773;i&#773;t&#773;e&#773;* du bus de contrôle du LCD |
 | E | bit | P0.7 | *Enable* du bus de contrôle du LCD |
 | Laser | bit | P1.2 | Broche de contrôle du laser |
 | Sirene | bit | P1.3 | Broche de contrôle de la sirène |
 | LED | bit | P1.0 | Broche de contrôle de la LED de debug |
 | | bit | P3.1 | Peut servir a la communication avec la carte principale (J6.1) |
 | | bit | P3.2 | Peut servir a la communication avec la carte principale (J6.2) |
 | | bit | P3.4 | Peut servir a la communication avec la carte principale (J6.3) |
 |nb_tours | octet | | Compte le nombre de tours de piste effectués |
 | nb_G | octet | | Compte le nombre de touches sur la cible gauche |
 | nb_C | octet | | Compte le nombre de touches sur la cible centre |
 | nb_D | octet | | Compte le nombre de touches sur la cible droite |
 
 ---
 
 ## Auteurs
  - bapt117
  - elomhs
  - gwenser
  - rene-INTech
 
