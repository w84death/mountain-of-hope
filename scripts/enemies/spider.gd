extends "res://scripts/enemies/abstract_enemy.gd"


func _init(bag).(bag):
    self.avatar = preload("res://scenes/enemies/spider.xscn").instance()
    self.body_part_head = self.avatar.get_node('body')
    self.body_part_body = self.avatar.get_node('body')
    self.body_part_footer = self.avatar.get_node('body')

    self.aggro_range = 550
    self.attack_range = 40
    self.velocity = 110
    self.score = 10
