
obj/kern/kernel:     file format elf32-i386


Disassembly of section .text:

f0100000 <_start+0xeffffff4>:
.globl		_start
_start = RELOC(entry)

.globl entry
entry:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fe 4f 52             	decb   0x52(%edi)
f010000b:	e4 66                	in     $0x66,%al

f010000c <entry>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 
	# physical addresses [0, 4MB).  This 4MB region will be suffice
	# until we set up our real page table in mem_init in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 20 12 00       	mov    $0x122000,%eax
	movl	%eax, %cr3
f010001a:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl	%cr0, %eax
f010001d:	0f 20 c0             	mov    %cr0,%eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
f0100020:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl	%eax, %cr0
f0100025:	0f 22 c0             	mov    %eax,%cr0

	# Now paging is enabled, but we're still running at a low EIP
	# (why is this okay?).  Jump up above KERNBASE before entering
	# C code.
	mov	$relocated, %eax
f0100028:	b8 2f 00 10 f0       	mov    $0xf010002f,%eax
	jmp	*%eax
f010002d:	ff e0                	jmp    *%eax

f010002f <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(bootstacktop),%esp
f0100034:	bc 00 20 12 f0       	mov    $0xf0122000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 39 01 00 00       	call   f0100177 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	53                   	push   %ebx
f0100044:	83 ec 14             	sub    $0x14,%esp
		monitor(NULL);
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
f0100047:	8d 5d 14             	lea    0x14(%ebp),%ebx
{
	va_list ap;

	va_start(ap, fmt);
	cprintf("kernel warning at %s:%d: ", file, line);
f010004a:	8b 45 0c             	mov    0xc(%ebp),%eax
f010004d:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100051:	8b 45 08             	mov    0x8(%ebp),%eax
f0100054:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100058:	c7 04 24 e0 7d 10 f0 	movl   $0xf0107de0,(%esp)
f010005f:	e8 a3 4a 00 00       	call   f0104b07 <cprintf>
	vcprintf(fmt, ap);
f0100064:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100068:	8b 45 10             	mov    0x10(%ebp),%eax
f010006b:	89 04 24             	mov    %eax,(%esp)
f010006e:	e8 61 4a 00 00       	call   f0104ad4 <vcprintf>
	cprintf("\n");
f0100073:	c7 04 24 d9 82 10 f0 	movl   $0xf01082d9,(%esp)
f010007a:	e8 88 4a 00 00       	call   f0104b07 <cprintf>
	va_end(ap);
}
f010007f:	83 c4 14             	add    $0x14,%esp
f0100082:	5b                   	pop    %ebx
f0100083:	5d                   	pop    %ebp
f0100084:	c3                   	ret    

f0100085 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f0100085:	55                   	push   %ebp
f0100086:	89 e5                	mov    %esp,%ebp
f0100088:	56                   	push   %esi
f0100089:	53                   	push   %ebx
f010008a:	83 ec 10             	sub    $0x10,%esp
f010008d:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f0100090:	83 3d a0 de 24 f0 00 	cmpl   $0x0,0xf024dea0
f0100097:	75 46                	jne    f01000df <_panic+0x5a>
		goto dead;
	panicstr = fmt;
f0100099:	89 35 a0 de 24 f0    	mov    %esi,0xf024dea0

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");
f010009f:	fa                   	cli    
f01000a0:	fc                   	cld    
/*
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
f01000a1:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");

	va_start(ap, fmt);
	cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f01000a4:	e8 15 76 00 00       	call   f01076be <cpunum>
f01000a9:	8b 55 0c             	mov    0xc(%ebp),%edx
f01000ac:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01000b0:	8b 55 08             	mov    0x8(%ebp),%edx
f01000b3:	89 54 24 08          	mov    %edx,0x8(%esp)
f01000b7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01000bb:	c7 04 24 38 7e 10 f0 	movl   $0xf0107e38,(%esp)
f01000c2:	e8 40 4a 00 00       	call   f0104b07 <cprintf>
	vcprintf(fmt, ap);
f01000c7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01000cb:	89 34 24             	mov    %esi,(%esp)
f01000ce:	e8 01 4a 00 00       	call   f0104ad4 <vcprintf>
	cprintf("\n");
f01000d3:	c7 04 24 d9 82 10 f0 	movl   $0xf01082d9,(%esp)
f01000da:	e8 28 4a 00 00       	call   f0104b07 <cprintf>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f01000df:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01000e6:	e8 7e 0a 00 00       	call   f0100b69 <monitor>
f01000eb:	eb f2                	jmp    f01000df <_panic+0x5a>

f01000ed <mp_main>:
}

// Setup code for APs
void
mp_main(void)
{
f01000ed:	55                   	push   %ebp
f01000ee:	89 e5                	mov    %esp,%ebp
f01000f0:	83 ec 18             	sub    $0x18,%esp
	// We are in high EIP now, safe to switch to kern_pgdir 
	lcr3(PADDR(kern_pgdir));
f01000f3:	a1 ac de 24 f0       	mov    0xf024deac,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01000f8:	89 c2                	mov    %eax,%edx
f01000fa:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01000ff:	77 20                	ja     f0100121 <mp_main+0x34>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100101:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100105:	c7 44 24 08 5c 7e 10 	movl   $0xf0107e5c,0x8(%esp)
f010010c:	f0 
f010010d:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
f0100114:	00 
f0100115:	c7 04 24 fa 7d 10 f0 	movl   $0xf0107dfa,(%esp)
f010011c:	e8 64 ff ff ff       	call   f0100085 <_panic>
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0100121:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f0100127:	0f 22 da             	mov    %edx,%cr3
	cprintf("SMP: CPU %d starting\n", cpunum());
f010012a:	e8 8f 75 00 00       	call   f01076be <cpunum>
f010012f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100133:	c7 04 24 06 7e 10 f0 	movl   $0xf0107e06,(%esp)
f010013a:	e8 c8 49 00 00       	call   f0104b07 <cprintf>

	lapic_init();
f010013f:	e8 96 75 00 00       	call   f01076da <lapic_init>
	env_init_percpu();
f0100144:	e8 17 40 00 00       	call   f0104160 <env_init_percpu>
	trap_init_percpu();
f0100149:	e8 f2 49 00 00       	call   f0104b40 <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f010014e:	66 90                	xchg   %ax,%ax
f0100150:	e8 69 75 00 00       	call   f01076be <cpunum>
f0100155:	6b d0 74             	imul   $0x74,%eax,%edx
f0100158:	81 c2 24 e0 24 f0    	add    $0xf024e024,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f010015e:	b8 01 00 00 00       	mov    $0x1,%eax
f0100163:	f0 87 02             	lock xchg %eax,(%edx)
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f0100166:	c7 04 24 80 43 12 f0 	movl   $0xf0124380,(%esp)
f010016d:	e8 13 79 00 00       	call   f0107a85 <spin_lock>
	// to start running processes on this CPU.  But make sure that
	// only one CPU can enter the scheduler at a time!
	//
	// Your code here:
        lock_kernel();
        sched_yield();
f0100172:	e8 09 58 00 00       	call   f0105980 <sched_yield>

f0100177 <i386_init>:
}


void
i386_init(void)
{
f0100177:	55                   	push   %ebp
f0100178:	89 e5                	mov    %esp,%ebp
f010017a:	56                   	push   %esi
f010017b:	53                   	push   %ebx
f010017c:	83 ec 10             	sub    $0x10,%esp
	wrmsr(0x176, (uint32_t)&sysenter_handler, 0);*/

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f010017f:	b8 04 f0 28 f0       	mov    $0xf028f004,%eax
f0100184:	2d 50 cc 24 f0       	sub    $0xf024cc50,%eax
f0100189:	89 44 24 08          	mov    %eax,0x8(%esp)
f010018d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100194:	00 
f0100195:	c7 04 24 50 cc 24 f0 	movl   $0xf024cc50,(%esp)
f010019c:	e8 75 6e 00 00       	call   f0107016 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01001a1:	e8 6f 06 00 00       	call   f0100815 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01001a6:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f01001ad:	00 
f01001ae:	c7 04 24 1c 7e 10 f0 	movl   $0xf0107e1c,(%esp)
f01001b5:	e8 4d 49 00 00       	call   f0104b07 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f01001ba:	e8 96 26 00 00       	call   f0102855 <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f01001bf:	e8 c6 3f 00 00       	call   f010418a <env_init>
	trap_init();
f01001c4:	e8 20 4a 00 00       	call   f0104be9 <trap_init>

	// Lab 4 multiprocessor initialization functions
	mp_init();
f01001c9:	e8 0c 72 00 00       	call   f01073da <mp_init>
	lapic_init();
f01001ce:	66 90                	xchg   %ax,%ax
f01001d0:	e8 05 75 00 00       	call   f01076da <lapic_init>

	// Lab 4 multitasking initialization functions
	pic_init();
f01001d5:	e8 6b 48 00 00       	call   f0104a45 <pic_init>
f01001da:	c7 04 24 80 43 12 f0 	movl   $0xf0124380,(%esp)
f01001e1:	e8 9f 78 00 00       	call   f0107a85 <spin_lock>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01001e6:	83 3d a8 de 24 f0 07 	cmpl   $0x7,0xf024dea8
f01001ed:	77 24                	ja     f0100213 <i386_init+0x9c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01001ef:	c7 44 24 0c 00 70 00 	movl   $0x7000,0xc(%esp)
f01001f6:	00 
f01001f7:	c7 44 24 08 80 7e 10 	movl   $0xf0107e80,0x8(%esp)
f01001fe:	f0 
f01001ff:	c7 44 24 04 85 00 00 	movl   $0x85,0x4(%esp)
f0100206:	00 
f0100207:	c7 04 24 fa 7d 10 f0 	movl   $0xf0107dfa,(%esp)
f010020e:	e8 72 fe ff ff       	call   f0100085 <_panic>
	void *code;
	struct Cpu *c;

	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f0100213:	b8 f6 72 10 f0       	mov    $0xf01072f6,%eax
f0100218:	2d 7c 72 10 f0       	sub    $0xf010727c,%eax
f010021d:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100221:	c7 44 24 04 7c 72 10 	movl   $0xf010727c,0x4(%esp)
f0100228:	f0 
f0100229:	c7 04 24 00 70 00 f0 	movl   $0xf0007000,(%esp)
f0100230:	e8 40 6e 00 00       	call   f0107075 <memmove>

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f0100235:	6b 05 c4 e3 24 f0 74 	imul   $0x74,0xf024e3c4,%eax
f010023c:	05 20 e0 24 f0       	add    $0xf024e020,%eax
f0100241:	3d 20 e0 24 f0       	cmp    $0xf024e020,%eax
f0100246:	76 65                	jbe    f01002ad <i386_init+0x136>
f0100248:	be 00 00 00 00       	mov    $0x0,%esi
f010024d:	bb 20 e0 24 f0       	mov    $0xf024e020,%ebx
		if (c == cpus + cpunum())  // We've started already.
f0100252:	e8 67 74 00 00       	call   f01076be <cpunum>
f0100257:	6b c0 74             	imul   $0x74,%eax,%eax
f010025a:	05 20 e0 24 f0       	add    $0xf024e020,%eax
f010025f:	39 c3                	cmp    %eax,%ebx
f0100261:	74 34                	je     f0100297 <i386_init+0x120>
			continue;

		// Tell mpentry.S what stack to use 
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f0100263:	89 f0                	mov    %esi,%eax
f0100265:	c1 f8 02             	sar    $0x2,%eax
f0100268:	69 c0 35 c2 72 4f    	imul   $0x4f72c235,%eax,%eax
f010026e:	c1 e0 0f             	shl    $0xf,%eax
f0100271:	8d 80 00 70 25 f0    	lea    -0xfda9000(%eax),%eax
f0100277:	a3 a4 de 24 f0       	mov    %eax,0xf024dea4
		// Start the CPU at mpentry_start
		lapic_startap(c->cpu_id, PADDR(code));
f010027c:	c7 44 24 04 00 70 00 	movl   $0x7000,0x4(%esp)
f0100283:	00 
f0100284:	0f b6 03             	movzbl (%ebx),%eax
f0100287:	89 04 24             	mov    %eax,(%esp)
f010028a:	e8 b5 75 00 00       	call   f0107844 <lapic_startap>
		// Wait for the CPU to finish some basic setup in mp_main()
		while(c->cpu_status != CPU_STARTED)
f010028f:	8b 43 04             	mov    0x4(%ebx),%eax
f0100292:	83 f8 01             	cmp    $0x1,%eax
f0100295:	75 f8                	jne    f010028f <i386_init+0x118>
	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f0100297:	83 c3 74             	add    $0x74,%ebx
f010029a:	83 c6 74             	add    $0x74,%esi
f010029d:	6b 05 c4 e3 24 f0 74 	imul   $0x74,0xf024e3c4,%eax
f01002a4:	05 20 e0 24 f0       	add    $0xf024e020,%eax
f01002a9:	39 c3                	cmp    %eax,%ebx
f01002ab:	72 a5                	jb     f0100252 <i386_init+0xdb>
f01002ad:	bb 00 00 00 00       	mov    $0x0,%ebx
#endif

	// Should always have idle processes at first.
	int i;
	for (i = 0; i < NCPU; i++)
		ENV_CREATE(user_idle, ENV_TYPE_IDLE);
f01002b2:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01002b9:	00 
f01002ba:	c7 44 24 04 90 89 00 	movl   $0x8990,0x4(%esp)
f01002c1:	00 
f01002c2:	c7 04 24 5e 54 1a f0 	movl   $0xf01a545e,(%esp)
f01002c9:	e8 62 45 00 00       	call   f0104830 <env_create>
	lock_kernel();
#endif

	// Should always have idle processes at first.
	int i;
	for (i = 0; i < NCPU; i++)
f01002ce:	83 c3 01             	add    $0x1,%ebx
f01002d1:	83 fb 08             	cmp    $0x8,%ebx
f01002d4:	75 dc                	jne    f01002b2 <i386_init+0x13b>
		ENV_CREATE(user_idle, ENV_TYPE_IDLE);

#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
f01002d6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01002dd:	00 
f01002de:	c7 44 24 04 ea aa 00 	movl   $0xaaea,0x4(%esp)
f01002e5:	00 
f01002e6:	c7 04 24 fc 86 23 f0 	movl   $0xf02386fc,(%esp)
f01002ed:	e8 3e 45 00 00       	call   f0104830 <env_create>
        //ENV_CREATE(user_prior,ENV_TYPE_USER);

#endif // TEST*

	// Schedule and run the first user environment!
	sched_yield();
f01002f2:	e8 89 56 00 00       	call   f0105980 <sched_yield>

f01002f7 <spinlock_test>:
static void boot_aps(void);

static volatile int test_ctr = 0;

void spinlock_test()
{
f01002f7:	55                   	push   %ebp
f01002f8:	89 e5                	mov    %esp,%ebp
f01002fa:	56                   	push   %esi
f01002fb:	53                   	push   %ebx
f01002fc:	83 ec 20             	sub    $0x20,%esp
	int i;
	volatile int interval = 0;
f01002ff:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	/* BSP give APs some time to reach this point */
	if (cpunum() == 0) {
f0100306:	e8 b3 73 00 00       	call   f01076be <cpunum>
f010030b:	85 c0                	test   %eax,%eax
f010030d:	75 10                	jne    f010031f <spinlock_test+0x28>
		while (interval++ < 10000)
f010030f:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100312:	8d 50 01             	lea    0x1(%eax),%edx
f0100315:	89 55 f4             	mov    %edx,-0xc(%ebp)
f0100318:	3d 0f 27 00 00       	cmp    $0x270f,%eax
f010031d:	7e 0c                	jle    f010032b <spinlock_test+0x34>
f010031f:	bb 00 00 00 00       	mov    $0x0,%ebx
			asm volatile("pause");
	}

	for (i=0; i<100; i++) {
		lock_kernel();
		if (test_ctr % 10000 != 0)
f0100324:	be ad 8b db 68       	mov    $0x68db8bad,%esi
f0100329:	eb 14                	jmp    f010033f <spinlock_test+0x48>
	volatile int interval = 0;

	/* BSP give APs some time to reach this point */
	if (cpunum() == 0) {
		while (interval++ < 10000)
			asm volatile("pause");
f010032b:	f3 90                	pause  
	int i;
	volatile int interval = 0;

	/* BSP give APs some time to reach this point */
	if (cpunum() == 0) {
		while (interval++ < 10000)
f010032d:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100330:	8d 50 01             	lea    0x1(%eax),%edx
f0100333:	89 55 f4             	mov    %edx,-0xc(%ebp)
f0100336:	3d 0f 27 00 00       	cmp    $0x270f,%eax
f010033b:	7e ee                	jle    f010032b <spinlock_test+0x34>
f010033d:	eb e0                	jmp    f010031f <spinlock_test+0x28>
f010033f:	c7 04 24 80 43 12 f0 	movl   $0xf0124380,(%esp)
f0100346:	e8 3a 77 00 00       	call   f0107a85 <spin_lock>
			asm volatile("pause");
	}

	for (i=0; i<100; i++) {
		lock_kernel();
		if (test_ctr % 10000 != 0)
f010034b:	8b 0d 00 d0 24 f0    	mov    0xf024d000,%ecx
f0100351:	89 c8                	mov    %ecx,%eax
f0100353:	f7 ee                	imul   %esi
f0100355:	c1 fa 0c             	sar    $0xc,%edx
f0100358:	89 c8                	mov    %ecx,%eax
f010035a:	c1 f8 1f             	sar    $0x1f,%eax
f010035d:	29 c2                	sub    %eax,%edx
f010035f:	69 d2 10 27 00 00    	imul   $0x2710,%edx,%edx
f0100365:	39 d1                	cmp    %edx,%ecx
f0100367:	74 1c                	je     f0100385 <spinlock_test+0x8e>
			panic("ticket spinlock test fail: I saw a middle value\n");
f0100369:	c7 44 24 08 a4 7e 10 	movl   $0xf0107ea4,0x8(%esp)
f0100370:	f0 
f0100371:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
f0100378:	00 
f0100379:	c7 04 24 fa 7d 10 f0 	movl   $0xf0107dfa,(%esp)
f0100380:	e8 00 fd ff ff       	call   f0100085 <_panic>
		interval = 0;
f0100385:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
		while (interval++ < 10000)
f010038c:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010038f:	8d 50 01             	lea    0x1(%eax),%edx
f0100392:	89 55 f4             	mov    %edx,-0xc(%ebp)
f0100395:	3d 0f 27 00 00       	cmp    $0x270f,%eax
f010039a:	7f 1d                	jg     f01003b9 <spinlock_test+0xc2>
			test_ctr++;
f010039c:	a1 00 d0 24 f0       	mov    0xf024d000,%eax
f01003a1:	83 c0 01             	add    $0x1,%eax
f01003a4:	a3 00 d0 24 f0       	mov    %eax,0xf024d000
	for (i=0; i<100; i++) {
		lock_kernel();
		if (test_ctr % 10000 != 0)
			panic("ticket spinlock test fail: I saw a middle value\n");
		interval = 0;
		while (interval++ < 10000)
f01003a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01003ac:	8d 50 01             	lea    0x1(%eax),%edx
f01003af:	89 55 f4             	mov    %edx,-0xc(%ebp)
f01003b2:	3d 0f 27 00 00       	cmp    $0x270f,%eax
f01003b7:	7e e3                	jle    f010039c <spinlock_test+0xa5>
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f01003b9:	c7 04 24 80 43 12 f0 	movl   $0xf0124380,(%esp)
f01003c0:	e8 a7 75 00 00       	call   f010796c <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f01003c5:	f3 90                	pause  
	if (cpunum() == 0) {
		while (interval++ < 10000)
			asm volatile("pause");
	}

	for (i=0; i<100; i++) {
f01003c7:	83 c3 01             	add    $0x1,%ebx
f01003ca:	83 fb 64             	cmp    $0x64,%ebx
f01003cd:	0f 85 6c ff ff ff    	jne    f010033f <spinlock_test+0x48>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f01003d3:	c7 04 24 80 43 12 f0 	movl   $0xf0124380,(%esp)
f01003da:	e8 a6 76 00 00       	call   f0107a85 <spin_lock>
		while (interval++ < 10000)
			test_ctr++;
		unlock_kernel();
	}
	lock_kernel();
	cprintf("spinlock_test() succeeded on CPU %d!\n", cpunum());
f01003df:	e8 da 72 00 00       	call   f01076be <cpunum>
f01003e4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01003e8:	c7 04 24 d8 7e 10 f0 	movl   $0xf0107ed8,(%esp)
f01003ef:	e8 13 47 00 00       	call   f0104b07 <cprintf>
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f01003f4:	c7 04 24 80 43 12 f0 	movl   $0xf0124380,(%esp)
f01003fb:	e8 6c 75 00 00       	call   f010796c <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0100400:	f3 90                	pause  
	unlock_kernel();
}
f0100402:	83 c4 20             	add    $0x20,%esp
f0100405:	5b                   	pop    %ebx
f0100406:	5e                   	pop    %esi
f0100407:	5d                   	pop    %ebp
f0100408:	c3                   	ret    
f0100409:	00 00                	add    %al,(%eax)
f010040b:	00 00                	add    %al,(%eax)
f010040d:	00 00                	add    %al,(%eax)
	...

f0100410 <delay>:
static void cons_putc(int c);

// Stupid I/O delay routine necessitated by historical PC design flaws
static void
delay(void)
{
f0100410:	55                   	push   %ebp
f0100411:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100413:	ba 84 00 00 00       	mov    $0x84,%edx
f0100418:	ec                   	in     (%dx),%al
f0100419:	ec                   	in     (%dx),%al
f010041a:	ec                   	in     (%dx),%al
f010041b:	ec                   	in     (%dx),%al
	inb(0x84);
	inb(0x84);
	inb(0x84);
	inb(0x84);
}
f010041c:	5d                   	pop    %ebp
f010041d:	c3                   	ret    

f010041e <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f010041e:	55                   	push   %ebp
f010041f:	89 e5                	mov    %esp,%ebp
f0100421:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100426:	ec                   	in     (%dx),%al
f0100427:	89 c2                	mov    %eax,%edx
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f0100429:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010042e:	f6 c2 01             	test   $0x1,%dl
f0100431:	74 09                	je     f010043c <serial_proc_data+0x1e>
f0100433:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100438:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f0100439:	0f b6 c0             	movzbl %al,%eax
}
f010043c:	5d                   	pop    %ebp
f010043d:	c3                   	ret    

f010043e <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f010043e:	55                   	push   %ebp
f010043f:	89 e5                	mov    %esp,%ebp
f0100441:	57                   	push   %edi
f0100442:	56                   	push   %esi
f0100443:	53                   	push   %ebx
f0100444:	83 ec 0c             	sub    $0xc,%esp
f0100447:	89 c6                	mov    %eax,%esi
	int c;

	while ((c = (*proc)()) != -1) {
		if (c == 0)
			continue;
		cons.buf[cons.wpos++] = c;
f0100449:	bb 44 d2 24 f0       	mov    $0xf024d244,%ebx
f010044e:	bf 40 d0 24 f0       	mov    $0xf024d040,%edi
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f0100453:	eb 1e                	jmp    f0100473 <cons_intr+0x35>
		if (c == 0)
f0100455:	85 c0                	test   %eax,%eax
f0100457:	74 1a                	je     f0100473 <cons_intr+0x35>
			continue;
		cons.buf[cons.wpos++] = c;
f0100459:	8b 13                	mov    (%ebx),%edx
f010045b:	88 04 17             	mov    %al,(%edi,%edx,1)
f010045e:	8d 42 01             	lea    0x1(%edx),%eax
		if (cons.wpos == CONSBUFSIZE)
f0100461:	3d 00 02 00 00       	cmp    $0x200,%eax
			cons.wpos = 0;
f0100466:	0f 94 c2             	sete   %dl
f0100469:	0f b6 d2             	movzbl %dl,%edx
f010046c:	83 ea 01             	sub    $0x1,%edx
f010046f:	21 d0                	and    %edx,%eax
f0100471:	89 03                	mov    %eax,(%ebx)
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f0100473:	ff d6                	call   *%esi
f0100475:	83 f8 ff             	cmp    $0xffffffff,%eax
f0100478:	75 db                	jne    f0100455 <cons_intr+0x17>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f010047a:	83 c4 0c             	add    $0xc,%esp
f010047d:	5b                   	pop    %ebx
f010047e:	5e                   	pop    %esi
f010047f:	5f                   	pop    %edi
f0100480:	5d                   	pop    %ebp
f0100481:	c3                   	ret    

f0100482 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f0100482:	55                   	push   %ebp
f0100483:	89 e5                	mov    %esp,%ebp
f0100485:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f0100488:	b8 1a 07 10 f0       	mov    $0xf010071a,%eax
f010048d:	e8 ac ff ff ff       	call   f010043e <cons_intr>
}
f0100492:	c9                   	leave  
f0100493:	c3                   	ret    

f0100494 <serial_intr>:
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f0100494:	55                   	push   %ebp
f0100495:	89 e5                	mov    %esp,%ebp
f0100497:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
f010049a:	83 3d 24 d0 24 f0 00 	cmpl   $0x0,0xf024d024
f01004a1:	74 0a                	je     f01004ad <serial_intr+0x19>
		cons_intr(serial_proc_data);
f01004a3:	b8 1e 04 10 f0       	mov    $0xf010041e,%eax
f01004a8:	e8 91 ff ff ff       	call   f010043e <cons_intr>
}
f01004ad:	c9                   	leave  
f01004ae:	c3                   	ret    

f01004af <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f01004af:	55                   	push   %ebp
f01004b0:	89 e5                	mov    %esp,%ebp
f01004b2:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f01004b5:	e8 da ff ff ff       	call   f0100494 <serial_intr>
	kbd_intr();
f01004ba:	e8 c3 ff ff ff       	call   f0100482 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f01004bf:	8b 15 40 d2 24 f0    	mov    0xf024d240,%edx
f01004c5:	b8 00 00 00 00       	mov    $0x0,%eax
f01004ca:	3b 15 44 d2 24 f0    	cmp    0xf024d244,%edx
f01004d0:	74 21                	je     f01004f3 <cons_getc+0x44>
		c = cons.buf[cons.rpos++];
f01004d2:	0f b6 82 40 d0 24 f0 	movzbl -0xfdb2fc0(%edx),%eax
f01004d9:	83 c2 01             	add    $0x1,%edx
		if (cons.rpos == CONSBUFSIZE)
f01004dc:	81 fa 00 02 00 00    	cmp    $0x200,%edx
			cons.rpos = 0;
f01004e2:	0f 94 c1             	sete   %cl
f01004e5:	0f b6 c9             	movzbl %cl,%ecx
f01004e8:	83 e9 01             	sub    $0x1,%ecx
f01004eb:	21 ca                	and    %ecx,%edx
f01004ed:	89 15 40 d2 24 f0    	mov    %edx,0xf024d240
		return c;
	}
	return 0;
}
f01004f3:	c9                   	leave  
f01004f4:	c3                   	ret    

f01004f5 <getchar>:
	cons_putc(c);
}

int
getchar(void)
{
f01004f5:	55                   	push   %ebp
f01004f6:	89 e5                	mov    %esp,%ebp
f01004f8:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f01004fb:	e8 af ff ff ff       	call   f01004af <cons_getc>
f0100500:	85 c0                	test   %eax,%eax
f0100502:	74 f7                	je     f01004fb <getchar+0x6>
		/* do nothing */;
	return c;
}
f0100504:	c9                   	leave  
f0100505:	c3                   	ret    

f0100506 <iscons>:

int
iscons(int fdnum)
{
f0100506:	55                   	push   %ebp
f0100507:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f0100509:	b8 01 00 00 00       	mov    $0x1,%eax
f010050e:	5d                   	pop    %ebp
f010050f:	c3                   	ret    

f0100510 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f0100510:	55                   	push   %ebp
f0100511:	89 e5                	mov    %esp,%ebp
f0100513:	57                   	push   %edi
f0100514:	56                   	push   %esi
f0100515:	53                   	push   %ebx
f0100516:	83 ec 2c             	sub    $0x2c,%esp
f0100519:	89 c7                	mov    %eax,%edi
f010051b:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100520:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;
	
	for (i = 0;
f0100521:	a8 20                	test   $0x20,%al
f0100523:	75 21                	jne    f0100546 <cons_putc+0x36>
f0100525:	bb 00 00 00 00       	mov    $0x0,%ebx
f010052a:	be fd 03 00 00       	mov    $0x3fd,%esi
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
		delay();
f010052f:	e8 dc fe ff ff       	call   f0100410 <delay>
f0100534:	89 f2                	mov    %esi,%edx
f0100536:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;
	
	for (i = 0;
f0100537:	a8 20                	test   $0x20,%al
f0100539:	75 0b                	jne    f0100546 <cons_putc+0x36>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
f010053b:	83 c3 01             	add    $0x1,%ebx
static void
serial_putc(int c)
{
	int i;
	
	for (i = 0;
f010053e:	81 fb 00 32 00 00    	cmp    $0x3200,%ebx
f0100544:	75 e9                	jne    f010052f <cons_putc+0x1f>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
		delay();
	
	outb(COM1 + COM_TX, c);
f0100546:	89 fa                	mov    %edi,%edx
f0100548:	89 f8                	mov    %edi,%eax
f010054a:	88 55 e7             	mov    %dl,-0x19(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010054d:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100552:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100553:	b2 79                	mov    $0x79,%dl
f0100555:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f0100556:	84 c0                	test   %al,%al
f0100558:	78 21                	js     f010057b <cons_putc+0x6b>
f010055a:	bb 00 00 00 00       	mov    $0x0,%ebx
f010055f:	be 79 03 00 00       	mov    $0x379,%esi
		delay();
f0100564:	e8 a7 fe ff ff       	call   f0100410 <delay>
f0100569:	89 f2                	mov    %esi,%edx
f010056b:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f010056c:	84 c0                	test   %al,%al
f010056e:	78 0b                	js     f010057b <cons_putc+0x6b>
f0100570:	83 c3 01             	add    $0x1,%ebx
f0100573:	81 fb 00 32 00 00    	cmp    $0x3200,%ebx
f0100579:	75 e9                	jne    f0100564 <cons_putc+0x54>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010057b:	ba 78 03 00 00       	mov    $0x378,%edx
f0100580:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f0100584:	ee                   	out    %al,(%dx)
f0100585:	b2 7a                	mov    $0x7a,%dl
f0100587:	b8 0d 00 00 00       	mov    $0xd,%eax
f010058c:	ee                   	out    %al,(%dx)
f010058d:	b8 08 00 00 00       	mov    $0x8,%eax
f0100592:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f0100593:	f7 c7 00 ff ff ff    	test   $0xffffff00,%edi
f0100599:	75 06                	jne    f01005a1 <cons_putc+0x91>
		c |= 0x0700;
f010059b:	81 cf 00 07 00 00    	or     $0x700,%edi

	switch (c & 0xff) {
f01005a1:	89 f8                	mov    %edi,%eax
f01005a3:	25 ff 00 00 00       	and    $0xff,%eax
f01005a8:	83 f8 09             	cmp    $0x9,%eax
f01005ab:	0f 84 83 00 00 00    	je     f0100634 <cons_putc+0x124>
f01005b1:	83 f8 09             	cmp    $0x9,%eax
f01005b4:	7f 0c                	jg     f01005c2 <cons_putc+0xb2>
f01005b6:	83 f8 08             	cmp    $0x8,%eax
f01005b9:	0f 85 a9 00 00 00    	jne    f0100668 <cons_putc+0x158>
f01005bf:	90                   	nop
f01005c0:	eb 18                	jmp    f01005da <cons_putc+0xca>
f01005c2:	83 f8 0a             	cmp    $0xa,%eax
f01005c5:	8d 76 00             	lea    0x0(%esi),%esi
f01005c8:	74 40                	je     f010060a <cons_putc+0xfa>
f01005ca:	83 f8 0d             	cmp    $0xd,%eax
f01005cd:	8d 76 00             	lea    0x0(%esi),%esi
f01005d0:	0f 85 92 00 00 00    	jne    f0100668 <cons_putc+0x158>
f01005d6:	66 90                	xchg   %ax,%ax
f01005d8:	eb 38                	jmp    f0100612 <cons_putc+0x102>
	case '\b':
		if (crt_pos > 0) {
f01005da:	0f b7 05 30 d0 24 f0 	movzwl 0xf024d030,%eax
f01005e1:	66 85 c0             	test   %ax,%ax
f01005e4:	0f 84 e8 00 00 00    	je     f01006d2 <cons_putc+0x1c2>
			crt_pos--;
f01005ea:	83 e8 01             	sub    $0x1,%eax
f01005ed:	66 a3 30 d0 24 f0    	mov    %ax,0xf024d030
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01005f3:	0f b7 c0             	movzwl %ax,%eax
f01005f6:	66 81 e7 00 ff       	and    $0xff00,%di
f01005fb:	83 cf 20             	or     $0x20,%edi
f01005fe:	8b 15 2c d0 24 f0    	mov    0xf024d02c,%edx
f0100604:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f0100608:	eb 7b                	jmp    f0100685 <cons_putc+0x175>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f010060a:	66 83 05 30 d0 24 f0 	addw   $0x50,0xf024d030
f0100611:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f0100612:	0f b7 05 30 d0 24 f0 	movzwl 0xf024d030,%eax
f0100619:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f010061f:	c1 e8 10             	shr    $0x10,%eax
f0100622:	66 c1 e8 06          	shr    $0x6,%ax
f0100626:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0100629:	c1 e0 04             	shl    $0x4,%eax
f010062c:	66 a3 30 d0 24 f0    	mov    %ax,0xf024d030
f0100632:	eb 51                	jmp    f0100685 <cons_putc+0x175>
		break;
	case '\t':
		cons_putc(' ');
f0100634:	b8 20 00 00 00       	mov    $0x20,%eax
f0100639:	e8 d2 fe ff ff       	call   f0100510 <cons_putc>
		cons_putc(' ');
f010063e:	b8 20 00 00 00       	mov    $0x20,%eax
f0100643:	e8 c8 fe ff ff       	call   f0100510 <cons_putc>
		cons_putc(' ');
f0100648:	b8 20 00 00 00       	mov    $0x20,%eax
f010064d:	e8 be fe ff ff       	call   f0100510 <cons_putc>
		cons_putc(' ');
f0100652:	b8 20 00 00 00       	mov    $0x20,%eax
f0100657:	e8 b4 fe ff ff       	call   f0100510 <cons_putc>
		cons_putc(' ');
f010065c:	b8 20 00 00 00       	mov    $0x20,%eax
f0100661:	e8 aa fe ff ff       	call   f0100510 <cons_putc>
f0100666:	eb 1d                	jmp    f0100685 <cons_putc+0x175>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f0100668:	0f b7 05 30 d0 24 f0 	movzwl 0xf024d030,%eax
f010066f:	0f b7 c8             	movzwl %ax,%ecx
f0100672:	8b 15 2c d0 24 f0    	mov    0xf024d02c,%edx
f0100678:	66 89 3c 4a          	mov    %di,(%edx,%ecx,2)
f010067c:	83 c0 01             	add    $0x1,%eax
f010067f:	66 a3 30 d0 24 f0    	mov    %ax,0xf024d030
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100685:	66 81 3d 30 d0 24 f0 	cmpw   $0x7cf,0xf024d030
f010068c:	cf 07 
f010068e:	76 42                	jbe    f01006d2 <cons_putc+0x1c2>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100690:	a1 2c d0 24 f0       	mov    0xf024d02c,%eax
f0100695:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
f010069c:	00 
f010069d:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f01006a3:	89 54 24 04          	mov    %edx,0x4(%esp)
f01006a7:	89 04 24             	mov    %eax,(%esp)
f01006aa:	e8 c6 69 00 00       	call   f0107075 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f01006af:	8b 15 2c d0 24 f0    	mov    0xf024d02c,%edx
f01006b5:	b8 80 07 00 00       	mov    $0x780,%eax
f01006ba:	66 c7 04 42 20 07    	movw   $0x720,(%edx,%eax,2)
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01006c0:	83 c0 01             	add    $0x1,%eax
f01006c3:	3d d0 07 00 00       	cmp    $0x7d0,%eax
f01006c8:	75 f0                	jne    f01006ba <cons_putc+0x1aa>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f01006ca:	66 83 2d 30 d0 24 f0 	subw   $0x50,0xf024d030
f01006d1:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f01006d2:	8b 0d 28 d0 24 f0    	mov    0xf024d028,%ecx
f01006d8:	89 cb                	mov    %ecx,%ebx
f01006da:	b8 0e 00 00 00       	mov    $0xe,%eax
f01006df:	89 ca                	mov    %ecx,%edx
f01006e1:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01006e2:	0f b7 35 30 d0 24 f0 	movzwl 0xf024d030,%esi
f01006e9:	83 c1 01             	add    $0x1,%ecx
f01006ec:	89 f0                	mov    %esi,%eax
f01006ee:	66 c1 e8 08          	shr    $0x8,%ax
f01006f2:	89 ca                	mov    %ecx,%edx
f01006f4:	ee                   	out    %al,(%dx)
f01006f5:	b8 0f 00 00 00       	mov    $0xf,%eax
f01006fa:	89 da                	mov    %ebx,%edx
f01006fc:	ee                   	out    %al,(%dx)
f01006fd:	89 f0                	mov    %esi,%eax
f01006ff:	89 ca                	mov    %ecx,%edx
f0100701:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f0100702:	83 c4 2c             	add    $0x2c,%esp
f0100705:	5b                   	pop    %ebx
f0100706:	5e                   	pop    %esi
f0100707:	5f                   	pop    %edi
f0100708:	5d                   	pop    %ebp
f0100709:	c3                   	ret    

f010070a <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f010070a:	55                   	push   %ebp
f010070b:	89 e5                	mov    %esp,%ebp
f010070d:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f0100710:	8b 45 08             	mov    0x8(%ebp),%eax
f0100713:	e8 f8 fd ff ff       	call   f0100510 <cons_putc>
}
f0100718:	c9                   	leave  
f0100719:	c3                   	ret    

f010071a <kbd_proc_data>:
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f010071a:	55                   	push   %ebp
f010071b:	89 e5                	mov    %esp,%ebp
f010071d:	53                   	push   %ebx
f010071e:	83 ec 14             	sub    $0x14,%esp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100721:	ba 64 00 00 00       	mov    $0x64,%edx
f0100726:	ec                   	in     (%dx),%al
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f0100727:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f010072c:	a8 01                	test   $0x1,%al
f010072e:	0f 84 d9 00 00 00    	je     f010080d <kbd_proc_data+0xf3>
f0100734:	b2 60                	mov    $0x60,%dl
f0100736:	ec                   	in     (%dx),%al
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f0100737:	3c e0                	cmp    $0xe0,%al
f0100739:	75 11                	jne    f010074c <kbd_proc_data+0x32>
		// E0 escape character
		shift |= E0ESC;
f010073b:	83 0d 20 d0 24 f0 40 	orl    $0x40,0xf024d020
f0100742:	bb 00 00 00 00       	mov    $0x0,%ebx
		return 0;
f0100747:	e9 c1 00 00 00       	jmp    f010080d <kbd_proc_data+0xf3>
	} else if (data & 0x80) {
f010074c:	84 c0                	test   %al,%al
f010074e:	79 32                	jns    f0100782 <kbd_proc_data+0x68>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f0100750:	8b 15 20 d0 24 f0    	mov    0xf024d020,%edx
f0100756:	f6 c2 40             	test   $0x40,%dl
f0100759:	75 03                	jne    f010075e <kbd_proc_data+0x44>
f010075b:	83 e0 7f             	and    $0x7f,%eax
		shift &= ~(shiftcode[data] | E0ESC);
f010075e:	0f b6 c0             	movzbl %al,%eax
f0100761:	0f b6 80 40 7f 10 f0 	movzbl -0xfef80c0(%eax),%eax
f0100768:	83 c8 40             	or     $0x40,%eax
f010076b:	0f b6 c0             	movzbl %al,%eax
f010076e:	f7 d0                	not    %eax
f0100770:	21 c2                	and    %eax,%edx
f0100772:	89 15 20 d0 24 f0    	mov    %edx,0xf024d020
f0100778:	bb 00 00 00 00       	mov    $0x0,%ebx
		return 0;
f010077d:	e9 8b 00 00 00       	jmp    f010080d <kbd_proc_data+0xf3>
	} else if (shift & E0ESC) {
f0100782:	8b 15 20 d0 24 f0    	mov    0xf024d020,%edx
f0100788:	f6 c2 40             	test   $0x40,%dl
f010078b:	74 0c                	je     f0100799 <kbd_proc_data+0x7f>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f010078d:	83 c8 80             	or     $0xffffff80,%eax
		shift &= ~E0ESC;
f0100790:	83 e2 bf             	and    $0xffffffbf,%edx
f0100793:	89 15 20 d0 24 f0    	mov    %edx,0xf024d020
	}

	shift |= shiftcode[data];
f0100799:	0f b6 c0             	movzbl %al,%eax
	shift ^= togglecode[data];
f010079c:	0f b6 90 40 7f 10 f0 	movzbl -0xfef80c0(%eax),%edx
f01007a3:	0b 15 20 d0 24 f0    	or     0xf024d020,%edx
f01007a9:	0f b6 88 40 80 10 f0 	movzbl -0xfef7fc0(%eax),%ecx
f01007b0:	31 ca                	xor    %ecx,%edx
f01007b2:	89 15 20 d0 24 f0    	mov    %edx,0xf024d020

	c = charcode[shift & (CTL | SHIFT)][data];
f01007b8:	89 d1                	mov    %edx,%ecx
f01007ba:	83 e1 03             	and    $0x3,%ecx
f01007bd:	8b 0c 8d 40 81 10 f0 	mov    -0xfef7ec0(,%ecx,4),%ecx
f01007c4:	0f b6 1c 01          	movzbl (%ecx,%eax,1),%ebx
	if (shift & CAPSLOCK) {
f01007c8:	f6 c2 08             	test   $0x8,%dl
f01007cb:	74 1a                	je     f01007e7 <kbd_proc_data+0xcd>
		if ('a' <= c && c <= 'z')
f01007cd:	89 d9                	mov    %ebx,%ecx
f01007cf:	8d 43 9f             	lea    -0x61(%ebx),%eax
f01007d2:	83 f8 19             	cmp    $0x19,%eax
f01007d5:	77 05                	ja     f01007dc <kbd_proc_data+0xc2>
			c += 'A' - 'a';
f01007d7:	83 eb 20             	sub    $0x20,%ebx
f01007da:	eb 0b                	jmp    f01007e7 <kbd_proc_data+0xcd>
		else if ('A' <= c && c <= 'Z')
f01007dc:	83 e9 41             	sub    $0x41,%ecx
f01007df:	83 f9 19             	cmp    $0x19,%ecx
f01007e2:	77 03                	ja     f01007e7 <kbd_proc_data+0xcd>
			c += 'a' - 'A';
f01007e4:	83 c3 20             	add    $0x20,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01007e7:	f7 d2                	not    %edx
f01007e9:	f6 c2 06             	test   $0x6,%dl
f01007ec:	75 1f                	jne    f010080d <kbd_proc_data+0xf3>
f01007ee:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f01007f4:	75 17                	jne    f010080d <kbd_proc_data+0xf3>
		cprintf("Rebooting!\n");
f01007f6:	c7 04 24 fe 7e 10 f0 	movl   $0xf0107efe,(%esp)
f01007fd:	e8 05 43 00 00       	call   f0104b07 <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100802:	ba 92 00 00 00       	mov    $0x92,%edx
f0100807:	b8 03 00 00 00       	mov    $0x3,%eax
f010080c:	ee                   	out    %al,(%dx)
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f010080d:	89 d8                	mov    %ebx,%eax
f010080f:	83 c4 14             	add    $0x14,%esp
f0100812:	5b                   	pop    %ebx
f0100813:	5d                   	pop    %ebp
f0100814:	c3                   	ret    

f0100815 <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f0100815:	55                   	push   %ebp
f0100816:	89 e5                	mov    %esp,%ebp
f0100818:	57                   	push   %edi
f0100819:	56                   	push   %esi
f010081a:	53                   	push   %ebx
f010081b:	83 ec 1c             	sub    $0x1c,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f010081e:	b8 00 80 0b f0       	mov    $0xf00b8000,%eax
f0100823:	0f b7 10             	movzwl (%eax),%edx
	*cp = (uint16_t) 0xA55A;
f0100826:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
	if (*cp != 0xA55A) {
f010082b:	0f b7 00             	movzwl (%eax),%eax
f010082e:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100832:	74 11                	je     f0100845 <cons_init+0x30>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f0100834:	c7 05 28 d0 24 f0 b4 	movl   $0x3b4,0xf024d028
f010083b:	03 00 00 
f010083e:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f0100843:	eb 16                	jmp    f010085b <cons_init+0x46>
	} else {
		*cp = was;
f0100845:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f010084c:	c7 05 28 d0 24 f0 d4 	movl   $0x3d4,0xf024d028
f0100853:	03 00 00 
f0100856:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
	}
	
	/* Extract cursor location */
	outb(addr_6845, 14);
f010085b:	8b 0d 28 d0 24 f0    	mov    0xf024d028,%ecx
f0100861:	89 cb                	mov    %ecx,%ebx
f0100863:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100868:	89 ca                	mov    %ecx,%edx
f010086a:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f010086b:	83 c1 01             	add    $0x1,%ecx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010086e:	89 ca                	mov    %ecx,%edx
f0100870:	ec                   	in     (%dx),%al
f0100871:	0f b6 f8             	movzbl %al,%edi
f0100874:	c1 e7 08             	shl    $0x8,%edi
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100877:	b8 0f 00 00 00       	mov    $0xf,%eax
f010087c:	89 da                	mov    %ebx,%edx
f010087e:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010087f:	89 ca                	mov    %ecx,%edx
f0100881:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f0100882:	89 35 2c d0 24 f0    	mov    %esi,0xf024d02c
	crt_pos = pos;
f0100888:	0f b6 c8             	movzbl %al,%ecx
f010088b:	09 cf                	or     %ecx,%edi
f010088d:	66 89 3d 30 d0 24 f0 	mov    %di,0xf024d030

static void
kbd_init(void)
{
	// Drain the kbd buffer so that Bochs generates interrupts.
	kbd_intr();
f0100894:	e8 e9 fb ff ff       	call   f0100482 <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<1));
f0100899:	0f b7 05 70 43 12 f0 	movzwl 0xf0124370,%eax
f01008a0:	25 fd ff 00 00       	and    $0xfffd,%eax
f01008a5:	89 04 24             	mov    %eax,(%esp)
f01008a8:	e8 27 41 00 00       	call   f01049d4 <irq_setmask_8259A>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01008ad:	bb fa 03 00 00       	mov    $0x3fa,%ebx
f01008b2:	b8 00 00 00 00       	mov    $0x0,%eax
f01008b7:	89 da                	mov    %ebx,%edx
f01008b9:	ee                   	out    %al,(%dx)
f01008ba:	b2 fb                	mov    $0xfb,%dl
f01008bc:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f01008c1:	ee                   	out    %al,(%dx)
f01008c2:	b9 f8 03 00 00       	mov    $0x3f8,%ecx
f01008c7:	b8 0c 00 00 00       	mov    $0xc,%eax
f01008cc:	89 ca                	mov    %ecx,%edx
f01008ce:	ee                   	out    %al,(%dx)
f01008cf:	b2 f9                	mov    $0xf9,%dl
f01008d1:	b8 00 00 00 00       	mov    $0x0,%eax
f01008d6:	ee                   	out    %al,(%dx)
f01008d7:	b2 fb                	mov    $0xfb,%dl
f01008d9:	b8 03 00 00 00       	mov    $0x3,%eax
f01008de:	ee                   	out    %al,(%dx)
f01008df:	b2 fc                	mov    $0xfc,%dl
f01008e1:	b8 00 00 00 00       	mov    $0x0,%eax
f01008e6:	ee                   	out    %al,(%dx)
f01008e7:	b2 f9                	mov    $0xf9,%dl
f01008e9:	b8 01 00 00 00       	mov    $0x1,%eax
f01008ee:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01008ef:	b2 fd                	mov    $0xfd,%dl
f01008f1:	ec                   	in     (%dx),%al
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f01008f2:	3c ff                	cmp    $0xff,%al
f01008f4:	0f 95 c0             	setne  %al
f01008f7:	0f b6 f0             	movzbl %al,%esi
f01008fa:	89 35 24 d0 24 f0    	mov    %esi,0xf024d024
f0100900:	89 da                	mov    %ebx,%edx
f0100902:	ec                   	in     (%dx),%al
f0100903:	89 ca                	mov    %ecx,%edx
f0100905:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f0100906:	85 f6                	test   %esi,%esi
f0100908:	75 0c                	jne    f0100916 <cons_init+0x101>
		cprintf("Serial port does not exist!\n");
f010090a:	c7 04 24 0a 7f 10 f0 	movl   $0xf0107f0a,(%esp)
f0100911:	e8 f1 41 00 00       	call   f0104b07 <cprintf>
}
f0100916:	83 c4 1c             	add    $0x1c,%esp
f0100919:	5b                   	pop    %ebx
f010091a:	5e                   	pop    %esi
f010091b:	5f                   	pop    %edi
f010091c:	5d                   	pop    %ebp
f010091d:	c3                   	ret    
	...

f0100920 <rdtsc>:
		(end-entry+1023)/1024);
	return 0;
}


static uint64_t rdtsc() {
f0100920:	55                   	push   %ebp
f0100921:	89 e5                	mov    %esp,%ebp
    uint32_t lo,hi;
   __asm__ __volatile__
f0100923:	0f 31                	rdtsc  
   (
      "rdtsc":"=a"(lo),"=d"(hi)
   );
   return (uint64_t) hi<<32|lo;    
}
f0100925:	5d                   	pop    %ebp
f0100926:	c3                   	ret    

f0100927 <read_eip>:
// return EIP of caller.
// does not work if inlined.
// putting at the end of the file seems to prevent inlining.
unsigned
read_eip()
{
f0100927:	55                   	push   %ebp
f0100928:	89 e5                	mov    %esp,%ebp
	uint32_t callerpc;
	__asm __volatile("movl 4(%%ebp), %0" : "=r" (callerpc));
f010092a:	8b 45 04             	mov    0x4(%ebp),%eax
	return callerpc;
}
f010092d:	5d                   	pop    %ebp
f010092e:	c3                   	ret    

f010092f <start_overflow>:
    cprintf("Overflow success\n");
}

void
start_overflow(void)
{
f010092f:	55                   	push   %ebp
f0100930:	89 e5                	mov    %esp,%ebp
f0100932:	57                   	push   %edi
f0100933:	56                   	push   %esi
f0100934:	53                   	push   %ebx
f0100935:	81 ec 3c 01 00 00    	sub    $0x13c,%esp
    // you augmented in the "Exercise 9" to do this job.

    // hint: You can use the read_pretaddr function to retrieve 
    //       the pointer to the function call return address;

    char str[256] = {};
f010093b:	8d bd e8 fe ff ff    	lea    -0x118(%ebp),%edi
f0100941:	b9 40 00 00 00       	mov    $0x40,%ecx
f0100946:	b8 00 00 00 00       	mov    $0x0,%eax
f010094b:	f3 ab                	rep stos %eax,%es:(%edi)
// Lab1 only
// read the pointer to the retaddr on the stack
static uint32_t
read_pretaddr() {
    uint32_t pretaddr;
    __asm __volatile("leal 4(%%ebp), %0" : "=r" (pretaddr)); 
f010094d:	8d 45 04             	lea    0x4(%ebp),%eax
f0100950:	89 85 d4 fe ff ff    	mov    %eax,-0x12c(%ebp)
    char str[256] = {};
    int nstr = 0;
    char *pret_addr;
    int i = 0;
    pret_addr = (char*)read_pretaddr();
    uint32_t oldret = *((uint32_t*)pret_addr);
f0100956:	8b 00                	mov    (%eax),%eax
f0100958:	89 85 e4 fe ff ff    	mov    %eax,-0x11c(%ebp)
    uint32_t overflowaddr = (uint32_t)do_overflow;
f010095e:	c7 85 e0 fe ff ff 5d 	movl   $0xf0100a5d,-0x120(%ebp)
f0100965:	0a 10 f0 
f0100968:	be 00 00 00 00       	mov    $0x0,%esi
    for(i = 0;i<4;i++){
f010096d:	bf 00 00 00 00       	mov    $0x0,%edi
       unsigned int j;
       for(j = 0;j<256;j++)
           str[j] = 0;
f0100972:	8d 9d e8 fe ff ff    	lea    -0x118(%ebp),%ebx
f0100978:	89 9d d0 fe ff ff    	mov    %ebx,-0x130(%ebp)
f010097e:	eb 6c                	jmp    f01009ec <start_overflow+0xbd>
f0100980:	c6 04 03 00          	movb   $0x0,(%ebx,%eax,1)
    pret_addr = (char*)read_pretaddr();
    uint32_t oldret = *((uint32_t*)pret_addr);
    uint32_t overflowaddr = (uint32_t)do_overflow;
    for(i = 0;i<4;i++){
       unsigned int j;
       for(j = 0;j<256;j++)
f0100984:	83 c0 01             	add    $0x1,%eax
f0100987:	3d 00 01 00 00       	cmp    $0x100,%eax
f010098c:	75 f2                	jne    f0100980 <start_overflow+0x51>
{
    cprintf("Overflow success\n");
}

void
start_overflow(void)
f010098e:	89 f1                	mov    %esi,%ecx
       unsigned int j;
       for(j = 0;j<256;j++)
           str[j] = 0;
       char* addr = (char*)(&overflowaddr);
       unsigned char num = (unsigned char)((*(addr + i)) &0xFF);
       for(j = 0; j<num;j++)
f0100990:	0f b6 94 35 e0 fe ff 	movzbl -0x120(%ebp,%esi,1),%edx
f0100997:	ff 
f0100998:	85 d2                	test   %edx,%edx
f010099a:	74 0d                	je     f01009a9 <start_overflow+0x7a>
f010099c:	89 f8                	mov    %edi,%eax
           str[j] = ' ';
f010099e:	c6 04 03 20          	movb   $0x20,(%ebx,%eax,1)
       unsigned int j;
       for(j = 0;j<256;j++)
           str[j] = 0;
       char* addr = (char*)(&overflowaddr);
       unsigned char num = (unsigned char)((*(addr + i)) &0xFF);
       for(j = 0; j<num;j++)
f01009a2:	83 c0 01             	add    $0x1,%eax
f01009a5:	39 d0                	cmp    %edx,%eax
f01009a7:	72 f5                	jb     f010099e <start_overflow+0x6f>
           str[j] = ' ';
       cprintf("%s%n\n",str,pret_addr + i);
f01009a9:	03 8d d4 fe ff ff    	add    -0x12c(%ebp),%ecx
f01009af:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01009b3:	8b 85 d0 fe ff ff    	mov    -0x130(%ebp),%eax
f01009b9:	89 44 24 04          	mov    %eax,0x4(%esp)
f01009bd:	c7 04 24 50 81 10 f0 	movl   $0xf0108150,(%esp)
f01009c4:	e8 3e 41 00 00       	call   f0104b07 <cprintf>
    char *pret_addr;
    int i = 0;
    pret_addr = (char*)read_pretaddr();
    uint32_t oldret = *((uint32_t*)pret_addr);
    uint32_t overflowaddr = (uint32_t)do_overflow;
    for(i = 0;i<4;i++){
f01009c9:	83 c6 01             	add    $0x1,%esi
f01009cc:	83 fe 04             	cmp    $0x4,%esi
f01009cf:	75 1b                	jne    f01009ec <start_overflow+0xbd>
f01009d1:	8b bd d4 fe ff ff    	mov    -0x12c(%ebp),%edi
f01009d7:	83 c7 04             	add    $0x4,%edi
f01009da:	66 be 00 00          	mov    $0x0,%si
       cprintf("%s%n\n",str,pret_addr + i);
    }
    for(i = 0;i<4;i++){
       unsigned int j;
       for(j = 0;j<256;j++)
           str[j] = 0;
f01009de:	8d 9d e8 fe ff ff    	lea    -0x118(%ebp),%ebx
f01009e4:	89 9d d4 fe ff ff    	mov    %ebx,-0x12c(%ebp)
f01009ea:	eb 52                	jmp    f0100a3e <start_overflow+0x10f>
    char *pret_addr;
    int i = 0;
    pret_addr = (char*)read_pretaddr();
    uint32_t oldret = *((uint32_t*)pret_addr);
    uint32_t overflowaddr = (uint32_t)do_overflow;
    for(i = 0;i<4;i++){
f01009ec:	89 f8                	mov    %edi,%eax
f01009ee:	eb 90                	jmp    f0100980 <start_overflow+0x51>
       cprintf("%s%n\n",str,pret_addr + i);
    }
    for(i = 0;i<4;i++){
       unsigned int j;
       for(j = 0;j<256;j++)
           str[j] = 0;
f01009f0:	c6 04 03 00          	movb   $0x0,(%ebx,%eax,1)
           str[j] = ' ';
       cprintf("%s%n\n",str,pret_addr + i);
    }
    for(i = 0;i<4;i++){
       unsigned int j;
       for(j = 0;j<256;j++)
f01009f4:	83 c0 01             	add    $0x1,%eax
f01009f7:	3d 00 01 00 00       	cmp    $0x100,%eax
f01009fc:	75 f2                	jne    f01009f0 <start_overflow+0xc1>
           str[j] = 0;
       char* addr = (char*)(&oldret);
       unsigned char num = (unsigned char)((*(addr + i))&0xFF);
       for(j = 0; j<num;j++)
f01009fe:	0f b6 94 35 e4 fe ff 	movzbl -0x11c(%ebp,%esi,1),%edx
f0100a05:	ff 
f0100a06:	85 d2                	test   %edx,%edx
f0100a08:	74 0f                	je     f0100a19 <start_overflow+0xea>
f0100a0a:	66 b8 00 00          	mov    $0x0,%ax
           str[j] = ' ';
f0100a0e:	c6 04 03 20          	movb   $0x20,(%ebx,%eax,1)
       unsigned int j;
       for(j = 0;j<256;j++)
           str[j] = 0;
       char* addr = (char*)(&oldret);
       unsigned char num = (unsigned char)((*(addr + i))&0xFF);
       for(j = 0; j<num;j++)
f0100a12:	83 c0 01             	add    $0x1,%eax
f0100a15:	39 d0                	cmp    %edx,%eax
f0100a17:	72 f5                	jb     f0100a0e <start_overflow+0xdf>
           str[j] = ' ';
       cprintf("%s%n\n",str,pret_addr + 4 + i);
f0100a19:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0100a1d:	8b 95 d4 fe ff ff    	mov    -0x12c(%ebp),%edx
f0100a23:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100a27:	c7 04 24 50 81 10 f0 	movl   $0xf0108150,(%esp)
f0100a2e:	e8 d4 40 00 00       	call   f0104b07 <cprintf>
       unsigned char num = (unsigned char)((*(addr + i)) &0xFF);
       for(j = 0; j<num;j++)
           str[j] = ' ';
       cprintf("%s%n\n",str,pret_addr + i);
    }
    for(i = 0;i<4;i++){
f0100a33:	83 c6 01             	add    $0x1,%esi
f0100a36:	83 c7 01             	add    $0x1,%edi
f0100a39:	83 fe 04             	cmp    $0x4,%esi
f0100a3c:	74 07                	je     f0100a45 <start_overflow+0x116>
f0100a3e:	b8 00 00 00 00       	mov    $0x0,%eax
f0100a43:	eb ab                	jmp    f01009f0 <start_overflow+0xc1>
       cprintf("%s%n\n",str,pret_addr + 4 + i);
    }
    

	// Your code here.
}
f0100a45:	81 c4 3c 01 00 00    	add    $0x13c,%esp
f0100a4b:	5b                   	pop    %ebx
f0100a4c:	5e                   	pop    %esi
f0100a4d:	5f                   	pop    %edi
f0100a4e:	5d                   	pop    %ebp
f0100a4f:	c3                   	ret    

f0100a50 <overflow_me>:

void
overflow_me(void)
{
f0100a50:	55                   	push   %ebp
f0100a51:	89 e5                	mov    %esp,%ebp
f0100a53:	83 ec 08             	sub    $0x8,%esp
        start_overflow();
f0100a56:	e8 d4 fe ff ff       	call   f010092f <start_overflow>
}
f0100a5b:	c9                   	leave  
f0100a5c:	c3                   	ret    

f0100a5d <do_overflow>:
    
}

void
do_overflow(void)
{
f0100a5d:	55                   	push   %ebp
f0100a5e:	89 e5                	mov    %esp,%ebp
f0100a60:	83 ec 18             	sub    $0x18,%esp
    cprintf("Overflow success\n");
f0100a63:	c7 04 24 56 81 10 f0 	movl   $0xf0108156,(%esp)
f0100a6a:	e8 98 40 00 00       	call   f0104b07 <cprintf>
}
f0100a6f:	c9                   	leave  
f0100a70:	c3                   	ret    

f0100a71 <mon_kerninfo>:
	return 0;
}

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f0100a71:	55                   	push   %ebp
f0100a72:	89 e5                	mov    %esp,%ebp
f0100a74:	83 ec 18             	sub    $0x18,%esp
	extern char entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f0100a77:	c7 04 24 68 81 10 f0 	movl   $0xf0108168,(%esp)
f0100a7e:	e8 84 40 00 00       	call   f0104b07 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100a83:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f0100a8a:	00 
f0100a8b:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f0100a92:	f0 
f0100a93:	c7 04 24 e4 83 10 f0 	movl   $0xf01083e4,(%esp)
f0100a9a:	e8 68 40 00 00       	call   f0104b07 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100a9f:	c7 44 24 08 c5 7d 10 	movl   $0x107dc5,0x8(%esp)
f0100aa6:	00 
f0100aa7:	c7 44 24 04 c5 7d 10 	movl   $0xf0107dc5,0x4(%esp)
f0100aae:	f0 
f0100aaf:	c7 04 24 08 84 10 f0 	movl   $0xf0108408,(%esp)
f0100ab6:	e8 4c 40 00 00       	call   f0104b07 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100abb:	c7 44 24 08 50 cc 24 	movl   $0x24cc50,0x8(%esp)
f0100ac2:	00 
f0100ac3:	c7 44 24 04 50 cc 24 	movl   $0xf024cc50,0x4(%esp)
f0100aca:	f0 
f0100acb:	c7 04 24 2c 84 10 f0 	movl   $0xf010842c,(%esp)
f0100ad2:	e8 30 40 00 00       	call   f0104b07 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100ad7:	c7 44 24 08 04 f0 28 	movl   $0x28f004,0x8(%esp)
f0100ade:	00 
f0100adf:	c7 44 24 04 04 f0 28 	movl   $0xf028f004,0x4(%esp)
f0100ae6:	f0 
f0100ae7:	c7 04 24 50 84 10 f0 	movl   $0xf0108450,(%esp)
f0100aee:	e8 14 40 00 00       	call   f0104b07 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100af3:	b8 03 f4 28 f0       	mov    $0xf028f403,%eax
f0100af8:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
f0100afd:	89 c2                	mov    %eax,%edx
f0100aff:	c1 fa 1f             	sar    $0x1f,%edx
f0100b02:	c1 ea 16             	shr    $0x16,%edx
f0100b05:	8d 04 02             	lea    (%edx,%eax,1),%eax
f0100b08:	c1 f8 0a             	sar    $0xa,%eax
f0100b0b:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100b0f:	c7 04 24 74 84 10 f0 	movl   $0xf0108474,(%esp)
f0100b16:	e8 ec 3f 00 00       	call   f0104b07 <cprintf>
		(end-entry+1023)/1024);
	return 0;
}
f0100b1b:	b8 00 00 00 00       	mov    $0x0,%eax
f0100b20:	c9                   	leave  
f0100b21:	c3                   	ret    

f0100b22 <mon_help>:
} 


int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100b22:	55                   	push   %ebp
f0100b23:	89 e5                	mov    %esp,%ebp
f0100b25:	57                   	push   %edi
f0100b26:	56                   	push   %esi
f0100b27:	53                   	push   %ebx
f0100b28:	83 ec 1c             	sub    $0x1c,%esp
f0100b2b:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100b30:	be a4 85 10 f0       	mov    $0xf01085a4,%esi
f0100b35:	bf a0 85 10 f0       	mov    $0xf01085a0,%edi
f0100b3a:	8b 04 1e             	mov    (%esi,%ebx,1),%eax
f0100b3d:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100b41:	8b 04 1f             	mov    (%edi,%ebx,1),%eax
f0100b44:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100b48:	c7 04 24 81 81 10 f0 	movl   $0xf0108181,(%esp)
f0100b4f:	e8 b3 3f 00 00       	call   f0104b07 <cprintf>
f0100b54:	83 c3 0c             	add    $0xc,%ebx
int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
	int i;

	for (i = 0; i < NCOMMANDS; i++)
f0100b57:	83 fb 6c             	cmp    $0x6c,%ebx
f0100b5a:	75 de                	jne    f0100b3a <mon_help+0x18>
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
	return 0;
}
f0100b5c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100b61:	83 c4 1c             	add    $0x1c,%esp
f0100b64:	5b                   	pop    %ebx
f0100b65:	5e                   	pop    %esi
f0100b66:	5f                   	pop    %edi
f0100b67:	5d                   	pop    %ebp
f0100b68:	c3                   	ret    

f0100b69 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100b69:	55                   	push   %ebp
f0100b6a:	89 e5                	mov    %esp,%ebp
f0100b6c:	57                   	push   %edi
f0100b6d:	56                   	push   %esi
f0100b6e:	53                   	push   %ebx
f0100b6f:	83 ec 5c             	sub    $0x5c,%esp
	char *buf;
        if(tf == NULL){
f0100b72:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0100b76:	75 1a                	jne    f0100b92 <monitor+0x29>
	   cprintf("Welcome to the JOS kernel monitor!\n");
f0100b78:	c7 04 24 a0 84 10 f0 	movl   $0xf01084a0,(%esp)
f0100b7f:	e8 83 3f 00 00       	call   f0104b07 <cprintf>
	   cprintf("Type 'help' for a list of commands.\n");
f0100b84:	c7 04 24 c4 84 10 f0 	movl   $0xf01084c4,(%esp)
f0100b8b:	e8 77 3f 00 00       	call   f0104b07 <cprintf>
f0100b90:	eb 0b                	jmp    f0100b9d <monitor+0x34>
        }

	if (tf != NULL)
		print_trapframe(tf);
f0100b92:	8b 45 08             	mov    0x8(%ebp),%eax
f0100b95:	89 04 24             	mov    %eax,(%esp)
f0100b98:	e8 e1 46 00 00       	call   f010527e <print_trapframe>

	while (1) {
		buf = readline("K> ");
f0100b9d:	c7 04 24 8a 81 10 f0 	movl   $0xf010818a,(%esp)
f0100ba4:	e8 b7 61 00 00       	call   f0106d60 <readline>
f0100ba9:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100bab:	85 c0                	test   %eax,%eax
f0100bad:	74 ee                	je     f0100b9d <monitor+0x34>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f0100baf:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
f0100bb6:	be 00 00 00 00       	mov    $0x0,%esi
f0100bbb:	eb 06                	jmp    f0100bc3 <monitor+0x5a>
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100bbd:	c6 03 00             	movb   $0x0,(%ebx)
f0100bc0:	83 c3 01             	add    $0x1,%ebx
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f0100bc3:	0f b6 03             	movzbl (%ebx),%eax
f0100bc6:	84 c0                	test   %al,%al
f0100bc8:	74 6b                	je     f0100c35 <monitor+0xcc>
f0100bca:	0f be c0             	movsbl %al,%eax
f0100bcd:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100bd1:	c7 04 24 8e 81 10 f0 	movl   $0xf010818e,(%esp)
f0100bd8:	e8 de 63 00 00       	call   f0106fbb <strchr>
f0100bdd:	85 c0                	test   %eax,%eax
f0100bdf:	75 dc                	jne    f0100bbd <monitor+0x54>
			*buf++ = 0;
		if (*buf == 0)
f0100be1:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100be4:	74 4f                	je     f0100c35 <monitor+0xcc>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f0100be6:	83 fe 0f             	cmp    $0xf,%esi
f0100be9:	75 16                	jne    f0100c01 <monitor+0x98>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100beb:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f0100bf2:	00 
f0100bf3:	c7 04 24 93 81 10 f0 	movl   $0xf0108193,(%esp)
f0100bfa:	e8 08 3f 00 00       	call   f0104b07 <cprintf>
f0100bff:	eb 9c                	jmp    f0100b9d <monitor+0x34>
			return 0;
		}
		argv[argc++] = buf;
f0100c01:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f0100c05:	83 c6 01             	add    $0x1,%esi
		while (*buf && !strchr(WHITESPACE, *buf))
f0100c08:	0f b6 03             	movzbl (%ebx),%eax
f0100c0b:	84 c0                	test   %al,%al
f0100c0d:	75 0d                	jne    f0100c1c <monitor+0xb3>
f0100c0f:	90                   	nop
f0100c10:	eb b1                	jmp    f0100bc3 <monitor+0x5a>
			buf++;
f0100c12:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f0100c15:	0f b6 03             	movzbl (%ebx),%eax
f0100c18:	84 c0                	test   %al,%al
f0100c1a:	74 a7                	je     f0100bc3 <monitor+0x5a>
f0100c1c:	0f be c0             	movsbl %al,%eax
f0100c1f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100c23:	c7 04 24 8e 81 10 f0 	movl   $0xf010818e,(%esp)
f0100c2a:	e8 8c 63 00 00       	call   f0106fbb <strchr>
f0100c2f:	85 c0                	test   %eax,%eax
f0100c31:	74 df                	je     f0100c12 <monitor+0xa9>
f0100c33:	eb 8e                	jmp    f0100bc3 <monitor+0x5a>
			buf++;
	}
	argv[argc] = 0;
f0100c35:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100c3c:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100c3d:	85 f6                	test   %esi,%esi
f0100c3f:	90                   	nop
f0100c40:	0f 84 57 ff ff ff    	je     f0100b9d <monitor+0x34>
f0100c46:	bb a0 85 10 f0       	mov    $0xf01085a0,%ebx
f0100c4b:	bf 00 00 00 00       	mov    $0x0,%edi
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100c50:	8b 03                	mov    (%ebx),%eax
f0100c52:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100c56:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100c59:	89 04 24             	mov    %eax,(%esp)
f0100c5c:	e8 e4 62 00 00       	call   f0106f45 <strcmp>
f0100c61:	85 c0                	test   %eax,%eax
f0100c63:	75 23                	jne    f0100c88 <monitor+0x11f>
			return commands[i].func(argc, argv, tf);
f0100c65:	6b ff 0c             	imul   $0xc,%edi,%edi
f0100c68:	8b 45 08             	mov    0x8(%ebp),%eax
f0100c6b:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100c6f:	8d 45 a8             	lea    -0x58(%ebp),%eax
f0100c72:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100c76:	89 34 24             	mov    %esi,(%esp)
f0100c79:	ff 97 a8 85 10 f0    	call   *-0xfef7a58(%edi)
		print_trapframe(tf);

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100c7f:	85 c0                	test   %eax,%eax
f0100c81:	78 28                	js     f0100cab <monitor+0x142>
f0100c83:	e9 15 ff ff ff       	jmp    f0100b9d <monitor+0x34>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f0100c88:	83 c7 01             	add    $0x1,%edi
f0100c8b:	83 c3 0c             	add    $0xc,%ebx
f0100c8e:	83 ff 09             	cmp    $0x9,%edi
f0100c91:	75 bd                	jne    f0100c50 <monitor+0xe7>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100c93:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100c96:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100c9a:	c7 04 24 b0 81 10 f0 	movl   $0xf01081b0,(%esp)
f0100ca1:	e8 61 3e 00 00       	call   f0104b07 <cprintf>
f0100ca6:	e9 f2 fe ff ff       	jmp    f0100b9d <monitor+0x34>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0100cab:	83 c4 5c             	add    $0x5c,%esp
f0100cae:	5b                   	pop    %ebx
f0100caf:	5e                   	pop    %esi
f0100cb0:	5f                   	pop    %edi
f0100cb1:	5d                   	pop    %ebp
f0100cb2:	c3                   	ret    

f0100cb3 <mon_time>:
   return (uint64_t) hi<<32|lo;    
}

int 
mon_time(int argc, char**argv,struct Trapframe *tf)
{
f0100cb3:	55                   	push   %ebp
f0100cb4:	89 e5                	mov    %esp,%ebp
f0100cb6:	57                   	push   %edi
f0100cb7:	56                   	push   %esi
f0100cb8:	53                   	push   %ebx
f0100cb9:	83 ec 3c             	sub    $0x3c,%esp
f0100cbc:	be a0 85 10 f0       	mov    $0xf01085a0,%esi
f0100cc1:	bf 00 00 00 00       	mov    $0x0,%edi
   int ret;
   int flag = 0;
   uint64_t begin;
   uint64_t end;
   for(i = 0;i<NCOMMANDS;i++){
       if(strcmp(argv[1],commands[i].name) == 0){
f0100cc6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0100cc9:	83 c3 04             	add    $0x4,%ebx
f0100ccc:	8b 06                	mov    (%esi),%eax
f0100cce:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0100cd1:	89 5d e0             	mov    %ebx,-0x20(%ebp)
f0100cd4:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100cd8:	8b 03                	mov    (%ebx),%eax
f0100cda:	89 04 24             	mov    %eax,(%esp)
f0100cdd:	e8 63 62 00 00       	call   f0106f45 <strcmp>
f0100ce2:	85 c0                	test   %eax,%eax
f0100ce4:	75 51                	jne    f0100d37 <mon_time+0x84>
          begin = rdtsc();
f0100ce6:	e8 35 fc ff ff       	call   f0100920 <rdtsc>
f0100ceb:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100cee:	89 55 d4             	mov    %edx,-0x2c(%ebp)
          ret = (commands[i].func)(argc-1,&argv[1],tf);
f0100cf1:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f0100cf4:	8b 55 10             	mov    0x10(%ebp),%edx
f0100cf7:	89 54 24 08          	mov    %edx,0x8(%esp)
f0100cfb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100cff:	8b 55 08             	mov    0x8(%ebp),%edx
f0100d02:	83 ea 01             	sub    $0x1,%edx
f0100d05:	89 14 24             	mov    %edx,(%esp)
f0100d08:	ff 14 85 a8 85 10 f0 	call   *-0xfef7a58(,%eax,4)
          end = rdtsc();
f0100d0f:	e8 0c fc ff ff       	call   f0100920 <rdtsc>
          cprintf("%s cycles: %d\n",commands[i].name,end-begin);
f0100d14:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0100d17:	1b 55 d4             	sbb    -0x2c(%ebp),%edx
f0100d1a:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100d1e:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0100d22:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0100d25:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100d29:	c7 04 24 c6 81 10 f0 	movl   $0xf01081c6,(%esp)
f0100d30:	e8 d2 3d 00 00       	call   f0104b07 <cprintf>
f0100d35:	eb 0d                	jmp    f0100d44 <mon_time+0x91>
   int i;
   int ret;
   int flag = 0;
   uint64_t begin;
   uint64_t end;
   for(i = 0;i<NCOMMANDS;i++){
f0100d37:	83 c7 01             	add    $0x1,%edi
f0100d3a:	83 c6 0c             	add    $0xc,%esi
f0100d3d:	83 ff 09             	cmp    $0x9,%edi
f0100d40:	75 8a                	jne    f0100ccc <mon_time+0x19>
f0100d42:	eb 0d                	jmp    f0100d51 <mon_time+0x9e>
       }
   }
   if(flag == 0)
     cprintf("no such command %s\n",argv[1]);
   return 0;
}
f0100d44:	b8 00 00 00 00       	mov    $0x0,%eax
f0100d49:	83 c4 3c             	add    $0x3c,%esp
f0100d4c:	5b                   	pop    %ebx
f0100d4d:	5e                   	pop    %esi
f0100d4e:	5f                   	pop    %edi
f0100d4f:	5d                   	pop    %ebp
f0100d50:	c3                   	ret    
          flag = 1;
          break;
       }
   }
   if(flag == 0)
     cprintf("no such command %s\n",argv[1]);
f0100d51:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0100d54:	8b 01                	mov    (%ecx),%eax
f0100d56:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100d5a:	c7 04 24 d5 81 10 f0 	movl   $0xf01081d5,(%esp)
f0100d61:	e8 a1 3d 00 00       	call   f0104b07 <cprintf>
f0100d66:	eb dc                	jmp    f0100d44 <mon_time+0x91>

f0100d68 <mon_backtrace>:
        start_overflow();
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f0100d68:	55                   	push   %ebp
f0100d69:	89 e5                	mov    %esp,%ebp
f0100d6b:	57                   	push   %edi
f0100d6c:	56                   	push   %esi
f0100d6d:	53                   	push   %ebx
f0100d6e:	83 ec 4c             	sub    $0x4c,%esp
	// Your code here.
    overflow_me();
f0100d71:	e8 da fc ff ff       	call   f0100a50 <overflow_me>
    cprintf("Stack backtrace:\n");
f0100d76:	c7 04 24 e9 81 10 f0 	movl   $0xf01081e9,(%esp)
f0100d7d:	e8 85 3d 00 00       	call   f0104b07 <cprintf>
    uint32_t* ebp = (uint32_t*)read_ebp();
f0100d82:	89 ee                	mov    %ebp,%esi
    struct Eipdebuginfo info;
    while(ebp != 0){
f0100d84:	85 f6                	test   %esi,%esi
f0100d86:	0f 84 97 00 00 00    	je     f0100e23 <mon_backtrace+0xbb>
    int i = 0;
    cprintf("eip %08x  ebp %08x  ",ebp[1],ebp);
f0100d8c:	8d 7e 04             	lea    0x4(%esi),%edi
f0100d8f:	89 74 24 08          	mov    %esi,0x8(%esp)
f0100d93:	8b 07                	mov    (%edi),%eax
f0100d95:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100d99:	c7 04 24 fb 81 10 f0 	movl   $0xf01081fb,(%esp)
f0100da0:	e8 62 3d 00 00       	call   f0104b07 <cprintf>
    debuginfo_eip(ebp[1],&info);
f0100da5:	8d 45 d0             	lea    -0x30(%ebp),%eax
f0100da8:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100dac:	8b 07                	mov    (%edi),%eax
f0100dae:	89 04 24             	mov    %eax,(%esp)
f0100db1:	e8 18 55 00 00       	call   f01062ce <debuginfo_eip>
    cprintf("args ");
f0100db6:	c7 04 24 10 82 10 f0 	movl   $0xf0108210,(%esp)
f0100dbd:	e8 45 3d 00 00       	call   f0104b07 <cprintf>
f0100dc2:	bb 00 00 00 00       	mov    $0x0,%ebx
    for(i = 0; i< 5;i++){
       cprintf("%08x ",ebp[i+2]);
f0100dc7:	8b 44 9e 08          	mov    0x8(%esi,%ebx,4),%eax
f0100dcb:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100dcf:	c7 04 24 01 83 10 f0 	movl   $0xf0108301,(%esp)
f0100dd6:	e8 2c 3d 00 00       	call   f0104b07 <cprintf>
    while(ebp != 0){
    int i = 0;
    cprintf("eip %08x  ebp %08x  ",ebp[1],ebp);
    debuginfo_eip(ebp[1],&info);
    cprintf("args ");
    for(i = 0; i< 5;i++){
f0100ddb:	83 c3 01             	add    $0x1,%ebx
f0100dde:	83 fb 05             	cmp    $0x5,%ebx
f0100de1:	75 e4                	jne    f0100dc7 <mon_backtrace+0x5f>
       cprintf("%08x ",ebp[i+2]);
    }
    cprintf("\n");
f0100de3:	c7 04 24 d9 82 10 f0 	movl   $0xf01082d9,(%esp)
f0100dea:	e8 18 3d 00 00       	call   f0104b07 <cprintf>
    cprintf("\t%s:%d: %s+%d\n",info.eip_file,info.eip_line,info.eip_fn_name,ebp[1]-info.eip_fn_addr);
f0100def:	8b 07                	mov    (%edi),%eax
f0100df1:	2b 45 e0             	sub    -0x20(%ebp),%eax
f0100df4:	89 44 24 10          	mov    %eax,0x10(%esp)
f0100df8:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100dfb:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100dff:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100e02:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100e06:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0100e09:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100e0d:	c7 04 24 16 82 10 f0 	movl   $0xf0108216,(%esp)
f0100e14:	e8 ee 3c 00 00       	call   f0104b07 <cprintf>
    ebp = (uint32_t*)(*(ebp));
f0100e19:	8b 36                	mov    (%esi),%esi
	// Your code here.
    overflow_me();
    cprintf("Stack backtrace:\n");
    uint32_t* ebp = (uint32_t*)read_ebp();
    struct Eipdebuginfo info;
    while(ebp != 0){
f0100e1b:	85 f6                	test   %esi,%esi
f0100e1d:	0f 85 69 ff ff ff    	jne    f0100d8c <mon_backtrace+0x24>
    }
    cprintf("\n");
    cprintf("\t%s:%d: %s+%d\n",info.eip_file,info.eip_line,info.eip_fn_name,ebp[1]-info.eip_fn_addr);
    ebp = (uint32_t*)(*(ebp));
    }
    cprintf("Backtrace success\n");
f0100e23:	c7 04 24 25 82 10 f0 	movl   $0xf0108225,(%esp)
f0100e2a:	e8 d8 3c 00 00       	call   f0104b07 <cprintf>
    return 0;
}
f0100e2f:	b8 00 00 00 00       	mov    $0x0,%eax
f0100e34:	83 c4 4c             	add    $0x4c,%esp
f0100e37:	5b                   	pop    %ebx
f0100e38:	5e                   	pop    %esi
f0100e39:	5f                   	pop    %edi
f0100e3a:	5d                   	pop    %ebp
f0100e3b:	c3                   	ret    

f0100e3c <mon_x>:
unsigned read_eip();

/***** Implementations of basic kernel monitor commands *****/

int 
mon_x(int argc,char **argv,struct Trapframe *tf){
f0100e3c:	55                   	push   %ebp
f0100e3d:	89 e5                	mov    %esp,%ebp
f0100e3f:	83 ec 18             	sub    $0x18,%esp
   if(argc != 2)
f0100e42:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
f0100e46:	74 0e                	je     f0100e56 <mon_x+0x1a>
     cprintf("Usage: x [addr]\n");   
f0100e48:	c7 04 24 38 82 10 f0 	movl   $0xf0108238,(%esp)
f0100e4f:	e8 b3 3c 00 00       	call   f0104b07 <cprintf>
f0100e54:	eb 44                	jmp    f0100e9a <mon_x+0x5e>
   else if(tf == NULL)
f0100e56:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0100e5a:	75 0e                	jne    f0100e6a <mon_x+0x2e>
     cprintf("trapframe error\n");
f0100e5c:	c7 04 24 49 82 10 f0 	movl   $0xf0108249,(%esp)
f0100e63:	e8 9f 3c 00 00       	call   f0104b07 <cprintf>
f0100e68:	eb 30                	jmp    f0100e9a <mon_x+0x5e>
   else{
       uint32_t addr = strtol(argv[1],0,0);
f0100e6a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0100e71:	00 
f0100e72:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100e79:	00 
f0100e7a:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100e7d:	8b 40 04             	mov    0x4(%eax),%eax
f0100e80:	89 04 24             	mov    %eax,(%esp)
f0100e83:	e8 03 63 00 00       	call   f010718b <strtol>
       uint32_t value = 0; 
       value = *((uint32_t*)addr);
       cprintf("%d\n",value);
f0100e88:	8b 00                	mov    (%eax),%eax
f0100e8a:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100e8e:	c7 04 24 d1 81 10 f0 	movl   $0xf01081d1,(%esp)
f0100e95:	e8 6d 3c 00 00       	call   f0104b07 <cprintf>
    }
    return 0;
}
f0100e9a:	b8 00 00 00 00       	mov    $0x0,%eax
f0100e9f:	c9                   	leave  
f0100ea0:	c3                   	ret    

f0100ea1 <mon_changeperm>:
   return 0;
}

int 
mon_changeperm(int argc,char**argv,struct Trapframe *tf)
{
f0100ea1:	55                   	push   %ebp
f0100ea2:	89 e5                	mov    %esp,%ebp
f0100ea4:	83 ec 38             	sub    $0x38,%esp
f0100ea7:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0100eaa:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0100ead:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0100eb0:	8b 75 08             	mov    0x8(%ebp),%esi
f0100eb3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
    if(argc != 3 && argc != 4){
f0100eb6:	8d 46 fd             	lea    -0x3(%esi),%eax
f0100eb9:	83 f8 01             	cmp    $0x1,%eax
f0100ebc:	76 11                	jbe    f0100ecf <mon_changeperm+0x2e>
      cprintf("Usage: changeperm [op] [addr] ([perm])\n");
f0100ebe:	c7 04 24 ec 84 10 f0 	movl   $0xf01084ec,(%esp)
f0100ec5:	e8 3d 3c 00 00       	call   f0104b07 <cprintf>
      return 0;
f0100eca:	e9 23 01 00 00       	jmp    f0100ff2 <mon_changeperm+0x151>
    }
    char* op = argv[1];
f0100ecf:	8b 43 04             	mov    0x4(%ebx),%eax
f0100ed2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    uintptr_t addr = strtol(argv[2],0,0);
f0100ed5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0100edc:	00 
f0100edd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100ee4:	00 
f0100ee5:	8b 43 08             	mov    0x8(%ebx),%eax
f0100ee8:	89 04 24             	mov    %eax,(%esp)
f0100eeb:	e8 9b 62 00 00       	call   f010718b <strtol>
    pte_t* pte = pgdir_walk(kern_pgdir,(void*)addr,1);
f0100ef0:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0100ef7:	00 
f0100ef8:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100efc:	a1 ac de 24 f0       	mov    0xf024deac,%eax
f0100f01:	89 04 24             	mov    %eax,(%esp)
f0100f04:	e8 fc 11 00 00       	call   f0102105 <pgdir_walk>
f0100f09:	89 c7                	mov    %eax,%edi
    if(pte == NULL){
f0100f0b:	85 c0                	test   %eax,%eax
f0100f0d:	75 11                	jne    f0100f20 <mon_changeperm+0x7f>
       cprintf("pte error\n");
f0100f0f:	c7 04 24 5a 82 10 f0 	movl   $0xf010825a,(%esp)
f0100f16:	e8 ec 3b 00 00       	call   f0104b07 <cprintf>
       return 0;
f0100f1b:	e9 d2 00 00 00       	jmp    f0100ff2 <mon_changeperm+0x151>
    }
    if(strcmp(op,"set") == 0 || strcmp(op,"change") == 0){
f0100f20:	c7 44 24 04 65 82 10 	movl   $0xf0108265,0x4(%esp)
f0100f27:	f0 
f0100f28:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100f2b:	89 04 24             	mov    %eax,(%esp)
f0100f2e:	e8 12 60 00 00       	call   f0106f45 <strcmp>
f0100f33:	85 c0                	test   %eax,%eax
f0100f35:	74 17                	je     f0100f4e <mon_changeperm+0xad>
f0100f37:	c7 44 24 04 69 82 10 	movl   $0xf0108269,0x4(%esp)
f0100f3e:	f0 
f0100f3f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100f42:	89 04 24             	mov    %eax,(%esp)
f0100f45:	e8 fb 5f 00 00       	call   f0106f45 <strcmp>
f0100f4a:	85 c0                	test   %eax,%eax
f0100f4c:	75 58                	jne    f0100fa6 <mon_changeperm+0x105>
       if(argc != 4){
f0100f4e:	83 fe 04             	cmp    $0x4,%esi
f0100f51:	74 11                	je     f0100f64 <mon_changeperm+0xc3>
         cprintf("Usage: changeperm [op] [addr] ([perm])\n");
f0100f53:	c7 04 24 ec 84 10 f0 	movl   $0xf01084ec,(%esp)
f0100f5a:	e8 a8 3b 00 00       	call   f0104b07 <cprintf>
         return 0;
f0100f5f:	e9 8e 00 00 00       	jmp    f0100ff2 <mon_changeperm+0x151>
       }
       uintptr_t perm = strtol(argv[3],0,0);
f0100f64:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0100f6b:	00 
f0100f6c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100f73:	00 
f0100f74:	8b 43 0c             	mov    0xc(%ebx),%eax
f0100f77:	89 04 24             	mov    %eax,(%esp)
f0100f7a:	e8 0c 62 00 00       	call   f010718b <strtol>
       if((perm & 0x00000FFF) != perm){
f0100f7f:	89 c2                	mov    %eax,%edx
f0100f81:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
f0100f87:	39 c2                	cmp    %eax,%edx
f0100f89:	74 0e                	je     f0100f99 <mon_changeperm+0xf8>
          cprintf("wrong perm\n");
f0100f8b:	c7 04 24 70 82 10 f0 	movl   $0xf0108270,(%esp)
f0100f92:	e8 70 3b 00 00       	call   f0104b07 <cprintf>
          return 0;
f0100f97:	eb 59                	jmp    f0100ff2 <mon_changeperm+0x151>
       }
       *pte = ((*pte)& 0xFFFFF000) | perm;
f0100f99:	8b 07                	mov    (%edi),%eax
f0100f9b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100fa0:	09 c2                	or     %eax,%edx
f0100fa2:	89 17                	mov    %edx,(%edi)
    pte_t* pte = pgdir_walk(kern_pgdir,(void*)addr,1);
    if(pte == NULL){
       cprintf("pte error\n");
       return 0;
    }
    if(strcmp(op,"set") == 0 || strcmp(op,"change") == 0){
f0100fa4:	eb 40                	jmp    f0100fe6 <mon_changeperm+0x145>
          cprintf("wrong perm\n");
          return 0;
       }
       *pte = ((*pte)& 0xFFFFF000) | perm;
    }
    else if(strcmp(op,"clear") == 0){
f0100fa6:	c7 44 24 04 7c 82 10 	movl   $0xf010827c,0x4(%esp)
f0100fad:	f0 
f0100fae:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100fb1:	89 04 24             	mov    %eax,(%esp)
f0100fb4:	e8 8c 5f 00 00       	call   f0106f45 <strcmp>
f0100fb9:	85 c0                	test   %eax,%eax
f0100fbb:	75 1b                	jne    f0100fd8 <mon_changeperm+0x137>
       if(argc != 3){
f0100fbd:	83 fe 03             	cmp    $0x3,%esi
f0100fc0:	74 0e                	je     f0100fd0 <mon_changeperm+0x12f>
         cprintf("Usage: changeperm [op] [addr] ([perm])\n");
f0100fc2:	c7 04 24 ec 84 10 f0 	movl   $0xf01084ec,(%esp)
f0100fc9:	e8 39 3b 00 00       	call   f0104b07 <cprintf>
         return 0;
f0100fce:	eb 22                	jmp    f0100ff2 <mon_changeperm+0x151>
       }
       *pte = ((*pte)& 0xFFFFF000);
f0100fd0:	81 27 00 f0 ff ff    	andl   $0xfffff000,(%edi)
f0100fd6:	eb 0e                	jmp    f0100fe6 <mon_changeperm+0x145>
    }
    else{
      cprintf("Usage: changeperm [op] [addr] ([perm])\n");
f0100fd8:	c7 04 24 ec 84 10 f0 	movl   $0xf01084ec,(%esp)
f0100fdf:	e8 23 3b 00 00       	call   f0104b07 <cprintf>
      return 0;
f0100fe4:	eb 0c                	jmp    f0100ff2 <mon_changeperm+0x151>
    }
    cprintf("success\n");
f0100fe6:	c7 04 24 2f 82 10 f0 	movl   $0xf010822f,(%esp)
f0100fed:	e8 15 3b 00 00       	call   f0104b07 <cprintf>
    return 0;
}
f0100ff2:	b8 00 00 00 00       	mov    $0x0,%eax
f0100ff7:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0100ffa:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0100ffd:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0101000:	89 ec                	mov    %ebp,%esp
f0101002:	5d                   	pop    %ebp
f0101003:	c3                   	ret    

f0101004 <mon_showmappings>:
   return 0;
}

int 
mon_showmappings(int argc,char**argv,struct Trapframe *tf)
{
f0101004:	55                   	push   %ebp
f0101005:	89 e5                	mov    %esp,%ebp
f0101007:	57                   	push   %edi
f0101008:	56                   	push   %esi
f0101009:	53                   	push   %ebx
f010100a:	83 ec 1c             	sub    $0x1c,%esp
f010100d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
   if(argc != 3)
f0101010:	83 7d 08 03          	cmpl   $0x3,0x8(%ebp)
f0101014:	0f 85 2c 02 00 00    	jne    f0101246 <mon_showmappings+0x242>
      return 0;
   uintptr_t begin = strtol(argv[1],0,0);
f010101a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101021:	00 
f0101022:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101029:	00 
f010102a:	8b 43 04             	mov    0x4(%ebx),%eax
f010102d:	89 04 24             	mov    %eax,(%esp)
f0101030:	e8 56 61 00 00       	call   f010718b <strtol>
f0101035:	89 c6                	mov    %eax,%esi
   uintptr_t end = strtol(argv[2],0,0);
f0101037:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010103e:	00 
f010103f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101046:	00 
f0101047:	8b 43 08             	mov    0x8(%ebx),%eax
f010104a:	89 04 24             	mov    %eax,(%esp)
f010104d:	e8 39 61 00 00       	call   f010718b <strtol>
f0101052:	89 c7                	mov    %eax,%edi
   if(begin > end || begin != ROUNDUP(begin,PGSIZE)){
f0101054:	39 c6                	cmp    %eax,%esi
f0101056:	77 18                	ja     f0101070 <mon_showmappings+0x6c>
f0101058:	8d 86 ff 0f 00 00    	lea    0xfff(%esi),%eax
f010105e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0101063:	39 c6                	cmp    %eax,%esi
f0101065:	75 09                	jne    f0101070 <mon_showmappings+0x6c>
      cprintf("wrong virtual address\n");
      return 0;
   }
   while(begin < end){
f0101067:	39 fe                	cmp    %edi,%esi
f0101069:	72 16                	jb     f0101081 <mon_showmappings+0x7d>
f010106b:	e9 d6 01 00 00       	jmp    f0101246 <mon_showmappings+0x242>
   if(argc != 3)
      return 0;
   uintptr_t begin = strtol(argv[1],0,0);
   uintptr_t end = strtol(argv[2],0,0);
   if(begin > end || begin != ROUNDUP(begin,PGSIZE)){
      cprintf("wrong virtual address\n");
f0101070:	c7 04 24 82 82 10 f0 	movl   $0xf0108282,(%esp)
f0101077:	e8 8b 3a 00 00       	call   f0104b07 <cprintf>
      return 0;
f010107c:	e9 c5 01 00 00       	jmp    f0101246 <mon_showmappings+0x242>
   }
   while(begin < end){
      pte_t* pte = pgdir_walk(kern_pgdir,(void*)begin,0);
f0101081:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101088:	00 
f0101089:	89 74 24 04          	mov    %esi,0x4(%esp)
f010108d:	a1 ac de 24 f0       	mov    0xf024deac,%eax
f0101092:	89 04 24             	mov    %eax,(%esp)
f0101095:	e8 6b 10 00 00       	call   f0102105 <pgdir_walk>
f010109a:	89 c3                	mov    %eax,%ebx
      if(pte && ((*pte) & PTE_P)&&((*pte) & PTE_PS)){
f010109c:	85 c0                	test   %eax,%eax
f010109e:	0f 84 88 01 00 00    	je     f010122c <mon_showmappings+0x228>
f01010a4:	8b 00                	mov    (%eax),%eax
f01010a6:	89 c2                	mov    %eax,%edx
f01010a8:	81 e2 81 00 00 00    	and    $0x81,%edx
f01010ae:	81 fa 81 00 00 00    	cmp    $0x81,%edx
f01010b4:	0f 85 b5 00 00 00    	jne    f010116f <mon_showmappings+0x16b>
          cprintf("0x%08x - 0x%08x   ",begin,begin+PTSIZE-1);
f01010ba:	8d 86 ff ff 3f 00    	lea    0x3fffff(%esi),%eax
f01010c0:	89 44 24 08          	mov    %eax,0x8(%esp)
f01010c4:	89 74 24 04          	mov    %esi,0x4(%esp)
f01010c8:	c7 04 24 99 82 10 f0 	movl   $0xf0108299,(%esp)
f01010cf:	e8 33 3a 00 00       	call   f0104b07 <cprintf>
          cprintf("0x%08x - 0x%08x   ",PTE_ADDR(*pte),PTE_ADDR(*pte)+PTSIZE-1);
f01010d4:	8b 03                	mov    (%ebx),%eax
f01010d6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01010db:	8d 90 ff ff 3f 00    	lea    0x3fffff(%eax),%edx
f01010e1:	89 54 24 08          	mov    %edx,0x8(%esp)
f01010e5:	89 44 24 04          	mov    %eax,0x4(%esp)
f01010e9:	c7 04 24 99 82 10 f0 	movl   $0xf0108299,(%esp)
f01010f0:	e8 12 3a 00 00       	call   f0104b07 <cprintf>
          cprintf("kernel:");
f01010f5:	c7 04 24 ac 82 10 f0 	movl   $0xf01082ac,(%esp)
f01010fc:	e8 06 3a 00 00       	call   f0104b07 <cprintf>
          if((*pte)& PTE_W)
f0101101:	f6 03 02             	testb  $0x2,(%ebx)
f0101104:	74 0e                	je     f0101114 <mon_showmappings+0x110>
            cprintf("R/W  ");
f0101106:	c7 04 24 b4 82 10 f0 	movl   $0xf01082b4,(%esp)
f010110d:	e8 f5 39 00 00       	call   f0104b07 <cprintf>
f0101112:	eb 0c                	jmp    f0101120 <mon_showmappings+0x11c>
          else
            cprintf("R/-  ");
f0101114:	c7 04 24 ba 82 10 f0 	movl   $0xf01082ba,(%esp)
f010111b:	e8 e7 39 00 00       	call   f0104b07 <cprintf>
          cprintf("user:");
f0101120:	c7 04 24 c0 82 10 f0 	movl   $0xf01082c0,(%esp)
f0101127:	e8 db 39 00 00       	call   f0104b07 <cprintf>
          if((*pte)& PTE_U){
f010112c:	8b 03                	mov    (%ebx),%eax
f010112e:	a8 04                	test   $0x4,%al
f0101130:	74 20                	je     f0101152 <mon_showmappings+0x14e>
              if((*pte)& PTE_W)
f0101132:	a8 02                	test   $0x2,%al
f0101134:	74 0e                	je     f0101144 <mon_showmappings+0x140>
                cprintf("R/W  \n");
f0101136:	c7 04 24 c6 82 10 f0 	movl   $0xf01082c6,(%esp)
f010113d:	e8 c5 39 00 00       	call   f0104b07 <cprintf>
f0101142:	eb 1a                	jmp    f010115e <mon_showmappings+0x15a>
              else
                cprintf("R/-  \n");
f0101144:	c7 04 24 cd 82 10 f0 	movl   $0xf01082cd,(%esp)
f010114b:	e8 b7 39 00 00       	call   f0104b07 <cprintf>
f0101150:	eb 0c                	jmp    f010115e <mon_showmappings+0x15a>
          }
          else
            cprintf("-/-  \n");
f0101152:	c7 04 24 d4 82 10 f0 	movl   $0xf01082d4,(%esp)
f0101159:	e8 a9 39 00 00       	call   f0104b07 <cprintf>
          if(begin + PTSIZE < begin)
f010115e:	81 c6 00 00 40 00    	add    $0x400000,%esi
f0101164:	0f 83 d0 00 00 00    	jae    f010123a <mon_showmappings+0x236>
f010116a:	e9 d7 00 00 00       	jmp    f0101246 <mon_showmappings+0x242>
            break;
          begin += PTSIZE;
      }
      else if(pte && ((*pte) & PTE_P)){
f010116f:	a8 01                	test   $0x1,%al
f0101171:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101178:	0f 84 ae 00 00 00    	je     f010122c <mon_showmappings+0x228>
          cprintf("0x%08x - 0x%08x   ",begin,begin+PGSIZE-1);
f010117e:	8d 86 ff 0f 00 00    	lea    0xfff(%esi),%eax
f0101184:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101188:	89 74 24 04          	mov    %esi,0x4(%esp)
f010118c:	c7 04 24 99 82 10 f0 	movl   $0xf0108299,(%esp)
f0101193:	e8 6f 39 00 00       	call   f0104b07 <cprintf>
          cprintf("0x%08x - 0x%08x   ",PTE_ADDR(*pte),PTE_ADDR(*pte)+PGSIZE-1);
f0101198:	8b 03                	mov    (%ebx),%eax
f010119a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010119f:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f01011a5:	89 54 24 08          	mov    %edx,0x8(%esp)
f01011a9:	89 44 24 04          	mov    %eax,0x4(%esp)
f01011ad:	c7 04 24 99 82 10 f0 	movl   $0xf0108299,(%esp)
f01011b4:	e8 4e 39 00 00       	call   f0104b07 <cprintf>
          cprintf("kernel:");
f01011b9:	c7 04 24 ac 82 10 f0 	movl   $0xf01082ac,(%esp)
f01011c0:	e8 42 39 00 00       	call   f0104b07 <cprintf>
          if((*pte)& PTE_W)
f01011c5:	f6 03 02             	testb  $0x2,(%ebx)
f01011c8:	74 0e                	je     f01011d8 <mon_showmappings+0x1d4>
            cprintf("R/W  ");
f01011ca:	c7 04 24 b4 82 10 f0 	movl   $0xf01082b4,(%esp)
f01011d1:	e8 31 39 00 00       	call   f0104b07 <cprintf>
f01011d6:	eb 0c                	jmp    f01011e4 <mon_showmappings+0x1e0>
          else
            cprintf("R/-  ");
f01011d8:	c7 04 24 ba 82 10 f0 	movl   $0xf01082ba,(%esp)
f01011df:	e8 23 39 00 00       	call   f0104b07 <cprintf>
          cprintf("user:");
f01011e4:	c7 04 24 c0 82 10 f0 	movl   $0xf01082c0,(%esp)
f01011eb:	e8 17 39 00 00       	call   f0104b07 <cprintf>
          if((*pte)& PTE_U){
f01011f0:	8b 03                	mov    (%ebx),%eax
f01011f2:	a8 04                	test   $0x4,%al
f01011f4:	74 20                	je     f0101216 <mon_showmappings+0x212>
              if((*pte)& PTE_W)
f01011f6:	a8 02                	test   $0x2,%al
f01011f8:	74 0e                	je     f0101208 <mon_showmappings+0x204>
                cprintf("R/W  \n");
f01011fa:	c7 04 24 c6 82 10 f0 	movl   $0xf01082c6,(%esp)
f0101201:	e8 01 39 00 00       	call   f0104b07 <cprintf>
f0101206:	eb 1a                	jmp    f0101222 <mon_showmappings+0x21e>
              else
                cprintf("R/-  \n");
f0101208:	c7 04 24 cd 82 10 f0 	movl   $0xf01082cd,(%esp)
f010120f:	e8 f3 38 00 00       	call   f0104b07 <cprintf>
f0101214:	eb 0c                	jmp    f0101222 <mon_showmappings+0x21e>
          }
          else
            cprintf("-/-  \n");
f0101216:	c7 04 24 d4 82 10 f0 	movl   $0xf01082d4,(%esp)
f010121d:	e8 e5 38 00 00       	call   f0104b07 <cprintf>
          if(begin + PGSIZE < begin)
f0101222:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0101228:	73 10                	jae    f010123a <mon_showmappings+0x236>
f010122a:	eb 1a                	jmp    f0101246 <mon_showmappings+0x242>
             break;
          begin += PGSIZE;
      }
      else{
          if(begin + PGSIZE < begin)
f010122c:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0101232:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0101238:	72 0c                	jb     f0101246 <mon_showmappings+0x242>
   uintptr_t end = strtol(argv[2],0,0);
   if(begin > end || begin != ROUNDUP(begin,PGSIZE)){
      cprintf("wrong virtual address\n");
      return 0;
   }
   while(begin < end){
f010123a:	39 f7                	cmp    %esi,%edi
f010123c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101240:	0f 87 3b fe ff ff    	ja     f0101081 <mon_showmappings+0x7d>
            break;
          begin += PGSIZE;
      }
   }
   return 0;
}
f0101246:	b8 00 00 00 00       	mov    $0x0,%eax
f010124b:	83 c4 1c             	add    $0x1c,%esp
f010124e:	5b                   	pop    %ebx
f010124f:	5e                   	pop    %esi
f0101250:	5f                   	pop    %edi
f0101251:	5d                   	pop    %ebp
f0101252:	c3                   	ret    

f0101253 <mon_dump>:
    return 0;
}

int 
mon_dump(int argc,char** argv,struct Trapframe* tf)
{
f0101253:	55                   	push   %ebp
f0101254:	89 e5                	mov    %esp,%ebp
f0101256:	57                   	push   %edi
f0101257:	56                   	push   %esi
f0101258:	53                   	push   %ebx
f0101259:	83 ec 2c             	sub    $0x2c,%esp
f010125c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
   if(argc != 4){
f010125f:	83 7d 08 04          	cmpl   $0x4,0x8(%ebp)
f0101263:	74 11                	je     f0101276 <mon_dump+0x23>
      cprintf("Usage: dump [op] [addr] [size]\n");
f0101265:	c7 04 24 14 85 10 f0 	movl   $0xf0108514,(%esp)
f010126c:	e8 96 38 00 00       	call   f0104b07 <cprintf>
      return 0;
f0101271:	e9 75 02 00 00       	jmp    f01014eb <mon_dump+0x298>
   }
   char* op = argv[1];
f0101276:	8b 73 04             	mov    0x4(%ebx),%esi
   uint32_t size = strtol(argv[3],0,0);
f0101279:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101280:	00 
f0101281:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101288:	00 
f0101289:	8b 43 0c             	mov    0xc(%ebx),%eax
f010128c:	89 04 24             	mov    %eax,(%esp)
f010128f:	e8 f7 5e 00 00       	call   f010718b <strtol>
f0101294:	89 45 e4             	mov    %eax,-0x1c(%ebp)
   uint32_t value = 0;
   if(strcmp(op,"v") == 0){
f0101297:	c7 44 24 04 cb 92 10 	movl   $0xf01092cb,0x4(%esp)
f010129e:	f0 
f010129f:	89 34 24             	mov    %esi,(%esp)
f01012a2:	e8 9e 5c 00 00       	call   f0106f45 <strcmp>
f01012a7:	85 c0                	test   %eax,%eax
f01012a9:	0f 85 e6 00 00 00    	jne    f0101395 <mon_dump+0x142>
      uintptr_t addr = strtol(argv[2],0,0); 
f01012af:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01012b6:	00 
f01012b7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01012be:	00 
f01012bf:	8b 43 08             	mov    0x8(%ebx),%eax
f01012c2:	89 04 24             	mov    %eax,(%esp)
f01012c5:	e8 c1 5e 00 00       	call   f010718b <strtol>
f01012ca:	89 c3                	mov    %eax,%ebx
      if(addr != ROUNDUP(addr,PGSIZE)){
f01012cc:	8d 80 ff 0f 00 00    	lea    0xfff(%eax),%eax
f01012d2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01012d7:	39 c3                	cmp    %eax,%ebx
f01012d9:	75 18                	jne    f01012f3 <mon_dump+0xa0>
        cprintf("wrong address\n");
        return 0;
      }     
      int i = 0;
      for(i = 0; i<size;i++){
f01012db:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01012df:	0f 84 9f 00 00 00    	je     f0101384 <mon_dump+0x131>
f01012e5:	89 df                	mov    %ebx,%edi
f01012e7:	b8 00 00 00 00       	mov    $0x0,%eax
f01012ec:	be 00 00 00 00       	mov    $0x0,%esi
f01012f1:	eb 21                	jmp    f0101314 <mon_dump+0xc1>
   uint32_t size = strtol(argv[3],0,0);
   uint32_t value = 0;
   if(strcmp(op,"v") == 0){
      uintptr_t addr = strtol(argv[2],0,0); 
      if(addr != ROUNDUP(addr,PGSIZE)){
        cprintf("wrong address\n");
f01012f3:	c7 04 24 db 82 10 f0 	movl   $0xf01082db,(%esp)
f01012fa:	e8 08 38 00 00       	call   f0104b07 <cprintf>
        return 0;
f01012ff:	e9 e7 01 00 00       	jmp    f01014eb <mon_dump+0x298>
      }     
      int i = 0;
      for(i = 0; i<size;i++){
        if(addr + i*4 < addr + (i-1)*4 && i != 0)
f0101304:	89 fb                	mov    %edi,%ebx
f0101306:	83 c3 04             	add    $0x4,%ebx
f0101309:	73 07                	jae    f0101312 <mon_dump+0xbf>
f010130b:	85 f6                	test   %esi,%esi
f010130d:	8d 76 00             	lea    0x0(%esi),%esi
f0101310:	75 72                	jne    f0101384 <mon_dump+0x131>
f0101312:	89 df                	mov    %ebx,%edi
            break;
        if(i%4 == 0){
f0101314:	a8 03                	test   $0x3,%al
f0101316:	75 20                	jne    f0101338 <mon_dump+0xe5>
          if(i != 0)
f0101318:	85 f6                	test   %esi,%esi
f010131a:	74 0c                	je     f0101328 <mon_dump+0xd5>
             cprintf("\n");
f010131c:	c7 04 24 d9 82 10 f0 	movl   $0xf01082d9,(%esp)
f0101323:	e8 df 37 00 00       	call   f0104b07 <cprintf>
          cprintf("0x%08x: ",addr + i*4);
f0101328:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010132c:	c7 04 24 ea 82 10 f0 	movl   $0xf01082ea,(%esp)
f0101333:	e8 cf 37 00 00       	call   f0104b07 <cprintf>
        }
        pte_t* pte = pgdir_walk(kern_pgdir,(void*)(addr+i*4),0);
f0101338:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010133f:	00 
f0101340:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101344:	a1 ac de 24 f0       	mov    0xf024deac,%eax
f0101349:	89 04 24             	mov    %eax,(%esp)
f010134c:	e8 b4 0d 00 00       	call   f0102105 <pgdir_walk>
        if((!pte) || (!(*pte) & PTE_P))
f0101351:	85 c0                	test   %eax,%eax
f0101353:	74 05                	je     f010135a <mon_dump+0x107>
f0101355:	83 38 00             	cmpl   $0x0,(%eax)
f0101358:	75 0e                	jne    f0101368 <mon_dump+0x115>
            cprintf("--         ");
f010135a:	c7 04 24 f3 82 10 f0 	movl   $0xf01082f3,(%esp)
f0101361:	e8 a1 37 00 00       	call   f0104b07 <cprintf>
          if(i != 0)
             cprintf("\n");
          cprintf("0x%08x: ",addr + i*4);
        }
        pte_t* pte = pgdir_walk(kern_pgdir,(void*)(addr+i*4),0);
        if((!pte) || (!(*pte) & PTE_P))
f0101366:	eb 12                	jmp    f010137a <mon_dump+0x127>
            cprintf("--         ");
        else{
          value = *((uint32_t*)(addr + i*4));
          cprintf("0x%08x ",value);
f0101368:	8b 03                	mov    (%ebx),%eax
f010136a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010136e:	c7 04 24 ff 82 10 f0 	movl   $0xf01082ff,(%esp)
f0101375:	e8 8d 37 00 00       	call   f0104b07 <cprintf>
      if(addr != ROUNDUP(addr,PGSIZE)){
        cprintf("wrong address\n");
        return 0;
      }     
      int i = 0;
      for(i = 0; i<size;i++){
f010137a:	83 c6 01             	add    $0x1,%esi
f010137d:	89 f0                	mov    %esi,%eax
f010137f:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
f0101382:	77 80                	ja     f0101304 <mon_dump+0xb1>
        else{
          value = *((uint32_t*)(addr + i*4));
          cprintf("0x%08x ",value);
        }
      }
      cprintf("\n");
f0101384:	c7 04 24 d9 82 10 f0 	movl   $0xf01082d9,(%esp)
f010138b:	e8 77 37 00 00       	call   f0104b07 <cprintf>
f0101390:	e9 56 01 00 00       	jmp    f01014eb <mon_dump+0x298>
    }
    else if(strcmp(op,"p") == 0){
f0101395:	c7 44 24 04 d6 83 10 	movl   $0xf01083d6,0x4(%esp)
f010139c:	f0 
f010139d:	89 34 24             	mov    %esi,(%esp)
f01013a0:	e8 a0 5b 00 00       	call   f0106f45 <strcmp>
f01013a5:	85 c0                	test   %eax,%eax
f01013a7:	0f 85 32 01 00 00    	jne    f01014df <mon_dump+0x28c>
        physaddr_t addr = strtol(argv[2],0,0); 
f01013ad:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01013b4:	00 
f01013b5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01013bc:	00 
f01013bd:	8b 43 08             	mov    0x8(%ebx),%eax
f01013c0:	89 04 24             	mov    %eax,(%esp)
f01013c3:	e8 c3 5d 00 00       	call   f010718b <strtol>
f01013c8:	89 c7                	mov    %eax,%edi
        if(addr != ROUNDUP(addr,PGSIZE)){
f01013ca:	8d 80 ff 0f 00 00    	lea    0xfff(%eax),%eax
f01013d0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01013d5:	39 c7                	cmp    %eax,%edi
f01013d7:	75 1f                	jne    f01013f8 <mon_dump+0x1a5>
           cprintf("wrong address\n");
           return 0;
        }  
        uintptr_t vaddr = 0;   
        int i = 0;       
        for(i = 0; i<size;i++){
f01013d9:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01013dd:	0f 84 ee 00 00 00    	je     f01014d1 <mon_dump+0x27e>
f01013e3:	89 fe                	mov    %edi,%esi
f01013e5:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f01013ec:	b8 00 00 00 00       	mov    $0x0,%eax
f01013f1:	bb 00 00 00 00       	mov    $0x0,%ebx
f01013f6:	eb 2c                	jmp    f0101424 <mon_dump+0x1d1>
      cprintf("\n");
    }
    else if(strcmp(op,"p") == 0){
        physaddr_t addr = strtol(argv[2],0,0); 
        if(addr != ROUNDUP(addr,PGSIZE)){
           cprintf("wrong address\n");
f01013f8:	c7 04 24 db 82 10 f0 	movl   $0xf01082db,(%esp)
f01013ff:	e8 03 37 00 00       	call   f0104b07 <cprintf>
           return 0;
f0101404:	e9 e2 00 00 00       	jmp    f01014eb <mon_dump+0x298>
f0101409:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
f0101410:	89 55 e0             	mov    %edx,-0x20(%ebp)
        }  
        uintptr_t vaddr = 0;   
        int i = 0;       
        for(i = 0; i<size;i++){
          if(addr + i*4 < addr + (i-1)*4 && i != 0)
f0101413:	89 fe                	mov    %edi,%esi
f0101415:	83 c6 04             	add    $0x4,%esi
f0101418:	73 08                	jae    f0101422 <mon_dump+0x1cf>
f010141a:	85 db                	test   %ebx,%ebx
f010141c:	0f 85 af 00 00 00    	jne    f01014d1 <mon_dump+0x27e>
f0101422:	89 f7                	mov    %esi,%edi
              break;
          if(i%4 == 0){
f0101424:	a8 03                	test   $0x3,%al
f0101426:	75 20                	jne    f0101448 <mon_dump+0x1f5>
             if(i != 0)
f0101428:	85 db                	test   %ebx,%ebx
f010142a:	74 0c                	je     f0101438 <mon_dump+0x1e5>
               cprintf("\n");
f010142c:	c7 04 24 d9 82 10 f0 	movl   $0xf01082d9,(%esp)
f0101433:	e8 cf 36 00 00       	call   f0104b07 <cprintf>
             cprintf("0x%08x: ",addr + i*4);
f0101438:	89 74 24 04          	mov    %esi,0x4(%esp)
f010143c:	c7 04 24 ea 82 10 f0 	movl   $0xf01082ea,(%esp)
f0101443:	e8 bf 36 00 00       	call   f0104b07 <cprintf>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101448:	89 f0                	mov    %esi,%eax
f010144a:	c1 e8 0c             	shr    $0xc,%eax
f010144d:	3b 05 a8 de 24 f0    	cmp    0xf024dea8,%eax
f0101453:	72 20                	jb     f0101475 <mon_dump+0x222>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101455:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0101459:	c7 44 24 08 80 7e 10 	movl   $0xf0107e80,0x8(%esp)
f0101460:	f0 
f0101461:	c7 44 24 04 35 01 00 	movl   $0x135,0x4(%esp)
f0101468:	00 
f0101469:	c7 04 24 07 83 10 f0 	movl   $0xf0108307,(%esp)
f0101470:	e8 10 ec ff ff       	call   f0100085 <_panic>
	return (void *)(pa + KERNBASE);
f0101475:	81 ee 00 00 00 10    	sub    $0x10000000,%esi
          }
          vaddr = (uintptr_t)KADDR(addr + i*4);
          pte_t* pte = pgdir_walk(kern_pgdir,(void*)(vaddr+i*4),0);
f010147b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101482:	00 
f0101483:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0101486:	8d 04 16             	lea    (%esi,%edx,1),%eax
f0101489:	89 44 24 04          	mov    %eax,0x4(%esp)
f010148d:	a1 ac de 24 f0       	mov    0xf024deac,%eax
f0101492:	89 04 24             	mov    %eax,(%esp)
f0101495:	e8 6b 0c 00 00       	call   f0102105 <pgdir_walk>
          if((!pte) || (!(*pte) & PTE_P))
f010149a:	85 c0                	test   %eax,%eax
f010149c:	74 05                	je     f01014a3 <mon_dump+0x250>
f010149e:	83 38 00             	cmpl   $0x0,(%eax)
f01014a1:	75 0e                	jne    f01014b1 <mon_dump+0x25e>
              cprintf("--         ");
f01014a3:	c7 04 24 f3 82 10 f0 	movl   $0xf01082f3,(%esp)
f01014aa:	e8 58 36 00 00       	call   f0104b07 <cprintf>
               cprintf("\n");
             cprintf("0x%08x: ",addr + i*4);
          }
          vaddr = (uintptr_t)KADDR(addr + i*4);
          pte_t* pte = pgdir_walk(kern_pgdir,(void*)(vaddr+i*4),0);
          if((!pte) || (!(*pte) & PTE_P))
f01014af:	eb 12                	jmp    f01014c3 <mon_dump+0x270>
              cprintf("--         ");
          else{
            value = *((uint32_t*)(vaddr));
            cprintf("0x%08x ",value);
f01014b1:	8b 06                	mov    (%esi),%eax
f01014b3:	89 44 24 04          	mov    %eax,0x4(%esp)
f01014b7:	c7 04 24 ff 82 10 f0 	movl   $0xf01082ff,(%esp)
f01014be:	e8 44 36 00 00       	call   f0104b07 <cprintf>
           cprintf("wrong address\n");
           return 0;
        }  
        uintptr_t vaddr = 0;   
        int i = 0;       
        for(i = 0; i<size;i++){
f01014c3:	83 c3 01             	add    $0x1,%ebx
f01014c6:	89 d8                	mov    %ebx,%eax
f01014c8:	39 5d e4             	cmp    %ebx,-0x1c(%ebp)
f01014cb:	0f 87 38 ff ff ff    	ja     f0101409 <mon_dump+0x1b6>
          else{
            value = *((uint32_t*)(vaddr));
            cprintf("0x%08x ",value);
          }
        }
         cprintf("\n");
f01014d1:	c7 04 24 d9 82 10 f0 	movl   $0xf01082d9,(%esp)
f01014d8:	e8 2a 36 00 00       	call   f0104b07 <cprintf>
f01014dd:	eb 0c                	jmp    f01014eb <mon_dump+0x298>
    }
    else{
        cprintf("Usage: dump [op] [addr] [size]\n");
f01014df:	c7 04 24 14 85 10 f0 	movl   $0xf0108514,(%esp)
f01014e6:	e8 1c 36 00 00       	call   f0104b07 <cprintf>
        return 0;
    }
    return 0;
}
f01014eb:	b8 00 00 00 00       	mov    $0x0,%eax
f01014f0:	83 c4 2c             	add    $0x2c,%esp
f01014f3:	5b                   	pop    %ebx
f01014f4:	5e                   	pop    %esi
f01014f5:	5f                   	pop    %edi
f01014f6:	5d                   	pop    %ebp
f01014f7:	c3                   	ret    

f01014f8 <mon_c>:
  }
  return 0;
}

int 
mon_c(int argc,char **argv,struct Trapframe *tf){
f01014f8:	55                   	push   %ebp
f01014f9:	89 e5                	mov    %esp,%ebp
f01014fb:	83 ec 38             	sub    $0x38,%esp
f01014fe:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0101501:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0101504:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0101507:	8b 75 10             	mov    0x10(%ebp),%esi
  if(argc != 1)
f010150a:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
f010150e:	74 0e                	je     f010151e <mon_c+0x26>
    cprintf("Usage: c\n");
f0101510:	c7 04 24 16 83 10 f0 	movl   $0xf0108316,(%esp)
f0101517:	e8 eb 35 00 00       	call   f0104b07 <cprintf>
f010151c:	eb 48                	jmp    f0101566 <mon_c+0x6e>
  else if(tf == NULL)
f010151e:	85 f6                	test   %esi,%esi
f0101520:	75 0e                	jne    f0101530 <mon_c+0x38>
    cprintf("trapframe error\n");
f0101522:	c7 04 24 49 82 10 f0 	movl   $0xf0108249,(%esp)
f0101529:	e8 d9 35 00 00       	call   f0104b07 <cprintf>
f010152e:	eb 36                	jmp    f0101566 <mon_c+0x6e>
  else{
     curenv->env_tf = *tf;		
f0101530:	e8 89 61 00 00       	call   f01076be <cpunum>
f0101535:	bb 20 e0 24 f0       	mov    $0xf024e020,%ebx
f010153a:	6b c0 74             	imul   $0x74,%eax,%eax
f010153d:	8b 44 18 08          	mov    0x8(%eax,%ebx,1),%eax
f0101541:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0101544:	b9 11 00 00 00       	mov    $0x11,%ecx
f0101549:	89 c7                	mov    %eax,%edi
f010154b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
     tf = &curenv->env_tf;
f010154d:	e8 6c 61 00 00       	call   f01076be <cpunum>
     env_run(curenv);
f0101552:	e8 67 61 00 00       	call   f01076be <cpunum>
f0101557:	6b c0 74             	imul   $0x74,%eax,%eax
f010155a:	8b 44 18 08          	mov    0x8(%eax,%ebx,1),%eax
f010155e:	89 04 24             	mov    %eax,(%esp)
f0101561:	e8 64 2d 00 00       	call   f01042ca <env_run>
  }

  return 0;
} 
f0101566:	b8 00 00 00 00       	mov    $0x0,%eax
f010156b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f010156e:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0101571:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0101574:	89 ec                	mov    %ebp,%esp
f0101576:	5d                   	pop    %ebp
f0101577:	c3                   	ret    

f0101578 <mon_si>:
    }
    return 0;
}

int 
mon_si(int argc,char **argv,struct Trapframe *tf){
f0101578:	55                   	push   %ebp
f0101579:	89 e5                	mov    %esp,%ebp
f010157b:	83 ec 68             	sub    $0x68,%esp
f010157e:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0101581:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0101584:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0101587:	8b 75 10             	mov    0x10(%ebp),%esi
  if(argc != 1)
f010158a:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
f010158e:	74 11                	je     f01015a1 <mon_si+0x29>
    cprintf("Usage: si\n");
f0101590:	c7 04 24 20 83 10 f0 	movl   $0xf0108320,(%esp)
f0101597:	e8 6b 35 00 00       	call   f0104b07 <cprintf>
f010159c:	e9 a2 00 00 00       	jmp    f0101643 <mon_si+0xcb>
  else if(tf == NULL)
f01015a1:	85 f6                	test   %esi,%esi
f01015a3:	75 11                	jne    f01015b6 <mon_si+0x3e>
    cprintf("trapframe error\n");
f01015a5:	c7 04 24 49 82 10 f0 	movl   $0xf0108249,(%esp)
f01015ac:	e8 56 35 00 00       	call   f0104b07 <cprintf>
f01015b1:	e9 8d 00 00 00       	jmp    f0101643 <mon_si+0xcb>
  else{
    struct Eipdebuginfo info;
    tf->tf_eflags = tf->tf_eflags | 0x100;
f01015b6:	81 4e 38 00 01 00 00 	orl    $0x100,0x38(%esi)
    cprintf("tf_eip=%08x\n",tf->tf_eip);
f01015bd:	8b 46 30             	mov    0x30(%esi),%eax
f01015c0:	89 44 24 04          	mov    %eax,0x4(%esp)
f01015c4:	c7 04 24 2b 83 10 f0 	movl   $0xf010832b,(%esp)
f01015cb:	e8 37 35 00 00       	call   f0104b07 <cprintf>
    debuginfo_eip(tf->tf_eip,&info);
f01015d0:	8d 45 d0             	lea    -0x30(%ebp),%eax
f01015d3:	89 44 24 04          	mov    %eax,0x4(%esp)
f01015d7:	8b 46 30             	mov    0x30(%esi),%eax
f01015da:	89 04 24             	mov    %eax,(%esp)
f01015dd:	e8 ec 4c 00 00       	call   f01062ce <debuginfo_eip>
    cprintf("%s:%d: %s+%d\n",info.eip_file,info.eip_line,info.eip_fn_name,tf->tf_eip-info.eip_fn_addr);
f01015e2:	8b 46 30             	mov    0x30(%esi),%eax
f01015e5:	2b 45 e0             	sub    -0x20(%ebp),%eax
f01015e8:	89 44 24 10          	mov    %eax,0x10(%esp)
f01015ec:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01015ef:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01015f3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01015f6:	89 44 24 08          	mov    %eax,0x8(%esp)
f01015fa:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01015fd:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101601:	c7 04 24 17 82 10 f0 	movl   $0xf0108217,(%esp)
f0101608:	e8 fa 34 00 00       	call   f0104b07 <cprintf>
    curenv->env_tf = *tf;		
f010160d:	e8 ac 60 00 00       	call   f01076be <cpunum>
f0101612:	bb 20 e0 24 f0       	mov    $0xf024e020,%ebx
f0101617:	6b c0 74             	imul   $0x74,%eax,%eax
f010161a:	8b 44 18 08          	mov    0x8(%eax,%ebx,1),%eax
f010161e:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0101621:	b9 11 00 00 00       	mov    $0x11,%ecx
f0101626:	89 c7                	mov    %eax,%edi
f0101628:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
    tf = &curenv->env_tf;
f010162a:	e8 8f 60 00 00       	call   f01076be <cpunum>
    env_run(curenv);
f010162f:	e8 8a 60 00 00       	call   f01076be <cpunum>
f0101634:	6b c0 74             	imul   $0x74,%eax,%eax
f0101637:	8b 44 18 08          	mov    0x8(%eax,%ebx,1),%eax
f010163b:	89 04 24             	mov    %eax,(%esp)
f010163e:	e8 87 2c 00 00       	call   f01042ca <env_run>
  }
  return 0;
}
f0101643:	b8 00 00 00 00       	mov    $0x0,%eax
f0101648:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f010164b:	8b 75 f8             	mov    -0x8(%ebp),%esi
f010164e:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0101651:	89 ec                	mov    %ebp,%esp
f0101653:	5d                   	pop    %ebp
f0101654:	c3                   	ret    
	...

f0101660 <page_free_npages>:
//	2. Add the pages to the chunk list
//	
//	Return 0 if everything ok
int
page_free_npages(struct Page *pp, int n)
{
f0101660:	55                   	push   %ebp
f0101661:	89 e5                	mov    %esp,%ebp
f0101663:	53                   	push   %ebx
f0101664:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// Fill this function
        struct Page* tmpPP = pp;
        int i = 0;
        if(pp == NULL)
f0101667:	85 db                	test   %ebx,%ebx
f0101669:	74 3c                	je     f01016a7 <page_free_npages+0x47>
            return -1;
        for(i = 0;i< n-1;i++){
f010166b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010166e:	83 e9 01             	sub    $0x1,%ecx
f0101671:	89 d8                	mov    %ebx,%eax
f0101673:	85 c9                	test   %ecx,%ecx
f0101675:	7e 1b                	jle    f0101692 <page_free_npages+0x32>
             if(tmpPP->pp_link == NULL)
f0101677:	8b 03                	mov    (%ebx),%eax
f0101679:	ba 00 00 00 00       	mov    $0x0,%edx
f010167e:	85 c0                	test   %eax,%eax
f0101680:	75 08                	jne    f010168a <page_free_npages+0x2a>
f0101682:	eb 23                	jmp    f01016a7 <page_free_npages+0x47>
f0101684:	8b 00                	mov    (%eax),%eax
f0101686:	85 c0                	test   %eax,%eax
f0101688:	74 1d                	je     f01016a7 <page_free_npages+0x47>
	// Fill this function
        struct Page* tmpPP = pp;
        int i = 0;
        if(pp == NULL)
            return -1;
        for(i = 0;i< n-1;i++){
f010168a:	83 c2 01             	add    $0x1,%edx
f010168d:	39 ca                	cmp    %ecx,%edx
f010168f:	90                   	nop
f0101690:	7c f2                	jl     f0101684 <page_free_npages+0x24>
             if(tmpPP->pp_link == NULL)
                 return -1;
             tmpPP = tmpPP->pp_link;
        }
        tmpPP->pp_link = page_free_list;
f0101692:	8b 15 50 d2 24 f0    	mov    0xf024d250,%edx
f0101698:	89 10                	mov    %edx,(%eax)
        page_free_list = pp;
f010169a:	89 1d 50 d2 24 f0    	mov    %ebx,0xf024d250
f01016a0:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
f01016a5:	eb 05                	jmp    f01016ac <page_free_npages+0x4c>
f01016a7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f01016ac:	5b                   	pop    %ebx
f01016ad:	5d                   	pop    %ebp
f01016ae:	c3                   	ret    

f01016af <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct Page *pp)
{
f01016af:	55                   	push   %ebp
f01016b0:	89 e5                	mov    %esp,%ebp
f01016b2:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
        pp->pp_link = page_free_list;
f01016b5:	8b 15 50 d2 24 f0    	mov    0xf024d250,%edx
f01016bb:	89 10                	mov    %edx,(%eax)
        page_free_list = pp;
f01016bd:	a3 50 d2 24 f0       	mov    %eax,0xf024d250
}
f01016c2:	5d                   	pop    %ebp
f01016c3:	c3                   	ret    

f01016c4 <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct Page* pp)
{
f01016c4:	55                   	push   %ebp
f01016c5:	89 e5                	mov    %esp,%ebp
f01016c7:	83 ec 04             	sub    $0x4,%esp
f01016ca:	8b 45 08             	mov    0x8(%ebp),%eax
	if (--pp->pp_ref == 0)
f01016cd:	0f b7 50 04          	movzwl 0x4(%eax),%edx
f01016d1:	83 ea 01             	sub    $0x1,%edx
f01016d4:	66 89 50 04          	mov    %dx,0x4(%eax)
f01016d8:	66 85 d2             	test   %dx,%dx
f01016db:	75 08                	jne    f01016e5 <page_decref+0x21>
		page_free(pp);
f01016dd:	89 04 24             	mov    %eax,(%esp)
f01016e0:	e8 ca ff ff ff       	call   f01016af <page_free>
}
f01016e5:	c9                   	leave  
f01016e6:	c3                   	ret    

f01016e7 <pgdir_walk_large>:
	return &vpt[PTX(va)];
}

pte_t*
pgdir_walk_large(pde_t *pgdir, const void *va, int create)
{
f01016e7:	55                   	push   %ebp
f01016e8:	89 e5                	mov    %esp,%ebp
f01016ea:	8b 45 0c             	mov    0xc(%ebp),%eax
f01016ed:	c1 e8 16             	shr    $0x16,%eax
f01016f0:	c1 e0 02             	shl    $0x2,%eax
f01016f3:	03 45 08             	add    0x8(%ebp),%eax
        return &pgdir[PDX(va)];
}
f01016f6:	5d                   	pop    %ebp
f01016f7:	c3                   	ret    

f01016f8 <check_va2pa_large>:
	return PTE_ADDR(p[PTX(va)]);
}

static physaddr_t
check_va2pa_large(pde_t *pgdir, uintptr_t va)
{
f01016f8:	55                   	push   %ebp
f01016f9:	89 e5                	mov    %esp,%ebp
	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P) | !(*pgdir & PTE_PS))
f01016fb:	c1 ea 16             	shr    $0x16,%edx
f01016fe:	8b 04 90             	mov    (%eax,%edx,4),%eax
f0101701:	89 c2                	mov    %eax,%edx
f0101703:	81 e2 81 00 00 00    	and    $0x81,%edx
f0101709:	89 c1                	mov    %eax,%ecx
f010170b:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0101711:	81 fa 81 00 00 00    	cmp    $0x81,%edx
f0101717:	0f 94 c0             	sete   %al
f010171a:	0f b6 c0             	movzbl %al,%eax
f010171d:	83 e8 01             	sub    $0x1,%eax
f0101720:	09 c8                	or     %ecx,%eax
		return ~0;
	return PTE_ADDR(*pgdir);
}
f0101722:	5d                   	pop    %ebp
f0101723:	c3                   	ret    

f0101724 <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f0101724:	55                   	push   %ebp
f0101725:	89 e5                	mov    %esp,%ebp
f0101727:	83 ec 08             	sub    $0x8,%esp
	// Flush the entry only if we're modifying the current address space.
	if (!curenv || curenv->env_pgdir == pgdir)
f010172a:	e8 8f 5f 00 00       	call   f01076be <cpunum>
f010172f:	6b c0 74             	imul   $0x74,%eax,%eax
f0101732:	83 b8 28 e0 24 f0 00 	cmpl   $0x0,-0xfdb1fd8(%eax)
f0101739:	74 16                	je     f0101751 <tlb_invalidate+0x2d>
f010173b:	e8 7e 5f 00 00       	call   f01076be <cpunum>
f0101740:	6b c0 74             	imul   $0x74,%eax,%eax
f0101743:	8b 90 28 e0 24 f0    	mov    -0xfdb1fd8(%eax),%edx
f0101749:	8b 45 08             	mov    0x8(%ebp),%eax
f010174c:	39 42 64             	cmp    %eax,0x64(%edx)
f010174f:	75 06                	jne    f0101757 <tlb_invalidate+0x33>
}

static __inline void 
invlpg(void *addr)
{ 
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0101751:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101754:	0f 01 38             	invlpg (%eax)
		invlpg(va);
}
f0101757:	c9                   	leave  
f0101758:	c3                   	ret    

f0101759 <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0101759:	55                   	push   %ebp
f010175a:	89 e5                	mov    %esp,%ebp
f010175c:	83 ec 18             	sub    $0x18,%esp
f010175f:	89 c2                	mov    %eax,%edx
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0101761:	83 3d 48 d2 24 f0 00 	cmpl   $0x0,0xf024d248
f0101768:	75 0f                	jne    f0101779 <boot_alloc+0x20>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f010176a:	b8 03 00 29 f0       	mov    $0xf0290003,%eax
f010176f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0101774:	a3 48 d2 24 f0       	mov    %eax,0xf024d248
	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
        result = nextfree;
f0101779:	a1 48 d2 24 f0       	mov    0xf024d248,%eax
        nextfree = ROUNDUP(nextfree+n,PGSIZE);
f010177e:	8d 94 10 ff 0f 00 00 	lea    0xfff(%eax,%edx,1),%edx
f0101785:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f010178b:	89 15 48 d2 24 f0    	mov    %edx,0xf024d248
        if((uint32_t)nextfree >= 0xF0400000){    // VA's [KERNBASE, KERNBASE+4MB)
f0101791:	81 fa ff ff 3f f0    	cmp    $0xf03fffff,%edx
f0101797:	76 21                	jbe    f01017ba <boot_alloc+0x61>
           nextfree = result;
f0101799:	a3 48 d2 24 f0       	mov    %eax,0xf024d248
           panic("boot_alloc:Out of memory\n");
f010179e:	c7 44 24 08 0c 86 10 	movl   $0xf010860c,0x8(%esp)
f01017a5:	f0 
f01017a6:	c7 44 24 04 73 00 00 	movl   $0x73,0x4(%esp)
f01017ad:	00 
f01017ae:	c7 04 24 26 86 10 f0 	movl   $0xf0108626,(%esp)
f01017b5:	e8 cb e8 ff ff       	call   f0100085 <_panic>
        }
	return result;
}
f01017ba:	c9                   	leave  
f01017bb:	c3                   	ret    

f01017bc <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f01017bc:	55                   	push   %ebp
f01017bd:	89 e5                	mov    %esp,%ebp
f01017bf:	56                   	push   %esi
f01017c0:	53                   	push   %ebx
f01017c1:	83 ec 10             	sub    $0x10,%esp
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 0; i < npages; i++) {
f01017c4:	83 3d a8 de 24 f0 00 	cmpl   $0x0,0xf024dea8
f01017cb:	0f 84 41 01 00 00    	je     f0101912 <page_init+0x156>
f01017d1:	be 00 00 00 00       	mov    $0x0,%esi
f01017d6:	bb 00 00 00 00       	mov    $0x0,%ebx
                if(i == 0){
f01017db:	85 db                	test   %ebx,%ebx
f01017dd:	75 1b                	jne    f01017fa <page_init+0x3e>
                   pages[i].pp_ref = 1;
f01017df:	a1 b0 de 24 f0       	mov    0xf024deb0,%eax
f01017e4:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
                   pages[i].pp_link = NULL;
f01017ea:	a1 b0 de 24 f0       	mov    0xf024deb0,%eax
f01017ef:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
f01017f5:	e9 06 01 00 00       	jmp    f0101900 <page_init+0x144>
                }
                else if(i == MPENTRY_PADDR/PGSIZE){
f01017fa:	83 fb 07             	cmp    $0x7,%ebx
f01017fd:	75 1c                	jne    f010181b <page_init+0x5f>
                   pages[i].pp_ref = 1;
f01017ff:	a1 b0 de 24 f0       	mov    0xf024deb0,%eax
f0101804:	66 c7 40 3c 01 00    	movw   $0x1,0x3c(%eax)
                   pages[i].pp_link = NULL;
f010180a:	a1 b0 de 24 f0       	mov    0xf024deb0,%eax
f010180f:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)
f0101816:	e9 e5 00 00 00       	jmp    f0101900 <page_init+0x144>
                }
                else if(i>=1 && i < npages_basemem){
f010181b:	39 1d 4c d2 24 f0    	cmp    %ebx,0xf024d24c
f0101821:	76 2c                	jbe    f010184f <page_init+0x93>
                //else if(i >= 1 && i < MPENTRY_PADDR/PGSIZE){
                   pages[i].pp_ref = 0;
f0101823:	a1 b0 de 24 f0       	mov    0xf024deb0,%eax
f0101828:	66 c7 44 30 04 00 00 	movw   $0x0,0x4(%eax,%esi,1)
                   pages[i].pp_link = page_free_list;
f010182f:	8b 15 50 d2 24 f0    	mov    0xf024d250,%edx
f0101835:	a1 b0 de 24 f0       	mov    0xf024deb0,%eax
f010183a:	89 14 30             	mov    %edx,(%eax,%esi,1)
                   page_free_list = &pages[i];
f010183d:	89 f0                	mov    %esi,%eax
f010183f:	03 05 b0 de 24 f0    	add    0xf024deb0,%eax
f0101845:	a3 50 d2 24 f0       	mov    %eax,0xf024d250
                }
                else if(i == MPENTRY_PADDR/PGSIZE){
                   pages[i].pp_ref = 1;
                   pages[i].pp_link = NULL;
                }
                else if(i>=1 && i < npages_basemem){
f010184a:	e9 b1 00 00 00       	jmp    f0101900 <page_init+0x144>
                   pages[i].pp_ref = 0;
                   pages[i].pp_link = page_free_list;
                   page_free_list = &pages[i];
                }
                
                else if(i >= IOPHYSMEM/PGSIZE && i<EXTPHYSMEM/PGSIZE){
f010184f:	8d 83 60 ff ff ff    	lea    -0xa0(%ebx),%eax
f0101855:	83 f8 5f             	cmp    $0x5f,%eax
f0101858:	77 1d                	ja     f0101877 <page_init+0xbb>
                   pages[i].pp_ref = 1;
f010185a:	a1 b0 de 24 f0       	mov    0xf024deb0,%eax
f010185f:	66 c7 44 30 04 01 00 	movw   $0x1,0x4(%eax,%esi,1)
                   pages[i].pp_link = NULL;
f0101866:	a1 b0 de 24 f0       	mov    0xf024deb0,%eax
f010186b:	c7 04 30 00 00 00 00 	movl   $0x0,(%eax,%esi,1)
f0101872:	e9 89 00 00 00       	jmp    f0101900 <page_init+0x144>
                }
                else if(i >= EXTPHYSMEM/PGSIZE && i<((uint32_t)PADDR(boot_alloc(0)))/PGSIZE){
f0101877:	81 fb ff 00 00 00    	cmp    $0xff,%ebx
f010187d:	76 5a                	jbe    f01018d9 <page_init+0x11d>
f010187f:	b8 00 00 00 00       	mov    $0x0,%eax
f0101884:	e8 d0 fe ff ff       	call   f0101759 <boot_alloc>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0101889:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010188e:	66 90                	xchg   %ax,%ax
f0101890:	77 20                	ja     f01018b2 <page_init+0xf6>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101892:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101896:	c7 44 24 08 5c 7e 10 	movl   $0xf0107e5c,0x8(%esp)
f010189d:	f0 
f010189e:	c7 44 24 04 63 01 00 	movl   $0x163,0x4(%esp)
f01018a5:	00 
f01018a6:	c7 04 24 26 86 10 f0 	movl   $0xf0108626,(%esp)
f01018ad:	e8 d3 e7 ff ff       	call   f0100085 <_panic>
f01018b2:	8d 80 00 00 00 10    	lea    0x10000000(%eax),%eax
f01018b8:	c1 e8 0c             	shr    $0xc,%eax
f01018bb:	39 c3                	cmp    %eax,%ebx
f01018bd:	73 1a                	jae    f01018d9 <page_init+0x11d>
		   pages[i].pp_ref = 1;
f01018bf:	a1 b0 de 24 f0       	mov    0xf024deb0,%eax
f01018c4:	66 c7 44 30 04 01 00 	movw   $0x1,0x4(%eax,%esi,1)
                   pages[i].pp_link = NULL;
f01018cb:	a1 b0 de 24 f0       	mov    0xf024deb0,%eax
f01018d0:	c7 04 30 00 00 00 00 	movl   $0x0,(%eax,%esi,1)
                
                else if(i >= IOPHYSMEM/PGSIZE && i<EXTPHYSMEM/PGSIZE){
                   pages[i].pp_ref = 1;
                   pages[i].pp_link = NULL;
                }
                else if(i >= EXTPHYSMEM/PGSIZE && i<((uint32_t)PADDR(boot_alloc(0)))/PGSIZE){
f01018d7:	eb 27                	jmp    f0101900 <page_init+0x144>
		   pages[i].pp_ref = 1;
                   pages[i].pp_link = NULL;
                }
                else{
                   pages[i].pp_ref = 0;
f01018d9:	a1 b0 de 24 f0       	mov    0xf024deb0,%eax
f01018de:	66 c7 44 30 04 00 00 	movw   $0x0,0x4(%eax,%esi,1)
		   pages[i].pp_link = page_free_list;
f01018e5:	8b 15 50 d2 24 f0    	mov    0xf024d250,%edx
f01018eb:	a1 b0 de 24 f0       	mov    0xf024deb0,%eax
f01018f0:	89 14 30             	mov    %edx,(%eax,%esi,1)
		   page_free_list = &pages[i];
f01018f3:	89 f0                	mov    %esi,%eax
f01018f5:	03 05 b0 de 24 f0    	add    0xf024deb0,%eax
f01018fb:	a3 50 d2 24 f0       	mov    %eax,0xf024d250
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 0; i < npages; i++) {
f0101900:	83 c3 01             	add    $0x1,%ebx
f0101903:	83 c6 08             	add    $0x8,%esi
f0101906:	39 1d a8 de 24 f0    	cmp    %ebx,0xf024dea8
f010190c:	0f 87 c9 fe ff ff    	ja     f01017db <page_init+0x1f>
                   pages[i].pp_ref = 0;
		   pages[i].pp_link = page_free_list;
		   page_free_list = &pages[i];
                }
	}
	chunk_list = NULL;
f0101912:	c7 05 54 d2 24 f0 00 	movl   $0x0,0xf024d254
f0101919:	00 00 00 
}
f010191c:	83 c4 10             	add    $0x10,%esp
f010191f:	5b                   	pop    %ebx
f0101920:	5e                   	pop    %esi
f0101921:	5d                   	pop    %ebp
f0101922:	c3                   	ret    

f0101923 <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f0101923:	55                   	push   %ebp
f0101924:	89 e5                	mov    %esp,%ebp
f0101926:	83 ec 18             	sub    $0x18,%esp
f0101929:	89 5d f8             	mov    %ebx,-0x8(%ebp)
f010192c:	89 75 fc             	mov    %esi,-0x4(%ebp)
f010192f:	89 c3                	mov    %eax,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0101931:	89 04 24             	mov    %eax,(%esp)
f0101934:	e8 73 30 00 00       	call   f01049ac <mc146818_read>
f0101939:	89 c6                	mov    %eax,%esi
f010193b:	83 c3 01             	add    $0x1,%ebx
f010193e:	89 1c 24             	mov    %ebx,(%esp)
f0101941:	e8 66 30 00 00       	call   f01049ac <mc146818_read>
f0101946:	c1 e0 08             	shl    $0x8,%eax
f0101949:	09 f0                	or     %esi,%eax
}
f010194b:	8b 5d f8             	mov    -0x8(%ebp),%ebx
f010194e:	8b 75 fc             	mov    -0x4(%ebp),%esi
f0101951:	89 ec                	mov    %ebp,%esp
f0101953:	5d                   	pop    %ebp
f0101954:	c3                   	ret    

f0101955 <i386_detect_memory>:

static void
i386_detect_memory(void)
{
f0101955:	55                   	push   %ebp
f0101956:	89 e5                	mov    %esp,%ebp
f0101958:	83 ec 18             	sub    $0x18,%esp
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f010195b:	b8 15 00 00 00       	mov    $0x15,%eax
f0101960:	e8 be ff ff ff       	call   f0101923 <nvram_read>
f0101965:	c1 e0 0a             	shl    $0xa,%eax
f0101968:	89 c2                	mov    %eax,%edx
f010196a:	c1 fa 1f             	sar    $0x1f,%edx
f010196d:	c1 ea 14             	shr    $0x14,%edx
f0101970:	8d 04 02             	lea    (%edx,%eax,1),%eax
f0101973:	c1 f8 0c             	sar    $0xc,%eax
f0101976:	a3 4c d2 24 f0       	mov    %eax,0xf024d24c
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f010197b:	b8 17 00 00 00       	mov    $0x17,%eax
f0101980:	e8 9e ff ff ff       	call   f0101923 <nvram_read>
f0101985:	89 c2                	mov    %eax,%edx
f0101987:	c1 e2 0a             	shl    $0xa,%edx
f010198a:	89 d0                	mov    %edx,%eax
f010198c:	c1 f8 1f             	sar    $0x1f,%eax
f010198f:	c1 e8 14             	shr    $0x14,%eax
f0101992:	01 d0                	add    %edx,%eax
f0101994:	c1 f8 0c             	sar    $0xc,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f0101997:	85 c0                	test   %eax,%eax
f0101999:	74 0e                	je     f01019a9 <i386_detect_memory+0x54>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f010199b:	8d 90 00 01 00 00    	lea    0x100(%eax),%edx
f01019a1:	89 15 a8 de 24 f0    	mov    %edx,0xf024dea8
f01019a7:	eb 0c                	jmp    f01019b5 <i386_detect_memory+0x60>
	else
		npages = npages_basemem;
f01019a9:	8b 15 4c d2 24 f0    	mov    0xf024d24c,%edx
f01019af:	89 15 a8 de 24 f0    	mov    %edx,0xf024dea8

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01019b5:	c1 e0 0c             	shl    $0xc,%eax
f01019b8:	c1 e8 0a             	shr    $0xa,%eax
f01019bb:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01019bf:	a1 4c d2 24 f0       	mov    0xf024d24c,%eax
f01019c4:	c1 e0 0c             	shl    $0xc,%eax
f01019c7:	c1 e8 0a             	shr    $0xa,%eax
f01019ca:	89 44 24 08          	mov    %eax,0x8(%esp)
f01019ce:	a1 a8 de 24 f0       	mov    0xf024dea8,%eax
f01019d3:	c1 e0 0c             	shl    $0xc,%eax
f01019d6:	c1 e8 0a             	shr    $0xa,%eax
f01019d9:	89 44 24 04          	mov    %eax,0x4(%esp)
f01019dd:	c7 04 24 38 89 10 f0 	movl   $0xf0108938,(%esp)
f01019e4:	e8 1e 31 00 00       	call   f0104b07 <cprintf>
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
		npages_extmem * PGSIZE / 1024);
}
f01019e9:	c9                   	leave  
f01019ea:	c3                   	ret    

f01019eb <page_alloc_npages>:
// Try to reuse the pages cached in the chuck list
//
// Hint: use page2kva and memset
struct Page *
page_alloc_npages(int alloc_flags, int n)
{
f01019eb:	55                   	push   %ebp
f01019ec:	89 e5                	mov    %esp,%ebp
f01019ee:	57                   	push   %edi
f01019ef:	56                   	push   %esi
f01019f0:	53                   	push   %ebx
f01019f1:	83 ec 3c             	sub    $0x3c,%esp
	// Fill this function
	struct Page* newPage = NULL;
        int i,j;
        int fflag = 0;
        int flag = 0;
        if(n <= 0){
f01019f4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01019f8:	0f 8e 67 01 00 00    	jle    f0101b65 <page_alloc_npages+0x17a>
            return newPage;
        }
        if(page_free_list == NULL)
f01019fe:	8b 35 50 d2 24 f0    	mov    0xf024d250,%esi
f0101a04:	85 f6                	test   %esi,%esi
f0101a06:	0f 84 59 01 00 00    	je     f0101b65 <page_alloc_npages+0x17a>
            return newPage;
        for(i = 0; i+n-1 <npages;i++){
f0101a0c:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101a0f:	83 e8 01             	sub    $0x1,%eax
f0101a12:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101a15:	8b 15 a8 de 24 f0    	mov    0xf024dea8,%edx
f0101a1b:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0101a1e:	39 d0                	cmp    %edx,%eax
f0101a20:	0f 83 3f 01 00 00    	jae    f0101b65 <page_alloc_npages+0x17a>
           for(j = 0;j<n;j++){
              struct Page* tmpFree = page_free_list;
              flag = 0;
              if(pages[i+j].pp_ref != 0)
f0101a26:	a1 b0 de 24 f0       	mov    0xf024deb0,%eax
f0101a2b:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101a2e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0101a31:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
                 break;
              while(tmpFree!= NULL){
                 if(tmpFree == &pages[i+j]){
f0101a38:	89 f7                	mov    %esi,%edi
        if(n <= 0){
            return newPage;
        }
        if(page_free_list == NULL)
            return newPage;
        for(i = 0; i+n-1 <npages;i++){
f0101a3a:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101a3d:	83 ea 01             	sub    $0x1,%edx
f0101a40:	89 55 d8             	mov    %edx,-0x28(%ebp)
f0101a43:	eb 68                	jmp    f0101aad <page_alloc_npages+0xc2>
           for(j = 0;j<n;j++){
              struct Page* tmpFree = page_free_list;
              flag = 0;
              if(pages[i+j].pp_ref != 0)
f0101a45:	89 ca                	mov    %ecx,%edx
f0101a47:	0f b7 41 04          	movzwl 0x4(%ecx),%eax
f0101a4b:	83 c1 08             	add    $0x8,%ecx
f0101a4e:	66 85 c0             	test   %ax,%ax
f0101a51:	75 43                	jne    f0101a96 <page_alloc_npages+0xab>
                 break;
              while(tmpFree!= NULL){
                 if(tmpFree == &pages[i+j]){
f0101a53:	89 f8                	mov    %edi,%eax
f0101a55:	39 d6                	cmp    %edx,%esi
f0101a57:	75 09                	jne    f0101a62 <page_alloc_npages+0x77>
f0101a59:	eb 0f                	jmp    f0101a6a <page_alloc_npages+0x7f>
f0101a5b:	39 d0                	cmp    %edx,%eax
f0101a5d:	8d 76 00             	lea    0x0(%esi),%esi
f0101a60:	74 08                	je     f0101a6a <page_alloc_npages+0x7f>
                   flag = 1;
                   break;
                 }
                 tmpFree = tmpFree->pp_link;
f0101a62:	8b 00                	mov    (%eax),%eax
           for(j = 0;j<n;j++){
              struct Page* tmpFree = page_free_list;
              flag = 0;
              if(pages[i+j].pp_ref != 0)
                 break;
              while(tmpFree!= NULL){
f0101a64:	85 c0                	test   %eax,%eax
f0101a66:	75 f3                	jne    f0101a5b <page_alloc_npages+0x70>
f0101a68:	eb 10                	jmp    f0101a7a <page_alloc_npages+0x8f>
            return newPage;
        }
        if(page_free_list == NULL)
            return newPage;
        for(i = 0; i+n-1 <npages;i++){
           for(j = 0;j<n;j++){
f0101a6a:	83 c3 01             	add    $0x1,%ebx
f0101a6d:	39 5d 0c             	cmp    %ebx,0xc(%ebp)
f0101a70:	7f d3                	jg     f0101a45 <page_alloc_npages+0x5a>
f0101a72:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0101a78:	eb 08                	jmp    f0101a82 <page_alloc_npages+0x97>
                 tmpFree = tmpFree->pp_link;
              }
              if(flag == 0)
                 break;
           }
           if(j >= n){
f0101a7a:	39 5d 0c             	cmp    %ebx,0xc(%ebp)
f0101a7d:	8d 76 00             	lea    0x0(%esi),%esi
f0101a80:	7f 14                	jg     f0101a96 <page_alloc_npages+0xab>
             fflag = 1;
             newPage = &pages[i];
f0101a82:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101a85:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0101a88:	8d 1c c2             	lea    (%edx,%eax,8),%ebx
        }
        if(fflag == 0)
           return NULL;
        struct Page* tmp = page_free_list;
        while(tmp != NULL){
            if(tmp->pp_link >= &newPage[0] && tmp->pp_link <= &newPage[n-1])
f0101a8b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0101a8e:	8d 7c cb f8          	lea    -0x8(%ebx,%ecx,8),%edi
f0101a92:	89 f2                	mov    %esi,%edx
f0101a94:	eb 2f                	jmp    f0101ac5 <page_alloc_npages+0xda>
        if(n <= 0){
            return newPage;
        }
        if(page_free_list == NULL)
            return newPage;
        for(i = 0; i+n-1 <npages;i++){
f0101a96:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
f0101a9a:	83 45 e4 08          	addl   $0x8,-0x1c(%ebp)
f0101a9e:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0101aa1:	03 45 e0             	add    -0x20(%ebp),%eax
f0101aa4:	3b 45 dc             	cmp    -0x24(%ebp),%eax
f0101aa7:	0f 83 b8 00 00 00    	jae    f0101b65 <page_alloc_npages+0x17a>
f0101aad:	8b 55 e4             	mov    -0x1c(%ebp),%edx
           for(j = 0;j<n;j++){
              struct Page* tmpFree = page_free_list;
              flag = 0;
              if(pages[i+j].pp_ref != 0)
f0101ab0:	66 83 7a 04 00       	cmpw   $0x0,0x4(%edx)
f0101ab5:	75 df                	jne    f0101a96 <page_alloc_npages+0xab>
f0101ab7:	89 d1                	mov    %edx,%ecx
f0101ab9:	83 c1 08             	add    $0x8,%ecx
f0101abc:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101ac1:	eb 90                	jmp    f0101a53 <page_alloc_npages+0x68>
f0101ac3:	89 c2                	mov    %eax,%edx
        }
        if(fflag == 0)
           return NULL;
        struct Page* tmp = page_free_list;
        while(tmp != NULL){
            if(tmp->pp_link >= &newPage[0] && tmp->pp_link <= &newPage[n-1])
f0101ac5:	8b 02                	mov    (%edx),%eax
f0101ac7:	39 c3                	cmp    %eax,%ebx
f0101ac9:	77 0a                	ja     f0101ad5 <page_alloc_npages+0xea>
f0101acb:	39 f8                	cmp    %edi,%eax
f0101acd:	77 06                	ja     f0101ad5 <page_alloc_npages+0xea>
                 tmp->pp_link = tmp->pp_link->pp_link;
f0101acf:	8b 00                	mov    (%eax),%eax
f0101ad1:	89 02                	mov    %eax,(%edx)
f0101ad3:	89 d0                	mov    %edx,%eax
           }               
        }
        if(fflag == 0)
           return NULL;
        struct Page* tmp = page_free_list;
        while(tmp != NULL){
f0101ad5:	85 c0                	test   %eax,%eax
f0101ad7:	75 ea                	jne    f0101ac3 <page_alloc_npages+0xd8>
            if(tmp->pp_link >= &newPage[0] && tmp->pp_link <= &newPage[n-1])
                 tmp->pp_link = tmp->pp_link->pp_link;
            else
                 tmp = tmp->pp_link;
        }
        if(page_free_list >= &newPage[0] && page_free_list <= &newPage[n-1]){
f0101ad9:	39 de                	cmp    %ebx,%esi
f0101adb:	72 0b                	jb     f0101ae8 <page_alloc_npages+0xfd>
f0101add:	39 fe                	cmp    %edi,%esi
f0101adf:	77 07                	ja     f0101ae8 <page_alloc_npages+0xfd>
           page_free_list = page_free_list->pp_link;
f0101ae1:	8b 06                	mov    (%esi),%eax
f0101ae3:	a3 50 d2 24 f0       	mov    %eax,0xf024d250
        }
         for(i = 0;i<n-1;i++){
f0101ae8:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f0101aec:	7e 15                	jle    f0101b03 <page_alloc_npages+0x118>
f0101aee:	8d 43 08             	lea    0x8(%ebx),%eax
f0101af1:	ba 01 00 00 00       	mov    $0x1,%edx
             newPage[i].pp_link = &newPage[i+1];
f0101af6:	89 40 f8             	mov    %eax,-0x8(%eax)
f0101af9:	83 c2 01             	add    $0x1,%edx
f0101afc:	83 c0 08             	add    $0x8,%eax
                 tmp = tmp->pp_link;
        }
        if(page_free_list >= &newPage[0] && page_free_list <= &newPage[n-1]){
           page_free_list = page_free_list->pp_link;
        }
         for(i = 0;i<n-1;i++){
f0101aff:	39 d1                	cmp    %edx,%ecx
f0101b01:	75 f3                	jne    f0101af6 <page_alloc_npages+0x10b>
             newPage[i].pp_link = &newPage[i+1];
         }
         if(alloc_flags & ALLOC_ZERO){
f0101b03:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0101b07:	74 61                	je     f0101b6a <page_alloc_npages+0x17f>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0101b09:	89 d8                	mov    %ebx,%eax
f0101b0b:	2b 05 b0 de 24 f0    	sub    0xf024deb0,%eax
f0101b11:	c1 f8 03             	sar    $0x3,%eax
f0101b14:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101b17:	89 c2                	mov    %eax,%edx
f0101b19:	c1 ea 0c             	shr    $0xc,%edx
f0101b1c:	3b 15 a8 de 24 f0    	cmp    0xf024dea8,%edx
f0101b22:	72 20                	jb     f0101b44 <page_alloc_npages+0x159>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101b24:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101b28:	c7 44 24 08 80 7e 10 	movl   $0xf0107e80,0x8(%esp)
f0101b2f:	f0 
f0101b30:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0101b37:	00 
f0101b38:	c7 04 24 32 86 10 f0 	movl   $0xf0108632,(%esp)
f0101b3f:	e8 41 e5 ff ff       	call   f0100085 <_panic>
           char* addr = page2kva(newPage);
           memset(addr,0,PGSIZE*n);
f0101b44:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101b47:	c1 e2 0c             	shl    $0xc,%edx
f0101b4a:	89 54 24 08          	mov    %edx,0x8(%esp)
f0101b4e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101b55:	00 
f0101b56:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101b5b:	89 04 24             	mov    %eax,(%esp)
f0101b5e:	e8 b3 54 00 00       	call   f0107016 <memset>
f0101b63:	eb 05                	jmp    f0101b6a <page_alloc_npages+0x17f>
f0101b65:	bb 00 00 00 00       	mov    $0x0,%ebx
         }           
        return newPage; 
}
f0101b6a:	89 d8                	mov    %ebx,%eax
f0101b6c:	83 c4 3c             	add    $0x3c,%esp
f0101b6f:	5b                   	pop    %ebx
f0101b70:	5e                   	pop    %esi
f0101b71:	5f                   	pop    %edi
f0101b72:	5d                   	pop    %ebp
f0101b73:	c3                   	ret    

f0101b74 <page_realloc_npages>:
// You can man realloc for better understanding.
// (Try to reuse the allocated pages as many as possible.)
//
struct Page *
page_realloc_npages(struct Page *pp, int old_n, int new_n)
{
f0101b74:	55                   	push   %ebp
f0101b75:	89 e5                	mov    %esp,%ebp
f0101b77:	83 ec 38             	sub    $0x38,%esp
f0101b7a:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0101b7d:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0101b80:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0101b83:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0101b86:	8b 45 0c             	mov    0xc(%ebp),%eax
	// Fill this function
        if(old_n <= 0 || new_n <= 0)
f0101b89:	85 c0                	test   %eax,%eax
f0101b8b:	0f 8e d2 00 00 00    	jle    f0101c63 <page_realloc_npages+0xef>
f0101b91:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0101b95:	0f 8e c8 00 00 00    	jle    f0101c63 <page_realloc_npages+0xef>
static int
check_continuous(struct Page *pp, int num_page)
{
	struct Page *tmp; 
	int i;
	for( tmp = pp, i = 0; i < num_page - 1; tmp = tmp->pp_link, i++ )
f0101b9b:	8d 50 ff             	lea    -0x1(%eax),%edx
f0101b9e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0101ba1:	85 d2                	test   %edx,%edx
f0101ba3:	0f 8e ce 00 00 00    	jle    f0101c77 <page_realloc_npages+0x103>
	{
		if(tmp == NULL) 
f0101ba9:	85 db                	test   %ebx,%ebx
f0101bab:	0f 84 b7 00 00 00    	je     f0101c68 <page_realloc_npages+0xf4>
		{
			return 0;
		}
		if( (page2pa(tmp->pp_link) - page2pa(tmp)) != PGSIZE )
f0101bb1:	8b 13                	mov    (%ebx),%edx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0101bb3:	8b 3d b0 de 24 f0    	mov    0xf024deb0,%edi
f0101bb9:	89 d1                	mov    %edx,%ecx
f0101bbb:	29 f9                	sub    %edi,%ecx
f0101bbd:	c1 f9 03             	sar    $0x3,%ecx
f0101bc0:	89 de                	mov    %ebx,%esi
f0101bc2:	29 fe                	sub    %edi,%esi
f0101bc4:	c1 fe 03             	sar    $0x3,%esi
f0101bc7:	29 f1                	sub    %esi,%ecx
f0101bc9:	89 ce                	mov    %ecx,%esi
f0101bcb:	c1 e6 0c             	shl    $0xc,%esi
f0101bce:	b9 00 00 00 00       	mov    $0x0,%ecx
f0101bd3:	81 fe 00 10 00 00    	cmp    $0x1000,%esi
f0101bd9:	74 28                	je     f0101c03 <page_realloc_npages+0x8f>
f0101bdb:	e9 83 00 00 00       	jmp    f0101c63 <page_realloc_npages+0xef>
{
	struct Page *tmp; 
	int i;
	for( tmp = pp, i = 0; i < num_page - 1; tmp = tmp->pp_link, i++ )
	{
		if(tmp == NULL) 
f0101be0:	85 d2                	test   %edx,%edx
f0101be2:	74 7f                	je     f0101c63 <page_realloc_npages+0xef>
		{
			return 0;
		}
		if( (page2pa(tmp->pp_link) - page2pa(tmp)) != PGSIZE )
f0101be4:	8b 02                	mov    (%edx),%eax
f0101be6:	89 c3                	mov    %eax,%ebx
f0101be8:	29 fb                	sub    %edi,%ebx
f0101bea:	c1 fb 03             	sar    $0x3,%ebx
f0101bed:	29 fa                	sub    %edi,%edx
f0101bef:	c1 fa 03             	sar    $0x3,%edx
f0101bf2:	29 d3                	sub    %edx,%ebx
f0101bf4:	c1 e3 0c             	shl    $0xc,%ebx
f0101bf7:	81 fb 00 10 00 00    	cmp    $0x1000,%ebx
f0101bfd:	75 64                	jne    f0101c63 <page_realloc_npages+0xef>
f0101bff:	89 c2                	mov    %eax,%edx
f0101c01:	eb 09                	jmp    f0101c0c <page_realloc_npages+0x98>
f0101c03:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0101c06:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0101c09:	89 45 e0             	mov    %eax,-0x20(%ebp)
static int
check_continuous(struct Page *pp, int num_page)
{
	struct Page *tmp; 
	int i;
	for( tmp = pp, i = 0; i < num_page - 1; tmp = tmp->pp_link, i++ )
f0101c0c:	83 c1 01             	add    $0x1,%ecx
f0101c0f:	39 ce                	cmp    %ecx,%esi
f0101c11:	7f cd                	jg     f0101be0 <page_realloc_npages+0x6c>
f0101c13:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0101c16:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101c19:	eb 5c                	jmp    f0101c77 <page_realloc_npages+0x103>
            return NULL;
        if(!check_continuous(pp,old_n))
            return NULL;
        if(old_n == new_n)
            return pp;
        if(old_n > new_n){
f0101c1b:	3b 45 10             	cmp    0x10(%ebp),%eax
f0101c1e:	7e 20                	jle    f0101c40 <page_realloc_npages+0xcc>
           struct Page* lastPage = &pp[new_n-1];
f0101c20:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0101c23:	8d 54 cb f8          	lea    -0x8(%ebx,%ecx,8),%edx
           lastPage->pp_link = NULL;
f0101c27:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
           page_free_npages(&lastPage[1],old_n-new_n);
f0101c2d:	29 c8                	sub    %ecx,%eax
f0101c2f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101c33:	83 c2 08             	add    $0x8,%edx
f0101c36:	89 14 24             	mov    %edx,(%esp)
f0101c39:	e8 22 fa ff ff       	call   f0101660 <page_free_npages>
           return pp;
f0101c3e:	eb 28                	jmp    f0101c68 <page_realloc_npages+0xf4>
        }
        else{
           struct Page* newPage;
           page_free_npages(pp,old_n);
f0101c40:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101c44:	89 1c 24             	mov    %ebx,(%esp)
f0101c47:	e8 14 fa ff ff       	call   f0101660 <page_free_npages>
           newPage = page_alloc_npages(0,new_n);
f0101c4c:	8b 45 10             	mov    0x10(%ebp),%eax
f0101c4f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101c53:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101c5a:	e8 8c fd ff ff       	call   f01019eb <page_alloc_npages>
f0101c5f:	89 c3                	mov    %eax,%ebx
           return newPage;
f0101c61:	eb 05                	jmp    f0101c68 <page_realloc_npages+0xf4>
f0101c63:	bb 00 00 00 00       	mov    $0x0,%ebx
        }
	return NULL;
}
f0101c68:	89 d8                	mov    %ebx,%eax
f0101c6a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0101c6d:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0101c70:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0101c73:	89 ec                	mov    %ebp,%esp
f0101c75:	5d                   	pop    %ebp
f0101c76:	c3                   	ret    
	// Fill this function
        if(old_n <= 0 || new_n <= 0)
            return NULL;
        if(!check_continuous(pp,old_n))
            return NULL;
        if(old_n == new_n)
f0101c77:	3b 45 10             	cmp    0x10(%ebp),%eax
f0101c7a:	75 9f                	jne    f0101c1b <page_realloc_npages+0xa7>
f0101c7c:	eb ea                	jmp    f0101c68 <page_realloc_npages+0xf4>

f0101c7e <check_va2pa>:
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0101c7e:	55                   	push   %ebp
f0101c7f:	89 e5                	mov    %esp,%ebp
f0101c81:	83 ec 18             	sub    $0x18,%esp
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
f0101c84:	89 d1                	mov    %edx,%ecx
f0101c86:	c1 e9 16             	shr    $0x16,%ecx
f0101c89:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0101c8c:	a8 01                	test   $0x1,%al
f0101c8e:	74 4d                	je     f0101cdd <check_va2pa+0x5f>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0101c90:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101c95:	89 c1                	mov    %eax,%ecx
f0101c97:	c1 e9 0c             	shr    $0xc,%ecx
f0101c9a:	3b 0d a8 de 24 f0    	cmp    0xf024dea8,%ecx
f0101ca0:	72 20                	jb     f0101cc2 <check_va2pa+0x44>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101ca2:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101ca6:	c7 44 24 08 80 7e 10 	movl   $0xf0107e80,0x8(%esp)
f0101cad:	f0 
f0101cae:	c7 44 24 04 1a 04 00 	movl   $0x41a,0x4(%esp)
f0101cb5:	00 
f0101cb6:	c7 04 24 26 86 10 f0 	movl   $0xf0108626,(%esp)
f0101cbd:	e8 c3 e3 ff ff       	call   f0100085 <_panic>
	if (!(p[PTX(va)] & PTE_P))
f0101cc2:	c1 ea 0c             	shr    $0xc,%edx
f0101cc5:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0101ccb:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0101cd2:	a8 01                	test   $0x1,%al
f0101cd4:	74 07                	je     f0101cdd <check_va2pa+0x5f>
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0101cd6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0101cdb:	eb 05                	jmp    f0101ce2 <check_va2pa+0x64>
f0101cdd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f0101ce2:	c9                   	leave  
f0101ce3:	c3                   	ret    

f0101ce4 <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0101ce4:	55                   	push   %ebp
f0101ce5:	89 e5                	mov    %esp,%ebp
f0101ce7:	57                   	push   %edi
f0101ce8:	56                   	push   %esi
f0101ce9:	53                   	push   %ebx
f0101cea:	83 ec 5c             	sub    $0x5c,%esp
	struct Page *pp;
	int pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0101ced:	83 f8 01             	cmp    $0x1,%eax
f0101cf0:	19 f6                	sbb    %esi,%esi
f0101cf2:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
f0101cf8:	83 c6 01             	add    $0x1,%esi
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0101cfb:	8b 1d 50 d2 24 f0    	mov    0xf024d250,%ebx
f0101d01:	85 db                	test   %ebx,%ebx
f0101d03:	75 1c                	jne    f0101d21 <check_page_free_list+0x3d>
		panic("'page_free_list' is a null pointer!");
f0101d05:	c7 44 24 08 74 89 10 	movl   $0xf0108974,0x8(%esp)
f0101d0c:	f0 
f0101d0d:	c7 44 24 04 46 03 00 	movl   $0x346,0x4(%esp)
f0101d14:	00 
f0101d15:	c7 04 24 26 86 10 f0 	movl   $0xf0108626,(%esp)
f0101d1c:	e8 64 e3 ff ff       	call   f0100085 <_panic>

	if (only_low_memory) {
f0101d21:	85 c0                	test   %eax,%eax
f0101d23:	74 52                	je     f0101d77 <check_page_free_list+0x93>
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct Page *pp1, *pp2;
		struct Page **tp[2] = { &pp1, &pp2 };
f0101d25:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101d28:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0101d2b:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0101d2e:	89 45 dc             	mov    %eax,-0x24(%ebp)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0101d31:	8b 0d b0 de 24 f0    	mov    0xf024deb0,%ecx
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0101d37:	89 d8                	mov    %ebx,%eax
f0101d39:	29 c8                	sub    %ecx,%eax
f0101d3b:	c1 e0 09             	shl    $0x9,%eax
f0101d3e:	c1 e8 16             	shr    $0x16,%eax
f0101d41:	39 f0                	cmp    %esi,%eax
f0101d43:	0f 93 c0             	setae  %al
f0101d46:	0f b6 c0             	movzbl %al,%eax
			*tp[pagetype] = pp;
f0101d49:	8b 54 85 d8          	mov    -0x28(%ebp,%eax,4),%edx
f0101d4d:	89 1a                	mov    %ebx,(%edx)
			tp[pagetype] = &pp->pp_link;
f0101d4f:	89 5c 85 d8          	mov    %ebx,-0x28(%ebp,%eax,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct Page *pp1, *pp2;
		struct Page **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0101d53:	8b 1b                	mov    (%ebx),%ebx
f0101d55:	85 db                	test   %ebx,%ebx
f0101d57:	75 de                	jne    f0101d37 <check_page_free_list+0x53>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0101d59:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0101d5c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0101d62:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0101d65:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0101d68:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0101d6a:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0101d6d:	89 1d 50 d2 24 f0    	mov    %ebx,0xf024d250
	}
	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link){
f0101d73:	85 db                	test   %ebx,%ebx
f0101d75:	74 67                	je     f0101dde <check_page_free_list+0xfa>
f0101d77:	89 d8                	mov    %ebx,%eax
f0101d79:	2b 05 b0 de 24 f0    	sub    0xf024deb0,%eax
f0101d7f:	c1 f8 03             	sar    $0x3,%eax
f0101d82:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0101d85:	89 c2                	mov    %eax,%edx
f0101d87:	c1 ea 16             	shr    $0x16,%edx
f0101d8a:	39 f2                	cmp    %esi,%edx
f0101d8c:	73 4a                	jae    f0101dd8 <check_page_free_list+0xf4>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101d8e:	89 c2                	mov    %eax,%edx
f0101d90:	c1 ea 0c             	shr    $0xc,%edx
f0101d93:	3b 15 a8 de 24 f0    	cmp    0xf024dea8,%edx
f0101d99:	72 20                	jb     f0101dbb <check_page_free_list+0xd7>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101d9b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101d9f:	c7 44 24 08 80 7e 10 	movl   $0xf0107e80,0x8(%esp)
f0101da6:	f0 
f0101da7:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0101dae:	00 
f0101daf:	c7 04 24 32 86 10 f0 	movl   $0xf0108632,(%esp)
f0101db6:	e8 ca e2 ff ff       	call   f0100085 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0101dbb:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
f0101dc2:	00 
f0101dc3:	c7 44 24 04 97 00 00 	movl   $0x97,0x4(%esp)
f0101dca:	00 
f0101dcb:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101dd0:	89 04 24             	mov    %eax,(%esp)
f0101dd3:	e8 3e 52 00 00       	call   f0107016 <memset>
		*tp[0] = pp2;
		page_free_list = pp1;
	}
	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link){
f0101dd8:	8b 1b                	mov    (%ebx),%ebx
f0101dda:	85 db                	test   %ebx,%ebx
f0101ddc:	75 99                	jne    f0101d77 <check_page_free_list+0x93>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);
	}
	first_free_page = (char *) boot_alloc(0);
f0101dde:	b8 00 00 00 00       	mov    $0x0,%eax
f0101de3:	e8 71 f9 ff ff       	call   f0101759 <boot_alloc>
f0101de8:	89 45 c4             	mov    %eax,-0x3c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0101deb:	8b 15 50 d2 24 f0    	mov    0xf024d250,%edx
f0101df1:	85 d2                	test   %edx,%edx
f0101df3:	0f 84 3a 02 00 00    	je     f0102033 <check_page_free_list+0x34f>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0101df9:	8b 1d b0 de 24 f0    	mov    0xf024deb0,%ebx
f0101dff:	39 da                	cmp    %ebx,%edx
f0101e01:	72 4f                	jb     f0101e52 <check_page_free_list+0x16e>
		assert(pp < pages + npages);
f0101e03:	a1 a8 de 24 f0       	mov    0xf024dea8,%eax
f0101e08:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0101e0b:	8d 04 c3             	lea    (%ebx,%eax,8),%eax
f0101e0e:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101e11:	39 c2                	cmp    %eax,%edx
f0101e13:	73 66                	jae    f0101e7b <check_page_free_list+0x197>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0101e15:	89 5d cc             	mov    %ebx,-0x34(%ebp)
f0101e18:	89 d0                	mov    %edx,%eax
f0101e1a:	29 d8                	sub    %ebx,%eax
f0101e1c:	a8 07                	test   $0x7,%al
f0101e1e:	0f 85 84 00 00 00    	jne    f0101ea8 <check_page_free_list+0x1c4>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0101e24:	c1 f8 03             	sar    $0x3,%eax
f0101e27:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0101e2a:	85 c0                	test   %eax,%eax
f0101e2c:	0f 84 a4 00 00 00    	je     f0101ed6 <check_page_free_list+0x1f2>
		assert(page2pa(pp) != IOPHYSMEM);
f0101e32:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0101e37:	0f 84 c4 00 00 00    	je     f0101f01 <check_page_free_list+0x21d>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0101e3d:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0101e42:	0f 85 08 01 00 00    	jne    f0101f50 <check_page_free_list+0x26c>
f0101e48:	e9 df 00 00 00       	jmp    f0101f2c <check_page_free_list+0x248>
			memset(page2kva(pp), 0x97, 128);
	}
	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0101e4d:	3b 55 b4             	cmp    -0x4c(%ebp),%edx
f0101e50:	73 24                	jae    f0101e76 <check_page_free_list+0x192>
f0101e52:	c7 44 24 0c 40 86 10 	movl   $0xf0108640,0xc(%esp)
f0101e59:	f0 
f0101e5a:	c7 44 24 08 4c 86 10 	movl   $0xf010864c,0x8(%esp)
f0101e61:	f0 
f0101e62:	c7 44 24 04 5f 03 00 	movl   $0x35f,0x4(%esp)
f0101e69:	00 
f0101e6a:	c7 04 24 26 86 10 f0 	movl   $0xf0108626,(%esp)
f0101e71:	e8 0f e2 ff ff       	call   f0100085 <_panic>
		assert(pp < pages + npages);
f0101e76:	3b 55 d0             	cmp    -0x30(%ebp),%edx
f0101e79:	72 24                	jb     f0101e9f <check_page_free_list+0x1bb>
f0101e7b:	c7 44 24 0c 61 86 10 	movl   $0xf0108661,0xc(%esp)
f0101e82:	f0 
f0101e83:	c7 44 24 08 4c 86 10 	movl   $0xf010864c,0x8(%esp)
f0101e8a:	f0 
f0101e8b:	c7 44 24 04 60 03 00 	movl   $0x360,0x4(%esp)
f0101e92:	00 
f0101e93:	c7 04 24 26 86 10 f0 	movl   $0xf0108626,(%esp)
f0101e9a:	e8 e6 e1 ff ff       	call   f0100085 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0101e9f:	89 d0                	mov    %edx,%eax
f0101ea1:	2b 45 cc             	sub    -0x34(%ebp),%eax
f0101ea4:	a8 07                	test   $0x7,%al
f0101ea6:	74 24                	je     f0101ecc <check_page_free_list+0x1e8>
f0101ea8:	c7 44 24 0c 98 89 10 	movl   $0xf0108998,0xc(%esp)
f0101eaf:	f0 
f0101eb0:	c7 44 24 08 4c 86 10 	movl   $0xf010864c,0x8(%esp)
f0101eb7:	f0 
f0101eb8:	c7 44 24 04 61 03 00 	movl   $0x361,0x4(%esp)
f0101ebf:	00 
f0101ec0:	c7 04 24 26 86 10 f0 	movl   $0xf0108626,(%esp)
f0101ec7:	e8 b9 e1 ff ff       	call   f0100085 <_panic>
f0101ecc:	c1 f8 03             	sar    $0x3,%eax
f0101ecf:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0101ed2:	85 c0                	test   %eax,%eax
f0101ed4:	75 24                	jne    f0101efa <check_page_free_list+0x216>
f0101ed6:	c7 44 24 0c 75 86 10 	movl   $0xf0108675,0xc(%esp)
f0101edd:	f0 
f0101ede:	c7 44 24 08 4c 86 10 	movl   $0xf010864c,0x8(%esp)
f0101ee5:	f0 
f0101ee6:	c7 44 24 04 64 03 00 	movl   $0x364,0x4(%esp)
f0101eed:	00 
f0101eee:	c7 04 24 26 86 10 f0 	movl   $0xf0108626,(%esp)
f0101ef5:	e8 8b e1 ff ff       	call   f0100085 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0101efa:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0101eff:	75 24                	jne    f0101f25 <check_page_free_list+0x241>
f0101f01:	c7 44 24 0c 86 86 10 	movl   $0xf0108686,0xc(%esp)
f0101f08:	f0 
f0101f09:	c7 44 24 08 4c 86 10 	movl   $0xf010864c,0x8(%esp)
f0101f10:	f0 
f0101f11:	c7 44 24 04 65 03 00 	movl   $0x365,0x4(%esp)
f0101f18:	00 
f0101f19:	c7 04 24 26 86 10 f0 	movl   $0xf0108626,(%esp)
f0101f20:	e8 60 e1 ff ff       	call   f0100085 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0101f25:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0101f2a:	75 31                	jne    f0101f5d <check_page_free_list+0x279>
f0101f2c:	c7 44 24 0c cc 89 10 	movl   $0xf01089cc,0xc(%esp)
f0101f33:	f0 
f0101f34:	c7 44 24 08 4c 86 10 	movl   $0xf010864c,0x8(%esp)
f0101f3b:	f0 
f0101f3c:	c7 44 24 04 66 03 00 	movl   $0x366,0x4(%esp)
f0101f43:	00 
f0101f44:	c7 04 24 26 86 10 f0 	movl   $0xf0108626,(%esp)
f0101f4b:	e8 35 e1 ff ff       	call   f0100085 <_panic>
f0101f50:	be 00 00 00 00       	mov    $0x0,%esi
f0101f55:	bf 00 00 00 00       	mov    $0x0,%edi
f0101f5a:	89 5d b4             	mov    %ebx,-0x4c(%ebp)
		assert(page2pa(pp) != EXTPHYSMEM);
f0101f5d:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0101f62:	75 24                	jne    f0101f88 <check_page_free_list+0x2a4>
f0101f64:	c7 44 24 0c 9f 86 10 	movl   $0xf010869f,0xc(%esp)
f0101f6b:	f0 
f0101f6c:	c7 44 24 08 4c 86 10 	movl   $0xf010864c,0x8(%esp)
f0101f73:	f0 
f0101f74:	c7 44 24 04 67 03 00 	movl   $0x367,0x4(%esp)
f0101f7b:	00 
f0101f7c:	c7 04 24 26 86 10 f0 	movl   $0xf0108626,(%esp)
f0101f83:	e8 fd e0 ff ff       	call   f0100085 <_panic>
f0101f88:	89 c1                	mov    %eax,%ecx
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0101f8a:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0101f8f:	76 59                	jbe    f0101fea <check_page_free_list+0x306>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101f91:	89 c3                	mov    %eax,%ebx
f0101f93:	c1 eb 0c             	shr    $0xc,%ebx
f0101f96:	39 5d c8             	cmp    %ebx,-0x38(%ebp)
f0101f99:	77 20                	ja     f0101fbb <check_page_free_list+0x2d7>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101f9b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101f9f:	c7 44 24 08 80 7e 10 	movl   $0xf0107e80,0x8(%esp)
f0101fa6:	f0 
f0101fa7:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0101fae:	00 
f0101faf:	c7 04 24 32 86 10 f0 	movl   $0xf0108632,(%esp)
f0101fb6:	e8 ca e0 ff ff       	call   f0100085 <_panic>
f0101fbb:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
f0101fc1:	39 5d c4             	cmp    %ebx,-0x3c(%ebp)
f0101fc4:	76 24                	jbe    f0101fea <check_page_free_list+0x306>
f0101fc6:	c7 44 24 0c f0 89 10 	movl   $0xf01089f0,0xc(%esp)
f0101fcd:	f0 
f0101fce:	c7 44 24 08 4c 86 10 	movl   $0xf010864c,0x8(%esp)
f0101fd5:	f0 
f0101fd6:	c7 44 24 04 68 03 00 	movl   $0x368,0x4(%esp)
f0101fdd:	00 
f0101fde:	c7 04 24 26 86 10 f0 	movl   $0xf0108626,(%esp)
f0101fe5:	e8 9b e0 ff ff       	call   f0100085 <_panic>
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f0101fea:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0101fef:	75 24                	jne    f0102015 <check_page_free_list+0x331>
f0101ff1:	c7 44 24 0c b9 86 10 	movl   $0xf01086b9,0xc(%esp)
f0101ff8:	f0 
f0101ff9:	c7 44 24 08 4c 86 10 	movl   $0xf010864c,0x8(%esp)
f0102000:	f0 
f0102001:	c7 44 24 04 6a 03 00 	movl   $0x36a,0x4(%esp)
f0102008:	00 
f0102009:	c7 04 24 26 86 10 f0 	movl   $0xf0108626,(%esp)
f0102010:	e8 70 e0 ff ff       	call   f0100085 <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
f0102015:	81 f9 ff ff 0f 00    	cmp    $0xfffff,%ecx
f010201b:	77 05                	ja     f0102022 <check_page_free_list+0x33e>
			++nfree_basemem;
f010201d:	83 c7 01             	add    $0x1,%edi
f0102020:	eb 03                	jmp    f0102025 <check_page_free_list+0x341>
		else
			++nfree_extmem;
f0102022:	83 c6 01             	add    $0x1,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link){
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);
	}
	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0102025:	8b 12                	mov    (%edx),%edx
f0102027:	85 d2                	test   %edx,%edx
f0102029:	0f 85 1e fe ff ff    	jne    f0101e4d <check_page_free_list+0x169>
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f010202f:	85 ff                	test   %edi,%edi
f0102031:	7f 24                	jg     f0102057 <check_page_free_list+0x373>
f0102033:	c7 44 24 0c d6 86 10 	movl   $0xf01086d6,0xc(%esp)
f010203a:	f0 
f010203b:	c7 44 24 08 4c 86 10 	movl   $0xf010864c,0x8(%esp)
f0102042:	f0 
f0102043:	c7 44 24 04 72 03 00 	movl   $0x372,0x4(%esp)
f010204a:	00 
f010204b:	c7 04 24 26 86 10 f0 	movl   $0xf0108626,(%esp)
f0102052:	e8 2e e0 ff ff       	call   f0100085 <_panic>
	assert(nfree_extmem > 0);
f0102057:	85 f6                	test   %esi,%esi
f0102059:	7f 24                	jg     f010207f <check_page_free_list+0x39b>
f010205b:	c7 44 24 0c e8 86 10 	movl   $0xf01086e8,0xc(%esp)
f0102062:	f0 
f0102063:	c7 44 24 08 4c 86 10 	movl   $0xf010864c,0x8(%esp)
f010206a:	f0 
f010206b:	c7 44 24 04 73 03 00 	movl   $0x373,0x4(%esp)
f0102072:	00 
f0102073:	c7 04 24 26 86 10 f0 	movl   $0xf0108626,(%esp)
f010207a:	e8 06 e0 ff ff       	call   f0100085 <_panic>
        //cprintf("check_page_free_list() succeeded!\n");
}
f010207f:	83 c4 5c             	add    $0x5c,%esp
f0102082:	5b                   	pop    %ebx
f0102083:	5e                   	pop    %esi
f0102084:	5f                   	pop    %edi
f0102085:	5d                   	pop    %ebp
f0102086:	c3                   	ret    

f0102087 <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct Page *
page_alloc(int alloc_flags)
{
f0102087:	55                   	push   %ebp
f0102088:	89 e5                	mov    %esp,%ebp
f010208a:	53                   	push   %ebx
f010208b:	83 ec 14             	sub    $0x14,%esp
	// Fill this function in
        struct Page* newPage = NULL;
        if(!page_free_list){
f010208e:	8b 1d 50 d2 24 f0    	mov    0xf024d250,%ebx
f0102094:	85 db                	test   %ebx,%ebx
f0102096:	74 65                	je     f01020fd <page_alloc+0x76>
            return newPage;
        }
        newPage = page_free_list;
        page_free_list = page_free_list->pp_link;
f0102098:	8b 03                	mov    (%ebx),%eax
f010209a:	a3 50 d2 24 f0       	mov    %eax,0xf024d250
        if(alloc_flags & ALLOC_ZERO){
f010209f:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f01020a3:	74 58                	je     f01020fd <page_alloc+0x76>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f01020a5:	89 d8                	mov    %ebx,%eax
f01020a7:	2b 05 b0 de 24 f0    	sub    0xf024deb0,%eax
f01020ad:	c1 f8 03             	sar    $0x3,%eax
f01020b0:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01020b3:	89 c2                	mov    %eax,%edx
f01020b5:	c1 ea 0c             	shr    $0xc,%edx
f01020b8:	3b 15 a8 de 24 f0    	cmp    0xf024dea8,%edx
f01020be:	72 20                	jb     f01020e0 <page_alloc+0x59>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01020c0:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01020c4:	c7 44 24 08 80 7e 10 	movl   $0xf0107e80,0x8(%esp)
f01020cb:	f0 
f01020cc:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f01020d3:	00 
f01020d4:	c7 04 24 32 86 10 f0 	movl   $0xf0108632,(%esp)
f01020db:	e8 a5 df ff ff       	call   f0100085 <_panic>
           char* addr = page2kva(newPage);
           memset(addr,0,PGSIZE);
f01020e0:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01020e7:	00 
f01020e8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01020ef:	00 
f01020f0:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01020f5:	89 04 24             	mov    %eax,(%esp)
f01020f8:	e8 19 4f 00 00       	call   f0107016 <memset>
        } 
        return newPage;  
}
f01020fd:	89 d8                	mov    %ebx,%eax
f01020ff:	83 c4 14             	add    $0x14,%esp
f0102102:	5b                   	pop    %ebx
f0102103:	5d                   	pop    %ebp
f0102104:	c3                   	ret    

f0102105 <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f0102105:	55                   	push   %ebp
f0102106:	89 e5                	mov    %esp,%ebp
f0102108:	83 ec 18             	sub    $0x18,%esp
f010210b:	89 5d f8             	mov    %ebx,-0x8(%ebp)
f010210e:	89 75 fc             	mov    %esi,-0x4(%ebp)
	// Fill this function in
        pde_t* pde = NULL;
        physaddr_t pt;    //physical address
        pte_t* vpt = NULL;
        pde = &pgdir[PDX(va)];
f0102111:	8b 75 0c             	mov    0xc(%ebp),%esi
f0102114:	89 f3                	mov    %esi,%ebx
f0102116:	c1 eb 16             	shr    $0x16,%ebx
f0102119:	c1 e3 02             	shl    $0x2,%ebx
f010211c:	03 5d 08             	add    0x8(%ebp),%ebx
        if((*pde) & PTE_PS)
f010211f:	8b 03                	mov    (%ebx),%eax
f0102121:	84 c0                	test   %al,%al
f0102123:	0f 88 86 00 00 00    	js     f01021af <pgdir_walk+0xaa>
            return &pgdir[PDX(va)];
        if((!((*pde) & PTE_P)) && create == 0)
f0102129:	89 c2                	mov    %eax,%edx
f010212b:	83 e2 01             	and    $0x1,%edx
f010212e:	75 06                	jne    f0102136 <pgdir_walk+0x31>
f0102130:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0102134:	74 74                	je     f01021aa <pgdir_walk+0xa5>
           return NULL;
        else if(!((*pde) & PTE_P)){
f0102136:	85 d2                	test   %edx,%edx
f0102138:	75 2c                	jne    f0102166 <pgdir_walk+0x61>
           struct Page* page = NULL;
           if(!(page = page_alloc(ALLOC_ZERO)))
f010213a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0102141:	e8 41 ff ff ff       	call   f0102087 <page_alloc>
f0102146:	89 c2                	mov    %eax,%edx
f0102148:	85 c0                	test   %eax,%eax
f010214a:	74 5e                	je     f01021aa <pgdir_walk+0xa5>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f010214c:	2b 05 b0 de 24 f0    	sub    0xf024deb0,%eax
f0102152:	c1 f8 03             	sar    $0x3,%eax
f0102155:	c1 e0 0c             	shl    $0xc,%eax
              return NULL;
           pt = page2pa(page);     
           *pde = pt | PTE_P | PTE_W | PTE_U;
f0102158:	89 c1                	mov    %eax,%ecx
f010215a:	83 c9 07             	or     $0x7,%ecx
f010215d:	89 0b                	mov    %ecx,(%ebx)
           page->pp_ref++;
f010215f:	66 83 42 04 01       	addw   $0x1,0x4(%edx)
f0102164:	eb 05                	jmp    f010216b <pgdir_walk+0x66>
        }
        else{
          pt = PTE_ADDR(*pde);
f0102166:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010216b:	89 c2                	mov    %eax,%edx
f010216d:	c1 ea 0c             	shr    $0xc,%edx
f0102170:	3b 15 a8 de 24 f0    	cmp    0xf024dea8,%edx
f0102176:	72 20                	jb     f0102198 <pgdir_walk+0x93>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102178:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010217c:	c7 44 24 08 80 7e 10 	movl   $0xf0107e80,0x8(%esp)
f0102183:	f0 
f0102184:	c7 44 24 04 4b 02 00 	movl   $0x24b,0x4(%esp)
f010218b:	00 
f010218c:	c7 04 24 26 86 10 f0 	movl   $0xf0108626,(%esp)
f0102193:	e8 ed de ff ff       	call   f0100085 <_panic>
        }
        vpt = (pte_t*)KADDR(pt);          
	return &vpt[PTX(va)];
f0102198:	c1 ee 0a             	shr    $0xa,%esi
f010219b:	81 e6 fc 0f 00 00    	and    $0xffc,%esi
f01021a1:	8d 9c 30 00 00 00 f0 	lea    -0x10000000(%eax,%esi,1),%ebx
f01021a8:	eb 05                	jmp    f01021af <pgdir_walk+0xaa>
f01021aa:	bb 00 00 00 00       	mov    $0x0,%ebx
}
f01021af:	89 d8                	mov    %ebx,%eax
f01021b1:	8b 5d f8             	mov    -0x8(%ebp),%ebx
f01021b4:	8b 75 fc             	mov    -0x4(%ebp),%esi
f01021b7:	89 ec                	mov    %ebp,%esp
f01021b9:	5d                   	pop    %ebp
f01021ba:	c3                   	ret    

f01021bb <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f01021bb:	55                   	push   %ebp
f01021bc:	89 e5                	mov    %esp,%ebp
f01021be:	57                   	push   %edi
f01021bf:	56                   	push   %esi
f01021c0:	53                   	push   %ebx
f01021c1:	83 ec 2c             	sub    $0x2c,%esp
f01021c4:	8b 75 08             	mov    0x8(%ebp),%esi
f01021c7:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 3: Your code here.
        void* begin = ROUNDDOWN((void*)va,PGSIZE);
f01021ca:	8b 45 0c             	mov    0xc(%ebp),%eax
f01021cd:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01021d0:	89 c3                	mov    %eax,%ebx
f01021d2:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
        void* end = ROUNDUP((void*)(va+len),PGSIZE);
f01021d8:	03 45 10             	add    0x10(%ebp),%eax
f01021db:	05 ff 0f 00 00       	add    $0xfff,%eax
f01021e0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01021e5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        while(begin < end){
f01021e8:	39 c3                	cmp    %eax,%ebx
f01021ea:	73 7e                	jae    f010226a <user_mem_check+0xaf>
           pte_t* pte = pgdir_walk(env->env_pgdir,begin,0);
f01021ec:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01021f3:	00 
f01021f4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01021f8:	8b 46 64             	mov    0x64(%esi),%eax
f01021fb:	89 04 24             	mov    %eax,(%esp)
f01021fe:	e8 02 ff ff ff       	call   f0102105 <pgdir_walk>
f0102203:	89 da                	mov    %ebx,%edx
           if((uint32_t)begin >= ULIM){
f0102205:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f010220b:	76 21                	jbe    f010222e <user_mem_check+0x73>
                if(begin > va)
f010220d:	39 5d 0c             	cmp    %ebx,0xc(%ebp)
f0102210:	73 0d                	jae    f010221f <user_mem_check+0x64>
                  user_mem_check_addr = (uintptr_t)begin;
f0102212:	89 1d 58 d2 24 f0    	mov    %ebx,0xf024d258
f0102218:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f010221d:	eb 50                	jmp    f010226f <user_mem_check+0xb4>
                else
                  user_mem_check_addr = (uintptr_t)va;
f010221f:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102222:	a3 58 d2 24 f0       	mov    %eax,0xf024d258
f0102227:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f010222c:	eb 41                	jmp    f010226f <user_mem_check+0xb4>
                return -E_FAULT;
           }
           if(!pte || !(*pte & PTE_P) || ((*pte & perm) != perm)){
f010222e:	85 c0                	test   %eax,%eax
f0102230:	74 0c                	je     f010223e <user_mem_check+0x83>
f0102232:	8b 00                	mov    (%eax),%eax
f0102234:	a8 01                	test   $0x1,%al
f0102236:	74 06                	je     f010223e <user_mem_check+0x83>
f0102238:	21 f8                	and    %edi,%eax
f010223a:	39 c7                	cmp    %eax,%edi
f010223c:	74 21                	je     f010225f <user_mem_check+0xa4>
                if(begin > va)
f010223e:	39 5d 0c             	cmp    %ebx,0xc(%ebp)
f0102241:	73 0d                	jae    f0102250 <user_mem_check+0x95>
                  user_mem_check_addr = (uintptr_t)begin;
f0102243:	89 15 58 d2 24 f0    	mov    %edx,0xf024d258
f0102249:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f010224e:	eb 1f                	jmp    f010226f <user_mem_check+0xb4>
                else
                  user_mem_check_addr = (uintptr_t)va;
f0102250:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102253:	a3 58 d2 24 f0       	mov    %eax,0xf024d258
f0102258:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f010225d:	eb 10                	jmp    f010226f <user_mem_check+0xb4>
                return -E_FAULT;
           }
           begin += PGSIZE;
f010225f:	81 c3 00 10 00 00    	add    $0x1000,%ebx
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
	// LAB 3: Your code here.
        void* begin = ROUNDDOWN((void*)va,PGSIZE);
        void* end = ROUNDUP((void*)(va+len),PGSIZE);
        while(begin < end){
f0102265:	39 5d e4             	cmp    %ebx,-0x1c(%ebp)
f0102268:	77 82                	ja     f01021ec <user_mem_check+0x31>
f010226a:	b8 00 00 00 00       	mov    $0x0,%eax
                return -E_FAULT;
           }
           begin += PGSIZE;
        }
	return 0;
}
f010226f:	83 c4 2c             	add    $0x2c,%esp
f0102272:	5b                   	pop    %ebx
f0102273:	5e                   	pop    %esi
f0102274:	5f                   	pop    %edi
f0102275:	5d                   	pop    %ebp
f0102276:	c3                   	ret    

f0102277 <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f0102277:	55                   	push   %ebp
f0102278:	89 e5                	mov    %esp,%ebp
f010227a:	53                   	push   %ebx
f010227b:	83 ec 14             	sub    $0x14,%esp
f010227e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f0102281:	8b 45 14             	mov    0x14(%ebp),%eax
f0102284:	83 c8 04             	or     $0x4,%eax
f0102287:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010228b:	8b 45 10             	mov    0x10(%ebp),%eax
f010228e:	89 44 24 08          	mov    %eax,0x8(%esp)
f0102292:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102295:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102299:	89 1c 24             	mov    %ebx,(%esp)
f010229c:	e8 1a ff ff ff       	call   f01021bb <user_mem_check>
f01022a1:	85 c0                	test   %eax,%eax
f01022a3:	79 24                	jns    f01022c9 <user_mem_assert+0x52>
		cprintf("[%08x] user_mem_check assertion failure for "
f01022a5:	a1 58 d2 24 f0       	mov    0xf024d258,%eax
f01022aa:	89 44 24 08          	mov    %eax,0x8(%esp)
f01022ae:	8b 43 48             	mov    0x48(%ebx),%eax
f01022b1:	89 44 24 04          	mov    %eax,0x4(%esp)
f01022b5:	c7 04 24 38 8a 10 f0 	movl   $0xf0108a38,(%esp)
f01022bc:	e8 46 28 00 00       	call   f0104b07 <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f01022c1:	89 1c 24             	mov    %ebx,(%esp)
f01022c4:	e8 c6 22 00 00       	call   f010458f <env_destroy>
	}
}
f01022c9:	83 c4 14             	add    $0x14,%esp
f01022cc:	5b                   	pop    %ebx
f01022cd:	5d                   	pop    %ebp
f01022ce:	c3                   	ret    

f01022cf <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct Page *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f01022cf:	55                   	push   %ebp
f01022d0:	89 e5                	mov    %esp,%ebp
f01022d2:	53                   	push   %ebx
f01022d3:	83 ec 14             	sub    $0x14,%esp
f01022d6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// Fill this function in
        pte_t* pte = pgdir_walk(pgdir,va,0);
f01022d9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01022e0:	00 
f01022e1:	8b 45 0c             	mov    0xc(%ebp),%eax
f01022e4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01022e8:	8b 45 08             	mov    0x8(%ebp),%eax
f01022eb:	89 04 24             	mov    %eax,(%esp)
f01022ee:	e8 12 fe ff ff       	call   f0102105 <pgdir_walk>
        if(pte_store != NULL)
f01022f3:	85 db                	test   %ebx,%ebx
f01022f5:	74 02                	je     f01022f9 <page_lookup+0x2a>
           *pte_store = pte;
f01022f7:	89 03                	mov    %eax,(%ebx)
        if(pte == NULL || !((*pte) & PTE_P))
f01022f9:	85 c0                	test   %eax,%eax
f01022fb:	74 38                	je     f0102335 <page_lookup+0x66>
f01022fd:	8b 00                	mov    (%eax),%eax
f01022ff:	a8 01                	test   $0x1,%al
f0102301:	74 32                	je     f0102335 <page_lookup+0x66>
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102303:	c1 e8 0c             	shr    $0xc,%eax
f0102306:	3b 05 a8 de 24 f0    	cmp    0xf024dea8,%eax
f010230c:	72 1c                	jb     f010232a <page_lookup+0x5b>
		panic("pa2page called with invalid pa");
f010230e:	c7 44 24 08 70 8a 10 	movl   $0xf0108a70,0x8(%esp)
f0102315:	f0 
f0102316:	c7 44 24 04 4f 00 00 	movl   $0x4f,0x4(%esp)
f010231d:	00 
f010231e:	c7 04 24 32 86 10 f0 	movl   $0xf0108632,(%esp)
f0102325:	e8 5b dd ff ff       	call   f0100085 <_panic>
	return &pages[PGNUM(pa)];
f010232a:	c1 e0 03             	shl    $0x3,%eax
f010232d:	03 05 b0 de 24 f0    	add    0xf024deb0,%eax
	   return NULL;
        else
           return pa2page(PTE_ADDR(*pte));
f0102333:	eb 05                	jmp    f010233a <page_lookup+0x6b>
f0102335:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010233a:	83 c4 14             	add    $0x14,%esp
f010233d:	5b                   	pop    %ebx
f010233e:	5d                   	pop    %ebp
f010233f:	c3                   	ret    

f0102340 <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f0102340:	55                   	push   %ebp
f0102341:	89 e5                	mov    %esp,%ebp
f0102343:	83 ec 28             	sub    $0x28,%esp
f0102346:	89 5d f8             	mov    %ebx,-0x8(%ebp)
f0102349:	89 75 fc             	mov    %esi,-0x4(%ebp)
f010234c:	8b 75 08             	mov    0x8(%ebp),%esi
f010234f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Fill this function in
        pte_t* pte = NULL;
f0102352:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
        pte_t** pte_store = &pte;
        struct Page* page = page_lookup(pgdir,va,pte_store);
f0102359:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010235c:	89 44 24 08          	mov    %eax,0x8(%esp)
f0102360:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102364:	89 34 24             	mov    %esi,(%esp)
f0102367:	e8 63 ff ff ff       	call   f01022cf <page_lookup>
        if(page == NULL)
f010236c:	85 c0                	test   %eax,%eax
f010236e:	74 21                	je     f0102391 <page_remove+0x51>
           return;
        page_decref(page);
f0102370:	89 04 24             	mov    %eax,(%esp)
f0102373:	e8 4c f3 ff ff       	call   f01016c4 <page_decref>
        if(pte != NULL)
f0102378:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010237b:	85 c0                	test   %eax,%eax
f010237d:	74 06                	je     f0102385 <page_remove+0x45>
           *pte = 0;
f010237f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
        tlb_invalidate(pgdir,va);
f0102385:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102389:	89 34 24             	mov    %esi,(%esp)
f010238c:	e8 93 f3 ff ff       	call   f0101724 <tlb_invalidate>
}
f0102391:	8b 5d f8             	mov    -0x8(%ebp),%ebx
f0102394:	8b 75 fc             	mov    -0x4(%ebp),%esi
f0102397:	89 ec                	mov    %ebp,%esp
f0102399:	5d                   	pop    %ebp
f010239a:	c3                   	ret    

f010239b <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct Page *pp, void *va, int perm)
{
f010239b:	55                   	push   %ebp
f010239c:	89 e5                	mov    %esp,%ebp
f010239e:	83 ec 28             	sub    $0x28,%esp
f01023a1:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f01023a4:	89 75 f8             	mov    %esi,-0x8(%ebp)
f01023a7:	89 7d fc             	mov    %edi,-0x4(%ebp)
f01023aa:	8b 75 0c             	mov    0xc(%ebp),%esi
f01023ad:	8b 7d 10             	mov    0x10(%ebp),%edi
	// Fill this function in
        pte_t* pte = pgdir_walk(pgdir,va,1);
f01023b0:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01023b7:	00 
f01023b8:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01023bc:	8b 45 08             	mov    0x8(%ebp),%eax
f01023bf:	89 04 24             	mov    %eax,(%esp)
f01023c2:	e8 3e fd ff ff       	call   f0102105 <pgdir_walk>
f01023c7:	89 c3                	mov    %eax,%ebx
        if(pte == NULL)
f01023c9:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f01023ce:	85 db                	test   %ebx,%ebx
f01023d0:	74 38                	je     f010240a <page_insert+0x6f>
           return -E_NO_MEM;
        pp->pp_ref++;
f01023d2:	66 83 46 04 01       	addw   $0x1,0x4(%esi)
        if((*pte) & PTE_P){
f01023d7:	f6 03 01             	testb  $0x1,(%ebx)
f01023da:	74 0f                	je     f01023eb <page_insert+0x50>
           //tlb_invalidate(pgdir,va);
           page_remove(pgdir,va);
f01023dc:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01023e0:	8b 45 08             	mov    0x8(%ebp),%eax
f01023e3:	89 04 24             	mov    %eax,(%esp)
f01023e6:	e8 55 ff ff ff       	call   f0102340 <page_remove>
        }
        *pte = page2pa(pp) | perm | PTE_P;
f01023eb:	8b 55 14             	mov    0x14(%ebp),%edx
f01023ee:	83 ca 01             	or     $0x1,%edx
f01023f1:	2b 35 b0 de 24 f0    	sub    0xf024deb0,%esi
f01023f7:	c1 fe 03             	sar    $0x3,%esi
f01023fa:	89 f0                	mov    %esi,%eax
f01023fc:	c1 e0 0c             	shl    $0xc,%eax
f01023ff:	89 d6                	mov    %edx,%esi
f0102401:	09 c6                	or     %eax,%esi
f0102403:	89 33                	mov    %esi,(%ebx)
f0102405:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
f010240a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f010240d:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0102410:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0102413:	89 ec                	mov    %ebp,%esp
f0102415:	5d                   	pop    %ebp
f0102416:	c3                   	ret    

f0102417 <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f0102417:	55                   	push   %ebp
f0102418:	89 e5                	mov    %esp,%ebp
f010241a:	57                   	push   %edi
f010241b:	56                   	push   %esi
f010241c:	53                   	push   %ebx
f010241d:	83 ec 2c             	sub    $0x2c,%esp
f0102420:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0102423:	89 d3                	mov    %edx,%ebx
f0102425:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f0102428:	8b 7d 08             	mov    0x8(%ebp),%edi
	// Fill this function in
        int i;
        for(i = 0; i < size; i += PGSIZE){
f010242b:	85 c9                	test   %ecx,%ecx
f010242d:	74 49                	je     f0102478 <boot_map_region+0x61>
f010242f:	be 00 00 00 00       	mov    $0x0,%esi
           pte_t* pte = pgdir_walk(pgdir,(void*)va,1);
           if(pte == NULL)
              return;
           *pte = pa | perm | PTE_P;
f0102434:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102437:	83 c8 01             	or     $0x1,%eax
f010243a:	89 45 dc             	mov    %eax,-0x24(%ebp)
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	// Fill this function in
        int i;
        for(i = 0; i < size; i += PGSIZE){
           pte_t* pte = pgdir_walk(pgdir,(void*)va,1);
f010243d:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0102444:	00 
f0102445:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102449:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010244c:	89 04 24             	mov    %eax,(%esp)
f010244f:	e8 b1 fc ff ff       	call   f0102105 <pgdir_walk>
           if(pte == NULL)
f0102454:	85 c0                	test   %eax,%eax
f0102456:	74 20                	je     f0102478 <boot_map_region+0x61>
              return;
           *pte = pa | perm | PTE_P;
f0102458:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010245b:	09 fa                	or     %edi,%edx
f010245d:	89 10                	mov    %edx,(%eax)
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	// Fill this function in
        int i;
        for(i = 0; i < size; i += PGSIZE){
f010245f:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102465:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
f0102468:	76 0e                	jbe    f0102478 <boot_map_region+0x61>
           pte_t* pte = pgdir_walk(pgdir,(void*)va,1);
           if(pte == NULL)
              return;
           *pte = pa | perm | PTE_P;
           va += PGSIZE;
f010246a:	81 c3 00 10 00 00    	add    $0x1000,%ebx
           pa += PGSIZE;
f0102470:	81 c7 00 10 00 00    	add    $0x1000,%edi
f0102476:	eb c5                	jmp    f010243d <boot_map_region+0x26>
        }
}
f0102478:	83 c4 2c             	add    $0x2c,%esp
f010247b:	5b                   	pop    %ebx
f010247c:	5e                   	pop    %esi
f010247d:	5f                   	pop    %edi
f010247e:	5d                   	pop    %ebp
f010247f:	c3                   	ret    

f0102480 <check_page_installed_pgdir>:
}

// check page_insert, page_remove, &c, with an installed kern_pgdir
static void
check_page_installed_pgdir(void)
{
f0102480:	55                   	push   %ebp
f0102481:	89 e5                	mov    %esp,%ebp
f0102483:	57                   	push   %edi
f0102484:	56                   	push   %esi
f0102485:	53                   	push   %ebx
f0102486:	83 ec 2c             	sub    $0x2c,%esp
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102489:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102490:	e8 f2 fb ff ff       	call   f0102087 <page_alloc>
f0102495:	89 c3                	mov    %eax,%ebx
f0102497:	85 c0                	test   %eax,%eax
f0102499:	75 24                	jne    f01024bf <check_page_installed_pgdir+0x3f>
f010249b:	c7 44 24 0c f9 86 10 	movl   $0xf01086f9,0xc(%esp)
f01024a2:	f0 
f01024a3:	c7 44 24 08 4c 86 10 	movl   $0xf010864c,0x8(%esp)
f01024aa:	f0 
f01024ab:	c7 44 24 04 34 05 00 	movl   $0x534,0x4(%esp)
f01024b2:	00 
f01024b3:	c7 04 24 26 86 10 f0 	movl   $0xf0108626,(%esp)
f01024ba:	e8 c6 db ff ff       	call   f0100085 <_panic>
	assert((pp1 = page_alloc(0)));
f01024bf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01024c6:	e8 bc fb ff ff       	call   f0102087 <page_alloc>
f01024cb:	89 c7                	mov    %eax,%edi
f01024cd:	85 c0                	test   %eax,%eax
f01024cf:	75 24                	jne    f01024f5 <check_page_installed_pgdir+0x75>
f01024d1:	c7 44 24 0c 0f 87 10 	movl   $0xf010870f,0xc(%esp)
f01024d8:	f0 
f01024d9:	c7 44 24 08 4c 86 10 	movl   $0xf010864c,0x8(%esp)
f01024e0:	f0 
f01024e1:	c7 44 24 04 35 05 00 	movl   $0x535,0x4(%esp)
f01024e8:	00 
f01024e9:	c7 04 24 26 86 10 f0 	movl   $0xf0108626,(%esp)
f01024f0:	e8 90 db ff ff       	call   f0100085 <_panic>
	assert((pp2 = page_alloc(0)));
f01024f5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01024fc:	e8 86 fb ff ff       	call   f0102087 <page_alloc>
f0102501:	89 c6                	mov    %eax,%esi
f0102503:	85 c0                	test   %eax,%eax
f0102505:	75 24                	jne    f010252b <check_page_installed_pgdir+0xab>
f0102507:	c7 44 24 0c 25 87 10 	movl   $0xf0108725,0xc(%esp)
f010250e:	f0 
f010250f:	c7 44 24 08 4c 86 10 	movl   $0xf010864c,0x8(%esp)
f0102516:	f0 
f0102517:	c7 44 24 04 36 05 00 	movl   $0x536,0x4(%esp)
f010251e:	00 
f010251f:	c7 04 24 26 86 10 f0 	movl   $0xf0108626,(%esp)
f0102526:	e8 5a db ff ff       	call   f0100085 <_panic>
	page_free(pp0);
f010252b:	89 1c 24             	mov    %ebx,(%esp)
f010252e:	e8 7c f1 ff ff       	call   f01016af <page_free>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0102533:	89 f8                	mov    %edi,%eax
f0102535:	2b 05 b0 de 24 f0    	sub    0xf024deb0,%eax
f010253b:	c1 f8 03             	sar    $0x3,%eax
f010253e:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102541:	89 c2                	mov    %eax,%edx
f0102543:	c1 ea 0c             	shr    $0xc,%edx
f0102546:	3b 15 a8 de 24 f0    	cmp    0xf024dea8,%edx
f010254c:	72 20                	jb     f010256e <check_page_installed_pgdir+0xee>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010254e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102552:	c7 44 24 08 80 7e 10 	movl   $0xf0107e80,0x8(%esp)
f0102559:	f0 
f010255a:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0102561:	00 
f0102562:	c7 04 24 32 86 10 f0 	movl   $0xf0108632,(%esp)
f0102569:	e8 17 db ff ff       	call   f0100085 <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f010256e:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102575:	00 
f0102576:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f010257d:	00 
f010257e:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102583:	89 04 24             	mov    %eax,(%esp)
f0102586:	e8 8b 4a 00 00       	call   f0107016 <memset>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f010258b:	89 75 e4             	mov    %esi,-0x1c(%ebp)
f010258e:	89 f0                	mov    %esi,%eax
f0102590:	2b 05 b0 de 24 f0    	sub    0xf024deb0,%eax
f0102596:	c1 f8 03             	sar    $0x3,%eax
f0102599:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010259c:	89 c2                	mov    %eax,%edx
f010259e:	c1 ea 0c             	shr    $0xc,%edx
f01025a1:	3b 15 a8 de 24 f0    	cmp    0xf024dea8,%edx
f01025a7:	72 20                	jb     f01025c9 <check_page_installed_pgdir+0x149>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01025a9:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01025ad:	c7 44 24 08 80 7e 10 	movl   $0xf0107e80,0x8(%esp)
f01025b4:	f0 
f01025b5:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f01025bc:	00 
f01025bd:	c7 04 24 32 86 10 f0 	movl   $0xf0108632,(%esp)
f01025c4:	e8 bc da ff ff       	call   f0100085 <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f01025c9:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01025d0:	00 
f01025d1:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f01025d8:	00 
f01025d9:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01025de:	89 04 24             	mov    %eax,(%esp)
f01025e1:	e8 30 4a 00 00       	call   f0107016 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f01025e6:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01025ed:	00 
f01025ee:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01025f5:	00 
f01025f6:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01025fa:	a1 ac de 24 f0       	mov    0xf024deac,%eax
f01025ff:	89 04 24             	mov    %eax,(%esp)
f0102602:	e8 94 fd ff ff       	call   f010239b <page_insert>
	assert(pp1->pp_ref == 1);
f0102607:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f010260c:	74 24                	je     f0102632 <check_page_installed_pgdir+0x1b2>
f010260e:	c7 44 24 0c 3b 87 10 	movl   $0xf010873b,0xc(%esp)
f0102615:	f0 
f0102616:	c7 44 24 08 4c 86 10 	movl   $0xf010864c,0x8(%esp)
f010261d:	f0 
f010261e:	c7 44 24 04 3b 05 00 	movl   $0x53b,0x4(%esp)
f0102625:	00 
f0102626:	c7 04 24 26 86 10 f0 	movl   $0xf0108626,(%esp)
f010262d:	e8 53 da ff ff       	call   f0100085 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102632:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102639:	01 01 01 
f010263c:	74 24                	je     f0102662 <check_page_installed_pgdir+0x1e2>
f010263e:	c7 44 24 0c 90 8a 10 	movl   $0xf0108a90,0xc(%esp)
f0102645:	f0 
f0102646:	c7 44 24 08 4c 86 10 	movl   $0xf010864c,0x8(%esp)
f010264d:	f0 
f010264e:	c7 44 24 04 3c 05 00 	movl   $0x53c,0x4(%esp)
f0102655:	00 
f0102656:	c7 04 24 26 86 10 f0 	movl   $0xf0108626,(%esp)
f010265d:	e8 23 da ff ff       	call   f0100085 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102662:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102669:	00 
f010266a:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102671:	00 
f0102672:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102676:	a1 ac de 24 f0       	mov    0xf024deac,%eax
f010267b:	89 04 24             	mov    %eax,(%esp)
f010267e:	e8 18 fd ff ff       	call   f010239b <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102683:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f010268a:	02 02 02 
f010268d:	74 24                	je     f01026b3 <check_page_installed_pgdir+0x233>
f010268f:	c7 44 24 0c b4 8a 10 	movl   $0xf0108ab4,0xc(%esp)
f0102696:	f0 
f0102697:	c7 44 24 08 4c 86 10 	movl   $0xf010864c,0x8(%esp)
f010269e:	f0 
f010269f:	c7 44 24 04 3e 05 00 	movl   $0x53e,0x4(%esp)
f01026a6:	00 
f01026a7:	c7 04 24 26 86 10 f0 	movl   $0xf0108626,(%esp)
f01026ae:	e8 d2 d9 ff ff       	call   f0100085 <_panic>
	assert(pp2->pp_ref == 1);
f01026b3:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01026b8:	74 24                	je     f01026de <check_page_installed_pgdir+0x25e>
f01026ba:	c7 44 24 0c 4c 87 10 	movl   $0xf010874c,0xc(%esp)
f01026c1:	f0 
f01026c2:	c7 44 24 08 4c 86 10 	movl   $0xf010864c,0x8(%esp)
f01026c9:	f0 
f01026ca:	c7 44 24 04 3f 05 00 	movl   $0x53f,0x4(%esp)
f01026d1:	00 
f01026d2:	c7 04 24 26 86 10 f0 	movl   $0xf0108626,(%esp)
f01026d9:	e8 a7 d9 ff ff       	call   f0100085 <_panic>
	assert(pp1->pp_ref == 0);
f01026de:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f01026e3:	74 24                	je     f0102709 <check_page_installed_pgdir+0x289>
f01026e5:	c7 44 24 0c 5d 87 10 	movl   $0xf010875d,0xc(%esp)
f01026ec:	f0 
f01026ed:	c7 44 24 08 4c 86 10 	movl   $0xf010864c,0x8(%esp)
f01026f4:	f0 
f01026f5:	c7 44 24 04 40 05 00 	movl   $0x540,0x4(%esp)
f01026fc:	00 
f01026fd:	c7 04 24 26 86 10 f0 	movl   $0xf0108626,(%esp)
f0102704:	e8 7c d9 ff ff       	call   f0100085 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102709:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102710:	03 03 03 
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0102713:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102716:	2b 05 b0 de 24 f0    	sub    0xf024deb0,%eax
f010271c:	c1 f8 03             	sar    $0x3,%eax
f010271f:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102722:	89 c2                	mov    %eax,%edx
f0102724:	c1 ea 0c             	shr    $0xc,%edx
f0102727:	3b 15 a8 de 24 f0    	cmp    0xf024dea8,%edx
f010272d:	72 20                	jb     f010274f <check_page_installed_pgdir+0x2cf>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010272f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102733:	c7 44 24 08 80 7e 10 	movl   $0xf0107e80,0x8(%esp)
f010273a:	f0 
f010273b:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0102742:	00 
f0102743:	c7 04 24 32 86 10 f0 	movl   $0xf0108632,(%esp)
f010274a:	e8 36 d9 ff ff       	call   f0100085 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f010274f:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0102756:	03 03 03 
f0102759:	74 24                	je     f010277f <check_page_installed_pgdir+0x2ff>
f010275b:	c7 44 24 0c d8 8a 10 	movl   $0xf0108ad8,0xc(%esp)
f0102762:	f0 
f0102763:	c7 44 24 08 4c 86 10 	movl   $0xf010864c,0x8(%esp)
f010276a:	f0 
f010276b:	c7 44 24 04 42 05 00 	movl   $0x542,0x4(%esp)
f0102772:	00 
f0102773:	c7 04 24 26 86 10 f0 	movl   $0xf0108626,(%esp)
f010277a:	e8 06 d9 ff ff       	call   f0100085 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f010277f:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102786:	00 
f0102787:	a1 ac de 24 f0       	mov    0xf024deac,%eax
f010278c:	89 04 24             	mov    %eax,(%esp)
f010278f:	e8 ac fb ff ff       	call   f0102340 <page_remove>
	assert(pp2->pp_ref == 0);
f0102794:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102799:	74 24                	je     f01027bf <check_page_installed_pgdir+0x33f>
f010279b:	c7 44 24 0c 6e 87 10 	movl   $0xf010876e,0xc(%esp)
f01027a2:	f0 
f01027a3:	c7 44 24 08 4c 86 10 	movl   $0xf010864c,0x8(%esp)
f01027aa:	f0 
f01027ab:	c7 44 24 04 44 05 00 	movl   $0x544,0x4(%esp)
f01027b2:	00 
f01027b3:	c7 04 24 26 86 10 f0 	movl   $0xf0108626,(%esp)
f01027ba:	e8 c6 d8 ff ff       	call   f0100085 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01027bf:	a1 ac de 24 f0       	mov    0xf024deac,%eax
f01027c4:	8b 08                	mov    (%eax),%ecx
f01027c6:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f01027cc:	89 da                	mov    %ebx,%edx
f01027ce:	2b 15 b0 de 24 f0    	sub    0xf024deb0,%edx
f01027d4:	c1 fa 03             	sar    $0x3,%edx
f01027d7:	c1 e2 0c             	shl    $0xc,%edx
f01027da:	39 d1                	cmp    %edx,%ecx
f01027dc:	74 24                	je     f0102802 <check_page_installed_pgdir+0x382>
f01027de:	c7 44 24 0c 04 8b 10 	movl   $0xf0108b04,0xc(%esp)
f01027e5:	f0 
f01027e6:	c7 44 24 08 4c 86 10 	movl   $0xf010864c,0x8(%esp)
f01027ed:	f0 
f01027ee:	c7 44 24 04 47 05 00 	movl   $0x547,0x4(%esp)
f01027f5:	00 
f01027f6:	c7 04 24 26 86 10 f0 	movl   $0xf0108626,(%esp)
f01027fd:	e8 83 d8 ff ff       	call   f0100085 <_panic>
	kern_pgdir[0] = 0;
f0102802:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f0102808:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f010280d:	74 24                	je     f0102833 <check_page_installed_pgdir+0x3b3>
f010280f:	c7 44 24 0c 7f 87 10 	movl   $0xf010877f,0xc(%esp)
f0102816:	f0 
f0102817:	c7 44 24 08 4c 86 10 	movl   $0xf010864c,0x8(%esp)
f010281e:	f0 
f010281f:	c7 44 24 04 49 05 00 	movl   $0x549,0x4(%esp)
f0102826:	00 
f0102827:	c7 04 24 26 86 10 f0 	movl   $0xf0108626,(%esp)
f010282e:	e8 52 d8 ff ff       	call   f0100085 <_panic>
	pp0->pp_ref = 0;
f0102833:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f0102839:	89 1c 24             	mov    %ebx,(%esp)
f010283c:	e8 6e ee ff ff       	call   f01016af <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102841:	c7 04 24 2c 8b 10 f0 	movl   $0xf0108b2c,(%esp)
f0102848:	e8 ba 22 00 00       	call   f0104b07 <cprintf>
}
f010284d:	83 c4 2c             	add    $0x2c,%esp
f0102850:	5b                   	pop    %ebx
f0102851:	5e                   	pop    %esi
f0102852:	5f                   	pop    %edi
f0102853:	5d                   	pop    %ebp
f0102854:	c3                   	ret    

f0102855 <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f0102855:	55                   	push   %ebp
f0102856:	89 e5                	mov    %esp,%ebp
f0102858:	57                   	push   %edi
f0102859:	56                   	push   %esi
f010285a:	53                   	push   %ebx
f010285b:	83 ec 3c             	sub    $0x3c,%esp
	uint32_t cr0;
	size_t n;

	// Find out how much memory the machine has (npages & npages_basemem).
	i386_detect_memory();
f010285e:	e8 f2 f0 ff ff       	call   f0101955 <i386_detect_memory>
	// Remove this line when you're ready to test this function.
	//panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f0102863:	b8 00 10 00 00       	mov    $0x1000,%eax
f0102868:	e8 ec ee ff ff       	call   f0101759 <boot_alloc>
f010286d:	a3 ac de 24 f0       	mov    %eax,0xf024deac
	memset(kern_pgdir, 0, PGSIZE);
f0102872:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102879:	00 
f010287a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102881:	00 
f0102882:	89 04 24             	mov    %eax,(%esp)
f0102885:	e8 8c 47 00 00       	call   f0107016 <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following two lines.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f010288a:	a1 ac de 24 f0       	mov    0xf024deac,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010288f:	89 c2                	mov    %eax,%edx
f0102891:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102896:	77 20                	ja     f01028b8 <mem_init+0x63>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102898:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010289c:	c7 44 24 08 5c 7e 10 	movl   $0xf0107e5c,0x8(%esp)
f01028a3:	f0 
f01028a4:	c7 44 24 04 99 00 00 	movl   $0x99,0x4(%esp)
f01028ab:	00 
f01028ac:	c7 04 24 26 86 10 f0 	movl   $0xf0108626,(%esp)
f01028b3:	e8 cd d7 ff ff       	call   f0100085 <_panic>
f01028b8:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f01028be:	83 ca 05             	or     $0x5,%edx
f01028c1:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate an array of npages 'struct Page's and store it in 'pages'.
	// The kernel uses this array to keep track of physical pages: for
	// each physical page, there is a corresponding struct Page in this
	// array.  'npages' is the number of physical pages in memory.
	// Your code goes here:
        pages = (struct Page*)boot_alloc(npages*sizeof(struct Page));
f01028c7:	a1 a8 de 24 f0       	mov    0xf024dea8,%eax
f01028cc:	c1 e0 03             	shl    $0x3,%eax
f01028cf:	e8 85 ee ff ff       	call   f0101759 <boot_alloc>
f01028d4:	a3 b0 de 24 f0       	mov    %eax,0xf024deb0
        //cprintf("sizeofPage: %d\n",sizeof(struct Page));
        memset(pages,0,npages*sizeof(struct Page));
f01028d9:	8b 15 a8 de 24 f0    	mov    0xf024dea8,%edx
f01028df:	c1 e2 03             	shl    $0x3,%edx
f01028e2:	89 54 24 08          	mov    %edx,0x8(%esp)
f01028e6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01028ed:	00 
f01028ee:	89 04 24             	mov    %eax,(%esp)
f01028f1:	e8 20 47 00 00       	call   f0107016 <memset>

	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.

        envs = (struct Env*)boot_alloc(NENV*sizeof(struct Env));
f01028f6:	b8 00 10 02 00       	mov    $0x21000,%eax
f01028fb:	e8 59 ee ff ff       	call   f0101759 <boot_alloc>
f0102900:	a3 5c d2 24 f0       	mov    %eax,0xf024d25c
        memset(envs,0,NENV*sizeof(struct Env));
f0102905:	c7 44 24 08 00 10 02 	movl   $0x21000,0x8(%esp)
f010290c:	00 
f010290d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102914:	00 
f0102915:	89 04 24             	mov    %eax,(%esp)
f0102918:	e8 f9 46 00 00       	call   f0107016 <memset>
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f010291d:	e8 9a ee ff ff       	call   f01017bc <page_init>

	check_page_free_list(1);
f0102922:	b8 01 00 00 00       	mov    $0x1,%eax
f0102927:	e8 b8 f3 ff ff       	call   f0101ce4 <check_page_free_list>
	int nfree;
	struct Page *fl;
	char *c;
	int i;

	if (!pages)
f010292c:	83 3d b0 de 24 f0 00 	cmpl   $0x0,0xf024deb0
f0102933:	75 1c                	jne    f0102951 <mem_init+0xfc>
		panic("'pages' is a null pointer!");
f0102935:	c7 44 24 08 90 87 10 	movl   $0xf0108790,0x8(%esp)
f010293c:	f0 
f010293d:	c7 44 24 04 85 03 00 	movl   $0x385,0x4(%esp)
f0102944:	00 
f0102945:	c7 04 24 26 86 10 f0 	movl   $0xf0108626,(%esp)
f010294c:	e8 34 d7 ff ff       	call   f0100085 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0102951:	a1 50 d2 24 f0       	mov    0xf024d250,%eax
f0102956:	bb 00 00 00 00       	mov    $0x0,%ebx
f010295b:	85 c0                	test   %eax,%eax
f010295d:	74 09                	je     f0102968 <mem_init+0x113>
		++nfree;
f010295f:	83 c3 01             	add    $0x1,%ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0102962:	8b 00                	mov    (%eax),%eax
f0102964:	85 c0                	test   %eax,%eax
f0102966:	75 f7                	jne    f010295f <mem_init+0x10a>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102968:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010296f:	e8 13 f7 ff ff       	call   f0102087 <page_alloc>
f0102974:	89 c6                	mov    %eax,%esi
f0102976:	85 c0                	test   %eax,%eax
f0102978:	75 24                	jne    f010299e <mem_init+0x149>
f010297a:	c7 44 24 0c f9 86 10 	movl   $0xf01086f9,0xc(%esp)
f0102981:	f0 
f0102982:	c7 44 24 08 4c 86 10 	movl   $0xf010864c,0x8(%esp)
f0102989:	f0 
f010298a:	c7 44 24 04 8d 03 00 	movl   $0x38d,0x4(%esp)
f0102991:	00 
f0102992:	c7 04 24 26 86 10 f0 	movl   $0xf0108626,(%esp)
f0102999:	e8 e7 d6 ff ff       	call   f0100085 <_panic>
	assert((pp1 = page_alloc(0)));
f010299e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01029a5:	e8 dd f6 ff ff       	call   f0102087 <page_alloc>
f01029aa:	89 c7                	mov    %eax,%edi
f01029ac:	85 c0                	test   %eax,%eax
f01029ae:	75 24                	jne    f01029d4 <mem_init+0x17f>
f01029b0:	c7 44 24 0c 0f 87 10 	movl   $0xf010870f,0xc(%esp)
f01029b7:	f0 
f01029b8:	c7 44 24 08 4c 86 10 	movl   $0xf010864c,0x8(%esp)
f01029bf:	f0 
f01029c0:	c7 44 24 04 8e 03 00 	movl   $0x38e,0x4(%esp)
f01029c7:	00 
f01029c8:	c7 04 24 26 86 10 f0 	movl   $0xf0108626,(%esp)
f01029cf:	e8 b1 d6 ff ff       	call   f0100085 <_panic>
	assert((pp2 = page_alloc(0)));
f01029d4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01029db:	e8 a7 f6 ff ff       	call   f0102087 <page_alloc>
f01029e0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01029e3:	85 c0                	test   %eax,%eax
f01029e5:	75 24                	jne    f0102a0b <mem_init+0x1b6>
f01029e7:	c7 44 24 0c 25 87 10 	movl   $0xf0108725,0xc(%esp)
f01029ee:	f0 
f01029ef:	c7 44 24 08 4c 86 10 	movl   $0xf010864c,0x8(%esp)
f01029f6:	f0 
f01029f7:	c7 44 24 04 8f 03 00 	movl   $0x38f,0x4(%esp)
f01029fe:	00 
f01029ff:	c7 04 24 26 86 10 f0 	movl   $0xf0108626,(%esp)
f0102a06:	e8 7a d6 ff ff       	call   f0100085 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0102a0b:	39 fe                	cmp    %edi,%esi
f0102a0d:	75 24                	jne    f0102a33 <mem_init+0x1de>
f0102a0f:	c7 44 24 0c ab 87 10 	movl   $0xf01087ab,0xc(%esp)
f0102a16:	f0 
f0102a17:	c7 44 24 08 4c 86 10 	movl   $0xf010864c,0x8(%esp)
f0102a1e:	f0 
f0102a1f:	c7 44 24 04 92 03 00 	movl   $0x392,0x4(%esp)
f0102a26:	00 
f0102a27:	c7 04 24 26 86 10 f0 	movl   $0xf0108626,(%esp)
f0102a2e:	e8 52 d6 ff ff       	call   f0100085 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0102a33:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f0102a36:	74 05                	je     f0102a3d <mem_init+0x1e8>
f0102a38:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f0102a3b:	75 24                	jne    f0102a61 <mem_init+0x20c>
f0102a3d:	c7 44 24 0c 58 8b 10 	movl   $0xf0108b58,0xc(%esp)
f0102a44:	f0 
f0102a45:	c7 44 24 08 4c 86 10 	movl   $0xf010864c,0x8(%esp)
f0102a4c:	f0 
f0102a4d:	c7 44 24 04 93 03 00 	movl   $0x393,0x4(%esp)
f0102a54:	00 
f0102a55:	c7 04 24 26 86 10 f0 	movl   $0xf0108626,(%esp)
f0102a5c:	e8 24 d6 ff ff       	call   f0100085 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0102a61:	8b 15 b0 de 24 f0    	mov    0xf024deb0,%edx
	assert(page2pa(pp0) < npages*PGSIZE);
f0102a67:	a1 a8 de 24 f0       	mov    0xf024dea8,%eax
f0102a6c:	c1 e0 0c             	shl    $0xc,%eax
f0102a6f:	89 f1                	mov    %esi,%ecx
f0102a71:	29 d1                	sub    %edx,%ecx
f0102a73:	c1 f9 03             	sar    $0x3,%ecx
f0102a76:	c1 e1 0c             	shl    $0xc,%ecx
f0102a79:	39 c1                	cmp    %eax,%ecx
f0102a7b:	72 24                	jb     f0102aa1 <mem_init+0x24c>
f0102a7d:	c7 44 24 0c bd 87 10 	movl   $0xf01087bd,0xc(%esp)
f0102a84:	f0 
f0102a85:	c7 44 24 08 4c 86 10 	movl   $0xf010864c,0x8(%esp)
f0102a8c:	f0 
f0102a8d:	c7 44 24 04 94 03 00 	movl   $0x394,0x4(%esp)
f0102a94:	00 
f0102a95:	c7 04 24 26 86 10 f0 	movl   $0xf0108626,(%esp)
f0102a9c:	e8 e4 d5 ff ff       	call   f0100085 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f0102aa1:	89 f9                	mov    %edi,%ecx
f0102aa3:	29 d1                	sub    %edx,%ecx
f0102aa5:	c1 f9 03             	sar    $0x3,%ecx
f0102aa8:	c1 e1 0c             	shl    $0xc,%ecx
f0102aab:	39 c8                	cmp    %ecx,%eax
f0102aad:	77 24                	ja     f0102ad3 <mem_init+0x27e>
f0102aaf:	c7 44 24 0c da 87 10 	movl   $0xf01087da,0xc(%esp)
f0102ab6:	f0 
f0102ab7:	c7 44 24 08 4c 86 10 	movl   $0xf010864c,0x8(%esp)
f0102abe:	f0 
f0102abf:	c7 44 24 04 95 03 00 	movl   $0x395,0x4(%esp)
f0102ac6:	00 
f0102ac7:	c7 04 24 26 86 10 f0 	movl   $0xf0108626,(%esp)
f0102ace:	e8 b2 d5 ff ff       	call   f0100085 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f0102ad3:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0102ad6:	29 d1                	sub    %edx,%ecx
f0102ad8:	89 ca                	mov    %ecx,%edx
f0102ada:	c1 fa 03             	sar    $0x3,%edx
f0102add:	c1 e2 0c             	shl    $0xc,%edx
f0102ae0:	39 d0                	cmp    %edx,%eax
f0102ae2:	77 24                	ja     f0102b08 <mem_init+0x2b3>
f0102ae4:	c7 44 24 0c f7 87 10 	movl   $0xf01087f7,0xc(%esp)
f0102aeb:	f0 
f0102aec:	c7 44 24 08 4c 86 10 	movl   $0xf010864c,0x8(%esp)
f0102af3:	f0 
f0102af4:	c7 44 24 04 96 03 00 	movl   $0x396,0x4(%esp)
f0102afb:	00 
f0102afc:	c7 04 24 26 86 10 f0 	movl   $0xf0108626,(%esp)
f0102b03:	e8 7d d5 ff ff       	call   f0100085 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0102b08:	a1 50 d2 24 f0       	mov    0xf024d250,%eax
f0102b0d:	89 45 cc             	mov    %eax,-0x34(%ebp)
	page_free_list = 0;
f0102b10:	c7 05 50 d2 24 f0 00 	movl   $0x0,0xf024d250
f0102b17:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0102b1a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102b21:	e8 61 f5 ff ff       	call   f0102087 <page_alloc>
f0102b26:	85 c0                	test   %eax,%eax
f0102b28:	74 24                	je     f0102b4e <mem_init+0x2f9>
f0102b2a:	c7 44 24 0c 14 88 10 	movl   $0xf0108814,0xc(%esp)
f0102b31:	f0 
f0102b32:	c7 44 24 08 4c 86 10 	movl   $0xf010864c,0x8(%esp)
f0102b39:	f0 
f0102b3a:	c7 44 24 04 9d 03 00 	movl   $0x39d,0x4(%esp)
f0102b41:	00 
f0102b42:	c7 04 24 26 86 10 f0 	movl   $0xf0108626,(%esp)
f0102b49:	e8 37 d5 ff ff       	call   f0100085 <_panic>

	// free and re-allocate?
	page_free(pp0);
f0102b4e:	89 34 24             	mov    %esi,(%esp)
f0102b51:	e8 59 eb ff ff       	call   f01016af <page_free>
	page_free(pp1);
f0102b56:	89 3c 24             	mov    %edi,(%esp)
f0102b59:	e8 51 eb ff ff       	call   f01016af <page_free>
	page_free(pp2);
f0102b5e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0102b61:	89 14 24             	mov    %edx,(%esp)
f0102b64:	e8 46 eb ff ff       	call   f01016af <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102b69:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102b70:	e8 12 f5 ff ff       	call   f0102087 <page_alloc>
f0102b75:	89 c6                	mov    %eax,%esi
f0102b77:	85 c0                	test   %eax,%eax
f0102b79:	75 24                	jne    f0102b9f <mem_init+0x34a>
f0102b7b:	c7 44 24 0c f9 86 10 	movl   $0xf01086f9,0xc(%esp)
f0102b82:	f0 
f0102b83:	c7 44 24 08 4c 86 10 	movl   $0xf010864c,0x8(%esp)
f0102b8a:	f0 
f0102b8b:	c7 44 24 04 a4 03 00 	movl   $0x3a4,0x4(%esp)
f0102b92:	00 
f0102b93:	c7 04 24 26 86 10 f0 	movl   $0xf0108626,(%esp)
f0102b9a:	e8 e6 d4 ff ff       	call   f0100085 <_panic>
	assert((pp1 = page_alloc(0)));
f0102b9f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102ba6:	e8 dc f4 ff ff       	call   f0102087 <page_alloc>
f0102bab:	89 c7                	mov    %eax,%edi
f0102bad:	85 c0                	test   %eax,%eax
f0102baf:	75 24                	jne    f0102bd5 <mem_init+0x380>
f0102bb1:	c7 44 24 0c 0f 87 10 	movl   $0xf010870f,0xc(%esp)
f0102bb8:	f0 
f0102bb9:	c7 44 24 08 4c 86 10 	movl   $0xf010864c,0x8(%esp)
f0102bc0:	f0 
f0102bc1:	c7 44 24 04 a5 03 00 	movl   $0x3a5,0x4(%esp)
f0102bc8:	00 
f0102bc9:	c7 04 24 26 86 10 f0 	movl   $0xf0108626,(%esp)
f0102bd0:	e8 b0 d4 ff ff       	call   f0100085 <_panic>
	assert((pp2 = page_alloc(0)));
f0102bd5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102bdc:	e8 a6 f4 ff ff       	call   f0102087 <page_alloc>
f0102be1:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102be4:	85 c0                	test   %eax,%eax
f0102be6:	75 24                	jne    f0102c0c <mem_init+0x3b7>
f0102be8:	c7 44 24 0c 25 87 10 	movl   $0xf0108725,0xc(%esp)
f0102bef:	f0 
f0102bf0:	c7 44 24 08 4c 86 10 	movl   $0xf010864c,0x8(%esp)
f0102bf7:	f0 
f0102bf8:	c7 44 24 04 a6 03 00 	movl   $0x3a6,0x4(%esp)
f0102bff:	00 
f0102c00:	c7 04 24 26 86 10 f0 	movl   $0xf0108626,(%esp)
f0102c07:	e8 79 d4 ff ff       	call   f0100085 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0102c0c:	39 fe                	cmp    %edi,%esi
f0102c0e:	75 24                	jne    f0102c34 <mem_init+0x3df>
f0102c10:	c7 44 24 0c ab 87 10 	movl   $0xf01087ab,0xc(%esp)
f0102c17:	f0 
f0102c18:	c7 44 24 08 4c 86 10 	movl   $0xf010864c,0x8(%esp)
f0102c1f:	f0 
f0102c20:	c7 44 24 04 a8 03 00 	movl   $0x3a8,0x4(%esp)
f0102c27:	00 
f0102c28:	c7 04 24 26 86 10 f0 	movl   $0xf0108626,(%esp)
f0102c2f:	e8 51 d4 ff ff       	call   f0100085 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0102c34:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f0102c37:	74 05                	je     f0102c3e <mem_init+0x3e9>
f0102c39:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f0102c3c:	75 24                	jne    f0102c62 <mem_init+0x40d>
f0102c3e:	c7 44 24 0c 58 8b 10 	movl   $0xf0108b58,0xc(%esp)
f0102c45:	f0 
f0102c46:	c7 44 24 08 4c 86 10 	movl   $0xf010864c,0x8(%esp)
f0102c4d:	f0 
f0102c4e:	c7 44 24 04 a9 03 00 	movl   $0x3a9,0x4(%esp)
f0102c55:	00 
f0102c56:	c7 04 24 26 86 10 f0 	movl   $0xf0108626,(%esp)
f0102c5d:	e8 23 d4 ff ff       	call   f0100085 <_panic>
	assert(!page_alloc(0));
f0102c62:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102c69:	e8 19 f4 ff ff       	call   f0102087 <page_alloc>
f0102c6e:	85 c0                	test   %eax,%eax
f0102c70:	74 24                	je     f0102c96 <mem_init+0x441>
f0102c72:	c7 44 24 0c 14 88 10 	movl   $0xf0108814,0xc(%esp)
f0102c79:	f0 
f0102c7a:	c7 44 24 08 4c 86 10 	movl   $0xf010864c,0x8(%esp)
f0102c81:	f0 
f0102c82:	c7 44 24 04 aa 03 00 	movl   $0x3aa,0x4(%esp)
f0102c89:	00 
f0102c8a:	c7 04 24 26 86 10 f0 	movl   $0xf0108626,(%esp)
f0102c91:	e8 ef d3 ff ff       	call   f0100085 <_panic>
f0102c96:	89 75 d0             	mov    %esi,-0x30(%ebp)
f0102c99:	89 f0                	mov    %esi,%eax
f0102c9b:	2b 05 b0 de 24 f0    	sub    0xf024deb0,%eax
f0102ca1:	c1 f8 03             	sar    $0x3,%eax
f0102ca4:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102ca7:	89 c2                	mov    %eax,%edx
f0102ca9:	c1 ea 0c             	shr    $0xc,%edx
f0102cac:	3b 15 a8 de 24 f0    	cmp    0xf024dea8,%edx
f0102cb2:	72 20                	jb     f0102cd4 <mem_init+0x47f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102cb4:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102cb8:	c7 44 24 08 80 7e 10 	movl   $0xf0107e80,0x8(%esp)
f0102cbf:	f0 
f0102cc0:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0102cc7:	00 
f0102cc8:	c7 04 24 32 86 10 f0 	movl   $0xf0108632,(%esp)
f0102ccf:	e8 b1 d3 ff ff       	call   f0100085 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f0102cd4:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102cdb:	00 
f0102cdc:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f0102ce3:	00 
f0102ce4:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102ce9:	89 04 24             	mov    %eax,(%esp)
f0102cec:	e8 25 43 00 00       	call   f0107016 <memset>
	page_free(pp0);
f0102cf1:	89 34 24             	mov    %esi,(%esp)
f0102cf4:	e8 b6 e9 ff ff       	call   f01016af <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0102cf9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0102d00:	e8 82 f3 ff ff       	call   f0102087 <page_alloc>
f0102d05:	85 c0                	test   %eax,%eax
f0102d07:	75 24                	jne    f0102d2d <mem_init+0x4d8>
f0102d09:	c7 44 24 0c 23 88 10 	movl   $0xf0108823,0xc(%esp)
f0102d10:	f0 
f0102d11:	c7 44 24 08 4c 86 10 	movl   $0xf010864c,0x8(%esp)
f0102d18:	f0 
f0102d19:	c7 44 24 04 af 03 00 	movl   $0x3af,0x4(%esp)
f0102d20:	00 
f0102d21:	c7 04 24 26 86 10 f0 	movl   $0xf0108626,(%esp)
f0102d28:	e8 58 d3 ff ff       	call   f0100085 <_panic>
	assert(pp && pp0 == pp);
f0102d2d:	39 c6                	cmp    %eax,%esi
f0102d2f:	74 24                	je     f0102d55 <mem_init+0x500>
f0102d31:	c7 44 24 0c 41 88 10 	movl   $0xf0108841,0xc(%esp)
f0102d38:	f0 
f0102d39:	c7 44 24 08 4c 86 10 	movl   $0xf010864c,0x8(%esp)
f0102d40:	f0 
f0102d41:	c7 44 24 04 b0 03 00 	movl   $0x3b0,0x4(%esp)
f0102d48:	00 
f0102d49:	c7 04 24 26 86 10 f0 	movl   $0xf0108626,(%esp)
f0102d50:	e8 30 d3 ff ff       	call   f0100085 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0102d55:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0102d58:	2b 15 b0 de 24 f0    	sub    0xf024deb0,%edx
f0102d5e:	c1 fa 03             	sar    $0x3,%edx
f0102d61:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102d64:	89 d0                	mov    %edx,%eax
f0102d66:	c1 e8 0c             	shr    $0xc,%eax
f0102d69:	3b 05 a8 de 24 f0    	cmp    0xf024dea8,%eax
f0102d6f:	72 20                	jb     f0102d91 <mem_init+0x53c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102d71:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102d75:	c7 44 24 08 80 7e 10 	movl   $0xf0107e80,0x8(%esp)
f0102d7c:	f0 
f0102d7d:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0102d84:	00 
f0102d85:	c7 04 24 32 86 10 f0 	movl   $0xf0108632,(%esp)
f0102d8c:	e8 f4 d2 ff ff       	call   f0100085 <_panic>
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f0102d91:	80 ba 00 00 00 f0 00 	cmpb   $0x0,-0x10000000(%edx)
f0102d98:	75 11                	jne    f0102dab <mem_init+0x556>
f0102d9a:	8d 82 01 00 00 f0    	lea    -0xfffffff(%edx),%eax
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102da0:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f0102da6:	80 38 00             	cmpb   $0x0,(%eax)
f0102da9:	74 24                	je     f0102dcf <mem_init+0x57a>
f0102dab:	c7 44 24 0c 51 88 10 	movl   $0xf0108851,0xc(%esp)
f0102db2:	f0 
f0102db3:	c7 44 24 08 4c 86 10 	movl   $0xf010864c,0x8(%esp)
f0102dba:	f0 
f0102dbb:	c7 44 24 04 b3 03 00 	movl   $0x3b3,0x4(%esp)
f0102dc2:	00 
f0102dc3:	c7 04 24 26 86 10 f0 	movl   $0xf0108626,(%esp)
f0102dca:	e8 b6 d2 ff ff       	call   f0100085 <_panic>
f0102dcf:	83 c0 01             	add    $0x1,%eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f0102dd2:	39 d0                	cmp    %edx,%eax
f0102dd4:	75 d0                	jne    f0102da6 <mem_init+0x551>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f0102dd6:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0102dd9:	89 0d 50 d2 24 f0    	mov    %ecx,0xf024d250

	// free the pages we took
	page_free(pp0);
f0102ddf:	89 34 24             	mov    %esi,(%esp)
f0102de2:	e8 c8 e8 ff ff       	call   f01016af <page_free>
	page_free(pp1);
f0102de7:	89 3c 24             	mov    %edi,(%esp)
f0102dea:	e8 c0 e8 ff ff       	call   f01016af <page_free>
	page_free(pp2);
f0102def:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102df2:	89 04 24             	mov    %eax,(%esp)
f0102df5:	e8 b5 e8 ff ff       	call   f01016af <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0102dfa:	a1 50 d2 24 f0       	mov    0xf024d250,%eax
f0102dff:	85 c0                	test   %eax,%eax
f0102e01:	74 09                	je     f0102e0c <mem_init+0x5b7>
		--nfree;
f0102e03:	83 eb 01             	sub    $0x1,%ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0102e06:	8b 00                	mov    (%eax),%eax
f0102e08:	85 c0                	test   %eax,%eax
f0102e0a:	75 f7                	jne    f0102e03 <mem_init+0x5ae>
		--nfree;
	assert(nfree == 0);
f0102e0c:	85 db                	test   %ebx,%ebx
f0102e0e:	74 24                	je     f0102e34 <mem_init+0x5df>
f0102e10:	c7 44 24 0c 5b 88 10 	movl   $0xf010885b,0xc(%esp)
f0102e17:	f0 
f0102e18:	c7 44 24 08 4c 86 10 	movl   $0xf010864c,0x8(%esp)
f0102e1f:	f0 
f0102e20:	c7 44 24 04 c0 03 00 	movl   $0x3c0,0x4(%esp)
f0102e27:	00 
f0102e28:	c7 04 24 26 86 10 f0 	movl   $0xf0108626,(%esp)
f0102e2f:	e8 51 d2 ff ff       	call   f0100085 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f0102e34:	c7 04 24 78 8b 10 f0 	movl   $0xf0108b78,(%esp)
f0102e3b:	e8 c7 1c 00 00       	call   f0104b07 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102e40:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102e47:	e8 3b f2 ff ff       	call   f0102087 <page_alloc>
f0102e4c:	89 c6                	mov    %eax,%esi
f0102e4e:	85 c0                	test   %eax,%eax
f0102e50:	75 24                	jne    f0102e76 <mem_init+0x621>
f0102e52:	c7 44 24 0c f9 86 10 	movl   $0xf01086f9,0xc(%esp)
f0102e59:	f0 
f0102e5a:	c7 44 24 08 4c 86 10 	movl   $0xf010864c,0x8(%esp)
f0102e61:	f0 
f0102e62:	c7 44 24 04 38 04 00 	movl   $0x438,0x4(%esp)
f0102e69:	00 
f0102e6a:	c7 04 24 26 86 10 f0 	movl   $0xf0108626,(%esp)
f0102e71:	e8 0f d2 ff ff       	call   f0100085 <_panic>
	assert((pp1 = page_alloc(0)));
f0102e76:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102e7d:	e8 05 f2 ff ff       	call   f0102087 <page_alloc>
f0102e82:	89 c7                	mov    %eax,%edi
f0102e84:	85 c0                	test   %eax,%eax
f0102e86:	75 24                	jne    f0102eac <mem_init+0x657>
f0102e88:	c7 44 24 0c 0f 87 10 	movl   $0xf010870f,0xc(%esp)
f0102e8f:	f0 
f0102e90:	c7 44 24 08 4c 86 10 	movl   $0xf010864c,0x8(%esp)
f0102e97:	f0 
f0102e98:	c7 44 24 04 39 04 00 	movl   $0x439,0x4(%esp)
f0102e9f:	00 
f0102ea0:	c7 04 24 26 86 10 f0 	movl   $0xf0108626,(%esp)
f0102ea7:	e8 d9 d1 ff ff       	call   f0100085 <_panic>
	assert((pp2 = page_alloc(0)));
f0102eac:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102eb3:	e8 cf f1 ff ff       	call   f0102087 <page_alloc>
f0102eb8:	89 c3                	mov    %eax,%ebx
f0102eba:	85 c0                	test   %eax,%eax
f0102ebc:	75 24                	jne    f0102ee2 <mem_init+0x68d>
f0102ebe:	c7 44 24 0c 25 87 10 	movl   $0xf0108725,0xc(%esp)
f0102ec5:	f0 
f0102ec6:	c7 44 24 08 4c 86 10 	movl   $0xf010864c,0x8(%esp)
f0102ecd:	f0 
f0102ece:	c7 44 24 04 3a 04 00 	movl   $0x43a,0x4(%esp)
f0102ed5:	00 
f0102ed6:	c7 04 24 26 86 10 f0 	movl   $0xf0108626,(%esp)
f0102edd:	e8 a3 d1 ff ff       	call   f0100085 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0102ee2:	39 fe                	cmp    %edi,%esi
f0102ee4:	75 24                	jne    f0102f0a <mem_init+0x6b5>
f0102ee6:	c7 44 24 0c ab 87 10 	movl   $0xf01087ab,0xc(%esp)
f0102eed:	f0 
f0102eee:	c7 44 24 08 4c 86 10 	movl   $0xf010864c,0x8(%esp)
f0102ef5:	f0 
f0102ef6:	c7 44 24 04 3d 04 00 	movl   $0x43d,0x4(%esp)
f0102efd:	00 
f0102efe:	c7 04 24 26 86 10 f0 	movl   $0xf0108626,(%esp)
f0102f05:	e8 7b d1 ff ff       	call   f0100085 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0102f0a:	39 c7                	cmp    %eax,%edi
f0102f0c:	74 04                	je     f0102f12 <mem_init+0x6bd>
f0102f0e:	39 c6                	cmp    %eax,%esi
f0102f10:	75 24                	jne    f0102f36 <mem_init+0x6e1>
f0102f12:	c7 44 24 0c 58 8b 10 	movl   $0xf0108b58,0xc(%esp)
f0102f19:	f0 
f0102f1a:	c7 44 24 08 4c 86 10 	movl   $0xf010864c,0x8(%esp)
f0102f21:	f0 
f0102f22:	c7 44 24 04 3e 04 00 	movl   $0x43e,0x4(%esp)
f0102f29:	00 
f0102f2a:	c7 04 24 26 86 10 f0 	movl   $0xf0108626,(%esp)
f0102f31:	e8 4f d1 ff ff       	call   f0100085 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0102f36:	8b 15 50 d2 24 f0    	mov    0xf024d250,%edx
f0102f3c:	89 55 c8             	mov    %edx,-0x38(%ebp)
	page_free_list = 0;
f0102f3f:	c7 05 50 d2 24 f0 00 	movl   $0x0,0xf024d250
f0102f46:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0102f49:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102f50:	e8 32 f1 ff ff       	call   f0102087 <page_alloc>
f0102f55:	85 c0                	test   %eax,%eax
f0102f57:	74 24                	je     f0102f7d <mem_init+0x728>
f0102f59:	c7 44 24 0c 14 88 10 	movl   $0xf0108814,0xc(%esp)
f0102f60:	f0 
f0102f61:	c7 44 24 08 4c 86 10 	movl   $0xf010864c,0x8(%esp)
f0102f68:	f0 
f0102f69:	c7 44 24 04 45 04 00 	movl   $0x445,0x4(%esp)
f0102f70:	00 
f0102f71:	c7 04 24 26 86 10 f0 	movl   $0xf0108626,(%esp)
f0102f78:	e8 08 d1 ff ff       	call   f0100085 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0102f7d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0102f80:	89 44 24 08          	mov    %eax,0x8(%esp)
f0102f84:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102f8b:	00 
f0102f8c:	a1 ac de 24 f0       	mov    0xf024deac,%eax
f0102f91:	89 04 24             	mov    %eax,(%esp)
f0102f94:	e8 36 f3 ff ff       	call   f01022cf <page_lookup>
f0102f99:	85 c0                	test   %eax,%eax
f0102f9b:	74 24                	je     f0102fc1 <mem_init+0x76c>
f0102f9d:	c7 44 24 0c 98 8b 10 	movl   $0xf0108b98,0xc(%esp)
f0102fa4:	f0 
f0102fa5:	c7 44 24 08 4c 86 10 	movl   $0xf010864c,0x8(%esp)
f0102fac:	f0 
f0102fad:	c7 44 24 04 48 04 00 	movl   $0x448,0x4(%esp)
f0102fb4:	00 
f0102fb5:	c7 04 24 26 86 10 f0 	movl   $0xf0108626,(%esp)
f0102fbc:	e8 c4 d0 ff ff       	call   f0100085 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0102fc1:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102fc8:	00 
f0102fc9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102fd0:	00 
f0102fd1:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0102fd5:	a1 ac de 24 f0       	mov    0xf024deac,%eax
f0102fda:	89 04 24             	mov    %eax,(%esp)
f0102fdd:	e8 b9 f3 ff ff       	call   f010239b <page_insert>
f0102fe2:	85 c0                	test   %eax,%eax
f0102fe4:	78 24                	js     f010300a <mem_init+0x7b5>
f0102fe6:	c7 44 24 0c d0 8b 10 	movl   $0xf0108bd0,0xc(%esp)
f0102fed:	f0 
f0102fee:	c7 44 24 08 4c 86 10 	movl   $0xf010864c,0x8(%esp)
f0102ff5:	f0 
f0102ff6:	c7 44 24 04 4b 04 00 	movl   $0x44b,0x4(%esp)
f0102ffd:	00 
f0102ffe:	c7 04 24 26 86 10 f0 	movl   $0xf0108626,(%esp)
f0103005:	e8 7b d0 ff ff       	call   f0100085 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f010300a:	89 34 24             	mov    %esi,(%esp)
f010300d:	e8 9d e6 ff ff       	call   f01016af <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0103012:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0103019:	00 
f010301a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0103021:	00 
f0103022:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103026:	a1 ac de 24 f0       	mov    0xf024deac,%eax
f010302b:	89 04 24             	mov    %eax,(%esp)
f010302e:	e8 68 f3 ff ff       	call   f010239b <page_insert>
f0103033:	85 c0                	test   %eax,%eax
f0103035:	74 24                	je     f010305b <mem_init+0x806>
f0103037:	c7 44 24 0c 00 8c 10 	movl   $0xf0108c00,0xc(%esp)
f010303e:	f0 
f010303f:	c7 44 24 08 4c 86 10 	movl   $0xf010864c,0x8(%esp)
f0103046:	f0 
f0103047:	c7 44 24 04 4f 04 00 	movl   $0x44f,0x4(%esp)
f010304e:	00 
f010304f:	c7 04 24 26 86 10 f0 	movl   $0xf0108626,(%esp)
f0103056:	e8 2a d0 ff ff       	call   f0100085 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010305b:	a1 ac de 24 f0       	mov    0xf024deac,%eax
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0103060:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f0103063:	8b 08                	mov    (%eax),%ecx
f0103065:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f010306b:	89 f2                	mov    %esi,%edx
f010306d:	2b 15 b0 de 24 f0    	sub    0xf024deb0,%edx
f0103073:	c1 fa 03             	sar    $0x3,%edx
f0103076:	c1 e2 0c             	shl    $0xc,%edx
f0103079:	39 d1                	cmp    %edx,%ecx
f010307b:	74 24                	je     f01030a1 <mem_init+0x84c>
f010307d:	c7 44 24 0c 04 8b 10 	movl   $0xf0108b04,0xc(%esp)
f0103084:	f0 
f0103085:	c7 44 24 08 4c 86 10 	movl   $0xf010864c,0x8(%esp)
f010308c:	f0 
f010308d:	c7 44 24 04 50 04 00 	movl   $0x450,0x4(%esp)
f0103094:	00 
f0103095:	c7 04 24 26 86 10 f0 	movl   $0xf0108626,(%esp)
f010309c:	e8 e4 cf ff ff       	call   f0100085 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f01030a1:	ba 00 00 00 00       	mov    $0x0,%edx
f01030a6:	e8 d3 eb ff ff       	call   f0101c7e <check_va2pa>
f01030ab:	89 7d d0             	mov    %edi,-0x30(%ebp)
f01030ae:	89 fa                	mov    %edi,%edx
f01030b0:	2b 15 b0 de 24 f0    	sub    0xf024deb0,%edx
f01030b6:	c1 fa 03             	sar    $0x3,%edx
f01030b9:	c1 e2 0c             	shl    $0xc,%edx
f01030bc:	39 d0                	cmp    %edx,%eax
f01030be:	74 24                	je     f01030e4 <mem_init+0x88f>
f01030c0:	c7 44 24 0c 30 8c 10 	movl   $0xf0108c30,0xc(%esp)
f01030c7:	f0 
f01030c8:	c7 44 24 08 4c 86 10 	movl   $0xf010864c,0x8(%esp)
f01030cf:	f0 
f01030d0:	c7 44 24 04 51 04 00 	movl   $0x451,0x4(%esp)
f01030d7:	00 
f01030d8:	c7 04 24 26 86 10 f0 	movl   $0xf0108626,(%esp)
f01030df:	e8 a1 cf ff ff       	call   f0100085 <_panic>
	assert(pp1->pp_ref == 1);
f01030e4:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f01030e9:	74 24                	je     f010310f <mem_init+0x8ba>
f01030eb:	c7 44 24 0c 3b 87 10 	movl   $0xf010873b,0xc(%esp)
f01030f2:	f0 
f01030f3:	c7 44 24 08 4c 86 10 	movl   $0xf010864c,0x8(%esp)
f01030fa:	f0 
f01030fb:	c7 44 24 04 52 04 00 	movl   $0x452,0x4(%esp)
f0103102:	00 
f0103103:	c7 04 24 26 86 10 f0 	movl   $0xf0108626,(%esp)
f010310a:	e8 76 cf ff ff       	call   f0100085 <_panic>
	assert(pp0->pp_ref == 1);
f010310f:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0103114:	74 24                	je     f010313a <mem_init+0x8e5>
f0103116:	c7 44 24 0c 7f 87 10 	movl   $0xf010877f,0xc(%esp)
f010311d:	f0 
f010311e:	c7 44 24 08 4c 86 10 	movl   $0xf010864c,0x8(%esp)
f0103125:	f0 
f0103126:	c7 44 24 04 53 04 00 	movl   $0x453,0x4(%esp)
f010312d:	00 
f010312e:	c7 04 24 26 86 10 f0 	movl   $0xf0108626,(%esp)
f0103135:	e8 4b cf ff ff       	call   f0100085 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f010313a:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0103141:	00 
f0103142:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103149:	00 
f010314a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010314e:	a1 ac de 24 f0       	mov    0xf024deac,%eax
f0103153:	89 04 24             	mov    %eax,(%esp)
f0103156:	e8 40 f2 ff ff       	call   f010239b <page_insert>
f010315b:	85 c0                	test   %eax,%eax
f010315d:	74 24                	je     f0103183 <mem_init+0x92e>
f010315f:	c7 44 24 0c 60 8c 10 	movl   $0xf0108c60,0xc(%esp)
f0103166:	f0 
f0103167:	c7 44 24 08 4c 86 10 	movl   $0xf010864c,0x8(%esp)
f010316e:	f0 
f010316f:	c7 44 24 04 56 04 00 	movl   $0x456,0x4(%esp)
f0103176:	00 
f0103177:	c7 04 24 26 86 10 f0 	movl   $0xf0108626,(%esp)
f010317e:	e8 02 cf ff ff       	call   f0100085 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0103183:	ba 00 10 00 00       	mov    $0x1000,%edx
f0103188:	a1 ac de 24 f0       	mov    0xf024deac,%eax
f010318d:	e8 ec ea ff ff       	call   f0101c7e <check_va2pa>
f0103192:	89 5d cc             	mov    %ebx,-0x34(%ebp)
f0103195:	89 da                	mov    %ebx,%edx
f0103197:	2b 15 b0 de 24 f0    	sub    0xf024deb0,%edx
f010319d:	c1 fa 03             	sar    $0x3,%edx
f01031a0:	c1 e2 0c             	shl    $0xc,%edx
f01031a3:	39 d0                	cmp    %edx,%eax
f01031a5:	74 24                	je     f01031cb <mem_init+0x976>
f01031a7:	c7 44 24 0c 9c 8c 10 	movl   $0xf0108c9c,0xc(%esp)
f01031ae:	f0 
f01031af:	c7 44 24 08 4c 86 10 	movl   $0xf010864c,0x8(%esp)
f01031b6:	f0 
f01031b7:	c7 44 24 04 57 04 00 	movl   $0x457,0x4(%esp)
f01031be:	00 
f01031bf:	c7 04 24 26 86 10 f0 	movl   $0xf0108626,(%esp)
f01031c6:	e8 ba ce ff ff       	call   f0100085 <_panic>
	assert(pp2->pp_ref == 1);
f01031cb:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01031d0:	74 24                	je     f01031f6 <mem_init+0x9a1>
f01031d2:	c7 44 24 0c 4c 87 10 	movl   $0xf010874c,0xc(%esp)
f01031d9:	f0 
f01031da:	c7 44 24 08 4c 86 10 	movl   $0xf010864c,0x8(%esp)
f01031e1:	f0 
f01031e2:	c7 44 24 04 58 04 00 	movl   $0x458,0x4(%esp)
f01031e9:	00 
f01031ea:	c7 04 24 26 86 10 f0 	movl   $0xf0108626,(%esp)
f01031f1:	e8 8f ce ff ff       	call   f0100085 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f01031f6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01031fd:	e8 85 ee ff ff       	call   f0102087 <page_alloc>
f0103202:	85 c0                	test   %eax,%eax
f0103204:	74 24                	je     f010322a <mem_init+0x9d5>
f0103206:	c7 44 24 0c 14 88 10 	movl   $0xf0108814,0xc(%esp)
f010320d:	f0 
f010320e:	c7 44 24 08 4c 86 10 	movl   $0xf010864c,0x8(%esp)
f0103215:	f0 
f0103216:	c7 44 24 04 5b 04 00 	movl   $0x45b,0x4(%esp)
f010321d:	00 
f010321e:	c7 04 24 26 86 10 f0 	movl   $0xf0108626,(%esp)
f0103225:	e8 5b ce ff ff       	call   f0100085 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f010322a:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0103231:	00 
f0103232:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103239:	00 
f010323a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010323e:	a1 ac de 24 f0       	mov    0xf024deac,%eax
f0103243:	89 04 24             	mov    %eax,(%esp)
f0103246:	e8 50 f1 ff ff       	call   f010239b <page_insert>
f010324b:	85 c0                	test   %eax,%eax
f010324d:	74 24                	je     f0103273 <mem_init+0xa1e>
f010324f:	c7 44 24 0c 60 8c 10 	movl   $0xf0108c60,0xc(%esp)
f0103256:	f0 
f0103257:	c7 44 24 08 4c 86 10 	movl   $0xf010864c,0x8(%esp)
f010325e:	f0 
f010325f:	c7 44 24 04 5e 04 00 	movl   $0x45e,0x4(%esp)
f0103266:	00 
f0103267:	c7 04 24 26 86 10 f0 	movl   $0xf0108626,(%esp)
f010326e:	e8 12 ce ff ff       	call   f0100085 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0103273:	ba 00 10 00 00       	mov    $0x1000,%edx
f0103278:	a1 ac de 24 f0       	mov    0xf024deac,%eax
f010327d:	e8 fc e9 ff ff       	call   f0101c7e <check_va2pa>
f0103282:	8b 55 cc             	mov    -0x34(%ebp),%edx
f0103285:	2b 15 b0 de 24 f0    	sub    0xf024deb0,%edx
f010328b:	c1 fa 03             	sar    $0x3,%edx
f010328e:	c1 e2 0c             	shl    $0xc,%edx
f0103291:	39 d0                	cmp    %edx,%eax
f0103293:	74 24                	je     f01032b9 <mem_init+0xa64>
f0103295:	c7 44 24 0c 9c 8c 10 	movl   $0xf0108c9c,0xc(%esp)
f010329c:	f0 
f010329d:	c7 44 24 08 4c 86 10 	movl   $0xf010864c,0x8(%esp)
f01032a4:	f0 
f01032a5:	c7 44 24 04 5f 04 00 	movl   $0x45f,0x4(%esp)
f01032ac:	00 
f01032ad:	c7 04 24 26 86 10 f0 	movl   $0xf0108626,(%esp)
f01032b4:	e8 cc cd ff ff       	call   f0100085 <_panic>
	assert(pp2->pp_ref == 1);
f01032b9:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01032be:	74 24                	je     f01032e4 <mem_init+0xa8f>
f01032c0:	c7 44 24 0c 4c 87 10 	movl   $0xf010874c,0xc(%esp)
f01032c7:	f0 
f01032c8:	c7 44 24 08 4c 86 10 	movl   $0xf010864c,0x8(%esp)
f01032cf:	f0 
f01032d0:	c7 44 24 04 60 04 00 	movl   $0x460,0x4(%esp)
f01032d7:	00 
f01032d8:	c7 04 24 26 86 10 f0 	movl   $0xf0108626,(%esp)
f01032df:	e8 a1 cd ff ff       	call   f0100085 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f01032e4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01032eb:	e8 97 ed ff ff       	call   f0102087 <page_alloc>
f01032f0:	85 c0                	test   %eax,%eax
f01032f2:	74 24                	je     f0103318 <mem_init+0xac3>
f01032f4:	c7 44 24 0c 14 88 10 	movl   $0xf0108814,0xc(%esp)
f01032fb:	f0 
f01032fc:	c7 44 24 08 4c 86 10 	movl   $0xf010864c,0x8(%esp)
f0103303:	f0 
f0103304:	c7 44 24 04 64 04 00 	movl   $0x464,0x4(%esp)
f010330b:	00 
f010330c:	c7 04 24 26 86 10 f0 	movl   $0xf0108626,(%esp)
f0103313:	e8 6d cd ff ff       	call   f0100085 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0103318:	a1 ac de 24 f0       	mov    0xf024deac,%eax
f010331d:	8b 00                	mov    (%eax),%eax
f010331f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103324:	89 c2                	mov    %eax,%edx
f0103326:	c1 ea 0c             	shr    $0xc,%edx
f0103329:	3b 15 a8 de 24 f0    	cmp    0xf024dea8,%edx
f010332f:	72 20                	jb     f0103351 <mem_init+0xafc>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103331:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103335:	c7 44 24 08 80 7e 10 	movl   $0xf0107e80,0x8(%esp)
f010333c:	f0 
f010333d:	c7 44 24 04 67 04 00 	movl   $0x467,0x4(%esp)
f0103344:	00 
f0103345:	c7 04 24 26 86 10 f0 	movl   $0xf0108626,(%esp)
f010334c:	e8 34 cd ff ff       	call   f0100085 <_panic>
f0103351:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0103356:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0103359:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0103360:	00 
f0103361:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0103368:	00 
f0103369:	a1 ac de 24 f0       	mov    0xf024deac,%eax
f010336e:	89 04 24             	mov    %eax,(%esp)
f0103371:	e8 8f ed ff ff       	call   f0102105 <pgdir_walk>
f0103376:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0103379:	83 c2 04             	add    $0x4,%edx
f010337c:	39 d0                	cmp    %edx,%eax
f010337e:	74 24                	je     f01033a4 <mem_init+0xb4f>
f0103380:	c7 44 24 0c cc 8c 10 	movl   $0xf0108ccc,0xc(%esp)
f0103387:	f0 
f0103388:	c7 44 24 08 4c 86 10 	movl   $0xf010864c,0x8(%esp)
f010338f:	f0 
f0103390:	c7 44 24 04 68 04 00 	movl   $0x468,0x4(%esp)
f0103397:	00 
f0103398:	c7 04 24 26 86 10 f0 	movl   $0xf0108626,(%esp)
f010339f:	e8 e1 cc ff ff       	call   f0100085 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f01033a4:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f01033ab:	00 
f01033ac:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01033b3:	00 
f01033b4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01033b8:	a1 ac de 24 f0       	mov    0xf024deac,%eax
f01033bd:	89 04 24             	mov    %eax,(%esp)
f01033c0:	e8 d6 ef ff ff       	call   f010239b <page_insert>
f01033c5:	85 c0                	test   %eax,%eax
f01033c7:	74 24                	je     f01033ed <mem_init+0xb98>
f01033c9:	c7 44 24 0c 0c 8d 10 	movl   $0xf0108d0c,0xc(%esp)
f01033d0:	f0 
f01033d1:	c7 44 24 08 4c 86 10 	movl   $0xf010864c,0x8(%esp)
f01033d8:	f0 
f01033d9:	c7 44 24 04 6b 04 00 	movl   $0x46b,0x4(%esp)
f01033e0:	00 
f01033e1:	c7 04 24 26 86 10 f0 	movl   $0xf0108626,(%esp)
f01033e8:	e8 98 cc ff ff       	call   f0100085 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01033ed:	ba 00 10 00 00       	mov    $0x1000,%edx
f01033f2:	a1 ac de 24 f0       	mov    0xf024deac,%eax
f01033f7:	e8 82 e8 ff ff       	call   f0101c7e <check_va2pa>
f01033fc:	8b 55 cc             	mov    -0x34(%ebp),%edx
f01033ff:	2b 15 b0 de 24 f0    	sub    0xf024deb0,%edx
f0103405:	c1 fa 03             	sar    $0x3,%edx
f0103408:	c1 e2 0c             	shl    $0xc,%edx
f010340b:	39 d0                	cmp    %edx,%eax
f010340d:	74 24                	je     f0103433 <mem_init+0xbde>
f010340f:	c7 44 24 0c 9c 8c 10 	movl   $0xf0108c9c,0xc(%esp)
f0103416:	f0 
f0103417:	c7 44 24 08 4c 86 10 	movl   $0xf010864c,0x8(%esp)
f010341e:	f0 
f010341f:	c7 44 24 04 6c 04 00 	movl   $0x46c,0x4(%esp)
f0103426:	00 
f0103427:	c7 04 24 26 86 10 f0 	movl   $0xf0108626,(%esp)
f010342e:	e8 52 cc ff ff       	call   f0100085 <_panic>
	assert(pp2->pp_ref == 1);
f0103433:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0103438:	74 24                	je     f010345e <mem_init+0xc09>
f010343a:	c7 44 24 0c 4c 87 10 	movl   $0xf010874c,0xc(%esp)
f0103441:	f0 
f0103442:	c7 44 24 08 4c 86 10 	movl   $0xf010864c,0x8(%esp)
f0103449:	f0 
f010344a:	c7 44 24 04 6d 04 00 	movl   $0x46d,0x4(%esp)
f0103451:	00 
f0103452:	c7 04 24 26 86 10 f0 	movl   $0xf0108626,(%esp)
f0103459:	e8 27 cc ff ff       	call   f0100085 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f010345e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0103465:	00 
f0103466:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f010346d:	00 
f010346e:	a1 ac de 24 f0       	mov    0xf024deac,%eax
f0103473:	89 04 24             	mov    %eax,(%esp)
f0103476:	e8 8a ec ff ff       	call   f0102105 <pgdir_walk>
f010347b:	f6 00 04             	testb  $0x4,(%eax)
f010347e:	75 24                	jne    f01034a4 <mem_init+0xc4f>
f0103480:	c7 44 24 0c 4c 8d 10 	movl   $0xf0108d4c,0xc(%esp)
f0103487:	f0 
f0103488:	c7 44 24 08 4c 86 10 	movl   $0xf010864c,0x8(%esp)
f010348f:	f0 
f0103490:	c7 44 24 04 6e 04 00 	movl   $0x46e,0x4(%esp)
f0103497:	00 
f0103498:	c7 04 24 26 86 10 f0 	movl   $0xf0108626,(%esp)
f010349f:	e8 e1 cb ff ff       	call   f0100085 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f01034a4:	a1 ac de 24 f0       	mov    0xf024deac,%eax
f01034a9:	f6 00 04             	testb  $0x4,(%eax)
f01034ac:	75 24                	jne    f01034d2 <mem_init+0xc7d>
f01034ae:	c7 44 24 0c 66 88 10 	movl   $0xf0108866,0xc(%esp)
f01034b5:	f0 
f01034b6:	c7 44 24 08 4c 86 10 	movl   $0xf010864c,0x8(%esp)
f01034bd:	f0 
f01034be:	c7 44 24 04 6f 04 00 	movl   $0x46f,0x4(%esp)
f01034c5:	00 
f01034c6:	c7 04 24 26 86 10 f0 	movl   $0xf0108626,(%esp)
f01034cd:	e8 b3 cb ff ff       	call   f0100085 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f01034d2:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01034d9:	00 
f01034da:	c7 44 24 08 00 00 40 	movl   $0x400000,0x8(%esp)
f01034e1:	00 
f01034e2:	89 74 24 04          	mov    %esi,0x4(%esp)
f01034e6:	89 04 24             	mov    %eax,(%esp)
f01034e9:	e8 ad ee ff ff       	call   f010239b <page_insert>
f01034ee:	85 c0                	test   %eax,%eax
f01034f0:	78 24                	js     f0103516 <mem_init+0xcc1>
f01034f2:	c7 44 24 0c 80 8d 10 	movl   $0xf0108d80,0xc(%esp)
f01034f9:	f0 
f01034fa:	c7 44 24 08 4c 86 10 	movl   $0xf010864c,0x8(%esp)
f0103501:	f0 
f0103502:	c7 44 24 04 72 04 00 	movl   $0x472,0x4(%esp)
f0103509:	00 
f010350a:	c7 04 24 26 86 10 f0 	movl   $0xf0108626,(%esp)
f0103511:	e8 6f cb ff ff       	call   f0100085 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0103516:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f010351d:	00 
f010351e:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103525:	00 
f0103526:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010352a:	a1 ac de 24 f0       	mov    0xf024deac,%eax
f010352f:	89 04 24             	mov    %eax,(%esp)
f0103532:	e8 64 ee ff ff       	call   f010239b <page_insert>
f0103537:	85 c0                	test   %eax,%eax
f0103539:	74 24                	je     f010355f <mem_init+0xd0a>
f010353b:	c7 44 24 0c b8 8d 10 	movl   $0xf0108db8,0xc(%esp)
f0103542:	f0 
f0103543:	c7 44 24 08 4c 86 10 	movl   $0xf010864c,0x8(%esp)
f010354a:	f0 
f010354b:	c7 44 24 04 75 04 00 	movl   $0x475,0x4(%esp)
f0103552:	00 
f0103553:	c7 04 24 26 86 10 f0 	movl   $0xf0108626,(%esp)
f010355a:	e8 26 cb ff ff       	call   f0100085 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f010355f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0103566:	00 
f0103567:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f010356e:	00 
f010356f:	a1 ac de 24 f0       	mov    0xf024deac,%eax
f0103574:	89 04 24             	mov    %eax,(%esp)
f0103577:	e8 89 eb ff ff       	call   f0102105 <pgdir_walk>
f010357c:	f6 00 04             	testb  $0x4,(%eax)
f010357f:	74 24                	je     f01035a5 <mem_init+0xd50>
f0103581:	c7 44 24 0c f4 8d 10 	movl   $0xf0108df4,0xc(%esp)
f0103588:	f0 
f0103589:	c7 44 24 08 4c 86 10 	movl   $0xf010864c,0x8(%esp)
f0103590:	f0 
f0103591:	c7 44 24 04 76 04 00 	movl   $0x476,0x4(%esp)
f0103598:	00 
f0103599:	c7 04 24 26 86 10 f0 	movl   $0xf0108626,(%esp)
f01035a0:	e8 e0 ca ff ff       	call   f0100085 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f01035a5:	ba 00 00 00 00       	mov    $0x0,%edx
f01035aa:	a1 ac de 24 f0       	mov    0xf024deac,%eax
f01035af:	e8 ca e6 ff ff       	call   f0101c7e <check_va2pa>
f01035b4:	8b 55 d0             	mov    -0x30(%ebp),%edx
f01035b7:	2b 15 b0 de 24 f0    	sub    0xf024deb0,%edx
f01035bd:	c1 fa 03             	sar    $0x3,%edx
f01035c0:	c1 e2 0c             	shl    $0xc,%edx
f01035c3:	39 d0                	cmp    %edx,%eax
f01035c5:	74 24                	je     f01035eb <mem_init+0xd96>
f01035c7:	c7 44 24 0c 2c 8e 10 	movl   $0xf0108e2c,0xc(%esp)
f01035ce:	f0 
f01035cf:	c7 44 24 08 4c 86 10 	movl   $0xf010864c,0x8(%esp)
f01035d6:	f0 
f01035d7:	c7 44 24 04 79 04 00 	movl   $0x479,0x4(%esp)
f01035de:	00 
f01035df:	c7 04 24 26 86 10 f0 	movl   $0xf0108626,(%esp)
f01035e6:	e8 9a ca ff ff       	call   f0100085 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01035eb:	ba 00 10 00 00       	mov    $0x1000,%edx
f01035f0:	a1 ac de 24 f0       	mov    0xf024deac,%eax
f01035f5:	e8 84 e6 ff ff       	call   f0101c7e <check_va2pa>
f01035fa:	8b 55 d0             	mov    -0x30(%ebp),%edx
f01035fd:	2b 15 b0 de 24 f0    	sub    0xf024deb0,%edx
f0103603:	c1 fa 03             	sar    $0x3,%edx
f0103606:	c1 e2 0c             	shl    $0xc,%edx
f0103609:	39 d0                	cmp    %edx,%eax
f010360b:	74 24                	je     f0103631 <mem_init+0xddc>
f010360d:	c7 44 24 0c 58 8e 10 	movl   $0xf0108e58,0xc(%esp)
f0103614:	f0 
f0103615:	c7 44 24 08 4c 86 10 	movl   $0xf010864c,0x8(%esp)
f010361c:	f0 
f010361d:	c7 44 24 04 7a 04 00 	movl   $0x47a,0x4(%esp)
f0103624:	00 
f0103625:	c7 04 24 26 86 10 f0 	movl   $0xf0108626,(%esp)
f010362c:	e8 54 ca ff ff       	call   f0100085 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0103631:	66 83 7f 04 02       	cmpw   $0x2,0x4(%edi)
f0103636:	74 24                	je     f010365c <mem_init+0xe07>
f0103638:	c7 44 24 0c 7c 88 10 	movl   $0xf010887c,0xc(%esp)
f010363f:	f0 
f0103640:	c7 44 24 08 4c 86 10 	movl   $0xf010864c,0x8(%esp)
f0103647:	f0 
f0103648:	c7 44 24 04 7c 04 00 	movl   $0x47c,0x4(%esp)
f010364f:	00 
f0103650:	c7 04 24 26 86 10 f0 	movl   $0xf0108626,(%esp)
f0103657:	e8 29 ca ff ff       	call   f0100085 <_panic>
	assert(pp2->pp_ref == 0);
f010365c:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0103661:	74 24                	je     f0103687 <mem_init+0xe32>
f0103663:	c7 44 24 0c 6e 87 10 	movl   $0xf010876e,0xc(%esp)
f010366a:	f0 
f010366b:	c7 44 24 08 4c 86 10 	movl   $0xf010864c,0x8(%esp)
f0103672:	f0 
f0103673:	c7 44 24 04 7d 04 00 	movl   $0x47d,0x4(%esp)
f010367a:	00 
f010367b:	c7 04 24 26 86 10 f0 	movl   $0xf0108626,(%esp)
f0103682:	e8 fe c9 ff ff       	call   f0100085 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0103687:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010368e:	e8 f4 e9 ff ff       	call   f0102087 <page_alloc>
f0103693:	85 c0                	test   %eax,%eax
f0103695:	74 04                	je     f010369b <mem_init+0xe46>
f0103697:	39 c3                	cmp    %eax,%ebx
f0103699:	74 24                	je     f01036bf <mem_init+0xe6a>
f010369b:	c7 44 24 0c 88 8e 10 	movl   $0xf0108e88,0xc(%esp)
f01036a2:	f0 
f01036a3:	c7 44 24 08 4c 86 10 	movl   $0xf010864c,0x8(%esp)
f01036aa:	f0 
f01036ab:	c7 44 24 04 80 04 00 	movl   $0x480,0x4(%esp)
f01036b2:	00 
f01036b3:	c7 04 24 26 86 10 f0 	movl   $0xf0108626,(%esp)
f01036ba:	e8 c6 c9 ff ff       	call   f0100085 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f01036bf:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01036c6:	00 
f01036c7:	a1 ac de 24 f0       	mov    0xf024deac,%eax
f01036cc:	89 04 24             	mov    %eax,(%esp)
f01036cf:	e8 6c ec ff ff       	call   f0102340 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01036d4:	ba 00 00 00 00       	mov    $0x0,%edx
f01036d9:	a1 ac de 24 f0       	mov    0xf024deac,%eax
f01036de:	e8 9b e5 ff ff       	call   f0101c7e <check_va2pa>
f01036e3:	83 f8 ff             	cmp    $0xffffffff,%eax
f01036e6:	74 24                	je     f010370c <mem_init+0xeb7>
f01036e8:	c7 44 24 0c ac 8e 10 	movl   $0xf0108eac,0xc(%esp)
f01036ef:	f0 
f01036f0:	c7 44 24 08 4c 86 10 	movl   $0xf010864c,0x8(%esp)
f01036f7:	f0 
f01036f8:	c7 44 24 04 84 04 00 	movl   $0x484,0x4(%esp)
f01036ff:	00 
f0103700:	c7 04 24 26 86 10 f0 	movl   $0xf0108626,(%esp)
f0103707:	e8 79 c9 ff ff       	call   f0100085 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f010370c:	ba 00 10 00 00       	mov    $0x1000,%edx
f0103711:	a1 ac de 24 f0       	mov    0xf024deac,%eax
f0103716:	e8 63 e5 ff ff       	call   f0101c7e <check_va2pa>
f010371b:	8b 55 d0             	mov    -0x30(%ebp),%edx
f010371e:	2b 15 b0 de 24 f0    	sub    0xf024deb0,%edx
f0103724:	c1 fa 03             	sar    $0x3,%edx
f0103727:	c1 e2 0c             	shl    $0xc,%edx
f010372a:	39 d0                	cmp    %edx,%eax
f010372c:	74 24                	je     f0103752 <mem_init+0xefd>
f010372e:	c7 44 24 0c 58 8e 10 	movl   $0xf0108e58,0xc(%esp)
f0103735:	f0 
f0103736:	c7 44 24 08 4c 86 10 	movl   $0xf010864c,0x8(%esp)
f010373d:	f0 
f010373e:	c7 44 24 04 85 04 00 	movl   $0x485,0x4(%esp)
f0103745:	00 
f0103746:	c7 04 24 26 86 10 f0 	movl   $0xf0108626,(%esp)
f010374d:	e8 33 c9 ff ff       	call   f0100085 <_panic>
	assert(pp1->pp_ref == 1);
f0103752:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0103757:	74 24                	je     f010377d <mem_init+0xf28>
f0103759:	c7 44 24 0c 3b 87 10 	movl   $0xf010873b,0xc(%esp)
f0103760:	f0 
f0103761:	c7 44 24 08 4c 86 10 	movl   $0xf010864c,0x8(%esp)
f0103768:	f0 
f0103769:	c7 44 24 04 86 04 00 	movl   $0x486,0x4(%esp)
f0103770:	00 
f0103771:	c7 04 24 26 86 10 f0 	movl   $0xf0108626,(%esp)
f0103778:	e8 08 c9 ff ff       	call   f0100085 <_panic>
	assert(pp2->pp_ref == 0);
f010377d:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0103782:	74 24                	je     f01037a8 <mem_init+0xf53>
f0103784:	c7 44 24 0c 6e 87 10 	movl   $0xf010876e,0xc(%esp)
f010378b:	f0 
f010378c:	c7 44 24 08 4c 86 10 	movl   $0xf010864c,0x8(%esp)
f0103793:	f0 
f0103794:	c7 44 24 04 87 04 00 	movl   $0x487,0x4(%esp)
f010379b:	00 
f010379c:	c7 04 24 26 86 10 f0 	movl   $0xf0108626,(%esp)
f01037a3:	e8 dd c8 ff ff       	call   f0100085 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f01037a8:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01037af:	00 
f01037b0:	a1 ac de 24 f0       	mov    0xf024deac,%eax
f01037b5:	89 04 24             	mov    %eax,(%esp)
f01037b8:	e8 83 eb ff ff       	call   f0102340 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01037bd:	ba 00 00 00 00       	mov    $0x0,%edx
f01037c2:	a1 ac de 24 f0       	mov    0xf024deac,%eax
f01037c7:	e8 b2 e4 ff ff       	call   f0101c7e <check_va2pa>
f01037cc:	83 f8 ff             	cmp    $0xffffffff,%eax
f01037cf:	74 24                	je     f01037f5 <mem_init+0xfa0>
f01037d1:	c7 44 24 0c ac 8e 10 	movl   $0xf0108eac,0xc(%esp)
f01037d8:	f0 
f01037d9:	c7 44 24 08 4c 86 10 	movl   $0xf010864c,0x8(%esp)
f01037e0:	f0 
f01037e1:	c7 44 24 04 8b 04 00 	movl   $0x48b,0x4(%esp)
f01037e8:	00 
f01037e9:	c7 04 24 26 86 10 f0 	movl   $0xf0108626,(%esp)
f01037f0:	e8 90 c8 ff ff       	call   f0100085 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f01037f5:	ba 00 10 00 00       	mov    $0x1000,%edx
f01037fa:	a1 ac de 24 f0       	mov    0xf024deac,%eax
f01037ff:	e8 7a e4 ff ff       	call   f0101c7e <check_va2pa>
f0103804:	83 f8 ff             	cmp    $0xffffffff,%eax
f0103807:	74 24                	je     f010382d <mem_init+0xfd8>
f0103809:	c7 44 24 0c d0 8e 10 	movl   $0xf0108ed0,0xc(%esp)
f0103810:	f0 
f0103811:	c7 44 24 08 4c 86 10 	movl   $0xf010864c,0x8(%esp)
f0103818:	f0 
f0103819:	c7 44 24 04 8c 04 00 	movl   $0x48c,0x4(%esp)
f0103820:	00 
f0103821:	c7 04 24 26 86 10 f0 	movl   $0xf0108626,(%esp)
f0103828:	e8 58 c8 ff ff       	call   f0100085 <_panic>
	assert(pp1->pp_ref == 0);
f010382d:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0103832:	74 24                	je     f0103858 <mem_init+0x1003>
f0103834:	c7 44 24 0c 5d 87 10 	movl   $0xf010875d,0xc(%esp)
f010383b:	f0 
f010383c:	c7 44 24 08 4c 86 10 	movl   $0xf010864c,0x8(%esp)
f0103843:	f0 
f0103844:	c7 44 24 04 8d 04 00 	movl   $0x48d,0x4(%esp)
f010384b:	00 
f010384c:	c7 04 24 26 86 10 f0 	movl   $0xf0108626,(%esp)
f0103853:	e8 2d c8 ff ff       	call   f0100085 <_panic>
	assert(pp2->pp_ref == 0);
f0103858:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f010385d:	74 24                	je     f0103883 <mem_init+0x102e>
f010385f:	c7 44 24 0c 6e 87 10 	movl   $0xf010876e,0xc(%esp)
f0103866:	f0 
f0103867:	c7 44 24 08 4c 86 10 	movl   $0xf010864c,0x8(%esp)
f010386e:	f0 
f010386f:	c7 44 24 04 8e 04 00 	movl   $0x48e,0x4(%esp)
f0103876:	00 
f0103877:	c7 04 24 26 86 10 f0 	movl   $0xf0108626,(%esp)
f010387e:	e8 02 c8 ff ff       	call   f0100085 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0103883:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010388a:	e8 f8 e7 ff ff       	call   f0102087 <page_alloc>
f010388f:	85 c0                	test   %eax,%eax
f0103891:	74 04                	je     f0103897 <mem_init+0x1042>
f0103893:	39 c7                	cmp    %eax,%edi
f0103895:	74 24                	je     f01038bb <mem_init+0x1066>
f0103897:	c7 44 24 0c f8 8e 10 	movl   $0xf0108ef8,0xc(%esp)
f010389e:	f0 
f010389f:	c7 44 24 08 4c 86 10 	movl   $0xf010864c,0x8(%esp)
f01038a6:	f0 
f01038a7:	c7 44 24 04 91 04 00 	movl   $0x491,0x4(%esp)
f01038ae:	00 
f01038af:	c7 04 24 26 86 10 f0 	movl   $0xf0108626,(%esp)
f01038b6:	e8 ca c7 ff ff       	call   f0100085 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f01038bb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01038c2:	e8 c0 e7 ff ff       	call   f0102087 <page_alloc>
f01038c7:	85 c0                	test   %eax,%eax
f01038c9:	74 24                	je     f01038ef <mem_init+0x109a>
f01038cb:	c7 44 24 0c 14 88 10 	movl   $0xf0108814,0xc(%esp)
f01038d2:	f0 
f01038d3:	c7 44 24 08 4c 86 10 	movl   $0xf010864c,0x8(%esp)
f01038da:	f0 
f01038db:	c7 44 24 04 94 04 00 	movl   $0x494,0x4(%esp)
f01038e2:	00 
f01038e3:	c7 04 24 26 86 10 f0 	movl   $0xf0108626,(%esp)
f01038ea:	e8 96 c7 ff ff       	call   f0100085 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01038ef:	a1 ac de 24 f0       	mov    0xf024deac,%eax
f01038f4:	8b 08                	mov    (%eax),%ecx
f01038f6:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f01038fc:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01038ff:	2b 15 b0 de 24 f0    	sub    0xf024deb0,%edx
f0103905:	c1 fa 03             	sar    $0x3,%edx
f0103908:	c1 e2 0c             	shl    $0xc,%edx
f010390b:	39 d1                	cmp    %edx,%ecx
f010390d:	74 24                	je     f0103933 <mem_init+0x10de>
f010390f:	c7 44 24 0c 04 8b 10 	movl   $0xf0108b04,0xc(%esp)
f0103916:	f0 
f0103917:	c7 44 24 08 4c 86 10 	movl   $0xf010864c,0x8(%esp)
f010391e:	f0 
f010391f:	c7 44 24 04 97 04 00 	movl   $0x497,0x4(%esp)
f0103926:	00 
f0103927:	c7 04 24 26 86 10 f0 	movl   $0xf0108626,(%esp)
f010392e:	e8 52 c7 ff ff       	call   f0100085 <_panic>
	kern_pgdir[0] = 0;
f0103933:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f0103939:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f010393e:	74 24                	je     f0103964 <mem_init+0x110f>
f0103940:	c7 44 24 0c 7f 87 10 	movl   $0xf010877f,0xc(%esp)
f0103947:	f0 
f0103948:	c7 44 24 08 4c 86 10 	movl   $0xf010864c,0x8(%esp)
f010394f:	f0 
f0103950:	c7 44 24 04 99 04 00 	movl   $0x499,0x4(%esp)
f0103957:	00 
f0103958:	c7 04 24 26 86 10 f0 	movl   $0xf0108626,(%esp)
f010395f:	e8 21 c7 ff ff       	call   f0100085 <_panic>
	pp0->pp_ref = 0;
f0103964:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f010396a:	89 34 24             	mov    %esi,(%esp)
f010396d:	e8 3d dd ff ff       	call   f01016af <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0103972:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0103979:	00 
f010397a:	c7 44 24 04 00 10 40 	movl   $0x401000,0x4(%esp)
f0103981:	00 
f0103982:	a1 ac de 24 f0       	mov    0xf024deac,%eax
f0103987:	89 04 24             	mov    %eax,(%esp)
f010398a:	e8 76 e7 ff ff       	call   f0102105 <pgdir_walk>
f010398f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0103992:	8b 0d ac de 24 f0    	mov    0xf024deac,%ecx
f0103998:	83 c1 04             	add    $0x4,%ecx
f010399b:	8b 11                	mov    (%ecx),%edx
f010399d:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01039a3:	89 55 cc             	mov    %edx,-0x34(%ebp)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01039a6:	c1 ea 0c             	shr    $0xc,%edx
f01039a9:	3b 15 a8 de 24 f0    	cmp    0xf024dea8,%edx
f01039af:	72 23                	jb     f01039d4 <mem_init+0x117f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01039b1:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f01039b4:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f01039b8:	c7 44 24 08 80 7e 10 	movl   $0xf0107e80,0x8(%esp)
f01039bf:	f0 
f01039c0:	c7 44 24 04 a0 04 00 	movl   $0x4a0,0x4(%esp)
f01039c7:	00 
f01039c8:	c7 04 24 26 86 10 f0 	movl   $0xf0108626,(%esp)
f01039cf:	e8 b1 c6 ff ff       	call   f0100085 <_panic>
	assert(ptep == ptep1 + PTX(va));
f01039d4:	8b 55 cc             	mov    -0x34(%ebp),%edx
f01039d7:	81 ea fc ff ff 0f    	sub    $0xffffffc,%edx
f01039dd:	39 d0                	cmp    %edx,%eax
f01039df:	74 24                	je     f0103a05 <mem_init+0x11b0>
f01039e1:	c7 44 24 0c 8d 88 10 	movl   $0xf010888d,0xc(%esp)
f01039e8:	f0 
f01039e9:	c7 44 24 08 4c 86 10 	movl   $0xf010864c,0x8(%esp)
f01039f0:	f0 
f01039f1:	c7 44 24 04 a1 04 00 	movl   $0x4a1,0x4(%esp)
f01039f8:	00 
f01039f9:	c7 04 24 26 86 10 f0 	movl   $0xf0108626,(%esp)
f0103a00:	e8 80 c6 ff ff       	call   f0100085 <_panic>
	kern_pgdir[PDX(va)] = 0;
f0103a05:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	pp0->pp_ref = 0;
f0103a0b:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0103a11:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103a14:	2b 05 b0 de 24 f0    	sub    0xf024deb0,%eax
f0103a1a:	c1 f8 03             	sar    $0x3,%eax
f0103a1d:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103a20:	89 c2                	mov    %eax,%edx
f0103a22:	c1 ea 0c             	shr    $0xc,%edx
f0103a25:	3b 15 a8 de 24 f0    	cmp    0xf024dea8,%edx
f0103a2b:	72 20                	jb     f0103a4d <mem_init+0x11f8>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103a2d:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103a31:	c7 44 24 08 80 7e 10 	movl   $0xf0107e80,0x8(%esp)
f0103a38:	f0 
f0103a39:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0103a40:	00 
f0103a41:	c7 04 24 32 86 10 f0 	movl   $0xf0108632,(%esp)
f0103a48:	e8 38 c6 ff ff       	call   f0100085 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0103a4d:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103a54:	00 
f0103a55:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
f0103a5c:	00 
f0103a5d:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0103a62:	89 04 24             	mov    %eax,(%esp)
f0103a65:	e8 ac 35 00 00       	call   f0107016 <memset>
	page_free(pp0);
f0103a6a:	89 34 24             	mov    %esi,(%esp)
f0103a6d:	e8 3d dc ff ff       	call   f01016af <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0103a72:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0103a79:	00 
f0103a7a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103a81:	00 
f0103a82:	a1 ac de 24 f0       	mov    0xf024deac,%eax
f0103a87:	89 04 24             	mov    %eax,(%esp)
f0103a8a:	e8 76 e6 ff ff       	call   f0102105 <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0103a8f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0103a92:	2b 15 b0 de 24 f0    	sub    0xf024deb0,%edx
f0103a98:	c1 fa 03             	sar    $0x3,%edx
f0103a9b:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103a9e:	89 d0                	mov    %edx,%eax
f0103aa0:	c1 e8 0c             	shr    $0xc,%eax
f0103aa3:	3b 05 a8 de 24 f0    	cmp    0xf024dea8,%eax
f0103aa9:	72 20                	jb     f0103acb <mem_init+0x1276>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103aab:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0103aaf:	c7 44 24 08 80 7e 10 	movl   $0xf0107e80,0x8(%esp)
f0103ab6:	f0 
f0103ab7:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0103abe:	00 
f0103abf:	c7 04 24 32 86 10 f0 	movl   $0xf0108632,(%esp)
f0103ac6:	e8 ba c5 ff ff       	call   f0100085 <_panic>
	ptep = (pte_t *) page2kva(pp0);
f0103acb:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
f0103ad1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0103ad4:	f6 00 01             	testb  $0x1,(%eax)
f0103ad7:	75 11                	jne    f0103aea <mem_init+0x1295>
f0103ad9:	8d 82 04 00 00 f0    	lea    -0xffffffc(%edx),%eax
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0103adf:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0103ae5:	f6 00 01             	testb  $0x1,(%eax)
f0103ae8:	74 24                	je     f0103b0e <mem_init+0x12b9>
f0103aea:	c7 44 24 0c a5 88 10 	movl   $0xf01088a5,0xc(%esp)
f0103af1:	f0 
f0103af2:	c7 44 24 08 4c 86 10 	movl   $0xf010864c,0x8(%esp)
f0103af9:	f0 
f0103afa:	c7 44 24 04 ab 04 00 	movl   $0x4ab,0x4(%esp)
f0103b01:	00 
f0103b02:	c7 04 24 26 86 10 f0 	movl   $0xf0108626,(%esp)
f0103b09:	e8 77 c5 ff ff       	call   f0100085 <_panic>
f0103b0e:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f0103b11:	39 d0                	cmp    %edx,%eax
f0103b13:	75 d0                	jne    f0103ae5 <mem_init+0x1290>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f0103b15:	a1 ac de 24 f0       	mov    0xf024deac,%eax
f0103b1a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0103b20:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// give free list back
	page_free_list = fl;
f0103b26:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0103b29:	a3 50 d2 24 f0       	mov    %eax,0xf024d250

	// free the pages we took
	page_free(pp0);
f0103b2e:	89 34 24             	mov    %esi,(%esp)
f0103b31:	e8 79 db ff ff       	call   f01016af <page_free>
	page_free(pp1);
f0103b36:	89 3c 24             	mov    %edi,(%esp)
f0103b39:	e8 71 db ff ff       	call   f01016af <page_free>
	page_free(pp2);
f0103b3e:	89 1c 24             	mov    %ebx,(%esp)
f0103b41:	e8 69 db ff ff       	call   f01016af <page_free>

	cprintf("check_page() succeeded!\n");
f0103b46:	c7 04 24 bc 88 10 f0 	movl   $0xf01088bc,(%esp)
f0103b4d:	e8 b5 0f 00 00       	call   f0104b07 <cprintf>
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
        boot_map_region(kern_pgdir,UPAGES,PTSIZE,PADDR(pages),PTE_U|PTE_P);
f0103b52:	a1 b0 de 24 f0       	mov    0xf024deb0,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103b57:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103b5c:	77 20                	ja     f0103b7e <mem_init+0x1329>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103b5e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103b62:	c7 44 24 08 5c 7e 10 	movl   $0xf0107e5c,0x8(%esp)
f0103b69:	f0 
f0103b6a:	c7 44 24 04 c7 00 00 	movl   $0xc7,0x4(%esp)
f0103b71:	00 
f0103b72:	c7 04 24 26 86 10 f0 	movl   $0xf0108626,(%esp)
f0103b79:	e8 07 c5 ff ff       	call   f0100085 <_panic>
f0103b7e:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
f0103b85:	00 
f0103b86:	8d 80 00 00 00 10    	lea    0x10000000(%eax),%eax
f0103b8c:	89 04 24             	mov    %eax,(%esp)
f0103b8f:	b9 00 00 40 00       	mov    $0x400000,%ecx
f0103b94:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0103b99:	a1 ac de 24 f0       	mov    0xf024deac,%eax
f0103b9e:	e8 74 e8 ff ff       	call   f0102417 <boot_map_region>
	// (ie. perm = PTE_U | PTE_P).
	// Permissions:
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.
        boot_map_region(kern_pgdir,UENVS,PTSIZE,PADDR(envs),PTE_U|PTE_P);
f0103ba3:	a1 5c d2 24 f0       	mov    0xf024d25c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103ba8:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103bad:	77 20                	ja     f0103bcf <mem_init+0x137a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103baf:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103bb3:	c7 44 24 08 5c 7e 10 	movl   $0xf0107e5c,0x8(%esp)
f0103bba:	f0 
f0103bbb:	c7 44 24 04 cf 00 00 	movl   $0xcf,0x4(%esp)
f0103bc2:	00 
f0103bc3:	c7 04 24 26 86 10 f0 	movl   $0xf0108626,(%esp)
f0103bca:	e8 b6 c4 ff ff       	call   f0100085 <_panic>
f0103bcf:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
f0103bd6:	00 
f0103bd7:	8d 80 00 00 00 10    	lea    0x10000000(%eax),%eax
f0103bdd:	89 04 24             	mov    %eax,(%esp)
f0103be0:	b9 00 00 40 00       	mov    $0x400000,%ecx
f0103be5:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0103bea:	a1 ac de 24 f0       	mov    0xf024deac,%eax
f0103bef:	e8 23 e8 ff ff       	call   f0102417 <boot_map_region>
static void
mem_init_mp(void)
{
	// Create a direct mapping at the top of virtual address space starting
	// at IOMEMBASE for accessing the LAPIC unit using memory-mapped I/O.
	boot_map_region(kern_pgdir, IOMEMBASE, -IOMEMBASE, IOMEM_PADDR, PTE_W);
f0103bf4:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0103bfb:	00 
f0103bfc:	c7 04 24 00 00 00 fe 	movl   $0xfe000000,(%esp)
f0103c03:	b9 00 00 00 02       	mov    $0x2000000,%ecx
f0103c08:	ba 00 00 00 fe       	mov    $0xfe000000,%edx
f0103c0d:	a1 ac de 24 f0       	mov    0xf024deac,%eax
f0103c12:	e8 00 e8 ff ff       	call   f0102417 <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103c17:	c7 45 cc 00 f0 24 f0 	movl   $0xf024f000,-0x34(%ebp)
f0103c1e:	81 7d cc ff ff ff ef 	cmpl   $0xefffffff,-0x34(%ebp)
f0103c25:	0f 87 eb 04 00 00    	ja     f0104116 <mem_init+0x18c1>
f0103c2b:	b8 00 f0 24 f0       	mov    $0xf024f000,%eax
f0103c30:	eb 0a                	jmp    f0103c3c <mem_init+0x13e7>
f0103c32:	89 d8                	mov    %ebx,%eax
f0103c34:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f0103c3a:	77 20                	ja     f0103c5c <mem_init+0x1407>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103c3c:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103c40:	c7 44 24 08 5c 7e 10 	movl   $0xf0107e5c,0x8(%esp)
f0103c47:	f0 
f0103c48:	c7 44 24 04 26 01 00 	movl   $0x126,0x4(%esp)
f0103c4f:	00 
f0103c50:	c7 04 24 26 86 10 f0 	movl   $0xf0108626,(%esp)
f0103c57:	e8 29 c4 ff ff       	call   f0100085 <_panic>
	//
	// LAB 4: Your code here:
        int i;
        for(i = 0;i<NCPU;i++){
          uint32_t kstacktop_i = KSTACKTOP - i*(KSTKSIZE+KSTKGAP);
          boot_map_region(kern_pgdir,kstacktop_i - KSTKSIZE , KSTKSIZE, PADDR(percpu_kstacks[i]),PTE_P | PTE_W);
f0103c5c:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f0103c63:	00 
f0103c64:	8d 83 00 00 00 10    	lea    0x10000000(%ebx),%eax
f0103c6a:	89 04 24             	mov    %eax,(%esp)
f0103c6d:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0103c72:	89 f2                	mov    %esi,%edx
f0103c74:	a1 ac de 24 f0       	mov    0xf024deac,%eax
f0103c79:	e8 99 e7 ff ff       	call   f0102417 <boot_map_region>
f0103c7e:	81 c3 00 80 00 00    	add    $0x8000,%ebx
f0103c84:	81 ee 00 00 01 00    	sub    $0x10000,%esi
	//             Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	//
	// LAB 4: Your code here:
        int i;
        for(i = 0;i<NCPU;i++){
f0103c8a:	81 fe 00 80 b7 ef    	cmp    $0xefb78000,%esi
f0103c90:	75 a0                	jne    f0103c32 <mem_init+0x13dd>
	mem_init_mp();

        //lcr4(rcr4() |CR4_PSE);
        //boot_map_region_large(kern_pgdir,KERNBASE,(uint32_t)(~KERNBASE + 1),PADDR((void*)KERNBASE),PTE_P|PTE_W);
        //boot_map_region_large(kern_pgdir,KERNBASE,(uint32_t)(IOMEMBASE-KERNBASE),PADDR((void*)KERNBASE),PTE_P|PTE_W);
        boot_map_region(kern_pgdir,KERNBASE,(uint32_t)(IOMEMBASE-KERNBASE),PADDR((void*)KERNBASE),PTE_P|PTE_W);
f0103c92:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f0103c99:	00 
f0103c9a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103ca1:	b9 00 00 00 0e       	mov    $0xe000000,%ecx
f0103ca6:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0103cab:	a1 ac de 24 f0       	mov    0xf024deac,%eax
f0103cb0:	e8 62 e7 ff ff       	call   f0102417 <boot_map_region>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f0103cb5:	8b 1d ac de 24 f0    	mov    0xf024deac,%ebx

	// check pages array
	n = ROUNDUP(npages*sizeof(struct Page), PGSIZE);
f0103cbb:	a1 a8 de 24 f0       	mov    0xf024dea8,%eax
f0103cc0:	8d 3c c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%edi
	for (i = 0; i < n; i += PGSIZE)
f0103cc7:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
f0103ccd:	74 79                	je     f0103d48 <mem_init+0x14f3>
f0103ccf:	be 00 00 00 00       	mov    $0x0,%esi
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0103cd4:	8d 96 00 00 00 ef    	lea    -0x11000000(%esi),%edx
f0103cda:	89 d8                	mov    %ebx,%eax
f0103cdc:	e8 9d df ff ff       	call   f0101c7e <check_va2pa>
f0103ce1:	8b 15 b0 de 24 f0    	mov    0xf024deb0,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103ce7:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0103ced:	77 20                	ja     f0103d0f <mem_init+0x14ba>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103cef:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0103cf3:	c7 44 24 08 5c 7e 10 	movl   $0xf0107e5c,0x8(%esp)
f0103cfa:	f0 
f0103cfb:	c7 44 24 04 d8 03 00 	movl   $0x3d8,0x4(%esp)
f0103d02:	00 
f0103d03:	c7 04 24 26 86 10 f0 	movl   $0xf0108626,(%esp)
f0103d0a:	e8 76 c3 ff ff       	call   f0100085 <_panic>
f0103d0f:	8d 94 32 00 00 00 10 	lea    0x10000000(%edx,%esi,1),%edx
f0103d16:	39 d0                	cmp    %edx,%eax
f0103d18:	74 24                	je     f0103d3e <mem_init+0x14e9>
f0103d1a:	c7 44 24 0c 1c 8f 10 	movl   $0xf0108f1c,0xc(%esp)
f0103d21:	f0 
f0103d22:	c7 44 24 08 4c 86 10 	movl   $0xf010864c,0x8(%esp)
f0103d29:	f0 
f0103d2a:	c7 44 24 04 d8 03 00 	movl   $0x3d8,0x4(%esp)
f0103d31:	00 
f0103d32:	c7 04 24 26 86 10 f0 	movl   $0xf0108626,(%esp)
f0103d39:	e8 47 c3 ff ff       	call   f0100085 <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct Page), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0103d3e:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0103d44:	39 f7                	cmp    %esi,%edi
f0103d46:	77 8c                	ja     f0103cd4 <mem_init+0x147f>
f0103d48:	be 00 00 00 00       	mov    $0x0,%esi
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0103d4d:	8d 96 00 00 c0 ee    	lea    -0x11400000(%esi),%edx
f0103d53:	89 d8                	mov    %ebx,%eax
f0103d55:	e8 24 df ff ff       	call   f0101c7e <check_va2pa>
f0103d5a:	8b 15 5c d2 24 f0    	mov    0xf024d25c,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103d60:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0103d66:	77 20                	ja     f0103d88 <mem_init+0x1533>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103d68:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0103d6c:	c7 44 24 08 5c 7e 10 	movl   $0xf0107e5c,0x8(%esp)
f0103d73:	f0 
f0103d74:	c7 44 24 04 dd 03 00 	movl   $0x3dd,0x4(%esp)
f0103d7b:	00 
f0103d7c:	c7 04 24 26 86 10 f0 	movl   $0xf0108626,(%esp)
f0103d83:	e8 fd c2 ff ff       	call   f0100085 <_panic>
f0103d88:	8d 94 32 00 00 00 10 	lea    0x10000000(%edx,%esi,1),%edx
f0103d8f:	39 d0                	cmp    %edx,%eax
f0103d91:	74 24                	je     f0103db7 <mem_init+0x1562>
f0103d93:	c7 44 24 0c 50 8f 10 	movl   $0xf0108f50,0xc(%esp)
f0103d9a:	f0 
f0103d9b:	c7 44 24 08 4c 86 10 	movl   $0xf010864c,0x8(%esp)
f0103da2:	f0 
f0103da3:	c7 44 24 04 dd 03 00 	movl   $0x3dd,0x4(%esp)
f0103daa:	00 
f0103dab:	c7 04 24 26 86 10 f0 	movl   $0xf0108626,(%esp)
f0103db2:	e8 ce c2 ff ff       	call   f0100085 <_panic>
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0103db7:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0103dbd:	81 fe 00 10 02 00    	cmp    $0x21000,%esi
f0103dc3:	75 88                	jne    f0103d4d <mem_init+0x14f8>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	if (check_va2pa_large(pgdir, KERNBASE) == 0) {
f0103dc5:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0103dca:	89 d8                	mov    %ebx,%eax
f0103dcc:	e8 27 d9 ff ff       	call   f01016f8 <check_va2pa_large>
f0103dd1:	85 c0                	test   %eax,%eax
f0103dd3:	74 13                	je     f0103de8 <mem_init+0x1593>
		for (i = 0; i < npages * PGSIZE; i += PTSIZE)
			assert(check_va2pa_large(pgdir, KERNBASE + i) == i);

		cprintf("large page installed!\n");
	} else {
	    for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0103dd5:	a1 a8 de 24 f0       	mov    0xf024dea8,%eax
f0103dda:	c1 e0 0c             	shl    $0xc,%eax
	// check phys mem
	if (check_va2pa_large(pgdir, KERNBASE) == 0) {
		for (i = 0; i < npages * PGSIZE; i += PTSIZE)
			assert(check_va2pa_large(pgdir, KERNBASE + i) == i);

		cprintf("large page installed!\n");
f0103ddd:	be 00 00 00 00       	mov    $0x0,%esi
	} else {
	    for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0103de2:	85 c0                	test   %eax,%eax
f0103de4:	75 6c                	jne    f0103e52 <mem_init+0x15fd>
f0103de6:	eb 63                	jmp    f0103e4b <mem_init+0x15f6>
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	if (check_va2pa_large(pgdir, KERNBASE) == 0) {
		for (i = 0; i < npages * PGSIZE; i += PTSIZE)
f0103de8:	8b 3d a8 de 24 f0    	mov    0xf024dea8,%edi
f0103dee:	c1 e7 0c             	shl    $0xc,%edi
			assert(check_va2pa_large(pgdir, KERNBASE + i) == i);
f0103df1:	b8 00 00 00 00       	mov    $0x0,%eax
f0103df6:	89 de                	mov    %ebx,%esi
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	if (check_va2pa_large(pgdir, KERNBASE) == 0) {
		for (i = 0; i < npages * PGSIZE; i += PTSIZE)
f0103df8:	85 ff                	test   %edi,%edi
f0103dfa:	75 37                	jne    f0103e33 <mem_init+0x15de>
f0103dfc:	eb 41                	jmp    f0103e3f <mem_init+0x15ea>
f0103dfe:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
			assert(check_va2pa_large(pgdir, KERNBASE + i) == i);
f0103e04:	89 f0                	mov    %esi,%eax
f0103e06:	e8 ed d8 ff ff       	call   f01016f8 <check_va2pa_large>
f0103e0b:	39 d8                	cmp    %ebx,%eax
f0103e0d:	74 24                	je     f0103e33 <mem_init+0x15de>
f0103e0f:	c7 44 24 0c 84 8f 10 	movl   $0xf0108f84,0xc(%esp)
f0103e16:	f0 
f0103e17:	c7 44 24 08 4c 86 10 	movl   $0xf010864c,0x8(%esp)
f0103e1e:	f0 
f0103e1f:	c7 44 24 04 e2 03 00 	movl   $0x3e2,0x4(%esp)
f0103e26:	00 
f0103e27:	c7 04 24 26 86 10 f0 	movl   $0xf0108626,(%esp)
f0103e2e:	e8 52 c2 ff ff       	call   f0100085 <_panic>
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	if (check_va2pa_large(pgdir, KERNBASE) == 0) {
		for (i = 0; i < npages * PGSIZE; i += PTSIZE)
f0103e33:	8d 98 00 00 40 00    	lea    0x400000(%eax),%ebx
f0103e39:	39 df                	cmp    %ebx,%edi
f0103e3b:	77 c1                	ja     f0103dfe <mem_init+0x15a9>
f0103e3d:	89 f3                	mov    %esi,%ebx
			assert(check_va2pa_large(pgdir, KERNBASE + i) == i);

		cprintf("large page installed!\n");
f0103e3f:	c7 04 24 d5 88 10 f0 	movl   $0xf01088d5,(%esp)
f0103e46:	e8 bc 0c 00 00       	call   f0104b07 <cprintf>
f0103e4b:	be 00 00 00 fe       	mov    $0xfe000000,%esi
f0103e50:	eb 49                	jmp    f0103e9b <mem_init+0x1646>
	} else {
	    for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		    assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0103e52:	8d 96 00 00 00 f0    	lea    -0x10000000(%esi),%edx
f0103e58:	89 d8                	mov    %ebx,%eax
f0103e5a:	e8 1f de ff ff       	call   f0101c7e <check_va2pa>
f0103e5f:	39 c6                	cmp    %eax,%esi
f0103e61:	74 24                	je     f0103e87 <mem_init+0x1632>
f0103e63:	c7 44 24 0c b0 8f 10 	movl   $0xf0108fb0,0xc(%esp)
f0103e6a:	f0 
f0103e6b:	c7 44 24 08 4c 86 10 	movl   $0xf010864c,0x8(%esp)
f0103e72:	f0 
f0103e73:	c7 44 24 04 e7 03 00 	movl   $0x3e7,0x4(%esp)
f0103e7a:	00 
f0103e7b:	c7 04 24 26 86 10 f0 	movl   $0xf0108626,(%esp)
f0103e82:	e8 fe c1 ff ff       	call   f0100085 <_panic>
		for (i = 0; i < npages * PGSIZE; i += PTSIZE)
			assert(check_va2pa_large(pgdir, KERNBASE + i) == i);

		cprintf("large page installed!\n");
	} else {
	    for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0103e87:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0103e8d:	a1 a8 de 24 f0       	mov    0xf024dea8,%eax
f0103e92:	c1 e0 0c             	shl    $0xc,%eax
f0103e95:	39 c6                	cmp    %eax,%esi
f0103e97:	72 b9                	jb     f0103e52 <mem_init+0x15fd>
f0103e99:	eb b0                	jmp    f0103e4b <mem_init+0x15f6>
	}

	
	// check IO mem (new in lab 4)
	for (i = IOMEMBASE; i < -PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, i) == i);
f0103e9b:	89 f2                	mov    %esi,%edx
f0103e9d:	89 d8                	mov    %ebx,%eax
f0103e9f:	e8 da dd ff ff       	call   f0101c7e <check_va2pa>
f0103ea4:	39 c6                	cmp    %eax,%esi
f0103ea6:	74 24                	je     f0103ecc <mem_init+0x1677>
f0103ea8:	c7 44 24 0c ec 88 10 	movl   $0xf01088ec,0xc(%esp)
f0103eaf:	f0 
f0103eb0:	c7 44 24 08 4c 86 10 	movl   $0xf010864c,0x8(%esp)
f0103eb7:	f0 
f0103eb8:	c7 44 24 04 ed 03 00 	movl   $0x3ed,0x4(%esp)
f0103ebf:	00 
f0103ec0:	c7 04 24 26 86 10 f0 	movl   $0xf0108626,(%esp)
f0103ec7:	e8 b9 c1 ff ff       	call   f0100085 <_panic>
		    assert(check_va2pa(pgdir, KERNBASE + i) == i);
	}

	
	// check IO mem (new in lab 4)
	for (i = IOMEMBASE; i < -PGSIZE; i += PGSIZE)
f0103ecc:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0103ed2:	81 fe 00 f0 ff ff    	cmp    $0xfffff000,%esi
f0103ed8:	75 c1                	jne    f0103e9b <mem_init+0x1646>
f0103eda:	c7 45 d0 00 00 bf ef 	movl   $0xefbf0000,-0x30(%ebp)
		assert(check_va2pa(pgdir, i) == i);
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0103ee1:	89 df                	mov    %ebx,%edi
		    assert(check_va2pa(pgdir, KERNBASE + i) == i);
	}

	
	// check IO mem (new in lab 4)
	for (i = IOMEMBASE; i < -PGSIZE; i += PGSIZE)
f0103ee3:	8b 55 cc             	mov    -0x34(%ebp),%edx
f0103ee6:	89 55 c8             	mov    %edx,-0x38(%ebp)
f0103ee9:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0103eec:	81 c3 00 80 00 00    	add    $0x8000,%ebx
f0103ef2:	89 d6                	mov    %edx,%esi
f0103ef4:	81 c6 00 00 00 10    	add    $0x10000000,%esi
f0103efa:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0103efd:	81 c1 00 00 01 00    	add    $0x10000,%ecx
f0103f03:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0103f06:	89 da                	mov    %ebx,%edx
f0103f08:	89 f8                	mov    %edi,%eax
f0103f0a:	e8 6f dd ff ff       	call   f0101c7e <check_va2pa>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103f0f:	81 7d cc ff ff ff ef 	cmpl   $0xefffffff,-0x34(%ebp)
f0103f16:	77 23                	ja     f0103f3b <mem_init+0x16e6>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103f18:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0103f1b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103f1f:	c7 44 24 08 5c 7e 10 	movl   $0xf0107e5c,0x8(%esp)
f0103f26:	f0 
f0103f27:	c7 44 24 04 f4 03 00 	movl   $0x3f4,0x4(%esp)
f0103f2e:	00 
f0103f2f:	c7 04 24 26 86 10 f0 	movl   $0xf0108626,(%esp)
f0103f36:	e8 4a c1 ff ff       	call   f0100085 <_panic>
f0103f3b:	39 f0                	cmp    %esi,%eax
f0103f3d:	74 24                	je     f0103f63 <mem_init+0x170e>
f0103f3f:	c7 44 24 0c d8 8f 10 	movl   $0xf0108fd8,0xc(%esp)
f0103f46:	f0 
f0103f47:	c7 44 24 08 4c 86 10 	movl   $0xf010864c,0x8(%esp)
f0103f4e:	f0 
f0103f4f:	c7 44 24 04 f4 03 00 	movl   $0x3f4,0x4(%esp)
f0103f56:	00 
f0103f57:	c7 04 24 26 86 10 f0 	movl   $0xf0108626,(%esp)
f0103f5e:	e8 22 c1 ff ff       	call   f0100085 <_panic>
f0103f63:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0103f69:	8d b0 00 10 00 00    	lea    0x1000(%eax),%esi
		assert(check_va2pa(pgdir, i) == i);
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0103f6f:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0103f72:	0f 85 d4 01 00 00    	jne    f010414c <mem_init+0x18f7>
f0103f78:	bb 00 00 00 00       	mov    $0x0,%ebx
f0103f7d:	8b 75 d0             	mov    -0x30(%ebp),%esi
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
f0103f80:	8d 14 1e             	lea    (%esi,%ebx,1),%edx
f0103f83:	89 f8                	mov    %edi,%eax
f0103f85:	e8 f4 dc ff ff       	call   f0101c7e <check_va2pa>
f0103f8a:	83 f8 ff             	cmp    $0xffffffff,%eax
f0103f8d:	74 24                	je     f0103fb3 <mem_init+0x175e>
f0103f8f:	c7 44 24 0c 20 90 10 	movl   $0xf0109020,0xc(%esp)
f0103f96:	f0 
f0103f97:	c7 44 24 08 4c 86 10 	movl   $0xf010864c,0x8(%esp)
f0103f9e:	f0 
f0103f9f:	c7 44 24 04 f6 03 00 	movl   $0x3f6,0x4(%esp)
f0103fa6:	00 
f0103fa7:	c7 04 24 26 86 10 f0 	movl   $0xf0108626,(%esp)
f0103fae:	e8 d2 c0 ff ff       	call   f0100085 <_panic>
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
f0103fb3:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0103fb9:	81 fb 00 80 00 00    	cmp    $0x8000,%ebx
f0103fbf:	75 bf                	jne    f0103f80 <mem_init+0x172b>
f0103fc1:	81 6d d0 00 00 01 00 	subl   $0x10000,-0x30(%ebp)
f0103fc8:	81 45 cc 00 80 00 00 	addl   $0x8000,-0x34(%ebp)
	// check IO mem (new in lab 4)
	for (i = IOMEMBASE; i < -PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, i) == i);
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
f0103fcf:	81 7d d0 00 00 b7 ef 	cmpl   $0xefb70000,-0x30(%ebp)
f0103fd6:	0f 85 07 ff ff ff    	jne    f0103ee3 <mem_init+0x168e>
f0103fdc:	89 fb                	mov    %edi,%ebx
f0103fde:	b8 00 00 00 00       	mov    $0x0,%eax
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
	}
	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f0103fe3:	8d 90 45 fc ff ff    	lea    -0x3bb(%eax),%edx
f0103fe9:	83 fa 03             	cmp    $0x3,%edx
f0103fec:	77 2e                	ja     f010401c <mem_init+0x17c7>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
			assert(pgdir[i] & PTE_P);
f0103fee:	f6 04 83 01          	testb  $0x1,(%ebx,%eax,4)
f0103ff2:	0f 85 aa 00 00 00    	jne    f01040a2 <mem_init+0x184d>
f0103ff8:	c7 44 24 0c 07 89 10 	movl   $0xf0108907,0xc(%esp)
f0103fff:	f0 
f0104000:	c7 44 24 08 4c 86 10 	movl   $0xf010864c,0x8(%esp)
f0104007:	f0 
f0104008:	c7 44 24 04 ff 03 00 	movl   $0x3ff,0x4(%esp)
f010400f:	00 
f0104010:	c7 04 24 26 86 10 f0 	movl   $0xf0108626,(%esp)
f0104017:	e8 69 c0 ff ff       	call   f0100085 <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f010401c:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0104021:	76 55                	jbe    f0104078 <mem_init+0x1823>
				assert(pgdir[i] & PTE_P);
f0104023:	8b 14 83             	mov    (%ebx,%eax,4),%edx
f0104026:	f6 c2 01             	test   $0x1,%dl
f0104029:	75 24                	jne    f010404f <mem_init+0x17fa>
f010402b:	c7 44 24 0c 07 89 10 	movl   $0xf0108907,0xc(%esp)
f0104032:	f0 
f0104033:	c7 44 24 08 4c 86 10 	movl   $0xf010864c,0x8(%esp)
f010403a:	f0 
f010403b:	c7 44 24 04 03 04 00 	movl   $0x403,0x4(%esp)
f0104042:	00 
f0104043:	c7 04 24 26 86 10 f0 	movl   $0xf0108626,(%esp)
f010404a:	e8 36 c0 ff ff       	call   f0100085 <_panic>
				assert(pgdir[i] & PTE_W);
f010404f:	f6 c2 02             	test   $0x2,%dl
f0104052:	75 4e                	jne    f01040a2 <mem_init+0x184d>
f0104054:	c7 44 24 0c 18 89 10 	movl   $0xf0108918,0xc(%esp)
f010405b:	f0 
f010405c:	c7 44 24 08 4c 86 10 	movl   $0xf010864c,0x8(%esp)
f0104063:	f0 
f0104064:	c7 44 24 04 04 04 00 	movl   $0x404,0x4(%esp)
f010406b:	00 
f010406c:	c7 04 24 26 86 10 f0 	movl   $0xf0108626,(%esp)
f0104073:	e8 0d c0 ff ff       	call   f0100085 <_panic>
			} else
				assert(pgdir[i] == 0);
f0104078:	83 3c 83 00          	cmpl   $0x0,(%ebx,%eax,4)
f010407c:	74 24                	je     f01040a2 <mem_init+0x184d>
f010407e:	c7 44 24 0c 29 89 10 	movl   $0xf0108929,0xc(%esp)
f0104085:	f0 
f0104086:	c7 44 24 08 4c 86 10 	movl   $0xf010864c,0x8(%esp)
f010408d:	f0 
f010408e:	c7 44 24 04 06 04 00 	movl   $0x406,0x4(%esp)
f0104095:	00 
f0104096:	c7 04 24 26 86 10 f0 	movl   $0xf0108626,(%esp)
f010409d:	e8 e3 bf ff ff       	call   f0100085 <_panic>
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
	}
	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f01040a2:	83 c0 01             	add    $0x1,%eax
f01040a5:	3d 00 04 00 00       	cmp    $0x400,%eax
f01040aa:	0f 85 33 ff ff ff    	jne    f0103fe3 <mem_init+0x178e>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f01040b0:	c7 04 24 44 90 10 f0 	movl   $0xf0109044,(%esp)
f01040b7:	e8 4b 0a 00 00       	call   f0104b07 <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f01040bc:	a1 ac de 24 f0       	mov    0xf024deac,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01040c1:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01040c6:	77 20                	ja     f01040e8 <mem_init+0x1893>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01040c8:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01040cc:	c7 44 24 08 5c 7e 10 	movl   $0xf0107e5c,0x8(%esp)
f01040d3:	f0 
f01040d4:	c7 44 24 04 f8 00 00 	movl   $0xf8,0x4(%esp)
f01040db:	00 
f01040dc:	c7 04 24 26 86 10 f0 	movl   $0xf0108626,(%esp)
f01040e3:	e8 9d bf ff ff       	call   f0100085 <_panic>
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f01040e8:	8d 80 00 00 00 10    	lea    0x10000000(%eax),%eax
f01040ee:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f01040f1:	b8 00 00 00 00       	mov    $0x0,%eax
f01040f6:	e8 e9 db ff ff       	call   f0101ce4 <check_page_free_list>

static __inline uint32_t
rcr0(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f01040fb:	0f 20 c0             	mov    %cr0,%eax

	// entry.S set the really important flags in cr0 (including enabling
	// paging).  Here we configure the rest of the flags that we care about.
	cr0 = rcr0();
	cr0 |= CR0_PE|CR0_PG|CR0_AM|CR0_WP|CR0_NE|CR0_MP;
f01040fe:	0d 23 00 05 80       	or     $0x80050023,%eax
}

static __inline void
lcr0(uint32_t val)
{
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f0104103:	83 e0 f3             	and    $0xfffffff3,%eax
f0104106:	0f 22 c0             	mov    %eax,%cr0
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
f0104109:	e8 72 e3 ff ff       	call   f0102480 <check_page_installed_pgdir>
}
f010410e:	83 c4 3c             	add    $0x3c,%esp
f0104111:	5b                   	pop    %ebx
f0104112:	5e                   	pop    %esi
f0104113:	5f                   	pop    %edi
f0104114:	5d                   	pop    %ebp
f0104115:	c3                   	ret    
	//
	// LAB 4: Your code here:
        int i;
        for(i = 0;i<NCPU;i++){
          uint32_t kstacktop_i = KSTACKTOP - i*(KSTKSIZE+KSTKGAP);
          boot_map_region(kern_pgdir,kstacktop_i - KSTKSIZE , KSTKSIZE, PADDR(percpu_kstacks[i]),PTE_P | PTE_W);
f0104116:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f010411d:	00 
f010411e:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0104121:	05 00 00 00 10       	add    $0x10000000,%eax
f0104126:	89 04 24             	mov    %eax,(%esp)
f0104129:	b9 00 80 00 00       	mov    $0x8000,%ecx
f010412e:	ba 00 80 bf ef       	mov    $0xefbf8000,%edx
f0104133:	a1 ac de 24 f0       	mov    0xf024deac,%eax
f0104138:	e8 da e2 ff ff       	call   f0102417 <boot_map_region>
f010413d:	bb 00 70 25 f0       	mov    $0xf0257000,%ebx
f0104142:	be 00 80 be ef       	mov    $0xefbe8000,%esi
f0104147:	e9 e6 fa ff ff       	jmp    f0103c32 <mem_init+0x13dd>
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f010414c:	89 da                	mov    %ebx,%edx
f010414e:	89 f8                	mov    %edi,%eax
f0104150:	e8 29 db ff ff       	call   f0101c7e <check_va2pa>
f0104155:	e9 e1 fd ff ff       	jmp    f0103f3b <mem_init+0x16e6>
f010415a:	00 00                	add    %al,(%eax)
f010415c:	00 00                	add    %al,(%eax)
	...

f0104160 <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f0104160:	55                   	push   %ebp
f0104161:	89 e5                	mov    %esp,%ebp
}

static __inline void
lgdt(void *p)
{
	__asm __volatile("lgdt (%0)" : : "r" (p));
f0104163:	b8 68 43 12 f0       	mov    $0xf0124368,%eax
f0104168:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" :: "a" (GD_UD|3));
f010416b:	b8 23 00 00 00       	mov    $0x23,%eax
f0104170:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" :: "a" (GD_UD|3));
f0104172:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" :: "a" (GD_KD));
f0104174:	b0 10                	mov    $0x10,%al
f0104176:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" :: "a" (GD_KD));
f0104178:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" :: "a" (GD_KD));
f010417a:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" :: "i" (GD_KT));
f010417c:	ea 83 41 10 f0 08 00 	ljmp   $0x8,$0xf0104183
}

static __inline void
lldt(uint16_t sel)
{
	__asm __volatile("lldt %0" : : "r" (sel));
f0104183:	b0 00                	mov    $0x0,%al
f0104185:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f0104188:	5d                   	pop    %ebp
f0104189:	c3                   	ret    

f010418a <env_init>:
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f010418a:	55                   	push   %ebp
f010418b:	89 e5                	mov    %esp,%ebp
f010418d:	8b 15 60 d2 24 f0    	mov    0xf024d260,%edx
f0104193:	b8 7c 0f 02 00       	mov    $0x20f7c,%eax
	// Set up envs array
	// LAB 3: Your code here.
        int i = NENV -1;
        for(i = NENV -1; i >= 0;i--){
           envs[i].env_id = 0;
f0104198:	8b 0d 5c d2 24 f0    	mov    0xf024d25c,%ecx
f010419e:	c7 44 01 48 00 00 00 	movl   $0x0,0x48(%ecx,%eax,1)
f01041a5:	00 
           envs[i].env_link = env_free_list;
f01041a6:	8b 0d 5c d2 24 f0    	mov    0xf024d25c,%ecx
f01041ac:	89 54 01 44          	mov    %edx,0x44(%ecx,%eax,1)
           env_free_list = &envs[i];
f01041b0:	89 c2                	mov    %eax,%edx
f01041b2:	03 15 5c d2 24 f0    	add    0xf024d25c,%edx
           envs[i].env_break = 0;
f01041b8:	c7 42 60 00 00 00 00 	movl   $0x0,0x60(%edx)
f01041bf:	2d 84 00 00 00       	sub    $0x84,%eax
env_init(void)
{
	// Set up envs array
	// LAB 3: Your code here.
        int i = NENV -1;
        for(i = NENV -1; i >= 0;i--){
f01041c4:	3d 7c ff ff ff       	cmp    $0xffffff7c,%eax
f01041c9:	75 cd                	jne    f0104198 <env_init+0xe>
f01041cb:	89 15 60 d2 24 f0    	mov    %edx,0xf024d260
           envs[i].env_link = env_free_list;
           env_free_list = &envs[i];
           envs[i].env_break = 0;
        }      
	// Per-CPU part of the initialization
	env_init_percpu();
f01041d1:	e8 8a ff ff ff       	call   f0104160 <env_init_percpu>
}
f01041d6:	5d                   	pop    %ebp
f01041d7:	c3                   	ret    

f01041d8 <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f01041d8:	55                   	push   %ebp
f01041d9:	89 e5                	mov    %esp,%ebp
f01041db:	83 ec 18             	sub    $0x18,%esp
f01041de:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f01041e1:	89 75 f8             	mov    %esi,-0x8(%ebp)
f01041e4:	89 7d fc             	mov    %edi,-0x4(%ebp)
f01041e7:	8b 45 08             	mov    0x8(%ebp),%eax
f01041ea:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f01041ed:	85 c0                	test   %eax,%eax
f01041ef:	75 17                	jne    f0104208 <envid2env+0x30>
		*env_store = curenv;
f01041f1:	e8 c8 34 00 00       	call   f01076be <cpunum>
f01041f6:	6b c0 74             	imul   $0x74,%eax,%eax
f01041f9:	8b 80 28 e0 24 f0    	mov    -0xfdb1fd8(%eax),%eax
f01041ff:	89 06                	mov    %eax,(%esi)
f0104201:	b8 00 00 00 00       	mov    $0x0,%eax
		return 0;
f0104206:	eb 72                	jmp    f010427a <envid2env+0xa2>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f0104208:	89 c2                	mov    %eax,%edx
f010420a:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0104210:	89 d1                	mov    %edx,%ecx
f0104212:	c1 e1 07             	shl    $0x7,%ecx
f0104215:	8d 1c 91             	lea    (%ecx,%edx,4),%ebx
f0104218:	03 1d 5c d2 24 f0    	add    0xf024d25c,%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f010421e:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f0104222:	74 05                	je     f0104229 <envid2env+0x51>
f0104224:	39 43 48             	cmp    %eax,0x48(%ebx)
f0104227:	74 0d                	je     f0104236 <envid2env+0x5e>
		*env_store = 0;
f0104229:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
f010422f:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
		return -E_BAD_ENV;
f0104234:	eb 44                	jmp    f010427a <envid2env+0xa2>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0104236:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f010423a:	74 37                	je     f0104273 <envid2env+0x9b>
f010423c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0104240:	e8 79 34 00 00       	call   f01076be <cpunum>
f0104245:	6b c0 74             	imul   $0x74,%eax,%eax
f0104248:	39 98 28 e0 24 f0    	cmp    %ebx,-0xfdb1fd8(%eax)
f010424e:	74 23                	je     f0104273 <envid2env+0x9b>
f0104250:	8b 7b 4c             	mov    0x4c(%ebx),%edi
f0104253:	e8 66 34 00 00       	call   f01076be <cpunum>
f0104258:	6b c0 74             	imul   $0x74,%eax,%eax
f010425b:	8b 80 28 e0 24 f0    	mov    -0xfdb1fd8(%eax),%eax
f0104261:	3b 78 48             	cmp    0x48(%eax),%edi
f0104264:	74 0d                	je     f0104273 <envid2env+0x9b>
		*env_store = 0;
f0104266:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
f010426c:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
		return -E_BAD_ENV;
f0104271:	eb 07                	jmp    f010427a <envid2env+0xa2>
	}

	*env_store = e;
f0104273:	89 1e                	mov    %ebx,(%esi)
f0104275:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
f010427a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f010427d:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0104280:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0104283:	89 ec                	mov    %ebp,%esp
f0104285:	5d                   	pop    %ebp
f0104286:	c3                   	ret    

f0104287 <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0104287:	55                   	push   %ebp
f0104288:	89 e5                	mov    %esp,%ebp
f010428a:	53                   	push   %ebx
f010428b:	83 ec 14             	sub    $0x14,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f010428e:	e8 2b 34 00 00       	call   f01076be <cpunum>
f0104293:	6b c0 74             	imul   $0x74,%eax,%eax
f0104296:	8b 98 28 e0 24 f0    	mov    -0xfdb1fd8(%eax),%ebx
f010429c:	e8 1d 34 00 00       	call   f01076be <cpunum>
f01042a1:	89 43 5c             	mov    %eax,0x5c(%ebx)

	__asm __volatile("movl %0,%%esp\n"
f01042a4:	8b 65 08             	mov    0x8(%ebp),%esp
f01042a7:	61                   	popa   
f01042a8:	07                   	pop    %es
f01042a9:	1f                   	pop    %ds
f01042aa:	83 c4 08             	add    $0x8,%esp
f01042ad:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f01042ae:	c7 44 24 08 63 90 10 	movl   $0xf0109063,0x8(%esp)
f01042b5:	f0 
f01042b6:	c7 44 24 04 f4 01 00 	movl   $0x1f4,0x4(%esp)
f01042bd:	00 
f01042be:	c7 04 24 6f 90 10 f0 	movl   $0xf010906f,(%esp)
f01042c5:	e8 bb bd ff ff       	call   f0100085 <_panic>

f01042ca <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f01042ca:	55                   	push   %ebp
f01042cb:	89 e5                	mov    %esp,%ebp
f01042cd:	53                   	push   %ebx
f01042ce:	83 ec 14             	sub    $0x14,%esp
f01042d1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	//	e->env_tf.  Go back through the code you wrote above
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.
        if(e!= curenv){
f01042d4:	e8 e5 33 00 00       	call   f01076be <cpunum>
f01042d9:	6b c0 74             	imul   $0x74,%eax,%eax
f01042dc:	39 98 28 e0 24 f0    	cmp    %ebx,-0xfdb1fd8(%eax)
f01042e2:	0f 84 88 00 00 00    	je     f0104370 <env_run+0xa6>
           if(curenv != NULL){
f01042e8:	e8 d1 33 00 00       	call   f01076be <cpunum>
f01042ed:	6b c0 74             	imul   $0x74,%eax,%eax
f01042f0:	83 b8 28 e0 24 f0 00 	cmpl   $0x0,-0xfdb1fd8(%eax)
f01042f7:	74 29                	je     f0104322 <env_run+0x58>
               if(curenv->env_status == ENV_RUNNING)
f01042f9:	e8 c0 33 00 00       	call   f01076be <cpunum>
f01042fe:	6b c0 74             	imul   $0x74,%eax,%eax
f0104301:	8b 80 28 e0 24 f0    	mov    -0xfdb1fd8(%eax),%eax
f0104307:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f010430b:	75 15                	jne    f0104322 <env_run+0x58>
                  curenv->env_status = ENV_RUNNABLE;
f010430d:	e8 ac 33 00 00       	call   f01076be <cpunum>
f0104312:	6b c0 74             	imul   $0x74,%eax,%eax
f0104315:	8b 80 28 e0 24 f0    	mov    -0xfdb1fd8(%eax),%eax
f010431b:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
           }
           curenv = e;
f0104322:	e8 97 33 00 00       	call   f01076be <cpunum>
f0104327:	6b c0 74             	imul   $0x74,%eax,%eax
f010432a:	89 98 28 e0 24 f0    	mov    %ebx,-0xfdb1fd8(%eax)
           e->env_status = ENV_RUNNING;
f0104330:	c7 43 54 03 00 00 00 	movl   $0x3,0x54(%ebx)
           e->env_runs++;
f0104337:	83 43 58 01          	addl   $0x1,0x58(%ebx)
           lcr3(PADDR(e->env_pgdir));
f010433b:	8b 43 64             	mov    0x64(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010433e:	89 c2                	mov    %eax,%edx
f0104340:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0104345:	77 20                	ja     f0104367 <env_run+0x9d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0104347:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010434b:	c7 44 24 08 5c 7e 10 	movl   $0xf0107e5c,0x8(%esp)
f0104352:	f0 
f0104353:	c7 44 24 04 1a 02 00 	movl   $0x21a,0x4(%esp)
f010435a:	00 
f010435b:	c7 04 24 6f 90 10 f0 	movl   $0xf010906f,(%esp)
f0104362:	e8 1e bd ff ff       	call   f0100085 <_panic>
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0104367:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f010436d:	0f 22 da             	mov    %edx,%cr3
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0104370:	c7 04 24 80 43 12 f0 	movl   $0xf0124380,(%esp)
f0104377:	e8 f0 35 00 00       	call   f010796c <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f010437c:	f3 90                	pause  
        }
        //print_trapframe(&e->env_tf);
        
        unlock_kernel(); 
        env_pop_tf(&e->env_tf);     
f010437e:	89 1c 24             	mov    %ebx,(%esp)
f0104381:	e8 01 ff ff ff       	call   f0104287 <env_pop_tf>

f0104386 <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f0104386:	55                   	push   %ebp
f0104387:	89 e5                	mov    %esp,%ebp
f0104389:	57                   	push   %edi
f010438a:	56                   	push   %esi
f010438b:	53                   	push   %ebx
f010438c:	83 ec 2c             	sub    $0x2c,%esp
f010438f:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0104392:	e8 27 33 00 00       	call   f01076be <cpunum>
f0104397:	6b c0 74             	imul   $0x74,%eax,%eax
f010439a:	39 b8 28 e0 24 f0    	cmp    %edi,-0xfdb1fd8(%eax)
f01043a0:	75 35                	jne    f01043d7 <env_free+0x51>
		lcr3(PADDR(kern_pgdir));
f01043a2:	a1 ac de 24 f0       	mov    0xf024deac,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01043a7:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01043ac:	77 20                	ja     f01043ce <env_free+0x48>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01043ae:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01043b2:	c7 44 24 08 5c 7e 10 	movl   $0xf0107e5c,0x8(%esp)
f01043b9:	f0 
f01043ba:	c7 44 24 04 a1 01 00 	movl   $0x1a1,0x4(%esp)
f01043c1:	00 
f01043c2:	c7 04 24 6f 90 10 f0 	movl   $0xf010906f,(%esp)
f01043c9:	e8 b7 bc ff ff       	call   f0100085 <_panic>
f01043ce:	8d 80 00 00 00 10    	lea    0x10000000(%eax),%eax
f01043d4:	0f 22 d8             	mov    %eax,%cr3

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f01043d7:	8b 5f 48             	mov    0x48(%edi),%ebx
f01043da:	e8 df 32 00 00       	call   f01076be <cpunum>
f01043df:	6b d0 74             	imul   $0x74,%eax,%edx
f01043e2:	b8 00 00 00 00       	mov    $0x0,%eax
f01043e7:	83 ba 28 e0 24 f0 00 	cmpl   $0x0,-0xfdb1fd8(%edx)
f01043ee:	74 11                	je     f0104401 <env_free+0x7b>
f01043f0:	e8 c9 32 00 00       	call   f01076be <cpunum>
f01043f5:	6b c0 74             	imul   $0x74,%eax,%eax
f01043f8:	8b 80 28 e0 24 f0    	mov    -0xfdb1fd8(%eax),%eax
f01043fe:	8b 40 48             	mov    0x48(%eax),%eax
f0104401:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0104405:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104409:	c7 04 24 7a 90 10 f0 	movl   $0xf010907a,(%esp)
f0104410:	e8 f2 06 00 00       	call   f0104b07 <cprintf>
f0104415:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f010441c:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010441f:	c1 e0 02             	shl    $0x2,%eax
f0104422:	89 45 dc             	mov    %eax,-0x24(%ebp)
	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0104425:	8b 47 64             	mov    0x64(%edi),%eax
f0104428:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010442b:	8b 34 10             	mov    (%eax,%edx,1),%esi
f010442e:	f7 c6 01 00 00 00    	test   $0x1,%esi
f0104434:	0f 84 b8 00 00 00    	je     f01044f2 <env_free+0x16c>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f010443a:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0104440:	89 f0                	mov    %esi,%eax
f0104442:	c1 e8 0c             	shr    $0xc,%eax
f0104445:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104448:	3b 05 a8 de 24 f0    	cmp    0xf024dea8,%eax
f010444e:	72 20                	jb     f0104470 <env_free+0xea>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0104450:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0104454:	c7 44 24 08 80 7e 10 	movl   $0xf0107e80,0x8(%esp)
f010445b:	f0 
f010445c:	c7 44 24 04 b0 01 00 	movl   $0x1b0,0x4(%esp)
f0104463:	00 
f0104464:	c7 04 24 6f 90 10 f0 	movl   $0xf010906f,(%esp)
f010446b:	e8 15 bc ff ff       	call   f0100085 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0104470:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0104473:	c1 e2 16             	shl    $0x16,%edx
f0104476:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0104479:	bb 00 00 00 00       	mov    $0x0,%ebx
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
f010447e:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f0104485:	01 
f0104486:	74 17                	je     f010449f <env_free+0x119>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0104488:	89 d8                	mov    %ebx,%eax
f010448a:	c1 e0 0c             	shl    $0xc,%eax
f010448d:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0104490:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104494:	8b 47 64             	mov    0x64(%edi),%eax
f0104497:	89 04 24             	mov    %eax,(%esp)
f010449a:	e8 a1 de ff ff       	call   f0102340 <page_remove>
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f010449f:	83 c3 01             	add    $0x1,%ebx
f01044a2:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f01044a8:	75 d4                	jne    f010447e <env_free+0xf8>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f01044aa:	8b 47 64             	mov    0x64(%edi),%eax
f01044ad:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01044b0:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01044b7:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01044ba:	3b 05 a8 de 24 f0    	cmp    0xf024dea8,%eax
f01044c0:	72 1c                	jb     f01044de <env_free+0x158>
		panic("pa2page called with invalid pa");
f01044c2:	c7 44 24 08 70 8a 10 	movl   $0xf0108a70,0x8(%esp)
f01044c9:	f0 
f01044ca:	c7 44 24 04 4f 00 00 	movl   $0x4f,0x4(%esp)
f01044d1:	00 
f01044d2:	c7 04 24 32 86 10 f0 	movl   $0xf0108632,(%esp)
f01044d9:	e8 a7 bb ff ff       	call   f0100085 <_panic>
		page_decref(pa2page(pa));
f01044de:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01044e1:	c1 e0 03             	shl    $0x3,%eax
f01044e4:	03 05 b0 de 24 f0    	add    0xf024deb0,%eax
f01044ea:	89 04 24             	mov    %eax,(%esp)
f01044ed:	e8 d2 d1 ff ff       	call   f01016c4 <page_decref>
	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f01044f2:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
f01044f6:	81 7d e0 bb 03 00 00 	cmpl   $0x3bb,-0x20(%ebp)
f01044fd:	0f 85 19 ff ff ff    	jne    f010441c <env_free+0x96>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f0104503:	8b 47 64             	mov    0x64(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0104506:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010450b:	77 20                	ja     f010452d <env_free+0x1a7>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010450d:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104511:	c7 44 24 08 5c 7e 10 	movl   $0xf0107e5c,0x8(%esp)
f0104518:	f0 
f0104519:	c7 44 24 04 be 01 00 	movl   $0x1be,0x4(%esp)
f0104520:	00 
f0104521:	c7 04 24 6f 90 10 f0 	movl   $0xf010906f,(%esp)
f0104528:	e8 58 bb ff ff       	call   f0100085 <_panic>
	e->env_pgdir = 0;
f010452d:	c7 47 64 00 00 00 00 	movl   $0x0,0x64(%edi)
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0104534:	8d 80 00 00 00 10    	lea    0x10000000(%eax),%eax
f010453a:	c1 e8 0c             	shr    $0xc,%eax
f010453d:	3b 05 a8 de 24 f0    	cmp    0xf024dea8,%eax
f0104543:	72 1c                	jb     f0104561 <env_free+0x1db>
		panic("pa2page called with invalid pa");
f0104545:	c7 44 24 08 70 8a 10 	movl   $0xf0108a70,0x8(%esp)
f010454c:	f0 
f010454d:	c7 44 24 04 4f 00 00 	movl   $0x4f,0x4(%esp)
f0104554:	00 
f0104555:	c7 04 24 32 86 10 f0 	movl   $0xf0108632,(%esp)
f010455c:	e8 24 bb ff ff       	call   f0100085 <_panic>
	page_decref(pa2page(pa));
f0104561:	c1 e0 03             	shl    $0x3,%eax
f0104564:	03 05 b0 de 24 f0    	add    0xf024deb0,%eax
f010456a:	89 04 24             	mov    %eax,(%esp)
f010456d:	e8 52 d1 ff ff       	call   f01016c4 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0104572:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f0104579:	a1 60 d2 24 f0       	mov    0xf024d260,%eax
f010457e:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f0104581:	89 3d 60 d2 24 f0    	mov    %edi,0xf024d260
}
f0104587:	83 c4 2c             	add    $0x2c,%esp
f010458a:	5b                   	pop    %ebx
f010458b:	5e                   	pop    %esi
f010458c:	5f                   	pop    %edi
f010458d:	5d                   	pop    %ebp
f010458e:	c3                   	ret    

f010458f <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f010458f:	55                   	push   %ebp
f0104590:	89 e5                	mov    %esp,%ebp
f0104592:	53                   	push   %ebx
f0104593:	83 ec 14             	sub    $0x14,%esp
f0104596:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f0104599:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f010459d:	75 19                	jne    f01045b8 <env_destroy+0x29>
f010459f:	e8 1a 31 00 00       	call   f01076be <cpunum>
f01045a4:	6b c0 74             	imul   $0x74,%eax,%eax
f01045a7:	39 98 28 e0 24 f0    	cmp    %ebx,-0xfdb1fd8(%eax)
f01045ad:	74 09                	je     f01045b8 <env_destroy+0x29>
		e->env_status = ENV_DYING;
f01045af:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f01045b6:	eb 2f                	jmp    f01045e7 <env_destroy+0x58>
	}

	env_free(e);
f01045b8:	89 1c 24             	mov    %ebx,(%esp)
f01045bb:	e8 c6 fd ff ff       	call   f0104386 <env_free>

	if (curenv == e) {
f01045c0:	e8 f9 30 00 00       	call   f01076be <cpunum>
f01045c5:	6b c0 74             	imul   $0x74,%eax,%eax
f01045c8:	39 98 28 e0 24 f0    	cmp    %ebx,-0xfdb1fd8(%eax)
f01045ce:	75 17                	jne    f01045e7 <env_destroy+0x58>
		curenv = NULL;
f01045d0:	e8 e9 30 00 00       	call   f01076be <cpunum>
f01045d5:	6b c0 74             	imul   $0x74,%eax,%eax
f01045d8:	c7 80 28 e0 24 f0 00 	movl   $0x0,-0xfdb1fd8(%eax)
f01045df:	00 00 00 
		sched_yield();
f01045e2:	e8 99 13 00 00       	call   f0105980 <sched_yield>
	}
}
f01045e7:	83 c4 14             	add    $0x14,%esp
f01045ea:	5b                   	pop    %ebx
f01045eb:	5d                   	pop    %ebp
f01045ec:	c3                   	ret    

f01045ed <env_alloc>:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f01045ed:	55                   	push   %ebp
f01045ee:	89 e5                	mov    %esp,%ebp
f01045f0:	53                   	push   %ebx
f01045f1:	83 ec 14             	sub    $0x14,%esp
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f01045f4:	8b 1d 60 d2 24 f0    	mov    0xf024d260,%ebx
f01045fa:	ba fb ff ff ff       	mov    $0xfffffffb,%edx
f01045ff:	85 db                	test   %ebx,%ebx
f0104601:	0f 84 a4 01 00 00    	je     f01047ab <env_alloc+0x1be>
{
	int i;
	struct Page *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f0104607:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f010460e:	e8 74 da ff ff       	call   f0102087 <page_alloc>
f0104613:	ba fc ff ff ff       	mov    $0xfffffffc,%edx
f0104618:	85 c0                	test   %eax,%eax
f010461a:	0f 84 8b 01 00 00    	je     f01047ab <env_alloc+0x1be>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0104620:	89 c2                	mov    %eax,%edx
f0104622:	2b 15 b0 de 24 f0    	sub    0xf024deb0,%edx
f0104628:	c1 fa 03             	sar    $0x3,%edx
f010462b:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010462e:	89 d1                	mov    %edx,%ecx
f0104630:	c1 e9 0c             	shr    $0xc,%ecx
f0104633:	3b 0d a8 de 24 f0    	cmp    0xf024dea8,%ecx
f0104639:	72 20                	jb     f010465b <env_alloc+0x6e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010463b:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010463f:	c7 44 24 08 80 7e 10 	movl   $0xf0107e80,0x8(%esp)
f0104646:	f0 
f0104647:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f010464e:	00 
f010464f:	c7 04 24 32 86 10 f0 	movl   $0xf0108632,(%esp)
f0104656:	e8 2a ba ff ff       	call   f0100085 <_panic>
	//	is an exception -- you need to increment env_pgdir's
	//	pp_ref for env_free to work correctly.
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.
        e->env_pgdir = (pde_t*)page2kva(p);
f010465b:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0104661:	89 53 64             	mov    %edx,0x64(%ebx)
        p->pp_ref++;
f0104664:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
        memmove(e->env_pgdir,kern_pgdir,PGSIZE);
f0104669:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0104670:	00 
f0104671:	a1 ac de 24 f0       	mov    0xf024deac,%eax
f0104676:	89 44 24 04          	mov    %eax,0x4(%esp)
f010467a:	8b 43 64             	mov    0x64(%ebx),%eax
f010467d:	89 04 24             	mov    %eax,(%esp)
f0104680:	e8 f0 29 00 00       	call   f0107075 <memmove>
	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f0104685:	8b 43 64             	mov    0x64(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0104688:	89 c2                	mov    %eax,%edx
f010468a:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010468f:	77 20                	ja     f01046b1 <env_alloc+0xc4>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0104691:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104695:	c7 44 24 08 5c 7e 10 	movl   $0xf0107e5c,0x8(%esp)
f010469c:	f0 
f010469d:	c7 44 24 04 c4 00 00 	movl   $0xc4,0x4(%esp)
f01046a4:	00 
f01046a5:	c7 04 24 6f 90 10 f0 	movl   $0xf010906f,(%esp)
f01046ac:	e8 d4 b9 ff ff       	call   f0100085 <_panic>
f01046b1:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f01046b7:	83 ca 05             	or     $0x5,%edx
f01046ba:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f01046c0:	8b 43 48             	mov    0x48(%ebx),%eax
f01046c3:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f01046c8:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f01046cd:	7f 05                	jg     f01046d4 <env_alloc+0xe7>
f01046cf:	b8 00 10 00 00       	mov    $0x1000,%eax
		generation = 1 << ENVGENSHIFT;
	e->env_id = generation | (e - envs);
f01046d4:	89 da                	mov    %ebx,%edx
f01046d6:	2b 15 5c d2 24 f0    	sub    0xf024d25c,%edx
f01046dc:	c1 fa 02             	sar    $0x2,%edx
f01046df:	69 d2 e1 83 0f 3e    	imul   $0x3e0f83e1,%edx,%edx
f01046e5:	09 d0                	or     %edx,%eax
f01046e7:	89 43 48             	mov    %eax,0x48(%ebx)
        //cprintf("envs:%8x\n",e->env_id);
	// Set the basic status variables.
	e->env_parent_id = parent_id;
f01046ea:	8b 45 0c             	mov    0xc(%ebp),%eax
f01046ed:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f01046f0:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f01046f7:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f01046fe:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f0104705:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
f010470c:	00 
f010470d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0104714:	00 
f0104715:	89 1c 24             	mov    %ebx,(%esp)
f0104718:	e8 f9 28 00 00       	call   f0107016 <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f010471d:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f0104723:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f0104729:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f010472f:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f0104736:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	// You will set e->env_tf.tf_eip later.
        e->env_prior = PRIOR_MIDD;
f010473c:	c7 83 80 00 00 00 02 	movl   $0x2,0x80(%ebx)
f0104743:	00 00 00 

	// Enable interrupts while in user mode.
	// LAB 4: Your code here.
        e->env_tf.tf_eflags |= FL_IF;
f0104746:	81 4b 38 00 02 00 00 	orl    $0x200,0x38(%ebx)
	// Clear the page fault handler until user installs one.
	e->env_pgfault_upcall = 0;
f010474d:	c7 43 68 00 00 00 00 	movl   $0x0,0x68(%ebx)

	// Also clear the IPC receiving flag.
	e->env_ipc_recving = 0;
f0104754:	c7 43 6c 00 00 00 00 	movl   $0x0,0x6c(%ebx)

	// commit the allocation
	env_free_list = e->env_link;
f010475b:	8b 43 44             	mov    0x44(%ebx),%eax
f010475e:	a3 60 d2 24 f0       	mov    %eax,0xf024d260
	*newenv_store = e;
f0104763:	8b 45 08             	mov    0x8(%ebp),%eax
f0104766:	89 18                	mov    %ebx,(%eax)

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0104768:	8b 5b 48             	mov    0x48(%ebx),%ebx
f010476b:	e8 4e 2f 00 00       	call   f01076be <cpunum>
f0104770:	6b c0 74             	imul   $0x74,%eax,%eax
f0104773:	ba 00 00 00 00       	mov    $0x0,%edx
f0104778:	83 b8 28 e0 24 f0 00 	cmpl   $0x0,-0xfdb1fd8(%eax)
f010477f:	74 11                	je     f0104792 <env_alloc+0x1a5>
f0104781:	e8 38 2f 00 00       	call   f01076be <cpunum>
f0104786:	6b c0 74             	imul   $0x74,%eax,%eax
f0104789:	8b 80 28 e0 24 f0    	mov    -0xfdb1fd8(%eax),%eax
f010478f:	8b 50 48             	mov    0x48(%eax),%edx
f0104792:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0104796:	89 54 24 04          	mov    %edx,0x4(%esp)
f010479a:	c7 04 24 90 90 10 f0 	movl   $0xf0109090,(%esp)
f01047a1:	e8 61 03 00 00       	call   f0104b07 <cprintf>
f01047a6:	ba 00 00 00 00       	mov    $0x0,%edx
	return 0;
}
f01047ab:	89 d0                	mov    %edx,%eax
f01047ad:	83 c4 14             	add    $0x14,%esp
f01047b0:	5b                   	pop    %ebx
f01047b1:	5d                   	pop    %ebp
f01047b2:	c3                   	ret    

f01047b3 <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f01047b3:	55                   	push   %ebp
f01047b4:	89 e5                	mov    %esp,%ebp
f01047b6:	57                   	push   %edi
f01047b7:	56                   	push   %esi
f01047b8:	53                   	push   %ebx
f01047b9:	83 ec 1c             	sub    $0x1c,%esp
f01047bc:	89 c6                	mov    %eax,%esi
	//
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
        void* begin = ROUNDDOWN(va,PGSIZE);
f01047be:	89 d3                	mov    %edx,%ebx
f01047c0:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
        void* end = ROUNDUP(va+len,PGSIZE);
f01047c6:	8d bc 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%edi
f01047cd:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
        while(begin < end){
f01047d3:	39 fb                	cmp    %edi,%ebx
f01047d5:	73 51                	jae    f0104828 <region_alloc+0x75>
           struct Page* page = page_alloc(0);
f01047d7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01047de:	e8 a4 d8 ff ff       	call   f0102087 <page_alloc>
           if(page == NULL)
f01047e3:	85 c0                	test   %eax,%eax
f01047e5:	75 1c                	jne    f0104803 <region_alloc+0x50>
               panic("page alloc failed\n");
f01047e7:	c7 44 24 08 a5 90 10 	movl   $0xf01090a5,0x8(%esp)
f01047ee:	f0 
f01047ef:	c7 44 24 04 28 01 00 	movl   $0x128,0x4(%esp)
f01047f6:	00 
f01047f7:	c7 04 24 6f 90 10 f0 	movl   $0xf010906f,(%esp)
f01047fe:	e8 82 b8 ff ff       	call   f0100085 <_panic>
           page_insert(e->env_pgdir,page,begin,PTE_U|PTE_W|PTE_P);
f0104803:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
f010480a:	00 
f010480b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f010480f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104813:	8b 46 64             	mov    0x64(%esi),%eax
f0104816:	89 04 24             	mov    %eax,(%esp)
f0104819:	e8 7d db ff ff       	call   f010239b <page_insert>
           begin += PGSIZE;
f010481e:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
        void* begin = ROUNDDOWN(va,PGSIZE);
        void* end = ROUNDUP(va+len,PGSIZE);
        while(begin < end){
f0104824:	39 df                	cmp    %ebx,%edi
f0104826:	77 af                	ja     f01047d7 <region_alloc+0x24>
           if(page == NULL)
               panic("page alloc failed\n");
           page_insert(e->env_pgdir,page,begin,PTE_U|PTE_W|PTE_P);
           begin += PGSIZE;
        }
}
f0104828:	83 c4 1c             	add    $0x1c,%esp
f010482b:	5b                   	pop    %ebx
f010482c:	5e                   	pop    %esi
f010482d:	5f                   	pop    %edi
f010482e:	5d                   	pop    %ebp
f010482f:	c3                   	ret    

f0104830 <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, size_t size, enum EnvType type)
{
f0104830:	55                   	push   %ebp
f0104831:	89 e5                	mov    %esp,%ebp
f0104833:	57                   	push   %edi
f0104834:	56                   	push   %esi
f0104835:	53                   	push   %ebx
f0104836:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 3: Your code here.
        struct Env* newEnv;
        int r;
        r = env_alloc(&newEnv,0);
f0104839:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0104840:	00 
f0104841:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104844:	89 04 24             	mov    %eax,(%esp)
f0104847:	e8 a1 fd ff ff       	call   f01045ed <env_alloc>
        if(r < 0)
f010484c:	85 c0                	test   %eax,%eax
f010484e:	79 20                	jns    f0104870 <env_create+0x40>
           panic("env_alloc: %e", r);
f0104850:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104854:	c7 44 24 08 b8 90 10 	movl   $0xf01090b8,0x8(%esp)
f010485b:	f0 
f010485c:	c7 44 24 04 8e 01 00 	movl   $0x18e,0x4(%esp)
f0104863:	00 
f0104864:	c7 04 24 6f 90 10 f0 	movl   $0xf010906f,(%esp)
f010486b:	e8 15 b8 ff ff       	call   f0100085 <_panic>
        load_icode(newEnv,binary,size);
f0104870:	8b 7d e4             	mov    -0x1c(%ebp),%edi
	//  You must also do something with the program's entry point,
	//  to make sure that the environment starts executing there.
	//  What?  (See env_run() and env_pop_tf() below.)

	// LAB 3: Your code here.
        struct Elf* elfhdr = (struct Elf*)binary;
f0104873:	8b 45 08             	mov    0x8(%ebp),%eax
f0104876:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        struct Proghdr *ph, *eph;
        if (elfhdr->e_magic != ELF_MAGIC)
f0104879:	81 38 7f 45 4c 46    	cmpl   $0x464c457f,(%eax)
f010487f:	74 1c                	je     f010489d <env_create+0x6d>
		panic("Wrong ELF FILE\n");
f0104881:	c7 44 24 08 c6 90 10 	movl   $0xf01090c6,0x8(%esp)
f0104888:	f0 
f0104889:	c7 44 24 04 67 01 00 	movl   $0x167,0x4(%esp)
f0104890:	00 
f0104891:	c7 04 24 6f 90 10 f0 	movl   $0xf010906f,(%esp)
f0104898:	e8 e8 b7 ff ff       	call   f0100085 <_panic>
        ph = (struct Proghdr *) ((uint8_t *) elfhdr + elfhdr->e_phoff);
f010489d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01048a0:	8b 5a 1c             	mov    0x1c(%edx),%ebx
        eph = ph + elfhdr->e_phnum;
f01048a3:	0f b7 72 2c          	movzwl 0x2c(%edx),%esi

        lcr3(PADDR(e->env_pgdir));
f01048a7:	8b 47 64             	mov    0x64(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01048aa:	89 c2                	mov    %eax,%edx
f01048ac:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01048b1:	77 20                	ja     f01048d3 <env_create+0xa3>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01048b3:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01048b7:	c7 44 24 08 5c 7e 10 	movl   $0xf0107e5c,0x8(%esp)
f01048be:	f0 
f01048bf:	c7 44 24 04 6b 01 00 	movl   $0x16b,0x4(%esp)
f01048c6:	00 
f01048c7:	c7 04 24 6f 90 10 f0 	movl   $0xf010906f,(%esp)
f01048ce:	e8 b2 b7 ff ff       	call   f0100085 <_panic>
	// LAB 3: Your code here.
        struct Elf* elfhdr = (struct Elf*)binary;
        struct Proghdr *ph, *eph;
        if (elfhdr->e_magic != ELF_MAGIC)
		panic("Wrong ELF FILE\n");
        ph = (struct Proghdr *) ((uint8_t *) elfhdr + elfhdr->e_phoff);
f01048d3:	03 5d d4             	add    -0x2c(%ebp),%ebx
        eph = ph + elfhdr->e_phnum;
f01048d6:	0f b7 f6             	movzwl %si,%esi
f01048d9:	c1 e6 05             	shl    $0x5,%esi
f01048dc:	8d 34 33             	lea    (%ebx,%esi,1),%esi
f01048df:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f01048e5:	0f 22 da             	mov    %edx,%cr3

        lcr3(PADDR(e->env_pgdir));
        for (; ph < eph; ph++){
f01048e8:	39 f3                	cmp    %esi,%ebx
f01048ea:	73 5d                	jae    f0104949 <env_create+0x119>
                if(ph->p_type == ELF_PROG_LOAD){
f01048ec:	83 3b 01             	cmpl   $0x1,(%ebx)
f01048ef:	75 51                	jne    f0104942 <env_create+0x112>
		   region_alloc(e,(void*)ph->p_va,ph->p_memsz);
f01048f1:	8b 4b 14             	mov    0x14(%ebx),%ecx
f01048f4:	8b 53 08             	mov    0x8(%ebx),%edx
f01048f7:	89 f8                	mov    %edi,%eax
f01048f9:	e8 b5 fe ff ff       	call   f01047b3 <region_alloc>
                   memset((void*)ph->p_va,0,ph->p_memsz);
f01048fe:	8b 43 14             	mov    0x14(%ebx),%eax
f0104901:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104905:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010490c:	00 
f010490d:	8b 43 08             	mov    0x8(%ebx),%eax
f0104910:	89 04 24             	mov    %eax,(%esp)
f0104913:	e8 fe 26 00 00       	call   f0107016 <memset>
                   if(ph->p_va + ph->p_memsz > e->env_break)
f0104918:	8b 43 14             	mov    0x14(%ebx),%eax
f010491b:	03 43 08             	add    0x8(%ebx),%eax
f010491e:	3b 47 60             	cmp    0x60(%edi),%eax
f0104921:	76 03                	jbe    f0104926 <env_create+0xf6>
                      e->env_break = ph->p_va + ph->p_memsz;
f0104923:	89 47 60             	mov    %eax,0x60(%edi)
                   memmove((void*)ph->p_va,binary+ph->p_offset,ph->p_filesz);
f0104926:	8b 43 10             	mov    0x10(%ebx),%eax
f0104929:	89 44 24 08          	mov    %eax,0x8(%esp)
f010492d:	8b 45 08             	mov    0x8(%ebp),%eax
f0104930:	03 43 04             	add    0x4(%ebx),%eax
f0104933:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104937:	8b 43 08             	mov    0x8(%ebx),%eax
f010493a:	89 04 24             	mov    %eax,(%esp)
f010493d:	e8 33 27 00 00       	call   f0107075 <memmove>
		panic("Wrong ELF FILE\n");
        ph = (struct Proghdr *) ((uint8_t *) elfhdr + elfhdr->e_phoff);
        eph = ph + elfhdr->e_phnum;

        lcr3(PADDR(e->env_pgdir));
        for (; ph < eph; ph++){
f0104942:	83 c3 20             	add    $0x20,%ebx
f0104945:	39 de                	cmp    %ebx,%esi
f0104947:	77 a3                	ja     f01048ec <env_create+0xbc>
                   if(ph->p_va + ph->p_memsz > e->env_break)
                      e->env_break = ph->p_va + ph->p_memsz;
                   memmove((void*)ph->p_va,binary+ph->p_offset,ph->p_filesz);
                }
        }
        e->env_tf.tf_eip = elfhdr->e_entry;
f0104949:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f010494c:	8b 42 18             	mov    0x18(%edx),%eax
f010494f:	89 47 30             	mov    %eax,0x30(%edi)
        lcr3(PADDR(kern_pgdir));
f0104952:	a1 ac de 24 f0       	mov    0xf024deac,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0104957:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010495c:	77 20                	ja     f010497e <env_create+0x14e>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010495e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104962:	c7 44 24 08 5c 7e 10 	movl   $0xf0107e5c,0x8(%esp)
f0104969:	f0 
f010496a:	c7 44 24 04 76 01 00 	movl   $0x176,0x4(%esp)
f0104971:	00 
f0104972:	c7 04 24 6f 90 10 f0 	movl   $0xf010906f,(%esp)
f0104979:	e8 07 b7 ff ff       	call   f0100085 <_panic>
f010497e:	8d 80 00 00 00 10    	lea    0x10000000(%eax),%eax
f0104984:	0f 22 d8             	mov    %eax,%cr3
        
	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.
        region_alloc(e,(void*)(USTACKTOP-PGSIZE),PGSIZE);
f0104987:	b9 00 10 00 00       	mov    $0x1000,%ecx
f010498c:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f0104991:	89 f8                	mov    %edi,%eax
f0104993:	e8 1b fe ff ff       	call   f01047b3 <region_alloc>
        int r;
        r = env_alloc(&newEnv,0);
        if(r < 0)
           panic("env_alloc: %e", r);
        load_icode(newEnv,binary,size);
        newEnv->env_type = type;
f0104998:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010499b:	8b 55 10             	mov    0x10(%ebp),%edx
f010499e:	89 50 50             	mov    %edx,0x50(%eax)
}
f01049a1:	83 c4 3c             	add    $0x3c,%esp
f01049a4:	5b                   	pop    %ebx
f01049a5:	5e                   	pop    %esi
f01049a6:	5f                   	pop    %edi
f01049a7:	5d                   	pop    %ebp
f01049a8:	c3                   	ret    
f01049a9:	00 00                	add    %al,(%eax)
	...

f01049ac <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f01049ac:	55                   	push   %ebp
f01049ad:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01049af:	ba 70 00 00 00       	mov    $0x70,%edx
f01049b4:	8b 45 08             	mov    0x8(%ebp),%eax
f01049b7:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01049b8:	b2 71                	mov    $0x71,%dl
f01049ba:	ec                   	in     (%dx),%al
f01049bb:	0f b6 c0             	movzbl %al,%eax
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
}
f01049be:	5d                   	pop    %ebp
f01049bf:	c3                   	ret    

f01049c0 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f01049c0:	55                   	push   %ebp
f01049c1:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01049c3:	ba 70 00 00 00       	mov    $0x70,%edx
f01049c8:	8b 45 08             	mov    0x8(%ebp),%eax
f01049cb:	ee                   	out    %al,(%dx)
f01049cc:	b2 71                	mov    $0x71,%dl
f01049ce:	8b 45 0c             	mov    0xc(%ebp),%eax
f01049d1:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f01049d2:	5d                   	pop    %ebp
f01049d3:	c3                   	ret    

f01049d4 <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f01049d4:	55                   	push   %ebp
f01049d5:	89 e5                	mov    %esp,%ebp
f01049d7:	56                   	push   %esi
f01049d8:	53                   	push   %ebx
f01049d9:	83 ec 10             	sub    $0x10,%esp
f01049dc:	8b 45 08             	mov    0x8(%ebp),%eax
f01049df:	89 c6                	mov    %eax,%esi
	int i;
	irq_mask_8259A = mask;
f01049e1:	66 a3 70 43 12 f0    	mov    %ax,0xf0124370
	if (!didinit)
f01049e7:	83 3d 64 d2 24 f0 00 	cmpl   $0x0,0xf024d264
f01049ee:	74 4e                	je     f0104a3e <irq_setmask_8259A+0x6a>
f01049f0:	ba 21 00 00 00       	mov    $0x21,%edx
f01049f5:	ee                   	out    %al,(%dx)
f01049f6:	89 f0                	mov    %esi,%eax
f01049f8:	66 c1 e8 08          	shr    $0x8,%ax
f01049fc:	b2 a1                	mov    $0xa1,%dl
f01049fe:	ee                   	out    %al,(%dx)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
f01049ff:	c7 04 24 d6 90 10 f0 	movl   $0xf01090d6,(%esp)
f0104a06:	e8 fc 00 00 00       	call   f0104b07 <cprintf>
f0104a0b:	bb 00 00 00 00       	mov    $0x0,%ebx
	for (i = 0; i < 16; i++)
		if (~mask & (1<<i))
f0104a10:	0f b7 f6             	movzwl %si,%esi
f0104a13:	f7 d6                	not    %esi
f0104a15:	0f a3 de             	bt     %ebx,%esi
f0104a18:	73 10                	jae    f0104a2a <irq_setmask_8259A+0x56>
			cprintf(" %d", i);
f0104a1a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0104a1e:	c7 04 24 c4 95 10 f0 	movl   $0xf01095c4,(%esp)
f0104a25:	e8 dd 00 00 00       	call   f0104b07 <cprintf>
	if (!didinit)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
f0104a2a:	83 c3 01             	add    $0x1,%ebx
f0104a2d:	83 fb 10             	cmp    $0x10,%ebx
f0104a30:	75 e3                	jne    f0104a15 <irq_setmask_8259A+0x41>
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
f0104a32:	c7 04 24 d9 82 10 f0 	movl   $0xf01082d9,(%esp)
f0104a39:	e8 c9 00 00 00       	call   f0104b07 <cprintf>
}
f0104a3e:	83 c4 10             	add    $0x10,%esp
f0104a41:	5b                   	pop    %ebx
f0104a42:	5e                   	pop    %esi
f0104a43:	5d                   	pop    %ebp
f0104a44:	c3                   	ret    

f0104a45 <pic_init>:
static bool didinit;

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
f0104a45:	55                   	push   %ebp
f0104a46:	89 e5                	mov    %esp,%ebp
f0104a48:	83 ec 18             	sub    $0x18,%esp
	didinit = 1;
f0104a4b:	c7 05 64 d2 24 f0 01 	movl   $0x1,0xf024d264
f0104a52:	00 00 00 
f0104a55:	ba 21 00 00 00       	mov    $0x21,%edx
f0104a5a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104a5f:	ee                   	out    %al,(%dx)
f0104a60:	b2 a1                	mov    $0xa1,%dl
f0104a62:	ee                   	out    %al,(%dx)
f0104a63:	b2 20                	mov    $0x20,%dl
f0104a65:	b8 11 00 00 00       	mov    $0x11,%eax
f0104a6a:	ee                   	out    %al,(%dx)
f0104a6b:	b2 21                	mov    $0x21,%dl
f0104a6d:	b8 20 00 00 00       	mov    $0x20,%eax
f0104a72:	ee                   	out    %al,(%dx)
f0104a73:	b8 04 00 00 00       	mov    $0x4,%eax
f0104a78:	ee                   	out    %al,(%dx)
f0104a79:	b8 03 00 00 00       	mov    $0x3,%eax
f0104a7e:	ee                   	out    %al,(%dx)
f0104a7f:	b2 a0                	mov    $0xa0,%dl
f0104a81:	b8 11 00 00 00       	mov    $0x11,%eax
f0104a86:	ee                   	out    %al,(%dx)
f0104a87:	b2 a1                	mov    $0xa1,%dl
f0104a89:	b8 28 00 00 00       	mov    $0x28,%eax
f0104a8e:	ee                   	out    %al,(%dx)
f0104a8f:	b8 02 00 00 00       	mov    $0x2,%eax
f0104a94:	ee                   	out    %al,(%dx)
f0104a95:	b8 01 00 00 00       	mov    $0x1,%eax
f0104a9a:	ee                   	out    %al,(%dx)
f0104a9b:	b2 20                	mov    $0x20,%dl
f0104a9d:	b8 68 00 00 00       	mov    $0x68,%eax
f0104aa2:	ee                   	out    %al,(%dx)
f0104aa3:	b8 0a 00 00 00       	mov    $0xa,%eax
f0104aa8:	ee                   	out    %al,(%dx)
f0104aa9:	b2 a0                	mov    $0xa0,%dl
f0104aab:	b8 68 00 00 00       	mov    $0x68,%eax
f0104ab0:	ee                   	out    %al,(%dx)
f0104ab1:	b8 0a 00 00 00       	mov    $0xa,%eax
f0104ab6:	ee                   	out    %al,(%dx)
	outb(IO_PIC1, 0x0a);             /* read IRR by default */

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
f0104ab7:	0f b7 05 70 43 12 f0 	movzwl 0xf0124370,%eax
f0104abe:	66 83 f8 ff          	cmp    $0xffffffff,%ax
f0104ac2:	74 0b                	je     f0104acf <pic_init+0x8a>
		irq_setmask_8259A(irq_mask_8259A);
f0104ac4:	0f b7 c0             	movzwl %ax,%eax
f0104ac7:	89 04 24             	mov    %eax,(%esp)
f0104aca:	e8 05 ff ff ff       	call   f01049d4 <irq_setmask_8259A>
}
f0104acf:	c9                   	leave  
f0104ad0:	c3                   	ret    
f0104ad1:	00 00                	add    %al,(%eax)
	...

f0104ad4 <vcprintf>:
    (*cnt)++;
}

int
vcprintf(const char *fmt, va_list ap)
{
f0104ad4:	55                   	push   %ebp
f0104ad5:	89 e5                	mov    %esp,%ebp
f0104ad7:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f0104ada:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0104ae1:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104ae4:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104ae8:	8b 45 08             	mov    0x8(%ebp),%eax
f0104aeb:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104aef:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0104af2:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104af6:	c7 04 24 21 4b 10 f0 	movl   $0xf0104b21,(%esp)
f0104afd:	e8 2a 1b 00 00       	call   f010662c <vprintfmt>
	return cnt;
}
f0104b02:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104b05:	c9                   	leave  
f0104b06:	c3                   	ret    

f0104b07 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0104b07:	55                   	push   %ebp
f0104b08:	89 e5                	mov    %esp,%ebp
f0104b0a:	83 ec 18             	sub    $0x18,%esp
	vprintfmt((void*)putch, &cnt, fmt, ap);
	return cnt;
}

int
cprintf(const char *fmt, ...)
f0104b0d:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
f0104b10:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104b14:	8b 45 08             	mov    0x8(%ebp),%eax
f0104b17:	89 04 24             	mov    %eax,(%esp)
f0104b1a:	e8 b5 ff ff ff       	call   f0104ad4 <vcprintf>
	va_end(ap);

	return cnt;
}
f0104b1f:	c9                   	leave  
f0104b20:	c3                   	ret    

f0104b21 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0104b21:	55                   	push   %ebp
f0104b22:	89 e5                	mov    %esp,%ebp
f0104b24:	53                   	push   %ebx
f0104b25:	83 ec 14             	sub    $0x14,%esp
f0104b28:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	cputchar(ch);
f0104b2b:	8b 45 08             	mov    0x8(%ebp),%eax
f0104b2e:	89 04 24             	mov    %eax,(%esp)
f0104b31:	e8 d4 bb ff ff       	call   f010070a <cputchar>
    (*cnt)++;
f0104b36:	83 03 01             	addl   $0x1,(%ebx)
}
f0104b39:	83 c4 14             	add    $0x14,%esp
f0104b3c:	5b                   	pop    %ebx
f0104b3d:	5d                   	pop    %ebp
f0104b3e:	c3                   	ret    
	...

f0104b40 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0104b40:	55                   	push   %ebp
f0104b41:	89 e5                	mov    %esp,%ebp
f0104b43:	83 ec 18             	sub    $0x18,%esp
f0104b46:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0104b49:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0104b4c:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// get a triple fault.  If you set up an individual CPU's TSS
	// wrong, you may not get a fault until you try to return from
	// user space on that CPU.
	//
	// LAB 4: Your code here:
        uint32_t cpuid = cpunum();
f0104b4f:	e8 6a 2b 00 00       	call   f01076be <cpunum>
f0104b54:	89 c3                	mov    %eax,%ebx
}

static inline void 
wrmsr(unsigned msr, unsigned low, unsigned high)
{
        asm volatile("wrmsr" : : "c" (msr), "a"(low), "d" (high) : "memory");
f0104b56:	ba 00 00 00 00       	mov    $0x0,%edx
f0104b5b:	b8 08 00 00 00       	mov    $0x8,%eax
f0104b60:	b9 74 01 00 00       	mov    $0x174,%ecx
f0104b65:	0f 30                	wrmsr  

        extern void sysenter_handler();
	wrmsr(0x174, GD_KT, 0);
	wrmsr(0x175, KSTACKTOP - cpuid*(KSTKSIZE + KSTKGAP), 0);
f0104b67:	be c0 ef 00 00       	mov    $0xefc0,%esi
f0104b6c:	29 de                	sub    %ebx,%esi
f0104b6e:	c1 e6 10             	shl    $0x10,%esi
f0104b71:	b1 75                	mov    $0x75,%cl
f0104b73:	89 f0                	mov    %esi,%eax
f0104b75:	0f 30                	wrmsr  
f0104b77:	b8 3a 59 10 f0       	mov    $0xf010593a,%eax
f0104b7c:	b1 76                	mov    $0x76,%cl
f0104b7e:	0f 30                	wrmsr  
	wrmsr(0x176, (uint32_t)&sysenter_handler, 0);

        struct Taskstate* cpu_ts = &thiscpu->cpu_ts;
f0104b80:	e8 39 2b 00 00       	call   f01076be <cpunum>
f0104b85:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b88:	05 20 e0 24 f0       	add    $0xf024e020,%eax
f0104b8d:	8d 78 0c             	lea    0xc(%eax),%edi
        cpu_ts->ts_esp0 = KSTACKTOP -cpuid*(KSTKSIZE +KSTKGAP);
f0104b90:	89 70 10             	mov    %esi,0x10(%eax)
        cpu_ts->ts_ss0 = GD_KD;
f0104b93:	66 c7 40 14 10 00    	movw   $0x10,0x14(%eax)
        gdt[(GD_TSS0 >> 3) + cpuid] = SEG16(STS_T32A, (uint32_t) (cpu_ts),
f0104b99:	8d 53 05             	lea    0x5(%ebx),%edx
f0104b9c:	b8 00 43 12 f0       	mov    $0xf0124300,%eax
f0104ba1:	66 c7 04 d0 68 00    	movw   $0x68,(%eax,%edx,8)
f0104ba7:	66 89 7c d0 02       	mov    %di,0x2(%eax,%edx,8)
f0104bac:	89 fe                	mov    %edi,%esi
f0104bae:	c1 ee 10             	shr    $0x10,%esi
f0104bb1:	89 f1                	mov    %esi,%ecx
f0104bb3:	88 4c d0 04          	mov    %cl,0x4(%eax,%edx,8)
f0104bb7:	c6 44 d0 06 40       	movb   $0x40,0x6(%eax,%edx,8)
f0104bbc:	89 f9                	mov    %edi,%ecx
f0104bbe:	c1 e9 18             	shr    $0x18,%ecx
f0104bc1:	88 4c d0 07          	mov    %cl,0x7(%eax,%edx,8)
					sizeof(struct Taskstate), 0);
	gdt[(GD_TSS0 >> 3) + cpuid].sd_s = 0;
f0104bc5:	c6 44 d0 05 89       	movb   $0x89,0x5(%eax,%edx,8)
}

static __inline void
ltr(uint16_t sel)
{
	__asm __volatile("ltr %0" : : "r" (sel));
f0104bca:	8d 1c dd 28 00 00 00 	lea    0x28(,%ebx,8),%ebx
f0104bd1:	0f 00 db             	ltr    %bx
}  

static __inline void
lidt(void *p)
{
	__asm __volatile("lidt (%0)" : : "r" (p));
f0104bd4:	b8 74 43 12 f0       	mov    $0xf0124374,%eax
f0104bd9:	0f 01 18             	lidtl  (%eax)
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0);

	// Load the IDT
	lidt(&idt_pd);*/
}
f0104bdc:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0104bdf:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0104be2:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0104be5:	89 ec                	mov    %ebp,%esp
f0104be7:	5d                   	pop    %ebp
f0104be8:	c3                   	ret    

f0104be9 <trap_init>:
}


void
trap_init(void)
{
f0104be9:	55                   	push   %ebp
f0104bea:	89 e5                	mov    %esp,%ebp
f0104bec:	83 ec 08             	sub    $0x8,%esp
        extern void handler_ide();
        extern void handler_irq15();


       
        SETGATE(idt[T_DIVIDE],0,GD_KT,handler_divide, 0);
f0104bef:	b8 1c 58 10 f0       	mov    $0xf010581c,%eax
f0104bf4:	66 a3 80 d2 24 f0    	mov    %ax,0xf024d280
f0104bfa:	66 c7 05 82 d2 24 f0 	movw   $0x8,0xf024d282
f0104c01:	08 00 
f0104c03:	c6 05 84 d2 24 f0 00 	movb   $0x0,0xf024d284
f0104c0a:	c6 05 85 d2 24 f0 8e 	movb   $0x8e,0xf024d285
f0104c11:	c1 e8 10             	shr    $0x10,%eax
f0104c14:	66 a3 86 d2 24 f0    	mov    %ax,0xf024d286
        SETGATE(idt[T_DEBUG],0,GD_KT,handler_debug, 0);
f0104c1a:	b8 26 58 10 f0       	mov    $0xf0105826,%eax
f0104c1f:	66 a3 88 d2 24 f0    	mov    %ax,0xf024d288
f0104c25:	66 c7 05 8a d2 24 f0 	movw   $0x8,0xf024d28a
f0104c2c:	08 00 
f0104c2e:	c6 05 8c d2 24 f0 00 	movb   $0x0,0xf024d28c
f0104c35:	c6 05 8d d2 24 f0 8e 	movb   $0x8e,0xf024d28d
f0104c3c:	c1 e8 10             	shr    $0x10,%eax
f0104c3f:	66 a3 8e d2 24 f0    	mov    %ax,0xf024d28e
        SETGATE(idt[T_NMI],0,GD_KT,handler_nmi, 0);
f0104c45:	b8 30 58 10 f0       	mov    $0xf0105830,%eax
f0104c4a:	66 a3 90 d2 24 f0    	mov    %ax,0xf024d290
f0104c50:	66 c7 05 92 d2 24 f0 	movw   $0x8,0xf024d292
f0104c57:	08 00 
f0104c59:	c6 05 94 d2 24 f0 00 	movb   $0x0,0xf024d294
f0104c60:	c6 05 95 d2 24 f0 8e 	movb   $0x8e,0xf024d295
f0104c67:	c1 e8 10             	shr    $0x10,%eax
f0104c6a:	66 a3 96 d2 24 f0    	mov    %ax,0xf024d296
        SETGATE(idt[T_BRKPT],0,GD_KT,handler_brkpt, 3);
f0104c70:	b8 3a 58 10 f0       	mov    $0xf010583a,%eax
f0104c75:	66 a3 98 d2 24 f0    	mov    %ax,0xf024d298
f0104c7b:	66 c7 05 9a d2 24 f0 	movw   $0x8,0xf024d29a
f0104c82:	08 00 
f0104c84:	c6 05 9c d2 24 f0 00 	movb   $0x0,0xf024d29c
f0104c8b:	c6 05 9d d2 24 f0 ee 	movb   $0xee,0xf024d29d
f0104c92:	c1 e8 10             	shr    $0x10,%eax
f0104c95:	66 a3 9e d2 24 f0    	mov    %ax,0xf024d29e
        SETGATE(idt[T_OFLOW],0,GD_KT,handler_oflow, 0);
f0104c9b:	b8 44 58 10 f0       	mov    $0xf0105844,%eax
f0104ca0:	66 a3 a0 d2 24 f0    	mov    %ax,0xf024d2a0
f0104ca6:	66 c7 05 a2 d2 24 f0 	movw   $0x8,0xf024d2a2
f0104cad:	08 00 
f0104caf:	c6 05 a4 d2 24 f0 00 	movb   $0x0,0xf024d2a4
f0104cb6:	c6 05 a5 d2 24 f0 8e 	movb   $0x8e,0xf024d2a5
f0104cbd:	c1 e8 10             	shr    $0x10,%eax
f0104cc0:	66 a3 a6 d2 24 f0    	mov    %ax,0xf024d2a6
        SETGATE(idt[T_BOUND],0,GD_KT,handler_bound, 0);
f0104cc6:	b8 4e 58 10 f0       	mov    $0xf010584e,%eax
f0104ccb:	66 a3 a8 d2 24 f0    	mov    %ax,0xf024d2a8
f0104cd1:	66 c7 05 aa d2 24 f0 	movw   $0x8,0xf024d2aa
f0104cd8:	08 00 
f0104cda:	c6 05 ac d2 24 f0 00 	movb   $0x0,0xf024d2ac
f0104ce1:	c6 05 ad d2 24 f0 8e 	movb   $0x8e,0xf024d2ad
f0104ce8:	c1 e8 10             	shr    $0x10,%eax
f0104ceb:	66 a3 ae d2 24 f0    	mov    %ax,0xf024d2ae
        SETGATE(idt[T_ILLOP],0,GD_KT,handler_illop, 0);
f0104cf1:	b8 58 58 10 f0       	mov    $0xf0105858,%eax
f0104cf6:	66 a3 b0 d2 24 f0    	mov    %ax,0xf024d2b0
f0104cfc:	66 c7 05 b2 d2 24 f0 	movw   $0x8,0xf024d2b2
f0104d03:	08 00 
f0104d05:	c6 05 b4 d2 24 f0 00 	movb   $0x0,0xf024d2b4
f0104d0c:	c6 05 b5 d2 24 f0 8e 	movb   $0x8e,0xf024d2b5
f0104d13:	c1 e8 10             	shr    $0x10,%eax
f0104d16:	66 a3 b6 d2 24 f0    	mov    %ax,0xf024d2b6
        SETGATE(idt[T_DEVICE],0,GD_KT,handler_device, 0);
f0104d1c:	b8 62 58 10 f0       	mov    $0xf0105862,%eax
f0104d21:	66 a3 b8 d2 24 f0    	mov    %ax,0xf024d2b8
f0104d27:	66 c7 05 ba d2 24 f0 	movw   $0x8,0xf024d2ba
f0104d2e:	08 00 
f0104d30:	c6 05 bc d2 24 f0 00 	movb   $0x0,0xf024d2bc
f0104d37:	c6 05 bd d2 24 f0 8e 	movb   $0x8e,0xf024d2bd
f0104d3e:	c1 e8 10             	shr    $0x10,%eax
f0104d41:	66 a3 be d2 24 f0    	mov    %ax,0xf024d2be
        SETGATE(idt[T_DBLFLT],0,GD_KT,handler_dblflt, 0);
f0104d47:	b8 6c 58 10 f0       	mov    $0xf010586c,%eax
f0104d4c:	66 a3 c0 d2 24 f0    	mov    %ax,0xf024d2c0
f0104d52:	66 c7 05 c2 d2 24 f0 	movw   $0x8,0xf024d2c2
f0104d59:	08 00 
f0104d5b:	c6 05 c4 d2 24 f0 00 	movb   $0x0,0xf024d2c4
f0104d62:	c6 05 c5 d2 24 f0 8e 	movb   $0x8e,0xf024d2c5
f0104d69:	c1 e8 10             	shr    $0x10,%eax
f0104d6c:	66 a3 c6 d2 24 f0    	mov    %ax,0xf024d2c6
        SETGATE(idt[T_TSS],0,GD_KT,handler_tss, 0);
f0104d72:	b8 74 58 10 f0       	mov    $0xf0105874,%eax
f0104d77:	66 a3 d0 d2 24 f0    	mov    %ax,0xf024d2d0
f0104d7d:	66 c7 05 d2 d2 24 f0 	movw   $0x8,0xf024d2d2
f0104d84:	08 00 
f0104d86:	c6 05 d4 d2 24 f0 00 	movb   $0x0,0xf024d2d4
f0104d8d:	c6 05 d5 d2 24 f0 8e 	movb   $0x8e,0xf024d2d5
f0104d94:	c1 e8 10             	shr    $0x10,%eax
f0104d97:	66 a3 d6 d2 24 f0    	mov    %ax,0xf024d2d6
        SETGATE(idt[T_SEGNP],0,GD_KT,handler_segnp, 0);
f0104d9d:	b8 7c 58 10 f0       	mov    $0xf010587c,%eax
f0104da2:	66 a3 d8 d2 24 f0    	mov    %ax,0xf024d2d8
f0104da8:	66 c7 05 da d2 24 f0 	movw   $0x8,0xf024d2da
f0104daf:	08 00 
f0104db1:	c6 05 dc d2 24 f0 00 	movb   $0x0,0xf024d2dc
f0104db8:	c6 05 dd d2 24 f0 8e 	movb   $0x8e,0xf024d2dd
f0104dbf:	c1 e8 10             	shr    $0x10,%eax
f0104dc2:	66 a3 de d2 24 f0    	mov    %ax,0xf024d2de
        SETGATE(idt[T_STACK],0,GD_KT,handler_stack, 0);
f0104dc8:	b8 84 58 10 f0       	mov    $0xf0105884,%eax
f0104dcd:	66 a3 e0 d2 24 f0    	mov    %ax,0xf024d2e0
f0104dd3:	66 c7 05 e2 d2 24 f0 	movw   $0x8,0xf024d2e2
f0104dda:	08 00 
f0104ddc:	c6 05 e4 d2 24 f0 00 	movb   $0x0,0xf024d2e4
f0104de3:	c6 05 e5 d2 24 f0 8e 	movb   $0x8e,0xf024d2e5
f0104dea:	c1 e8 10             	shr    $0x10,%eax
f0104ded:	66 a3 e6 d2 24 f0    	mov    %ax,0xf024d2e6
        SETGATE(idt[T_GPFLT],0,GD_KT,handler_gpflt, 0);
f0104df3:	b8 8c 58 10 f0       	mov    $0xf010588c,%eax
f0104df8:	66 a3 e8 d2 24 f0    	mov    %ax,0xf024d2e8
f0104dfe:	66 c7 05 ea d2 24 f0 	movw   $0x8,0xf024d2ea
f0104e05:	08 00 
f0104e07:	c6 05 ec d2 24 f0 00 	movb   $0x0,0xf024d2ec
f0104e0e:	c6 05 ed d2 24 f0 8e 	movb   $0x8e,0xf024d2ed
f0104e15:	c1 e8 10             	shr    $0x10,%eax
f0104e18:	66 a3 ee d2 24 f0    	mov    %ax,0xf024d2ee
        SETGATE(idt[T_PGFLT],0,GD_KT,handler_pgflt, 0);
f0104e1e:	b8 94 58 10 f0       	mov    $0xf0105894,%eax
f0104e23:	66 a3 f0 d2 24 f0    	mov    %ax,0xf024d2f0
f0104e29:	66 c7 05 f2 d2 24 f0 	movw   $0x8,0xf024d2f2
f0104e30:	08 00 
f0104e32:	c6 05 f4 d2 24 f0 00 	movb   $0x0,0xf024d2f4
f0104e39:	c6 05 f5 d2 24 f0 8e 	movb   $0x8e,0xf024d2f5
f0104e40:	c1 e8 10             	shr    $0x10,%eax
f0104e43:	66 a3 f6 d2 24 f0    	mov    %ax,0xf024d2f6
        SETGATE(idt[T_FPERR],0,GD_KT,handler_fperr, 0);
f0104e49:	b8 9c 58 10 f0       	mov    $0xf010589c,%eax
f0104e4e:	66 a3 00 d3 24 f0    	mov    %ax,0xf024d300
f0104e54:	66 c7 05 02 d3 24 f0 	movw   $0x8,0xf024d302
f0104e5b:	08 00 
f0104e5d:	c6 05 04 d3 24 f0 00 	movb   $0x0,0xf024d304
f0104e64:	c6 05 05 d3 24 f0 8e 	movb   $0x8e,0xf024d305
f0104e6b:	c1 e8 10             	shr    $0x10,%eax
f0104e6e:	66 a3 06 d3 24 f0    	mov    %ax,0xf024d306
        SETGATE(idt[T_ALIGN],0,GD_KT,handler_align, 0);
f0104e74:	b8 a6 58 10 f0       	mov    $0xf01058a6,%eax
f0104e79:	66 a3 08 d3 24 f0    	mov    %ax,0xf024d308
f0104e7f:	66 c7 05 0a d3 24 f0 	movw   $0x8,0xf024d30a
f0104e86:	08 00 
f0104e88:	c6 05 0c d3 24 f0 00 	movb   $0x0,0xf024d30c
f0104e8f:	c6 05 0d d3 24 f0 8e 	movb   $0x8e,0xf024d30d
f0104e96:	c1 e8 10             	shr    $0x10,%eax
f0104e99:	66 a3 0e d3 24 f0    	mov    %ax,0xf024d30e
        SETGATE(idt[T_MCHK],0,GD_KT,handler_mchk, 0);
f0104e9f:	b8 b0 58 10 f0       	mov    $0xf01058b0,%eax
f0104ea4:	66 a3 10 d3 24 f0    	mov    %ax,0xf024d310
f0104eaa:	66 c7 05 12 d3 24 f0 	movw   $0x8,0xf024d312
f0104eb1:	08 00 
f0104eb3:	c6 05 14 d3 24 f0 00 	movb   $0x0,0xf024d314
f0104eba:	c6 05 15 d3 24 f0 8e 	movb   $0x8e,0xf024d315
f0104ec1:	c1 e8 10             	shr    $0x10,%eax
f0104ec4:	66 a3 16 d3 24 f0    	mov    %ax,0xf024d316
        SETGATE(idt[T_SIMDERR],0,GD_KT,handler_simderr, 0);
f0104eca:	b8 ba 58 10 f0       	mov    $0xf01058ba,%eax
f0104ecf:	66 a3 18 d3 24 f0    	mov    %ax,0xf024d318
f0104ed5:	66 c7 05 1a d3 24 f0 	movw   $0x8,0xf024d31a
f0104edc:	08 00 
f0104ede:	c6 05 1c d3 24 f0 00 	movb   $0x0,0xf024d31c
f0104ee5:	c6 05 1d d3 24 f0 8e 	movb   $0x8e,0xf024d31d
f0104eec:	c1 e8 10             	shr    $0x10,%eax
f0104eef:	66 a3 1e d3 24 f0    	mov    %ax,0xf024d31e

        SETGATE(idt[T_SYSCALL], 0, GD_KT, handler_syscall, 3);
f0104ef5:	b8 c4 58 10 f0       	mov    $0xf01058c4,%eax
f0104efa:	66 a3 00 d4 24 f0    	mov    %ax,0xf024d400
f0104f00:	66 c7 05 02 d4 24 f0 	movw   $0x8,0xf024d402
f0104f07:	08 00 
f0104f09:	c6 05 04 d4 24 f0 00 	movb   $0x0,0xf024d404
f0104f10:	c6 05 05 d4 24 f0 ee 	movb   $0xee,0xf024d405
f0104f17:	c1 e8 10             	shr    $0x10,%eax
f0104f1a:	66 a3 06 d4 24 f0    	mov    %ax,0xf024d406
        SETGATE(idt[IRQ_OFFSET + IRQ_TIMER], 0, GD_KT, handler_timer, 0);
f0104f20:	b8 ce 58 10 f0       	mov    $0xf01058ce,%eax
f0104f25:	66 a3 80 d3 24 f0    	mov    %ax,0xf024d380
f0104f2b:	66 c7 05 82 d3 24 f0 	movw   $0x8,0xf024d382
f0104f32:	08 00 
f0104f34:	c6 05 84 d3 24 f0 00 	movb   $0x0,0xf024d384
f0104f3b:	c6 05 85 d3 24 f0 8e 	movb   $0x8e,0xf024d385
f0104f42:	c1 e8 10             	shr    $0x10,%eax
f0104f45:	66 a3 86 d3 24 f0    	mov    %ax,0xf024d386
        SETGATE(idt[IRQ_OFFSET + IRQ_KBD], 0, GD_KT, handler_kbd, 0);
f0104f4b:	b8 d8 58 10 f0       	mov    $0xf01058d8,%eax
f0104f50:	66 a3 88 d3 24 f0    	mov    %ax,0xf024d388
f0104f56:	66 c7 05 8a d3 24 f0 	movw   $0x8,0xf024d38a
f0104f5d:	08 00 
f0104f5f:	c6 05 8c d3 24 f0 00 	movb   $0x0,0xf024d38c
f0104f66:	c6 05 8d d3 24 f0 8e 	movb   $0x8e,0xf024d38d
f0104f6d:	c1 e8 10             	shr    $0x10,%eax
f0104f70:	66 a3 8e d3 24 f0    	mov    %ax,0xf024d38e
        SETGATE(idt[IRQ_OFFSET + 2], 0, GD_KT, handler_irq2, 0);
f0104f76:	b8 e2 58 10 f0       	mov    $0xf01058e2,%eax
f0104f7b:	66 a3 90 d3 24 f0    	mov    %ax,0xf024d390
f0104f81:	66 c7 05 92 d3 24 f0 	movw   $0x8,0xf024d392
f0104f88:	08 00 
f0104f8a:	c6 05 94 d3 24 f0 00 	movb   $0x0,0xf024d394
f0104f91:	c6 05 95 d3 24 f0 8e 	movb   $0x8e,0xf024d395
f0104f98:	c1 e8 10             	shr    $0x10,%eax
f0104f9b:	66 a3 96 d3 24 f0    	mov    %ax,0xf024d396
        SETGATE(idt[IRQ_OFFSET + 3], 0, GD_KT, handler_irq3, 0);
f0104fa1:	b8 ec 58 10 f0       	mov    $0xf01058ec,%eax
f0104fa6:	66 a3 98 d3 24 f0    	mov    %ax,0xf024d398
f0104fac:	66 c7 05 9a d3 24 f0 	movw   $0x8,0xf024d39a
f0104fb3:	08 00 
f0104fb5:	c6 05 9c d3 24 f0 00 	movb   $0x0,0xf024d39c
f0104fbc:	c6 05 9d d3 24 f0 8e 	movb   $0x8e,0xf024d39d
f0104fc3:	c1 e8 10             	shr    $0x10,%eax
f0104fc6:	66 a3 9e d3 24 f0    	mov    %ax,0xf024d39e
        SETGATE(idt[IRQ_OFFSET + IRQ_SERIAL], 0, GD_KT, handler_serial, 0);
f0104fcc:	b8 f2 58 10 f0       	mov    $0xf01058f2,%eax
f0104fd1:	66 a3 a0 d3 24 f0    	mov    %ax,0xf024d3a0
f0104fd7:	66 c7 05 a2 d3 24 f0 	movw   $0x8,0xf024d3a2
f0104fde:	08 00 
f0104fe0:	c6 05 a4 d3 24 f0 00 	movb   $0x0,0xf024d3a4
f0104fe7:	c6 05 a5 d3 24 f0 8e 	movb   $0x8e,0xf024d3a5
f0104fee:	c1 e8 10             	shr    $0x10,%eax
f0104ff1:	66 a3 a6 d3 24 f0    	mov    %ax,0xf024d3a6
        SETGATE(idt[IRQ_OFFSET + 5], 0, GD_KT, handler_irq5, 0);
f0104ff7:	b8 f8 58 10 f0       	mov    $0xf01058f8,%eax
f0104ffc:	66 a3 a8 d3 24 f0    	mov    %ax,0xf024d3a8
f0105002:	66 c7 05 aa d3 24 f0 	movw   $0x8,0xf024d3aa
f0105009:	08 00 
f010500b:	c6 05 ac d3 24 f0 00 	movb   $0x0,0xf024d3ac
f0105012:	c6 05 ad d3 24 f0 8e 	movb   $0x8e,0xf024d3ad
f0105019:	c1 e8 10             	shr    $0x10,%eax
f010501c:	66 a3 ae d3 24 f0    	mov    %ax,0xf024d3ae
        SETGATE(idt[IRQ_OFFSET + 6], 0, GD_KT, handler_irq6, 0);
f0105022:	b8 fe 58 10 f0       	mov    $0xf01058fe,%eax
f0105027:	66 a3 b0 d3 24 f0    	mov    %ax,0xf024d3b0
f010502d:	66 c7 05 b2 d3 24 f0 	movw   $0x8,0xf024d3b2
f0105034:	08 00 
f0105036:	c6 05 b4 d3 24 f0 00 	movb   $0x0,0xf024d3b4
f010503d:	c6 05 b5 d3 24 f0 8e 	movb   $0x8e,0xf024d3b5
f0105044:	c1 e8 10             	shr    $0x10,%eax
f0105047:	66 a3 b6 d3 24 f0    	mov    %ax,0xf024d3b6
        SETGATE(idt[IRQ_OFFSET + IRQ_SPURIOUS], 0, GD_KT, handler_spurious, 0);
f010504d:	b8 04 59 10 f0       	mov    $0xf0105904,%eax
f0105052:	66 a3 b8 d3 24 f0    	mov    %ax,0xf024d3b8
f0105058:	66 c7 05 ba d3 24 f0 	movw   $0x8,0xf024d3ba
f010505f:	08 00 
f0105061:	c6 05 bc d3 24 f0 00 	movb   $0x0,0xf024d3bc
f0105068:	c6 05 bd d3 24 f0 8e 	movb   $0x8e,0xf024d3bd
f010506f:	c1 e8 10             	shr    $0x10,%eax
f0105072:	66 a3 be d3 24 f0    	mov    %ax,0xf024d3be
        SETGATE(idt[IRQ_OFFSET + 8], 0, GD_KT, handler_irq8, 0);
f0105078:	b8 0a 59 10 f0       	mov    $0xf010590a,%eax
f010507d:	66 a3 c0 d3 24 f0    	mov    %ax,0xf024d3c0
f0105083:	66 c7 05 c2 d3 24 f0 	movw   $0x8,0xf024d3c2
f010508a:	08 00 
f010508c:	c6 05 c4 d3 24 f0 00 	movb   $0x0,0xf024d3c4
f0105093:	c6 05 c5 d3 24 f0 8e 	movb   $0x8e,0xf024d3c5
f010509a:	c1 e8 10             	shr    $0x10,%eax
f010509d:	66 a3 c6 d3 24 f0    	mov    %ax,0xf024d3c6
        SETGATE(idt[IRQ_OFFSET + 9], 0, GD_KT, handler_irq9, 0);
f01050a3:	b8 10 59 10 f0       	mov    $0xf0105910,%eax
f01050a8:	66 a3 c8 d3 24 f0    	mov    %ax,0xf024d3c8
f01050ae:	66 c7 05 ca d3 24 f0 	movw   $0x8,0xf024d3ca
f01050b5:	08 00 
f01050b7:	c6 05 cc d3 24 f0 00 	movb   $0x0,0xf024d3cc
f01050be:	c6 05 cd d3 24 f0 8e 	movb   $0x8e,0xf024d3cd
f01050c5:	c1 e8 10             	shr    $0x10,%eax
f01050c8:	66 a3 ce d3 24 f0    	mov    %ax,0xf024d3ce
        SETGATE(idt[IRQ_OFFSET + 10], 0, GD_KT, handler_irq10, 0);
f01050ce:	b8 16 59 10 f0       	mov    $0xf0105916,%eax
f01050d3:	66 a3 d0 d3 24 f0    	mov    %ax,0xf024d3d0
f01050d9:	66 c7 05 d2 d3 24 f0 	movw   $0x8,0xf024d3d2
f01050e0:	08 00 
f01050e2:	c6 05 d4 d3 24 f0 00 	movb   $0x0,0xf024d3d4
f01050e9:	c6 05 d5 d3 24 f0 8e 	movb   $0x8e,0xf024d3d5
f01050f0:	c1 e8 10             	shr    $0x10,%eax
f01050f3:	66 a3 d6 d3 24 f0    	mov    %ax,0xf024d3d6
        SETGATE(idt[IRQ_OFFSET + 11], 0, GD_KT, handler_irq11, 0);
f01050f9:	b8 1c 59 10 f0       	mov    $0xf010591c,%eax
f01050fe:	66 a3 d8 d3 24 f0    	mov    %ax,0xf024d3d8
f0105104:	66 c7 05 da d3 24 f0 	movw   $0x8,0xf024d3da
f010510b:	08 00 
f010510d:	c6 05 dc d3 24 f0 00 	movb   $0x0,0xf024d3dc
f0105114:	c6 05 dd d3 24 f0 8e 	movb   $0x8e,0xf024d3dd
f010511b:	c1 e8 10             	shr    $0x10,%eax
f010511e:	66 a3 de d3 24 f0    	mov    %ax,0xf024d3de
        SETGATE(idt[IRQ_OFFSET + 12], 0, GD_KT, handler_irq12, 0);
f0105124:	b8 22 59 10 f0       	mov    $0xf0105922,%eax
f0105129:	66 a3 e0 d3 24 f0    	mov    %ax,0xf024d3e0
f010512f:	66 c7 05 e2 d3 24 f0 	movw   $0x8,0xf024d3e2
f0105136:	08 00 
f0105138:	c6 05 e4 d3 24 f0 00 	movb   $0x0,0xf024d3e4
f010513f:	c6 05 e5 d3 24 f0 8e 	movb   $0x8e,0xf024d3e5
f0105146:	c1 e8 10             	shr    $0x10,%eax
f0105149:	66 a3 e6 d3 24 f0    	mov    %ax,0xf024d3e6
        SETGATE(idt[IRQ_OFFSET + 13], 0, GD_KT, handler_irq13, 0);
f010514f:	b8 28 59 10 f0       	mov    $0xf0105928,%eax
f0105154:	66 a3 e8 d3 24 f0    	mov    %ax,0xf024d3e8
f010515a:	66 c7 05 ea d3 24 f0 	movw   $0x8,0xf024d3ea
f0105161:	08 00 
f0105163:	c6 05 ec d3 24 f0 00 	movb   $0x0,0xf024d3ec
f010516a:	c6 05 ed d3 24 f0 8e 	movb   $0x8e,0xf024d3ed
f0105171:	c1 e8 10             	shr    $0x10,%eax
f0105174:	66 a3 ee d3 24 f0    	mov    %ax,0xf024d3ee
        SETGATE(idt[IRQ_OFFSET + IRQ_IDE], 0, GD_KT, handler_ide, 0);
f010517a:	b8 2e 59 10 f0       	mov    $0xf010592e,%eax
f010517f:	66 a3 f0 d3 24 f0    	mov    %ax,0xf024d3f0
f0105185:	66 c7 05 f2 d3 24 f0 	movw   $0x8,0xf024d3f2
f010518c:	08 00 
f010518e:	c6 05 f4 d3 24 f0 00 	movb   $0x0,0xf024d3f4
f0105195:	c6 05 f5 d3 24 f0 8e 	movb   $0x8e,0xf024d3f5
f010519c:	c1 e8 10             	shr    $0x10,%eax
f010519f:	66 a3 f6 d3 24 f0    	mov    %ax,0xf024d3f6
        SETGATE(idt[IRQ_OFFSET + 15], 0, GD_KT, handler_irq15, 0);
f01051a5:	b8 34 59 10 f0       	mov    $0xf0105934,%eax
f01051aa:	66 a3 f8 d3 24 f0    	mov    %ax,0xf024d3f8
f01051b0:	66 c7 05 fa d3 24 f0 	movw   $0x8,0xf024d3fa
f01051b7:	08 00 
f01051b9:	c6 05 fc d3 24 f0 00 	movb   $0x0,0xf024d3fc
f01051c0:	c6 05 fd d3 24 f0 8e 	movb   $0x8e,0xf024d3fd
f01051c7:	c1 e8 10             	shr    $0x10,%eax
f01051ca:	66 a3 fe d3 24 f0    	mov    %ax,0xf024d3fe
        
	// Per-CPU setup 
	trap_init_percpu();
f01051d0:	e8 6b f9 ff ff       	call   f0104b40 <trap_init_percpu>
}
f01051d5:	c9                   	leave  
f01051d6:	c3                   	ret    

f01051d7 <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f01051d7:	55                   	push   %ebp
f01051d8:	89 e5                	mov    %esp,%ebp
f01051da:	53                   	push   %ebx
f01051db:	83 ec 14             	sub    $0x14,%esp
f01051de:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f01051e1:	8b 03                	mov    (%ebx),%eax
f01051e3:	89 44 24 04          	mov    %eax,0x4(%esp)
f01051e7:	c7 04 24 ea 90 10 f0 	movl   $0xf01090ea,(%esp)
f01051ee:	e8 14 f9 ff ff       	call   f0104b07 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f01051f3:	8b 43 04             	mov    0x4(%ebx),%eax
f01051f6:	89 44 24 04          	mov    %eax,0x4(%esp)
f01051fa:	c7 04 24 f9 90 10 f0 	movl   $0xf01090f9,(%esp)
f0105201:	e8 01 f9 ff ff       	call   f0104b07 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0105206:	8b 43 08             	mov    0x8(%ebx),%eax
f0105209:	89 44 24 04          	mov    %eax,0x4(%esp)
f010520d:	c7 04 24 08 91 10 f0 	movl   $0xf0109108,(%esp)
f0105214:	e8 ee f8 ff ff       	call   f0104b07 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0105219:	8b 43 0c             	mov    0xc(%ebx),%eax
f010521c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105220:	c7 04 24 17 91 10 f0 	movl   $0xf0109117,(%esp)
f0105227:	e8 db f8 ff ff       	call   f0104b07 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f010522c:	8b 43 10             	mov    0x10(%ebx),%eax
f010522f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105233:	c7 04 24 26 91 10 f0 	movl   $0xf0109126,(%esp)
f010523a:	e8 c8 f8 ff ff       	call   f0104b07 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f010523f:	8b 43 14             	mov    0x14(%ebx),%eax
f0105242:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105246:	c7 04 24 35 91 10 f0 	movl   $0xf0109135,(%esp)
f010524d:	e8 b5 f8 ff ff       	call   f0104b07 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0105252:	8b 43 18             	mov    0x18(%ebx),%eax
f0105255:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105259:	c7 04 24 44 91 10 f0 	movl   $0xf0109144,(%esp)
f0105260:	e8 a2 f8 ff ff       	call   f0104b07 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0105265:	8b 43 1c             	mov    0x1c(%ebx),%eax
f0105268:	89 44 24 04          	mov    %eax,0x4(%esp)
f010526c:	c7 04 24 53 91 10 f0 	movl   $0xf0109153,(%esp)
f0105273:	e8 8f f8 ff ff       	call   f0104b07 <cprintf>
}
f0105278:	83 c4 14             	add    $0x14,%esp
f010527b:	5b                   	pop    %ebx
f010527c:	5d                   	pop    %ebp
f010527d:	c3                   	ret    

f010527e <print_trapframe>:
	lidt(&idt_pd);*/
}

void
print_trapframe(struct Trapframe *tf)
{
f010527e:	55                   	push   %ebp
f010527f:	89 e5                	mov    %esp,%ebp
f0105281:	56                   	push   %esi
f0105282:	53                   	push   %ebx
f0105283:	83 ec 10             	sub    $0x10,%esp
f0105286:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f0105289:	e8 30 24 00 00       	call   f01076be <cpunum>
f010528e:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105292:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105296:	c7 04 24 62 91 10 f0 	movl   $0xf0109162,(%esp)
f010529d:	e8 65 f8 ff ff       	call   f0104b07 <cprintf>
	print_regs(&tf->tf_regs);
f01052a2:	89 1c 24             	mov    %ebx,(%esp)
f01052a5:	e8 2d ff ff ff       	call   f01051d7 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f01052aa:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f01052ae:	89 44 24 04          	mov    %eax,0x4(%esp)
f01052b2:	c7 04 24 80 91 10 f0 	movl   $0xf0109180,(%esp)
f01052b9:	e8 49 f8 ff ff       	call   f0104b07 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f01052be:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f01052c2:	89 44 24 04          	mov    %eax,0x4(%esp)
f01052c6:	c7 04 24 93 91 10 f0 	movl   $0xf0109193,(%esp)
f01052cd:	e8 35 f8 ff ff       	call   f0104b07 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f01052d2:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
f01052d5:	83 f8 13             	cmp    $0x13,%eax
f01052d8:	77 09                	ja     f01052e3 <print_trapframe+0x65>
		return excnames[trapno];
f01052da:	8b 14 85 80 94 10 f0 	mov    -0xfef6b80(,%eax,4),%edx
f01052e1:	eb 1c                	jmp    f01052ff <print_trapframe+0x81>
	if (trapno == T_SYSCALL)
f01052e3:	ba a6 91 10 f0       	mov    $0xf01091a6,%edx
f01052e8:	83 f8 30             	cmp    $0x30,%eax
f01052eb:	74 12                	je     f01052ff <print_trapframe+0x81>
		return "System call";
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f01052ed:	8d 48 e0             	lea    -0x20(%eax),%ecx
f01052f0:	ba c1 91 10 f0       	mov    $0xf01091c1,%edx
f01052f5:	83 f9 0f             	cmp    $0xf,%ecx
f01052f8:	76 05                	jbe    f01052ff <print_trapframe+0x81>
f01052fa:	ba b2 91 10 f0       	mov    $0xf01091b2,%edx
{
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f01052ff:	89 54 24 08          	mov    %edx,0x8(%esp)
f0105303:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105307:	c7 04 24 d4 91 10 f0 	movl   $0xf01091d4,(%esp)
f010530e:	e8 f4 f7 ff ff       	call   f0104b07 <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0105313:	3b 1d 80 da 24 f0    	cmp    0xf024da80,%ebx
f0105319:	75 19                	jne    f0105334 <print_trapframe+0xb6>
f010531b:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f010531f:	75 13                	jne    f0105334 <print_trapframe+0xb6>

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f0105321:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f0105324:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105328:	c7 04 24 e6 91 10 f0 	movl   $0xf01091e6,(%esp)
f010532f:	e8 d3 f7 ff ff       	call   f0104b07 <cprintf>
	cprintf("  err  0x%08x", tf->tf_err);
f0105334:	8b 43 2c             	mov    0x2c(%ebx),%eax
f0105337:	89 44 24 04          	mov    %eax,0x4(%esp)
f010533b:	c7 04 24 f5 91 10 f0 	movl   $0xf01091f5,(%esp)
f0105342:	e8 c0 f7 ff ff       	call   f0104b07 <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f0105347:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f010534b:	75 47                	jne    f0105394 <print_trapframe+0x116>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f010534d:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f0105350:	be 0f 92 10 f0       	mov    $0xf010920f,%esi
f0105355:	a8 01                	test   $0x1,%al
f0105357:	75 05                	jne    f010535e <print_trapframe+0xe0>
f0105359:	be 03 92 10 f0       	mov    $0xf0109203,%esi
f010535e:	b9 1f 92 10 f0       	mov    $0xf010921f,%ecx
f0105363:	a8 02                	test   $0x2,%al
f0105365:	75 05                	jne    f010536c <print_trapframe+0xee>
f0105367:	b9 1a 92 10 f0       	mov    $0xf010921a,%ecx
f010536c:	ba 25 92 10 f0       	mov    $0xf0109225,%edx
f0105371:	a8 04                	test   $0x4,%al
f0105373:	75 05                	jne    f010537a <print_trapframe+0xfc>
f0105375:	ba fc 92 10 f0       	mov    $0xf01092fc,%edx
f010537a:	89 74 24 0c          	mov    %esi,0xc(%esp)
f010537e:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0105382:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105386:	c7 04 24 2a 92 10 f0 	movl   $0xf010922a,(%esp)
f010538d:	e8 75 f7 ff ff       	call   f0104b07 <cprintf>
f0105392:	eb 0c                	jmp    f01053a0 <print_trapframe+0x122>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f0105394:	c7 04 24 d9 82 10 f0 	movl   $0xf01082d9,(%esp)
f010539b:	e8 67 f7 ff ff       	call   f0104b07 <cprintf>
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f01053a0:	8b 43 30             	mov    0x30(%ebx),%eax
f01053a3:	89 44 24 04          	mov    %eax,0x4(%esp)
f01053a7:	c7 04 24 39 92 10 f0 	movl   $0xf0109239,(%esp)
f01053ae:	e8 54 f7 ff ff       	call   f0104b07 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f01053b3:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f01053b7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01053bb:	c7 04 24 48 92 10 f0 	movl   $0xf0109248,(%esp)
f01053c2:	e8 40 f7 ff ff       	call   f0104b07 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f01053c7:	8b 43 38             	mov    0x38(%ebx),%eax
f01053ca:	89 44 24 04          	mov    %eax,0x4(%esp)
f01053ce:	c7 04 24 5b 92 10 f0 	movl   $0xf010925b,(%esp)
f01053d5:	e8 2d f7 ff ff       	call   f0104b07 <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f01053da:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f01053de:	74 27                	je     f0105407 <print_trapframe+0x189>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f01053e0:	8b 43 3c             	mov    0x3c(%ebx),%eax
f01053e3:	89 44 24 04          	mov    %eax,0x4(%esp)
f01053e7:	c7 04 24 6a 92 10 f0 	movl   $0xf010926a,(%esp)
f01053ee:	e8 14 f7 ff ff       	call   f0104b07 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f01053f3:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f01053f7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01053fb:	c7 04 24 79 92 10 f0 	movl   $0xf0109279,(%esp)
f0105402:	e8 00 f7 ff ff       	call   f0104b07 <cprintf>
	}
}
f0105407:	83 c4 10             	add    $0x10,%esp
f010540a:	5b                   	pop    %ebx
f010540b:	5e                   	pop    %esi
f010540c:	5d                   	pop    %ebp
f010540d:	c3                   	ret    

f010540e <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f010540e:	55                   	push   %ebp
f010540f:	89 e5                	mov    %esp,%ebp
f0105411:	57                   	push   %edi
f0105412:	56                   	push   %esi
f0105413:	53                   	push   %ebx
f0105414:	83 ec 2c             	sub    $0x2c,%esp
f0105417:	8b 5d 08             	mov    0x8(%ebp),%ebx
f010541a:	0f 20 d0             	mov    %cr2,%eax
f010541d:	89 45 e0             	mov    %eax,-0x20(%ebp)
	fault_va = rcr2();

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.
        if (tf->tf_cs == GD_KT){
f0105420:	66 83 7b 34 08       	cmpw   $0x8,0x34(%ebx)
f0105425:	75 1c                	jne    f0105443 <page_fault_handler+0x35>
            panic("page fault in kernel");
f0105427:	c7 44 24 08 8c 92 10 	movl   $0xf010928c,0x8(%esp)
f010542e:	f0 
f010542f:	c7 44 24 04 81 01 00 	movl   $0x181,0x4(%esp)
f0105436:	00 
f0105437:	c7 04 24 a1 92 10 f0 	movl   $0xf01092a1,(%esp)
f010543e:	e8 42 ac ff ff       	call   f0100085 <_panic>
	//   user_mem_assert() and env_run() are useful here.
	//   To change what the user environment runs, modify 'curenv->env_tf'
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.
        void* call = curenv->env_pgfault_upcall;
f0105443:	e8 76 22 00 00       	call   f01076be <cpunum>
f0105448:	6b c0 74             	imul   $0x74,%eax,%eax
f010544b:	8b 80 28 e0 24 f0    	mov    -0xfdb1fd8(%eax),%eax
f0105451:	8b 40 68             	mov    0x68(%eax),%eax
f0105454:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(!call){
f0105457:	85 c0                	test   %eax,%eax
f0105459:	75 4e                	jne    f01054a9 <page_fault_handler+0x9b>
	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f010545b:	8b 73 30             	mov    0x30(%ebx),%esi
		curenv->env_id, fault_va, tf->tf_eip);
f010545e:	e8 5b 22 00 00       	call   f01076be <cpunum>

	// LAB 4: Your code here.
        void* call = curenv->env_pgfault_upcall;
        if(!call){
	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0105463:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0105467:	8b 55 e0             	mov    -0x20(%ebp),%edx
f010546a:	89 54 24 08          	mov    %edx,0x8(%esp)
f010546e:	be 20 e0 24 f0       	mov    $0xf024e020,%esi
f0105473:	6b c0 74             	imul   $0x74,%eax,%eax
f0105476:	8b 44 30 08          	mov    0x8(%eax,%esi,1),%eax
f010547a:	8b 40 48             	mov    0x48(%eax),%eax
f010547d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105481:	c7 04 24 48 94 10 f0 	movl   $0xf0109448,(%esp)
f0105488:	e8 7a f6 ff ff       	call   f0104b07 <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f010548d:	89 1c 24             	mov    %ebx,(%esp)
f0105490:	e8 e9 fd ff ff       	call   f010527e <print_trapframe>
	env_destroy(curenv);
f0105495:	e8 24 22 00 00       	call   f01076be <cpunum>
f010549a:	6b c0 74             	imul   $0x74,%eax,%eax
f010549d:	8b 44 30 08          	mov    0x8(%eax,%esi,1),%eax
f01054a1:	89 04 24             	mov    %eax,(%esp)
f01054a4:	e8 e6 f0 ff ff       	call   f010458f <env_destroy>
        }
        struct UTrapframe* utf;
        if((tf->tf_esp >= UXSTACKTOP - PGSIZE) && (tf->tf_esp <= UXSTACKTOP - 1))
f01054a9:	8b 43 3c             	mov    0x3c(%ebx),%eax
f01054ac:	8d 90 00 10 40 11    	lea    0x11401000(%eax),%edx
f01054b2:	be cc ff bf ee       	mov    $0xeebfffcc,%esi
f01054b7:	81 fa ff 0f 00 00    	cmp    $0xfff,%edx
f01054bd:	77 03                	ja     f01054c2 <page_fault_handler+0xb4>
           utf = (struct UTrapframe*)(tf->tf_esp - sizeof(struct UTrapframe) - 4);
f01054bf:	8d 70 c8             	lea    -0x38(%eax),%esi
        else
           utf = (struct UTrapframe*)(UXSTACKTOP - sizeof(struct UTrapframe));
        user_mem_assert(curenv,(void*)utf,sizeof(struct UTrapframe),PTE_P|PTE_U|PTE_W);
f01054c2:	e8 f7 21 00 00       	call   f01076be <cpunum>
f01054c7:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
f01054ce:	00 
f01054cf:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
f01054d6:	00 
f01054d7:	89 74 24 04          	mov    %esi,0x4(%esp)
f01054db:	bf 20 e0 24 f0       	mov    $0xf024e020,%edi
f01054e0:	6b c0 74             	imul   $0x74,%eax,%eax
f01054e3:	8b 44 38 08          	mov    0x8(%eax,%edi,1),%eax
f01054e7:	89 04 24             	mov    %eax,(%esp)
f01054ea:	e8 88 cd ff ff       	call   f0102277 <user_mem_assert>
        utf->utf_fault_va = fault_va;
f01054ef:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01054f2:	89 06                	mov    %eax,(%esi)
        utf->utf_err = tf->tf_err;
f01054f4:	8b 43 2c             	mov    0x2c(%ebx),%eax
f01054f7:	89 46 04             	mov    %eax,0x4(%esi)
        utf->utf_regs = tf->tf_regs;
f01054fa:	8b 03                	mov    (%ebx),%eax
f01054fc:	89 46 08             	mov    %eax,0x8(%esi)
f01054ff:	8b 43 04             	mov    0x4(%ebx),%eax
f0105502:	89 46 0c             	mov    %eax,0xc(%esi)
f0105505:	8b 43 08             	mov    0x8(%ebx),%eax
f0105508:	89 46 10             	mov    %eax,0x10(%esi)
f010550b:	8b 43 0c             	mov    0xc(%ebx),%eax
f010550e:	89 46 14             	mov    %eax,0x14(%esi)
f0105511:	8b 43 10             	mov    0x10(%ebx),%eax
f0105514:	89 46 18             	mov    %eax,0x18(%esi)
f0105517:	8b 43 14             	mov    0x14(%ebx),%eax
f010551a:	89 46 1c             	mov    %eax,0x1c(%esi)
f010551d:	8b 43 18             	mov    0x18(%ebx),%eax
f0105520:	89 46 20             	mov    %eax,0x20(%esi)
f0105523:	8b 43 1c             	mov    0x1c(%ebx),%eax
f0105526:	89 46 24             	mov    %eax,0x24(%esi)
        utf->utf_eip = tf->tf_eip;
f0105529:	8b 43 30             	mov    0x30(%ebx),%eax
f010552c:	89 46 28             	mov    %eax,0x28(%esi)
        utf->utf_eflags = tf->tf_eflags;
f010552f:	8b 43 38             	mov    0x38(%ebx),%eax
f0105532:	89 46 2c             	mov    %eax,0x2c(%esi)
        utf->utf_esp = tf->tf_esp;
f0105535:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0105538:	89 46 30             	mov    %eax,0x30(%esi)
        curenv->env_tf.tf_eip = (uint32_t)call;
f010553b:	e8 7e 21 00 00       	call   f01076be <cpunum>
f0105540:	6b c0 74             	imul   $0x74,%eax,%eax
f0105543:	8b 44 38 08          	mov    0x8(%eax,%edi,1),%eax
f0105547:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f010554a:	89 50 30             	mov    %edx,0x30(%eax)
        curenv->env_tf.tf_esp = (uint32_t)utf;
f010554d:	e8 6c 21 00 00       	call   f01076be <cpunum>
f0105552:	6b c0 74             	imul   $0x74,%eax,%eax
f0105555:	8b 44 38 08          	mov    0x8(%eax,%edi,1),%eax
f0105559:	89 70 3c             	mov    %esi,0x3c(%eax)
        env_run(curenv);
f010555c:	e8 5d 21 00 00       	call   f01076be <cpunum>
f0105561:	6b c0 74             	imul   $0x74,%eax,%eax
f0105564:	8b 44 38 08          	mov    0x8(%eax,%edi,1),%eax
f0105568:	89 04 24             	mov    %eax,(%esp)
f010556b:	e8 5a ed ff ff       	call   f01042ca <env_run>

f0105570 <syscall_helper>:
		env_run(curenv);
	else
		sched_yield();
}

uint32_t syscall_helper(struct Trapframe *tf){
f0105570:	55                   	push   %ebp
f0105571:	89 e5                	mov    %esp,%ebp
f0105573:	83 ec 38             	sub    $0x38,%esp
f0105576:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0105579:	89 75 f8             	mov    %esi,-0x8(%ebp)
f010557c:	89 7d fc             	mov    %edi,-0x4(%ebp)
f010557f:	8b 5d 08             	mov    0x8(%ebp),%ebx
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f0105582:	c7 04 24 80 43 12 f0 	movl   $0xf0124380,(%esp)
f0105589:	e8 f7 24 00 00       	call   f0107a85 <spin_lock>
        uint32_t ret = 0;     
        lock_kernel();
        curenv->env_tf = *tf; 
f010558e:	e8 2b 21 00 00       	call   f01076be <cpunum>
f0105593:	6b c0 74             	imul   $0x74,%eax,%eax
f0105596:	8b 80 28 e0 24 f0    	mov    -0xfdb1fd8(%eax),%eax
f010559c:	b9 11 00 00 00       	mov    $0x11,%ecx
f01055a1:	89 c7                	mov    %eax,%edi
f01055a3:	89 de                	mov    %ebx,%esi
f01055a5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
        //tf = &curenv->env_tf;
        ret = syscall(tf->tf_regs.reg_eax,tf->tf_regs.reg_edx,tf->tf_regs.reg_ecx,tf->tf_regs.reg_ebx,tf->tf_regs.reg_edi,0);
f01055a7:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
f01055ae:	00 
f01055af:	8b 03                	mov    (%ebx),%eax
f01055b1:	89 44 24 10          	mov    %eax,0x10(%esp)
f01055b5:	8b 43 10             	mov    0x10(%ebx),%eax
f01055b8:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01055bc:	8b 43 18             	mov    0x18(%ebx),%eax
f01055bf:	89 44 24 08          	mov    %eax,0x8(%esp)
f01055c3:	8b 43 14             	mov    0x14(%ebx),%eax
f01055c6:	89 44 24 04          	mov    %eax,0x4(%esp)
f01055ca:	8b 43 1c             	mov    0x1c(%ebx),%eax
f01055cd:	89 04 24             	mov    %eax,(%esp)
f01055d0:	e8 0b 05 00 00       	call   f0105ae0 <syscall>
f01055d5:	89 c3                	mov    %eax,%ebx
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f01055d7:	c7 04 24 80 43 12 f0 	movl   $0xf0124380,(%esp)
f01055de:	e8 89 23 00 00       	call   f010796c <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f01055e3:	f3 90                	pause  
        //tf->tf_regs.reg_eax = ret;
        unlock_kernel();
        return ret; 
}
f01055e5:	89 d8                	mov    %ebx,%eax
f01055e7:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f01055ea:	8b 75 f8             	mov    -0x8(%ebp),%esi
f01055ed:	8b 7d fc             	mov    -0x4(%ebp),%edi
f01055f0:	89 ec                	mov    %ebp,%esp
f01055f2:	5d                   	pop    %ebp
f01055f3:	c3                   	ret    

f01055f4 <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f01055f4:	55                   	push   %ebp
f01055f5:	89 e5                	mov    %esp,%ebp
f01055f7:	83 ec 38             	sub    $0x38,%esp
f01055fa:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f01055fd:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0105600:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0105603:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f0105606:	fc                   	cld    

	// Halt the CPU if some other CPU has called panic()
	extern char *panicstr;
	if (panicstr)
f0105607:	83 3d a0 de 24 f0 00 	cmpl   $0x0,0xf024dea0
f010560e:	74 01                	je     f0105611 <trap+0x1d>
		asm volatile("hlt");
f0105610:	f4                   	hlt    

static __inline uint32_t
read_eflags(void)
{
        uint32_t eflags;
        __asm __volatile("pushfl; popl %0" : "=r" (eflags));
f0105611:	9c                   	pushf  
f0105612:	58                   	pop    %eax

	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f0105613:	f6 c4 02             	test   $0x2,%ah
f0105616:	74 24                	je     f010563c <trap+0x48>
f0105618:	c7 44 24 0c ad 92 10 	movl   $0xf01092ad,0xc(%esp)
f010561f:	f0 
f0105620:	c7 44 24 08 4c 86 10 	movl   $0xf010864c,0x8(%esp)
f0105627:	f0 
f0105628:	c7 44 24 04 40 01 00 	movl   $0x140,0x4(%esp)
f010562f:	00 
f0105630:	c7 04 24 a1 92 10 f0 	movl   $0xf01092a1,(%esp)
f0105637:	e8 49 aa ff ff       	call   f0100085 <_panic>

	if ((tf->tf_cs & 3) == 3) {
f010563c:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f0105640:	83 e0 03             	and    $0x3,%eax
f0105643:	83 f8 03             	cmp    $0x3,%eax
f0105646:	0f 85 a9 00 00 00    	jne    f01056f5 <trap+0x101>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f010564c:	c7 04 24 80 43 12 f0 	movl   $0xf0124380,(%esp)
f0105653:	e8 2d 24 00 00       	call   f0107a85 <spin_lock>
		// Trapped from user mode.
		// Acquire the big kernel lock before doing any
		// serious kernel work.
		// LAB 4: Your code here.
                lock_kernel();
		assert(curenv);
f0105658:	e8 61 20 00 00       	call   f01076be <cpunum>
f010565d:	6b c0 74             	imul   $0x74,%eax,%eax
f0105660:	83 b8 28 e0 24 f0 00 	cmpl   $0x0,-0xfdb1fd8(%eax)
f0105667:	75 24                	jne    f010568d <trap+0x99>
f0105669:	c7 44 24 0c c6 92 10 	movl   $0xf01092c6,0xc(%esp)
f0105670:	f0 
f0105671:	c7 44 24 08 4c 86 10 	movl   $0xf010864c,0x8(%esp)
f0105678:	f0 
f0105679:	c7 44 24 04 48 01 00 	movl   $0x148,0x4(%esp)
f0105680:	00 
f0105681:	c7 04 24 a1 92 10 f0 	movl   $0xf01092a1,(%esp)
f0105688:	e8 f8 a9 ff ff       	call   f0100085 <_panic>

		// Garbage collect if current enviroment is a zombie
		if (curenv->env_status == ENV_DYING) {
f010568d:	e8 2c 20 00 00       	call   f01076be <cpunum>
f0105692:	6b c0 74             	imul   $0x74,%eax,%eax
f0105695:	8b 80 28 e0 24 f0    	mov    -0xfdb1fd8(%eax),%eax
f010569b:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f010569f:	75 2e                	jne    f01056cf <trap+0xdb>
			env_free(curenv);
f01056a1:	e8 18 20 00 00       	call   f01076be <cpunum>
f01056a6:	be 20 e0 24 f0       	mov    $0xf024e020,%esi
f01056ab:	6b c0 74             	imul   $0x74,%eax,%eax
f01056ae:	8b 44 30 08          	mov    0x8(%eax,%esi,1),%eax
f01056b2:	89 04 24             	mov    %eax,(%esp)
f01056b5:	e8 cc ec ff ff       	call   f0104386 <env_free>
			curenv = NULL;
f01056ba:	e8 ff 1f 00 00       	call   f01076be <cpunum>
f01056bf:	6b c0 74             	imul   $0x74,%eax,%eax
f01056c2:	c7 44 30 08 00 00 00 	movl   $0x0,0x8(%eax,%esi,1)
f01056c9:	00 
			sched_yield();
f01056ca:	e8 b1 02 00 00       	call   f0105980 <sched_yield>
		}

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f01056cf:	e8 ea 1f 00 00       	call   f01076be <cpunum>
f01056d4:	bb 20 e0 24 f0       	mov    $0xf024e020,%ebx
f01056d9:	6b c0 74             	imul   $0x74,%eax,%eax
f01056dc:	8b 44 18 08          	mov    0x8(%eax,%ebx,1),%eax
f01056e0:	b9 11 00 00 00       	mov    $0x11,%ecx
f01056e5:	89 c7                	mov    %eax,%edi
f01056e7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f01056e9:	e8 d0 1f 00 00       	call   f01076be <cpunum>
f01056ee:	6b c0 74             	imul   $0x74,%eax,%eax
f01056f1:	8b 74 18 08          	mov    0x8(%eax,%ebx,1),%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f01056f5:	89 35 80 da 24 f0    	mov    %esi,0xf024da80
	// LAB 3: Your code here.

	// Handle spurious interrupts
	// The hardware sometimes raises these because of noise on the
	// IRQ line or other reasons. We don't care.
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f01056fb:	8b 46 28             	mov    0x28(%esi),%eax
f01056fe:	83 f8 27             	cmp    $0x27,%eax
f0105701:	75 19                	jne    f010571c <trap+0x128>
		cprintf("Spurious interrupt on irq 7\n");
f0105703:	c7 04 24 cd 92 10 f0 	movl   $0xf01092cd,(%esp)
f010570a:	e8 f8 f3 ff ff       	call   f0104b07 <cprintf>
		print_trapframe(tf);
f010570f:	89 34 24             	mov    %esi,(%esp)
f0105712:	e8 67 fb ff ff       	call   f010527e <print_trapframe>
f0105717:	e9 c0 00 00 00       	jmp    f01057dc <trap+0x1e8>

	// Handle clock interrupts. Don't forget to acknowledge the
	// interrupt using lapic_eoi() before calling the scheduler!
	// LAB 4: Your code here.

        if(tf->tf_trapno == T_PGFLT)
f010571c:	83 f8 0e             	cmp    $0xe,%eax
f010571f:	90                   	nop
f0105720:	75 0b                	jne    f010572d <trap+0x139>
            page_fault_handler(tf);
f0105722:	89 34 24             	mov    %esi,(%esp)
f0105725:	8d 76 00             	lea    0x0(%esi),%esi
f0105728:	e8 e1 fc ff ff       	call   f010540e <page_fault_handler>
	// Unexpected trap: The user process or the kernel has a bug.
        if(tf->tf_trapno == T_BRKPT)
f010572d:	83 7e 28 03          	cmpl   $0x3,0x28(%esi)
f0105731:	75 08                	jne    f010573b <trap+0x147>
            monitor(tf);
f0105733:	89 34 24             	mov    %esi,(%esp)
f0105736:	e8 2e b4 ff ff       	call   f0100b69 <monitor>
        if(tf->tf_trapno == T_DEBUG){
f010573b:	83 7e 28 01          	cmpl   $0x1,0x28(%esi)
f010573f:	90                   	nop
f0105740:	75 0f                	jne    f0105751 <trap+0x15d>
            tf->tf_eflags = tf->tf_eflags & (~0x100);
f0105742:	81 66 38 ff fe ff ff 	andl   $0xfffffeff,0x38(%esi)
            monitor(tf);
f0105749:	89 34 24             	mov    %esi,(%esp)
f010574c:	e8 18 b4 ff ff       	call   f0100b69 <monitor>
        }
        if(tf->tf_trapno == IRQ_OFFSET + IRQ_TIMER){
f0105751:	8b 46 28             	mov    0x28(%esi),%eax
f0105754:	83 f8 20             	cmp    $0x20,%eax
f0105757:	75 0a                	jne    f0105763 <trap+0x16f>
                lapic_eoi();
f0105759:	e8 99 20 00 00       	call   f01077f7 <lapic_eoi>
		sched_yield();
f010575e:	e8 1d 02 00 00       	call   f0105980 <sched_yield>
	}
        if(tf->tf_trapno == T_SYSCALL){
f0105763:	83 f8 30             	cmp    $0x30,%eax
f0105766:	75 33                	jne    f010579b <trap+0x1a7>
		tf->tf_regs.reg_eax = syscall(tf->tf_regs.reg_eax,tf->tf_regs.reg_edx,tf->tf_regs.reg_ecx,tf->tf_regs.reg_ebx,tf->tf_regs.reg_edi,0);
f0105768:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
f010576f:	00 
f0105770:	8b 06                	mov    (%esi),%eax
f0105772:	89 44 24 10          	mov    %eax,0x10(%esp)
f0105776:	8b 46 10             	mov    0x10(%esi),%eax
f0105779:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010577d:	8b 46 18             	mov    0x18(%esi),%eax
f0105780:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105784:	8b 46 14             	mov    0x14(%esi),%eax
f0105787:	89 44 24 04          	mov    %eax,0x4(%esp)
f010578b:	8b 46 1c             	mov    0x1c(%esi),%eax
f010578e:	89 04 24             	mov    %eax,(%esp)
f0105791:	e8 4a 03 00 00       	call   f0105ae0 <syscall>
f0105796:	89 46 1c             	mov    %eax,0x1c(%esi)
f0105799:	eb 41                	jmp    f01057dc <trap+0x1e8>
                return;
	}
	print_trapframe(tf);
f010579b:	89 34 24             	mov    %esi,(%esp)
f010579e:	e8 db fa ff ff       	call   f010527e <print_trapframe>
	if (tf->tf_cs == GD_KT)
f01057a3:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f01057a8:	75 1c                	jne    f01057c6 <trap+0x1d2>
		panic("unhandled trap in kernel");
f01057aa:	c7 44 24 08 ea 92 10 	movl   $0xf01092ea,0x8(%esp)
f01057b1:	f0 
f01057b2:	c7 44 24 04 2a 01 00 	movl   $0x12a,0x4(%esp)
f01057b9:	00 
f01057ba:	c7 04 24 a1 92 10 f0 	movl   $0xf01092a1,(%esp)
f01057c1:	e8 bf a8 ff ff       	call   f0100085 <_panic>
	else {
		env_destroy(curenv);
f01057c6:	e8 f3 1e 00 00       	call   f01076be <cpunum>
f01057cb:	6b c0 74             	imul   $0x74,%eax,%eax
f01057ce:	8b 80 28 e0 24 f0    	mov    -0xfdb1fd8(%eax),%eax
f01057d4:	89 04 24             	mov    %eax,(%esp)
f01057d7:	e8 b3 ed ff ff       	call   f010458f <env_destroy>
	trap_dispatch(tf);

	// If we made it to this point, then no other environment was
	// scheduled, so we should return to the current environment
	// if doing so makes sense.
	if (curenv && curenv->env_status == ENV_RUNNING)
f01057dc:	e8 dd 1e 00 00       	call   f01076be <cpunum>
f01057e1:	6b c0 74             	imul   $0x74,%eax,%eax
f01057e4:	83 b8 28 e0 24 f0 00 	cmpl   $0x0,-0xfdb1fd8(%eax)
f01057eb:	74 2a                	je     f0105817 <trap+0x223>
f01057ed:	e8 cc 1e 00 00       	call   f01076be <cpunum>
f01057f2:	6b c0 74             	imul   $0x74,%eax,%eax
f01057f5:	8b 80 28 e0 24 f0    	mov    -0xfdb1fd8(%eax),%eax
f01057fb:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f01057ff:	75 16                	jne    f0105817 <trap+0x223>
		env_run(curenv);
f0105801:	e8 b8 1e 00 00       	call   f01076be <cpunum>
f0105806:	6b c0 74             	imul   $0x74,%eax,%eax
f0105809:	8b 80 28 e0 24 f0    	mov    -0xfdb1fd8(%eax),%eax
f010580f:	89 04 24             	mov    %eax,(%esp)
f0105812:	e8 b3 ea ff ff       	call   f01042ca <env_run>
	else
		sched_yield();
f0105817:	e8 64 01 00 00       	call   f0105980 <sched_yield>

f010581c <handler_divide>:
.text

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */
TRAPHANDLER_NOEC(handler_divide, T_DIVIDE)
f010581c:	6a 00                	push   $0x0
f010581e:	6a 00                	push   $0x0
f0105820:	e9 49 01 00 00       	jmp    f010596e <_alltraps>
f0105825:	90                   	nop

f0105826 <handler_debug>:
TRAPHANDLER_NOEC(handler_debug, T_DEBUG)
f0105826:	6a 00                	push   $0x0
f0105828:	6a 01                	push   $0x1
f010582a:	e9 3f 01 00 00       	jmp    f010596e <_alltraps>
f010582f:	90                   	nop

f0105830 <handler_nmi>:
TRAPHANDLER_NOEC(handler_nmi, T_NMI)
f0105830:	6a 00                	push   $0x0
f0105832:	6a 02                	push   $0x2
f0105834:	e9 35 01 00 00       	jmp    f010596e <_alltraps>
f0105839:	90                   	nop

f010583a <handler_brkpt>:
TRAPHANDLER_NOEC(handler_brkpt, T_BRKPT)
f010583a:	6a 00                	push   $0x0
f010583c:	6a 03                	push   $0x3
f010583e:	e9 2b 01 00 00       	jmp    f010596e <_alltraps>
f0105843:	90                   	nop

f0105844 <handler_oflow>:
TRAPHANDLER_NOEC(handler_oflow, T_OFLOW)
f0105844:	6a 00                	push   $0x0
f0105846:	6a 04                	push   $0x4
f0105848:	e9 21 01 00 00       	jmp    f010596e <_alltraps>
f010584d:	90                   	nop

f010584e <handler_bound>:
TRAPHANDLER_NOEC(handler_bound, T_BOUND)
f010584e:	6a 00                	push   $0x0
f0105850:	6a 05                	push   $0x5
f0105852:	e9 17 01 00 00       	jmp    f010596e <_alltraps>
f0105857:	90                   	nop

f0105858 <handler_illop>:
TRAPHANDLER_NOEC(handler_illop, T_ILLOP)
f0105858:	6a 00                	push   $0x0
f010585a:	6a 06                	push   $0x6
f010585c:	e9 0d 01 00 00       	jmp    f010596e <_alltraps>
f0105861:	90                   	nop

f0105862 <handler_device>:
TRAPHANDLER_NOEC(handler_device, T_DEVICE)
f0105862:	6a 00                	push   $0x0
f0105864:	6a 07                	push   $0x7
f0105866:	e9 03 01 00 00       	jmp    f010596e <_alltraps>
f010586b:	90                   	nop

f010586c <handler_dblflt>:
TRAPHANDLER(handler_dblflt, T_DBLFLT)
f010586c:	6a 08                	push   $0x8
f010586e:	e9 fb 00 00 00       	jmp    f010596e <_alltraps>
f0105873:	90                   	nop

f0105874 <handler_tss>:
TRAPHANDLER(handler_tss, T_TSS)
f0105874:	6a 0a                	push   $0xa
f0105876:	e9 f3 00 00 00       	jmp    f010596e <_alltraps>
f010587b:	90                   	nop

f010587c <handler_segnp>:
TRAPHANDLER(handler_segnp, T_SEGNP)
f010587c:	6a 0b                	push   $0xb
f010587e:	e9 eb 00 00 00       	jmp    f010596e <_alltraps>
f0105883:	90                   	nop

f0105884 <handler_stack>:
TRAPHANDLER(handler_stack, T_STACK)
f0105884:	6a 0c                	push   $0xc
f0105886:	e9 e3 00 00 00       	jmp    f010596e <_alltraps>
f010588b:	90                   	nop

f010588c <handler_gpflt>:
TRAPHANDLER(handler_gpflt, T_GPFLT)
f010588c:	6a 0d                	push   $0xd
f010588e:	e9 db 00 00 00       	jmp    f010596e <_alltraps>
f0105893:	90                   	nop

f0105894 <handler_pgflt>:
TRAPHANDLER(handler_pgflt, T_PGFLT)
f0105894:	6a 0e                	push   $0xe
f0105896:	e9 d3 00 00 00       	jmp    f010596e <_alltraps>
f010589b:	90                   	nop

f010589c <handler_fperr>:
TRAPHANDLER_NOEC(handler_fperr, T_FPERR)
f010589c:	6a 00                	push   $0x0
f010589e:	6a 10                	push   $0x10
f01058a0:	e9 c9 00 00 00       	jmp    f010596e <_alltraps>
f01058a5:	90                   	nop

f01058a6 <handler_align>:
TRAPHANDLER_NOEC(handler_align, T_ALIGN)
f01058a6:	6a 00                	push   $0x0
f01058a8:	6a 11                	push   $0x11
f01058aa:	e9 bf 00 00 00       	jmp    f010596e <_alltraps>
f01058af:	90                   	nop

f01058b0 <handler_mchk>:
TRAPHANDLER_NOEC(handler_mchk, T_MCHK)
f01058b0:	6a 00                	push   $0x0
f01058b2:	6a 12                	push   $0x12
f01058b4:	e9 b5 00 00 00       	jmp    f010596e <_alltraps>
f01058b9:	90                   	nop

f01058ba <handler_simderr>:
TRAPHANDLER_NOEC(handler_simderr, T_SIMDERR)
f01058ba:	6a 00                	push   $0x0
f01058bc:	6a 13                	push   $0x13
f01058be:	e9 ab 00 00 00       	jmp    f010596e <_alltraps>
f01058c3:	90                   	nop

f01058c4 <handler_syscall>:

TRAPHANDLER_NOEC(handler_syscall, T_SYSCALL);	
f01058c4:	6a 00                	push   $0x0
f01058c6:	6a 30                	push   $0x30
f01058c8:	e9 a1 00 00 00       	jmp    f010596e <_alltraps>
f01058cd:	90                   	nop

f01058ce <handler_timer>:

TRAPHANDLER_NOEC(handler_timer,IRQ_OFFSET + IRQ_TIMER);
f01058ce:	6a 00                	push   $0x0
f01058d0:	6a 20                	push   $0x20
f01058d2:	e9 97 00 00 00       	jmp    f010596e <_alltraps>
f01058d7:	90                   	nop

f01058d8 <handler_kbd>:
TRAPHANDLER_NOEC(handler_kbd,IRQ_OFFSET + IRQ_KBD);
f01058d8:	6a 00                	push   $0x0
f01058da:	6a 21                	push   $0x21
f01058dc:	e9 8d 00 00 00       	jmp    f010596e <_alltraps>
f01058e1:	90                   	nop

f01058e2 <handler_irq2>:
TRAPHANDLER_NOEC(handler_irq2,IRQ_OFFSET + 2);
f01058e2:	6a 00                	push   $0x0
f01058e4:	6a 22                	push   $0x22
f01058e6:	e9 83 00 00 00       	jmp    f010596e <_alltraps>
f01058eb:	90                   	nop

f01058ec <handler_irq3>:
TRAPHANDLER_NOEC(handler_irq3,IRQ_OFFSET + 3);
f01058ec:	6a 00                	push   $0x0
f01058ee:	6a 23                	push   $0x23
f01058f0:	eb 7c                	jmp    f010596e <_alltraps>

f01058f2 <handler_serial>:
TRAPHANDLER_NOEC(handler_serial,IRQ_OFFSET + IRQ_SERIAL);
f01058f2:	6a 00                	push   $0x0
f01058f4:	6a 24                	push   $0x24
f01058f6:	eb 76                	jmp    f010596e <_alltraps>

f01058f8 <handler_irq5>:
TRAPHANDLER_NOEC(handler_irq5,IRQ_OFFSET + 5);
f01058f8:	6a 00                	push   $0x0
f01058fa:	6a 25                	push   $0x25
f01058fc:	eb 70                	jmp    f010596e <_alltraps>

f01058fe <handler_irq6>:
TRAPHANDLER_NOEC(handler_irq6,IRQ_OFFSET + 6);
f01058fe:	6a 00                	push   $0x0
f0105900:	6a 26                	push   $0x26
f0105902:	eb 6a                	jmp    f010596e <_alltraps>

f0105904 <handler_spurious>:
TRAPHANDLER_NOEC(handler_spurious,IRQ_OFFSET + IRQ_SPURIOUS);
f0105904:	6a 00                	push   $0x0
f0105906:	6a 27                	push   $0x27
f0105908:	eb 64                	jmp    f010596e <_alltraps>

f010590a <handler_irq8>:
TRAPHANDLER_NOEC(handler_irq8,IRQ_OFFSET + 8);
f010590a:	6a 00                	push   $0x0
f010590c:	6a 28                	push   $0x28
f010590e:	eb 5e                	jmp    f010596e <_alltraps>

f0105910 <handler_irq9>:
TRAPHANDLER_NOEC(handler_irq9,IRQ_OFFSET + 9);
f0105910:	6a 00                	push   $0x0
f0105912:	6a 29                	push   $0x29
f0105914:	eb 58                	jmp    f010596e <_alltraps>

f0105916 <handler_irq10>:
TRAPHANDLER_NOEC(handler_irq10,IRQ_OFFSET + 10);
f0105916:	6a 00                	push   $0x0
f0105918:	6a 2a                	push   $0x2a
f010591a:	eb 52                	jmp    f010596e <_alltraps>

f010591c <handler_irq11>:
TRAPHANDLER_NOEC(handler_irq11,IRQ_OFFSET + 11);
f010591c:	6a 00                	push   $0x0
f010591e:	6a 2b                	push   $0x2b
f0105920:	eb 4c                	jmp    f010596e <_alltraps>

f0105922 <handler_irq12>:
TRAPHANDLER_NOEC(handler_irq12,IRQ_OFFSET + 12);
f0105922:	6a 00                	push   $0x0
f0105924:	6a 2c                	push   $0x2c
f0105926:	eb 46                	jmp    f010596e <_alltraps>

f0105928 <handler_irq13>:
TRAPHANDLER_NOEC(handler_irq13,IRQ_OFFSET + 13);
f0105928:	6a 00                	push   $0x0
f010592a:	6a 2d                	push   $0x2d
f010592c:	eb 40                	jmp    f010596e <_alltraps>

f010592e <handler_ide>:
TRAPHANDLER_NOEC(handler_ide,IRQ_OFFSET + IRQ_IDE);
f010592e:	6a 00                	push   $0x0
f0105930:	6a 2e                	push   $0x2e
f0105932:	eb 3a                	jmp    f010596e <_alltraps>

f0105934 <handler_irq15>:
TRAPHANDLER_NOEC(handler_irq15,IRQ_OFFSET + 15);
f0105934:	6a 00                	push   $0x0
f0105936:	6a 2f                	push   $0x2f
f0105938:	eb 34                	jmp    f010596e <_alltraps>

f010593a <sysenter_handler>:
.align 2;
sysenter_handler:
/*
 * Lab 3: Your code here for system call handling
 */
    pushl $GD_UD | 3
f010593a:	6a 23                	push   $0x23
    pushl %ebp
f010593c:	55                   	push   %ebp
    pushfl
f010593d:	9c                   	pushf  
    pushl $GD_UT | 3
f010593e:	6a 1b                	push   $0x1b
    pushl %esi
f0105940:	56                   	push   %esi
    pushl $0
f0105941:	6a 00                	push   $0x0
    pushl $T_SYSCALL
f0105943:	6a 30                	push   $0x30
    pushl %ds
f0105945:	1e                   	push   %ds
    pushl %es
f0105946:	06                   	push   %es
    pushal
f0105947:	60                   	pusha  
    movl $GD_KD, %eax
f0105948:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax,%ds
f010594d:	8e d8                	mov    %eax,%ds
    movw %ax,%es
f010594f:	8e c0                	mov    %eax,%es
    pushl %esp
f0105951:	54                   	push   %esp
    call syscall_helper
f0105952:	e8 19 fc ff ff       	call   f0105570 <syscall_helper>
    popl %esp
f0105957:	5c                   	pop    %esp
    //popal
    popl %edi
f0105958:	5f                   	pop    %edi
    popl %esi
f0105959:	5e                   	pop    %esi
    popl %ebp
f010595a:	5d                   	pop    %ebp
    popl %ebx
f010595b:	5b                   	pop    %ebx
    popl %ebx
f010595c:	5b                   	pop    %ebx
    popl %edx
f010595d:	5a                   	pop    %edx
    popl %ecx
f010595e:	59                   	pop    %ecx
    addl $0x4,%esp
f010595f:	83 c4 04             	add    $0x4,%esp

    popl %es
f0105962:	07                   	pop    %es
    popl %ds
f0105963:	1f                   	pop    %ds
    addl $0x8,%esp
f0105964:	83 c4 08             	add    $0x8,%esp
    movl %esi,%edx
f0105967:	89 f2                	mov    %esi,%edx
    movl %ebp,%ecx
f0105969:	89 e9                	mov    %ebp,%ecx
    sti  //open interrupt
f010596b:	fb                   	sti    
    sysexit
f010596c:	0f 35                	sysexit 

f010596e <_alltraps>:

/*
 * Lab 3: Your code here for _alltraps
 */
_alltraps:
    pushl %ds
f010596e:	1e                   	push   %ds
    pushl %es
f010596f:	06                   	push   %es
    pushal
f0105970:	60                   	pusha  
    movl $GD_KD, %eax
f0105971:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax,%ds
f0105976:	8e d8                	mov    %eax,%ds
    movw %ax,%es
f0105978:	8e c0                	mov    %eax,%es
    pushl %esp
f010597a:	54                   	push   %esp
    call trap
f010597b:	e8 74 fc ff ff       	call   f01055f4 <trap>

f0105980 <sched_yield>:


// Choose a user environment to run and run it.
void
sched_yield(void)
{
f0105980:	55                   	push   %ebp
f0105981:	89 e5                	mov    %esp,%ebp
f0105983:	53                   	push   %ebx
f0105984:	83 ec 14             	sub    $0x14,%esp
	// LAB 4: Your code here.
        uint32_t env_id = 0;
        uint32_t next_id = 0;
        uint32_t high_prior_id = 0;
        uint32_t max_prior = 0;
        if(curenv)
f0105987:	e8 32 1d 00 00       	call   f01076be <cpunum>
f010598c:	6b d0 74             	imul   $0x74,%eax,%edx
f010598f:	b8 00 00 00 00       	mov    $0x0,%eax
f0105994:	83 ba 28 e0 24 f0 00 	cmpl   $0x0,-0xfdb1fd8(%edx)
f010599b:	74 16                	je     f01059b3 <sched_yield+0x33>
            env_id = ENVX(curenv->env_id);   
f010599d:	e8 1c 1d 00 00       	call   f01076be <cpunum>
f01059a2:	6b c0 74             	imul   $0x74,%eax,%eax
f01059a5:	8b 80 28 e0 24 f0    	mov    -0xfdb1fd8(%eax),%eax
f01059ab:	8b 40 48             	mov    0x48(%eax),%eax
f01059ae:	25 ff 03 00 00       	and    $0x3ff,%eax
        next_id = env_id;
        for(i = 0;i < NENV ;i++){
           next_id = (next_id + 1) % NENV;
           if(envs[next_id].env_type != ENV_TYPE_IDLE &&
f01059b3:	8b 1d 5c d2 24 f0    	mov    0xf024d25c,%ebx
f01059b9:	ba 00 00 00 00       	mov    $0x0,%edx
        uint32_t max_prior = 0;
        if(curenv)
            env_id = ENVX(curenv->env_id);   
        next_id = env_id;
        for(i = 0;i < NENV ;i++){
           next_id = (next_id + 1) % NENV;
f01059be:	83 c0 01             	add    $0x1,%eax
f01059c1:	25 ff 03 00 00       	and    $0x3ff,%eax
           if(envs[next_id].env_type != ENV_TYPE_IDLE &&
f01059c6:	89 c1                	mov    %eax,%ecx
f01059c8:	c1 e1 07             	shl    $0x7,%ecx
f01059cb:	8d 0c 81             	lea    (%ecx,%eax,4),%ecx
f01059ce:	8d 0c 0b             	lea    (%ebx,%ecx,1),%ecx
f01059d1:	83 79 50 01          	cmpl   $0x1,0x50(%ecx)
f01059d5:	74 0e                	je     f01059e5 <sched_yield+0x65>
               envs[next_id].env_status == ENV_RUNNABLE){
f01059d7:	83 79 54 02          	cmpl   $0x2,0x54(%ecx)
f01059db:	75 08                	jne    f01059e5 <sched_yield+0x65>
                //cprintf("next_id:%d\n",next_id);
                env_run(&envs[next_id]);
f01059dd:	89 0c 24             	mov    %ecx,(%esp)
f01059e0:	e8 e5 e8 ff ff       	call   f01042ca <env_run>
        uint32_t high_prior_id = 0;
        uint32_t max_prior = 0;
        if(curenv)
            env_id = ENVX(curenv->env_id);   
        next_id = env_id;
        for(i = 0;i < NENV ;i++){
f01059e5:	83 c2 01             	add    $0x1,%edx
f01059e8:	81 fa 00 04 00 00    	cmp    $0x400,%edx
f01059ee:	75 ce                	jne    f01059be <sched_yield+0x3e>
                //cprintf("next_id:%d\n",next_id);
                env_run(&envs[next_id]);
                break;
           }
        }
        if(curenv && curenv->env_type != ENV_TYPE_IDLE && curenv->env_status == ENV_RUNNING)
f01059f0:	e8 c9 1c 00 00       	call   f01076be <cpunum>
f01059f5:	6b c0 74             	imul   $0x74,%eax,%eax
f01059f8:	83 b8 28 e0 24 f0 00 	cmpl   $0x0,-0xfdb1fd8(%eax)
f01059ff:	74 14                	je     f0105a15 <sched_yield+0x95>
f0105a01:	e8 b8 1c 00 00       	call   f01076be <cpunum>
f0105a06:	6b c0 74             	imul   $0x74,%eax,%eax
f0105a09:	8b 80 28 e0 24 f0    	mov    -0xfdb1fd8(%eax),%eax
f0105a0f:	83 78 50 01          	cmpl   $0x1,0x50(%eax)
f0105a13:	75 0f                	jne    f0105a24 <sched_yield+0xa4>
            env_run(curenv);*/
	// For debugging and testing purposes, if there are no
	// runnable environments other than the idle environments,
	// drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
		if (envs[i].env_type != ENV_TYPE_IDLE &&
f0105a15:	8b 1d 5c d2 24 f0    	mov    0xf024d25c,%ebx
f0105a1b:	89 d8                	mov    %ebx,%eax
f0105a1d:	ba 00 00 00 00       	mov    $0x0,%edx
f0105a22:	eb 2a                	jmp    f0105a4e <sched_yield+0xce>
                //cprintf("next_id:%d\n",next_id);
                env_run(&envs[next_id]);
                break;
           }
        }
        if(curenv && curenv->env_type != ENV_TYPE_IDLE && curenv->env_status == ENV_RUNNING)
f0105a24:	e8 95 1c 00 00       	call   f01076be <cpunum>
f0105a29:	6b c0 74             	imul   $0x74,%eax,%eax
f0105a2c:	8b 80 28 e0 24 f0    	mov    -0xfdb1fd8(%eax),%eax
f0105a32:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0105a36:	75 dd                	jne    f0105a15 <sched_yield+0x95>
            env_run(curenv);
f0105a38:	e8 81 1c 00 00       	call   f01076be <cpunum>
f0105a3d:	6b c0 74             	imul   $0x74,%eax,%eax
f0105a40:	8b 80 28 e0 24 f0    	mov    -0xfdb1fd8(%eax),%eax
f0105a46:	89 04 24             	mov    %eax,(%esp)
f0105a49:	e8 7c e8 ff ff       	call   f01042ca <env_run>
            env_run(curenv);*/
	// For debugging and testing purposes, if there are no
	// runnable environments other than the idle environments,
	// drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
		if (envs[i].env_type != ENV_TYPE_IDLE &&
f0105a4e:	83 78 50 01          	cmpl   $0x1,0x50(%eax)
f0105a52:	74 0b                	je     f0105a5f <sched_yield+0xdf>
f0105a54:	8b 48 54             	mov    0x54(%eax),%ecx
f0105a57:	83 e9 02             	sub    $0x2,%ecx
f0105a5a:	83 f9 01             	cmp    $0x1,%ecx
f0105a5d:	76 12                	jbe    f0105a71 <sched_yield+0xf1>
        if(curenv && curenv->env_type != ENV_TYPE_IDLE && curenv->env_status == ENV_RUNNING)
            env_run(curenv);*/
	// For debugging and testing purposes, if there are no
	// runnable environments other than the idle environments,
	// drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0105a5f:	83 c2 01             	add    $0x1,%edx
f0105a62:	05 84 00 00 00       	add    $0x84,%eax
f0105a67:	81 fa 00 04 00 00    	cmp    $0x400,%edx
f0105a6d:	75 df                	jne    f0105a4e <sched_yield+0xce>
f0105a6f:	eb 08                	jmp    f0105a79 <sched_yield+0xf9>
		if (envs[i].env_type != ENV_TYPE_IDLE &&
		    (envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING))
			break;
	}
	if (i == NENV) {
f0105a71:	81 fa 00 04 00 00    	cmp    $0x400,%edx
f0105a77:	75 1a                	jne    f0105a93 <sched_yield+0x113>
		cprintf("No more runnable environments!\n");
f0105a79:	c7 04 24 d0 94 10 f0 	movl   $0xf01094d0,(%esp)
f0105a80:	e8 82 f0 ff ff       	call   f0104b07 <cprintf>
		while (1)
			monitor(NULL);
f0105a85:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0105a8c:	e8 d8 b0 ff ff       	call   f0100b69 <monitor>
f0105a91:	eb f2                	jmp    f0105a85 <sched_yield+0x105>
	}

	// Run this CPU's idle environment when nothing else is runnable.
	idle = &envs[cpunum()];
f0105a93:	e8 26 1c 00 00       	call   f01076be <cpunum>
f0105a98:	69 c0 84 00 00 00    	imul   $0x84,%eax,%eax
f0105a9e:	01 c3                	add    %eax,%ebx
	if (!(idle->env_status == ENV_RUNNABLE || idle->env_status == ENV_RUNNING))
f0105aa0:	8b 43 54             	mov    0x54(%ebx),%eax
f0105aa3:	83 e8 02             	sub    $0x2,%eax
f0105aa6:	83 f8 01             	cmp    $0x1,%eax
f0105aa9:	76 25                	jbe    f0105ad0 <sched_yield+0x150>
		panic("CPU %d: No idle environment!", cpunum());
f0105aab:	e8 0e 1c 00 00       	call   f01076be <cpunum>
f0105ab0:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105ab4:	c7 44 24 08 f0 94 10 	movl   $0xf01094f0,0x8(%esp)
f0105abb:	f0 
f0105abc:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f0105ac3:	00 
f0105ac4:	c7 04 24 0d 95 10 f0 	movl   $0xf010950d,(%esp)
f0105acb:	e8 b5 a5 ff ff       	call   f0100085 <_panic>
	env_run(idle);
f0105ad0:	89 1c 24             	mov    %ebx,(%esp)
f0105ad3:	e8 f2 e7 ff ff       	call   f01042ca <env_run>
	...

f0105ae0 <syscall>:
        return 0;
}
// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0105ae0:	55                   	push   %ebp
f0105ae1:	89 e5                	mov    %esp,%ebp
f0105ae3:	57                   	push   %edi
f0105ae4:	56                   	push   %esi
f0105ae5:	53                   	push   %ebx
f0105ae6:	83 ec 3c             	sub    $0x3c,%esp
f0105ae9:	8b 55 08             	mov    0x8(%ebp),%edx
f0105aec:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105aef:	8b 75 10             	mov    0x10(%ebp),%esi
f0105af2:	8b 7d 18             	mov    0x18(%ebp),%edi
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.
        int32_t ret = 0;
        switch(syscallno){
f0105af5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0105afa:	83 fa 0f             	cmp    $0xf,%edx
f0105afd:	0f 87 8c 06 00 00    	ja     f010618f <syscall+0x6af>
f0105b03:	ff 24 95 64 95 10 f0 	jmp    *-0xfef6a9c(,%edx,4)
sys_cputs(const char *s, size_t len)
{
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.       
	// LAB 3: Your code here.
        user_mem_assert(curenv,s,len,PTE_U);
f0105b0a:	e8 af 1b 00 00       	call   f01076be <cpunum>
f0105b0f:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f0105b16:	00 
f0105b17:	89 74 24 08          	mov    %esi,0x8(%esp)
f0105b1b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105b1f:	6b c0 74             	imul   $0x74,%eax,%eax
f0105b22:	8b 80 28 e0 24 f0    	mov    -0xfdb1fd8(%eax),%eax
f0105b28:	89 04 24             	mov    %eax,(%esp)
f0105b2b:	e8 47 c7 ff ff       	call   f0102277 <user_mem_assert>
	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f0105b30:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0105b34:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105b38:	c7 04 24 1a 95 10 f0 	movl   $0xf010951a,(%esp)
f0105b3f:	e8 c3 ef ff ff       	call   f0104b07 <cprintf>
f0105b44:	b8 00 00 00 00       	mov    $0x0,%eax
f0105b49:	e9 41 06 00 00       	jmp    f010618f <syscall+0x6af>
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f0105b4e:	e8 5c a9 ff ff       	call   f01004af <cons_getc>
        case SYS_cputs:
          sys_cputs((const char*)a1,(size_t)a2);
          break;
        case SYS_cgetc:
          ret = sys_cgetc();
          break;
f0105b53:	e9 37 06 00 00       	jmp    f010618f <syscall+0x6af>

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f0105b58:	90                   	nop
f0105b59:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0105b60:	e8 59 1b 00 00       	call   f01076be <cpunum>
f0105b65:	6b c0 74             	imul   $0x74,%eax,%eax
f0105b68:	8b 80 28 e0 24 f0    	mov    -0xfdb1fd8(%eax),%eax
f0105b6e:	8b 40 48             	mov    0x48(%eax),%eax
        case SYS_cgetc:
          ret = sys_cgetc();
          break;
        case SYS_getenvid:
          ret = sys_getenvid();
          break;
f0105b71:	e9 19 06 00 00       	jmp    f010618f <syscall+0x6af>
{
        
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f0105b76:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0105b7d:	00 
f0105b7e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0105b81:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105b85:	89 1c 24             	mov    %ebx,(%esp)
f0105b88:	e8 4b e6 ff ff       	call   f01041d8 <envid2env>
f0105b8d:	85 c0                	test   %eax,%eax
f0105b8f:	0f 88 fa 05 00 00    	js     f010618f <syscall+0x6af>
		return r;
	if (e == curenv)
f0105b95:	e8 24 1b 00 00       	call   f01076be <cpunum>
f0105b9a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0105b9d:	6b c0 74             	imul   $0x74,%eax,%eax
f0105ba0:	39 90 28 e0 24 f0    	cmp    %edx,-0xfdb1fd8(%eax)
f0105ba6:	75 23                	jne    f0105bcb <syscall+0xeb>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f0105ba8:	e8 11 1b 00 00       	call   f01076be <cpunum>
f0105bad:	6b c0 74             	imul   $0x74,%eax,%eax
f0105bb0:	8b 80 28 e0 24 f0    	mov    -0xfdb1fd8(%eax),%eax
f0105bb6:	8b 40 48             	mov    0x48(%eax),%eax
f0105bb9:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105bbd:	c7 04 24 1f 95 10 f0 	movl   $0xf010951f,(%esp)
f0105bc4:	e8 3e ef ff ff       	call   f0104b07 <cprintf>
f0105bc9:	eb 28                	jmp    f0105bf3 <syscall+0x113>
	else
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f0105bcb:	8b 5a 48             	mov    0x48(%edx),%ebx
f0105bce:	e8 eb 1a 00 00       	call   f01076be <cpunum>
f0105bd3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0105bd7:	6b c0 74             	imul   $0x74,%eax,%eax
f0105bda:	8b 80 28 e0 24 f0    	mov    -0xfdb1fd8(%eax),%eax
f0105be0:	8b 40 48             	mov    0x48(%eax),%eax
f0105be3:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105be7:	c7 04 24 3a 95 10 f0 	movl   $0xf010953a,(%esp)
f0105bee:	e8 14 ef ff ff       	call   f0104b07 <cprintf>
	env_destroy(e);
f0105bf3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105bf6:	89 04 24             	mov    %eax,(%esp)
f0105bf9:	e8 91 e9 ff ff       	call   f010458f <env_destroy>
f0105bfe:	b8 00 00 00 00       	mov    $0x0,%eax
f0105c03:	e9 87 05 00 00       	jmp    f010618f <syscall+0x6af>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0105c08:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f0105c0e:	77 20                	ja     f0105c30 <syscall+0x150>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0105c10:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0105c14:	c7 44 24 08 5c 7e 10 	movl   $0xf0107e5c,0x8(%esp)
f0105c1b:	f0 
f0105c1c:	c7 44 24 04 46 00 00 	movl   $0x46,0x4(%esp)
f0105c23:	00 
f0105c24:	c7 04 24 52 95 10 f0 	movl   $0xf0109552,(%esp)
f0105c2b:	e8 55 a4 ff ff       	call   f0100085 <_panic>
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105c30:	81 c3 00 00 00 10    	add    $0x10000000,%ebx
f0105c36:	c1 eb 0c             	shr    $0xc,%ebx
f0105c39:	3b 1d a8 de 24 f0    	cmp    0xf024dea8,%ebx
f0105c3f:	72 1c                	jb     f0105c5d <syscall+0x17d>
		panic("pa2page called with invalid pa");
f0105c41:	c7 44 24 08 70 8a 10 	movl   $0xf0108a70,0x8(%esp)
f0105c48:	f0 
f0105c49:	c7 44 24 04 4f 00 00 	movl   $0x4f,0x4(%esp)
f0105c50:	00 
f0105c51:	c7 04 24 32 86 10 f0 	movl   $0xf0108632,(%esp)
f0105c58:	e8 28 a4 ff ff       	call   f0100085 <_panic>
	return &pages[PGNUM(pa)];
f0105c5d:	c1 e3 03             	shl    $0x3,%ebx
static int
sys_map_kernel_page(void* kpage, void* va)
{
	int r;
	struct Page* p = pa2page(PADDR(kpage));
	if(p ==NULL)
f0105c60:	b8 03 00 00 00       	mov    $0x3,%eax
f0105c65:	03 1d b0 de 24 f0    	add    0xf024deb0,%ebx
f0105c6b:	0f 84 1e 05 00 00    	je     f010618f <syscall+0x6af>
		return E_INVAL;
	r = page_insert(curenv->env_pgdir, p, va, PTE_U | PTE_W);
f0105c71:	e8 48 1a 00 00       	call   f01076be <cpunum>
f0105c76:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f0105c7d:	00 
f0105c7e:	89 74 24 08          	mov    %esi,0x8(%esp)
f0105c82:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105c86:	6b c0 74             	imul   $0x74,%eax,%eax
f0105c89:	8b 80 28 e0 24 f0    	mov    -0xfdb1fd8(%eax),%eax
f0105c8f:	8b 40 64             	mov    0x64(%eax),%eax
f0105c92:	89 04 24             	mov    %eax,(%esp)
f0105c95:	e8 01 c7 ff ff       	call   f010239b <page_insert>
f0105c9a:	e9 f0 04 00 00       	jmp    f010618f <syscall+0x6af>

static int
sys_sbrk(uint32_t inc)
{
	// LAB3: your code sbrk here...
        uintptr_t begin = ROUNDUP(curenv->env_break,PGSIZE);
f0105c9f:	e8 1a 1a 00 00       	call   f01076be <cpunum>
f0105ca4:	6b c0 74             	imul   $0x74,%eax,%eax
f0105ca7:	8b 80 28 e0 24 f0    	mov    -0xfdb1fd8(%eax),%eax
f0105cad:	8b 70 60             	mov    0x60(%eax),%esi
f0105cb0:	81 c6 ff 0f 00 00    	add    $0xfff,%esi
f0105cb6:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
        uintptr_t end = ROUNDUP(begin + inc,PGSIZE);
f0105cbc:	8d 84 1e ff 0f 00 00 	lea    0xfff(%esi,%ebx,1),%eax
f0105cc3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0105cc8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        while(begin < end){
f0105ccb:	39 c6                	cmp    %eax,%esi
f0105ccd:	73 65                	jae    f0105d34 <syscall+0x254>
           struct Page* page = page_alloc(0);
           if(page == NULL)
               panic("page alloc failed\n");
           page_insert(curenv->env_pgdir,page,(void*)begin,PTE_U|PTE_W|PTE_P);
f0105ccf:	bb 20 e0 24 f0       	mov    $0xf024e020,%ebx
{
	// LAB3: your code sbrk here...
        uintptr_t begin = ROUNDUP(curenv->env_break,PGSIZE);
        uintptr_t end = ROUNDUP(begin + inc,PGSIZE);
        while(begin < end){
           struct Page* page = page_alloc(0);
f0105cd4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0105cdb:	e8 a7 c3 ff ff       	call   f0102087 <page_alloc>
f0105ce0:	89 c7                	mov    %eax,%edi
           if(page == NULL)
f0105ce2:	85 c0                	test   %eax,%eax
f0105ce4:	75 1c                	jne    f0105d02 <syscall+0x222>
               panic("page alloc failed\n");
f0105ce6:	c7 44 24 08 a5 90 10 	movl   $0xf01090a5,0x8(%esp)
f0105ced:	f0 
f0105cee:	c7 44 24 04 99 01 00 	movl   $0x199,0x4(%esp)
f0105cf5:	00 
f0105cf6:	c7 04 24 52 95 10 f0 	movl   $0xf0109552,(%esp)
f0105cfd:	e8 83 a3 ff ff       	call   f0100085 <_panic>
           page_insert(curenv->env_pgdir,page,(void*)begin,PTE_U|PTE_W|PTE_P);
f0105d02:	e8 b7 19 00 00       	call   f01076be <cpunum>
f0105d07:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
f0105d0e:	00 
f0105d0f:	89 74 24 08          	mov    %esi,0x8(%esp)
f0105d13:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105d17:	6b c0 74             	imul   $0x74,%eax,%eax
f0105d1a:	8b 44 18 08          	mov    0x8(%eax,%ebx,1),%eax
f0105d1e:	8b 40 64             	mov    0x64(%eax),%eax
f0105d21:	89 04 24             	mov    %eax,(%esp)
f0105d24:	e8 72 c6 ff ff       	call   f010239b <page_insert>
           begin += PGSIZE;
f0105d29:	81 c6 00 10 00 00    	add    $0x1000,%esi
sys_sbrk(uint32_t inc)
{
	// LAB3: your code sbrk here...
        uintptr_t begin = ROUNDUP(curenv->env_break,PGSIZE);
        uintptr_t end = ROUNDUP(begin + inc,PGSIZE);
        while(begin < end){
f0105d2f:	39 75 d4             	cmp    %esi,-0x2c(%ebp)
f0105d32:	77 a0                	ja     f0105cd4 <syscall+0x1f4>
           if(page == NULL)
               panic("page alloc failed\n");
           page_insert(curenv->env_pgdir,page,(void*)begin,PTE_U|PTE_W|PTE_P);
           begin += PGSIZE;
        }
        curenv->env_break = end;
f0105d34:	e8 85 19 00 00       	call   f01076be <cpunum>
f0105d39:	bb 20 e0 24 f0       	mov    $0xf024e020,%ebx
f0105d3e:	6b c0 74             	imul   $0x74,%eax,%eax
f0105d41:	8b 44 18 08          	mov    0x8(%eax,%ebx,1),%eax
f0105d45:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0105d48:	89 50 60             	mov    %edx,0x60(%eax)
	return curenv->env_break;
f0105d4b:	e8 6e 19 00 00       	call   f01076be <cpunum>
f0105d50:	6b c0 74             	imul   $0x74,%eax,%eax
f0105d53:	8b 44 18 08          	mov    0x8(%eax,%ebx,1),%eax
f0105d57:	8b 40 60             	mov    0x60(%eax),%eax
        case SYS_map_kernel_page:
          ret = sys_map_kernel_page((void*)a1,(void*)a2);
          break;
        case SYS_sbrk:
          ret = sys_sbrk(a1);
          break;
f0105d5a:	e9 30 04 00 00       	jmp    f010618f <syscall+0x6af>

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
	sched_yield();
f0105d5f:	e8 1c fc ff ff       	call   f0105980 <sched_yield>
	// from the current environment -- but tweaked so sys_exofork
	// will appear to return 0.
        struct Env* forkEnv;
        uint32_t ret;
        //panic("1111111\n");
        ret = env_alloc(&forkEnv,curenv->env_id);
f0105d64:	e8 55 19 00 00       	call   f01076be <cpunum>
f0105d69:	bb 20 e0 24 f0       	mov    $0xf024e020,%ebx
f0105d6e:	6b c0 74             	imul   $0x74,%eax,%eax
f0105d71:	8b 44 18 08          	mov    0x8(%eax,%ebx,1),%eax
f0105d75:	8b 40 48             	mov    0x48(%eax),%eax
f0105d78:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105d7c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0105d7f:	89 04 24             	mov    %eax,(%esp)
f0105d82:	e8 66 e8 ff ff       	call   f01045ed <env_alloc>
        if(ret < 0){
           return ret;
        }
        forkEnv->env_status = ENV_NOT_RUNNABLE;
f0105d87:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105d8a:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)

        forkEnv->env_tf = curenv->env_tf;
f0105d91:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105d94:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0105d97:	e8 22 19 00 00       	call   f01076be <cpunum>
f0105d9c:	6b c0 74             	imul   $0x74,%eax,%eax
f0105d9f:	8b 74 18 08          	mov    0x8(%eax,%ebx,1),%esi
f0105da3:	b9 11 00 00 00       	mov    $0x11,%ecx
f0105da8:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0105dab:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
        forkEnv->env_tf.tf_regs.reg_eax = 0;
f0105dad:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105db0:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
        //cprintf("env_id:%d\n",forkEnv->env_id);
        return forkEnv->env_id;
f0105db7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105dba:	8b 40 48             	mov    0x48(%eax),%eax
        case SYS_yield:
          sys_yield();
          break;
        case SYS_exofork:
          ret = sys_exofork();
          break;
f0105dbd:	e9 cd 03 00 00       	jmp    f010618f <syscall+0x6af>
	// check whether the current environment has permission to set
	// envid's status.

	// LAB 4: Your code here.
        struct Env* env;
        uint32_t ret = envid2env(envid,&env,1);
f0105dc2:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0105dc9:	00 
f0105dca:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0105dcd:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105dd1:	89 1c 24             	mov    %ebx,(%esp)
f0105dd4:	e8 ff e3 ff ff       	call   f01041d8 <envid2env>
        if(ret < 0)
            return -E_BAD_ENV;
        env->env_status = status;
f0105dd9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105ddc:	89 70 54             	mov    %esi,0x54(%eax)
f0105ddf:	b8 00 00 00 00       	mov    $0x0,%eax
        case SYS_exofork:
          ret = sys_exofork();
          break;
        case SYS_env_set_status:
          ret = sys_env_set_status((envid_t)a1,(int)a2);
          break;
f0105de4:	e9 a6 03 00 00       	jmp    f010618f <syscall+0x6af>
//		or the caller doesn't have permission to change envid.
static int
sys_env_set_pgfault_upcall(envid_t envid, void *func)
{
        struct Env* env;
        uint32_t ret = envid2env(envid,&env,1);
f0105de9:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0105df0:	00 
f0105df1:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0105df4:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105df8:	89 1c 24             	mov    %ebx,(%esp)
f0105dfb:	e8 d8 e3 ff ff       	call   f01041d8 <envid2env>
        if(ret < 0)
            return -E_BAD_ENV;
        env->env_pgfault_upcall = func;
f0105e00:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105e03:	89 70 68             	mov    %esi,0x68(%eax)
f0105e06:	b8 00 00 00 00       	mov    $0x0,%eax
        case SYS_env_set_status:
          ret = sys_env_set_status((envid_t)a1,(int)a2);
          break;
        case SYS_env_set_pgfault_upcall:
          ret = sys_env_set_pgfault_upcall((envid_t)a1, (void *)a2);
          break;
f0105e0b:	e9 7f 03 00 00       	jmp    f010618f <syscall+0x6af>
	//   Most of the new code you write should be to check the
	//   parameters for correctness.
	//   If page_insert() fails, remember to free the page you
	//   allocated!
        uint32_t vaddr = (uint32_t)va;
        if(vaddr >= UTOP || (vaddr%PGSIZE))
f0105e10:	81 fe ff ff bf ee    	cmp    $0xeebfffff,%esi
f0105e16:	77 6c                	ja     f0105e84 <syscall+0x3a4>
f0105e18:	f7 c6 ff 0f 00 00    	test   $0xfff,%esi
f0105e1e:	75 64                	jne    f0105e84 <syscall+0x3a4>
              return -E_INVAL;
        if(!(perm & PTE_P) || !(perm & PTE_U))
f0105e20:	8b 45 14             	mov    0x14(%ebp),%eax
f0105e23:	83 e0 05             	and    $0x5,%eax
f0105e26:	83 f8 05             	cmp    $0x5,%eax
f0105e29:	75 59                	jne    f0105e84 <syscall+0x3a4>
              return -E_INVAL;
        struct Env* env;
        struct Page* page;
        uint32_t ret = envid2env(envid,&env,1);
f0105e2b:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0105e32:	00 
f0105e33:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0105e36:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105e3a:	89 1c 24             	mov    %ebx,(%esp)
f0105e3d:	e8 96 e3 ff ff       	call   f01041d8 <envid2env>
        if(ret < 0)
            return -E_BAD_ENV;
        page = page_alloc(ALLOC_ZERO);
f0105e42:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0105e49:	e8 39 c2 ff ff       	call   f0102087 <page_alloc>
f0105e4e:	89 c2                	mov    %eax,%edx
        if(!page)
f0105e50:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0105e55:	85 d2                	test   %edx,%edx
f0105e57:	0f 84 32 03 00 00    	je     f010618f <syscall+0x6af>
            return -E_NO_MEM;
        ret = page_insert(env->env_pgdir,page,va,perm);
f0105e5d:	8b 45 14             	mov    0x14(%ebp),%eax
f0105e60:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105e64:	89 74 24 08          	mov    %esi,0x8(%esp)
f0105e68:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105e6c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105e6f:	8b 40 64             	mov    0x64(%eax),%eax
f0105e72:	89 04 24             	mov    %eax,(%esp)
f0105e75:	e8 21 c5 ff ff       	call   f010239b <page_insert>
f0105e7a:	b8 00 00 00 00       	mov    $0x0,%eax
f0105e7f:	e9 0b 03 00 00       	jmp    f010618f <syscall+0x6af>
f0105e84:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0105e89:	e9 01 03 00 00       	jmp    f010618f <syscall+0x6af>
	//   parameters for correctness.
	//   Use the third argument to page_lookup() to
	//   check the current permissions on the page.
        uint32_t srcvaddr = (uint32_t)srcva;
        uint32_t dstvaddr = (uint32_t)dstva;
        if(srcvaddr >= UTOP || (srcvaddr%PGSIZE) || dstvaddr >= UTOP || (dstvaddr%PGSIZE))
f0105e8e:	81 fe ff ff bf ee    	cmp    $0xeebfffff,%esi
f0105e94:	0f 87 c2 00 00 00    	ja     f0105f5c <syscall+0x47c>
          break;
        case SYS_page_alloc:
          ret = sys_page_alloc((envid_t)a1, (void *)a2, (int)a3);
          break;
        case SYS_page_map:{
          uint32_t dstva = (uint32_t)a4 & 0xFFFFF000;
f0105e9a:	89 fa                	mov    %edi,%edx
f0105e9c:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0105ea2:	89 55 d0             	mov    %edx,-0x30(%ebp)
	//   parameters for correctness.
	//   Use the third argument to page_lookup() to
	//   check the current permissions on the page.
        uint32_t srcvaddr = (uint32_t)srcva;
        uint32_t dstvaddr = (uint32_t)dstva;
        if(srcvaddr >= UTOP || (srcvaddr%PGSIZE) || dstvaddr >= UTOP || (dstvaddr%PGSIZE))
f0105ea5:	f7 c6 ff 0f 00 00    	test   $0xfff,%esi
f0105eab:	0f 85 ab 00 00 00    	jne    f0105f5c <syscall+0x47c>
f0105eb1:	81 fa ff ff bf ee    	cmp    $0xeebfffff,%edx
f0105eb7:	0f 87 9f 00 00 00    	ja     f0105f5c <syscall+0x47c>
        case SYS_page_alloc:
          ret = sys_page_alloc((envid_t)a1, (void *)a2, (int)a3);
          break;
        case SYS_page_map:{
          uint32_t dstva = (uint32_t)a4 & 0xFFFFF000;
          uint32_t perm = (uint32_t)a4 & 0xFFF;
f0105ebd:	89 f8                	mov    %edi,%eax
f0105ebf:	25 ff 0f 00 00       	and    $0xfff,%eax
f0105ec4:	89 45 cc             	mov    %eax,-0x34(%ebp)
	//   check the current permissions on the page.
        uint32_t srcvaddr = (uint32_t)srcva;
        uint32_t dstvaddr = (uint32_t)dstva;
        if(srcvaddr >= UTOP || (srcvaddr%PGSIZE) || dstvaddr >= UTOP || (dstvaddr%PGSIZE))
              return -E_INVAL;
        if(!(perm & PTE_P) || !(perm & PTE_U))
f0105ec7:	83 e7 05             	and    $0x5,%edi
f0105eca:	83 ff 05             	cmp    $0x5,%edi
f0105ecd:	0f 85 89 00 00 00    	jne    f0105f5c <syscall+0x47c>
              return -E_INVAL;
        struct Env* srcenv;
        struct Env* dstenv;
        uint32_t ret;
        ret = envid2env(srcenvid,&srcenv,1);
f0105ed3:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0105eda:	00 
f0105edb:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0105ede:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105ee2:	89 1c 24             	mov    %ebx,(%esp)
f0105ee5:	e8 ee e2 ff ff       	call   f01041d8 <envid2env>
        if(ret < 0)
           return -E_BAD_ENV;
        ret = envid2env(dstenvid,&dstenv,1);
f0105eea:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0105ef1:	00 
f0105ef2:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0105ef5:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105ef9:	8b 55 14             	mov    0x14(%ebp),%edx
f0105efc:	89 14 24             	mov    %edx,(%esp)
f0105eff:	e8 d4 e2 ff ff       	call   f01041d8 <envid2env>
        if(ret < 0)
           return -E_BAD_ENV;
        struct Page* page;
        pte_t* pte;
        page = page_lookup(srcenv->env_pgdir,srcva,&pte);
f0105f04:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0105f07:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105f0b:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105f0f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105f12:	8b 40 64             	mov    0x64(%eax),%eax
f0105f15:	89 04 24             	mov    %eax,(%esp)
f0105f18:	e8 b2 c3 ff ff       	call   f01022cf <page_lookup>
        if(page == NULL)
f0105f1d:	85 c0                	test   %eax,%eax
f0105f1f:	74 3b                	je     f0105f5c <syscall+0x47c>
           return -E_INVAL;
        if(!(perm & PTE_P) || !(perm & PTE_U) || (!pte))
f0105f21:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0105f24:	85 c9                	test   %ecx,%ecx
f0105f26:	74 34                	je     f0105f5c <syscall+0x47c>
          ret = sys_page_alloc((envid_t)a1, (void *)a2, (int)a3);
          break;
        case SYS_page_map:{
          uint32_t dstva = (uint32_t)a4 & 0xFFFFF000;
          uint32_t perm = (uint32_t)a4 & 0xFFF;
          ret = sys_page_map((envid_t)a1, (void *)a2,(envid_t)a3, (void *)dstva, (int)perm);
f0105f28:	8b 55 cc             	mov    -0x34(%ebp),%edx
        page = page_lookup(srcenv->env_pgdir,srcva,&pte);
        if(page == NULL)
           return -E_INVAL;
        if(!(perm & PTE_P) || !(perm & PTE_U) || (!pte))
              return -E_INVAL;
        if((perm & PTE_W) && (!((*pte) & PTE_W)))
f0105f2b:	f6 c2 02             	test   $0x2,%dl
f0105f2e:	74 05                	je     f0105f35 <syscall+0x455>
f0105f30:	f6 01 02             	testb  $0x2,(%ecx)
f0105f33:	74 27                	je     f0105f5c <syscall+0x47c>
              return -E_INVAL;
        ret = page_insert(dstenv->env_pgdir,page,dstva,perm);
f0105f35:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0105f39:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0105f3c:	89 54 24 08          	mov    %edx,0x8(%esp)
f0105f40:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105f44:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0105f47:	8b 40 64             	mov    0x64(%eax),%eax
f0105f4a:	89 04 24             	mov    %eax,(%esp)
f0105f4d:	e8 49 c4 ff ff       	call   f010239b <page_insert>
f0105f52:	b8 00 00 00 00       	mov    $0x0,%eax
f0105f57:	e9 33 02 00 00       	jmp    f010618f <syscall+0x6af>
f0105f5c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0105f61:	e9 29 02 00 00       	jmp    f010618f <syscall+0x6af>
sys_page_unmap(envid_t envid, void *va)
{
	// Hint: This function is a wrapper around page_remove().
        uint32_t vaddr = (uint32_t)va;
        struct Env* env;
        if(vaddr >= UTOP || (vaddr%PGSIZE))
f0105f66:	81 fe ff ff bf ee    	cmp    $0xeebfffff,%esi
f0105f6c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0105f70:	77 3b                	ja     f0105fad <syscall+0x4cd>
f0105f72:	f7 c6 ff 0f 00 00    	test   $0xfff,%esi
f0105f78:	75 33                	jne    f0105fad <syscall+0x4cd>
              return -E_INVAL;        
        uint32_t ret = envid2env(envid,&env,1);
f0105f7a:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0105f81:	00 
f0105f82:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0105f85:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105f89:	89 1c 24             	mov    %ebx,(%esp)
f0105f8c:	e8 47 e2 ff ff       	call   f01041d8 <envid2env>
        if(ret < 0)
            return -E_BAD_ENV;
        page_remove(env->env_pgdir,va);
f0105f91:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105f95:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105f98:	8b 40 64             	mov    0x64(%eax),%eax
f0105f9b:	89 04 24             	mov    %eax,(%esp)
f0105f9e:	e8 9d c3 ff ff       	call   f0102340 <page_remove>
f0105fa3:	b8 00 00 00 00       	mov    $0x0,%eax
f0105fa8:	e9 e2 01 00 00       	jmp    f010618f <syscall+0x6af>
f0105fad:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0105fb2:	e9 d8 01 00 00       	jmp    f010618f <syscall+0x6af>
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, unsigned perm)
{
	// LAB 4: Your code here.
        struct Env* env;
        uint32_t srcvaddr = (uint32_t)srcva;
        uint32_t ret = envid2env(envid,&env,0);
f0105fb7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0105fbe:	00 
f0105fbf:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0105fc2:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105fc6:	89 1c 24             	mov    %ebx,(%esp)
f0105fc9:	e8 0a e2 ff ff       	call   f01041d8 <envid2env>
        if(ret < 0)
            return -E_BAD_ENV;
        if((!env->env_ipc_recving) || env->env_ipc_from)
f0105fce:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105fd1:	83 78 6c 00          	cmpl   $0x0,0x6c(%eax)
f0105fd5:	0f 84 06 01 00 00    	je     f01060e1 <syscall+0x601>
f0105fdb:	83 78 78 00          	cmpl   $0x0,0x78(%eax)
f0105fdf:	0f 85 fc 00 00 00    	jne    f01060e1 <syscall+0x601>
            return -E_IPC_NOT_RECV;
        if(srcvaddr < UTOP){
f0105fe5:	81 7d 14 ff ff bf ee 	cmpl   $0xeebfffff,0x14(%ebp)
f0105fec:	0f 87 aa 00 00 00    	ja     f010609c <syscall+0x5bc>
            if(srcvaddr % PGSIZE)
f0105ff2:	f7 45 14 ff 0f 00 00 	testl  $0xfff,0x14(%ebp)
f0105ff9:	0f 85 ec 00 00 00    	jne    f01060eb <syscall+0x60b>
                 return -E_INVAL;
            if(!(perm & PTE_P) || !(perm & PTE_U))
f0105fff:	89 f8                	mov    %edi,%eax
f0106001:	83 e0 05             	and    $0x5,%eax
f0106004:	83 f8 05             	cmp    $0x5,%eax
f0106007:	0f 85 de 00 00 00    	jne    f01060eb <syscall+0x60b>
                 return -E_INVAL;
            pte_t* pte;
            struct Page* page = page_lookup(curenv->env_pgdir,srcva,&pte);
f010600d:	e8 ac 16 00 00       	call   f01076be <cpunum>
f0106012:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0106015:	89 54 24 08          	mov    %edx,0x8(%esp)
f0106019:	8b 55 14             	mov    0x14(%ebp),%edx
f010601c:	89 54 24 04          	mov    %edx,0x4(%esp)
f0106020:	6b c0 74             	imul   $0x74,%eax,%eax
f0106023:	8b 80 28 e0 24 f0    	mov    -0xfdb1fd8(%eax),%eax
f0106029:	8b 40 64             	mov    0x64(%eax),%eax
f010602c:	89 04 24             	mov    %eax,(%esp)
f010602f:	e8 9b c2 ff ff       	call   f01022cf <page_lookup>
            if((!page) || (!pte) || (!((*pte) & PTE_P)) || (!((*pte) & PTE_U)))
f0106034:	85 c0                	test   %eax,%eax
f0106036:	0f 84 af 00 00 00    	je     f01060eb <syscall+0x60b>
f010603c:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010603f:	85 d2                	test   %edx,%edx
f0106041:	0f 84 a4 00 00 00    	je     f01060eb <syscall+0x60b>
f0106047:	8b 12                	mov    (%edx),%edx
f0106049:	89 d1                	mov    %edx,%ecx
f010604b:	83 e1 05             	and    $0x5,%ecx
f010604e:	83 f9 05             	cmp    $0x5,%ecx
f0106051:	0f 85 94 00 00 00    	jne    f01060eb <syscall+0x60b>
                 return -E_INVAL;
            if((perm & PTE_W) && (!((*pte) & PTE_W)))
f0106057:	f7 c7 02 00 00 00    	test   $0x2,%edi
f010605d:	74 09                	je     f0106068 <syscall+0x588>
f010605f:	f6 c2 02             	test   $0x2,%dl
f0106062:	0f 84 83 00 00 00    	je     f01060eb <syscall+0x60b>
                 return -E_INVAL;
            if((uint32_t)env->env_ipc_dstva < UTOP){
f0106068:	8b 55 e0             	mov    -0x20(%ebp),%edx
f010606b:	8b 4a 70             	mov    0x70(%edx),%ecx
f010606e:	81 f9 ff ff bf ee    	cmp    $0xeebfffff,%ecx
f0106074:	77 1f                	ja     f0106095 <syscall+0x5b5>
                 ret = page_insert(env->env_pgdir,page,env->env_ipc_dstva,perm);
f0106076:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f010607a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010607e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106082:	8b 42 64             	mov    0x64(%edx),%eax
f0106085:	89 04 24             	mov    %eax,(%esp)
f0106088:	e8 0e c3 ff ff       	call   f010239b <page_insert>
                 if(ret < 0)
                    return ret;
                 env->env_ipc_perm = perm;
f010608d:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0106090:	89 78 7c             	mov    %edi,0x7c(%eax)
f0106093:	eb 07                	jmp    f010609c <syscall+0x5bc>
            }
            else
                 env->env_ipc_perm = 0;
f0106095:	c7 42 7c 00 00 00 00 	movl   $0x0,0x7c(%edx)
         }
         env->env_ipc_recving = 0;
f010609c:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010609f:	c7 40 6c 00 00 00 00 	movl   $0x0,0x6c(%eax)
         env->env_ipc_value = value;
f01060a6:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01060a9:	89 70 74             	mov    %esi,0x74(%eax)
         env->env_ipc_from = curenv->env_id;
f01060ac:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f01060af:	e8 0a 16 00 00       	call   f01076be <cpunum>
f01060b4:	6b c0 74             	imul   $0x74,%eax,%eax
f01060b7:	8b 80 28 e0 24 f0    	mov    -0xfdb1fd8(%eax),%eax
f01060bd:	8b 40 48             	mov    0x48(%eax),%eax
f01060c0:	89 43 78             	mov    %eax,0x78(%ebx)
         env->env_status = ENV_RUNNABLE;
f01060c3:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01060c6:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
         env->env_tf.tf_regs.reg_eax = 0;
f01060cd:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01060d0:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
f01060d7:	b8 00 00 00 00       	mov    $0x0,%eax
f01060dc:	e9 ae 00 00 00       	jmp    f010618f <syscall+0x6af>
f01060e1:	b8 f9 ff ff ff       	mov    $0xfffffff9,%eax
f01060e6:	e9 a4 00 00 00       	jmp    f010618f <syscall+0x6af>
f01060eb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01060f0:	e9 9a 00 00 00       	jmp    f010618f <syscall+0x6af>
//	-E_INVAL if dstva < UTOP but dstva is not page-aligned.
static int
sys_ipc_recv(void *dstva)
{
	// LAB 4: Your code here.
        if((uint32_t)dstva < UTOP){
f01060f5:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
f01060fb:	90                   	nop
f01060fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106100:	77 10                	ja     f0106112 <syscall+0x632>
           if((uint32_t)dstva % PGSIZE)
f0106102:	f7 c3 ff 0f 00 00    	test   $0xfff,%ebx
f0106108:	74 08                	je     f0106112 <syscall+0x632>
f010610a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010610f:	90                   	nop
f0106110:	eb 7d                	jmp    f010618f <syscall+0x6af>
                 return -E_INVAL;
        }
        curenv->env_ipc_recving = 1;
f0106112:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0106118:	e8 a1 15 00 00       	call   f01076be <cpunum>
f010611d:	be 20 e0 24 f0       	mov    $0xf024e020,%esi
f0106122:	6b c0 74             	imul   $0x74,%eax,%eax
f0106125:	8b 44 30 08          	mov    0x8(%eax,%esi,1),%eax
f0106129:	c7 40 6c 01 00 00 00 	movl   $0x1,0x6c(%eax)
        curenv->env_ipc_dstva = dstva;
f0106130:	e8 89 15 00 00       	call   f01076be <cpunum>
f0106135:	6b c0 74             	imul   $0x74,%eax,%eax
f0106138:	8b 44 30 08          	mov    0x8(%eax,%esi,1),%eax
f010613c:	89 58 70             	mov    %ebx,0x70(%eax)
        curenv->env_ipc_from = 0;
f010613f:	e8 7a 15 00 00       	call   f01076be <cpunum>
f0106144:	6b c0 74             	imul   $0x74,%eax,%eax
f0106147:	8b 44 30 08          	mov    0x8(%eax,%esi,1),%eax
f010614b:	c7 40 78 00 00 00 00 	movl   $0x0,0x78(%eax)
        curenv->env_status = ENV_NOT_RUNNABLE;
f0106152:	e8 67 15 00 00       	call   f01076be <cpunum>
f0106157:	6b c0 74             	imul   $0x74,%eax,%eax
f010615a:	8b 44 30 08          	mov    0x8(%eax,%esi,1),%eax
f010615e:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
        sched_yield();
f0106165:	e8 16 f8 ff ff       	call   f0105980 <sched_yield>
}

static int 
sys_env_set_prior(envid_t envid, uint32_t prior){
        struct Env* env;
        uint32_t ret = envid2env(envid,&env,1);
f010616a:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0106171:	00 
f0106172:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0106175:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106179:	89 1c 24             	mov    %ebx,(%esp)
f010617c:	e8 57 e0 ff ff       	call   f01041d8 <envid2env>
        if(ret < 0)
            return -E_BAD_ENV;
        env->env_prior = prior;
f0106181:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0106184:	89 b0 80 00 00 00    	mov    %esi,0x80(%eax)
f010618a:	b8 00 00 00 00       	mov    $0x0,%eax
        return ret;
     
          
     
	//panic("syscall not implemented");
}
f010618f:	83 c4 3c             	add    $0x3c,%esp
f0106192:	5b                   	pop    %ebx
f0106193:	5e                   	pop    %esi
f0106194:	5f                   	pop    %edi
f0106195:	5d                   	pop    %ebp
f0106196:	c3                   	ret    
	...

f01061a0 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f01061a0:	55                   	push   %ebp
f01061a1:	89 e5                	mov    %esp,%ebp
f01061a3:	57                   	push   %edi
f01061a4:	56                   	push   %esi
f01061a5:	53                   	push   %ebx
f01061a6:	83 ec 14             	sub    $0x14,%esp
f01061a9:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01061ac:	89 55 e8             	mov    %edx,-0x18(%ebp)
f01061af:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f01061b2:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f01061b5:	8b 1a                	mov    (%edx),%ebx
f01061b7:	8b 01                	mov    (%ecx),%eax
f01061b9:	89 45 ec             	mov    %eax,-0x14(%ebp)
	
	while (l <= r) {
f01061bc:	39 c3                	cmp    %eax,%ebx
f01061be:	0f 8f 9c 00 00 00    	jg     f0106260 <stab_binsearch+0xc0>
f01061c4:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
		int true_m = (l + r) / 2, m = true_m;
f01061cb:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01061ce:	01 d8                	add    %ebx,%eax
f01061d0:	89 c7                	mov    %eax,%edi
f01061d2:	c1 ef 1f             	shr    $0x1f,%edi
f01061d5:	01 c7                	add    %eax,%edi
f01061d7:	d1 ff                	sar    %edi
		
		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01061d9:	39 df                	cmp    %ebx,%edi
f01061db:	7c 33                	jl     f0106210 <stab_binsearch+0x70>
f01061dd:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f01061e0:	8b 55 f0             	mov    -0x10(%ebp),%edx
f01061e3:	0f b6 44 82 04       	movzbl 0x4(%edx,%eax,4),%eax
f01061e8:	39 f0                	cmp    %esi,%eax
f01061ea:	0f 84 bc 00 00 00    	je     f01062ac <stab_binsearch+0x10c>
f01061f0:	8d 44 7f fd          	lea    -0x3(%edi,%edi,2),%eax
f01061f4:	8d 54 82 04          	lea    0x4(%edx,%eax,4),%edx
f01061f8:	89 f8                	mov    %edi,%eax
			m--;
f01061fa:	83 e8 01             	sub    $0x1,%eax
	
	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
		
		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01061fd:	39 d8                	cmp    %ebx,%eax
f01061ff:	7c 0f                	jl     f0106210 <stab_binsearch+0x70>
f0106201:	0f b6 0a             	movzbl (%edx),%ecx
f0106204:	83 ea 0c             	sub    $0xc,%edx
f0106207:	39 f1                	cmp    %esi,%ecx
f0106209:	75 ef                	jne    f01061fa <stab_binsearch+0x5a>
f010620b:	e9 9e 00 00 00       	jmp    f01062ae <stab_binsearch+0x10e>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0106210:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f0106213:	eb 3c                	jmp    f0106251 <stab_binsearch+0xb1>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f0106215:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0106218:	89 01                	mov    %eax,(%ecx)
			l = true_m + 1;
f010621a:	8d 5f 01             	lea    0x1(%edi),%ebx
f010621d:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f0106224:	eb 2b                	jmp    f0106251 <stab_binsearch+0xb1>
		} else if (stabs[m].n_value > addr) {
f0106226:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0106229:	76 14                	jbe    f010623f <stab_binsearch+0x9f>
			*region_right = m - 1;
f010622b:	83 e8 01             	sub    $0x1,%eax
f010622e:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0106231:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0106234:	89 02                	mov    %eax,(%edx)
f0106236:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f010623d:	eb 12                	jmp    f0106251 <stab_binsearch+0xb1>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f010623f:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0106242:	89 01                	mov    %eax,(%ecx)
			l = m;
			addr++;
f0106244:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0106248:	89 c3                	mov    %eax,%ebx
f010624a:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;
	
	while (l <= r) {
f0106251:	39 5d ec             	cmp    %ebx,-0x14(%ebp)
f0106254:	0f 8d 71 ff ff ff    	jge    f01061cb <stab_binsearch+0x2b>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f010625a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f010625e:	75 0f                	jne    f010626f <stab_binsearch+0xcf>
		*region_right = *region_left - 1;
f0106260:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f0106263:	8b 03                	mov    (%ebx),%eax
f0106265:	83 e8 01             	sub    $0x1,%eax
f0106268:	8b 55 e0             	mov    -0x20(%ebp),%edx
f010626b:	89 02                	mov    %eax,(%edx)
f010626d:	eb 57                	jmp    f01062c6 <stab_binsearch+0x126>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f010626f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0106272:	8b 01                	mov    (%ecx),%eax
		     l > *region_left && stabs[l].n_type != type;
f0106274:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f0106277:	8b 0b                	mov    (%ebx),%ecx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0106279:	39 c1                	cmp    %eax,%ecx
f010627b:	7d 28                	jge    f01062a5 <stab_binsearch+0x105>
		     l > *region_left && stabs[l].n_type != type;
f010627d:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0106280:	8b 5d f0             	mov    -0x10(%ebp),%ebx
f0106283:	0f b6 54 93 04       	movzbl 0x4(%ebx,%edx,4),%edx
f0106288:	39 f2                	cmp    %esi,%edx
f010628a:	74 19                	je     f01062a5 <stab_binsearch+0x105>
f010628c:	8d 54 40 fd          	lea    -0x3(%eax,%eax,2),%edx
f0106290:	8d 54 93 04          	lea    0x4(%ebx,%edx,4),%edx
		     l--)
f0106294:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0106297:	39 c1                	cmp    %eax,%ecx
f0106299:	7d 0a                	jge    f01062a5 <stab_binsearch+0x105>
		     l > *region_left && stabs[l].n_type != type;
f010629b:	0f b6 1a             	movzbl (%edx),%ebx
f010629e:	83 ea 0c             	sub    $0xc,%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01062a1:	39 f3                	cmp    %esi,%ebx
f01062a3:	75 ef                	jne    f0106294 <stab_binsearch+0xf4>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
f01062a5:	8b 55 e8             	mov    -0x18(%ebp),%edx
f01062a8:	89 02                	mov    %eax,(%edx)
f01062aa:	eb 1a                	jmp    f01062c6 <stab_binsearch+0x126>
	}
}
f01062ac:	89 f8                	mov    %edi,%eax
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f01062ae:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01062b1:	8b 4d f0             	mov    -0x10(%ebp),%ecx
f01062b4:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f01062b8:	3b 55 0c             	cmp    0xc(%ebp),%edx
f01062bb:	0f 82 54 ff ff ff    	jb     f0106215 <stab_binsearch+0x75>
f01062c1:	e9 60 ff ff ff       	jmp    f0106226 <stab_binsearch+0x86>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f01062c6:	83 c4 14             	add    $0x14,%esp
f01062c9:	5b                   	pop    %ebx
f01062ca:	5e                   	pop    %esi
f01062cb:	5f                   	pop    %edi
f01062cc:	5d                   	pop    %ebp
f01062cd:	c3                   	ret    

f01062ce <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f01062ce:	55                   	push   %ebp
f01062cf:	89 e5                	mov    %esp,%ebp
f01062d1:	83 ec 58             	sub    $0x58,%esp
f01062d4:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f01062d7:	89 75 f8             	mov    %esi,-0x8(%ebp)
f01062da:	89 7d fc             	mov    %edi,-0x4(%ebp)
f01062dd:	8b 7d 08             	mov    0x8(%ebp),%edi
f01062e0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f01062e3:	c7 03 a4 95 10 f0    	movl   $0xf01095a4,(%ebx)
	info->eip_line = 0;
f01062e9:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f01062f0:	c7 43 08 a4 95 10 f0 	movl   $0xf01095a4,0x8(%ebx)
	info->eip_fn_namelen = 9;
f01062f7:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f01062fe:	89 7b 10             	mov    %edi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0106301:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0106308:	81 ff ff ff 7f ef    	cmp    $0xef7fffff,%edi
f010630e:	76 1a                	jbe    f010632a <debuginfo_eip+0x5c>
f0106310:	be 6b 94 11 f0       	mov    $0xf011946b,%esi
f0106315:	c7 45 c4 6d 58 11 f0 	movl   $0xf011586d,-0x3c(%ebp)
f010631c:	b8 6c 58 11 f0       	mov    $0xf011586c,%eax
f0106321:	c7 45 c0 f4 9a 10 f0 	movl   $0xf0109af4,-0x40(%ebp)
f0106328:	eb 16                	jmp    f0106340 <debuginfo_eip+0x72>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.

		stabs = usd->stabs;
f010632a:	ba 00 00 20 00       	mov    $0x200000,%edx
f010632f:	8b 02                	mov    (%edx),%eax
f0106331:	89 45 c0             	mov    %eax,-0x40(%ebp)
		stab_end = usd->stab_end;
f0106334:	8b 42 04             	mov    0x4(%edx),%eax
		stabstr = usd->stabstr;
f0106337:	8b 4a 08             	mov    0x8(%edx),%ecx
f010633a:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
		stabstr_end = usd->stabstr_end;
f010633d:	8b 72 0c             	mov    0xc(%edx),%esi
		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0106340:	39 75 c4             	cmp    %esi,-0x3c(%ebp)
f0106343:	0f 83 65 01 00 00    	jae    f01064ae <debuginfo_eip+0x1e0>
f0106349:	80 7e ff 00          	cmpb   $0x0,-0x1(%esi)
f010634d:	0f 85 5b 01 00 00    	jne    f01064ae <debuginfo_eip+0x1e0>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.
	
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0106353:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f010635a:	2b 45 c0             	sub    -0x40(%ebp),%eax
f010635d:	c1 f8 02             	sar    $0x2,%eax
f0106360:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0106366:	83 e8 01             	sub    $0x1,%eax
f0106369:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f010636c:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f010636f:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0106372:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0106376:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f010637d:	8b 45 c0             	mov    -0x40(%ebp),%eax
f0106380:	e8 1b fe ff ff       	call   f01061a0 <stab_binsearch>
	if (lfile == 0)
f0106385:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0106388:	85 c0                	test   %eax,%eax
f010638a:	0f 84 1e 01 00 00    	je     f01064ae <debuginfo_eip+0x1e0>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0106390:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0106393:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0106396:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0106399:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f010639c:	8d 55 dc             	lea    -0x24(%ebp),%edx
f010639f:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01063a3:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f01063aa:	8b 45 c0             	mov    -0x40(%ebp),%eax
f01063ad:	e8 ee fd ff ff       	call   f01061a0 <stab_binsearch>

	if (lfun <= rfun) {
f01063b2:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01063b5:	3b 45 d8             	cmp    -0x28(%ebp),%eax
f01063b8:	7f 35                	jg     f01063ef <debuginfo_eip+0x121>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f01063ba:	6b c0 0c             	imul   $0xc,%eax,%eax
f01063bd:	8b 55 c0             	mov    -0x40(%ebp),%edx
f01063c0:	8b 04 10             	mov    (%eax,%edx,1),%eax
f01063c3:	89 f2                	mov    %esi,%edx
f01063c5:	2b 55 c4             	sub    -0x3c(%ebp),%edx
f01063c8:	39 d0                	cmp    %edx,%eax
f01063ca:	73 06                	jae    f01063d2 <debuginfo_eip+0x104>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f01063cc:	03 45 c4             	add    -0x3c(%ebp),%eax
f01063cf:	89 43 08             	mov    %eax,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f01063d2:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01063d5:	6b c2 0c             	imul   $0xc,%edx,%eax
f01063d8:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f01063db:	8b 44 08 08          	mov    0x8(%eax,%ecx,1),%eax
f01063df:	89 43 10             	mov    %eax,0x10(%ebx)
		addr -= info->eip_fn_addr;
f01063e2:	29 c7                	sub    %eax,%edi
		// Search within the function definition for the line number.
		lline = lfun;
f01063e4:	89 55 d4             	mov    %edx,-0x2c(%ebp)
		rline = rfun;
f01063e7:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01063ea:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01063ed:	eb 0f                	jmp    f01063fe <debuginfo_eip+0x130>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f01063ef:	89 7b 10             	mov    %edi,0x10(%ebx)
		lline = lfile;
f01063f2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01063f5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f01063f8:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01063fb:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f01063fe:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f0106405:	00 
f0106406:	8b 43 08             	mov    0x8(%ebx),%eax
f0106409:	89 04 24             	mov    %eax,(%esp)
f010640c:	e8 da 0b 00 00       	call   f0106feb <strfind>
f0106411:	2b 43 08             	sub    0x8(%ebx),%eax
f0106414:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
        stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0106417:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f010641a:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f010641d:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0106421:	c7 04 24 44 00 00 00 	movl   $0x44,(%esp)
f0106428:	8b 45 c0             	mov    -0x40(%ebp),%eax
f010642b:	e8 70 fd ff ff       	call   f01061a0 <stab_binsearch>
        if(lline <= rline)
f0106430:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0106433:	3b 45 d0             	cmp    -0x30(%ebp),%eax
f0106436:	7f 76                	jg     f01064ae <debuginfo_eip+0x1e0>
           info->eip_line = stabs[lline].n_desc;
f0106438:	6b c0 0c             	imul   $0xc,%eax,%eax
f010643b:	8b 55 c0             	mov    -0x40(%ebp),%edx
f010643e:	0f b7 44 10 06       	movzwl 0x6(%eax,%edx,1),%eax
f0106443:	89 43 04             	mov    %eax,0x4(%ebx)
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
f0106446:	8b 7d e4             	mov    -0x1c(%ebp),%edi
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0106449:	eb 06                	jmp    f0106451 <debuginfo_eip+0x183>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f010644b:	83 e8 01             	sub    $0x1,%eax
f010644e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
f0106451:	8b 45 d4             	mov    -0x2c(%ebp),%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0106454:	39 f8                	cmp    %edi,%eax
f0106456:	7c 27                	jl     f010647f <debuginfo_eip+0x1b1>
	       && stabs[lline].n_type != N_SOL
f0106458:	6b d0 0c             	imul   $0xc,%eax,%edx
f010645b:	03 55 c0             	add    -0x40(%ebp),%edx
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f010645e:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0106462:	80 f9 84             	cmp    $0x84,%cl
f0106465:	74 60                	je     f01064c7 <debuginfo_eip+0x1f9>
f0106467:	80 f9 64             	cmp    $0x64,%cl
f010646a:	75 df                	jne    f010644b <debuginfo_eip+0x17d>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f010646c:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
f0106470:	74 d9                	je     f010644b <debuginfo_eip+0x17d>
f0106472:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0106478:	eb 4d                	jmp    f01064c7 <debuginfo_eip+0x1f9>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
		info->eip_file = stabstr + stabs[lline].n_strx;
f010647a:	03 45 c4             	add    -0x3c(%ebp),%eax
f010647d:	89 03                	mov    %eax,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f010647f:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0106482:	3b 45 d8             	cmp    -0x28(%ebp),%eax
f0106485:	7d 2e                	jge    f01064b5 <debuginfo_eip+0x1e7>
		for (lline = lfun + 1;
f0106487:	83 c0 01             	add    $0x1,%eax
f010648a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010648d:	eb 08                	jmp    f0106497 <debuginfo_eip+0x1c9>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f010648f:	83 43 14 01          	addl   $0x1,0x14(%ebx)
	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
f0106493:	83 45 d4 01          	addl   $0x1,-0x2c(%ebp)

	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0106497:	8b 45 d4             	mov    -0x2c(%ebp),%eax


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f010649a:	3b 45 d8             	cmp    -0x28(%ebp),%eax
f010649d:	7d 16                	jge    f01064b5 <debuginfo_eip+0x1e7>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f010649f:	6b c0 0c             	imul   $0xc,%eax,%eax
f01064a2:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f01064a5:	80 7c 08 04 a0       	cmpb   $0xa0,0x4(%eax,%ecx,1)
f01064aa:	74 e3                	je     f010648f <debuginfo_eip+0x1c1>
f01064ac:	eb 07                	jmp    f01064b5 <debuginfo_eip+0x1e7>
f01064ae:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01064b3:	eb 05                	jmp    f01064ba <debuginfo_eip+0x1ec>
f01064b5:	b8 00 00 00 00       	mov    $0x0,%eax
		     lline++)
			info->eip_fn_narg++;
	
	return 0;
}
f01064ba:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f01064bd:	8b 75 f8             	mov    -0x8(%ebp),%esi
f01064c0:	8b 7d fc             	mov    -0x4(%ebp),%edi
f01064c3:	89 ec                	mov    %ebp,%esp
f01064c5:	5d                   	pop    %ebp
f01064c6:	c3                   	ret    
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f01064c7:	6b c0 0c             	imul   $0xc,%eax,%eax
f01064ca:	8b 55 c0             	mov    -0x40(%ebp),%edx
f01064cd:	8b 04 10             	mov    (%eax,%edx,1),%eax
f01064d0:	2b 75 c4             	sub    -0x3c(%ebp),%esi
f01064d3:	39 f0                	cmp    %esi,%eax
f01064d5:	72 a3                	jb     f010647a <debuginfo_eip+0x1ac>
f01064d7:	eb a6                	jmp    f010647f <debuginfo_eip+0x1b1>
f01064d9:	00 00                	add    %al,(%eax)
f01064db:	00 00                	add    %al,(%eax)
f01064dd:	00 00                	add    %al,(%eax)
	...

f01064e0 <printnum_v2>:
 */

static void 
printnum_v2(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f01064e0:	55                   	push   %ebp
f01064e1:	89 e5                	mov    %esp,%ebp
f01064e3:	57                   	push   %edi
f01064e4:	56                   	push   %esi
f01064e5:	53                   	push   %ebx
f01064e6:	83 ec 4c             	sub    $0x4c,%esp
f01064e9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01064ec:	89 d6                	mov    %edx,%esi
f01064ee:	8b 45 08             	mov    0x8(%ebp),%eax
f01064f1:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01064f4:	8b 55 0c             	mov    0xc(%ebp),%edx
f01064f7:	89 55 e0             	mov    %edx,-0x20(%ebp)
f01064fa:	8b 45 10             	mov    0x10(%ebp),%eax
f01064fd:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0106500:	8b 7d 18             	mov    0x18(%ebp),%edi
    if (num >= base) {
f0106503:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0106506:	b9 00 00 00 00       	mov    $0x0,%ecx
f010650b:	39 d1                	cmp    %edx,%ecx
f010650d:	72 07                	jb     f0106516 <printnum_v2+0x36>
f010650f:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0106512:	39 d0                	cmp    %edx,%eax
f0106514:	77 5f                	ja     f0106575 <printnum_v2+0x95>
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
f0106516:	89 7c 24 10          	mov    %edi,0x10(%esp)
f010651a:	83 eb 01             	sub    $0x1,%ebx
f010651d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0106521:	89 44 24 08          	mov    %eax,0x8(%esp)
f0106525:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0106529:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
f010652d:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f0106530:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
f0106533:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0106536:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f010653a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0106541:	00 
f0106542:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0106545:	89 04 24             	mov    %eax,(%esp)
f0106548:	8b 55 e0             	mov    -0x20(%ebp),%edx
f010654b:	89 54 24 04          	mov    %edx,0x4(%esp)
f010654f:	e8 0c 16 00 00       	call   f0107b60 <__udivdi3>
f0106554:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0106557:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010655a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010655e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0106562:	89 04 24             	mov    %eax,(%esp)
f0106565:	89 54 24 04          	mov    %edx,0x4(%esp)
f0106569:	89 f2                	mov    %esi,%edx
f010656b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010656e:	e8 6d ff ff ff       	call   f01064e0 <printnum_v2>
f0106573:	eb 1e                	jmp    f0106593 <printnum_v2+0xb3>
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
f0106575:	83 ff 2d             	cmp    $0x2d,%edi
f0106578:	74 19                	je     f0106593 <printnum_v2+0xb3>
		while (--width > 0)
f010657a:	83 eb 01             	sub    $0x1,%ebx
f010657d:	85 db                	test   %ebx,%ebx
f010657f:	90                   	nop
f0106580:	7e 11                	jle    f0106593 <printnum_v2+0xb3>
			putch(padc, putdat);
f0106582:	89 74 24 04          	mov    %esi,0x4(%esp)
f0106586:	89 3c 24             	mov    %edi,(%esp)
f0106589:	ff 55 e4             	call   *-0x1c(%ebp)
    if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
		while (--width > 0)
f010658c:	83 eb 01             	sub    $0x1,%ebx
f010658f:	85 db                	test   %ebx,%ebx
f0106591:	7f ef                	jg     f0106582 <printnum_v2+0xa2>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0106593:	89 74 24 04          	mov    %esi,0x4(%esp)
f0106597:	8b 74 24 04          	mov    0x4(%esp),%esi
f010659b:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010659e:	89 44 24 08          	mov    %eax,0x8(%esp)
f01065a2:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f01065a9:	00 
f01065aa:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01065ad:	89 14 24             	mov    %edx,(%esp)
f01065b0:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f01065b3:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f01065b7:	e8 d4 16 00 00       	call   f0107c90 <__umoddi3>
f01065bc:	89 74 24 04          	mov    %esi,0x4(%esp)
f01065c0:	0f be 80 ae 95 10 f0 	movsbl -0xfef6a52(%eax),%eax
f01065c7:	89 04 24             	mov    %eax,(%esp)
f01065ca:	ff 55 e4             	call   *-0x1c(%ebp)
}
f01065cd:	83 c4 4c             	add    $0x4c,%esp
f01065d0:	5b                   	pop    %ebx
f01065d1:	5e                   	pop    %esi
f01065d2:	5f                   	pop    %edi
f01065d3:	5d                   	pop    %ebp
f01065d4:	c3                   	ret    

f01065d5 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f01065d5:	55                   	push   %ebp
f01065d6:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f01065d8:	83 fa 01             	cmp    $0x1,%edx
f01065db:	7e 0e                	jle    f01065eb <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f01065dd:	8b 10                	mov    (%eax),%edx
f01065df:	8d 4a 08             	lea    0x8(%edx),%ecx
f01065e2:	89 08                	mov    %ecx,(%eax)
f01065e4:	8b 02                	mov    (%edx),%eax
f01065e6:	8b 52 04             	mov    0x4(%edx),%edx
f01065e9:	eb 22                	jmp    f010660d <getuint+0x38>
	else if (lflag)
f01065eb:	85 d2                	test   %edx,%edx
f01065ed:	74 10                	je     f01065ff <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f01065ef:	8b 10                	mov    (%eax),%edx
f01065f1:	8d 4a 04             	lea    0x4(%edx),%ecx
f01065f4:	89 08                	mov    %ecx,(%eax)
f01065f6:	8b 02                	mov    (%edx),%eax
f01065f8:	ba 00 00 00 00       	mov    $0x0,%edx
f01065fd:	eb 0e                	jmp    f010660d <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f01065ff:	8b 10                	mov    (%eax),%edx
f0106601:	8d 4a 04             	lea    0x4(%edx),%ecx
f0106604:	89 08                	mov    %ecx,(%eax)
f0106606:	8b 02                	mov    (%edx),%eax
f0106608:	ba 00 00 00 00       	mov    $0x0,%edx
}
f010660d:	5d                   	pop    %ebp
f010660e:	c3                   	ret    

f010660f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f010660f:	55                   	push   %ebp
f0106610:	89 e5                	mov    %esp,%ebp
f0106612:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0106615:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0106619:	8b 10                	mov    (%eax),%edx
f010661b:	3b 50 04             	cmp    0x4(%eax),%edx
f010661e:	73 0a                	jae    f010662a <sprintputch+0x1b>
		*b->buf++ = ch;
f0106620:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0106623:	88 0a                	mov    %cl,(%edx)
f0106625:	83 c2 01             	add    $0x1,%edx
f0106628:	89 10                	mov    %edx,(%eax)
}
f010662a:	5d                   	pop    %ebp
f010662b:	c3                   	ret    

f010662c <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f010662c:	55                   	push   %ebp
f010662d:	89 e5                	mov    %esp,%ebp
f010662f:	57                   	push   %edi
f0106630:	56                   	push   %esi
f0106631:	53                   	push   %ebx
f0106632:	83 ec 6c             	sub    $0x6c,%esp
f0106635:	8b 7d 10             	mov    0x10(%ebp),%edi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
f0106638:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
f010663f:	eb 1a                	jmp    f010665b <vprintfmt+0x2f>
	int base, lflag, width, precision, altflag,signflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0106641:	85 c0                	test   %eax,%eax
f0106643:	0f 84 66 06 00 00    	je     f0106caf <vprintfmt+0x683>
				return;
			putch(ch, putdat);
f0106649:	8b 55 0c             	mov    0xc(%ebp),%edx
f010664c:	89 54 24 04          	mov    %edx,0x4(%esp)
f0106650:	89 04 24             	mov    %eax,(%esp)
f0106653:	ff 55 08             	call   *0x8(%ebp)
f0106656:	eb 03                	jmp    f010665b <vprintfmt+0x2f>
f0106658:	8b 7d e4             	mov    -0x1c(%ebp),%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag,signflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f010665b:	0f b6 07             	movzbl (%edi),%eax
f010665e:	83 c7 01             	add    $0x1,%edi
f0106661:	83 f8 25             	cmp    $0x25,%eax
f0106664:	75 db                	jne    f0106641 <vprintfmt+0x15>
f0106666:	c6 45 cc 20          	movb   $0x20,-0x34(%ebp)
f010666a:	b9 00 00 00 00       	mov    $0x0,%ecx
f010666f:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
f0106676:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f010667b:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
f0106682:	be 00 00 00 00       	mov    $0x0,%esi
f0106687:	eb 06                	jmp    f010668f <vprintfmt+0x63>
f0106689:	c6 45 cc 2d          	movb   $0x2d,-0x34(%ebp)
f010668d:	89 c7                	mov    %eax,%edi
		precision = -1;
		lflag = 0;
		altflag = 0;
                signflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010668f:	0f b6 17             	movzbl (%edi),%edx
f0106692:	0f b6 c2             	movzbl %dl,%eax
f0106695:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0106698:	8d 47 01             	lea    0x1(%edi),%eax
f010669b:	83 ea 23             	sub    $0x23,%edx
f010669e:	80 fa 55             	cmp    $0x55,%dl
f01066a1:	0f 87 60 05 00 00    	ja     f0106c07 <vprintfmt+0x5db>
f01066a7:	0f b6 d2             	movzbl %dl,%edx
f01066aa:	ff 24 95 e0 96 10 f0 	jmp    *-0xfef6920(,%edx,4)
f01066b1:	b9 01 00 00 00       	mov    $0x1,%ecx
f01066b6:	eb d5                	jmp    f010668d <vprintfmt+0x61>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f01066b8:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f01066bb:	83 eb 30             	sub    $0x30,%ebx
				ch = *fmt;
f01066be:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
f01066c1:	8d 7a d0             	lea    -0x30(%edx),%edi
f01066c4:	83 ff 09             	cmp    $0x9,%edi
f01066c7:	76 08                	jbe    f01066d1 <vprintfmt+0xa5>
f01066c9:	eb 40                	jmp    f010670b <vprintfmt+0xdf>
f01066cb:	c6 45 cc 30          	movb   $0x30,-0x34(%ebp)
                        signflag = 1;
                        goto reswitch;
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
			goto reswitch;
f01066cf:	eb bc                	jmp    f010668d <vprintfmt+0x61>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f01066d1:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
f01066d4:	8d 1c 9b             	lea    (%ebx,%ebx,4),%ebx
f01066d7:	8d 5c 5a d0          	lea    -0x30(%edx,%ebx,2),%ebx
				ch = *fmt;
f01066db:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
f01066de:	8d 7a d0             	lea    -0x30(%edx),%edi
f01066e1:	83 ff 09             	cmp    $0x9,%edi
f01066e4:	76 eb                	jbe    f01066d1 <vprintfmt+0xa5>
f01066e6:	eb 23                	jmp    f010670b <vprintfmt+0xdf>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f01066e8:	8b 55 14             	mov    0x14(%ebp),%edx
f01066eb:	8d 5a 04             	lea    0x4(%edx),%ebx
f01066ee:	89 5d 14             	mov    %ebx,0x14(%ebp)
f01066f1:	8b 1a                	mov    (%edx),%ebx
			goto process_precision;
f01066f3:	eb 16                	jmp    f010670b <vprintfmt+0xdf>

		case '.':
			if (width < 0)
f01066f5:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01066f8:	c1 fa 1f             	sar    $0x1f,%edx
f01066fb:	f7 d2                	not    %edx
f01066fd:	21 55 d8             	and    %edx,-0x28(%ebp)
f0106700:	eb 8b                	jmp    f010668d <vprintfmt+0x61>
f0106702:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
f0106709:	eb 82                	jmp    f010668d <vprintfmt+0x61>

		process_precision:
			if (width < 0)
f010670b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f010670f:	0f 89 78 ff ff ff    	jns    f010668d <vprintfmt+0x61>
f0106715:	89 5d d8             	mov    %ebx,-0x28(%ebp)
f0106718:	8b 5d c8             	mov    -0x38(%ebp),%ebx
f010671b:	e9 6d ff ff ff       	jmp    f010668d <vprintfmt+0x61>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0106720:	83 c6 01             	add    $0x1,%esi
			goto reswitch;
f0106723:	e9 65 ff ff ff       	jmp    f010668d <vprintfmt+0x61>
f0106728:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f010672b:	8b 45 14             	mov    0x14(%ebp),%eax
f010672e:	8d 50 04             	lea    0x4(%eax),%edx
f0106731:	89 55 14             	mov    %edx,0x14(%ebp)
f0106734:	8b 55 0c             	mov    0xc(%ebp),%edx
f0106737:	89 54 24 04          	mov    %edx,0x4(%esp)
f010673b:	8b 00                	mov    (%eax),%eax
f010673d:	89 04 24             	mov    %eax,(%esp)
f0106740:	ff 55 08             	call   *0x8(%ebp)
f0106743:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;
f0106746:	e9 10 ff ff ff       	jmp    f010665b <vprintfmt+0x2f>
f010674b:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
f010674e:	8b 45 14             	mov    0x14(%ebp),%eax
f0106751:	8d 50 04             	lea    0x4(%eax),%edx
f0106754:	89 55 14             	mov    %edx,0x14(%ebp)
f0106757:	8b 00                	mov    (%eax),%eax
f0106759:	89 c2                	mov    %eax,%edx
f010675b:	c1 fa 1f             	sar    $0x1f,%edx
f010675e:	31 d0                	xor    %edx,%eax
f0106760:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0106762:	83 f8 08             	cmp    $0x8,%eax
f0106765:	7f 0b                	jg     f0106772 <vprintfmt+0x146>
f0106767:	8b 14 85 40 98 10 f0 	mov    -0xfef67c0(,%eax,4),%edx
f010676e:	85 d2                	test   %edx,%edx
f0106770:	75 26                	jne    f0106798 <vprintfmt+0x16c>
				printfmt(putch, putdat, "error %d", err);
f0106772:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0106776:	c7 44 24 08 bf 95 10 	movl   $0xf01095bf,0x8(%esp)
f010677d:	f0 
f010677e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0106781:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0106785:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0106788:	89 1c 24             	mov    %ebx,(%esp)
f010678b:	e8 a7 05 00 00       	call   f0106d37 <printfmt>
f0106790:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0106793:	e9 c3 fe ff ff       	jmp    f010665b <vprintfmt+0x2f>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
f0106798:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010679c:	c7 44 24 08 5e 86 10 	movl   $0xf010865e,0x8(%esp)
f01067a3:	f0 
f01067a4:	8b 45 0c             	mov    0xc(%ebp),%eax
f01067a7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01067ab:	8b 55 08             	mov    0x8(%ebp),%edx
f01067ae:	89 14 24             	mov    %edx,(%esp)
f01067b1:	e8 81 05 00 00       	call   f0106d37 <printfmt>
f01067b6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01067b9:	e9 9d fe ff ff       	jmp    f010665b <vprintfmt+0x2f>
f01067be:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01067c1:	89 c7                	mov    %eax,%edi
f01067c3:	89 d9                	mov    %ebx,%ecx
f01067c5:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01067c8:	89 45 c0             	mov    %eax,-0x40(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f01067cb:	8b 45 14             	mov    0x14(%ebp),%eax
f01067ce:	8d 50 04             	lea    0x4(%eax),%edx
f01067d1:	89 55 14             	mov    %edx,0x14(%ebp)
f01067d4:	8b 30                	mov    (%eax),%esi
f01067d6:	85 f6                	test   %esi,%esi
f01067d8:	75 05                	jne    f01067df <vprintfmt+0x1b3>
f01067da:	be c8 95 10 f0       	mov    $0xf01095c8,%esi
				p = "(null)";
			if (width > 0 && padc != '-')
f01067df:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
f01067e3:	7e 06                	jle    f01067eb <vprintfmt+0x1bf>
f01067e5:	80 7d cc 2d          	cmpb   $0x2d,-0x34(%ebp)
f01067e9:	75 10                	jne    f01067fb <vprintfmt+0x1cf>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01067eb:	0f be 06             	movsbl (%esi),%eax
f01067ee:	85 c0                	test   %eax,%eax
f01067f0:	0f 85 a2 00 00 00    	jne    f0106898 <vprintfmt+0x26c>
f01067f6:	e9 92 00 00 00       	jmp    f010688d <vprintfmt+0x261>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f01067fb:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f01067ff:	89 34 24             	mov    %esi,(%esp)
f0106802:	e8 54 06 00 00       	call   f0106e5b <strnlen>
f0106807:	8b 55 c0             	mov    -0x40(%ebp),%edx
f010680a:	29 c2                	sub    %eax,%edx
f010680c:	89 55 d8             	mov    %edx,-0x28(%ebp)
f010680f:	85 d2                	test   %edx,%edx
f0106811:	7e d8                	jle    f01067eb <vprintfmt+0x1bf>
					putch(padc, putdat);
f0106813:	0f be 4d cc          	movsbl -0x34(%ebp),%ecx
f0106817:	89 5d c0             	mov    %ebx,-0x40(%ebp)
f010681a:	89 d3                	mov    %edx,%ebx
f010681c:	89 75 d8             	mov    %esi,-0x28(%ebp)
f010681f:	89 7d bc             	mov    %edi,-0x44(%ebp)
f0106822:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0106825:	89 ce                	mov    %ecx,%esi
f0106827:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010682b:	89 34 24             	mov    %esi,(%esp)
f010682e:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0106831:	83 eb 01             	sub    $0x1,%ebx
f0106834:	85 db                	test   %ebx,%ebx
f0106836:	7f ef                	jg     f0106827 <vprintfmt+0x1fb>
f0106838:	8b 5d c0             	mov    -0x40(%ebp),%ebx
f010683b:	8b 75 d8             	mov    -0x28(%ebp),%esi
f010683e:	8b 7d bc             	mov    -0x44(%ebp),%edi
f0106841:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0106848:	eb a1                	jmp    f01067eb <vprintfmt+0x1bf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f010684a:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
f010684e:	74 1b                	je     f010686b <vprintfmt+0x23f>
f0106850:	8d 50 e0             	lea    -0x20(%eax),%edx
f0106853:	83 fa 5e             	cmp    $0x5e,%edx
f0106856:	76 13                	jbe    f010686b <vprintfmt+0x23f>
					putch('?', putdat);
f0106858:	8b 45 0c             	mov    0xc(%ebp),%eax
f010685b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010685f:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f0106866:	ff 55 08             	call   *0x8(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0106869:	eb 0d                	jmp    f0106878 <vprintfmt+0x24c>
					putch('?', putdat);
				else
					putch(ch, putdat);
f010686b:	8b 55 0c             	mov    0xc(%ebp),%edx
f010686e:	89 54 24 04          	mov    %edx,0x4(%esp)
f0106872:	89 04 24             	mov    %eax,(%esp)
f0106875:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0106878:	83 ef 01             	sub    $0x1,%edi
f010687b:	0f be 06             	movsbl (%esi),%eax
f010687e:	85 c0                	test   %eax,%eax
f0106880:	74 05                	je     f0106887 <vprintfmt+0x25b>
f0106882:	83 c6 01             	add    $0x1,%esi
f0106885:	eb 1a                	jmp    f01068a1 <vprintfmt+0x275>
f0106887:	89 7d d8             	mov    %edi,-0x28(%ebp)
f010688a:	8b 7d cc             	mov    -0x34(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f010688d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0106891:	7f 1f                	jg     f01068b2 <vprintfmt+0x286>
f0106893:	e9 c0 fd ff ff       	jmp    f0106658 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0106898:	83 c6 01             	add    $0x1,%esi
f010689b:	89 7d cc             	mov    %edi,-0x34(%ebp)
f010689e:	8b 7d d8             	mov    -0x28(%ebp),%edi
f01068a1:	85 db                	test   %ebx,%ebx
f01068a3:	78 a5                	js     f010684a <vprintfmt+0x21e>
f01068a5:	83 eb 01             	sub    $0x1,%ebx
f01068a8:	79 a0                	jns    f010684a <vprintfmt+0x21e>
f01068aa:	89 7d d8             	mov    %edi,-0x28(%ebp)
f01068ad:	8b 7d cc             	mov    -0x34(%ebp),%edi
f01068b0:	eb db                	jmp    f010688d <vprintfmt+0x261>
f01068b2:	8b 5d d8             	mov    -0x28(%ebp),%ebx
f01068b5:	8b 75 0c             	mov    0xc(%ebp),%esi
f01068b8:	89 7d d8             	mov    %edi,-0x28(%ebp)
f01068bb:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f01068be:	89 74 24 04          	mov    %esi,0x4(%esp)
f01068c2:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f01068c9:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f01068cb:	83 eb 01             	sub    $0x1,%ebx
f01068ce:	85 db                	test   %ebx,%ebx
f01068d0:	7f ec                	jg     f01068be <vprintfmt+0x292>
f01068d2:	8b 7d d8             	mov    -0x28(%ebp),%edi
f01068d5:	e9 81 fd ff ff       	jmp    f010665b <vprintfmt+0x2f>
f01068da:	89 45 e4             	mov    %eax,-0x1c(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f01068dd:	83 fe 01             	cmp    $0x1,%esi
f01068e0:	7e 10                	jle    f01068f2 <vprintfmt+0x2c6>
		return va_arg(*ap, long long);
f01068e2:	8b 45 14             	mov    0x14(%ebp),%eax
f01068e5:	8d 50 08             	lea    0x8(%eax),%edx
f01068e8:	89 55 14             	mov    %edx,0x14(%ebp)
f01068eb:	8b 18                	mov    (%eax),%ebx
f01068ed:	8b 70 04             	mov    0x4(%eax),%esi
f01068f0:	eb 26                	jmp    f0106918 <vprintfmt+0x2ec>
	else if (lflag)
f01068f2:	85 f6                	test   %esi,%esi
f01068f4:	74 12                	je     f0106908 <vprintfmt+0x2dc>
		return va_arg(*ap, long);
f01068f6:	8b 45 14             	mov    0x14(%ebp),%eax
f01068f9:	8d 50 04             	lea    0x4(%eax),%edx
f01068fc:	89 55 14             	mov    %edx,0x14(%ebp)
f01068ff:	8b 18                	mov    (%eax),%ebx
f0106901:	89 de                	mov    %ebx,%esi
f0106903:	c1 fe 1f             	sar    $0x1f,%esi
f0106906:	eb 10                	jmp    f0106918 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
f0106908:	8b 45 14             	mov    0x14(%ebp),%eax
f010690b:	8d 50 04             	lea    0x4(%eax),%edx
f010690e:	89 55 14             	mov    %edx,0x14(%ebp)
f0106911:	8b 18                	mov    (%eax),%ebx
f0106913:	89 de                	mov    %ebx,%esi
f0106915:	c1 fe 1f             	sar    $0x1f,%esi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
                        if(signflag == 1){
f0106918:	83 f9 01             	cmp    $0x1,%ecx
f010691b:	75 1e                	jne    f010693b <vprintfmt+0x30f>
                               if((long long)num > 0){
f010691d:	85 f6                	test   %esi,%esi
f010691f:	78 1a                	js     f010693b <vprintfmt+0x30f>
f0106921:	85 f6                	test   %esi,%esi
f0106923:	7f 05                	jg     f010692a <vprintfmt+0x2fe>
f0106925:	83 fb 00             	cmp    $0x0,%ebx
f0106928:	76 11                	jbe    f010693b <vprintfmt+0x30f>
                                   putch('+',putdat);
f010692a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010692d:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0106931:	c7 04 24 2b 00 00 00 	movl   $0x2b,(%esp)
f0106938:	ff 55 08             	call   *0x8(%ebp)
                               }
                        }
			if ((long long) num < 0) {
f010693b:	85 f6                	test   %esi,%esi
f010693d:	78 13                	js     f0106952 <vprintfmt+0x326>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f010693f:	89 5d b0             	mov    %ebx,-0x50(%ebp)
f0106942:	89 75 b4             	mov    %esi,-0x4c(%ebp)
f0106945:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0106948:	b8 0a 00 00 00       	mov    $0xa,%eax
f010694d:	e9 da 00 00 00       	jmp    f0106a2c <vprintfmt+0x400>
                               if((long long)num > 0){
                                   putch('+',putdat);
                               }
                        }
			if ((long long) num < 0) {
				putch('-', putdat);
f0106952:	8b 45 0c             	mov    0xc(%ebp),%eax
f0106955:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106959:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f0106960:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f0106963:	89 da                	mov    %ebx,%edx
f0106965:	89 f1                	mov    %esi,%ecx
f0106967:	f7 da                	neg    %edx
f0106969:	83 d1 00             	adc    $0x0,%ecx
f010696c:	f7 d9                	neg    %ecx
f010696e:	89 55 b0             	mov    %edx,-0x50(%ebp)
f0106971:	89 4d b4             	mov    %ecx,-0x4c(%ebp)
f0106974:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0106977:	b8 0a 00 00 00       	mov    $0xa,%eax
f010697c:	e9 ab 00 00 00       	jmp    f0106a2c <vprintfmt+0x400>
f0106981:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0106984:	89 f2                	mov    %esi,%edx
f0106986:	8d 45 14             	lea    0x14(%ebp),%eax
f0106989:	e8 47 fc ff ff       	call   f01065d5 <getuint>
f010698e:	89 45 b0             	mov    %eax,-0x50(%ebp)
f0106991:	89 55 b4             	mov    %edx,-0x4c(%ebp)
f0106994:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0106997:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
f010699c:	e9 8b 00 00 00       	jmp    f0106a2c <vprintfmt+0x400>
f01069a1:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			putch('0', putdat);
f01069a4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01069a7:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f01069ab:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f01069b2:	ff 55 08             	call   *0x8(%ebp)
			num = getuint(&ap,lflag);
f01069b5:	89 f2                	mov    %esi,%edx
f01069b7:	8d 45 14             	lea    0x14(%ebp),%eax
f01069ba:	e8 16 fc ff ff       	call   f01065d5 <getuint>
f01069bf:	89 45 b0             	mov    %eax,-0x50(%ebp)
f01069c2:	89 55 b4             	mov    %edx,-0x4c(%ebp)
f01069c5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01069c8:	b8 08 00 00 00       	mov    $0x8,%eax
                        base = 8;
			goto number;
f01069cd:	eb 5d                	jmp    f0106a2c <vprintfmt+0x400>
f01069cf:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
f01069d2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01069d5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01069d9:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f01069e0:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f01069e3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01069e7:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f01069ee:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
f01069f1:	8b 45 14             	mov    0x14(%ebp),%eax
f01069f4:	8d 50 04             	lea    0x4(%eax),%edx
f01069f7:	89 55 14             	mov    %edx,0x14(%ebp)
f01069fa:	8b 10                	mov    (%eax),%edx
f01069fc:	b9 00 00 00 00       	mov    $0x0,%ecx
f0106a01:	89 55 b0             	mov    %edx,-0x50(%ebp)
f0106a04:	89 4d b4             	mov    %ecx,-0x4c(%ebp)
f0106a07:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0106a0a:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f0106a0f:	eb 1b                	jmp    f0106a2c <vprintfmt+0x400>
f0106a11:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0106a14:	89 f2                	mov    %esi,%edx
f0106a16:	8d 45 14             	lea    0x14(%ebp),%eax
f0106a19:	e8 b7 fb ff ff       	call   f01065d5 <getuint>
f0106a1e:	89 45 b0             	mov    %eax,-0x50(%ebp)
f0106a21:	89 55 b4             	mov    %edx,-0x4c(%ebp)
f0106a24:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0106a27:	b8 10 00 00 00       	mov    $0x10,%eax
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
f0106a2c:	0f be 4d cc          	movsbl -0x34(%ebp),%ecx
f0106a30:	89 4d d0             	mov    %ecx,-0x30(%ebp)
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0106a33:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0106a36:	83 7d b4 00          	cmpl   $0x0,-0x4c(%ebp)
f0106a3a:	77 09                	ja     f0106a45 <vprintfmt+0x419>
f0106a3c:	39 45 b0             	cmp    %eax,-0x50(%ebp)
f0106a3f:	0f 82 ac 00 00 00    	jb     f0106af1 <vprintfmt+0x4c5>
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
f0106a45:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0106a48:	89 5c 24 10          	mov    %ebx,0x10(%esp)
f0106a4c:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0106a4f:	83 ea 01             	sub    $0x1,%edx
f0106a52:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0106a56:	89 44 24 08          	mov    %eax,0x8(%esp)
f0106a5a:	8b 44 24 08          	mov    0x8(%esp),%eax
f0106a5e:	8b 54 24 0c          	mov    0xc(%esp),%edx
f0106a62:	89 45 c0             	mov    %eax,-0x40(%ebp)
f0106a65:	89 55 c4             	mov    %edx,-0x3c(%ebp)
f0106a68:	8b 55 cc             	mov    -0x34(%ebp),%edx
f0106a6b:	89 54 24 08          	mov    %edx,0x8(%esp)
f0106a6f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0106a76:	00 
f0106a77:	8b 4d b0             	mov    -0x50(%ebp),%ecx
f0106a7a:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
f0106a7d:	89 0c 24             	mov    %ecx,(%esp)
f0106a80:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0106a84:	e8 d7 10 00 00       	call   f0107b60 <__udivdi3>
f0106a89:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f0106a8c:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0106a8f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0106a93:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0106a97:	89 04 24             	mov    %eax,(%esp)
f0106a9a:	89 54 24 04          	mov    %edx,0x4(%esp)
f0106a9e:	8b 55 0c             	mov    0xc(%ebp),%edx
f0106aa1:	8b 45 08             	mov    0x8(%ebp),%eax
f0106aa4:	e8 37 fa ff ff       	call   f01064e0 <printnum_v2>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0106aa9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0106aac:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0106ab0:	8b 74 24 04          	mov    0x4(%esp),%esi
f0106ab4:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0106ab7:	89 44 24 08          	mov    %eax,0x8(%esp)
f0106abb:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0106ac2:	00 
f0106ac3:	8b 55 b0             	mov    -0x50(%ebp),%edx
f0106ac6:	8b 4d b4             	mov    -0x4c(%ebp),%ecx
f0106ac9:	89 14 24             	mov    %edx,(%esp)
f0106acc:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0106ad0:	e8 bb 11 00 00       	call   f0107c90 <__umoddi3>
f0106ad5:	89 74 24 04          	mov    %esi,0x4(%esp)
f0106ad9:	0f be 80 ae 95 10 f0 	movsbl -0xfef6a52(%eax),%eax
f0106ae0:	89 04 24             	mov    %eax,(%esp)
f0106ae3:	ff 55 08             	call   *0x8(%ebp)
        if(padc == '-'){
f0106ae6:	83 7d d0 2d          	cmpl   $0x2d,-0x30(%ebp)
f0106aea:	74 54                	je     f0106b40 <vprintfmt+0x514>
f0106aec:	e9 67 fb ff ff       	jmp    f0106658 <vprintfmt+0x2c>
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
f0106af1:	83 7d d0 2d          	cmpl   $0x2d,-0x30(%ebp)
f0106af5:	8d 76 00             	lea    0x0(%esi),%esi
f0106af8:	0f 84 2a 01 00 00    	je     f0106c28 <vprintfmt+0x5fc>
		while (--width > 0)
f0106afe:	8b 7d d8             	mov    -0x28(%ebp),%edi
f0106b01:	83 ef 01             	sub    $0x1,%edi
f0106b04:	85 ff                	test   %edi,%edi
f0106b06:	0f 8e 5e 01 00 00    	jle    f0106c6a <vprintfmt+0x63e>
f0106b0c:	8b 4d b0             	mov    -0x50(%ebp),%ecx
f0106b0f:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
f0106b12:	89 4d d8             	mov    %ecx,-0x28(%ebp)
f0106b15:	89 5d dc             	mov    %ebx,-0x24(%ebp)
f0106b18:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0106b1b:	8b 75 0c             	mov    0xc(%ebp),%esi
			putch(padc, putdat);
f0106b1e:	89 74 24 04          	mov    %esi,0x4(%esp)
f0106b22:	89 1c 24             	mov    %ebx,(%esp)
f0106b25:	ff 55 08             	call   *0x8(%ebp)
	if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
		while (--width > 0)
f0106b28:	83 ef 01             	sub    $0x1,%edi
f0106b2b:	85 ff                	test   %edi,%edi
f0106b2d:	7f ef                	jg     f0106b1e <vprintfmt+0x4f2>
f0106b2f:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0106b32:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0106b35:	89 45 b0             	mov    %eax,-0x50(%ebp)
f0106b38:	89 55 b4             	mov    %edx,-0x4c(%ebp)
f0106b3b:	e9 2a 01 00 00       	jmp    f0106c6a <vprintfmt+0x63e>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
        if(padc == '-'){
           while (--width > 0)
f0106b40:	8b 5d d8             	mov    -0x28(%ebp),%ebx
f0106b43:	83 eb 01             	sub    $0x1,%ebx
f0106b46:	85 db                	test   %ebx,%ebx
f0106b48:	0f 8e 0a fb ff ff    	jle    f0106658 <vprintfmt+0x2c>
f0106b4e:	8b 75 0c             	mov    0xc(%ebp),%esi
f0106b51:	89 7d d8             	mov    %edi,-0x28(%ebp)
f0106b54:	8b 7d 08             	mov    0x8(%ebp),%edi
			putch(' ', putdat);
f0106b57:	89 74 24 04          	mov    %esi,0x4(%esp)
f0106b5b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0106b62:	ff d7                	call   *%edi
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
        if(padc == '-'){
           while (--width > 0)
f0106b64:	83 eb 01             	sub    $0x1,%ebx
f0106b67:	85 db                	test   %ebx,%ebx
f0106b69:	7f ec                	jg     f0106b57 <vprintfmt+0x52b>
f0106b6b:	8b 7d d8             	mov    -0x28(%ebp),%edi
f0106b6e:	e9 e8 fa ff ff       	jmp    f010665b <vprintfmt+0x2f>
f0106b73:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
            char* n;
            if ((n = va_arg(ap, char *)) == NULL)
f0106b76:	8b 45 14             	mov    0x14(%ebp),%eax
f0106b79:	8d 50 04             	lea    0x4(%eax),%edx
f0106b7c:	89 55 14             	mov    %edx,0x14(%ebp)
f0106b7f:	8b 00                	mov    (%eax),%eax
f0106b81:	85 c0                	test   %eax,%eax
f0106b83:	75 2a                	jne    f0106baf <vprintfmt+0x583>
		  printfmt(putch,putdat,"%s",null_error);
f0106b85:	c7 44 24 0c 64 96 10 	movl   $0xf0109664,0xc(%esp)
f0106b8c:	f0 
f0106b8d:	c7 44 24 08 5e 86 10 	movl   $0xf010865e,0x8(%esp)
f0106b94:	f0 
f0106b95:	8b 55 0c             	mov    0xc(%ebp),%edx
f0106b98:	89 54 24 04          	mov    %edx,0x4(%esp)
f0106b9c:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0106b9f:	89 0c 24             	mov    %ecx,(%esp)
f0106ba2:	e8 90 01 00 00       	call   f0106d37 <printfmt>
f0106ba7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0106baa:	e9 ac fa ff ff       	jmp    f010665b <vprintfmt+0x2f>
            else if((*(int*)putdat) > 127){
f0106baf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0106bb2:	8b 13                	mov    (%ebx),%edx
f0106bb4:	83 fa 7f             	cmp    $0x7f,%edx
f0106bb7:	7e 29                	jle    f0106be2 <vprintfmt+0x5b6>
                  *n = *(int*)putdat;
f0106bb9:	88 10                	mov    %dl,(%eax)
                  printfmt(putch,putdat,"%s",overflow_error);
f0106bbb:	c7 44 24 0c 9c 96 10 	movl   $0xf010969c,0xc(%esp)
f0106bc2:	f0 
f0106bc3:	c7 44 24 08 5e 86 10 	movl   $0xf010865e,0x8(%esp)
f0106bca:	f0 
f0106bcb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0106bcf:	8b 45 08             	mov    0x8(%ebp),%eax
f0106bd2:	89 04 24             	mov    %eax,(%esp)
f0106bd5:	e8 5d 01 00 00       	call   f0106d37 <printfmt>
f0106bda:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0106bdd:	e9 79 fa ff ff       	jmp    f010665b <vprintfmt+0x2f>
            }
            else
                  *n = *(int*)putdat;
f0106be2:	88 10                	mov    %dl,(%eax)
f0106be4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0106be7:	e9 6f fa ff ff       	jmp    f010665b <vprintfmt+0x2f>
f0106bec:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0106bef:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            break;
        }
		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0106bf2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0106bf5:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0106bf9:	89 14 24             	mov    %edx,(%esp)
f0106bfc:	ff 55 08             	call   *0x8(%ebp)
f0106bff:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;
f0106c02:	e9 54 fa ff ff       	jmp    f010665b <vprintfmt+0x2f>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0106c07:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0106c0a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0106c0e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f0106c15:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f0106c18:	8d 47 ff             	lea    -0x1(%edi),%eax
f0106c1b:	80 38 25             	cmpb   $0x25,(%eax)
f0106c1e:	0f 84 37 fa ff ff    	je     f010665b <vprintfmt+0x2f>
f0106c24:	89 c7                	mov    %eax,%edi
f0106c26:	eb f0                	jmp    f0106c18 <vprintfmt+0x5ec>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0106c28:	8b 45 0c             	mov    0xc(%ebp),%eax
f0106c2b:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106c2f:	8b 74 24 04          	mov    0x4(%esp),%esi
f0106c33:	8b 55 cc             	mov    -0x34(%ebp),%edx
f0106c36:	89 54 24 08          	mov    %edx,0x8(%esp)
f0106c3a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0106c41:	00 
f0106c42:	8b 45 b0             	mov    -0x50(%ebp),%eax
f0106c45:	8b 55 b4             	mov    -0x4c(%ebp),%edx
f0106c48:	89 04 24             	mov    %eax,(%esp)
f0106c4b:	89 54 24 04          	mov    %edx,0x4(%esp)
f0106c4f:	e8 3c 10 00 00       	call   f0107c90 <__umoddi3>
f0106c54:	89 74 24 04          	mov    %esi,0x4(%esp)
f0106c58:	0f be 80 ae 95 10 f0 	movsbl -0xfef6a52(%eax),%eax
f0106c5f:	89 04 24             	mov    %eax,(%esp)
f0106c62:	ff 55 08             	call   *0x8(%ebp)
f0106c65:	e9 d6 fe ff ff       	jmp    f0106b40 <vprintfmt+0x514>
f0106c6a:	8b 55 0c             	mov    0xc(%ebp),%edx
f0106c6d:	89 54 24 04          	mov    %edx,0x4(%esp)
f0106c71:	8b 74 24 04          	mov    0x4(%esp),%esi
f0106c75:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0106c78:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0106c7c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0106c83:	00 
f0106c84:	8b 45 b0             	mov    -0x50(%ebp),%eax
f0106c87:	8b 55 b4             	mov    -0x4c(%ebp),%edx
f0106c8a:	89 04 24             	mov    %eax,(%esp)
f0106c8d:	89 54 24 04          	mov    %edx,0x4(%esp)
f0106c91:	e8 fa 0f 00 00       	call   f0107c90 <__umoddi3>
f0106c96:	89 74 24 04          	mov    %esi,0x4(%esp)
f0106c9a:	0f be 80 ae 95 10 f0 	movsbl -0xfef6a52(%eax),%eax
f0106ca1:	89 04 24             	mov    %eax,(%esp)
f0106ca4:	ff 55 08             	call   *0x8(%ebp)
f0106ca7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0106caa:	e9 ac f9 ff ff       	jmp    f010665b <vprintfmt+0x2f>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
f0106caf:	83 c4 6c             	add    $0x6c,%esp
f0106cb2:	5b                   	pop    %ebx
f0106cb3:	5e                   	pop    %esi
f0106cb4:	5f                   	pop    %edi
f0106cb5:	5d                   	pop    %ebp
f0106cb6:	c3                   	ret    

f0106cb7 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0106cb7:	55                   	push   %ebp
f0106cb8:	89 e5                	mov    %esp,%ebp
f0106cba:	83 ec 28             	sub    $0x28,%esp
f0106cbd:	8b 45 08             	mov    0x8(%ebp),%eax
f0106cc0:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
f0106cc3:	85 c0                	test   %eax,%eax
f0106cc5:	74 04                	je     f0106ccb <vsnprintf+0x14>
f0106cc7:	85 d2                	test   %edx,%edx
f0106cc9:	7f 07                	jg     f0106cd2 <vsnprintf+0x1b>
f0106ccb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0106cd0:	eb 3b                	jmp    f0106d0d <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
f0106cd2:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0106cd5:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
f0106cd9:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0106cdc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0106ce3:	8b 45 14             	mov    0x14(%ebp),%eax
f0106ce6:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0106cea:	8b 45 10             	mov    0x10(%ebp),%eax
f0106ced:	89 44 24 08          	mov    %eax,0x8(%esp)
f0106cf1:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0106cf4:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106cf8:	c7 04 24 0f 66 10 f0 	movl   $0xf010660f,(%esp)
f0106cff:	e8 28 f9 ff ff       	call   f010662c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0106d04:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0106d07:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0106d0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
f0106d0d:	c9                   	leave  
f0106d0e:	c3                   	ret    

f0106d0f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0106d0f:	55                   	push   %ebp
f0106d10:	89 e5                	mov    %esp,%ebp
f0106d12:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
f0106d15:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
f0106d18:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0106d1c:	8b 45 10             	mov    0x10(%ebp),%eax
f0106d1f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0106d23:	8b 45 0c             	mov    0xc(%ebp),%eax
f0106d26:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106d2a:	8b 45 08             	mov    0x8(%ebp),%eax
f0106d2d:	89 04 24             	mov    %eax,(%esp)
f0106d30:	e8 82 ff ff ff       	call   f0106cb7 <vsnprintf>
	va_end(ap);

	return rc;
}
f0106d35:	c9                   	leave  
f0106d36:	c3                   	ret    

f0106d37 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0106d37:	55                   	push   %ebp
f0106d38:	89 e5                	mov    %esp,%ebp
f0106d3a:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
f0106d3d:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
f0106d40:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0106d44:	8b 45 10             	mov    0x10(%ebp),%eax
f0106d47:	89 44 24 08          	mov    %eax,0x8(%esp)
f0106d4b:	8b 45 0c             	mov    0xc(%ebp),%eax
f0106d4e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106d52:	8b 45 08             	mov    0x8(%ebp),%eax
f0106d55:	89 04 24             	mov    %eax,(%esp)
f0106d58:	e8 cf f8 ff ff       	call   f010662c <vprintfmt>
	va_end(ap);
}
f0106d5d:	c9                   	leave  
f0106d5e:	c3                   	ret    
	...

f0106d60 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0106d60:	55                   	push   %ebp
f0106d61:	89 e5                	mov    %esp,%ebp
f0106d63:	57                   	push   %edi
f0106d64:	56                   	push   %esi
f0106d65:	53                   	push   %ebx
f0106d66:	83 ec 1c             	sub    $0x1c,%esp
f0106d69:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0106d6c:	85 c0                	test   %eax,%eax
f0106d6e:	74 10                	je     f0106d80 <readline+0x20>
		cprintf("%s", prompt);
f0106d70:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106d74:	c7 04 24 5e 86 10 f0 	movl   $0xf010865e,(%esp)
f0106d7b:	e8 87 dd ff ff       	call   f0104b07 <cprintf>

	i = 0;
	echoing = iscons(0);
f0106d80:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0106d87:	e8 7a 97 ff ff       	call   f0100506 <iscons>
f0106d8c:	89 c7                	mov    %eax,%edi
f0106d8e:	be 00 00 00 00       	mov    $0x0,%esi
	while (1) {
		c = getchar();
f0106d93:	e8 5d 97 ff ff       	call   f01004f5 <getchar>
f0106d98:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0106d9a:	85 c0                	test   %eax,%eax
f0106d9c:	79 17                	jns    f0106db5 <readline+0x55>
			cprintf("read error: %e\n", c);
f0106d9e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106da2:	c7 04 24 64 98 10 f0 	movl   $0xf0109864,(%esp)
f0106da9:	e8 59 dd ff ff       	call   f0104b07 <cprintf>
f0106dae:	b8 00 00 00 00       	mov    $0x0,%eax
			return NULL;
f0106db3:	eb 76                	jmp    f0106e2b <readline+0xcb>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0106db5:	83 f8 08             	cmp    $0x8,%eax
f0106db8:	74 08                	je     f0106dc2 <readline+0x62>
f0106dba:	83 f8 7f             	cmp    $0x7f,%eax
f0106dbd:	8d 76 00             	lea    0x0(%esi),%esi
f0106dc0:	75 19                	jne    f0106ddb <readline+0x7b>
f0106dc2:	85 f6                	test   %esi,%esi
f0106dc4:	7e 15                	jle    f0106ddb <readline+0x7b>
			if (echoing)
f0106dc6:	85 ff                	test   %edi,%edi
f0106dc8:	74 0c                	je     f0106dd6 <readline+0x76>
				cputchar('\b');
f0106dca:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
f0106dd1:	e8 34 99 ff ff       	call   f010070a <cputchar>
			i--;
f0106dd6:	83 ee 01             	sub    $0x1,%esi
	while (1) {
		c = getchar();
		if (c < 0) {
			cprintf("read error: %e\n", c);
			return NULL;
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0106dd9:	eb b8                	jmp    f0106d93 <readline+0x33>
			if (echoing)
				cputchar('\b');
			i--;
		} else if (c >= ' ' && i < BUFLEN-1) {
f0106ddb:	83 fb 1f             	cmp    $0x1f,%ebx
f0106dde:	66 90                	xchg   %ax,%ax
f0106de0:	7e 23                	jle    f0106e05 <readline+0xa5>
f0106de2:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0106de8:	7f 1b                	jg     f0106e05 <readline+0xa5>
			if (echoing)
f0106dea:	85 ff                	test   %edi,%edi
f0106dec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106df0:	74 08                	je     f0106dfa <readline+0x9a>
				cputchar(c);
f0106df2:	89 1c 24             	mov    %ebx,(%esp)
f0106df5:	e8 10 99 ff ff       	call   f010070a <cputchar>
			buf[i++] = c;
f0106dfa:	88 9e a0 da 24 f0    	mov    %bl,-0xfdb2560(%esi)
f0106e00:	83 c6 01             	add    $0x1,%esi
f0106e03:	eb 8e                	jmp    f0106d93 <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f0106e05:	83 fb 0a             	cmp    $0xa,%ebx
f0106e08:	74 05                	je     f0106e0f <readline+0xaf>
f0106e0a:	83 fb 0d             	cmp    $0xd,%ebx
f0106e0d:	75 84                	jne    f0106d93 <readline+0x33>
			if (echoing)
f0106e0f:	85 ff                	test   %edi,%edi
f0106e11:	74 0c                	je     f0106e1f <readline+0xbf>
				cputchar('\n');
f0106e13:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
f0106e1a:	e8 eb 98 ff ff       	call   f010070a <cputchar>
			buf[i] = 0;
f0106e1f:	c6 86 a0 da 24 f0 00 	movb   $0x0,-0xfdb2560(%esi)
f0106e26:	b8 a0 da 24 f0       	mov    $0xf024daa0,%eax
			return buf;
		}
	}
}
f0106e2b:	83 c4 1c             	add    $0x1c,%esp
f0106e2e:	5b                   	pop    %ebx
f0106e2f:	5e                   	pop    %esi
f0106e30:	5f                   	pop    %edi
f0106e31:	5d                   	pop    %ebp
f0106e32:	c3                   	ret    
	...

f0106e40 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0106e40:	55                   	push   %ebp
f0106e41:	89 e5                	mov    %esp,%ebp
f0106e43:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0106e46:	b8 00 00 00 00       	mov    $0x0,%eax
f0106e4b:	80 3a 00             	cmpb   $0x0,(%edx)
f0106e4e:	74 09                	je     f0106e59 <strlen+0x19>
		n++;
f0106e50:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0106e53:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0106e57:	75 f7                	jne    f0106e50 <strlen+0x10>
		n++;
	return n;
}
f0106e59:	5d                   	pop    %ebp
f0106e5a:	c3                   	ret    

f0106e5b <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0106e5b:	55                   	push   %ebp
f0106e5c:	89 e5                	mov    %esp,%ebp
f0106e5e:	53                   	push   %ebx
f0106e5f:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0106e62:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0106e65:	85 c9                	test   %ecx,%ecx
f0106e67:	74 19                	je     f0106e82 <strnlen+0x27>
f0106e69:	80 3b 00             	cmpb   $0x0,(%ebx)
f0106e6c:	74 14                	je     f0106e82 <strnlen+0x27>
f0106e6e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
f0106e73:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0106e76:	39 c8                	cmp    %ecx,%eax
f0106e78:	74 0d                	je     f0106e87 <strnlen+0x2c>
f0106e7a:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
f0106e7e:	75 f3                	jne    f0106e73 <strnlen+0x18>
f0106e80:	eb 05                	jmp    f0106e87 <strnlen+0x2c>
f0106e82:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
f0106e87:	5b                   	pop    %ebx
f0106e88:	5d                   	pop    %ebp
f0106e89:	c3                   	ret    

f0106e8a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0106e8a:	55                   	push   %ebp
f0106e8b:	89 e5                	mov    %esp,%ebp
f0106e8d:	53                   	push   %ebx
f0106e8e:	8b 45 08             	mov    0x8(%ebp),%eax
f0106e91:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0106e94:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0106e99:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
f0106e9d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f0106ea0:	83 c2 01             	add    $0x1,%edx
f0106ea3:	84 c9                	test   %cl,%cl
f0106ea5:	75 f2                	jne    f0106e99 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f0106ea7:	5b                   	pop    %ebx
f0106ea8:	5d                   	pop    %ebp
f0106ea9:	c3                   	ret    

f0106eaa <strcat>:

char *
strcat(char *dst, const char *src)
{
f0106eaa:	55                   	push   %ebp
f0106eab:	89 e5                	mov    %esp,%ebp
f0106ead:	53                   	push   %ebx
f0106eae:	83 ec 08             	sub    $0x8,%esp
f0106eb1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0106eb4:	89 1c 24             	mov    %ebx,(%esp)
f0106eb7:	e8 84 ff ff ff       	call   f0106e40 <strlen>
	strcpy(dst + len, src);
f0106ebc:	8b 55 0c             	mov    0xc(%ebp),%edx
f0106ebf:	89 54 24 04          	mov    %edx,0x4(%esp)
f0106ec3:	8d 04 03             	lea    (%ebx,%eax,1),%eax
f0106ec6:	89 04 24             	mov    %eax,(%esp)
f0106ec9:	e8 bc ff ff ff       	call   f0106e8a <strcpy>
	return dst;
}
f0106ece:	89 d8                	mov    %ebx,%eax
f0106ed0:	83 c4 08             	add    $0x8,%esp
f0106ed3:	5b                   	pop    %ebx
f0106ed4:	5d                   	pop    %ebp
f0106ed5:	c3                   	ret    

f0106ed6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0106ed6:	55                   	push   %ebp
f0106ed7:	89 e5                	mov    %esp,%ebp
f0106ed9:	56                   	push   %esi
f0106eda:	53                   	push   %ebx
f0106edb:	8b 45 08             	mov    0x8(%ebp),%eax
f0106ede:	8b 55 0c             	mov    0xc(%ebp),%edx
f0106ee1:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0106ee4:	85 f6                	test   %esi,%esi
f0106ee6:	74 18                	je     f0106f00 <strncpy+0x2a>
f0106ee8:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
f0106eed:	0f b6 1a             	movzbl (%edx),%ebx
f0106ef0:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0106ef3:	80 3a 01             	cmpb   $0x1,(%edx)
f0106ef6:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0106ef9:	83 c1 01             	add    $0x1,%ecx
f0106efc:	39 ce                	cmp    %ecx,%esi
f0106efe:	77 ed                	ja     f0106eed <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0106f00:	5b                   	pop    %ebx
f0106f01:	5e                   	pop    %esi
f0106f02:	5d                   	pop    %ebp
f0106f03:	c3                   	ret    

f0106f04 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0106f04:	55                   	push   %ebp
f0106f05:	89 e5                	mov    %esp,%ebp
f0106f07:	56                   	push   %esi
f0106f08:	53                   	push   %ebx
f0106f09:	8b 75 08             	mov    0x8(%ebp),%esi
f0106f0c:	8b 55 0c             	mov    0xc(%ebp),%edx
f0106f0f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0106f12:	89 f0                	mov    %esi,%eax
f0106f14:	85 c9                	test   %ecx,%ecx
f0106f16:	74 27                	je     f0106f3f <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
f0106f18:	83 e9 01             	sub    $0x1,%ecx
f0106f1b:	74 1d                	je     f0106f3a <strlcpy+0x36>
f0106f1d:	0f b6 1a             	movzbl (%edx),%ebx
f0106f20:	84 db                	test   %bl,%bl
f0106f22:	74 16                	je     f0106f3a <strlcpy+0x36>
			*dst++ = *src++;
f0106f24:	88 18                	mov    %bl,(%eax)
f0106f26:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0106f29:	83 e9 01             	sub    $0x1,%ecx
f0106f2c:	74 0e                	je     f0106f3c <strlcpy+0x38>
			*dst++ = *src++;
f0106f2e:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0106f31:	0f b6 1a             	movzbl (%edx),%ebx
f0106f34:	84 db                	test   %bl,%bl
f0106f36:	75 ec                	jne    f0106f24 <strlcpy+0x20>
f0106f38:	eb 02                	jmp    f0106f3c <strlcpy+0x38>
f0106f3a:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
f0106f3c:	c6 00 00             	movb   $0x0,(%eax)
f0106f3f:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
f0106f41:	5b                   	pop    %ebx
f0106f42:	5e                   	pop    %esi
f0106f43:	5d                   	pop    %ebp
f0106f44:	c3                   	ret    

f0106f45 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0106f45:	55                   	push   %ebp
f0106f46:	89 e5                	mov    %esp,%ebp
f0106f48:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0106f4b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0106f4e:	0f b6 01             	movzbl (%ecx),%eax
f0106f51:	84 c0                	test   %al,%al
f0106f53:	74 15                	je     f0106f6a <strcmp+0x25>
f0106f55:	3a 02                	cmp    (%edx),%al
f0106f57:	75 11                	jne    f0106f6a <strcmp+0x25>
		p++, q++;
f0106f59:	83 c1 01             	add    $0x1,%ecx
f0106f5c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0106f5f:	0f b6 01             	movzbl (%ecx),%eax
f0106f62:	84 c0                	test   %al,%al
f0106f64:	74 04                	je     f0106f6a <strcmp+0x25>
f0106f66:	3a 02                	cmp    (%edx),%al
f0106f68:	74 ef                	je     f0106f59 <strcmp+0x14>
f0106f6a:	0f b6 c0             	movzbl %al,%eax
f0106f6d:	0f b6 12             	movzbl (%edx),%edx
f0106f70:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0106f72:	5d                   	pop    %ebp
f0106f73:	c3                   	ret    

f0106f74 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0106f74:	55                   	push   %ebp
f0106f75:	89 e5                	mov    %esp,%ebp
f0106f77:	53                   	push   %ebx
f0106f78:	8b 55 08             	mov    0x8(%ebp),%edx
f0106f7b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0106f7e:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
f0106f81:	85 c0                	test   %eax,%eax
f0106f83:	74 23                	je     f0106fa8 <strncmp+0x34>
f0106f85:	0f b6 1a             	movzbl (%edx),%ebx
f0106f88:	84 db                	test   %bl,%bl
f0106f8a:	74 25                	je     f0106fb1 <strncmp+0x3d>
f0106f8c:	3a 19                	cmp    (%ecx),%bl
f0106f8e:	75 21                	jne    f0106fb1 <strncmp+0x3d>
f0106f90:	83 e8 01             	sub    $0x1,%eax
f0106f93:	74 13                	je     f0106fa8 <strncmp+0x34>
		n--, p++, q++;
f0106f95:	83 c2 01             	add    $0x1,%edx
f0106f98:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0106f9b:	0f b6 1a             	movzbl (%edx),%ebx
f0106f9e:	84 db                	test   %bl,%bl
f0106fa0:	74 0f                	je     f0106fb1 <strncmp+0x3d>
f0106fa2:	3a 19                	cmp    (%ecx),%bl
f0106fa4:	74 ea                	je     f0106f90 <strncmp+0x1c>
f0106fa6:	eb 09                	jmp    f0106fb1 <strncmp+0x3d>
f0106fa8:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0106fad:	5b                   	pop    %ebx
f0106fae:	5d                   	pop    %ebp
f0106faf:	90                   	nop
f0106fb0:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0106fb1:	0f b6 02             	movzbl (%edx),%eax
f0106fb4:	0f b6 11             	movzbl (%ecx),%edx
f0106fb7:	29 d0                	sub    %edx,%eax
f0106fb9:	eb f2                	jmp    f0106fad <strncmp+0x39>

f0106fbb <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0106fbb:	55                   	push   %ebp
f0106fbc:	89 e5                	mov    %esp,%ebp
f0106fbe:	8b 45 08             	mov    0x8(%ebp),%eax
f0106fc1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0106fc5:	0f b6 10             	movzbl (%eax),%edx
f0106fc8:	84 d2                	test   %dl,%dl
f0106fca:	74 18                	je     f0106fe4 <strchr+0x29>
		if (*s == c)
f0106fcc:	38 ca                	cmp    %cl,%dl
f0106fce:	75 0a                	jne    f0106fda <strchr+0x1f>
f0106fd0:	eb 17                	jmp    f0106fe9 <strchr+0x2e>
f0106fd2:	38 ca                	cmp    %cl,%dl
f0106fd4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106fd8:	74 0f                	je     f0106fe9 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0106fda:	83 c0 01             	add    $0x1,%eax
f0106fdd:	0f b6 10             	movzbl (%eax),%edx
f0106fe0:	84 d2                	test   %dl,%dl
f0106fe2:	75 ee                	jne    f0106fd2 <strchr+0x17>
f0106fe4:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
f0106fe9:	5d                   	pop    %ebp
f0106fea:	c3                   	ret    

f0106feb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0106feb:	55                   	push   %ebp
f0106fec:	89 e5                	mov    %esp,%ebp
f0106fee:	8b 45 08             	mov    0x8(%ebp),%eax
f0106ff1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0106ff5:	0f b6 10             	movzbl (%eax),%edx
f0106ff8:	84 d2                	test   %dl,%dl
f0106ffa:	74 18                	je     f0107014 <strfind+0x29>
		if (*s == c)
f0106ffc:	38 ca                	cmp    %cl,%dl
f0106ffe:	75 0a                	jne    f010700a <strfind+0x1f>
f0107000:	eb 12                	jmp    f0107014 <strfind+0x29>
f0107002:	38 ca                	cmp    %cl,%dl
f0107004:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0107008:	74 0a                	je     f0107014 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f010700a:	83 c0 01             	add    $0x1,%eax
f010700d:	0f b6 10             	movzbl (%eax),%edx
f0107010:	84 d2                	test   %dl,%dl
f0107012:	75 ee                	jne    f0107002 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
f0107014:	5d                   	pop    %ebp
f0107015:	c3                   	ret    

f0107016 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0107016:	55                   	push   %ebp
f0107017:	89 e5                	mov    %esp,%ebp
f0107019:	83 ec 0c             	sub    $0xc,%esp
f010701c:	89 1c 24             	mov    %ebx,(%esp)
f010701f:	89 74 24 04          	mov    %esi,0x4(%esp)
f0107023:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0107027:	8b 7d 08             	mov    0x8(%ebp),%edi
f010702a:	8b 45 0c             	mov    0xc(%ebp),%eax
f010702d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0107030:	85 c9                	test   %ecx,%ecx
f0107032:	74 30                	je     f0107064 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0107034:	f7 c7 03 00 00 00    	test   $0x3,%edi
f010703a:	75 25                	jne    f0107061 <memset+0x4b>
f010703c:	f6 c1 03             	test   $0x3,%cl
f010703f:	75 20                	jne    f0107061 <memset+0x4b>
		c &= 0xFF;
f0107041:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0107044:	89 d3                	mov    %edx,%ebx
f0107046:	c1 e3 08             	shl    $0x8,%ebx
f0107049:	89 d6                	mov    %edx,%esi
f010704b:	c1 e6 18             	shl    $0x18,%esi
f010704e:	89 d0                	mov    %edx,%eax
f0107050:	c1 e0 10             	shl    $0x10,%eax
f0107053:	09 f0                	or     %esi,%eax
f0107055:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
f0107057:	09 d8                	or     %ebx,%eax
f0107059:	c1 e9 02             	shr    $0x2,%ecx
f010705c:	fc                   	cld    
f010705d:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f010705f:	eb 03                	jmp    f0107064 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0107061:	fc                   	cld    
f0107062:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0107064:	89 f8                	mov    %edi,%eax
f0107066:	8b 1c 24             	mov    (%esp),%ebx
f0107069:	8b 74 24 04          	mov    0x4(%esp),%esi
f010706d:	8b 7c 24 08          	mov    0x8(%esp),%edi
f0107071:	89 ec                	mov    %ebp,%esp
f0107073:	5d                   	pop    %ebp
f0107074:	c3                   	ret    

f0107075 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0107075:	55                   	push   %ebp
f0107076:	89 e5                	mov    %esp,%ebp
f0107078:	83 ec 08             	sub    $0x8,%esp
f010707b:	89 34 24             	mov    %esi,(%esp)
f010707e:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0107082:	8b 45 08             	mov    0x8(%ebp),%eax
f0107085:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
f0107088:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
f010708b:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
f010708d:	39 c6                	cmp    %eax,%esi
f010708f:	73 35                	jae    f01070c6 <memmove+0x51>
f0107091:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0107094:	39 d0                	cmp    %edx,%eax
f0107096:	73 2e                	jae    f01070c6 <memmove+0x51>
		s += n;
		d += n;
f0107098:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010709a:	f6 c2 03             	test   $0x3,%dl
f010709d:	75 1b                	jne    f01070ba <memmove+0x45>
f010709f:	f7 c7 03 00 00 00    	test   $0x3,%edi
f01070a5:	75 13                	jne    f01070ba <memmove+0x45>
f01070a7:	f6 c1 03             	test   $0x3,%cl
f01070aa:	75 0e                	jne    f01070ba <memmove+0x45>
			asm volatile("std; rep movsl\n"
f01070ac:	83 ef 04             	sub    $0x4,%edi
f01070af:	8d 72 fc             	lea    -0x4(%edx),%esi
f01070b2:	c1 e9 02             	shr    $0x2,%ecx
f01070b5:	fd                   	std    
f01070b6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01070b8:	eb 09                	jmp    f01070c3 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f01070ba:	83 ef 01             	sub    $0x1,%edi
f01070bd:	8d 72 ff             	lea    -0x1(%edx),%esi
f01070c0:	fd                   	std    
f01070c1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f01070c3:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
f01070c4:	eb 20                	jmp    f01070e6 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01070c6:	f7 c6 03 00 00 00    	test   $0x3,%esi
f01070cc:	75 15                	jne    f01070e3 <memmove+0x6e>
f01070ce:	f7 c7 03 00 00 00    	test   $0x3,%edi
f01070d4:	75 0d                	jne    f01070e3 <memmove+0x6e>
f01070d6:	f6 c1 03             	test   $0x3,%cl
f01070d9:	75 08                	jne    f01070e3 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
f01070db:	c1 e9 02             	shr    $0x2,%ecx
f01070de:	fc                   	cld    
f01070df:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01070e1:	eb 03                	jmp    f01070e6 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f01070e3:	fc                   	cld    
f01070e4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f01070e6:	8b 34 24             	mov    (%esp),%esi
f01070e9:	8b 7c 24 04          	mov    0x4(%esp),%edi
f01070ed:	89 ec                	mov    %ebp,%esp
f01070ef:	5d                   	pop    %ebp
f01070f0:	c3                   	ret    

f01070f1 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
f01070f1:	55                   	push   %ebp
f01070f2:	89 e5                	mov    %esp,%ebp
f01070f4:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f01070f7:	8b 45 10             	mov    0x10(%ebp),%eax
f01070fa:	89 44 24 08          	mov    %eax,0x8(%esp)
f01070fe:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107101:	89 44 24 04          	mov    %eax,0x4(%esp)
f0107105:	8b 45 08             	mov    0x8(%ebp),%eax
f0107108:	89 04 24             	mov    %eax,(%esp)
f010710b:	e8 65 ff ff ff       	call   f0107075 <memmove>
}
f0107110:	c9                   	leave  
f0107111:	c3                   	ret    

f0107112 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0107112:	55                   	push   %ebp
f0107113:	89 e5                	mov    %esp,%ebp
f0107115:	57                   	push   %edi
f0107116:	56                   	push   %esi
f0107117:	53                   	push   %ebx
f0107118:	8b 75 08             	mov    0x8(%ebp),%esi
f010711b:	8b 7d 0c             	mov    0xc(%ebp),%edi
f010711e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0107121:	85 c9                	test   %ecx,%ecx
f0107123:	74 36                	je     f010715b <memcmp+0x49>
		if (*s1 != *s2)
f0107125:	0f b6 06             	movzbl (%esi),%eax
f0107128:	0f b6 1f             	movzbl (%edi),%ebx
f010712b:	38 d8                	cmp    %bl,%al
f010712d:	74 20                	je     f010714f <memcmp+0x3d>
f010712f:	eb 14                	jmp    f0107145 <memcmp+0x33>
f0107131:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
f0107136:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
f010713b:	83 c2 01             	add    $0x1,%edx
f010713e:	83 e9 01             	sub    $0x1,%ecx
f0107141:	38 d8                	cmp    %bl,%al
f0107143:	74 12                	je     f0107157 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
f0107145:	0f b6 c0             	movzbl %al,%eax
f0107148:	0f b6 db             	movzbl %bl,%ebx
f010714b:	29 d8                	sub    %ebx,%eax
f010714d:	eb 11                	jmp    f0107160 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010714f:	83 e9 01             	sub    $0x1,%ecx
f0107152:	ba 00 00 00 00       	mov    $0x0,%edx
f0107157:	85 c9                	test   %ecx,%ecx
f0107159:	75 d6                	jne    f0107131 <memcmp+0x1f>
f010715b:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
f0107160:	5b                   	pop    %ebx
f0107161:	5e                   	pop    %esi
f0107162:	5f                   	pop    %edi
f0107163:	5d                   	pop    %ebp
f0107164:	c3                   	ret    

f0107165 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0107165:	55                   	push   %ebp
f0107166:	89 e5                	mov    %esp,%ebp
f0107168:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f010716b:	89 c2                	mov    %eax,%edx
f010716d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0107170:	39 d0                	cmp    %edx,%eax
f0107172:	73 15                	jae    f0107189 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
f0107174:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
f0107178:	38 08                	cmp    %cl,(%eax)
f010717a:	75 06                	jne    f0107182 <memfind+0x1d>
f010717c:	eb 0b                	jmp    f0107189 <memfind+0x24>
f010717e:	38 08                	cmp    %cl,(%eax)
f0107180:	74 07                	je     f0107189 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0107182:	83 c0 01             	add    $0x1,%eax
f0107185:	39 c2                	cmp    %eax,%edx
f0107187:	77 f5                	ja     f010717e <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0107189:	5d                   	pop    %ebp
f010718a:	c3                   	ret    

f010718b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f010718b:	55                   	push   %ebp
f010718c:	89 e5                	mov    %esp,%ebp
f010718e:	57                   	push   %edi
f010718f:	56                   	push   %esi
f0107190:	53                   	push   %ebx
f0107191:	83 ec 04             	sub    $0x4,%esp
f0107194:	8b 55 08             	mov    0x8(%ebp),%edx
f0107197:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010719a:	0f b6 02             	movzbl (%edx),%eax
f010719d:	3c 20                	cmp    $0x20,%al
f010719f:	74 04                	je     f01071a5 <strtol+0x1a>
f01071a1:	3c 09                	cmp    $0x9,%al
f01071a3:	75 0e                	jne    f01071b3 <strtol+0x28>
		s++;
f01071a5:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01071a8:	0f b6 02             	movzbl (%edx),%eax
f01071ab:	3c 20                	cmp    $0x20,%al
f01071ad:	74 f6                	je     f01071a5 <strtol+0x1a>
f01071af:	3c 09                	cmp    $0x9,%al
f01071b1:	74 f2                	je     f01071a5 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
f01071b3:	3c 2b                	cmp    $0x2b,%al
f01071b5:	75 0c                	jne    f01071c3 <strtol+0x38>
		s++;
f01071b7:	83 c2 01             	add    $0x1,%edx
f01071ba:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
f01071c1:	eb 15                	jmp    f01071d8 <strtol+0x4d>
	else if (*s == '-')
f01071c3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
f01071ca:	3c 2d                	cmp    $0x2d,%al
f01071cc:	75 0a                	jne    f01071d8 <strtol+0x4d>
		s++, neg = 1;
f01071ce:	83 c2 01             	add    $0x1,%edx
f01071d1:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01071d8:	85 db                	test   %ebx,%ebx
f01071da:	0f 94 c0             	sete   %al
f01071dd:	74 05                	je     f01071e4 <strtol+0x59>
f01071df:	83 fb 10             	cmp    $0x10,%ebx
f01071e2:	75 18                	jne    f01071fc <strtol+0x71>
f01071e4:	80 3a 30             	cmpb   $0x30,(%edx)
f01071e7:	75 13                	jne    f01071fc <strtol+0x71>
f01071e9:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f01071ed:	8d 76 00             	lea    0x0(%esi),%esi
f01071f0:	75 0a                	jne    f01071fc <strtol+0x71>
		s += 2, base = 16;
f01071f2:	83 c2 02             	add    $0x2,%edx
f01071f5:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01071fa:	eb 15                	jmp    f0107211 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01071fc:	84 c0                	test   %al,%al
f01071fe:	66 90                	xchg   %ax,%ax
f0107200:	74 0f                	je     f0107211 <strtol+0x86>
f0107202:	bb 0a 00 00 00       	mov    $0xa,%ebx
f0107207:	80 3a 30             	cmpb   $0x30,(%edx)
f010720a:	75 05                	jne    f0107211 <strtol+0x86>
		s++, base = 8;
f010720c:	83 c2 01             	add    $0x1,%edx
f010720f:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0107211:	b8 00 00 00 00       	mov    $0x0,%eax
f0107216:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0107218:	0f b6 0a             	movzbl (%edx),%ecx
f010721b:	89 cf                	mov    %ecx,%edi
f010721d:	8d 59 d0             	lea    -0x30(%ecx),%ebx
f0107220:	80 fb 09             	cmp    $0x9,%bl
f0107223:	77 08                	ja     f010722d <strtol+0xa2>
			dig = *s - '0';
f0107225:	0f be c9             	movsbl %cl,%ecx
f0107228:	83 e9 30             	sub    $0x30,%ecx
f010722b:	eb 1e                	jmp    f010724b <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
f010722d:	8d 5f 9f             	lea    -0x61(%edi),%ebx
f0107230:	80 fb 19             	cmp    $0x19,%bl
f0107233:	77 08                	ja     f010723d <strtol+0xb2>
			dig = *s - 'a' + 10;
f0107235:	0f be c9             	movsbl %cl,%ecx
f0107238:	83 e9 57             	sub    $0x57,%ecx
f010723b:	eb 0e                	jmp    f010724b <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
f010723d:	8d 5f bf             	lea    -0x41(%edi),%ebx
f0107240:	80 fb 19             	cmp    $0x19,%bl
f0107243:	77 15                	ja     f010725a <strtol+0xcf>
			dig = *s - 'A' + 10;
f0107245:	0f be c9             	movsbl %cl,%ecx
f0107248:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f010724b:	39 f1                	cmp    %esi,%ecx
f010724d:	7d 0b                	jge    f010725a <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
f010724f:	83 c2 01             	add    $0x1,%edx
f0107252:	0f af c6             	imul   %esi,%eax
f0107255:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
f0107258:	eb be                	jmp    f0107218 <strtol+0x8d>
f010725a:	89 c1                	mov    %eax,%ecx

	if (endptr)
f010725c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0107260:	74 05                	je     f0107267 <strtol+0xdc>
		*endptr = (char *) s;
f0107262:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0107265:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
f0107267:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
f010726b:	74 04                	je     f0107271 <strtol+0xe6>
f010726d:	89 c8                	mov    %ecx,%eax
f010726f:	f7 d8                	neg    %eax
}
f0107271:	83 c4 04             	add    $0x4,%esp
f0107274:	5b                   	pop    %ebx
f0107275:	5e                   	pop    %esi
f0107276:	5f                   	pop    %edi
f0107277:	5d                   	pop    %ebp
f0107278:	c3                   	ret    
f0107279:	00 00                	add    %al,(%eax)
	...

f010727c <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f010727c:	fa                   	cli    

	xorw    %ax, %ax
f010727d:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f010727f:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0107281:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0107283:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f0107285:	0f 01 16             	lgdtl  (%esi)
f0107288:	74 70                	je     f01072fa <mpentry_end+0x4>
	movl    %cr0, %eax
f010728a:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f010728d:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f0107291:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f0107294:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f010729a:	08 00                	or     %al,(%eax)

f010729c <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f010729c:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f01072a0:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f01072a2:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f01072a4:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f01072a6:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f01072aa:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f01072ac:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f01072ae:	b8 00 20 12 00       	mov    $0x122000,%eax
	movl    %eax, %cr3
f01072b3:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f01072b6:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f01072b9:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f01072be:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in mem_init()
	movl    mpentry_kstack, %esp
f01072c1:	8b 25 a4 de 24 f0    	mov    0xf024dea4,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f01072c7:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f01072cc:	b8 ed 00 10 f0       	mov    $0xf01000ed,%eax
	call    *%eax
f01072d1:	ff d0                	call   *%eax

f01072d3 <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f01072d3:	eb fe                	jmp    f01072d3 <spin>
f01072d5:	8d 76 00             	lea    0x0(%esi),%esi

f01072d8 <gdt>:
	...
f01072e0:	ff                   	(bad)  
f01072e1:	ff 00                	incl   (%eax)
f01072e3:	00 00                	add    %al,(%eax)
f01072e5:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f01072ec:	00 92 cf 00 17 00    	add    %dl,0x1700cf(%edx)

f01072f0 <gdtdesc>:
f01072f0:	17                   	pop    %ss
f01072f1:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f01072f6 <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f01072f6:	90                   	nop
	...

f0107300 <sum>:
#define MPIOINTR  0x03  // One per bus interrupt source
#define MPLINTR   0x04  // One per system interrupt source

static uint8_t
sum(void *addr, int len)
{
f0107300:	55                   	push   %ebp
f0107301:	89 e5                	mov    %esp,%ebp
f0107303:	56                   	push   %esi
f0107304:	53                   	push   %ebx
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0107305:	bb 00 00 00 00       	mov    $0x0,%ebx
f010730a:	b9 00 00 00 00       	mov    $0x0,%ecx
f010730f:	85 d2                	test   %edx,%edx
f0107311:	7e 0d                	jle    f0107320 <sum+0x20>
		sum += ((uint8_t *)addr)[i];
f0107313:	0f b6 34 08          	movzbl (%eax,%ecx,1),%esi
f0107317:	01 f3                	add    %esi,%ebx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0107319:	83 c1 01             	add    $0x1,%ecx
f010731c:	39 d1                	cmp    %edx,%ecx
f010731e:	75 f3                	jne    f0107313 <sum+0x13>
		sum += ((uint8_t *)addr)[i];
	return sum;
}
f0107320:	89 d8                	mov    %ebx,%eax
f0107322:	5b                   	pop    %ebx
f0107323:	5e                   	pop    %esi
f0107324:	5d                   	pop    %ebp
f0107325:	c3                   	ret    

f0107326 <mpsearch1>:

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f0107326:	55                   	push   %ebp
f0107327:	89 e5                	mov    %esp,%ebp
f0107329:	56                   	push   %esi
f010732a:	53                   	push   %ebx
f010732b:	83 ec 10             	sub    $0x10,%esp
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010732e:	8b 0d a8 de 24 f0    	mov    0xf024dea8,%ecx
f0107334:	89 c3                	mov    %eax,%ebx
f0107336:	c1 eb 0c             	shr    $0xc,%ebx
f0107339:	39 cb                	cmp    %ecx,%ebx
f010733b:	72 20                	jb     f010735d <mpsearch1+0x37>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010733d:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0107341:	c7 44 24 08 80 7e 10 	movl   $0xf0107e80,0x8(%esp)
f0107348:	f0 
f0107349:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f0107350:	00 
f0107351:	c7 04 24 01 9a 10 f0 	movl   $0xf0109a01,(%esp)
f0107358:	e8 28 8d ff ff       	call   f0100085 <_panic>
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f010735d:	8d 34 02             	lea    (%edx,%eax,1),%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0107360:	89 f2                	mov    %esi,%edx
f0107362:	c1 ea 0c             	shr    $0xc,%edx
f0107365:	39 d1                	cmp    %edx,%ecx
f0107367:	77 20                	ja     f0107389 <mpsearch1+0x63>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0107369:	89 74 24 0c          	mov    %esi,0xc(%esp)
f010736d:	c7 44 24 08 80 7e 10 	movl   $0xf0107e80,0x8(%esp)
f0107374:	f0 
f0107375:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f010737c:	00 
f010737d:	c7 04 24 01 9a 10 f0 	movl   $0xf0109a01,(%esp)
f0107384:	e8 fc 8c ff ff       	call   f0100085 <_panic>
f0107389:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
f010738f:	81 ee 00 00 00 10    	sub    $0x10000000,%esi

	for (; mp < end; mp++)
f0107395:	39 f3                	cmp    %esi,%ebx
f0107397:	73 33                	jae    f01073cc <mpsearch1+0xa6>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0107399:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
f01073a0:	00 
f01073a1:	c7 44 24 04 11 9a 10 	movl   $0xf0109a11,0x4(%esp)
f01073a8:	f0 
f01073a9:	89 1c 24             	mov    %ebx,(%esp)
f01073ac:	e8 61 fd ff ff       	call   f0107112 <memcmp>
f01073b1:	85 c0                	test   %eax,%eax
f01073b3:	75 10                	jne    f01073c5 <mpsearch1+0x9f>
		    sum(mp, sizeof(*mp)) == 0)
f01073b5:	ba 10 00 00 00       	mov    $0x10,%edx
f01073ba:	89 d8                	mov    %ebx,%eax
f01073bc:	e8 3f ff ff ff       	call   f0107300 <sum>
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f01073c1:	84 c0                	test   %al,%al
f01073c3:	74 0c                	je     f01073d1 <mpsearch1+0xab>
static struct mp *
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
f01073c5:	83 c3 10             	add    $0x10,%ebx
f01073c8:	39 de                	cmp    %ebx,%esi
f01073ca:	77 cd                	ja     f0107399 <mpsearch1+0x73>
f01073cc:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
}
f01073d1:	89 d8                	mov    %ebx,%eax
f01073d3:	83 c4 10             	add    $0x10,%esp
f01073d6:	5b                   	pop    %ebx
f01073d7:	5e                   	pop    %esi
f01073d8:	5d                   	pop    %ebp
f01073d9:	c3                   	ret    

f01073da <mp_init>:
	return conf;
}

void
mp_init(void)
{
f01073da:	55                   	push   %ebp
f01073db:	89 e5                	mov    %esp,%ebp
f01073dd:	57                   	push   %edi
f01073de:	56                   	push   %esi
f01073df:	53                   	push   %ebx
f01073e0:	83 ec 2c             	sub    $0x2c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f01073e3:	c7 05 c0 e3 24 f0 20 	movl   $0xf024e020,0xf024e3c0
f01073ea:	e0 24 f0 
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01073ed:	83 3d a8 de 24 f0 00 	cmpl   $0x0,0xf024dea8
f01073f4:	75 24                	jne    f010741a <mp_init+0x40>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01073f6:	c7 44 24 0c 00 04 00 	movl   $0x400,0xc(%esp)
f01073fd:	00 
f01073fe:	c7 44 24 08 80 7e 10 	movl   $0xf0107e80,0x8(%esp)
f0107405:	f0 
f0107406:	c7 44 24 04 6f 00 00 	movl   $0x6f,0x4(%esp)
f010740d:	00 
f010740e:	c7 04 24 01 9a 10 f0 	movl   $0xf0109a01,(%esp)
f0107415:	e8 6b 8c ff ff       	call   f0100085 <_panic>
	// The BIOS data area lives in 16-bit segment 0x40.
	bda = (uint8_t *) KADDR(0x40 << 4);

	// [MP 4] The 16-bit segment of the EBDA is in the two bytes
	// starting at byte 0x0E of the BDA.  0 if not present.
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f010741a:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f0107421:	85 c0                	test   %eax,%eax
f0107423:	74 16                	je     f010743b <mp_init+0x61>
		p <<= 4;	// Translate from segment to PA
		if ((mp = mpsearch1(p, 1024)))
f0107425:	c1 e0 04             	shl    $0x4,%eax
f0107428:	ba 00 04 00 00       	mov    $0x400,%edx
f010742d:	e8 f4 fe ff ff       	call   f0107326 <mpsearch1>
f0107432:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0107435:	85 c0                	test   %eax,%eax
f0107437:	75 3c                	jne    f0107475 <mp_init+0x9b>
f0107439:	eb 20                	jmp    f010745b <mp_init+0x81>
			return mp;
	} else {
		// The size of base memory, in KB is in the two bytes
		// starting at 0x13 of the BDA.
		p = *(uint16_t *) (bda + 0x13) * 1024;
		if ((mp = mpsearch1(p - 1024, 1024)))
f010743b:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f0107442:	c1 e0 0a             	shl    $0xa,%eax
f0107445:	2d 00 04 00 00       	sub    $0x400,%eax
f010744a:	ba 00 04 00 00       	mov    $0x400,%edx
f010744f:	e8 d2 fe ff ff       	call   f0107326 <mpsearch1>
f0107454:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0107457:	85 c0                	test   %eax,%eax
f0107459:	75 1a                	jne    f0107475 <mp_init+0x9b>
			return mp;
	}
	return mpsearch1(0xF0000, 0x10000);
f010745b:	ba 00 00 01 00       	mov    $0x10000,%edx
f0107460:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f0107465:	e8 bc fe ff ff       	call   f0107326 <mpsearch1>
f010746a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
mpconfig(struct mp **pmp)
{
	struct mpconf *conf;
	struct mp *mp;

	if ((mp = mpsearch()) == 0)
f010746d:	85 c0                	test   %eax,%eax
f010746f:	0f 84 27 02 00 00    	je     f010769c <mp_init+0x2c2>
		return NULL;
	if (mp->physaddr == 0 || mp->type != 0) {
f0107475:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0107478:	8b 78 04             	mov    0x4(%eax),%edi
f010747b:	85 ff                	test   %edi,%edi
f010747d:	74 06                	je     f0107485 <mp_init+0xab>
f010747f:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f0107483:	74 11                	je     f0107496 <mp_init+0xbc>
		cprintf("SMP: Default configurations not implemented\n");
f0107485:	c7 04 24 74 98 10 f0 	movl   $0xf0109874,(%esp)
f010748c:	e8 76 d6 ff ff       	call   f0104b07 <cprintf>
f0107491:	e9 06 02 00 00       	jmp    f010769c <mp_init+0x2c2>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0107496:	89 f8                	mov    %edi,%eax
f0107498:	c1 e8 0c             	shr    $0xc,%eax
f010749b:	3b 05 a8 de 24 f0    	cmp    0xf024dea8,%eax
f01074a1:	72 20                	jb     f01074c3 <mp_init+0xe9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01074a3:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f01074a7:	c7 44 24 08 80 7e 10 	movl   $0xf0107e80,0x8(%esp)
f01074ae:	f0 
f01074af:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
f01074b6:	00 
f01074b7:	c7 04 24 01 9a 10 f0 	movl   $0xf0109a01,(%esp)
f01074be:	e8 c2 8b ff ff       	call   f0100085 <_panic>
		return NULL;
	}
	conf = (struct mpconf *) KADDR(mp->physaddr);
f01074c3:	81 ef 00 00 00 10    	sub    $0x10000000,%edi
	if (memcmp(conf, "PCMP", 4) != 0) {
f01074c9:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
f01074d0:	00 
f01074d1:	c7 44 24 04 16 9a 10 	movl   $0xf0109a16,0x4(%esp)
f01074d8:	f0 
f01074d9:	89 3c 24             	mov    %edi,(%esp)
f01074dc:	e8 31 fc ff ff       	call   f0107112 <memcmp>
f01074e1:	85 c0                	test   %eax,%eax
f01074e3:	74 11                	je     f01074f6 <mp_init+0x11c>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f01074e5:	c7 04 24 a4 98 10 f0 	movl   $0xf01098a4,(%esp)
f01074ec:	e8 16 d6 ff ff       	call   f0104b07 <cprintf>
f01074f1:	e9 a6 01 00 00       	jmp    f010769c <mp_init+0x2c2>
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f01074f6:	0f b7 57 04          	movzwl 0x4(%edi),%edx
f01074fa:	89 f8                	mov    %edi,%eax
f01074fc:	e8 ff fd ff ff       	call   f0107300 <sum>
f0107501:	84 c0                	test   %al,%al
f0107503:	74 11                	je     f0107516 <mp_init+0x13c>
		cprintf("SMP: Bad MP configuration checksum\n");
f0107505:	c7 04 24 d8 98 10 f0 	movl   $0xf01098d8,(%esp)
f010750c:	e8 f6 d5 ff ff       	call   f0104b07 <cprintf>
f0107511:	e9 86 01 00 00       	jmp    f010769c <mp_init+0x2c2>
		return NULL;
	}
	if (conf->version != 1 && conf->version != 4) {
f0107516:	0f b6 47 06          	movzbl 0x6(%edi),%eax
f010751a:	3c 01                	cmp    $0x1,%al
f010751c:	74 1c                	je     f010753a <mp_init+0x160>
f010751e:	3c 04                	cmp    $0x4,%al
f0107520:	74 18                	je     f010753a <mp_init+0x160>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f0107522:	0f b6 c0             	movzbl %al,%eax
f0107525:	89 44 24 04          	mov    %eax,0x4(%esp)
f0107529:	c7 04 24 fc 98 10 f0 	movl   $0xf01098fc,(%esp)
f0107530:	e8 d2 d5 ff ff       	call   f0104b07 <cprintf>
f0107535:	e9 62 01 00 00       	jmp    f010769c <mp_init+0x2c2>
		return NULL;
	}
	if (sum((uint8_t *)conf + conf->length, conf->xlength) != conf->xchecksum) {
f010753a:	0f b7 57 28          	movzwl 0x28(%edi),%edx
f010753e:	0f b7 47 04          	movzwl 0x4(%edi),%eax
f0107542:	8d 04 07             	lea    (%edi,%eax,1),%eax
f0107545:	e8 b6 fd ff ff       	call   f0107300 <sum>
f010754a:	3a 47 2a             	cmp    0x2a(%edi),%al
f010754d:	74 11                	je     f0107560 <mp_init+0x186>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f010754f:	c7 04 24 1c 99 10 f0 	movl   $0xf010991c,(%esp)
f0107556:	e8 ac d5 ff ff       	call   f0104b07 <cprintf>
f010755b:	e9 3c 01 00 00       	jmp    f010769c <mp_init+0x2c2>
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
	if ((conf = mpconfig(&mp)) == 0)
f0107560:	85 ff                	test   %edi,%edi
f0107562:	0f 84 34 01 00 00    	je     f010769c <mp_init+0x2c2>
		return;
	ismp = 1;
f0107568:	c7 05 00 e0 24 f0 01 	movl   $0x1,0xf024e000
f010756f:	00 00 00 
	lapic = (uint32_t *)conf->lapicaddr;
f0107572:	8b 47 24             	mov    0x24(%edi),%eax
f0107575:	a3 00 f0 28 f0       	mov    %eax,0xf028f000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f010757a:	66 83 7f 22 00       	cmpw   $0x0,0x22(%edi)
f010757f:	0f 84 98 00 00 00    	je     f010761d <mp_init+0x243>
f0107585:	8d 5f 2c             	lea    0x2c(%edi),%ebx
f0107588:	be 00 00 00 00       	mov    $0x0,%esi
		switch (*p) {
f010758d:	0f b6 03             	movzbl (%ebx),%eax
f0107590:	84 c0                	test   %al,%al
f0107592:	74 06                	je     f010759a <mp_init+0x1c0>
f0107594:	3c 04                	cmp    $0x4,%al
f0107596:	77 55                	ja     f01075ed <mp_init+0x213>
f0107598:	eb 4e                	jmp    f01075e8 <mp_init+0x20e>
		case MPPROC:
			proc = (struct mpproc *)p;
f010759a:	89 da                	mov    %ebx,%edx
			if (proc->flags & MPPROC_BOOT)
f010759c:	f6 43 03 02          	testb  $0x2,0x3(%ebx)
f01075a0:	74 11                	je     f01075b3 <mp_init+0x1d9>
				bootcpu = &cpus[ncpu];
f01075a2:	6b 05 c4 e3 24 f0 74 	imul   $0x74,0xf024e3c4,%eax
f01075a9:	05 20 e0 24 f0       	add    $0xf024e020,%eax
f01075ae:	a3 c0 e3 24 f0       	mov    %eax,0xf024e3c0
			if (ncpu < NCPU) {
f01075b3:	a1 c4 e3 24 f0       	mov    0xf024e3c4,%eax
f01075b8:	83 f8 07             	cmp    $0x7,%eax
f01075bb:	7f 12                	jg     f01075cf <mp_init+0x1f5>
				cpus[ncpu].cpu_id = ncpu;
f01075bd:	6b d0 74             	imul   $0x74,%eax,%edx
f01075c0:	88 82 20 e0 24 f0    	mov    %al,-0xfdb1fe0(%edx)
				ncpu++;
f01075c6:	83 05 c4 e3 24 f0 01 	addl   $0x1,0xf024e3c4
f01075cd:	eb 14                	jmp    f01075e3 <mp_init+0x209>
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f01075cf:	0f b6 42 01          	movzbl 0x1(%edx),%eax
f01075d3:	89 44 24 04          	mov    %eax,0x4(%esp)
f01075d7:	c7 04 24 4c 99 10 f0 	movl   $0xf010994c,(%esp)
f01075de:	e8 24 d5 ff ff       	call   f0104b07 <cprintf>
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f01075e3:	83 c3 14             	add    $0x14,%ebx
			continue;
f01075e6:	eb 26                	jmp    f010760e <mp_init+0x234>
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f01075e8:	83 c3 08             	add    $0x8,%ebx
			continue;
f01075eb:	eb 21                	jmp    f010760e <mp_init+0x234>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f01075ed:	0f b6 c0             	movzbl %al,%eax
f01075f0:	89 44 24 04          	mov    %eax,0x4(%esp)
f01075f4:	c7 04 24 74 99 10 f0 	movl   $0xf0109974,(%esp)
f01075fb:	e8 07 d5 ff ff       	call   f0104b07 <cprintf>
			ismp = 0;
f0107600:	c7 05 00 e0 24 f0 00 	movl   $0x0,0xf024e000
f0107607:	00 00 00 
			i = conf->entry;
f010760a:	0f b7 77 22          	movzwl 0x22(%edi),%esi
	if ((conf = mpconfig(&mp)) == 0)
		return;
	ismp = 1;
	lapic = (uint32_t *)conf->lapicaddr;

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f010760e:	83 c6 01             	add    $0x1,%esi
f0107611:	0f b7 47 22          	movzwl 0x22(%edi),%eax
f0107615:	39 f0                	cmp    %esi,%eax
f0107617:	0f 87 70 ff ff ff    	ja     f010758d <mp_init+0x1b3>
			ismp = 0;
			i = conf->entry;
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f010761d:	a1 c0 e3 24 f0       	mov    0xf024e3c0,%eax
f0107622:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f0107629:	83 3d 00 e0 24 f0 00 	cmpl   $0x0,0xf024e000
f0107630:	75 22                	jne    f0107654 <mp_init+0x27a>
		// Didn't like what we found; fall back to no MP.
		ncpu = 1;
f0107632:	c7 05 c4 e3 24 f0 01 	movl   $0x1,0xf024e3c4
f0107639:	00 00 00 
		lapic = NULL;
f010763c:	c7 05 00 f0 28 f0 00 	movl   $0x0,0xf028f000
f0107643:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f0107646:	c7 04 24 94 99 10 f0 	movl   $0xf0109994,(%esp)
f010764d:	e8 b5 d4 ff ff       	call   f0104b07 <cprintf>
		return;
f0107652:	eb 48                	jmp    f010769c <mp_init+0x2c2>
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f0107654:	a1 c4 e3 24 f0       	mov    0xf024e3c4,%eax
f0107659:	89 44 24 08          	mov    %eax,0x8(%esp)
f010765d:	a1 c0 e3 24 f0       	mov    0xf024e3c0,%eax
f0107662:	0f b6 00             	movzbl (%eax),%eax
f0107665:	89 44 24 04          	mov    %eax,0x4(%esp)
f0107669:	c7 04 24 1b 9a 10 f0 	movl   $0xf0109a1b,(%esp)
f0107670:	e8 92 d4 ff ff       	call   f0104b07 <cprintf>

	if (mp->imcrp) {
f0107675:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0107678:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f010767c:	74 1e                	je     f010769c <mp_init+0x2c2>
		// [MP 3.2.6.1] If the hardware implements PIC mode,
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f010767e:	c7 04 24 c0 99 10 f0 	movl   $0xf01099c0,(%esp)
f0107685:	e8 7d d4 ff ff       	call   f0104b07 <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010768a:	ba 22 00 00 00       	mov    $0x22,%edx
f010768f:	b8 70 00 00 00       	mov    $0x70,%eax
f0107694:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0107695:	b2 23                	mov    $0x23,%dl
f0107697:	ec                   	in     (%dx),%al
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0107698:	83 c8 01             	or     $0x1,%eax
f010769b:	ee                   	out    %al,(%dx)
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
	}
}
f010769c:	83 c4 2c             	add    $0x2c,%esp
f010769f:	5b                   	pop    %ebx
f01076a0:	5e                   	pop    %esi
f01076a1:	5f                   	pop    %edi
f01076a2:	5d                   	pop    %ebp
f01076a3:	c3                   	ret    

f01076a4 <lapicw>:

volatile uint32_t *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
f01076a4:	55                   	push   %ebp
f01076a5:	89 e5                	mov    %esp,%ebp
	lapic[index] = value;
f01076a7:	c1 e0 02             	shl    $0x2,%eax
f01076aa:	03 05 00 f0 28 f0    	add    0xf028f000,%eax
f01076b0:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f01076b2:	a1 00 f0 28 f0       	mov    0xf028f000,%eax
f01076b7:	83 c0 20             	add    $0x20,%eax
f01076ba:	8b 00                	mov    (%eax),%eax
}
f01076bc:	5d                   	pop    %ebp
f01076bd:	c3                   	ret    

f01076be <cpunum>:
	lapicw(TPR, 0);
}

int
cpunum(void)
{
f01076be:	55                   	push   %ebp
f01076bf:	89 e5                	mov    %esp,%ebp
	if (lapic)
f01076c1:	8b 15 00 f0 28 f0    	mov    0xf028f000,%edx
f01076c7:	b8 00 00 00 00       	mov    $0x0,%eax
f01076cc:	85 d2                	test   %edx,%edx
f01076ce:	74 08                	je     f01076d8 <cpunum+0x1a>
		return lapic[ID] >> 24;
f01076d0:	83 c2 20             	add    $0x20,%edx
f01076d3:	8b 02                	mov    (%edx),%eax
f01076d5:	c1 e8 18             	shr    $0x18,%eax
	return 0;
}
f01076d8:	5d                   	pop    %ebp
f01076d9:	c3                   	ret    

f01076da <lapic_init>:
	lapic[ID];  // wait for write to finish, by reading
}

void
lapic_init(void)
{
f01076da:	55                   	push   %ebp
f01076db:	89 e5                	mov    %esp,%ebp
	if (!lapic) 
f01076dd:	83 3d 00 f0 28 f0 00 	cmpl   $0x0,0xf028f000
f01076e4:	0f 84 0b 01 00 00    	je     f01077f5 <lapic_init+0x11b>
		return;

	// Enable local APIC; set spurious interrupt vector.
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f01076ea:	ba 27 01 00 00       	mov    $0x127,%edx
f01076ef:	b8 3c 00 00 00       	mov    $0x3c,%eax
f01076f4:	e8 ab ff ff ff       	call   f01076a4 <lapicw>

	// The timer repeatedly counts down at bus frequency
	// from lapic[TICR] and then issues an interrupt.  
	// If we cared more about precise timekeeping,
	// TICR would be calibrated using an external time source.
	lapicw(TDCR, X1);
f01076f9:	ba 0b 00 00 00       	mov    $0xb,%edx
f01076fe:	b8 f8 00 00 00       	mov    $0xf8,%eax
f0107703:	e8 9c ff ff ff       	call   f01076a4 <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f0107708:	ba 20 00 02 00       	mov    $0x20020,%edx
f010770d:	b8 c8 00 00 00       	mov    $0xc8,%eax
f0107712:	e8 8d ff ff ff       	call   f01076a4 <lapicw>
	lapicw(TICR, 10000000); 
f0107717:	ba 80 96 98 00       	mov    $0x989680,%edx
f010771c:	b8 e0 00 00 00       	mov    $0xe0,%eax
f0107721:	e8 7e ff ff ff       	call   f01076a4 <lapicw>
	//
	// According to Intel MP Specification, the BIOS should initialize
	// BSP's local APIC in Virtual Wire Mode, in which 8259A's
	// INTR is virtually connected to BSP's LINTIN0. In this mode,
	// we do not need to program the IOAPIC.
	if (thiscpu != bootcpu)
f0107726:	e8 93 ff ff ff       	call   f01076be <cpunum>
f010772b:	6b c0 74             	imul   $0x74,%eax,%eax
f010772e:	05 20 e0 24 f0       	add    $0xf024e020,%eax
f0107733:	39 05 c0 e3 24 f0    	cmp    %eax,0xf024e3c0
f0107739:	74 0f                	je     f010774a <lapic_init+0x70>
		lapicw(LINT0, MASKED);
f010773b:	ba 00 00 01 00       	mov    $0x10000,%edx
f0107740:	b8 d4 00 00 00       	mov    $0xd4,%eax
f0107745:	e8 5a ff ff ff       	call   f01076a4 <lapicw>

	// Disable NMI (LINT1) on all CPUs
	lapicw(LINT1, MASKED);
f010774a:	ba 00 00 01 00       	mov    $0x10000,%edx
f010774f:	b8 d8 00 00 00       	mov    $0xd8,%eax
f0107754:	e8 4b ff ff ff       	call   f01076a4 <lapicw>

	// Disable performance counter overflow interrupts
	// on machines that provide that interrupt entry.
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f0107759:	a1 00 f0 28 f0       	mov    0xf028f000,%eax
f010775e:	83 c0 30             	add    $0x30,%eax
f0107761:	8b 00                	mov    (%eax),%eax
f0107763:	c1 e8 10             	shr    $0x10,%eax
f0107766:	3c 03                	cmp    $0x3,%al
f0107768:	76 0f                	jbe    f0107779 <lapic_init+0x9f>
		lapicw(PCINT, MASKED);
f010776a:	ba 00 00 01 00       	mov    $0x10000,%edx
f010776f:	b8 d0 00 00 00       	mov    $0xd0,%eax
f0107774:	e8 2b ff ff ff       	call   f01076a4 <lapicw>

	// Map error interrupt to IRQ_ERROR.
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f0107779:	ba 33 00 00 00       	mov    $0x33,%edx
f010777e:	b8 dc 00 00 00       	mov    $0xdc,%eax
f0107783:	e8 1c ff ff ff       	call   f01076a4 <lapicw>

	// Clear error status register (requires back-to-back writes).
	lapicw(ESR, 0);
f0107788:	ba 00 00 00 00       	mov    $0x0,%edx
f010778d:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0107792:	e8 0d ff ff ff       	call   f01076a4 <lapicw>
	lapicw(ESR, 0);
f0107797:	ba 00 00 00 00       	mov    $0x0,%edx
f010779c:	b8 a0 00 00 00       	mov    $0xa0,%eax
f01077a1:	e8 fe fe ff ff       	call   f01076a4 <lapicw>

	// Ack any outstanding interrupts.
	lapicw(EOI, 0);
f01077a6:	ba 00 00 00 00       	mov    $0x0,%edx
f01077ab:	b8 2c 00 00 00       	mov    $0x2c,%eax
f01077b0:	e8 ef fe ff ff       	call   f01076a4 <lapicw>

	// Send an Init Level De-Assert to synchronize arbitration ID's.
	lapicw(ICRHI, 0);
f01077b5:	ba 00 00 00 00       	mov    $0x0,%edx
f01077ba:	b8 c4 00 00 00       	mov    $0xc4,%eax
f01077bf:	e8 e0 fe ff ff       	call   f01076a4 <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f01077c4:	ba 00 85 08 00       	mov    $0x88500,%edx
f01077c9:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01077ce:	e8 d1 fe ff ff       	call   f01076a4 <lapicw>
	while(lapic[ICRLO] & DELIVS)
f01077d3:	8b 15 00 f0 28 f0    	mov    0xf028f000,%edx
f01077d9:	81 c2 00 03 00 00    	add    $0x300,%edx
f01077df:	8b 02                	mov    (%edx),%eax
f01077e1:	f6 c4 10             	test   $0x10,%ah
f01077e4:	75 f9                	jne    f01077df <lapic_init+0x105>
		;

	// Enable interrupts on the APIC (but not on the processor).
	lapicw(TPR, 0);
f01077e6:	ba 00 00 00 00       	mov    $0x0,%edx
f01077eb:	b8 20 00 00 00       	mov    $0x20,%eax
f01077f0:	e8 af fe ff ff       	call   f01076a4 <lapicw>
}
f01077f5:	5d                   	pop    %ebp
f01077f6:	c3                   	ret    

f01077f7 <lapic_eoi>:
}

// Acknowledge interrupt.
void
lapic_eoi(void)
{
f01077f7:	55                   	push   %ebp
f01077f8:	89 e5                	mov    %esp,%ebp
	if (lapic)
f01077fa:	83 3d 00 f0 28 f0 00 	cmpl   $0x0,0xf028f000
f0107801:	74 0f                	je     f0107812 <lapic_eoi+0x1b>
		lapicw(EOI, 0);
f0107803:	ba 00 00 00 00       	mov    $0x0,%edx
f0107808:	b8 2c 00 00 00       	mov    $0x2c,%eax
f010780d:	e8 92 fe ff ff       	call   f01076a4 <lapicw>
}
f0107812:	5d                   	pop    %ebp
f0107813:	c3                   	ret    

f0107814 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
static void
microdelay(int us)
{
f0107814:	55                   	push   %ebp
f0107815:	89 e5                	mov    %esp,%ebp
}
f0107817:	5d                   	pop    %ebp
f0107818:	c3                   	ret    

f0107819 <lapic_ipi>:
	}
}

void
lapic_ipi(int vector)
{
f0107819:	55                   	push   %ebp
f010781a:	89 e5                	mov    %esp,%ebp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f010781c:	8b 55 08             	mov    0x8(%ebp),%edx
f010781f:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f0107825:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010782a:	e8 75 fe ff ff       	call   f01076a4 <lapicw>
	while (lapic[ICRLO] & DELIVS)
f010782f:	8b 15 00 f0 28 f0    	mov    0xf028f000,%edx
f0107835:	81 c2 00 03 00 00    	add    $0x300,%edx
f010783b:	8b 02                	mov    (%edx),%eax
f010783d:	f6 c4 10             	test   $0x10,%ah
f0107840:	75 f9                	jne    f010783b <lapic_ipi+0x22>
		;
}
f0107842:	5d                   	pop    %ebp
f0107843:	c3                   	ret    

f0107844 <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f0107844:	55                   	push   %ebp
f0107845:	89 e5                	mov    %esp,%ebp
f0107847:	56                   	push   %esi
f0107848:	53                   	push   %ebx
f0107849:	83 ec 10             	sub    $0x10,%esp
f010784c:	8b 75 0c             	mov    0xc(%ebp),%esi
f010784f:	0f b6 5d 08          	movzbl 0x8(%ebp),%ebx
f0107853:	ba 70 00 00 00       	mov    $0x70,%edx
f0107858:	b8 0f 00 00 00       	mov    $0xf,%eax
f010785d:	ee                   	out    %al,(%dx)
f010785e:	b2 71                	mov    $0x71,%dl
f0107860:	b8 0a 00 00 00       	mov    $0xa,%eax
f0107865:	ee                   	out    %al,(%dx)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0107866:	83 3d a8 de 24 f0 00 	cmpl   $0x0,0xf024dea8
f010786d:	75 24                	jne    f0107893 <lapic_startap+0x4f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010786f:	c7 44 24 0c 67 04 00 	movl   $0x467,0xc(%esp)
f0107876:	00 
f0107877:	c7 44 24 08 80 7e 10 	movl   $0xf0107e80,0x8(%esp)
f010787e:	f0 
f010787f:	c7 44 24 04 93 00 00 	movl   $0x93,0x4(%esp)
f0107886:	00 
f0107887:	c7 04 24 38 9a 10 f0 	movl   $0xf0109a38,(%esp)
f010788e:	e8 f2 87 ff ff       	call   f0100085 <_panic>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f0107893:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f010789a:	00 00 
	wrv[1] = addr >> 4;
f010789c:	89 f0                	mov    %esi,%eax
f010789e:	c1 e8 04             	shr    $0x4,%eax
f01078a1:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f01078a7:	c1 e3 18             	shl    $0x18,%ebx
f01078aa:	89 da                	mov    %ebx,%edx
f01078ac:	b8 c4 00 00 00       	mov    $0xc4,%eax
f01078b1:	e8 ee fd ff ff       	call   f01076a4 <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f01078b6:	ba 00 c5 00 00       	mov    $0xc500,%edx
f01078bb:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01078c0:	e8 df fd ff ff       	call   f01076a4 <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f01078c5:	ba 00 85 00 00       	mov    $0x8500,%edx
f01078ca:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01078cf:	e8 d0 fd ff ff       	call   f01076a4 <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f01078d4:	c1 ee 0c             	shr    $0xc,%esi
f01078d7:	81 ce 00 06 00 00    	or     $0x600,%esi
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f01078dd:	89 da                	mov    %ebx,%edx
f01078df:	b8 c4 00 00 00       	mov    $0xc4,%eax
f01078e4:	e8 bb fd ff ff       	call   f01076a4 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f01078e9:	89 f2                	mov    %esi,%edx
f01078eb:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01078f0:	e8 af fd ff ff       	call   f01076a4 <lapicw>
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f01078f5:	89 da                	mov    %ebx,%edx
f01078f7:	b8 c4 00 00 00       	mov    $0xc4,%eax
f01078fc:	e8 a3 fd ff ff       	call   f01076a4 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0107901:	89 f2                	mov    %esi,%edx
f0107903:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0107908:	e8 97 fd ff ff       	call   f01076a4 <lapicw>
		microdelay(200);
	}
}
f010790d:	83 c4 10             	add    $0x10,%esp
f0107910:	5b                   	pop    %ebx
f0107911:	5e                   	pop    %esi
f0107912:	5d                   	pop    %ebp
f0107913:	c3                   	ret    
	...

f0107920 <__spin_initlock>:
}
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f0107920:	55                   	push   %ebp
f0107921:	89 e5                	mov    %esp,%ebp
f0107923:	8b 45 08             	mov    0x8(%ebp),%eax
#ifndef USE_TICKET_SPIN_LOCK
	lk->locked = 0;
f0107926:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
        lk->next = 0;

#endif

#ifdef DEBUG_SPINLOCK
	lk->name = name;
f010792c:	8b 55 0c             	mov    0xc(%ebp),%edx
f010792f:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f0107932:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f0107939:	5d                   	pop    %ebp
f010793a:	c3                   	ret    

f010793b <holding>:
}

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
f010793b:	55                   	push   %ebp
f010793c:	89 e5                	mov    %esp,%ebp
f010793e:	53                   	push   %ebx
f010793f:	83 ec 04             	sub    $0x4,%esp
f0107942:	89 c2                	mov    %eax,%edx
#ifndef USE_TICKET_SPIN_LOCK
	return lock->locked && lock->cpu == thiscpu;
f0107944:	b8 00 00 00 00       	mov    $0x0,%eax
f0107949:	83 3a 00             	cmpl   $0x0,(%edx)
f010794c:	74 18                	je     f0107966 <holding+0x2b>
f010794e:	8b 5a 08             	mov    0x8(%edx),%ebx
f0107951:	e8 68 fd ff ff       	call   f01076be <cpunum>
f0107956:	6b c0 74             	imul   $0x74,%eax,%eax
f0107959:	05 20 e0 24 f0       	add    $0xf024e020,%eax
f010795e:	39 c3                	cmp    %eax,%ebx
f0107960:	0f 94 c0             	sete   %al
f0107963:	0f b6 c0             	movzbl %al,%eax
	//LAB 4: Your code here
        return lock->own != lock->next && lock->cpu == thiscpu;
	//panic("ticket spinlock: not implemented yet");

#endif
}
f0107966:	83 c4 04             	add    $0x4,%esp
f0107969:	5b                   	pop    %ebx
f010796a:	5d                   	pop    %ebp
f010796b:	c3                   	ret    

f010796c <spin_unlock>:
}

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f010796c:	55                   	push   %ebp
f010796d:	89 e5                	mov    %esp,%ebp
f010796f:	83 ec 78             	sub    $0x78,%esp
f0107972:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0107975:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0107978:	89 7d fc             	mov    %edi,-0x4(%ebp)
f010797b:	8b 5d 08             	mov    0x8(%ebp),%ebx
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
f010797e:	89 d8                	mov    %ebx,%eax
f0107980:	e8 b6 ff ff ff       	call   f010793b <holding>
f0107985:	85 c0                	test   %eax,%eax
f0107987:	0f 85 d5 00 00 00    	jne    f0107a62 <spin_unlock+0xf6>
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f010798d:	c7 44 24 08 28 00 00 	movl   $0x28,0x8(%esp)
f0107994:	00 
f0107995:	8d 43 0c             	lea    0xc(%ebx),%eax
f0107998:	89 44 24 04          	mov    %eax,0x4(%esp)
f010799c:	8d 45 a8             	lea    -0x58(%ebp),%eax
f010799f:	89 04 24             	mov    %eax,(%esp)
f01079a2:	e8 ce f6 ff ff       	call   f0107075 <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f01079a7:	8b 43 08             	mov    0x8(%ebx),%eax
f01079aa:	0f b6 30             	movzbl (%eax),%esi
f01079ad:	8b 5b 04             	mov    0x4(%ebx),%ebx
f01079b0:	e8 09 fd ff ff       	call   f01076be <cpunum>
f01079b5:	89 74 24 0c          	mov    %esi,0xc(%esp)
f01079b9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01079bd:	89 44 24 04          	mov    %eax,0x4(%esp)
f01079c1:	c7 04 24 48 9a 10 f0 	movl   $0xf0109a48,(%esp)
f01079c8:	e8 3a d1 ff ff       	call   f0104b07 <cprintf>
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f01079cd:	8b 45 a8             	mov    -0x58(%ebp),%eax
f01079d0:	85 c0                	test   %eax,%eax
f01079d2:	74 72                	je     f0107a46 <spin_unlock+0xda>
f01079d4:	8d 5d a8             	lea    -0x58(%ebp),%ebx
#endif
}

// Release the lock.
void
spin_unlock(struct spinlock *lk)
f01079d7:	8d 7d cc             	lea    -0x34(%ebp),%edi
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f01079da:	8d 75 d0             	lea    -0x30(%ebp),%esi
f01079dd:	89 74 24 04          	mov    %esi,0x4(%esp)
f01079e1:	89 04 24             	mov    %eax,(%esp)
f01079e4:	e8 e5 e8 ff ff       	call   f01062ce <debuginfo_eip>
f01079e9:	85 c0                	test   %eax,%eax
f01079eb:	78 39                	js     f0107a26 <spin_unlock+0xba>
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
f01079ed:	8b 03                	mov    (%ebx),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f01079ef:	89 c2                	mov    %eax,%edx
f01079f1:	2b 55 e0             	sub    -0x20(%ebp),%edx
f01079f4:	89 54 24 18          	mov    %edx,0x18(%esp)
f01079f8:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01079fb:	89 54 24 14          	mov    %edx,0x14(%esp)
f01079ff:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0107a02:	89 54 24 10          	mov    %edx,0x10(%esp)
f0107a06:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0107a09:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0107a0d:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0107a10:	89 54 24 08          	mov    %edx,0x8(%esp)
f0107a14:	89 44 24 04          	mov    %eax,0x4(%esp)
f0107a18:	c7 04 24 ac 9a 10 f0 	movl   $0xf0109aac,(%esp)
f0107a1f:	e8 e3 d0 ff ff       	call   f0104b07 <cprintf>
f0107a24:	eb 12                	jmp    f0107a38 <spin_unlock+0xcc>
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
f0107a26:	8b 03                	mov    (%ebx),%eax
f0107a28:	89 44 24 04          	mov    %eax,0x4(%esp)
f0107a2c:	c7 04 24 c3 9a 10 f0 	movl   $0xf0109ac3,(%esp)
f0107a33:	e8 cf d0 ff ff       	call   f0104b07 <cprintf>
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f0107a38:	39 fb                	cmp    %edi,%ebx
f0107a3a:	74 0a                	je     f0107a46 <spin_unlock+0xda>
f0107a3c:	8b 43 04             	mov    0x4(%ebx),%eax
f0107a3f:	83 c3 04             	add    $0x4,%ebx
f0107a42:	85 c0                	test   %eax,%eax
f0107a44:	75 97                	jne    f01079dd <spin_unlock+0x71>
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
f0107a46:	c7 44 24 08 cb 9a 10 	movl   $0xf0109acb,0x8(%esp)
f0107a4d:	f0 
f0107a4e:	c7 44 24 04 8a 00 00 	movl   $0x8a,0x4(%esp)
f0107a55:	00 
f0107a56:	c7 04 24 d7 9a 10 f0 	movl   $0xf0109ad7,(%esp)
f0107a5d:	e8 23 86 ff ff       	call   f0100085 <_panic>
	}

	lk->pcs[0] = 0;
f0107a62:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
	lk->cpu = 0;
f0107a69:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0107a70:	b8 00 00 00 00       	mov    $0x0,%eax
f0107a75:	f0 87 03             	lock xchg %eax,(%ebx)
	xchg(&lk->locked, 0);
#else
	//LAB 4: Your code here
        atomic_return_and_add(&lk->own,1);
#endif
}
f0107a78:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0107a7b:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0107a7e:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0107a81:	89 ec                	mov    %ebp,%esp
f0107a83:	5d                   	pop    %ebp
f0107a84:	c3                   	ret    

f0107a85 <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f0107a85:	55                   	push   %ebp
f0107a86:	89 e5                	mov    %esp,%ebp
f0107a88:	56                   	push   %esi
f0107a89:	53                   	push   %ebx
f0107a8a:	83 ec 20             	sub    $0x20,%esp
f0107a8d:	8b 5d 08             	mov    0x8(%ebp),%ebx
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f0107a90:	89 d8                	mov    %ebx,%eax
f0107a92:	e8 a4 fe ff ff       	call   f010793b <holding>
f0107a97:	85 c0                	test   %eax,%eax
f0107a99:	75 12                	jne    f0107aad <spin_lock+0x28>

#ifndef USE_TICKET_SPIN_LOCK
	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f0107a9b:	89 da                	mov    %ebx,%edx
f0107a9d:	b0 01                	mov    $0x1,%al
f0107a9f:	f0 87 03             	lock xchg %eax,(%ebx)
f0107aa2:	b9 01 00 00 00       	mov    $0x1,%ecx
f0107aa7:	85 c0                	test   %eax,%eax
f0107aa9:	75 2e                	jne    f0107ad9 <spin_lock+0x54>
f0107aab:	eb 37                	jmp    f0107ae4 <spin_lock+0x5f>
void
spin_lock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f0107aad:	8b 5b 04             	mov    0x4(%ebx),%ebx
f0107ab0:	e8 09 fc ff ff       	call   f01076be <cpunum>
f0107ab5:	89 5c 24 10          	mov    %ebx,0x10(%esp)
f0107ab9:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0107abd:	c7 44 24 08 80 9a 10 	movl   $0xf0109a80,0x8(%esp)
f0107ac4:	f0 
f0107ac5:	c7 44 24 04 5c 00 00 	movl   $0x5c,0x4(%esp)
f0107acc:	00 
f0107acd:	c7 04 24 d7 9a 10 f0 	movl   $0xf0109ad7,(%esp)
f0107ad4:	e8 ac 85 ff ff       	call   f0100085 <_panic>
#ifndef USE_TICKET_SPIN_LOCK
	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f0107ad9:	f3 90                	pause  
f0107adb:	89 c8                	mov    %ecx,%eax
f0107add:	f0 87 02             	lock xchg %eax,(%edx)

#ifndef USE_TICKET_SPIN_LOCK
	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f0107ae0:	85 c0                	test   %eax,%eax
f0107ae2:	75 f5                	jne    f0107ad9 <spin_lock+0x54>

#endif

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f0107ae4:	e8 d5 fb ff ff       	call   f01076be <cpunum>
f0107ae9:	6b c0 74             	imul   $0x74,%eax,%eax
f0107aec:	05 20 e0 24 f0       	add    $0xf024e020,%eax
f0107af1:	89 43 08             	mov    %eax,0x8(%ebx)
	get_caller_pcs(lk->pcs);
f0107af4:	8d 73 0c             	lea    0xc(%ebx),%esi
get_caller_pcs(uint32_t pcs[])
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
f0107af7:	89 e8                	mov    %ebp,%eax
	for (i = 0; i < 10; i++){
		if (ebp == 0 || ebp < (uint32_t *)ULIM
f0107af9:	8d 90 00 00 80 10    	lea    0x10800000(%eax),%edx
f0107aff:	81 fa ff ff 7f 0e    	cmp    $0xe7fffff,%edx
f0107b05:	76 40                	jbe    f0107b47 <spin_lock+0xc2>
f0107b07:	eb 33                	jmp    f0107b3c <spin_lock+0xb7>
f0107b09:	8d 8a 00 00 80 10    	lea    0x10800000(%edx),%ecx
f0107b0f:	81 f9 ff ff 7f 0e    	cmp    $0xe7fffff,%ecx
f0107b15:	77 2a                	ja     f0107b41 <spin_lock+0xbc>
		    || ebp >= (uint32_t *)IOMEMBASE)
			break;
		pcs[i] = ebp[1];          // saved %eip
f0107b17:	8b 4a 04             	mov    0x4(%edx),%ecx
f0107b1a:	89 0c 86             	mov    %ecx,(%esi,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f0107b1d:	8b 12                	mov    (%edx),%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f0107b1f:	83 c0 01             	add    $0x1,%eax
f0107b22:	83 f8 0a             	cmp    $0xa,%eax
f0107b25:	75 e2                	jne    f0107b09 <spin_lock+0x84>
f0107b27:	eb 2d                	jmp    f0107b56 <spin_lock+0xd1>
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
		pcs[i] = 0;
f0107b29:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
		    || ebp >= (uint32_t *)IOMEMBASE)
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
f0107b2f:	83 c0 01             	add    $0x1,%eax
f0107b32:	83 c2 04             	add    $0x4,%edx
f0107b35:	83 f8 09             	cmp    $0x9,%eax
f0107b38:	7e ef                	jle    f0107b29 <spin_lock+0xa4>
f0107b3a:	eb 1a                	jmp    f0107b56 <spin_lock+0xd1>
	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
	get_caller_pcs(lk->pcs);
#endif
}
f0107b3c:	b8 00 00 00 00       	mov    $0x0,%eax
// Acquire the lock.
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
f0107b41:	8d 54 83 0c          	lea    0xc(%ebx,%eax,4),%edx
f0107b45:	eb e2                	jmp    f0107b29 <spin_lock+0xa4>
	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
		if (ebp == 0 || ebp < (uint32_t *)ULIM
		    || ebp >= (uint32_t *)IOMEMBASE)
			break;
		pcs[i] = ebp[1];          // saved %eip
f0107b47:	8b 50 04             	mov    0x4(%eax),%edx
f0107b4a:	89 53 0c             	mov    %edx,0xc(%ebx)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f0107b4d:	8b 10                	mov    (%eax),%edx
f0107b4f:	b8 01 00 00 00       	mov    $0x1,%eax
f0107b54:	eb b3                	jmp    f0107b09 <spin_lock+0x84>
	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
	get_caller_pcs(lk->pcs);
#endif
}
f0107b56:	83 c4 20             	add    $0x20,%esp
f0107b59:	5b                   	pop    %ebx
f0107b5a:	5e                   	pop    %esi
f0107b5b:	5d                   	pop    %ebp
f0107b5c:	c3                   	ret    
f0107b5d:	00 00                	add    %al,(%eax)
	...

f0107b60 <__udivdi3>:
f0107b60:	55                   	push   %ebp
f0107b61:	89 e5                	mov    %esp,%ebp
f0107b63:	57                   	push   %edi
f0107b64:	56                   	push   %esi
f0107b65:	83 ec 10             	sub    $0x10,%esp
f0107b68:	8b 45 14             	mov    0x14(%ebp),%eax
f0107b6b:	8b 55 08             	mov    0x8(%ebp),%edx
f0107b6e:	8b 75 10             	mov    0x10(%ebp),%esi
f0107b71:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0107b74:	85 c0                	test   %eax,%eax
f0107b76:	89 55 f0             	mov    %edx,-0x10(%ebp)
f0107b79:	75 35                	jne    f0107bb0 <__udivdi3+0x50>
f0107b7b:	39 fe                	cmp    %edi,%esi
f0107b7d:	77 61                	ja     f0107be0 <__udivdi3+0x80>
f0107b7f:	85 f6                	test   %esi,%esi
f0107b81:	75 0b                	jne    f0107b8e <__udivdi3+0x2e>
f0107b83:	b8 01 00 00 00       	mov    $0x1,%eax
f0107b88:	31 d2                	xor    %edx,%edx
f0107b8a:	f7 f6                	div    %esi
f0107b8c:	89 c6                	mov    %eax,%esi
f0107b8e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
f0107b91:	31 d2                	xor    %edx,%edx
f0107b93:	89 f8                	mov    %edi,%eax
f0107b95:	f7 f6                	div    %esi
f0107b97:	89 c7                	mov    %eax,%edi
f0107b99:	89 c8                	mov    %ecx,%eax
f0107b9b:	f7 f6                	div    %esi
f0107b9d:	89 c1                	mov    %eax,%ecx
f0107b9f:	89 fa                	mov    %edi,%edx
f0107ba1:	89 c8                	mov    %ecx,%eax
f0107ba3:	83 c4 10             	add    $0x10,%esp
f0107ba6:	5e                   	pop    %esi
f0107ba7:	5f                   	pop    %edi
f0107ba8:	5d                   	pop    %ebp
f0107ba9:	c3                   	ret    
f0107baa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0107bb0:	39 f8                	cmp    %edi,%eax
f0107bb2:	77 1c                	ja     f0107bd0 <__udivdi3+0x70>
f0107bb4:	0f bd d0             	bsr    %eax,%edx
f0107bb7:	83 f2 1f             	xor    $0x1f,%edx
f0107bba:	89 55 f4             	mov    %edx,-0xc(%ebp)
f0107bbd:	75 39                	jne    f0107bf8 <__udivdi3+0x98>
f0107bbf:	3b 75 f0             	cmp    -0x10(%ebp),%esi
f0107bc2:	0f 86 a0 00 00 00    	jbe    f0107c68 <__udivdi3+0x108>
f0107bc8:	39 f8                	cmp    %edi,%eax
f0107bca:	0f 82 98 00 00 00    	jb     f0107c68 <__udivdi3+0x108>
f0107bd0:	31 ff                	xor    %edi,%edi
f0107bd2:	31 c9                	xor    %ecx,%ecx
f0107bd4:	89 c8                	mov    %ecx,%eax
f0107bd6:	89 fa                	mov    %edi,%edx
f0107bd8:	83 c4 10             	add    $0x10,%esp
f0107bdb:	5e                   	pop    %esi
f0107bdc:	5f                   	pop    %edi
f0107bdd:	5d                   	pop    %ebp
f0107bde:	c3                   	ret    
f0107bdf:	90                   	nop
f0107be0:	89 d1                	mov    %edx,%ecx
f0107be2:	89 fa                	mov    %edi,%edx
f0107be4:	89 c8                	mov    %ecx,%eax
f0107be6:	31 ff                	xor    %edi,%edi
f0107be8:	f7 f6                	div    %esi
f0107bea:	89 c1                	mov    %eax,%ecx
f0107bec:	89 fa                	mov    %edi,%edx
f0107bee:	89 c8                	mov    %ecx,%eax
f0107bf0:	83 c4 10             	add    $0x10,%esp
f0107bf3:	5e                   	pop    %esi
f0107bf4:	5f                   	pop    %edi
f0107bf5:	5d                   	pop    %ebp
f0107bf6:	c3                   	ret    
f0107bf7:	90                   	nop
f0107bf8:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
f0107bfc:	89 f2                	mov    %esi,%edx
f0107bfe:	d3 e0                	shl    %cl,%eax
f0107c00:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0107c03:	b8 20 00 00 00       	mov    $0x20,%eax
f0107c08:	2b 45 f4             	sub    -0xc(%ebp),%eax
f0107c0b:	89 c1                	mov    %eax,%ecx
f0107c0d:	d3 ea                	shr    %cl,%edx
f0107c0f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
f0107c13:	0b 55 ec             	or     -0x14(%ebp),%edx
f0107c16:	d3 e6                	shl    %cl,%esi
f0107c18:	89 c1                	mov    %eax,%ecx
f0107c1a:	89 75 e8             	mov    %esi,-0x18(%ebp)
f0107c1d:	89 fe                	mov    %edi,%esi
f0107c1f:	d3 ee                	shr    %cl,%esi
f0107c21:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
f0107c25:	89 55 ec             	mov    %edx,-0x14(%ebp)
f0107c28:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0107c2b:	d3 e7                	shl    %cl,%edi
f0107c2d:	89 c1                	mov    %eax,%ecx
f0107c2f:	d3 ea                	shr    %cl,%edx
f0107c31:	09 d7                	or     %edx,%edi
f0107c33:	89 f2                	mov    %esi,%edx
f0107c35:	89 f8                	mov    %edi,%eax
f0107c37:	f7 75 ec             	divl   -0x14(%ebp)
f0107c3a:	89 d6                	mov    %edx,%esi
f0107c3c:	89 c7                	mov    %eax,%edi
f0107c3e:	f7 65 e8             	mull   -0x18(%ebp)
f0107c41:	39 d6                	cmp    %edx,%esi
f0107c43:	89 55 ec             	mov    %edx,-0x14(%ebp)
f0107c46:	72 30                	jb     f0107c78 <__udivdi3+0x118>
f0107c48:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0107c4b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
f0107c4f:	d3 e2                	shl    %cl,%edx
f0107c51:	39 c2                	cmp    %eax,%edx
f0107c53:	73 05                	jae    f0107c5a <__udivdi3+0xfa>
f0107c55:	3b 75 ec             	cmp    -0x14(%ebp),%esi
f0107c58:	74 1e                	je     f0107c78 <__udivdi3+0x118>
f0107c5a:	89 f9                	mov    %edi,%ecx
f0107c5c:	31 ff                	xor    %edi,%edi
f0107c5e:	e9 71 ff ff ff       	jmp    f0107bd4 <__udivdi3+0x74>
f0107c63:	90                   	nop
f0107c64:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0107c68:	31 ff                	xor    %edi,%edi
f0107c6a:	b9 01 00 00 00       	mov    $0x1,%ecx
f0107c6f:	e9 60 ff ff ff       	jmp    f0107bd4 <__udivdi3+0x74>
f0107c74:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0107c78:	8d 4f ff             	lea    -0x1(%edi),%ecx
f0107c7b:	31 ff                	xor    %edi,%edi
f0107c7d:	89 c8                	mov    %ecx,%eax
f0107c7f:	89 fa                	mov    %edi,%edx
f0107c81:	83 c4 10             	add    $0x10,%esp
f0107c84:	5e                   	pop    %esi
f0107c85:	5f                   	pop    %edi
f0107c86:	5d                   	pop    %ebp
f0107c87:	c3                   	ret    
	...

f0107c90 <__umoddi3>:
f0107c90:	55                   	push   %ebp
f0107c91:	89 e5                	mov    %esp,%ebp
f0107c93:	57                   	push   %edi
f0107c94:	56                   	push   %esi
f0107c95:	83 ec 20             	sub    $0x20,%esp
f0107c98:	8b 55 14             	mov    0x14(%ebp),%edx
f0107c9b:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0107c9e:	8b 7d 10             	mov    0x10(%ebp),%edi
f0107ca1:	8b 75 0c             	mov    0xc(%ebp),%esi
f0107ca4:	85 d2                	test   %edx,%edx
f0107ca6:	89 c8                	mov    %ecx,%eax
f0107ca8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
f0107cab:	75 13                	jne    f0107cc0 <__umoddi3+0x30>
f0107cad:	39 f7                	cmp    %esi,%edi
f0107caf:	76 3f                	jbe    f0107cf0 <__umoddi3+0x60>
f0107cb1:	89 f2                	mov    %esi,%edx
f0107cb3:	f7 f7                	div    %edi
f0107cb5:	89 d0                	mov    %edx,%eax
f0107cb7:	31 d2                	xor    %edx,%edx
f0107cb9:	83 c4 20             	add    $0x20,%esp
f0107cbc:	5e                   	pop    %esi
f0107cbd:	5f                   	pop    %edi
f0107cbe:	5d                   	pop    %ebp
f0107cbf:	c3                   	ret    
f0107cc0:	39 f2                	cmp    %esi,%edx
f0107cc2:	77 4c                	ja     f0107d10 <__umoddi3+0x80>
f0107cc4:	0f bd ca             	bsr    %edx,%ecx
f0107cc7:	83 f1 1f             	xor    $0x1f,%ecx
f0107cca:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0107ccd:	75 51                	jne    f0107d20 <__umoddi3+0x90>
f0107ccf:	3b 7d f4             	cmp    -0xc(%ebp),%edi
f0107cd2:	0f 87 e0 00 00 00    	ja     f0107db8 <__umoddi3+0x128>
f0107cd8:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0107cdb:	29 f8                	sub    %edi,%eax
f0107cdd:	19 d6                	sbb    %edx,%esi
f0107cdf:	89 45 f4             	mov    %eax,-0xc(%ebp)
f0107ce2:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0107ce5:	89 f2                	mov    %esi,%edx
f0107ce7:	83 c4 20             	add    $0x20,%esp
f0107cea:	5e                   	pop    %esi
f0107ceb:	5f                   	pop    %edi
f0107cec:	5d                   	pop    %ebp
f0107ced:	c3                   	ret    
f0107cee:	66 90                	xchg   %ax,%ax
f0107cf0:	85 ff                	test   %edi,%edi
f0107cf2:	75 0b                	jne    f0107cff <__umoddi3+0x6f>
f0107cf4:	b8 01 00 00 00       	mov    $0x1,%eax
f0107cf9:	31 d2                	xor    %edx,%edx
f0107cfb:	f7 f7                	div    %edi
f0107cfd:	89 c7                	mov    %eax,%edi
f0107cff:	89 f0                	mov    %esi,%eax
f0107d01:	31 d2                	xor    %edx,%edx
f0107d03:	f7 f7                	div    %edi
f0107d05:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0107d08:	f7 f7                	div    %edi
f0107d0a:	eb a9                	jmp    f0107cb5 <__umoddi3+0x25>
f0107d0c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0107d10:	89 c8                	mov    %ecx,%eax
f0107d12:	89 f2                	mov    %esi,%edx
f0107d14:	83 c4 20             	add    $0x20,%esp
f0107d17:	5e                   	pop    %esi
f0107d18:	5f                   	pop    %edi
f0107d19:	5d                   	pop    %ebp
f0107d1a:	c3                   	ret    
f0107d1b:	90                   	nop
f0107d1c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0107d20:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0107d24:	d3 e2                	shl    %cl,%edx
f0107d26:	89 55 f4             	mov    %edx,-0xc(%ebp)
f0107d29:	ba 20 00 00 00       	mov    $0x20,%edx
f0107d2e:	2b 55 f0             	sub    -0x10(%ebp),%edx
f0107d31:	89 55 ec             	mov    %edx,-0x14(%ebp)
f0107d34:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f0107d38:	89 fa                	mov    %edi,%edx
f0107d3a:	d3 ea                	shr    %cl,%edx
f0107d3c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0107d40:	0b 55 f4             	or     -0xc(%ebp),%edx
f0107d43:	d3 e7                	shl    %cl,%edi
f0107d45:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f0107d49:	89 55 f4             	mov    %edx,-0xc(%ebp)
f0107d4c:	89 f2                	mov    %esi,%edx
f0107d4e:	89 7d e8             	mov    %edi,-0x18(%ebp)
f0107d51:	89 c7                	mov    %eax,%edi
f0107d53:	d3 ea                	shr    %cl,%edx
f0107d55:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0107d59:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0107d5c:	89 c2                	mov    %eax,%edx
f0107d5e:	d3 e6                	shl    %cl,%esi
f0107d60:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f0107d64:	d3 ea                	shr    %cl,%edx
f0107d66:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0107d6a:	09 d6                	or     %edx,%esi
f0107d6c:	89 f0                	mov    %esi,%eax
f0107d6e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0107d71:	d3 e7                	shl    %cl,%edi
f0107d73:	89 f2                	mov    %esi,%edx
f0107d75:	f7 75 f4             	divl   -0xc(%ebp)
f0107d78:	89 d6                	mov    %edx,%esi
f0107d7a:	f7 65 e8             	mull   -0x18(%ebp)
f0107d7d:	39 d6                	cmp    %edx,%esi
f0107d7f:	72 2b                	jb     f0107dac <__umoddi3+0x11c>
f0107d81:	39 c7                	cmp    %eax,%edi
f0107d83:	72 23                	jb     f0107da8 <__umoddi3+0x118>
f0107d85:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0107d89:	29 c7                	sub    %eax,%edi
f0107d8b:	19 d6                	sbb    %edx,%esi
f0107d8d:	89 f0                	mov    %esi,%eax
f0107d8f:	89 f2                	mov    %esi,%edx
f0107d91:	d3 ef                	shr    %cl,%edi
f0107d93:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f0107d97:	d3 e0                	shl    %cl,%eax
f0107d99:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0107d9d:	09 f8                	or     %edi,%eax
f0107d9f:	d3 ea                	shr    %cl,%edx
f0107da1:	83 c4 20             	add    $0x20,%esp
f0107da4:	5e                   	pop    %esi
f0107da5:	5f                   	pop    %edi
f0107da6:	5d                   	pop    %ebp
f0107da7:	c3                   	ret    
f0107da8:	39 d6                	cmp    %edx,%esi
f0107daa:	75 d9                	jne    f0107d85 <__umoddi3+0xf5>
f0107dac:	2b 45 e8             	sub    -0x18(%ebp),%eax
f0107daf:	1b 55 f4             	sbb    -0xc(%ebp),%edx
f0107db2:	eb d1                	jmp    f0107d85 <__umoddi3+0xf5>
f0107db4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0107db8:	39 f2                	cmp    %esi,%edx
f0107dba:	0f 82 18 ff ff ff    	jb     f0107cd8 <__umoddi3+0x48>
f0107dc0:	e9 1d ff ff ff       	jmp    f0107ce2 <__umoddi3+0x52>
