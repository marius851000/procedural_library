@tool
extends LibraryLOD

@export var book_distance: int # Only used if book_info is not set before _ready
var book_info: GodotBookInfo

func _init() -> void:
	self.use_lod = false;
	self.auto_allocate_if_needed = false

func load_book_if_needed():
	if book_info == null:
		self.book_info = $"/root/GlobalLibrary".get_book_range_from_distance(book_distance, 0, true)[0]

func get_max_supported_length() -> int:
	load_book_if_needed()
	return book_info.get_width()

func _load_static():
	var book_title = null
	var book_width = 0
	if Engine.is_editor_hint():
		book_title = "Lorem Ipsum Something"
		book_width = 30
	else:
		self.load_book_if_needed()
		book_title = book_info.get_title()
		book_width = book_info.get_width()
	
	$SimpleBookMesh.set("scale", Vector3($SimpleBookMesh.scale.x, book_width * 0.001, $SimpleBookMesh.scale.z))
	$SimpleBookMesh.set("position", Vector3($SimpleBookMesh.scale.x/2, $SimpleBookMesh.scale.y/2, -$SimpleBookMesh.scale.z/2))
	
	var font_height = book_width / 2
	if font_height > 30:
		font_height = 30
	$"Label".pixel_size = (font_height * 0.001) / $"Label".font_size
	$"Label".text = book_title
	$"Label".position = Vector3($SimpleBookMesh.scale.x/2, $SimpleBookMesh.scale.y/2, 0.001)

func does_contain_book_by_default(searched_book_distance: int) -> bool:
	if book_info == null:
		return false
	else:
		return book_info.get_distance() <= searched_book_distance and book_info.get_distance() + book_info.get_width() > searched_book_distance
