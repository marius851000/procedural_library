extends LibraryLOD

func _init():
	self.use_lod = false
	self.remove_child_on_low = false

func when_no_parent_is_found(): # expected
	pass

func _process(dt: float):
	#TODO: actually call that 10 time per second (approx) with increasing number
	self.process_lod_maybe(0)
