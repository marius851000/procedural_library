@tool
extends LibraryLOD

@export var scale_for_spacing: float = 1.1:
	set(value):
		scale_for_spacing = value
		if Engine.is_editor_hint():
			reload_preview()

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
	
	var occupied_space = 0;
	for book in books:
		occupied_space += book.get_width();
	
	var possible_space = self.book_length_mm * self.scale_for_spacing
	var average_space_between_book = 0
	if books.size() != 0:
		average_space_between_book = (possible_space - occupied_space) / books.size()
	
	var current_distance = 0
	for book in books:
		var node = book_scene.instantiate()
		node.book_info = book
		node.rotate(Vector3.FORWARD, PI/2)
		node.position = Vector3((0.001 * current_distance), 0.20, 0)
		current_distance += book.get_width()
		current_distance += average_space_between_book
		add_child(node)
	$PreviewMesh.set("visible", false)

func _unload_static():
	$PreviewMesh.set("visible", true)

func reload_preview():
	$PreviewMesh.set("scale", Vector3(book_length_mm * 0.001 * scale_for_spacing, 1, 1))
	$PreviewMesh.set("position", Vector3(book_length_mm * 0.001 * scale_for_spacing / 2, 0.2/2, -0.15/2))
