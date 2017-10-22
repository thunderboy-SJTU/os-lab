
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
f0100015:	b8 00 60 12 00       	mov    $0x126000,%eax
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
f0100034:	bc 00 60 12 f0       	mov    $0xf0126000,%esp

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
f0100058:	c7 04 24 20 8d 10 f0 	movl   $0xf0108d20,(%esp)
f010005f:	e8 ab 4b 00 00       	call   f0104c0f <cprintf>
	vcprintf(fmt, ap);
f0100064:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100068:	8b 45 10             	mov    0x10(%ebp),%eax
f010006b:	89 04 24             	mov    %eax,(%esp)
f010006e:	e8 69 4b 00 00       	call   f0104bdc <vcprintf>
	cprintf("\n");
f0100073:	c7 04 24 19 92 10 f0 	movl   $0xf0109219,(%esp)
f010007a:	e8 90 4b 00 00       	call   f0104c0f <cprintf>
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
f0100090:	83 3d ac 3e 29 f0 00 	cmpl   $0x0,0xf0293eac
f0100097:	75 46                	jne    f01000df <_panic+0x5a>
		goto dead;
	panicstr = fmt;
f0100099:	89 35 ac 3e 29 f0    	mov    %esi,0xf0293eac

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
f01000a4:	e8 f5 7a 00 00       	call   f0107b9e <cpunum>
f01000a9:	8b 55 0c             	mov    0xc(%ebp),%edx
f01000ac:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01000b0:	8b 55 08             	mov    0x8(%ebp),%edx
f01000b3:	89 54 24 08          	mov    %edx,0x8(%esp)
f01000b7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01000bb:	c7 04 24 78 8d 10 f0 	movl   $0xf0108d78,(%esp)
f01000c2:	e8 48 4b 00 00       	call   f0104c0f <cprintf>
	vcprintf(fmt, ap);
f01000c7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01000cb:	89 34 24             	mov    %esi,(%esp)
f01000ce:	e8 09 4b 00 00       	call   f0104bdc <vcprintf>
	cprintf("\n");
f01000d3:	c7 04 24 19 92 10 f0 	movl   $0xf0109219,(%esp)
f01000da:	e8 30 4b 00 00       	call   f0104c0f <cprintf>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f01000df:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01000e6:	e8 be 0a 00 00       	call   f0100ba9 <monitor>
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
f01000f3:	a1 b8 3e 29 f0       	mov    0xf0293eb8,%eax
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
f0100105:	c7 44 24 08 9c 8d 10 	movl   $0xf0108d9c,0x8(%esp)
f010010c:	f0 
f010010d:	c7 44 24 04 aa 00 00 	movl   $0xaa,0x4(%esp)
f0100114:	00 
f0100115:	c7 04 24 3a 8d 10 f0 	movl   $0xf0108d3a,(%esp)
f010011c:	e8 64 ff ff ff       	call   f0100085 <_panic>
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0100121:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f0100127:	0f 22 da             	mov    %edx,%cr3
	cprintf("SMP: CPU %d starting\n", cpunum());
f010012a:	e8 6f 7a 00 00       	call   f0107b9e <cpunum>
f010012f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100133:	c7 04 24 46 8d 10 f0 	movl   $0xf0108d46,(%esp)
f010013a:	e8 d0 4a 00 00       	call   f0104c0f <cprintf>

	lapic_init();
f010013f:	e8 76 7a 00 00       	call   f0107bba <lapic_init>
	env_init_percpu();
f0100144:	e8 77 41 00 00       	call   f01042c0 <env_init_percpu>
	trap_init_percpu();
f0100149:	e8 f2 4a 00 00       	call   f0104c40 <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f010014e:	66 90                	xchg   %ax,%ax
f0100150:	e8 49 7a 00 00       	call   f0107b9e <cpunum>
f0100155:	6b d0 74             	imul   $0x74,%eax,%edx
f0100158:	81 c2 24 40 29 f0    	add    $0xf0294024,%edx
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
f0100166:	c7 04 24 80 83 12 f0 	movl   $0xf0128380,(%esp)
f010016d:	e8 f3 7d 00 00       	call   f0107f65 <spin_lock>
	// to start running processes on this CPU.  But make sure that
	// only one CPU can enter the scheduler at a time!
	//
	// Your code here:
        lock_kernel();
        sched_yield();
f0100172:	e8 19 59 00 00       	call   f0105a90 <sched_yield>

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
f010017f:	b8 60 58 2f f0       	mov    $0xf02f5860,%eax
f0100184:	2d 0b 28 29 f0       	sub    $0xf029280b,%eax
f0100189:	89 44 24 08          	mov    %eax,0x8(%esp)
f010018d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100194:	00 
f0100195:	c7 04 24 0b 28 29 f0 	movl   $0xf029280b,(%esp)
f010019c:	e8 55 73 00 00       	call   f01074f6 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01001a1:	e8 af 06 00 00       	call   f0100855 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01001a6:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f01001ad:	00 
f01001ae:	c7 04 24 5c 8d 10 f0 	movl   $0xf0108d5c,(%esp)
f01001b5:	e8 55 4a 00 00       	call   f0104c0f <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f01001ba:	e8 b0 27 00 00       	call   f010296f <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f01001bf:	e8 26 41 00 00       	call   f01042ea <env_init>
	trap_init();
f01001c4:	e8 20 4b 00 00       	call   f0104ce9 <trap_init>

	// Lab 4 multiprocessor initialization functions
	mp_init();
f01001c9:	e8 ec 76 00 00       	call   f01078ba <mp_init>
	lapic_init();
f01001ce:	66 90                	xchg   %ax,%ax
f01001d0:	e8 e5 79 00 00       	call   f0107bba <lapic_init>

	// Lab 4 multitasking initialization functions
	pic_init();
f01001d5:	e8 76 49 00 00       	call   f0104b50 <pic_init>

	// Lab 6 hardware initialization functions
	time_init();
f01001da:	e8 61 88 00 00       	call   f0108a40 <time_init>
	pci_init();
f01001df:	90                   	nop
f01001e0:	e8 c3 85 00 00       	call   f01087a8 <pci_init>
f01001e5:	c7 04 24 80 83 12 f0 	movl   $0xf0128380,(%esp)
f01001ec:	e8 74 7d 00 00       	call   f0107f65 <spin_lock>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01001f1:	83 3d b4 3e 29 f0 07 	cmpl   $0x7,0xf0293eb4
f01001f8:	77 24                	ja     f010021e <i386_init+0xa7>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01001fa:	c7 44 24 0c 00 70 00 	movl   $0x7000,0xc(%esp)
f0100201:	00 
f0100202:	c7 44 24 08 c0 8d 10 	movl   $0xf0108dc0,0x8(%esp)
f0100209:	f0 
f010020a:	c7 44 24 04 93 00 00 	movl   $0x93,0x4(%esp)
f0100211:	00 
f0100212:	c7 04 24 3a 8d 10 f0 	movl   $0xf0108d3a,(%esp)
f0100219:	e8 67 fe ff ff       	call   f0100085 <_panic>
	void *code;
	struct Cpu *c;

	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f010021e:	b8 d6 77 10 f0       	mov    $0xf01077d6,%eax
f0100223:	2d 5c 77 10 f0       	sub    $0xf010775c,%eax
f0100228:	89 44 24 08          	mov    %eax,0x8(%esp)
f010022c:	c7 44 24 04 5c 77 10 	movl   $0xf010775c,0x4(%esp)
f0100233:	f0 
f0100234:	c7 04 24 00 70 00 f0 	movl   $0xf0007000,(%esp)
f010023b:	e8 15 73 00 00       	call   f0107555 <memmove>

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f0100240:	6b 05 c4 43 29 f0 74 	imul   $0x74,0xf02943c4,%eax
f0100247:	05 20 40 29 f0       	add    $0xf0294020,%eax
f010024c:	3d 20 40 29 f0       	cmp    $0xf0294020,%eax
f0100251:	76 65                	jbe    f01002b8 <i386_init+0x141>
f0100253:	be 00 00 00 00       	mov    $0x0,%esi
f0100258:	bb 20 40 29 f0       	mov    $0xf0294020,%ebx
		if (c == cpus + cpunum())  // We've started already.
f010025d:	e8 3c 79 00 00       	call   f0107b9e <cpunum>
f0100262:	6b c0 74             	imul   $0x74,%eax,%eax
f0100265:	05 20 40 29 f0       	add    $0xf0294020,%eax
f010026a:	39 c3                	cmp    %eax,%ebx
f010026c:	74 34                	je     f01002a2 <i386_init+0x12b>
			continue;

		// Tell mpentry.S what stack to use 
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f010026e:	89 f0                	mov    %esi,%eax
f0100270:	c1 f8 02             	sar    $0x2,%eax
f0100273:	69 c0 35 c2 72 4f    	imul   $0x4f72c235,%eax,%eax
f0100279:	c1 e0 0f             	shl    $0xf,%eax
f010027c:	8d 80 00 d0 29 f0    	lea    -0xfd63000(%eax),%eax
f0100282:	a3 b0 3e 29 f0       	mov    %eax,0xf0293eb0
		// Start the CPU at mpentry_start
		lapic_startap(c->cpu_id, PADDR(code));
f0100287:	c7 44 24 04 00 70 00 	movl   $0x7000,0x4(%esp)
f010028e:	00 
f010028f:	0f b6 03             	movzbl (%ebx),%eax
f0100292:	89 04 24             	mov    %eax,(%esp)
f0100295:	e8 8a 7a 00 00       	call   f0107d24 <lapic_startap>
		// Wait for the CPU to finish some basic setup in mp_main()
		while(c->cpu_status != CPU_STARTED)
f010029a:	8b 43 04             	mov    0x4(%ebx),%eax
f010029d:	83 f8 01             	cmp    $0x1,%eax
f01002a0:	75 f8                	jne    f010029a <i386_init+0x123>
	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f01002a2:	83 c3 74             	add    $0x74,%ebx
f01002a5:	83 c6 74             	add    $0x74,%esi
f01002a8:	6b 05 c4 43 29 f0 74 	imul   $0x74,0xf02943c4,%eax
f01002af:	05 20 40 29 f0       	add    $0xf0294020,%eax
f01002b4:	39 c3                	cmp    %eax,%ebx
f01002b6:	72 a5                	jb     f010025d <i386_init+0xe6>
f01002b8:	bb 00 00 00 00       	mov    $0x0,%ebx
#endif

	// Should always have idle processes at first.
	int i;
	for (i = 0; i < NCPU; i++)
		ENV_CREATE(user_idle, ENV_TYPE_IDLE);
f01002bd:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01002c4:	00 
f01002c5:	c7 44 24 04 1b 50 00 	movl   $0x501b,0x4(%esp)
f01002cc:	00 
f01002cd:	c7 04 24 eb 36 17 f0 	movl   $0xf01736eb,(%esp)
f01002d4:	e8 42 46 00 00       	call   f010491b <env_create>
	lock_kernel();
#endif

	// Should always have idle processes at first.
	int i;
	for (i = 0; i < NCPU; i++)
f01002d9:	83 c3 01             	add    $0x1,%ebx
f01002dc:	83 fb 08             	cmp    $0x8,%ebx
f01002df:	75 dc                	jne    f01002bd <i386_init+0x146>
		ENV_CREATE(user_idle, ENV_TYPE_IDLE);

	// Start fs.
	ENV_CREATE(fs_fs, ENV_TYPE_FS);
f01002e1:	c7 44 24 08 02 00 00 	movl   $0x2,0x8(%esp)
f01002e8:	00 
f01002e9:	c7 44 24 04 66 a7 01 	movl   $0x1a766,0x4(%esp)
f01002f0:	00 
f01002f1:	c7 04 24 1b d5 1e f0 	movl   $0xf01ed51b,(%esp)
f01002f8:	e8 1e 46 00 00       	call   f010491b <env_create>

#if !defined(TEST_NO_NS)
	// Start ns.
	ENV_CREATE(net_ns, ENV_TYPE_NS);
f01002fd:	c7 44 24 08 03 00 00 	movl   $0x3,0x8(%esp)
f0100304:	00 
f0100305:	c7 44 24 04 69 c1 04 	movl   $0x4c169,0x4(%esp)
f010030c:	00 
f010030d:	c7 04 24 a2 66 24 f0 	movl   $0xf02466a2,(%esp)
f0100314:	e8 02 46 00 00       	call   f010491b <env_create>
#endif

#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
f0100319:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0100320:	00 
f0100321:	c7 44 24 04 26 61 00 	movl   $0x6126,0x4(%esp)
f0100328:	00 
f0100329:	c7 04 24 a2 2e 21 f0 	movl   $0xf0212ea2,(%esp)
f0100330:	e8 e6 45 00 00       	call   f010491b <env_create>
        ENV_CREATE(user_httpd,ENV_TYPE_NS);

#endif // TEST*

	// Schedule and run the first user environment!
	sched_yield();
f0100335:	e8 56 57 00 00       	call   f0105a90 <sched_yield>

f010033a <spinlock_test>:
static void boot_aps(void);

static volatile int test_ctr = 0;

void spinlock_test()
{
f010033a:	55                   	push   %ebp
f010033b:	89 e5                	mov    %esp,%ebp
f010033d:	56                   	push   %esi
f010033e:	53                   	push   %ebx
f010033f:	83 ec 20             	sub    $0x20,%esp
	int i;
	volatile int interval = 0;
f0100342:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	/* BSP give APs some time to reach this point */
	if (cpunum() == 0) {
f0100349:	e8 50 78 00 00       	call   f0107b9e <cpunum>
f010034e:	85 c0                	test   %eax,%eax
f0100350:	75 10                	jne    f0100362 <spinlock_test+0x28>
		while (interval++ < 10000)
f0100352:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100355:	8d 50 01             	lea    0x1(%eax),%edx
f0100358:	89 55 f4             	mov    %edx,-0xc(%ebp)
f010035b:	3d 0f 27 00 00       	cmp    $0x270f,%eax
f0100360:	7e 0c                	jle    f010036e <spinlock_test+0x34>
f0100362:	bb 00 00 00 00       	mov    $0x0,%ebx
			asm volatile("pause");
	}

	for (i=0; i<100; i++) {
		lock_kernel();
		if (test_ctr % 10000 != 0)
f0100367:	be ad 8b db 68       	mov    $0x68db8bad,%esi
f010036c:	eb 14                	jmp    f0100382 <spinlock_test+0x48>
	volatile int interval = 0;

	/* BSP give APs some time to reach this point */
	if (cpunum() == 0) {
		while (interval++ < 10000)
			asm volatile("pause");
f010036e:	f3 90                	pause  
	int i;
	volatile int interval = 0;

	/* BSP give APs some time to reach this point */
	if (cpunum() == 0) {
		while (interval++ < 10000)
f0100370:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100373:	8d 50 01             	lea    0x1(%eax),%edx
f0100376:	89 55 f4             	mov    %edx,-0xc(%ebp)
f0100379:	3d 0f 27 00 00       	cmp    $0x270f,%eax
f010037e:	7e ee                	jle    f010036e <spinlock_test+0x34>
f0100380:	eb e0                	jmp    f0100362 <spinlock_test+0x28>
f0100382:	c7 04 24 80 83 12 f0 	movl   $0xf0128380,(%esp)
f0100389:	e8 d7 7b 00 00       	call   f0107f65 <spin_lock>
			asm volatile("pause");
	}

	for (i=0; i<100; i++) {
		lock_kernel();
		if (test_ctr % 10000 != 0)
f010038e:	8b 0d 00 30 29 f0    	mov    0xf0293000,%ecx
f0100394:	89 c8                	mov    %ecx,%eax
f0100396:	f7 ee                	imul   %esi
f0100398:	c1 fa 0c             	sar    $0xc,%edx
f010039b:	89 c8                	mov    %ecx,%eax
f010039d:	c1 f8 1f             	sar    $0x1f,%eax
f01003a0:	29 c2                	sub    %eax,%edx
f01003a2:	69 d2 10 27 00 00    	imul   $0x2710,%edx,%edx
f01003a8:	39 d1                	cmp    %edx,%ecx
f01003aa:	74 1c                	je     f01003c8 <spinlock_test+0x8e>
			panic("ticket spinlock test fail: I saw a middle value\n");
f01003ac:	c7 44 24 08 e4 8d 10 	movl   $0xf0108de4,0x8(%esp)
f01003b3:	f0 
f01003b4:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
f01003bb:	00 
f01003bc:	c7 04 24 3a 8d 10 f0 	movl   $0xf0108d3a,(%esp)
f01003c3:	e8 bd fc ff ff       	call   f0100085 <_panic>
		interval = 0;
f01003c8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
		while (interval++ < 10000)
f01003cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01003d2:	8d 50 01             	lea    0x1(%eax),%edx
f01003d5:	89 55 f4             	mov    %edx,-0xc(%ebp)
f01003d8:	3d 0f 27 00 00       	cmp    $0x270f,%eax
f01003dd:	7f 1d                	jg     f01003fc <spinlock_test+0xc2>
			test_ctr++;
f01003df:	a1 00 30 29 f0       	mov    0xf0293000,%eax
f01003e4:	83 c0 01             	add    $0x1,%eax
f01003e7:	a3 00 30 29 f0       	mov    %eax,0xf0293000
	for (i=0; i<100; i++) {
		lock_kernel();
		if (test_ctr % 10000 != 0)
			panic("ticket spinlock test fail: I saw a middle value\n");
		interval = 0;
		while (interval++ < 10000)
f01003ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01003ef:	8d 50 01             	lea    0x1(%eax),%edx
f01003f2:	89 55 f4             	mov    %edx,-0xc(%ebp)
f01003f5:	3d 0f 27 00 00       	cmp    $0x270f,%eax
f01003fa:	7e e3                	jle    f01003df <spinlock_test+0xa5>
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f01003fc:	c7 04 24 80 83 12 f0 	movl   $0xf0128380,(%esp)
f0100403:	e8 44 7a 00 00       	call   f0107e4c <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0100408:	f3 90                	pause  
	if (cpunum() == 0) {
		while (interval++ < 10000)
			asm volatile("pause");
	}

	for (i=0; i<100; i++) {
f010040a:	83 c3 01             	add    $0x1,%ebx
f010040d:	83 fb 64             	cmp    $0x64,%ebx
f0100410:	0f 85 6c ff ff ff    	jne    f0100382 <spinlock_test+0x48>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f0100416:	c7 04 24 80 83 12 f0 	movl   $0xf0128380,(%esp)
f010041d:	e8 43 7b 00 00       	call   f0107f65 <spin_lock>
		while (interval++ < 10000)
			test_ctr++;
		unlock_kernel();
	}
	lock_kernel();
	cprintf("spinlock_test() succeeded on CPU %d!\n", cpunum());
f0100422:	e8 77 77 00 00       	call   f0107b9e <cpunum>
f0100427:	89 44 24 04          	mov    %eax,0x4(%esp)
f010042b:	c7 04 24 18 8e 10 f0 	movl   $0xf0108e18,(%esp)
f0100432:	e8 d8 47 00 00       	call   f0104c0f <cprintf>
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0100437:	c7 04 24 80 83 12 f0 	movl   $0xf0128380,(%esp)
f010043e:	e8 09 7a 00 00       	call   f0107e4c <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0100443:	f3 90                	pause  
	unlock_kernel();
}
f0100445:	83 c4 20             	add    $0x20,%esp
f0100448:	5b                   	pop    %ebx
f0100449:	5e                   	pop    %esi
f010044a:	5d                   	pop    %ebp
f010044b:	c3                   	ret    
f010044c:	00 00                	add    %al,(%eax)
	...

f0100450 <delay>:
static void cons_putc(int c);

// Stupid I/O delay routine necessitated by historical PC design flaws
static void
delay(void)
{
f0100450:	55                   	push   %ebp
f0100451:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100453:	ba 84 00 00 00       	mov    $0x84,%edx
f0100458:	ec                   	in     (%dx),%al
f0100459:	ec                   	in     (%dx),%al
f010045a:	ec                   	in     (%dx),%al
f010045b:	ec                   	in     (%dx),%al
	inb(0x84);
	inb(0x84);
	inb(0x84);
	inb(0x84);
}
f010045c:	5d                   	pop    %ebp
f010045d:	c3                   	ret    

f010045e <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f010045e:	55                   	push   %ebp
f010045f:	89 e5                	mov    %esp,%ebp
f0100461:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100466:	ec                   	in     (%dx),%al
f0100467:	89 c2                	mov    %eax,%edx
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f0100469:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010046e:	f6 c2 01             	test   $0x1,%dl
f0100471:	74 09                	je     f010047c <serial_proc_data+0x1e>
f0100473:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100478:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f0100479:	0f b6 c0             	movzbl %al,%eax
}
f010047c:	5d                   	pop    %ebp
f010047d:	c3                   	ret    

f010047e <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f010047e:	55                   	push   %ebp
f010047f:	89 e5                	mov    %esp,%ebp
f0100481:	57                   	push   %edi
f0100482:	56                   	push   %esi
f0100483:	53                   	push   %ebx
f0100484:	83 ec 0c             	sub    $0xc,%esp
f0100487:	89 c6                	mov    %eax,%esi
	int c;

	while ((c = (*proc)()) != -1) {
		if (c == 0)
			continue;
		cons.buf[cons.wpos++] = c;
f0100489:	bb 44 32 29 f0       	mov    $0xf0293244,%ebx
f010048e:	bf 40 30 29 f0       	mov    $0xf0293040,%edi
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f0100493:	eb 1e                	jmp    f01004b3 <cons_intr+0x35>
		if (c == 0)
f0100495:	85 c0                	test   %eax,%eax
f0100497:	74 1a                	je     f01004b3 <cons_intr+0x35>
			continue;
		cons.buf[cons.wpos++] = c;
f0100499:	8b 13                	mov    (%ebx),%edx
f010049b:	88 04 17             	mov    %al,(%edi,%edx,1)
f010049e:	8d 42 01             	lea    0x1(%edx),%eax
		if (cons.wpos == CONSBUFSIZE)
f01004a1:	3d 00 02 00 00       	cmp    $0x200,%eax
			cons.wpos = 0;
f01004a6:	0f 94 c2             	sete   %dl
f01004a9:	0f b6 d2             	movzbl %dl,%edx
f01004ac:	83 ea 01             	sub    $0x1,%edx
f01004af:	21 d0                	and    %edx,%eax
f01004b1:	89 03                	mov    %eax,(%ebx)
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f01004b3:	ff d6                	call   *%esi
f01004b5:	83 f8 ff             	cmp    $0xffffffff,%eax
f01004b8:	75 db                	jne    f0100495 <cons_intr+0x17>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f01004ba:	83 c4 0c             	add    $0xc,%esp
f01004bd:	5b                   	pop    %ebx
f01004be:	5e                   	pop    %esi
f01004bf:	5f                   	pop    %edi
f01004c0:	5d                   	pop    %ebp
f01004c1:	c3                   	ret    

f01004c2 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f01004c2:	55                   	push   %ebp
f01004c3:	89 e5                	mov    %esp,%ebp
f01004c5:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f01004c8:	b8 5a 07 10 f0       	mov    $0xf010075a,%eax
f01004cd:	e8 ac ff ff ff       	call   f010047e <cons_intr>
}
f01004d2:	c9                   	leave  
f01004d3:	c3                   	ret    

f01004d4 <serial_intr>:
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f01004d4:	55                   	push   %ebp
f01004d5:	89 e5                	mov    %esp,%ebp
f01004d7:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
f01004da:	83 3d 24 30 29 f0 00 	cmpl   $0x0,0xf0293024
f01004e1:	74 0a                	je     f01004ed <serial_intr+0x19>
		cons_intr(serial_proc_data);
f01004e3:	b8 5e 04 10 f0       	mov    $0xf010045e,%eax
f01004e8:	e8 91 ff ff ff       	call   f010047e <cons_intr>
}
f01004ed:	c9                   	leave  
f01004ee:	c3                   	ret    

f01004ef <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f01004ef:	55                   	push   %ebp
f01004f0:	89 e5                	mov    %esp,%ebp
f01004f2:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f01004f5:	e8 da ff ff ff       	call   f01004d4 <serial_intr>
	kbd_intr();
f01004fa:	e8 c3 ff ff ff       	call   f01004c2 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f01004ff:	8b 15 40 32 29 f0    	mov    0xf0293240,%edx
f0100505:	b8 00 00 00 00       	mov    $0x0,%eax
f010050a:	3b 15 44 32 29 f0    	cmp    0xf0293244,%edx
f0100510:	74 21                	je     f0100533 <cons_getc+0x44>
		c = cons.buf[cons.rpos++];
f0100512:	0f b6 82 40 30 29 f0 	movzbl -0xfd6cfc0(%edx),%eax
f0100519:	83 c2 01             	add    $0x1,%edx
		if (cons.rpos == CONSBUFSIZE)
f010051c:	81 fa 00 02 00 00    	cmp    $0x200,%edx
			cons.rpos = 0;
f0100522:	0f 94 c1             	sete   %cl
f0100525:	0f b6 c9             	movzbl %cl,%ecx
f0100528:	83 e9 01             	sub    $0x1,%ecx
f010052b:	21 ca                	and    %ecx,%edx
f010052d:	89 15 40 32 29 f0    	mov    %edx,0xf0293240
		return c;
	}
	return 0;
}
f0100533:	c9                   	leave  
f0100534:	c3                   	ret    

f0100535 <getchar>:
	cons_putc(c);
}

int
getchar(void)
{
f0100535:	55                   	push   %ebp
f0100536:	89 e5                	mov    %esp,%ebp
f0100538:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f010053b:	e8 af ff ff ff       	call   f01004ef <cons_getc>
f0100540:	85 c0                	test   %eax,%eax
f0100542:	74 f7                	je     f010053b <getchar+0x6>
		/* do nothing */;
	return c;
}
f0100544:	c9                   	leave  
f0100545:	c3                   	ret    

f0100546 <iscons>:

int
iscons(int fdnum)
{
f0100546:	55                   	push   %ebp
f0100547:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f0100549:	b8 01 00 00 00       	mov    $0x1,%eax
f010054e:	5d                   	pop    %ebp
f010054f:	c3                   	ret    

f0100550 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f0100550:	55                   	push   %ebp
f0100551:	89 e5                	mov    %esp,%ebp
f0100553:	57                   	push   %edi
f0100554:	56                   	push   %esi
f0100555:	53                   	push   %ebx
f0100556:	83 ec 2c             	sub    $0x2c,%esp
f0100559:	89 c7                	mov    %eax,%edi
f010055b:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100560:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;
	
	for (i = 0;
f0100561:	a8 20                	test   $0x20,%al
f0100563:	75 21                	jne    f0100586 <cons_putc+0x36>
f0100565:	bb 00 00 00 00       	mov    $0x0,%ebx
f010056a:	be fd 03 00 00       	mov    $0x3fd,%esi
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
		delay();
f010056f:	e8 dc fe ff ff       	call   f0100450 <delay>
f0100574:	89 f2                	mov    %esi,%edx
f0100576:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;
	
	for (i = 0;
f0100577:	a8 20                	test   $0x20,%al
f0100579:	75 0b                	jne    f0100586 <cons_putc+0x36>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
f010057b:	83 c3 01             	add    $0x1,%ebx
static void
serial_putc(int c)
{
	int i;
	
	for (i = 0;
f010057e:	81 fb 00 32 00 00    	cmp    $0x3200,%ebx
f0100584:	75 e9                	jne    f010056f <cons_putc+0x1f>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
		delay();
	
	outb(COM1 + COM_TX, c);
f0100586:	89 fa                	mov    %edi,%edx
f0100588:	89 f8                	mov    %edi,%eax
f010058a:	88 55 e7             	mov    %dl,-0x19(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010058d:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100592:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100593:	b2 79                	mov    $0x79,%dl
f0100595:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f0100596:	84 c0                	test   %al,%al
f0100598:	78 21                	js     f01005bb <cons_putc+0x6b>
f010059a:	bb 00 00 00 00       	mov    $0x0,%ebx
f010059f:	be 79 03 00 00       	mov    $0x379,%esi
		delay();
f01005a4:	e8 a7 fe ff ff       	call   f0100450 <delay>
f01005a9:	89 f2                	mov    %esi,%edx
f01005ab:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f01005ac:	84 c0                	test   %al,%al
f01005ae:	78 0b                	js     f01005bb <cons_putc+0x6b>
f01005b0:	83 c3 01             	add    $0x1,%ebx
f01005b3:	81 fb 00 32 00 00    	cmp    $0x3200,%ebx
f01005b9:	75 e9                	jne    f01005a4 <cons_putc+0x54>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01005bb:	ba 78 03 00 00       	mov    $0x378,%edx
f01005c0:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f01005c4:	ee                   	out    %al,(%dx)
f01005c5:	b2 7a                	mov    $0x7a,%dl
f01005c7:	b8 0d 00 00 00       	mov    $0xd,%eax
f01005cc:	ee                   	out    %al,(%dx)
f01005cd:	b8 08 00 00 00       	mov    $0x8,%eax
f01005d2:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f01005d3:	f7 c7 00 ff ff ff    	test   $0xffffff00,%edi
f01005d9:	75 06                	jne    f01005e1 <cons_putc+0x91>
		c |= 0x0700;
f01005db:	81 cf 00 07 00 00    	or     $0x700,%edi

	switch (c & 0xff) {
f01005e1:	89 f8                	mov    %edi,%eax
f01005e3:	25 ff 00 00 00       	and    $0xff,%eax
f01005e8:	83 f8 09             	cmp    $0x9,%eax
f01005eb:	0f 84 83 00 00 00    	je     f0100674 <cons_putc+0x124>
f01005f1:	83 f8 09             	cmp    $0x9,%eax
f01005f4:	7f 0c                	jg     f0100602 <cons_putc+0xb2>
f01005f6:	83 f8 08             	cmp    $0x8,%eax
f01005f9:	0f 85 a9 00 00 00    	jne    f01006a8 <cons_putc+0x158>
f01005ff:	90                   	nop
f0100600:	eb 18                	jmp    f010061a <cons_putc+0xca>
f0100602:	83 f8 0a             	cmp    $0xa,%eax
f0100605:	8d 76 00             	lea    0x0(%esi),%esi
f0100608:	74 40                	je     f010064a <cons_putc+0xfa>
f010060a:	83 f8 0d             	cmp    $0xd,%eax
f010060d:	8d 76 00             	lea    0x0(%esi),%esi
f0100610:	0f 85 92 00 00 00    	jne    f01006a8 <cons_putc+0x158>
f0100616:	66 90                	xchg   %ax,%ax
f0100618:	eb 38                	jmp    f0100652 <cons_putc+0x102>
	case '\b':
		if (crt_pos > 0) {
f010061a:	0f b7 05 30 30 29 f0 	movzwl 0xf0293030,%eax
f0100621:	66 85 c0             	test   %ax,%ax
f0100624:	0f 84 e8 00 00 00    	je     f0100712 <cons_putc+0x1c2>
			crt_pos--;
f010062a:	83 e8 01             	sub    $0x1,%eax
f010062d:	66 a3 30 30 29 f0    	mov    %ax,0xf0293030
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f0100633:	0f b7 c0             	movzwl %ax,%eax
f0100636:	66 81 e7 00 ff       	and    $0xff00,%di
f010063b:	83 cf 20             	or     $0x20,%edi
f010063e:	8b 15 2c 30 29 f0    	mov    0xf029302c,%edx
f0100644:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f0100648:	eb 7b                	jmp    f01006c5 <cons_putc+0x175>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f010064a:	66 83 05 30 30 29 f0 	addw   $0x50,0xf0293030
f0100651:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f0100652:	0f b7 05 30 30 29 f0 	movzwl 0xf0293030,%eax
f0100659:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f010065f:	c1 e8 10             	shr    $0x10,%eax
f0100662:	66 c1 e8 06          	shr    $0x6,%ax
f0100666:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0100669:	c1 e0 04             	shl    $0x4,%eax
f010066c:	66 a3 30 30 29 f0    	mov    %ax,0xf0293030
f0100672:	eb 51                	jmp    f01006c5 <cons_putc+0x175>
		break;
	case '\t':
		cons_putc(' ');
f0100674:	b8 20 00 00 00       	mov    $0x20,%eax
f0100679:	e8 d2 fe ff ff       	call   f0100550 <cons_putc>
		cons_putc(' ');
f010067e:	b8 20 00 00 00       	mov    $0x20,%eax
f0100683:	e8 c8 fe ff ff       	call   f0100550 <cons_putc>
		cons_putc(' ');
f0100688:	b8 20 00 00 00       	mov    $0x20,%eax
f010068d:	e8 be fe ff ff       	call   f0100550 <cons_putc>
		cons_putc(' ');
f0100692:	b8 20 00 00 00       	mov    $0x20,%eax
f0100697:	e8 b4 fe ff ff       	call   f0100550 <cons_putc>
		cons_putc(' ');
f010069c:	b8 20 00 00 00       	mov    $0x20,%eax
f01006a1:	e8 aa fe ff ff       	call   f0100550 <cons_putc>
f01006a6:	eb 1d                	jmp    f01006c5 <cons_putc+0x175>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f01006a8:	0f b7 05 30 30 29 f0 	movzwl 0xf0293030,%eax
f01006af:	0f b7 c8             	movzwl %ax,%ecx
f01006b2:	8b 15 2c 30 29 f0    	mov    0xf029302c,%edx
f01006b8:	66 89 3c 4a          	mov    %di,(%edx,%ecx,2)
f01006bc:	83 c0 01             	add    $0x1,%eax
f01006bf:	66 a3 30 30 29 f0    	mov    %ax,0xf0293030
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f01006c5:	66 81 3d 30 30 29 f0 	cmpw   $0x7cf,0xf0293030
f01006cc:	cf 07 
f01006ce:	76 42                	jbe    f0100712 <cons_putc+0x1c2>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f01006d0:	a1 2c 30 29 f0       	mov    0xf029302c,%eax
f01006d5:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
f01006dc:	00 
f01006dd:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f01006e3:	89 54 24 04          	mov    %edx,0x4(%esp)
f01006e7:	89 04 24             	mov    %eax,(%esp)
f01006ea:	e8 66 6e 00 00       	call   f0107555 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f01006ef:	8b 15 2c 30 29 f0    	mov    0xf029302c,%edx
f01006f5:	b8 80 07 00 00       	mov    $0x780,%eax
f01006fa:	66 c7 04 42 20 07    	movw   $0x720,(%edx,%eax,2)
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100700:	83 c0 01             	add    $0x1,%eax
f0100703:	3d d0 07 00 00       	cmp    $0x7d0,%eax
f0100708:	75 f0                	jne    f01006fa <cons_putc+0x1aa>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f010070a:	66 83 2d 30 30 29 f0 	subw   $0x50,0xf0293030
f0100711:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f0100712:	8b 0d 28 30 29 f0    	mov    0xf0293028,%ecx
f0100718:	89 cb                	mov    %ecx,%ebx
f010071a:	b8 0e 00 00 00       	mov    $0xe,%eax
f010071f:	89 ca                	mov    %ecx,%edx
f0100721:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100722:	0f b7 35 30 30 29 f0 	movzwl 0xf0293030,%esi
f0100729:	83 c1 01             	add    $0x1,%ecx
f010072c:	89 f0                	mov    %esi,%eax
f010072e:	66 c1 e8 08          	shr    $0x8,%ax
f0100732:	89 ca                	mov    %ecx,%edx
f0100734:	ee                   	out    %al,(%dx)
f0100735:	b8 0f 00 00 00       	mov    $0xf,%eax
f010073a:	89 da                	mov    %ebx,%edx
f010073c:	ee                   	out    %al,(%dx)
f010073d:	89 f0                	mov    %esi,%eax
f010073f:	89 ca                	mov    %ecx,%edx
f0100741:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f0100742:	83 c4 2c             	add    $0x2c,%esp
f0100745:	5b                   	pop    %ebx
f0100746:	5e                   	pop    %esi
f0100747:	5f                   	pop    %edi
f0100748:	5d                   	pop    %ebp
f0100749:	c3                   	ret    

f010074a <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f010074a:	55                   	push   %ebp
f010074b:	89 e5                	mov    %esp,%ebp
f010074d:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f0100750:	8b 45 08             	mov    0x8(%ebp),%eax
f0100753:	e8 f8 fd ff ff       	call   f0100550 <cons_putc>
}
f0100758:	c9                   	leave  
f0100759:	c3                   	ret    

f010075a <kbd_proc_data>:
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f010075a:	55                   	push   %ebp
f010075b:	89 e5                	mov    %esp,%ebp
f010075d:	53                   	push   %ebx
f010075e:	83 ec 14             	sub    $0x14,%esp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100761:	ba 64 00 00 00       	mov    $0x64,%edx
f0100766:	ec                   	in     (%dx),%al
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f0100767:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f010076c:	a8 01                	test   $0x1,%al
f010076e:	0f 84 d9 00 00 00    	je     f010084d <kbd_proc_data+0xf3>
f0100774:	b2 60                	mov    $0x60,%dl
f0100776:	ec                   	in     (%dx),%al
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f0100777:	3c e0                	cmp    $0xe0,%al
f0100779:	75 11                	jne    f010078c <kbd_proc_data+0x32>
		// E0 escape character
		shift |= E0ESC;
f010077b:	83 0d 20 30 29 f0 40 	orl    $0x40,0xf0293020
f0100782:	bb 00 00 00 00       	mov    $0x0,%ebx
		return 0;
f0100787:	e9 c1 00 00 00       	jmp    f010084d <kbd_proc_data+0xf3>
	} else if (data & 0x80) {
f010078c:	84 c0                	test   %al,%al
f010078e:	79 32                	jns    f01007c2 <kbd_proc_data+0x68>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f0100790:	8b 15 20 30 29 f0    	mov    0xf0293020,%edx
f0100796:	f6 c2 40             	test   $0x40,%dl
f0100799:	75 03                	jne    f010079e <kbd_proc_data+0x44>
f010079b:	83 e0 7f             	and    $0x7f,%eax
		shift &= ~(shiftcode[data] | E0ESC);
f010079e:	0f b6 c0             	movzbl %al,%eax
f01007a1:	0f b6 80 80 8e 10 f0 	movzbl -0xfef7180(%eax),%eax
f01007a8:	83 c8 40             	or     $0x40,%eax
f01007ab:	0f b6 c0             	movzbl %al,%eax
f01007ae:	f7 d0                	not    %eax
f01007b0:	21 c2                	and    %eax,%edx
f01007b2:	89 15 20 30 29 f0    	mov    %edx,0xf0293020
f01007b8:	bb 00 00 00 00       	mov    $0x0,%ebx
		return 0;
f01007bd:	e9 8b 00 00 00       	jmp    f010084d <kbd_proc_data+0xf3>
	} else if (shift & E0ESC) {
f01007c2:	8b 15 20 30 29 f0    	mov    0xf0293020,%edx
f01007c8:	f6 c2 40             	test   $0x40,%dl
f01007cb:	74 0c                	je     f01007d9 <kbd_proc_data+0x7f>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f01007cd:	83 c8 80             	or     $0xffffff80,%eax
		shift &= ~E0ESC;
f01007d0:	83 e2 bf             	and    $0xffffffbf,%edx
f01007d3:	89 15 20 30 29 f0    	mov    %edx,0xf0293020
	}

	shift |= shiftcode[data];
f01007d9:	0f b6 c0             	movzbl %al,%eax
	shift ^= togglecode[data];
f01007dc:	0f b6 90 80 8e 10 f0 	movzbl -0xfef7180(%eax),%edx
f01007e3:	0b 15 20 30 29 f0    	or     0xf0293020,%edx
f01007e9:	0f b6 88 80 8f 10 f0 	movzbl -0xfef7080(%eax),%ecx
f01007f0:	31 ca                	xor    %ecx,%edx
f01007f2:	89 15 20 30 29 f0    	mov    %edx,0xf0293020

	c = charcode[shift & (CTL | SHIFT)][data];
f01007f8:	89 d1                	mov    %edx,%ecx
f01007fa:	83 e1 03             	and    $0x3,%ecx
f01007fd:	8b 0c 8d 80 90 10 f0 	mov    -0xfef6f80(,%ecx,4),%ecx
f0100804:	0f b6 1c 01          	movzbl (%ecx,%eax,1),%ebx
	if (shift & CAPSLOCK) {
f0100808:	f6 c2 08             	test   $0x8,%dl
f010080b:	74 1a                	je     f0100827 <kbd_proc_data+0xcd>
		if ('a' <= c && c <= 'z')
f010080d:	89 d9                	mov    %ebx,%ecx
f010080f:	8d 43 9f             	lea    -0x61(%ebx),%eax
f0100812:	83 f8 19             	cmp    $0x19,%eax
f0100815:	77 05                	ja     f010081c <kbd_proc_data+0xc2>
			c += 'A' - 'a';
f0100817:	83 eb 20             	sub    $0x20,%ebx
f010081a:	eb 0b                	jmp    f0100827 <kbd_proc_data+0xcd>
		else if ('A' <= c && c <= 'Z')
f010081c:	83 e9 41             	sub    $0x41,%ecx
f010081f:	83 f9 19             	cmp    $0x19,%ecx
f0100822:	77 03                	ja     f0100827 <kbd_proc_data+0xcd>
			c += 'a' - 'A';
f0100824:	83 c3 20             	add    $0x20,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f0100827:	f7 d2                	not    %edx
f0100829:	f6 c2 06             	test   $0x6,%dl
f010082c:	75 1f                	jne    f010084d <kbd_proc_data+0xf3>
f010082e:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f0100834:	75 17                	jne    f010084d <kbd_proc_data+0xf3>
		cprintf("Rebooting!\n");
f0100836:	c7 04 24 3e 8e 10 f0 	movl   $0xf0108e3e,(%esp)
f010083d:	e8 cd 43 00 00       	call   f0104c0f <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100842:	ba 92 00 00 00       	mov    $0x92,%edx
f0100847:	b8 03 00 00 00       	mov    $0x3,%eax
f010084c:	ee                   	out    %al,(%dx)
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f010084d:	89 d8                	mov    %ebx,%eax
f010084f:	83 c4 14             	add    $0x14,%esp
f0100852:	5b                   	pop    %ebx
f0100853:	5d                   	pop    %ebp
f0100854:	c3                   	ret    

f0100855 <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f0100855:	55                   	push   %ebp
f0100856:	89 e5                	mov    %esp,%ebp
f0100858:	57                   	push   %edi
f0100859:	56                   	push   %esi
f010085a:	53                   	push   %ebx
f010085b:	83 ec 1c             	sub    $0x1c,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f010085e:	b8 00 80 0b f0       	mov    $0xf00b8000,%eax
f0100863:	0f b7 10             	movzwl (%eax),%edx
	*cp = (uint16_t) 0xA55A;
f0100866:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
	if (*cp != 0xA55A) {
f010086b:	0f b7 00             	movzwl (%eax),%eax
f010086e:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100872:	74 11                	je     f0100885 <cons_init+0x30>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f0100874:	c7 05 28 30 29 f0 b4 	movl   $0x3b4,0xf0293028
f010087b:	03 00 00 
f010087e:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f0100883:	eb 16                	jmp    f010089b <cons_init+0x46>
	} else {
		*cp = was;
f0100885:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f010088c:	c7 05 28 30 29 f0 d4 	movl   $0x3d4,0xf0293028
f0100893:	03 00 00 
f0100896:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
	}
	
	/* Extract cursor location */
	outb(addr_6845, 14);
f010089b:	8b 0d 28 30 29 f0    	mov    0xf0293028,%ecx
f01008a1:	89 cb                	mov    %ecx,%ebx
f01008a3:	b8 0e 00 00 00       	mov    $0xe,%eax
f01008a8:	89 ca                	mov    %ecx,%edx
f01008aa:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f01008ab:	83 c1 01             	add    $0x1,%ecx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01008ae:	89 ca                	mov    %ecx,%edx
f01008b0:	ec                   	in     (%dx),%al
f01008b1:	0f b6 f8             	movzbl %al,%edi
f01008b4:	c1 e7 08             	shl    $0x8,%edi
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01008b7:	b8 0f 00 00 00       	mov    $0xf,%eax
f01008bc:	89 da                	mov    %ebx,%edx
f01008be:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01008bf:	89 ca                	mov    %ecx,%edx
f01008c1:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f01008c2:	89 35 2c 30 29 f0    	mov    %esi,0xf029302c
	crt_pos = pos;
f01008c8:	0f b6 c8             	movzbl %al,%ecx
f01008cb:	09 cf                	or     %ecx,%edi
f01008cd:	66 89 3d 30 30 29 f0 	mov    %di,0xf0293030

static void
kbd_init(void)
{
	// Drain the kbd buffer so that Bochs generates interrupts.
	kbd_intr();
f01008d4:	e8 e9 fb ff ff       	call   f01004c2 <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<1));
f01008d9:	0f b7 05 70 83 12 f0 	movzwl 0xf0128370,%eax
f01008e0:	25 fd ff 00 00       	and    $0xfffd,%eax
f01008e5:	89 04 24             	mov    %eax,(%esp)
f01008e8:	e8 f2 41 00 00       	call   f0104adf <irq_setmask_8259A>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01008ed:	bb fa 03 00 00       	mov    $0x3fa,%ebx
f01008f2:	b8 00 00 00 00       	mov    $0x0,%eax
f01008f7:	89 da                	mov    %ebx,%edx
f01008f9:	ee                   	out    %al,(%dx)
f01008fa:	b2 fb                	mov    $0xfb,%dl
f01008fc:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f0100901:	ee                   	out    %al,(%dx)
f0100902:	b9 f8 03 00 00       	mov    $0x3f8,%ecx
f0100907:	b8 0c 00 00 00       	mov    $0xc,%eax
f010090c:	89 ca                	mov    %ecx,%edx
f010090e:	ee                   	out    %al,(%dx)
f010090f:	b2 f9                	mov    $0xf9,%dl
f0100911:	b8 00 00 00 00       	mov    $0x0,%eax
f0100916:	ee                   	out    %al,(%dx)
f0100917:	b2 fb                	mov    $0xfb,%dl
f0100919:	b8 03 00 00 00       	mov    $0x3,%eax
f010091e:	ee                   	out    %al,(%dx)
f010091f:	b2 fc                	mov    $0xfc,%dl
f0100921:	b8 00 00 00 00       	mov    $0x0,%eax
f0100926:	ee                   	out    %al,(%dx)
f0100927:	b2 f9                	mov    $0xf9,%dl
f0100929:	b8 01 00 00 00       	mov    $0x1,%eax
f010092e:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010092f:	b2 fd                	mov    $0xfd,%dl
f0100931:	ec                   	in     (%dx),%al
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f0100932:	3c ff                	cmp    $0xff,%al
f0100934:	0f 95 c0             	setne  %al
f0100937:	0f b6 f0             	movzbl %al,%esi
f010093a:	89 35 24 30 29 f0    	mov    %esi,0xf0293024
f0100940:	89 da                	mov    %ebx,%edx
f0100942:	ec                   	in     (%dx),%al
f0100943:	89 ca                	mov    %ecx,%edx
f0100945:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f0100946:	85 f6                	test   %esi,%esi
f0100948:	75 0c                	jne    f0100956 <cons_init+0x101>
		cprintf("Serial port does not exist!\n");
f010094a:	c7 04 24 4a 8e 10 f0 	movl   $0xf0108e4a,(%esp)
f0100951:	e8 b9 42 00 00       	call   f0104c0f <cprintf>
}
f0100956:	83 c4 1c             	add    $0x1c,%esp
f0100959:	5b                   	pop    %ebx
f010095a:	5e                   	pop    %esi
f010095b:	5f                   	pop    %edi
f010095c:	5d                   	pop    %ebp
f010095d:	c3                   	ret    
	...

f0100960 <rdtsc>:
		(end-entry+1023)/1024);
	return 0;
}


static uint64_t rdtsc() {
f0100960:	55                   	push   %ebp
f0100961:	89 e5                	mov    %esp,%ebp
    uint32_t lo,hi;
   __asm__ __volatile__
f0100963:	0f 31                	rdtsc  
   (
      "rdtsc":"=a"(lo),"=d"(hi)
   );
   return (uint64_t) hi<<32|lo;    
}
f0100965:	5d                   	pop    %ebp
f0100966:	c3                   	ret    

f0100967 <read_eip>:
// return EIP of caller.
// does not work if inlined.
// putting at the end of the file seems to prevent inlining.
unsigned
read_eip()
{
f0100967:	55                   	push   %ebp
f0100968:	89 e5                	mov    %esp,%ebp
	uint32_t callerpc;
	__asm __volatile("movl 4(%%ebp), %0" : "=r" (callerpc));
f010096a:	8b 45 04             	mov    0x4(%ebp),%eax
	return callerpc;
}
f010096d:	5d                   	pop    %ebp
f010096e:	c3                   	ret    

f010096f <start_overflow>:
    cprintf("Overflow success\n");
}

void
start_overflow(void)
{
f010096f:	55                   	push   %ebp
f0100970:	89 e5                	mov    %esp,%ebp
f0100972:	57                   	push   %edi
f0100973:	56                   	push   %esi
f0100974:	53                   	push   %ebx
f0100975:	81 ec 3c 01 00 00    	sub    $0x13c,%esp
    // you augmented in the "Exercise 9" to do this job.

    // hint: You can use the read_pretaddr function to retrieve 
    //       the pointer to the function call return address;

    char str[256] = {};
f010097b:	8d bd e8 fe ff ff    	lea    -0x118(%ebp),%edi
f0100981:	b9 40 00 00 00       	mov    $0x40,%ecx
f0100986:	b8 00 00 00 00       	mov    $0x0,%eax
f010098b:	f3 ab                	rep stos %eax,%es:(%edi)
// Lab1 only
// read the pointer to the retaddr on the stack
static uint32_t
read_pretaddr() {
    uint32_t pretaddr;
    __asm __volatile("leal 4(%%ebp), %0" : "=r" (pretaddr)); 
f010098d:	8d 45 04             	lea    0x4(%ebp),%eax
f0100990:	89 85 d4 fe ff ff    	mov    %eax,-0x12c(%ebp)
    char str[256] = {};
    int nstr = 0;
    char *pret_addr;
    int i = 0;
    pret_addr = (char*)read_pretaddr();
    uint32_t oldret = *((uint32_t*)pret_addr);
f0100996:	8b 00                	mov    (%eax),%eax
f0100998:	89 85 e4 fe ff ff    	mov    %eax,-0x11c(%ebp)
    uint32_t overflowaddr = (uint32_t)do_overflow;
f010099e:	c7 85 e0 fe ff ff 9d 	movl   $0xf0100a9d,-0x120(%ebp)
f01009a5:	0a 10 f0 
f01009a8:	be 00 00 00 00       	mov    $0x0,%esi
    for(i = 0;i<4;i++){
f01009ad:	bf 00 00 00 00       	mov    $0x0,%edi
       unsigned int j;
       for(j = 0;j<256;j++)
           str[j] = 0;
f01009b2:	8d 9d e8 fe ff ff    	lea    -0x118(%ebp),%ebx
f01009b8:	89 9d d0 fe ff ff    	mov    %ebx,-0x130(%ebp)
f01009be:	eb 6c                	jmp    f0100a2c <start_overflow+0xbd>
f01009c0:	c6 04 03 00          	movb   $0x0,(%ebx,%eax,1)
    pret_addr = (char*)read_pretaddr();
    uint32_t oldret = *((uint32_t*)pret_addr);
    uint32_t overflowaddr = (uint32_t)do_overflow;
    for(i = 0;i<4;i++){
       unsigned int j;
       for(j = 0;j<256;j++)
f01009c4:	83 c0 01             	add    $0x1,%eax
f01009c7:	3d 00 01 00 00       	cmp    $0x100,%eax
f01009cc:	75 f2                	jne    f01009c0 <start_overflow+0x51>
{
    cprintf("Overflow success\n");
}

void
start_overflow(void)
f01009ce:	89 f1                	mov    %esi,%ecx
       unsigned int j;
       for(j = 0;j<256;j++)
           str[j] = 0;
       char* addr = (char*)(&overflowaddr);
       unsigned char num = (unsigned char)((*(addr + i)) &0xFF);
       for(j = 0; j<num;j++)
f01009d0:	0f b6 94 35 e0 fe ff 	movzbl -0x120(%ebp,%esi,1),%edx
f01009d7:	ff 
f01009d8:	85 d2                	test   %edx,%edx
f01009da:	74 0d                	je     f01009e9 <start_overflow+0x7a>
f01009dc:	89 f8                	mov    %edi,%eax
           str[j] = ' ';
f01009de:	c6 04 03 20          	movb   $0x20,(%ebx,%eax,1)
       unsigned int j;
       for(j = 0;j<256;j++)
           str[j] = 0;
       char* addr = (char*)(&overflowaddr);
       unsigned char num = (unsigned char)((*(addr + i)) &0xFF);
       for(j = 0; j<num;j++)
f01009e2:	83 c0 01             	add    $0x1,%eax
f01009e5:	39 d0                	cmp    %edx,%eax
f01009e7:	72 f5                	jb     f01009de <start_overflow+0x6f>
           str[j] = ' ';
       cprintf("%s%n\n",str,pret_addr + i);
f01009e9:	03 8d d4 fe ff ff    	add    -0x12c(%ebp),%ecx
f01009ef:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01009f3:	8b 85 d0 fe ff ff    	mov    -0x130(%ebp),%eax
f01009f9:	89 44 24 04          	mov    %eax,0x4(%esp)
f01009fd:	c7 04 24 90 90 10 f0 	movl   $0xf0109090,(%esp)
f0100a04:	e8 06 42 00 00       	call   f0104c0f <cprintf>
    char *pret_addr;
    int i = 0;
    pret_addr = (char*)read_pretaddr();
    uint32_t oldret = *((uint32_t*)pret_addr);
    uint32_t overflowaddr = (uint32_t)do_overflow;
    for(i = 0;i<4;i++){
f0100a09:	83 c6 01             	add    $0x1,%esi
f0100a0c:	83 fe 04             	cmp    $0x4,%esi
f0100a0f:	75 1b                	jne    f0100a2c <start_overflow+0xbd>
f0100a11:	8b bd d4 fe ff ff    	mov    -0x12c(%ebp),%edi
f0100a17:	83 c7 04             	add    $0x4,%edi
f0100a1a:	66 be 00 00          	mov    $0x0,%si
       cprintf("%s%n\n",str,pret_addr + i);
    }
    for(i = 0;i<4;i++){
       unsigned int j;
       for(j = 0;j<256;j++)
           str[j] = 0;
f0100a1e:	8d 9d e8 fe ff ff    	lea    -0x118(%ebp),%ebx
f0100a24:	89 9d d4 fe ff ff    	mov    %ebx,-0x12c(%ebp)
f0100a2a:	eb 52                	jmp    f0100a7e <start_overflow+0x10f>
    char *pret_addr;
    int i = 0;
    pret_addr = (char*)read_pretaddr();
    uint32_t oldret = *((uint32_t*)pret_addr);
    uint32_t overflowaddr = (uint32_t)do_overflow;
    for(i = 0;i<4;i++){
f0100a2c:	89 f8                	mov    %edi,%eax
f0100a2e:	eb 90                	jmp    f01009c0 <start_overflow+0x51>
       cprintf("%s%n\n",str,pret_addr + i);
    }
    for(i = 0;i<4;i++){
       unsigned int j;
       for(j = 0;j<256;j++)
           str[j] = 0;
f0100a30:	c6 04 03 00          	movb   $0x0,(%ebx,%eax,1)
           str[j] = ' ';
       cprintf("%s%n\n",str,pret_addr + i);
    }
    for(i = 0;i<4;i++){
       unsigned int j;
       for(j = 0;j<256;j++)
f0100a34:	83 c0 01             	add    $0x1,%eax
f0100a37:	3d 00 01 00 00       	cmp    $0x100,%eax
f0100a3c:	75 f2                	jne    f0100a30 <start_overflow+0xc1>
           str[j] = 0;
       char* addr = (char*)(&oldret);
       unsigned char num = (unsigned char)((*(addr + i))&0xFF);
       for(j = 0; j<num;j++)
f0100a3e:	0f b6 94 35 e4 fe ff 	movzbl -0x11c(%ebp,%esi,1),%edx
f0100a45:	ff 
f0100a46:	85 d2                	test   %edx,%edx
f0100a48:	74 0f                	je     f0100a59 <start_overflow+0xea>
f0100a4a:	66 b8 00 00          	mov    $0x0,%ax
           str[j] = ' ';
f0100a4e:	c6 04 03 20          	movb   $0x20,(%ebx,%eax,1)
       unsigned int j;
       for(j = 0;j<256;j++)
           str[j] = 0;
       char* addr = (char*)(&oldret);
       unsigned char num = (unsigned char)((*(addr + i))&0xFF);
       for(j = 0; j<num;j++)
f0100a52:	83 c0 01             	add    $0x1,%eax
f0100a55:	39 d0                	cmp    %edx,%eax
f0100a57:	72 f5                	jb     f0100a4e <start_overflow+0xdf>
           str[j] = ' ';
       cprintf("%s%n\n",str,pret_addr + 4 + i);
f0100a59:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0100a5d:	8b 95 d4 fe ff ff    	mov    -0x12c(%ebp),%edx
f0100a63:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100a67:	c7 04 24 90 90 10 f0 	movl   $0xf0109090,(%esp)
f0100a6e:	e8 9c 41 00 00       	call   f0104c0f <cprintf>
       unsigned char num = (unsigned char)((*(addr + i)) &0xFF);
       for(j = 0; j<num;j++)
           str[j] = ' ';
       cprintf("%s%n\n",str,pret_addr + i);
    }
    for(i = 0;i<4;i++){
f0100a73:	83 c6 01             	add    $0x1,%esi
f0100a76:	83 c7 01             	add    $0x1,%edi
f0100a79:	83 fe 04             	cmp    $0x4,%esi
f0100a7c:	74 07                	je     f0100a85 <start_overflow+0x116>
f0100a7e:	b8 00 00 00 00       	mov    $0x0,%eax
f0100a83:	eb ab                	jmp    f0100a30 <start_overflow+0xc1>
       cprintf("%s%n\n",str,pret_addr + 4 + i);
    }
    

	// Your code here.
}
f0100a85:	81 c4 3c 01 00 00    	add    $0x13c,%esp
f0100a8b:	5b                   	pop    %ebx
f0100a8c:	5e                   	pop    %esi
f0100a8d:	5f                   	pop    %edi
f0100a8e:	5d                   	pop    %ebp
f0100a8f:	c3                   	ret    

f0100a90 <overflow_me>:

void
overflow_me(void)
{
f0100a90:	55                   	push   %ebp
f0100a91:	89 e5                	mov    %esp,%ebp
f0100a93:	83 ec 08             	sub    $0x8,%esp
        start_overflow();
f0100a96:	e8 d4 fe ff ff       	call   f010096f <start_overflow>
}
f0100a9b:	c9                   	leave  
f0100a9c:	c3                   	ret    

f0100a9d <do_overflow>:
    
}

void
do_overflow(void)
{
f0100a9d:	55                   	push   %ebp
f0100a9e:	89 e5                	mov    %esp,%ebp
f0100aa0:	83 ec 18             	sub    $0x18,%esp
    cprintf("Overflow success\n");
f0100aa3:	c7 04 24 96 90 10 f0 	movl   $0xf0109096,(%esp)
f0100aaa:	e8 60 41 00 00       	call   f0104c0f <cprintf>
}
f0100aaf:	c9                   	leave  
f0100ab0:	c3                   	ret    

f0100ab1 <mon_kerninfo>:
	return 0;
}

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f0100ab1:	55                   	push   %ebp
f0100ab2:	89 e5                	mov    %esp,%ebp
f0100ab4:	83 ec 18             	sub    $0x18,%esp
	extern char entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f0100ab7:	c7 04 24 a8 90 10 f0 	movl   $0xf01090a8,(%esp)
f0100abe:	e8 4c 41 00 00       	call   f0104c0f <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100ac3:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f0100aca:	00 
f0100acb:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f0100ad2:	f0 
f0100ad3:	c7 04 24 24 93 10 f0 	movl   $0xf0109324,(%esp)
f0100ada:	e8 30 41 00 00       	call   f0104c0f <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100adf:	c7 44 24 08 05 8d 10 	movl   $0x108d05,0x8(%esp)
f0100ae6:	00 
f0100ae7:	c7 44 24 04 05 8d 10 	movl   $0xf0108d05,0x4(%esp)
f0100aee:	f0 
f0100aef:	c7 04 24 48 93 10 f0 	movl   $0xf0109348,(%esp)
f0100af6:	e8 14 41 00 00       	call   f0104c0f <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100afb:	c7 44 24 08 0b 28 29 	movl   $0x29280b,0x8(%esp)
f0100b02:	00 
f0100b03:	c7 44 24 04 0b 28 29 	movl   $0xf029280b,0x4(%esp)
f0100b0a:	f0 
f0100b0b:	c7 04 24 6c 93 10 f0 	movl   $0xf010936c,(%esp)
f0100b12:	e8 f8 40 00 00       	call   f0104c0f <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100b17:	c7 44 24 08 60 58 2f 	movl   $0x2f5860,0x8(%esp)
f0100b1e:	00 
f0100b1f:	c7 44 24 04 60 58 2f 	movl   $0xf02f5860,0x4(%esp)
f0100b26:	f0 
f0100b27:	c7 04 24 90 93 10 f0 	movl   $0xf0109390,(%esp)
f0100b2e:	e8 dc 40 00 00       	call   f0104c0f <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100b33:	b8 5f 5c 2f f0       	mov    $0xf02f5c5f,%eax
f0100b38:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
f0100b3d:	89 c2                	mov    %eax,%edx
f0100b3f:	c1 fa 1f             	sar    $0x1f,%edx
f0100b42:	c1 ea 16             	shr    $0x16,%edx
f0100b45:	8d 04 02             	lea    (%edx,%eax,1),%eax
f0100b48:	c1 f8 0a             	sar    $0xa,%eax
f0100b4b:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100b4f:	c7 04 24 b4 93 10 f0 	movl   $0xf01093b4,(%esp)
f0100b56:	e8 b4 40 00 00       	call   f0104c0f <cprintf>
		(end-entry+1023)/1024);
	return 0;
}
f0100b5b:	b8 00 00 00 00       	mov    $0x0,%eax
f0100b60:	c9                   	leave  
f0100b61:	c3                   	ret    

f0100b62 <mon_help>:
} 


int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100b62:	55                   	push   %ebp
f0100b63:	89 e5                	mov    %esp,%ebp
f0100b65:	57                   	push   %edi
f0100b66:	56                   	push   %esi
f0100b67:	53                   	push   %ebx
f0100b68:	83 ec 1c             	sub    $0x1c,%esp
f0100b6b:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100b70:	be e4 94 10 f0       	mov    $0xf01094e4,%esi
f0100b75:	bf e0 94 10 f0       	mov    $0xf01094e0,%edi
f0100b7a:	8b 04 1e             	mov    (%esi,%ebx,1),%eax
f0100b7d:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100b81:	8b 04 1f             	mov    (%edi,%ebx,1),%eax
f0100b84:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100b88:	c7 04 24 c1 90 10 f0 	movl   $0xf01090c1,(%esp)
f0100b8f:	e8 7b 40 00 00       	call   f0104c0f <cprintf>
f0100b94:	83 c3 0c             	add    $0xc,%ebx
int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
	int i;

	for (i = 0; i < NCOMMANDS; i++)
f0100b97:	83 fb 6c             	cmp    $0x6c,%ebx
f0100b9a:	75 de                	jne    f0100b7a <mon_help+0x18>
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
	return 0;
}
f0100b9c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100ba1:	83 c4 1c             	add    $0x1c,%esp
f0100ba4:	5b                   	pop    %ebx
f0100ba5:	5e                   	pop    %esi
f0100ba6:	5f                   	pop    %edi
f0100ba7:	5d                   	pop    %ebp
f0100ba8:	c3                   	ret    

f0100ba9 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100ba9:	55                   	push   %ebp
f0100baa:	89 e5                	mov    %esp,%ebp
f0100bac:	57                   	push   %edi
f0100bad:	56                   	push   %esi
f0100bae:	53                   	push   %ebx
f0100baf:	83 ec 5c             	sub    $0x5c,%esp
	char *buf;
        if(tf == NULL){
f0100bb2:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0100bb6:	75 1a                	jne    f0100bd2 <monitor+0x29>
	   cprintf("Welcome to the JOS kernel monitor!\n");
f0100bb8:	c7 04 24 e0 93 10 f0 	movl   $0xf01093e0,(%esp)
f0100bbf:	e8 4b 40 00 00       	call   f0104c0f <cprintf>
	   cprintf("Type 'help' for a list of commands.\n");
f0100bc4:	c7 04 24 04 94 10 f0 	movl   $0xf0109404,(%esp)
f0100bcb:	e8 3f 40 00 00       	call   f0104c0f <cprintf>
f0100bd0:	eb 0b                	jmp    f0100bdd <monitor+0x34>
        }

	if (tf != NULL)
		print_trapframe(tf);
f0100bd2:	8b 45 08             	mov    0x8(%ebp),%eax
f0100bd5:	89 04 24             	mov    %eax,(%esp)
f0100bd8:	e8 a1 47 00 00       	call   f010537e <print_trapframe>

	while (1) {
		buf = readline("K> ");
f0100bdd:	c7 04 24 ca 90 10 f0 	movl   $0xf01090ca,(%esp)
f0100be4:	e8 57 66 00 00       	call   f0107240 <readline>
f0100be9:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100beb:	85 c0                	test   %eax,%eax
f0100bed:	74 ee                	je     f0100bdd <monitor+0x34>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f0100bef:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
f0100bf6:	be 00 00 00 00       	mov    $0x0,%esi
f0100bfb:	eb 06                	jmp    f0100c03 <monitor+0x5a>
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100bfd:	c6 03 00             	movb   $0x0,(%ebx)
f0100c00:	83 c3 01             	add    $0x1,%ebx
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f0100c03:	0f b6 03             	movzbl (%ebx),%eax
f0100c06:	84 c0                	test   %al,%al
f0100c08:	74 6b                	je     f0100c75 <monitor+0xcc>
f0100c0a:	0f be c0             	movsbl %al,%eax
f0100c0d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100c11:	c7 04 24 ce 90 10 f0 	movl   $0xf01090ce,(%esp)
f0100c18:	e8 7e 68 00 00       	call   f010749b <strchr>
f0100c1d:	85 c0                	test   %eax,%eax
f0100c1f:	75 dc                	jne    f0100bfd <monitor+0x54>
			*buf++ = 0;
		if (*buf == 0)
f0100c21:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100c24:	74 4f                	je     f0100c75 <monitor+0xcc>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f0100c26:	83 fe 0f             	cmp    $0xf,%esi
f0100c29:	75 16                	jne    f0100c41 <monitor+0x98>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100c2b:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f0100c32:	00 
f0100c33:	c7 04 24 d3 90 10 f0 	movl   $0xf01090d3,(%esp)
f0100c3a:	e8 d0 3f 00 00       	call   f0104c0f <cprintf>
f0100c3f:	eb 9c                	jmp    f0100bdd <monitor+0x34>
			return 0;
		}
		argv[argc++] = buf;
f0100c41:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f0100c45:	83 c6 01             	add    $0x1,%esi
		while (*buf && !strchr(WHITESPACE, *buf))
f0100c48:	0f b6 03             	movzbl (%ebx),%eax
f0100c4b:	84 c0                	test   %al,%al
f0100c4d:	75 0d                	jne    f0100c5c <monitor+0xb3>
f0100c4f:	90                   	nop
f0100c50:	eb b1                	jmp    f0100c03 <monitor+0x5a>
			buf++;
f0100c52:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f0100c55:	0f b6 03             	movzbl (%ebx),%eax
f0100c58:	84 c0                	test   %al,%al
f0100c5a:	74 a7                	je     f0100c03 <monitor+0x5a>
f0100c5c:	0f be c0             	movsbl %al,%eax
f0100c5f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100c63:	c7 04 24 ce 90 10 f0 	movl   $0xf01090ce,(%esp)
f0100c6a:	e8 2c 68 00 00       	call   f010749b <strchr>
f0100c6f:	85 c0                	test   %eax,%eax
f0100c71:	74 df                	je     f0100c52 <monitor+0xa9>
f0100c73:	eb 8e                	jmp    f0100c03 <monitor+0x5a>
			buf++;
	}
	argv[argc] = 0;
f0100c75:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100c7c:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100c7d:	85 f6                	test   %esi,%esi
f0100c7f:	90                   	nop
f0100c80:	0f 84 57 ff ff ff    	je     f0100bdd <monitor+0x34>
f0100c86:	bb e0 94 10 f0       	mov    $0xf01094e0,%ebx
f0100c8b:	bf 00 00 00 00       	mov    $0x0,%edi
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100c90:	8b 03                	mov    (%ebx),%eax
f0100c92:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100c96:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100c99:	89 04 24             	mov    %eax,(%esp)
f0100c9c:	e8 84 67 00 00       	call   f0107425 <strcmp>
f0100ca1:	85 c0                	test   %eax,%eax
f0100ca3:	75 23                	jne    f0100cc8 <monitor+0x11f>
			return commands[i].func(argc, argv, tf);
f0100ca5:	6b ff 0c             	imul   $0xc,%edi,%edi
f0100ca8:	8b 45 08             	mov    0x8(%ebp),%eax
f0100cab:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100caf:	8d 45 a8             	lea    -0x58(%ebp),%eax
f0100cb2:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100cb6:	89 34 24             	mov    %esi,(%esp)
f0100cb9:	ff 97 e8 94 10 f0    	call   *-0xfef6b18(%edi)
		print_trapframe(tf);

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100cbf:	85 c0                	test   %eax,%eax
f0100cc1:	78 28                	js     f0100ceb <monitor+0x142>
f0100cc3:	e9 15 ff ff ff       	jmp    f0100bdd <monitor+0x34>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f0100cc8:	83 c7 01             	add    $0x1,%edi
f0100ccb:	83 c3 0c             	add    $0xc,%ebx
f0100cce:	83 ff 09             	cmp    $0x9,%edi
f0100cd1:	75 bd                	jne    f0100c90 <monitor+0xe7>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100cd3:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100cd6:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100cda:	c7 04 24 f0 90 10 f0 	movl   $0xf01090f0,(%esp)
f0100ce1:	e8 29 3f 00 00       	call   f0104c0f <cprintf>
f0100ce6:	e9 f2 fe ff ff       	jmp    f0100bdd <monitor+0x34>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0100ceb:	83 c4 5c             	add    $0x5c,%esp
f0100cee:	5b                   	pop    %ebx
f0100cef:	5e                   	pop    %esi
f0100cf0:	5f                   	pop    %edi
f0100cf1:	5d                   	pop    %ebp
f0100cf2:	c3                   	ret    

f0100cf3 <mon_time>:
   return (uint64_t) hi<<32|lo;    
}

int 
mon_time(int argc, char**argv,struct Trapframe *tf)
{
f0100cf3:	55                   	push   %ebp
f0100cf4:	89 e5                	mov    %esp,%ebp
f0100cf6:	57                   	push   %edi
f0100cf7:	56                   	push   %esi
f0100cf8:	53                   	push   %ebx
f0100cf9:	83 ec 3c             	sub    $0x3c,%esp
f0100cfc:	be e0 94 10 f0       	mov    $0xf01094e0,%esi
f0100d01:	bf 00 00 00 00       	mov    $0x0,%edi
   int ret;
   int flag = 0;
   uint64_t begin;
   uint64_t end;
   for(i = 0;i<NCOMMANDS;i++){
       if(strcmp(argv[1],commands[i].name) == 0){
f0100d06:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0100d09:	83 c3 04             	add    $0x4,%ebx
f0100d0c:	8b 06                	mov    (%esi),%eax
f0100d0e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0100d11:	89 5d e0             	mov    %ebx,-0x20(%ebp)
f0100d14:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100d18:	8b 03                	mov    (%ebx),%eax
f0100d1a:	89 04 24             	mov    %eax,(%esp)
f0100d1d:	e8 03 67 00 00       	call   f0107425 <strcmp>
f0100d22:	85 c0                	test   %eax,%eax
f0100d24:	75 51                	jne    f0100d77 <mon_time+0x84>
          begin = rdtsc();
f0100d26:	e8 35 fc ff ff       	call   f0100960 <rdtsc>
f0100d2b:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100d2e:	89 55 d4             	mov    %edx,-0x2c(%ebp)
          ret = (commands[i].func)(argc-1,&argv[1],tf);
f0100d31:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f0100d34:	8b 55 10             	mov    0x10(%ebp),%edx
f0100d37:	89 54 24 08          	mov    %edx,0x8(%esp)
f0100d3b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100d3f:	8b 55 08             	mov    0x8(%ebp),%edx
f0100d42:	83 ea 01             	sub    $0x1,%edx
f0100d45:	89 14 24             	mov    %edx,(%esp)
f0100d48:	ff 14 85 e8 94 10 f0 	call   *-0xfef6b18(,%eax,4)
          end = rdtsc();
f0100d4f:	e8 0c fc ff ff       	call   f0100960 <rdtsc>
          cprintf("%s cycles: %d\n",commands[i].name,end-begin);
f0100d54:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0100d57:	1b 55 d4             	sbb    -0x2c(%ebp),%edx
f0100d5a:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100d5e:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0100d62:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0100d65:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100d69:	c7 04 24 06 91 10 f0 	movl   $0xf0109106,(%esp)
f0100d70:	e8 9a 3e 00 00       	call   f0104c0f <cprintf>
f0100d75:	eb 0d                	jmp    f0100d84 <mon_time+0x91>
   int i;
   int ret;
   int flag = 0;
   uint64_t begin;
   uint64_t end;
   for(i = 0;i<NCOMMANDS;i++){
f0100d77:	83 c7 01             	add    $0x1,%edi
f0100d7a:	83 c6 0c             	add    $0xc,%esi
f0100d7d:	83 ff 09             	cmp    $0x9,%edi
f0100d80:	75 8a                	jne    f0100d0c <mon_time+0x19>
f0100d82:	eb 0d                	jmp    f0100d91 <mon_time+0x9e>
       }
   }
   if(flag == 0)
     cprintf("no such command %s\n",argv[1]);
   return 0;
}
f0100d84:	b8 00 00 00 00       	mov    $0x0,%eax
f0100d89:	83 c4 3c             	add    $0x3c,%esp
f0100d8c:	5b                   	pop    %ebx
f0100d8d:	5e                   	pop    %esi
f0100d8e:	5f                   	pop    %edi
f0100d8f:	5d                   	pop    %ebp
f0100d90:	c3                   	ret    
          flag = 1;
          break;
       }
   }
   if(flag == 0)
     cprintf("no such command %s\n",argv[1]);
f0100d91:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0100d94:	8b 01                	mov    (%ecx),%eax
f0100d96:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100d9a:	c7 04 24 15 91 10 f0 	movl   $0xf0109115,(%esp)
f0100da1:	e8 69 3e 00 00       	call   f0104c0f <cprintf>
f0100da6:	eb dc                	jmp    f0100d84 <mon_time+0x91>

f0100da8 <mon_backtrace>:
        start_overflow();
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f0100da8:	55                   	push   %ebp
f0100da9:	89 e5                	mov    %esp,%ebp
f0100dab:	57                   	push   %edi
f0100dac:	56                   	push   %esi
f0100dad:	53                   	push   %ebx
f0100dae:	83 ec 4c             	sub    $0x4c,%esp
	// Your code here.
    overflow_me();
f0100db1:	e8 da fc ff ff       	call   f0100a90 <overflow_me>
    cprintf("Stack backtrace:\n");
f0100db6:	c7 04 24 29 91 10 f0 	movl   $0xf0109129,(%esp)
f0100dbd:	e8 4d 3e 00 00       	call   f0104c0f <cprintf>
    uint32_t* ebp = (uint32_t*)read_ebp();
f0100dc2:	89 ee                	mov    %ebp,%esi
    struct Eipdebuginfo info;
    while(ebp != 0){
f0100dc4:	85 f6                	test   %esi,%esi
f0100dc6:	0f 84 97 00 00 00    	je     f0100e63 <mon_backtrace+0xbb>
    int i = 0;
    cprintf("eip %08x  ebp %08x  ",ebp[1],ebp);
f0100dcc:	8d 7e 04             	lea    0x4(%esi),%edi
f0100dcf:	89 74 24 08          	mov    %esi,0x8(%esp)
f0100dd3:	8b 07                	mov    (%edi),%eax
f0100dd5:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100dd9:	c7 04 24 3b 91 10 f0 	movl   $0xf010913b,(%esp)
f0100de0:	e8 2a 3e 00 00       	call   f0104c0f <cprintf>
    debuginfo_eip(ebp[1],&info);
f0100de5:	8d 45 d0             	lea    -0x30(%ebp),%eax
f0100de8:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100dec:	8b 07                	mov    (%edi),%eax
f0100dee:	89 04 24             	mov    %eax,(%esp)
f0100df1:	e8 b8 59 00 00       	call   f01067ae <debuginfo_eip>
    cprintf("args ");
f0100df6:	c7 04 24 50 91 10 f0 	movl   $0xf0109150,(%esp)
f0100dfd:	e8 0d 3e 00 00       	call   f0104c0f <cprintf>
f0100e02:	bb 00 00 00 00       	mov    $0x0,%ebx
    for(i = 0; i< 5;i++){
       cprintf("%08x ",ebp[i+2]);
f0100e07:	8b 44 9e 08          	mov    0x8(%esi,%ebx,4),%eax
f0100e0b:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100e0f:	c7 04 24 41 92 10 f0 	movl   $0xf0109241,(%esp)
f0100e16:	e8 f4 3d 00 00       	call   f0104c0f <cprintf>
    while(ebp != 0){
    int i = 0;
    cprintf("eip %08x  ebp %08x  ",ebp[1],ebp);
    debuginfo_eip(ebp[1],&info);
    cprintf("args ");
    for(i = 0; i< 5;i++){
f0100e1b:	83 c3 01             	add    $0x1,%ebx
f0100e1e:	83 fb 05             	cmp    $0x5,%ebx
f0100e21:	75 e4                	jne    f0100e07 <mon_backtrace+0x5f>
       cprintf("%08x ",ebp[i+2]);
    }
    cprintf("\n");
f0100e23:	c7 04 24 19 92 10 f0 	movl   $0xf0109219,(%esp)
f0100e2a:	e8 e0 3d 00 00       	call   f0104c0f <cprintf>
    cprintf("\t%s:%d: %s+%d\n",info.eip_file,info.eip_line,info.eip_fn_name,ebp[1]-info.eip_fn_addr);
f0100e2f:	8b 07                	mov    (%edi),%eax
f0100e31:	2b 45 e0             	sub    -0x20(%ebp),%eax
f0100e34:	89 44 24 10          	mov    %eax,0x10(%esp)
f0100e38:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100e3b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100e3f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100e42:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100e46:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0100e49:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100e4d:	c7 04 24 56 91 10 f0 	movl   $0xf0109156,(%esp)
f0100e54:	e8 b6 3d 00 00       	call   f0104c0f <cprintf>
    ebp = (uint32_t*)(*(ebp));
f0100e59:	8b 36                	mov    (%esi),%esi
	// Your code here.
    overflow_me();
    cprintf("Stack backtrace:\n");
    uint32_t* ebp = (uint32_t*)read_ebp();
    struct Eipdebuginfo info;
    while(ebp != 0){
f0100e5b:	85 f6                	test   %esi,%esi
f0100e5d:	0f 85 69 ff ff ff    	jne    f0100dcc <mon_backtrace+0x24>
    }
    cprintf("\n");
    cprintf("\t%s:%d: %s+%d\n",info.eip_file,info.eip_line,info.eip_fn_name,ebp[1]-info.eip_fn_addr);
    ebp = (uint32_t*)(*(ebp));
    }
    cprintf("Backtrace success\n");
f0100e63:	c7 04 24 65 91 10 f0 	movl   $0xf0109165,(%esp)
f0100e6a:	e8 a0 3d 00 00       	call   f0104c0f <cprintf>
    return 0;
}
f0100e6f:	b8 00 00 00 00       	mov    $0x0,%eax
f0100e74:	83 c4 4c             	add    $0x4c,%esp
f0100e77:	5b                   	pop    %ebx
f0100e78:	5e                   	pop    %esi
f0100e79:	5f                   	pop    %edi
f0100e7a:	5d                   	pop    %ebp
f0100e7b:	c3                   	ret    

f0100e7c <mon_x>:
unsigned read_eip();

/***** Implementations of basic kernel monitor commands *****/

int 
mon_x(int argc,char **argv,struct Trapframe *tf){
f0100e7c:	55                   	push   %ebp
f0100e7d:	89 e5                	mov    %esp,%ebp
f0100e7f:	83 ec 18             	sub    $0x18,%esp
   if(argc != 2)
f0100e82:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
f0100e86:	74 0e                	je     f0100e96 <mon_x+0x1a>
     cprintf("Usage: x [addr]\n");   
f0100e88:	c7 04 24 78 91 10 f0 	movl   $0xf0109178,(%esp)
f0100e8f:	e8 7b 3d 00 00       	call   f0104c0f <cprintf>
f0100e94:	eb 44                	jmp    f0100eda <mon_x+0x5e>
   else if(tf == NULL)
f0100e96:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0100e9a:	75 0e                	jne    f0100eaa <mon_x+0x2e>
     cprintf("trapframe error\n");
f0100e9c:	c7 04 24 89 91 10 f0 	movl   $0xf0109189,(%esp)
f0100ea3:	e8 67 3d 00 00       	call   f0104c0f <cprintf>
f0100ea8:	eb 30                	jmp    f0100eda <mon_x+0x5e>
   else{
       uint32_t addr = strtol(argv[1],0,0);
f0100eaa:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0100eb1:	00 
f0100eb2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100eb9:	00 
f0100eba:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100ebd:	8b 40 04             	mov    0x4(%eax),%eax
f0100ec0:	89 04 24             	mov    %eax,(%esp)
f0100ec3:	e8 a3 67 00 00       	call   f010766b <strtol>
       uint32_t value = 0; 
       value = *((uint32_t*)addr);
       cprintf("%d\n",value);
f0100ec8:	8b 00                	mov    (%eax),%eax
f0100eca:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100ece:	c7 04 24 11 91 10 f0 	movl   $0xf0109111,(%esp)
f0100ed5:	e8 35 3d 00 00       	call   f0104c0f <cprintf>
    }
    return 0;
}
f0100eda:	b8 00 00 00 00       	mov    $0x0,%eax
f0100edf:	c9                   	leave  
f0100ee0:	c3                   	ret    

f0100ee1 <mon_changeperm>:
   return 0;
}

int 
mon_changeperm(int argc,char**argv,struct Trapframe *tf)
{
f0100ee1:	55                   	push   %ebp
f0100ee2:	89 e5                	mov    %esp,%ebp
f0100ee4:	83 ec 38             	sub    $0x38,%esp
f0100ee7:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0100eea:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0100eed:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0100ef0:	8b 75 08             	mov    0x8(%ebp),%esi
f0100ef3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
    if(argc != 3 && argc != 4){
f0100ef6:	8d 46 fd             	lea    -0x3(%esi),%eax
f0100ef9:	83 f8 01             	cmp    $0x1,%eax
f0100efc:	76 11                	jbe    f0100f0f <mon_changeperm+0x2e>
      cprintf("Usage: changeperm [op] [addr] ([perm])\n");
f0100efe:	c7 04 24 2c 94 10 f0 	movl   $0xf010942c,(%esp)
f0100f05:	e8 05 3d 00 00       	call   f0104c0f <cprintf>
      return 0;
f0100f0a:	e9 23 01 00 00       	jmp    f0101032 <mon_changeperm+0x151>
    }
    char* op = argv[1];
f0100f0f:	8b 43 04             	mov    0x4(%ebx),%eax
f0100f12:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    uintptr_t addr = strtol(argv[2],0,0);
f0100f15:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0100f1c:	00 
f0100f1d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100f24:	00 
f0100f25:	8b 43 08             	mov    0x8(%ebx),%eax
f0100f28:	89 04 24             	mov    %eax,(%esp)
f0100f2b:	e8 3b 67 00 00       	call   f010766b <strtol>
    pte_t* pte = pgdir_walk(kern_pgdir,(void*)addr,1);
f0100f30:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0100f37:	00 
f0100f38:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100f3c:	a1 b8 3e 29 f0       	mov    0xf0293eb8,%eax
f0100f41:	89 04 24             	mov    %eax,(%esp)
f0100f44:	e8 74 12 00 00       	call   f01021bd <pgdir_walk>
f0100f49:	89 c7                	mov    %eax,%edi
    if(pte == NULL){
f0100f4b:	85 c0                	test   %eax,%eax
f0100f4d:	75 11                	jne    f0100f60 <mon_changeperm+0x7f>
       cprintf("pte error\n");
f0100f4f:	c7 04 24 9a 91 10 f0 	movl   $0xf010919a,(%esp)
f0100f56:	e8 b4 3c 00 00       	call   f0104c0f <cprintf>
       return 0;
f0100f5b:	e9 d2 00 00 00       	jmp    f0101032 <mon_changeperm+0x151>
    }
    if(strcmp(op,"set") == 0 || strcmp(op,"change") == 0){
f0100f60:	c7 44 24 04 a5 91 10 	movl   $0xf01091a5,0x4(%esp)
f0100f67:	f0 
f0100f68:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100f6b:	89 04 24             	mov    %eax,(%esp)
f0100f6e:	e8 b2 64 00 00       	call   f0107425 <strcmp>
f0100f73:	85 c0                	test   %eax,%eax
f0100f75:	74 17                	je     f0100f8e <mon_changeperm+0xad>
f0100f77:	c7 44 24 04 a9 91 10 	movl   $0xf01091a9,0x4(%esp)
f0100f7e:	f0 
f0100f7f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100f82:	89 04 24             	mov    %eax,(%esp)
f0100f85:	e8 9b 64 00 00       	call   f0107425 <strcmp>
f0100f8a:	85 c0                	test   %eax,%eax
f0100f8c:	75 58                	jne    f0100fe6 <mon_changeperm+0x105>
       if(argc != 4){
f0100f8e:	83 fe 04             	cmp    $0x4,%esi
f0100f91:	74 11                	je     f0100fa4 <mon_changeperm+0xc3>
         cprintf("Usage: changeperm [op] [addr] ([perm])\n");
f0100f93:	c7 04 24 2c 94 10 f0 	movl   $0xf010942c,(%esp)
f0100f9a:	e8 70 3c 00 00       	call   f0104c0f <cprintf>
         return 0;
f0100f9f:	e9 8e 00 00 00       	jmp    f0101032 <mon_changeperm+0x151>
       }
       uintptr_t perm = strtol(argv[3],0,0);
f0100fa4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0100fab:	00 
f0100fac:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100fb3:	00 
f0100fb4:	8b 43 0c             	mov    0xc(%ebx),%eax
f0100fb7:	89 04 24             	mov    %eax,(%esp)
f0100fba:	e8 ac 66 00 00       	call   f010766b <strtol>
       if((perm & 0x00000FFF) != perm){
f0100fbf:	89 c2                	mov    %eax,%edx
f0100fc1:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
f0100fc7:	39 c2                	cmp    %eax,%edx
f0100fc9:	74 0e                	je     f0100fd9 <mon_changeperm+0xf8>
          cprintf("wrong perm\n");
f0100fcb:	c7 04 24 b0 91 10 f0 	movl   $0xf01091b0,(%esp)
f0100fd2:	e8 38 3c 00 00       	call   f0104c0f <cprintf>
          return 0;
f0100fd7:	eb 59                	jmp    f0101032 <mon_changeperm+0x151>
       }
       *pte = ((*pte)& 0xFFFFF000) | perm;
f0100fd9:	8b 07                	mov    (%edi),%eax
f0100fdb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100fe0:	09 c2                	or     %eax,%edx
f0100fe2:	89 17                	mov    %edx,(%edi)
    pte_t* pte = pgdir_walk(kern_pgdir,(void*)addr,1);
    if(pte == NULL){
       cprintf("pte error\n");
       return 0;
    }
    if(strcmp(op,"set") == 0 || strcmp(op,"change") == 0){
f0100fe4:	eb 40                	jmp    f0101026 <mon_changeperm+0x145>
          cprintf("wrong perm\n");
          return 0;
       }
       *pte = ((*pte)& 0xFFFFF000) | perm;
    }
    else if(strcmp(op,"clear") == 0){
f0100fe6:	c7 44 24 04 bc 91 10 	movl   $0xf01091bc,0x4(%esp)
f0100fed:	f0 
f0100fee:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100ff1:	89 04 24             	mov    %eax,(%esp)
f0100ff4:	e8 2c 64 00 00       	call   f0107425 <strcmp>
f0100ff9:	85 c0                	test   %eax,%eax
f0100ffb:	75 1b                	jne    f0101018 <mon_changeperm+0x137>
       if(argc != 3){
f0100ffd:	83 fe 03             	cmp    $0x3,%esi
f0101000:	74 0e                	je     f0101010 <mon_changeperm+0x12f>
         cprintf("Usage: changeperm [op] [addr] ([perm])\n");
f0101002:	c7 04 24 2c 94 10 f0 	movl   $0xf010942c,(%esp)
f0101009:	e8 01 3c 00 00       	call   f0104c0f <cprintf>
         return 0;
f010100e:	eb 22                	jmp    f0101032 <mon_changeperm+0x151>
       }
       *pte = ((*pte)& 0xFFFFF000);
f0101010:	81 27 00 f0 ff ff    	andl   $0xfffff000,(%edi)
f0101016:	eb 0e                	jmp    f0101026 <mon_changeperm+0x145>
    }
    else{
      cprintf("Usage: changeperm [op] [addr] ([perm])\n");
f0101018:	c7 04 24 2c 94 10 f0 	movl   $0xf010942c,(%esp)
f010101f:	e8 eb 3b 00 00       	call   f0104c0f <cprintf>
      return 0;
f0101024:	eb 0c                	jmp    f0101032 <mon_changeperm+0x151>
    }
    cprintf("success\n");
f0101026:	c7 04 24 6f 91 10 f0 	movl   $0xf010916f,(%esp)
f010102d:	e8 dd 3b 00 00       	call   f0104c0f <cprintf>
    return 0;
}
f0101032:	b8 00 00 00 00       	mov    $0x0,%eax
f0101037:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f010103a:	8b 75 f8             	mov    -0x8(%ebp),%esi
f010103d:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0101040:	89 ec                	mov    %ebp,%esp
f0101042:	5d                   	pop    %ebp
f0101043:	c3                   	ret    

f0101044 <mon_showmappings>:
   return 0;
}

int 
mon_showmappings(int argc,char**argv,struct Trapframe *tf)
{
f0101044:	55                   	push   %ebp
f0101045:	89 e5                	mov    %esp,%ebp
f0101047:	57                   	push   %edi
f0101048:	56                   	push   %esi
f0101049:	53                   	push   %ebx
f010104a:	83 ec 1c             	sub    $0x1c,%esp
f010104d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
   if(argc != 3)
f0101050:	83 7d 08 03          	cmpl   $0x3,0x8(%ebp)
f0101054:	0f 85 2c 02 00 00    	jne    f0101286 <mon_showmappings+0x242>
      return 0;
   uintptr_t begin = strtol(argv[1],0,0);
f010105a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101061:	00 
f0101062:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101069:	00 
f010106a:	8b 43 04             	mov    0x4(%ebx),%eax
f010106d:	89 04 24             	mov    %eax,(%esp)
f0101070:	e8 f6 65 00 00       	call   f010766b <strtol>
f0101075:	89 c6                	mov    %eax,%esi
   uintptr_t end = strtol(argv[2],0,0);
f0101077:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010107e:	00 
f010107f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101086:	00 
f0101087:	8b 43 08             	mov    0x8(%ebx),%eax
f010108a:	89 04 24             	mov    %eax,(%esp)
f010108d:	e8 d9 65 00 00       	call   f010766b <strtol>
f0101092:	89 c7                	mov    %eax,%edi
   if(begin > end || begin != ROUNDUP(begin,PGSIZE)){
f0101094:	39 c6                	cmp    %eax,%esi
f0101096:	77 18                	ja     f01010b0 <mon_showmappings+0x6c>
f0101098:	8d 86 ff 0f 00 00    	lea    0xfff(%esi),%eax
f010109e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01010a3:	39 c6                	cmp    %eax,%esi
f01010a5:	75 09                	jne    f01010b0 <mon_showmappings+0x6c>
      cprintf("wrong virtual address\n");
      return 0;
   }
   while(begin < end){
f01010a7:	39 fe                	cmp    %edi,%esi
f01010a9:	72 16                	jb     f01010c1 <mon_showmappings+0x7d>
f01010ab:	e9 d6 01 00 00       	jmp    f0101286 <mon_showmappings+0x242>
   if(argc != 3)
      return 0;
   uintptr_t begin = strtol(argv[1],0,0);
   uintptr_t end = strtol(argv[2],0,0);
   if(begin > end || begin != ROUNDUP(begin,PGSIZE)){
      cprintf("wrong virtual address\n");
f01010b0:	c7 04 24 c2 91 10 f0 	movl   $0xf01091c2,(%esp)
f01010b7:	e8 53 3b 00 00       	call   f0104c0f <cprintf>
      return 0;
f01010bc:	e9 c5 01 00 00       	jmp    f0101286 <mon_showmappings+0x242>
   }
   while(begin < end){
      pte_t* pte = pgdir_walk(kern_pgdir,(void*)begin,0);
f01010c1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01010c8:	00 
f01010c9:	89 74 24 04          	mov    %esi,0x4(%esp)
f01010cd:	a1 b8 3e 29 f0       	mov    0xf0293eb8,%eax
f01010d2:	89 04 24             	mov    %eax,(%esp)
f01010d5:	e8 e3 10 00 00       	call   f01021bd <pgdir_walk>
f01010da:	89 c3                	mov    %eax,%ebx
      if(pte && ((*pte) & PTE_P)&&((*pte) & PTE_PS)){
f01010dc:	85 c0                	test   %eax,%eax
f01010de:	0f 84 88 01 00 00    	je     f010126c <mon_showmappings+0x228>
f01010e4:	8b 00                	mov    (%eax),%eax
f01010e6:	89 c2                	mov    %eax,%edx
f01010e8:	81 e2 81 00 00 00    	and    $0x81,%edx
f01010ee:	81 fa 81 00 00 00    	cmp    $0x81,%edx
f01010f4:	0f 85 b5 00 00 00    	jne    f01011af <mon_showmappings+0x16b>
          cprintf("0x%08x - 0x%08x   ",begin,begin+PTSIZE-1);
f01010fa:	8d 86 ff ff 3f 00    	lea    0x3fffff(%esi),%eax
f0101100:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101104:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101108:	c7 04 24 d9 91 10 f0 	movl   $0xf01091d9,(%esp)
f010110f:	e8 fb 3a 00 00       	call   f0104c0f <cprintf>
          cprintf("0x%08x - 0x%08x   ",PTE_ADDR(*pte),PTE_ADDR(*pte)+PTSIZE-1);
f0101114:	8b 03                	mov    (%ebx),%eax
f0101116:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010111b:	8d 90 ff ff 3f 00    	lea    0x3fffff(%eax),%edx
f0101121:	89 54 24 08          	mov    %edx,0x8(%esp)
f0101125:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101129:	c7 04 24 d9 91 10 f0 	movl   $0xf01091d9,(%esp)
f0101130:	e8 da 3a 00 00       	call   f0104c0f <cprintf>
          cprintf("kernel:");
f0101135:	c7 04 24 ec 91 10 f0 	movl   $0xf01091ec,(%esp)
f010113c:	e8 ce 3a 00 00       	call   f0104c0f <cprintf>
          if((*pte)& PTE_W)
f0101141:	f6 03 02             	testb  $0x2,(%ebx)
f0101144:	74 0e                	je     f0101154 <mon_showmappings+0x110>
            cprintf("R/W  ");
f0101146:	c7 04 24 f4 91 10 f0 	movl   $0xf01091f4,(%esp)
f010114d:	e8 bd 3a 00 00       	call   f0104c0f <cprintf>
f0101152:	eb 0c                	jmp    f0101160 <mon_showmappings+0x11c>
          else
            cprintf("R/-  ");
f0101154:	c7 04 24 fa 91 10 f0 	movl   $0xf01091fa,(%esp)
f010115b:	e8 af 3a 00 00       	call   f0104c0f <cprintf>
          cprintf("user:");
f0101160:	c7 04 24 00 92 10 f0 	movl   $0xf0109200,(%esp)
f0101167:	e8 a3 3a 00 00       	call   f0104c0f <cprintf>
          if((*pte)& PTE_U){
f010116c:	8b 03                	mov    (%ebx),%eax
f010116e:	a8 04                	test   $0x4,%al
f0101170:	74 20                	je     f0101192 <mon_showmappings+0x14e>
              if((*pte)& PTE_W)
f0101172:	a8 02                	test   $0x2,%al
f0101174:	74 0e                	je     f0101184 <mon_showmappings+0x140>
                cprintf("R/W  \n");
f0101176:	c7 04 24 06 92 10 f0 	movl   $0xf0109206,(%esp)
f010117d:	e8 8d 3a 00 00       	call   f0104c0f <cprintf>
f0101182:	eb 1a                	jmp    f010119e <mon_showmappings+0x15a>
              else
                cprintf("R/-  \n");
f0101184:	c7 04 24 0d 92 10 f0 	movl   $0xf010920d,(%esp)
f010118b:	e8 7f 3a 00 00       	call   f0104c0f <cprintf>
f0101190:	eb 0c                	jmp    f010119e <mon_showmappings+0x15a>
          }
          else
            cprintf("-/-  \n");
f0101192:	c7 04 24 14 92 10 f0 	movl   $0xf0109214,(%esp)
f0101199:	e8 71 3a 00 00       	call   f0104c0f <cprintf>
          if(begin + PTSIZE < begin)
f010119e:	81 c6 00 00 40 00    	add    $0x400000,%esi
f01011a4:	0f 83 d0 00 00 00    	jae    f010127a <mon_showmappings+0x236>
f01011aa:	e9 d7 00 00 00       	jmp    f0101286 <mon_showmappings+0x242>
            break;
          begin += PTSIZE;
      }
      else if(pte && ((*pte) & PTE_P)){
f01011af:	a8 01                	test   $0x1,%al
f01011b1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01011b8:	0f 84 ae 00 00 00    	je     f010126c <mon_showmappings+0x228>
          cprintf("0x%08x - 0x%08x   ",begin,begin+PGSIZE-1);
f01011be:	8d 86 ff 0f 00 00    	lea    0xfff(%esi),%eax
f01011c4:	89 44 24 08          	mov    %eax,0x8(%esp)
f01011c8:	89 74 24 04          	mov    %esi,0x4(%esp)
f01011cc:	c7 04 24 d9 91 10 f0 	movl   $0xf01091d9,(%esp)
f01011d3:	e8 37 3a 00 00       	call   f0104c0f <cprintf>
          cprintf("0x%08x - 0x%08x   ",PTE_ADDR(*pte),PTE_ADDR(*pte)+PGSIZE-1);
f01011d8:	8b 03                	mov    (%ebx),%eax
f01011da:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01011df:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f01011e5:	89 54 24 08          	mov    %edx,0x8(%esp)
f01011e9:	89 44 24 04          	mov    %eax,0x4(%esp)
f01011ed:	c7 04 24 d9 91 10 f0 	movl   $0xf01091d9,(%esp)
f01011f4:	e8 16 3a 00 00       	call   f0104c0f <cprintf>
          cprintf("kernel:");
f01011f9:	c7 04 24 ec 91 10 f0 	movl   $0xf01091ec,(%esp)
f0101200:	e8 0a 3a 00 00       	call   f0104c0f <cprintf>
          if((*pte)& PTE_W)
f0101205:	f6 03 02             	testb  $0x2,(%ebx)
f0101208:	74 0e                	je     f0101218 <mon_showmappings+0x1d4>
            cprintf("R/W  ");
f010120a:	c7 04 24 f4 91 10 f0 	movl   $0xf01091f4,(%esp)
f0101211:	e8 f9 39 00 00       	call   f0104c0f <cprintf>
f0101216:	eb 0c                	jmp    f0101224 <mon_showmappings+0x1e0>
          else
            cprintf("R/-  ");
f0101218:	c7 04 24 fa 91 10 f0 	movl   $0xf01091fa,(%esp)
f010121f:	e8 eb 39 00 00       	call   f0104c0f <cprintf>
          cprintf("user:");
f0101224:	c7 04 24 00 92 10 f0 	movl   $0xf0109200,(%esp)
f010122b:	e8 df 39 00 00       	call   f0104c0f <cprintf>
          if((*pte)& PTE_U){
f0101230:	8b 03                	mov    (%ebx),%eax
f0101232:	a8 04                	test   $0x4,%al
f0101234:	74 20                	je     f0101256 <mon_showmappings+0x212>
              if((*pte)& PTE_W)
f0101236:	a8 02                	test   $0x2,%al
f0101238:	74 0e                	je     f0101248 <mon_showmappings+0x204>
                cprintf("R/W  \n");
f010123a:	c7 04 24 06 92 10 f0 	movl   $0xf0109206,(%esp)
f0101241:	e8 c9 39 00 00       	call   f0104c0f <cprintf>
f0101246:	eb 1a                	jmp    f0101262 <mon_showmappings+0x21e>
              else
                cprintf("R/-  \n");
f0101248:	c7 04 24 0d 92 10 f0 	movl   $0xf010920d,(%esp)
f010124f:	e8 bb 39 00 00       	call   f0104c0f <cprintf>
f0101254:	eb 0c                	jmp    f0101262 <mon_showmappings+0x21e>
          }
          else
            cprintf("-/-  \n");
f0101256:	c7 04 24 14 92 10 f0 	movl   $0xf0109214,(%esp)
f010125d:	e8 ad 39 00 00       	call   f0104c0f <cprintf>
          if(begin + PGSIZE < begin)
f0101262:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0101268:	73 10                	jae    f010127a <mon_showmappings+0x236>
f010126a:	eb 1a                	jmp    f0101286 <mon_showmappings+0x242>
             break;
          begin += PGSIZE;
      }
      else{
          if(begin + PGSIZE < begin)
f010126c:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0101272:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0101278:	72 0c                	jb     f0101286 <mon_showmappings+0x242>
   uintptr_t end = strtol(argv[2],0,0);
   if(begin > end || begin != ROUNDUP(begin,PGSIZE)){
      cprintf("wrong virtual address\n");
      return 0;
   }
   while(begin < end){
f010127a:	39 f7                	cmp    %esi,%edi
f010127c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101280:	0f 87 3b fe ff ff    	ja     f01010c1 <mon_showmappings+0x7d>
            break;
          begin += PGSIZE;
      }
   }
   return 0;
}
f0101286:	b8 00 00 00 00       	mov    $0x0,%eax
f010128b:	83 c4 1c             	add    $0x1c,%esp
f010128e:	5b                   	pop    %ebx
f010128f:	5e                   	pop    %esi
f0101290:	5f                   	pop    %edi
f0101291:	5d                   	pop    %ebp
f0101292:	c3                   	ret    

f0101293 <mon_dump>:
    return 0;
}

int 
mon_dump(int argc,char** argv,struct Trapframe* tf)
{
f0101293:	55                   	push   %ebp
f0101294:	89 e5                	mov    %esp,%ebp
f0101296:	57                   	push   %edi
f0101297:	56                   	push   %esi
f0101298:	53                   	push   %ebx
f0101299:	83 ec 2c             	sub    $0x2c,%esp
f010129c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
   if(argc != 4){
f010129f:	83 7d 08 04          	cmpl   $0x4,0x8(%ebp)
f01012a3:	74 11                	je     f01012b6 <mon_dump+0x23>
      cprintf("Usage: dump [op] [addr] [size]\n");
f01012a5:	c7 04 24 54 94 10 f0 	movl   $0xf0109454,(%esp)
f01012ac:	e8 5e 39 00 00       	call   f0104c0f <cprintf>
      return 0;
f01012b1:	e9 75 02 00 00       	jmp    f010152b <mon_dump+0x298>
   }
   char* op = argv[1];
f01012b6:	8b 73 04             	mov    0x4(%ebx),%esi
   uint32_t size = strtol(argv[3],0,0);
f01012b9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01012c0:	00 
f01012c1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01012c8:	00 
f01012c9:	8b 43 0c             	mov    0xc(%ebx),%eax
f01012cc:	89 04 24             	mov    %eax,(%esp)
f01012cf:	e8 97 63 00 00       	call   f010766b <strtol>
f01012d4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
   uint32_t value = 0;
   if(strcmp(op,"v") == 0){
f01012d7:	c7 44 24 04 f8 a1 10 	movl   $0xf010a1f8,0x4(%esp)
f01012de:	f0 
f01012df:	89 34 24             	mov    %esi,(%esp)
f01012e2:	e8 3e 61 00 00       	call   f0107425 <strcmp>
f01012e7:	85 c0                	test   %eax,%eax
f01012e9:	0f 85 e6 00 00 00    	jne    f01013d5 <mon_dump+0x142>
      uintptr_t addr = strtol(argv[2],0,0); 
f01012ef:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01012f6:	00 
f01012f7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01012fe:	00 
f01012ff:	8b 43 08             	mov    0x8(%ebx),%eax
f0101302:	89 04 24             	mov    %eax,(%esp)
f0101305:	e8 61 63 00 00       	call   f010766b <strtol>
f010130a:	89 c3                	mov    %eax,%ebx
      if(addr != ROUNDUP(addr,PGSIZE)){
f010130c:	8d 80 ff 0f 00 00    	lea    0xfff(%eax),%eax
f0101312:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0101317:	39 c3                	cmp    %eax,%ebx
f0101319:	75 18                	jne    f0101333 <mon_dump+0xa0>
        cprintf("wrong address\n");
        return 0;
      }     
      int i = 0;
      for(i = 0; i<size;i++){
f010131b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f010131f:	0f 84 9f 00 00 00    	je     f01013c4 <mon_dump+0x131>
f0101325:	89 df                	mov    %ebx,%edi
f0101327:	b8 00 00 00 00       	mov    $0x0,%eax
f010132c:	be 00 00 00 00       	mov    $0x0,%esi
f0101331:	eb 21                	jmp    f0101354 <mon_dump+0xc1>
   uint32_t size = strtol(argv[3],0,0);
   uint32_t value = 0;
   if(strcmp(op,"v") == 0){
      uintptr_t addr = strtol(argv[2],0,0); 
      if(addr != ROUNDUP(addr,PGSIZE)){
        cprintf("wrong address\n");
f0101333:	c7 04 24 1b 92 10 f0 	movl   $0xf010921b,(%esp)
f010133a:	e8 d0 38 00 00       	call   f0104c0f <cprintf>
        return 0;
f010133f:	e9 e7 01 00 00       	jmp    f010152b <mon_dump+0x298>
      }     
      int i = 0;
      for(i = 0; i<size;i++){
        if(addr + i*4 < addr + (i-1)*4 && i != 0)
f0101344:	89 fb                	mov    %edi,%ebx
f0101346:	83 c3 04             	add    $0x4,%ebx
f0101349:	73 07                	jae    f0101352 <mon_dump+0xbf>
f010134b:	85 f6                	test   %esi,%esi
f010134d:	8d 76 00             	lea    0x0(%esi),%esi
f0101350:	75 72                	jne    f01013c4 <mon_dump+0x131>
f0101352:	89 df                	mov    %ebx,%edi
            break;
        if(i%4 == 0){
f0101354:	a8 03                	test   $0x3,%al
f0101356:	75 20                	jne    f0101378 <mon_dump+0xe5>
          if(i != 0)
f0101358:	85 f6                	test   %esi,%esi
f010135a:	74 0c                	je     f0101368 <mon_dump+0xd5>
             cprintf("\n");
f010135c:	c7 04 24 19 92 10 f0 	movl   $0xf0109219,(%esp)
f0101363:	e8 a7 38 00 00       	call   f0104c0f <cprintf>
          cprintf("0x%08x: ",addr + i*4);
f0101368:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010136c:	c7 04 24 2a 92 10 f0 	movl   $0xf010922a,(%esp)
f0101373:	e8 97 38 00 00       	call   f0104c0f <cprintf>
        }
        pte_t* pte = pgdir_walk(kern_pgdir,(void*)(addr+i*4),0);
f0101378:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010137f:	00 
f0101380:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101384:	a1 b8 3e 29 f0       	mov    0xf0293eb8,%eax
f0101389:	89 04 24             	mov    %eax,(%esp)
f010138c:	e8 2c 0e 00 00       	call   f01021bd <pgdir_walk>
        if((!pte) || (!(*pte) & PTE_P))
f0101391:	85 c0                	test   %eax,%eax
f0101393:	74 05                	je     f010139a <mon_dump+0x107>
f0101395:	83 38 00             	cmpl   $0x0,(%eax)
f0101398:	75 0e                	jne    f01013a8 <mon_dump+0x115>
            cprintf("--         ");
f010139a:	c7 04 24 33 92 10 f0 	movl   $0xf0109233,(%esp)
f01013a1:	e8 69 38 00 00       	call   f0104c0f <cprintf>
          if(i != 0)
             cprintf("\n");
          cprintf("0x%08x: ",addr + i*4);
        }
        pte_t* pte = pgdir_walk(kern_pgdir,(void*)(addr+i*4),0);
        if((!pte) || (!(*pte) & PTE_P))
f01013a6:	eb 12                	jmp    f01013ba <mon_dump+0x127>
            cprintf("--         ");
        else{
          value = *((uint32_t*)(addr + i*4));
          cprintf("0x%08x ",value);
f01013a8:	8b 03                	mov    (%ebx),%eax
f01013aa:	89 44 24 04          	mov    %eax,0x4(%esp)
f01013ae:	c7 04 24 3f 92 10 f0 	movl   $0xf010923f,(%esp)
f01013b5:	e8 55 38 00 00       	call   f0104c0f <cprintf>
      if(addr != ROUNDUP(addr,PGSIZE)){
        cprintf("wrong address\n");
        return 0;
      }     
      int i = 0;
      for(i = 0; i<size;i++){
f01013ba:	83 c6 01             	add    $0x1,%esi
f01013bd:	89 f0                	mov    %esi,%eax
f01013bf:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
f01013c2:	77 80                	ja     f0101344 <mon_dump+0xb1>
        else{
          value = *((uint32_t*)(addr + i*4));
          cprintf("0x%08x ",value);
        }
      }
      cprintf("\n");
f01013c4:	c7 04 24 19 92 10 f0 	movl   $0xf0109219,(%esp)
f01013cb:	e8 3f 38 00 00       	call   f0104c0f <cprintf>
f01013d0:	e9 56 01 00 00       	jmp    f010152b <mon_dump+0x298>
    }
    else if(strcmp(op,"p") == 0){
f01013d5:	c7 44 24 04 16 93 10 	movl   $0xf0109316,0x4(%esp)
f01013dc:	f0 
f01013dd:	89 34 24             	mov    %esi,(%esp)
f01013e0:	e8 40 60 00 00       	call   f0107425 <strcmp>
f01013e5:	85 c0                	test   %eax,%eax
f01013e7:	0f 85 32 01 00 00    	jne    f010151f <mon_dump+0x28c>
        physaddr_t addr = strtol(argv[2],0,0); 
f01013ed:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01013f4:	00 
f01013f5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01013fc:	00 
f01013fd:	8b 43 08             	mov    0x8(%ebx),%eax
f0101400:	89 04 24             	mov    %eax,(%esp)
f0101403:	e8 63 62 00 00       	call   f010766b <strtol>
f0101408:	89 c7                	mov    %eax,%edi
        if(addr != ROUNDUP(addr,PGSIZE)){
f010140a:	8d 80 ff 0f 00 00    	lea    0xfff(%eax),%eax
f0101410:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0101415:	39 c7                	cmp    %eax,%edi
f0101417:	75 1f                	jne    f0101438 <mon_dump+0x1a5>
           cprintf("wrong address\n");
           return 0;
        }  
        uintptr_t vaddr = 0;   
        int i = 0;       
        for(i = 0; i<size;i++){
f0101419:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f010141d:	0f 84 ee 00 00 00    	je     f0101511 <mon_dump+0x27e>
f0101423:	89 fe                	mov    %edi,%esi
f0101425:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f010142c:	b8 00 00 00 00       	mov    $0x0,%eax
f0101431:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101436:	eb 2c                	jmp    f0101464 <mon_dump+0x1d1>
      cprintf("\n");
    }
    else if(strcmp(op,"p") == 0){
        physaddr_t addr = strtol(argv[2],0,0); 
        if(addr != ROUNDUP(addr,PGSIZE)){
           cprintf("wrong address\n");
f0101438:	c7 04 24 1b 92 10 f0 	movl   $0xf010921b,(%esp)
f010143f:	e8 cb 37 00 00       	call   f0104c0f <cprintf>
           return 0;
f0101444:	e9 e2 00 00 00       	jmp    f010152b <mon_dump+0x298>
f0101449:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
f0101450:	89 55 e0             	mov    %edx,-0x20(%ebp)
        }  
        uintptr_t vaddr = 0;   
        int i = 0;       
        for(i = 0; i<size;i++){
          if(addr + i*4 < addr + (i-1)*4 && i != 0)
f0101453:	89 fe                	mov    %edi,%esi
f0101455:	83 c6 04             	add    $0x4,%esi
f0101458:	73 08                	jae    f0101462 <mon_dump+0x1cf>
f010145a:	85 db                	test   %ebx,%ebx
f010145c:	0f 85 af 00 00 00    	jne    f0101511 <mon_dump+0x27e>
f0101462:	89 f7                	mov    %esi,%edi
              break;
          if(i%4 == 0){
f0101464:	a8 03                	test   $0x3,%al
f0101466:	75 20                	jne    f0101488 <mon_dump+0x1f5>
             if(i != 0)
f0101468:	85 db                	test   %ebx,%ebx
f010146a:	74 0c                	je     f0101478 <mon_dump+0x1e5>
               cprintf("\n");
f010146c:	c7 04 24 19 92 10 f0 	movl   $0xf0109219,(%esp)
f0101473:	e8 97 37 00 00       	call   f0104c0f <cprintf>
             cprintf("0x%08x: ",addr + i*4);
f0101478:	89 74 24 04          	mov    %esi,0x4(%esp)
f010147c:	c7 04 24 2a 92 10 f0 	movl   $0xf010922a,(%esp)
f0101483:	e8 87 37 00 00       	call   f0104c0f <cprintf>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101488:	89 f0                	mov    %esi,%eax
f010148a:	c1 e8 0c             	shr    $0xc,%eax
f010148d:	3b 05 b4 3e 29 f0    	cmp    0xf0293eb4,%eax
f0101493:	72 20                	jb     f01014b5 <mon_dump+0x222>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101495:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0101499:	c7 44 24 08 c0 8d 10 	movl   $0xf0108dc0,0x8(%esp)
f01014a0:	f0 
f01014a1:	c7 44 24 04 35 01 00 	movl   $0x135,0x4(%esp)
f01014a8:	00 
f01014a9:	c7 04 24 47 92 10 f0 	movl   $0xf0109247,(%esp)
f01014b0:	e8 d0 eb ff ff       	call   f0100085 <_panic>
	return (void *)(pa + KERNBASE);
f01014b5:	81 ee 00 00 00 10    	sub    $0x10000000,%esi
          }
          vaddr = (uintptr_t)KADDR(addr + i*4);
          pte_t* pte = pgdir_walk(kern_pgdir,(void*)(vaddr+i*4),0);
f01014bb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01014c2:	00 
f01014c3:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01014c6:	8d 04 16             	lea    (%esi,%edx,1),%eax
f01014c9:	89 44 24 04          	mov    %eax,0x4(%esp)
f01014cd:	a1 b8 3e 29 f0       	mov    0xf0293eb8,%eax
f01014d2:	89 04 24             	mov    %eax,(%esp)
f01014d5:	e8 e3 0c 00 00       	call   f01021bd <pgdir_walk>
          if((!pte) || (!(*pte) & PTE_P))
f01014da:	85 c0                	test   %eax,%eax
f01014dc:	74 05                	je     f01014e3 <mon_dump+0x250>
f01014de:	83 38 00             	cmpl   $0x0,(%eax)
f01014e1:	75 0e                	jne    f01014f1 <mon_dump+0x25e>
              cprintf("--         ");
f01014e3:	c7 04 24 33 92 10 f0 	movl   $0xf0109233,(%esp)
f01014ea:	e8 20 37 00 00       	call   f0104c0f <cprintf>
               cprintf("\n");
             cprintf("0x%08x: ",addr + i*4);
          }
          vaddr = (uintptr_t)KADDR(addr + i*4);
          pte_t* pte = pgdir_walk(kern_pgdir,(void*)(vaddr+i*4),0);
          if((!pte) || (!(*pte) & PTE_P))
f01014ef:	eb 12                	jmp    f0101503 <mon_dump+0x270>
              cprintf("--         ");
          else{
            value = *((uint32_t*)(vaddr));
            cprintf("0x%08x ",value);
f01014f1:	8b 06                	mov    (%esi),%eax
f01014f3:	89 44 24 04          	mov    %eax,0x4(%esp)
f01014f7:	c7 04 24 3f 92 10 f0 	movl   $0xf010923f,(%esp)
f01014fe:	e8 0c 37 00 00       	call   f0104c0f <cprintf>
           cprintf("wrong address\n");
           return 0;
        }  
        uintptr_t vaddr = 0;   
        int i = 0;       
        for(i = 0; i<size;i++){
f0101503:	83 c3 01             	add    $0x1,%ebx
f0101506:	89 d8                	mov    %ebx,%eax
f0101508:	39 5d e4             	cmp    %ebx,-0x1c(%ebp)
f010150b:	0f 87 38 ff ff ff    	ja     f0101449 <mon_dump+0x1b6>
          else{
            value = *((uint32_t*)(vaddr));
            cprintf("0x%08x ",value);
          }
        }
         cprintf("\n");
f0101511:	c7 04 24 19 92 10 f0 	movl   $0xf0109219,(%esp)
f0101518:	e8 f2 36 00 00       	call   f0104c0f <cprintf>
f010151d:	eb 0c                	jmp    f010152b <mon_dump+0x298>
    }
    else{
        cprintf("Usage: dump [op] [addr] [size]\n");
f010151f:	c7 04 24 54 94 10 f0 	movl   $0xf0109454,(%esp)
f0101526:	e8 e4 36 00 00       	call   f0104c0f <cprintf>
        return 0;
    }
    return 0;
}
f010152b:	b8 00 00 00 00       	mov    $0x0,%eax
f0101530:	83 c4 2c             	add    $0x2c,%esp
f0101533:	5b                   	pop    %ebx
f0101534:	5e                   	pop    %esi
f0101535:	5f                   	pop    %edi
f0101536:	5d                   	pop    %ebp
f0101537:	c3                   	ret    

f0101538 <mon_c>:
  }
  return 0;
}

int 
mon_c(int argc,char **argv,struct Trapframe *tf){
f0101538:	55                   	push   %ebp
f0101539:	89 e5                	mov    %esp,%ebp
f010153b:	83 ec 38             	sub    $0x38,%esp
f010153e:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0101541:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0101544:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0101547:	8b 75 10             	mov    0x10(%ebp),%esi
  if(argc != 1)
f010154a:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
f010154e:	74 0e                	je     f010155e <mon_c+0x26>
    cprintf("Usage: c\n");
f0101550:	c7 04 24 56 92 10 f0 	movl   $0xf0109256,(%esp)
f0101557:	e8 b3 36 00 00       	call   f0104c0f <cprintf>
f010155c:	eb 48                	jmp    f01015a6 <mon_c+0x6e>
  else if(tf == NULL)
f010155e:	85 f6                	test   %esi,%esi
f0101560:	75 0e                	jne    f0101570 <mon_c+0x38>
    cprintf("trapframe error\n");
f0101562:	c7 04 24 89 91 10 f0 	movl   $0xf0109189,(%esp)
f0101569:	e8 a1 36 00 00       	call   f0104c0f <cprintf>
f010156e:	eb 36                	jmp    f01015a6 <mon_c+0x6e>
  else{
     curenv->env_tf = *tf;		
f0101570:	e8 29 66 00 00       	call   f0107b9e <cpunum>
f0101575:	bb 20 40 29 f0       	mov    $0xf0294020,%ebx
f010157a:	6b c0 74             	imul   $0x74,%eax,%eax
f010157d:	8b 44 18 08          	mov    0x8(%eax,%ebx,1),%eax
f0101581:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0101584:	b9 11 00 00 00       	mov    $0x11,%ecx
f0101589:	89 c7                	mov    %eax,%edi
f010158b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
     tf = &curenv->env_tf;
f010158d:	e8 0c 66 00 00       	call   f0107b9e <cpunum>
     env_run(curenv);
f0101592:	e8 07 66 00 00       	call   f0107b9e <cpunum>
f0101597:	6b c0 74             	imul   $0x74,%eax,%eax
f010159a:	8b 44 18 08          	mov    0x8(%eax,%ebx,1),%eax
f010159e:	89 04 24             	mov    %eax,(%esp)
f01015a1:	e8 84 2e 00 00       	call   f010442a <env_run>
  }

  return 0;
} 
f01015a6:	b8 00 00 00 00       	mov    $0x0,%eax
f01015ab:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f01015ae:	8b 75 f8             	mov    -0x8(%ebp),%esi
f01015b1:	8b 7d fc             	mov    -0x4(%ebp),%edi
f01015b4:	89 ec                	mov    %ebp,%esp
f01015b6:	5d                   	pop    %ebp
f01015b7:	c3                   	ret    

f01015b8 <mon_si>:
    }
    return 0;
}

int 
mon_si(int argc,char **argv,struct Trapframe *tf){
f01015b8:	55                   	push   %ebp
f01015b9:	89 e5                	mov    %esp,%ebp
f01015bb:	83 ec 68             	sub    $0x68,%esp
f01015be:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f01015c1:	89 75 f8             	mov    %esi,-0x8(%ebp)
f01015c4:	89 7d fc             	mov    %edi,-0x4(%ebp)
f01015c7:	8b 75 10             	mov    0x10(%ebp),%esi
  if(argc != 1)
f01015ca:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
f01015ce:	74 11                	je     f01015e1 <mon_si+0x29>
    cprintf("Usage: si\n");
f01015d0:	c7 04 24 60 92 10 f0 	movl   $0xf0109260,(%esp)
f01015d7:	e8 33 36 00 00       	call   f0104c0f <cprintf>
f01015dc:	e9 a2 00 00 00       	jmp    f0101683 <mon_si+0xcb>
  else if(tf == NULL)
f01015e1:	85 f6                	test   %esi,%esi
f01015e3:	75 11                	jne    f01015f6 <mon_si+0x3e>
    cprintf("trapframe error\n");
f01015e5:	c7 04 24 89 91 10 f0 	movl   $0xf0109189,(%esp)
f01015ec:	e8 1e 36 00 00       	call   f0104c0f <cprintf>
f01015f1:	e9 8d 00 00 00       	jmp    f0101683 <mon_si+0xcb>
  else{
    struct Eipdebuginfo info;
    tf->tf_eflags = tf->tf_eflags | 0x100;
f01015f6:	81 4e 38 00 01 00 00 	orl    $0x100,0x38(%esi)
    cprintf("tf_eip=%08x\n",tf->tf_eip);
f01015fd:	8b 46 30             	mov    0x30(%esi),%eax
f0101600:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101604:	c7 04 24 6b 92 10 f0 	movl   $0xf010926b,(%esp)
f010160b:	e8 ff 35 00 00       	call   f0104c0f <cprintf>
    debuginfo_eip(tf->tf_eip,&info);
f0101610:	8d 45 d0             	lea    -0x30(%ebp),%eax
f0101613:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101617:	8b 46 30             	mov    0x30(%esi),%eax
f010161a:	89 04 24             	mov    %eax,(%esp)
f010161d:	e8 8c 51 00 00       	call   f01067ae <debuginfo_eip>
    cprintf("%s:%d: %s+%d\n",info.eip_file,info.eip_line,info.eip_fn_name,tf->tf_eip-info.eip_fn_addr);
f0101622:	8b 46 30             	mov    0x30(%esi),%eax
f0101625:	2b 45 e0             	sub    -0x20(%ebp),%eax
f0101628:	89 44 24 10          	mov    %eax,0x10(%esp)
f010162c:	8b 45 d8             	mov    -0x28(%ebp),%eax
f010162f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101633:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101636:	89 44 24 08          	mov    %eax,0x8(%esp)
f010163a:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010163d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101641:	c7 04 24 57 91 10 f0 	movl   $0xf0109157,(%esp)
f0101648:	e8 c2 35 00 00       	call   f0104c0f <cprintf>
    curenv->env_tf = *tf;		
f010164d:	e8 4c 65 00 00       	call   f0107b9e <cpunum>
f0101652:	bb 20 40 29 f0       	mov    $0xf0294020,%ebx
f0101657:	6b c0 74             	imul   $0x74,%eax,%eax
f010165a:	8b 44 18 08          	mov    0x8(%eax,%ebx,1),%eax
f010165e:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0101661:	b9 11 00 00 00       	mov    $0x11,%ecx
f0101666:	89 c7                	mov    %eax,%edi
f0101668:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
    tf = &curenv->env_tf;
f010166a:	e8 2f 65 00 00       	call   f0107b9e <cpunum>
    env_run(curenv);
f010166f:	e8 2a 65 00 00       	call   f0107b9e <cpunum>
f0101674:	6b c0 74             	imul   $0x74,%eax,%eax
f0101677:	8b 44 18 08          	mov    0x8(%eax,%ebx,1),%eax
f010167b:	89 04 24             	mov    %eax,(%esp)
f010167e:	e8 a7 2d 00 00       	call   f010442a <env_run>
  }
  return 0;
}
f0101683:	b8 00 00 00 00       	mov    $0x0,%eax
f0101688:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f010168b:	8b 75 f8             	mov    -0x8(%ebp),%esi
f010168e:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0101691:	89 ec                	mov    %ebp,%esp
f0101693:	5d                   	pop    %ebp
f0101694:	c3                   	ret    
	...

f01016a0 <page_free_npages>:
//	2. Add the pages to the chunk list
//	
//	Return 0 if everything ok
int
page_free_npages(struct Page *pp, int n)
{
f01016a0:	55                   	push   %ebp
f01016a1:	89 e5                	mov    %esp,%ebp
f01016a3:	53                   	push   %ebx
f01016a4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// Fill this function
        struct Page* tmpPP = pp;
        int i = 0;
        if(pp == NULL)
f01016a7:	85 db                	test   %ebx,%ebx
f01016a9:	74 3c                	je     f01016e7 <page_free_npages+0x47>
            return -1;
        for(i = 0;i< n-1;i++){
f01016ab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01016ae:	83 e9 01             	sub    $0x1,%ecx
f01016b1:	89 d8                	mov    %ebx,%eax
f01016b3:	85 c9                	test   %ecx,%ecx
f01016b5:	7e 1b                	jle    f01016d2 <page_free_npages+0x32>
             if(tmpPP->pp_link == NULL)
f01016b7:	8b 03                	mov    (%ebx),%eax
f01016b9:	ba 00 00 00 00       	mov    $0x0,%edx
f01016be:	85 c0                	test   %eax,%eax
f01016c0:	75 08                	jne    f01016ca <page_free_npages+0x2a>
f01016c2:	eb 23                	jmp    f01016e7 <page_free_npages+0x47>
f01016c4:	8b 00                	mov    (%eax),%eax
f01016c6:	85 c0                	test   %eax,%eax
f01016c8:	74 1d                	je     f01016e7 <page_free_npages+0x47>
	// Fill this function
        struct Page* tmpPP = pp;
        int i = 0;
        if(pp == NULL)
            return -1;
        for(i = 0;i< n-1;i++){
f01016ca:	83 c2 01             	add    $0x1,%edx
f01016cd:	39 ca                	cmp    %ecx,%edx
f01016cf:	90                   	nop
f01016d0:	7c f2                	jl     f01016c4 <page_free_npages+0x24>
             if(tmpPP->pp_link == NULL)
                 return -1;
             tmpPP = tmpPP->pp_link;
        }
        tmpPP->pp_link = page_free_list;
f01016d2:	8b 15 50 32 29 f0    	mov    0xf0293250,%edx
f01016d8:	89 10                	mov    %edx,(%eax)
        page_free_list = pp;
f01016da:	89 1d 50 32 29 f0    	mov    %ebx,0xf0293250
f01016e0:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
f01016e5:	eb 05                	jmp    f01016ec <page_free_npages+0x4c>
f01016e7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f01016ec:	5b                   	pop    %ebx
f01016ed:	5d                   	pop    %ebp
f01016ee:	c3                   	ret    

f01016ef <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct Page *pp)
{
f01016ef:	55                   	push   %ebp
f01016f0:	89 e5                	mov    %esp,%ebp
f01016f2:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
        pp->pp_link = page_free_list;
f01016f5:	8b 15 50 32 29 f0    	mov    0xf0293250,%edx
f01016fb:	89 10                	mov    %edx,(%eax)
        page_free_list = pp;
f01016fd:	a3 50 32 29 f0       	mov    %eax,0xf0293250
}
f0101702:	5d                   	pop    %ebp
f0101703:	c3                   	ret    

f0101704 <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct Page* pp)
{
f0101704:	55                   	push   %ebp
f0101705:	89 e5                	mov    %esp,%ebp
f0101707:	83 ec 04             	sub    $0x4,%esp
f010170a:	8b 45 08             	mov    0x8(%ebp),%eax
	if (--pp->pp_ref == 0)
f010170d:	0f b7 50 04          	movzwl 0x4(%eax),%edx
f0101711:	83 ea 01             	sub    $0x1,%edx
f0101714:	66 89 50 04          	mov    %dx,0x4(%eax)
f0101718:	66 85 d2             	test   %dx,%dx
f010171b:	75 08                	jne    f0101725 <page_decref+0x21>
		page_free(pp);
f010171d:	89 04 24             	mov    %eax,(%esp)
f0101720:	e8 ca ff ff ff       	call   f01016ef <page_free>
}
f0101725:	c9                   	leave  
f0101726:	c3                   	ret    

f0101727 <pgdir_walk_large>:
	return &vpt[PTX(va)];
}

pte_t*
pgdir_walk_large(pde_t *pgdir, const void *va, int create)
{
f0101727:	55                   	push   %ebp
f0101728:	89 e5                	mov    %esp,%ebp
f010172a:	8b 45 0c             	mov    0xc(%ebp),%eax
f010172d:	c1 e8 16             	shr    $0x16,%eax
f0101730:	c1 e0 02             	shl    $0x2,%eax
f0101733:	03 45 08             	add    0x8(%ebp),%eax
        return &pgdir[PDX(va)];
}
f0101736:	5d                   	pop    %ebp
f0101737:	c3                   	ret    

f0101738 <check_va2pa_large>:
	return PTE_ADDR(p[PTX(va)]);
}

static physaddr_t
check_va2pa_large(pde_t *pgdir, uintptr_t va)
{
f0101738:	55                   	push   %ebp
f0101739:	89 e5                	mov    %esp,%ebp
	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P) | !(*pgdir & PTE_PS))
f010173b:	c1 ea 16             	shr    $0x16,%edx
f010173e:	8b 04 90             	mov    (%eax,%edx,4),%eax
f0101741:	89 c2                	mov    %eax,%edx
f0101743:	81 e2 81 00 00 00    	and    $0x81,%edx
f0101749:	89 c1                	mov    %eax,%ecx
f010174b:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0101751:	81 fa 81 00 00 00    	cmp    $0x81,%edx
f0101757:	0f 94 c0             	sete   %al
f010175a:	0f b6 c0             	movzbl %al,%eax
f010175d:	83 e8 01             	sub    $0x1,%eax
f0101760:	09 c8                	or     %ecx,%eax
		return ~0;
	return PTE_ADDR(*pgdir);
}
f0101762:	5d                   	pop    %ebp
f0101763:	c3                   	ret    

f0101764 <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0101764:	55                   	push   %ebp
f0101765:	89 e5                	mov    %esp,%ebp
f0101767:	83 ec 18             	sub    $0x18,%esp
f010176a:	89 c2                	mov    %eax,%edx
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f010176c:	83 3d 48 32 29 f0 00 	cmpl   $0x0,0xf0293248
f0101773:	75 0f                	jne    f0101784 <boot_alloc+0x20>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0101775:	b8 5f 68 2f f0       	mov    $0xf02f685f,%eax
f010177a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010177f:	a3 48 32 29 f0       	mov    %eax,0xf0293248
	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
        result = nextfree;
f0101784:	a1 48 32 29 f0       	mov    0xf0293248,%eax
        nextfree = ROUNDUP(nextfree+n,PGSIZE);
f0101789:	8d 94 10 ff 0f 00 00 	lea    0xfff(%eax,%edx,1),%edx
f0101790:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101796:	89 15 48 32 29 f0    	mov    %edx,0xf0293248
        if((uint32_t)nextfree >= 0xF0400000){    // VA's [KERNBASE, KERNBASE+4MB)
f010179c:	81 fa ff ff 3f f0    	cmp    $0xf03fffff,%edx
f01017a2:	76 21                	jbe    f01017c5 <boot_alloc+0x61>
           nextfree = result;
f01017a4:	a3 48 32 29 f0       	mov    %eax,0xf0293248
           panic("boot_alloc:Out of memory\n");
f01017a9:	c7 44 24 08 4c 95 10 	movl   $0xf010954c,0x8(%esp)
f01017b0:	f0 
f01017b1:	c7 44 24 04 72 00 00 	movl   $0x72,0x4(%esp)
f01017b8:	00 
f01017b9:	c7 04 24 66 95 10 f0 	movl   $0xf0109566,(%esp)
f01017c0:	e8 c0 e8 ff ff       	call   f0100085 <_panic>
        }
	return result;
}
f01017c5:	c9                   	leave  
f01017c6:	c3                   	ret    

f01017c7 <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f01017c7:	55                   	push   %ebp
f01017c8:	89 e5                	mov    %esp,%ebp
f01017ca:	56                   	push   %esi
f01017cb:	53                   	push   %ebx
f01017cc:	83 ec 10             	sub    $0x10,%esp
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 0; i < npages; i++) {
f01017cf:	83 3d b4 3e 29 f0 00 	cmpl   $0x0,0xf0293eb4
f01017d6:	0f 84 3f 01 00 00    	je     f010191b <page_init+0x154>
f01017dc:	be 00 00 00 00       	mov    $0x0,%esi
f01017e1:	bb 00 00 00 00       	mov    $0x0,%ebx
                if(i == 0){
f01017e6:	85 db                	test   %ebx,%ebx
f01017e8:	75 1b                	jne    f0101805 <page_init+0x3e>
                   pages[i].pp_ref = 1;
f01017ea:	a1 bc 3e 29 f0       	mov    0xf0293ebc,%eax
f01017ef:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
                   pages[i].pp_link = NULL;
f01017f5:	a1 bc 3e 29 f0       	mov    0xf0293ebc,%eax
f01017fa:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
f0101800:	e9 04 01 00 00       	jmp    f0101909 <page_init+0x142>
                }
                else if(i == MPENTRY_PADDR/PGSIZE){
f0101805:	83 fb 07             	cmp    $0x7,%ebx
f0101808:	75 1c                	jne    f0101826 <page_init+0x5f>
                   pages[i].pp_ref = 1;
f010180a:	a1 bc 3e 29 f0       	mov    0xf0293ebc,%eax
f010180f:	66 c7 40 3c 01 00    	movw   $0x1,0x3c(%eax)
                   pages[i].pp_link = NULL;
f0101815:	a1 bc 3e 29 f0       	mov    0xf0293ebc,%eax
f010181a:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)
f0101821:	e9 e3 00 00 00       	jmp    f0101909 <page_init+0x142>
                }
                else if(i>=1 && i < npages_basemem){
f0101826:	39 1d 4c 32 29 f0    	cmp    %ebx,0xf029324c
f010182c:	76 2c                	jbe    f010185a <page_init+0x93>
                //else if(i >= 1 && i < MPENTRY_PADDR/PGSIZE){
                   pages[i].pp_ref = 0;
f010182e:	a1 bc 3e 29 f0       	mov    0xf0293ebc,%eax
f0101833:	66 c7 44 30 04 00 00 	movw   $0x0,0x4(%eax,%esi,1)
                   pages[i].pp_link = page_free_list;
f010183a:	8b 15 50 32 29 f0    	mov    0xf0293250,%edx
f0101840:	a1 bc 3e 29 f0       	mov    0xf0293ebc,%eax
f0101845:	89 14 30             	mov    %edx,(%eax,%esi,1)
                   page_free_list = &pages[i];
f0101848:	89 f0                	mov    %esi,%eax
f010184a:	03 05 bc 3e 29 f0    	add    0xf0293ebc,%eax
f0101850:	a3 50 32 29 f0       	mov    %eax,0xf0293250
                }
                else if(i == MPENTRY_PADDR/PGSIZE){
                   pages[i].pp_ref = 1;
                   pages[i].pp_link = NULL;
                }
                else if(i>=1 && i < npages_basemem){
f0101855:	e9 af 00 00 00       	jmp    f0101909 <page_init+0x142>
                   pages[i].pp_ref = 0;
                   pages[i].pp_link = page_free_list;
                   page_free_list = &pages[i];
                }
                
                else if(i >= IOPHYSMEM/PGSIZE && i<EXTPHYSMEM/PGSIZE){
f010185a:	8d 83 60 ff ff ff    	lea    -0xa0(%ebx),%eax
f0101860:	83 f8 5f             	cmp    $0x5f,%eax
f0101863:	77 1d                	ja     f0101882 <page_init+0xbb>
                   pages[i].pp_ref = 1;
f0101865:	a1 bc 3e 29 f0       	mov    0xf0293ebc,%eax
f010186a:	66 c7 44 30 04 01 00 	movw   $0x1,0x4(%eax,%esi,1)
                   pages[i].pp_link = NULL;
f0101871:	a1 bc 3e 29 f0       	mov    0xf0293ebc,%eax
f0101876:	c7 04 30 00 00 00 00 	movl   $0x0,(%eax,%esi,1)
f010187d:	e9 87 00 00 00       	jmp    f0101909 <page_init+0x142>
                }
                else if(i >= EXTPHYSMEM/PGSIZE && i<((uint32_t)PADDR(boot_alloc(0)))/PGSIZE){
f0101882:	81 fb ff 00 00 00    	cmp    $0xff,%ebx
f0101888:	76 58                	jbe    f01018e2 <page_init+0x11b>
f010188a:	b8 00 00 00 00       	mov    $0x0,%eax
f010188f:	e8 d0 fe ff ff       	call   f0101764 <boot_alloc>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0101894:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101899:	77 20                	ja     f01018bb <page_init+0xf4>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010189b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010189f:	c7 44 24 08 9c 8d 10 	movl   $0xf0108d9c,0x8(%esp)
f01018a6:	f0 
f01018a7:	c7 44 24 04 62 01 00 	movl   $0x162,0x4(%esp)
f01018ae:	00 
f01018af:	c7 04 24 66 95 10 f0 	movl   $0xf0109566,(%esp)
f01018b6:	e8 ca e7 ff ff       	call   f0100085 <_panic>
f01018bb:	8d 80 00 00 00 10    	lea    0x10000000(%eax),%eax
f01018c1:	c1 e8 0c             	shr    $0xc,%eax
f01018c4:	39 c3                	cmp    %eax,%ebx
f01018c6:	73 1a                	jae    f01018e2 <page_init+0x11b>
		   pages[i].pp_ref = 1;
f01018c8:	a1 bc 3e 29 f0       	mov    0xf0293ebc,%eax
f01018cd:	66 c7 44 30 04 01 00 	movw   $0x1,0x4(%eax,%esi,1)
                   pages[i].pp_link = NULL;
f01018d4:	a1 bc 3e 29 f0       	mov    0xf0293ebc,%eax
f01018d9:	c7 04 30 00 00 00 00 	movl   $0x0,(%eax,%esi,1)
                
                else if(i >= IOPHYSMEM/PGSIZE && i<EXTPHYSMEM/PGSIZE){
                   pages[i].pp_ref = 1;
                   pages[i].pp_link = NULL;
                }
                else if(i >= EXTPHYSMEM/PGSIZE && i<((uint32_t)PADDR(boot_alloc(0)))/PGSIZE){
f01018e0:	eb 27                	jmp    f0101909 <page_init+0x142>
		   pages[i].pp_ref = 1;
                   pages[i].pp_link = NULL;
                }
                else{
                   pages[i].pp_ref = 0;
f01018e2:	a1 bc 3e 29 f0       	mov    0xf0293ebc,%eax
f01018e7:	66 c7 44 30 04 00 00 	movw   $0x0,0x4(%eax,%esi,1)
		   pages[i].pp_link = page_free_list;
f01018ee:	8b 15 50 32 29 f0    	mov    0xf0293250,%edx
f01018f4:	a1 bc 3e 29 f0       	mov    0xf0293ebc,%eax
f01018f9:	89 14 30             	mov    %edx,(%eax,%esi,1)
		   page_free_list = &pages[i];
f01018fc:	89 f0                	mov    %esi,%eax
f01018fe:	03 05 bc 3e 29 f0    	add    0xf0293ebc,%eax
f0101904:	a3 50 32 29 f0       	mov    %eax,0xf0293250
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 0; i < npages; i++) {
f0101909:	83 c3 01             	add    $0x1,%ebx
f010190c:	83 c6 08             	add    $0x8,%esi
f010190f:	39 1d b4 3e 29 f0    	cmp    %ebx,0xf0293eb4
f0101915:	0f 87 cb fe ff ff    	ja     f01017e6 <page_init+0x1f>
                   pages[i].pp_ref = 0;
		   pages[i].pp_link = page_free_list;
		   page_free_list = &pages[i];
                }
	}
	chunk_list = NULL;
f010191b:	c7 05 54 32 29 f0 00 	movl   $0x0,0xf0293254
f0101922:	00 00 00 
}
f0101925:	83 c4 10             	add    $0x10,%esp
f0101928:	5b                   	pop    %ebx
f0101929:	5e                   	pop    %esi
f010192a:	5d                   	pop    %ebp
f010192b:	c3                   	ret    

f010192c <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f010192c:	55                   	push   %ebp
f010192d:	89 e5                	mov    %esp,%ebp
f010192f:	83 ec 08             	sub    $0x8,%esp
	// Flush the entry only if we're modifying the current address space.
	if (!curenv || curenv->env_pgdir == pgdir)
f0101932:	e8 67 62 00 00       	call   f0107b9e <cpunum>
f0101937:	6b c0 74             	imul   $0x74,%eax,%eax
f010193a:	83 b8 28 40 29 f0 00 	cmpl   $0x0,-0xfd6bfd8(%eax)
f0101941:	74 16                	je     f0101959 <tlb_invalidate+0x2d>
f0101943:	e8 56 62 00 00       	call   f0107b9e <cpunum>
f0101948:	6b c0 74             	imul   $0x74,%eax,%eax
f010194b:	8b 90 28 40 29 f0    	mov    -0xfd6bfd8(%eax),%edx
f0101951:	8b 45 08             	mov    0x8(%ebp),%eax
f0101954:	39 42 64             	cmp    %eax,0x64(%edx)
f0101957:	75 06                	jne    f010195f <tlb_invalidate+0x33>
}

static __inline void 
invlpg(void *addr)
{ 
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0101959:	8b 45 0c             	mov    0xc(%ebp),%eax
f010195c:	0f 01 38             	invlpg (%eax)
		invlpg(va);
}
f010195f:	c9                   	leave  
f0101960:	c3                   	ret    

f0101961 <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f0101961:	55                   	push   %ebp
f0101962:	89 e5                	mov    %esp,%ebp
f0101964:	83 ec 18             	sub    $0x18,%esp
f0101967:	89 5d f8             	mov    %ebx,-0x8(%ebp)
f010196a:	89 75 fc             	mov    %esi,-0x4(%ebp)
f010196d:	89 c3                	mov    %eax,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f010196f:	89 04 24             	mov    %eax,(%esp)
f0101972:	e8 2d 31 00 00       	call   f0104aa4 <mc146818_read>
f0101977:	89 c6                	mov    %eax,%esi
f0101979:	83 c3 01             	add    $0x1,%ebx
f010197c:	89 1c 24             	mov    %ebx,(%esp)
f010197f:	e8 20 31 00 00       	call   f0104aa4 <mc146818_read>
f0101984:	c1 e0 08             	shl    $0x8,%eax
f0101987:	09 f0                	or     %esi,%eax
}
f0101989:	8b 5d f8             	mov    -0x8(%ebp),%ebx
f010198c:	8b 75 fc             	mov    -0x4(%ebp),%esi
f010198f:	89 ec                	mov    %ebp,%esp
f0101991:	5d                   	pop    %ebp
f0101992:	c3                   	ret    

f0101993 <i386_detect_memory>:

static void
i386_detect_memory(void)
{
f0101993:	55                   	push   %ebp
f0101994:	89 e5                	mov    %esp,%ebp
f0101996:	83 ec 18             	sub    $0x18,%esp
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f0101999:	b8 15 00 00 00       	mov    $0x15,%eax
f010199e:	e8 be ff ff ff       	call   f0101961 <nvram_read>
f01019a3:	c1 e0 0a             	shl    $0xa,%eax
f01019a6:	89 c2                	mov    %eax,%edx
f01019a8:	c1 fa 1f             	sar    $0x1f,%edx
f01019ab:	c1 ea 14             	shr    $0x14,%edx
f01019ae:	8d 04 02             	lea    (%edx,%eax,1),%eax
f01019b1:	c1 f8 0c             	sar    $0xc,%eax
f01019b4:	a3 4c 32 29 f0       	mov    %eax,0xf029324c
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f01019b9:	b8 17 00 00 00       	mov    $0x17,%eax
f01019be:	e8 9e ff ff ff       	call   f0101961 <nvram_read>
f01019c3:	89 c2                	mov    %eax,%edx
f01019c5:	c1 e2 0a             	shl    $0xa,%edx
f01019c8:	89 d0                	mov    %edx,%eax
f01019ca:	c1 f8 1f             	sar    $0x1f,%eax
f01019cd:	c1 e8 14             	shr    $0x14,%eax
f01019d0:	01 d0                	add    %edx,%eax
f01019d2:	c1 f8 0c             	sar    $0xc,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f01019d5:	85 c0                	test   %eax,%eax
f01019d7:	74 0e                	je     f01019e7 <i386_detect_memory+0x54>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f01019d9:	8d 90 00 01 00 00    	lea    0x100(%eax),%edx
f01019df:	89 15 b4 3e 29 f0    	mov    %edx,0xf0293eb4
f01019e5:	eb 0c                	jmp    f01019f3 <i386_detect_memory+0x60>
	else
		npages = npages_basemem;
f01019e7:	8b 15 4c 32 29 f0    	mov    0xf029324c,%edx
f01019ed:	89 15 b4 3e 29 f0    	mov    %edx,0xf0293eb4

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01019f3:	c1 e0 0c             	shl    $0xc,%eax
f01019f6:	c1 e8 0a             	shr    $0xa,%eax
f01019f9:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01019fd:	a1 4c 32 29 f0       	mov    0xf029324c,%eax
f0101a02:	c1 e0 0c             	shl    $0xc,%eax
f0101a05:	c1 e8 0a             	shr    $0xa,%eax
f0101a08:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101a0c:	a1 b4 3e 29 f0       	mov    0xf0293eb4,%eax
f0101a11:	c1 e0 0c             	shl    $0xc,%eax
f0101a14:	c1 e8 0a             	shr    $0xa,%eax
f0101a17:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101a1b:	c7 04 24 90 98 10 f0 	movl   $0xf0109890,(%esp)
f0101a22:	e8 e8 31 00 00       	call   f0104c0f <cprintf>
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
		npages_extmem * PGSIZE / 1024);
}
f0101a27:	c9                   	leave  
f0101a28:	c3                   	ret    

f0101a29 <page_alloc_npages>:
// Try to reuse the pages cached in the chuck list
//
// Hint: use page2kva and memset
struct Page *
page_alloc_npages(int alloc_flags, int n)
{
f0101a29:	55                   	push   %ebp
f0101a2a:	89 e5                	mov    %esp,%ebp
f0101a2c:	57                   	push   %edi
f0101a2d:	56                   	push   %esi
f0101a2e:	53                   	push   %ebx
f0101a2f:	83 ec 3c             	sub    $0x3c,%esp
	// Fill this function
	struct Page* newPage = NULL;
        int i,j;
        int fflag = 0;
        int flag = 0;
        if(n <= 0){
f0101a32:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0101a36:	0f 8e 69 01 00 00    	jle    f0101ba5 <page_alloc_npages+0x17c>
            return newPage;
        }
        if(page_free_list == NULL)
f0101a3c:	8b 35 50 32 29 f0    	mov    0xf0293250,%esi
f0101a42:	85 f6                	test   %esi,%esi
f0101a44:	0f 84 5b 01 00 00    	je     f0101ba5 <page_alloc_npages+0x17c>
            return newPage;
        for(i = 0; i+n-1 <npages;i++){
f0101a4a:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101a4d:	83 e8 01             	sub    $0x1,%eax
f0101a50:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101a53:	8b 15 b4 3e 29 f0    	mov    0xf0293eb4,%edx
f0101a59:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0101a5c:	39 d0                	cmp    %edx,%eax
f0101a5e:	0f 83 41 01 00 00    	jae    f0101ba5 <page_alloc_npages+0x17c>
           for(j = 0;j<n;j++){
              struct Page* tmpFree = page_free_list;
              flag = 0;
              if(pages[i+j].pp_ref != 0)
f0101a64:	a1 bc 3e 29 f0       	mov    0xf0293ebc,%eax
f0101a69:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101a6c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0101a6f:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
                 break;
              while(tmpFree!= NULL){
                 if(tmpFree == &pages[i+j]){
f0101a76:	89 f7                	mov    %esi,%edi
        if(n <= 0){
            return newPage;
        }
        if(page_free_list == NULL)
            return newPage;
        for(i = 0; i+n-1 <npages;i++){
f0101a78:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101a7b:	83 ea 01             	sub    $0x1,%edx
f0101a7e:	89 55 d8             	mov    %edx,-0x28(%ebp)
f0101a81:	eb 6a                	jmp    f0101aed <page_alloc_npages+0xc4>
           for(j = 0;j<n;j++){
              struct Page* tmpFree = page_free_list;
              flag = 0;
              if(pages[i+j].pp_ref != 0)
f0101a83:	89 ca                	mov    %ecx,%edx
f0101a85:	0f b7 41 04          	movzwl 0x4(%ecx),%eax
f0101a89:	83 c1 08             	add    $0x8,%ecx
f0101a8c:	66 85 c0             	test   %ax,%ax
f0101a8f:	75 45                	jne    f0101ad6 <page_alloc_npages+0xad>
                 break;
              while(tmpFree!= NULL){
                 if(tmpFree == &pages[i+j]){
f0101a91:	89 f8                	mov    %edi,%eax
f0101a93:	39 d6                	cmp    %edx,%esi
f0101a95:	75 0b                	jne    f0101aa2 <page_alloc_npages+0x79>
f0101a97:	eb 11                	jmp    f0101aaa <page_alloc_npages+0x81>
f0101a99:	39 d0                	cmp    %edx,%eax
f0101a9b:	90                   	nop
f0101a9c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101aa0:	74 08                	je     f0101aaa <page_alloc_npages+0x81>
                   flag = 1;
                   break;
                 }
                 tmpFree = tmpFree->pp_link;
f0101aa2:	8b 00                	mov    (%eax),%eax
           for(j = 0;j<n;j++){
              struct Page* tmpFree = page_free_list;
              flag = 0;
              if(pages[i+j].pp_ref != 0)
                 break;
              while(tmpFree!= NULL){
f0101aa4:	85 c0                	test   %eax,%eax
f0101aa6:	75 f1                	jne    f0101a99 <page_alloc_npages+0x70>
f0101aa8:	eb 10                	jmp    f0101aba <page_alloc_npages+0x91>
            return newPage;
        }
        if(page_free_list == NULL)
            return newPage;
        for(i = 0; i+n-1 <npages;i++){
           for(j = 0;j<n;j++){
f0101aaa:	83 c3 01             	add    $0x1,%ebx
f0101aad:	39 5d 0c             	cmp    %ebx,0xc(%ebp)
f0101ab0:	7f d1                	jg     f0101a83 <page_alloc_npages+0x5a>
f0101ab2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0101ab8:	eb 08                	jmp    f0101ac2 <page_alloc_npages+0x99>
                 tmpFree = tmpFree->pp_link;
              }
              if(flag == 0)
                 break;
           }
           if(j >= n){
f0101aba:	39 5d 0c             	cmp    %ebx,0xc(%ebp)
f0101abd:	8d 76 00             	lea    0x0(%esi),%esi
f0101ac0:	7f 14                	jg     f0101ad6 <page_alloc_npages+0xad>
             fflag = 1;
             newPage = &pages[i];
f0101ac2:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101ac5:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0101ac8:	8d 1c c2             	lea    (%edx,%eax,8),%ebx
        }
        if(fflag == 0)
           return NULL;
        struct Page* tmp = page_free_list;
        while(tmp != NULL){
            if(tmp->pp_link >= &newPage[0] && tmp->pp_link <= &newPage[n-1])
f0101acb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0101ace:	8d 7c cb f8          	lea    -0x8(%ebx,%ecx,8),%edi
f0101ad2:	89 f2                	mov    %esi,%edx
f0101ad4:	eb 2f                	jmp    f0101b05 <page_alloc_npages+0xdc>
        if(n <= 0){
            return newPage;
        }
        if(page_free_list == NULL)
            return newPage;
        for(i = 0; i+n-1 <npages;i++){
f0101ad6:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
f0101ada:	83 45 e4 08          	addl   $0x8,-0x1c(%ebp)
f0101ade:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0101ae1:	03 45 e0             	add    -0x20(%ebp),%eax
f0101ae4:	3b 45 dc             	cmp    -0x24(%ebp),%eax
f0101ae7:	0f 83 b8 00 00 00    	jae    f0101ba5 <page_alloc_npages+0x17c>
f0101aed:	8b 55 e4             	mov    -0x1c(%ebp),%edx
           for(j = 0;j<n;j++){
              struct Page* tmpFree = page_free_list;
              flag = 0;
              if(pages[i+j].pp_ref != 0)
f0101af0:	66 83 7a 04 00       	cmpw   $0x0,0x4(%edx)
f0101af5:	75 df                	jne    f0101ad6 <page_alloc_npages+0xad>
f0101af7:	89 d1                	mov    %edx,%ecx
f0101af9:	83 c1 08             	add    $0x8,%ecx
f0101afc:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101b01:	eb 8e                	jmp    f0101a91 <page_alloc_npages+0x68>
f0101b03:	89 c2                	mov    %eax,%edx
        }
        if(fflag == 0)
           return NULL;
        struct Page* tmp = page_free_list;
        while(tmp != NULL){
            if(tmp->pp_link >= &newPage[0] && tmp->pp_link <= &newPage[n-1])
f0101b05:	8b 02                	mov    (%edx),%eax
f0101b07:	39 c3                	cmp    %eax,%ebx
f0101b09:	77 0a                	ja     f0101b15 <page_alloc_npages+0xec>
f0101b0b:	39 f8                	cmp    %edi,%eax
f0101b0d:	77 06                	ja     f0101b15 <page_alloc_npages+0xec>
                 tmp->pp_link = tmp->pp_link->pp_link;
f0101b0f:	8b 00                	mov    (%eax),%eax
f0101b11:	89 02                	mov    %eax,(%edx)
f0101b13:	89 d0                	mov    %edx,%eax
           }               
        }
        if(fflag == 0)
           return NULL;
        struct Page* tmp = page_free_list;
        while(tmp != NULL){
f0101b15:	85 c0                	test   %eax,%eax
f0101b17:	75 ea                	jne    f0101b03 <page_alloc_npages+0xda>
            if(tmp->pp_link >= &newPage[0] && tmp->pp_link <= &newPage[n-1])
                 tmp->pp_link = tmp->pp_link->pp_link;
            else
                 tmp = tmp->pp_link;
        }
        if(page_free_list >= &newPage[0] && page_free_list <= &newPage[n-1]){
f0101b19:	39 de                	cmp    %ebx,%esi
f0101b1b:	72 0b                	jb     f0101b28 <page_alloc_npages+0xff>
f0101b1d:	39 fe                	cmp    %edi,%esi
f0101b1f:	77 07                	ja     f0101b28 <page_alloc_npages+0xff>
           page_free_list = page_free_list->pp_link;
f0101b21:	8b 06                	mov    (%esi),%eax
f0101b23:	a3 50 32 29 f0       	mov    %eax,0xf0293250
        }
         for(i = 0;i<n-1;i++){
f0101b28:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f0101b2c:	7e 15                	jle    f0101b43 <page_alloc_npages+0x11a>
f0101b2e:	8d 43 08             	lea    0x8(%ebx),%eax
f0101b31:	ba 01 00 00 00       	mov    $0x1,%edx
             newPage[i].pp_link = &newPage[i+1];
f0101b36:	89 40 f8             	mov    %eax,-0x8(%eax)
f0101b39:	83 c2 01             	add    $0x1,%edx
f0101b3c:	83 c0 08             	add    $0x8,%eax
                 tmp = tmp->pp_link;
        }
        if(page_free_list >= &newPage[0] && page_free_list <= &newPage[n-1]){
           page_free_list = page_free_list->pp_link;
        }
         for(i = 0;i<n-1;i++){
f0101b3f:	39 d1                	cmp    %edx,%ecx
f0101b41:	75 f3                	jne    f0101b36 <page_alloc_npages+0x10d>
             newPage[i].pp_link = &newPage[i+1];
         }
         if(alloc_flags & ALLOC_ZERO){
f0101b43:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0101b47:	74 61                	je     f0101baa <page_alloc_npages+0x181>


static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0101b49:	89 d8                	mov    %ebx,%eax
f0101b4b:	2b 05 bc 3e 29 f0    	sub    0xf0293ebc,%eax
f0101b51:	c1 f8 03             	sar    $0x3,%eax
f0101b54:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101b57:	89 c2                	mov    %eax,%edx
f0101b59:	c1 ea 0c             	shr    $0xc,%edx
f0101b5c:	3b 15 b4 3e 29 f0    	cmp    0xf0293eb4,%edx
f0101b62:	72 20                	jb     f0101b84 <page_alloc_npages+0x15b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101b64:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101b68:	c7 44 24 08 c0 8d 10 	movl   $0xf0108dc0,0x8(%esp)
f0101b6f:	f0 
f0101b70:	c7 44 24 04 59 00 00 	movl   $0x59,0x4(%esp)
f0101b77:	00 
f0101b78:	c7 04 24 72 95 10 f0 	movl   $0xf0109572,(%esp)
f0101b7f:	e8 01 e5 ff ff       	call   f0100085 <_panic>
           char* addr = page2kva(newPage);
           memset(addr,0,PGSIZE*n);
f0101b84:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101b87:	c1 e2 0c             	shl    $0xc,%edx
f0101b8a:	89 54 24 08          	mov    %edx,0x8(%esp)
f0101b8e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101b95:	00 
f0101b96:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101b9b:	89 04 24             	mov    %eax,(%esp)
f0101b9e:	e8 53 59 00 00       	call   f01074f6 <memset>
f0101ba3:	eb 05                	jmp    f0101baa <page_alloc_npages+0x181>
f0101ba5:	bb 00 00 00 00       	mov    $0x0,%ebx
         }           
        return newPage; 
}
f0101baa:	89 d8                	mov    %ebx,%eax
f0101bac:	83 c4 3c             	add    $0x3c,%esp
f0101baf:	5b                   	pop    %ebx
f0101bb0:	5e                   	pop    %esi
f0101bb1:	5f                   	pop    %edi
f0101bb2:	5d                   	pop    %ebp
f0101bb3:	c3                   	ret    

f0101bb4 <page_realloc_npages>:
// You can man realloc for better understanding.
// (Try to reuse the allocated pages as many as possible.)
//
struct Page *
page_realloc_npages(struct Page *pp, int old_n, int new_n)
{
f0101bb4:	55                   	push   %ebp
f0101bb5:	89 e5                	mov    %esp,%ebp
f0101bb7:	83 ec 38             	sub    $0x38,%esp
f0101bba:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0101bbd:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0101bc0:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0101bc3:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0101bc6:	8b 45 0c             	mov    0xc(%ebp),%eax
	// Fill this function
        if(old_n <= 0 || new_n <= 0)
f0101bc9:	85 c0                	test   %eax,%eax
f0101bcb:	0f 8e d2 00 00 00    	jle    f0101ca3 <page_realloc_npages+0xef>
f0101bd1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0101bd5:	0f 8e c8 00 00 00    	jle    f0101ca3 <page_realloc_npages+0xef>
static int
check_continuous(struct Page *pp, int num_page)
{
	struct Page *tmp; 
	int i;
	for( tmp = pp, i = 0; i < num_page - 1; tmp = tmp->pp_link, i++ )
f0101bdb:	8d 50 ff             	lea    -0x1(%eax),%edx
f0101bde:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0101be1:	85 d2                	test   %edx,%edx
f0101be3:	0f 8e ce 00 00 00    	jle    f0101cb7 <page_realloc_npages+0x103>
	{
		if(tmp == NULL) 
f0101be9:	85 db                	test   %ebx,%ebx
f0101beb:	0f 84 b7 00 00 00    	je     f0101ca8 <page_realloc_npages+0xf4>
		{
			return 0;
		}
		if( (page2pa(tmp->pp_link) - page2pa(tmp)) != PGSIZE )
f0101bf1:	8b 13                	mov    (%ebx),%edx


static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0101bf3:	8b 3d bc 3e 29 f0    	mov    0xf0293ebc,%edi
f0101bf9:	89 d1                	mov    %edx,%ecx
f0101bfb:	29 f9                	sub    %edi,%ecx
f0101bfd:	c1 f9 03             	sar    $0x3,%ecx
f0101c00:	89 de                	mov    %ebx,%esi
f0101c02:	29 fe                	sub    %edi,%esi
f0101c04:	c1 fe 03             	sar    $0x3,%esi
f0101c07:	29 f1                	sub    %esi,%ecx
f0101c09:	89 ce                	mov    %ecx,%esi
f0101c0b:	c1 e6 0c             	shl    $0xc,%esi
f0101c0e:	b9 00 00 00 00       	mov    $0x0,%ecx
f0101c13:	81 fe 00 10 00 00    	cmp    $0x1000,%esi
f0101c19:	74 28                	je     f0101c43 <page_realloc_npages+0x8f>
f0101c1b:	e9 83 00 00 00       	jmp    f0101ca3 <page_realloc_npages+0xef>
{
	struct Page *tmp; 
	int i;
	for( tmp = pp, i = 0; i < num_page - 1; tmp = tmp->pp_link, i++ )
	{
		if(tmp == NULL) 
f0101c20:	85 d2                	test   %edx,%edx
f0101c22:	74 7f                	je     f0101ca3 <page_realloc_npages+0xef>
		{
			return 0;
		}
		if( (page2pa(tmp->pp_link) - page2pa(tmp)) != PGSIZE )
f0101c24:	8b 02                	mov    (%edx),%eax
f0101c26:	89 c3                	mov    %eax,%ebx
f0101c28:	29 fb                	sub    %edi,%ebx
f0101c2a:	c1 fb 03             	sar    $0x3,%ebx
f0101c2d:	29 fa                	sub    %edi,%edx
f0101c2f:	c1 fa 03             	sar    $0x3,%edx
f0101c32:	29 d3                	sub    %edx,%ebx
f0101c34:	c1 e3 0c             	shl    $0xc,%ebx
f0101c37:	81 fb 00 10 00 00    	cmp    $0x1000,%ebx
f0101c3d:	75 64                	jne    f0101ca3 <page_realloc_npages+0xef>
f0101c3f:	89 c2                	mov    %eax,%edx
f0101c41:	eb 09                	jmp    f0101c4c <page_realloc_npages+0x98>
f0101c43:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0101c46:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0101c49:	89 45 e0             	mov    %eax,-0x20(%ebp)
static int
check_continuous(struct Page *pp, int num_page)
{
	struct Page *tmp; 
	int i;
	for( tmp = pp, i = 0; i < num_page - 1; tmp = tmp->pp_link, i++ )
f0101c4c:	83 c1 01             	add    $0x1,%ecx
f0101c4f:	39 ce                	cmp    %ecx,%esi
f0101c51:	7f cd                	jg     f0101c20 <page_realloc_npages+0x6c>
f0101c53:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0101c56:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101c59:	eb 5c                	jmp    f0101cb7 <page_realloc_npages+0x103>
            return NULL;
        if(!check_continuous(pp,old_n))
            return NULL;
        if(old_n == new_n)
            return pp;
        if(old_n > new_n){
f0101c5b:	3b 45 10             	cmp    0x10(%ebp),%eax
f0101c5e:	7e 20                	jle    f0101c80 <page_realloc_npages+0xcc>
           struct Page* lastPage = &pp[new_n-1];
f0101c60:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0101c63:	8d 54 cb f8          	lea    -0x8(%ebx,%ecx,8),%edx
           lastPage->pp_link = NULL;
f0101c67:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
           page_free_npages(&lastPage[1],old_n-new_n);
f0101c6d:	29 c8                	sub    %ecx,%eax
f0101c6f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101c73:	83 c2 08             	add    $0x8,%edx
f0101c76:	89 14 24             	mov    %edx,(%esp)
f0101c79:	e8 22 fa ff ff       	call   f01016a0 <page_free_npages>
           return pp;
f0101c7e:	eb 28                	jmp    f0101ca8 <page_realloc_npages+0xf4>
        }
        else{
           struct Page* newPage;
           page_free_npages(pp,old_n);
f0101c80:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101c84:	89 1c 24             	mov    %ebx,(%esp)
f0101c87:	e8 14 fa ff ff       	call   f01016a0 <page_free_npages>
           newPage = page_alloc_npages(0,new_n);
f0101c8c:	8b 45 10             	mov    0x10(%ebp),%eax
f0101c8f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101c93:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101c9a:	e8 8a fd ff ff       	call   f0101a29 <page_alloc_npages>
f0101c9f:	89 c3                	mov    %eax,%ebx
           return newPage;
f0101ca1:	eb 05                	jmp    f0101ca8 <page_realloc_npages+0xf4>
f0101ca3:	bb 00 00 00 00       	mov    $0x0,%ebx
        }
	return NULL;
}
f0101ca8:	89 d8                	mov    %ebx,%eax
f0101caa:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0101cad:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0101cb0:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0101cb3:	89 ec                	mov    %ebp,%esp
f0101cb5:	5d                   	pop    %ebp
f0101cb6:	c3                   	ret    
	// Fill this function
        if(old_n <= 0 || new_n <= 0)
            return NULL;
        if(!check_continuous(pp,old_n))
            return NULL;
        if(old_n == new_n)
f0101cb7:	3b 45 10             	cmp    0x10(%ebp),%eax
f0101cba:	75 9f                	jne    f0101c5b <page_realloc_npages+0xa7>
f0101cbc:	eb ea                	jmp    f0101ca8 <page_realloc_npages+0xf4>

f0101cbe <va2pa>:
	cprintf("check_kern_pgdir() succeeded!\n");
}


physaddr_t va2pa(pde_t *pgdir,uintptr_t va)
{
f0101cbe:	55                   	push   %ebp
f0101cbf:	89 e5                	mov    %esp,%ebp
f0101cc1:	83 ec 18             	sub    $0x18,%esp
f0101cc4:	8b 55 0c             	mov    0xc(%ebp),%edx
    pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
f0101cc7:	89 d1                	mov    %edx,%ecx
f0101cc9:	c1 e9 16             	shr    $0x16,%ecx
f0101ccc:	8b 45 08             	mov    0x8(%ebp),%eax
f0101ccf:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0101cd2:	a8 01                	test   $0x1,%al
f0101cd4:	74 57                	je     f0101d2d <va2pa+0x6f>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0101cd6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101cdb:	89 c1                	mov    %eax,%ecx
f0101cdd:	c1 e9 0c             	shr    $0xc,%ecx
f0101ce0:	3b 0d b4 3e 29 f0    	cmp    0xf0293eb4,%ecx
f0101ce6:	72 20                	jb     f0101d08 <va2pa+0x4a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101ce8:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101cec:	c7 44 24 08 c0 8d 10 	movl   $0xf0108dc0,0x8(%esp)
f0101cf3:	f0 
f0101cf4:	c7 44 24 04 29 04 00 	movl   $0x429,0x4(%esp)
f0101cfb:	00 
f0101cfc:	c7 04 24 66 95 10 f0 	movl   $0xf0109566,(%esp)
f0101d03:	e8 7d e3 ff ff       	call   f0100085 <_panic>
	if (!(p[PTX(va)] & PTE_P))
f0101d08:	89 d1                	mov    %edx,%ecx
f0101d0a:	c1 e9 0c             	shr    $0xc,%ecx
f0101d0d:	81 e1 ff 03 00 00    	and    $0x3ff,%ecx
f0101d13:	8b 84 88 00 00 00 f0 	mov    -0x10000000(%eax,%ecx,4),%eax
f0101d1a:	a8 01                	test   $0x1,%al
f0101d1c:	74 0f                	je     f0101d2d <va2pa+0x6f>
		return ~0;
	return PTE_ADDR(p[PTX(va)])|PGOFF(va);
f0101d1e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0101d23:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
f0101d29:	09 d0                	or     %edx,%eax
f0101d2b:	eb 05                	jmp    f0101d32 <va2pa+0x74>
f0101d2d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f0101d32:	c9                   	leave  
f0101d33:	c3                   	ret    

f0101d34 <check_va2pa>:
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0101d34:	55                   	push   %ebp
f0101d35:	89 e5                	mov    %esp,%ebp
f0101d37:	83 ec 18             	sub    $0x18,%esp
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
f0101d3a:	89 d1                	mov    %edx,%ecx
f0101d3c:	c1 e9 16             	shr    $0x16,%ecx
f0101d3f:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0101d42:	a8 01                	test   $0x1,%al
f0101d44:	74 4d                	je     f0101d93 <check_va2pa+0x5f>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0101d46:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101d4b:	89 c1                	mov    %eax,%ecx
f0101d4d:	c1 e9 0c             	shr    $0xc,%ecx
f0101d50:	3b 0d b4 3e 29 f0    	cmp    0xf0293eb4,%ecx
f0101d56:	72 20                	jb     f0101d78 <check_va2pa+0x44>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101d58:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101d5c:	c7 44 24 08 c0 8d 10 	movl   $0xf0108dc0,0x8(%esp)
f0101d63:	f0 
f0101d64:	c7 44 24 04 3c 04 00 	movl   $0x43c,0x4(%esp)
f0101d6b:	00 
f0101d6c:	c7 04 24 66 95 10 f0 	movl   $0xf0109566,(%esp)
f0101d73:	e8 0d e3 ff ff       	call   f0100085 <_panic>
	if (!(p[PTX(va)] & PTE_P))
f0101d78:	c1 ea 0c             	shr    $0xc,%edx
f0101d7b:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0101d81:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0101d88:	a8 01                	test   $0x1,%al
f0101d8a:	74 07                	je     f0101d93 <check_va2pa+0x5f>
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0101d8c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0101d91:	eb 05                	jmp    f0101d98 <check_va2pa+0x64>
f0101d93:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f0101d98:	c9                   	leave  
f0101d99:	c3                   	ret    

f0101d9a <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0101d9a:	55                   	push   %ebp
f0101d9b:	89 e5                	mov    %esp,%ebp
f0101d9d:	57                   	push   %edi
f0101d9e:	56                   	push   %esi
f0101d9f:	53                   	push   %ebx
f0101da0:	83 ec 5c             	sub    $0x5c,%esp
	struct Page *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0101da3:	83 f8 01             	cmp    $0x1,%eax
f0101da6:	19 f6                	sbb    %esi,%esi
f0101da8:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
f0101dae:	83 c6 01             	add    $0x1,%esi
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0101db1:	8b 1d 50 32 29 f0    	mov    0xf0293250,%ebx
f0101db7:	85 db                	test   %ebx,%ebx
f0101db9:	75 1c                	jne    f0101dd7 <check_page_free_list+0x3d>
		panic("'page_free_list' is a null pointer!");
f0101dbb:	c7 44 24 08 cc 98 10 	movl   $0xf01098cc,0x8(%esp)
f0101dc2:	f0 
f0101dc3:	c7 44 24 04 54 03 00 	movl   $0x354,0x4(%esp)
f0101dca:	00 
f0101dcb:	c7 04 24 66 95 10 f0 	movl   $0xf0109566,(%esp)
f0101dd2:	e8 ae e2 ff ff       	call   f0100085 <_panic>

	if (only_low_memory) {
f0101dd7:	85 c0                	test   %eax,%eax
f0101dd9:	74 52                	je     f0101e2d <check_page_free_list+0x93>
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct Page *pp1, *pp2;
		struct Page **tp[2] = { &pp1, &pp2 };
f0101ddb:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101dde:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0101de1:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0101de4:	89 45 dc             	mov    %eax,-0x24(%ebp)


static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0101de7:	8b 0d bc 3e 29 f0    	mov    0xf0293ebc,%ecx
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0101ded:	89 d8                	mov    %ebx,%eax
f0101def:	29 c8                	sub    %ecx,%eax
f0101df1:	c1 e0 09             	shl    $0x9,%eax
f0101df4:	c1 e8 16             	shr    $0x16,%eax
f0101df7:	39 c6                	cmp    %eax,%esi
f0101df9:	0f 96 c0             	setbe  %al
f0101dfc:	0f b6 c0             	movzbl %al,%eax
			*tp[pagetype] = pp;
f0101dff:	8b 54 85 d8          	mov    -0x28(%ebp,%eax,4),%edx
f0101e03:	89 1a                	mov    %ebx,(%edx)
			tp[pagetype] = &pp->pp_link;
f0101e05:	89 5c 85 d8          	mov    %ebx,-0x28(%ebp,%eax,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct Page *pp1, *pp2;
		struct Page **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0101e09:	8b 1b                	mov    (%ebx),%ebx
f0101e0b:	85 db                	test   %ebx,%ebx
f0101e0d:	75 de                	jne    f0101ded <check_page_free_list+0x53>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0101e0f:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0101e12:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0101e18:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0101e1b:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0101e1e:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0101e20:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0101e23:	89 1d 50 32 29 f0    	mov    %ebx,0xf0293250
	}
	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link){
f0101e29:	85 db                	test   %ebx,%ebx
f0101e2b:	74 67                	je     f0101e94 <check_page_free_list+0xfa>
f0101e2d:	89 d8                	mov    %ebx,%eax
f0101e2f:	2b 05 bc 3e 29 f0    	sub    0xf0293ebc,%eax
f0101e35:	c1 f8 03             	sar    $0x3,%eax
f0101e38:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0101e3b:	89 c2                	mov    %eax,%edx
f0101e3d:	c1 ea 16             	shr    $0x16,%edx
f0101e40:	39 d6                	cmp    %edx,%esi
f0101e42:	76 4a                	jbe    f0101e8e <check_page_free_list+0xf4>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101e44:	89 c2                	mov    %eax,%edx
f0101e46:	c1 ea 0c             	shr    $0xc,%edx
f0101e49:	3b 15 b4 3e 29 f0    	cmp    0xf0293eb4,%edx
f0101e4f:	72 20                	jb     f0101e71 <check_page_free_list+0xd7>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101e51:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101e55:	c7 44 24 08 c0 8d 10 	movl   $0xf0108dc0,0x8(%esp)
f0101e5c:	f0 
f0101e5d:	c7 44 24 04 59 00 00 	movl   $0x59,0x4(%esp)
f0101e64:	00 
f0101e65:	c7 04 24 72 95 10 f0 	movl   $0xf0109572,(%esp)
f0101e6c:	e8 14 e2 ff ff       	call   f0100085 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0101e71:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
f0101e78:	00 
f0101e79:	c7 44 24 04 97 00 00 	movl   $0x97,0x4(%esp)
f0101e80:	00 
f0101e81:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101e86:	89 04 24             	mov    %eax,(%esp)
f0101e89:	e8 68 56 00 00       	call   f01074f6 <memset>
		*tp[0] = pp2;
		page_free_list = pp1;
	}
	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link){
f0101e8e:	8b 1b                	mov    (%ebx),%ebx
f0101e90:	85 db                	test   %ebx,%ebx
f0101e92:	75 99                	jne    f0101e2d <check_page_free_list+0x93>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);
	}
	first_free_page = (char *) boot_alloc(0);
f0101e94:	b8 00 00 00 00       	mov    $0x0,%eax
f0101e99:	e8 c6 f8 ff ff       	call   f0101764 <boot_alloc>
f0101e9e:	89 45 c4             	mov    %eax,-0x3c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0101ea1:	8b 15 50 32 29 f0    	mov    0xf0293250,%edx
f0101ea7:	85 d2                	test   %edx,%edx
f0101ea9:	0f 84 3c 02 00 00    	je     f01020eb <check_page_free_list+0x351>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0101eaf:	8b 1d bc 3e 29 f0    	mov    0xf0293ebc,%ebx
f0101eb5:	39 da                	cmp    %ebx,%edx
f0101eb7:	72 51                	jb     f0101f0a <check_page_free_list+0x170>
		assert(pp < pages + npages);
f0101eb9:	a1 b4 3e 29 f0       	mov    0xf0293eb4,%eax
f0101ebe:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0101ec1:	8d 04 c3             	lea    (%ebx,%eax,8),%eax
f0101ec4:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101ec7:	39 c2                	cmp    %eax,%edx
f0101ec9:	73 68                	jae    f0101f33 <check_page_free_list+0x199>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0101ecb:	89 5d cc             	mov    %ebx,-0x34(%ebp)
f0101ece:	89 d0                	mov    %edx,%eax
f0101ed0:	29 d8                	sub    %ebx,%eax
f0101ed2:	a8 07                	test   $0x7,%al
f0101ed4:	0f 85 86 00 00 00    	jne    f0101f60 <check_page_free_list+0x1c6>


static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0101eda:	c1 f8 03             	sar    $0x3,%eax
f0101edd:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0101ee0:	85 c0                	test   %eax,%eax
f0101ee2:	0f 84 a6 00 00 00    	je     f0101f8e <check_page_free_list+0x1f4>
		assert(page2pa(pp) != IOPHYSMEM);
f0101ee8:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0101eed:	0f 84 c6 00 00 00    	je     f0101fb9 <check_page_free_list+0x21f>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0101ef3:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0101ef8:	0f 85 0a 01 00 00    	jne    f0102008 <check_page_free_list+0x26e>
f0101efe:	66 90                	xchg   %ax,%ax
f0101f00:	e9 df 00 00 00       	jmp    f0101fe4 <check_page_free_list+0x24a>
			memset(page2kva(pp), 0x97, 128);
	}
	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0101f05:	3b 55 b4             	cmp    -0x4c(%ebp),%edx
f0101f08:	73 24                	jae    f0101f2e <check_page_free_list+0x194>
f0101f0a:	c7 44 24 0c 80 95 10 	movl   $0xf0109580,0xc(%esp)
f0101f11:	f0 
f0101f12:	c7 44 24 08 8c 95 10 	movl   $0xf010958c,0x8(%esp)
f0101f19:	f0 
f0101f1a:	c7 44 24 04 6d 03 00 	movl   $0x36d,0x4(%esp)
f0101f21:	00 
f0101f22:	c7 04 24 66 95 10 f0 	movl   $0xf0109566,(%esp)
f0101f29:	e8 57 e1 ff ff       	call   f0100085 <_panic>
		assert(pp < pages + npages);
f0101f2e:	3b 55 d0             	cmp    -0x30(%ebp),%edx
f0101f31:	72 24                	jb     f0101f57 <check_page_free_list+0x1bd>
f0101f33:	c7 44 24 0c a1 95 10 	movl   $0xf01095a1,0xc(%esp)
f0101f3a:	f0 
f0101f3b:	c7 44 24 08 8c 95 10 	movl   $0xf010958c,0x8(%esp)
f0101f42:	f0 
f0101f43:	c7 44 24 04 6e 03 00 	movl   $0x36e,0x4(%esp)
f0101f4a:	00 
f0101f4b:	c7 04 24 66 95 10 f0 	movl   $0xf0109566,(%esp)
f0101f52:	e8 2e e1 ff ff       	call   f0100085 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0101f57:	89 d0                	mov    %edx,%eax
f0101f59:	2b 45 cc             	sub    -0x34(%ebp),%eax
f0101f5c:	a8 07                	test   $0x7,%al
f0101f5e:	74 24                	je     f0101f84 <check_page_free_list+0x1ea>
f0101f60:	c7 44 24 0c f0 98 10 	movl   $0xf01098f0,0xc(%esp)
f0101f67:	f0 
f0101f68:	c7 44 24 08 8c 95 10 	movl   $0xf010958c,0x8(%esp)
f0101f6f:	f0 
f0101f70:	c7 44 24 04 6f 03 00 	movl   $0x36f,0x4(%esp)
f0101f77:	00 
f0101f78:	c7 04 24 66 95 10 f0 	movl   $0xf0109566,(%esp)
f0101f7f:	e8 01 e1 ff ff       	call   f0100085 <_panic>
f0101f84:	c1 f8 03             	sar    $0x3,%eax
f0101f87:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0101f8a:	85 c0                	test   %eax,%eax
f0101f8c:	75 24                	jne    f0101fb2 <check_page_free_list+0x218>
f0101f8e:	c7 44 24 0c b5 95 10 	movl   $0xf01095b5,0xc(%esp)
f0101f95:	f0 
f0101f96:	c7 44 24 08 8c 95 10 	movl   $0xf010958c,0x8(%esp)
f0101f9d:	f0 
f0101f9e:	c7 44 24 04 72 03 00 	movl   $0x372,0x4(%esp)
f0101fa5:	00 
f0101fa6:	c7 04 24 66 95 10 f0 	movl   $0xf0109566,(%esp)
f0101fad:	e8 d3 e0 ff ff       	call   f0100085 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0101fb2:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0101fb7:	75 24                	jne    f0101fdd <check_page_free_list+0x243>
f0101fb9:	c7 44 24 0c c6 95 10 	movl   $0xf01095c6,0xc(%esp)
f0101fc0:	f0 
f0101fc1:	c7 44 24 08 8c 95 10 	movl   $0xf010958c,0x8(%esp)
f0101fc8:	f0 
f0101fc9:	c7 44 24 04 73 03 00 	movl   $0x373,0x4(%esp)
f0101fd0:	00 
f0101fd1:	c7 04 24 66 95 10 f0 	movl   $0xf0109566,(%esp)
f0101fd8:	e8 a8 e0 ff ff       	call   f0100085 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0101fdd:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0101fe2:	75 31                	jne    f0102015 <check_page_free_list+0x27b>
f0101fe4:	c7 44 24 0c 24 99 10 	movl   $0xf0109924,0xc(%esp)
f0101feb:	f0 
f0101fec:	c7 44 24 08 8c 95 10 	movl   $0xf010958c,0x8(%esp)
f0101ff3:	f0 
f0101ff4:	c7 44 24 04 74 03 00 	movl   $0x374,0x4(%esp)
f0101ffb:	00 
f0101ffc:	c7 04 24 66 95 10 f0 	movl   $0xf0109566,(%esp)
f0102003:	e8 7d e0 ff ff       	call   f0100085 <_panic>
f0102008:	be 00 00 00 00       	mov    $0x0,%esi
f010200d:	bf 00 00 00 00       	mov    $0x0,%edi
f0102012:	89 5d b4             	mov    %ebx,-0x4c(%ebp)
		assert(page2pa(pp) != EXTPHYSMEM);
f0102015:	3d 00 00 10 00       	cmp    $0x100000,%eax
f010201a:	75 24                	jne    f0102040 <check_page_free_list+0x2a6>
f010201c:	c7 44 24 0c df 95 10 	movl   $0xf01095df,0xc(%esp)
f0102023:	f0 
f0102024:	c7 44 24 08 8c 95 10 	movl   $0xf010958c,0x8(%esp)
f010202b:	f0 
f010202c:	c7 44 24 04 75 03 00 	movl   $0x375,0x4(%esp)
f0102033:	00 
f0102034:	c7 04 24 66 95 10 f0 	movl   $0xf0109566,(%esp)
f010203b:	e8 45 e0 ff ff       	call   f0100085 <_panic>
f0102040:	89 c1                	mov    %eax,%ecx
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0102042:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0102047:	76 59                	jbe    f01020a2 <check_page_free_list+0x308>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102049:	89 c3                	mov    %eax,%ebx
f010204b:	c1 eb 0c             	shr    $0xc,%ebx
f010204e:	39 5d c8             	cmp    %ebx,-0x38(%ebp)
f0102051:	77 20                	ja     f0102073 <check_page_free_list+0x2d9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102053:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102057:	c7 44 24 08 c0 8d 10 	movl   $0xf0108dc0,0x8(%esp)
f010205e:	f0 
f010205f:	c7 44 24 04 59 00 00 	movl   $0x59,0x4(%esp)
f0102066:	00 
f0102067:	c7 04 24 72 95 10 f0 	movl   $0xf0109572,(%esp)
f010206e:	e8 12 e0 ff ff       	call   f0100085 <_panic>
f0102073:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
f0102079:	39 5d c4             	cmp    %ebx,-0x3c(%ebp)
f010207c:	76 24                	jbe    f01020a2 <check_page_free_list+0x308>
f010207e:	c7 44 24 0c 48 99 10 	movl   $0xf0109948,0xc(%esp)
f0102085:	f0 
f0102086:	c7 44 24 08 8c 95 10 	movl   $0xf010958c,0x8(%esp)
f010208d:	f0 
f010208e:	c7 44 24 04 76 03 00 	movl   $0x376,0x4(%esp)
f0102095:	00 
f0102096:	c7 04 24 66 95 10 f0 	movl   $0xf0109566,(%esp)
f010209d:	e8 e3 df ff ff       	call   f0100085 <_panic>
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f01020a2:	3d 00 70 00 00       	cmp    $0x7000,%eax
f01020a7:	75 24                	jne    f01020cd <check_page_free_list+0x333>
f01020a9:	c7 44 24 0c f9 95 10 	movl   $0xf01095f9,0xc(%esp)
f01020b0:	f0 
f01020b1:	c7 44 24 08 8c 95 10 	movl   $0xf010958c,0x8(%esp)
f01020b8:	f0 
f01020b9:	c7 44 24 04 78 03 00 	movl   $0x378,0x4(%esp)
f01020c0:	00 
f01020c1:	c7 04 24 66 95 10 f0 	movl   $0xf0109566,(%esp)
f01020c8:	e8 b8 df ff ff       	call   f0100085 <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
f01020cd:	81 f9 ff ff 0f 00    	cmp    $0xfffff,%ecx
f01020d3:	77 05                	ja     f01020da <check_page_free_list+0x340>
			++nfree_basemem;
f01020d5:	83 c7 01             	add    $0x1,%edi
f01020d8:	eb 03                	jmp    f01020dd <check_page_free_list+0x343>
		else
			++nfree_extmem;
f01020da:	83 c6 01             	add    $0x1,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link){
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);
	}
	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f01020dd:	8b 12                	mov    (%edx),%edx
f01020df:	85 d2                	test   %edx,%edx
f01020e1:	0f 85 1e fe ff ff    	jne    f0101f05 <check_page_free_list+0x16b>
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f01020e7:	85 ff                	test   %edi,%edi
f01020e9:	7f 24                	jg     f010210f <check_page_free_list+0x375>
f01020eb:	c7 44 24 0c 16 96 10 	movl   $0xf0109616,0xc(%esp)
f01020f2:	f0 
f01020f3:	c7 44 24 08 8c 95 10 	movl   $0xf010958c,0x8(%esp)
f01020fa:	f0 
f01020fb:	c7 44 24 04 80 03 00 	movl   $0x380,0x4(%esp)
f0102102:	00 
f0102103:	c7 04 24 66 95 10 f0 	movl   $0xf0109566,(%esp)
f010210a:	e8 76 df ff ff       	call   f0100085 <_panic>
	assert(nfree_extmem > 0);
f010210f:	85 f6                	test   %esi,%esi
f0102111:	7f 24                	jg     f0102137 <check_page_free_list+0x39d>
f0102113:	c7 44 24 0c 28 96 10 	movl   $0xf0109628,0xc(%esp)
f010211a:	f0 
f010211b:	c7 44 24 08 8c 95 10 	movl   $0xf010958c,0x8(%esp)
f0102122:	f0 
f0102123:	c7 44 24 04 81 03 00 	movl   $0x381,0x4(%esp)
f010212a:	00 
f010212b:	c7 04 24 66 95 10 f0 	movl   $0xf0109566,(%esp)
f0102132:	e8 4e df ff ff       	call   f0100085 <_panic>
        //cprintf("check_page_free_list() succeeded!\n");
}
f0102137:	83 c4 5c             	add    $0x5c,%esp
f010213a:	5b                   	pop    %ebx
f010213b:	5e                   	pop    %esi
f010213c:	5f                   	pop    %edi
f010213d:	5d                   	pop    %ebp
f010213e:	c3                   	ret    

f010213f <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct Page *
page_alloc(int alloc_flags)
{
f010213f:	55                   	push   %ebp
f0102140:	89 e5                	mov    %esp,%ebp
f0102142:	53                   	push   %ebx
f0102143:	83 ec 14             	sub    $0x14,%esp
	// Fill this function in
        struct Page* newPage = NULL;
        if(!page_free_list){
f0102146:	8b 1d 50 32 29 f0    	mov    0xf0293250,%ebx
f010214c:	85 db                	test   %ebx,%ebx
f010214e:	74 65                	je     f01021b5 <page_alloc+0x76>
            return newPage;
        }
        newPage = page_free_list;
        page_free_list = page_free_list->pp_link;
f0102150:	8b 03                	mov    (%ebx),%eax
f0102152:	a3 50 32 29 f0       	mov    %eax,0xf0293250
        if(alloc_flags & ALLOC_ZERO){
f0102157:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f010215b:	74 58                	je     f01021b5 <page_alloc+0x76>


static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f010215d:	89 d8                	mov    %ebx,%eax
f010215f:	2b 05 bc 3e 29 f0    	sub    0xf0293ebc,%eax
f0102165:	c1 f8 03             	sar    $0x3,%eax
f0102168:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010216b:	89 c2                	mov    %eax,%edx
f010216d:	c1 ea 0c             	shr    $0xc,%edx
f0102170:	3b 15 b4 3e 29 f0    	cmp    0xf0293eb4,%edx
f0102176:	72 20                	jb     f0102198 <page_alloc+0x59>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102178:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010217c:	c7 44 24 08 c0 8d 10 	movl   $0xf0108dc0,0x8(%esp)
f0102183:	f0 
f0102184:	c7 44 24 04 59 00 00 	movl   $0x59,0x4(%esp)
f010218b:	00 
f010218c:	c7 04 24 72 95 10 f0 	movl   $0xf0109572,(%esp)
f0102193:	e8 ed de ff ff       	call   f0100085 <_panic>
           char* addr = page2kva(newPage);
           memset(addr,0,PGSIZE);
f0102198:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010219f:	00 
f01021a0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01021a7:	00 
f01021a8:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01021ad:	89 04 24             	mov    %eax,(%esp)
f01021b0:	e8 41 53 00 00       	call   f01074f6 <memset>
        } 
        return newPage;  
}
f01021b5:	89 d8                	mov    %ebx,%eax
f01021b7:	83 c4 14             	add    $0x14,%esp
f01021ba:	5b                   	pop    %ebx
f01021bb:	5d                   	pop    %ebp
f01021bc:	c3                   	ret    

f01021bd <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f01021bd:	55                   	push   %ebp
f01021be:	89 e5                	mov    %esp,%ebp
f01021c0:	83 ec 18             	sub    $0x18,%esp
f01021c3:	89 5d f8             	mov    %ebx,-0x8(%ebp)
f01021c6:	89 75 fc             	mov    %esi,-0x4(%ebp)
	// Fill this function in
        pde_t* pde = NULL;
        physaddr_t pt;    //physical address
        pte_t* vpt = NULL;
        pde = &pgdir[PDX(va)];
f01021c9:	8b 75 0c             	mov    0xc(%ebp),%esi
f01021cc:	89 f3                	mov    %esi,%ebx
f01021ce:	c1 eb 16             	shr    $0x16,%ebx
f01021d1:	c1 e3 02             	shl    $0x2,%ebx
f01021d4:	03 5d 08             	add    0x8(%ebp),%ebx
        if((*pde) & PTE_PS)
f01021d7:	8b 03                	mov    (%ebx),%eax
f01021d9:	84 c0                	test   %al,%al
f01021db:	0f 88 86 00 00 00    	js     f0102267 <pgdir_walk+0xaa>
            return &pgdir[PDX(va)];
        if((!((*pde) & PTE_P)) && create == 0)
f01021e1:	89 c2                	mov    %eax,%edx
f01021e3:	83 e2 01             	and    $0x1,%edx
f01021e6:	75 06                	jne    f01021ee <pgdir_walk+0x31>
f01021e8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f01021ec:	74 74                	je     f0102262 <pgdir_walk+0xa5>
           return NULL;
        else if(!((*pde) & PTE_P)){
f01021ee:	85 d2                	test   %edx,%edx
f01021f0:	75 2c                	jne    f010221e <pgdir_walk+0x61>
           struct Page* page = NULL;
           if(!(page = page_alloc(ALLOC_ZERO)))
f01021f2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01021f9:	e8 41 ff ff ff       	call   f010213f <page_alloc>
f01021fe:	89 c2                	mov    %eax,%edx
f0102200:	85 c0                	test   %eax,%eax
f0102202:	74 5e                	je     f0102262 <pgdir_walk+0xa5>


static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0102204:	2b 05 bc 3e 29 f0    	sub    0xf0293ebc,%eax
f010220a:	c1 f8 03             	sar    $0x3,%eax
f010220d:	c1 e0 0c             	shl    $0xc,%eax
              return NULL;
           pt = page2pa(page);     
           *pde = pt | PTE_P | PTE_W | PTE_U;
f0102210:	89 c1                	mov    %eax,%ecx
f0102212:	83 c9 07             	or     $0x7,%ecx
f0102215:	89 0b                	mov    %ecx,(%ebx)
           page->pp_ref++;
f0102217:	66 83 42 04 01       	addw   $0x1,0x4(%edx)
f010221c:	eb 05                	jmp    f0102223 <pgdir_walk+0x66>
        }
        else{
          pt = PTE_ADDR(*pde);
f010221e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102223:	89 c2                	mov    %eax,%edx
f0102225:	c1 ea 0c             	shr    $0xc,%edx
f0102228:	3b 15 b4 3e 29 f0    	cmp    0xf0293eb4,%edx
f010222e:	72 20                	jb     f0102250 <pgdir_walk+0x93>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102230:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102234:	c7 44 24 08 c0 8d 10 	movl   $0xf0108dc0,0x8(%esp)
f010223b:	f0 
f010223c:	c7 44 24 04 4a 02 00 	movl   $0x24a,0x4(%esp)
f0102243:	00 
f0102244:	c7 04 24 66 95 10 f0 	movl   $0xf0109566,(%esp)
f010224b:	e8 35 de ff ff       	call   f0100085 <_panic>
        }
        vpt = (pte_t*)KADDR(pt);          
	return &vpt[PTX(va)];
f0102250:	c1 ee 0a             	shr    $0xa,%esi
f0102253:	81 e6 fc 0f 00 00    	and    $0xffc,%esi
f0102259:	8d 9c 30 00 00 00 f0 	lea    -0x10000000(%eax,%esi,1),%ebx
f0102260:	eb 05                	jmp    f0102267 <pgdir_walk+0xaa>
f0102262:	bb 00 00 00 00       	mov    $0x0,%ebx
}
f0102267:	89 d8                	mov    %ebx,%eax
f0102269:	8b 5d f8             	mov    -0x8(%ebp),%ebx
f010226c:	8b 75 fc             	mov    -0x4(%ebp),%esi
f010226f:	89 ec                	mov    %ebp,%esp
f0102271:	5d                   	pop    %ebp
f0102272:	c3                   	ret    

f0102273 <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f0102273:	55                   	push   %ebp
f0102274:	89 e5                	mov    %esp,%ebp
f0102276:	57                   	push   %edi
f0102277:	56                   	push   %esi
f0102278:	53                   	push   %ebx
f0102279:	83 ec 2c             	sub    $0x2c,%esp
f010227c:	8b 75 08             	mov    0x8(%ebp),%esi
f010227f:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 3: Your code here.
        void* begin = ROUNDDOWN((void*)va,PGSIZE);
f0102282:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102285:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0102288:	89 c3                	mov    %eax,%ebx
f010228a:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
        void* end = ROUNDUP((void*)(va+len),PGSIZE);
f0102290:	03 45 10             	add    0x10(%ebp),%eax
f0102293:	05 ff 0f 00 00       	add    $0xfff,%eax
f0102298:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010229d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        while(begin < end){
f01022a0:	39 c3                	cmp    %eax,%ebx
f01022a2:	73 7e                	jae    f0102322 <user_mem_check+0xaf>
           pte_t* pte = pgdir_walk(env->env_pgdir,begin,0);
f01022a4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01022ab:	00 
f01022ac:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01022b0:	8b 46 64             	mov    0x64(%esi),%eax
f01022b3:	89 04 24             	mov    %eax,(%esp)
f01022b6:	e8 02 ff ff ff       	call   f01021bd <pgdir_walk>
f01022bb:	89 da                	mov    %ebx,%edx
           if((uint32_t)begin >= ULIM){
f01022bd:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f01022c3:	76 21                	jbe    f01022e6 <user_mem_check+0x73>
                if(begin > va)
f01022c5:	39 5d 0c             	cmp    %ebx,0xc(%ebp)
f01022c8:	73 0d                	jae    f01022d7 <user_mem_check+0x64>
                  user_mem_check_addr = (uintptr_t)begin;
f01022ca:	89 1d 58 32 29 f0    	mov    %ebx,0xf0293258
f01022d0:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f01022d5:	eb 50                	jmp    f0102327 <user_mem_check+0xb4>
                else
                  user_mem_check_addr = (uintptr_t)va;
f01022d7:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01022da:	a3 58 32 29 f0       	mov    %eax,0xf0293258
f01022df:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f01022e4:	eb 41                	jmp    f0102327 <user_mem_check+0xb4>
                return -E_FAULT;
           }
           if(!pte || !(*pte & PTE_P) || ((*pte & perm) != perm)){
f01022e6:	85 c0                	test   %eax,%eax
f01022e8:	74 0c                	je     f01022f6 <user_mem_check+0x83>
f01022ea:	8b 00                	mov    (%eax),%eax
f01022ec:	a8 01                	test   $0x1,%al
f01022ee:	74 06                	je     f01022f6 <user_mem_check+0x83>
f01022f0:	21 f8                	and    %edi,%eax
f01022f2:	39 c7                	cmp    %eax,%edi
f01022f4:	74 21                	je     f0102317 <user_mem_check+0xa4>
                if(begin > va)
f01022f6:	39 5d 0c             	cmp    %ebx,0xc(%ebp)
f01022f9:	73 0d                	jae    f0102308 <user_mem_check+0x95>
                  user_mem_check_addr = (uintptr_t)begin;
f01022fb:	89 15 58 32 29 f0    	mov    %edx,0xf0293258
f0102301:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0102306:	eb 1f                	jmp    f0102327 <user_mem_check+0xb4>
                else
                  user_mem_check_addr = (uintptr_t)va;
f0102308:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010230b:	a3 58 32 29 f0       	mov    %eax,0xf0293258
f0102310:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0102315:	eb 10                	jmp    f0102327 <user_mem_check+0xb4>
                return -E_FAULT;
           }
           begin += PGSIZE;
f0102317:	81 c3 00 10 00 00    	add    $0x1000,%ebx
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
	// LAB 3: Your code here.
        void* begin = ROUNDDOWN((void*)va,PGSIZE);
        void* end = ROUNDUP((void*)(va+len),PGSIZE);
        while(begin < end){
f010231d:	39 5d e4             	cmp    %ebx,-0x1c(%ebp)
f0102320:	77 82                	ja     f01022a4 <user_mem_check+0x31>
f0102322:	b8 00 00 00 00       	mov    $0x0,%eax
                return -E_FAULT;
           }
           begin += PGSIZE;
        }
	return 0;
}
f0102327:	83 c4 2c             	add    $0x2c,%esp
f010232a:	5b                   	pop    %ebx
f010232b:	5e                   	pop    %esi
f010232c:	5f                   	pop    %edi
f010232d:	5d                   	pop    %ebp
f010232e:	c3                   	ret    

f010232f <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f010232f:	55                   	push   %ebp
f0102330:	89 e5                	mov    %esp,%ebp
f0102332:	53                   	push   %ebx
f0102333:	83 ec 14             	sub    $0x14,%esp
f0102336:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f0102339:	8b 45 14             	mov    0x14(%ebp),%eax
f010233c:	83 c8 04             	or     $0x4,%eax
f010233f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102343:	8b 45 10             	mov    0x10(%ebp),%eax
f0102346:	89 44 24 08          	mov    %eax,0x8(%esp)
f010234a:	8b 45 0c             	mov    0xc(%ebp),%eax
f010234d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102351:	89 1c 24             	mov    %ebx,(%esp)
f0102354:	e8 1a ff ff ff       	call   f0102273 <user_mem_check>
f0102359:	85 c0                	test   %eax,%eax
f010235b:	79 24                	jns    f0102381 <user_mem_assert+0x52>
		cprintf("[%08x] user_mem_check assertion failure for "
f010235d:	a1 58 32 29 f0       	mov    0xf0293258,%eax
f0102362:	89 44 24 08          	mov    %eax,0x8(%esp)
f0102366:	8b 43 48             	mov    0x48(%ebx),%eax
f0102369:	89 44 24 04          	mov    %eax,0x4(%esp)
f010236d:	c7 04 24 90 99 10 f0 	movl   $0xf0109990,(%esp)
f0102374:	e8 96 28 00 00       	call   f0104c0f <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f0102379:	89 1c 24             	mov    %ebx,(%esp)
f010237c:	e8 37 23 00 00       	call   f01046b8 <env_destroy>
	}
}
f0102381:	83 c4 14             	add    $0x14,%esp
f0102384:	5b                   	pop    %ebx
f0102385:	5d                   	pop    %ebp
f0102386:	c3                   	ret    

f0102387 <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct Page *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f0102387:	55                   	push   %ebp
f0102388:	89 e5                	mov    %esp,%ebp
f010238a:	53                   	push   %ebx
f010238b:	83 ec 14             	sub    $0x14,%esp
f010238e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// Fill this function in
        pte_t* pte = pgdir_walk(pgdir,va,0);
f0102391:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102398:	00 
f0102399:	8b 45 0c             	mov    0xc(%ebp),%eax
f010239c:	89 44 24 04          	mov    %eax,0x4(%esp)
f01023a0:	8b 45 08             	mov    0x8(%ebp),%eax
f01023a3:	89 04 24             	mov    %eax,(%esp)
f01023a6:	e8 12 fe ff ff       	call   f01021bd <pgdir_walk>
        if(pte_store != NULL)
f01023ab:	85 db                	test   %ebx,%ebx
f01023ad:	74 02                	je     f01023b1 <page_lookup+0x2a>
           *pte_store = pte;
f01023af:	89 03                	mov    %eax,(%ebx)
        if(pte == NULL || !((*pte) & PTE_P))
f01023b1:	85 c0                	test   %eax,%eax
f01023b3:	74 38                	je     f01023ed <page_lookup+0x66>
f01023b5:	8b 00                	mov    (%eax),%eax
f01023b7:	a8 01                	test   $0x1,%al
f01023b9:	74 32                	je     f01023ed <page_lookup+0x66>
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01023bb:	c1 e8 0c             	shr    $0xc,%eax
f01023be:	3b 05 b4 3e 29 f0    	cmp    0xf0293eb4,%eax
f01023c4:	72 1c                	jb     f01023e2 <page_lookup+0x5b>
		panic("pa2page called with invalid pa");
f01023c6:	c7 44 24 08 c8 99 10 	movl   $0xf01099c8,0x8(%esp)
f01023cd:	f0 
f01023ce:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f01023d5:	00 
f01023d6:	c7 04 24 72 95 10 f0 	movl   $0xf0109572,(%esp)
f01023dd:	e8 a3 dc ff ff       	call   f0100085 <_panic>
	return &pages[PGNUM(pa)];
f01023e2:	c1 e0 03             	shl    $0x3,%eax
f01023e5:	03 05 bc 3e 29 f0    	add    0xf0293ebc,%eax
	   return NULL;
        else
           return pa2page(PTE_ADDR(*pte));
f01023eb:	eb 05                	jmp    f01023f2 <page_lookup+0x6b>
f01023ed:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01023f2:	83 c4 14             	add    $0x14,%esp
f01023f5:	5b                   	pop    %ebx
f01023f6:	5d                   	pop    %ebp
f01023f7:	c3                   	ret    

f01023f8 <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f01023f8:	55                   	push   %ebp
f01023f9:	89 e5                	mov    %esp,%ebp
f01023fb:	83 ec 28             	sub    $0x28,%esp
f01023fe:	89 5d f8             	mov    %ebx,-0x8(%ebp)
f0102401:	89 75 fc             	mov    %esi,-0x4(%ebp)
f0102404:	8b 75 08             	mov    0x8(%ebp),%esi
f0102407:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Fill this function in
        pte_t* pte = NULL;
f010240a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
        pte_t** pte_store = &pte;
        struct Page* page = page_lookup(pgdir,va,pte_store);
f0102411:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0102414:	89 44 24 08          	mov    %eax,0x8(%esp)
f0102418:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010241c:	89 34 24             	mov    %esi,(%esp)
f010241f:	e8 63 ff ff ff       	call   f0102387 <page_lookup>
        if(page == NULL)
f0102424:	85 c0                	test   %eax,%eax
f0102426:	74 21                	je     f0102449 <page_remove+0x51>
           return;
        page_decref(page);
f0102428:	89 04 24             	mov    %eax,(%esp)
f010242b:	e8 d4 f2 ff ff       	call   f0101704 <page_decref>
        if(pte != NULL)
f0102430:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102433:	85 c0                	test   %eax,%eax
f0102435:	74 06                	je     f010243d <page_remove+0x45>
           *pte = 0;
f0102437:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
        tlb_invalidate(pgdir,va);
f010243d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102441:	89 34 24             	mov    %esi,(%esp)
f0102444:	e8 e3 f4 ff ff       	call   f010192c <tlb_invalidate>
}
f0102449:	8b 5d f8             	mov    -0x8(%ebp),%ebx
f010244c:	8b 75 fc             	mov    -0x4(%ebp),%esi
f010244f:	89 ec                	mov    %ebp,%esp
f0102451:	5d                   	pop    %ebp
f0102452:	c3                   	ret    

f0102453 <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct Page *pp, void *va, int perm)
{
f0102453:	55                   	push   %ebp
f0102454:	89 e5                	mov    %esp,%ebp
f0102456:	83 ec 28             	sub    $0x28,%esp
f0102459:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f010245c:	89 75 f8             	mov    %esi,-0x8(%ebp)
f010245f:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0102462:	8b 75 0c             	mov    0xc(%ebp),%esi
f0102465:	8b 7d 10             	mov    0x10(%ebp),%edi
	// Fill this function in
        pte_t* pte = pgdir_walk(pgdir,va,1);
f0102468:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f010246f:	00 
f0102470:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0102474:	8b 45 08             	mov    0x8(%ebp),%eax
f0102477:	89 04 24             	mov    %eax,(%esp)
f010247a:	e8 3e fd ff ff       	call   f01021bd <pgdir_walk>
f010247f:	89 c3                	mov    %eax,%ebx
        if(pte == NULL)
f0102481:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0102486:	85 db                	test   %ebx,%ebx
f0102488:	74 38                	je     f01024c2 <page_insert+0x6f>
           return -E_NO_MEM;
        pp->pp_ref++;
f010248a:	66 83 46 04 01       	addw   $0x1,0x4(%esi)
        if((*pte) & PTE_P){
f010248f:	f6 03 01             	testb  $0x1,(%ebx)
f0102492:	74 0f                	je     f01024a3 <page_insert+0x50>
           //tlb_invalidate(pgdir,va);
           page_remove(pgdir,va);
f0102494:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0102498:	8b 45 08             	mov    0x8(%ebp),%eax
f010249b:	89 04 24             	mov    %eax,(%esp)
f010249e:	e8 55 ff ff ff       	call   f01023f8 <page_remove>
        }
        *pte = page2pa(pp) | perm | PTE_P;
f01024a3:	8b 55 14             	mov    0x14(%ebp),%edx
f01024a6:	83 ca 01             	or     $0x1,%edx
f01024a9:	2b 35 bc 3e 29 f0    	sub    0xf0293ebc,%esi
f01024af:	c1 fe 03             	sar    $0x3,%esi
f01024b2:	89 f0                	mov    %esi,%eax
f01024b4:	c1 e0 0c             	shl    $0xc,%eax
f01024b7:	89 d6                	mov    %edx,%esi
f01024b9:	09 c6                	or     %eax,%esi
f01024bb:	89 33                	mov    %esi,(%ebx)
f01024bd:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
f01024c2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f01024c5:	8b 75 f8             	mov    -0x8(%ebp),%esi
f01024c8:	8b 7d fc             	mov    -0x4(%ebp),%edi
f01024cb:	89 ec                	mov    %ebp,%esp
f01024cd:	5d                   	pop    %ebp
f01024ce:	c3                   	ret    

f01024cf <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f01024cf:	55                   	push   %ebp
f01024d0:	89 e5                	mov    %esp,%ebp
f01024d2:	57                   	push   %edi
f01024d3:	56                   	push   %esi
f01024d4:	53                   	push   %ebx
f01024d5:	83 ec 2c             	sub    $0x2c,%esp
f01024d8:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01024db:	89 d3                	mov    %edx,%ebx
f01024dd:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f01024e0:	8b 7d 08             	mov    0x8(%ebp),%edi
	// Fill this function in
        int i;
        for(i = 0; i < size; i += PGSIZE){
f01024e3:	85 c9                	test   %ecx,%ecx
f01024e5:	74 49                	je     f0102530 <boot_map_region+0x61>
f01024e7:	be 00 00 00 00       	mov    $0x0,%esi
           pte_t* pte = pgdir_walk(pgdir,(void*)va,1);
           if(pte == NULL)
              return;
           *pte = pa | perm | PTE_P;
f01024ec:	8b 45 0c             	mov    0xc(%ebp),%eax
f01024ef:	83 c8 01             	or     $0x1,%eax
f01024f2:	89 45 dc             	mov    %eax,-0x24(%ebp)
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	// Fill this function in
        int i;
        for(i = 0; i < size; i += PGSIZE){
           pte_t* pte = pgdir_walk(pgdir,(void*)va,1);
f01024f5:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01024fc:	00 
f01024fd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102501:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102504:	89 04 24             	mov    %eax,(%esp)
f0102507:	e8 b1 fc ff ff       	call   f01021bd <pgdir_walk>
           if(pte == NULL)
f010250c:	85 c0                	test   %eax,%eax
f010250e:	74 20                	je     f0102530 <boot_map_region+0x61>
              return;
           *pte = pa | perm | PTE_P;
f0102510:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0102513:	09 fa                	or     %edi,%edx
f0102515:	89 10                	mov    %edx,(%eax)
void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	// Fill this function in
        int i;
        for(i = 0; i < size; i += PGSIZE){
f0102517:	81 c6 00 10 00 00    	add    $0x1000,%esi
f010251d:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
f0102520:	76 0e                	jbe    f0102530 <boot_map_region+0x61>
           pte_t* pte = pgdir_walk(pgdir,(void*)va,1);
           if(pte == NULL)
              return;
           *pte = pa | perm | PTE_P;
           va += PGSIZE;
f0102522:	81 c3 00 10 00 00    	add    $0x1000,%ebx
           pa += PGSIZE;
f0102528:	81 c7 00 10 00 00    	add    $0x1000,%edi
f010252e:	eb c5                	jmp    f01024f5 <boot_map_region+0x26>
        }
}
f0102530:	83 c4 2c             	add    $0x2c,%esp
f0102533:	5b                   	pop    %ebx
f0102534:	5e                   	pop    %esi
f0102535:	5f                   	pop    %edi
f0102536:	5d                   	pop    %ebp
f0102537:	c3                   	ret    

f0102538 <e1000_map_region>:
        }
}

//
void* e1000_map_region(physaddr_t pa,size_t size)
{
f0102538:	55                   	push   %ebp
f0102539:	89 e5                	mov    %esp,%ebp
f010253b:	83 ec 18             	sub    $0x18,%esp
    uintptr_t base = KSTACKTOP;
    size = ROUNDUP(size,PGSIZE);
f010253e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0102541:	81 c1 ff 0f 00 00    	add    $0xfff,%ecx
f0102547:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
    if(base + size > KERNBASE){
f010254d:	8d 81 00 00 c0 ef    	lea    -0x10400000(%ecx),%eax
f0102553:	3d 00 00 00 f0       	cmp    $0xf0000000,%eax
f0102558:	76 1c                	jbe    f0102576 <e1000_map_region+0x3e>
       panic("e1000 map out of range");
f010255a:	c7 44 24 08 39 96 10 	movl   $0xf0109639,0x8(%esp)
f0102561:	f0 
f0102562:	c7 44 24 04 8e 02 00 	movl   $0x28e,0x4(%esp)
f0102569:	00 
f010256a:	c7 04 24 66 95 10 f0 	movl   $0xf0109566,(%esp)
f0102571:	e8 0f db ff ff       	call   f0100085 <_panic>
    }
    boot_map_region(kern_pgdir,base,size,pa,PTE_P|PTE_W|PTE_PCD|PTE_PWT);
f0102576:	c7 44 24 04 1b 00 00 	movl   $0x1b,0x4(%esp)
f010257d:	00 
f010257e:	8b 45 08             	mov    0x8(%ebp),%eax
f0102581:	89 04 24             	mov    %eax,(%esp)
f0102584:	ba 00 00 c0 ef       	mov    $0xefc00000,%edx
f0102589:	a1 b8 3e 29 f0       	mov    0xf0293eb8,%eax
f010258e:	e8 3c ff ff ff       	call   f01024cf <boot_map_region>
    return (void*)base;
}
f0102593:	b8 00 00 c0 ef       	mov    $0xefc00000,%eax
f0102598:	c9                   	leave  
f0102599:	c3                   	ret    

f010259a <check_page_installed_pgdir>:
}

// check page_insert, page_remove, &c, with an installed kern_pgdir
static void
check_page_installed_pgdir(void)
{
f010259a:	55                   	push   %ebp
f010259b:	89 e5                	mov    %esp,%ebp
f010259d:	57                   	push   %edi
f010259e:	56                   	push   %esi
f010259f:	53                   	push   %ebx
f01025a0:	83 ec 2c             	sub    $0x2c,%esp
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01025a3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01025aa:	e8 90 fb ff ff       	call   f010213f <page_alloc>
f01025af:	89 c3                	mov    %eax,%ebx
f01025b1:	85 c0                	test   %eax,%eax
f01025b3:	75 24                	jne    f01025d9 <check_page_installed_pgdir+0x3f>
f01025b5:	c7 44 24 0c 50 96 10 	movl   $0xf0109650,0xc(%esp)
f01025bc:	f0 
f01025bd:	c7 44 24 08 8c 95 10 	movl   $0xf010958c,0x8(%esp)
f01025c4:	f0 
f01025c5:	c7 44 24 04 56 05 00 	movl   $0x556,0x4(%esp)
f01025cc:	00 
f01025cd:	c7 04 24 66 95 10 f0 	movl   $0xf0109566,(%esp)
f01025d4:	e8 ac da ff ff       	call   f0100085 <_panic>
	assert((pp1 = page_alloc(0)));
f01025d9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01025e0:	e8 5a fb ff ff       	call   f010213f <page_alloc>
f01025e5:	89 c7                	mov    %eax,%edi
f01025e7:	85 c0                	test   %eax,%eax
f01025e9:	75 24                	jne    f010260f <check_page_installed_pgdir+0x75>
f01025eb:	c7 44 24 0c 66 96 10 	movl   $0xf0109666,0xc(%esp)
f01025f2:	f0 
f01025f3:	c7 44 24 08 8c 95 10 	movl   $0xf010958c,0x8(%esp)
f01025fa:	f0 
f01025fb:	c7 44 24 04 57 05 00 	movl   $0x557,0x4(%esp)
f0102602:	00 
f0102603:	c7 04 24 66 95 10 f0 	movl   $0xf0109566,(%esp)
f010260a:	e8 76 da ff ff       	call   f0100085 <_panic>
	assert((pp2 = page_alloc(0)));
f010260f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102616:	e8 24 fb ff ff       	call   f010213f <page_alloc>
f010261b:	89 c6                	mov    %eax,%esi
f010261d:	85 c0                	test   %eax,%eax
f010261f:	75 24                	jne    f0102645 <check_page_installed_pgdir+0xab>
f0102621:	c7 44 24 0c 7c 96 10 	movl   $0xf010967c,0xc(%esp)
f0102628:	f0 
f0102629:	c7 44 24 08 8c 95 10 	movl   $0xf010958c,0x8(%esp)
f0102630:	f0 
f0102631:	c7 44 24 04 58 05 00 	movl   $0x558,0x4(%esp)
f0102638:	00 
f0102639:	c7 04 24 66 95 10 f0 	movl   $0xf0109566,(%esp)
f0102640:	e8 40 da ff ff       	call   f0100085 <_panic>
	page_free(pp0);
f0102645:	89 1c 24             	mov    %ebx,(%esp)
f0102648:	e8 a2 f0 ff ff       	call   f01016ef <page_free>


static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f010264d:	89 f8                	mov    %edi,%eax
f010264f:	2b 05 bc 3e 29 f0    	sub    0xf0293ebc,%eax
f0102655:	c1 f8 03             	sar    $0x3,%eax
f0102658:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010265b:	89 c2                	mov    %eax,%edx
f010265d:	c1 ea 0c             	shr    $0xc,%edx
f0102660:	3b 15 b4 3e 29 f0    	cmp    0xf0293eb4,%edx
f0102666:	72 20                	jb     f0102688 <check_page_installed_pgdir+0xee>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102668:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010266c:	c7 44 24 08 c0 8d 10 	movl   $0xf0108dc0,0x8(%esp)
f0102673:	f0 
f0102674:	c7 44 24 04 59 00 00 	movl   $0x59,0x4(%esp)
f010267b:	00 
f010267c:	c7 04 24 72 95 10 f0 	movl   $0xf0109572,(%esp)
f0102683:	e8 fd d9 ff ff       	call   f0100085 <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f0102688:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010268f:	00 
f0102690:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f0102697:	00 
f0102698:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010269d:	89 04 24             	mov    %eax,(%esp)
f01026a0:	e8 51 4e 00 00       	call   f01074f6 <memset>


static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f01026a5:	89 75 e4             	mov    %esi,-0x1c(%ebp)
f01026a8:	89 f0                	mov    %esi,%eax
f01026aa:	2b 05 bc 3e 29 f0    	sub    0xf0293ebc,%eax
f01026b0:	c1 f8 03             	sar    $0x3,%eax
f01026b3:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01026b6:	89 c2                	mov    %eax,%edx
f01026b8:	c1 ea 0c             	shr    $0xc,%edx
f01026bb:	3b 15 b4 3e 29 f0    	cmp    0xf0293eb4,%edx
f01026c1:	72 20                	jb     f01026e3 <check_page_installed_pgdir+0x149>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01026c3:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01026c7:	c7 44 24 08 c0 8d 10 	movl   $0xf0108dc0,0x8(%esp)
f01026ce:	f0 
f01026cf:	c7 44 24 04 59 00 00 	movl   $0x59,0x4(%esp)
f01026d6:	00 
f01026d7:	c7 04 24 72 95 10 f0 	movl   $0xf0109572,(%esp)
f01026de:	e8 a2 d9 ff ff       	call   f0100085 <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f01026e3:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01026ea:	00 
f01026eb:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f01026f2:	00 
f01026f3:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01026f8:	89 04 24             	mov    %eax,(%esp)
f01026fb:	e8 f6 4d 00 00       	call   f01074f6 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102700:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102707:	00 
f0102708:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010270f:	00 
f0102710:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0102714:	a1 b8 3e 29 f0       	mov    0xf0293eb8,%eax
f0102719:	89 04 24             	mov    %eax,(%esp)
f010271c:	e8 32 fd ff ff       	call   f0102453 <page_insert>
	assert(pp1->pp_ref == 1);
f0102721:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102726:	74 24                	je     f010274c <check_page_installed_pgdir+0x1b2>
f0102728:	c7 44 24 0c 92 96 10 	movl   $0xf0109692,0xc(%esp)
f010272f:	f0 
f0102730:	c7 44 24 08 8c 95 10 	movl   $0xf010958c,0x8(%esp)
f0102737:	f0 
f0102738:	c7 44 24 04 5d 05 00 	movl   $0x55d,0x4(%esp)
f010273f:	00 
f0102740:	c7 04 24 66 95 10 f0 	movl   $0xf0109566,(%esp)
f0102747:	e8 39 d9 ff ff       	call   f0100085 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f010274c:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102753:	01 01 01 
f0102756:	74 24                	je     f010277c <check_page_installed_pgdir+0x1e2>
f0102758:	c7 44 24 0c e8 99 10 	movl   $0xf01099e8,0xc(%esp)
f010275f:	f0 
f0102760:	c7 44 24 08 8c 95 10 	movl   $0xf010958c,0x8(%esp)
f0102767:	f0 
f0102768:	c7 44 24 04 5e 05 00 	movl   $0x55e,0x4(%esp)
f010276f:	00 
f0102770:	c7 04 24 66 95 10 f0 	movl   $0xf0109566,(%esp)
f0102777:	e8 09 d9 ff ff       	call   f0100085 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f010277c:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102783:	00 
f0102784:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010278b:	00 
f010278c:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102790:	a1 b8 3e 29 f0       	mov    0xf0293eb8,%eax
f0102795:	89 04 24             	mov    %eax,(%esp)
f0102798:	e8 b6 fc ff ff       	call   f0102453 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f010279d:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f01027a4:	02 02 02 
f01027a7:	74 24                	je     f01027cd <check_page_installed_pgdir+0x233>
f01027a9:	c7 44 24 0c 0c 9a 10 	movl   $0xf0109a0c,0xc(%esp)
f01027b0:	f0 
f01027b1:	c7 44 24 08 8c 95 10 	movl   $0xf010958c,0x8(%esp)
f01027b8:	f0 
f01027b9:	c7 44 24 04 60 05 00 	movl   $0x560,0x4(%esp)
f01027c0:	00 
f01027c1:	c7 04 24 66 95 10 f0 	movl   $0xf0109566,(%esp)
f01027c8:	e8 b8 d8 ff ff       	call   f0100085 <_panic>
	assert(pp2->pp_ref == 1);
f01027cd:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01027d2:	74 24                	je     f01027f8 <check_page_installed_pgdir+0x25e>
f01027d4:	c7 44 24 0c a3 96 10 	movl   $0xf01096a3,0xc(%esp)
f01027db:	f0 
f01027dc:	c7 44 24 08 8c 95 10 	movl   $0xf010958c,0x8(%esp)
f01027e3:	f0 
f01027e4:	c7 44 24 04 61 05 00 	movl   $0x561,0x4(%esp)
f01027eb:	00 
f01027ec:	c7 04 24 66 95 10 f0 	movl   $0xf0109566,(%esp)
f01027f3:	e8 8d d8 ff ff       	call   f0100085 <_panic>
	assert(pp1->pp_ref == 0);
f01027f8:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f01027fd:	74 24                	je     f0102823 <check_page_installed_pgdir+0x289>
f01027ff:	c7 44 24 0c b4 96 10 	movl   $0xf01096b4,0xc(%esp)
f0102806:	f0 
f0102807:	c7 44 24 08 8c 95 10 	movl   $0xf010958c,0x8(%esp)
f010280e:	f0 
f010280f:	c7 44 24 04 62 05 00 	movl   $0x562,0x4(%esp)
f0102816:	00 
f0102817:	c7 04 24 66 95 10 f0 	movl   $0xf0109566,(%esp)
f010281e:	e8 62 d8 ff ff       	call   f0100085 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102823:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f010282a:	03 03 03 


static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f010282d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102830:	2b 05 bc 3e 29 f0    	sub    0xf0293ebc,%eax
f0102836:	c1 f8 03             	sar    $0x3,%eax
f0102839:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010283c:	89 c2                	mov    %eax,%edx
f010283e:	c1 ea 0c             	shr    $0xc,%edx
f0102841:	3b 15 b4 3e 29 f0    	cmp    0xf0293eb4,%edx
f0102847:	72 20                	jb     f0102869 <check_page_installed_pgdir+0x2cf>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102849:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010284d:	c7 44 24 08 c0 8d 10 	movl   $0xf0108dc0,0x8(%esp)
f0102854:	f0 
f0102855:	c7 44 24 04 59 00 00 	movl   $0x59,0x4(%esp)
f010285c:	00 
f010285d:	c7 04 24 72 95 10 f0 	movl   $0xf0109572,(%esp)
f0102864:	e8 1c d8 ff ff       	call   f0100085 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102869:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0102870:	03 03 03 
f0102873:	74 24                	je     f0102899 <check_page_installed_pgdir+0x2ff>
f0102875:	c7 44 24 0c 30 9a 10 	movl   $0xf0109a30,0xc(%esp)
f010287c:	f0 
f010287d:	c7 44 24 08 8c 95 10 	movl   $0xf010958c,0x8(%esp)
f0102884:	f0 
f0102885:	c7 44 24 04 64 05 00 	movl   $0x564,0x4(%esp)
f010288c:	00 
f010288d:	c7 04 24 66 95 10 f0 	movl   $0xf0109566,(%esp)
f0102894:	e8 ec d7 ff ff       	call   f0100085 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102899:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01028a0:	00 
f01028a1:	a1 b8 3e 29 f0       	mov    0xf0293eb8,%eax
f01028a6:	89 04 24             	mov    %eax,(%esp)
f01028a9:	e8 4a fb ff ff       	call   f01023f8 <page_remove>
	assert(pp2->pp_ref == 0);
f01028ae:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f01028b3:	74 24                	je     f01028d9 <check_page_installed_pgdir+0x33f>
f01028b5:	c7 44 24 0c c5 96 10 	movl   $0xf01096c5,0xc(%esp)
f01028bc:	f0 
f01028bd:	c7 44 24 08 8c 95 10 	movl   $0xf010958c,0x8(%esp)
f01028c4:	f0 
f01028c5:	c7 44 24 04 66 05 00 	movl   $0x566,0x4(%esp)
f01028cc:	00 
f01028cd:	c7 04 24 66 95 10 f0 	movl   $0xf0109566,(%esp)
f01028d4:	e8 ac d7 ff ff       	call   f0100085 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01028d9:	a1 b8 3e 29 f0       	mov    0xf0293eb8,%eax
f01028de:	8b 08                	mov    (%eax),%ecx
f01028e0:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f01028e6:	89 da                	mov    %ebx,%edx
f01028e8:	2b 15 bc 3e 29 f0    	sub    0xf0293ebc,%edx
f01028ee:	c1 fa 03             	sar    $0x3,%edx
f01028f1:	c1 e2 0c             	shl    $0xc,%edx
f01028f4:	39 d1                	cmp    %edx,%ecx
f01028f6:	74 24                	je     f010291c <check_page_installed_pgdir+0x382>
f01028f8:	c7 44 24 0c 5c 9a 10 	movl   $0xf0109a5c,0xc(%esp)
f01028ff:	f0 
f0102900:	c7 44 24 08 8c 95 10 	movl   $0xf010958c,0x8(%esp)
f0102907:	f0 
f0102908:	c7 44 24 04 69 05 00 	movl   $0x569,0x4(%esp)
f010290f:	00 
f0102910:	c7 04 24 66 95 10 f0 	movl   $0xf0109566,(%esp)
f0102917:	e8 69 d7 ff ff       	call   f0100085 <_panic>
	kern_pgdir[0] = 0;
f010291c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f0102922:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102927:	74 24                	je     f010294d <check_page_installed_pgdir+0x3b3>
f0102929:	c7 44 24 0c d6 96 10 	movl   $0xf01096d6,0xc(%esp)
f0102930:	f0 
f0102931:	c7 44 24 08 8c 95 10 	movl   $0xf010958c,0x8(%esp)
f0102938:	f0 
f0102939:	c7 44 24 04 6b 05 00 	movl   $0x56b,0x4(%esp)
f0102940:	00 
f0102941:	c7 04 24 66 95 10 f0 	movl   $0xf0109566,(%esp)
f0102948:	e8 38 d7 ff ff       	call   f0100085 <_panic>
	pp0->pp_ref = 0;
f010294d:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f0102953:	89 1c 24             	mov    %ebx,(%esp)
f0102956:	e8 94 ed ff ff       	call   f01016ef <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f010295b:	c7 04 24 84 9a 10 f0 	movl   $0xf0109a84,(%esp)
f0102962:	e8 a8 22 00 00       	call   f0104c0f <cprintf>
}
f0102967:	83 c4 2c             	add    $0x2c,%esp
f010296a:	5b                   	pop    %ebx
f010296b:	5e                   	pop    %esi
f010296c:	5f                   	pop    %edi
f010296d:	5d                   	pop    %ebp
f010296e:	c3                   	ret    

f010296f <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f010296f:	55                   	push   %ebp
f0102970:	89 e5                	mov    %esp,%ebp
f0102972:	57                   	push   %edi
f0102973:	56                   	push   %esi
f0102974:	53                   	push   %ebx
f0102975:	83 ec 3c             	sub    $0x3c,%esp
	uint32_t cr0;
	size_t n;

	// Find out how much memory the machine has (npages & npages_basemem).
	i386_detect_memory();
f0102978:	e8 16 f0 ff ff       	call   f0101993 <i386_detect_memory>
	// Remove this line when you're ready to test this function.
	//panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f010297d:	b8 00 10 00 00       	mov    $0x1000,%eax
f0102982:	e8 dd ed ff ff       	call   f0101764 <boot_alloc>
f0102987:	a3 b8 3e 29 f0       	mov    %eax,0xf0293eb8
	memset(kern_pgdir, 0, PGSIZE);
f010298c:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102993:	00 
f0102994:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010299b:	00 
f010299c:	89 04 24             	mov    %eax,(%esp)
f010299f:	e8 52 4b 00 00       	call   f01074f6 <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following two lines.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f01029a4:	a1 b8 3e 29 f0       	mov    0xf0293eb8,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01029a9:	89 c2                	mov    %eax,%edx
f01029ab:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01029b0:	77 20                	ja     f01029d2 <mem_init+0x63>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01029b2:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01029b6:	c7 44 24 08 9c 8d 10 	movl   $0xf0108d9c,0x8(%esp)
f01029bd:	f0 
f01029be:	c7 44 24 04 98 00 00 	movl   $0x98,0x4(%esp)
f01029c5:	00 
f01029c6:	c7 04 24 66 95 10 f0 	movl   $0xf0109566,(%esp)
f01029cd:	e8 b3 d6 ff ff       	call   f0100085 <_panic>
f01029d2:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f01029d8:	83 ca 05             	or     $0x5,%edx
f01029db:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate an array of npages 'struct Page's and store it in 'pages'.
	// The kernel uses this array to keep track of physical pages: for
	// each physical page, there is a corresponding struct Page in this
	// array.  'npages' is the number of physical pages in memory.
	// Your code goes here:
        pages = (struct Page*)boot_alloc(npages*sizeof(struct Page));
f01029e1:	a1 b4 3e 29 f0       	mov    0xf0293eb4,%eax
f01029e6:	c1 e0 03             	shl    $0x3,%eax
f01029e9:	e8 76 ed ff ff       	call   f0101764 <boot_alloc>
f01029ee:	a3 bc 3e 29 f0       	mov    %eax,0xf0293ebc
        //cprintf("sizeofPage: %d\n",sizeof(struct Page));
        memset(pages,0,npages*sizeof(struct Page));
f01029f3:	8b 15 b4 3e 29 f0    	mov    0xf0293eb4,%edx
f01029f9:	c1 e2 03             	shl    $0x3,%edx
f01029fc:	89 54 24 08          	mov    %edx,0x8(%esp)
f0102a00:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102a07:	00 
f0102a08:	89 04 24             	mov    %eax,(%esp)
f0102a0b:	e8 e6 4a 00 00       	call   f01074f6 <memset>

	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.

        envs = (struct Env*)boot_alloc(NENV*sizeof(struct Env));
f0102a10:	b8 00 10 02 00       	mov    $0x21000,%eax
f0102a15:	e8 4a ed ff ff       	call   f0101764 <boot_alloc>
f0102a1a:	a3 5c 32 29 f0       	mov    %eax,0xf029325c
        memset(envs,0,NENV*sizeof(struct Env));
f0102a1f:	c7 44 24 08 00 10 02 	movl   $0x21000,0x8(%esp)
f0102a26:	00 
f0102a27:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102a2e:	00 
f0102a2f:	89 04 24             	mov    %eax,(%esp)
f0102a32:	e8 bf 4a 00 00       	call   f01074f6 <memset>
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f0102a37:	e8 8b ed ff ff       	call   f01017c7 <page_init>

	check_page_free_list(1);
f0102a3c:	b8 01 00 00 00       	mov    $0x1,%eax
f0102a41:	e8 54 f3 ff ff       	call   f0101d9a <check_page_free_list>
	int nfree;
	struct Page *fl;
	char *c;
	int i;

	if (!pages)
f0102a46:	83 3d bc 3e 29 f0 00 	cmpl   $0x0,0xf0293ebc
f0102a4d:	75 1c                	jne    f0102a6b <mem_init+0xfc>
		panic("'pages' is a null pointer!");
f0102a4f:	c7 44 24 08 e7 96 10 	movl   $0xf01096e7,0x8(%esp)
f0102a56:	f0 
f0102a57:	c7 44 24 04 93 03 00 	movl   $0x393,0x4(%esp)
f0102a5e:	00 
f0102a5f:	c7 04 24 66 95 10 f0 	movl   $0xf0109566,(%esp)
f0102a66:	e8 1a d6 ff ff       	call   f0100085 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0102a6b:	a1 50 32 29 f0       	mov    0xf0293250,%eax
f0102a70:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102a75:	85 c0                	test   %eax,%eax
f0102a77:	74 09                	je     f0102a82 <mem_init+0x113>
		++nfree;
f0102a79:	83 c3 01             	add    $0x1,%ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0102a7c:	8b 00                	mov    (%eax),%eax
f0102a7e:	85 c0                	test   %eax,%eax
f0102a80:	75 f7                	jne    f0102a79 <mem_init+0x10a>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102a82:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102a89:	e8 b1 f6 ff ff       	call   f010213f <page_alloc>
f0102a8e:	89 c6                	mov    %eax,%esi
f0102a90:	85 c0                	test   %eax,%eax
f0102a92:	75 24                	jne    f0102ab8 <mem_init+0x149>
f0102a94:	c7 44 24 0c 50 96 10 	movl   $0xf0109650,0xc(%esp)
f0102a9b:	f0 
f0102a9c:	c7 44 24 08 8c 95 10 	movl   $0xf010958c,0x8(%esp)
f0102aa3:	f0 
f0102aa4:	c7 44 24 04 9b 03 00 	movl   $0x39b,0x4(%esp)
f0102aab:	00 
f0102aac:	c7 04 24 66 95 10 f0 	movl   $0xf0109566,(%esp)
f0102ab3:	e8 cd d5 ff ff       	call   f0100085 <_panic>
	assert((pp1 = page_alloc(0)));
f0102ab8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102abf:	e8 7b f6 ff ff       	call   f010213f <page_alloc>
f0102ac4:	89 c7                	mov    %eax,%edi
f0102ac6:	85 c0                	test   %eax,%eax
f0102ac8:	75 24                	jne    f0102aee <mem_init+0x17f>
f0102aca:	c7 44 24 0c 66 96 10 	movl   $0xf0109666,0xc(%esp)
f0102ad1:	f0 
f0102ad2:	c7 44 24 08 8c 95 10 	movl   $0xf010958c,0x8(%esp)
f0102ad9:	f0 
f0102ada:	c7 44 24 04 9c 03 00 	movl   $0x39c,0x4(%esp)
f0102ae1:	00 
f0102ae2:	c7 04 24 66 95 10 f0 	movl   $0xf0109566,(%esp)
f0102ae9:	e8 97 d5 ff ff       	call   f0100085 <_panic>
	assert((pp2 = page_alloc(0)));
f0102aee:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102af5:	e8 45 f6 ff ff       	call   f010213f <page_alloc>
f0102afa:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102afd:	85 c0                	test   %eax,%eax
f0102aff:	75 24                	jne    f0102b25 <mem_init+0x1b6>
f0102b01:	c7 44 24 0c 7c 96 10 	movl   $0xf010967c,0xc(%esp)
f0102b08:	f0 
f0102b09:	c7 44 24 08 8c 95 10 	movl   $0xf010958c,0x8(%esp)
f0102b10:	f0 
f0102b11:	c7 44 24 04 9d 03 00 	movl   $0x39d,0x4(%esp)
f0102b18:	00 
f0102b19:	c7 04 24 66 95 10 f0 	movl   $0xf0109566,(%esp)
f0102b20:	e8 60 d5 ff ff       	call   f0100085 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0102b25:	39 fe                	cmp    %edi,%esi
f0102b27:	75 24                	jne    f0102b4d <mem_init+0x1de>
f0102b29:	c7 44 24 0c 02 97 10 	movl   $0xf0109702,0xc(%esp)
f0102b30:	f0 
f0102b31:	c7 44 24 08 8c 95 10 	movl   $0xf010958c,0x8(%esp)
f0102b38:	f0 
f0102b39:	c7 44 24 04 a0 03 00 	movl   $0x3a0,0x4(%esp)
f0102b40:	00 
f0102b41:	c7 04 24 66 95 10 f0 	movl   $0xf0109566,(%esp)
f0102b48:	e8 38 d5 ff ff       	call   f0100085 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0102b4d:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f0102b50:	74 05                	je     f0102b57 <mem_init+0x1e8>
f0102b52:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f0102b55:	75 24                	jne    f0102b7b <mem_init+0x20c>
f0102b57:	c7 44 24 0c b0 9a 10 	movl   $0xf0109ab0,0xc(%esp)
f0102b5e:	f0 
f0102b5f:	c7 44 24 08 8c 95 10 	movl   $0xf010958c,0x8(%esp)
f0102b66:	f0 
f0102b67:	c7 44 24 04 a1 03 00 	movl   $0x3a1,0x4(%esp)
f0102b6e:	00 
f0102b6f:	c7 04 24 66 95 10 f0 	movl   $0xf0109566,(%esp)
f0102b76:	e8 0a d5 ff ff       	call   f0100085 <_panic>


static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0102b7b:	8b 15 bc 3e 29 f0    	mov    0xf0293ebc,%edx
	assert(page2pa(pp0) < npages*PGSIZE);
f0102b81:	a1 b4 3e 29 f0       	mov    0xf0293eb4,%eax
f0102b86:	c1 e0 0c             	shl    $0xc,%eax
f0102b89:	89 f1                	mov    %esi,%ecx
f0102b8b:	29 d1                	sub    %edx,%ecx
f0102b8d:	c1 f9 03             	sar    $0x3,%ecx
f0102b90:	c1 e1 0c             	shl    $0xc,%ecx
f0102b93:	39 c1                	cmp    %eax,%ecx
f0102b95:	72 24                	jb     f0102bbb <mem_init+0x24c>
f0102b97:	c7 44 24 0c 14 97 10 	movl   $0xf0109714,0xc(%esp)
f0102b9e:	f0 
f0102b9f:	c7 44 24 08 8c 95 10 	movl   $0xf010958c,0x8(%esp)
f0102ba6:	f0 
f0102ba7:	c7 44 24 04 a2 03 00 	movl   $0x3a2,0x4(%esp)
f0102bae:	00 
f0102baf:	c7 04 24 66 95 10 f0 	movl   $0xf0109566,(%esp)
f0102bb6:	e8 ca d4 ff ff       	call   f0100085 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f0102bbb:	89 f9                	mov    %edi,%ecx
f0102bbd:	29 d1                	sub    %edx,%ecx
f0102bbf:	c1 f9 03             	sar    $0x3,%ecx
f0102bc2:	c1 e1 0c             	shl    $0xc,%ecx
f0102bc5:	39 c8                	cmp    %ecx,%eax
f0102bc7:	77 24                	ja     f0102bed <mem_init+0x27e>
f0102bc9:	c7 44 24 0c 31 97 10 	movl   $0xf0109731,0xc(%esp)
f0102bd0:	f0 
f0102bd1:	c7 44 24 08 8c 95 10 	movl   $0xf010958c,0x8(%esp)
f0102bd8:	f0 
f0102bd9:	c7 44 24 04 a3 03 00 	movl   $0x3a3,0x4(%esp)
f0102be0:	00 
f0102be1:	c7 04 24 66 95 10 f0 	movl   $0xf0109566,(%esp)
f0102be8:	e8 98 d4 ff ff       	call   f0100085 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f0102bed:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0102bf0:	29 d1                	sub    %edx,%ecx
f0102bf2:	89 ca                	mov    %ecx,%edx
f0102bf4:	c1 fa 03             	sar    $0x3,%edx
f0102bf7:	c1 e2 0c             	shl    $0xc,%edx
f0102bfa:	39 d0                	cmp    %edx,%eax
f0102bfc:	77 24                	ja     f0102c22 <mem_init+0x2b3>
f0102bfe:	c7 44 24 0c 4e 97 10 	movl   $0xf010974e,0xc(%esp)
f0102c05:	f0 
f0102c06:	c7 44 24 08 8c 95 10 	movl   $0xf010958c,0x8(%esp)
f0102c0d:	f0 
f0102c0e:	c7 44 24 04 a4 03 00 	movl   $0x3a4,0x4(%esp)
f0102c15:	00 
f0102c16:	c7 04 24 66 95 10 f0 	movl   $0xf0109566,(%esp)
f0102c1d:	e8 63 d4 ff ff       	call   f0100085 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0102c22:	a1 50 32 29 f0       	mov    0xf0293250,%eax
f0102c27:	89 45 cc             	mov    %eax,-0x34(%ebp)
	page_free_list = 0;
f0102c2a:	c7 05 50 32 29 f0 00 	movl   $0x0,0xf0293250
f0102c31:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0102c34:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102c3b:	e8 ff f4 ff ff       	call   f010213f <page_alloc>
f0102c40:	85 c0                	test   %eax,%eax
f0102c42:	74 24                	je     f0102c68 <mem_init+0x2f9>
f0102c44:	c7 44 24 0c 6b 97 10 	movl   $0xf010976b,0xc(%esp)
f0102c4b:	f0 
f0102c4c:	c7 44 24 08 8c 95 10 	movl   $0xf010958c,0x8(%esp)
f0102c53:	f0 
f0102c54:	c7 44 24 04 ab 03 00 	movl   $0x3ab,0x4(%esp)
f0102c5b:	00 
f0102c5c:	c7 04 24 66 95 10 f0 	movl   $0xf0109566,(%esp)
f0102c63:	e8 1d d4 ff ff       	call   f0100085 <_panic>

	// free and re-allocate?
	page_free(pp0);
f0102c68:	89 34 24             	mov    %esi,(%esp)
f0102c6b:	e8 7f ea ff ff       	call   f01016ef <page_free>
	page_free(pp1);
f0102c70:	89 3c 24             	mov    %edi,(%esp)
f0102c73:	e8 77 ea ff ff       	call   f01016ef <page_free>
	page_free(pp2);
f0102c78:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0102c7b:	89 14 24             	mov    %edx,(%esp)
f0102c7e:	e8 6c ea ff ff       	call   f01016ef <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102c83:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102c8a:	e8 b0 f4 ff ff       	call   f010213f <page_alloc>
f0102c8f:	89 c6                	mov    %eax,%esi
f0102c91:	85 c0                	test   %eax,%eax
f0102c93:	75 24                	jne    f0102cb9 <mem_init+0x34a>
f0102c95:	c7 44 24 0c 50 96 10 	movl   $0xf0109650,0xc(%esp)
f0102c9c:	f0 
f0102c9d:	c7 44 24 08 8c 95 10 	movl   $0xf010958c,0x8(%esp)
f0102ca4:	f0 
f0102ca5:	c7 44 24 04 b2 03 00 	movl   $0x3b2,0x4(%esp)
f0102cac:	00 
f0102cad:	c7 04 24 66 95 10 f0 	movl   $0xf0109566,(%esp)
f0102cb4:	e8 cc d3 ff ff       	call   f0100085 <_panic>
	assert((pp1 = page_alloc(0)));
f0102cb9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102cc0:	e8 7a f4 ff ff       	call   f010213f <page_alloc>
f0102cc5:	89 c7                	mov    %eax,%edi
f0102cc7:	85 c0                	test   %eax,%eax
f0102cc9:	75 24                	jne    f0102cef <mem_init+0x380>
f0102ccb:	c7 44 24 0c 66 96 10 	movl   $0xf0109666,0xc(%esp)
f0102cd2:	f0 
f0102cd3:	c7 44 24 08 8c 95 10 	movl   $0xf010958c,0x8(%esp)
f0102cda:	f0 
f0102cdb:	c7 44 24 04 b3 03 00 	movl   $0x3b3,0x4(%esp)
f0102ce2:	00 
f0102ce3:	c7 04 24 66 95 10 f0 	movl   $0xf0109566,(%esp)
f0102cea:	e8 96 d3 ff ff       	call   f0100085 <_panic>
	assert((pp2 = page_alloc(0)));
f0102cef:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102cf6:	e8 44 f4 ff ff       	call   f010213f <page_alloc>
f0102cfb:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102cfe:	85 c0                	test   %eax,%eax
f0102d00:	75 24                	jne    f0102d26 <mem_init+0x3b7>
f0102d02:	c7 44 24 0c 7c 96 10 	movl   $0xf010967c,0xc(%esp)
f0102d09:	f0 
f0102d0a:	c7 44 24 08 8c 95 10 	movl   $0xf010958c,0x8(%esp)
f0102d11:	f0 
f0102d12:	c7 44 24 04 b4 03 00 	movl   $0x3b4,0x4(%esp)
f0102d19:	00 
f0102d1a:	c7 04 24 66 95 10 f0 	movl   $0xf0109566,(%esp)
f0102d21:	e8 5f d3 ff ff       	call   f0100085 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0102d26:	39 fe                	cmp    %edi,%esi
f0102d28:	75 24                	jne    f0102d4e <mem_init+0x3df>
f0102d2a:	c7 44 24 0c 02 97 10 	movl   $0xf0109702,0xc(%esp)
f0102d31:	f0 
f0102d32:	c7 44 24 08 8c 95 10 	movl   $0xf010958c,0x8(%esp)
f0102d39:	f0 
f0102d3a:	c7 44 24 04 b6 03 00 	movl   $0x3b6,0x4(%esp)
f0102d41:	00 
f0102d42:	c7 04 24 66 95 10 f0 	movl   $0xf0109566,(%esp)
f0102d49:	e8 37 d3 ff ff       	call   f0100085 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0102d4e:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f0102d51:	74 05                	je     f0102d58 <mem_init+0x3e9>
f0102d53:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f0102d56:	75 24                	jne    f0102d7c <mem_init+0x40d>
f0102d58:	c7 44 24 0c b0 9a 10 	movl   $0xf0109ab0,0xc(%esp)
f0102d5f:	f0 
f0102d60:	c7 44 24 08 8c 95 10 	movl   $0xf010958c,0x8(%esp)
f0102d67:	f0 
f0102d68:	c7 44 24 04 b7 03 00 	movl   $0x3b7,0x4(%esp)
f0102d6f:	00 
f0102d70:	c7 04 24 66 95 10 f0 	movl   $0xf0109566,(%esp)
f0102d77:	e8 09 d3 ff ff       	call   f0100085 <_panic>
	assert(!page_alloc(0));
f0102d7c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102d83:	e8 b7 f3 ff ff       	call   f010213f <page_alloc>
f0102d88:	85 c0                	test   %eax,%eax
f0102d8a:	74 24                	je     f0102db0 <mem_init+0x441>
f0102d8c:	c7 44 24 0c 6b 97 10 	movl   $0xf010976b,0xc(%esp)
f0102d93:	f0 
f0102d94:	c7 44 24 08 8c 95 10 	movl   $0xf010958c,0x8(%esp)
f0102d9b:	f0 
f0102d9c:	c7 44 24 04 b8 03 00 	movl   $0x3b8,0x4(%esp)
f0102da3:	00 
f0102da4:	c7 04 24 66 95 10 f0 	movl   $0xf0109566,(%esp)
f0102dab:	e8 d5 d2 ff ff       	call   f0100085 <_panic>
f0102db0:	89 75 d0             	mov    %esi,-0x30(%ebp)
f0102db3:	89 f0                	mov    %esi,%eax
f0102db5:	2b 05 bc 3e 29 f0    	sub    0xf0293ebc,%eax
f0102dbb:	c1 f8 03             	sar    $0x3,%eax
f0102dbe:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102dc1:	89 c2                	mov    %eax,%edx
f0102dc3:	c1 ea 0c             	shr    $0xc,%edx
f0102dc6:	3b 15 b4 3e 29 f0    	cmp    0xf0293eb4,%edx
f0102dcc:	72 20                	jb     f0102dee <mem_init+0x47f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102dce:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102dd2:	c7 44 24 08 c0 8d 10 	movl   $0xf0108dc0,0x8(%esp)
f0102dd9:	f0 
f0102dda:	c7 44 24 04 59 00 00 	movl   $0x59,0x4(%esp)
f0102de1:	00 
f0102de2:	c7 04 24 72 95 10 f0 	movl   $0xf0109572,(%esp)
f0102de9:	e8 97 d2 ff ff       	call   f0100085 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f0102dee:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102df5:	00 
f0102df6:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f0102dfd:	00 
f0102dfe:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102e03:	89 04 24             	mov    %eax,(%esp)
f0102e06:	e8 eb 46 00 00       	call   f01074f6 <memset>
	page_free(pp0);
f0102e0b:	89 34 24             	mov    %esi,(%esp)
f0102e0e:	e8 dc e8 ff ff       	call   f01016ef <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0102e13:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0102e1a:	e8 20 f3 ff ff       	call   f010213f <page_alloc>
f0102e1f:	85 c0                	test   %eax,%eax
f0102e21:	75 24                	jne    f0102e47 <mem_init+0x4d8>
f0102e23:	c7 44 24 0c 7a 97 10 	movl   $0xf010977a,0xc(%esp)
f0102e2a:	f0 
f0102e2b:	c7 44 24 08 8c 95 10 	movl   $0xf010958c,0x8(%esp)
f0102e32:	f0 
f0102e33:	c7 44 24 04 bd 03 00 	movl   $0x3bd,0x4(%esp)
f0102e3a:	00 
f0102e3b:	c7 04 24 66 95 10 f0 	movl   $0xf0109566,(%esp)
f0102e42:	e8 3e d2 ff ff       	call   f0100085 <_panic>
	assert(pp && pp0 == pp);
f0102e47:	39 c6                	cmp    %eax,%esi
f0102e49:	74 24                	je     f0102e6f <mem_init+0x500>
f0102e4b:	c7 44 24 0c 98 97 10 	movl   $0xf0109798,0xc(%esp)
f0102e52:	f0 
f0102e53:	c7 44 24 08 8c 95 10 	movl   $0xf010958c,0x8(%esp)
f0102e5a:	f0 
f0102e5b:	c7 44 24 04 be 03 00 	movl   $0x3be,0x4(%esp)
f0102e62:	00 
f0102e63:	c7 04 24 66 95 10 f0 	movl   $0xf0109566,(%esp)
f0102e6a:	e8 16 d2 ff ff       	call   f0100085 <_panic>


static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0102e6f:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0102e72:	2b 15 bc 3e 29 f0    	sub    0xf0293ebc,%edx
f0102e78:	c1 fa 03             	sar    $0x3,%edx
f0102e7b:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102e7e:	89 d0                	mov    %edx,%eax
f0102e80:	c1 e8 0c             	shr    $0xc,%eax
f0102e83:	3b 05 b4 3e 29 f0    	cmp    0xf0293eb4,%eax
f0102e89:	72 20                	jb     f0102eab <mem_init+0x53c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102e8b:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102e8f:	c7 44 24 08 c0 8d 10 	movl   $0xf0108dc0,0x8(%esp)
f0102e96:	f0 
f0102e97:	c7 44 24 04 59 00 00 	movl   $0x59,0x4(%esp)
f0102e9e:	00 
f0102e9f:	c7 04 24 72 95 10 f0 	movl   $0xf0109572,(%esp)
f0102ea6:	e8 da d1 ff ff       	call   f0100085 <_panic>
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f0102eab:	80 ba 00 00 00 f0 00 	cmpb   $0x0,-0x10000000(%edx)
f0102eb2:	75 11                	jne    f0102ec5 <mem_init+0x556>
f0102eb4:	8d 82 01 00 00 f0    	lea    -0xfffffff(%edx),%eax
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102eba:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f0102ec0:	80 38 00             	cmpb   $0x0,(%eax)
f0102ec3:	74 24                	je     f0102ee9 <mem_init+0x57a>
f0102ec5:	c7 44 24 0c a8 97 10 	movl   $0xf01097a8,0xc(%esp)
f0102ecc:	f0 
f0102ecd:	c7 44 24 08 8c 95 10 	movl   $0xf010958c,0x8(%esp)
f0102ed4:	f0 
f0102ed5:	c7 44 24 04 c1 03 00 	movl   $0x3c1,0x4(%esp)
f0102edc:	00 
f0102edd:	c7 04 24 66 95 10 f0 	movl   $0xf0109566,(%esp)
f0102ee4:	e8 9c d1 ff ff       	call   f0100085 <_panic>
f0102ee9:	83 c0 01             	add    $0x1,%eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f0102eec:	39 d0                	cmp    %edx,%eax
f0102eee:	75 d0                	jne    f0102ec0 <mem_init+0x551>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f0102ef0:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0102ef3:	89 0d 50 32 29 f0    	mov    %ecx,0xf0293250

	// free the pages we took
	page_free(pp0);
f0102ef9:	89 34 24             	mov    %esi,(%esp)
f0102efc:	e8 ee e7 ff ff       	call   f01016ef <page_free>
	page_free(pp1);
f0102f01:	89 3c 24             	mov    %edi,(%esp)
f0102f04:	e8 e6 e7 ff ff       	call   f01016ef <page_free>
	page_free(pp2);
f0102f09:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102f0c:	89 04 24             	mov    %eax,(%esp)
f0102f0f:	e8 db e7 ff ff       	call   f01016ef <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0102f14:	a1 50 32 29 f0       	mov    0xf0293250,%eax
f0102f19:	85 c0                	test   %eax,%eax
f0102f1b:	74 09                	je     f0102f26 <mem_init+0x5b7>
		--nfree;
f0102f1d:	83 eb 01             	sub    $0x1,%ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0102f20:	8b 00                	mov    (%eax),%eax
f0102f22:	85 c0                	test   %eax,%eax
f0102f24:	75 f7                	jne    f0102f1d <mem_init+0x5ae>
		--nfree;
	assert(nfree == 0);
f0102f26:	85 db                	test   %ebx,%ebx
f0102f28:	74 24                	je     f0102f4e <mem_init+0x5df>
f0102f2a:	c7 44 24 0c b2 97 10 	movl   $0xf01097b2,0xc(%esp)
f0102f31:	f0 
f0102f32:	c7 44 24 08 8c 95 10 	movl   $0xf010958c,0x8(%esp)
f0102f39:	f0 
f0102f3a:	c7 44 24 04 ce 03 00 	movl   $0x3ce,0x4(%esp)
f0102f41:	00 
f0102f42:	c7 04 24 66 95 10 f0 	movl   $0xf0109566,(%esp)
f0102f49:	e8 37 d1 ff ff       	call   f0100085 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f0102f4e:	c7 04 24 d0 9a 10 f0 	movl   $0xf0109ad0,(%esp)
f0102f55:	e8 b5 1c 00 00       	call   f0104c0f <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102f5a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102f61:	e8 d9 f1 ff ff       	call   f010213f <page_alloc>
f0102f66:	89 c6                	mov    %eax,%esi
f0102f68:	85 c0                	test   %eax,%eax
f0102f6a:	75 24                	jne    f0102f90 <mem_init+0x621>
f0102f6c:	c7 44 24 0c 50 96 10 	movl   $0xf0109650,0xc(%esp)
f0102f73:	f0 
f0102f74:	c7 44 24 08 8c 95 10 	movl   $0xf010958c,0x8(%esp)
f0102f7b:	f0 
f0102f7c:	c7 44 24 04 5a 04 00 	movl   $0x45a,0x4(%esp)
f0102f83:	00 
f0102f84:	c7 04 24 66 95 10 f0 	movl   $0xf0109566,(%esp)
f0102f8b:	e8 f5 d0 ff ff       	call   f0100085 <_panic>
	assert((pp1 = page_alloc(0)));
f0102f90:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102f97:	e8 a3 f1 ff ff       	call   f010213f <page_alloc>
f0102f9c:	89 c7                	mov    %eax,%edi
f0102f9e:	85 c0                	test   %eax,%eax
f0102fa0:	75 24                	jne    f0102fc6 <mem_init+0x657>
f0102fa2:	c7 44 24 0c 66 96 10 	movl   $0xf0109666,0xc(%esp)
f0102fa9:	f0 
f0102faa:	c7 44 24 08 8c 95 10 	movl   $0xf010958c,0x8(%esp)
f0102fb1:	f0 
f0102fb2:	c7 44 24 04 5b 04 00 	movl   $0x45b,0x4(%esp)
f0102fb9:	00 
f0102fba:	c7 04 24 66 95 10 f0 	movl   $0xf0109566,(%esp)
f0102fc1:	e8 bf d0 ff ff       	call   f0100085 <_panic>
	assert((pp2 = page_alloc(0)));
f0102fc6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102fcd:	e8 6d f1 ff ff       	call   f010213f <page_alloc>
f0102fd2:	89 c3                	mov    %eax,%ebx
f0102fd4:	85 c0                	test   %eax,%eax
f0102fd6:	75 24                	jne    f0102ffc <mem_init+0x68d>
f0102fd8:	c7 44 24 0c 7c 96 10 	movl   $0xf010967c,0xc(%esp)
f0102fdf:	f0 
f0102fe0:	c7 44 24 08 8c 95 10 	movl   $0xf010958c,0x8(%esp)
f0102fe7:	f0 
f0102fe8:	c7 44 24 04 5c 04 00 	movl   $0x45c,0x4(%esp)
f0102fef:	00 
f0102ff0:	c7 04 24 66 95 10 f0 	movl   $0xf0109566,(%esp)
f0102ff7:	e8 89 d0 ff ff       	call   f0100085 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0102ffc:	39 fe                	cmp    %edi,%esi
f0102ffe:	75 24                	jne    f0103024 <mem_init+0x6b5>
f0103000:	c7 44 24 0c 02 97 10 	movl   $0xf0109702,0xc(%esp)
f0103007:	f0 
f0103008:	c7 44 24 08 8c 95 10 	movl   $0xf010958c,0x8(%esp)
f010300f:	f0 
f0103010:	c7 44 24 04 5f 04 00 	movl   $0x45f,0x4(%esp)
f0103017:	00 
f0103018:	c7 04 24 66 95 10 f0 	movl   $0xf0109566,(%esp)
f010301f:	e8 61 d0 ff ff       	call   f0100085 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0103024:	39 c7                	cmp    %eax,%edi
f0103026:	74 04                	je     f010302c <mem_init+0x6bd>
f0103028:	39 c6                	cmp    %eax,%esi
f010302a:	75 24                	jne    f0103050 <mem_init+0x6e1>
f010302c:	c7 44 24 0c b0 9a 10 	movl   $0xf0109ab0,0xc(%esp)
f0103033:	f0 
f0103034:	c7 44 24 08 8c 95 10 	movl   $0xf010958c,0x8(%esp)
f010303b:	f0 
f010303c:	c7 44 24 04 60 04 00 	movl   $0x460,0x4(%esp)
f0103043:	00 
f0103044:	c7 04 24 66 95 10 f0 	movl   $0xf0109566,(%esp)
f010304b:	e8 35 d0 ff ff       	call   f0100085 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0103050:	8b 15 50 32 29 f0    	mov    0xf0293250,%edx
f0103056:	89 55 c8             	mov    %edx,-0x38(%ebp)
	page_free_list = 0;
f0103059:	c7 05 50 32 29 f0 00 	movl   $0x0,0xf0293250
f0103060:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0103063:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010306a:	e8 d0 f0 ff ff       	call   f010213f <page_alloc>
f010306f:	85 c0                	test   %eax,%eax
f0103071:	74 24                	je     f0103097 <mem_init+0x728>
f0103073:	c7 44 24 0c 6b 97 10 	movl   $0xf010976b,0xc(%esp)
f010307a:	f0 
f010307b:	c7 44 24 08 8c 95 10 	movl   $0xf010958c,0x8(%esp)
f0103082:	f0 
f0103083:	c7 44 24 04 67 04 00 	movl   $0x467,0x4(%esp)
f010308a:	00 
f010308b:	c7 04 24 66 95 10 f0 	movl   $0xf0109566,(%esp)
f0103092:	e8 ee cf ff ff       	call   f0100085 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0103097:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010309a:	89 44 24 08          	mov    %eax,0x8(%esp)
f010309e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01030a5:	00 
f01030a6:	a1 b8 3e 29 f0       	mov    0xf0293eb8,%eax
f01030ab:	89 04 24             	mov    %eax,(%esp)
f01030ae:	e8 d4 f2 ff ff       	call   f0102387 <page_lookup>
f01030b3:	85 c0                	test   %eax,%eax
f01030b5:	74 24                	je     f01030db <mem_init+0x76c>
f01030b7:	c7 44 24 0c f0 9a 10 	movl   $0xf0109af0,0xc(%esp)
f01030be:	f0 
f01030bf:	c7 44 24 08 8c 95 10 	movl   $0xf010958c,0x8(%esp)
f01030c6:	f0 
f01030c7:	c7 44 24 04 6a 04 00 	movl   $0x46a,0x4(%esp)
f01030ce:	00 
f01030cf:	c7 04 24 66 95 10 f0 	movl   $0xf0109566,(%esp)
f01030d6:	e8 aa cf ff ff       	call   f0100085 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f01030db:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01030e2:	00 
f01030e3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01030ea:	00 
f01030eb:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01030ef:	a1 b8 3e 29 f0       	mov    0xf0293eb8,%eax
f01030f4:	89 04 24             	mov    %eax,(%esp)
f01030f7:	e8 57 f3 ff ff       	call   f0102453 <page_insert>
f01030fc:	85 c0                	test   %eax,%eax
f01030fe:	78 24                	js     f0103124 <mem_init+0x7b5>
f0103100:	c7 44 24 0c 28 9b 10 	movl   $0xf0109b28,0xc(%esp)
f0103107:	f0 
f0103108:	c7 44 24 08 8c 95 10 	movl   $0xf010958c,0x8(%esp)
f010310f:	f0 
f0103110:	c7 44 24 04 6d 04 00 	movl   $0x46d,0x4(%esp)
f0103117:	00 
f0103118:	c7 04 24 66 95 10 f0 	movl   $0xf0109566,(%esp)
f010311f:	e8 61 cf ff ff       	call   f0100085 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0103124:	89 34 24             	mov    %esi,(%esp)
f0103127:	e8 c3 e5 ff ff       	call   f01016ef <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f010312c:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0103133:	00 
f0103134:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010313b:	00 
f010313c:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103140:	a1 b8 3e 29 f0       	mov    0xf0293eb8,%eax
f0103145:	89 04 24             	mov    %eax,(%esp)
f0103148:	e8 06 f3 ff ff       	call   f0102453 <page_insert>
f010314d:	85 c0                	test   %eax,%eax
f010314f:	74 24                	je     f0103175 <mem_init+0x806>
f0103151:	c7 44 24 0c 58 9b 10 	movl   $0xf0109b58,0xc(%esp)
f0103158:	f0 
f0103159:	c7 44 24 08 8c 95 10 	movl   $0xf010958c,0x8(%esp)
f0103160:	f0 
f0103161:	c7 44 24 04 71 04 00 	movl   $0x471,0x4(%esp)
f0103168:	00 
f0103169:	c7 04 24 66 95 10 f0 	movl   $0xf0109566,(%esp)
f0103170:	e8 10 cf ff ff       	call   f0100085 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0103175:	a1 b8 3e 29 f0       	mov    0xf0293eb8,%eax


static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f010317a:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f010317d:	8b 08                	mov    (%eax),%ecx
f010317f:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0103185:	89 f2                	mov    %esi,%edx
f0103187:	2b 15 bc 3e 29 f0    	sub    0xf0293ebc,%edx
f010318d:	c1 fa 03             	sar    $0x3,%edx
f0103190:	c1 e2 0c             	shl    $0xc,%edx
f0103193:	39 d1                	cmp    %edx,%ecx
f0103195:	74 24                	je     f01031bb <mem_init+0x84c>
f0103197:	c7 44 24 0c 5c 9a 10 	movl   $0xf0109a5c,0xc(%esp)
f010319e:	f0 
f010319f:	c7 44 24 08 8c 95 10 	movl   $0xf010958c,0x8(%esp)
f01031a6:	f0 
f01031a7:	c7 44 24 04 72 04 00 	movl   $0x472,0x4(%esp)
f01031ae:	00 
f01031af:	c7 04 24 66 95 10 f0 	movl   $0xf0109566,(%esp)
f01031b6:	e8 ca ce ff ff       	call   f0100085 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f01031bb:	ba 00 00 00 00       	mov    $0x0,%edx
f01031c0:	e8 6f eb ff ff       	call   f0101d34 <check_va2pa>
f01031c5:	89 7d d0             	mov    %edi,-0x30(%ebp)
f01031c8:	89 fa                	mov    %edi,%edx
f01031ca:	2b 15 bc 3e 29 f0    	sub    0xf0293ebc,%edx
f01031d0:	c1 fa 03             	sar    $0x3,%edx
f01031d3:	c1 e2 0c             	shl    $0xc,%edx
f01031d6:	39 d0                	cmp    %edx,%eax
f01031d8:	74 24                	je     f01031fe <mem_init+0x88f>
f01031da:	c7 44 24 0c 88 9b 10 	movl   $0xf0109b88,0xc(%esp)
f01031e1:	f0 
f01031e2:	c7 44 24 08 8c 95 10 	movl   $0xf010958c,0x8(%esp)
f01031e9:	f0 
f01031ea:	c7 44 24 04 73 04 00 	movl   $0x473,0x4(%esp)
f01031f1:	00 
f01031f2:	c7 04 24 66 95 10 f0 	movl   $0xf0109566,(%esp)
f01031f9:	e8 87 ce ff ff       	call   f0100085 <_panic>
	assert(pp1->pp_ref == 1);
f01031fe:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0103203:	74 24                	je     f0103229 <mem_init+0x8ba>
f0103205:	c7 44 24 0c 92 96 10 	movl   $0xf0109692,0xc(%esp)
f010320c:	f0 
f010320d:	c7 44 24 08 8c 95 10 	movl   $0xf010958c,0x8(%esp)
f0103214:	f0 
f0103215:	c7 44 24 04 74 04 00 	movl   $0x474,0x4(%esp)
f010321c:	00 
f010321d:	c7 04 24 66 95 10 f0 	movl   $0xf0109566,(%esp)
f0103224:	e8 5c ce ff ff       	call   f0100085 <_panic>
	assert(pp0->pp_ref == 1);
f0103229:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f010322e:	74 24                	je     f0103254 <mem_init+0x8e5>
f0103230:	c7 44 24 0c d6 96 10 	movl   $0xf01096d6,0xc(%esp)
f0103237:	f0 
f0103238:	c7 44 24 08 8c 95 10 	movl   $0xf010958c,0x8(%esp)
f010323f:	f0 
f0103240:	c7 44 24 04 75 04 00 	movl   $0x475,0x4(%esp)
f0103247:	00 
f0103248:	c7 04 24 66 95 10 f0 	movl   $0xf0109566,(%esp)
f010324f:	e8 31 ce ff ff       	call   f0100085 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0103254:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f010325b:	00 
f010325c:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103263:	00 
f0103264:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103268:	a1 b8 3e 29 f0       	mov    0xf0293eb8,%eax
f010326d:	89 04 24             	mov    %eax,(%esp)
f0103270:	e8 de f1 ff ff       	call   f0102453 <page_insert>
f0103275:	85 c0                	test   %eax,%eax
f0103277:	74 24                	je     f010329d <mem_init+0x92e>
f0103279:	c7 44 24 0c b8 9b 10 	movl   $0xf0109bb8,0xc(%esp)
f0103280:	f0 
f0103281:	c7 44 24 08 8c 95 10 	movl   $0xf010958c,0x8(%esp)
f0103288:	f0 
f0103289:	c7 44 24 04 78 04 00 	movl   $0x478,0x4(%esp)
f0103290:	00 
f0103291:	c7 04 24 66 95 10 f0 	movl   $0xf0109566,(%esp)
f0103298:	e8 e8 cd ff ff       	call   f0100085 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f010329d:	ba 00 10 00 00       	mov    $0x1000,%edx
f01032a2:	a1 b8 3e 29 f0       	mov    0xf0293eb8,%eax
f01032a7:	e8 88 ea ff ff       	call   f0101d34 <check_va2pa>
f01032ac:	89 5d cc             	mov    %ebx,-0x34(%ebp)
f01032af:	89 da                	mov    %ebx,%edx
f01032b1:	2b 15 bc 3e 29 f0    	sub    0xf0293ebc,%edx
f01032b7:	c1 fa 03             	sar    $0x3,%edx
f01032ba:	c1 e2 0c             	shl    $0xc,%edx
f01032bd:	39 d0                	cmp    %edx,%eax
f01032bf:	74 24                	je     f01032e5 <mem_init+0x976>
f01032c1:	c7 44 24 0c f4 9b 10 	movl   $0xf0109bf4,0xc(%esp)
f01032c8:	f0 
f01032c9:	c7 44 24 08 8c 95 10 	movl   $0xf010958c,0x8(%esp)
f01032d0:	f0 
f01032d1:	c7 44 24 04 79 04 00 	movl   $0x479,0x4(%esp)
f01032d8:	00 
f01032d9:	c7 04 24 66 95 10 f0 	movl   $0xf0109566,(%esp)
f01032e0:	e8 a0 cd ff ff       	call   f0100085 <_panic>
	assert(pp2->pp_ref == 1);
f01032e5:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01032ea:	74 24                	je     f0103310 <mem_init+0x9a1>
f01032ec:	c7 44 24 0c a3 96 10 	movl   $0xf01096a3,0xc(%esp)
f01032f3:	f0 
f01032f4:	c7 44 24 08 8c 95 10 	movl   $0xf010958c,0x8(%esp)
f01032fb:	f0 
f01032fc:	c7 44 24 04 7a 04 00 	movl   $0x47a,0x4(%esp)
f0103303:	00 
f0103304:	c7 04 24 66 95 10 f0 	movl   $0xf0109566,(%esp)
f010330b:	e8 75 cd ff ff       	call   f0100085 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0103310:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103317:	e8 23 ee ff ff       	call   f010213f <page_alloc>
f010331c:	85 c0                	test   %eax,%eax
f010331e:	74 24                	je     f0103344 <mem_init+0x9d5>
f0103320:	c7 44 24 0c 6b 97 10 	movl   $0xf010976b,0xc(%esp)
f0103327:	f0 
f0103328:	c7 44 24 08 8c 95 10 	movl   $0xf010958c,0x8(%esp)
f010332f:	f0 
f0103330:	c7 44 24 04 7d 04 00 	movl   $0x47d,0x4(%esp)
f0103337:	00 
f0103338:	c7 04 24 66 95 10 f0 	movl   $0xf0109566,(%esp)
f010333f:	e8 41 cd ff ff       	call   f0100085 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0103344:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f010334b:	00 
f010334c:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103353:	00 
f0103354:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103358:	a1 b8 3e 29 f0       	mov    0xf0293eb8,%eax
f010335d:	89 04 24             	mov    %eax,(%esp)
f0103360:	e8 ee f0 ff ff       	call   f0102453 <page_insert>
f0103365:	85 c0                	test   %eax,%eax
f0103367:	74 24                	je     f010338d <mem_init+0xa1e>
f0103369:	c7 44 24 0c b8 9b 10 	movl   $0xf0109bb8,0xc(%esp)
f0103370:	f0 
f0103371:	c7 44 24 08 8c 95 10 	movl   $0xf010958c,0x8(%esp)
f0103378:	f0 
f0103379:	c7 44 24 04 80 04 00 	movl   $0x480,0x4(%esp)
f0103380:	00 
f0103381:	c7 04 24 66 95 10 f0 	movl   $0xf0109566,(%esp)
f0103388:	e8 f8 cc ff ff       	call   f0100085 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f010338d:	ba 00 10 00 00       	mov    $0x1000,%edx
f0103392:	a1 b8 3e 29 f0       	mov    0xf0293eb8,%eax
f0103397:	e8 98 e9 ff ff       	call   f0101d34 <check_va2pa>
f010339c:	8b 55 cc             	mov    -0x34(%ebp),%edx
f010339f:	2b 15 bc 3e 29 f0    	sub    0xf0293ebc,%edx
f01033a5:	c1 fa 03             	sar    $0x3,%edx
f01033a8:	c1 e2 0c             	shl    $0xc,%edx
f01033ab:	39 d0                	cmp    %edx,%eax
f01033ad:	74 24                	je     f01033d3 <mem_init+0xa64>
f01033af:	c7 44 24 0c f4 9b 10 	movl   $0xf0109bf4,0xc(%esp)
f01033b6:	f0 
f01033b7:	c7 44 24 08 8c 95 10 	movl   $0xf010958c,0x8(%esp)
f01033be:	f0 
f01033bf:	c7 44 24 04 81 04 00 	movl   $0x481,0x4(%esp)
f01033c6:	00 
f01033c7:	c7 04 24 66 95 10 f0 	movl   $0xf0109566,(%esp)
f01033ce:	e8 b2 cc ff ff       	call   f0100085 <_panic>
	assert(pp2->pp_ref == 1);
f01033d3:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01033d8:	74 24                	je     f01033fe <mem_init+0xa8f>
f01033da:	c7 44 24 0c a3 96 10 	movl   $0xf01096a3,0xc(%esp)
f01033e1:	f0 
f01033e2:	c7 44 24 08 8c 95 10 	movl   $0xf010958c,0x8(%esp)
f01033e9:	f0 
f01033ea:	c7 44 24 04 82 04 00 	movl   $0x482,0x4(%esp)
f01033f1:	00 
f01033f2:	c7 04 24 66 95 10 f0 	movl   $0xf0109566,(%esp)
f01033f9:	e8 87 cc ff ff       	call   f0100085 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f01033fe:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103405:	e8 35 ed ff ff       	call   f010213f <page_alloc>
f010340a:	85 c0                	test   %eax,%eax
f010340c:	74 24                	je     f0103432 <mem_init+0xac3>
f010340e:	c7 44 24 0c 6b 97 10 	movl   $0xf010976b,0xc(%esp)
f0103415:	f0 
f0103416:	c7 44 24 08 8c 95 10 	movl   $0xf010958c,0x8(%esp)
f010341d:	f0 
f010341e:	c7 44 24 04 86 04 00 	movl   $0x486,0x4(%esp)
f0103425:	00 
f0103426:	c7 04 24 66 95 10 f0 	movl   $0xf0109566,(%esp)
f010342d:	e8 53 cc ff ff       	call   f0100085 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0103432:	a1 b8 3e 29 f0       	mov    0xf0293eb8,%eax
f0103437:	8b 00                	mov    (%eax),%eax
f0103439:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010343e:	89 c2                	mov    %eax,%edx
f0103440:	c1 ea 0c             	shr    $0xc,%edx
f0103443:	3b 15 b4 3e 29 f0    	cmp    0xf0293eb4,%edx
f0103449:	72 20                	jb     f010346b <mem_init+0xafc>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010344b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010344f:	c7 44 24 08 c0 8d 10 	movl   $0xf0108dc0,0x8(%esp)
f0103456:	f0 
f0103457:	c7 44 24 04 89 04 00 	movl   $0x489,0x4(%esp)
f010345e:	00 
f010345f:	c7 04 24 66 95 10 f0 	movl   $0xf0109566,(%esp)
f0103466:	e8 1a cc ff ff       	call   f0100085 <_panic>
f010346b:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0103470:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0103473:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010347a:	00 
f010347b:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0103482:	00 
f0103483:	a1 b8 3e 29 f0       	mov    0xf0293eb8,%eax
f0103488:	89 04 24             	mov    %eax,(%esp)
f010348b:	e8 2d ed ff ff       	call   f01021bd <pgdir_walk>
f0103490:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0103493:	83 c2 04             	add    $0x4,%edx
f0103496:	39 d0                	cmp    %edx,%eax
f0103498:	74 24                	je     f01034be <mem_init+0xb4f>
f010349a:	c7 44 24 0c 24 9c 10 	movl   $0xf0109c24,0xc(%esp)
f01034a1:	f0 
f01034a2:	c7 44 24 08 8c 95 10 	movl   $0xf010958c,0x8(%esp)
f01034a9:	f0 
f01034aa:	c7 44 24 04 8a 04 00 	movl   $0x48a,0x4(%esp)
f01034b1:	00 
f01034b2:	c7 04 24 66 95 10 f0 	movl   $0xf0109566,(%esp)
f01034b9:	e8 c7 cb ff ff       	call   f0100085 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f01034be:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f01034c5:	00 
f01034c6:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01034cd:	00 
f01034ce:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01034d2:	a1 b8 3e 29 f0       	mov    0xf0293eb8,%eax
f01034d7:	89 04 24             	mov    %eax,(%esp)
f01034da:	e8 74 ef ff ff       	call   f0102453 <page_insert>
f01034df:	85 c0                	test   %eax,%eax
f01034e1:	74 24                	je     f0103507 <mem_init+0xb98>
f01034e3:	c7 44 24 0c 64 9c 10 	movl   $0xf0109c64,0xc(%esp)
f01034ea:	f0 
f01034eb:	c7 44 24 08 8c 95 10 	movl   $0xf010958c,0x8(%esp)
f01034f2:	f0 
f01034f3:	c7 44 24 04 8d 04 00 	movl   $0x48d,0x4(%esp)
f01034fa:	00 
f01034fb:	c7 04 24 66 95 10 f0 	movl   $0xf0109566,(%esp)
f0103502:	e8 7e cb ff ff       	call   f0100085 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0103507:	ba 00 10 00 00       	mov    $0x1000,%edx
f010350c:	a1 b8 3e 29 f0       	mov    0xf0293eb8,%eax
f0103511:	e8 1e e8 ff ff       	call   f0101d34 <check_va2pa>
f0103516:	8b 55 cc             	mov    -0x34(%ebp),%edx
f0103519:	2b 15 bc 3e 29 f0    	sub    0xf0293ebc,%edx
f010351f:	c1 fa 03             	sar    $0x3,%edx
f0103522:	c1 e2 0c             	shl    $0xc,%edx
f0103525:	39 d0                	cmp    %edx,%eax
f0103527:	74 24                	je     f010354d <mem_init+0xbde>
f0103529:	c7 44 24 0c f4 9b 10 	movl   $0xf0109bf4,0xc(%esp)
f0103530:	f0 
f0103531:	c7 44 24 08 8c 95 10 	movl   $0xf010958c,0x8(%esp)
f0103538:	f0 
f0103539:	c7 44 24 04 8e 04 00 	movl   $0x48e,0x4(%esp)
f0103540:	00 
f0103541:	c7 04 24 66 95 10 f0 	movl   $0xf0109566,(%esp)
f0103548:	e8 38 cb ff ff       	call   f0100085 <_panic>
	assert(pp2->pp_ref == 1);
f010354d:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0103552:	74 24                	je     f0103578 <mem_init+0xc09>
f0103554:	c7 44 24 0c a3 96 10 	movl   $0xf01096a3,0xc(%esp)
f010355b:	f0 
f010355c:	c7 44 24 08 8c 95 10 	movl   $0xf010958c,0x8(%esp)
f0103563:	f0 
f0103564:	c7 44 24 04 8f 04 00 	movl   $0x48f,0x4(%esp)
f010356b:	00 
f010356c:	c7 04 24 66 95 10 f0 	movl   $0xf0109566,(%esp)
f0103573:	e8 0d cb ff ff       	call   f0100085 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0103578:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010357f:	00 
f0103580:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0103587:	00 
f0103588:	a1 b8 3e 29 f0       	mov    0xf0293eb8,%eax
f010358d:	89 04 24             	mov    %eax,(%esp)
f0103590:	e8 28 ec ff ff       	call   f01021bd <pgdir_walk>
f0103595:	f6 00 04             	testb  $0x4,(%eax)
f0103598:	75 24                	jne    f01035be <mem_init+0xc4f>
f010359a:	c7 44 24 0c a4 9c 10 	movl   $0xf0109ca4,0xc(%esp)
f01035a1:	f0 
f01035a2:	c7 44 24 08 8c 95 10 	movl   $0xf010958c,0x8(%esp)
f01035a9:	f0 
f01035aa:	c7 44 24 04 90 04 00 	movl   $0x490,0x4(%esp)
f01035b1:	00 
f01035b2:	c7 04 24 66 95 10 f0 	movl   $0xf0109566,(%esp)
f01035b9:	e8 c7 ca ff ff       	call   f0100085 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f01035be:	a1 b8 3e 29 f0       	mov    0xf0293eb8,%eax
f01035c3:	f6 00 04             	testb  $0x4,(%eax)
f01035c6:	75 24                	jne    f01035ec <mem_init+0xc7d>
f01035c8:	c7 44 24 0c bd 97 10 	movl   $0xf01097bd,0xc(%esp)
f01035cf:	f0 
f01035d0:	c7 44 24 08 8c 95 10 	movl   $0xf010958c,0x8(%esp)
f01035d7:	f0 
f01035d8:	c7 44 24 04 91 04 00 	movl   $0x491,0x4(%esp)
f01035df:	00 
f01035e0:	c7 04 24 66 95 10 f0 	movl   $0xf0109566,(%esp)
f01035e7:	e8 99 ca ff ff       	call   f0100085 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f01035ec:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01035f3:	00 
f01035f4:	c7 44 24 08 00 00 40 	movl   $0x400000,0x8(%esp)
f01035fb:	00 
f01035fc:	89 74 24 04          	mov    %esi,0x4(%esp)
f0103600:	89 04 24             	mov    %eax,(%esp)
f0103603:	e8 4b ee ff ff       	call   f0102453 <page_insert>
f0103608:	85 c0                	test   %eax,%eax
f010360a:	78 24                	js     f0103630 <mem_init+0xcc1>
f010360c:	c7 44 24 0c d8 9c 10 	movl   $0xf0109cd8,0xc(%esp)
f0103613:	f0 
f0103614:	c7 44 24 08 8c 95 10 	movl   $0xf010958c,0x8(%esp)
f010361b:	f0 
f010361c:	c7 44 24 04 94 04 00 	movl   $0x494,0x4(%esp)
f0103623:	00 
f0103624:	c7 04 24 66 95 10 f0 	movl   $0xf0109566,(%esp)
f010362b:	e8 55 ca ff ff       	call   f0100085 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0103630:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0103637:	00 
f0103638:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010363f:	00 
f0103640:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103644:	a1 b8 3e 29 f0       	mov    0xf0293eb8,%eax
f0103649:	89 04 24             	mov    %eax,(%esp)
f010364c:	e8 02 ee ff ff       	call   f0102453 <page_insert>
f0103651:	85 c0                	test   %eax,%eax
f0103653:	74 24                	je     f0103679 <mem_init+0xd0a>
f0103655:	c7 44 24 0c 10 9d 10 	movl   $0xf0109d10,0xc(%esp)
f010365c:	f0 
f010365d:	c7 44 24 08 8c 95 10 	movl   $0xf010958c,0x8(%esp)
f0103664:	f0 
f0103665:	c7 44 24 04 97 04 00 	movl   $0x497,0x4(%esp)
f010366c:	00 
f010366d:	c7 04 24 66 95 10 f0 	movl   $0xf0109566,(%esp)
f0103674:	e8 0c ca ff ff       	call   f0100085 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0103679:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0103680:	00 
f0103681:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0103688:	00 
f0103689:	a1 b8 3e 29 f0       	mov    0xf0293eb8,%eax
f010368e:	89 04 24             	mov    %eax,(%esp)
f0103691:	e8 27 eb ff ff       	call   f01021bd <pgdir_walk>
f0103696:	f6 00 04             	testb  $0x4,(%eax)
f0103699:	74 24                	je     f01036bf <mem_init+0xd50>
f010369b:	c7 44 24 0c 4c 9d 10 	movl   $0xf0109d4c,0xc(%esp)
f01036a2:	f0 
f01036a3:	c7 44 24 08 8c 95 10 	movl   $0xf010958c,0x8(%esp)
f01036aa:	f0 
f01036ab:	c7 44 24 04 98 04 00 	movl   $0x498,0x4(%esp)
f01036b2:	00 
f01036b3:	c7 04 24 66 95 10 f0 	movl   $0xf0109566,(%esp)
f01036ba:	e8 c6 c9 ff ff       	call   f0100085 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f01036bf:	ba 00 00 00 00       	mov    $0x0,%edx
f01036c4:	a1 b8 3e 29 f0       	mov    0xf0293eb8,%eax
f01036c9:	e8 66 e6 ff ff       	call   f0101d34 <check_va2pa>
f01036ce:	8b 55 d0             	mov    -0x30(%ebp),%edx
f01036d1:	2b 15 bc 3e 29 f0    	sub    0xf0293ebc,%edx
f01036d7:	c1 fa 03             	sar    $0x3,%edx
f01036da:	c1 e2 0c             	shl    $0xc,%edx
f01036dd:	39 d0                	cmp    %edx,%eax
f01036df:	74 24                	je     f0103705 <mem_init+0xd96>
f01036e1:	c7 44 24 0c 84 9d 10 	movl   $0xf0109d84,0xc(%esp)
f01036e8:	f0 
f01036e9:	c7 44 24 08 8c 95 10 	movl   $0xf010958c,0x8(%esp)
f01036f0:	f0 
f01036f1:	c7 44 24 04 9b 04 00 	movl   $0x49b,0x4(%esp)
f01036f8:	00 
f01036f9:	c7 04 24 66 95 10 f0 	movl   $0xf0109566,(%esp)
f0103700:	e8 80 c9 ff ff       	call   f0100085 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0103705:	ba 00 10 00 00       	mov    $0x1000,%edx
f010370a:	a1 b8 3e 29 f0       	mov    0xf0293eb8,%eax
f010370f:	e8 20 e6 ff ff       	call   f0101d34 <check_va2pa>
f0103714:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0103717:	2b 15 bc 3e 29 f0    	sub    0xf0293ebc,%edx
f010371d:	c1 fa 03             	sar    $0x3,%edx
f0103720:	c1 e2 0c             	shl    $0xc,%edx
f0103723:	39 d0                	cmp    %edx,%eax
f0103725:	74 24                	je     f010374b <mem_init+0xddc>
f0103727:	c7 44 24 0c b0 9d 10 	movl   $0xf0109db0,0xc(%esp)
f010372e:	f0 
f010372f:	c7 44 24 08 8c 95 10 	movl   $0xf010958c,0x8(%esp)
f0103736:	f0 
f0103737:	c7 44 24 04 9c 04 00 	movl   $0x49c,0x4(%esp)
f010373e:	00 
f010373f:	c7 04 24 66 95 10 f0 	movl   $0xf0109566,(%esp)
f0103746:	e8 3a c9 ff ff       	call   f0100085 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f010374b:	66 83 7f 04 02       	cmpw   $0x2,0x4(%edi)
f0103750:	74 24                	je     f0103776 <mem_init+0xe07>
f0103752:	c7 44 24 0c d3 97 10 	movl   $0xf01097d3,0xc(%esp)
f0103759:	f0 
f010375a:	c7 44 24 08 8c 95 10 	movl   $0xf010958c,0x8(%esp)
f0103761:	f0 
f0103762:	c7 44 24 04 9e 04 00 	movl   $0x49e,0x4(%esp)
f0103769:	00 
f010376a:	c7 04 24 66 95 10 f0 	movl   $0xf0109566,(%esp)
f0103771:	e8 0f c9 ff ff       	call   f0100085 <_panic>
	assert(pp2->pp_ref == 0);
f0103776:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f010377b:	74 24                	je     f01037a1 <mem_init+0xe32>
f010377d:	c7 44 24 0c c5 96 10 	movl   $0xf01096c5,0xc(%esp)
f0103784:	f0 
f0103785:	c7 44 24 08 8c 95 10 	movl   $0xf010958c,0x8(%esp)
f010378c:	f0 
f010378d:	c7 44 24 04 9f 04 00 	movl   $0x49f,0x4(%esp)
f0103794:	00 
f0103795:	c7 04 24 66 95 10 f0 	movl   $0xf0109566,(%esp)
f010379c:	e8 e4 c8 ff ff       	call   f0100085 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f01037a1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01037a8:	e8 92 e9 ff ff       	call   f010213f <page_alloc>
f01037ad:	85 c0                	test   %eax,%eax
f01037af:	74 04                	je     f01037b5 <mem_init+0xe46>
f01037b1:	39 c3                	cmp    %eax,%ebx
f01037b3:	74 24                	je     f01037d9 <mem_init+0xe6a>
f01037b5:	c7 44 24 0c e0 9d 10 	movl   $0xf0109de0,0xc(%esp)
f01037bc:	f0 
f01037bd:	c7 44 24 08 8c 95 10 	movl   $0xf010958c,0x8(%esp)
f01037c4:	f0 
f01037c5:	c7 44 24 04 a2 04 00 	movl   $0x4a2,0x4(%esp)
f01037cc:	00 
f01037cd:	c7 04 24 66 95 10 f0 	movl   $0xf0109566,(%esp)
f01037d4:	e8 ac c8 ff ff       	call   f0100085 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f01037d9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01037e0:	00 
f01037e1:	a1 b8 3e 29 f0       	mov    0xf0293eb8,%eax
f01037e6:	89 04 24             	mov    %eax,(%esp)
f01037e9:	e8 0a ec ff ff       	call   f01023f8 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01037ee:	ba 00 00 00 00       	mov    $0x0,%edx
f01037f3:	a1 b8 3e 29 f0       	mov    0xf0293eb8,%eax
f01037f8:	e8 37 e5 ff ff       	call   f0101d34 <check_va2pa>
f01037fd:	83 f8 ff             	cmp    $0xffffffff,%eax
f0103800:	74 24                	je     f0103826 <mem_init+0xeb7>
f0103802:	c7 44 24 0c 04 9e 10 	movl   $0xf0109e04,0xc(%esp)
f0103809:	f0 
f010380a:	c7 44 24 08 8c 95 10 	movl   $0xf010958c,0x8(%esp)
f0103811:	f0 
f0103812:	c7 44 24 04 a6 04 00 	movl   $0x4a6,0x4(%esp)
f0103819:	00 
f010381a:	c7 04 24 66 95 10 f0 	movl   $0xf0109566,(%esp)
f0103821:	e8 5f c8 ff ff       	call   f0100085 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0103826:	ba 00 10 00 00       	mov    $0x1000,%edx
f010382b:	a1 b8 3e 29 f0       	mov    0xf0293eb8,%eax
f0103830:	e8 ff e4 ff ff       	call   f0101d34 <check_va2pa>
f0103835:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0103838:	2b 15 bc 3e 29 f0    	sub    0xf0293ebc,%edx
f010383e:	c1 fa 03             	sar    $0x3,%edx
f0103841:	c1 e2 0c             	shl    $0xc,%edx
f0103844:	39 d0                	cmp    %edx,%eax
f0103846:	74 24                	je     f010386c <mem_init+0xefd>
f0103848:	c7 44 24 0c b0 9d 10 	movl   $0xf0109db0,0xc(%esp)
f010384f:	f0 
f0103850:	c7 44 24 08 8c 95 10 	movl   $0xf010958c,0x8(%esp)
f0103857:	f0 
f0103858:	c7 44 24 04 a7 04 00 	movl   $0x4a7,0x4(%esp)
f010385f:	00 
f0103860:	c7 04 24 66 95 10 f0 	movl   $0xf0109566,(%esp)
f0103867:	e8 19 c8 ff ff       	call   f0100085 <_panic>
	assert(pp1->pp_ref == 1);
f010386c:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0103871:	74 24                	je     f0103897 <mem_init+0xf28>
f0103873:	c7 44 24 0c 92 96 10 	movl   $0xf0109692,0xc(%esp)
f010387a:	f0 
f010387b:	c7 44 24 08 8c 95 10 	movl   $0xf010958c,0x8(%esp)
f0103882:	f0 
f0103883:	c7 44 24 04 a8 04 00 	movl   $0x4a8,0x4(%esp)
f010388a:	00 
f010388b:	c7 04 24 66 95 10 f0 	movl   $0xf0109566,(%esp)
f0103892:	e8 ee c7 ff ff       	call   f0100085 <_panic>
	assert(pp2->pp_ref == 0);
f0103897:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f010389c:	74 24                	je     f01038c2 <mem_init+0xf53>
f010389e:	c7 44 24 0c c5 96 10 	movl   $0xf01096c5,0xc(%esp)
f01038a5:	f0 
f01038a6:	c7 44 24 08 8c 95 10 	movl   $0xf010958c,0x8(%esp)
f01038ad:	f0 
f01038ae:	c7 44 24 04 a9 04 00 	movl   $0x4a9,0x4(%esp)
f01038b5:	00 
f01038b6:	c7 04 24 66 95 10 f0 	movl   $0xf0109566,(%esp)
f01038bd:	e8 c3 c7 ff ff       	call   f0100085 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f01038c2:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01038c9:	00 
f01038ca:	a1 b8 3e 29 f0       	mov    0xf0293eb8,%eax
f01038cf:	89 04 24             	mov    %eax,(%esp)
f01038d2:	e8 21 eb ff ff       	call   f01023f8 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01038d7:	ba 00 00 00 00       	mov    $0x0,%edx
f01038dc:	a1 b8 3e 29 f0       	mov    0xf0293eb8,%eax
f01038e1:	e8 4e e4 ff ff       	call   f0101d34 <check_va2pa>
f01038e6:	83 f8 ff             	cmp    $0xffffffff,%eax
f01038e9:	74 24                	je     f010390f <mem_init+0xfa0>
f01038eb:	c7 44 24 0c 04 9e 10 	movl   $0xf0109e04,0xc(%esp)
f01038f2:	f0 
f01038f3:	c7 44 24 08 8c 95 10 	movl   $0xf010958c,0x8(%esp)
f01038fa:	f0 
f01038fb:	c7 44 24 04 ad 04 00 	movl   $0x4ad,0x4(%esp)
f0103902:	00 
f0103903:	c7 04 24 66 95 10 f0 	movl   $0xf0109566,(%esp)
f010390a:	e8 76 c7 ff ff       	call   f0100085 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f010390f:	ba 00 10 00 00       	mov    $0x1000,%edx
f0103914:	a1 b8 3e 29 f0       	mov    0xf0293eb8,%eax
f0103919:	e8 16 e4 ff ff       	call   f0101d34 <check_va2pa>
f010391e:	83 f8 ff             	cmp    $0xffffffff,%eax
f0103921:	74 24                	je     f0103947 <mem_init+0xfd8>
f0103923:	c7 44 24 0c 28 9e 10 	movl   $0xf0109e28,0xc(%esp)
f010392a:	f0 
f010392b:	c7 44 24 08 8c 95 10 	movl   $0xf010958c,0x8(%esp)
f0103932:	f0 
f0103933:	c7 44 24 04 ae 04 00 	movl   $0x4ae,0x4(%esp)
f010393a:	00 
f010393b:	c7 04 24 66 95 10 f0 	movl   $0xf0109566,(%esp)
f0103942:	e8 3e c7 ff ff       	call   f0100085 <_panic>
	assert(pp1->pp_ref == 0);
f0103947:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f010394c:	74 24                	je     f0103972 <mem_init+0x1003>
f010394e:	c7 44 24 0c b4 96 10 	movl   $0xf01096b4,0xc(%esp)
f0103955:	f0 
f0103956:	c7 44 24 08 8c 95 10 	movl   $0xf010958c,0x8(%esp)
f010395d:	f0 
f010395e:	c7 44 24 04 af 04 00 	movl   $0x4af,0x4(%esp)
f0103965:	00 
f0103966:	c7 04 24 66 95 10 f0 	movl   $0xf0109566,(%esp)
f010396d:	e8 13 c7 ff ff       	call   f0100085 <_panic>
	assert(pp2->pp_ref == 0);
f0103972:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0103977:	74 24                	je     f010399d <mem_init+0x102e>
f0103979:	c7 44 24 0c c5 96 10 	movl   $0xf01096c5,0xc(%esp)
f0103980:	f0 
f0103981:	c7 44 24 08 8c 95 10 	movl   $0xf010958c,0x8(%esp)
f0103988:	f0 
f0103989:	c7 44 24 04 b0 04 00 	movl   $0x4b0,0x4(%esp)
f0103990:	00 
f0103991:	c7 04 24 66 95 10 f0 	movl   $0xf0109566,(%esp)
f0103998:	e8 e8 c6 ff ff       	call   f0100085 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f010399d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01039a4:	e8 96 e7 ff ff       	call   f010213f <page_alloc>
f01039a9:	85 c0                	test   %eax,%eax
f01039ab:	74 05                	je     f01039b2 <mem_init+0x1043>
f01039ad:	39 c7                	cmp    %eax,%edi
f01039af:	90                   	nop
f01039b0:	74 24                	je     f01039d6 <mem_init+0x1067>
f01039b2:	c7 44 24 0c 50 9e 10 	movl   $0xf0109e50,0xc(%esp)
f01039b9:	f0 
f01039ba:	c7 44 24 08 8c 95 10 	movl   $0xf010958c,0x8(%esp)
f01039c1:	f0 
f01039c2:	c7 44 24 04 b3 04 00 	movl   $0x4b3,0x4(%esp)
f01039c9:	00 
f01039ca:	c7 04 24 66 95 10 f0 	movl   $0xf0109566,(%esp)
f01039d1:	e8 af c6 ff ff       	call   f0100085 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f01039d6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01039dd:	e8 5d e7 ff ff       	call   f010213f <page_alloc>
f01039e2:	85 c0                	test   %eax,%eax
f01039e4:	74 24                	je     f0103a0a <mem_init+0x109b>
f01039e6:	c7 44 24 0c 6b 97 10 	movl   $0xf010976b,0xc(%esp)
f01039ed:	f0 
f01039ee:	c7 44 24 08 8c 95 10 	movl   $0xf010958c,0x8(%esp)
f01039f5:	f0 
f01039f6:	c7 44 24 04 b6 04 00 	movl   $0x4b6,0x4(%esp)
f01039fd:	00 
f01039fe:	c7 04 24 66 95 10 f0 	movl   $0xf0109566,(%esp)
f0103a05:	e8 7b c6 ff ff       	call   f0100085 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0103a0a:	a1 b8 3e 29 f0       	mov    0xf0293eb8,%eax
f0103a0f:	8b 08                	mov    (%eax),%ecx
f0103a11:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0103a17:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0103a1a:	2b 15 bc 3e 29 f0    	sub    0xf0293ebc,%edx
f0103a20:	c1 fa 03             	sar    $0x3,%edx
f0103a23:	c1 e2 0c             	shl    $0xc,%edx
f0103a26:	39 d1                	cmp    %edx,%ecx
f0103a28:	74 24                	je     f0103a4e <mem_init+0x10df>
f0103a2a:	c7 44 24 0c 5c 9a 10 	movl   $0xf0109a5c,0xc(%esp)
f0103a31:	f0 
f0103a32:	c7 44 24 08 8c 95 10 	movl   $0xf010958c,0x8(%esp)
f0103a39:	f0 
f0103a3a:	c7 44 24 04 b9 04 00 	movl   $0x4b9,0x4(%esp)
f0103a41:	00 
f0103a42:	c7 04 24 66 95 10 f0 	movl   $0xf0109566,(%esp)
f0103a49:	e8 37 c6 ff ff       	call   f0100085 <_panic>
	kern_pgdir[0] = 0;
f0103a4e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f0103a54:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0103a59:	74 24                	je     f0103a7f <mem_init+0x1110>
f0103a5b:	c7 44 24 0c d6 96 10 	movl   $0xf01096d6,0xc(%esp)
f0103a62:	f0 
f0103a63:	c7 44 24 08 8c 95 10 	movl   $0xf010958c,0x8(%esp)
f0103a6a:	f0 
f0103a6b:	c7 44 24 04 bb 04 00 	movl   $0x4bb,0x4(%esp)
f0103a72:	00 
f0103a73:	c7 04 24 66 95 10 f0 	movl   $0xf0109566,(%esp)
f0103a7a:	e8 06 c6 ff ff       	call   f0100085 <_panic>
	pp0->pp_ref = 0;
f0103a7f:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0103a85:	89 34 24             	mov    %esi,(%esp)
f0103a88:	e8 62 dc ff ff       	call   f01016ef <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0103a8d:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0103a94:	00 
f0103a95:	c7 44 24 04 00 10 40 	movl   $0x401000,0x4(%esp)
f0103a9c:	00 
f0103a9d:	a1 b8 3e 29 f0       	mov    0xf0293eb8,%eax
f0103aa2:	89 04 24             	mov    %eax,(%esp)
f0103aa5:	e8 13 e7 ff ff       	call   f01021bd <pgdir_walk>
f0103aaa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0103aad:	8b 0d b8 3e 29 f0    	mov    0xf0293eb8,%ecx
f0103ab3:	83 c1 04             	add    $0x4,%ecx
f0103ab6:	8b 11                	mov    (%ecx),%edx
f0103ab8:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0103abe:	89 55 cc             	mov    %edx,-0x34(%ebp)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103ac1:	c1 ea 0c             	shr    $0xc,%edx
f0103ac4:	3b 15 b4 3e 29 f0    	cmp    0xf0293eb4,%edx
f0103aca:	72 23                	jb     f0103aef <mem_init+0x1180>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103acc:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0103acf:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0103ad3:	c7 44 24 08 c0 8d 10 	movl   $0xf0108dc0,0x8(%esp)
f0103ada:	f0 
f0103adb:	c7 44 24 04 c2 04 00 	movl   $0x4c2,0x4(%esp)
f0103ae2:	00 
f0103ae3:	c7 04 24 66 95 10 f0 	movl   $0xf0109566,(%esp)
f0103aea:	e8 96 c5 ff ff       	call   f0100085 <_panic>
	assert(ptep == ptep1 + PTX(va));
f0103aef:	8b 55 cc             	mov    -0x34(%ebp),%edx
f0103af2:	81 ea fc ff ff 0f    	sub    $0xffffffc,%edx
f0103af8:	39 d0                	cmp    %edx,%eax
f0103afa:	74 24                	je     f0103b20 <mem_init+0x11b1>
f0103afc:	c7 44 24 0c e4 97 10 	movl   $0xf01097e4,0xc(%esp)
f0103b03:	f0 
f0103b04:	c7 44 24 08 8c 95 10 	movl   $0xf010958c,0x8(%esp)
f0103b0b:	f0 
f0103b0c:	c7 44 24 04 c3 04 00 	movl   $0x4c3,0x4(%esp)
f0103b13:	00 
f0103b14:	c7 04 24 66 95 10 f0 	movl   $0xf0109566,(%esp)
f0103b1b:	e8 65 c5 ff ff       	call   f0100085 <_panic>
	kern_pgdir[PDX(va)] = 0;
f0103b20:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	pp0->pp_ref = 0;
f0103b26:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)


static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0103b2c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103b2f:	2b 05 bc 3e 29 f0    	sub    0xf0293ebc,%eax
f0103b35:	c1 f8 03             	sar    $0x3,%eax
f0103b38:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103b3b:	89 c2                	mov    %eax,%edx
f0103b3d:	c1 ea 0c             	shr    $0xc,%edx
f0103b40:	3b 15 b4 3e 29 f0    	cmp    0xf0293eb4,%edx
f0103b46:	72 20                	jb     f0103b68 <mem_init+0x11f9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103b48:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103b4c:	c7 44 24 08 c0 8d 10 	movl   $0xf0108dc0,0x8(%esp)
f0103b53:	f0 
f0103b54:	c7 44 24 04 59 00 00 	movl   $0x59,0x4(%esp)
f0103b5b:	00 
f0103b5c:	c7 04 24 72 95 10 f0 	movl   $0xf0109572,(%esp)
f0103b63:	e8 1d c5 ff ff       	call   f0100085 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0103b68:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103b6f:	00 
f0103b70:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
f0103b77:	00 
f0103b78:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0103b7d:	89 04 24             	mov    %eax,(%esp)
f0103b80:	e8 71 39 00 00       	call   f01074f6 <memset>
	page_free(pp0);
f0103b85:	89 34 24             	mov    %esi,(%esp)
f0103b88:	e8 62 db ff ff       	call   f01016ef <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0103b8d:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0103b94:	00 
f0103b95:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103b9c:	00 
f0103b9d:	a1 b8 3e 29 f0       	mov    0xf0293eb8,%eax
f0103ba2:	89 04 24             	mov    %eax,(%esp)
f0103ba5:	e8 13 e6 ff ff       	call   f01021bd <pgdir_walk>


static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0103baa:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0103bad:	2b 15 bc 3e 29 f0    	sub    0xf0293ebc,%edx
f0103bb3:	c1 fa 03             	sar    $0x3,%edx
f0103bb6:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103bb9:	89 d0                	mov    %edx,%eax
f0103bbb:	c1 e8 0c             	shr    $0xc,%eax
f0103bbe:	3b 05 b4 3e 29 f0    	cmp    0xf0293eb4,%eax
f0103bc4:	72 20                	jb     f0103be6 <mem_init+0x1277>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103bc6:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0103bca:	c7 44 24 08 c0 8d 10 	movl   $0xf0108dc0,0x8(%esp)
f0103bd1:	f0 
f0103bd2:	c7 44 24 04 59 00 00 	movl   $0x59,0x4(%esp)
f0103bd9:	00 
f0103bda:	c7 04 24 72 95 10 f0 	movl   $0xf0109572,(%esp)
f0103be1:	e8 9f c4 ff ff       	call   f0100085 <_panic>
	ptep = (pte_t *) page2kva(pp0);
f0103be6:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
f0103bec:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0103bef:	f6 00 01             	testb  $0x1,(%eax)
f0103bf2:	75 11                	jne    f0103c05 <mem_init+0x1296>
f0103bf4:	8d 82 04 00 00 f0    	lea    -0xffffffc(%edx),%eax
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0103bfa:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0103c00:	f6 00 01             	testb  $0x1,(%eax)
f0103c03:	74 24                	je     f0103c29 <mem_init+0x12ba>
f0103c05:	c7 44 24 0c fc 97 10 	movl   $0xf01097fc,0xc(%esp)
f0103c0c:	f0 
f0103c0d:	c7 44 24 08 8c 95 10 	movl   $0xf010958c,0x8(%esp)
f0103c14:	f0 
f0103c15:	c7 44 24 04 cd 04 00 	movl   $0x4cd,0x4(%esp)
f0103c1c:	00 
f0103c1d:	c7 04 24 66 95 10 f0 	movl   $0xf0109566,(%esp)
f0103c24:	e8 5c c4 ff ff       	call   f0100085 <_panic>
f0103c29:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f0103c2c:	39 d0                	cmp    %edx,%eax
f0103c2e:	75 d0                	jne    f0103c00 <mem_init+0x1291>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f0103c30:	a1 b8 3e 29 f0       	mov    0xf0293eb8,%eax
f0103c35:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0103c3b:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// give free list back
	page_free_list = fl;
f0103c41:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0103c44:	a3 50 32 29 f0       	mov    %eax,0xf0293250

	// free the pages we took
	page_free(pp0);
f0103c49:	89 34 24             	mov    %esi,(%esp)
f0103c4c:	e8 9e da ff ff       	call   f01016ef <page_free>
	page_free(pp1);
f0103c51:	89 3c 24             	mov    %edi,(%esp)
f0103c54:	e8 96 da ff ff       	call   f01016ef <page_free>
	page_free(pp2);
f0103c59:	89 1c 24             	mov    %ebx,(%esp)
f0103c5c:	e8 8e da ff ff       	call   f01016ef <page_free>

	cprintf("check_page() succeeded!\n");
f0103c61:	c7 04 24 13 98 10 f0 	movl   $0xf0109813,(%esp)
f0103c68:	e8 a2 0f 00 00       	call   f0104c0f <cprintf>
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
        boot_map_region(kern_pgdir,UPAGES,PTSIZE,PADDR(pages),PTE_U|PTE_P);
f0103c6d:	a1 bc 3e 29 f0       	mov    0xf0293ebc,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103c72:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103c77:	77 20                	ja     f0103c99 <mem_init+0x132a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103c79:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103c7d:	c7 44 24 08 9c 8d 10 	movl   $0xf0108d9c,0x8(%esp)
f0103c84:	f0 
f0103c85:	c7 44 24 04 c6 00 00 	movl   $0xc6,0x4(%esp)
f0103c8c:	00 
f0103c8d:	c7 04 24 66 95 10 f0 	movl   $0xf0109566,(%esp)
f0103c94:	e8 ec c3 ff ff       	call   f0100085 <_panic>
f0103c99:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
f0103ca0:	00 
f0103ca1:	8d 80 00 00 00 10    	lea    0x10000000(%eax),%eax
f0103ca7:	89 04 24             	mov    %eax,(%esp)
f0103caa:	b9 00 00 40 00       	mov    $0x400000,%ecx
f0103caf:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0103cb4:	a1 b8 3e 29 f0       	mov    0xf0293eb8,%eax
f0103cb9:	e8 11 e8 ff ff       	call   f01024cf <boot_map_region>
	// (ie. perm = PTE_U | PTE_P).
	// Permissions:
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.
        boot_map_region(kern_pgdir,UENVS,PTSIZE,PADDR(envs),PTE_U|PTE_P);
f0103cbe:	a1 5c 32 29 f0       	mov    0xf029325c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103cc3:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103cc8:	77 20                	ja     f0103cea <mem_init+0x137b>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103cca:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103cce:	c7 44 24 08 9c 8d 10 	movl   $0xf0108d9c,0x8(%esp)
f0103cd5:	f0 
f0103cd6:	c7 44 24 04 ce 00 00 	movl   $0xce,0x4(%esp)
f0103cdd:	00 
f0103cde:	c7 04 24 66 95 10 f0 	movl   $0xf0109566,(%esp)
f0103ce5:	e8 9b c3 ff ff       	call   f0100085 <_panic>
f0103cea:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
f0103cf1:	00 
f0103cf2:	8d 80 00 00 00 10    	lea    0x10000000(%eax),%eax
f0103cf8:	89 04 24             	mov    %eax,(%esp)
f0103cfb:	b9 00 00 40 00       	mov    $0x400000,%ecx
f0103d00:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0103d05:	a1 b8 3e 29 f0       	mov    0xf0293eb8,%eax
f0103d0a:	e8 c0 e7 ff ff       	call   f01024cf <boot_map_region>
static void
mem_init_mp(void)
{
	// Create a direct mapping at the top of virtual address space starting
	// at IOMEMBASE for accessing the LAPIC unit using memory-mapped I/O.
	boot_map_region(kern_pgdir, IOMEMBASE, -IOMEMBASE, IOMEM_PADDR, PTE_W);
f0103d0f:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0103d16:	00 
f0103d17:	c7 04 24 00 00 00 fe 	movl   $0xfe000000,(%esp)
f0103d1e:	b9 00 00 00 02       	mov    $0x2000000,%ecx
f0103d23:	ba 00 00 00 fe       	mov    $0xfe000000,%edx
f0103d28:	a1 b8 3e 29 f0       	mov    0xf0293eb8,%eax
f0103d2d:	e8 9d e7 ff ff       	call   f01024cf <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103d32:	c7 45 cc 00 50 29 f0 	movl   $0xf0295000,-0x34(%ebp)
f0103d39:	81 7d cc ff ff ff ef 	cmpl   $0xefffffff,-0x34(%ebp)
f0103d40:	0f 87 2b 05 00 00    	ja     f0104271 <mem_init+0x1902>
f0103d46:	b8 00 50 29 f0       	mov    $0xf0295000,%eax
f0103d4b:	eb 0a                	jmp    f0103d57 <mem_init+0x13e8>
f0103d4d:	89 d8                	mov    %ebx,%eax
f0103d4f:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f0103d55:	77 20                	ja     f0103d77 <mem_init+0x1408>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103d57:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103d5b:	c7 44 24 08 9c 8d 10 	movl   $0xf0108d9c,0x8(%esp)
f0103d62:	f0 
f0103d63:	c7 44 24 04 25 01 00 	movl   $0x125,0x4(%esp)
f0103d6a:	00 
f0103d6b:	c7 04 24 66 95 10 f0 	movl   $0xf0109566,(%esp)
f0103d72:	e8 0e c3 ff ff       	call   f0100085 <_panic>
	//
	// LAB 4: Your code here:
        int i;
        for(i = 0;i<NCPU;i++){
          uint32_t kstacktop_i = KSTACKTOP - i*(KSTKSIZE+KSTKGAP);
          boot_map_region(kern_pgdir,kstacktop_i - KSTKSIZE , KSTKSIZE, PADDR(percpu_kstacks[i]),PTE_P | PTE_W);
f0103d77:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f0103d7e:	00 
f0103d7f:	8d 83 00 00 00 10    	lea    0x10000000(%ebx),%eax
f0103d85:	89 04 24             	mov    %eax,(%esp)
f0103d88:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0103d8d:	89 f2                	mov    %esi,%edx
f0103d8f:	a1 b8 3e 29 f0       	mov    0xf0293eb8,%eax
f0103d94:	e8 36 e7 ff ff       	call   f01024cf <boot_map_region>
f0103d99:	81 c3 00 80 00 00    	add    $0x8000,%ebx
f0103d9f:	81 ee 00 00 01 00    	sub    $0x10000,%esi
	//             Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	//
	// LAB 4: Your code here:
        int i;
        for(i = 0;i<NCPU;i++){
f0103da5:	81 fe 00 80 b7 ef    	cmp    $0xefb78000,%esi
f0103dab:	75 a0                	jne    f0103d4d <mem_init+0x13de>
	mem_init_mp();

        //lcr4(rcr4() |CR4_PSE);
        //boot_map_region_large(kern_pgdir,KERNBASE,(uint32_t)(~KERNBASE + 1),PADDR((void*)KERNBASE),PTE_P|PTE_W);
        //boot_map_region_large(kern_pgdir,KERNBASE,(uint32_t)(IOMEMBASE-KERNBASE),PADDR((void*)KERNBASE),PTE_P|PTE_W);
        boot_map_region(kern_pgdir,KERNBASE,(uint32_t)(IOMEMBASE-KERNBASE),PADDR((void*)KERNBASE),PTE_P|PTE_W);
f0103dad:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f0103db4:	00 
f0103db5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103dbc:	b9 00 00 00 0e       	mov    $0xe000000,%ecx
f0103dc1:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0103dc6:	a1 b8 3e 29 f0       	mov    0xf0293eb8,%eax
f0103dcb:	e8 ff e6 ff ff       	call   f01024cf <boot_map_region>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f0103dd0:	8b 35 b8 3e 29 f0    	mov    0xf0293eb8,%esi

	// check pages array
	n = ROUNDUP(npages*sizeof(struct Page), PGSIZE);
f0103dd6:	a1 b4 3e 29 f0       	mov    0xf0293eb4,%eax
f0103ddb:	8d 3c c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%edi
	for (i = 0; i < n; i += PGSIZE)
f0103de2:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
f0103de8:	74 79                	je     f0103e63 <mem_init+0x14f4>
f0103dea:	bb 00 00 00 00       	mov    $0x0,%ebx
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0103def:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
f0103df5:	89 f0                	mov    %esi,%eax
f0103df7:	e8 38 df ff ff       	call   f0101d34 <check_va2pa>
f0103dfc:	8b 15 bc 3e 29 f0    	mov    0xf0293ebc,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103e02:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0103e08:	77 20                	ja     f0103e2a <mem_init+0x14bb>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103e0a:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0103e0e:	c7 44 24 08 9c 8d 10 	movl   $0xf0108d9c,0x8(%esp)
f0103e15:	f0 
f0103e16:	c7 44 24 04 e6 03 00 	movl   $0x3e6,0x4(%esp)
f0103e1d:	00 
f0103e1e:	c7 04 24 66 95 10 f0 	movl   $0xf0109566,(%esp)
f0103e25:	e8 5b c2 ff ff       	call   f0100085 <_panic>
f0103e2a:	8d 94 1a 00 00 00 10 	lea    0x10000000(%edx,%ebx,1),%edx
f0103e31:	39 d0                	cmp    %edx,%eax
f0103e33:	74 24                	je     f0103e59 <mem_init+0x14ea>
f0103e35:	c7 44 24 0c 74 9e 10 	movl   $0xf0109e74,0xc(%esp)
f0103e3c:	f0 
f0103e3d:	c7 44 24 08 8c 95 10 	movl   $0xf010958c,0x8(%esp)
f0103e44:	f0 
f0103e45:	c7 44 24 04 e6 03 00 	movl   $0x3e6,0x4(%esp)
f0103e4c:	00 
f0103e4d:	c7 04 24 66 95 10 f0 	movl   $0xf0109566,(%esp)
f0103e54:	e8 2c c2 ff ff       	call   f0100085 <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct Page), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0103e59:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0103e5f:	39 df                	cmp    %ebx,%edi
f0103e61:	77 8c                	ja     f0103def <mem_init+0x1480>
f0103e63:	bb 00 00 00 00       	mov    $0x0,%ebx
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0103e68:	8d 93 00 00 c0 ee    	lea    -0x11400000(%ebx),%edx
f0103e6e:	89 f0                	mov    %esi,%eax
f0103e70:	e8 bf de ff ff       	call   f0101d34 <check_va2pa>
f0103e75:	8b 15 5c 32 29 f0    	mov    0xf029325c,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103e7b:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0103e81:	77 20                	ja     f0103ea3 <mem_init+0x1534>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103e83:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0103e87:	c7 44 24 08 9c 8d 10 	movl   $0xf0108d9c,0x8(%esp)
f0103e8e:	f0 
f0103e8f:	c7 44 24 04 eb 03 00 	movl   $0x3eb,0x4(%esp)
f0103e96:	00 
f0103e97:	c7 04 24 66 95 10 f0 	movl   $0xf0109566,(%esp)
f0103e9e:	e8 e2 c1 ff ff       	call   f0100085 <_panic>
f0103ea3:	8d 94 1a 00 00 00 10 	lea    0x10000000(%edx,%ebx,1),%edx
f0103eaa:	39 d0                	cmp    %edx,%eax
f0103eac:	74 24                	je     f0103ed2 <mem_init+0x1563>
f0103eae:	c7 44 24 0c a8 9e 10 	movl   $0xf0109ea8,0xc(%esp)
f0103eb5:	f0 
f0103eb6:	c7 44 24 08 8c 95 10 	movl   $0xf010958c,0x8(%esp)
f0103ebd:	f0 
f0103ebe:	c7 44 24 04 eb 03 00 	movl   $0x3eb,0x4(%esp)
f0103ec5:	00 
f0103ec6:	c7 04 24 66 95 10 f0 	movl   $0xf0109566,(%esp)
f0103ecd:	e8 b3 c1 ff ff       	call   f0100085 <_panic>
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0103ed2:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0103ed8:	81 fb 00 10 02 00    	cmp    $0x21000,%ebx
f0103ede:	75 88                	jne    f0103e68 <mem_init+0x14f9>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	if (check_va2pa_large(pgdir, KERNBASE) == 0) {
f0103ee0:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0103ee5:	89 f0                	mov    %esi,%eax
f0103ee7:	e8 4c d8 ff ff       	call   f0101738 <check_va2pa_large>
f0103eec:	85 c0                	test   %eax,%eax
f0103eee:	74 13                	je     f0103f03 <mem_init+0x1594>
		for (i = 0; i < npages * PGSIZE; i += PTSIZE)
			assert(check_va2pa_large(pgdir, KERNBASE + i) == i);

		cprintf("large page installed!\n");
	} else {
	    for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0103ef0:	a1 b4 3e 29 f0       	mov    0xf0293eb4,%eax
f0103ef5:	c1 e0 0c             	shl    $0xc,%eax
	// check phys mem
	if (check_va2pa_large(pgdir, KERNBASE) == 0) {
		for (i = 0; i < npages * PGSIZE; i += PTSIZE)
			assert(check_va2pa_large(pgdir, KERNBASE + i) == i);

		cprintf("large page installed!\n");
f0103ef8:	bb 00 00 00 00       	mov    $0x0,%ebx
	} else {
	    for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0103efd:	85 c0                	test   %eax,%eax
f0103eff:	75 68                	jne    f0103f69 <mem_init+0x15fa>
f0103f01:	eb 5f                	jmp    f0103f62 <mem_init+0x15f3>
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	if (check_va2pa_large(pgdir, KERNBASE) == 0) {
		for (i = 0; i < npages * PGSIZE; i += PTSIZE)
f0103f03:	8b 3d b4 3e 29 f0    	mov    0xf0293eb4,%edi
f0103f09:	c1 e7 0c             	shl    $0xc,%edi
			assert(check_va2pa_large(pgdir, KERNBASE + i) == i);
f0103f0c:	b8 00 00 00 00       	mov    $0x0,%eax
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	if (check_va2pa_large(pgdir, KERNBASE) == 0) {
		for (i = 0; i < npages * PGSIZE; i += PTSIZE)
f0103f11:	85 ff                	test   %edi,%edi
f0103f13:	75 37                	jne    f0103f4c <mem_init+0x15dd>
f0103f15:	eb 3f                	jmp    f0103f56 <mem_init+0x15e7>
f0103f17:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
			assert(check_va2pa_large(pgdir, KERNBASE + i) == i);
f0103f1d:	89 f0                	mov    %esi,%eax
f0103f1f:	e8 14 d8 ff ff       	call   f0101738 <check_va2pa_large>
f0103f24:	39 d8                	cmp    %ebx,%eax
f0103f26:	74 24                	je     f0103f4c <mem_init+0x15dd>
f0103f28:	c7 44 24 0c dc 9e 10 	movl   $0xf0109edc,0xc(%esp)
f0103f2f:	f0 
f0103f30:	c7 44 24 08 8c 95 10 	movl   $0xf010958c,0x8(%esp)
f0103f37:	f0 
f0103f38:	c7 44 24 04 f0 03 00 	movl   $0x3f0,0x4(%esp)
f0103f3f:	00 
f0103f40:	c7 04 24 66 95 10 f0 	movl   $0xf0109566,(%esp)
f0103f47:	e8 39 c1 ff ff       	call   f0100085 <_panic>
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	if (check_va2pa_large(pgdir, KERNBASE) == 0) {
		for (i = 0; i < npages * PGSIZE; i += PTSIZE)
f0103f4c:	8d 98 00 00 40 00    	lea    0x400000(%eax),%ebx
f0103f52:	39 fb                	cmp    %edi,%ebx
f0103f54:	72 c1                	jb     f0103f17 <mem_init+0x15a8>
			assert(check_va2pa_large(pgdir, KERNBASE + i) == i);

		cprintf("large page installed!\n");
f0103f56:	c7 04 24 2c 98 10 f0 	movl   $0xf010982c,(%esp)
f0103f5d:	e8 ad 0c 00 00       	call   f0104c0f <cprintf>
f0103f62:	bb 00 00 00 fe       	mov    $0xfe000000,%ebx
f0103f67:	eb 49                	jmp    f0103fb2 <mem_init+0x1643>
	} else {
	    for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		    assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0103f69:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
f0103f6f:	89 f0                	mov    %esi,%eax
f0103f71:	e8 be dd ff ff       	call   f0101d34 <check_va2pa>
f0103f76:	39 c3                	cmp    %eax,%ebx
f0103f78:	74 24                	je     f0103f9e <mem_init+0x162f>
f0103f7a:	c7 44 24 0c 08 9f 10 	movl   $0xf0109f08,0xc(%esp)
f0103f81:	f0 
f0103f82:	c7 44 24 08 8c 95 10 	movl   $0xf010958c,0x8(%esp)
f0103f89:	f0 
f0103f8a:	c7 44 24 04 f5 03 00 	movl   $0x3f5,0x4(%esp)
f0103f91:	00 
f0103f92:	c7 04 24 66 95 10 f0 	movl   $0xf0109566,(%esp)
f0103f99:	e8 e7 c0 ff ff       	call   f0100085 <_panic>
		for (i = 0; i < npages * PGSIZE; i += PTSIZE)
			assert(check_va2pa_large(pgdir, KERNBASE + i) == i);

		cprintf("large page installed!\n");
	} else {
	    for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0103f9e:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0103fa4:	a1 b4 3e 29 f0       	mov    0xf0293eb4,%eax
f0103fa9:	c1 e0 0c             	shl    $0xc,%eax
f0103fac:	39 c3                	cmp    %eax,%ebx
f0103fae:	72 b9                	jb     f0103f69 <mem_init+0x15fa>
f0103fb0:	eb b0                	jmp    f0103f62 <mem_init+0x15f3>
	}

	
	// check IO mem (new in lab 4)
	for (i = IOMEMBASE; i < -PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, i) == i);
f0103fb2:	89 da                	mov    %ebx,%edx
f0103fb4:	89 f0                	mov    %esi,%eax
f0103fb6:	e8 79 dd ff ff       	call   f0101d34 <check_va2pa>
f0103fbb:	39 c3                	cmp    %eax,%ebx
f0103fbd:	74 24                	je     f0103fe3 <mem_init+0x1674>
f0103fbf:	c7 44 24 0c 43 98 10 	movl   $0xf0109843,0xc(%esp)
f0103fc6:	f0 
f0103fc7:	c7 44 24 08 8c 95 10 	movl   $0xf010958c,0x8(%esp)
f0103fce:	f0 
f0103fcf:	c7 44 24 04 fb 03 00 	movl   $0x3fb,0x4(%esp)
f0103fd6:	00 
f0103fd7:	c7 04 24 66 95 10 f0 	movl   $0xf0109566,(%esp)
f0103fde:	e8 a2 c0 ff ff       	call   f0100085 <_panic>
		    assert(check_va2pa(pgdir, KERNBASE + i) == i);
	}

	
	// check IO mem (new in lab 4)
	for (i = IOMEMBASE; i < -PGSIZE; i += PGSIZE)
f0103fe3:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0103fe9:	81 fb 00 f0 ff ff    	cmp    $0xfffff000,%ebx
f0103fef:	75 c1                	jne    f0103fb2 <mem_init+0x1643>
f0103ff1:	bb 00 00 00 fe       	mov    $0xfe000000,%ebx
		assert(check_va2pa(pgdir, i) == i);

	// check IO mem (new in lab 4)
	for (i = IOMEMBASE; i < -PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, i) == i);
f0103ff6:	89 da                	mov    %ebx,%edx
f0103ff8:	89 f0                	mov    %esi,%eax
f0103ffa:	e8 35 dd ff ff       	call   f0101d34 <check_va2pa>
f0103fff:	39 c3                	cmp    %eax,%ebx
f0104001:	74 24                	je     f0104027 <mem_init+0x16b8>
f0104003:	c7 44 24 0c 43 98 10 	movl   $0xf0109843,0xc(%esp)
f010400a:	f0 
f010400b:	c7 44 24 08 8c 95 10 	movl   $0xf010958c,0x8(%esp)
f0104012:	f0 
f0104013:	c7 44 24 04 ff 03 00 	movl   $0x3ff,0x4(%esp)
f010401a:	00 
f010401b:	c7 04 24 66 95 10 f0 	movl   $0xf0109566,(%esp)
f0104022:	e8 5e c0 ff ff       	call   f0100085 <_panic>
	// check IO mem (new in lab 4)
	for (i = IOMEMBASE; i < -PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, i) == i);

	// check IO mem (new in lab 4)
	for (i = IOMEMBASE; i < -PGSIZE; i += PGSIZE)
f0104027:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f010402d:	81 fb 00 f0 ff ff    	cmp    $0xfffff000,%ebx
f0104033:	75 c1                	jne    f0103ff6 <mem_init+0x1687>
f0104035:	c7 45 d0 00 00 bf ef 	movl   $0xefbf0000,-0x30(%ebp)

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f010403c:	89 f7                	mov    %esi,%edi
	// check IO mem (new in lab 4)
	for (i = IOMEMBASE; i < -PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, i) == i);

	// check IO mem (new in lab 4)
	for (i = IOMEMBASE; i < -PGSIZE; i += PGSIZE)
f010403e:	8b 55 cc             	mov    -0x34(%ebp),%edx
f0104041:	89 55 c8             	mov    %edx,-0x38(%ebp)
f0104044:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0104047:	81 c3 00 80 00 00    	add    $0x8000,%ebx
f010404d:	89 d6                	mov    %edx,%esi
f010404f:	81 c6 00 00 00 10    	add    $0x10000000,%esi
f0104055:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0104058:	81 c1 00 00 01 00    	add    $0x10000,%ecx
f010405e:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0104061:	89 da                	mov    %ebx,%edx
f0104063:	89 f8                	mov    %edi,%eax
f0104065:	e8 ca dc ff ff       	call   f0101d34 <check_va2pa>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010406a:	81 7d cc ff ff ff ef 	cmpl   $0xefffffff,-0x34(%ebp)
f0104071:	77 23                	ja     f0104096 <mem_init+0x1727>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0104073:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0104076:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010407a:	c7 44 24 08 9c 8d 10 	movl   $0xf0108d9c,0x8(%esp)
f0104081:	f0 
f0104082:	c7 44 24 04 08 04 00 	movl   $0x408,0x4(%esp)
f0104089:	00 
f010408a:	c7 04 24 66 95 10 f0 	movl   $0xf0109566,(%esp)
f0104091:	e8 ef bf ff ff       	call   f0100085 <_panic>
f0104096:	39 f0                	cmp    %esi,%eax
f0104098:	74 24                	je     f01040be <mem_init+0x174f>
f010409a:	c7 44 24 0c 30 9f 10 	movl   $0xf0109f30,0xc(%esp)
f01040a1:	f0 
f01040a2:	c7 44 24 08 8c 95 10 	movl   $0xf010958c,0x8(%esp)
f01040a9:	f0 
f01040aa:	c7 44 24 04 08 04 00 	movl   $0x408,0x4(%esp)
f01040b1:	00 
f01040b2:	c7 04 24 66 95 10 f0 	movl   $0xf0109566,(%esp)
f01040b9:	e8 c7 bf ff ff       	call   f0100085 <_panic>
f01040be:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01040c4:	8d b0 00 10 00 00    	lea    0x1000(%eax),%esi

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f01040ca:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f01040cd:	0f 85 d4 01 00 00    	jne    f01042a7 <mem_init+0x1938>
f01040d3:	bb 00 00 00 00       	mov    $0x0,%ebx
f01040d8:	8b 75 d0             	mov    -0x30(%ebp),%esi
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
f01040db:	8d 14 1e             	lea    (%esi,%ebx,1),%edx
f01040de:	89 f8                	mov    %edi,%eax
f01040e0:	e8 4f dc ff ff       	call   f0101d34 <check_va2pa>
f01040e5:	83 f8 ff             	cmp    $0xffffffff,%eax
f01040e8:	74 24                	je     f010410e <mem_init+0x179f>
f01040ea:	c7 44 24 0c 78 9f 10 	movl   $0xf0109f78,0xc(%esp)
f01040f1:	f0 
f01040f2:	c7 44 24 08 8c 95 10 	movl   $0xf010958c,0x8(%esp)
f01040f9:	f0 
f01040fa:	c7 44 24 04 0a 04 00 	movl   $0x40a,0x4(%esp)
f0104101:	00 
f0104102:	c7 04 24 66 95 10 f0 	movl   $0xf0109566,(%esp)
f0104109:	e8 77 bf ff ff       	call   f0100085 <_panic>
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
f010410e:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0104114:	81 fb 00 80 00 00    	cmp    $0x8000,%ebx
f010411a:	75 bf                	jne    f01040db <mem_init+0x176c>
f010411c:	81 6d d0 00 00 01 00 	subl   $0x10000,-0x30(%ebp)
f0104123:	81 45 cc 00 80 00 00 	addl   $0x8000,-0x34(%ebp)
		assert(check_va2pa(pgdir, i) == i);


	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
f010412a:	81 7d d0 00 00 b7 ef 	cmpl   $0xefb70000,-0x30(%ebp)
f0104131:	0f 85 07 ff ff ff    	jne    f010403e <mem_init+0x16cf>
f0104137:	89 fe                	mov    %edi,%esi
f0104139:	b8 00 00 00 00       	mov    $0x0,%eax
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
	}
	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f010413e:	8d 90 45 fc ff ff    	lea    -0x3bb(%eax),%edx
f0104144:	83 fa 03             	cmp    $0x3,%edx
f0104147:	77 2e                	ja     f0104177 <mem_init+0x1808>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
			assert(pgdir[i] & PTE_P);
f0104149:	f6 04 86 01          	testb  $0x1,(%esi,%eax,4)
f010414d:	0f 85 aa 00 00 00    	jne    f01041fd <mem_init+0x188e>
f0104153:	c7 44 24 0c 5e 98 10 	movl   $0xf010985e,0xc(%esp)
f010415a:	f0 
f010415b:	c7 44 24 08 8c 95 10 	movl   $0xf010958c,0x8(%esp)
f0104162:	f0 
f0104163:	c7 44 24 04 13 04 00 	movl   $0x413,0x4(%esp)
f010416a:	00 
f010416b:	c7 04 24 66 95 10 f0 	movl   $0xf0109566,(%esp)
f0104172:	e8 0e bf ff ff       	call   f0100085 <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f0104177:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f010417c:	76 55                	jbe    f01041d3 <mem_init+0x1864>
				assert(pgdir[i] & PTE_P);
f010417e:	8b 14 86             	mov    (%esi,%eax,4),%edx
f0104181:	f6 c2 01             	test   $0x1,%dl
f0104184:	75 24                	jne    f01041aa <mem_init+0x183b>
f0104186:	c7 44 24 0c 5e 98 10 	movl   $0xf010985e,0xc(%esp)
f010418d:	f0 
f010418e:	c7 44 24 08 8c 95 10 	movl   $0xf010958c,0x8(%esp)
f0104195:	f0 
f0104196:	c7 44 24 04 17 04 00 	movl   $0x417,0x4(%esp)
f010419d:	00 
f010419e:	c7 04 24 66 95 10 f0 	movl   $0xf0109566,(%esp)
f01041a5:	e8 db be ff ff       	call   f0100085 <_panic>
				assert(pgdir[i] & PTE_W);
f01041aa:	f6 c2 02             	test   $0x2,%dl
f01041ad:	75 4e                	jne    f01041fd <mem_init+0x188e>
f01041af:	c7 44 24 0c 6f 98 10 	movl   $0xf010986f,0xc(%esp)
f01041b6:	f0 
f01041b7:	c7 44 24 08 8c 95 10 	movl   $0xf010958c,0x8(%esp)
f01041be:	f0 
f01041bf:	c7 44 24 04 18 04 00 	movl   $0x418,0x4(%esp)
f01041c6:	00 
f01041c7:	c7 04 24 66 95 10 f0 	movl   $0xf0109566,(%esp)
f01041ce:	e8 b2 be ff ff       	call   f0100085 <_panic>
			} else
				assert(pgdir[i] == 0);
f01041d3:	83 3c 86 00          	cmpl   $0x0,(%esi,%eax,4)
f01041d7:	74 24                	je     f01041fd <mem_init+0x188e>
f01041d9:	c7 44 24 0c 80 98 10 	movl   $0xf0109880,0xc(%esp)
f01041e0:	f0 
f01041e1:	c7 44 24 08 8c 95 10 	movl   $0xf010958c,0x8(%esp)
f01041e8:	f0 
f01041e9:	c7 44 24 04 1a 04 00 	movl   $0x41a,0x4(%esp)
f01041f0:	00 
f01041f1:	c7 04 24 66 95 10 f0 	movl   $0xf0109566,(%esp)
f01041f8:	e8 88 be ff ff       	call   f0100085 <_panic>
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
	}
	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f01041fd:	83 c0 01             	add    $0x1,%eax
f0104200:	3d 00 04 00 00       	cmp    $0x400,%eax
f0104205:	0f 85 33 ff ff ff    	jne    f010413e <mem_init+0x17cf>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f010420b:	c7 04 24 9c 9f 10 f0 	movl   $0xf0109f9c,(%esp)
f0104212:	e8 f8 09 00 00       	call   f0104c0f <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f0104217:	a1 b8 3e 29 f0       	mov    0xf0293eb8,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010421c:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0104221:	77 20                	ja     f0104243 <mem_init+0x18d4>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0104223:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104227:	c7 44 24 08 9c 8d 10 	movl   $0xf0108d9c,0x8(%esp)
f010422e:	f0 
f010422f:	c7 44 24 04 f7 00 00 	movl   $0xf7,0x4(%esp)
f0104236:	00 
f0104237:	c7 04 24 66 95 10 f0 	movl   $0xf0109566,(%esp)
f010423e:	e8 42 be ff ff       	call   f0100085 <_panic>
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0104243:	8d 80 00 00 00 10    	lea    0x10000000(%eax),%eax
f0104249:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f010424c:	b8 00 00 00 00       	mov    $0x0,%eax
f0104251:	e8 44 db ff ff       	call   f0101d9a <check_page_free_list>

static __inline uint32_t
rcr0(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f0104256:	0f 20 c0             	mov    %cr0,%eax

	// entry.S set the really important flags in cr0 (including enabling
	// paging).  Here we configure the rest of the flags that we care about.
	cr0 = rcr0();
	cr0 |= CR0_PE|CR0_PG|CR0_AM|CR0_WP|CR0_NE|CR0_MP;
f0104259:	0d 23 00 05 80       	or     $0x80050023,%eax
}

static __inline void
lcr0(uint32_t val)
{
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f010425e:	83 e0 f3             	and    $0xfffffff3,%eax
f0104261:	0f 22 c0             	mov    %eax,%cr0
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
f0104264:	e8 31 e3 ff ff       	call   f010259a <check_page_installed_pgdir>
}
f0104269:	83 c4 3c             	add    $0x3c,%esp
f010426c:	5b                   	pop    %ebx
f010426d:	5e                   	pop    %esi
f010426e:	5f                   	pop    %edi
f010426f:	5d                   	pop    %ebp
f0104270:	c3                   	ret    
	//
	// LAB 4: Your code here:
        int i;
        for(i = 0;i<NCPU;i++){
          uint32_t kstacktop_i = KSTACKTOP - i*(KSTKSIZE+KSTKGAP);
          boot_map_region(kern_pgdir,kstacktop_i - KSTKSIZE , KSTKSIZE, PADDR(percpu_kstacks[i]),PTE_P | PTE_W);
f0104271:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f0104278:	00 
f0104279:	8b 45 cc             	mov    -0x34(%ebp),%eax
f010427c:	05 00 00 00 10       	add    $0x10000000,%eax
f0104281:	89 04 24             	mov    %eax,(%esp)
f0104284:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0104289:	ba 00 80 bf ef       	mov    $0xefbf8000,%edx
f010428e:	a1 b8 3e 29 f0       	mov    0xf0293eb8,%eax
f0104293:	e8 37 e2 ff ff       	call   f01024cf <boot_map_region>
f0104298:	bb 00 d0 29 f0       	mov    $0xf029d000,%ebx
f010429d:	be 00 80 be ef       	mov    $0xefbe8000,%esi
f01042a2:	e9 a6 fa ff ff       	jmp    f0103d4d <mem_init+0x13de>
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f01042a7:	89 da                	mov    %ebx,%edx
f01042a9:	89 f8                	mov    %edi,%eax
f01042ab:	e8 84 da ff ff       	call   f0101d34 <check_va2pa>
f01042b0:	e9 e1 fd ff ff       	jmp    f0104096 <mem_init+0x1727>
	...

f01042c0 <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f01042c0:	55                   	push   %ebp
f01042c1:	89 e5                	mov    %esp,%ebp
}

static __inline void
lgdt(void *p)
{
	__asm __volatile("lgdt (%0)" : : "r" (p));
f01042c3:	b8 68 83 12 f0       	mov    $0xf0128368,%eax
f01042c8:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" :: "a" (GD_UD|3));
f01042cb:	b8 23 00 00 00       	mov    $0x23,%eax
f01042d0:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" :: "a" (GD_UD|3));
f01042d2:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" :: "a" (GD_KD));
f01042d4:	b0 10                	mov    $0x10,%al
f01042d6:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" :: "a" (GD_KD));
f01042d8:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" :: "a" (GD_KD));
f01042da:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" :: "i" (GD_KT));
f01042dc:	ea e3 42 10 f0 08 00 	ljmp   $0x8,$0xf01042e3
}

static __inline void
lldt(uint16_t sel)
{
	__asm __volatile("lldt %0" : : "r" (sel));
f01042e3:	b0 00                	mov    $0x0,%al
f01042e5:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f01042e8:	5d                   	pop    %ebp
f01042e9:	c3                   	ret    

f01042ea <env_init>:
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f01042ea:	55                   	push   %ebp
f01042eb:	89 e5                	mov    %esp,%ebp
f01042ed:	8b 15 60 32 29 f0    	mov    0xf0293260,%edx
f01042f3:	b8 7c 0f 02 00       	mov    $0x20f7c,%eax
	// Set up envs array
	// LAB 3: Your code here.
        int i = NENV -1;
        for(i = NENV -1; i >= 0;i--){
           envs[i].env_id = 0;
f01042f8:	8b 0d 5c 32 29 f0    	mov    0xf029325c,%ecx
f01042fe:	c7 44 01 48 00 00 00 	movl   $0x0,0x48(%ecx,%eax,1)
f0104305:	00 
           envs[i].env_link = env_free_list;
f0104306:	8b 0d 5c 32 29 f0    	mov    0xf029325c,%ecx
f010430c:	89 54 01 44          	mov    %edx,0x44(%ecx,%eax,1)
           env_free_list = &envs[i];
f0104310:	89 c2                	mov    %eax,%edx
f0104312:	03 15 5c 32 29 f0    	add    0xf029325c,%edx
           envs[i].env_break = 0;
f0104318:	c7 42 60 00 00 00 00 	movl   $0x0,0x60(%edx)
f010431f:	2d 84 00 00 00       	sub    $0x84,%eax
env_init(void)
{
	// Set up envs array
	// LAB 3: Your code here.
        int i = NENV -1;
        for(i = NENV -1; i >= 0;i--){
f0104324:	3d 7c ff ff ff       	cmp    $0xffffff7c,%eax
f0104329:	75 cd                	jne    f01042f8 <env_init+0xe>
f010432b:	89 15 60 32 29 f0    	mov    %edx,0xf0293260
           envs[i].env_link = env_free_list;
           env_free_list = &envs[i];
           envs[i].env_break = 0;
        }      
	// Per-CPU part of the initialization
	env_init_percpu();
f0104331:	e8 8a ff ff ff       	call   f01042c0 <env_init_percpu>
}
f0104336:	5d                   	pop    %ebp
f0104337:	c3                   	ret    

f0104338 <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f0104338:	55                   	push   %ebp
f0104339:	89 e5                	mov    %esp,%ebp
f010433b:	83 ec 18             	sub    $0x18,%esp
f010433e:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0104341:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0104344:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0104347:	8b 45 08             	mov    0x8(%ebp),%eax
f010434a:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f010434d:	85 c0                	test   %eax,%eax
f010434f:	75 17                	jne    f0104368 <envid2env+0x30>
		*env_store = curenv;
f0104351:	e8 48 38 00 00       	call   f0107b9e <cpunum>
f0104356:	6b c0 74             	imul   $0x74,%eax,%eax
f0104359:	8b 80 28 40 29 f0    	mov    -0xfd6bfd8(%eax),%eax
f010435f:	89 06                	mov    %eax,(%esi)
f0104361:	b8 00 00 00 00       	mov    $0x0,%eax
		return 0;
f0104366:	eb 72                	jmp    f01043da <envid2env+0xa2>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f0104368:	89 c2                	mov    %eax,%edx
f010436a:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0104370:	89 d1                	mov    %edx,%ecx
f0104372:	c1 e1 07             	shl    $0x7,%ecx
f0104375:	8d 1c 91             	lea    (%ecx,%edx,4),%ebx
f0104378:	03 1d 5c 32 29 f0    	add    0xf029325c,%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f010437e:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f0104382:	74 05                	je     f0104389 <envid2env+0x51>
f0104384:	39 43 48             	cmp    %eax,0x48(%ebx)
f0104387:	74 0d                	je     f0104396 <envid2env+0x5e>
		*env_store = 0;
f0104389:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
f010438f:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
		return -E_BAD_ENV;
f0104394:	eb 44                	jmp    f01043da <envid2env+0xa2>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0104396:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f010439a:	74 37                	je     f01043d3 <envid2env+0x9b>
f010439c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01043a0:	e8 f9 37 00 00       	call   f0107b9e <cpunum>
f01043a5:	6b c0 74             	imul   $0x74,%eax,%eax
f01043a8:	39 98 28 40 29 f0    	cmp    %ebx,-0xfd6bfd8(%eax)
f01043ae:	74 23                	je     f01043d3 <envid2env+0x9b>
f01043b0:	8b 7b 4c             	mov    0x4c(%ebx),%edi
f01043b3:	e8 e6 37 00 00       	call   f0107b9e <cpunum>
f01043b8:	6b c0 74             	imul   $0x74,%eax,%eax
f01043bb:	8b 80 28 40 29 f0    	mov    -0xfd6bfd8(%eax),%eax
f01043c1:	3b 78 48             	cmp    0x48(%eax),%edi
f01043c4:	74 0d                	je     f01043d3 <envid2env+0x9b>
		*env_store = 0;
f01043c6:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
f01043cc:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
		return -E_BAD_ENV;
f01043d1:	eb 07                	jmp    f01043da <envid2env+0xa2>
	}

	*env_store = e;
f01043d3:	89 1e                	mov    %ebx,(%esi)
f01043d5:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
f01043da:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f01043dd:	8b 75 f8             	mov    -0x8(%ebp),%esi
f01043e0:	8b 7d fc             	mov    -0x4(%ebp),%edi
f01043e3:	89 ec                	mov    %ebp,%esp
f01043e5:	5d                   	pop    %ebp
f01043e6:	c3                   	ret    

f01043e7 <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f01043e7:	55                   	push   %ebp
f01043e8:	89 e5                	mov    %esp,%ebp
f01043ea:	53                   	push   %ebx
f01043eb:	83 ec 14             	sub    $0x14,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f01043ee:	e8 ab 37 00 00       	call   f0107b9e <cpunum>
f01043f3:	6b c0 74             	imul   $0x74,%eax,%eax
f01043f6:	8b 98 28 40 29 f0    	mov    -0xfd6bfd8(%eax),%ebx
f01043fc:	e8 9d 37 00 00       	call   f0107b9e <cpunum>
f0104401:	89 43 5c             	mov    %eax,0x5c(%ebx)

	__asm __volatile("movl %0,%%esp\n"
f0104404:	8b 65 08             	mov    0x8(%ebp),%esp
f0104407:	61                   	popa   
f0104408:	07                   	pop    %es
f0104409:	1f                   	pop    %ds
f010440a:	83 c4 08             	add    $0x8,%esp
f010440d:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f010440e:	c7 44 24 08 bb 9f 10 	movl   $0xf0109fbb,0x8(%esp)
f0104415:	f0 
f0104416:	c7 44 24 04 fb 01 00 	movl   $0x1fb,0x4(%esp)
f010441d:	00 
f010441e:	c7 04 24 c7 9f 10 f0 	movl   $0xf0109fc7,(%esp)
f0104425:	e8 5b bc ff ff       	call   f0100085 <_panic>

f010442a <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f010442a:	55                   	push   %ebp
f010442b:	89 e5                	mov    %esp,%ebp
f010442d:	53                   	push   %ebx
f010442e:	83 ec 14             	sub    $0x14,%esp
f0104431:	8b 5d 08             	mov    0x8(%ebp),%ebx
	//	e->env_tf.  Go back through the code you wrote above
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.
        if(e!= curenv){
f0104434:	e8 65 37 00 00       	call   f0107b9e <cpunum>
f0104439:	6b c0 74             	imul   $0x74,%eax,%eax
f010443c:	39 98 28 40 29 f0    	cmp    %ebx,-0xfd6bfd8(%eax)
f0104442:	0f 84 88 00 00 00    	je     f01044d0 <env_run+0xa6>
           if(curenv != NULL){
f0104448:	e8 51 37 00 00       	call   f0107b9e <cpunum>
f010444d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104450:	83 b8 28 40 29 f0 00 	cmpl   $0x0,-0xfd6bfd8(%eax)
f0104457:	74 29                	je     f0104482 <env_run+0x58>
               if(curenv->env_status == ENV_RUNNING)
f0104459:	e8 40 37 00 00       	call   f0107b9e <cpunum>
f010445e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104461:	8b 80 28 40 29 f0    	mov    -0xfd6bfd8(%eax),%eax
f0104467:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f010446b:	75 15                	jne    f0104482 <env_run+0x58>
                  curenv->env_status = ENV_RUNNABLE;
f010446d:	e8 2c 37 00 00       	call   f0107b9e <cpunum>
f0104472:	6b c0 74             	imul   $0x74,%eax,%eax
f0104475:	8b 80 28 40 29 f0    	mov    -0xfd6bfd8(%eax),%eax
f010447b:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
           }
           curenv = e;
f0104482:	e8 17 37 00 00       	call   f0107b9e <cpunum>
f0104487:	6b c0 74             	imul   $0x74,%eax,%eax
f010448a:	89 98 28 40 29 f0    	mov    %ebx,-0xfd6bfd8(%eax)
           e->env_status = ENV_RUNNING;
f0104490:	c7 43 54 03 00 00 00 	movl   $0x3,0x54(%ebx)
           e->env_runs++;
f0104497:	83 43 58 01          	addl   $0x1,0x58(%ebx)
           lcr3(PADDR(e->env_pgdir));
f010449b:	8b 43 64             	mov    0x64(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010449e:	89 c2                	mov    %eax,%edx
f01044a0:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01044a5:	77 20                	ja     f01044c7 <env_run+0x9d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01044a7:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01044ab:	c7 44 24 08 9c 8d 10 	movl   $0xf0108d9c,0x8(%esp)
f01044b2:	f0 
f01044b3:	c7 44 24 04 21 02 00 	movl   $0x221,0x4(%esp)
f01044ba:	00 
f01044bb:	c7 04 24 c7 9f 10 f0 	movl   $0xf0109fc7,(%esp)
f01044c2:	e8 be bb ff ff       	call   f0100085 <_panic>
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f01044c7:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f01044cd:	0f 22 da             	mov    %edx,%cr3
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f01044d0:	c7 04 24 80 83 12 f0 	movl   $0xf0128380,(%esp)
f01044d7:	e8 70 39 00 00       	call   f0107e4c <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f01044dc:	f3 90                	pause  
        }
        //print_trapframe(&e->env_tf);
        
        unlock_kernel(); 
        env_pop_tf(&e->env_tf);     
f01044de:	89 1c 24             	mov    %ebx,(%esp)
f01044e1:	e8 01 ff ff ff       	call   f01043e7 <env_pop_tf>

f01044e6 <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f01044e6:	55                   	push   %ebp
f01044e7:	89 e5                	mov    %esp,%ebp
f01044e9:	57                   	push   %edi
f01044ea:	56                   	push   %esi
f01044eb:	53                   	push   %ebx
f01044ec:	83 ec 2c             	sub    $0x2c,%esp
f01044ef:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f01044f2:	e8 a7 36 00 00       	call   f0107b9e <cpunum>
f01044f7:	6b c0 74             	imul   $0x74,%eax,%eax
f01044fa:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0104501:	39 b8 28 40 29 f0    	cmp    %edi,-0xfd6bfd8(%eax)
f0104507:	75 3c                	jne    f0104545 <env_free+0x5f>
		lcr3(PADDR(kern_pgdir));
f0104509:	a1 b8 3e 29 f0       	mov    0xf0293eb8,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010450e:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0104513:	77 20                	ja     f0104535 <env_free+0x4f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0104515:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104519:	c7 44 24 08 9c 8d 10 	movl   $0xf0108d9c,0x8(%esp)
f0104520:	f0 
f0104521:	c7 44 24 04 a8 01 00 	movl   $0x1a8,0x4(%esp)
f0104528:	00 
f0104529:	c7 04 24 c7 9f 10 f0 	movl   $0xf0109fc7,(%esp)
f0104530:	e8 50 bb ff ff       	call   f0100085 <_panic>
f0104535:	8d 80 00 00 00 10    	lea    0x10000000(%eax),%eax
f010453b:	0f 22 d8             	mov    %eax,%cr3
f010453e:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0104545:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104548:	c1 e0 02             	shl    $0x2,%eax
f010454b:	89 45 dc             	mov    %eax,-0x24(%ebp)
	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f010454e:	8b 47 64             	mov    0x64(%edi),%eax
f0104551:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0104554:	8b 34 10             	mov    (%eax,%edx,1),%esi
f0104557:	f7 c6 01 00 00 00    	test   $0x1,%esi
f010455d:	0f 84 b8 00 00 00    	je     f010461b <env_free+0x135>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0104563:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0104569:	89 f0                	mov    %esi,%eax
f010456b:	c1 e8 0c             	shr    $0xc,%eax
f010456e:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104571:	3b 05 b4 3e 29 f0    	cmp    0xf0293eb4,%eax
f0104577:	72 20                	jb     f0104599 <env_free+0xb3>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0104579:	89 74 24 0c          	mov    %esi,0xc(%esp)
f010457d:	c7 44 24 08 c0 8d 10 	movl   $0xf0108dc0,0x8(%esp)
f0104584:	f0 
f0104585:	c7 44 24 04 b7 01 00 	movl   $0x1b7,0x4(%esp)
f010458c:	00 
f010458d:	c7 04 24 c7 9f 10 f0 	movl   $0xf0109fc7,(%esp)
f0104594:	e8 ec ba ff ff       	call   f0100085 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0104599:	8b 55 e0             	mov    -0x20(%ebp),%edx
f010459c:	c1 e2 16             	shl    $0x16,%edx
f010459f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01045a2:	bb 00 00 00 00       	mov    $0x0,%ebx
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
f01045a7:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f01045ae:	01 
f01045af:	74 17                	je     f01045c8 <env_free+0xe2>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f01045b1:	89 d8                	mov    %ebx,%eax
f01045b3:	c1 e0 0c             	shl    $0xc,%eax
f01045b6:	0b 45 e4             	or     -0x1c(%ebp),%eax
f01045b9:	89 44 24 04          	mov    %eax,0x4(%esp)
f01045bd:	8b 47 64             	mov    0x64(%edi),%eax
f01045c0:	89 04 24             	mov    %eax,(%esp)
f01045c3:	e8 30 de ff ff       	call   f01023f8 <page_remove>
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f01045c8:	83 c3 01             	add    $0x1,%ebx
f01045cb:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f01045d1:	75 d4                	jne    f01045a7 <env_free+0xc1>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f01045d3:	8b 47 64             	mov    0x64(%edi),%eax
f01045d6:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01045d9:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01045e0:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01045e3:	3b 05 b4 3e 29 f0    	cmp    0xf0293eb4,%eax
f01045e9:	72 1c                	jb     f0104607 <env_free+0x121>
		panic("pa2page called with invalid pa");
f01045eb:	c7 44 24 08 c8 99 10 	movl   $0xf01099c8,0x8(%esp)
f01045f2:	f0 
f01045f3:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f01045fa:	00 
f01045fb:	c7 04 24 72 95 10 f0 	movl   $0xf0109572,(%esp)
f0104602:	e8 7e ba ff ff       	call   f0100085 <_panic>
		page_decref(pa2page(pa));
f0104607:	8b 45 d8             	mov    -0x28(%ebp),%eax
f010460a:	c1 e0 03             	shl    $0x3,%eax
f010460d:	03 05 bc 3e 29 f0    	add    0xf0293ebc,%eax
f0104613:	89 04 24             	mov    %eax,(%esp)
f0104616:	e8 e9 d0 ff ff       	call   f0101704 <page_decref>
	// Note the environment's demise.
	// cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f010461b:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
f010461f:	81 7d e0 bb 03 00 00 	cmpl   $0x3bb,-0x20(%ebp)
f0104626:	0f 85 19 ff ff ff    	jne    f0104545 <env_free+0x5f>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f010462c:	8b 47 64             	mov    0x64(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010462f:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0104634:	77 20                	ja     f0104656 <env_free+0x170>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0104636:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010463a:	c7 44 24 08 9c 8d 10 	movl   $0xf0108d9c,0x8(%esp)
f0104641:	f0 
f0104642:	c7 44 24 04 c5 01 00 	movl   $0x1c5,0x4(%esp)
f0104649:	00 
f010464a:	c7 04 24 c7 9f 10 f0 	movl   $0xf0109fc7,(%esp)
f0104651:	e8 2f ba ff ff       	call   f0100085 <_panic>
	e->env_pgdir = 0;
f0104656:	c7 47 64 00 00 00 00 	movl   $0x0,0x64(%edi)
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010465d:	8d 80 00 00 00 10    	lea    0x10000000(%eax),%eax
f0104663:	c1 e8 0c             	shr    $0xc,%eax
f0104666:	3b 05 b4 3e 29 f0    	cmp    0xf0293eb4,%eax
f010466c:	72 1c                	jb     f010468a <env_free+0x1a4>
		panic("pa2page called with invalid pa");
f010466e:	c7 44 24 08 c8 99 10 	movl   $0xf01099c8,0x8(%esp)
f0104675:	f0 
f0104676:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f010467d:	00 
f010467e:	c7 04 24 72 95 10 f0 	movl   $0xf0109572,(%esp)
f0104685:	e8 fb b9 ff ff       	call   f0100085 <_panic>
	page_decref(pa2page(pa));
f010468a:	c1 e0 03             	shl    $0x3,%eax
f010468d:	03 05 bc 3e 29 f0    	add    0xf0293ebc,%eax
f0104693:	89 04 24             	mov    %eax,(%esp)
f0104696:	e8 69 d0 ff ff       	call   f0101704 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f010469b:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f01046a2:	a1 60 32 29 f0       	mov    0xf0293260,%eax
f01046a7:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f01046aa:	89 3d 60 32 29 f0    	mov    %edi,0xf0293260
}
f01046b0:	83 c4 2c             	add    $0x2c,%esp
f01046b3:	5b                   	pop    %ebx
f01046b4:	5e                   	pop    %esi
f01046b5:	5f                   	pop    %edi
f01046b6:	5d                   	pop    %ebp
f01046b7:	c3                   	ret    

f01046b8 <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f01046b8:	55                   	push   %ebp
f01046b9:	89 e5                	mov    %esp,%ebp
f01046bb:	53                   	push   %ebx
f01046bc:	83 ec 14             	sub    $0x14,%esp
f01046bf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f01046c2:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f01046c6:	75 19                	jne    f01046e1 <env_destroy+0x29>
f01046c8:	e8 d1 34 00 00       	call   f0107b9e <cpunum>
f01046cd:	6b c0 74             	imul   $0x74,%eax,%eax
f01046d0:	39 98 28 40 29 f0    	cmp    %ebx,-0xfd6bfd8(%eax)
f01046d6:	74 09                	je     f01046e1 <env_destroy+0x29>
		e->env_status = ENV_DYING;
f01046d8:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f01046df:	eb 2f                	jmp    f0104710 <env_destroy+0x58>
	}

	env_free(e);
f01046e1:	89 1c 24             	mov    %ebx,(%esp)
f01046e4:	e8 fd fd ff ff       	call   f01044e6 <env_free>

	if (curenv == e) {
f01046e9:	e8 b0 34 00 00       	call   f0107b9e <cpunum>
f01046ee:	6b c0 74             	imul   $0x74,%eax,%eax
f01046f1:	39 98 28 40 29 f0    	cmp    %ebx,-0xfd6bfd8(%eax)
f01046f7:	75 17                	jne    f0104710 <env_destroy+0x58>
		curenv = NULL;
f01046f9:	e8 a0 34 00 00       	call   f0107b9e <cpunum>
f01046fe:	6b c0 74             	imul   $0x74,%eax,%eax
f0104701:	c7 80 28 40 29 f0 00 	movl   $0x0,-0xfd6bfd8(%eax)
f0104708:	00 00 00 
		sched_yield();
f010470b:	e8 80 13 00 00       	call   f0105a90 <sched_yield>
	}
}
f0104710:	83 c4 14             	add    $0x14,%esp
f0104713:	5b                   	pop    %ebx
f0104714:	5d                   	pop    %ebp
f0104715:	c3                   	ret    

f0104716 <env_alloc>:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f0104716:	55                   	push   %ebp
f0104717:	89 e5                	mov    %esp,%ebp
f0104719:	53                   	push   %ebx
f010471a:	83 ec 14             	sub    $0x14,%esp
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f010471d:	8b 1d 60 32 29 f0    	mov    0xf0293260,%ebx
f0104723:	ba fb ff ff ff       	mov    $0xfffffffb,%edx
f0104728:	85 db                	test   %ebx,%ebx
f010472a:	0f 84 66 01 00 00    	je     f0104896 <env_alloc+0x180>
{
	int i;
	struct Page *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f0104730:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0104737:	e8 03 da ff ff       	call   f010213f <page_alloc>
f010473c:	ba fc ff ff ff       	mov    $0xfffffffc,%edx
f0104741:	85 c0                	test   %eax,%eax
f0104743:	0f 84 4d 01 00 00    	je     f0104896 <env_alloc+0x180>


static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0104749:	89 c2                	mov    %eax,%edx
f010474b:	2b 15 bc 3e 29 f0    	sub    0xf0293ebc,%edx
f0104751:	c1 fa 03             	sar    $0x3,%edx
f0104754:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0104757:	89 d1                	mov    %edx,%ecx
f0104759:	c1 e9 0c             	shr    $0xc,%ecx
f010475c:	3b 0d b4 3e 29 f0    	cmp    0xf0293eb4,%ecx
f0104762:	72 20                	jb     f0104784 <env_alloc+0x6e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0104764:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0104768:	c7 44 24 08 c0 8d 10 	movl   $0xf0108dc0,0x8(%esp)
f010476f:	f0 
f0104770:	c7 44 24 04 59 00 00 	movl   $0x59,0x4(%esp)
f0104777:	00 
f0104778:	c7 04 24 72 95 10 f0 	movl   $0xf0109572,(%esp)
f010477f:	e8 01 b9 ff ff       	call   f0100085 <_panic>
	//	is an exception -- you need to increment env_pgdir's
	//	pp_ref for env_free to work correctly.
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.
        e->env_pgdir = (pde_t*)page2kva(p);
f0104784:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f010478a:	89 53 64             	mov    %edx,0x64(%ebx)
        p->pp_ref++;
f010478d:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
        memmove(e->env_pgdir,kern_pgdir,PGSIZE);
f0104792:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0104799:	00 
f010479a:	a1 b8 3e 29 f0       	mov    0xf0293eb8,%eax
f010479f:	89 44 24 04          	mov    %eax,0x4(%esp)
f01047a3:	8b 43 64             	mov    0x64(%ebx),%eax
f01047a6:	89 04 24             	mov    %eax,(%esp)
f01047a9:	e8 a7 2d 00 00       	call   f0107555 <memmove>
	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f01047ae:	8b 43 64             	mov    0x64(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01047b1:	89 c2                	mov    %eax,%edx
f01047b3:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01047b8:	77 20                	ja     f01047da <env_alloc+0xc4>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01047ba:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01047be:	c7 44 24 08 9c 8d 10 	movl   $0xf0108d9c,0x8(%esp)
f01047c5:	f0 
f01047c6:	c7 44 24 04 c4 00 00 	movl   $0xc4,0x4(%esp)
f01047cd:	00 
f01047ce:	c7 04 24 c7 9f 10 f0 	movl   $0xf0109fc7,(%esp)
f01047d5:	e8 ab b8 ff ff       	call   f0100085 <_panic>
f01047da:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f01047e0:	83 ca 05             	or     $0x5,%edx
f01047e3:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f01047e9:	8b 43 48             	mov    0x48(%ebx),%eax
f01047ec:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f01047f1:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f01047f6:	7f 05                	jg     f01047fd <env_alloc+0xe7>
f01047f8:	b8 00 10 00 00       	mov    $0x1000,%eax
		generation = 1 << ENVGENSHIFT;
	e->env_id = generation | (e - envs);
f01047fd:	89 da                	mov    %ebx,%edx
f01047ff:	2b 15 5c 32 29 f0    	sub    0xf029325c,%edx
f0104805:	c1 fa 02             	sar    $0x2,%edx
f0104808:	69 d2 e1 83 0f 3e    	imul   $0x3e0f83e1,%edx,%edx
f010480e:	09 d0                	or     %edx,%eax
f0104810:	89 43 48             	mov    %eax,0x48(%ebx)
        //cprintf("envs:%8x\n",e->env_id);
	// Set the basic status variables.
	e->env_parent_id = parent_id;
f0104813:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104816:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f0104819:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f0104820:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f0104827:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f010482e:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
f0104835:	00 
f0104836:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010483d:	00 
f010483e:	89 1c 24             	mov    %ebx,(%esp)
f0104841:	e8 b0 2c 00 00       	call   f01074f6 <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f0104846:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f010484c:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f0104852:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f0104858:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f010485f:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	// You will set e->env_tf.tf_eip later.
        e->env_prior = PRIOR_MIDD;
f0104865:	c7 83 80 00 00 00 02 	movl   $0x2,0x80(%ebx)
f010486c:	00 00 00 

	// Enable interrupts while in user mode.
	// LAB 4: Your code here.
        e->env_tf.tf_eflags |= FL_IF;
f010486f:	81 4b 38 00 02 00 00 	orl    $0x200,0x38(%ebx)
	// Clear the page fault handler until user installs one.
	e->env_pgfault_upcall = 0;
f0104876:	c7 43 68 00 00 00 00 	movl   $0x0,0x68(%ebx)

	// Also clear the IPC receiving flag.
	e->env_ipc_recving = 0;
f010487d:	c7 43 6c 00 00 00 00 	movl   $0x0,0x6c(%ebx)

	// commit the allocation
	env_free_list = e->env_link;
f0104884:	8b 43 44             	mov    0x44(%ebx),%eax
f0104887:	a3 60 32 29 f0       	mov    %eax,0xf0293260
	*newenv_store = e;
f010488c:	8b 45 08             	mov    0x8(%ebp),%eax
f010488f:	89 18                	mov    %ebx,(%eax)
f0104891:	ba 00 00 00 00       	mov    $0x0,%edx

	// cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f0104896:	89 d0                	mov    %edx,%eax
f0104898:	83 c4 14             	add    $0x14,%esp
f010489b:	5b                   	pop    %ebx
f010489c:	5d                   	pop    %ebp
f010489d:	c3                   	ret    

f010489e <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f010489e:	55                   	push   %ebp
f010489f:	89 e5                	mov    %esp,%ebp
f01048a1:	57                   	push   %edi
f01048a2:	56                   	push   %esi
f01048a3:	53                   	push   %ebx
f01048a4:	83 ec 1c             	sub    $0x1c,%esp
f01048a7:	89 c6                	mov    %eax,%esi
	//
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
        void* begin = ROUNDDOWN(va,PGSIZE);
f01048a9:	89 d3                	mov    %edx,%ebx
f01048ab:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
        void* end = ROUNDUP(va+len,PGSIZE);
f01048b1:	8d bc 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%edi
f01048b8:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
        while(begin < end){
f01048be:	39 fb                	cmp    %edi,%ebx
f01048c0:	73 51                	jae    f0104913 <region_alloc+0x75>
           struct Page* page = page_alloc(0);
f01048c2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01048c9:	e8 71 d8 ff ff       	call   f010213f <page_alloc>
           if(page == NULL)
f01048ce:	85 c0                	test   %eax,%eax
f01048d0:	75 1c                	jne    f01048ee <region_alloc+0x50>
               panic("page alloc failed\n");
f01048d2:	c7 44 24 08 d2 9f 10 	movl   $0xf0109fd2,0x8(%esp)
f01048d9:	f0 
f01048da:	c7 44 24 04 28 01 00 	movl   $0x128,0x4(%esp)
f01048e1:	00 
f01048e2:	c7 04 24 c7 9f 10 f0 	movl   $0xf0109fc7,(%esp)
f01048e9:	e8 97 b7 ff ff       	call   f0100085 <_panic>
           page_insert(e->env_pgdir,page,begin,PTE_U|PTE_W|PTE_P);
f01048ee:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
f01048f5:	00 
f01048f6:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01048fa:	89 44 24 04          	mov    %eax,0x4(%esp)
f01048fe:	8b 46 64             	mov    0x64(%esi),%eax
f0104901:	89 04 24             	mov    %eax,(%esp)
f0104904:	e8 4a db ff ff       	call   f0102453 <page_insert>
           begin += PGSIZE;
f0104909:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
        void* begin = ROUNDDOWN(va,PGSIZE);
        void* end = ROUNDUP(va+len,PGSIZE);
        while(begin < end){
f010490f:	39 df                	cmp    %ebx,%edi
f0104911:	77 af                	ja     f01048c2 <region_alloc+0x24>
           if(page == NULL)
               panic("page alloc failed\n");
           page_insert(e->env_pgdir,page,begin,PTE_U|PTE_W|PTE_P);
           begin += PGSIZE;
        }
}
f0104913:	83 c4 1c             	add    $0x1c,%esp
f0104916:	5b                   	pop    %ebx
f0104917:	5e                   	pop    %esi
f0104918:	5f                   	pop    %edi
f0104919:	5d                   	pop    %ebp
f010491a:	c3                   	ret    

f010491b <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, size_t size, enum EnvType type)
{
f010491b:	55                   	push   %ebp
f010491c:	89 e5                	mov    %esp,%ebp
f010491e:	57                   	push   %edi
f010491f:	56                   	push   %esi
f0104920:	53                   	push   %ebx
f0104921:	83 ec 3c             	sub    $0x3c,%esp
	// If this is the file server (type == ENV_TYPE_FS) give it I/O privileges.
	// LAB 5: Your code here.

        struct Env* newEnv;
        int r;
        r = env_alloc(&newEnv,0);
f0104924:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010492b:	00 
f010492c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010492f:	89 04 24             	mov    %eax,(%esp)
f0104932:	e8 df fd ff ff       	call   f0104716 <env_alloc>
        if(r < 0)
f0104937:	85 c0                	test   %eax,%eax
f0104939:	79 20                	jns    f010495b <env_create+0x40>
           panic("env_alloc: %e", r);
f010493b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010493f:	c7 44 24 08 e5 9f 10 	movl   $0xf0109fe5,0x8(%esp)
f0104946:	f0 
f0104947:	c7 44 24 04 92 01 00 	movl   $0x192,0x4(%esp)
f010494e:	00 
f010494f:	c7 04 24 c7 9f 10 f0 	movl   $0xf0109fc7,(%esp)
f0104956:	e8 2a b7 ff ff       	call   f0100085 <_panic>
        load_icode(newEnv,binary,size);
f010495b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
	//  You must also do something with the program's entry point,
	//  to make sure that the environment starts executing there.
	//  What?  (See env_run() and env_pop_tf() below.)

	// LAB 3: Your code here.
        struct Elf* elfhdr = (struct Elf*)binary;
f010495e:	8b 45 08             	mov    0x8(%ebp),%eax
f0104961:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        struct Proghdr *ph, *eph;
        if (elfhdr->e_magic != ELF_MAGIC)
f0104964:	81 38 7f 45 4c 46    	cmpl   $0x464c457f,(%eax)
f010496a:	74 1c                	je     f0104988 <env_create+0x6d>
		panic("Wrong ELF FILE\n");
f010496c:	c7 44 24 08 f3 9f 10 	movl   $0xf0109ff3,0x8(%esp)
f0104973:	f0 
f0104974:	c7 44 24 04 67 01 00 	movl   $0x167,0x4(%esp)
f010497b:	00 
f010497c:	c7 04 24 c7 9f 10 f0 	movl   $0xf0109fc7,(%esp)
f0104983:	e8 fd b6 ff ff       	call   f0100085 <_panic>
        ph = (struct Proghdr *) ((uint8_t *) elfhdr + elfhdr->e_phoff);
f0104988:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f010498b:	8b 5a 1c             	mov    0x1c(%edx),%ebx
        eph = ph + elfhdr->e_phnum;
f010498e:	0f b7 72 2c          	movzwl 0x2c(%edx),%esi

        lcr3(PADDR(e->env_pgdir));
f0104992:	8b 47 64             	mov    0x64(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0104995:	89 c2                	mov    %eax,%edx
f0104997:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010499c:	77 20                	ja     f01049be <env_create+0xa3>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010499e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01049a2:	c7 44 24 08 9c 8d 10 	movl   $0xf0108d9c,0x8(%esp)
f01049a9:	f0 
f01049aa:	c7 44 24 04 6b 01 00 	movl   $0x16b,0x4(%esp)
f01049b1:	00 
f01049b2:	c7 04 24 c7 9f 10 f0 	movl   $0xf0109fc7,(%esp)
f01049b9:	e8 c7 b6 ff ff       	call   f0100085 <_panic>
	// LAB 3: Your code here.
        struct Elf* elfhdr = (struct Elf*)binary;
        struct Proghdr *ph, *eph;
        if (elfhdr->e_magic != ELF_MAGIC)
		panic("Wrong ELF FILE\n");
        ph = (struct Proghdr *) ((uint8_t *) elfhdr + elfhdr->e_phoff);
f01049be:	03 5d d4             	add    -0x2c(%ebp),%ebx
        eph = ph + elfhdr->e_phnum;
f01049c1:	0f b7 f6             	movzwl %si,%esi
f01049c4:	c1 e6 05             	shl    $0x5,%esi
f01049c7:	8d 34 33             	lea    (%ebx,%esi,1),%esi
f01049ca:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f01049d0:	0f 22 da             	mov    %edx,%cr3

        lcr3(PADDR(e->env_pgdir));
        for (; ph < eph; ph++){
f01049d3:	39 f3                	cmp    %esi,%ebx
f01049d5:	73 5d                	jae    f0104a34 <env_create+0x119>
                if(ph->p_type == ELF_PROG_LOAD){
f01049d7:	83 3b 01             	cmpl   $0x1,(%ebx)
f01049da:	75 51                	jne    f0104a2d <env_create+0x112>
		   region_alloc(e,(void*)ph->p_va,ph->p_memsz);
f01049dc:	8b 4b 14             	mov    0x14(%ebx),%ecx
f01049df:	8b 53 08             	mov    0x8(%ebx),%edx
f01049e2:	89 f8                	mov    %edi,%eax
f01049e4:	e8 b5 fe ff ff       	call   f010489e <region_alloc>
                   memset((void*)ph->p_va,0,ph->p_memsz);
f01049e9:	8b 43 14             	mov    0x14(%ebx),%eax
f01049ec:	89 44 24 08          	mov    %eax,0x8(%esp)
f01049f0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01049f7:	00 
f01049f8:	8b 43 08             	mov    0x8(%ebx),%eax
f01049fb:	89 04 24             	mov    %eax,(%esp)
f01049fe:	e8 f3 2a 00 00       	call   f01074f6 <memset>
                   if(ph->p_va + ph->p_memsz > e->env_break)
f0104a03:	8b 43 14             	mov    0x14(%ebx),%eax
f0104a06:	03 43 08             	add    0x8(%ebx),%eax
f0104a09:	3b 47 60             	cmp    0x60(%edi),%eax
f0104a0c:	76 03                	jbe    f0104a11 <env_create+0xf6>
                      e->env_break = ph->p_va + ph->p_memsz;
f0104a0e:	89 47 60             	mov    %eax,0x60(%edi)
                   memmove((void*)ph->p_va,binary+ph->p_offset,ph->p_filesz);
f0104a11:	8b 43 10             	mov    0x10(%ebx),%eax
f0104a14:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104a18:	8b 45 08             	mov    0x8(%ebp),%eax
f0104a1b:	03 43 04             	add    0x4(%ebx),%eax
f0104a1e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104a22:	8b 43 08             	mov    0x8(%ebx),%eax
f0104a25:	89 04 24             	mov    %eax,(%esp)
f0104a28:	e8 28 2b 00 00       	call   f0107555 <memmove>
		panic("Wrong ELF FILE\n");
        ph = (struct Proghdr *) ((uint8_t *) elfhdr + elfhdr->e_phoff);
        eph = ph + elfhdr->e_phnum;

        lcr3(PADDR(e->env_pgdir));
        for (; ph < eph; ph++){
f0104a2d:	83 c3 20             	add    $0x20,%ebx
f0104a30:	39 de                	cmp    %ebx,%esi
f0104a32:	77 a3                	ja     f01049d7 <env_create+0xbc>
                   if(ph->p_va + ph->p_memsz > e->env_break)
                      e->env_break = ph->p_va + ph->p_memsz;
                   memmove((void*)ph->p_va,binary+ph->p_offset,ph->p_filesz);
                }
        }
        e->env_tf.tf_eip = elfhdr->e_entry;
f0104a34:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0104a37:	8b 42 18             	mov    0x18(%edx),%eax
f0104a3a:	89 47 30             	mov    %eax,0x30(%edi)
        lcr3(PADDR(kern_pgdir));
f0104a3d:	a1 b8 3e 29 f0       	mov    0xf0293eb8,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0104a42:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0104a47:	77 20                	ja     f0104a69 <env_create+0x14e>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0104a49:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104a4d:	c7 44 24 08 9c 8d 10 	movl   $0xf0108d9c,0x8(%esp)
f0104a54:	f0 
f0104a55:	c7 44 24 04 76 01 00 	movl   $0x176,0x4(%esp)
f0104a5c:	00 
f0104a5d:	c7 04 24 c7 9f 10 f0 	movl   $0xf0109fc7,(%esp)
f0104a64:	e8 1c b6 ff ff       	call   f0100085 <_panic>
f0104a69:	8d 80 00 00 00 10    	lea    0x10000000(%eax),%eax
f0104a6f:	0f 22 d8             	mov    %eax,%cr3
        
	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.
        region_alloc(e,(void*)(USTACKTOP-PGSIZE),PGSIZE);
f0104a72:	b9 00 10 00 00       	mov    $0x1000,%ecx
f0104a77:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f0104a7c:	89 f8                	mov    %edi,%eax
f0104a7e:	e8 1b fe ff ff       	call   f010489e <region_alloc>
        int r;
        r = env_alloc(&newEnv,0);
        if(r < 0)
           panic("env_alloc: %e", r);
        load_icode(newEnv,binary,size);
        newEnv->env_type = type;
f0104a83:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104a86:	8b 55 10             	mov    0x10(%ebp),%edx
f0104a89:	89 50 50             	mov    %edx,0x50(%eax)
        if(type == ENV_TYPE_FS)
f0104a8c:	83 fa 02             	cmp    $0x2,%edx
f0104a8f:	75 0a                	jne    f0104a9b <env_create+0x180>
           newEnv->env_tf.tf_eflags |= FL_IOPL_MASK;
f0104a91:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104a94:	81 48 38 00 30 00 00 	orl    $0x3000,0x38(%eax)

}
f0104a9b:	83 c4 3c             	add    $0x3c,%esp
f0104a9e:	5b                   	pop    %ebx
f0104a9f:	5e                   	pop    %esi
f0104aa0:	5f                   	pop    %edi
f0104aa1:	5d                   	pop    %ebp
f0104aa2:	c3                   	ret    
	...

f0104aa4 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0104aa4:	55                   	push   %ebp
f0104aa5:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0104aa7:	ba 70 00 00 00       	mov    $0x70,%edx
f0104aac:	8b 45 08             	mov    0x8(%ebp),%eax
f0104aaf:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0104ab0:	b2 71                	mov    $0x71,%dl
f0104ab2:	ec                   	in     (%dx),%al
f0104ab3:	0f b6 c0             	movzbl %al,%eax
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
}
f0104ab6:	5d                   	pop    %ebp
f0104ab7:	c3                   	ret    

f0104ab8 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0104ab8:	55                   	push   %ebp
f0104ab9:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0104abb:	ba 70 00 00 00       	mov    $0x70,%edx
f0104ac0:	8b 45 08             	mov    0x8(%ebp),%eax
f0104ac3:	ee                   	out    %al,(%dx)
f0104ac4:	b2 71                	mov    $0x71,%dl
f0104ac6:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104ac9:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0104aca:	5d                   	pop    %ebp
f0104acb:	c3                   	ret    

f0104acc <irq_eoi>:
	cprintf("\n");
}

void
irq_eoi(void)
{
f0104acc:	55                   	push   %ebp
f0104acd:	89 e5                	mov    %esp,%ebp
f0104acf:	ba 20 00 00 00       	mov    $0x20,%edx
f0104ad4:	b8 20 00 00 00       	mov    $0x20,%eax
f0104ad9:	ee                   	out    %al,(%dx)
f0104ada:	b2 a0                	mov    $0xa0,%dl
f0104adc:	ee                   	out    %al,(%dx)
	//   s: specific
	//   e: end-of-interrupt
	// xxx: specific interrupt line
	outb(IO_PIC1, 0x20);
	outb(IO_PIC2, 0x20);
}
f0104add:	5d                   	pop    %ebp
f0104ade:	c3                   	ret    

f0104adf <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f0104adf:	55                   	push   %ebp
f0104ae0:	89 e5                	mov    %esp,%ebp
f0104ae2:	56                   	push   %esi
f0104ae3:	53                   	push   %ebx
f0104ae4:	83 ec 10             	sub    $0x10,%esp
f0104ae7:	8b 45 08             	mov    0x8(%ebp),%eax
f0104aea:	89 c6                	mov    %eax,%esi
	int i;
	irq_mask_8259A = mask;
f0104aec:	66 a3 70 83 12 f0    	mov    %ax,0xf0128370
	if (!didinit)
f0104af2:	83 3d 64 32 29 f0 00 	cmpl   $0x0,0xf0293264
f0104af9:	74 4e                	je     f0104b49 <irq_setmask_8259A+0x6a>
f0104afb:	ba 21 00 00 00       	mov    $0x21,%edx
f0104b00:	ee                   	out    %al,(%dx)
f0104b01:	89 f0                	mov    %esi,%eax
f0104b03:	66 c1 e8 08          	shr    $0x8,%ax
f0104b07:	b2 a1                	mov    $0xa1,%dl
f0104b09:	ee                   	out    %al,(%dx)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
f0104b0a:	c7 04 24 03 a0 10 f0 	movl   $0xf010a003,(%esp)
f0104b11:	e8 f9 00 00 00       	call   f0104c0f <cprintf>
f0104b16:	bb 00 00 00 00       	mov    $0x0,%ebx
	for (i = 0; i < 16; i++)
		if (~mask & (1<<i))
f0104b1b:	0f b7 f6             	movzwl %si,%esi
f0104b1e:	f7 d6                	not    %esi
f0104b20:	0f a3 de             	bt     %ebx,%esi
f0104b23:	73 10                	jae    f0104b35 <irq_setmask_8259A+0x56>
			cprintf(" %d", i);
f0104b25:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0104b29:	c7 04 24 fc a4 10 f0 	movl   $0xf010a4fc,(%esp)
f0104b30:	e8 da 00 00 00       	call   f0104c0f <cprintf>
	if (!didinit)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
f0104b35:	83 c3 01             	add    $0x1,%ebx
f0104b38:	83 fb 10             	cmp    $0x10,%ebx
f0104b3b:	75 e3                	jne    f0104b20 <irq_setmask_8259A+0x41>
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
f0104b3d:	c7 04 24 19 92 10 f0 	movl   $0xf0109219,(%esp)
f0104b44:	e8 c6 00 00 00       	call   f0104c0f <cprintf>
}
f0104b49:	83 c4 10             	add    $0x10,%esp
f0104b4c:	5b                   	pop    %ebx
f0104b4d:	5e                   	pop    %esi
f0104b4e:	5d                   	pop    %ebp
f0104b4f:	c3                   	ret    

f0104b50 <pic_init>:
static bool didinit;

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
f0104b50:	55                   	push   %ebp
f0104b51:	89 e5                	mov    %esp,%ebp
f0104b53:	83 ec 18             	sub    $0x18,%esp
	didinit = 1;
f0104b56:	c7 05 64 32 29 f0 01 	movl   $0x1,0xf0293264
f0104b5d:	00 00 00 
f0104b60:	ba 21 00 00 00       	mov    $0x21,%edx
f0104b65:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104b6a:	ee                   	out    %al,(%dx)
f0104b6b:	b2 a1                	mov    $0xa1,%dl
f0104b6d:	ee                   	out    %al,(%dx)
f0104b6e:	b2 20                	mov    $0x20,%dl
f0104b70:	b8 11 00 00 00       	mov    $0x11,%eax
f0104b75:	ee                   	out    %al,(%dx)
f0104b76:	b2 21                	mov    $0x21,%dl
f0104b78:	b8 20 00 00 00       	mov    $0x20,%eax
f0104b7d:	ee                   	out    %al,(%dx)
f0104b7e:	b8 04 00 00 00       	mov    $0x4,%eax
f0104b83:	ee                   	out    %al,(%dx)
f0104b84:	b8 03 00 00 00       	mov    $0x3,%eax
f0104b89:	ee                   	out    %al,(%dx)
f0104b8a:	b2 a0                	mov    $0xa0,%dl
f0104b8c:	b8 11 00 00 00       	mov    $0x11,%eax
f0104b91:	ee                   	out    %al,(%dx)
f0104b92:	b2 a1                	mov    $0xa1,%dl
f0104b94:	b8 28 00 00 00       	mov    $0x28,%eax
f0104b99:	ee                   	out    %al,(%dx)
f0104b9a:	b8 02 00 00 00       	mov    $0x2,%eax
f0104b9f:	ee                   	out    %al,(%dx)
f0104ba0:	b8 01 00 00 00       	mov    $0x1,%eax
f0104ba5:	ee                   	out    %al,(%dx)
f0104ba6:	b2 20                	mov    $0x20,%dl
f0104ba8:	b8 68 00 00 00       	mov    $0x68,%eax
f0104bad:	ee                   	out    %al,(%dx)
f0104bae:	b8 0a 00 00 00       	mov    $0xa,%eax
f0104bb3:	ee                   	out    %al,(%dx)
f0104bb4:	b2 a0                	mov    $0xa0,%dl
f0104bb6:	b8 68 00 00 00       	mov    $0x68,%eax
f0104bbb:	ee                   	out    %al,(%dx)
f0104bbc:	b8 0a 00 00 00       	mov    $0xa,%eax
f0104bc1:	ee                   	out    %al,(%dx)
	outb(IO_PIC1, 0x0a);             /* read IRR by default */

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
f0104bc2:	0f b7 05 70 83 12 f0 	movzwl 0xf0128370,%eax
f0104bc9:	66 83 f8 ff          	cmp    $0xffffffff,%ax
f0104bcd:	74 0b                	je     f0104bda <pic_init+0x8a>
		irq_setmask_8259A(irq_mask_8259A);
f0104bcf:	0f b7 c0             	movzwl %ax,%eax
f0104bd2:	89 04 24             	mov    %eax,(%esp)
f0104bd5:	e8 05 ff ff ff       	call   f0104adf <irq_setmask_8259A>
}
f0104bda:	c9                   	leave  
f0104bdb:	c3                   	ret    

f0104bdc <vcprintf>:
	*cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
f0104bdc:	55                   	push   %ebp
f0104bdd:	89 e5                	mov    %esp,%ebp
f0104bdf:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f0104be2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0104be9:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104bec:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104bf0:	8b 45 08             	mov    0x8(%ebp),%eax
f0104bf3:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104bf7:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0104bfa:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104bfe:	c7 04 24 29 4c 10 f0 	movl   $0xf0104c29,(%esp)
f0104c05:	e8 02 1f 00 00       	call   f0106b0c <vprintfmt>
	return cnt;
}
f0104c0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104c0d:	c9                   	leave  
f0104c0e:	c3                   	ret    

f0104c0f <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0104c0f:	55                   	push   %ebp
f0104c10:	89 e5                	mov    %esp,%ebp
f0104c12:	83 ec 18             	sub    $0x18,%esp
	vprintfmt((void*)putch, &cnt, fmt, ap);
	return cnt;
}

int
cprintf(const char *fmt, ...)
f0104c15:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
f0104c18:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104c1c:	8b 45 08             	mov    0x8(%ebp),%eax
f0104c1f:	89 04 24             	mov    %eax,(%esp)
f0104c22:	e8 b5 ff ff ff       	call   f0104bdc <vcprintf>
	va_end(ap);

	return cnt;
}
f0104c27:	c9                   	leave  
f0104c28:	c3                   	ret    

f0104c29 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0104c29:	55                   	push   %ebp
f0104c2a:	89 e5                	mov    %esp,%ebp
f0104c2c:	83 ec 18             	sub    $0x18,%esp
	cputchar(ch);
f0104c2f:	8b 45 08             	mov    0x8(%ebp),%eax
f0104c32:	89 04 24             	mov    %eax,(%esp)
f0104c35:	e8 10 bb ff ff       	call   f010074a <cputchar>
	*cnt++;
}
f0104c3a:	c9                   	leave  
f0104c3b:	c3                   	ret    
f0104c3c:	00 00                	add    %al,(%eax)
	...

f0104c40 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0104c40:	55                   	push   %ebp
f0104c41:	89 e5                	mov    %esp,%ebp
f0104c43:	83 ec 18             	sub    $0x18,%esp
f0104c46:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0104c49:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0104c4c:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// get a triple fault.  If you set up an individual CPU's TSS
	// wrong, you may not get a fault until you try to return from
	// user space on that CPU.
	//
	// LAB 4: Your code here:
        uint32_t cpuid = cpunum();
f0104c4f:	e8 4a 2f 00 00       	call   f0107b9e <cpunum>
f0104c54:	89 c3                	mov    %eax,%ebx
}

static inline void 
wrmsr(unsigned msr, unsigned low, unsigned high)
{
        asm volatile("wrmsr" : : "c" (msr), "a"(low), "d" (high) : "memory");
f0104c56:	ba 00 00 00 00       	mov    $0x0,%edx
f0104c5b:	b8 08 00 00 00       	mov    $0x8,%eax
f0104c60:	b9 74 01 00 00       	mov    $0x174,%ecx
f0104c65:	0f 30                	wrmsr  

        extern void sysenter_handler();
	wrmsr(0x174, GD_KT, 0);
	wrmsr(0x175, KSTACKTOP - cpuid*(KSTKSIZE + KSTKGAP), 0);
f0104c67:	be c0 ef 00 00       	mov    $0xefc0,%esi
f0104c6c:	29 de                	sub    %ebx,%esi
f0104c6e:	c1 e6 10             	shl    $0x10,%esi
f0104c71:	b1 75                	mov    $0x75,%cl
f0104c73:	89 f0                	mov    %esi,%eax
f0104c75:	0f 30                	wrmsr  
f0104c77:	b8 42 5a 10 f0       	mov    $0xf0105a42,%eax
f0104c7c:	b1 76                	mov    $0x76,%cl
f0104c7e:	0f 30                	wrmsr  
	wrmsr(0x176, (uint32_t)&sysenter_handler, 0);

        struct Taskstate* cpu_ts = &thiscpu->cpu_ts;
f0104c80:	e8 19 2f 00 00       	call   f0107b9e <cpunum>
f0104c85:	6b c0 74             	imul   $0x74,%eax,%eax
f0104c88:	05 20 40 29 f0       	add    $0xf0294020,%eax
f0104c8d:	8d 78 0c             	lea    0xc(%eax),%edi
        cpu_ts->ts_esp0 = KSTACKTOP -cpuid*(KSTKSIZE +KSTKGAP);
f0104c90:	89 70 10             	mov    %esi,0x10(%eax)
        cpu_ts->ts_ss0 = GD_KD;
f0104c93:	66 c7 40 14 10 00    	movw   $0x10,0x14(%eax)
        gdt[(GD_TSS0 >> 3) + cpuid] = SEG16(STS_T32A, (uint32_t) (cpu_ts),
f0104c99:	8d 53 05             	lea    0x5(%ebx),%edx
f0104c9c:	b8 00 83 12 f0       	mov    $0xf0128300,%eax
f0104ca1:	66 c7 04 d0 68 00    	movw   $0x68,(%eax,%edx,8)
f0104ca7:	66 89 7c d0 02       	mov    %di,0x2(%eax,%edx,8)
f0104cac:	89 fe                	mov    %edi,%esi
f0104cae:	c1 ee 10             	shr    $0x10,%esi
f0104cb1:	89 f1                	mov    %esi,%ecx
f0104cb3:	88 4c d0 04          	mov    %cl,0x4(%eax,%edx,8)
f0104cb7:	c6 44 d0 06 40       	movb   $0x40,0x6(%eax,%edx,8)
f0104cbc:	89 f9                	mov    %edi,%ecx
f0104cbe:	c1 e9 18             	shr    $0x18,%ecx
f0104cc1:	88 4c d0 07          	mov    %cl,0x7(%eax,%edx,8)
					sizeof(struct Taskstate), 0);
	gdt[(GD_TSS0 >> 3) + cpuid].sd_s = 0;
f0104cc5:	c6 44 d0 05 89       	movb   $0x89,0x5(%eax,%edx,8)
}

static __inline void
ltr(uint16_t sel)
{
	__asm __volatile("ltr %0" : : "r" (sel));
f0104cca:	8d 1c dd 28 00 00 00 	lea    0x28(,%ebx,8),%ebx
f0104cd1:	0f 00 db             	ltr    %bx
}  

static __inline void
lidt(void *p)
{
	__asm __volatile("lidt (%0)" : : "r" (p));
f0104cd4:	b8 74 83 12 f0       	mov    $0xf0128374,%eax
f0104cd9:	0f 01 18             	lidtl  (%eax)
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0);

	// Load the IDT
	lidt(&idt_pd);*/
}
f0104cdc:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0104cdf:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0104ce2:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0104ce5:	89 ec                	mov    %ebp,%esp
f0104ce7:	5d                   	pop    %ebp
f0104ce8:	c3                   	ret    

f0104ce9 <trap_init>:
}


void
trap_init(void)
{
f0104ce9:	55                   	push   %ebp
f0104cea:	89 e5                	mov    %esp,%ebp
f0104cec:	83 ec 08             	sub    $0x8,%esp
        extern void handler_ide();
        extern void handler_irq15();


       
        SETGATE(idt[T_DIVIDE],0,GD_KT,handler_divide, 0);
f0104cef:	b8 24 59 10 f0       	mov    $0xf0105924,%eax
f0104cf4:	66 a3 80 32 29 f0    	mov    %ax,0xf0293280
f0104cfa:	66 c7 05 82 32 29 f0 	movw   $0x8,0xf0293282
f0104d01:	08 00 
f0104d03:	c6 05 84 32 29 f0 00 	movb   $0x0,0xf0293284
f0104d0a:	c6 05 85 32 29 f0 8e 	movb   $0x8e,0xf0293285
f0104d11:	c1 e8 10             	shr    $0x10,%eax
f0104d14:	66 a3 86 32 29 f0    	mov    %ax,0xf0293286
        SETGATE(idt[T_DEBUG],0,GD_KT,handler_debug, 0);
f0104d1a:	b8 2e 59 10 f0       	mov    $0xf010592e,%eax
f0104d1f:	66 a3 88 32 29 f0    	mov    %ax,0xf0293288
f0104d25:	66 c7 05 8a 32 29 f0 	movw   $0x8,0xf029328a
f0104d2c:	08 00 
f0104d2e:	c6 05 8c 32 29 f0 00 	movb   $0x0,0xf029328c
f0104d35:	c6 05 8d 32 29 f0 8e 	movb   $0x8e,0xf029328d
f0104d3c:	c1 e8 10             	shr    $0x10,%eax
f0104d3f:	66 a3 8e 32 29 f0    	mov    %ax,0xf029328e
        SETGATE(idt[T_NMI],0,GD_KT,handler_nmi, 0);
f0104d45:	b8 38 59 10 f0       	mov    $0xf0105938,%eax
f0104d4a:	66 a3 90 32 29 f0    	mov    %ax,0xf0293290
f0104d50:	66 c7 05 92 32 29 f0 	movw   $0x8,0xf0293292
f0104d57:	08 00 
f0104d59:	c6 05 94 32 29 f0 00 	movb   $0x0,0xf0293294
f0104d60:	c6 05 95 32 29 f0 8e 	movb   $0x8e,0xf0293295
f0104d67:	c1 e8 10             	shr    $0x10,%eax
f0104d6a:	66 a3 96 32 29 f0    	mov    %ax,0xf0293296
        SETGATE(idt[T_BRKPT],0,GD_KT,handler_brkpt, 3);
f0104d70:	b8 42 59 10 f0       	mov    $0xf0105942,%eax
f0104d75:	66 a3 98 32 29 f0    	mov    %ax,0xf0293298
f0104d7b:	66 c7 05 9a 32 29 f0 	movw   $0x8,0xf029329a
f0104d82:	08 00 
f0104d84:	c6 05 9c 32 29 f0 00 	movb   $0x0,0xf029329c
f0104d8b:	c6 05 9d 32 29 f0 ee 	movb   $0xee,0xf029329d
f0104d92:	c1 e8 10             	shr    $0x10,%eax
f0104d95:	66 a3 9e 32 29 f0    	mov    %ax,0xf029329e
        SETGATE(idt[T_OFLOW],0,GD_KT,handler_oflow, 0);
f0104d9b:	b8 4c 59 10 f0       	mov    $0xf010594c,%eax
f0104da0:	66 a3 a0 32 29 f0    	mov    %ax,0xf02932a0
f0104da6:	66 c7 05 a2 32 29 f0 	movw   $0x8,0xf02932a2
f0104dad:	08 00 
f0104daf:	c6 05 a4 32 29 f0 00 	movb   $0x0,0xf02932a4
f0104db6:	c6 05 a5 32 29 f0 8e 	movb   $0x8e,0xf02932a5
f0104dbd:	c1 e8 10             	shr    $0x10,%eax
f0104dc0:	66 a3 a6 32 29 f0    	mov    %ax,0xf02932a6
        SETGATE(idt[T_BOUND],0,GD_KT,handler_bound, 0);
f0104dc6:	b8 56 59 10 f0       	mov    $0xf0105956,%eax
f0104dcb:	66 a3 a8 32 29 f0    	mov    %ax,0xf02932a8
f0104dd1:	66 c7 05 aa 32 29 f0 	movw   $0x8,0xf02932aa
f0104dd8:	08 00 
f0104dda:	c6 05 ac 32 29 f0 00 	movb   $0x0,0xf02932ac
f0104de1:	c6 05 ad 32 29 f0 8e 	movb   $0x8e,0xf02932ad
f0104de8:	c1 e8 10             	shr    $0x10,%eax
f0104deb:	66 a3 ae 32 29 f0    	mov    %ax,0xf02932ae
        SETGATE(idt[T_ILLOP],0,GD_KT,handler_illop, 0);
f0104df1:	b8 60 59 10 f0       	mov    $0xf0105960,%eax
f0104df6:	66 a3 b0 32 29 f0    	mov    %ax,0xf02932b0
f0104dfc:	66 c7 05 b2 32 29 f0 	movw   $0x8,0xf02932b2
f0104e03:	08 00 
f0104e05:	c6 05 b4 32 29 f0 00 	movb   $0x0,0xf02932b4
f0104e0c:	c6 05 b5 32 29 f0 8e 	movb   $0x8e,0xf02932b5
f0104e13:	c1 e8 10             	shr    $0x10,%eax
f0104e16:	66 a3 b6 32 29 f0    	mov    %ax,0xf02932b6
        SETGATE(idt[T_DEVICE],0,GD_KT,handler_device, 0);
f0104e1c:	b8 6a 59 10 f0       	mov    $0xf010596a,%eax
f0104e21:	66 a3 b8 32 29 f0    	mov    %ax,0xf02932b8
f0104e27:	66 c7 05 ba 32 29 f0 	movw   $0x8,0xf02932ba
f0104e2e:	08 00 
f0104e30:	c6 05 bc 32 29 f0 00 	movb   $0x0,0xf02932bc
f0104e37:	c6 05 bd 32 29 f0 8e 	movb   $0x8e,0xf02932bd
f0104e3e:	c1 e8 10             	shr    $0x10,%eax
f0104e41:	66 a3 be 32 29 f0    	mov    %ax,0xf02932be
        SETGATE(idt[T_DBLFLT],0,GD_KT,handler_dblflt, 0);
f0104e47:	b8 74 59 10 f0       	mov    $0xf0105974,%eax
f0104e4c:	66 a3 c0 32 29 f0    	mov    %ax,0xf02932c0
f0104e52:	66 c7 05 c2 32 29 f0 	movw   $0x8,0xf02932c2
f0104e59:	08 00 
f0104e5b:	c6 05 c4 32 29 f0 00 	movb   $0x0,0xf02932c4
f0104e62:	c6 05 c5 32 29 f0 8e 	movb   $0x8e,0xf02932c5
f0104e69:	c1 e8 10             	shr    $0x10,%eax
f0104e6c:	66 a3 c6 32 29 f0    	mov    %ax,0xf02932c6
        SETGATE(idt[T_TSS],0,GD_KT,handler_tss, 0);
f0104e72:	b8 7c 59 10 f0       	mov    $0xf010597c,%eax
f0104e77:	66 a3 d0 32 29 f0    	mov    %ax,0xf02932d0
f0104e7d:	66 c7 05 d2 32 29 f0 	movw   $0x8,0xf02932d2
f0104e84:	08 00 
f0104e86:	c6 05 d4 32 29 f0 00 	movb   $0x0,0xf02932d4
f0104e8d:	c6 05 d5 32 29 f0 8e 	movb   $0x8e,0xf02932d5
f0104e94:	c1 e8 10             	shr    $0x10,%eax
f0104e97:	66 a3 d6 32 29 f0    	mov    %ax,0xf02932d6
        SETGATE(idt[T_SEGNP],0,GD_KT,handler_segnp, 0);
f0104e9d:	b8 84 59 10 f0       	mov    $0xf0105984,%eax
f0104ea2:	66 a3 d8 32 29 f0    	mov    %ax,0xf02932d8
f0104ea8:	66 c7 05 da 32 29 f0 	movw   $0x8,0xf02932da
f0104eaf:	08 00 
f0104eb1:	c6 05 dc 32 29 f0 00 	movb   $0x0,0xf02932dc
f0104eb8:	c6 05 dd 32 29 f0 8e 	movb   $0x8e,0xf02932dd
f0104ebf:	c1 e8 10             	shr    $0x10,%eax
f0104ec2:	66 a3 de 32 29 f0    	mov    %ax,0xf02932de
        SETGATE(idt[T_STACK],0,GD_KT,handler_stack, 0);
f0104ec8:	b8 8c 59 10 f0       	mov    $0xf010598c,%eax
f0104ecd:	66 a3 e0 32 29 f0    	mov    %ax,0xf02932e0
f0104ed3:	66 c7 05 e2 32 29 f0 	movw   $0x8,0xf02932e2
f0104eda:	08 00 
f0104edc:	c6 05 e4 32 29 f0 00 	movb   $0x0,0xf02932e4
f0104ee3:	c6 05 e5 32 29 f0 8e 	movb   $0x8e,0xf02932e5
f0104eea:	c1 e8 10             	shr    $0x10,%eax
f0104eed:	66 a3 e6 32 29 f0    	mov    %ax,0xf02932e6
        SETGATE(idt[T_GPFLT],0,GD_KT,handler_gpflt, 0);
f0104ef3:	b8 94 59 10 f0       	mov    $0xf0105994,%eax
f0104ef8:	66 a3 e8 32 29 f0    	mov    %ax,0xf02932e8
f0104efe:	66 c7 05 ea 32 29 f0 	movw   $0x8,0xf02932ea
f0104f05:	08 00 
f0104f07:	c6 05 ec 32 29 f0 00 	movb   $0x0,0xf02932ec
f0104f0e:	c6 05 ed 32 29 f0 8e 	movb   $0x8e,0xf02932ed
f0104f15:	c1 e8 10             	shr    $0x10,%eax
f0104f18:	66 a3 ee 32 29 f0    	mov    %ax,0xf02932ee
        SETGATE(idt[T_PGFLT],0,GD_KT,handler_pgflt, 0);
f0104f1e:	b8 9c 59 10 f0       	mov    $0xf010599c,%eax
f0104f23:	66 a3 f0 32 29 f0    	mov    %ax,0xf02932f0
f0104f29:	66 c7 05 f2 32 29 f0 	movw   $0x8,0xf02932f2
f0104f30:	08 00 
f0104f32:	c6 05 f4 32 29 f0 00 	movb   $0x0,0xf02932f4
f0104f39:	c6 05 f5 32 29 f0 8e 	movb   $0x8e,0xf02932f5
f0104f40:	c1 e8 10             	shr    $0x10,%eax
f0104f43:	66 a3 f6 32 29 f0    	mov    %ax,0xf02932f6
        SETGATE(idt[T_FPERR],0,GD_KT,handler_fperr, 0);
f0104f49:	b8 a4 59 10 f0       	mov    $0xf01059a4,%eax
f0104f4e:	66 a3 00 33 29 f0    	mov    %ax,0xf0293300
f0104f54:	66 c7 05 02 33 29 f0 	movw   $0x8,0xf0293302
f0104f5b:	08 00 
f0104f5d:	c6 05 04 33 29 f0 00 	movb   $0x0,0xf0293304
f0104f64:	c6 05 05 33 29 f0 8e 	movb   $0x8e,0xf0293305
f0104f6b:	c1 e8 10             	shr    $0x10,%eax
f0104f6e:	66 a3 06 33 29 f0    	mov    %ax,0xf0293306
        SETGATE(idt[T_ALIGN],0,GD_KT,handler_align, 0);
f0104f74:	b8 ae 59 10 f0       	mov    $0xf01059ae,%eax
f0104f79:	66 a3 08 33 29 f0    	mov    %ax,0xf0293308
f0104f7f:	66 c7 05 0a 33 29 f0 	movw   $0x8,0xf029330a
f0104f86:	08 00 
f0104f88:	c6 05 0c 33 29 f0 00 	movb   $0x0,0xf029330c
f0104f8f:	c6 05 0d 33 29 f0 8e 	movb   $0x8e,0xf029330d
f0104f96:	c1 e8 10             	shr    $0x10,%eax
f0104f99:	66 a3 0e 33 29 f0    	mov    %ax,0xf029330e
        SETGATE(idt[T_MCHK],0,GD_KT,handler_mchk, 0);
f0104f9f:	b8 b8 59 10 f0       	mov    $0xf01059b8,%eax
f0104fa4:	66 a3 10 33 29 f0    	mov    %ax,0xf0293310
f0104faa:	66 c7 05 12 33 29 f0 	movw   $0x8,0xf0293312
f0104fb1:	08 00 
f0104fb3:	c6 05 14 33 29 f0 00 	movb   $0x0,0xf0293314
f0104fba:	c6 05 15 33 29 f0 8e 	movb   $0x8e,0xf0293315
f0104fc1:	c1 e8 10             	shr    $0x10,%eax
f0104fc4:	66 a3 16 33 29 f0    	mov    %ax,0xf0293316
        SETGATE(idt[T_SIMDERR],0,GD_KT,handler_simderr, 0);
f0104fca:	b8 c2 59 10 f0       	mov    $0xf01059c2,%eax
f0104fcf:	66 a3 18 33 29 f0    	mov    %ax,0xf0293318
f0104fd5:	66 c7 05 1a 33 29 f0 	movw   $0x8,0xf029331a
f0104fdc:	08 00 
f0104fde:	c6 05 1c 33 29 f0 00 	movb   $0x0,0xf029331c
f0104fe5:	c6 05 1d 33 29 f0 8e 	movb   $0x8e,0xf029331d
f0104fec:	c1 e8 10             	shr    $0x10,%eax
f0104fef:	66 a3 1e 33 29 f0    	mov    %ax,0xf029331e

        SETGATE(idt[T_SYSCALL], 0, GD_KT, handler_syscall, 3);
f0104ff5:	b8 cc 59 10 f0       	mov    $0xf01059cc,%eax
f0104ffa:	66 a3 00 34 29 f0    	mov    %ax,0xf0293400
f0105000:	66 c7 05 02 34 29 f0 	movw   $0x8,0xf0293402
f0105007:	08 00 
f0105009:	c6 05 04 34 29 f0 00 	movb   $0x0,0xf0293404
f0105010:	c6 05 05 34 29 f0 ee 	movb   $0xee,0xf0293405
f0105017:	c1 e8 10             	shr    $0x10,%eax
f010501a:	66 a3 06 34 29 f0    	mov    %ax,0xf0293406
        SETGATE(idt[IRQ_OFFSET + IRQ_TIMER], 0, GD_KT, handler_timer, 0);
f0105020:	b8 d6 59 10 f0       	mov    $0xf01059d6,%eax
f0105025:	66 a3 80 33 29 f0    	mov    %ax,0xf0293380
f010502b:	66 c7 05 82 33 29 f0 	movw   $0x8,0xf0293382
f0105032:	08 00 
f0105034:	c6 05 84 33 29 f0 00 	movb   $0x0,0xf0293384
f010503b:	c6 05 85 33 29 f0 8e 	movb   $0x8e,0xf0293385
f0105042:	c1 e8 10             	shr    $0x10,%eax
f0105045:	66 a3 86 33 29 f0    	mov    %ax,0xf0293386
        SETGATE(idt[IRQ_OFFSET + IRQ_KBD], 0, GD_KT, handler_kbd, 0);
f010504b:	b8 e0 59 10 f0       	mov    $0xf01059e0,%eax
f0105050:	66 a3 88 33 29 f0    	mov    %ax,0xf0293388
f0105056:	66 c7 05 8a 33 29 f0 	movw   $0x8,0xf029338a
f010505d:	08 00 
f010505f:	c6 05 8c 33 29 f0 00 	movb   $0x0,0xf029338c
f0105066:	c6 05 8d 33 29 f0 8e 	movb   $0x8e,0xf029338d
f010506d:	c1 e8 10             	shr    $0x10,%eax
f0105070:	66 a3 8e 33 29 f0    	mov    %ax,0xf029338e
        SETGATE(idt[IRQ_OFFSET + 2], 0, GD_KT, handler_irq2, 0);
f0105076:	b8 ea 59 10 f0       	mov    $0xf01059ea,%eax
f010507b:	66 a3 90 33 29 f0    	mov    %ax,0xf0293390
f0105081:	66 c7 05 92 33 29 f0 	movw   $0x8,0xf0293392
f0105088:	08 00 
f010508a:	c6 05 94 33 29 f0 00 	movb   $0x0,0xf0293394
f0105091:	c6 05 95 33 29 f0 8e 	movb   $0x8e,0xf0293395
f0105098:	c1 e8 10             	shr    $0x10,%eax
f010509b:	66 a3 96 33 29 f0    	mov    %ax,0xf0293396
        SETGATE(idt[IRQ_OFFSET + 3], 0, GD_KT, handler_irq3, 0);
f01050a1:	b8 f4 59 10 f0       	mov    $0xf01059f4,%eax
f01050a6:	66 a3 98 33 29 f0    	mov    %ax,0xf0293398
f01050ac:	66 c7 05 9a 33 29 f0 	movw   $0x8,0xf029339a
f01050b3:	08 00 
f01050b5:	c6 05 9c 33 29 f0 00 	movb   $0x0,0xf029339c
f01050bc:	c6 05 9d 33 29 f0 8e 	movb   $0x8e,0xf029339d
f01050c3:	c1 e8 10             	shr    $0x10,%eax
f01050c6:	66 a3 9e 33 29 f0    	mov    %ax,0xf029339e
        SETGATE(idt[IRQ_OFFSET + IRQ_SERIAL], 0, GD_KT, handler_serial, 0);
f01050cc:	b8 fa 59 10 f0       	mov    $0xf01059fa,%eax
f01050d1:	66 a3 a0 33 29 f0    	mov    %ax,0xf02933a0
f01050d7:	66 c7 05 a2 33 29 f0 	movw   $0x8,0xf02933a2
f01050de:	08 00 
f01050e0:	c6 05 a4 33 29 f0 00 	movb   $0x0,0xf02933a4
f01050e7:	c6 05 a5 33 29 f0 8e 	movb   $0x8e,0xf02933a5
f01050ee:	c1 e8 10             	shr    $0x10,%eax
f01050f1:	66 a3 a6 33 29 f0    	mov    %ax,0xf02933a6
        SETGATE(idt[IRQ_OFFSET + 5], 0, GD_KT, handler_irq5, 0);
f01050f7:	b8 00 5a 10 f0       	mov    $0xf0105a00,%eax
f01050fc:	66 a3 a8 33 29 f0    	mov    %ax,0xf02933a8
f0105102:	66 c7 05 aa 33 29 f0 	movw   $0x8,0xf02933aa
f0105109:	08 00 
f010510b:	c6 05 ac 33 29 f0 00 	movb   $0x0,0xf02933ac
f0105112:	c6 05 ad 33 29 f0 8e 	movb   $0x8e,0xf02933ad
f0105119:	c1 e8 10             	shr    $0x10,%eax
f010511c:	66 a3 ae 33 29 f0    	mov    %ax,0xf02933ae
        SETGATE(idt[IRQ_OFFSET + 6], 0, GD_KT, handler_irq6, 0);
f0105122:	b8 06 5a 10 f0       	mov    $0xf0105a06,%eax
f0105127:	66 a3 b0 33 29 f0    	mov    %ax,0xf02933b0
f010512d:	66 c7 05 b2 33 29 f0 	movw   $0x8,0xf02933b2
f0105134:	08 00 
f0105136:	c6 05 b4 33 29 f0 00 	movb   $0x0,0xf02933b4
f010513d:	c6 05 b5 33 29 f0 8e 	movb   $0x8e,0xf02933b5
f0105144:	c1 e8 10             	shr    $0x10,%eax
f0105147:	66 a3 b6 33 29 f0    	mov    %ax,0xf02933b6
        SETGATE(idt[IRQ_OFFSET + IRQ_SPURIOUS], 0, GD_KT, handler_spurious, 0);
f010514d:	b8 0c 5a 10 f0       	mov    $0xf0105a0c,%eax
f0105152:	66 a3 b8 33 29 f0    	mov    %ax,0xf02933b8
f0105158:	66 c7 05 ba 33 29 f0 	movw   $0x8,0xf02933ba
f010515f:	08 00 
f0105161:	c6 05 bc 33 29 f0 00 	movb   $0x0,0xf02933bc
f0105168:	c6 05 bd 33 29 f0 8e 	movb   $0x8e,0xf02933bd
f010516f:	c1 e8 10             	shr    $0x10,%eax
f0105172:	66 a3 be 33 29 f0    	mov    %ax,0xf02933be
        SETGATE(idt[IRQ_OFFSET + 8], 0, GD_KT, handler_irq8, 0);
f0105178:	b8 12 5a 10 f0       	mov    $0xf0105a12,%eax
f010517d:	66 a3 c0 33 29 f0    	mov    %ax,0xf02933c0
f0105183:	66 c7 05 c2 33 29 f0 	movw   $0x8,0xf02933c2
f010518a:	08 00 
f010518c:	c6 05 c4 33 29 f0 00 	movb   $0x0,0xf02933c4
f0105193:	c6 05 c5 33 29 f0 8e 	movb   $0x8e,0xf02933c5
f010519a:	c1 e8 10             	shr    $0x10,%eax
f010519d:	66 a3 c6 33 29 f0    	mov    %ax,0xf02933c6
        SETGATE(idt[IRQ_OFFSET + 9], 0, GD_KT, handler_irq9, 0);
f01051a3:	b8 18 5a 10 f0       	mov    $0xf0105a18,%eax
f01051a8:	66 a3 c8 33 29 f0    	mov    %ax,0xf02933c8
f01051ae:	66 c7 05 ca 33 29 f0 	movw   $0x8,0xf02933ca
f01051b5:	08 00 
f01051b7:	c6 05 cc 33 29 f0 00 	movb   $0x0,0xf02933cc
f01051be:	c6 05 cd 33 29 f0 8e 	movb   $0x8e,0xf02933cd
f01051c5:	c1 e8 10             	shr    $0x10,%eax
f01051c8:	66 a3 ce 33 29 f0    	mov    %ax,0xf02933ce
        SETGATE(idt[IRQ_OFFSET + 10], 0, GD_KT, handler_irq10, 0);
f01051ce:	b8 1e 5a 10 f0       	mov    $0xf0105a1e,%eax
f01051d3:	66 a3 d0 33 29 f0    	mov    %ax,0xf02933d0
f01051d9:	66 c7 05 d2 33 29 f0 	movw   $0x8,0xf02933d2
f01051e0:	08 00 
f01051e2:	c6 05 d4 33 29 f0 00 	movb   $0x0,0xf02933d4
f01051e9:	c6 05 d5 33 29 f0 8e 	movb   $0x8e,0xf02933d5
f01051f0:	c1 e8 10             	shr    $0x10,%eax
f01051f3:	66 a3 d6 33 29 f0    	mov    %ax,0xf02933d6
        SETGATE(idt[IRQ_OFFSET + 11], 0, GD_KT, handler_irq11, 0);
f01051f9:	b8 24 5a 10 f0       	mov    $0xf0105a24,%eax
f01051fe:	66 a3 d8 33 29 f0    	mov    %ax,0xf02933d8
f0105204:	66 c7 05 da 33 29 f0 	movw   $0x8,0xf02933da
f010520b:	08 00 
f010520d:	c6 05 dc 33 29 f0 00 	movb   $0x0,0xf02933dc
f0105214:	c6 05 dd 33 29 f0 8e 	movb   $0x8e,0xf02933dd
f010521b:	c1 e8 10             	shr    $0x10,%eax
f010521e:	66 a3 de 33 29 f0    	mov    %ax,0xf02933de
        SETGATE(idt[IRQ_OFFSET + 12], 0, GD_KT, handler_irq12, 0);
f0105224:	b8 2a 5a 10 f0       	mov    $0xf0105a2a,%eax
f0105229:	66 a3 e0 33 29 f0    	mov    %ax,0xf02933e0
f010522f:	66 c7 05 e2 33 29 f0 	movw   $0x8,0xf02933e2
f0105236:	08 00 
f0105238:	c6 05 e4 33 29 f0 00 	movb   $0x0,0xf02933e4
f010523f:	c6 05 e5 33 29 f0 8e 	movb   $0x8e,0xf02933e5
f0105246:	c1 e8 10             	shr    $0x10,%eax
f0105249:	66 a3 e6 33 29 f0    	mov    %ax,0xf02933e6
        SETGATE(idt[IRQ_OFFSET + 13], 0, GD_KT, handler_irq13, 0);
f010524f:	b8 30 5a 10 f0       	mov    $0xf0105a30,%eax
f0105254:	66 a3 e8 33 29 f0    	mov    %ax,0xf02933e8
f010525a:	66 c7 05 ea 33 29 f0 	movw   $0x8,0xf02933ea
f0105261:	08 00 
f0105263:	c6 05 ec 33 29 f0 00 	movb   $0x0,0xf02933ec
f010526a:	c6 05 ed 33 29 f0 8e 	movb   $0x8e,0xf02933ed
f0105271:	c1 e8 10             	shr    $0x10,%eax
f0105274:	66 a3 ee 33 29 f0    	mov    %ax,0xf02933ee
        SETGATE(idt[IRQ_OFFSET + IRQ_IDE], 0, GD_KT, handler_ide, 0);
f010527a:	b8 36 5a 10 f0       	mov    $0xf0105a36,%eax
f010527f:	66 a3 f0 33 29 f0    	mov    %ax,0xf02933f0
f0105285:	66 c7 05 f2 33 29 f0 	movw   $0x8,0xf02933f2
f010528c:	08 00 
f010528e:	c6 05 f4 33 29 f0 00 	movb   $0x0,0xf02933f4
f0105295:	c6 05 f5 33 29 f0 8e 	movb   $0x8e,0xf02933f5
f010529c:	c1 e8 10             	shr    $0x10,%eax
f010529f:	66 a3 f6 33 29 f0    	mov    %ax,0xf02933f6
        SETGATE(idt[IRQ_OFFSET + 15], 0, GD_KT, handler_irq15, 0);
f01052a5:	b8 3c 5a 10 f0       	mov    $0xf0105a3c,%eax
f01052aa:	66 a3 f8 33 29 f0    	mov    %ax,0xf02933f8
f01052b0:	66 c7 05 fa 33 29 f0 	movw   $0x8,0xf02933fa
f01052b7:	08 00 
f01052b9:	c6 05 fc 33 29 f0 00 	movb   $0x0,0xf02933fc
f01052c0:	c6 05 fd 33 29 f0 8e 	movb   $0x8e,0xf02933fd
f01052c7:	c1 e8 10             	shr    $0x10,%eax
f01052ca:	66 a3 fe 33 29 f0    	mov    %ax,0xf02933fe
        
	// Per-CPU setup 
	trap_init_percpu();
f01052d0:	e8 6b f9 ff ff       	call   f0104c40 <trap_init_percpu>
}
f01052d5:	c9                   	leave  
f01052d6:	c3                   	ret    

f01052d7 <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f01052d7:	55                   	push   %ebp
f01052d8:	89 e5                	mov    %esp,%ebp
f01052da:	53                   	push   %ebx
f01052db:	83 ec 14             	sub    $0x14,%esp
f01052de:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f01052e1:	8b 03                	mov    (%ebx),%eax
f01052e3:	89 44 24 04          	mov    %eax,0x4(%esp)
f01052e7:	c7 04 24 17 a0 10 f0 	movl   $0xf010a017,(%esp)
f01052ee:	e8 1c f9 ff ff       	call   f0104c0f <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f01052f3:	8b 43 04             	mov    0x4(%ebx),%eax
f01052f6:	89 44 24 04          	mov    %eax,0x4(%esp)
f01052fa:	c7 04 24 26 a0 10 f0 	movl   $0xf010a026,(%esp)
f0105301:	e8 09 f9 ff ff       	call   f0104c0f <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0105306:	8b 43 08             	mov    0x8(%ebx),%eax
f0105309:	89 44 24 04          	mov    %eax,0x4(%esp)
f010530d:	c7 04 24 35 a0 10 f0 	movl   $0xf010a035,(%esp)
f0105314:	e8 f6 f8 ff ff       	call   f0104c0f <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0105319:	8b 43 0c             	mov    0xc(%ebx),%eax
f010531c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105320:	c7 04 24 44 a0 10 f0 	movl   $0xf010a044,(%esp)
f0105327:	e8 e3 f8 ff ff       	call   f0104c0f <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f010532c:	8b 43 10             	mov    0x10(%ebx),%eax
f010532f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105333:	c7 04 24 53 a0 10 f0 	movl   $0xf010a053,(%esp)
f010533a:	e8 d0 f8 ff ff       	call   f0104c0f <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f010533f:	8b 43 14             	mov    0x14(%ebx),%eax
f0105342:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105346:	c7 04 24 62 a0 10 f0 	movl   $0xf010a062,(%esp)
f010534d:	e8 bd f8 ff ff       	call   f0104c0f <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0105352:	8b 43 18             	mov    0x18(%ebx),%eax
f0105355:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105359:	c7 04 24 71 a0 10 f0 	movl   $0xf010a071,(%esp)
f0105360:	e8 aa f8 ff ff       	call   f0104c0f <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0105365:	8b 43 1c             	mov    0x1c(%ebx),%eax
f0105368:	89 44 24 04          	mov    %eax,0x4(%esp)
f010536c:	c7 04 24 80 a0 10 f0 	movl   $0xf010a080,(%esp)
f0105373:	e8 97 f8 ff ff       	call   f0104c0f <cprintf>
}
f0105378:	83 c4 14             	add    $0x14,%esp
f010537b:	5b                   	pop    %ebx
f010537c:	5d                   	pop    %ebp
f010537d:	c3                   	ret    

f010537e <print_trapframe>:
	lidt(&idt_pd);*/
}

void
print_trapframe(struct Trapframe *tf)
{
f010537e:	55                   	push   %ebp
f010537f:	89 e5                	mov    %esp,%ebp
f0105381:	56                   	push   %esi
f0105382:	53                   	push   %ebx
f0105383:	83 ec 10             	sub    $0x10,%esp
f0105386:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f0105389:	e8 10 28 00 00       	call   f0107b9e <cpunum>
f010538e:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105392:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105396:	c7 04 24 8f a0 10 f0 	movl   $0xf010a08f,(%esp)
f010539d:	e8 6d f8 ff ff       	call   f0104c0f <cprintf>
	print_regs(&tf->tf_regs);
f01053a2:	89 1c 24             	mov    %ebx,(%esp)
f01053a5:	e8 2d ff ff ff       	call   f01052d7 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f01053aa:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f01053ae:	89 44 24 04          	mov    %eax,0x4(%esp)
f01053b2:	c7 04 24 ad a0 10 f0 	movl   $0xf010a0ad,(%esp)
f01053b9:	e8 51 f8 ff ff       	call   f0104c0f <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f01053be:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f01053c2:	89 44 24 04          	mov    %eax,0x4(%esp)
f01053c6:	c7 04 24 c0 a0 10 f0 	movl   $0xf010a0c0,(%esp)
f01053cd:	e8 3d f8 ff ff       	call   f0104c0f <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f01053d2:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
f01053d5:	83 f8 13             	cmp    $0x13,%eax
f01053d8:	77 09                	ja     f01053e3 <print_trapframe+0x65>
		return excnames[trapno];
f01053da:	8b 14 85 a0 a3 10 f0 	mov    -0xfef5c60(,%eax,4),%edx
f01053e1:	eb 1c                	jmp    f01053ff <print_trapframe+0x81>
	if (trapno == T_SYSCALL)
f01053e3:	ba d3 a0 10 f0       	mov    $0xf010a0d3,%edx
f01053e8:	83 f8 30             	cmp    $0x30,%eax
f01053eb:	74 12                	je     f01053ff <print_trapframe+0x81>
		return "System call";
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f01053ed:	8d 48 e0             	lea    -0x20(%eax),%ecx
f01053f0:	ba ee a0 10 f0       	mov    $0xf010a0ee,%edx
f01053f5:	83 f9 0f             	cmp    $0xf,%ecx
f01053f8:	76 05                	jbe    f01053ff <print_trapframe+0x81>
f01053fa:	ba df a0 10 f0       	mov    $0xf010a0df,%edx
{
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f01053ff:	89 54 24 08          	mov    %edx,0x8(%esp)
f0105403:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105407:	c7 04 24 01 a1 10 f0 	movl   $0xf010a101,(%esp)
f010540e:	e8 fc f7 ff ff       	call   f0104c0f <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0105413:	3b 1d 80 3a 29 f0    	cmp    0xf0293a80,%ebx
f0105419:	75 19                	jne    f0105434 <print_trapframe+0xb6>
f010541b:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f010541f:	75 13                	jne    f0105434 <print_trapframe+0xb6>

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f0105421:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f0105424:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105428:	c7 04 24 13 a1 10 f0 	movl   $0xf010a113,(%esp)
f010542f:	e8 db f7 ff ff       	call   f0104c0f <cprintf>
	cprintf("  err  0x%08x", tf->tf_err);
f0105434:	8b 43 2c             	mov    0x2c(%ebx),%eax
f0105437:	89 44 24 04          	mov    %eax,0x4(%esp)
f010543b:	c7 04 24 22 a1 10 f0 	movl   $0xf010a122,(%esp)
f0105442:	e8 c8 f7 ff ff       	call   f0104c0f <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f0105447:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f010544b:	75 47                	jne    f0105494 <print_trapframe+0x116>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f010544d:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f0105450:	be 3c a1 10 f0       	mov    $0xf010a13c,%esi
f0105455:	a8 01                	test   $0x1,%al
f0105457:	75 05                	jne    f010545e <print_trapframe+0xe0>
f0105459:	be 30 a1 10 f0       	mov    $0xf010a130,%esi
f010545e:	b9 4c a1 10 f0       	mov    $0xf010a14c,%ecx
f0105463:	a8 02                	test   $0x2,%al
f0105465:	75 05                	jne    f010546c <print_trapframe+0xee>
f0105467:	b9 47 a1 10 f0       	mov    $0xf010a147,%ecx
f010546c:	ba 52 a1 10 f0       	mov    $0xf010a152,%edx
f0105471:	a8 04                	test   $0x4,%al
f0105473:	75 05                	jne    f010547a <print_trapframe+0xfc>
f0105475:	ba 29 a2 10 f0       	mov    $0xf010a229,%edx
f010547a:	89 74 24 0c          	mov    %esi,0xc(%esp)
f010547e:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0105482:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105486:	c7 04 24 57 a1 10 f0 	movl   $0xf010a157,(%esp)
f010548d:	e8 7d f7 ff ff       	call   f0104c0f <cprintf>
f0105492:	eb 0c                	jmp    f01054a0 <print_trapframe+0x122>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f0105494:	c7 04 24 19 92 10 f0 	movl   $0xf0109219,(%esp)
f010549b:	e8 6f f7 ff ff       	call   f0104c0f <cprintf>
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f01054a0:	8b 43 30             	mov    0x30(%ebx),%eax
f01054a3:	89 44 24 04          	mov    %eax,0x4(%esp)
f01054a7:	c7 04 24 66 a1 10 f0 	movl   $0xf010a166,(%esp)
f01054ae:	e8 5c f7 ff ff       	call   f0104c0f <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f01054b3:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f01054b7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01054bb:	c7 04 24 75 a1 10 f0 	movl   $0xf010a175,(%esp)
f01054c2:	e8 48 f7 ff ff       	call   f0104c0f <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f01054c7:	8b 43 38             	mov    0x38(%ebx),%eax
f01054ca:	89 44 24 04          	mov    %eax,0x4(%esp)
f01054ce:	c7 04 24 88 a1 10 f0 	movl   $0xf010a188,(%esp)
f01054d5:	e8 35 f7 ff ff       	call   f0104c0f <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f01054da:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f01054de:	74 27                	je     f0105507 <print_trapframe+0x189>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f01054e0:	8b 43 3c             	mov    0x3c(%ebx),%eax
f01054e3:	89 44 24 04          	mov    %eax,0x4(%esp)
f01054e7:	c7 04 24 97 a1 10 f0 	movl   $0xf010a197,(%esp)
f01054ee:	e8 1c f7 ff ff       	call   f0104c0f <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f01054f3:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f01054f7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01054fb:	c7 04 24 a6 a1 10 f0 	movl   $0xf010a1a6,(%esp)
f0105502:	e8 08 f7 ff ff       	call   f0104c0f <cprintf>
	}
}
f0105507:	83 c4 10             	add    $0x10,%esp
f010550a:	5b                   	pop    %ebx
f010550b:	5e                   	pop    %esi
f010550c:	5d                   	pop    %ebp
f010550d:	c3                   	ret    

f010550e <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f010550e:	55                   	push   %ebp
f010550f:	89 e5                	mov    %esp,%ebp
f0105511:	57                   	push   %edi
f0105512:	56                   	push   %esi
f0105513:	53                   	push   %ebx
f0105514:	83 ec 2c             	sub    $0x2c,%esp
f0105517:	8b 5d 08             	mov    0x8(%ebp),%ebx
f010551a:	0f 20 d0             	mov    %cr2,%eax
f010551d:	89 45 e0             	mov    %eax,-0x20(%ebp)
	fault_va = rcr2();

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.
        if (tf->tf_cs == GD_KT){
f0105520:	66 83 7b 34 08       	cmpw   $0x8,0x34(%ebx)
f0105525:	75 1c                	jne    f0105543 <page_fault_handler+0x35>
            panic("page fault in kernel");
f0105527:	c7 44 24 08 b9 a1 10 	movl   $0xf010a1b9,0x8(%esp)
f010552e:	f0 
f010552f:	c7 44 24 04 8b 01 00 	movl   $0x18b,0x4(%esp)
f0105536:	00 
f0105537:	c7 04 24 ce a1 10 f0 	movl   $0xf010a1ce,(%esp)
f010553e:	e8 42 ab ff ff       	call   f0100085 <_panic>
	//   user_mem_assert() and env_run() are useful here.
	//   To change what the user environment runs, modify 'curenv->env_tf'
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.
        void* call = curenv->env_pgfault_upcall;
f0105543:	e8 56 26 00 00       	call   f0107b9e <cpunum>
f0105548:	6b c0 74             	imul   $0x74,%eax,%eax
f010554b:	8b 80 28 40 29 f0    	mov    -0xfd6bfd8(%eax),%eax
f0105551:	8b 40 68             	mov    0x68(%eax),%eax
f0105554:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(!call){
f0105557:	85 c0                	test   %eax,%eax
f0105559:	75 4e                	jne    f01055a9 <page_fault_handler+0x9b>
	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f010555b:	8b 73 30             	mov    0x30(%ebx),%esi
		curenv->env_id, fault_va, tf->tf_eip);
f010555e:	e8 3b 26 00 00       	call   f0107b9e <cpunum>

	// LAB 4: Your code here.
        void* call = curenv->env_pgfault_upcall;
        if(!call){
	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0105563:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0105567:	8b 55 e0             	mov    -0x20(%ebp),%edx
f010556a:	89 54 24 08          	mov    %edx,0x8(%esp)
f010556e:	be 20 40 29 f0       	mov    $0xf0294020,%esi
f0105573:	6b c0 74             	imul   $0x74,%eax,%eax
f0105576:	8b 44 30 08          	mov    0x8(%eax,%esi,1),%eax
f010557a:	8b 40 48             	mov    0x48(%eax),%eax
f010557d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105581:	c7 04 24 74 a3 10 f0 	movl   $0xf010a374,(%esp)
f0105588:	e8 82 f6 ff ff       	call   f0104c0f <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f010558d:	89 1c 24             	mov    %ebx,(%esp)
f0105590:	e8 e9 fd ff ff       	call   f010537e <print_trapframe>
	env_destroy(curenv);
f0105595:	e8 04 26 00 00       	call   f0107b9e <cpunum>
f010559a:	6b c0 74             	imul   $0x74,%eax,%eax
f010559d:	8b 44 30 08          	mov    0x8(%eax,%esi,1),%eax
f01055a1:	89 04 24             	mov    %eax,(%esp)
f01055a4:	e8 0f f1 ff ff       	call   f01046b8 <env_destroy>
        }
        struct UTrapframe* utf;
        if((tf->tf_esp >= UXSTACKTOP - PGSIZE) && (tf->tf_esp <= UXSTACKTOP - 1))
f01055a9:	8b 43 3c             	mov    0x3c(%ebx),%eax
f01055ac:	8d 90 00 10 40 11    	lea    0x11401000(%eax),%edx
f01055b2:	be cc ff bf ee       	mov    $0xeebfffcc,%esi
f01055b7:	81 fa ff 0f 00 00    	cmp    $0xfff,%edx
f01055bd:	77 03                	ja     f01055c2 <page_fault_handler+0xb4>
           utf = (struct UTrapframe*)(tf->tf_esp - sizeof(struct UTrapframe) - 4);
f01055bf:	8d 70 c8             	lea    -0x38(%eax),%esi
        else
           utf = (struct UTrapframe*)(UXSTACKTOP - sizeof(struct UTrapframe));
        user_mem_assert(curenv,(void*)utf,sizeof(struct UTrapframe),PTE_P|PTE_U|PTE_W);
f01055c2:	e8 d7 25 00 00       	call   f0107b9e <cpunum>
f01055c7:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
f01055ce:	00 
f01055cf:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
f01055d6:	00 
f01055d7:	89 74 24 04          	mov    %esi,0x4(%esp)
f01055db:	bf 20 40 29 f0       	mov    $0xf0294020,%edi
f01055e0:	6b c0 74             	imul   $0x74,%eax,%eax
f01055e3:	8b 44 38 08          	mov    0x8(%eax,%edi,1),%eax
f01055e7:	89 04 24             	mov    %eax,(%esp)
f01055ea:	e8 40 cd ff ff       	call   f010232f <user_mem_assert>
        utf->utf_fault_va = fault_va;
f01055ef:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01055f2:	89 06                	mov    %eax,(%esi)
        utf->utf_err = tf->tf_err;
f01055f4:	8b 43 2c             	mov    0x2c(%ebx),%eax
f01055f7:	89 46 04             	mov    %eax,0x4(%esi)
        utf->utf_regs = tf->tf_regs;
f01055fa:	8b 03                	mov    (%ebx),%eax
f01055fc:	89 46 08             	mov    %eax,0x8(%esi)
f01055ff:	8b 43 04             	mov    0x4(%ebx),%eax
f0105602:	89 46 0c             	mov    %eax,0xc(%esi)
f0105605:	8b 43 08             	mov    0x8(%ebx),%eax
f0105608:	89 46 10             	mov    %eax,0x10(%esi)
f010560b:	8b 43 0c             	mov    0xc(%ebx),%eax
f010560e:	89 46 14             	mov    %eax,0x14(%esi)
f0105611:	8b 43 10             	mov    0x10(%ebx),%eax
f0105614:	89 46 18             	mov    %eax,0x18(%esi)
f0105617:	8b 43 14             	mov    0x14(%ebx),%eax
f010561a:	89 46 1c             	mov    %eax,0x1c(%esi)
f010561d:	8b 43 18             	mov    0x18(%ebx),%eax
f0105620:	89 46 20             	mov    %eax,0x20(%esi)
f0105623:	8b 43 1c             	mov    0x1c(%ebx),%eax
f0105626:	89 46 24             	mov    %eax,0x24(%esi)
        utf->utf_eip = tf->tf_eip;
f0105629:	8b 43 30             	mov    0x30(%ebx),%eax
f010562c:	89 46 28             	mov    %eax,0x28(%esi)
        utf->utf_eflags = tf->tf_eflags;
f010562f:	8b 43 38             	mov    0x38(%ebx),%eax
f0105632:	89 46 2c             	mov    %eax,0x2c(%esi)
        utf->utf_esp = tf->tf_esp;
f0105635:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0105638:	89 46 30             	mov    %eax,0x30(%esi)
        curenv->env_tf.tf_eip = (uint32_t)call;
f010563b:	e8 5e 25 00 00       	call   f0107b9e <cpunum>
f0105640:	6b c0 74             	imul   $0x74,%eax,%eax
f0105643:	8b 44 38 08          	mov    0x8(%eax,%edi,1),%eax
f0105647:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f010564a:	89 50 30             	mov    %edx,0x30(%eax)
        curenv->env_tf.tf_esp = (uint32_t)utf;
f010564d:	e8 4c 25 00 00       	call   f0107b9e <cpunum>
f0105652:	6b c0 74             	imul   $0x74,%eax,%eax
f0105655:	8b 44 38 08          	mov    0x8(%eax,%edi,1),%eax
f0105659:	89 70 3c             	mov    %esi,0x3c(%eax)
        env_run(curenv);
f010565c:	e8 3d 25 00 00       	call   f0107b9e <cpunum>
f0105661:	6b c0 74             	imul   $0x74,%eax,%eax
f0105664:	8b 44 38 08          	mov    0x8(%eax,%edi,1),%eax
f0105668:	89 04 24             	mov    %eax,(%esp)
f010566b:	e8 ba ed ff ff       	call   f010442a <env_run>

f0105670 <syscall_helper>:
		env_run(curenv);
	else
		sched_yield();
}

uint32_t syscall_helper(struct Trapframe *tf){
f0105670:	55                   	push   %ebp
f0105671:	89 e5                	mov    %esp,%ebp
f0105673:	83 ec 38             	sub    $0x38,%esp
f0105676:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0105679:	89 75 f8             	mov    %esi,-0x8(%ebp)
f010567c:	89 7d fc             	mov    %edi,-0x4(%ebp)
f010567f:	8b 5d 08             	mov    0x8(%ebp),%ebx
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f0105682:	c7 04 24 80 83 12 f0 	movl   $0xf0128380,(%esp)
f0105689:	e8 d7 28 00 00       	call   f0107f65 <spin_lock>
        uint32_t ret = 0;     
        lock_kernel();
        curenv->env_tf = *tf; 
f010568e:	e8 0b 25 00 00       	call   f0107b9e <cpunum>
f0105693:	6b c0 74             	imul   $0x74,%eax,%eax
f0105696:	8b 80 28 40 29 f0    	mov    -0xfd6bfd8(%eax),%eax
f010569c:	b9 11 00 00 00       	mov    $0x11,%ecx
f01056a1:	89 c7                	mov    %eax,%edi
f01056a3:	89 de                	mov    %ebx,%esi
f01056a5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
        //tf = &curenv->env_tf;
        ret = syscall(tf->tf_regs.reg_eax,tf->tf_regs.reg_edx,tf->tf_regs.reg_ecx,tf->tf_regs.reg_ebx,tf->tf_regs.reg_edi,0);
f01056a7:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
f01056ae:	00 
f01056af:	8b 03                	mov    (%ebx),%eax
f01056b1:	89 44 24 10          	mov    %eax,0x10(%esp)
f01056b5:	8b 43 10             	mov    0x10(%ebx),%eax
f01056b8:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01056bc:	8b 43 18             	mov    0x18(%ebx),%eax
f01056bf:	89 44 24 08          	mov    %eax,0x8(%esp)
f01056c3:	8b 43 14             	mov    0x14(%ebx),%eax
f01056c6:	89 44 24 04          	mov    %eax,0x4(%esp)
f01056ca:	8b 43 1c             	mov    0x1c(%ebx),%eax
f01056cd:	89 04 24             	mov    %eax,(%esp)
f01056d0:	e8 1b 05 00 00       	call   f0105bf0 <syscall>
f01056d5:	89 c3                	mov    %eax,%ebx
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f01056d7:	c7 04 24 80 83 12 f0 	movl   $0xf0128380,(%esp)
f01056de:	e8 69 27 00 00       	call   f0107e4c <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f01056e3:	f3 90                	pause  
        //tf->tf_regs.reg_eax = ret;
        unlock_kernel();
        return ret; 
}
f01056e5:	89 d8                	mov    %ebx,%eax
f01056e7:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f01056ea:	8b 75 f8             	mov    -0x8(%ebp),%esi
f01056ed:	8b 7d fc             	mov    -0x4(%ebp),%edi
f01056f0:	89 ec                	mov    %ebp,%esp
f01056f2:	5d                   	pop    %ebp
f01056f3:	c3                   	ret    

f01056f4 <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f01056f4:	55                   	push   %ebp
f01056f5:	89 e5                	mov    %esp,%ebp
f01056f7:	83 ec 38             	sub    $0x38,%esp
f01056fa:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f01056fd:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0105700:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0105703:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f0105706:	fc                   	cld    

	// Halt the CPU if some other CPU has called panic()
	extern char *panicstr;
	if (panicstr)
f0105707:	83 3d ac 3e 29 f0 00 	cmpl   $0x0,0xf0293eac
f010570e:	74 01                	je     f0105711 <trap+0x1d>
		asm volatile("hlt");
f0105710:	f4                   	hlt    

static __inline uint32_t
read_eflags(void)
{
        uint32_t eflags;
        __asm __volatile("pushfl; popl %0" : "=r" (eflags));
f0105711:	9c                   	pushf  
f0105712:	58                   	pop    %eax

	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f0105713:	f6 c4 02             	test   $0x2,%ah
f0105716:	74 24                	je     f010573c <trap+0x48>
f0105718:	c7 44 24 0c da a1 10 	movl   $0xf010a1da,0xc(%esp)
f010571f:	f0 
f0105720:	c7 44 24 08 8c 95 10 	movl   $0xf010958c,0x8(%esp)
f0105727:	f0 
f0105728:	c7 44 24 04 4a 01 00 	movl   $0x14a,0x4(%esp)
f010572f:	00 
f0105730:	c7 04 24 ce a1 10 f0 	movl   $0xf010a1ce,(%esp)
f0105737:	e8 49 a9 ff ff       	call   f0100085 <_panic>

	if ((tf->tf_cs & 3) == 3) {
f010573c:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f0105740:	83 e0 03             	and    $0x3,%eax
f0105743:	83 f8 03             	cmp    $0x3,%eax
f0105746:	0f 85 a9 00 00 00    	jne    f01057f5 <trap+0x101>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f010574c:	c7 04 24 80 83 12 f0 	movl   $0xf0128380,(%esp)
f0105753:	e8 0d 28 00 00       	call   f0107f65 <spin_lock>
		// Trapped from user mode.
		// Acquire the big kernel lock before doing any
		// serious kernel work.
		// LAB 4: Your code here.
                lock_kernel();
		assert(curenv);
f0105758:	e8 41 24 00 00       	call   f0107b9e <cpunum>
f010575d:	6b c0 74             	imul   $0x74,%eax,%eax
f0105760:	83 b8 28 40 29 f0 00 	cmpl   $0x0,-0xfd6bfd8(%eax)
f0105767:	75 24                	jne    f010578d <trap+0x99>
f0105769:	c7 44 24 0c f3 a1 10 	movl   $0xf010a1f3,0xc(%esp)
f0105770:	f0 
f0105771:	c7 44 24 08 8c 95 10 	movl   $0xf010958c,0x8(%esp)
f0105778:	f0 
f0105779:	c7 44 24 04 52 01 00 	movl   $0x152,0x4(%esp)
f0105780:	00 
f0105781:	c7 04 24 ce a1 10 f0 	movl   $0xf010a1ce,(%esp)
f0105788:	e8 f8 a8 ff ff       	call   f0100085 <_panic>

		// Garbage collect if current enviroment is a zombie
		if (curenv->env_status == ENV_DYING) {
f010578d:	e8 0c 24 00 00       	call   f0107b9e <cpunum>
f0105792:	6b c0 74             	imul   $0x74,%eax,%eax
f0105795:	8b 80 28 40 29 f0    	mov    -0xfd6bfd8(%eax),%eax
f010579b:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f010579f:	75 2e                	jne    f01057cf <trap+0xdb>
			env_free(curenv);
f01057a1:	e8 f8 23 00 00       	call   f0107b9e <cpunum>
f01057a6:	be 20 40 29 f0       	mov    $0xf0294020,%esi
f01057ab:	6b c0 74             	imul   $0x74,%eax,%eax
f01057ae:	8b 44 30 08          	mov    0x8(%eax,%esi,1),%eax
f01057b2:	89 04 24             	mov    %eax,(%esp)
f01057b5:	e8 2c ed ff ff       	call   f01044e6 <env_free>
			curenv = NULL;
f01057ba:	e8 df 23 00 00       	call   f0107b9e <cpunum>
f01057bf:	6b c0 74             	imul   $0x74,%eax,%eax
f01057c2:	c7 44 30 08 00 00 00 	movl   $0x0,0x8(%eax,%esi,1)
f01057c9:	00 
			sched_yield();
f01057ca:	e8 c1 02 00 00       	call   f0105a90 <sched_yield>
		}

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f01057cf:	e8 ca 23 00 00       	call   f0107b9e <cpunum>
f01057d4:	bb 20 40 29 f0       	mov    $0xf0294020,%ebx
f01057d9:	6b c0 74             	imul   $0x74,%eax,%eax
f01057dc:	8b 44 18 08          	mov    0x8(%eax,%ebx,1),%eax
f01057e0:	b9 11 00 00 00       	mov    $0x11,%ecx
f01057e5:	89 c7                	mov    %eax,%edi
f01057e7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f01057e9:	e8 b0 23 00 00       	call   f0107b9e <cpunum>
f01057ee:	6b c0 74             	imul   $0x74,%eax,%eax
f01057f1:	8b 74 18 08          	mov    0x8(%eax,%ebx,1),%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f01057f5:	89 35 80 3a 29 f0    	mov    %esi,0xf0293a80
	// LAB 3: Your code here.

	// Handle spurious interrupts
	// The hardware sometimes raises these because of noise on the
	// IRQ line or other reasons. We don't care.
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f01057fb:	8b 46 28             	mov    0x28(%esi),%eax
f01057fe:	83 f8 27             	cmp    $0x27,%eax
f0105801:	75 19                	jne    f010581c <trap+0x128>
		cprintf("Spurious interrupt on irq 7\n");
f0105803:	c7 04 24 fa a1 10 f0 	movl   $0xf010a1fa,(%esp)
f010580a:	e8 00 f4 ff ff       	call   f0104c0f <cprintf>
		print_trapframe(tf);
f010580f:	89 34 24             	mov    %esi,(%esp)
f0105812:	e8 67 fb ff ff       	call   f010537e <print_trapframe>
f0105817:	e9 c5 00 00 00       	jmp    f01058e1 <trap+0x1ed>
	// triggered on every CPU.
	// LAB 6: Your code here.



        if(tf->tf_trapno == T_PGFLT)
f010581c:	83 f8 0e             	cmp    $0xe,%eax
f010581f:	90                   	nop
f0105820:	75 0b                	jne    f010582d <trap+0x139>
            page_fault_handler(tf);
f0105822:	89 34 24             	mov    %esi,(%esp)
f0105825:	8d 76 00             	lea    0x0(%esi),%esi
f0105828:	e8 e1 fc ff ff       	call   f010550e <page_fault_handler>
	// Unexpected trap: The user process or the kernel has a bug.
        if(tf->tf_trapno == T_BRKPT)
f010582d:	83 7e 28 03          	cmpl   $0x3,0x28(%esi)
f0105831:	75 08                	jne    f010583b <trap+0x147>
            monitor(tf);
f0105833:	89 34 24             	mov    %esi,(%esp)
f0105836:	e8 6e b3 ff ff       	call   f0100ba9 <monitor>
        if(tf->tf_trapno == T_DEBUG){
f010583b:	83 7e 28 01          	cmpl   $0x1,0x28(%esi)
f010583f:	90                   	nop
f0105840:	75 0f                	jne    f0105851 <trap+0x15d>
            tf->tf_eflags = tf->tf_eflags & (~0x100);
f0105842:	81 66 38 ff fe ff ff 	andl   $0xfffffeff,0x38(%esi)
            monitor(tf);
f0105849:	89 34 24             	mov    %esi,(%esp)
f010584c:	e8 58 b3 ff ff       	call   f0100ba9 <monitor>
        }
        if(tf->tf_trapno == IRQ_OFFSET + IRQ_TIMER){
f0105851:	8b 46 28             	mov    0x28(%esi),%eax
f0105854:	83 f8 20             	cmp    $0x20,%eax
f0105857:	75 0f                	jne    f0105868 <trap+0x174>
                time_tick();
f0105859:	e8 00 32 00 00       	call   f0108a5e <time_tick>
                lapic_eoi();
f010585e:	e8 74 24 00 00       	call   f0107cd7 <lapic_eoi>
		sched_yield();
f0105863:	e8 28 02 00 00       	call   f0105a90 <sched_yield>
	}
        if(tf->tf_trapno == T_SYSCALL){
f0105868:	83 f8 30             	cmp    $0x30,%eax
f010586b:	75 33                	jne    f01058a0 <trap+0x1ac>
		tf->tf_regs.reg_eax = syscall(tf->tf_regs.reg_eax,tf->tf_regs.reg_edx,tf->tf_regs.reg_ecx,tf->tf_regs.reg_ebx,tf->tf_regs.reg_edi,0);
f010586d:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
f0105874:	00 
f0105875:	8b 06                	mov    (%esi),%eax
f0105877:	89 44 24 10          	mov    %eax,0x10(%esp)
f010587b:	8b 46 10             	mov    0x10(%esi),%eax
f010587e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105882:	8b 46 18             	mov    0x18(%esi),%eax
f0105885:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105889:	8b 46 14             	mov    0x14(%esi),%eax
f010588c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105890:	8b 46 1c             	mov    0x1c(%esi),%eax
f0105893:	89 04 24             	mov    %eax,(%esp)
f0105896:	e8 55 03 00 00       	call   f0105bf0 <syscall>
f010589b:	89 46 1c             	mov    %eax,0x1c(%esi)
f010589e:	eb 41                	jmp    f01058e1 <trap+0x1ed>
                return;
	}
	print_trapframe(tf);
f01058a0:	89 34 24             	mov    %esi,(%esp)
f01058a3:	e8 d6 fa ff ff       	call   f010537e <print_trapframe>
	if (tf->tf_cs == GD_KT)
f01058a8:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f01058ad:	75 1c                	jne    f01058cb <trap+0x1d7>
		panic("unhandled trap in kernel");
f01058af:	c7 44 24 08 17 a2 10 	movl   $0xf010a217,0x8(%esp)
f01058b6:	f0 
f01058b7:	c7 44 24 04 34 01 00 	movl   $0x134,0x4(%esp)
f01058be:	00 
f01058bf:	c7 04 24 ce a1 10 f0 	movl   $0xf010a1ce,(%esp)
f01058c6:	e8 ba a7 ff ff       	call   f0100085 <_panic>
	else {
		env_destroy(curenv);
f01058cb:	e8 ce 22 00 00       	call   f0107b9e <cpunum>
f01058d0:	6b c0 74             	imul   $0x74,%eax,%eax
f01058d3:	8b 80 28 40 29 f0    	mov    -0xfd6bfd8(%eax),%eax
f01058d9:	89 04 24             	mov    %eax,(%esp)
f01058dc:	e8 d7 ed ff ff       	call   f01046b8 <env_destroy>
	trap_dispatch(tf);

	// If we made it to this point, then no other environment was
	// scheduled, so we should return to the current environment
	// if doing so makes sense.
	if (curenv && curenv->env_status == ENV_RUNNING)
f01058e1:	e8 b8 22 00 00       	call   f0107b9e <cpunum>
f01058e6:	6b c0 74             	imul   $0x74,%eax,%eax
f01058e9:	83 b8 28 40 29 f0 00 	cmpl   $0x0,-0xfd6bfd8(%eax)
f01058f0:	74 2a                	je     f010591c <trap+0x228>
f01058f2:	e8 a7 22 00 00       	call   f0107b9e <cpunum>
f01058f7:	6b c0 74             	imul   $0x74,%eax,%eax
f01058fa:	8b 80 28 40 29 f0    	mov    -0xfd6bfd8(%eax),%eax
f0105900:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0105904:	75 16                	jne    f010591c <trap+0x228>
		env_run(curenv);
f0105906:	e8 93 22 00 00       	call   f0107b9e <cpunum>
f010590b:	6b c0 74             	imul   $0x74,%eax,%eax
f010590e:	8b 80 28 40 29 f0    	mov    -0xfd6bfd8(%eax),%eax
f0105914:	89 04 24             	mov    %eax,(%esp)
f0105917:	e8 0e eb ff ff       	call   f010442a <env_run>
	else
		sched_yield();
f010591c:	e8 6f 01 00 00       	call   f0105a90 <sched_yield>
f0105921:	00 00                	add    %al,(%eax)
	...

f0105924 <handler_divide>:
.text

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */
TRAPHANDLER_NOEC(handler_divide, T_DIVIDE)
f0105924:	6a 00                	push   $0x0
f0105926:	6a 00                	push   $0x0
f0105928:	e9 49 01 00 00       	jmp    f0105a76 <_alltraps>
f010592d:	90                   	nop

f010592e <handler_debug>:
TRAPHANDLER_NOEC(handler_debug, T_DEBUG)
f010592e:	6a 00                	push   $0x0
f0105930:	6a 01                	push   $0x1
f0105932:	e9 3f 01 00 00       	jmp    f0105a76 <_alltraps>
f0105937:	90                   	nop

f0105938 <handler_nmi>:
TRAPHANDLER_NOEC(handler_nmi, T_NMI)
f0105938:	6a 00                	push   $0x0
f010593a:	6a 02                	push   $0x2
f010593c:	e9 35 01 00 00       	jmp    f0105a76 <_alltraps>
f0105941:	90                   	nop

f0105942 <handler_brkpt>:
TRAPHANDLER_NOEC(handler_brkpt, T_BRKPT)
f0105942:	6a 00                	push   $0x0
f0105944:	6a 03                	push   $0x3
f0105946:	e9 2b 01 00 00       	jmp    f0105a76 <_alltraps>
f010594b:	90                   	nop

f010594c <handler_oflow>:
TRAPHANDLER_NOEC(handler_oflow, T_OFLOW)
f010594c:	6a 00                	push   $0x0
f010594e:	6a 04                	push   $0x4
f0105950:	e9 21 01 00 00       	jmp    f0105a76 <_alltraps>
f0105955:	90                   	nop

f0105956 <handler_bound>:
TRAPHANDLER_NOEC(handler_bound, T_BOUND)
f0105956:	6a 00                	push   $0x0
f0105958:	6a 05                	push   $0x5
f010595a:	e9 17 01 00 00       	jmp    f0105a76 <_alltraps>
f010595f:	90                   	nop

f0105960 <handler_illop>:
TRAPHANDLER_NOEC(handler_illop, T_ILLOP)
f0105960:	6a 00                	push   $0x0
f0105962:	6a 06                	push   $0x6
f0105964:	e9 0d 01 00 00       	jmp    f0105a76 <_alltraps>
f0105969:	90                   	nop

f010596a <handler_device>:
TRAPHANDLER_NOEC(handler_device, T_DEVICE)
f010596a:	6a 00                	push   $0x0
f010596c:	6a 07                	push   $0x7
f010596e:	e9 03 01 00 00       	jmp    f0105a76 <_alltraps>
f0105973:	90                   	nop

f0105974 <handler_dblflt>:
TRAPHANDLER(handler_dblflt, T_DBLFLT)
f0105974:	6a 08                	push   $0x8
f0105976:	e9 fb 00 00 00       	jmp    f0105a76 <_alltraps>
f010597b:	90                   	nop

f010597c <handler_tss>:
TRAPHANDLER(handler_tss, T_TSS)
f010597c:	6a 0a                	push   $0xa
f010597e:	e9 f3 00 00 00       	jmp    f0105a76 <_alltraps>
f0105983:	90                   	nop

f0105984 <handler_segnp>:
TRAPHANDLER(handler_segnp, T_SEGNP)
f0105984:	6a 0b                	push   $0xb
f0105986:	e9 eb 00 00 00       	jmp    f0105a76 <_alltraps>
f010598b:	90                   	nop

f010598c <handler_stack>:
TRAPHANDLER(handler_stack, T_STACK)
f010598c:	6a 0c                	push   $0xc
f010598e:	e9 e3 00 00 00       	jmp    f0105a76 <_alltraps>
f0105993:	90                   	nop

f0105994 <handler_gpflt>:
TRAPHANDLER(handler_gpflt, T_GPFLT)
f0105994:	6a 0d                	push   $0xd
f0105996:	e9 db 00 00 00       	jmp    f0105a76 <_alltraps>
f010599b:	90                   	nop

f010599c <handler_pgflt>:
TRAPHANDLER(handler_pgflt, T_PGFLT)
f010599c:	6a 0e                	push   $0xe
f010599e:	e9 d3 00 00 00       	jmp    f0105a76 <_alltraps>
f01059a3:	90                   	nop

f01059a4 <handler_fperr>:
TRAPHANDLER_NOEC(handler_fperr, T_FPERR)
f01059a4:	6a 00                	push   $0x0
f01059a6:	6a 10                	push   $0x10
f01059a8:	e9 c9 00 00 00       	jmp    f0105a76 <_alltraps>
f01059ad:	90                   	nop

f01059ae <handler_align>:
TRAPHANDLER_NOEC(handler_align, T_ALIGN)
f01059ae:	6a 00                	push   $0x0
f01059b0:	6a 11                	push   $0x11
f01059b2:	e9 bf 00 00 00       	jmp    f0105a76 <_alltraps>
f01059b7:	90                   	nop

f01059b8 <handler_mchk>:
TRAPHANDLER_NOEC(handler_mchk, T_MCHK)
f01059b8:	6a 00                	push   $0x0
f01059ba:	6a 12                	push   $0x12
f01059bc:	e9 b5 00 00 00       	jmp    f0105a76 <_alltraps>
f01059c1:	90                   	nop

f01059c2 <handler_simderr>:
TRAPHANDLER_NOEC(handler_simderr, T_SIMDERR)
f01059c2:	6a 00                	push   $0x0
f01059c4:	6a 13                	push   $0x13
f01059c6:	e9 ab 00 00 00       	jmp    f0105a76 <_alltraps>
f01059cb:	90                   	nop

f01059cc <handler_syscall>:

TRAPHANDLER_NOEC(handler_syscall, T_SYSCALL);	
f01059cc:	6a 00                	push   $0x0
f01059ce:	6a 30                	push   $0x30
f01059d0:	e9 a1 00 00 00       	jmp    f0105a76 <_alltraps>
f01059d5:	90                   	nop

f01059d6 <handler_timer>:

TRAPHANDLER_NOEC(handler_timer,IRQ_OFFSET + IRQ_TIMER);
f01059d6:	6a 00                	push   $0x0
f01059d8:	6a 20                	push   $0x20
f01059da:	e9 97 00 00 00       	jmp    f0105a76 <_alltraps>
f01059df:	90                   	nop

f01059e0 <handler_kbd>:
TRAPHANDLER_NOEC(handler_kbd,IRQ_OFFSET + IRQ_KBD);
f01059e0:	6a 00                	push   $0x0
f01059e2:	6a 21                	push   $0x21
f01059e4:	e9 8d 00 00 00       	jmp    f0105a76 <_alltraps>
f01059e9:	90                   	nop

f01059ea <handler_irq2>:
TRAPHANDLER_NOEC(handler_irq2,IRQ_OFFSET + 2);
f01059ea:	6a 00                	push   $0x0
f01059ec:	6a 22                	push   $0x22
f01059ee:	e9 83 00 00 00       	jmp    f0105a76 <_alltraps>
f01059f3:	90                   	nop

f01059f4 <handler_irq3>:
TRAPHANDLER_NOEC(handler_irq3,IRQ_OFFSET + 3);
f01059f4:	6a 00                	push   $0x0
f01059f6:	6a 23                	push   $0x23
f01059f8:	eb 7c                	jmp    f0105a76 <_alltraps>

f01059fa <handler_serial>:
TRAPHANDLER_NOEC(handler_serial,IRQ_OFFSET + IRQ_SERIAL);
f01059fa:	6a 00                	push   $0x0
f01059fc:	6a 24                	push   $0x24
f01059fe:	eb 76                	jmp    f0105a76 <_alltraps>

f0105a00 <handler_irq5>:
TRAPHANDLER_NOEC(handler_irq5,IRQ_OFFSET + 5);
f0105a00:	6a 00                	push   $0x0
f0105a02:	6a 25                	push   $0x25
f0105a04:	eb 70                	jmp    f0105a76 <_alltraps>

f0105a06 <handler_irq6>:
TRAPHANDLER_NOEC(handler_irq6,IRQ_OFFSET + 6);
f0105a06:	6a 00                	push   $0x0
f0105a08:	6a 26                	push   $0x26
f0105a0a:	eb 6a                	jmp    f0105a76 <_alltraps>

f0105a0c <handler_spurious>:
TRAPHANDLER_NOEC(handler_spurious,IRQ_OFFSET + IRQ_SPURIOUS);
f0105a0c:	6a 00                	push   $0x0
f0105a0e:	6a 27                	push   $0x27
f0105a10:	eb 64                	jmp    f0105a76 <_alltraps>

f0105a12 <handler_irq8>:
TRAPHANDLER_NOEC(handler_irq8,IRQ_OFFSET + 8);
f0105a12:	6a 00                	push   $0x0
f0105a14:	6a 28                	push   $0x28
f0105a16:	eb 5e                	jmp    f0105a76 <_alltraps>

f0105a18 <handler_irq9>:
TRAPHANDLER_NOEC(handler_irq9,IRQ_OFFSET + 9);
f0105a18:	6a 00                	push   $0x0
f0105a1a:	6a 29                	push   $0x29
f0105a1c:	eb 58                	jmp    f0105a76 <_alltraps>

f0105a1e <handler_irq10>:
TRAPHANDLER_NOEC(handler_irq10,IRQ_OFFSET + 10);
f0105a1e:	6a 00                	push   $0x0
f0105a20:	6a 2a                	push   $0x2a
f0105a22:	eb 52                	jmp    f0105a76 <_alltraps>

f0105a24 <handler_irq11>:
TRAPHANDLER_NOEC(handler_irq11,IRQ_OFFSET + 11);
f0105a24:	6a 00                	push   $0x0
f0105a26:	6a 2b                	push   $0x2b
f0105a28:	eb 4c                	jmp    f0105a76 <_alltraps>

f0105a2a <handler_irq12>:
TRAPHANDLER_NOEC(handler_irq12,IRQ_OFFSET + 12);
f0105a2a:	6a 00                	push   $0x0
f0105a2c:	6a 2c                	push   $0x2c
f0105a2e:	eb 46                	jmp    f0105a76 <_alltraps>

f0105a30 <handler_irq13>:
TRAPHANDLER_NOEC(handler_irq13,IRQ_OFFSET + 13);
f0105a30:	6a 00                	push   $0x0
f0105a32:	6a 2d                	push   $0x2d
f0105a34:	eb 40                	jmp    f0105a76 <_alltraps>

f0105a36 <handler_ide>:
TRAPHANDLER_NOEC(handler_ide,IRQ_OFFSET + IRQ_IDE);
f0105a36:	6a 00                	push   $0x0
f0105a38:	6a 2e                	push   $0x2e
f0105a3a:	eb 3a                	jmp    f0105a76 <_alltraps>

f0105a3c <handler_irq15>:
TRAPHANDLER_NOEC(handler_irq15,IRQ_OFFSET + 15);
f0105a3c:	6a 00                	push   $0x0
f0105a3e:	6a 2f                	push   $0x2f
f0105a40:	eb 34                	jmp    f0105a76 <_alltraps>

f0105a42 <sysenter_handler>:
.align 2;
sysenter_handler:
/*
 * Lab 3: Your code here for system call handling
 */
    pushl $GD_UD | 3
f0105a42:	6a 23                	push   $0x23
    pushl %ebp
f0105a44:	55                   	push   %ebp
    pushfl
f0105a45:	9c                   	pushf  
    pushl $GD_UT | 3
f0105a46:	6a 1b                	push   $0x1b
    pushl %esi
f0105a48:	56                   	push   %esi
    pushl $0
f0105a49:	6a 00                	push   $0x0
    pushl $T_SYSCALL
f0105a4b:	6a 30                	push   $0x30
    pushl %ds
f0105a4d:	1e                   	push   %ds
    pushl %es
f0105a4e:	06                   	push   %es
    pushal
f0105a4f:	60                   	pusha  
    movl $GD_KD, %eax
f0105a50:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax,%ds
f0105a55:	8e d8                	mov    %eax,%ds
    movw %ax,%es
f0105a57:	8e c0                	mov    %eax,%es
    pushl %esp
f0105a59:	54                   	push   %esp
    call syscall_helper
f0105a5a:	e8 11 fc ff ff       	call   f0105670 <syscall_helper>
    popl %esp
f0105a5f:	5c                   	pop    %esp
    //popal
    popl %edi
f0105a60:	5f                   	pop    %edi
    popl %esi
f0105a61:	5e                   	pop    %esi
    popl %ebp
f0105a62:	5d                   	pop    %ebp
    popl %ebx
f0105a63:	5b                   	pop    %ebx
    popl %ebx
f0105a64:	5b                   	pop    %ebx
    popl %edx
f0105a65:	5a                   	pop    %edx
    popl %ecx
f0105a66:	59                   	pop    %ecx
    addl $0x4,%esp
f0105a67:	83 c4 04             	add    $0x4,%esp

    popl %es
f0105a6a:	07                   	pop    %es
    popl %ds
f0105a6b:	1f                   	pop    %ds
    addl $0x8,%esp
f0105a6c:	83 c4 08             	add    $0x8,%esp
    movl %esi,%edx
f0105a6f:	89 f2                	mov    %esi,%edx
    movl %ebp,%ecx
f0105a71:	89 e9                	mov    %ebp,%ecx
    sti  //open interrupt
f0105a73:	fb                   	sti    
    sysexit
f0105a74:	0f 35                	sysexit 

f0105a76 <_alltraps>:

/*
 * Lab 3: Your code here for _alltraps
 */
_alltraps:
    pushl %ds
f0105a76:	1e                   	push   %ds
    pushl %es
f0105a77:	06                   	push   %es
    pushal
f0105a78:	60                   	pusha  
    movl $GD_KD, %eax
f0105a79:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax,%ds
f0105a7e:	8e d8                	mov    %eax,%ds
    movw %ax,%es
f0105a80:	8e c0                	mov    %eax,%es
    pushl %esp
f0105a82:	54                   	push   %esp
    call trap
f0105a83:	e8 6c fc ff ff       	call   f01056f4 <trap>
	...

f0105a90 <sched_yield>:


// Choose a user environment to run and run it.
void
sched_yield(void)
{
f0105a90:	55                   	push   %ebp
f0105a91:	89 e5                	mov    %esp,%ebp
f0105a93:	53                   	push   %ebx
f0105a94:	83 ec 14             	sub    $0x14,%esp
	// LAB 4: Your code here.
        uint32_t env_id = 0;
        uint32_t next_id = 0;
        uint32_t high_prior_id = 0;
        uint32_t max_prior = 0;
        if(curenv)
f0105a97:	e8 02 21 00 00       	call   f0107b9e <cpunum>
f0105a9c:	6b d0 74             	imul   $0x74,%eax,%edx
f0105a9f:	b8 00 00 00 00       	mov    $0x0,%eax
f0105aa4:	83 ba 28 40 29 f0 00 	cmpl   $0x0,-0xfd6bfd8(%edx)
f0105aab:	74 16                	je     f0105ac3 <sched_yield+0x33>
            env_id = ENVX(curenv->env_id);   
f0105aad:	e8 ec 20 00 00       	call   f0107b9e <cpunum>
f0105ab2:	6b c0 74             	imul   $0x74,%eax,%eax
f0105ab5:	8b 80 28 40 29 f0    	mov    -0xfd6bfd8(%eax),%eax
f0105abb:	8b 40 48             	mov    0x48(%eax),%eax
f0105abe:	25 ff 03 00 00       	and    $0x3ff,%eax
        next_id = env_id;
        for(i = 0;i < NENV ;i++){
           next_id = (next_id + 1) % NENV;
           if(envs[next_id].env_type != ENV_TYPE_IDLE &&
f0105ac3:	8b 1d 5c 32 29 f0    	mov    0xf029325c,%ebx
f0105ac9:	ba 00 00 00 00       	mov    $0x0,%edx
        uint32_t max_prior = 0;
        if(curenv)
            env_id = ENVX(curenv->env_id);   
        next_id = env_id;
        for(i = 0;i < NENV ;i++){
           next_id = (next_id + 1) % NENV;
f0105ace:	83 c0 01             	add    $0x1,%eax
f0105ad1:	25 ff 03 00 00       	and    $0x3ff,%eax
           if(envs[next_id].env_type != ENV_TYPE_IDLE &&
f0105ad6:	89 c1                	mov    %eax,%ecx
f0105ad8:	c1 e1 07             	shl    $0x7,%ecx
f0105adb:	8d 0c 81             	lea    (%ecx,%eax,4),%ecx
f0105ade:	8d 0c 0b             	lea    (%ebx,%ecx,1),%ecx
f0105ae1:	83 79 50 01          	cmpl   $0x1,0x50(%ecx)
f0105ae5:	74 0e                	je     f0105af5 <sched_yield+0x65>
               envs[next_id].env_status == ENV_RUNNABLE){
f0105ae7:	83 79 54 02          	cmpl   $0x2,0x54(%ecx)
f0105aeb:	75 08                	jne    f0105af5 <sched_yield+0x65>
                //cprintf("next_id:%d\n",next_id);
                env_run(&envs[next_id]);
f0105aed:	89 0c 24             	mov    %ecx,(%esp)
f0105af0:	e8 35 e9 ff ff       	call   f010442a <env_run>
        uint32_t high_prior_id = 0;
        uint32_t max_prior = 0;
        if(curenv)
            env_id = ENVX(curenv->env_id);   
        next_id = env_id;
        for(i = 0;i < NENV ;i++){
f0105af5:	83 c2 01             	add    $0x1,%edx
f0105af8:	81 fa 00 04 00 00    	cmp    $0x400,%edx
f0105afe:	75 ce                	jne    f0105ace <sched_yield+0x3e>
                //cprintf("next_id:%d\n",next_id);
                env_run(&envs[next_id]);
                break;
           }
        }
        if(curenv && curenv->env_type != ENV_TYPE_IDLE && curenv->env_status == ENV_RUNNING)
f0105b00:	e8 99 20 00 00       	call   f0107b9e <cpunum>
f0105b05:	6b c0 74             	imul   $0x74,%eax,%eax
f0105b08:	83 b8 28 40 29 f0 00 	cmpl   $0x0,-0xfd6bfd8(%eax)
f0105b0f:	74 14                	je     f0105b25 <sched_yield+0x95>
f0105b11:	e8 88 20 00 00       	call   f0107b9e <cpunum>
f0105b16:	6b c0 74             	imul   $0x74,%eax,%eax
f0105b19:	8b 80 28 40 29 f0    	mov    -0xfd6bfd8(%eax),%eax
f0105b1f:	83 78 50 01          	cmpl   $0x1,0x50(%eax)
f0105b23:	75 0f                	jne    f0105b34 <sched_yield+0xa4>
            env_run(curenv);*/
	// For debugging and testing purposes, if there are no
	// runnable environments other than the idle environments,
	// drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
		if (envs[i].env_type != ENV_TYPE_IDLE &&
f0105b25:	8b 1d 5c 32 29 f0    	mov    0xf029325c,%ebx
f0105b2b:	89 d8                	mov    %ebx,%eax
f0105b2d:	ba 00 00 00 00       	mov    $0x0,%edx
f0105b32:	eb 2a                	jmp    f0105b5e <sched_yield+0xce>
                //cprintf("next_id:%d\n",next_id);
                env_run(&envs[next_id]);
                break;
           }
        }
        if(curenv && curenv->env_type != ENV_TYPE_IDLE && curenv->env_status == ENV_RUNNING)
f0105b34:	e8 65 20 00 00       	call   f0107b9e <cpunum>
f0105b39:	6b c0 74             	imul   $0x74,%eax,%eax
f0105b3c:	8b 80 28 40 29 f0    	mov    -0xfd6bfd8(%eax),%eax
f0105b42:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0105b46:	75 dd                	jne    f0105b25 <sched_yield+0x95>
            env_run(curenv);
f0105b48:	e8 51 20 00 00       	call   f0107b9e <cpunum>
f0105b4d:	6b c0 74             	imul   $0x74,%eax,%eax
f0105b50:	8b 80 28 40 29 f0    	mov    -0xfd6bfd8(%eax),%eax
f0105b56:	89 04 24             	mov    %eax,(%esp)
f0105b59:	e8 cc e8 ff ff       	call   f010442a <env_run>
            env_run(curenv);*/
	// For debugging and testing purposes, if there are no
	// runnable environments other than the idle environments,
	// drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
		if (envs[i].env_type != ENV_TYPE_IDLE &&
f0105b5e:	83 78 50 01          	cmpl   $0x1,0x50(%eax)
f0105b62:	74 0b                	je     f0105b6f <sched_yield+0xdf>
f0105b64:	8b 48 54             	mov    0x54(%eax),%ecx
f0105b67:	83 e9 02             	sub    $0x2,%ecx
f0105b6a:	83 f9 01             	cmp    $0x1,%ecx
f0105b6d:	76 12                	jbe    f0105b81 <sched_yield+0xf1>
        if(curenv && curenv->env_type != ENV_TYPE_IDLE && curenv->env_status == ENV_RUNNING)
            env_run(curenv);*/
	// For debugging and testing purposes, if there are no
	// runnable environments other than the idle environments,
	// drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0105b6f:	83 c2 01             	add    $0x1,%edx
f0105b72:	05 84 00 00 00       	add    $0x84,%eax
f0105b77:	81 fa 00 04 00 00    	cmp    $0x400,%edx
f0105b7d:	75 df                	jne    f0105b5e <sched_yield+0xce>
f0105b7f:	eb 08                	jmp    f0105b89 <sched_yield+0xf9>
		if (envs[i].env_type != ENV_TYPE_IDLE &&
		    (envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING))
			break;
	}
	if (i == NENV) {
f0105b81:	81 fa 00 04 00 00    	cmp    $0x400,%edx
f0105b87:	75 1a                	jne    f0105ba3 <sched_yield+0x113>
		cprintf("No more runnable environments!\n");
f0105b89:	c7 04 24 f0 a3 10 f0 	movl   $0xf010a3f0,(%esp)
f0105b90:	e8 7a f0 ff ff       	call   f0104c0f <cprintf>
		while (1)
			monitor(NULL);
f0105b95:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0105b9c:	e8 08 b0 ff ff       	call   f0100ba9 <monitor>
f0105ba1:	eb f2                	jmp    f0105b95 <sched_yield+0x105>
	}

	// Run this CPU's idle environment when nothing else is runnable.
	idle = &envs[cpunum()];
f0105ba3:	e8 f6 1f 00 00       	call   f0107b9e <cpunum>
f0105ba8:	69 c0 84 00 00 00    	imul   $0x84,%eax,%eax
f0105bae:	01 c3                	add    %eax,%ebx
	if (!(idle->env_status == ENV_RUNNABLE || idle->env_status == ENV_RUNNING))
f0105bb0:	8b 43 54             	mov    0x54(%ebx),%eax
f0105bb3:	83 e8 02             	sub    $0x2,%eax
f0105bb6:	83 f8 01             	cmp    $0x1,%eax
f0105bb9:	76 25                	jbe    f0105be0 <sched_yield+0x150>
		panic("CPU %d: No idle environment!", cpunum());
f0105bbb:	e8 de 1f 00 00       	call   f0107b9e <cpunum>
f0105bc0:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105bc4:	c7 44 24 08 10 a4 10 	movl   $0xf010a410,0x8(%esp)
f0105bcb:	f0 
f0105bcc:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f0105bd3:	00 
f0105bd4:	c7 04 24 2d a4 10 f0 	movl   $0xf010a42d,(%esp)
f0105bdb:	e8 a5 a4 ff ff       	call   f0100085 <_panic>
	env_run(idle);
f0105be0:	89 1c 24             	mov    %ebx,(%esp)
f0105be3:	e8 42 e8 ff ff       	call   f010442a <env_run>
	...

f0105bf0 <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0105bf0:	55                   	push   %ebp
f0105bf1:	89 e5                	mov    %esp,%ebp
f0105bf3:	57                   	push   %edi
f0105bf4:	56                   	push   %esi
f0105bf5:	53                   	push   %ebx
f0105bf6:	83 ec 5c             	sub    $0x5c,%esp
f0105bf9:	8b 45 08             	mov    0x8(%ebp),%eax
f0105bfc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.
        int32_t ret = 0;
        switch(syscallno){
f0105bff:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f0105c04:	83 f8 15             	cmp    $0x15,%eax
f0105c07:	0f 87 67 0a 00 00    	ja     f0106674 <syscall+0xa84>
f0105c0d:	ff 24 85 84 a4 10 f0 	jmp    *-0xfef5b7c(,%eax,4)
sys_cputs(const char *s, size_t len)
{
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.       
	// LAB 3: Your code here.
        user_mem_assert(curenv,s,len,PTE_U);
f0105c14:	e8 85 1f 00 00       	call   f0107b9e <cpunum>
f0105c19:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f0105c20:	00 
f0105c21:	8b 55 10             	mov    0x10(%ebp),%edx
f0105c24:	89 54 24 08          	mov    %edx,0x8(%esp)
f0105c28:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105c2c:	6b c0 74             	imul   $0x74,%eax,%eax
f0105c2f:	8b 80 28 40 29 f0    	mov    -0xfd6bfd8(%eax),%eax
f0105c35:	89 04 24             	mov    %eax,(%esp)
f0105c38:	e8 f2 c6 ff ff       	call   f010232f <user_mem_assert>
	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f0105c3d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0105c41:	8b 5d 10             	mov    0x10(%ebp),%ebx
f0105c44:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105c48:	c7 04 24 3a a4 10 f0 	movl   $0xf010a43a,(%esp)
f0105c4f:	e8 bb ef ff ff       	call   f0104c0f <cprintf>
f0105c54:	be 00 00 00 00       	mov    $0x0,%esi
f0105c59:	e9 16 0a 00 00       	jmp    f0106674 <syscall+0xa84>
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f0105c5e:	e8 8c a8 ff ff       	call   f01004ef <cons_getc>
f0105c63:	89 c6                	mov    %eax,%esi
        case SYS_cputs:
          sys_cputs((const char*)a1,(size_t)a2);
          break;
        case SYS_cgetc:
          ret = sys_cgetc();
          break;
f0105c65:	e9 0a 0a 00 00       	jmp    f0106674 <syscall+0xa84>

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f0105c6a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0105c70:	e8 29 1f 00 00       	call   f0107b9e <cpunum>
f0105c75:	6b c0 74             	imul   $0x74,%eax,%eax
f0105c78:	8b 80 28 40 29 f0    	mov    -0xfd6bfd8(%eax),%eax
f0105c7e:	8b 70 48             	mov    0x48(%eax),%esi
        case SYS_cgetc:
          ret = sys_cgetc();
          break;
        case SYS_getenvid:
          ret = sys_getenvid();
          break;
f0105c81:	e9 ee 09 00 00       	jmp    f0106674 <syscall+0xa84>
{
        
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f0105c86:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0105c8d:	00 
f0105c8e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0105c91:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105c95:	89 1c 24             	mov    %ebx,(%esp)
f0105c98:	e8 9b e6 ff ff       	call   f0104338 <envid2env>
f0105c9d:	89 c6                	mov    %eax,%esi
f0105c9f:	85 c0                	test   %eax,%eax
f0105ca1:	0f 88 cd 09 00 00    	js     f0106674 <syscall+0xa84>
		return r;
	if (e == curenv)
f0105ca7:	e8 f2 1e 00 00       	call   f0107b9e <cpunum>
f0105cac:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0105caf:	6b c0 74             	imul   $0x74,%eax,%eax
f0105cb2:	39 90 28 40 29 f0    	cmp    %edx,-0xfd6bfd8(%eax)
f0105cb8:	75 23                	jne    f0105cdd <syscall+0xed>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f0105cba:	e8 df 1e 00 00       	call   f0107b9e <cpunum>
f0105cbf:	6b c0 74             	imul   $0x74,%eax,%eax
f0105cc2:	8b 80 28 40 29 f0    	mov    -0xfd6bfd8(%eax),%eax
f0105cc8:	8b 40 48             	mov    0x48(%eax),%eax
f0105ccb:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105ccf:	c7 04 24 3f a4 10 f0 	movl   $0xf010a43f,(%esp)
f0105cd6:	e8 34 ef ff ff       	call   f0104c0f <cprintf>
f0105cdb:	eb 28                	jmp    f0105d05 <syscall+0x115>
	else
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f0105cdd:	8b 5a 48             	mov    0x48(%edx),%ebx
f0105ce0:	e8 b9 1e 00 00       	call   f0107b9e <cpunum>
f0105ce5:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0105ce9:	6b c0 74             	imul   $0x74,%eax,%eax
f0105cec:	8b 80 28 40 29 f0    	mov    -0xfd6bfd8(%eax),%eax
f0105cf2:	8b 40 48             	mov    0x48(%eax),%eax
f0105cf5:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105cf9:	c7 04 24 5a a4 10 f0 	movl   $0xf010a45a,(%esp)
f0105d00:	e8 0a ef ff ff       	call   f0104c0f <cprintf>
	env_destroy(e);
f0105d05:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105d08:	89 04 24             	mov    %eax,(%esp)
f0105d0b:	e8 a8 e9 ff ff       	call   f01046b8 <env_destroy>
f0105d10:	be 00 00 00 00       	mov    $0x0,%esi
f0105d15:	e9 5a 09 00 00       	jmp    f0106674 <syscall+0xa84>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0105d1a:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f0105d20:	77 20                	ja     f0105d42 <syscall+0x152>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0105d22:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0105d26:	c7 44 24 08 9c 8d 10 	movl   $0xf0108d9c,0x8(%esp)
f0105d2d:	f0 
f0105d2e:	c7 44 24 04 49 00 00 	movl   $0x49,0x4(%esp)
f0105d35:	00 
f0105d36:	c7 04 24 72 a4 10 f0 	movl   $0xf010a472,(%esp)
f0105d3d:	e8 43 a3 ff ff       	call   f0100085 <_panic>
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105d42:	81 c3 00 00 00 10    	add    $0x10000000,%ebx
f0105d48:	c1 eb 0c             	shr    $0xc,%ebx
f0105d4b:	3b 1d b4 3e 29 f0    	cmp    0xf0293eb4,%ebx
f0105d51:	72 1c                	jb     f0105d6f <syscall+0x17f>
		panic("pa2page called with invalid pa");
f0105d53:	c7 44 24 08 c8 99 10 	movl   $0xf01099c8,0x8(%esp)
f0105d5a:	f0 
f0105d5b:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f0105d62:	00 
f0105d63:	c7 04 24 72 95 10 f0 	movl   $0xf0109572,(%esp)
f0105d6a:	e8 16 a3 ff ff       	call   f0100085 <_panic>
	return &pages[PGNUM(pa)];
f0105d6f:	c1 e3 03             	shl    $0x3,%ebx
static int
sys_map_kernel_page(void* kpage, void* va)
{
	int r;
	struct Page* p = pa2page(PADDR(kpage));
	if(p ==NULL)
f0105d72:	be 03 00 00 00       	mov    $0x3,%esi
f0105d77:	03 1d bc 3e 29 f0    	add    0xf0293ebc,%ebx
f0105d7d:	0f 84 f1 08 00 00    	je     f0106674 <syscall+0xa84>
		return E_INVAL;
	r = page_insert(curenv->env_pgdir, p, va, PTE_U | PTE_W);
f0105d83:	e8 16 1e 00 00       	call   f0107b9e <cpunum>
f0105d88:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f0105d8f:	00 
f0105d90:	8b 55 10             	mov    0x10(%ebp),%edx
f0105d93:	89 54 24 08          	mov    %edx,0x8(%esp)
f0105d97:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105d9b:	6b c0 74             	imul   $0x74,%eax,%eax
f0105d9e:	8b 80 28 40 29 f0    	mov    -0xfd6bfd8(%eax),%eax
f0105da4:	8b 40 64             	mov    0x64(%eax),%eax
f0105da7:	89 04 24             	mov    %eax,(%esp)
f0105daa:	e8 a4 c6 ff ff       	call   f0102453 <page_insert>
f0105daf:	89 c6                	mov    %eax,%esi
f0105db1:	e9 be 08 00 00       	jmp    f0106674 <syscall+0xa84>

static int
sys_sbrk(uint32_t inc)
{
	// LAB3: your code sbrk here...
        uintptr_t begin = ROUNDUP(curenv->env_break,PGSIZE);
f0105db6:	e8 e3 1d 00 00       	call   f0107b9e <cpunum>
f0105dbb:	6b c0 74             	imul   $0x74,%eax,%eax
f0105dbe:	8b 80 28 40 29 f0    	mov    -0xfd6bfd8(%eax),%eax
f0105dc4:	8b 70 60             	mov    0x60(%eax),%esi
f0105dc7:	81 c6 ff 0f 00 00    	add    $0xfff,%esi
f0105dcd:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
        uintptr_t end = ROUNDUP(begin + inc,PGSIZE);
f0105dd3:	8d 84 1e ff 0f 00 00 	lea    0xfff(%esi,%ebx,1),%eax
f0105dda:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0105ddf:	89 45 c4             	mov    %eax,-0x3c(%ebp)
        while(begin < end){
f0105de2:	39 c6                	cmp    %eax,%esi
f0105de4:	73 65                	jae    f0105e4b <syscall+0x25b>
           struct Page* page = page_alloc(0);
           if(page == NULL)
               panic("page alloc failed\n");
           page_insert(curenv->env_pgdir,page,(void*)begin,PTE_U|PTE_W|PTE_P);
f0105de6:	bb 20 40 29 f0       	mov    $0xf0294020,%ebx
{
	// LAB3: your code sbrk here...
        uintptr_t begin = ROUNDUP(curenv->env_break,PGSIZE);
        uintptr_t end = ROUNDUP(begin + inc,PGSIZE);
        while(begin < end){
           struct Page* page = page_alloc(0);
f0105deb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0105df2:	e8 48 c3 ff ff       	call   f010213f <page_alloc>
f0105df7:	89 c7                	mov    %eax,%edi
           if(page == NULL)
f0105df9:	85 c0                	test   %eax,%eax
f0105dfb:	75 1c                	jne    f0105e19 <syscall+0x229>
               panic("page alloc failed\n");
f0105dfd:	c7 44 24 08 d2 9f 10 	movl   $0xf0109fd2,0x8(%esp)
f0105e04:	f0 
f0105e05:	c7 44 24 04 b6 01 00 	movl   $0x1b6,0x4(%esp)
f0105e0c:	00 
f0105e0d:	c7 04 24 72 a4 10 f0 	movl   $0xf010a472,(%esp)
f0105e14:	e8 6c a2 ff ff       	call   f0100085 <_panic>
           page_insert(curenv->env_pgdir,page,(void*)begin,PTE_U|PTE_W|PTE_P);
f0105e19:	e8 80 1d 00 00       	call   f0107b9e <cpunum>
f0105e1e:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
f0105e25:	00 
f0105e26:	89 74 24 08          	mov    %esi,0x8(%esp)
f0105e2a:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105e2e:	6b c0 74             	imul   $0x74,%eax,%eax
f0105e31:	8b 44 18 08          	mov    0x8(%eax,%ebx,1),%eax
f0105e35:	8b 40 64             	mov    0x64(%eax),%eax
f0105e38:	89 04 24             	mov    %eax,(%esp)
f0105e3b:	e8 13 c6 ff ff       	call   f0102453 <page_insert>
           begin += PGSIZE;
f0105e40:	81 c6 00 10 00 00    	add    $0x1000,%esi
sys_sbrk(uint32_t inc)
{
	// LAB3: your code sbrk here...
        uintptr_t begin = ROUNDUP(curenv->env_break,PGSIZE);
        uintptr_t end = ROUNDUP(begin + inc,PGSIZE);
        while(begin < end){
f0105e46:	39 75 c4             	cmp    %esi,-0x3c(%ebp)
f0105e49:	77 a0                	ja     f0105deb <syscall+0x1fb>
           if(page == NULL)
               panic("page alloc failed\n");
           page_insert(curenv->env_pgdir,page,(void*)begin,PTE_U|PTE_W|PTE_P);
           begin += PGSIZE;
        }
        curenv->env_break = end;
f0105e4b:	e8 4e 1d 00 00       	call   f0107b9e <cpunum>
f0105e50:	bb 20 40 29 f0       	mov    $0xf0294020,%ebx
f0105e55:	6b c0 74             	imul   $0x74,%eax,%eax
f0105e58:	8b 44 18 08          	mov    0x8(%eax,%ebx,1),%eax
f0105e5c:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f0105e5f:	89 50 60             	mov    %edx,0x60(%eax)
	return curenv->env_break;
f0105e62:	e8 37 1d 00 00       	call   f0107b9e <cpunum>
f0105e67:	6b c0 74             	imul   $0x74,%eax,%eax
f0105e6a:	8b 44 18 08          	mov    0x8(%eax,%ebx,1),%eax
f0105e6e:	8b 70 60             	mov    0x60(%eax),%esi
        case SYS_map_kernel_page:
          ret = sys_map_kernel_page((void*)a1,(void*)a2);
          break;
        case SYS_sbrk:
          ret = sys_sbrk(a1);
          break;
f0105e71:	e9 fe 07 00 00       	jmp    f0106674 <syscall+0xa84>

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
	sched_yield();
f0105e76:	e8 15 fc ff ff       	call   f0105a90 <sched_yield>
	// from the current environment -- but tweaked so sys_exofork
	// will appear to return 0.
        struct Env* forkEnv;
        uint32_t ret;
        //panic("1111111\n");
        ret = env_alloc(&forkEnv,curenv->env_id);
f0105e7b:	e8 1e 1d 00 00       	call   f0107b9e <cpunum>
f0105e80:	bb 20 40 29 f0       	mov    $0xf0294020,%ebx
f0105e85:	6b c0 74             	imul   $0x74,%eax,%eax
f0105e88:	8b 44 18 08          	mov    0x8(%eax,%ebx,1),%eax
f0105e8c:	8b 40 48             	mov    0x48(%eax),%eax
f0105e8f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105e93:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0105e96:	89 04 24             	mov    %eax,(%esp)
f0105e99:	e8 78 e8 ff ff       	call   f0104716 <env_alloc>
        if(ret < 0){
           return ret;
        }
        forkEnv->env_status = ENV_NOT_RUNNABLE;
f0105e9e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105ea1:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)

        forkEnv->env_tf = curenv->env_tf;
f0105ea8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105eab:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0105eae:	e8 eb 1c 00 00       	call   f0107b9e <cpunum>
f0105eb3:	6b c0 74             	imul   $0x74,%eax,%eax
f0105eb6:	8b 74 18 08          	mov    0x8(%eax,%ebx,1),%esi
f0105eba:	b9 11 00 00 00       	mov    $0x11,%ecx
f0105ebf:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0105ec2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
        forkEnv->env_tf.tf_regs.reg_eax = 0;
f0105ec4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105ec7:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
        //cprintf("env_id:%d\n",forkEnv->env_id);
        return forkEnv->env_id;
f0105ece:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105ed1:	8b 70 48             	mov    0x48(%eax),%esi
        case SYS_yield:
          sys_yield();
          break;
        case SYS_exofork:
          ret = sys_exofork();
          break;
f0105ed4:	e9 9b 07 00 00       	jmp    f0106674 <syscall+0xa84>
	// check whether the current environment has permission to set
	// envid's status.

	// LAB 4: Your code here.
        struct Env* env;
        uint32_t ret = envid2env(envid,&env,1);
f0105ed9:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0105ee0:	00 
f0105ee1:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0105ee4:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105ee8:	89 1c 24             	mov    %ebx,(%esp)
f0105eeb:	e8 48 e4 ff ff       	call   f0104338 <envid2env>
        if(ret < 0)
            return -E_BAD_ENV;
        env->env_status = status;
f0105ef0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105ef3:	8b 55 10             	mov    0x10(%ebp),%edx
f0105ef6:	89 50 54             	mov    %edx,0x54(%eax)
f0105ef9:	be 00 00 00 00       	mov    $0x0,%esi
        case SYS_exofork:
          ret = sys_exofork();
          break;
        case SYS_env_set_status:
          ret = sys_env_set_status((envid_t)a1,(int)a2);
          break;
f0105efe:	e9 71 07 00 00       	jmp    f0106674 <syscall+0xa84>
//		or the caller doesn't have permission to change envid.
static int
sys_env_set_pgfault_upcall(envid_t envid, void *func)
{
        struct Env* env;
        uint32_t ret = envid2env(envid,&env,1);
f0105f03:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0105f0a:	00 
f0105f0b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0105f0e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105f12:	89 1c 24             	mov    %ebx,(%esp)
f0105f15:	e8 1e e4 ff ff       	call   f0104338 <envid2env>
        if(ret < 0)
            return -E_BAD_ENV;
        env->env_pgfault_upcall = func;
f0105f1a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105f1d:	8b 5d 10             	mov    0x10(%ebp),%ebx
f0105f20:	89 58 68             	mov    %ebx,0x68(%eax)
f0105f23:	be 00 00 00 00       	mov    $0x0,%esi
        case SYS_env_set_status:
          ret = sys_env_set_status((envid_t)a1,(int)a2);
          break;
        case SYS_env_set_pgfault_upcall:
          ret = sys_env_set_pgfault_upcall((envid_t)a1, (void *)a2);
          break;
f0105f28:	e9 47 07 00 00       	jmp    f0106674 <syscall+0xa84>
	//   Most of the new code you write should be to check the
	//   parameters for correctness.
	//   If page_insert() fails, remember to free the page you
	//   allocated!
        uint32_t vaddr = (uint32_t)va;
        if(vaddr >= UTOP || (vaddr%PGSIZE))
f0105f2d:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0105f34:	77 6e                	ja     f0105fa4 <syscall+0x3b4>
f0105f36:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f0105f3d:	75 65                	jne    f0105fa4 <syscall+0x3b4>
              return -E_INVAL;
        if(!(perm & PTE_P) || !(perm & PTE_U))
f0105f3f:	8b 45 14             	mov    0x14(%ebp),%eax
f0105f42:	83 e0 05             	and    $0x5,%eax
f0105f45:	83 f8 05             	cmp    $0x5,%eax
f0105f48:	75 5a                	jne    f0105fa4 <syscall+0x3b4>
              return -E_INVAL;
        struct Env* env;
        struct Page* page;
        uint32_t ret = envid2env(envid,&env,1);
f0105f4a:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0105f51:	00 
f0105f52:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0105f55:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105f59:	89 1c 24             	mov    %ebx,(%esp)
f0105f5c:	e8 d7 e3 ff ff       	call   f0104338 <envid2env>
        if(ret < 0)
            return -E_BAD_ENV;
        page = page_alloc(ALLOC_ZERO);
f0105f61:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0105f68:	e8 d2 c1 ff ff       	call   f010213f <page_alloc>
        if(!page)
f0105f6d:	be fc ff ff ff       	mov    $0xfffffffc,%esi
f0105f72:	85 c0                	test   %eax,%eax
f0105f74:	0f 84 fa 06 00 00    	je     f0106674 <syscall+0xa84>
            return -E_NO_MEM;
        ret = page_insert(env->env_pgdir,page,va,perm);
f0105f7a:	8b 55 14             	mov    0x14(%ebp),%edx
f0105f7d:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0105f81:	8b 5d 10             	mov    0x10(%ebp),%ebx
f0105f84:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0105f88:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105f8c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105f8f:	8b 40 64             	mov    0x64(%eax),%eax
f0105f92:	89 04 24             	mov    %eax,(%esp)
f0105f95:	e8 b9 c4 ff ff       	call   f0102453 <page_insert>
f0105f9a:	be 00 00 00 00       	mov    $0x0,%esi
f0105f9f:	e9 d0 06 00 00       	jmp    f0106674 <syscall+0xa84>
f0105fa4:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f0105fa9:	e9 c6 06 00 00       	jmp    f0106674 <syscall+0xa84>
	//   parameters for correctness.
	//   Use the third argument to page_lookup() to
	//   check the current permissions on the page.
        uint32_t srcvaddr = (uint32_t)srcva;
        uint32_t dstvaddr = (uint32_t)dstva;
        if(srcvaddr >= UTOP || (srcvaddr%PGSIZE) || dstvaddr >= UTOP || (dstvaddr%PGSIZE))
f0105fae:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0105fb5:	0f 87 c3 00 00 00    	ja     f010607e <syscall+0x48e>
          break;
        case SYS_page_alloc:
          ret = sys_page_alloc((envid_t)a1, (void *)a2, (int)a3);
          break;
        case SYS_page_map:{
          uint32_t dstva = (uint32_t)a4 & 0xFFFFF000;
f0105fbb:	8b 75 18             	mov    0x18(%ebp),%esi
f0105fbe:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	//   parameters for correctness.
	//   Use the third argument to page_lookup() to
	//   check the current permissions on the page.
        uint32_t srcvaddr = (uint32_t)srcva;
        uint32_t dstvaddr = (uint32_t)dstva;
        if(srcvaddr >= UTOP || (srcvaddr%PGSIZE) || dstvaddr >= UTOP || (dstvaddr%PGSIZE))
f0105fc4:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f0105fcb:	0f 85 ad 00 00 00    	jne    f010607e <syscall+0x48e>
f0105fd1:	81 fe ff ff bf ee    	cmp    $0xeebfffff,%esi
f0105fd7:	0f 87 a1 00 00 00    	ja     f010607e <syscall+0x48e>
        case SYS_page_alloc:
          ret = sys_page_alloc((envid_t)a1, (void *)a2, (int)a3);
          break;
        case SYS_page_map:{
          uint32_t dstva = (uint32_t)a4 & 0xFFFFF000;
          uint32_t perm = (uint32_t)a4 & 0xFFF;
f0105fdd:	8b 7d 18             	mov    0x18(%ebp),%edi
f0105fe0:	81 e7 ff 0f 00 00    	and    $0xfff,%edi
	//   check the current permissions on the page.
        uint32_t srcvaddr = (uint32_t)srcva;
        uint32_t dstvaddr = (uint32_t)dstva;
        if(srcvaddr >= UTOP || (srcvaddr%PGSIZE) || dstvaddr >= UTOP || (dstvaddr%PGSIZE))
              return -E_INVAL;
        if(!(perm & PTE_P) || !(perm & PTE_U))
f0105fe6:	8b 45 18             	mov    0x18(%ebp),%eax
f0105fe9:	83 e0 05             	and    $0x5,%eax
f0105fec:	83 f8 05             	cmp    $0x5,%eax
f0105fef:	0f 85 89 00 00 00    	jne    f010607e <syscall+0x48e>
              return -E_INVAL;
        struct Env* srcenv;
        struct Env* dstenv;
        uint32_t ret;
        ret = envid2env(srcenvid,&srcenv,1);
f0105ff5:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0105ffc:	00 
f0105ffd:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0106000:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106004:	89 1c 24             	mov    %ebx,(%esp)
f0106007:	e8 2c e3 ff ff       	call   f0104338 <envid2env>
        if(ret < 0)
           return -E_BAD_ENV;
        ret = envid2env(dstenvid,&dstenv,1);
f010600c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0106013:	00 
f0106014:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0106017:	89 44 24 04          	mov    %eax,0x4(%esp)
f010601b:	8b 45 14             	mov    0x14(%ebp),%eax
f010601e:	89 04 24             	mov    %eax,(%esp)
f0106021:	e8 12 e3 ff ff       	call   f0104338 <envid2env>
        if(ret < 0)
           return -E_BAD_ENV;
        struct Page* page;
        pte_t* pte;
        page = page_lookup(srcenv->env_pgdir,srcva,&pte);
f0106026:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0106029:	89 44 24 08          	mov    %eax,0x8(%esp)
f010602d:	8b 55 10             	mov    0x10(%ebp),%edx
f0106030:	89 54 24 04          	mov    %edx,0x4(%esp)
f0106034:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0106037:	8b 40 64             	mov    0x64(%eax),%eax
f010603a:	89 04 24             	mov    %eax,(%esp)
f010603d:	e8 45 c3 ff ff       	call   f0102387 <page_lookup>
        if(page == NULL)
f0106042:	85 c0                	test   %eax,%eax
f0106044:	74 38                	je     f010607e <syscall+0x48e>
           return -E_INVAL;
        if(!(perm & PTE_P) || !(perm & PTE_U) || (!pte))
f0106046:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0106049:	85 d2                	test   %edx,%edx
f010604b:	74 31                	je     f010607e <syscall+0x48e>
              return -E_INVAL;
        if((perm & PTE_W) && (!((*pte) & PTE_W)))
f010604d:	f7 c7 02 00 00 00    	test   $0x2,%edi
f0106053:	74 05                	je     f010605a <syscall+0x46a>
f0106055:	f6 02 02             	testb  $0x2,(%edx)
f0106058:	74 24                	je     f010607e <syscall+0x48e>
              return -E_INVAL;
        ret = page_insert(dstenv->env_pgdir,page,dstva,perm);
f010605a:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f010605e:	89 74 24 08          	mov    %esi,0x8(%esp)
f0106062:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106066:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0106069:	8b 40 64             	mov    0x64(%eax),%eax
f010606c:	89 04 24             	mov    %eax,(%esp)
f010606f:	e8 df c3 ff ff       	call   f0102453 <page_insert>
f0106074:	be 00 00 00 00       	mov    $0x0,%esi
f0106079:	e9 f6 05 00 00       	jmp    f0106674 <syscall+0xa84>
f010607e:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f0106083:	e9 ec 05 00 00       	jmp    f0106674 <syscall+0xa84>
sys_page_unmap(envid_t envid, void *va)
{
	// Hint: This function is a wrapper around page_remove().
        uint32_t vaddr = (uint32_t)va;
        struct Env* env;
        if(vaddr >= UTOP || (vaddr%PGSIZE))
f0106088:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f010608f:	90                   	nop
f0106090:	77 3f                	ja     f01060d1 <syscall+0x4e1>
f0106092:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f0106099:	75 36                	jne    f01060d1 <syscall+0x4e1>
              return -E_INVAL;        
        uint32_t ret = envid2env(envid,&env,1);
f010609b:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01060a2:	00 
f01060a3:	8d 45 e0             	lea    -0x20(%ebp),%eax
f01060a6:	89 44 24 04          	mov    %eax,0x4(%esp)
f01060aa:	89 1c 24             	mov    %ebx,(%esp)
f01060ad:	e8 86 e2 ff ff       	call   f0104338 <envid2env>
        if(ret < 0)
            return -E_BAD_ENV;
        page_remove(env->env_pgdir,va);
f01060b2:	8b 5d 10             	mov    0x10(%ebp),%ebx
f01060b5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01060b9:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01060bc:	8b 40 64             	mov    0x64(%eax),%eax
f01060bf:	89 04 24             	mov    %eax,(%esp)
f01060c2:	e8 31 c3 ff ff       	call   f01023f8 <page_remove>
f01060c7:	be 00 00 00 00       	mov    $0x0,%esi
f01060cc:	e9 a3 05 00 00       	jmp    f0106674 <syscall+0xa84>
f01060d1:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f01060d6:	e9 99 05 00 00       	jmp    f0106674 <syscall+0xa84>
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, unsigned perm)
{
	// LAB 4: Your code here.
        struct Env* env;
        uint32_t srcvaddr = (uint32_t)srcva;
        uint32_t ret = envid2env(envid,&env,0);
f01060db:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01060e2:	00 
f01060e3:	8d 45 e0             	lea    -0x20(%ebp),%eax
f01060e6:	89 44 24 04          	mov    %eax,0x4(%esp)
f01060ea:	89 1c 24             	mov    %ebx,(%esp)
f01060ed:	e8 46 e2 ff ff       	call   f0104338 <envid2env>
        if(ret < 0)
            return -E_BAD_ENV;
        if((!env->env_ipc_recving) || env->env_ipc_from)
f01060f2:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01060f5:	83 78 6c 00          	cmpl   $0x0,0x6c(%eax)
f01060f9:	0f 84 0e 01 00 00    	je     f010620d <syscall+0x61d>
f01060ff:	83 78 78 00          	cmpl   $0x0,0x78(%eax)
f0106103:	0f 85 04 01 00 00    	jne    f010620d <syscall+0x61d>
            return -E_IPC_NOT_RECV;
        if(srcvaddr < UTOP){
f0106109:	81 7d 14 ff ff bf ee 	cmpl   $0xeebfffff,0x14(%ebp)
f0106110:	0f 87 af 00 00 00    	ja     f01061c5 <syscall+0x5d5>
            if(srcvaddr % PGSIZE)
f0106116:	f7 45 14 ff 0f 00 00 	testl  $0xfff,0x14(%ebp)
f010611d:	8d 76 00             	lea    0x0(%esi),%esi
f0106120:	0f 85 f1 00 00 00    	jne    f0106217 <syscall+0x627>
                 return -E_INVAL;
            if(!(perm & PTE_P) || !(perm & PTE_U))
f0106126:	8b 45 18             	mov    0x18(%ebp),%eax
f0106129:	83 e0 05             	and    $0x5,%eax
f010612c:	83 f8 05             	cmp    $0x5,%eax
f010612f:	0f 85 e2 00 00 00    	jne    f0106217 <syscall+0x627>
                 return -E_INVAL;
            pte_t* pte;
            struct Page* page = page_lookup(curenv->env_pgdir,srcva,&pte);
f0106135:	e8 64 1a 00 00       	call   f0107b9e <cpunum>
f010613a:	8d 55 dc             	lea    -0x24(%ebp),%edx
f010613d:	89 54 24 08          	mov    %edx,0x8(%esp)
f0106141:	8b 55 14             	mov    0x14(%ebp),%edx
f0106144:	89 54 24 04          	mov    %edx,0x4(%esp)
f0106148:	6b c0 74             	imul   $0x74,%eax,%eax
f010614b:	8b 80 28 40 29 f0    	mov    -0xfd6bfd8(%eax),%eax
f0106151:	8b 40 64             	mov    0x64(%eax),%eax
f0106154:	89 04 24             	mov    %eax,(%esp)
f0106157:	e8 2b c2 ff ff       	call   f0102387 <page_lookup>
            if((!page) || (!pte) || (!((*pte) & PTE_P)) || (!((*pte) & PTE_U)))
f010615c:	85 c0                	test   %eax,%eax
f010615e:	0f 84 b3 00 00 00    	je     f0106217 <syscall+0x627>
f0106164:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0106167:	85 d2                	test   %edx,%edx
f0106169:	0f 84 a8 00 00 00    	je     f0106217 <syscall+0x627>
f010616f:	8b 12                	mov    (%edx),%edx
f0106171:	89 d1                	mov    %edx,%ecx
f0106173:	83 e1 05             	and    $0x5,%ecx
f0106176:	83 f9 05             	cmp    $0x5,%ecx
f0106179:	0f 85 98 00 00 00    	jne    f0106217 <syscall+0x627>
                 return -E_INVAL;
            if((perm & PTE_W) && (!((*pte) & PTE_W)))
f010617f:	f6 45 18 02          	testb  $0x2,0x18(%ebp)
f0106183:	74 09                	je     f010618e <syscall+0x59e>
f0106185:	f6 c2 02             	test   $0x2,%dl
f0106188:	0f 84 89 00 00 00    	je     f0106217 <syscall+0x627>
                 return -E_INVAL;
            if((uint32_t)env->env_ipc_dstva < UTOP){
f010618e:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0106191:	8b 4a 70             	mov    0x70(%edx),%ecx
f0106194:	81 f9 ff ff bf ee    	cmp    $0xeebfffff,%ecx
f010619a:	77 22                	ja     f01061be <syscall+0x5ce>
                 ret = page_insert(env->env_pgdir,page,env->env_ipc_dstva,perm);
f010619c:	8b 5d 18             	mov    0x18(%ebp),%ebx
f010619f:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f01061a3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01061a7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01061ab:	8b 42 64             	mov    0x64(%edx),%eax
f01061ae:	89 04 24             	mov    %eax,(%esp)
f01061b1:	e8 9d c2 ff ff       	call   f0102453 <page_insert>
                 if(ret < 0)
                    return ret;
                 env->env_ipc_perm = perm;
f01061b6:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01061b9:	89 58 7c             	mov    %ebx,0x7c(%eax)
f01061bc:	eb 07                	jmp    f01061c5 <syscall+0x5d5>
            }
            else
                 env->env_ipc_perm = 0;
f01061be:	c7 42 7c 00 00 00 00 	movl   $0x0,0x7c(%edx)
         }
         env->env_ipc_recving = 0;
f01061c5:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01061c8:	c7 40 6c 00 00 00 00 	movl   $0x0,0x6c(%eax)
         env->env_ipc_value = value;
f01061cf:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01061d2:	8b 55 10             	mov    0x10(%ebp),%edx
f01061d5:	89 50 74             	mov    %edx,0x74(%eax)
         env->env_ipc_from = curenv->env_id;
f01061d8:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f01061db:	e8 be 19 00 00       	call   f0107b9e <cpunum>
f01061e0:	6b c0 74             	imul   $0x74,%eax,%eax
f01061e3:	8b 80 28 40 29 f0    	mov    -0xfd6bfd8(%eax),%eax
f01061e9:	8b 40 48             	mov    0x48(%eax),%eax
f01061ec:	89 43 78             	mov    %eax,0x78(%ebx)
         env->env_status = ENV_RUNNABLE;
f01061ef:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01061f2:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
         env->env_tf.tf_regs.reg_eax = 0;
f01061f9:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01061fc:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
f0106203:	be 00 00 00 00       	mov    $0x0,%esi
f0106208:	e9 67 04 00 00       	jmp    f0106674 <syscall+0xa84>
f010620d:	be f9 ff ff ff       	mov    $0xfffffff9,%esi
f0106212:	e9 5d 04 00 00       	jmp    f0106674 <syscall+0xa84>
f0106217:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f010621c:	e9 53 04 00 00       	jmp    f0106674 <syscall+0xa84>
//	-E_INVAL if dstva < UTOP but dstva is not page-aligned.
static int
sys_ipc_recv(void *dstva)
{
	// LAB 4: Your code here.
        if((uint32_t)dstva < UTOP){
f0106221:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
f0106227:	77 13                	ja     f010623c <syscall+0x64c>
           if((uint32_t)dstva % PGSIZE)
f0106229:	f7 c3 ff 0f 00 00    	test   $0xfff,%ebx
f010622f:	90                   	nop
f0106230:	74 0a                	je     f010623c <syscall+0x64c>
f0106232:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f0106237:	e9 38 04 00 00       	jmp    f0106674 <syscall+0xa84>
                 return -E_INVAL;
        }
        curenv->env_ipc_recving = 1;
f010623c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106240:	e8 59 19 00 00       	call   f0107b9e <cpunum>
f0106245:	be 20 40 29 f0       	mov    $0xf0294020,%esi
f010624a:	6b c0 74             	imul   $0x74,%eax,%eax
f010624d:	8b 44 30 08          	mov    0x8(%eax,%esi,1),%eax
f0106251:	c7 40 6c 01 00 00 00 	movl   $0x1,0x6c(%eax)
        curenv->env_ipc_dstva = dstva;
f0106258:	e8 41 19 00 00       	call   f0107b9e <cpunum>
f010625d:	6b c0 74             	imul   $0x74,%eax,%eax
f0106260:	8b 44 30 08          	mov    0x8(%eax,%esi,1),%eax
f0106264:	89 58 70             	mov    %ebx,0x70(%eax)
        curenv->env_ipc_from = 0;
f0106267:	e8 32 19 00 00       	call   f0107b9e <cpunum>
f010626c:	6b c0 74             	imul   $0x74,%eax,%eax
f010626f:	8b 44 30 08          	mov    0x8(%eax,%esi,1),%eax
f0106273:	c7 40 78 00 00 00 00 	movl   $0x0,0x78(%eax)
        curenv->env_status = ENV_NOT_RUNNABLE;
f010627a:	e8 1f 19 00 00       	call   f0107b9e <cpunum>
f010627f:	6b c0 74             	imul   $0x74,%eax,%eax
f0106282:	8b 44 30 08          	mov    0x8(%eax,%esi,1),%eax
f0106286:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
        sched_yield();
f010628d:	e8 fe f7 ff ff       	call   f0105a90 <sched_yield>


static int 
sys_env_set_prior(envid_t envid, uint32_t prior){
        struct Env* env;
        uint32_t ret = envid2env(envid,&env,1);
f0106292:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0106299:	00 
f010629a:	8d 45 dc             	lea    -0x24(%ebp),%eax
f010629d:	89 44 24 04          	mov    %eax,0x4(%esp)
f01062a1:	89 1c 24             	mov    %ebx,(%esp)
f01062a4:	e8 8f e0 ff ff       	call   f0104338 <envid2env>
        if(ret < 0)
            return -E_BAD_ENV;
        env->env_prior = prior;
f01062a9:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01062ac:	8b 5d 10             	mov    0x10(%ebp),%ebx
f01062af:	89 98 80 00 00 00    	mov    %ebx,0x80(%eax)
f01062b5:	be 00 00 00 00       	mov    $0x0,%esi
        case SYS_ipc_recv:
          ret = sys_ipc_recv((void*)a1);
          break;
        case SYS_env_set_prior:
          ret = sys_env_set_prior((envid_t)a1,(uint32_t)a2);
          break;
f01062ba:	e9 b5 03 00 00       	jmp    f0106674 <syscall+0xa84>
	// LAB 5: Your code here.
	// Remember to check whether the user has supplied us with a good
	// address!
        struct Env* env;
        int r;
        r = envid2env(envid,&env,1);
f01062bf:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01062c6:	00 
f01062c7:	8d 45 dc             	lea    -0x24(%ebp),%eax
f01062ca:	89 44 24 04          	mov    %eax,0x4(%esp)
f01062ce:	89 1c 24             	mov    %ebx,(%esp)
f01062d1:	e8 62 e0 ff ff       	call   f0104338 <envid2env>
        if(r < 0)
f01062d6:	be fe ff ff ff       	mov    $0xfffffffe,%esi
f01062db:	85 c0                	test   %eax,%eax
f01062dd:	0f 88 91 03 00 00    	js     f0106674 <syscall+0xa84>
          return -E_BAD_ENV;
        user_mem_assert(env,tf,sizeof(struct Trapframe),PTE_P|PTE_U);
f01062e3:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
f01062ea:	00 
f01062eb:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
f01062f2:	00 
f01062f3:	8b 45 10             	mov    0x10(%ebp),%eax
f01062f6:	89 44 24 04          	mov    %eax,0x4(%esp)
f01062fa:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01062fd:	89 04 24             	mov    %eax,(%esp)
f0106300:	e8 2a c0 ff ff       	call   f010232f <user_mem_assert>
        env->env_tf = *tf;
f0106305:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0106308:	b9 11 00 00 00       	mov    $0x11,%ecx
f010630d:	89 c7                	mov    %eax,%edi
f010630f:	8b 75 10             	mov    0x10(%ebp),%esi
f0106312:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
        env->env_tf.tf_cs = GD_UT|3;
f0106314:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0106317:	66 c7 40 34 1b 00    	movw   $0x1b,0x34(%eax)
        env->env_tf.tf_eflags |= FL_IF;
f010631d:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0106320:	81 48 38 00 02 00 00 	orl    $0x200,0x38(%eax)
f0106327:	be 00 00 00 00       	mov    $0x0,%esi
f010632c:	e9 43 03 00 00       	jmp    f0106674 <syscall+0xa84>
        uint32_t begin, end;
        int perm;
        int r;
        struct Page* pg;
        struct Proghdr* ph = (struct Proghdr*) vph;
        for (i = 0; i < phnum; i++, ph++) {
f0106331:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0106335:	0f 84 fe 00 00 00    	je     f0106439 <syscall+0x849>
        uint32_t tmp = FTEMP;
        uint32_t begin, end;
        int perm;
        int r;
        struct Page* pg;
        struct Proghdr* ph = (struct Proghdr*) vph;
f010633b:	89 5d b8             	mov    %ebx,-0x48(%ebp)
f010633e:	bf 00 00 00 e0       	mov    $0xe0000000,%edi
f0106343:	c7 45 b0 00 00 00 00 	movl   $0x0,-0x50(%ebp)
        for (i = 0; i < phnum; i++, ph++) {
	      if (ph->p_type != ELF_PROG_LOAD)
f010634a:	8b 55 b8             	mov    -0x48(%ebp),%edx
f010634d:	83 3a 01             	cmpl   $0x1,(%edx)
f0106350:	0f 85 ce 00 00 00    	jne    f0106424 <syscall+0x834>
		   continue;
	      perm = PTE_P | PTE_U;
	      if (ph->p_flags & ELF_PROG_FLAG_WRITE)
f0106356:	8b 42 18             	mov    0x18(%edx),%eax
f0106359:	83 e0 02             	and    $0x2,%eax
f010635c:	83 f8 01             	cmp    $0x1,%eax
f010635f:	19 db                	sbb    %ebx,%ebx
f0106361:	83 e3 fe             	and    $0xfffffffe,%ebx
f0106364:	83 c3 07             	add    $0x7,%ebx
f0106367:	89 5d bc             	mov    %ebx,-0x44(%ebp)
		   perm |= PTE_W;
              end = ROUNDUP(ph->p_va + ph->p_memsz, PGSIZE);
f010636a:	8b 5a 08             	mov    0x8(%edx),%ebx
f010636d:	89 d8                	mov    %ebx,%eax
f010636f:	03 42 14             	add    0x14(%edx),%eax
f0106372:	05 ff 0f 00 00       	add    $0xfff,%eax
f0106377:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010637c:	89 45 b4             	mov    %eax,-0x4c(%ebp)
	      for (begin = ROUNDDOWN(ph->p_va, PGSIZE); begin != end; begin += PGSIZE) {
f010637f:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f0106385:	39 d8                	cmp    %ebx,%eax
f0106387:	0f 84 97 00 00 00    	je     f0106424 <syscall+0x834>
f010638d:	89 7d c0             	mov    %edi,-0x40(%ebp)
		   if ((pg = page_lookup(curenv->env_pgdir, (void *)tmp, NULL)) == NULL) 
f0106390:	e8 09 18 00 00       	call   f0107b9e <cpunum>
f0106395:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010639c:	00 
f010639d:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01063a1:	6b c0 74             	imul   $0x74,%eax,%eax
f01063a4:	8b 80 28 40 29 f0    	mov    -0xfd6bfd8(%eax),%eax
f01063aa:	8b 40 64             	mov    0x64(%eax),%eax
f01063ad:	89 04 24             	mov    %eax,(%esp)
f01063b0:	e8 d2 bf ff ff       	call   f0102387 <page_lookup>
f01063b5:	89 c6                	mov    %eax,%esi
f01063b7:	85 c0                	test   %eax,%eax
f01063b9:	0f 84 3d 01 00 00    	je     f01064fc <syscall+0x90c>
			  return -E_NO_MEM;
		   if ((r = page_insert(curenv->env_pgdir, pg, (void *)begin, perm)) < 0)
f01063bf:	e8 da 17 00 00       	call   f0107b9e <cpunum>
f01063c4:	8b 55 bc             	mov    -0x44(%ebp),%edx
f01063c7:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01063cb:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01063cf:	89 74 24 04          	mov    %esi,0x4(%esp)
f01063d3:	6b c0 74             	imul   $0x74,%eax,%eax
f01063d6:	8b 80 28 40 29 f0    	mov    -0xfd6bfd8(%eax),%eax
f01063dc:	8b 40 64             	mov    0x64(%eax),%eax
f01063df:	89 04 24             	mov    %eax,(%esp)
f01063e2:	e8 6c c0 ff ff       	call   f0102453 <page_insert>
f01063e7:	85 c0                	test   %eax,%eax
f01063e9:	0f 88 83 02 00 00    	js     f0106672 <syscall+0xa82>
			  return r;
		   page_remove(curenv->env_pgdir, (void *)tmp);
f01063ef:	e8 aa 17 00 00       	call   f0107b9e <cpunum>
f01063f4:	8b 55 c0             	mov    -0x40(%ebp),%edx
f01063f7:	89 54 24 04          	mov    %edx,0x4(%esp)
f01063fb:	6b c0 74             	imul   $0x74,%eax,%eax
f01063fe:	8b 80 28 40 29 f0    	mov    -0xfd6bfd8(%eax),%eax
f0106404:	8b 40 64             	mov    0x64(%eax),%eax
f0106407:	89 04 24             	mov    %eax,(%esp)
f010640a:	e8 e9 bf ff ff       	call   f01023f8 <page_remove>
                   tmp += PGSIZE;
f010640f:	81 c7 00 10 00 00    	add    $0x1000,%edi
		   continue;
	      perm = PTE_P | PTE_U;
	      if (ph->p_flags & ELF_PROG_FLAG_WRITE)
		   perm |= PTE_W;
              end = ROUNDUP(ph->p_va + ph->p_memsz, PGSIZE);
	      for (begin = ROUNDDOWN(ph->p_va, PGSIZE); begin != end; begin += PGSIZE) {
f0106415:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f010641b:	39 5d b4             	cmp    %ebx,-0x4c(%ebp)
f010641e:	0f 85 69 ff ff ff    	jne    f010638d <syscall+0x79d>
        uint32_t begin, end;
        int perm;
        int r;
        struct Page* pg;
        struct Proghdr* ph = (struct Proghdr*) vph;
        for (i = 0; i < phnum; i++, ph++) {
f0106424:	83 45 b0 01          	addl   $0x1,-0x50(%ebp)
f0106428:	8b 5d b0             	mov    -0x50(%ebp),%ebx
f010642b:	39 5d 10             	cmp    %ebx,0x10(%ebp)
f010642e:	76 0e                	jbe    f010643e <syscall+0x84e>
f0106430:	83 45 b8 20          	addl   $0x20,-0x48(%ebp)
f0106434:	e9 11 ff ff ff       	jmp    f010634a <syscall+0x75a>
f0106439:	bf 00 00 00 e0       	mov    $0xe0000000,%edi
			  return r;
		   page_remove(curenv->env_pgdir, (void *)tmp);
                   tmp += PGSIZE;
	      }
        }
        if ((pg = page_lookup(curenv->env_pgdir, (void *)tmp, NULL)) == NULL) 
f010643e:	e8 5b 17 00 00       	call   f0107b9e <cpunum>
f0106443:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010644a:	00 
f010644b:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010644f:	6b c0 74             	imul   $0x74,%eax,%eax
f0106452:	8b 80 28 40 29 f0    	mov    -0xfd6bfd8(%eax),%eax
f0106458:	8b 40 64             	mov    0x64(%eax),%eax
f010645b:	89 04 24             	mov    %eax,(%esp)
f010645e:	e8 24 bf ff ff       	call   f0102387 <page_lookup>
f0106463:	89 c3                	mov    %eax,%ebx
f0106465:	85 c0                	test   %eax,%eax
f0106467:	0f 84 8f 00 00 00    	je     f01064fc <syscall+0x90c>
	     return -E_NO_MEM;
        if ((r = page_insert(curenv->env_pgdir, pg, (void *)(USTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W)) < 0) 
f010646d:	e8 2c 17 00 00       	call   f0107b9e <cpunum>
f0106472:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
f0106479:	00 
f010647a:	c7 44 24 08 00 d0 bf 	movl   $0xeebfd000,0x8(%esp)
f0106481:	ee 
f0106482:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0106486:	6b c0 74             	imul   $0x74,%eax,%eax
f0106489:	8b 80 28 40 29 f0    	mov    -0xfd6bfd8(%eax),%eax
f010648f:	8b 40 64             	mov    0x64(%eax),%eax
f0106492:	89 04 24             	mov    %eax,(%esp)
f0106495:	e8 b9 bf ff ff       	call   f0102453 <page_insert>
f010649a:	89 c6                	mov    %eax,%esi
f010649c:	85 c0                	test   %eax,%eax
f010649e:	0f 88 d0 01 00 00    	js     f0106674 <syscall+0xa84>
	     return r;
        page_remove(curenv->env_pgdir, (void *)tmp);
f01064a4:	e8 f5 16 00 00       	call   f0107b9e <cpunum>
f01064a9:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01064ad:	bb 20 40 29 f0       	mov    $0xf0294020,%ebx
f01064b2:	6b c0 74             	imul   $0x74,%eax,%eax
f01064b5:	8b 44 18 08          	mov    0x8(%eax,%ebx,1),%eax
f01064b9:	8b 40 64             	mov    0x64(%eax),%eax
f01064bc:	89 04 24             	mov    %eax,(%esp)
f01064bf:	e8 34 bf ff ff       	call   f01023f8 <page_remove>
        curenv->env_tf.tf_esp = esp;
f01064c4:	e8 d5 16 00 00       	call   f0107b9e <cpunum>
f01064c9:	6b c0 74             	imul   $0x74,%eax,%eax
f01064cc:	8b 44 18 08          	mov    0x8(%eax,%ebx,1),%eax
f01064d0:	8b 55 14             	mov    0x14(%ebp),%edx
f01064d3:	89 50 3c             	mov    %edx,0x3c(%eax)
        curenv->env_tf.tf_eip = eip;	
f01064d6:	e8 c3 16 00 00       	call   f0107b9e <cpunum>
f01064db:	6b c0 74             	imul   $0x74,%eax,%eax
f01064de:	8b 44 18 08          	mov    0x8(%eax,%ebx,1),%eax
f01064e2:	8b 55 18             	mov    0x18(%ebp),%edx
f01064e5:	89 50 30             	mov    %edx,0x30(%eax)
        env_run(curenv);
f01064e8:	e8 b1 16 00 00       	call   f0107b9e <cpunum>
f01064ed:	6b c0 74             	imul   $0x74,%eax,%eax
f01064f0:	8b 44 18 08          	mov    0x8(%eax,%ebx,1),%eax
f01064f4:	89 04 24             	mov    %eax,(%esp)
f01064f7:	e8 2e df ff ff       	call   f010442a <env_run>
f01064fc:	be fc ff ff ff       	mov    $0xfffffffc,%esi
f0106501:	e9 6e 01 00 00       	jmp    f0106674 <syscall+0xa84>
// Return the current time.
static int
sys_time_msec(void)
{
	// LAB 6: Your code here.
        return time_msec();
f0106506:	e8 44 25 00 00       	call   f0108a4f <time_msec>
f010650b:	89 c6                	mov    %eax,%esi
        case SYS_exec:
          ret = sys_exec((void*)a1,(uint32_t)a2,(uint32_t)a3,(uint32_t)a4); 
          break;  
        case SYS_time_msec:
          ret = sys_time_msec();
          break;  
f010650d:	8d 76 00             	lea    0x0(%esi),%esi
f0106510:	e9 5f 01 00 00       	jmp    f0106674 <syscall+0xa84>
        return 0;
}

static int sys_transmit_packet(uint32_t data ,int len){
    int r;
    user_mem_assert(curenv,(void*)data,len,PTE_P|PTE_U);
f0106515:	e8 84 16 00 00       	call   f0107b9e <cpunum>
f010651a:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
f0106521:	00 
f0106522:	8b 55 10             	mov    0x10(%ebp),%edx
f0106525:	89 54 24 08          	mov    %edx,0x8(%esp)
f0106529:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010652d:	be 20 40 29 f0       	mov    $0xf0294020,%esi
f0106532:	6b c0 74             	imul   $0x74,%eax,%eax
f0106535:	8b 44 30 08          	mov    0x8(%eax,%esi,1),%eax
f0106539:	89 04 24             	mov    %eax,(%esp)
f010653c:	e8 ee bd ff ff       	call   f010232f <user_mem_assert>
    struct tx_desc td;
    memset((void*)&td,0,sizeof(struct tx_desc));
f0106541:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
f0106548:	00 
f0106549:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0106550:	00 
f0106551:	8d 45 cc             	lea    -0x34(%ebp),%eax
f0106554:	89 04 24             	mov    %eax,(%esp)
f0106557:	e8 9a 0f 00 00       	call   f01074f6 <memset>
    td.addr = va2pa(curenv->env_pgdir,data);
f010655c:	e8 3d 16 00 00       	call   f0107b9e <cpunum>
f0106561:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0106565:	6b c0 74             	imul   $0x74,%eax,%eax
f0106568:	8b 44 30 08          	mov    0x8(%eax,%esi,1),%eax
f010656c:	8b 40 64             	mov    0x64(%eax),%eax
f010656f:	89 04 24             	mov    %eax,(%esp)
f0106572:	e8 47 b7 ff ff       	call   f0101cbe <va2pa>
f0106577:	89 45 cc             	mov    %eax,-0x34(%ebp)
f010657a:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
    td.length = len;
f0106581:	0f b7 5d 10          	movzwl 0x10(%ebp),%ebx
f0106585:	66 89 5d d4          	mov    %bx,-0x2c(%ebp)
    while(1){
       r = transmit_packet(&td);
f0106589:	8d 5d cc             	lea    -0x34(%ebp),%ebx
f010658c:	89 1c 24             	mov    %ebx,(%esp)
f010658f:	e8 2e 1b 00 00       	call   f01080c2 <transmit_packet>
       if(r == 0)
f0106594:	85 c0                	test   %eax,%eax
f0106596:	75 f4                	jne    f010658c <syscall+0x99c>
f0106598:	89 c6                	mov    %eax,%esi
f010659a:	e9 d5 00 00 00       	jmp    f0106674 <syscall+0xa84>
          break;  
        case SYS_transmit_packet:
          ret = sys_transmit_packet((uint32_t)a1,(int)a2);
          break;  
        case SYS_receive_packet:
          ret = sys_receive_packet((uint32_t)a1,(int*)a2);
f010659f:	8b 7d 10             	mov    0x10(%ebp),%edi
    return r;
}

static int sys_receive_packet(uint32_t data,int* len){
    int r;
    user_mem_assert(curenv,(void*)data,MAXBUFLEN,PTE_P|PTE_U);
f01065a2:	e8 f7 15 00 00       	call   f0107b9e <cpunum>
f01065a7:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
f01065ae:	00 
f01065af:	c7 44 24 08 00 08 00 	movl   $0x800,0x8(%esp)
f01065b6:	00 
f01065b7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01065bb:	be 20 40 29 f0       	mov    $0xf0294020,%esi
f01065c0:	6b c0 74             	imul   $0x74,%eax,%eax
f01065c3:	8b 44 30 08          	mov    0x8(%eax,%esi,1),%eax
f01065c7:	89 04 24             	mov    %eax,(%esp)
f01065ca:	e8 60 bd ff ff       	call   f010232f <user_mem_assert>
    user_mem_assert(curenv,(void*)len,sizeof(int),PTE_P|PTE_U);
f01065cf:	e8 ca 15 00 00       	call   f0107b9e <cpunum>
f01065d4:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
f01065db:	00 
f01065dc:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
f01065e3:	00 
f01065e4:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01065e8:	6b c0 74             	imul   $0x74,%eax,%eax
f01065eb:	8b 44 30 08          	mov    0x8(%eax,%esi,1),%eax
f01065ef:	89 04 24             	mov    %eax,(%esp)
f01065f2:	e8 38 bd ff ff       	call   f010232f <user_mem_assert>
    struct rx_desc rd;
    r = receive_packet(&rd);
f01065f7:	8d 45 cc             	lea    -0x34(%ebp),%eax
f01065fa:	89 04 24             	mov    %eax,(%esp)
f01065fd:	e8 3e 1a 00 00       	call   f0108040 <receive_packet>
f0106602:	89 c6                	mov    %eax,%esi
    if(r < 0)
f0106604:	85 c0                	test   %eax,%eax
f0106606:	78 6c                	js     f0106674 <syscall+0xa84>
       return r;
    *len = rd.length;
f0106608:	0f b7 55 d4          	movzwl -0x2c(%ebp),%edx
f010660c:	89 17                	mov    %edx,(%edi)
    //cprintf("length:%d\n",rd.length);
    uintptr_t addr = (uintptr_t)KADDR((physaddr_t)rd.buffer_addr);
f010660e:	8b 45 cc             	mov    -0x34(%ebp),%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0106611:	89 c1                	mov    %eax,%ecx
f0106613:	c1 e9 0c             	shr    $0xc,%ecx
f0106616:	3b 0d b4 3e 29 f0    	cmp    0xf0293eb4,%ecx
f010661c:	72 20                	jb     f010663e <syscall+0xa4e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010661e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0106622:	c7 44 24 08 c0 8d 10 	movl   $0xf0108dc0,0x8(%esp)
f0106629:	f0 
f010662a:	c7 44 24 04 11 02 00 	movl   $0x211,0x4(%esp)
f0106631:	00 
f0106632:	c7 04 24 72 a4 10 f0 	movl   $0xf010a472,(%esp)
f0106639:	e8 47 9a ff ff       	call   f0100085 <_panic>
    memmove((void*)data,(void*)addr,*len);
f010663e:	89 54 24 08          	mov    %edx,0x8(%esp)
f0106642:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0106647:	89 44 24 04          	mov    %eax,0x4(%esp)
f010664b:	89 1c 24             	mov    %ebx,(%esp)
f010664e:	e8 02 0f 00 00       	call   f0107555 <memmove>
f0106653:	eb 1f                	jmp    f0106674 <syscall+0xa84>
    return r;
}

static int sys_get_mac(uint8_t* macaddr)
{
   uintptr_t ral = E1000_REG(base,E1000_RA);
f0106655:	a1 c0 3e 29 f0       	mov    0xf0293ec0,%eax
f010665a:	05 00 54 00 00       	add    $0x5400,%eax
   uintptr_t rah = ral + sizeof(uint32_t);
   *(uint32_t*)macaddr = *(uint32_t*)ral;
f010665f:	8b 10                	mov    (%eax),%edx
f0106661:	89 13                	mov    %edx,(%ebx)
   *(uint16_t*)(macaddr + 4) = *(uint16_t*)rah;
f0106663:	0f b7 40 04          	movzwl 0x4(%eax),%eax
f0106667:	66 89 43 04          	mov    %ax,0x4(%ebx)
f010666b:	be 00 00 00 00       	mov    $0x0,%esi
        case SYS_receive_packet:
          ret = sys_receive_packet((uint32_t)a1,(int*)a2);
          break;
        case SYS_get_mac:
          ret = sys_get_mac((uint8_t*)a1);
          break;  
f0106670:	eb 02                	jmp    f0106674 <syscall+0xa84>
f0106672:	89 c6                	mov    %eax,%esi
        return ret;
     
          
     
	//panic("syscall not implemented");
}
f0106674:	89 f0                	mov    %esi,%eax
f0106676:	83 c4 5c             	add    $0x5c,%esp
f0106679:	5b                   	pop    %ebx
f010667a:	5e                   	pop    %esi
f010667b:	5f                   	pop    %edi
f010667c:	5d                   	pop    %ebp
f010667d:	c3                   	ret    
	...

f0106680 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0106680:	55                   	push   %ebp
f0106681:	89 e5                	mov    %esp,%ebp
f0106683:	57                   	push   %edi
f0106684:	56                   	push   %esi
f0106685:	53                   	push   %ebx
f0106686:	83 ec 14             	sub    $0x14,%esp
f0106689:	89 45 f0             	mov    %eax,-0x10(%ebp)
f010668c:	89 55 e8             	mov    %edx,-0x18(%ebp)
f010668f:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0106692:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0106695:	8b 1a                	mov    (%edx),%ebx
f0106697:	8b 01                	mov    (%ecx),%eax
f0106699:	89 45 ec             	mov    %eax,-0x14(%ebp)
	
	while (l <= r) {
f010669c:	39 c3                	cmp    %eax,%ebx
f010669e:	0f 8f 9c 00 00 00    	jg     f0106740 <stab_binsearch+0xc0>
f01066a4:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
		int true_m = (l + r) / 2, m = true_m;
f01066ab:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01066ae:	01 d8                	add    %ebx,%eax
f01066b0:	89 c7                	mov    %eax,%edi
f01066b2:	c1 ef 1f             	shr    $0x1f,%edi
f01066b5:	01 c7                	add    %eax,%edi
f01066b7:	d1 ff                	sar    %edi
		
		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01066b9:	39 df                	cmp    %ebx,%edi
f01066bb:	7c 33                	jl     f01066f0 <stab_binsearch+0x70>
f01066bd:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f01066c0:	8b 55 f0             	mov    -0x10(%ebp),%edx
f01066c3:	0f b6 44 82 04       	movzbl 0x4(%edx,%eax,4),%eax
f01066c8:	39 f0                	cmp    %esi,%eax
f01066ca:	0f 84 bc 00 00 00    	je     f010678c <stab_binsearch+0x10c>
f01066d0:	8d 44 7f fd          	lea    -0x3(%edi,%edi,2),%eax
f01066d4:	8d 54 82 04          	lea    0x4(%edx,%eax,4),%edx
f01066d8:	89 f8                	mov    %edi,%eax
			m--;
f01066da:	83 e8 01             	sub    $0x1,%eax
	
	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
		
		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01066dd:	39 d8                	cmp    %ebx,%eax
f01066df:	7c 0f                	jl     f01066f0 <stab_binsearch+0x70>
f01066e1:	0f b6 0a             	movzbl (%edx),%ecx
f01066e4:	83 ea 0c             	sub    $0xc,%edx
f01066e7:	39 f1                	cmp    %esi,%ecx
f01066e9:	75 ef                	jne    f01066da <stab_binsearch+0x5a>
f01066eb:	e9 9e 00 00 00       	jmp    f010678e <stab_binsearch+0x10e>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f01066f0:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f01066f3:	eb 3c                	jmp    f0106731 <stab_binsearch+0xb1>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f01066f5:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f01066f8:	89 01                	mov    %eax,(%ecx)
			l = true_m + 1;
f01066fa:	8d 5f 01             	lea    0x1(%edi),%ebx
f01066fd:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f0106704:	eb 2b                	jmp    f0106731 <stab_binsearch+0xb1>
		} else if (stabs[m].n_value > addr) {
f0106706:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0106709:	76 14                	jbe    f010671f <stab_binsearch+0x9f>
			*region_right = m - 1;
f010670b:	83 e8 01             	sub    $0x1,%eax
f010670e:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0106711:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0106714:	89 02                	mov    %eax,(%edx)
f0106716:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f010671d:	eb 12                	jmp    f0106731 <stab_binsearch+0xb1>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f010671f:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0106722:	89 01                	mov    %eax,(%ecx)
			l = m;
			addr++;
f0106724:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0106728:	89 c3                	mov    %eax,%ebx
f010672a:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;
	
	while (l <= r) {
f0106731:	39 5d ec             	cmp    %ebx,-0x14(%ebp)
f0106734:	0f 8d 71 ff ff ff    	jge    f01066ab <stab_binsearch+0x2b>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f010673a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f010673e:	75 0f                	jne    f010674f <stab_binsearch+0xcf>
		*region_right = *region_left - 1;
f0106740:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f0106743:	8b 03                	mov    (%ebx),%eax
f0106745:	83 e8 01             	sub    $0x1,%eax
f0106748:	8b 55 e0             	mov    -0x20(%ebp),%edx
f010674b:	89 02                	mov    %eax,(%edx)
f010674d:	eb 57                	jmp    f01067a6 <stab_binsearch+0x126>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f010674f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0106752:	8b 01                	mov    (%ecx),%eax
		     l > *region_left && stabs[l].n_type != type;
f0106754:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f0106757:	8b 0b                	mov    (%ebx),%ecx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0106759:	39 c1                	cmp    %eax,%ecx
f010675b:	7d 28                	jge    f0106785 <stab_binsearch+0x105>
		     l > *region_left && stabs[l].n_type != type;
f010675d:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0106760:	8b 5d f0             	mov    -0x10(%ebp),%ebx
f0106763:	0f b6 54 93 04       	movzbl 0x4(%ebx,%edx,4),%edx
f0106768:	39 f2                	cmp    %esi,%edx
f010676a:	74 19                	je     f0106785 <stab_binsearch+0x105>
f010676c:	8d 54 40 fd          	lea    -0x3(%eax,%eax,2),%edx
f0106770:	8d 54 93 04          	lea    0x4(%ebx,%edx,4),%edx
		     l--)
f0106774:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0106777:	39 c1                	cmp    %eax,%ecx
f0106779:	7d 0a                	jge    f0106785 <stab_binsearch+0x105>
		     l > *region_left && stabs[l].n_type != type;
f010677b:	0f b6 1a             	movzbl (%edx),%ebx
f010677e:	83 ea 0c             	sub    $0xc,%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0106781:	39 f3                	cmp    %esi,%ebx
f0106783:	75 ef                	jne    f0106774 <stab_binsearch+0xf4>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
f0106785:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0106788:	89 02                	mov    %eax,(%edx)
f010678a:	eb 1a                	jmp    f01067a6 <stab_binsearch+0x126>
	}
}
f010678c:	89 f8                	mov    %edi,%eax
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f010678e:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0106791:	8b 4d f0             	mov    -0x10(%ebp),%ecx
f0106794:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0106798:	3b 55 0c             	cmp    0xc(%ebp),%edx
f010679b:	0f 82 54 ff ff ff    	jb     f01066f5 <stab_binsearch+0x75>
f01067a1:	e9 60 ff ff ff       	jmp    f0106706 <stab_binsearch+0x86>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f01067a6:	83 c4 14             	add    $0x14,%esp
f01067a9:	5b                   	pop    %ebx
f01067aa:	5e                   	pop    %esi
f01067ab:	5f                   	pop    %edi
f01067ac:	5d                   	pop    %ebp
f01067ad:	c3                   	ret    

f01067ae <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f01067ae:	55                   	push   %ebp
f01067af:	89 e5                	mov    %esp,%ebp
f01067b1:	83 ec 58             	sub    $0x58,%esp
f01067b4:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f01067b7:	89 75 f8             	mov    %esi,-0x8(%ebp)
f01067ba:	89 7d fc             	mov    %edi,-0x4(%ebp)
f01067bd:	8b 7d 08             	mov    0x8(%ebp),%edi
f01067c0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f01067c3:	c7 03 dc a4 10 f0    	movl   $0xf010a4dc,(%ebx)
	info->eip_line = 0;
f01067c9:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f01067d0:	c7 43 08 dc a4 10 f0 	movl   $0xf010a4dc,0x8(%ebx)
	info->eip_fn_namelen = 9;
f01067d7:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f01067de:	89 7b 10             	mov    %edi,0x10(%ebx)
	info->eip_fn_narg = 0;
f01067e1:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f01067e8:	81 ff ff ff 7f ef    	cmp    $0xef7fffff,%edi
f01067ee:	76 1a                	jbe    f010680a <debuginfo_eip+0x5c>
f01067f0:	be 37 d0 11 f0       	mov    $0xf011d037,%esi
f01067f5:	c7 45 c4 25 84 11 f0 	movl   $0xf0118425,-0x3c(%ebp)
f01067fc:	b8 24 84 11 f0       	mov    $0xf0118424,%eax
f0106801:	c7 45 c0 74 ad 10 f0 	movl   $0xf010ad74,-0x40(%ebp)
f0106808:	eb 16                	jmp    f0106820 <debuginfo_eip+0x72>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.

		stabs = usd->stabs;
f010680a:	ba 00 00 20 00       	mov    $0x200000,%edx
f010680f:	8b 02                	mov    (%edx),%eax
f0106811:	89 45 c0             	mov    %eax,-0x40(%ebp)
		stab_end = usd->stab_end;
f0106814:	8b 42 04             	mov    0x4(%edx),%eax
		stabstr = usd->stabstr;
f0106817:	8b 4a 08             	mov    0x8(%edx),%ecx
f010681a:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
		stabstr_end = usd->stabstr_end;
f010681d:	8b 72 0c             	mov    0xc(%edx),%esi
		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0106820:	39 75 c4             	cmp    %esi,-0x3c(%ebp)
f0106823:	0f 83 65 01 00 00    	jae    f010698e <debuginfo_eip+0x1e0>
f0106829:	80 7e ff 00          	cmpb   $0x0,-0x1(%esi)
f010682d:	0f 85 5b 01 00 00    	jne    f010698e <debuginfo_eip+0x1e0>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.
	
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0106833:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f010683a:	2b 45 c0             	sub    -0x40(%ebp),%eax
f010683d:	c1 f8 02             	sar    $0x2,%eax
f0106840:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0106846:	83 e8 01             	sub    $0x1,%eax
f0106849:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f010684c:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f010684f:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0106852:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0106856:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f010685d:	8b 45 c0             	mov    -0x40(%ebp),%eax
f0106860:	e8 1b fe ff ff       	call   f0106680 <stab_binsearch>
	if (lfile == 0)
f0106865:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0106868:	85 c0                	test   %eax,%eax
f010686a:	0f 84 1e 01 00 00    	je     f010698e <debuginfo_eip+0x1e0>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0106870:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0106873:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0106876:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0106879:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f010687c:	8d 55 dc             	lea    -0x24(%ebp),%edx
f010687f:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0106883:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f010688a:	8b 45 c0             	mov    -0x40(%ebp),%eax
f010688d:	e8 ee fd ff ff       	call   f0106680 <stab_binsearch>

	if (lfun <= rfun) {
f0106892:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0106895:	3b 45 d8             	cmp    -0x28(%ebp),%eax
f0106898:	7f 35                	jg     f01068cf <debuginfo_eip+0x121>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f010689a:	6b c0 0c             	imul   $0xc,%eax,%eax
f010689d:	8b 55 c0             	mov    -0x40(%ebp),%edx
f01068a0:	8b 04 10             	mov    (%eax,%edx,1),%eax
f01068a3:	89 f2                	mov    %esi,%edx
f01068a5:	2b 55 c4             	sub    -0x3c(%ebp),%edx
f01068a8:	39 d0                	cmp    %edx,%eax
f01068aa:	73 06                	jae    f01068b2 <debuginfo_eip+0x104>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f01068ac:	03 45 c4             	add    -0x3c(%ebp),%eax
f01068af:	89 43 08             	mov    %eax,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f01068b2:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01068b5:	6b c2 0c             	imul   $0xc,%edx,%eax
f01068b8:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f01068bb:	8b 44 08 08          	mov    0x8(%eax,%ecx,1),%eax
f01068bf:	89 43 10             	mov    %eax,0x10(%ebx)
		addr -= info->eip_fn_addr;
f01068c2:	29 c7                	sub    %eax,%edi
		// Search within the function definition for the line number.
		lline = lfun;
f01068c4:	89 55 d4             	mov    %edx,-0x2c(%ebp)
		rline = rfun;
f01068c7:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01068ca:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01068cd:	eb 0f                	jmp    f01068de <debuginfo_eip+0x130>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f01068cf:	89 7b 10             	mov    %edi,0x10(%ebx)
		lline = lfile;
f01068d2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01068d5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f01068d8:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01068db:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f01068de:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f01068e5:	00 
f01068e6:	8b 43 08             	mov    0x8(%ebx),%eax
f01068e9:	89 04 24             	mov    %eax,(%esp)
f01068ec:	e8 da 0b 00 00       	call   f01074cb <strfind>
f01068f1:	2b 43 08             	sub    0x8(%ebx),%eax
f01068f4:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
        stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f01068f7:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f01068fa:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f01068fd:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0106901:	c7 04 24 44 00 00 00 	movl   $0x44,(%esp)
f0106908:	8b 45 c0             	mov    -0x40(%ebp),%eax
f010690b:	e8 70 fd ff ff       	call   f0106680 <stab_binsearch>
        if(lline <= rline)
f0106910:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0106913:	3b 45 d0             	cmp    -0x30(%ebp),%eax
f0106916:	7f 76                	jg     f010698e <debuginfo_eip+0x1e0>
           info->eip_line = stabs[lline].n_desc;
f0106918:	6b c0 0c             	imul   $0xc,%eax,%eax
f010691b:	8b 55 c0             	mov    -0x40(%ebp),%edx
f010691e:	0f b7 44 10 06       	movzwl 0x6(%eax,%edx,1),%eax
f0106923:	89 43 04             	mov    %eax,0x4(%ebx)
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
f0106926:	8b 7d e4             	mov    -0x1c(%ebp),%edi
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0106929:	eb 06                	jmp    f0106931 <debuginfo_eip+0x183>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f010692b:	83 e8 01             	sub    $0x1,%eax
f010692e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
f0106931:	8b 45 d4             	mov    -0x2c(%ebp),%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0106934:	39 f8                	cmp    %edi,%eax
f0106936:	7c 27                	jl     f010695f <debuginfo_eip+0x1b1>
	       && stabs[lline].n_type != N_SOL
f0106938:	6b d0 0c             	imul   $0xc,%eax,%edx
f010693b:	03 55 c0             	add    -0x40(%ebp),%edx
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f010693e:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0106942:	80 f9 84             	cmp    $0x84,%cl
f0106945:	74 60                	je     f01069a7 <debuginfo_eip+0x1f9>
f0106947:	80 f9 64             	cmp    $0x64,%cl
f010694a:	75 df                	jne    f010692b <debuginfo_eip+0x17d>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f010694c:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
f0106950:	74 d9                	je     f010692b <debuginfo_eip+0x17d>
f0106952:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0106958:	eb 4d                	jmp    f01069a7 <debuginfo_eip+0x1f9>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
		info->eip_file = stabstr + stabs[lline].n_strx;
f010695a:	03 45 c4             	add    -0x3c(%ebp),%eax
f010695d:	89 03                	mov    %eax,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f010695f:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0106962:	3b 45 d8             	cmp    -0x28(%ebp),%eax
f0106965:	7d 2e                	jge    f0106995 <debuginfo_eip+0x1e7>
		for (lline = lfun + 1;
f0106967:	83 c0 01             	add    $0x1,%eax
f010696a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010696d:	eb 08                	jmp    f0106977 <debuginfo_eip+0x1c9>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f010696f:	83 43 14 01          	addl   $0x1,0x14(%ebx)
	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
f0106973:	83 45 d4 01          	addl   $0x1,-0x2c(%ebp)

	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0106977:	8b 45 d4             	mov    -0x2c(%ebp),%eax


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f010697a:	3b 45 d8             	cmp    -0x28(%ebp),%eax
f010697d:	7d 16                	jge    f0106995 <debuginfo_eip+0x1e7>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f010697f:	6b c0 0c             	imul   $0xc,%eax,%eax
f0106982:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f0106985:	80 7c 08 04 a0       	cmpb   $0xa0,0x4(%eax,%ecx,1)
f010698a:	74 e3                	je     f010696f <debuginfo_eip+0x1c1>
f010698c:	eb 07                	jmp    f0106995 <debuginfo_eip+0x1e7>
f010698e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0106993:	eb 05                	jmp    f010699a <debuginfo_eip+0x1ec>
f0106995:	b8 00 00 00 00       	mov    $0x0,%eax
		     lline++)
			info->eip_fn_narg++;
	
	return 0;
}
f010699a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f010699d:	8b 75 f8             	mov    -0x8(%ebp),%esi
f01069a0:	8b 7d fc             	mov    -0x4(%ebp),%edi
f01069a3:	89 ec                	mov    %ebp,%esp
f01069a5:	5d                   	pop    %ebp
f01069a6:	c3                   	ret    
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f01069a7:	6b c0 0c             	imul   $0xc,%eax,%eax
f01069aa:	8b 55 c0             	mov    -0x40(%ebp),%edx
f01069ad:	8b 04 10             	mov    (%eax,%edx,1),%eax
f01069b0:	2b 75 c4             	sub    -0x3c(%ebp),%esi
f01069b3:	39 f0                	cmp    %esi,%eax
f01069b5:	72 a3                	jb     f010695a <debuginfo_eip+0x1ac>
f01069b7:	eb a6                	jmp    f010695f <debuginfo_eip+0x1b1>
f01069b9:	00 00                	add    %al,(%eax)
f01069bb:	00 00                	add    %al,(%eax)
f01069bd:	00 00                	add    %al,(%eax)
	...

f01069c0 <printnum_v2>:
 */

static void 
printnum_v2(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f01069c0:	55                   	push   %ebp
f01069c1:	89 e5                	mov    %esp,%ebp
f01069c3:	57                   	push   %edi
f01069c4:	56                   	push   %esi
f01069c5:	53                   	push   %ebx
f01069c6:	83 ec 4c             	sub    $0x4c,%esp
f01069c9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01069cc:	89 d6                	mov    %edx,%esi
f01069ce:	8b 45 08             	mov    0x8(%ebp),%eax
f01069d1:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01069d4:	8b 55 0c             	mov    0xc(%ebp),%edx
f01069d7:	89 55 e0             	mov    %edx,-0x20(%ebp)
f01069da:	8b 45 10             	mov    0x10(%ebp),%eax
f01069dd:	8b 5d 14             	mov    0x14(%ebp),%ebx
f01069e0:	8b 7d 18             	mov    0x18(%ebp),%edi
    if (num >= base) {
f01069e3:	89 45 dc             	mov    %eax,-0x24(%ebp)
f01069e6:	b9 00 00 00 00       	mov    $0x0,%ecx
f01069eb:	39 d1                	cmp    %edx,%ecx
f01069ed:	72 07                	jb     f01069f6 <printnum_v2+0x36>
f01069ef:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01069f2:	39 d0                	cmp    %edx,%eax
f01069f4:	77 5f                	ja     f0106a55 <printnum_v2+0x95>
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
f01069f6:	89 7c 24 10          	mov    %edi,0x10(%esp)
f01069fa:	83 eb 01             	sub    $0x1,%ebx
f01069fd:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0106a01:	89 44 24 08          	mov    %eax,0x8(%esp)
f0106a05:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0106a09:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
f0106a0d:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f0106a10:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
f0106a13:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0106a16:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0106a1a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0106a21:	00 
f0106a22:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0106a25:	89 04 24             	mov    %eax,(%esp)
f0106a28:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0106a2b:	89 54 24 04          	mov    %edx,0x4(%esp)
f0106a2f:	e8 6c 20 00 00       	call   f0108aa0 <__udivdi3>
f0106a34:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0106a37:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0106a3a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0106a3e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0106a42:	89 04 24             	mov    %eax,(%esp)
f0106a45:	89 54 24 04          	mov    %edx,0x4(%esp)
f0106a49:	89 f2                	mov    %esi,%edx
f0106a4b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0106a4e:	e8 6d ff ff ff       	call   f01069c0 <printnum_v2>
f0106a53:	eb 1e                	jmp    f0106a73 <printnum_v2+0xb3>
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
f0106a55:	83 ff 2d             	cmp    $0x2d,%edi
f0106a58:	74 19                	je     f0106a73 <printnum_v2+0xb3>
		while (--width > 0)
f0106a5a:	83 eb 01             	sub    $0x1,%ebx
f0106a5d:	85 db                	test   %ebx,%ebx
f0106a5f:	90                   	nop
f0106a60:	7e 11                	jle    f0106a73 <printnum_v2+0xb3>
			putch(padc, putdat);
f0106a62:	89 74 24 04          	mov    %esi,0x4(%esp)
f0106a66:	89 3c 24             	mov    %edi,(%esp)
f0106a69:	ff 55 e4             	call   *-0x1c(%ebp)
    if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
		while (--width > 0)
f0106a6c:	83 eb 01             	sub    $0x1,%ebx
f0106a6f:	85 db                	test   %ebx,%ebx
f0106a71:	7f ef                	jg     f0106a62 <printnum_v2+0xa2>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0106a73:	89 74 24 04          	mov    %esi,0x4(%esp)
f0106a77:	8b 74 24 04          	mov    0x4(%esp),%esi
f0106a7b:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0106a7e:	89 44 24 08          	mov    %eax,0x8(%esp)
f0106a82:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0106a89:	00 
f0106a8a:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0106a8d:	89 14 24             	mov    %edx,(%esp)
f0106a90:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0106a93:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0106a97:	e8 34 21 00 00       	call   f0108bd0 <__umoddi3>
f0106a9c:	89 74 24 04          	mov    %esi,0x4(%esp)
f0106aa0:	0f be 80 e6 a4 10 f0 	movsbl -0xfef5b1a(%eax),%eax
f0106aa7:	89 04 24             	mov    %eax,(%esp)
f0106aaa:	ff 55 e4             	call   *-0x1c(%ebp)
}
f0106aad:	83 c4 4c             	add    $0x4c,%esp
f0106ab0:	5b                   	pop    %ebx
f0106ab1:	5e                   	pop    %esi
f0106ab2:	5f                   	pop    %edi
f0106ab3:	5d                   	pop    %ebp
f0106ab4:	c3                   	ret    

f0106ab5 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0106ab5:	55                   	push   %ebp
f0106ab6:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0106ab8:	83 fa 01             	cmp    $0x1,%edx
f0106abb:	7e 0e                	jle    f0106acb <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0106abd:	8b 10                	mov    (%eax),%edx
f0106abf:	8d 4a 08             	lea    0x8(%edx),%ecx
f0106ac2:	89 08                	mov    %ecx,(%eax)
f0106ac4:	8b 02                	mov    (%edx),%eax
f0106ac6:	8b 52 04             	mov    0x4(%edx),%edx
f0106ac9:	eb 22                	jmp    f0106aed <getuint+0x38>
	else if (lflag)
f0106acb:	85 d2                	test   %edx,%edx
f0106acd:	74 10                	je     f0106adf <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0106acf:	8b 10                	mov    (%eax),%edx
f0106ad1:	8d 4a 04             	lea    0x4(%edx),%ecx
f0106ad4:	89 08                	mov    %ecx,(%eax)
f0106ad6:	8b 02                	mov    (%edx),%eax
f0106ad8:	ba 00 00 00 00       	mov    $0x0,%edx
f0106add:	eb 0e                	jmp    f0106aed <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0106adf:	8b 10                	mov    (%eax),%edx
f0106ae1:	8d 4a 04             	lea    0x4(%edx),%ecx
f0106ae4:	89 08                	mov    %ecx,(%eax)
f0106ae6:	8b 02                	mov    (%edx),%eax
f0106ae8:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0106aed:	5d                   	pop    %ebp
f0106aee:	c3                   	ret    

f0106aef <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0106aef:	55                   	push   %ebp
f0106af0:	89 e5                	mov    %esp,%ebp
f0106af2:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0106af5:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0106af9:	8b 10                	mov    (%eax),%edx
f0106afb:	3b 50 04             	cmp    0x4(%eax),%edx
f0106afe:	73 0a                	jae    f0106b0a <sprintputch+0x1b>
		*b->buf++ = ch;
f0106b00:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0106b03:	88 0a                	mov    %cl,(%edx)
f0106b05:	83 c2 01             	add    $0x1,%edx
f0106b08:	89 10                	mov    %edx,(%eax)
}
f0106b0a:	5d                   	pop    %ebp
f0106b0b:	c3                   	ret    

f0106b0c <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0106b0c:	55                   	push   %ebp
f0106b0d:	89 e5                	mov    %esp,%ebp
f0106b0f:	57                   	push   %edi
f0106b10:	56                   	push   %esi
f0106b11:	53                   	push   %ebx
f0106b12:	83 ec 6c             	sub    $0x6c,%esp
f0106b15:	8b 7d 10             	mov    0x10(%ebp),%edi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
f0106b18:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
f0106b1f:	eb 1a                	jmp    f0106b3b <vprintfmt+0x2f>
	int base, lflag, width, precision, altflag,signflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0106b21:	85 c0                	test   %eax,%eax
f0106b23:	0f 84 66 06 00 00    	je     f010718f <vprintfmt+0x683>
				return;
			putch(ch, putdat);
f0106b29:	8b 55 0c             	mov    0xc(%ebp),%edx
f0106b2c:	89 54 24 04          	mov    %edx,0x4(%esp)
f0106b30:	89 04 24             	mov    %eax,(%esp)
f0106b33:	ff 55 08             	call   *0x8(%ebp)
f0106b36:	eb 03                	jmp    f0106b3b <vprintfmt+0x2f>
f0106b38:	8b 7d e4             	mov    -0x1c(%ebp),%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag,signflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0106b3b:	0f b6 07             	movzbl (%edi),%eax
f0106b3e:	83 c7 01             	add    $0x1,%edi
f0106b41:	83 f8 25             	cmp    $0x25,%eax
f0106b44:	75 db                	jne    f0106b21 <vprintfmt+0x15>
f0106b46:	c6 45 cc 20          	movb   $0x20,-0x34(%ebp)
f0106b4a:	b9 00 00 00 00       	mov    $0x0,%ecx
f0106b4f:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
f0106b56:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f0106b5b:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
f0106b62:	be 00 00 00 00       	mov    $0x0,%esi
f0106b67:	eb 06                	jmp    f0106b6f <vprintfmt+0x63>
f0106b69:	c6 45 cc 2d          	movb   $0x2d,-0x34(%ebp)
f0106b6d:	89 c7                	mov    %eax,%edi
		precision = -1;
		lflag = 0;
		altflag = 0;
                signflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0106b6f:	0f b6 17             	movzbl (%edi),%edx
f0106b72:	0f b6 c2             	movzbl %dl,%eax
f0106b75:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0106b78:	8d 47 01             	lea    0x1(%edi),%eax
f0106b7b:	83 ea 23             	sub    $0x23,%edx
f0106b7e:	80 fa 55             	cmp    $0x55,%dl
f0106b81:	0f 87 60 05 00 00    	ja     f01070e7 <vprintfmt+0x5db>
f0106b87:	0f b6 d2             	movzbl %dl,%edx
f0106b8a:	ff 24 95 c0 a6 10 f0 	jmp    *-0xfef5940(,%edx,4)
f0106b91:	b9 01 00 00 00       	mov    $0x1,%ecx
f0106b96:	eb d5                	jmp    f0106b6d <vprintfmt+0x61>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0106b98:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0106b9b:	83 eb 30             	sub    $0x30,%ebx
				ch = *fmt;
f0106b9e:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
f0106ba1:	8d 7a d0             	lea    -0x30(%edx),%edi
f0106ba4:	83 ff 09             	cmp    $0x9,%edi
f0106ba7:	76 08                	jbe    f0106bb1 <vprintfmt+0xa5>
f0106ba9:	eb 40                	jmp    f0106beb <vprintfmt+0xdf>
f0106bab:	c6 45 cc 30          	movb   $0x30,-0x34(%ebp)
                        signflag = 1;
                        goto reswitch;
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
			goto reswitch;
f0106baf:	eb bc                	jmp    f0106b6d <vprintfmt+0x61>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0106bb1:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
f0106bb4:	8d 1c 9b             	lea    (%ebx,%ebx,4),%ebx
f0106bb7:	8d 5c 5a d0          	lea    -0x30(%edx,%ebx,2),%ebx
				ch = *fmt;
f0106bbb:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
f0106bbe:	8d 7a d0             	lea    -0x30(%edx),%edi
f0106bc1:	83 ff 09             	cmp    $0x9,%edi
f0106bc4:	76 eb                	jbe    f0106bb1 <vprintfmt+0xa5>
f0106bc6:	eb 23                	jmp    f0106beb <vprintfmt+0xdf>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0106bc8:	8b 55 14             	mov    0x14(%ebp),%edx
f0106bcb:	8d 5a 04             	lea    0x4(%edx),%ebx
f0106bce:	89 5d 14             	mov    %ebx,0x14(%ebp)
f0106bd1:	8b 1a                	mov    (%edx),%ebx
			goto process_precision;
f0106bd3:	eb 16                	jmp    f0106beb <vprintfmt+0xdf>

		case '.':
			if (width < 0)
f0106bd5:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0106bd8:	c1 fa 1f             	sar    $0x1f,%edx
f0106bdb:	f7 d2                	not    %edx
f0106bdd:	21 55 d8             	and    %edx,-0x28(%ebp)
f0106be0:	eb 8b                	jmp    f0106b6d <vprintfmt+0x61>
f0106be2:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
f0106be9:	eb 82                	jmp    f0106b6d <vprintfmt+0x61>

		process_precision:
			if (width < 0)
f0106beb:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0106bef:	0f 89 78 ff ff ff    	jns    f0106b6d <vprintfmt+0x61>
f0106bf5:	89 5d d8             	mov    %ebx,-0x28(%ebp)
f0106bf8:	8b 5d c8             	mov    -0x38(%ebp),%ebx
f0106bfb:	e9 6d ff ff ff       	jmp    f0106b6d <vprintfmt+0x61>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0106c00:	83 c6 01             	add    $0x1,%esi
			goto reswitch;
f0106c03:	e9 65 ff ff ff       	jmp    f0106b6d <vprintfmt+0x61>
f0106c08:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0106c0b:	8b 45 14             	mov    0x14(%ebp),%eax
f0106c0e:	8d 50 04             	lea    0x4(%eax),%edx
f0106c11:	89 55 14             	mov    %edx,0x14(%ebp)
f0106c14:	8b 55 0c             	mov    0xc(%ebp),%edx
f0106c17:	89 54 24 04          	mov    %edx,0x4(%esp)
f0106c1b:	8b 00                	mov    (%eax),%eax
f0106c1d:	89 04 24             	mov    %eax,(%esp)
f0106c20:	ff 55 08             	call   *0x8(%ebp)
f0106c23:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;
f0106c26:	e9 10 ff ff ff       	jmp    f0106b3b <vprintfmt+0x2f>
f0106c2b:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
f0106c2e:	8b 45 14             	mov    0x14(%ebp),%eax
f0106c31:	8d 50 04             	lea    0x4(%eax),%edx
f0106c34:	89 55 14             	mov    %edx,0x14(%ebp)
f0106c37:	8b 00                	mov    (%eax),%eax
f0106c39:	89 c2                	mov    %eax,%edx
f0106c3b:	c1 fa 1f             	sar    $0x1f,%edx
f0106c3e:	31 d0                	xor    %edx,%eax
f0106c40:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0106c42:	83 f8 0f             	cmp    $0xf,%eax
f0106c45:	7f 0b                	jg     f0106c52 <vprintfmt+0x146>
f0106c47:	8b 14 85 20 a8 10 f0 	mov    -0xfef57e0(,%eax,4),%edx
f0106c4e:	85 d2                	test   %edx,%edx
f0106c50:	75 26                	jne    f0106c78 <vprintfmt+0x16c>
				printfmt(putch, putdat, "error %d", err);
f0106c52:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0106c56:	c7 44 24 08 f7 a4 10 	movl   $0xf010a4f7,0x8(%esp)
f0106c5d:	f0 
f0106c5e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0106c61:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0106c65:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0106c68:	89 1c 24             	mov    %ebx,(%esp)
f0106c6b:	e8 a7 05 00 00       	call   f0107217 <printfmt>
f0106c70:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0106c73:	e9 c3 fe ff ff       	jmp    f0106b3b <vprintfmt+0x2f>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
f0106c78:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0106c7c:	c7 44 24 08 9e 95 10 	movl   $0xf010959e,0x8(%esp)
f0106c83:	f0 
f0106c84:	8b 45 0c             	mov    0xc(%ebp),%eax
f0106c87:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106c8b:	8b 55 08             	mov    0x8(%ebp),%edx
f0106c8e:	89 14 24             	mov    %edx,(%esp)
f0106c91:	e8 81 05 00 00       	call   f0107217 <printfmt>
f0106c96:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0106c99:	e9 9d fe ff ff       	jmp    f0106b3b <vprintfmt+0x2f>
f0106c9e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0106ca1:	89 c7                	mov    %eax,%edi
f0106ca3:	89 d9                	mov    %ebx,%ecx
f0106ca5:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0106ca8:	89 45 c0             	mov    %eax,-0x40(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0106cab:	8b 45 14             	mov    0x14(%ebp),%eax
f0106cae:	8d 50 04             	lea    0x4(%eax),%edx
f0106cb1:	89 55 14             	mov    %edx,0x14(%ebp)
f0106cb4:	8b 30                	mov    (%eax),%esi
f0106cb6:	85 f6                	test   %esi,%esi
f0106cb8:	75 05                	jne    f0106cbf <vprintfmt+0x1b3>
f0106cba:	be 00 a5 10 f0       	mov    $0xf010a500,%esi
				p = "(null)";
			if (width > 0 && padc != '-')
f0106cbf:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
f0106cc3:	7e 06                	jle    f0106ccb <vprintfmt+0x1bf>
f0106cc5:	80 7d cc 2d          	cmpb   $0x2d,-0x34(%ebp)
f0106cc9:	75 10                	jne    f0106cdb <vprintfmt+0x1cf>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0106ccb:	0f be 06             	movsbl (%esi),%eax
f0106cce:	85 c0                	test   %eax,%eax
f0106cd0:	0f 85 a2 00 00 00    	jne    f0106d78 <vprintfmt+0x26c>
f0106cd6:	e9 92 00 00 00       	jmp    f0106d6d <vprintfmt+0x261>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0106cdb:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0106cdf:	89 34 24             	mov    %esi,(%esp)
f0106ce2:	e8 54 06 00 00       	call   f010733b <strnlen>
f0106ce7:	8b 55 c0             	mov    -0x40(%ebp),%edx
f0106cea:	29 c2                	sub    %eax,%edx
f0106cec:	89 55 d8             	mov    %edx,-0x28(%ebp)
f0106cef:	85 d2                	test   %edx,%edx
f0106cf1:	7e d8                	jle    f0106ccb <vprintfmt+0x1bf>
					putch(padc, putdat);
f0106cf3:	0f be 4d cc          	movsbl -0x34(%ebp),%ecx
f0106cf7:	89 5d c0             	mov    %ebx,-0x40(%ebp)
f0106cfa:	89 d3                	mov    %edx,%ebx
f0106cfc:	89 75 d8             	mov    %esi,-0x28(%ebp)
f0106cff:	89 7d bc             	mov    %edi,-0x44(%ebp)
f0106d02:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0106d05:	89 ce                	mov    %ecx,%esi
f0106d07:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0106d0b:	89 34 24             	mov    %esi,(%esp)
f0106d0e:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0106d11:	83 eb 01             	sub    $0x1,%ebx
f0106d14:	85 db                	test   %ebx,%ebx
f0106d16:	7f ef                	jg     f0106d07 <vprintfmt+0x1fb>
f0106d18:	8b 5d c0             	mov    -0x40(%ebp),%ebx
f0106d1b:	8b 75 d8             	mov    -0x28(%ebp),%esi
f0106d1e:	8b 7d bc             	mov    -0x44(%ebp),%edi
f0106d21:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0106d28:	eb a1                	jmp    f0106ccb <vprintfmt+0x1bf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0106d2a:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
f0106d2e:	74 1b                	je     f0106d4b <vprintfmt+0x23f>
f0106d30:	8d 50 e0             	lea    -0x20(%eax),%edx
f0106d33:	83 fa 5e             	cmp    $0x5e,%edx
f0106d36:	76 13                	jbe    f0106d4b <vprintfmt+0x23f>
					putch('?', putdat);
f0106d38:	8b 45 0c             	mov    0xc(%ebp),%eax
f0106d3b:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106d3f:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f0106d46:	ff 55 08             	call   *0x8(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0106d49:	eb 0d                	jmp    f0106d58 <vprintfmt+0x24c>
					putch('?', putdat);
				else
					putch(ch, putdat);
f0106d4b:	8b 55 0c             	mov    0xc(%ebp),%edx
f0106d4e:	89 54 24 04          	mov    %edx,0x4(%esp)
f0106d52:	89 04 24             	mov    %eax,(%esp)
f0106d55:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0106d58:	83 ef 01             	sub    $0x1,%edi
f0106d5b:	0f be 06             	movsbl (%esi),%eax
f0106d5e:	85 c0                	test   %eax,%eax
f0106d60:	74 05                	je     f0106d67 <vprintfmt+0x25b>
f0106d62:	83 c6 01             	add    $0x1,%esi
f0106d65:	eb 1a                	jmp    f0106d81 <vprintfmt+0x275>
f0106d67:	89 7d d8             	mov    %edi,-0x28(%ebp)
f0106d6a:	8b 7d cc             	mov    -0x34(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0106d6d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0106d71:	7f 1f                	jg     f0106d92 <vprintfmt+0x286>
f0106d73:	e9 c0 fd ff ff       	jmp    f0106b38 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0106d78:	83 c6 01             	add    $0x1,%esi
f0106d7b:	89 7d cc             	mov    %edi,-0x34(%ebp)
f0106d7e:	8b 7d d8             	mov    -0x28(%ebp),%edi
f0106d81:	85 db                	test   %ebx,%ebx
f0106d83:	78 a5                	js     f0106d2a <vprintfmt+0x21e>
f0106d85:	83 eb 01             	sub    $0x1,%ebx
f0106d88:	79 a0                	jns    f0106d2a <vprintfmt+0x21e>
f0106d8a:	89 7d d8             	mov    %edi,-0x28(%ebp)
f0106d8d:	8b 7d cc             	mov    -0x34(%ebp),%edi
f0106d90:	eb db                	jmp    f0106d6d <vprintfmt+0x261>
f0106d92:	8b 5d d8             	mov    -0x28(%ebp),%ebx
f0106d95:	8b 75 0c             	mov    0xc(%ebp),%esi
f0106d98:	89 7d d8             	mov    %edi,-0x28(%ebp)
f0106d9b:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0106d9e:	89 74 24 04          	mov    %esi,0x4(%esp)
f0106da2:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0106da9:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0106dab:	83 eb 01             	sub    $0x1,%ebx
f0106dae:	85 db                	test   %ebx,%ebx
f0106db0:	7f ec                	jg     f0106d9e <vprintfmt+0x292>
f0106db2:	8b 7d d8             	mov    -0x28(%ebp),%edi
f0106db5:	e9 81 fd ff ff       	jmp    f0106b3b <vprintfmt+0x2f>
f0106dba:	89 45 e4             	mov    %eax,-0x1c(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0106dbd:	83 fe 01             	cmp    $0x1,%esi
f0106dc0:	7e 10                	jle    f0106dd2 <vprintfmt+0x2c6>
		return va_arg(*ap, long long);
f0106dc2:	8b 45 14             	mov    0x14(%ebp),%eax
f0106dc5:	8d 50 08             	lea    0x8(%eax),%edx
f0106dc8:	89 55 14             	mov    %edx,0x14(%ebp)
f0106dcb:	8b 18                	mov    (%eax),%ebx
f0106dcd:	8b 70 04             	mov    0x4(%eax),%esi
f0106dd0:	eb 26                	jmp    f0106df8 <vprintfmt+0x2ec>
	else if (lflag)
f0106dd2:	85 f6                	test   %esi,%esi
f0106dd4:	74 12                	je     f0106de8 <vprintfmt+0x2dc>
		return va_arg(*ap, long);
f0106dd6:	8b 45 14             	mov    0x14(%ebp),%eax
f0106dd9:	8d 50 04             	lea    0x4(%eax),%edx
f0106ddc:	89 55 14             	mov    %edx,0x14(%ebp)
f0106ddf:	8b 18                	mov    (%eax),%ebx
f0106de1:	89 de                	mov    %ebx,%esi
f0106de3:	c1 fe 1f             	sar    $0x1f,%esi
f0106de6:	eb 10                	jmp    f0106df8 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
f0106de8:	8b 45 14             	mov    0x14(%ebp),%eax
f0106deb:	8d 50 04             	lea    0x4(%eax),%edx
f0106dee:	89 55 14             	mov    %edx,0x14(%ebp)
f0106df1:	8b 18                	mov    (%eax),%ebx
f0106df3:	89 de                	mov    %ebx,%esi
f0106df5:	c1 fe 1f             	sar    $0x1f,%esi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
                        if(signflag == 1){
f0106df8:	83 f9 01             	cmp    $0x1,%ecx
f0106dfb:	75 1e                	jne    f0106e1b <vprintfmt+0x30f>
                               if((long long)num > 0){
f0106dfd:	85 f6                	test   %esi,%esi
f0106dff:	78 1a                	js     f0106e1b <vprintfmt+0x30f>
f0106e01:	85 f6                	test   %esi,%esi
f0106e03:	7f 05                	jg     f0106e0a <vprintfmt+0x2fe>
f0106e05:	83 fb 00             	cmp    $0x0,%ebx
f0106e08:	76 11                	jbe    f0106e1b <vprintfmt+0x30f>
                                   putch('+',putdat);
f0106e0a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0106e0d:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0106e11:	c7 04 24 2b 00 00 00 	movl   $0x2b,(%esp)
f0106e18:	ff 55 08             	call   *0x8(%ebp)
                               }
                        }
			if ((long long) num < 0) {
f0106e1b:	85 f6                	test   %esi,%esi
f0106e1d:	78 13                	js     f0106e32 <vprintfmt+0x326>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0106e1f:	89 5d b0             	mov    %ebx,-0x50(%ebp)
f0106e22:	89 75 b4             	mov    %esi,-0x4c(%ebp)
f0106e25:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0106e28:	b8 0a 00 00 00       	mov    $0xa,%eax
f0106e2d:	e9 da 00 00 00       	jmp    f0106f0c <vprintfmt+0x400>
                               if((long long)num > 0){
                                   putch('+',putdat);
                               }
                        }
			if ((long long) num < 0) {
				putch('-', putdat);
f0106e32:	8b 45 0c             	mov    0xc(%ebp),%eax
f0106e35:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106e39:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f0106e40:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f0106e43:	89 da                	mov    %ebx,%edx
f0106e45:	89 f1                	mov    %esi,%ecx
f0106e47:	f7 da                	neg    %edx
f0106e49:	83 d1 00             	adc    $0x0,%ecx
f0106e4c:	f7 d9                	neg    %ecx
f0106e4e:	89 55 b0             	mov    %edx,-0x50(%ebp)
f0106e51:	89 4d b4             	mov    %ecx,-0x4c(%ebp)
f0106e54:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0106e57:	b8 0a 00 00 00       	mov    $0xa,%eax
f0106e5c:	e9 ab 00 00 00       	jmp    f0106f0c <vprintfmt+0x400>
f0106e61:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0106e64:	89 f2                	mov    %esi,%edx
f0106e66:	8d 45 14             	lea    0x14(%ebp),%eax
f0106e69:	e8 47 fc ff ff       	call   f0106ab5 <getuint>
f0106e6e:	89 45 b0             	mov    %eax,-0x50(%ebp)
f0106e71:	89 55 b4             	mov    %edx,-0x4c(%ebp)
f0106e74:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0106e77:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
f0106e7c:	e9 8b 00 00 00       	jmp    f0106f0c <vprintfmt+0x400>
f0106e81:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			putch('0', putdat);
f0106e84:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0106e87:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0106e8b:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f0106e92:	ff 55 08             	call   *0x8(%ebp)
			num = getuint(&ap,lflag);
f0106e95:	89 f2                	mov    %esi,%edx
f0106e97:	8d 45 14             	lea    0x14(%ebp),%eax
f0106e9a:	e8 16 fc ff ff       	call   f0106ab5 <getuint>
f0106e9f:	89 45 b0             	mov    %eax,-0x50(%ebp)
f0106ea2:	89 55 b4             	mov    %edx,-0x4c(%ebp)
f0106ea5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0106ea8:	b8 08 00 00 00       	mov    $0x8,%eax
                        base = 8;
			goto number;
f0106ead:	eb 5d                	jmp    f0106f0c <vprintfmt+0x400>
f0106eaf:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
f0106eb2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0106eb5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0106eb9:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f0106ec0:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f0106ec3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0106ec7:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f0106ece:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
f0106ed1:	8b 45 14             	mov    0x14(%ebp),%eax
f0106ed4:	8d 50 04             	lea    0x4(%eax),%edx
f0106ed7:	89 55 14             	mov    %edx,0x14(%ebp)
f0106eda:	8b 10                	mov    (%eax),%edx
f0106edc:	b9 00 00 00 00       	mov    $0x0,%ecx
f0106ee1:	89 55 b0             	mov    %edx,-0x50(%ebp)
f0106ee4:	89 4d b4             	mov    %ecx,-0x4c(%ebp)
f0106ee7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0106eea:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f0106eef:	eb 1b                	jmp    f0106f0c <vprintfmt+0x400>
f0106ef1:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0106ef4:	89 f2                	mov    %esi,%edx
f0106ef6:	8d 45 14             	lea    0x14(%ebp),%eax
f0106ef9:	e8 b7 fb ff ff       	call   f0106ab5 <getuint>
f0106efe:	89 45 b0             	mov    %eax,-0x50(%ebp)
f0106f01:	89 55 b4             	mov    %edx,-0x4c(%ebp)
f0106f04:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0106f07:	b8 10 00 00 00       	mov    $0x10,%eax
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
f0106f0c:	0f be 4d cc          	movsbl -0x34(%ebp),%ecx
f0106f10:	89 4d d0             	mov    %ecx,-0x30(%ebp)
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0106f13:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0106f16:	83 7d b4 00          	cmpl   $0x0,-0x4c(%ebp)
f0106f1a:	77 09                	ja     f0106f25 <vprintfmt+0x419>
f0106f1c:	39 45 b0             	cmp    %eax,-0x50(%ebp)
f0106f1f:	0f 82 ac 00 00 00    	jb     f0106fd1 <vprintfmt+0x4c5>
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
f0106f25:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0106f28:	89 5c 24 10          	mov    %ebx,0x10(%esp)
f0106f2c:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0106f2f:	83 ea 01             	sub    $0x1,%edx
f0106f32:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0106f36:	89 44 24 08          	mov    %eax,0x8(%esp)
f0106f3a:	8b 44 24 08          	mov    0x8(%esp),%eax
f0106f3e:	8b 54 24 0c          	mov    0xc(%esp),%edx
f0106f42:	89 45 c0             	mov    %eax,-0x40(%ebp)
f0106f45:	89 55 c4             	mov    %edx,-0x3c(%ebp)
f0106f48:	8b 55 cc             	mov    -0x34(%ebp),%edx
f0106f4b:	89 54 24 08          	mov    %edx,0x8(%esp)
f0106f4f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0106f56:	00 
f0106f57:	8b 4d b0             	mov    -0x50(%ebp),%ecx
f0106f5a:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
f0106f5d:	89 0c 24             	mov    %ecx,(%esp)
f0106f60:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0106f64:	e8 37 1b 00 00       	call   f0108aa0 <__udivdi3>
f0106f69:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f0106f6c:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0106f6f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0106f73:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0106f77:	89 04 24             	mov    %eax,(%esp)
f0106f7a:	89 54 24 04          	mov    %edx,0x4(%esp)
f0106f7e:	8b 55 0c             	mov    0xc(%ebp),%edx
f0106f81:	8b 45 08             	mov    0x8(%ebp),%eax
f0106f84:	e8 37 fa ff ff       	call   f01069c0 <printnum_v2>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0106f89:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0106f8c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0106f90:	8b 74 24 04          	mov    0x4(%esp),%esi
f0106f94:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0106f97:	89 44 24 08          	mov    %eax,0x8(%esp)
f0106f9b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0106fa2:	00 
f0106fa3:	8b 55 b0             	mov    -0x50(%ebp),%edx
f0106fa6:	8b 4d b4             	mov    -0x4c(%ebp),%ecx
f0106fa9:	89 14 24             	mov    %edx,(%esp)
f0106fac:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0106fb0:	e8 1b 1c 00 00       	call   f0108bd0 <__umoddi3>
f0106fb5:	89 74 24 04          	mov    %esi,0x4(%esp)
f0106fb9:	0f be 80 e6 a4 10 f0 	movsbl -0xfef5b1a(%eax),%eax
f0106fc0:	89 04 24             	mov    %eax,(%esp)
f0106fc3:	ff 55 08             	call   *0x8(%ebp)
        if(padc == '-'){
f0106fc6:	83 7d d0 2d          	cmpl   $0x2d,-0x30(%ebp)
f0106fca:	74 54                	je     f0107020 <vprintfmt+0x514>
f0106fcc:	e9 67 fb ff ff       	jmp    f0106b38 <vprintfmt+0x2c>
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
f0106fd1:	83 7d d0 2d          	cmpl   $0x2d,-0x30(%ebp)
f0106fd5:	8d 76 00             	lea    0x0(%esi),%esi
f0106fd8:	0f 84 2a 01 00 00    	je     f0107108 <vprintfmt+0x5fc>
		while (--width > 0)
f0106fde:	8b 7d d8             	mov    -0x28(%ebp),%edi
f0106fe1:	83 ef 01             	sub    $0x1,%edi
f0106fe4:	85 ff                	test   %edi,%edi
f0106fe6:	0f 8e 5e 01 00 00    	jle    f010714a <vprintfmt+0x63e>
f0106fec:	8b 4d b0             	mov    -0x50(%ebp),%ecx
f0106fef:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
f0106ff2:	89 4d d8             	mov    %ecx,-0x28(%ebp)
f0106ff5:	89 5d dc             	mov    %ebx,-0x24(%ebp)
f0106ff8:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0106ffb:	8b 75 0c             	mov    0xc(%ebp),%esi
			putch(padc, putdat);
f0106ffe:	89 74 24 04          	mov    %esi,0x4(%esp)
f0107002:	89 1c 24             	mov    %ebx,(%esp)
f0107005:	ff 55 08             	call   *0x8(%ebp)
	if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
		while (--width > 0)
f0107008:	83 ef 01             	sub    $0x1,%edi
f010700b:	85 ff                	test   %edi,%edi
f010700d:	7f ef                	jg     f0106ffe <vprintfmt+0x4f2>
f010700f:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0107012:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0107015:	89 45 b0             	mov    %eax,-0x50(%ebp)
f0107018:	89 55 b4             	mov    %edx,-0x4c(%ebp)
f010701b:	e9 2a 01 00 00       	jmp    f010714a <vprintfmt+0x63e>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
        if(padc == '-'){
           while (--width > 0)
f0107020:	8b 5d d8             	mov    -0x28(%ebp),%ebx
f0107023:	83 eb 01             	sub    $0x1,%ebx
f0107026:	85 db                	test   %ebx,%ebx
f0107028:	0f 8e 0a fb ff ff    	jle    f0106b38 <vprintfmt+0x2c>
f010702e:	8b 75 0c             	mov    0xc(%ebp),%esi
f0107031:	89 7d d8             	mov    %edi,-0x28(%ebp)
f0107034:	8b 7d 08             	mov    0x8(%ebp),%edi
			putch(' ', putdat);
f0107037:	89 74 24 04          	mov    %esi,0x4(%esp)
f010703b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0107042:	ff d7                	call   *%edi
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
        if(padc == '-'){
           while (--width > 0)
f0107044:	83 eb 01             	sub    $0x1,%ebx
f0107047:	85 db                	test   %ebx,%ebx
f0107049:	7f ec                	jg     f0107037 <vprintfmt+0x52b>
f010704b:	8b 7d d8             	mov    -0x28(%ebp),%edi
f010704e:	e9 e8 fa ff ff       	jmp    f0106b3b <vprintfmt+0x2f>
f0107053:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
            char* n;
            if ((n = va_arg(ap, char *)) == NULL)
f0107056:	8b 45 14             	mov    0x14(%ebp),%eax
f0107059:	8d 50 04             	lea    0x4(%eax),%edx
f010705c:	89 55 14             	mov    %edx,0x14(%ebp)
f010705f:	8b 00                	mov    (%eax),%eax
f0107061:	85 c0                	test   %eax,%eax
f0107063:	75 2a                	jne    f010708f <vprintfmt+0x583>
		  printfmt(putch,putdat,"%s",null_error);
f0107065:	c7 44 24 0c 1c a6 10 	movl   $0xf010a61c,0xc(%esp)
f010706c:	f0 
f010706d:	c7 44 24 08 9e 95 10 	movl   $0xf010959e,0x8(%esp)
f0107074:	f0 
f0107075:	8b 55 0c             	mov    0xc(%ebp),%edx
f0107078:	89 54 24 04          	mov    %edx,0x4(%esp)
f010707c:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010707f:	89 0c 24             	mov    %ecx,(%esp)
f0107082:	e8 90 01 00 00       	call   f0107217 <printfmt>
f0107087:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010708a:	e9 ac fa ff ff       	jmp    f0106b3b <vprintfmt+0x2f>
            else if((*(int*)putdat) > 127){
f010708f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0107092:	8b 13                	mov    (%ebx),%edx
f0107094:	83 fa 7f             	cmp    $0x7f,%edx
f0107097:	7e 29                	jle    f01070c2 <vprintfmt+0x5b6>
                  *n = *(int*)putdat;
f0107099:	88 10                	mov    %dl,(%eax)
                  printfmt(putch,putdat,"%s",overflow_error);
f010709b:	c7 44 24 0c 54 a6 10 	movl   $0xf010a654,0xc(%esp)
f01070a2:	f0 
f01070a3:	c7 44 24 08 9e 95 10 	movl   $0xf010959e,0x8(%esp)
f01070aa:	f0 
f01070ab:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01070af:	8b 45 08             	mov    0x8(%ebp),%eax
f01070b2:	89 04 24             	mov    %eax,(%esp)
f01070b5:	e8 5d 01 00 00       	call   f0107217 <printfmt>
f01070ba:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01070bd:	e9 79 fa ff ff       	jmp    f0106b3b <vprintfmt+0x2f>
            }
            else
                  *n = *(int*)putdat;
f01070c2:	88 10                	mov    %dl,(%eax)
f01070c4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01070c7:	e9 6f fa ff ff       	jmp    f0106b3b <vprintfmt+0x2f>
f01070cc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01070cf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            break;
        }
		// escaped '%' character
		case '%':
			putch(ch, putdat);
f01070d2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01070d5:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f01070d9:	89 14 24             	mov    %edx,(%esp)
f01070dc:	ff 55 08             	call   *0x8(%ebp)
f01070df:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;
f01070e2:	e9 54 fa ff ff       	jmp    f0106b3b <vprintfmt+0x2f>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f01070e7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01070ea:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01070ee:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f01070f5:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f01070f8:	8d 47 ff             	lea    -0x1(%edi),%eax
f01070fb:	80 38 25             	cmpb   $0x25,(%eax)
f01070fe:	0f 84 37 fa ff ff    	je     f0106b3b <vprintfmt+0x2f>
f0107104:	89 c7                	mov    %eax,%edi
f0107106:	eb f0                	jmp    f01070f8 <vprintfmt+0x5ec>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0107108:	8b 45 0c             	mov    0xc(%ebp),%eax
f010710b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010710f:	8b 74 24 04          	mov    0x4(%esp),%esi
f0107113:	8b 55 cc             	mov    -0x34(%ebp),%edx
f0107116:	89 54 24 08          	mov    %edx,0x8(%esp)
f010711a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0107121:	00 
f0107122:	8b 45 b0             	mov    -0x50(%ebp),%eax
f0107125:	8b 55 b4             	mov    -0x4c(%ebp),%edx
f0107128:	89 04 24             	mov    %eax,(%esp)
f010712b:	89 54 24 04          	mov    %edx,0x4(%esp)
f010712f:	e8 9c 1a 00 00       	call   f0108bd0 <__umoddi3>
f0107134:	89 74 24 04          	mov    %esi,0x4(%esp)
f0107138:	0f be 80 e6 a4 10 f0 	movsbl -0xfef5b1a(%eax),%eax
f010713f:	89 04 24             	mov    %eax,(%esp)
f0107142:	ff 55 08             	call   *0x8(%ebp)
f0107145:	e9 d6 fe ff ff       	jmp    f0107020 <vprintfmt+0x514>
f010714a:	8b 55 0c             	mov    0xc(%ebp),%edx
f010714d:	89 54 24 04          	mov    %edx,0x4(%esp)
f0107151:	8b 74 24 04          	mov    0x4(%esp),%esi
f0107155:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0107158:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010715c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0107163:	00 
f0107164:	8b 45 b0             	mov    -0x50(%ebp),%eax
f0107167:	8b 55 b4             	mov    -0x4c(%ebp),%edx
f010716a:	89 04 24             	mov    %eax,(%esp)
f010716d:	89 54 24 04          	mov    %edx,0x4(%esp)
f0107171:	e8 5a 1a 00 00       	call   f0108bd0 <__umoddi3>
f0107176:	89 74 24 04          	mov    %esi,0x4(%esp)
f010717a:	0f be 80 e6 a4 10 f0 	movsbl -0xfef5b1a(%eax),%eax
f0107181:	89 04 24             	mov    %eax,(%esp)
f0107184:	ff 55 08             	call   *0x8(%ebp)
f0107187:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010718a:	e9 ac f9 ff ff       	jmp    f0106b3b <vprintfmt+0x2f>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
f010718f:	83 c4 6c             	add    $0x6c,%esp
f0107192:	5b                   	pop    %ebx
f0107193:	5e                   	pop    %esi
f0107194:	5f                   	pop    %edi
f0107195:	5d                   	pop    %ebp
f0107196:	c3                   	ret    

f0107197 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0107197:	55                   	push   %ebp
f0107198:	89 e5                	mov    %esp,%ebp
f010719a:	83 ec 28             	sub    $0x28,%esp
f010719d:	8b 45 08             	mov    0x8(%ebp),%eax
f01071a0:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
f01071a3:	85 c0                	test   %eax,%eax
f01071a5:	74 04                	je     f01071ab <vsnprintf+0x14>
f01071a7:	85 d2                	test   %edx,%edx
f01071a9:	7f 07                	jg     f01071b2 <vsnprintf+0x1b>
f01071ab:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01071b0:	eb 3b                	jmp    f01071ed <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
f01071b2:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01071b5:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
f01071b9:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01071bc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f01071c3:	8b 45 14             	mov    0x14(%ebp),%eax
f01071c6:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01071ca:	8b 45 10             	mov    0x10(%ebp),%eax
f01071cd:	89 44 24 08          	mov    %eax,0x8(%esp)
f01071d1:	8d 45 ec             	lea    -0x14(%ebp),%eax
f01071d4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01071d8:	c7 04 24 ef 6a 10 f0 	movl   $0xf0106aef,(%esp)
f01071df:	e8 28 f9 ff ff       	call   f0106b0c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f01071e4:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01071e7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f01071ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
f01071ed:	c9                   	leave  
f01071ee:	c3                   	ret    

f01071ef <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f01071ef:	55                   	push   %ebp
f01071f0:	89 e5                	mov    %esp,%ebp
f01071f2:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
f01071f5:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
f01071f8:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01071fc:	8b 45 10             	mov    0x10(%ebp),%eax
f01071ff:	89 44 24 08          	mov    %eax,0x8(%esp)
f0107203:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107206:	89 44 24 04          	mov    %eax,0x4(%esp)
f010720a:	8b 45 08             	mov    0x8(%ebp),%eax
f010720d:	89 04 24             	mov    %eax,(%esp)
f0107210:	e8 82 ff ff ff       	call   f0107197 <vsnprintf>
	va_end(ap);

	return rc;
}
f0107215:	c9                   	leave  
f0107216:	c3                   	ret    

f0107217 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0107217:	55                   	push   %ebp
f0107218:	89 e5                	mov    %esp,%ebp
f010721a:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
f010721d:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
f0107220:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0107224:	8b 45 10             	mov    0x10(%ebp),%eax
f0107227:	89 44 24 08          	mov    %eax,0x8(%esp)
f010722b:	8b 45 0c             	mov    0xc(%ebp),%eax
f010722e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0107232:	8b 45 08             	mov    0x8(%ebp),%eax
f0107235:	89 04 24             	mov    %eax,(%esp)
f0107238:	e8 cf f8 ff ff       	call   f0106b0c <vprintfmt>
	va_end(ap);
}
f010723d:	c9                   	leave  
f010723e:	c3                   	ret    
	...

f0107240 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0107240:	55                   	push   %ebp
f0107241:	89 e5                	mov    %esp,%ebp
f0107243:	57                   	push   %edi
f0107244:	56                   	push   %esi
f0107245:	53                   	push   %ebx
f0107246:	83 ec 1c             	sub    $0x1c,%esp
f0107249:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f010724c:	85 c0                	test   %eax,%eax
f010724e:	74 10                	je     f0107260 <readline+0x20>
		cprintf("%s", prompt);
f0107250:	89 44 24 04          	mov    %eax,0x4(%esp)
f0107254:	c7 04 24 9e 95 10 f0 	movl   $0xf010959e,(%esp)
f010725b:	e8 af d9 ff ff       	call   f0104c0f <cprintf>

	i = 0;
	echoing = iscons(0);
f0107260:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0107267:	e8 da 92 ff ff       	call   f0100546 <iscons>
f010726c:	89 c7                	mov    %eax,%edi
f010726e:	be 00 00 00 00       	mov    $0x0,%esi
	while (1) {
		c = getchar();
f0107273:	e8 bd 92 ff ff       	call   f0100535 <getchar>
f0107278:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f010727a:	85 c0                	test   %eax,%eax
f010727c:	79 17                	jns    f0107295 <readline+0x55>
			cprintf("read error: %e\n", c);
f010727e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0107282:	c7 04 24 60 a8 10 f0 	movl   $0xf010a860,(%esp)
f0107289:	e8 81 d9 ff ff       	call   f0104c0f <cprintf>
f010728e:	b8 00 00 00 00       	mov    $0x0,%eax
			return NULL;
f0107293:	eb 76                	jmp    f010730b <readline+0xcb>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0107295:	83 f8 08             	cmp    $0x8,%eax
f0107298:	74 08                	je     f01072a2 <readline+0x62>
f010729a:	83 f8 7f             	cmp    $0x7f,%eax
f010729d:	8d 76 00             	lea    0x0(%esi),%esi
f01072a0:	75 19                	jne    f01072bb <readline+0x7b>
f01072a2:	85 f6                	test   %esi,%esi
f01072a4:	7e 15                	jle    f01072bb <readline+0x7b>
			if (echoing)
f01072a6:	85 ff                	test   %edi,%edi
f01072a8:	74 0c                	je     f01072b6 <readline+0x76>
				cputchar('\b');
f01072aa:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
f01072b1:	e8 94 94 ff ff       	call   f010074a <cputchar>
			i--;
f01072b6:	83 ee 01             	sub    $0x1,%esi
	while (1) {
		c = getchar();
		if (c < 0) {
			cprintf("read error: %e\n", c);
			return NULL;
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f01072b9:	eb b8                	jmp    f0107273 <readline+0x33>
			if (echoing)
				cputchar('\b');
			i--;
		} else if (c >= ' ' && i < BUFLEN-1) {
f01072bb:	83 fb 1f             	cmp    $0x1f,%ebx
f01072be:	66 90                	xchg   %ax,%ax
f01072c0:	7e 23                	jle    f01072e5 <readline+0xa5>
f01072c2:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f01072c8:	7f 1b                	jg     f01072e5 <readline+0xa5>
			if (echoing)
f01072ca:	85 ff                	test   %edi,%edi
f01072cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01072d0:	74 08                	je     f01072da <readline+0x9a>
				cputchar(c);
f01072d2:	89 1c 24             	mov    %ebx,(%esp)
f01072d5:	e8 70 94 ff ff       	call   f010074a <cputchar>
			buf[i++] = c;
f01072da:	88 9e a0 3a 29 f0    	mov    %bl,-0xfd6c560(%esi)
f01072e0:	83 c6 01             	add    $0x1,%esi
f01072e3:	eb 8e                	jmp    f0107273 <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f01072e5:	83 fb 0a             	cmp    $0xa,%ebx
f01072e8:	74 05                	je     f01072ef <readline+0xaf>
f01072ea:	83 fb 0d             	cmp    $0xd,%ebx
f01072ed:	75 84                	jne    f0107273 <readline+0x33>
			if (echoing)
f01072ef:	85 ff                	test   %edi,%edi
f01072f1:	74 0c                	je     f01072ff <readline+0xbf>
				cputchar('\n');
f01072f3:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
f01072fa:	e8 4b 94 ff ff       	call   f010074a <cputchar>
			buf[i] = 0;
f01072ff:	c6 86 a0 3a 29 f0 00 	movb   $0x0,-0xfd6c560(%esi)
f0107306:	b8 a0 3a 29 f0       	mov    $0xf0293aa0,%eax
			return buf;
		}
	}
}
f010730b:	83 c4 1c             	add    $0x1c,%esp
f010730e:	5b                   	pop    %ebx
f010730f:	5e                   	pop    %esi
f0107310:	5f                   	pop    %edi
f0107311:	5d                   	pop    %ebp
f0107312:	c3                   	ret    
	...

f0107320 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0107320:	55                   	push   %ebp
f0107321:	89 e5                	mov    %esp,%ebp
f0107323:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0107326:	b8 00 00 00 00       	mov    $0x0,%eax
f010732b:	80 3a 00             	cmpb   $0x0,(%edx)
f010732e:	74 09                	je     f0107339 <strlen+0x19>
		n++;
f0107330:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0107333:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0107337:	75 f7                	jne    f0107330 <strlen+0x10>
		n++;
	return n;
}
f0107339:	5d                   	pop    %ebp
f010733a:	c3                   	ret    

f010733b <strnlen>:

int
strnlen(const char *s, size_t size)
{
f010733b:	55                   	push   %ebp
f010733c:	89 e5                	mov    %esp,%ebp
f010733e:	53                   	push   %ebx
f010733f:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0107342:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0107345:	85 c9                	test   %ecx,%ecx
f0107347:	74 19                	je     f0107362 <strnlen+0x27>
f0107349:	80 3b 00             	cmpb   $0x0,(%ebx)
f010734c:	74 14                	je     f0107362 <strnlen+0x27>
f010734e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
f0107353:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0107356:	39 c8                	cmp    %ecx,%eax
f0107358:	74 0d                	je     f0107367 <strnlen+0x2c>
f010735a:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
f010735e:	75 f3                	jne    f0107353 <strnlen+0x18>
f0107360:	eb 05                	jmp    f0107367 <strnlen+0x2c>
f0107362:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
f0107367:	5b                   	pop    %ebx
f0107368:	5d                   	pop    %ebp
f0107369:	c3                   	ret    

f010736a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f010736a:	55                   	push   %ebp
f010736b:	89 e5                	mov    %esp,%ebp
f010736d:	53                   	push   %ebx
f010736e:	8b 45 08             	mov    0x8(%ebp),%eax
f0107371:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0107374:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0107379:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
f010737d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f0107380:	83 c2 01             	add    $0x1,%edx
f0107383:	84 c9                	test   %cl,%cl
f0107385:	75 f2                	jne    f0107379 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f0107387:	5b                   	pop    %ebx
f0107388:	5d                   	pop    %ebp
f0107389:	c3                   	ret    

f010738a <strcat>:

char *
strcat(char *dst, const char *src)
{
f010738a:	55                   	push   %ebp
f010738b:	89 e5                	mov    %esp,%ebp
f010738d:	53                   	push   %ebx
f010738e:	83 ec 08             	sub    $0x8,%esp
f0107391:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0107394:	89 1c 24             	mov    %ebx,(%esp)
f0107397:	e8 84 ff ff ff       	call   f0107320 <strlen>
	strcpy(dst + len, src);
f010739c:	8b 55 0c             	mov    0xc(%ebp),%edx
f010739f:	89 54 24 04          	mov    %edx,0x4(%esp)
f01073a3:	8d 04 03             	lea    (%ebx,%eax,1),%eax
f01073a6:	89 04 24             	mov    %eax,(%esp)
f01073a9:	e8 bc ff ff ff       	call   f010736a <strcpy>
	return dst;
}
f01073ae:	89 d8                	mov    %ebx,%eax
f01073b0:	83 c4 08             	add    $0x8,%esp
f01073b3:	5b                   	pop    %ebx
f01073b4:	5d                   	pop    %ebp
f01073b5:	c3                   	ret    

f01073b6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f01073b6:	55                   	push   %ebp
f01073b7:	89 e5                	mov    %esp,%ebp
f01073b9:	56                   	push   %esi
f01073ba:	53                   	push   %ebx
f01073bb:	8b 45 08             	mov    0x8(%ebp),%eax
f01073be:	8b 55 0c             	mov    0xc(%ebp),%edx
f01073c1:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01073c4:	85 f6                	test   %esi,%esi
f01073c6:	74 18                	je     f01073e0 <strncpy+0x2a>
f01073c8:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
f01073cd:	0f b6 1a             	movzbl (%edx),%ebx
f01073d0:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f01073d3:	80 3a 01             	cmpb   $0x1,(%edx)
f01073d6:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01073d9:	83 c1 01             	add    $0x1,%ecx
f01073dc:	39 ce                	cmp    %ecx,%esi
f01073de:	77 ed                	ja     f01073cd <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f01073e0:	5b                   	pop    %ebx
f01073e1:	5e                   	pop    %esi
f01073e2:	5d                   	pop    %ebp
f01073e3:	c3                   	ret    

f01073e4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f01073e4:	55                   	push   %ebp
f01073e5:	89 e5                	mov    %esp,%ebp
f01073e7:	56                   	push   %esi
f01073e8:	53                   	push   %ebx
f01073e9:	8b 75 08             	mov    0x8(%ebp),%esi
f01073ec:	8b 55 0c             	mov    0xc(%ebp),%edx
f01073ef:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f01073f2:	89 f0                	mov    %esi,%eax
f01073f4:	85 c9                	test   %ecx,%ecx
f01073f6:	74 27                	je     f010741f <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
f01073f8:	83 e9 01             	sub    $0x1,%ecx
f01073fb:	74 1d                	je     f010741a <strlcpy+0x36>
f01073fd:	0f b6 1a             	movzbl (%edx),%ebx
f0107400:	84 db                	test   %bl,%bl
f0107402:	74 16                	je     f010741a <strlcpy+0x36>
			*dst++ = *src++;
f0107404:	88 18                	mov    %bl,(%eax)
f0107406:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0107409:	83 e9 01             	sub    $0x1,%ecx
f010740c:	74 0e                	je     f010741c <strlcpy+0x38>
			*dst++ = *src++;
f010740e:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0107411:	0f b6 1a             	movzbl (%edx),%ebx
f0107414:	84 db                	test   %bl,%bl
f0107416:	75 ec                	jne    f0107404 <strlcpy+0x20>
f0107418:	eb 02                	jmp    f010741c <strlcpy+0x38>
f010741a:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
f010741c:	c6 00 00             	movb   $0x0,(%eax)
f010741f:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
f0107421:	5b                   	pop    %ebx
f0107422:	5e                   	pop    %esi
f0107423:	5d                   	pop    %ebp
f0107424:	c3                   	ret    

f0107425 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0107425:	55                   	push   %ebp
f0107426:	89 e5                	mov    %esp,%ebp
f0107428:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010742b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f010742e:	0f b6 01             	movzbl (%ecx),%eax
f0107431:	84 c0                	test   %al,%al
f0107433:	74 15                	je     f010744a <strcmp+0x25>
f0107435:	3a 02                	cmp    (%edx),%al
f0107437:	75 11                	jne    f010744a <strcmp+0x25>
		p++, q++;
f0107439:	83 c1 01             	add    $0x1,%ecx
f010743c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f010743f:	0f b6 01             	movzbl (%ecx),%eax
f0107442:	84 c0                	test   %al,%al
f0107444:	74 04                	je     f010744a <strcmp+0x25>
f0107446:	3a 02                	cmp    (%edx),%al
f0107448:	74 ef                	je     f0107439 <strcmp+0x14>
f010744a:	0f b6 c0             	movzbl %al,%eax
f010744d:	0f b6 12             	movzbl (%edx),%edx
f0107450:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0107452:	5d                   	pop    %ebp
f0107453:	c3                   	ret    

f0107454 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0107454:	55                   	push   %ebp
f0107455:	89 e5                	mov    %esp,%ebp
f0107457:	53                   	push   %ebx
f0107458:	8b 55 08             	mov    0x8(%ebp),%edx
f010745b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010745e:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
f0107461:	85 c0                	test   %eax,%eax
f0107463:	74 23                	je     f0107488 <strncmp+0x34>
f0107465:	0f b6 1a             	movzbl (%edx),%ebx
f0107468:	84 db                	test   %bl,%bl
f010746a:	74 25                	je     f0107491 <strncmp+0x3d>
f010746c:	3a 19                	cmp    (%ecx),%bl
f010746e:	75 21                	jne    f0107491 <strncmp+0x3d>
f0107470:	83 e8 01             	sub    $0x1,%eax
f0107473:	74 13                	je     f0107488 <strncmp+0x34>
		n--, p++, q++;
f0107475:	83 c2 01             	add    $0x1,%edx
f0107478:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f010747b:	0f b6 1a             	movzbl (%edx),%ebx
f010747e:	84 db                	test   %bl,%bl
f0107480:	74 0f                	je     f0107491 <strncmp+0x3d>
f0107482:	3a 19                	cmp    (%ecx),%bl
f0107484:	74 ea                	je     f0107470 <strncmp+0x1c>
f0107486:	eb 09                	jmp    f0107491 <strncmp+0x3d>
f0107488:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f010748d:	5b                   	pop    %ebx
f010748e:	5d                   	pop    %ebp
f010748f:	90                   	nop
f0107490:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0107491:	0f b6 02             	movzbl (%edx),%eax
f0107494:	0f b6 11             	movzbl (%ecx),%edx
f0107497:	29 d0                	sub    %edx,%eax
f0107499:	eb f2                	jmp    f010748d <strncmp+0x39>

f010749b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f010749b:	55                   	push   %ebp
f010749c:	89 e5                	mov    %esp,%ebp
f010749e:	8b 45 08             	mov    0x8(%ebp),%eax
f01074a1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01074a5:	0f b6 10             	movzbl (%eax),%edx
f01074a8:	84 d2                	test   %dl,%dl
f01074aa:	74 18                	je     f01074c4 <strchr+0x29>
		if (*s == c)
f01074ac:	38 ca                	cmp    %cl,%dl
f01074ae:	75 0a                	jne    f01074ba <strchr+0x1f>
f01074b0:	eb 17                	jmp    f01074c9 <strchr+0x2e>
f01074b2:	38 ca                	cmp    %cl,%dl
f01074b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01074b8:	74 0f                	je     f01074c9 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f01074ba:	83 c0 01             	add    $0x1,%eax
f01074bd:	0f b6 10             	movzbl (%eax),%edx
f01074c0:	84 d2                	test   %dl,%dl
f01074c2:	75 ee                	jne    f01074b2 <strchr+0x17>
f01074c4:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
f01074c9:	5d                   	pop    %ebp
f01074ca:	c3                   	ret    

f01074cb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f01074cb:	55                   	push   %ebp
f01074cc:	89 e5                	mov    %esp,%ebp
f01074ce:	8b 45 08             	mov    0x8(%ebp),%eax
f01074d1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01074d5:	0f b6 10             	movzbl (%eax),%edx
f01074d8:	84 d2                	test   %dl,%dl
f01074da:	74 18                	je     f01074f4 <strfind+0x29>
		if (*s == c)
f01074dc:	38 ca                	cmp    %cl,%dl
f01074de:	75 0a                	jne    f01074ea <strfind+0x1f>
f01074e0:	eb 12                	jmp    f01074f4 <strfind+0x29>
f01074e2:	38 ca                	cmp    %cl,%dl
f01074e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01074e8:	74 0a                	je     f01074f4 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f01074ea:	83 c0 01             	add    $0x1,%eax
f01074ed:	0f b6 10             	movzbl (%eax),%edx
f01074f0:	84 d2                	test   %dl,%dl
f01074f2:	75 ee                	jne    f01074e2 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
f01074f4:	5d                   	pop    %ebp
f01074f5:	c3                   	ret    

f01074f6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f01074f6:	55                   	push   %ebp
f01074f7:	89 e5                	mov    %esp,%ebp
f01074f9:	83 ec 0c             	sub    $0xc,%esp
f01074fc:	89 1c 24             	mov    %ebx,(%esp)
f01074ff:	89 74 24 04          	mov    %esi,0x4(%esp)
f0107503:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0107507:	8b 7d 08             	mov    0x8(%ebp),%edi
f010750a:	8b 45 0c             	mov    0xc(%ebp),%eax
f010750d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0107510:	85 c9                	test   %ecx,%ecx
f0107512:	74 30                	je     f0107544 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0107514:	f7 c7 03 00 00 00    	test   $0x3,%edi
f010751a:	75 25                	jne    f0107541 <memset+0x4b>
f010751c:	f6 c1 03             	test   $0x3,%cl
f010751f:	75 20                	jne    f0107541 <memset+0x4b>
		c &= 0xFF;
f0107521:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0107524:	89 d3                	mov    %edx,%ebx
f0107526:	c1 e3 08             	shl    $0x8,%ebx
f0107529:	89 d6                	mov    %edx,%esi
f010752b:	c1 e6 18             	shl    $0x18,%esi
f010752e:	89 d0                	mov    %edx,%eax
f0107530:	c1 e0 10             	shl    $0x10,%eax
f0107533:	09 f0                	or     %esi,%eax
f0107535:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
f0107537:	09 d8                	or     %ebx,%eax
f0107539:	c1 e9 02             	shr    $0x2,%ecx
f010753c:	fc                   	cld    
f010753d:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f010753f:	eb 03                	jmp    f0107544 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0107541:	fc                   	cld    
f0107542:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0107544:	89 f8                	mov    %edi,%eax
f0107546:	8b 1c 24             	mov    (%esp),%ebx
f0107549:	8b 74 24 04          	mov    0x4(%esp),%esi
f010754d:	8b 7c 24 08          	mov    0x8(%esp),%edi
f0107551:	89 ec                	mov    %ebp,%esp
f0107553:	5d                   	pop    %ebp
f0107554:	c3                   	ret    

f0107555 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0107555:	55                   	push   %ebp
f0107556:	89 e5                	mov    %esp,%ebp
f0107558:	83 ec 08             	sub    $0x8,%esp
f010755b:	89 34 24             	mov    %esi,(%esp)
f010755e:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0107562:	8b 45 08             	mov    0x8(%ebp),%eax
f0107565:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
f0107568:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
f010756b:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
f010756d:	39 c6                	cmp    %eax,%esi
f010756f:	73 35                	jae    f01075a6 <memmove+0x51>
f0107571:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0107574:	39 d0                	cmp    %edx,%eax
f0107576:	73 2e                	jae    f01075a6 <memmove+0x51>
		s += n;
		d += n;
f0107578:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010757a:	f6 c2 03             	test   $0x3,%dl
f010757d:	75 1b                	jne    f010759a <memmove+0x45>
f010757f:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0107585:	75 13                	jne    f010759a <memmove+0x45>
f0107587:	f6 c1 03             	test   $0x3,%cl
f010758a:	75 0e                	jne    f010759a <memmove+0x45>
			asm volatile("std; rep movsl\n"
f010758c:	83 ef 04             	sub    $0x4,%edi
f010758f:	8d 72 fc             	lea    -0x4(%edx),%esi
f0107592:	c1 e9 02             	shr    $0x2,%ecx
f0107595:	fd                   	std    
f0107596:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0107598:	eb 09                	jmp    f01075a3 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f010759a:	83 ef 01             	sub    $0x1,%edi
f010759d:	8d 72 ff             	lea    -0x1(%edx),%esi
f01075a0:	fd                   	std    
f01075a1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f01075a3:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
f01075a4:	eb 20                	jmp    f01075c6 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01075a6:	f7 c6 03 00 00 00    	test   $0x3,%esi
f01075ac:	75 15                	jne    f01075c3 <memmove+0x6e>
f01075ae:	f7 c7 03 00 00 00    	test   $0x3,%edi
f01075b4:	75 0d                	jne    f01075c3 <memmove+0x6e>
f01075b6:	f6 c1 03             	test   $0x3,%cl
f01075b9:	75 08                	jne    f01075c3 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
f01075bb:	c1 e9 02             	shr    $0x2,%ecx
f01075be:	fc                   	cld    
f01075bf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01075c1:	eb 03                	jmp    f01075c6 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f01075c3:	fc                   	cld    
f01075c4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f01075c6:	8b 34 24             	mov    (%esp),%esi
f01075c9:	8b 7c 24 04          	mov    0x4(%esp),%edi
f01075cd:	89 ec                	mov    %ebp,%esp
f01075cf:	5d                   	pop    %ebp
f01075d0:	c3                   	ret    

f01075d1 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
f01075d1:	55                   	push   %ebp
f01075d2:	89 e5                	mov    %esp,%ebp
f01075d4:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f01075d7:	8b 45 10             	mov    0x10(%ebp),%eax
f01075da:	89 44 24 08          	mov    %eax,0x8(%esp)
f01075de:	8b 45 0c             	mov    0xc(%ebp),%eax
f01075e1:	89 44 24 04          	mov    %eax,0x4(%esp)
f01075e5:	8b 45 08             	mov    0x8(%ebp),%eax
f01075e8:	89 04 24             	mov    %eax,(%esp)
f01075eb:	e8 65 ff ff ff       	call   f0107555 <memmove>
}
f01075f0:	c9                   	leave  
f01075f1:	c3                   	ret    

f01075f2 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f01075f2:	55                   	push   %ebp
f01075f3:	89 e5                	mov    %esp,%ebp
f01075f5:	57                   	push   %edi
f01075f6:	56                   	push   %esi
f01075f7:	53                   	push   %ebx
f01075f8:	8b 75 08             	mov    0x8(%ebp),%esi
f01075fb:	8b 7d 0c             	mov    0xc(%ebp),%edi
f01075fe:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0107601:	85 c9                	test   %ecx,%ecx
f0107603:	74 36                	je     f010763b <memcmp+0x49>
		if (*s1 != *s2)
f0107605:	0f b6 06             	movzbl (%esi),%eax
f0107608:	0f b6 1f             	movzbl (%edi),%ebx
f010760b:	38 d8                	cmp    %bl,%al
f010760d:	74 20                	je     f010762f <memcmp+0x3d>
f010760f:	eb 14                	jmp    f0107625 <memcmp+0x33>
f0107611:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
f0107616:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
f010761b:	83 c2 01             	add    $0x1,%edx
f010761e:	83 e9 01             	sub    $0x1,%ecx
f0107621:	38 d8                	cmp    %bl,%al
f0107623:	74 12                	je     f0107637 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
f0107625:	0f b6 c0             	movzbl %al,%eax
f0107628:	0f b6 db             	movzbl %bl,%ebx
f010762b:	29 d8                	sub    %ebx,%eax
f010762d:	eb 11                	jmp    f0107640 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010762f:	83 e9 01             	sub    $0x1,%ecx
f0107632:	ba 00 00 00 00       	mov    $0x0,%edx
f0107637:	85 c9                	test   %ecx,%ecx
f0107639:	75 d6                	jne    f0107611 <memcmp+0x1f>
f010763b:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
f0107640:	5b                   	pop    %ebx
f0107641:	5e                   	pop    %esi
f0107642:	5f                   	pop    %edi
f0107643:	5d                   	pop    %ebp
f0107644:	c3                   	ret    

f0107645 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0107645:	55                   	push   %ebp
f0107646:	89 e5                	mov    %esp,%ebp
f0107648:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f010764b:	89 c2                	mov    %eax,%edx
f010764d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0107650:	39 d0                	cmp    %edx,%eax
f0107652:	73 15                	jae    f0107669 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
f0107654:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
f0107658:	38 08                	cmp    %cl,(%eax)
f010765a:	75 06                	jne    f0107662 <memfind+0x1d>
f010765c:	eb 0b                	jmp    f0107669 <memfind+0x24>
f010765e:	38 08                	cmp    %cl,(%eax)
f0107660:	74 07                	je     f0107669 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0107662:	83 c0 01             	add    $0x1,%eax
f0107665:	39 c2                	cmp    %eax,%edx
f0107667:	77 f5                	ja     f010765e <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0107669:	5d                   	pop    %ebp
f010766a:	c3                   	ret    

f010766b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f010766b:	55                   	push   %ebp
f010766c:	89 e5                	mov    %esp,%ebp
f010766e:	57                   	push   %edi
f010766f:	56                   	push   %esi
f0107670:	53                   	push   %ebx
f0107671:	83 ec 04             	sub    $0x4,%esp
f0107674:	8b 55 08             	mov    0x8(%ebp),%edx
f0107677:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010767a:	0f b6 02             	movzbl (%edx),%eax
f010767d:	3c 20                	cmp    $0x20,%al
f010767f:	74 04                	je     f0107685 <strtol+0x1a>
f0107681:	3c 09                	cmp    $0x9,%al
f0107683:	75 0e                	jne    f0107693 <strtol+0x28>
		s++;
f0107685:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0107688:	0f b6 02             	movzbl (%edx),%eax
f010768b:	3c 20                	cmp    $0x20,%al
f010768d:	74 f6                	je     f0107685 <strtol+0x1a>
f010768f:	3c 09                	cmp    $0x9,%al
f0107691:	74 f2                	je     f0107685 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
f0107693:	3c 2b                	cmp    $0x2b,%al
f0107695:	75 0c                	jne    f01076a3 <strtol+0x38>
		s++;
f0107697:	83 c2 01             	add    $0x1,%edx
f010769a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
f01076a1:	eb 15                	jmp    f01076b8 <strtol+0x4d>
	else if (*s == '-')
f01076a3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
f01076aa:	3c 2d                	cmp    $0x2d,%al
f01076ac:	75 0a                	jne    f01076b8 <strtol+0x4d>
		s++, neg = 1;
f01076ae:	83 c2 01             	add    $0x1,%edx
f01076b1:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01076b8:	85 db                	test   %ebx,%ebx
f01076ba:	0f 94 c0             	sete   %al
f01076bd:	74 05                	je     f01076c4 <strtol+0x59>
f01076bf:	83 fb 10             	cmp    $0x10,%ebx
f01076c2:	75 18                	jne    f01076dc <strtol+0x71>
f01076c4:	80 3a 30             	cmpb   $0x30,(%edx)
f01076c7:	75 13                	jne    f01076dc <strtol+0x71>
f01076c9:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f01076cd:	8d 76 00             	lea    0x0(%esi),%esi
f01076d0:	75 0a                	jne    f01076dc <strtol+0x71>
		s += 2, base = 16;
f01076d2:	83 c2 02             	add    $0x2,%edx
f01076d5:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01076da:	eb 15                	jmp    f01076f1 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01076dc:	84 c0                	test   %al,%al
f01076de:	66 90                	xchg   %ax,%ax
f01076e0:	74 0f                	je     f01076f1 <strtol+0x86>
f01076e2:	bb 0a 00 00 00       	mov    $0xa,%ebx
f01076e7:	80 3a 30             	cmpb   $0x30,(%edx)
f01076ea:	75 05                	jne    f01076f1 <strtol+0x86>
		s++, base = 8;
f01076ec:	83 c2 01             	add    $0x1,%edx
f01076ef:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01076f1:	b8 00 00 00 00       	mov    $0x0,%eax
f01076f6:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f01076f8:	0f b6 0a             	movzbl (%edx),%ecx
f01076fb:	89 cf                	mov    %ecx,%edi
f01076fd:	8d 59 d0             	lea    -0x30(%ecx),%ebx
f0107700:	80 fb 09             	cmp    $0x9,%bl
f0107703:	77 08                	ja     f010770d <strtol+0xa2>
			dig = *s - '0';
f0107705:	0f be c9             	movsbl %cl,%ecx
f0107708:	83 e9 30             	sub    $0x30,%ecx
f010770b:	eb 1e                	jmp    f010772b <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
f010770d:	8d 5f 9f             	lea    -0x61(%edi),%ebx
f0107710:	80 fb 19             	cmp    $0x19,%bl
f0107713:	77 08                	ja     f010771d <strtol+0xb2>
			dig = *s - 'a' + 10;
f0107715:	0f be c9             	movsbl %cl,%ecx
f0107718:	83 e9 57             	sub    $0x57,%ecx
f010771b:	eb 0e                	jmp    f010772b <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
f010771d:	8d 5f bf             	lea    -0x41(%edi),%ebx
f0107720:	80 fb 19             	cmp    $0x19,%bl
f0107723:	77 15                	ja     f010773a <strtol+0xcf>
			dig = *s - 'A' + 10;
f0107725:	0f be c9             	movsbl %cl,%ecx
f0107728:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f010772b:	39 f1                	cmp    %esi,%ecx
f010772d:	7d 0b                	jge    f010773a <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
f010772f:	83 c2 01             	add    $0x1,%edx
f0107732:	0f af c6             	imul   %esi,%eax
f0107735:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
f0107738:	eb be                	jmp    f01076f8 <strtol+0x8d>
f010773a:	89 c1                	mov    %eax,%ecx

	if (endptr)
f010773c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0107740:	74 05                	je     f0107747 <strtol+0xdc>
		*endptr = (char *) s;
f0107742:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0107745:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
f0107747:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
f010774b:	74 04                	je     f0107751 <strtol+0xe6>
f010774d:	89 c8                	mov    %ecx,%eax
f010774f:	f7 d8                	neg    %eax
}
f0107751:	83 c4 04             	add    $0x4,%esp
f0107754:	5b                   	pop    %ebx
f0107755:	5e                   	pop    %esi
f0107756:	5f                   	pop    %edi
f0107757:	5d                   	pop    %ebp
f0107758:	c3                   	ret    
f0107759:	00 00                	add    %al,(%eax)
	...

f010775c <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f010775c:	fa                   	cli    

	xorw    %ax, %ax
f010775d:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f010775f:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0107761:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0107763:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f0107765:	0f 01 16             	lgdtl  (%esi)
f0107768:	74 70                	je     f01077da <mpentry_end+0x4>
	movl    %cr0, %eax
f010776a:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f010776d:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f0107771:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f0107774:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f010777a:	08 00                	or     %al,(%eax)

f010777c <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f010777c:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f0107780:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0107782:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0107784:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f0107786:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f010778a:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f010778c:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f010778e:	b8 00 60 12 00       	mov    $0x126000,%eax
	movl    %eax, %cr3
f0107793:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f0107796:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f0107799:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f010779e:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in mem_init()
	movl    mpentry_kstack, %esp
f01077a1:	8b 25 b0 3e 29 f0    	mov    0xf0293eb0,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f01077a7:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f01077ac:	b8 ed 00 10 f0       	mov    $0xf01000ed,%eax
	call    *%eax
f01077b1:	ff d0                	call   *%eax

f01077b3 <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f01077b3:	eb fe                	jmp    f01077b3 <spin>
f01077b5:	8d 76 00             	lea    0x0(%esi),%esi

f01077b8 <gdt>:
	...
f01077c0:	ff                   	(bad)  
f01077c1:	ff 00                	incl   (%eax)
f01077c3:	00 00                	add    %al,(%eax)
f01077c5:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f01077cc:	00 92 cf 00 17 00    	add    %dl,0x1700cf(%edx)

f01077d0 <gdtdesc>:
f01077d0:	17                   	pop    %ss
f01077d1:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f01077d6 <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f01077d6:	90                   	nop
	...

f01077e0 <sum>:
#define MPIOINTR  0x03  // One per bus interrupt source
#define MPLINTR   0x04  // One per system interrupt source

static uint8_t
sum(void *addr, int len)
{
f01077e0:	55                   	push   %ebp
f01077e1:	89 e5                	mov    %esp,%ebp
f01077e3:	56                   	push   %esi
f01077e4:	53                   	push   %ebx
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f01077e5:	bb 00 00 00 00       	mov    $0x0,%ebx
f01077ea:	b9 00 00 00 00       	mov    $0x0,%ecx
f01077ef:	85 d2                	test   %edx,%edx
f01077f1:	7e 0d                	jle    f0107800 <sum+0x20>
		sum += ((uint8_t *)addr)[i];
f01077f3:	0f b6 34 08          	movzbl (%eax,%ecx,1),%esi
f01077f7:	01 f3                	add    %esi,%ebx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f01077f9:	83 c1 01             	add    $0x1,%ecx
f01077fc:	39 d1                	cmp    %edx,%ecx
f01077fe:	75 f3                	jne    f01077f3 <sum+0x13>
		sum += ((uint8_t *)addr)[i];
	return sum;
}
f0107800:	89 d8                	mov    %ebx,%eax
f0107802:	5b                   	pop    %ebx
f0107803:	5e                   	pop    %esi
f0107804:	5d                   	pop    %ebp
f0107805:	c3                   	ret    

f0107806 <mpsearch1>:

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f0107806:	55                   	push   %ebp
f0107807:	89 e5                	mov    %esp,%ebp
f0107809:	56                   	push   %esi
f010780a:	53                   	push   %ebx
f010780b:	83 ec 10             	sub    $0x10,%esp
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010780e:	8b 0d b4 3e 29 f0    	mov    0xf0293eb4,%ecx
f0107814:	89 c3                	mov    %eax,%ebx
f0107816:	c1 eb 0c             	shr    $0xc,%ebx
f0107819:	39 cb                	cmp    %ecx,%ebx
f010781b:	72 20                	jb     f010783d <mpsearch1+0x37>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010781d:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0107821:	c7 44 24 08 c0 8d 10 	movl   $0xf0108dc0,0x8(%esp)
f0107828:	f0 
f0107829:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f0107830:	00 
f0107831:	c7 04 24 fd a9 10 f0 	movl   $0xf010a9fd,(%esp)
f0107838:	e8 48 88 ff ff       	call   f0100085 <_panic>
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f010783d:	8d 34 02             	lea    (%edx,%eax,1),%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0107840:	89 f2                	mov    %esi,%edx
f0107842:	c1 ea 0c             	shr    $0xc,%edx
f0107845:	39 d1                	cmp    %edx,%ecx
f0107847:	77 20                	ja     f0107869 <mpsearch1+0x63>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0107849:	89 74 24 0c          	mov    %esi,0xc(%esp)
f010784d:	c7 44 24 08 c0 8d 10 	movl   $0xf0108dc0,0x8(%esp)
f0107854:	f0 
f0107855:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f010785c:	00 
f010785d:	c7 04 24 fd a9 10 f0 	movl   $0xf010a9fd,(%esp)
f0107864:	e8 1c 88 ff ff       	call   f0100085 <_panic>
f0107869:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
f010786f:	81 ee 00 00 00 10    	sub    $0x10000000,%esi

	for (; mp < end; mp++)
f0107875:	39 f3                	cmp    %esi,%ebx
f0107877:	73 33                	jae    f01078ac <mpsearch1+0xa6>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0107879:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
f0107880:	00 
f0107881:	c7 44 24 04 0d aa 10 	movl   $0xf010aa0d,0x4(%esp)
f0107888:	f0 
f0107889:	89 1c 24             	mov    %ebx,(%esp)
f010788c:	e8 61 fd ff ff       	call   f01075f2 <memcmp>
f0107891:	85 c0                	test   %eax,%eax
f0107893:	75 10                	jne    f01078a5 <mpsearch1+0x9f>
		    sum(mp, sizeof(*mp)) == 0)
f0107895:	ba 10 00 00 00       	mov    $0x10,%edx
f010789a:	89 d8                	mov    %ebx,%eax
f010789c:	e8 3f ff ff ff       	call   f01077e0 <sum>
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f01078a1:	84 c0                	test   %al,%al
f01078a3:	74 0c                	je     f01078b1 <mpsearch1+0xab>
static struct mp *
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
f01078a5:	83 c3 10             	add    $0x10,%ebx
f01078a8:	39 de                	cmp    %ebx,%esi
f01078aa:	77 cd                	ja     f0107879 <mpsearch1+0x73>
f01078ac:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
}
f01078b1:	89 d8                	mov    %ebx,%eax
f01078b3:	83 c4 10             	add    $0x10,%esp
f01078b6:	5b                   	pop    %ebx
f01078b7:	5e                   	pop    %esi
f01078b8:	5d                   	pop    %ebp
f01078b9:	c3                   	ret    

f01078ba <mp_init>:
	return conf;
}

void
mp_init(void)
{
f01078ba:	55                   	push   %ebp
f01078bb:	89 e5                	mov    %esp,%ebp
f01078bd:	57                   	push   %edi
f01078be:	56                   	push   %esi
f01078bf:	53                   	push   %ebx
f01078c0:	83 ec 2c             	sub    $0x2c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f01078c3:	c7 05 c0 43 29 f0 20 	movl   $0xf0294020,0xf02943c0
f01078ca:	40 29 f0 
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01078cd:	83 3d b4 3e 29 f0 00 	cmpl   $0x0,0xf0293eb4
f01078d4:	75 24                	jne    f01078fa <mp_init+0x40>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01078d6:	c7 44 24 0c 00 04 00 	movl   $0x400,0xc(%esp)
f01078dd:	00 
f01078de:	c7 44 24 08 c0 8d 10 	movl   $0xf0108dc0,0x8(%esp)
f01078e5:	f0 
f01078e6:	c7 44 24 04 6f 00 00 	movl   $0x6f,0x4(%esp)
f01078ed:	00 
f01078ee:	c7 04 24 fd a9 10 f0 	movl   $0xf010a9fd,(%esp)
f01078f5:	e8 8b 87 ff ff       	call   f0100085 <_panic>
	// The BIOS data area lives in 16-bit segment 0x40.
	bda = (uint8_t *) KADDR(0x40 << 4);

	// [MP 4] The 16-bit segment of the EBDA is in the two bytes
	// starting at byte 0x0E of the BDA.  0 if not present.
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f01078fa:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f0107901:	85 c0                	test   %eax,%eax
f0107903:	74 16                	je     f010791b <mp_init+0x61>
		p <<= 4;	// Translate from segment to PA
		if ((mp = mpsearch1(p, 1024)))
f0107905:	c1 e0 04             	shl    $0x4,%eax
f0107908:	ba 00 04 00 00       	mov    $0x400,%edx
f010790d:	e8 f4 fe ff ff       	call   f0107806 <mpsearch1>
f0107912:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0107915:	85 c0                	test   %eax,%eax
f0107917:	75 3c                	jne    f0107955 <mp_init+0x9b>
f0107919:	eb 20                	jmp    f010793b <mp_init+0x81>
			return mp;
	} else {
		// The size of base memory, in KB is in the two bytes
		// starting at 0x13 of the BDA.
		p = *(uint16_t *) (bda + 0x13) * 1024;
		if ((mp = mpsearch1(p - 1024, 1024)))
f010791b:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f0107922:	c1 e0 0a             	shl    $0xa,%eax
f0107925:	2d 00 04 00 00       	sub    $0x400,%eax
f010792a:	ba 00 04 00 00       	mov    $0x400,%edx
f010792f:	e8 d2 fe ff ff       	call   f0107806 <mpsearch1>
f0107934:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0107937:	85 c0                	test   %eax,%eax
f0107939:	75 1a                	jne    f0107955 <mp_init+0x9b>
			return mp;
	}
	return mpsearch1(0xF0000, 0x10000);
f010793b:	ba 00 00 01 00       	mov    $0x10000,%edx
f0107940:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f0107945:	e8 bc fe ff ff       	call   f0107806 <mpsearch1>
f010794a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
mpconfig(struct mp **pmp)
{
	struct mpconf *conf;
	struct mp *mp;

	if ((mp = mpsearch()) == 0)
f010794d:	85 c0                	test   %eax,%eax
f010794f:	0f 84 27 02 00 00    	je     f0107b7c <mp_init+0x2c2>
		return NULL;
	if (mp->physaddr == 0 || mp->type != 0) {
f0107955:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0107958:	8b 78 04             	mov    0x4(%eax),%edi
f010795b:	85 ff                	test   %edi,%edi
f010795d:	74 06                	je     f0107965 <mp_init+0xab>
f010795f:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f0107963:	74 11                	je     f0107976 <mp_init+0xbc>
		cprintf("SMP: Default configurations not implemented\n");
f0107965:	c7 04 24 70 a8 10 f0 	movl   $0xf010a870,(%esp)
f010796c:	e8 9e d2 ff ff       	call   f0104c0f <cprintf>
f0107971:	e9 06 02 00 00       	jmp    f0107b7c <mp_init+0x2c2>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0107976:	89 f8                	mov    %edi,%eax
f0107978:	c1 e8 0c             	shr    $0xc,%eax
f010797b:	3b 05 b4 3e 29 f0    	cmp    0xf0293eb4,%eax
f0107981:	72 20                	jb     f01079a3 <mp_init+0xe9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0107983:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0107987:	c7 44 24 08 c0 8d 10 	movl   $0xf0108dc0,0x8(%esp)
f010798e:	f0 
f010798f:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
f0107996:	00 
f0107997:	c7 04 24 fd a9 10 f0 	movl   $0xf010a9fd,(%esp)
f010799e:	e8 e2 86 ff ff       	call   f0100085 <_panic>
		return NULL;
	}
	conf = (struct mpconf *) KADDR(mp->physaddr);
f01079a3:	81 ef 00 00 00 10    	sub    $0x10000000,%edi
	if (memcmp(conf, "PCMP", 4) != 0) {
f01079a9:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
f01079b0:	00 
f01079b1:	c7 44 24 04 12 aa 10 	movl   $0xf010aa12,0x4(%esp)
f01079b8:	f0 
f01079b9:	89 3c 24             	mov    %edi,(%esp)
f01079bc:	e8 31 fc ff ff       	call   f01075f2 <memcmp>
f01079c1:	85 c0                	test   %eax,%eax
f01079c3:	74 11                	je     f01079d6 <mp_init+0x11c>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f01079c5:	c7 04 24 a0 a8 10 f0 	movl   $0xf010a8a0,(%esp)
f01079cc:	e8 3e d2 ff ff       	call   f0104c0f <cprintf>
f01079d1:	e9 a6 01 00 00       	jmp    f0107b7c <mp_init+0x2c2>
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f01079d6:	0f b7 57 04          	movzwl 0x4(%edi),%edx
f01079da:	89 f8                	mov    %edi,%eax
f01079dc:	e8 ff fd ff ff       	call   f01077e0 <sum>
f01079e1:	84 c0                	test   %al,%al
f01079e3:	74 11                	je     f01079f6 <mp_init+0x13c>
		cprintf("SMP: Bad MP configuration checksum\n");
f01079e5:	c7 04 24 d4 a8 10 f0 	movl   $0xf010a8d4,(%esp)
f01079ec:	e8 1e d2 ff ff       	call   f0104c0f <cprintf>
f01079f1:	e9 86 01 00 00       	jmp    f0107b7c <mp_init+0x2c2>
		return NULL;
	}
	if (conf->version != 1 && conf->version != 4) {
f01079f6:	0f b6 47 06          	movzbl 0x6(%edi),%eax
f01079fa:	3c 01                	cmp    $0x1,%al
f01079fc:	74 1c                	je     f0107a1a <mp_init+0x160>
f01079fe:	3c 04                	cmp    $0x4,%al
f0107a00:	74 18                	je     f0107a1a <mp_init+0x160>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f0107a02:	0f b6 c0             	movzbl %al,%eax
f0107a05:	89 44 24 04          	mov    %eax,0x4(%esp)
f0107a09:	c7 04 24 f8 a8 10 f0 	movl   $0xf010a8f8,(%esp)
f0107a10:	e8 fa d1 ff ff       	call   f0104c0f <cprintf>
f0107a15:	e9 62 01 00 00       	jmp    f0107b7c <mp_init+0x2c2>
		return NULL;
	}
	if (sum((uint8_t *)conf + conf->length, conf->xlength) != conf->xchecksum) {
f0107a1a:	0f b7 57 28          	movzwl 0x28(%edi),%edx
f0107a1e:	0f b7 47 04          	movzwl 0x4(%edi),%eax
f0107a22:	8d 04 07             	lea    (%edi,%eax,1),%eax
f0107a25:	e8 b6 fd ff ff       	call   f01077e0 <sum>
f0107a2a:	3a 47 2a             	cmp    0x2a(%edi),%al
f0107a2d:	74 11                	je     f0107a40 <mp_init+0x186>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f0107a2f:	c7 04 24 18 a9 10 f0 	movl   $0xf010a918,(%esp)
f0107a36:	e8 d4 d1 ff ff       	call   f0104c0f <cprintf>
f0107a3b:	e9 3c 01 00 00       	jmp    f0107b7c <mp_init+0x2c2>
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
	if ((conf = mpconfig(&mp)) == 0)
f0107a40:	85 ff                	test   %edi,%edi
f0107a42:	0f 84 34 01 00 00    	je     f0107b7c <mp_init+0x2c2>
		return;
	ismp = 1;
f0107a48:	c7 05 00 40 29 f0 01 	movl   $0x1,0xf0294000
f0107a4f:	00 00 00 
	lapic = (uint32_t *)conf->lapicaddr;
f0107a52:	8b 47 24             	mov    0x24(%edi),%eax
f0107a55:	a3 00 50 2d f0       	mov    %eax,0xf02d5000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0107a5a:	66 83 7f 22 00       	cmpw   $0x0,0x22(%edi)
f0107a5f:	0f 84 98 00 00 00    	je     f0107afd <mp_init+0x243>
f0107a65:	8d 5f 2c             	lea    0x2c(%edi),%ebx
f0107a68:	be 00 00 00 00       	mov    $0x0,%esi
		switch (*p) {
f0107a6d:	0f b6 03             	movzbl (%ebx),%eax
f0107a70:	84 c0                	test   %al,%al
f0107a72:	74 06                	je     f0107a7a <mp_init+0x1c0>
f0107a74:	3c 04                	cmp    $0x4,%al
f0107a76:	77 55                	ja     f0107acd <mp_init+0x213>
f0107a78:	eb 4e                	jmp    f0107ac8 <mp_init+0x20e>
		case MPPROC:
			proc = (struct mpproc *)p;
f0107a7a:	89 da                	mov    %ebx,%edx
			if (proc->flags & MPPROC_BOOT)
f0107a7c:	f6 43 03 02          	testb  $0x2,0x3(%ebx)
f0107a80:	74 11                	je     f0107a93 <mp_init+0x1d9>
				bootcpu = &cpus[ncpu];
f0107a82:	6b 05 c4 43 29 f0 74 	imul   $0x74,0xf02943c4,%eax
f0107a89:	05 20 40 29 f0       	add    $0xf0294020,%eax
f0107a8e:	a3 c0 43 29 f0       	mov    %eax,0xf02943c0
			if (ncpu < NCPU) {
f0107a93:	a1 c4 43 29 f0       	mov    0xf02943c4,%eax
f0107a98:	83 f8 07             	cmp    $0x7,%eax
f0107a9b:	7f 12                	jg     f0107aaf <mp_init+0x1f5>
				cpus[ncpu].cpu_id = ncpu;
f0107a9d:	6b d0 74             	imul   $0x74,%eax,%edx
f0107aa0:	88 82 20 40 29 f0    	mov    %al,-0xfd6bfe0(%edx)
				ncpu++;
f0107aa6:	83 05 c4 43 29 f0 01 	addl   $0x1,0xf02943c4
f0107aad:	eb 14                	jmp    f0107ac3 <mp_init+0x209>
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f0107aaf:	0f b6 42 01          	movzbl 0x1(%edx),%eax
f0107ab3:	89 44 24 04          	mov    %eax,0x4(%esp)
f0107ab7:	c7 04 24 48 a9 10 f0 	movl   $0xf010a948,(%esp)
f0107abe:	e8 4c d1 ff ff       	call   f0104c0f <cprintf>
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f0107ac3:	83 c3 14             	add    $0x14,%ebx
			continue;
f0107ac6:	eb 26                	jmp    f0107aee <mp_init+0x234>
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f0107ac8:	83 c3 08             	add    $0x8,%ebx
			continue;
f0107acb:	eb 21                	jmp    f0107aee <mp_init+0x234>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f0107acd:	0f b6 c0             	movzbl %al,%eax
f0107ad0:	89 44 24 04          	mov    %eax,0x4(%esp)
f0107ad4:	c7 04 24 70 a9 10 f0 	movl   $0xf010a970,(%esp)
f0107adb:	e8 2f d1 ff ff       	call   f0104c0f <cprintf>
			ismp = 0;
f0107ae0:	c7 05 00 40 29 f0 00 	movl   $0x0,0xf0294000
f0107ae7:	00 00 00 
			i = conf->entry;
f0107aea:	0f b7 77 22          	movzwl 0x22(%edi),%esi
	if ((conf = mpconfig(&mp)) == 0)
		return;
	ismp = 1;
	lapic = (uint32_t *)conf->lapicaddr;

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0107aee:	83 c6 01             	add    $0x1,%esi
f0107af1:	0f b7 47 22          	movzwl 0x22(%edi),%eax
f0107af5:	39 f0                	cmp    %esi,%eax
f0107af7:	0f 87 70 ff ff ff    	ja     f0107a6d <mp_init+0x1b3>
			ismp = 0;
			i = conf->entry;
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f0107afd:	a1 c0 43 29 f0       	mov    0xf02943c0,%eax
f0107b02:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f0107b09:	83 3d 00 40 29 f0 00 	cmpl   $0x0,0xf0294000
f0107b10:	75 22                	jne    f0107b34 <mp_init+0x27a>
		// Didn't like what we found; fall back to no MP.
		ncpu = 1;
f0107b12:	c7 05 c4 43 29 f0 01 	movl   $0x1,0xf02943c4
f0107b19:	00 00 00 
		lapic = NULL;
f0107b1c:	c7 05 00 50 2d f0 00 	movl   $0x0,0xf02d5000
f0107b23:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f0107b26:	c7 04 24 90 a9 10 f0 	movl   $0xf010a990,(%esp)
f0107b2d:	e8 dd d0 ff ff       	call   f0104c0f <cprintf>
		return;
f0107b32:	eb 48                	jmp    f0107b7c <mp_init+0x2c2>
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f0107b34:	a1 c4 43 29 f0       	mov    0xf02943c4,%eax
f0107b39:	89 44 24 08          	mov    %eax,0x8(%esp)
f0107b3d:	a1 c0 43 29 f0       	mov    0xf02943c0,%eax
f0107b42:	0f b6 00             	movzbl (%eax),%eax
f0107b45:	89 44 24 04          	mov    %eax,0x4(%esp)
f0107b49:	c7 04 24 17 aa 10 f0 	movl   $0xf010aa17,(%esp)
f0107b50:	e8 ba d0 ff ff       	call   f0104c0f <cprintf>

	if (mp->imcrp) {
f0107b55:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0107b58:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f0107b5c:	74 1e                	je     f0107b7c <mp_init+0x2c2>
		// [MP 3.2.6.1] If the hardware implements PIC mode,
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f0107b5e:	c7 04 24 bc a9 10 f0 	movl   $0xf010a9bc,(%esp)
f0107b65:	e8 a5 d0 ff ff       	call   f0104c0f <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0107b6a:	ba 22 00 00 00       	mov    $0x22,%edx
f0107b6f:	b8 70 00 00 00       	mov    $0x70,%eax
f0107b74:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0107b75:	b2 23                	mov    $0x23,%dl
f0107b77:	ec                   	in     (%dx),%al
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0107b78:	83 c8 01             	or     $0x1,%eax
f0107b7b:	ee                   	out    %al,(%dx)
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
	}
}
f0107b7c:	83 c4 2c             	add    $0x2c,%esp
f0107b7f:	5b                   	pop    %ebx
f0107b80:	5e                   	pop    %esi
f0107b81:	5f                   	pop    %edi
f0107b82:	5d                   	pop    %ebp
f0107b83:	c3                   	ret    

f0107b84 <lapicw>:

volatile uint32_t *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
f0107b84:	55                   	push   %ebp
f0107b85:	89 e5                	mov    %esp,%ebp
	lapic[index] = value;
f0107b87:	c1 e0 02             	shl    $0x2,%eax
f0107b8a:	03 05 00 50 2d f0    	add    0xf02d5000,%eax
f0107b90:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f0107b92:	a1 00 50 2d f0       	mov    0xf02d5000,%eax
f0107b97:	83 c0 20             	add    $0x20,%eax
f0107b9a:	8b 00                	mov    (%eax),%eax
}
f0107b9c:	5d                   	pop    %ebp
f0107b9d:	c3                   	ret    

f0107b9e <cpunum>:
	lapicw(TPR, 0);
}

int
cpunum(void)
{
f0107b9e:	55                   	push   %ebp
f0107b9f:	89 e5                	mov    %esp,%ebp
	if (lapic)
f0107ba1:	8b 15 00 50 2d f0    	mov    0xf02d5000,%edx
f0107ba7:	b8 00 00 00 00       	mov    $0x0,%eax
f0107bac:	85 d2                	test   %edx,%edx
f0107bae:	74 08                	je     f0107bb8 <cpunum+0x1a>
		return lapic[ID] >> 24;
f0107bb0:	83 c2 20             	add    $0x20,%edx
f0107bb3:	8b 02                	mov    (%edx),%eax
f0107bb5:	c1 e8 18             	shr    $0x18,%eax
	return 0;
}
f0107bb8:	5d                   	pop    %ebp
f0107bb9:	c3                   	ret    

f0107bba <lapic_init>:
	lapic[ID];  // wait for write to finish, by reading
}

void
lapic_init(void)
{
f0107bba:	55                   	push   %ebp
f0107bbb:	89 e5                	mov    %esp,%ebp
	if (!lapic) 
f0107bbd:	83 3d 00 50 2d f0 00 	cmpl   $0x0,0xf02d5000
f0107bc4:	0f 84 0b 01 00 00    	je     f0107cd5 <lapic_init+0x11b>
		return;

	// Enable local APIC; set spurious interrupt vector.
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f0107bca:	ba 27 01 00 00       	mov    $0x127,%edx
f0107bcf:	b8 3c 00 00 00       	mov    $0x3c,%eax
f0107bd4:	e8 ab ff ff ff       	call   f0107b84 <lapicw>

	// The timer repeatedly counts down at bus frequency
	// from lapic[TICR] and then issues an interrupt.  
	// If we cared more about precise timekeeping,
	// TICR would be calibrated using an external time source.
	lapicw(TDCR, X1);
f0107bd9:	ba 0b 00 00 00       	mov    $0xb,%edx
f0107bde:	b8 f8 00 00 00       	mov    $0xf8,%eax
f0107be3:	e8 9c ff ff ff       	call   f0107b84 <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f0107be8:	ba 20 00 02 00       	mov    $0x20020,%edx
f0107bed:	b8 c8 00 00 00       	mov    $0xc8,%eax
f0107bf2:	e8 8d ff ff ff       	call   f0107b84 <lapicw>
	lapicw(TICR, 10000000); 
f0107bf7:	ba 80 96 98 00       	mov    $0x989680,%edx
f0107bfc:	b8 e0 00 00 00       	mov    $0xe0,%eax
f0107c01:	e8 7e ff ff ff       	call   f0107b84 <lapicw>
	//
	// According to Intel MP Specification, the BIOS should initialize
	// BSP's local APIC in Virtual Wire Mode, in which 8259A's
	// INTR is virtually connected to BSP's LINTIN0. In this mode,
	// we do not need to program the IOAPIC.
	if (thiscpu != bootcpu)
f0107c06:	e8 93 ff ff ff       	call   f0107b9e <cpunum>
f0107c0b:	6b c0 74             	imul   $0x74,%eax,%eax
f0107c0e:	05 20 40 29 f0       	add    $0xf0294020,%eax
f0107c13:	39 05 c0 43 29 f0    	cmp    %eax,0xf02943c0
f0107c19:	74 0f                	je     f0107c2a <lapic_init+0x70>
		lapicw(LINT0, MASKED);
f0107c1b:	ba 00 00 01 00       	mov    $0x10000,%edx
f0107c20:	b8 d4 00 00 00       	mov    $0xd4,%eax
f0107c25:	e8 5a ff ff ff       	call   f0107b84 <lapicw>

	// Disable NMI (LINT1) on all CPUs
	lapicw(LINT1, MASKED);
f0107c2a:	ba 00 00 01 00       	mov    $0x10000,%edx
f0107c2f:	b8 d8 00 00 00       	mov    $0xd8,%eax
f0107c34:	e8 4b ff ff ff       	call   f0107b84 <lapicw>

	// Disable performance counter overflow interrupts
	// on machines that provide that interrupt entry.
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f0107c39:	a1 00 50 2d f0       	mov    0xf02d5000,%eax
f0107c3e:	83 c0 30             	add    $0x30,%eax
f0107c41:	8b 00                	mov    (%eax),%eax
f0107c43:	c1 e8 10             	shr    $0x10,%eax
f0107c46:	3c 03                	cmp    $0x3,%al
f0107c48:	76 0f                	jbe    f0107c59 <lapic_init+0x9f>
		lapicw(PCINT, MASKED);
f0107c4a:	ba 00 00 01 00       	mov    $0x10000,%edx
f0107c4f:	b8 d0 00 00 00       	mov    $0xd0,%eax
f0107c54:	e8 2b ff ff ff       	call   f0107b84 <lapicw>

	// Map error interrupt to IRQ_ERROR.
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f0107c59:	ba 33 00 00 00       	mov    $0x33,%edx
f0107c5e:	b8 dc 00 00 00       	mov    $0xdc,%eax
f0107c63:	e8 1c ff ff ff       	call   f0107b84 <lapicw>

	// Clear error status register (requires back-to-back writes).
	lapicw(ESR, 0);
f0107c68:	ba 00 00 00 00       	mov    $0x0,%edx
f0107c6d:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0107c72:	e8 0d ff ff ff       	call   f0107b84 <lapicw>
	lapicw(ESR, 0);
f0107c77:	ba 00 00 00 00       	mov    $0x0,%edx
f0107c7c:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0107c81:	e8 fe fe ff ff       	call   f0107b84 <lapicw>

	// Ack any outstanding interrupts.
	lapicw(EOI, 0);
f0107c86:	ba 00 00 00 00       	mov    $0x0,%edx
f0107c8b:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0107c90:	e8 ef fe ff ff       	call   f0107b84 <lapicw>

	// Send an Init Level De-Assert to synchronize arbitration ID's.
	lapicw(ICRHI, 0);
f0107c95:	ba 00 00 00 00       	mov    $0x0,%edx
f0107c9a:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0107c9f:	e8 e0 fe ff ff       	call   f0107b84 <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f0107ca4:	ba 00 85 08 00       	mov    $0x88500,%edx
f0107ca9:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0107cae:	e8 d1 fe ff ff       	call   f0107b84 <lapicw>
	while(lapic[ICRLO] & DELIVS)
f0107cb3:	8b 15 00 50 2d f0    	mov    0xf02d5000,%edx
f0107cb9:	81 c2 00 03 00 00    	add    $0x300,%edx
f0107cbf:	8b 02                	mov    (%edx),%eax
f0107cc1:	f6 c4 10             	test   $0x10,%ah
f0107cc4:	75 f9                	jne    f0107cbf <lapic_init+0x105>
		;

	// Enable interrupts on the APIC (but not on the processor).
	lapicw(TPR, 0);
f0107cc6:	ba 00 00 00 00       	mov    $0x0,%edx
f0107ccb:	b8 20 00 00 00       	mov    $0x20,%eax
f0107cd0:	e8 af fe ff ff       	call   f0107b84 <lapicw>
}
f0107cd5:	5d                   	pop    %ebp
f0107cd6:	c3                   	ret    

f0107cd7 <lapic_eoi>:
}

// Acknowledge interrupt.
void
lapic_eoi(void)
{
f0107cd7:	55                   	push   %ebp
f0107cd8:	89 e5                	mov    %esp,%ebp
	if (lapic)
f0107cda:	83 3d 00 50 2d f0 00 	cmpl   $0x0,0xf02d5000
f0107ce1:	74 0f                	je     f0107cf2 <lapic_eoi+0x1b>
		lapicw(EOI, 0);
f0107ce3:	ba 00 00 00 00       	mov    $0x0,%edx
f0107ce8:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0107ced:	e8 92 fe ff ff       	call   f0107b84 <lapicw>
}
f0107cf2:	5d                   	pop    %ebp
f0107cf3:	c3                   	ret    

f0107cf4 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
static void
microdelay(int us)
{
f0107cf4:	55                   	push   %ebp
f0107cf5:	89 e5                	mov    %esp,%ebp
}
f0107cf7:	5d                   	pop    %ebp
f0107cf8:	c3                   	ret    

f0107cf9 <lapic_ipi>:
	}
}

void
lapic_ipi(int vector)
{
f0107cf9:	55                   	push   %ebp
f0107cfa:	89 e5                	mov    %esp,%ebp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f0107cfc:	8b 55 08             	mov    0x8(%ebp),%edx
f0107cff:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f0107d05:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0107d0a:	e8 75 fe ff ff       	call   f0107b84 <lapicw>
	while (lapic[ICRLO] & DELIVS)
f0107d0f:	8b 15 00 50 2d f0    	mov    0xf02d5000,%edx
f0107d15:	81 c2 00 03 00 00    	add    $0x300,%edx
f0107d1b:	8b 02                	mov    (%edx),%eax
f0107d1d:	f6 c4 10             	test   $0x10,%ah
f0107d20:	75 f9                	jne    f0107d1b <lapic_ipi+0x22>
		;
}
f0107d22:	5d                   	pop    %ebp
f0107d23:	c3                   	ret    

f0107d24 <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f0107d24:	55                   	push   %ebp
f0107d25:	89 e5                	mov    %esp,%ebp
f0107d27:	56                   	push   %esi
f0107d28:	53                   	push   %ebx
f0107d29:	83 ec 10             	sub    $0x10,%esp
f0107d2c:	8b 75 0c             	mov    0xc(%ebp),%esi
f0107d2f:	0f b6 5d 08          	movzbl 0x8(%ebp),%ebx
f0107d33:	ba 70 00 00 00       	mov    $0x70,%edx
f0107d38:	b8 0f 00 00 00       	mov    $0xf,%eax
f0107d3d:	ee                   	out    %al,(%dx)
f0107d3e:	b2 71                	mov    $0x71,%dl
f0107d40:	b8 0a 00 00 00       	mov    $0xa,%eax
f0107d45:	ee                   	out    %al,(%dx)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0107d46:	83 3d b4 3e 29 f0 00 	cmpl   $0x0,0xf0293eb4
f0107d4d:	75 24                	jne    f0107d73 <lapic_startap+0x4f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0107d4f:	c7 44 24 0c 67 04 00 	movl   $0x467,0xc(%esp)
f0107d56:	00 
f0107d57:	c7 44 24 08 c0 8d 10 	movl   $0xf0108dc0,0x8(%esp)
f0107d5e:	f0 
f0107d5f:	c7 44 24 04 93 00 00 	movl   $0x93,0x4(%esp)
f0107d66:	00 
f0107d67:	c7 04 24 34 aa 10 f0 	movl   $0xf010aa34,(%esp)
f0107d6e:	e8 12 83 ff ff       	call   f0100085 <_panic>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f0107d73:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f0107d7a:	00 00 
	wrv[1] = addr >> 4;
f0107d7c:	89 f0                	mov    %esi,%eax
f0107d7e:	c1 e8 04             	shr    $0x4,%eax
f0107d81:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f0107d87:	c1 e3 18             	shl    $0x18,%ebx
f0107d8a:	89 da                	mov    %ebx,%edx
f0107d8c:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0107d91:	e8 ee fd ff ff       	call   f0107b84 <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f0107d96:	ba 00 c5 00 00       	mov    $0xc500,%edx
f0107d9b:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0107da0:	e8 df fd ff ff       	call   f0107b84 <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f0107da5:	ba 00 85 00 00       	mov    $0x8500,%edx
f0107daa:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0107daf:	e8 d0 fd ff ff       	call   f0107b84 <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0107db4:	c1 ee 0c             	shr    $0xc,%esi
f0107db7:	81 ce 00 06 00 00    	or     $0x600,%esi
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0107dbd:	89 da                	mov    %ebx,%edx
f0107dbf:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0107dc4:	e8 bb fd ff ff       	call   f0107b84 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0107dc9:	89 f2                	mov    %esi,%edx
f0107dcb:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0107dd0:	e8 af fd ff ff       	call   f0107b84 <lapicw>
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0107dd5:	89 da                	mov    %ebx,%edx
f0107dd7:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0107ddc:	e8 a3 fd ff ff       	call   f0107b84 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0107de1:	89 f2                	mov    %esi,%edx
f0107de3:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0107de8:	e8 97 fd ff ff       	call   f0107b84 <lapicw>
		microdelay(200);
	}
}
f0107ded:	83 c4 10             	add    $0x10,%esp
f0107df0:	5b                   	pop    %ebx
f0107df1:	5e                   	pop    %esi
f0107df2:	5d                   	pop    %ebp
f0107df3:	c3                   	ret    
	...

f0107e00 <__spin_initlock>:
}
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f0107e00:	55                   	push   %ebp
f0107e01:	89 e5                	mov    %esp,%ebp
f0107e03:	8b 45 08             	mov    0x8(%ebp),%eax
#ifndef USE_TICKET_SPIN_LOCK
	lk->locked = 0;
f0107e06:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
        lk->next = 0;

#endif

#ifdef DEBUG_SPINLOCK
	lk->name = name;
f0107e0c:	8b 55 0c             	mov    0xc(%ebp),%edx
f0107e0f:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f0107e12:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f0107e19:	5d                   	pop    %ebp
f0107e1a:	c3                   	ret    

f0107e1b <holding>:
}

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
f0107e1b:	55                   	push   %ebp
f0107e1c:	89 e5                	mov    %esp,%ebp
f0107e1e:	53                   	push   %ebx
f0107e1f:	83 ec 04             	sub    $0x4,%esp
f0107e22:	89 c2                	mov    %eax,%edx
#ifndef USE_TICKET_SPIN_LOCK
	return lock->locked && lock->cpu == thiscpu;
f0107e24:	b8 00 00 00 00       	mov    $0x0,%eax
f0107e29:	83 3a 00             	cmpl   $0x0,(%edx)
f0107e2c:	74 18                	je     f0107e46 <holding+0x2b>
f0107e2e:	8b 5a 08             	mov    0x8(%edx),%ebx
f0107e31:	e8 68 fd ff ff       	call   f0107b9e <cpunum>
f0107e36:	6b c0 74             	imul   $0x74,%eax,%eax
f0107e39:	05 20 40 29 f0       	add    $0xf0294020,%eax
f0107e3e:	39 c3                	cmp    %eax,%ebx
f0107e40:	0f 94 c0             	sete   %al
f0107e43:	0f b6 c0             	movzbl %al,%eax
	//LAB 4: Your code here
        return lock->own != lock->next && lock->cpu == thiscpu;
	//panic("ticket spinlock: not implemented yet");

#endif
}
f0107e46:	83 c4 04             	add    $0x4,%esp
f0107e49:	5b                   	pop    %ebx
f0107e4a:	5d                   	pop    %ebp
f0107e4b:	c3                   	ret    

f0107e4c <spin_unlock>:
}

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f0107e4c:	55                   	push   %ebp
f0107e4d:	89 e5                	mov    %esp,%ebp
f0107e4f:	83 ec 78             	sub    $0x78,%esp
f0107e52:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0107e55:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0107e58:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0107e5b:	8b 5d 08             	mov    0x8(%ebp),%ebx
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
f0107e5e:	89 d8                	mov    %ebx,%eax
f0107e60:	e8 b6 ff ff ff       	call   f0107e1b <holding>
f0107e65:	85 c0                	test   %eax,%eax
f0107e67:	0f 85 d5 00 00 00    	jne    f0107f42 <spin_unlock+0xf6>
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f0107e6d:	c7 44 24 08 28 00 00 	movl   $0x28,0x8(%esp)
f0107e74:	00 
f0107e75:	8d 43 0c             	lea    0xc(%ebx),%eax
f0107e78:	89 44 24 04          	mov    %eax,0x4(%esp)
f0107e7c:	8d 45 a8             	lea    -0x58(%ebp),%eax
f0107e7f:	89 04 24             	mov    %eax,(%esp)
f0107e82:	e8 ce f6 ff ff       	call   f0107555 <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f0107e87:	8b 43 08             	mov    0x8(%ebx),%eax
f0107e8a:	0f b6 30             	movzbl (%eax),%esi
f0107e8d:	8b 5b 04             	mov    0x4(%ebx),%ebx
f0107e90:	e8 09 fd ff ff       	call   f0107b9e <cpunum>
f0107e95:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0107e99:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0107e9d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0107ea1:	c7 04 24 44 aa 10 f0 	movl   $0xf010aa44,(%esp)
f0107ea8:	e8 62 cd ff ff       	call   f0104c0f <cprintf>
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f0107ead:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0107eb0:	85 c0                	test   %eax,%eax
f0107eb2:	74 72                	je     f0107f26 <spin_unlock+0xda>
f0107eb4:	8d 5d a8             	lea    -0x58(%ebp),%ebx
#endif
}

// Release the lock.
void
spin_unlock(struct spinlock *lk)
f0107eb7:	8d 7d cc             	lea    -0x34(%ebp),%edi
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f0107eba:	8d 75 d0             	lea    -0x30(%ebp),%esi
f0107ebd:	89 74 24 04          	mov    %esi,0x4(%esp)
f0107ec1:	89 04 24             	mov    %eax,(%esp)
f0107ec4:	e8 e5 e8 ff ff       	call   f01067ae <debuginfo_eip>
f0107ec9:	85 c0                	test   %eax,%eax
f0107ecb:	78 39                	js     f0107f06 <spin_unlock+0xba>
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
f0107ecd:	8b 03                	mov    (%ebx),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f0107ecf:	89 c2                	mov    %eax,%edx
f0107ed1:	2b 55 e0             	sub    -0x20(%ebp),%edx
f0107ed4:	89 54 24 18          	mov    %edx,0x18(%esp)
f0107ed8:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0107edb:	89 54 24 14          	mov    %edx,0x14(%esp)
f0107edf:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0107ee2:	89 54 24 10          	mov    %edx,0x10(%esp)
f0107ee6:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0107ee9:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0107eed:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0107ef0:	89 54 24 08          	mov    %edx,0x8(%esp)
f0107ef4:	89 44 24 04          	mov    %eax,0x4(%esp)
f0107ef8:	c7 04 24 a6 aa 10 f0 	movl   $0xf010aaa6,(%esp)
f0107eff:	e8 0b cd ff ff       	call   f0104c0f <cprintf>
f0107f04:	eb 12                	jmp    f0107f18 <spin_unlock+0xcc>
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
f0107f06:	8b 03                	mov    (%ebx),%eax
f0107f08:	89 44 24 04          	mov    %eax,0x4(%esp)
f0107f0c:	c7 04 24 bd aa 10 f0 	movl   $0xf010aabd,(%esp)
f0107f13:	e8 f7 cc ff ff       	call   f0104c0f <cprintf>
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f0107f18:	39 fb                	cmp    %edi,%ebx
f0107f1a:	74 0a                	je     f0107f26 <spin_unlock+0xda>
f0107f1c:	8b 43 04             	mov    0x4(%ebx),%eax
f0107f1f:	83 c3 04             	add    $0x4,%ebx
f0107f22:	85 c0                	test   %eax,%eax
f0107f24:	75 97                	jne    f0107ebd <spin_unlock+0x71>
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
f0107f26:	c7 44 24 08 c5 aa 10 	movl   $0xf010aac5,0x8(%esp)
f0107f2d:	f0 
f0107f2e:	c7 44 24 04 8a 00 00 	movl   $0x8a,0x4(%esp)
f0107f35:	00 
f0107f36:	c7 04 24 d1 aa 10 f0 	movl   $0xf010aad1,(%esp)
f0107f3d:	e8 43 81 ff ff       	call   f0100085 <_panic>
	}

	lk->pcs[0] = 0;
f0107f42:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
	lk->cpu = 0;
f0107f49:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0107f50:	b8 00 00 00 00       	mov    $0x0,%eax
f0107f55:	f0 87 03             	lock xchg %eax,(%ebx)
	xchg(&lk->locked, 0);
#else
	//LAB 4: Your code here
        atomic_return_and_add(&lk->own,1);
#endif
}
f0107f58:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0107f5b:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0107f5e:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0107f61:	89 ec                	mov    %ebp,%esp
f0107f63:	5d                   	pop    %ebp
f0107f64:	c3                   	ret    

f0107f65 <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f0107f65:	55                   	push   %ebp
f0107f66:	89 e5                	mov    %esp,%ebp
f0107f68:	56                   	push   %esi
f0107f69:	53                   	push   %ebx
f0107f6a:	83 ec 20             	sub    $0x20,%esp
f0107f6d:	8b 5d 08             	mov    0x8(%ebp),%ebx
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f0107f70:	89 d8                	mov    %ebx,%eax
f0107f72:	e8 a4 fe ff ff       	call   f0107e1b <holding>
f0107f77:	85 c0                	test   %eax,%eax
f0107f79:	75 12                	jne    f0107f8d <spin_lock+0x28>

#ifndef USE_TICKET_SPIN_LOCK
	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f0107f7b:	89 da                	mov    %ebx,%edx
f0107f7d:	b0 01                	mov    $0x1,%al
f0107f7f:	f0 87 03             	lock xchg %eax,(%ebx)
f0107f82:	b9 01 00 00 00       	mov    $0x1,%ecx
f0107f87:	85 c0                	test   %eax,%eax
f0107f89:	75 2e                	jne    f0107fb9 <spin_lock+0x54>
f0107f8b:	eb 37                	jmp    f0107fc4 <spin_lock+0x5f>
void
spin_lock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f0107f8d:	8b 5b 04             	mov    0x4(%ebx),%ebx
f0107f90:	e8 09 fc ff ff       	call   f0107b9e <cpunum>
f0107f95:	89 5c 24 10          	mov    %ebx,0x10(%esp)
f0107f99:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0107f9d:	c7 44 24 08 7c aa 10 	movl   $0xf010aa7c,0x8(%esp)
f0107fa4:	f0 
f0107fa5:	c7 44 24 04 5c 00 00 	movl   $0x5c,0x4(%esp)
f0107fac:	00 
f0107fad:	c7 04 24 d1 aa 10 f0 	movl   $0xf010aad1,(%esp)
f0107fb4:	e8 cc 80 ff ff       	call   f0100085 <_panic>
#ifndef USE_TICKET_SPIN_LOCK
	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f0107fb9:	f3 90                	pause  
f0107fbb:	89 c8                	mov    %ecx,%eax
f0107fbd:	f0 87 02             	lock xchg %eax,(%edx)

#ifndef USE_TICKET_SPIN_LOCK
	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f0107fc0:	85 c0                	test   %eax,%eax
f0107fc2:	75 f5                	jne    f0107fb9 <spin_lock+0x54>

#endif

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f0107fc4:	e8 d5 fb ff ff       	call   f0107b9e <cpunum>
f0107fc9:	6b c0 74             	imul   $0x74,%eax,%eax
f0107fcc:	05 20 40 29 f0       	add    $0xf0294020,%eax
f0107fd1:	89 43 08             	mov    %eax,0x8(%ebx)
	get_caller_pcs(lk->pcs);
f0107fd4:	8d 73 0c             	lea    0xc(%ebx),%esi
get_caller_pcs(uint32_t pcs[])
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
f0107fd7:	89 e8                	mov    %ebp,%eax
	for (i = 0; i < 10; i++){
		if (ebp == 0 || ebp < (uint32_t *)ULIM
f0107fd9:	8d 90 00 00 80 10    	lea    0x10800000(%eax),%edx
f0107fdf:	81 fa ff ff 7f 0e    	cmp    $0xe7fffff,%edx
f0107fe5:	76 40                	jbe    f0108027 <spin_lock+0xc2>
f0107fe7:	eb 33                	jmp    f010801c <spin_lock+0xb7>
f0107fe9:	8d 8a 00 00 80 10    	lea    0x10800000(%edx),%ecx
f0107fef:	81 f9 ff ff 7f 0e    	cmp    $0xe7fffff,%ecx
f0107ff5:	77 2a                	ja     f0108021 <spin_lock+0xbc>
		    || ebp >= (uint32_t *)IOMEMBASE)
			break;
		pcs[i] = ebp[1];          // saved %eip
f0107ff7:	8b 4a 04             	mov    0x4(%edx),%ecx
f0107ffa:	89 0c 86             	mov    %ecx,(%esi,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f0107ffd:	8b 12                	mov    (%edx),%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f0107fff:	83 c0 01             	add    $0x1,%eax
f0108002:	83 f8 0a             	cmp    $0xa,%eax
f0108005:	75 e2                	jne    f0107fe9 <spin_lock+0x84>
f0108007:	eb 2d                	jmp    f0108036 <spin_lock+0xd1>
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
		pcs[i] = 0;
f0108009:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
		    || ebp >= (uint32_t *)IOMEMBASE)
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
f010800f:	83 c0 01             	add    $0x1,%eax
f0108012:	83 c2 04             	add    $0x4,%edx
f0108015:	83 f8 09             	cmp    $0x9,%eax
f0108018:	7e ef                	jle    f0108009 <spin_lock+0xa4>
f010801a:	eb 1a                	jmp    f0108036 <spin_lock+0xd1>
	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
	get_caller_pcs(lk->pcs);
#endif
}
f010801c:	b8 00 00 00 00       	mov    $0x0,%eax
// Acquire the lock.
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
f0108021:	8d 54 83 0c          	lea    0xc(%ebx,%eax,4),%edx
f0108025:	eb e2                	jmp    f0108009 <spin_lock+0xa4>
	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
		if (ebp == 0 || ebp < (uint32_t *)ULIM
		    || ebp >= (uint32_t *)IOMEMBASE)
			break;
		pcs[i] = ebp[1];          // saved %eip
f0108027:	8b 50 04             	mov    0x4(%eax),%edx
f010802a:	89 53 0c             	mov    %edx,0xc(%ebx)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f010802d:	8b 10                	mov    (%eax),%edx
f010802f:	b8 01 00 00 00       	mov    $0x1,%eax
f0108034:	eb b3                	jmp    f0107fe9 <spin_lock+0x84>
	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
	get_caller_pcs(lk->pcs);
#endif
}
f0108036:	83 c4 20             	add    $0x20,%esp
f0108039:	5b                   	pop    %ebx
f010803a:	5e                   	pop    %esi
f010803b:	5d                   	pop    %ebp
f010803c:	c3                   	ret    
f010803d:	00 00                	add    %al,(%eax)
	...

f0108040 <receive_packet>:
       cprintf("%x ",*((char*)((uint32_t)begin->addr) + i));
   cprintf("%d\n",begin->cmd);*/
   return 0;
}

int receive_packet(struct rx_desc* rd){
f0108040:	55                   	push   %ebp
f0108041:	89 e5                	mov    %esp,%ebp
f0108043:	56                   	push   %esi
f0108044:	53                   	push   %ebx
f0108045:	83 ec 10             	sub    $0x10,%esp
f0108048:	8b 4d 08             	mov    0x8(%ebp),%ecx
    uint32_t num = (*rdt + 1) % RXDESC_LENGTH; 
f010804b:	a1 28 50 2d f0       	mov    0xf02d5028,%eax
f0108050:	8b 18                	mov    (%eax),%ebx
f0108052:	83 c3 01             	add    $0x1,%ebx
f0108055:	83 e3 3f             	and    $0x3f,%ebx
    //cprintf("%d\n",num);
    if(rx_table[num].status & E1000_RXD_STAT_DD){
f0108058:	89 d8                	mov    %ebx,%eax
f010805a:	c1 e0 04             	shl    $0x4,%eax
f010805d:	0f b6 90 6c 54 2f f0 	movzbl -0xfd0ab94(%eax),%edx
f0108064:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0108069:	f6 c2 01             	test   $0x1,%dl
f010806c:	74 4d                	je     f01080bb <receive_packet+0x7b>
       if(!(rx_table[num].status & E1000_RXD_STAT_EOP)){
f010806e:	f6 c2 02             	test   $0x2,%dl
f0108071:	75 13                	jne    f0108086 <receive_packet+0x46>
            cprintf("eop miss\n");
f0108073:	c7 04 24 ed aa 10 f0 	movl   $0xf010aaed,(%esp)
f010807a:	e8 90 cb ff ff       	call   f0104c0f <cprintf>
f010807f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
            return -1;
f0108084:	eb 35                	jmp    f01080bb <receive_packet+0x7b>
       }
       *rd = rx_table[num];
f0108086:	ba 60 54 2f f0       	mov    $0xf02f5460,%edx
f010808b:	89 d8                	mov    %ebx,%eax
f010808d:	c1 e0 04             	shl    $0x4,%eax
f0108090:	8b 34 10             	mov    (%eax,%edx,1),%esi
f0108093:	89 31                	mov    %esi,(%ecx)
f0108095:	8b 74 10 04          	mov    0x4(%eax,%edx,1),%esi
f0108099:	89 71 04             	mov    %esi,0x4(%ecx)
f010809c:	8b 74 10 08          	mov    0x8(%eax,%edx,1),%esi
f01080a0:	89 71 08             	mov    %esi,0x8(%ecx)
f01080a3:	8b 74 10 0c          	mov    0xc(%eax,%edx,1),%esi
f01080a7:	89 71 0c             	mov    %esi,0xc(%ecx)
       rx_table[num].status &= ~E1000_RXD_STAT_DD;
       rx_table[num].status &= ~E1000_RXD_STAT_EOP;
f01080aa:	80 64 02 0c fc       	andb   $0xfc,0xc(%edx,%eax,1)
       *rdt = num;
f01080af:	a1 28 50 2d f0       	mov    0xf02d5028,%eax
f01080b4:	89 18                	mov    %ebx,(%eax)
f01080b6:	b8 00 00 00 00       	mov    $0x0,%eax
       //cprintf("length:%d\n",rx_table[num].length);
       return 0;
    }
    return -1;
}
f01080bb:	83 c4 10             	add    $0x10,%esp
f01080be:	5b                   	pop    %ebx
f01080bf:	5e                   	pop    %esi
f01080c0:	5d                   	pop    %ebp
f01080c1:	c3                   	ret    

f01080c2 <transmit_packet>:
    return 0;
}



int transmit_packet(struct tx_desc* td){
f01080c2:	55                   	push   %ebp
f01080c3:	89 e5                	mov    %esp,%ebp
f01080c5:	53                   	push   %ebx
f01080c6:	83 ec 14             	sub    $0x14,%esp
f01080c9:	8b 55 08             	mov    0x8(%ebp),%edx
   struct tx_desc* begin = &tx_table[*tdt];
f01080cc:	8b 0d 24 50 2d f0    	mov    0xf02d5024,%ecx
f01080d2:	8b 01                	mov    (%ecx),%eax
f01080d4:	c1 e0 04             	shl    $0x4,%eax
f01080d7:	05 40 50 2d f0       	add    $0xf02d5040,%eax
   if(!(begin->status & E1000_TXD_STAT_DD)){
f01080dc:	f6 40 0c 01          	testb  $0x1,0xc(%eax)
f01080e0:	75 13                	jne    f01080f5 <transmit_packet+0x33>
       cprintf("transmit queue is full\n");
f01080e2:	c7 04 24 f7 aa 10 f0 	movl   $0xf010aaf7,(%esp)
f01080e9:	e8 21 cb ff ff       	call   f0104c0f <cprintf>
f01080ee:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
       return -1;
f01080f3:	eb 29                	jmp    f010811e <transmit_packet+0x5c>
   }
   *begin = *td;
f01080f5:	8b 1a                	mov    (%edx),%ebx
f01080f7:	89 18                	mov    %ebx,(%eax)
f01080f9:	8b 5a 04             	mov    0x4(%edx),%ebx
f01080fc:	89 58 04             	mov    %ebx,0x4(%eax)
f01080ff:	8b 5a 08             	mov    0x8(%edx),%ebx
f0108102:	89 58 08             	mov    %ebx,0x8(%eax)
f0108105:	8b 52 0c             	mov    0xc(%edx),%edx
f0108108:	89 50 0c             	mov    %edx,0xc(%eax)
   begin->cmd |= E1000_TXD_CMD_RS >> 24;
   begin->cmd |= E1000_TXD_CMD_EOP>> 24;
f010810b:	80 48 0b 09          	orb    $0x9,0xb(%eax)
   *tdt = (*tdt + 1) % TXDESC_LENGTH;
f010810f:	8b 01                	mov    (%ecx),%eax
f0108111:	83 c0 01             	add    $0x1,%eax
f0108114:	83 e0 3f             	and    $0x3f,%eax
f0108117:	89 01                	mov    %eax,(%ecx)
f0108119:	b8 00 00 00 00       	mov    $0x0,%eax
   /*int i;
   for(i = 0; i<begin->length;i++)
       cprintf("%x ",*((char*)((uint32_t)begin->addr) + i));
   cprintf("%d\n",begin->cmd);*/
   return 0;
}
f010811e:	83 c4 14             	add    $0x14,%esp
f0108121:	5b                   	pop    %ebx
f0108122:	5d                   	pop    %ebp
f0108123:	c3                   	ret    

f0108124 <pci_e1000_attach>:
        rx_table[i].buffer_addr = PADDR(rx_buf[i].buf);
     return 0;
}

int pci_e1000_attach(struct pci_func *pcif)
{
f0108124:	55                   	push   %ebp
f0108125:	89 e5                	mov    %esp,%ebp
f0108127:	53                   	push   %ebx
f0108128:	83 ec 24             	sub    $0x24,%esp
f010812b:	8b 5d 08             	mov    0x8(%ebp),%ebx
    pci_func_enable(pcif);
f010812e:	89 1c 24             	mov    %ebx,(%esp)
f0108131:	e8 a8 07 00 00       	call   f01088de <pci_func_enable>
    base = e1000_map_region(pcif->reg_base[0],pcif->reg_size[0]);
f0108136:	8b 43 2c             	mov    0x2c(%ebx),%eax
f0108139:	89 44 24 04          	mov    %eax,0x4(%esp)
f010813d:	8b 43 14             	mov    0x14(%ebx),%eax
f0108140:	89 04 24             	mov    %eax,(%esp)
f0108143:	e8 f0 a3 ff ff       	call   f0102538 <e1000_map_region>
f0108148:	a3 c0 3e 29 f0       	mov    %eax,0xf0293ec0
struct rx_desc rx_table[RXDESC_LENGTH];
struct rcvbuf rx_buf[RXDESC_LENGTH];

static int init_table(){
     int i;
     memset(tx_table,0,sizeof(struct tx_desc)*TXDESC_LENGTH);
f010814d:	c7 44 24 08 00 04 00 	movl   $0x400,0x8(%esp)
f0108154:	00 
f0108155:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010815c:	00 
f010815d:	c7 04 24 40 50 2d f0 	movl   $0xf02d5040,(%esp)
f0108164:	e8 8d f3 ff ff       	call   f01074f6 <memset>
f0108169:	b8 00 00 00 00       	mov    $0x0,%eax
     for(i = 0; i<TXDESC_LENGTH;i++)
        tx_table[i].status |= E1000_TXD_STAT_DD;
f010816e:	ba 4c 50 2d f0       	mov    $0xf02d504c,%edx
f0108173:	80 0c 02 01          	orb    $0x1,(%edx,%eax,1)
f0108177:	83 c0 10             	add    $0x10,%eax
struct rcvbuf rx_buf[RXDESC_LENGTH];

static int init_table(){
     int i;
     memset(tx_table,0,sizeof(struct tx_desc)*TXDESC_LENGTH);
     for(i = 0; i<TXDESC_LENGTH;i++)
f010817a:	3d 00 04 00 00       	cmp    $0x400,%eax
f010817f:	75 f2                	jne    f0108173 <pci_e1000_attach+0x4f>
        tx_table[i].status |= E1000_TXD_STAT_DD;
     memset(rx_table,0,sizeof(struct rx_desc)*RXDESC_LENGTH);
f0108181:	c7 44 24 08 00 04 00 	movl   $0x400,0x8(%esp)
f0108188:	00 
f0108189:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0108190:	00 
f0108191:	c7 04 24 60 54 2f f0 	movl   $0xf02f5460,(%esp)
f0108198:	e8 59 f3 ff ff       	call   f01074f6 <memset>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010819d:	ba 60 54 2d f0       	mov    $0xf02d5460,%edx
f01081a2:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f01081a8:	0f 87 16 02 00 00    	ja     f01083c4 <pci_e1000_attach+0x2a0>
f01081ae:	eb 15                	jmp    f01081c5 <pci_e1000_attach+0xa1>
     for(i = 0; i<RXDESC_LENGTH;i++)
        rx_table[i].buffer_addr = PADDR(rx_buf[i].buf);
f01081b0:	89 c2                	mov    %eax,%edx
f01081b2:	c1 e2 0b             	shl    $0xb,%edx
f01081b5:	81 c2 60 54 2d f0    	add    $0xf02d5460,%edx
f01081bb:	89 d3                	mov    %edx,%ebx
f01081bd:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f01081c3:	77 20                	ja     f01081e5 <pci_e1000_attach+0xc1>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01081c5:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01081c9:	c7 44 24 08 9c 8d 10 	movl   $0xf0108d9c,0x8(%esp)
f01081d0:	f0 
f01081d1:	c7 44 24 04 16 00 00 	movl   $0x16,0x4(%esp)
f01081d8:	00 
f01081d9:	c7 04 24 0f ab 10 f0 	movl   $0xf010ab0f,(%esp)
f01081e0:	e8 a0 7e ff ff       	call   f0100085 <_panic>
f01081e5:	89 c2                	mov    %eax,%edx
f01081e7:	c1 e2 04             	shl    $0x4,%edx
f01081ea:	81 c3 00 00 00 10    	add    $0x10000000,%ebx
f01081f0:	89 1c 11             	mov    %ebx,(%ecx,%edx,1)
f01081f3:	c7 44 11 04 00 00 00 	movl   $0x0,0x4(%ecx,%edx,1)
f01081fa:	00 
     int i;
     memset(tx_table,0,sizeof(struct tx_desc)*TXDESC_LENGTH);
     for(i = 0; i<TXDESC_LENGTH;i++)
        tx_table[i].status |= E1000_TXD_STAT_DD;
     memset(rx_table,0,sizeof(struct rx_desc)*RXDESC_LENGTH);
     for(i = 0; i<RXDESC_LENGTH;i++)
f01081fb:	83 c0 01             	add    $0x1,%eax
f01081fe:	83 f8 40             	cmp    $0x40,%eax
f0108201:	75 ad                	jne    f01081b0 <pci_e1000_attach+0x8c>
{
    pci_func_enable(pcif);
    base = e1000_map_region(pcif->reg_base[0],pcif->reg_size[0]);
    //cprintf("test:%08x\n",*(uint32_t*)E1000_REG(base,0x00008));
    init_table();
    uintptr_t tdbal = E1000_REG(base,E1000_TDBAL);
f0108203:	8b 15 c0 3e 29 f0    	mov    0xf0293ec0,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0108209:	b8 40 50 2d f0       	mov    $0xf02d5040,%eax
f010820e:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0108213:	77 20                	ja     f0108235 <pci_e1000_attach+0x111>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0108215:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0108219:	c7 44 24 08 9c 8d 10 	movl   $0xf0108d9c,0x8(%esp)
f0108220:	f0 
f0108221:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
f0108228:	00 
f0108229:	c7 04 24 0f ab 10 f0 	movl   $0xf010ab0f,(%esp)
f0108230:	e8 50 7e ff ff       	call   f0100085 <_panic>
    *(uint32_t*)tdbal = PADDR(tx_table);
f0108235:	05 00 00 00 10       	add    $0x10000000,%eax
f010823a:	89 82 00 38 00 00    	mov    %eax,0x3800(%edx)
    uintptr_t tdbah = E1000_REG(base,E1000_TDBAH);
    *(uint32_t*)tdbah = 0;
f0108240:	a1 c0 3e 29 f0       	mov    0xf0293ec0,%eax
f0108245:	c7 80 04 38 00 00 00 	movl   $0x0,0x3804(%eax)
f010824c:	00 00 00 
    uintptr_t tdlen = E1000_REG(base,E1000_TDLEN);
    *(uint32_t*)tdlen = sizeof(struct tx_desc)*TXDESC_LENGTH;
f010824f:	a1 c0 3e 29 f0       	mov    0xf0293ec0,%eax
f0108254:	c7 80 08 38 00 00 00 	movl   $0x400,0x3808(%eax)
f010825b:	04 00 00 
    tdh = (uint32_t*)E1000_REG(base,E1000_TDH);
f010825e:	a1 c0 3e 29 f0       	mov    0xf0293ec0,%eax
f0108263:	05 10 38 00 00       	add    $0x3810,%eax
f0108268:	a3 20 50 2d f0       	mov    %eax,0xf02d5020
    *tdh = 0;
f010826d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    tdt = (uint32_t*)E1000_REG(base,E1000_TDT);
f0108273:	a1 c0 3e 29 f0       	mov    0xf0293ec0,%eax
f0108278:	05 18 38 00 00       	add    $0x3818,%eax
f010827d:	a3 24 50 2d f0       	mov    %eax,0xf02d5024
    *tdt = 0;
f0108282:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    uintptr_t tctl = E1000_REG(base,E1000_TCTL);
    uint32_t tmp = 0;
    tmp |= E1000_TCTL_EN;
    tmp |= E1000_TCTL_PSP;
    tmp |= 0x40 << 12;   //E1000_TCTL_COLD  = 0x003ff000
    *(uint32_t*)tctl = tmp;
f0108288:	a1 c0 3e 29 f0       	mov    0xf0293ec0,%eax
f010828d:	c7 80 00 04 00 00 0a 	movl   $0x4000a,0x400(%eax)
f0108294:	00 04 00 
    uintptr_t tipg = E1000_REG(base,E1000_TIPG);
    tmp = 0;
    tmp |= 10;
    tmp |= 4 << 10;
    tmp |= 6 << 20;
    *(uint32_t*)tipg = tmp;
f0108297:	a1 c0 3e 29 f0       	mov    0xf0293ec0,%eax
f010829c:	c7 80 10 04 00 00 0a 	movl   $0x60100a,0x410(%eax)
f01082a3:	10 60 00 
    /*struct tx_desc td;
    transmit_packet(&td);*/
    uintptr_t ral = E1000_REG(base,E1000_RA);
f01082a6:	8b 15 c0 3e 29 f0    	mov    0xf0293ec0,%edx
f01082ac:	8d 82 00 54 00 00    	lea    0x5400(%edx),%eax
    uintptr_t rah = ral + sizeof(uint32_t);

    /**(uint32_t*)ral = 0x12005452;
    *(uint32_t*)rah = 0x5634 | E1000_RAH_AV;*/
    volatile uintptr_t eerd = E1000_REG(base,E1000_EERD);
f01082b2:	83 c2 14             	add    $0x14,%edx
f01082b5:	89 55 f4             	mov    %edx,-0xc(%ebp)
    *(uint32_t*)eerd = 0x0 << E1000_EEPROM_RW_ADDR_SHIFT;
f01082b8:	8b 55 f4             	mov    -0xc(%ebp),%edx
f01082bb:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
    *(uint32_t*)eerd |= E1000_EEPROM_RW_REG_START;
f01082c1:	8b 55 f4             	mov    -0xc(%ebp),%edx
f01082c4:	83 0a 01             	orl    $0x1,(%edx)
    while(1){
         if((*(uint32_t*)eerd) & E1000_EEPROM_RW_REG_DONE)
f01082c7:	8b 55 f4             	mov    -0xc(%ebp),%edx
f01082ca:	f6 02 10             	testb  $0x10,(%edx)
f01082cd:	74 f8                	je     f01082c7 <pci_e1000_attach+0x1a3>
             break;
         
    }
    *(uint32_t*)ral = (*(uint32_t*)eerd) >> E1000_EEPROM_RW_REG_DATA;
f01082cf:	89 c2                	mov    %eax,%edx
f01082d1:	8b 4d f4             	mov    -0xc(%ebp),%ecx
f01082d4:	8b 09                	mov    (%ecx),%ecx
f01082d6:	c1 e9 10             	shr    $0x10,%ecx
f01082d9:	89 08                	mov    %ecx,(%eax)
    *(uint32_t*)eerd = 0x1 << E1000_EEPROM_RW_ADDR_SHIFT;
f01082db:	8b 4d f4             	mov    -0xc(%ebp),%ecx
f01082de:	c7 01 00 01 00 00    	movl   $0x100,(%ecx)
    *(uint32_t*)eerd |= E1000_EEPROM_RW_REG_START;
f01082e4:	8b 4d f4             	mov    -0xc(%ebp),%ecx
f01082e7:	83 09 01             	orl    $0x1,(%ecx)
     while(1){
         if((*(uint32_t*)eerd) & E1000_EEPROM_RW_REG_DONE)
f01082ea:	8b 4d f4             	mov    -0xc(%ebp),%ecx
f01082ed:	f6 01 10             	testb  $0x10,(%ecx)
f01082f0:	74 f8                	je     f01082ea <pci_e1000_attach+0x1c6>
             break;
         
    }
    *(uint32_t*)ral |= (*(uint32_t*)eerd) & 0xffff0000;
f01082f2:	8b 4d f4             	mov    -0xc(%ebp),%ecx
f01082f5:	8b 09                	mov    (%ecx),%ecx
f01082f7:	66 b9 00 00          	mov    $0x0,%cx
f01082fb:	09 0a                	or     %ecx,(%edx)
    *(uint32_t*)eerd = 0x2 << E1000_EEPROM_RW_ADDR_SHIFT;
f01082fd:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0108300:	c7 02 00 02 00 00    	movl   $0x200,(%edx)
    *(uint32_t*)eerd |= E1000_EEPROM_RW_REG_START;
f0108306:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0108309:	83 0a 01             	orl    $0x1,(%edx)
     while(1){
         if((*(uint32_t*)eerd) & E1000_EEPROM_RW_REG_DONE)
f010830c:	8b 55 f4             	mov    -0xc(%ebp),%edx
f010830f:	f6 02 10             	testb  $0x10,(%edx)
f0108312:	74 f8                	je     f010830c <pci_e1000_attach+0x1e8>
             break;
         
    }
    *(uint32_t*)rah = (*(uint32_t*)eerd) >> E1000_EEPROM_RW_REG_DATA;
f0108314:	8b 55 f4             	mov    -0xc(%ebp),%edx
    *(uint32_t*)rah |= E1000_RAH_AV;
f0108317:	8b 12                	mov    (%edx),%edx
f0108319:	c1 ea 10             	shr    $0x10,%edx
f010831c:	81 ca 00 00 00 80    	or     $0x80000000,%edx
f0108322:	89 50 04             	mov    %edx,0x4(%eax)
    //cprintf("rah:%08x\n",*(uint32_t*)rah);
    //cprintf("ral:%08x\n",*(uint32_t*)ral);

    uintptr_t rdbal = E1000_REG(base,E1000_RDBAL);
f0108325:	8b 15 c0 3e 29 f0    	mov    0xf0293ec0,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010832b:	b8 60 54 2f f0       	mov    $0xf02f5460,%eax
f0108330:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0108335:	77 20                	ja     f0108357 <pci_e1000_attach+0x233>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0108337:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010833b:	c7 44 24 08 9c 8d 10 	movl   $0xf0108d9c,0x8(%esp)
f0108342:	f0 
f0108343:	c7 44 24 04 5b 00 00 	movl   $0x5b,0x4(%esp)
f010834a:	00 
f010834b:	c7 04 24 0f ab 10 f0 	movl   $0xf010ab0f,(%esp)
f0108352:	e8 2e 7d ff ff       	call   f0100085 <_panic>
    *(uint32_t*)rdbal = PADDR(rx_table);
f0108357:	05 00 00 00 10       	add    $0x10000000,%eax
f010835c:	89 82 00 28 00 00    	mov    %eax,0x2800(%edx)
    uintptr_t rdbah = E1000_REG(base,E1000_RDBAH);
    *(uint32_t*)rdbah = 0;
f0108362:	a1 c0 3e 29 f0       	mov    0xf0293ec0,%eax
f0108367:	c7 80 04 28 00 00 00 	movl   $0x0,0x2804(%eax)
f010836e:	00 00 00 
    uintptr_t rdlen = E1000_REG(base,E1000_RDLEN);
    *(uint32_t*)rdlen = sizeof(struct rx_desc)*RXDESC_LENGTH;
f0108371:	a1 c0 3e 29 f0       	mov    0xf0293ec0,%eax
f0108376:	c7 80 08 28 00 00 00 	movl   $0x400,0x2808(%eax)
f010837d:	04 00 00 
    rdh = (uint32_t*)E1000_REG(base,E1000_RDH);
f0108380:	a1 c0 3e 29 f0       	mov    0xf0293ec0,%eax
f0108385:	05 10 28 00 00       	add    $0x2810,%eax
f010838a:	a3 40 54 2d f0       	mov    %eax,0xf02d5440
    *(uint32_t*)rdh = 0;
f010838f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    rdt = (uint32_t*)E1000_REG(base,E1000_RDT);
f0108395:	a1 c0 3e 29 f0       	mov    0xf0293ec0,%eax
f010839a:	05 18 28 00 00       	add    $0x2818,%eax
f010839f:	a3 28 50 2d f0       	mov    %eax,0xf02d5028
    *(uint32_t*)rdt = RXDESC_LENGTH - 1;
f01083a4:	c7 00 3f 00 00 00    	movl   $0x3f,(%eax)
    tmp = 0;
    tmp |= E1000_RCTL_EN;
    tmp |= E1000_RCTL_BAM;
    tmp |= E1000_RCTL_SZ_2048;
    tmp |= E1000_RCTL_SECRC;
    *(uint32_t*)rctl = tmp;
f01083aa:	a1 c0 3e 29 f0       	mov    0xf0293ec0,%eax
f01083af:	c7 80 00 01 00 00 02 	movl   $0x4008002,0x100(%eax)
f01083b6:	80 00 04 
       
    return 0;
}
f01083b9:	b8 00 00 00 00       	mov    $0x0,%eax
f01083be:	83 c4 24             	add    $0x24,%esp
f01083c1:	5b                   	pop    %ebx
f01083c2:	5d                   	pop    %ebp
f01083c3:	c3                   	ret    
     memset(tx_table,0,sizeof(struct tx_desc)*TXDESC_LENGTH);
     for(i = 0; i<TXDESC_LENGTH;i++)
        tx_table[i].status |= E1000_TXD_STAT_DD;
     memset(rx_table,0,sizeof(struct rx_desc)*RXDESC_LENGTH);
     for(i = 0; i<RXDESC_LENGTH;i++)
        rx_table[i].buffer_addr = PADDR(rx_buf[i].buf);
f01083c4:	b8 60 54 2f f0       	mov    $0xf02f5460,%eax
f01083c9:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f01083cf:	89 10                	mov    %edx,(%eax)
f01083d1:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
f01083d8:	b8 01 00 00 00       	mov    $0x1,%eax
f01083dd:	b9 60 54 2f f0       	mov    $0xf02f5460,%ecx
f01083e2:	e9 c9 fd ff ff       	jmp    f01081b0 <pci_e1000_attach+0x8c>
	...

f01083f0 <pci_attach_match>:
}

static int __attribute__((warn_unused_result))
pci_attach_match(uint32_t key1, uint32_t key2,
		 struct pci_driver *list, struct pci_func *pcif)
{
f01083f0:	55                   	push   %ebp
f01083f1:	89 e5                	mov    %esp,%ebp
f01083f3:	57                   	push   %edi
f01083f4:	56                   	push   %esi
f01083f5:	53                   	push   %ebx
f01083f6:	83 ec 3c             	sub    $0x3c,%esp
f01083f9:	89 c7                	mov    %eax,%edi
f01083fb:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01083fe:	89 ce                	mov    %ecx,%esi
	uint32_t i;

	for (i = 0; list[i].attachfn; i++) {
f0108400:	8b 41 08             	mov    0x8(%ecx),%eax
f0108403:	85 c0                	test   %eax,%eax
f0108405:	74 4d                	je     f0108454 <pci_attach_match+0x64>
f0108407:	8d 59 0c             	lea    0xc(%ecx),%ebx
		if (list[i].key1 == key1 && list[i].key2 == key2) {
f010840a:	39 3e                	cmp    %edi,(%esi)
f010840c:	75 3a                	jne    f0108448 <pci_attach_match+0x58>
f010840e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0108411:	39 56 04             	cmp    %edx,0x4(%esi)
f0108414:	75 32                	jne    f0108448 <pci_attach_match+0x58>
			int r = list[i].attachfn(pcif);
f0108416:	8b 55 08             	mov    0x8(%ebp),%edx
f0108419:	89 14 24             	mov    %edx,(%esp)
f010841c:	ff d0                	call   *%eax
			if (r > 0)
f010841e:	85 c0                	test   %eax,%eax
f0108420:	7f 37                	jg     f0108459 <pci_attach_match+0x69>
				return r;
			if (r < 0)
f0108422:	85 c0                	test   %eax,%eax
f0108424:	79 22                	jns    f0108448 <pci_attach_match+0x58>
				cprintf("pci_attach_match: attaching "
f0108426:	89 44 24 10          	mov    %eax,0x10(%esp)
f010842a:	8b 46 08             	mov    0x8(%esi),%eax
f010842d:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0108431:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0108434:	89 44 24 08          	mov    %eax,0x8(%esp)
f0108438:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010843c:	c7 04 24 1c ab 10 f0 	movl   $0xf010ab1c,(%esp)
f0108443:	e8 c7 c7 ff ff       	call   f0104c0f <cprintf>
f0108448:	89 de                	mov    %ebx,%esi
pci_attach_match(uint32_t key1, uint32_t key2,
		 struct pci_driver *list, struct pci_func *pcif)
{
	uint32_t i;

	for (i = 0; list[i].attachfn; i++) {
f010844a:	8b 43 08             	mov    0x8(%ebx),%eax
f010844d:	83 c3 0c             	add    $0xc,%ebx
f0108450:	85 c0                	test   %eax,%eax
f0108452:	75 b6                	jne    f010840a <pci_attach_match+0x1a>
f0108454:	b8 00 00 00 00       	mov    $0x0,%eax
					"%x.%x (%p): e\n",
					key1, key2, list[i].attachfn, r);
		}
	}
	return 0;
}
f0108459:	83 c4 3c             	add    $0x3c,%esp
f010845c:	5b                   	pop    %ebx
f010845d:	5e                   	pop    %esi
f010845e:	5f                   	pop    %edi
f010845f:	5d                   	pop    %ebp
f0108460:	c3                   	ret    

f0108461 <pci_conf1_set_addr>:
static void
pci_conf1_set_addr(uint32_t bus,
		   uint32_t dev,
		   uint32_t func,
		   uint32_t offset)
{
f0108461:	55                   	push   %ebp
f0108462:	89 e5                	mov    %esp,%ebp
f0108464:	53                   	push   %ebx
f0108465:	83 ec 14             	sub    $0x14,%esp
f0108468:	8b 5d 08             	mov    0x8(%ebp),%ebx
	assert(bus < 256);
f010846b:	3d ff 00 00 00       	cmp    $0xff,%eax
f0108470:	76 24                	jbe    f0108496 <pci_conf1_set_addr+0x35>
f0108472:	c7 44 24 0c 74 ac 10 	movl   $0xf010ac74,0xc(%esp)
f0108479:	f0 
f010847a:	c7 44 24 08 8c 95 10 	movl   $0xf010958c,0x8(%esp)
f0108481:	f0 
f0108482:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
f0108489:	00 
f010848a:	c7 04 24 7e ac 10 f0 	movl   $0xf010ac7e,(%esp)
f0108491:	e8 ef 7b ff ff       	call   f0100085 <_panic>
	assert(dev < 32);
f0108496:	83 fa 1f             	cmp    $0x1f,%edx
f0108499:	76 24                	jbe    f01084bf <pci_conf1_set_addr+0x5e>
f010849b:	c7 44 24 0c 89 ac 10 	movl   $0xf010ac89,0xc(%esp)
f01084a2:	f0 
f01084a3:	c7 44 24 08 8c 95 10 	movl   $0xf010958c,0x8(%esp)
f01084aa:	f0 
f01084ab:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
f01084b2:	00 
f01084b3:	c7 04 24 7e ac 10 f0 	movl   $0xf010ac7e,(%esp)
f01084ba:	e8 c6 7b ff ff       	call   f0100085 <_panic>
	assert(func < 8);
f01084bf:	83 f9 07             	cmp    $0x7,%ecx
f01084c2:	76 24                	jbe    f01084e8 <pci_conf1_set_addr+0x87>
f01084c4:	c7 44 24 0c 92 ac 10 	movl   $0xf010ac92,0xc(%esp)
f01084cb:	f0 
f01084cc:	c7 44 24 08 8c 95 10 	movl   $0xf010958c,0x8(%esp)
f01084d3:	f0 
f01084d4:	c7 44 24 04 2d 00 00 	movl   $0x2d,0x4(%esp)
f01084db:	00 
f01084dc:	c7 04 24 7e ac 10 f0 	movl   $0xf010ac7e,(%esp)
f01084e3:	e8 9d 7b ff ff       	call   f0100085 <_panic>
	assert(offset < 256);
f01084e8:	81 fb ff 00 00 00    	cmp    $0xff,%ebx
f01084ee:	76 24                	jbe    f0108514 <pci_conf1_set_addr+0xb3>
f01084f0:	c7 44 24 0c 9b ac 10 	movl   $0xf010ac9b,0xc(%esp)
f01084f7:	f0 
f01084f8:	c7 44 24 08 8c 95 10 	movl   $0xf010958c,0x8(%esp)
f01084ff:	f0 
f0108500:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
f0108507:	00 
f0108508:	c7 04 24 7e ac 10 f0 	movl   $0xf010ac7e,(%esp)
f010850f:	e8 71 7b ff ff       	call   f0100085 <_panic>
	assert((offset & 0x3) == 0);
f0108514:	f6 c3 03             	test   $0x3,%bl
f0108517:	74 24                	je     f010853d <pci_conf1_set_addr+0xdc>
f0108519:	c7 44 24 0c a8 ac 10 	movl   $0xf010aca8,0xc(%esp)
f0108520:	f0 
f0108521:	c7 44 24 08 8c 95 10 	movl   $0xf010958c,0x8(%esp)
f0108528:	f0 
f0108529:	c7 44 24 04 2f 00 00 	movl   $0x2f,0x4(%esp)
f0108530:	00 
f0108531:	c7 04 24 7e ac 10 f0 	movl   $0xf010ac7e,(%esp)
f0108538:	e8 48 7b ff ff       	call   f0100085 <_panic>
}

static __inline void
outl(int port, uint32_t data)
{
	__asm __volatile("outl %0,%w1" : : "a" (data), "d" (port));
f010853d:	c1 e0 10             	shl    $0x10,%eax
f0108540:	0d 00 00 00 80       	or     $0x80000000,%eax
f0108545:	c1 e2 0b             	shl    $0xb,%edx
f0108548:	09 d0                	or     %edx,%eax
f010854a:	09 d8                	or     %ebx,%eax
f010854c:	c1 e1 08             	shl    $0x8,%ecx
f010854f:	09 c8                	or     %ecx,%eax
f0108551:	ba f8 0c 00 00       	mov    $0xcf8,%edx
f0108556:	ef                   	out    %eax,(%dx)

	uint32_t v = (1 << 31) |		// config-space
		(bus << 16) | (dev << 11) | (func << 8) | (offset);
	outl(pci_conf1_addr_ioport, v);
}
f0108557:	83 c4 14             	add    $0x14,%esp
f010855a:	5b                   	pop    %ebx
f010855b:	5d                   	pop    %ebp
f010855c:	c3                   	ret    

f010855d <pci_conf_read>:

static uint32_t
pci_conf_read(struct pci_func *f, uint32_t off)
{
f010855d:	55                   	push   %ebp
f010855e:	89 e5                	mov    %esp,%ebp
f0108560:	53                   	push   %ebx
f0108561:	83 ec 14             	sub    $0x14,%esp
f0108564:	89 d3                	mov    %edx,%ebx
	pci_conf1_set_addr(f->bus->busno, f->dev, f->func, off);
f0108566:	8b 48 08             	mov    0x8(%eax),%ecx
f0108569:	8b 50 04             	mov    0x4(%eax),%edx
f010856c:	8b 00                	mov    (%eax),%eax
f010856e:	8b 40 04             	mov    0x4(%eax),%eax
f0108571:	89 1c 24             	mov    %ebx,(%esp)
f0108574:	e8 e8 fe ff ff       	call   f0108461 <pci_conf1_set_addr>

static __inline uint32_t
inl(int port)
{
	uint32_t data;
	__asm __volatile("inl %w1,%0" : "=a" (data) : "d" (port));
f0108579:	ba fc 0c 00 00       	mov    $0xcfc,%edx
f010857e:	ed                   	in     (%dx),%eax
	return inl(pci_conf1_data_ioport);
}
f010857f:	83 c4 14             	add    $0x14,%esp
f0108582:	5b                   	pop    %ebx
f0108583:	5d                   	pop    %ebp
f0108584:	c3                   	ret    

f0108585 <pci_scan_bus>:
		f->irq_line);
}

static int
pci_scan_bus(struct pci_bus *bus)
{
f0108585:	55                   	push   %ebp
f0108586:	89 e5                	mov    %esp,%ebp
f0108588:	57                   	push   %edi
f0108589:	56                   	push   %esi
f010858a:	53                   	push   %ebx
f010858b:	81 ec 3c 01 00 00    	sub    $0x13c,%esp
f0108591:	89 c3                	mov    %eax,%ebx
	int totaldev = 0;
	struct pci_func df;
	memset(&df, 0, sizeof(df));
f0108593:	c7 44 24 08 48 00 00 	movl   $0x48,0x8(%esp)
f010859a:	00 
f010859b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01085a2:	00 
f01085a3:	8d 45 a0             	lea    -0x60(%ebp),%eax
f01085a6:	89 04 24             	mov    %eax,(%esp)
f01085a9:	e8 48 ef ff ff       	call   f01074f6 <memset>
	df.bus = bus;
f01085ae:	89 5d a0             	mov    %ebx,-0x60(%ebp)

	for (df.dev = 0; df.dev < 32; df.dev++) {
f01085b1:	c7 45 a4 00 00 00 00 	movl   $0x0,-0x5c(%ebp)
};

static void
pci_print_func(struct pci_func *f)
{
	const char *class = pci_class[0];
f01085b8:	c7 85 fc fe ff ff 00 	movl   $0x0,-0x104(%ebp)
f01085bf:	00 00 00 
	struct pci_func df;
	memset(&df, 0, sizeof(df));
	df.bus = bus;

	for (df.dev = 0; df.dev < 32; df.dev++) {
		uint32_t bhlc = pci_conf_read(&df, PCI_BHLC_REG);
f01085c2:	8d 45 a0             	lea    -0x60(%ebp),%eax
f01085c5:	89 85 f0 fe ff ff    	mov    %eax,-0x110(%ebp)
		if (PCI_HDRTYPE_TYPE(bhlc) > 1)	    // Unsupported or no device
			continue;

		totaldev++;

		struct pci_func f = df;
f01085cb:	8d 8d 58 ff ff ff    	lea    -0xa8(%ebp),%ecx
f01085d1:	89 8d f4 fe ff ff    	mov    %ecx,-0x10c(%ebp)
		for (f.func = 0; f.func < (PCI_HDRTYPE_MULTIFN(bhlc) ? 8 : 1);
		     f.func++) {
			struct pci_func af = f;
f01085d7:	8d 85 10 ff ff ff    	lea    -0xf0(%ebp),%eax
f01085dd:	89 85 ec fe ff ff    	mov    %eax,-0x114(%ebp)
f01085e3:	89 8d 00 ff ff ff    	mov    %ecx,-0x100(%ebp)
f01085e9:	89 85 04 ff ff ff    	mov    %eax,-0xfc(%ebp)
	struct pci_func df;
	memset(&df, 0, sizeof(df));
	df.bus = bus;

	for (df.dev = 0; df.dev < 32; df.dev++) {
		uint32_t bhlc = pci_conf_read(&df, PCI_BHLC_REG);
f01085ef:	ba 0c 00 00 00       	mov    $0xc,%edx
f01085f4:	8d 45 a0             	lea    -0x60(%ebp),%eax
f01085f7:	e8 61 ff ff ff       	call   f010855d <pci_conf_read>
		if (PCI_HDRTYPE_TYPE(bhlc) > 1)	    // Unsupported or no device
f01085fc:	89 c2                	mov    %eax,%edx
f01085fe:	c1 ea 10             	shr    $0x10,%edx
f0108601:	83 e2 7f             	and    $0x7f,%edx
f0108604:	83 fa 01             	cmp    $0x1,%edx
f0108607:	0f 87 77 01 00 00    	ja     f0108784 <pci_scan_bus+0x1ff>
			continue;

		totaldev++;

		struct pci_func f = df;
f010860d:	b9 12 00 00 00       	mov    $0x12,%ecx
f0108612:	8b bd f4 fe ff ff    	mov    -0x10c(%ebp),%edi
f0108618:	8b b5 f0 fe ff ff    	mov    -0x110(%ebp),%esi
f010861e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		for (f.func = 0; f.func < (PCI_HDRTYPE_MULTIFN(bhlc) ? 8 : 1);
f0108620:	c7 85 60 ff ff ff 00 	movl   $0x0,-0xa0(%ebp)
f0108627:	00 00 00 
f010862a:	89 c3                	mov    %eax,%ebx
f010862c:	81 e3 00 00 80 00    	and    $0x800000,%ebx
f0108632:	e9 2f 01 00 00       	jmp    f0108766 <pci_scan_bus+0x1e1>
		     f.func++) {
			struct pci_func af = f;
f0108637:	8b bd ec fe ff ff    	mov    -0x114(%ebp),%edi
f010863d:	8b b5 f4 fe ff ff    	mov    -0x10c(%ebp),%esi
f0108643:	b9 12 00 00 00       	mov    $0x12,%ecx
f0108648:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

			af.dev_id = pci_conf_read(&f, PCI_ID_REG);
f010864a:	ba 00 00 00 00       	mov    $0x0,%edx
f010864f:	8b 85 00 ff ff ff    	mov    -0x100(%ebp),%eax
f0108655:	e8 03 ff ff ff       	call   f010855d <pci_conf_read>
f010865a:	89 85 1c ff ff ff    	mov    %eax,-0xe4(%ebp)
			if (PCI_VENDOR(af.dev_id) == 0xffff)
f0108660:	66 83 f8 ff          	cmp    $0xffffffff,%ax
f0108664:	0f 84 f5 00 00 00    	je     f010875f <pci_scan_bus+0x1da>
				continue;

			uint32_t intr = pci_conf_read(&af, PCI_INTERRUPT_REG);
f010866a:	ba 3c 00 00 00       	mov    $0x3c,%edx
f010866f:	8b 85 04 ff ff ff    	mov    -0xfc(%ebp),%eax
f0108675:	e8 e3 fe ff ff       	call   f010855d <pci_conf_read>
			af.irq_line = PCI_INTERRUPT_LINE(intr);
f010867a:	88 85 54 ff ff ff    	mov    %al,-0xac(%ebp)

			af.dev_class = pci_conf_read(&af, PCI_CLASS_REG);
f0108680:	ba 08 00 00 00       	mov    $0x8,%edx
f0108685:	8b 85 04 ff ff ff    	mov    -0xfc(%ebp),%eax
f010868b:	e8 cd fe ff ff       	call   f010855d <pci_conf_read>
f0108690:	89 85 20 ff ff ff    	mov    %eax,-0xe0(%ebp)

static void
pci_print_func(struct pci_func *f)
{
	const char *class = pci_class[0];
	if (PCI_CLASS(f->dev_class) < sizeof(pci_class) / sizeof(pci_class[0]))
f0108696:	89 c2                	mov    %eax,%edx
f0108698:	c1 ea 18             	shr    $0x18,%edx
f010869b:	b9 bc ac 10 f0       	mov    $0xf010acbc,%ecx
f01086a0:	83 fa 06             	cmp    $0x6,%edx
f01086a3:	77 07                	ja     f01086ac <pci_scan_bus+0x127>
		class = pci_class[PCI_CLASS(f->dev_class)];
f01086a5:	8b 0c 95 30 ad 10 f0 	mov    -0xfef52d0(,%edx,4),%ecx

	cprintf("PCI: %02x:%02x.%d: %04x:%04x: class: %x.%x (%s) irq: %d\n",
		f->bus->busno, f->dev, f->func,
		PCI_VENDOR(f->dev_id), PCI_PRODUCT(f->dev_id),
f01086ac:	8b bd 1c ff ff ff    	mov    -0xe4(%ebp),%edi
{
	const char *class = pci_class[0];
	if (PCI_CLASS(f->dev_class) < sizeof(pci_class) / sizeof(pci_class[0]))
		class = pci_class[PCI_CLASS(f->dev_class)];

	cprintf("PCI: %02x:%02x.%d: %04x:%04x: class: %x.%x (%s) irq: %d\n",
f01086b2:	0f b6 b5 54 ff ff ff 	movzbl -0xac(%ebp),%esi
f01086b9:	89 74 24 24          	mov    %esi,0x24(%esp)
f01086bd:	89 4c 24 20          	mov    %ecx,0x20(%esp)
f01086c1:	c1 e8 10             	shr    $0x10,%eax
f01086c4:	25 ff 00 00 00       	and    $0xff,%eax
f01086c9:	89 44 24 1c          	mov    %eax,0x1c(%esp)
f01086cd:	89 54 24 18          	mov    %edx,0x18(%esp)
f01086d1:	89 f8                	mov    %edi,%eax
f01086d3:	c1 e8 10             	shr    $0x10,%eax
f01086d6:	89 44 24 14          	mov    %eax,0x14(%esp)
f01086da:	81 e7 ff ff 00 00    	and    $0xffff,%edi
f01086e0:	89 7c 24 10          	mov    %edi,0x10(%esp)
f01086e4:	8b 85 18 ff ff ff    	mov    -0xe8(%ebp),%eax
f01086ea:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01086ee:	8b 85 14 ff ff ff    	mov    -0xec(%ebp),%eax
f01086f4:	89 44 24 08          	mov    %eax,0x8(%esp)
f01086f8:	8b 85 10 ff ff ff    	mov    -0xf0(%ebp),%eax
f01086fe:	8b 40 04             	mov    0x4(%eax),%eax
f0108701:	89 44 24 04          	mov    %eax,0x4(%esp)
f0108705:	c7 04 24 48 ab 10 f0 	movl   $0xf010ab48,(%esp)
f010870c:	e8 fe c4 ff ff       	call   f0104c0f <cprintf>
static int
pci_attach(struct pci_func *f)
{
	return
		pci_attach_match(PCI_CLASS(f->dev_class),
				 PCI_SUBCLASS(f->dev_class),
f0108711:	8b 85 20 ff ff ff    	mov    -0xe0(%ebp),%eax
				 &pci_attach_class[0], f) ||
f0108717:	89 c2                	mov    %eax,%edx
f0108719:	c1 ea 10             	shr    $0x10,%edx
f010871c:	81 e2 ff 00 00 00    	and    $0xff,%edx
f0108722:	c1 e8 18             	shr    $0x18,%eax
f0108725:	8b 8d 04 ff ff ff    	mov    -0xfc(%ebp),%ecx
f010872b:	89 0c 24             	mov    %ecx,(%esp)
f010872e:	b9 b4 83 12 f0       	mov    $0xf01283b4,%ecx
f0108733:	e8 b8 fc ff ff       	call   f01083f0 <pci_attach_match>

static int
pci_attach(struct pci_func *f)
{
	return
		pci_attach_match(PCI_CLASS(f->dev_class),
f0108738:	85 c0                	test   %eax,%eax
f010873a:	75 23                	jne    f010875f <pci_scan_bus+0x1da>
				 PCI_SUBCLASS(f->dev_class),
				 &pci_attach_class[0], f) ||
		pci_attach_match(PCI_VENDOR(f->dev_id),
				 PCI_PRODUCT(f->dev_id),
f010873c:	8b 85 1c ff ff ff    	mov    -0xe4(%ebp),%eax
				 &pci_attach_vendor[0], f);
f0108742:	89 c2                	mov    %eax,%edx
f0108744:	c1 ea 10             	shr    $0x10,%edx
f0108747:	25 ff ff 00 00       	and    $0xffff,%eax
f010874c:	8b 8d 04 ff ff ff    	mov    -0xfc(%ebp),%ecx
f0108752:	89 0c 24             	mov    %ecx,(%esp)
f0108755:	b9 cc 83 12 f0       	mov    $0xf01283cc,%ecx
f010875a:	e8 91 fc ff ff       	call   f01083f0 <pci_attach_match>

		totaldev++;

		struct pci_func f = df;
		for (f.func = 0; f.func < (PCI_HDRTYPE_MULTIFN(bhlc) ? 8 : 1);
		     f.func++) {
f010875f:	83 85 60 ff ff ff 01 	addl   $0x1,-0xa0(%ebp)
			continue;

		totaldev++;

		struct pci_func f = df;
		for (f.func = 0; f.func < (PCI_HDRTYPE_MULTIFN(bhlc) ? 8 : 1);
f0108766:	83 fb 01             	cmp    $0x1,%ebx
f0108769:	19 c0                	sbb    %eax,%eax
f010876b:	83 e0 f9             	and    $0xfffffff9,%eax
f010876e:	83 c0 08             	add    $0x8,%eax
f0108771:	3b 85 60 ff ff ff    	cmp    -0xa0(%ebp),%eax
f0108777:	0f 87 ba fe ff ff    	ja     f0108637 <pci_scan_bus+0xb2>
	for (df.dev = 0; df.dev < 32; df.dev++) {
		uint32_t bhlc = pci_conf_read(&df, PCI_BHLC_REG);
		if (PCI_HDRTYPE_TYPE(bhlc) > 1)	    // Unsupported or no device
			continue;

		totaldev++;
f010877d:	83 85 fc fe ff ff 01 	addl   $0x1,-0x104(%ebp)
	int totaldev = 0;
	struct pci_func df;
	memset(&df, 0, sizeof(df));
	df.bus = bus;

	for (df.dev = 0; df.dev < 32; df.dev++) {
f0108784:	8b 45 a4             	mov    -0x5c(%ebp),%eax
f0108787:	83 c0 01             	add    $0x1,%eax
f010878a:	83 f8 1f             	cmp    $0x1f,%eax
f010878d:	77 08                	ja     f0108797 <pci_scan_bus+0x212>
f010878f:	89 45 a4             	mov    %eax,-0x5c(%ebp)
f0108792:	e9 58 fe ff ff       	jmp    f01085ef <pci_scan_bus+0x6a>
			pci_attach(&af);
		}
	}

	return totaldev;
}
f0108797:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
f010879d:	81 c4 3c 01 00 00    	add    $0x13c,%esp
f01087a3:	5b                   	pop    %ebx
f01087a4:	5e                   	pop    %esi
f01087a5:	5f                   	pop    %edi
f01087a6:	5d                   	pop    %ebp
f01087a7:	c3                   	ret    

f01087a8 <pci_init>:
		PCI_VENDOR(f->dev_id), PCI_PRODUCT(f->dev_id));
}

int
pci_init(void)
{
f01087a8:	55                   	push   %ebp
f01087a9:	89 e5                	mov    %esp,%ebp
f01087ab:	83 ec 18             	sub    $0x18,%esp
	static struct pci_bus root_bus;
	memset(&root_bus, 0, sizeof(root_bus));
f01087ae:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
f01087b5:	00 
f01087b6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01087bd:	00 
f01087be:	c7 04 24 a0 3e 29 f0 	movl   $0xf0293ea0,(%esp)
f01087c5:	e8 2c ed ff ff       	call   f01074f6 <memset>

	return pci_scan_bus(&root_bus);
f01087ca:	b8 a0 3e 29 f0       	mov    $0xf0293ea0,%eax
f01087cf:	e8 b1 fd ff ff       	call   f0108585 <pci_scan_bus>
}
f01087d4:	c9                   	leave  
f01087d5:	c3                   	ret    

f01087d6 <pci_bridge_attach>:
	return totaldev;
}

static int
pci_bridge_attach(struct pci_func *pcif)
{
f01087d6:	55                   	push   %ebp
f01087d7:	89 e5                	mov    %esp,%ebp
f01087d9:	83 ec 48             	sub    $0x48,%esp
f01087dc:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f01087df:	89 75 f8             	mov    %esi,-0x8(%ebp)
f01087e2:	89 7d fc             	mov    %edi,-0x4(%ebp)
f01087e5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	uint32_t ioreg  = pci_conf_read(pcif, PCI_BRIDGE_STATIO_REG);
f01087e8:	ba 1c 00 00 00       	mov    $0x1c,%edx
f01087ed:	89 d8                	mov    %ebx,%eax
f01087ef:	e8 69 fd ff ff       	call   f010855d <pci_conf_read>
f01087f4:	89 c7                	mov    %eax,%edi
	uint32_t busreg = pci_conf_read(pcif, PCI_BRIDGE_BUS_REG);
f01087f6:	ba 18 00 00 00       	mov    $0x18,%edx
f01087fb:	89 d8                	mov    %ebx,%eax
f01087fd:	e8 5b fd ff ff       	call   f010855d <pci_conf_read>
f0108802:	89 c6                	mov    %eax,%esi

	if (PCI_BRIDGE_IO_32BITS(ioreg)) {
f0108804:	83 e7 0f             	and    $0xf,%edi
f0108807:	83 ff 01             	cmp    $0x1,%edi
f010880a:	75 2a                	jne    f0108836 <pci_bridge_attach+0x60>
		cprintf("PCI: %02x:%02x.%d: 32-bit bridge IO not supported.\n",
f010880c:	8b 43 08             	mov    0x8(%ebx),%eax
f010880f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0108813:	8b 43 04             	mov    0x4(%ebx),%eax
f0108816:	89 44 24 08          	mov    %eax,0x8(%esp)
f010881a:	8b 03                	mov    (%ebx),%eax
f010881c:	8b 40 04             	mov    0x4(%eax),%eax
f010881f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0108823:	c7 04 24 84 ab 10 f0 	movl   $0xf010ab84,(%esp)
f010882a:	e8 e0 c3 ff ff       	call   f0104c0f <cprintf>
f010882f:	b8 00 00 00 00       	mov    $0x0,%eax
			pcif->bus->busno, pcif->dev, pcif->func);
		return 0;
f0108834:	eb 66                	jmp    f010889c <pci_bridge_attach+0xc6>
	}

	struct pci_bus nbus;
	memset(&nbus, 0, sizeof(nbus));
f0108836:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
f010883d:	00 
f010883e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0108845:	00 
f0108846:	8d 7d e0             	lea    -0x20(%ebp),%edi
f0108849:	89 3c 24             	mov    %edi,(%esp)
f010884c:	e8 a5 ec ff ff       	call   f01074f6 <memset>
	nbus.parent_bridge = pcif;
f0108851:	89 5d e0             	mov    %ebx,-0x20(%ebp)
	nbus.busno = (busreg >> PCI_BRIDGE_BUS_SECONDARY_SHIFT) & 0xff;
f0108854:	89 f2                	mov    %esi,%edx
f0108856:	0f b6 c6             	movzbl %dh,%eax
f0108859:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	if (pci_show_devs)
		cprintf("PCI: %02x:%02x.%d: bridge to PCI bus %d--%d\n",
f010885c:	c1 ee 10             	shr    $0x10,%esi
f010885f:	81 e6 ff 00 00 00    	and    $0xff,%esi
f0108865:	89 74 24 14          	mov    %esi,0x14(%esp)
f0108869:	89 44 24 10          	mov    %eax,0x10(%esp)
f010886d:	8b 43 08             	mov    0x8(%ebx),%eax
f0108870:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0108874:	8b 43 04             	mov    0x4(%ebx),%eax
f0108877:	89 44 24 08          	mov    %eax,0x8(%esp)
f010887b:	8b 03                	mov    (%ebx),%eax
f010887d:	8b 40 04             	mov    0x4(%eax),%eax
f0108880:	89 44 24 04          	mov    %eax,0x4(%esp)
f0108884:	c7 04 24 b8 ab 10 f0 	movl   $0xf010abb8,(%esp)
f010888b:	e8 7f c3 ff ff       	call   f0104c0f <cprintf>
			pcif->bus->busno, pcif->dev, pcif->func,
			nbus.busno,
			(busreg >> PCI_BRIDGE_BUS_SUBORDINATE_SHIFT) & 0xff);

	pci_scan_bus(&nbus);
f0108890:	89 f8                	mov    %edi,%eax
f0108892:	e8 ee fc ff ff       	call   f0108585 <pci_scan_bus>
f0108897:	b8 01 00 00 00       	mov    $0x1,%eax
	return 1;
}
f010889c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f010889f:	8b 75 f8             	mov    -0x8(%ebp),%esi
f01088a2:	8b 7d fc             	mov    -0x4(%ebp),%edi
f01088a5:	89 ec                	mov    %ebp,%esp
f01088a7:	5d                   	pop    %ebp
f01088a8:	c3                   	ret    

f01088a9 <pci_conf_write>:
	return inl(pci_conf1_data_ioport);
}

static void
pci_conf_write(struct pci_func *f, uint32_t off, uint32_t v)
{
f01088a9:	55                   	push   %ebp
f01088aa:	89 e5                	mov    %esp,%ebp
f01088ac:	83 ec 18             	sub    $0x18,%esp
f01088af:	89 5d f8             	mov    %ebx,-0x8(%ebp)
f01088b2:	89 75 fc             	mov    %esi,-0x4(%ebp)
f01088b5:	89 d3                	mov    %edx,%ebx
f01088b7:	89 ce                	mov    %ecx,%esi
	pci_conf1_set_addr(f->bus->busno, f->dev, f->func, off);
f01088b9:	8b 48 08             	mov    0x8(%eax),%ecx
f01088bc:	8b 50 04             	mov    0x4(%eax),%edx
f01088bf:	8b 00                	mov    (%eax),%eax
f01088c1:	8b 40 04             	mov    0x4(%eax),%eax
f01088c4:	89 1c 24             	mov    %ebx,(%esp)
f01088c7:	e8 95 fb ff ff       	call   f0108461 <pci_conf1_set_addr>
}

static __inline void
outl(int port, uint32_t data)
{
	__asm __volatile("outl %0,%w1" : : "a" (data), "d" (port));
f01088cc:	ba fc 0c 00 00       	mov    $0xcfc,%edx
f01088d1:	89 f0                	mov    %esi,%eax
f01088d3:	ef                   	out    %eax,(%dx)
	outl(pci_conf1_data_ioport, v);
}
f01088d4:	8b 5d f8             	mov    -0x8(%ebp),%ebx
f01088d7:	8b 75 fc             	mov    -0x4(%ebp),%esi
f01088da:	89 ec                	mov    %ebp,%esp
f01088dc:	5d                   	pop    %ebp
f01088dd:	c3                   	ret    

f01088de <pci_func_enable>:

// External PCI subsystem interface

void
pci_func_enable(struct pci_func *f)
{
f01088de:	55                   	push   %ebp
f01088df:	89 e5                	mov    %esp,%ebp
f01088e1:	57                   	push   %edi
f01088e2:	56                   	push   %esi
f01088e3:	53                   	push   %ebx
f01088e4:	83 ec 4c             	sub    $0x4c,%esp
f01088e7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	pci_conf_write(f, PCI_COMMAND_STATUS_REG,
f01088ea:	b9 07 00 00 00       	mov    $0x7,%ecx
f01088ef:	ba 04 00 00 00       	mov    $0x4,%edx
f01088f4:	89 d8                	mov    %ebx,%eax
f01088f6:	e8 ae ff ff ff       	call   f01088a9 <pci_conf_write>
f01088fb:	be 10 00 00 00       	mov    $0x10,%esi
	uint32_t bar_width;
	uint32_t bar;
	for (bar = PCI_MAPREG_START; bar < PCI_MAPREG_END;
	     bar += bar_width)
	{
		uint32_t oldv = pci_conf_read(f, bar);
f0108900:	89 f2                	mov    %esi,%edx
f0108902:	89 d8                	mov    %ebx,%eax
f0108904:	e8 54 fc ff ff       	call   f010855d <pci_conf_read>
f0108909:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		bar_width = 4;
		pci_conf_write(f, bar, 0xffffffff);
f010890c:	b9 ff ff ff ff       	mov    $0xffffffff,%ecx
f0108911:	89 f2                	mov    %esi,%edx
f0108913:	89 d8                	mov    %ebx,%eax
f0108915:	e8 8f ff ff ff       	call   f01088a9 <pci_conf_write>
		uint32_t rv = pci_conf_read(f, bar);
f010891a:	89 f2                	mov    %esi,%edx
f010891c:	89 d8                	mov    %ebx,%eax
f010891e:	e8 3a fc ff ff       	call   f010855d <pci_conf_read>

		if (rv == 0)
f0108923:	bf 04 00 00 00       	mov    $0x4,%edi
f0108928:	85 c0                	test   %eax,%eax
f010892a:	0f 84 c4 00 00 00    	je     f01089f4 <pci_func_enable+0x116>
			continue;

		int regnum = PCI_MAPREG_NUM(bar);
f0108930:	8d 56 f0             	lea    -0x10(%esi),%edx
f0108933:	c1 ea 02             	shr    $0x2,%edx
f0108936:	89 55 e0             	mov    %edx,-0x20(%ebp)
		uint32_t base, size;
		if (PCI_MAPREG_TYPE(rv) == PCI_MAPREG_TYPE_MEM) {
f0108939:	a8 01                	test   $0x1,%al
f010893b:	75 2c                	jne    f0108969 <pci_func_enable+0x8b>
			if (PCI_MAPREG_MEM_TYPE(rv) == PCI_MAPREG_MEM_TYPE_64BIT)
f010893d:	89 c2                	mov    %eax,%edx
f010893f:	83 e2 06             	and    $0x6,%edx
f0108942:	83 fa 04             	cmp    $0x4,%edx
f0108945:	0f 94 c2             	sete   %dl
f0108948:	0f b6 fa             	movzbl %dl,%edi
f010894b:	8d 3c bd 04 00 00 00 	lea    0x4(,%edi,4),%edi
				bar_width = 8;

			size = PCI_MAPREG_MEM_SIZE(rv);
f0108952:	83 e0 f0             	and    $0xfffffff0,%eax
f0108955:	89 c2                	mov    %eax,%edx
f0108957:	f7 da                	neg    %edx
f0108959:	21 d0                	and    %edx,%eax
f010895b:	89 45 dc             	mov    %eax,-0x24(%ebp)
			base = PCI_MAPREG_MEM_ADDR(oldv);
f010895e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0108961:	83 e0 f0             	and    $0xfffffff0,%eax
f0108964:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0108967:	eb 1a                	jmp    f0108983 <pci_func_enable+0xa5>
			if (pci_show_addrs)
				cprintf("  mem region %d: %d bytes at 0x%x\n",
					regnum, size, base);
		} else {
			size = PCI_MAPREG_IO_SIZE(rv);
f0108969:	83 e0 fc             	and    $0xfffffffc,%eax
f010896c:	89 c2                	mov    %eax,%edx
f010896e:	f7 da                	neg    %edx
f0108970:	21 d0                	and    %edx,%eax
f0108972:	89 45 dc             	mov    %eax,-0x24(%ebp)
			base = PCI_MAPREG_IO_ADDR(oldv);
f0108975:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0108978:	83 e2 fc             	and    $0xfffffffc,%edx
f010897b:	89 55 d8             	mov    %edx,-0x28(%ebp)
f010897e:	bf 04 00 00 00       	mov    $0x4,%edi
			if (pci_show_addrs)
				cprintf("  io region %d: %d bytes at 0x%x\n",
					regnum, size, base);
		}

		pci_conf_write(f, bar, oldv);
f0108983:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0108986:	89 f2                	mov    %esi,%edx
f0108988:	89 d8                	mov    %ebx,%eax
f010898a:	e8 1a ff ff ff       	call   f01088a9 <pci_conf_write>
		f->reg_base[regnum] = base;
f010898f:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0108992:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0108995:	89 54 83 14          	mov    %edx,0x14(%ebx,%eax,4)
		f->reg_size[regnum] = size;
f0108999:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010899c:	89 54 83 2c          	mov    %edx,0x2c(%ebx,%eax,4)

		if (size && !base)
f01089a0:	85 d2                	test   %edx,%edx
f01089a2:	74 50                	je     f01089f4 <pci_func_enable+0x116>
f01089a4:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f01089a8:	75 4a                	jne    f01089f4 <pci_func_enable+0x116>
			cprintf("PCI device %02x:%02x.%d (%04x:%04x) "
				"may be misconfigured: "
				"region %d: base 0x%x, size %d\n",
				f->bus->busno, f->dev, f->func,
				PCI_VENDOR(f->dev_id), PCI_PRODUCT(f->dev_id),
f01089aa:	8b 43 0c             	mov    0xc(%ebx),%eax
		pci_conf_write(f, bar, oldv);
		f->reg_base[regnum] = base;
		f->reg_size[regnum] = size;

		if (size && !base)
			cprintf("PCI device %02x:%02x.%d (%04x:%04x) "
f01089ad:	89 54 24 20          	mov    %edx,0x20(%esp)
f01089b1:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01089b4:	89 54 24 1c          	mov    %edx,0x1c(%esp)
f01089b8:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01089bb:	89 54 24 18          	mov    %edx,0x18(%esp)
f01089bf:	89 c2                	mov    %eax,%edx
f01089c1:	c1 ea 10             	shr    $0x10,%edx
f01089c4:	89 54 24 14          	mov    %edx,0x14(%esp)
f01089c8:	25 ff ff 00 00       	and    $0xffff,%eax
f01089cd:	89 44 24 10          	mov    %eax,0x10(%esp)
f01089d1:	8b 43 08             	mov    0x8(%ebx),%eax
f01089d4:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01089d8:	8b 43 04             	mov    0x4(%ebx),%eax
f01089db:	89 44 24 08          	mov    %eax,0x8(%esp)
f01089df:	8b 03                	mov    (%ebx),%eax
f01089e1:	8b 40 04             	mov    0x4(%eax),%eax
f01089e4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01089e8:	c7 04 24 e8 ab 10 f0 	movl   $0xf010abe8,(%esp)
f01089ef:	e8 1b c2 ff ff       	call   f0104c0f <cprintf>
		       PCI_COMMAND_MASTER_ENABLE);

	uint32_t bar_width;
	uint32_t bar;
	for (bar = PCI_MAPREG_START; bar < PCI_MAPREG_END;
	     bar += bar_width)
f01089f4:	01 fe                	add    %edi,%esi
		       PCI_COMMAND_MEM_ENABLE |
		       PCI_COMMAND_MASTER_ENABLE);

	uint32_t bar_width;
	uint32_t bar;
	for (bar = PCI_MAPREG_START; bar < PCI_MAPREG_END;
f01089f6:	83 fe 27             	cmp    $0x27,%esi
f01089f9:	0f 86 01 ff ff ff    	jbe    f0108900 <pci_func_enable+0x22>
				regnum, base, size);
	}

	cprintf("PCI function %02x:%02x.%d (%04x:%04x) enabled\n",
		f->bus->busno, f->dev, f->func,
		PCI_VENDOR(f->dev_id), PCI_PRODUCT(f->dev_id));
f01089ff:	8b 43 0c             	mov    0xc(%ebx),%eax
				f->bus->busno, f->dev, f->func,
				PCI_VENDOR(f->dev_id), PCI_PRODUCT(f->dev_id),
				regnum, base, size);
	}

	cprintf("PCI function %02x:%02x.%d (%04x:%04x) enabled\n",
f0108a02:	89 c2                	mov    %eax,%edx
f0108a04:	c1 ea 10             	shr    $0x10,%edx
f0108a07:	89 54 24 14          	mov    %edx,0x14(%esp)
f0108a0b:	25 ff ff 00 00       	and    $0xffff,%eax
f0108a10:	89 44 24 10          	mov    %eax,0x10(%esp)
f0108a14:	8b 43 08             	mov    0x8(%ebx),%eax
f0108a17:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0108a1b:	8b 43 04             	mov    0x4(%ebx),%eax
f0108a1e:	89 44 24 08          	mov    %eax,0x8(%esp)
f0108a22:	8b 03                	mov    (%ebx),%eax
f0108a24:	8b 40 04             	mov    0x4(%eax),%eax
f0108a27:	89 44 24 04          	mov    %eax,0x4(%esp)
f0108a2b:	c7 04 24 44 ac 10 f0 	movl   $0xf010ac44,(%esp)
f0108a32:	e8 d8 c1 ff ff       	call   f0104c0f <cprintf>
		f->bus->busno, f->dev, f->func,
		PCI_VENDOR(f->dev_id), PCI_PRODUCT(f->dev_id));
}
f0108a37:	83 c4 4c             	add    $0x4c,%esp
f0108a3a:	5b                   	pop    %ebx
f0108a3b:	5e                   	pop    %esi
f0108a3c:	5f                   	pop    %edi
f0108a3d:	5d                   	pop    %ebp
f0108a3e:	c3                   	ret    
	...

f0108a40 <time_init>:

static unsigned int ticks;

void
time_init(void)
{
f0108a40:	55                   	push   %ebp
f0108a41:	89 e5                	mov    %esp,%ebp
	ticks = 0;
f0108a43:	c7 05 a8 3e 29 f0 00 	movl   $0x0,0xf0293ea8
f0108a4a:	00 00 00 
}
f0108a4d:	5d                   	pop    %ebp
f0108a4e:	c3                   	ret    

f0108a4f <time_msec>:
		panic("time_tick: time overflowed");
}

unsigned int
time_msec(void)
{
f0108a4f:	55                   	push   %ebp
f0108a50:	89 e5                	mov    %esp,%ebp
f0108a52:	a1 a8 3e 29 f0       	mov    0xf0293ea8,%eax
f0108a57:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0108a5a:	01 c0                	add    %eax,%eax
	return ticks * 10;
}
f0108a5c:	5d                   	pop    %ebp
f0108a5d:	c3                   	ret    

f0108a5e <time_tick>:

// This should be called once per timer interrupt.  A timer interrupt
// fires every 10 ms.
void
time_tick(void)
{
f0108a5e:	55                   	push   %ebp
f0108a5f:	89 e5                	mov    %esp,%ebp
f0108a61:	83 ec 18             	sub    $0x18,%esp
	ticks++;
f0108a64:	a1 a8 3e 29 f0       	mov    0xf0293ea8,%eax
f0108a69:	83 c0 01             	add    $0x1,%eax
f0108a6c:	a3 a8 3e 29 f0       	mov    %eax,0xf0293ea8
	if (ticks * 10 < ticks)
f0108a71:	8d 14 80             	lea    (%eax,%eax,4),%edx
f0108a74:	01 d2                	add    %edx,%edx
f0108a76:	39 d0                	cmp    %edx,%eax
f0108a78:	76 1c                	jbe    f0108a96 <time_tick+0x38>
		panic("time_tick: time overflowed");
f0108a7a:	c7 44 24 08 4c ad 10 	movl   $0xf010ad4c,0x8(%esp)
f0108a81:	f0 
f0108a82:	c7 44 24 04 13 00 00 	movl   $0x13,0x4(%esp)
f0108a89:	00 
f0108a8a:	c7 04 24 67 ad 10 f0 	movl   $0xf010ad67,(%esp)
f0108a91:	e8 ef 75 ff ff       	call   f0100085 <_panic>
}
f0108a96:	c9                   	leave  
f0108a97:	c3                   	ret    
	...

f0108aa0 <__udivdi3>:
f0108aa0:	55                   	push   %ebp
f0108aa1:	89 e5                	mov    %esp,%ebp
f0108aa3:	57                   	push   %edi
f0108aa4:	56                   	push   %esi
f0108aa5:	83 ec 10             	sub    $0x10,%esp
f0108aa8:	8b 45 14             	mov    0x14(%ebp),%eax
f0108aab:	8b 55 08             	mov    0x8(%ebp),%edx
f0108aae:	8b 75 10             	mov    0x10(%ebp),%esi
f0108ab1:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0108ab4:	85 c0                	test   %eax,%eax
f0108ab6:	89 55 f0             	mov    %edx,-0x10(%ebp)
f0108ab9:	75 35                	jne    f0108af0 <__udivdi3+0x50>
f0108abb:	39 fe                	cmp    %edi,%esi
f0108abd:	77 61                	ja     f0108b20 <__udivdi3+0x80>
f0108abf:	85 f6                	test   %esi,%esi
f0108ac1:	75 0b                	jne    f0108ace <__udivdi3+0x2e>
f0108ac3:	b8 01 00 00 00       	mov    $0x1,%eax
f0108ac8:	31 d2                	xor    %edx,%edx
f0108aca:	f7 f6                	div    %esi
f0108acc:	89 c6                	mov    %eax,%esi
f0108ace:	8b 4d f0             	mov    -0x10(%ebp),%ecx
f0108ad1:	31 d2                	xor    %edx,%edx
f0108ad3:	89 f8                	mov    %edi,%eax
f0108ad5:	f7 f6                	div    %esi
f0108ad7:	89 c7                	mov    %eax,%edi
f0108ad9:	89 c8                	mov    %ecx,%eax
f0108adb:	f7 f6                	div    %esi
f0108add:	89 c1                	mov    %eax,%ecx
f0108adf:	89 fa                	mov    %edi,%edx
f0108ae1:	89 c8                	mov    %ecx,%eax
f0108ae3:	83 c4 10             	add    $0x10,%esp
f0108ae6:	5e                   	pop    %esi
f0108ae7:	5f                   	pop    %edi
f0108ae8:	5d                   	pop    %ebp
f0108ae9:	c3                   	ret    
f0108aea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0108af0:	39 f8                	cmp    %edi,%eax
f0108af2:	77 1c                	ja     f0108b10 <__udivdi3+0x70>
f0108af4:	0f bd d0             	bsr    %eax,%edx
f0108af7:	83 f2 1f             	xor    $0x1f,%edx
f0108afa:	89 55 f4             	mov    %edx,-0xc(%ebp)
f0108afd:	75 39                	jne    f0108b38 <__udivdi3+0x98>
f0108aff:	3b 75 f0             	cmp    -0x10(%ebp),%esi
f0108b02:	0f 86 a0 00 00 00    	jbe    f0108ba8 <__udivdi3+0x108>
f0108b08:	39 f8                	cmp    %edi,%eax
f0108b0a:	0f 82 98 00 00 00    	jb     f0108ba8 <__udivdi3+0x108>
f0108b10:	31 ff                	xor    %edi,%edi
f0108b12:	31 c9                	xor    %ecx,%ecx
f0108b14:	89 c8                	mov    %ecx,%eax
f0108b16:	89 fa                	mov    %edi,%edx
f0108b18:	83 c4 10             	add    $0x10,%esp
f0108b1b:	5e                   	pop    %esi
f0108b1c:	5f                   	pop    %edi
f0108b1d:	5d                   	pop    %ebp
f0108b1e:	c3                   	ret    
f0108b1f:	90                   	nop
f0108b20:	89 d1                	mov    %edx,%ecx
f0108b22:	89 fa                	mov    %edi,%edx
f0108b24:	89 c8                	mov    %ecx,%eax
f0108b26:	31 ff                	xor    %edi,%edi
f0108b28:	f7 f6                	div    %esi
f0108b2a:	89 c1                	mov    %eax,%ecx
f0108b2c:	89 fa                	mov    %edi,%edx
f0108b2e:	89 c8                	mov    %ecx,%eax
f0108b30:	83 c4 10             	add    $0x10,%esp
f0108b33:	5e                   	pop    %esi
f0108b34:	5f                   	pop    %edi
f0108b35:	5d                   	pop    %ebp
f0108b36:	c3                   	ret    
f0108b37:	90                   	nop
f0108b38:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
f0108b3c:	89 f2                	mov    %esi,%edx
f0108b3e:	d3 e0                	shl    %cl,%eax
f0108b40:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0108b43:	b8 20 00 00 00       	mov    $0x20,%eax
f0108b48:	2b 45 f4             	sub    -0xc(%ebp),%eax
f0108b4b:	89 c1                	mov    %eax,%ecx
f0108b4d:	d3 ea                	shr    %cl,%edx
f0108b4f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
f0108b53:	0b 55 ec             	or     -0x14(%ebp),%edx
f0108b56:	d3 e6                	shl    %cl,%esi
f0108b58:	89 c1                	mov    %eax,%ecx
f0108b5a:	89 75 e8             	mov    %esi,-0x18(%ebp)
f0108b5d:	89 fe                	mov    %edi,%esi
f0108b5f:	d3 ee                	shr    %cl,%esi
f0108b61:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
f0108b65:	89 55 ec             	mov    %edx,-0x14(%ebp)
f0108b68:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0108b6b:	d3 e7                	shl    %cl,%edi
f0108b6d:	89 c1                	mov    %eax,%ecx
f0108b6f:	d3 ea                	shr    %cl,%edx
f0108b71:	09 d7                	or     %edx,%edi
f0108b73:	89 f2                	mov    %esi,%edx
f0108b75:	89 f8                	mov    %edi,%eax
f0108b77:	f7 75 ec             	divl   -0x14(%ebp)
f0108b7a:	89 d6                	mov    %edx,%esi
f0108b7c:	89 c7                	mov    %eax,%edi
f0108b7e:	f7 65 e8             	mull   -0x18(%ebp)
f0108b81:	39 d6                	cmp    %edx,%esi
f0108b83:	89 55 ec             	mov    %edx,-0x14(%ebp)
f0108b86:	72 30                	jb     f0108bb8 <__udivdi3+0x118>
f0108b88:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0108b8b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
f0108b8f:	d3 e2                	shl    %cl,%edx
f0108b91:	39 c2                	cmp    %eax,%edx
f0108b93:	73 05                	jae    f0108b9a <__udivdi3+0xfa>
f0108b95:	3b 75 ec             	cmp    -0x14(%ebp),%esi
f0108b98:	74 1e                	je     f0108bb8 <__udivdi3+0x118>
f0108b9a:	89 f9                	mov    %edi,%ecx
f0108b9c:	31 ff                	xor    %edi,%edi
f0108b9e:	e9 71 ff ff ff       	jmp    f0108b14 <__udivdi3+0x74>
f0108ba3:	90                   	nop
f0108ba4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0108ba8:	31 ff                	xor    %edi,%edi
f0108baa:	b9 01 00 00 00       	mov    $0x1,%ecx
f0108baf:	e9 60 ff ff ff       	jmp    f0108b14 <__udivdi3+0x74>
f0108bb4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0108bb8:	8d 4f ff             	lea    -0x1(%edi),%ecx
f0108bbb:	31 ff                	xor    %edi,%edi
f0108bbd:	89 c8                	mov    %ecx,%eax
f0108bbf:	89 fa                	mov    %edi,%edx
f0108bc1:	83 c4 10             	add    $0x10,%esp
f0108bc4:	5e                   	pop    %esi
f0108bc5:	5f                   	pop    %edi
f0108bc6:	5d                   	pop    %ebp
f0108bc7:	c3                   	ret    
	...

f0108bd0 <__umoddi3>:
f0108bd0:	55                   	push   %ebp
f0108bd1:	89 e5                	mov    %esp,%ebp
f0108bd3:	57                   	push   %edi
f0108bd4:	56                   	push   %esi
f0108bd5:	83 ec 20             	sub    $0x20,%esp
f0108bd8:	8b 55 14             	mov    0x14(%ebp),%edx
f0108bdb:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0108bde:	8b 7d 10             	mov    0x10(%ebp),%edi
f0108be1:	8b 75 0c             	mov    0xc(%ebp),%esi
f0108be4:	85 d2                	test   %edx,%edx
f0108be6:	89 c8                	mov    %ecx,%eax
f0108be8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
f0108beb:	75 13                	jne    f0108c00 <__umoddi3+0x30>
f0108bed:	39 f7                	cmp    %esi,%edi
f0108bef:	76 3f                	jbe    f0108c30 <__umoddi3+0x60>
f0108bf1:	89 f2                	mov    %esi,%edx
f0108bf3:	f7 f7                	div    %edi
f0108bf5:	89 d0                	mov    %edx,%eax
f0108bf7:	31 d2                	xor    %edx,%edx
f0108bf9:	83 c4 20             	add    $0x20,%esp
f0108bfc:	5e                   	pop    %esi
f0108bfd:	5f                   	pop    %edi
f0108bfe:	5d                   	pop    %ebp
f0108bff:	c3                   	ret    
f0108c00:	39 f2                	cmp    %esi,%edx
f0108c02:	77 4c                	ja     f0108c50 <__umoddi3+0x80>
f0108c04:	0f bd ca             	bsr    %edx,%ecx
f0108c07:	83 f1 1f             	xor    $0x1f,%ecx
f0108c0a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0108c0d:	75 51                	jne    f0108c60 <__umoddi3+0x90>
f0108c0f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
f0108c12:	0f 87 e0 00 00 00    	ja     f0108cf8 <__umoddi3+0x128>
f0108c18:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0108c1b:	29 f8                	sub    %edi,%eax
f0108c1d:	19 d6                	sbb    %edx,%esi
f0108c1f:	89 45 f4             	mov    %eax,-0xc(%ebp)
f0108c22:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0108c25:	89 f2                	mov    %esi,%edx
f0108c27:	83 c4 20             	add    $0x20,%esp
f0108c2a:	5e                   	pop    %esi
f0108c2b:	5f                   	pop    %edi
f0108c2c:	5d                   	pop    %ebp
f0108c2d:	c3                   	ret    
f0108c2e:	66 90                	xchg   %ax,%ax
f0108c30:	85 ff                	test   %edi,%edi
f0108c32:	75 0b                	jne    f0108c3f <__umoddi3+0x6f>
f0108c34:	b8 01 00 00 00       	mov    $0x1,%eax
f0108c39:	31 d2                	xor    %edx,%edx
f0108c3b:	f7 f7                	div    %edi
f0108c3d:	89 c7                	mov    %eax,%edi
f0108c3f:	89 f0                	mov    %esi,%eax
f0108c41:	31 d2                	xor    %edx,%edx
f0108c43:	f7 f7                	div    %edi
f0108c45:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0108c48:	f7 f7                	div    %edi
f0108c4a:	eb a9                	jmp    f0108bf5 <__umoddi3+0x25>
f0108c4c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0108c50:	89 c8                	mov    %ecx,%eax
f0108c52:	89 f2                	mov    %esi,%edx
f0108c54:	83 c4 20             	add    $0x20,%esp
f0108c57:	5e                   	pop    %esi
f0108c58:	5f                   	pop    %edi
f0108c59:	5d                   	pop    %ebp
f0108c5a:	c3                   	ret    
f0108c5b:	90                   	nop
f0108c5c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0108c60:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0108c64:	d3 e2                	shl    %cl,%edx
f0108c66:	89 55 f4             	mov    %edx,-0xc(%ebp)
f0108c69:	ba 20 00 00 00       	mov    $0x20,%edx
f0108c6e:	2b 55 f0             	sub    -0x10(%ebp),%edx
f0108c71:	89 55 ec             	mov    %edx,-0x14(%ebp)
f0108c74:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f0108c78:	89 fa                	mov    %edi,%edx
f0108c7a:	d3 ea                	shr    %cl,%edx
f0108c7c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0108c80:	0b 55 f4             	or     -0xc(%ebp),%edx
f0108c83:	d3 e7                	shl    %cl,%edi
f0108c85:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f0108c89:	89 55 f4             	mov    %edx,-0xc(%ebp)
f0108c8c:	89 f2                	mov    %esi,%edx
f0108c8e:	89 7d e8             	mov    %edi,-0x18(%ebp)
f0108c91:	89 c7                	mov    %eax,%edi
f0108c93:	d3 ea                	shr    %cl,%edx
f0108c95:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0108c99:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0108c9c:	89 c2                	mov    %eax,%edx
f0108c9e:	d3 e6                	shl    %cl,%esi
f0108ca0:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f0108ca4:	d3 ea                	shr    %cl,%edx
f0108ca6:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0108caa:	09 d6                	or     %edx,%esi
f0108cac:	89 f0                	mov    %esi,%eax
f0108cae:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0108cb1:	d3 e7                	shl    %cl,%edi
f0108cb3:	89 f2                	mov    %esi,%edx
f0108cb5:	f7 75 f4             	divl   -0xc(%ebp)
f0108cb8:	89 d6                	mov    %edx,%esi
f0108cba:	f7 65 e8             	mull   -0x18(%ebp)
f0108cbd:	39 d6                	cmp    %edx,%esi
f0108cbf:	72 2b                	jb     f0108cec <__umoddi3+0x11c>
f0108cc1:	39 c7                	cmp    %eax,%edi
f0108cc3:	72 23                	jb     f0108ce8 <__umoddi3+0x118>
f0108cc5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0108cc9:	29 c7                	sub    %eax,%edi
f0108ccb:	19 d6                	sbb    %edx,%esi
f0108ccd:	89 f0                	mov    %esi,%eax
f0108ccf:	89 f2                	mov    %esi,%edx
f0108cd1:	d3 ef                	shr    %cl,%edi
f0108cd3:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f0108cd7:	d3 e0                	shl    %cl,%eax
f0108cd9:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0108cdd:	09 f8                	or     %edi,%eax
f0108cdf:	d3 ea                	shr    %cl,%edx
f0108ce1:	83 c4 20             	add    $0x20,%esp
f0108ce4:	5e                   	pop    %esi
f0108ce5:	5f                   	pop    %edi
f0108ce6:	5d                   	pop    %ebp
f0108ce7:	c3                   	ret    
f0108ce8:	39 d6                	cmp    %edx,%esi
f0108cea:	75 d9                	jne    f0108cc5 <__umoddi3+0xf5>
f0108cec:	2b 45 e8             	sub    -0x18(%ebp),%eax
f0108cef:	1b 55 f4             	sbb    -0xc(%ebp),%edx
f0108cf2:	eb d1                	jmp    f0108cc5 <__umoddi3+0xf5>
f0108cf4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0108cf8:	39 f2                	cmp    %esi,%edx
f0108cfa:	0f 82 18 ff ff ff    	jb     f0108c18 <__umoddi3+0x48>
f0108d00:	e9 1d ff ff ff       	jmp    f0108c22 <__umoddi3+0x52>
