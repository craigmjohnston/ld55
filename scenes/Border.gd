extends Node

@export var sprite: Sprite2D

func on_hover():
	sprite.visible = true

func on_unhover():
	sprite.visible = false
