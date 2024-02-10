extends Node3D

var mob_scene = preload("res://entities/enemies/base_enemy/base_enemy.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	var mob = mob_scene.instantiate()
	$Dungeon.set_start(false)
	$Dungeon/DungeonMesh.set_start(false)
	#add_child(mob)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
