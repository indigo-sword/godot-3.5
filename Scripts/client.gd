extends Control

const GODOT_CLIENT_ERRORS = preload("res://Scripts/client_errors.gd")

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

func _init(): 
	self.LOGGED_IN = false
	self._COOKIE = ""
	self._URL = "http://64.225.11.30:8080"
	self.UNAME = ""
	self.ERROR = ""
	self.ERROR_CODE = 0
	self.BIO = ""
	
func login(username: String, password: String):
	if self.LOGGED_IN: 
		return "Already logged in"
	
	self.UNAME = username
	
	var headers = ["Content-Type: application/x-www-form-urlencoded"]
	var body = "username=" + username + "&password=" + password

	$LoginRequest.request(self._URL + "/login", headers, true, HTTPClient.METHOD_POST, body)
	return ""
	
func _on_LoginRequest_request_completed(result, response_code, headers, body):
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
	
	$LogoutRequest.request(self._URL + "/logout", headers, true, HTTPClient.METHOD_POST, body)
	
	return ""
	
func _on_LogoutRequest_request_completed(result, response_code, headers, body):
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
	
	var headers = ["Content-Type: application/x-www-form-urlencoded"]
	var body = "username=" + username + "&password=" + password + "&email=" + email	
	$CreateUserRequest.request(self._URL + "/create_user", headers, true, HTTPClient.METHOD_POST, body)
	return ""
	
func _on_CreateUserRequest_request_completed(result, response_code, headers, body):
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
	
	$ChangeBioRequest.request(self._URL + "/change_user_bio", headers, true, HTTPClient.METHOD_POST, body)
	return ""
	
func _on_ChangeBioRequest_request_completed(result, response_code, headers, body):
	var output = parse_json(body.get_string_from_utf8())
	
	if response_code == 200:
		self.BIO = output["bio"]
		self.ERROR = ""
		self.ERROR_CODE = 0
		
	else: 
		if result != 0: 
			self.ERROR = GODOT_CLIENT_ERRORS.E.get(result, "unknown error")
			self.ERROR_CODE = result
		else: 
			self.ERROR = output.get("message", "unknown server error")
			self.ERROR_CODE = response_code
			
	emit_signal("change_bio_completed")
