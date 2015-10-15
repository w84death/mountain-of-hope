
extends Control

export var button_id = 0

func _ready():
	self.get_node("Sprite").set_frame(self.button_id)
	pass


