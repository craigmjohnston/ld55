extends Node2D

@export var titleScene: PackedScene
@export var gameplayScene: PackedScene
@export var loseScene: PackedScene
@export var winScene: PackedScene

var currentScn: Node

func _ready():
	var scn = titleScene.instantiate()
	add_child(scn)
	scn.play_clicked.connect(on_title_play_clicked)
	currentScn = scn

func on_title_play_clicked():
	if currentScn != null:
		currentScn.queue_free()
	var scn = gameplayScene.instantiate()
	add_child(scn)
	currentScn = scn
