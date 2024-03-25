### Client
- The Client class is a singleton, meaning it is always spawned and can be used anytime at the game. 
#### Attributes
- The Client has internal and external attributes. Internal attributes start with an underscore (_). Check them:
  - LOGGED_IN (bool): whether the player is logged in, gets set on login and logout
  - UNAME (String): username of player, gets set when player logs in
  - ERROR (String): gets filled if the server returns an error to the client upon making a request (but not when the user makes an invalid client call, check that down below)
  - ERROR_CODE (String): gets filled with server error code when server returns an error
  - _COOKIE (String): cookie used to maintain session with server
  - _URL (String): server URL

#### Functions
- Each function is related to a server endpoint. If you want to know more about the server, check [project octopus](https://github.com/indigo-sword/project-octopus). Check them:
  - login(username: String, password: String): logs user in
  - logout(): logs user out
  - create_user(username: String, password: String, email: String): creates a user
  - change_bio(new_bio: String): changes the bio

#### How the client works
- The Godot client is practically manual, so we need to do everything here. What each function does is basically:
  - Checking if there are any errors when it gets called (i.e. calling login when you are already logged in returns an error)
  - Setting internal attributes (i.e. in login UNAME)
  - Setting headers (they should **almost** always be the same, with the exception of endpoints that receive files)
  - Setting body
    - The body is set with variables following this pattern: [variable_name]=[variable_value]&[variable2_name]=[variable2_value]&...
  - Calling its HTTPRequest module to run a request with the right methods
  - Returning "" (or no error)
  - The HTTPRequest module will run its code in parallel, and this creates some situations we will explain in the how to use section.

- The HTTPRequest module will, after completing its request, run the _on_[REQUEST]_request_completed function. It will:
  - Get the server's response
  - Set attributes if response is good
  - Else, it will set errors
  - Finally, it will emit a signal that it's finished

#### How to use the client
- Check Scripts/Client_test.gd and Scenes/Client_test.tscn (it is a scene that just runs the test) for an example
- Basically, you will follow login's commented example below. Just remember that each function has its [function]_completed signal.
```bash
err = Client.login(SAMPLE_UNAME, SAMPLE_PASS)    # err will return whether the client was rightfully called
if err == "":                                    # no error on calling the client
  yield(Client, "login_completed")               # yield() will make your code only return when the client finishes making the request
else:                                            # here you would have a CLIENT CALL error 
  return "The client didn't like your answer"

if Client.ERROR != "":                           # here you would have a SERVER returned error
  return "The server didn't like your answer"
```

