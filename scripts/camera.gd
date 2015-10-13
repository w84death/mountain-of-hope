
var bag
var camera

var zoom

var shakes = 0
var shakes_max = 3
var shake_time = 0.1
var shake_boundary = 5

var shake_initial_position

func _init_bag(bag):
    self.bag = bag
    self.camera = self.bag.root.camera
    self.zoom = self.camera.get_zoom()

func shake():
    self.shakes = 0
    self.shake_initial_position = self.camera.get_camera_pos()
    self.do_single_shake()

func do_single_shake():
    var pos
    var distance_x
    var distance_y
    if self.shakes < self.shakes_max:
        distance_x = randi() % self.shake_boundary
        distance_y = randi() % self.shake_boundary
        if randf() <= 0.5:
            distance_x = -distance_x
        if randf() <= 0.5:
            distance_y = -distance_y

        pos = self.shake_initial_position + Vector2(distance_x, distance_y)
        self.camera.set_offset(pos)
        self.shakes = self.shakes + 1
        self.bag.timers.set_timeout(self.shake_time, self, "do_single_shake")
    else:
        self.camera.set_offset(shake_initial_position)