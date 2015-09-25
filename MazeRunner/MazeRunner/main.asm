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
mapWidth BYTE 23
mapHeight BYTE 20
consoleHandle DWORD ?
cursorInfo CONSOLE_CURSOR_INFO <>

buffer Byte BUFFER_SIZE DUP(?)

spaceChar byte ?

ALIGN WORD
FuturePOS COORD <0,1>
CurrentPOS COORD <0,0>

.code

;//------------------------------------------------------------------------------
main proc
;//
;// Description: Main Application Entry Point
;// Receives: Nothing
;// Returns: Nothing
;//------------------------------------------------------------------------------

;//Init
INVOKE GetStdHandle, STD_OUTPUT_HANDLE
mov consoleHandle, eax
INVOKE GetConsoleCursorInfo, consoleHandle, addr cursorInfo
mov cursorInfo.bVisible, FALSE
INVOKE SetConsoleCursorInfo, consoleHandle, addr cursorInfo
;//End Init

;//MainScreen:
;//call MenuScreen
;//
;//cmp ax, 1
;//jz StartGame
;//cmp ax, 2
;//jz ShowOptions
;//cmp ax, 3
;//jz ShowScore
;//cmp ax, 4
;//jz ExitProgram
;//
;//jmp MainScreen
;//
;//StartGame:
;// TODO(Nathan): Need to default COORS for current and future player POS for each new game
call PrintMaze
; call MainGameLoop
;//
;//jmp MainScreen
;//
;//ShowScore:
;//call ScoreScreen
;//
;//jmp MainScreen
;//
;//ShowOptions:
;//call OptionsScreen
;//
;// jmp MainScreen

 invoke GetValueFromMatrix, addr buffer, FuturePOS, mapHeight, mapWidth

;//GameOver:
;//jmp ExitProgram

;//Clean up Before Exit
;// mov cursorInfo.bVisible, TRUE
;// INVOKE SetConsoleCursorInfo, consoleHandle, addr cursorInfo
ExitProgram:
invoke ExitProcess, 0
main endp

;//Procedures
;//------------------------------------------------------------------------------
PrintMaze PROC USES edx ecx eax ebx
;//
;// Description: Reads the Map from a file into a buffer array and prints it to the screen
;// Uses: edx, ecx, eax, and ebx
;// Receives: Nothing
;// Returns: array stored in buffer
;//------------------------------------------------------------------------------

.data
fileName byte "level.dat", 0
fileHandle HANDLE ?
.code
call Clrscr
mov edx, OFFSET fileName
call OpenInputFile
mov fileHandle, eax

mov edx, OFFSET buffer
mov ecx, BUFFER_SIZE
call ReadFromFile

;//clean registers
mov ecx, 0
mov eax, 0
mov ebx, 0

mov edx, OFFSET buffer
mov ecx, SIZEOF buffer

;//Setup map size and player location
call WriteString
call Crlf

mov eax, fileHandle
call CloseFile

ret
PrintMaze ENDP

;//------------------------------------------------------------------------------
GenerateScorePickups PROC
;//
;// Description: will randomly place score pickups on the map
;// Uses: Nothing
;// Receives: Nothing
;// Returns: Nothing
;// Remarks: this might end up as a macro for easer calling.
;//------------------------------------------------------------------------------

ret
GenerateScorePickups ENDP

;//------------------------------------------------------------------------------
GetValueFromMatrix PROC USES eax ebx ecx edx, 
matrix: PTR BYTE, coords : COORD, nRows : byte, nCols : byte
    LOCAL baseAddress : BYTE
;//
;// Description: The Main Game Loop
;// Uses: 
;// Receives:
;// Returns: Nothing
;//------------------------------------------------------------------------------
.data
bytesInRow dword ?
.code
xor eax, eax;//y || row
xor ecx, ecx;//x || cols
xor ebx, ebx

movzx eax, (coord ptr coords).Y;//row

mul nCols


movzx ecx,  (coord ptr coords).X ;//col

;//calc row offset
;// row = cols * y

;// so index = (cols * y) + x

add eax, ecx

movzx esi, [buffer + eax]



ret
GetValueFromMatrix ENDP

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
GameLoop:

call UpdateGameInformation
call GetPlayerInput


 jmp GameLoop

;//TODO(nathan): 
;// Update Clock
;// get user input
;// move player
;// check if at exit
;// update score

ret
MainGameLoop ENDP


GetPlayerInput PROC USES eax
LOCAL keyPress : BYTE
.data

.code
mov keyPress, 0

xor eax, eax
mov eax, 10
call Delay
call ReadKey

mov keyPress, al

.IF(keyPress == "s")
add FuturePOS.Y, 1
.ELSEIF(keyPress == "w")
sub FuturePOS.Y, 1
.ELSEIF(keyPress == "d")
add FuturePOS.X, 1
.ELSEIF(keyPress == "a")
sub FuturePOS.X, 1
.ENDIF




ret
GetPlayerInput ENDP

;//------------------------------------------------------------------------------
MenuScreen PROC USES eax edx
;//
;// Description: Prints the Main Menu and Reads user input
;// Uses: eax and edx
;// Receives: Nothing
;// Returns: player menu choice stored in AX
;//------------------------------------------------------------------------------
.data
msgMenu byte "1: Play", 13, 10, "2: Options", 13, 10, "3: Scores", 13, 10, "4: Exit", 13, 10, 0

.code
xor eax, eax
xor edx, edx

call Clrscr

mov edx, OFFSET msgMenu
call WriteString
call Crlf
call readInt

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
xor eax, eax
xor edx, edx

call Clrscr

mov edx, OFFSET msgScoreTitle
call WriteString

call WaitMsg
;/*TODO(Nathan) Task List in order of operations for Score Screen
 ; *1. Clear Screen
 ; *2. Read Score File
 ; *3. Print Scores onto Screen
 ; *4. Print Options for Return to Main Screen, Clear Score List
 ; *Notes: Read Player Input here?.
 ; */
ret
ScoreScreen ENDP

;//------------------------------------------------------------------------------
SaveScore PROC;
;//
;// Description: Saves the Score and Completion Time to a file 
;// Uses:
;// Receives: name, score and, time remaining
;// Returns: Nothing
;//------------------------------------------------------------------------------
.data
.code
;/*TODO(Nathan) Task List in order of operations for SaveScore
 ; *1. Clear Screen
 ; *2. Save Score to File
 ; */
ret
SaveScore ENDP

;//------------------------------------------------------------------------------
OptionsScreen PROC USES eax edx;
;//
;// Description: Displays the Options and Reads Input from the User 
;//              and Updates global flags
;// Uses: eax and edx
;// Returns: Nothing
;// Remarks: this option is on the cutting block; will be first to go if out of time
;//------------------------------------------------------------------------------
.data
msgOptions byte "Options", 0

.code
xor eax, eax
xor edx, edx

call Clrscr

mov edx, OFFSET msgOptions
call WriteString

call WaitMsg

;/*TODO(Nathan) Task List in order of operations for Options
 ; *1. Clear Screen
 ; *2. Enable Timer
 ; */
ret
OptionsScreen ENDP

;//------------------------------------------------------------------------------
UpdateGameInformation PROC uses al
;// Uses: al
;// Description: Don't Know May Not Be Used;
;// Receives: the player current and future locations in global variables
;// Returns: nothing
;//------------------------------------------------------------------------------
.data
playerChar byte " ", 0
len byte 1
.code

xor eax, eax

;//Draw Player
INVOKE SetConsoleCursorPosition, consoleHandle, CurrentPOS
mov al, " "
call WriteChar

xor ax, ax
mov ax, FuturePOS.X
mov CurrentPOS.X, ax

xor ax, ax
mov ax, FuturePOS.Y
mov CurrentPOS.Y, ax

INVOKE SetConsoleCursorPosition, consoleHandle, CurrentPOS
mov al, 0DBh;// offset playerChar
call WriteChar

;// call ReadConsoleOutputCharacter, consoleHandle, addr spaceChar, len * 2, addr FuturePOS, len





;/*TODO(Nathan) Task List in order of operations for Update Game Information
 ; *1. Draw Time, Score, Player and Items onto Maze
 ; */
ret
UpdateGameInformation ENDP

end main