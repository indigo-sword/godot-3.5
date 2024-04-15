# Menu

- This is the documentation of the many endpoints the menu can have. I will describe the current state of the menu. The menu begins on `Main/Init.tscn` and is controlled by the `Main/Init.gd` script. So, we will begin there.

### Description of endpoints

- `Main` is the collection of scenes that are used in the game's opening. It consists of two scenes.

  - `Init.tscn` is the main scene of the game. It is the first scene that is loaded when the game is started. Upon any interaction, it goes to the `Login.tscn` scene.

  - `Login.tscn` is the scene that is responsible for the player's login. If a player does not have a login, they can create one. Upon login, they go to PlayerMain

<br/>

- `PlayerMain` consists of the game's main menu, with different options. From there, the player can interact with buttons to go to a series of endpoints

  - Management-related buttons:

    - `Logout` button leads user back to the `Init` scene
    - `Configs` button leads user to the `Config` folder
    - `User Info` button leads user to the `UserInfo` folder

  - Discovery-related buttons:

    - `Popular Levels`, `Find Levels`, `Popular Paths` and `Find Paths` buttons lead user to the `Discover` folder

  - Creation-related buttons:

    - `Manage` button leads user to the `MyStuff` folder
    - `Create Level` button leads user to the level creator (and out of the menu)

  - Social buttons:
    - `Find User` and `See Followers` buttons lead user to the `Followers` folder

<br/>

- `Config` is the folder that contains the scene used to manage the game's configuration.

- `UserInfo` is the folder that contains the scene used to manage the user's information (i.e. username, password, bio, etc).

<br>

- `Discover` is the folder that contains the scenes used to discover new levels and paths in the game.

  - `PopularLevels` is the scene that shows the most popular levels in the game.

    - This scene needs work on further endpoints (i.e. loading a level when you click the `Play` button and showing the level's information when you click the `See More` button)

  - `FindLevels` is the scene that allows the user to search for levels in the game.

    - This scene needs work on further endpoints (i.e. loading a level when you click the `Play` button and showing the level's information when you click the `See More` button)

  - `PopularPaths` is the scene that shows the most popular paths in the game.

    - This scene needs work on further endpoints (i.e. loading a path when you click the `Play` button and showing the path's information when you click the `See More` button). The path information scene is already in development (@jpireshe) under the MyStuff/EditPath folder.

  - `FindPaths` is the scene that allows the user to search for paths in the game.

    - This scene needs work on further endpoints (i.e. loading a path when you click the `Play` button and showing the path's information when you click the `See More` button). The path information scene is already in development (@jpireshe) under the MyStuff/EditPath folder.

<br/>

- `MyStuff` is the folder that contains the scenes used to manage the user's creations in the game.

  - `Manage` is the scene that shows the user's levels and paths. The user can edit or delete them.

    - This scene needs work on further endpoints (i.e. loading a scene about the level's info when you click the `Edit` button, which should then have a gateway to the level editor, and playing the level when you click the `Play` button). It also needs work to load paths to be played.

    - The path editor is in development

  - `EditPath` is the endpoint where a user should edit a path's info. We are currently working with adding nodes to the path, but the visualization part is ready :)
