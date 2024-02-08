@tool
extends Node3D

@export var grid_map_path : NodePath = NodePath("$../GridMap")
@onready var gridmap : GridMap = get_node(grid_map_path)

@export var start : bool = false : set = set_start
func set_start(val:bool)->void:
	if Engine.is_editor_hint():
		create_dungeon()
		
var dun_cell_scene : PackedScene = preload("res://world/dungeon/dungeon_tiles.tscn") #should use "dungeon cell",
																					# so the blocks you want to use

var directions : Dictionary = {
	"up" : Vector3i.FORWARD, "down" : Vector3i.BACK,
	"left" : Vector3i.LEFT, "right" : Vector3i.RIGHT
}
		
func create_dungeon():
	for c in get_children():
		remove_child(c)
		c.queue_free()
	
	for cell in gridmap.get_used_cells():
		var cell_index : int = gridmap.get_cell_item(cell)
		if cell_index <=2 && cell_index >=0:
			var dun_cell : Node3D = dun_cell_scene.instantiate()
			dun_cell.position = Vector3(cell) + Vector3(0.5,0,0.5)
			add_child(dun_cell)
			dun_cell.set_owner(owner)
			# to be finished
