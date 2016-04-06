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

var panel
var hp_cap = 16
var top_height = 0

var is_jumping = false

var EXIT_THRESHOLD = 30

var camera

func _init(bag, player_id).(bag):
    self.bag = bag
    self.player_id = player_id
    self.velocity = 50
    self.hp = 10
    self.max_hp = 10
    self.score = 0
    self.avatar = preload("res://scenes/player/player.xscn").instance()
    self.animations = self.avatar.get_node('animations')
    self.body = self.avatar.get_node('body')
    self.camera = self.avatar.get_node('Camera2D')


    #self.panel = self.bag.hud.bind_player_panel(player_id)
    self.update_bars()

    self.sounds['hit'] = 'player_hit'
    self.sounds['die'] = 'player_die'
    self.sounds['attack1'] = 'player_attack1'
    self.sounds['attack2'] = 'player_attack2'

func bind_arcade():
    var arcade = self.bag.input.devices['arcade']
    arcade.register_handler(preload("res://scripts/input/handlers/player_move_arcade.gd").new(self.bag, self, 0, JOY_BUTTON_11, -1))
    arcade.register_handler(preload("res://scripts/input/handlers/player_move_arcade.gd").new(self.bag, self, 0, JOY_BUTTON_10, 1))
    arcade.register_handler(preload("res://scripts/input/handlers/player_jump_arcade.gd").new(self.bag, self, JOY_BUTTON_15))

func bind_keyboard_and_mouse():
    var keyboard = self.bag.input.devices['keyboard']
    var mouse = self.bag.input.devices['mouse']
    #keyboard.register_handler(preload("res://scripts/input/handlers/player_enter_game_keyboard.gd").new(self.bag, self))
    #keyboard.register_handler(preload("res://scripts/input/handlers/player_move_key.gd").new(self.bag, self, 1, KEY_W, -1))
    #keyboard.register_handler(preload("res://scripts/input/handlers/player_move_key.gd").new(self.bag, self, 1, KEY_S, 1))
    keyboard.register_handler(preload("res://scripts/input/handlers/player_jump_key.gd").new(self.bag, self, KEY_SPACE))
    keyboard.register_handler(preload("res://scripts/input/handlers/player_move_key.gd").new(self.bag, self, 0, KEY_A, -1))
    keyboard.register_handler(preload("res://scripts/input/handlers/player_move_key.gd").new(self.bag, self, 0, KEY_D, 1))
    keyboard.register_handler(preload("res://scripts/input/handlers/player_drink_key.gd").new(self.bag, self, KEY_W))
    #mouse.register_handler(preload("res://scripts/input/handlers/player_attack_mouse.gd").new(self.bag, self))

func enter_game():
    self.is_playing = true
    self.spawn(Vector2(640, -60))

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
    .process(delta)
    self.handle_items()
    self.check_map_segment()

func check_map_segment():
    var height = -1 * int(self.avatar.get_pos().y)
    if height > self.top_height:
        self.top_height = height
        self.bag.hud.set_score(height)
    self.bag.map.update_segments(height)

func modify_position(delta):
    .modify_position(delta)
    self.handle_animations()

func jump(jumping_flag):

    self.is_jumping = jumping_flag

func handle_collision(collider):
    return

func handle_animations():
    if not self.animations.is_playing():
        if abs(self.movement_vector[0]) > self.AXIS_THRESHOLD || abs(self.movement_vector[1]) > self.AXIS_THRESHOLD:
            self.animations.play('run')
            #print('run?')
        else:
            self.animations.play('idle')
            #print('idle?')
    else:
        if self.animations.get_current_animation() == 'idle' && (abs(self.movement_vector[0]) > self.AXIS_THRESHOLD || abs(self.movement_vector[1]) > self.AXIS_THRESHOLD):
            self.animations.play('run')
        elif self.animations.get_current_animation() == 'run' && abs(self.movement_vector[0]) < self.AXIS_THRESHOLD && abs(self.movement_vector[1]) < self.AXIS_THRESHOLD:
            self.animations.play('idle')

func drink():
    if not self.is_in_air && not self.is_on_wall:
        self.animations.play('drink')
        self.bag.sound_controller.play('drink')
        self.bag.timers.set_timeout(1, self, 'stop_drink')


func stop_drink():
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

func handle_jump():
    self.bag.sound_controller.play('jump_normal')

func attack():
    if self.is_attack_on_cooldown:
        return

    var enemies
    var random_attack = 'attack'+ str(1 + randi() % 2)

    if not self.animations.get_current_animation() == 'attack1' and not self.animations.get_current_animation() == 'attack2' :
        self.animations.play(random_attack)
        self.play_sound(random_attack)
        #self.blast.play('blast')
    elif not self.animations.is_playing():
        if self.animations.get_current_animation() == 'attack1':
            self.animations.play('attack2')
            self.play_sound('attack2')
        else:
            self.animations.play('attack1')
            self.play_sound('attack1')
        self.blast.play('blast')

    enemies = [] #self.bag.enemies.get_enemies_near_object(self, self.attack_range, self.target_cone_vector, self.attack_width)
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

func update_bars():
    #self.panel.update_bar(self.panel.fat_bar, self.hp - 1, 0)
    #self.panel.update_bar(self.panel.power_bar, self.attack_strength - 1, 3)
    #self.panel.update_points(self.score)
    return

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
    self.is_playing = false
    self.is_alive = true
    self.movement_vector = [0, 0]
    self.controller_vector = [0, 0]
    self.score = 0
    self.is_attack_on_cooldown = false
    self.top_height = 0
    self.camera.clear_current()
    self.despawn()

func attack_cooled_down():
    self.is_attack_on_cooldown = false
