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

;//Map data
mapWidth BYTE 23
mapHeight BYTE 20
consoleHandle DWORD ?
cursorInfo CONSOLE_CURSOR_INFO <>
buffer Byte BUFFER_SIZE DUP(? )

;//Player data - x, y
ALIGN WORD
FuturePOS COORD <0,1>
ALIGN WORD
CurrentPOS COORD <0,1>
ALIGN WORD
ScorePOS COORD <0,0>
ALIGN WORD 
TimerPOS COORD <0,0>


;//game info
msgTiming byte "Time Remaining: ", 0
timeStart DWORD 0
timePrev DWORD 0
timeElapsed DWORD 0

maxTime DWORD 0


msgScore byte "Score: ", 0
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
push ax

xor ax, ax
mov ax, (coord ptr sourceCOORD).X
mov(coord ptr destCOORD).X, ax

xor ax, ax
mov ax, (coord ptr sourceCOORD).Y
mov(coord ptr destCOORD).Y, ax

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

INVOKE SetConsoleCursorPosition, consoleHandle, coords
mWrite "                                             ", 0;//shady hack that should be fixed.
INVOKE SetConsoleCursorPosition, consoleHandle, coords

call GetTextColor
mov currentTextColor, eax

mov eax, color
call SetTextColor

mov edx, offset message
call WriteString

IFNB < optionalIntValue >
xor eax,eax
mov eax, optionalIntValue
call WriteInt
ENDIF

mov eax, currentTextColor
call SetTextColor

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
INVOKE GetStdHandle, STD_OUTPUT_HANDLE
mov consoleHandle, eax
INVOKE GetConsoleCursorInfo, consoleHandle, addr cursorInfo
mov cursorInfo.bVisible, FALSE
INVOKE SetConsoleCursorInfo, consoleHandle, addr cursorInfo

mov score, 0
xor ax, ax
movzx ax, mapWidth
add ax, 1
mov ScorePOS.X, ax
mov ScorePOS.Y, 2

mov TimerPOS.X, ax
mov TimerPOS.Y, 1

;//End Init

MainScreen:
xor eax,eax
call MenuScreen

cmp ax, 1
jz StartGame
cmp ax, 2
jz ShowScore
cmp ax, 3
jz ExitProgram

jmp MainScreen


StartGame:
call MainGameLoop
jmp MainScreen

ShowScore:
call ScoreScreen
jmp MainScreen

;//Clean up Before Exit
mov cursorInfo.bVisible, TRUE
INVOKE SetConsoleCursorInfo, consoleHandle, addr cursorInfo

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
GetValueFromMatrix PROC USES eax ecx edx, 
matrix: PTR BYTE, coords : COORD, nRows : byte, nCols : byte
    LOCAL baseAddress : BYTE
;//
;// Description: The Main Game Loop
;// Uses: eax, ecx, edx
;// Receives: a Pointer to COORDs, nRows and, NCols
;// Returns: the value in the array at the location specified in matrix using ebx
;//------------------------------------------------------------------------------
.data
bytesInRow dword ?
.code
xor eax, eax;//y || row
xor ecx, ecx;//x || col
xor ebx, ebx

movzx ecx, (coord ptr coords).X;//col
movzx eax, (coord ptr coords).Y;//row
mul nCols;//multiply eax by nCols

add ecx, eax
movzx ebx, [buffer + 1 * ecx]
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
;// TODO(Nathan): Need to default COORS for current and future player POS for each new game

call PrintMaze

;//Start Game Time
mov timeElapsed, 0
mov timeStart, 0
mov timePrev, 0
mov maxTime, 40
mov timeRemaining, 40
call GetMSeconds
mov timeStart, eax

;//Draw starting information on screen before entering game loop
mPrintAtLocation msgScore, ScorePOS, white, score
mPrintAtLocation msgTiming, TimerPOS, white

call UpdatePlayerLocation

GameLoop:
xor ebx, ebx
call GetPlayerInput

cmp ebx, 1
jz Win

call UpdateTimer
cmp timeRemaining, 0
jz GameOver

jmp GameLoop

GameOver :
call Clrscr
mWrite "Game Over, you ran out of time", 13, 10, 0
call Crlf
call WaitMsg
jmp quit

Win:
call Clrscr
mWrite "you win, we'll do things here later like saving scores", 13, 10, 0;//TODO(Nathan): implement saving of scores
call Crlf
call WaitMsg
jmp quit

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

mov eax, timeElapsed
mov timePrev, eax

call GetMSeconds
sub eax, timeStart
mov edx, 0
mov ebx, 1000
div ebx

mov timeElapsed, eax

mov ebx, maxTime

sub ebx, timeElapsed

mov timeRemaining, ebx

mPrintAtLocation msgtiming, TimerPOS, white, timeRemaining
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

;//Check if Move is valid
.IF(ebx != 0 && ebx != 13 && ebx != 12 && ebx != 43 && ebx != 45 && ebx != 124 && keyPress != 1)

call UpdatePlayerLocation

.IF(ebx == 126)
    mov ebx, 1
    jmp Quit
.ELSEIF(ebx == 42);// 157)
    add score, 15
.ELSEIF(ebx == 234)
    add score, 10
.ENDIF

mPrintAtLocation msgScore, ScorePOS, white, score

.ElSE
mCopyCOORD FuturePOS, CurrentPOS

.ENDIF

mov ebx, 0

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
msgMenu byte "1: Play", 13, 10, "2: Scores", 13, 10, "3: Exit", 13, 10, 0

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
 ; *4. Print Options for Return to Main Screen
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

ret
SaveScore ENDP

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