extends "res://scripts/input/handlers/gamepad_handler.gd"

var bag
var player

func _init(bag, player, axis):
    self.bag = bag
    self.player = player
    self.type = InputEvent.JOYSTICK_MOTION
    self.axis = axis

func handle(event):
    if self.bag.game_state.game_in_progress && self.player.is_playing && self.player.is_alive:
        self.player.target_cone_vector[self.axis - 2] = event.value