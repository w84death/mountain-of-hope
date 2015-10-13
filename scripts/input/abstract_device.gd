
var handled_input_types = []
var device_id = null

var event_handlers = []

func can_handle(event):
    for type in self.handled_input_types:
        if event.type == type:
            if self.device_id != null:
                if event.device == self.device_id:
                    return true
            else:
                return true
    return false

func register_handler(handler):
    self.event_handlers.append(handler)

func handle_event(event):
    for handler in self.event_handlers:
        handler.handle(event)