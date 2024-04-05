extends Control

func open_configs(user: String):
	var config_json
	
	var config_path = "res://Scripts/Configs/" + user + ".json"
	var config_file = File.new()
	
	if not config_file.file_exists(config_path):
		# If the file doesn't exist, create an empty JSON
		config_json = {
			"username": Client.UNAME,
			
		}
		var json_string = JSON.print(config_json)
		config_file.open(config_path, File.WRITE)
		config_file.store_string(json_string)
		config_file.close()
		
	else:
		# If the file exists, load its content
		config_file.open(config_path, File.READ)
		var json_string = config_file.get_as_text()
		config_json = JSON.parse(json_string)
		config_file.close()
	
	return config_json

func save_configs(user: String, configs: Dictionary):
	var config_path = "res://Scripts/Configs/" + user + ".json"
	var config_file = File.new()
	
	config_file.open(config_path, File.WRITE)
	var json_string = JSON.print(configs)
	config_file.store_string(json_string)
	config_file.close()

	return "configs saved successfully"
	
