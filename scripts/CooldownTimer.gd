extends Timer

export var cancel_timeout: float = 1
export var default_timeout: float = .5

func start_cancelled():
	self.start(cancel_timeout)
	
func start_default():
	self.start(default_timeout)
