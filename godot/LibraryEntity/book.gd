extends Node3D

@export var book_id: int
var book_title: String

func _ready() -> void:
	book_title = $"/root/GlobalLibrary".get_book_title(book_id)
	$"Label".set("text", book_title)
	print(book_title)
