
extends Node3D

@export var grid_map_path : NodePath 
@onready var gridmap : GridMap = get_node(grid_map_path)

@export var start : bool = false : set = set_start
func set_start(val:bool)->void:
	#if Engine.is_editor_hint():
	create_dungeon()
		
var dun_cell_scene : PackedScene = preload("res://world/dungeon/dungeon_meshes.tscn") #should use "dungeon cell",
																					# so the blocks you want to use

var directions : Dictionary = {
	"up" : Vector3i.FORWARD, "down" : Vector3i.BACK,
	"left" : Vector3i.LEFT, "right" : Vector3i.RIGHT
}
# if cell is border
func handle_none(cell:RigidBody3D, dir:String):
	pass#cell.call("hide_wall_"+dir)
	
func handle_00(cell:RigidBody3D, dir:String):
	cell.call("hide_wall_"+dir)
func handle_01(cell:RigidBody3D, dir:String):
	cell.call("hide_wall_"+dir)
func handle_02(cell:RigidBody3D, dir:String):
	cell.call("hide_wall_"+dir)
func handle_10(cell:RigidBody3D, dir:String):
	cell.call("hide_wall_"+dir)		
func handle_11(cell:RigidBody3D, dir:String):
	cell.call("hide_wall_"+dir)		
func handle_12(cell:RigidBody3D, dir:String):
	cell.call("hide_wall_"+dir)
func handle_20(cell:RigidBody3D, dir:String):
	cell.call("hide_wall_"+dir)
func handle_21(cell:RigidBody3D, dir:String):
	cell.call("hide_wall_"+dir)
func handle_22(cell:RigidBody3D, dir:String):
	cell.call("hide_wall_"+dir)
	
			
func create_dungeon():
	for c in get_children():
		remove_child(c)
		c.queue_free()
	var t: int = 0
	for cell in gridmap.get_used_cells():
		var cell_index : int = gridmap.get_cell_item(cell)
		if cell_index <=2 && cell_index >=0:
			var dun_cell : RigidBody3D = dun_cell_scene.instantiate()
			dun_cell.position = Vector3(cell) + Vector3(0.5,0,0.5)
			add_child(dun_cell)
			t +=1
			#dun_cell.set_owner(owner)
			
			for i in 4:
				var cell_n : Vector3i = cell + directions.values()[i]
				var cell_n_index : int = gridmap.get_cell_item(cell_n)
				if cell_n_index == -1 || cell_n_index == 3:
					handle_none(dun_cell, directions.keys()[i])
				else:
					var key: String = str(cell_index) + str(cell_n_index)
					call("handle_"+key, dun_cell, directions.keys()[i])
			if t%10 == 9:
				await get_tree().create_timer(0).timeout
