extends Node3D
class_name LibraryLOD

signal post_load
signal pre_unload

@export var unique_library_child_id: String;
@export var parent_lod: LibraryLOD;
@export var unload_distance: float = 2.0;
@export var load_distance: float = 1.0;
var use_lod: bool = true;
var is_high_lod: bool = false;

var childs_lod: Array[LibraryLOD] = [];

func _ready():
	process_lod()

func register_child_lod(child_lod: LibraryLOD):
	self.childs_lod.push_back(child_lod)
	child_lod.set("parent_lod", self)

func does_contain_book_by_default(book_id: int) -> bool:
	return false

func _unload_static():
	pass

func unload():
	if not is_high_lod or not use_lod:
		return
	_unload_static()
	for child in childs_lod:
		if is_instance_valid(child):
			child.queue_free()
	childs_lod.clear()
	is_high_lod = false
	
func _load_static():
	pass

func load():
	if is_high_lod:
		return
	_load_static()
	is_high_lod = true

func process_lod():
	if use_lod:
		var calculated_distance = $"/root/CameraManager".get_distance_to_nearest_camera(self);
		if is_high_lod:
			if calculated_distance > unload_distance:
				unload()
		else:
			if calculated_distance < load_distance:
				self.load()

func _process(dt: float):
	process_lod()
