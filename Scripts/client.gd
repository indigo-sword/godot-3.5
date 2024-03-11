extends Control

# class attributes
var LOGGED_IN: bool
var COOKIE: String
var URL: String
var UNAME: String
var ERROR: String
var BIO: String

# signals
signal login_completed
signal logout_completed
signal change_bio_completed

func _init(): 
	self.LOGGED_IN = false
	self.COOKIE = ""
	self.URL = "http://64.225.11.30:8080"
	self.UNAME = ""
	self.ERROR = ""
	self.BIO = ""
	
func login(username: String, password: String):
	if self.LOGGED_IN: 
		self.ERROR = "already logged in"
		return
	self.ERROR = ""
	
	self.UNAME = username
	
	var headers = ["Content-Type: application/x-www-form-urlencoded"]
	var body = "username=" + username + "&password=" + password
	
	$LoginRequest.request(self.URL + "/login", headers, true, HTTPClient.METHOD_POST, body)

func _on_LoginRequest_request_completed(result, response_code, headers, body):
	if response_code == 200:
		for header in headers:
			if "Set-Cookie" in header:
				self.COOKIE = header.split(" ")[1].split(";")[0]
				self.LOGGED_IN = true
				self.ERROR = ""
	
	else: self.ERROR = response_code
	emit_signal("login_completed")
	
func logout():
	if not self.LOGGED_IN:
		self.ERROR = "not logged in"
		return
	self.ERROR = ""
		
	var headers = ["Content-Type: application/x-www-form-urlencoded", "Cookie: " + COOKIE]
	var body = "username=" + self.UNAME 
	
	$LogoutRequest.request(self.URL + "/logout", headers, true, HTTPClient.METHOD_POST, body)
	
func _on_LogoutRequest_request_completed(result, response_code, headers, body):
	var output = parse_json(body.get_string_from_utf8())
	
	if response_code == 200:
		self.LOGGED_IN = false
		self.ERROR = ""
		
	else: self.ERROR = response_code
	emit_signal("logout_completed")

func change_bio(new_bio: String):
	if not(self.LOGGED_IN):
		self.ERROR = "not logged in"
		return
		
	if "&" in new_bio: 
		self.ERROR = "invalid character: &"
		return
	self.ERROR = ""
	
	var headers = ["Content-Type: application/x-www-form-urlencoded", "Cookie: " + COOKIE]
	var body = "username=" + self.UNAME + "&bio=" + new_bio
	
	$ChangeBioRequest.request(URL + "/change_user_bio", headers, true, HTTPClient.METHOD_POST, body)
	
func _on_ChangeBioRequest_request_completed(result, response_code, headers, body):
	var output = parse_json(body.get_string_from_utf8())
	
	if response_code == 200:
		self.BIO = output["bio"]
		self.ERROR = ""
		
	else: self.ERROR = response_code
	emit_signal("change_bio_completed")
