extends Node2D

@export var titleScene: PackedScene
@export var gameplayScene: PackedScene
@export var loseScene: PackedScene
@export var winScene: PackedScene

var currentScn: Node
var overlayScn: Node

func _ready():
	start_game()
	#var scn = titleScene.instantiate()
	#add_child(scn)
	#scn.play_clicked.connect(on_title_play_clicked)
	#currentScn = scn

func on_title_play_clicked():
	start_game()

func on_lose():
	#if currentScn != null:
		#currentScn.queue_free()
	var scn = loseScene.instantiate()
	add_child(scn)
	scn.try_again_clicked.connect(on_try_again_clicked)
	overlayScn = scn

func on_win():
	#if currentScn != null:
		#currentScn.queue_free()
	var scn = winScene.instantiate()
	add_child(scn)
	scn.try_again_clicked.connect(on_try_again_clicked)
	overlayScn = scn
	
func on_try_again_clicked():
	start_game()
	
func start_game():
	if currentScn != null:
		currentScn.queue_free()
	if overlayScn != null:
		overlayScn.queue_free()
	var scn = gameplayScene.instantiate()
	add_child(scn)
	var mgr = scn.get_node("Game Manager")
	mgr.win.connect(on_win)
	mgr.lose.connect(on_lose)
	currentScn = scn
