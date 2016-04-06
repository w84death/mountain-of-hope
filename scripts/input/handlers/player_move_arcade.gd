extends "res://scripts/input/handlers/gamepad_handler.gd"

var bag
var player
var direction

func _init(bag, player, axis, key, direction):
    self.bag = bag
    self.player = player
    self.axis = axis
    self.direction = direction
    self.type = InputEvent.JOYSTICK_BUTTON
    self.button_index = key

func handle(event):
    if event.is_pressed() && self.bag.game_state.game_in_progress && self.player.is_playing && self.player.is_alive:
        self.player.controller_vector[self.axis] = self.player.controller_vector[self.axis] + self.direction
        if abs(self.player.controller_vector[self.axis]) > abs(self.direction):
            self.player.controller_vector[self.axis] = self.direction
    if not event.is_pressed() && self.bag.game_state.game_in_progress && self.player.is_playing && self.player.is_alive:
        self.player.controller_vector[self.axis] = self.player.controller_vector[self.axis] - self.direction