
var bag

var item_templates = {
    'cheese' : preload("res://scripts/items/cheese.gd"),
    'medicals' : preload("res://scripts/items/medicals.gd")
}

var items_list = {}

func reset():
    for instance_id in self.items_list:
        self.items_list[instance_id].detach()
    self.items_list.clear()

func _init_bag(bag):
    self.bag = bag

func add_item(item):
    self.items_list[item.get_instance_ID()] = item

func del_item(item):
    self.items_list.erase(item.get_instance_ID())

func spawn(name, map_position):
    var new_item = self.item_templates[name].new(self.bag)
    var global_position = self.bag.room_loader.translate_position(map_position)
    new_item.spawn(global_position)
    self.add_item(new_item)

    return new_item

func get_items_near_object(object):
    var results = []
    for instance_id in self.items_list:
        if self.items_list[instance_id].calculate_distance_to_object(object) < 30:
            results.append(self.items_list[instance_id])

    return results




