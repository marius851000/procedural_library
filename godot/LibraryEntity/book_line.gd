@tool
extends Node3D

@export var start_index: int
@export var line_size: int = 10:
	set(value):
		if Engine.is_editor_hint():
			reload_preview()
		line_size = value

func _ready() -> void:
	if not Engine.is_editor_hint():
		var book_scene = preload("res://LibraryEntity/Book.tscn")
		for i in range(line_size):
			var node = book_scene.instantiate()
			node.set("book_id", start_index + i)
			node.rotate(Vector3.FORWARD, PI/2)
			node.translate(Vector3.UP * (0.05 * i + 0.02))
			add_child(node)
		$PreviewMesh.queue_free()
	else:
		reload_preview()

func reload_preview():
	$PreviewMesh.set("scale", Vector3(line_size, 1, 1))
	$PreviewMesh.set("position", Vector3(line_size*0.05/2, 0, -0.15/2))
