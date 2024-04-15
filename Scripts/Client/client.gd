extends Control

const GODOT_CLIENT_ERRORS = preload("res://Scripts/Client/client_errors.gd")

# ATTRIBUTES
var LOGGED_IN: bool
var UNAME: String
var EMAIL: String
var FOLLOWING: int
var FOLLOWERS: int
var BIO: String
var _COOKIE: String
var _URL: String

# SIGNALS
signal login_completed
signal logout_completed
signal change_bio_completed
signal create_user_completed
signal get_user_completed
signal follow_user_completed
signal unfollow_user_completed
signal get_follows_completed
signal create_node_completed
signal get_level_completed
signal update_node_level_completed
signal get_node_data_completed
signal link_nodes_completed
signal get_next_links_completed
signal get_previous_links_completed
signal update_playcount_completed
signal update_rating_completed
signal update_node_description_completed
signal update_node_title_completed
signal create_path_completed
signal add_to_path_completed
signal get_path_info_completed
signal create_path_from_nodes_completed
signal update_path_playcount_completed
signal update_path_rating_completed
signal update_path_title_completed
signal update_path_description_completed
signal get_user_paths_completed
signal get_node_paths_completed
signal query_users_completed
signal query_nodes_completed
signal query_paths_completed
signal get_popular_nodes_completed
signal get_popular_paths_completed

#### INTERNAL FUNCTIONS
func _init(): 
	randomize()
	self.LOGGED_IN = false
	self._COOKIE = ""
	self._URL = "http://64.225.11.30:8080"
	self.UNAME = ""
	self.BIO = ""
	self.EMAIL = ""
	self.FOLLOWING = 0
	self.FOLLOWERS = 0

func _generate_boundary():
	var boundary = ""
	var characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
	for i in range(32):
		boundary += characters[randi() % characters.length()]
	return boundary

func _default_request_processing(result: int, response_code: int, expected: int, body) -> Dictionary:
	var output = parse_json(body.get_string_from_utf8())
	output["code"] = String(response_code)

	if response_code != expected:
		if result != 0: 
			output = {"message": GODOT_CLIENT_ERRORS.E.get(result, "unknown error"), "code": String(result)}
		else: 
			output = {"message": output.get("message", "unknown server error"), "code": String(response_code)}
			
	return output
	
#### CLIENT INTERFACES
func login(username: String, password: String):
	if self.LOGGED_IN: return "already logged in"

	var headers = ["Content-Type: application/x-www-form-urlencoded"]
	var body = "username=" + username + "&password=" + password
	
	$Login.connect("request_completed", self, "_on_Login_request_completed")
	$Login.request(self._URL + "/login", headers, true, HTTPClient.METHOD_POST, body)
	return ""
	
func _on_Login_request_completed(result, response_code, headers, body):
	var output = _default_request_processing(result, response_code, 200, body)
	
	if response_code == 200:
		self.LOGGED_IN = true
		self.UNAME = output["username"]
		self.BIO = output["bio"]
		self.EMAIL = output["email"]
		self.FOLLOWING = output["following"]
		self.FOLLOWERS = output["followers"]

		for header in headers:
			if "Set-Cookie" in header:
				self._COOKIE = header.split(" ")[1].split(";")[0]
				
	Configs.open_configs(self.UNAME)
	
	emit_signal("login_completed", output)
	
	
func logout():
	if not self.LOGGED_IN: return "not logged in"
		
	var headers = ["Content-Type: application/x-www-form-urlencoded", "Cookie: " + self._COOKIE]
	var body = "username=" + self.UNAME 
	
	$Logout.connect("request_completed", self, "_on_Logout_request_completed")
	$Logout.request(self._URL + "/logout", headers, true, HTTPClient.METHOD_POST, body)
	return ""
	
func _on_Logout_request_completed(result, response_code, headers, body):
	var output = _default_request_processing(result, response_code, 200, body)
	if response_code == 200: self.LOGGED_IN = false
	emit_signal("logout_completed", output)
	
	
func create_user(username: String, password: String, email: String):	
	if "&" in username or "&" in password or "&" in email: return "invalid character: &"
	if self.LOGGED_IN: return "already logged in"	
	
	var headers = ["Content-Type: application/x-www-form-urlencoded"]
	var body = "username=" + username + "&password=" + password + "&email=" + email	
	
	$CreateUser.connect("request_completed", self, "_on_CreateUser_request_completed")
	$CreateUser.request(self._URL + "/create_user", headers, true, HTTPClient.METHOD_POST, body)
	return ""
	
func _on_CreateUser_request_completed(result, response_code, headers, body):
	var output = _default_request_processing(result, response_code, 201, body)	
	emit_signal("create_user_completed", output)


func change_bio(new_bio: String):
	if not(self.LOGGED_IN): return "not logged in"
	if "&" in new_bio: return "invalid character: &"
	
	var headers = ["Content-Type: application/x-www-form-urlencoded", "Cookie: " + self._COOKIE]
	var body = "username=" + self.UNAME + "&bio=" + new_bio
	
	$ChangeBio.connect("request_completed", self, "_on_ChangeBio_request_completed")
	$ChangeBio.request(self._URL + "/change_user_bio", headers, true, HTTPClient.METHOD_POST, body)
	return ""
	
func _on_ChangeBio_request_completed(result, response_code, headers, body):
	var output = _default_request_processing(result, response_code, 200, body)		
	if output.get("code", "not found") == "200": 
		self.BIO = output.get("bio", "bio not found")
		
	emit_signal("change_bio_completed", output)
	
func get_user(username: String):
	var headers = ["Content-Type: application/x-www-form-urlencoded"]
	var body = "username=" + username
	
	$GetUser.connect("request_completed", self, "_on_GetUser_request_completed")
	$GetUser.request(self._URL + "/get_user", headers, true, HTTPClient.METHOD_GET, body)
	
	return ""

func _on_GetUser_request_completed(result, response_code, headers, body):
	var output = _default_request_processing(result, response_code, 200, body)
	emit_signal("get_user_completed", output)
	
	
func follow_user(followed_username: String):
	if not self.LOGGED_IN: return "not logged in"
	
	var headers = ["Content-Type: application/x-www-form-urlencoded", "Cookie: " + self._COOKIE]
	var body = "username=" + self.UNAME + "&followed_username=" + followed_username
	
	$FollowUser.connect("request_completed", self, "_on_FollowUser_request_completed")
	$FollowUser.request(self._URL + "/follow_user", headers, true, HTTPClient.METHOD_POST, body)
	
	return ""
	
func _on_FollowUser_request_completed(result, response_code, headers, body):
	var output = _default_request_processing(result, response_code, 200, body)
	emit_signal("follow_user_completed", output)


func unfollow_user(unfollowed_username: String):
	if not self.LOGGED_IN: return "not logged in"
	
	var headers = ["Content-Type: application/x-www-form-urlencoded", "Cookie: " + self._COOKIE]
	var body = "username=" + self.UNAME + "&unfollowed_username=" + unfollowed_username
	
	$UnfollowUser.connect("request_completed", self, "_on_UnfollowUser_request_completed")
	$UnfollowUser.request(self._URL + "/unfollow_user", headers, true, HTTPClient.METHOD_POST, body)

	return ""
	
func _on_UnfollowUser_request_completed(result, response_code, headers, body):
	var output = _default_request_processing(result, response_code, 200, body)
	emit_signal("unfollow_user_completed", output)
	
	
func get_follows(username: String):
	var headers = ["Content-Type: application/x-www-form-urlencoded"]
	var body = "username=" + username
	
	$GetFollows.connect("request_completed", self, "_on_GetFollows_request_completed")
	$GetFollows.request(self._URL + "/get_follows", headers, true, HTTPClient.METHOD_GET, body)
	
	return ""
	
func _on_GetFollows_request_completed(result, response_code, headers, body):
	var output = _default_request_processing(result, response_code, 200, body)
	emit_signal("get_follows_completed", output)
 

func create_node(title: String, description: String, is_initial: bool, is_final: bool, file_path: String):
	if not self.LOGGED_IN: return "not logged in"
	
	var boundary = _generate_boundary()

	var body = "--" + boundary + "\r\n"
	
	var file = File.new()
	var file_opened = file.open(file_path, File.READ)
	if file_opened != 0: 
		return "Error opening file: " + file_path 
	
	var file_contents = file.get_as_text()
	file.close()
	
	body += 'Content-Disposition: form-data; name="username"\r\n\r\n'
	body += self.UNAME + "\r\n"
	body += "--" + boundary + "\r\n"
	
	body += 'Content-Disposition: form-data; name="title"\r\n\r\n'
	body += title + "\r\n"
	body += "--" + boundary + "\r\n"
	
	body += 'Content-Disposition: form-data; name="description"\r\n\r\n'
	body += description + "\r\n"
	body += "--" + boundary + "\r\n"
	
	body += 'Content-Disposition: form-data; name="is_initial"\r\n\r\n'
	body += str(is_initial) + "\r\n"
	body += "--" + boundary + "\r\n"
	
	body += 'Content-Disposition: form-data; name="is_final"\r\n\r\n'
	body += str(is_final) + "\r\n"
	body += "--" + boundary + "\r\n"
	
	body += 'Content-Disposition: form-data; name="file"; filename="' + file_path.get_file() + '"\r\n'
	body += "Content-Type: application/octet-stream\r\n\r\n"
	body += file_contents
	body += "\r\n"
	body += "--" + boundary + "--"
	
	var headers = ["Content-Type: multipart/form-data; boundary=" + boundary, "Cookie: " + self._COOKIE]
	
	$CreateNode.connect("request_completed", self, "_on_CreateNode_request_completed")
	$CreateNode.request(self._URL + "/create_node", headers, true, HTTPClient.METHOD_POST, body)

	return "" 
	
func _on_CreateNode_request_completed(result, response_code, headers, body):
	var output = _default_request_processing(result, response_code, 201, body)
	if output.get("code", "not found") == "200":
		Configs.add_level(output["node_id"])
		
	emit_signal("create_node_completed", output)
	
	
func get_level(node_id: String):
	var headers = ["Content-Type: application/x-www-form-urlencoded"]
	var body = "node_id=" + node_id
	
	$GetLevel.connect("request_completed", self, "_on_GetLevel_request_completed")
	$GetLevel.request(self._URL + "/get_level", headers, true, HTTPClient.METHOD_GET, body)
	
	return ""
	
func _on_GetLevel_request_completed(result, response_code, headers, body):
	var output = _default_request_processing(result, response_code, 200, body)
	
	if response_code == 200:
		ensureDirectoryExists("res://SavedLevels/")
		var file_path = "res://SavedLevels/" + output["node_id"] + ".tscn"
		var file = File.new()
		file.open(file_path, File.WRITE)
		file.store_string(output["level"])
		file.close()
		
	emit_signal("get_level_completed", output)
	
	
func update_node_level(node_id: String, file_path: String):
	if not self.LOGGED_IN: return "not logged in"
	
	var file = File.new()
	var file_opened = file.open(file_path, File.READ)
	if file_opened != 0: 
		return "Error opening file: " + file_path 
	
	var file_contents = file.get_as_text()
	file.close()
	
	var boundary = _generate_boundary()
	var body = "--" + boundary + "\r\n"
	body += 'Content-Disposition: form-data; name="username"\r\n\r\n'
	body += self.UNAME + "\r\n"
	body += "--" + boundary + "\r\n"
	
	body += 'Content-Disposition: form-data; name="node_id"\r\n\r\n'
	body += node_id + "\r\n"
	body += "--" + boundary + "\r\n"
	
	body += 'Content-Disposition: form-data; name="file"; filename="' + file_path.get_file() + '"\r\n'
	body += "Content-Type: application/octet-stream\r\n\r\n"
	body += file_contents
	body += "\r\n"
	body += "--" + boundary + "--"
	
	var headers = ["Content-Type: multipart/form-data; boundary=" + boundary, "Cookie: " + self._COOKIE]
	
	$UpdateNodeLevel.connect("request_completed", self, "_on_UpdateNodeLevel_request_completed")
	$UpdateNodeLevel.request(self._URL + "/update_node_level", headers, true, HTTPClient.METHOD_POST, body)
	
	return ""
	
func _on_UpdateNodeLevel_request_completed(result, response_code, headers, body):
	var output = _default_request_processing(result, response_code, 200, body)
	emit_signal("update_node_level_completed", output)

	
func get_node_data(node_id: String):
	var headers = ["Content-Type: application/x-www-form-urlencoded"]
	var body = "node_id=" + node_id
	
	$GetNode.connect("request_completed", self, "_on_GetNodeData_request_completed")
	$GetNode.request(self._URL + "/get_node", headers, true, HTTPClient.METHOD_GET, body)
	
	return ""

func _on_GetNodeData_request_completed(result, response_code, headers, body):
	var output = _default_request_processing(result, response_code, 200, body)
	emit_signal("get_node_data_completed", output)
	
	
func link_nodes(origin_id: String, destination_id: String, description: String):
	if not self.LOGGED_IN: return "not logged in"
	
	var headers = ["Content-Type: application/x-www-form-urlencoded", "Cookie: " + self._COOKIE]
	var body = "username=" + self.UNAME + "&origin_id=" + origin_id + "&destination_id=" + destination_id + "&description=" + description
	
	$LinkNodes.connect("request_completed", self, "_on_LinkNodes_request_completed")
	$LinkNodes.request(self._URL + "/link_nodes", headers, true, HTTPClient.METHOD_POST, body)
	
	return ""

func _on_LinkNodes_request_completed(result, response_code, headers, body):
	var output = _default_request_processing(result, response_code, 200, body)
	emit_signal("link_nodes_completed", output)


func get_next_links(node_id: String):
	var headers = ["Content-Type: application/x-www-form-urlencoded"]
	var body = "node_id=" + node_id
	
	$GetNextLinks.connect("request_completed", self, "_on_GetNextLinks_request_completed")
	$GetNextLinks.request(self._URL + "/get_next_links", headers, true, HTTPClient.METHOD_GET, body)
	
	return ""
	
func _on_GetNextLinks_request_completed(result, response_code, headers, body):
	var output = _default_request_processing(result, response_code, 200, body)
	emit_signal("get_next_links_completed", output)


func get_previous_links(node_id: String):
	var headers = ["Content-Type: application/x-www-form-urlencoded"]
	var body = "node_id=" + node_id
	
	$GetNextLinks.connect("request_completed", self, "_on_GetPreviousLinks_request_completed")
	$GetNextLinks.request(self._URL + "/get_previous_links", headers, true, HTTPClient.METHOD_GET, body)
	
	return ""
	
func _on_GetPreviousLinks_request_completed(result, response_code, headers, body):
	var output = _default_request_processing(result, response_code, 200, body)
	emit_signal("get_previous_links_completed", output)


func update_playcount(node_id: String):
	var headers = ["Content-Type: application/x-www-form-urlencoded"]
	var body = "node_id=" + node_id
	
	$UpdatePlaycount.connect("request_completed", self, "_on_UpdatePlaycount_request_completed")
	$UpdatePlaycount.request(self._URL + "/update_playcount", headers, true, HTTPClient.METHOD_POST, body)
	
	return ""
	
func _on_UpdatePlaycount_request_completed(result, response_code, headers, body):
	var output = _default_request_processing(result, response_code, 200, body)
	emit_signal("update_playcount_completed", output)


func update_rating(node_id: String, rating: float):
	if not self.LOGGED_IN: return "not logged in"
	if rating < 0.0 or rating > 10.0: return "invalid rating"
	
	var headers = ["Content-Type: application/x-www-form-urlencoded", "Cookie: " + self._COOKIE]
	var body = "username=" + self.UNAME + "&node_id=" + node_id + "&rating=" + String(rating)
	
	$UpdateRating.connect("request_completed", self, "_on_UpdateRating_request_completed")
	$UpdateRating.request(self._URL + "/update_rating", headers, true, HTTPClient.METHOD_POST, body)
	
	return ""
	
func _on_UpdateRating_request_completed(result, response_code, headers, body):
	var output = _default_request_processing(result, response_code, 200, body)
	emit_signal("update_rating_completed", output)
	
	
func update_node_description(node_id: String, description: String):
	if not self.LOGGED_IN: return "not logged in"
	if "&" in description: return "forbidden character: &"
	
	var headers = ["Content-Type: application/x-www-form-urlencoded", "Cookie: " + self._COOKIE]
	var body = "username=" + self.UNAME + "&node_id=" + node_id + "&description=" + description
	
	$UpdateNodeDescription.connect("request_completed", self, "_on_UpdateNodeDescription_request_completed")
	$UpdateNodeDescription.request(self._URL + "/update_node_description", headers, true, HTTPClient.METHOD_POST, body)
	
	return ""
	
func _on_UpdateNodeDescription_request_completed(result, response_code, headers, body):
	var output = _default_request_processing(result, response_code, 200, body)
	emit_signal("update_node_description_completed", output)
	
	
func update_node_title(node_id: String, title: String):
	if not self.LOGGED_IN: return "not logged in"
	if "&" in title: return "forbidden character: &"
	
	var headers = ["Content-Type: application/x-www-form-urlencoded", "Cookie: " + self._COOKIE]
	var body = "username=" + self.UNAME + "&node_id=" + node_id + "&title=" + title
	
	$UpdateNodeTitle.connect("request_completed", self, "_on_UpdateNodeTitle_request_completed")
	$UpdateNodeTitle.request(self._URL + "/update_node_title", headers, true, HTTPClient.METHOD_POST, body)
	
	return ""
	
func _on_UpdateNodeTitle_request_completed(result, response_code, headers, body):
	var output = _default_request_processing(result, response_code, 200, body)
	emit_signal("update_node_title_completed", output)
	
	
func create_path(title: String, description: String):
	if not self.LOGGED_IN: return "not logged in"
	if "&" in title or "&" in description: return "forbidden character: &"
	
	var headers = ["Content-Type: application/x-www-form-urlencoded", "Cookie: " + self._COOKIE]
	var body = "username=" + self.UNAME + "&title=" + title + "&description=" + description
	
	$CreatePath.connect("request_completed", self, "_on_CreatePath_request_completed")
	$CreatePath.request(self._URL + "/create_path", headers, true, HTTPClient.METHOD_POST, body)
	
	return ""
	
func _on_CreatePath_request_completed(result, response_code, headers, body):
	var output = _default_request_processing(result, response_code, 201, body)
	emit_signal("create_path_completed", output)
	

func add_to_path(path_id: String, node_id: String, position: int):
	if position < 0: return "invalid position (must be 0 or larger)"
	if not self.LOGGED_IN: return "not logged in"
	
	var headers = ["Content-Type: application/x-www-form-urlencoded", "Cookie: " + self._COOKIE]
	var body = "username=" + self.UNAME + "&path_id=" + path_id + "&node_id=" + node_id + "&position=" + String(position)
	
	$AddToPath.connect("request_completed", self, "_on_AddToPath_request_completed")
	$AddToPath.request(self._URL + "/add_to_path", headers, true, HTTPClient.METHOD_POST, body)
	
	return ""

func _on_AddToPath_request_completed(result, response_code, headers, body):
	var output = _default_request_processing(result, response_code, 200, body)
	emit_signal("add_to_path_completed", output)


func get_path_info(path_id: String):
	var headers = ["Content-Type: application/x-www-form-urlencoded"]
	var body = "path_id=" + path_id
	
	$GetPath.connect("request_completed", self, "_on_GetPath_request_completed")
	$GetPath.request(self._URL + "/get_path", headers, true, HTTPClient.METHOD_GET, body)
	
	return ""

func _on_GetPath_request_completed(result, response_code, headers, body):
	var output = _default_request_processing(result, response_code, 200, body)
	emit_signal("get_path_info_completed", output)


func create_path_from_nodes(title: String, description: String, nodes: Array, positions: Array):
	if len(nodes) == 0: return "must be non-empty array"
	if len(positions) != len(nodes): return "nodes and positions size must match"
	if not self.LOGGED_IN: return "Not logged in"
	
	var headers = ["Content-Type: application/x-www-form-urlencoded", "Cookie: " + self._COOKIE]
	var body = "username=" + self.UNAME + "&title=" + title + "&description=" + description
	
	for node in nodes:
		body += "&node_ids=" + node
		
	for position in positions:
		body += "&positions=" + String(position)
		
	$CreatePathFromNodes.connect("request_completed", self, "_on_CreatePathFromNodes_request_completed")
	$CreatePathFromNodes.request(self._URL + "/create_path_from_nodes", headers, true, HTTPClient.METHOD_POST, body)
	
	return ""
	
func _on_CreatePathFromNodes_request_completed(result, response_code, headers, body):
	var output = _default_request_processing(result, response_code, 201, body)
	emit_signal("create_path_from_nodes_completed", output)
	

func update_path_playcount(path_id: String):
	var headers = ["Content-Type: application/x-www-form-urlencoded"]
	var body = "path_id=" + path_id
	
	$UpdatePathPlaycount.connect("request_completed", self, "_on_UpdatePathPlaycount_request_completed")
	$UpdatePathPlaycount.request(self._URL + "/update_path_playcount", headers, true, HTTPClient.METHOD_POST, body)
	
	return ""

func _on_UpdatePathPlaycount_request_completed(result, response_code, headers, body):
	var output = _default_request_processing(result, response_code, 200, body)
	emit_signal("update_path_playcount_completed", output)
	

func update_path_rating(path_id: String, rating: float):
	if not self.LOGGED_IN: return "not logged in"
	
	if rating < 0.0 or rating > 10.0: return "invalid rating"
	
	var headers = ["Content-Type: application/x-www-form-urlencoded", "Cookie: " + self._COOKIE]
	var body = "username=" + self.UNAME + "&path_id=" + path_id + "&rating=" + String(rating)
	
	$UpdatePathRating.connect("request_completed", self, "_on_UpdatePathRating_request_completed")
	$UpdatePathRating.request(self._URL + "/update_path_rating", headers, true, HTTPClient.METHOD_POST, body)
	
	return ""
	
func _on_UpdatePathRating_request_completed(result, response_code, headers, body):
	var output = _default_request_processing(result, response_code, 200, body)
	emit_signal("update_path_rating_completed", output)
	

func update_path_title(path_id: String, title: String):
	if not self.LOGGED_IN: return "not logged in"
	var headers = ["Content-Type: application/x-www-form-urlencoded", "Cookie: " + self._COOKIE]
	var body = "username=" + self.UNAME + "&path_id=" + path_id + "&title=" + title
	
	$UpdatePathTitle.connect("request_completed", self, "_on_UpdatePathTitle_request_completed")
	$UpdatePathTitle.request(self._URL + "/update_path_title", headers, true, HTTPClient.METHOD_POST, body)
	
	return ""
	
func _on_UpdatePathTitle_request_completed(result, response_code, headers, body):
	var output = _default_request_processing(result, response_code, 200, body)
	emit_signal("update_path_title_completed", output)


func update_path_description(path_id: String, description: String):
	if not self.LOGGED_IN: return "not logged in"
	var headers = ["Content-Type: application/x-www-form-urlencoded", "Cookie: " + self._COOKIE]
	var body = "username=" + self.UNAME + "&path_id=" + path_id + "&description=" + description
	
	$UpdatePathDescription.connect("request_completed", self, "_on_UpdatePathDescription_request_completed")
	$UpdatePathDescription.request(self._URL + "/update_path_description", headers, true, HTTPClient.METHOD_POST, body)
	
	return ""
	
func _on_UpdatePathDescription_request_completed(result, response_code, headers, body):
	var output = _default_request_processing(result, response_code, 200, body)
	emit_signal("update_path_description_completed", output)


func get_user_paths(username: String):
	var headers = ["Content-Type: application/x-www-form-urlencoded"]
	var body = "username=" + username
	
	$GetUserPaths.connect("request_completed", self, "_on_GetUserPaths_request_completed")
	$GetUserPaths.request(self._URL + "/get_user_paths", headers, true, HTTPClient.METHOD_GET, body)
	
	return ""
	
func _on_GetUserPaths_request_completed(result, response_code, headers, body):
	var output = _default_request_processing(result, response_code, 200, body)
	emit_signal("get_user_paths_completed", output)
	

func get_node_paths(node_id: String):
	var headers = ["Content-Type: application/x-www-form-urlencoded"]
	var body = "node_id=" + node_id
	
	$GetNodePaths.connect("request_completed", self, "_on_GetNodePaths_request_completed")
	$GetNodePaths.request(self._URL + "/get_node_paths", headers, true, HTTPClient.METHOD_GET, body)
	
	return ""
	
func _on_GetNodePaths_request_completed(result, response_code, headers, body):
	var output = _default_request_processing(result, response_code, 200, body)
	emit_signal("get_node_paths_completed", output)
	

func query_users(query: String):
	var headers = ["Content-Type: application/x-www-form-urlencoded"]
	var body = "query=" + query
	
	$QueryUsers.connect("request_completed", self, "_on_QueryUsers_request_completed")
	$QueryUsers.request(self._URL + "/query_users", headers, true, HTTPClient.METHOD_GET, body)
	
	return ""

func _on_QueryUsers_request_completed(result, response_code, headers, body):
	var output = _default_request_processing(result, response_code, 200, body)
	emit_signal("query_users_completed", output)

func query_nodes(query: String):
	var headers = ["Content-Type: application/x-www-form-urlencoded"]
	var body = "query=" + query
	
	$QueryNodes.connect("request_completed", self, "_on_QueryNodes_request_completed")
	$QueryNodes.request(self._URL + "/query_nodes", headers, true, HTTPClient.METHOD_GET, body)
	
	return ""
	
func _on_QueryNodes_request_completed(result, response_code, headers, body):
	var output = _default_request_processing(result, response_code, 200, body)
	emit_signal("query_nodes_completed", output)
	
func query_paths(query: String):
	var headers = ["Content-Type: application/x-www-form-urlencoded"]
	var body = "query=" + query
	
	$QueryPaths.connect("request_completed", self, "_on_QueryPaths_request_completed")
	$QueryPaths.request(self._URL + "/query_paths", headers, true, HTTPClient.METHOD_GET, body)
	
	return ""
	
func _on_QueryPaths_request_completed(result, response_code, headers, body):
	var output = _default_request_processing(result, response_code, 200, body)
	emit_signal("query_paths_completed", output)


func get_popular_nodes():
	var headers = ["Content-Type: application/x-www-form-urlencoded"]
	
	var body = ""
	
	$GetPopularNodes.connect("request_completed", self, "_on_GetPopularNodes_request_completed")
	$GetPopularNodes.request(self._URL + "/get_popular_nodes", headers, true, HTTPClient.METHOD_GET, body)
	
	return ""
	
func _on_GetPopularNodes_request_completed(result, response_code, headers, body):
	var output = _default_request_processing(result, response_code, 200, body)
	emit_signal("get_popular_nodes_completed", output)
	
	
func get_popular_paths():
	var headers = ["Content-Type: application/x-www-form-urlencoded"]
	
	var body = ""
	
	$GetPopularPaths.connect("request_completed", self, "_on_GetPopularPaths_request_completed")
	$GetPopularPaths.request(self._URL + "/get_popular_paths", headers, true, HTTPClient.METHOD_GET, body)
	
	return ""
	
func _on_GetPopularPaths_request_completed(result, response_code, headers, body):
	var output = _default_request_processing(result, response_code, 200, body)
	emit_signal("get_popular_paths_completed", output)


func ensureDirectoryExists(dir_path: String):
	var dir = Directory.new()
	
	# Check if the directory exists
	if not dir.dir_exists(dir_path):
		# Directory doesn't exist, create it
		var result = dir.make_dir(dir_path)
		if result == OK:
			print("Directory created:", dir_path)
		else:
			print("Failed to create directory:", dir_path)
	else:
		print("Directory already exists:", dir_path)
