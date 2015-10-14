
var bag

var logo

func _init_bag(bag):
    self.bag = bag

    self.logo = self.bag.root.get_node('logo')

func show():
    self.logo.show()

func hide():
    self.logo.hide()