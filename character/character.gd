extends RigidBody3D

var _input := Vector3.ZERO
# builds up velocity
var _incremental_speed : float = 1.0

var mouse_sensitivity := 0.001
var twist_input := 0.0
var pitch_input := 0.0
var mouse_coord := Vector3(0,0,0)

@onready var twist_pivot := $TwistPivot
@onready var pitch_pivot := $TwistPivot/PitchPivot
@onready var raycast := $TwistPivot/PitchPivot/RayCast3D

# load ball
var ball = preload("res://objects/ball.tscn")
var shooted : bool = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	shooted = false
	var input := Vector3.ZERO
	input.x = Input.get_axis("ui_left", "ui_right")
	input.z = Input.get_axis("ui_up", "ui_down")
	_input = twist_pivot.basis * input * 15.0 * delta * _incremental_speed
	var collision = move_and_collide(_input)
	if collision != null:
		if collision.get_collider().is_in_group("Tree"):
			collision.get_collider().get_pushed(_input)
		_incremental_speed = 1.0
	else:
		_incremental_speed += 0.5*delta
		if _incremental_speed > 2.0:
			_incremental_speed = 2.0
	
	
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	twist_pivot.rotate_y(twist_input)
	pitch_pivot.rotate_x(pitch_input)
	pitch_pivot.rotation.x = clamp($TwistPivot/PitchPivot.rotation.x, -0.4, 0.6)
	
	twist_input = 0.0
	pitch_input = 0.0
	
	
	
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			twist_input = -event.relative.x * mouse_sensitivity
			pitch_input = - event.relative.y * mouse_sensitivity
			mouse_coord = Vector3(0, event.relative.y,event.relative.x)
	elif Input.is_action_pressed("shoot") and shooted == false:
		shooted = true
		var instanced = ball.instantiate()
		instanced.position = raycast.global_position
		instanced.transform.basis = raycast.global_transform.basis
		#instanced.set_direction(twist_pivot.basis*Vector3(0,0,1))
		get_tree().get_root().add_child(instanced)

			


