@tool
extends LibraryLOD

func _init():
	self.use_lod = false
	self.remove_child_on_low = false

func _enter_tree() -> void:
	self.allocation = BookAllocator.new();
	self.allocation.start = 0;
	self.allocation.size = self.get_max_supported_length();
	super._enter_tree()
	
func get_max_supported_length() -> int:
	if !Engine.is_editor_hint():
		return $"/root/GlobalLibrary".get_library_length()
	else:
		return 1 << 63

func contain_book(_book_start_position: int) -> bool:
	return true
