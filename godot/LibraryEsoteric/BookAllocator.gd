extends RefCounted
class_name BookAllocator

# the start of the allocation. Should stay constant.
@export var start: int;
# the size of the allocation. Should stay constant.
@export var size: int;
# which amount of size has already been allocated, from the beggining. May change. Should stay below size.
@export var allocated_amount: int = 0;

# end of the allocation, inclusive
func get_last() -> int:
	return self.start + self.size

func next_allocation_start() -> int:
	return self.start + self.allocated_amount
	
func allocate(amount: int) -> BookAllocator:
	var result: BookAllocator = BookAllocator.new()
	result.start = next_allocation_start();
	result.allocated_amount = 0;
	if self.size - self.allocated_amount < amount:
		result.size = size - allocated_amount;
		self.allocated_amount = size;
	else:
		result.size = amount;
		self.allocated_amount += amount
	return result


func contain_book_by_default(book_start_position: int) -> bool:
	return book_start_position <= get_last() and book_start_position >= self.start
