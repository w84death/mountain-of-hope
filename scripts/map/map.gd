
var bag

var segments = []

var SCREEN_WIDTH = Globals.get("display/width")
var SCREEN_HEIGHT = Globals.get("display/height")
var SCREEN_MARGIN = 100

var SEGMENT_SIZE = 120
var SEGMENT_LINE_HEIGHT = 36

var WALL_HEIGHT = 40
var WALL_HALF_WIDTH = 36

var platforms = [
    { 'width' : 100, 'template' : preload('res://scenes/map/platform_grass.xscn') }
]

var left_wall_template = preload('res://scenes/map/wall_left.xscn')
var right_wall_template = preload('res://scenes/map/wall_right.xscn')
var playable_width = 0


func _init_bag(bag):
    self.bag = bag
    self.playable_width = self.SCREEN_WIDTH - (self.SCREEN_MARGIN * 2)
    self.reset_map()

func reset_map():
    return


func generate_next_map_segment():
    var next_segment_index = self.segments.size()

    var new_segment = []

    new_segment = self.add_walls(new_segment)
    new_segment = self.add_separator(new_segment)

    self.segments.append(new_segment)
    self.apply_segment(next_segment_index)
    self.destroy_unused_segment(next_segment_index - 3)

func apply_segment(id):
    var segment_offset = id * self.SEGMENT_SIZE * self.SEGMENT_LINE_HEIGHT
    for object in self.segments[id]:
        self.bag.action_controller.attach_object(object.object)
        print(object)
        object.object.set_global_pos(Vector2(object.x, -object.y - segment_offset))

func destroy_unused_segment(id):
    if id < 0:
        return

    return

func add_segment_object(segment, x, y, object):
    segment.append({
        'x' : x,
        'y' : y,
        'object' : object
    })

    return segment

func add_separator(segment):
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
        segment = self.add_segment_object(segment, wall_offset + self.playable_width, real_height, right_wall)

        height = height + self.WALL_HEIGHT
    return segment