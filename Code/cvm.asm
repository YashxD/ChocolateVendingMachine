.model		tiny
.data
		porta		equ 	10h
		portb		equ		12h
		portc		equ		14h
		ctrio		equ		16h
		button		db		?
		weight_need	db		82
		motor 		db		00001100b
		choc_no_1	db		10
		choc_no_2	db		10
		choc_no_3	db		10
		
.code
.startup
init:
       	mov ax,0
		mov es,ax
		mov ax,interrupt
		mov [es:08h],ax
		mov ax,00h
		mov [es:0ah],ax
		
		mov       ax,0200h
        mov       ds,ax
        mov       es,ax
        mov       ss,ax
        mov       sp,0FFFEH
		  
		mov al,10010001b
		out	ctrio,al

		mov choc_no_1,10
		mov choc_no_2,10
		mov choc_no_3,10
		
x1:		jmp x1		

interrupt:
		call delay	
		;call testmot
		;jmp choc1
		
		mov al,10010001b
		out	ctrio,al
		
		in al,portc		;state of buttons in al
		and al,07h
		cmp al,07h
		jz exitp
		
		call delay
		in al,portc		;state of buttons in al
		and al,07h
		mov button,al
		cmp al,07h
		jz exitp
		
		
		;Initialize Variables
		mov weight_need, 82
		mov motor, 00000001b
		lea di,choc_no_1

but1:					;button 1 was pressed the weight of the coins needed is stored
		cmp button,06h
		jnz but2
		jmp weight_ready
		
but2:					;button 2 was pressed the weight of the coins needed is stored and the motor selected
		cmp button,05h
		jnz but3
		mov weight_need,89
		xor motor,00010000b
		inc di
		jmp weight_ready
		
but3:					;button 3 was pressed the weight of the coins needed is stored and the motor selected
		cmp button,03h
		jnz exitp
		mov weight_need,103
		xor motor,00100000b
		inc di
		inc di
		
		
weight_ready:

		;call delay2min
		
		in al,portc	
		and al,00001000b
		;jz weight_ready
		
		call rotmot
		;call testmot
		
		in al,porta
		cmp al,weight_need			;equal or more coin
		jb exitp
				
		;call rotmot
		sub byte ptr [di],1
		
choc1:								;checking if chocolate 1 finished
		cmp choc_no_1,0
		jne choc2
		mov al,00001111b
		out ctrio,al
choc2:								;checking if chocolate 2 finished
		cmp choc_no_2,0
		jne choc3
		mov al,00001101b
		out ctrio,al
choc3:								;checking if chocolate 3 finished
		cmp choc_no_3,0
		jne exitp
		mov al,00001011b
		out ctrio,al
		
exitp:		
		mov al,10010001b
		out	ctrio,al
		iret		
		
.exit


delay proc near
		mov cx,30d4h
	x2:	nop
		nop
		nop
		nop
		loop x2
		ret
delay endp


delay2min	proc near
		mov cx,1770
delay2minloop:
		call delay
		loop delay2minloop
		ret
delay2min	endp


delayr	proc near
		mov cx,0F000h
delayrr:
		nop
		nop
		nop
		nop
		loop delayrr
		ret
delayr	endp


rotmot proc near
		;and motor,00000000b
		;or	motor,00000001b
		mov al,motor
		out portb,al
		call delayr
		
		xor motor,00000011b
		mov al,motor
		out portb,al
		call delayr
		
		xor motor,00000110b
		mov al,motor
		out portb,al
		call delayr
		
		xor motor,00001100b
		mov al,motor
		out portb,al
		call delayr
		
		xor motor,00001001b
		mov al,motor
		out portb,al
		call delayr
		ret
rotmot	endp


testmot proc near
		mov al,00000001b
		out portb,al
		call delayr
		
		mov al,00000010b
		out portb,al				;motor turned by one step
		call delayr
		
		mov al,00000100b
		out portb,al
		call delayr
		
		mov al,00001000b
		out portb,al
		call delayr
		
		mov al,00000001b
		out portb,al
		call delayr
		ret
testmot endp

end