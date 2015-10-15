
var root
var stream_player
var sample_player
var bag

var sound_volume = 1.0
var music_volume = 1.0

var stream
var samples = [
    ['jump_normal', preload('res://assets/sounds/sfx/jump_normal.wav')],
    ['drink', preload('res://assets/sounds/sfx/drink.wav')],
]

func _init_bag(bag):
    self.bag = bag
    self.sample_player = self.bag.sample_player
    sample_player.set_default_volume_db(self.sound_volume)
    self.load_samples()

func play(sound):
    sample_player.play(sound)

func load_samples():
    for sample in self.samples:
        self.sample_player.get_sample_library().add_sample(sample[0], sample[1])
