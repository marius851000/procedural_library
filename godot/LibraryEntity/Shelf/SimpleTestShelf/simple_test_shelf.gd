extends LibraryLOD

func _init():
	remove_child_on_low = false
	book_length_mm = 800 + 500 + 200 + 1000

func _load_static():
	$BookLine.book_start_distance_mm = book_start_distance_mm
	$BookLine2.book_start_distance_mm = $BookLine.book_start_distance_mm + $BookLine.book_length_mm
	$BookLine3.book_start_distance_mm = $BookLine2.book_start_distance_mm + $BookLine2.book_length_mm
	$BookLine4.book_start_distance_mm = $BookLine3.book_start_distance_mm + $BookLine3.book_length_mm
	
func does_contain_book_by_default(book_id: int) -> bool:
	#TODO: re-implement
	return false
	#return book_id >= start_index and book_id < start_index + 80
