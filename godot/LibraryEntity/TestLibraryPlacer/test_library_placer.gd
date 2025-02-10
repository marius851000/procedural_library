extends Node3D

@export var distance_per_element: float = 2 # meter
@export var diameter: float = 10 # meter

func _enter_tree() -> void:
	var radius = diameter / 2
	var circumference = radius * TAU
	var element_to_place_count = circumference / distance_per_element
	
	for i in range(element_to_place_count):
		var proportion: float = float(i) / float(element_to_place_count)
		var value1: float = sin(proportion * TAU) * radius
		var value2: float = cos(proportion * TAU) * radius
		var test_shelf = preload("res://LibraryEntity/Shelf/SimpleTestShelf/SimpleTestShelf.tscn")
		var instanciated = test_shelf.instantiate()
		instanciated.position = Vector3(value1, 0, value2)
		instanciated.rotation = Vector3(0, proportion * TAU - PI, 0)
		add_child(instanciated)
