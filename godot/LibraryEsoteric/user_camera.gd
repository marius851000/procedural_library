extends SimpleFreeLookCamera3D

func _ready() -> void:
	$"/root/CameraManager".set("camera", self)
