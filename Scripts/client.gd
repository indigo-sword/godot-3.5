extends Control

var URL = "http://64.225.11.30:8080"

var cookie = ""
var username = "LsZCFWRNMl"
var password = "PASS"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func login(username: String, password: String):
	var headers = ["Content-Type: application/x-www-form-urlencoded"]
	var body = "username=" + username + "&password=" + password
	
	$login.request(URL + "/login", headers, HTTPClient.METHOD_POST, body)


func _on_login_request_completed(result, response_code, headers, body):
	var output = JSON.parse_string(body.get_string_from_utf8())
	if response_code == 200:
		for header in headers:
			if "Set-Cookie" in header:
				cookie = header.split(" ")[1].split(";")[0]
				print(cookie)

func _on_login_button_pressed():
	login(username, password)

func change_bio(username: String, new_bio: String):
	var headers = ["Content-Type: application/x-www-form-urlencoded", "Cookie: " + cookie]
	var body = "username=" + username + "&bio=" + new_bio
	
	$changeBio.request(URL + "/change_user_bio", headers, HTTPClient.METHOD_POST, body)
	
func _on_change_bio_button_pressed():
	change_bio(username, "some new bio")

func _on_change_bio_request_completed(result, response_code, headers, body):
	var output = JSON.parse_string(body.get_string_from_utf8())
	var message = output["message"]
	var bio = output["bio"]
	
	print(message, " ", response_code)
	print("new bio: ", bio)
	
	return bio
