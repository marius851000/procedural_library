@tool
extends LibraryLOD

@export var start_index: int
@export var line_size: int = 10:
	set(value):
		if Engine.is_editor_hint():
			reload_preview()
		line_size = value

func _ready() -> void:
	if not Engine.is_editor_hint():
		super._ready();
	reload_preview()

func _load_static():
	var book_scene = preload("res://LibraryEntity/Book.tscn")
	for i in range(line_size):
		var node = book_scene.instantiate()
		node.set("book_id", start_index + i)
		node.set("unique_library_child_id", "book_default_" + str(i))
		node.rotate(Vector3.FORWARD, PI/2)
		node.translate(Vector3.UP * (0.05 * i + 0.02))
		register_child_lod(node)
		add_child(node)
	$PreviewMesh.set("visible", false)

func _unload_static():
	$PreviewMesh.set("visible", true)
	
func does_contain_book_by_default(book_id: int) -> bool:
	return book_id >= start_index and book_id < start_index + line_size
	
func reload_preview():
	$PreviewMesh.set("scale", Vector3(line_size, 1, 1))
	$PreviewMesh.set("position", Vector3(line_size*0.05/2, 0, -0.15/2))
