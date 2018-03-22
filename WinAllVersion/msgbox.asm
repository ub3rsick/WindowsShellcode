; https://github.com/NoviceLive/shellcoding/tree/master/windows/messagebox
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
	;; nonvolatile ebx = LoadLibrary("kernel32.dll");	kernel32.dll module handle
	;; nonvolatile esi = GetProcAddress;				GetProcAddress function address	

    ;; eax = GetProcAddress(ebx, "LoadLibraryA");
    push edi
    push 'Ayra'
    push 'rbiL'
    push 'daoL'
    push esp			; pointer to LoadLibraryA string
    push ebx			; kernel32.dll module handle
    call esi			; GetProcAddress(kernel32 Handle, "LoadLibraryA");
						; return address of LoadLibraryA to EAX
	
	
    ;; eax = LoadLibrary("user32");
    xor ecx, ecx
    push edi
    mov cx, '23'
    push ecx
    push 'resu'
    push esp		; pointer to user32 string
    call eax		; LoadLibraryA("user32")
					; user32.dll module handle is returned to EAX

	; Find address of MessageBoxA function in user32.dll
    ;; eax = GetProcAddress(eax, "MessageBoxA")
    push edi
    push 0141786fh
    dec byte ptr [esp + 3h]
    push 'Bega'
    push 'sseM'
    push esp		; pointer to MessageBoxA string
    push eax		; user32.dll module handle
    call esi		; GetProcAddress(user32.dll module handle, MessageBoxA)
					; returns address of MessageBoxA to EAX

    ;; eax = MessageBoxA(NULL, "Hello World!", NULL, MB_OK);
    push edi
    push '!dlr'
    push 'oW o'
    push 'lleH'
    mov ecx, esp
    push edi		; MB_OK NULL
    push edi		; NULL
    push ecx		; Pointer to HelloWorld! string
    push edi		; NULL
    call eax		; invoke MessageBoxA

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
