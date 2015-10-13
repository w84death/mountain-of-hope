extends "res://scripts/input/handlers/keyboard_handler.gd"

var bag
var player

func _init(bag, player):
    self.bag = bag
    self.player = player
    self.scancode = KEY_SPACE

func handle(event):
    if event.is_pressed() && self.bag.game_state.game_in_progress && not self.player.is_playing:
        self.player.enter_game()