
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
f0100058:	c7 04 24 e0 7f 10 f0 	movl   $0xf0107fe0,(%esp)
f010005f:	e8 5b 4a 00 00       	call   f0104abf <cprintf>
	vcprintf(fmt, ap);
f0100064:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100068:	8b 45 10             	mov    0x10(%ebp),%eax
f010006b:	89 04 24             	mov    %eax,(%esp)
f010006e:	e8 19 4a 00 00       	call   f0104a8c <vcprintf>
	cprintf("\n");
f0100073:	c7 04 24 d9 84 10 f0 	movl   $0xf01084d9,(%esp)
f010007a:	e8 40 4a 00 00       	call   f0104abf <cprintf>
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
f0100090:	83 3d a0 0e 1f f0 00 	cmpl   $0x0,0xf01f0ea0
f0100097:	75 46                	jne    f01000df <_panic+0x5a>
		goto dead;
	panicstr = fmt;
f0100099:	89 35 a0 0e 1f f0    	mov    %esi,0xf01f0ea0

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
f01000a4:	e8 25 78 00 00       	call   f01078ce <cpunum>
f01000a9:	8b 55 0c             	mov    0xc(%ebp),%edx
f01000ac:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01000b0:	8b 55 08             	mov    0x8(%ebp),%edx
f01000b3:	89 54 24 08          	mov    %edx,0x8(%esp)
f01000b7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01000bb:	c7 04 24 38 80 10 f0 	movl   $0xf0108038,(%esp)
f01000c2:	e8 f8 49 00 00       	call   f0104abf <cprintf>
	vcprintf(fmt, ap);
f01000c7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01000cb:	89 34 24             	mov    %esi,(%esp)
f01000ce:	e8 b9 49 00 00       	call   f0104a8c <vcprintf>
	cprintf("\n");
f01000d3:	c7 04 24 d9 84 10 f0 	movl   $0xf01084d9,(%esp)
f01000da:	e8 e0 49 00 00       	call   f0104abf <cprintf>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f01000df:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01000e6:	e8 9e 0a 00 00       	call   f0100b89 <monitor>
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
f01000f3:	a1 ac 0e 1f f0       	mov    0xf01f0eac,%eax
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
f0100105:	c7 44 24 08 5c 80 10 	movl   $0xf010805c,0x8(%esp)
f010010c:	f0 
f010010d:	c7 44 24 04 9e 00 00 	movl   $0x9e,0x4(%esp)
f0100114:	00 
f0100115:	c7 04 24 fa 7f 10 f0 	movl   $0xf0107ffa,(%esp)
f010011c:	e8 64 ff ff ff       	call   f0100085 <_panic>
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0100121:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f0100127:	0f 22 da             	mov    %edx,%cr3
	cprintf("SMP: CPU %d starting\n", cpunum());
f010012a:	e8 9f 77 00 00       	call   f01078ce <cpunum>
f010012f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100133:	c7 04 24 06 80 10 f0 	movl   $0xf0108006,(%esp)
f010013a:	e8 80 49 00 00       	call   f0104abf <cprintf>

	lapic_init();
f010013f:	e8 a6 77 00 00       	call   f01078ea <lapic_init>
	env_init_percpu();
f0100144:	e8 37 40 00 00       	call   f0104180 <env_init_percpu>
	trap_init_percpu();
f0100149:	e8 a2 49 00 00       	call   f0104af0 <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f010014e:	66 90                	xchg   %ax,%ax
f0100150:	e8 79 77 00 00       	call   f01078ce <cpunum>
f0100155:	6b d0 74             	imul   $0x74,%eax,%edx
f0100158:	81 c2 24 10 1f f0    	add    $0xf01f1024,%edx
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
f010016d:	e8 23 7b 00 00       	call   f0107c95 <spin_lock>
	// to start running processes on this CPU.  But make sure that
	// only one CPU can enter the scheduler at a time!
	//
	// Your code here:
        lock_kernel();
        sched_yield();
f0100172:	e8 b9 57 00 00       	call   f0105930 <sched_yield>

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
f010017f:	b8 04 20 23 f0       	mov    $0xf0232004,%eax
f0100184:	2d 5b f3 1e f0       	sub    $0xf01ef35b,%eax
f0100189:	89 44 24 08          	mov    %eax,0x8(%esp)
f010018d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100194:	00 
f0100195:	c7 04 24 5b f3 1e f0 	movl   $0xf01ef35b,(%esp)
f010019c:	e8 85 70 00 00       	call   f0107226 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01001a1:	e8 8f 06 00 00       	call   f0100835 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01001a6:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f01001ad:	00 
f01001ae:	c7 04 24 1c 80 10 f0 	movl   $0xf010801c,(%esp)
f01001b5:	e8 05 49 00 00       	call   f0104abf <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f01001ba:	e8 b6 26 00 00       	call   f0102875 <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f01001bf:	e8 e6 3f 00 00       	call   f01041aa <env_init>
	trap_init();
f01001c4:	e8 d0 49 00 00       	call   f0104b99 <trap_init>

	// Lab 4 multiprocessor initialization functions
	mp_init();
f01001c9:	e8 1c 74 00 00       	call   f01075ea <mp_init>
	lapic_init();
f01001ce:	66 90                	xchg   %ax,%ax
f01001d0:	e8 15 77 00 00       	call   f01078ea <lapic_init>

	// Lab 4 multitasking initialization functions
	pic_init();
f01001d5:	e8 23 48 00 00       	call   f01049fd <pic_init>
f01001da:	c7 04 24 80 43 12 f0 	movl   $0xf0124380,(%esp)
f01001e1:	e8 af 7a 00 00       	call   f0107c95 <spin_lock>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01001e6:	83 3d a8 0e 1f f0 07 	cmpl   $0x7,0xf01f0ea8
f01001ed:	77 24                	ja     f0100213 <i386_init+0x9c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01001ef:	c7 44 24 0c 00 70 00 	movl   $0x7000,0xc(%esp)
f01001f6:	00 
f01001f7:	c7 44 24 08 80 80 10 	movl   $0xf0108080,0x8(%esp)
f01001fe:	f0 
f01001ff:	c7 44 24 04 87 00 00 	movl   $0x87,0x4(%esp)
f0100206:	00 
f0100207:	c7 04 24 fa 7f 10 f0 	movl   $0xf0107ffa,(%esp)
f010020e:	e8 72 fe ff ff       	call   f0100085 <_panic>
	void *code;
	struct Cpu *c;

	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f0100213:	b8 06 75 10 f0       	mov    $0xf0107506,%eax
f0100218:	2d 8c 74 10 f0       	sub    $0xf010748c,%eax
f010021d:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100221:	c7 44 24 04 8c 74 10 	movl   $0xf010748c,0x4(%esp)
f0100228:	f0 
f0100229:	c7 04 24 00 70 00 f0 	movl   $0xf0007000,(%esp)
f0100230:	e8 50 70 00 00       	call   f0107285 <memmove>

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f0100235:	6b 05 c4 13 1f f0 74 	imul   $0x74,0xf01f13c4,%eax
f010023c:	05 20 10 1f f0       	add    $0xf01f1020,%eax
f0100241:	3d 20 10 1f f0       	cmp    $0xf01f1020,%eax
f0100246:	76 65                	jbe    f01002ad <i386_init+0x136>
f0100248:	be 00 00 00 00       	mov    $0x0,%esi
f010024d:	bb 20 10 1f f0       	mov    $0xf01f1020,%ebx
		if (c == cpus + cpunum())  // We've started already.
f0100252:	e8 77 76 00 00       	call   f01078ce <cpunum>
f0100257:	6b c0 74             	imul   $0x74,%eax,%eax
f010025a:	05 20 10 1f f0       	add    $0xf01f1020,%eax
f010025f:	39 c3                	cmp    %eax,%ebx
f0100261:	74 34                	je     f0100297 <i386_init+0x120>
			continue;

		// Tell mpentry.S what stack to use 
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f0100263:	89 f0                	mov    %esi,%eax
f0100265:	c1 f8 02             	sar    $0x2,%eax
f0100268:	69 c0 35 c2 72 4f    	imul   $0x4f72c235,%eax,%eax
f010026e:	c1 e0 0f             	shl    $0xf,%eax
f0100271:	8d 80 00 a0 1f f0    	lea    -0xfe06000(%eax),%eax
f0100277:	a3 a4 0e 1f f0       	mov    %eax,0xf01f0ea4
		// Start the CPU at mpentry_start
		lapic_startap(c->cpu_id, PADDR(code));
f010027c:	c7 44 24 04 00 70 00 	movl   $0x7000,0x4(%esp)
f0100283:	00 
f0100284:	0f b6 03             	movzbl (%ebx),%eax
f0100287:	89 04 24             	mov    %eax,(%esp)
f010028a:	e8 c5 77 00 00       	call   f0107a54 <lapic_startap>
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
f010029d:	6b 05 c4 13 1f f0 74 	imul   $0x74,0xf01f13c4,%eax
f01002a4:	05 20 10 1f f0       	add    $0xf01f1020,%eax
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
f01002ba:	c7 44 24 04 7f 4c 00 	movl   $0x4c7f,0x4(%esp)
f01002c1:	00 
f01002c2:	c7 04 24 97 c0 16 f0 	movl   $0xf016c097,(%esp)
f01002c9:	e8 0d 45 00 00       	call   f01047db <env_create>
	lock_kernel();
#endif

	// Should always have idle processes at first.
	int i;
	for (i = 0; i < NCPU; i++)
f01002ce:	83 c3 01             	add    $0x1,%ebx
f01002d1:	83 fb 08             	cmp    $0x8,%ebx
f01002d4:	75 dc                	jne    f01002b2 <i386_init+0x13b>
		ENV_CREATE(user_idle, ENV_TYPE_IDLE);

	// Start fs.
	ENV_CREATE(fs_fs, ENV_TYPE_FS);
f01002d6:	c7 44 24 08 02 00 00 	movl   $0x2,0x8(%esp)
f01002dd:	00 
f01002de:	c7 44 24 04 fc 63 01 	movl   $0x163fc,0x4(%esp)
f01002e5:	00 
f01002e6:	c7 04 24 5f 8f 1d f0 	movl   $0xf01d8f5f,(%esp)
f01002ed:	e8 e9 44 00 00       	call   f01047db <env_create>

#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
f01002f2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01002f9:	00 
f01002fa:	c7 44 24 04 0c 5d 00 	movl   $0x5d0c,0x4(%esp)
f0100301:	00 
f0100302:	c7 04 24 48 d5 1c f0 	movl   $0xf01cd548,(%esp)
f0100309:	e8 cd 44 00 00       	call   f01047db <env_create>
	// ENV_CREATE(user_icode, ENV_TYPE_USER);

#endif // TEST*

	// Schedule and run the first user environment!
	sched_yield();
f010030e:	e8 1d 56 00 00       	call   f0105930 <sched_yield>

f0100313 <spinlock_test>:
static void boot_aps(void);

static volatile int test_ctr = 0;

void spinlock_test()
{
f0100313:	55                   	push   %ebp
f0100314:	89 e5                	mov    %esp,%ebp
f0100316:	56                   	push   %esi
f0100317:	53                   	push   %ebx
f0100318:	83 ec 20             	sub    $0x20,%esp
	int i;
	volatile int interval = 0;
f010031b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	/* BSP give APs some time to reach this point */
	if (cpunum() == 0) {
f0100322:	e8 a7 75 00 00       	call   f01078ce <cpunum>
f0100327:	85 c0                	test   %eax,%eax
f0100329:	75 10                	jne    f010033b <spinlock_test+0x28>
		while (interval++ < 10000)
f010032b:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010032e:	8d 50 01             	lea    0x1(%eax),%edx
f0100331:	89 55 f4             	mov    %edx,-0xc(%ebp)
f0100334:	3d 0f 27 00 00       	cmp    $0x270f,%eax
f0100339:	7e 0c                	jle    f0100347 <spinlock_test+0x34>
f010033b:	bb 00 00 00 00       	mov    $0x0,%ebx
			asm volatile("pause");
	}

	for (i=0; i<100; i++) {
		lock_kernel();
		if (test_ctr % 10000 != 0)
f0100340:	be ad 8b db 68       	mov    $0x68db8bad,%esi
f0100345:	eb 14                	jmp    f010035b <spinlock_test+0x48>
	volatile int interval = 0;

	/* BSP give APs some time to reach this point */
	if (cpunum() == 0) {
		while (interval++ < 10000)
			asm volatile("pause");
f0100347:	f3 90                	pause  
	int i;
	volatile int interval = 0;

	/* BSP give APs some time to reach this point */
	if (cpunum() == 0) {
		while (interval++ < 10000)
f0100349:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010034c:	8d 50 01             	lea    0x1(%eax),%edx
f010034f:	89 55 f4             	mov    %edx,-0xc(%ebp)
f0100352:	3d 0f 27 00 00       	cmp    $0x270f,%eax
f0100357:	7e ee                	jle    f0100347 <spinlock_test+0x34>
f0100359:	eb e0                	jmp    f010033b <spinlock_test+0x28>
f010035b:	c7 04 24 80 43 12 f0 	movl   $0xf0124380,(%esp)
f0100362:	e8 2e 79 00 00       	call   f0107c95 <spin_lock>
			asm volatile("pause");
	}

	for (i=0; i<100; i++) {
		lock_kernel();
		if (test_ctr % 10000 != 0)
f0100367:	8b 0d 00 00 1f f0    	mov    0xf01f0000,%ecx
f010036d:	89 c8                	mov    %ecx,%eax
f010036f:	f7 ee                	imul   %esi
f0100371:	c1 fa 0c             	sar    $0xc,%edx
f0100374:	89 c8                	mov    %ecx,%eax
f0100376:	c1 f8 1f             	sar    $0x1f,%eax
f0100379:	29 c2                	sub    %eax,%edx
f010037b:	69 d2 10 27 00 00    	imul   $0x2710,%edx,%edx
f0100381:	39 d1                	cmp    %edx,%ecx
f0100383:	74 1c                	je     f01003a1 <spinlock_test+0x8e>
			panic("ticket spinlock test fail: I saw a middle value\n");
f0100385:	c7 44 24 08 a4 80 10 	movl   $0xf01080a4,0x8(%esp)
f010038c:	f0 
f010038d:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
f0100394:	00 
f0100395:	c7 04 24 fa 7f 10 f0 	movl   $0xf0107ffa,(%esp)
f010039c:	e8 e4 fc ff ff       	call   f0100085 <_panic>
		interval = 0;
f01003a1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
		while (interval++ < 10000)
f01003a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01003ab:	8d 50 01             	lea    0x1(%eax),%edx
f01003ae:	89 55 f4             	mov    %edx,-0xc(%ebp)
f01003b1:	3d 0f 27 00 00       	cmp    $0x270f,%eax
f01003b6:	7f 1d                	jg     f01003d5 <spinlock_test+0xc2>
			test_ctr++;
f01003b8:	a1 00 00 1f f0       	mov    0xf01f0000,%eax
f01003bd:	83 c0 01             	add    $0x1,%eax
f01003c0:	a3 00 00 1f f0       	mov    %eax,0xf01f0000
	for (i=0; i<100; i++) {
		lock_kernel();
		if (test_ctr % 10000 != 0)
			panic("ticket spinlock test fail: I saw a middle value\n");
		interval = 0;
		while (interval++ < 10000)
f01003c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01003c8:	8d 50 01             	lea    0x1(%eax),%edx
f01003cb:	89 55 f4             	mov    %edx,-0xc(%ebp)
f01003ce:	3d 0f 27 00 00       	cmp    $0x270f,%eax
f01003d3:	7e e3                	jle    f01003b8 <spinlock_test+0xa5>
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f01003d5:	c7 04 24 80 43 12 f0 	movl   $0xf0124380,(%esp)
f01003dc:	e8 9b 77 00 00       	call   f0107b7c <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f01003e1:	f3 90                	pause  
	if (cpunum() == 0) {
		while (interval++ < 10000)
			asm volatile("pause");
	}

	for (i=0; i<100; i++) {
f01003e3:	83 c3 01             	add    $0x1,%ebx
f01003e6:	83 fb 64             	cmp    $0x64,%ebx
f01003e9:	0f 85 6c ff ff ff    	jne    f010035b <spinlock_test+0x48>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f01003ef:	c7 04 24 80 43 12 f0 	movl   $0xf0124380,(%esp)
f01003f6:	e8 9a 78 00 00       	call   f0107c95 <spin_lock>
		while (interval++ < 10000)
			test_ctr++;
		unlock_kernel();
	}
	lock_kernel();
	cprintf("spinlock_test() succeeded on CPU %d!\n", cpunum());
f01003fb:	e8 ce 74 00 00       	call   f01078ce <cpunum>
f0100400:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100404:	c7 04 24 d8 80 10 f0 	movl   $0xf01080d8,(%esp)
f010040b:	e8 af 46 00 00       	call   f0104abf <cprintf>
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0100410:	c7 04 24 80 43 12 f0 	movl   $0xf0124380,(%esp)
f0100417:	e8 60 77 00 00       	call   f0107b7c <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f010041c:	f3 90                	pause  
	unlock_kernel();
}
f010041e:	83 c4 20             	add    $0x20,%esp
f0100421:	5b                   	pop    %ebx
f0100422:	5e                   	pop    %esi
f0100423:	5d                   	pop    %ebp
f0100424:	c3                   	ret    
	...

f0100430 <delay>:
static void cons_putc(int c);

// Stupid I/O delay routine necessitated by historical PC design flaws
static void
delay(void)
{
f0100430:	55                   	push   %ebp
f0100431:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100433:	ba 84 00 00 00       	mov    $0x84,%edx
f0100438:	ec                   	in     (%dx),%al
f0100439:	ec                   	in     (%dx),%al
f010043a:	ec                   	in     (%dx),%al
f010043b:	ec                   	in     (%dx),%al
	inb(0x84);
	inb(0x84);
	inb(0x84);
	inb(0x84);
}
f010043c:	5d                   	pop    %ebp
f010043d:	c3                   	ret    

f010043e <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f010043e:	55                   	push   %ebp
f010043f:	89 e5                	mov    %esp,%ebp
f0100441:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100446:	ec                   	in     (%dx),%al
f0100447:	89 c2                	mov    %eax,%edx
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f0100449:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010044e:	f6 c2 01             	test   $0x1,%dl
f0100451:	74 09                	je     f010045c <serial_proc_data+0x1e>
f0100453:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100458:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f0100459:	0f b6 c0             	movzbl %al,%eax
}
f010045c:	5d                   	pop    %ebp
f010045d:	c3                   	ret    

f010045e <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f010045e:	55                   	push   %ebp
f010045f:	89 e5                	mov    %esp,%ebp
f0100461:	57                   	push   %edi
f0100462:	56                   	push   %esi
f0100463:	53                   	push   %ebx
f0100464:	83 ec 0c             	sub    $0xc,%esp
f0100467:	89 c6                	mov    %eax,%esi
	int c;

	while ((c = (*proc)()) != -1) {
		if (c == 0)
			continue;
		cons.buf[cons.wpos++] = c;
f0100469:	bb 44 02 1f f0       	mov    $0xf01f0244,%ebx
f010046e:	bf 40 00 1f f0       	mov    $0xf01f0040,%edi
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f0100473:	eb 1e                	jmp    f0100493 <cons_intr+0x35>
		if (c == 0)
f0100475:	85 c0                	test   %eax,%eax
f0100477:	74 1a                	je     f0100493 <cons_intr+0x35>
			continue;
		cons.buf[cons.wpos++] = c;
f0100479:	8b 13                	mov    (%ebx),%edx
f010047b:	88 04 17             	mov    %al,(%edi,%edx,1)
f010047e:	8d 42 01             	lea    0x1(%edx),%eax
		if (cons.wpos == CONSBUFSIZE)
f0100481:	3d 00 02 00 00       	cmp    $0x200,%eax
			cons.wpos = 0;
f0100486:	0f 94 c2             	sete   %dl
f0100489:	0f b6 d2             	movzbl %dl,%edx
f010048c:	83 ea 01             	sub    $0x1,%edx
f010048f:	21 d0                	and    %edx,%eax
f0100491:	89 03                	mov    %eax,(%ebx)
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f0100493:	ff d6                	call   *%esi
f0100495:	83 f8 ff             	cmp    $0xffffffff,%eax
f0100498:	75 db                	jne    f0100475 <cons_intr+0x17>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f010049a:	83 c4 0c             	add    $0xc,%esp
f010049d:	5b                   	pop    %ebx
f010049e:	5e                   	pop    %esi
f010049f:	5f                   	pop    %edi
f01004a0:	5d                   	pop    %ebp
f01004a1:	c3                   	ret    

f01004a2 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f01004a2:	55                   	push   %ebp
f01004a3:	89 e5                	mov    %esp,%ebp
f01004a5:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f01004a8:	b8 3a 07 10 f0       	mov    $0xf010073a,%eax
f01004ad:	e8 ac ff ff ff       	call   f010045e <cons_intr>
}
f01004b2:	c9                   	leave  
f01004b3:	c3                   	ret    

f01004b4 <serial_intr>:
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f01004b4:	55                   	push   %ebp
f01004b5:	89 e5                	mov    %esp,%ebp
f01004b7:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
f01004ba:	83 3d 24 00 1f f0 00 	cmpl   $0x0,0xf01f0024
f01004c1:	74 0a                	je     f01004cd <serial_intr+0x19>
		cons_intr(serial_proc_data);
f01004c3:	b8 3e 04 10 f0       	mov    $0xf010043e,%eax
f01004c8:	e8 91 ff ff ff       	call   f010045e <cons_intr>
}
f01004cd:	c9                   	leave  
f01004ce:	c3                   	ret    

f01004cf <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f01004cf:	55                   	push   %ebp
f01004d0:	89 e5                	mov    %esp,%ebp
f01004d2:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f01004d5:	e8 da ff ff ff       	call   f01004b4 <serial_intr>
	kbd_intr();
f01004da:	e8 c3 ff ff ff       	call   f01004a2 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f01004df:	8b 15 40 02 1f f0    	mov    0xf01f0240,%edx
f01004e5:	b8 00 00 00 00       	mov    $0x0,%eax
f01004ea:	3b 15 44 02 1f f0    	cmp    0xf01f0244,%edx
f01004f0:	74 21                	je     f0100513 <cons_getc+0x44>
		c = cons.buf[cons.rpos++];
f01004f2:	0f b6 82 40 00 1f f0 	movzbl -0xfe0ffc0(%edx),%eax
f01004f9:	83 c2 01             	add    $0x1,%edx
		if (cons.rpos == CONSBUFSIZE)
f01004fc:	81 fa 00 02 00 00    	cmp    $0x200,%edx
			cons.rpos = 0;
f0100502:	0f 94 c1             	sete   %cl
f0100505:	0f b6 c9             	movzbl %cl,%ecx
f0100508:	83 e9 01             	sub    $0x1,%ecx
f010050b:	21 ca                	and    %ecx,%edx
f010050d:	89 15 40 02 1f f0    	mov    %edx,0xf01f0240
		return c;
	}
	return 0;
}
f0100513:	c9                   	leave  
f0100514:	c3                   	ret    

f0100515 <getchar>:
	cons_putc(c);
}

int
getchar(void)
{
f0100515:	55                   	push   %ebp
f0100516:	89 e5                	mov    %esp,%ebp
f0100518:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f010051b:	e8 af ff ff ff       	call   f01004cf <cons_getc>
f0100520:	85 c0                	test   %eax,%eax
f0100522:	74 f7                	je     f010051b <getchar+0x6>
		/* do nothing */;
	return c;
}
f0100524:	c9                   	leave  
f0100525:	c3                   	ret    

f0100526 <iscons>:

int
iscons(int fdnum)
{
f0100526:	55                   	push   %ebp
f0100527:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f0100529:	b8 01 00 00 00       	mov    $0x1,%eax
f010052e:	5d                   	pop    %ebp
f010052f:	c3                   	ret    

f0100530 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f0100530:	55                   	push   %ebp
f0100531:	89 e5                	mov    %esp,%ebp
f0100533:	57                   	push   %edi
f0100534:	56                   	push   %esi
f0100535:	53                   	push   %ebx
f0100536:	83 ec 2c             	sub    $0x2c,%esp
f0100539:	89 c7                	mov    %eax,%edi
f010053b:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100540:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;
	
	for (i = 0;
f0100541:	a8 20                	test   $0x20,%al
f0100543:	75 21                	jne    f0100566 <cons_putc+0x36>
f0100545:	bb 00 00 00 00       	mov    $0x0,%ebx
f010054a:	be fd 03 00 00       	mov    $0x3fd,%esi
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
		delay();
f010054f:	e8 dc fe ff ff       	call   f0100430 <delay>
f0100554:	89 f2                	mov    %esi,%edx
f0100556:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;
	
	for (i = 0;
f0100557:	a8 20                	test   $0x20,%al
f0100559:	75 0b                	jne    f0100566 <cons_putc+0x36>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
f010055b:	83 c3 01             	add    $0x1,%ebx
static void
serial_putc(int c)
{
	int i;
	
	for (i = 0;
f010055e:	81 fb 00 32 00 00    	cmp    $0x3200,%ebx
f0100564:	75 e9                	jne    f010054f <cons_putc+0x1f>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
		delay();
	
	outb(COM1 + COM_TX, c);
f0100566:	89 fa                	mov    %edi,%edx
f0100568:	89 f8                	mov    %edi,%eax
f010056a:	88 55 e7             	mov    %dl,-0x19(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010056d:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100572:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100573:	b2 79                	mov    $0x79,%dl
f0100575:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f0100576:	84 c0                	test   %al,%al
f0100578:	78 21                	js     f010059b <cons_putc+0x6b>
f010057a:	bb 00 00 00 00       	mov    $0x0,%ebx
f010057f:	be 79 03 00 00       	mov    $0x379,%esi
		delay();
f0100584:	e8 a7 fe ff ff       	call   f0100430 <delay>
f0100589:	89 f2                	mov    %esi,%edx
f010058b:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f010058c:	84 c0                	test   %al,%al
f010058e:	78 0b                	js     f010059b <cons_putc+0x6b>
f0100590:	83 c3 01             	add    $0x1,%ebx
f0100593:	81 fb 00 32 00 00    	cmp    $0x3200,%ebx
f0100599:	75 e9                	jne    f0100584 <cons_putc+0x54>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010059b:	ba 78 03 00 00       	mov    $0x378,%edx
f01005a0:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f01005a4:	ee                   	out    %al,(%dx)
f01005a5:	b2 7a                	mov    $0x7a,%dl
f01005a7:	b8 0d 00 00 00       	mov    $0xd,%eax
f01005ac:	ee                   	out    %al,(%dx)
f01005ad:	b8 08 00 00 00       	mov    $0x8,%eax
f01005b2:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f01005b3:	f7 c7 00 ff ff ff    	test   $0xffffff00,%edi
f01005b9:	75 06                	jne    f01005c1 <cons_putc+0x91>
		c |= 0x0700;
f01005bb:	81 cf 00 07 00 00    	or     $0x700,%edi

	switch (c & 0xff) {
f01005c1:	89 f8                	mov    %edi,%eax
f01005c3:	25 ff 00 00 00       	and    $0xff,%eax
f01005c8:	83 f8 09             	cmp    $0x9,%eax
f01005cb:	0f 84 83 00 00 00    	je     f0100654 <cons_putc+0x124>
f01005d1:	83 f8 09             	cmp    $0x9,%eax
f01005d4:	7f 0c                	jg     f01005e2 <cons_putc+0xb2>
f01005d6:	83 f8 08             	cmp    $0x8,%eax
f01005d9:	0f 85 a9 00 00 00    	jne    f0100688 <cons_putc+0x158>
f01005df:	90                   	nop
f01005e0:	eb 18                	jmp    f01005fa <cons_putc+0xca>
f01005e2:	83 f8 0a             	cmp    $0xa,%eax
f01005e5:	8d 76 00             	lea    0x0(%esi),%esi
f01005e8:	74 40                	je     f010062a <cons_putc+0xfa>
f01005ea:	83 f8 0d             	cmp    $0xd,%eax
f01005ed:	8d 76 00             	lea    0x0(%esi),%esi
f01005f0:	0f 85 92 00 00 00    	jne    f0100688 <cons_putc+0x158>
f01005f6:	66 90                	xchg   %ax,%ax
f01005f8:	eb 38                	jmp    f0100632 <cons_putc+0x102>
	case '\b':
		if (crt_pos > 0) {
f01005fa:	0f b7 05 30 00 1f f0 	movzwl 0xf01f0030,%eax
f0100601:	66 85 c0             	test   %ax,%ax
f0100604:	0f 84 e8 00 00 00    	je     f01006f2 <cons_putc+0x1c2>
			crt_pos--;
f010060a:	83 e8 01             	sub    $0x1,%eax
f010060d:	66 a3 30 00 1f f0    	mov    %ax,0xf01f0030
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f0100613:	0f b7 c0             	movzwl %ax,%eax
f0100616:	66 81 e7 00 ff       	and    $0xff00,%di
f010061b:	83 cf 20             	or     $0x20,%edi
f010061e:	8b 15 2c 00 1f f0    	mov    0xf01f002c,%edx
f0100624:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f0100628:	eb 7b                	jmp    f01006a5 <cons_putc+0x175>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f010062a:	66 83 05 30 00 1f f0 	addw   $0x50,0xf01f0030
f0100631:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f0100632:	0f b7 05 30 00 1f f0 	movzwl 0xf01f0030,%eax
f0100639:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f010063f:	c1 e8 10             	shr    $0x10,%eax
f0100642:	66 c1 e8 06          	shr    $0x6,%ax
f0100646:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0100649:	c1 e0 04             	shl    $0x4,%eax
f010064c:	66 a3 30 00 1f f0    	mov    %ax,0xf01f0030
f0100652:	eb 51                	jmp    f01006a5 <cons_putc+0x175>
		break;
	case '\t':
		cons_putc(' ');
f0100654:	b8 20 00 00 00       	mov    $0x20,%eax
f0100659:	e8 d2 fe ff ff       	call   f0100530 <cons_putc>
		cons_putc(' ');
f010065e:	b8 20 00 00 00       	mov    $0x20,%eax
f0100663:	e8 c8 fe ff ff       	call   f0100530 <cons_putc>
		cons_putc(' ');
f0100668:	b8 20 00 00 00       	mov    $0x20,%eax
f010066d:	e8 be fe ff ff       	call   f0100530 <cons_putc>
		cons_putc(' ');
f0100672:	b8 20 00 00 00       	mov    $0x20,%eax
f0100677:	e8 b4 fe ff ff       	call   f0100530 <cons_putc>
		cons_putc(' ');
f010067c:	b8 20 00 00 00       	mov    $0x20,%eax
f0100681:	e8 aa fe ff ff       	call   f0100530 <cons_putc>
f0100686:	eb 1d                	jmp    f01006a5 <cons_putc+0x175>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f0100688:	0f b7 05 30 00 1f f0 	movzwl 0xf01f0030,%eax
f010068f:	0f b7 c8             	movzwl %ax,%ecx
f0100692:	8b 15 2c 00 1f f0    	mov    0xf01f002c,%edx
f0100698:	66 89 3c 4a          	mov    %di,(%edx,%ecx,2)
f010069c:	83 c0 01             	add    $0x1,%eax
f010069f:	66 a3 30 00 1f f0    	mov    %ax,0xf01f0030
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f01006a5:	66 81 3d 30 00 1f f0 	cmpw   $0x7cf,0xf01f0030
f01006ac:	cf 07 
f01006ae:	76 42                	jbe    f01006f2 <cons_putc+0x1c2>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f01006b0:	a1 2c 00 1f f0       	mov    0xf01f002c,%eax
f01006b5:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
f01006bc:	00 
f01006bd:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f01006c3:	89 54 24 04          	mov    %edx,0x4(%esp)
f01006c7:	89 04 24             	mov    %eax,(%esp)
f01006ca:	e8 b6 6b 00 00       	call   f0107285 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f01006cf:	8b 15 2c 00 1f f0    	mov    0xf01f002c,%edx
f01006d5:	b8 80 07 00 00       	mov    $0x780,%eax
f01006da:	66 c7 04 42 20 07    	movw   $0x720,(%edx,%eax,2)
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01006e0:	83 c0 01             	add    $0x1,%eax
f01006e3:	3d d0 07 00 00       	cmp    $0x7d0,%eax
f01006e8:	75 f0                	jne    f01006da <cons_putc+0x1aa>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f01006ea:	66 83 2d 30 00 1f f0 	subw   $0x50,0xf01f0030
f01006f1:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f01006f2:	8b 0d 28 00 1f f0    	mov    0xf01f0028,%ecx
f01006f8:	89 cb                	mov    %ecx,%ebx
f01006fa:	b8 0e 00 00 00       	mov    $0xe,%eax
f01006ff:	89 ca                	mov    %ecx,%edx
f0100701:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100702:	0f b7 35 30 00 1f f0 	movzwl 0xf01f0030,%esi
f0100709:	83 c1 01             	add    $0x1,%ecx
f010070c:	89 f0                	mov    %esi,%eax
f010070e:	66 c1 e8 08          	shr    $0x8,%ax
f0100712:	89 ca                	mov    %ecx,%edx
f0100714:	ee                   	out    %al,(%dx)
f0100715:	b8 0f 00 00 00       	mov    $0xf,%eax
f010071a:	89 da                	mov    %ebx,%edx
f010071c:	ee                   	out    %al,(%dx)
f010071d:	89 f0                	mov    %esi,%eax
f010071f:	89 ca                	mov    %ecx,%edx
f0100721:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f0100722:	83 c4 2c             	add    $0x2c,%esp
f0100725:	5b                   	pop    %ebx
f0100726:	5e                   	pop    %esi
f0100727:	5f                   	pop    %edi
f0100728:	5d                   	pop    %ebp
f0100729:	c3                   	ret    

f010072a <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f010072a:	55                   	push   %ebp
f010072b:	89 e5                	mov    %esp,%ebp
f010072d:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f0100730:	8b 45 08             	mov    0x8(%ebp),%eax
f0100733:	e8 f8 fd ff ff       	call   f0100530 <cons_putc>
}
f0100738:	c9                   	leave  
f0100739:	c3                   	ret    

f010073a <kbd_proc_data>:
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f010073a:	55                   	push   %ebp
f010073b:	89 e5                	mov    %esp,%ebp
f010073d:	53                   	push   %ebx
f010073e:	83 ec 14             	sub    $0x14,%esp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100741:	ba 64 00 00 00       	mov    $0x64,%edx
f0100746:	ec                   	in     (%dx),%al
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f0100747:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f010074c:	a8 01                	test   $0x1,%al
f010074e:	0f 84 d9 00 00 00    	je     f010082d <kbd_proc_data+0xf3>
f0100754:	b2 60                	mov    $0x60,%dl
f0100756:	ec                   	in     (%dx),%al
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f0100757:	3c e0                	cmp    $0xe0,%al
f0100759:	75 11                	jne    f010076c <kbd_proc_data+0x32>
		// E0 escape character
		shift |= E0ESC;
f010075b:	83 0d 20 00 1f f0 40 	orl    $0x40,0xf01f0020
f0100762:	bb 00 00 00 00       	mov    $0x0,%ebx
		return 0;
f0100767:	e9 c1 00 00 00       	jmp    f010082d <kbd_proc_data+0xf3>
	} else if (data & 0x80) {
f010076c:	84 c0                	test   %al,%al
f010076e:	79 32                	jns    f01007a2 <kbd_proc_data+0x68>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f0100770:	8b 15 20 00 1f f0    	mov    0xf01f0020,%edx
f0100776:	f6 c2 40             	test   $0x40,%dl
f0100779:	75 03                	jne    f010077e <kbd_proc_data+0x44>
f010077b:	83 e0 7f             	and    $0x7f,%eax
		shift &= ~(shiftcode[data] | E0ESC);
f010077e:	0f b6 c0             	movzbl %al,%eax
f0100781:	0f b6 80 40 81 10 f0 	movzbl -0xfef7ec0(%eax),%eax
f0100788:	83 c8 40             	or     $0x40,%eax
f010078b:	0f b6 c0             	movzbl %al,%eax
f010078e:	f7 d0                	not    %eax
f0100790:	21 c2                	and    %eax,%edx
f0100792:	89 15 20 00 1f f0    	mov    %edx,0xf01f0020
f0100798:	bb 00 00 00 00       	mov    $0x0,%ebx
		return 0;
f010079d:	e9 8b 00 00 00       	jmp    f010082d <kbd_proc_data+0xf3>
	} else if (shift & E0ESC) {
f01007a2:	8b 15 20 00 1f f0    	mov    0xf01f0020,%edx
f01007a8:	f6 c2 40             	test   $0x40,%dl
f01007ab:	74 0c                	je     f01007b9 <kbd_proc_data+0x7f>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f01007ad:	83 c8 80             	or     $0xffffff80,%eax
		shift &= ~E0ESC;
f01007b0:	83 e2 bf             	and    $0xffffffbf,%edx
f01007b3:	89 15 20 00 1f f0    	mov    %edx,0xf01f0020
	}

	shift |= shiftcode[data];
f01007b9:	0f b6 c0             	movzbl %al,%eax
	shift ^= togglecode[data];
f01007bc:	0f b6 90 40 81 10 f0 	movzbl -0xfef7ec0(%eax),%edx
f01007c3:	0b 15 20 00 1f f0    	or     0xf01f0020,%edx
f01007c9:	0f b6 88 40 82 10 f0 	movzbl -0xfef7dc0(%eax),%ecx
f01007d0:	31 ca                	xor    %ecx,%edx
f01007d2:	89 15 20 00 1f f0    	mov    %edx,0xf01f0020

	c = charcode[shift & (CTL | SHIFT)][data];
f01007d8:	89 d1                	mov    %edx,%ecx
f01007da:	83 e1 03             	and    $0x3,%ecx
f01007dd:	8b 0c 8d 40 83 10 f0 	mov    -0xfef7cc0(,%ecx,4),%ecx
f01007e4:	0f b6 1c 01          	movzbl (%ecx,%eax,1),%ebx
	if (shift & CAPSLOCK) {
f01007e8:	f6 c2 08             	test   $0x8,%dl
f01007eb:	74 1a                	je     f0100807 <kbd_proc_data+0xcd>
		if ('a' <= c && c <= 'z')
f01007ed:	89 d9                	mov    %ebx,%ecx
f01007ef:	8d 43 9f             	lea    -0x61(%ebx),%eax
f01007f2:	83 f8 19             	cmp    $0x19,%eax
f01007f5:	77 05                	ja     f01007fc <kbd_proc_data+0xc2>
			c += 'A' - 'a';
f01007f7:	83 eb 20             	sub    $0x20,%ebx
f01007fa:	eb 0b                	jmp    f0100807 <kbd_proc_data+0xcd>
		else if ('A' <= c && c <= 'Z')
f01007fc:	83 e9 41             	sub    $0x41,%ecx
f01007ff:	83 f9 19             	cmp    $0x19,%ecx
f0100802:	77 03                	ja     f0100807 <kbd_proc_data+0xcd>
			c += 'a' - 'A';
f0100804:	83 c3 20             	add    $0x20,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f0100807:	f7 d2                	not    %edx
f0100809:	f6 c2 06             	test   $0x6,%dl
f010080c:	75 1f                	jne    f010082d <kbd_proc_data+0xf3>
f010080e:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f0100814:	75 17                	jne    f010082d <kbd_proc_data+0xf3>
		cprintf("Rebooting!\n");
f0100816:	c7 04 24 fe 80 10 f0 	movl   $0xf01080fe,(%esp)
f010081d:	e8 9d 42 00 00       	call   f0104abf <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100822:	ba 92 00 00 00       	mov    $0x92,%edx
f0100827:	b8 03 00 00 00       	mov    $0x3,%eax
f010082c:	ee                   	out    %al,(%dx)
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f010082d:	89 d8                	mov    %ebx,%eax
f010082f:	83 c4 14             	add    $0x14,%esp
f0100832:	5b                   	pop    %ebx
f0100833:	5d                   	pop    %ebp
f0100834:	c3                   	ret    

f0100835 <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f0100835:	55                   	push   %ebp
f0100836:	89 e5                	mov    %esp,%ebp
f0100838:	57                   	push   %edi
f0100839:	56                   	push   %esi
f010083a:	53                   	push   %ebx
f010083b:	83 ec 1c             	sub    $0x1c,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f010083e:	b8 00 80 0b f0       	mov    $0xf00b8000,%eax
f0100843:	0f b7 10             	movzwl (%eax),%edx
	*cp = (uint16_t) 0xA55A;
f0100846:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
	if (*cp != 0xA55A) {
f010084b:	0f b7 00             	movzwl (%eax),%eax
f010084e:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100852:	74 11                	je     f0100865 <cons_init+0x30>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f0100854:	c7 05 28 00 1f f0 b4 	movl   $0x3b4,0xf01f0028
f010085b:	03 00 00 
f010085e:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f0100863:	eb 16                	jmp    f010087b <cons_init+0x46>
	} else {
		*cp = was;
f0100865:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f010086c:	c7 05 28 00 1f f0 d4 	movl   $0x3d4,0xf01f0028
f0100873:	03 00 00 
f0100876:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
	}
	
	/* Extract cursor location */
	outb(addr_6845, 14);
f010087b:	8b 0d 28 00 1f f0    	mov    0xf01f0028,%ecx
f0100881:	89 cb                	mov    %ecx,%ebx
f0100883:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100888:	89 ca                	mov    %ecx,%edx
f010088a:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f010088b:	83 c1 01             	add    $0x1,%ecx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010088e:	89 ca                	mov    %ecx,%edx
f0100890:	ec                   	in     (%dx),%al
f0100891:	0f b6 f8             	movzbl %al,%edi
f0100894:	c1 e7 08             	shl    $0x8,%edi
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100897:	b8 0f 00 00 00       	mov    $0xf,%eax
f010089c:	89 da                	mov    %ebx,%edx
f010089e:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010089f:	89 ca                	mov    %ecx,%edx
f01008a1:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f01008a2:	89 35 2c 00 1f f0    	mov    %esi,0xf01f002c
	crt_pos = pos;
f01008a8:	0f b6 c8             	movzbl %al,%ecx
f01008ab:	09 cf                	or     %ecx,%edi
f01008ad:	66 89 3d 30 00 1f f0 	mov    %di,0xf01f0030

static void
kbd_init(void)
{
	// Drain the kbd buffer so that Bochs generates interrupts.
	kbd_intr();
f01008b4:	e8 e9 fb ff ff       	call   f01004a2 <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<1));
f01008b9:	0f b7 05 70 43 12 f0 	movzwl 0xf0124370,%eax
f01008c0:	25 fd ff 00 00       	and    $0xfffd,%eax
f01008c5:	89 04 24             	mov    %eax,(%esp)
f01008c8:	e8 bf 40 00 00       	call   f010498c <irq_setmask_8259A>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01008cd:	bb fa 03 00 00       	mov    $0x3fa,%ebx
f01008d2:	b8 00 00 00 00       	mov    $0x0,%eax
f01008d7:	89 da                	mov    %ebx,%edx
f01008d9:	ee                   	out    %al,(%dx)
f01008da:	b2 fb                	mov    $0xfb,%dl
f01008dc:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f01008e1:	ee                   	out    %al,(%dx)
f01008e2:	b9 f8 03 00 00       	mov    $0x3f8,%ecx
f01008e7:	b8 0c 00 00 00       	mov    $0xc,%eax
f01008ec:	89 ca                	mov    %ecx,%edx
f01008ee:	ee                   	out    %al,(%dx)
f01008ef:	b2 f9                	mov    $0xf9,%dl
f01008f1:	b8 00 00 00 00       	mov    $0x0,%eax
f01008f6:	ee                   	out    %al,(%dx)
f01008f7:	b2 fb                	mov    $0xfb,%dl
f01008f9:	b8 03 00 00 00       	mov    $0x3,%eax
f01008fe:	ee                   	out    %al,(%dx)
f01008ff:	b2 fc                	mov    $0xfc,%dl
f0100901:	b8 00 00 00 00       	mov    $0x0,%eax
f0100906:	ee                   	out    %al,(%dx)
f0100907:	b2 f9                	mov    $0xf9,%dl
f0100909:	b8 01 00 00 00       	mov    $0x1,%eax
f010090e:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010090f:	b2 fd                	mov    $0xfd,%dl
f0100911:	ec                   	in     (%dx),%al
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f0100912:	3c ff                	cmp    $0xff,%al
f0100914:	0f 95 c0             	setne  %al
f0100917:	0f b6 f0             	movzbl %al,%esi
f010091a:	89 35 24 00 1f f0    	mov    %esi,0xf01f0024
f0100920:	89 da                	mov    %ebx,%edx
f0100922:	ec                   	in     (%dx),%al
f0100923:	89 ca                	mov    %ecx,%edx
f0100925:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f0100926:	85 f6                	test   %esi,%esi
f0100928:	75 0c                	jne    f0100936 <cons_init+0x101>
		cprintf("Serial port does not exist!\n");
f010092a:	c7 04 24 0a 81 10 f0 	movl   $0xf010810a,(%esp)
f0100931:	e8 89 41 00 00       	call   f0104abf <cprintf>
}
f0100936:	83 c4 1c             	add    $0x1c,%esp
f0100939:	5b                   	pop    %ebx
f010093a:	5e                   	pop    %esi
f010093b:	5f                   	pop    %edi
f010093c:	5d                   	pop    %ebp
f010093d:	c3                   	ret    
	...

f0100940 <rdtsc>:
		(end-entry+1023)/1024);
	return 0;
}


static uint64_t rdtsc() {
f0100940:	55                   	push   %ebp
f0100941:	89 e5                	mov    %esp,%ebp
    uint32_t lo,hi;
   __asm__ __volatile__
f0100943:	0f 31                	rdtsc  
   (
      "rdtsc":"=a"(lo),"=d"(hi)
   );
   return (uint64_t) hi<<32|lo;    
}
f0100945:	5d                   	pop    %ebp
f0100946:	c3                   	ret    

f0100947 <read_eip>:
// return EIP of caller.
// does not work if inlined.
// putting at the end of the file seems to prevent inlining.
unsigned
read_eip()
{
f0100947:	55                   	push   %ebp
f0100948:	89 e5                	mov    %esp,%ebp
	uint32_t callerpc;
	__asm __volatile("movl 4(%%ebp), %0" : "=r" (callerpc));
f010094a:	8b 45 04             	mov    0x4(%ebp),%eax
	return callerpc;
}
f010094d:	5d                   	pop    %ebp
f010094e:	c3                   	ret    

f010094f <start_overflow>:
    cprintf("Overflow success\n");
}

void
start_overflow(void)
{
f010094f:	55                   	push   %ebp
f0100950:	89 e5                	mov    %esp,%ebp
f0100952:	57                   	push   %edi
f0100953:	56                   	push   %esi
f0100954:	53                   	push   %ebx
f0100955:	81 ec 3c 01 00 00    	sub    $0x13c,%esp
    // you augmented in the "Exercise 9" to do this job.

    // hint: You can use the read_pretaddr function to retrieve 
    //       the pointer to the function call return address;

    char str[256] = {};
f010095b:	8d bd e8 fe ff ff    	lea    -0x118(%ebp),%edi
f0100961:	b9 40 00 00 00       	mov    $0x40,%ecx
f0100966:	b8 00 00 00 00       	mov    $0x0,%eax
f010096b:	f3 ab                	rep stos %eax,%es:(%edi)
// Lab1 only
// read the pointer to the retaddr on the stack
static uint32_t
read_pretaddr() {
    uint32_t pretaddr;
    __asm __volatile("leal 4(%%ebp), %0" : "=r" (pretaddr)); 
f010096d:	8d 45 04             	lea    0x4(%ebp),%eax
f0100970:	89 85 d4 fe ff ff    	mov    %eax,-0x12c(%ebp)
    char str[256] = {};
    int nstr = 0;
    char *pret_addr;
    int i = 0;
    pret_addr = (char*)read_pretaddr();
    uint32_t oldret = *((uint32_t*)pret_addr);
f0100976:	8b 00                	mov    (%eax),%eax
f0100978:	89 85 e4 fe ff ff    	mov    %eax,-0x11c(%ebp)
    uint32_t overflowaddr = (uint32_t)do_overflow;
f010097e:	c7 85 e0 fe ff ff 7d 	movl   $0xf0100a7d,-0x120(%ebp)
f0100985:	0a 10 f0 
f0100988:	be 00 00 00 00       	mov    $0x0,%esi
    for(i = 0;i<4;i++){
f010098d:	bf 00 00 00 00       	mov    $0x0,%edi
       unsigned int j;
       for(j = 0;j<256;j++)
           str[j] = 0;
f0100992:	8d 9d e8 fe ff ff    	lea    -0x118(%ebp),%ebx
f0100998:	89 9d d0 fe ff ff    	mov    %ebx,-0x130(%ebp)
f010099e:	eb 6c                	jmp    f0100a0c <start_overflow+0xbd>
f01009a0:	c6 04 03 00          	movb   $0x0,(%ebx,%eax,1)
    pret_addr = (char*)read_pretaddr();
    uint32_t oldret = *((uint32_t*)pret_addr);
    uint32_t overflowaddr = (uint32_t)do_overflow;
    for(i = 0;i<4;i++){
       unsigned int j;
       for(j = 0;j<256;j++)
f01009a4:	83 c0 01             	add    $0x1,%eax
f01009a7:	3d 00 01 00 00       	cmp    $0x100,%eax
f01009ac:	75 f2                	jne    f01009a0 <start_overflow+0x51>
{
    cprintf("Overflow success\n");
}

void
start_overflow(void)
f01009ae:	89 f1                	mov    %esi,%ecx
       unsigned int j;
       for(j = 0;j<256;j++)
           str[j] = 0;
       char* addr = (char*)(&overflowaddr);
       unsigned char num = (unsigned char)((*(addr + i)) &0xFF);
       for(j = 0; j<num;j++)
f01009b0:	0f b6 94 35 e0 fe ff 	movzbl -0x120(%ebp,%esi,1),%edx
f01009b7:	ff 
f01009b8:	85 d2                	test   %edx,%edx
f01009ba:	74 0d                	je     f01009c9 <start_overflow+0x7a>
f01009bc:	89 f8                	mov    %edi,%eax
           str[j] = ' ';
f01009be:	c6 04 03 20          	movb   $0x20,(%ebx,%eax,1)
       unsigned int j;
       for(j = 0;j<256;j++)
           str[j] = 0;
       char* addr = (char*)(&overflowaddr);
       unsigned char num = (unsigned char)((*(addr + i)) &0xFF);
       for(j = 0; j<num;j++)
f01009c2:	83 c0 01             	add    $0x1,%eax
f01009c5:	39 d0                	cmp    %edx,%eax
f01009c7:	72 f5                	jb     f01009be <start_overflow+0x6f>
           str[j] = ' ';
       cprintf("%s%n\n",str,pret_addr + i);
f01009c9:	03 8d d4 fe ff ff    	add    -0x12c(%ebp),%ecx
f01009cf:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01009d3:	8b 85 d0 fe ff ff    	mov    -0x130(%ebp),%eax
f01009d9:	89 44 24 04          	mov    %eax,0x4(%esp)
f01009dd:	c7 04 24 50 83 10 f0 	movl   $0xf0108350,(%esp)
f01009e4:	e8 d6 40 00 00       	call   f0104abf <cprintf>
    char *pret_addr;
    int i = 0;
    pret_addr = (char*)read_pretaddr();
    uint32_t oldret = *((uint32_t*)pret_addr);
    uint32_t overflowaddr = (uint32_t)do_overflow;
    for(i = 0;i<4;i++){
f01009e9:	83 c6 01             	add    $0x1,%esi
f01009ec:	83 fe 04             	cmp    $0x4,%esi
f01009ef:	75 1b                	jne    f0100a0c <start_overflow+0xbd>
f01009f1:	8b bd d4 fe ff ff    	mov    -0x12c(%ebp),%edi
f01009f7:	83 c7 04             	add    $0x4,%edi
f01009fa:	66 be 00 00          	mov    $0x0,%si
       cprintf("%s%n\n",str,pret_addr + i);
    }
    for(i = 0;i<4;i++){
       unsigned int j;
       for(j = 0;j<256;j++)
           str[j] = 0;
f01009fe:	8d 9d e8 fe ff ff    	lea    -0x118(%ebp),%ebx
f0100a04:	89 9d d4 fe ff ff    	mov    %ebx,-0x12c(%ebp)
f0100a0a:	eb 52                	jmp    f0100a5e <start_overflow+0x10f>
    char *pret_addr;
    int i = 0;
    pret_addr = (char*)read_pretaddr();
    uint32_t oldret = *((uint32_t*)pret_addr);
    uint32_t overflowaddr = (uint32_t)do_overflow;
    for(i = 0;i<4;i++){
f0100a0c:	89 f8                	mov    %edi,%eax
f0100a0e:	eb 90                	jmp    f01009a0 <start_overflow+0x51>
       cprintf("%s%n\n",str,pret_addr + i);
    }
    for(i = 0;i<4;i++){
       unsigned int j;
       for(j = 0;j<256;j++)
           str[j] = 0;
f0100a10:	c6 04 03 00          	movb   $0x0,(%ebx,%eax,1)
           str[j] = ' ';
       cprintf("%s%n\n",str,pret_addr + i);
    }
    for(i = 0;i<4;i++){
       unsigned int j;
       for(j = 0;j<256;j++)
f0100a14:	83 c0 01             	add    $0x1,%eax
f0100a17:	3d 00 01 00 00       	cmp    $0x100,%eax
f0100a1c:	75 f2                	jne    f0100a10 <start_overflow+0xc1>
           str[j] = 0;
       char* addr = (char*)(&oldret);
       unsigned char num = (unsigned char)((*(addr + i))&0xFF);
       for(j = 0; j<num;j++)
f0100a1e:	0f b6 94 35 e4 fe ff 	movzbl -0x11c(%ebp,%esi,1),%edx
f0100a25:	ff 
f0100a26:	85 d2                	test   %edx,%edx
f0100a28:	74 0f                	je     f0100a39 <start_overflow+0xea>
f0100a2a:	66 b8 00 00          	mov    $0x0,%ax
           str[j] = ' ';
f0100a2e:	c6 04 03 20          	movb   $0x20,(%ebx,%eax,1)
       unsigned int j;
       for(j = 0;j<256;j++)
           str[j] = 0;
       char* addr = (char*)(&oldret);
       unsigned char num = (unsigned char)((*(addr + i))&0xFF);
       for(j = 0; j<num;j++)
f0100a32:	83 c0 01             	add    $0x1,%eax
f0100a35:	39 d0                	cmp    %edx,%eax
f0100a37:	72 f5                	jb     f0100a2e <start_overflow+0xdf>
           str[j] = ' ';
       cprintf("%s%n\n",str,pret_addr + 4 + i);
f0100a39:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0100a3d:	8b 95 d4 fe ff ff    	mov    -0x12c(%ebp),%edx
f0100a43:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100a47:	c7 04 24 50 83 10 f0 	movl   $0xf0108350,(%esp)
f0100a4e:	e8 6c 40 00 00       	call   f0104abf <cprintf>
       unsigned char num = (unsigned char)((*(addr + i)) &0xFF);
       for(j = 0; j<num;j++)
           str[j] = ' ';
       cprintf("%s%n\n",str,pret_addr + i);
    }
    for(i = 0;i<4;i++){
f0100a53:	83 c6 01             	add    $0x1,%esi
f0100a56:	83 c7 01             	add    $0x1,%edi
f0100a59:	83 fe 04             	cmp    $0x4,%esi
f0100a5c:	74 07                	je     f0100a65 <start_overflow+0x116>
f0100a5e:	b8 00 00 00 00       	mov    $0x0,%eax
f0100a63:	eb ab                	jmp    f0100a10 <start_overflow+0xc1>
       cprintf("%s%n\n",str,pret_addr + 4 + i);
    }
    

	// Your code here.
}
f0100a65:	81 c4 3c 01 00 00    	add    $0x13c,%esp
f0100a6b:	5b                   	pop    %ebx
f0100a6c:	5e                   	pop    %esi
f0100a6d:	5f                   	pop    %edi
f0100a6e:	5d                   	pop    %ebp
f0100a6f:	c3                   	ret    

f0100a70 <overflow_me>:

void
overflow_me(void)
{
f0100a70:	55                   	push   %ebp
f0100a71:	89 e5                	mov    %esp,%ebp
f0100a73:	83 ec 08             	sub    $0x8,%esp
        start_overflow();
f0100a76:	e8 d4 fe ff ff       	call   f010094f <start_overflow>
}
f0100a7b:	c9                   	leave  
f0100a7c:	c3                   	ret    

f0100a7d <do_overflow>:
    
}

void
do_overflow(void)
{
f0100a7d:	55                   	push   %ebp
f0100a7e:	89 e5                	mov    %esp,%ebp
f0100a80:	83 ec 18             	sub    $0x18,%esp
    cprintf("Overflow success\n");
f0100a83:	c7 04 24 56 83 10 f0 	movl   $0xf0108356,(%esp)
f0100a8a:	e8 30 40 00 00       	call   f0104abf <cprintf>
}
f0100a8f:	c9                   	leave  
f0100a90:	c3                   	ret    

f0100a91 <mon_kerninfo>:
	return 0;
}

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f0100a91:	55                   	push   %ebp
f0100a92:	89 e5                	mov    %esp,%ebp
f0100a94:	83 ec 18             	sub    $0x18,%esp
	extern char entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f0100a97:	c7 04 24 68 83 10 f0 	movl   $0xf0108368,(%esp)
f0100a9e:	e8 1c 40 00 00       	call   f0104abf <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100aa3:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f0100aaa:	00 
f0100aab:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f0100ab2:	f0 
f0100ab3:	c7 04 24 e4 85 10 f0 	movl   $0xf01085e4,(%esp)
f0100aba:	e8 00 40 00 00       	call   f0104abf <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100abf:	c7 44 24 08 d5 7f 10 	movl   $0x107fd5,0x8(%esp)
f0100ac6:	00 
f0100ac7:	c7 44 24 04 d5 7f 10 	movl   $0xf0107fd5,0x4(%esp)
f0100ace:	f0 
f0100acf:	c7 04 24 08 86 10 f0 	movl   $0xf0108608,(%esp)
f0100ad6:	e8 e4 3f 00 00       	call   f0104abf <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100adb:	c7 44 24 08 5b f3 1e 	movl   $0x1ef35b,0x8(%esp)
f0100ae2:	00 
f0100ae3:	c7 44 24 04 5b f3 1e 	movl   $0xf01ef35b,0x4(%esp)
f0100aea:	f0 
f0100aeb:	c7 04 24 2c 86 10 f0 	movl   $0xf010862c,(%esp)
f0100af2:	e8 c8 3f 00 00       	call   f0104abf <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100af7:	c7 44 24 08 04 20 23 	movl   $0x232004,0x8(%esp)
f0100afe:	00 
f0100aff:	c7 44 24 04 04 20 23 	movl   $0xf0232004,0x4(%esp)
f0100b06:	f0 
f0100b07:	c7 04 24 50 86 10 f0 	movl   $0xf0108650,(%esp)
f0100b0e:	e8 ac 3f 00 00       	call   f0104abf <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100b13:	b8 03 24 23 f0       	mov    $0xf0232403,%eax
f0100b18:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
f0100b1d:	89 c2                	mov    %eax,%edx
f0100b1f:	c1 fa 1f             	sar    $0x1f,%edx
f0100b22:	c1 ea 16             	shr    $0x16,%edx
f0100b25:	8d 04 02             	lea    (%edx,%eax,1),%eax
f0100b28:	c1 f8 0a             	sar    $0xa,%eax
f0100b2b:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100b2f:	c7 04 24 74 86 10 f0 	movl   $0xf0108674,(%esp)
f0100b36:	e8 84 3f 00 00       	call   f0104abf <cprintf>
		(end-entry+1023)/1024);
	return 0;
}
f0100b3b:	b8 00 00 00 00       	mov    $0x0,%eax
f0100b40:	c9                   	leave  
f0100b41:	c3                   	ret    

f0100b42 <mon_help>:
} 


int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100b42:	55                   	push   %ebp
f0100b43:	89 e5                	mov    %esp,%ebp
f0100b45:	57                   	push   %edi
f0100b46:	56                   	push   %esi
f0100b47:	53                   	push   %ebx
f0100b48:	83 ec 1c             	sub    $0x1c,%esp
f0100b4b:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100b50:	be a4 87 10 f0       	mov    $0xf01087a4,%esi
f0100b55:	bf a0 87 10 f0       	mov    $0xf01087a0,%edi
f0100b5a:	8b 04 1e             	mov    (%esi,%ebx,1),%eax
f0100b5d:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100b61:	8b 04 1f             	mov    (%edi,%ebx,1),%eax
f0100b64:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100b68:	c7 04 24 81 83 10 f0 	movl   $0xf0108381,(%esp)
f0100b6f:	e8 4b 3f 00 00       	call   f0104abf <cprintf>
f0100b74:	83 c3 0c             	add    $0xc,%ebx
int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
	int i;

	for (i = 0; i < NCOMMANDS; i++)
f0100b77:	83 fb 6c             	cmp    $0x6c,%ebx
f0100b7a:	75 de                	jne    f0100b5a <mon_help+0x18>
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
	return 0;
}
f0100b7c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100b81:	83 c4 1c             	add    $0x1c,%esp
f0100b84:	5b                   	pop    %ebx
f0100b85:	5e                   	pop    %esi
f0100b86:	5f                   	pop    %edi
f0100b87:	5d                   	pop    %ebp
f0100b88:	c3                   	ret    

f0100b89 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100b89:	55                   	push   %ebp
f0100b8a:	89 e5                	mov    %esp,%ebp
f0100b8c:	57                   	push   %edi
f0100b8d:	56                   	push   %esi
f0100b8e:	53                   	push   %ebx
f0100b8f:	83 ec 5c             	sub    $0x5c,%esp
	char *buf;
        if(tf == NULL){
f0100b92:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0100b96:	75 1a                	jne    f0100bb2 <monitor+0x29>
	   cprintf("Welcome to the JOS kernel monitor!\n");
f0100b98:	c7 04 24 a0 86 10 f0 	movl   $0xf01086a0,(%esp)
f0100b9f:	e8 1b 3f 00 00       	call   f0104abf <cprintf>
	   cprintf("Type 'help' for a list of commands.\n");
f0100ba4:	c7 04 24 c4 86 10 f0 	movl   $0xf01086c4,(%esp)
f0100bab:	e8 0f 3f 00 00       	call   f0104abf <cprintf>
f0100bb0:	eb 0b                	jmp    f0100bbd <monitor+0x34>
        }

	if (tf != NULL)
		print_trapframe(tf);
f0100bb2:	8b 45 08             	mov    0x8(%ebp),%eax
f0100bb5:	89 04 24             	mov    %eax,(%esp)
f0100bb8:	e8 71 46 00 00       	call   f010522e <print_trapframe>

	while (1) {
		buf = readline("K> ");
f0100bbd:	c7 04 24 8a 83 10 f0 	movl   $0xf010838a,(%esp)
f0100bc4:	e8 a7 63 00 00       	call   f0106f70 <readline>
f0100bc9:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100bcb:	85 c0                	test   %eax,%eax
f0100bcd:	74 ee                	je     f0100bbd <monitor+0x34>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f0100bcf:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
f0100bd6:	be 00 00 00 00       	mov    $0x0,%esi
f0100bdb:	eb 06                	jmp    f0100be3 <monitor+0x5a>
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100bdd:	c6 03 00             	movb   $0x0,(%ebx)
f0100be0:	83 c3 01             	add    $0x1,%ebx
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f0100be3:	0f b6 03             	movzbl (%ebx),%eax
f0100be6:	84 c0                	test   %al,%al
f0100be8:	74 6b                	je     f0100c55 <monitor+0xcc>
f0100bea:	0f be c0             	movsbl %al,%eax
f0100bed:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100bf1:	c7 04 24 8e 83 10 f0 	movl   $0xf010838e,(%esp)
f0100bf8:	e8 ce 65 00 00       	call   f01071cb <strchr>
f0100bfd:	85 c0                	test   %eax,%eax
f0100bff:	75 dc                	jne    f0100bdd <monitor+0x54>
			*buf++ = 0;
		if (*buf == 0)
f0100c01:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100c04:	74 4f                	je     f0100c55 <monitor+0xcc>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f0100c06:	83 fe 0f             	cmp    $0xf,%esi
f0100c09:	75 16                	jne    f0100c21 <monitor+0x98>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100c0b:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f0100c12:	00 
f0100c13:	c7 04 24 93 83 10 f0 	movl   $0xf0108393,(%esp)
f0100c1a:	e8 a0 3e 00 00       	call   f0104abf <cprintf>
f0100c1f:	eb 9c                	jmp    f0100bbd <monitor+0x34>
			return 0;
		}
		argv[argc++] = buf;
f0100c21:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f0100c25:	83 c6 01             	add    $0x1,%esi
		while (*buf && !strchr(WHITESPACE, *buf))
f0100c28:	0f b6 03             	movzbl (%ebx),%eax
f0100c2b:	84 c0                	test   %al,%al
f0100c2d:	75 0d                	jne    f0100c3c <monitor+0xb3>
f0100c2f:	90                   	nop
f0100c30:	eb b1                	jmp    f0100be3 <monitor+0x5a>
			buf++;
f0100c32:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f0100c35:	0f b6 03             	movzbl (%ebx),%eax
f0100c38:	84 c0                	test   %al,%al
f0100c3a:	74 a7                	je     f0100be3 <monitor+0x5a>
f0100c3c:	0f be c0             	movsbl %al,%eax
f0100c3f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100c43:	c7 04 24 8e 83 10 f0 	movl   $0xf010838e,(%esp)
f0100c4a:	e8 7c 65 00 00       	call   f01071cb <strchr>
f0100c4f:	85 c0                	test   %eax,%eax
f0100c51:	74 df                	je     f0100c32 <monitor+0xa9>
f0100c53:	eb 8e                	jmp    f0100be3 <monitor+0x5a>
			buf++;
	}
	argv[argc] = 0;
f0100c55:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100c5c:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100c5d:	85 f6                	test   %esi,%esi
f0100c5f:	90                   	nop
f0100c60:	0f 84 57 ff ff ff    	je     f0100bbd <monitor+0x34>
f0100c66:	bb a0 87 10 f0       	mov    $0xf01087a0,%ebx
f0100c6b:	bf 00 00 00 00       	mov    $0x0,%edi
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100c70:	8b 03                	mov    (%ebx),%eax
f0100c72:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100c76:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100c79:	89 04 24             	mov    %eax,(%esp)
f0100c7c:	e8 d4 64 00 00       	call   f0107155 <strcmp>
f0100c81:	85 c0                	test   %eax,%eax
f0100c83:	75 23                	jne    f0100ca8 <monitor+0x11f>
			return commands[i].func(argc, argv, tf);
f0100c85:	6b ff 0c             	imul   $0xc,%edi,%edi
f0100c88:	8b 45 08             	mov    0x8(%ebp),%eax
f0100c8b:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100c8f:	8d 45 a8             	lea    -0x58(%ebp),%eax
f0100c92:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100c96:	89 34 24             	mov    %esi,(%esp)
f0100c99:	ff 97 a8 87 10 f0    	call   *-0xfef7858(%edi)
		print_trapframe(tf);

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100c9f:	85 c0                	test   %eax,%eax
f0100ca1:	78 28                	js     f0100ccb <monitor+0x142>
f0100ca3:	e9 15 ff ff ff       	jmp    f0100bbd <monitor+0x34>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f0100ca8:	83 c7 01             	add    $0x1,%edi
f0100cab:	83 c3 0c             	add    $0xc,%ebx
f0100cae:	83 ff 09             	cmp    $0x9,%edi
f0100cb1:	75 bd                	jne    f0100c70 <monitor+0xe7>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100cb3:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100cb6:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100cba:	c7 04 24 b0 83 10 f0 	movl   $0xf01083b0,(%esp)
f0100cc1:	e8 f9 3d 00 00       	call   f0104abf <cprintf>
f0100cc6:	e9 f2 fe ff ff       	jmp    f0100bbd <monitor+0x34>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0100ccb:	83 c4 5c             	add    $0x5c,%esp
f0100cce:	5b                   	pop    %ebx
f0100ccf:	5e                   	pop    %esi
f0100cd0:	5f                   	pop    %edi
f0100cd1:	5d                   	pop    %ebp
f0100cd2:	c3                   	ret    

f0100cd3 <mon_time>:
   return (uint64_t) hi<<32|lo;    
}

int 
mon_time(int argc, char**argv,struct Trapframe *tf)
{
f0100cd3:	55                   	push   %ebp
f0100cd4:	89 e5                	mov    %esp,%ebp
f0100cd6:	57                   	push   %edi
f0100cd7:	56                   	push   %esi
f0100cd8:	53                   	push   %ebx
f0100cd9:	83 ec 3c             	sub    $0x3c,%esp
f0100cdc:	be a0 87 10 f0       	mov    $0xf01087a0,%esi
f0100ce1:	bf 00 00 00 00       	mov    $0x0,%edi
   int ret;
   int flag = 0;
   uint64_t begin;
   uint64_t end;
   for(i = 0;i<NCOMMANDS;i++){
       if(strcmp(argv[1],commands[i].name) == 0){
f0100ce6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0100ce9:	83 c3 04             	add    $0x4,%ebx
f0100cec:	8b 06                	mov    (%esi),%eax
f0100cee:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0100cf1:	89 5d e0             	mov    %ebx,-0x20(%ebp)
f0100cf4:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100cf8:	8b 03                	mov    (%ebx),%eax
f0100cfa:	89 04 24             	mov    %eax,(%esp)
f0100cfd:	e8 53 64 00 00       	call   f0107155 <strcmp>
f0100d02:	85 c0                	test   %eax,%eax
f0100d04:	75 51                	jne    f0100d57 <mon_time+0x84>
          begin = rdtsc();
f0100d06:	e8 35 fc ff ff       	call   f0100940 <rdtsc>
f0100d0b:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100d0e:	89 55 d4             	mov    %edx,-0x2c(%ebp)
          ret = (commands[i].func)(argc-1,&argv[1],tf);
f0100d11:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f0100d14:	8b 55 10             	mov    0x10(%ebp),%edx
f0100d17:	89 54 24 08          	mov    %edx,0x8(%esp)
f0100d1b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100d1f:	8b 55 08             	mov    0x8(%ebp),%edx
f0100d22:	83 ea 01             	sub    $0x1,%edx
f0100d25:	89 14 24             	mov    %edx,(%esp)
f0100d28:	ff 14 85 a8 87 10 f0 	call   *-0xfef7858(,%eax,4)
          end = rdtsc();
f0100d2f:	e8 0c fc ff ff       	call   f0100940 <rdtsc>
          cprintf("%s cycles: %d\n",commands[i].name,end-begin);
f0100d34:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0100d37:	1b 55 d4             	sbb    -0x2c(%ebp),%edx
f0100d3a:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100d3e:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0100d42:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0100d45:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100d49:	c7 04 24 c6 83 10 f0 	movl   $0xf01083c6,(%esp)
f0100d50:	e8 6a 3d 00 00       	call   f0104abf <cprintf>
f0100d55:	eb 0d                	jmp    f0100d64 <mon_time+0x91>
   int i;
   int ret;
   int flag = 0;
   uint64_t begin;
   uint64_t end;
   for(i = 0;i<NCOMMANDS;i++){
f0100d57:	83 c7 01             	add    $0x1,%edi
f0100d5a:	83 c6 0c             	add    $0xc,%esi
f0100d5d:	83 ff 09             	cmp    $0x9,%edi
f0100d60:	75 8a                	jne    f0100cec <mon_time+0x19>
f0100d62:	eb 0d                	jmp    f0100d71 <mon_time+0x9e>
       }
   }
   if(flag == 0)
     cprintf("no such command %s\n",argv[1]);
   return 0;
}
f0100d64:	b8 00 00 00 00       	mov    $0x0,%eax
f0100d69:	83 c4 3c             	add    $0x3c,%esp
f0100d6c:	5b                   	pop    %ebx
f0100d6d:	5e                   	pop    %esi
f0100d6e:	5f                   	pop    %edi
f0100d6f:	5d                   	pop    %ebp
f0100d70:	c3                   	ret    
          flag = 1;
          break;
       }
   }
   if(flag == 0)
     cprintf("no such command %s\n",argv[1]);
f0100d71:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0100d74:	8b 01                	mov    (%ecx),%eax
f0100d76:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100d7a:	c7 04 24 d5 83 10 f0 	movl   $0xf01083d5,(%esp)
f0100d81:	e8 39 3d 00 00       	call   f0104abf <cprintf>
f0100d86:	eb dc                	jmp    f0100d64 <mon_time+0x91>

f0100d88 <mon_backtrace>:
        start_overflow();
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f0100d88:	55                   	push   %ebp
f0100d89:	89 e5                	mov    %esp,%ebp
f0100d8b:	57                   	push   %edi
f0100d8c:	56                   	push   %esi
f0100d8d:	53                   	push   %ebx
f0100d8e:	83 ec 4c             	sub    $0x4c,%esp
	// Your code here.
    overflow_me();
f0100d91:	e8 da fc ff ff       	call   f0100a70 <overflow_me>
    cprintf("Stack backtrace:\n");
f0100d96:	c7 04 24 e9 83 10 f0 	movl   $0xf01083e9,(%esp)
f0100d9d:	e8 1d 3d 00 00       	call   f0104abf <cprintf>
    uint32_t* ebp = (uint32_t*)read_ebp();
f0100da2:	89 ee                	mov    %ebp,%esi
    struct Eipdebuginfo info;
    while(ebp != 0){
f0100da4:	85 f6                	test   %esi,%esi
f0100da6:	0f 84 97 00 00 00    	je     f0100e43 <mon_backtrace+0xbb>
    int i = 0;
    cprintf("eip %08x  ebp %08x  ",ebp[1],ebp);
f0100dac:	8d 7e 04             	lea    0x4(%esi),%edi
f0100daf:	89 74 24 08          	mov    %esi,0x8(%esp)
f0100db3:	8b 07                	mov    (%edi),%eax
f0100db5:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100db9:	c7 04 24 fb 83 10 f0 	movl   $0xf01083fb,(%esp)
f0100dc0:	e8 fa 3c 00 00       	call   f0104abf <cprintf>
    debuginfo_eip(ebp[1],&info);
f0100dc5:	8d 45 d0             	lea    -0x30(%ebp),%eax
f0100dc8:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100dcc:	8b 07                	mov    (%edi),%eax
f0100dce:	89 04 24             	mov    %eax,(%esp)
f0100dd1:	e8 08 57 00 00       	call   f01064de <debuginfo_eip>
    cprintf("args ");
f0100dd6:	c7 04 24 10 84 10 f0 	movl   $0xf0108410,(%esp)
f0100ddd:	e8 dd 3c 00 00       	call   f0104abf <cprintf>
f0100de2:	bb 00 00 00 00       	mov    $0x0,%ebx
    for(i = 0; i< 5;i++){
       cprintf("%08x ",ebp[i+2]);
f0100de7:	8b 44 9e 08          	mov    0x8(%esi,%ebx,4),%eax
f0100deb:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100def:	c7 04 24 01 85 10 f0 	movl   $0xf0108501,(%esp)
f0100df6:	e8 c4 3c 00 00       	call   f0104abf <cprintf>
    while(ebp != 0){
    int i = 0;
    cprintf("eip %08x  ebp %08x  ",ebp[1],ebp);
    debuginfo_eip(ebp[1],&info);
    cprintf("args ");
    for(i = 0; i< 5;i++){
f0100dfb:	83 c3 01             	add    $0x1,%ebx
f0100dfe:	83 fb 05             	cmp    $0x5,%ebx
f0100e01:	75 e4                	jne    f0100de7 <mon_backtrace+0x5f>
       cprintf("%08x ",ebp[i+2]);
    }
    cprintf("\n");
f0100e03:	c7 04 24 d9 84 10 f0 	movl   $0xf01084d9,(%esp)
f0100e0a:	e8 b0 3c 00 00       	call   f0104abf <cprintf>
    cprintf("\t%s:%d: %s+%d\n",info.eip_file,info.eip_line,info.eip_fn_name,ebp[1]-info.eip_fn_addr);
f0100e0f:	8b 07                	mov    (%edi),%eax
f0100e11:	2b 45 e0             	sub    -0x20(%ebp),%eax
f0100e14:	89 44 24 10          	mov    %eax,0x10(%esp)
f0100e18:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100e1b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100e1f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100e22:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100e26:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0100e29:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100e2d:	c7 04 24 16 84 10 f0 	movl   $0xf0108416,(%esp)
f0100e34:	e8 86 3c 00 00       	call   f0104abf <cprintf>
    ebp = (uint32_t*)(*(ebp));
f0100e39:	8b 36                	mov    (%esi),%esi
	// Your code here.
    overflow_me();
    cprintf("Stack backtrace:\n");
    uint32_t* ebp = (uint32_t*)read_ebp();
    struct Eipdebuginfo info;
    while(ebp != 0){
f0100e3b:	85 f6                	test   %esi,%esi
f0100e3d:	0f 85 69 ff ff ff    	jne    f0100dac <mon_backtrace+0x24>
    }
    cprintf("\n");
    cprintf("\t%s:%d: %s+%d\n",info.eip_file,info.eip_line,info.eip_fn_name,ebp[1]-info.eip_fn_addr);
    ebp = (uint32_t*)(*(ebp));
    }
    cprintf("Backtrace success\n");
f0100e43:	c7 04 24 25 84 10 f0 	movl   $0xf0108425,(%esp)
f0100e4a:	e8 70 3c 00 00       	call   f0104abf <cprintf>
    return 0;
}
f0100e4f:	b8 00 00 00 00       	mov    $0x0,%eax
f0100e54:	83 c4 4c             	add    $0x4c,%esp
f0100e57:	5b                   	pop    %ebx
f0100e58:	5e                   	pop    %esi
f0100e59:	5f                   	pop    %edi
f0100e5a:	5d                   	pop    %ebp
f0100e5b:	c3                   	ret    

f0100e5c <mon_x>:
unsigned read_eip();

/***** Implementations of basic kernel monitor commands *****/

int 
mon_x(int argc,char **argv,struct Trapframe *tf){
f0100e5c:	55                   	push   %ebp
f0100e5d:	89 e5                	mov    %esp,%ebp
f0100e5f:	83 ec 18             	sub    $0x18,%esp
   if(argc != 2)
f0100e62:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
f0100e66:	74 0e                	je     f0100e76 <mon_x+0x1a>
     cprintf("Usage: x [addr]\n");   
f0100e68:	c7 04 24 38 84 10 f0 	movl   $0xf0108438,(%esp)
f0100e6f:	e8 4b 3c 00 00       	call   f0104abf <cprintf>
f0100e74:	eb 44                	jmp    f0100eba <mon_x+0x5e>
   else if(tf == NULL)
f0100e76:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0100e7a:	75 0e                	jne    f0100e8a <mon_x+0x2e>
     cprintf("trapframe error\n");
f0100e7c:	c7 04 24 49 84 10 f0 	movl   $0xf0108449,(%esp)
f0100e83:	e8 37 3c 00 00       	call   f0104abf <cprintf>
f0100e88:	eb 30                	jmp    f0100eba <mon_x+0x5e>
   else{
       uint32_t addr = strtol(argv[1],0,0);
f0100e8a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0100e91:	00 
f0100e92:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100e99:	00 
f0100e9a:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100e9d:	8b 40 04             	mov    0x4(%eax),%eax
f0100ea0:	89 04 24             	mov    %eax,(%esp)
f0100ea3:	e8 f3 64 00 00       	call   f010739b <strtol>
       uint32_t value = 0; 
       value = *((uint32_t*)addr);
       cprintf("%d\n",value);
f0100ea8:	8b 00                	mov    (%eax),%eax
f0100eaa:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100eae:	c7 04 24 d1 83 10 f0 	movl   $0xf01083d1,(%esp)
f0100eb5:	e8 05 3c 00 00       	call   f0104abf <cprintf>
    }
    return 0;
}
f0100eba:	b8 00 00 00 00       	mov    $0x0,%eax
f0100ebf:	c9                   	leave  
f0100ec0:	c3                   	ret    

f0100ec1 <mon_changeperm>:
   return 0;
}

int 
mon_changeperm(int argc,char**argv,struct Trapframe *tf)
{
f0100ec1:	55                   	push   %ebp
f0100ec2:	89 e5                	mov    %esp,%ebp
f0100ec4:	83 ec 38             	sub    $0x38,%esp
f0100ec7:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0100eca:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0100ecd:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0100ed0:	8b 75 08             	mov    0x8(%ebp),%esi
f0100ed3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
    if(argc != 3 && argc != 4){
f0100ed6:	8d 46 fd             	lea    -0x3(%esi),%eax
f0100ed9:	83 f8 01             	cmp    $0x1,%eax
f0100edc:	76 11                	jbe    f0100eef <mon_changeperm+0x2e>
      cprintf("Usage: changeperm [op] [addr] ([perm])\n");
f0100ede:	c7 04 24 ec 86 10 f0 	movl   $0xf01086ec,(%esp)
f0100ee5:	e8 d5 3b 00 00       	call   f0104abf <cprintf>
      return 0;
f0100eea:	e9 23 01 00 00       	jmp    f0101012 <mon_changeperm+0x151>
    }
    char* op = argv[1];
f0100eef:	8b 43 04             	mov    0x4(%ebx),%eax
f0100ef2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    uintptr_t addr = strtol(argv[2],0,0);
f0100ef5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0100efc:	00 
f0100efd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100f04:	00 
f0100f05:	8b 43 08             	mov    0x8(%ebx),%eax
f0100f08:	89 04 24             	mov    %eax,(%esp)
f0100f0b:	e8 8b 64 00 00       	call   f010739b <strtol>
    pte_t* pte = pgdir_walk(kern_pgdir,(void*)addr,1);
f0100f10:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0100f17:	00 
f0100f18:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100f1c:	a1 ac 0e 1f f0       	mov    0xf01f0eac,%eax
f0100f21:	89 04 24             	mov    %eax,(%esp)
f0100f24:	e8 fc 11 00 00       	call   f0102125 <pgdir_walk>
f0100f29:	89 c7                	mov    %eax,%edi
    if(pte == NULL){
f0100f2b:	85 c0                	test   %eax,%eax
f0100f2d:	75 11                	jne    f0100f40 <mon_changeperm+0x7f>
       cprintf("pte error\n");
f0100f2f:	c7 04 24 5a 84 10 f0 	movl   $0xf010845a,(%esp)
f0100f36:	e8 84 3b 00 00       	call   f0104abf <cprintf>
       return 0;
f0100f3b:	e9 d2 00 00 00       	jmp    f0101012 <mon_changeperm+0x151>
    }
    if(strcmp(op,"set") == 0 || strcmp(op,"change") == 0){
f0100f40:	c7 44 24 04 65 84 10 	movl   $0xf0108465,0x4(%esp)
f0100f47:	f0 
f0100f48:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100f4b:	89 04 24             	mov    %eax,(%esp)
f0100f4e:	e8 02 62 00 00       	call   f0107155 <strcmp>
f0100f53:	85 c0                	test   %eax,%eax
f0100f55:	74 17                	je     f0100f6e <mon_changeperm+0xad>
f0100f57:	c7 44 24 04 69 84 10 	movl   $0xf0108469,0x4(%esp)
f0100f5e:	f0 
f0100f5f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100f62:	89 04 24             	mov    %eax,(%esp)
f0100f65:	e8 eb 61 00 00       	call   f0107155 <strcmp>
f0100f6a:	85 c0                	test   %eax,%eax
f0100f6c:	75 58                	jne    f0100fc6 <mon_changeperm+0x105>
       if(argc != 4){
f0100f6e:	83 fe 04             	cmp    $0x4,%esi
f0100f71:	74 11                	je     f0100f84 <mon_changeperm+0xc3>
         cprintf("Usage: changeperm [op] [addr] ([perm])\n");
f0100f73:	c7 04 24 ec 86 10 f0 	movl   $0xf01086ec,(%esp)
f0100f7a:	e8 40 3b 00 00       	call   f0104abf <cprintf>
         return 0;
f0100f7f:	e9 8e 00 00 00       	jmp    f0101012 <mon_changeperm+0x151>
       }
       uintptr_t perm = strtol(argv[3],0,0);
f0100f84:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0100f8b:	00 
f0100f8c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100f93:	00 
f0100f94:	8b 43 0c             	mov    0xc(%ebx),%eax
f0100f97:	89 04 24             	mov    %eax,(%esp)
f0100f9a:	e8 fc 63 00 00       	call   f010739b <strtol>
       if((perm & 0x00000FFF) != perm){
f0100f9f:	89 c2                	mov    %eax,%edx
f0100fa1:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
f0100fa7:	39 c2                	cmp    %eax,%edx
f0100fa9:	74 0e                	je     f0100fb9 <mon_changeperm+0xf8>
          cprintf("wrong perm\n");
f0100fab:	c7 04 24 70 84 10 f0 	movl   $0xf0108470,(%esp)
f0100fb2:	e8 08 3b 00 00       	call   f0104abf <cprintf>
          return 0;
f0100fb7:	eb 59                	jmp    f0101012 <mon_changeperm+0x151>
       }
       *pte = ((*pte)& 0xFFFFF000) | perm;
f0100fb9:	8b 07                	mov    (%edi),%eax
f0100fbb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100fc0:	09 c2                	or     %eax,%edx
f0100fc2:	89 17                	mov    %edx,(%edi)
    pte_t* pte = pgdir_walk(kern_pgdir,(void*)addr,1);
    if(pte == NULL){
       cprintf("pte error\n");
       return 0;
    }
    if(strcmp(op,"set") == 0 || strcmp(op,"change") == 0){
f0100fc4:	eb 40                	jmp    f0101006 <mon_changeperm+0x145>
          cprintf("wrong perm\n");
          return 0;
       }
       *pte = ((*pte)& 0xFFFFF000) | perm;
    }
    else if(strcmp(op,"clear") == 0){
f0100fc6:	c7 44 24 04 7c 84 10 	movl   $0xf010847c,0x4(%esp)
f0100fcd:	f0 
f0100fce:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100fd1:	89 04 24             	mov    %eax,(%esp)
f0100fd4:	e8 7c 61 00 00       	call   f0107155 <strcmp>
f0100fd9:	85 c0                	test   %eax,%eax
f0100fdb:	75 1b                	jne    f0100ff8 <mon_changeperm+0x137>
       if(argc != 3){
f0100fdd:	83 fe 03             	cmp    $0x3,%esi
f0100fe0:	74 0e                	je     f0100ff0 <mon_changeperm+0x12f>
         cprintf("Usage: changeperm [op] [addr] ([perm])\n");
f0100fe2:	c7 04 24 ec 86 10 f0 	movl   $0xf01086ec,(%esp)
f0100fe9:	e8 d1 3a 00 00       	call   f0104abf <cprintf>
         return 0;
f0100fee:	eb 22                	jmp    f0101012 <mon_changeperm+0x151>
       }
       *pte = ((*pte)& 0xFFFFF000);
f0100ff0:	81 27 00 f0 ff ff    	andl   $0xfffff000,(%edi)
f0100ff6:	eb 0e                	jmp    f0101006 <mon_changeperm+0x145>
    }
    else{
      cprintf("Usage: changeperm [op] [addr] ([perm])\n");
f0100ff8:	c7 04 24 ec 86 10 f0 	movl   $0xf01086ec,(%esp)
f0100fff:	e8 bb 3a 00 00       	call   f0104abf <cprintf>
      return 0;
f0101004:	eb 0c                	jmp    f0101012 <mon_changeperm+0x151>
    }
    cprintf("success\n");
f0101006:	c7 04 24 2f 84 10 f0 	movl   $0xf010842f,(%esp)
f010100d:	e8 ad 3a 00 00       	call   f0104abf <cprintf>
    return 0;
}
f0101012:	b8 00 00 00 00       	mov    $0x0,%eax
f0101017:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f010101a:	8b 75 f8             	mov    -0x8(%ebp),%esi
f010101d:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0101020:	89 ec                	mov    %ebp,%esp
f0101022:	5d                   	pop    %ebp
f0101023:	c3                   	ret    

f0101024 <mon_showmappings>:
   return 0;
}

int 
mon_showmappings(int argc,char**argv,struct Trapframe *tf)
{
f0101024:	55                   	push   %ebp
f0101025:	89 e5                	mov    %esp,%ebp
f0101027:	57                   	push   %edi
f0101028:	56                   	push   %esi
f0101029:	53                   	push   %ebx
f010102a:	83 ec 1c             	sub    $0x1c,%esp
f010102d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
   if(argc != 3)
f0101030:	83 7d 08 03          	cmpl   $0x3,0x8(%ebp)
f0101034:	0f 85 2c 02 00 00    	jne    f0101266 <mon_showmappings+0x242>
      return 0;
   uintptr_t begin = strtol(argv[1],0,0);
f010103a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101041:	00 
f0101042:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101049:	00 
f010104a:	8b 43 04             	mov    0x4(%ebx),%eax
f010104d:	89 04 24             	mov    %eax,(%esp)
f0101050:	e8 46 63 00 00       	call   f010739b <strtol>
f0101055:	89 c6                	mov    %eax,%esi
   uintptr_t end = strtol(argv[2],0,0);
f0101057:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010105e:	00 
f010105f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101066:	00 
f0101067:	8b 43 08             	mov    0x8(%ebx),%eax
f010106a:	89 04 24             	mov    %eax,(%esp)
f010106d:	e8 29 63 00 00       	call   f010739b <strtol>
f0101072:	89 c7                	mov    %eax,%edi
   if(begin > end || begin != ROUNDUP(begin,PGSIZE)){
f0101074:	39 c6                	cmp    %eax,%esi
f0101076:	77 18                	ja     f0101090 <mon_showmappings+0x6c>
f0101078:	8d 86 ff 0f 00 00    	lea    0xfff(%esi),%eax
f010107e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0101083:	39 c6                	cmp    %eax,%esi
f0101085:	75 09                	jne    f0101090 <mon_showmappings+0x6c>
      cprintf("wrong virtual address\n");
      return 0;
   }
   while(begin < end){
f0101087:	39 fe                	cmp    %edi,%esi
f0101089:	72 16                	jb     f01010a1 <mon_showmappings+0x7d>
f010108b:	e9 d6 01 00 00       	jmp    f0101266 <mon_showmappings+0x242>
   if(argc != 3)
      return 0;
   uintptr_t begin = strtol(argv[1],0,0);
   uintptr_t end = strtol(argv[2],0,0);
   if(begin > end || begin != ROUNDUP(begin,PGSIZE)){
      cprintf("wrong virtual address\n");
f0101090:	c7 04 24 82 84 10 f0 	movl   $0xf0108482,(%esp)
f0101097:	e8 23 3a 00 00       	call   f0104abf <cprintf>
      return 0;
f010109c:	e9 c5 01 00 00       	jmp    f0101266 <mon_showmappings+0x242>
   }
   while(begin < end){
      pte_t* pte = pgdir_walk(kern_pgdir,(void*)begin,0);
f01010a1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01010a8:	00 
f01010a9:	89 74 24 04          	mov    %esi,0x4(%esp)
f01010ad:	a1 ac 0e 1f f0       	mov    0xf01f0eac,%eax
f01010b2:	89 04 24             	mov    %eax,(%esp)
f01010b5:	e8 6b 10 00 00       	call   f0102125 <pgdir_walk>
f01010ba:	89 c3                	mov    %eax,%ebx
      if(pte && ((*pte) & PTE_P)&&((*pte) & PTE_PS)){
f01010bc:	85 c0                	test   %eax,%eax
f01010be:	0f 84 88 01 00 00    	je     f010124c <mon_showmappings+0x228>
f01010c4:	8b 00                	mov    (%eax),%eax
f01010c6:	89 c2                	mov    %eax,%edx
f01010c8:	81 e2 81 00 00 00    	and    $0x81,%edx
f01010ce:	81 fa 81 00 00 00    	cmp    $0x81,%edx
f01010d4:	0f 85 b5 00 00 00    	jne    f010118f <mon_showmappings+0x16b>
          cprintf("0x%08x - 0x%08x   ",begin,begin+PTSIZE-1);
f01010da:	8d 86 ff ff 3f 00    	lea    0x3fffff(%esi),%eax
f01010e0:	89 44 24 08          	mov    %eax,0x8(%esp)
f01010e4:	89 74 24 04          	mov    %esi,0x4(%esp)
f01010e8:	c7 04 24 99 84 10 f0 	movl   $0xf0108499,(%esp)
f01010ef:	e8 cb 39 00 00       	call   f0104abf <cprintf>
          cprintf("0x%08x - 0x%08x   ",PTE_ADDR(*pte),PTE_ADDR(*pte)+PTSIZE-1);
f01010f4:	8b 03                	mov    (%ebx),%eax
f01010f6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01010fb:	8d 90 ff ff 3f 00    	lea    0x3fffff(%eax),%edx
f0101101:	89 54 24 08          	mov    %edx,0x8(%esp)
f0101105:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101109:	c7 04 24 99 84 10 f0 	movl   $0xf0108499,(%esp)
f0101110:	e8 aa 39 00 00       	call   f0104abf <cprintf>
          cprintf("kernel:");
f0101115:	c7 04 24 ac 84 10 f0 	movl   $0xf01084ac,(%esp)
f010111c:	e8 9e 39 00 00       	call   f0104abf <cprintf>
          if((*pte)& PTE_W)
f0101121:	f6 03 02             	testb  $0x2,(%ebx)
f0101124:	74 0e                	je     f0101134 <mon_showmappings+0x110>
            cprintf("R/W  ");
f0101126:	c7 04 24 b4 84 10 f0 	movl   $0xf01084b4,(%esp)
f010112d:	e8 8d 39 00 00       	call   f0104abf <cprintf>
f0101132:	eb 0c                	jmp    f0101140 <mon_showmappings+0x11c>
          else
            cprintf("R/-  ");
f0101134:	c7 04 24 ba 84 10 f0 	movl   $0xf01084ba,(%esp)
f010113b:	e8 7f 39 00 00       	call   f0104abf <cprintf>
          cprintf("user:");
f0101140:	c7 04 24 c0 84 10 f0 	movl   $0xf01084c0,(%esp)
f0101147:	e8 73 39 00 00       	call   f0104abf <cprintf>
          if((*pte)& PTE_U){
f010114c:	8b 03                	mov    (%ebx),%eax
f010114e:	a8 04                	test   $0x4,%al
f0101150:	74 20                	je     f0101172 <mon_showmappings+0x14e>
              if((*pte)& PTE_W)
f0101152:	a8 02                	test   $0x2,%al
f0101154:	74 0e                	je     f0101164 <mon_showmappings+0x140>
                cprintf("R/W  \n");
f0101156:	c7 04 24 c6 84 10 f0 	movl   $0xf01084c6,(%esp)
f010115d:	e8 5d 39 00 00       	call   f0104abf <cprintf>
f0101162:	eb 1a                	jmp    f010117e <mon_showmappings+0x15a>
              else
                cprintf("R/-  \n");
f0101164:	c7 04 24 cd 84 10 f0 	movl   $0xf01084cd,(%esp)
f010116b:	e8 4f 39 00 00       	call   f0104abf <cprintf>
f0101170:	eb 0c                	jmp    f010117e <mon_showmappings+0x15a>
          }
          else
            cprintf("-/-  \n");
f0101172:	c7 04 24 d4 84 10 f0 	movl   $0xf01084d4,(%esp)
f0101179:	e8 41 39 00 00       	call   f0104abf <cprintf>
          if(begin + PTSIZE < begin)
f010117e:	81 c6 00 00 40 00    	add    $0x400000,%esi
f0101184:	0f 83 d0 00 00 00    	jae    f010125a <mon_showmappings+0x236>
f010118a:	e9 d7 00 00 00       	jmp    f0101266 <mon_showmappings+0x242>
            break;
          begin += PTSIZE;
      }
      else if(pte && ((*pte) & PTE_P)){
f010118f:	a8 01                	test   $0x1,%al
f0101191:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101198:	0f 84 ae 00 00 00    	je     f010124c <mon_showmappings+0x228>
          cprintf("0x%08x - 0x%08x   ",begin,begin+PGSIZE-1);
f010119e:	8d 86 ff 0f 00 00    	lea    0xfff(%esi),%eax
f01011a4:	89 44 24 08          	mov    %eax,0x8(%esp)
f01011a8:	89 74 24 04          	mov    %esi,0x4(%esp)
f01011ac:	c7 04 24 99 84 10 f0 	movl   $0xf0108499,(%esp)
f01011b3:	e8 07 39 00 00       	call   f0104abf <cprintf>
          cprintf("0x%08x - 0x%08x   ",PTE_ADDR(*pte),PTE_ADDR(*pte)+PGSIZE-1);
f01011b8:	8b 03                	mov    (%ebx),%eax
f01011ba:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01011bf:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f01011c5:	89 54 24 08          	mov    %edx,0x8(%esp)
f01011c9:	89 44 24 04          	mov    %eax,0x4(%esp)
f01011cd:	c7 04 24 99 84 10 f0 	movl   $0xf0108499,(%esp)
f01011d4:	e8 e6 38 00 00       	call   f0104abf <cprintf>
          cprintf("kernel:");
f01011d9:	c7 04 24 ac 84 10 f0 	movl   $0xf01084ac,(%esp)
f01011e0:	e8 da 38 00 00       	call   f0104abf <cprintf>
          if((*pte)& PTE_W)
f01011e5:	f6 03 02             	testb  $0x2,(%ebx)
f01011e8:	74 0e                	je     f01011f8 <mon_showmappings+0x1d4>
            cprintf("R/W  ");
f01011ea:	c7 04 24 b4 84 10 f0 	movl   $0xf01084b4,(%esp)
f01011f1:	e8 c9 38 00 00       	call   f0104abf <cprintf>
f01011f6:	eb 0c                	jmp    f0101204 <mon_showmappings+0x1e0>
          else
            cprintf("R/-  ");
f01011f8:	c7 04 24 ba 84 10 f0 	movl   $0xf01084ba,(%esp)
f01011ff:	e8 bb 38 00 00       	call   f0104abf <cprintf>
          cprintf("user:");
f0101204:	c7 04 24 c0 84 10 f0 	movl   $0xf01084c0,(%esp)
f010120b:	e8 af 38 00 00       	call   f0104abf <cprintf>
          if((*pte)& PTE_U){
f0101210:	8b 03                	mov    (%ebx),%eax
f0101212:	a8 04                	test   $0x4,%al
f0101214:	74 20                	je     f0101236 <mon_showmappings+0x212>
              if((*pte)& PTE_W)
f0101216:	a8 02                	test   $0x2,%al
f0101218:	74 0e                	je     f0101228 <mon_showmappings+0x204>
                cprintf("R/W  \n");
f010121a:	c7 04 24 c6 84 10 f0 	movl   $0xf01084c6,(%esp)
f0101221:	e8 99 38 00 00       	call   f0104abf <cprintf>
f0101226:	eb 1a                	jmp    f0101242 <mon_showmappings+0x21e>
              else
                cprintf("R/-  \n");
f0101228:	c7 04 24 cd 84 10 f0 	movl   $0xf01084cd,(%esp)
f010122f:	e8 8b 38 00 00       	call   f0104abf <cprintf>
f0101234:	eb 0c                	jmp    f0101242 <mon_showmappings+0x21e>
          }
          else
            cprintf("-/-  \n");
f0101236:	c7 04 24 d4 84 10 f0 	movl   $0xf01084d4,(%esp)
f010123d:	e8 7d 38 00 00       	call   f0104abf <cprintf>
          if(begin + PGSIZE < begin)
f0101242:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0101248:	73 10                	jae    f010125a <mon_showmappings+0x236>
f010124a:	eb 1a                	jmp    f0101266 <mon_showmappings+0x242>
             break;
          begin += PGSIZE;
      }
      else{
          if(begin + PGSIZE < begin)
f010124c:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0101252:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0101258:	72 0c                	jb     f0101266 <mon_showmappings+0x242>
   uintptr_t end = strtol(argv[2],0,0);
   if(begin > end || begin != ROUNDUP(begin,PGSIZE)){
      cprintf("wrong virtual address\n");
      return 0;
   }
   while(begin < end){
f010125a:	39 f7                	cmp    %esi,%edi
f010125c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101260:	0f 87 3b fe ff ff    	ja     f01010a1 <mon_showmappings+0x7d>
            break;
          begin += PGSIZE;
      }
   }
   return 0;
}
f0101266:	b8 00 00 00 00       	mov    $0x0,%eax
f010126b:	83 c4 1c             	add    $0x1c,%esp
f010126e:	5b                   	pop    %ebx
f010126f:	5e                   	pop    %esi
f0101270:	5f                   	pop    %edi
f0101271:	5d                   	pop    %ebp
f0101272:	c3                   	ret    

f0101273 <mon_dump>:
    return 0;
}

int 
mon_dump(int argc,char** argv,struct Trapframe* tf)
{
f0101273:	55                   	push   %ebp
f0101274:	89 e5                	mov    %esp,%ebp
f0101276:	57                   	push   %edi
f0101277:	56                   	push   %esi
f0101278:	53                   	push   %ebx
f0101279:	83 ec 2c             	sub    $0x2c,%esp
f010127c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
   if(argc != 4){
f010127f:	83 7d 08 04          	cmpl   $0x4,0x8(%ebp)
f0101283:	74 11                	je     f0101296 <mon_dump+0x23>
      cprintf("Usage: dump [op] [addr] [size]\n");
f0101285:	c7 04 24 14 87 10 f0 	movl   $0xf0108714,(%esp)
f010128c:	e8 2e 38 00 00       	call   f0104abf <cprintf>
      return 0;
f0101291:	e9 75 02 00 00       	jmp    f010150b <mon_dump+0x298>
   }
   char* op = argv[1];
f0101296:	8b 73 04             	mov    0x4(%ebx),%esi
   uint32_t size = strtol(argv[3],0,0);
f0101299:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01012a0:	00 
f01012a1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01012a8:	00 
f01012a9:	8b 43 0c             	mov    0xc(%ebx),%eax
f01012ac:	89 04 24             	mov    %eax,(%esp)
f01012af:	e8 e7 60 00 00       	call   f010739b <strtol>
f01012b4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
   uint32_t value = 0;
   if(strcmp(op,"v") == 0){
f01012b7:	c7 44 24 04 a0 94 10 	movl   $0xf01094a0,0x4(%esp)
f01012be:	f0 
f01012bf:	89 34 24             	mov    %esi,(%esp)
f01012c2:	e8 8e 5e 00 00       	call   f0107155 <strcmp>
f01012c7:	85 c0                	test   %eax,%eax
f01012c9:	0f 85 e6 00 00 00    	jne    f01013b5 <mon_dump+0x142>
      uintptr_t addr = strtol(argv[2],0,0); 
f01012cf:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01012d6:	00 
f01012d7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01012de:	00 
f01012df:	8b 43 08             	mov    0x8(%ebx),%eax
f01012e2:	89 04 24             	mov    %eax,(%esp)
f01012e5:	e8 b1 60 00 00       	call   f010739b <strtol>
f01012ea:	89 c3                	mov    %eax,%ebx
      if(addr != ROUNDUP(addr,PGSIZE)){
f01012ec:	8d 80 ff 0f 00 00    	lea    0xfff(%eax),%eax
f01012f2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01012f7:	39 c3                	cmp    %eax,%ebx
f01012f9:	75 18                	jne    f0101313 <mon_dump+0xa0>
        cprintf("wrong address\n");
        return 0;
      }     
      int i = 0;
      for(i = 0; i<size;i++){
f01012fb:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01012ff:	0f 84 9f 00 00 00    	je     f01013a4 <mon_dump+0x131>
f0101305:	89 df                	mov    %ebx,%edi
f0101307:	b8 00 00 00 00       	mov    $0x0,%eax
f010130c:	be 00 00 00 00       	mov    $0x0,%esi
f0101311:	eb 21                	jmp    f0101334 <mon_dump+0xc1>
   uint32_t size = strtol(argv[3],0,0);
   uint32_t value = 0;
   if(strcmp(op,"v") == 0){
      uintptr_t addr = strtol(argv[2],0,0); 
      if(addr != ROUNDUP(addr,PGSIZE)){
        cprintf("wrong address\n");
f0101313:	c7 04 24 db 84 10 f0 	movl   $0xf01084db,(%esp)
f010131a:	e8 a0 37 00 00       	call   f0104abf <cprintf>
        return 0;
f010131f:	e9 e7 01 00 00       	jmp    f010150b <mon_dump+0x298>
      }     
      int i = 0;
      for(i = 0; i<size;i++){
        if(addr + i*4 < addr + (i-1)*4 && i != 0)
f0101324:	89 fb                	mov    %edi,%ebx
f0101326:	83 c3 04             	add    $0x4,%ebx
f0101329:	73 07                	jae    f0101332 <mon_dump+0xbf>
f010132b:	85 f6                	test   %esi,%esi
f010132d:	8d 76 00             	lea    0x0(%esi),%esi
f0101330:	75 72                	jne    f01013a4 <mon_dump+0x131>
f0101332:	89 df                	mov    %ebx,%edi
            break;
        if(i%4 == 0){
f0101334:	a8 03                	test   $0x3,%al
f0101336:	75 20                	jne    f0101358 <mon_dump+0xe5>
          if(i != 0)
f0101338:	85 f6                	test   %esi,%esi
f010133a:	74 0c                	je     f0101348 <mon_dump+0xd5>
             cprintf("\n");
f010133c:	c7 04 24 d9 84 10 f0 	movl   $0xf01084d9,(%esp)
f0101343:	e8 77 37 00 00       	call   f0104abf <cprintf>
          cprintf("0x%08x: ",addr + i*4);
f0101348:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010134c:	c7 04 24 ea 84 10 f0 	movl   $0xf01084ea,(%esp)
f0101353:	e8 67 37 00 00       	call   f0104abf <cprintf>
        }
        pte_t* pte = pgdir_walk(kern_pgdir,(void*)(addr+i*4),0);
f0101358:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010135f:	00 
f0101360:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101364:	a1 ac 0e 1f f0       	mov    0xf01f0eac,%eax
f0101369:	89 04 24             	mov    %eax,(%esp)
f010136c:	e8 b4 0d 00 00       	call   f0102125 <pgdir_walk>
        if((!pte) || (!(*pte) & PTE_P))
f0101371:	85 c0                	test   %eax,%eax
f0101373:	74 05                	je     f010137a <mon_dump+0x107>
f0101375:	83 38 00             	cmpl   $0x0,(%eax)
f0101378:	75 0e                	jne    f0101388 <mon_dump+0x115>
            cprintf("--         ");
f010137a:	c7 04 24 f3 84 10 f0 	movl   $0xf01084f3,(%esp)
f0101381:	e8 39 37 00 00       	call   f0104abf <cprintf>
          if(i != 0)
             cprintf("\n");
          cprintf("0x%08x: ",addr + i*4);
        }
        pte_t* pte = pgdir_walk(kern_pgdir,(void*)(addr+i*4),0);
        if((!pte) || (!(*pte) & PTE_P))
f0101386:	eb 12                	jmp    f010139a <mon_dump+0x127>
            cprintf("--         ");
        else{
          value = *((uint32_t*)(addr + i*4));
          cprintf("0x%08x ",value);
f0101388:	8b 03                	mov    (%ebx),%eax
f010138a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010138e:	c7 04 24 ff 84 10 f0 	movl   $0xf01084ff,(%esp)
f0101395:	e8 25 37 00 00       	call   f0104abf <cprintf>
      if(addr != ROUNDUP(addr,PGSIZE)){
        cprintf("wrong address\n");
        return 0;
      }     
      int i = 0;
      for(i = 0; i<size;i++){
f010139a:	83 c6 01             	add    $0x1,%esi
f010139d:	89 f0                	mov    %esi,%eax
f010139f:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
f01013a2:	77 80                	ja     f0101324 <mon_dump+0xb1>
        else{
          value = *((uint32_t*)(addr + i*4));
          cprintf("0x%08x ",value);
        }
      }
      cprintf("\n");
f01013a4:	c7 04 24 d9 84 10 f0 	movl   $0xf01084d9,(%esp)
f01013ab:	e8 0f 37 00 00       	call   f0104abf <cprintf>
f01013b0:	e9 56 01 00 00       	jmp    f010150b <mon_dump+0x298>
    }
    else if(strcmp(op,"p") == 0){
f01013b5:	c7 44 24 04 d6 85 10 	movl   $0xf01085d6,0x4(%esp)
f01013bc:	f0 
f01013bd:	89 34 24             	mov    %esi,(%esp)
f01013c0:	e8 90 5d 00 00       	call   f0107155 <strcmp>
f01013c5:	85 c0                	test   %eax,%eax
f01013c7:	0f 85 32 01 00 00    	jne    f01014ff <mon_dump+0x28c>
        physaddr_t addr = strtol(argv[2],0,0); 
f01013cd:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01013d4:	00 
f01013d5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01013dc:	00 
f01013dd:	8b 43 08             	mov    0x8(%ebx),%eax
f01013e0:	89 04 24             	mov    %eax,(%esp)
f01013e3:	e8 b3 5f 00 00       	call   f010739b <strtol>
f01013e8:	89 c7                	mov    %eax,%edi
        if(addr != ROUNDUP(addr,PGSIZE)){
f01013ea:	8d 80 ff 0f 00 00    	lea    0xfff(%eax),%eax
f01013f0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01013f5:	39 c7                	cmp    %eax,%edi
f01013f7:	75 1f                	jne    f0101418 <mon_dump+0x1a5>
           cprintf("wrong address\n");
           return 0;
        }  
        uintptr_t vaddr = 0;   
        int i = 0;       
        for(i = 0; i<size;i++){
f01013f9:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01013fd:	0f 84 ee 00 00 00    	je     f01014f1 <mon_dump+0x27e>
f0101403:	89 fe                	mov    %edi,%esi
f0101405:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f010140c:	b8 00 00 00 00       	mov    $0x0,%eax
f0101411:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101416:	eb 2c                	jmp    f0101444 <mon_dump+0x1d1>
      cprintf("\n");
    }
    else if(strcmp(op,"p") == 0){
        physaddr_t addr = strtol(argv[2],0,0); 
        if(addr != ROUNDUP(addr,PGSIZE)){
           cprintf("wrong address\n");
f0101418:	c7 04 24 db 84 10 f0 	movl   $0xf01084db,(%esp)
f010141f:	e8 9b 36 00 00       	call   f0104abf <cprintf>
           return 0;
f0101424:	e9 e2 00 00 00       	jmp    f010150b <mon_dump+0x298>
f0101429:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
f0101430:	89 55 e0             	mov    %edx,-0x20(%ebp)
        }  
        uintptr_t vaddr = 0;   
        int i = 0;       
        for(i = 0; i<size;i++){
          if(addr + i*4 < addr + (i-1)*4 && i != 0)
f0101433:	89 fe                	mov    %edi,%esi
f0101435:	83 c6 04             	add    $0x4,%esi
f0101438:	73 08                	jae    f0101442 <mon_dump+0x1cf>
f010143a:	85 db                	test   %ebx,%ebx
f010143c:	0f 85 af 00 00 00    	jne    f01014f1 <mon_dump+0x27e>
f0101442:	89 f7                	mov    %esi,%edi
              break;
          if(i%4 == 0){
f0101444:	a8 03                	test   $0x3,%al
f0101446:	75 20                	jne    f0101468 <mon_dump+0x1f5>
             if(i != 0)
f0101448:	85 db                	test   %ebx,%ebx
f010144a:	74 0c                	je     f0101458 <mon_dump+0x1e5>
               cprintf("\n");
f010144c:	c7 04 24 d9 84 10 f0 	movl   $0xf01084d9,(%esp)
f0101453:	e8 67 36 00 00       	call   f0104abf <cprintf>
             cprintf("0x%08x: ",addr + i*4);
f0101458:	89 74 24 04          	mov    %esi,0x4(%esp)
f010145c:	c7 04 24 ea 84 10 f0 	movl   $0xf01084ea,(%esp)
f0101463:	e8 57 36 00 00       	call   f0104abf <cprintf>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101468:	89 f0                	mov    %esi,%eax
f010146a:	c1 e8 0c             	shr    $0xc,%eax
f010146d:	3b 05 a8 0e 1f f0    	cmp    0xf01f0ea8,%eax
f0101473:	72 20                	jb     f0101495 <mon_dump+0x222>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101475:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0101479:	c7 44 24 08 80 80 10 	movl   $0xf0108080,0x8(%esp)
f0101480:	f0 
f0101481:	c7 44 24 04 35 01 00 	movl   $0x135,0x4(%esp)
f0101488:	00 
f0101489:	c7 04 24 07 85 10 f0 	movl   $0xf0108507,(%esp)
f0101490:	e8 f0 eb ff ff       	call   f0100085 <_panic>
	return (void *)(pa + KERNBASE);
f0101495:	81 ee 00 00 00 10    	sub    $0x10000000,%esi
          }
          vaddr = (uintptr_t)KADDR(addr + i*4);
          pte_t* pte = pgdir_walk(kern_pgdir,(void*)(vaddr+i*4),0);
f010149b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01014a2:	00 
f01014a3:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01014a6:	8d 04 16             	lea    (%esi,%edx,1),%eax
f01014a9:	89 44 24 04          	mov    %eax,0x4(%esp)
f01014ad:	a1 ac 0e 1f f0       	mov    0xf01f0eac,%eax
f01014b2:	89 04 24             	mov    %eax,(%esp)
f01014b5:	e8 6b 0c 00 00       	call   f0102125 <pgdir_walk>
          if((!pte) || (!(*pte) & PTE_P))
f01014ba:	85 c0                	test   %eax,%eax
f01014bc:	74 05                	je     f01014c3 <mon_dump+0x250>
f01014be:	83 38 00             	cmpl   $0x0,(%eax)
f01014c1:	75 0e                	jne    f01014d1 <mon_dump+0x25e>
              cprintf("--         ");
f01014c3:	c7 04 24 f3 84 10 f0 	movl   $0xf01084f3,(%esp)
f01014ca:	e8 f0 35 00 00       	call   f0104abf <cprintf>
               cprintf("\n");
             cprintf("0x%08x: ",addr + i*4);
          }
          vaddr = (uintptr_t)KADDR(addr + i*4);
          pte_t* pte = pgdir_walk(kern_pgdir,(void*)(vaddr+i*4),0);
          if((!pte) || (!(*pte) & PTE_P))
f01014cf:	eb 12                	jmp    f01014e3 <mon_dump+0x270>
              cprintf("--         ");
          else{
            value = *((uint32_t*)(vaddr));
            cprintf("0x%08x ",value);
f01014d1:	8b 06                	mov    (%esi),%eax
f01014d3:	89 44 24 04          	mov    %eax,0x4(%esp)
f01014d7:	c7 04 24 ff 84 10 f0 	movl   $0xf01084ff,(%esp)
f01014de:	e8 dc 35 00 00       	call   f0104abf <cprintf>
           cprintf("wrong address\n");
           return 0;
        }  
        uintptr_t vaddr = 0;   
        int i = 0;       
        for(i = 0; i<size;i++){
f01014e3:	83 c3 01             	add    $0x1,%ebx
f01014e6:	89 d8                	mov    %ebx,%eax
f01014e8:	39 5d e4             	cmp    %ebx,-0x1c(%ebp)
f01014eb:	0f 87 38 ff ff ff    	ja     f0101429 <mon_dump+0x1b6>
          else{
            value = *((uint32_t*)(vaddr));
            cprintf("0x%08x ",value);
          }
        }
         cprintf("\n");
f01014f1:	c7 04 24 d9 84 10 f0 	movl   $0xf01084d9,(%esp)
f01014f8:	e8 c2 35 00 00       	call   f0104abf <cprintf>
f01014fd:	eb 0c                	jmp    f010150b <mon_dump+0x298>
    }
    else{
        cprintf("Usage: dump [op] [addr] [size]\n");
f01014ff:	c7 04 24 14 87 10 f0 	movl   $0xf0108714,(%esp)
f0101506:	e8 b4 35 00 00       	call   f0104abf <cprintf>
        return 0;
    }
    return 0;
}
f010150b:	b8 00 00 00 00       	mov    $0x0,%eax
f0101510:	83 c4 2c             	add    $0x2c,%esp
f0101513:	5b                   	pop    %ebx
f0101514:	5e                   	pop    %esi
f0101515:	5f                   	pop    %edi
f0101516:	5d                   	pop    %ebp
f0101517:	c3                   	ret    

f0101518 <mon_c>:
  }
  return 0;
}

int 
mon_c(int argc,char **argv,struct Trapframe *tf){
f0101518:	55                   	push   %ebp
f0101519:	89 e5                	mov    %esp,%ebp
f010151b:	83 ec 38             	sub    $0x38,%esp
f010151e:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0101521:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0101524:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0101527:	8b 75 10             	mov    0x10(%ebp),%esi
  if(argc != 1)
f010152a:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
f010152e:	74 0e                	je     f010153e <mon_c+0x26>
    cprintf("Usage: c\n");
f0101530:	c7 04 24 16 85 10 f0 	movl   $0xf0108516,(%esp)
f0101537:	e8 83 35 00 00       	call   f0104abf <cprintf>
f010153c:	eb 48                	jmp    f0101586 <mon_c+0x6e>
  else if(tf == NULL)
f010153e:	85 f6                	test   %esi,%esi
f0101540:	75 0e                	jne    f0101550 <mon_c+0x38>
    cprintf("trapframe error\n");
f0101542:	c7 04 24 49 84 10 f0 	movl   $0xf0108449,(%esp)
f0101549:	e8 71 35 00 00       	call   f0104abf <cprintf>
f010154e:	eb 36                	jmp    f0101586 <mon_c+0x6e>
  else{
     curenv->env_tf = *tf;		
f0101550:	e8 79 63 00 00       	call   f01078ce <cpunum>
f0101555:	bb 20 10 1f f0       	mov    $0xf01f1020,%ebx
f010155a:	6b c0 74             	imul   $0x74,%eax,%eax
f010155d:	8b 44 18 08          	mov    0x8(%eax,%ebx,1),%eax
f0101561:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0101564:	b9 11 00 00 00       	mov    $0x11,%ecx
f0101569:	89 c7                	mov    %eax,%edi
f010156b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
     tf = &curenv->env_tf;
f010156d:	e8 5c 63 00 00       	call   f01078ce <cpunum>
     env_run(curenv);
f0101572:	e8 57 63 00 00       	call   f01078ce <cpunum>
f0101577:	6b c0 74             	imul   $0x74,%eax,%eax
f010157a:	8b 44 18 08          	mov    0x8(%eax,%ebx,1),%eax
f010157e:	89 04 24             	mov    %eax,(%esp)
f0101581:	e8 64 2d 00 00       	call   f01042ea <env_run>
  }

  return 0;
} 
f0101586:	b8 00 00 00 00       	mov    $0x0,%eax
f010158b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f010158e:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0101591:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0101594:	89 ec                	mov    %ebp,%esp
f0101596:	5d                   	pop    %ebp
f0101597:	c3                   	ret    

f0101598 <mon_si>:
    }
    return 0;
}

int 
mon_si(int argc,char **argv,struct Trapframe *tf){
f0101598:	55                   	push   %ebp
f0101599:	89 e5                	mov    %esp,%ebp
f010159b:	83 ec 68             	sub    $0x68,%esp
f010159e:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f01015a1:	89 75 f8             	mov    %esi,-0x8(%ebp)
f01015a4:	89 7d fc             	mov    %edi,-0x4(%ebp)
f01015a7:	8b 75 10             	mov    0x10(%ebp),%esi
  if(argc != 1)
f01015aa:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
f01015ae:	74 11                	je     f01015c1 <mon_si+0x29>
    cprintf("Usage: si\n");
f01015b0:	c7 04 24 20 85 10 f0 	movl   $0xf0108520,(%esp)
f01015b7:	e8 03 35 00 00       	call   f0104abf <cprintf>
f01015bc:	e9 a2 00 00 00       	jmp    f0101663 <mon_si+0xcb>
  else if(tf == NULL)
f01015c1:	85 f6                	test   %esi,%esi
f01015c3:	75 11                	jne    f01015d6 <mon_si+0x3e>
    cprintf("trapframe error\n");
f01015c5:	c7 04 24 49 84 10 f0 	movl   $0xf0108449,(%esp)
f01015cc:	e8 ee 34 00 00       	call   f0104abf <cprintf>
f01015d1:	e9 8d 00 00 00       	jmp    f0101663 <mon_si+0xcb>
  else{
    struct Eipdebuginfo info;
    tf->tf_eflags = tf->tf_eflags | 0x100;
f01015d6:	81 4e 38 00 01 00 00 	orl    $0x100,0x38(%esi)
    cprintf("tf_eip=%08x\n",tf->tf_eip);
f01015dd:	8b 46 30             	mov    0x30(%esi),%eax
f01015e0:	89 44 24 04          	mov    %eax,0x4(%esp)
f01015e4:	c7 04 24 2b 85 10 f0 	movl   $0xf010852b,(%esp)
f01015eb:	e8 cf 34 00 00       	call   f0104abf <cprintf>
    debuginfo_eip(tf->tf_eip,&info);
f01015f0:	8d 45 d0             	lea    -0x30(%ebp),%eax
f01015f3:	89 44 24 04          	mov    %eax,0x4(%esp)
f01015f7:	8b 46 30             	mov    0x30(%esi),%eax
f01015fa:	89 04 24             	mov    %eax,(%esp)
f01015fd:	e8 dc 4e 00 00       	call   f01064de <debuginfo_eip>
    cprintf("%s:%d: %s+%d\n",info.eip_file,info.eip_line,info.eip_fn_name,tf->tf_eip-info.eip_fn_addr);
f0101602:	8b 46 30             	mov    0x30(%esi),%eax
f0101605:	2b 45 e0             	sub    -0x20(%ebp),%eax
f0101608:	89 44 24 10          	mov    %eax,0x10(%esp)
f010160c:	8b 45 d8             	mov    -0x28(%ebp),%eax
f010160f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101613:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101616:	89 44 24 08          	mov    %eax,0x8(%esp)
f010161a:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010161d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101621:	c7 04 24 17 84 10 f0 	movl   $0xf0108417,(%esp)
f0101628:	e8 92 34 00 00       	call   f0104abf <cprintf>
    curenv->env_tf = *tf;		
f010162d:	e8 9c 62 00 00       	call   f01078ce <cpunum>
f0101632:	bb 20 10 1f f0       	mov    $0xf01f1020,%ebx
f0101637:	6b c0 74             	imul   $0x74,%eax,%eax
f010163a:	8b 44 18 08          	mov    0x8(%eax,%ebx,1),%eax
f010163e:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0101641:	b9 11 00 00 00       	mov    $0x11,%ecx
f0101646:	89 c7                	mov    %eax,%edi
f0101648:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
    tf = &curenv->env_tf;
f010164a:	e8 7f 62 00 00       	call   f01078ce <cpunum>
    env_run(curenv);
f010164f:	e8 7a 62 00 00       	call   f01078ce <cpunum>
f0101654:	6b c0 74             	imul   $0x74,%eax,%eax
f0101657:	8b 44 18 08          	mov    0x8(%eax,%ebx,1),%eax
f010165b:	89 04 24             	mov    %eax,(%esp)
f010165e:	e8 87 2c 00 00       	call   f01042ea <env_run>
  }
  return 0;
}
f0101663:	b8 00 00 00 00       	mov    $0x0,%eax
f0101668:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f010166b:	8b 75 f8             	mov    -0x8(%ebp),%esi
f010166e:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0101671:	89 ec                	mov    %ebp,%esp
f0101673:	5d                   	pop    %ebp
f0101674:	c3                   	ret    
	...

f0101680 <page_free_npages>:
//	2. Add the pages to the chunk list
//	
//	Return 0 if everything ok
int
page_free_npages(struct Page *pp, int n)
{
f0101680:	55                   	push   %ebp
f0101681:	89 e5                	mov    %esp,%ebp
f0101683:	53                   	push   %ebx
f0101684:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// Fill this function
        struct Page* tmpPP = pp;
        int i = 0;
        if(pp == NULL)
f0101687:	85 db                	test   %ebx,%ebx
f0101689:	74 3c                	je     f01016c7 <page_free_npages+0x47>
            return -1;
        for(i = 0;i< n-1;i++){
f010168b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010168e:	83 e9 01             	sub    $0x1,%ecx
f0101691:	89 d8                	mov    %ebx,%eax
f0101693:	85 c9                	test   %ecx,%ecx
f0101695:	7e 1b                	jle    f01016b2 <page_free_npages+0x32>
             if(tmpPP->pp_link == NULL)
f0101697:	8b 03                	mov    (%ebx),%eax
f0101699:	ba 00 00 00 00       	mov    $0x0,%edx
f010169e:	85 c0                	test   %eax,%eax
f01016a0:	75 08                	jne    f01016aa <page_free_npages+0x2a>
f01016a2:	eb 23                	jmp    f01016c7 <page_free_npages+0x47>
f01016a4:	8b 00                	mov    (%eax),%eax
f01016a6:	85 c0                	test   %eax,%eax
f01016a8:	74 1d                	je     f01016c7 <page_free_npages+0x47>
	// Fill this function
        struct Page* tmpPP = pp;
        int i = 0;
        if(pp == NULL)
            return -1;
        for(i = 0;i< n-1;i++){
f01016aa:	83 c2 01             	add    $0x1,%edx
f01016ad:	39 ca                	cmp    %ecx,%edx
f01016af:	90                   	nop
f01016b0:	7c f2                	jl     f01016a4 <page_free_npages+0x24>
             if(tmpPP->pp_link == NULL)
                 return -1;
             tmpPP = tmpPP->pp_link;
        }
        tmpPP->pp_link = page_free_list;
f01016b2:	8b 15 50 02 1f f0    	mov    0xf01f0250,%edx
f01016b8:	89 10                	mov    %edx,(%eax)
        page_free_list = pp;
f01016ba:	89 1d 50 02 1f f0    	mov    %ebx,0xf01f0250
f01016c0:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
f01016c5:	eb 05                	jmp    f01016cc <page_free_npages+0x4c>
f01016c7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f01016cc:	5b                   	pop    %ebx
f01016cd:	5d                   	pop    %ebp
f01016ce:	c3                   	ret    

f01016cf <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct Page *pp)
{
f01016cf:	55                   	push   %ebp
f01016d0:	89 e5                	mov    %esp,%ebp
f01016d2:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
        pp->pp_link = page_free_list;
f01016d5:	8b 15 50 02 1f f0    	mov    0xf01f0250,%edx
f01016db:	89 10                	mov    %edx,(%eax)
        page_free_list = pp;
f01016dd:	a3 50 02 1f f0       	mov    %eax,0xf01f0250
}
f01016e2:	5d                   	pop    %ebp
f01016e3:	c3                   	ret    

f01016e4 <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct Page* pp)
{
f01016e4:	55                   	push   %ebp
f01016e5:	89 e5                	mov    %esp,%ebp
f01016e7:	83 ec 04             	sub    $0x4,%esp
f01016ea:	8b 45 08             	mov    0x8(%ebp),%eax
	if (--pp->pp_ref == 0)
f01016ed:	0f b7 50 04          	movzwl 0x4(%eax),%edx
f01016f1:	83 ea 01             	sub    $0x1,%edx
f01016f4:	66 89 50 04          	mov    %dx,0x4(%eax)
f01016f8:	66 85 d2             	test   %dx,%dx
f01016fb:	75 08                	jne    f0101705 <page_decref+0x21>
		page_free(pp);
f01016fd:	89 04 24             	mov    %eax,(%esp)
f0101700:	e8 ca ff ff ff       	call   f01016cf <page_free>
}
f0101705:	c9                   	leave  
f0101706:	c3                   	ret    

f0101707 <pgdir_walk_large>:
	return &vpt[PTX(va)];
}

pte_t*
pgdir_walk_large(pde_t *pgdir, const void *va, int create)
{
f0101707:	55                   	push   %ebp
f0101708:	89 e5                	mov    %esp,%ebp
f010170a:	8b 45 0c             	mov    0xc(%ebp),%eax
f010170d:	c1 e8 16             	shr    $0x16,%eax
f0101710:	c1 e0 02             	shl    $0x2,%eax
f0101713:	03 45 08             	add    0x8(%ebp),%eax
        return &pgdir[PDX(va)];
}
f0101716:	5d                   	pop    %ebp
f0101717:	c3                   	ret    

f0101718 <check_va2pa_large>:
	return PTE_ADDR(p[PTX(va)]);
}

static physaddr_t
check_va2pa_large(pde_t *pgdir, uintptr_t va)
{
f0101718:	55                   	push   %ebp
f0101719:	89 e5                	mov    %esp,%ebp
	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P) | !(*pgdir & PTE_PS))
f010171b:	c1 ea 16             	shr    $0x16,%edx
f010171e:	8b 04 90             	mov    (%eax,%edx,4),%eax
f0101721:	89 c2                	mov    %eax,%edx
f0101723:	81 e2 81 00 00 00    	and    $0x81,%edx
f0101729:	89 c1                	mov    %eax,%ecx
f010172b:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0101731:	81 fa 81 00 00 00    	cmp    $0x81,%edx
f0101737:	0f 94 c0             	sete   %al
f010173a:	0f b6 c0             	movzbl %al,%eax
f010173d:	83 e8 01             	sub    $0x1,%eax
f0101740:	09 c8                	or     %ecx,%eax
		return ~0;
	return PTE_ADDR(*pgdir);
}
f0101742:	5d                   	pop    %ebp
f0101743:	c3                   	ret    

f0101744 <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f0101744:	55                   	push   %ebp
f0101745:	89 e5                	mov    %esp,%ebp
f0101747:	83 ec 08             	sub    $0x8,%esp
	// Flush the entry only if we're modifying the current address space.
	if (!curenv || curenv->env_pgdir == pgdir)
f010174a:	e8 7f 61 00 00       	call   f01078ce <cpunum>
f010174f:	6b c0 74             	imul   $0x74,%eax,%eax
f0101752:	83 b8 28 10 1f f0 00 	cmpl   $0x0,-0xfe0efd8(%eax)
f0101759:	74 16                	je     f0101771 <tlb_invalidate+0x2d>
f010175b:	e8 6e 61 00 00       	call   f01078ce <cpunum>
f0101760:	6b c0 74             	imul   $0x74,%eax,%eax
f0101763:	8b 90 28 10 1f f0    	mov    -0xfe0efd8(%eax),%edx
f0101769:	8b 45 08             	mov    0x8(%ebp),%eax
f010176c:	39 42 64             	cmp    %eax,0x64(%edx)
f010176f:	75 06                	jne    f0101777 <tlb_invalidate+0x33>
}

static __inline void 
invlpg(void *addr)
{ 
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0101771:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101774:	0f 01 38             	invlpg (%eax)
		invlpg(va);
}
f0101777:	c9                   	leave  
f0101778:	c3                   	ret    

f0101779 <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0101779:	55                   	push   %ebp
f010177a:	89 e5                	mov    %esp,%ebp
f010177c:	83 ec 18             	sub    $0x18,%esp
f010177f:	89 c2                	mov    %eax,%edx
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0101781:	83 3d 48 02 1f f0 00 	cmpl   $0x0,0xf01f0248
f0101788:	75 0f                	jne    f0101799 <boot_alloc+0x20>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f010178a:	b8 03 30 23 f0       	mov    $0xf0233003,%eax
f010178f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0101794:	a3 48 02 1f f0       	mov    %eax,0xf01f0248
	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
        result = nextfree;
f0101799:	a1 48 02 1f f0       	mov    0xf01f0248,%eax
        nextfree = ROUNDUP(nextfree+n,PGSIZE);
f010179e:	8d 94 10 ff 0f 00 00 	lea    0xfff(%eax,%edx,1),%edx
f01017a5:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01017ab:	89 15 48 02 1f f0    	mov    %edx,0xf01f0248
        if((uint32_t)nextfree >= 0xF0400000){    // VA's [KERNBASE, KERNBASE+4MB)
f01017b1:	81 fa ff ff 3f f0    	cmp    $0xf03fffff,%edx
f01017b7:	76 21                	jbe    f01017da <boot_alloc+0x61>
           nextfree = result;
f01017b9:	a3 48 02 1f f0       	mov    %eax,0xf01f0248
           panic("boot_alloc:Out of memory\n");
f01017be:	c7 44 24 08 0c 88 10 	movl   $0xf010880c,0x8(%esp)
f01017c5:	f0 
f01017c6:	c7 44 24 04 73 00 00 	movl   $0x73,0x4(%esp)
f01017cd:	00 
f01017ce:	c7 04 24 26 88 10 f0 	movl   $0xf0108826,(%esp)
f01017d5:	e8 ab e8 ff ff       	call   f0100085 <_panic>
        }
	return result;
}
f01017da:	c9                   	leave  
f01017db:	c3                   	ret    

f01017dc <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f01017dc:	55                   	push   %ebp
f01017dd:	89 e5                	mov    %esp,%ebp
f01017df:	56                   	push   %esi
f01017e0:	53                   	push   %ebx
f01017e1:	83 ec 10             	sub    $0x10,%esp
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 0; i < npages; i++) {
f01017e4:	83 3d a8 0e 1f f0 00 	cmpl   $0x0,0xf01f0ea8
f01017eb:	0f 84 41 01 00 00    	je     f0101932 <page_init+0x156>
f01017f1:	be 00 00 00 00       	mov    $0x0,%esi
f01017f6:	bb 00 00 00 00       	mov    $0x0,%ebx
                if(i == 0){
f01017fb:	85 db                	test   %ebx,%ebx
f01017fd:	75 1b                	jne    f010181a <page_init+0x3e>
                   pages[i].pp_ref = 1;
f01017ff:	a1 b0 0e 1f f0       	mov    0xf01f0eb0,%eax
f0101804:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
                   pages[i].pp_link = NULL;
f010180a:	a1 b0 0e 1f f0       	mov    0xf01f0eb0,%eax
f010180f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
f0101815:	e9 06 01 00 00       	jmp    f0101920 <page_init+0x144>
                }
                else if(i == MPENTRY_PADDR/PGSIZE){
f010181a:	83 fb 07             	cmp    $0x7,%ebx
f010181d:	75 1c                	jne    f010183b <page_init+0x5f>
                   pages[i].pp_ref = 1;
f010181f:	a1 b0 0e 1f f0       	mov    0xf01f0eb0,%eax
f0101824:	66 c7 40 3c 01 00    	movw   $0x1,0x3c(%eax)
                   pages[i].pp_link = NULL;
f010182a:	a1 b0 0e 1f f0       	mov    0xf01f0eb0,%eax
f010182f:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)
f0101836:	e9 e5 00 00 00       	jmp    f0101920 <page_init+0x144>
                }
                else if(i>=1 && i < npages_basemem){
f010183b:	39 1d 4c 02 1f f0    	cmp    %ebx,0xf01f024c
f0101841:	76 2c                	jbe    f010186f <page_init+0x93>
                //else if(i >= 1 && i < MPENTRY_PADDR/PGSIZE){
                   pages[i].pp_ref = 0;
f0101843:	a1 b0 0e 1f f0       	mov    0xf01f0eb0,%eax
f0101848:	66 c7 44 30 04 00 00 	movw   $0x0,0x4(%eax,%esi,1)
                   pages[i].pp_link = page_free_list;
f010184f:	8b 15 50 02 1f f0    	mov    0xf01f0250,%edx
f0101855:	a1 b0 0e 1f f0       	mov    0xf01f0eb0,%eax
f010185a:	89 14 30             	mov    %edx,(%eax,%esi,1)
                   page_free_list = &pages[i];
f010185d:	89 f0                	mov    %esi,%eax
f010185f:	03 05 b0 0e 1f f0    	add    0xf01f0eb0,%eax
f0101865:	a3 50 02 1f f0       	mov    %eax,0xf01f0250
                }
                else if(i == MPENTRY_PADDR/PGSIZE){
                   pages[i].pp_ref = 1;
                   pages[i].pp_link = NULL;
                }
                else if(i>=1 && i < npages_basemem){
f010186a:	e9 b1 00 00 00       	jmp    f0101920 <page_init+0x144>
                   pages[i].pp_ref = 0;
                   pages[i].pp_link = page_free_list;
                   page_free_list = &pages[i];
                }
                
                else if(i >= IOPHYSMEM/PGSIZE && i<EXTPHYSMEM/PGSIZE){
f010186f:	8d 83 60 ff ff ff    	lea    -0xa0(%ebx),%eax
f0101875:	83 f8 5f             	cmp    $0x5f,%eax
f0101878:	77 1d                	ja     f0101897 <page_init+0xbb>
                   pages[i].pp_ref = 1;
f010187a:	a1 b0 0e 1f f0       	mov    0xf01f0eb0,%eax
f010187f:	66 c7 44 30 04 01 00 	movw   $0x1,0x4(%eax,%esi,1)
                   pages[i].pp_link = NULL;
f0101886:	a1 b0 0e 1f f0       	mov    0xf01f0eb0,%eax
f010188b:	c7 04 30 00 00 00 00 	movl   $0x0,(%eax,%esi,1)
f0101892:	e9 89 00 00 00       	jmp    f0101920 <page_init+0x144>
                }
                else if(i >= EXTPHYSMEM/PGSIZE && i<((uint32_t)PADDR(boot_alloc(0)))/PGSIZE){
f0101897:	81 fb ff 00 00 00    	cmp    $0xff,%ebx
f010189d:	76 5a                	jbe    f01018f9 <page_init+0x11d>
f010189f:	b8 00 00 00 00       	mov    $0x0,%eax
f01018a4:	e8 d0 fe ff ff       	call   f0101779 <boot_alloc>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01018a9:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01018ae:	66 90                	xchg   %ax,%ax
f01018b0:	77 20                	ja     f01018d2 <page_init+0xf6>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01018b2:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01018b6:	c7 44 24 08 5c 80 10 	movl   $0xf010805c,0x8(%esp)
f01018bd:	f0 
f01018be:	c7 44 24 04 63 01 00 	movl   $0x163,0x4(%esp)
f01018c5:	00 
f01018c6:	c7 04 24 26 88 10 f0 	movl   $0xf0108826,(%esp)
f01018cd:	e8 b3 e7 ff ff       	call   f0100085 <_panic>
f01018d2:	8d 80 00 00 00 10    	lea    0x10000000(%eax),%eax
f01018d8:	c1 e8 0c             	shr    $0xc,%eax
f01018db:	39 c3                	cmp    %eax,%ebx
f01018dd:	73 1a                	jae    f01018f9 <page_init+0x11d>
		   pages[i].pp_ref = 1;
f01018df:	a1 b0 0e 1f f0       	mov    0xf01f0eb0,%eax
f01018e4:	66 c7 44 30 04 01 00 	movw   $0x1,0x4(%eax,%esi,1)
                   pages[i].pp_link = NULL;
f01018eb:	a1 b0 0e 1f f0       	mov    0xf01f0eb0,%eax
f01018f0:	c7 04 30 00 00 00 00 	movl   $0x0,(%eax,%esi,1)
                
                else if(i >= IOPHYSMEM/PGSIZE && i<EXTPHYSMEM/PGSIZE){
                   pages[i].pp_ref = 1;
                   pages[i].pp_link = NULL;
                }
                else if(i >= EXTPHYSMEM/PGSIZE && i<((uint32_t)PADDR(boot_alloc(0)))/PGSIZE){
f01018f7:	eb 27                	jmp    f0101920 <page_init+0x144>
		   pages[i].pp_ref = 1;
                   pages[i].pp_link = NULL;
                }
                else{
                   pages[i].pp_ref = 0;
f01018f9:	a1 b0 0e 1f f0       	mov    0xf01f0eb0,%eax
f01018fe:	66 c7 44 30 04 00 00 	movw   $0x0,0x4(%eax,%esi,1)
		   pages[i].pp_link = page_free_list;
f0101905:	8b 15 50 02 1f f0    	mov    0xf01f0250,%edx
f010190b:	a1 b0 0e 1f f0       	mov    0xf01f0eb0,%eax
f0101910:	89 14 30             	mov    %edx,(%eax,%esi,1)
		   page_free_list = &pages[i];
f0101913:	89 f0                	mov    %esi,%eax
f0101915:	03 05 b0 0e 1f f0    	add    0xf01f0eb0,%eax
f010191b:	a3 50 02 1f f0       	mov    %eax,0xf01f0250
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 0; i < npages; i++) {
f0101920:	83 c3 01             	add    $0x1,%ebx
f0101923:	83 c6 08             	add    $0x8,%esi
f0101926:	39 1d a8 0e 1f f0    	cmp    %ebx,0xf01f0ea8
f010192c:	0f 87 c9 fe ff ff    	ja     f01017fb <page_init+0x1f>
                   pages[i].pp_ref = 0;
		   pages[i].pp_link = page_free_list;
		   page_free_list = &pages[i];
                }
	}
	chunk_list = NULL;
f0101932:	c7 05 54 02 1f f0 00 	movl   $0x0,0xf01f0254
f0101939:	00 00 00 
}
f010193c:	83 c4 10             	add    $0x10,%esp
f010193f:	5b                   	pop    %ebx
f0101940:	5e                   	pop    %esi
f0101941:	5d                   	pop    %ebp
f0101942:	c3                   	ret    

f0101943 <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f0101943:	55                   	push   %ebp
f0101944:	89 e5                	mov    %esp,%ebp
f0101946:	83 ec 18             	sub    $0x18,%esp
f0101949:	89 5d f8             	mov    %ebx,-0x8(%ebp)
f010194c:	89 75 fc             	mov    %esi,-0x4(%ebp)
f010194f:	89 c3                	mov    %eax,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0101951:	89 04 24             	mov    %eax,(%esp)
f0101954:	e8 0b 30 00 00       	call   f0104964 <mc146818_read>
f0101959:	89 c6                	mov    %eax,%esi
f010195b:	83 c3 01             	add    $0x1,%ebx
f010195e:	89 1c 24             	mov    %ebx,(%esp)
f0101961:	e8 fe 2f 00 00       	call   f0104964 <mc146818_read>
f0101966:	c1 e0 08             	shl    $0x8,%eax
f0101969:	09 f0                	or     %esi,%eax
}
f010196b:	8b 5d f8             	mov    -0x8(%ebp),%ebx
f010196e:	8b 75 fc             	mov    -0x4(%ebp),%esi
f0101971:	89 ec                	mov    %ebp,%esp
f0101973:	5d                   	pop    %ebp
f0101974:	c3                   	ret    

f0101975 <i386_detect_memory>:

static void
i386_detect_memory(void)
{
f0101975:	55                   	push   %ebp
f0101976:	89 e5                	mov    %esp,%ebp
f0101978:	83 ec 18             	sub    $0x18,%esp
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f010197b:	b8 15 00 00 00       	mov    $0x15,%eax
f0101980:	e8 be ff ff ff       	call   f0101943 <nvram_read>
f0101985:	c1 e0 0a             	shl    $0xa,%eax
f0101988:	89 c2                	mov    %eax,%edx
f010198a:	c1 fa 1f             	sar    $0x1f,%edx
f010198d:	c1 ea 14             	shr    $0x14,%edx
f0101990:	8d 04 02             	lea    (%edx,%eax,1),%eax
f0101993:	c1 f8 0c             	sar    $0xc,%eax
f0101996:	a3 4c 02 1f f0       	mov    %eax,0xf01f024c
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f010199b:	b8 17 00 00 00       	mov    $0x17,%eax
f01019a0:	e8 9e ff ff ff       	call   f0101943 <nvram_read>
f01019a5:	89 c2                	mov    %eax,%edx
f01019a7:	c1 e2 0a             	shl    $0xa,%edx
f01019aa:	89 d0                	mov    %edx,%eax
f01019ac:	c1 f8 1f             	sar    $0x1f,%eax
f01019af:	c1 e8 14             	shr    $0x14,%eax
f01019b2:	01 d0                	add    %edx,%eax
f01019b4:	c1 f8 0c             	sar    $0xc,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f01019b7:	85 c0                	test   %eax,%eax
f01019b9:	74 0e                	je     f01019c9 <i386_detect_memory+0x54>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f01019bb:	8d 90 00 01 00 00    	lea    0x100(%eax),%edx
f01019c1:	89 15 a8 0e 1f f0    	mov    %edx,0xf01f0ea8
f01019c7:	eb 0c                	jmp    f01019d5 <i386_detect_memory+0x60>
	else
		npages = npages_basemem;
f01019c9:	8b 15 4c 02 1f f0    	mov    0xf01f024c,%edx
f01019cf:	89 15 a8 0e 1f f0    	mov    %edx,0xf01f0ea8

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01019d5:	c1 e0 0c             	shl    $0xc,%eax
f01019d8:	c1 e8 0a             	shr    $0xa,%eax
f01019db:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01019df:	a1 4c 02 1f f0       	mov    0xf01f024c,%eax
f01019e4:	c1 e0 0c             	shl    $0xc,%eax
f01019e7:	c1 e8 0a             	shr    $0xa,%eax
f01019ea:	89 44 24 08          	mov    %eax,0x8(%esp)
f01019ee:	a1 a8 0e 1f f0       	mov    0xf01f0ea8,%eax
f01019f3:	c1 e0 0c             	shl    $0xc,%eax
f01019f6:	c1 e8 0a             	shr    $0xa,%eax
f01019f9:	89 44 24 04          	mov    %eax,0x4(%esp)
f01019fd:	c7 04 24 38 8b 10 f0 	movl   $0xf0108b38,(%esp)
f0101a04:	e8 b6 30 00 00       	call   f0104abf <cprintf>
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
		npages_extmem * PGSIZE / 1024);
}
f0101a09:	c9                   	leave  
f0101a0a:	c3                   	ret    

f0101a0b <page_alloc_npages>:
// Try to reuse the pages cached in the chuck list
//
// Hint: use page2kva and memset
struct Page *
page_alloc_npages(int alloc_flags, int n)
{
f0101a0b:	55                   	push   %ebp
f0101a0c:	89 e5                	mov    %esp,%ebp
f0101a0e:	57                   	push   %edi
f0101a0f:	56                   	push   %esi
f0101a10:	53                   	push   %ebx
f0101a11:	83 ec 3c             	sub    $0x3c,%esp
	// Fill this function
	struct Page* newPage = NULL;
        int i,j;
        int fflag = 0;
        int flag = 0;
        if(n <= 0){
f0101a14:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0101a18:	0f 8e 67 01 00 00    	jle    f0101b85 <page_alloc_npages+0x17a>
            return newPage;
        }
        if(page_free_list == NULL)
f0101a1e:	8b 35 50 02 1f f0    	mov    0xf01f0250,%esi
f0101a24:	85 f6                	test   %esi,%esi
f0101a26:	0f 84 59 01 00 00    	je     f0101b85 <page_alloc_npages+0x17a>
            return newPage;
        for(i = 0; i+n-1 <npages;i++){
f0101a2c:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101a2f:	83 e8 01             	sub    $0x1,%eax
f0101a32:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101a35:	8b 15 a8 0e 1f f0    	mov    0xf01f0ea8,%edx
f0101a3b:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0101a3e:	39 d0                	cmp    %edx,%eax
f0101a40:	0f 83 3f 01 00 00    	jae    f0101b85 <page_alloc_npages+0x17a>
           for(j = 0;j<n;j++){
              struct Page* tmpFree = page_free_list;
              flag = 0;
              if(pages[i+j].pp_ref != 0)
f0101a46:	a1 b0 0e 1f f0       	mov    0xf01f0eb0,%eax
f0101a4b:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101a4e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0101a51:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
                 break;
              while(tmpFree!= NULL){
                 if(tmpFree == &pages[i+j]){
f0101a58:	89 f7                	mov    %esi,%edi
        if(n <= 0){
            return newPage;
        }
        if(page_free_list == NULL)
            return newPage;
        for(i = 0; i+n-1 <npages;i++){
f0101a5a:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101a5d:	83 ea 01             	sub    $0x1,%edx
f0101a60:	89 55 d8             	mov    %edx,-0x28(%ebp)
f0101a63:	eb 68                	jmp    f0101acd <page_alloc_npages+0xc2>
           for(j = 0;j<n;j++){
              struct Page* tmpFree = page_free_list;
              flag = 0;
              if(pages[i+j].pp_ref != 0)
f0101a65:	89 ca                	mov    %ecx,%edx
f0101a67:	0f b7 41 04          	movzwl 0x4(%ecx),%eax
f0101a6b:	83 c1 08             	add    $0x8,%ecx
f0101a6e:	66 85 c0             	test   %ax,%ax
f0101a71:	75 43                	jne    f0101ab6 <page_alloc_npages+0xab>
                 break;
              while(tmpFree!= NULL){
                 if(tmpFree == &pages[i+j]){
f0101a73:	89 f8                	mov    %edi,%eax
f0101a75:	39 d6                	cmp    %edx,%esi
f0101a77:	75 09                	jne    f0101a82 <page_alloc_npages+0x77>
f0101a79:	eb 0f                	jmp    f0101a8a <page_alloc_npages+0x7f>
f0101a7b:	39 d0                	cmp    %edx,%eax
f0101a7d:	8d 76 00             	lea    0x0(%esi),%esi
f0101a80:	74 08                	je     f0101a8a <page_alloc_npages+0x7f>
                   flag = 1;
                   break;
                 }
                 tmpFree = tmpFree->pp_link;
f0101a82:	8b 00                	mov    (%eax),%eax
           for(j = 0;j<n;j++){
              struct Page* tmpFree = page_free_list;
              flag = 0;
              if(pages[i+j].pp_ref != 0)
                 break;
              while(tmpFree!= NULL){
f0101a84:	85 c0                	test   %eax,%eax
f0101a86:	75 f3                	jne    f0101a7b <page_alloc_npages+0x70>
f0101a88:	eb 10                	jmp    f0101a9a <page_alloc_npages+0x8f>
            return newPage;
        }
        if(page_free_list == NULL)
            return newPage;
        for(i = 0; i+n-1 <npages;i++){
           for(j = 0;j<n;j++){
f0101a8a:	83 c3 01             	add    $0x1,%ebx
f0101a8d:	39 5d 0c             	cmp    %ebx,0xc(%ebp)
f0101a90:	7f d3                	jg     f0101a65 <page_alloc_npages+0x5a>
f0101a92:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0101a98:	eb 08                	jmp    f0101aa2 <page_alloc_npages+0x97>
                 tmpFree = tmpFree->pp_link;
              }
              if(flag == 0)
                 break;
           }
           if(j >= n){
f0101a9a:	39 5d 0c             	cmp    %ebx,0xc(%ebp)
f0101a9d:	8d 76 00             	lea    0x0(%esi),%esi
f0101aa0:	7f 14                	jg     f0101ab6 <page_alloc_npages+0xab>
             fflag = 1;
             newPage = &pages[i];
f0101aa2:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101aa5:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0101aa8:	8d 1c c2             	lea    (%edx,%eax,8),%ebx
        }
        if(fflag == 0)
           return NULL;
        struct Page* tmp = page_free_list;
        while(tmp != NULL){
            if(tmp->pp_link >= &newPage[0] && tmp->pp_link <= &newPage[n-1])
f0101aab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0101aae:	8d 7c cb f8          	lea    -0x8(%ebx,%ecx,8),%edi
f0101ab2:	89 f2                	mov    %esi,%edx
f0101ab4:	eb 2f                	jmp    f0101ae5 <page_alloc_npages+0xda>
        if(n <= 0){
            return newPage;
        }
        if(page_free_list == NULL)
            return newPage;
        for(i = 0; i+n-1 <npages;i++){
f0101ab6:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
f0101aba:	83 45 e4 08          	addl   $0x8,-0x1c(%ebp)
f0101abe:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0101ac1:	03 45 e0             	add    -0x20(%ebp),%eax
f0101ac4:	3b 45 dc             	cmp    -0x24(%ebp),%eax
f0101ac7:	0f 83 b8 00 00 00    	jae    f0101b85 <page_alloc_npages+0x17a>
f0101acd:	8b 55 e4             	mov    -0x1c(%ebp),%edx
           for(j = 0;j<n;j++){
              struct Page* tmpFree = page_free_list;
              flag = 0;
              if(pages[i+j].pp_ref != 0)
f0101ad0:	66 83 7a 04 00       	cmpw   $0x0,0x4(%edx)
f0101ad5:	75 df                	jne    f0101ab6 <page_alloc_npages+0xab>
f0101ad7:	89 d1                	mov    %edx,%ecx
f0101ad9:	83 c1 08             	add    $0x8,%ecx
f0101adc:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101ae1:	eb 90                	jmp    f0101a73 <page_alloc_npages+0x68>
f0101ae3:	89 c2                	mov    %eax,%edx
        }
        if(fflag == 0)
           return NULL;
        struct Page* tmp = page_free_list;
        while(tmp != NULL){
            if(tmp->pp_link >= &newPage[0] && tmp->pp_link <= &newPage[n-1])
f0101ae5:	8b 02                	mov    (%edx),%eax
f0101ae7:	39 c3                	cmp    %eax,%ebx
f0101ae9:	77 0a                	ja     f0101af5 <page_alloc_npages+0xea>
f0101aeb:	39 f8                	cmp    %edi,%eax
f0101aed:	77 06                	ja     f0101af5 <page_alloc_npages+0xea>
                 tmp->pp_link = tmp->pp_link->pp_link;
f0101aef:	8b 00                	mov    (%eax),%eax
f0101af1:	89 02                	mov    %eax,(%edx)
f0101af3:	89 d0                	mov    %edx,%eax
           }               
        }
        if(fflag == 0)
           return NULL;
        struct Page* tmp = page_free_list;
        while(tmp != NULL){
f0101af5:	85 c0                	test   %eax,%eax
f0101af7:	75 ea                	jne    f0101ae3 <page_alloc_npages+0xd8>
            if(tmp->pp_link >= &newPage[0] && tmp->pp_link <= &newPage[n-1])
                 tmp->pp_link = tmp->pp_link->pp_link;
            else
                 tmp = tmp->pp_link;
        }
        if(page_free_list >= &newPage[0] && page_free_list <= &newPage[n-1]){
f0101af9:	39 de                	cmp    %ebx,%esi
f0101afb:	72 0b                	jb     f0101b08 <page_alloc_npages+0xfd>
f0101afd:	39 fe                	cmp    %edi,%esi
f0101aff:	77 07                	ja     f0101b08 <page_alloc_npages+0xfd>
           page_free_list = page_free_list->pp_link;
f0101b01:	8b 06                	mov    (%esi),%eax
f0101b03:	a3 50 02 1f f0       	mov    %eax,0xf01f0250
        }
         for(i = 0;i<n-1;i++){
f0101b08:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f0101b0c:	7e 15                	jle    f0101b23 <page_alloc_npages+0x118>
f0101b0e:	8d 43 08             	lea    0x8(%ebx),%eax
f0101b11:	ba 01 00 00 00       	mov    $0x1,%edx
             newPage[i].pp_link = &newPage[i+1];
f0101b16:	89 40 f8             	mov    %eax,-0x8(%eax)
f0101b19:	83 c2 01             	add    $0x1,%edx
f0101b1c:	83 c0 08             	add    $0x8,%eax
                 tmp = tmp->pp_link;
        }
        if(page_free_list >= &newPage[0] && page_free_list <= &newPage[n-1]){
           page_free_list = page_free_list->pp_link;
        }
         for(i = 0;i<n-1;i++){
f0101b1f:	39 d1                	cmp    %edx,%ecx
f0101b21:	75 f3                	jne    f0101b16 <page_alloc_npages+0x10b>
             newPage[i].pp_link = &newPage[i+1];
         }
         if(alloc_flags & ALLOC_ZERO){
f0101b23:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0101b27:	74 61                	je     f0101b8a <page_alloc_npages+0x17f>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0101b29:	89 d8                	mov    %ebx,%eax
f0101b2b:	2b 05 b0 0e 1f f0    	sub    0xf01f0eb0,%eax
f0101b31:	c1 f8 03             	sar    $0x3,%eax
f0101b34:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101b37:	89 c2                	mov    %eax,%edx
f0101b39:	c1 ea 0c             	shr    $0xc,%edx
f0101b3c:	3b 15 a8 0e 1f f0    	cmp    0xf01f0ea8,%edx
f0101b42:	72 20                	jb     f0101b64 <page_alloc_npages+0x159>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101b44:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101b48:	c7 44 24 08 80 80 10 	movl   $0xf0108080,0x8(%esp)
f0101b4f:	f0 
f0101b50:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0101b57:	00 
f0101b58:	c7 04 24 32 88 10 f0 	movl   $0xf0108832,(%esp)
f0101b5f:	e8 21 e5 ff ff       	call   f0100085 <_panic>
           char* addr = page2kva(newPage);
           memset(addr,0,PGSIZE*n);
f0101b64:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101b67:	c1 e2 0c             	shl    $0xc,%edx
f0101b6a:	89 54 24 08          	mov    %edx,0x8(%esp)
f0101b6e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101b75:	00 
f0101b76:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101b7b:	89 04 24             	mov    %eax,(%esp)
f0101b7e:	e8 a3 56 00 00       	call   f0107226 <memset>
f0101b83:	eb 05                	jmp    f0101b8a <page_alloc_npages+0x17f>
f0101b85:	bb 00 00 00 00       	mov    $0x0,%ebx
         }           
        return newPage; 
}
f0101b8a:	89 d8                	mov    %ebx,%eax
f0101b8c:	83 c4 3c             	add    $0x3c,%esp
f0101b8f:	5b                   	pop    %ebx
f0101b90:	5e                   	pop    %esi
f0101b91:	5f                   	pop    %edi
f0101b92:	5d                   	pop    %ebp
f0101b93:	c3                   	ret    

f0101b94 <page_realloc_npages>:
// You can man realloc for better understanding.
// (Try to reuse the allocated pages as many as possible.)
//
struct Page *
page_realloc_npages(struct Page *pp, int old_n, int new_n)
{
f0101b94:	55                   	push   %ebp
f0101b95:	89 e5                	mov    %esp,%ebp
f0101b97:	83 ec 38             	sub    $0x38,%esp
f0101b9a:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0101b9d:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0101ba0:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0101ba3:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0101ba6:	8b 45 0c             	mov    0xc(%ebp),%eax
	// Fill this function
        if(old_n <= 0 || new_n <= 0)
f0101ba9:	85 c0                	test   %eax,%eax
f0101bab:	0f 8e d2 00 00 00    	jle    f0101c83 <page_realloc_npages+0xef>
f0101bb1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0101bb5:	0f 8e c8 00 00 00    	jle    f0101c83 <page_realloc_npages+0xef>
static int
check_continuous(struct Page *pp, int num_page)
{
	struct Page *tmp; 
	int i;
	for( tmp = pp, i = 0; i < num_page - 1; tmp = tmp->pp_link, i++ )
f0101bbb:	8d 50 ff             	lea    -0x1(%eax),%edx
f0101bbe:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0101bc1:	85 d2                	test   %edx,%edx
f0101bc3:	0f 8e ce 00 00 00    	jle    f0101c97 <page_realloc_npages+0x103>
	{
		if(tmp == NULL) 
f0101bc9:	85 db                	test   %ebx,%ebx
f0101bcb:	0f 84 b7 00 00 00    	je     f0101c88 <page_realloc_npages+0xf4>
		{
			return 0;
		}
		if( (page2pa(tmp->pp_link) - page2pa(tmp)) != PGSIZE )
f0101bd1:	8b 13                	mov    (%ebx),%edx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0101bd3:	8b 3d b0 0e 1f f0    	mov    0xf01f0eb0,%edi
f0101bd9:	89 d1                	mov    %edx,%ecx
f0101bdb:	29 f9                	sub    %edi,%ecx
f0101bdd:	c1 f9 03             	sar    $0x3,%ecx
f0101be0:	89 de                	mov    %ebx,%esi
f0101be2:	29 fe                	sub    %edi,%esi
f0101be4:	c1 fe 03             	sar    $0x3,%esi
f0101be7:	29 f1                	sub    %esi,%ecx
f0101be9:	89 ce                	mov    %ecx,%esi
f0101beb:	c1 e6 0c             	shl    $0xc,%esi
f0101bee:	b9 00 00 00 00       	mov    $0x0,%ecx
f0101bf3:	81 fe 00 10 00 00    	cmp    $0x1000,%esi
f0101bf9:	74 28                	je     f0101c23 <page_realloc_npages+0x8f>
f0101bfb:	e9 83 00 00 00       	jmp    f0101c83 <page_realloc_npages+0xef>
{
	struct Page *tmp; 
	int i;
	for( tmp = pp, i = 0; i < num_page - 1; tmp = tmp->pp_link, i++ )
	{
		if(tmp == NULL) 
f0101c00:	85 d2                	test   %edx,%edx
f0101c02:	74 7f                	je     f0101c83 <page_realloc_npages+0xef>
		{
			return 0;
		}
		if( (page2pa(tmp->pp_link) - page2pa(tmp)) != PGSIZE )
f0101c04:	8b 02                	mov    (%edx),%eax
f0101c06:	89 c3                	mov    %eax,%ebx
f0101c08:	29 fb                	sub    %edi,%ebx
f0101c0a:	c1 fb 03             	sar    $0x3,%ebx
f0101c0d:	29 fa                	sub    %edi,%edx
f0101c0f:	c1 fa 03             	sar    $0x3,%edx
f0101c12:	29 d3                	sub    %edx,%ebx
f0101c14:	c1 e3 0c             	shl    $0xc,%ebx
f0101c17:	81 fb 00 10 00 00    	cmp    $0x1000,%ebx
f0101c1d:	75 64                	jne    f0101c83 <page_realloc_npages+0xef>
f0101c1f:	89 c2                	mov    %eax,%edx
f0101c21:	eb 09                	jmp    f0101c2c <page_realloc_npages+0x98>
f0101c23:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0101c26:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0101c29:	89 45 e0             	mov    %eax,-0x20(%ebp)
static int
check_continuous(struct Page *pp, int num_page)
{
	struct Page *tmp; 
	int i;
	for( tmp = pp, i = 0; i < num_page - 1; tmp = tmp->pp_link, i++ )
f0101c2c:	83 c1 01             	add    $0x1,%ecx
f0101c2f:	39 ce                	cmp    %ecx,%esi
f0101c31:	7f cd                	jg     f0101c00 <page_realloc_npages+0x6c>
f0101c33:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0101c36:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101c39:	eb 5c                	jmp    f0101c97 <page_realloc_npages+0x103>
            return NULL;
        if(!check_continuous(pp,old_n))
            return NULL;
        if(old_n == new_n)
            return pp;
        if(old_n > new_n){
f0101c3b:	3b 45 10             	cmp    0x10(%ebp),%eax
f0101c3e:	7e 20                	jle    f0101c60 <page_realloc_npages+0xcc>
           struct Page* lastPage = &pp[new_n-1];
f0101c40:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0101c43:	8d 54 cb f8          	lea    -0x8(%ebx,%ecx,8),%edx
           lastPage->pp_link = NULL;
f0101c47:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
           page_free_npages(&lastPage[1],old_n-new_n);
f0101c4d:	29 c8                	sub    %ecx,%eax
f0101c4f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101c53:	83 c2 08             	add    $0x8,%edx
f0101c56:	89 14 24             	mov    %edx,(%esp)
f0101c59:	e8 22 fa ff ff       	call   f0101680 <page_free_npages>
           return pp;
f0101c5e:	eb 28                	jmp    f0101c88 <page_realloc_npages+0xf4>
        }
        else{
           struct Page* newPage;
           page_free_npages(pp,old_n);
f0101c60:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101c64:	89 1c 24             	mov    %ebx,(%esp)
f0101c67:	e8 14 fa ff ff       	call   f0101680 <page_free_npages>
           newPage = page_alloc_npages(0,new_n);
f0101c6c:	8b 45 10             	mov    0x10(%ebp),%eax
f0101c6f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101c73:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101c7a:	e8 8c fd ff ff       	call   f0101a0b <page_alloc_npages>
f0101c7f:	89 c3                	mov    %eax,%ebx
           return newPage;
f0101c81:	eb 05                	jmp    f0101c88 <page_realloc_npages+0xf4>
f0101c83:	bb 00 00 00 00       	mov    $0x0,%ebx
        }
	return NULL;
}
f0101c88:	89 d8                	mov    %ebx,%eax
f0101c8a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0101c8d:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0101c90:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0101c93:	89 ec                	mov    %ebp,%esp
f0101c95:	5d                   	pop    %ebp
f0101c96:	c3                   	ret    
	// Fill this function
        if(old_n <= 0 || new_n <= 0)
            return NULL;
        if(!check_continuous(pp,old_n))
            return NULL;
        if(old_n == new_n)
f0101c97:	3b 45 10             	cmp    0x10(%ebp),%eax
f0101c9a:	75 9f                	jne    f0101c3b <page_realloc_npages+0xa7>
f0101c9c:	eb ea                	jmp    f0101c88 <page_realloc_npages+0xf4>

f0101c9e <check_va2pa>:
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0101c9e:	55                   	push   %ebp
f0101c9f:	89 e5                	mov    %esp,%ebp
f0101ca1:	83 ec 18             	sub    $0x18,%esp
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
f0101ca4:	89 d1                	mov    %edx,%ecx
f0101ca6:	c1 e9 16             	shr    $0x16,%ecx
f0101ca9:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0101cac:	a8 01                	test   $0x1,%al
f0101cae:	74 4d                	je     f0101cfd <check_va2pa+0x5f>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0101cb0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101cb5:	89 c1                	mov    %eax,%ecx
f0101cb7:	c1 e9 0c             	shr    $0xc,%ecx
f0101cba:	3b 0d a8 0e 1f f0    	cmp    0xf01f0ea8,%ecx
f0101cc0:	72 20                	jb     f0101ce2 <check_va2pa+0x44>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101cc2:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101cc6:	c7 44 24 08 80 80 10 	movl   $0xf0108080,0x8(%esp)
f0101ccd:	f0 
f0101cce:	c7 44 24 04 1a 04 00 	movl   $0x41a,0x4(%esp)
f0101cd5:	00 
f0101cd6:	c7 04 24 26 88 10 f0 	movl   $0xf0108826,(%esp)
f0101cdd:	e8 a3 e3 ff ff       	call   f0100085 <_panic>
	if (!(p[PTX(va)] & PTE_P))
f0101ce2:	c1 ea 0c             	shr    $0xc,%edx
f0101ce5:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0101ceb:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0101cf2:	a8 01                	test   $0x1,%al
f0101cf4:	74 07                	je     f0101cfd <check_va2pa+0x5f>
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0101cf6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0101cfb:	eb 05                	jmp    f0101d02 <check_va2pa+0x64>
f0101cfd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f0101d02:	c9                   	leave  
f0101d03:	c3                   	ret    

f0101d04 <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0101d04:	55                   	push   %ebp
f0101d05:	89 e5                	mov    %esp,%ebp
f0101d07:	57                   	push   %edi
f0101d08:	56                   	push   %esi
f0101d09:	53                   	push   %ebx
f0101d0a:	83 ec 5c             	sub    $0x5c,%esp
	struct Page *pp;
	int pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0101d0d:	83 f8 01             	cmp    $0x1,%eax
f0101d10:	19 f6                	sbb    %esi,%esi
f0101d12:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
f0101d18:	83 c6 01             	add    $0x1,%esi
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0101d1b:	8b 1d 50 02 1f f0    	mov    0xf01f0250,%ebx
f0101d21:	85 db                	test   %ebx,%ebx
f0101d23:	75 1c                	jne    f0101d41 <check_page_free_list+0x3d>
		panic("'page_free_list' is a null pointer!");
f0101d25:	c7 44 24 08 74 8b 10 	movl   $0xf0108b74,0x8(%esp)
f0101d2c:	f0 
f0101d2d:	c7 44 24 04 46 03 00 	movl   $0x346,0x4(%esp)
f0101d34:	00 
f0101d35:	c7 04 24 26 88 10 f0 	movl   $0xf0108826,(%esp)
f0101d3c:	e8 44 e3 ff ff       	call   f0100085 <_panic>

	if (only_low_memory) {
f0101d41:	85 c0                	test   %eax,%eax
f0101d43:	74 52                	je     f0101d97 <check_page_free_list+0x93>
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct Page *pp1, *pp2;
		struct Page **tp[2] = { &pp1, &pp2 };
f0101d45:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101d48:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0101d4b:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0101d4e:	89 45 dc             	mov    %eax,-0x24(%ebp)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0101d51:	8b 0d b0 0e 1f f0    	mov    0xf01f0eb0,%ecx
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0101d57:	89 d8                	mov    %ebx,%eax
f0101d59:	29 c8                	sub    %ecx,%eax
f0101d5b:	c1 e0 09             	shl    $0x9,%eax
f0101d5e:	c1 e8 16             	shr    $0x16,%eax
f0101d61:	39 f0                	cmp    %esi,%eax
f0101d63:	0f 93 c0             	setae  %al
f0101d66:	0f b6 c0             	movzbl %al,%eax
			*tp[pagetype] = pp;
f0101d69:	8b 54 85 d8          	mov    -0x28(%ebp,%eax,4),%edx
f0101d6d:	89 1a                	mov    %ebx,(%edx)
			tp[pagetype] = &pp->pp_link;
f0101d6f:	89 5c 85 d8          	mov    %ebx,-0x28(%ebp,%eax,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct Page *pp1, *pp2;
		struct Page **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0101d73:	8b 1b                	mov    (%ebx),%ebx
f0101d75:	85 db                	test   %ebx,%ebx
f0101d77:	75 de                	jne    f0101d57 <check_page_free_list+0x53>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0101d79:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0101d7c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0101d82:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0101d85:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0101d88:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0101d8a:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0101d8d:	89 1d 50 02 1f f0    	mov    %ebx,0xf01f0250
	}
	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link){
f0101d93:	85 db                	test   %ebx,%ebx
f0101d95:	74 67                	je     f0101dfe <check_page_free_list+0xfa>
f0101d97:	89 d8                	mov    %ebx,%eax
f0101d99:	2b 05 b0 0e 1f f0    	sub    0xf01f0eb0,%eax
f0101d9f:	c1 f8 03             	sar    $0x3,%eax
f0101da2:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0101da5:	89 c2                	mov    %eax,%edx
f0101da7:	c1 ea 16             	shr    $0x16,%edx
f0101daa:	39 f2                	cmp    %esi,%edx
f0101dac:	73 4a                	jae    f0101df8 <check_page_free_list+0xf4>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101dae:	89 c2                	mov    %eax,%edx
f0101db0:	c1 ea 0c             	shr    $0xc,%edx
f0101db3:	3b 15 a8 0e 1f f0    	cmp    0xf01f0ea8,%edx
f0101db9:	72 20                	jb     f0101ddb <check_page_free_list+0xd7>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101dbb:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101dbf:	c7 44 24 08 80 80 10 	movl   $0xf0108080,0x8(%esp)
f0101dc6:	f0 
f0101dc7:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0101dce:	00 
f0101dcf:	c7 04 24 32 88 10 f0 	movl   $0xf0108832,(%esp)
f0101dd6:	e8 aa e2 ff ff       	call   f0100085 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0101ddb:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
f0101de2:	00 
f0101de3:	c7 44 24 04 97 00 00 	movl   $0x97,0x4(%esp)
f0101dea:	00 
f0101deb:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101df0:	89 04 24             	mov    %eax,(%esp)
f0101df3:	e8 2e 54 00 00       	call   f0107226 <memset>
		*tp[0] = pp2;
		page_free_list = pp1;
	}
	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link){
f0101df8:	8b 1b                	mov    (%ebx),%ebx
f0101dfa:	85 db                	test   %ebx,%ebx
f0101dfc:	75 99                	jne    f0101d97 <check_page_free_list+0x93>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);
	}
	first_free_page = (char *) boot_alloc(0);
f0101dfe:	b8 00 00 00 00       	mov    $0x0,%eax
f0101e03:	e8 71 f9 ff ff       	call   f0101779 <boot_alloc>
f0101e08:	89 45 c4             	mov    %eax,-0x3c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0101e0b:	8b 15 50 02 1f f0    	mov    0xf01f0250,%edx
f0101e11:	85 d2                	test   %edx,%edx
f0101e13:	0f 84 3a 02 00 00    	je     f0102053 <check_page_free_list+0x34f>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0101e19:	8b 1d b0 0e 1f f0    	mov    0xf01f0eb0,%ebx
f0101e1f:	39 da                	cmp    %ebx,%edx
f0101e21:	72 4f                	jb     f0101e72 <check_page_free_list+0x16e>
		assert(pp < pages + npages);
f0101e23:	a1 a8 0e 1f f0       	mov    0xf01f0ea8,%eax
f0101e28:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0101e2b:	8d 04 c3             	lea    (%ebx,%eax,8),%eax
f0101e2e:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101e31:	39 c2                	cmp    %eax,%edx
f0101e33:	73 66                	jae    f0101e9b <check_page_free_list+0x197>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0101e35:	89 5d cc             	mov    %ebx,-0x34(%ebp)
f0101e38:	89 d0                	mov    %edx,%eax
f0101e3a:	29 d8                	sub    %ebx,%eax
f0101e3c:	a8 07                	test   $0x7,%al
f0101e3e:	0f 85 84 00 00 00    	jne    f0101ec8 <check_page_free_list+0x1c4>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0101e44:	c1 f8 03             	sar    $0x3,%eax
f0101e47:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0101e4a:	85 c0                	test   %eax,%eax
f0101e4c:	0f 84 a4 00 00 00    	je     f0101ef6 <check_page_free_list+0x1f2>
		assert(page2pa(pp) != IOPHYSMEM);
f0101e52:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0101e57:	0f 84 c4 00 00 00    	je     f0101f21 <check_page_free_list+0x21d>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0101e5d:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0101e62:	0f 85 08 01 00 00    	jne    f0101f70 <check_page_free_list+0x26c>
f0101e68:	e9 df 00 00 00       	jmp    f0101f4c <check_page_free_list+0x248>
			memset(page2kva(pp), 0x97, 128);
	}
	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0101e6d:	3b 55 b4             	cmp    -0x4c(%ebp),%edx
f0101e70:	73 24                	jae    f0101e96 <check_page_free_list+0x192>
f0101e72:	c7 44 24 0c 40 88 10 	movl   $0xf0108840,0xc(%esp)
f0101e79:	f0 
f0101e7a:	c7 44 24 08 4c 88 10 	movl   $0xf010884c,0x8(%esp)
f0101e81:	f0 
f0101e82:	c7 44 24 04 5f 03 00 	movl   $0x35f,0x4(%esp)
f0101e89:	00 
f0101e8a:	c7 04 24 26 88 10 f0 	movl   $0xf0108826,(%esp)
f0101e91:	e8 ef e1 ff ff       	call   f0100085 <_panic>
		assert(pp < pages + npages);
f0101e96:	3b 55 d0             	cmp    -0x30(%ebp),%edx
f0101e99:	72 24                	jb     f0101ebf <check_page_free_list+0x1bb>
f0101e9b:	c7 44 24 0c 61 88 10 	movl   $0xf0108861,0xc(%esp)
f0101ea2:	f0 
f0101ea3:	c7 44 24 08 4c 88 10 	movl   $0xf010884c,0x8(%esp)
f0101eaa:	f0 
f0101eab:	c7 44 24 04 60 03 00 	movl   $0x360,0x4(%esp)
f0101eb2:	00 
f0101eb3:	c7 04 24 26 88 10 f0 	movl   $0xf0108826,(%esp)
f0101eba:	e8 c6 e1 ff ff       	call   f0100085 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0101ebf:	89 d0                	mov    %edx,%eax
f0101ec1:	2b 45 cc             	sub    -0x34(%ebp),%eax
f0101ec4:	a8 07                	test   $0x7,%al
f0101ec6:	74 24                	je     f0101eec <check_page_free_list+0x1e8>
f0101ec8:	c7 44 24 0c 98 8b 10 	movl   $0xf0108b98,0xc(%esp)
f0101ecf:	f0 
f0101ed0:	c7 44 24 08 4c 88 10 	movl   $0xf010884c,0x8(%esp)
f0101ed7:	f0 
f0101ed8:	c7 44 24 04 61 03 00 	movl   $0x361,0x4(%esp)
f0101edf:	00 
f0101ee0:	c7 04 24 26 88 10 f0 	movl   $0xf0108826,(%esp)
f0101ee7:	e8 99 e1 ff ff       	call   f0100085 <_panic>
f0101eec:	c1 f8 03             	sar    $0x3,%eax
f0101eef:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0101ef2:	85 c0                	test   %eax,%eax
f0101ef4:	75 24                	jne    f0101f1a <check_page_free_list+0x216>
f0101ef6:	c7 44 24 0c 75 88 10 	movl   $0xf0108875,0xc(%esp)
f0101efd:	f0 
f0101efe:	c7 44 24 08 4c 88 10 	movl   $0xf010884c,0x8(%esp)
f0101f05:	f0 
f0101f06:	c7 44 24 04 64 03 00 	movl   $0x364,0x4(%esp)
f0101f0d:	00 
f0101f0e:	c7 04 24 26 88 10 f0 	movl   $0xf0108826,(%esp)
f0101f15:	e8 6b e1 ff ff       	call   f0100085 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0101f1a:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0101f1f:	75 24                	jne    f0101f45 <check_page_free_list+0x241>
f0101f21:	c7 44 24 0c 86 88 10 	movl   $0xf0108886,0xc(%esp)
f0101f28:	f0 
f0101f29:	c7 44 24 08 4c 88 10 	movl   $0xf010884c,0x8(%esp)
f0101f30:	f0 
f0101f31:	c7 44 24 04 65 03 00 	movl   $0x365,0x4(%esp)
f0101f38:	00 
f0101f39:	c7 04 24 26 88 10 f0 	movl   $0xf0108826,(%esp)
f0101f40:	e8 40 e1 ff ff       	call   f0100085 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0101f45:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0101f4a:	75 31                	jne    f0101f7d <check_page_free_list+0x279>
f0101f4c:	c7 44 24 0c cc 8b 10 	movl   $0xf0108bcc,0xc(%esp)
f0101f53:	f0 
f0101f54:	c7 44 24 08 4c 88 10 	movl   $0xf010884c,0x8(%esp)
f0101f5b:	f0 
f0101f5c:	c7 44 24 04 66 03 00 	movl   $0x366,0x4(%esp)
f0101f63:	00 
f0101f64:	c7 04 24 26 88 10 f0 	movl   $0xf0108826,(%esp)
f0101f6b:	e8 15 e1 ff ff       	call   f0100085 <_panic>
f0101f70:	be 00 00 00 00       	mov    $0x0,%esi
f0101f75:	bf 00 00 00 00       	mov    $0x0,%edi
f0101f7a:	89 5d b4             	mov    %ebx,-0x4c(%ebp)
		assert(page2pa(pp) != EXTPHYSMEM);
f0101f7d:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0101f82:	75 24                	jne    f0101fa8 <check_page_free_list+0x2a4>
f0101f84:	c7 44 24 0c 9f 88 10 	movl   $0xf010889f,0xc(%esp)
f0101f8b:	f0 
f0101f8c:	c7 44 24 08 4c 88 10 	movl   $0xf010884c,0x8(%esp)
f0101f93:	f0 
f0101f94:	c7 44 24 04 67 03 00 	movl   $0x367,0x4(%esp)
f0101f9b:	00 
f0101f9c:	c7 04 24 26 88 10 f0 	movl   $0xf0108826,(%esp)
f0101fa3:	e8 dd e0 ff ff       	call   f0100085 <_panic>
f0101fa8:	89 c1                	mov    %eax,%ecx
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0101faa:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0101faf:	76 59                	jbe    f010200a <check_page_free_list+0x306>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101fb1:	89 c3                	mov    %eax,%ebx
f0101fb3:	c1 eb 0c             	shr    $0xc,%ebx
f0101fb6:	39 5d c8             	cmp    %ebx,-0x38(%ebp)
f0101fb9:	77 20                	ja     f0101fdb <check_page_free_list+0x2d7>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101fbb:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101fbf:	c7 44 24 08 80 80 10 	movl   $0xf0108080,0x8(%esp)
f0101fc6:	f0 
f0101fc7:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0101fce:	00 
f0101fcf:	c7 04 24 32 88 10 f0 	movl   $0xf0108832,(%esp)
f0101fd6:	e8 aa e0 ff ff       	call   f0100085 <_panic>
f0101fdb:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
f0101fe1:	39 5d c4             	cmp    %ebx,-0x3c(%ebp)
f0101fe4:	76 24                	jbe    f010200a <check_page_free_list+0x306>
f0101fe6:	c7 44 24 0c f0 8b 10 	movl   $0xf0108bf0,0xc(%esp)
f0101fed:	f0 
f0101fee:	c7 44 24 08 4c 88 10 	movl   $0xf010884c,0x8(%esp)
f0101ff5:	f0 
f0101ff6:	c7 44 24 04 68 03 00 	movl   $0x368,0x4(%esp)
f0101ffd:	00 
f0101ffe:	c7 04 24 26 88 10 f0 	movl   $0xf0108826,(%esp)
f0102005:	e8 7b e0 ff ff       	call   f0100085 <_panic>
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f010200a:	3d 00 70 00 00       	cmp    $0x7000,%eax
f010200f:	75 24                	jne    f0102035 <check_page_free_list+0x331>
f0102011:	c7 44 24 0c b9 88 10 	movl   $0xf01088b9,0xc(%esp)
f0102018:	f0 
f0102019:	c7 44 24 08 4c 88 10 	movl   $0xf010884c,0x8(%esp)
f0102020:	f0 
f0102021:	c7 44 24 04 6a 03 00 	movl   $0x36a,0x4(%esp)
f0102028:	00 
f0102029:	c7 04 24 26 88 10 f0 	movl   $0xf0108826,(%esp)
f0102030:	e8 50 e0 ff ff       	call   f0100085 <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
f0102035:	81 f9 ff ff 0f 00    	cmp    $0xfffff,%ecx
f010203b:	77 05                	ja     f0102042 <check_page_free_list+0x33e>
			++nfree_basemem;
f010203d:	83 c7 01             	add    $0x1,%edi
f0102040:	eb 03                	jmp    f0102045 <check_page_free_list+0x341>
		else
			++nfree_extmem;
f0102042:	83 c6 01             	add    $0x1,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link){
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);
	}
	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0102045:	8b 12                	mov    (%edx),%edx
f0102047:	85 d2                	test   %edx,%edx
f0102049:	0f 85 1e fe ff ff    	jne    f0101e6d <check_page_free_list+0x169>
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f010204f:	85 ff                	test   %edi,%edi
f0102051:	7f 24                	jg     f0102077 <check_page_free_list+0x373>
f0102053:	c7 44 24 0c d6 88 10 	movl   $0xf01088d6,0xc(%esp)
f010205a:	f0 
f010205b:	c7 44 24 08 4c 88 10 	movl   $0xf010884c,0x8(%esp)
f0102062:	f0 
f0102063:	c7 44 24 04 72 03 00 	movl   $0x372,0x4(%esp)
f010206a:	00 
f010206b:	c7 04 24 26 88 10 f0 	movl   $0xf0108826,(%esp)
f0102072:	e8 0e e0 ff ff       	call   f0100085 <_panic>
	assert(nfree_extmem > 0);
f0102077:	85 f6                	test   %esi,%esi
f0102079:	7f 24                	jg     f010209f <check_page_free_list+0x39b>
f010207b:	c7 44 24 0c e8 88 10 	movl   $0xf01088e8,0xc(%esp)
f0102082:	f0 
f0102083:	c7 44 24 08 4c 88 10 	movl   $0xf010884c,0x8(%esp)
f010208a:	f0 
f010208b:	c7 44 24 04 73 03 00 	movl   $0x373,0x4(%esp)
f0102092:	00 
f0102093:	c7 04 24 26 88 10 f0 	movl   $0xf0108826,(%esp)
f010209a:	e8 e6 df ff ff       	call   f0100085 <_panic>
        //cprintf("check_page_free_list() succeeded!\n");
}
f010209f:	83 c4 5c             	add    $0x5c,%esp
f01020a2:	5b                   	pop    %ebx
f01020a3:	5e                   	pop    %esi
f01020a4:	5f                   	pop    %edi
f01020a5:	5d                   	pop    %ebp
f01020a6:	c3                   	ret    

f01020a7 <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct Page *
page_alloc(int alloc_flags)
{
f01020a7:	55                   	push   %ebp
f01020a8:	89 e5                	mov    %esp,%ebp
f01020aa:	53                   	push   %ebx
f01020ab:	83 ec 14             	sub    $0x14,%esp
	// Fill this function in
        struct Page* newPage = NULL;
        if(!page_free_list){
f01020ae:	8b 1d 50 02 1f f0    	mov    0xf01f0250,%ebx
f01020b4:	85 db                	test   %ebx,%ebx
f01020b6:	74 65                	je     f010211d <page_alloc+0x76>
            return newPage;
        }
        newPage = page_free_list;
        page_free_list = page_free_list->pp_link;
f01020b8:	8b 03                	mov    (%ebx),%eax
f01020ba:	a3 50 02 1f f0       	mov    %eax,0xf01f0250
        if(alloc_flags & ALLOC_ZERO){
f01020bf:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f01020c3:	74 58                	je     f010211d <page_alloc+0x76>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f01020c5:	89 d8                	mov    %ebx,%eax
f01020c7:	2b 05 b0 0e 1f f0    	sub    0xf01f0eb0,%eax
f01020cd:	c1 f8 03             	sar    $0x3,%eax
f01020d0:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01020d3:	89 c2                	mov    %eax,%edx
f01020d5:	c1 ea 0c             	shr    $0xc,%edx
f01020d8:	3b 15 a8 0e 1f f0    	cmp    0xf01f0ea8,%edx
f01020de:	72 20                	jb     f0102100 <page_alloc+0x59>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01020e0:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01020e4:	c7 44 24 08 80 80 10 	movl   $0xf0108080,0x8(%esp)
f01020eb:	f0 
f01020ec:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f01020f3:	00 
f01020f4:	c7 04 24 32 88 10 f0 	movl   $0xf0108832,(%esp)
f01020fb:	e8 85 df ff ff       	call   f0100085 <_panic>
           char* addr = page2kva(newPage);
           memset(addr,0,PGSIZE);
f0102100:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102107:	00 
f0102108:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010210f:	00 
f0102110:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102115:	89 04 24             	mov    %eax,(%esp)
f0102118:	e8 09 51 00 00       	call   f0107226 <memset>
        } 
        return newPage;  
}
f010211d:	89 d8                	mov    %ebx,%eax
f010211f:	83 c4 14             	add    $0x14,%esp
f0102122:	5b                   	pop    %ebx
f0102123:	5d                   	pop    %ebp
f0102124:	c3                   	ret    

f0102125 <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f0102125:	55                   	push   %ebp
f0102126:	89 e5                	mov    %esp,%ebp
f0102128:	83 ec 18             	sub    $0x18,%esp
f010212b:	89 5d f8             	mov    %ebx,-0x8(%ebp)
f010212e:	89 75 fc             	mov    %esi,-0x4(%ebp)
	// Fill this function in
        pde_t* pde = NULL;
        physaddr_t pt;    //physical address
        pte_t* vpt = NULL;
        pde = &pgdir[PDX(va)];
f0102131:	8b 75 0c             	mov    0xc(%ebp),%esi
f0102134:	89 f3                	mov    %esi,%ebx
f0102136:	c1 eb 16             	shr    $0x16,%ebx
f0102139:	c1 e3 02             	shl    $0x2,%ebx
f010213c:	03 5d 08             	add    0x8(%ebp),%ebx
        if((*pde) & PTE_PS)
f010213f:	8b 03                	mov    (%ebx),%eax
f0102141:	84 c0                	test   %al,%al
f0102143:	0f 88 86 00 00 00    	js     f01021cf <pgdir_walk+0xaa>
            return &pgdir[PDX(va)];
        if((!((*pde) & PTE_P)) && create == 0)
f0102149:	89 c2                	mov    %eax,%edx
f010214b:	83 e2 01             	and    $0x1,%edx
f010214e:	75 06                	jne    f0102156 <pgdir_walk+0x31>
f0102150:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0102154:	74 74                	je     f01021ca <pgdir_walk+0xa5>
           return NULL;
        else if(!((*pde) & PTE_P)){
f0102156:	85 d2                	test   %edx,%edx
f0102158:	75 2c                	jne    f0102186 <pgdir_walk+0x61>
           struct Page* page = NULL;
           if(!(page = page_alloc(ALLOC_ZERO)))
f010215a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0102161:	e8 41 ff ff ff       	call   f01020a7 <page_alloc>
f0102166:	89 c2                	mov    %eax,%edx
f0102168:	85 c0                	test   %eax,%eax
f010216a:	74 5e                	je     f01021ca <pgdir_walk+0xa5>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f010216c:	2b 05 b0 0e 1f f0    	sub    0xf01f0eb0,%eax
f0102172:	c1 f8 03             	sar    $0x3,%eax
f0102175:	c1 e0 0c             	shl    $0xc,%eax
              return NULL;
           pt = page2pa(page);     
           *pde = pt | PTE_P | PTE_W | PTE_U;
f0102178:	89 c1                	mov    %eax,%ecx
f010217a:	83 c9 07             	or     $0x7,%ecx
f010217d:	89 0b                	mov    %ecx,(%ebx)
           page->pp_ref++;
f010217f:	66 83 42 04 01       	addw   $0x1,0x4(%edx)
f0102184:	eb 05                	jmp    f010218b <pgdir_walk+0x66>
        }
        else{
          pt = PTE_ADDR(*pde);
f0102186:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010218b:	89 c2                	mov    %eax,%edx
f010218d:	c1 ea 0c             	shr    $0xc,%edx
f0102190:	3b 15 a8 0e 1f f0    	cmp    0xf01f0ea8,%edx
f0102196:	72 20                	jb     f01021b8 <pgdir_walk+0x93>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102198:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010219c:	c7 44 24 08 80 80 10 	movl   $0xf0108080,0x8(%esp)
f01021a3:	f0 
f01021a4:	c7 44 24 04 4b 02 00 	movl   $0x24b,0x4(%esp)
f01021ab:	00 
f01021ac:	c7 04 24 26 88 10 f0 	movl   $0xf0108826,(%esp)
f01021b3:	e8 cd de ff ff       	call   f0100085 <_panic>
        }
        vpt = (pte_t*)KADDR(pt);          
	return &vpt[PTX(va)];
f01021b8:	c1 ee 0a             	shr    $0xa,%esi
f01021bb:	81 e6 fc 0f 00 00    	and    $0xffc,%esi
f01021c1:	8d 9c 30 00 00 00 f0 	lea    -0x10000000(%eax,%esi,1),%ebx
f01021c8:	eb 05                	jmp    f01021cf <pgdir_walk+0xaa>
f01021ca:	bb 00 00 00 00       	mov    $0x0,%ebx
}
f01021cf:	89 d8                	mov    %ebx,%eax
f01021d1:	8b 5d f8             	mov    -0x8(%ebp),%ebx
f01021d4:	8b 75 fc             	mov    -0x4(%ebp),%esi
f01021d7:	89 ec                	mov    %ebp,%esp
f01021d9:	5d                   	pop    %ebp
f01021da:	c3                   	ret    

f01021db <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f01021db:	55                   	push   %ebp
f01021dc:	89 e5                	mov    %esp,%ebp
f01021de:	57                   	push   %edi
f01021df:	56                   	push   %esi
f01021e0:	53                   	push   %ebx
f01021e1:	83 ec 2c             	sub    $0x2c,%esp
f01021e4:	8b 75 08             	mov    0x8(%ebp),%esi
f01021e7:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 3: Your code here.
        void* begin = ROUNDDOWN((void*)va,PGSIZE);
f01021ea:	8b 45 0c             	mov    0xc(%ebp),%eax
f01021ed:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01021f0:	89 c3                	mov    %eax,%ebx
f01021f2:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
        void* end = ROUNDUP((void*)(va+len),PGSIZE);
f01021f8:	03 45 10             	add    0x10(%ebp),%eax
f01021fb:	05 ff 0f 00 00       	add    $0xfff,%eax
f0102200:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102205:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        while(begin < end){
f0102208:	39 c3                	cmp    %eax,%ebx
f010220a:	73 7e                	jae    f010228a <user_mem_check+0xaf>
           pte_t* pte = pgdir_walk(env->env_pgdir,begin,0);
f010220c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102213:	00 
f0102214:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102218:	8b 46 64             	mov    0x64(%esi),%eax
f010221b:	89 04 24             	mov    %eax,(%esp)
f010221e:	e8 02 ff ff ff       	call   f0102125 <pgdir_walk>
f0102223:	89 da                	mov    %ebx,%edx
           if((uint32_t)begin >= ULIM){
f0102225:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f010222b:	76 21                	jbe    f010224e <user_mem_check+0x73>
                if(begin > va)
f010222d:	39 5d 0c             	cmp    %ebx,0xc(%ebp)
f0102230:	73 0d                	jae    f010223f <user_mem_check+0x64>
                  user_mem_check_addr = (uintptr_t)begin;
f0102232:	89 1d 58 02 1f f0    	mov    %ebx,0xf01f0258
f0102238:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f010223d:	eb 50                	jmp    f010228f <user_mem_check+0xb4>
                else
                  user_mem_check_addr = (uintptr_t)va;
f010223f:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102242:	a3 58 02 1f f0       	mov    %eax,0xf01f0258
f0102247:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f010224c:	eb 41                	jmp    f010228f <user_mem_check+0xb4>
                return -E_FAULT;
           }
           if(!pte || !(*pte & PTE_P) || ((*pte & perm) != perm)){
f010224e:	85 c0                	test   %eax,%eax
f0102250:	74 0c                	je     f010225e <user_mem_check+0x83>
f0102252:	8b 00                	mov    (%eax),%eax
f0102254:	a8 01                	test   $0x1,%al
f0102256:	74 06                	je     f010225e <user_mem_check+0x83>
f0102258:	21 f8                	and    %edi,%eax
f010225a:	39 c7                	cmp    %eax,%edi
f010225c:	74 21                	je     f010227f <user_mem_check+0xa4>
                if(begin > va)
f010225e:	39 5d 0c             	cmp    %ebx,0xc(%ebp)
f0102261:	73 0d                	jae    f0102270 <user_mem_check+0x95>
                  user_mem_check_addr = (uintptr_t)begin;
f0102263:	89 15 58 02 1f f0    	mov    %edx,0xf01f0258
f0102269:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f010226e:	eb 1f                	jmp    f010228f <user_mem_check+0xb4>
                else
                  user_mem_check_addr = (uintptr_t)va;
f0102270:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102273:	a3 58 02 1f f0       	mov    %eax,0xf01f0258
f0102278:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f010227d:	eb 10                	jmp    f010228f <user_mem_check+0xb4>
                return -E_FAULT;
           }
           begin += PGSIZE;
f010227f:	81 c3 00 10 00 00    	add    $0x1000,%ebx
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
	// LAB 3: Your code here.
        void* begin = ROUNDDOWN((void*)va,PGSIZE);
        void* end = ROUNDUP((void*)(va+len),PGSIZE);
        while(begin < end){
f0102285:	39 5d e4             	cmp    %ebx,-0x1c(%ebp)
f0102288:	77 82                	ja     f010220c <user_mem_check+0x31>
f010228a:	b8 00 00 00 00       	mov    $0x0,%eax
                return -E_FAULT;
           }
           begin += PGSIZE;
        }
	return 0;
}
f010228f:	83 c4 2c             	add    $0x2c,%esp
f0102292:	5b                   	pop    %ebx
f0102293:	5e                   	pop    %esi
f0102294:	5f                   	pop    %edi
f0102295:	5d                   	pop    %ebp
f0102296:	c3                   	ret    

f0102297 <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f0102297:	55                   	push   %ebp
f0102298:	89 e5                	mov    %esp,%ebp
f010229a:	53                   	push   %ebx
f010229b:	83 ec 14             	sub    $0x14,%esp
f010229e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f01022a1:	8b 45 14             	mov    0x14(%ebp),%eax
f01022a4:	83 c8 04             	or     $0x4,%eax
f01022a7:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01022ab:	8b 45 10             	mov    0x10(%ebp),%eax
f01022ae:	89 44 24 08          	mov    %eax,0x8(%esp)
f01022b2:	8b 45 0c             	mov    0xc(%ebp),%eax
f01022b5:	89 44 24 04          	mov    %eax,0x4(%esp)
f01022b9:	89 1c 24             	mov    %ebx,(%esp)
f01022bc:	e8 1a ff ff ff       	call   f01021db <user_mem_check>
f01022c1:	85 c0                	test   %eax,%eax
f01022c3:	79 24                	jns    f01022e9 <user_mem_assert+0x52>
		cprintf("[%08x] user_mem_check assertion failure for "
f01022c5:	a1 58 02 1f f0       	mov    0xf01f0258,%eax
f01022ca:	89 44 24 08          	mov    %eax,0x8(%esp)
f01022ce:	8b 43 48             	mov    0x48(%ebx),%eax
f01022d1:	89 44 24 04          	mov    %eax,0x4(%esp)
f01022d5:	c7 04 24 38 8c 10 f0 	movl   $0xf0108c38,(%esp)
f01022dc:	e8 de 27 00 00       	call   f0104abf <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f01022e1:	89 1c 24             	mov    %ebx,(%esp)
f01022e4:	e8 8f 22 00 00       	call   f0104578 <env_destroy>
	}
}
f01022e9:	83 c4 14             	add    $0x14,%esp
f01022ec:	5b                   	pop    %ebx
f01022ed:	5d                   	pop    %ebp
f01022ee:	c3                   	ret    

f01022ef <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct Page *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f01022ef:	55                   	push   %ebp
f01022f0:	89 e5                	mov    %esp,%ebp
f01022f2:	53                   	push   %ebx
f01022f3:	83 ec 14             	sub    $0x14,%esp
f01022f6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// Fill this function in
        pte_t* pte = pgdir_walk(pgdir,va,0);
f01022f9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102300:	00 
f0102301:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102304:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102308:	8b 45 08             	mov    0x8(%ebp),%eax
f010230b:	89 04 24             	mov    %eax,(%esp)
f010230e:	e8 12 fe ff ff       	call   f0102125 <pgdir_walk>
        if(pte_store != NULL)
f0102313:	85 db                	test   %ebx,%ebx
f0102315:	74 02                	je     f0102319 <page_lookup+0x2a>
           *pte_store = pte;
f0102317:	89 03                	mov    %eax,(%ebx)
        if(pte == NULL || !((*pte) & PTE_P))
f0102319:	85 c0                	test   %eax,%eax
f010231b:	74 38                	je     f0102355 <page_lookup+0x66>
f010231d:	8b 00                	mov    (%eax),%eax
f010231f:	a8 01                	test   $0x1,%al
f0102321:	74 32                	je     f0102355 <page_lookup+0x66>
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102323:	c1 e8 0c             	shr    $0xc,%eax
f0102326:	3b 05 a8 0e 1f f0    	cmp    0xf01f0ea8,%eax
f010232c:	72 1c                	jb     f010234a <page_lookup+0x5b>
		panic("pa2page called with invalid pa");
f010232e:	c7 44 24 08 70 8c 10 	movl   $0xf0108c70,0x8(%esp)
f0102335:	f0 
f0102336:	c7 44 24 04 4f 00 00 	movl   $0x4f,0x4(%esp)
f010233d:	00 
f010233e:	c7 04 24 32 88 10 f0 	movl   $0xf0108832,(%esp)
f0102345:	e8 3b dd ff ff       	call   f0100085 <_panic>
	return &pages[PGNUM(pa)];
f010234a:	c1 e0 03             	shl    $0x3,%eax
f010234d:	03 05 b0 0e 1f f0    	add    0xf01f0eb0,%eax
	   return NULL;
        else
           return pa2page(PTE_ADDR(*pte));
f0102353:	eb 05                	jmp    f010235a <page_lookup+0x6b>
f0102355:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010235a:	83 c4 14             	add    $0x14,%esp
f010235d:	5b                   	pop    %ebx
f010235e:	5d                   	pop    %ebp
f010235f:	c3                   	ret    

f0102360 <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f0102360:	55                   	push   %ebp
f0102361:	89 e5                	mov    %esp,%ebp
f0102363:	83 ec 28             	sub    $0x28,%esp
f0102366:	89 5d f8             	mov    %ebx,-0x8(%ebp)
f0102369:	89 75 fc             	mov    %esi,-0x4(%ebp)
f010236c:	8b 75 08             	mov    0x8(%ebp),%esi
f010236f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Fill this function in
        pte_t* pte = NULL;
f0102372:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
        pte_t** pte_store = &pte;
        struct Page* page = page_lookup(pgdir,va,pte_store);
f0102379:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010237c:	89 44 24 08          	mov    %eax,0x8(%esp)
f0102380:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102384:	89 34 24             	mov    %esi,(%esp)
f0102387:	e8 63 ff ff ff       	call   f01022ef <page_lookup>
        if(page == NULL)
f010238c:	85 c0                	test   %eax,%eax
f010238e:	74 21                	je     f01023b1 <page_remove+0x51>
           return;
        page_decref(page);
f0102390:	89 04 24             	mov    %eax,(%esp)
f0102393:	e8 4c f3 ff ff       	call   f01016e4 <page_decref>
        if(pte != NULL)
f0102398:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010239b:	85 c0                	test   %eax,%eax
f010239d:	74 06                	je     f01023a5 <page_remove+0x45>
           *pte = 0;
f010239f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
        tlb_invalidate(pgdir,va);
f01023a5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01023a9:	89 34 24             	mov    %esi,(%esp)
f01023ac:	e8 93 f3 ff ff       	call   f0101744 <tlb_invalidate>
}
f01023b1:	8b 5d f8             	mov    -0x8(%ebp),%ebx
f01023b4:	8b 75 fc             	mov    -0x4(%ebp),%esi
f01023b7:	89 ec                	mov    %ebp,%esp
f01023b9:	5d                   	pop    %ebp
f01023ba:	c3                   	ret    

f01023bb <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct Page *pp, void *va, int perm)
{
f01023bb:	55                   	push   %ebp
f01023bc:	89 e5                	mov    %esp,%ebp
f01023be:	83 ec 28             	sub    $0x28,%esp
f01023c1:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f01023c4:	89 75 f8             	mov    %esi,-0x8(%ebp)
f01023c7:	89 7d fc             	mov    %edi,-0x4(%ebp)
f01023ca:	8b 75 0c             	mov    0xc(%ebp),%esi
f01023cd:	8b 7d 10             	mov    0x10(%ebp),%edi
	// Fill this function in
        pte_t* pte = pgdir_walk(pgdir,va,1);
f01023d0:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01023d7:	00 
f01023d8:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01023dc:	8b 45 08             	mov    0x8(%ebp),%eax
f01023df:	89 04 24             	mov    %eax,(%esp)
f01023e2:	e8 3e fd ff ff       	call   f0102125 <pgdir_walk>
f01023e7:	89 c3                	mov    %eax,%ebx
        if(pte == NULL)
f01023e9:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f01023ee:	85 db                	test   %ebx,%ebx
f01023f0:	74 38                	je     f010242a <page_insert+0x6f>
           return -E_NO_MEM;
        pp->pp_ref++;
f01023f2:	66 83 46 04 01       	addw   $0x1,0x4(%esi)
        if((*pte) & PTE_P){
f01023f7:	f6 03 01             	testb  $0x1,(%ebx)
f01023fa:	74 0f                	je     f010240b <page_insert+0x50>
           //tlb_invalidate(pgdir,va);
           page_remove(pgdir,va);
f01023fc:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0102400:	8b 45 08             	mov    0x8(%ebp),%eax
f0102403:	89 04 24             	mov    %eax,(%esp)
f0102406:	e8 55 ff ff ff       	call   f0102360 <page_remove>
        }
        *pte = page2pa(pp) | perm | PTE_P;
f010240b:	8b 55 14             	mov    0x14(%ebp),%edx
f010240e:	83 ca 01             	or     $0x1,%edx
f0102411:	2b 35 b0 0e 1f f0    	sub    0xf01f0eb0,%esi
f0102417:	c1 fe 03             	sar    $0x3,%esi
f010241a:	89 f0                	mov    %esi,%eax
f010241c:	c1 e0 0c             	shl    $0xc,%eax
f010241f:	89 d6                	mov    %edx,%esi
f0102421:	09 c6                	or     %eax,%esi
f0102423:	89 33                	mov    %esi,(%ebx)
f0102425:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
f010242a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f010242d:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0102430:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0102433:	89 ec                	mov    %ebp,%esp
f0102435:	5d                   	pop    %ebp
f0102436:	c3                   	ret    

f0102437 <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f0102437:	55                   	push   %ebp
f0102438:	89 e5                	mov    %esp,%ebp
f010243a:	57                   	push   %edi
f010243b:	56                   	push   %esi
f010243c:	53                   	push   %ebx
f010243d:	83 ec 2c             	sub    $0x2c,%esp
f0102440:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0102443:	89 d3                	mov    %edx,%ebx
f0102445:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f0102448:	8b 7d 08             	mov    0x8(%ebp),%edi
	// Fill this function in
        int i;
        for(i = 0; i < size; i += PGSIZE){
f010244b:	85 c9                	test   %ecx,%ecx
f010244d:	74 49                	je     f0102498 <boot_map_region+0x61>
f010244f:	be 00 00 00 00       	mov    $0x0,%esi
           pte_t* pte = pgdir_walk(pgdir,(void*)va,1);
           if(pte == NULL)
              return;
           *pte = pa | perm | PTE_P;
f0102454:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102457:	83 c8 01             	or     $0x1,%eax
f010245a:	89 45 dc             	mov    %eax,-0x24(%ebp)
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	// Fill this function in
        int i;
        for(i = 0; i < size; i += PGSIZE){
           pte_t* pte = pgdir_walk(pgdir,(void*)va,1);
f010245d:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0102464:	00 
f0102465:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102469:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010246c:	89 04 24             	mov    %eax,(%esp)
f010246f:	e8 b1 fc ff ff       	call   f0102125 <pgdir_walk>
           if(pte == NULL)
f0102474:	85 c0                	test   %eax,%eax
f0102476:	74 20                	je     f0102498 <boot_map_region+0x61>
              return;
           *pte = pa | perm | PTE_P;
f0102478:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010247b:	09 fa                	or     %edi,%edx
f010247d:	89 10                	mov    %edx,(%eax)
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	// Fill this function in
        int i;
        for(i = 0; i < size; i += PGSIZE){
f010247f:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102485:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
f0102488:	76 0e                	jbe    f0102498 <boot_map_region+0x61>
           pte_t* pte = pgdir_walk(pgdir,(void*)va,1);
           if(pte == NULL)
              return;
           *pte = pa | perm | PTE_P;
           va += PGSIZE;
f010248a:	81 c3 00 10 00 00    	add    $0x1000,%ebx
           pa += PGSIZE;
f0102490:	81 c7 00 10 00 00    	add    $0x1000,%edi
f0102496:	eb c5                	jmp    f010245d <boot_map_region+0x26>
        }
}
f0102498:	83 c4 2c             	add    $0x2c,%esp
f010249b:	5b                   	pop    %ebx
f010249c:	5e                   	pop    %esi
f010249d:	5f                   	pop    %edi
f010249e:	5d                   	pop    %ebp
f010249f:	c3                   	ret    

f01024a0 <check_page_installed_pgdir>:
}

// check page_insert, page_remove, &c, with an installed kern_pgdir
static void
check_page_installed_pgdir(void)
{
f01024a0:	55                   	push   %ebp
f01024a1:	89 e5                	mov    %esp,%ebp
f01024a3:	57                   	push   %edi
f01024a4:	56                   	push   %esi
f01024a5:	53                   	push   %ebx
f01024a6:	83 ec 2c             	sub    $0x2c,%esp
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01024a9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01024b0:	e8 f2 fb ff ff       	call   f01020a7 <page_alloc>
f01024b5:	89 c3                	mov    %eax,%ebx
f01024b7:	85 c0                	test   %eax,%eax
f01024b9:	75 24                	jne    f01024df <check_page_installed_pgdir+0x3f>
f01024bb:	c7 44 24 0c f9 88 10 	movl   $0xf01088f9,0xc(%esp)
f01024c2:	f0 
f01024c3:	c7 44 24 08 4c 88 10 	movl   $0xf010884c,0x8(%esp)
f01024ca:	f0 
f01024cb:	c7 44 24 04 34 05 00 	movl   $0x534,0x4(%esp)
f01024d2:	00 
f01024d3:	c7 04 24 26 88 10 f0 	movl   $0xf0108826,(%esp)
f01024da:	e8 a6 db ff ff       	call   f0100085 <_panic>
	assert((pp1 = page_alloc(0)));
f01024df:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01024e6:	e8 bc fb ff ff       	call   f01020a7 <page_alloc>
f01024eb:	89 c7                	mov    %eax,%edi
f01024ed:	85 c0                	test   %eax,%eax
f01024ef:	75 24                	jne    f0102515 <check_page_installed_pgdir+0x75>
f01024f1:	c7 44 24 0c 0f 89 10 	movl   $0xf010890f,0xc(%esp)
f01024f8:	f0 
f01024f9:	c7 44 24 08 4c 88 10 	movl   $0xf010884c,0x8(%esp)
f0102500:	f0 
f0102501:	c7 44 24 04 35 05 00 	movl   $0x535,0x4(%esp)
f0102508:	00 
f0102509:	c7 04 24 26 88 10 f0 	movl   $0xf0108826,(%esp)
f0102510:	e8 70 db ff ff       	call   f0100085 <_panic>
	assert((pp2 = page_alloc(0)));
f0102515:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010251c:	e8 86 fb ff ff       	call   f01020a7 <page_alloc>
f0102521:	89 c6                	mov    %eax,%esi
f0102523:	85 c0                	test   %eax,%eax
f0102525:	75 24                	jne    f010254b <check_page_installed_pgdir+0xab>
f0102527:	c7 44 24 0c 25 89 10 	movl   $0xf0108925,0xc(%esp)
f010252e:	f0 
f010252f:	c7 44 24 08 4c 88 10 	movl   $0xf010884c,0x8(%esp)
f0102536:	f0 
f0102537:	c7 44 24 04 36 05 00 	movl   $0x536,0x4(%esp)
f010253e:	00 
f010253f:	c7 04 24 26 88 10 f0 	movl   $0xf0108826,(%esp)
f0102546:	e8 3a db ff ff       	call   f0100085 <_panic>
	page_free(pp0);
f010254b:	89 1c 24             	mov    %ebx,(%esp)
f010254e:	e8 7c f1 ff ff       	call   f01016cf <page_free>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0102553:	89 f8                	mov    %edi,%eax
f0102555:	2b 05 b0 0e 1f f0    	sub    0xf01f0eb0,%eax
f010255b:	c1 f8 03             	sar    $0x3,%eax
f010255e:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102561:	89 c2                	mov    %eax,%edx
f0102563:	c1 ea 0c             	shr    $0xc,%edx
f0102566:	3b 15 a8 0e 1f f0    	cmp    0xf01f0ea8,%edx
f010256c:	72 20                	jb     f010258e <check_page_installed_pgdir+0xee>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010256e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102572:	c7 44 24 08 80 80 10 	movl   $0xf0108080,0x8(%esp)
f0102579:	f0 
f010257a:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0102581:	00 
f0102582:	c7 04 24 32 88 10 f0 	movl   $0xf0108832,(%esp)
f0102589:	e8 f7 da ff ff       	call   f0100085 <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f010258e:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102595:	00 
f0102596:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f010259d:	00 
f010259e:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01025a3:	89 04 24             	mov    %eax,(%esp)
f01025a6:	e8 7b 4c 00 00       	call   f0107226 <memset>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f01025ab:	89 75 e4             	mov    %esi,-0x1c(%ebp)
f01025ae:	89 f0                	mov    %esi,%eax
f01025b0:	2b 05 b0 0e 1f f0    	sub    0xf01f0eb0,%eax
f01025b6:	c1 f8 03             	sar    $0x3,%eax
f01025b9:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01025bc:	89 c2                	mov    %eax,%edx
f01025be:	c1 ea 0c             	shr    $0xc,%edx
f01025c1:	3b 15 a8 0e 1f f0    	cmp    0xf01f0ea8,%edx
f01025c7:	72 20                	jb     f01025e9 <check_page_installed_pgdir+0x149>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01025c9:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01025cd:	c7 44 24 08 80 80 10 	movl   $0xf0108080,0x8(%esp)
f01025d4:	f0 
f01025d5:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f01025dc:	00 
f01025dd:	c7 04 24 32 88 10 f0 	movl   $0xf0108832,(%esp)
f01025e4:	e8 9c da ff ff       	call   f0100085 <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f01025e9:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01025f0:	00 
f01025f1:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f01025f8:	00 
f01025f9:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01025fe:	89 04 24             	mov    %eax,(%esp)
f0102601:	e8 20 4c 00 00       	call   f0107226 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102606:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f010260d:	00 
f010260e:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102615:	00 
f0102616:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010261a:	a1 ac 0e 1f f0       	mov    0xf01f0eac,%eax
f010261f:	89 04 24             	mov    %eax,(%esp)
f0102622:	e8 94 fd ff ff       	call   f01023bb <page_insert>
	assert(pp1->pp_ref == 1);
f0102627:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f010262c:	74 24                	je     f0102652 <check_page_installed_pgdir+0x1b2>
f010262e:	c7 44 24 0c 3b 89 10 	movl   $0xf010893b,0xc(%esp)
f0102635:	f0 
f0102636:	c7 44 24 08 4c 88 10 	movl   $0xf010884c,0x8(%esp)
f010263d:	f0 
f010263e:	c7 44 24 04 3b 05 00 	movl   $0x53b,0x4(%esp)
f0102645:	00 
f0102646:	c7 04 24 26 88 10 f0 	movl   $0xf0108826,(%esp)
f010264d:	e8 33 da ff ff       	call   f0100085 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102652:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102659:	01 01 01 
f010265c:	74 24                	je     f0102682 <check_page_installed_pgdir+0x1e2>
f010265e:	c7 44 24 0c 90 8c 10 	movl   $0xf0108c90,0xc(%esp)
f0102665:	f0 
f0102666:	c7 44 24 08 4c 88 10 	movl   $0xf010884c,0x8(%esp)
f010266d:	f0 
f010266e:	c7 44 24 04 3c 05 00 	movl   $0x53c,0x4(%esp)
f0102675:	00 
f0102676:	c7 04 24 26 88 10 f0 	movl   $0xf0108826,(%esp)
f010267d:	e8 03 da ff ff       	call   f0100085 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102682:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102689:	00 
f010268a:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102691:	00 
f0102692:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102696:	a1 ac 0e 1f f0       	mov    0xf01f0eac,%eax
f010269b:	89 04 24             	mov    %eax,(%esp)
f010269e:	e8 18 fd ff ff       	call   f01023bb <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f01026a3:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f01026aa:	02 02 02 
f01026ad:	74 24                	je     f01026d3 <check_page_installed_pgdir+0x233>
f01026af:	c7 44 24 0c b4 8c 10 	movl   $0xf0108cb4,0xc(%esp)
f01026b6:	f0 
f01026b7:	c7 44 24 08 4c 88 10 	movl   $0xf010884c,0x8(%esp)
f01026be:	f0 
f01026bf:	c7 44 24 04 3e 05 00 	movl   $0x53e,0x4(%esp)
f01026c6:	00 
f01026c7:	c7 04 24 26 88 10 f0 	movl   $0xf0108826,(%esp)
f01026ce:	e8 b2 d9 ff ff       	call   f0100085 <_panic>
	assert(pp2->pp_ref == 1);
f01026d3:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01026d8:	74 24                	je     f01026fe <check_page_installed_pgdir+0x25e>
f01026da:	c7 44 24 0c 4c 89 10 	movl   $0xf010894c,0xc(%esp)
f01026e1:	f0 
f01026e2:	c7 44 24 08 4c 88 10 	movl   $0xf010884c,0x8(%esp)
f01026e9:	f0 
f01026ea:	c7 44 24 04 3f 05 00 	movl   $0x53f,0x4(%esp)
f01026f1:	00 
f01026f2:	c7 04 24 26 88 10 f0 	movl   $0xf0108826,(%esp)
f01026f9:	e8 87 d9 ff ff       	call   f0100085 <_panic>
	assert(pp1->pp_ref == 0);
f01026fe:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102703:	74 24                	je     f0102729 <check_page_installed_pgdir+0x289>
f0102705:	c7 44 24 0c 5d 89 10 	movl   $0xf010895d,0xc(%esp)
f010270c:	f0 
f010270d:	c7 44 24 08 4c 88 10 	movl   $0xf010884c,0x8(%esp)
f0102714:	f0 
f0102715:	c7 44 24 04 40 05 00 	movl   $0x540,0x4(%esp)
f010271c:	00 
f010271d:	c7 04 24 26 88 10 f0 	movl   $0xf0108826,(%esp)
f0102724:	e8 5c d9 ff ff       	call   f0100085 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102729:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102730:	03 03 03 
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0102733:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102736:	2b 05 b0 0e 1f f0    	sub    0xf01f0eb0,%eax
f010273c:	c1 f8 03             	sar    $0x3,%eax
f010273f:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102742:	89 c2                	mov    %eax,%edx
f0102744:	c1 ea 0c             	shr    $0xc,%edx
f0102747:	3b 15 a8 0e 1f f0    	cmp    0xf01f0ea8,%edx
f010274d:	72 20                	jb     f010276f <check_page_installed_pgdir+0x2cf>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010274f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102753:	c7 44 24 08 80 80 10 	movl   $0xf0108080,0x8(%esp)
f010275a:	f0 
f010275b:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0102762:	00 
f0102763:	c7 04 24 32 88 10 f0 	movl   $0xf0108832,(%esp)
f010276a:	e8 16 d9 ff ff       	call   f0100085 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f010276f:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0102776:	03 03 03 
f0102779:	74 24                	je     f010279f <check_page_installed_pgdir+0x2ff>
f010277b:	c7 44 24 0c d8 8c 10 	movl   $0xf0108cd8,0xc(%esp)
f0102782:	f0 
f0102783:	c7 44 24 08 4c 88 10 	movl   $0xf010884c,0x8(%esp)
f010278a:	f0 
f010278b:	c7 44 24 04 42 05 00 	movl   $0x542,0x4(%esp)
f0102792:	00 
f0102793:	c7 04 24 26 88 10 f0 	movl   $0xf0108826,(%esp)
f010279a:	e8 e6 d8 ff ff       	call   f0100085 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f010279f:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01027a6:	00 
f01027a7:	a1 ac 0e 1f f0       	mov    0xf01f0eac,%eax
f01027ac:	89 04 24             	mov    %eax,(%esp)
f01027af:	e8 ac fb ff ff       	call   f0102360 <page_remove>
	assert(pp2->pp_ref == 0);
f01027b4:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f01027b9:	74 24                	je     f01027df <check_page_installed_pgdir+0x33f>
f01027bb:	c7 44 24 0c 6e 89 10 	movl   $0xf010896e,0xc(%esp)
f01027c2:	f0 
f01027c3:	c7 44 24 08 4c 88 10 	movl   $0xf010884c,0x8(%esp)
f01027ca:	f0 
f01027cb:	c7 44 24 04 44 05 00 	movl   $0x544,0x4(%esp)
f01027d2:	00 
f01027d3:	c7 04 24 26 88 10 f0 	movl   $0xf0108826,(%esp)
f01027da:	e8 a6 d8 ff ff       	call   f0100085 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01027df:	a1 ac 0e 1f f0       	mov    0xf01f0eac,%eax
f01027e4:	8b 08                	mov    (%eax),%ecx
f01027e6:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f01027ec:	89 da                	mov    %ebx,%edx
f01027ee:	2b 15 b0 0e 1f f0    	sub    0xf01f0eb0,%edx
f01027f4:	c1 fa 03             	sar    $0x3,%edx
f01027f7:	c1 e2 0c             	shl    $0xc,%edx
f01027fa:	39 d1                	cmp    %edx,%ecx
f01027fc:	74 24                	je     f0102822 <check_page_installed_pgdir+0x382>
f01027fe:	c7 44 24 0c 04 8d 10 	movl   $0xf0108d04,0xc(%esp)
f0102805:	f0 
f0102806:	c7 44 24 08 4c 88 10 	movl   $0xf010884c,0x8(%esp)
f010280d:	f0 
f010280e:	c7 44 24 04 47 05 00 	movl   $0x547,0x4(%esp)
f0102815:	00 
f0102816:	c7 04 24 26 88 10 f0 	movl   $0xf0108826,(%esp)
f010281d:	e8 63 d8 ff ff       	call   f0100085 <_panic>
	kern_pgdir[0] = 0;
f0102822:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f0102828:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f010282d:	74 24                	je     f0102853 <check_page_installed_pgdir+0x3b3>
f010282f:	c7 44 24 0c 7f 89 10 	movl   $0xf010897f,0xc(%esp)
f0102836:	f0 
f0102837:	c7 44 24 08 4c 88 10 	movl   $0xf010884c,0x8(%esp)
f010283e:	f0 
f010283f:	c7 44 24 04 49 05 00 	movl   $0x549,0x4(%esp)
f0102846:	00 
f0102847:	c7 04 24 26 88 10 f0 	movl   $0xf0108826,(%esp)
f010284e:	e8 32 d8 ff ff       	call   f0100085 <_panic>
	pp0->pp_ref = 0;
f0102853:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f0102859:	89 1c 24             	mov    %ebx,(%esp)
f010285c:	e8 6e ee ff ff       	call   f01016cf <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102861:	c7 04 24 2c 8d 10 f0 	movl   $0xf0108d2c,(%esp)
f0102868:	e8 52 22 00 00       	call   f0104abf <cprintf>
}
f010286d:	83 c4 2c             	add    $0x2c,%esp
f0102870:	5b                   	pop    %ebx
f0102871:	5e                   	pop    %esi
f0102872:	5f                   	pop    %edi
f0102873:	5d                   	pop    %ebp
f0102874:	c3                   	ret    

f0102875 <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f0102875:	55                   	push   %ebp
f0102876:	89 e5                	mov    %esp,%ebp
f0102878:	57                   	push   %edi
f0102879:	56                   	push   %esi
f010287a:	53                   	push   %ebx
f010287b:	83 ec 3c             	sub    $0x3c,%esp
	uint32_t cr0;
	size_t n;

	// Find out how much memory the machine has (npages & npages_basemem).
	i386_detect_memory();
f010287e:	e8 f2 f0 ff ff       	call   f0101975 <i386_detect_memory>
	// Remove this line when you're ready to test this function.
	//panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f0102883:	b8 00 10 00 00       	mov    $0x1000,%eax
f0102888:	e8 ec ee ff ff       	call   f0101779 <boot_alloc>
f010288d:	a3 ac 0e 1f f0       	mov    %eax,0xf01f0eac
	memset(kern_pgdir, 0, PGSIZE);
f0102892:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102899:	00 
f010289a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01028a1:	00 
f01028a2:	89 04 24             	mov    %eax,(%esp)
f01028a5:	e8 7c 49 00 00       	call   f0107226 <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following two lines.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f01028aa:	a1 ac 0e 1f f0       	mov    0xf01f0eac,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01028af:	89 c2                	mov    %eax,%edx
f01028b1:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01028b6:	77 20                	ja     f01028d8 <mem_init+0x63>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01028b8:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01028bc:	c7 44 24 08 5c 80 10 	movl   $0xf010805c,0x8(%esp)
f01028c3:	f0 
f01028c4:	c7 44 24 04 99 00 00 	movl   $0x99,0x4(%esp)
f01028cb:	00 
f01028cc:	c7 04 24 26 88 10 f0 	movl   $0xf0108826,(%esp)
f01028d3:	e8 ad d7 ff ff       	call   f0100085 <_panic>
f01028d8:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f01028de:	83 ca 05             	or     $0x5,%edx
f01028e1:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate an array of npages 'struct Page's and store it in 'pages'.
	// The kernel uses this array to keep track of physical pages: for
	// each physical page, there is a corresponding struct Page in this
	// array.  'npages' is the number of physical pages in memory.
	// Your code goes here:
        pages = (struct Page*)boot_alloc(npages*sizeof(struct Page));
f01028e7:	a1 a8 0e 1f f0       	mov    0xf01f0ea8,%eax
f01028ec:	c1 e0 03             	shl    $0x3,%eax
f01028ef:	e8 85 ee ff ff       	call   f0101779 <boot_alloc>
f01028f4:	a3 b0 0e 1f f0       	mov    %eax,0xf01f0eb0
        //cprintf("sizeofPage: %d\n",sizeof(struct Page));
        memset(pages,0,npages*sizeof(struct Page));
f01028f9:	8b 15 a8 0e 1f f0    	mov    0xf01f0ea8,%edx
f01028ff:	c1 e2 03             	shl    $0x3,%edx
f0102902:	89 54 24 08          	mov    %edx,0x8(%esp)
f0102906:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010290d:	00 
f010290e:	89 04 24             	mov    %eax,(%esp)
f0102911:	e8 10 49 00 00       	call   f0107226 <memset>

	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.

        envs = (struct Env*)boot_alloc(NENV*sizeof(struct Env));
f0102916:	b8 00 10 02 00       	mov    $0x21000,%eax
f010291b:	e8 59 ee ff ff       	call   f0101779 <boot_alloc>
f0102920:	a3 5c 02 1f f0       	mov    %eax,0xf01f025c
        memset(envs,0,NENV*sizeof(struct Env));
f0102925:	c7 44 24 08 00 10 02 	movl   $0x21000,0x8(%esp)
f010292c:	00 
f010292d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102934:	00 
f0102935:	89 04 24             	mov    %eax,(%esp)
f0102938:	e8 e9 48 00 00       	call   f0107226 <memset>
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f010293d:	e8 9a ee ff ff       	call   f01017dc <page_init>

	check_page_free_list(1);
f0102942:	b8 01 00 00 00       	mov    $0x1,%eax
f0102947:	e8 b8 f3 ff ff       	call   f0101d04 <check_page_free_list>
	int nfree;
	struct Page *fl;
	char *c;
	int i;

	if (!pages)
f010294c:	83 3d b0 0e 1f f0 00 	cmpl   $0x0,0xf01f0eb0
f0102953:	75 1c                	jne    f0102971 <mem_init+0xfc>
		panic("'pages' is a null pointer!");
f0102955:	c7 44 24 08 90 89 10 	movl   $0xf0108990,0x8(%esp)
f010295c:	f0 
f010295d:	c7 44 24 04 85 03 00 	movl   $0x385,0x4(%esp)
f0102964:	00 
f0102965:	c7 04 24 26 88 10 f0 	movl   $0xf0108826,(%esp)
f010296c:	e8 14 d7 ff ff       	call   f0100085 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0102971:	a1 50 02 1f f0       	mov    0xf01f0250,%eax
f0102976:	bb 00 00 00 00       	mov    $0x0,%ebx
f010297b:	85 c0                	test   %eax,%eax
f010297d:	74 09                	je     f0102988 <mem_init+0x113>
		++nfree;
f010297f:	83 c3 01             	add    $0x1,%ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0102982:	8b 00                	mov    (%eax),%eax
f0102984:	85 c0                	test   %eax,%eax
f0102986:	75 f7                	jne    f010297f <mem_init+0x10a>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102988:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010298f:	e8 13 f7 ff ff       	call   f01020a7 <page_alloc>
f0102994:	89 c6                	mov    %eax,%esi
f0102996:	85 c0                	test   %eax,%eax
f0102998:	75 24                	jne    f01029be <mem_init+0x149>
f010299a:	c7 44 24 0c f9 88 10 	movl   $0xf01088f9,0xc(%esp)
f01029a1:	f0 
f01029a2:	c7 44 24 08 4c 88 10 	movl   $0xf010884c,0x8(%esp)
f01029a9:	f0 
f01029aa:	c7 44 24 04 8d 03 00 	movl   $0x38d,0x4(%esp)
f01029b1:	00 
f01029b2:	c7 04 24 26 88 10 f0 	movl   $0xf0108826,(%esp)
f01029b9:	e8 c7 d6 ff ff       	call   f0100085 <_panic>
	assert((pp1 = page_alloc(0)));
f01029be:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01029c5:	e8 dd f6 ff ff       	call   f01020a7 <page_alloc>
f01029ca:	89 c7                	mov    %eax,%edi
f01029cc:	85 c0                	test   %eax,%eax
f01029ce:	75 24                	jne    f01029f4 <mem_init+0x17f>
f01029d0:	c7 44 24 0c 0f 89 10 	movl   $0xf010890f,0xc(%esp)
f01029d7:	f0 
f01029d8:	c7 44 24 08 4c 88 10 	movl   $0xf010884c,0x8(%esp)
f01029df:	f0 
f01029e0:	c7 44 24 04 8e 03 00 	movl   $0x38e,0x4(%esp)
f01029e7:	00 
f01029e8:	c7 04 24 26 88 10 f0 	movl   $0xf0108826,(%esp)
f01029ef:	e8 91 d6 ff ff       	call   f0100085 <_panic>
	assert((pp2 = page_alloc(0)));
f01029f4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01029fb:	e8 a7 f6 ff ff       	call   f01020a7 <page_alloc>
f0102a00:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102a03:	85 c0                	test   %eax,%eax
f0102a05:	75 24                	jne    f0102a2b <mem_init+0x1b6>
f0102a07:	c7 44 24 0c 25 89 10 	movl   $0xf0108925,0xc(%esp)
f0102a0e:	f0 
f0102a0f:	c7 44 24 08 4c 88 10 	movl   $0xf010884c,0x8(%esp)
f0102a16:	f0 
f0102a17:	c7 44 24 04 8f 03 00 	movl   $0x38f,0x4(%esp)
f0102a1e:	00 
f0102a1f:	c7 04 24 26 88 10 f0 	movl   $0xf0108826,(%esp)
f0102a26:	e8 5a d6 ff ff       	call   f0100085 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0102a2b:	39 fe                	cmp    %edi,%esi
f0102a2d:	75 24                	jne    f0102a53 <mem_init+0x1de>
f0102a2f:	c7 44 24 0c ab 89 10 	movl   $0xf01089ab,0xc(%esp)
f0102a36:	f0 
f0102a37:	c7 44 24 08 4c 88 10 	movl   $0xf010884c,0x8(%esp)
f0102a3e:	f0 
f0102a3f:	c7 44 24 04 92 03 00 	movl   $0x392,0x4(%esp)
f0102a46:	00 
f0102a47:	c7 04 24 26 88 10 f0 	movl   $0xf0108826,(%esp)
f0102a4e:	e8 32 d6 ff ff       	call   f0100085 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0102a53:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f0102a56:	74 05                	je     f0102a5d <mem_init+0x1e8>
f0102a58:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f0102a5b:	75 24                	jne    f0102a81 <mem_init+0x20c>
f0102a5d:	c7 44 24 0c 58 8d 10 	movl   $0xf0108d58,0xc(%esp)
f0102a64:	f0 
f0102a65:	c7 44 24 08 4c 88 10 	movl   $0xf010884c,0x8(%esp)
f0102a6c:	f0 
f0102a6d:	c7 44 24 04 93 03 00 	movl   $0x393,0x4(%esp)
f0102a74:	00 
f0102a75:	c7 04 24 26 88 10 f0 	movl   $0xf0108826,(%esp)
f0102a7c:	e8 04 d6 ff ff       	call   f0100085 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0102a81:	8b 15 b0 0e 1f f0    	mov    0xf01f0eb0,%edx
	assert(page2pa(pp0) < npages*PGSIZE);
f0102a87:	a1 a8 0e 1f f0       	mov    0xf01f0ea8,%eax
f0102a8c:	c1 e0 0c             	shl    $0xc,%eax
f0102a8f:	89 f1                	mov    %esi,%ecx
f0102a91:	29 d1                	sub    %edx,%ecx
f0102a93:	c1 f9 03             	sar    $0x3,%ecx
f0102a96:	c1 e1 0c             	shl    $0xc,%ecx
f0102a99:	39 c1                	cmp    %eax,%ecx
f0102a9b:	72 24                	jb     f0102ac1 <mem_init+0x24c>
f0102a9d:	c7 44 24 0c bd 89 10 	movl   $0xf01089bd,0xc(%esp)
f0102aa4:	f0 
f0102aa5:	c7 44 24 08 4c 88 10 	movl   $0xf010884c,0x8(%esp)
f0102aac:	f0 
f0102aad:	c7 44 24 04 94 03 00 	movl   $0x394,0x4(%esp)
f0102ab4:	00 
f0102ab5:	c7 04 24 26 88 10 f0 	movl   $0xf0108826,(%esp)
f0102abc:	e8 c4 d5 ff ff       	call   f0100085 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f0102ac1:	89 f9                	mov    %edi,%ecx
f0102ac3:	29 d1                	sub    %edx,%ecx
f0102ac5:	c1 f9 03             	sar    $0x3,%ecx
f0102ac8:	c1 e1 0c             	shl    $0xc,%ecx
f0102acb:	39 c8                	cmp    %ecx,%eax
f0102acd:	77 24                	ja     f0102af3 <mem_init+0x27e>
f0102acf:	c7 44 24 0c da 89 10 	movl   $0xf01089da,0xc(%esp)
f0102ad6:	f0 
f0102ad7:	c7 44 24 08 4c 88 10 	movl   $0xf010884c,0x8(%esp)
f0102ade:	f0 
f0102adf:	c7 44 24 04 95 03 00 	movl   $0x395,0x4(%esp)
f0102ae6:	00 
f0102ae7:	c7 04 24 26 88 10 f0 	movl   $0xf0108826,(%esp)
f0102aee:	e8 92 d5 ff ff       	call   f0100085 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f0102af3:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0102af6:	29 d1                	sub    %edx,%ecx
f0102af8:	89 ca                	mov    %ecx,%edx
f0102afa:	c1 fa 03             	sar    $0x3,%edx
f0102afd:	c1 e2 0c             	shl    $0xc,%edx
f0102b00:	39 d0                	cmp    %edx,%eax
f0102b02:	77 24                	ja     f0102b28 <mem_init+0x2b3>
f0102b04:	c7 44 24 0c f7 89 10 	movl   $0xf01089f7,0xc(%esp)
f0102b0b:	f0 
f0102b0c:	c7 44 24 08 4c 88 10 	movl   $0xf010884c,0x8(%esp)
f0102b13:	f0 
f0102b14:	c7 44 24 04 96 03 00 	movl   $0x396,0x4(%esp)
f0102b1b:	00 
f0102b1c:	c7 04 24 26 88 10 f0 	movl   $0xf0108826,(%esp)
f0102b23:	e8 5d d5 ff ff       	call   f0100085 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0102b28:	a1 50 02 1f f0       	mov    0xf01f0250,%eax
f0102b2d:	89 45 cc             	mov    %eax,-0x34(%ebp)
	page_free_list = 0;
f0102b30:	c7 05 50 02 1f f0 00 	movl   $0x0,0xf01f0250
f0102b37:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0102b3a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102b41:	e8 61 f5 ff ff       	call   f01020a7 <page_alloc>
f0102b46:	85 c0                	test   %eax,%eax
f0102b48:	74 24                	je     f0102b6e <mem_init+0x2f9>
f0102b4a:	c7 44 24 0c 14 8a 10 	movl   $0xf0108a14,0xc(%esp)
f0102b51:	f0 
f0102b52:	c7 44 24 08 4c 88 10 	movl   $0xf010884c,0x8(%esp)
f0102b59:	f0 
f0102b5a:	c7 44 24 04 9d 03 00 	movl   $0x39d,0x4(%esp)
f0102b61:	00 
f0102b62:	c7 04 24 26 88 10 f0 	movl   $0xf0108826,(%esp)
f0102b69:	e8 17 d5 ff ff       	call   f0100085 <_panic>

	// free and re-allocate?
	page_free(pp0);
f0102b6e:	89 34 24             	mov    %esi,(%esp)
f0102b71:	e8 59 eb ff ff       	call   f01016cf <page_free>
	page_free(pp1);
f0102b76:	89 3c 24             	mov    %edi,(%esp)
f0102b79:	e8 51 eb ff ff       	call   f01016cf <page_free>
	page_free(pp2);
f0102b7e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0102b81:	89 14 24             	mov    %edx,(%esp)
f0102b84:	e8 46 eb ff ff       	call   f01016cf <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102b89:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102b90:	e8 12 f5 ff ff       	call   f01020a7 <page_alloc>
f0102b95:	89 c6                	mov    %eax,%esi
f0102b97:	85 c0                	test   %eax,%eax
f0102b99:	75 24                	jne    f0102bbf <mem_init+0x34a>
f0102b9b:	c7 44 24 0c f9 88 10 	movl   $0xf01088f9,0xc(%esp)
f0102ba2:	f0 
f0102ba3:	c7 44 24 08 4c 88 10 	movl   $0xf010884c,0x8(%esp)
f0102baa:	f0 
f0102bab:	c7 44 24 04 a4 03 00 	movl   $0x3a4,0x4(%esp)
f0102bb2:	00 
f0102bb3:	c7 04 24 26 88 10 f0 	movl   $0xf0108826,(%esp)
f0102bba:	e8 c6 d4 ff ff       	call   f0100085 <_panic>
	assert((pp1 = page_alloc(0)));
f0102bbf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102bc6:	e8 dc f4 ff ff       	call   f01020a7 <page_alloc>
f0102bcb:	89 c7                	mov    %eax,%edi
f0102bcd:	85 c0                	test   %eax,%eax
f0102bcf:	75 24                	jne    f0102bf5 <mem_init+0x380>
f0102bd1:	c7 44 24 0c 0f 89 10 	movl   $0xf010890f,0xc(%esp)
f0102bd8:	f0 
f0102bd9:	c7 44 24 08 4c 88 10 	movl   $0xf010884c,0x8(%esp)
f0102be0:	f0 
f0102be1:	c7 44 24 04 a5 03 00 	movl   $0x3a5,0x4(%esp)
f0102be8:	00 
f0102be9:	c7 04 24 26 88 10 f0 	movl   $0xf0108826,(%esp)
f0102bf0:	e8 90 d4 ff ff       	call   f0100085 <_panic>
	assert((pp2 = page_alloc(0)));
f0102bf5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102bfc:	e8 a6 f4 ff ff       	call   f01020a7 <page_alloc>
f0102c01:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102c04:	85 c0                	test   %eax,%eax
f0102c06:	75 24                	jne    f0102c2c <mem_init+0x3b7>
f0102c08:	c7 44 24 0c 25 89 10 	movl   $0xf0108925,0xc(%esp)
f0102c0f:	f0 
f0102c10:	c7 44 24 08 4c 88 10 	movl   $0xf010884c,0x8(%esp)
f0102c17:	f0 
f0102c18:	c7 44 24 04 a6 03 00 	movl   $0x3a6,0x4(%esp)
f0102c1f:	00 
f0102c20:	c7 04 24 26 88 10 f0 	movl   $0xf0108826,(%esp)
f0102c27:	e8 59 d4 ff ff       	call   f0100085 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0102c2c:	39 fe                	cmp    %edi,%esi
f0102c2e:	75 24                	jne    f0102c54 <mem_init+0x3df>
f0102c30:	c7 44 24 0c ab 89 10 	movl   $0xf01089ab,0xc(%esp)
f0102c37:	f0 
f0102c38:	c7 44 24 08 4c 88 10 	movl   $0xf010884c,0x8(%esp)
f0102c3f:	f0 
f0102c40:	c7 44 24 04 a8 03 00 	movl   $0x3a8,0x4(%esp)
f0102c47:	00 
f0102c48:	c7 04 24 26 88 10 f0 	movl   $0xf0108826,(%esp)
f0102c4f:	e8 31 d4 ff ff       	call   f0100085 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0102c54:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f0102c57:	74 05                	je     f0102c5e <mem_init+0x3e9>
f0102c59:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f0102c5c:	75 24                	jne    f0102c82 <mem_init+0x40d>
f0102c5e:	c7 44 24 0c 58 8d 10 	movl   $0xf0108d58,0xc(%esp)
f0102c65:	f0 
f0102c66:	c7 44 24 08 4c 88 10 	movl   $0xf010884c,0x8(%esp)
f0102c6d:	f0 
f0102c6e:	c7 44 24 04 a9 03 00 	movl   $0x3a9,0x4(%esp)
f0102c75:	00 
f0102c76:	c7 04 24 26 88 10 f0 	movl   $0xf0108826,(%esp)
f0102c7d:	e8 03 d4 ff ff       	call   f0100085 <_panic>
	assert(!page_alloc(0));
f0102c82:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102c89:	e8 19 f4 ff ff       	call   f01020a7 <page_alloc>
f0102c8e:	85 c0                	test   %eax,%eax
f0102c90:	74 24                	je     f0102cb6 <mem_init+0x441>
f0102c92:	c7 44 24 0c 14 8a 10 	movl   $0xf0108a14,0xc(%esp)
f0102c99:	f0 
f0102c9a:	c7 44 24 08 4c 88 10 	movl   $0xf010884c,0x8(%esp)
f0102ca1:	f0 
f0102ca2:	c7 44 24 04 aa 03 00 	movl   $0x3aa,0x4(%esp)
f0102ca9:	00 
f0102caa:	c7 04 24 26 88 10 f0 	movl   $0xf0108826,(%esp)
f0102cb1:	e8 cf d3 ff ff       	call   f0100085 <_panic>
f0102cb6:	89 75 d0             	mov    %esi,-0x30(%ebp)
f0102cb9:	89 f0                	mov    %esi,%eax
f0102cbb:	2b 05 b0 0e 1f f0    	sub    0xf01f0eb0,%eax
f0102cc1:	c1 f8 03             	sar    $0x3,%eax
f0102cc4:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102cc7:	89 c2                	mov    %eax,%edx
f0102cc9:	c1 ea 0c             	shr    $0xc,%edx
f0102ccc:	3b 15 a8 0e 1f f0    	cmp    0xf01f0ea8,%edx
f0102cd2:	72 20                	jb     f0102cf4 <mem_init+0x47f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102cd4:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102cd8:	c7 44 24 08 80 80 10 	movl   $0xf0108080,0x8(%esp)
f0102cdf:	f0 
f0102ce0:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0102ce7:	00 
f0102ce8:	c7 04 24 32 88 10 f0 	movl   $0xf0108832,(%esp)
f0102cef:	e8 91 d3 ff ff       	call   f0100085 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f0102cf4:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102cfb:	00 
f0102cfc:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f0102d03:	00 
f0102d04:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102d09:	89 04 24             	mov    %eax,(%esp)
f0102d0c:	e8 15 45 00 00       	call   f0107226 <memset>
	page_free(pp0);
f0102d11:	89 34 24             	mov    %esi,(%esp)
f0102d14:	e8 b6 e9 ff ff       	call   f01016cf <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0102d19:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0102d20:	e8 82 f3 ff ff       	call   f01020a7 <page_alloc>
f0102d25:	85 c0                	test   %eax,%eax
f0102d27:	75 24                	jne    f0102d4d <mem_init+0x4d8>
f0102d29:	c7 44 24 0c 23 8a 10 	movl   $0xf0108a23,0xc(%esp)
f0102d30:	f0 
f0102d31:	c7 44 24 08 4c 88 10 	movl   $0xf010884c,0x8(%esp)
f0102d38:	f0 
f0102d39:	c7 44 24 04 af 03 00 	movl   $0x3af,0x4(%esp)
f0102d40:	00 
f0102d41:	c7 04 24 26 88 10 f0 	movl   $0xf0108826,(%esp)
f0102d48:	e8 38 d3 ff ff       	call   f0100085 <_panic>
	assert(pp && pp0 == pp);
f0102d4d:	39 c6                	cmp    %eax,%esi
f0102d4f:	74 24                	je     f0102d75 <mem_init+0x500>
f0102d51:	c7 44 24 0c 41 8a 10 	movl   $0xf0108a41,0xc(%esp)
f0102d58:	f0 
f0102d59:	c7 44 24 08 4c 88 10 	movl   $0xf010884c,0x8(%esp)
f0102d60:	f0 
f0102d61:	c7 44 24 04 b0 03 00 	movl   $0x3b0,0x4(%esp)
f0102d68:	00 
f0102d69:	c7 04 24 26 88 10 f0 	movl   $0xf0108826,(%esp)
f0102d70:	e8 10 d3 ff ff       	call   f0100085 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0102d75:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0102d78:	2b 15 b0 0e 1f f0    	sub    0xf01f0eb0,%edx
f0102d7e:	c1 fa 03             	sar    $0x3,%edx
f0102d81:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102d84:	89 d0                	mov    %edx,%eax
f0102d86:	c1 e8 0c             	shr    $0xc,%eax
f0102d89:	3b 05 a8 0e 1f f0    	cmp    0xf01f0ea8,%eax
f0102d8f:	72 20                	jb     f0102db1 <mem_init+0x53c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102d91:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102d95:	c7 44 24 08 80 80 10 	movl   $0xf0108080,0x8(%esp)
f0102d9c:	f0 
f0102d9d:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0102da4:	00 
f0102da5:	c7 04 24 32 88 10 f0 	movl   $0xf0108832,(%esp)
f0102dac:	e8 d4 d2 ff ff       	call   f0100085 <_panic>
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f0102db1:	80 ba 00 00 00 f0 00 	cmpb   $0x0,-0x10000000(%edx)
f0102db8:	75 11                	jne    f0102dcb <mem_init+0x556>
f0102dba:	8d 82 01 00 00 f0    	lea    -0xfffffff(%edx),%eax
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102dc0:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f0102dc6:	80 38 00             	cmpb   $0x0,(%eax)
f0102dc9:	74 24                	je     f0102def <mem_init+0x57a>
f0102dcb:	c7 44 24 0c 51 8a 10 	movl   $0xf0108a51,0xc(%esp)
f0102dd2:	f0 
f0102dd3:	c7 44 24 08 4c 88 10 	movl   $0xf010884c,0x8(%esp)
f0102dda:	f0 
f0102ddb:	c7 44 24 04 b3 03 00 	movl   $0x3b3,0x4(%esp)
f0102de2:	00 
f0102de3:	c7 04 24 26 88 10 f0 	movl   $0xf0108826,(%esp)
f0102dea:	e8 96 d2 ff ff       	call   f0100085 <_panic>
f0102def:	83 c0 01             	add    $0x1,%eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f0102df2:	39 d0                	cmp    %edx,%eax
f0102df4:	75 d0                	jne    f0102dc6 <mem_init+0x551>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f0102df6:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0102df9:	89 0d 50 02 1f f0    	mov    %ecx,0xf01f0250

	// free the pages we took
	page_free(pp0);
f0102dff:	89 34 24             	mov    %esi,(%esp)
f0102e02:	e8 c8 e8 ff ff       	call   f01016cf <page_free>
	page_free(pp1);
f0102e07:	89 3c 24             	mov    %edi,(%esp)
f0102e0a:	e8 c0 e8 ff ff       	call   f01016cf <page_free>
	page_free(pp2);
f0102e0f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102e12:	89 04 24             	mov    %eax,(%esp)
f0102e15:	e8 b5 e8 ff ff       	call   f01016cf <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0102e1a:	a1 50 02 1f f0       	mov    0xf01f0250,%eax
f0102e1f:	85 c0                	test   %eax,%eax
f0102e21:	74 09                	je     f0102e2c <mem_init+0x5b7>
		--nfree;
f0102e23:	83 eb 01             	sub    $0x1,%ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0102e26:	8b 00                	mov    (%eax),%eax
f0102e28:	85 c0                	test   %eax,%eax
f0102e2a:	75 f7                	jne    f0102e23 <mem_init+0x5ae>
		--nfree;
	assert(nfree == 0);
f0102e2c:	85 db                	test   %ebx,%ebx
f0102e2e:	74 24                	je     f0102e54 <mem_init+0x5df>
f0102e30:	c7 44 24 0c 5b 8a 10 	movl   $0xf0108a5b,0xc(%esp)
f0102e37:	f0 
f0102e38:	c7 44 24 08 4c 88 10 	movl   $0xf010884c,0x8(%esp)
f0102e3f:	f0 
f0102e40:	c7 44 24 04 c0 03 00 	movl   $0x3c0,0x4(%esp)
f0102e47:	00 
f0102e48:	c7 04 24 26 88 10 f0 	movl   $0xf0108826,(%esp)
f0102e4f:	e8 31 d2 ff ff       	call   f0100085 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f0102e54:	c7 04 24 78 8d 10 f0 	movl   $0xf0108d78,(%esp)
f0102e5b:	e8 5f 1c 00 00       	call   f0104abf <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102e60:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102e67:	e8 3b f2 ff ff       	call   f01020a7 <page_alloc>
f0102e6c:	89 c6                	mov    %eax,%esi
f0102e6e:	85 c0                	test   %eax,%eax
f0102e70:	75 24                	jne    f0102e96 <mem_init+0x621>
f0102e72:	c7 44 24 0c f9 88 10 	movl   $0xf01088f9,0xc(%esp)
f0102e79:	f0 
f0102e7a:	c7 44 24 08 4c 88 10 	movl   $0xf010884c,0x8(%esp)
f0102e81:	f0 
f0102e82:	c7 44 24 04 38 04 00 	movl   $0x438,0x4(%esp)
f0102e89:	00 
f0102e8a:	c7 04 24 26 88 10 f0 	movl   $0xf0108826,(%esp)
f0102e91:	e8 ef d1 ff ff       	call   f0100085 <_panic>
	assert((pp1 = page_alloc(0)));
f0102e96:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102e9d:	e8 05 f2 ff ff       	call   f01020a7 <page_alloc>
f0102ea2:	89 c7                	mov    %eax,%edi
f0102ea4:	85 c0                	test   %eax,%eax
f0102ea6:	75 24                	jne    f0102ecc <mem_init+0x657>
f0102ea8:	c7 44 24 0c 0f 89 10 	movl   $0xf010890f,0xc(%esp)
f0102eaf:	f0 
f0102eb0:	c7 44 24 08 4c 88 10 	movl   $0xf010884c,0x8(%esp)
f0102eb7:	f0 
f0102eb8:	c7 44 24 04 39 04 00 	movl   $0x439,0x4(%esp)
f0102ebf:	00 
f0102ec0:	c7 04 24 26 88 10 f0 	movl   $0xf0108826,(%esp)
f0102ec7:	e8 b9 d1 ff ff       	call   f0100085 <_panic>
	assert((pp2 = page_alloc(0)));
f0102ecc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102ed3:	e8 cf f1 ff ff       	call   f01020a7 <page_alloc>
f0102ed8:	89 c3                	mov    %eax,%ebx
f0102eda:	85 c0                	test   %eax,%eax
f0102edc:	75 24                	jne    f0102f02 <mem_init+0x68d>
f0102ede:	c7 44 24 0c 25 89 10 	movl   $0xf0108925,0xc(%esp)
f0102ee5:	f0 
f0102ee6:	c7 44 24 08 4c 88 10 	movl   $0xf010884c,0x8(%esp)
f0102eed:	f0 
f0102eee:	c7 44 24 04 3a 04 00 	movl   $0x43a,0x4(%esp)
f0102ef5:	00 
f0102ef6:	c7 04 24 26 88 10 f0 	movl   $0xf0108826,(%esp)
f0102efd:	e8 83 d1 ff ff       	call   f0100085 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0102f02:	39 fe                	cmp    %edi,%esi
f0102f04:	75 24                	jne    f0102f2a <mem_init+0x6b5>
f0102f06:	c7 44 24 0c ab 89 10 	movl   $0xf01089ab,0xc(%esp)
f0102f0d:	f0 
f0102f0e:	c7 44 24 08 4c 88 10 	movl   $0xf010884c,0x8(%esp)
f0102f15:	f0 
f0102f16:	c7 44 24 04 3d 04 00 	movl   $0x43d,0x4(%esp)
f0102f1d:	00 
f0102f1e:	c7 04 24 26 88 10 f0 	movl   $0xf0108826,(%esp)
f0102f25:	e8 5b d1 ff ff       	call   f0100085 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0102f2a:	39 c7                	cmp    %eax,%edi
f0102f2c:	74 04                	je     f0102f32 <mem_init+0x6bd>
f0102f2e:	39 c6                	cmp    %eax,%esi
f0102f30:	75 24                	jne    f0102f56 <mem_init+0x6e1>
f0102f32:	c7 44 24 0c 58 8d 10 	movl   $0xf0108d58,0xc(%esp)
f0102f39:	f0 
f0102f3a:	c7 44 24 08 4c 88 10 	movl   $0xf010884c,0x8(%esp)
f0102f41:	f0 
f0102f42:	c7 44 24 04 3e 04 00 	movl   $0x43e,0x4(%esp)
f0102f49:	00 
f0102f4a:	c7 04 24 26 88 10 f0 	movl   $0xf0108826,(%esp)
f0102f51:	e8 2f d1 ff ff       	call   f0100085 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0102f56:	8b 15 50 02 1f f0    	mov    0xf01f0250,%edx
f0102f5c:	89 55 c8             	mov    %edx,-0x38(%ebp)
	page_free_list = 0;
f0102f5f:	c7 05 50 02 1f f0 00 	movl   $0x0,0xf01f0250
f0102f66:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0102f69:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102f70:	e8 32 f1 ff ff       	call   f01020a7 <page_alloc>
f0102f75:	85 c0                	test   %eax,%eax
f0102f77:	74 24                	je     f0102f9d <mem_init+0x728>
f0102f79:	c7 44 24 0c 14 8a 10 	movl   $0xf0108a14,0xc(%esp)
f0102f80:	f0 
f0102f81:	c7 44 24 08 4c 88 10 	movl   $0xf010884c,0x8(%esp)
f0102f88:	f0 
f0102f89:	c7 44 24 04 45 04 00 	movl   $0x445,0x4(%esp)
f0102f90:	00 
f0102f91:	c7 04 24 26 88 10 f0 	movl   $0xf0108826,(%esp)
f0102f98:	e8 e8 d0 ff ff       	call   f0100085 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0102f9d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0102fa0:	89 44 24 08          	mov    %eax,0x8(%esp)
f0102fa4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102fab:	00 
f0102fac:	a1 ac 0e 1f f0       	mov    0xf01f0eac,%eax
f0102fb1:	89 04 24             	mov    %eax,(%esp)
f0102fb4:	e8 36 f3 ff ff       	call   f01022ef <page_lookup>
f0102fb9:	85 c0                	test   %eax,%eax
f0102fbb:	74 24                	je     f0102fe1 <mem_init+0x76c>
f0102fbd:	c7 44 24 0c 98 8d 10 	movl   $0xf0108d98,0xc(%esp)
f0102fc4:	f0 
f0102fc5:	c7 44 24 08 4c 88 10 	movl   $0xf010884c,0x8(%esp)
f0102fcc:	f0 
f0102fcd:	c7 44 24 04 48 04 00 	movl   $0x448,0x4(%esp)
f0102fd4:	00 
f0102fd5:	c7 04 24 26 88 10 f0 	movl   $0xf0108826,(%esp)
f0102fdc:	e8 a4 d0 ff ff       	call   f0100085 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0102fe1:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102fe8:	00 
f0102fe9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102ff0:	00 
f0102ff1:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0102ff5:	a1 ac 0e 1f f0       	mov    0xf01f0eac,%eax
f0102ffa:	89 04 24             	mov    %eax,(%esp)
f0102ffd:	e8 b9 f3 ff ff       	call   f01023bb <page_insert>
f0103002:	85 c0                	test   %eax,%eax
f0103004:	78 24                	js     f010302a <mem_init+0x7b5>
f0103006:	c7 44 24 0c d0 8d 10 	movl   $0xf0108dd0,0xc(%esp)
f010300d:	f0 
f010300e:	c7 44 24 08 4c 88 10 	movl   $0xf010884c,0x8(%esp)
f0103015:	f0 
f0103016:	c7 44 24 04 4b 04 00 	movl   $0x44b,0x4(%esp)
f010301d:	00 
f010301e:	c7 04 24 26 88 10 f0 	movl   $0xf0108826,(%esp)
f0103025:	e8 5b d0 ff ff       	call   f0100085 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f010302a:	89 34 24             	mov    %esi,(%esp)
f010302d:	e8 9d e6 ff ff       	call   f01016cf <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0103032:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0103039:	00 
f010303a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0103041:	00 
f0103042:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103046:	a1 ac 0e 1f f0       	mov    0xf01f0eac,%eax
f010304b:	89 04 24             	mov    %eax,(%esp)
f010304e:	e8 68 f3 ff ff       	call   f01023bb <page_insert>
f0103053:	85 c0                	test   %eax,%eax
f0103055:	74 24                	je     f010307b <mem_init+0x806>
f0103057:	c7 44 24 0c 00 8e 10 	movl   $0xf0108e00,0xc(%esp)
f010305e:	f0 
f010305f:	c7 44 24 08 4c 88 10 	movl   $0xf010884c,0x8(%esp)
f0103066:	f0 
f0103067:	c7 44 24 04 4f 04 00 	movl   $0x44f,0x4(%esp)
f010306e:	00 
f010306f:	c7 04 24 26 88 10 f0 	movl   $0xf0108826,(%esp)
f0103076:	e8 0a d0 ff ff       	call   f0100085 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010307b:	a1 ac 0e 1f f0       	mov    0xf01f0eac,%eax
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0103080:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f0103083:	8b 08                	mov    (%eax),%ecx
f0103085:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f010308b:	89 f2                	mov    %esi,%edx
f010308d:	2b 15 b0 0e 1f f0    	sub    0xf01f0eb0,%edx
f0103093:	c1 fa 03             	sar    $0x3,%edx
f0103096:	c1 e2 0c             	shl    $0xc,%edx
f0103099:	39 d1                	cmp    %edx,%ecx
f010309b:	74 24                	je     f01030c1 <mem_init+0x84c>
f010309d:	c7 44 24 0c 04 8d 10 	movl   $0xf0108d04,0xc(%esp)
f01030a4:	f0 
f01030a5:	c7 44 24 08 4c 88 10 	movl   $0xf010884c,0x8(%esp)
f01030ac:	f0 
f01030ad:	c7 44 24 04 50 04 00 	movl   $0x450,0x4(%esp)
f01030b4:	00 
f01030b5:	c7 04 24 26 88 10 f0 	movl   $0xf0108826,(%esp)
f01030bc:	e8 c4 cf ff ff       	call   f0100085 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f01030c1:	ba 00 00 00 00       	mov    $0x0,%edx
f01030c6:	e8 d3 eb ff ff       	call   f0101c9e <check_va2pa>
f01030cb:	89 7d d0             	mov    %edi,-0x30(%ebp)
f01030ce:	89 fa                	mov    %edi,%edx
f01030d0:	2b 15 b0 0e 1f f0    	sub    0xf01f0eb0,%edx
f01030d6:	c1 fa 03             	sar    $0x3,%edx
f01030d9:	c1 e2 0c             	shl    $0xc,%edx
f01030dc:	39 d0                	cmp    %edx,%eax
f01030de:	74 24                	je     f0103104 <mem_init+0x88f>
f01030e0:	c7 44 24 0c 30 8e 10 	movl   $0xf0108e30,0xc(%esp)
f01030e7:	f0 
f01030e8:	c7 44 24 08 4c 88 10 	movl   $0xf010884c,0x8(%esp)
f01030ef:	f0 
f01030f0:	c7 44 24 04 51 04 00 	movl   $0x451,0x4(%esp)
f01030f7:	00 
f01030f8:	c7 04 24 26 88 10 f0 	movl   $0xf0108826,(%esp)
f01030ff:	e8 81 cf ff ff       	call   f0100085 <_panic>
	assert(pp1->pp_ref == 1);
f0103104:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0103109:	74 24                	je     f010312f <mem_init+0x8ba>
f010310b:	c7 44 24 0c 3b 89 10 	movl   $0xf010893b,0xc(%esp)
f0103112:	f0 
f0103113:	c7 44 24 08 4c 88 10 	movl   $0xf010884c,0x8(%esp)
f010311a:	f0 
f010311b:	c7 44 24 04 52 04 00 	movl   $0x452,0x4(%esp)
f0103122:	00 
f0103123:	c7 04 24 26 88 10 f0 	movl   $0xf0108826,(%esp)
f010312a:	e8 56 cf ff ff       	call   f0100085 <_panic>
	assert(pp0->pp_ref == 1);
f010312f:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0103134:	74 24                	je     f010315a <mem_init+0x8e5>
f0103136:	c7 44 24 0c 7f 89 10 	movl   $0xf010897f,0xc(%esp)
f010313d:	f0 
f010313e:	c7 44 24 08 4c 88 10 	movl   $0xf010884c,0x8(%esp)
f0103145:	f0 
f0103146:	c7 44 24 04 53 04 00 	movl   $0x453,0x4(%esp)
f010314d:	00 
f010314e:	c7 04 24 26 88 10 f0 	movl   $0xf0108826,(%esp)
f0103155:	e8 2b cf ff ff       	call   f0100085 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f010315a:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0103161:	00 
f0103162:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103169:	00 
f010316a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010316e:	a1 ac 0e 1f f0       	mov    0xf01f0eac,%eax
f0103173:	89 04 24             	mov    %eax,(%esp)
f0103176:	e8 40 f2 ff ff       	call   f01023bb <page_insert>
f010317b:	85 c0                	test   %eax,%eax
f010317d:	74 24                	je     f01031a3 <mem_init+0x92e>
f010317f:	c7 44 24 0c 60 8e 10 	movl   $0xf0108e60,0xc(%esp)
f0103186:	f0 
f0103187:	c7 44 24 08 4c 88 10 	movl   $0xf010884c,0x8(%esp)
f010318e:	f0 
f010318f:	c7 44 24 04 56 04 00 	movl   $0x456,0x4(%esp)
f0103196:	00 
f0103197:	c7 04 24 26 88 10 f0 	movl   $0xf0108826,(%esp)
f010319e:	e8 e2 ce ff ff       	call   f0100085 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01031a3:	ba 00 10 00 00       	mov    $0x1000,%edx
f01031a8:	a1 ac 0e 1f f0       	mov    0xf01f0eac,%eax
f01031ad:	e8 ec ea ff ff       	call   f0101c9e <check_va2pa>
f01031b2:	89 5d cc             	mov    %ebx,-0x34(%ebp)
f01031b5:	89 da                	mov    %ebx,%edx
f01031b7:	2b 15 b0 0e 1f f0    	sub    0xf01f0eb0,%edx
f01031bd:	c1 fa 03             	sar    $0x3,%edx
f01031c0:	c1 e2 0c             	shl    $0xc,%edx
f01031c3:	39 d0                	cmp    %edx,%eax
f01031c5:	74 24                	je     f01031eb <mem_init+0x976>
f01031c7:	c7 44 24 0c 9c 8e 10 	movl   $0xf0108e9c,0xc(%esp)
f01031ce:	f0 
f01031cf:	c7 44 24 08 4c 88 10 	movl   $0xf010884c,0x8(%esp)
f01031d6:	f0 
f01031d7:	c7 44 24 04 57 04 00 	movl   $0x457,0x4(%esp)
f01031de:	00 
f01031df:	c7 04 24 26 88 10 f0 	movl   $0xf0108826,(%esp)
f01031e6:	e8 9a ce ff ff       	call   f0100085 <_panic>
	assert(pp2->pp_ref == 1);
f01031eb:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01031f0:	74 24                	je     f0103216 <mem_init+0x9a1>
f01031f2:	c7 44 24 0c 4c 89 10 	movl   $0xf010894c,0xc(%esp)
f01031f9:	f0 
f01031fa:	c7 44 24 08 4c 88 10 	movl   $0xf010884c,0x8(%esp)
f0103201:	f0 
f0103202:	c7 44 24 04 58 04 00 	movl   $0x458,0x4(%esp)
f0103209:	00 
f010320a:	c7 04 24 26 88 10 f0 	movl   $0xf0108826,(%esp)
f0103211:	e8 6f ce ff ff       	call   f0100085 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0103216:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010321d:	e8 85 ee ff ff       	call   f01020a7 <page_alloc>
f0103222:	85 c0                	test   %eax,%eax
f0103224:	74 24                	je     f010324a <mem_init+0x9d5>
f0103226:	c7 44 24 0c 14 8a 10 	movl   $0xf0108a14,0xc(%esp)
f010322d:	f0 
f010322e:	c7 44 24 08 4c 88 10 	movl   $0xf010884c,0x8(%esp)
f0103235:	f0 
f0103236:	c7 44 24 04 5b 04 00 	movl   $0x45b,0x4(%esp)
f010323d:	00 
f010323e:	c7 04 24 26 88 10 f0 	movl   $0xf0108826,(%esp)
f0103245:	e8 3b ce ff ff       	call   f0100085 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f010324a:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0103251:	00 
f0103252:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103259:	00 
f010325a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010325e:	a1 ac 0e 1f f0       	mov    0xf01f0eac,%eax
f0103263:	89 04 24             	mov    %eax,(%esp)
f0103266:	e8 50 f1 ff ff       	call   f01023bb <page_insert>
f010326b:	85 c0                	test   %eax,%eax
f010326d:	74 24                	je     f0103293 <mem_init+0xa1e>
f010326f:	c7 44 24 0c 60 8e 10 	movl   $0xf0108e60,0xc(%esp)
f0103276:	f0 
f0103277:	c7 44 24 08 4c 88 10 	movl   $0xf010884c,0x8(%esp)
f010327e:	f0 
f010327f:	c7 44 24 04 5e 04 00 	movl   $0x45e,0x4(%esp)
f0103286:	00 
f0103287:	c7 04 24 26 88 10 f0 	movl   $0xf0108826,(%esp)
f010328e:	e8 f2 cd ff ff       	call   f0100085 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0103293:	ba 00 10 00 00       	mov    $0x1000,%edx
f0103298:	a1 ac 0e 1f f0       	mov    0xf01f0eac,%eax
f010329d:	e8 fc e9 ff ff       	call   f0101c9e <check_va2pa>
f01032a2:	8b 55 cc             	mov    -0x34(%ebp),%edx
f01032a5:	2b 15 b0 0e 1f f0    	sub    0xf01f0eb0,%edx
f01032ab:	c1 fa 03             	sar    $0x3,%edx
f01032ae:	c1 e2 0c             	shl    $0xc,%edx
f01032b1:	39 d0                	cmp    %edx,%eax
f01032b3:	74 24                	je     f01032d9 <mem_init+0xa64>
f01032b5:	c7 44 24 0c 9c 8e 10 	movl   $0xf0108e9c,0xc(%esp)
f01032bc:	f0 
f01032bd:	c7 44 24 08 4c 88 10 	movl   $0xf010884c,0x8(%esp)
f01032c4:	f0 
f01032c5:	c7 44 24 04 5f 04 00 	movl   $0x45f,0x4(%esp)
f01032cc:	00 
f01032cd:	c7 04 24 26 88 10 f0 	movl   $0xf0108826,(%esp)
f01032d4:	e8 ac cd ff ff       	call   f0100085 <_panic>
	assert(pp2->pp_ref == 1);
f01032d9:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01032de:	74 24                	je     f0103304 <mem_init+0xa8f>
f01032e0:	c7 44 24 0c 4c 89 10 	movl   $0xf010894c,0xc(%esp)
f01032e7:	f0 
f01032e8:	c7 44 24 08 4c 88 10 	movl   $0xf010884c,0x8(%esp)
f01032ef:	f0 
f01032f0:	c7 44 24 04 60 04 00 	movl   $0x460,0x4(%esp)
f01032f7:	00 
f01032f8:	c7 04 24 26 88 10 f0 	movl   $0xf0108826,(%esp)
f01032ff:	e8 81 cd ff ff       	call   f0100085 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0103304:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010330b:	e8 97 ed ff ff       	call   f01020a7 <page_alloc>
f0103310:	85 c0                	test   %eax,%eax
f0103312:	74 24                	je     f0103338 <mem_init+0xac3>
f0103314:	c7 44 24 0c 14 8a 10 	movl   $0xf0108a14,0xc(%esp)
f010331b:	f0 
f010331c:	c7 44 24 08 4c 88 10 	movl   $0xf010884c,0x8(%esp)
f0103323:	f0 
f0103324:	c7 44 24 04 64 04 00 	movl   $0x464,0x4(%esp)
f010332b:	00 
f010332c:	c7 04 24 26 88 10 f0 	movl   $0xf0108826,(%esp)
f0103333:	e8 4d cd ff ff       	call   f0100085 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0103338:	a1 ac 0e 1f f0       	mov    0xf01f0eac,%eax
f010333d:	8b 00                	mov    (%eax),%eax
f010333f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103344:	89 c2                	mov    %eax,%edx
f0103346:	c1 ea 0c             	shr    $0xc,%edx
f0103349:	3b 15 a8 0e 1f f0    	cmp    0xf01f0ea8,%edx
f010334f:	72 20                	jb     f0103371 <mem_init+0xafc>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103351:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103355:	c7 44 24 08 80 80 10 	movl   $0xf0108080,0x8(%esp)
f010335c:	f0 
f010335d:	c7 44 24 04 67 04 00 	movl   $0x467,0x4(%esp)
f0103364:	00 
f0103365:	c7 04 24 26 88 10 f0 	movl   $0xf0108826,(%esp)
f010336c:	e8 14 cd ff ff       	call   f0100085 <_panic>
f0103371:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0103376:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0103379:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0103380:	00 
f0103381:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0103388:	00 
f0103389:	a1 ac 0e 1f f0       	mov    0xf01f0eac,%eax
f010338e:	89 04 24             	mov    %eax,(%esp)
f0103391:	e8 8f ed ff ff       	call   f0102125 <pgdir_walk>
f0103396:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0103399:	83 c2 04             	add    $0x4,%edx
f010339c:	39 d0                	cmp    %edx,%eax
f010339e:	74 24                	je     f01033c4 <mem_init+0xb4f>
f01033a0:	c7 44 24 0c cc 8e 10 	movl   $0xf0108ecc,0xc(%esp)
f01033a7:	f0 
f01033a8:	c7 44 24 08 4c 88 10 	movl   $0xf010884c,0x8(%esp)
f01033af:	f0 
f01033b0:	c7 44 24 04 68 04 00 	movl   $0x468,0x4(%esp)
f01033b7:	00 
f01033b8:	c7 04 24 26 88 10 f0 	movl   $0xf0108826,(%esp)
f01033bf:	e8 c1 cc ff ff       	call   f0100085 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f01033c4:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f01033cb:	00 
f01033cc:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01033d3:	00 
f01033d4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01033d8:	a1 ac 0e 1f f0       	mov    0xf01f0eac,%eax
f01033dd:	89 04 24             	mov    %eax,(%esp)
f01033e0:	e8 d6 ef ff ff       	call   f01023bb <page_insert>
f01033e5:	85 c0                	test   %eax,%eax
f01033e7:	74 24                	je     f010340d <mem_init+0xb98>
f01033e9:	c7 44 24 0c 0c 8f 10 	movl   $0xf0108f0c,0xc(%esp)
f01033f0:	f0 
f01033f1:	c7 44 24 08 4c 88 10 	movl   $0xf010884c,0x8(%esp)
f01033f8:	f0 
f01033f9:	c7 44 24 04 6b 04 00 	movl   $0x46b,0x4(%esp)
f0103400:	00 
f0103401:	c7 04 24 26 88 10 f0 	movl   $0xf0108826,(%esp)
f0103408:	e8 78 cc ff ff       	call   f0100085 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f010340d:	ba 00 10 00 00       	mov    $0x1000,%edx
f0103412:	a1 ac 0e 1f f0       	mov    0xf01f0eac,%eax
f0103417:	e8 82 e8 ff ff       	call   f0101c9e <check_va2pa>
f010341c:	8b 55 cc             	mov    -0x34(%ebp),%edx
f010341f:	2b 15 b0 0e 1f f0    	sub    0xf01f0eb0,%edx
f0103425:	c1 fa 03             	sar    $0x3,%edx
f0103428:	c1 e2 0c             	shl    $0xc,%edx
f010342b:	39 d0                	cmp    %edx,%eax
f010342d:	74 24                	je     f0103453 <mem_init+0xbde>
f010342f:	c7 44 24 0c 9c 8e 10 	movl   $0xf0108e9c,0xc(%esp)
f0103436:	f0 
f0103437:	c7 44 24 08 4c 88 10 	movl   $0xf010884c,0x8(%esp)
f010343e:	f0 
f010343f:	c7 44 24 04 6c 04 00 	movl   $0x46c,0x4(%esp)
f0103446:	00 
f0103447:	c7 04 24 26 88 10 f0 	movl   $0xf0108826,(%esp)
f010344e:	e8 32 cc ff ff       	call   f0100085 <_panic>
	assert(pp2->pp_ref == 1);
f0103453:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0103458:	74 24                	je     f010347e <mem_init+0xc09>
f010345a:	c7 44 24 0c 4c 89 10 	movl   $0xf010894c,0xc(%esp)
f0103461:	f0 
f0103462:	c7 44 24 08 4c 88 10 	movl   $0xf010884c,0x8(%esp)
f0103469:	f0 
f010346a:	c7 44 24 04 6d 04 00 	movl   $0x46d,0x4(%esp)
f0103471:	00 
f0103472:	c7 04 24 26 88 10 f0 	movl   $0xf0108826,(%esp)
f0103479:	e8 07 cc ff ff       	call   f0100085 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f010347e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0103485:	00 
f0103486:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f010348d:	00 
f010348e:	a1 ac 0e 1f f0       	mov    0xf01f0eac,%eax
f0103493:	89 04 24             	mov    %eax,(%esp)
f0103496:	e8 8a ec ff ff       	call   f0102125 <pgdir_walk>
f010349b:	f6 00 04             	testb  $0x4,(%eax)
f010349e:	75 24                	jne    f01034c4 <mem_init+0xc4f>
f01034a0:	c7 44 24 0c 4c 8f 10 	movl   $0xf0108f4c,0xc(%esp)
f01034a7:	f0 
f01034a8:	c7 44 24 08 4c 88 10 	movl   $0xf010884c,0x8(%esp)
f01034af:	f0 
f01034b0:	c7 44 24 04 6e 04 00 	movl   $0x46e,0x4(%esp)
f01034b7:	00 
f01034b8:	c7 04 24 26 88 10 f0 	movl   $0xf0108826,(%esp)
f01034bf:	e8 c1 cb ff ff       	call   f0100085 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f01034c4:	a1 ac 0e 1f f0       	mov    0xf01f0eac,%eax
f01034c9:	f6 00 04             	testb  $0x4,(%eax)
f01034cc:	75 24                	jne    f01034f2 <mem_init+0xc7d>
f01034ce:	c7 44 24 0c 66 8a 10 	movl   $0xf0108a66,0xc(%esp)
f01034d5:	f0 
f01034d6:	c7 44 24 08 4c 88 10 	movl   $0xf010884c,0x8(%esp)
f01034dd:	f0 
f01034de:	c7 44 24 04 6f 04 00 	movl   $0x46f,0x4(%esp)
f01034e5:	00 
f01034e6:	c7 04 24 26 88 10 f0 	movl   $0xf0108826,(%esp)
f01034ed:	e8 93 cb ff ff       	call   f0100085 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f01034f2:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01034f9:	00 
f01034fa:	c7 44 24 08 00 00 40 	movl   $0x400000,0x8(%esp)
f0103501:	00 
f0103502:	89 74 24 04          	mov    %esi,0x4(%esp)
f0103506:	89 04 24             	mov    %eax,(%esp)
f0103509:	e8 ad ee ff ff       	call   f01023bb <page_insert>
f010350e:	85 c0                	test   %eax,%eax
f0103510:	78 24                	js     f0103536 <mem_init+0xcc1>
f0103512:	c7 44 24 0c 80 8f 10 	movl   $0xf0108f80,0xc(%esp)
f0103519:	f0 
f010351a:	c7 44 24 08 4c 88 10 	movl   $0xf010884c,0x8(%esp)
f0103521:	f0 
f0103522:	c7 44 24 04 72 04 00 	movl   $0x472,0x4(%esp)
f0103529:	00 
f010352a:	c7 04 24 26 88 10 f0 	movl   $0xf0108826,(%esp)
f0103531:	e8 4f cb ff ff       	call   f0100085 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0103536:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f010353d:	00 
f010353e:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103545:	00 
f0103546:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010354a:	a1 ac 0e 1f f0       	mov    0xf01f0eac,%eax
f010354f:	89 04 24             	mov    %eax,(%esp)
f0103552:	e8 64 ee ff ff       	call   f01023bb <page_insert>
f0103557:	85 c0                	test   %eax,%eax
f0103559:	74 24                	je     f010357f <mem_init+0xd0a>
f010355b:	c7 44 24 0c b8 8f 10 	movl   $0xf0108fb8,0xc(%esp)
f0103562:	f0 
f0103563:	c7 44 24 08 4c 88 10 	movl   $0xf010884c,0x8(%esp)
f010356a:	f0 
f010356b:	c7 44 24 04 75 04 00 	movl   $0x475,0x4(%esp)
f0103572:	00 
f0103573:	c7 04 24 26 88 10 f0 	movl   $0xf0108826,(%esp)
f010357a:	e8 06 cb ff ff       	call   f0100085 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f010357f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0103586:	00 
f0103587:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f010358e:	00 
f010358f:	a1 ac 0e 1f f0       	mov    0xf01f0eac,%eax
f0103594:	89 04 24             	mov    %eax,(%esp)
f0103597:	e8 89 eb ff ff       	call   f0102125 <pgdir_walk>
f010359c:	f6 00 04             	testb  $0x4,(%eax)
f010359f:	74 24                	je     f01035c5 <mem_init+0xd50>
f01035a1:	c7 44 24 0c f4 8f 10 	movl   $0xf0108ff4,0xc(%esp)
f01035a8:	f0 
f01035a9:	c7 44 24 08 4c 88 10 	movl   $0xf010884c,0x8(%esp)
f01035b0:	f0 
f01035b1:	c7 44 24 04 76 04 00 	movl   $0x476,0x4(%esp)
f01035b8:	00 
f01035b9:	c7 04 24 26 88 10 f0 	movl   $0xf0108826,(%esp)
f01035c0:	e8 c0 ca ff ff       	call   f0100085 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f01035c5:	ba 00 00 00 00       	mov    $0x0,%edx
f01035ca:	a1 ac 0e 1f f0       	mov    0xf01f0eac,%eax
f01035cf:	e8 ca e6 ff ff       	call   f0101c9e <check_va2pa>
f01035d4:	8b 55 d0             	mov    -0x30(%ebp),%edx
f01035d7:	2b 15 b0 0e 1f f0    	sub    0xf01f0eb0,%edx
f01035dd:	c1 fa 03             	sar    $0x3,%edx
f01035e0:	c1 e2 0c             	shl    $0xc,%edx
f01035e3:	39 d0                	cmp    %edx,%eax
f01035e5:	74 24                	je     f010360b <mem_init+0xd96>
f01035e7:	c7 44 24 0c 2c 90 10 	movl   $0xf010902c,0xc(%esp)
f01035ee:	f0 
f01035ef:	c7 44 24 08 4c 88 10 	movl   $0xf010884c,0x8(%esp)
f01035f6:	f0 
f01035f7:	c7 44 24 04 79 04 00 	movl   $0x479,0x4(%esp)
f01035fe:	00 
f01035ff:	c7 04 24 26 88 10 f0 	movl   $0xf0108826,(%esp)
f0103606:	e8 7a ca ff ff       	call   f0100085 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f010360b:	ba 00 10 00 00       	mov    $0x1000,%edx
f0103610:	a1 ac 0e 1f f0       	mov    0xf01f0eac,%eax
f0103615:	e8 84 e6 ff ff       	call   f0101c9e <check_va2pa>
f010361a:	8b 55 d0             	mov    -0x30(%ebp),%edx
f010361d:	2b 15 b0 0e 1f f0    	sub    0xf01f0eb0,%edx
f0103623:	c1 fa 03             	sar    $0x3,%edx
f0103626:	c1 e2 0c             	shl    $0xc,%edx
f0103629:	39 d0                	cmp    %edx,%eax
f010362b:	74 24                	je     f0103651 <mem_init+0xddc>
f010362d:	c7 44 24 0c 58 90 10 	movl   $0xf0109058,0xc(%esp)
f0103634:	f0 
f0103635:	c7 44 24 08 4c 88 10 	movl   $0xf010884c,0x8(%esp)
f010363c:	f0 
f010363d:	c7 44 24 04 7a 04 00 	movl   $0x47a,0x4(%esp)
f0103644:	00 
f0103645:	c7 04 24 26 88 10 f0 	movl   $0xf0108826,(%esp)
f010364c:	e8 34 ca ff ff       	call   f0100085 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0103651:	66 83 7f 04 02       	cmpw   $0x2,0x4(%edi)
f0103656:	74 24                	je     f010367c <mem_init+0xe07>
f0103658:	c7 44 24 0c 7c 8a 10 	movl   $0xf0108a7c,0xc(%esp)
f010365f:	f0 
f0103660:	c7 44 24 08 4c 88 10 	movl   $0xf010884c,0x8(%esp)
f0103667:	f0 
f0103668:	c7 44 24 04 7c 04 00 	movl   $0x47c,0x4(%esp)
f010366f:	00 
f0103670:	c7 04 24 26 88 10 f0 	movl   $0xf0108826,(%esp)
f0103677:	e8 09 ca ff ff       	call   f0100085 <_panic>
	assert(pp2->pp_ref == 0);
f010367c:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0103681:	74 24                	je     f01036a7 <mem_init+0xe32>
f0103683:	c7 44 24 0c 6e 89 10 	movl   $0xf010896e,0xc(%esp)
f010368a:	f0 
f010368b:	c7 44 24 08 4c 88 10 	movl   $0xf010884c,0x8(%esp)
f0103692:	f0 
f0103693:	c7 44 24 04 7d 04 00 	movl   $0x47d,0x4(%esp)
f010369a:	00 
f010369b:	c7 04 24 26 88 10 f0 	movl   $0xf0108826,(%esp)
f01036a2:	e8 de c9 ff ff       	call   f0100085 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f01036a7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01036ae:	e8 f4 e9 ff ff       	call   f01020a7 <page_alloc>
f01036b3:	85 c0                	test   %eax,%eax
f01036b5:	74 04                	je     f01036bb <mem_init+0xe46>
f01036b7:	39 c3                	cmp    %eax,%ebx
f01036b9:	74 24                	je     f01036df <mem_init+0xe6a>
f01036bb:	c7 44 24 0c 88 90 10 	movl   $0xf0109088,0xc(%esp)
f01036c2:	f0 
f01036c3:	c7 44 24 08 4c 88 10 	movl   $0xf010884c,0x8(%esp)
f01036ca:	f0 
f01036cb:	c7 44 24 04 80 04 00 	movl   $0x480,0x4(%esp)
f01036d2:	00 
f01036d3:	c7 04 24 26 88 10 f0 	movl   $0xf0108826,(%esp)
f01036da:	e8 a6 c9 ff ff       	call   f0100085 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f01036df:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01036e6:	00 
f01036e7:	a1 ac 0e 1f f0       	mov    0xf01f0eac,%eax
f01036ec:	89 04 24             	mov    %eax,(%esp)
f01036ef:	e8 6c ec ff ff       	call   f0102360 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01036f4:	ba 00 00 00 00       	mov    $0x0,%edx
f01036f9:	a1 ac 0e 1f f0       	mov    0xf01f0eac,%eax
f01036fe:	e8 9b e5 ff ff       	call   f0101c9e <check_va2pa>
f0103703:	83 f8 ff             	cmp    $0xffffffff,%eax
f0103706:	74 24                	je     f010372c <mem_init+0xeb7>
f0103708:	c7 44 24 0c ac 90 10 	movl   $0xf01090ac,0xc(%esp)
f010370f:	f0 
f0103710:	c7 44 24 08 4c 88 10 	movl   $0xf010884c,0x8(%esp)
f0103717:	f0 
f0103718:	c7 44 24 04 84 04 00 	movl   $0x484,0x4(%esp)
f010371f:	00 
f0103720:	c7 04 24 26 88 10 f0 	movl   $0xf0108826,(%esp)
f0103727:	e8 59 c9 ff ff       	call   f0100085 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f010372c:	ba 00 10 00 00       	mov    $0x1000,%edx
f0103731:	a1 ac 0e 1f f0       	mov    0xf01f0eac,%eax
f0103736:	e8 63 e5 ff ff       	call   f0101c9e <check_va2pa>
f010373b:	8b 55 d0             	mov    -0x30(%ebp),%edx
f010373e:	2b 15 b0 0e 1f f0    	sub    0xf01f0eb0,%edx
f0103744:	c1 fa 03             	sar    $0x3,%edx
f0103747:	c1 e2 0c             	shl    $0xc,%edx
f010374a:	39 d0                	cmp    %edx,%eax
f010374c:	74 24                	je     f0103772 <mem_init+0xefd>
f010374e:	c7 44 24 0c 58 90 10 	movl   $0xf0109058,0xc(%esp)
f0103755:	f0 
f0103756:	c7 44 24 08 4c 88 10 	movl   $0xf010884c,0x8(%esp)
f010375d:	f0 
f010375e:	c7 44 24 04 85 04 00 	movl   $0x485,0x4(%esp)
f0103765:	00 
f0103766:	c7 04 24 26 88 10 f0 	movl   $0xf0108826,(%esp)
f010376d:	e8 13 c9 ff ff       	call   f0100085 <_panic>
	assert(pp1->pp_ref == 1);
f0103772:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0103777:	74 24                	je     f010379d <mem_init+0xf28>
f0103779:	c7 44 24 0c 3b 89 10 	movl   $0xf010893b,0xc(%esp)
f0103780:	f0 
f0103781:	c7 44 24 08 4c 88 10 	movl   $0xf010884c,0x8(%esp)
f0103788:	f0 
f0103789:	c7 44 24 04 86 04 00 	movl   $0x486,0x4(%esp)
f0103790:	00 
f0103791:	c7 04 24 26 88 10 f0 	movl   $0xf0108826,(%esp)
f0103798:	e8 e8 c8 ff ff       	call   f0100085 <_panic>
	assert(pp2->pp_ref == 0);
f010379d:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01037a2:	74 24                	je     f01037c8 <mem_init+0xf53>
f01037a4:	c7 44 24 0c 6e 89 10 	movl   $0xf010896e,0xc(%esp)
f01037ab:	f0 
f01037ac:	c7 44 24 08 4c 88 10 	movl   $0xf010884c,0x8(%esp)
f01037b3:	f0 
f01037b4:	c7 44 24 04 87 04 00 	movl   $0x487,0x4(%esp)
f01037bb:	00 
f01037bc:	c7 04 24 26 88 10 f0 	movl   $0xf0108826,(%esp)
f01037c3:	e8 bd c8 ff ff       	call   f0100085 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f01037c8:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01037cf:	00 
f01037d0:	a1 ac 0e 1f f0       	mov    0xf01f0eac,%eax
f01037d5:	89 04 24             	mov    %eax,(%esp)
f01037d8:	e8 83 eb ff ff       	call   f0102360 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01037dd:	ba 00 00 00 00       	mov    $0x0,%edx
f01037e2:	a1 ac 0e 1f f0       	mov    0xf01f0eac,%eax
f01037e7:	e8 b2 e4 ff ff       	call   f0101c9e <check_va2pa>
f01037ec:	83 f8 ff             	cmp    $0xffffffff,%eax
f01037ef:	74 24                	je     f0103815 <mem_init+0xfa0>
f01037f1:	c7 44 24 0c ac 90 10 	movl   $0xf01090ac,0xc(%esp)
f01037f8:	f0 
f01037f9:	c7 44 24 08 4c 88 10 	movl   $0xf010884c,0x8(%esp)
f0103800:	f0 
f0103801:	c7 44 24 04 8b 04 00 	movl   $0x48b,0x4(%esp)
f0103808:	00 
f0103809:	c7 04 24 26 88 10 f0 	movl   $0xf0108826,(%esp)
f0103810:	e8 70 c8 ff ff       	call   f0100085 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0103815:	ba 00 10 00 00       	mov    $0x1000,%edx
f010381a:	a1 ac 0e 1f f0       	mov    0xf01f0eac,%eax
f010381f:	e8 7a e4 ff ff       	call   f0101c9e <check_va2pa>
f0103824:	83 f8 ff             	cmp    $0xffffffff,%eax
f0103827:	74 24                	je     f010384d <mem_init+0xfd8>
f0103829:	c7 44 24 0c d0 90 10 	movl   $0xf01090d0,0xc(%esp)
f0103830:	f0 
f0103831:	c7 44 24 08 4c 88 10 	movl   $0xf010884c,0x8(%esp)
f0103838:	f0 
f0103839:	c7 44 24 04 8c 04 00 	movl   $0x48c,0x4(%esp)
f0103840:	00 
f0103841:	c7 04 24 26 88 10 f0 	movl   $0xf0108826,(%esp)
f0103848:	e8 38 c8 ff ff       	call   f0100085 <_panic>
	assert(pp1->pp_ref == 0);
f010384d:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0103852:	74 24                	je     f0103878 <mem_init+0x1003>
f0103854:	c7 44 24 0c 5d 89 10 	movl   $0xf010895d,0xc(%esp)
f010385b:	f0 
f010385c:	c7 44 24 08 4c 88 10 	movl   $0xf010884c,0x8(%esp)
f0103863:	f0 
f0103864:	c7 44 24 04 8d 04 00 	movl   $0x48d,0x4(%esp)
f010386b:	00 
f010386c:	c7 04 24 26 88 10 f0 	movl   $0xf0108826,(%esp)
f0103873:	e8 0d c8 ff ff       	call   f0100085 <_panic>
	assert(pp2->pp_ref == 0);
f0103878:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f010387d:	74 24                	je     f01038a3 <mem_init+0x102e>
f010387f:	c7 44 24 0c 6e 89 10 	movl   $0xf010896e,0xc(%esp)
f0103886:	f0 
f0103887:	c7 44 24 08 4c 88 10 	movl   $0xf010884c,0x8(%esp)
f010388e:	f0 
f010388f:	c7 44 24 04 8e 04 00 	movl   $0x48e,0x4(%esp)
f0103896:	00 
f0103897:	c7 04 24 26 88 10 f0 	movl   $0xf0108826,(%esp)
f010389e:	e8 e2 c7 ff ff       	call   f0100085 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f01038a3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01038aa:	e8 f8 e7 ff ff       	call   f01020a7 <page_alloc>
f01038af:	85 c0                	test   %eax,%eax
f01038b1:	74 04                	je     f01038b7 <mem_init+0x1042>
f01038b3:	39 c7                	cmp    %eax,%edi
f01038b5:	74 24                	je     f01038db <mem_init+0x1066>
f01038b7:	c7 44 24 0c f8 90 10 	movl   $0xf01090f8,0xc(%esp)
f01038be:	f0 
f01038bf:	c7 44 24 08 4c 88 10 	movl   $0xf010884c,0x8(%esp)
f01038c6:	f0 
f01038c7:	c7 44 24 04 91 04 00 	movl   $0x491,0x4(%esp)
f01038ce:	00 
f01038cf:	c7 04 24 26 88 10 f0 	movl   $0xf0108826,(%esp)
f01038d6:	e8 aa c7 ff ff       	call   f0100085 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f01038db:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01038e2:	e8 c0 e7 ff ff       	call   f01020a7 <page_alloc>
f01038e7:	85 c0                	test   %eax,%eax
f01038e9:	74 24                	je     f010390f <mem_init+0x109a>
f01038eb:	c7 44 24 0c 14 8a 10 	movl   $0xf0108a14,0xc(%esp)
f01038f2:	f0 
f01038f3:	c7 44 24 08 4c 88 10 	movl   $0xf010884c,0x8(%esp)
f01038fa:	f0 
f01038fb:	c7 44 24 04 94 04 00 	movl   $0x494,0x4(%esp)
f0103902:	00 
f0103903:	c7 04 24 26 88 10 f0 	movl   $0xf0108826,(%esp)
f010390a:	e8 76 c7 ff ff       	call   f0100085 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010390f:	a1 ac 0e 1f f0       	mov    0xf01f0eac,%eax
f0103914:	8b 08                	mov    (%eax),%ecx
f0103916:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f010391c:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f010391f:	2b 15 b0 0e 1f f0    	sub    0xf01f0eb0,%edx
f0103925:	c1 fa 03             	sar    $0x3,%edx
f0103928:	c1 e2 0c             	shl    $0xc,%edx
f010392b:	39 d1                	cmp    %edx,%ecx
f010392d:	74 24                	je     f0103953 <mem_init+0x10de>
f010392f:	c7 44 24 0c 04 8d 10 	movl   $0xf0108d04,0xc(%esp)
f0103936:	f0 
f0103937:	c7 44 24 08 4c 88 10 	movl   $0xf010884c,0x8(%esp)
f010393e:	f0 
f010393f:	c7 44 24 04 97 04 00 	movl   $0x497,0x4(%esp)
f0103946:	00 
f0103947:	c7 04 24 26 88 10 f0 	movl   $0xf0108826,(%esp)
f010394e:	e8 32 c7 ff ff       	call   f0100085 <_panic>
	kern_pgdir[0] = 0;
f0103953:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f0103959:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f010395e:	74 24                	je     f0103984 <mem_init+0x110f>
f0103960:	c7 44 24 0c 7f 89 10 	movl   $0xf010897f,0xc(%esp)
f0103967:	f0 
f0103968:	c7 44 24 08 4c 88 10 	movl   $0xf010884c,0x8(%esp)
f010396f:	f0 
f0103970:	c7 44 24 04 99 04 00 	movl   $0x499,0x4(%esp)
f0103977:	00 
f0103978:	c7 04 24 26 88 10 f0 	movl   $0xf0108826,(%esp)
f010397f:	e8 01 c7 ff ff       	call   f0100085 <_panic>
	pp0->pp_ref = 0;
f0103984:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f010398a:	89 34 24             	mov    %esi,(%esp)
f010398d:	e8 3d dd ff ff       	call   f01016cf <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0103992:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0103999:	00 
f010399a:	c7 44 24 04 00 10 40 	movl   $0x401000,0x4(%esp)
f01039a1:	00 
f01039a2:	a1 ac 0e 1f f0       	mov    0xf01f0eac,%eax
f01039a7:	89 04 24             	mov    %eax,(%esp)
f01039aa:	e8 76 e7 ff ff       	call   f0102125 <pgdir_walk>
f01039af:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f01039b2:	8b 0d ac 0e 1f f0    	mov    0xf01f0eac,%ecx
f01039b8:	83 c1 04             	add    $0x4,%ecx
f01039bb:	8b 11                	mov    (%ecx),%edx
f01039bd:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01039c3:	89 55 cc             	mov    %edx,-0x34(%ebp)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01039c6:	c1 ea 0c             	shr    $0xc,%edx
f01039c9:	3b 15 a8 0e 1f f0    	cmp    0xf01f0ea8,%edx
f01039cf:	72 23                	jb     f01039f4 <mem_init+0x117f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01039d1:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f01039d4:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f01039d8:	c7 44 24 08 80 80 10 	movl   $0xf0108080,0x8(%esp)
f01039df:	f0 
f01039e0:	c7 44 24 04 a0 04 00 	movl   $0x4a0,0x4(%esp)
f01039e7:	00 
f01039e8:	c7 04 24 26 88 10 f0 	movl   $0xf0108826,(%esp)
f01039ef:	e8 91 c6 ff ff       	call   f0100085 <_panic>
	assert(ptep == ptep1 + PTX(va));
f01039f4:	8b 55 cc             	mov    -0x34(%ebp),%edx
f01039f7:	81 ea fc ff ff 0f    	sub    $0xffffffc,%edx
f01039fd:	39 d0                	cmp    %edx,%eax
f01039ff:	74 24                	je     f0103a25 <mem_init+0x11b0>
f0103a01:	c7 44 24 0c 8d 8a 10 	movl   $0xf0108a8d,0xc(%esp)
f0103a08:	f0 
f0103a09:	c7 44 24 08 4c 88 10 	movl   $0xf010884c,0x8(%esp)
f0103a10:	f0 
f0103a11:	c7 44 24 04 a1 04 00 	movl   $0x4a1,0x4(%esp)
f0103a18:	00 
f0103a19:	c7 04 24 26 88 10 f0 	movl   $0xf0108826,(%esp)
f0103a20:	e8 60 c6 ff ff       	call   f0100085 <_panic>
	kern_pgdir[PDX(va)] = 0;
f0103a25:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	pp0->pp_ref = 0;
f0103a2b:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0103a31:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103a34:	2b 05 b0 0e 1f f0    	sub    0xf01f0eb0,%eax
f0103a3a:	c1 f8 03             	sar    $0x3,%eax
f0103a3d:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103a40:	89 c2                	mov    %eax,%edx
f0103a42:	c1 ea 0c             	shr    $0xc,%edx
f0103a45:	3b 15 a8 0e 1f f0    	cmp    0xf01f0ea8,%edx
f0103a4b:	72 20                	jb     f0103a6d <mem_init+0x11f8>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103a4d:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103a51:	c7 44 24 08 80 80 10 	movl   $0xf0108080,0x8(%esp)
f0103a58:	f0 
f0103a59:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0103a60:	00 
f0103a61:	c7 04 24 32 88 10 f0 	movl   $0xf0108832,(%esp)
f0103a68:	e8 18 c6 ff ff       	call   f0100085 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0103a6d:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103a74:	00 
f0103a75:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
f0103a7c:	00 
f0103a7d:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0103a82:	89 04 24             	mov    %eax,(%esp)
f0103a85:	e8 9c 37 00 00       	call   f0107226 <memset>
	page_free(pp0);
f0103a8a:	89 34 24             	mov    %esi,(%esp)
f0103a8d:	e8 3d dc ff ff       	call   f01016cf <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0103a92:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0103a99:	00 
f0103a9a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103aa1:	00 
f0103aa2:	a1 ac 0e 1f f0       	mov    0xf01f0eac,%eax
f0103aa7:	89 04 24             	mov    %eax,(%esp)
f0103aaa:	e8 76 e6 ff ff       	call   f0102125 <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0103aaf:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0103ab2:	2b 15 b0 0e 1f f0    	sub    0xf01f0eb0,%edx
f0103ab8:	c1 fa 03             	sar    $0x3,%edx
f0103abb:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103abe:	89 d0                	mov    %edx,%eax
f0103ac0:	c1 e8 0c             	shr    $0xc,%eax
f0103ac3:	3b 05 a8 0e 1f f0    	cmp    0xf01f0ea8,%eax
f0103ac9:	72 20                	jb     f0103aeb <mem_init+0x1276>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103acb:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0103acf:	c7 44 24 08 80 80 10 	movl   $0xf0108080,0x8(%esp)
f0103ad6:	f0 
f0103ad7:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0103ade:	00 
f0103adf:	c7 04 24 32 88 10 f0 	movl   $0xf0108832,(%esp)
f0103ae6:	e8 9a c5 ff ff       	call   f0100085 <_panic>
	ptep = (pte_t *) page2kva(pp0);
f0103aeb:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
f0103af1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0103af4:	f6 00 01             	testb  $0x1,(%eax)
f0103af7:	75 11                	jne    f0103b0a <mem_init+0x1295>
f0103af9:	8d 82 04 00 00 f0    	lea    -0xffffffc(%edx),%eax
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0103aff:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0103b05:	f6 00 01             	testb  $0x1,(%eax)
f0103b08:	74 24                	je     f0103b2e <mem_init+0x12b9>
f0103b0a:	c7 44 24 0c a5 8a 10 	movl   $0xf0108aa5,0xc(%esp)
f0103b11:	f0 
f0103b12:	c7 44 24 08 4c 88 10 	movl   $0xf010884c,0x8(%esp)
f0103b19:	f0 
f0103b1a:	c7 44 24 04 ab 04 00 	movl   $0x4ab,0x4(%esp)
f0103b21:	00 
f0103b22:	c7 04 24 26 88 10 f0 	movl   $0xf0108826,(%esp)
f0103b29:	e8 57 c5 ff ff       	call   f0100085 <_panic>
f0103b2e:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f0103b31:	39 d0                	cmp    %edx,%eax
f0103b33:	75 d0                	jne    f0103b05 <mem_init+0x1290>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f0103b35:	a1 ac 0e 1f f0       	mov    0xf01f0eac,%eax
f0103b3a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0103b40:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// give free list back
	page_free_list = fl;
f0103b46:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0103b49:	a3 50 02 1f f0       	mov    %eax,0xf01f0250

	// free the pages we took
	page_free(pp0);
f0103b4e:	89 34 24             	mov    %esi,(%esp)
f0103b51:	e8 79 db ff ff       	call   f01016cf <page_free>
	page_free(pp1);
f0103b56:	89 3c 24             	mov    %edi,(%esp)
f0103b59:	e8 71 db ff ff       	call   f01016cf <page_free>
	page_free(pp2);
f0103b5e:	89 1c 24             	mov    %ebx,(%esp)
f0103b61:	e8 69 db ff ff       	call   f01016cf <page_free>

	cprintf("check_page() succeeded!\n");
f0103b66:	c7 04 24 bc 8a 10 f0 	movl   $0xf0108abc,(%esp)
f0103b6d:	e8 4d 0f 00 00       	call   f0104abf <cprintf>
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
        boot_map_region(kern_pgdir,UPAGES,PTSIZE,PADDR(pages),PTE_U|PTE_P);
f0103b72:	a1 b0 0e 1f f0       	mov    0xf01f0eb0,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103b77:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103b7c:	77 20                	ja     f0103b9e <mem_init+0x1329>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103b7e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103b82:	c7 44 24 08 5c 80 10 	movl   $0xf010805c,0x8(%esp)
f0103b89:	f0 
f0103b8a:	c7 44 24 04 c7 00 00 	movl   $0xc7,0x4(%esp)
f0103b91:	00 
f0103b92:	c7 04 24 26 88 10 f0 	movl   $0xf0108826,(%esp)
f0103b99:	e8 e7 c4 ff ff       	call   f0100085 <_panic>
f0103b9e:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
f0103ba5:	00 
f0103ba6:	8d 80 00 00 00 10    	lea    0x10000000(%eax),%eax
f0103bac:	89 04 24             	mov    %eax,(%esp)
f0103baf:	b9 00 00 40 00       	mov    $0x400000,%ecx
f0103bb4:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0103bb9:	a1 ac 0e 1f f0       	mov    0xf01f0eac,%eax
f0103bbe:	e8 74 e8 ff ff       	call   f0102437 <boot_map_region>
	// (ie. perm = PTE_U | PTE_P).
	// Permissions:
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.
        boot_map_region(kern_pgdir,UENVS,PTSIZE,PADDR(envs),PTE_U|PTE_P);
f0103bc3:	a1 5c 02 1f f0       	mov    0xf01f025c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103bc8:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103bcd:	77 20                	ja     f0103bef <mem_init+0x137a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103bcf:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103bd3:	c7 44 24 08 5c 80 10 	movl   $0xf010805c,0x8(%esp)
f0103bda:	f0 
f0103bdb:	c7 44 24 04 cf 00 00 	movl   $0xcf,0x4(%esp)
f0103be2:	00 
f0103be3:	c7 04 24 26 88 10 f0 	movl   $0xf0108826,(%esp)
f0103bea:	e8 96 c4 ff ff       	call   f0100085 <_panic>
f0103bef:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
f0103bf6:	00 
f0103bf7:	8d 80 00 00 00 10    	lea    0x10000000(%eax),%eax
f0103bfd:	89 04 24             	mov    %eax,(%esp)
f0103c00:	b9 00 00 40 00       	mov    $0x400000,%ecx
f0103c05:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0103c0a:	a1 ac 0e 1f f0       	mov    0xf01f0eac,%eax
f0103c0f:	e8 23 e8 ff ff       	call   f0102437 <boot_map_region>
static void
mem_init_mp(void)
{
	// Create a direct mapping at the top of virtual address space starting
	// at IOMEMBASE for accessing the LAPIC unit using memory-mapped I/O.
	boot_map_region(kern_pgdir, IOMEMBASE, -IOMEMBASE, IOMEM_PADDR, PTE_W);
f0103c14:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0103c1b:	00 
f0103c1c:	c7 04 24 00 00 00 fe 	movl   $0xfe000000,(%esp)
f0103c23:	b9 00 00 00 02       	mov    $0x2000000,%ecx
f0103c28:	ba 00 00 00 fe       	mov    $0xfe000000,%edx
f0103c2d:	a1 ac 0e 1f f0       	mov    0xf01f0eac,%eax
f0103c32:	e8 00 e8 ff ff       	call   f0102437 <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103c37:	c7 45 cc 00 20 1f f0 	movl   $0xf01f2000,-0x34(%ebp)
f0103c3e:	81 7d cc ff ff ff ef 	cmpl   $0xefffffff,-0x34(%ebp)
f0103c45:	0f 87 eb 04 00 00    	ja     f0104136 <mem_init+0x18c1>
f0103c4b:	b8 00 20 1f f0       	mov    $0xf01f2000,%eax
f0103c50:	eb 0a                	jmp    f0103c5c <mem_init+0x13e7>
f0103c52:	89 d8                	mov    %ebx,%eax
f0103c54:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f0103c5a:	77 20                	ja     f0103c7c <mem_init+0x1407>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103c5c:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103c60:	c7 44 24 08 5c 80 10 	movl   $0xf010805c,0x8(%esp)
f0103c67:	f0 
f0103c68:	c7 44 24 04 26 01 00 	movl   $0x126,0x4(%esp)
f0103c6f:	00 
f0103c70:	c7 04 24 26 88 10 f0 	movl   $0xf0108826,(%esp)
f0103c77:	e8 09 c4 ff ff       	call   f0100085 <_panic>
	//
	// LAB 4: Your code here:
        int i;
        for(i = 0;i<NCPU;i++){
          uint32_t kstacktop_i = KSTACKTOP - i*(KSTKSIZE+KSTKGAP);
          boot_map_region(kern_pgdir,kstacktop_i - KSTKSIZE , KSTKSIZE, PADDR(percpu_kstacks[i]),PTE_P | PTE_W);
f0103c7c:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f0103c83:	00 
f0103c84:	8d 83 00 00 00 10    	lea    0x10000000(%ebx),%eax
f0103c8a:	89 04 24             	mov    %eax,(%esp)
f0103c8d:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0103c92:	89 f2                	mov    %esi,%edx
f0103c94:	a1 ac 0e 1f f0       	mov    0xf01f0eac,%eax
f0103c99:	e8 99 e7 ff ff       	call   f0102437 <boot_map_region>
f0103c9e:	81 c3 00 80 00 00    	add    $0x8000,%ebx
f0103ca4:	81 ee 00 00 01 00    	sub    $0x10000,%esi
	//             Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	//
	// LAB 4: Your code here:
        int i;
        for(i = 0;i<NCPU;i++){
f0103caa:	81 fe 00 80 b7 ef    	cmp    $0xefb78000,%esi
f0103cb0:	75 a0                	jne    f0103c52 <mem_init+0x13dd>
	mem_init_mp();

        //lcr4(rcr4() |CR4_PSE);
        //boot_map_region_large(kern_pgdir,KERNBASE,(uint32_t)(~KERNBASE + 1),PADDR((void*)KERNBASE),PTE_P|PTE_W);
        //boot_map_region_large(kern_pgdir,KERNBASE,(uint32_t)(IOMEMBASE-KERNBASE),PADDR((void*)KERNBASE),PTE_P|PTE_W);
        boot_map_region(kern_pgdir,KERNBASE,(uint32_t)(IOMEMBASE-KERNBASE),PADDR((void*)KERNBASE),PTE_P|PTE_W);
f0103cb2:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f0103cb9:	00 
f0103cba:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103cc1:	b9 00 00 00 0e       	mov    $0xe000000,%ecx
f0103cc6:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0103ccb:	a1 ac 0e 1f f0       	mov    0xf01f0eac,%eax
f0103cd0:	e8 62 e7 ff ff       	call   f0102437 <boot_map_region>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f0103cd5:	8b 1d ac 0e 1f f0    	mov    0xf01f0eac,%ebx

	// check pages array
	n = ROUNDUP(npages*sizeof(struct Page), PGSIZE);
f0103cdb:	a1 a8 0e 1f f0       	mov    0xf01f0ea8,%eax
f0103ce0:	8d 3c c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%edi
	for (i = 0; i < n; i += PGSIZE)
f0103ce7:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
f0103ced:	74 79                	je     f0103d68 <mem_init+0x14f3>
f0103cef:	be 00 00 00 00       	mov    $0x0,%esi
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0103cf4:	8d 96 00 00 00 ef    	lea    -0x11000000(%esi),%edx
f0103cfa:	89 d8                	mov    %ebx,%eax
f0103cfc:	e8 9d df ff ff       	call   f0101c9e <check_va2pa>
f0103d01:	8b 15 b0 0e 1f f0    	mov    0xf01f0eb0,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103d07:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0103d0d:	77 20                	ja     f0103d2f <mem_init+0x14ba>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103d0f:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0103d13:	c7 44 24 08 5c 80 10 	movl   $0xf010805c,0x8(%esp)
f0103d1a:	f0 
f0103d1b:	c7 44 24 04 d8 03 00 	movl   $0x3d8,0x4(%esp)
f0103d22:	00 
f0103d23:	c7 04 24 26 88 10 f0 	movl   $0xf0108826,(%esp)
f0103d2a:	e8 56 c3 ff ff       	call   f0100085 <_panic>
f0103d2f:	8d 94 32 00 00 00 10 	lea    0x10000000(%edx,%esi,1),%edx
f0103d36:	39 d0                	cmp    %edx,%eax
f0103d38:	74 24                	je     f0103d5e <mem_init+0x14e9>
f0103d3a:	c7 44 24 0c 1c 91 10 	movl   $0xf010911c,0xc(%esp)
f0103d41:	f0 
f0103d42:	c7 44 24 08 4c 88 10 	movl   $0xf010884c,0x8(%esp)
f0103d49:	f0 
f0103d4a:	c7 44 24 04 d8 03 00 	movl   $0x3d8,0x4(%esp)
f0103d51:	00 
f0103d52:	c7 04 24 26 88 10 f0 	movl   $0xf0108826,(%esp)
f0103d59:	e8 27 c3 ff ff       	call   f0100085 <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct Page), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0103d5e:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0103d64:	39 f7                	cmp    %esi,%edi
f0103d66:	77 8c                	ja     f0103cf4 <mem_init+0x147f>
f0103d68:	be 00 00 00 00       	mov    $0x0,%esi
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0103d6d:	8d 96 00 00 c0 ee    	lea    -0x11400000(%esi),%edx
f0103d73:	89 d8                	mov    %ebx,%eax
f0103d75:	e8 24 df ff ff       	call   f0101c9e <check_va2pa>
f0103d7a:	8b 15 5c 02 1f f0    	mov    0xf01f025c,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103d80:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0103d86:	77 20                	ja     f0103da8 <mem_init+0x1533>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103d88:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0103d8c:	c7 44 24 08 5c 80 10 	movl   $0xf010805c,0x8(%esp)
f0103d93:	f0 
f0103d94:	c7 44 24 04 dd 03 00 	movl   $0x3dd,0x4(%esp)
f0103d9b:	00 
f0103d9c:	c7 04 24 26 88 10 f0 	movl   $0xf0108826,(%esp)
f0103da3:	e8 dd c2 ff ff       	call   f0100085 <_panic>
f0103da8:	8d 94 32 00 00 00 10 	lea    0x10000000(%edx,%esi,1),%edx
f0103daf:	39 d0                	cmp    %edx,%eax
f0103db1:	74 24                	je     f0103dd7 <mem_init+0x1562>
f0103db3:	c7 44 24 0c 50 91 10 	movl   $0xf0109150,0xc(%esp)
f0103dba:	f0 
f0103dbb:	c7 44 24 08 4c 88 10 	movl   $0xf010884c,0x8(%esp)
f0103dc2:	f0 
f0103dc3:	c7 44 24 04 dd 03 00 	movl   $0x3dd,0x4(%esp)
f0103dca:	00 
f0103dcb:	c7 04 24 26 88 10 f0 	movl   $0xf0108826,(%esp)
f0103dd2:	e8 ae c2 ff ff       	call   f0100085 <_panic>
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0103dd7:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0103ddd:	81 fe 00 10 02 00    	cmp    $0x21000,%esi
f0103de3:	75 88                	jne    f0103d6d <mem_init+0x14f8>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	if (check_va2pa_large(pgdir, KERNBASE) == 0) {
f0103de5:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0103dea:	89 d8                	mov    %ebx,%eax
f0103dec:	e8 27 d9 ff ff       	call   f0101718 <check_va2pa_large>
f0103df1:	85 c0                	test   %eax,%eax
f0103df3:	74 13                	je     f0103e08 <mem_init+0x1593>
		for (i = 0; i < npages * PGSIZE; i += PTSIZE)
			assert(check_va2pa_large(pgdir, KERNBASE + i) == i);

		cprintf("large page installed!\n");
	} else {
	    for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0103df5:	a1 a8 0e 1f f0       	mov    0xf01f0ea8,%eax
f0103dfa:	c1 e0 0c             	shl    $0xc,%eax
	// check phys mem
	if (check_va2pa_large(pgdir, KERNBASE) == 0) {
		for (i = 0; i < npages * PGSIZE; i += PTSIZE)
			assert(check_va2pa_large(pgdir, KERNBASE + i) == i);

		cprintf("large page installed!\n");
f0103dfd:	be 00 00 00 00       	mov    $0x0,%esi
	} else {
	    for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0103e02:	85 c0                	test   %eax,%eax
f0103e04:	75 6c                	jne    f0103e72 <mem_init+0x15fd>
f0103e06:	eb 63                	jmp    f0103e6b <mem_init+0x15f6>
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	if (check_va2pa_large(pgdir, KERNBASE) == 0) {
		for (i = 0; i < npages * PGSIZE; i += PTSIZE)
f0103e08:	8b 3d a8 0e 1f f0    	mov    0xf01f0ea8,%edi
f0103e0e:	c1 e7 0c             	shl    $0xc,%edi
			assert(check_va2pa_large(pgdir, KERNBASE + i) == i);
f0103e11:	b8 00 00 00 00       	mov    $0x0,%eax
f0103e16:	89 de                	mov    %ebx,%esi
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	if (check_va2pa_large(pgdir, KERNBASE) == 0) {
		for (i = 0; i < npages * PGSIZE; i += PTSIZE)
f0103e18:	85 ff                	test   %edi,%edi
f0103e1a:	75 37                	jne    f0103e53 <mem_init+0x15de>
f0103e1c:	eb 41                	jmp    f0103e5f <mem_init+0x15ea>
f0103e1e:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
			assert(check_va2pa_large(pgdir, KERNBASE + i) == i);
f0103e24:	89 f0                	mov    %esi,%eax
f0103e26:	e8 ed d8 ff ff       	call   f0101718 <check_va2pa_large>
f0103e2b:	39 d8                	cmp    %ebx,%eax
f0103e2d:	74 24                	je     f0103e53 <mem_init+0x15de>
f0103e2f:	c7 44 24 0c 84 91 10 	movl   $0xf0109184,0xc(%esp)
f0103e36:	f0 
f0103e37:	c7 44 24 08 4c 88 10 	movl   $0xf010884c,0x8(%esp)
f0103e3e:	f0 
f0103e3f:	c7 44 24 04 e2 03 00 	movl   $0x3e2,0x4(%esp)
f0103e46:	00 
f0103e47:	c7 04 24 26 88 10 f0 	movl   $0xf0108826,(%esp)
f0103e4e:	e8 32 c2 ff ff       	call   f0100085 <_panic>
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	if (check_va2pa_large(pgdir, KERNBASE) == 0) {
		for (i = 0; i < npages * PGSIZE; i += PTSIZE)
f0103e53:	8d 98 00 00 40 00    	lea    0x400000(%eax),%ebx
f0103e59:	39 df                	cmp    %ebx,%edi
f0103e5b:	77 c1                	ja     f0103e1e <mem_init+0x15a9>
f0103e5d:	89 f3                	mov    %esi,%ebx
			assert(check_va2pa_large(pgdir, KERNBASE + i) == i);

		cprintf("large page installed!\n");
f0103e5f:	c7 04 24 d5 8a 10 f0 	movl   $0xf0108ad5,(%esp)
f0103e66:	e8 54 0c 00 00       	call   f0104abf <cprintf>
f0103e6b:	be 00 00 00 fe       	mov    $0xfe000000,%esi
f0103e70:	eb 49                	jmp    f0103ebb <mem_init+0x1646>
	} else {
	    for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		    assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0103e72:	8d 96 00 00 00 f0    	lea    -0x10000000(%esi),%edx
f0103e78:	89 d8                	mov    %ebx,%eax
f0103e7a:	e8 1f de ff ff       	call   f0101c9e <check_va2pa>
f0103e7f:	39 c6                	cmp    %eax,%esi
f0103e81:	74 24                	je     f0103ea7 <mem_init+0x1632>
f0103e83:	c7 44 24 0c b0 91 10 	movl   $0xf01091b0,0xc(%esp)
f0103e8a:	f0 
f0103e8b:	c7 44 24 08 4c 88 10 	movl   $0xf010884c,0x8(%esp)
f0103e92:	f0 
f0103e93:	c7 44 24 04 e7 03 00 	movl   $0x3e7,0x4(%esp)
f0103e9a:	00 
f0103e9b:	c7 04 24 26 88 10 f0 	movl   $0xf0108826,(%esp)
f0103ea2:	e8 de c1 ff ff       	call   f0100085 <_panic>
		for (i = 0; i < npages * PGSIZE; i += PTSIZE)
			assert(check_va2pa_large(pgdir, KERNBASE + i) == i);

		cprintf("large page installed!\n");
	} else {
	    for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0103ea7:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0103ead:	a1 a8 0e 1f f0       	mov    0xf01f0ea8,%eax
f0103eb2:	c1 e0 0c             	shl    $0xc,%eax
f0103eb5:	39 c6                	cmp    %eax,%esi
f0103eb7:	72 b9                	jb     f0103e72 <mem_init+0x15fd>
f0103eb9:	eb b0                	jmp    f0103e6b <mem_init+0x15f6>
	}

	
	// check IO mem (new in lab 4)
	for (i = IOMEMBASE; i < -PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, i) == i);
f0103ebb:	89 f2                	mov    %esi,%edx
f0103ebd:	89 d8                	mov    %ebx,%eax
f0103ebf:	e8 da dd ff ff       	call   f0101c9e <check_va2pa>
f0103ec4:	39 c6                	cmp    %eax,%esi
f0103ec6:	74 24                	je     f0103eec <mem_init+0x1677>
f0103ec8:	c7 44 24 0c ec 8a 10 	movl   $0xf0108aec,0xc(%esp)
f0103ecf:	f0 
f0103ed0:	c7 44 24 08 4c 88 10 	movl   $0xf010884c,0x8(%esp)
f0103ed7:	f0 
f0103ed8:	c7 44 24 04 ed 03 00 	movl   $0x3ed,0x4(%esp)
f0103edf:	00 
f0103ee0:	c7 04 24 26 88 10 f0 	movl   $0xf0108826,(%esp)
f0103ee7:	e8 99 c1 ff ff       	call   f0100085 <_panic>
		    assert(check_va2pa(pgdir, KERNBASE + i) == i);
	}

	
	// check IO mem (new in lab 4)
	for (i = IOMEMBASE; i < -PGSIZE; i += PGSIZE)
f0103eec:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0103ef2:	81 fe 00 f0 ff ff    	cmp    $0xfffff000,%esi
f0103ef8:	75 c1                	jne    f0103ebb <mem_init+0x1646>
f0103efa:	c7 45 d0 00 00 bf ef 	movl   $0xefbf0000,-0x30(%ebp)
		assert(check_va2pa(pgdir, i) == i);
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0103f01:	89 df                	mov    %ebx,%edi
		    assert(check_va2pa(pgdir, KERNBASE + i) == i);
	}

	
	// check IO mem (new in lab 4)
	for (i = IOMEMBASE; i < -PGSIZE; i += PGSIZE)
f0103f03:	8b 55 cc             	mov    -0x34(%ebp),%edx
f0103f06:	89 55 c8             	mov    %edx,-0x38(%ebp)
f0103f09:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0103f0c:	81 c3 00 80 00 00    	add    $0x8000,%ebx
f0103f12:	89 d6                	mov    %edx,%esi
f0103f14:	81 c6 00 00 00 10    	add    $0x10000000,%esi
f0103f1a:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0103f1d:	81 c1 00 00 01 00    	add    $0x10000,%ecx
f0103f23:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0103f26:	89 da                	mov    %ebx,%edx
f0103f28:	89 f8                	mov    %edi,%eax
f0103f2a:	e8 6f dd ff ff       	call   f0101c9e <check_va2pa>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103f2f:	81 7d cc ff ff ff ef 	cmpl   $0xefffffff,-0x34(%ebp)
f0103f36:	77 23                	ja     f0103f5b <mem_init+0x16e6>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103f38:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0103f3b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103f3f:	c7 44 24 08 5c 80 10 	movl   $0xf010805c,0x8(%esp)
f0103f46:	f0 
f0103f47:	c7 44 24 04 f4 03 00 	movl   $0x3f4,0x4(%esp)
f0103f4e:	00 
f0103f4f:	c7 04 24 26 88 10 f0 	movl   $0xf0108826,(%esp)
f0103f56:	e8 2a c1 ff ff       	call   f0100085 <_panic>
f0103f5b:	39 f0                	cmp    %esi,%eax
f0103f5d:	74 24                	je     f0103f83 <mem_init+0x170e>
f0103f5f:	c7 44 24 0c d8 91 10 	movl   $0xf01091d8,0xc(%esp)
f0103f66:	f0 
f0103f67:	c7 44 24 08 4c 88 10 	movl   $0xf010884c,0x8(%esp)
f0103f6e:	f0 
f0103f6f:	c7 44 24 04 f4 03 00 	movl   $0x3f4,0x4(%esp)
f0103f76:	00 
f0103f77:	c7 04 24 26 88 10 f0 	movl   $0xf0108826,(%esp)
f0103f7e:	e8 02 c1 ff ff       	call   f0100085 <_panic>
f0103f83:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0103f89:	8d b0 00 10 00 00    	lea    0x1000(%eax),%esi
		assert(check_va2pa(pgdir, i) == i);
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0103f8f:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0103f92:	0f 85 d4 01 00 00    	jne    f010416c <mem_init+0x18f7>
f0103f98:	bb 00 00 00 00       	mov    $0x0,%ebx
f0103f9d:	8b 75 d0             	mov    -0x30(%ebp),%esi
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
f0103fa0:	8d 14 1e             	lea    (%esi,%ebx,1),%edx
f0103fa3:	89 f8                	mov    %edi,%eax
f0103fa5:	e8 f4 dc ff ff       	call   f0101c9e <check_va2pa>
f0103faa:	83 f8 ff             	cmp    $0xffffffff,%eax
f0103fad:	74 24                	je     f0103fd3 <mem_init+0x175e>
f0103faf:	c7 44 24 0c 20 92 10 	movl   $0xf0109220,0xc(%esp)
f0103fb6:	f0 
f0103fb7:	c7 44 24 08 4c 88 10 	movl   $0xf010884c,0x8(%esp)
f0103fbe:	f0 
f0103fbf:	c7 44 24 04 f6 03 00 	movl   $0x3f6,0x4(%esp)
f0103fc6:	00 
f0103fc7:	c7 04 24 26 88 10 f0 	movl   $0xf0108826,(%esp)
f0103fce:	e8 b2 c0 ff ff       	call   f0100085 <_panic>
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
f0103fd3:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0103fd9:	81 fb 00 80 00 00    	cmp    $0x8000,%ebx
f0103fdf:	75 bf                	jne    f0103fa0 <mem_init+0x172b>
f0103fe1:	81 6d d0 00 00 01 00 	subl   $0x10000,-0x30(%ebp)
f0103fe8:	81 45 cc 00 80 00 00 	addl   $0x8000,-0x34(%ebp)
	// check IO mem (new in lab 4)
	for (i = IOMEMBASE; i < -PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, i) == i);
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
f0103fef:	81 7d d0 00 00 b7 ef 	cmpl   $0xefb70000,-0x30(%ebp)
f0103ff6:	0f 85 07 ff ff ff    	jne    f0103f03 <mem_init+0x168e>
f0103ffc:	89 fb                	mov    %edi,%ebx
f0103ffe:	b8 00 00 00 00       	mov    $0x0,%eax
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
	}
	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f0104003:	8d 90 45 fc ff ff    	lea    -0x3bb(%eax),%edx
f0104009:	83 fa 03             	cmp    $0x3,%edx
f010400c:	77 2e                	ja     f010403c <mem_init+0x17c7>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
			assert(pgdir[i] & PTE_P);
f010400e:	f6 04 83 01          	testb  $0x1,(%ebx,%eax,4)
f0104012:	0f 85 aa 00 00 00    	jne    f01040c2 <mem_init+0x184d>
f0104018:	c7 44 24 0c 07 8b 10 	movl   $0xf0108b07,0xc(%esp)
f010401f:	f0 
f0104020:	c7 44 24 08 4c 88 10 	movl   $0xf010884c,0x8(%esp)
f0104027:	f0 
f0104028:	c7 44 24 04 ff 03 00 	movl   $0x3ff,0x4(%esp)
f010402f:	00 
f0104030:	c7 04 24 26 88 10 f0 	movl   $0xf0108826,(%esp)
f0104037:	e8 49 c0 ff ff       	call   f0100085 <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f010403c:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0104041:	76 55                	jbe    f0104098 <mem_init+0x1823>
				assert(pgdir[i] & PTE_P);
f0104043:	8b 14 83             	mov    (%ebx,%eax,4),%edx
f0104046:	f6 c2 01             	test   $0x1,%dl
f0104049:	75 24                	jne    f010406f <mem_init+0x17fa>
f010404b:	c7 44 24 0c 07 8b 10 	movl   $0xf0108b07,0xc(%esp)
f0104052:	f0 
f0104053:	c7 44 24 08 4c 88 10 	movl   $0xf010884c,0x8(%esp)
f010405a:	f0 
f010405b:	c7 44 24 04 03 04 00 	movl   $0x403,0x4(%esp)
f0104062:	00 
f0104063:	c7 04 24 26 88 10 f0 	movl   $0xf0108826,(%esp)
f010406a:	e8 16 c0 ff ff       	call   f0100085 <_panic>
				assert(pgdir[i] & PTE_W);
f010406f:	f6 c2 02             	test   $0x2,%dl
f0104072:	75 4e                	jne    f01040c2 <mem_init+0x184d>
f0104074:	c7 44 24 0c 18 8b 10 	movl   $0xf0108b18,0xc(%esp)
f010407b:	f0 
f010407c:	c7 44 24 08 4c 88 10 	movl   $0xf010884c,0x8(%esp)
f0104083:	f0 
f0104084:	c7 44 24 04 04 04 00 	movl   $0x404,0x4(%esp)
f010408b:	00 
f010408c:	c7 04 24 26 88 10 f0 	movl   $0xf0108826,(%esp)
f0104093:	e8 ed bf ff ff       	call   f0100085 <_panic>
			} else
				assert(pgdir[i] == 0);
f0104098:	83 3c 83 00          	cmpl   $0x0,(%ebx,%eax,4)
f010409c:	74 24                	je     f01040c2 <mem_init+0x184d>
f010409e:	c7 44 24 0c 29 8b 10 	movl   $0xf0108b29,0xc(%esp)
f01040a5:	f0 
f01040a6:	c7 44 24 08 4c 88 10 	movl   $0xf010884c,0x8(%esp)
f01040ad:	f0 
f01040ae:	c7 44 24 04 06 04 00 	movl   $0x406,0x4(%esp)
f01040b5:	00 
f01040b6:	c7 04 24 26 88 10 f0 	movl   $0xf0108826,(%esp)
f01040bd:	e8 c3 bf ff ff       	call   f0100085 <_panic>
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
	}
	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f01040c2:	83 c0 01             	add    $0x1,%eax
f01040c5:	3d 00 04 00 00       	cmp    $0x400,%eax
f01040ca:	0f 85 33 ff ff ff    	jne    f0104003 <mem_init+0x178e>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f01040d0:	c7 04 24 44 92 10 f0 	movl   $0xf0109244,(%esp)
f01040d7:	e8 e3 09 00 00       	call   f0104abf <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f01040dc:	a1 ac 0e 1f f0       	mov    0xf01f0eac,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01040e1:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01040e6:	77 20                	ja     f0104108 <mem_init+0x1893>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01040e8:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01040ec:	c7 44 24 08 5c 80 10 	movl   $0xf010805c,0x8(%esp)
f01040f3:	f0 
f01040f4:	c7 44 24 04 f8 00 00 	movl   $0xf8,0x4(%esp)
f01040fb:	00 
f01040fc:	c7 04 24 26 88 10 f0 	movl   $0xf0108826,(%esp)
f0104103:	e8 7d bf ff ff       	call   f0100085 <_panic>
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0104108:	8d 80 00 00 00 10    	lea    0x10000000(%eax),%eax
f010410e:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f0104111:	b8 00 00 00 00       	mov    $0x0,%eax
f0104116:	e8 e9 db ff ff       	call   f0101d04 <check_page_free_list>

static __inline uint32_t
rcr0(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f010411b:	0f 20 c0             	mov    %cr0,%eax

	// entry.S set the really important flags in cr0 (including enabling
	// paging).  Here we configure the rest of the flags that we care about.
	cr0 = rcr0();
	cr0 |= CR0_PE|CR0_PG|CR0_AM|CR0_WP|CR0_NE|CR0_MP;
f010411e:	0d 23 00 05 80       	or     $0x80050023,%eax
}

static __inline void
lcr0(uint32_t val)
{
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f0104123:	83 e0 f3             	and    $0xfffffff3,%eax
f0104126:	0f 22 c0             	mov    %eax,%cr0
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
f0104129:	e8 72 e3 ff ff       	call   f01024a0 <check_page_installed_pgdir>
}
f010412e:	83 c4 3c             	add    $0x3c,%esp
f0104131:	5b                   	pop    %ebx
f0104132:	5e                   	pop    %esi
f0104133:	5f                   	pop    %edi
f0104134:	5d                   	pop    %ebp
f0104135:	c3                   	ret    
	//
	// LAB 4: Your code here:
        int i;
        for(i = 0;i<NCPU;i++){
          uint32_t kstacktop_i = KSTACKTOP - i*(KSTKSIZE+KSTKGAP);
          boot_map_region(kern_pgdir,kstacktop_i - KSTKSIZE , KSTKSIZE, PADDR(percpu_kstacks[i]),PTE_P | PTE_W);
f0104136:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f010413d:	00 
f010413e:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0104141:	05 00 00 00 10       	add    $0x10000000,%eax
f0104146:	89 04 24             	mov    %eax,(%esp)
f0104149:	b9 00 80 00 00       	mov    $0x8000,%ecx
f010414e:	ba 00 80 bf ef       	mov    $0xefbf8000,%edx
f0104153:	a1 ac 0e 1f f0       	mov    0xf01f0eac,%eax
f0104158:	e8 da e2 ff ff       	call   f0102437 <boot_map_region>
f010415d:	bb 00 a0 1f f0       	mov    $0xf01fa000,%ebx
f0104162:	be 00 80 be ef       	mov    $0xefbe8000,%esi
f0104167:	e9 e6 fa ff ff       	jmp    f0103c52 <mem_init+0x13dd>
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f010416c:	89 da                	mov    %ebx,%edx
f010416e:	89 f8                	mov    %edi,%eax
f0104170:	e8 29 db ff ff       	call   f0101c9e <check_va2pa>
f0104175:	e9 e1 fd ff ff       	jmp    f0103f5b <mem_init+0x16e6>
f010417a:	00 00                	add    %al,(%eax)
f010417c:	00 00                	add    %al,(%eax)
	...

f0104180 <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f0104180:	55                   	push   %ebp
f0104181:	89 e5                	mov    %esp,%ebp
}

static __inline void
lgdt(void *p)
{
	__asm __volatile("lgdt (%0)" : : "r" (p));
f0104183:	b8 68 43 12 f0       	mov    $0xf0124368,%eax
f0104188:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" :: "a" (GD_UD|3));
f010418b:	b8 23 00 00 00       	mov    $0x23,%eax
f0104190:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" :: "a" (GD_UD|3));
f0104192:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" :: "a" (GD_KD));
f0104194:	b0 10                	mov    $0x10,%al
f0104196:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" :: "a" (GD_KD));
f0104198:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" :: "a" (GD_KD));
f010419a:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" :: "i" (GD_KT));
f010419c:	ea a3 41 10 f0 08 00 	ljmp   $0x8,$0xf01041a3
}

static __inline void
lldt(uint16_t sel)
{
	__asm __volatile("lldt %0" : : "r" (sel));
f01041a3:	b0 00                	mov    $0x0,%al
f01041a5:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f01041a8:	5d                   	pop    %ebp
f01041a9:	c3                   	ret    

f01041aa <env_init>:
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f01041aa:	55                   	push   %ebp
f01041ab:	89 e5                	mov    %esp,%ebp
f01041ad:	8b 15 60 02 1f f0    	mov    0xf01f0260,%edx
f01041b3:	b8 7c 0f 02 00       	mov    $0x20f7c,%eax
	// Set up envs array
	// LAB 3: Your code here.
        int i = NENV -1;
        for(i = NENV -1; i >= 0;i--){
           envs[i].env_id = 0;
f01041b8:	8b 0d 5c 02 1f f0    	mov    0xf01f025c,%ecx
f01041be:	c7 44 01 48 00 00 00 	movl   $0x0,0x48(%ecx,%eax,1)
f01041c5:	00 
           envs[i].env_link = env_free_list;
f01041c6:	8b 0d 5c 02 1f f0    	mov    0xf01f025c,%ecx
f01041cc:	89 54 01 44          	mov    %edx,0x44(%ecx,%eax,1)
           env_free_list = &envs[i];
f01041d0:	89 c2                	mov    %eax,%edx
f01041d2:	03 15 5c 02 1f f0    	add    0xf01f025c,%edx
           envs[i].env_break = 0;
f01041d8:	c7 42 60 00 00 00 00 	movl   $0x0,0x60(%edx)
f01041df:	2d 84 00 00 00       	sub    $0x84,%eax
env_init(void)
{
	// Set up envs array
	// LAB 3: Your code here.
        int i = NENV -1;
        for(i = NENV -1; i >= 0;i--){
f01041e4:	3d 7c ff ff ff       	cmp    $0xffffff7c,%eax
f01041e9:	75 cd                	jne    f01041b8 <env_init+0xe>
f01041eb:	89 15 60 02 1f f0    	mov    %edx,0xf01f0260
           envs[i].env_link = env_free_list;
           env_free_list = &envs[i];
           envs[i].env_break = 0;
        }      
	// Per-CPU part of the initialization
	env_init_percpu();
f01041f1:	e8 8a ff ff ff       	call   f0104180 <env_init_percpu>
}
f01041f6:	5d                   	pop    %ebp
f01041f7:	c3                   	ret    

f01041f8 <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f01041f8:	55                   	push   %ebp
f01041f9:	89 e5                	mov    %esp,%ebp
f01041fb:	83 ec 18             	sub    $0x18,%esp
f01041fe:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0104201:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0104204:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0104207:	8b 45 08             	mov    0x8(%ebp),%eax
f010420a:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f010420d:	85 c0                	test   %eax,%eax
f010420f:	75 17                	jne    f0104228 <envid2env+0x30>
		*env_store = curenv;
f0104211:	e8 b8 36 00 00       	call   f01078ce <cpunum>
f0104216:	6b c0 74             	imul   $0x74,%eax,%eax
f0104219:	8b 80 28 10 1f f0    	mov    -0xfe0efd8(%eax),%eax
f010421f:	89 06                	mov    %eax,(%esi)
f0104221:	b8 00 00 00 00       	mov    $0x0,%eax
		return 0;
f0104226:	eb 72                	jmp    f010429a <envid2env+0xa2>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f0104228:	89 c2                	mov    %eax,%edx
f010422a:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0104230:	89 d1                	mov    %edx,%ecx
f0104232:	c1 e1 07             	shl    $0x7,%ecx
f0104235:	8d 1c 91             	lea    (%ecx,%edx,4),%ebx
f0104238:	03 1d 5c 02 1f f0    	add    0xf01f025c,%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f010423e:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f0104242:	74 05                	je     f0104249 <envid2env+0x51>
f0104244:	39 43 48             	cmp    %eax,0x48(%ebx)
f0104247:	74 0d                	je     f0104256 <envid2env+0x5e>
		*env_store = 0;
f0104249:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
f010424f:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
		return -E_BAD_ENV;
f0104254:	eb 44                	jmp    f010429a <envid2env+0xa2>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0104256:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f010425a:	74 37                	je     f0104293 <envid2env+0x9b>
f010425c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0104260:	e8 69 36 00 00       	call   f01078ce <cpunum>
f0104265:	6b c0 74             	imul   $0x74,%eax,%eax
f0104268:	39 98 28 10 1f f0    	cmp    %ebx,-0xfe0efd8(%eax)
f010426e:	74 23                	je     f0104293 <envid2env+0x9b>
f0104270:	8b 7b 4c             	mov    0x4c(%ebx),%edi
f0104273:	e8 56 36 00 00       	call   f01078ce <cpunum>
f0104278:	6b c0 74             	imul   $0x74,%eax,%eax
f010427b:	8b 80 28 10 1f f0    	mov    -0xfe0efd8(%eax),%eax
f0104281:	3b 78 48             	cmp    0x48(%eax),%edi
f0104284:	74 0d                	je     f0104293 <envid2env+0x9b>
		*env_store = 0;
f0104286:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
f010428c:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
		return -E_BAD_ENV;
f0104291:	eb 07                	jmp    f010429a <envid2env+0xa2>
	}

	*env_store = e;
f0104293:	89 1e                	mov    %ebx,(%esi)
f0104295:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
f010429a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f010429d:	8b 75 f8             	mov    -0x8(%ebp),%esi
f01042a0:	8b 7d fc             	mov    -0x4(%ebp),%edi
f01042a3:	89 ec                	mov    %ebp,%esp
f01042a5:	5d                   	pop    %ebp
f01042a6:	c3                   	ret    

f01042a7 <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f01042a7:	55                   	push   %ebp
f01042a8:	89 e5                	mov    %esp,%ebp
f01042aa:	53                   	push   %ebx
f01042ab:	83 ec 14             	sub    $0x14,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f01042ae:	e8 1b 36 00 00       	call   f01078ce <cpunum>
f01042b3:	6b c0 74             	imul   $0x74,%eax,%eax
f01042b6:	8b 98 28 10 1f f0    	mov    -0xfe0efd8(%eax),%ebx
f01042bc:	e8 0d 36 00 00       	call   f01078ce <cpunum>
f01042c1:	89 43 5c             	mov    %eax,0x5c(%ebx)

	__asm __volatile("movl %0,%%esp\n"
f01042c4:	8b 65 08             	mov    0x8(%ebp),%esp
f01042c7:	61                   	popa   
f01042c8:	07                   	pop    %es
f01042c9:	1f                   	pop    %ds
f01042ca:	83 c4 08             	add    $0x8,%esp
f01042cd:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f01042ce:	c7 44 24 08 63 92 10 	movl   $0xf0109263,0x8(%esp)
f01042d5:	f0 
f01042d6:	c7 44 24 04 fb 01 00 	movl   $0x1fb,0x4(%esp)
f01042dd:	00 
f01042de:	c7 04 24 6f 92 10 f0 	movl   $0xf010926f,(%esp)
f01042e5:	e8 9b bd ff ff       	call   f0100085 <_panic>

f01042ea <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f01042ea:	55                   	push   %ebp
f01042eb:	89 e5                	mov    %esp,%ebp
f01042ed:	53                   	push   %ebx
f01042ee:	83 ec 14             	sub    $0x14,%esp
f01042f1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	//	e->env_tf.  Go back through the code you wrote above
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.
        if(e!= curenv){
f01042f4:	e8 d5 35 00 00       	call   f01078ce <cpunum>
f01042f9:	6b c0 74             	imul   $0x74,%eax,%eax
f01042fc:	39 98 28 10 1f f0    	cmp    %ebx,-0xfe0efd8(%eax)
f0104302:	0f 84 88 00 00 00    	je     f0104390 <env_run+0xa6>
           if(curenv != NULL){
f0104308:	e8 c1 35 00 00       	call   f01078ce <cpunum>
f010430d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104310:	83 b8 28 10 1f f0 00 	cmpl   $0x0,-0xfe0efd8(%eax)
f0104317:	74 29                	je     f0104342 <env_run+0x58>
               if(curenv->env_status == ENV_RUNNING)
f0104319:	e8 b0 35 00 00       	call   f01078ce <cpunum>
f010431e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104321:	8b 80 28 10 1f f0    	mov    -0xfe0efd8(%eax),%eax
f0104327:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f010432b:	75 15                	jne    f0104342 <env_run+0x58>
                  curenv->env_status = ENV_RUNNABLE;
f010432d:	e8 9c 35 00 00       	call   f01078ce <cpunum>
f0104332:	6b c0 74             	imul   $0x74,%eax,%eax
f0104335:	8b 80 28 10 1f f0    	mov    -0xfe0efd8(%eax),%eax
f010433b:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
           }
           curenv = e;
f0104342:	e8 87 35 00 00       	call   f01078ce <cpunum>
f0104347:	6b c0 74             	imul   $0x74,%eax,%eax
f010434a:	89 98 28 10 1f f0    	mov    %ebx,-0xfe0efd8(%eax)
           e->env_status = ENV_RUNNING;
f0104350:	c7 43 54 03 00 00 00 	movl   $0x3,0x54(%ebx)
           e->env_runs++;
f0104357:	83 43 58 01          	addl   $0x1,0x58(%ebx)
           lcr3(PADDR(e->env_pgdir));
f010435b:	8b 43 64             	mov    0x64(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010435e:	89 c2                	mov    %eax,%edx
f0104360:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0104365:	77 20                	ja     f0104387 <env_run+0x9d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0104367:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010436b:	c7 44 24 08 5c 80 10 	movl   $0xf010805c,0x8(%esp)
f0104372:	f0 
f0104373:	c7 44 24 04 21 02 00 	movl   $0x221,0x4(%esp)
f010437a:	00 
f010437b:	c7 04 24 6f 92 10 f0 	movl   $0xf010926f,(%esp)
f0104382:	e8 fe bc ff ff       	call   f0100085 <_panic>
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0104387:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f010438d:	0f 22 da             	mov    %edx,%cr3
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0104390:	c7 04 24 80 43 12 f0 	movl   $0xf0124380,(%esp)
f0104397:	e8 e0 37 00 00       	call   f0107b7c <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f010439c:	f3 90                	pause  
        }
        //print_trapframe(&e->env_tf);
        
        unlock_kernel(); 
        env_pop_tf(&e->env_tf);     
f010439e:	89 1c 24             	mov    %ebx,(%esp)
f01043a1:	e8 01 ff ff ff       	call   f01042a7 <env_pop_tf>

f01043a6 <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f01043a6:	55                   	push   %ebp
f01043a7:	89 e5                	mov    %esp,%ebp
f01043a9:	57                   	push   %edi
f01043aa:	56                   	push   %esi
f01043ab:	53                   	push   %ebx
f01043ac:	83 ec 2c             	sub    $0x2c,%esp
f01043af:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f01043b2:	e8 17 35 00 00       	call   f01078ce <cpunum>
f01043b7:	6b c0 74             	imul   $0x74,%eax,%eax
f01043ba:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f01043c1:	39 b8 28 10 1f f0    	cmp    %edi,-0xfe0efd8(%eax)
f01043c7:	75 3c                	jne    f0104405 <env_free+0x5f>
		lcr3(PADDR(kern_pgdir));
f01043c9:	a1 ac 0e 1f f0       	mov    0xf01f0eac,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01043ce:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01043d3:	77 20                	ja     f01043f5 <env_free+0x4f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01043d5:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01043d9:	c7 44 24 08 5c 80 10 	movl   $0xf010805c,0x8(%esp)
f01043e0:	f0 
f01043e1:	c7 44 24 04 a8 01 00 	movl   $0x1a8,0x4(%esp)
f01043e8:	00 
f01043e9:	c7 04 24 6f 92 10 f0 	movl   $0xf010926f,(%esp)
f01043f0:	e8 90 bc ff ff       	call   f0100085 <_panic>
f01043f5:	8d 80 00 00 00 10    	lea    0x10000000(%eax),%eax
f01043fb:	0f 22 d8             	mov    %eax,%cr3
f01043fe:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0104405:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104408:	c1 e0 02             	shl    $0x2,%eax
f010440b:	89 45 dc             	mov    %eax,-0x24(%ebp)
	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f010440e:	8b 47 64             	mov    0x64(%edi),%eax
f0104411:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0104414:	8b 34 10             	mov    (%eax,%edx,1),%esi
f0104417:	f7 c6 01 00 00 00    	test   $0x1,%esi
f010441d:	0f 84 b8 00 00 00    	je     f01044db <env_free+0x135>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0104423:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0104429:	89 f0                	mov    %esi,%eax
f010442b:	c1 e8 0c             	shr    $0xc,%eax
f010442e:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104431:	3b 05 a8 0e 1f f0    	cmp    0xf01f0ea8,%eax
f0104437:	72 20                	jb     f0104459 <env_free+0xb3>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0104439:	89 74 24 0c          	mov    %esi,0xc(%esp)
f010443d:	c7 44 24 08 80 80 10 	movl   $0xf0108080,0x8(%esp)
f0104444:	f0 
f0104445:	c7 44 24 04 b7 01 00 	movl   $0x1b7,0x4(%esp)
f010444c:	00 
f010444d:	c7 04 24 6f 92 10 f0 	movl   $0xf010926f,(%esp)
f0104454:	e8 2c bc ff ff       	call   f0100085 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0104459:	8b 55 e0             	mov    -0x20(%ebp),%edx
f010445c:	c1 e2 16             	shl    $0x16,%edx
f010445f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0104462:	bb 00 00 00 00       	mov    $0x0,%ebx
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
f0104467:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f010446e:	01 
f010446f:	74 17                	je     f0104488 <env_free+0xe2>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0104471:	89 d8                	mov    %ebx,%eax
f0104473:	c1 e0 0c             	shl    $0xc,%eax
f0104476:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0104479:	89 44 24 04          	mov    %eax,0x4(%esp)
f010447d:	8b 47 64             	mov    0x64(%edi),%eax
f0104480:	89 04 24             	mov    %eax,(%esp)
f0104483:	e8 d8 de ff ff       	call   f0102360 <page_remove>
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0104488:	83 c3 01             	add    $0x1,%ebx
f010448b:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f0104491:	75 d4                	jne    f0104467 <env_free+0xc1>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0104493:	8b 47 64             	mov    0x64(%edi),%eax
f0104496:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0104499:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01044a0:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01044a3:	3b 05 a8 0e 1f f0    	cmp    0xf01f0ea8,%eax
f01044a9:	72 1c                	jb     f01044c7 <env_free+0x121>
		panic("pa2page called with invalid pa");
f01044ab:	c7 44 24 08 70 8c 10 	movl   $0xf0108c70,0x8(%esp)
f01044b2:	f0 
f01044b3:	c7 44 24 04 4f 00 00 	movl   $0x4f,0x4(%esp)
f01044ba:	00 
f01044bb:	c7 04 24 32 88 10 f0 	movl   $0xf0108832,(%esp)
f01044c2:	e8 be bb ff ff       	call   f0100085 <_panic>
		page_decref(pa2page(pa));
f01044c7:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01044ca:	c1 e0 03             	shl    $0x3,%eax
f01044cd:	03 05 b0 0e 1f f0    	add    0xf01f0eb0,%eax
f01044d3:	89 04 24             	mov    %eax,(%esp)
f01044d6:	e8 09 d2 ff ff       	call   f01016e4 <page_decref>
	// Note the environment's demise.
	// cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f01044db:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
f01044df:	81 7d e0 bb 03 00 00 	cmpl   $0x3bb,-0x20(%ebp)
f01044e6:	0f 85 19 ff ff ff    	jne    f0104405 <env_free+0x5f>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f01044ec:	8b 47 64             	mov    0x64(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01044ef:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01044f4:	77 20                	ja     f0104516 <env_free+0x170>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01044f6:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01044fa:	c7 44 24 08 5c 80 10 	movl   $0xf010805c,0x8(%esp)
f0104501:	f0 
f0104502:	c7 44 24 04 c5 01 00 	movl   $0x1c5,0x4(%esp)
f0104509:	00 
f010450a:	c7 04 24 6f 92 10 f0 	movl   $0xf010926f,(%esp)
f0104511:	e8 6f bb ff ff       	call   f0100085 <_panic>
	e->env_pgdir = 0;
f0104516:	c7 47 64 00 00 00 00 	movl   $0x0,0x64(%edi)
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010451d:	8d 80 00 00 00 10    	lea    0x10000000(%eax),%eax
f0104523:	c1 e8 0c             	shr    $0xc,%eax
f0104526:	3b 05 a8 0e 1f f0    	cmp    0xf01f0ea8,%eax
f010452c:	72 1c                	jb     f010454a <env_free+0x1a4>
		panic("pa2page called with invalid pa");
f010452e:	c7 44 24 08 70 8c 10 	movl   $0xf0108c70,0x8(%esp)
f0104535:	f0 
f0104536:	c7 44 24 04 4f 00 00 	movl   $0x4f,0x4(%esp)
f010453d:	00 
f010453e:	c7 04 24 32 88 10 f0 	movl   $0xf0108832,(%esp)
f0104545:	e8 3b bb ff ff       	call   f0100085 <_panic>
	page_decref(pa2page(pa));
f010454a:	c1 e0 03             	shl    $0x3,%eax
f010454d:	03 05 b0 0e 1f f0    	add    0xf01f0eb0,%eax
f0104553:	89 04 24             	mov    %eax,(%esp)
f0104556:	e8 89 d1 ff ff       	call   f01016e4 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f010455b:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f0104562:	a1 60 02 1f f0       	mov    0xf01f0260,%eax
f0104567:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f010456a:	89 3d 60 02 1f f0    	mov    %edi,0xf01f0260
}
f0104570:	83 c4 2c             	add    $0x2c,%esp
f0104573:	5b                   	pop    %ebx
f0104574:	5e                   	pop    %esi
f0104575:	5f                   	pop    %edi
f0104576:	5d                   	pop    %ebp
f0104577:	c3                   	ret    

f0104578 <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f0104578:	55                   	push   %ebp
f0104579:	89 e5                	mov    %esp,%ebp
f010457b:	53                   	push   %ebx
f010457c:	83 ec 14             	sub    $0x14,%esp
f010457f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f0104582:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f0104586:	75 19                	jne    f01045a1 <env_destroy+0x29>
f0104588:	e8 41 33 00 00       	call   f01078ce <cpunum>
f010458d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104590:	39 98 28 10 1f f0    	cmp    %ebx,-0xfe0efd8(%eax)
f0104596:	74 09                	je     f01045a1 <env_destroy+0x29>
		e->env_status = ENV_DYING;
f0104598:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f010459f:	eb 2f                	jmp    f01045d0 <env_destroy+0x58>
	}

	env_free(e);
f01045a1:	89 1c 24             	mov    %ebx,(%esp)
f01045a4:	e8 fd fd ff ff       	call   f01043a6 <env_free>

	if (curenv == e) {
f01045a9:	e8 20 33 00 00       	call   f01078ce <cpunum>
f01045ae:	6b c0 74             	imul   $0x74,%eax,%eax
f01045b1:	39 98 28 10 1f f0    	cmp    %ebx,-0xfe0efd8(%eax)
f01045b7:	75 17                	jne    f01045d0 <env_destroy+0x58>
		curenv = NULL;
f01045b9:	e8 10 33 00 00       	call   f01078ce <cpunum>
f01045be:	6b c0 74             	imul   $0x74,%eax,%eax
f01045c1:	c7 80 28 10 1f f0 00 	movl   $0x0,-0xfe0efd8(%eax)
f01045c8:	00 00 00 
		sched_yield();
f01045cb:	e8 60 13 00 00       	call   f0105930 <sched_yield>
	}
}
f01045d0:	83 c4 14             	add    $0x14,%esp
f01045d3:	5b                   	pop    %ebx
f01045d4:	5d                   	pop    %ebp
f01045d5:	c3                   	ret    

f01045d6 <env_alloc>:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f01045d6:	55                   	push   %ebp
f01045d7:	89 e5                	mov    %esp,%ebp
f01045d9:	53                   	push   %ebx
f01045da:	83 ec 14             	sub    $0x14,%esp
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f01045dd:	8b 1d 60 02 1f f0    	mov    0xf01f0260,%ebx
f01045e3:	ba fb ff ff ff       	mov    $0xfffffffb,%edx
f01045e8:	85 db                	test   %ebx,%ebx
f01045ea:	0f 84 66 01 00 00    	je     f0104756 <env_alloc+0x180>
{
	int i;
	struct Page *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f01045f0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01045f7:	e8 ab da ff ff       	call   f01020a7 <page_alloc>
f01045fc:	ba fc ff ff ff       	mov    $0xfffffffc,%edx
f0104601:	85 c0                	test   %eax,%eax
f0104603:	0f 84 4d 01 00 00    	je     f0104756 <env_alloc+0x180>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0104609:	89 c2                	mov    %eax,%edx
f010460b:	2b 15 b0 0e 1f f0    	sub    0xf01f0eb0,%edx
f0104611:	c1 fa 03             	sar    $0x3,%edx
f0104614:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0104617:	89 d1                	mov    %edx,%ecx
f0104619:	c1 e9 0c             	shr    $0xc,%ecx
f010461c:	3b 0d a8 0e 1f f0    	cmp    0xf01f0ea8,%ecx
f0104622:	72 20                	jb     f0104644 <env_alloc+0x6e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0104624:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0104628:	c7 44 24 08 80 80 10 	movl   $0xf0108080,0x8(%esp)
f010462f:	f0 
f0104630:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0104637:	00 
f0104638:	c7 04 24 32 88 10 f0 	movl   $0xf0108832,(%esp)
f010463f:	e8 41 ba ff ff       	call   f0100085 <_panic>
	//	is an exception -- you need to increment env_pgdir's
	//	pp_ref for env_free to work correctly.
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.
        e->env_pgdir = (pde_t*)page2kva(p);
f0104644:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f010464a:	89 53 64             	mov    %edx,0x64(%ebx)
        p->pp_ref++;
f010464d:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
        memmove(e->env_pgdir,kern_pgdir,PGSIZE);
f0104652:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0104659:	00 
f010465a:	a1 ac 0e 1f f0       	mov    0xf01f0eac,%eax
f010465f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104663:	8b 43 64             	mov    0x64(%ebx),%eax
f0104666:	89 04 24             	mov    %eax,(%esp)
f0104669:	e8 17 2c 00 00       	call   f0107285 <memmove>
	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f010466e:	8b 43 64             	mov    0x64(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0104671:	89 c2                	mov    %eax,%edx
f0104673:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0104678:	77 20                	ja     f010469a <env_alloc+0xc4>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010467a:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010467e:	c7 44 24 08 5c 80 10 	movl   $0xf010805c,0x8(%esp)
f0104685:	f0 
f0104686:	c7 44 24 04 c4 00 00 	movl   $0xc4,0x4(%esp)
f010468d:	00 
f010468e:	c7 04 24 6f 92 10 f0 	movl   $0xf010926f,(%esp)
f0104695:	e8 eb b9 ff ff       	call   f0100085 <_panic>
f010469a:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f01046a0:	83 ca 05             	or     $0x5,%edx
f01046a3:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f01046a9:	8b 43 48             	mov    0x48(%ebx),%eax
f01046ac:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f01046b1:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f01046b6:	7f 05                	jg     f01046bd <env_alloc+0xe7>
f01046b8:	b8 00 10 00 00       	mov    $0x1000,%eax
		generation = 1 << ENVGENSHIFT;
	e->env_id = generation | (e - envs);
f01046bd:	89 da                	mov    %ebx,%edx
f01046bf:	2b 15 5c 02 1f f0    	sub    0xf01f025c,%edx
f01046c5:	c1 fa 02             	sar    $0x2,%edx
f01046c8:	69 d2 e1 83 0f 3e    	imul   $0x3e0f83e1,%edx,%edx
f01046ce:	09 d0                	or     %edx,%eax
f01046d0:	89 43 48             	mov    %eax,0x48(%ebx)
        //cprintf("envs:%8x\n",e->env_id);
	// Set the basic status variables.
	e->env_parent_id = parent_id;
f01046d3:	8b 45 0c             	mov    0xc(%ebp),%eax
f01046d6:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f01046d9:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f01046e0:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f01046e7:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f01046ee:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
f01046f5:	00 
f01046f6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01046fd:	00 
f01046fe:	89 1c 24             	mov    %ebx,(%esp)
f0104701:	e8 20 2b 00 00       	call   f0107226 <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f0104706:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f010470c:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f0104712:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f0104718:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f010471f:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	// You will set e->env_tf.tf_eip later.
        e->env_prior = PRIOR_MIDD;
f0104725:	c7 83 80 00 00 00 02 	movl   $0x2,0x80(%ebx)
f010472c:	00 00 00 

	// Enable interrupts while in user mode.
	// LAB 4: Your code here.
        e->env_tf.tf_eflags |= FL_IF;
f010472f:	81 4b 38 00 02 00 00 	orl    $0x200,0x38(%ebx)
	// Clear the page fault handler until user installs one.
	e->env_pgfault_upcall = 0;
f0104736:	c7 43 68 00 00 00 00 	movl   $0x0,0x68(%ebx)

	// Also clear the IPC receiving flag.
	e->env_ipc_recving = 0;
f010473d:	c7 43 6c 00 00 00 00 	movl   $0x0,0x6c(%ebx)

	// commit the allocation
	env_free_list = e->env_link;
f0104744:	8b 43 44             	mov    0x44(%ebx),%eax
f0104747:	a3 60 02 1f f0       	mov    %eax,0xf01f0260
	*newenv_store = e;
f010474c:	8b 45 08             	mov    0x8(%ebp),%eax
f010474f:	89 18                	mov    %ebx,(%eax)
f0104751:	ba 00 00 00 00       	mov    $0x0,%edx

	// cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f0104756:	89 d0                	mov    %edx,%eax
f0104758:	83 c4 14             	add    $0x14,%esp
f010475b:	5b                   	pop    %ebx
f010475c:	5d                   	pop    %ebp
f010475d:	c3                   	ret    

f010475e <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f010475e:	55                   	push   %ebp
f010475f:	89 e5                	mov    %esp,%ebp
f0104761:	57                   	push   %edi
f0104762:	56                   	push   %esi
f0104763:	53                   	push   %ebx
f0104764:	83 ec 1c             	sub    $0x1c,%esp
f0104767:	89 c6                	mov    %eax,%esi
	//
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
        void* begin = ROUNDDOWN(va,PGSIZE);
f0104769:	89 d3                	mov    %edx,%ebx
f010476b:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
        void* end = ROUNDUP(va+len,PGSIZE);
f0104771:	8d bc 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%edi
f0104778:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
        while(begin < end){
f010477e:	39 fb                	cmp    %edi,%ebx
f0104780:	73 51                	jae    f01047d3 <region_alloc+0x75>
           struct Page* page = page_alloc(0);
f0104782:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0104789:	e8 19 d9 ff ff       	call   f01020a7 <page_alloc>
           if(page == NULL)
f010478e:	85 c0                	test   %eax,%eax
f0104790:	75 1c                	jne    f01047ae <region_alloc+0x50>
               panic("page alloc failed\n");
f0104792:	c7 44 24 08 7a 92 10 	movl   $0xf010927a,0x8(%esp)
f0104799:	f0 
f010479a:	c7 44 24 04 28 01 00 	movl   $0x128,0x4(%esp)
f01047a1:	00 
f01047a2:	c7 04 24 6f 92 10 f0 	movl   $0xf010926f,(%esp)
f01047a9:	e8 d7 b8 ff ff       	call   f0100085 <_panic>
           page_insert(e->env_pgdir,page,begin,PTE_U|PTE_W|PTE_P);
f01047ae:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
f01047b5:	00 
f01047b6:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01047ba:	89 44 24 04          	mov    %eax,0x4(%esp)
f01047be:	8b 46 64             	mov    0x64(%esi),%eax
f01047c1:	89 04 24             	mov    %eax,(%esp)
f01047c4:	e8 f2 db ff ff       	call   f01023bb <page_insert>
           begin += PGSIZE;
f01047c9:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
        void* begin = ROUNDDOWN(va,PGSIZE);
        void* end = ROUNDUP(va+len,PGSIZE);
        while(begin < end){
f01047cf:	39 df                	cmp    %ebx,%edi
f01047d1:	77 af                	ja     f0104782 <region_alloc+0x24>
           if(page == NULL)
               panic("page alloc failed\n");
           page_insert(e->env_pgdir,page,begin,PTE_U|PTE_W|PTE_P);
           begin += PGSIZE;
        }
}
f01047d3:	83 c4 1c             	add    $0x1c,%esp
f01047d6:	5b                   	pop    %ebx
f01047d7:	5e                   	pop    %esi
f01047d8:	5f                   	pop    %edi
f01047d9:	5d                   	pop    %ebp
f01047da:	c3                   	ret    

f01047db <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, size_t size, enum EnvType type)
{
f01047db:	55                   	push   %ebp
f01047dc:	89 e5                	mov    %esp,%ebp
f01047de:	57                   	push   %edi
f01047df:	56                   	push   %esi
f01047e0:	53                   	push   %ebx
f01047e1:	83 ec 3c             	sub    $0x3c,%esp
	// If this is the file server (type == ENV_TYPE_FS) give it I/O privileges.
	// LAB 5: Your code here.

        struct Env* newEnv;
        int r;
        r = env_alloc(&newEnv,0);
f01047e4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01047eb:	00 
f01047ec:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01047ef:	89 04 24             	mov    %eax,(%esp)
f01047f2:	e8 df fd ff ff       	call   f01045d6 <env_alloc>
        if(r < 0)
f01047f7:	85 c0                	test   %eax,%eax
f01047f9:	79 20                	jns    f010481b <env_create+0x40>
           panic("env_alloc: %e", r);
f01047fb:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01047ff:	c7 44 24 08 8d 92 10 	movl   $0xf010928d,0x8(%esp)
f0104806:	f0 
f0104807:	c7 44 24 04 92 01 00 	movl   $0x192,0x4(%esp)
f010480e:	00 
f010480f:	c7 04 24 6f 92 10 f0 	movl   $0xf010926f,(%esp)
f0104816:	e8 6a b8 ff ff       	call   f0100085 <_panic>
        load_icode(newEnv,binary,size);
f010481b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
	//  You must also do something with the program's entry point,
	//  to make sure that the environment starts executing there.
	//  What?  (See env_run() and env_pop_tf() below.)

	// LAB 3: Your code here.
        struct Elf* elfhdr = (struct Elf*)binary;
f010481e:	8b 45 08             	mov    0x8(%ebp),%eax
f0104821:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        struct Proghdr *ph, *eph;
        if (elfhdr->e_magic != ELF_MAGIC)
f0104824:	81 38 7f 45 4c 46    	cmpl   $0x464c457f,(%eax)
f010482a:	74 1c                	je     f0104848 <env_create+0x6d>
		panic("Wrong ELF FILE\n");
f010482c:	c7 44 24 08 9b 92 10 	movl   $0xf010929b,0x8(%esp)
f0104833:	f0 
f0104834:	c7 44 24 04 67 01 00 	movl   $0x167,0x4(%esp)
f010483b:	00 
f010483c:	c7 04 24 6f 92 10 f0 	movl   $0xf010926f,(%esp)
f0104843:	e8 3d b8 ff ff       	call   f0100085 <_panic>
        ph = (struct Proghdr *) ((uint8_t *) elfhdr + elfhdr->e_phoff);
f0104848:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f010484b:	8b 5a 1c             	mov    0x1c(%edx),%ebx
        eph = ph + elfhdr->e_phnum;
f010484e:	0f b7 72 2c          	movzwl 0x2c(%edx),%esi

        lcr3(PADDR(e->env_pgdir));
f0104852:	8b 47 64             	mov    0x64(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0104855:	89 c2                	mov    %eax,%edx
f0104857:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010485c:	77 20                	ja     f010487e <env_create+0xa3>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010485e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104862:	c7 44 24 08 5c 80 10 	movl   $0xf010805c,0x8(%esp)
f0104869:	f0 
f010486a:	c7 44 24 04 6b 01 00 	movl   $0x16b,0x4(%esp)
f0104871:	00 
f0104872:	c7 04 24 6f 92 10 f0 	movl   $0xf010926f,(%esp)
f0104879:	e8 07 b8 ff ff       	call   f0100085 <_panic>
	// LAB 3: Your code here.
        struct Elf* elfhdr = (struct Elf*)binary;
        struct Proghdr *ph, *eph;
        if (elfhdr->e_magic != ELF_MAGIC)
		panic("Wrong ELF FILE\n");
        ph = (struct Proghdr *) ((uint8_t *) elfhdr + elfhdr->e_phoff);
f010487e:	03 5d d4             	add    -0x2c(%ebp),%ebx
        eph = ph + elfhdr->e_phnum;
f0104881:	0f b7 f6             	movzwl %si,%esi
f0104884:	c1 e6 05             	shl    $0x5,%esi
f0104887:	8d 34 33             	lea    (%ebx,%esi,1),%esi
f010488a:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f0104890:	0f 22 da             	mov    %edx,%cr3

        lcr3(PADDR(e->env_pgdir));
        for (; ph < eph; ph++){
f0104893:	39 f3                	cmp    %esi,%ebx
f0104895:	73 5d                	jae    f01048f4 <env_create+0x119>
                if(ph->p_type == ELF_PROG_LOAD){
f0104897:	83 3b 01             	cmpl   $0x1,(%ebx)
f010489a:	75 51                	jne    f01048ed <env_create+0x112>
		   region_alloc(e,(void*)ph->p_va,ph->p_memsz);
f010489c:	8b 4b 14             	mov    0x14(%ebx),%ecx
f010489f:	8b 53 08             	mov    0x8(%ebx),%edx
f01048a2:	89 f8                	mov    %edi,%eax
f01048a4:	e8 b5 fe ff ff       	call   f010475e <region_alloc>
                   memset((void*)ph->p_va,0,ph->p_memsz);
f01048a9:	8b 43 14             	mov    0x14(%ebx),%eax
f01048ac:	89 44 24 08          	mov    %eax,0x8(%esp)
f01048b0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01048b7:	00 
f01048b8:	8b 43 08             	mov    0x8(%ebx),%eax
f01048bb:	89 04 24             	mov    %eax,(%esp)
f01048be:	e8 63 29 00 00       	call   f0107226 <memset>
                   if(ph->p_va + ph->p_memsz > e->env_break)
f01048c3:	8b 43 14             	mov    0x14(%ebx),%eax
f01048c6:	03 43 08             	add    0x8(%ebx),%eax
f01048c9:	3b 47 60             	cmp    0x60(%edi),%eax
f01048cc:	76 03                	jbe    f01048d1 <env_create+0xf6>
                      e->env_break = ph->p_va + ph->p_memsz;
f01048ce:	89 47 60             	mov    %eax,0x60(%edi)
                   memmove((void*)ph->p_va,binary+ph->p_offset,ph->p_filesz);
f01048d1:	8b 43 10             	mov    0x10(%ebx),%eax
f01048d4:	89 44 24 08          	mov    %eax,0x8(%esp)
f01048d8:	8b 45 08             	mov    0x8(%ebp),%eax
f01048db:	03 43 04             	add    0x4(%ebx),%eax
f01048de:	89 44 24 04          	mov    %eax,0x4(%esp)
f01048e2:	8b 43 08             	mov    0x8(%ebx),%eax
f01048e5:	89 04 24             	mov    %eax,(%esp)
f01048e8:	e8 98 29 00 00       	call   f0107285 <memmove>
		panic("Wrong ELF FILE\n");
        ph = (struct Proghdr *) ((uint8_t *) elfhdr + elfhdr->e_phoff);
        eph = ph + elfhdr->e_phnum;

        lcr3(PADDR(e->env_pgdir));
        for (; ph < eph; ph++){
f01048ed:	83 c3 20             	add    $0x20,%ebx
f01048f0:	39 de                	cmp    %ebx,%esi
f01048f2:	77 a3                	ja     f0104897 <env_create+0xbc>
                   if(ph->p_va + ph->p_memsz > e->env_break)
                      e->env_break = ph->p_va + ph->p_memsz;
                   memmove((void*)ph->p_va,binary+ph->p_offset,ph->p_filesz);
                }
        }
        e->env_tf.tf_eip = elfhdr->e_entry;
f01048f4:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01048f7:	8b 42 18             	mov    0x18(%edx),%eax
f01048fa:	89 47 30             	mov    %eax,0x30(%edi)
        lcr3(PADDR(kern_pgdir));
f01048fd:	a1 ac 0e 1f f0       	mov    0xf01f0eac,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0104902:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0104907:	77 20                	ja     f0104929 <env_create+0x14e>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0104909:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010490d:	c7 44 24 08 5c 80 10 	movl   $0xf010805c,0x8(%esp)
f0104914:	f0 
f0104915:	c7 44 24 04 76 01 00 	movl   $0x176,0x4(%esp)
f010491c:	00 
f010491d:	c7 04 24 6f 92 10 f0 	movl   $0xf010926f,(%esp)
f0104924:	e8 5c b7 ff ff       	call   f0100085 <_panic>
f0104929:	8d 80 00 00 00 10    	lea    0x10000000(%eax),%eax
f010492f:	0f 22 d8             	mov    %eax,%cr3
        
	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.
        region_alloc(e,(void*)(USTACKTOP-PGSIZE),PGSIZE);
f0104932:	b9 00 10 00 00       	mov    $0x1000,%ecx
f0104937:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f010493c:	89 f8                	mov    %edi,%eax
f010493e:	e8 1b fe ff ff       	call   f010475e <region_alloc>
        int r;
        r = env_alloc(&newEnv,0);
        if(r < 0)
           panic("env_alloc: %e", r);
        load_icode(newEnv,binary,size);
        newEnv->env_type = type;
f0104943:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104946:	8b 55 10             	mov    0x10(%ebp),%edx
f0104949:	89 50 50             	mov    %edx,0x50(%eax)
        if(type == ENV_TYPE_FS)
f010494c:	83 fa 02             	cmp    $0x2,%edx
f010494f:	75 0a                	jne    f010495b <env_create+0x180>
           newEnv->env_tf.tf_eflags |= FL_IOPL_MASK;
f0104951:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104954:	81 48 38 00 30 00 00 	orl    $0x3000,0x38(%eax)

}
f010495b:	83 c4 3c             	add    $0x3c,%esp
f010495e:	5b                   	pop    %ebx
f010495f:	5e                   	pop    %esi
f0104960:	5f                   	pop    %edi
f0104961:	5d                   	pop    %ebp
f0104962:	c3                   	ret    
	...

f0104964 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0104964:	55                   	push   %ebp
f0104965:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0104967:	ba 70 00 00 00       	mov    $0x70,%edx
f010496c:	8b 45 08             	mov    0x8(%ebp),%eax
f010496f:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0104970:	b2 71                	mov    $0x71,%dl
f0104972:	ec                   	in     (%dx),%al
f0104973:	0f b6 c0             	movzbl %al,%eax
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
}
f0104976:	5d                   	pop    %ebp
f0104977:	c3                   	ret    

f0104978 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0104978:	55                   	push   %ebp
f0104979:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010497b:	ba 70 00 00 00       	mov    $0x70,%edx
f0104980:	8b 45 08             	mov    0x8(%ebp),%eax
f0104983:	ee                   	out    %al,(%dx)
f0104984:	b2 71                	mov    $0x71,%dl
f0104986:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104989:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f010498a:	5d                   	pop    %ebp
f010498b:	c3                   	ret    

f010498c <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f010498c:	55                   	push   %ebp
f010498d:	89 e5                	mov    %esp,%ebp
f010498f:	56                   	push   %esi
f0104990:	53                   	push   %ebx
f0104991:	83 ec 10             	sub    $0x10,%esp
f0104994:	8b 45 08             	mov    0x8(%ebp),%eax
f0104997:	89 c6                	mov    %eax,%esi
	int i;
	irq_mask_8259A = mask;
f0104999:	66 a3 70 43 12 f0    	mov    %ax,0xf0124370
	if (!didinit)
f010499f:	83 3d 64 02 1f f0 00 	cmpl   $0x0,0xf01f0264
f01049a6:	74 4e                	je     f01049f6 <irq_setmask_8259A+0x6a>
f01049a8:	ba 21 00 00 00       	mov    $0x21,%edx
f01049ad:	ee                   	out    %al,(%dx)
f01049ae:	89 f0                	mov    %esi,%eax
f01049b0:	66 c1 e8 08          	shr    $0x8,%ax
f01049b4:	b2 a1                	mov    $0xa1,%dl
f01049b6:	ee                   	out    %al,(%dx)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
f01049b7:	c7 04 24 ab 92 10 f0 	movl   $0xf01092ab,(%esp)
f01049be:	e8 fc 00 00 00       	call   f0104abf <cprintf>
f01049c3:	bb 00 00 00 00       	mov    $0x0,%ebx
	for (i = 0; i < 16; i++)
		if (~mask & (1<<i))
f01049c8:	0f b7 f6             	movzwl %si,%esi
f01049cb:	f7 d6                	not    %esi
f01049cd:	0f a3 de             	bt     %ebx,%esi
f01049d0:	73 10                	jae    f01049e2 <irq_setmask_8259A+0x56>
			cprintf(" %d", i);
f01049d2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01049d6:	c7 04 24 8c 97 10 f0 	movl   $0xf010978c,(%esp)
f01049dd:	e8 dd 00 00 00       	call   f0104abf <cprintf>
	if (!didinit)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
f01049e2:	83 c3 01             	add    $0x1,%ebx
f01049e5:	83 fb 10             	cmp    $0x10,%ebx
f01049e8:	75 e3                	jne    f01049cd <irq_setmask_8259A+0x41>
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
f01049ea:	c7 04 24 d9 84 10 f0 	movl   $0xf01084d9,(%esp)
f01049f1:	e8 c9 00 00 00       	call   f0104abf <cprintf>
}
f01049f6:	83 c4 10             	add    $0x10,%esp
f01049f9:	5b                   	pop    %ebx
f01049fa:	5e                   	pop    %esi
f01049fb:	5d                   	pop    %ebp
f01049fc:	c3                   	ret    

f01049fd <pic_init>:
static bool didinit;

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
f01049fd:	55                   	push   %ebp
f01049fe:	89 e5                	mov    %esp,%ebp
f0104a00:	83 ec 18             	sub    $0x18,%esp
	didinit = 1;
f0104a03:	c7 05 64 02 1f f0 01 	movl   $0x1,0xf01f0264
f0104a0a:	00 00 00 
f0104a0d:	ba 21 00 00 00       	mov    $0x21,%edx
f0104a12:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104a17:	ee                   	out    %al,(%dx)
f0104a18:	b2 a1                	mov    $0xa1,%dl
f0104a1a:	ee                   	out    %al,(%dx)
f0104a1b:	b2 20                	mov    $0x20,%dl
f0104a1d:	b8 11 00 00 00       	mov    $0x11,%eax
f0104a22:	ee                   	out    %al,(%dx)
f0104a23:	b2 21                	mov    $0x21,%dl
f0104a25:	b8 20 00 00 00       	mov    $0x20,%eax
f0104a2a:	ee                   	out    %al,(%dx)
f0104a2b:	b8 04 00 00 00       	mov    $0x4,%eax
f0104a30:	ee                   	out    %al,(%dx)
f0104a31:	b8 03 00 00 00       	mov    $0x3,%eax
f0104a36:	ee                   	out    %al,(%dx)
f0104a37:	b2 a0                	mov    $0xa0,%dl
f0104a39:	b8 11 00 00 00       	mov    $0x11,%eax
f0104a3e:	ee                   	out    %al,(%dx)
f0104a3f:	b2 a1                	mov    $0xa1,%dl
f0104a41:	b8 28 00 00 00       	mov    $0x28,%eax
f0104a46:	ee                   	out    %al,(%dx)
f0104a47:	b8 02 00 00 00       	mov    $0x2,%eax
f0104a4c:	ee                   	out    %al,(%dx)
f0104a4d:	b8 01 00 00 00       	mov    $0x1,%eax
f0104a52:	ee                   	out    %al,(%dx)
f0104a53:	b2 20                	mov    $0x20,%dl
f0104a55:	b8 68 00 00 00       	mov    $0x68,%eax
f0104a5a:	ee                   	out    %al,(%dx)
f0104a5b:	b8 0a 00 00 00       	mov    $0xa,%eax
f0104a60:	ee                   	out    %al,(%dx)
f0104a61:	b2 a0                	mov    $0xa0,%dl
f0104a63:	b8 68 00 00 00       	mov    $0x68,%eax
f0104a68:	ee                   	out    %al,(%dx)
f0104a69:	b8 0a 00 00 00       	mov    $0xa,%eax
f0104a6e:	ee                   	out    %al,(%dx)
	outb(IO_PIC1, 0x0a);             /* read IRR by default */

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
f0104a6f:	0f b7 05 70 43 12 f0 	movzwl 0xf0124370,%eax
f0104a76:	66 83 f8 ff          	cmp    $0xffffffff,%ax
f0104a7a:	74 0b                	je     f0104a87 <pic_init+0x8a>
		irq_setmask_8259A(irq_mask_8259A);
f0104a7c:	0f b7 c0             	movzwl %ax,%eax
f0104a7f:	89 04 24             	mov    %eax,(%esp)
f0104a82:	e8 05 ff ff ff       	call   f010498c <irq_setmask_8259A>
}
f0104a87:	c9                   	leave  
f0104a88:	c3                   	ret    
f0104a89:	00 00                	add    %al,(%eax)
	...

f0104a8c <vcprintf>:
	*cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
f0104a8c:	55                   	push   %ebp
f0104a8d:	89 e5                	mov    %esp,%ebp
f0104a8f:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f0104a92:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0104a99:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104a9c:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104aa0:	8b 45 08             	mov    0x8(%ebp),%eax
f0104aa3:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104aa7:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0104aaa:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104aae:	c7 04 24 d9 4a 10 f0 	movl   $0xf0104ad9,(%esp)
f0104ab5:	e8 82 1d 00 00       	call   f010683c <vprintfmt>
	return cnt;
}
f0104aba:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104abd:	c9                   	leave  
f0104abe:	c3                   	ret    

f0104abf <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0104abf:	55                   	push   %ebp
f0104ac0:	89 e5                	mov    %esp,%ebp
f0104ac2:	83 ec 18             	sub    $0x18,%esp
	vprintfmt((void*)putch, &cnt, fmt, ap);
	return cnt;
}

int
cprintf(const char *fmt, ...)
f0104ac5:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
f0104ac8:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104acc:	8b 45 08             	mov    0x8(%ebp),%eax
f0104acf:	89 04 24             	mov    %eax,(%esp)
f0104ad2:	e8 b5 ff ff ff       	call   f0104a8c <vcprintf>
	va_end(ap);

	return cnt;
}
f0104ad7:	c9                   	leave  
f0104ad8:	c3                   	ret    

f0104ad9 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0104ad9:	55                   	push   %ebp
f0104ada:	89 e5                	mov    %esp,%ebp
f0104adc:	83 ec 18             	sub    $0x18,%esp
	cputchar(ch);
f0104adf:	8b 45 08             	mov    0x8(%ebp),%eax
f0104ae2:	89 04 24             	mov    %eax,(%esp)
f0104ae5:	e8 40 bc ff ff       	call   f010072a <cputchar>
	*cnt++;
}
f0104aea:	c9                   	leave  
f0104aeb:	c3                   	ret    
f0104aec:	00 00                	add    %al,(%eax)
	...

f0104af0 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0104af0:	55                   	push   %ebp
f0104af1:	89 e5                	mov    %esp,%ebp
f0104af3:	83 ec 18             	sub    $0x18,%esp
f0104af6:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0104af9:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0104afc:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// get a triple fault.  If you set up an individual CPU's TSS
	// wrong, you may not get a fault until you try to return from
	// user space on that CPU.
	//
	// LAB 4: Your code here:
        uint32_t cpuid = cpunum();
f0104aff:	e8 ca 2d 00 00       	call   f01078ce <cpunum>
f0104b04:	89 c3                	mov    %eax,%ebx
}

static inline void 
wrmsr(unsigned msr, unsigned low, unsigned high)
{
        asm volatile("wrmsr" : : "c" (msr), "a"(low), "d" (high) : "memory");
f0104b06:	ba 00 00 00 00       	mov    $0x0,%edx
f0104b0b:	b8 08 00 00 00       	mov    $0x8,%eax
f0104b10:	b9 74 01 00 00       	mov    $0x174,%ecx
f0104b15:	0f 30                	wrmsr  

        extern void sysenter_handler();
	wrmsr(0x174, GD_KT, 0);
	wrmsr(0x175, KSTACKTOP - cpuid*(KSTKSIZE + KSTKGAP), 0);
f0104b17:	be c0 ef 00 00       	mov    $0xefc0,%esi
f0104b1c:	29 de                	sub    %ebx,%esi
f0104b1e:	c1 e6 10             	shl    $0x10,%esi
f0104b21:	b1 75                	mov    $0x75,%cl
f0104b23:	89 f0                	mov    %esi,%eax
f0104b25:	0f 30                	wrmsr  
f0104b27:	b8 ea 58 10 f0       	mov    $0xf01058ea,%eax
f0104b2c:	b1 76                	mov    $0x76,%cl
f0104b2e:	0f 30                	wrmsr  
	wrmsr(0x176, (uint32_t)&sysenter_handler, 0);

        struct Taskstate* cpu_ts = &thiscpu->cpu_ts;
f0104b30:	e8 99 2d 00 00       	call   f01078ce <cpunum>
f0104b35:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b38:	05 20 10 1f f0       	add    $0xf01f1020,%eax
f0104b3d:	8d 78 0c             	lea    0xc(%eax),%edi
        cpu_ts->ts_esp0 = KSTACKTOP -cpuid*(KSTKSIZE +KSTKGAP);
f0104b40:	89 70 10             	mov    %esi,0x10(%eax)
        cpu_ts->ts_ss0 = GD_KD;
f0104b43:	66 c7 40 14 10 00    	movw   $0x10,0x14(%eax)
        gdt[(GD_TSS0 >> 3) + cpuid] = SEG16(STS_T32A, (uint32_t) (cpu_ts),
f0104b49:	8d 53 05             	lea    0x5(%ebx),%edx
f0104b4c:	b8 00 43 12 f0       	mov    $0xf0124300,%eax
f0104b51:	66 c7 04 d0 68 00    	movw   $0x68,(%eax,%edx,8)
f0104b57:	66 89 7c d0 02       	mov    %di,0x2(%eax,%edx,8)
f0104b5c:	89 fe                	mov    %edi,%esi
f0104b5e:	c1 ee 10             	shr    $0x10,%esi
f0104b61:	89 f1                	mov    %esi,%ecx
f0104b63:	88 4c d0 04          	mov    %cl,0x4(%eax,%edx,8)
f0104b67:	c6 44 d0 06 40       	movb   $0x40,0x6(%eax,%edx,8)
f0104b6c:	89 f9                	mov    %edi,%ecx
f0104b6e:	c1 e9 18             	shr    $0x18,%ecx
f0104b71:	88 4c d0 07          	mov    %cl,0x7(%eax,%edx,8)
					sizeof(struct Taskstate), 0);
	gdt[(GD_TSS0 >> 3) + cpuid].sd_s = 0;
f0104b75:	c6 44 d0 05 89       	movb   $0x89,0x5(%eax,%edx,8)
}

static __inline void
ltr(uint16_t sel)
{
	__asm __volatile("ltr %0" : : "r" (sel));
f0104b7a:	8d 1c dd 28 00 00 00 	lea    0x28(,%ebx,8),%ebx
f0104b81:	0f 00 db             	ltr    %bx
}  

static __inline void
lidt(void *p)
{
	__asm __volatile("lidt (%0)" : : "r" (p));
f0104b84:	b8 74 43 12 f0       	mov    $0xf0124374,%eax
f0104b89:	0f 01 18             	lidtl  (%eax)
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0);

	// Load the IDT
	lidt(&idt_pd);*/
}
f0104b8c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0104b8f:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0104b92:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0104b95:	89 ec                	mov    %ebp,%esp
f0104b97:	5d                   	pop    %ebp
f0104b98:	c3                   	ret    

f0104b99 <trap_init>:
}


void
trap_init(void)
{
f0104b99:	55                   	push   %ebp
f0104b9a:	89 e5                	mov    %esp,%ebp
f0104b9c:	83 ec 08             	sub    $0x8,%esp
        extern void handler_ide();
        extern void handler_irq15();


       
        SETGATE(idt[T_DIVIDE],0,GD_KT,handler_divide, 0);
f0104b9f:	b8 cc 57 10 f0       	mov    $0xf01057cc,%eax
f0104ba4:	66 a3 80 02 1f f0    	mov    %ax,0xf01f0280
f0104baa:	66 c7 05 82 02 1f f0 	movw   $0x8,0xf01f0282
f0104bb1:	08 00 
f0104bb3:	c6 05 84 02 1f f0 00 	movb   $0x0,0xf01f0284
f0104bba:	c6 05 85 02 1f f0 8e 	movb   $0x8e,0xf01f0285
f0104bc1:	c1 e8 10             	shr    $0x10,%eax
f0104bc4:	66 a3 86 02 1f f0    	mov    %ax,0xf01f0286
        SETGATE(idt[T_DEBUG],0,GD_KT,handler_debug, 0);
f0104bca:	b8 d6 57 10 f0       	mov    $0xf01057d6,%eax
f0104bcf:	66 a3 88 02 1f f0    	mov    %ax,0xf01f0288
f0104bd5:	66 c7 05 8a 02 1f f0 	movw   $0x8,0xf01f028a
f0104bdc:	08 00 
f0104bde:	c6 05 8c 02 1f f0 00 	movb   $0x0,0xf01f028c
f0104be5:	c6 05 8d 02 1f f0 8e 	movb   $0x8e,0xf01f028d
f0104bec:	c1 e8 10             	shr    $0x10,%eax
f0104bef:	66 a3 8e 02 1f f0    	mov    %ax,0xf01f028e
        SETGATE(idt[T_NMI],0,GD_KT,handler_nmi, 0);
f0104bf5:	b8 e0 57 10 f0       	mov    $0xf01057e0,%eax
f0104bfa:	66 a3 90 02 1f f0    	mov    %ax,0xf01f0290
f0104c00:	66 c7 05 92 02 1f f0 	movw   $0x8,0xf01f0292
f0104c07:	08 00 
f0104c09:	c6 05 94 02 1f f0 00 	movb   $0x0,0xf01f0294
f0104c10:	c6 05 95 02 1f f0 8e 	movb   $0x8e,0xf01f0295
f0104c17:	c1 e8 10             	shr    $0x10,%eax
f0104c1a:	66 a3 96 02 1f f0    	mov    %ax,0xf01f0296
        SETGATE(idt[T_BRKPT],0,GD_KT,handler_brkpt, 3);
f0104c20:	b8 ea 57 10 f0       	mov    $0xf01057ea,%eax
f0104c25:	66 a3 98 02 1f f0    	mov    %ax,0xf01f0298
f0104c2b:	66 c7 05 9a 02 1f f0 	movw   $0x8,0xf01f029a
f0104c32:	08 00 
f0104c34:	c6 05 9c 02 1f f0 00 	movb   $0x0,0xf01f029c
f0104c3b:	c6 05 9d 02 1f f0 ee 	movb   $0xee,0xf01f029d
f0104c42:	c1 e8 10             	shr    $0x10,%eax
f0104c45:	66 a3 9e 02 1f f0    	mov    %ax,0xf01f029e
        SETGATE(idt[T_OFLOW],0,GD_KT,handler_oflow, 0);
f0104c4b:	b8 f4 57 10 f0       	mov    $0xf01057f4,%eax
f0104c50:	66 a3 a0 02 1f f0    	mov    %ax,0xf01f02a0
f0104c56:	66 c7 05 a2 02 1f f0 	movw   $0x8,0xf01f02a2
f0104c5d:	08 00 
f0104c5f:	c6 05 a4 02 1f f0 00 	movb   $0x0,0xf01f02a4
f0104c66:	c6 05 a5 02 1f f0 8e 	movb   $0x8e,0xf01f02a5
f0104c6d:	c1 e8 10             	shr    $0x10,%eax
f0104c70:	66 a3 a6 02 1f f0    	mov    %ax,0xf01f02a6
        SETGATE(idt[T_BOUND],0,GD_KT,handler_bound, 0);
f0104c76:	b8 fe 57 10 f0       	mov    $0xf01057fe,%eax
f0104c7b:	66 a3 a8 02 1f f0    	mov    %ax,0xf01f02a8
f0104c81:	66 c7 05 aa 02 1f f0 	movw   $0x8,0xf01f02aa
f0104c88:	08 00 
f0104c8a:	c6 05 ac 02 1f f0 00 	movb   $0x0,0xf01f02ac
f0104c91:	c6 05 ad 02 1f f0 8e 	movb   $0x8e,0xf01f02ad
f0104c98:	c1 e8 10             	shr    $0x10,%eax
f0104c9b:	66 a3 ae 02 1f f0    	mov    %ax,0xf01f02ae
        SETGATE(idt[T_ILLOP],0,GD_KT,handler_illop, 0);
f0104ca1:	b8 08 58 10 f0       	mov    $0xf0105808,%eax
f0104ca6:	66 a3 b0 02 1f f0    	mov    %ax,0xf01f02b0
f0104cac:	66 c7 05 b2 02 1f f0 	movw   $0x8,0xf01f02b2
f0104cb3:	08 00 
f0104cb5:	c6 05 b4 02 1f f0 00 	movb   $0x0,0xf01f02b4
f0104cbc:	c6 05 b5 02 1f f0 8e 	movb   $0x8e,0xf01f02b5
f0104cc3:	c1 e8 10             	shr    $0x10,%eax
f0104cc6:	66 a3 b6 02 1f f0    	mov    %ax,0xf01f02b6
        SETGATE(idt[T_DEVICE],0,GD_KT,handler_device, 0);
f0104ccc:	b8 12 58 10 f0       	mov    $0xf0105812,%eax
f0104cd1:	66 a3 b8 02 1f f0    	mov    %ax,0xf01f02b8
f0104cd7:	66 c7 05 ba 02 1f f0 	movw   $0x8,0xf01f02ba
f0104cde:	08 00 
f0104ce0:	c6 05 bc 02 1f f0 00 	movb   $0x0,0xf01f02bc
f0104ce7:	c6 05 bd 02 1f f0 8e 	movb   $0x8e,0xf01f02bd
f0104cee:	c1 e8 10             	shr    $0x10,%eax
f0104cf1:	66 a3 be 02 1f f0    	mov    %ax,0xf01f02be
        SETGATE(idt[T_DBLFLT],0,GD_KT,handler_dblflt, 0);
f0104cf7:	b8 1c 58 10 f0       	mov    $0xf010581c,%eax
f0104cfc:	66 a3 c0 02 1f f0    	mov    %ax,0xf01f02c0
f0104d02:	66 c7 05 c2 02 1f f0 	movw   $0x8,0xf01f02c2
f0104d09:	08 00 
f0104d0b:	c6 05 c4 02 1f f0 00 	movb   $0x0,0xf01f02c4
f0104d12:	c6 05 c5 02 1f f0 8e 	movb   $0x8e,0xf01f02c5
f0104d19:	c1 e8 10             	shr    $0x10,%eax
f0104d1c:	66 a3 c6 02 1f f0    	mov    %ax,0xf01f02c6
        SETGATE(idt[T_TSS],0,GD_KT,handler_tss, 0);
f0104d22:	b8 24 58 10 f0       	mov    $0xf0105824,%eax
f0104d27:	66 a3 d0 02 1f f0    	mov    %ax,0xf01f02d0
f0104d2d:	66 c7 05 d2 02 1f f0 	movw   $0x8,0xf01f02d2
f0104d34:	08 00 
f0104d36:	c6 05 d4 02 1f f0 00 	movb   $0x0,0xf01f02d4
f0104d3d:	c6 05 d5 02 1f f0 8e 	movb   $0x8e,0xf01f02d5
f0104d44:	c1 e8 10             	shr    $0x10,%eax
f0104d47:	66 a3 d6 02 1f f0    	mov    %ax,0xf01f02d6
        SETGATE(idt[T_SEGNP],0,GD_KT,handler_segnp, 0);
f0104d4d:	b8 2c 58 10 f0       	mov    $0xf010582c,%eax
f0104d52:	66 a3 d8 02 1f f0    	mov    %ax,0xf01f02d8
f0104d58:	66 c7 05 da 02 1f f0 	movw   $0x8,0xf01f02da
f0104d5f:	08 00 
f0104d61:	c6 05 dc 02 1f f0 00 	movb   $0x0,0xf01f02dc
f0104d68:	c6 05 dd 02 1f f0 8e 	movb   $0x8e,0xf01f02dd
f0104d6f:	c1 e8 10             	shr    $0x10,%eax
f0104d72:	66 a3 de 02 1f f0    	mov    %ax,0xf01f02de
        SETGATE(idt[T_STACK],0,GD_KT,handler_stack, 0);
f0104d78:	b8 34 58 10 f0       	mov    $0xf0105834,%eax
f0104d7d:	66 a3 e0 02 1f f0    	mov    %ax,0xf01f02e0
f0104d83:	66 c7 05 e2 02 1f f0 	movw   $0x8,0xf01f02e2
f0104d8a:	08 00 
f0104d8c:	c6 05 e4 02 1f f0 00 	movb   $0x0,0xf01f02e4
f0104d93:	c6 05 e5 02 1f f0 8e 	movb   $0x8e,0xf01f02e5
f0104d9a:	c1 e8 10             	shr    $0x10,%eax
f0104d9d:	66 a3 e6 02 1f f0    	mov    %ax,0xf01f02e6
        SETGATE(idt[T_GPFLT],0,GD_KT,handler_gpflt, 0);
f0104da3:	b8 3c 58 10 f0       	mov    $0xf010583c,%eax
f0104da8:	66 a3 e8 02 1f f0    	mov    %ax,0xf01f02e8
f0104dae:	66 c7 05 ea 02 1f f0 	movw   $0x8,0xf01f02ea
f0104db5:	08 00 
f0104db7:	c6 05 ec 02 1f f0 00 	movb   $0x0,0xf01f02ec
f0104dbe:	c6 05 ed 02 1f f0 8e 	movb   $0x8e,0xf01f02ed
f0104dc5:	c1 e8 10             	shr    $0x10,%eax
f0104dc8:	66 a3 ee 02 1f f0    	mov    %ax,0xf01f02ee
        SETGATE(idt[T_PGFLT],0,GD_KT,handler_pgflt, 0);
f0104dce:	b8 44 58 10 f0       	mov    $0xf0105844,%eax
f0104dd3:	66 a3 f0 02 1f f0    	mov    %ax,0xf01f02f0
f0104dd9:	66 c7 05 f2 02 1f f0 	movw   $0x8,0xf01f02f2
f0104de0:	08 00 
f0104de2:	c6 05 f4 02 1f f0 00 	movb   $0x0,0xf01f02f4
f0104de9:	c6 05 f5 02 1f f0 8e 	movb   $0x8e,0xf01f02f5
f0104df0:	c1 e8 10             	shr    $0x10,%eax
f0104df3:	66 a3 f6 02 1f f0    	mov    %ax,0xf01f02f6
        SETGATE(idt[T_FPERR],0,GD_KT,handler_fperr, 0);
f0104df9:	b8 4c 58 10 f0       	mov    $0xf010584c,%eax
f0104dfe:	66 a3 00 03 1f f0    	mov    %ax,0xf01f0300
f0104e04:	66 c7 05 02 03 1f f0 	movw   $0x8,0xf01f0302
f0104e0b:	08 00 
f0104e0d:	c6 05 04 03 1f f0 00 	movb   $0x0,0xf01f0304
f0104e14:	c6 05 05 03 1f f0 8e 	movb   $0x8e,0xf01f0305
f0104e1b:	c1 e8 10             	shr    $0x10,%eax
f0104e1e:	66 a3 06 03 1f f0    	mov    %ax,0xf01f0306
        SETGATE(idt[T_ALIGN],0,GD_KT,handler_align, 0);
f0104e24:	b8 56 58 10 f0       	mov    $0xf0105856,%eax
f0104e29:	66 a3 08 03 1f f0    	mov    %ax,0xf01f0308
f0104e2f:	66 c7 05 0a 03 1f f0 	movw   $0x8,0xf01f030a
f0104e36:	08 00 
f0104e38:	c6 05 0c 03 1f f0 00 	movb   $0x0,0xf01f030c
f0104e3f:	c6 05 0d 03 1f f0 8e 	movb   $0x8e,0xf01f030d
f0104e46:	c1 e8 10             	shr    $0x10,%eax
f0104e49:	66 a3 0e 03 1f f0    	mov    %ax,0xf01f030e
        SETGATE(idt[T_MCHK],0,GD_KT,handler_mchk, 0);
f0104e4f:	b8 60 58 10 f0       	mov    $0xf0105860,%eax
f0104e54:	66 a3 10 03 1f f0    	mov    %ax,0xf01f0310
f0104e5a:	66 c7 05 12 03 1f f0 	movw   $0x8,0xf01f0312
f0104e61:	08 00 
f0104e63:	c6 05 14 03 1f f0 00 	movb   $0x0,0xf01f0314
f0104e6a:	c6 05 15 03 1f f0 8e 	movb   $0x8e,0xf01f0315
f0104e71:	c1 e8 10             	shr    $0x10,%eax
f0104e74:	66 a3 16 03 1f f0    	mov    %ax,0xf01f0316
        SETGATE(idt[T_SIMDERR],0,GD_KT,handler_simderr, 0);
f0104e7a:	b8 6a 58 10 f0       	mov    $0xf010586a,%eax
f0104e7f:	66 a3 18 03 1f f0    	mov    %ax,0xf01f0318
f0104e85:	66 c7 05 1a 03 1f f0 	movw   $0x8,0xf01f031a
f0104e8c:	08 00 
f0104e8e:	c6 05 1c 03 1f f0 00 	movb   $0x0,0xf01f031c
f0104e95:	c6 05 1d 03 1f f0 8e 	movb   $0x8e,0xf01f031d
f0104e9c:	c1 e8 10             	shr    $0x10,%eax
f0104e9f:	66 a3 1e 03 1f f0    	mov    %ax,0xf01f031e

        SETGATE(idt[T_SYSCALL], 0, GD_KT, handler_syscall, 3);
f0104ea5:	b8 74 58 10 f0       	mov    $0xf0105874,%eax
f0104eaa:	66 a3 00 04 1f f0    	mov    %ax,0xf01f0400
f0104eb0:	66 c7 05 02 04 1f f0 	movw   $0x8,0xf01f0402
f0104eb7:	08 00 
f0104eb9:	c6 05 04 04 1f f0 00 	movb   $0x0,0xf01f0404
f0104ec0:	c6 05 05 04 1f f0 ee 	movb   $0xee,0xf01f0405
f0104ec7:	c1 e8 10             	shr    $0x10,%eax
f0104eca:	66 a3 06 04 1f f0    	mov    %ax,0xf01f0406
        SETGATE(idt[IRQ_OFFSET + IRQ_TIMER], 0, GD_KT, handler_timer, 0);
f0104ed0:	b8 7e 58 10 f0       	mov    $0xf010587e,%eax
f0104ed5:	66 a3 80 03 1f f0    	mov    %ax,0xf01f0380
f0104edb:	66 c7 05 82 03 1f f0 	movw   $0x8,0xf01f0382
f0104ee2:	08 00 
f0104ee4:	c6 05 84 03 1f f0 00 	movb   $0x0,0xf01f0384
f0104eeb:	c6 05 85 03 1f f0 8e 	movb   $0x8e,0xf01f0385
f0104ef2:	c1 e8 10             	shr    $0x10,%eax
f0104ef5:	66 a3 86 03 1f f0    	mov    %ax,0xf01f0386
        SETGATE(idt[IRQ_OFFSET + IRQ_KBD], 0, GD_KT, handler_kbd, 0);
f0104efb:	b8 88 58 10 f0       	mov    $0xf0105888,%eax
f0104f00:	66 a3 88 03 1f f0    	mov    %ax,0xf01f0388
f0104f06:	66 c7 05 8a 03 1f f0 	movw   $0x8,0xf01f038a
f0104f0d:	08 00 
f0104f0f:	c6 05 8c 03 1f f0 00 	movb   $0x0,0xf01f038c
f0104f16:	c6 05 8d 03 1f f0 8e 	movb   $0x8e,0xf01f038d
f0104f1d:	c1 e8 10             	shr    $0x10,%eax
f0104f20:	66 a3 8e 03 1f f0    	mov    %ax,0xf01f038e
        SETGATE(idt[IRQ_OFFSET + 2], 0, GD_KT, handler_irq2, 0);
f0104f26:	b8 92 58 10 f0       	mov    $0xf0105892,%eax
f0104f2b:	66 a3 90 03 1f f0    	mov    %ax,0xf01f0390
f0104f31:	66 c7 05 92 03 1f f0 	movw   $0x8,0xf01f0392
f0104f38:	08 00 
f0104f3a:	c6 05 94 03 1f f0 00 	movb   $0x0,0xf01f0394
f0104f41:	c6 05 95 03 1f f0 8e 	movb   $0x8e,0xf01f0395
f0104f48:	c1 e8 10             	shr    $0x10,%eax
f0104f4b:	66 a3 96 03 1f f0    	mov    %ax,0xf01f0396
        SETGATE(idt[IRQ_OFFSET + 3], 0, GD_KT, handler_irq3, 0);
f0104f51:	b8 9c 58 10 f0       	mov    $0xf010589c,%eax
f0104f56:	66 a3 98 03 1f f0    	mov    %ax,0xf01f0398
f0104f5c:	66 c7 05 9a 03 1f f0 	movw   $0x8,0xf01f039a
f0104f63:	08 00 
f0104f65:	c6 05 9c 03 1f f0 00 	movb   $0x0,0xf01f039c
f0104f6c:	c6 05 9d 03 1f f0 8e 	movb   $0x8e,0xf01f039d
f0104f73:	c1 e8 10             	shr    $0x10,%eax
f0104f76:	66 a3 9e 03 1f f0    	mov    %ax,0xf01f039e
        SETGATE(idt[IRQ_OFFSET + IRQ_SERIAL], 0, GD_KT, handler_serial, 0);
f0104f7c:	b8 a2 58 10 f0       	mov    $0xf01058a2,%eax
f0104f81:	66 a3 a0 03 1f f0    	mov    %ax,0xf01f03a0
f0104f87:	66 c7 05 a2 03 1f f0 	movw   $0x8,0xf01f03a2
f0104f8e:	08 00 
f0104f90:	c6 05 a4 03 1f f0 00 	movb   $0x0,0xf01f03a4
f0104f97:	c6 05 a5 03 1f f0 8e 	movb   $0x8e,0xf01f03a5
f0104f9e:	c1 e8 10             	shr    $0x10,%eax
f0104fa1:	66 a3 a6 03 1f f0    	mov    %ax,0xf01f03a6
        SETGATE(idt[IRQ_OFFSET + 5], 0, GD_KT, handler_irq5, 0);
f0104fa7:	b8 a8 58 10 f0       	mov    $0xf01058a8,%eax
f0104fac:	66 a3 a8 03 1f f0    	mov    %ax,0xf01f03a8
f0104fb2:	66 c7 05 aa 03 1f f0 	movw   $0x8,0xf01f03aa
f0104fb9:	08 00 
f0104fbb:	c6 05 ac 03 1f f0 00 	movb   $0x0,0xf01f03ac
f0104fc2:	c6 05 ad 03 1f f0 8e 	movb   $0x8e,0xf01f03ad
f0104fc9:	c1 e8 10             	shr    $0x10,%eax
f0104fcc:	66 a3 ae 03 1f f0    	mov    %ax,0xf01f03ae
        SETGATE(idt[IRQ_OFFSET + 6], 0, GD_KT, handler_irq6, 0);
f0104fd2:	b8 ae 58 10 f0       	mov    $0xf01058ae,%eax
f0104fd7:	66 a3 b0 03 1f f0    	mov    %ax,0xf01f03b0
f0104fdd:	66 c7 05 b2 03 1f f0 	movw   $0x8,0xf01f03b2
f0104fe4:	08 00 
f0104fe6:	c6 05 b4 03 1f f0 00 	movb   $0x0,0xf01f03b4
f0104fed:	c6 05 b5 03 1f f0 8e 	movb   $0x8e,0xf01f03b5
f0104ff4:	c1 e8 10             	shr    $0x10,%eax
f0104ff7:	66 a3 b6 03 1f f0    	mov    %ax,0xf01f03b6
        SETGATE(idt[IRQ_OFFSET + IRQ_SPURIOUS], 0, GD_KT, handler_spurious, 0);
f0104ffd:	b8 b4 58 10 f0       	mov    $0xf01058b4,%eax
f0105002:	66 a3 b8 03 1f f0    	mov    %ax,0xf01f03b8
f0105008:	66 c7 05 ba 03 1f f0 	movw   $0x8,0xf01f03ba
f010500f:	08 00 
f0105011:	c6 05 bc 03 1f f0 00 	movb   $0x0,0xf01f03bc
f0105018:	c6 05 bd 03 1f f0 8e 	movb   $0x8e,0xf01f03bd
f010501f:	c1 e8 10             	shr    $0x10,%eax
f0105022:	66 a3 be 03 1f f0    	mov    %ax,0xf01f03be
        SETGATE(idt[IRQ_OFFSET + 8], 0, GD_KT, handler_irq8, 0);
f0105028:	b8 ba 58 10 f0       	mov    $0xf01058ba,%eax
f010502d:	66 a3 c0 03 1f f0    	mov    %ax,0xf01f03c0
f0105033:	66 c7 05 c2 03 1f f0 	movw   $0x8,0xf01f03c2
f010503a:	08 00 
f010503c:	c6 05 c4 03 1f f0 00 	movb   $0x0,0xf01f03c4
f0105043:	c6 05 c5 03 1f f0 8e 	movb   $0x8e,0xf01f03c5
f010504a:	c1 e8 10             	shr    $0x10,%eax
f010504d:	66 a3 c6 03 1f f0    	mov    %ax,0xf01f03c6
        SETGATE(idt[IRQ_OFFSET + 9], 0, GD_KT, handler_irq9, 0);
f0105053:	b8 c0 58 10 f0       	mov    $0xf01058c0,%eax
f0105058:	66 a3 c8 03 1f f0    	mov    %ax,0xf01f03c8
f010505e:	66 c7 05 ca 03 1f f0 	movw   $0x8,0xf01f03ca
f0105065:	08 00 
f0105067:	c6 05 cc 03 1f f0 00 	movb   $0x0,0xf01f03cc
f010506e:	c6 05 cd 03 1f f0 8e 	movb   $0x8e,0xf01f03cd
f0105075:	c1 e8 10             	shr    $0x10,%eax
f0105078:	66 a3 ce 03 1f f0    	mov    %ax,0xf01f03ce
        SETGATE(idt[IRQ_OFFSET + 10], 0, GD_KT, handler_irq10, 0);
f010507e:	b8 c6 58 10 f0       	mov    $0xf01058c6,%eax
f0105083:	66 a3 d0 03 1f f0    	mov    %ax,0xf01f03d0
f0105089:	66 c7 05 d2 03 1f f0 	movw   $0x8,0xf01f03d2
f0105090:	08 00 
f0105092:	c6 05 d4 03 1f f0 00 	movb   $0x0,0xf01f03d4
f0105099:	c6 05 d5 03 1f f0 8e 	movb   $0x8e,0xf01f03d5
f01050a0:	c1 e8 10             	shr    $0x10,%eax
f01050a3:	66 a3 d6 03 1f f0    	mov    %ax,0xf01f03d6
        SETGATE(idt[IRQ_OFFSET + 11], 0, GD_KT, handler_irq11, 0);
f01050a9:	b8 cc 58 10 f0       	mov    $0xf01058cc,%eax
f01050ae:	66 a3 d8 03 1f f0    	mov    %ax,0xf01f03d8
f01050b4:	66 c7 05 da 03 1f f0 	movw   $0x8,0xf01f03da
f01050bb:	08 00 
f01050bd:	c6 05 dc 03 1f f0 00 	movb   $0x0,0xf01f03dc
f01050c4:	c6 05 dd 03 1f f0 8e 	movb   $0x8e,0xf01f03dd
f01050cb:	c1 e8 10             	shr    $0x10,%eax
f01050ce:	66 a3 de 03 1f f0    	mov    %ax,0xf01f03de
        SETGATE(idt[IRQ_OFFSET + 12], 0, GD_KT, handler_irq12, 0);
f01050d4:	b8 d2 58 10 f0       	mov    $0xf01058d2,%eax
f01050d9:	66 a3 e0 03 1f f0    	mov    %ax,0xf01f03e0
f01050df:	66 c7 05 e2 03 1f f0 	movw   $0x8,0xf01f03e2
f01050e6:	08 00 
f01050e8:	c6 05 e4 03 1f f0 00 	movb   $0x0,0xf01f03e4
f01050ef:	c6 05 e5 03 1f f0 8e 	movb   $0x8e,0xf01f03e5
f01050f6:	c1 e8 10             	shr    $0x10,%eax
f01050f9:	66 a3 e6 03 1f f0    	mov    %ax,0xf01f03e6
        SETGATE(idt[IRQ_OFFSET + 13], 0, GD_KT, handler_irq13, 0);
f01050ff:	b8 d8 58 10 f0       	mov    $0xf01058d8,%eax
f0105104:	66 a3 e8 03 1f f0    	mov    %ax,0xf01f03e8
f010510a:	66 c7 05 ea 03 1f f0 	movw   $0x8,0xf01f03ea
f0105111:	08 00 
f0105113:	c6 05 ec 03 1f f0 00 	movb   $0x0,0xf01f03ec
f010511a:	c6 05 ed 03 1f f0 8e 	movb   $0x8e,0xf01f03ed
f0105121:	c1 e8 10             	shr    $0x10,%eax
f0105124:	66 a3 ee 03 1f f0    	mov    %ax,0xf01f03ee
        SETGATE(idt[IRQ_OFFSET + IRQ_IDE], 0, GD_KT, handler_ide, 0);
f010512a:	b8 de 58 10 f0       	mov    $0xf01058de,%eax
f010512f:	66 a3 f0 03 1f f0    	mov    %ax,0xf01f03f0
f0105135:	66 c7 05 f2 03 1f f0 	movw   $0x8,0xf01f03f2
f010513c:	08 00 
f010513e:	c6 05 f4 03 1f f0 00 	movb   $0x0,0xf01f03f4
f0105145:	c6 05 f5 03 1f f0 8e 	movb   $0x8e,0xf01f03f5
f010514c:	c1 e8 10             	shr    $0x10,%eax
f010514f:	66 a3 f6 03 1f f0    	mov    %ax,0xf01f03f6
        SETGATE(idt[IRQ_OFFSET + 15], 0, GD_KT, handler_irq15, 0);
f0105155:	b8 e4 58 10 f0       	mov    $0xf01058e4,%eax
f010515a:	66 a3 f8 03 1f f0    	mov    %ax,0xf01f03f8
f0105160:	66 c7 05 fa 03 1f f0 	movw   $0x8,0xf01f03fa
f0105167:	08 00 
f0105169:	c6 05 fc 03 1f f0 00 	movb   $0x0,0xf01f03fc
f0105170:	c6 05 fd 03 1f f0 8e 	movb   $0x8e,0xf01f03fd
f0105177:	c1 e8 10             	shr    $0x10,%eax
f010517a:	66 a3 fe 03 1f f0    	mov    %ax,0xf01f03fe
        
	// Per-CPU setup 
	trap_init_percpu();
f0105180:	e8 6b f9 ff ff       	call   f0104af0 <trap_init_percpu>
}
f0105185:	c9                   	leave  
f0105186:	c3                   	ret    

f0105187 <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f0105187:	55                   	push   %ebp
f0105188:	89 e5                	mov    %esp,%ebp
f010518a:	53                   	push   %ebx
f010518b:	83 ec 14             	sub    $0x14,%esp
f010518e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0105191:	8b 03                	mov    (%ebx),%eax
f0105193:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105197:	c7 04 24 bf 92 10 f0 	movl   $0xf01092bf,(%esp)
f010519e:	e8 1c f9 ff ff       	call   f0104abf <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f01051a3:	8b 43 04             	mov    0x4(%ebx),%eax
f01051a6:	89 44 24 04          	mov    %eax,0x4(%esp)
f01051aa:	c7 04 24 ce 92 10 f0 	movl   $0xf01092ce,(%esp)
f01051b1:	e8 09 f9 ff ff       	call   f0104abf <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f01051b6:	8b 43 08             	mov    0x8(%ebx),%eax
f01051b9:	89 44 24 04          	mov    %eax,0x4(%esp)
f01051bd:	c7 04 24 dd 92 10 f0 	movl   $0xf01092dd,(%esp)
f01051c4:	e8 f6 f8 ff ff       	call   f0104abf <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f01051c9:	8b 43 0c             	mov    0xc(%ebx),%eax
f01051cc:	89 44 24 04          	mov    %eax,0x4(%esp)
f01051d0:	c7 04 24 ec 92 10 f0 	movl   $0xf01092ec,(%esp)
f01051d7:	e8 e3 f8 ff ff       	call   f0104abf <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f01051dc:	8b 43 10             	mov    0x10(%ebx),%eax
f01051df:	89 44 24 04          	mov    %eax,0x4(%esp)
f01051e3:	c7 04 24 fb 92 10 f0 	movl   $0xf01092fb,(%esp)
f01051ea:	e8 d0 f8 ff ff       	call   f0104abf <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f01051ef:	8b 43 14             	mov    0x14(%ebx),%eax
f01051f2:	89 44 24 04          	mov    %eax,0x4(%esp)
f01051f6:	c7 04 24 0a 93 10 f0 	movl   $0xf010930a,(%esp)
f01051fd:	e8 bd f8 ff ff       	call   f0104abf <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0105202:	8b 43 18             	mov    0x18(%ebx),%eax
f0105205:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105209:	c7 04 24 19 93 10 f0 	movl   $0xf0109319,(%esp)
f0105210:	e8 aa f8 ff ff       	call   f0104abf <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0105215:	8b 43 1c             	mov    0x1c(%ebx),%eax
f0105218:	89 44 24 04          	mov    %eax,0x4(%esp)
f010521c:	c7 04 24 28 93 10 f0 	movl   $0xf0109328,(%esp)
f0105223:	e8 97 f8 ff ff       	call   f0104abf <cprintf>
}
f0105228:	83 c4 14             	add    $0x14,%esp
f010522b:	5b                   	pop    %ebx
f010522c:	5d                   	pop    %ebp
f010522d:	c3                   	ret    

f010522e <print_trapframe>:
	lidt(&idt_pd);*/
}

void
print_trapframe(struct Trapframe *tf)
{
f010522e:	55                   	push   %ebp
f010522f:	89 e5                	mov    %esp,%ebp
f0105231:	56                   	push   %esi
f0105232:	53                   	push   %ebx
f0105233:	83 ec 10             	sub    $0x10,%esp
f0105236:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f0105239:	e8 90 26 00 00       	call   f01078ce <cpunum>
f010523e:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105242:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105246:	c7 04 24 37 93 10 f0 	movl   $0xf0109337,(%esp)
f010524d:	e8 6d f8 ff ff       	call   f0104abf <cprintf>
	print_regs(&tf->tf_regs);
f0105252:	89 1c 24             	mov    %ebx,(%esp)
f0105255:	e8 2d ff ff ff       	call   f0105187 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f010525a:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f010525e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105262:	c7 04 24 55 93 10 f0 	movl   $0xf0109355,(%esp)
f0105269:	e8 51 f8 ff ff       	call   f0104abf <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f010526e:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f0105272:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105276:	c7 04 24 68 93 10 f0 	movl   $0xf0109368,(%esp)
f010527d:	e8 3d f8 ff ff       	call   f0104abf <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0105282:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
f0105285:	83 f8 13             	cmp    $0x13,%eax
f0105288:	77 09                	ja     f0105293 <print_trapframe+0x65>
		return excnames[trapno];
f010528a:	8b 14 85 40 96 10 f0 	mov    -0xfef69c0(,%eax,4),%edx
f0105291:	eb 1c                	jmp    f01052af <print_trapframe+0x81>
	if (trapno == T_SYSCALL)
f0105293:	ba 7b 93 10 f0       	mov    $0xf010937b,%edx
f0105298:	83 f8 30             	cmp    $0x30,%eax
f010529b:	74 12                	je     f01052af <print_trapframe+0x81>
		return "System call";
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f010529d:	8d 48 e0             	lea    -0x20(%eax),%ecx
f01052a0:	ba 96 93 10 f0       	mov    $0xf0109396,%edx
f01052a5:	83 f9 0f             	cmp    $0xf,%ecx
f01052a8:	76 05                	jbe    f01052af <print_trapframe+0x81>
f01052aa:	ba 87 93 10 f0       	mov    $0xf0109387,%edx
{
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f01052af:	89 54 24 08          	mov    %edx,0x8(%esp)
f01052b3:	89 44 24 04          	mov    %eax,0x4(%esp)
f01052b7:	c7 04 24 a9 93 10 f0 	movl   $0xf01093a9,(%esp)
f01052be:	e8 fc f7 ff ff       	call   f0104abf <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f01052c3:	3b 1d 80 0a 1f f0    	cmp    0xf01f0a80,%ebx
f01052c9:	75 19                	jne    f01052e4 <print_trapframe+0xb6>
f01052cb:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f01052cf:	75 13                	jne    f01052e4 <print_trapframe+0xb6>

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f01052d1:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f01052d4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01052d8:	c7 04 24 bb 93 10 f0 	movl   $0xf01093bb,(%esp)
f01052df:	e8 db f7 ff ff       	call   f0104abf <cprintf>
	cprintf("  err  0x%08x", tf->tf_err);
f01052e4:	8b 43 2c             	mov    0x2c(%ebx),%eax
f01052e7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01052eb:	c7 04 24 ca 93 10 f0 	movl   $0xf01093ca,(%esp)
f01052f2:	e8 c8 f7 ff ff       	call   f0104abf <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f01052f7:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f01052fb:	75 47                	jne    f0105344 <print_trapframe+0x116>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f01052fd:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f0105300:	be e4 93 10 f0       	mov    $0xf01093e4,%esi
f0105305:	a8 01                	test   $0x1,%al
f0105307:	75 05                	jne    f010530e <print_trapframe+0xe0>
f0105309:	be d8 93 10 f0       	mov    $0xf01093d8,%esi
f010530e:	b9 f4 93 10 f0       	mov    $0xf01093f4,%ecx
f0105313:	a8 02                	test   $0x2,%al
f0105315:	75 05                	jne    f010531c <print_trapframe+0xee>
f0105317:	b9 ef 93 10 f0       	mov    $0xf01093ef,%ecx
f010531c:	ba fa 93 10 f0       	mov    $0xf01093fa,%edx
f0105321:	a8 04                	test   $0x4,%al
f0105323:	75 05                	jne    f010532a <print_trapframe+0xfc>
f0105325:	ba d1 94 10 f0       	mov    $0xf01094d1,%edx
f010532a:	89 74 24 0c          	mov    %esi,0xc(%esp)
f010532e:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0105332:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105336:	c7 04 24 ff 93 10 f0 	movl   $0xf01093ff,(%esp)
f010533d:	e8 7d f7 ff ff       	call   f0104abf <cprintf>
f0105342:	eb 0c                	jmp    f0105350 <print_trapframe+0x122>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f0105344:	c7 04 24 d9 84 10 f0 	movl   $0xf01084d9,(%esp)
f010534b:	e8 6f f7 ff ff       	call   f0104abf <cprintf>
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0105350:	8b 43 30             	mov    0x30(%ebx),%eax
f0105353:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105357:	c7 04 24 0e 94 10 f0 	movl   $0xf010940e,(%esp)
f010535e:	e8 5c f7 ff ff       	call   f0104abf <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0105363:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f0105367:	89 44 24 04          	mov    %eax,0x4(%esp)
f010536b:	c7 04 24 1d 94 10 f0 	movl   $0xf010941d,(%esp)
f0105372:	e8 48 f7 ff ff       	call   f0104abf <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0105377:	8b 43 38             	mov    0x38(%ebx),%eax
f010537a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010537e:	c7 04 24 30 94 10 f0 	movl   $0xf0109430,(%esp)
f0105385:	e8 35 f7 ff ff       	call   f0104abf <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f010538a:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f010538e:	74 27                	je     f01053b7 <print_trapframe+0x189>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f0105390:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0105393:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105397:	c7 04 24 3f 94 10 f0 	movl   $0xf010943f,(%esp)
f010539e:	e8 1c f7 ff ff       	call   f0104abf <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f01053a3:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f01053a7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01053ab:	c7 04 24 4e 94 10 f0 	movl   $0xf010944e,(%esp)
f01053b2:	e8 08 f7 ff ff       	call   f0104abf <cprintf>
	}
}
f01053b7:	83 c4 10             	add    $0x10,%esp
f01053ba:	5b                   	pop    %ebx
f01053bb:	5e                   	pop    %esi
f01053bc:	5d                   	pop    %ebp
f01053bd:	c3                   	ret    

f01053be <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f01053be:	55                   	push   %ebp
f01053bf:	89 e5                	mov    %esp,%ebp
f01053c1:	57                   	push   %edi
f01053c2:	56                   	push   %esi
f01053c3:	53                   	push   %ebx
f01053c4:	83 ec 2c             	sub    $0x2c,%esp
f01053c7:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01053ca:	0f 20 d0             	mov    %cr2,%eax
f01053cd:	89 45 e0             	mov    %eax,-0x20(%ebp)
	fault_va = rcr2();

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.
        if (tf->tf_cs == GD_KT){
f01053d0:	66 83 7b 34 08       	cmpw   $0x8,0x34(%ebx)
f01053d5:	75 1c                	jne    f01053f3 <page_fault_handler+0x35>
            panic("page fault in kernel");
f01053d7:	c7 44 24 08 61 94 10 	movl   $0xf0109461,0x8(%esp)
f01053de:	f0 
f01053df:	c7 44 24 04 81 01 00 	movl   $0x181,0x4(%esp)
f01053e6:	00 
f01053e7:	c7 04 24 76 94 10 f0 	movl   $0xf0109476,(%esp)
f01053ee:	e8 92 ac ff ff       	call   f0100085 <_panic>
	//   user_mem_assert() and env_run() are useful here.
	//   To change what the user environment runs, modify 'curenv->env_tf'
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.
        void* call = curenv->env_pgfault_upcall;
f01053f3:	e8 d6 24 00 00       	call   f01078ce <cpunum>
f01053f8:	6b c0 74             	imul   $0x74,%eax,%eax
f01053fb:	8b 80 28 10 1f f0    	mov    -0xfe0efd8(%eax),%eax
f0105401:	8b 40 68             	mov    0x68(%eax),%eax
f0105404:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(!call){
f0105407:	85 c0                	test   %eax,%eax
f0105409:	75 4e                	jne    f0105459 <page_fault_handler+0x9b>
	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f010540b:	8b 73 30             	mov    0x30(%ebx),%esi
		curenv->env_id, fault_va, tf->tf_eip);
f010540e:	e8 bb 24 00 00       	call   f01078ce <cpunum>

	// LAB 4: Your code here.
        void* call = curenv->env_pgfault_upcall;
        if(!call){
	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0105413:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0105417:	8b 55 e0             	mov    -0x20(%ebp),%edx
f010541a:	89 54 24 08          	mov    %edx,0x8(%esp)
f010541e:	be 20 10 1f f0       	mov    $0xf01f1020,%esi
f0105423:	6b c0 74             	imul   $0x74,%eax,%eax
f0105426:	8b 44 30 08          	mov    0x8(%eax,%esi,1),%eax
f010542a:	8b 40 48             	mov    0x48(%eax),%eax
f010542d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105431:	c7 04 24 1c 96 10 f0 	movl   $0xf010961c,(%esp)
f0105438:	e8 82 f6 ff ff       	call   f0104abf <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f010543d:	89 1c 24             	mov    %ebx,(%esp)
f0105440:	e8 e9 fd ff ff       	call   f010522e <print_trapframe>
	env_destroy(curenv);
f0105445:	e8 84 24 00 00       	call   f01078ce <cpunum>
f010544a:	6b c0 74             	imul   $0x74,%eax,%eax
f010544d:	8b 44 30 08          	mov    0x8(%eax,%esi,1),%eax
f0105451:	89 04 24             	mov    %eax,(%esp)
f0105454:	e8 1f f1 ff ff       	call   f0104578 <env_destroy>
        }
        struct UTrapframe* utf;
        if((tf->tf_esp >= UXSTACKTOP - PGSIZE) && (tf->tf_esp <= UXSTACKTOP - 1))
f0105459:	8b 43 3c             	mov    0x3c(%ebx),%eax
f010545c:	8d 90 00 10 40 11    	lea    0x11401000(%eax),%edx
f0105462:	be cc ff bf ee       	mov    $0xeebfffcc,%esi
f0105467:	81 fa ff 0f 00 00    	cmp    $0xfff,%edx
f010546d:	77 03                	ja     f0105472 <page_fault_handler+0xb4>
           utf = (struct UTrapframe*)(tf->tf_esp - sizeof(struct UTrapframe) - 4);
f010546f:	8d 70 c8             	lea    -0x38(%eax),%esi
        else
           utf = (struct UTrapframe*)(UXSTACKTOP - sizeof(struct UTrapframe));
        user_mem_assert(curenv,(void*)utf,sizeof(struct UTrapframe),PTE_P|PTE_U|PTE_W);
f0105472:	e8 57 24 00 00       	call   f01078ce <cpunum>
f0105477:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
f010547e:	00 
f010547f:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
f0105486:	00 
f0105487:	89 74 24 04          	mov    %esi,0x4(%esp)
f010548b:	bf 20 10 1f f0       	mov    $0xf01f1020,%edi
f0105490:	6b c0 74             	imul   $0x74,%eax,%eax
f0105493:	8b 44 38 08          	mov    0x8(%eax,%edi,1),%eax
f0105497:	89 04 24             	mov    %eax,(%esp)
f010549a:	e8 f8 cd ff ff       	call   f0102297 <user_mem_assert>
        utf->utf_fault_va = fault_va;
f010549f:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01054a2:	89 06                	mov    %eax,(%esi)
        utf->utf_err = tf->tf_err;
f01054a4:	8b 43 2c             	mov    0x2c(%ebx),%eax
f01054a7:	89 46 04             	mov    %eax,0x4(%esi)
        utf->utf_regs = tf->tf_regs;
f01054aa:	8b 03                	mov    (%ebx),%eax
f01054ac:	89 46 08             	mov    %eax,0x8(%esi)
f01054af:	8b 43 04             	mov    0x4(%ebx),%eax
f01054b2:	89 46 0c             	mov    %eax,0xc(%esi)
f01054b5:	8b 43 08             	mov    0x8(%ebx),%eax
f01054b8:	89 46 10             	mov    %eax,0x10(%esi)
f01054bb:	8b 43 0c             	mov    0xc(%ebx),%eax
f01054be:	89 46 14             	mov    %eax,0x14(%esi)
f01054c1:	8b 43 10             	mov    0x10(%ebx),%eax
f01054c4:	89 46 18             	mov    %eax,0x18(%esi)
f01054c7:	8b 43 14             	mov    0x14(%ebx),%eax
f01054ca:	89 46 1c             	mov    %eax,0x1c(%esi)
f01054cd:	8b 43 18             	mov    0x18(%ebx),%eax
f01054d0:	89 46 20             	mov    %eax,0x20(%esi)
f01054d3:	8b 43 1c             	mov    0x1c(%ebx),%eax
f01054d6:	89 46 24             	mov    %eax,0x24(%esi)
        utf->utf_eip = tf->tf_eip;
f01054d9:	8b 43 30             	mov    0x30(%ebx),%eax
f01054dc:	89 46 28             	mov    %eax,0x28(%esi)
        utf->utf_eflags = tf->tf_eflags;
f01054df:	8b 43 38             	mov    0x38(%ebx),%eax
f01054e2:	89 46 2c             	mov    %eax,0x2c(%esi)
        utf->utf_esp = tf->tf_esp;
f01054e5:	8b 43 3c             	mov    0x3c(%ebx),%eax
f01054e8:	89 46 30             	mov    %eax,0x30(%esi)
        curenv->env_tf.tf_eip = (uint32_t)call;
f01054eb:	e8 de 23 00 00       	call   f01078ce <cpunum>
f01054f0:	6b c0 74             	imul   $0x74,%eax,%eax
f01054f3:	8b 44 38 08          	mov    0x8(%eax,%edi,1),%eax
f01054f7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01054fa:	89 50 30             	mov    %edx,0x30(%eax)
        curenv->env_tf.tf_esp = (uint32_t)utf;
f01054fd:	e8 cc 23 00 00       	call   f01078ce <cpunum>
f0105502:	6b c0 74             	imul   $0x74,%eax,%eax
f0105505:	8b 44 38 08          	mov    0x8(%eax,%edi,1),%eax
f0105509:	89 70 3c             	mov    %esi,0x3c(%eax)
        env_run(curenv);
f010550c:	e8 bd 23 00 00       	call   f01078ce <cpunum>
f0105511:	6b c0 74             	imul   $0x74,%eax,%eax
f0105514:	8b 44 38 08          	mov    0x8(%eax,%edi,1),%eax
f0105518:	89 04 24             	mov    %eax,(%esp)
f010551b:	e8 ca ed ff ff       	call   f01042ea <env_run>

f0105520 <syscall_helper>:
		env_run(curenv);
	else
		sched_yield();
}

uint32_t syscall_helper(struct Trapframe *tf){
f0105520:	55                   	push   %ebp
f0105521:	89 e5                	mov    %esp,%ebp
f0105523:	83 ec 38             	sub    $0x38,%esp
f0105526:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0105529:	89 75 f8             	mov    %esi,-0x8(%ebp)
f010552c:	89 7d fc             	mov    %edi,-0x4(%ebp)
f010552f:	8b 5d 08             	mov    0x8(%ebp),%ebx
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f0105532:	c7 04 24 80 43 12 f0 	movl   $0xf0124380,(%esp)
f0105539:	e8 57 27 00 00       	call   f0107c95 <spin_lock>
        uint32_t ret = 0;     
        lock_kernel();
        curenv->env_tf = *tf; 
f010553e:	e8 8b 23 00 00       	call   f01078ce <cpunum>
f0105543:	6b c0 74             	imul   $0x74,%eax,%eax
f0105546:	8b 80 28 10 1f f0    	mov    -0xfe0efd8(%eax),%eax
f010554c:	b9 11 00 00 00       	mov    $0x11,%ecx
f0105551:	89 c7                	mov    %eax,%edi
f0105553:	89 de                	mov    %ebx,%esi
f0105555:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
        //tf = &curenv->env_tf;
        ret = syscall(tf->tf_regs.reg_eax,tf->tf_regs.reg_edx,tf->tf_regs.reg_ecx,tf->tf_regs.reg_ebx,tf->tf_regs.reg_edi,0);
f0105557:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
f010555e:	00 
f010555f:	8b 03                	mov    (%ebx),%eax
f0105561:	89 44 24 10          	mov    %eax,0x10(%esp)
f0105565:	8b 43 10             	mov    0x10(%ebx),%eax
f0105568:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010556c:	8b 43 18             	mov    0x18(%ebx),%eax
f010556f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105573:	8b 43 14             	mov    0x14(%ebx),%eax
f0105576:	89 44 24 04          	mov    %eax,0x4(%esp)
f010557a:	8b 43 1c             	mov    0x1c(%ebx),%eax
f010557d:	89 04 24             	mov    %eax,(%esp)
f0105580:	e8 0b 05 00 00       	call   f0105a90 <syscall>
f0105585:	89 c3                	mov    %eax,%ebx
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0105587:	c7 04 24 80 43 12 f0 	movl   $0xf0124380,(%esp)
f010558e:	e8 e9 25 00 00       	call   f0107b7c <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0105593:	f3 90                	pause  
        //tf->tf_regs.reg_eax = ret;
        unlock_kernel();
        return ret; 
}
f0105595:	89 d8                	mov    %ebx,%eax
f0105597:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f010559a:	8b 75 f8             	mov    -0x8(%ebp),%esi
f010559d:	8b 7d fc             	mov    -0x4(%ebp),%edi
f01055a0:	89 ec                	mov    %ebp,%esp
f01055a2:	5d                   	pop    %ebp
f01055a3:	c3                   	ret    

f01055a4 <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f01055a4:	55                   	push   %ebp
f01055a5:	89 e5                	mov    %esp,%ebp
f01055a7:	83 ec 38             	sub    $0x38,%esp
f01055aa:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f01055ad:	89 75 f8             	mov    %esi,-0x8(%ebp)
f01055b0:	89 7d fc             	mov    %edi,-0x4(%ebp)
f01055b3:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f01055b6:	fc                   	cld    

	// Halt the CPU if some other CPU has called panic()
	extern char *panicstr;
	if (panicstr)
f01055b7:	83 3d a0 0e 1f f0 00 	cmpl   $0x0,0xf01f0ea0
f01055be:	74 01                	je     f01055c1 <trap+0x1d>
		asm volatile("hlt");
f01055c0:	f4                   	hlt    

static __inline uint32_t
read_eflags(void)
{
        uint32_t eflags;
        __asm __volatile("pushfl; popl %0" : "=r" (eflags));
f01055c1:	9c                   	pushf  
f01055c2:	58                   	pop    %eax

	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f01055c3:	f6 c4 02             	test   $0x2,%ah
f01055c6:	74 24                	je     f01055ec <trap+0x48>
f01055c8:	c7 44 24 0c 82 94 10 	movl   $0xf0109482,0xc(%esp)
f01055cf:	f0 
f01055d0:	c7 44 24 08 4c 88 10 	movl   $0xf010884c,0x8(%esp)
f01055d7:	f0 
f01055d8:	c7 44 24 04 40 01 00 	movl   $0x140,0x4(%esp)
f01055df:	00 
f01055e0:	c7 04 24 76 94 10 f0 	movl   $0xf0109476,(%esp)
f01055e7:	e8 99 aa ff ff       	call   f0100085 <_panic>

	if ((tf->tf_cs & 3) == 3) {
f01055ec:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f01055f0:	83 e0 03             	and    $0x3,%eax
f01055f3:	83 f8 03             	cmp    $0x3,%eax
f01055f6:	0f 85 a9 00 00 00    	jne    f01056a5 <trap+0x101>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f01055fc:	c7 04 24 80 43 12 f0 	movl   $0xf0124380,(%esp)
f0105603:	e8 8d 26 00 00       	call   f0107c95 <spin_lock>
		// Trapped from user mode.
		// Acquire the big kernel lock before doing any
		// serious kernel work.
		// LAB 4: Your code here.
                lock_kernel();
		assert(curenv);
f0105608:	e8 c1 22 00 00       	call   f01078ce <cpunum>
f010560d:	6b c0 74             	imul   $0x74,%eax,%eax
f0105610:	83 b8 28 10 1f f0 00 	cmpl   $0x0,-0xfe0efd8(%eax)
f0105617:	75 24                	jne    f010563d <trap+0x99>
f0105619:	c7 44 24 0c 9b 94 10 	movl   $0xf010949b,0xc(%esp)
f0105620:	f0 
f0105621:	c7 44 24 08 4c 88 10 	movl   $0xf010884c,0x8(%esp)
f0105628:	f0 
f0105629:	c7 44 24 04 48 01 00 	movl   $0x148,0x4(%esp)
f0105630:	00 
f0105631:	c7 04 24 76 94 10 f0 	movl   $0xf0109476,(%esp)
f0105638:	e8 48 aa ff ff       	call   f0100085 <_panic>

		// Garbage collect if current enviroment is a zombie
		if (curenv->env_status == ENV_DYING) {
f010563d:	e8 8c 22 00 00       	call   f01078ce <cpunum>
f0105642:	6b c0 74             	imul   $0x74,%eax,%eax
f0105645:	8b 80 28 10 1f f0    	mov    -0xfe0efd8(%eax),%eax
f010564b:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f010564f:	75 2e                	jne    f010567f <trap+0xdb>
			env_free(curenv);
f0105651:	e8 78 22 00 00       	call   f01078ce <cpunum>
f0105656:	be 20 10 1f f0       	mov    $0xf01f1020,%esi
f010565b:	6b c0 74             	imul   $0x74,%eax,%eax
f010565e:	8b 44 30 08          	mov    0x8(%eax,%esi,1),%eax
f0105662:	89 04 24             	mov    %eax,(%esp)
f0105665:	e8 3c ed ff ff       	call   f01043a6 <env_free>
			curenv = NULL;
f010566a:	e8 5f 22 00 00       	call   f01078ce <cpunum>
f010566f:	6b c0 74             	imul   $0x74,%eax,%eax
f0105672:	c7 44 30 08 00 00 00 	movl   $0x0,0x8(%eax,%esi,1)
f0105679:	00 
			sched_yield();
f010567a:	e8 b1 02 00 00       	call   f0105930 <sched_yield>
		}

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f010567f:	e8 4a 22 00 00       	call   f01078ce <cpunum>
f0105684:	bb 20 10 1f f0       	mov    $0xf01f1020,%ebx
f0105689:	6b c0 74             	imul   $0x74,%eax,%eax
f010568c:	8b 44 18 08          	mov    0x8(%eax,%ebx,1),%eax
f0105690:	b9 11 00 00 00       	mov    $0x11,%ecx
f0105695:	89 c7                	mov    %eax,%edi
f0105697:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f0105699:	e8 30 22 00 00       	call   f01078ce <cpunum>
f010569e:	6b c0 74             	imul   $0x74,%eax,%eax
f01056a1:	8b 74 18 08          	mov    0x8(%eax,%ebx,1),%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f01056a5:	89 35 80 0a 1f f0    	mov    %esi,0xf01f0a80
	// LAB 3: Your code here.

	// Handle spurious interrupts
	// The hardware sometimes raises these because of noise on the
	// IRQ line or other reasons. We don't care.
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f01056ab:	8b 46 28             	mov    0x28(%esi),%eax
f01056ae:	83 f8 27             	cmp    $0x27,%eax
f01056b1:	75 19                	jne    f01056cc <trap+0x128>
		cprintf("Spurious interrupt on irq 7\n");
f01056b3:	c7 04 24 a2 94 10 f0 	movl   $0xf01094a2,(%esp)
f01056ba:	e8 00 f4 ff ff       	call   f0104abf <cprintf>
		print_trapframe(tf);
f01056bf:	89 34 24             	mov    %esi,(%esp)
f01056c2:	e8 67 fb ff ff       	call   f010522e <print_trapframe>
f01056c7:	e9 c0 00 00 00       	jmp    f010578c <trap+0x1e8>

	// Handle clock interrupts. Don't forget to acknowledge the
	// interrupt using lapic_eoi() before calling the scheduler!
	// LAB 4: Your code here.

        if(tf->tf_trapno == T_PGFLT)
f01056cc:	83 f8 0e             	cmp    $0xe,%eax
f01056cf:	90                   	nop
f01056d0:	75 0b                	jne    f01056dd <trap+0x139>
            page_fault_handler(tf);
f01056d2:	89 34 24             	mov    %esi,(%esp)
f01056d5:	8d 76 00             	lea    0x0(%esi),%esi
f01056d8:	e8 e1 fc ff ff       	call   f01053be <page_fault_handler>
	// Unexpected trap: The user process or the kernel has a bug.
        if(tf->tf_trapno == T_BRKPT)
f01056dd:	83 7e 28 03          	cmpl   $0x3,0x28(%esi)
f01056e1:	75 08                	jne    f01056eb <trap+0x147>
            monitor(tf);
f01056e3:	89 34 24             	mov    %esi,(%esp)
f01056e6:	e8 9e b4 ff ff       	call   f0100b89 <monitor>
        if(tf->tf_trapno == T_DEBUG){
f01056eb:	83 7e 28 01          	cmpl   $0x1,0x28(%esi)
f01056ef:	90                   	nop
f01056f0:	75 0f                	jne    f0105701 <trap+0x15d>
            tf->tf_eflags = tf->tf_eflags & (~0x100);
f01056f2:	81 66 38 ff fe ff ff 	andl   $0xfffffeff,0x38(%esi)
            monitor(tf);
f01056f9:	89 34 24             	mov    %esi,(%esp)
f01056fc:	e8 88 b4 ff ff       	call   f0100b89 <monitor>
        }
        if(tf->tf_trapno == IRQ_OFFSET + IRQ_TIMER){
f0105701:	8b 46 28             	mov    0x28(%esi),%eax
f0105704:	83 f8 20             	cmp    $0x20,%eax
f0105707:	75 0a                	jne    f0105713 <trap+0x16f>
                lapic_eoi();
f0105709:	e8 f9 22 00 00       	call   f0107a07 <lapic_eoi>
		sched_yield();
f010570e:	e8 1d 02 00 00       	call   f0105930 <sched_yield>
	}
        if(tf->tf_trapno == T_SYSCALL){
f0105713:	83 f8 30             	cmp    $0x30,%eax
f0105716:	75 33                	jne    f010574b <trap+0x1a7>
		tf->tf_regs.reg_eax = syscall(tf->tf_regs.reg_eax,tf->tf_regs.reg_edx,tf->tf_regs.reg_ecx,tf->tf_regs.reg_ebx,tf->tf_regs.reg_edi,0);
f0105718:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
f010571f:	00 
f0105720:	8b 06                	mov    (%esi),%eax
f0105722:	89 44 24 10          	mov    %eax,0x10(%esp)
f0105726:	8b 46 10             	mov    0x10(%esi),%eax
f0105729:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010572d:	8b 46 18             	mov    0x18(%esi),%eax
f0105730:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105734:	8b 46 14             	mov    0x14(%esi),%eax
f0105737:	89 44 24 04          	mov    %eax,0x4(%esp)
f010573b:	8b 46 1c             	mov    0x1c(%esi),%eax
f010573e:	89 04 24             	mov    %eax,(%esp)
f0105741:	e8 4a 03 00 00       	call   f0105a90 <syscall>
f0105746:	89 46 1c             	mov    %eax,0x1c(%esi)
f0105749:	eb 41                	jmp    f010578c <trap+0x1e8>
                return;
	}
	print_trapframe(tf);
f010574b:	89 34 24             	mov    %esi,(%esp)
f010574e:	e8 db fa ff ff       	call   f010522e <print_trapframe>
	if (tf->tf_cs == GD_KT)
f0105753:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f0105758:	75 1c                	jne    f0105776 <trap+0x1d2>
		panic("unhandled trap in kernel");
f010575a:	c7 44 24 08 bf 94 10 	movl   $0xf01094bf,0x8(%esp)
f0105761:	f0 
f0105762:	c7 44 24 04 2a 01 00 	movl   $0x12a,0x4(%esp)
f0105769:	00 
f010576a:	c7 04 24 76 94 10 f0 	movl   $0xf0109476,(%esp)
f0105771:	e8 0f a9 ff ff       	call   f0100085 <_panic>
	else {
		env_destroy(curenv);
f0105776:	e8 53 21 00 00       	call   f01078ce <cpunum>
f010577b:	6b c0 74             	imul   $0x74,%eax,%eax
f010577e:	8b 80 28 10 1f f0    	mov    -0xfe0efd8(%eax),%eax
f0105784:	89 04 24             	mov    %eax,(%esp)
f0105787:	e8 ec ed ff ff       	call   f0104578 <env_destroy>
	trap_dispatch(tf);

	// If we made it to this point, then no other environment was
	// scheduled, so we should return to the current environment
	// if doing so makes sense.
	if (curenv && curenv->env_status == ENV_RUNNING)
f010578c:	e8 3d 21 00 00       	call   f01078ce <cpunum>
f0105791:	6b c0 74             	imul   $0x74,%eax,%eax
f0105794:	83 b8 28 10 1f f0 00 	cmpl   $0x0,-0xfe0efd8(%eax)
f010579b:	74 2a                	je     f01057c7 <trap+0x223>
f010579d:	e8 2c 21 00 00       	call   f01078ce <cpunum>
f01057a2:	6b c0 74             	imul   $0x74,%eax,%eax
f01057a5:	8b 80 28 10 1f f0    	mov    -0xfe0efd8(%eax),%eax
f01057ab:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f01057af:	75 16                	jne    f01057c7 <trap+0x223>
		env_run(curenv);
f01057b1:	e8 18 21 00 00       	call   f01078ce <cpunum>
f01057b6:	6b c0 74             	imul   $0x74,%eax,%eax
f01057b9:	8b 80 28 10 1f f0    	mov    -0xfe0efd8(%eax),%eax
f01057bf:	89 04 24             	mov    %eax,(%esp)
f01057c2:	e8 23 eb ff ff       	call   f01042ea <env_run>
	else
		sched_yield();
f01057c7:	e8 64 01 00 00       	call   f0105930 <sched_yield>

f01057cc <handler_divide>:
.text

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */
TRAPHANDLER_NOEC(handler_divide, T_DIVIDE)
f01057cc:	6a 00                	push   $0x0
f01057ce:	6a 00                	push   $0x0
f01057d0:	e9 49 01 00 00       	jmp    f010591e <_alltraps>
f01057d5:	90                   	nop

f01057d6 <handler_debug>:
TRAPHANDLER_NOEC(handler_debug, T_DEBUG)
f01057d6:	6a 00                	push   $0x0
f01057d8:	6a 01                	push   $0x1
f01057da:	e9 3f 01 00 00       	jmp    f010591e <_alltraps>
f01057df:	90                   	nop

f01057e0 <handler_nmi>:
TRAPHANDLER_NOEC(handler_nmi, T_NMI)
f01057e0:	6a 00                	push   $0x0
f01057e2:	6a 02                	push   $0x2
f01057e4:	e9 35 01 00 00       	jmp    f010591e <_alltraps>
f01057e9:	90                   	nop

f01057ea <handler_brkpt>:
TRAPHANDLER_NOEC(handler_brkpt, T_BRKPT)
f01057ea:	6a 00                	push   $0x0
f01057ec:	6a 03                	push   $0x3
f01057ee:	e9 2b 01 00 00       	jmp    f010591e <_alltraps>
f01057f3:	90                   	nop

f01057f4 <handler_oflow>:
TRAPHANDLER_NOEC(handler_oflow, T_OFLOW)
f01057f4:	6a 00                	push   $0x0
f01057f6:	6a 04                	push   $0x4
f01057f8:	e9 21 01 00 00       	jmp    f010591e <_alltraps>
f01057fd:	90                   	nop

f01057fe <handler_bound>:
TRAPHANDLER_NOEC(handler_bound, T_BOUND)
f01057fe:	6a 00                	push   $0x0
f0105800:	6a 05                	push   $0x5
f0105802:	e9 17 01 00 00       	jmp    f010591e <_alltraps>
f0105807:	90                   	nop

f0105808 <handler_illop>:
TRAPHANDLER_NOEC(handler_illop, T_ILLOP)
f0105808:	6a 00                	push   $0x0
f010580a:	6a 06                	push   $0x6
f010580c:	e9 0d 01 00 00       	jmp    f010591e <_alltraps>
f0105811:	90                   	nop

f0105812 <handler_device>:
TRAPHANDLER_NOEC(handler_device, T_DEVICE)
f0105812:	6a 00                	push   $0x0
f0105814:	6a 07                	push   $0x7
f0105816:	e9 03 01 00 00       	jmp    f010591e <_alltraps>
f010581b:	90                   	nop

f010581c <handler_dblflt>:
TRAPHANDLER(handler_dblflt, T_DBLFLT)
f010581c:	6a 08                	push   $0x8
f010581e:	e9 fb 00 00 00       	jmp    f010591e <_alltraps>
f0105823:	90                   	nop

f0105824 <handler_tss>:
TRAPHANDLER(handler_tss, T_TSS)
f0105824:	6a 0a                	push   $0xa
f0105826:	e9 f3 00 00 00       	jmp    f010591e <_alltraps>
f010582b:	90                   	nop

f010582c <handler_segnp>:
TRAPHANDLER(handler_segnp, T_SEGNP)
f010582c:	6a 0b                	push   $0xb
f010582e:	e9 eb 00 00 00       	jmp    f010591e <_alltraps>
f0105833:	90                   	nop

f0105834 <handler_stack>:
TRAPHANDLER(handler_stack, T_STACK)
f0105834:	6a 0c                	push   $0xc
f0105836:	e9 e3 00 00 00       	jmp    f010591e <_alltraps>
f010583b:	90                   	nop

f010583c <handler_gpflt>:
TRAPHANDLER(handler_gpflt, T_GPFLT)
f010583c:	6a 0d                	push   $0xd
f010583e:	e9 db 00 00 00       	jmp    f010591e <_alltraps>
f0105843:	90                   	nop

f0105844 <handler_pgflt>:
TRAPHANDLER(handler_pgflt, T_PGFLT)
f0105844:	6a 0e                	push   $0xe
f0105846:	e9 d3 00 00 00       	jmp    f010591e <_alltraps>
f010584b:	90                   	nop

f010584c <handler_fperr>:
TRAPHANDLER_NOEC(handler_fperr, T_FPERR)
f010584c:	6a 00                	push   $0x0
f010584e:	6a 10                	push   $0x10
f0105850:	e9 c9 00 00 00       	jmp    f010591e <_alltraps>
f0105855:	90                   	nop

f0105856 <handler_align>:
TRAPHANDLER_NOEC(handler_align, T_ALIGN)
f0105856:	6a 00                	push   $0x0
f0105858:	6a 11                	push   $0x11
f010585a:	e9 bf 00 00 00       	jmp    f010591e <_alltraps>
f010585f:	90                   	nop

f0105860 <handler_mchk>:
TRAPHANDLER_NOEC(handler_mchk, T_MCHK)
f0105860:	6a 00                	push   $0x0
f0105862:	6a 12                	push   $0x12
f0105864:	e9 b5 00 00 00       	jmp    f010591e <_alltraps>
f0105869:	90                   	nop

f010586a <handler_simderr>:
TRAPHANDLER_NOEC(handler_simderr, T_SIMDERR)
f010586a:	6a 00                	push   $0x0
f010586c:	6a 13                	push   $0x13
f010586e:	e9 ab 00 00 00       	jmp    f010591e <_alltraps>
f0105873:	90                   	nop

f0105874 <handler_syscall>:

TRAPHANDLER_NOEC(handler_syscall, T_SYSCALL);	
f0105874:	6a 00                	push   $0x0
f0105876:	6a 30                	push   $0x30
f0105878:	e9 a1 00 00 00       	jmp    f010591e <_alltraps>
f010587d:	90                   	nop

f010587e <handler_timer>:

TRAPHANDLER_NOEC(handler_timer,IRQ_OFFSET + IRQ_TIMER);
f010587e:	6a 00                	push   $0x0
f0105880:	6a 20                	push   $0x20
f0105882:	e9 97 00 00 00       	jmp    f010591e <_alltraps>
f0105887:	90                   	nop

f0105888 <handler_kbd>:
TRAPHANDLER_NOEC(handler_kbd,IRQ_OFFSET + IRQ_KBD);
f0105888:	6a 00                	push   $0x0
f010588a:	6a 21                	push   $0x21
f010588c:	e9 8d 00 00 00       	jmp    f010591e <_alltraps>
f0105891:	90                   	nop

f0105892 <handler_irq2>:
TRAPHANDLER_NOEC(handler_irq2,IRQ_OFFSET + 2);
f0105892:	6a 00                	push   $0x0
f0105894:	6a 22                	push   $0x22
f0105896:	e9 83 00 00 00       	jmp    f010591e <_alltraps>
f010589b:	90                   	nop

f010589c <handler_irq3>:
TRAPHANDLER_NOEC(handler_irq3,IRQ_OFFSET + 3);
f010589c:	6a 00                	push   $0x0
f010589e:	6a 23                	push   $0x23
f01058a0:	eb 7c                	jmp    f010591e <_alltraps>

f01058a2 <handler_serial>:
TRAPHANDLER_NOEC(handler_serial,IRQ_OFFSET + IRQ_SERIAL);
f01058a2:	6a 00                	push   $0x0
f01058a4:	6a 24                	push   $0x24
f01058a6:	eb 76                	jmp    f010591e <_alltraps>

f01058a8 <handler_irq5>:
TRAPHANDLER_NOEC(handler_irq5,IRQ_OFFSET + 5);
f01058a8:	6a 00                	push   $0x0
f01058aa:	6a 25                	push   $0x25
f01058ac:	eb 70                	jmp    f010591e <_alltraps>

f01058ae <handler_irq6>:
TRAPHANDLER_NOEC(handler_irq6,IRQ_OFFSET + 6);
f01058ae:	6a 00                	push   $0x0
f01058b0:	6a 26                	push   $0x26
f01058b2:	eb 6a                	jmp    f010591e <_alltraps>

f01058b4 <handler_spurious>:
TRAPHANDLER_NOEC(handler_spurious,IRQ_OFFSET + IRQ_SPURIOUS);
f01058b4:	6a 00                	push   $0x0
f01058b6:	6a 27                	push   $0x27
f01058b8:	eb 64                	jmp    f010591e <_alltraps>

f01058ba <handler_irq8>:
TRAPHANDLER_NOEC(handler_irq8,IRQ_OFFSET + 8);
f01058ba:	6a 00                	push   $0x0
f01058bc:	6a 28                	push   $0x28
f01058be:	eb 5e                	jmp    f010591e <_alltraps>

f01058c0 <handler_irq9>:
TRAPHANDLER_NOEC(handler_irq9,IRQ_OFFSET + 9);
f01058c0:	6a 00                	push   $0x0
f01058c2:	6a 29                	push   $0x29
f01058c4:	eb 58                	jmp    f010591e <_alltraps>

f01058c6 <handler_irq10>:
TRAPHANDLER_NOEC(handler_irq10,IRQ_OFFSET + 10);
f01058c6:	6a 00                	push   $0x0
f01058c8:	6a 2a                	push   $0x2a
f01058ca:	eb 52                	jmp    f010591e <_alltraps>

f01058cc <handler_irq11>:
TRAPHANDLER_NOEC(handler_irq11,IRQ_OFFSET + 11);
f01058cc:	6a 00                	push   $0x0
f01058ce:	6a 2b                	push   $0x2b
f01058d0:	eb 4c                	jmp    f010591e <_alltraps>

f01058d2 <handler_irq12>:
TRAPHANDLER_NOEC(handler_irq12,IRQ_OFFSET + 12);
f01058d2:	6a 00                	push   $0x0
f01058d4:	6a 2c                	push   $0x2c
f01058d6:	eb 46                	jmp    f010591e <_alltraps>

f01058d8 <handler_irq13>:
TRAPHANDLER_NOEC(handler_irq13,IRQ_OFFSET + 13);
f01058d8:	6a 00                	push   $0x0
f01058da:	6a 2d                	push   $0x2d
f01058dc:	eb 40                	jmp    f010591e <_alltraps>

f01058de <handler_ide>:
TRAPHANDLER_NOEC(handler_ide,IRQ_OFFSET + IRQ_IDE);
f01058de:	6a 00                	push   $0x0
f01058e0:	6a 2e                	push   $0x2e
f01058e2:	eb 3a                	jmp    f010591e <_alltraps>

f01058e4 <handler_irq15>:
TRAPHANDLER_NOEC(handler_irq15,IRQ_OFFSET + 15);
f01058e4:	6a 00                	push   $0x0
f01058e6:	6a 2f                	push   $0x2f
f01058e8:	eb 34                	jmp    f010591e <_alltraps>

f01058ea <sysenter_handler>:
.align 2;
sysenter_handler:
/*
 * Lab 3: Your code here for system call handling
 */
    pushl $GD_UD | 3
f01058ea:	6a 23                	push   $0x23
    pushl %ebp
f01058ec:	55                   	push   %ebp
    pushfl
f01058ed:	9c                   	pushf  
    pushl $GD_UT | 3
f01058ee:	6a 1b                	push   $0x1b
    pushl %esi
f01058f0:	56                   	push   %esi
    pushl $0
f01058f1:	6a 00                	push   $0x0
    pushl $T_SYSCALL
f01058f3:	6a 30                	push   $0x30
    pushl %ds
f01058f5:	1e                   	push   %ds
    pushl %es
f01058f6:	06                   	push   %es
    pushal
f01058f7:	60                   	pusha  
    movl $GD_KD, %eax
f01058f8:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax,%ds
f01058fd:	8e d8                	mov    %eax,%ds
    movw %ax,%es
f01058ff:	8e c0                	mov    %eax,%es
    pushl %esp
f0105901:	54                   	push   %esp
    call syscall_helper
f0105902:	e8 19 fc ff ff       	call   f0105520 <syscall_helper>
    popl %esp
f0105907:	5c                   	pop    %esp
    //popal
    popl %edi
f0105908:	5f                   	pop    %edi
    popl %esi
f0105909:	5e                   	pop    %esi
    popl %ebp
f010590a:	5d                   	pop    %ebp
    popl %ebx
f010590b:	5b                   	pop    %ebx
    popl %ebx
f010590c:	5b                   	pop    %ebx
    popl %edx
f010590d:	5a                   	pop    %edx
    popl %ecx
f010590e:	59                   	pop    %ecx
    addl $0x4,%esp
f010590f:	83 c4 04             	add    $0x4,%esp

    popl %es
f0105912:	07                   	pop    %es
    popl %ds
f0105913:	1f                   	pop    %ds
    addl $0x8,%esp
f0105914:	83 c4 08             	add    $0x8,%esp
    movl %esi,%edx
f0105917:	89 f2                	mov    %esi,%edx
    movl %ebp,%ecx
f0105919:	89 e9                	mov    %ebp,%ecx
    sti  //open interrupt
f010591b:	fb                   	sti    
    sysexit
f010591c:	0f 35                	sysexit 

f010591e <_alltraps>:

/*
 * Lab 3: Your code here for _alltraps
 */
_alltraps:
    pushl %ds
f010591e:	1e                   	push   %ds
    pushl %es
f010591f:	06                   	push   %es
    pushal
f0105920:	60                   	pusha  
    movl $GD_KD, %eax
f0105921:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax,%ds
f0105926:	8e d8                	mov    %eax,%ds
    movw %ax,%es
f0105928:	8e c0                	mov    %eax,%es
    pushl %esp
f010592a:	54                   	push   %esp
    call trap
f010592b:	e8 74 fc ff ff       	call   f01055a4 <trap>

f0105930 <sched_yield>:


// Choose a user environment to run and run it.
void
sched_yield(void)
{
f0105930:	55                   	push   %ebp
f0105931:	89 e5                	mov    %esp,%ebp
f0105933:	53                   	push   %ebx
f0105934:	83 ec 14             	sub    $0x14,%esp
	// LAB 4: Your code here.
        uint32_t env_id = 0;
        uint32_t next_id = 0;
        uint32_t high_prior_id = 0;
        uint32_t max_prior = 0;
        if(curenv)
f0105937:	e8 92 1f 00 00       	call   f01078ce <cpunum>
f010593c:	6b d0 74             	imul   $0x74,%eax,%edx
f010593f:	b8 00 00 00 00       	mov    $0x0,%eax
f0105944:	83 ba 28 10 1f f0 00 	cmpl   $0x0,-0xfe0efd8(%edx)
f010594b:	74 16                	je     f0105963 <sched_yield+0x33>
            env_id = ENVX(curenv->env_id);   
f010594d:	e8 7c 1f 00 00       	call   f01078ce <cpunum>
f0105952:	6b c0 74             	imul   $0x74,%eax,%eax
f0105955:	8b 80 28 10 1f f0    	mov    -0xfe0efd8(%eax),%eax
f010595b:	8b 40 48             	mov    0x48(%eax),%eax
f010595e:	25 ff 03 00 00       	and    $0x3ff,%eax
        next_id = env_id;
        for(i = 0;i < NENV ;i++){
           next_id = (next_id + 1) % NENV;
           if(envs[next_id].env_type != ENV_TYPE_IDLE &&
f0105963:	8b 1d 5c 02 1f f0    	mov    0xf01f025c,%ebx
f0105969:	ba 00 00 00 00       	mov    $0x0,%edx
        uint32_t max_prior = 0;
        if(curenv)
            env_id = ENVX(curenv->env_id);   
        next_id = env_id;
        for(i = 0;i < NENV ;i++){
           next_id = (next_id + 1) % NENV;
f010596e:	83 c0 01             	add    $0x1,%eax
f0105971:	25 ff 03 00 00       	and    $0x3ff,%eax
           if(envs[next_id].env_type != ENV_TYPE_IDLE &&
f0105976:	89 c1                	mov    %eax,%ecx
f0105978:	c1 e1 07             	shl    $0x7,%ecx
f010597b:	8d 0c 81             	lea    (%ecx,%eax,4),%ecx
f010597e:	8d 0c 0b             	lea    (%ebx,%ecx,1),%ecx
f0105981:	83 79 50 01          	cmpl   $0x1,0x50(%ecx)
f0105985:	74 0e                	je     f0105995 <sched_yield+0x65>
               envs[next_id].env_status == ENV_RUNNABLE){
f0105987:	83 79 54 02          	cmpl   $0x2,0x54(%ecx)
f010598b:	75 08                	jne    f0105995 <sched_yield+0x65>
                //cprintf("next_id:%d\n",next_id);
                env_run(&envs[next_id]);
f010598d:	89 0c 24             	mov    %ecx,(%esp)
f0105990:	e8 55 e9 ff ff       	call   f01042ea <env_run>
        uint32_t high_prior_id = 0;
        uint32_t max_prior = 0;
        if(curenv)
            env_id = ENVX(curenv->env_id);   
        next_id = env_id;
        for(i = 0;i < NENV ;i++){
f0105995:	83 c2 01             	add    $0x1,%edx
f0105998:	81 fa 00 04 00 00    	cmp    $0x400,%edx
f010599e:	75 ce                	jne    f010596e <sched_yield+0x3e>
                //cprintf("next_id:%d\n",next_id);
                env_run(&envs[next_id]);
                break;
           }
        }
        if(curenv && curenv->env_type != ENV_TYPE_IDLE && curenv->env_status == ENV_RUNNING)
f01059a0:	e8 29 1f 00 00       	call   f01078ce <cpunum>
f01059a5:	6b c0 74             	imul   $0x74,%eax,%eax
f01059a8:	83 b8 28 10 1f f0 00 	cmpl   $0x0,-0xfe0efd8(%eax)
f01059af:	74 14                	je     f01059c5 <sched_yield+0x95>
f01059b1:	e8 18 1f 00 00       	call   f01078ce <cpunum>
f01059b6:	6b c0 74             	imul   $0x74,%eax,%eax
f01059b9:	8b 80 28 10 1f f0    	mov    -0xfe0efd8(%eax),%eax
f01059bf:	83 78 50 01          	cmpl   $0x1,0x50(%eax)
f01059c3:	75 0f                	jne    f01059d4 <sched_yield+0xa4>
            env_run(curenv);*/
	// For debugging and testing purposes, if there are no
	// runnable environments other than the idle environments,
	// drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
		if (envs[i].env_type != ENV_TYPE_IDLE &&
f01059c5:	8b 1d 5c 02 1f f0    	mov    0xf01f025c,%ebx
f01059cb:	89 d8                	mov    %ebx,%eax
f01059cd:	ba 00 00 00 00       	mov    $0x0,%edx
f01059d2:	eb 2a                	jmp    f01059fe <sched_yield+0xce>
                //cprintf("next_id:%d\n",next_id);
                env_run(&envs[next_id]);
                break;
           }
        }
        if(curenv && curenv->env_type != ENV_TYPE_IDLE && curenv->env_status == ENV_RUNNING)
f01059d4:	e8 f5 1e 00 00       	call   f01078ce <cpunum>
f01059d9:	6b c0 74             	imul   $0x74,%eax,%eax
f01059dc:	8b 80 28 10 1f f0    	mov    -0xfe0efd8(%eax),%eax
f01059e2:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f01059e6:	75 dd                	jne    f01059c5 <sched_yield+0x95>
            env_run(curenv);
f01059e8:	e8 e1 1e 00 00       	call   f01078ce <cpunum>
f01059ed:	6b c0 74             	imul   $0x74,%eax,%eax
f01059f0:	8b 80 28 10 1f f0    	mov    -0xfe0efd8(%eax),%eax
f01059f6:	89 04 24             	mov    %eax,(%esp)
f01059f9:	e8 ec e8 ff ff       	call   f01042ea <env_run>
            env_run(curenv);*/
	// For debugging and testing purposes, if there are no
	// runnable environments other than the idle environments,
	// drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
		if (envs[i].env_type != ENV_TYPE_IDLE &&
f01059fe:	83 78 50 01          	cmpl   $0x1,0x50(%eax)
f0105a02:	74 0b                	je     f0105a0f <sched_yield+0xdf>
f0105a04:	8b 48 54             	mov    0x54(%eax),%ecx
f0105a07:	83 e9 02             	sub    $0x2,%ecx
f0105a0a:	83 f9 01             	cmp    $0x1,%ecx
f0105a0d:	76 12                	jbe    f0105a21 <sched_yield+0xf1>
        if(curenv && curenv->env_type != ENV_TYPE_IDLE && curenv->env_status == ENV_RUNNING)
            env_run(curenv);*/
	// For debugging and testing purposes, if there are no
	// runnable environments other than the idle environments,
	// drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0105a0f:	83 c2 01             	add    $0x1,%edx
f0105a12:	05 84 00 00 00       	add    $0x84,%eax
f0105a17:	81 fa 00 04 00 00    	cmp    $0x400,%edx
f0105a1d:	75 df                	jne    f01059fe <sched_yield+0xce>
f0105a1f:	eb 08                	jmp    f0105a29 <sched_yield+0xf9>
		if (envs[i].env_type != ENV_TYPE_IDLE &&
		    (envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING))
			break;
	}
	if (i == NENV) {
f0105a21:	81 fa 00 04 00 00    	cmp    $0x400,%edx
f0105a27:	75 1a                	jne    f0105a43 <sched_yield+0x113>
		cprintf("No more runnable environments!\n");
f0105a29:	c7 04 24 90 96 10 f0 	movl   $0xf0109690,(%esp)
f0105a30:	e8 8a f0 ff ff       	call   f0104abf <cprintf>
		while (1)
			monitor(NULL);
f0105a35:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0105a3c:	e8 48 b1 ff ff       	call   f0100b89 <monitor>
f0105a41:	eb f2                	jmp    f0105a35 <sched_yield+0x105>
	}

	// Run this CPU's idle environment when nothing else is runnable.
	idle = &envs[cpunum()];
f0105a43:	e8 86 1e 00 00       	call   f01078ce <cpunum>
f0105a48:	69 c0 84 00 00 00    	imul   $0x84,%eax,%eax
f0105a4e:	01 c3                	add    %eax,%ebx
	if (!(idle->env_status == ENV_RUNNABLE || idle->env_status == ENV_RUNNING))
f0105a50:	8b 43 54             	mov    0x54(%ebx),%eax
f0105a53:	83 e8 02             	sub    $0x2,%eax
f0105a56:	83 f8 01             	cmp    $0x1,%eax
f0105a59:	76 25                	jbe    f0105a80 <sched_yield+0x150>
		panic("CPU %d: No idle environment!", cpunum());
f0105a5b:	e8 6e 1e 00 00       	call   f01078ce <cpunum>
f0105a60:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105a64:	c7 44 24 08 b0 96 10 	movl   $0xf01096b0,0x8(%esp)
f0105a6b:	f0 
f0105a6c:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f0105a73:	00 
f0105a74:	c7 04 24 cd 96 10 f0 	movl   $0xf01096cd,(%esp)
f0105a7b:	e8 05 a6 ff ff       	call   f0100085 <_panic>
	env_run(idle);
f0105a80:	89 1c 24             	mov    %ebx,(%esp)
f0105a83:	e8 62 e8 ff ff       	call   f01042ea <env_run>
	...

f0105a90 <syscall>:
        return 0;
}
// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0105a90:	55                   	push   %ebp
f0105a91:	89 e5                	mov    %esp,%ebp
f0105a93:	57                   	push   %edi
f0105a94:	56                   	push   %esi
f0105a95:	53                   	push   %ebx
f0105a96:	83 ec 4c             	sub    $0x4c,%esp
f0105a99:	8b 55 08             	mov    0x8(%ebp),%edx
f0105a9c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.
        int32_t ret = 0;
        switch(syscallno){
f0105a9f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0105aa4:	83 fa 11             	cmp    $0x11,%edx
f0105aa7:	0f 87 f3 08 00 00    	ja     f01063a0 <syscall+0x910>
f0105aad:	ff 24 95 24 97 10 f0 	jmp    *-0xfef68dc(,%edx,4)
sys_cputs(const char *s, size_t len)
{
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.       
	// LAB 3: Your code here.
        user_mem_assert(curenv,s,len,PTE_U);
f0105ab4:	e8 15 1e 00 00       	call   f01078ce <cpunum>
f0105ab9:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f0105ac0:	00 
f0105ac1:	8b 55 10             	mov    0x10(%ebp),%edx
f0105ac4:	89 54 24 08          	mov    %edx,0x8(%esp)
f0105ac8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105acc:	6b c0 74             	imul   $0x74,%eax,%eax
f0105acf:	8b 80 28 10 1f f0    	mov    -0xfe0efd8(%eax),%eax
f0105ad5:	89 04 24             	mov    %eax,(%esp)
f0105ad8:	e8 ba c7 ff ff       	call   f0102297 <user_mem_assert>
	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f0105add:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0105ae1:	8b 5d 10             	mov    0x10(%ebp),%ebx
f0105ae4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105ae8:	c7 04 24 da 96 10 f0 	movl   $0xf01096da,(%esp)
f0105aef:	e8 cb ef ff ff       	call   f0104abf <cprintf>
f0105af4:	b8 00 00 00 00       	mov    $0x0,%eax
f0105af9:	e9 a2 08 00 00       	jmp    f01063a0 <syscall+0x910>
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f0105afe:	e8 cc a9 ff ff       	call   f01004cf <cons_getc>
        case SYS_cputs:
          sys_cputs((const char*)a1,(size_t)a2);
          break;
        case SYS_cgetc:
          ret = sys_cgetc();
          break;
f0105b03:	e9 98 08 00 00       	jmp    f01063a0 <syscall+0x910>

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f0105b08:	90                   	nop
f0105b09:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0105b10:	e8 b9 1d 00 00       	call   f01078ce <cpunum>
f0105b15:	6b c0 74             	imul   $0x74,%eax,%eax
f0105b18:	8b 80 28 10 1f f0    	mov    -0xfe0efd8(%eax),%eax
f0105b1e:	8b 40 48             	mov    0x48(%eax),%eax
        case SYS_cgetc:
          ret = sys_cgetc();
          break;
        case SYS_getenvid:
          ret = sys_getenvid();
          break;
f0105b21:	e9 7a 08 00 00       	jmp    f01063a0 <syscall+0x910>
{
        
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f0105b26:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0105b2d:	00 
f0105b2e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0105b31:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105b35:	89 1c 24             	mov    %ebx,(%esp)
f0105b38:	e8 bb e6 ff ff       	call   f01041f8 <envid2env>
f0105b3d:	85 c0                	test   %eax,%eax
f0105b3f:	0f 88 5b 08 00 00    	js     f01063a0 <syscall+0x910>
		return r;
	if (e == curenv)
f0105b45:	e8 84 1d 00 00       	call   f01078ce <cpunum>
f0105b4a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0105b4d:	6b c0 74             	imul   $0x74,%eax,%eax
f0105b50:	39 90 28 10 1f f0    	cmp    %edx,-0xfe0efd8(%eax)
f0105b56:	75 23                	jne    f0105b7b <syscall+0xeb>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f0105b58:	e8 71 1d 00 00       	call   f01078ce <cpunum>
f0105b5d:	6b c0 74             	imul   $0x74,%eax,%eax
f0105b60:	8b 80 28 10 1f f0    	mov    -0xfe0efd8(%eax),%eax
f0105b66:	8b 40 48             	mov    0x48(%eax),%eax
f0105b69:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105b6d:	c7 04 24 df 96 10 f0 	movl   $0xf01096df,(%esp)
f0105b74:	e8 46 ef ff ff       	call   f0104abf <cprintf>
f0105b79:	eb 28                	jmp    f0105ba3 <syscall+0x113>
	else
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f0105b7b:	8b 5a 48             	mov    0x48(%edx),%ebx
f0105b7e:	e8 4b 1d 00 00       	call   f01078ce <cpunum>
f0105b83:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0105b87:	6b c0 74             	imul   $0x74,%eax,%eax
f0105b8a:	8b 80 28 10 1f f0    	mov    -0xfe0efd8(%eax),%eax
f0105b90:	8b 40 48             	mov    0x48(%eax),%eax
f0105b93:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105b97:	c7 04 24 fa 96 10 f0 	movl   $0xf01096fa,(%esp)
f0105b9e:	e8 1c ef ff ff       	call   f0104abf <cprintf>
	env_destroy(e);
f0105ba3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105ba6:	89 04 24             	mov    %eax,(%esp)
f0105ba9:	e8 ca e9 ff ff       	call   f0104578 <env_destroy>
f0105bae:	b8 00 00 00 00       	mov    $0x0,%eax
f0105bb3:	e9 e8 07 00 00       	jmp    f01063a0 <syscall+0x910>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0105bb8:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f0105bbe:	77 20                	ja     f0105be0 <syscall+0x150>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0105bc0:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0105bc4:	c7 44 24 08 5c 80 10 	movl   $0xf010805c,0x8(%esp)
f0105bcb:	f0 
f0105bcc:	c7 44 24 04 47 00 00 	movl   $0x47,0x4(%esp)
f0105bd3:	00 
f0105bd4:	c7 04 24 12 97 10 f0 	movl   $0xf0109712,(%esp)
f0105bdb:	e8 a5 a4 ff ff       	call   f0100085 <_panic>
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105be0:	81 c3 00 00 00 10    	add    $0x10000000,%ebx
f0105be6:	c1 eb 0c             	shr    $0xc,%ebx
f0105be9:	3b 1d a8 0e 1f f0    	cmp    0xf01f0ea8,%ebx
f0105bef:	72 1c                	jb     f0105c0d <syscall+0x17d>
		panic("pa2page called with invalid pa");
f0105bf1:	c7 44 24 08 70 8c 10 	movl   $0xf0108c70,0x8(%esp)
f0105bf8:	f0 
f0105bf9:	c7 44 24 04 4f 00 00 	movl   $0x4f,0x4(%esp)
f0105c00:	00 
f0105c01:	c7 04 24 32 88 10 f0 	movl   $0xf0108832,(%esp)
f0105c08:	e8 78 a4 ff ff       	call   f0100085 <_panic>
	return &pages[PGNUM(pa)];
f0105c0d:	c1 e3 03             	shl    $0x3,%ebx
static int
sys_map_kernel_page(void* kpage, void* va)
{
	int r;
	struct Page* p = pa2page(PADDR(kpage));
	if(p ==NULL)
f0105c10:	b8 03 00 00 00       	mov    $0x3,%eax
f0105c15:	03 1d b0 0e 1f f0    	add    0xf01f0eb0,%ebx
f0105c1b:	0f 84 7f 07 00 00    	je     f01063a0 <syscall+0x910>
		return E_INVAL;
	r = page_insert(curenv->env_pgdir, p, va, PTE_U | PTE_W);
f0105c21:	e8 a8 1c 00 00       	call   f01078ce <cpunum>
f0105c26:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f0105c2d:	00 
f0105c2e:	8b 55 10             	mov    0x10(%ebp),%edx
f0105c31:	89 54 24 08          	mov    %edx,0x8(%esp)
f0105c35:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105c39:	6b c0 74             	imul   $0x74,%eax,%eax
f0105c3c:	8b 80 28 10 1f f0    	mov    -0xfe0efd8(%eax),%eax
f0105c42:	8b 40 64             	mov    0x64(%eax),%eax
f0105c45:	89 04 24             	mov    %eax,(%esp)
f0105c48:	e8 6e c7 ff ff       	call   f01023bb <page_insert>
f0105c4d:	e9 4e 07 00 00       	jmp    f01063a0 <syscall+0x910>

static int
sys_sbrk(uint32_t inc)
{
	// LAB3: your code sbrk here...
        uintptr_t begin = ROUNDUP(curenv->env_break,PGSIZE);
f0105c52:	e8 77 1c 00 00       	call   f01078ce <cpunum>
f0105c57:	6b c0 74             	imul   $0x74,%eax,%eax
f0105c5a:	8b 80 28 10 1f f0    	mov    -0xfe0efd8(%eax),%eax
f0105c60:	8b 70 60             	mov    0x60(%eax),%esi
f0105c63:	81 c6 ff 0f 00 00    	add    $0xfff,%esi
f0105c69:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
        uintptr_t end = ROUNDUP(begin + inc,PGSIZE);
f0105c6f:	8d 84 1e ff 0f 00 00 	lea    0xfff(%esi,%ebx,1),%eax
f0105c76:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0105c7b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        while(begin < end){
f0105c7e:	39 c6                	cmp    %eax,%esi
f0105c80:	73 65                	jae    f0105ce7 <syscall+0x257>
           struct Page* page = page_alloc(0);
           if(page == NULL)
               panic("page alloc failed\n");
           page_insert(curenv->env_pgdir,page,(void*)begin,PTE_U|PTE_W|PTE_P);
f0105c82:	bb 20 10 1f f0       	mov    $0xf01f1020,%ebx
{
	// LAB3: your code sbrk here...
        uintptr_t begin = ROUNDUP(curenv->env_break,PGSIZE);
        uintptr_t end = ROUNDUP(begin + inc,PGSIZE);
        while(begin < end){
           struct Page* page = page_alloc(0);
f0105c87:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0105c8e:	e8 14 c4 ff ff       	call   f01020a7 <page_alloc>
f0105c93:	89 c7                	mov    %eax,%edi
           if(page == NULL)
f0105c95:	85 c0                	test   %eax,%eax
f0105c97:	75 1c                	jne    f0105cb5 <syscall+0x225>
               panic("page alloc failed\n");
f0105c99:	c7 44 24 08 7a 92 10 	movl   $0xf010927a,0x8(%esp)
f0105ca0:	f0 
f0105ca1:	c7 44 24 04 b4 01 00 	movl   $0x1b4,0x4(%esp)
f0105ca8:	00 
f0105ca9:	c7 04 24 12 97 10 f0 	movl   $0xf0109712,(%esp)
f0105cb0:	e8 d0 a3 ff ff       	call   f0100085 <_panic>
           page_insert(curenv->env_pgdir,page,(void*)begin,PTE_U|PTE_W|PTE_P);
f0105cb5:	e8 14 1c 00 00       	call   f01078ce <cpunum>
f0105cba:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
f0105cc1:	00 
f0105cc2:	89 74 24 08          	mov    %esi,0x8(%esp)
f0105cc6:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105cca:	6b c0 74             	imul   $0x74,%eax,%eax
f0105ccd:	8b 44 18 08          	mov    0x8(%eax,%ebx,1),%eax
f0105cd1:	8b 40 64             	mov    0x64(%eax),%eax
f0105cd4:	89 04 24             	mov    %eax,(%esp)
f0105cd7:	e8 df c6 ff ff       	call   f01023bb <page_insert>
           begin += PGSIZE;
f0105cdc:	81 c6 00 10 00 00    	add    $0x1000,%esi
sys_sbrk(uint32_t inc)
{
	// LAB3: your code sbrk here...
        uintptr_t begin = ROUNDUP(curenv->env_break,PGSIZE);
        uintptr_t end = ROUNDUP(begin + inc,PGSIZE);
        while(begin < end){
f0105ce2:	39 75 d4             	cmp    %esi,-0x2c(%ebp)
f0105ce5:	77 a0                	ja     f0105c87 <syscall+0x1f7>
           if(page == NULL)
               panic("page alloc failed\n");
           page_insert(curenv->env_pgdir,page,(void*)begin,PTE_U|PTE_W|PTE_P);
           begin += PGSIZE;
        }
        curenv->env_break = end;
f0105ce7:	e8 e2 1b 00 00       	call   f01078ce <cpunum>
f0105cec:	bb 20 10 1f f0       	mov    $0xf01f1020,%ebx
f0105cf1:	6b c0 74             	imul   $0x74,%eax,%eax
f0105cf4:	8b 44 18 08          	mov    0x8(%eax,%ebx,1),%eax
f0105cf8:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0105cfb:	89 50 60             	mov    %edx,0x60(%eax)
	return curenv->env_break;
f0105cfe:	e8 cb 1b 00 00       	call   f01078ce <cpunum>
f0105d03:	6b c0 74             	imul   $0x74,%eax,%eax
f0105d06:	8b 44 18 08          	mov    0x8(%eax,%ebx,1),%eax
f0105d0a:	8b 40 60             	mov    0x60(%eax),%eax
        case SYS_map_kernel_page:
          ret = sys_map_kernel_page((void*)a1,(void*)a2);
          break;
        case SYS_sbrk:
          ret = sys_sbrk(a1);
          break;
f0105d0d:	e9 8e 06 00 00       	jmp    f01063a0 <syscall+0x910>

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
	sched_yield();
f0105d12:	e8 19 fc ff ff       	call   f0105930 <sched_yield>
	// from the current environment -- but tweaked so sys_exofork
	// will appear to return 0.
        struct Env* forkEnv;
        uint32_t ret;
        //panic("1111111\n");
        ret = env_alloc(&forkEnv,curenv->env_id);
f0105d17:	e8 b2 1b 00 00       	call   f01078ce <cpunum>
f0105d1c:	bb 20 10 1f f0       	mov    $0xf01f1020,%ebx
f0105d21:	6b c0 74             	imul   $0x74,%eax,%eax
f0105d24:	8b 44 18 08          	mov    0x8(%eax,%ebx,1),%eax
f0105d28:	8b 40 48             	mov    0x48(%eax),%eax
f0105d2b:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105d2f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0105d32:	89 04 24             	mov    %eax,(%esp)
f0105d35:	e8 9c e8 ff ff       	call   f01045d6 <env_alloc>
        if(ret < 0){
           return ret;
        }
        forkEnv->env_status = ENV_NOT_RUNNABLE;
f0105d3a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105d3d:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)

        forkEnv->env_tf = curenv->env_tf;
f0105d44:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105d47:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0105d4a:	e8 7f 1b 00 00       	call   f01078ce <cpunum>
f0105d4f:	6b c0 74             	imul   $0x74,%eax,%eax
f0105d52:	8b 74 18 08          	mov    0x8(%eax,%ebx,1),%esi
f0105d56:	b9 11 00 00 00       	mov    $0x11,%ecx
f0105d5b:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0105d5e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
        forkEnv->env_tf.tf_regs.reg_eax = 0;
f0105d60:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105d63:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
        //cprintf("env_id:%d\n",forkEnv->env_id);
        return forkEnv->env_id;
f0105d6a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105d6d:	8b 40 48             	mov    0x48(%eax),%eax
        case SYS_yield:
          sys_yield();
          break;
        case SYS_exofork:
          ret = sys_exofork();
          break;
f0105d70:	e9 2b 06 00 00       	jmp    f01063a0 <syscall+0x910>
	// check whether the current environment has permission to set
	// envid's status.

	// LAB 4: Your code here.
        struct Env* env;
        uint32_t ret = envid2env(envid,&env,1);
f0105d75:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0105d7c:	00 
f0105d7d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0105d80:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105d84:	89 1c 24             	mov    %ebx,(%esp)
f0105d87:	e8 6c e4 ff ff       	call   f01041f8 <envid2env>
        if(ret < 0)
            return -E_BAD_ENV;
        env->env_status = status;
f0105d8c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105d8f:	8b 55 10             	mov    0x10(%ebp),%edx
f0105d92:	89 50 54             	mov    %edx,0x54(%eax)
f0105d95:	b8 00 00 00 00       	mov    $0x0,%eax
        case SYS_exofork:
          ret = sys_exofork();
          break;
        case SYS_env_set_status:
          ret = sys_env_set_status((envid_t)a1,(int)a2);
          break;
f0105d9a:	e9 01 06 00 00       	jmp    f01063a0 <syscall+0x910>
//		or the caller doesn't have permission to change envid.
static int
sys_env_set_pgfault_upcall(envid_t envid, void *func)
{
        struct Env* env;
        uint32_t ret = envid2env(envid,&env,1);
f0105d9f:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0105da6:	00 
f0105da7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0105daa:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105dae:	89 1c 24             	mov    %ebx,(%esp)
f0105db1:	e8 42 e4 ff ff       	call   f01041f8 <envid2env>
        if(ret < 0)
            return -E_BAD_ENV;
        env->env_pgfault_upcall = func;
f0105db6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105db9:	8b 5d 10             	mov    0x10(%ebp),%ebx
f0105dbc:	89 58 68             	mov    %ebx,0x68(%eax)
f0105dbf:	b8 00 00 00 00       	mov    $0x0,%eax
        case SYS_env_set_status:
          ret = sys_env_set_status((envid_t)a1,(int)a2);
          break;
        case SYS_env_set_pgfault_upcall:
          ret = sys_env_set_pgfault_upcall((envid_t)a1, (void *)a2);
          break;
f0105dc4:	e9 d7 05 00 00       	jmp    f01063a0 <syscall+0x910>
	//   Most of the new code you write should be to check the
	//   parameters for correctness.
	//   If page_insert() fails, remember to free the page you
	//   allocated!
        uint32_t vaddr = (uint32_t)va;
        if(vaddr >= UTOP || (vaddr%PGSIZE))
f0105dc9:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0105dd0:	77 70                	ja     f0105e42 <syscall+0x3b2>
f0105dd2:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f0105dd9:	75 67                	jne    f0105e42 <syscall+0x3b2>
              return -E_INVAL;
        if(!(perm & PTE_P) || !(perm & PTE_U))
f0105ddb:	8b 45 14             	mov    0x14(%ebp),%eax
f0105dde:	83 e0 05             	and    $0x5,%eax
f0105de1:	83 f8 05             	cmp    $0x5,%eax
f0105de4:	75 5c                	jne    f0105e42 <syscall+0x3b2>
              return -E_INVAL;
        struct Env* env;
        struct Page* page;
        uint32_t ret = envid2env(envid,&env,1);
f0105de6:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0105ded:	00 
f0105dee:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0105df1:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105df5:	89 1c 24             	mov    %ebx,(%esp)
f0105df8:	e8 fb e3 ff ff       	call   f01041f8 <envid2env>
        if(ret < 0)
            return -E_BAD_ENV;
        page = page_alloc(ALLOC_ZERO);
f0105dfd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0105e04:	e8 9e c2 ff ff       	call   f01020a7 <page_alloc>
f0105e09:	89 c2                	mov    %eax,%edx
        if(!page)
f0105e0b:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0105e10:	85 d2                	test   %edx,%edx
f0105e12:	0f 84 88 05 00 00    	je     f01063a0 <syscall+0x910>
            return -E_NO_MEM;
        ret = page_insert(env->env_pgdir,page,va,perm);
f0105e18:	8b 45 14             	mov    0x14(%ebp),%eax
f0105e1b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105e1f:	8b 5d 10             	mov    0x10(%ebp),%ebx
f0105e22:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0105e26:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105e2a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105e2d:	8b 40 64             	mov    0x64(%eax),%eax
f0105e30:	89 04 24             	mov    %eax,(%esp)
f0105e33:	e8 83 c5 ff ff       	call   f01023bb <page_insert>
f0105e38:	b8 00 00 00 00       	mov    $0x0,%eax
f0105e3d:	e9 5e 05 00 00       	jmp    f01063a0 <syscall+0x910>
f0105e42:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0105e47:	e9 54 05 00 00       	jmp    f01063a0 <syscall+0x910>
	//   parameters for correctness.
	//   Use the third argument to page_lookup() to
	//   check the current permissions on the page.
        uint32_t srcvaddr = (uint32_t)srcva;
        uint32_t dstvaddr = (uint32_t)dstva;
        if(srcvaddr >= UTOP || (srcvaddr%PGSIZE) || dstvaddr >= UTOP || (dstvaddr%PGSIZE))
f0105e4c:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0105e53:	0f 87 c3 00 00 00    	ja     f0105f1c <syscall+0x48c>
          break;
        case SYS_page_alloc:
          ret = sys_page_alloc((envid_t)a1, (void *)a2, (int)a3);
          break;
        case SYS_page_map:{
          uint32_t dstva = (uint32_t)a4 & 0xFFFFF000;
f0105e59:	8b 75 18             	mov    0x18(%ebp),%esi
f0105e5c:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	//   parameters for correctness.
	//   Use the third argument to page_lookup() to
	//   check the current permissions on the page.
        uint32_t srcvaddr = (uint32_t)srcva;
        uint32_t dstvaddr = (uint32_t)dstva;
        if(srcvaddr >= UTOP || (srcvaddr%PGSIZE) || dstvaddr >= UTOP || (dstvaddr%PGSIZE))
f0105e62:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f0105e69:	0f 85 ad 00 00 00    	jne    f0105f1c <syscall+0x48c>
f0105e6f:	81 fe ff ff bf ee    	cmp    $0xeebfffff,%esi
f0105e75:	0f 87 a1 00 00 00    	ja     f0105f1c <syscall+0x48c>
        case SYS_page_alloc:
          ret = sys_page_alloc((envid_t)a1, (void *)a2, (int)a3);
          break;
        case SYS_page_map:{
          uint32_t dstva = (uint32_t)a4 & 0xFFFFF000;
          uint32_t perm = (uint32_t)a4 & 0xFFF;
f0105e7b:	8b 7d 18             	mov    0x18(%ebp),%edi
f0105e7e:	81 e7 ff 0f 00 00    	and    $0xfff,%edi
	//   check the current permissions on the page.
        uint32_t srcvaddr = (uint32_t)srcva;
        uint32_t dstvaddr = (uint32_t)dstva;
        if(srcvaddr >= UTOP || (srcvaddr%PGSIZE) || dstvaddr >= UTOP || (dstvaddr%PGSIZE))
              return -E_INVAL;
        if(!(perm & PTE_P) || !(perm & PTE_U))
f0105e84:	8b 45 18             	mov    0x18(%ebp),%eax
f0105e87:	83 e0 05             	and    $0x5,%eax
f0105e8a:	83 f8 05             	cmp    $0x5,%eax
f0105e8d:	0f 85 89 00 00 00    	jne    f0105f1c <syscall+0x48c>
              return -E_INVAL;
        struct Env* srcenv;
        struct Env* dstenv;
        uint32_t ret;
        ret = envid2env(srcenvid,&srcenv,1);
f0105e93:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0105e9a:	00 
f0105e9b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0105e9e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105ea2:	89 1c 24             	mov    %ebx,(%esp)
f0105ea5:	e8 4e e3 ff ff       	call   f01041f8 <envid2env>
        if(ret < 0)
           return -E_BAD_ENV;
        ret = envid2env(dstenvid,&dstenv,1);
f0105eaa:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0105eb1:	00 
f0105eb2:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0105eb5:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105eb9:	8b 45 14             	mov    0x14(%ebp),%eax
f0105ebc:	89 04 24             	mov    %eax,(%esp)
f0105ebf:	e8 34 e3 ff ff       	call   f01041f8 <envid2env>
        if(ret < 0)
           return -E_BAD_ENV;
        struct Page* page;
        pte_t* pte;
        page = page_lookup(srcenv->env_pgdir,srcva,&pte);
f0105ec4:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0105ec7:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105ecb:	8b 55 10             	mov    0x10(%ebp),%edx
f0105ece:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105ed2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105ed5:	8b 40 64             	mov    0x64(%eax),%eax
f0105ed8:	89 04 24             	mov    %eax,(%esp)
f0105edb:	e8 0f c4 ff ff       	call   f01022ef <page_lookup>
        if(page == NULL)
f0105ee0:	85 c0                	test   %eax,%eax
f0105ee2:	74 38                	je     f0105f1c <syscall+0x48c>
           return -E_INVAL;
        if(!(perm & PTE_P) || !(perm & PTE_U) || (!pte))
f0105ee4:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0105ee7:	85 d2                	test   %edx,%edx
f0105ee9:	74 31                	je     f0105f1c <syscall+0x48c>
              return -E_INVAL;
        if((perm & PTE_W) && (!((*pte) & PTE_W)))
f0105eeb:	f7 c7 02 00 00 00    	test   $0x2,%edi
f0105ef1:	74 05                	je     f0105ef8 <syscall+0x468>
f0105ef3:	f6 02 02             	testb  $0x2,(%edx)
f0105ef6:	74 24                	je     f0105f1c <syscall+0x48c>
              return -E_INVAL;
        ret = page_insert(dstenv->env_pgdir,page,dstva,perm);
f0105ef8:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0105efc:	89 74 24 08          	mov    %esi,0x8(%esp)
f0105f00:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105f04:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0105f07:	8b 40 64             	mov    0x64(%eax),%eax
f0105f0a:	89 04 24             	mov    %eax,(%esp)
f0105f0d:	e8 a9 c4 ff ff       	call   f01023bb <page_insert>
f0105f12:	b8 00 00 00 00       	mov    $0x0,%eax
f0105f17:	e9 84 04 00 00       	jmp    f01063a0 <syscall+0x910>
f0105f1c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0105f21:	e9 7a 04 00 00       	jmp    f01063a0 <syscall+0x910>
sys_page_unmap(envid_t envid, void *va)
{
	// Hint: This function is a wrapper around page_remove().
        uint32_t vaddr = (uint32_t)va;
        struct Env* env;
        if(vaddr >= UTOP || (vaddr%PGSIZE))
f0105f26:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0105f2d:	8d 76 00             	lea    0x0(%esi),%esi
f0105f30:	77 3f                	ja     f0105f71 <syscall+0x4e1>
f0105f32:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f0105f39:	75 36                	jne    f0105f71 <syscall+0x4e1>
              return -E_INVAL;        
        uint32_t ret = envid2env(envid,&env,1);
f0105f3b:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0105f42:	00 
f0105f43:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0105f46:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105f4a:	89 1c 24             	mov    %ebx,(%esp)
f0105f4d:	e8 a6 e2 ff ff       	call   f01041f8 <envid2env>
        if(ret < 0)
            return -E_BAD_ENV;
        page_remove(env->env_pgdir,va);
f0105f52:	8b 5d 10             	mov    0x10(%ebp),%ebx
f0105f55:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105f59:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105f5c:	8b 40 64             	mov    0x64(%eax),%eax
f0105f5f:	89 04 24             	mov    %eax,(%esp)
f0105f62:	e8 f9 c3 ff ff       	call   f0102360 <page_remove>
f0105f67:	b8 00 00 00 00       	mov    $0x0,%eax
f0105f6c:	e9 2f 04 00 00       	jmp    f01063a0 <syscall+0x910>
f0105f71:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0105f76:	e9 25 04 00 00       	jmp    f01063a0 <syscall+0x910>
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, unsigned perm)
{
	// LAB 4: Your code here.
        struct Env* env;
        uint32_t srcvaddr = (uint32_t)srcva;
        uint32_t ret = envid2env(envid,&env,0);
f0105f7b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0105f82:	00 
f0105f83:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0105f86:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105f8a:	89 1c 24             	mov    %ebx,(%esp)
f0105f8d:	e8 66 e2 ff ff       	call   f01041f8 <envid2env>
        if(ret < 0)
            return -E_BAD_ENV;
        if((!env->env_ipc_recving) || env->env_ipc_from)
f0105f92:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105f95:	83 78 6c 00          	cmpl   $0x0,0x6c(%eax)
f0105f99:	0f 84 0e 01 00 00    	je     f01060ad <syscall+0x61d>
f0105f9f:	83 78 78 00          	cmpl   $0x0,0x78(%eax)
f0105fa3:	0f 85 04 01 00 00    	jne    f01060ad <syscall+0x61d>
            return -E_IPC_NOT_RECV;
        if(srcvaddr < UTOP){
f0105fa9:	81 7d 14 ff ff bf ee 	cmpl   $0xeebfffff,0x14(%ebp)
f0105fb0:	0f 87 af 00 00 00    	ja     f0106065 <syscall+0x5d5>
            if(srcvaddr % PGSIZE)
f0105fb6:	f7 45 14 ff 0f 00 00 	testl  $0xfff,0x14(%ebp)
f0105fbd:	8d 76 00             	lea    0x0(%esi),%esi
f0105fc0:	0f 85 f1 00 00 00    	jne    f01060b7 <syscall+0x627>
                 return -E_INVAL;
            if(!(perm & PTE_P) || !(perm & PTE_U))
f0105fc6:	8b 45 18             	mov    0x18(%ebp),%eax
f0105fc9:	83 e0 05             	and    $0x5,%eax
f0105fcc:	83 f8 05             	cmp    $0x5,%eax
f0105fcf:	0f 85 e2 00 00 00    	jne    f01060b7 <syscall+0x627>
                 return -E_INVAL;
            pte_t* pte;
            struct Page* page = page_lookup(curenv->env_pgdir,srcva,&pte);
f0105fd5:	e8 f4 18 00 00       	call   f01078ce <cpunum>
f0105fda:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0105fdd:	89 54 24 08          	mov    %edx,0x8(%esp)
f0105fe1:	8b 55 14             	mov    0x14(%ebp),%edx
f0105fe4:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105fe8:	6b c0 74             	imul   $0x74,%eax,%eax
f0105feb:	8b 80 28 10 1f f0    	mov    -0xfe0efd8(%eax),%eax
f0105ff1:	8b 40 64             	mov    0x64(%eax),%eax
f0105ff4:	89 04 24             	mov    %eax,(%esp)
f0105ff7:	e8 f3 c2 ff ff       	call   f01022ef <page_lookup>
            if((!page) || (!pte) || (!((*pte) & PTE_P)) || (!((*pte) & PTE_U)))
f0105ffc:	85 c0                	test   %eax,%eax
f0105ffe:	0f 84 b3 00 00 00    	je     f01060b7 <syscall+0x627>
f0106004:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0106007:	85 d2                	test   %edx,%edx
f0106009:	0f 84 a8 00 00 00    	je     f01060b7 <syscall+0x627>
f010600f:	8b 12                	mov    (%edx),%edx
f0106011:	89 d1                	mov    %edx,%ecx
f0106013:	83 e1 05             	and    $0x5,%ecx
f0106016:	83 f9 05             	cmp    $0x5,%ecx
f0106019:	0f 85 98 00 00 00    	jne    f01060b7 <syscall+0x627>
                 return -E_INVAL;
            if((perm & PTE_W) && (!((*pte) & PTE_W)))
f010601f:	f6 45 18 02          	testb  $0x2,0x18(%ebp)
f0106023:	74 09                	je     f010602e <syscall+0x59e>
f0106025:	f6 c2 02             	test   $0x2,%dl
f0106028:	0f 84 89 00 00 00    	je     f01060b7 <syscall+0x627>
                 return -E_INVAL;
            if((uint32_t)env->env_ipc_dstva < UTOP){
f010602e:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0106031:	8b 4a 70             	mov    0x70(%edx),%ecx
f0106034:	81 f9 ff ff bf ee    	cmp    $0xeebfffff,%ecx
f010603a:	77 22                	ja     f010605e <syscall+0x5ce>
                 ret = page_insert(env->env_pgdir,page,env->env_ipc_dstva,perm);
f010603c:	8b 5d 18             	mov    0x18(%ebp),%ebx
f010603f:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0106043:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0106047:	89 44 24 04          	mov    %eax,0x4(%esp)
f010604b:	8b 42 64             	mov    0x64(%edx),%eax
f010604e:	89 04 24             	mov    %eax,(%esp)
f0106051:	e8 65 c3 ff ff       	call   f01023bb <page_insert>
                 if(ret < 0)
                    return ret;
                 env->env_ipc_perm = perm;
f0106056:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0106059:	89 58 7c             	mov    %ebx,0x7c(%eax)
f010605c:	eb 07                	jmp    f0106065 <syscall+0x5d5>
            }
            else
                 env->env_ipc_perm = 0;
f010605e:	c7 42 7c 00 00 00 00 	movl   $0x0,0x7c(%edx)
         }
         env->env_ipc_recving = 0;
f0106065:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0106068:	c7 40 6c 00 00 00 00 	movl   $0x0,0x6c(%eax)
         env->env_ipc_value = value;
f010606f:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0106072:	8b 55 10             	mov    0x10(%ebp),%edx
f0106075:	89 50 74             	mov    %edx,0x74(%eax)
         env->env_ipc_from = curenv->env_id;
f0106078:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f010607b:	e8 4e 18 00 00       	call   f01078ce <cpunum>
f0106080:	6b c0 74             	imul   $0x74,%eax,%eax
f0106083:	8b 80 28 10 1f f0    	mov    -0xfe0efd8(%eax),%eax
f0106089:	8b 40 48             	mov    0x48(%eax),%eax
f010608c:	89 43 78             	mov    %eax,0x78(%ebx)
         env->env_status = ENV_RUNNABLE;
f010608f:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0106092:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
         env->env_tf.tf_regs.reg_eax = 0;
f0106099:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010609c:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
f01060a3:	b8 00 00 00 00       	mov    $0x0,%eax
f01060a8:	e9 f3 02 00 00       	jmp    f01063a0 <syscall+0x910>
f01060ad:	b8 f9 ff ff ff       	mov    $0xfffffff9,%eax
f01060b2:	e9 e9 02 00 00       	jmp    f01063a0 <syscall+0x910>
f01060b7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01060bc:	e9 df 02 00 00       	jmp    f01063a0 <syscall+0x910>
//	-E_INVAL if dstva < UTOP but dstva is not page-aligned.
static int
sys_ipc_recv(void *dstva)
{
	// LAB 4: Your code here.
        if((uint32_t)dstva < UTOP){
f01060c1:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
f01060c7:	77 13                	ja     f01060dc <syscall+0x64c>
           if((uint32_t)dstva % PGSIZE)
f01060c9:	f7 c3 ff 0f 00 00    	test   $0xfff,%ebx
f01060cf:	90                   	nop
f01060d0:	74 0a                	je     f01060dc <syscall+0x64c>
f01060d2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01060d7:	e9 c4 02 00 00       	jmp    f01063a0 <syscall+0x910>
                 return -E_INVAL;
        }
        curenv->env_ipc_recving = 1;
f01060dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01060e0:	e8 e9 17 00 00       	call   f01078ce <cpunum>
f01060e5:	be 20 10 1f f0       	mov    $0xf01f1020,%esi
f01060ea:	6b c0 74             	imul   $0x74,%eax,%eax
f01060ed:	8b 44 30 08          	mov    0x8(%eax,%esi,1),%eax
f01060f1:	c7 40 6c 01 00 00 00 	movl   $0x1,0x6c(%eax)
        curenv->env_ipc_dstva = dstva;
f01060f8:	e8 d1 17 00 00       	call   f01078ce <cpunum>
f01060fd:	6b c0 74             	imul   $0x74,%eax,%eax
f0106100:	8b 44 30 08          	mov    0x8(%eax,%esi,1),%eax
f0106104:	89 58 70             	mov    %ebx,0x70(%eax)
        curenv->env_ipc_from = 0;
f0106107:	e8 c2 17 00 00       	call   f01078ce <cpunum>
f010610c:	6b c0 74             	imul   $0x74,%eax,%eax
f010610f:	8b 44 30 08          	mov    0x8(%eax,%esi,1),%eax
f0106113:	c7 40 78 00 00 00 00 	movl   $0x0,0x78(%eax)
        curenv->env_status = ENV_NOT_RUNNABLE;
f010611a:	e8 af 17 00 00       	call   f01078ce <cpunum>
f010611f:	6b c0 74             	imul   $0x74,%eax,%eax
f0106122:	8b 44 30 08          	mov    0x8(%eax,%esi,1),%eax
f0106126:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
        sched_yield();
f010612d:	e8 fe f7 ff ff       	call   f0105930 <sched_yield>
}

static int 
sys_env_set_prior(envid_t envid, uint32_t prior){
        struct Env* env;
        uint32_t ret = envid2env(envid,&env,1);
f0106132:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0106139:	00 
f010613a:	8d 45 dc             	lea    -0x24(%ebp),%eax
f010613d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106141:	89 1c 24             	mov    %ebx,(%esp)
f0106144:	e8 af e0 ff ff       	call   f01041f8 <envid2env>
        if(ret < 0)
            return -E_BAD_ENV;
        env->env_prior = prior;
f0106149:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010614c:	8b 5d 10             	mov    0x10(%ebp),%ebx
f010614f:	89 98 80 00 00 00    	mov    %ebx,0x80(%eax)
f0106155:	b8 00 00 00 00       	mov    $0x0,%eax
        case SYS_ipc_recv:
          ret = sys_ipc_recv((void*)a1);
          break;
        case SYS_env_set_prior:
          ret = sys_env_set_prior((envid_t)a1,(uint32_t)a2);
          break;
f010615a:	e9 41 02 00 00       	jmp    f01063a0 <syscall+0x910>
	// LAB 5: Your code here.
	// Remember to check whether the user has supplied us with a good
	// address!
        struct Env* env;
        int r;
        r = envid2env(envid,&env,1);
f010615f:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0106166:	00 
f0106167:	8d 45 dc             	lea    -0x24(%ebp),%eax
f010616a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010616e:	89 1c 24             	mov    %ebx,(%esp)
f0106171:	e8 82 e0 ff ff       	call   f01041f8 <envid2env>
f0106176:	89 c2                	mov    %eax,%edx
        if(r < 0)
f0106178:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f010617d:	85 d2                	test   %edx,%edx
f010617f:	0f 88 1b 02 00 00    	js     f01063a0 <syscall+0x910>
          return -E_BAD_ENV;
        user_mem_assert(env,tf,sizeof(struct Trapframe),PTE_P|PTE_U);
f0106185:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
f010618c:	00 
f010618d:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
f0106194:	00 
f0106195:	8b 45 10             	mov    0x10(%ebp),%eax
f0106198:	89 44 24 04          	mov    %eax,0x4(%esp)
f010619c:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010619f:	89 04 24             	mov    %eax,(%esp)
f01061a2:	e8 f0 c0 ff ff       	call   f0102297 <user_mem_assert>
        env->env_tf = *tf;
f01061a7:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01061aa:	b9 11 00 00 00       	mov    $0x11,%ecx
f01061af:	89 c7                	mov    %eax,%edi
f01061b1:	8b 75 10             	mov    0x10(%ebp),%esi
f01061b4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
        env->env_tf.tf_cs = GD_UT|3;
f01061b6:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01061b9:	66 c7 40 34 1b 00    	movw   $0x1b,0x34(%eax)
        env->env_tf.tf_eflags |= FL_IF;
f01061bf:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01061c2:	81 48 38 00 02 00 00 	orl    $0x200,0x38(%eax)
f01061c9:	b8 00 00 00 00       	mov    $0x0,%eax
f01061ce:	e9 cd 01 00 00       	jmp    f01063a0 <syscall+0x910>
        uint32_t begin, end;
        int perm;
        int r;
        struct Page* pg;
        struct Proghdr* ph = (struct Proghdr*) vph;
        for (i = 0; i < phnum; i++, ph++) {
f01061d3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f01061d7:	0f 84 01 01 00 00    	je     f01062de <syscall+0x84e>
        uint32_t tmp = FTEMP;
        uint32_t begin, end;
        int perm;
        int r;
        struct Page* pg;
        struct Proghdr* ph = (struct Proghdr*) vph;
f01061dd:	89 5d c8             	mov    %ebx,-0x38(%ebp)
f01061e0:	be 00 00 00 e0       	mov    $0xe0000000,%esi
f01061e5:	c7 45 c0 00 00 00 00 	movl   $0x0,-0x40(%ebp)
	      perm = PTE_P | PTE_U;
	      if (ph->p_flags & ELF_PROG_FLAG_WRITE)
		   perm |= PTE_W;
              end = ROUNDUP(ph->p_va + ph->p_memsz, PGSIZE);
	      for (begin = ROUNDDOWN(ph->p_va, PGSIZE); begin != end; begin += PGSIZE) {
		   if ((pg = page_lookup(curenv->env_pgdir, (void *)tmp, NULL)) == NULL) 
f01061ec:	bb 20 10 1f f0       	mov    $0xf01f1020,%ebx
        int perm;
        int r;
        struct Page* pg;
        struct Proghdr* ph = (struct Proghdr*) vph;
        for (i = 0; i < phnum; i++, ph++) {
	      if (ph->p_type != ELF_PROG_LOAD)
f01061f1:	8b 55 c8             	mov    -0x38(%ebp),%edx
f01061f4:	83 3a 01             	cmpl   $0x1,(%edx)
f01061f7:	0f 85 cc 00 00 00    	jne    f01062c9 <syscall+0x839>
		   continue;
	      perm = PTE_P | PTE_U;
	      if (ph->p_flags & ELF_PROG_FLAG_WRITE)
f01061fd:	8b 42 18             	mov    0x18(%edx),%eax
f0106200:	83 e0 02             	and    $0x2,%eax
f0106203:	83 f8 01             	cmp    $0x1,%eax
f0106206:	19 c0                	sbb    %eax,%eax
f0106208:	83 e0 fe             	and    $0xfffffffe,%eax
f010620b:	83 c0 07             	add    $0x7,%eax
f010620e:	89 45 cc             	mov    %eax,-0x34(%ebp)
		   perm |= PTE_W;
              end = ROUNDUP(ph->p_va + ph->p_memsz, PGSIZE);
f0106211:	8b 7a 08             	mov    0x8(%edx),%edi
f0106214:	89 f8                	mov    %edi,%eax
f0106216:	03 42 14             	add    0x14(%edx),%eax
f0106219:	05 ff 0f 00 00       	add    $0xfff,%eax
f010621e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0106223:	89 45 c4             	mov    %eax,-0x3c(%ebp)
	      for (begin = ROUNDDOWN(ph->p_va, PGSIZE); begin != end; begin += PGSIZE) {
f0106226:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
f010622c:	39 f8                	cmp    %edi,%eax
f010622e:	0f 84 95 00 00 00    	je     f01062c9 <syscall+0x839>
f0106234:	89 75 d0             	mov    %esi,-0x30(%ebp)
		   if ((pg = page_lookup(curenv->env_pgdir, (void *)tmp, NULL)) == NULL) 
f0106237:	e8 92 16 00 00       	call   f01078ce <cpunum>
f010623c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0106243:	00 
f0106244:	89 74 24 04          	mov    %esi,0x4(%esp)
f0106248:	6b c0 74             	imul   $0x74,%eax,%eax
f010624b:	8b 44 18 08          	mov    0x8(%eax,%ebx,1),%eax
f010624f:	8b 40 64             	mov    0x64(%eax),%eax
f0106252:	89 04 24             	mov    %eax,(%esp)
f0106255:	e8 95 c0 ff ff       	call   f01022ef <page_lookup>
f010625a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010625d:	85 c0                	test   %eax,%eax
f010625f:	0f 84 36 01 00 00    	je     f010639b <syscall+0x90b>
			  return -E_NO_MEM;
		   if ((r = page_insert(curenv->env_pgdir, pg, (void *)begin, perm)) < 0)
f0106265:	e8 64 16 00 00       	call   f01078ce <cpunum>
f010626a:	8b 55 cc             	mov    -0x34(%ebp),%edx
f010626d:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0106271:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0106275:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0106278:	89 54 24 04          	mov    %edx,0x4(%esp)
f010627c:	6b c0 74             	imul   $0x74,%eax,%eax
f010627f:	8b 44 18 08          	mov    0x8(%eax,%ebx,1),%eax
f0106283:	8b 40 64             	mov    0x64(%eax),%eax
f0106286:	89 04 24             	mov    %eax,(%esp)
f0106289:	e8 2d c1 ff ff       	call   f01023bb <page_insert>
f010628e:	85 c0                	test   %eax,%eax
f0106290:	0f 88 0a 01 00 00    	js     f01063a0 <syscall+0x910>
			  return r;
		   page_remove(curenv->env_pgdir, (void *)tmp);
f0106296:	e8 33 16 00 00       	call   f01078ce <cpunum>
f010629b:	8b 55 d0             	mov    -0x30(%ebp),%edx
f010629e:	89 54 24 04          	mov    %edx,0x4(%esp)
f01062a2:	6b c0 74             	imul   $0x74,%eax,%eax
f01062a5:	8b 44 18 08          	mov    0x8(%eax,%ebx,1),%eax
f01062a9:	8b 40 64             	mov    0x64(%eax),%eax
f01062ac:	89 04 24             	mov    %eax,(%esp)
f01062af:	e8 ac c0 ff ff       	call   f0102360 <page_remove>
                   tmp += PGSIZE;
f01062b4:	81 c6 00 10 00 00    	add    $0x1000,%esi
		   continue;
	      perm = PTE_P | PTE_U;
	      if (ph->p_flags & ELF_PROG_FLAG_WRITE)
		   perm |= PTE_W;
              end = ROUNDUP(ph->p_va + ph->p_memsz, PGSIZE);
	      for (begin = ROUNDDOWN(ph->p_va, PGSIZE); begin != end; begin += PGSIZE) {
f01062ba:	81 c7 00 10 00 00    	add    $0x1000,%edi
f01062c0:	39 7d c4             	cmp    %edi,-0x3c(%ebp)
f01062c3:	0f 85 6b ff ff ff    	jne    f0106234 <syscall+0x7a4>
        uint32_t begin, end;
        int perm;
        int r;
        struct Page* pg;
        struct Proghdr* ph = (struct Proghdr*) vph;
        for (i = 0; i < phnum; i++, ph++) {
f01062c9:	83 45 c0 01          	addl   $0x1,-0x40(%ebp)
f01062cd:	8b 45 c0             	mov    -0x40(%ebp),%eax
f01062d0:	39 45 10             	cmp    %eax,0x10(%ebp)
f01062d3:	76 0e                	jbe    f01062e3 <syscall+0x853>
f01062d5:	83 45 c8 20          	addl   $0x20,-0x38(%ebp)
f01062d9:	e9 13 ff ff ff       	jmp    f01061f1 <syscall+0x761>
f01062de:	be 00 00 00 e0       	mov    $0xe0000000,%esi
			  return r;
		   page_remove(curenv->env_pgdir, (void *)tmp);
                   tmp += PGSIZE;
	      }
        }
        if ((pg = page_lookup(curenv->env_pgdir, (void *)tmp, NULL)) == NULL) 
f01062e3:	e8 e6 15 00 00       	call   f01078ce <cpunum>
f01062e8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01062ef:	00 
f01062f0:	89 74 24 04          	mov    %esi,0x4(%esp)
f01062f4:	6b c0 74             	imul   $0x74,%eax,%eax
f01062f7:	8b 80 28 10 1f f0    	mov    -0xfe0efd8(%eax),%eax
f01062fd:	8b 40 64             	mov    0x64(%eax),%eax
f0106300:	89 04 24             	mov    %eax,(%esp)
f0106303:	e8 e7 bf ff ff       	call   f01022ef <page_lookup>
f0106308:	89 c3                	mov    %eax,%ebx
f010630a:	85 c0                	test   %eax,%eax
f010630c:	0f 84 89 00 00 00    	je     f010639b <syscall+0x90b>
	     return -E_NO_MEM;
        if ((r = page_insert(curenv->env_pgdir, pg, (void *)(USTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W)) < 0) 
f0106312:	e8 b7 15 00 00       	call   f01078ce <cpunum>
f0106317:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
f010631e:	00 
f010631f:	c7 44 24 08 00 d0 bf 	movl   $0xeebfd000,0x8(%esp)
f0106326:	ee 
f0106327:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010632b:	6b c0 74             	imul   $0x74,%eax,%eax
f010632e:	8b 80 28 10 1f f0    	mov    -0xfe0efd8(%eax),%eax
f0106334:	8b 40 64             	mov    0x64(%eax),%eax
f0106337:	89 04 24             	mov    %eax,(%esp)
f010633a:	e8 7c c0 ff ff       	call   f01023bb <page_insert>
f010633f:	85 c0                	test   %eax,%eax
f0106341:	78 5d                	js     f01063a0 <syscall+0x910>
	     return r;
        page_remove(curenv->env_pgdir, (void *)tmp);
f0106343:	e8 86 15 00 00       	call   f01078ce <cpunum>
f0106348:	89 74 24 04          	mov    %esi,0x4(%esp)
f010634c:	bb 20 10 1f f0       	mov    $0xf01f1020,%ebx
f0106351:	6b c0 74             	imul   $0x74,%eax,%eax
f0106354:	8b 44 18 08          	mov    0x8(%eax,%ebx,1),%eax
f0106358:	8b 40 64             	mov    0x64(%eax),%eax
f010635b:	89 04 24             	mov    %eax,(%esp)
f010635e:	e8 fd bf ff ff       	call   f0102360 <page_remove>
        curenv->env_tf.tf_esp = esp;
f0106363:	e8 66 15 00 00       	call   f01078ce <cpunum>
f0106368:	6b c0 74             	imul   $0x74,%eax,%eax
f010636b:	8b 44 18 08          	mov    0x8(%eax,%ebx,1),%eax
f010636f:	8b 55 14             	mov    0x14(%ebp),%edx
f0106372:	89 50 3c             	mov    %edx,0x3c(%eax)
        curenv->env_tf.tf_eip = eip;	
f0106375:	e8 54 15 00 00       	call   f01078ce <cpunum>
f010637a:	6b c0 74             	imul   $0x74,%eax,%eax
f010637d:	8b 44 18 08          	mov    0x8(%eax,%ebx,1),%eax
f0106381:	8b 55 18             	mov    0x18(%ebp),%edx
f0106384:	89 50 30             	mov    %edx,0x30(%eax)
        env_run(curenv);
f0106387:	e8 42 15 00 00       	call   f01078ce <cpunum>
f010638c:	6b c0 74             	imul   $0x74,%eax,%eax
f010638f:	8b 44 18 08          	mov    0x8(%eax,%ebx,1),%eax
f0106393:	89 04 24             	mov    %eax,(%esp)
f0106396:	e8 4f df ff ff       	call   f01042ea <env_run>
f010639b:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
        return ret;
     
          
     
	//panic("syscall not implemented");
}
f01063a0:	83 c4 4c             	add    $0x4c,%esp
f01063a3:	5b                   	pop    %ebx
f01063a4:	5e                   	pop    %esi
f01063a5:	5f                   	pop    %edi
f01063a6:	5d                   	pop    %ebp
f01063a7:	c3                   	ret    
	...

f01063b0 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f01063b0:	55                   	push   %ebp
f01063b1:	89 e5                	mov    %esp,%ebp
f01063b3:	57                   	push   %edi
f01063b4:	56                   	push   %esi
f01063b5:	53                   	push   %ebx
f01063b6:	83 ec 14             	sub    $0x14,%esp
f01063b9:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01063bc:	89 55 e8             	mov    %edx,-0x18(%ebp)
f01063bf:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f01063c2:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f01063c5:	8b 1a                	mov    (%edx),%ebx
f01063c7:	8b 01                	mov    (%ecx),%eax
f01063c9:	89 45 ec             	mov    %eax,-0x14(%ebp)
	
	while (l <= r) {
f01063cc:	39 c3                	cmp    %eax,%ebx
f01063ce:	0f 8f 9c 00 00 00    	jg     f0106470 <stab_binsearch+0xc0>
f01063d4:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
		int true_m = (l + r) / 2, m = true_m;
f01063db:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01063de:	01 d8                	add    %ebx,%eax
f01063e0:	89 c7                	mov    %eax,%edi
f01063e2:	c1 ef 1f             	shr    $0x1f,%edi
f01063e5:	01 c7                	add    %eax,%edi
f01063e7:	d1 ff                	sar    %edi
		
		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01063e9:	39 df                	cmp    %ebx,%edi
f01063eb:	7c 33                	jl     f0106420 <stab_binsearch+0x70>
f01063ed:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f01063f0:	8b 55 f0             	mov    -0x10(%ebp),%edx
f01063f3:	0f b6 44 82 04       	movzbl 0x4(%edx,%eax,4),%eax
f01063f8:	39 f0                	cmp    %esi,%eax
f01063fa:	0f 84 bc 00 00 00    	je     f01064bc <stab_binsearch+0x10c>
f0106400:	8d 44 7f fd          	lea    -0x3(%edi,%edi,2),%eax
f0106404:	8d 54 82 04          	lea    0x4(%edx,%eax,4),%edx
f0106408:	89 f8                	mov    %edi,%eax
			m--;
f010640a:	83 e8 01             	sub    $0x1,%eax
	
	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
		
		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f010640d:	39 d8                	cmp    %ebx,%eax
f010640f:	7c 0f                	jl     f0106420 <stab_binsearch+0x70>
f0106411:	0f b6 0a             	movzbl (%edx),%ecx
f0106414:	83 ea 0c             	sub    $0xc,%edx
f0106417:	39 f1                	cmp    %esi,%ecx
f0106419:	75 ef                	jne    f010640a <stab_binsearch+0x5a>
f010641b:	e9 9e 00 00 00       	jmp    f01064be <stab_binsearch+0x10e>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0106420:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f0106423:	eb 3c                	jmp    f0106461 <stab_binsearch+0xb1>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f0106425:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0106428:	89 01                	mov    %eax,(%ecx)
			l = true_m + 1;
f010642a:	8d 5f 01             	lea    0x1(%edi),%ebx
f010642d:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f0106434:	eb 2b                	jmp    f0106461 <stab_binsearch+0xb1>
		} else if (stabs[m].n_value > addr) {
f0106436:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0106439:	76 14                	jbe    f010644f <stab_binsearch+0x9f>
			*region_right = m - 1;
f010643b:	83 e8 01             	sub    $0x1,%eax
f010643e:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0106441:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0106444:	89 02                	mov    %eax,(%edx)
f0106446:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f010644d:	eb 12                	jmp    f0106461 <stab_binsearch+0xb1>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f010644f:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0106452:	89 01                	mov    %eax,(%ecx)
			l = m;
			addr++;
f0106454:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0106458:	89 c3                	mov    %eax,%ebx
f010645a:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;
	
	while (l <= r) {
f0106461:	39 5d ec             	cmp    %ebx,-0x14(%ebp)
f0106464:	0f 8d 71 ff ff ff    	jge    f01063db <stab_binsearch+0x2b>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f010646a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f010646e:	75 0f                	jne    f010647f <stab_binsearch+0xcf>
		*region_right = *region_left - 1;
f0106470:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f0106473:	8b 03                	mov    (%ebx),%eax
f0106475:	83 e8 01             	sub    $0x1,%eax
f0106478:	8b 55 e0             	mov    -0x20(%ebp),%edx
f010647b:	89 02                	mov    %eax,(%edx)
f010647d:	eb 57                	jmp    f01064d6 <stab_binsearch+0x126>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f010647f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0106482:	8b 01                	mov    (%ecx),%eax
		     l > *region_left && stabs[l].n_type != type;
f0106484:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f0106487:	8b 0b                	mov    (%ebx),%ecx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0106489:	39 c1                	cmp    %eax,%ecx
f010648b:	7d 28                	jge    f01064b5 <stab_binsearch+0x105>
		     l > *region_left && stabs[l].n_type != type;
f010648d:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0106490:	8b 5d f0             	mov    -0x10(%ebp),%ebx
f0106493:	0f b6 54 93 04       	movzbl 0x4(%ebx,%edx,4),%edx
f0106498:	39 f2                	cmp    %esi,%edx
f010649a:	74 19                	je     f01064b5 <stab_binsearch+0x105>
f010649c:	8d 54 40 fd          	lea    -0x3(%eax,%eax,2),%edx
f01064a0:	8d 54 93 04          	lea    0x4(%ebx,%edx,4),%edx
		     l--)
f01064a4:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01064a7:	39 c1                	cmp    %eax,%ecx
f01064a9:	7d 0a                	jge    f01064b5 <stab_binsearch+0x105>
		     l > *region_left && stabs[l].n_type != type;
f01064ab:	0f b6 1a             	movzbl (%edx),%ebx
f01064ae:	83 ea 0c             	sub    $0xc,%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01064b1:	39 f3                	cmp    %esi,%ebx
f01064b3:	75 ef                	jne    f01064a4 <stab_binsearch+0xf4>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
f01064b5:	8b 55 e8             	mov    -0x18(%ebp),%edx
f01064b8:	89 02                	mov    %eax,(%edx)
f01064ba:	eb 1a                	jmp    f01064d6 <stab_binsearch+0x126>
	}
}
f01064bc:	89 f8                	mov    %edi,%eax
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f01064be:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01064c1:	8b 4d f0             	mov    -0x10(%ebp),%ecx
f01064c4:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f01064c8:	3b 55 0c             	cmp    0xc(%ebp),%edx
f01064cb:	0f 82 54 ff ff ff    	jb     f0106425 <stab_binsearch+0x75>
f01064d1:	e9 60 ff ff ff       	jmp    f0106436 <stab_binsearch+0x86>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f01064d6:	83 c4 14             	add    $0x14,%esp
f01064d9:	5b                   	pop    %ebx
f01064da:	5e                   	pop    %esi
f01064db:	5f                   	pop    %edi
f01064dc:	5d                   	pop    %ebp
f01064dd:	c3                   	ret    

f01064de <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f01064de:	55                   	push   %ebp
f01064df:	89 e5                	mov    %esp,%ebp
f01064e1:	83 ec 58             	sub    $0x58,%esp
f01064e4:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f01064e7:	89 75 f8             	mov    %esi,-0x8(%ebp)
f01064ea:	89 7d fc             	mov    %edi,-0x4(%ebp)
f01064ed:	8b 7d 08             	mov    0x8(%ebp),%edi
f01064f0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f01064f3:	c7 03 6c 97 10 f0    	movl   $0xf010976c,(%ebx)
	info->eip_line = 0;
f01064f9:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0106500:	c7 43 08 6c 97 10 f0 	movl   $0xf010976c,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0106507:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f010650e:	89 7b 10             	mov    %edi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0106511:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0106518:	81 ff ff ff 7f ef    	cmp    $0xef7fffff,%edi
f010651e:	76 1a                	jbe    f010653a <debuginfo_eip+0x5c>
f0106520:	be 3e 99 11 f0       	mov    $0xf011993e,%esi
f0106525:	c7 45 c4 89 5c 11 f0 	movl   $0xf0115c89,-0x3c(%ebp)
f010652c:	b8 88 5c 11 f0       	mov    $0xf0115c88,%eax
f0106531:	c7 45 c0 90 9d 10 f0 	movl   $0xf0109d90,-0x40(%ebp)
f0106538:	eb 16                	jmp    f0106550 <debuginfo_eip+0x72>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.

		stabs = usd->stabs;
f010653a:	ba 00 00 20 00       	mov    $0x200000,%edx
f010653f:	8b 02                	mov    (%edx),%eax
f0106541:	89 45 c0             	mov    %eax,-0x40(%ebp)
		stab_end = usd->stab_end;
f0106544:	8b 42 04             	mov    0x4(%edx),%eax
		stabstr = usd->stabstr;
f0106547:	8b 4a 08             	mov    0x8(%edx),%ecx
f010654a:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
		stabstr_end = usd->stabstr_end;
f010654d:	8b 72 0c             	mov    0xc(%edx),%esi
		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0106550:	39 75 c4             	cmp    %esi,-0x3c(%ebp)
f0106553:	0f 83 65 01 00 00    	jae    f01066be <debuginfo_eip+0x1e0>
f0106559:	80 7e ff 00          	cmpb   $0x0,-0x1(%esi)
f010655d:	0f 85 5b 01 00 00    	jne    f01066be <debuginfo_eip+0x1e0>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.
	
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0106563:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f010656a:	2b 45 c0             	sub    -0x40(%ebp),%eax
f010656d:	c1 f8 02             	sar    $0x2,%eax
f0106570:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0106576:	83 e8 01             	sub    $0x1,%eax
f0106579:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f010657c:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f010657f:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0106582:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0106586:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f010658d:	8b 45 c0             	mov    -0x40(%ebp),%eax
f0106590:	e8 1b fe ff ff       	call   f01063b0 <stab_binsearch>
	if (lfile == 0)
f0106595:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0106598:	85 c0                	test   %eax,%eax
f010659a:	0f 84 1e 01 00 00    	je     f01066be <debuginfo_eip+0x1e0>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f01065a0:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f01065a3:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01065a6:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f01065a9:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f01065ac:	8d 55 dc             	lea    -0x24(%ebp),%edx
f01065af:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01065b3:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f01065ba:	8b 45 c0             	mov    -0x40(%ebp),%eax
f01065bd:	e8 ee fd ff ff       	call   f01063b0 <stab_binsearch>

	if (lfun <= rfun) {
f01065c2:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01065c5:	3b 45 d8             	cmp    -0x28(%ebp),%eax
f01065c8:	7f 35                	jg     f01065ff <debuginfo_eip+0x121>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f01065ca:	6b c0 0c             	imul   $0xc,%eax,%eax
f01065cd:	8b 55 c0             	mov    -0x40(%ebp),%edx
f01065d0:	8b 04 10             	mov    (%eax,%edx,1),%eax
f01065d3:	89 f2                	mov    %esi,%edx
f01065d5:	2b 55 c4             	sub    -0x3c(%ebp),%edx
f01065d8:	39 d0                	cmp    %edx,%eax
f01065da:	73 06                	jae    f01065e2 <debuginfo_eip+0x104>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f01065dc:	03 45 c4             	add    -0x3c(%ebp),%eax
f01065df:	89 43 08             	mov    %eax,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f01065e2:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01065e5:	6b c2 0c             	imul   $0xc,%edx,%eax
f01065e8:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f01065eb:	8b 44 08 08          	mov    0x8(%eax,%ecx,1),%eax
f01065ef:	89 43 10             	mov    %eax,0x10(%ebx)
		addr -= info->eip_fn_addr;
f01065f2:	29 c7                	sub    %eax,%edi
		// Search within the function definition for the line number.
		lline = lfun;
f01065f4:	89 55 d4             	mov    %edx,-0x2c(%ebp)
		rline = rfun;
f01065f7:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01065fa:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01065fd:	eb 0f                	jmp    f010660e <debuginfo_eip+0x130>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f01065ff:	89 7b 10             	mov    %edi,0x10(%ebx)
		lline = lfile;
f0106602:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0106605:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0106608:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010660b:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f010660e:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f0106615:	00 
f0106616:	8b 43 08             	mov    0x8(%ebx),%eax
f0106619:	89 04 24             	mov    %eax,(%esp)
f010661c:	e8 da 0b 00 00       	call   f01071fb <strfind>
f0106621:	2b 43 08             	sub    0x8(%ebx),%eax
f0106624:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
        stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0106627:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f010662a:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f010662d:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0106631:	c7 04 24 44 00 00 00 	movl   $0x44,(%esp)
f0106638:	8b 45 c0             	mov    -0x40(%ebp),%eax
f010663b:	e8 70 fd ff ff       	call   f01063b0 <stab_binsearch>
        if(lline <= rline)
f0106640:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0106643:	3b 45 d0             	cmp    -0x30(%ebp),%eax
f0106646:	7f 76                	jg     f01066be <debuginfo_eip+0x1e0>
           info->eip_line = stabs[lline].n_desc;
f0106648:	6b c0 0c             	imul   $0xc,%eax,%eax
f010664b:	8b 55 c0             	mov    -0x40(%ebp),%edx
f010664e:	0f b7 44 10 06       	movzwl 0x6(%eax,%edx,1),%eax
f0106653:	89 43 04             	mov    %eax,0x4(%ebx)
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
f0106656:	8b 7d e4             	mov    -0x1c(%ebp),%edi
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0106659:	eb 06                	jmp    f0106661 <debuginfo_eip+0x183>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f010665b:	83 e8 01             	sub    $0x1,%eax
f010665e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
f0106661:	8b 45 d4             	mov    -0x2c(%ebp),%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0106664:	39 f8                	cmp    %edi,%eax
f0106666:	7c 27                	jl     f010668f <debuginfo_eip+0x1b1>
	       && stabs[lline].n_type != N_SOL
f0106668:	6b d0 0c             	imul   $0xc,%eax,%edx
f010666b:	03 55 c0             	add    -0x40(%ebp),%edx
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f010666e:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0106672:	80 f9 84             	cmp    $0x84,%cl
f0106675:	74 60                	je     f01066d7 <debuginfo_eip+0x1f9>
f0106677:	80 f9 64             	cmp    $0x64,%cl
f010667a:	75 df                	jne    f010665b <debuginfo_eip+0x17d>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f010667c:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
f0106680:	74 d9                	je     f010665b <debuginfo_eip+0x17d>
f0106682:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0106688:	eb 4d                	jmp    f01066d7 <debuginfo_eip+0x1f9>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
		info->eip_file = stabstr + stabs[lline].n_strx;
f010668a:	03 45 c4             	add    -0x3c(%ebp),%eax
f010668d:	89 03                	mov    %eax,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f010668f:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0106692:	3b 45 d8             	cmp    -0x28(%ebp),%eax
f0106695:	7d 2e                	jge    f01066c5 <debuginfo_eip+0x1e7>
		for (lline = lfun + 1;
f0106697:	83 c0 01             	add    $0x1,%eax
f010669a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010669d:	eb 08                	jmp    f01066a7 <debuginfo_eip+0x1c9>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f010669f:	83 43 14 01          	addl   $0x1,0x14(%ebx)
	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
f01066a3:	83 45 d4 01          	addl   $0x1,-0x2c(%ebp)

	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f01066a7:	8b 45 d4             	mov    -0x2c(%ebp),%eax


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f01066aa:	3b 45 d8             	cmp    -0x28(%ebp),%eax
f01066ad:	7d 16                	jge    f01066c5 <debuginfo_eip+0x1e7>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f01066af:	6b c0 0c             	imul   $0xc,%eax,%eax
f01066b2:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f01066b5:	80 7c 08 04 a0       	cmpb   $0xa0,0x4(%eax,%ecx,1)
f01066ba:	74 e3                	je     f010669f <debuginfo_eip+0x1c1>
f01066bc:	eb 07                	jmp    f01066c5 <debuginfo_eip+0x1e7>
f01066be:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01066c3:	eb 05                	jmp    f01066ca <debuginfo_eip+0x1ec>
f01066c5:	b8 00 00 00 00       	mov    $0x0,%eax
		     lline++)
			info->eip_fn_narg++;
	
	return 0;
}
f01066ca:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f01066cd:	8b 75 f8             	mov    -0x8(%ebp),%esi
f01066d0:	8b 7d fc             	mov    -0x4(%ebp),%edi
f01066d3:	89 ec                	mov    %ebp,%esp
f01066d5:	5d                   	pop    %ebp
f01066d6:	c3                   	ret    
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f01066d7:	6b c0 0c             	imul   $0xc,%eax,%eax
f01066da:	8b 55 c0             	mov    -0x40(%ebp),%edx
f01066dd:	8b 04 10             	mov    (%eax,%edx,1),%eax
f01066e0:	2b 75 c4             	sub    -0x3c(%ebp),%esi
f01066e3:	39 f0                	cmp    %esi,%eax
f01066e5:	72 a3                	jb     f010668a <debuginfo_eip+0x1ac>
f01066e7:	eb a6                	jmp    f010668f <debuginfo_eip+0x1b1>
f01066e9:	00 00                	add    %al,(%eax)
f01066eb:	00 00                	add    %al,(%eax)
f01066ed:	00 00                	add    %al,(%eax)
	...

f01066f0 <printnum_v2>:
 */

static void 
printnum_v2(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f01066f0:	55                   	push   %ebp
f01066f1:	89 e5                	mov    %esp,%ebp
f01066f3:	57                   	push   %edi
f01066f4:	56                   	push   %esi
f01066f5:	53                   	push   %ebx
f01066f6:	83 ec 4c             	sub    $0x4c,%esp
f01066f9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01066fc:	89 d6                	mov    %edx,%esi
f01066fe:	8b 45 08             	mov    0x8(%ebp),%eax
f0106701:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0106704:	8b 55 0c             	mov    0xc(%ebp),%edx
f0106707:	89 55 e0             	mov    %edx,-0x20(%ebp)
f010670a:	8b 45 10             	mov    0x10(%ebp),%eax
f010670d:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0106710:	8b 7d 18             	mov    0x18(%ebp),%edi
    if (num >= base) {
f0106713:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0106716:	b9 00 00 00 00       	mov    $0x0,%ecx
f010671b:	39 d1                	cmp    %edx,%ecx
f010671d:	72 07                	jb     f0106726 <printnum_v2+0x36>
f010671f:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0106722:	39 d0                	cmp    %edx,%eax
f0106724:	77 5f                	ja     f0106785 <printnum_v2+0x95>
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
f0106726:	89 7c 24 10          	mov    %edi,0x10(%esp)
f010672a:	83 eb 01             	sub    $0x1,%ebx
f010672d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0106731:	89 44 24 08          	mov    %eax,0x8(%esp)
f0106735:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0106739:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
f010673d:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f0106740:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
f0106743:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0106746:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f010674a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0106751:	00 
f0106752:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0106755:	89 04 24             	mov    %eax,(%esp)
f0106758:	8b 55 e0             	mov    -0x20(%ebp),%edx
f010675b:	89 54 24 04          	mov    %edx,0x4(%esp)
f010675f:	e8 0c 16 00 00       	call   f0107d70 <__udivdi3>
f0106764:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0106767:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010676a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010676e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0106772:	89 04 24             	mov    %eax,(%esp)
f0106775:	89 54 24 04          	mov    %edx,0x4(%esp)
f0106779:	89 f2                	mov    %esi,%edx
f010677b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010677e:	e8 6d ff ff ff       	call   f01066f0 <printnum_v2>
f0106783:	eb 1e                	jmp    f01067a3 <printnum_v2+0xb3>
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
f0106785:	83 ff 2d             	cmp    $0x2d,%edi
f0106788:	74 19                	je     f01067a3 <printnum_v2+0xb3>
		while (--width > 0)
f010678a:	83 eb 01             	sub    $0x1,%ebx
f010678d:	85 db                	test   %ebx,%ebx
f010678f:	90                   	nop
f0106790:	7e 11                	jle    f01067a3 <printnum_v2+0xb3>
			putch(padc, putdat);
f0106792:	89 74 24 04          	mov    %esi,0x4(%esp)
f0106796:	89 3c 24             	mov    %edi,(%esp)
f0106799:	ff 55 e4             	call   *-0x1c(%ebp)
    if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
		while (--width > 0)
f010679c:	83 eb 01             	sub    $0x1,%ebx
f010679f:	85 db                	test   %ebx,%ebx
f01067a1:	7f ef                	jg     f0106792 <printnum_v2+0xa2>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f01067a3:	89 74 24 04          	mov    %esi,0x4(%esp)
f01067a7:	8b 74 24 04          	mov    0x4(%esp),%esi
f01067ab:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01067ae:	89 44 24 08          	mov    %eax,0x8(%esp)
f01067b2:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f01067b9:	00 
f01067ba:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01067bd:	89 14 24             	mov    %edx,(%esp)
f01067c0:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f01067c3:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f01067c7:	e8 d4 16 00 00       	call   f0107ea0 <__umoddi3>
f01067cc:	89 74 24 04          	mov    %esi,0x4(%esp)
f01067d0:	0f be 80 76 97 10 f0 	movsbl -0xfef688a(%eax),%eax
f01067d7:	89 04 24             	mov    %eax,(%esp)
f01067da:	ff 55 e4             	call   *-0x1c(%ebp)
}
f01067dd:	83 c4 4c             	add    $0x4c,%esp
f01067e0:	5b                   	pop    %ebx
f01067e1:	5e                   	pop    %esi
f01067e2:	5f                   	pop    %edi
f01067e3:	5d                   	pop    %ebp
f01067e4:	c3                   	ret    

f01067e5 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f01067e5:	55                   	push   %ebp
f01067e6:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f01067e8:	83 fa 01             	cmp    $0x1,%edx
f01067eb:	7e 0e                	jle    f01067fb <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f01067ed:	8b 10                	mov    (%eax),%edx
f01067ef:	8d 4a 08             	lea    0x8(%edx),%ecx
f01067f2:	89 08                	mov    %ecx,(%eax)
f01067f4:	8b 02                	mov    (%edx),%eax
f01067f6:	8b 52 04             	mov    0x4(%edx),%edx
f01067f9:	eb 22                	jmp    f010681d <getuint+0x38>
	else if (lflag)
f01067fb:	85 d2                	test   %edx,%edx
f01067fd:	74 10                	je     f010680f <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f01067ff:	8b 10                	mov    (%eax),%edx
f0106801:	8d 4a 04             	lea    0x4(%edx),%ecx
f0106804:	89 08                	mov    %ecx,(%eax)
f0106806:	8b 02                	mov    (%edx),%eax
f0106808:	ba 00 00 00 00       	mov    $0x0,%edx
f010680d:	eb 0e                	jmp    f010681d <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f010680f:	8b 10                	mov    (%eax),%edx
f0106811:	8d 4a 04             	lea    0x4(%edx),%ecx
f0106814:	89 08                	mov    %ecx,(%eax)
f0106816:	8b 02                	mov    (%edx),%eax
f0106818:	ba 00 00 00 00       	mov    $0x0,%edx
}
f010681d:	5d                   	pop    %ebp
f010681e:	c3                   	ret    

f010681f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f010681f:	55                   	push   %ebp
f0106820:	89 e5                	mov    %esp,%ebp
f0106822:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0106825:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0106829:	8b 10                	mov    (%eax),%edx
f010682b:	3b 50 04             	cmp    0x4(%eax),%edx
f010682e:	73 0a                	jae    f010683a <sprintputch+0x1b>
		*b->buf++ = ch;
f0106830:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0106833:	88 0a                	mov    %cl,(%edx)
f0106835:	83 c2 01             	add    $0x1,%edx
f0106838:	89 10                	mov    %edx,(%eax)
}
f010683a:	5d                   	pop    %ebp
f010683b:	c3                   	ret    

f010683c <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f010683c:	55                   	push   %ebp
f010683d:	89 e5                	mov    %esp,%ebp
f010683f:	57                   	push   %edi
f0106840:	56                   	push   %esi
f0106841:	53                   	push   %ebx
f0106842:	83 ec 6c             	sub    $0x6c,%esp
f0106845:	8b 7d 10             	mov    0x10(%ebp),%edi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
f0106848:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
f010684f:	eb 1a                	jmp    f010686b <vprintfmt+0x2f>
	int base, lflag, width, precision, altflag,signflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0106851:	85 c0                	test   %eax,%eax
f0106853:	0f 84 66 06 00 00    	je     f0106ebf <vprintfmt+0x683>
				return;
			putch(ch, putdat);
f0106859:	8b 55 0c             	mov    0xc(%ebp),%edx
f010685c:	89 54 24 04          	mov    %edx,0x4(%esp)
f0106860:	89 04 24             	mov    %eax,(%esp)
f0106863:	ff 55 08             	call   *0x8(%ebp)
f0106866:	eb 03                	jmp    f010686b <vprintfmt+0x2f>
f0106868:	8b 7d e4             	mov    -0x1c(%ebp),%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag,signflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f010686b:	0f b6 07             	movzbl (%edi),%eax
f010686e:	83 c7 01             	add    $0x1,%edi
f0106871:	83 f8 25             	cmp    $0x25,%eax
f0106874:	75 db                	jne    f0106851 <vprintfmt+0x15>
f0106876:	c6 45 cc 20          	movb   $0x20,-0x34(%ebp)
f010687a:	b9 00 00 00 00       	mov    $0x0,%ecx
f010687f:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
f0106886:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f010688b:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
f0106892:	be 00 00 00 00       	mov    $0x0,%esi
f0106897:	eb 06                	jmp    f010689f <vprintfmt+0x63>
f0106899:	c6 45 cc 2d          	movb   $0x2d,-0x34(%ebp)
f010689d:	89 c7                	mov    %eax,%edi
		precision = -1;
		lflag = 0;
		altflag = 0;
                signflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010689f:	0f b6 17             	movzbl (%edi),%edx
f01068a2:	0f b6 c2             	movzbl %dl,%eax
f01068a5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01068a8:	8d 47 01             	lea    0x1(%edi),%eax
f01068ab:	83 ea 23             	sub    $0x23,%edx
f01068ae:	80 fa 55             	cmp    $0x55,%dl
f01068b1:	0f 87 60 05 00 00    	ja     f0106e17 <vprintfmt+0x5db>
f01068b7:	0f b6 d2             	movzbl %dl,%edx
f01068ba:	ff 24 95 60 99 10 f0 	jmp    *-0xfef66a0(,%edx,4)
f01068c1:	b9 01 00 00 00       	mov    $0x1,%ecx
f01068c6:	eb d5                	jmp    f010689d <vprintfmt+0x61>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f01068c8:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f01068cb:	83 eb 30             	sub    $0x30,%ebx
				ch = *fmt;
f01068ce:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
f01068d1:	8d 7a d0             	lea    -0x30(%edx),%edi
f01068d4:	83 ff 09             	cmp    $0x9,%edi
f01068d7:	76 08                	jbe    f01068e1 <vprintfmt+0xa5>
f01068d9:	eb 40                	jmp    f010691b <vprintfmt+0xdf>
f01068db:	c6 45 cc 30          	movb   $0x30,-0x34(%ebp)
                        signflag = 1;
                        goto reswitch;
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
			goto reswitch;
f01068df:	eb bc                	jmp    f010689d <vprintfmt+0x61>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f01068e1:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
f01068e4:	8d 1c 9b             	lea    (%ebx,%ebx,4),%ebx
f01068e7:	8d 5c 5a d0          	lea    -0x30(%edx,%ebx,2),%ebx
				ch = *fmt;
f01068eb:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
f01068ee:	8d 7a d0             	lea    -0x30(%edx),%edi
f01068f1:	83 ff 09             	cmp    $0x9,%edi
f01068f4:	76 eb                	jbe    f01068e1 <vprintfmt+0xa5>
f01068f6:	eb 23                	jmp    f010691b <vprintfmt+0xdf>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f01068f8:	8b 55 14             	mov    0x14(%ebp),%edx
f01068fb:	8d 5a 04             	lea    0x4(%edx),%ebx
f01068fe:	89 5d 14             	mov    %ebx,0x14(%ebp)
f0106901:	8b 1a                	mov    (%edx),%ebx
			goto process_precision;
f0106903:	eb 16                	jmp    f010691b <vprintfmt+0xdf>

		case '.':
			if (width < 0)
f0106905:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0106908:	c1 fa 1f             	sar    $0x1f,%edx
f010690b:	f7 d2                	not    %edx
f010690d:	21 55 d8             	and    %edx,-0x28(%ebp)
f0106910:	eb 8b                	jmp    f010689d <vprintfmt+0x61>
f0106912:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
f0106919:	eb 82                	jmp    f010689d <vprintfmt+0x61>

		process_precision:
			if (width < 0)
f010691b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f010691f:	0f 89 78 ff ff ff    	jns    f010689d <vprintfmt+0x61>
f0106925:	89 5d d8             	mov    %ebx,-0x28(%ebp)
f0106928:	8b 5d c8             	mov    -0x38(%ebp),%ebx
f010692b:	e9 6d ff ff ff       	jmp    f010689d <vprintfmt+0x61>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0106930:	83 c6 01             	add    $0x1,%esi
			goto reswitch;
f0106933:	e9 65 ff ff ff       	jmp    f010689d <vprintfmt+0x61>
f0106938:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f010693b:	8b 45 14             	mov    0x14(%ebp),%eax
f010693e:	8d 50 04             	lea    0x4(%eax),%edx
f0106941:	89 55 14             	mov    %edx,0x14(%ebp)
f0106944:	8b 55 0c             	mov    0xc(%ebp),%edx
f0106947:	89 54 24 04          	mov    %edx,0x4(%esp)
f010694b:	8b 00                	mov    (%eax),%eax
f010694d:	89 04 24             	mov    %eax,(%esp)
f0106950:	ff 55 08             	call   *0x8(%ebp)
f0106953:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;
f0106956:	e9 10 ff ff ff       	jmp    f010686b <vprintfmt+0x2f>
f010695b:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
f010695e:	8b 45 14             	mov    0x14(%ebp),%eax
f0106961:	8d 50 04             	lea    0x4(%eax),%edx
f0106964:	89 55 14             	mov    %edx,0x14(%ebp)
f0106967:	8b 00                	mov    (%eax),%eax
f0106969:	89 c2                	mov    %eax,%edx
f010696b:	c1 fa 1f             	sar    $0x1f,%edx
f010696e:	31 d0                	xor    %edx,%eax
f0106970:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0106972:	83 f8 0f             	cmp    $0xf,%eax
f0106975:	7f 0b                	jg     f0106982 <vprintfmt+0x146>
f0106977:	8b 14 85 c0 9a 10 f0 	mov    -0xfef6540(,%eax,4),%edx
f010697e:	85 d2                	test   %edx,%edx
f0106980:	75 26                	jne    f01069a8 <vprintfmt+0x16c>
				printfmt(putch, putdat, "error %d", err);
f0106982:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0106986:	c7 44 24 08 87 97 10 	movl   $0xf0109787,0x8(%esp)
f010698d:	f0 
f010698e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0106991:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0106995:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0106998:	89 1c 24             	mov    %ebx,(%esp)
f010699b:	e8 a7 05 00 00       	call   f0106f47 <printfmt>
f01069a0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f01069a3:	e9 c3 fe ff ff       	jmp    f010686b <vprintfmt+0x2f>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
f01069a8:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01069ac:	c7 44 24 08 5e 88 10 	movl   $0xf010885e,0x8(%esp)
f01069b3:	f0 
f01069b4:	8b 45 0c             	mov    0xc(%ebp),%eax
f01069b7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01069bb:	8b 55 08             	mov    0x8(%ebp),%edx
f01069be:	89 14 24             	mov    %edx,(%esp)
f01069c1:	e8 81 05 00 00       	call   f0106f47 <printfmt>
f01069c6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01069c9:	e9 9d fe ff ff       	jmp    f010686b <vprintfmt+0x2f>
f01069ce:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01069d1:	89 c7                	mov    %eax,%edi
f01069d3:	89 d9                	mov    %ebx,%ecx
f01069d5:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01069d8:	89 45 c0             	mov    %eax,-0x40(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f01069db:	8b 45 14             	mov    0x14(%ebp),%eax
f01069de:	8d 50 04             	lea    0x4(%eax),%edx
f01069e1:	89 55 14             	mov    %edx,0x14(%ebp)
f01069e4:	8b 30                	mov    (%eax),%esi
f01069e6:	85 f6                	test   %esi,%esi
f01069e8:	75 05                	jne    f01069ef <vprintfmt+0x1b3>
f01069ea:	be 90 97 10 f0       	mov    $0xf0109790,%esi
				p = "(null)";
			if (width > 0 && padc != '-')
f01069ef:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
f01069f3:	7e 06                	jle    f01069fb <vprintfmt+0x1bf>
f01069f5:	80 7d cc 2d          	cmpb   $0x2d,-0x34(%ebp)
f01069f9:	75 10                	jne    f0106a0b <vprintfmt+0x1cf>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01069fb:	0f be 06             	movsbl (%esi),%eax
f01069fe:	85 c0                	test   %eax,%eax
f0106a00:	0f 85 a2 00 00 00    	jne    f0106aa8 <vprintfmt+0x26c>
f0106a06:	e9 92 00 00 00       	jmp    f0106a9d <vprintfmt+0x261>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0106a0b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0106a0f:	89 34 24             	mov    %esi,(%esp)
f0106a12:	e8 54 06 00 00       	call   f010706b <strnlen>
f0106a17:	8b 55 c0             	mov    -0x40(%ebp),%edx
f0106a1a:	29 c2                	sub    %eax,%edx
f0106a1c:	89 55 d8             	mov    %edx,-0x28(%ebp)
f0106a1f:	85 d2                	test   %edx,%edx
f0106a21:	7e d8                	jle    f01069fb <vprintfmt+0x1bf>
					putch(padc, putdat);
f0106a23:	0f be 4d cc          	movsbl -0x34(%ebp),%ecx
f0106a27:	89 5d c0             	mov    %ebx,-0x40(%ebp)
f0106a2a:	89 d3                	mov    %edx,%ebx
f0106a2c:	89 75 d8             	mov    %esi,-0x28(%ebp)
f0106a2f:	89 7d bc             	mov    %edi,-0x44(%ebp)
f0106a32:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0106a35:	89 ce                	mov    %ecx,%esi
f0106a37:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0106a3b:	89 34 24             	mov    %esi,(%esp)
f0106a3e:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0106a41:	83 eb 01             	sub    $0x1,%ebx
f0106a44:	85 db                	test   %ebx,%ebx
f0106a46:	7f ef                	jg     f0106a37 <vprintfmt+0x1fb>
f0106a48:	8b 5d c0             	mov    -0x40(%ebp),%ebx
f0106a4b:	8b 75 d8             	mov    -0x28(%ebp),%esi
f0106a4e:	8b 7d bc             	mov    -0x44(%ebp),%edi
f0106a51:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0106a58:	eb a1                	jmp    f01069fb <vprintfmt+0x1bf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0106a5a:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
f0106a5e:	74 1b                	je     f0106a7b <vprintfmt+0x23f>
f0106a60:	8d 50 e0             	lea    -0x20(%eax),%edx
f0106a63:	83 fa 5e             	cmp    $0x5e,%edx
f0106a66:	76 13                	jbe    f0106a7b <vprintfmt+0x23f>
					putch('?', putdat);
f0106a68:	8b 45 0c             	mov    0xc(%ebp),%eax
f0106a6b:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106a6f:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f0106a76:	ff 55 08             	call   *0x8(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0106a79:	eb 0d                	jmp    f0106a88 <vprintfmt+0x24c>
					putch('?', putdat);
				else
					putch(ch, putdat);
f0106a7b:	8b 55 0c             	mov    0xc(%ebp),%edx
f0106a7e:	89 54 24 04          	mov    %edx,0x4(%esp)
f0106a82:	89 04 24             	mov    %eax,(%esp)
f0106a85:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0106a88:	83 ef 01             	sub    $0x1,%edi
f0106a8b:	0f be 06             	movsbl (%esi),%eax
f0106a8e:	85 c0                	test   %eax,%eax
f0106a90:	74 05                	je     f0106a97 <vprintfmt+0x25b>
f0106a92:	83 c6 01             	add    $0x1,%esi
f0106a95:	eb 1a                	jmp    f0106ab1 <vprintfmt+0x275>
f0106a97:	89 7d d8             	mov    %edi,-0x28(%ebp)
f0106a9a:	8b 7d cc             	mov    -0x34(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0106a9d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0106aa1:	7f 1f                	jg     f0106ac2 <vprintfmt+0x286>
f0106aa3:	e9 c0 fd ff ff       	jmp    f0106868 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0106aa8:	83 c6 01             	add    $0x1,%esi
f0106aab:	89 7d cc             	mov    %edi,-0x34(%ebp)
f0106aae:	8b 7d d8             	mov    -0x28(%ebp),%edi
f0106ab1:	85 db                	test   %ebx,%ebx
f0106ab3:	78 a5                	js     f0106a5a <vprintfmt+0x21e>
f0106ab5:	83 eb 01             	sub    $0x1,%ebx
f0106ab8:	79 a0                	jns    f0106a5a <vprintfmt+0x21e>
f0106aba:	89 7d d8             	mov    %edi,-0x28(%ebp)
f0106abd:	8b 7d cc             	mov    -0x34(%ebp),%edi
f0106ac0:	eb db                	jmp    f0106a9d <vprintfmt+0x261>
f0106ac2:	8b 5d d8             	mov    -0x28(%ebp),%ebx
f0106ac5:	8b 75 0c             	mov    0xc(%ebp),%esi
f0106ac8:	89 7d d8             	mov    %edi,-0x28(%ebp)
f0106acb:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0106ace:	89 74 24 04          	mov    %esi,0x4(%esp)
f0106ad2:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0106ad9:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0106adb:	83 eb 01             	sub    $0x1,%ebx
f0106ade:	85 db                	test   %ebx,%ebx
f0106ae0:	7f ec                	jg     f0106ace <vprintfmt+0x292>
f0106ae2:	8b 7d d8             	mov    -0x28(%ebp),%edi
f0106ae5:	e9 81 fd ff ff       	jmp    f010686b <vprintfmt+0x2f>
f0106aea:	89 45 e4             	mov    %eax,-0x1c(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0106aed:	83 fe 01             	cmp    $0x1,%esi
f0106af0:	7e 10                	jle    f0106b02 <vprintfmt+0x2c6>
		return va_arg(*ap, long long);
f0106af2:	8b 45 14             	mov    0x14(%ebp),%eax
f0106af5:	8d 50 08             	lea    0x8(%eax),%edx
f0106af8:	89 55 14             	mov    %edx,0x14(%ebp)
f0106afb:	8b 18                	mov    (%eax),%ebx
f0106afd:	8b 70 04             	mov    0x4(%eax),%esi
f0106b00:	eb 26                	jmp    f0106b28 <vprintfmt+0x2ec>
	else if (lflag)
f0106b02:	85 f6                	test   %esi,%esi
f0106b04:	74 12                	je     f0106b18 <vprintfmt+0x2dc>
		return va_arg(*ap, long);
f0106b06:	8b 45 14             	mov    0x14(%ebp),%eax
f0106b09:	8d 50 04             	lea    0x4(%eax),%edx
f0106b0c:	89 55 14             	mov    %edx,0x14(%ebp)
f0106b0f:	8b 18                	mov    (%eax),%ebx
f0106b11:	89 de                	mov    %ebx,%esi
f0106b13:	c1 fe 1f             	sar    $0x1f,%esi
f0106b16:	eb 10                	jmp    f0106b28 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
f0106b18:	8b 45 14             	mov    0x14(%ebp),%eax
f0106b1b:	8d 50 04             	lea    0x4(%eax),%edx
f0106b1e:	89 55 14             	mov    %edx,0x14(%ebp)
f0106b21:	8b 18                	mov    (%eax),%ebx
f0106b23:	89 de                	mov    %ebx,%esi
f0106b25:	c1 fe 1f             	sar    $0x1f,%esi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
                        if(signflag == 1){
f0106b28:	83 f9 01             	cmp    $0x1,%ecx
f0106b2b:	75 1e                	jne    f0106b4b <vprintfmt+0x30f>
                               if((long long)num > 0){
f0106b2d:	85 f6                	test   %esi,%esi
f0106b2f:	78 1a                	js     f0106b4b <vprintfmt+0x30f>
f0106b31:	85 f6                	test   %esi,%esi
f0106b33:	7f 05                	jg     f0106b3a <vprintfmt+0x2fe>
f0106b35:	83 fb 00             	cmp    $0x0,%ebx
f0106b38:	76 11                	jbe    f0106b4b <vprintfmt+0x30f>
                                   putch('+',putdat);
f0106b3a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0106b3d:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0106b41:	c7 04 24 2b 00 00 00 	movl   $0x2b,(%esp)
f0106b48:	ff 55 08             	call   *0x8(%ebp)
                               }
                        }
			if ((long long) num < 0) {
f0106b4b:	85 f6                	test   %esi,%esi
f0106b4d:	78 13                	js     f0106b62 <vprintfmt+0x326>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0106b4f:	89 5d b0             	mov    %ebx,-0x50(%ebp)
f0106b52:	89 75 b4             	mov    %esi,-0x4c(%ebp)
f0106b55:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0106b58:	b8 0a 00 00 00       	mov    $0xa,%eax
f0106b5d:	e9 da 00 00 00       	jmp    f0106c3c <vprintfmt+0x400>
                               if((long long)num > 0){
                                   putch('+',putdat);
                               }
                        }
			if ((long long) num < 0) {
				putch('-', putdat);
f0106b62:	8b 45 0c             	mov    0xc(%ebp),%eax
f0106b65:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106b69:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f0106b70:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f0106b73:	89 da                	mov    %ebx,%edx
f0106b75:	89 f1                	mov    %esi,%ecx
f0106b77:	f7 da                	neg    %edx
f0106b79:	83 d1 00             	adc    $0x0,%ecx
f0106b7c:	f7 d9                	neg    %ecx
f0106b7e:	89 55 b0             	mov    %edx,-0x50(%ebp)
f0106b81:	89 4d b4             	mov    %ecx,-0x4c(%ebp)
f0106b84:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0106b87:	b8 0a 00 00 00       	mov    $0xa,%eax
f0106b8c:	e9 ab 00 00 00       	jmp    f0106c3c <vprintfmt+0x400>
f0106b91:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0106b94:	89 f2                	mov    %esi,%edx
f0106b96:	8d 45 14             	lea    0x14(%ebp),%eax
f0106b99:	e8 47 fc ff ff       	call   f01067e5 <getuint>
f0106b9e:	89 45 b0             	mov    %eax,-0x50(%ebp)
f0106ba1:	89 55 b4             	mov    %edx,-0x4c(%ebp)
f0106ba4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0106ba7:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
f0106bac:	e9 8b 00 00 00       	jmp    f0106c3c <vprintfmt+0x400>
f0106bb1:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			putch('0', putdat);
f0106bb4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0106bb7:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0106bbb:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f0106bc2:	ff 55 08             	call   *0x8(%ebp)
			num = getuint(&ap,lflag);
f0106bc5:	89 f2                	mov    %esi,%edx
f0106bc7:	8d 45 14             	lea    0x14(%ebp),%eax
f0106bca:	e8 16 fc ff ff       	call   f01067e5 <getuint>
f0106bcf:	89 45 b0             	mov    %eax,-0x50(%ebp)
f0106bd2:	89 55 b4             	mov    %edx,-0x4c(%ebp)
f0106bd5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0106bd8:	b8 08 00 00 00       	mov    $0x8,%eax
                        base = 8;
			goto number;
f0106bdd:	eb 5d                	jmp    f0106c3c <vprintfmt+0x400>
f0106bdf:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
f0106be2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0106be5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0106be9:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f0106bf0:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f0106bf3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0106bf7:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f0106bfe:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
f0106c01:	8b 45 14             	mov    0x14(%ebp),%eax
f0106c04:	8d 50 04             	lea    0x4(%eax),%edx
f0106c07:	89 55 14             	mov    %edx,0x14(%ebp)
f0106c0a:	8b 10                	mov    (%eax),%edx
f0106c0c:	b9 00 00 00 00       	mov    $0x0,%ecx
f0106c11:	89 55 b0             	mov    %edx,-0x50(%ebp)
f0106c14:	89 4d b4             	mov    %ecx,-0x4c(%ebp)
f0106c17:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0106c1a:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f0106c1f:	eb 1b                	jmp    f0106c3c <vprintfmt+0x400>
f0106c21:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0106c24:	89 f2                	mov    %esi,%edx
f0106c26:	8d 45 14             	lea    0x14(%ebp),%eax
f0106c29:	e8 b7 fb ff ff       	call   f01067e5 <getuint>
f0106c2e:	89 45 b0             	mov    %eax,-0x50(%ebp)
f0106c31:	89 55 b4             	mov    %edx,-0x4c(%ebp)
f0106c34:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0106c37:	b8 10 00 00 00       	mov    $0x10,%eax
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
f0106c3c:	0f be 4d cc          	movsbl -0x34(%ebp),%ecx
f0106c40:	89 4d d0             	mov    %ecx,-0x30(%ebp)
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0106c43:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0106c46:	83 7d b4 00          	cmpl   $0x0,-0x4c(%ebp)
f0106c4a:	77 09                	ja     f0106c55 <vprintfmt+0x419>
f0106c4c:	39 45 b0             	cmp    %eax,-0x50(%ebp)
f0106c4f:	0f 82 ac 00 00 00    	jb     f0106d01 <vprintfmt+0x4c5>
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
f0106c55:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0106c58:	89 5c 24 10          	mov    %ebx,0x10(%esp)
f0106c5c:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0106c5f:	83 ea 01             	sub    $0x1,%edx
f0106c62:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0106c66:	89 44 24 08          	mov    %eax,0x8(%esp)
f0106c6a:	8b 44 24 08          	mov    0x8(%esp),%eax
f0106c6e:	8b 54 24 0c          	mov    0xc(%esp),%edx
f0106c72:	89 45 c0             	mov    %eax,-0x40(%ebp)
f0106c75:	89 55 c4             	mov    %edx,-0x3c(%ebp)
f0106c78:	8b 55 cc             	mov    -0x34(%ebp),%edx
f0106c7b:	89 54 24 08          	mov    %edx,0x8(%esp)
f0106c7f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0106c86:	00 
f0106c87:	8b 4d b0             	mov    -0x50(%ebp),%ecx
f0106c8a:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
f0106c8d:	89 0c 24             	mov    %ecx,(%esp)
f0106c90:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0106c94:	e8 d7 10 00 00       	call   f0107d70 <__udivdi3>
f0106c99:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f0106c9c:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0106c9f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0106ca3:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0106ca7:	89 04 24             	mov    %eax,(%esp)
f0106caa:	89 54 24 04          	mov    %edx,0x4(%esp)
f0106cae:	8b 55 0c             	mov    0xc(%ebp),%edx
f0106cb1:	8b 45 08             	mov    0x8(%ebp),%eax
f0106cb4:	e8 37 fa ff ff       	call   f01066f0 <printnum_v2>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0106cb9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0106cbc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0106cc0:	8b 74 24 04          	mov    0x4(%esp),%esi
f0106cc4:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0106cc7:	89 44 24 08          	mov    %eax,0x8(%esp)
f0106ccb:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0106cd2:	00 
f0106cd3:	8b 55 b0             	mov    -0x50(%ebp),%edx
f0106cd6:	8b 4d b4             	mov    -0x4c(%ebp),%ecx
f0106cd9:	89 14 24             	mov    %edx,(%esp)
f0106cdc:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0106ce0:	e8 bb 11 00 00       	call   f0107ea0 <__umoddi3>
f0106ce5:	89 74 24 04          	mov    %esi,0x4(%esp)
f0106ce9:	0f be 80 76 97 10 f0 	movsbl -0xfef688a(%eax),%eax
f0106cf0:	89 04 24             	mov    %eax,(%esp)
f0106cf3:	ff 55 08             	call   *0x8(%ebp)
        if(padc == '-'){
f0106cf6:	83 7d d0 2d          	cmpl   $0x2d,-0x30(%ebp)
f0106cfa:	74 54                	je     f0106d50 <vprintfmt+0x514>
f0106cfc:	e9 67 fb ff ff       	jmp    f0106868 <vprintfmt+0x2c>
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
f0106d01:	83 7d d0 2d          	cmpl   $0x2d,-0x30(%ebp)
f0106d05:	8d 76 00             	lea    0x0(%esi),%esi
f0106d08:	0f 84 2a 01 00 00    	je     f0106e38 <vprintfmt+0x5fc>
		while (--width > 0)
f0106d0e:	8b 7d d8             	mov    -0x28(%ebp),%edi
f0106d11:	83 ef 01             	sub    $0x1,%edi
f0106d14:	85 ff                	test   %edi,%edi
f0106d16:	0f 8e 5e 01 00 00    	jle    f0106e7a <vprintfmt+0x63e>
f0106d1c:	8b 4d b0             	mov    -0x50(%ebp),%ecx
f0106d1f:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
f0106d22:	89 4d d8             	mov    %ecx,-0x28(%ebp)
f0106d25:	89 5d dc             	mov    %ebx,-0x24(%ebp)
f0106d28:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0106d2b:	8b 75 0c             	mov    0xc(%ebp),%esi
			putch(padc, putdat);
f0106d2e:	89 74 24 04          	mov    %esi,0x4(%esp)
f0106d32:	89 1c 24             	mov    %ebx,(%esp)
f0106d35:	ff 55 08             	call   *0x8(%ebp)
	if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
		while (--width > 0)
f0106d38:	83 ef 01             	sub    $0x1,%edi
f0106d3b:	85 ff                	test   %edi,%edi
f0106d3d:	7f ef                	jg     f0106d2e <vprintfmt+0x4f2>
f0106d3f:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0106d42:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0106d45:	89 45 b0             	mov    %eax,-0x50(%ebp)
f0106d48:	89 55 b4             	mov    %edx,-0x4c(%ebp)
f0106d4b:	e9 2a 01 00 00       	jmp    f0106e7a <vprintfmt+0x63e>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
        if(padc == '-'){
           while (--width > 0)
f0106d50:	8b 5d d8             	mov    -0x28(%ebp),%ebx
f0106d53:	83 eb 01             	sub    $0x1,%ebx
f0106d56:	85 db                	test   %ebx,%ebx
f0106d58:	0f 8e 0a fb ff ff    	jle    f0106868 <vprintfmt+0x2c>
f0106d5e:	8b 75 0c             	mov    0xc(%ebp),%esi
f0106d61:	89 7d d8             	mov    %edi,-0x28(%ebp)
f0106d64:	8b 7d 08             	mov    0x8(%ebp),%edi
			putch(' ', putdat);
f0106d67:	89 74 24 04          	mov    %esi,0x4(%esp)
f0106d6b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0106d72:	ff d7                	call   *%edi
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
        if(padc == '-'){
           while (--width > 0)
f0106d74:	83 eb 01             	sub    $0x1,%ebx
f0106d77:	85 db                	test   %ebx,%ebx
f0106d79:	7f ec                	jg     f0106d67 <vprintfmt+0x52b>
f0106d7b:	8b 7d d8             	mov    -0x28(%ebp),%edi
f0106d7e:	e9 e8 fa ff ff       	jmp    f010686b <vprintfmt+0x2f>
f0106d83:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
            char* n;
            if ((n = va_arg(ap, char *)) == NULL)
f0106d86:	8b 45 14             	mov    0x14(%ebp),%eax
f0106d89:	8d 50 04             	lea    0x4(%eax),%edx
f0106d8c:	89 55 14             	mov    %edx,0x14(%ebp)
f0106d8f:	8b 00                	mov    (%eax),%eax
f0106d91:	85 c0                	test   %eax,%eax
f0106d93:	75 2a                	jne    f0106dbf <vprintfmt+0x583>
		  printfmt(putch,putdat,"%s",null_error);
f0106d95:	c7 44 24 0c ac 98 10 	movl   $0xf01098ac,0xc(%esp)
f0106d9c:	f0 
f0106d9d:	c7 44 24 08 5e 88 10 	movl   $0xf010885e,0x8(%esp)
f0106da4:	f0 
f0106da5:	8b 55 0c             	mov    0xc(%ebp),%edx
f0106da8:	89 54 24 04          	mov    %edx,0x4(%esp)
f0106dac:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0106daf:	89 0c 24             	mov    %ecx,(%esp)
f0106db2:	e8 90 01 00 00       	call   f0106f47 <printfmt>
f0106db7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0106dba:	e9 ac fa ff ff       	jmp    f010686b <vprintfmt+0x2f>
            else if((*(int*)putdat) > 127){
f0106dbf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0106dc2:	8b 13                	mov    (%ebx),%edx
f0106dc4:	83 fa 7f             	cmp    $0x7f,%edx
f0106dc7:	7e 29                	jle    f0106df2 <vprintfmt+0x5b6>
                  *n = *(int*)putdat;
f0106dc9:	88 10                	mov    %dl,(%eax)
                  printfmt(putch,putdat,"%s",overflow_error);
f0106dcb:	c7 44 24 0c e4 98 10 	movl   $0xf01098e4,0xc(%esp)
f0106dd2:	f0 
f0106dd3:	c7 44 24 08 5e 88 10 	movl   $0xf010885e,0x8(%esp)
f0106dda:	f0 
f0106ddb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0106ddf:	8b 45 08             	mov    0x8(%ebp),%eax
f0106de2:	89 04 24             	mov    %eax,(%esp)
f0106de5:	e8 5d 01 00 00       	call   f0106f47 <printfmt>
f0106dea:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0106ded:	e9 79 fa ff ff       	jmp    f010686b <vprintfmt+0x2f>
            }
            else
                  *n = *(int*)putdat;
f0106df2:	88 10                	mov    %dl,(%eax)
f0106df4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0106df7:	e9 6f fa ff ff       	jmp    f010686b <vprintfmt+0x2f>
f0106dfc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0106dff:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            break;
        }
		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0106e02:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0106e05:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0106e09:	89 14 24             	mov    %edx,(%esp)
f0106e0c:	ff 55 08             	call   *0x8(%ebp)
f0106e0f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;
f0106e12:	e9 54 fa ff ff       	jmp    f010686b <vprintfmt+0x2f>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0106e17:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0106e1a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0106e1e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f0106e25:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f0106e28:	8d 47 ff             	lea    -0x1(%edi),%eax
f0106e2b:	80 38 25             	cmpb   $0x25,(%eax)
f0106e2e:	0f 84 37 fa ff ff    	je     f010686b <vprintfmt+0x2f>
f0106e34:	89 c7                	mov    %eax,%edi
f0106e36:	eb f0                	jmp    f0106e28 <vprintfmt+0x5ec>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0106e38:	8b 45 0c             	mov    0xc(%ebp),%eax
f0106e3b:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106e3f:	8b 74 24 04          	mov    0x4(%esp),%esi
f0106e43:	8b 55 cc             	mov    -0x34(%ebp),%edx
f0106e46:	89 54 24 08          	mov    %edx,0x8(%esp)
f0106e4a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0106e51:	00 
f0106e52:	8b 45 b0             	mov    -0x50(%ebp),%eax
f0106e55:	8b 55 b4             	mov    -0x4c(%ebp),%edx
f0106e58:	89 04 24             	mov    %eax,(%esp)
f0106e5b:	89 54 24 04          	mov    %edx,0x4(%esp)
f0106e5f:	e8 3c 10 00 00       	call   f0107ea0 <__umoddi3>
f0106e64:	89 74 24 04          	mov    %esi,0x4(%esp)
f0106e68:	0f be 80 76 97 10 f0 	movsbl -0xfef688a(%eax),%eax
f0106e6f:	89 04 24             	mov    %eax,(%esp)
f0106e72:	ff 55 08             	call   *0x8(%ebp)
f0106e75:	e9 d6 fe ff ff       	jmp    f0106d50 <vprintfmt+0x514>
f0106e7a:	8b 55 0c             	mov    0xc(%ebp),%edx
f0106e7d:	89 54 24 04          	mov    %edx,0x4(%esp)
f0106e81:	8b 74 24 04          	mov    0x4(%esp),%esi
f0106e85:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0106e88:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0106e8c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0106e93:	00 
f0106e94:	8b 45 b0             	mov    -0x50(%ebp),%eax
f0106e97:	8b 55 b4             	mov    -0x4c(%ebp),%edx
f0106e9a:	89 04 24             	mov    %eax,(%esp)
f0106e9d:	89 54 24 04          	mov    %edx,0x4(%esp)
f0106ea1:	e8 fa 0f 00 00       	call   f0107ea0 <__umoddi3>
f0106ea6:	89 74 24 04          	mov    %esi,0x4(%esp)
f0106eaa:	0f be 80 76 97 10 f0 	movsbl -0xfef688a(%eax),%eax
f0106eb1:	89 04 24             	mov    %eax,(%esp)
f0106eb4:	ff 55 08             	call   *0x8(%ebp)
f0106eb7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0106eba:	e9 ac f9 ff ff       	jmp    f010686b <vprintfmt+0x2f>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
f0106ebf:	83 c4 6c             	add    $0x6c,%esp
f0106ec2:	5b                   	pop    %ebx
f0106ec3:	5e                   	pop    %esi
f0106ec4:	5f                   	pop    %edi
f0106ec5:	5d                   	pop    %ebp
f0106ec6:	c3                   	ret    

f0106ec7 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0106ec7:	55                   	push   %ebp
f0106ec8:	89 e5                	mov    %esp,%ebp
f0106eca:	83 ec 28             	sub    $0x28,%esp
f0106ecd:	8b 45 08             	mov    0x8(%ebp),%eax
f0106ed0:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
f0106ed3:	85 c0                	test   %eax,%eax
f0106ed5:	74 04                	je     f0106edb <vsnprintf+0x14>
f0106ed7:	85 d2                	test   %edx,%edx
f0106ed9:	7f 07                	jg     f0106ee2 <vsnprintf+0x1b>
f0106edb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0106ee0:	eb 3b                	jmp    f0106f1d <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
f0106ee2:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0106ee5:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
f0106ee9:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0106eec:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0106ef3:	8b 45 14             	mov    0x14(%ebp),%eax
f0106ef6:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0106efa:	8b 45 10             	mov    0x10(%ebp),%eax
f0106efd:	89 44 24 08          	mov    %eax,0x8(%esp)
f0106f01:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0106f04:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106f08:	c7 04 24 1f 68 10 f0 	movl   $0xf010681f,(%esp)
f0106f0f:	e8 28 f9 ff ff       	call   f010683c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0106f14:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0106f17:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0106f1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
f0106f1d:	c9                   	leave  
f0106f1e:	c3                   	ret    

f0106f1f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0106f1f:	55                   	push   %ebp
f0106f20:	89 e5                	mov    %esp,%ebp
f0106f22:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
f0106f25:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
f0106f28:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0106f2c:	8b 45 10             	mov    0x10(%ebp),%eax
f0106f2f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0106f33:	8b 45 0c             	mov    0xc(%ebp),%eax
f0106f36:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106f3a:	8b 45 08             	mov    0x8(%ebp),%eax
f0106f3d:	89 04 24             	mov    %eax,(%esp)
f0106f40:	e8 82 ff ff ff       	call   f0106ec7 <vsnprintf>
	va_end(ap);

	return rc;
}
f0106f45:	c9                   	leave  
f0106f46:	c3                   	ret    

f0106f47 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0106f47:	55                   	push   %ebp
f0106f48:	89 e5                	mov    %esp,%ebp
f0106f4a:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
f0106f4d:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
f0106f50:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0106f54:	8b 45 10             	mov    0x10(%ebp),%eax
f0106f57:	89 44 24 08          	mov    %eax,0x8(%esp)
f0106f5b:	8b 45 0c             	mov    0xc(%ebp),%eax
f0106f5e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106f62:	8b 45 08             	mov    0x8(%ebp),%eax
f0106f65:	89 04 24             	mov    %eax,(%esp)
f0106f68:	e8 cf f8 ff ff       	call   f010683c <vprintfmt>
	va_end(ap);
}
f0106f6d:	c9                   	leave  
f0106f6e:	c3                   	ret    
	...

f0106f70 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0106f70:	55                   	push   %ebp
f0106f71:	89 e5                	mov    %esp,%ebp
f0106f73:	57                   	push   %edi
f0106f74:	56                   	push   %esi
f0106f75:	53                   	push   %ebx
f0106f76:	83 ec 1c             	sub    $0x1c,%esp
f0106f79:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0106f7c:	85 c0                	test   %eax,%eax
f0106f7e:	74 10                	je     f0106f90 <readline+0x20>
		cprintf("%s", prompt);
f0106f80:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106f84:	c7 04 24 5e 88 10 f0 	movl   $0xf010885e,(%esp)
f0106f8b:	e8 2f db ff ff       	call   f0104abf <cprintf>

	i = 0;
	echoing = iscons(0);
f0106f90:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0106f97:	e8 8a 95 ff ff       	call   f0100526 <iscons>
f0106f9c:	89 c7                	mov    %eax,%edi
f0106f9e:	be 00 00 00 00       	mov    $0x0,%esi
	while (1) {
		c = getchar();
f0106fa3:	e8 6d 95 ff ff       	call   f0100515 <getchar>
f0106fa8:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0106faa:	85 c0                	test   %eax,%eax
f0106fac:	79 17                	jns    f0106fc5 <readline+0x55>
			cprintf("read error: %e\n", c);
f0106fae:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106fb2:	c7 04 24 00 9b 10 f0 	movl   $0xf0109b00,(%esp)
f0106fb9:	e8 01 db ff ff       	call   f0104abf <cprintf>
f0106fbe:	b8 00 00 00 00       	mov    $0x0,%eax
			return NULL;
f0106fc3:	eb 76                	jmp    f010703b <readline+0xcb>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0106fc5:	83 f8 08             	cmp    $0x8,%eax
f0106fc8:	74 08                	je     f0106fd2 <readline+0x62>
f0106fca:	83 f8 7f             	cmp    $0x7f,%eax
f0106fcd:	8d 76 00             	lea    0x0(%esi),%esi
f0106fd0:	75 19                	jne    f0106feb <readline+0x7b>
f0106fd2:	85 f6                	test   %esi,%esi
f0106fd4:	7e 15                	jle    f0106feb <readline+0x7b>
			if (echoing)
f0106fd6:	85 ff                	test   %edi,%edi
f0106fd8:	74 0c                	je     f0106fe6 <readline+0x76>
				cputchar('\b');
f0106fda:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
f0106fe1:	e8 44 97 ff ff       	call   f010072a <cputchar>
			i--;
f0106fe6:	83 ee 01             	sub    $0x1,%esi
	while (1) {
		c = getchar();
		if (c < 0) {
			cprintf("read error: %e\n", c);
			return NULL;
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0106fe9:	eb b8                	jmp    f0106fa3 <readline+0x33>
			if (echoing)
				cputchar('\b');
			i--;
		} else if (c >= ' ' && i < BUFLEN-1) {
f0106feb:	83 fb 1f             	cmp    $0x1f,%ebx
f0106fee:	66 90                	xchg   %ax,%ax
f0106ff0:	7e 23                	jle    f0107015 <readline+0xa5>
f0106ff2:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0106ff8:	7f 1b                	jg     f0107015 <readline+0xa5>
			if (echoing)
f0106ffa:	85 ff                	test   %edi,%edi
f0106ffc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0107000:	74 08                	je     f010700a <readline+0x9a>
				cputchar(c);
f0107002:	89 1c 24             	mov    %ebx,(%esp)
f0107005:	e8 20 97 ff ff       	call   f010072a <cputchar>
			buf[i++] = c;
f010700a:	88 9e a0 0a 1f f0    	mov    %bl,-0xfe0f560(%esi)
f0107010:	83 c6 01             	add    $0x1,%esi
f0107013:	eb 8e                	jmp    f0106fa3 <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f0107015:	83 fb 0a             	cmp    $0xa,%ebx
f0107018:	74 05                	je     f010701f <readline+0xaf>
f010701a:	83 fb 0d             	cmp    $0xd,%ebx
f010701d:	75 84                	jne    f0106fa3 <readline+0x33>
			if (echoing)
f010701f:	85 ff                	test   %edi,%edi
f0107021:	74 0c                	je     f010702f <readline+0xbf>
				cputchar('\n');
f0107023:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
f010702a:	e8 fb 96 ff ff       	call   f010072a <cputchar>
			buf[i] = 0;
f010702f:	c6 86 a0 0a 1f f0 00 	movb   $0x0,-0xfe0f560(%esi)
f0107036:	b8 a0 0a 1f f0       	mov    $0xf01f0aa0,%eax
			return buf;
		}
	}
}
f010703b:	83 c4 1c             	add    $0x1c,%esp
f010703e:	5b                   	pop    %ebx
f010703f:	5e                   	pop    %esi
f0107040:	5f                   	pop    %edi
f0107041:	5d                   	pop    %ebp
f0107042:	c3                   	ret    
	...

f0107050 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0107050:	55                   	push   %ebp
f0107051:	89 e5                	mov    %esp,%ebp
f0107053:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0107056:	b8 00 00 00 00       	mov    $0x0,%eax
f010705b:	80 3a 00             	cmpb   $0x0,(%edx)
f010705e:	74 09                	je     f0107069 <strlen+0x19>
		n++;
f0107060:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0107063:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0107067:	75 f7                	jne    f0107060 <strlen+0x10>
		n++;
	return n;
}
f0107069:	5d                   	pop    %ebp
f010706a:	c3                   	ret    

f010706b <strnlen>:

int
strnlen(const char *s, size_t size)
{
f010706b:	55                   	push   %ebp
f010706c:	89 e5                	mov    %esp,%ebp
f010706e:	53                   	push   %ebx
f010706f:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0107072:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0107075:	85 c9                	test   %ecx,%ecx
f0107077:	74 19                	je     f0107092 <strnlen+0x27>
f0107079:	80 3b 00             	cmpb   $0x0,(%ebx)
f010707c:	74 14                	je     f0107092 <strnlen+0x27>
f010707e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
f0107083:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0107086:	39 c8                	cmp    %ecx,%eax
f0107088:	74 0d                	je     f0107097 <strnlen+0x2c>
f010708a:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
f010708e:	75 f3                	jne    f0107083 <strnlen+0x18>
f0107090:	eb 05                	jmp    f0107097 <strnlen+0x2c>
f0107092:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
f0107097:	5b                   	pop    %ebx
f0107098:	5d                   	pop    %ebp
f0107099:	c3                   	ret    

f010709a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f010709a:	55                   	push   %ebp
f010709b:	89 e5                	mov    %esp,%ebp
f010709d:	53                   	push   %ebx
f010709e:	8b 45 08             	mov    0x8(%ebp),%eax
f01070a1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01070a4:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f01070a9:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
f01070ad:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f01070b0:	83 c2 01             	add    $0x1,%edx
f01070b3:	84 c9                	test   %cl,%cl
f01070b5:	75 f2                	jne    f01070a9 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f01070b7:	5b                   	pop    %ebx
f01070b8:	5d                   	pop    %ebp
f01070b9:	c3                   	ret    

f01070ba <strcat>:

char *
strcat(char *dst, const char *src)
{
f01070ba:	55                   	push   %ebp
f01070bb:	89 e5                	mov    %esp,%ebp
f01070bd:	53                   	push   %ebx
f01070be:	83 ec 08             	sub    $0x8,%esp
f01070c1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f01070c4:	89 1c 24             	mov    %ebx,(%esp)
f01070c7:	e8 84 ff ff ff       	call   f0107050 <strlen>
	strcpy(dst + len, src);
f01070cc:	8b 55 0c             	mov    0xc(%ebp),%edx
f01070cf:	89 54 24 04          	mov    %edx,0x4(%esp)
f01070d3:	8d 04 03             	lea    (%ebx,%eax,1),%eax
f01070d6:	89 04 24             	mov    %eax,(%esp)
f01070d9:	e8 bc ff ff ff       	call   f010709a <strcpy>
	return dst;
}
f01070de:	89 d8                	mov    %ebx,%eax
f01070e0:	83 c4 08             	add    $0x8,%esp
f01070e3:	5b                   	pop    %ebx
f01070e4:	5d                   	pop    %ebp
f01070e5:	c3                   	ret    

f01070e6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f01070e6:	55                   	push   %ebp
f01070e7:	89 e5                	mov    %esp,%ebp
f01070e9:	56                   	push   %esi
f01070ea:	53                   	push   %ebx
f01070eb:	8b 45 08             	mov    0x8(%ebp),%eax
f01070ee:	8b 55 0c             	mov    0xc(%ebp),%edx
f01070f1:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01070f4:	85 f6                	test   %esi,%esi
f01070f6:	74 18                	je     f0107110 <strncpy+0x2a>
f01070f8:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
f01070fd:	0f b6 1a             	movzbl (%edx),%ebx
f0107100:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0107103:	80 3a 01             	cmpb   $0x1,(%edx)
f0107106:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0107109:	83 c1 01             	add    $0x1,%ecx
f010710c:	39 ce                	cmp    %ecx,%esi
f010710e:	77 ed                	ja     f01070fd <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0107110:	5b                   	pop    %ebx
f0107111:	5e                   	pop    %esi
f0107112:	5d                   	pop    %ebp
f0107113:	c3                   	ret    

f0107114 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0107114:	55                   	push   %ebp
f0107115:	89 e5                	mov    %esp,%ebp
f0107117:	56                   	push   %esi
f0107118:	53                   	push   %ebx
f0107119:	8b 75 08             	mov    0x8(%ebp),%esi
f010711c:	8b 55 0c             	mov    0xc(%ebp),%edx
f010711f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0107122:	89 f0                	mov    %esi,%eax
f0107124:	85 c9                	test   %ecx,%ecx
f0107126:	74 27                	je     f010714f <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
f0107128:	83 e9 01             	sub    $0x1,%ecx
f010712b:	74 1d                	je     f010714a <strlcpy+0x36>
f010712d:	0f b6 1a             	movzbl (%edx),%ebx
f0107130:	84 db                	test   %bl,%bl
f0107132:	74 16                	je     f010714a <strlcpy+0x36>
			*dst++ = *src++;
f0107134:	88 18                	mov    %bl,(%eax)
f0107136:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0107139:	83 e9 01             	sub    $0x1,%ecx
f010713c:	74 0e                	je     f010714c <strlcpy+0x38>
			*dst++ = *src++;
f010713e:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0107141:	0f b6 1a             	movzbl (%edx),%ebx
f0107144:	84 db                	test   %bl,%bl
f0107146:	75 ec                	jne    f0107134 <strlcpy+0x20>
f0107148:	eb 02                	jmp    f010714c <strlcpy+0x38>
f010714a:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
f010714c:	c6 00 00             	movb   $0x0,(%eax)
f010714f:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
f0107151:	5b                   	pop    %ebx
f0107152:	5e                   	pop    %esi
f0107153:	5d                   	pop    %ebp
f0107154:	c3                   	ret    

f0107155 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0107155:	55                   	push   %ebp
f0107156:	89 e5                	mov    %esp,%ebp
f0107158:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010715b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f010715e:	0f b6 01             	movzbl (%ecx),%eax
f0107161:	84 c0                	test   %al,%al
f0107163:	74 15                	je     f010717a <strcmp+0x25>
f0107165:	3a 02                	cmp    (%edx),%al
f0107167:	75 11                	jne    f010717a <strcmp+0x25>
		p++, q++;
f0107169:	83 c1 01             	add    $0x1,%ecx
f010716c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f010716f:	0f b6 01             	movzbl (%ecx),%eax
f0107172:	84 c0                	test   %al,%al
f0107174:	74 04                	je     f010717a <strcmp+0x25>
f0107176:	3a 02                	cmp    (%edx),%al
f0107178:	74 ef                	je     f0107169 <strcmp+0x14>
f010717a:	0f b6 c0             	movzbl %al,%eax
f010717d:	0f b6 12             	movzbl (%edx),%edx
f0107180:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0107182:	5d                   	pop    %ebp
f0107183:	c3                   	ret    

f0107184 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0107184:	55                   	push   %ebp
f0107185:	89 e5                	mov    %esp,%ebp
f0107187:	53                   	push   %ebx
f0107188:	8b 55 08             	mov    0x8(%ebp),%edx
f010718b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010718e:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
f0107191:	85 c0                	test   %eax,%eax
f0107193:	74 23                	je     f01071b8 <strncmp+0x34>
f0107195:	0f b6 1a             	movzbl (%edx),%ebx
f0107198:	84 db                	test   %bl,%bl
f010719a:	74 25                	je     f01071c1 <strncmp+0x3d>
f010719c:	3a 19                	cmp    (%ecx),%bl
f010719e:	75 21                	jne    f01071c1 <strncmp+0x3d>
f01071a0:	83 e8 01             	sub    $0x1,%eax
f01071a3:	74 13                	je     f01071b8 <strncmp+0x34>
		n--, p++, q++;
f01071a5:	83 c2 01             	add    $0x1,%edx
f01071a8:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f01071ab:	0f b6 1a             	movzbl (%edx),%ebx
f01071ae:	84 db                	test   %bl,%bl
f01071b0:	74 0f                	je     f01071c1 <strncmp+0x3d>
f01071b2:	3a 19                	cmp    (%ecx),%bl
f01071b4:	74 ea                	je     f01071a0 <strncmp+0x1c>
f01071b6:	eb 09                	jmp    f01071c1 <strncmp+0x3d>
f01071b8:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f01071bd:	5b                   	pop    %ebx
f01071be:	5d                   	pop    %ebp
f01071bf:	90                   	nop
f01071c0:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f01071c1:	0f b6 02             	movzbl (%edx),%eax
f01071c4:	0f b6 11             	movzbl (%ecx),%edx
f01071c7:	29 d0                	sub    %edx,%eax
f01071c9:	eb f2                	jmp    f01071bd <strncmp+0x39>

f01071cb <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f01071cb:	55                   	push   %ebp
f01071cc:	89 e5                	mov    %esp,%ebp
f01071ce:	8b 45 08             	mov    0x8(%ebp),%eax
f01071d1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01071d5:	0f b6 10             	movzbl (%eax),%edx
f01071d8:	84 d2                	test   %dl,%dl
f01071da:	74 18                	je     f01071f4 <strchr+0x29>
		if (*s == c)
f01071dc:	38 ca                	cmp    %cl,%dl
f01071de:	75 0a                	jne    f01071ea <strchr+0x1f>
f01071e0:	eb 17                	jmp    f01071f9 <strchr+0x2e>
f01071e2:	38 ca                	cmp    %cl,%dl
f01071e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01071e8:	74 0f                	je     f01071f9 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f01071ea:	83 c0 01             	add    $0x1,%eax
f01071ed:	0f b6 10             	movzbl (%eax),%edx
f01071f0:	84 d2                	test   %dl,%dl
f01071f2:	75 ee                	jne    f01071e2 <strchr+0x17>
f01071f4:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
f01071f9:	5d                   	pop    %ebp
f01071fa:	c3                   	ret    

f01071fb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f01071fb:	55                   	push   %ebp
f01071fc:	89 e5                	mov    %esp,%ebp
f01071fe:	8b 45 08             	mov    0x8(%ebp),%eax
f0107201:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0107205:	0f b6 10             	movzbl (%eax),%edx
f0107208:	84 d2                	test   %dl,%dl
f010720a:	74 18                	je     f0107224 <strfind+0x29>
		if (*s == c)
f010720c:	38 ca                	cmp    %cl,%dl
f010720e:	75 0a                	jne    f010721a <strfind+0x1f>
f0107210:	eb 12                	jmp    f0107224 <strfind+0x29>
f0107212:	38 ca                	cmp    %cl,%dl
f0107214:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0107218:	74 0a                	je     f0107224 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f010721a:	83 c0 01             	add    $0x1,%eax
f010721d:	0f b6 10             	movzbl (%eax),%edx
f0107220:	84 d2                	test   %dl,%dl
f0107222:	75 ee                	jne    f0107212 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
f0107224:	5d                   	pop    %ebp
f0107225:	c3                   	ret    

f0107226 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0107226:	55                   	push   %ebp
f0107227:	89 e5                	mov    %esp,%ebp
f0107229:	83 ec 0c             	sub    $0xc,%esp
f010722c:	89 1c 24             	mov    %ebx,(%esp)
f010722f:	89 74 24 04          	mov    %esi,0x4(%esp)
f0107233:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0107237:	8b 7d 08             	mov    0x8(%ebp),%edi
f010723a:	8b 45 0c             	mov    0xc(%ebp),%eax
f010723d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0107240:	85 c9                	test   %ecx,%ecx
f0107242:	74 30                	je     f0107274 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0107244:	f7 c7 03 00 00 00    	test   $0x3,%edi
f010724a:	75 25                	jne    f0107271 <memset+0x4b>
f010724c:	f6 c1 03             	test   $0x3,%cl
f010724f:	75 20                	jne    f0107271 <memset+0x4b>
		c &= 0xFF;
f0107251:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0107254:	89 d3                	mov    %edx,%ebx
f0107256:	c1 e3 08             	shl    $0x8,%ebx
f0107259:	89 d6                	mov    %edx,%esi
f010725b:	c1 e6 18             	shl    $0x18,%esi
f010725e:	89 d0                	mov    %edx,%eax
f0107260:	c1 e0 10             	shl    $0x10,%eax
f0107263:	09 f0                	or     %esi,%eax
f0107265:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
f0107267:	09 d8                	or     %ebx,%eax
f0107269:	c1 e9 02             	shr    $0x2,%ecx
f010726c:	fc                   	cld    
f010726d:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f010726f:	eb 03                	jmp    f0107274 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0107271:	fc                   	cld    
f0107272:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0107274:	89 f8                	mov    %edi,%eax
f0107276:	8b 1c 24             	mov    (%esp),%ebx
f0107279:	8b 74 24 04          	mov    0x4(%esp),%esi
f010727d:	8b 7c 24 08          	mov    0x8(%esp),%edi
f0107281:	89 ec                	mov    %ebp,%esp
f0107283:	5d                   	pop    %ebp
f0107284:	c3                   	ret    

f0107285 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0107285:	55                   	push   %ebp
f0107286:	89 e5                	mov    %esp,%ebp
f0107288:	83 ec 08             	sub    $0x8,%esp
f010728b:	89 34 24             	mov    %esi,(%esp)
f010728e:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0107292:	8b 45 08             	mov    0x8(%ebp),%eax
f0107295:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
f0107298:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
f010729b:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
f010729d:	39 c6                	cmp    %eax,%esi
f010729f:	73 35                	jae    f01072d6 <memmove+0x51>
f01072a1:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f01072a4:	39 d0                	cmp    %edx,%eax
f01072a6:	73 2e                	jae    f01072d6 <memmove+0x51>
		s += n;
		d += n;
f01072a8:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01072aa:	f6 c2 03             	test   $0x3,%dl
f01072ad:	75 1b                	jne    f01072ca <memmove+0x45>
f01072af:	f7 c7 03 00 00 00    	test   $0x3,%edi
f01072b5:	75 13                	jne    f01072ca <memmove+0x45>
f01072b7:	f6 c1 03             	test   $0x3,%cl
f01072ba:	75 0e                	jne    f01072ca <memmove+0x45>
			asm volatile("std; rep movsl\n"
f01072bc:	83 ef 04             	sub    $0x4,%edi
f01072bf:	8d 72 fc             	lea    -0x4(%edx),%esi
f01072c2:	c1 e9 02             	shr    $0x2,%ecx
f01072c5:	fd                   	std    
f01072c6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01072c8:	eb 09                	jmp    f01072d3 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f01072ca:	83 ef 01             	sub    $0x1,%edi
f01072cd:	8d 72 ff             	lea    -0x1(%edx),%esi
f01072d0:	fd                   	std    
f01072d1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f01072d3:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
f01072d4:	eb 20                	jmp    f01072f6 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01072d6:	f7 c6 03 00 00 00    	test   $0x3,%esi
f01072dc:	75 15                	jne    f01072f3 <memmove+0x6e>
f01072de:	f7 c7 03 00 00 00    	test   $0x3,%edi
f01072e4:	75 0d                	jne    f01072f3 <memmove+0x6e>
f01072e6:	f6 c1 03             	test   $0x3,%cl
f01072e9:	75 08                	jne    f01072f3 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
f01072eb:	c1 e9 02             	shr    $0x2,%ecx
f01072ee:	fc                   	cld    
f01072ef:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01072f1:	eb 03                	jmp    f01072f6 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f01072f3:	fc                   	cld    
f01072f4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f01072f6:	8b 34 24             	mov    (%esp),%esi
f01072f9:	8b 7c 24 04          	mov    0x4(%esp),%edi
f01072fd:	89 ec                	mov    %ebp,%esp
f01072ff:	5d                   	pop    %ebp
f0107300:	c3                   	ret    

f0107301 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
f0107301:	55                   	push   %ebp
f0107302:	89 e5                	mov    %esp,%ebp
f0107304:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f0107307:	8b 45 10             	mov    0x10(%ebp),%eax
f010730a:	89 44 24 08          	mov    %eax,0x8(%esp)
f010730e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107311:	89 44 24 04          	mov    %eax,0x4(%esp)
f0107315:	8b 45 08             	mov    0x8(%ebp),%eax
f0107318:	89 04 24             	mov    %eax,(%esp)
f010731b:	e8 65 ff ff ff       	call   f0107285 <memmove>
}
f0107320:	c9                   	leave  
f0107321:	c3                   	ret    

f0107322 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0107322:	55                   	push   %ebp
f0107323:	89 e5                	mov    %esp,%ebp
f0107325:	57                   	push   %edi
f0107326:	56                   	push   %esi
f0107327:	53                   	push   %ebx
f0107328:	8b 75 08             	mov    0x8(%ebp),%esi
f010732b:	8b 7d 0c             	mov    0xc(%ebp),%edi
f010732e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0107331:	85 c9                	test   %ecx,%ecx
f0107333:	74 36                	je     f010736b <memcmp+0x49>
		if (*s1 != *s2)
f0107335:	0f b6 06             	movzbl (%esi),%eax
f0107338:	0f b6 1f             	movzbl (%edi),%ebx
f010733b:	38 d8                	cmp    %bl,%al
f010733d:	74 20                	je     f010735f <memcmp+0x3d>
f010733f:	eb 14                	jmp    f0107355 <memcmp+0x33>
f0107341:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
f0107346:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
f010734b:	83 c2 01             	add    $0x1,%edx
f010734e:	83 e9 01             	sub    $0x1,%ecx
f0107351:	38 d8                	cmp    %bl,%al
f0107353:	74 12                	je     f0107367 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
f0107355:	0f b6 c0             	movzbl %al,%eax
f0107358:	0f b6 db             	movzbl %bl,%ebx
f010735b:	29 d8                	sub    %ebx,%eax
f010735d:	eb 11                	jmp    f0107370 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010735f:	83 e9 01             	sub    $0x1,%ecx
f0107362:	ba 00 00 00 00       	mov    $0x0,%edx
f0107367:	85 c9                	test   %ecx,%ecx
f0107369:	75 d6                	jne    f0107341 <memcmp+0x1f>
f010736b:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
f0107370:	5b                   	pop    %ebx
f0107371:	5e                   	pop    %esi
f0107372:	5f                   	pop    %edi
f0107373:	5d                   	pop    %ebp
f0107374:	c3                   	ret    

f0107375 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0107375:	55                   	push   %ebp
f0107376:	89 e5                	mov    %esp,%ebp
f0107378:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f010737b:	89 c2                	mov    %eax,%edx
f010737d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0107380:	39 d0                	cmp    %edx,%eax
f0107382:	73 15                	jae    f0107399 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
f0107384:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
f0107388:	38 08                	cmp    %cl,(%eax)
f010738a:	75 06                	jne    f0107392 <memfind+0x1d>
f010738c:	eb 0b                	jmp    f0107399 <memfind+0x24>
f010738e:	38 08                	cmp    %cl,(%eax)
f0107390:	74 07                	je     f0107399 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0107392:	83 c0 01             	add    $0x1,%eax
f0107395:	39 c2                	cmp    %eax,%edx
f0107397:	77 f5                	ja     f010738e <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0107399:	5d                   	pop    %ebp
f010739a:	c3                   	ret    

f010739b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f010739b:	55                   	push   %ebp
f010739c:	89 e5                	mov    %esp,%ebp
f010739e:	57                   	push   %edi
f010739f:	56                   	push   %esi
f01073a0:	53                   	push   %ebx
f01073a1:	83 ec 04             	sub    $0x4,%esp
f01073a4:	8b 55 08             	mov    0x8(%ebp),%edx
f01073a7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01073aa:	0f b6 02             	movzbl (%edx),%eax
f01073ad:	3c 20                	cmp    $0x20,%al
f01073af:	74 04                	je     f01073b5 <strtol+0x1a>
f01073b1:	3c 09                	cmp    $0x9,%al
f01073b3:	75 0e                	jne    f01073c3 <strtol+0x28>
		s++;
f01073b5:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01073b8:	0f b6 02             	movzbl (%edx),%eax
f01073bb:	3c 20                	cmp    $0x20,%al
f01073bd:	74 f6                	je     f01073b5 <strtol+0x1a>
f01073bf:	3c 09                	cmp    $0x9,%al
f01073c1:	74 f2                	je     f01073b5 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
f01073c3:	3c 2b                	cmp    $0x2b,%al
f01073c5:	75 0c                	jne    f01073d3 <strtol+0x38>
		s++;
f01073c7:	83 c2 01             	add    $0x1,%edx
f01073ca:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
f01073d1:	eb 15                	jmp    f01073e8 <strtol+0x4d>
	else if (*s == '-')
f01073d3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
f01073da:	3c 2d                	cmp    $0x2d,%al
f01073dc:	75 0a                	jne    f01073e8 <strtol+0x4d>
		s++, neg = 1;
f01073de:	83 c2 01             	add    $0x1,%edx
f01073e1:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01073e8:	85 db                	test   %ebx,%ebx
f01073ea:	0f 94 c0             	sete   %al
f01073ed:	74 05                	je     f01073f4 <strtol+0x59>
f01073ef:	83 fb 10             	cmp    $0x10,%ebx
f01073f2:	75 18                	jne    f010740c <strtol+0x71>
f01073f4:	80 3a 30             	cmpb   $0x30,(%edx)
f01073f7:	75 13                	jne    f010740c <strtol+0x71>
f01073f9:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f01073fd:	8d 76 00             	lea    0x0(%esi),%esi
f0107400:	75 0a                	jne    f010740c <strtol+0x71>
		s += 2, base = 16;
f0107402:	83 c2 02             	add    $0x2,%edx
f0107405:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f010740a:	eb 15                	jmp    f0107421 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f010740c:	84 c0                	test   %al,%al
f010740e:	66 90                	xchg   %ax,%ax
f0107410:	74 0f                	je     f0107421 <strtol+0x86>
f0107412:	bb 0a 00 00 00       	mov    $0xa,%ebx
f0107417:	80 3a 30             	cmpb   $0x30,(%edx)
f010741a:	75 05                	jne    f0107421 <strtol+0x86>
		s++, base = 8;
f010741c:	83 c2 01             	add    $0x1,%edx
f010741f:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0107421:	b8 00 00 00 00       	mov    $0x0,%eax
f0107426:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0107428:	0f b6 0a             	movzbl (%edx),%ecx
f010742b:	89 cf                	mov    %ecx,%edi
f010742d:	8d 59 d0             	lea    -0x30(%ecx),%ebx
f0107430:	80 fb 09             	cmp    $0x9,%bl
f0107433:	77 08                	ja     f010743d <strtol+0xa2>
			dig = *s - '0';
f0107435:	0f be c9             	movsbl %cl,%ecx
f0107438:	83 e9 30             	sub    $0x30,%ecx
f010743b:	eb 1e                	jmp    f010745b <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
f010743d:	8d 5f 9f             	lea    -0x61(%edi),%ebx
f0107440:	80 fb 19             	cmp    $0x19,%bl
f0107443:	77 08                	ja     f010744d <strtol+0xb2>
			dig = *s - 'a' + 10;
f0107445:	0f be c9             	movsbl %cl,%ecx
f0107448:	83 e9 57             	sub    $0x57,%ecx
f010744b:	eb 0e                	jmp    f010745b <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
f010744d:	8d 5f bf             	lea    -0x41(%edi),%ebx
f0107450:	80 fb 19             	cmp    $0x19,%bl
f0107453:	77 15                	ja     f010746a <strtol+0xcf>
			dig = *s - 'A' + 10;
f0107455:	0f be c9             	movsbl %cl,%ecx
f0107458:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f010745b:	39 f1                	cmp    %esi,%ecx
f010745d:	7d 0b                	jge    f010746a <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
f010745f:	83 c2 01             	add    $0x1,%edx
f0107462:	0f af c6             	imul   %esi,%eax
f0107465:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
f0107468:	eb be                	jmp    f0107428 <strtol+0x8d>
f010746a:	89 c1                	mov    %eax,%ecx

	if (endptr)
f010746c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0107470:	74 05                	je     f0107477 <strtol+0xdc>
		*endptr = (char *) s;
f0107472:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0107475:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
f0107477:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
f010747b:	74 04                	je     f0107481 <strtol+0xe6>
f010747d:	89 c8                	mov    %ecx,%eax
f010747f:	f7 d8                	neg    %eax
}
f0107481:	83 c4 04             	add    $0x4,%esp
f0107484:	5b                   	pop    %ebx
f0107485:	5e                   	pop    %esi
f0107486:	5f                   	pop    %edi
f0107487:	5d                   	pop    %ebp
f0107488:	c3                   	ret    
f0107489:	00 00                	add    %al,(%eax)
	...

f010748c <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f010748c:	fa                   	cli    

	xorw    %ax, %ax
f010748d:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f010748f:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0107491:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0107493:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f0107495:	0f 01 16             	lgdtl  (%esi)
f0107498:	74 70                	je     f010750a <mpentry_end+0x4>
	movl    %cr0, %eax
f010749a:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f010749d:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f01074a1:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f01074a4:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f01074aa:	08 00                	or     %al,(%eax)

f01074ac <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f01074ac:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f01074b0:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f01074b2:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f01074b4:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f01074b6:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f01074ba:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f01074bc:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f01074be:	b8 00 20 12 00       	mov    $0x122000,%eax
	movl    %eax, %cr3
f01074c3:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f01074c6:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f01074c9:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f01074ce:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in mem_init()
	movl    mpentry_kstack, %esp
f01074d1:	8b 25 a4 0e 1f f0    	mov    0xf01f0ea4,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f01074d7:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f01074dc:	b8 ed 00 10 f0       	mov    $0xf01000ed,%eax
	call    *%eax
f01074e1:	ff d0                	call   *%eax

f01074e3 <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f01074e3:	eb fe                	jmp    f01074e3 <spin>
f01074e5:	8d 76 00             	lea    0x0(%esi),%esi

f01074e8 <gdt>:
	...
f01074f0:	ff                   	(bad)  
f01074f1:	ff 00                	incl   (%eax)
f01074f3:	00 00                	add    %al,(%eax)
f01074f5:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f01074fc:	00 92 cf 00 17 00    	add    %dl,0x1700cf(%edx)

f0107500 <gdtdesc>:
f0107500:	17                   	pop    %ss
f0107501:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f0107506 <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f0107506:	90                   	nop
	...

f0107510 <sum>:
#define MPIOINTR  0x03  // One per bus interrupt source
#define MPLINTR   0x04  // One per system interrupt source

static uint8_t
sum(void *addr, int len)
{
f0107510:	55                   	push   %ebp
f0107511:	89 e5                	mov    %esp,%ebp
f0107513:	56                   	push   %esi
f0107514:	53                   	push   %ebx
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0107515:	bb 00 00 00 00       	mov    $0x0,%ebx
f010751a:	b9 00 00 00 00       	mov    $0x0,%ecx
f010751f:	85 d2                	test   %edx,%edx
f0107521:	7e 0d                	jle    f0107530 <sum+0x20>
		sum += ((uint8_t *)addr)[i];
f0107523:	0f b6 34 08          	movzbl (%eax,%ecx,1),%esi
f0107527:	01 f3                	add    %esi,%ebx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0107529:	83 c1 01             	add    $0x1,%ecx
f010752c:	39 d1                	cmp    %edx,%ecx
f010752e:	75 f3                	jne    f0107523 <sum+0x13>
		sum += ((uint8_t *)addr)[i];
	return sum;
}
f0107530:	89 d8                	mov    %ebx,%eax
f0107532:	5b                   	pop    %ebx
f0107533:	5e                   	pop    %esi
f0107534:	5d                   	pop    %ebp
f0107535:	c3                   	ret    

f0107536 <mpsearch1>:

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f0107536:	55                   	push   %ebp
f0107537:	89 e5                	mov    %esp,%ebp
f0107539:	56                   	push   %esi
f010753a:	53                   	push   %ebx
f010753b:	83 ec 10             	sub    $0x10,%esp
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010753e:	8b 0d a8 0e 1f f0    	mov    0xf01f0ea8,%ecx
f0107544:	89 c3                	mov    %eax,%ebx
f0107546:	c1 eb 0c             	shr    $0xc,%ebx
f0107549:	39 cb                	cmp    %ecx,%ebx
f010754b:	72 20                	jb     f010756d <mpsearch1+0x37>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010754d:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0107551:	c7 44 24 08 80 80 10 	movl   $0xf0108080,0x8(%esp)
f0107558:	f0 
f0107559:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f0107560:	00 
f0107561:	c7 04 24 9d 9c 10 f0 	movl   $0xf0109c9d,(%esp)
f0107568:	e8 18 8b ff ff       	call   f0100085 <_panic>
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f010756d:	8d 34 02             	lea    (%edx,%eax,1),%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0107570:	89 f2                	mov    %esi,%edx
f0107572:	c1 ea 0c             	shr    $0xc,%edx
f0107575:	39 d1                	cmp    %edx,%ecx
f0107577:	77 20                	ja     f0107599 <mpsearch1+0x63>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0107579:	89 74 24 0c          	mov    %esi,0xc(%esp)
f010757d:	c7 44 24 08 80 80 10 	movl   $0xf0108080,0x8(%esp)
f0107584:	f0 
f0107585:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f010758c:	00 
f010758d:	c7 04 24 9d 9c 10 f0 	movl   $0xf0109c9d,(%esp)
f0107594:	e8 ec 8a ff ff       	call   f0100085 <_panic>
f0107599:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
f010759f:	81 ee 00 00 00 10    	sub    $0x10000000,%esi

	for (; mp < end; mp++)
f01075a5:	39 f3                	cmp    %esi,%ebx
f01075a7:	73 33                	jae    f01075dc <mpsearch1+0xa6>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f01075a9:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
f01075b0:	00 
f01075b1:	c7 44 24 04 ad 9c 10 	movl   $0xf0109cad,0x4(%esp)
f01075b8:	f0 
f01075b9:	89 1c 24             	mov    %ebx,(%esp)
f01075bc:	e8 61 fd ff ff       	call   f0107322 <memcmp>
f01075c1:	85 c0                	test   %eax,%eax
f01075c3:	75 10                	jne    f01075d5 <mpsearch1+0x9f>
		    sum(mp, sizeof(*mp)) == 0)
f01075c5:	ba 10 00 00 00       	mov    $0x10,%edx
f01075ca:	89 d8                	mov    %ebx,%eax
f01075cc:	e8 3f ff ff ff       	call   f0107510 <sum>
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f01075d1:	84 c0                	test   %al,%al
f01075d3:	74 0c                	je     f01075e1 <mpsearch1+0xab>
static struct mp *
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
f01075d5:	83 c3 10             	add    $0x10,%ebx
f01075d8:	39 de                	cmp    %ebx,%esi
f01075da:	77 cd                	ja     f01075a9 <mpsearch1+0x73>
f01075dc:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
}
f01075e1:	89 d8                	mov    %ebx,%eax
f01075e3:	83 c4 10             	add    $0x10,%esp
f01075e6:	5b                   	pop    %ebx
f01075e7:	5e                   	pop    %esi
f01075e8:	5d                   	pop    %ebp
f01075e9:	c3                   	ret    

f01075ea <mp_init>:
	return conf;
}

void
mp_init(void)
{
f01075ea:	55                   	push   %ebp
f01075eb:	89 e5                	mov    %esp,%ebp
f01075ed:	57                   	push   %edi
f01075ee:	56                   	push   %esi
f01075ef:	53                   	push   %ebx
f01075f0:	83 ec 2c             	sub    $0x2c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f01075f3:	c7 05 c0 13 1f f0 20 	movl   $0xf01f1020,0xf01f13c0
f01075fa:	10 1f f0 
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01075fd:	83 3d a8 0e 1f f0 00 	cmpl   $0x0,0xf01f0ea8
f0107604:	75 24                	jne    f010762a <mp_init+0x40>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0107606:	c7 44 24 0c 00 04 00 	movl   $0x400,0xc(%esp)
f010760d:	00 
f010760e:	c7 44 24 08 80 80 10 	movl   $0xf0108080,0x8(%esp)
f0107615:	f0 
f0107616:	c7 44 24 04 6f 00 00 	movl   $0x6f,0x4(%esp)
f010761d:	00 
f010761e:	c7 04 24 9d 9c 10 f0 	movl   $0xf0109c9d,(%esp)
f0107625:	e8 5b 8a ff ff       	call   f0100085 <_panic>
	// The BIOS data area lives in 16-bit segment 0x40.
	bda = (uint8_t *) KADDR(0x40 << 4);

	// [MP 4] The 16-bit segment of the EBDA is in the two bytes
	// starting at byte 0x0E of the BDA.  0 if not present.
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f010762a:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f0107631:	85 c0                	test   %eax,%eax
f0107633:	74 16                	je     f010764b <mp_init+0x61>
		p <<= 4;	// Translate from segment to PA
		if ((mp = mpsearch1(p, 1024)))
f0107635:	c1 e0 04             	shl    $0x4,%eax
f0107638:	ba 00 04 00 00       	mov    $0x400,%edx
f010763d:	e8 f4 fe ff ff       	call   f0107536 <mpsearch1>
f0107642:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0107645:	85 c0                	test   %eax,%eax
f0107647:	75 3c                	jne    f0107685 <mp_init+0x9b>
f0107649:	eb 20                	jmp    f010766b <mp_init+0x81>
			return mp;
	} else {
		// The size of base memory, in KB is in the two bytes
		// starting at 0x13 of the BDA.
		p = *(uint16_t *) (bda + 0x13) * 1024;
		if ((mp = mpsearch1(p - 1024, 1024)))
f010764b:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f0107652:	c1 e0 0a             	shl    $0xa,%eax
f0107655:	2d 00 04 00 00       	sub    $0x400,%eax
f010765a:	ba 00 04 00 00       	mov    $0x400,%edx
f010765f:	e8 d2 fe ff ff       	call   f0107536 <mpsearch1>
f0107664:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0107667:	85 c0                	test   %eax,%eax
f0107669:	75 1a                	jne    f0107685 <mp_init+0x9b>
			return mp;
	}
	return mpsearch1(0xF0000, 0x10000);
f010766b:	ba 00 00 01 00       	mov    $0x10000,%edx
f0107670:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f0107675:	e8 bc fe ff ff       	call   f0107536 <mpsearch1>
f010767a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
mpconfig(struct mp **pmp)
{
	struct mpconf *conf;
	struct mp *mp;

	if ((mp = mpsearch()) == 0)
f010767d:	85 c0                	test   %eax,%eax
f010767f:	0f 84 27 02 00 00    	je     f01078ac <mp_init+0x2c2>
		return NULL;
	if (mp->physaddr == 0 || mp->type != 0) {
f0107685:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0107688:	8b 78 04             	mov    0x4(%eax),%edi
f010768b:	85 ff                	test   %edi,%edi
f010768d:	74 06                	je     f0107695 <mp_init+0xab>
f010768f:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f0107693:	74 11                	je     f01076a6 <mp_init+0xbc>
		cprintf("SMP: Default configurations not implemented\n");
f0107695:	c7 04 24 10 9b 10 f0 	movl   $0xf0109b10,(%esp)
f010769c:	e8 1e d4 ff ff       	call   f0104abf <cprintf>
f01076a1:	e9 06 02 00 00       	jmp    f01078ac <mp_init+0x2c2>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01076a6:	89 f8                	mov    %edi,%eax
f01076a8:	c1 e8 0c             	shr    $0xc,%eax
f01076ab:	3b 05 a8 0e 1f f0    	cmp    0xf01f0ea8,%eax
f01076b1:	72 20                	jb     f01076d3 <mp_init+0xe9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01076b3:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f01076b7:	c7 44 24 08 80 80 10 	movl   $0xf0108080,0x8(%esp)
f01076be:	f0 
f01076bf:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
f01076c6:	00 
f01076c7:	c7 04 24 9d 9c 10 f0 	movl   $0xf0109c9d,(%esp)
f01076ce:	e8 b2 89 ff ff       	call   f0100085 <_panic>
		return NULL;
	}
	conf = (struct mpconf *) KADDR(mp->physaddr);
f01076d3:	81 ef 00 00 00 10    	sub    $0x10000000,%edi
	if (memcmp(conf, "PCMP", 4) != 0) {
f01076d9:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
f01076e0:	00 
f01076e1:	c7 44 24 04 b2 9c 10 	movl   $0xf0109cb2,0x4(%esp)
f01076e8:	f0 
f01076e9:	89 3c 24             	mov    %edi,(%esp)
f01076ec:	e8 31 fc ff ff       	call   f0107322 <memcmp>
f01076f1:	85 c0                	test   %eax,%eax
f01076f3:	74 11                	je     f0107706 <mp_init+0x11c>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f01076f5:	c7 04 24 40 9b 10 f0 	movl   $0xf0109b40,(%esp)
f01076fc:	e8 be d3 ff ff       	call   f0104abf <cprintf>
f0107701:	e9 a6 01 00 00       	jmp    f01078ac <mp_init+0x2c2>
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f0107706:	0f b7 57 04          	movzwl 0x4(%edi),%edx
f010770a:	89 f8                	mov    %edi,%eax
f010770c:	e8 ff fd ff ff       	call   f0107510 <sum>
f0107711:	84 c0                	test   %al,%al
f0107713:	74 11                	je     f0107726 <mp_init+0x13c>
		cprintf("SMP: Bad MP configuration checksum\n");
f0107715:	c7 04 24 74 9b 10 f0 	movl   $0xf0109b74,(%esp)
f010771c:	e8 9e d3 ff ff       	call   f0104abf <cprintf>
f0107721:	e9 86 01 00 00       	jmp    f01078ac <mp_init+0x2c2>
		return NULL;
	}
	if (conf->version != 1 && conf->version != 4) {
f0107726:	0f b6 47 06          	movzbl 0x6(%edi),%eax
f010772a:	3c 01                	cmp    $0x1,%al
f010772c:	74 1c                	je     f010774a <mp_init+0x160>
f010772e:	3c 04                	cmp    $0x4,%al
f0107730:	74 18                	je     f010774a <mp_init+0x160>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f0107732:	0f b6 c0             	movzbl %al,%eax
f0107735:	89 44 24 04          	mov    %eax,0x4(%esp)
f0107739:	c7 04 24 98 9b 10 f0 	movl   $0xf0109b98,(%esp)
f0107740:	e8 7a d3 ff ff       	call   f0104abf <cprintf>
f0107745:	e9 62 01 00 00       	jmp    f01078ac <mp_init+0x2c2>
		return NULL;
	}
	if (sum((uint8_t *)conf + conf->length, conf->xlength) != conf->xchecksum) {
f010774a:	0f b7 57 28          	movzwl 0x28(%edi),%edx
f010774e:	0f b7 47 04          	movzwl 0x4(%edi),%eax
f0107752:	8d 04 07             	lea    (%edi,%eax,1),%eax
f0107755:	e8 b6 fd ff ff       	call   f0107510 <sum>
f010775a:	3a 47 2a             	cmp    0x2a(%edi),%al
f010775d:	74 11                	je     f0107770 <mp_init+0x186>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f010775f:	c7 04 24 b8 9b 10 f0 	movl   $0xf0109bb8,(%esp)
f0107766:	e8 54 d3 ff ff       	call   f0104abf <cprintf>
f010776b:	e9 3c 01 00 00       	jmp    f01078ac <mp_init+0x2c2>
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
	if ((conf = mpconfig(&mp)) == 0)
f0107770:	85 ff                	test   %edi,%edi
f0107772:	0f 84 34 01 00 00    	je     f01078ac <mp_init+0x2c2>
		return;
	ismp = 1;
f0107778:	c7 05 00 10 1f f0 01 	movl   $0x1,0xf01f1000
f010777f:	00 00 00 
	lapic = (uint32_t *)conf->lapicaddr;
f0107782:	8b 47 24             	mov    0x24(%edi),%eax
f0107785:	a3 00 20 23 f0       	mov    %eax,0xf0232000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f010778a:	66 83 7f 22 00       	cmpw   $0x0,0x22(%edi)
f010778f:	0f 84 98 00 00 00    	je     f010782d <mp_init+0x243>
f0107795:	8d 5f 2c             	lea    0x2c(%edi),%ebx
f0107798:	be 00 00 00 00       	mov    $0x0,%esi
		switch (*p) {
f010779d:	0f b6 03             	movzbl (%ebx),%eax
f01077a0:	84 c0                	test   %al,%al
f01077a2:	74 06                	je     f01077aa <mp_init+0x1c0>
f01077a4:	3c 04                	cmp    $0x4,%al
f01077a6:	77 55                	ja     f01077fd <mp_init+0x213>
f01077a8:	eb 4e                	jmp    f01077f8 <mp_init+0x20e>
		case MPPROC:
			proc = (struct mpproc *)p;
f01077aa:	89 da                	mov    %ebx,%edx
			if (proc->flags & MPPROC_BOOT)
f01077ac:	f6 43 03 02          	testb  $0x2,0x3(%ebx)
f01077b0:	74 11                	je     f01077c3 <mp_init+0x1d9>
				bootcpu = &cpus[ncpu];
f01077b2:	6b 05 c4 13 1f f0 74 	imul   $0x74,0xf01f13c4,%eax
f01077b9:	05 20 10 1f f0       	add    $0xf01f1020,%eax
f01077be:	a3 c0 13 1f f0       	mov    %eax,0xf01f13c0
			if (ncpu < NCPU) {
f01077c3:	a1 c4 13 1f f0       	mov    0xf01f13c4,%eax
f01077c8:	83 f8 07             	cmp    $0x7,%eax
f01077cb:	7f 12                	jg     f01077df <mp_init+0x1f5>
				cpus[ncpu].cpu_id = ncpu;
f01077cd:	6b d0 74             	imul   $0x74,%eax,%edx
f01077d0:	88 82 20 10 1f f0    	mov    %al,-0xfe0efe0(%edx)
				ncpu++;
f01077d6:	83 05 c4 13 1f f0 01 	addl   $0x1,0xf01f13c4
f01077dd:	eb 14                	jmp    f01077f3 <mp_init+0x209>
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f01077df:	0f b6 42 01          	movzbl 0x1(%edx),%eax
f01077e3:	89 44 24 04          	mov    %eax,0x4(%esp)
f01077e7:	c7 04 24 e8 9b 10 f0 	movl   $0xf0109be8,(%esp)
f01077ee:	e8 cc d2 ff ff       	call   f0104abf <cprintf>
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f01077f3:	83 c3 14             	add    $0x14,%ebx
			continue;
f01077f6:	eb 26                	jmp    f010781e <mp_init+0x234>
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f01077f8:	83 c3 08             	add    $0x8,%ebx
			continue;
f01077fb:	eb 21                	jmp    f010781e <mp_init+0x234>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f01077fd:	0f b6 c0             	movzbl %al,%eax
f0107800:	89 44 24 04          	mov    %eax,0x4(%esp)
f0107804:	c7 04 24 10 9c 10 f0 	movl   $0xf0109c10,(%esp)
f010780b:	e8 af d2 ff ff       	call   f0104abf <cprintf>
			ismp = 0;
f0107810:	c7 05 00 10 1f f0 00 	movl   $0x0,0xf01f1000
f0107817:	00 00 00 
			i = conf->entry;
f010781a:	0f b7 77 22          	movzwl 0x22(%edi),%esi
	if ((conf = mpconfig(&mp)) == 0)
		return;
	ismp = 1;
	lapic = (uint32_t *)conf->lapicaddr;

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f010781e:	83 c6 01             	add    $0x1,%esi
f0107821:	0f b7 47 22          	movzwl 0x22(%edi),%eax
f0107825:	39 f0                	cmp    %esi,%eax
f0107827:	0f 87 70 ff ff ff    	ja     f010779d <mp_init+0x1b3>
			ismp = 0;
			i = conf->entry;
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f010782d:	a1 c0 13 1f f0       	mov    0xf01f13c0,%eax
f0107832:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f0107839:	83 3d 00 10 1f f0 00 	cmpl   $0x0,0xf01f1000
f0107840:	75 22                	jne    f0107864 <mp_init+0x27a>
		// Didn't like what we found; fall back to no MP.
		ncpu = 1;
f0107842:	c7 05 c4 13 1f f0 01 	movl   $0x1,0xf01f13c4
f0107849:	00 00 00 
		lapic = NULL;
f010784c:	c7 05 00 20 23 f0 00 	movl   $0x0,0xf0232000
f0107853:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f0107856:	c7 04 24 30 9c 10 f0 	movl   $0xf0109c30,(%esp)
f010785d:	e8 5d d2 ff ff       	call   f0104abf <cprintf>
		return;
f0107862:	eb 48                	jmp    f01078ac <mp_init+0x2c2>
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f0107864:	a1 c4 13 1f f0       	mov    0xf01f13c4,%eax
f0107869:	89 44 24 08          	mov    %eax,0x8(%esp)
f010786d:	a1 c0 13 1f f0       	mov    0xf01f13c0,%eax
f0107872:	0f b6 00             	movzbl (%eax),%eax
f0107875:	89 44 24 04          	mov    %eax,0x4(%esp)
f0107879:	c7 04 24 b7 9c 10 f0 	movl   $0xf0109cb7,(%esp)
f0107880:	e8 3a d2 ff ff       	call   f0104abf <cprintf>

	if (mp->imcrp) {
f0107885:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0107888:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f010788c:	74 1e                	je     f01078ac <mp_init+0x2c2>
		// [MP 3.2.6.1] If the hardware implements PIC mode,
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f010788e:	c7 04 24 5c 9c 10 f0 	movl   $0xf0109c5c,(%esp)
f0107895:	e8 25 d2 ff ff       	call   f0104abf <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010789a:	ba 22 00 00 00       	mov    $0x22,%edx
f010789f:	b8 70 00 00 00       	mov    $0x70,%eax
f01078a4:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01078a5:	b2 23                	mov    $0x23,%dl
f01078a7:	ec                   	in     (%dx),%al
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01078a8:	83 c8 01             	or     $0x1,%eax
f01078ab:	ee                   	out    %al,(%dx)
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
	}
}
f01078ac:	83 c4 2c             	add    $0x2c,%esp
f01078af:	5b                   	pop    %ebx
f01078b0:	5e                   	pop    %esi
f01078b1:	5f                   	pop    %edi
f01078b2:	5d                   	pop    %ebp
f01078b3:	c3                   	ret    

f01078b4 <lapicw>:

volatile uint32_t *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
f01078b4:	55                   	push   %ebp
f01078b5:	89 e5                	mov    %esp,%ebp
	lapic[index] = value;
f01078b7:	c1 e0 02             	shl    $0x2,%eax
f01078ba:	03 05 00 20 23 f0    	add    0xf0232000,%eax
f01078c0:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f01078c2:	a1 00 20 23 f0       	mov    0xf0232000,%eax
f01078c7:	83 c0 20             	add    $0x20,%eax
f01078ca:	8b 00                	mov    (%eax),%eax
}
f01078cc:	5d                   	pop    %ebp
f01078cd:	c3                   	ret    

f01078ce <cpunum>:
	lapicw(TPR, 0);
}

int
cpunum(void)
{
f01078ce:	55                   	push   %ebp
f01078cf:	89 e5                	mov    %esp,%ebp
	if (lapic)
f01078d1:	8b 15 00 20 23 f0    	mov    0xf0232000,%edx
f01078d7:	b8 00 00 00 00       	mov    $0x0,%eax
f01078dc:	85 d2                	test   %edx,%edx
f01078de:	74 08                	je     f01078e8 <cpunum+0x1a>
		return lapic[ID] >> 24;
f01078e0:	83 c2 20             	add    $0x20,%edx
f01078e3:	8b 02                	mov    (%edx),%eax
f01078e5:	c1 e8 18             	shr    $0x18,%eax
	return 0;
}
f01078e8:	5d                   	pop    %ebp
f01078e9:	c3                   	ret    

f01078ea <lapic_init>:
	lapic[ID];  // wait for write to finish, by reading
}

void
lapic_init(void)
{
f01078ea:	55                   	push   %ebp
f01078eb:	89 e5                	mov    %esp,%ebp
	if (!lapic) 
f01078ed:	83 3d 00 20 23 f0 00 	cmpl   $0x0,0xf0232000
f01078f4:	0f 84 0b 01 00 00    	je     f0107a05 <lapic_init+0x11b>
		return;

	// Enable local APIC; set spurious interrupt vector.
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f01078fa:	ba 27 01 00 00       	mov    $0x127,%edx
f01078ff:	b8 3c 00 00 00       	mov    $0x3c,%eax
f0107904:	e8 ab ff ff ff       	call   f01078b4 <lapicw>

	// The timer repeatedly counts down at bus frequency
	// from lapic[TICR] and then issues an interrupt.  
	// If we cared more about precise timekeeping,
	// TICR would be calibrated using an external time source.
	lapicw(TDCR, X1);
f0107909:	ba 0b 00 00 00       	mov    $0xb,%edx
f010790e:	b8 f8 00 00 00       	mov    $0xf8,%eax
f0107913:	e8 9c ff ff ff       	call   f01078b4 <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f0107918:	ba 20 00 02 00       	mov    $0x20020,%edx
f010791d:	b8 c8 00 00 00       	mov    $0xc8,%eax
f0107922:	e8 8d ff ff ff       	call   f01078b4 <lapicw>
	lapicw(TICR, 10000000); 
f0107927:	ba 80 96 98 00       	mov    $0x989680,%edx
f010792c:	b8 e0 00 00 00       	mov    $0xe0,%eax
f0107931:	e8 7e ff ff ff       	call   f01078b4 <lapicw>
	//
	// According to Intel MP Specification, the BIOS should initialize
	// BSP's local APIC in Virtual Wire Mode, in which 8259A's
	// INTR is virtually connected to BSP's LINTIN0. In this mode,
	// we do not need to program the IOAPIC.
	if (thiscpu != bootcpu)
f0107936:	e8 93 ff ff ff       	call   f01078ce <cpunum>
f010793b:	6b c0 74             	imul   $0x74,%eax,%eax
f010793e:	05 20 10 1f f0       	add    $0xf01f1020,%eax
f0107943:	39 05 c0 13 1f f0    	cmp    %eax,0xf01f13c0
f0107949:	74 0f                	je     f010795a <lapic_init+0x70>
		lapicw(LINT0, MASKED);
f010794b:	ba 00 00 01 00       	mov    $0x10000,%edx
f0107950:	b8 d4 00 00 00       	mov    $0xd4,%eax
f0107955:	e8 5a ff ff ff       	call   f01078b4 <lapicw>

	// Disable NMI (LINT1) on all CPUs
	lapicw(LINT1, MASKED);
f010795a:	ba 00 00 01 00       	mov    $0x10000,%edx
f010795f:	b8 d8 00 00 00       	mov    $0xd8,%eax
f0107964:	e8 4b ff ff ff       	call   f01078b4 <lapicw>

	// Disable performance counter overflow interrupts
	// on machines that provide that interrupt entry.
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f0107969:	a1 00 20 23 f0       	mov    0xf0232000,%eax
f010796e:	83 c0 30             	add    $0x30,%eax
f0107971:	8b 00                	mov    (%eax),%eax
f0107973:	c1 e8 10             	shr    $0x10,%eax
f0107976:	3c 03                	cmp    $0x3,%al
f0107978:	76 0f                	jbe    f0107989 <lapic_init+0x9f>
		lapicw(PCINT, MASKED);
f010797a:	ba 00 00 01 00       	mov    $0x10000,%edx
f010797f:	b8 d0 00 00 00       	mov    $0xd0,%eax
f0107984:	e8 2b ff ff ff       	call   f01078b4 <lapicw>

	// Map error interrupt to IRQ_ERROR.
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f0107989:	ba 33 00 00 00       	mov    $0x33,%edx
f010798e:	b8 dc 00 00 00       	mov    $0xdc,%eax
f0107993:	e8 1c ff ff ff       	call   f01078b4 <lapicw>

	// Clear error status register (requires back-to-back writes).
	lapicw(ESR, 0);
f0107998:	ba 00 00 00 00       	mov    $0x0,%edx
f010799d:	b8 a0 00 00 00       	mov    $0xa0,%eax
f01079a2:	e8 0d ff ff ff       	call   f01078b4 <lapicw>
	lapicw(ESR, 0);
f01079a7:	ba 00 00 00 00       	mov    $0x0,%edx
f01079ac:	b8 a0 00 00 00       	mov    $0xa0,%eax
f01079b1:	e8 fe fe ff ff       	call   f01078b4 <lapicw>

	// Ack any outstanding interrupts.
	lapicw(EOI, 0);
f01079b6:	ba 00 00 00 00       	mov    $0x0,%edx
f01079bb:	b8 2c 00 00 00       	mov    $0x2c,%eax
f01079c0:	e8 ef fe ff ff       	call   f01078b4 <lapicw>

	// Send an Init Level De-Assert to synchronize arbitration ID's.
	lapicw(ICRHI, 0);
f01079c5:	ba 00 00 00 00       	mov    $0x0,%edx
f01079ca:	b8 c4 00 00 00       	mov    $0xc4,%eax
f01079cf:	e8 e0 fe ff ff       	call   f01078b4 <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f01079d4:	ba 00 85 08 00       	mov    $0x88500,%edx
f01079d9:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01079de:	e8 d1 fe ff ff       	call   f01078b4 <lapicw>
	while(lapic[ICRLO] & DELIVS)
f01079e3:	8b 15 00 20 23 f0    	mov    0xf0232000,%edx
f01079e9:	81 c2 00 03 00 00    	add    $0x300,%edx
f01079ef:	8b 02                	mov    (%edx),%eax
f01079f1:	f6 c4 10             	test   $0x10,%ah
f01079f4:	75 f9                	jne    f01079ef <lapic_init+0x105>
		;

	// Enable interrupts on the APIC (but not on the processor).
	lapicw(TPR, 0);
f01079f6:	ba 00 00 00 00       	mov    $0x0,%edx
f01079fb:	b8 20 00 00 00       	mov    $0x20,%eax
f0107a00:	e8 af fe ff ff       	call   f01078b4 <lapicw>
}
f0107a05:	5d                   	pop    %ebp
f0107a06:	c3                   	ret    

f0107a07 <lapic_eoi>:
}

// Acknowledge interrupt.
void
lapic_eoi(void)
{
f0107a07:	55                   	push   %ebp
f0107a08:	89 e5                	mov    %esp,%ebp
	if (lapic)
f0107a0a:	83 3d 00 20 23 f0 00 	cmpl   $0x0,0xf0232000
f0107a11:	74 0f                	je     f0107a22 <lapic_eoi+0x1b>
		lapicw(EOI, 0);
f0107a13:	ba 00 00 00 00       	mov    $0x0,%edx
f0107a18:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0107a1d:	e8 92 fe ff ff       	call   f01078b4 <lapicw>
}
f0107a22:	5d                   	pop    %ebp
f0107a23:	c3                   	ret    

f0107a24 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
static void
microdelay(int us)
{
f0107a24:	55                   	push   %ebp
f0107a25:	89 e5                	mov    %esp,%ebp
}
f0107a27:	5d                   	pop    %ebp
f0107a28:	c3                   	ret    

f0107a29 <lapic_ipi>:
	}
}

void
lapic_ipi(int vector)
{
f0107a29:	55                   	push   %ebp
f0107a2a:	89 e5                	mov    %esp,%ebp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f0107a2c:	8b 55 08             	mov    0x8(%ebp),%edx
f0107a2f:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f0107a35:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0107a3a:	e8 75 fe ff ff       	call   f01078b4 <lapicw>
	while (lapic[ICRLO] & DELIVS)
f0107a3f:	8b 15 00 20 23 f0    	mov    0xf0232000,%edx
f0107a45:	81 c2 00 03 00 00    	add    $0x300,%edx
f0107a4b:	8b 02                	mov    (%edx),%eax
f0107a4d:	f6 c4 10             	test   $0x10,%ah
f0107a50:	75 f9                	jne    f0107a4b <lapic_ipi+0x22>
		;
}
f0107a52:	5d                   	pop    %ebp
f0107a53:	c3                   	ret    

f0107a54 <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f0107a54:	55                   	push   %ebp
f0107a55:	89 e5                	mov    %esp,%ebp
f0107a57:	56                   	push   %esi
f0107a58:	53                   	push   %ebx
f0107a59:	83 ec 10             	sub    $0x10,%esp
f0107a5c:	8b 75 0c             	mov    0xc(%ebp),%esi
f0107a5f:	0f b6 5d 08          	movzbl 0x8(%ebp),%ebx
f0107a63:	ba 70 00 00 00       	mov    $0x70,%edx
f0107a68:	b8 0f 00 00 00       	mov    $0xf,%eax
f0107a6d:	ee                   	out    %al,(%dx)
f0107a6e:	b2 71                	mov    $0x71,%dl
f0107a70:	b8 0a 00 00 00       	mov    $0xa,%eax
f0107a75:	ee                   	out    %al,(%dx)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0107a76:	83 3d a8 0e 1f f0 00 	cmpl   $0x0,0xf01f0ea8
f0107a7d:	75 24                	jne    f0107aa3 <lapic_startap+0x4f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0107a7f:	c7 44 24 0c 67 04 00 	movl   $0x467,0xc(%esp)
f0107a86:	00 
f0107a87:	c7 44 24 08 80 80 10 	movl   $0xf0108080,0x8(%esp)
f0107a8e:	f0 
f0107a8f:	c7 44 24 04 93 00 00 	movl   $0x93,0x4(%esp)
f0107a96:	00 
f0107a97:	c7 04 24 d4 9c 10 f0 	movl   $0xf0109cd4,(%esp)
f0107a9e:	e8 e2 85 ff ff       	call   f0100085 <_panic>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f0107aa3:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f0107aaa:	00 00 
	wrv[1] = addr >> 4;
f0107aac:	89 f0                	mov    %esi,%eax
f0107aae:	c1 e8 04             	shr    $0x4,%eax
f0107ab1:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f0107ab7:	c1 e3 18             	shl    $0x18,%ebx
f0107aba:	89 da                	mov    %ebx,%edx
f0107abc:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0107ac1:	e8 ee fd ff ff       	call   f01078b4 <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f0107ac6:	ba 00 c5 00 00       	mov    $0xc500,%edx
f0107acb:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0107ad0:	e8 df fd ff ff       	call   f01078b4 <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f0107ad5:	ba 00 85 00 00       	mov    $0x8500,%edx
f0107ada:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0107adf:	e8 d0 fd ff ff       	call   f01078b4 <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0107ae4:	c1 ee 0c             	shr    $0xc,%esi
f0107ae7:	81 ce 00 06 00 00    	or     $0x600,%esi
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0107aed:	89 da                	mov    %ebx,%edx
f0107aef:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0107af4:	e8 bb fd ff ff       	call   f01078b4 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0107af9:	89 f2                	mov    %esi,%edx
f0107afb:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0107b00:	e8 af fd ff ff       	call   f01078b4 <lapicw>
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0107b05:	89 da                	mov    %ebx,%edx
f0107b07:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0107b0c:	e8 a3 fd ff ff       	call   f01078b4 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0107b11:	89 f2                	mov    %esi,%edx
f0107b13:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0107b18:	e8 97 fd ff ff       	call   f01078b4 <lapicw>
		microdelay(200);
	}
}
f0107b1d:	83 c4 10             	add    $0x10,%esp
f0107b20:	5b                   	pop    %ebx
f0107b21:	5e                   	pop    %esi
f0107b22:	5d                   	pop    %ebp
f0107b23:	c3                   	ret    
	...

f0107b30 <__spin_initlock>:
}
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f0107b30:	55                   	push   %ebp
f0107b31:	89 e5                	mov    %esp,%ebp
f0107b33:	8b 45 08             	mov    0x8(%ebp),%eax
#ifndef USE_TICKET_SPIN_LOCK
	lk->locked = 0;
f0107b36:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
        lk->next = 0;

#endif

#ifdef DEBUG_SPINLOCK
	lk->name = name;
f0107b3c:	8b 55 0c             	mov    0xc(%ebp),%edx
f0107b3f:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f0107b42:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f0107b49:	5d                   	pop    %ebp
f0107b4a:	c3                   	ret    

f0107b4b <holding>:
}

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
f0107b4b:	55                   	push   %ebp
f0107b4c:	89 e5                	mov    %esp,%ebp
f0107b4e:	53                   	push   %ebx
f0107b4f:	83 ec 04             	sub    $0x4,%esp
f0107b52:	89 c2                	mov    %eax,%edx
#ifndef USE_TICKET_SPIN_LOCK
	return lock->locked && lock->cpu == thiscpu;
f0107b54:	b8 00 00 00 00       	mov    $0x0,%eax
f0107b59:	83 3a 00             	cmpl   $0x0,(%edx)
f0107b5c:	74 18                	je     f0107b76 <holding+0x2b>
f0107b5e:	8b 5a 08             	mov    0x8(%edx),%ebx
f0107b61:	e8 68 fd ff ff       	call   f01078ce <cpunum>
f0107b66:	6b c0 74             	imul   $0x74,%eax,%eax
f0107b69:	05 20 10 1f f0       	add    $0xf01f1020,%eax
f0107b6e:	39 c3                	cmp    %eax,%ebx
f0107b70:	0f 94 c0             	sete   %al
f0107b73:	0f b6 c0             	movzbl %al,%eax
	//LAB 4: Your code here
        return lock->own != lock->next && lock->cpu == thiscpu;
	//panic("ticket spinlock: not implemented yet");

#endif
}
f0107b76:	83 c4 04             	add    $0x4,%esp
f0107b79:	5b                   	pop    %ebx
f0107b7a:	5d                   	pop    %ebp
f0107b7b:	c3                   	ret    

f0107b7c <spin_unlock>:
}

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f0107b7c:	55                   	push   %ebp
f0107b7d:	89 e5                	mov    %esp,%ebp
f0107b7f:	83 ec 78             	sub    $0x78,%esp
f0107b82:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0107b85:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0107b88:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0107b8b:	8b 5d 08             	mov    0x8(%ebp),%ebx
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
f0107b8e:	89 d8                	mov    %ebx,%eax
f0107b90:	e8 b6 ff ff ff       	call   f0107b4b <holding>
f0107b95:	85 c0                	test   %eax,%eax
f0107b97:	0f 85 d5 00 00 00    	jne    f0107c72 <spin_unlock+0xf6>
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f0107b9d:	c7 44 24 08 28 00 00 	movl   $0x28,0x8(%esp)
f0107ba4:	00 
f0107ba5:	8d 43 0c             	lea    0xc(%ebx),%eax
f0107ba8:	89 44 24 04          	mov    %eax,0x4(%esp)
f0107bac:	8d 45 a8             	lea    -0x58(%ebp),%eax
f0107baf:	89 04 24             	mov    %eax,(%esp)
f0107bb2:	e8 ce f6 ff ff       	call   f0107285 <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f0107bb7:	8b 43 08             	mov    0x8(%ebx),%eax
f0107bba:	0f b6 30             	movzbl (%eax),%esi
f0107bbd:	8b 5b 04             	mov    0x4(%ebx),%ebx
f0107bc0:	e8 09 fd ff ff       	call   f01078ce <cpunum>
f0107bc5:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0107bc9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0107bcd:	89 44 24 04          	mov    %eax,0x4(%esp)
f0107bd1:	c7 04 24 e4 9c 10 f0 	movl   $0xf0109ce4,(%esp)
f0107bd8:	e8 e2 ce ff ff       	call   f0104abf <cprintf>
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f0107bdd:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0107be0:	85 c0                	test   %eax,%eax
f0107be2:	74 72                	je     f0107c56 <spin_unlock+0xda>
f0107be4:	8d 5d a8             	lea    -0x58(%ebp),%ebx
#endif
}

// Release the lock.
void
spin_unlock(struct spinlock *lk)
f0107be7:	8d 7d cc             	lea    -0x34(%ebp),%edi
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f0107bea:	8d 75 d0             	lea    -0x30(%ebp),%esi
f0107bed:	89 74 24 04          	mov    %esi,0x4(%esp)
f0107bf1:	89 04 24             	mov    %eax,(%esp)
f0107bf4:	e8 e5 e8 ff ff       	call   f01064de <debuginfo_eip>
f0107bf9:	85 c0                	test   %eax,%eax
f0107bfb:	78 39                	js     f0107c36 <spin_unlock+0xba>
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
f0107bfd:	8b 03                	mov    (%ebx),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f0107bff:	89 c2                	mov    %eax,%edx
f0107c01:	2b 55 e0             	sub    -0x20(%ebp),%edx
f0107c04:	89 54 24 18          	mov    %edx,0x18(%esp)
f0107c08:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0107c0b:	89 54 24 14          	mov    %edx,0x14(%esp)
f0107c0f:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0107c12:	89 54 24 10          	mov    %edx,0x10(%esp)
f0107c16:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0107c19:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0107c1d:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0107c20:	89 54 24 08          	mov    %edx,0x8(%esp)
f0107c24:	89 44 24 04          	mov    %eax,0x4(%esp)
f0107c28:	c7 04 24 48 9d 10 f0 	movl   $0xf0109d48,(%esp)
f0107c2f:	e8 8b ce ff ff       	call   f0104abf <cprintf>
f0107c34:	eb 12                	jmp    f0107c48 <spin_unlock+0xcc>
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
f0107c36:	8b 03                	mov    (%ebx),%eax
f0107c38:	89 44 24 04          	mov    %eax,0x4(%esp)
f0107c3c:	c7 04 24 5f 9d 10 f0 	movl   $0xf0109d5f,(%esp)
f0107c43:	e8 77 ce ff ff       	call   f0104abf <cprintf>
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f0107c48:	39 fb                	cmp    %edi,%ebx
f0107c4a:	74 0a                	je     f0107c56 <spin_unlock+0xda>
f0107c4c:	8b 43 04             	mov    0x4(%ebx),%eax
f0107c4f:	83 c3 04             	add    $0x4,%ebx
f0107c52:	85 c0                	test   %eax,%eax
f0107c54:	75 97                	jne    f0107bed <spin_unlock+0x71>
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
f0107c56:	c7 44 24 08 67 9d 10 	movl   $0xf0109d67,0x8(%esp)
f0107c5d:	f0 
f0107c5e:	c7 44 24 04 8a 00 00 	movl   $0x8a,0x4(%esp)
f0107c65:	00 
f0107c66:	c7 04 24 73 9d 10 f0 	movl   $0xf0109d73,(%esp)
f0107c6d:	e8 13 84 ff ff       	call   f0100085 <_panic>
	}

	lk->pcs[0] = 0;
f0107c72:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
	lk->cpu = 0;
f0107c79:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0107c80:	b8 00 00 00 00       	mov    $0x0,%eax
f0107c85:	f0 87 03             	lock xchg %eax,(%ebx)
	xchg(&lk->locked, 0);
#else
	//LAB 4: Your code here
        atomic_return_and_add(&lk->own,1);
#endif
}
f0107c88:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0107c8b:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0107c8e:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0107c91:	89 ec                	mov    %ebp,%esp
f0107c93:	5d                   	pop    %ebp
f0107c94:	c3                   	ret    

f0107c95 <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f0107c95:	55                   	push   %ebp
f0107c96:	89 e5                	mov    %esp,%ebp
f0107c98:	56                   	push   %esi
f0107c99:	53                   	push   %ebx
f0107c9a:	83 ec 20             	sub    $0x20,%esp
f0107c9d:	8b 5d 08             	mov    0x8(%ebp),%ebx
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f0107ca0:	89 d8                	mov    %ebx,%eax
f0107ca2:	e8 a4 fe ff ff       	call   f0107b4b <holding>
f0107ca7:	85 c0                	test   %eax,%eax
f0107ca9:	75 12                	jne    f0107cbd <spin_lock+0x28>

#ifndef USE_TICKET_SPIN_LOCK
	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f0107cab:	89 da                	mov    %ebx,%edx
f0107cad:	b0 01                	mov    $0x1,%al
f0107caf:	f0 87 03             	lock xchg %eax,(%ebx)
f0107cb2:	b9 01 00 00 00       	mov    $0x1,%ecx
f0107cb7:	85 c0                	test   %eax,%eax
f0107cb9:	75 2e                	jne    f0107ce9 <spin_lock+0x54>
f0107cbb:	eb 37                	jmp    f0107cf4 <spin_lock+0x5f>
void
spin_lock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f0107cbd:	8b 5b 04             	mov    0x4(%ebx),%ebx
f0107cc0:	e8 09 fc ff ff       	call   f01078ce <cpunum>
f0107cc5:	89 5c 24 10          	mov    %ebx,0x10(%esp)
f0107cc9:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0107ccd:	c7 44 24 08 1c 9d 10 	movl   $0xf0109d1c,0x8(%esp)
f0107cd4:	f0 
f0107cd5:	c7 44 24 04 5c 00 00 	movl   $0x5c,0x4(%esp)
f0107cdc:	00 
f0107cdd:	c7 04 24 73 9d 10 f0 	movl   $0xf0109d73,(%esp)
f0107ce4:	e8 9c 83 ff ff       	call   f0100085 <_panic>
#ifndef USE_TICKET_SPIN_LOCK
	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f0107ce9:	f3 90                	pause  
f0107ceb:	89 c8                	mov    %ecx,%eax
f0107ced:	f0 87 02             	lock xchg %eax,(%edx)

#ifndef USE_TICKET_SPIN_LOCK
	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f0107cf0:	85 c0                	test   %eax,%eax
f0107cf2:	75 f5                	jne    f0107ce9 <spin_lock+0x54>

#endif

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f0107cf4:	e8 d5 fb ff ff       	call   f01078ce <cpunum>
f0107cf9:	6b c0 74             	imul   $0x74,%eax,%eax
f0107cfc:	05 20 10 1f f0       	add    $0xf01f1020,%eax
f0107d01:	89 43 08             	mov    %eax,0x8(%ebx)
	get_caller_pcs(lk->pcs);
f0107d04:	8d 73 0c             	lea    0xc(%ebx),%esi
get_caller_pcs(uint32_t pcs[])
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
f0107d07:	89 e8                	mov    %ebp,%eax
	for (i = 0; i < 10; i++){
		if (ebp == 0 || ebp < (uint32_t *)ULIM
f0107d09:	8d 90 00 00 80 10    	lea    0x10800000(%eax),%edx
f0107d0f:	81 fa ff ff 7f 0e    	cmp    $0xe7fffff,%edx
f0107d15:	76 40                	jbe    f0107d57 <spin_lock+0xc2>
f0107d17:	eb 33                	jmp    f0107d4c <spin_lock+0xb7>
f0107d19:	8d 8a 00 00 80 10    	lea    0x10800000(%edx),%ecx
f0107d1f:	81 f9 ff ff 7f 0e    	cmp    $0xe7fffff,%ecx
f0107d25:	77 2a                	ja     f0107d51 <spin_lock+0xbc>
		    || ebp >= (uint32_t *)IOMEMBASE)
			break;
		pcs[i] = ebp[1];          // saved %eip
f0107d27:	8b 4a 04             	mov    0x4(%edx),%ecx
f0107d2a:	89 0c 86             	mov    %ecx,(%esi,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f0107d2d:	8b 12                	mov    (%edx),%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f0107d2f:	83 c0 01             	add    $0x1,%eax
f0107d32:	83 f8 0a             	cmp    $0xa,%eax
f0107d35:	75 e2                	jne    f0107d19 <spin_lock+0x84>
f0107d37:	eb 2d                	jmp    f0107d66 <spin_lock+0xd1>
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
		pcs[i] = 0;
f0107d39:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
		    || ebp >= (uint32_t *)IOMEMBASE)
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
f0107d3f:	83 c0 01             	add    $0x1,%eax
f0107d42:	83 c2 04             	add    $0x4,%edx
f0107d45:	83 f8 09             	cmp    $0x9,%eax
f0107d48:	7e ef                	jle    f0107d39 <spin_lock+0xa4>
f0107d4a:	eb 1a                	jmp    f0107d66 <spin_lock+0xd1>
	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
	get_caller_pcs(lk->pcs);
#endif
}
f0107d4c:	b8 00 00 00 00       	mov    $0x0,%eax
// Acquire the lock.
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
f0107d51:	8d 54 83 0c          	lea    0xc(%ebx,%eax,4),%edx
f0107d55:	eb e2                	jmp    f0107d39 <spin_lock+0xa4>
	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
		if (ebp == 0 || ebp < (uint32_t *)ULIM
		    || ebp >= (uint32_t *)IOMEMBASE)
			break;
		pcs[i] = ebp[1];          // saved %eip
f0107d57:	8b 50 04             	mov    0x4(%eax),%edx
f0107d5a:	89 53 0c             	mov    %edx,0xc(%ebx)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f0107d5d:	8b 10                	mov    (%eax),%edx
f0107d5f:	b8 01 00 00 00       	mov    $0x1,%eax
f0107d64:	eb b3                	jmp    f0107d19 <spin_lock+0x84>
	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
	get_caller_pcs(lk->pcs);
#endif
}
f0107d66:	83 c4 20             	add    $0x20,%esp
f0107d69:	5b                   	pop    %ebx
f0107d6a:	5e                   	pop    %esi
f0107d6b:	5d                   	pop    %ebp
f0107d6c:	c3                   	ret    
f0107d6d:	00 00                	add    %al,(%eax)
	...

f0107d70 <__udivdi3>:
f0107d70:	55                   	push   %ebp
f0107d71:	89 e5                	mov    %esp,%ebp
f0107d73:	57                   	push   %edi
f0107d74:	56                   	push   %esi
f0107d75:	83 ec 10             	sub    $0x10,%esp
f0107d78:	8b 45 14             	mov    0x14(%ebp),%eax
f0107d7b:	8b 55 08             	mov    0x8(%ebp),%edx
f0107d7e:	8b 75 10             	mov    0x10(%ebp),%esi
f0107d81:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0107d84:	85 c0                	test   %eax,%eax
f0107d86:	89 55 f0             	mov    %edx,-0x10(%ebp)
f0107d89:	75 35                	jne    f0107dc0 <__udivdi3+0x50>
f0107d8b:	39 fe                	cmp    %edi,%esi
f0107d8d:	77 61                	ja     f0107df0 <__udivdi3+0x80>
f0107d8f:	85 f6                	test   %esi,%esi
f0107d91:	75 0b                	jne    f0107d9e <__udivdi3+0x2e>
f0107d93:	b8 01 00 00 00       	mov    $0x1,%eax
f0107d98:	31 d2                	xor    %edx,%edx
f0107d9a:	f7 f6                	div    %esi
f0107d9c:	89 c6                	mov    %eax,%esi
f0107d9e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
f0107da1:	31 d2                	xor    %edx,%edx
f0107da3:	89 f8                	mov    %edi,%eax
f0107da5:	f7 f6                	div    %esi
f0107da7:	89 c7                	mov    %eax,%edi
f0107da9:	89 c8                	mov    %ecx,%eax
f0107dab:	f7 f6                	div    %esi
f0107dad:	89 c1                	mov    %eax,%ecx
f0107daf:	89 fa                	mov    %edi,%edx
f0107db1:	89 c8                	mov    %ecx,%eax
f0107db3:	83 c4 10             	add    $0x10,%esp
f0107db6:	5e                   	pop    %esi
f0107db7:	5f                   	pop    %edi
f0107db8:	5d                   	pop    %ebp
f0107db9:	c3                   	ret    
f0107dba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0107dc0:	39 f8                	cmp    %edi,%eax
f0107dc2:	77 1c                	ja     f0107de0 <__udivdi3+0x70>
f0107dc4:	0f bd d0             	bsr    %eax,%edx
f0107dc7:	83 f2 1f             	xor    $0x1f,%edx
f0107dca:	89 55 f4             	mov    %edx,-0xc(%ebp)
f0107dcd:	75 39                	jne    f0107e08 <__udivdi3+0x98>
f0107dcf:	3b 75 f0             	cmp    -0x10(%ebp),%esi
f0107dd2:	0f 86 a0 00 00 00    	jbe    f0107e78 <__udivdi3+0x108>
f0107dd8:	39 f8                	cmp    %edi,%eax
f0107dda:	0f 82 98 00 00 00    	jb     f0107e78 <__udivdi3+0x108>
f0107de0:	31 ff                	xor    %edi,%edi
f0107de2:	31 c9                	xor    %ecx,%ecx
f0107de4:	89 c8                	mov    %ecx,%eax
f0107de6:	89 fa                	mov    %edi,%edx
f0107de8:	83 c4 10             	add    $0x10,%esp
f0107deb:	5e                   	pop    %esi
f0107dec:	5f                   	pop    %edi
f0107ded:	5d                   	pop    %ebp
f0107dee:	c3                   	ret    
f0107def:	90                   	nop
f0107df0:	89 d1                	mov    %edx,%ecx
f0107df2:	89 fa                	mov    %edi,%edx
f0107df4:	89 c8                	mov    %ecx,%eax
f0107df6:	31 ff                	xor    %edi,%edi
f0107df8:	f7 f6                	div    %esi
f0107dfa:	89 c1                	mov    %eax,%ecx
f0107dfc:	89 fa                	mov    %edi,%edx
f0107dfe:	89 c8                	mov    %ecx,%eax
f0107e00:	83 c4 10             	add    $0x10,%esp
f0107e03:	5e                   	pop    %esi
f0107e04:	5f                   	pop    %edi
f0107e05:	5d                   	pop    %ebp
f0107e06:	c3                   	ret    
f0107e07:	90                   	nop
f0107e08:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
f0107e0c:	89 f2                	mov    %esi,%edx
f0107e0e:	d3 e0                	shl    %cl,%eax
f0107e10:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0107e13:	b8 20 00 00 00       	mov    $0x20,%eax
f0107e18:	2b 45 f4             	sub    -0xc(%ebp),%eax
f0107e1b:	89 c1                	mov    %eax,%ecx
f0107e1d:	d3 ea                	shr    %cl,%edx
f0107e1f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
f0107e23:	0b 55 ec             	or     -0x14(%ebp),%edx
f0107e26:	d3 e6                	shl    %cl,%esi
f0107e28:	89 c1                	mov    %eax,%ecx
f0107e2a:	89 75 e8             	mov    %esi,-0x18(%ebp)
f0107e2d:	89 fe                	mov    %edi,%esi
f0107e2f:	d3 ee                	shr    %cl,%esi
f0107e31:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
f0107e35:	89 55 ec             	mov    %edx,-0x14(%ebp)
f0107e38:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0107e3b:	d3 e7                	shl    %cl,%edi
f0107e3d:	89 c1                	mov    %eax,%ecx
f0107e3f:	d3 ea                	shr    %cl,%edx
f0107e41:	09 d7                	or     %edx,%edi
f0107e43:	89 f2                	mov    %esi,%edx
f0107e45:	89 f8                	mov    %edi,%eax
f0107e47:	f7 75 ec             	divl   -0x14(%ebp)
f0107e4a:	89 d6                	mov    %edx,%esi
f0107e4c:	89 c7                	mov    %eax,%edi
f0107e4e:	f7 65 e8             	mull   -0x18(%ebp)
f0107e51:	39 d6                	cmp    %edx,%esi
f0107e53:	89 55 ec             	mov    %edx,-0x14(%ebp)
f0107e56:	72 30                	jb     f0107e88 <__udivdi3+0x118>
f0107e58:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0107e5b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
f0107e5f:	d3 e2                	shl    %cl,%edx
f0107e61:	39 c2                	cmp    %eax,%edx
f0107e63:	73 05                	jae    f0107e6a <__udivdi3+0xfa>
f0107e65:	3b 75 ec             	cmp    -0x14(%ebp),%esi
f0107e68:	74 1e                	je     f0107e88 <__udivdi3+0x118>
f0107e6a:	89 f9                	mov    %edi,%ecx
f0107e6c:	31 ff                	xor    %edi,%edi
f0107e6e:	e9 71 ff ff ff       	jmp    f0107de4 <__udivdi3+0x74>
f0107e73:	90                   	nop
f0107e74:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0107e78:	31 ff                	xor    %edi,%edi
f0107e7a:	b9 01 00 00 00       	mov    $0x1,%ecx
f0107e7f:	e9 60 ff ff ff       	jmp    f0107de4 <__udivdi3+0x74>
f0107e84:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0107e88:	8d 4f ff             	lea    -0x1(%edi),%ecx
f0107e8b:	31 ff                	xor    %edi,%edi
f0107e8d:	89 c8                	mov    %ecx,%eax
f0107e8f:	89 fa                	mov    %edi,%edx
f0107e91:	83 c4 10             	add    $0x10,%esp
f0107e94:	5e                   	pop    %esi
f0107e95:	5f                   	pop    %edi
f0107e96:	5d                   	pop    %ebp
f0107e97:	c3                   	ret    
	...

f0107ea0 <__umoddi3>:
f0107ea0:	55                   	push   %ebp
f0107ea1:	89 e5                	mov    %esp,%ebp
f0107ea3:	57                   	push   %edi
f0107ea4:	56                   	push   %esi
f0107ea5:	83 ec 20             	sub    $0x20,%esp
f0107ea8:	8b 55 14             	mov    0x14(%ebp),%edx
f0107eab:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0107eae:	8b 7d 10             	mov    0x10(%ebp),%edi
f0107eb1:	8b 75 0c             	mov    0xc(%ebp),%esi
f0107eb4:	85 d2                	test   %edx,%edx
f0107eb6:	89 c8                	mov    %ecx,%eax
f0107eb8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
f0107ebb:	75 13                	jne    f0107ed0 <__umoddi3+0x30>
f0107ebd:	39 f7                	cmp    %esi,%edi
f0107ebf:	76 3f                	jbe    f0107f00 <__umoddi3+0x60>
f0107ec1:	89 f2                	mov    %esi,%edx
f0107ec3:	f7 f7                	div    %edi
f0107ec5:	89 d0                	mov    %edx,%eax
f0107ec7:	31 d2                	xor    %edx,%edx
f0107ec9:	83 c4 20             	add    $0x20,%esp
f0107ecc:	5e                   	pop    %esi
f0107ecd:	5f                   	pop    %edi
f0107ece:	5d                   	pop    %ebp
f0107ecf:	c3                   	ret    
f0107ed0:	39 f2                	cmp    %esi,%edx
f0107ed2:	77 4c                	ja     f0107f20 <__umoddi3+0x80>
f0107ed4:	0f bd ca             	bsr    %edx,%ecx
f0107ed7:	83 f1 1f             	xor    $0x1f,%ecx
f0107eda:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0107edd:	75 51                	jne    f0107f30 <__umoddi3+0x90>
f0107edf:	3b 7d f4             	cmp    -0xc(%ebp),%edi
f0107ee2:	0f 87 e0 00 00 00    	ja     f0107fc8 <__umoddi3+0x128>
f0107ee8:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0107eeb:	29 f8                	sub    %edi,%eax
f0107eed:	19 d6                	sbb    %edx,%esi
f0107eef:	89 45 f4             	mov    %eax,-0xc(%ebp)
f0107ef2:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0107ef5:	89 f2                	mov    %esi,%edx
f0107ef7:	83 c4 20             	add    $0x20,%esp
f0107efa:	5e                   	pop    %esi
f0107efb:	5f                   	pop    %edi
f0107efc:	5d                   	pop    %ebp
f0107efd:	c3                   	ret    
f0107efe:	66 90                	xchg   %ax,%ax
f0107f00:	85 ff                	test   %edi,%edi
f0107f02:	75 0b                	jne    f0107f0f <__umoddi3+0x6f>
f0107f04:	b8 01 00 00 00       	mov    $0x1,%eax
f0107f09:	31 d2                	xor    %edx,%edx
f0107f0b:	f7 f7                	div    %edi
f0107f0d:	89 c7                	mov    %eax,%edi
f0107f0f:	89 f0                	mov    %esi,%eax
f0107f11:	31 d2                	xor    %edx,%edx
f0107f13:	f7 f7                	div    %edi
f0107f15:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0107f18:	f7 f7                	div    %edi
f0107f1a:	eb a9                	jmp    f0107ec5 <__umoddi3+0x25>
f0107f1c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0107f20:	89 c8                	mov    %ecx,%eax
f0107f22:	89 f2                	mov    %esi,%edx
f0107f24:	83 c4 20             	add    $0x20,%esp
f0107f27:	5e                   	pop    %esi
f0107f28:	5f                   	pop    %edi
f0107f29:	5d                   	pop    %ebp
f0107f2a:	c3                   	ret    
f0107f2b:	90                   	nop
f0107f2c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0107f30:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0107f34:	d3 e2                	shl    %cl,%edx
f0107f36:	89 55 f4             	mov    %edx,-0xc(%ebp)
f0107f39:	ba 20 00 00 00       	mov    $0x20,%edx
f0107f3e:	2b 55 f0             	sub    -0x10(%ebp),%edx
f0107f41:	89 55 ec             	mov    %edx,-0x14(%ebp)
f0107f44:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f0107f48:	89 fa                	mov    %edi,%edx
f0107f4a:	d3 ea                	shr    %cl,%edx
f0107f4c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0107f50:	0b 55 f4             	or     -0xc(%ebp),%edx
f0107f53:	d3 e7                	shl    %cl,%edi
f0107f55:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f0107f59:	89 55 f4             	mov    %edx,-0xc(%ebp)
f0107f5c:	89 f2                	mov    %esi,%edx
f0107f5e:	89 7d e8             	mov    %edi,-0x18(%ebp)
f0107f61:	89 c7                	mov    %eax,%edi
f0107f63:	d3 ea                	shr    %cl,%edx
f0107f65:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0107f69:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0107f6c:	89 c2                	mov    %eax,%edx
f0107f6e:	d3 e6                	shl    %cl,%esi
f0107f70:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f0107f74:	d3 ea                	shr    %cl,%edx
f0107f76:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0107f7a:	09 d6                	or     %edx,%esi
f0107f7c:	89 f0                	mov    %esi,%eax
f0107f7e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0107f81:	d3 e7                	shl    %cl,%edi
f0107f83:	89 f2                	mov    %esi,%edx
f0107f85:	f7 75 f4             	divl   -0xc(%ebp)
f0107f88:	89 d6                	mov    %edx,%esi
f0107f8a:	f7 65 e8             	mull   -0x18(%ebp)
f0107f8d:	39 d6                	cmp    %edx,%esi
f0107f8f:	72 2b                	jb     f0107fbc <__umoddi3+0x11c>
f0107f91:	39 c7                	cmp    %eax,%edi
f0107f93:	72 23                	jb     f0107fb8 <__umoddi3+0x118>
f0107f95:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0107f99:	29 c7                	sub    %eax,%edi
f0107f9b:	19 d6                	sbb    %edx,%esi
f0107f9d:	89 f0                	mov    %esi,%eax
f0107f9f:	89 f2                	mov    %esi,%edx
f0107fa1:	d3 ef                	shr    %cl,%edi
f0107fa3:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f0107fa7:	d3 e0                	shl    %cl,%eax
f0107fa9:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0107fad:	09 f8                	or     %edi,%eax
f0107faf:	d3 ea                	shr    %cl,%edx
f0107fb1:	83 c4 20             	add    $0x20,%esp
f0107fb4:	5e                   	pop    %esi
f0107fb5:	5f                   	pop    %edi
f0107fb6:	5d                   	pop    %ebp
f0107fb7:	c3                   	ret    
f0107fb8:	39 d6                	cmp    %edx,%esi
f0107fba:	75 d9                	jne    f0107f95 <__umoddi3+0xf5>
f0107fbc:	2b 45 e8             	sub    -0x18(%ebp),%eax
f0107fbf:	1b 55 f4             	sbb    -0xc(%ebp),%edx
f0107fc2:	eb d1                	jmp    f0107f95 <__umoddi3+0xf5>
f0107fc4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0107fc8:	39 f2                	cmp    %esi,%edx
f0107fca:	0f 82 18 ff ff ff    	jb     f0107ee8 <__umoddi3+0x48>
f0107fd0:	e9 1d ff ff ff       	jmp    f0107ef2 <__umoddi3+0x52>
