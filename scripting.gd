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
	SPR,
	IF
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	CodeEditor.text=decompile(Globals.ram.size() - 20480)
	pass


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
			"IF":
				bytecode.append(IF)
				bytecode.append(tokens[1].to_int())
				bytecode.append(tokens[2].to_int())
				bytecode.append(tokens[3].to_int())
	return bytecode


func decompile(length: int) -> String:
	var pc = 20480 # 0x5000
	var assemblyText: String
	while pc < 20480 + length:
		var opcode = Globals.ram[pc]
		match opcode:
			MOV_R_V:
				var reg = Globals.ram[pc + 1]
				var val = Globals.ram[pc + 2]
				assemblyText += "MOV_R_V" +" "+ str(reg) +" "+ str(val) + "\n"
				pc += 3
			STOP:
				assemblyText += "STOP"
				pc += 1
			MOV_R_R:
				var reg1 = Globals.ram[pc + 1]
				var reg2 = Globals.ram[pc + 2]
				assemblyText += "MOV_R_R" +" " + str(reg1) + " " + str(reg2) + "\n"
				pc += 3
			WRITE:
				var addr = (Globals.ram[pc + 1]*256 + Globals.ram[pc +2])
				var val = Globals.ram[pc + 3]
				assemblyText += "WRITE" + " " + str(addr) + " " + str(val) + "\n"
				pc += 4
			ADD:
				var R1 = Globals.ram[pc + 1]
				var R2 = Globals.ram[pc + 2]
				assemblyText += "ADD" + " " + str(R1) + " " + str(R2) + "\n"
				pc += 3
			SUB:
				var addr = (Globals.ram[pc + 1] * 256 + Globals.ram[pc + 2])
				var val = (Globals.ram[pc + 3] * 256 + Globals.ram[pc + 4])
				assemblyText += "SUB" + " " + str(addr) + " " + str(val) + "\n"
				pc += 5
			JMP:
				var addr = (Globals.ram[pc + 1] * 256 + Globals.ram[pc + 2])
				assemblyText += "JMP" + " " + str(addr) + "\n"
				pc += 3
			SPR:
				var index = Globals.ram[pc + 1]
				var x = Globals.ram[pc + 2]
				var y = Globals.ram[pc + 3]
				assemblyText += "SPR" + " " + str(index) + " " + str(x) + " " + str(y) + "\n"
				pc += 4
			IF:
				var val1 = Globals.ram[pc + 1]
				var val2 = Globals.ram[pc + 2]
				var pcInc = Globals.ram[pc + 3]
				assemblyText += "IF" + " " + str(val1) + "  " + str(val2) + " " + str(pcInc) + "\n"
				pc += 4
	return assemblyText
		

func _on_back_pressed() -> void:
	Globals.isRunning = false
	Globals.isStopped = false
	Globals.pc = 0
	get_tree().change_scene_to_file("res://main.tscn")
	pass
