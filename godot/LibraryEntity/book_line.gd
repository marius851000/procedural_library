@tool
extends LibraryLOD

func _set_book_length_mm(value: int):
	super(value)
	if Engine.is_editor_hint():
		reload_preview()

func _ready() -> void:
	if not Engine.is_editor_hint():
		super._ready();
	reload_preview()

func _load_static():
	var book_scene = preload("res://LibraryEntity/Book.tscn")
	var books = $"/root/GlobalLibrary".get_book_range_from_distance(book_start_distance_mm, book_length_mm, false)
	
	var previous_book = null
	var free_space_total_length = 0
	var free_space_count = 0
	for book in books:
		if previous_book != null:
			free_space_total_length += book.get_distance() - previous_book.get_distance() - book.get_width()
			free_space_count += 1
		previous_book = book
	
	var average_free_space = 0
	if free_space_count != 0:
		average_free_space = free_space_total_length / free_space_count
	
	var current_distance = 0
	for book in books:
		var node = book_scene.instantiate()
		node.book_info = book
		node.rotate(Vector3.FORWARD, PI/2)
		node.position = Vector3((0.001 * current_distance), 0.20, 0)
		current_distance += book.get_width()
		current_distance += average_free_space
		add_child(node)
	$PreviewMesh.set("visible", false)

func _unload_static():
	$PreviewMesh.set("visible", true)
	
func does_contain_book_by_default(book_id: int) -> bool:
	#TODO: re-implement
	return false
	#return book_id >= start_index and book_id < start_index + line_size
	
func reload_preview():
	$PreviewMesh.set("scale", Vector3(book_length_mm * 0.001, 1, 1))
	$PreviewMesh.set("position", Vector3(book_length_mm * 0.001/2, 0.2/2, -0.15/2))
