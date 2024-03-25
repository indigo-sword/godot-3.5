# Information
We are migrating code from [godot-build](https://github.com/indigo-sword/godot-build), written in Godot 4.2, into this repo, written in Godot 3.5. The old repo will be deprecated once the migration completes. Godot 3.5 is a LTS version so hopefully that also justifies our choice :P

## Player
The player, together with its sprite manager, animation manager, and script, are packaged into ```Objects/Player.tscn``` for repeated uses in the levels. As a contributor, you don't necessarily need to interact with this object when building a new level for the game, as the level loader will automatically load a player object into the scene and map keyboard controls whenever the level is loaded for play.
## Gameplay Control
To control the player in game, use the arrow keys or WASD to move around, shift to dash, and space bar to attack. More advanced controls are:
- Attack combos (WIP): if you hit shift exactly when an enemy is attacking, you can make a critical/heavy attack by hitting the space bar immediately.
- Heavy attack (WIP): if you hold onto the space bar you will enter the stage to initiate a heavy attack. This will take some charge time so it requires precise timing.
