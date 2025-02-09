extends LibraryLOD

var next_allocation_start: int = 0;

func _init():
	self.use_lod = false
	self.remove_child_on_low = false

func when_no_parent_is_found(): # expected
	pass

func allocate_book_range(length: int) -> int:
	var to_return = next_allocation_start
	next_allocation_start += length
	return to_return

func does_contain_book_by_default(book_start_position: int) -> bool:
	return true
	
func _process(dt: float):
	#TODO: actually call that 10 time per second (approx) with increasing number
	self.process_lod_maybe(0)
