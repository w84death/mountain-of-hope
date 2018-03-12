extends "res://scripts/input/handlers/gamepad_handler.gd"

var bag

var state

func _init(bag):
    self.bag = bag
    self.type = InputEvent.JOYSTICK_BUTTON
    self.multi_button = true
    self.state = 0

func handle(event):
    if event.is_pressed() && self.bag.game_state.game_in_progress:

        if self.state == 0 && event.button_index == 16:
            self.state = 1
        elif self.state == 1 && event.button_index == 20:
            self.state = 2
        elif self.state == 2 && event.button_index == 5:
            self.state = 3
        elif self.state == 3 && event.button_index == 3:
            self.state = 4
        elif self.state == 4 && event.button_index == 21:
            self.state = 5
        else:
            self.state = 0

        if self.state == 5:
            OS.get_main_loop().quit()



