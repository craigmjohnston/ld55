extends Node2D

class_name Board

signal clicked

@export var tile_scn: PackedScene
@export var max_dimensions: Vector2i
@export var tile_size: Vector2

var tiles: Array
var tile_nodes: Array
var dimensions: Vector2i

var enabled: bool = true
var init: bool = false

enum SIDE { LEFT, RIGHT, TOP, BOTTOM, NONE }

func disable():
	enabled = false
	for child in get_children():
		child.queue_free()

func set_tiles(tiles: Array):	
	dimensions = Vector2i(tiles.size(), tiles[0].size())
	
	if !init:
		init_board()
	
	for x in dimensions.x:		
		for y in dimensions.y:
			var stats = tiles[x][y]
			var t = new_tile(stats, x, y)
			self.tiles[x][y] = stats
			tile_nodes[x][y] = t
			
func init_board():
	# intialise the tile array
	self.tiles = []
	self.tiles.resize(max_dimensions.x)
	tile_nodes = []
	tile_nodes.resize(max_dimensions.x)
	for x in max_dimensions.x:
		self.tiles[x] = []
		self.tiles[x].resize(max_dimensions.y)
		tile_nodes[x] = []
		tile_nodes[x].resize(max_dimensions.y)
	
	init = true
	
	position -= (tiles.size()/2-0.5)*tile_size

func new_tile(stats: TileStats, x: int, y: int):
	var i = tile_scn.instantiate()
	i.set_size(tile_size)
	i.position = Vector2(x * tile_size.x, y * tile_size.y)
	i.set_stats(stats.suit, stats.value)
	i.z_index = y - x
	add_child(i)
	return i
	
func update_tiles():
	for x in tiles.size():
		for y in tiles[x].size():
			var tile = tiles[x][y]
			tile_nodes[x][y].set_stats(tile.suit, tile.value)
	
func duplicate_tiles_array():
	var out = []
	for x in tiles.size():
		out.append([])
		for y in tiles[x].size():
			out[x].append(tiles[x][y])

func add_row(row: Array[TileStats], at_end: bool):
	var out = []
	out.resize(tiles.size())
	var offset = 1 if at_end else -1
	for x in tiles.size():
		out[x] = []
		out[x].resize(tiles[x].size())
		for y in tiles[x].size():
			if !at_end && y == 0 || at_end && y == tiles[x].size() - 1:
				out[x][y] = row[x]
				continue
			out[x][y] = tiles[x][y+offset]
	tiles = out
	update_tiles()
		
func get_row(index: int):
	var out: Array[TileStats] = []
	out.resize(max_dimensions.x)
	for x in tiles.size():
		if tiles[x][index] == null: continue
		out[x] = tiles[x][index]
	return out

func add_column(col: Array[TileStats], at_end: bool):
	var out = []
	out.resize(tiles.size())
	var offset = 1 if at_end else -1
	for x in tiles.size():
		out[x] = []
		out[x].resize(tiles[x].size())
		for y in tiles[x].size():
			if !at_end && x == 0 || at_end && x == tiles.size() - 1:
				out[x][y] = col[y]
				continue
			out[x][y] = tiles[x+offset][y]
	tiles = out
	update_tiles()
	pass
	
func get_column(index: int):
	var out: Array[TileStats] = []
	out.resize(max_dimensions.y)
	for y in tiles[index].size():
		if tiles[index][y] == null: continue
		out[y] = tiles[index][y]
	return out
	
func build_offset_array():
	var out: Array = []
	out.resize(max_dimensions.x)
	for x in max_dimensions.x:
		var x_off = x - max_dimensions.x/2
		out[x] = []
		out[x].resize(max_dimensions.y)
		for y in max_dimensions.y:
			var y_off = y - max_dimensions.y/2
			out[x][y] = tiles[x_off][y_off]
	return out

func calculate_score():
	#var arr = build_offset_array()
	var connected = find_connected(tiles)
	var valid = []
	for run in connected:
		if run.size() >= 3:
			valid.append(run)
	var score = 0
	for run in valid:
		score += run.size()
		#for pos in run:
			#score += arr[pos.x][pos.y].value
	return score

func find_connected(arr: Array):
	var out = []
	var visited: Array = []
	visited.resize(max_dimensions.x)
	for x in max_dimensions.x:
		visited[x] = []
		visited[x].resize(max_dimensions.y)
	for x in max_dimensions.x:
		for y in max_dimensions.y:
			if arr[x][y] == null:
				visited[x][y] = true
				continue
			if visited[x][y]: continue
			var component = flood_fill(arr, visited, Vector2i(x, y))
			if component.size() > 0:
				out.append(component)
			for pos in component:
				visited[pos.x][pos.y] = true
	return out

func flood_fill(arr: Array, visited: Array, start: Vector2i):
	var stack = [start]
	var component = []
	var directions = [Vector2i(0, 1), Vector2i(1, 0), Vector2i(0, -1), Vector2i(-1, 0)] # right, down, left, up
	
	while stack.size() > 0:
		var pos = stack.pop_back()
		if visited[pos.x][pos.y]:
			continue
		
		visited[pos.x][pos.y] = true
		component.append(pos)
		
		for offset in directions:
			var other = pos + offset
			if is_valid_pos(arr, other, arr[pos.x][pos.y].suit):
				stack.push_back(other)
	
	return component
			
func is_valid_pos(arr: Array, pos: Vector2i, suit: TileStats.SUIT):
	return (pos.x >= 0 && 
		pos.y >= 0 && 
		pos.x < max_dimensions.x && 
		pos.y < max_dimensions.y && 
		arr[pos.x][pos.y] != null && 
		arr[pos.x][pos.y].suit == suit)

func on_input_event(viewport: Node, event: InputEvent, shape_idx: int):
	if event is InputEventMouseButton:
		if event.pressed && event.button_index == MOUSE_BUTTON_LEFT:
			clicked.emit()
