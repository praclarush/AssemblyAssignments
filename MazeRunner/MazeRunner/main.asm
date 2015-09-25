;/* ---------------------------------------------------------------------------
;**
;** File: main.asm
;** Description: Assembly Template
;** Author: Nathan Bremmer
;** -------------------------------------------------------------------------*/
INCLUDE Irvine32.inc
INCLUDE macros.inc


.386
.model flat, stdcall
.stack 4096

ExitProcess proto, dwExitCode:dword
GetValueFromMatrix proto matrix : PTR BYTE, cords : COORD, nRows : byte, nCols : byte


BUFFER_SIZE = 5000

.data

;//Map data
mapWidth BYTE 23
mapHeight BYTE 20
consoleHandle DWORD ?
cursorInfo CONSOLE_CURSOR_INFO <>
buffer Byte BUFFER_SIZE DUP(? )

;//Player data
ALIGN WORD
FuturePOS COORD <0,1> ;//x, y
ALIGN WORD
CurrentPOS COORD <0,1>
ALIGN WORD
ScorePOS COORD <>


;//game info
score dword 0
.code

;//------------------------------------------------------------------------------
mCopyCOORD MACRO destCOORD:req, sourceCOORD:req
;//
;// Description: Copies the values of one COORD struct to another
;// Avoid Using ax
;// Receives: a destination coord and a source coord struct; 
;// Returns: Nothing
;//------------------------------------------------------------------------------

xor ax, ax
mov ax, (coord ptr sourceCOORD).X
mov(coord ptr destCOORD).X, ax

xor ax, ax
mov ax, (coord ptr sourceCOORD).Y
mov(coord ptr destCOORD).Y, ax

ENDM

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

mov score, 0

;//mov ScorePOS.Y, 10
;//xor ax, ax
;//
;//mov ScorePOS.x, mapWidth

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
call PrintMaze
call UpdatePlayerLocation
call MainGameLoop
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

;//Clean up Before Exit
mov cursorInfo.bVisible, TRUE
INVOKE SetConsoleCursorInfo, consoleHandle, addr cursorInfo

ExitProgram:
invoke ExitProcess, 0
main endp

;//Procedures
;//------------------------------------------------------------------------------
PrintMaze PROC
;//
;// Description: Reads the Map from a file and prints it to the screen
;// Receives: Nothing
;// Returns: Nothing
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
GetValueFromMatrix PROC USES eax ecx edx, 
matrix: PTR BYTE, coords : COORD, nRows : byte, nCols : byte    
;//
;// Description: The Main Game Loop
;// Uses: 
;// Receives:
;// Returns: the value in the array at the location specified in matrix using ebx
;// Notes: calc row offset
;//        row = cols * y
;//        so index = (cols * y) + x
;//------------------------------------------------------------------------------
.data
bytesInRow dword ?
.code
xor eax, eax;//y || row
xor ecx, ecx;//x || cols
xor ebx, ebx

movzx ecx, (coord ptr coords).X;//col
movzx eax, (coord ptr coords).Y;//row
mul nCols;//multiply eax by nCols

add ecx, eax
movzx ebx, [buffer + 1 * ecx]
ret
GetValueFromMatrix ENDP

;//------------------------------------------------------------------------------
MainGameLoop PROC
;//
;// Description: The Main Game Loop
;// Uses: 
;// Receives:
;// Returns: Nothing
;//------------------------------------------------------------------------------
.data

.code
GameLoop:

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
inc FuturePOS.Y
.ELSEIF(keyPress == "w")
dec FuturePOS.Y
.ELSEIF(keyPress == "d")
inc FuturePOS.X
.ELSEIF(keyPress == "a")
dec FuturePOS.X
.ENDIF

xor ebx, ebx
invoke GetValueFromMatrix, addr buffer, FuturePOS, mapHeight, mapWidth
;// check if move is valid

.IF(ebx != 0 && ebx != 13 && ebx != 12 && ebx != 43 && ebx != 45 && ebx != 124 && keyPress != 1)

call UpdatePlayerLocation

.IF(ebx == 126)
;//Game Over with Exit
.ELSEIF(ebx == 42);// 157)
add score, 15
.ELSEIF(ebx == 234)
add score, 10
.ENDIF

.ElSE
mCopyCOORD FuturePOS, CurrentPOS

.ENDIF

ret
GetPlayerInput ENDP

;//------------------------------------------------------------------------------
MenuScreen PROC;
;//
;// Description: Prints the Main Menu and Reads user input
;// Uses: 
;// Receives: Nothing
;// Returns: AX
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
ScoreScreen PROC
;//
;// Description: Reads and Displays the Scores from a File
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
;// Receives: Nothing
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
OptionsScreen PROC;
;//
;// Description: Displays the Options and Reads Input from the User 
;//              and Updates global flags
;// Receives: Nothing
;// Returns: Nothing
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
UpdateScoreOnScreen proc
 
;//
;// Description:
;// Uses:
;// Receives:
;// Returns:
;//------------------------------------------------------------------------------


ret
UpdateScoreOnScreen endp

;//------------------------------------------------------------------------------
UpdatePlayerLocation PROC
;//
;// Description: Don't Know May Not Be Used;
;// Receives: Nothing
;// Returns: Nothing
;//------------------------------------------------------------------------------
.data
.code
xor eax, eax

;//Draw Player
INVOKE SetConsoleCursorPosition, consoleHandle, CurrentPOS
mov al, " "
call WriteChar

mCopyCOORD CurrentPOS, FuturePOS

INVOKE SetConsoleCursorPosition, consoleHandle, CurrentPOS
mov al, 0DBh;//player char box thing
call WriteChar

ret
UpdatePlayerLocation ENDP

end main