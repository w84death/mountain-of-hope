extends "res://scripts/input/handlers/gamepad_handler.gd"

var bag
var player

func _init(bag, player):
    self.bag = bag
    self.player = player
    self.type = InputEvent.JOYSTICK_BUTTON
    self.button_index = JOY_BUTTON_7

func handle(event):
    if event.is_pressed() && self.bag.game_state.game_in_progress && self.player.is_playing && self.player.is_alive:
        self.player.attack()