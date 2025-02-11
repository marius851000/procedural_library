@tool
extends LibraryLOD

var next_allocation_start: int = 0;

func _init():
	self.use_lod = false
	self.remove_child_on_low = false

func _enter_tree() -> void:
	if !Engine.is_editor_hint():
		self.book_length_mm = $"/root/GlobalLibrary".get_library_length()
	super._enter_tree()

func allocate_book_range(length: int) -> int:
	if Engine.is_editor_hint():
		return 0
	else:
		var to_return = next_allocation_start
		next_allocation_start += length
		return to_return

func does_contain_book_by_default(book_start_position: int) -> bool:
	return true
