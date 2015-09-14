;/* ---------------------------------------------------------------------------
;** File: main.asm
;** Description: Read two numbers; Finds the LCM of them; Determines if they
;**              are Prime Numbers
;** Assignment:
;**     Read two numbers from User Input
;**     Find the Least Common Multiple of those two Numbers
;**     Test Input:
;**         Input: 3,2 LCM = 6
;**         Input: 5,10 LCM = 10
;**         Input: 4,6 LCM = 12
;**     Determine if the two numbers entered or Prime
;** Author: Nathan Bremmer
;** -------------------------------------------------------------------------*/

INCLUDE Irvine32.inc
INCLUDE macros.inc


.386
.model flat, stdcall
.stack 4096

ExitProcess proto, dwExitCode:dword

.data
number1 word 0
number2 word 0

.code
;//------------------------------------------------------------------------------
main proc
;//
;// Description: Main Application Entry Point
;// Receives: Nothing
;// Returns: Nothing
;//------------------------------------------------------------------------------

;//Get User Input
call GetUserInput

;//Find Least Common Multiple
call FindLeastCommonMultiple

;//Check if first number is prime
xor ax, ax                              ;//clean the ax register for use
mov ax, number1                         ;//move the value of number1 to ax which is used by IsPrimeNumber
call IsPrimeNumber

;//Check if second number is prime
xor ax, ax                              ;//clean the ax register for use
mov ax, number2                         ;//move the value of number2 to ax which is used by IsPrimeNumber
call IsPrimeNumber

call WaitMsg                            ;//wait for use to end application
invoke ExitProcess, 0
main endp

;//------------------------------------------------------------------------------
GetUserInput PROC
;//
;// Description: Gets the input from the user
;// Uses: Nothing
;// Receives: Nothing
;// Returns: Nothing
;//------------------------------------------------------------------------------

.data
msgInputNumber1 byte "Enter Number 1: ", 0
msgInputNumber2 byte "Enter Number 2: ", 0
.code
;//Clean Registers
xor eax, eax
xor edx, edx

;//Get First Number form user
mov edx, OFFSET msgInputNumber1         ;//mov the prompt for the user to enter the first number into edx
call WriteString                        ;//write the value of edx to the console screen
call ReadInt                            ;//reads input from the user
mov number1, ax                         ;//save the input from the user into a variable

;//Get Second Number from user
xor eax, eax                            ;//clean the eax register for use
mov edx, OFFSET msgInputNumber2         ;//mov the prompt for the user to enter the first number into edx
call WriteString                        ;//write the value of edx to the console screen
call ReadInt                            ;//reads input from the user
mov number2, ax                         ;//save the input from the user into a variable

ret
GetUserInput ENDP

;//------------------------------------------------------------------------------
FindLeastCommonMultiple PROC USES esi ebx
;//
;// Description: Finds the least Common Multiple for two numbers provided by
;//              by the user and prints that value to the screen
;// Uses: ESI, EBX, EFlags
;// Receives: Nothing
;// Returns: Nothing
;//------------------------------------------------------------------------------

.data
msgLCM byte "The Least Common Multiple of the two numbers is ", 0
counter dword 0                         ;//used to track the attempt at finding the LCM
remainder1 dword 0
remainder2 dword 0
.code
;//save the contents of the flag registers
pushad
pushfd

mov counter, 2                           ;//start the attempt at 2

;//TODO(Nathan): Set the counter to the largest of the two numbers

L1:
;//clean the remainder variables
mov remainder1, 0
mov remainder2, 0

;//get remainder for the first number
mov edx, 0                              ;//clean the edx register
mov eax, counter                        ;//move the value of counter to eax
movzx ebx, number1                      ;//move the value of number1 to ebx
div ebx                                 ;// div eax by ebx
mov remainder1, edx                     ;//move the remainder from edx to remainder1

;//get remainder for second number
mov edx, 0                              ;//clean the edx register
mov eax, counter                        ;//move the value of counter to eax
movzx ebx, number2                      ;//move the value of number 2 to ebx
div ebx                                 ;//div eax by ebx
mov remainder2, edx                     ;//move the remainder from edx to remainder2

;//sum remainders; if the result is 0 then counter was the LCM of both numbers
mov eax, remainder1                     ;//move remainder1 to eax
add eax, remainder2                     ;//sum remainder2 with eax

;//check if sum is still zero; if it is then counter is the LCM
cmp eax, 0                              ;// compare the value of eax to 0
jz LCM                                  ;//if the compare was true jump to the LCM label
inc counter                             ;//increment the counter
jmp L1                                  ;//jump to the L1 label

LCM :
;//print message
mov edx, 0                              ;//clean the edx register
mov edx, OFFSET msgLCM                  ;//move the LCM message to the edx register
call WriteString                        ;//write the value of the edx register to the screen
mov eax, counter                        ;//move the value of the counter variable to the eax register
call WriteDec                           ;//write the vlaue of the eax register to the screen
call Crlf                               ;//right a line break
jmp Return                              ;//jump to return


Return :
;//return the state of the flags registers to what they were before the start of the function
popfd
popad
ret
FindLeastCommonMultiple ENDP


;//------------------------------------------------------------------------------
IsPrimeNumber PROC USES esi ebx
;//
;// Description: Determines if the value stored in the AX register is a Prime
;//              Number or Not and prints to the screen. 
;// Uses: ESI, EBX, EFlags
;// Receives: AX
;// Returns: Nothing
;//------------------------------------------------------------------------------

.data
msgIsPrime byte " Is a Prime Number", 0
msgIsNotPrime byte " Is not a Prime Number", 0

number dword 0
tester dword 0
.code
;//save the contents of the flag registers
pushad
pushfd

mov tester, 2                           ;//set the tester value to 2, this is needed since the method is called twice
mov number, eax                         ;//move the value of eax(ax) to number

L1 :
mov eax, number                         ;//move the value of number to eax
cmp eax, tester                         ;//compare the value of eax to tester
je Prime                                ;//jump to Prime label if they are equal

mov edx, 0                              ;//clean the edx register
mov ebx, tester                         ;//set the ebx register to tester
div ebx                                 ;//divide eax with ebx
cmp edx, 0                              ;//compare the remainder to 0; if the remainder is 0 then the number is not prime
jz NotPrime                             ;//jump to NotPrime label if the zero flag is set
inc tester                              ;//increment tester
jmp L1                                  ;//jump to L1 flag


Prime :
mov eax, number                         ;//move the value of number to eax
call WriteDec                           ;//write the value of eax to the console
mov edx, OFFSET msgIsPrime              ;//move the contents of msgIsPrime to edx
call WriteString                        ;//write the value of edx to the console
call Crlf                               ;//write a Line Feed
jmp Return                              ;//jump to return flag

NotPrime :
mov eax, number                         ;//move the value of number to eax
call WriteDec                           ;//write the value of eax to the console
mov edx, OFFSET msgIsNotPrime           ;//move the contents of msgIsNotPrime to edx
call WriteString                        ;//write the value of edx to the console
call Crlf                               ;//write a Line Feed
jmp Return                              ;//jump to return

Return :

;//restore the Flag registers
popfd
popad
ret
IsPrimeNumber ENDP
end main