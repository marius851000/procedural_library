extends Node

@export var camera: Camera3D;

# Return +inf if no camera has been defined yet
func get_distance_to_nearest_camera(other_object: Node3D) -> float:
	if camera == null:
		return INF
	else:
		return camera.global_position.distance_to(other_object.global_position)
