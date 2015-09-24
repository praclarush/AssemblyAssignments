
;/* ---------------------------------------------------------------------------
;**
;** File: main.asm
;** Description: Week 8 Assignment
;** Assignment:
;**    1. Macro that receives a 32 bit integer and a string and writes the string to the screen as many times as specified by the integer.
;**    2. Macro that receives two 32 bit integers then divides the first by the 2nd and outputs the result and remainder.
;**    3. Macro that receives a character value and returns the ASCII value (alpha numeric).
;** Author: Nathan Bremmer
;** -------------------------------------------------------------------------*/

INCLUDE Irvine32.inc
INCLUDE macros.inc

ExitProcess proto, dwExitCode:dword

.data
;//problem 1:
message byte "Repeat this string X times", 13, 10, 0
count dword 3

;//problem 2:
dividend dword 5
divisor dword 3

;//problem 3:
asciivalue dword ?
.code

;//------------------------------------------------------------------------------
mGetAsciiValue MACRO char:req, value:req
;//
;// Description:gets the ASCII value for a provided char
;// Uses:
;// Returns:the ascii value of char in Value
;//------------------------------------------------------------------------------

mov value, char

ENDM


;//declare macros
;//------------------------------------------------------------------------------
mDivideNumber MACRO dividend:req, divisor:req
;//
;// Description: Divides the dividend by the divisor and prints out the quotient 
;//              and remainder
;// Avoid using: edx, eax, ebx
;//------------------------------------------------------------------------------
.data
remainder dword 0

.code
push edx
push eax
push ebx

xor edx, edx
xor eax, eax
xor ebx, ebx

mov eax, dividend
call WriteInt
mWrite " divided by "

xor eax, eax
mov eax, divisor
call WriteInt

mWrite " is: "

xor eax, eax
mov eax, dividend
mov ebx, divisor
div ebx

call WriteInt

mWrite " with a remainder of "
xor eax, eax
mov eax, edx
call WriteInt
call Crlf 

pop ebx
pop eax
pop edx

ENDM

;//------------------------------------------------------------------------------
mRepeatString MACRO string : req, amount : = <1>
;//
;// Description: prints the value stored in string the amount of times stored in
;//              amounts
;// Defaults: Default value of amount is 1
;// Avoid using: edx, ecx
;// Returns:
;//------------------------------------------------------------------------------

push edx
;;//clean the registers for use
xor edx, edx
xor ecx, ecx

mov ecx, amount;;// move the value of amount to the edi value for look

L1:
call WriteString;;//write the value of edx to the screen
loop L1

pop edx
ENDM


;//declare main code
;//------------------------------------------------------------------------------
main proc
;//
;// Description: Main application point
;//------------------------------------------------------------------------------

jmp Problem3


Problem1:

mRepeatString message, count

call WaitMsg
call Clrscr

Problem2:

mDivideNumber dividend, divisor
call WaitMsg
call Clrscr

Problem3:
mGetAsciiValue 'a', asciivalue

mWrite "The Ascii Value of 'a' is "
mov eax, asciiValue
call WriteInt
call crlf

call WaitMsg
call Clrscr

invoke ExitProcess, 0
main endp

end main