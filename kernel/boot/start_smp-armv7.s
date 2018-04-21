.equ	CPSR_MODE_USER,		0x10
.equ	CPSR_MODE_FIQ,		0x11
.equ	CPSR_MODE_IRQ,		0x12
.equ	CPSR_MODE_SVC,		0x13
.equ	CPSR_MODE_ABORT,	0x17
.equ	CPSR_MODE_UNDEFINED,	0x1b
.equ	CPSR_MODE_SYSTEM,	0x1f

.equ	CPSR_MODE_FIQ_DISABLE,	(1<<6)		@ F set, FIQ disabled
.equ	CPSR_MODE_IRQ_DISABLE,	(1<<7)		@ I set, IRQ disabled
.equ	CPSR_MODE_ABORT_DISABLE,(1<<8)		@ A set, ABT disabled


.globl start_core

start_core:
	mrs	r3, cpsr		/* put cpsr in r3 */
        and	r4, r3, #0x1F		/* mask off all but mode */
        cmp	r4, #0x1A		/* check for HYP (0x1A) */
        bne	done_hyp		/* skip ahead if not in HYP mode */

	/* If we're here, we are in HYP mode */
	bic	r3, r3, #0x1F		/* clear the mode bits */
					/* Setup SVC mode, IRQs disabled */
	orr	r3, #CPSR_MODE_SVC | CPSR_MODE_IRQ_DISABLE | CPSR_MODE_FIQ_DISABLE
					/* mask Abort bit */
					/* Separate as it's an invalid constant */
					/* If we try to include with above */
        orr	r3, #CPSR_MODE_ABORT_DISABLE

	adr	lr, done_pi2		/* load address we want to return to */
	msr	spsr_cxsf, r3		/* update spsr, cxsf = everything */
	msr	ELR_hyp, lr		/* Special return address when in */
					/* hypervisor mode */
	eret				/* Special return-from hypervisor */
					/* instruction */
done_hyp:
done_pi2:

	/* Get current CPUID */
	/* From the Multiprocessor Affinity Register (MPIDR) */

	/* Note, the desciprtion of MPIDR in the ARMv7 ARM does not match */
	/* well with the actual usage, which is better described in the */
	/* ARM Cortex-A7 manuals */

	mrc	p15, 0, r3, c0, c0, 5
	ands	r3, #3                  /* CPU ID is Bits 0..1 */

	/* set up system stack */
	/* core0 = 0x8000 - 0x7000 */
	/* core1 = 0x7000 - 0x6000 */
	/* core2 = 0x6000 - 0x5000 */
	/* core3 = 0x5000 - 0x4000 */
	/*  so (8-core#)<<12 */

	mov	r0,#8
	sub	r0,r3
	lsl	r0,#12
	mov	sp,r0

	mov	r0,r3			/* put cpu# in arg0 */

	b	secondary_boot_c

