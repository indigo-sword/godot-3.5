extends TextureRect

var color_effect = Color(1, 0, 0, 1) 

# Called when the node enters the scene tree for the first time.
func _ready():
	var shader_code = """
		shader_type canvas_item;
		
		uniform vec4 new_color : hint_color;
		uniform float blur_amount = 4.0; 

		void fragment() {
			vec2 uv = UV;
			vec4 original_color = texture(TEXTURE, uv);

			vec4 colored = original_color * new_color;

			vec4 sum = vec4(0.0);
			float total = 0.0;
			for (int x = -4; x <= 4; x++) {
				for (int y = -4; y <= 4; y++) {
					float weight = exp(-(x*x + y*y) / (2.0 * blur_amount));
					sum += texture(TEXTURE, uv + vec2(x, y) * 0.004) * weight; 
					total += weight;
				}
			}
			COLOR = (sum / total) * colored;
		}
	"""
	
	# Create Shader and ShaderMaterial
	var shader = Shader.new()
	shader.code = shader_code
	var material = ShaderMaterial.new()
	material.shader = shader
	material.set_shader_param("new_color", color_effect)
	material.set_shader_param("blur_amount", 4.0) # Adjust as necessary

	# Assign material to the TextureRect
	self.material = material


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
