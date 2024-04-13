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
		if !upnext_right.enabled:
			return
		var upnext = upnext_right.get_column(0)
		board.add_column(upnext, true)
		end_turn()
	if event.is_action_pressed("left_upnext"):
		if !upnext_left.enabled:
			return
		var upnext = upnext_left.get_column(0)
		board.add_column(upnext, false)
		end_turn()
	if event.is_action_pressed("top_upnext"):
		if !upnext_top.enabled:
			return
		var upnext = upnext_top.get_row(0)
		board.add_row(upnext, false)
		end_turn()
	if event.is_action_pressed("bottom_upnext"):
		if !upnext_bottom.enabled:
			return
		var upnext = upnext_bottom.get_row(0)
		board.add_row(upnext, true)
		end_turn()
		
func start():
	# generate the main board
	var tiles = generate_tiles(4, 4)
	board.set_tiles(tiles)
	
	upnext_left.max_dimensions = Vector2i(1, board.max_dimensions.y)
	upnext_right.max_dimensions = Vector2i(1, board.max_dimensions.y)
	upnext_top.max_dimensions = Vector2i(board.max_dimensions.x, 1)
	upnext_bottom.max_dimensions = Vector2i(board.max_dimensions.x, 1)
	
	start_turn()
	
func start_turn():
	var tiles: Array
	
	upnext_left.top_count = board.top_count
	upnext_left.bottom_count = board.bottom_count
	
	upnext_right.top_count = board.top_count
	upnext_right.bottom_count = board.bottom_count
	
	upnext_top.left_count = board.left_count
	upnext_top.right_count = board.right_count
	
	upnext_bottom.left_count = board.left_count
	upnext_bottom.right_count = board.right_count
	
	# upnext - right
	if upnext_right.enabled:
		tiles = generate_tiles(1, board.dimensions.y)
		upnext_right.set_tiles(tiles)
	
	# upnext - left
	if upnext_left.enabled:
		tiles = generate_tiles(1, board.dimensions.y)
		upnext_left.set_tiles(tiles)
	
	# upnext - top
	if upnext_top.enabled:
		tiles = generate_tiles(board.dimensions.x, 1)
		upnext_top.set_tiles(tiles)
	
	# upnext - bottom
	if upnext_bottom.enabled:
		tiles = generate_tiles(board.dimensions.x, 1)
		upnext_bottom.set_tiles(tiles)
	
func end_turn():
	if upnext_left.enabled && board.is_full(Board.SIDE.LEFT):
		upnext_left.disable()
	if upnext_right.enabled && board.is_full(Board.SIDE.RIGHT):
		upnext_right.disable()
	if upnext_top.enabled && board.is_full(Board.SIDE.TOP):
		upnext_top.disable()
	if upnext_bottom.enabled && board.is_full(Board.SIDE.BOTTOM):
		upnext_bottom.disable()
		
	var score = board.calculate_score()
	print_debug("score: ", score)
	
	start_turn()

func generate_tiles(width: int, height: int):
	var out = []
	for x in width:
		var row = []
		out.append(row)
		for y in height:
			var tile = TileStats.new()
			tile.suit = rng.randi_range(0, 3)
			tile.value = rng.randi_range(1, 10) * 5
			row.append(tile)
	return out
