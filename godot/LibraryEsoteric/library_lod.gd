@tool
extends Node3D
class_name LibraryLOD

var parent_lod: LibraryLOD:
	set(value):
		if parent_lod != null:
			parent_lod.tree_exiting.disconnect(_parent_lod_exiting)
		if value != null:
			value.tree_exiting.connect(_parent_lod_exiting)
		parent_lod = value

func _parent_lod_exiting():
	self.parent_lod.tree_exiting.disconnect(_parent_lod_exiting)
	self.parent_lod = null
		
# -1 is the default value, equivalent to null
@export var book_start_distance_mm: int = -1;
@export var book_length_mm: int = -1:
	set(value):
		book_length_mm = value
		process_lod(Engine.is_editor_hint())

func _set_book_length_mm(value: int):
	book_length_mm = value

@export var unload_distance: float = 2.0;
@export var load_distance: float = 1.0;
#TODO: can’t I make them overrideable constant? It should optimise better.
var use_lod = true;
# if true, will free the registered child LOD
# if false, will put registered child at low lod and disable LOD update for them. It won’t deregister them.
var remove_child_on_low = true;
var is_high_lod = false;
@export var auto_allocate_if_needed = true;

var childs_lod: Array[LibraryLOD] = [];

func _enter_tree() -> void:
	find_and_register_with_parent()
	if self.book_start_distance_mm == -1 and auto_allocate_if_needed and !Engine.is_editor_hint():
		if self.parent_lod == null:
			self.book_start_distance_mm = 0
		else:
			assert(book_length_mm != -1)
			self.book_start_distance_mm = self.parent_lod.allocate_book_range(book_length_mm)
	
	if parent_lod != null:
		# given this node is also included in the parent’s child, account for that
		var parent_sum_of_child_distance_without_this: int = parent_lod.sum_of_child_distance() - self.book_length_mm
		var parent_remaining_space: int = parent_lod.book_length_mm - parent_sum_of_child_distance_without_this
		if parent_remaining_space < self.book_length_mm:
			if parent_remaining_space < 0:
				self.book_length_mm = 0
			else:
				self.book_length_mm = parent_remaining_space
			
	process_lod(true)

func sum_of_child_distance() -> int:
	var sum: int = 0
	for child in childs_lod:
		sum += child.book_length_mm
	return sum

func find_and_register_with_parent():
	var considering_parent = self
	while true:
		considering_parent = considering_parent.get_parent()
		if considering_parent == null:
			break
		if is_instance_of(considering_parent, LibraryLOD):
			break
	
	if considering_parent == null:
		$"/root/LibraryLodPoller".register_node(self)
	else:
		self.parent_lod = considering_parent
		self.parent_lod.register_child_lod(self)

func allocate_book_range(length: int) -> int:
	assert(false, "allocate book range called on an invalid LibraryLOD")
	return -1

func register_child_lod(child_lod: LibraryLOD):
	self.childs_lod.push_back(child_lod)
	child_lod.set("parent_lod", self)

func does_contain_book_by_default(book_start_position: int) -> bool:
	return book_start_distance_mm <= book_start_position and book_start_distance_mm + book_length_mm > book_start_position

func get_book_position(book_start_position: int) -> Vector3:
	for child in childs_lod:
		if child.does_contain_book_by_default(book_start_position):
			return child.get_book_position(book_start_position)
	return self.global_position
	
func _unload_static():
	pass

func unload():
	if not is_high_lod or not use_lod:
		return
	_unload_static()
	for child in childs_lod:
		if is_instance_valid(child):
			if remove_child_on_low:
				child.queue_free()
			else:
				child.unload()
	if remove_child_on_low:
		childs_lod.clear()
	is_high_lod = false

func _load_static():
	pass

func load():
	if is_high_lod:
		return
	_load_static()
	is_high_lod = true

func process_lod(force: bool):
	if !is_inside_tree():
		return
	if use_lod:
		var calculated_distance: float = $"/root/CameraManager".get_distance_to_nearest_camera(self);
		#print(self.to_string() + " .. " + str(calculated_distance))
		if is_high_lod:
			if calculated_distance > unload_distance or force:
				unload()
		else:
			if calculated_distance < load_distance or force:
				self.load()
	else:
		self.load()

# Will call this function 10 time per second (by default).
# marker_number will loop from 0 to 0xFFFF at each call.
func process_lod_maybe(marker_number: int):
	process_lod(false)
	if is_high_lod:
		for child in childs_lod:
			child.process_lod_maybe(marker_number)
