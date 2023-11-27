.equ sck=5         ; we set up pin for master
.equ miso=4
.equ mosi=3
.equ ss=2
        .EQU	RS=2		;bit RS
		.EQU	RW=3		;bit RW
		.EQU	E=4		    ;bit E

.org 0

ldi r16, high(RAMEND)
out SPH, r16
ldi r16, low(RAMEND)
out SPL, r16

ldi r16,$1c      ; we set up pin for rs,rw,e for lcd in master
out ddrc,r16

CBI		PORTC,RS			
CBI		PORTC,RW		;set up lcd	
CBI		PORTC,E	

RCALL	POWER_RESET_LCD8	
RCALL	INIT_LCD8

rcall spi_init
rcall USART_Init       ; Initialize USART
rcall spi_init
ldi r16,$ff
out ddrd,r16

sbi portc,0   ; we set pin to receive signal from slave
sbi portb,2   ; we set pin for ss to control slave
loop:
	rcall spi_transmit
	rjmp loop
spi_transmit:
	check: sbic pinc,0  ; we check if data is already in spdr of slave or not
	       rjmp check
	cbi portb,2         ; we set pin "SS" to low to let slave transmit data to master
	nop
	out spdr,r16
	wait_transmit: 
	in r18,spsr
	sbrs r18,spif
	rjmp wait_transmit
	in r16,spdr    ; r16 contain data from slave
	sbi portb,2
	rcall USART_SendChar  ; we send data from keypad to terminal
	mov r20,r16

	CBI PORTC,RS
	LDI R17,0X01
	RCALL OUT_LCD  ; clear display
	LDI R16,20
	RCALL DELAY_US

	mov r17,r20

	sbi PORTC,rs
	rcall XUAT          ; we send data from keypad to lcd
	ldi r16,1
	RCALL	DELAY_US
	ret


spi_init:
	ldi r16,(1<<sck)|(1<<ss)|(1<<mosi)|(0<<miso)
	out ddrb,r16
	ldi r16,(1<<SPE)|(1<<mstr)|(1<<spr0)
	out spcr,r16
	;ldi r16,(1<<spi2x0)
	;sts spsr0,r16
	ret
USART_Init:
   ldi r16, 103           ; Set baud rate for 9600 bps with 1 MHz clock
    sts UBRR0L, r16       ; Set baud rate low byte
    ldi r16, (1<< U2X0)  ; Set double speed
    sts UCSR0A, r16
    ldi r16, (1 << UCSZ01) | (1 << UCSZ00) ; 8 data bits, no parity, 1 stop bit
    sts UCSR0C, r16
    ldi r16, (1 << RXEN0) | (1 << TXEN0)   ; Enable transmitter and receiver
    sts UCSR0B, r16
    ret

USART_SendChar:
    push r17
    USART_SendChar_Wait:
    lds r17, UCSR0A
    sbrs r17, UDRE0       ; Wait for data register to be empty 
    rjmp USART_SendChar_Wait
    sts UDR0, r16         ; Send character in r16
    pop r17
    ret

USART_ReceiveChar:
    push r17
    USART_ReceiveChar_Wait:
    lds r17, UCSR0A
    sbrs r17, RXC0        ; Wait for receive complete
    rjmp USART_ReceiveChar_Wait
    lds r16, UDR0         ; Store received character in r16
    pop r17
    ret
INIT_LCD8:                       
				
				CBI PORTC,RS
				LDI	R17,0X02
				RCALL OUT_LCD   ; set the cursor to
				LDI R16,1
				RCALL DELAY_US

				CBI PORTC,RS
				LDI R17,0X01
				RCALL OUT_LCD   ; clear all the content original of lcd
				LDI R16,20
				RCALL DELAY_US

				CBI PORTC,RS
				LDI R17,0X0C
				RCALL OUT_LCD    ;turn on lcd and turn off cursor
				LDI R16,1
				RCALL DELAY_US
				RET
POWER_RESET_LCD8: 
				LDI		R16,200				
				RCALL	DELAY_US		
			    CBI		PORTC,RS
				LDI		R17,$30		; we set up lcd 3 times
				RCALL	OUT_LCD
				LDI		R16,42
				RCALL	DELAY_US

				CBI		PORTC,RS
				LDI		R17,$30			
				RCALL	OUT_LCD
				LDI		R16,2
				RCALL	DELAY_US

				CBI		PORTC,RS
				LDI		R17,$30
				RCALL	OUT_LCD
				LDI		R16,2
				RCALL	DELAY_US		
				RET


XUAT: 
				MOV		R21,R17
				ANDI    R21,$F0   ; code here we have value of keypad(0,1,2,3,...,E,F)in assci in r17
				OUT		PORTD,R21 ;the reason why we have to do ori is make sure rs always =1
				SBI		PORTC,E   ; this code for high nibble
				CBI		PORTC,E

				LDI		R16,1
				RCALL	DELAY_US

				SWAP	R17
				ANDI	R17,$F0
				OUT		PORTD,R17
				SBI		PORTC,E				
				CBI		PORTC,E
				LDI		R16,1
				RCALL	DELAY_US

				RET
				
OUT_LCD: 	
				MOV		R21,R17
				ANDI    R21,$F0  ; this one the same code above
				OUT		PORTD,R21 ; just diffent we don't have ori  
				SBI		PORTC,E   ; because we want rs=0 for commands
				CBI		PORTC,E

				LDI		R16,1
				RCALL	DELAY_US

				SWAP	R17
				ANDI	R17,$F0
				OUT		PORTD,R17
				SBI		PORTC,E				
				CBI		PORTC,E

				LDI		R16,1
				RCALL	DELAY_US
				RET

DELAY_US:	MOV	R15,R16		
			LDI	R16,200			
L1:			MOV	R14,R16		
L2:			DEC	R14				
			NOP					
			BRNE	L2		
			DEC		R15				
			BRNE	L1				
			RET