extends Node

@export var camera: Camera3D;

func get_distance_to_nearest_camera(other_object: Node3D) -> float:
	return camera.global_position.distance_to(other_object.global_position)
