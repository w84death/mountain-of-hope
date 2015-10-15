extends "res://scripts/object.gd"

var velocity
var movement_vector = [0, 0]
var controller_vector = [0, 0]

var AXIS_THRESHOLD = 0.15

var body
var animations
var hat = false

var stun_duration = 0.15
var stun_level = 0

var can_jump = true
var is_in_air = false
var is_on_wall = false
var wall_vector = Vector2(0, 0)

var tombstone_template #= preload("res://scenes/particles/thumbstone.xscn")

var FLOOR_FRICTION = 25
var MOVEMENT_SPEED_CAP_LAND = 10
var MOVEMENT_SPEED_CAP_AIR = 12
var GRAVITY = 30
var COLLIDING_FALL = 0.1
var JUMP_SPEED = 20
var AIR_CONTROL = 0.8

func _init(bag).(bag):
    self.bag = bag

func spawn(position):
    .spawn(position)
    self.bag.processing.register(self)

func despawn():
    self.bag.processing.remove(self)
    .despawn()

func process(delta):
    self.modify_position(delta)

func modify_position(delta):
    var x = self.apply_axis_threshold(self.controller_vector[0])
    var y = self.apply_axis_threshold(self.controller_vector[1])

    var current_motion = Vector2(self.movement_vector[0], self.movement_vector[1])
    var motion_delta = Vector2(x, y) * self.velocity * delta

    if self.is_in_air:
        motion_delta = motion_delta * self.AIR_CONTROL

    motion_delta.y = motion_delta.y + self.GRAVITY * delta

    current_motion = current_motion + motion_delta

    var speed_cap = self.MOVEMENT_SPEED_CAP_LAND
    if self.is_in_air:
        speed_cap = self.MOVEMENT_SPEED_CAP_AIR
    if abs(current_motion.x) > speed_cap:
        if current_motion.x < 0:
            current_motion.x = -speed_cap
        else:
            current_motion.x = speed_cap

    if abs(current_motion.y) > speed_cap:
        if current_motion.y < 0:
            current_motion.y = -speed_cap
        else:
            current_motion.y = speed_cap

    if current_motion == Vector2(0, 0) && not self.is_in_air:
        return

    if not self.is_in_air && self.is_jumping && self.can_jump:
        current_motion.y = -self.JUMP_SPEED

        if self.is_on_wall:
            current_motion.x = self.wall_vector.x * self.JUMP_SPEED
            self.can_jump = false
            self.bag.timers.set_timeout(1, self, 'enable_jump')

        self.handle_jump()

    current_motion = self.apply_friction(current_motion, delta)

    self.avatar.move(current_motion)
    if (self.avatar.is_colliding()):
        var normal = self.avatar.get_collision_normal()
        if (normal.x == 1 || normal.x == -1) && abs(normal.y) < 0.01:
            self.is_on_wall = true
            self.wall_vector = normal
        else:
            self.is_on_wall = false

        var n = self.avatar.get_collision_normal()
        current_motion = n.slide(current_motion)
        if not self.is_in_air:
            current_motion.y = self.COLLIDING_FALL
        self.is_in_air = false
        self.avatar.move(current_motion)
        self.handle_collision(self.avatar.get_collider())
    else:
        self.is_in_air = true
        self.is_on_wall = false
    self.flip(self.controller_vector[0])
    self.movement_vector[0] = current_motion.x
    self.movement_vector[1] = current_motion.y

func handle_collision(collider):
    return

func handle_jump():
    return

func apply_friction(current_motion, delta):
    if abs(current_motion.x) < self.FLOOR_FRICTION * delta:
        current_motion.x = 0
    else:
        if current_motion.x > 0:
            current_motion.x = current_motion.x - self.FLOOR_FRICTION * delta
        else:
            current_motion.x = current_motion.x + self.FLOOR_FRICTION * delta

    return current_motion

func apply_axis_threshold(axis_value):
    if abs(axis_value) < self.AXIS_THRESHOLD:
        return 0
    return axis_value

func flip(direction):
    if direction == 0:
        return

    var flip_sprite = false
    if direction > 0:
        flip_sprite = true

    self.body.set_flip_h(flip_sprite)

func reset_movement():
    self.movement_vector = [0, 0]
    #self.avatar.set_opacity(1)
    #self.animations.play('idle')

func push_back(enemy):
    var enemy_position = enemy.get_pos()
    var object_position = self.get_pos()

    var position_delta_x =  object_position.x - enemy_position.x
    var position_delta_y = object_position.y - enemy_position.y
    var force = pow(enemy.attack_strength, -1)

    var scale = force / self.calculate_distance(enemy_position) * 10

    self.avatar.move(Vector2(position_delta_x * scale, position_delta_y * scale))
    self.stun()

func stun(duration=null):
    if duration == null:
        duration = self.stun_duration
    self.is_processing = false
    self.stun_level = stun_level + 1
    self.bag.timers.set_timeout(duration, self, "remove_stun")

func remove_stun():
    self.stun_level = stun_level - 1
    if self.stun_level == 0:
        self.is_processing = true

func die():
    self.spawn_tombstone()
    .die()

func spawn_tombstone():
    var tombstone = self.tombstone_template.instance()
    self.bag.game_state.current_cell.add_persistent_object(tombstone, self.get_pos())

func enable_jump():
    self.can_jump = true