extends "res://scripts/object.gd"

var velocity
var movement_vector = [0, 0]

var AXIS_THRESHOLD = 0.15

var body_part_head
var body_part_body
var body_part_footer
var animations
var hat = false

var stun_duration = 0.15
var stun_level = 0

var tombstone_template = preload("res://scenes/particles/thumbstone.xscn")

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
    var x = self.apply_axis_threshold(self.movement_vector[0])
    var y = self.apply_axis_threshold(self.movement_vector[1])
    var motion = Vector2(x, y) * self.velocity * delta
    self.avatar.move(motion)
    if (self.avatar.is_colliding()):
        var n = self.avatar.get_collision_normal()
        motion = n.slide(motion)
        self.avatar.move(motion)
    self.flip(self.movement_vector[0])

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

    self.body_part_head.set_flip_h(flip_sprite)
    self.body_part_body.set_flip_h(flip_sprite)
    self.body_part_footer.set_flip_h(flip_sprite)
    if self.hat:
        self.hat.set_flip_h(flip_sprite)

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