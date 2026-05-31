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

func moveSpriteWithButtons(sprite: int, vx: int, vy: int, startX: int, startY: int):
	var x: int = startX
	var y: int = startY
	if Globals.ram[0x4B31] == 4:
		hardware.draw_sprite(sprite,)
	if Globals.ram[0x4B31] == 3:
		return true
	if Globals.ram[0x4B31] == 2:
		return true
	if Globals.ram[0x4B31] == 1:
		return true
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



func draw_sprite(sprite_index: int, x: int, y: int) -> void:
	hardware.draw_sprite(sprite_index, x, y)
	pass
