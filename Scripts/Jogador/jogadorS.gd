extends CharacterBody3D


const Pscale = Vector3(1, 1, 1) 
const Cscale =Vector3(1, 0.5, 1) 


@export var look_sensitivity : float = 0.006



const BASE_SPEED: float = 10.0
const RUN_MULT: float = 1.5


@export var coyote_time := 0.2
var coyote_timer := 0.0

const AIR_CONTROL := 0.04
var AIR_MAX_SPEED = BASE_SPEED * 2.0

const JUMP_VELOCITY = 7

var Sjump = true

func _ready():

# Seta a parte visivel do jogador
	for child in %CorpoJogador.find_children("*", "VisualInstance3D"):
		child.set_layer_mask_value(1, false)
		child.set_layer_mask_value(2, true)

#movumenta a camera 
func _unhandled_input(event):
	if event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	elif  event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			rotate_y(-event.relative.x * look_sensitivity)
			%Camera3D.rotate_x(-event.relative.y * look_sensitivity)
			%Camera3D.rotation.x = clamp(%Camera3D.rotation.x, deg_to_rad(-90) , deg_to_rad(90))





func _physics_process(delta: float) -> void:
	# Gravidade
	if not is_on_floor():
		velocity += get_gravity() * delta

	if is_on_floor():
		Sjump = true

#corrida
	var speed := BASE_SPEED * (RUN_MULT if Input.is_action_pressed("sprint") else 1.0)
	var input_dir := Input.get_vector("left", "right", "front", "down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	# Movimento no chão
	if is_on_floor():
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = move_toward(velocity.x, 0, speed)
			velocity.z = move_toward(velocity.z, 0, speed)
	else:
		# CONTROLE LIMITADO NO AR (com inércia)
		var target_velocity = direction * speed
		velocity.x = lerp(velocity.x, target_velocity.x, AIR_CONTROL)
		velocity.z = lerp(velocity.z, target_velocity.z, AIR_CONTROL)

		# Limita a velocidade no ar
		var horizontal_speed := Vector2(velocity.x, velocity.z).length()
		if horizontal_speed > AIR_MAX_SPEED:
			var limited = Vector2(velocity.x, velocity.z).normalized() * AIR_MAX_SPEED
			velocity.x = limited.x
			velocity.z = limited.y

#timer para o pulo
	if is_on_floor():
		coyote_timer = coyote_time
	else:
		coyote_timer -= delta

# Pulo
	if Input.is_action_just_pressed("junp"):
		if is_on_floor() or coyote_timer > 0.0:
			velocity.y = JUMP_VELOCITY
			coyote_timer = 0.0
		elif is_on_wall_only() and Sjump:
			velocity.y = JUMP_VELOCITY
			Sjump = false




	move_and_slide()
