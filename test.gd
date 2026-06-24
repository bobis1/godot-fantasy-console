#extends Node

#var GDscriptWrapper

#func _ready() -> void:
#	GDscriptWrapper = get_node("GDscriptInterpreter")
#	pass

#func _process(delta: float) -> void:
#	if GDscriptWrapper.isUpPressed:
#		print("UP Pressed")
#	pass



extends Node

var GDscriptWrapper

func _ready() -> void:
	GDscriptWrapper = get_node("../GDscriptInterpreter")
	GDscriptWrapper.setUpSprite(40, 40, 0 ,1)
	pass

func _process(delta: float) -> void:
	GDscriptWrapper.SwitchTilemap(1)
	GDscriptWrapper.moveSpriteWithButtons(2, 2, 2, 0, 1)
	if GDscriptWrapper.isUpPressed:
		print("UP Pressed")
	pass




extends Node

var GDscriptWrapper

func _ready() -> void:
	GDscriptWrapper = get_node("../GDscriptInterpreter")
	GDscriptWrapper.setUpSprite(40, 40, 0 ,1)
	pass

func _process(delta: float) -> void:
	GDscriptWrapper.SwitchTilemap(1)
	GDscriptWrapper.moveSpriteWithButtons(2, 2, 2, 0, 1)
	if GDscriptWrapper.isUpPressed:
		print("UP Pressed")
	pass
