extends "res://scripts/input/handlers/keyboard_handler.gd"

func _init():
    self.scancode = KEY_ESCAPE

func handle(event):
    if event.is_pressed():
        OS.get_main_loop().quit()