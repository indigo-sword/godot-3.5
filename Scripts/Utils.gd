extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	randomize() # Initialize the random number generator
	print(generate_uuid())

func generate_uuid_part(length: int) -> String:
	var characters = "0123456789abcdef" # Hexadecimal characters
	var result = ""
	for i in range(length):
		result += characters[randi() % characters.length()]
	return result

# Function to generate a UUID
func generate_uuid() -> String:
	return "%s-%s-4%s-b%s-%s" % [
		generate_uuid_part(8), # 8 characters
		generate_uuid_part(4), # 4 characters
		generate_uuid_part(3), # 3 characters (after the '4' indicating the UUID version)
		generate_uuid_part(3), # 3 characters (after the 'b' indicating the variant)
		generate_uuid_part(12) # 12 characters
	]

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
