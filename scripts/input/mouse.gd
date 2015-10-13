
extends "res://scripts/input/abstract_device.gd"

func _init():
    self.handled_input_types = [
        InputEvent.MOUSE_MOTION,
        InputEvent.MOUSE_BUTTON,
    ]

func handle_event(event):
    for handler in self.event_handlers:
        if handler.type == event.type:
            if handler.type == InputEvent.MOUSE_BUTTON && handler.button_index == event.button_index:
                handler.handle(event)
            elif handler.type == InputEvent.MOUSE_MOTION:
                handler.handle(event)