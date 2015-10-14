
var bag

var segments = []
var last_visited_segment = -1

var SCREEN_WIDTH = Globals.get("display/width")
var SCREEN_HEIGHT = Globals.get("display/height")
var SCREEN_MARGIN = 200

var SEGMENT_SIZE = 60
var SEGMENT_LINE_HEIGHT = 36

var WALL_HEIGHT = 39
var WALL_HALF_WIDTH = 36

var platforms = [
    { 'width' : 100, 'template' : preload('res://scenes/map/platform_grass.xscn') }
]

var left_wall_template = preload('res://scenes/map/wall_left.xscn')
var right_wall_template = preload('res://scenes/map/wall_right.xscn')
var separator_template = preload('res://scenes/map/base_platform.xscn')
var playable_width = 0


func _init_bag(bag):
    self.bag = bag
    self.playable_width = self.SCREEN_WIDTH - (self.SCREEN_MARGIN * 2)
    self.reset_map()

func reset_map():
    for segment in self.segments:
        self.destroy_unused_segment(segment)
    self.segments.clear()


func generate_next_map_segment():
    var next_segment_index = self.segments.size()

    var new_segment = []

    new_segment = self.add_walls(new_segment)
    new_segment = self.add_separator(new_segment)
    new_segment = self.add_platforms(new_segment)

    self.segments.append(new_segment)
    self.apply_segment(next_segment_index)
    self.destroy_unused_segment_by_id(next_segment_index - 3)

func apply_segment(id):
    var segment_offset = id * self.SEGMENT_SIZE * self.SEGMENT_LINE_HEIGHT
    for object in self.segments[id]:
        self.bag.action_controller.attach_object(object.object)
        object.object.set_global_pos(Vector2(object.x, -object.y - segment_offset))

func destroy_unused_segment_by_id(id):
    if id < 0:
        return

    self.destroy_unused_segment(self.segments[id])

func destroy_unused_segment(segment):
    for object in segment:
        self.bag.action_controller.detach_object(object.object)
        object.object.queue_free()

    segment.clear()

func add_segment_object(segment, x, y, object):
    segment.append({
        'x' : x,
        'y' : y,
        'object' : object
    })

    return segment

func add_separator(segment):
    var separator_platform = self.separator_template.instance()
    segment = self.add_segment_object(segment, -10, self.SEGMENT_LINE_HEIGHT, separator_platform)
    return segment

func add_walls(segment):
    var height = 0
    var left_wall
    var right_wall
    var wall_offset
    var real_height

    while height < self.SEGMENT_SIZE:
        left_wall = self.left_wall_template.instance()
        right_wall = self.right_wall_template.instance()

        wall_offset = self.SCREEN_MARGIN - self.WALL_HALF_WIDTH
        real_height = (height + self.WALL_HEIGHT / 2) * self.SEGMENT_LINE_HEIGHT
        segment = self.add_segment_object(segment, wall_offset, real_height, left_wall)
        segment = self.add_segment_object(segment, wall_offset + self.playable_width + self.WALL_HALF_WIDTH * 2, real_height, right_wall)

        height = height + self.WALL_HEIGHT
    return segment

func update_segments(player_height):
    var segment_height = self.SEGMENT_SIZE * self.SEGMENT_LINE_HEIGHT
    var overflow = player_height % segment_height

    var segment_num = (player_height - overflow) / segment_height

    if overflow > 100 && segment_num > self.last_visited_segment:
        self.last_visited_segment = segment_num
        self.generate_next_map_segment()

func add_platforms(segment):
    var iterator = 2
    var new_platform

    while iterator < self.SEGMENT_SIZE - 1:
        new_platform = self.platforms[0].template.instance()

        segment = self.add_segment_object(segment, 400, (iterator + 1) * self.SEGMENT_LINE_HEIGHT, new_platform)
        iterator = iterator + 2

    return segment