;;; This file contains the morse encoder of a messagewritten in Assembly
;;; Part of the group project of group 01
	
#define __SFR_OFFSET 0
#include <avr/io.h>

	DOT_GAP = 10 	; 100 ms
	DASH_GAP = 30	; 300 ms
	LETTER_GAP = 70	; 700 ms
	END_OF_MESSAGE = 100	; 1s
	
;;; Definitions of all the letters:
;;;( First 4 bits hold the length and last 4 hold the sequence of dots and dashes.
;;; The sequence is stored opposite as the signals are sent
;;; from the smallest to the highest bit.)
;;; 0b  0000  _  0000
;;;     ____     ____
;;;      ||       ||
;;;      ||       ||
;;;      XX       XX
;;;    length  sequence
;;; e.g. 0b0011 0011 - means 3 morse symbols: Dash -> Dash -> Dot  ===> the letter G
	
	;; Letters with length of 1
	E = 0b10000
	T = 0b10001

	;; Letters with length of 2
	I = 0b100000
	A = 0b100010
	N = 0b100001
	M = 0b100011

	;; Letters with length of 3
	S = 0b110000
	U = 0b110100
	R = 0b110010
	W = 0b110110
	D = 0b110001
	K = 0b110101
	G = 0b110011
	O = 0b110111

	;; Letters with length of 4
	H = 0b1000000
	V = 0b1001000
	F = 0b1000100
	L = 0b1000010
	P = 0b1000110
	J = 0b1001110
	B = 0b1000001
	X = 0b1001001
	C = 0b1000101
	Y = 0b1001101
	Z = 0b1000011
	Q = 0b1001011


	

	
;;; Make main global so that it can be available in init.S
	.global main
main:
;;; Make PIN 13 on PORTB an output.
	sbi DDRB, 5

;;; Repeat the encoding forever
endless_cycle:
;;; Clear register 25 to use it as a counter for the elements of the array.
	clr r25
;;; Load the first index of the array on Z.
	ldi r30, lo8(message)
	ldi r31, hi8(message)
;;; Repeat for all letters.
	
encode_all_letters:
;;; See if the end of the array has been reached
;;; And if it has been reached to end the process.
	cpi r25, LENGTH
	breq end_of_message
	
;;; Load the letter on register 17 (r17 is used in encode_letter),
;;; then increment Z (go to next index).
	lpm r17, Z+
	call encode_letter
;;; increment the current index.
	inc r25
;;; Repeat the process until finishing the message.
	rjmp encode_all_letters
	
;;; make a pause after finished the message.
end_of_message:
;;; Make the 1 second delay.
	ldi r24, END_OF_MESSAGE
	call delay_cs
	jmp endless_cycle		; Repeat the message forever.


encode_letter:
;;; r28 holds the length
	mov r28, r17
	swap r28
	andi r28, 0b00001111
;;; r29 holds the sequence
	mov r29, r17
	andi r29, 0b00001111

encoding:
	cpi r28, 0
	breq 1f

;;; take the last of the symbols
	mov r16, r29
	andi r16, 0b00000001
	call encode_symbol
	
	
	dec r28
;;; decrement the count of sybols
	lsr r29
;;; Delete the last symbol and move others to the right.
	rjmp encoding
1:
	ldi r24, LETTER_GAP
	call delay_cs
	reti




;;; Symbol should be loaded on r16.
encode_symbol:
;;; Set bit in PIN 13.
	sbi PORTB, 5
;;; Check whether it should be a dot(0) or a dash(1).
	cpi r16, 1
	breq dash_delay

dot_delay:
;;; Make a 100ms delay for a dot.
	ldi r24, DOT_GAP
	call delay_cs
	rjmp 1f
dash_delay:
;;; Make a 300ms delay for a dash.
	ldi r24, DASH_GAP
	call delay_cs
	rjmp 1f

1:
;;; Clear bit in PIN 13.
	cbi PORTB, 5
;;; Make a SIGNAL_GAP.
	ldi r24, 10
	call delay_cs
	reti

;;; Length of the array and the array holding the massage.
	LENGTH = 26
	.global message
	.type   message, @object
message:
	.byte	A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z
