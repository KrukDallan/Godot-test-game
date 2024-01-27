extends RigidBody3D

var direction = Vector3.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	apply_impulse(-direction*200, Vector3(0,1,0))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func set_direction(dir: Vector3) -> void:
	direction = dir
	
