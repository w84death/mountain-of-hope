
var bag
var camera

func _ready():
    self.camera = self.get_node("/root/root/Camera2D")
    self.bag = preload("res://scripts/dependency_bag.gd").new(self)
    self.set_process_input(true)
    self.set_fixed_process(true)

func _input(event):
    self.bag.input.handle_event(event)

func _fixed_process(delta):
    self.bag.processing.process(delta)