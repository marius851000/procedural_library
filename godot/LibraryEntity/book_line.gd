@tool
extends LibraryLOD

@export var start_position: int
@export var length: int = 500:
	set(value):
		length = value
		if Engine.is_editor_hint():
			reload_preview()

func _ready() -> void:
	if not Engine.is_editor_hint():
		super._ready();
	reload_preview()

func _load_static():
	var book_scene = preload("res://LibraryEntity/Book.tscn")
	var books = $"/root/GlobalLibrary".get_book_range_from_distance(start_position, length, false)
	for book in books:
		var node = book_scene.instantiate()
		node.book_info = book
		node.rotate(Vector3.FORWARD, PI/2)
		var distance_to_start = book.get_distance() - start_position
		node.position = Vector3((0.001 * distance_to_start), 0.20, 0)
		add_child(node)
	$PreviewMesh.set("visible", false)

func _unload_static():
	$PreviewMesh.set("visible", true)
	
func does_contain_book_by_default(book_id: int) -> bool:
	#TODO: re-implement
	return false
	#return book_id >= start_index and book_id < start_index + line_size
	
func reload_preview():
	$PreviewMesh.set("scale", Vector3(length * 0.001, 1, 1))
	$PreviewMesh.set("position", Vector3(length*0.001/2, 0.2/2, -0.15/2))
