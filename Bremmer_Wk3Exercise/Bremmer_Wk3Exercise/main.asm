
;/* ---------------------------------------------------------------------------
;**
;** File: main.asm
;** Description: Wk3Exercise
;** Assignment:
;**   *  Create an array of 5 numbers with the values of 1 5 10 15 20.
;**   *  Using LENGTHOF, Loop through the array and in each loop, do the following:
;**   *  Save the original value of the loop for output at the end
;**   *  Use INC
;**   *  Output the value
;**   *  Add 5 to the number
;**   *  Output the value
;**   *  Use DEC
;**   *  Output the value
;**   *  Subtract 10 from the number
;**     Check the carry, sign, and overflow flags and output the results
;**     For each element of the array, output the original value before any modifications were performed on it.
;**     Call WaitMsg
;**     End of loop
;**     For the all values in the array, use indirect  addressing
;**     Call the DumpRegs to display these values.
;** Author: Nathan Bremmer
;** -------------------------------------------------------------------------*/

.386

INCLUDE Irvine32.inc

.386
.model flat, stdcall
.stack 4096

ExitProcess proto, dwExitCode:dword

.data
arrayB DWORD 1h, 5h, 10h, 15h, 20h

.code
main proc
mov edi, OFFSET arrayB              ;//Get the address of the array
mov ecx, LENGTHOF arrayB            ;//Get the length of the array

L1:
    mov eax, 0                      ;//prep eax for use
    mov esi, 0                      ;//prep esi for use
    mov esi, [edi]                  ;//save the original array value for later
    mov eax, [edi]                  ;//move the value of the array into eax
    inc eax                         ;//increment the array value
    call DumpRegs
    add eax, 5h                     ;//add 5 to the number
    call DumpRegs
    dec eax                         ;//decrement the array value
    call DumpRegs
    sub eax, 10h                    ;//subtract 10 from the number
    call DumpRegs
    mov eax, esi                    ;//Move the original value into eax for viewing
    call DumpRegs
    add edi, TYPE arrayB            ;//move to the next element in the array
    call WaitMsg                    ;//Wait for user before moving to next index in the array
loop L1   

invoke ExitProcess, 0;
main endp
end main