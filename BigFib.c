/******************************************************************************
;@
;@ Student Name 1: Judd Foster
;@ Student 1 #: 301377893
;@ Student 1 (userid): juddf (email): juddf@sfu.ca
;@
;@ Student Name 2: Divyam Sharma
;@ Student 2 #: 301372345
;@ Student 2 (userid): divyams (email): divyams@sfu.ca
;@
;@ Below, edit to list any people who helped you with the code in this file,
;@      or put ‘none’ if nobody helped (the two of) you.
;@
;@ Helpers: none
;@
;@ Also, reference resources beyond the course textbooks and the course pages on Canvas
;@ that you used in making your submission.
;@
;@ Resources:  none
;@
;@% Instructions:
;@ * Put your name(s), student number(s), userid(s) in the above section.
;@ * Edit the "Helpers" line and "Resources" line.
;@ * Your group name should be "<userid1>_<userid2>" (eg. stu1_stu2)
;@ * Form groups as described at:  https://courses.cs.sfu.ca/docs/students
;@ * Submit your file to courses.cs.sfu.ca
;@
;@ Name        : BigFib.c
;@ Description : bigFib subroutine for HW5.
******************************************************************************/

#include <stdio.h>
#include <stdlib.h>

typedef unsigned int bigNumN[];

int bigAdd(bigNumN bigN0P, const bigNumN bigN1P, unsigned int maxN0Size);

int bigFib(int n, int maxSize, unsigned **bNP) {
	unsigned* bNa = malloc(4 * (1 + maxSize));			//F1
	unsigned* bNb = malloc(4 * (1 + maxSize));			//F0
	unsigned* bNc;																	//temp pointer
	unsigned i = 0;																	//for loop iterator
	int retval = 0;																	//return value

	//Boundary case
	if (maxSize == 0)
	{
		*bNP = bNb;
		free(bNa);
		return 0; //exit the function
	}
	// check for null pointer being returned.
	// return -1 if we could not allocate the required memory
	if (bNa == NULL || bNb == NULL) return -1;
	//Initialising the fibonacci numbers in an array
	*bNa = 1;
	*(bNa + 1) = 1;
	*bNb = 1;
	*(bNb + 1) = 0;
	
	for (i = 0; i < n; i++)
	{
		// bNa = bNa + bNb
		retval = bigAdd(bNa, bNb, (*bNa) + (((*bNa) + 1 <= maxSize) ? 1 : 0));
		// return -2 if the answer will be bigger than the allocated maxsize
		if (retval == -1) return -2;
		// overflow occured
		if (retval == 1)
		{
			n = i;
			break;
		}
		else
		{
			// swap the pointers
			bNc = bNb;
			bNb = bNa;
			bNa = bNc;
		}
	}
	// point the answer to bNa which we will return
	*bNP = bNb;
	// don't forget to free the other allocated memory
	free(bNa);
	free(bNc);
	return n;
}
