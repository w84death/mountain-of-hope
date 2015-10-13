extends "res://scripts/moving_object.gd"

var player_id
var is_playing = false
var is_alive = true
var attack_range = 100
var attack_width = PI * 0.33
var attack_strength = 1
var attack_cooldown = 0.25
var is_attack_on_cooldown = false
var blast

var target_cone
var target_cone_vector = [0, 0]
var target_cone_angle = 0.0

var panel
var hp_cap = 16

var EXIT_THRESHOLD = 30

func _init(bag, player_id).(bag):
    self.bag = bag
    self.player_id = player_id
    self.velocity = 200
    self.hp = 10
    self.max_hp = 10
    self.score = 0
    self.avatar = preload("res://scenes/player/player.xscn").instance()
    self.body_part_head = self.avatar.get_node('head')
    self.hat = self.body_part_head.get_node('hat')
    self.body_part_body = self.avatar.get_node('body')
    self.body_part_footer = self.avatar.get_node('footer')
    self.target_cone = self.avatar.get_node('attack_cone')
    self.animations = self.avatar.get_node('body_animations')
    self.blast = self.avatar.get_node('blast_animations')

    self.bind_gamepad(player_id)
    self.panel = self.bag.hud.bind_player_panel(player_id)
    self.hat.set_frame(player_id)
    self.update_bars()

    self.sounds['hit'] = 'player_hit'
    self.sounds['die'] = 'player_die'
    self.sounds['attack1'] = 'player_attack1'
    self.sounds['attack2'] = 'player_attack2'

func bind_gamepad(id):
    var gamepad = self.bag.input.devices['pad' + str(id)]
    gamepad.register_handler(preload("res://scripts/input/handlers/player_enter_game_gamepad.gd").new(self.bag, self))
    gamepad.register_handler(preload("res://scripts/input/handlers/player_move_axis.gd").new(self.bag, self, 0))
    gamepad.register_handler(preload("res://scripts/input/handlers/player_move_axis.gd").new(self.bag, self, 1))
    gamepad.register_handler(preload("res://scripts/input/handlers/player_cone_gamepad.gd").new(self.bag, self, 2))
    gamepad.register_handler(preload("res://scripts/input/handlers/player_cone_gamepad.gd").new(self.bag, self, 3))
    gamepad.register_handler(preload("res://scripts/input/handlers/player_attack_gamepad.gd").new(self.bag, self))

func bind_keyboard_and_mouse():
    var keyboard = self.bag.input.devices['keyboard']
    var mouse = self.bag.input.devices['mouse']
    keyboard.register_handler(preload("res://scripts/input/handlers/player_enter_game_keyboard.gd").new(self.bag, self))
    keyboard.register_handler(preload("res://scripts/input/handlers/player_move_key.gd").new(self.bag, self, 1, KEY_W, -1))
    keyboard.register_handler(preload("res://scripts/input/handlers/player_move_key.gd").new(self.bag, self, 1, KEY_S, 1))
    keyboard.register_handler(preload("res://scripts/input/handlers/player_move_key.gd").new(self.bag, self, 0, KEY_A, -1))
    keyboard.register_handler(preload("res://scripts/input/handlers/player_move_key.gd").new(self.bag, self, 0, KEY_D, 1))
    mouse.register_handler(preload("res://scripts/input/handlers/player_cone_mouse.gd").new(self.bag, self))
    mouse.register_handler(preload("res://scripts/input/handlers/player_attack_mouse.gd").new(self.bag, self))

func enter_game():
    self.is_playing = true
    self.spawn(self.bag.room_loader.get_spawn_position('initial' + str(self.player_id)))
    self.panel.show()

func spawn(position):
    self.is_alive = true
    .spawn(position)

func die():
    self.is_alive = false
    self.panel.hide()
    .die()
    if not self.bag.players.is_living_player_in_game():
        self.bag.sample_player.play('game_over')
        self.bag.action_controller.end_game()

func process(delta):
    self.adjust_attack_cone()
    .process(delta)
    self.check_doors()
    self.handle_items()

func modify_position(delta):
    .modify_position(delta)
    self.flip(self.target_cone_vector[0])
    self.handle_animations()

func handle_animations():

    if not self.animations.is_playing():
        if abs(self.movement_vector[0]) > self.AXIS_THRESHOLD || abs(self.movement_vector[1]) > self.AXIS_THRESHOLD:
            self.animations.play('run')
            print('run?')
        else:
            self.animations.play('idle')
            print('idle?')
    else:
        if self.animations.get_current_animation() == 'idle' && (abs(self.movement_vector[0]) > self.AXIS_THRESHOLD || abs(self.movement_vector[1]) > self.AXIS_THRESHOLD):
            self.animations.play('run')
        elif self.animations.get_current_animation() == 'run' && abs(self.movement_vector[0]) < self.AXIS_THRESHOLD && abs(self.movement_vector[1]) < self.AXIS_THRESHOLD:
            self.animations.play('idle')


func handle_items():
    var items = self.bag.items.get_items_near_object(self)
    for item in items:
        if item.power_up_type == 0:
            self.get_fat(item.power_up_amount)
        else:
            self.get_power(item.power_up_amount)
        self.score = self.score + item.score
        item.pick()
        self.update_bars()


func adjust_attack_cone():
    if abs(self.target_cone_vector[0]) < self.AXIS_THRESHOLD || abs(self.target_cone_vector[1]) < self.AXIS_THRESHOLD:
        return

    self.target_cone_angle = -atan2(self.target_cone_vector[1], self.target_cone_vector[0]) - PI/2
    self.target_cone.set_rot(self.target_cone_angle)

func attack():
    if self.is_attack_on_cooldown:
        return

    var enemies
    var random_attack = 'attack'+ str(1 + randi() % 2)

    if not self.animations.get_current_animation() == 'attack1' and not self.animations.get_current_animation() == 'attack2' :
        self.animations.play(random_attack)
        self.play_sound(random_attack)
        self.blast.play('blast')
    elif not self.animations.is_playing():
        if self.animations.get_current_animation() == 'attack1':
            self.animations.play('attack2')
            self.play_sound('attack2')
        else:
            self.animations.play('attack1')
            self.play_sound('attack1')
        self.blast.play('blast')

    enemies = self.bag.enemies.get_enemies_near_object(self, self.attack_range, self.target_cone_vector, self.attack_width)
    for enemy in enemies:
        if enemy.will_die(self.attack_strength):
            self.score += enemy.score
            self.update_bars()

        enemy.recieve_damage(self.attack_strength)
        enemy.push_back(self)
    self.bag.timers.set_timeout(self.attack_cooldown, self, "attack_cooled_down")

func get_power(amount):
    self.attack_strength += amount
    if self.attack_strength >= 16:
        self.die();

    self.hp -= amount
    self.max_hp -= amount
    self.update_bars()

func get_fat(amount):
    self.hp += amount
    self.max_hp += amount
    if self.max_hp > self.hp_cap:
        self.max_hp = self.hp_cap
    if self.hp > self.max_hp:
        self.hp = self.max_hp
    self.update_bars()

func check_colisions():
    return

func check_doors():
    if not self.bag.game_state.doors_open:
        return;

    var door_coords
    var new_coords = [0, 0]
    var cell = self.bag.game_state.current_cell
    if cell.north != null:
        door_coords = self.bag.room_loader.door_definitions['north'][1]
        new_coords[0] = door_coords[0] + 7
        new_coords[1] = door_coords[1] + 0
        if self.check_exit(new_coords, cell.north, Vector2(16, 0)):
            self.bag.players.move_to_entry_position('south')
            return
    if cell.south != null:
        door_coords = self.bag.room_loader.door_definitions['south'][1]
        new_coords[0] = door_coords[0] + 7
        new_coords[1] = door_coords[1] + 10
        if self.check_exit(new_coords, cell.south, Vector2(16, 40)):
            self.bag.players.move_to_entry_position('north')
            return
    if cell.east != null:
        door_coords = self.bag.room_loader.door_definitions['east'][1]
        new_coords[0] = door_coords[0] + 16
        new_coords[1] = door_coords[1] + 4
        if self.check_exit(new_coords, cell.east, Vector2(40, 0)):
            self.bag.players.move_to_entry_position('west')
            return
    if cell.west != null:
        door_coords = self.bag.room_loader.door_definitions['west'][1]
        new_coords[0] = door_coords[0] + 0
        new_coords[1] = door_coords[1] + 4
        if self.check_exit(new_coords, cell.west, Vector2(-10, 0)):
            self.bag.players.move_to_entry_position('east')
            return

    self.check_level_exit()

func check_exit(door_coords, cell, door_offset):
    var exit_area = self.bag.room_loader.translate_position(Vector2(door_coords[0] + self.bag.room_loader.side_offset, door_coords[1]))
    exit_area = exit_area + door_offset
    var distance = self.calculate_distance(exit_area)
    if distance < self.EXIT_THRESHOLD:
        self.bag.map.switch_to_cell(cell)
        return true
    return false

func check_level_exit():
    var exit_area
    var distance
    for exit in self.bag.game_state.current_room.exits:
        exit_area = self.bag.room_loader.translate_position(Vector2(exit[0] + self.bag.room_loader.side_offset, exit[1]))
        distance = self.calculate_distance(exit_area)
        if distance < self.EXIT_THRESHOLD:
            self.bag.action_controller.next_level(exit[2])

func move_to_entry_position(name):
    var entry_position
    entry_position = self.bag.room_loader.get_spawn_position(name + str(self.player_id))
    self.avatar.set_pos(entry_position)

func update_bars():
    self.panel.update_bar(self.panel.fat_bar, self.hp - 1, 0)
    self.panel.update_bar(self.panel.power_bar, self.attack_strength - 1, 3)
    self.panel.update_points(self.score)

func set_hp(hp):
    .set_hp(hp)
    self.update_bars()

func recieve_damage(damage):
    self.bag.camera.shake()
    .recieve_damage(damage)

func reset():
    self.attack_strength = 1
    self.hp = 10
    self.max_hp = 10
    self.target_cone_vector = [0, 0]
    self.target_cone_angle = 0.0
    self.is_playing = false
    self.is_alive = true
    self.movement_vector = [0, 0]
    self.score = 0
    self.is_attack_on_cooldown = false

func attack_cooled_down():
    self.is_attack_on_cooldown = false
