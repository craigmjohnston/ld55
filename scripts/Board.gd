extends Node2D

class_name Board

@export var tile_scn: PackedScene
@export var max_dimensions: Vector2i
@export var tile_size: Vector2

var tiles: Array
var dimensions: Vector2i

var left_count: int
var right_count: int
var top_count: int
var bottom_count: int

var enabled: bool = true
var init: bool = false

enum SIDE { LEFT, RIGHT, TOP, BOTTOM }

func disable():
	enabled = false
	for child in get_children():
		child.queue_free()

func is_full(side: SIDE):
	match side:
		SIDE.LEFT:
			return left_count >= max_dimensions.x/2 + 1
		SIDE.RIGHT:
			return right_count >= max_dimensions.x/2
		SIDE.TOP:
			return top_count >= max_dimensions.y/2 + 1
		SIDE.BOTTOM:
			return bottom_count >= max_dimensions.y/2

func set_tiles(tiles: Array):	
	dimensions = Vector2i(tiles.size(), tiles[0].size())
	
	if !init:
		init_board()
	
	for x in dimensions.x:
		x = -left_count+x+1
		for y in dimensions.y:
			y = -top_count+y+1
			var stats = tiles[x][y]
			new_tile(stats, x, y)
			self.tiles[x][y] = stats
			
func init_board():
	# intialise the tile array
	self.tiles = []
	self.tiles.resize(max_dimensions.x)
	for x in max_dimensions.x:
		self.tiles[x] = []
		self.tiles[x].resize(max_dimensions.y)		
	
	left_count = dimensions.x/2+1
	top_count = dimensions.y/2+1
	right_count = dimensions.x/2
	bottom_count = dimensions.y/2		
	
	init = true
	
	position += tile_size / 2

func new_tile(stats: TileStats, x: int, y: int):
	var i = tile_scn.instantiate()
	i.set_size(tile_size)
	i.position = Vector2(x * tile_size.x, y * tile_size.y)
	i.set_stats(stats.suit, stats.value)
	i.z_index = y - x
	add_child(i)
	return i

func add_row(tiles: Array[TileStats], at_end: bool):
	var y = bottom_count if at_end else -top_count
	for x in tiles.size():
		var off = -left_count+x+1
		if tiles[off] == null: continue
		new_tile(tiles[off], off, y)
		self.tiles[off][y] = tiles[off]
	if at_end:
		bottom_count += 1
	else:
		top_count += 1
	dimensions.y += 1
		
func get_row(index: int):
	var out: Array[TileStats] = []
	out.resize(max_dimensions.x)
	for x in tiles.size():
		if tiles[x][index] == null: continue
		out[x] = tiles[x][index]
	return out

func add_column(tiles: Array[TileStats], at_end: bool):
	var x = right_count if at_end else -left_count
	for y in tiles.size():
		var off = -top_count+y+1
		if tiles[off] == null: continue
		new_tile(tiles[off], x, off)
		self.tiles[x][off] = tiles[off]
	if at_end:
		right_count += 1
	else:
		left_count += 1
	dimensions.x += 1
	
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
	var arr = build_offset_array()	
	var connected = find_connected(arr)
	var valid = []
	for run in connected:
		if run.size() >= 3:
			valid.append(run)
	var score = 0
	for run in valid:
		for pos in run:
			score += arr[pos.x][pos.y].value
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
