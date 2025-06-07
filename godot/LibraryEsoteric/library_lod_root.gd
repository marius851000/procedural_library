@tool
extends LibraryLOD

var next_allocation_start: int = 0;

func _init():
	self.use_lod = false
	self.remove_child_on_low = false

func _enter_tree() -> void:
	super._enter_tree()
	
func get_max_supported_length() -> int:
	if !Engine.is_editor_hint():
		return $"/root/GlobalLibrary".get_library_length()
	else:
		return 1 << 63

func allocate_book_range(length: int) -> int:
	if Engine.is_editor_hint():
		return 0
	else:
		#TODO: make sure to not go over the book_max_length_mm limit
		var to_return = next_allocation_start
		next_allocation_start += length
		return to_return

func does_contain_book_by_default(_book_start_position: int) -> bool:
	return true
