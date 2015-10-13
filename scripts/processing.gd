
var bag

var ready = false

var objects = {}

func _init_bag(bag):
    self.bag = bag
    self.ready = true

func register(object):
    self.objects[object.get_instance_ID()] = object

func remove(object):
    self.objects.erase(object.get_instance_ID())

func process(delta):
    if not self.ready:
        return

    for id in self.objects:
        if self.objects[id].is_processing:
            self.objects[id].process(delta)

func reset():
    self.objects.clear()
