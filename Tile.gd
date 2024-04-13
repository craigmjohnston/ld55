extends Node

class_name Tile

@onready var background: Sprite2D = $Background
@onready var icon: Sprite2D = $Icon
@onready var label: Label = $Label

@export var suit: TileStats.SUIT
@export var value: int

# Called when the node enters the scene tree for the first time.
func _ready():
	update_visual()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func set_stats(suit: TileStats.SUIT, value: int):
	self.suit = suit
	self.value = value
	update_visual()

func update_visual():
	if label == null: return
	label.text = str(value)
