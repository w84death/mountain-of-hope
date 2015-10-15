
var bag

var hud
var score

func _init_bag(bag):
    self.bag = bag
    self.hud = self.bag.root.get_node('hud')
    self.score = hud.get_node('top/center/score1')

func show():
    self.hud.show()

func hide():
    self.hud.hide()

func set_score(height):
    self.score.set_text(str(height) + 'm')