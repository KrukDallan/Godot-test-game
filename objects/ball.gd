extends RigidBody3D

var direction = Vector3.ZERO

const speed = 15.0

# Called when the node enters the scene tree for the first time.
func _ready():
	apply_impulse(transform.basis*Vector3(0,0,-speed)*20, Vector3(0,1,0))
	$Timer.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if $Timer.time_left == 0.0:
		queue_free()

func get_pushed(source: Vector3) -> void:
	#apply_central_force(-source*100)
	apply_impulse(source*1000, Vector3(0,1,0))
	

	
