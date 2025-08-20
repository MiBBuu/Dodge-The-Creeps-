extends Area2D

# This defines a custom signal called "hit" that we will have our player emit (send out) when it collides with an enemy.
signal hit

@export var speed = 400 # How fast the player will move (pixels/sec).
var screen_size # Size of the game window.

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size
# Player will be hidden when the game starts.
	hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var velocity = Vector2.ZERO # The player´s movement vector.
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
		
		
# We start by setting the velocity to (0, 0) - by default, the player should not be moving. Then we check each input and add/subtract from the velocity to obtain a total direction. 
# For example, if you hold right and down at the same time, the resulting velocity vector will be (1, 1). 
# In this case, since we're adding a horizontal and a vertical movement, the player would move faster diagonally than if it just moved horizontally.
# We can prevent that if we normalize the velocity, which means we set its length to 1, then multiply by the desired speed. This means no more fast diagonal movement.

	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		$AnimatedSprite2D.play() # $ is shorthand for get_node(). So in the code, $AnimatedSprite2D.play() is the same as get_node("AnimatedSprite2D").play().
	else:
		$AnimatedSprite2D.stop()
	
	# Delta parameter refers to frame length - the amount of time that the previous frame took to complete.
	# Using this value ensures that movement will remain consistent even if the frame rate changes.
	position += velocity * delta
	# Clamp prevents player from leaving the screen.
	position = position.clamp(Vector2.ZERO, screen_size)	
	
	# We have the "walk" animation, which shows the player walking to the right.
	# This animation should be flipped horizontally using the flip_h property for left movement.
	# We also have the "up" animation, which should be flipped vertically with flip_v for downward movement. 
	if velocity.x != 0:
		$AnimatedSprite2D.animation = "walk"
		$AnimatedSprite2D.flip_v = false
		# See the note below about the following boolean assignment.
		$AnimatedSprite2D.flip_h = velocity.x < 0
	elif velocity.y != 0:
		$AnimatedSprite2D.animation = "up"
		$AnimatedSprite2D.flip_v = velocity.y > 0

func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false

func _on_body_entered(_body):
	hide() # Player disappears after being hit.
	hit.emit()
	# Must be deferred as we can't change physics properties on a physics callback.
	$CollisionShape2D.set_deferred("disabled", true)
