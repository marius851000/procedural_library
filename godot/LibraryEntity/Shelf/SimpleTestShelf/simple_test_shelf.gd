extends LibraryLOD

@export var start_index: int;
# Contain 80 books (TODO: find a better way to manage those book range)

func _init():
	remove_child_on_low = false

func _load_static():
	$BookLine.set("start_index", start_index)
	$BookLine2.set("start_index", start_index + 20)
	$BookLine3.set("start_index", start_index + 40)
	$BookLine4.set("start_index", start_index + 60)
	
func does_contain_book_by_default(book_id: int) -> bool:
	return book_id >= start_index and book_id < start_index + 80
