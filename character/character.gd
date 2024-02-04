extends RigidBody3D

var _input := Vector3.ZERO
# builds up velocity
var _incremental_speed : float = 1.0
var dash_factor : float = 2.0
var shooting_threshold : float = 0.0

var mouse_sensitivity := 0.001
var twist_input := 0.0
var pitch_input := 0.0

var twist_pivot
var pitch_pivot 
var raycast 
var groundcast 

@onready var detector = $TwistPivot/PitchPivot/Detector

@export var jump_impulse = 50
# The downward acceleration when in the air, in meters per second squared.
@export var fall_acceleration = 9.81
@export var fall_addendum = 0.0

# Load ball
var ball = preload("res://objects/ball.tscn")
var shooted : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	twist_pivot = $TwistPivot
	pitch_pivot = $TwistPivot/PitchPivot
	raycast = $TwistPivot/PitchPivot/RayCast3D 
	groundcast = $GroundCast


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	shooting_threshold += delta
	if !groundcast.is_colliding():
		var downward_force_y = - fall_acceleration*delta - fall_addendum
		
		apply_central_force(Vector3(0,downward_force_y,0))
		fall_addendum += delta*50
	else:
		fall_addendum = 0.0
		

	var input := Vector3.ZERO
	input.x = Input.get_axis("ui_left", "ui_right")
	input.z = Input.get_axis("ui_up", "ui_down")
	_input = twist_pivot.basis * input * 15.0 * delta * _incremental_speed * dash_factor
	
	var collision = move_and_collide(_input)
	if collision != null:
		if collision.get_collider().is_in_group("Tree"):
			pass#collision.get_collider().get_pushed(_input)
		elif collision.get_collider().is_in_group("Ball"):
			collision.get_collider().get_pushed(_input*0.5)
		_incremental_speed = 1.0
	else:
		_incremental_speed += 0.5*delta
		if _incremental_speed > 2.0:
			_incremental_speed = 2.0

	#if not is_on_floor(): # If in the air, fall towards the floor. Literally gravity
			#position.y = position.y - (fall_acceleration * delta)
			
	if Input.is_action_pressed("shoot") and shooting_threshold > 5*delta:
		shooting_threshold = 0.0
		var instanced = ball.instantiate()
		instanced.position = raycast.global_position
		instanced.transform.basis = raycast.global_transform.basis
		get_tree().get_root().add_child(instanced)
	
	twist_pivot.rotate_y(twist_input)
	pitch_pivot.rotate_x(pitch_input)
	pitch_pivot.rotation.x = clamp($TwistPivot/PitchPivot.rotation.x, -1.0, 1.0)
	
	twist_input = 0.0
	pitch_input = 0.0
	
	if Input.is_key_pressed(KEY_SPACE):
		apply_central_impulse(Vector3(0,3,0))
		
	for i in detector.get_overlapping_bodies():
		if i.name.contains("Tree"):
			i.glow()
			if Input.is_key_pressed(KEY_E):
				i.get_pulled()



func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			twist_input = -event.relative.x * mouse_sensitivity
			pitch_input = - event.relative.y * mouse_sensitivity
	
	elif Input.is_action_pressed("dash"):
		dash_factor = 2.0
	else:
		dash_factor = 1.0
		
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

			


