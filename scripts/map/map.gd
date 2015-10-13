
var bag

var map = []
var cells = []
var start_cell

var cell_template = preload("res://scripts/map/map_cell.gd")

var tilesets = [
    preload("res://scenes/levels/main_tileset1.res"),
    preload("res://scenes/levels/main_tileset2.res"),
    preload("res://scenes/levels/main_tileset3.res"),
    preload("res://scenes/levels/main_tileset4.res"),
]

func _init_bag(bag):
    self.bag = bag
    self.reset_map()

func reset_map():
    self.map = [
        [null, null, null, null, null, null, null, null, null],
        [null, null, null, null, null, null, null, null, null],
        [null, null, null, null, null, null, null, null, null],
        [null, null, null, null, null, null, null, null, null],
        [null, null, null, null, null, null, null, null, null],
        [null, null, null, null, null, null, null, null, null],
        [null, null, null, null, null, null, null, null, null],
        [null, null, null, null, null, null, null, null, null],
        [null, null, null, null, null, null, null, null, null],
    ]
    self.cells = []
    self.start_cell = self.add_cell('start', 5, 5)

func add_cell(room_template_name, x, y):
    var cell = self.cell_template.new(self.bag)
    cell.x = x
    cell.y = y
    cell.template_name = room_template_name
    self.map[y][x] = cell
    self.cells.append(cell)
    self.connect_room(cell)
    return cell

func connect_room(cell):
    self.connect_room_cell(cell, cell.x, cell.y - 1, 'north')
    self.connect_room_cell(cell, cell.x, cell.y + 1, 'south')
    self.connect_room_cell(cell, cell.x + 1, cell.y, 'east')
    self.connect_room_cell(cell, cell.x - 1, cell.y, 'west')

func connect_room_cell(cell, x, y, direction):
    if x < 0 || x >= self.map[0].size() || y < 0 || y >= self.map.size() || self.map[y][x] == null:
        return
    var neighbour_cell = self.map[y][x]
    if direction == 'north':
        cell.north = neighbour_cell
        neighbour_cell.south = cell
    elif direction == 'south':
        cell.south = neighbour_cell
        neighbour_cell.north = cell
    elif direction == 'east':
        cell.east = neighbour_cell
        neighbour_cell.west = cell
    elif direction == 'west':
        cell.west = neighbour_cell
        neighbour_cell.east = cell

func generate_map(level):
    var level_settings = self.bag.game_state.levels[level]
    var room_count = level_settings['rooms']
    var pickup_count = level_settings['pickup_rooms']
    var difficulty = level_settings['room_difficulty']
    var tileset = level_settings['tileset']
    self.reset_map()
    for i in range(room_count):
        self.randomize_cell(difficulty, self.bag.room_loader.difficulty_templates)
    for i in range(pickup_count):
        self.randomize_cell(difficulty, self.bag.room_loader.difficulty_pickups)
    self.randomize_cell(difficulty, self.bag.room_loader.difficulty_bosses)

    self.bag.room_loader.tilemap.set_tileset(self.tilesets[tileset])

func randomize_cell(difficulty, room_collection):
    var free_cell
    var free_spot
    var room_type
    var new_cell
    free_cell = self.pick_random_free_cell()
    if free_cell != null:
        free_spot = self.pick_random_free_neighbout_spot(free_cell)
        room_type = self.pick_random_room_type(difficulty, room_collection)
        self.add_cell(room_type, free_spot.x, free_spot.y)


func pick_random_free_cell():
    var available_cells = []
    for cell in self.cells:
        if cell.has_free_connections():
            available_cells.append(cell)
    randomize()
    if available_cells.size() == 0:
        return null
    return available_cells[randi() % available_cells.size()]

func pick_random_free_neighbout_spot(cell):
    var directions = []
    var randomed
    if cell.north == null && cell.y - 1 >= 0:
        directions.append('north')
    if cell.south == null && cell.y + 1 < self.map.size():
        directions.append('south')
    if cell.east == null && cell.x + 1 < self.map[0].size():
        directions.append('east')
    if cell.west == null && cell.x - 1 >= 0:
        directions.append('west')
    randomize()
    randomed = directions[randi() % directions.size()]
    if randomed == 'north':
        return Vector2(cell.x, cell.y - 1)
    if randomed == 'south':
        return Vector2(cell.x, cell.y + 1)
    if randomed == 'east':
        return Vector2(cell.x + 1, cell.y)
    if randomed == 'west':
        return Vector2(cell.x - 1, cell.y)

func pick_random_room_type(difficulty, collection):
    var on_level_templates = collection[difficulty]
    randomize()
    return on_level_templates[randi() % on_level_templates.size()]

func switch_to_cell(cell):
    if self.bag.game_state.current_cell != null:
        self.bag.game_state.current_cell.detach_persistent_objects()
    self.bag.game_state.current_cell = cell
    self.bag.room_loader.load_room(cell)
    cell.attach_persisten_objects()
