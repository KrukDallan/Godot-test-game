@tool
extends Node3D


@onready var mesh = get_node("dungeon_meshes")
@export var start : bool = false : set = set_start
func set_start(val:bool)->void:
	print(mesh.get_child(0))
