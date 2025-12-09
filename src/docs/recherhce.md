# Mécaniques clés & sources (Tower Defense 2D)

- **Système d’argent**  
  L’argent est gagné (kills/fin de vague) et dépensé (achat/upgrades), avec une progression calibrée pour éviter le snowball.  
  _Source :_ [Simple in-game currency system in Godot](https://www.wayline.io/blog/simple-in-game-currency-system-godot)

- **Création de map en tuiles hexagonales**

  _Source :_ https://www.youtube.com/watch?v=v55h6hTFWLw

- **Génération de vagues d’ennemis**  
  Un gestionnaire de vagues instancie des ennemis à intervalles, avec quantité/statistiques qui montent par vague.  
  _Source :_ [Spawning 2D Enemy Waves (Godot 4)](https://medium.com/codex/godot-1-01-spawning-2d-enemy-waves-godot-4-c-a3cc41880e33)

- **Mini-boss et boss**  
  Insérer périodiquement des ennemis élites/boss (PV/capacités uniques) crée des pics de difficulté et rythme la progression.  
  _Source :_ [Game Developer — Building Better Bosses](https://www.gamedeveloper.com/design/building-better-bosses)

- **Level/upgrade des tours & changement de skin**  
  Les upgrades augmentent dégâts/portée/cadence et déclenchent un changement visuel (sprites/animations par niveau).  
  _Source :_ [GDQuest — Tower Defense Upgrades (overview)](https://school.gdquest.com/courses/learn_2d_gamedev_godot_4/tower_defense_upgrades/overview)

- **Positionnement des tours**  
  Placement sur une grille avec prévisualisation (valide/invalides) et validation pour ne pas bloquer le chemin.  
  _Source :_ https://www.youtube.com/watch?v=-k7oUH0i-YQ
