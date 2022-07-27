// BEGIN: asminject_libc_fclose
// wrapper for the libc fclose function
// tested with libc 2.2.5 and 2.4
// Assumes the signature for fclose is int fclose(FILE * stream);
// if your libc has a different signature for fclose, this code will probably fail
// edi = file handle

asminject_libc_fclose:
	push ebp
	mov ebp, esp
	sub esp, 0x10
	push r9
	push r14
	
	mov r9, [BASEADDRESS:.+/libc[\-0-9so\.]*.(so|so\.[0-9]+)$:BASEADDRESS] + [RELATIVEOFFSET:^fclose($|@@.+):RELATIVEOFFSET]
	call r9

	pop r14
	pop r9
	leave
	ret
	
// END: asminject_libc_fclose