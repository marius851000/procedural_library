extends LibraryLOD

@export var start_index: int;
# Contain 80 books (TODO: find a better way to manage those book range)

func _load_static():
	$BookLine.set("start_index", start_index)
	$BookLine2.set("start_index", start_index + 20)
	$BookLine3.set("start_index", start_index + 40)
	$BookLine4.set("start_index", start_index + 60)
	#TODO: add those bookline in the list of child LOD, but do not remove them on unload (need to change BookLine so it still remove its own child)
	#TODO: also, disable LOD processing on the child. Maybe rewrite it with signals instead.
	
