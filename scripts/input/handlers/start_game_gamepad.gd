extends "res://scripts/input/handlers/gamepad_handler.gd"

var bag

func _init(bag):
    self.bag = bag
    self.type = InputEvent.JOYSTICK_BUTTON
    self.button_index = JOY_BUTTON_9

func handle(event):
    if event.is_pressed() && not self.bag.game_state.game_in_progress:
        self.bag.action_controller.start_game()