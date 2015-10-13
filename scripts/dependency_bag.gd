
var root

var game_state = preload("res://scripts/game_state.gd").new()
var action_controller = preload("res://scripts/controllers/action_controller.gd").new()

var hud = preload("res://scripts/hud/hud.gd").new()
var timers = preload("res://scripts/timers.gd").new()
var input = preload("res://scripts/input/input.gd").new()
var players = preload("res://scripts/players.gd").new()
var enemies = preload("res://scripts/enemies.gd").new()
var items = preload("res://scripts/items.gd").new()
var processing = preload("res://scripts/processing.gd").new()
var camera = preload("res://scripts/camera.gd").new()
var map = preload("res://scripts/map/map.gd").new()
var room_loader = preload("res://scripts/map/room_loader.gd").new()
var sample_player
var stream_player

func _init(root_node):
    self.root = root_node
    self.hud._init_bag(self)
    self.timers._init_bag(self)
    self.game_state._init_bag(self)
    self.input._init_bag(self)
    self.camera._init_bag(self)
    self.players._init_bag(self)
    self.enemies._init_bag(self)
    self.items._init_bag(self)
    self.processing._init_bag(self)
    self.action_controller._init_bag(self)
    self.room_loader._init_bag(self)
    self.map._init_bag(self)
    self.sample_player = self.root.get_node('SamplePlayer')
    self.stream_player = self.root.get_node('StreamPlayer')

func reset():
    self.players.reset()
    self.game_state.reset()
    self.hud.reset()
    self.enemies.reset()
    self.items.reset()
    self.processing.reset()
    self.map.reset_map()
