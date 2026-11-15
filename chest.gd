extends StaticBody2D

func _ready():
	$opened.visible = false
	$closed.visible = true

func _on_key_2_chest_opened() -> void:
	$opened.visible = true
	$closed.visible = false
