extends LibraryLOD

@export var book_id: int
var book_title: String

func _init() -> void:
	self.use_lod = false;
	
func _ready() -> void:
	super._ready()
	book_title = $"/root/GlobalLibrary".get_book_title(book_id)
	$"Label".set("text", book_title)

func does_contain_book_by_default(searched_book_id: int) -> bool:
	return book_id == searched_book_id

func _process(delta: float) -> void:
	pass # Do not call the LibraryLOD LOD-related code
