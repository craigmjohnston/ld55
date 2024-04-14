extends Node

signal win
signal lose

@export var game_scene: PackedScene
@export var score_label: Label
@export var turns_label: Label
@export var levels: Array[Level]

var board: Board
var upnext_right: Board
var upnext_left: Board
var upnext_top: Board
var upnext_bottom: Board

var continue_button: Button

var rng = RandomNumberGenerator.new()
var turn_counter = 0
var game_over = false

var current_game_scene: Node
var current_level_index: int
var current_level: Level

var chosen_direction: Board.SIDE = Board.SIDE.NONE

func _ready():
	load_level(0)
	
func load_level(index: int):
	current_level_index = index
	current_level = levels[index]
	start()

func _input(event):		
	if game_over: return	
	if event.is_action_pressed("right_upnext"):
		upnext_right_chosen()		
	if event.is_action_pressed("left_upnext"):
		upnext_left_chosen()		
	if event.is_action_pressed("top_upnext"):
		upnext_top_chosen()		
	if event.is_action_pressed("bottom_upnext"):
		upnext_bottom_chosen()		
		
func upnext_right_chosen():
	if !upnext_right.enabled || game_over:
		return
	var upnext = upnext_right.get_column(0)
	chosen_direction = Board.SIDE.RIGHT
	board.add_column(upnext, true)
	end_turn()

func upnext_left_chosen():
	if !upnext_left.enabled || game_over:
		return
	var upnext = upnext_left.get_column(0)
	chosen_direction = Board.SIDE.LEFT
	board.add_column(upnext, false)
	end_turn()

func upnext_top_chosen():
	if !upnext_top.enabled || game_over:
		return
	var upnext = upnext_top.get_row(0)
	chosen_direction = Board.SIDE.TOP
	board.add_row(upnext, false)
	end_turn()

func upnext_bottom_chosen():
	if !upnext_bottom.enabled || game_over:
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
		
	continue_button = get_parent().get_node("ContinueButton")
	continue_button.visible = false
	continue_button.disabled = true
	
	current_game_scene = game_scene.instantiate()
	add_child(current_game_scene)	
	
	board = current_game_scene.get_node("Board")
	
	upnext_left = current_game_scene.get_node("UpNextLeft")
	upnext_left.clicked.connect(upnext_left_chosen)
	
	upnext_right = current_game_scene.get_node("UpNextRight")
	upnext_right.clicked.connect(upnext_right_chosen)
	
	upnext_top = current_game_scene.get_node("UpNextTop")
	upnext_top.clicked.connect(upnext_top_chosen)
	
	upnext_bottom = current_game_scene.get_node("UpNextBottom")
	upnext_bottom.clicked.connect(upnext_bottom_chosen)
	
	# generate the main board
	var tiles = generate_tiles(board.max_dimensions.x, board.max_dimensions.y, true)
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
	turns_label.text = "1/" + str(current_level.max_turns)
	
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
	var score = board.calculate_score()
	score_label.text = str(score) + "/" + str(current_level.target_score)
	
	turn_counter += 1
	turns_label.text = str(turn_counter+1) + "/" + str(current_level.max_turns)
	
	if score >= current_level.target_score:
		match chosen_direction:
			Board.SIDE.LEFT: upnext_left.disable()
			Board.SIDE.RIGHT: upnext_right.disable()
			Board.SIDE.TOP: upnext_top.disable()
			Board.SIDE.BOTTOM: upnext_bottom.disable()
		if levels.size() > current_level_index + 1:
			continue_button.visible = true
			continue_button.disabled = false
			game_over = true
			return
		# all the levels have been completed
		win.emit()
		game_over = true
		return
	
	if turn_counter >= current_level.max_turns:
		lose.emit()
		game_over = true
		return
	
	start_turn()
	
func continue_clicked():
	load_level(current_level_index + 1)

func generate_tiles(width: int, height: int, even: bool = false):
	var suit_ticker = 0
	var out = []
	for x in width:
		var row = []
		out.append(row)
		for y in height:
			var tile = TileStats.new()
			if even:
				tile.suit = suit_ticker % 4
				suit_ticker += 1
			else:
				tile.suit = rng.randi_range(0, 3)
			tile.value = rng.randi_range(1, 10) * 5
			row.append(tile)
		suit_ticker += 1
	return out
