extends "res://scripts/input/abstract_device.gd"

func _init():
    self.handled_input_types = [
        InputEvent.JOYSTICK_MOTION,
        InputEvent.JOYSTICK_BUTTON,
    ]

func handle_event(event):
    for handler in self.event_handlers:
        if handler.type == event.type:
            if (handler.type == InputEvent.JOYSTICK_MOTION && handler.axis == event.axis) or (handler.type == InputEvent.JOYSTICK_BUTTON && handler.button_index == event.button_index):
                handler.handle(event)