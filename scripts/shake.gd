func shake_camera():
    shakes = 0
    shake_initial_position = terrain.get_pos()
    self.do_single_shake()

func do_single_shake():
    if shakes < shakes_max:
        var distance_x = randi() % shake_boundary
        var distance_y = randi() % shake_boundary
        if randf() <= 0.5:
            distance_x = -distance_x
        if randf() <= 0.5:
            distance_y = -distance_y

        pos = Vector2(shake_initial_position) + Vector2(distance_x, distance_y)
        target = pos
        underground.set_pos(pos)
        terrain.set_pos(pos)
        shakes += 1
        shake_timer.start()
    else:
        pos = shake_initial_position
        target = pos
        underground.set_pos(shake_initial_position)
        terrain.set_pos(shake_initial_position)

