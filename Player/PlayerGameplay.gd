extends "res://Player/CharacterMovement_Base.gd"

#####################################
#Refrences
@onready var CameraRef = $CameraRoot
#####################################

#####################################
#Controls Settings
@export var OnePressJump := false
@export var UsingSprintToggle := false
@export var UsingCrouchToggle := false
#####################################

var h_rotation :float
var v_rotation :float

var direction := Vector3.FORWARD

func _ready():
	super._ready()
	
	
var timer := 0.2
var StopTimer := true
func _physics_process(delta):
	super._physics_process(delta)
	if timer > 0.0:
		timer -= delta
	else:
		timer = 0.0
	
	if Input.is_action_just_released("SwitchCameraView"):
		if timer > 0.0:
			$CameraRoot.ViewAngle = $CameraRoot.ViewAngle + 1 if $CameraRoot.ViewAngle < 2 else 0
	if Input.is_action_just_pressed("SwitchCameraView"):
		timer = 0.2
		StopTimer = false
	if Input.is_action_pressed("SwitchCameraView") and timer <= 0.0:
		if StopTimer == false:
			$CameraRoot.ViewMode = $CameraRoot.ViewMode + 1 if $CameraRoot.ViewMode < 1 else 0
			StopTimer = true
		
		
	#------------------ Input Movement ------------------#
	h_rotation = $CameraRoot.HObject.transform.basis.get_euler().y
	v_rotation = $CameraRoot.VObject.transform.basis.get_euler().x

	if Input.is_action_pressed("forward") || Input.is_action_pressed("back") || Input.is_action_pressed("right") || Input.is_action_pressed("left") :
		direction = Vector3(Input.get_action_strength("right") - Input.get_action_strength("left"),
			v_rotation * (Input.get_action_strength("back") - Input.get_action_strength("forward")) if IsFlying == true else 0.0,
			Input.get_action_strength("back") - Input.get_action_strength("forward"))
		direction = direction.rotated(Vector3.UP,h_rotation).normalized()
		if Gait == Global.Gait.Sprinting :
			AddMovementInput(direction, CurrentMovementData.Sprint_Speed,CurrentMovementData.Sprint_Acceleration)
		elif Gait == Global.Gait.Running:
			AddMovementInput(direction, CurrentMovementData.Run_Speed,CurrentMovementData.Run_Acceleration)
		else:
			AddMovementInput(direction, CurrentMovementData.Walk_Speed,CurrentMovementData.Walk_Acceleration)
	else:
		AddMovementInput(direction,0,CurrentMovementData.Walk_Acceleration)
	
	
	#------------------ Input Crouch ------------------#
	if UsingCrouchToggle == false:
		if Input.is_action_pressed("crouch"):
			if DesiredStance != Global.Stance.Crouching:
				DesiredStance = Global.Stance.Crouching
		else:
			if DesiredStance != Global.Stance.Standing:
				DesiredStance = Global.Stance.Standing
	else:
		if Input.is_action_just_pressed("crouch"):
			DesiredStance = Global.Stance.Standing if DesiredStance == Global.Stance.Crouching else Global.Stance.Crouching
	
	#------------------ Input Aim ------------------#
	if Input.is_action_pressed("aim"):
		if !AnimRef.get("parameters/roll/active"):
			AnimRef.set("parameters/aim_transition/current",0)
	else:
		AnimRef.set("parameters/aim_transition/current",1)
		#------------------ Jump ------------------#
	if is_on_floor():
		if !AnimRef.get("parameters/roll/active"):
			if OnePressJump == true:
				if Input.is_action_just_pressed("jump"):
					if DesiredStance != Global.Stance.Standing:
						DesiredStance = Global.Stance.Standing
					elif not head_bonked:
						jump()
			else:
				if Input.is_action_pressed("jump"):
					if DesiredStance != Global.Stance.Standing:
						DesiredStance = Global.Stance.Standing
					elif not head_bonked:
						jump()
	
func _input(event):
	#------------------ Sprint ------------------#
	if UsingSprintToggle:
		if event.is_action_pressed("sprint"):
			DesiredGait = Global.Gait.Walking if DesiredGait == Global.Gait.Sprinting else Global.Gait.Sprinting
	else:
		if Input.is_action_pressed("sprint"):
			DesiredGait = Global.Gait.Sprinting
		elif Input.is_action_pressed("run"):
			DesiredGait = Global.Gait.Running 
		else:
			DesiredGait = Global.Gait.Walking



		if RotationMode == Global.RotationMode.VelocityDirection:
			if CameraRef != null:
				if CameraRef.ViewMode == Global.ViewMode.FirstPerson:
					CameraRef.ViewMode = Global.ViewMode.ThirdPerson
					

