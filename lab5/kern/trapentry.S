/* See COPYRIGHT for copyright information. */

#include <inc/mmu.h>
#include <inc/memlayout.h>
#include <inc/trap.h>

#include <kern/picirq.h>


###################################################################
# exceptions/interrupts
###################################################################

/* TRAPHANDLER defines a globally-visible function for handling a trap.
 * It pushes a trap number onto the stack, then jumps to _alltraps.
 * Use TRAPHANDLER for traps where the CPU automatically pushes an error code.
 *
 * You shouldn't call a TRAPHANDLER function from C, but you may
 * need to _declare_ one in C (for instance, to get a function pointer
 * during IDT setup).  You can declare the function with
 *   void NAME();
 * where NAME is the argument passed to TRAPHANDLER.
 */
#define TRAPHANDLER(name, num)						\
	.globl name;		/* define global symbol for 'name' */	\
	.type name, @function;	/* symbol type is function */		\
	.align 2;		/* align function definition */		\
	name:			/* function starts here */		\
	pushl $(num);							\
	jmp _alltraps

/* Use TRAPHANDLER_NOEC for traps where the CPU doesn't push an error code.
 * It pushes a 0 in place of the error code, so the trap frame has the same
 * format in either case.
 */
#define TRAPHANDLER_NOEC(name, num)					\
	.globl name;							\
	.type name, @function;						\
	.align 2;							\
	name:								\
	pushl $0;							\
	pushl $(num);							\
	jmp _alltraps

.text

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */
TRAPHANDLER_NOEC(handler_divide, T_DIVIDE)
TRAPHANDLER_NOEC(handler_debug, T_DEBUG)
TRAPHANDLER_NOEC(handler_nmi, T_NMI)
TRAPHANDLER_NOEC(handler_brkpt, T_BRKPT)
TRAPHANDLER_NOEC(handler_oflow, T_OFLOW)
TRAPHANDLER_NOEC(handler_bound, T_BOUND)
TRAPHANDLER_NOEC(handler_illop, T_ILLOP)
TRAPHANDLER_NOEC(handler_device, T_DEVICE)
TRAPHANDLER(handler_dblflt, T_DBLFLT)
TRAPHANDLER(handler_tss, T_TSS)
TRAPHANDLER(handler_segnp, T_SEGNP)
TRAPHANDLER(handler_stack, T_STACK)
TRAPHANDLER(handler_gpflt, T_GPFLT)
TRAPHANDLER(handler_pgflt, T_PGFLT)
TRAPHANDLER_NOEC(handler_fperr, T_FPERR)
TRAPHANDLER_NOEC(handler_align, T_ALIGN)
TRAPHANDLER_NOEC(handler_mchk, T_MCHK)
TRAPHANDLER_NOEC(handler_simderr, T_SIMDERR)

TRAPHANDLER_NOEC(handler_syscall, T_SYSCALL);	

TRAPHANDLER_NOEC(handler_timer,IRQ_OFFSET + IRQ_TIMER);
TRAPHANDLER_NOEC(handler_kbd,IRQ_OFFSET + IRQ_KBD);
TRAPHANDLER_NOEC(handler_irq2,IRQ_OFFSET + 2);
TRAPHANDLER_NOEC(handler_irq3,IRQ_OFFSET + 3);
TRAPHANDLER_NOEC(handler_serial,IRQ_OFFSET + IRQ_SERIAL);
TRAPHANDLER_NOEC(handler_irq5,IRQ_OFFSET + 5);
TRAPHANDLER_NOEC(handler_irq6,IRQ_OFFSET + 6);
TRAPHANDLER_NOEC(handler_spurious,IRQ_OFFSET + IRQ_SPURIOUS);
TRAPHANDLER_NOEC(handler_irq8,IRQ_OFFSET + 8);
TRAPHANDLER_NOEC(handler_irq9,IRQ_OFFSET + 9);
TRAPHANDLER_NOEC(handler_irq10,IRQ_OFFSET + 10);
TRAPHANDLER_NOEC(handler_irq11,IRQ_OFFSET + 11);
TRAPHANDLER_NOEC(handler_irq12,IRQ_OFFSET + 12);
TRAPHANDLER_NOEC(handler_irq13,IRQ_OFFSET + 13);
TRAPHANDLER_NOEC(handler_ide,IRQ_OFFSET + IRQ_IDE);
TRAPHANDLER_NOEC(handler_irq15,IRQ_OFFSET + 15);




.globl sysenter_handler;
.type sysenter_handler, @function;
.align 2;
sysenter_handler:
/*
 * Lab 3: Your code here for system call handling
 */
    pushl $GD_UD | 3
    pushl %ebp
    pushfl
    pushl $GD_UT | 3
    pushl %esi
    pushl $0
    pushl $T_SYSCALL
    pushl %ds
    pushl %es
    pushal
    movl $GD_KD, %eax
    movw %ax,%ds
    movw %ax,%es
    pushl %esp
    call syscall_helper
    popl %esp
    //popal
    popl %edi
    popl %esi
    popl %ebp
    popl %ebx
    popl %ebx
    popl %edx
    popl %ecx
    addl $0x4,%esp

    popl %es
    popl %ds
    addl $0x8,%esp
    movl %esi,%edx
    movl %ebp,%ecx
    sti  //open interrupt
    sysexit
    


/*
 * Lab 3: Your code here for _alltraps
 */
_alltraps:
    pushl %ds
    pushl %es
    pushal
    movl $GD_KD, %eax
    movw %ax,%ds
    movw %ax,%es
    pushl %esp
    call trap

