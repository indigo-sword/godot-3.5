extends Node2D

func RANDOM_UNAME():
	var l = 60
	var characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_"
	var uname = ""
	for i in range(l):
		uname += characters[rand_range(0, characters.length())]
	return uname

func RANDOM_PASS():
	var l = 25
	var characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_!@#$%^*()-+=[]{}|;:,.<>?`~"
	var password = ""
	for i in range(l):
		password += characters[rand_range(0, characters.length())]
	return password

func RANDOM_EMAIL():
	var uname = RANDOM_UNAME()
	return uname + "@gmail.com"
	
func _on_login_pressed():
	var SAMPLE_UNAME = "LsZCFWRNMl"
	var SAMPLE_PASS = "PASS"
	var err = ""
	
	#### test login -- SUCCESS
	print("test login -- SUCCESS") 
	err = Client.login(SAMPLE_UNAME, SAMPLE_PASS)
	if err == "": yield(Client, "login_completed")
	else: 
		print("TESTING ERROR: got error at function: ", err)
		return
	
	if Client.ERROR != "": 
		print("TESTING ERROR: got error at client: ", Client.ERROR)
		return
	
	print("ok")
	
	#### test login -- FAIL: already logged in
	print("test login -- FAIL: already logged in")
	err = Client.login(SAMPLE_UNAME, SAMPLE_PASS)
	if err != "Already logged in": 
		print("TESTING ERROR: got wrong error: ", err)
		return

	if Client.ERROR != "": 
		print("TESTING ERROR: got error at client: ", Client.ERROR)
		return
	
	print("ok")
	
	#### test login -- FAIL: wrong password
	# this was just testing whether we got the right 
	# error messages
	print("test login -- FAIL: wrong password")
	
	err = Client.logout()
	yield(Client, "logout_completed")
	if Client.LOGGED_IN: 
		print("TESTING ERROR - logout function")
		return
		
	err = Client.login(SAMPLE_UNAME, "wrong password")
	if err == "": yield(Client, "login_completed")
	
	if Client.ERROR != "invalid password":
		print("TESTING ERROR: got wrong error at client: ", Client.ERROR)
		return
		
	if Client.ERROR_CODE != 401:
		print("TESTING ERROR: got wrong error code at client: ", Client.ERROR_CODE)
		
	print("ok")
	
	#### test logout -- SUCCESS
	err = Client.login(SAMPLE_UNAME, SAMPLE_PASS)
	if err == "": yield(Client, "login_completed")
	
	print("test logout -- SUCCESS")
	err = Client.logout()
	if err == "": yield(Client, "logout_completed")
	
	if Client.ERROR != "": 
		print("TESTING ERROR: got error at client: ", Client.ERROR)
		return
		
	print("ok")
	
	#### test logout --  FAIL: already logged out
	print("test logout --  FAIL: already logged out")
	err = Client.logout()
	if err != "not logged in":
		print("TESTING ERROR: no error when should have")
		return
		
	print("ok")
	
	err = Client.login(SAMPLE_UNAME, SAMPLE_PASS)
	if err == "": yield(Client, "login_completed")
	
	#### test create user -- SUCCESS
	print("test create user -- SUCCESS")
	var t = Client.create_user(RANDOM_UNAME(), RANDOM_PASS(), RANDOM_EMAIL())
	if t == "": yield(Client, "create_user_completed")
	else:
		print("TESTING ERROR: got error when should not have")
		return
	
	if Client.ERROR_CODE != 0:
		print("TESTING ERROR: got error in client when should not have")
		print(Client.ERROR)
		return
	
	print("ok")
		
	#### test change bio -- SUCCESS
	print("test change bio -- SUCCESS")
	
	err = Client.change_bio("hello this is my new bio")
	if err == "": yield(Client, "change_bio_completed")
	else: 
		print("TESTING ERROR: got error ", err)
		return
	
	if Client.ERROR != "": 
		print("TESTING ERROR: got error when should not have ", Client.ERROR)
		return
		
	print("ok")

	#### test change bio -- FAIL: has &
	print("test change bio -- FAIL: has &")
	err = Client.change_bio("toin & jonas")
	if err != "invalid character: &": 
		print("TESTING ERROR: got no error when should have")
		
	print("ok")
