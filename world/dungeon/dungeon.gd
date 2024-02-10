

extends Node3D
@onready var grid_map : GridMap = $GridMap
@onready var dungeonmesh : Node3D = $DungeonMesh
func _ready():
	set_start(false)
	dungeonmesh.set_start(false)
	Character.position = get_starting_position()

var starting_pos : Vector3 = Vector3.ZERO
func get_starting_position():
	return starting_pos



@export var start : bool = false : set = set_start
func set_start(val:bool)->void:
	if Engine.is_editor_hint():
		generate()
	
@export_range(0,1) var edge_survival_chance	: float = 0.25
@export var border_size : int = 20 : set = set_border_size
func set_border_size(val: int)->void:
	border_size = val	
	if Engine.is_editor_hint():
		visualize_border()
		
# number of rooms		
@export var room_number : int = 4
# minimum distance between rooms
@export var room_margin : int = 1
@export var room_recursion : int = 15
@export var min_room_size : int = 2
@export var max_room_size : int = 4
@export_multiline var custom_seed : String = "" : set = set_seed
func set_seed(val:String)->void:
	custom_seed = val
	seed(val.hash())

var room_tiles : Array[PackedVector3Array] = []
var room_positions : PackedVector3Array = []
	
func visualize_border():
	if Engine.is_editor_hint():
		grid_map.clear()
	for i in range(-1, border_size +1):
		grid_map.set_cell_item(Vector3i(i,0, -1), 3)
		grid_map.set_cell_item(Vector3i(i,0, border_size), 3)
		grid_map.set_cell_item(Vector3i(border_size,0, i), 3)
		grid_map.set_cell_item(Vector3i(-1,0, i), 3)
		

func generate():
	room_tiles.clear()
	room_positions.clear()
	if custom_seed : set_seed(custom_seed)
	visualize_border()
	for i in room_number:
		make_room(room_recursion)
	
	var rpv2 : PackedVector2Array = []
	var delaunay_graph : AStar2D = AStar2D.new()
	# minimum spanning tree
	var mst_graph : AStar2D = AStar2D.new()
	
	for p in room_positions:
		rpv2.append(Vector2(p.x, p.z))
		delaunay_graph.add_point(delaunay_graph.get_available_point_id(),Vector2(p.x, p.z))
		mst_graph.add_point(mst_graph.get_available_point_id(),Vector2(p.x, p.z))
		
	var delaunay : Array = Array(Geometry2D.triangulate_delaunay(rpv2))
	
	for i in delaunay.size()/3:
		var p1 : int = delaunay.pop_front()
		var p2 : int = delaunay.pop_front()
		var p3 : int = delaunay.pop_front()
		
		delaunay_graph.connect_points(p1,p2)
		delaunay_graph.connect_points(p2,p3)
		delaunay_graph.connect_points(p1,p3)
		
	var visited_points : PackedInt32Array = []
	visited_points.append(randi() % room_positions.size())
	
	while visited_points.size() != mst_graph.get_point_count():
		var possible_connections : Array[PackedInt32Array] = []
		for vp in visited_points:
			for connection in delaunay_graph.get_point_connections(vp):
				if !visited_points.has(connection):
					var con : PackedInt32Array = [vp,connection]
					possible_connections.append(con)
					
		var connection : PackedInt32Array = possible_connections.pick_random()
		for pc in possible_connections:
			if rpv2[pc[0]].distance_squared_to(rpv2[pc[1]]) <\
			 rpv2[connection[0]].distance_squared_to(rpv2[connection[1]]):
				connection = pc
		visited_points.append(connection[1])
		mst_graph.connect_points(connection[0], connection[1])
		var tmp : Vector2 = mst_graph.get_point_position(randi() % mst_graph.get_point_count())
		starting_pos = Vector3(tmp.x, 1, tmp.y)
		print("starting pos setted")
		delaunay_graph.disconnect_points(connection[0], connection[1])
	
	var hallway_graph : AStar2D = mst_graph
	
	for p in delaunay_graph.get_point_ids():
		for c in delaunay_graph.get_point_connections(p):
			if c>p:
				var kill : float = randf()
				if edge_survival_chance > kill:
					hallway_graph.connect_points(p,c)
	create_hallways(hallway_graph)
	
func create_hallways(hallway_graph : AStar2D):
	var hallways : Array[PackedVector3Array] = []
	for p in hallway_graph.get_point_ids():
		for c in hallway_graph.get_point_connections(p):
			if c>p:
				var room_from : PackedVector3Array = room_tiles[p]
				var room_to : PackedVector3Array = room_tiles[c]
				var tile_from : Vector3 = room_from[0]
				var tile_to : Vector3 = room_to[0]
				for tile in room_from:
					if tile.distance_squared_to(room_positions[c])<\
					tile_from.distance_squared_to(room_positions[c]):
						tile_from = tile
				for tile in room_to:
					if tile.distance_squared_to(room_positions[p])<\
					tile_to.distance_squared_to(room_positions[p]):
						tile_to = tile
				var hallway : PackedVector3Array = [tile_from, tile_to]
				hallways.append(hallway)
				grid_map.set_cell_item(tile_from, 2)
				grid_map.set_cell_item(tile_to, 2)
	
	var astar : AStarGrid2D = AStarGrid2D.new()
	astar.size = Vector2i.ONE * border_size
	astar.update()
	astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar.default_estimate_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	
	for tile in grid_map.get_used_cells_by_item(0):
		astar.set_point_solid(Vector2i(tile.x, tile.y))
		
	for h in hallways:
		var pos_from : Vector2i = Vector2i(h[0].x, h[0].z)
		var pos_to : Vector2i = Vector2i(h[1].x, h[1].z)
		var hall : PackedVector2Array = astar.get_point_path(pos_from, pos_to)
		
		for t in hall:
			var pos : Vector3i = Vector3i(t.x, 0 , t.y)
			if grid_map.get_cell_item(pos) < 0:
				grid_map.set_cell_item(pos,1)
	
	
	
	
func make_room(rec:int):
	if !(rec > 0):
		return 
	
	# dimensions of the room we are trying to place
	var width : int = (randi() % (max_room_size - min_room_size)) + min_room_size
	var height : int = (randi() % (max_room_size- min_room_size)) + min_room_size
	
	var start_pos : Vector3i
	start_pos.x = randi() % (border_size - width + 1)
	start_pos.z = randi() % (border_size - height + 1)
	
	# checks if rooms are occupied
	# this double for loop exits with success if it can find an open position to place the tile
	for r in range(-room_margin, height + room_margin):
		for c in range(-room_margin, width + room_margin):
			var pos : Vector3i = start_pos + Vector3i(c, 0, r)
			if grid_map.get_cell_item(pos) == 0:
				make_room(rec-1)
				return
			
	var room : PackedVector3Array = []
	# for each row in height
	for r in height:
		# for each column in width
		for c in width:
			var pos : Vector3i = start_pos + Vector3i(c, 0, r)
			grid_map.set_cell_item(pos, 0)
			room.append(pos)
	room_tiles.append(room)

	var avg_x : float = start_pos.x + (float(width)/2)
	var avg_z : float = start_pos.z + (float(height)/2)
	var pos : Vector3 = Vector3(avg_x,0, avg_z)
	room_positions.append(pos)
