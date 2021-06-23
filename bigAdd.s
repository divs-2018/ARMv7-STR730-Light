;@============================================================================
;@
;@ Student Name 1: Divyam Sharma
;@ Student 1 #: 301372345
;@ Student 1 (userid): divyams (email): divyams@sfu.ca
;@
;@ Student Name 2: Judd Foster
;@ Student 2 #: 301377893
;@ Student 2 (userid): juddf (email): juddf@sfu.ca
;@
;@ Below, edit to list any people who helped you with the code in this file,
;@      or put none if nobody helped (the two of) you.
;@
;@ Helpers: none
;@
;@ Also, reference resources beyond the course textbooks and the course pages on Canvas
;@ that you used in making your submission.
;@
;@ Resources: none
;@
;@% Instructions:
;@ * Put your name(s), student number(s), userid(s) in the above section.
;@ * Edit the "Helpers" line and "Resources" line.
;@ * Your group name should be "<userid1>_<userid2>" (eg. stu1_stu2)
;@ * Form groups as described at:  https://courses.cs.sfu.ca/docs/students
;@ * Submit your file to courses.cs.sfu.ca
;@
;@ Name        : bigAdd.s
;@ Description : bigAdd subroutine for Assignment.
;@============================================================================

;@ Tabs set for 8 characters in Edit > Configuration

	GLOBAL	bigAdd
	AREA	||.text||, CODE, READONLY


; 107-41=66 lines of code for this subroutine

					; r0 is pointing to bigN0P, r1 is pointing to bigN1P, r2 = maxN0Size
bigAdd	push	{r3-r12, lr}		; push registers to stack and original link register
	ldr	r3, [r0, #0]		; load r3 with sizeBigN0P
	ldr	r4, [r1, #0]		; load r4 with sizeBigN1P
	cmp	r3, r4
	movls	r5, r4			; store the greater of the 2 values
	movhi	r5, r3
	cmp	r5, r2			; return -1 if maxn0size is less than either operand size
	mvnhi	r0, #0
	bhi	ret
	add	r6, r3, r4		; if we get here the bigN0P array has enough allocated memory to store the result
	cmp	r6, #0			; if r3 == r4 == 0 (0 + 0 = 0), return 0
	beq	nocrry
	subs	r7, r3, r4
	addpl	r5, r4, #1		; r5 is how many times we should loop (stores the lesser of r3/r4)
	addmi	r5, r3, #1
	ldrmi 	r9, [r1, #0]		; store r1's size into r0 size which is the answer size
	strmi	r9, [r0, #0]
	mov	r6, #1			; r6 is the iterator
	mov	r8, #0			; reset our register holding the carry flag
L0 	cmp	r6, r5			; test if we are done BEFORE we start
	beq	L0P
	ldr	r3, [r0, r6, lsl #2]	; load the numbers from each array
	ldr	r4, [r1, r6, lsl #2]
	bl	addOp			; perform the add operation
	b	L0			; loop until done
L0P 	cmp	r7, #0			; check if the bigAdd operation is done (operand size is equal)
	bl	setcrry			; used to reset the carry after cmp modifies it	
	bne	ndone			; if not equal, bigAdd is not done (moves into L1)
	bcc	nocrry			; if equal, check if carry is clear, if carry is clear we are done
	b	precrry
ndone	movpl	r12, r0
	movmi	r12, r1
	add	r9, r7, r7, asr #31	; abs(r7) so that subs in the L1 works properly
	eor	r7, r9, r7, asr #31
	mov	r4, #0			; pad 0
L1 	ldr	r3, [r12, r6, lsl #2]	; load the numbers from each array
	bl	addOp			; perform the add operation
	subs	r7, #1			; decrement iterator, also test if we should stop
	bne	L1			; loop until done
	cmp	r8, #0			; is r8 (carry from MSB) clear?
	beq	nocrry			; if carry is clear then always return 0				
precrry	add	r2, r2, #1		; carry is 1 if we make it here, see if there is space to store it (look at r2)
	cmp	r6, r2			; add 1 to r2 because r6 is incremented one extra time at the end of the for loop
	moveq	r0, #1			; if r6 == r2, there is no space to store the carry
	beq	ret
	ldr	r8, [r0, #0]		; update the size with the new size (which is + 1 since we're adding a carry)
	add	r8, r8, #1
	str	r8, [r0, #0]
	mov	r8, #1			; this is the actual carry word to be stored in memory
	str	r8, [r0, r6, lsl #2]	; put the carry word in the register
nocrry	mov	r0, #0
ret	pop	{r3-r12, lr}
	bx	lr
setcrry	mrs	r9, cpsr		; this block sets carry = r8
	and	r9, r9, #0xDFFFFFFF	; bit inverse of carry bit
	orr	r9, r9, r8
	msr	cpsr_f, r9
	bx	lr
addOp	push	{lr}			; store our return before branching again
	bl	setcrry			; CPSR carry = r8
	adcs	r3, r3, r4		; perform the addition
	movcs	r8, #0x20000000		; temporarily store carry into r8
	movcc	r8, #0
	str	r3, [r0, r6, lsl #2]	; store the result back into bigN0P
	add	r6, r6, #1		; move to the next word
	pop	{lr}			; move old return address back to lr
	bx	lr			; return to it

	END