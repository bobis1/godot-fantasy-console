extends Node

@export var hardware: Node


func moveSpriteWithButtons(SpriteAddr: int):
	
	pass


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


func draw_sprite(sprite_index: int, x: int, y: int) -> void:
	hardware.draw_sprite(sprite_index, x, y)
	pass
