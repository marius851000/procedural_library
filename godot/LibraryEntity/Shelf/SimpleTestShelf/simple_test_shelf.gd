@tool
extends LibraryLOD

func _init():
	remove_child_on_low = false

func get_max_supported_length():
	return $BookLine.get_max_supported_length() + $BookLine2.get_max_supported_length() +  $BookLine3.get_max_supported_length() + $BookLine4.get_max_supported_length()

func _load_static():
	if !Engine.is_editor_hint():
		var remaining_length_to_allocate = book_start_distance_mm + self.book_max_length_mm
		
		$BookLine.book_start_distance_mm = book_start_distance_mm
		$BookLine.book_max_length_mm = min(remaining_length_to_allocate, $BookLine.get_max_supported_length())
		remaining_length_to_allocate -= $BookLine.book_max_length_mm
		
		$BookLine2.book_start_distance_mm = $BookLine.book_start_distance_mm + $BookLine.book_max_length_mm
		$BookLine2.book_max_length_mm = min(remaining_length_to_allocate, $BookLine2.get_max_supported_length())
		remaining_length_to_allocate -= $BookLine2.book_max_length_mm
		
		$BookLine3.book_start_distance_mm = $BookLine2.book_start_distance_mm + $BookLine2.book_max_length_mm
		$BookLine3.book_max_length_mm = min(remaining_length_to_allocate, $BookLine3.get_max_supported_length())
		remaining_length_to_allocate -= $BookLine3.book_max_length_mm
		
		$BookLine4.book_start_distance_mm = $BookLine3.book_start_distance_mm + $BookLine2.book_max_length_mm
		$BookLine4.book_max_length_mm = min(remaining_length_to_allocate, $BookLine3.get_max_supported_length())
		remaining_length_to_allocate -= $BookLine4.book_max_length_mm
