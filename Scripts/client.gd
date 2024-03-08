extends Control

#### IMPORTANT: we should use a variable to detect anywhere 
#### in the game whether the user is logged in.
#### how do we do that? i'm using globals for the moment
var LOGGED_IN = false
var COOKIE = ""
var URL = "http://64.225.11.30:8080"

# for testing purposes
var SAMPLE_UNAME = "LsZCFWRNMl"
var SAMPLE_PASS = "PASS"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass 
	
func login(username: String, password: String):
	var headers = ["Content-Type: application/x-www-form-urlencoded"]
	var body = "username=" + username + "&password=" + password
	
	return $LoginRequest.request(URL + "/login", headers, HTTPClient.METHOD_POST, body)

func _on_LoginRequest_request_completed(result, response_code, headers, body):
	var output = JSON.parse_string(body.get_string_from_utf8())
	if response_code == 200:
		for header in headers:
			if "Set-Cookie" in header:
				COOKIE = header.split(" ")[1].split(";")[0]
				print(COOKIE)
	
	return COOKIE 
	
func change_bio(username: String, new_bio: String):
	var headers = ["Content-Type: application/x-www-form-urlencoded", "Cookie: " + COOKIE]
	var body = "username=" + username + "&bio=" + new_bio
	
	return $ChangeBioRequest.request(URL + "/change_user_bio", headers, HTTPClient.METHOD_POST, body)

func _on_ChangeBioRequest_request_completed(result, response_code, headers, body):
	var output = JSON.parse_string(body.get_string_from_utf8())
	var message = output["message"]
	var bio = output["bio"]
	
	print(message, " ", response_code)
	print("new bio: ", bio)
	
	return bio
