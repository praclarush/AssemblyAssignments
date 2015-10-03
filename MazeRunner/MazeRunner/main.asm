;/* ---------------------------------------------------------------------------
 ;** File: main.asm
 ;** Description: Maze Runner Game for Final Project in CSPG360
 ;**              Computer Organization and Assembly Language
 ;** Author: Nathan Bremmer
 ;** -------------------------------------------------------------------------*/

INCLUDE Irvine32.inc
INCLUDE macros.inc

.386
.model flat, stdcall
.stack 4096

;//Prototypes
ExitProcess proto, dwExitCode:dword
GetValueFromMatrix proto matrix : PTR BYTE, cords : COORD, nRows : byte, nCols : byte

;//Constants
BUFFER_SIZE = 5000

.data

;//Console Variables
consoleTitle byte "Maze Runner", 0
consoleHandle DWORD ?
cursorInfo CONSOLE_CURSOR_INFO < >

;//Map data
mapWidth BYTE 23
mapHeight BYTE 20

;//Locations of lots of things - x, y
ALIGN WORD
FuturePOS COORD <0, 1>
ALIGN WORD
CurrentPOS COORD <0, 1>
ALIGN WORD
ScorePOS COORD <0, 0>
ALIGN WORD
TimerPOS COORD <0, 0>
ALIGN WORD
MarkerPOS COORD < 0, 0 >

;//game info
msgTiming byte "Time Remaining: ", 0
timeStart DWORD 0
timePrev DWORD 0
timeElapsed DWORD 0
timeRemaining DWORD 0
maxTime DWORD 0
msgScore byte "Score: ", 0
score dword 0

;//File Info
scoreFileName byte "scores.dat", 0
helpFileName byte "HelpFile.dat", 0
levelfileName byte "level.dat", 0

fileBuffer Byte BUFFER_SIZE DUP(? )
levelBuffer Byte BUFFER_SIZE DUP(? )
helpFileHandle HANDLE ?
fileHandle HANDLE ?
.code

;//MACROS
;//------------------------------------------------------------------------------
mCopyCOORD MACRO destCOORD : req, sourceCOORD : req
;//
;// Description: Copies the values of one COORD struct to another
;// Avoid Using ax
;// Receives: a destination coord and a source coord struct; 
;// Returns: Nothing
;//------------------------------------------------------------------------------
push ax
xor ax, ax                              ;//clean ax register
mov ax, (coord ptr sourceCOORD).X       ;//move the value of sourceCOORD.x to the ax register
mov(coord ptr destCOORD).X, ax          ;//move the value of the ax register to destCOORD.x

xor ax, ax                              ;//clean ax register
mov ax, (coord ptr sourceCOORD).Y       ;//move the value of sourceCOORD.x to the ax register
mov(coord ptr destCOORD).Y, ax          ;//move the value of the ax register to destCOORD.x

pop ax
ENDM

;//------------------------------------------------------------------------------
mPrintAtLocation MACRO message : req, coords : req, color : req, optionalIntValue
LOCAL currentTextColor
;//
;// Description: prints a string in the specified color at the specified location
;//              if an optionalIntValue is included print it after the message
;// Avoid Using: eax, edx
;// Receives:Message, coords, color, optional Value
;// Returns:Nothing
;//------------------------------------------------------------------------------
.data
currentTextColor DWORD ?
.code
push eax
push edx

INVOKE SetConsoleCursorPosition, consoleHandle, coords      ;//move the cursor to the position specified in coords
mWrite "                                             ", 0   ;//shady hack that should be fixed. used to replace the text that was there so that stuff isn't left behind
INVOKE SetConsoleCursorPosition, consoleHandle, coords      ;//reset the cursor to the position specified in coords

call GetTextColor                                           ;//get the current text color of the background and foreground
mov currentTextColor, eax                                   ;//save the current color data into currentTextColor;

mov eax, color                                              ;//move the new color into the eax register
call SetTextColor                                           ;//set the new color to be used when writing to the console

mov edx, offset message                                     ;//move the address of the message into edx register
call WriteString                                            ;//write the data stored in the edx register to the screen

IFNB < optionalIntValue >                                   ;// check to see if anything was passed in optionalIntValue
xor eax, eax                                                ;//clean the eax register
mov eax, optionalIntValue                                   ;//move the optionalIntValue to the eax register
call WriteInt                                               ;//write the value of eax onto the screen
ENDIF

mov eax, currentTextColor                                   ;//move the text color stored in currentTextColor to eax
call SetTextColor                                           ;//set the text color to the value stored in eax

pop edx
pop eax
ENDM

;//------------------------------------------------------------------------------
main proc
;//
;// Description: Main Application Entry Point
;// Receives: Nothing
;// Returns: Nothing
;//------------------------------------------------------------------------------

;//Init
INVOKE GetStdHandle, STD_OUTPUT_HANDLE                          ;//get the handle for the console window
mov consoleHandle, eax                                          ;//store the handle in consoleHandle
INVOKE GetConsoleCursorInfo, consoleHandle, addr cursorInfo     ;//get the cursor info struct
mov cursorInfo.bVisible, FALSE                                  ;//set the cursor visibility to false in the info struct
INVOKE SetConsoleCursorInfo, consoleHandle, addr cursorInfo     ;//write the info struct to the console
INVOKE SetConsoleTitle, addr consoleTitle                       ;//set the Console Title

;//set up Positions for Score and Timer
mov score, 0                                                    ;//reset score
xor ax, ax                                                      ;//clean ax register
movzx ax, mapWidth                                              ;//set ax to the mapWidth
add ax, 1                                                       ;//add 1 to ax
mov ScorePOS.X, ax                                              ;//set the value of ax to the ScorePOS.X
mov ScorePOS.Y, 2                                               ;// set ScorePOS.y to 2
mov TimerPOS.X, ax                                              ;//set the value of ax to the TimerPOS.x
mov TimerPOS.Y, 1                                               ;//set the value of TimerPOS.y to 1

;//End Init

MainScreen:
xor eax, eax
call MenuScreen;//show the main Menu

cmp ax, 1                                                       ;//if the player choice is 1 jump to startGame
jz StartGame
cmp ax, 2                                                       ;//if the player choice is 2 jump to ShowScore
jz ShowScore
cmp ax, 3                                                       ;//if the player choice is 3 jump to Help
jz Help
cmp ax, 4                                                       ;//if the player choice is 4 jump to ExitProgram
jz ExitProgram

jmp MainScreen                                                  ;//if no choice was made reshow the Main Menu


Help:
call PrintHelpFile                                              ;//Show the Help file
jmp MainScreen                                                  ;//jump to main menu

StartGame:
call MainGameLoop                                               ;//Begin the Game
jmp MainScreen                                                  ;//jump to main menu

ShowScore:
call ScoreScreen                                                ;//show the Score Screen
jmp MainScreen                                                  ;//jump to Main Menu

;//Clean up Before Exit
mov cursorInfo.bVisible, TRUE                                   ;//set the cursor to visible
INVOKE SetConsoleCursorInfo, consoleHandle, addr cursorInfo     ;//write the cursor struct to the console

ExitProgram:
invoke ExitProcess, 0                                           ;//exit application thread
main endp

;//Procedures

;//------------------------------------------------------------------------------
PrintScores PROC USES edx ecx eax ebx
;//
;// Description: Reads the Score file and prints it to the screen.
;// Uses: edx, ecx, eax, and ebx
;// Receives: Nothing
;// Returns: array stored in fileBuffer
;//------------------------------------------------------------------------------

.code
mov edx, OFFSET scoreFileName   ;//move the address of scoreFileName to edx
call OpenInputFile              ;//open the file specified in edx
mov fileHandle, eax             ;//move the file Handle to fileHandle

mov edx, OFFSET fileBuffer      ;//move the address of the fileBuffer to edx
mov ecx, BUFFER_SIZE            ;//move the size of the fileBuffer to ecx
call ReadFromFile               ;//read the file into edx/fileBuffer

;//clean registers
mov ecx, 0
mov eax, 0
mov ebx, 0

mov edx, OFFSET fileBuffer      ;//move the address of the fileBuffer to edx; this is due to edx possibly being changed before now
mov ecx, SIZEOF fileBuffer      ;//move the size of the fileBuffer to ecx

call WriteString                ;//write the contents of edx to the screen
call Crlf                       ;//print a new line

mov eax, fileHandle             ;//move the fileHandle to eax
call CloseFile                  ;//close the fileHandle

ret
PrintScores ENDP

;//------------------------------------------------------------------------------
PrintMaze PROC USES edx ecx eax ebx
;//
;// Description: Reads the Maze Map data file and prints it to the screen.
;// Uses: edx, ecx, eax, and ebx
;// Receives: Nothing
;// Returns: array stored in levelBuffer
;//------------------------------------------------------------------------------

.code
call Clrscr
mov edx, OFFSET levelfileName   ;//move the address of levelfileName to edx
call OpenInputFile              ;//open the file specified in edx
mov fileHandle, eax             ;//move the file Handle to fileHandle

mov edx, OFFSET levelBuffer     ;//move the address of the levelBuffer to edx
mov ecx, BUFFER_SIZE            ;//move the size of the levelBuffer to ecx
call ReadFromFile               ;//read the file into edx/levelBuffer

;//clean registers
mov ecx, 0
mov eax, 0
mov ebx, 0

mov edx, OFFSET levelBuffer     ;//move the address of the levelBuffer to edx; this is due to edx possibly being changed before now
mov ecx, SIZEOF levelBuffer     ;//move the size of the levelBuffer to ecx

call WriteString                ;//write the contents of edx to the screen
call Crlf                       ;//print a new line

mov eax, fileHandle             ;//move the fileHandle to eax
call CloseFile                  ;//close the fileHandle

ret
PrintMaze ENDP

;//------------------------------------------------------------------------------
PrintHelpFile PROC USES edx ecx eax ebx
;//
;// Description: Reads the help file into a buffer array and prints it to the screen
;// Uses: edx, ecx, eax, and ebx
;// Receives: Nothing
;// Returns: array stored in fileBuffer
;//------------------------------------------------------------------------------
.code
call Clrscr
mov edx, OFFSET helpFileName    ;//move the address of helpFileName to edx
call OpenInputFile              ;//open the file specified in edx
mov helpFileHandle, eax         ;//move the file Handle to helpFileHandle

mov edx, OFFSET fileBuffer      ;//move the address of the fileBuffer to edx
mov ecx, BUFFER_SIZE            ;//move the size of the fileBuffer to ecx
call ReadFromFile               ;//read the file into edx/fileBuffer

;//clean registers
mov ecx, 0
mov eax, 0
mov ebx, 0

mov edx, OFFSET fileBuffer      ;//move the address of the fileBuffer to edx; this is due to edx possibly being changed before now
mov ecx, SIZEOF fileBuffer      ;//move the size of the fileBuffer to ecx

call WriteString                ;//write the contents of edx to the screen
call Crlf                       ;//print a new line

mov eax, helpFileHandle         ;//move the fileHandle to eax
call CloseFile                  ;//close the fileHandle

call Crlf                       ;//print a new line
call WaitMsg                    ;//print wait prompt
ret
PrintHelpFile ENDP

;//------------------------------------------------------------------------------
GetValueFromMatrix PROC USES eax ecx edx,
matrix: PTR BYTE, coords : COORD, nRows : byte, nCols : byte
        LOCAL baseAddress : BYTE
        ;//
;// Description: Gets a value at the specified location from the map array
;// Uses: eax, ecx, edx
;// Receives: a Pointer to COORDs, nRows and, NCols
;// Returns: the value in the array at the location specified in matrix using ebx
;//------------------------------------------------------------------------------
.data
bytesInRow dword ?
.code
;//clean registers
xor eax, eax;
xor ecx, ecx;
xor ebx, ebx

movzx ecx, (coord ptr coords).X     ;//move the value of x into ecx - this is the column in the matrix
movzx eax, (coord ptr coords).Y     ;//move the value of y into eax - this is the row in the matrix
mul nCols                           ;//multiply eax by nCols - the length of each row - this moves the array index to the first column of the row specified in eax

add ecx, eax                        ;//add the value of eax to ecx - this moves the index to the column specified in ecx for row eax
movzx ebx, [levelBuffer + 1 * ecx]  ;//get the value located at the index calculated in ecx

ret
GetValueFromMatrix ENDP

;//------------------------------------------------------------------------------
SetValueToMatrix PROC USES eax ecx,
matrix: PTR BYTE, coords : COORD, nRows : byte, nCols : byte, value : byte
        ;//
;// Description: sets a value to the map array at the specified location
;// Uses: eax, ecx
;// Receives: a Pointer to COORDs, nRows, NCols and, the value to set
;// Returns: Nothing
;//------------------------------------------------------------------------------
.code
;//clean registers
xor eax, eax;
xor ecx, ecx;

movzx ecx, (coord ptr coords).X     ;//move the value of x into ecx - this is the column in the matrix
movzx eax, (coord ptr coords).Y     ;//move the value of y into eax - this is the row in the matrix
mul nCols                           ;//multiply eax by nCols - the length of each row - this moves the array index to the first column of the row specified in eax
add ecx, eax                        ;//add the value of eax to ecx - this moves the index to the column specified in ecx for row eax
xor eax, eax                        ;//clean the eax register for use
mov al, value                       ;// set the value of value to the al register
mov levelBuffer[ecx], al            ;//set the value of the al register to the location pointed to by ecx in the level buffer

ret
SetValueToMatrix ENDP


;//------------------------------------------------------------------------------
MainGameLoop PROC USES eax
;//
;// Description: The Main Game Loop
;// Uses: eax
;// Receives: Nothing
;// Returns: value stored in gameOver variable as a 1 or 0
;//------------------------------------------------------------------------------
.data

.code
;// TODO(Nathan): Need to default COORS for current and future player POS for each new game

;//Set player positions before starting game
mov CurrentPOS.X, 0
mov CurrentPOS.Y, 1
mov FuturePOS.X, 0
mov FuturePOS.Y, 1

call PrintMaze                                      ;//print the maze to the screen
call GenerateScorePickups                           ;//setup score pickups

;//set default values for timer
mov timeElapsed, 0
mov timeStart, 0
mov timePrev, 0
mov maxTime, 60                                     ;//time limit is 60 seconds
mov timeRemaining, 60                               ;//time limit is 60 seconds
call GetMSeconds                                    ;//get the current milliseconds
mov timeStart, eax                                  ;//move the current milliseconds to timeStart

;//Draw starting information on screen before entering game loop

mPrintAtLocation msgScore, ScorePOS, white, score   ;//print the score to the location specified in ScorePOS
mPrintAtLocation msgTiming, TimerPOS, white         ;//print the time remaining to the location specified in TimerPOS

call UpdatePlayerLocation                           ;//update the player's location on the map

GameLoop:
xor ebx, ebx                                        ;//clean the ebx register
call GetPlayerInput                                 ;// get the player input and update gamestate

cmp ebx, 1                                          ;//if the gamestate stored in ebx is 1 then the game ended in victory
jz Win                                              ;//jump to Win

call UpdateTimer                                    ;//update the game timer
cmp timeRemaining, 0                                ;//check if there is time remaining; if there isn't then set flag to 0
jz GameOver                                         ;//jump to gameover

jmp GameLoop                                        ;//if the gamestate isn't 1 or the time remaining jump to the top of the loop.

GameOver:
call Clrscr                                         ;//clear the screen
mWrite "Game Over, you ran out of time", 13, 10, 0  ;//print the game over message
call Crlf                                           ;//print a new line
call WaitMsg                                        ;//print wait message
jmp quit                                            ;//jump to quit

Win:
call Clrscr                                         ;//clear the screen
call SaveScore                                      ;//prompt the player to save score 
call Crlf                                           ;//print new line
call WaitMsg                                        ;//print wait message
jmp quit                                            ;//jump to quit

quit:
ret
MainGameLoop ENDP

;//------------------------------------------------------------------------------
UpdateTimer proc USES eax ebx edx
;//
;// Description: Updates the Timer in game
;// Uses: eax ebx edx
;// Receives: Nothing
;// Returns: Nothing
;//------------------------------------------------------------------------------

mov eax, timeElapsed                                        ;//move the value of timeElapsed into eax
mov timePrev, eax                                           ;//save this value into timePrev

call GetMSeconds                                            ;//get the current milliseconds
sub eax, timeStart                                          ;//subtract the value of timeStart from eax
mov edx, 0                                                  ;//clean edx
mov ebx, 1000                                               ;//set ebx to 1000 milliseconds or 1 second
div ebx                                                     ;//divide edx by ebx

mov timeElapsed, eax                                        ;//set the value of eax to timeElapsed; this is now in seconds
mov ebx, maxTime                                            ;//move the value of maxTime to ebx
sub ebx, timeElapsed                                        ;//subtract the timeElapsed from ebx
mov timeRemaining, ebx                                      ;//move the value of ebx to timeRemaining

mPrintAtLocation msgtiming, TimerPOS, white, timeRemaining  ;//print the value of timeRemaining to the location specified in TimerPOS
ret
UpdateTimer endp

;//------------------------------------------------------------------------------
GetPlayerInput PROC USES eax
LOCAL keyPress : BYTE
;//
;// Description: Gets the players Input then updates the character POS, Score and
;//              and timer on the screen
;// Uses: eax
;// Receives: Nothing
;// Returns: value stored in gameOver variable as a 1 or 0
;//------------------------------------------------------------------------------
.data

.code
mov keyPress, 0                                     ;// clean the variable keyPress

xor eax, eax                                        ;//clean the eax register
mov eax, 10                                         ;//set the eax register to 10
call Delay                                          ;//wait amount of time equal to the value of eax
call ReadKey                                        ;//get the current key pressed

mov keyPress, al                                    ;//move the value of al (key pressed) into keyPress

.IF(keyPress == "s")
inc FuturePOS.Y                                     ;//if the key Pressed is s then increment the y position in futurePOS (move down)
.ELSEIF(keyPress == "w")                            
dec FuturePOS.Y                                     ;//if the key Pressed is w then decrement the y position in futurePOS (move up)
.ELSEIF(keyPress == "d")                            
inc FuturePOS.X                                     ;//if the key Pressed is d then increment the x position in futurePOS (move right)
.ELSEIF(keyPress == "a")                            
dec FuturePOS.X                                     ;//if the key Pressed is a then increment the y position in futurePOS (move right)
.ENDIF

xor ebx, ebx                                        ;//clean the ebx register

;//get the value in the levelBuffer at the FuturePOS
invoke GetValueFromMatrix, addr levelBuffer, FuturePOS, mapHeight, mapWidth

;//http://www.ascii-code.com/
;//Check if Move is valid
.IF(ebx != 0 && ebx != 13 && ebx != 12 && ebx != 43 && ebx != 45 && ebx != 124 && keyPress != 1);

;//set char at position in map array to space as well;
invoke SetValueToMatrix, addr levelBuffer, CurrentPOS, mapHeight, mapWidth, " "

call UpdatePlayerLocation                           ;//update the player location on the map

.IF(ebx == 126)
mov ebx, 1                                          ;//set the gamestate to 1
jmp Quit                                            ;//jump to quit
.ELSEIF(ebx == 157)
add score, 15                                       ;//add 15 to the score
.ELSEIF(ebx == 234)
add score, 10                                       ;//add 10 to the score
.ENDIF

mPrintAtLocation msgScore, ScorePOS, white, score   ;//print the score to the position specified in ScorePOS
.ElSE
mCopyCOORD FuturePOS, CurrentPOS                    ;//reset the futurePOS to the currentPOS 
.ENDIF
mov ebx, 0                                          ;//set the value of ebx to 0

Quit:
ret
GetPlayerInput ENDP

;//------------------------------------------------------------------------------
MenuScreen PROC USES edx
;//
;// Description: Prints the Main Menu and Reads user input
;// Uses: edx
;// Receives: Nothing
;// Returns: player menu choice stored in AX
;//------------------------------------------------------------------------------
.data
msgMenu byte "1: Play", 13, 10, "2: Scores", 13, 10, "3: Help", 13, 10, "4: Exit", 13, 10, 0

.code
;//clean the registers
xor eax, eax
xor edx, edx

call Clrscr                 ;//clear the screen
mov edx, OFFSET msgMenu     ;//move the address of msgMenu to edx
call WriteString            ;//write the value stored in edx to the console
call Crlf                   ;//write a new line
call readInt                ;//read input from keyboard

ret
MenuScreen ENDP

;//------------------------------------------------------------------------------
ScoreScreen PROC USES eax edx
;//
;// Description: Reads and Displays the Scores from a File
;// Uses: eax and edx
;// Receives: Nothing
;// Returns: Nothing
;//------------------------------------------------------------------------------
.data
msgScoreTitle byte "Scores: ", 13, 10, 0

.code
;//clean registers
xor eax, eax
xor edx, edx

call Clrscr                     ;//clear the screen
mov edx, OFFSET msgScoreTitle   ;//move the address of msgScoreTitle to edx
call WriteString                ;//write the value of edx to the console 
call Crlf                       ;//write a new line
call PrintScores                ;//print the scores to the screen
call WaitMsg                    ;//print wait message

ret
ScoreScreen ENDP

;//------------------------------------------------------------------------------
SaveScore PROC USES edx ecx eax ebx
;//
;// Description: Saves the Score and Completion Time to a file 
;// Uses:
;// Receives: name, score and, time remaining
;// Returns: Nothing
;//------------------------------------------------------------------------------
.data
scoreSaveFileHandle Handle ?
stringLength dword ?
stringNewLine byte 13, 10
.code

mov cursorInfo.bVisible, TRUE           ;//set the cursor visible so the user can see what they type

;//set the cursor info struct to the console
INVOKE SetConsoleCursorInfo, consoleHandle, addr cursorInfo

call Clrscr                             ;//clear the screen

mWrite "Congratulations on wining!"     ;//print the win message to the screen
call Crlf                               ;//print an new line
mWrite "score: "                        ;//print score leader text to the screen

xor eax, eax                            ;//clean the eax register
mov eax, score                          ;//move the value of score to eax
call WriteInt                           ;//write the value of eax to the screen

call Crlf                               ;//write a new line
mWrite "Time Remaining: "               ;//write the time remaining message to the screen

xor eax, eax                            ;//clean the eax register
mov eax, timeRemaining                  ;//move the time Remaining to the eax 
call WriteInt                           ;//write the value of eax to the screen
call Crlf                               ;//print a new line to the screen

;//Get user input
mWrite "Please Enter a Name: "          ;//print name prompt to the screen
mov ecx, BUFFER_SIZE                    ;//get the buffer size
mov edx, OFFSET fileBuffer              ;//move the address of fileBuffer to edx
call ReadString                         ;//get input from keyboard
mov stringLength, eax                   ;//move the length of that input to stringLength

;// open score file for writing 
;// Note:(Nathan) : Had to do it this way as existing library doesn't allow for appending of file
INVOKE CreateFile, ADDR scoreFileName, GENERIC_WRITE, DO_NOT_SHARE, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0

mov scoreSaveFileHandle, eax            ;//move the file handle to scoreSaveFileHandle

;//check if the file was opened successfully
.IF(eax == INVALID_HANDLE_VALUE)
call Crlf
mWrite "ERROR: cannot open scores.dat file"
call Crlf
call WaitMsg
jmp Quit                                ;//exit the save function
.ENDIF

;//move the file pointer to the end of the file
invoke SetFilePointer, scoreSaveFileHandle, 0, 0, FILE_END

push stringLength                       ;//save the value of stringLength for use later because its going to be overwritten

;//Write New Line Chars so that each entry is on it's own line
INVOKE WriteFile, scoreSaveFileHandle, addr stringNewLine, lengthof stringNewLine, addr stringLength, 0

pop stringLength;//restore the value of stringLength

;//write user input into file
INVOKE WriteFile, scoreSaveFileHandle, addr fileBuffer, stringLength, addr stringLength, 0

;//write score to file
;//clean the registers
xor eax, eax
xor edx, edx

mov eax, score                          ;//move the value of score to eax
call IntToString                        ;//convert the value in eax to a string

INVOKE Str_length, edx                  ;//get the length of the string

;//write the value of edx (score) to the file 
INVOKE WriteFile, scoreSaveFileHandle, edx, eax, addr stringLength, 0

;//Write TimeRemaining to string
;//clean the registers
xor eax, eax
xor edx, edx

mov eax, timeRemaining                  ;//move the value of timeRemaining to eax
call IntToString                        ;//convert the value of eax to a string

INVOKE Str_length, edx                  ;//get the length of the screen

;//write the value of edx (time remaining) to the file
INVOKE WriteFile, sCoreSaveFileHandle, edx, eax, addr stringLength, 0

;//close the file
INVOKE CloseHandle, scoreSaveFileHandle

mov cursorInfo.bVisible, FALSE          ;//set the cursor invisible 

;//write the cursor info struct the the console
INVOKE SetConsoleCursorInfo, consoleHandle, addr cursorInfo

Quit:
ret
SaveScore ENDP

;//------------------------------------------------------------------------------
IntToString PROC USES eax ecx edi ebx
;//
;// Description: Turns a Integer into a string
;// Uses: eax, ecx, edi, ebx
;// Receives: A integer in EAX
;// Returns: a string in EDX
;// Remarks: Large portions of this code came from the Irvine32 Library - WriteInt
;//         All comments are the original comments from the source code
;//------------------------------------------------------------------------------
WI_Bufsize = 12
true = 1
false = 0
.data
buffer_B  BYTE  WI_Bufsize DUP(0), 0    ;// buffer to hold digits
neg_flag  BYTE ?

.code

mov   neg_flag, false                   ;//assume neg_flag is false
or    eax, eax                          ;//is AX positive ?
jns   WIS1                              ;//yes: jump to B1
neg   eax                               ;//no: make it positive
mov   neg_flag, true                    ;//set neg_flag to true

WIS1:
mov   ecx, 0                            ;// digit count = 0
mov   edi, OFFSET buffer_B
add   edi, (WI_Bufsize - 1)
mov   ebx, 10                           ;// will divide by 10

WIS2:
mov   edx, 0                            ;// set dividend to 0
div   ebx                               ;// divide AX by 10
or    dl, 30h                           ;// convert remainder to ASCII
dec   edi                               ;// reverse through the buffer
mov[edi], dl                            ;// store ASCII digit
inc   ecx                               ;// increment digit count
or    eax, eax                          ;// quotient > 0 ?
jnz   WIS2                              ;// yes: divide again

;// Insert the sign.

dec   edi                               ;// back up in the buffer
inc   ecx                               ;// increment counter
mov   BYTE PTR[edi], ' '                ;// insert a space because I wanted to (nathan)
cmp   neg_flag, false                   ;// was the number positive ?
jz    WIS3;// yes
mov   BYTE PTR[edi], ' '                ;// no: insert a space because I wanted to (nathan)

WIS3:
mov  edx, edi
ret
IntToString ENDP

       ;//------------------------------------------------------------------------------
GenerateRandomPoint PROC USES eax edx
;//
;// Description: generate a random point
;// Uses: eax, edx, ecx
;// Receives: Nothing
;// Returns: Nothing
;// Remarks: this might end up as a macro for easer calling.
;//------------------------------------------------------------------------------
;//clean registers
xor eax, eax
xor edx, edx

;//gen X-axis
movzx eax, mapWidth                     ;//set the max number that can be return by RandomRange to the Map width
call RandomRange                        ;//return a number between 0 and eax-1
movzx dx, al                            ;//move the value returned by RandomRange to the dx register
mov MarkerPOS.X, dx                     ;//move the value of the dx register to the x position

;//gen y-Axis
;//clean registers
xor eax, eax
xor edx, edx

movzx eax, mapHeight                    ;//set the max number that can be return by RandomRange to the Map width
call RandomRange                        ;//return a number between 0 and eax-1
movzx dx, al                            ;//move the value returned by RandomRange to the dx register
mov MarkerPOS.y, dx                     ;//move the value of the dx register to the x position

ret
GenerateRandomPoint ENDP

;//------------------------------------------------------------------------------
GenerateScorePickups PROC USES eax edx ecx
;//
;// Description: will randomly place score pickups on the map
;// Uses: Nothing
;// Receives: Nothing
;// Returns: Nothing
;// Remarks: this might end up as a macro for easer calling.
;//------------------------------------------------------------------------------

.data
numHighPoints dword 6
numLowPoints dword 6

highPointChar byte 157
lowPointChar byte 234

.code
call Randomize              ;//init the randomizer
GenHighPoint:
xor ecx, ecx                ;//clean the ecx register
mov ecx, numHighPoints      ;//set the ecx (loop counter) to the number of high point chars to generate

;//Gen high point pickups
L1:
RetryX :
call GenerateRandomPoint    ;//get a random point

xor ebx, ebx                ;//clean the ebx register

;//get the value in the levelBuffer at the FuturePOS
invoke GetValueFromMatrix, addr levelBuffer, MarkerPOS, mapHeight, mapWidth

.IF(ebx == 32);
;//set the car at the generated position to ascii ùto 157
invoke SetValueToMatrix, addr levelBuffer, MarkerPOS, mapHeight, mapWidth, 157

push ecx                    ;//save the ecx register because SetConsoleCursorPosition messes with it

;//move the cursor to the position specified in CurrentPOS
INVOKE SetConsoleCursorPosition, consoleHandle, MarkerPOS

mov al, highPointChar       ;//move a empty space to the al register
call WriteChar              ;//write a blank char so to erase the previous player marker

pop ecx                     ;//restore the ecx register
loop L1
jmp GenerateLowPoint
.ENDIF

jmp RetryX

GenerateLowPoint :
xor ecx, ecx                ;//clean the ecx register
mov ecx, numLowPoints       ;//set the ecx (loop counter) to the number of low point chars to generate

;//Gen high point pickups
L2:
RetryY :
call GenerateRandomPoint    ;//get a random point

xor ebx, ebx                ;//clean the ebx register

;//get the value in the levelBuffer at the FuturePOS
invoke GetValueFromMatrix, addr levelBuffer, MarkerPOS, mapHeight, mapWidth

.IF(ebx == 32);
;//set the car at the generated position to ascii ùto 234
invoke SetValueToMatrix, addr levelBuffer, MarkerPOS, mapHeight, mapWidth, 234
push ecx                    ;//save the ecx register because SetConsoleCursorPosition messes with it

;//move the cursor to the position specified in CurrentPOS
INVOKE SetConsoleCursorPosition, consoleHandle, MarkerPOS
mov al, lowPointChar        ;//move a empty space to the al register
call WriteChar              ;//write a blank char so to erase the previous player marker

pop ecx                     ;//restore the ecx register
loop L2
jmp Quit
.ENDIF

jmp RetryY

Quit :
ret
GenerateScorePickups ENDP

;//------------------------------------------------------------------------------
UpdatePlayerLocation PROC USES eax
;// Uses: al
;// Description: Don't Know May Not Be Used;
;// Receives: the player current and future locations in global variables
;// Returns: nothing
;//------------------------------------------------------------------------------
.data
.code
xor eax, eax

;//Draw Player
INVOKE SetConsoleCursorPosition, consoleHandle, CurrentPOS  ;//move the cursor to the position specified in CurrentPOS
mov al, " "                                                 ;//move a empty space to the al register
call WriteChar                                              ;//write a blank char so to erase the previous player marker

mCopyCOORD CurrentPOS, FuturePOS                            ;//copy the futurePOS to the currentPOS

INVOKE SetConsoleCursorPosition, consoleHandle, CurrentPOS  ;//move the cursor to the position specified in CurrentPOS
mov al, 0DBh                                                ;//move the weird box thing to the al register
mov al, 0DBh                                                ;//move the weird box thing to the al register
call WriteChar                                              ;//draw the player char

ret
UpdatePlayerLocation ENDP

end main