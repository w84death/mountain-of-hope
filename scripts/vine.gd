
extends KinematicBody2D

# member variables here, example:
# var a=2
# var b="textvar"

func _ready():
	self.get_node("AnimationPlayer").seek(randi()%2, true)
	pass


