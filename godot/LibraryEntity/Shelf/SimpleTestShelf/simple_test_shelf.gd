@tool
extends LibraryLOD

func _init():
	remove_child_on_low = false

func get_max_supported_length():
	return $BookLine.get_max_supported_length() + $BookLine2.get_max_supported_length() +  $BookLine3.get_max_supported_length() + $BookLine4.get_max_supported_length()
