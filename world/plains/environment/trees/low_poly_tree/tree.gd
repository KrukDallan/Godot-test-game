extends RigidBody3D

var bark_color : Color = Color(240.0,77.0,0.0,255.0)

# Called when the node enters the scene tree for the first time.
func _ready():
	var new_material = StandardMaterial3D.new()
	new_material.albedo_color = bark_color
	new_material.emission_enabled = false
	$Bark.set_surface_override_material(0,$BarkColorMesh.get_surface_override_material(0).duplicate())
	#$Bark.set_surface_override_material(0, new_material)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var colliders = get_colliding_bodies()
	var should_glow = false
	for collider in colliders:
		if collider.name.contains("Character"):
			should_glow = true
	
	if should_glow:
		glow()
	else:
		stop_glowing()

func get_pushed(source: Vector3) -> void:
	#apply_central_force(-source*100)
	apply_impulse(source*1000, Vector3(0,1,0))
	

func get_pulled() -> void:
	var move_to = position - Character.position
	move_to = move_to.normalized()
	apply_impulse(-move_to*5)
	
func glow():
	$Bark.get_surface_override_material(0).emission_enabled = true
	
func stop_glowing():
	$Bark.get_surface_override_material(0).emission_enabled = false
	
func get_bark_material() -> Material:
	return $Bark.get_surface_override_material(0)
