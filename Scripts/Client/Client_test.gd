extends Node2D

func RANDOM_UNAME():
	var l = 15
	var characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_"
	var uname = ""
	for i in range(l):
		uname += characters[rand_range(0, characters.length())]

	return uname

func RANDOM_EMAIL():
	var uname = RANDOM_UNAME()
	return uname + "@gmail.com"
	
func _on_login_pressed():
	randomize()
	
	var SAMPLE_UNAME = "LsZCFWRNMl"
	var NEW_USER_1 = RANDOM_UNAME()
	var SAMPLE_PASS = "PASS"
	var err = ""
	var ret = ""
	
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
	var t = Client.create_user(NEW_USER_1, "PASSWORD", RANDOM_EMAIL())
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
		print("TESTING ERROR: got error at client when should not have ", Client.ERROR)
		return
		
	print("ok")

	#### test change bio -- FAIL: has &
	print("test change bio -- FAIL: has &")
	err = Client.change_bio("toin & jonas")
	if err != "invalid character: &": 
		print("TESTING ERROR: got no error when should have")
		
	print("ok")
	
	#### test get user -- SUCCESS
	print("test get user -- SUCCESS")
	err = Client.get_user(SAMPLE_UNAME)
	if err == "": 
		ret = yield(Client, "get_user_completed")
		assert(ret.get("username", "not found" == SAMPLE_UNAME))
	else: 
		print("TESTING ERROR: got error when should not have ", err)
		return
		
	if Client.ERROR: 
		print("TESTING ERROR: got error at client when should not have ", Client.ERROR)
		return
	
	print("ok")
	
	#### test follow user -- SUCCESS
	print("test follow user -- SUCCESS")
	assert(Client.follow_user(NEW_USER_1) == "")
	ret = yield(Client, "follow_user_completed")
	assert(ret.get("message", "not found") == "user followed")	
	print("ok")
	
	#### test unfollow user -- SUCCESS
	print("test unfollow user -- SUCCESS")
	err = Client.unfollow_user(NEW_USER_1)
	assert(err == "")
	ret = yield(Client, "unfollow_user_completed")
	assert(ret.get("message", "not found") == "user unfollowed")
	print("ok")

	#### test get follows -- SUCCESS
	# refollowing to have something
	print("test get follows -- SUCCESS")
	assert(Client.follow_user(NEW_USER_1) == "")
	ret = yield(Client, "follow_user_completed")
	assert(ret.get("message", "not found") == "user followed")	
	
	err = Client.get_follows(NEW_USER_1)
	assert(err == "")
	ret = yield(Client, "get_follows_completed")
	assert(ret["followed"][0] == SAMPLE_UNAME)
	
	print("ok")
	
	#### test create node -- SUCCESS
	print("test create node -- SUCCESS")
	err = Client.create_node("title", "description", true, false, "res://SavedLevels/test1.tscn")
	assert(err == "")
	ret = yield(Client, "create_node_completed")
	assert(ret.get("message", "not found") == "node created")
	print("ok")

	var node_id = ret["node_id"]
	
	#### test get level -- SUCCESS
	print("test get level -- SUCCESS")
	assert(Client.get_level(node_id) == "")
	ret = yield(Client, "get_level_completed")
	assert(ret.get("message", "error") == "level")
	print("ok")
	
	#### test get level -- FAIL: no level found
	print("test get level -- FAIL: no level found")
	assert(Client.get_level("aaa") == "")
	ret = yield(Client, "get_level_completed")
	assert(ret.get("message", "error") == "node not found")
	print("ok")
	
	#### test update node level -- SUCCESS
	print("test update node level -- SUCCESS")
	assert(Client.update_node_level(node_id, "res://SavedLevels/test1.tscn") == "")	
	ret = yield(Client, "update_node_level_completed")
	assert(ret.get("message", "error") == "level updated")
	print("ok")
