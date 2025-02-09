extends Node3D

@export var root: LibraryLOD;
@export var position_book_to_find: int;

func _process(_dt: float):
	self.global_position = self.root.get_book_position(position_book_to_find)
	
