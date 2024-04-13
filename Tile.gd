extends Node

class_name Tile

@onready var background: Sprite2D = $Background
@onready var icon: Sprite2D = $Icon
@onready var label: Label = $Label

@export var suit: TileStats.SUIT
@export var value: int

func _ready():
	update_visual()

func set_stats(suit: TileStats.SUIT, value: int):
	self.suit = suit
	self.value = value
	update_visual()

func update_visual():
	if label == null: return
	label.text = str(value)
	match suit:
		TileStats.SUIT.HEART:
			icon.modulate = Color.RED
		TileStats.SUIT.DIAMOND:
			icon.modulate = Color.GREEN
		TileStats.SUIT.SPADE:
			icon.modulate = Color.DIM_GRAY
		
