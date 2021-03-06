
var bag

var game_board = preload("res://scenes/map/map.xscn").instance()
var tilemap
var z_index

func _init_bag(bag):
    self.bag = bag
    self.tilemap = self.game_board.get_node('level/TileMap/')
    #self.z_index = self.tilemap.get_node('z_index')

func start_game():
    self.bag.game_state.game_in_progress = true
    self.bag.root.get_node('Viewport/board').add_child(self.game_board)
    self.bag.players.spawn_players()
    self.bag.map.generate_next_map_segment()
    self.bag.hud.show()
    self.bag.menu.hide()

func end_game():
    self.bag.game_state.game_in_progress = false
    self.bag.players.reset()
    self.bag.root.remove_child(self.game_board)
    self.bag.hud.hide()
    self.bag.menu.show()
    self.bag.map.reset_map()
    self.bag.reset()

func next_level(next):
    var level_settings
    if next == 'next':
        self.bag.game_state.level = self.bag.game_state.level + 1
        level_settings = self.bag.game_state.levels[self.bag.game_state.level]
        self.bag.map.generate_map(self.bag.game_state.level)
        self.bag.map.switch_to_cell(self.bag.map.start_cell)
        self.bag.players.move_to_entry_position('initial')
    elif next == 'end':
        self.end_game()

func attach_object(object):
    self.game_board.add_child(object)

func detach_object(object):
    self.game_board.remove_child(object)