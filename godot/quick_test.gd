extends Node3D

@export var book_per_line = 10;
@export var line_count = 40;

func _ready():
	var line_scene = preload("res://LibraryEntity/BookLine.tscn")
	for i in range(0, line_count):
		var line = line_scene.instantiate()
		line.set("line_size", book_per_line)
		line.set("start_index", i * book_per_line)
		line.set("position", Vector3(0, 0.25*i, 0))
		add_child(line)
