
;/* ---------------------------------------------------------------------------
;**
;** File: main.asm
;** Description: Week 7 Assignment
;** Assignment:
;** Problem 1
;** Write a procedure to implement the C/C++ string compare procedure: strnicmp()
;** It should have the interface:
;** INVOKE Strnicmp, strA, strB, nBytes
;** Constrain the length N to a maximum of 20 characters.  Use the following test cases
;**
;**     1.	compare string MASM and MASM
;**     2.	compare string MASS and MASM
;**     3.	compare string mASM and MASm
;** To show this procedure working, print out the result of the above 3 comparisons by printing the results to the console screen, 
;** e.g. “Test1, the strings are equal” or “Test1, strings are not equal”
;**
;** Problem 2
;** Write two matrix manipulation procedures and test the matrix identity. Assume the matrices are square 3x3.
;**     a.	Write a procedure to transpose a matrix A
;**     b.	Write a procedure to multiply 2 matrices. Y=AB
;**     c.	Test your two procedures by demonstrating that the following matrix identity holds true: (AB)T = BTAT
;**     Use for matrix A =  1  5  2  and B = 2  0  1
;**                         1  0  1          1  3  1
;**                         2  2  1          2  1  0
;**
;** Show that the identity is true by printing out the resultant matrix for left hand side and the right hand side, and showing that they are equal.
;**
;** Hint: Use one dimension arrays to store the matrices.
;**
;** Author: Nathan Bremmer
;** -------------------------------------------------------------------------*/


INCLUDE Irvine32.inc
INCLUDE macros.inc

ExitProcess proto, dwExitCode:dword
Strnicmp PROTO, strA : dword, strB : dword, nBytes : dword
MutiplyMatrixs PROTO, mtxA : dword, mtxB : dword, nRows : dword, nCols : dword

.data
;//problem 1 variables
strWord1 byte "MASM", 0
strWord2 byte "MASS", 0
strWord3 byte "mASM", 0
strWord4 byte "MASm", 0
nLength dword 0

;//problem 2 variable
matrixA dword 1h, 5h, 2h
RowSizeA = ($ - matrixA)
        dword 1h, 0h, 1h
        dword 2h, 2h, 1h

matrixB dword 2h, 0h, 1h
RowSizeB = ($ - matrixB)
        dword 1h, 3h, 1h
        dword 2h, 1h, 0h

matrixC word 9 dup(0)
msgProduct byte "The product of Matrix A and Matrix B is: ", 13, 10, 0

.code

;//------------------------------------------------------------------------------
main proc
;//
;// Description: Main Application Entry Point
;// Uses: none
;// Receives: none
;// Returns: none
;//------------------------------------------------------------------------------

;//Problem 1
Question1:
invoke Str_length, addr strWord1
mov nLength, eax
invoke Strnicmp, addr strWord1, addr strWord1, nLength
invoke Strnicmp, addr strWord1, addr strWord2, nLength
invoke Strnicmp, addr strWord3, addr strWord4, nLength
call WaitMsg

call Crlf

;//Problem 2
Question2:
xor edx, edx
mov edx, offset msgProduct
call WriteString

invoke MutiplyMatrixs, addr matrixA, addr matrixB, 3, 3
call WaitMsg

invoke ExitProcess, 0
main endp

;//------------------------------------------------------------------------------
MutiplyMatrixs proc, mtxA:dword, mtxB:dword, nRows : dword, nCols : dword
;//
;// Description: Multiples two matrixes
;// Uses:
;// Receives:the addresses to Matrix A and Matrix B, the number of columns and rows
;// Returns:Nothing
;//------------------------------------------------------------------------------
.data
space byte ' ', 0
workingRow dword 0
workingCol dword 0
rowCounter dword 0
colCounter dword 0
colSize dword 0
rowSize dword 0
counter dword 0
sum dword 0

.code
;//reset variables for call
mov workingRow, 0
mov workingCol, 0
mov rowCounter, 0
mov colCounter, 0
mov colSize, 0
mov rowSize, 0
mov counter, 0
mov sum, 0

;//calc memory places for columns
xor eax, eax                    ;//clean register
xor ebx, ebx                    ;//clean register
mov eax, 3                      ;//set the value of eax to 3
mov ebx, nCols                  ;//mov the value of nCols to ebx
mul ebx                         ;//multiply the value of ebx by eax
mov colSize, eax                ;//set the product in eax to colSize

;//calc memory places for rows
xor eax, eax                    ;//clean register
xor ebx, ebx                    ;//clean register
mov eax, 8                      ;//set the value of eax to 8
mov ebx, nRows                  ;//mov the value of nCols to ebx
mul ebx                         ;//multiply the value of ebx by eax
mov rowSize, eax                ;//set the product in eax to colSize

NextRow:
mov workingCol, 0               ;//set the working column to the first column of the row

NextCol :
mov eax, workingRow             ;//move the value of workingRow into the eax register
mov ebx, workingCol             ;//move the value of the workingCol into the ebx register
mov rowCounter, eax             ;//set the rowCounter to the value of the eax register
mov colCounter, ebx             ;//set the colCounter to thevalue of the ebx revister
mov counter, 0                  ;//zero the counter for new operations
mov sum, 0                      ;//zero the sum for new operations

Next:
;//multiply
mov esi, mtxA                   ;//move MtxA to the esi register
add esi, rowCounter             ;//mov the pointer in memory by the amount in rowCounter
mov eax, [esi]                  ;//move the value at the pointer location to the eax register
mov esi, mtxB                   ;//move MtxB to the esi register
add esi, colCounter             ;//mov the point in memory by the amount in the colCounter
mov ebx, [esi]                  ;//mov the value at the pointer location to the ebx register
mul ebx                         ;//multiply the ebx register by the eax register

;//Add 
add sum, eax                    ;//add the value of eax to the value stored in sum
add rowCounter, 4               ;//move the rowCounter forward 4 bytes
add colCounter, 12              ;//move the colCounter forward 12 bytes
inc counter                     ;//increment the counter
cmp counter, 2                  ;//compare the counter to the value 2
jle Next                        ;//jump if the value in counter is less then or equal to 2 this is because we only want to do this operation 3 times note(This is bad, should fix this)

printValue :
mov eax, sum                    ;//move the value of sum into eax for printing to the screen
call WriteDec                   ;//write the value of eax to the screen
mov edx, offset space           ;//set edx eqaul to the offset of space
call WriteString                ;//write the value of edx to the screen

add workingCol, 4               ;//increase the value of workingCol by 4
mov eax, workingCol             ;//move the value of working col to eax
cmp eax, colSize                ;//compare the value of eax to colSize
jle NextCol                     ;//jump if the value of eax is less then or equal to colSize
call Crlf                       ;//print a new line

add workingRow, 12              ;//increase the value of workingRow by 12
mov eax, workingRow             ;//move the value of workingRow to eax
cmp eax, rowSize                ;//compare the value of eax to rowSize
jle NextRow                     ;//jump if the value of eax is less then or equal to rowSize

call Crlf                       ;//write a new line after everything is done

ret
MutiplyMatrixs endp

;//------------------------------------------------------------------------------
TransposeMatrix proc, mtxA:word, mtxB : word
;//
;// Description:
;// Uses:
;// Receives:
;// Returns:
;//------------------------------------------------------------------------------


ret
TransposeMatrix endp

;//------------------------------------------------------------------------------
Strnicmp proc, strA:dword, strB:dword, nBytes:dword
;//
;// Description: Compares two strings writing to the screen if the strings 
;//              are equal or not equal or if the length is greater then 20
;// Uses: none
;// Receives: dword strA, dword strB, dword numBytes (length)
;// Returns: none
;//------------------------------------------------------------------------------

.data
msgEqual byte " are equal", 13, 10, 0
msgNotEqual byte " are not equal", 13, 10, 0
msgAnd byte " and ", 0
msgLengthError byte "the length of nBytes is greater then 20", 13, 10, 0

.code

;//clean registers for use
xor esi,esi
xor edi,edi
xor ecx, ecx

mov esi, strA                   ;//move the value of strA into esi
mov edi, strB                   ;//move the value of strB into edi
mov ecx, nBytes                 ;//move the value of nBytes into ecx

cmp ecx, 20                     ;//compare the value of ecx to 20(max length)
jz stringToLong                 ;//jump if zero


cld                             ;//Clear the direction flag in prep for looping through strings
repe cmpsd                      ;//compare each byte in esi and edi 
jz equal                        ;//jump if the two registers are equal
jnz notEqual                    ;//jump if the two registers are not equal

equal:
mov edx, strA                   ;//move the value of strA to edx
call WriteString                ;//write the value of edx to the screen
mov edx, OFFSET msgAnd          ;//move the offset to msgAnd to edx
call WriteString                ;//write the value of edx to the screen
mov edx, strB                   ;//write the value of strB to the screen
call WriteString                ;//write the value of edx to the screen
mov edx, OFFSET msgEqual        ;//move the offset of msgEqual to edx
call WriteString                ;//write the value of edx to the screen
jmp Return                      ;//jump to exit

notEqual:
mov edx, strA                   ;//move the value of strA to edx
call WriteString                ;//write the value of edx to the screen
mov edx, OFFSET msgAnd          ;//move the offset to msgAnd to edx
call WriteString                ;//write the value of edx to the screen
mov edx, strB                   ;//write the value of strB to the screen
call WriteString                ;//write the value of edx to the screen
mov edx, OFFSET msgNotEqual     ;//move the offset of msgEqual to edx
call WriteString                ;//write the value of edx to the screen
jmp Return;//jump to exit

stringToLong:
mov edx, OFFSET msgLengthError  ;//move the offset of msgLengthError to edx
call WriteString                ;//write the value of edx to the screen
jmp Return                      ;//jump to exit

Return:
 ret
Strnicmp endp
end main