extends Node2D

func _on_login_pressed():
	var SAMPLE_UNAME = "LsZCFWRNMl"
	var SAMPLE_PASS = "PASS"
	
	# test login
	print("LOGIN:")
	Client.login(SAMPLE_UNAME, SAMPLE_PASS)
	if not Client.ERROR: yield(Client, "login_completed")
	
	if not Client.LOGGED_IN or Client.ERROR != "": print(Client.ERROR)
	else: print("ok")
	
	# test login fail
	print("LOGIN ALREADY LOGGED IN:")
	Client.login(SAMPLE_UNAME, SAMPLE_PASS)
	if not Client.ERROR: yield(Client, "login_completed")
	if Client.ERROR != "already logged in": print(Client.ERROR)
	else: print("ok")
	
	# test logout
	print("LOGOUT:")
	Client.logout()
	if not Client.ERROR: yield(Client, "logout_completed")
	
	if Client.LOGGED_IN or Client.ERROR != "": print(Client.ERROR)
	else: print("ok")
	
	# test logout fail
	print("LOGOUT ALREADY LOGGED OUT:")
	Client.logout()
	if not Client.ERROR: yield(Client, "logout_completed")
	if Client.ERROR != "not logged in": print(Client.ERROR)
	else: print("ok")
	
	Client.login(SAMPLE_UNAME, SAMPLE_PASS)
	if not Client.ERROR: yield(Client, "login_completed")
	
	# test change bio
	print("CHANGE BIO:")
	
	Client.change_bio("hello this is my new bio")
	if not Client.ERROR: yield(Client, "change_bio_completed")
	
	if Client.ERROR != "": print(Client.ERROR)
	else: print("ok")
	
	# test change bio fail
	print("CHANGE BIO WITH &:")
	Client.change_bio("toin & jonas")
	
	if Client.ERROR != "invalid character: &": print(Client.ERROR)
	else: print("ok")
