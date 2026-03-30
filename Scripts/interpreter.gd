extends Node

func execute(userCode: String):
	var script = GDScript.new()
	script.source_code = userCode
	var script_inst = script.new()
	var error = script.reload()
	if error != OK:
		print("Error in script: ", error)
		return
	script_inst.run(self)
	
