extends Node2D

var scriptPath = ""
@export var NamingPopup: Control
@export var CodeEditor: CodeEdit
@export var GDscriptButton: Button
@export var DocumentationButton: Button
@export var Docs: Control


var highlighter = CodeHighlighter.new()
var AssemblyText = PackedStringArray([])

var boilerPlate = "res://boilerPlate.txt"

var isDocsActivated = false

const gdScriptPath = "user://Scripts/"

enum {
	STOP,
	MOV_R_V,
	MOV_R_R,
	WRITE, #WRITE to ram
	LOAD, # Get value from ram
	ADD, #Adds two registers
	SUB, # Subtracts two  registers
	JMP,
	SPR,
	IF,
	MOV_A_R,
	CLEAR
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	CodeEditor.text=decompile(Globals.ram.size() - 20480)
	print("IDE Boot -> isOnGDscript: ", Globals.isOnGDscript, " | isJustLoaded: ", Globals.isJustLoaded)
	setUpHighlighting()
	changeScriptingMode()
	if Globals.isOnGDscript && Globals.isJustLoaded:
		var loadingText = FileAccess.open("user://loading.txt", FileAccess.READ)
		if loadingText != null:
					var loaded_string = loadingText.get_as_text()
					print("String pulled from file: \n", loaded_string) 
					CodeEditor.text = loaded_string
					loadingText.close()
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass




func _on_save_pressed() -> void:
	NamingPopup.visible = true
	pass


func _on_line_edit_text_submitted(new_text: String) -> void:
	if(!Globals.isOnGDscript):
		scriptPath = new_text
		var file = CodeEditor.text
		NamingPopup.visible = false
		var bytecode = compile(file)
		for i in range(bytecode.size()):
			Globals.ram[0x5000+i] = bytecode[i]
		Globals.isRunning = false
		Globals.isStopped = false
		Globals.pc = 0x5000
	else:
		var file = CodeEditor.text
		NamingPopup.visible = false
		Globals.GDscript = file
		var loadFile = FileAccess.open("user://loading.txt", FileAccess.WRITE)
		loadFile.store_string(file)
		runGDscript(file)
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
				bytecode.append(tokens[2].to_int() / 256)
				bytecode.append(tokens[2].to_int() % 256)
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
				bytecode.append(checkForRegister(tokens[2], bytecode))
			"ADD":
				bytecode.append(ADD)
				bytecode.append(tokens[1].replace("R", "").to_int())
				bytecode.append(checkForRegister(tokens[2], bytecode))
			"SUB":
				bytecode.append(SUB)
				bytecode.append(tokens[1].replace("R", "").to_int())
				bytecode.append(checkForRegister(tokens[2], bytecode))
			"JMP":
				bytecode.append(JMP)
				bytecode.append(tokens[1].to_int() / 256)
				bytecode.append(tokens[1].to_int() % 256)
			"SPR":
				bytecode.append(SPR)
				bytecode.append(checkForRegister(tokens[1], bytecode))
				bytecode.append(checkForRegister(tokens[2], bytecode))
				bytecode.append(checkForRegister(tokens[3], bytecode))
			"IF":
				bytecode.append(IF)
				bytecode.append(checkForRegister(tokens[1], bytecode))
				bytecode.append(checkForRegister(tokens[2], bytecode))
				bytecode.append(tokens[3].to_int())
			"MOV_A_R":
				bytecode.append(MOV_A_R)
				bytecode.append(tokens[1].replace("R", "").to_int())
				bytecode.append(tokens[2].to_int() / 256)
				bytecode.append(tokens[2].to_int() % 256)
			"CLEAR":
				bytecode.append(CLEAR)
	bytecode.append(0xFF)
	return bytecode
 

func decompile(length: int) -> String:
	var pc = 20480 # 0x5000
	var AssemblyText = PackedStringArray([])
	while pc < 20480 + length:
		var opcode = Globals.ram[pc]
		if opcode == 0xFF:
			break
		match opcode:
			MOV_R_V:
				var reg = Globals.ram[pc + 1]
				var val = (Globals.ram[pc + 2] * 256) + Globals.ram[pc + 3]
				AssemblyText.append("MOV_R_V" +" "+ str(reg) +" "+ str(val) + "\n")
				pc += 4
			STOP:
				AssemblyText.append("STOP")
				pc += 1
			MOV_R_R:
				var reg1 = Globals.ram[pc + 1]
				var reg2 = Globals.ram[pc + 2]
				AssemblyText.append("MOV_R_R" +" " + str(reg1) + " " + str(reg2) + "\n")
				pc += 3
			WRITE:
				var addr = (Globals.ram[pc + 1]*256 + Globals.ram[pc +2])
				var val = Globals.ram[pc + 3]
				AssemblyText.append("WRITE" + " " + str(addr) + " " + str(val) + "\n")
				pc += 4
			ADD:
				var R1 = Globals.ram[pc + 1]
				var R2 = Globals.ram[pc + 2]
				AssemblyText.append("ADD" + " " + str(R1) + " " + str(R2) + "\n")
				pc += 3
			SUB:
				var addr = (Globals.ram[pc + 1] * 256 + Globals.ram[pc + 2])
				var val = (Globals.ram[pc + 3] * 256 + Globals.ram[pc + 4])
				AssemblyText.append("SUB" + " " + str(addr) + " " + str(val) + "\n")
				pc += 5
			JMP:
				var addr = (Globals.ram[pc + 1] * 256 + Globals.ram[pc + 2])
				AssemblyText.append("JMP" + " " + str(addr) + "\n")
				pc += 3
			SPR:
				var index = Globals.ram[pc + 1]
				var x = Globals.ram[pc + 2]
				var y = Globals.ram[pc + 3]
				AssemblyText.append("SPR" + " " + str(index) + " " + str(x) + " " + str(y) + "\n")
				pc += 4
			IF:
				var val1 = Globals.ram[pc + 1]
				var val2 = Globals.ram[pc + 2]
				var pcInc = Globals.ram[pc + 3]
				AssemblyText.append("IF" + " " + str(val1) + "  " + str(val2) + " " + str(pcInc) + "\n")
				pc += 4
			MOV_A_R:
				var highByte = Globals.ram[pc + 2]
				var lowByte = Globals.ram[pc + 3]
				var address = (highByte * 256) + lowByte
				var Register = Globals.ram[pc + 1]
				AssemblyText.append("MOV_V_R " + "R" + str(Register) + " " + str(address) + "\n")
				pc += 4
			CLEAR:
				AssemblyText.append("CLEAR" + "\n")
				pc += 1
			_:
				pc+=1
	var FinishedAssemblyText = "".join(AssemblyText)
	return FinishedAssemblyText
		

func checkForRegister(token: String, bytecode: PackedByteArray) -> int:
	if token.begins_with("R"):
		bytecode.append(1)
		return token.replace("R", "").to_int()
	bytecode.append(0)
	return token.to_int()

func _on_back_pressed() -> void:
	Globals.isRunning = false
	Globals.isStopped = false
	Globals.pc = 0
	get_tree().change_scene_to_file("res://main.tscn")
	pass




func _on_scripting_toggle_pressed() -> void:
	Globals.isOnGDscript = !Globals.isOnGDscript
	changeScriptingMode()
	pass 

func changeScriptingMode() -> void:
	if Globals.isOnGDscript:
		GDscriptButton.text = "GDscript"
		CodeEditor.text = FileAccess.get_file_as_string(boilerPlate)
	else:
		GDscriptButton.text = "Assembly"
	print(Globals.isOnGDscript)


func runGDscript(script: String) -> void:
	var n_script = GDScript.new()
	
	var clean_script = ""
	for i in range(script.length()):
		var char_code = script.unicode_at(i)
		if char_code != 0 and char_code != 0xFFFD:
			clean_script += String.chr(char_code)
			
	n_script.source_code = clean_script
	
	# 3. Compile!
	var compile = n_script.reload()
	if compile == OK:
		var MainScene = load("res://main.tscn")
		var MainInstance = MainScene.instantiate()
		var targetNode = MainInstance.get_node("GDscriptRunner")
		targetNode.set_script(n_script)
		add_child(MainInstance)
	else:
		print("Compiler failed even after scrubbing!")

func _on_documentation_pressed() -> void:
	isDocsActivated = !isDocsActivated
	if isDocsActivated:
		Docs.visible = true
	else:
		Docs.visible = false
	pass
	
	
func setUpHighlighting() -> void:
	highlighter.number_color = Color("00873bff")
	highlighter.symbol_color = Color(0.513, 0.513, 0.513, 1.0)
	highlighter.function_color = Color(0.418, 0.602, 1.0, 1.0)
	highlighter.member_variable_color = Color("#fd971f") # Orange
	var keyword_color = Color("#f92672") # Pink/Red
	var keywords = [
		"func", "var", "if", "else", "elif", "pass", 
		"extends", "return", "void", "Node", "for", "while"
	]
	for kw in keywords:
		highlighter.add_keyword_color(kw, keyword_color)
	highlighter.add_color_region("#", "", Color("#75715e"), true)
	highlighter.add_color_region('"', '"', Color("#e6db74"), false)
	CodeEditor.syntax_highlighter = highlighter
	pass


func _on_undo_pressed() -> void:
	CodeEditor.undo()
	pass


func _on_redo_pressed() -> void:
	CodeEditor.redo()
	pass
