#make_bin#

#LOAD_SEGMENT=FFFFh#
#LOAD_OFFSET=0000h#

#CS=0000h#
#IP=0000h#

#DS=0000h#
#ES=0000h#

#SS=0000h#
#SP=FFFEh#

#AX=0000h#
#BX=0000h#
#CX=0000h#
#DX=0000h#
#SI=0000h#
#DI=0000h#
#BP=0000h#
		
			jmp ioinit
			db     	5 dup(0)
			dw		interrupt
			dw		0000
			db		1012 dup(0)
			
ioinit:		
		porta		equ 	10h
		portb		equ		12h
		portc		equ		14h
		ctrio		equ		16h
		
		weight_need	equ		1002h
		motor		equ		1003h
		button		equ		1004h
		choc_no_1	equ		1005h
		choc_no_2	equ		1006h
		choc_no_3	equ		1007h
		
		mov ax,0100h
        mov ds,ax
        mov es,ax
        mov ss,ax
        mov sp,0FFFEh
		
		mov al,10010001b
		out	ctrio,al
		
		mov al,0
		mov choc_no_1,al
		mov choc_no_2,al
		mov choc_no_3,al
		
x1:		jmp x1

interrupt:
		
		mov cx,30d4h
delay1:	nop							;20ms delay
		nop
		nop
		nop
		loop delay1
		
		in al,portc		;stores state of buttons in al then checks if a button has been pressed
		and al,07h
		cmp al,07h
		jz exitp
		
		
		mov cx,30d4h
delay2:	nop							;20ms delay
		nop
		nop
		nop
		loop delay2
		
		in al,portc		;stores state of buttons in al then checks if a button has been actually pressed
		and al,07h
		mov button,al
		cmp al,07h
		jz exitp
		
		mov di,05h
		mov motor,00001100b
		
but1:					;button 1 was pressed the weight of the coins needed is stored
		cmp [button],06h
		jnz but2
		mov [weight_need],82
		jmp x3
		
but2:					;button 2 was pressed the weight of the coins needed is stored and the motor selected
		cmp [button],05h
		jnz but3
		mov weight_need,89
		xor [motor],00010000b
		inc di
		jmp x3
		
but3:					;button 3 was pressed the weight of the coins needed is stored and the motor selected
		cmp [button],03h
		jnz exitp
		mov [weight_need],103
		xor [motor],00100000b
		inc di
		inc di
x3:		
		mov bx,1770h
twomindelay:			
		;mov cx,30d4h
		;mov cx, 02d4h
delay3:	nop							;20ms delay
		nop
		nop
		nop
		;loop delay3
		
		dec bx
		jnz twomindelay
		
		mov al,00001001b
		out ctrio,al
		
		mov al,00001000b
		out ctrio,al
		
		mov cx,400
delay4:	nop							;2.5 us delay
		nop
		nop
		nop
		loop delay4
		
		mov al,00001001b
		out ctrio,al
		
weight_ready:
		in al,portc	
		and al,00001000b
		jz weight_ready
		
		in al,porta
		cmp al,[weight_need]			;equal or more coin
		jb exitp
		        
		mov al,[motor]        
		out portb,al
		xor [motor],00001010b
	    mov al,[motor]        
		out portb,al			;motor turned by one step
		xor [motor],00000101b
		mov al,[motor]        
		out portb,al
		xor [motor],00001010b
		mov al,[motor]        
		out portb,al
		
		sub [di],1
		
choc1:								;checking if chocolate 1 finished
		cmp [1005h],0
		ja choc2
		mov al,00001111b
		out ctrio,al
choc2:								;checking if chocolate 2 finished
		cmp [1006h],0
		ja choc3
		mov al,00001101b
		out ctrio,al
choc3:								;checking if chocolate 3 finished
		cmp [1007h],0
		ja exitp
		mov al,00001011b
		out ctrio,al
		
exitp:		iret		