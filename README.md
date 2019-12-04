# TechThePetiteVoiture
Projet du module Intégration de Système Electroniques (PHY4501)


## Ressources du Microcontrôleur Secondaire

Le `Timer 0` est utilisé lors de l'initialisation du LCD.

Le `Timer 1` est utilisé par l'UART

 | Nom | Type | Ressource | Description |
 | --- | :---: | ---: | --- |
 | LCD_Bus | octet | P2 | Bus de données pour communication avec l'écran LCD |
 | RS | bit | P0.5 | *Registry Select* du bus de contrôle du LCD |
 | RW | bit | P0.6 | *Read W&#773;r&#773;i&#773;t&#773;e&#773;* du bus de contrôle du LCD |
 | E | bit | P0.7 | *Enable* du bus de contrôle du LCD |
 | BF | bit | P2.7 | *Busy Flag* de l'afficheur LCD |
 | Laser | bit | P1.2 | Broche de contrôle du laser |
 | Sirene | bit | P1.3 | Broche de contrôle de la sirène |
 | LED | bit | P1.0 | Broche de contrôle de la LED de debug |
 
 
 ## Auteurs
  - bapt117
  - gwenser
  - elomhs
  - rene-INTech
 