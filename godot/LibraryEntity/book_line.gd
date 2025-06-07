@tool
extends LibraryLOD

#TODO: putting the size in the book_max_length_mm is probably not a good idea

@export var scale_for_spacing: float = 1.1:
	set(value):
		scale_for_spacing = value
		process_lod(Engine.is_editor_hint())

@export var extra_space_for_randomness_mm: float = 0:
	set(value):
		extra_space_for_randomness_mm = value
		process_lod(Engine.is_editor_hint())

var debug_child_mesh: MeshInstance3D = null;
var random_selected_offset: float = 0; # unit is meters

func _enter_tree() -> void:
	recalculate_random_offset()
	super()

func get_max_supported_length() -> int:
	return max(0, book_max_length_mm)
	
func recalculate_random_offset():
	if Engine.is_editor_hint():
		self.random_selected_offset = self.extra_space_for_randomness_mm/2000
	else:
		#TODO: make stable, based on book start mm
		var rng = RandomNumberGenerator.new();
		self.random_selected_offset = rng.randf_range(0, self.extra_space_for_randomness_mm)/1000
	
func _load_static():
	var book_scene = preload("res://LibraryEntity/Book.tscn")
	var books: Array[GodotBookInfo];
	var book_size_in_editor = 30
	if !Engine.is_editor_hint():
		books = $"/root/GlobalLibrary".get_book_range_from_distance(book_start_distance_mm, book_max_length_mm, false)
	else:
		books = []
		var reached_book_size = 0
		while reached_book_size < book_max_length_mm:
			reached_book_size += book_size_in_editor
			books.push_back(null)
	
	var occupied_space = 0;
	for book in books:
		if !Engine.is_editor_hint():
			occupied_space += book.get_width();
		else:
			occupied_space += book_size_in_editor
	
	var possible_space = self.book_max_length_mm * self.scale_for_spacing
	var average_space_between_book = 0
	if books.size() != 0:
		average_space_between_book = (possible_space - occupied_space) / books.size()
		
	var current_distance = 0
	for book in books:
		var node = book_scene.instantiate()
		if !Engine.is_editor_hint():
			node.book_info = book
		else:
			node.book_max_length_mm = book_size_in_editor
		node.rotate(Vector3.FORWARD, PI/2)
		node.position = Vector3((0.001 * current_distance) + self.random_selected_offset, 0.20, 0)
		if !Engine.is_editor_hint():
			current_distance += book.get_width()
		else:
			current_distance += book_size_in_editor
		current_distance += average_space_between_book
		add_child(node)
	$PreviewMesh.visible = false
	
	if Engine.is_editor_hint():
		if self.debug_child_mesh != null:
			self.debug_child_mesh.queue_free()
		var length_to_use_mm: float = float(book_max_length_mm) * scale_for_spacing + extra_space_for_randomness_mm
		var meshInstance: MeshInstance3D = MeshInstance3D.new()
		var boxMesh: BoxMesh = BoxMesh.new()
		boxMesh.size = Vector3(length_to_use_mm/1000, 0.02, 0.02)
		meshInstance.mesh = boxMesh
		meshInstance.position = Vector3(boxMesh.size.x/2, 0.1, -0.1)
		add_child(meshInstance)
		self.debug_child_mesh = meshInstance
		

func _unload_static():
	if self.debug_child_mesh != null:
		self.debug_child_mesh.queue_free()
	$PreviewMesh.set("scale", Vector3(book_max_length_mm * 0.001 * scale_for_spacing, 1, 1))
	$PreviewMesh.set("position", Vector3(book_max_length_mm * 0.001 * scale_for_spacing / 2 + random_selected_offset, 0.2/2, -0.15/2))
	$PreviewMesh.visible = true
