extends "res://scripts/items/abstract_item.gd"

var body

func _init(bag).(bag):
    self.avatar = preload("res://scenes/items/cheese.xscn").instance()
    self.body = self.avatar.get_node('body')
    self.randomize_frame()


func randomize_frame():
    randomize()
    self.body.set_frame(randi() % self.body.get_hframes())
