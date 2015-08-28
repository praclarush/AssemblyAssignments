TITLE MASM TemplateTITLE MASM Template


;//Description: Week 2 Assignment; first part is the tutorial the second part is the addition task of problem 3
;
;//Revision date:


INCLUDE Irvine32.inc
.data
myMessage BYTE "My name is Nathan Bremmer and this is my first assembly language class", 0dh, 0ah, 0
var1 WORD 10
var2 WORD - 60
var3 WORD 30

.code
main PROC
call Clrscr

;//Show Message 
mov  edx, OFFSET myMessage
call WriteString

xor eax, eax                ;//clearing the eax register of the string message

;//My Code (Nathan)
;//Addition Task problem 3
;//mov ax, var1                ;//move the value of var1 to the ax register (16bit part of eax)
;//add ax, var2                ;//add the value of var2 to the ax register
;//add ax, var3                ;//add the value of var3 to the ax register

;//Teachers Response

movzx eax, var1 ;//Move 16 bits into the eax and zero-extend the high-order 16bits
add ax, var2
add ax, var3


call DumpRegs               ;//dump the registers to the console window;
call waitMsg


exit
main ENDP

END main

;//Even though the value is negative the data is still only 16 bits, those 16 bits only take up half of the eax register so the other half is empty resulting in all zeros. 
;// Add the the fact that negative values are still displayed as positive numbers only with a negative flag set in the FLAGS register