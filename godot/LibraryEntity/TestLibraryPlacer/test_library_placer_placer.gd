extends Node3D

@export var concentric_circle_count: int = 1;
@export var first_circle_radius: float = 4;
@export var radius_extra_step: float = 3:
	set(value):
		if (value >= 1):
			radius_extra_step = value;

func _enter_tree() -> void:
	var to_instanciate = preload("res://LibraryEntity/TestLibraryPlacer/test_library_placer.tscn")	
	for i in range(concentric_circle_count):
		var this_radius = first_circle_radius + i * radius_extra_step
		var child = to_instanciate.instantiate()
		child.diameter = this_radius * 2
		add_child(child)
		
