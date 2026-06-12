extends Node2D

var scriptPath = ""
@export var NamingPopup: Control
@export var CodeEditor: CodeEdit
@export var GDscriptButton: Button
@export var DocumentationButton: Button
@export var Docs: Control
@export var DocumentationText: RichTextLabel

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
	DocumentationText.text = "
[b][color=#66d9ef]1. SYSTEM ARCHITECTURE[/color][/b]
This system provides raw, low-level access to the virtual CPU and RAM. You can write highly optimized Assembly directly to memory, or use the GDScript wrapper for high-level engine logic.
[ul]
Memory: 64KB (Addressable up to [code]0xFFFF[/code])
 Program Counter (PC) begins at [code]0x5000[/code] (20480)
 Universal registers accessed via [code]R[/code] prefix (e.g., [code]R1[/code])
[/ul]

[b][color=#a6e22e]2. ASSEMBLY INSTRUCTIONS[/color][/b]
The arguments have to be seperated by a single space
[table=3]
[cell][b]CMD[/b][/cell] [cell][b]ARGS[/b][/cell] [cell][b]DESCRIPTION[/b][/cell]
[cell][color=#f92672]MOV_R_V[/color][/cell] [cell]Reg Val[/cell] [cell]Moves a literal integer [i]Val[/i] into register [i]Reg[/i].[/cell]
[cell][color=#f92672]MOV_R_R[/color][/cell] [cell]R1 R2[/cell] [cell]Copies the value currently stored in [i]R1[/i] into [i]R2[/i].[/cell]
[cell][color=#f92672]MOV_A_R[/color][/cell] [cell]Reg Addr[/cell] [cell]Moves the value stored at memory [i]Addr[/i] into [i]Reg[/i].[/cell]
[cell][color=#f92672]WRITE[/color][/cell] [cell]Addr Val[/cell] [cell]Writes a literal [i]Val[/i] directly into RAM [i]Addr[/i].[/cell]
[cell][color=#f92672]ADD[/color][/cell] [cell]R1 R2[/cell] [cell]Adds the value of [i]R2[/i] to [i]R1[/i].[/cell]
[cell][color=#f92672]SUB[/color][/cell] [cell]Addr Val[/cell] [cell]Subtracts [i]Val[/i] from the data at memory [i]Addr[/i].[/cell]
[cell][color=#f92672]JMP[/color][/cell] [cell]Addr[/cell] [cell]Jumps the Program Counter (PC) to [i]Addr[/i].[/cell]
[cell][color=#f92672]IF[/color][/cell] [cell]V1 V2 Jmp[/cell] [cell]If [i]V1 == V2[/i], the PC jumps forward by [i]Jmp[/i] steps.[/cell]
[cell][color=#f92672]SPR[/color][/cell] [cell]Idx X Y[/cell] [cell]Draws sprite mapped to [i]Idx[/i] at screen coordinates [i]X, Y[/i].[/cell]
[cell][color=#f92672]CLEAR[/color][/cell] [cell]None[/cell] [cell]Clears the current screen data buffer.[/cell]
[cell][color=#f92672]STOP[/color][/cell] [cell]None[/cell] [cell]Halts the CPU execution completely.[/cell]
[/table]

[b][color=#fd971f]3. GDSCRIPT WRAPPER[/color][/b]
If you don't wanna write in the fake assembly thing then you also have an option to use gdscript
[ul]
It is highly recommended that you look at the GDscriptWrapper.gd file to get a basic understanding of the helper functions included there.
However, some of the basic helper functions include: 
	isUpPressed() -> This returns true if the W key is pressed
	isDownPressed() -> This returns true if the S key is pressed
	isLeftPressed() -> This returns true if the A key is pressed
	isRightPressed() -> This returns true if the D key is pressed.
	isAPressed() -> This returns true if the Q key is pressed(Yes, I know I was thinking the A button of a console)
	setRegisterValue(register: int, value: int) -> This sets the register with the id that you inputed to the value that you inputed.
	addRegisterValue(register: int, value: int) -> This adds the values that you inputed to the register that you inputed.
	subRegisterValue(register: int, value: int) -> This subtracts the value that you inputed from the register that you inputed.
	getRegisterValue(register: int) -> This returns the value that is stored in the register that you inputed
	draw_sprite(sprite_index: int, x: int, y: int) -> This draws the sprite of a specific ID and draws it to the x and y position that is inputed.
	SwitchTileMap(tilemapindex: int) -> Loads the tilemap with the id that you inputted
	DrawTestPattern() -> This will draw the test pattern that was created when I first started making this fantasy console.
	moveSpriteWithButtons(sprite: int, vx: int, vy: int, reg1: int, reg2: int) -> This will set up a sprite to be moved with buttons
	NOTE: In order for this to work you need to 
[/ul]"
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
