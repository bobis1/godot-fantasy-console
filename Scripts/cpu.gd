extends Node

var AssemblyFile
var AssemblyFileName: String

func _ready() -> void:
	AssemblyFile = FileAccess.get_file_as_string("user://" + AssemblyFileName)
