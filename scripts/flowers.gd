
extends Sprite

var r

func _ready():
	r = randi()%(self.get_hframes()*self.get_vframes())
	self.set_frame(r)
