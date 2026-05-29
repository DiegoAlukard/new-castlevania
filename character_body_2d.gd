extends CharacterBody2D

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

const SPEED = 60.0
const JUMP_VELOCITY = -240.0
const STAIR_SPEED = 40.0 # Velocidade clássica mais lenta para subir escadas

# Máquina de Estados (State Machine) para organizar os movimentos
enum States { NORMAL, ON_STAIR }
var current_state: States = States.NORMAL

# Guarda a escada que o jogador está tocando no momento
var active_stair: StairTrigger = null

func _physics_process(delta: float) -> void:
	# Gerencia o comportamento do Simon dependendo do estado atual
	match current_state:
		States.NORMAL:
			handle_normal_state(delta)
		States.ON_STAIR:
			handle_stair_state(delta)

## ESTADO NORMAL: Movimentação padrão no chão e no ar
func handle_normal_state(delta: float) -> void:
	# Aplica gravidade
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Pulo
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Movimentação Horizontal
	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	# Animações e Flip do Sprite
	if is_on_floor(): 
		if direction != 0:
			anim.play("walk")
			anim.flip_h = (direction > 0)
		else: 
			anim.play("idle")
	else:
		anim.play("jump")
			
	move_and_slide()
	
	# Verifica se o jogador quer entrar na escada
	check_stair_activation()

## ESTADO NA ESCADA: Movimentação diagonal sem gravidade
## ESTADO NA ESCADA: Movimentação diagonal sem gravidade
func handle_stair_state(delta: float) -> void:
	if active_stair == null:
		current_state = States.NORMAL
		return

	velocity = Vector2.ZERO
	var stair_input := Input.get_axis("up", "down")
	
	if stair_input != 0:
		var modifier_x := -1.0 if active_stair.direction == active_stair.StairDirection.UP_RIGHT else -1.0
		
		velocity.y = stair_input * STAIR_SPEED
		velocity.x = stair_input * STAIR_SPEED * modifier_x
		
		# Acesso correto via sprite_frames
		if anim.sprite_frames.has_animation("walk_stair"):
			anim.play("walk_stair")
		else:
			anim.play("walk")
			
		anim.flip_h = (velocity.x > 0)
	else:
		# Acesso correto via sprite_frames
		if anim.sprite_frames.has_animation("idle_stair"):
			anim.play("idle_stair")
		else:
			anim.play("idle")
		anim.stop() 
		
	move_and_slide()
	
	if Input.is_action_just_pressed("jump"):
		current_state = States.NORMAL
	
	if is_on_floor() and stair_input > 0:
		current_state = States.NORMAL

## Função que checa os inputs de entrar na escada
func check_stair_activation() -> void:
	if active_stair == null: 
		return
	
	# Se está na base da escada e aperta para CIMA
	if not active_stair.is_top and Input.is_action_pressed("up"):
		start_climbing()
	
	# Se está no topo da escada e aperta para BAIXO
	elif active_stair.is_top and Input.is_action_pressed("down"):
		start_climbing()

func start_climbing() -> void:
	if active_stair == null:
		return
	current_state = States.ON_STAIR
	velocity = Vector2.ZERO
	# Alinha o Simon horizontalmente com o centro do gatilho para ele não subir torto
	global_position.x = active_stair.global_position.x
