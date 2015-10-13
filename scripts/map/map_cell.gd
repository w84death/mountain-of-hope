
var bag

var x
var y

var template_name

var north = null
var south = null
var east = null
var west = null

var clear = false
var items_loaded = false
var items = {}

var persistent_objects = []

func _init(bag):
    self.bag = bag

func has_free_connections():
    return self.north == null || self.south == null || self.east == null || self.west == null

func add_item(item):
    self.items[item.get_instance_ID()] = item

func del_item(item):
    self.items.erase(item.get_instance_ID())

func detach_persistent_objects():
    for object in self.persistent_objects:
        self.bag.action_controller.detach_object(object[0])

func attach_persisten_objects():
    for object in self.persistent_objects:
        self.bag.action_controller.attach_object(object[0])
        object[0].set_pos(object[1])

func add_persistent_object(object, position):
    self.persistent_objects.append([object, position])
    self.bag.action_controller.attach_object(object)
    object.set_pos(position)
