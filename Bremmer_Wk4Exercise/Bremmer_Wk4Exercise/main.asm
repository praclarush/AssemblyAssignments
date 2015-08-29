;/* ---------------------------------------------------------------------------
 ;**
 ;** File: main.asm
 ;** Description: Wk4Exercise
 ;** Assignment:
 ;** Problem 1
 ;** The file myInputFile.txt is an encrypted file. Your assignment is to decrypt this file and hopefully answer the question for bonus points. Do the following in your code.
 ;**    a.	Open the file “InputFile.txt”, read the contents.
 ;**        Hint: if your file open handle does not work, check that you have the InputFile.txt file in the project directory and not the debug directory.
 ;**    b.	XOR each byte of the file with 0ffh. (Please refer to the note on XOR operation below)
 ;**    c.	Print the contents of the file decoded string to the console window
 ;**    d.	Print the output to a file “OutputFile.txt”
 ;**    e.	Use a comment in your asm file to answer the bonus question.
 ;** Problem 2
 ;**  Create 32 random points which have (x, y) co-ordinates. The co-ordinates are constrained to be in the following range:
 ;**        (-15<= x <= 14) and (-15<=y <=14)
 ;**        (Hint – generate a random # between 0 and 29 then subtract 15 from this).
 ;**    a.	Plot the co-ordinate in the console screen with a different color if it lies in the following quadrants:
 ;**        Quadrant 1 points gets a yellow *
 ;**        Quadrant 2 points gets a cyan *
 ;**        Quadrant 3 points gets a red *
 ;**        Quadrant 4 points gets a green *
 ;**
 ;**    b.	Draw the x and y axis too
 ;**
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
;//Question 1 Variables
buffer BYTE BUFFER_SIZE DUP(? )
fileName BYTE "inputfile.txt", 0
fileHandle HANDLE ?

;//Question 2 Variables
randVal DWORD ?
xAxis BYTE "-", 0
yAxis BYTE "|", 0
point BYTE "*", 0
consoleRow BYTE ?
consoleCols BYTE ?
centerX BYTE ?
centerY BYTE ?
xPoint BYTE ?
yPoint BYTE ?

.code
main proc
jmp Question_2;//DEBUG

;//Question  1
Question_1:
    mov edx, OFFSET fileName        ;//move the memory address of the file name to EDX
    call OpenInputFile              ;//Open the file for reading
    mov fileHandle, eax             ;//assign the fileHandle to the open file

    mov edx, OFFSET buffer          ;//Assign the buffer
    mov ecx, BUFFER_SIZE            ;//get the max buffer size
    call ReadFromFile               ;//Read the file into the buffer

    mov ecx, 0                      ;//zero ecx just to be save
    mov edx, OFFSET buffer          ;// make sure the buffer is in EDX
    mov ecx, SIZEOF buffer          ;// init the loop counter (ECX) with the length of the buffer
    mov esi, 0                      ;//zero esi which will be used as a indexer just to be safe

decode_string :
    xor buffer[esi], 0ffh           ;//xor the value at the current index of the buffer array with 0ffh
    inc esi                         ;//Increment the value of esi our Indexer
    loop decode_string              ;// loop though the buffer array

    mov buffer[eax], 0              ;//insert a null terminator for the write to the screen
    mov edx, OFFSET buffer          ;//make sure edx has the address for the buffer
    call WriteString                ;// write the contents of the buffer to the screen
    call Crlf

    mov eax, fileHandle             ;//move the fileHandle to eax for closing
    call CloseFile                  ;//Close the file and remove the read lock

    call WaitMsg                    ;//Wait for user input before moving to the next segment of the application


;//Question 2
Question_2:
call Clrscr

;//Prep Registers
mov al, 0
mov dl, 0
mov eax, 0
mov edx, 0
mov ebx, 0

;//Get Max X,Y of Console
mov ax, white
call SetTextColor

call GetMaxXY                       ;//Get the max size of the console
mov consoleRow, al                  ;//save the max rows (y)
mov consoleCols, dl                 ;//save the max columns (x)

;//Get Center of X Axis of Console
xor al, al                          ;//clean the al register
movzx ax, consoleRow                ;//store the height of the console for division 
mov bl, 2
div bl                              ;//divide the contents of the ax register by the contents of the bl register
mov centerX, al                     ;//save the center of the console columns as the center of the X axis (I THINK THESE ARE REVERSED)

;//Get Center of Y Axis of Console
xor al, al                          ;//clean the al register
movzx ax, consoleCols               ;//store the width of the console for division
mov bl, 2
div bl                              ;//divide the contents of the ax register by the contents of the bl register
mov centerY, al                     ;//save the center of the console columns as the center of the Y axis (I THINK THESE ARE REVERSED)

;//Prep Draw_X_Axis
movzx ecx, consoleCols              ;//move the width of the console into ecx register to use as a loop counter
mov al, xAxis                       ;//move the character ("-") for printing
mov dl, 0
mov dh, centerX                     ;//set the console curser at the center of the y axis to draw the x axis

Draw_X_Axis :
call Gotoxy                         ;//move the cursor to the location specified by dl,dh
call WriteChar                      ;//write the value of al ("-") onto the screen
inc dl                              ;//move the cursor over one
loop Draw_X_Axis

;//Prep Draw_Y_Axis
movzx ecx, consoleRow               ;//move the height of the console into the ecx register for use as a loop counter 
mov al, yAxis                       ;//move the character ("|") for printing
mov dl, centerY                     ;//set the console curser at the center of the x axis to draw the y axis
mov dh, 0

Draw_Y_Axis :
call Gotoxy                         ;//move the cursor to the location specified by dl,dh
call WriteChar                      ;//write the value of al ("|") onto the screen
inc dh                              ;//move the cursor over one
loop Draw_Y_Axis

mov ecx,32                          ;//Set Loop counter

call Randomize                      ;//init the randomizer

Generate_Point:
;//clean the registers for use
xor eax, eax
xor edx, edx
mov dh, 0
mov dl, 0
mov al, 0

;//get the x location for the point 
mov eax, 30                         ;//set the max number that can be returned by the randomRange
call RandomRange                    ;//return a number between 0 and eax-1 (29)
mov dh, al                          ;//move the lower fourth of the value returned in the eax register to the dh register for manipulation
sub dh, 15                          ;//subtract 15 from dh so that our range is between -15 and 14
add dh, centerX                     ;//add the length of the first half of the console's width so that everything is spaced properly
mov xPoint, dh                      ;//move the value of dh to xPoint for saving (this is due to needing to use those registers again)

;// clean the registers
mov edx, eax
xor eax, eax

;//get the y location for the point
mov eax, 30                         ;//set the max number that can be returned by the randomRange
call RandomRange                    ;//return a number between 0 and eax-1 (29)
mov dl, al                          ;// move the lower fourth of the value returned in the eax register to the dh register for manipulation
sub dl, 15                          ;//subtract 15 from dl so that our range is between -15 and 14
add dl, centerY                     ;//add the length of the first half of the console's height so that everything is spaced properly
mov yPoint, dl                      ;//move the value of the dl to the yPoint for saving (This is incase those registers are needed before we use them again)


xor ax, ax                          ;//Clean the ax register for coloring; this sets the color of the text to black
mov dl, yPoint                      ;//move the value of yPoint to dl for drawing 
mov dh, xPoint                      ;//move the value of xPoint to dh for drawing 

jmp Set_Color                       ;//Jump to the Set Color section to decide on what color the text should be
                                    ;// (note to self) : this jump is here because there a limit on how much can be between a jump(loop) and it's destination.

Draw_Point:
call GotoXY                         ;//set the cursor at the position specified by the dl,dh registers 
mov al, point                       ;//move the character ("*") that will be drawn into the al register 
call WriteChar                      ;//write the character that is in the al register to the console ("*")
    
loop Generate_Point

;//reset text color for wait prompt
mov ax, white
call SetTextColor

call WaitMsg
jmp quit

Set_Color:
;//*********************************************
;//* Set the color of the point before drawing *
;//*********************************************
;// Quadrant 1 points gets a yellow *
;// Quadrant 2 points gets a cyan *
;// Quadrant 3 points gets a red *
;// Quadrant 4 points gets a green *
.IF(dh > centerX) && (dl > centerY)
mov ax, green
.ELSEIF(dh > centerX) && (dl < centerY)
mov ax, red
.ELSEIF(dh < centerX) && (dl > centerY)
mov ax, cyan
.ELSEIF(dh < CenterX) && (dl < centerY)
mov ax, yellow
.ELSE
mov ax, white
.ENDIF

call SetTextColor                   ;//Set the color of the text to what is in the ax register
jmp Draw_Point


quit :
    invoke ExitProcess, 0           ;//Exit the application
 main endp
 end main
