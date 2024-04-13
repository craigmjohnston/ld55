extends Node2D

signal try_again_clicked

func on_try_again_clicked():
	try_again_clicked.emit()
