extends Node2D

class_name Tile

@onready var background: Sprite2D = $Background
@onready var icon: Sprite2D = $Icon
@onready var label: Label = $Label

@export var suit_icons: Array[Texture]
@export var suit: TileStats.SUIT
@export var value: int
@export var texture_size: Vector2i

var desired_size: Vector2

func _ready():
	update_visual()
	
func set_size(desired_size: Vector2):
	self.desired_size = desired_size	

func set_stats(suit: TileStats.SUIT, value: int):
	self.suit = suit
	self.value = value
	update_visual()

func update_visual():
	if label == null: return
	label.text = str(value)
	icon.texture = suit_icons[suit]
	
	var sprite_size = texture_size.x
	var ratio = desired_size.x / sprite_size
	scale = Vector2(ratio, ratio)
	
func fade_out():
	pass

func animate_translate(pos: Vector2):
	pass
