# Godot Fantasy Console
### Why this exists
After 3 failed projects to create a fantasy game console. I believe that this project is ready for people to see it. I created this project with the purpose of learning more about consoles and computers as a whole at a lower level.

### Usage
When you first start the fantasy console you load into the "Game" Screen. When you are here the assembly program that is loaded will be running To go to the sprite editor you hit "r" on your keyboard. After this to get to the different menus of the editor there are different buttons to get you there such as the "Script" and "Cartridge" buttons.
Video demo of how to load a cartridge: https://www.youtube.com/watch?v=jbBCyqgyIfA The cartridge must be a .png that either you created or a demo from the demos folder.


### Specifications
This console has 64kb of "ram" and 8 registers. The chart of all the addresses that the different "parts" of ram is below.
| Purpose   | Start/End |
| -------- | ---------- |
| Vram     | 0x000/0x4B00|
| Palette   |      0x4B01|
|Input      |      0x4B31 |
|Sprite     | 0x4B32/0x4FF6|
|Instruction| 0x5000/0x10000|

#### Sprites
Each of the 64 pixel sprites are 32 bytes. With two pixels per byte. Each sprite has an index that is associated when you save it. To load a sprite in using the SPR instruction you have to put the sprite index as the first parameter.

#### Palette
In this console there are 16 colors for you to chose from when creating your sprites. All of them are collected in this chart

| Name   | RGB
| -------- | ---------- |
| Transparent     | 0,0,0(This is special it will simply not render)||
| Red       |  255,0,0|
|Green      |  0,255,0 |
|Blue       | 0,0,255|
|Purple     |150,0,150
|Yellow | 230,201,137|
|Brown | 160,80,60|
|Peach | 255, 204, 170|
|Lavender| 131, 118, 156|
|Light Gray| 194, 195, 199|
|Dark Gray| 104, 105, 109|
|Dark Blue| 29, 43, 83|
|Dark Purple| 126, 37, 83|
|Lime Green| 168,231,46|
|Mauve| 117,70,101|
|Teal| 18,83,89|

#### Instructions
To create programs on this I created a very scuffed assembly language to do this. There are 12 instructions in the chart below. Examples of simple programs written in this assembly language can be found in the demos folder.

| Mnemonic   | Usage | Example|
| -------- | ----------|---------|
| STOP     | Stops the program| STOP|
| MOV_R_V   |      Moves a given value into a register|MOV R0 25 |
|MOV_R_R      |      Moves the value of a Register into a second register | MOV R0 R1|
|WRITE     | Writes a value into ram(It can be a value from a register or a static value)| WRITE 20494 40|
|ADD| Adds a given value to a register(The second value can be a register or a static value)|ADD R2 10 |
|SUB| Subtracts a given value to a register(The second value can be a register or a static value)| SUB R2 10|
|JMP| Jumps to a certain value in the ram(This is typed in decimal)|JMP 20480|
|SPR| Creates a sprite of a given index and a given x and y value.| SPR 0 R1 R2|
|IF| Checks if two given values are true. If so then it moves on to the instruction right after it. If it is false it skips forward by an amount given by the third parameter.|IF R3 0 1|
|MOV_A_R| Moves a value from ram into a register.| MOV_A_R R0 19249|
|CLEAR| This draws the test pattern.(Not recomended for use)|CLEAR|

#### Cartridges
Right now the cartridges work by appending the ram to the end of a .png file. This .png file has a color randomly chosen. At some point I would like the center disk of the .png reflect what is actually being loading into it.

#### Inputs
There are 6 inputs right now W,A,S,D,Q, and E. The input byte will automatically change based on which of these inputs you click. with 1,2,3,4,5,6 being the respective values based on the inputs.

