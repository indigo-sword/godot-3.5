# Information
We are migrating code from [godot-build](https://github.com/indigo-sword/godot-build), written in Godot 4.2, into this repo, written in Godot 3.5. The old repo will be deprecated once the migration completes. Godot 3.5 is a LTS version so hopefully that also justifies our choice :P

## Player
The player, together with its sprite manager, animation manager, and script, are packaged into ```Objects/Player.tscn``` for repeated uses in the levels. As a contributor, you don't necessarily need to interact with this object when building a new level for the game, as the level loader will automatically load a player object into the scene and map keyboard controls whenever the level is loaded for play.

### Gameplay Control
To control the player in game, use the arrow keys or WASD to move around, shift to dash, and space bar to attack. More advanced controls are:
- Dodge parry (WIP): if you hit shift exactly when an enemy is attacking, you can make a critical/heavy attack by hitting the space bar right after.
- Heavy attack (WIP): if you hold onto the space bar you will enter the stage to initiate a heavy attack. This will take some charge time so it requires precise timing.

## Level Editor
The level editor is a custom tool built into the game to allow contributors to build levels without needing to touch the code.  The level editor is still in development, and the final version will be built with the following features:

### Map Navigation: The map supports drag-to-move and zoom-in/out functionalities, enabling users to navigate the scene and focus on specific areas. 
- Zoom (ctrl+/-): The map supports zooming in and out, enabling detailed focus or broader views of the scene. 
- Viewport Movement (A/W/S/D): Users can move around the viewport to create extensive scenes beyond the initial screen size.

### Scene Building:
- Object and Enemy Positioning: Users can position objects, such as weapons (e.g., a character's sword), and enemies on the screen, allowing for customized scene setups.
- Tile Blocks: Users can customize the scene's terrain and environment by selecting and placing tile blocks.
- Animated Characters (E): Simulate the motion of animated characters to preview the live scenes.

### Scene Management:
- Saving and Loading (WIP): Scenes can be saved to and loaded to our server, allowing users to preserve their progress and return to their creations at any time. It will also enable sharing and collaboration on scenes.

### TODOs:
- NPC Interactions: Developing Non-Player Characters (NPCs) and their dialogues, which will allow for interactions and conversations with NPCs.
- Asset Gathering: Actively gathering assets to expand the creative possibilities for users.
