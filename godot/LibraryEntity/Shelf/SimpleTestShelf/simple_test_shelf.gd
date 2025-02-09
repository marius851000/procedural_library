extends LibraryLOD

@export var start_position: int;

func _init():
	remove_child_on_low = false

func _load_static():
	$BookLine.set("start_position", start_position)
	$BookLine2.set("start_position", $BookLine.start_position + $BookLine.length)
	$BookLine3.set("start_position", $BookLine2.start_position + $BookLine2.length)
	$BookLine4.set("start_position", $BookLine3.start_position + $BookLine3.length)
	
func does_contain_book_by_default(book_id: int) -> bool:
	#TODO: re-implement
	return false
	#return book_id >= start_index and book_id < start_index + 80
