extends Node2D

var scriptPath = ""
@export var NamingPopup: Control
@export var CodeEditor: CodeEdit

enum {
	STOP,
	MOV_R_V,
	MOV_R_R,
	WRITE, #WRITE to ram
	LOAD, # Get value from ram
	ADD, #Adds two registers
	SUB, 
	JMP,
	SPR
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass




func _on_save_pressed() -> void:
	NamingPopup.visible = true
	pass


func _on_line_edit_text_submitted(new_text: String) -> void:
	scriptPath = new_text
	var file = CodeEditor.text
	NamingPopup.visible = false
	var bytecode = compile(file)
	for i in range(bytecode.size()):
		Globals.ram[0x5000+i] = bytecode[i]
	print("Bytecode: ", bytecode)
	print("Bytecode size: ", bytecode.size())
	print("RAM at 0x5000: ", Globals.ram[0x5000])
	print("RAM at 0x5001: ", Globals.ram[0x5001])
	print("RAM at 0x5002: ", Globals.ram[0x5002])
	print("RAM at 0x5003: ", Globals.ram[0x5003])
	print("PC after compile: ", Globals.pc)
	Globals.isRunning = false
	Globals.isStopped = false
	Globals.pc = 0x5000
	pass 


func compile(source_code: String) -> PackedByteArray:
	var bytecode = PackedByteArray()
	var lines = source_code.split("\n")

	for line in lines:
		line = line.strip_edges()
		if line == "" or line.begins_with(";"): continue 
		var tokens = line.replace(",", " ").split(" ", false)
		var command = tokens[0].to_upper()
		match command:
			"MOV_R_V":
				bytecode.append(MOV_R_V)
				bytecode.append(tokens[1].replace("R", "").to_int() )
				bytecode.append(tokens[2].to_int())
			"STOP":
				bytecode.append(STOP)
			"MOV_R_R":
				bytecode.append(MOV_R_R)
				bytecode.append(tokens[1].replace("R", "").to_int())
				bytecode.append(tokens[2].replace("R", "").to_int())
			"WRITE":
				bytecode.append(WRITE)
				bytecode.append(tokens[1].to_int() / 256)
				bytecode.append(tokens[1].to_int() % 256)
				bytecode.append(tokens[2].to_int())
			"ADD":
				bytecode.append(ADD)
				bytecode.append(tokens[1].replace("R", "").to_int())
				bytecode.append(tokens[2].replace("R", "").to_int())
			"SUB":
				bytecode.append(SUB)
				bytecode.append(tokens[1].to_int() / 256)
				bytecode.append(tokens[2].to_int() % 256)
				bytecode.append(tokens[3].to_int() / 256)
				bytecode.append(tokens[4].to_int() % 256)
			"JMP":
				bytecode.append(JMP)
				bytecode.append(tokens[1].to_int() / 256)
				bytecode.append(tokens[1].to_int() % 256)
			"SPR":
				bytecode.append(SPR)
				bytecode.append(tokens[1].to_int())
				bytecode.append(tokens[2].to_int())
				bytecode.append(tokens[3].to_int())
	return bytecode


func _on_back_pressed() -> void:
	Globals.isRunning = false
	Globals.isStopped = false
	Globals.pc = 0
	get_tree().change_scene_to_file("res://main.tscn")
	pass
