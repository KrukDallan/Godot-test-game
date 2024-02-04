extends RigidBody3D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func get_pushed(source: Vector3) -> void:
	#apply_central_force(-source*100)
	apply_impulse(source*1000, Vector3(0,1,0))
	

func get_pulled() -> void:
	var move_to = position - Character.position
	move_to = move_to.normalized()
	apply_impulse(-move_to*5)
	
func glow():
	$Tree_lp_11.get_surface_override_material(0).emission_enabled = true
	
func stop_glowing():
	pass
