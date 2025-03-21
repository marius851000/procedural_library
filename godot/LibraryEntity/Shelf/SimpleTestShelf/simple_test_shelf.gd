@tool
extends LibraryLOD

func _init():
	remove_child_on_low = false
	book_length_mm = 1000 + 700 + 300 + 800

func _load_static():
	if !Engine.is_editor_hint():
		$BookLine.book_start_distance_mm = book_start_distance_mm
		$BookLine2.book_start_distance_mm = $BookLine.book_start_distance_mm + $BookLine.book_length_mm
		$BookLine3.book_start_distance_mm = $BookLine2.book_start_distance_mm + $BookLine2.book_length_mm
		$BookLine4.book_start_distance_mm = $BookLine3.book_start_distance_mm + $BookLine3.book_length_mm
