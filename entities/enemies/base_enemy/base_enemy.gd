extends RigidBody3D

# 191 -286 x
#545 -28

var moving_threshold : float = 0.0
var move_to = Vector3.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	# random integer between -280 and 180.
	var rand_x = (randi() % 460 - 280) + 0.0
	var rand_z = (randi() % 500 - 20) + 0.0
	position = Vector3(rand_x, $MeshInstance3D.mesh.size.y +100, rand_z)
	move_to = position - Character.position
	move_to = -move_to.normalized()
	apply_impulse(move_to*50)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	move_to = position - Character.position
	move_to = move_to.normalized()
	if moving_threshold > 3*delta:
		apply_impulse(-move_to * delta * 800)
		moving_threshold = 0.0
	moving_threshold += delta
	
	var colliders = get_colliding_bodies()
	for collider in colliders:
		if collider.is_in_group("Ball"):
			$SubViewport/ProgressBar.value = $SubViewport/ProgressBar.value - 5
			if $SubViewport/ProgressBar.value <= 0:
				die()
			
			
func die():
	queue_free()


