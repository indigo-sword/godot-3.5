extends Timer

func _start_timer(duration):
	self.wait_time = duration
	self.start()

func start_dash(duration):
	self._start_timer(duration)

func is_dashing():
	return !self.is_stopped()
