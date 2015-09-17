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
BUFFER_SIZE = 5000

.data
mapWidth BYTE ?
mapHeight BYTE ?

;//THis will end up being a COOR Struct but for testing
playerX BYTE ?
playerY BYTE ?
.code

;//------------------------------------------------------------------------------
main proc
;//
;// Description: Main Application Entry Point
;// Receives: Nothing
;// Returns: Nothing
;//------------------------------------------------------------------------------

;/*TODO(Nathan) Task List in order of operations for Game Start
; *1. Clear Screen
; *2. Draw Main Menu
; *3. User Selections - Start Game, Options, Score List, Exit
; *4. Options Screen: If user selects Options -> Draw the Options
; *5. Score List: If user selects Score List -> Draw the Score List
; *6. Start Game: if user selects Start Game -> start the MainGameLoop;
; *7. Exit: If use selects Exit -> quit the application
; */

MainScreen:
call MenuScreen

cmp ax, 1
jz StartGame
cmp ax, 2
jz ShowOptions
cmp ax, 3
jz ShowScore
cmp ax, 4
jz ExitProgram

jmp MainScreen

StartGame:
call PrintMaze
call MainGameLoop

jmp MainScreen

ShowScore:
call ScoreScreen

jmp MainScreen

ShowOptions:
call OptionsScreen

jmp MainScreen

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
buffer Byte BUFFER_SIZE DUP(? )
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
MainGameLoop PROC
;//
;// Description: The Main Game Loop
;// Uses: 
;// Receives:
;// Returns: Nothing
;//------------------------------------------------------------------------------
.data
.code
call WaitMsg

;//TODO(nathan): 
;// Update Clock
;// get user input
;// move player
;// check if at exit
;// update score

ret
MainGameLoop ENDP

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
UpdateGameInformation PROC
;//
;// Description: Don't Know May Not Be Used;
;// Receives: Nothing
;// Returns: Nothing
;//------------------------------------------------------------------------------
.data
.code
;/*TODO(Nathan) Task List in order of operations for Update Game Information
 ; *1. Draw Time, Score, Player and Items onto Maze
 ; */
ret
UpdateGameInformation ENDP

end main