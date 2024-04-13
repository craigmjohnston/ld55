extends Node

@onready var board: Board = $Board
@onready var upnext_right: Board = $UpNextRight
@onready var upnext_left: Board = $UpNextLeft
@onready var upnext_top: Board = $UpNextTop
@onready var upnext_bottom: Board = $UpNextBottom

var rng = RandomNumberGenerator.new()

# At the start of the game we generate the board
# And every turn we generate the UpNext boards
# The "length" (depending on orientation) of the UpNexts matches the board

func _input(event):
	if event.is_action_pressed("new_tile"):
		start()
	if event.is_action_pressed("right_upnext"):
		var upnext = upnext_right.get_column(0)
		board.add_column(upnext, true)
		end_turn()
	if event.is_action_pressed("left_upnext"):
		var upnext = upnext_left.get_column(0)
		board.add_column(upnext, false)
		end_turn()
	if event.is_action_pressed("top_upnext"):
		var upnext = upnext_top.get_row(0)
		board.add_row(upnext, false)
		end_turn()
	if event.is_action_pressed("bottom_upnext"):
		var upnext = upnext_bottom.get_row(0)
		board.add_row(upnext, true)
		end_turn()
		
func start():
	# generate the main board
	var tiles = generate_tiles(4, 4)
	board.set_tiles(tiles)
	start_turn()
	
func start_turn():
	# upnext - right
	var tiles = generate_tiles(1, board.dimensions.y)
	upnext_right.set_tiles(tiles)
	
	# upnext - left
	tiles = generate_tiles(1, board.dimensions.y)
	upnext_left.set_tiles(tiles)
	
	# upnext - top
	tiles = generate_tiles(board.dimensions.x, 1)
	upnext_top.set_tiles(tiles)
	
	# upnext - bottom
	tiles = generate_tiles(board.dimensions.x, 1)
	upnext_bottom.set_tiles(tiles)
	
func end_turn():
	start_turn()

func generate_tiles(width: int, height: int):
	var out = []
	for x in width:
		var row = []
		out.append(row)
		for y in height:
			var tile = TileStats.new()
			tile.suit = TileStats.SUIT.HEART
			tile.value = rng.randi_range(1, 10) * 5
			row.append(tile)
	return out
