extends "res://scripts/input/handlers/mouse_handler.gd"

var bag
var player

func _init(bag, player):
    self.bag = bag
    self.player = player
    self.type = InputEvent.MOUSE_MOTION

func handle(event):
    var position
    if self.bag.game_state.game_in_progress && self.player.is_playing && self.player.is_alive:
        position = player.get_screen_pos()
        self.player.target_cone_vector[0] = event.x - position.x
        self.player.target_cone_vector[1] = event.y - position.y