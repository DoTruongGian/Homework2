.equ sck=5    ;set up pins for spi 
.equ miso=4
.equ mosi=3
.equ ss=2
.org 0
ldi r16, high(RAMEND)
out SPH, r16
ldi r16, low(RAMEND)
out SPL, r16
rcall spi_init

ldi r16,$0f
out ddrd,r16 ; 0-3 is output 4-7 is input pull-up 
ldi r16,$f0  ; here we set up for keypad
out portd,r16


sbi ddrc,0   ; we set up pin that master can know to set pin ss to low
sbi portc,0
loop:
	rcall xu_ly
	rjmp loop
xu_ly:

		LAP:	ldi r17,$fe     ;in port a from pin 4->7 is pull-up resistor
				out portd,r17   ;so from 0->3 is output it can be high or low
				sbic PIND,4     ; if pina 4 is press 
				rjmp NHAY       ; if not we jump to another rows
				
				rcall DELAY
		deb:	sbis pind,4
				rjmp deb

				LDI R17,$33    ; than we load number 3
			    rcall spi_transmit
	
		NHAY:
				SBIC PIND,5    ; pina 5 is press or not
				RJMP NHAY_1

				rcall DELAY
		deb1:	sbis pind,5
				rjmp deb1
		
				LDI R17,$34     ; here we load number 4
				rcall spi_transmit

		NHAY_1: SBIC PIND,6    
				RJMP NHAY_2

				rcall DELAY
		deb2:	sbis pind,6
				rjmp deb2
			
				LDI R17,$42
				rcall spi_transmit
				
		NHAY_2:
				SBIC PIND,7
				RJMP NHAY_3
				
				rcall DELAY
		deb3:	sbis pind,7
				rjmp deb3

				LDI R17,$43
				rcall spi_transmit
				
		NHAY_3:	
				LDI R17,$fD      ; here we change other columns
				OUT PORTD,R17    ; and we check like the code above
				SBIC PIND,4
				RJMP NHAY_4
				
				rcall DELAY
		deb4:	sbis pind,4
				rjmp deb4
						
				LDI R17,$32
				rcall spi_transmit
			
		NHAY_4: 
				SBIC PIND,5
				RJMP NHAY_5
				
				rcall DELAY
		deb5:	sbis pind,5
				rjmp deb5

			
				LDI R17,$35
				rcall spi_transmit
			
		NHAY_5:	
				SBIC PIND,6
				RJMP NHAY_6
				
				rcall DELAY
		deb6:	sbis pind,6
				rjmp deb6
					
				LDI R17,$41
				rcall spi_transmit
		
		NHAY_6:
				SBIC PIND,7
				RJMP NHAY_7
				
				rcall DELAY
		deb7:	sbis pind,7
				rjmp deb7
					 
				LDI R17,$44
				rcall spi_transmit
					
		NHAY_7:
				LDI R17,$fB
				OUT PORTD,R17
				SBIC PIND,4
				RJMP NHAY_8
				
				rcall DELAY
		deb8:	sbis pind,4
				rjmp deb8
			
				LDI R17,$31
				rcall spi_transmit
			
		NHAY_8:
				SBIC PIND,5
				RJMP NHAY_9
				
				rcall DELAY
		deb9:	sbis pind,5
				rjmp deb9

					
				LDI R17,$36
				rcall spi_transmit
			
		NHAY_9:	
				SBIC PIND,6
				RJMP NHAY_10
				
				rcall DELAY
		deb10:	sbis pind,6
				rjmp deb10
							
				LDI R17,$39
				rcall spi_transmit
				
		NHAY_10:
				SBIC PIND,7
				RJMP NHAY_11
				
				rcall DELAY
		deb11:	sbis pind,7
				rjmp deb11
	
				LDI R17,$45
				rcall spi_transmit
			
		NHAY_11:	
				LDI R17,$f7
				OUT PORTD,R17
				SBIC PIND,4
				RJMP NHAY_12
				
				rcall DELAY
		deb12:	sbis pind,4
				rjmp deb12
			
				LDI R17,$30
				rcall spi_transmit
			
		NHAY_12:
				SBIC PIND,5
				RJMP NHAY_13
				
				rcall DELAY
		deb13:	sbis pind,5
				rjmp deb13
					
				LDI R17,$37
				rcall spi_transmit
			
		NHAY_13:
				SBIC PIND,6
				RJMP NHAY_14
				
				rcall DELAY
		deb14:	sbis pind,6
				rjmp deb14
			
				LDI R17,$38
				rcall spi_transmit

		NHAY_14:
				SBIC PIND,7
				RJMP NHAY_15
				
				rcall DELAY
		deb15:	sbis pind,7
				rjmp deb15

				LDI R17,$46
			    rcall spi_transmit
		NHAY_15:
				RJMP LAP
ret

spi_transmit:
	cbi portc,0     ; we send signal to master
	nop             ; and master will set pin ss to low
	nop             ; and slave can transfer data to master
	nop
	nop
	out spdr,r17

	wait_transmit:  ; code here we check data is transfer from slave to master
	in r18,spsr     ; it is finished or not
	sbrs r18,spif
	rjmp wait_transmit
	in r17,spdr
	sbi portc,0
	ret


spi_init:
	ldi r16,(1<<miso)|(0<<sck)|(0<<ss)|(0<<mosi)
	out ddrb,r16
	ldi r16,(1<<SPE)|(1<<spr0)
	out spcr,r16
	;ldi r16,(1<<spi2x0)
	;sts spsr0,r16
	ret
DELAY:
L3: LDI R21,100 ;1MC
L1: LDI R20,200 ;1MC
L2: DEC R20 ;1MC
NOP ;1MC
BRNE L2 ;2/1MC
DEC R21 ;1MC
BRNE L1 ;2/1MC
RET