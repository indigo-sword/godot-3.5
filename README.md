# Branches Of Fate - Godot 3.5

Welcome to Branches of Fate's Godot 3.5 implementation! This repository contains the source code for the game.

We are migrating code from [godot-build](https://github.com/indigo-sword/godot-build), written in Godot 4.2, into this repo, written in Godot 3.5. The old repo will be deprecated once the migration completes. Godot 3.5 is a LTS version, and we are using it to ensure the game's stability and compatibility with various platforms.

## Starting the Game

- The game is still not done, but you can download this repo and open it in Godot 3.5 to see the current state of the game - and possibly to contribute.

- To start the game, open the `project.godot` file in Godot 3.5. You can do this by opening Godot and selecting the `project.godot` file in the file explorer.

- Once the project is open, you can run the game by clicking the play button in the top-right corner of the Godot window.

## Contributing

- If you want to contribute with online features, you will need to use the server. To do that, check our other repository, which manages our API: [Branches Of Fate](https://github.com/indigo-sword/project-octopus).

- If you use the server, you will be able to see that there is already a version of the database there for you :). You can use it to test the game. If you want to do tests, I crated a test user for you to use: `jvphenares` as username and `PASS` as password.

- When you put the server online, you can change the `_URL` attribute in the `_init()` method in the `Scripts/Client/client.gd` file to your server's URL. Just be sure to change it back when you make a PR.

# Implementation

- Check an overview of how the game is implemented:

## Assets

- The assets for the game are stored in the `Assets` folder. You can find the sprites, animations, and sound effects used in the game here. The assets were gathered for free use, so feel free to also use them.

- If you want to contribute with assets, check our [Discord server](https://discord.gg/abQa2a3Dc5) to see how you can help us. We put some requests in the `#art-requests` channel. You can also just put whatever asset you want to share in your PR and we can review it.

- The assets are organized into the following subfolders:
  - `Fonts`: Contains the fonts used in the game.
  - `GuiComponents`: Contains the GUI components used in the game.
  - `Images`: Contains the images used as images (not sprites) in the game. Mostly used for the Menus.
  - `Player`: Contains the sprites and animations for the player character.
  - `SettingItems`: Contains the ambience of the game.
  - `TilesBuildings`: Contains the tilesets used in the game.
  - `Weapons`: Contains the weapons used in the game.

## Items

- The items folder contains ???

## Objects

- The Objects folder contains the objects - be them abstract or concrete - that are used in the game. The objects are organized into the following subfolders:
  - `Client`: A Godot singleton that manages the client-side of the game. It is always present in the game and is responsible for managing the game's state and the player's interactions with the game. Check its [README](Objects/Client/README.md) for more information.
  - `Config`: A Godot singleton that manages the game's configuration. It is responsible for loading and saving the game's configuration, such as the player's settings and the game's settings.
  - `Control`: ???
  - `Enemy`: Contains the implementation of the enemies in the game. The enemies are the characters that the player must defeat to progress in the game.

## SavedLevels

- This folder contains the saved levels in the game. They are loaded so the player can play them.

## Scenes

- This folder contains all scenes an user can access in the game. The scenes are organized into the following subfolders:

  - `LevelEditor`: Contains the scenes that are used in the level editor. The level editor is a tool that allows users to create their own levels.

  - `Menu`: Contains the scenes that are used in the game's menus. There are lots of them categorized under subfolders. Check its README.md for more information.

  - `Tests`: Contains the scenes that are used to test the game. The tests are used to ensure that the game is working as expected.

## Scripts

- These are loadable scripts used by Objects in the game. They are organized into many subfolders, but each object calls them in their manner. They are organized within folders depending on who they relate to (i.e. the client scripts are in the Client folder)

---------------------------- OLD README -----------------------------

## Player

The player, together with its sprite manager, animation manager, and script, are packaged into `Objects/Player.tscn` for repeated uses in the levels. As a contributor, you don't necessarily need to interact with this object when building a new level for the game, as the level loader will automatically load a player object into the scene and map keyboard controls whenever the level is loaded for play.

### Gameplay Control

To control the player in game, use the arrow keys or WASD to move around, shift to dash, and space bar to attack. More advanced controls are:

- Dodge parry (WIP): if you hit shift exactly when an enemy is attacking, you can make a critical/heavy attack by hitting the space bar right after.
- Heavy attack (WIP): if you hold onto the space bar you will enter the stage to initiate a heavy attack. This will take some charge time so it requires precise timing.

## Level Editor

The level editor is a custom tool built into the game to allow contributors to build levels without needing to touch the code. The level editor is still in development, and the final version will be built with the following features:

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
