

var bag
var tilemap
var room_max_size = Vector2(20, 12)
var side_offset = 3
var DOORS_CLOSED = 3
var DOORS_OPEN = 2

var spawns = {
    'initial0' : Vector2(8, 5),
    'initial1' : Vector2(9, 5),
    'initial2' : Vector2(8, 6),
    'initial3' : Vector2(9, 6),
    'north0' : Vector2(8, 1),
    'north1' : Vector2(9, 1),
    'north2' : Vector2(8, 2),
    'north3' : Vector2(9, 2),
    'south0' : Vector2(8, 9),
    'south1' : Vector2(9, 9),
    'south2' : Vector2(8, 8),
    'south3' : Vector2(9, 8),
    'east0' : Vector2(15, 5),
    'east1' : Vector2(14, 5),
    'east2' : Vector2(15, 6),
    'east3' : Vector2(14, 6),
    'west0' : Vector2(1, 5),
    'west1' : Vector2(2, 5),
    'west2' : Vector2(1, 6),
    'west3' : Vector2(2, 6),
}

var room_templates = {
    'start' : preload("res://scripts/map/rooms/start_room.gd"),
    'easy1' : preload("res://scripts/map/rooms/easy1_room.gd"),
    'easy2' : preload("res://scripts/map/rooms/easy2_room.gd"),
    'easy3' : preload("res://scripts/map/rooms/easy3_room.gd"),
    'easy4' : preload("res://scripts/map/rooms/easy4_room.gd"),
    'easy5' : preload("res://scripts/map/rooms/easy5_room.gd"),
    'easy6' : preload("res://scripts/map/rooms/easy6_room.gd"),
    'boss1' : preload("res://scripts/map/rooms/boss1_room.gd"),
    'boss2' : preload("res://scripts/map/rooms/boss2_room.gd"),
    'pickup1' : preload("res://scripts/map/rooms/pickup1_room.gd"),
    'pickup2' : preload("res://scripts/map/rooms/pickup2_room.gd"),
}

var difficulty_templates = [
    ['start'],
    ['easy1', 'easy2', 'easy4', 'easy5', 'easy6'],
    ['easy2', 'easy3', 'easy4', 'easy6'],
    ['easy2', 'easy3', 'easy4', 'easy6'],
]

var difficulty_pickups = [
    [],
    ['pickup1'],
    ['pickup1', 'pickup2'],
    ['pickup2'],
]

var difficulty_bosses = [
    [],
    ['boss1'],
    ['boss1'],
    ['boss2'],
]


var door_definitions = {
    'north' : [
        [0, 0, 14, 21],
        [1, 0, 0, 19],
        [2, 0, 13, 20],
    ],
    'south' : [
        [0, 0, 16, 26],
        [1, 0, 0, 27],
        [2, 0, 15, 28],
    ],
    'east' : [
        [0, 0, 13, 17],
        [0, 1, 0, 22],
        [0, 2, 15, 24],
    ],
    'west' : [
        [0, 0, 14, 18],
        [0, 1, 0, 23],
        [0, 2, 16, 25],
    ],
}

func _init_bag(bag):
    self.bag = bag
    self.tilemap = self.bag.action_controller.tilemap

func load_room(cell):
    var template_name = cell.template_name
    var data
    self.clear_space()
    self.bag.game_state.current_room = self.room_templates[template_name].new()
    data = self.create_passages(self.bag.game_state.current_room.room, cell)
    self.apply_room_data(data)
    if self.bag.game_state.current_room.enemies.size() > 0 && not cell.clear:
        self.spawn_enemies(self.bag.game_state.current_room.enemies)
        self.close_doors()
    else:
        self.open_doors()
    self.bag.items.reset()
    if cell.items_loaded:
        self.load_previous_items(cell.items)
    else:
        self.spawn_items(self.bag.game_state.current_room.items, cell)
        cell.items_loaded = true

func create_passages(data, cell):
    if cell.north != null:
        data = self.open_passage(data, self.door_definitions['north'], 7, 0)
    if cell.south != null:
        data = self.open_passage(data, self.door_definitions['south'], 7, 10)
    if cell.east != null:
        data = self.open_passage(data, self.door_definitions['east'], 16, 4)
    if cell.west != null:
        data = self.open_passage(data, self.door_definitions['west'], 0, 4)
    return data

func open_passage(data, passage, x, y):
    for tile in passage:
        data[tile[1] + y][tile[0] + x] = tile[2]
    return data

func close_doors():
    self.bag.game_state.doors_open = false
    self.switch_doors(self.DOORS_CLOSED)

func open_doors():
    self.bag.game_state.doors_open = true
    self.switch_doors(self.DOORS_OPEN)

func switch_custom_doors(tile_index):
    for custom_door in self.bag.game_state.current_room.doors:
        self.apply_door(self.door_definitions[custom_door[2]], tile_index, custom_door[0], custom_door[1])

func switch_doors(tile_index):
    var cell = self.bag.game_state.current_cell
    if cell.north != null:
        self.apply_door(self.door_definitions['north'], tile_index, 7, 0)
    if cell.south != null:
        self.apply_door(self.door_definitions['south'], tile_index, 7, 10)
    if cell.east != null:
        self.apply_door(self.door_definitions['east'], tile_index, 16, 4)
    if cell.west != null:
        self.apply_door(self.door_definitions['west'], tile_index, 0, 4)
    self.switch_custom_doors(tile_index)

func apply_door(definition, tile_index, x, y):
    for tile in definition:
        self.tilemap.set_cell(tile[0] + self.side_offset + x, tile[1] + y, tile[tile_index])

func clear_space():
    for x in range(self.room_max_size.x):
        for y in range(self.room_max_size.y):
            self.tilemap.set_cell(x, y, -1)

func apply_room_data(data):
    var row
    for y in range(0, data.size()):
        row = data[y]
        for x in range(0, row.size()):
            self.tilemap.set_cell(x + self.side_offset, y, data[y][x])

func spawn_enemies(enemies):
    var position = Vector2(0, 0)
    var enemy_name
    self.bag.enemies.reset()
    for enemy_data in enemies:
        position.x = enemy_data[0] + self.side_offset
        position.y = enemy_data[1]
        if enemy_data[2] == null:
            enemy_name = self.bag.enemies.get_random_enemy_name(enemy_data[3])
        else:
            enemy_name = enemy_data[2]
        self.bag.enemies.spawn(enemy_name, position)

func spawn_items(items, cell):
    var position = Vector2(0, 0)
    for item_data in items:
        position.x = item_data[0] + self.side_offset
        position.y = item_data[1]
        cell.add_item(self.bag.items.spawn(item_data[2], position))

func load_previous_items(items):
    for item in items:
        items[item].attach()
        self.bag.items.add_item(items[item])

func get_spawn_position(spawn_name):
    var position = self.get_spawn_position_on_map(spawn_name)
    return self.translate_position(position)

func get_spawn_position_on_map(spawn_name):
    var position = self.bag.room_loader.spawns[spawn_name]
    position.x = position.x + self.side_offset
    return position

func translate_position(position):
    return self.tilemap.map_to_world(position)