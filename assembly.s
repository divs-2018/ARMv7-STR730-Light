;@============================================================================
;@
;@ Student Name 1: Divyam Sharma
;@
;@
;@ Also, reference resources beyond the course textbooks and the course pages on Canvas
;@ that you used in making your submission.
;@
;@ Name        : assembly.s
;@ Copyright (C) 2020 Craig Scratchley    wcs (at) sfu (dot) ca  
;@============================================================================

;@ Tabs set for 8 characters in Edit > Configuration

#include "asm_include.h"
#include "73x_tim_l.h"
#include "73x_eic_l.h"
;@ defining some constants for loading
#define CR1_bits 0x00008090
#define OCBR_value 0x00008000
#define prescalar_value 0x00000810

	IMPORT	ARMFIQ_Disable
	IMPORT	ARMFIQ_Enable		

	GLOBAL	FIQ_Handler
	GLOBAL	InitHwAssembly
	GLOBAL	LoopFunc
	AREA	||.text||, CODE, READONLY
	
FIQ_Handler
	// You can put your FIQ_Handler here.
	// At that point, you can remove some code from LoopFunc below.
	
	;@ check if external interupt
	ldr r4, =EIC_BASE
	ldr r3,[r4,#EIC_FIPR]
	
	mov r5,#0x00000002
	cmp r3,r5
	beq timer 
	
	ldr r2,=TIM0_BASE
	ldr r9,[r2,#TIMn_CR2];
	lsl r9,r9,#1;@double prescalar
	
	cmp r9,#0x00001100;@prescalar overflow, reset to original
	bicne r9,r9,#0xFF00
	ldreq r9,=prescalar_value
	orr r9,r9,#0x0800 ;@reenable OCBIE
	strh r9,[r2,#TIMn_CR2]
	
	;@check if timer interrupt as well
	mov r5,#0x00000001
	cmp r3,r5
	beq finish
timer
	ldr 	R12, =GPIO0_BASE
	ldrh	R1, [R12, #GPIO_PD_OFS]	
	cmp R1, #GPIO_PIN_15
	moveq R8, #0
	cmp R1, #GPIO_PIN_0 
	moveq R8, #1
	
	cmp r8,#1
	;@divide or multiply by 2 for next pin
	lsleq r1, r1,#1
	lsrne r1, r1,#1
	strh 	R1, [R12, #GPIO_PD_OFS]
	
finish
	ldr r2,=TIM0_BASE
	;@disable OCFB
	ldr r3,[r2,#TIMn_SR]
	bic r3,r3,#0x00000800
	str r3,[r2,#TIMn_SR]
	
	;@remove pending bits
	ldr r3,[r4,#EIC_FIPR]
	;@orr r3,r3,#0x00000002
	str r3,[r4,#EIC_FIPR]
	
	;@ clear f bit (looks like this isnt needed)
	;mrs r3,CPSR
	;bic r3,#0xc0
	;msr CPSR_c,r3

	MOV	PC, LR	
	

InitHwAssembly	
	;@  Setup GPIO6 - UART0 Tx pin setup (P6.9)     
	LDR 	R12, =GPIO6_BASE
	;@ GPIO_Mode_AF_PP
	LDRH	R1, [R12, #GPIO_PC0_OFS]
	ORR 	R1, R1, #GPIO_PIN_9
	STRH 	R1, [R12, #GPIO_PC0_OFS]
	
	LDRH 	R1, [R12, #GPIO_PC1_OFS]
	ORR 	R1, R1, #GPIO_PIN_9
	STRH 	R1, [R12, #GPIO_PC1_OFS]
	
	LDRH 	R1, [R12, #GPIO_PC2_OFS]
	ORR 	R1, R1, #GPIO_PIN_9
	STRH 	R1, [R12, #GPIO_PC2_OFS]

	/* update the below code with your work on last week's lab regarding GPIO */

	;@ *** modify/add-to the below lines for this assignment  ***
	LDR 	R12, =GPIO0_BASE
	;@ put some code here to configure GPIO0
	LDRH	R1, [R12, #GPIO_PC0_OFS]
	ldr r5, =GPIO_PIN_ALL
	ORR 	R1, R1, r5
	STRH 	R1, [R12, #GPIO_PC0_OFS]
	
	LDRH 	R1, [R12, #GPIO_PC1_OFS]
	;@ fill in an instruction to clear bit 0
	mov r1,#0
	STRH 	R1, [R12, #GPIO_PC1_OFS]
	
	LDRH 	R1, [R12, #GPIO_PC2_OFS]
	ORR 	R1, R1, r5
	STRH 	R1, [R12, #GPIO_PC2_OFS]
	;@ ^^^ modify the above lines ^^^
	;@  Turn on GPIO0 pin 0     
	LDR 	R12, =GPIO0_BASE
	LDRH	R1, [R12, #GPIO_PD_OFS]
	ORR 	R1, R1, #GPIO_PIN_0
	STRH 	R1, [R12, #GPIO_PD_OFS]
	
	;@ configure pin 8 of GPIO1
	;@PC0 =1
	LDR 	R12, =GPIO1_BASE
	LDRH	R1, [R12, #GPIO_PC0_OFS]
	ORR 	R1, R1, #GPIO_PIN_8
	STRH 	R1, [R12, #GPIO_PC0_OFS]
	;@PC1 =0
	LDRH	R1, [R12, #GPIO_PC1_OFS]
	BIC 	R1, R1, #GPIO_PIN_8
	STRH 	R1, [R12, #GPIO_PC1_OFS]
	;@PC2 =0
	LDRH	R1, [R12, #GPIO_PC2_OFS]
	BIC 	R1, R1, #GPIO_PIN_8
	STRH 	R1, [R12, #GPIO_PC2_OFS]
	;@configure INT0 external interrupt 101 control bits
	LDR 	R12, =CFG_BASE
	
	LDRH	R1, [R12, #CFG_EITE0]
	ORR 	R1, R1, #0x00000001;
	STRH 	R1, [R12, #CFG_EITE0]
	LDRH	R1, [R12, #CFG_EITE1]
	BIC 	R1, R1, #0x00000001
	STRH 	R1, [R12, #CFG_EITE1]
	LDRH	R1, [R12, #CFG_EITE2]
	ORR 	R1, R1, #0x00000001
	STRH 	R1, [R12, #CFG_EITE2]
	
	
	;@set up timer
	LDR r2,=TIM0_BASE
	LDR r3,=CR1_bits
	STR r3,[r2,#TIMn_CR1]
	LDR r3, =OCBR_value
	STR r3,[r2,#TIMn_OCBR];@ clock value that causes interupt

	LDR r3, =prescalar_value ;@also enables OCBIE
	STR r3,[r2,#TIMn_CR2]
	
	LDR r2, =EIC_BASE

	
	;@enable global FIQ interrupt
	MOV r3,#0x00000002
	STR r3,[r2,#EIC_ICR]
	;@enable channel 1 and 0
	MOV r3,#0x00000003
	STR r3,[r2,#EIC_FIER]
	
	
	MOV	PC, LR
		
LoopFunc
	/* 1) Update the below code with your work on last week's lab regarding GPIO. 
	   2) Once you start on the FIQ_Handler above, you can remove your work with GPIO
		here.
	*/

	;@ *** modify the below lines for this assignment  ***
	;@ *** make pins of I/O port 0 strobe back and forth between
	;@     all the Bits in the range Bit 0 to Bit 15 ***

	;@ put in a delay here
		
	;@ ^^^ modify the above lines ^^^

	B LoopFunc
	;@ MV 	PC, LR
	END
