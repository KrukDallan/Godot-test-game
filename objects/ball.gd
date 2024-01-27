extends RigidBody3D

var direction = Vector3.ZERO

const speed = 10.0

# Called when the node enters the scene tree for the first time.
func _ready():
	apply_impulse(transform.basis*Vector3(0,0,-speed)*20, Vector3(0,1,0))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass#move_and_collide(transform.basis*Vector3(0,0,-speed)* delta) 

func set_direction(dir: Vector3) -> void:
	direction = dir
	
