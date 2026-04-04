extends Node

@export var hardware: Node

# Second priority get cartridges done first.

func execute(userCode: String):
	var script = GDScript.new()
	script.source_code = userCode
	var error = script.reload()
	if error != OK:
		print("Error in script: ", error)
		return
	var script_inst = script.new()

	script_inst.run(self)
	
	
