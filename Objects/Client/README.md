### Client

- The Client class is a singleton, meaning it is always spawned and can be used anytime at the game.

#### Attributes

- The Client has internal and external attributes. Internal attributes start with an underscore (\_). Check them:

  - LOGGED_IN (bool): whether the player is logged in, gets set on login and logout
  - UNAME (String): username of player, gets set when player logs in
  - EMAIL (String): email of player, gets set when player logs in
  - FOLLOWING (int): number of people the player is following, gets set when player logs in
  - FOLLOWERS (int): number of people following the player, gets set when player logs in
  - BIO (String): bio of player, gets set when player logs in
  - \_COOKIE (String): cookie used to maintain session with server
  - \_URL (String): server URL

#### Functions

- Each function is related to a server endpoint. If you want to know more about the server, check [project octopus](https://github.com/indigo-sword/project-octopus). Check them:

  | function                                                                                             | description                                      | API endpoint             |
  | ---------------------------------------------------------------------------------------------------- | ------------------------------------------------ | ------------------------ |
  | \_generate_boundary()                                                                                | generates a boundary for file sending            |                          |
  | \_default_request_processing()                                                                       | preprocesses any request for the other functions |                          |
  | \_init()                                                                                             | initializes the client                           |                          |
  | login(username: String, password: String)                                                            | logs user in                                     | /login                   |
  | logout()                                                                                             | logs user out                                    | /logout                  |
  | create_user(username: String, password: String, email: String)                                       | creates a user                                   | /create_user             |
  | change_bio(new_bio: String)                                                                          | changes the bio                                  | /change_user_bio         |
  | get_user(username: String)                                                                           | gets user info                                   | /get_user                |
  | follow_user(followed_username: String)                                                               | follows a user                                   | /follow_user             |
  | unfollow_user(unfollowed_username: String)                                                           | unfollows a user                                 | /unfollow_user           |
  | get_follows(username: String)                                                                        | gets who the user follows                        | /get_follows             |
  | create_node(title: String, description: String, is_initial: bool, is_final: bool, file_path: String) | creates a node                                   | /create_node             |
  | get_level(node_id: String)                                                                           | downloads a level                                | /get_level               |
  | update_node_level(node_id: String, file_path: String)                                                | updates a node's level                           | /update_node_level       |
  | get_node_data(node_id: String)                                                                       | gets a node's data                               | /get_node                |
  | link_nodes(origin_id: String, destination_id: String, description: String)                           | links two nodes                                  | /link_nodes              |
  | get_next_links(node_id: String)                                                                      | gets the next links of a node                    | /get_next_links          |
  | get_previous_links(node_id: String)                                                                  | gets the previous links of a node                | /get_previous_links      |
  | update_playcount(node_id: String)                                                                    | updates the playcount of a node                  | /update_playcount        |
  | update_rating(node_id: String, rating: float)                                                        | updates the rating of a node                     | /update_rating           |
  | update_node_description(node_id: String, description: String)                                        | updates the description of a node                | /update_node_description |
  | update_node_title(node_id: String, title: String)                                                    | updates the title of a node                      | /update_node_title       |
  | create_path(title: String, description: String)                                                      | creates a path                                   | /create_path             |
  | add_to_path(path_id: String, node_id: String, position: int)                                         | adds a node to a path                            | /add_to_path             |
  | get_path_info(path_id: String)                                                                       | gets a path's info                               | /get_path                |
  | create_path_from_nodes(title: String, description: String, nodes: Array, positions: Array)           | creates a path from nodes                        | /create_path_from_nodes  |
  | update_path_playcount(path_id: String)                                                               | updates the playcount of a path                  | /update_path_playcount   |
  | update_path_rating(path_id: String, rating: float)                                                   | updates the rating of a path                     | /update_path_rating      |
  | update_path_title(path_id: String, title: String)                                                    | updates the title of a path                      | /update_path_title       |
  | update_path_description(path_id: String, description: String)                                        | updates the description of a path                | /update_path_description |
  | get_user_paths(username: String)                                                                     | gets the paths of a user                         | /get_user_paths          |
  | get_node_paths(node_id: String)                                                                      | gets the paths of a node                         | /get_node_paths          |
  | query_users(query: String)                                                                           | queries users                                    | /query_users             |
  | query_nodes(query: String)                                                                           | queries nodes                                    | /query_nodes             |
  | query_paths(query: String)                                                                           | queries paths                                    | /query_paths             |
  | get_popular_nodes()                                                                                  | gets the popular nodes                           | /get_popular_nodes       |
  | get_popular_paths()                                                                                  | gets the popular paths                           | /get_popular_paths       |

#### How the client works

- The Godot client is practically manual, so we need to do everything here. What each function does is basically:

  - Checking if there are any errors when it gets called (i.e. calling login when you are already logged in returns an error)

  - Setting headers (they should **almost** always be the same, with the exception of endpoints that receive files)

  - Setting body

    - The body is set with variables following this pattern: [variable_name]=[variable_value]&[variable2_name]=[variable2_value]&...

  - Calling its HTTPRequest module to run a request with the right methods

  - Returning "" (or no error)

  - The HTTPRequest module will run its code in parallel, and this creates some situations we will explain in the how to use section.

- The HTTPRequest module will, after completing its request, run the _on_[REQUEST]\_request_completed function. It will:
  - Get the server's response
  - Parse it using \_default_request_processing()
  - Do some optional actions (like setting the cookie on login)
  - Finally, it will emit a signal that it's finished, alongside with the server's output from your request.

#### How to use the client

- Check Scripts/Client_test.gd and Scenes/Client_test.tscn (it is a scene that just runs the test) for an example. You can also check the menu's codes that use the client extensively.
- Basically, you will follow login's commented example below. Just remember that each function has its [function]\_completed signal, so you need to yield at some point.

```bash
var err = Client.login(SAMPLE_UNAME, SAMPLE_PASS) # err will return whether the client was rightfully called
if err != "":                                    # client error
  print("client error: ", err)
  return

var ret = yield(Client, "login_completed") # waits for the signal to be emitted
if ret.get("code", "") != "200":           # server error
  print("server error: ", ret)
  return

# continue the code using ret
```
