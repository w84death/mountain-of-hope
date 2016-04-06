extends "res://scripts/input/handlers/gamepad_handler.gd"

var bag

func _init(bag):
    self.bag = bag
    self.type = InputEvent.JOYSTICK_BUTTON
    self.button_index = 21

func handle(event):
    if event.is_pressed() && self.bag.game_state.game_in_progress:
        self.bag.action_controller.end_game()