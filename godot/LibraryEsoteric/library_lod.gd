@tool
extends Node3D
class_name LibraryLOD

var parent_lod: LibraryLOD:
	set(value):
		if parent_lod != null:
			if parent_lod.tree_exiting.is_connected(_parent_lod_exiting):
				parent_lod.tree_exiting.disconnect(_parent_lod_exiting)
		if value != null:
			value.tree_exiting.connect(_parent_lod_exiting, Object.CONNECT_ONE_SHOT)
		parent_lod = value

func _parent_lod_exiting():
	self.parent_lod = null
		
# -1 is the default value, equivalent to null
@export var book_start_distance_mm: int = -1;

# The maximum book length this element and their childs are allowed to have.
# May be lower than the max supported length, returned by get_max_supported_length.
# May also be 0
# -1 will set it to the max supported length, unless it would go over the parent’s book_max_length_mm (when entering tree)
@export var book_max_length_mm: int = -1:
	set(value):
		book_max_length_mm = value
		process_lod(Engine.is_editor_hint())
var is_book_max_length_mm_final: bool = false

@export var unload_distance: float = 2.0;
@export var load_distance: float = 1.0;
#TODO: can’t I make them overrideable constant? It should optimise better.
# Will not reduce the level of detail of this element if false. It will stay at high whatever happen, and _unload_static will never be called
var use_lod = true;
# if true, will free the registered child LOD
# if false, will put registered child at low lod and disable LOD update for them. It won’t deregister them.
var remove_child_on_low = true;
var lod_level: int = -1; # 0 is high, 1 is low, -1 is when unload
@export var auto_allocate_if_needed = true;

var childs_lod: Array[LibraryLOD] = [];

func _enter_tree() -> void:
	find_and_register_with_parent()
	
	if !Engine.is_editor_hint():
		assert(self.get_max_supported_length() > 0)
		if self.book_max_length_mm < 0:
			self.book_max_length_mm = self.get_max_supported_length()
		
		# limit book_max_length_mm to what the parent can handle
		if parent_lod != null:
			var parent_remaining_space: int = parent_lod.space_remaining_to_allocate()
			assert(parent_remaining_space >= 0)
			if self.book_max_length_mm > parent_remaining_space:
				self.book_max_length_mm = parent_remaining_space
		is_book_max_length_mm_final = true
	
		if self.book_start_distance_mm < 0 and auto_allocate_if_needed:
			if self.parent_lod == null:
				self.book_start_distance_mm = 0
			else:
				self.book_start_distance_mm = self.parent_lod.allocate_book_range(book_max_length_mm)

	process_lod(true)

# The value returned should stay constant
func get_max_supported_length() -> int:
	return 0

# max only be called during or after _on_enter_tree, only after this one book_max_length_mm has been set
func space_remaining_to_allocate():
	var space_remaining: int = self.book_max_length_mm
	assert(space_remaining >= 0)
	for child in childs_lod:
		if child.is_book_max_length_mm_final:
			space_remaining -= child.book_max_length_mm
			assert(space_remaining >= 0)
	return space_remaining

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

func allocate_book_range(_length: int) -> int:
	assert(false, "allocate book range called on an invalid LibraryLOD")
	return -1

func register_child_lod(child_lod: LibraryLOD):
	child_lod.tree_exiting.connect(_on_child_lod_exiting.bind(child_lod), Object.CONNECT_ONE_SHOT)
	self.childs_lod.push_back(child_lod)
	child_lod.set("parent_lod", self)

func _on_child_lod_exiting(child_node: LibraryLOD):
	for i in range(self.childs_lod.size()):
		if self.childs_lod[i] == child_node:
			self.childs_lod.remove_at(i)
			break

func does_contain_book_by_default(book_start_position: int) -> bool:
	return book_start_distance_mm <= book_start_position and book_start_distance_mm + book_max_length_mm > book_start_position

func get_book_position(book_start_position: int) -> Vector3:
	for child in childs_lod:
		if child.does_contain_book_by_default(book_start_position):
			return child.get_book_position(book_start_position)
	return self.global_position
	
func _unload_static():
	pass

func unload(force: bool):
	if (lod_level == 1 or not use_lod):
		if force:
			self.load(false)
		else:
			return
	_unload_static()
	for child in childs_lod:
		if is_instance_valid(child):
			if remove_child_on_low:
				child.queue_free()
			else:
				child.unload(false)
	if remove_child_on_low:
		childs_lod.clear()
	lod_level = 1

func _load_static():
	pass

func load(force: bool):
	if lod_level == 0:
		if force:
			self.unload(false)
		else:
			return
	_load_static()
	lod_level = 0

func process_lod(force: bool):
	if !is_inside_tree():
		return
	if lod_level == -1:
		force = true
	if use_lod:
		var calculated_distance: float = $"/root/CameraManager".get_distance_to_nearest_camera(self);
		#print(self.to_string() + " .. " + str(calculated_distance))
		if force:
			if calculated_distance > unload_distance:
				unload(force)
			else:
				self.load(force)
		else:
			if lod_level == 0:
				if calculated_distance > unload_distance:
					unload(force)
			else:
				if calculated_distance < load_distance:
					self.load(force)
	else:
		self.load(force)
		

# Will call this function 10 time per second (by default).
# marker_number will loop from 0 to 0xFFFF at each call.
func process_lod_maybe(marker_number: int):
	process_lod(false)
	if lod_level == 0:
		for child in childs_lod:
			child.process_lod_maybe(marker_number)
