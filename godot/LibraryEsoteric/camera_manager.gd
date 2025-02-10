@tool
extends Node

@export var camera: Camera3D;

# Return +inf if no camera has been defined yet
func get_distance_to_nearest_camera(other_object: Node3D) -> float:
	if !Engine.is_editor_hint():
		if camera == null:
			return INF
		else:
			return camera.global_position.distance_to(other_object.global_position)
	else:
		var nearest_camera: float = INF
		#TODO: figure out how to detect which camera are actives!
		for viewport_id in range(4):
			var viewport_3d: SubViewport = EditorInterface.get_editor_viewport_3d(viewport_id)
			
			if viewport_3d == null:
				continue
			var distance: float = viewport_3d.get_camera_3d().global_position.distance_to(other_object.global_position)
			if distance < nearest_camera:
				nearest_camera = distance
			break #temporary, until I can detect which cameras are active
		return nearest_camera
