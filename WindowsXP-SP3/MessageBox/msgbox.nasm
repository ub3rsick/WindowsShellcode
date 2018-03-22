; Author	: RIZAL MUHAMMED [UB3RSiCK]
; Date		: 21/03/2018
;
; Filename	: msgbox.nasm
; compile/link	: nasm -f elf32 msgbox.nasm -o msgbox.o; ld msgbox.o -o msgbox

; WINDOWS XP SP3 - MessageBoxA
; user32.dll is dynamically loaded and MessageBoxA address is retieved during runtime.
; 

; LoadLibraryA is located at 0x7c801d7b in kernel32.dll
; GetProcAddress is located at 0x7c80ae30 in kernel32.dll
; ExitProcess is located at 0x7c81cafa in kernel32.dll

section .text

global _start

_start:
	
	; clear all registers
	xor eax, eax
	xor ebx, ebx
	xor ecx, ecx
	xor edx, edx

	jmp short getLibraryName
		retLibraryName:
			pop ecx
			mov [ecx + 10], dl	; Inser NULL terminator
			
			; HMODULE WINAPI LoadLibrary(
			;	  _In_ LPCTSTR lpFileName
			; );

			mov ebx, 0x7c801d7b	; LoadLibraryA
			push ecx		; Pointer to user32.dll NULL terminated
			call ebx		; Module handle is returned to EAX

	jmp short getFuncName
		retFuncName:
			pop ecx
			xor edx, edx
			mov [ecx + 11], dl	; Insert NULL terminator at end of MessageBoxA string
			
			; FARPROC WINAPI GetProcAddress(
			;	  _In_ HMODULE hModule,
			;	  _In_ LPCSTR  lpProcName
			; );			

			push ecx		; Pointer to  MessageBoxA string
			push eax		; user32 module handle
			mov ebx, 0x7c80ae30	; GetProcAddress 
			call ebx		; Returns address of MessageBoxA in EAX

	jmp short getDisplayMsg
		retDisplayMsg:
			pop ecx
			xor edx, edx
			mov [ecx + 8], dl	; Inset NULL at end of display message
			
			; int WINAPI MessageBox(
			;	  _In_opt_ HWND    hWnd,		; Handle to owner of the msgbox window, NULL - has no owner window
			;	  _In_opt_ LPCTSTR lpText,		; Display message
			;	  _In_opt_ LPCTSTR lpCaption,		; Box Title
			;	  _In_     UINT    uType		; MB_OK 0x00000000L
			; );
			 
			push edx		; MB_OK
			push ecx		; Title
			push ecx		; Caption
			push edx		; NULL - no owner window
			
			; eax has address of MessageBoxA
			call eax
	exit:
		push edx			; ExitProcess exitcode
		mov eax, 0x7c81cafa		; ExitProcess
		call eax			; Safely exit without crashing
			
	getLibraryName:
		call retLibraryName
		db 'user32.dllN'

	getFuncName:
		call retFuncName
		db 'MessageBoxAN'
	
	getDisplayMsg:
		call retDisplayMsg
		db 'UB3RSiCKN'
