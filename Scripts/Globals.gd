extends Node

var ram = PackedByteArray()
var isRunning: bool
var pc = 0x5000
var isStopped: bool = false
var IsRamInit: bool = false
var isLoaded: bool = false
var wantCleared: bool = false
