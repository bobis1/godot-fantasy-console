extends Node

var GDscriptWrapper

func _ready() -> void:
	var GDscriptWrapper: Node = get_node("GDscriptInterpreter")
	pass

func _process(delta: float) -> void:
	if GDscriptWrapper.isUpPressed:
		print("UP Pressed")
	pass
