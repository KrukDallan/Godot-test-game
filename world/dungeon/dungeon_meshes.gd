@tool
extends RigidBody3D


func hide_wall_up():
	$NorthernWall.visible = false
	$CollisionShape_up.free()
	
func hide_wall_down():
	$SouthernWall.visible = false
	$CollisionShape_down.free()
	
func hide_wall_left():
	$WesternWall.visible = false
	$CollisionShape_left.free()

func hide_wall_right():
	$EasternWall.visible = false
	$CollisionShape_right.free()
