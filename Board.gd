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

func set_tiles(tiles: Array):	
	# intialise the tile array
	self.tiles = []
	self.tiles.resize(max_dimensions.x)
	for x in max_dimensions.x:
		self.tiles[x] = []
		self.tiles[x].resize(max_dimensions.y)		
	dimensions = Vector2i(tiles.size(), tiles[0].size())
	
	# instantiate the tiles
	for x in dimensions.x:
		x -= dimensions.x/2
		for y in dimensions.y:
			y -= dimensions.y/2
			var stats = tiles[x][y]
			new_tile(stats, x, y)
			self.tiles[x][y] = stats
			
	left_count = dimensions.x/2+1
	top_count = dimensions.y/2+1
	right_count = dimensions.x/2
	bottom_count = dimensions.y/2

func new_tile(stats: TileStats, x: int, y: int):
	var i = tile_scn.instantiate()
	i.position = Vector2(x * tile_size.x, y * tile_size.y)
	i.set_stats(stats.suit, stats.value)
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
	
func get_column(index: int):
	var out: Array[TileStats] = []
	out.resize(max_dimensions.y)
	for y in tiles[index].size():
		if tiles[index][y] == null: continue
		out[y] = tiles[index][y]
	return out
