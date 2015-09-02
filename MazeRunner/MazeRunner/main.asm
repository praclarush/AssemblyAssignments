;/* ---------------------------------------------------------------------------
;**
;** File: main.asm
;** Description: Assembly Template
;** Author: Nathan Bremmer
;** -------------------------------------------------------------------------*/

.386
.model flat, stdcall
.stack 4096
ExitProcess proto, dwExitCode:dword

.data

.code

;// Application Entry Point
main proc

;/*TODO(Nathan) Task List in order of operations for Game Start
; *1. Clear Screen
; *2. Draw Main Menu
; *3. User Selections - Start Game, Options, Score List, Exit
; *4. Options Screen: If user selects Options -> Draw the Options
; *5. Score List: If user selects Score List -> Draw the Score List
; *6. Start Game: if user selects Start Game -> start the MainGameLoop;
; *7. Exit: If use selects Exit -> quit the application
; */
invoke ExitProcess, 0
main endp

;//Procedures

MainGameLoop PROC
.data
.code
;/*TODO(Nathan) Task List in order of operations for Main Game Loop
 ; *1. Clear Screen
 ; *2. Set Player Name
 ; *3. Call PrintMaze -> Draw the Map onto the screen;
 ; *4. Call GetPlayerInput -> Get input from the player as to what to do; How to move; Timer needs to keep updating even while waiting for player input
 ; *5. Call UpdateGameInformation -> Updates the Score, Timer, Player, and Items
 ; *6. If game reaches defined End points return to caller
 ; */
ret
MainGameLoop ENDP

PrintMaze PROC;
.data
.code
ret
PrintMaze ENDP

GetPlayerInput PROC;//Reads the input from the player
.data
.code
;//TODO(Nathan): Don't have a clue
ret
GetPlayerInput ENDP

MenuScreen PROC;
.data
.code
;/*TODO(Nathan) Task List in order of operations for Menu Screen
 ; *1. Clear Screen
 ; *2. Print Menu Items; Play, Options, Score List, Exit
 ; *3. Update graphical indicator of Select; more then likely this (->)
 ; *Notes: Read Player Input here?
 ; */

ret
MenuScreen ENDP

ScoreScreen PROC;
.data
.code
;/*TODO(Nathan) Task List in order of operations for Score Screen
 ; *1. Clear Screen
 ; *2. Read Score File
 ; *3. Print Scores onto Screen
 ; *4. Print Options for Return to Main Screen, Clear Score List
 ; *Notes: Read Player Input here?.                                                                                                           
 ; */
ret
ScoreScreen ENDP

SaveScore PROC;
.data
.code
;/*TODO(Nathan) Task List in order of operations for SaveScore
 ; *1. Clear Screen
 ; *2. Save Score to File
 ; */
ret
SaveScore ENDP

OptionsScreen PROC;
.data
.code
;/*TODO(Nathan) Task List in order of operations for Options
 ; *1. Clear Screen
 ; *2. Enable Timer
 ; */
ret
OptionsScreen ENDP

UpdateGameInformation PROC
.data
.code
;/*TODO(Nathan) Task List in order of operations for Update Game Information
 ; *1. Draw Time, Score, Player and Items onto Maze
 ; */
ret
UpdateGameInformation ENDP

end main