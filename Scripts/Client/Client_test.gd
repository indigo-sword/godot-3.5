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
	
	var SAMPLE_UNAME = "jvphenares"
	var NEW_USER_1 = RANDOM_UNAME()
	var SAMPLE_PASS = "PASS"
	var err = ""
	var ret = ""

	if Client.LOGGED_IN: 
		assert(Client.logout() == "")
		assert(yield(Client, "logout_completed")["code"] == "200")
		
	#### test login -- SUCCESS
	print("test login -- SUCCESS")
	assert(Client.login(SAMPLE_UNAME, SAMPLE_PASS) == "")
	ret = yield(Client, "login_completed")
	assert(ret.get("code", "not found") == "200")	
	print("ok")
	
	#### test login -- FAIL: already logged in
	print("test login -- FAIL: already logged in")
	assert(Client.login(SAMPLE_UNAME, SAMPLE_PASS) == "already logged in")
	print("ok")

	#### test login -- FAIL: wrong password
	# this was just testing whether we got the right 
	# error messages
	Client.logout()
	yield(Client, "logout_completed")
	
	print("test login -- FAIL: wrong password")
	assert(Client.login(SAMPLE_UNAME, "wrong password") == "")
	ret = yield(Client, "login_completed")
	assert(ret["message"] == "invalid password")
	print("ok")
	
	
	#### test logout -- SUCCESS
	Client.login(SAMPLE_UNAME, SAMPLE_PASS)
	yield(Client, "login_completed")
	
	print("test logout -- SUCCESS")
	assert(Client.logout() == "")
	ret = yield(Client, "logout_completed")
	assert(ret["code"] == "200")
	print("ok")
	
	#### test logout --  FAIL: already logged out
	print("test logout --  FAIL: already logged out")
	assert(Client.logout() == "not logged in")
	print("ok")
	
	#### test create user -- SUCCESS
	print("test create user -- SUCCESS")
	assert(Client.create_user(NEW_USER_1, "PASSWORD", RANDOM_EMAIL()) == "")
	ret = yield(Client, "create_user_completed")
	assert(ret["code"] == "201")
	print("ok")
	
	Client.login(SAMPLE_UNAME, SAMPLE_PASS)
	yield(Client, "login_completed")
		
	#### test change bio -- SUCCESS
	print("test change bio -- SUCCESS")
	
	assert(Client.change_bio("hello this is my new bio") == "")
	ret = yield(Client, "change_bio_completed")
	assert(ret["code"] == "200")
	print("ok")

	#### test change bio -- FAIL: has &
	print("test change bio -- FAIL: has &")
	assert(Client.change_bio("toin & jonas") == "invalid character: &")
	print("ok")
	
	#### test get user -- SUCCESS
	print("test get user -- SUCCESS")
	assert(Client.get_user(SAMPLE_UNAME) == "")
	ret = yield(Client, "get_user_completed")
	assert(ret.get("username", "not found" == SAMPLE_UNAME))
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
	err = Client.create_node("THIS ONE SHOULD WORK", "description", true, false, "res://SavedLevels/test1.tscn")
	assert(err == "")
	ret = yield(Client, "create_node_completed")
	assert(ret.get("message", "not found") == "node created")
	print("ok")
	
	print(err)
	print(ret)
	var node_id = ret["node_id"]
	print(node_id)
	
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

	#### test get node -- SUCCESS
	print("test get node -- SUCCESS")
	assert(Client.get_node_data(node_id) == "")
	ret = yield(Client, "get_node_data_completed")
	assert(ret.get("code", "error") == "200")
	print("ok")
	
	#### test link nodes -- SUCCESS
	err = Client.create_node("title", "description", true, false, "res://SavedLevels/test1.tscn")
	assert(err == "")
	ret = yield(Client, "create_node_completed")
	assert(ret.get("message", "not found") == "node created")
	
	var node2_id = ret["node_id"]
	
	print("test link nodes -- SUCCESS")
	assert(Client.link_nodes(node_id, node2_id, "some description") == "")
	ret = yield(Client, "link_nodes_completed")
	assert(ret.get("code", "error") == "200")
	print("ok")
	
	#### test get next links -- SUCCESS
	print("test get next links -- SUCCESS")
	assert(Client.get_next_links(node_id) == "")
	ret = yield(Client, "get_next_links_completed")
	assert(ret["next_links"][0]["destination_id"] == node2_id)
	print("ok") 
	
	#### test get previous links -- SUCCESS
	print("test get previous links -- SUCCESS")
	assert(Client.get_previous_links(node2_id) == "")
	ret = yield(Client, "get_previous_links_completed")
	assert(ret["previous_links"][0]["origin_id"] == node_id)
	print("ok") 
	
	#### test update playcount -- SUCCESS
	print("test update playcount -- SUCCESS")
	assert(Client.update_playcount(node_id) == "")
	ret = yield(Client, "update_playcount_completed")
	assert(ret.get("code", "error") == "200")
	print("ok")
	
	#### test update rating -- SUCCESS
	print("test update rating -- SUCCESS")
	assert(Client.update_rating(node_id, 7.5) == "")
	ret = yield(Client, "update_rating_completed")
	assert(ret.get("code", "error") == "200")
	print("ok")
	
	#### test update node description -- SUCCESS
	print("test update node description -- SUCCESS")
	assert(Client.update_node_description(node_id, "something") == "")
	ret = yield(Client, "update_node_description_completed")
	assert(ret.get("code", "error") == "200")
	print("ok")
	
	#### test update node title -- SUCCESS
	print("test update node title -- SUCCESS")
	assert(Client.update_node_title(node_id, "DONT UDPATE MY TITLE LOL") == "")
	ret = yield(Client, "update_node_title_completed")
	assert(ret.get("code", "error") == "200")
	print("ok")

	#### test create path -- SUCCESS
	print("test create path -- SUCCESS")
	assert(Client.create_path("complex path", "description") == "")
	ret = yield(Client, "create_path_completed")
	assert(ret.get("code", "error") == "201")
	print("ok")
	
	var path_id = ret["path_id"]
	
	#### test add to path -- SUCCESS
	print("test add to path -- SUCCESS")
	assert(Client.add_to_path(path_id, node_id, 0) == "")
	ret = yield(Client, "add_to_path_completed")
	assert(ret.get("code", "error") == "200")
	print("ok")
	
	
	
	#### test get path info -- SUCCESS
	print("test get path info -- SUCCESS")
	assert(Client.get_path_info(path_id) == "")
	ret = yield(Client, "get_path_info_completed")
	assert(ret.get("code", "error") == "200")
	print("ok")
	
	#### test create path from nodes -- SUCCESS
	err = Client.create_node("THIS ONE", "description", true, false, "res://SavedLevels/test1.tscn")
	assert(err == "")
	ret = yield(Client, "create_node_completed")
	assert(ret.get("message", "not found") == "node created")
	
	var node3_id = ret["node_id"]
	
	err = Client.create_node("THIS TOO", "description", true, false, "res://SavedLevels/test1.tscn")
	assert(err == "")
	ret = yield(Client, "create_node_completed")
	assert(ret.get("message", "not found") == "node created")
	
	var node4_id = ret["node_id"]
	
	assert(Client.get_level(node2_id) == "")
	ret = yield(Client, "get_level_completed")
	
	assert(Client.get_level(node3_id) == "")
	ret = yield(Client, "get_level_completed")
	
	assert(Client.get_level(node4_id) == "")
	ret = yield(Client, "get_level_completed")
	
	print("test create path from nodes -- SUCCESS")
	assert(Client.create_path_from_nodes("a more complex path", "description", [node_id, node2_id, node4_id, node3_id], [0, 1, 2, 1]) == "")
	ret = yield(Client, "create_path_from_nodes_completed")
	assert(ret.get("code", "error") == "201")
	print("ok")
	
	#### test update path playcount -- SUCCESS
	print("test update path playcount -- SUCCESS")
	assert(Client.update_path_playcount(path_id) == "")
	ret = yield(Client, "update_path_playcount_completed")
	assert(ret.get("code", "error") == "200")
	print("ok")
	
	#### test update path rating -- SUCCESS
	print("test update path rating -- SUCCESS")
	assert(Client.update_path_rating(path_id, 5.5) == "")
	ret = yield(Client, "update_path_rating_completed")
	assert(ret.get("code", "error") == "200")
	print("ok")
	
	#### test update path title -- SUCCESS
	print("test update path title -- SUCCESS")
	assert(Client.update_path_title(path_id, "new title yay") == "")
	ret = yield(Client, "update_path_title_completed")
	assert(ret.get("code", "error") == "200")
	print("ok")
	
	#### test update path description -- SUCCESS
	print("test update path description -- SUCCESS")
	assert(Client.update_path_description(path_id, "new description yay") == "")
	ret = yield(Client, "update_path_description_completed")
	assert(ret.get("code", "error") == "200")
	print("ok")
	
	#### test get user paths -- SUCCESS
	print("test get user paths -- SUCCESS")
	assert(Client.get_user_paths(SAMPLE_UNAME) == "")
	ret = yield(Client, "get_user_paths_completed")
	assert(ret.get("code", "error") == "200")
	print("ok")
	
	#### test get node paths -- SUCCESS
	print("test get node paths -- SUCCESS")
	assert(Client.get_node_paths(node_id) == "")
	ret = yield(Client, "get_node_paths_completed")
	assert(ret.get("code", "error") == "200")
	print("ok")
	
	#### test query users -- SUCCESS
	print("test query users -- SUCCESS")
	assert(Client.query_users(SAMPLE_UNAME) == "")
	ret = yield(Client, "query_users_completed")
	assert(ret.get("code", "error") == "200")
	print("ok")
	
	#### test query nodes -- SUCCESS
	print("test query nodes -- SUCCESS")
	assert(Client.query_nodes(SAMPLE_UNAME) == "")
	ret = yield(Client, "query_nodes_completed")
	assert(ret.get("code", "error") == "200")
	print("ok")
	
	#### test query paths -- SUCCESS
	print("test query paths -- SUCCESS")
	assert(Client.query_paths(SAMPLE_UNAME) == "")
	ret = yield(Client, "query_paths_completed")
	assert(ret.get("code", "error") == "200")
	print("ok")
	
	#### test get popular nodes -- SUCCESS
	print("test get popular nodes -- SUCCESS")
	assert(Client.get_popular_nodes() == "")
	ret = yield(Client, "get_popular_nodes_completed")
	assert(ret.get("code", "error") == "200")
	print("ok")
	
	#### test get popular paths -- SUCCESS
	print("test get popular paths -- SUCCESS")
	assert(Client.get_popular_paths() == "")
	ret = yield(Client, "get_popular_paths_completed")
	assert(ret.get("code", "error") == "200")
	print("ok")

