@tool
extends LibraryLOD

@export var scale_for_spacing: float = 1.1:
	set(value):
		scale_for_spacing = value
		process_lod(Engine.is_editor_hint())

func _load_static():
	var book_scene = preload("res://LibraryEntity/Book.tscn")
	var books: Array[GodotBookInfo];
	var book_size_in_editor = 30
	if !Engine.is_editor_hint():
		books = $"/root/GlobalLibrary".get_book_range_from_distance(book_start_distance_mm, book_length_mm, false)
	else:
		books = []
		var reached_book_size = 0
		while reached_book_size < book_length_mm:
			reached_book_size += book_size_in_editor
			books.push_back(null)
	
	var occupied_space = 0;
	for book in books:
		if !Engine.is_editor_hint():
			occupied_space += book.get_width();
		else:
			occupied_space += book_size_in_editor
	
	var possible_space = self.book_length_mm * self.scale_for_spacing
	var average_space_between_book = 0
	if books.size() != 0:
		average_space_between_book = (possible_space - occupied_space) / books.size()
	
	var current_distance = 0
	for book in books:
		var node = book_scene.instantiate()
		if !Engine.is_editor_hint():
			node.book_info = book
		else:
			node.book_length_mm = book_size_in_editor
		node.rotate(Vector3.FORWARD, PI/2)
		node.position = Vector3((0.001 * current_distance), 0.20, 0)
		if !Engine.is_editor_hint():
			current_distance += book.get_width()
		else:
			current_distance += book_size_in_editor
		current_distance += average_space_between_book
		add_child(node)
	$PreviewMesh.visible = false

func _unload_static():
	$PreviewMesh.set("scale", Vector3(book_length_mm * 0.001 * scale_for_spacing, 1, 1))
	$PreviewMesh.set("position", Vector3(book_length_mm * 0.001 * scale_for_spacing / 2, 0.2/2, -0.15/2))
	$PreviewMesh.visible = true
