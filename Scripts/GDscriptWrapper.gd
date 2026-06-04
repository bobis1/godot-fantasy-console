extends Node

@export var hardware: Node
@export var CPU: Node


func isUpPressed():
	if Globals.ram[0x4B31] == 1:
		return true
	return false


func isDownPressed():
	if Globals.ram[0x4B31] == 2:
		return true
	return false

func isLeftPressed():
	if Globals.ram[0x4B31] == 3:
		return true
	return false

func isRightPressed():
	if Globals.ram[0x4B31] == 4:
		return true
	return false


func isAPressed():
	if Globals.ram[0x4B31] == 5:
		return true
	return false

func setUpSprite(sprite: int, startX: int, startY: int, reg1: int, reg2: int):
	setRegisterValue(reg1, startX)
	setRegisterValue(reg2, startY)

func moveSpriteWithButtons(sprite: int, vx: int, vy: int, reg1: int, reg2: int):
	if Globals.ram[0x4B31] == 4:
		addRegisterValue(reg1,vx)
	if Globals.ram[0x4B31] == 3:
		subRegisterValue(reg1,vx)
	if Globals.ram[0x4B31] == 2:
		addRegisterValue(reg2,vy)
	if Globals.ram[0x4B31] == 1:
		subRegisterValue(reg2,vy)
	hardware.draw_sprite(sprite,getRegisterValue(0), getRegisterValue(1))
	pass

func setRegisterValue(register: int, value: int):
	CPU.registers[register] = value
	pass

func addRegisterValue(register: int, value: int):
	CPU.registers[register] += value
	pass
	
func subRegisterValue(register: int, value: int):
	CPU.registers[register] -= value
	pass

func getRegisterValue(register: int) -> int:
	return CPU.registers[register]


func draw_sprite(sprite_index: int, x: int, y: int) -> void:
	hardware.draw_sprite(sprite_index, x, y)
	pass
