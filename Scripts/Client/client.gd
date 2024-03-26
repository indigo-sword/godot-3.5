extends Control

const GODOT_CLIENT_ERRORS = preload("res://Scripts/Client/client_errors.gd")

# class attributes
var LOGGED_IN: bool
var UNAME: String
var BIO: String
var ERROR: String
var ERROR_CODE: int
var _COOKIE: String
var _URL: String

# signals
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
signal get_node_completed
signal link_nodes_completed
signal get_next_links_completed
signal get_previous_links_completed
signal update_playcount_completed
signal update_rating_completed
signal update_node_description_completed
signal update_node_title_completed
signal create_path_completed
signal add_to_path_completed
signal get_path_completed
signal create_path_from_nodes_completed
signal update_path_playcount_completed
signal update_path_rating_completed
signal update_path_title_completed
signal update_path_description_completed
signal get_user_paths_completed
signal get_node_paths_completed

func _init(): 
	randomize()
	self.LOGGED_IN = false
	self._COOKIE = ""
	self._URL = "http://64.225.11.30:8080"
	self.UNAME = ""
	self.ERROR = ""
	self.ERROR_CODE = 0
	self.BIO = ""

func _generate_boundary():
	var boundary = ""
	var characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
	for i in range(32):
		boundary += characters[randi() % characters.length()]
	return boundary

func _default_request_processing(result: int, response_code: int, expected: int, body) -> Dictionary:
	var output = parse_json(body.get_string_from_utf8())

	if response_code != expected:
		if result != 0: 
			output = {"message": GODOT_CLIENT_ERRORS.E.get(result, "unknown error"), "code": String(result)}
		else: 
			output = {"message": output.get("message", "unknown server error"), "code": String(response_code)}
			
	return output
	
func login(username: String, password: String):
	if self.LOGGED_IN: 
		return "Already logged in"
	
	self.UNAME = username
	
	var headers = ["Content-Type: application/x-www-form-urlencoded"]
	var body = "username=" + username + "&password=" + password

	$Login.request(self._URL + "/login", headers, true, HTTPClient.METHOD_POST, body)
	return ""
	
func _on_Login_request_completed(result, response_code, headers, body):
	var output = parse_json(body.get_string_from_utf8())
	var got_cookie = false
	
	if response_code == 200:
		for header in headers:
			if "Set-Cookie" in header:
				self._COOKIE = header.split(" ")[1].split(";")[0]
				self.LOGGED_IN = true
				self.ERROR = ""
				self.ERROR_CODE = 0
				got_cookie = true
		
		if not got_cookie:
			self.ERROR = "server error - no cookie (this should not happen)"

	else: 
		self.UNAME = ""
		if result != 0: 
			self.ERROR = GODOT_CLIENT_ERRORS.E.get(result, "unknown error")
			self.ERROR_CODE = result
		else: 
			self.ERROR = output.get("message", "unknown server error")
			self.ERROR_CODE = response_code
		
	emit_signal("login_completed")
	
	
func logout():
	if not self.LOGGED_IN:
		return "not logged in"
		
	var headers = ["Content-Type: application/x-www-form-urlencoded", "Cookie: " + self._COOKIE]
	var body = "username=" + self.UNAME 
	
	$Logout.request(self._URL + "/logout", headers, true, HTTPClient.METHOD_POST, body)
	
	return ""
	
func _on_Logout_request_completed(result, response_code, headers, body):
	var output = parse_json(body.get_string_from_utf8())
	
	if response_code == 200:
		self.LOGGED_IN = false
		self.ERROR = ""
		self.ERROR_CODE = 0
		
	else: 
		if result != 0: 
			self.ERROR = GODOT_CLIENT_ERRORS.E.get(result, "unknown error")
			self.ERROR_CODE = result
		else: 
			self.ERROR = output.get("message", "unknown server error")
			self.ERROR_CODE = response_code
			
	emit_signal("logout_completed")
	
	
func create_user(username: String, password: String, email: String):	
	if "&" in username or "&" in password or "&" in email:
		return "invalid character: &"
		
	# TODO: maybe check login here
	var headers = ["Content-Type: application/x-www-form-urlencoded"]
	var body = "username=" + username + "&password=" + password + "&email=" + email	
	$CreateUser.request(self._URL + "/create_user", headers, true, HTTPClient.METHOD_POST, body)
	return ""
	
func _on_CreateUser_request_completed(result, response_code, headers, body):
	var output = parse_json(body.get_string_from_utf8())
	if response_code == 201:
		self.ERROR = ""
		self.ERROR_CODE = 0	
		
	else:
		if result != 0: 
			self.ERROR = GODOT_CLIENT_ERRORS.E.get(result, "unknown error")
			self.ERROR_CODE = result
		else:
			self.ERROR = output.get("message", "unknown server error")
			self.ERROR_CODE = response_code
	
	emit_signal("create_user_completed")

func change_bio(new_bio: String):
	if not(self.LOGGED_IN):
		return "not logged in"
		
	if "&" in new_bio: 
		return "invalid character: &"
	
	var headers = ["Content-Type: application/x-www-form-urlencoded", "Cookie: " + self._COOKIE]
	var body = "username=" + self.UNAME + "&bio=" + new_bio
	
	$ChangeBio.request(self._URL + "/change_user_bio", headers, true, HTTPClient.METHOD_POST, body)
	return ""
	
func _on_ChangeBio_request_completed(result, response_code, headers, body):
	var output = parse_json(body.get_string_from_utf8())
	
	if response_code == 200:
		self.BIO = output["bio"]
		self.ERROR = ""
		self.ERROR_CODE = 0
	else: 
		if result != 0: 
			self.ERROR = GODOT_CLIENT_ERRORS.E.get(result, "unknown error")
			self.ERROR_CODE = result
			output = GODOT_CLIENT_ERRORS.E.get(result, "unknown error") + " " + String(result)
		else: 
			self.ERROR = output.get("message", "unknown server error")
			self.ERROR_CODE = response_code
			output = output.get("message", "unknown server error") + " " + String(response_code)
			
	emit_signal("change_bio_completed", output)
	
func get_user(username: String):
	var headers = ["Content-Type: application/x-www-form-urlencoded"]
	var body = "username=" + username
	
	$GetUser.connect("request_completed", self, "_on_GetUser_request_completed")
	$GetUser.request(self._URL + "/get_user", headers, true, HTTPClient.METHOD_GET, body)
	
	return ""

func _on_GetUser_request_completed(result, response_code, headers, body):
	var output = parse_json(body.get_string_from_utf8())
	
	if response_code == 200:
		self.ERROR = ""
		self.ERROR_CODE = 0
	else:
		if result != 0: 
			self.ERROR = GODOT_CLIENT_ERRORS.E.get(result, "unknown error")
			self.ERROR_CODE = result
			output = GODOT_CLIENT_ERRORS.E.get(result, "unknown error") + " " + String(result)
		else: 
			self.ERROR = output.get("message", "unknown server error")
			self.ERROR_CODE = response_code
			output = output.get("message", "unknown server error") + " " + String(response_code)
	
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
	

