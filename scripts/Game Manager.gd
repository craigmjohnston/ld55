extends Node

signal win
signal lose

@export var game_scene: PackedScene
@export var max_turns: int
@export var score_label: Label
@export var turns_label: Label
@export var levels: Array[Level]

var board: Board
var upnext_right: Board
var upnext_left: Board
var upnext_top: Board
var upnext_bottom: Board

var rng = RandomNumberGenerator.new()
var turn_counter = 0
var game_over = false

var current_game_scene: Node
var current_level_index: int
var current_level: Level

var chosen_direction: Board.SIDE = Board.SIDE.NONE

# At the start of the game we generate the board
# And every turn we generate the UpNext boards
# The "length" (depending on orientation) of the UpNexts matches the board

func _ready():
	load_level(0)
	
func load_level(index: int):
	current_level_index = index
	current_level = levels[index]
	start()

func _input(event):
	#if event.is_action_pressed("new_tile"):
		#start()
		
	if game_over: return
	
	if event.is_action_pressed("right_upnext"):
		if !upnext_right.enabled:
			return
		var upnext = upnext_right.get_column(0)
		chosen_direction = Board.SIDE.RIGHT
		board.add_column(upnext, true)
		end_turn()
	if event.is_action_pressed("left_upnext"):
		if !upnext_left.enabled:
			return
		var upnext = upnext_left.get_column(0)
		chosen_direction = Board.SIDE.LEFT
		board.add_column(upnext, false)
		end_turn()
	if event.is_action_pressed("top_upnext"):
		if !upnext_top.enabled:
			return
		var upnext = upnext_top.get_row(0)
		chosen_direction = Board.SIDE.TOP
		board.add_row(upnext, false)
		end_turn()
	if event.is_action_pressed("bottom_upnext"):
		if !upnext_bottom.enabled:
			return
		var upnext = upnext_bottom.get_row(0)
		chosen_direction = Board.SIDE.BOTTOM
		board.add_row(upnext, true)
		end_turn()
		
func start():
	game_over = false
	turn_counter = 0
	chosen_direction = Board.SIDE.NONE
	
	if current_game_scene != null:
		current_game_scene.queue_free()
	
	current_game_scene = game_scene.instantiate()
	add_child(current_game_scene)	
	
	board = current_game_scene.get_node("Board")
	upnext_left = current_game_scene.get_node("UpNextLeft")
	upnext_right = current_game_scene.get_node("UpNextRight")
	upnext_top = current_game_scene.get_node("UpNextTop")
	upnext_bottom = current_game_scene.get_node("UpNextBottom")
	
	# generate the main board
	var tiles = generate_tiles(board.max_dimensions.x, board.max_dimensions.y)
	board.set_tiles(tiles)
	
	upnext_left.max_dimensions = Vector2i(1, board.max_dimensions.y)
	upnext_left.tile_size = board.tile_size
	upnext_right.max_dimensions = Vector2i(1, board.max_dimensions.y)
	upnext_right.tile_size = board.tile_size
	upnext_top.max_dimensions = Vector2i(board.max_dimensions.x, 1)
	upnext_top.tile_size = board.tile_size
	upnext_bottom.max_dimensions = Vector2i(board.max_dimensions.x, 1)
	upnext_bottom.tile_size = board.tile_size
	
	score_label.text = "0/" + str(current_level.target_score)
	turns_label.text = "1/" + str(max_turns)
	
	start_turn()
	
func start_turn():
	var tiles: Array
	
	# upnext - right
	if upnext_right.enabled && chosen_direction == Board.SIDE.RIGHT || chosen_direction == Board.SIDE.NONE:
		tiles = generate_tiles(1, board.dimensions.y)
		upnext_right.set_tiles(tiles)
	
	# upnext - left
	if upnext_left.enabled && chosen_direction == Board.SIDE.LEFT || chosen_direction == Board.SIDE.NONE:
		tiles = generate_tiles(1, board.dimensions.y)
		upnext_left.set_tiles(tiles)
	
	# upnext - top
	if upnext_top.enabled && chosen_direction == Board.SIDE.TOP || chosen_direction == Board.SIDE.NONE:
		tiles = generate_tiles(board.dimensions.x, 1)
		upnext_top.set_tiles(tiles)
	
	# upnext - bottom
	if upnext_bottom.enabled && chosen_direction == Board.SIDE.BOTTOM || chosen_direction == Board.SIDE.NONE:
		tiles = generate_tiles(board.dimensions.x, 1)
		upnext_bottom.set_tiles(tiles)
	
func end_turn():
	#if upnext_left.enabled && board.is_full(Board.SIDE.LEFT):
		#upnext_left.disable()
	#if upnext_right.enabled && board.is_full(Board.SIDE.RIGHT):
		#upnext_right.disable()
	#if upnext_top.enabled && board.is_full(Board.SIDE.TOP):
		#upnext_top.disable()
	#if upnext_bottom.enabled && board.is_full(Board.SIDE.BOTTOM):
		#upnext_bottom.disable()
		
	var score = board.calculate_score()
	score_label.text = str(score) + "/" + str(current_level.target_score)
	
	turn_counter += 1
	turns_label.text = str(turn_counter+1) + "/" + str(max_turns)
	
	if score > current_level.target_score:
		if levels.size() > current_level_index + 1:
			load_level(current_level_index + 1)
			return
		# all the levels have been completed
		win.emit()
		game_over = true
		return
	
	if turn_counter >= max_turns:
		lose.emit()
		game_over = true
		return
	
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
