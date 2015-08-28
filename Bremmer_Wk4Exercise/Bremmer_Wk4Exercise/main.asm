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

COORD STRUCT
X WORD ?
Y WORD ?
COORD ENDS


.data
;//Question 1 Variables
buffer BYTE BUFFER_SIZE DUP(? )
fileName BYTE "inputfile.txt", 0
fileHandle HANDLE ?

;//Question 2 Variables
randVal DWORD ?
AllPoints COORD 32 DUP(<0,0>)

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

mov	edi, 0
mov ecx, SIZEOF AllPoints
mov ax, 1


Fill_Coord_Array :

mov(COORD PTR AllPoints[edi]).X, ax
mov(COORD PTR AllPoints[edi]).Y, ax

    ;//FILL Y
    ; mov eax, 0
        ; mov eax, 29
        ; call RandomRange
        ; sub eax, 15
        ; mov al, eax
        ; mov(COORD PTR AllPoints[edi]).Y, ax


    call WaitMsg



quit :
invoke ExitProcess, 0
main endp
end main