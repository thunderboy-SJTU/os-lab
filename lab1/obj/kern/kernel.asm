
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
	# until we set up our real page table in i386_vm_init in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 10 11 00       	mov    $0x111000,%eax
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
f0100034:	bc 00 10 11 f0       	mov    $0xf0111000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 03 01 00 00       	call   f0100141 <i386_init>

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
f0100058:	c7 04 24 80 20 10 f0 	movl   $0xf0102080,(%esp)
f010005f:	e8 8b 0c 00 00       	call   f0100cef <cprintf>
	vcprintf(fmt, ap);
f0100064:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100068:	8b 45 10             	mov    0x10(%ebp),%eax
f010006b:	89 04 24             	mov    %eax,(%esp)
f010006e:	e8 49 0c 00 00       	call   f0100cbc <vcprintf>
	cprintf("\n");
f0100073:	c7 04 24 a6 21 10 f0 	movl   $0xf01021a6,(%esp)
f010007a:	e8 70 0c 00 00       	call   f0100cef <cprintf>
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
f0100090:	83 3d 00 33 11 f0 00 	cmpl   $0x0,0xf0113300
f0100097:	75 3d                	jne    f01000d6 <_panic+0x51>
		goto dead;
	panicstr = fmt;
f0100099:	89 35 00 33 11 f0    	mov    %esi,0xf0113300

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
	cprintf("kernel panic at %s:%d: ", file, line);
f01000a4:	8b 45 0c             	mov    0xc(%ebp),%eax
f01000a7:	89 44 24 08          	mov    %eax,0x8(%esp)
f01000ab:	8b 45 08             	mov    0x8(%ebp),%eax
f01000ae:	89 44 24 04          	mov    %eax,0x4(%esp)
f01000b2:	c7 04 24 9a 20 10 f0 	movl   $0xf010209a,(%esp)
f01000b9:	e8 31 0c 00 00       	call   f0100cef <cprintf>
	vcprintf(fmt, ap);
f01000be:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01000c2:	89 34 24             	mov    %esi,(%esp)
f01000c5:	e8 f2 0b 00 00       	call   f0100cbc <vcprintf>
	cprintf("\n");
f01000ca:	c7 04 24 a6 21 10 f0 	movl   $0xf01021a6,(%esp)
f01000d1:	e8 19 0c 00 00       	call   f0100cef <cprintf>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f01000d6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01000dd:	e8 17 09 00 00       	call   f01009f9 <monitor>
f01000e2:	eb f2                	jmp    f01000d6 <_panic+0x51>

f01000e4 <test_backtrace>:
#include <kern/console.h>

// Test the stack backtrace function (lab 1 only)
void
test_backtrace(int x)
{
f01000e4:	55                   	push   %ebp
f01000e5:	89 e5                	mov    %esp,%ebp
f01000e7:	53                   	push   %ebx
f01000e8:	83 ec 14             	sub    $0x14,%esp
f01000eb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("entering test_backtrace %d\n", x);
f01000ee:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01000f2:	c7 04 24 b2 20 10 f0 	movl   $0xf01020b2,(%esp)
f01000f9:	e8 f1 0b 00 00       	call   f0100cef <cprintf>
	if (x > 0)
f01000fe:	85 db                	test   %ebx,%ebx
f0100100:	7e 0d                	jle    f010010f <test_backtrace+0x2b>
		test_backtrace(x-1);
f0100102:	8d 43 ff             	lea    -0x1(%ebx),%eax
f0100105:	89 04 24             	mov    %eax,(%esp)
f0100108:	e8 d7 ff ff ff       	call   f01000e4 <test_backtrace>
f010010d:	eb 1c                	jmp    f010012b <test_backtrace+0x47>
	else
		mon_backtrace(0, 0, 0);
f010010f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0100116:	00 
f0100117:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010011e:	00 
f010011f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0100126:	e8 bb 0a 00 00       	call   f0100be6 <mon_backtrace>
	cprintf("leaving test_backtrace %d\n", x);
f010012b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010012f:	c7 04 24 ce 20 10 f0 	movl   $0xf01020ce,(%esp)
f0100136:	e8 b4 0b 00 00       	call   f0100cef <cprintf>
}
f010013b:	83 c4 14             	add    $0x14,%esp
f010013e:	5b                   	pop    %ebx
f010013f:	5d                   	pop    %ebp
f0100140:	c3                   	ret    

f0100141 <i386_init>:

void
i386_init(void)
{
f0100141:	55                   	push   %ebp
f0100142:	89 e5                	mov    %esp,%ebp
f0100144:	57                   	push   %edi
f0100145:	53                   	push   %ebx
f0100146:	81 ec 20 01 00 00    	sub    $0x120,%esp
	extern char edata[], end[];
   	// Lab1 only
	char chnum1 = 0, chnum2 = 0, ntest[256] = {};
f010014c:	c6 45 f7 00          	movb   $0x0,-0x9(%ebp)
f0100150:	c6 45 f6 00          	movb   $0x0,-0xa(%ebp)
f0100154:	ba 00 01 00 00       	mov    $0x100,%edx
f0100159:	b8 00 00 00 00       	mov    $0x0,%eax
f010015e:	8d bd f6 fe ff ff    	lea    -0x10a(%ebp),%edi
f0100164:	66 ab                	stos   %ax,%es:(%edi)
f0100166:	83 ea 02             	sub    $0x2,%edx
f0100169:	89 d1                	mov    %edx,%ecx
f010016b:	c1 e9 02             	shr    $0x2,%ecx
f010016e:	f3 ab                	rep stos %eax,%es:(%edi)
f0100170:	f6 c2 02             	test   $0x2,%dl
f0100173:	74 02                	je     f0100177 <i386_init+0x36>
f0100175:	66 ab                	stos   %ax,%es:(%edi)
f0100177:	83 e2 01             	and    $0x1,%edx
f010017a:	85 d2                	test   %edx,%edx
f010017c:	74 01                	je     f010017f <i386_init+0x3e>
f010017e:	aa                   	stos   %al,%es:(%edi)

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f010017f:	b8 60 39 11 f0       	mov    $0xf0113960,%eax
f0100184:	2d 00 33 11 f0       	sub    $0xf0113300,%eax
f0100189:	89 44 24 08          	mov    %eax,0x8(%esp)
f010018d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100194:	00 
f0100195:	c7 04 24 00 33 11 f0 	movl   $0xf0113300,(%esp)
f010019c:	e8 f5 19 00 00       	call   f0101b96 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01001a1:	e8 f4 03 00 00       	call   f010059a <cons_init>

	cprintf("6828 decimal is %o octal!%n\n%n", 6828, &chnum1, &chnum2);
f01001a6:	8d 45 f6             	lea    -0xa(%ebp),%eax
f01001a9:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01001ad:	8d 7d f7             	lea    -0x9(%ebp),%edi
f01001b0:	89 7c 24 08          	mov    %edi,0x8(%esp)
f01001b4:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f01001bb:	00 
f01001bc:	c7 04 24 30 21 10 f0 	movl   $0xf0102130,(%esp)
f01001c3:	e8 27 0b 00 00       	call   f0100cef <cprintf>
	cprintf("pading space in the right to number 22: %-8d.\n", 22);
f01001c8:	c7 44 24 04 16 00 00 	movl   $0x16,0x4(%esp)
f01001cf:	00 
f01001d0:	c7 04 24 50 21 10 f0 	movl   $0xf0102150,(%esp)
f01001d7:	e8 13 0b 00 00       	call   f0100cef <cprintf>
	cprintf("chnum1: %d chnum2: %d\n", chnum1, chnum2);
f01001dc:	0f be 45 f6          	movsbl -0xa(%ebp),%eax
f01001e0:	89 44 24 08          	mov    %eax,0x8(%esp)
f01001e4:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
f01001e8:	89 44 24 04          	mov    %eax,0x4(%esp)
f01001ec:	c7 04 24 e9 20 10 f0 	movl   $0xf01020e9,(%esp)
f01001f3:	e8 f7 0a 00 00       	call   f0100cef <cprintf>
	cprintf("%n", NULL);
f01001f8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01001ff:	00 
f0100200:	c7 04 24 02 21 10 f0 	movl   $0xf0102102,(%esp)
f0100207:	e8 e3 0a 00 00       	call   f0100cef <cprintf>
	memset(ntest, 0xd, sizeof(ntest) - 1);
f010020c:	c7 44 24 08 ff 00 00 	movl   $0xff,0x8(%esp)
f0100213:	00 
f0100214:	c7 44 24 04 0d 00 00 	movl   $0xd,0x4(%esp)
f010021b:	00 
f010021c:	8d 9d f6 fe ff ff    	lea    -0x10a(%ebp),%ebx
f0100222:	89 1c 24             	mov    %ebx,(%esp)
f0100225:	e8 6c 19 00 00       	call   f0101b96 <memset>
	cprintf("%s%n", ntest, &chnum1); 
f010022a:	89 7c 24 08          	mov    %edi,0x8(%esp)
f010022e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100232:	c7 04 24 00 21 10 f0 	movl   $0xf0102100,(%esp)
f0100239:	e8 b1 0a 00 00       	call   f0100cef <cprintf>
	cprintf("chnum1: %d\n", chnum1);
f010023e:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
f0100242:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100246:	c7 04 24 05 21 10 f0 	movl   $0xf0102105,(%esp)
f010024d:	e8 9d 0a 00 00       	call   f0100cef <cprintf>
	cprintf("show me the sign: %+d, %+d\n", 1024, -1024);
f0100252:	c7 44 24 08 00 fc ff 	movl   $0xfffffc00,0x8(%esp)
f0100259:	ff 
f010025a:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
f0100261:	00 
f0100262:	c7 04 24 11 21 10 f0 	movl   $0xf0102111,(%esp)
f0100269:	e8 81 0a 00 00       	call   f0100cef <cprintf>


	// Test the stack backtrace function (lab 1 only)
	test_backtrace(5);
f010026e:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
f0100275:	e8 6a fe ff ff       	call   f01000e4 <test_backtrace>

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
f010027a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0100281:	e8 73 07 00 00       	call   f01009f9 <monitor>
f0100286:	eb f2                	jmp    f010027a <i386_init+0x139>
	...

f0100290 <delay>:
static void cons_putc(int c);

// Stupid I/O delay routine necessitated by historical PC design flaws
static void
delay(void)
{
f0100290:	55                   	push   %ebp
f0100291:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100293:	ba 84 00 00 00       	mov    $0x84,%edx
f0100298:	ec                   	in     (%dx),%al
f0100299:	ec                   	in     (%dx),%al
f010029a:	ec                   	in     (%dx),%al
f010029b:	ec                   	in     (%dx),%al
	inb(0x84);
	inb(0x84);
	inb(0x84);
	inb(0x84);
}
f010029c:	5d                   	pop    %ebp
f010029d:	c3                   	ret    

f010029e <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f010029e:	55                   	push   %ebp
f010029f:	89 e5                	mov    %esp,%ebp
f01002a1:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01002a6:	ec                   	in     (%dx),%al
f01002a7:	89 c2                	mov    %eax,%edx
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f01002a9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01002ae:	f6 c2 01             	test   $0x1,%dl
f01002b1:	74 09                	je     f01002bc <serial_proc_data+0x1e>
f01002b3:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01002b8:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f01002b9:	0f b6 c0             	movzbl %al,%eax
}
f01002bc:	5d                   	pop    %ebp
f01002bd:	c3                   	ret    

f01002be <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f01002be:	55                   	push   %ebp
f01002bf:	89 e5                	mov    %esp,%ebp
f01002c1:	57                   	push   %edi
f01002c2:	56                   	push   %esi
f01002c3:	53                   	push   %ebx
f01002c4:	83 ec 0c             	sub    $0xc,%esp
f01002c7:	89 c6                	mov    %eax,%esi
	int c;

	while ((c = (*proc)()) != -1) {
		if (c == 0)
			continue;
		cons.buf[cons.wpos++] = c;
f01002c9:	bb 44 35 11 f0       	mov    $0xf0113544,%ebx
f01002ce:	bf 40 33 11 f0       	mov    $0xf0113340,%edi
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f01002d3:	eb 1e                	jmp    f01002f3 <cons_intr+0x35>
		if (c == 0)
f01002d5:	85 c0                	test   %eax,%eax
f01002d7:	74 1a                	je     f01002f3 <cons_intr+0x35>
			continue;
		cons.buf[cons.wpos++] = c;
f01002d9:	8b 13                	mov    (%ebx),%edx
f01002db:	88 04 17             	mov    %al,(%edi,%edx,1)
f01002de:	8d 42 01             	lea    0x1(%edx),%eax
		if (cons.wpos == CONSBUFSIZE)
f01002e1:	3d 00 02 00 00       	cmp    $0x200,%eax
			cons.wpos = 0;
f01002e6:	0f 94 c2             	sete   %dl
f01002e9:	0f b6 d2             	movzbl %dl,%edx
f01002ec:	83 ea 01             	sub    $0x1,%edx
f01002ef:	21 d0                	and    %edx,%eax
f01002f1:	89 03                	mov    %eax,(%ebx)
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f01002f3:	ff d6                	call   *%esi
f01002f5:	83 f8 ff             	cmp    $0xffffffff,%eax
f01002f8:	75 db                	jne    f01002d5 <cons_intr+0x17>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f01002fa:	83 c4 0c             	add    $0xc,%esp
f01002fd:	5b                   	pop    %ebx
f01002fe:	5e                   	pop    %esi
f01002ff:	5f                   	pop    %edi
f0100300:	5d                   	pop    %ebp
f0100301:	c3                   	ret    

f0100302 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f0100302:	55                   	push   %ebp
f0100303:	89 e5                	mov    %esp,%ebp
f0100305:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f0100308:	b8 8a 06 10 f0       	mov    $0xf010068a,%eax
f010030d:	e8 ac ff ff ff       	call   f01002be <cons_intr>
}
f0100312:	c9                   	leave  
f0100313:	c3                   	ret    

f0100314 <serial_intr>:
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f0100314:	55                   	push   %ebp
f0100315:	89 e5                	mov    %esp,%ebp
f0100317:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
f010031a:	83 3d 24 33 11 f0 00 	cmpl   $0x0,0xf0113324
f0100321:	74 0a                	je     f010032d <serial_intr+0x19>
		cons_intr(serial_proc_data);
f0100323:	b8 9e 02 10 f0       	mov    $0xf010029e,%eax
f0100328:	e8 91 ff ff ff       	call   f01002be <cons_intr>
}
f010032d:	c9                   	leave  
f010032e:	c3                   	ret    

f010032f <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f010032f:	55                   	push   %ebp
f0100330:	89 e5                	mov    %esp,%ebp
f0100332:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f0100335:	e8 da ff ff ff       	call   f0100314 <serial_intr>
	kbd_intr();
f010033a:	e8 c3 ff ff ff       	call   f0100302 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f010033f:	8b 15 40 35 11 f0    	mov    0xf0113540,%edx
f0100345:	b8 00 00 00 00       	mov    $0x0,%eax
f010034a:	3b 15 44 35 11 f0    	cmp    0xf0113544,%edx
f0100350:	74 21                	je     f0100373 <cons_getc+0x44>
		c = cons.buf[cons.rpos++];
f0100352:	0f b6 82 40 33 11 f0 	movzbl -0xfeeccc0(%edx),%eax
f0100359:	83 c2 01             	add    $0x1,%edx
		if (cons.rpos == CONSBUFSIZE)
f010035c:	81 fa 00 02 00 00    	cmp    $0x200,%edx
			cons.rpos = 0;
f0100362:	0f 94 c1             	sete   %cl
f0100365:	0f b6 c9             	movzbl %cl,%ecx
f0100368:	83 e9 01             	sub    $0x1,%ecx
f010036b:	21 ca                	and    %ecx,%edx
f010036d:	89 15 40 35 11 f0    	mov    %edx,0xf0113540
		return c;
	}
	return 0;
}
f0100373:	c9                   	leave  
f0100374:	c3                   	ret    

f0100375 <getchar>:
	cons_putc(c);
}

int
getchar(void)
{
f0100375:	55                   	push   %ebp
f0100376:	89 e5                	mov    %esp,%ebp
f0100378:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f010037b:	e8 af ff ff ff       	call   f010032f <cons_getc>
f0100380:	85 c0                	test   %eax,%eax
f0100382:	74 f7                	je     f010037b <getchar+0x6>
		/* do nothing */;
	return c;
}
f0100384:	c9                   	leave  
f0100385:	c3                   	ret    

f0100386 <iscons>:

int
iscons(int fdnum)
{
f0100386:	55                   	push   %ebp
f0100387:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f0100389:	b8 01 00 00 00       	mov    $0x1,%eax
f010038e:	5d                   	pop    %ebp
f010038f:	c3                   	ret    

f0100390 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f0100390:	55                   	push   %ebp
f0100391:	89 e5                	mov    %esp,%ebp
f0100393:	57                   	push   %edi
f0100394:	56                   	push   %esi
f0100395:	53                   	push   %ebx
f0100396:	83 ec 2c             	sub    $0x2c,%esp
f0100399:	89 c7                	mov    %eax,%edi
f010039b:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01003a0:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;
	
	for (i = 0;
f01003a1:	a8 20                	test   $0x20,%al
f01003a3:	75 21                	jne    f01003c6 <cons_putc+0x36>
f01003a5:	bb 00 00 00 00       	mov    $0x0,%ebx
f01003aa:	be fd 03 00 00       	mov    $0x3fd,%esi
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
		delay();
f01003af:	e8 dc fe ff ff       	call   f0100290 <delay>
f01003b4:	89 f2                	mov    %esi,%edx
f01003b6:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;
	
	for (i = 0;
f01003b7:	a8 20                	test   $0x20,%al
f01003b9:	75 0b                	jne    f01003c6 <cons_putc+0x36>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
f01003bb:	83 c3 01             	add    $0x1,%ebx
static void
serial_putc(int c)
{
	int i;
	
	for (i = 0;
f01003be:	81 fb 00 32 00 00    	cmp    $0x3200,%ebx
f01003c4:	75 e9                	jne    f01003af <cons_putc+0x1f>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
		delay();
	
	outb(COM1 + COM_TX, c);
f01003c6:	89 fa                	mov    %edi,%edx
f01003c8:	89 f8                	mov    %edi,%eax
f01003ca:	88 55 e7             	mov    %dl,-0x19(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003cd:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01003d2:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01003d3:	b2 79                	mov    $0x79,%dl
f01003d5:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f01003d6:	84 c0                	test   %al,%al
f01003d8:	78 21                	js     f01003fb <cons_putc+0x6b>
f01003da:	bb 00 00 00 00       	mov    $0x0,%ebx
f01003df:	be 79 03 00 00       	mov    $0x379,%esi
		delay();
f01003e4:	e8 a7 fe ff ff       	call   f0100290 <delay>
f01003e9:	89 f2                	mov    %esi,%edx
f01003eb:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f01003ec:	84 c0                	test   %al,%al
f01003ee:	78 0b                	js     f01003fb <cons_putc+0x6b>
f01003f0:	83 c3 01             	add    $0x1,%ebx
f01003f3:	81 fb 00 32 00 00    	cmp    $0x3200,%ebx
f01003f9:	75 e9                	jne    f01003e4 <cons_putc+0x54>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003fb:	ba 78 03 00 00       	mov    $0x378,%edx
f0100400:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f0100404:	ee                   	out    %al,(%dx)
f0100405:	b2 7a                	mov    $0x7a,%dl
f0100407:	b8 0d 00 00 00       	mov    $0xd,%eax
f010040c:	ee                   	out    %al,(%dx)
f010040d:	b8 08 00 00 00       	mov    $0x8,%eax
f0100412:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f0100413:	f7 c7 00 ff ff ff    	test   $0xffffff00,%edi
f0100419:	75 06                	jne    f0100421 <cons_putc+0x91>
		c |= 0x0700;
f010041b:	81 cf 00 07 00 00    	or     $0x700,%edi

	switch (c & 0xff) {
f0100421:	89 f8                	mov    %edi,%eax
f0100423:	25 ff 00 00 00       	and    $0xff,%eax
f0100428:	83 f8 09             	cmp    $0x9,%eax
f010042b:	0f 84 83 00 00 00    	je     f01004b4 <cons_putc+0x124>
f0100431:	83 f8 09             	cmp    $0x9,%eax
f0100434:	7f 0c                	jg     f0100442 <cons_putc+0xb2>
f0100436:	83 f8 08             	cmp    $0x8,%eax
f0100439:	0f 85 a9 00 00 00    	jne    f01004e8 <cons_putc+0x158>
f010043f:	90                   	nop
f0100440:	eb 18                	jmp    f010045a <cons_putc+0xca>
f0100442:	83 f8 0a             	cmp    $0xa,%eax
f0100445:	8d 76 00             	lea    0x0(%esi),%esi
f0100448:	74 40                	je     f010048a <cons_putc+0xfa>
f010044a:	83 f8 0d             	cmp    $0xd,%eax
f010044d:	8d 76 00             	lea    0x0(%esi),%esi
f0100450:	0f 85 92 00 00 00    	jne    f01004e8 <cons_putc+0x158>
f0100456:	66 90                	xchg   %ax,%ax
f0100458:	eb 38                	jmp    f0100492 <cons_putc+0x102>
	case '\b':
		if (crt_pos > 0) {
f010045a:	0f b7 05 30 33 11 f0 	movzwl 0xf0113330,%eax
f0100461:	66 85 c0             	test   %ax,%ax
f0100464:	0f 84 e8 00 00 00    	je     f0100552 <cons_putc+0x1c2>
			crt_pos--;
f010046a:	83 e8 01             	sub    $0x1,%eax
f010046d:	66 a3 30 33 11 f0    	mov    %ax,0xf0113330
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f0100473:	0f b7 c0             	movzwl %ax,%eax
f0100476:	66 81 e7 00 ff       	and    $0xff00,%di
f010047b:	83 cf 20             	or     $0x20,%edi
f010047e:	8b 15 2c 33 11 f0    	mov    0xf011332c,%edx
f0100484:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f0100488:	eb 7b                	jmp    f0100505 <cons_putc+0x175>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f010048a:	66 83 05 30 33 11 f0 	addw   $0x50,0xf0113330
f0100491:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f0100492:	0f b7 05 30 33 11 f0 	movzwl 0xf0113330,%eax
f0100499:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f010049f:	c1 e8 10             	shr    $0x10,%eax
f01004a2:	66 c1 e8 06          	shr    $0x6,%ax
f01004a6:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01004a9:	c1 e0 04             	shl    $0x4,%eax
f01004ac:	66 a3 30 33 11 f0    	mov    %ax,0xf0113330
f01004b2:	eb 51                	jmp    f0100505 <cons_putc+0x175>
		break;
	case '\t':
		cons_putc(' ');
f01004b4:	b8 20 00 00 00       	mov    $0x20,%eax
f01004b9:	e8 d2 fe ff ff       	call   f0100390 <cons_putc>
		cons_putc(' ');
f01004be:	b8 20 00 00 00       	mov    $0x20,%eax
f01004c3:	e8 c8 fe ff ff       	call   f0100390 <cons_putc>
		cons_putc(' ');
f01004c8:	b8 20 00 00 00       	mov    $0x20,%eax
f01004cd:	e8 be fe ff ff       	call   f0100390 <cons_putc>
		cons_putc(' ');
f01004d2:	b8 20 00 00 00       	mov    $0x20,%eax
f01004d7:	e8 b4 fe ff ff       	call   f0100390 <cons_putc>
		cons_putc(' ');
f01004dc:	b8 20 00 00 00       	mov    $0x20,%eax
f01004e1:	e8 aa fe ff ff       	call   f0100390 <cons_putc>
f01004e6:	eb 1d                	jmp    f0100505 <cons_putc+0x175>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f01004e8:	0f b7 05 30 33 11 f0 	movzwl 0xf0113330,%eax
f01004ef:	0f b7 c8             	movzwl %ax,%ecx
f01004f2:	8b 15 2c 33 11 f0    	mov    0xf011332c,%edx
f01004f8:	66 89 3c 4a          	mov    %di,(%edx,%ecx,2)
f01004fc:	83 c0 01             	add    $0x1,%eax
f01004ff:	66 a3 30 33 11 f0    	mov    %ax,0xf0113330
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100505:	66 81 3d 30 33 11 f0 	cmpw   $0x7cf,0xf0113330
f010050c:	cf 07 
f010050e:	76 42                	jbe    f0100552 <cons_putc+0x1c2>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100510:	a1 2c 33 11 f0       	mov    0xf011332c,%eax
f0100515:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
f010051c:	00 
f010051d:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100523:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100527:	89 04 24             	mov    %eax,(%esp)
f010052a:	e8 c6 16 00 00       	call   f0101bf5 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f010052f:	8b 15 2c 33 11 f0    	mov    0xf011332c,%edx
f0100535:	b8 80 07 00 00       	mov    $0x780,%eax
f010053a:	66 c7 04 42 20 07    	movw   $0x720,(%edx,%eax,2)
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100540:	83 c0 01             	add    $0x1,%eax
f0100543:	3d d0 07 00 00       	cmp    $0x7d0,%eax
f0100548:	75 f0                	jne    f010053a <cons_putc+0x1aa>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f010054a:	66 83 2d 30 33 11 f0 	subw   $0x50,0xf0113330
f0100551:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f0100552:	8b 0d 28 33 11 f0    	mov    0xf0113328,%ecx
f0100558:	89 cb                	mov    %ecx,%ebx
f010055a:	b8 0e 00 00 00       	mov    $0xe,%eax
f010055f:	89 ca                	mov    %ecx,%edx
f0100561:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100562:	0f b7 35 30 33 11 f0 	movzwl 0xf0113330,%esi
f0100569:	83 c1 01             	add    $0x1,%ecx
f010056c:	89 f0                	mov    %esi,%eax
f010056e:	66 c1 e8 08          	shr    $0x8,%ax
f0100572:	89 ca                	mov    %ecx,%edx
f0100574:	ee                   	out    %al,(%dx)
f0100575:	b8 0f 00 00 00       	mov    $0xf,%eax
f010057a:	89 da                	mov    %ebx,%edx
f010057c:	ee                   	out    %al,(%dx)
f010057d:	89 f0                	mov    %esi,%eax
f010057f:	89 ca                	mov    %ecx,%edx
f0100581:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f0100582:	83 c4 2c             	add    $0x2c,%esp
f0100585:	5b                   	pop    %ebx
f0100586:	5e                   	pop    %esi
f0100587:	5f                   	pop    %edi
f0100588:	5d                   	pop    %ebp
f0100589:	c3                   	ret    

f010058a <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f010058a:	55                   	push   %ebp
f010058b:	89 e5                	mov    %esp,%ebp
f010058d:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f0100590:	8b 45 08             	mov    0x8(%ebp),%eax
f0100593:	e8 f8 fd ff ff       	call   f0100390 <cons_putc>
}
f0100598:	c9                   	leave  
f0100599:	c3                   	ret    

f010059a <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f010059a:	55                   	push   %ebp
f010059b:	89 e5                	mov    %esp,%ebp
f010059d:	57                   	push   %edi
f010059e:	56                   	push   %esi
f010059f:	53                   	push   %ebx
f01005a0:	83 ec 1c             	sub    $0x1c,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f01005a3:	b8 00 80 0b f0       	mov    $0xf00b8000,%eax
f01005a8:	0f b7 10             	movzwl (%eax),%edx
	*cp = (uint16_t) 0xA55A;
f01005ab:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
	if (*cp != 0xA55A) {
f01005b0:	0f b7 00             	movzwl (%eax),%eax
f01005b3:	66 3d 5a a5          	cmp    $0xa55a,%ax
f01005b7:	74 11                	je     f01005ca <cons_init+0x30>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f01005b9:	c7 05 28 33 11 f0 b4 	movl   $0x3b4,0xf0113328
f01005c0:	03 00 00 
f01005c3:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f01005c8:	eb 16                	jmp    f01005e0 <cons_init+0x46>
	} else {
		*cp = was;
f01005ca:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f01005d1:	c7 05 28 33 11 f0 d4 	movl   $0x3d4,0xf0113328
f01005d8:	03 00 00 
f01005db:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
	}
	
	/* Extract cursor location */
	outb(addr_6845, 14);
f01005e0:	8b 0d 28 33 11 f0    	mov    0xf0113328,%ecx
f01005e6:	89 cb                	mov    %ecx,%ebx
f01005e8:	b8 0e 00 00 00       	mov    $0xe,%eax
f01005ed:	89 ca                	mov    %ecx,%edx
f01005ef:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f01005f0:	83 c1 01             	add    $0x1,%ecx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005f3:	89 ca                	mov    %ecx,%edx
f01005f5:	ec                   	in     (%dx),%al
f01005f6:	0f b6 f8             	movzbl %al,%edi
f01005f9:	c1 e7 08             	shl    $0x8,%edi
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01005fc:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100601:	89 da                	mov    %ebx,%edx
f0100603:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100604:	89 ca                	mov    %ecx,%edx
f0100606:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f0100607:	89 35 2c 33 11 f0    	mov    %esi,0xf011332c
	crt_pos = pos;
f010060d:	0f b6 c8             	movzbl %al,%ecx
f0100610:	09 cf                	or     %ecx,%edi
f0100612:	66 89 3d 30 33 11 f0 	mov    %di,0xf0113330
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100619:	bb fa 03 00 00       	mov    $0x3fa,%ebx
f010061e:	b8 00 00 00 00       	mov    $0x0,%eax
f0100623:	89 da                	mov    %ebx,%edx
f0100625:	ee                   	out    %al,(%dx)
f0100626:	b2 fb                	mov    $0xfb,%dl
f0100628:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f010062d:	ee                   	out    %al,(%dx)
f010062e:	b9 f8 03 00 00       	mov    $0x3f8,%ecx
f0100633:	b8 0c 00 00 00       	mov    $0xc,%eax
f0100638:	89 ca                	mov    %ecx,%edx
f010063a:	ee                   	out    %al,(%dx)
f010063b:	b2 f9                	mov    $0xf9,%dl
f010063d:	b8 00 00 00 00       	mov    $0x0,%eax
f0100642:	ee                   	out    %al,(%dx)
f0100643:	b2 fb                	mov    $0xfb,%dl
f0100645:	b8 03 00 00 00       	mov    $0x3,%eax
f010064a:	ee                   	out    %al,(%dx)
f010064b:	b2 fc                	mov    $0xfc,%dl
f010064d:	b8 00 00 00 00       	mov    $0x0,%eax
f0100652:	ee                   	out    %al,(%dx)
f0100653:	b2 f9                	mov    $0xf9,%dl
f0100655:	b8 01 00 00 00       	mov    $0x1,%eax
f010065a:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010065b:	b2 fd                	mov    $0xfd,%dl
f010065d:	ec                   	in     (%dx),%al
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f010065e:	3c ff                	cmp    $0xff,%al
f0100660:	0f 95 c0             	setne  %al
f0100663:	0f b6 f0             	movzbl %al,%esi
f0100666:	89 35 24 33 11 f0    	mov    %esi,0xf0113324
f010066c:	89 da                	mov    %ebx,%edx
f010066e:	ec                   	in     (%dx),%al
f010066f:	89 ca                	mov    %ecx,%edx
f0100671:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f0100672:	85 f6                	test   %esi,%esi
f0100674:	75 0c                	jne    f0100682 <cons_init+0xe8>
		cprintf("Serial port does not exist!\n");
f0100676:	c7 04 24 7f 21 10 f0 	movl   $0xf010217f,(%esp)
f010067d:	e8 6d 06 00 00       	call   f0100cef <cprintf>
}
f0100682:	83 c4 1c             	add    $0x1c,%esp
f0100685:	5b                   	pop    %ebx
f0100686:	5e                   	pop    %esi
f0100687:	5f                   	pop    %edi
f0100688:	5d                   	pop    %ebp
f0100689:	c3                   	ret    

f010068a <kbd_proc_data>:
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f010068a:	55                   	push   %ebp
f010068b:	89 e5                	mov    %esp,%ebp
f010068d:	53                   	push   %ebx
f010068e:	83 ec 14             	sub    $0x14,%esp
f0100691:	ba 64 00 00 00       	mov    $0x64,%edx
f0100696:	ec                   	in     (%dx),%al
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f0100697:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f010069c:	a8 01                	test   $0x1,%al
f010069e:	0f 84 d9 00 00 00    	je     f010077d <kbd_proc_data+0xf3>
f01006a4:	b2 60                	mov    $0x60,%dl
f01006a6:	ec                   	in     (%dx),%al
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f01006a7:	3c e0                	cmp    $0xe0,%al
f01006a9:	75 11                	jne    f01006bc <kbd_proc_data+0x32>
		// E0 escape character
		shift |= E0ESC;
f01006ab:	83 0d 20 33 11 f0 40 	orl    $0x40,0xf0113320
f01006b2:	bb 00 00 00 00       	mov    $0x0,%ebx
		return 0;
f01006b7:	e9 c1 00 00 00       	jmp    f010077d <kbd_proc_data+0xf3>
	} else if (data & 0x80) {
f01006bc:	84 c0                	test   %al,%al
f01006be:	79 32                	jns    f01006f2 <kbd_proc_data+0x68>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f01006c0:	8b 15 20 33 11 f0    	mov    0xf0113320,%edx
f01006c6:	f6 c2 40             	test   $0x40,%dl
f01006c9:	75 03                	jne    f01006ce <kbd_proc_data+0x44>
f01006cb:	83 e0 7f             	and    $0x7f,%eax
		shift &= ~(shiftcode[data] | E0ESC);
f01006ce:	0f b6 c0             	movzbl %al,%eax
f01006d1:	0f b6 80 c0 21 10 f0 	movzbl -0xfefde40(%eax),%eax
f01006d8:	83 c8 40             	or     $0x40,%eax
f01006db:	0f b6 c0             	movzbl %al,%eax
f01006de:	f7 d0                	not    %eax
f01006e0:	21 c2                	and    %eax,%edx
f01006e2:	89 15 20 33 11 f0    	mov    %edx,0xf0113320
f01006e8:	bb 00 00 00 00       	mov    $0x0,%ebx
		return 0;
f01006ed:	e9 8b 00 00 00       	jmp    f010077d <kbd_proc_data+0xf3>
	} else if (shift & E0ESC) {
f01006f2:	8b 15 20 33 11 f0    	mov    0xf0113320,%edx
f01006f8:	f6 c2 40             	test   $0x40,%dl
f01006fb:	74 0c                	je     f0100709 <kbd_proc_data+0x7f>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f01006fd:	83 c8 80             	or     $0xffffff80,%eax
		shift &= ~E0ESC;
f0100700:	83 e2 bf             	and    $0xffffffbf,%edx
f0100703:	89 15 20 33 11 f0    	mov    %edx,0xf0113320
	}

	shift |= shiftcode[data];
f0100709:	0f b6 c0             	movzbl %al,%eax
	shift ^= togglecode[data];
f010070c:	0f b6 90 c0 21 10 f0 	movzbl -0xfefde40(%eax),%edx
f0100713:	0b 15 20 33 11 f0    	or     0xf0113320,%edx
f0100719:	0f b6 88 c0 22 10 f0 	movzbl -0xfefdd40(%eax),%ecx
f0100720:	31 ca                	xor    %ecx,%edx
f0100722:	89 15 20 33 11 f0    	mov    %edx,0xf0113320

	c = charcode[shift & (CTL | SHIFT)][data];
f0100728:	89 d1                	mov    %edx,%ecx
f010072a:	83 e1 03             	and    $0x3,%ecx
f010072d:	8b 0c 8d c0 23 10 f0 	mov    -0xfefdc40(,%ecx,4),%ecx
f0100734:	0f b6 1c 01          	movzbl (%ecx,%eax,1),%ebx
	if (shift & CAPSLOCK) {
f0100738:	f6 c2 08             	test   $0x8,%dl
f010073b:	74 1a                	je     f0100757 <kbd_proc_data+0xcd>
		if ('a' <= c && c <= 'z')
f010073d:	89 d9                	mov    %ebx,%ecx
f010073f:	8d 43 9f             	lea    -0x61(%ebx),%eax
f0100742:	83 f8 19             	cmp    $0x19,%eax
f0100745:	77 05                	ja     f010074c <kbd_proc_data+0xc2>
			c += 'A' - 'a';
f0100747:	83 eb 20             	sub    $0x20,%ebx
f010074a:	eb 0b                	jmp    f0100757 <kbd_proc_data+0xcd>
		else if ('A' <= c && c <= 'Z')
f010074c:	83 e9 41             	sub    $0x41,%ecx
f010074f:	83 f9 19             	cmp    $0x19,%ecx
f0100752:	77 03                	ja     f0100757 <kbd_proc_data+0xcd>
			c += 'a' - 'A';
f0100754:	83 c3 20             	add    $0x20,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f0100757:	f7 d2                	not    %edx
f0100759:	f6 c2 06             	test   $0x6,%dl
f010075c:	75 1f                	jne    f010077d <kbd_proc_data+0xf3>
f010075e:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f0100764:	75 17                	jne    f010077d <kbd_proc_data+0xf3>
		cprintf("Rebooting!\n");
f0100766:	c7 04 24 9c 21 10 f0 	movl   $0xf010219c,(%esp)
f010076d:	e8 7d 05 00 00       	call   f0100cef <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100772:	ba 92 00 00 00       	mov    $0x92,%edx
f0100777:	b8 03 00 00 00       	mov    $0x3,%eax
f010077c:	ee                   	out    %al,(%dx)
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f010077d:	89 d8                	mov    %ebx,%eax
f010077f:	83 c4 14             	add    $0x14,%esp
f0100782:	5b                   	pop    %ebx
f0100783:	5d                   	pop    %ebp
f0100784:	c3                   	ret    
	...

f0100790 <rdtsc>:
	cprintf("Kernel executable memory footprint: %dKB\n",
		(end-entry+1023)/1024);
	return 0;
}

static uint64_t rdtsc() {
f0100790:	55                   	push   %ebp
f0100791:	89 e5                	mov    %esp,%ebp
    uint32_t lo,hi;
   __asm__ __volatile__
f0100793:	0f 31                	rdtsc  
   (
      "rdtsc":"=a"(lo),"=d"(hi)
   );
   return (uint64_t) hi<<32|lo;    
}
f0100795:	5d                   	pop    %ebp
f0100796:	c3                   	ret    

f0100797 <read_eip>:
// return EIP of caller.
// does not work if inlined.
// putting at the end of the file seems to prevent inlining.
unsigned
read_eip()
{
f0100797:	55                   	push   %ebp
f0100798:	89 e5                	mov    %esp,%ebp
	uint32_t callerpc;
	__asm __volatile("movl 4(%%ebp), %0" : "=r" (callerpc));
f010079a:	8b 45 04             	mov    0x4(%ebp),%eax
	return callerpc;
}
f010079d:	5d                   	pop    %ebp
f010079e:	c3                   	ret    

f010079f <start_overflow>:
    cprintf("Overflow success\n");
}

void
start_overflow(void)
{
f010079f:	55                   	push   %ebp
f01007a0:	89 e5                	mov    %esp,%ebp
f01007a2:	57                   	push   %edi
f01007a3:	56                   	push   %esi
f01007a4:	53                   	push   %ebx
f01007a5:	81 ec 3c 01 00 00    	sub    $0x13c,%esp
    // you augmented in the "Exercise 9" to do this job.

    // hint: You can use the read_pretaddr function to retrieve 
    //       the pointer to the function call return address;

    char str[256] = {};
f01007ab:	8d bd e8 fe ff ff    	lea    -0x118(%ebp),%edi
f01007b1:	b9 40 00 00 00       	mov    $0x40,%ecx
f01007b6:	b8 00 00 00 00       	mov    $0x0,%eax
f01007bb:	f3 ab                	rep stos %eax,%es:(%edi)
// Lab1 only
// read the pointer to the retaddr on the stack
static uint32_t
read_pretaddr() {
    uint32_t pretaddr;
    __asm __volatile("leal 4(%%ebp), %0" : "=r" (pretaddr)); 
f01007bd:	8d 45 04             	lea    0x4(%ebp),%eax
f01007c0:	89 85 d4 fe ff ff    	mov    %eax,-0x12c(%ebp)
    char str[256] = {};
    int nstr = 0;
    char *pret_addr;
    int i = 0;
    pret_addr = (char*)read_pretaddr();
    uint32_t oldret = *((uint32_t*)pret_addr);
f01007c6:	8b 00                	mov    (%eax),%eax
f01007c8:	89 85 e4 fe ff ff    	mov    %eax,-0x11c(%ebp)
    uint32_t overflowaddr = (uint32_t)do_overflow;
f01007ce:	c7 85 e0 fe ff ff cd 	movl   $0xf01008cd,-0x120(%ebp)
f01007d5:	08 10 f0 
f01007d8:	be 00 00 00 00       	mov    $0x0,%esi
    for(i = 0;i<4;i++){
f01007dd:	bf 00 00 00 00       	mov    $0x0,%edi
       unsigned int j;
       for(j = 0;j<256;j++)
           str[j] = 0;
f01007e2:	8d 9d e8 fe ff ff    	lea    -0x118(%ebp),%ebx
f01007e8:	89 9d d0 fe ff ff    	mov    %ebx,-0x130(%ebp)
f01007ee:	eb 6c                	jmp    f010085c <start_overflow+0xbd>
f01007f0:	c6 04 03 00          	movb   $0x0,(%ebx,%eax,1)
    pret_addr = (char*)read_pretaddr();
    uint32_t oldret = *((uint32_t*)pret_addr);
    uint32_t overflowaddr = (uint32_t)do_overflow;
    for(i = 0;i<4;i++){
       unsigned int j;
       for(j = 0;j<256;j++)
f01007f4:	83 c0 01             	add    $0x1,%eax
f01007f7:	3d 00 01 00 00       	cmp    $0x100,%eax
f01007fc:	75 f2                	jne    f01007f0 <start_overflow+0x51>
{
    cprintf("Overflow success\n");
}

void
start_overflow(void)
f01007fe:	89 f1                	mov    %esi,%ecx
       unsigned int j;
       for(j = 0;j<256;j++)
           str[j] = 0;
       char* addr = (char*)(&overflowaddr);
       unsigned char num = (unsigned char)((*(addr + i)) &0xFF);
       for(j = 0; j<num;j++)
f0100800:	0f b6 94 35 e0 fe ff 	movzbl -0x120(%ebp,%esi,1),%edx
f0100807:	ff 
f0100808:	85 d2                	test   %edx,%edx
f010080a:	74 0d                	je     f0100819 <start_overflow+0x7a>
f010080c:	89 f8                	mov    %edi,%eax
           str[j] = ' ';
f010080e:	c6 04 03 20          	movb   $0x20,(%ebx,%eax,1)
       unsigned int j;
       for(j = 0;j<256;j++)
           str[j] = 0;
       char* addr = (char*)(&overflowaddr);
       unsigned char num = (unsigned char)((*(addr + i)) &0xFF);
       for(j = 0; j<num;j++)
f0100812:	83 c0 01             	add    $0x1,%eax
f0100815:	39 d0                	cmp    %edx,%eax
f0100817:	72 f5                	jb     f010080e <start_overflow+0x6f>
           str[j] = ' ';
       cprintf("%s%n\n",str,pret_addr + i);
f0100819:	03 8d d4 fe ff ff    	add    -0x12c(%ebp),%ecx
f010081f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0100823:	8b 85 d0 fe ff ff    	mov    -0x130(%ebp),%eax
f0100829:	89 44 24 04          	mov    %eax,0x4(%esp)
f010082d:	c7 04 24 d0 23 10 f0 	movl   $0xf01023d0,(%esp)
f0100834:	e8 b6 04 00 00       	call   f0100cef <cprintf>
    char *pret_addr;
    int i = 0;
    pret_addr = (char*)read_pretaddr();
    uint32_t oldret = *((uint32_t*)pret_addr);
    uint32_t overflowaddr = (uint32_t)do_overflow;
    for(i = 0;i<4;i++){
f0100839:	83 c6 01             	add    $0x1,%esi
f010083c:	83 fe 04             	cmp    $0x4,%esi
f010083f:	75 1b                	jne    f010085c <start_overflow+0xbd>
f0100841:	8b bd d4 fe ff ff    	mov    -0x12c(%ebp),%edi
f0100847:	83 c7 04             	add    $0x4,%edi
f010084a:	66 be 00 00          	mov    $0x0,%si
       cprintf("%s%n\n",str,pret_addr + i);
    }
    for(i = 0;i<4;i++){
       unsigned int j;
       for(j = 0;j<256;j++)
           str[j] = 0;
f010084e:	8d 9d e8 fe ff ff    	lea    -0x118(%ebp),%ebx
f0100854:	89 9d d4 fe ff ff    	mov    %ebx,-0x12c(%ebp)
f010085a:	eb 52                	jmp    f01008ae <start_overflow+0x10f>
    char *pret_addr;
    int i = 0;
    pret_addr = (char*)read_pretaddr();
    uint32_t oldret = *((uint32_t*)pret_addr);
    uint32_t overflowaddr = (uint32_t)do_overflow;
    for(i = 0;i<4;i++){
f010085c:	89 f8                	mov    %edi,%eax
f010085e:	eb 90                	jmp    f01007f0 <start_overflow+0x51>
       cprintf("%s%n\n",str,pret_addr + i);
    }
    for(i = 0;i<4;i++){
       unsigned int j;
       for(j = 0;j<256;j++)
           str[j] = 0;
f0100860:	c6 04 03 00          	movb   $0x0,(%ebx,%eax,1)
           str[j] = ' ';
       cprintf("%s%n\n",str,pret_addr + i);
    }
    for(i = 0;i<4;i++){
       unsigned int j;
       for(j = 0;j<256;j++)
f0100864:	83 c0 01             	add    $0x1,%eax
f0100867:	3d 00 01 00 00       	cmp    $0x100,%eax
f010086c:	75 f2                	jne    f0100860 <start_overflow+0xc1>
           str[j] = 0;
       char* addr = (char*)(&oldret);
       unsigned char num = (unsigned char)((*(addr + i))&0xFF);
       for(j = 0; j<num;j++)
f010086e:	0f b6 94 35 e4 fe ff 	movzbl -0x11c(%ebp,%esi,1),%edx
f0100875:	ff 
f0100876:	85 d2                	test   %edx,%edx
f0100878:	74 0f                	je     f0100889 <start_overflow+0xea>
f010087a:	66 b8 00 00          	mov    $0x0,%ax
           str[j] = ' ';
f010087e:	c6 04 03 20          	movb   $0x20,(%ebx,%eax,1)
       unsigned int j;
       for(j = 0;j<256;j++)
           str[j] = 0;
       char* addr = (char*)(&oldret);
       unsigned char num = (unsigned char)((*(addr + i))&0xFF);
       for(j = 0; j<num;j++)
f0100882:	83 c0 01             	add    $0x1,%eax
f0100885:	39 d0                	cmp    %edx,%eax
f0100887:	72 f5                	jb     f010087e <start_overflow+0xdf>
           str[j] = ' ';
       cprintf("%s%n\n",str,pret_addr + 4 + i);
f0100889:	89 7c 24 08          	mov    %edi,0x8(%esp)
f010088d:	8b 95 d4 fe ff ff    	mov    -0x12c(%ebp),%edx
f0100893:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100897:	c7 04 24 d0 23 10 f0 	movl   $0xf01023d0,(%esp)
f010089e:	e8 4c 04 00 00       	call   f0100cef <cprintf>
       unsigned char num = (unsigned char)((*(addr + i)) &0xFF);
       for(j = 0; j<num;j++)
           str[j] = ' ';
       cprintf("%s%n\n",str,pret_addr + i);
    }
    for(i = 0;i<4;i++){
f01008a3:	83 c6 01             	add    $0x1,%esi
f01008a6:	83 c7 01             	add    $0x1,%edi
f01008a9:	83 fe 04             	cmp    $0x4,%esi
f01008ac:	74 07                	je     f01008b5 <start_overflow+0x116>
f01008ae:	b8 00 00 00 00       	mov    $0x0,%eax
f01008b3:	eb ab                	jmp    f0100860 <start_overflow+0xc1>
       cprintf("%s%n\n",str,pret_addr + 4 + i);
    }
    

	// Your code here.
}
f01008b5:	81 c4 3c 01 00 00    	add    $0x13c,%esp
f01008bb:	5b                   	pop    %ebx
f01008bc:	5e                   	pop    %esi
f01008bd:	5f                   	pop    %edi
f01008be:	5d                   	pop    %ebp
f01008bf:	c3                   	ret    

f01008c0 <overflow_me>:

void
overflow_me(void)
{
f01008c0:	55                   	push   %ebp
f01008c1:	89 e5                	mov    %esp,%ebp
f01008c3:	83 ec 08             	sub    $0x8,%esp
        start_overflow();
f01008c6:	e8 d4 fe ff ff       	call   f010079f <start_overflow>
}
f01008cb:	c9                   	leave  
f01008cc:	c3                   	ret    

f01008cd <do_overflow>:
    
}

void
do_overflow(void)
{
f01008cd:	55                   	push   %ebp
f01008ce:	89 e5                	mov    %esp,%ebp
f01008d0:	83 ec 18             	sub    $0x18,%esp
    cprintf("Overflow success\n");
f01008d3:	c7 04 24 d6 23 10 f0 	movl   $0xf01023d6,(%esp)
f01008da:	e8 10 04 00 00       	call   f0100cef <cprintf>
}
f01008df:	c9                   	leave  
f01008e0:	c3                   	ret    

f01008e1 <mon_kerninfo>:
	return 0;
}

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01008e1:	55                   	push   %ebp
f01008e2:	89 e5                	mov    %esp,%ebp
f01008e4:	83 ec 18             	sub    $0x18,%esp
	extern char entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01008e7:	c7 04 24 e8 23 10 f0 	movl   $0xf01023e8,(%esp)
f01008ee:	e8 fc 03 00 00       	call   f0100cef <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01008f3:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f01008fa:	00 
f01008fb:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f0100902:	f0 
f0100903:	c7 04 24 fc 24 10 f0 	movl   $0xf01024fc,(%esp)
f010090a:	e8 e0 03 00 00       	call   f0100cef <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f010090f:	c7 44 24 08 65 20 10 	movl   $0x102065,0x8(%esp)
f0100916:	00 
f0100917:	c7 44 24 04 65 20 10 	movl   $0xf0102065,0x4(%esp)
f010091e:	f0 
f010091f:	c7 04 24 20 25 10 f0 	movl   $0xf0102520,(%esp)
f0100926:	e8 c4 03 00 00       	call   f0100cef <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f010092b:	c7 44 24 08 00 33 11 	movl   $0x113300,0x8(%esp)
f0100932:	00 
f0100933:	c7 44 24 04 00 33 11 	movl   $0xf0113300,0x4(%esp)
f010093a:	f0 
f010093b:	c7 04 24 44 25 10 f0 	movl   $0xf0102544,(%esp)
f0100942:	e8 a8 03 00 00       	call   f0100cef <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100947:	c7 44 24 08 60 39 11 	movl   $0x113960,0x8(%esp)
f010094e:	00 
f010094f:	c7 44 24 04 60 39 11 	movl   $0xf0113960,0x4(%esp)
f0100956:	f0 
f0100957:	c7 04 24 68 25 10 f0 	movl   $0xf0102568,(%esp)
f010095e:	e8 8c 03 00 00       	call   f0100cef <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100963:	b8 5f 3d 11 f0       	mov    $0xf0113d5f,%eax
f0100968:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
f010096d:	89 c2                	mov    %eax,%edx
f010096f:	c1 fa 1f             	sar    $0x1f,%edx
f0100972:	c1 ea 16             	shr    $0x16,%edx
f0100975:	8d 04 02             	lea    (%edx,%eax,1),%eax
f0100978:	c1 f8 0a             	sar    $0xa,%eax
f010097b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010097f:	c7 04 24 8c 25 10 f0 	movl   $0xf010258c,(%esp)
f0100986:	e8 64 03 00 00       	call   f0100cef <cprintf>
		(end-entry+1023)/1024);
	return 0;
}
f010098b:	b8 00 00 00 00       	mov    $0x0,%eax
f0100990:	c9                   	leave  
f0100991:	c3                   	ret    

f0100992 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100992:	55                   	push   %ebp
f0100993:	89 e5                	mov    %esp,%ebp
f0100995:	83 ec 18             	sub    $0x18,%esp
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100998:	a1 44 26 10 f0       	mov    0xf0102644,%eax
f010099d:	89 44 24 08          	mov    %eax,0x8(%esp)
f01009a1:	a1 40 26 10 f0       	mov    0xf0102640,%eax
f01009a6:	89 44 24 04          	mov    %eax,0x4(%esp)
f01009aa:	c7 04 24 01 24 10 f0 	movl   $0xf0102401,(%esp)
f01009b1:	e8 39 03 00 00       	call   f0100cef <cprintf>
f01009b6:	a1 50 26 10 f0       	mov    0xf0102650,%eax
f01009bb:	89 44 24 08          	mov    %eax,0x8(%esp)
f01009bf:	a1 4c 26 10 f0       	mov    0xf010264c,%eax
f01009c4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01009c8:	c7 04 24 01 24 10 f0 	movl   $0xf0102401,(%esp)
f01009cf:	e8 1b 03 00 00       	call   f0100cef <cprintf>
f01009d4:	a1 5c 26 10 f0       	mov    0xf010265c,%eax
f01009d9:	89 44 24 08          	mov    %eax,0x8(%esp)
f01009dd:	a1 58 26 10 f0       	mov    0xf0102658,%eax
f01009e2:	89 44 24 04          	mov    %eax,0x4(%esp)
f01009e6:	c7 04 24 01 24 10 f0 	movl   $0xf0102401,(%esp)
f01009ed:	e8 fd 02 00 00       	call   f0100cef <cprintf>
	return 0;
}
f01009f2:	b8 00 00 00 00       	mov    $0x0,%eax
f01009f7:	c9                   	leave  
f01009f8:	c3                   	ret    

f01009f9 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f01009f9:	55                   	push   %ebp
f01009fa:	89 e5                	mov    %esp,%ebp
f01009fc:	57                   	push   %edi
f01009fd:	56                   	push   %esi
f01009fe:	53                   	push   %ebx
f01009ff:	83 ec 5c             	sub    $0x5c,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100a02:	c7 04 24 b8 25 10 f0 	movl   $0xf01025b8,(%esp)
f0100a09:	e8 e1 02 00 00       	call   f0100cef <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100a0e:	c7 04 24 dc 25 10 f0 	movl   $0xf01025dc,(%esp)
f0100a15:	e8 d5 02 00 00       	call   f0100cef <cprintf>


	while (1) {
		buf = readline("K> ");
f0100a1a:	c7 04 24 0a 24 10 f0 	movl   $0xf010240a,(%esp)
f0100a21:	e8 ea 0e 00 00       	call   f0101910 <readline>
f0100a26:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100a28:	85 c0                	test   %eax,%eax
f0100a2a:	74 ee                	je     f0100a1a <monitor+0x21>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f0100a2c:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
f0100a33:	be 00 00 00 00       	mov    $0x0,%esi
f0100a38:	eb 06                	jmp    f0100a40 <monitor+0x47>
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100a3a:	c6 03 00             	movb   $0x0,(%ebx)
f0100a3d:	83 c3 01             	add    $0x1,%ebx
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f0100a40:	0f b6 03             	movzbl (%ebx),%eax
f0100a43:	84 c0                	test   %al,%al
f0100a45:	74 6a                	je     f0100ab1 <monitor+0xb8>
f0100a47:	0f be c0             	movsbl %al,%eax
f0100a4a:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100a4e:	c7 04 24 0e 24 10 f0 	movl   $0xf010240e,(%esp)
f0100a55:	e8 e4 10 00 00       	call   f0101b3e <strchr>
f0100a5a:	85 c0                	test   %eax,%eax
f0100a5c:	75 dc                	jne    f0100a3a <monitor+0x41>
			*buf++ = 0;
		if (*buf == 0)
f0100a5e:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100a61:	74 4e                	je     f0100ab1 <monitor+0xb8>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f0100a63:	83 fe 0f             	cmp    $0xf,%esi
f0100a66:	75 16                	jne    f0100a7e <monitor+0x85>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100a68:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f0100a6f:	00 
f0100a70:	c7 04 24 13 24 10 f0 	movl   $0xf0102413,(%esp)
f0100a77:	e8 73 02 00 00       	call   f0100cef <cprintf>
f0100a7c:	eb 9c                	jmp    f0100a1a <monitor+0x21>
			return 0;
		}
		argv[argc++] = buf;
f0100a7e:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f0100a82:	83 c6 01             	add    $0x1,%esi
		while (*buf && !strchr(WHITESPACE, *buf))
f0100a85:	0f b6 03             	movzbl (%ebx),%eax
f0100a88:	84 c0                	test   %al,%al
f0100a8a:	75 0c                	jne    f0100a98 <monitor+0x9f>
f0100a8c:	eb b2                	jmp    f0100a40 <monitor+0x47>
			buf++;
f0100a8e:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f0100a91:	0f b6 03             	movzbl (%ebx),%eax
f0100a94:	84 c0                	test   %al,%al
f0100a96:	74 a8                	je     f0100a40 <monitor+0x47>
f0100a98:	0f be c0             	movsbl %al,%eax
f0100a9b:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100a9f:	c7 04 24 0e 24 10 f0 	movl   $0xf010240e,(%esp)
f0100aa6:	e8 93 10 00 00       	call   f0101b3e <strchr>
f0100aab:	85 c0                	test   %eax,%eax
f0100aad:	74 df                	je     f0100a8e <monitor+0x95>
f0100aaf:	eb 8f                	jmp    f0100a40 <monitor+0x47>
			buf++;
	}
	argv[argc] = 0;
f0100ab1:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100ab8:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100ab9:	85 f6                	test   %esi,%esi
f0100abb:	0f 84 59 ff ff ff    	je     f0100a1a <monitor+0x21>
f0100ac1:	bb 40 26 10 f0       	mov    $0xf0102640,%ebx
f0100ac6:	bf 00 00 00 00       	mov    $0x0,%edi
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100acb:	8b 03                	mov    (%ebx),%eax
f0100acd:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100ad1:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100ad4:	89 04 24             	mov    %eax,(%esp)
f0100ad7:	e8 ed 0f 00 00       	call   f0101ac9 <strcmp>
f0100adc:	85 c0                	test   %eax,%eax
f0100ade:	75 23                	jne    f0100b03 <monitor+0x10a>
			return commands[i].func(argc, argv, tf);
f0100ae0:	6b ff 0c             	imul   $0xc,%edi,%edi
f0100ae3:	8b 45 08             	mov    0x8(%ebp),%eax
f0100ae6:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100aea:	8d 45 a8             	lea    -0x58(%ebp),%eax
f0100aed:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100af1:	89 34 24             	mov    %esi,(%esp)
f0100af4:	ff 97 48 26 10 f0    	call   *-0xfefd9b8(%edi)


	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100afa:	85 c0                	test   %eax,%eax
f0100afc:	78 28                	js     f0100b26 <monitor+0x12d>
f0100afe:	e9 17 ff ff ff       	jmp    f0100a1a <monitor+0x21>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f0100b03:	83 c7 01             	add    $0x1,%edi
f0100b06:	83 c3 0c             	add    $0xc,%ebx
f0100b09:	83 ff 03             	cmp    $0x3,%edi
f0100b0c:	75 bd                	jne    f0100acb <monitor+0xd2>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100b0e:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100b11:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100b15:	c7 04 24 30 24 10 f0 	movl   $0xf0102430,(%esp)
f0100b1c:	e8 ce 01 00 00       	call   f0100cef <cprintf>
f0100b21:	e9 f4 fe ff ff       	jmp    f0100a1a <monitor+0x21>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0100b26:	83 c4 5c             	add    $0x5c,%esp
f0100b29:	5b                   	pop    %ebx
f0100b2a:	5e                   	pop    %esi
f0100b2b:	5f                   	pop    %edi
f0100b2c:	5d                   	pop    %ebp
f0100b2d:	c3                   	ret    

f0100b2e <mon_time>:
   return (uint64_t) hi<<32|lo;    
}

int 
mon_time(int argc, char**argv,struct Trapframe *tf)
{
f0100b2e:	55                   	push   %ebp
f0100b2f:	89 e5                	mov    %esp,%ebp
f0100b31:	57                   	push   %edi
f0100b32:	56                   	push   %esi
f0100b33:	53                   	push   %ebx
f0100b34:	83 ec 3c             	sub    $0x3c,%esp
f0100b37:	be 40 26 10 f0       	mov    $0xf0102640,%esi
f0100b3c:	bf 00 00 00 00       	mov    $0x0,%edi
   int ret;
   int flag = 0;
   uint64_t begin;
   uint64_t end;
   for(i = 0;i<NCOMMANDS;i++){
       if(strcmp(argv[1],commands[i].name) == 0){
f0100b41:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0100b44:	83 c3 04             	add    $0x4,%ebx
f0100b47:	8b 06                	mov    (%esi),%eax
f0100b49:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0100b4c:	89 5d e0             	mov    %ebx,-0x20(%ebp)
f0100b4f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100b53:	8b 03                	mov    (%ebx),%eax
f0100b55:	89 04 24             	mov    %eax,(%esp)
f0100b58:	e8 6c 0f 00 00       	call   f0101ac9 <strcmp>
f0100b5d:	85 c0                	test   %eax,%eax
f0100b5f:	75 51                	jne    f0100bb2 <mon_time+0x84>
          begin = rdtsc();
f0100b61:	e8 2a fc ff ff       	call   f0100790 <rdtsc>
f0100b66:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100b69:	89 55 d4             	mov    %edx,-0x2c(%ebp)
          ret = (commands[i].func)(argc-1,&argv[1],tf);
f0100b6c:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f0100b6f:	8b 55 10             	mov    0x10(%ebp),%edx
f0100b72:	89 54 24 08          	mov    %edx,0x8(%esp)
f0100b76:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100b7a:	8b 55 08             	mov    0x8(%ebp),%edx
f0100b7d:	83 ea 01             	sub    $0x1,%edx
f0100b80:	89 14 24             	mov    %edx,(%esp)
f0100b83:	ff 14 85 48 26 10 f0 	call   *-0xfefd9b8(,%eax,4)
          end = rdtsc();
f0100b8a:	e8 01 fc ff ff       	call   f0100790 <rdtsc>
          cprintf("%s cycles: %d\n",commands[i].name,end-begin);
f0100b8f:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0100b92:	1b 55 d4             	sbb    -0x2c(%ebp),%edx
f0100b95:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100b99:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0100b9d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0100ba0:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100ba4:	c7 04 24 46 24 10 f0 	movl   $0xf0102446,(%esp)
f0100bab:	e8 3f 01 00 00       	call   f0100cef <cprintf>
f0100bb0:	eb 10                	jmp    f0100bc2 <mon_time+0x94>
   int i;
   int ret;
   int flag = 0;
   uint64_t begin;
   uint64_t end;
   for(i = 0;i<NCOMMANDS;i++){
f0100bb2:	83 c7 01             	add    $0x1,%edi
f0100bb5:	83 c6 0c             	add    $0xc,%esi
f0100bb8:	83 ff 03             	cmp    $0x3,%edi
f0100bbb:	75 8a                	jne    f0100b47 <mon_time+0x19>
f0100bbd:	8d 76 00             	lea    0x0(%esi),%esi
f0100bc0:	eb 0d                	jmp    f0100bcf <mon_time+0xa1>
       }
   }
   if(flag == 0)
     cprintf("no such command %s\n",argv[1]);
   return 0;
}
f0100bc2:	b8 00 00 00 00       	mov    $0x0,%eax
f0100bc7:	83 c4 3c             	add    $0x3c,%esp
f0100bca:	5b                   	pop    %ebx
f0100bcb:	5e                   	pop    %esi
f0100bcc:	5f                   	pop    %edi
f0100bcd:	5d                   	pop    %ebp
f0100bce:	c3                   	ret    
          flag = 1;
          break;
       }
   }
   if(flag == 0)
     cprintf("no such command %s\n",argv[1]);
f0100bcf:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0100bd2:	8b 01                	mov    (%ecx),%eax
f0100bd4:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100bd8:	c7 04 24 55 24 10 f0 	movl   $0xf0102455,(%esp)
f0100bdf:	e8 0b 01 00 00       	call   f0100cef <cprintf>
f0100be4:	eb dc                	jmp    f0100bc2 <mon_time+0x94>

f0100be6 <mon_backtrace>:
        start_overflow();
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f0100be6:	55                   	push   %ebp
f0100be7:	89 e5                	mov    %esp,%ebp
f0100be9:	57                   	push   %edi
f0100bea:	56                   	push   %esi
f0100beb:	53                   	push   %ebx
f0100bec:	83 ec 4c             	sub    $0x4c,%esp
	// Your code here.
    overflow_me();
f0100bef:	e8 cc fc ff ff       	call   f01008c0 <overflow_me>
    cprintf("Stack backtrace:\n");
f0100bf4:	c7 04 24 69 24 10 f0 	movl   $0xf0102469,(%esp)
f0100bfb:	e8 ef 00 00 00       	call   f0100cef <cprintf>
    uint32_t* ebp = (uint32_t*)read_ebp();
f0100c00:	89 ee                	mov    %ebp,%esi
    struct Eipdebuginfo info;
    while(ebp != 0){
f0100c02:	85 f6                	test   %esi,%esi
f0100c04:	0f 84 97 00 00 00    	je     f0100ca1 <mon_backtrace+0xbb>
    int i = 0;
    cprintf("eip %08x  ebp %08x  ",ebp[1],ebp);
f0100c0a:	8d 7e 04             	lea    0x4(%esi),%edi
f0100c0d:	89 74 24 08          	mov    %esi,0x8(%esp)
f0100c11:	8b 07                	mov    (%edi),%eax
f0100c13:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100c17:	c7 04 24 7b 24 10 f0 	movl   $0xf010247b,(%esp)
f0100c1e:	e8 cc 00 00 00       	call   f0100cef <cprintf>
    debuginfo_eip(ebp[1],&info);
f0100c23:	8d 45 d0             	lea    -0x30(%ebp),%eax
f0100c26:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100c2a:	8b 07                	mov    (%edi),%eax
f0100c2c:	89 04 24             	mov    %eax,(%esp)
f0100c2f:	e8 2a 02 00 00       	call   f0100e5e <debuginfo_eip>
    cprintf("args ");
f0100c34:	c7 04 24 90 24 10 f0 	movl   $0xf0102490,(%esp)
f0100c3b:	e8 af 00 00 00       	call   f0100cef <cprintf>
f0100c40:	bb 00 00 00 00       	mov    $0x0,%ebx
    for(i = 0; i< 5;i++){
       cprintf("%08x ",ebp[i+2]);
f0100c45:	8b 44 9e 08          	mov    0x8(%esi,%ebx,4),%eax
f0100c49:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100c4d:	c7 04 24 96 24 10 f0 	movl   $0xf0102496,(%esp)
f0100c54:	e8 96 00 00 00       	call   f0100cef <cprintf>
    while(ebp != 0){
    int i = 0;
    cprintf("eip %08x  ebp %08x  ",ebp[1],ebp);
    debuginfo_eip(ebp[1],&info);
    cprintf("args ");
    for(i = 0; i< 5;i++){
f0100c59:	83 c3 01             	add    $0x1,%ebx
f0100c5c:	83 fb 05             	cmp    $0x5,%ebx
f0100c5f:	75 e4                	jne    f0100c45 <mon_backtrace+0x5f>
       cprintf("%08x ",ebp[i+2]);
    }
    cprintf("\n");
f0100c61:	c7 04 24 a6 21 10 f0 	movl   $0xf01021a6,(%esp)
f0100c68:	e8 82 00 00 00       	call   f0100cef <cprintf>
    cprintf("\t%s:%d: %s+%d\n",info.eip_file,info.eip_line,info.eip_fn_name,ebp[1]-info.eip_fn_addr);
f0100c6d:	8b 07                	mov    (%edi),%eax
f0100c6f:	2b 45 e0             	sub    -0x20(%ebp),%eax
f0100c72:	89 44 24 10          	mov    %eax,0x10(%esp)
f0100c76:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100c79:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100c7d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100c80:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100c84:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0100c87:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100c8b:	c7 04 24 9c 24 10 f0 	movl   $0xf010249c,(%esp)
f0100c92:	e8 58 00 00 00       	call   f0100cef <cprintf>
    ebp = (uint32_t*)(*(ebp));
f0100c97:	8b 36                	mov    (%esi),%esi
	// Your code here.
    overflow_me();
    cprintf("Stack backtrace:\n");
    uint32_t* ebp = (uint32_t*)read_ebp();
    struct Eipdebuginfo info;
    while(ebp != 0){
f0100c99:	85 f6                	test   %esi,%esi
f0100c9b:	0f 85 69 ff ff ff    	jne    f0100c0a <mon_backtrace+0x24>
    }
    cprintf("\n");
    cprintf("\t%s:%d: %s+%d\n",info.eip_file,info.eip_line,info.eip_fn_name,ebp[1]-info.eip_fn_addr);
    ebp = (uint32_t*)(*(ebp));
    }
    cprintf("Backtrace success\n");
f0100ca1:	c7 04 24 ab 24 10 f0 	movl   $0xf01024ab,(%esp)
f0100ca8:	e8 42 00 00 00       	call   f0100cef <cprintf>
    return 0;
}
f0100cad:	b8 00 00 00 00       	mov    $0x0,%eax
f0100cb2:	83 c4 4c             	add    $0x4c,%esp
f0100cb5:	5b                   	pop    %ebx
f0100cb6:	5e                   	pop    %esi
f0100cb7:	5f                   	pop    %edi
f0100cb8:	5d                   	pop    %ebp
f0100cb9:	c3                   	ret    
	...

f0100cbc <vcprintf>:
    (*cnt)++;
}

int
vcprintf(const char *fmt, va_list ap)
{
f0100cbc:	55                   	push   %ebp
f0100cbd:	89 e5                	mov    %esp,%ebp
f0100cbf:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f0100cc2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0100cc9:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100ccc:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100cd0:	8b 45 08             	mov    0x8(%ebp),%eax
f0100cd3:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100cd7:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0100cda:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100cde:	c7 04 24 09 0d 10 f0 	movl   $0xf0100d09,(%esp)
f0100ce5:	e8 f2 04 00 00       	call   f01011dc <vprintfmt>
	return cnt;
}
f0100cea:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100ced:	c9                   	leave  
f0100cee:	c3                   	ret    

f0100cef <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0100cef:	55                   	push   %ebp
f0100cf0:	89 e5                	mov    %esp,%ebp
f0100cf2:	83 ec 18             	sub    $0x18,%esp
	vprintfmt((void*)putch, &cnt, fmt, ap);
	return cnt;
}

int
cprintf(const char *fmt, ...)
f0100cf5:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
f0100cf8:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100cfc:	8b 45 08             	mov    0x8(%ebp),%eax
f0100cff:	89 04 24             	mov    %eax,(%esp)
f0100d02:	e8 b5 ff ff ff       	call   f0100cbc <vcprintf>
	va_end(ap);

	return cnt;
}
f0100d07:	c9                   	leave  
f0100d08:	c3                   	ret    

f0100d09 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0100d09:	55                   	push   %ebp
f0100d0a:	89 e5                	mov    %esp,%ebp
f0100d0c:	53                   	push   %ebx
f0100d0d:	83 ec 14             	sub    $0x14,%esp
f0100d10:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	cputchar(ch);
f0100d13:	8b 45 08             	mov    0x8(%ebp),%eax
f0100d16:	89 04 24             	mov    %eax,(%esp)
f0100d19:	e8 6c f8 ff ff       	call   f010058a <cputchar>
    (*cnt)++;
f0100d1e:	83 03 01             	addl   $0x1,(%ebx)
}
f0100d21:	83 c4 14             	add    $0x14,%esp
f0100d24:	5b                   	pop    %ebx
f0100d25:	5d                   	pop    %ebp
f0100d26:	c3                   	ret    
	...

f0100d30 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0100d30:	55                   	push   %ebp
f0100d31:	89 e5                	mov    %esp,%ebp
f0100d33:	57                   	push   %edi
f0100d34:	56                   	push   %esi
f0100d35:	53                   	push   %ebx
f0100d36:	83 ec 14             	sub    $0x14,%esp
f0100d39:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100d3c:	89 55 e8             	mov    %edx,-0x18(%ebp)
f0100d3f:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0100d42:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0100d45:	8b 1a                	mov    (%edx),%ebx
f0100d47:	8b 01                	mov    (%ecx),%eax
f0100d49:	89 45 ec             	mov    %eax,-0x14(%ebp)
	
	while (l <= r) {
f0100d4c:	39 c3                	cmp    %eax,%ebx
f0100d4e:	0f 8f 9c 00 00 00    	jg     f0100df0 <stab_binsearch+0xc0>
f0100d54:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
		int true_m = (l + r) / 2, m = true_m;
f0100d5b:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0100d5e:	01 d8                	add    %ebx,%eax
f0100d60:	89 c7                	mov    %eax,%edi
f0100d62:	c1 ef 1f             	shr    $0x1f,%edi
f0100d65:	01 c7                	add    %eax,%edi
f0100d67:	d1 ff                	sar    %edi
		
		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0100d69:	39 df                	cmp    %ebx,%edi
f0100d6b:	7c 33                	jl     f0100da0 <stab_binsearch+0x70>
f0100d6d:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f0100d70:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0100d73:	0f b6 44 82 04       	movzbl 0x4(%edx,%eax,4),%eax
f0100d78:	39 f0                	cmp    %esi,%eax
f0100d7a:	0f 84 bc 00 00 00    	je     f0100e3c <stab_binsearch+0x10c>
f0100d80:	8d 44 7f fd          	lea    -0x3(%edi,%edi,2),%eax
f0100d84:	8d 54 82 04          	lea    0x4(%edx,%eax,4),%edx
f0100d88:	89 f8                	mov    %edi,%eax
			m--;
f0100d8a:	83 e8 01             	sub    $0x1,%eax
	
	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
		
		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0100d8d:	39 d8                	cmp    %ebx,%eax
f0100d8f:	7c 0f                	jl     f0100da0 <stab_binsearch+0x70>
f0100d91:	0f b6 0a             	movzbl (%edx),%ecx
f0100d94:	83 ea 0c             	sub    $0xc,%edx
f0100d97:	39 f1                	cmp    %esi,%ecx
f0100d99:	75 ef                	jne    f0100d8a <stab_binsearch+0x5a>
f0100d9b:	e9 9e 00 00 00       	jmp    f0100e3e <stab_binsearch+0x10e>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0100da0:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f0100da3:	eb 3c                	jmp    f0100de1 <stab_binsearch+0xb1>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f0100da5:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0100da8:	89 01                	mov    %eax,(%ecx)
			l = true_m + 1;
f0100daa:	8d 5f 01             	lea    0x1(%edi),%ebx
f0100dad:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f0100db4:	eb 2b                	jmp    f0100de1 <stab_binsearch+0xb1>
		} else if (stabs[m].n_value > addr) {
f0100db6:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0100db9:	76 14                	jbe    f0100dcf <stab_binsearch+0x9f>
			*region_right = m - 1;
f0100dbb:	83 e8 01             	sub    $0x1,%eax
f0100dbe:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0100dc1:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0100dc4:	89 02                	mov    %eax,(%edx)
f0100dc6:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f0100dcd:	eb 12                	jmp    f0100de1 <stab_binsearch+0xb1>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0100dcf:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0100dd2:	89 01                	mov    %eax,(%ecx)
			l = m;
			addr++;
f0100dd4:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0100dd8:	89 c3                	mov    %eax,%ebx
f0100dda:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;
	
	while (l <= r) {
f0100de1:	39 5d ec             	cmp    %ebx,-0x14(%ebp)
f0100de4:	0f 8d 71 ff ff ff    	jge    f0100d5b <stab_binsearch+0x2b>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0100dea:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0100dee:	75 0f                	jne    f0100dff <stab_binsearch+0xcf>
		*region_right = *region_left - 1;
f0100df0:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f0100df3:	8b 03                	mov    (%ebx),%eax
f0100df5:	83 e8 01             	sub    $0x1,%eax
f0100df8:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0100dfb:	89 02                	mov    %eax,(%edx)
f0100dfd:	eb 57                	jmp    f0100e56 <stab_binsearch+0x126>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100dff:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0100e02:	8b 01                	mov    (%ecx),%eax
		     l > *region_left && stabs[l].n_type != type;
f0100e04:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f0100e07:	8b 0b                	mov    (%ebx),%ecx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100e09:	39 c1                	cmp    %eax,%ecx
f0100e0b:	7d 28                	jge    f0100e35 <stab_binsearch+0x105>
		     l > *region_left && stabs[l].n_type != type;
f0100e0d:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100e10:	8b 5d f0             	mov    -0x10(%ebp),%ebx
f0100e13:	0f b6 54 93 04       	movzbl 0x4(%ebx,%edx,4),%edx
f0100e18:	39 f2                	cmp    %esi,%edx
f0100e1a:	74 19                	je     f0100e35 <stab_binsearch+0x105>
f0100e1c:	8d 54 40 fd          	lea    -0x3(%eax,%eax,2),%edx
f0100e20:	8d 54 93 04          	lea    0x4(%ebx,%edx,4),%edx
		     l--)
f0100e24:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100e27:	39 c1                	cmp    %eax,%ecx
f0100e29:	7d 0a                	jge    f0100e35 <stab_binsearch+0x105>
		     l > *region_left && stabs[l].n_type != type;
f0100e2b:	0f b6 1a             	movzbl (%edx),%ebx
f0100e2e:	83 ea 0c             	sub    $0xc,%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100e31:	39 f3                	cmp    %esi,%ebx
f0100e33:	75 ef                	jne    f0100e24 <stab_binsearch+0xf4>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
f0100e35:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0100e38:	89 02                	mov    %eax,(%edx)
f0100e3a:	eb 1a                	jmp    f0100e56 <stab_binsearch+0x126>
	}
}
f0100e3c:	89 f8                	mov    %edi,%eax
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0100e3e:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100e41:	8b 4d f0             	mov    -0x10(%ebp),%ecx
f0100e44:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0100e48:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0100e4b:	0f 82 54 ff ff ff    	jb     f0100da5 <stab_binsearch+0x75>
f0100e51:	e9 60 ff ff ff       	jmp    f0100db6 <stab_binsearch+0x86>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f0100e56:	83 c4 14             	add    $0x14,%esp
f0100e59:	5b                   	pop    %ebx
f0100e5a:	5e                   	pop    %esi
f0100e5b:	5f                   	pop    %edi
f0100e5c:	5d                   	pop    %ebp
f0100e5d:	c3                   	ret    

f0100e5e <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0100e5e:	55                   	push   %ebp
f0100e5f:	89 e5                	mov    %esp,%ebp
f0100e61:	83 ec 48             	sub    $0x48,%esp
f0100e64:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0100e67:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0100e6a:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0100e6d:	8b 75 08             	mov    0x8(%ebp),%esi
f0100e70:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0100e73:	c7 03 64 26 10 f0    	movl   $0xf0102664,(%ebx)
	info->eip_line = 0;
f0100e79:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0100e80:	c7 43 08 64 26 10 f0 	movl   $0xf0102664,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0100e87:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0100e8e:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0100e91:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0100e98:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0100e9e:	76 12                	jbe    f0100eb2 <debuginfo_eip+0x54>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100ea0:	b8 3b 86 10 f0       	mov    $0xf010863b,%eax
f0100ea5:	3d a1 6a 10 f0       	cmp    $0xf0106aa1,%eax
f0100eaa:	0f 86 a2 01 00 00    	jbe    f0101052 <debuginfo_eip+0x1f4>
f0100eb0:	eb 1c                	jmp    f0100ece <debuginfo_eip+0x70>
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
	} else {
		// Can't search for user-level addresses yet!
  	        panic("User address");
f0100eb2:	c7 44 24 08 6e 26 10 	movl   $0xf010266e,0x8(%esp)
f0100eb9:	f0 
f0100eba:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
f0100ec1:	00 
f0100ec2:	c7 04 24 7b 26 10 f0 	movl   $0xf010267b,(%esp)
f0100ec9:	e8 b7 f1 ff ff       	call   f0100085 <_panic>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100ece:	80 3d 3a 86 10 f0 00 	cmpb   $0x0,0xf010863a
f0100ed5:	0f 85 77 01 00 00    	jne    f0101052 <debuginfo_eip+0x1f4>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.
	
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0100edb:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0100ee2:	b8 a0 6a 10 f0       	mov    $0xf0106aa0,%eax
f0100ee7:	2d 18 29 10 f0       	sub    $0xf0102918,%eax
f0100eec:	c1 f8 02             	sar    $0x2,%eax
f0100eef:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0100ef5:	83 e8 01             	sub    $0x1,%eax
f0100ef8:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0100efb:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0100efe:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0100f01:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100f05:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f0100f0c:	b8 18 29 10 f0       	mov    $0xf0102918,%eax
f0100f11:	e8 1a fe ff ff       	call   f0100d30 <stab_binsearch>
	if (lfile == 0)
f0100f16:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100f19:	85 c0                	test   %eax,%eax
f0100f1b:	0f 84 31 01 00 00    	je     f0101052 <debuginfo_eip+0x1f4>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0100f21:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0100f24:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100f27:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0100f2a:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0100f2d:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100f30:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100f34:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f0100f3b:	b8 18 29 10 f0       	mov    $0xf0102918,%eax
f0100f40:	e8 eb fd ff ff       	call   f0100d30 <stab_binsearch>

	if (lfun <= rfun) {
f0100f45:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100f48:	3b 45 d8             	cmp    -0x28(%ebp),%eax
f0100f4b:	7f 3c                	jg     f0100f89 <debuginfo_eip+0x12b>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0100f4d:	6b c0 0c             	imul   $0xc,%eax,%eax
f0100f50:	8b 80 18 29 10 f0    	mov    -0xfefd6e8(%eax),%eax
f0100f56:	ba 3b 86 10 f0       	mov    $0xf010863b,%edx
f0100f5b:	81 ea a1 6a 10 f0    	sub    $0xf0106aa1,%edx
f0100f61:	39 d0                	cmp    %edx,%eax
f0100f63:	73 08                	jae    f0100f6d <debuginfo_eip+0x10f>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0100f65:	05 a1 6a 10 f0       	add    $0xf0106aa1,%eax
f0100f6a:	89 43 08             	mov    %eax,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0100f6d:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100f70:	6b d0 0c             	imul   $0xc,%eax,%edx
f0100f73:	8b 92 20 29 10 f0    	mov    -0xfefd6e0(%edx),%edx
f0100f79:	89 53 10             	mov    %edx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0100f7c:	29 d6                	sub    %edx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f0100f7e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0100f81:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100f84:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100f87:	eb 0f                	jmp    f0100f98 <debuginfo_eip+0x13a>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0100f89:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0100f8c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100f8f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0100f92:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100f95:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0100f98:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f0100f9f:	00 
f0100fa0:	8b 43 08             	mov    0x8(%ebx),%eax
f0100fa3:	89 04 24             	mov    %eax,(%esp)
f0100fa6:	e8 c0 0b 00 00       	call   f0101b6b <strfind>
f0100fab:	2b 43 08             	sub    0x8(%ebx),%eax
f0100fae:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
        stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0100fb1:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0100fb4:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0100fb7:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100fbb:	c7 04 24 44 00 00 00 	movl   $0x44,(%esp)
f0100fc2:	b8 18 29 10 f0       	mov    $0xf0102918,%eax
f0100fc7:	e8 64 fd ff ff       	call   f0100d30 <stab_binsearch>
        if(lline <= rline)
f0100fcc:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100fcf:	3b 45 d0             	cmp    -0x30(%ebp),%eax
f0100fd2:	0f 8f 7a 00 00 00    	jg     f0101052 <debuginfo_eip+0x1f4>
           info->eip_line = stabs[lline].n_desc;
f0100fd8:	6b c0 0c             	imul   $0xc,%eax,%eax
f0100fdb:	0f b7 80 1e 29 10 f0 	movzwl -0xfefd6e2(%eax),%eax
f0100fe2:	89 43 04             	mov    %eax,0x4(%ebx)
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
f0100fe5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100fe8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100feb:	6b d0 0c             	imul   $0xc,%eax,%edx
f0100fee:	81 c2 20 29 10 f0    	add    $0xf0102920,%edx
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0100ff4:	eb 06                	jmp    f0100ffc <debuginfo_eip+0x19e>
f0100ff6:	83 e8 01             	sub    $0x1,%eax
f0100ff9:	83 ea 0c             	sub    $0xc,%edx
f0100ffc:	89 c6                	mov    %eax,%esi
f0100ffe:	39 f8                	cmp    %edi,%eax
f0101000:	7c 1f                	jl     f0101021 <debuginfo_eip+0x1c3>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0101002:	0f b6 4a fc          	movzbl -0x4(%edx),%ecx
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0101006:	80 f9 84             	cmp    $0x84,%cl
f0101009:	74 60                	je     f010106b <debuginfo_eip+0x20d>
f010100b:	80 f9 64             	cmp    $0x64,%cl
f010100e:	75 e6                	jne    f0100ff6 <debuginfo_eip+0x198>
f0101010:	83 3a 00             	cmpl   $0x0,(%edx)
f0101013:	74 e1                	je     f0100ff6 <debuginfo_eip+0x198>
f0101015:	8d 76 00             	lea    0x0(%esi),%esi
f0101018:	eb 51                	jmp    f010106b <debuginfo_eip+0x20d>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
		info->eip_file = stabstr + stabs[lline].n_strx;
f010101a:	05 a1 6a 10 f0       	add    $0xf0106aa1,%eax
f010101f:	89 03                	mov    %eax,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0101021:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0101024:	3b 45 d8             	cmp    -0x28(%ebp),%eax
f0101027:	7d 30                	jge    f0101059 <debuginfo_eip+0x1fb>
		for (lline = lfun + 1;
f0101029:	83 c0 01             	add    $0x1,%eax
f010102c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f010102f:	ba 18 29 10 f0       	mov    $0xf0102918,%edx


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0101034:	eb 08                	jmp    f010103e <debuginfo_eip+0x1e0>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0101036:	83 43 14 01          	addl   $0x1,0x14(%ebx)
	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
f010103a:	83 45 d4 01          	addl   $0x1,-0x2c(%ebp)

	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f010103e:	8b 45 d4             	mov    -0x2c(%ebp),%eax


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0101041:	3b 45 d8             	cmp    -0x28(%ebp),%eax
f0101044:	7d 13                	jge    f0101059 <debuginfo_eip+0x1fb>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0101046:	6b c0 0c             	imul   $0xc,%eax,%eax
f0101049:	80 7c 10 04 a0       	cmpb   $0xa0,0x4(%eax,%edx,1)
f010104e:	74 e6                	je     f0101036 <debuginfo_eip+0x1d8>
f0101050:	eb 07                	jmp    f0101059 <debuginfo_eip+0x1fb>
f0101052:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0101057:	eb 05                	jmp    f010105e <debuginfo_eip+0x200>
f0101059:	b8 00 00 00 00       	mov    $0x0,%eax
		     lline++)
			info->eip_fn_narg++;
	
	return 0;
}
f010105e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0101061:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0101064:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0101067:	89 ec                	mov    %ebp,%esp
f0101069:	5d                   	pop    %ebp
f010106a:	c3                   	ret    
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f010106b:	6b c6 0c             	imul   $0xc,%esi,%eax
f010106e:	8b 80 18 29 10 f0    	mov    -0xfefd6e8(%eax),%eax
f0101074:	ba 3b 86 10 f0       	mov    $0xf010863b,%edx
f0101079:	81 ea a1 6a 10 f0    	sub    $0xf0106aa1,%edx
f010107f:	39 d0                	cmp    %edx,%eax
f0101081:	72 97                	jb     f010101a <debuginfo_eip+0x1bc>
f0101083:	eb 9c                	jmp    f0101021 <debuginfo_eip+0x1c3>
	...

f0101090 <printnum_v2>:
 */

static void 
printnum_v2(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0101090:	55                   	push   %ebp
f0101091:	89 e5                	mov    %esp,%ebp
f0101093:	57                   	push   %edi
f0101094:	56                   	push   %esi
f0101095:	53                   	push   %ebx
f0101096:	83 ec 4c             	sub    $0x4c,%esp
f0101099:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010109c:	89 d6                	mov    %edx,%esi
f010109e:	8b 45 08             	mov    0x8(%ebp),%eax
f01010a1:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01010a4:	8b 55 0c             	mov    0xc(%ebp),%edx
f01010a7:	89 55 e0             	mov    %edx,-0x20(%ebp)
f01010aa:	8b 45 10             	mov    0x10(%ebp),%eax
f01010ad:	8b 5d 14             	mov    0x14(%ebp),%ebx
f01010b0:	8b 7d 18             	mov    0x18(%ebp),%edi
    if (num >= base) {
f01010b3:	89 45 dc             	mov    %eax,-0x24(%ebp)
f01010b6:	b9 00 00 00 00       	mov    $0x0,%ecx
f01010bb:	39 d1                	cmp    %edx,%ecx
f01010bd:	72 07                	jb     f01010c6 <printnum_v2+0x36>
f01010bf:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01010c2:	39 d0                	cmp    %edx,%eax
f01010c4:	77 5f                	ja     f0101125 <printnum_v2+0x95>
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
f01010c6:	89 7c 24 10          	mov    %edi,0x10(%esp)
f01010ca:	83 eb 01             	sub    $0x1,%ebx
f01010cd:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f01010d1:	89 44 24 08          	mov    %eax,0x8(%esp)
f01010d5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f01010d9:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
f01010dd:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f01010e0:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
f01010e3:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f01010e6:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01010ea:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f01010f1:	00 
f01010f2:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01010f5:	89 04 24             	mov    %eax,(%esp)
f01010f8:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01010fb:	89 54 24 04          	mov    %edx,0x4(%esp)
f01010ff:	e8 fc 0c 00 00       	call   f0101e00 <__udivdi3>
f0101104:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0101107:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010110a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010110e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0101112:	89 04 24             	mov    %eax,(%esp)
f0101115:	89 54 24 04          	mov    %edx,0x4(%esp)
f0101119:	89 f2                	mov    %esi,%edx
f010111b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010111e:	e8 6d ff ff ff       	call   f0101090 <printnum_v2>
f0101123:	eb 1e                	jmp    f0101143 <printnum_v2+0xb3>
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
f0101125:	83 ff 2d             	cmp    $0x2d,%edi
f0101128:	74 19                	je     f0101143 <printnum_v2+0xb3>
		while (--width > 0)
f010112a:	83 eb 01             	sub    $0x1,%ebx
f010112d:	85 db                	test   %ebx,%ebx
f010112f:	90                   	nop
f0101130:	7e 11                	jle    f0101143 <printnum_v2+0xb3>
			putch(padc, putdat);
f0101132:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101136:	89 3c 24             	mov    %edi,(%esp)
f0101139:	ff 55 e4             	call   *-0x1c(%ebp)
    if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
		while (--width > 0)
f010113c:	83 eb 01             	sub    $0x1,%ebx
f010113f:	85 db                	test   %ebx,%ebx
f0101141:	7f ef                	jg     f0101132 <printnum_v2+0xa2>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0101143:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101147:	8b 74 24 04          	mov    0x4(%esp),%esi
f010114b:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010114e:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101152:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0101159:	00 
f010115a:	8b 55 d8             	mov    -0x28(%ebp),%edx
f010115d:	89 14 24             	mov    %edx,(%esp)
f0101160:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0101163:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0101167:	e8 c4 0d 00 00       	call   f0101f30 <__umoddi3>
f010116c:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101170:	0f be 80 89 26 10 f0 	movsbl -0xfefd977(%eax),%eax
f0101177:	89 04 24             	mov    %eax,(%esp)
f010117a:	ff 55 e4             	call   *-0x1c(%ebp)
}
f010117d:	83 c4 4c             	add    $0x4c,%esp
f0101180:	5b                   	pop    %ebx
f0101181:	5e                   	pop    %esi
f0101182:	5f                   	pop    %edi
f0101183:	5d                   	pop    %ebp
f0101184:	c3                   	ret    

f0101185 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0101185:	55                   	push   %ebp
f0101186:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0101188:	83 fa 01             	cmp    $0x1,%edx
f010118b:	7e 0e                	jle    f010119b <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f010118d:	8b 10                	mov    (%eax),%edx
f010118f:	8d 4a 08             	lea    0x8(%edx),%ecx
f0101192:	89 08                	mov    %ecx,(%eax)
f0101194:	8b 02                	mov    (%edx),%eax
f0101196:	8b 52 04             	mov    0x4(%edx),%edx
f0101199:	eb 22                	jmp    f01011bd <getuint+0x38>
	else if (lflag)
f010119b:	85 d2                	test   %edx,%edx
f010119d:	74 10                	je     f01011af <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f010119f:	8b 10                	mov    (%eax),%edx
f01011a1:	8d 4a 04             	lea    0x4(%edx),%ecx
f01011a4:	89 08                	mov    %ecx,(%eax)
f01011a6:	8b 02                	mov    (%edx),%eax
f01011a8:	ba 00 00 00 00       	mov    $0x0,%edx
f01011ad:	eb 0e                	jmp    f01011bd <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f01011af:	8b 10                	mov    (%eax),%edx
f01011b1:	8d 4a 04             	lea    0x4(%edx),%ecx
f01011b4:	89 08                	mov    %ecx,(%eax)
f01011b6:	8b 02                	mov    (%edx),%eax
f01011b8:	ba 00 00 00 00       	mov    $0x0,%edx
}
f01011bd:	5d                   	pop    %ebp
f01011be:	c3                   	ret    

f01011bf <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f01011bf:	55                   	push   %ebp
f01011c0:	89 e5                	mov    %esp,%ebp
f01011c2:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f01011c5:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f01011c9:	8b 10                	mov    (%eax),%edx
f01011cb:	3b 50 04             	cmp    0x4(%eax),%edx
f01011ce:	73 0a                	jae    f01011da <sprintputch+0x1b>
		*b->buf++ = ch;
f01011d0:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01011d3:	88 0a                	mov    %cl,(%edx)
f01011d5:	83 c2 01             	add    $0x1,%edx
f01011d8:	89 10                	mov    %edx,(%eax)
}
f01011da:	5d                   	pop    %ebp
f01011db:	c3                   	ret    

f01011dc <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f01011dc:	55                   	push   %ebp
f01011dd:	89 e5                	mov    %esp,%ebp
f01011df:	57                   	push   %edi
f01011e0:	56                   	push   %esi
f01011e1:	53                   	push   %ebx
f01011e2:	83 ec 6c             	sub    $0x6c,%esp
f01011e5:	8b 7d 10             	mov    0x10(%ebp),%edi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
f01011e8:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
f01011ef:	eb 1a                	jmp    f010120b <vprintfmt+0x2f>
	int base, lflag, width, precision, altflag,signflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f01011f1:	85 c0                	test   %eax,%eax
f01011f3:	0f 84 66 06 00 00    	je     f010185f <vprintfmt+0x683>
				return;
			putch(ch, putdat);
f01011f9:	8b 55 0c             	mov    0xc(%ebp),%edx
f01011fc:	89 54 24 04          	mov    %edx,0x4(%esp)
f0101200:	89 04 24             	mov    %eax,(%esp)
f0101203:	ff 55 08             	call   *0x8(%ebp)
f0101206:	eb 03                	jmp    f010120b <vprintfmt+0x2f>
f0101208:	8b 7d e4             	mov    -0x1c(%ebp),%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag,signflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f010120b:	0f b6 07             	movzbl (%edi),%eax
f010120e:	83 c7 01             	add    $0x1,%edi
f0101211:	83 f8 25             	cmp    $0x25,%eax
f0101214:	75 db                	jne    f01011f1 <vprintfmt+0x15>
f0101216:	c6 45 cc 20          	movb   $0x20,-0x34(%ebp)
f010121a:	b9 00 00 00 00       	mov    $0x0,%ecx
f010121f:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
f0101226:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f010122b:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
f0101232:	be 00 00 00 00       	mov    $0x0,%esi
f0101237:	eb 06                	jmp    f010123f <vprintfmt+0x63>
f0101239:	c6 45 cc 2d          	movb   $0x2d,-0x34(%ebp)
f010123d:	89 c7                	mov    %eax,%edi
		precision = -1;
		lflag = 0;
		altflag = 0;
                signflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010123f:	0f b6 17             	movzbl (%edi),%edx
f0101242:	0f b6 c2             	movzbl %dl,%eax
f0101245:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0101248:	8d 47 01             	lea    0x1(%edi),%eax
f010124b:	83 ea 23             	sub    $0x23,%edx
f010124e:	80 fa 55             	cmp    $0x55,%dl
f0101251:	0f 87 60 05 00 00    	ja     f01017b7 <vprintfmt+0x5db>
f0101257:	0f b6 d2             	movzbl %dl,%edx
f010125a:	ff 24 95 94 27 10 f0 	jmp    *-0xfefd86c(,%edx,4)
f0101261:	b9 01 00 00 00       	mov    $0x1,%ecx
f0101266:	eb d5                	jmp    f010123d <vprintfmt+0x61>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0101268:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f010126b:	83 eb 30             	sub    $0x30,%ebx
				ch = *fmt;
f010126e:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
f0101271:	8d 7a d0             	lea    -0x30(%edx),%edi
f0101274:	83 ff 09             	cmp    $0x9,%edi
f0101277:	76 08                	jbe    f0101281 <vprintfmt+0xa5>
f0101279:	eb 40                	jmp    f01012bb <vprintfmt+0xdf>
f010127b:	c6 45 cc 30          	movb   $0x30,-0x34(%ebp)
                        signflag = 1;
                        goto reswitch;
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
			goto reswitch;
f010127f:	eb bc                	jmp    f010123d <vprintfmt+0x61>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0101281:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
f0101284:	8d 1c 9b             	lea    (%ebx,%ebx,4),%ebx
f0101287:	8d 5c 5a d0          	lea    -0x30(%edx,%ebx,2),%ebx
				ch = *fmt;
f010128b:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
f010128e:	8d 7a d0             	lea    -0x30(%edx),%edi
f0101291:	83 ff 09             	cmp    $0x9,%edi
f0101294:	76 eb                	jbe    f0101281 <vprintfmt+0xa5>
f0101296:	eb 23                	jmp    f01012bb <vprintfmt+0xdf>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0101298:	8b 55 14             	mov    0x14(%ebp),%edx
f010129b:	8d 5a 04             	lea    0x4(%edx),%ebx
f010129e:	89 5d 14             	mov    %ebx,0x14(%ebp)
f01012a1:	8b 1a                	mov    (%edx),%ebx
			goto process_precision;
f01012a3:	eb 16                	jmp    f01012bb <vprintfmt+0xdf>

		case '.':
			if (width < 0)
f01012a5:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01012a8:	c1 fa 1f             	sar    $0x1f,%edx
f01012ab:	f7 d2                	not    %edx
f01012ad:	21 55 d8             	and    %edx,-0x28(%ebp)
f01012b0:	eb 8b                	jmp    f010123d <vprintfmt+0x61>
f01012b2:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
f01012b9:	eb 82                	jmp    f010123d <vprintfmt+0x61>

		process_precision:
			if (width < 0)
f01012bb:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f01012bf:	0f 89 78 ff ff ff    	jns    f010123d <vprintfmt+0x61>
f01012c5:	89 5d d8             	mov    %ebx,-0x28(%ebp)
f01012c8:	8b 5d c8             	mov    -0x38(%ebp),%ebx
f01012cb:	e9 6d ff ff ff       	jmp    f010123d <vprintfmt+0x61>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f01012d0:	83 c6 01             	add    $0x1,%esi
			goto reswitch;
f01012d3:	e9 65 ff ff ff       	jmp    f010123d <vprintfmt+0x61>
f01012d8:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f01012db:	8b 45 14             	mov    0x14(%ebp),%eax
f01012de:	8d 50 04             	lea    0x4(%eax),%edx
f01012e1:	89 55 14             	mov    %edx,0x14(%ebp)
f01012e4:	8b 55 0c             	mov    0xc(%ebp),%edx
f01012e7:	89 54 24 04          	mov    %edx,0x4(%esp)
f01012eb:	8b 00                	mov    (%eax),%eax
f01012ed:	89 04 24             	mov    %eax,(%esp)
f01012f0:	ff 55 08             	call   *0x8(%ebp)
f01012f3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;
f01012f6:	e9 10 ff ff ff       	jmp    f010120b <vprintfmt+0x2f>
f01012fb:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
f01012fe:	8b 45 14             	mov    0x14(%ebp),%eax
f0101301:	8d 50 04             	lea    0x4(%eax),%edx
f0101304:	89 55 14             	mov    %edx,0x14(%ebp)
f0101307:	8b 00                	mov    (%eax),%eax
f0101309:	89 c2                	mov    %eax,%edx
f010130b:	c1 fa 1f             	sar    $0x1f,%edx
f010130e:	31 d0                	xor    %edx,%eax
f0101310:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0101312:	83 f8 06             	cmp    $0x6,%eax
f0101315:	7f 0b                	jg     f0101322 <vprintfmt+0x146>
f0101317:	8b 14 85 ec 28 10 f0 	mov    -0xfefd714(,%eax,4),%edx
f010131e:	85 d2                	test   %edx,%edx
f0101320:	75 26                	jne    f0101348 <vprintfmt+0x16c>
				printfmt(putch, putdat, "error %d", err);
f0101322:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101326:	c7 44 24 08 9a 26 10 	movl   $0xf010269a,0x8(%esp)
f010132d:	f0 
f010132e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0101331:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0101335:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0101338:	89 1c 24             	mov    %ebx,(%esp)
f010133b:	e8 a7 05 00 00       	call   f01018e7 <printfmt>
f0101340:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0101343:	e9 c3 fe ff ff       	jmp    f010120b <vprintfmt+0x2f>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
f0101348:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010134c:	c7 44 24 08 a3 26 10 	movl   $0xf01026a3,0x8(%esp)
f0101353:	f0 
f0101354:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101357:	89 44 24 04          	mov    %eax,0x4(%esp)
f010135b:	8b 55 08             	mov    0x8(%ebp),%edx
f010135e:	89 14 24             	mov    %edx,(%esp)
f0101361:	e8 81 05 00 00       	call   f01018e7 <printfmt>
f0101366:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0101369:	e9 9d fe ff ff       	jmp    f010120b <vprintfmt+0x2f>
f010136e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0101371:	89 c7                	mov    %eax,%edi
f0101373:	89 d9                	mov    %ebx,%ecx
f0101375:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0101378:	89 45 c0             	mov    %eax,-0x40(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f010137b:	8b 45 14             	mov    0x14(%ebp),%eax
f010137e:	8d 50 04             	lea    0x4(%eax),%edx
f0101381:	89 55 14             	mov    %edx,0x14(%ebp)
f0101384:	8b 30                	mov    (%eax),%esi
f0101386:	85 f6                	test   %esi,%esi
f0101388:	75 05                	jne    f010138f <vprintfmt+0x1b3>
f010138a:	be a6 26 10 f0       	mov    $0xf01026a6,%esi
				p = "(null)";
			if (width > 0 && padc != '-')
f010138f:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
f0101393:	7e 06                	jle    f010139b <vprintfmt+0x1bf>
f0101395:	80 7d cc 2d          	cmpb   $0x2d,-0x34(%ebp)
f0101399:	75 10                	jne    f01013ab <vprintfmt+0x1cf>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f010139b:	0f be 06             	movsbl (%esi),%eax
f010139e:	85 c0                	test   %eax,%eax
f01013a0:	0f 85 a2 00 00 00    	jne    f0101448 <vprintfmt+0x26c>
f01013a6:	e9 92 00 00 00       	jmp    f010143d <vprintfmt+0x261>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f01013ab:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f01013af:	89 34 24             	mov    %esi,(%esp)
f01013b2:	e8 54 06 00 00       	call   f0101a0b <strnlen>
f01013b7:	8b 55 c0             	mov    -0x40(%ebp),%edx
f01013ba:	29 c2                	sub    %eax,%edx
f01013bc:	89 55 d8             	mov    %edx,-0x28(%ebp)
f01013bf:	85 d2                	test   %edx,%edx
f01013c1:	7e d8                	jle    f010139b <vprintfmt+0x1bf>
					putch(padc, putdat);
f01013c3:	0f be 4d cc          	movsbl -0x34(%ebp),%ecx
f01013c7:	89 5d c0             	mov    %ebx,-0x40(%ebp)
f01013ca:	89 d3                	mov    %edx,%ebx
f01013cc:	89 75 d8             	mov    %esi,-0x28(%ebp)
f01013cf:	89 7d bc             	mov    %edi,-0x44(%ebp)
f01013d2:	8b 7d 0c             	mov    0xc(%ebp),%edi
f01013d5:	89 ce                	mov    %ecx,%esi
f01013d7:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01013db:	89 34 24             	mov    %esi,(%esp)
f01013de:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f01013e1:	83 eb 01             	sub    $0x1,%ebx
f01013e4:	85 db                	test   %ebx,%ebx
f01013e6:	7f ef                	jg     f01013d7 <vprintfmt+0x1fb>
f01013e8:	8b 5d c0             	mov    -0x40(%ebp),%ebx
f01013eb:	8b 75 d8             	mov    -0x28(%ebp),%esi
f01013ee:	8b 7d bc             	mov    -0x44(%ebp),%edi
f01013f1:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f01013f8:	eb a1                	jmp    f010139b <vprintfmt+0x1bf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f01013fa:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
f01013fe:	74 1b                	je     f010141b <vprintfmt+0x23f>
f0101400:	8d 50 e0             	lea    -0x20(%eax),%edx
f0101403:	83 fa 5e             	cmp    $0x5e,%edx
f0101406:	76 13                	jbe    f010141b <vprintfmt+0x23f>
					putch('?', putdat);
f0101408:	8b 45 0c             	mov    0xc(%ebp),%eax
f010140b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010140f:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f0101416:	ff 55 08             	call   *0x8(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0101419:	eb 0d                	jmp    f0101428 <vprintfmt+0x24c>
					putch('?', putdat);
				else
					putch(ch, putdat);
f010141b:	8b 55 0c             	mov    0xc(%ebp),%edx
f010141e:	89 54 24 04          	mov    %edx,0x4(%esp)
f0101422:	89 04 24             	mov    %eax,(%esp)
f0101425:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0101428:	83 ef 01             	sub    $0x1,%edi
f010142b:	0f be 06             	movsbl (%esi),%eax
f010142e:	85 c0                	test   %eax,%eax
f0101430:	74 05                	je     f0101437 <vprintfmt+0x25b>
f0101432:	83 c6 01             	add    $0x1,%esi
f0101435:	eb 1a                	jmp    f0101451 <vprintfmt+0x275>
f0101437:	89 7d d8             	mov    %edi,-0x28(%ebp)
f010143a:	8b 7d cc             	mov    -0x34(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f010143d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0101441:	7f 1f                	jg     f0101462 <vprintfmt+0x286>
f0101443:	e9 c0 fd ff ff       	jmp    f0101208 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0101448:	83 c6 01             	add    $0x1,%esi
f010144b:	89 7d cc             	mov    %edi,-0x34(%ebp)
f010144e:	8b 7d d8             	mov    -0x28(%ebp),%edi
f0101451:	85 db                	test   %ebx,%ebx
f0101453:	78 a5                	js     f01013fa <vprintfmt+0x21e>
f0101455:	83 eb 01             	sub    $0x1,%ebx
f0101458:	79 a0                	jns    f01013fa <vprintfmt+0x21e>
f010145a:	89 7d d8             	mov    %edi,-0x28(%ebp)
f010145d:	8b 7d cc             	mov    -0x34(%ebp),%edi
f0101460:	eb db                	jmp    f010143d <vprintfmt+0x261>
f0101462:	8b 5d d8             	mov    -0x28(%ebp),%ebx
f0101465:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101468:	89 7d d8             	mov    %edi,-0x28(%ebp)
f010146b:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f010146e:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101472:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0101479:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f010147b:	83 eb 01             	sub    $0x1,%ebx
f010147e:	85 db                	test   %ebx,%ebx
f0101480:	7f ec                	jg     f010146e <vprintfmt+0x292>
f0101482:	8b 7d d8             	mov    -0x28(%ebp),%edi
f0101485:	e9 81 fd ff ff       	jmp    f010120b <vprintfmt+0x2f>
f010148a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f010148d:	83 fe 01             	cmp    $0x1,%esi
f0101490:	7e 10                	jle    f01014a2 <vprintfmt+0x2c6>
		return va_arg(*ap, long long);
f0101492:	8b 45 14             	mov    0x14(%ebp),%eax
f0101495:	8d 50 08             	lea    0x8(%eax),%edx
f0101498:	89 55 14             	mov    %edx,0x14(%ebp)
f010149b:	8b 18                	mov    (%eax),%ebx
f010149d:	8b 70 04             	mov    0x4(%eax),%esi
f01014a0:	eb 26                	jmp    f01014c8 <vprintfmt+0x2ec>
	else if (lflag)
f01014a2:	85 f6                	test   %esi,%esi
f01014a4:	74 12                	je     f01014b8 <vprintfmt+0x2dc>
		return va_arg(*ap, long);
f01014a6:	8b 45 14             	mov    0x14(%ebp),%eax
f01014a9:	8d 50 04             	lea    0x4(%eax),%edx
f01014ac:	89 55 14             	mov    %edx,0x14(%ebp)
f01014af:	8b 18                	mov    (%eax),%ebx
f01014b1:	89 de                	mov    %ebx,%esi
f01014b3:	c1 fe 1f             	sar    $0x1f,%esi
f01014b6:	eb 10                	jmp    f01014c8 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
f01014b8:	8b 45 14             	mov    0x14(%ebp),%eax
f01014bb:	8d 50 04             	lea    0x4(%eax),%edx
f01014be:	89 55 14             	mov    %edx,0x14(%ebp)
f01014c1:	8b 18                	mov    (%eax),%ebx
f01014c3:	89 de                	mov    %ebx,%esi
f01014c5:	c1 fe 1f             	sar    $0x1f,%esi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
                        if(signflag == 1){
f01014c8:	83 f9 01             	cmp    $0x1,%ecx
f01014cb:	75 1e                	jne    f01014eb <vprintfmt+0x30f>
                               if((long long)num > 0){
f01014cd:	85 f6                	test   %esi,%esi
f01014cf:	78 1a                	js     f01014eb <vprintfmt+0x30f>
f01014d1:	85 f6                	test   %esi,%esi
f01014d3:	7f 05                	jg     f01014da <vprintfmt+0x2fe>
f01014d5:	83 fb 00             	cmp    $0x0,%ebx
f01014d8:	76 11                	jbe    f01014eb <vprintfmt+0x30f>
                                   putch('+',putdat);
f01014da:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01014dd:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f01014e1:	c7 04 24 2b 00 00 00 	movl   $0x2b,(%esp)
f01014e8:	ff 55 08             	call   *0x8(%ebp)
                               }
                        }
			if ((long long) num < 0) {
f01014eb:	85 f6                	test   %esi,%esi
f01014ed:	78 13                	js     f0101502 <vprintfmt+0x326>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f01014ef:	89 5d b0             	mov    %ebx,-0x50(%ebp)
f01014f2:	89 75 b4             	mov    %esi,-0x4c(%ebp)
f01014f5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01014f8:	b8 0a 00 00 00       	mov    $0xa,%eax
f01014fd:	e9 da 00 00 00       	jmp    f01015dc <vprintfmt+0x400>
                               if((long long)num > 0){
                                   putch('+',putdat);
                               }
                        }
			if ((long long) num < 0) {
				putch('-', putdat);
f0101502:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101505:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101509:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f0101510:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f0101513:	89 da                	mov    %ebx,%edx
f0101515:	89 f1                	mov    %esi,%ecx
f0101517:	f7 da                	neg    %edx
f0101519:	83 d1 00             	adc    $0x0,%ecx
f010151c:	f7 d9                	neg    %ecx
f010151e:	89 55 b0             	mov    %edx,-0x50(%ebp)
f0101521:	89 4d b4             	mov    %ecx,-0x4c(%ebp)
f0101524:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0101527:	b8 0a 00 00 00       	mov    $0xa,%eax
f010152c:	e9 ab 00 00 00       	jmp    f01015dc <vprintfmt+0x400>
f0101531:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0101534:	89 f2                	mov    %esi,%edx
f0101536:	8d 45 14             	lea    0x14(%ebp),%eax
f0101539:	e8 47 fc ff ff       	call   f0101185 <getuint>
f010153e:	89 45 b0             	mov    %eax,-0x50(%ebp)
f0101541:	89 55 b4             	mov    %edx,-0x4c(%ebp)
f0101544:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0101547:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
f010154c:	e9 8b 00 00 00       	jmp    f01015dc <vprintfmt+0x400>
f0101551:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			putch('0', putdat);
f0101554:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0101557:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f010155b:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f0101562:	ff 55 08             	call   *0x8(%ebp)
			num = getuint(&ap,lflag);
f0101565:	89 f2                	mov    %esi,%edx
f0101567:	8d 45 14             	lea    0x14(%ebp),%eax
f010156a:	e8 16 fc ff ff       	call   f0101185 <getuint>
f010156f:	89 45 b0             	mov    %eax,-0x50(%ebp)
f0101572:	89 55 b4             	mov    %edx,-0x4c(%ebp)
f0101575:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0101578:	b8 08 00 00 00       	mov    $0x8,%eax
                        base = 8;
			goto number;
f010157d:	eb 5d                	jmp    f01015dc <vprintfmt+0x400>
f010157f:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
f0101582:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101585:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101589:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f0101590:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f0101593:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101597:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f010159e:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
f01015a1:	8b 45 14             	mov    0x14(%ebp),%eax
f01015a4:	8d 50 04             	lea    0x4(%eax),%edx
f01015a7:	89 55 14             	mov    %edx,0x14(%ebp)
f01015aa:	8b 10                	mov    (%eax),%edx
f01015ac:	b9 00 00 00 00       	mov    $0x0,%ecx
f01015b1:	89 55 b0             	mov    %edx,-0x50(%ebp)
f01015b4:	89 4d b4             	mov    %ecx,-0x4c(%ebp)
f01015b7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01015ba:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f01015bf:	eb 1b                	jmp    f01015dc <vprintfmt+0x400>
f01015c1:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f01015c4:	89 f2                	mov    %esi,%edx
f01015c6:	8d 45 14             	lea    0x14(%ebp),%eax
f01015c9:	e8 b7 fb ff ff       	call   f0101185 <getuint>
f01015ce:	89 45 b0             	mov    %eax,-0x50(%ebp)
f01015d1:	89 55 b4             	mov    %edx,-0x4c(%ebp)
f01015d4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01015d7:	b8 10 00 00 00       	mov    $0x10,%eax
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
f01015dc:	0f be 4d cc          	movsbl -0x34(%ebp),%ecx
f01015e0:	89 4d d0             	mov    %ecx,-0x30(%ebp)
	// you can add helper function if needed.
	// your code here:


	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f01015e3:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01015e6:	83 7d b4 00          	cmpl   $0x0,-0x4c(%ebp)
f01015ea:	77 09                	ja     f01015f5 <vprintfmt+0x419>
f01015ec:	39 45 b0             	cmp    %eax,-0x50(%ebp)
f01015ef:	0f 82 ac 00 00 00    	jb     f01016a1 <vprintfmt+0x4c5>
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
f01015f5:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f01015f8:	89 5c 24 10          	mov    %ebx,0x10(%esp)
f01015fc:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01015ff:	83 ea 01             	sub    $0x1,%edx
f0101602:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0101606:	89 44 24 08          	mov    %eax,0x8(%esp)
f010160a:	8b 44 24 08          	mov    0x8(%esp),%eax
f010160e:	8b 54 24 0c          	mov    0xc(%esp),%edx
f0101612:	89 45 c0             	mov    %eax,-0x40(%ebp)
f0101615:	89 55 c4             	mov    %edx,-0x3c(%ebp)
f0101618:	8b 55 cc             	mov    -0x34(%ebp),%edx
f010161b:	89 54 24 08          	mov    %edx,0x8(%esp)
f010161f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0101626:	00 
f0101627:	8b 4d b0             	mov    -0x50(%ebp),%ecx
f010162a:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
f010162d:	89 0c 24             	mov    %ecx,(%esp)
f0101630:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101634:	e8 c7 07 00 00       	call   f0101e00 <__udivdi3>
f0101639:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f010163c:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f010163f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0101643:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0101647:	89 04 24             	mov    %eax,(%esp)
f010164a:	89 54 24 04          	mov    %edx,0x4(%esp)
f010164e:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101651:	8b 45 08             	mov    0x8(%ebp),%eax
f0101654:	e8 37 fa ff ff       	call   f0101090 <printnum_v2>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0101659:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010165c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101660:	8b 74 24 04          	mov    0x4(%esp),%esi
f0101664:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0101667:	89 44 24 08          	mov    %eax,0x8(%esp)
f010166b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0101672:	00 
f0101673:	8b 55 b0             	mov    -0x50(%ebp),%edx
f0101676:	8b 4d b4             	mov    -0x4c(%ebp),%ecx
f0101679:	89 14 24             	mov    %edx,(%esp)
f010167c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0101680:	e8 ab 08 00 00       	call   f0101f30 <__umoddi3>
f0101685:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101689:	0f be 80 89 26 10 f0 	movsbl -0xfefd977(%eax),%eax
f0101690:	89 04 24             	mov    %eax,(%esp)
f0101693:	ff 55 08             	call   *0x8(%ebp)
        if(padc == '-'){
f0101696:	83 7d d0 2d          	cmpl   $0x2d,-0x30(%ebp)
f010169a:	74 54                	je     f01016f0 <vprintfmt+0x514>
f010169c:	e9 67 fb ff ff       	jmp    f0101208 <vprintfmt+0x2c>
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
f01016a1:	83 7d d0 2d          	cmpl   $0x2d,-0x30(%ebp)
f01016a5:	8d 76 00             	lea    0x0(%esi),%esi
f01016a8:	0f 84 2a 01 00 00    	je     f01017d8 <vprintfmt+0x5fc>
		while (--width > 0)
f01016ae:	8b 7d d8             	mov    -0x28(%ebp),%edi
f01016b1:	83 ef 01             	sub    $0x1,%edi
f01016b4:	85 ff                	test   %edi,%edi
f01016b6:	0f 8e 5e 01 00 00    	jle    f010181a <vprintfmt+0x63e>
f01016bc:	8b 4d b0             	mov    -0x50(%ebp),%ecx
f01016bf:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
f01016c2:	89 4d d8             	mov    %ecx,-0x28(%ebp)
f01016c5:	89 5d dc             	mov    %ebx,-0x24(%ebp)
f01016c8:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f01016cb:	8b 75 0c             	mov    0xc(%ebp),%esi
			putch(padc, putdat);
f01016ce:	89 74 24 04          	mov    %esi,0x4(%esp)
f01016d2:	89 1c 24             	mov    %ebx,(%esp)
f01016d5:	ff 55 08             	call   *0x8(%ebp)
	if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
		while (--width > 0)
f01016d8:	83 ef 01             	sub    $0x1,%edi
f01016db:	85 ff                	test   %edi,%edi
f01016dd:	7f ef                	jg     f01016ce <vprintfmt+0x4f2>
f01016df:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01016e2:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01016e5:	89 45 b0             	mov    %eax,-0x50(%ebp)
f01016e8:	89 55 b4             	mov    %edx,-0x4c(%ebp)
f01016eb:	e9 2a 01 00 00       	jmp    f010181a <vprintfmt+0x63e>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
        if(padc == '-'){
           while (--width > 0)
f01016f0:	8b 5d d8             	mov    -0x28(%ebp),%ebx
f01016f3:	83 eb 01             	sub    $0x1,%ebx
f01016f6:	85 db                	test   %ebx,%ebx
f01016f8:	0f 8e 0a fb ff ff    	jle    f0101208 <vprintfmt+0x2c>
f01016fe:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101701:	89 7d d8             	mov    %edi,-0x28(%ebp)
f0101704:	8b 7d 08             	mov    0x8(%ebp),%edi
			putch(' ', putdat);
f0101707:	89 74 24 04          	mov    %esi,0x4(%esp)
f010170b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0101712:	ff d7                	call   *%edi
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
        if(padc == '-'){
           while (--width > 0)
f0101714:	83 eb 01             	sub    $0x1,%ebx
f0101717:	85 db                	test   %ebx,%ebx
f0101719:	7f ec                	jg     f0101707 <vprintfmt+0x52b>
f010171b:	8b 7d d8             	mov    -0x28(%ebp),%edi
f010171e:	e9 e8 fa ff ff       	jmp    f010120b <vprintfmt+0x2f>
f0101723:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
            char* n;
            if ((n = va_arg(ap, char *)) == NULL)
f0101726:	8b 45 14             	mov    0x14(%ebp),%eax
f0101729:	8d 50 04             	lea    0x4(%eax),%edx
f010172c:	89 55 14             	mov    %edx,0x14(%ebp)
f010172f:	8b 00                	mov    (%eax),%eax
f0101731:	85 c0                	test   %eax,%eax
f0101733:	75 2a                	jne    f010175f <vprintfmt+0x583>
		  printfmt(putch,putdat,"%s",null_error);
f0101735:	c7 44 24 0c 18 27 10 	movl   $0xf0102718,0xc(%esp)
f010173c:	f0 
f010173d:	c7 44 24 08 a3 26 10 	movl   $0xf01026a3,0x8(%esp)
f0101744:	f0 
f0101745:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101748:	89 54 24 04          	mov    %edx,0x4(%esp)
f010174c:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010174f:	89 0c 24             	mov    %ecx,(%esp)
f0101752:	e8 90 01 00 00       	call   f01018e7 <printfmt>
f0101757:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010175a:	e9 ac fa ff ff       	jmp    f010120b <vprintfmt+0x2f>
            else if((*(int*)putdat) > 127){
f010175f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101762:	8b 13                	mov    (%ebx),%edx
f0101764:	83 fa 7f             	cmp    $0x7f,%edx
f0101767:	7e 29                	jle    f0101792 <vprintfmt+0x5b6>
                  *n = *(int*)putdat;
f0101769:	88 10                	mov    %dl,(%eax)
                  printfmt(putch,putdat,"%s",overflow_error);
f010176b:	c7 44 24 0c 50 27 10 	movl   $0xf0102750,0xc(%esp)
f0101772:	f0 
f0101773:	c7 44 24 08 a3 26 10 	movl   $0xf01026a3,0x8(%esp)
f010177a:	f0 
f010177b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010177f:	8b 45 08             	mov    0x8(%ebp),%eax
f0101782:	89 04 24             	mov    %eax,(%esp)
f0101785:	e8 5d 01 00 00       	call   f01018e7 <printfmt>
f010178a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010178d:	e9 79 fa ff ff       	jmp    f010120b <vprintfmt+0x2f>
            }
            else
                  *n = *(int*)putdat;
f0101792:	88 10                	mov    %dl,(%eax)
f0101794:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0101797:	e9 6f fa ff ff       	jmp    f010120b <vprintfmt+0x2f>
f010179c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f010179f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            break;
        }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f01017a2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01017a5:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f01017a9:	89 14 24             	mov    %edx,(%esp)
f01017ac:	ff 55 08             	call   *0x8(%ebp)
f01017af:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;
f01017b2:	e9 54 fa ff ff       	jmp    f010120b <vprintfmt+0x2f>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f01017b7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01017ba:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01017be:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f01017c5:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f01017c8:	8d 47 ff             	lea    -0x1(%edi),%eax
f01017cb:	80 38 25             	cmpb   $0x25,(%eax)
f01017ce:	0f 84 37 fa ff ff    	je     f010120b <vprintfmt+0x2f>
f01017d4:	89 c7                	mov    %eax,%edi
f01017d6:	eb f0                	jmp    f01017c8 <vprintfmt+0x5ec>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f01017d8:	8b 45 0c             	mov    0xc(%ebp),%eax
f01017db:	89 44 24 04          	mov    %eax,0x4(%esp)
f01017df:	8b 74 24 04          	mov    0x4(%esp),%esi
f01017e3:	8b 55 cc             	mov    -0x34(%ebp),%edx
f01017e6:	89 54 24 08          	mov    %edx,0x8(%esp)
f01017ea:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f01017f1:	00 
f01017f2:	8b 45 b0             	mov    -0x50(%ebp),%eax
f01017f5:	8b 55 b4             	mov    -0x4c(%ebp),%edx
f01017f8:	89 04 24             	mov    %eax,(%esp)
f01017fb:	89 54 24 04          	mov    %edx,0x4(%esp)
f01017ff:	e8 2c 07 00 00       	call   f0101f30 <__umoddi3>
f0101804:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101808:	0f be 80 89 26 10 f0 	movsbl -0xfefd977(%eax),%eax
f010180f:	89 04 24             	mov    %eax,(%esp)
f0101812:	ff 55 08             	call   *0x8(%ebp)
f0101815:	e9 d6 fe ff ff       	jmp    f01016f0 <vprintfmt+0x514>
f010181a:	8b 55 0c             	mov    0xc(%ebp),%edx
f010181d:	89 54 24 04          	mov    %edx,0x4(%esp)
f0101821:	8b 74 24 04          	mov    0x4(%esp),%esi
f0101825:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0101828:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010182c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0101833:	00 
f0101834:	8b 45 b0             	mov    -0x50(%ebp),%eax
f0101837:	8b 55 b4             	mov    -0x4c(%ebp),%edx
f010183a:	89 04 24             	mov    %eax,(%esp)
f010183d:	89 54 24 04          	mov    %edx,0x4(%esp)
f0101841:	e8 ea 06 00 00       	call   f0101f30 <__umoddi3>
f0101846:	89 74 24 04          	mov    %esi,0x4(%esp)
f010184a:	0f be 80 89 26 10 f0 	movsbl -0xfefd977(%eax),%eax
f0101851:	89 04 24             	mov    %eax,(%esp)
f0101854:	ff 55 08             	call   *0x8(%ebp)
f0101857:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010185a:	e9 ac f9 ff ff       	jmp    f010120b <vprintfmt+0x2f>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
f010185f:	83 c4 6c             	add    $0x6c,%esp
f0101862:	5b                   	pop    %ebx
f0101863:	5e                   	pop    %esi
f0101864:	5f                   	pop    %edi
f0101865:	5d                   	pop    %ebp
f0101866:	c3                   	ret    

f0101867 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0101867:	55                   	push   %ebp
f0101868:	89 e5                	mov    %esp,%ebp
f010186a:	83 ec 28             	sub    $0x28,%esp
f010186d:	8b 45 08             	mov    0x8(%ebp),%eax
f0101870:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
f0101873:	85 c0                	test   %eax,%eax
f0101875:	74 04                	je     f010187b <vsnprintf+0x14>
f0101877:	85 d2                	test   %edx,%edx
f0101879:	7f 07                	jg     f0101882 <vsnprintf+0x1b>
f010187b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0101880:	eb 3b                	jmp    f01018bd <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
f0101882:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0101885:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
f0101889:	89 45 f0             	mov    %eax,-0x10(%ebp)
f010188c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0101893:	8b 45 14             	mov    0x14(%ebp),%eax
f0101896:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010189a:	8b 45 10             	mov    0x10(%ebp),%eax
f010189d:	89 44 24 08          	mov    %eax,0x8(%esp)
f01018a1:	8d 45 ec             	lea    -0x14(%ebp),%eax
f01018a4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01018a8:	c7 04 24 bf 11 10 f0 	movl   $0xf01011bf,(%esp)
f01018af:	e8 28 f9 ff ff       	call   f01011dc <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f01018b4:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01018b7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f01018ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
f01018bd:	c9                   	leave  
f01018be:	c3                   	ret    

f01018bf <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f01018bf:	55                   	push   %ebp
f01018c0:	89 e5                	mov    %esp,%ebp
f01018c2:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
f01018c5:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
f01018c8:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01018cc:	8b 45 10             	mov    0x10(%ebp),%eax
f01018cf:	89 44 24 08          	mov    %eax,0x8(%esp)
f01018d3:	8b 45 0c             	mov    0xc(%ebp),%eax
f01018d6:	89 44 24 04          	mov    %eax,0x4(%esp)
f01018da:	8b 45 08             	mov    0x8(%ebp),%eax
f01018dd:	89 04 24             	mov    %eax,(%esp)
f01018e0:	e8 82 ff ff ff       	call   f0101867 <vsnprintf>
	va_end(ap);

	return rc;
}
f01018e5:	c9                   	leave  
f01018e6:	c3                   	ret    

f01018e7 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f01018e7:	55                   	push   %ebp
f01018e8:	89 e5                	mov    %esp,%ebp
f01018ea:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
f01018ed:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
f01018f0:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01018f4:	8b 45 10             	mov    0x10(%ebp),%eax
f01018f7:	89 44 24 08          	mov    %eax,0x8(%esp)
f01018fb:	8b 45 0c             	mov    0xc(%ebp),%eax
f01018fe:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101902:	8b 45 08             	mov    0x8(%ebp),%eax
f0101905:	89 04 24             	mov    %eax,(%esp)
f0101908:	e8 cf f8 ff ff       	call   f01011dc <vprintfmt>
	va_end(ap);
}
f010190d:	c9                   	leave  
f010190e:	c3                   	ret    
	...

f0101910 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0101910:	55                   	push   %ebp
f0101911:	89 e5                	mov    %esp,%ebp
f0101913:	57                   	push   %edi
f0101914:	56                   	push   %esi
f0101915:	53                   	push   %ebx
f0101916:	83 ec 1c             	sub    $0x1c,%esp
f0101919:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f010191c:	85 c0                	test   %eax,%eax
f010191e:	74 10                	je     f0101930 <readline+0x20>
		cprintf("%s", prompt);
f0101920:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101924:	c7 04 24 a3 26 10 f0 	movl   $0xf01026a3,(%esp)
f010192b:	e8 bf f3 ff ff       	call   f0100cef <cprintf>

	i = 0;
	echoing = iscons(0);
f0101930:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101937:	e8 4a ea ff ff       	call   f0100386 <iscons>
f010193c:	89 c7                	mov    %eax,%edi
f010193e:	be 00 00 00 00       	mov    $0x0,%esi
	while (1) {
		c = getchar();
f0101943:	e8 2d ea ff ff       	call   f0100375 <getchar>
f0101948:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f010194a:	85 c0                	test   %eax,%eax
f010194c:	79 17                	jns    f0101965 <readline+0x55>
			cprintf("read error: %e\n", c);
f010194e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101952:	c7 04 24 08 29 10 f0 	movl   $0xf0102908,(%esp)
f0101959:	e8 91 f3 ff ff       	call   f0100cef <cprintf>
f010195e:	b8 00 00 00 00       	mov    $0x0,%eax
			return NULL;
f0101963:	eb 76                	jmp    f01019db <readline+0xcb>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0101965:	83 f8 08             	cmp    $0x8,%eax
f0101968:	74 08                	je     f0101972 <readline+0x62>
f010196a:	83 f8 7f             	cmp    $0x7f,%eax
f010196d:	8d 76 00             	lea    0x0(%esi),%esi
f0101970:	75 19                	jne    f010198b <readline+0x7b>
f0101972:	85 f6                	test   %esi,%esi
f0101974:	7e 15                	jle    f010198b <readline+0x7b>
			if (echoing)
f0101976:	85 ff                	test   %edi,%edi
f0101978:	74 0c                	je     f0101986 <readline+0x76>
				cputchar('\b');
f010197a:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
f0101981:	e8 04 ec ff ff       	call   f010058a <cputchar>
			i--;
f0101986:	83 ee 01             	sub    $0x1,%esi
	while (1) {
		c = getchar();
		if (c < 0) {
			cprintf("read error: %e\n", c);
			return NULL;
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0101989:	eb b8                	jmp    f0101943 <readline+0x33>
			if (echoing)
				cputchar('\b');
			i--;
		} else if (c >= ' ' && i < BUFLEN-1) {
f010198b:	83 fb 1f             	cmp    $0x1f,%ebx
f010198e:	66 90                	xchg   %ax,%ax
f0101990:	7e 23                	jle    f01019b5 <readline+0xa5>
f0101992:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0101998:	7f 1b                	jg     f01019b5 <readline+0xa5>
			if (echoing)
f010199a:	85 ff                	test   %edi,%edi
f010199c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01019a0:	74 08                	je     f01019aa <readline+0x9a>
				cputchar(c);
f01019a2:	89 1c 24             	mov    %ebx,(%esp)
f01019a5:	e8 e0 eb ff ff       	call   f010058a <cputchar>
			buf[i++] = c;
f01019aa:	88 9e 60 35 11 f0    	mov    %bl,-0xfeecaa0(%esi)
f01019b0:	83 c6 01             	add    $0x1,%esi
f01019b3:	eb 8e                	jmp    f0101943 <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f01019b5:	83 fb 0a             	cmp    $0xa,%ebx
f01019b8:	74 05                	je     f01019bf <readline+0xaf>
f01019ba:	83 fb 0d             	cmp    $0xd,%ebx
f01019bd:	75 84                	jne    f0101943 <readline+0x33>
			if (echoing)
f01019bf:	85 ff                	test   %edi,%edi
f01019c1:	74 0c                	je     f01019cf <readline+0xbf>
				cputchar('\n');
f01019c3:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
f01019ca:	e8 bb eb ff ff       	call   f010058a <cputchar>
			buf[i] = 0;
f01019cf:	c6 86 60 35 11 f0 00 	movb   $0x0,-0xfeecaa0(%esi)
f01019d6:	b8 60 35 11 f0       	mov    $0xf0113560,%eax
			return buf;
		}
	}
}
f01019db:	83 c4 1c             	add    $0x1c,%esp
f01019de:	5b                   	pop    %ebx
f01019df:	5e                   	pop    %esi
f01019e0:	5f                   	pop    %edi
f01019e1:	5d                   	pop    %ebp
f01019e2:	c3                   	ret    
	...

f01019f0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f01019f0:	55                   	push   %ebp
f01019f1:	89 e5                	mov    %esp,%ebp
f01019f3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f01019f6:	b8 00 00 00 00       	mov    $0x0,%eax
f01019fb:	80 3a 00             	cmpb   $0x0,(%edx)
f01019fe:	74 09                	je     f0101a09 <strlen+0x19>
		n++;
f0101a00:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0101a03:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0101a07:	75 f7                	jne    f0101a00 <strlen+0x10>
		n++;
	return n;
}
f0101a09:	5d                   	pop    %ebp
f0101a0a:	c3                   	ret    

f0101a0b <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0101a0b:	55                   	push   %ebp
f0101a0c:	89 e5                	mov    %esp,%ebp
f0101a0e:	53                   	push   %ebx
f0101a0f:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0101a12:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0101a15:	85 c9                	test   %ecx,%ecx
f0101a17:	74 19                	je     f0101a32 <strnlen+0x27>
f0101a19:	80 3b 00             	cmpb   $0x0,(%ebx)
f0101a1c:	74 14                	je     f0101a32 <strnlen+0x27>
f0101a1e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
f0101a23:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0101a26:	39 c8                	cmp    %ecx,%eax
f0101a28:	74 0d                	je     f0101a37 <strnlen+0x2c>
f0101a2a:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
f0101a2e:	75 f3                	jne    f0101a23 <strnlen+0x18>
f0101a30:	eb 05                	jmp    f0101a37 <strnlen+0x2c>
f0101a32:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
f0101a37:	5b                   	pop    %ebx
f0101a38:	5d                   	pop    %ebp
f0101a39:	c3                   	ret    

f0101a3a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0101a3a:	55                   	push   %ebp
f0101a3b:	89 e5                	mov    %esp,%ebp
f0101a3d:	53                   	push   %ebx
f0101a3e:	8b 45 08             	mov    0x8(%ebp),%eax
f0101a41:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101a44:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0101a49:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
f0101a4d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f0101a50:	83 c2 01             	add    $0x1,%edx
f0101a53:	84 c9                	test   %cl,%cl
f0101a55:	75 f2                	jne    f0101a49 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f0101a57:	5b                   	pop    %ebx
f0101a58:	5d                   	pop    %ebp
f0101a59:	c3                   	ret    

f0101a5a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0101a5a:	55                   	push   %ebp
f0101a5b:	89 e5                	mov    %esp,%ebp
f0101a5d:	56                   	push   %esi
f0101a5e:	53                   	push   %ebx
f0101a5f:	8b 45 08             	mov    0x8(%ebp),%eax
f0101a62:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101a65:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0101a68:	85 f6                	test   %esi,%esi
f0101a6a:	74 18                	je     f0101a84 <strncpy+0x2a>
f0101a6c:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
f0101a71:	0f b6 1a             	movzbl (%edx),%ebx
f0101a74:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0101a77:	80 3a 01             	cmpb   $0x1,(%edx)
f0101a7a:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0101a7d:	83 c1 01             	add    $0x1,%ecx
f0101a80:	39 ce                	cmp    %ecx,%esi
f0101a82:	77 ed                	ja     f0101a71 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0101a84:	5b                   	pop    %ebx
f0101a85:	5e                   	pop    %esi
f0101a86:	5d                   	pop    %ebp
f0101a87:	c3                   	ret    

f0101a88 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0101a88:	55                   	push   %ebp
f0101a89:	89 e5                	mov    %esp,%ebp
f0101a8b:	56                   	push   %esi
f0101a8c:	53                   	push   %ebx
f0101a8d:	8b 75 08             	mov    0x8(%ebp),%esi
f0101a90:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101a93:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0101a96:	89 f0                	mov    %esi,%eax
f0101a98:	85 c9                	test   %ecx,%ecx
f0101a9a:	74 27                	je     f0101ac3 <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
f0101a9c:	83 e9 01             	sub    $0x1,%ecx
f0101a9f:	74 1d                	je     f0101abe <strlcpy+0x36>
f0101aa1:	0f b6 1a             	movzbl (%edx),%ebx
f0101aa4:	84 db                	test   %bl,%bl
f0101aa6:	74 16                	je     f0101abe <strlcpy+0x36>
			*dst++ = *src++;
f0101aa8:	88 18                	mov    %bl,(%eax)
f0101aaa:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0101aad:	83 e9 01             	sub    $0x1,%ecx
f0101ab0:	74 0e                	je     f0101ac0 <strlcpy+0x38>
			*dst++ = *src++;
f0101ab2:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0101ab5:	0f b6 1a             	movzbl (%edx),%ebx
f0101ab8:	84 db                	test   %bl,%bl
f0101aba:	75 ec                	jne    f0101aa8 <strlcpy+0x20>
f0101abc:	eb 02                	jmp    f0101ac0 <strlcpy+0x38>
f0101abe:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
f0101ac0:	c6 00 00             	movb   $0x0,(%eax)
f0101ac3:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
f0101ac5:	5b                   	pop    %ebx
f0101ac6:	5e                   	pop    %esi
f0101ac7:	5d                   	pop    %ebp
f0101ac8:	c3                   	ret    

f0101ac9 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0101ac9:	55                   	push   %ebp
f0101aca:	89 e5                	mov    %esp,%ebp
f0101acc:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0101acf:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0101ad2:	0f b6 01             	movzbl (%ecx),%eax
f0101ad5:	84 c0                	test   %al,%al
f0101ad7:	74 15                	je     f0101aee <strcmp+0x25>
f0101ad9:	3a 02                	cmp    (%edx),%al
f0101adb:	75 11                	jne    f0101aee <strcmp+0x25>
		p++, q++;
f0101add:	83 c1 01             	add    $0x1,%ecx
f0101ae0:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0101ae3:	0f b6 01             	movzbl (%ecx),%eax
f0101ae6:	84 c0                	test   %al,%al
f0101ae8:	74 04                	je     f0101aee <strcmp+0x25>
f0101aea:	3a 02                	cmp    (%edx),%al
f0101aec:	74 ef                	je     f0101add <strcmp+0x14>
f0101aee:	0f b6 c0             	movzbl %al,%eax
f0101af1:	0f b6 12             	movzbl (%edx),%edx
f0101af4:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0101af6:	5d                   	pop    %ebp
f0101af7:	c3                   	ret    

f0101af8 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0101af8:	55                   	push   %ebp
f0101af9:	89 e5                	mov    %esp,%ebp
f0101afb:	53                   	push   %ebx
f0101afc:	8b 55 08             	mov    0x8(%ebp),%edx
f0101aff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0101b02:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
f0101b05:	85 c0                	test   %eax,%eax
f0101b07:	74 23                	je     f0101b2c <strncmp+0x34>
f0101b09:	0f b6 1a             	movzbl (%edx),%ebx
f0101b0c:	84 db                	test   %bl,%bl
f0101b0e:	74 24                	je     f0101b34 <strncmp+0x3c>
f0101b10:	3a 19                	cmp    (%ecx),%bl
f0101b12:	75 20                	jne    f0101b34 <strncmp+0x3c>
f0101b14:	83 e8 01             	sub    $0x1,%eax
f0101b17:	74 13                	je     f0101b2c <strncmp+0x34>
		n--, p++, q++;
f0101b19:	83 c2 01             	add    $0x1,%edx
f0101b1c:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0101b1f:	0f b6 1a             	movzbl (%edx),%ebx
f0101b22:	84 db                	test   %bl,%bl
f0101b24:	74 0e                	je     f0101b34 <strncmp+0x3c>
f0101b26:	3a 19                	cmp    (%ecx),%bl
f0101b28:	74 ea                	je     f0101b14 <strncmp+0x1c>
f0101b2a:	eb 08                	jmp    f0101b34 <strncmp+0x3c>
f0101b2c:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0101b31:	5b                   	pop    %ebx
f0101b32:	5d                   	pop    %ebp
f0101b33:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0101b34:	0f b6 02             	movzbl (%edx),%eax
f0101b37:	0f b6 11             	movzbl (%ecx),%edx
f0101b3a:	29 d0                	sub    %edx,%eax
f0101b3c:	eb f3                	jmp    f0101b31 <strncmp+0x39>

f0101b3e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0101b3e:	55                   	push   %ebp
f0101b3f:	89 e5                	mov    %esp,%ebp
f0101b41:	8b 45 08             	mov    0x8(%ebp),%eax
f0101b44:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0101b48:	0f b6 10             	movzbl (%eax),%edx
f0101b4b:	84 d2                	test   %dl,%dl
f0101b4d:	74 15                	je     f0101b64 <strchr+0x26>
		if (*s == c)
f0101b4f:	38 ca                	cmp    %cl,%dl
f0101b51:	75 07                	jne    f0101b5a <strchr+0x1c>
f0101b53:	eb 14                	jmp    f0101b69 <strchr+0x2b>
f0101b55:	38 ca                	cmp    %cl,%dl
f0101b57:	90                   	nop
f0101b58:	74 0f                	je     f0101b69 <strchr+0x2b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0101b5a:	83 c0 01             	add    $0x1,%eax
f0101b5d:	0f b6 10             	movzbl (%eax),%edx
f0101b60:	84 d2                	test   %dl,%dl
f0101b62:	75 f1                	jne    f0101b55 <strchr+0x17>
f0101b64:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
f0101b69:	5d                   	pop    %ebp
f0101b6a:	c3                   	ret    

f0101b6b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0101b6b:	55                   	push   %ebp
f0101b6c:	89 e5                	mov    %esp,%ebp
f0101b6e:	8b 45 08             	mov    0x8(%ebp),%eax
f0101b71:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0101b75:	0f b6 10             	movzbl (%eax),%edx
f0101b78:	84 d2                	test   %dl,%dl
f0101b7a:	74 18                	je     f0101b94 <strfind+0x29>
		if (*s == c)
f0101b7c:	38 ca                	cmp    %cl,%dl
f0101b7e:	75 0a                	jne    f0101b8a <strfind+0x1f>
f0101b80:	eb 12                	jmp    f0101b94 <strfind+0x29>
f0101b82:	38 ca                	cmp    %cl,%dl
f0101b84:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101b88:	74 0a                	je     f0101b94 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f0101b8a:	83 c0 01             	add    $0x1,%eax
f0101b8d:	0f b6 10             	movzbl (%eax),%edx
f0101b90:	84 d2                	test   %dl,%dl
f0101b92:	75 ee                	jne    f0101b82 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
f0101b94:	5d                   	pop    %ebp
f0101b95:	c3                   	ret    

f0101b96 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0101b96:	55                   	push   %ebp
f0101b97:	89 e5                	mov    %esp,%ebp
f0101b99:	83 ec 0c             	sub    $0xc,%esp
f0101b9c:	89 1c 24             	mov    %ebx,(%esp)
f0101b9f:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101ba3:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0101ba7:	8b 7d 08             	mov    0x8(%ebp),%edi
f0101baa:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101bad:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0101bb0:	85 c9                	test   %ecx,%ecx
f0101bb2:	74 30                	je     f0101be4 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0101bb4:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0101bba:	75 25                	jne    f0101be1 <memset+0x4b>
f0101bbc:	f6 c1 03             	test   $0x3,%cl
f0101bbf:	75 20                	jne    f0101be1 <memset+0x4b>
		c &= 0xFF;
f0101bc1:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0101bc4:	89 d3                	mov    %edx,%ebx
f0101bc6:	c1 e3 08             	shl    $0x8,%ebx
f0101bc9:	89 d6                	mov    %edx,%esi
f0101bcb:	c1 e6 18             	shl    $0x18,%esi
f0101bce:	89 d0                	mov    %edx,%eax
f0101bd0:	c1 e0 10             	shl    $0x10,%eax
f0101bd3:	09 f0                	or     %esi,%eax
f0101bd5:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
f0101bd7:	09 d8                	or     %ebx,%eax
f0101bd9:	c1 e9 02             	shr    $0x2,%ecx
f0101bdc:	fc                   	cld    
f0101bdd:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0101bdf:	eb 03                	jmp    f0101be4 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0101be1:	fc                   	cld    
f0101be2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0101be4:	89 f8                	mov    %edi,%eax
f0101be6:	8b 1c 24             	mov    (%esp),%ebx
f0101be9:	8b 74 24 04          	mov    0x4(%esp),%esi
f0101bed:	8b 7c 24 08          	mov    0x8(%esp),%edi
f0101bf1:	89 ec                	mov    %ebp,%esp
f0101bf3:	5d                   	pop    %ebp
f0101bf4:	c3                   	ret    

f0101bf5 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0101bf5:	55                   	push   %ebp
f0101bf6:	89 e5                	mov    %esp,%ebp
f0101bf8:	83 ec 08             	sub    $0x8,%esp
f0101bfb:	89 34 24             	mov    %esi,(%esp)
f0101bfe:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101c02:	8b 45 08             	mov    0x8(%ebp),%eax
f0101c05:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
f0101c08:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
f0101c0b:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
f0101c0d:	39 c6                	cmp    %eax,%esi
f0101c0f:	73 35                	jae    f0101c46 <memmove+0x51>
f0101c11:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0101c14:	39 d0                	cmp    %edx,%eax
f0101c16:	73 2e                	jae    f0101c46 <memmove+0x51>
		s += n;
		d += n;
f0101c18:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0101c1a:	f6 c2 03             	test   $0x3,%dl
f0101c1d:	75 1b                	jne    f0101c3a <memmove+0x45>
f0101c1f:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0101c25:	75 13                	jne    f0101c3a <memmove+0x45>
f0101c27:	f6 c1 03             	test   $0x3,%cl
f0101c2a:	75 0e                	jne    f0101c3a <memmove+0x45>
			asm volatile("std; rep movsl\n"
f0101c2c:	83 ef 04             	sub    $0x4,%edi
f0101c2f:	8d 72 fc             	lea    -0x4(%edx),%esi
f0101c32:	c1 e9 02             	shr    $0x2,%ecx
f0101c35:	fd                   	std    
f0101c36:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0101c38:	eb 09                	jmp    f0101c43 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0101c3a:	83 ef 01             	sub    $0x1,%edi
f0101c3d:	8d 72 ff             	lea    -0x1(%edx),%esi
f0101c40:	fd                   	std    
f0101c41:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0101c43:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0101c44:	eb 20                	jmp    f0101c66 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0101c46:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0101c4c:	75 15                	jne    f0101c63 <memmove+0x6e>
f0101c4e:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0101c54:	75 0d                	jne    f0101c63 <memmove+0x6e>
f0101c56:	f6 c1 03             	test   $0x3,%cl
f0101c59:	75 08                	jne    f0101c63 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
f0101c5b:	c1 e9 02             	shr    $0x2,%ecx
f0101c5e:	fc                   	cld    
f0101c5f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0101c61:	eb 03                	jmp    f0101c66 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0101c63:	fc                   	cld    
f0101c64:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0101c66:	8b 34 24             	mov    (%esp),%esi
f0101c69:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0101c6d:	89 ec                	mov    %ebp,%esp
f0101c6f:	5d                   	pop    %ebp
f0101c70:	c3                   	ret    

f0101c71 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
f0101c71:	55                   	push   %ebp
f0101c72:	89 e5                	mov    %esp,%ebp
f0101c74:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f0101c77:	8b 45 10             	mov    0x10(%ebp),%eax
f0101c7a:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101c7e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101c81:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101c85:	8b 45 08             	mov    0x8(%ebp),%eax
f0101c88:	89 04 24             	mov    %eax,(%esp)
f0101c8b:	e8 65 ff ff ff       	call   f0101bf5 <memmove>
}
f0101c90:	c9                   	leave  
f0101c91:	c3                   	ret    

f0101c92 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0101c92:	55                   	push   %ebp
f0101c93:	89 e5                	mov    %esp,%ebp
f0101c95:	57                   	push   %edi
f0101c96:	56                   	push   %esi
f0101c97:	53                   	push   %ebx
f0101c98:	8b 75 08             	mov    0x8(%ebp),%esi
f0101c9b:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0101c9e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0101ca1:	85 c9                	test   %ecx,%ecx
f0101ca3:	74 36                	je     f0101cdb <memcmp+0x49>
		if (*s1 != *s2)
f0101ca5:	0f b6 06             	movzbl (%esi),%eax
f0101ca8:	0f b6 1f             	movzbl (%edi),%ebx
f0101cab:	38 d8                	cmp    %bl,%al
f0101cad:	74 20                	je     f0101ccf <memcmp+0x3d>
f0101caf:	eb 14                	jmp    f0101cc5 <memcmp+0x33>
f0101cb1:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
f0101cb6:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
f0101cbb:	83 c2 01             	add    $0x1,%edx
f0101cbe:	83 e9 01             	sub    $0x1,%ecx
f0101cc1:	38 d8                	cmp    %bl,%al
f0101cc3:	74 12                	je     f0101cd7 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
f0101cc5:	0f b6 c0             	movzbl %al,%eax
f0101cc8:	0f b6 db             	movzbl %bl,%ebx
f0101ccb:	29 d8                	sub    %ebx,%eax
f0101ccd:	eb 11                	jmp    f0101ce0 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0101ccf:	83 e9 01             	sub    $0x1,%ecx
f0101cd2:	ba 00 00 00 00       	mov    $0x0,%edx
f0101cd7:	85 c9                	test   %ecx,%ecx
f0101cd9:	75 d6                	jne    f0101cb1 <memcmp+0x1f>
f0101cdb:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
f0101ce0:	5b                   	pop    %ebx
f0101ce1:	5e                   	pop    %esi
f0101ce2:	5f                   	pop    %edi
f0101ce3:	5d                   	pop    %ebp
f0101ce4:	c3                   	ret    

f0101ce5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0101ce5:	55                   	push   %ebp
f0101ce6:	89 e5                	mov    %esp,%ebp
f0101ce8:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f0101ceb:	89 c2                	mov    %eax,%edx
f0101ced:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0101cf0:	39 d0                	cmp    %edx,%eax
f0101cf2:	73 15                	jae    f0101d09 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
f0101cf4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
f0101cf8:	38 08                	cmp    %cl,(%eax)
f0101cfa:	75 06                	jne    f0101d02 <memfind+0x1d>
f0101cfc:	eb 0b                	jmp    f0101d09 <memfind+0x24>
f0101cfe:	38 08                	cmp    %cl,(%eax)
f0101d00:	74 07                	je     f0101d09 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0101d02:	83 c0 01             	add    $0x1,%eax
f0101d05:	39 c2                	cmp    %eax,%edx
f0101d07:	77 f5                	ja     f0101cfe <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0101d09:	5d                   	pop    %ebp
f0101d0a:	c3                   	ret    

f0101d0b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0101d0b:	55                   	push   %ebp
f0101d0c:	89 e5                	mov    %esp,%ebp
f0101d0e:	57                   	push   %edi
f0101d0f:	56                   	push   %esi
f0101d10:	53                   	push   %ebx
f0101d11:	83 ec 04             	sub    $0x4,%esp
f0101d14:	8b 55 08             	mov    0x8(%ebp),%edx
f0101d17:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0101d1a:	0f b6 02             	movzbl (%edx),%eax
f0101d1d:	3c 20                	cmp    $0x20,%al
f0101d1f:	74 04                	je     f0101d25 <strtol+0x1a>
f0101d21:	3c 09                	cmp    $0x9,%al
f0101d23:	75 0e                	jne    f0101d33 <strtol+0x28>
		s++;
f0101d25:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0101d28:	0f b6 02             	movzbl (%edx),%eax
f0101d2b:	3c 20                	cmp    $0x20,%al
f0101d2d:	74 f6                	je     f0101d25 <strtol+0x1a>
f0101d2f:	3c 09                	cmp    $0x9,%al
f0101d31:	74 f2                	je     f0101d25 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
f0101d33:	3c 2b                	cmp    $0x2b,%al
f0101d35:	75 0c                	jne    f0101d43 <strtol+0x38>
		s++;
f0101d37:	83 c2 01             	add    $0x1,%edx
f0101d3a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
f0101d41:	eb 15                	jmp    f0101d58 <strtol+0x4d>
	else if (*s == '-')
f0101d43:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
f0101d4a:	3c 2d                	cmp    $0x2d,%al
f0101d4c:	75 0a                	jne    f0101d58 <strtol+0x4d>
		s++, neg = 1;
f0101d4e:	83 c2 01             	add    $0x1,%edx
f0101d51:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0101d58:	85 db                	test   %ebx,%ebx
f0101d5a:	0f 94 c0             	sete   %al
f0101d5d:	74 05                	je     f0101d64 <strtol+0x59>
f0101d5f:	83 fb 10             	cmp    $0x10,%ebx
f0101d62:	75 18                	jne    f0101d7c <strtol+0x71>
f0101d64:	80 3a 30             	cmpb   $0x30,(%edx)
f0101d67:	75 13                	jne    f0101d7c <strtol+0x71>
f0101d69:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f0101d6d:	8d 76 00             	lea    0x0(%esi),%esi
f0101d70:	75 0a                	jne    f0101d7c <strtol+0x71>
		s += 2, base = 16;
f0101d72:	83 c2 02             	add    $0x2,%edx
f0101d75:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0101d7a:	eb 15                	jmp    f0101d91 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0101d7c:	84 c0                	test   %al,%al
f0101d7e:	66 90                	xchg   %ax,%ax
f0101d80:	74 0f                	je     f0101d91 <strtol+0x86>
f0101d82:	bb 0a 00 00 00       	mov    $0xa,%ebx
f0101d87:	80 3a 30             	cmpb   $0x30,(%edx)
f0101d8a:	75 05                	jne    f0101d91 <strtol+0x86>
		s++, base = 8;
f0101d8c:	83 c2 01             	add    $0x1,%edx
f0101d8f:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0101d91:	b8 00 00 00 00       	mov    $0x0,%eax
f0101d96:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0101d98:	0f b6 0a             	movzbl (%edx),%ecx
f0101d9b:	89 cf                	mov    %ecx,%edi
f0101d9d:	8d 59 d0             	lea    -0x30(%ecx),%ebx
f0101da0:	80 fb 09             	cmp    $0x9,%bl
f0101da3:	77 08                	ja     f0101dad <strtol+0xa2>
			dig = *s - '0';
f0101da5:	0f be c9             	movsbl %cl,%ecx
f0101da8:	83 e9 30             	sub    $0x30,%ecx
f0101dab:	eb 1e                	jmp    f0101dcb <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
f0101dad:	8d 5f 9f             	lea    -0x61(%edi),%ebx
f0101db0:	80 fb 19             	cmp    $0x19,%bl
f0101db3:	77 08                	ja     f0101dbd <strtol+0xb2>
			dig = *s - 'a' + 10;
f0101db5:	0f be c9             	movsbl %cl,%ecx
f0101db8:	83 e9 57             	sub    $0x57,%ecx
f0101dbb:	eb 0e                	jmp    f0101dcb <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
f0101dbd:	8d 5f bf             	lea    -0x41(%edi),%ebx
f0101dc0:	80 fb 19             	cmp    $0x19,%bl
f0101dc3:	77 15                	ja     f0101dda <strtol+0xcf>
			dig = *s - 'A' + 10;
f0101dc5:	0f be c9             	movsbl %cl,%ecx
f0101dc8:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f0101dcb:	39 f1                	cmp    %esi,%ecx
f0101dcd:	7d 0b                	jge    f0101dda <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
f0101dcf:	83 c2 01             	add    $0x1,%edx
f0101dd2:	0f af c6             	imul   %esi,%eax
f0101dd5:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
f0101dd8:	eb be                	jmp    f0101d98 <strtol+0x8d>
f0101dda:	89 c1                	mov    %eax,%ecx

	if (endptr)
f0101ddc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0101de0:	74 05                	je     f0101de7 <strtol+0xdc>
		*endptr = (char *) s;
f0101de2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101de5:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
f0101de7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
f0101deb:	74 04                	je     f0101df1 <strtol+0xe6>
f0101ded:	89 c8                	mov    %ecx,%eax
f0101def:	f7 d8                	neg    %eax
}
f0101df1:	83 c4 04             	add    $0x4,%esp
f0101df4:	5b                   	pop    %ebx
f0101df5:	5e                   	pop    %esi
f0101df6:	5f                   	pop    %edi
f0101df7:	5d                   	pop    %ebp
f0101df8:	c3                   	ret    
f0101df9:	00 00                	add    %al,(%eax)
f0101dfb:	00 00                	add    %al,(%eax)
f0101dfd:	00 00                	add    %al,(%eax)
	...

f0101e00 <__udivdi3>:
f0101e00:	55                   	push   %ebp
f0101e01:	89 e5                	mov    %esp,%ebp
f0101e03:	57                   	push   %edi
f0101e04:	56                   	push   %esi
f0101e05:	83 ec 10             	sub    $0x10,%esp
f0101e08:	8b 45 14             	mov    0x14(%ebp),%eax
f0101e0b:	8b 55 08             	mov    0x8(%ebp),%edx
f0101e0e:	8b 75 10             	mov    0x10(%ebp),%esi
f0101e11:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0101e14:	85 c0                	test   %eax,%eax
f0101e16:	89 55 f0             	mov    %edx,-0x10(%ebp)
f0101e19:	75 35                	jne    f0101e50 <__udivdi3+0x50>
f0101e1b:	39 fe                	cmp    %edi,%esi
f0101e1d:	77 61                	ja     f0101e80 <__udivdi3+0x80>
f0101e1f:	85 f6                	test   %esi,%esi
f0101e21:	75 0b                	jne    f0101e2e <__udivdi3+0x2e>
f0101e23:	b8 01 00 00 00       	mov    $0x1,%eax
f0101e28:	31 d2                	xor    %edx,%edx
f0101e2a:	f7 f6                	div    %esi
f0101e2c:	89 c6                	mov    %eax,%esi
f0101e2e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
f0101e31:	31 d2                	xor    %edx,%edx
f0101e33:	89 f8                	mov    %edi,%eax
f0101e35:	f7 f6                	div    %esi
f0101e37:	89 c7                	mov    %eax,%edi
f0101e39:	89 c8                	mov    %ecx,%eax
f0101e3b:	f7 f6                	div    %esi
f0101e3d:	89 c1                	mov    %eax,%ecx
f0101e3f:	89 fa                	mov    %edi,%edx
f0101e41:	89 c8                	mov    %ecx,%eax
f0101e43:	83 c4 10             	add    $0x10,%esp
f0101e46:	5e                   	pop    %esi
f0101e47:	5f                   	pop    %edi
f0101e48:	5d                   	pop    %ebp
f0101e49:	c3                   	ret    
f0101e4a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0101e50:	39 f8                	cmp    %edi,%eax
f0101e52:	77 1c                	ja     f0101e70 <__udivdi3+0x70>
f0101e54:	0f bd d0             	bsr    %eax,%edx
f0101e57:	83 f2 1f             	xor    $0x1f,%edx
f0101e5a:	89 55 f4             	mov    %edx,-0xc(%ebp)
f0101e5d:	75 39                	jne    f0101e98 <__udivdi3+0x98>
f0101e5f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
f0101e62:	0f 86 a0 00 00 00    	jbe    f0101f08 <__udivdi3+0x108>
f0101e68:	39 f8                	cmp    %edi,%eax
f0101e6a:	0f 82 98 00 00 00    	jb     f0101f08 <__udivdi3+0x108>
f0101e70:	31 ff                	xor    %edi,%edi
f0101e72:	31 c9                	xor    %ecx,%ecx
f0101e74:	89 c8                	mov    %ecx,%eax
f0101e76:	89 fa                	mov    %edi,%edx
f0101e78:	83 c4 10             	add    $0x10,%esp
f0101e7b:	5e                   	pop    %esi
f0101e7c:	5f                   	pop    %edi
f0101e7d:	5d                   	pop    %ebp
f0101e7e:	c3                   	ret    
f0101e7f:	90                   	nop
f0101e80:	89 d1                	mov    %edx,%ecx
f0101e82:	89 fa                	mov    %edi,%edx
f0101e84:	89 c8                	mov    %ecx,%eax
f0101e86:	31 ff                	xor    %edi,%edi
f0101e88:	f7 f6                	div    %esi
f0101e8a:	89 c1                	mov    %eax,%ecx
f0101e8c:	89 fa                	mov    %edi,%edx
f0101e8e:	89 c8                	mov    %ecx,%eax
f0101e90:	83 c4 10             	add    $0x10,%esp
f0101e93:	5e                   	pop    %esi
f0101e94:	5f                   	pop    %edi
f0101e95:	5d                   	pop    %ebp
f0101e96:	c3                   	ret    
f0101e97:	90                   	nop
f0101e98:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
f0101e9c:	89 f2                	mov    %esi,%edx
f0101e9e:	d3 e0                	shl    %cl,%eax
f0101ea0:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0101ea3:	b8 20 00 00 00       	mov    $0x20,%eax
f0101ea8:	2b 45 f4             	sub    -0xc(%ebp),%eax
f0101eab:	89 c1                	mov    %eax,%ecx
f0101ead:	d3 ea                	shr    %cl,%edx
f0101eaf:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
f0101eb3:	0b 55 ec             	or     -0x14(%ebp),%edx
f0101eb6:	d3 e6                	shl    %cl,%esi
f0101eb8:	89 c1                	mov    %eax,%ecx
f0101eba:	89 75 e8             	mov    %esi,-0x18(%ebp)
f0101ebd:	89 fe                	mov    %edi,%esi
f0101ebf:	d3 ee                	shr    %cl,%esi
f0101ec1:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
f0101ec5:	89 55 ec             	mov    %edx,-0x14(%ebp)
f0101ec8:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0101ecb:	d3 e7                	shl    %cl,%edi
f0101ecd:	89 c1                	mov    %eax,%ecx
f0101ecf:	d3 ea                	shr    %cl,%edx
f0101ed1:	09 d7                	or     %edx,%edi
f0101ed3:	89 f2                	mov    %esi,%edx
f0101ed5:	89 f8                	mov    %edi,%eax
f0101ed7:	f7 75 ec             	divl   -0x14(%ebp)
f0101eda:	89 d6                	mov    %edx,%esi
f0101edc:	89 c7                	mov    %eax,%edi
f0101ede:	f7 65 e8             	mull   -0x18(%ebp)
f0101ee1:	39 d6                	cmp    %edx,%esi
f0101ee3:	89 55 ec             	mov    %edx,-0x14(%ebp)
f0101ee6:	72 30                	jb     f0101f18 <__udivdi3+0x118>
f0101ee8:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0101eeb:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
f0101eef:	d3 e2                	shl    %cl,%edx
f0101ef1:	39 c2                	cmp    %eax,%edx
f0101ef3:	73 05                	jae    f0101efa <__udivdi3+0xfa>
f0101ef5:	3b 75 ec             	cmp    -0x14(%ebp),%esi
f0101ef8:	74 1e                	je     f0101f18 <__udivdi3+0x118>
f0101efa:	89 f9                	mov    %edi,%ecx
f0101efc:	31 ff                	xor    %edi,%edi
f0101efe:	e9 71 ff ff ff       	jmp    f0101e74 <__udivdi3+0x74>
f0101f03:	90                   	nop
f0101f04:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101f08:	31 ff                	xor    %edi,%edi
f0101f0a:	b9 01 00 00 00       	mov    $0x1,%ecx
f0101f0f:	e9 60 ff ff ff       	jmp    f0101e74 <__udivdi3+0x74>
f0101f14:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101f18:	8d 4f ff             	lea    -0x1(%edi),%ecx
f0101f1b:	31 ff                	xor    %edi,%edi
f0101f1d:	89 c8                	mov    %ecx,%eax
f0101f1f:	89 fa                	mov    %edi,%edx
f0101f21:	83 c4 10             	add    $0x10,%esp
f0101f24:	5e                   	pop    %esi
f0101f25:	5f                   	pop    %edi
f0101f26:	5d                   	pop    %ebp
f0101f27:	c3                   	ret    
	...

f0101f30 <__umoddi3>:
f0101f30:	55                   	push   %ebp
f0101f31:	89 e5                	mov    %esp,%ebp
f0101f33:	57                   	push   %edi
f0101f34:	56                   	push   %esi
f0101f35:	83 ec 20             	sub    $0x20,%esp
f0101f38:	8b 55 14             	mov    0x14(%ebp),%edx
f0101f3b:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0101f3e:	8b 7d 10             	mov    0x10(%ebp),%edi
f0101f41:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101f44:	85 d2                	test   %edx,%edx
f0101f46:	89 c8                	mov    %ecx,%eax
f0101f48:	89 4d f4             	mov    %ecx,-0xc(%ebp)
f0101f4b:	75 13                	jne    f0101f60 <__umoddi3+0x30>
f0101f4d:	39 f7                	cmp    %esi,%edi
f0101f4f:	76 3f                	jbe    f0101f90 <__umoddi3+0x60>
f0101f51:	89 f2                	mov    %esi,%edx
f0101f53:	f7 f7                	div    %edi
f0101f55:	89 d0                	mov    %edx,%eax
f0101f57:	31 d2                	xor    %edx,%edx
f0101f59:	83 c4 20             	add    $0x20,%esp
f0101f5c:	5e                   	pop    %esi
f0101f5d:	5f                   	pop    %edi
f0101f5e:	5d                   	pop    %ebp
f0101f5f:	c3                   	ret    
f0101f60:	39 f2                	cmp    %esi,%edx
f0101f62:	77 4c                	ja     f0101fb0 <__umoddi3+0x80>
f0101f64:	0f bd ca             	bsr    %edx,%ecx
f0101f67:	83 f1 1f             	xor    $0x1f,%ecx
f0101f6a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0101f6d:	75 51                	jne    f0101fc0 <__umoddi3+0x90>
f0101f6f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
f0101f72:	0f 87 e0 00 00 00    	ja     f0102058 <__umoddi3+0x128>
f0101f78:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101f7b:	29 f8                	sub    %edi,%eax
f0101f7d:	19 d6                	sbb    %edx,%esi
f0101f7f:	89 45 f4             	mov    %eax,-0xc(%ebp)
f0101f82:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101f85:	89 f2                	mov    %esi,%edx
f0101f87:	83 c4 20             	add    $0x20,%esp
f0101f8a:	5e                   	pop    %esi
f0101f8b:	5f                   	pop    %edi
f0101f8c:	5d                   	pop    %ebp
f0101f8d:	c3                   	ret    
f0101f8e:	66 90                	xchg   %ax,%ax
f0101f90:	85 ff                	test   %edi,%edi
f0101f92:	75 0b                	jne    f0101f9f <__umoddi3+0x6f>
f0101f94:	b8 01 00 00 00       	mov    $0x1,%eax
f0101f99:	31 d2                	xor    %edx,%edx
f0101f9b:	f7 f7                	div    %edi
f0101f9d:	89 c7                	mov    %eax,%edi
f0101f9f:	89 f0                	mov    %esi,%eax
f0101fa1:	31 d2                	xor    %edx,%edx
f0101fa3:	f7 f7                	div    %edi
f0101fa5:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101fa8:	f7 f7                	div    %edi
f0101faa:	eb a9                	jmp    f0101f55 <__umoddi3+0x25>
f0101fac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101fb0:	89 c8                	mov    %ecx,%eax
f0101fb2:	89 f2                	mov    %esi,%edx
f0101fb4:	83 c4 20             	add    $0x20,%esp
f0101fb7:	5e                   	pop    %esi
f0101fb8:	5f                   	pop    %edi
f0101fb9:	5d                   	pop    %ebp
f0101fba:	c3                   	ret    
f0101fbb:	90                   	nop
f0101fbc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101fc0:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0101fc4:	d3 e2                	shl    %cl,%edx
f0101fc6:	89 55 f4             	mov    %edx,-0xc(%ebp)
f0101fc9:	ba 20 00 00 00       	mov    $0x20,%edx
f0101fce:	2b 55 f0             	sub    -0x10(%ebp),%edx
f0101fd1:	89 55 ec             	mov    %edx,-0x14(%ebp)
f0101fd4:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f0101fd8:	89 fa                	mov    %edi,%edx
f0101fda:	d3 ea                	shr    %cl,%edx
f0101fdc:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0101fe0:	0b 55 f4             	or     -0xc(%ebp),%edx
f0101fe3:	d3 e7                	shl    %cl,%edi
f0101fe5:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f0101fe9:	89 55 f4             	mov    %edx,-0xc(%ebp)
f0101fec:	89 f2                	mov    %esi,%edx
f0101fee:	89 7d e8             	mov    %edi,-0x18(%ebp)
f0101ff1:	89 c7                	mov    %eax,%edi
f0101ff3:	d3 ea                	shr    %cl,%edx
f0101ff5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0101ff9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0101ffc:	89 c2                	mov    %eax,%edx
f0101ffe:	d3 e6                	shl    %cl,%esi
f0102000:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f0102004:	d3 ea                	shr    %cl,%edx
f0102006:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f010200a:	09 d6                	or     %edx,%esi
f010200c:	89 f0                	mov    %esi,%eax
f010200e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0102011:	d3 e7                	shl    %cl,%edi
f0102013:	89 f2                	mov    %esi,%edx
f0102015:	f7 75 f4             	divl   -0xc(%ebp)
f0102018:	89 d6                	mov    %edx,%esi
f010201a:	f7 65 e8             	mull   -0x18(%ebp)
f010201d:	39 d6                	cmp    %edx,%esi
f010201f:	72 2b                	jb     f010204c <__umoddi3+0x11c>
f0102021:	39 c7                	cmp    %eax,%edi
f0102023:	72 23                	jb     f0102048 <__umoddi3+0x118>
f0102025:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0102029:	29 c7                	sub    %eax,%edi
f010202b:	19 d6                	sbb    %edx,%esi
f010202d:	89 f0                	mov    %esi,%eax
f010202f:	89 f2                	mov    %esi,%edx
f0102031:	d3 ef                	shr    %cl,%edi
f0102033:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f0102037:	d3 e0                	shl    %cl,%eax
f0102039:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f010203d:	09 f8                	or     %edi,%eax
f010203f:	d3 ea                	shr    %cl,%edx
f0102041:	83 c4 20             	add    $0x20,%esp
f0102044:	5e                   	pop    %esi
f0102045:	5f                   	pop    %edi
f0102046:	5d                   	pop    %ebp
f0102047:	c3                   	ret    
f0102048:	39 d6                	cmp    %edx,%esi
f010204a:	75 d9                	jne    f0102025 <__umoddi3+0xf5>
f010204c:	2b 45 e8             	sub    -0x18(%ebp),%eax
f010204f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
f0102052:	eb d1                	jmp    f0102025 <__umoddi3+0xf5>
f0102054:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0102058:	39 f2                	cmp    %esi,%edx
f010205a:	0f 82 18 ff ff ff    	jb     f0101f78 <__umoddi3+0x48>
f0102060:	e9 1d ff ff ff       	jmp    f0101f82 <__umoddi3+0x52>
