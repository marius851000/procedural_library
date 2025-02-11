@tool
extends Node

# A global root node that will periodicly call the lod-related pooling function on registered child node
# Does this here instead of the root node due to working in the editor

var registered_node: Array[LibraryLOD] = [];

func register_node(node: LibraryLOD):
	node.tree_exited.connect(_registered_node_removed.bind(node))
	registered_node.push_back(node)

func _registered_node_removed(node: LibraryLOD):
	node.tree_exited.disconnect(_registered_node_removed.bind(node))
	for i in range(registered_node.size()):
		if registered_node[i] == node:
			registered_node.remove_at(i)
			break


func _process(_dt: float):
	#TODO: actually call that 10 time per second (approx) with increasing number
	for child in registered_node:
		child.process_lod_maybe(0)
