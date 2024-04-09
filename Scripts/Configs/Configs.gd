extends Control

var username: String
var levels: Array

func _init():
	self.username = ""
	self.levels = []

func clear():
	self.username = ""
	self.levels = []
	
func open_configs(user: String):
	var config_json
	var json_string
	
	var config_path = "res://Scripts/Configs/" + user + ".json"
	var config_file = File.new()
	
	if not config_file.file_exists(config_path):
		# If the file doesn't exist, create an empty JSON
		config_json = {
			"username": user,
			"levels": []
		}
		json_string = JSON.print(config_json)
		config_file.open(config_path, File.WRITE)
		config_file.store_string(json_string)
		config_file.close()
		
	else:
		# If the file exists, load its content
		config_file.open(config_path, File.READ)
		json_string = config_file.get_as_text()
		config_json = JSON.parse(json_string).result
		config_file.close()
	
	self.username = user
	self.levels = config_json["levels"]
	
	return ""

func save_configs(user: String, configs: Dictionary):
	var config_path = "res://Scripts/Configs/" + user + ".json"
	var config_file = File.new()
	
	config_file.open(config_path, File.WRITE)
	var json_string = JSON.print(configs)
	config_file.store_string(json_string)
	config_file.close()

	return ""
	
func add_level(user: String, level_id: String):
	var json_string
	var config_json
	
	var config_path = "res://Scripts/Configs/" + user + ".json"
	var config_file = File.new()
	
	# if file does not exist
	if not config_file.file_exists(config_path):
		# create configs
		config_json = {
			"username": user,
			"levels": [level_id]
		}
		json_string = JSON.print(config_json)
		
		# store
		config_file.open(config_path, File.WRITE)
		config_file.store_string(json_string)
		config_file.close()
	
	else:
		# read current configs
		config_file.open(config_path, File.READ)
		json_string = config_file.get_as_text()
		config_json = JSON.parse(json_string)
		config_file.close()
		
		# change stuff
		config_json["levels"] = config_json.get("levels", [])
		config_json["levels"].append(level_id)
		
		# write
		config_file.open(config_path, File.WRITE)
		json_string = JSON.print(config_json)
		config_file.store_string(json_string)
		config_file.close()

	return ""
