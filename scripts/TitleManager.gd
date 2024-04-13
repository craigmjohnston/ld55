extends Node2D

signal play_clicked

func on_play_clicked():
	play_clicked.emit()
