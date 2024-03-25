.586
.model flat, stdcall
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

includelib msvcrt.lib
extern exit: proc
extern fscanf: proc
extern fprintf:proc
extern fopen:proc
extern fclose:proc
extern printf: proc
extern scanf: proc

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

public start
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


.data

nr db 0
k dd 0  ;for writing 1024 lines to file
nr2 db 0  ;for reading/writing data/keys
mode_write db "w",0
mode_read db "r",0
file_date db "data.txt",0
format db "%x", 0
file_keys db "keys.txt",0
endl db 10,0
pointer_date dd 0
pointer_keys dd 0
pointer_cript dd 0
pointer_date_cript dd 0
pointer_decript dd 0
format_string db "%s",0
encr_file db "encryption.txt",0
decr_file db "decryption.txt",0
data_encr_file db "data_encr.txt",0
space db " ",0
key dd 0
key2 dd 0
data dd 0
data2 dd 0
cript dd 0
msg_encr db "Encrypted data:",0
msg_decr db "Decrypted data: ",0
.code

random MACRO
	rdtsc
	mov bl, al
	ror ebx, 8
	rdtsc
	mov bl, al
	ror ebx, 8
	rdtsc
	mov bl,al
	ror ebx, 8
	rdtsc
	mov bl, al
 ENDM
 
write_random MACRO file_date
   push ebx
   push offset format
   push pointer_date
   call fprintf
   add esp,12 
ENDM

write_keys MACRO file_keys
	push ebx
	push offset format
	push pointer_keys
	call fprintf
	add esp, 12
ENDM


start:
		
   push offset mode_write
   push offset file_date
   call fopen
   mov pointer_date, eax
   add esp, 8
   
  
write_file:	
	inc k
	cmp k, 1024
	jg cont
	random  
	write_random file_date
	push offset endl
	push offset format_string
	push pointer_date
	call fprintf
	jmp write_file

cont:
	push pointer_date
	call fclose
	add esp,4
	
	
keys:
	push offset mode_write
	push offset file_keys
	call fopen
	mov pointer_keys, eax
	add esp,8
	
	mov nr,0
	
write_keys:
	inc nr
	cmp nr, 32
	jg cont2 
	random
	write_keys file_keys
	push offset endl
	push offset format_string
	push pointer_keys
	call fprintf 
	jmp write_keys

cont2:
	push pointer_keys
	call fclose
	add esp,4
	
	
;encryption	
	mov nr,0
	mov nr2,0
	
	push offset mode_write
	push offset encr_file
	call fopen
	mov pointer_cript,eax
	add esp,8
	
	push offset mode_read
	push offset file_date
	call fopen
	mov pointer_date, eax
	add esp,8
	
	push offset mode_read
	push offset file_keys
	call fopen
	mov pointer_keys, eax
	add esp,8
	
	push offset mode_write
	push offset data_encr_file
	call fopen
	mov pointer_date_cript, eax
	add esp,8
	
read_enc_key:	
    mov nr2,0
	inc nr
	cmp nr,32
	jg cont3
	push offset key
	push offset format
	push pointer_keys
	call fscanf
	add esp,12
	
read_enc:	
	inc nr2
	cmp nr2,32
	jg read_enc_key
	push offset data
	push offset format
	push pointer_date
	call fscanf
	add esp,12
	
	
	;data
	push data
	push offset format
	push pointer_cript
	call fprintf
	add esp,12
	
	
	push offset space
	push offset format_string
	push pointer_cript
	call fprintf
	add esp,12
	
	;key
	push key
	push offset format
	push pointer_cript
	call fprintf
	add esp,12
	
	push offset space
	push offset format_string
	push pointer_cript
	call fprintf
	add esp,12

	
	mov ebx, data
	mov edx, key
	xor ebx,edx
	mov cript, ebx
	push cript
	push offset format
	push pointer_cript
	call fprintf
	add esp,12
	
	push cript
	push offset format
	push pointer_date_cript
	call fprintf
	add esp, 12
	
	push offset endl
	push offset format_string
	push pointer_date_cript
	call fprintf
	add esp,12
	
	push offset endl
	push offset format_string
	push pointer_cript
	call fprintf
	add esp,12
	
	jmp read_enc
	
cont3:
	push pointer_cript
	call fclose
	add esp,4
	
	push pointer_date
	call fclose
	add esp,4
	
	push pointer_keys
	call fclose
	add esp,4
	
	push pointer_date_cript
	call fclose
	add esp,4
	
continue:
;decryption

	mov nr,0
	mov nr2,0
	
	push offset mode_write
	push offset decr_file
	call fopen
	mov pointer_decript,eax
	add esp,8
	
	
	push offset mode_read
	push offset file_keys
	call fopen
	mov pointer_keys, eax
	add esp,8
	
	push offset mode_read
	push offset data_encr_file
	call fopen
	mov pointer_date_cript, eax
	add esp,8
	
read_decr_key:	
    inc nr
	mov nr2,0
	cmp nr,32
	jg cont4
	push offset key2
	push offset format
	push pointer_keys
	call fscanf
	add esp,12
	
read_decr:	
	inc nr2
	cmp nr2,32
	jg read_decr_key
	push offset data2
	push offset format
	push pointer_date_cript
	call fscanf
	add esp,12
	
	
	;data
	push data2
	push offset format
	push pointer_decript
	call fprintf
	add esp,12
	
	push offset space
	push offset format_string
	push pointer_decript
	call fprintf
	add esp,12
	
	;key
	push key2
	push offset format
	push pointer_decript
	call fprintf
	add esp,12
	
	push offset space
	push offset format_string
	push pointer_decript
	call fprintf
	add esp, 12
	
	mov ebx, data2
	mov edx, key2
	xor ebx,edx
	push ebx
	push offset format
	push pointer_decript
	call fprintf
	add esp,12
	
	push offset endl
	push offset format_string
	push pointer_decript
	call fprintf
	add esp,12
	
	
	jmp read_decr
	
cont4:
	push pointer_decript
	call fclose
	add esp,4
	
	push pointer_keys
	call fclose
	add esp,4

	push pointer_date_cript
	call fclose
	add esp,4

final:

	push offset mode_read
	push offset encr_file
	call fopen
	mov pointer_cript, eax
	add esp,8

	push offset msg_encr
	call printf
	add esp,4
	push offset endl
	push offset format_string
	call printf
	add esp, 8
	
	mov k,0
	
write_enc:
	inc k
	cmp k,1024
	jg write_dec_step1
	
	push offset data
	push offset format
	push pointer_cript
	call fscanf
	add esp, 12
	
	push data
	push offset format
	call printf
	add esp, 8
	
	push offset space
	push offset format_string
	call printf
	add esp, 8
	
	push offset data
	push offset format
	push pointer_cript
	call fscanf
	add esp, 12
	
	push data
	push offset format
	call printf
	add esp, 8
	
	push offset space
	push offset format_string
	call printf
	add esp, 8
	
	push offset data
	push offset format
	push pointer_cript
	call fscanf
	add esp, 12
	
	push data
	push offset format
	call printf
	add esp, 8
	
	push offset endl
	push offset format_string
	call printf
	add esp, 8
	
	jmp write_enc
	
write_dec_step1:

	push offset endl
	push offset format_string
	call printf
	add esp, 8
	
	push pointer_cript
	call fclose
	add esp,4
	
	push offset mode_read
	push offset decr_file
	call fopen
	mov pointer_decript, eax
	add esp,8

	push offset msg_decr
	call printf
	add esp,4
	push offset endl
	push offset format_string
	call printf
	add esp, 8
	
	mov k,0
	
write_dec_step2:
	inc k
	cmp k,1024
	jg final2
	
	push offset data
	push offset format
	push pointer_decript
	call fscanf
	add esp, 12
	
	push data
	push offset format
	call printf
	add esp, 8
	
	push offset space
	push offset format_string
	call printf
	add esp, 8
	
	push offset data
	push offset format
	push pointer_decript
	call fscanf
	add esp, 12
	
	push data
	push offset format
	call printf
	add esp, 8
	
	push offset space
	push offset format_string
	call printf
	add esp, 8
	
	push offset data
	push offset format
	push pointer_decript
	call fscanf
	add esp, 12
	
	push data
	push offset format
	call printf
	add esp, 8
	
	push offset endl
	push offset format_string
	call printf
	add esp, 8
	
	jmp write_dec_step2
	
	final2:
	push pointer_decript
	call fclose
	add esp,4
	push 0
	call exit
end start
