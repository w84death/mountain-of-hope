extends "res://scripts/input/abstract_device.gd"

func _init():
    self.handled_input_types = [
        InputEvent.KEY,
    ]

func handle_event(event):
    for handler in self.event_handlers:
        if handler.scancode == event.scancode:
            handler.handle(event)