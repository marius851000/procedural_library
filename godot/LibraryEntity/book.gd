extends LibraryLOD

@export var book_id: int
var book_title: String
var book_width: float

func _init() -> void:
	self.use_lod = false;

func _load_static():
	book_title = $"/root/GlobalLibrary".get_book_title(book_id)
	$"Label".set("text", book_title)
	book_width = $"/root/GlobalLibrary".get_book_width(book_id)
	$SimpleBookMesh.set("scale", Vector3($SimpleBookMesh.get("scale").x, book_width * 0.01, $SimpleBookMesh.get("scale").z))

func does_contain_book_by_default(searched_book_id: int) -> bool:
	return book_id == searched_book_id

func _process(delta: float) -> void:
	pass # Do not call the LibraryLOD LOD-related code
