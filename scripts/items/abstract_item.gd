extends "res://scripts/object.gd"

const POWER_UP_TYPE_HP = 0
const POWER_UP_TYPE_POWER = 1

var id = 0
var power_up_amount = 1
var power_up_type = POWER_UP_TYPE_HP

func _init(bag).(bag):
    self.initial_position = Vector2(0, 0)

func die():
    self.bag.items.del_item(self)
    self.bag.game_state.current_cell.del_item(self)
    self.despawn()

func pick():
    self.die()

