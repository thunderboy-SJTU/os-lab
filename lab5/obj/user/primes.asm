
obj/user/primes.debug:     file format elf32-i386


Disassembly of section .text:

00800020 <_start>:
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	cmpl $USTACKTOP, %esp
  800020:	81 fc 00 e0 bf ee    	cmp    $0xeebfe000,%esp
	jne args_exist
  800026:	75 04                	jne    80002c <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
  800028:	6a 00                	push   $0x0
	pushl $0
  80002a:	6a 00                	push   $0x0

0080002c <args_exist>:

args_exist:
	call libmain
  80002c:	e8 1f 01 00 00       	call   800150 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <primeproc>:

#include <inc/lib.h>

unsigned
primeproc(void)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	83 ec 2c             	sub    $0x2c,%esp
	int i, id, p;
	envid_t envid;

	// fetch a prime from our left neighbor
top:
	p = ipc_recv(&envid, 0, 0);
  80003d:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  800040:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800047:	00 
  800048:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80004f:	00 
  800050:	89 34 24             	mov    %esi,(%esp)
  800053:	e8 91 19 00 00       	call   8019e9 <ipc_recv>
  800058:	89 c3                	mov    %eax,%ebx
	cprintf("CPU %d: %d ", thisenv->env_cpunum, p);
  80005a:	a1 04 40 80 00       	mov    0x804004,%eax
  80005f:	8b 40 5c             	mov    0x5c(%eax),%eax
  800062:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800066:	89 44 24 04          	mov    %eax,0x4(%esp)
  80006a:	c7 04 24 20 26 80 00 	movl   $0x802620,(%esp)
  800071:	e8 03 02 00 00       	call   800279 <cprintf>

	// fork a right neighbor to continue the chain
	if ((id = fork()) < 0)
  800076:	e8 17 15 00 00       	call   801592 <fork>
  80007b:	89 c7                	mov    %eax,%edi
  80007d:	85 c0                	test   %eax,%eax
  80007f:	79 20                	jns    8000a1 <primeproc+0x6d>
		panic("fork: %e", id);
  800081:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800085:	c7 44 24 08 33 2a 80 	movl   $0x802a33,0x8(%esp)
  80008c:	00 
  80008d:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  800094:	00 
  800095:	c7 04 24 2c 26 80 00 	movl   $0x80262c,(%esp)
  80009c:	e8 1f 01 00 00       	call   8001c0 <_panic>
	if (id == 0)
  8000a1:	85 c0                	test   %eax,%eax
  8000a3:	74 9b                	je     800040 <primeproc+0xc>
		goto top;

	// filter out multiples of our prime
	while (1) {
		i = ipc_recv(&envid, 0, 0);
  8000a5:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  8000a8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000af:	00 
  8000b0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000b7:	00 
  8000b8:	89 34 24             	mov    %esi,(%esp)
  8000bb:	e8 29 19 00 00       	call   8019e9 <ipc_recv>
  8000c0:	89 c1                	mov    %eax,%ecx
		if (i % p)
  8000c2:	89 c2                	mov    %eax,%edx
  8000c4:	c1 fa 1f             	sar    $0x1f,%edx
  8000c7:	f7 fb                	idiv   %ebx
  8000c9:	85 d2                	test   %edx,%edx
  8000cb:	74 db                	je     8000a8 <primeproc+0x74>
			ipc_send(id, i, 0, 0);
  8000cd:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8000d4:	00 
  8000d5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000dc:	00 
  8000dd:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8000e1:	89 3c 24             	mov    %edi,(%esp)
  8000e4:	e8 82 18 00 00       	call   80196b <ipc_send>
  8000e9:	eb bd                	jmp    8000a8 <primeproc+0x74>

008000eb <umain>:
	}
}

void
umain(int argc, char **argv)
{
  8000eb:	55                   	push   %ebp
  8000ec:	89 e5                	mov    %esp,%ebp
  8000ee:	56                   	push   %esi
  8000ef:	53                   	push   %ebx
  8000f0:	83 ec 10             	sub    $0x10,%esp
	int i, id;

	// fork the first prime process in the chain
	if ((id = fork()) < 0)
  8000f3:	e8 9a 14 00 00       	call   801592 <fork>
  8000f8:	89 c6                	mov    %eax,%esi
  8000fa:	85 c0                	test   %eax,%eax
  8000fc:	79 20                	jns    80011e <umain+0x33>
		panic("fork: %e", id);
  8000fe:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800102:	c7 44 24 08 33 2a 80 	movl   $0x802a33,0x8(%esp)
  800109:	00 
  80010a:	c7 44 24 04 2d 00 00 	movl   $0x2d,0x4(%esp)
  800111:	00 
  800112:	c7 04 24 2c 26 80 00 	movl   $0x80262c,(%esp)
  800119:	e8 a2 00 00 00       	call   8001c0 <_panic>
	if (id == 0)
  80011e:	bb 02 00 00 00       	mov    $0x2,%ebx
  800123:	85 c0                	test   %eax,%eax
  800125:	75 05                	jne    80012c <umain+0x41>
		primeproc();
  800127:	e8 08 ff ff ff       	call   800034 <primeproc>

	// feed all the integers through
	for (i = 2; ; i++)
		ipc_send(id, i, 0, 0);
  80012c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800133:	00 
  800134:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80013b:	00 
  80013c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800140:	89 34 24             	mov    %esi,(%esp)
  800143:	e8 23 18 00 00       	call   80196b <ipc_send>
		panic("fork: %e", id);
	if (id == 0)
		primeproc();

	// feed all the integers through
	for (i = 2; ; i++)
  800148:	83 c3 01             	add    $0x1,%ebx
  80014b:	eb df                	jmp    80012c <umain+0x41>
  80014d:	00 00                	add    %al,(%eax)
	...

00800150 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800150:	55                   	push   %ebp
  800151:	89 e5                	mov    %esp,%ebp
  800153:	83 ec 18             	sub    $0x18,%esp
  800156:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800159:	89 75 fc             	mov    %esi,-0x4(%ebp)
  80015c:	8b 75 08             	mov    0x8(%ebp),%esi
  80015f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  800162:	e8 5b 13 00 00       	call   8014c2 <sys_getenvid>
  800167:	25 ff 03 00 00       	and    $0x3ff,%eax
  80016c:	89 c2                	mov    %eax,%edx
  80016e:	c1 e2 07             	shl    $0x7,%edx
  800171:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  800178:	a3 04 40 80 00       	mov    %eax,0x804004
        //cprintf("ENVX sys_get_envid(): %d\n",ENVX(sys_getenvid()));
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80017d:	85 f6                	test   %esi,%esi
  80017f:	7e 07                	jle    800188 <libmain+0x38>
		binaryname = argv[0];
  800181:	8b 03                	mov    (%ebx),%eax
  800183:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800188:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80018c:	89 34 24             	mov    %esi,(%esp)
  80018f:	e8 57 ff ff ff       	call   8000eb <umain>

	// exit gracefully
	exit();
  800194:	e8 0b 00 00 00       	call   8001a4 <exit>
}
  800199:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80019c:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80019f:	89 ec                	mov    %ebp,%esp
  8001a1:	5d                   	pop    %ebp
  8001a2:	c3                   	ret    
	...

008001a4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001a4:	55                   	push   %ebp
  8001a5:	89 e5                	mov    %esp,%ebp
  8001a7:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8001aa:	e8 8c 1d 00 00       	call   801f3b <close_all>
	sys_env_destroy(0);
  8001af:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8001b6:	e8 47 13 00 00       	call   801502 <sys_env_destroy>
}
  8001bb:	c9                   	leave  
  8001bc:	c3                   	ret    
  8001bd:	00 00                	add    %al,(%eax)
	...

008001c0 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8001c0:	55                   	push   %ebp
  8001c1:	89 e5                	mov    %esp,%ebp
  8001c3:	56                   	push   %esi
  8001c4:	53                   	push   %ebx
  8001c5:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  8001c8:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001cb:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  8001d1:	e8 ec 12 00 00       	call   8014c2 <sys_getenvid>
  8001d6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001d9:	89 54 24 10          	mov    %edx,0x10(%esp)
  8001dd:	8b 55 08             	mov    0x8(%ebp),%edx
  8001e0:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8001e4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001e8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001ec:	c7 04 24 44 26 80 00 	movl   $0x802644,(%esp)
  8001f3:	e8 81 00 00 00       	call   800279 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001f8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8001fc:	8b 45 10             	mov    0x10(%ebp),%eax
  8001ff:	89 04 24             	mov    %eax,(%esp)
  800202:	e8 11 00 00 00       	call   800218 <vcprintf>
	cprintf("\n");
  800207:	c7 04 24 5b 2b 80 00 	movl   $0x802b5b,(%esp)
  80020e:	e8 66 00 00 00       	call   800279 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800213:	cc                   	int3   
  800214:	eb fd                	jmp    800213 <_panic+0x53>
	...

00800218 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  800218:	55                   	push   %ebp
  800219:	89 e5                	mov    %esp,%ebp
  80021b:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800221:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800228:	00 00 00 
	b.cnt = 0;
  80022b:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800232:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800235:	8b 45 0c             	mov    0xc(%ebp),%eax
  800238:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80023c:	8b 45 08             	mov    0x8(%ebp),%eax
  80023f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800243:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800249:	89 44 24 04          	mov    %eax,0x4(%esp)
  80024d:	c7 04 24 93 02 80 00 	movl   $0x800293,(%esp)
  800254:	e8 d3 01 00 00       	call   80042c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800259:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80025f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800263:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800269:	89 04 24             	mov    %eax,(%esp)
  80026c:	e8 6b 0d 00 00       	call   800fdc <sys_cputs>

	return b.cnt;
}
  800271:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800277:	c9                   	leave  
  800278:	c3                   	ret    

00800279 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800279:	55                   	push   %ebp
  80027a:	89 e5                	mov    %esp,%ebp
  80027c:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  80027f:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  800282:	89 44 24 04          	mov    %eax,0x4(%esp)
  800286:	8b 45 08             	mov    0x8(%ebp),%eax
  800289:	89 04 24             	mov    %eax,(%esp)
  80028c:	e8 87 ff ff ff       	call   800218 <vcprintf>
	va_end(ap);

	return cnt;
}
  800291:	c9                   	leave  
  800292:	c3                   	ret    

00800293 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800293:	55                   	push   %ebp
  800294:	89 e5                	mov    %esp,%ebp
  800296:	53                   	push   %ebx
  800297:	83 ec 14             	sub    $0x14,%esp
  80029a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80029d:	8b 03                	mov    (%ebx),%eax
  80029f:	8b 55 08             	mov    0x8(%ebp),%edx
  8002a2:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8002a6:	83 c0 01             	add    $0x1,%eax
  8002a9:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8002ab:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002b0:	75 19                	jne    8002cb <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8002b2:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8002b9:	00 
  8002ba:	8d 43 08             	lea    0x8(%ebx),%eax
  8002bd:	89 04 24             	mov    %eax,(%esp)
  8002c0:	e8 17 0d 00 00       	call   800fdc <sys_cputs>
		b->idx = 0;
  8002c5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8002cb:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8002cf:	83 c4 14             	add    $0x14,%esp
  8002d2:	5b                   	pop    %ebx
  8002d3:	5d                   	pop    %ebp
  8002d4:	c3                   	ret    
	...

008002e0 <printnum_v2>:
 */

static void 
printnum_v2(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002e0:	55                   	push   %ebp
  8002e1:	89 e5                	mov    %esp,%ebp
  8002e3:	57                   	push   %edi
  8002e4:	56                   	push   %esi
  8002e5:	53                   	push   %ebx
  8002e6:	83 ec 4c             	sub    $0x4c,%esp
  8002e9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002ec:	89 d6                	mov    %edx,%esi
  8002ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8002f1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002f4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002f7:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8002fa:	8b 45 10             	mov    0x10(%ebp),%eax
  8002fd:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800300:	8b 7d 18             	mov    0x18(%ebp),%edi
    if (num >= base) {
  800303:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800306:	b9 00 00 00 00       	mov    $0x0,%ecx
  80030b:	39 d1                	cmp    %edx,%ecx
  80030d:	72 07                	jb     800316 <printnum_v2+0x36>
  80030f:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800312:	39 d0                	cmp    %edx,%eax
  800314:	77 5f                	ja     800375 <printnum_v2+0x95>
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
  800316:	89 7c 24 10          	mov    %edi,0x10(%esp)
  80031a:	83 eb 01             	sub    $0x1,%ebx
  80031d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800321:	89 44 24 08          	mov    %eax,0x8(%esp)
  800325:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800329:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  80032d:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800330:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  800333:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800336:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80033a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800341:	00 
  800342:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800345:	89 04 24             	mov    %eax,(%esp)
  800348:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80034b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80034f:	e8 4c 20 00 00       	call   8023a0 <__udivdi3>
  800354:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800357:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  80035a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80035e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800362:	89 04 24             	mov    %eax,(%esp)
  800365:	89 54 24 04          	mov    %edx,0x4(%esp)
  800369:	89 f2                	mov    %esi,%edx
  80036b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80036e:	e8 6d ff ff ff       	call   8002e0 <printnum_v2>
  800373:	eb 1e                	jmp    800393 <printnum_v2+0xb3>
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
  800375:	83 ff 2d             	cmp    $0x2d,%edi
  800378:	74 19                	je     800393 <printnum_v2+0xb3>
		while (--width > 0)
  80037a:	83 eb 01             	sub    $0x1,%ebx
  80037d:	85 db                	test   %ebx,%ebx
  80037f:	90                   	nop
  800380:	7e 11                	jle    800393 <printnum_v2+0xb3>
			putch(padc, putdat);
  800382:	89 74 24 04          	mov    %esi,0x4(%esp)
  800386:	89 3c 24             	mov    %edi,(%esp)
  800389:	ff 55 e4             	call   *-0x1c(%ebp)
    if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
		while (--width > 0)
  80038c:	83 eb 01             	sub    $0x1,%ebx
  80038f:	85 db                	test   %ebx,%ebx
  800391:	7f ef                	jg     800382 <printnum_v2+0xa2>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800393:	89 74 24 04          	mov    %esi,0x4(%esp)
  800397:	8b 74 24 04          	mov    0x4(%esp),%esi
  80039b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80039e:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003a2:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8003a9:	00 
  8003aa:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8003ad:	89 14 24             	mov    %edx,(%esp)
  8003b0:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8003b3:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8003b7:	e8 14 21 00 00       	call   8024d0 <__umoddi3>
  8003bc:	89 74 24 04          	mov    %esi,0x4(%esp)
  8003c0:	0f be 80 67 26 80 00 	movsbl 0x802667(%eax),%eax
  8003c7:	89 04 24             	mov    %eax,(%esp)
  8003ca:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8003cd:	83 c4 4c             	add    $0x4c,%esp
  8003d0:	5b                   	pop    %ebx
  8003d1:	5e                   	pop    %esi
  8003d2:	5f                   	pop    %edi
  8003d3:	5d                   	pop    %ebp
  8003d4:	c3                   	ret    

008003d5 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003d5:	55                   	push   %ebp
  8003d6:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003d8:	83 fa 01             	cmp    $0x1,%edx
  8003db:	7e 0e                	jle    8003eb <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003dd:	8b 10                	mov    (%eax),%edx
  8003df:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003e2:	89 08                	mov    %ecx,(%eax)
  8003e4:	8b 02                	mov    (%edx),%eax
  8003e6:	8b 52 04             	mov    0x4(%edx),%edx
  8003e9:	eb 22                	jmp    80040d <getuint+0x38>
	else if (lflag)
  8003eb:	85 d2                	test   %edx,%edx
  8003ed:	74 10                	je     8003ff <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003ef:	8b 10                	mov    (%eax),%edx
  8003f1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003f4:	89 08                	mov    %ecx,(%eax)
  8003f6:	8b 02                	mov    (%edx),%eax
  8003f8:	ba 00 00 00 00       	mov    $0x0,%edx
  8003fd:	eb 0e                	jmp    80040d <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003ff:	8b 10                	mov    (%eax),%edx
  800401:	8d 4a 04             	lea    0x4(%edx),%ecx
  800404:	89 08                	mov    %ecx,(%eax)
  800406:	8b 02                	mov    (%edx),%eax
  800408:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80040d:	5d                   	pop    %ebp
  80040e:	c3                   	ret    

0080040f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80040f:	55                   	push   %ebp
  800410:	89 e5                	mov    %esp,%ebp
  800412:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800415:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800419:	8b 10                	mov    (%eax),%edx
  80041b:	3b 50 04             	cmp    0x4(%eax),%edx
  80041e:	73 0a                	jae    80042a <sprintputch+0x1b>
		*b->buf++ = ch;
  800420:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800423:	88 0a                	mov    %cl,(%edx)
  800425:	83 c2 01             	add    $0x1,%edx
  800428:	89 10                	mov    %edx,(%eax)
}
  80042a:	5d                   	pop    %ebp
  80042b:	c3                   	ret    

0080042c <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80042c:	55                   	push   %ebp
  80042d:	89 e5                	mov    %esp,%ebp
  80042f:	57                   	push   %edi
  800430:	56                   	push   %esi
  800431:	53                   	push   %ebx
  800432:	83 ec 6c             	sub    $0x6c,%esp
  800435:	8b 7d 10             	mov    0x10(%ebp),%edi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800438:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  80043f:	eb 1a                	jmp    80045b <vprintfmt+0x2f>
	int base, lflag, width, precision, altflag,signflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800441:	85 c0                	test   %eax,%eax
  800443:	0f 84 66 06 00 00    	je     800aaf <vprintfmt+0x683>
				return;
			putch(ch, putdat);
  800449:	8b 55 0c             	mov    0xc(%ebp),%edx
  80044c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800450:	89 04 24             	mov    %eax,(%esp)
  800453:	ff 55 08             	call   *0x8(%ebp)
  800456:	eb 03                	jmp    80045b <vprintfmt+0x2f>
  800458:	8b 7d e4             	mov    -0x1c(%ebp),%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag,signflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80045b:	0f b6 07             	movzbl (%edi),%eax
  80045e:	83 c7 01             	add    $0x1,%edi
  800461:	83 f8 25             	cmp    $0x25,%eax
  800464:	75 db                	jne    800441 <vprintfmt+0x15>
  800466:	c6 45 cc 20          	movb   $0x20,-0x34(%ebp)
  80046a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80046f:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  800476:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
  80047b:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800482:	be 00 00 00 00       	mov    $0x0,%esi
  800487:	eb 06                	jmp    80048f <vprintfmt+0x63>
  800489:	c6 45 cc 2d          	movb   $0x2d,-0x34(%ebp)
  80048d:	89 c7                	mov    %eax,%edi
		precision = -1;
		lflag = 0;
		altflag = 0;
                signflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048f:	0f b6 17             	movzbl (%edi),%edx
  800492:	0f b6 c2             	movzbl %dl,%eax
  800495:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800498:	8d 47 01             	lea    0x1(%edi),%eax
  80049b:	83 ea 23             	sub    $0x23,%edx
  80049e:	80 fa 55             	cmp    $0x55,%dl
  8004a1:	0f 87 60 05 00 00    	ja     800a07 <vprintfmt+0x5db>
  8004a7:	0f b6 d2             	movzbl %dl,%edx
  8004aa:	ff 24 95 40 28 80 00 	jmp    *0x802840(,%edx,4)
  8004b1:	b9 01 00 00 00       	mov    $0x1,%ecx
  8004b6:	eb d5                	jmp    80048d <vprintfmt+0x61>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004b8:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8004bb:	83 eb 30             	sub    $0x30,%ebx
				ch = *fmt;
  8004be:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  8004c1:	8d 7a d0             	lea    -0x30(%edx),%edi
  8004c4:	83 ff 09             	cmp    $0x9,%edi
  8004c7:	76 08                	jbe    8004d1 <vprintfmt+0xa5>
  8004c9:	eb 40                	jmp    80050b <vprintfmt+0xdf>
  8004cb:	c6 45 cc 30          	movb   $0x30,-0x34(%ebp)
                        signflag = 1;
                        goto reswitch;
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
			goto reswitch;
  8004cf:	eb bc                	jmp    80048d <vprintfmt+0x61>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004d1:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  8004d4:	8d 1c 9b             	lea    (%ebx,%ebx,4),%ebx
  8004d7:	8d 5c 5a d0          	lea    -0x30(%edx,%ebx,2),%ebx
				ch = *fmt;
  8004db:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  8004de:	8d 7a d0             	lea    -0x30(%edx),%edi
  8004e1:	83 ff 09             	cmp    $0x9,%edi
  8004e4:	76 eb                	jbe    8004d1 <vprintfmt+0xa5>
  8004e6:	eb 23                	jmp    80050b <vprintfmt+0xdf>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004e8:	8b 55 14             	mov    0x14(%ebp),%edx
  8004eb:	8d 5a 04             	lea    0x4(%edx),%ebx
  8004ee:	89 5d 14             	mov    %ebx,0x14(%ebp)
  8004f1:	8b 1a                	mov    (%edx),%ebx
			goto process_precision;
  8004f3:	eb 16                	jmp    80050b <vprintfmt+0xdf>

		case '.':
			if (width < 0)
  8004f5:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8004f8:	c1 fa 1f             	sar    $0x1f,%edx
  8004fb:	f7 d2                	not    %edx
  8004fd:	21 55 d8             	and    %edx,-0x28(%ebp)
  800500:	eb 8b                	jmp    80048d <vprintfmt+0x61>
  800502:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  800509:	eb 82                	jmp    80048d <vprintfmt+0x61>

		process_precision:
			if (width < 0)
  80050b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80050f:	0f 89 78 ff ff ff    	jns    80048d <vprintfmt+0x61>
  800515:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800518:	8b 5d c8             	mov    -0x38(%ebp),%ebx
  80051b:	e9 6d ff ff ff       	jmp    80048d <vprintfmt+0x61>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800520:	83 c6 01             	add    $0x1,%esi
			goto reswitch;
  800523:	e9 65 ff ff ff       	jmp    80048d <vprintfmt+0x61>
  800528:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80052b:	8b 45 14             	mov    0x14(%ebp),%eax
  80052e:	8d 50 04             	lea    0x4(%eax),%edx
  800531:	89 55 14             	mov    %edx,0x14(%ebp)
  800534:	8b 55 0c             	mov    0xc(%ebp),%edx
  800537:	89 54 24 04          	mov    %edx,0x4(%esp)
  80053b:	8b 00                	mov    (%eax),%eax
  80053d:	89 04 24             	mov    %eax,(%esp)
  800540:	ff 55 08             	call   *0x8(%ebp)
  800543:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;
  800546:	e9 10 ff ff ff       	jmp    80045b <vprintfmt+0x2f>
  80054b:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  80054e:	8b 45 14             	mov    0x14(%ebp),%eax
  800551:	8d 50 04             	lea    0x4(%eax),%edx
  800554:	89 55 14             	mov    %edx,0x14(%ebp)
  800557:	8b 00                	mov    (%eax),%eax
  800559:	89 c2                	mov    %eax,%edx
  80055b:	c1 fa 1f             	sar    $0x1f,%edx
  80055e:	31 d0                	xor    %edx,%eax
  800560:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800562:	83 f8 0f             	cmp    $0xf,%eax
  800565:	7f 0b                	jg     800572 <vprintfmt+0x146>
  800567:	8b 14 85 a0 29 80 00 	mov    0x8029a0(,%eax,4),%edx
  80056e:	85 d2                	test   %edx,%edx
  800570:	75 26                	jne    800598 <vprintfmt+0x16c>
				printfmt(putch, putdat, "error %d", err);
  800572:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800576:	c7 44 24 08 78 26 80 	movl   $0x802678,0x8(%esp)
  80057d:	00 
  80057e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800581:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800585:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800588:	89 1c 24             	mov    %ebx,(%esp)
  80058b:	e8 a7 05 00 00       	call   800b37 <printfmt>
  800590:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800593:	e9 c3 fe ff ff       	jmp    80045b <vprintfmt+0x2f>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800598:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80059c:	c7 44 24 08 81 26 80 	movl   $0x802681,0x8(%esp)
  8005a3:	00 
  8005a4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005a7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005ab:	8b 55 08             	mov    0x8(%ebp),%edx
  8005ae:	89 14 24             	mov    %edx,(%esp)
  8005b1:	e8 81 05 00 00       	call   800b37 <printfmt>
  8005b6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005b9:	e9 9d fe ff ff       	jmp    80045b <vprintfmt+0x2f>
  8005be:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8005c1:	89 c7                	mov    %eax,%edi
  8005c3:	89 d9                	mov    %ebx,%ecx
  8005c5:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005c8:	89 45 c0             	mov    %eax,-0x40(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ce:	8d 50 04             	lea    0x4(%eax),%edx
  8005d1:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d4:	8b 30                	mov    (%eax),%esi
  8005d6:	85 f6                	test   %esi,%esi
  8005d8:	75 05                	jne    8005df <vprintfmt+0x1b3>
  8005da:	be 84 26 80 00       	mov    $0x802684,%esi
				p = "(null)";
			if (width > 0 && padc != '-')
  8005df:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
  8005e3:	7e 06                	jle    8005eb <vprintfmt+0x1bf>
  8005e5:	80 7d cc 2d          	cmpb   $0x2d,-0x34(%ebp)
  8005e9:	75 10                	jne    8005fb <vprintfmt+0x1cf>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005eb:	0f be 06             	movsbl (%esi),%eax
  8005ee:	85 c0                	test   %eax,%eax
  8005f0:	0f 85 a2 00 00 00    	jne    800698 <vprintfmt+0x26c>
  8005f6:	e9 92 00 00 00       	jmp    80068d <vprintfmt+0x261>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005fb:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8005ff:	89 34 24             	mov    %esi,(%esp)
  800602:	e8 74 05 00 00       	call   800b7b <strnlen>
  800607:	8b 55 c0             	mov    -0x40(%ebp),%edx
  80060a:	29 c2                	sub    %eax,%edx
  80060c:	89 55 d8             	mov    %edx,-0x28(%ebp)
  80060f:	85 d2                	test   %edx,%edx
  800611:	7e d8                	jle    8005eb <vprintfmt+0x1bf>
					putch(padc, putdat);
  800613:	0f be 4d cc          	movsbl -0x34(%ebp),%ecx
  800617:	89 5d c0             	mov    %ebx,-0x40(%ebp)
  80061a:	89 d3                	mov    %edx,%ebx
  80061c:	89 75 d8             	mov    %esi,-0x28(%ebp)
  80061f:	89 7d bc             	mov    %edi,-0x44(%ebp)
  800622:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800625:	89 ce                	mov    %ecx,%esi
  800627:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80062b:	89 34 24             	mov    %esi,(%esp)
  80062e:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800631:	83 eb 01             	sub    $0x1,%ebx
  800634:	85 db                	test   %ebx,%ebx
  800636:	7f ef                	jg     800627 <vprintfmt+0x1fb>
  800638:	8b 5d c0             	mov    -0x40(%ebp),%ebx
  80063b:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80063e:	8b 7d bc             	mov    -0x44(%ebp),%edi
  800641:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800648:	eb a1                	jmp    8005eb <vprintfmt+0x1bf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80064a:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  80064e:	74 1b                	je     80066b <vprintfmt+0x23f>
  800650:	8d 50 e0             	lea    -0x20(%eax),%edx
  800653:	83 fa 5e             	cmp    $0x5e,%edx
  800656:	76 13                	jbe    80066b <vprintfmt+0x23f>
					putch('?', putdat);
  800658:	8b 45 0c             	mov    0xc(%ebp),%eax
  80065b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80065f:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800666:	ff 55 08             	call   *0x8(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800669:	eb 0d                	jmp    800678 <vprintfmt+0x24c>
					putch('?', putdat);
				else
					putch(ch, putdat);
  80066b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80066e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800672:	89 04 24             	mov    %eax,(%esp)
  800675:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800678:	83 ef 01             	sub    $0x1,%edi
  80067b:	0f be 06             	movsbl (%esi),%eax
  80067e:	85 c0                	test   %eax,%eax
  800680:	74 05                	je     800687 <vprintfmt+0x25b>
  800682:	83 c6 01             	add    $0x1,%esi
  800685:	eb 1a                	jmp    8006a1 <vprintfmt+0x275>
  800687:	89 7d d8             	mov    %edi,-0x28(%ebp)
  80068a:	8b 7d cc             	mov    -0x34(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80068d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800691:	7f 1f                	jg     8006b2 <vprintfmt+0x286>
  800693:	e9 c0 fd ff ff       	jmp    800458 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800698:	83 c6 01             	add    $0x1,%esi
  80069b:	89 7d cc             	mov    %edi,-0x34(%ebp)
  80069e:	8b 7d d8             	mov    -0x28(%ebp),%edi
  8006a1:	85 db                	test   %ebx,%ebx
  8006a3:	78 a5                	js     80064a <vprintfmt+0x21e>
  8006a5:	83 eb 01             	sub    $0x1,%ebx
  8006a8:	79 a0                	jns    80064a <vprintfmt+0x21e>
  8006aa:	89 7d d8             	mov    %edi,-0x28(%ebp)
  8006ad:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8006b0:	eb db                	jmp    80068d <vprintfmt+0x261>
  8006b2:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  8006b5:	8b 75 0c             	mov    0xc(%ebp),%esi
  8006b8:	89 7d d8             	mov    %edi,-0x28(%ebp)
  8006bb:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006be:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006c2:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8006c9:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006cb:	83 eb 01             	sub    $0x1,%ebx
  8006ce:	85 db                	test   %ebx,%ebx
  8006d0:	7f ec                	jg     8006be <vprintfmt+0x292>
  8006d2:	8b 7d d8             	mov    -0x28(%ebp),%edi
  8006d5:	e9 81 fd ff ff       	jmp    80045b <vprintfmt+0x2f>
  8006da:	89 45 e4             	mov    %eax,-0x1c(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006dd:	83 fe 01             	cmp    $0x1,%esi
  8006e0:	7e 10                	jle    8006f2 <vprintfmt+0x2c6>
		return va_arg(*ap, long long);
  8006e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e5:	8d 50 08             	lea    0x8(%eax),%edx
  8006e8:	89 55 14             	mov    %edx,0x14(%ebp)
  8006eb:	8b 18                	mov    (%eax),%ebx
  8006ed:	8b 70 04             	mov    0x4(%eax),%esi
  8006f0:	eb 26                	jmp    800718 <vprintfmt+0x2ec>
	else if (lflag)
  8006f2:	85 f6                	test   %esi,%esi
  8006f4:	74 12                	je     800708 <vprintfmt+0x2dc>
		return va_arg(*ap, long);
  8006f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f9:	8d 50 04             	lea    0x4(%eax),%edx
  8006fc:	89 55 14             	mov    %edx,0x14(%ebp)
  8006ff:	8b 18                	mov    (%eax),%ebx
  800701:	89 de                	mov    %ebx,%esi
  800703:	c1 fe 1f             	sar    $0x1f,%esi
  800706:	eb 10                	jmp    800718 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  800708:	8b 45 14             	mov    0x14(%ebp),%eax
  80070b:	8d 50 04             	lea    0x4(%eax),%edx
  80070e:	89 55 14             	mov    %edx,0x14(%ebp)
  800711:	8b 18                	mov    (%eax),%ebx
  800713:	89 de                	mov    %ebx,%esi
  800715:	c1 fe 1f             	sar    $0x1f,%esi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
                        if(signflag == 1){
  800718:	83 f9 01             	cmp    $0x1,%ecx
  80071b:	75 1e                	jne    80073b <vprintfmt+0x30f>
                               if((long long)num > 0){
  80071d:	85 f6                	test   %esi,%esi
  80071f:	78 1a                	js     80073b <vprintfmt+0x30f>
  800721:	85 f6                	test   %esi,%esi
  800723:	7f 05                	jg     80072a <vprintfmt+0x2fe>
  800725:	83 fb 00             	cmp    $0x0,%ebx
  800728:	76 11                	jbe    80073b <vprintfmt+0x30f>
                                   putch('+',putdat);
  80072a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80072d:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800731:	c7 04 24 2b 00 00 00 	movl   $0x2b,(%esp)
  800738:	ff 55 08             	call   *0x8(%ebp)
                               }
                        }
			if ((long long) num < 0) {
  80073b:	85 f6                	test   %esi,%esi
  80073d:	78 13                	js     800752 <vprintfmt+0x326>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80073f:	89 5d b0             	mov    %ebx,-0x50(%ebp)
  800742:	89 75 b4             	mov    %esi,-0x4c(%ebp)
  800745:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800748:	b8 0a 00 00 00       	mov    $0xa,%eax
  80074d:	e9 da 00 00 00       	jmp    80082c <vprintfmt+0x400>
                               if((long long)num > 0){
                                   putch('+',putdat);
                               }
                        }
			if ((long long) num < 0) {
				putch('-', putdat);
  800752:	8b 45 0c             	mov    0xc(%ebp),%eax
  800755:	89 44 24 04          	mov    %eax,0x4(%esp)
  800759:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800760:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800763:	89 da                	mov    %ebx,%edx
  800765:	89 f1                	mov    %esi,%ecx
  800767:	f7 da                	neg    %edx
  800769:	83 d1 00             	adc    $0x0,%ecx
  80076c:	f7 d9                	neg    %ecx
  80076e:	89 55 b0             	mov    %edx,-0x50(%ebp)
  800771:	89 4d b4             	mov    %ecx,-0x4c(%ebp)
  800774:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800777:	b8 0a 00 00 00       	mov    $0xa,%eax
  80077c:	e9 ab 00 00 00       	jmp    80082c <vprintfmt+0x400>
  800781:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800784:	89 f2                	mov    %esi,%edx
  800786:	8d 45 14             	lea    0x14(%ebp),%eax
  800789:	e8 47 fc ff ff       	call   8003d5 <getuint>
  80078e:	89 45 b0             	mov    %eax,-0x50(%ebp)
  800791:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  800794:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800797:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
  80079c:	e9 8b 00 00 00       	jmp    80082c <vprintfmt+0x400>
  8007a1:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			putch('0', putdat);
  8007a4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007a7:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8007ab:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8007b2:	ff 55 08             	call   *0x8(%ebp)
			num = getuint(&ap,lflag);
  8007b5:	89 f2                	mov    %esi,%edx
  8007b7:	8d 45 14             	lea    0x14(%ebp),%eax
  8007ba:	e8 16 fc ff ff       	call   8003d5 <getuint>
  8007bf:	89 45 b0             	mov    %eax,-0x50(%ebp)
  8007c2:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  8007c5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007c8:	b8 08 00 00 00       	mov    $0x8,%eax
                        base = 8;
			goto number;
  8007cd:	eb 5d                	jmp    80082c <vprintfmt+0x400>
  8007cf:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
  8007d2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007d5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007d9:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8007e0:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8007e3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007e7:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8007ee:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  8007f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f4:	8d 50 04             	lea    0x4(%eax),%edx
  8007f7:	89 55 14             	mov    %edx,0x14(%ebp)
  8007fa:	8b 10                	mov    (%eax),%edx
  8007fc:	b9 00 00 00 00       	mov    $0x0,%ecx
  800801:	89 55 b0             	mov    %edx,-0x50(%ebp)
  800804:	89 4d b4             	mov    %ecx,-0x4c(%ebp)
  800807:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80080a:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80080f:	eb 1b                	jmp    80082c <vprintfmt+0x400>
  800811:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800814:	89 f2                	mov    %esi,%edx
  800816:	8d 45 14             	lea    0x14(%ebp),%eax
  800819:	e8 b7 fb ff ff       	call   8003d5 <getuint>
  80081e:	89 45 b0             	mov    %eax,-0x50(%ebp)
  800821:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  800824:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800827:	b8 10 00 00 00       	mov    $0x10,%eax
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  80082c:	0f be 4d cc          	movsbl -0x34(%ebp),%ecx
  800830:	89 4d d0             	mov    %ecx,-0x30(%ebp)
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800833:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800836:	83 7d b4 00          	cmpl   $0x0,-0x4c(%ebp)
  80083a:	77 09                	ja     800845 <vprintfmt+0x419>
  80083c:	39 45 b0             	cmp    %eax,-0x50(%ebp)
  80083f:	0f 82 ac 00 00 00    	jb     8008f1 <vprintfmt+0x4c5>
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
  800845:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800848:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  80084c:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80084f:	83 ea 01             	sub    $0x1,%edx
  800852:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800856:	89 44 24 08          	mov    %eax,0x8(%esp)
  80085a:	8b 44 24 08          	mov    0x8(%esp),%eax
  80085e:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800862:	89 45 c0             	mov    %eax,-0x40(%ebp)
  800865:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  800868:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80086b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80086f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800876:	00 
  800877:	8b 4d b0             	mov    -0x50(%ebp),%ecx
  80087a:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
  80087d:	89 0c 24             	mov    %ecx,(%esp)
  800880:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800884:	e8 17 1b 00 00       	call   8023a0 <__udivdi3>
  800889:	8b 4d c0             	mov    -0x40(%ebp),%ecx
  80088c:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  80088f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800893:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800897:	89 04 24             	mov    %eax,(%esp)
  80089a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80089e:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a4:	e8 37 fa ff ff       	call   8002e0 <printnum_v2>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8008a9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8008ac:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008b0:	8b 74 24 04          	mov    0x4(%esp),%esi
  8008b4:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8008b7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008bb:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8008c2:	00 
  8008c3:	8b 55 b0             	mov    -0x50(%ebp),%edx
  8008c6:	8b 4d b4             	mov    -0x4c(%ebp),%ecx
  8008c9:	89 14 24             	mov    %edx,(%esp)
  8008cc:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8008d0:	e8 fb 1b 00 00       	call   8024d0 <__umoddi3>
  8008d5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8008d9:	0f be 80 67 26 80 00 	movsbl 0x802667(%eax),%eax
  8008e0:	89 04 24             	mov    %eax,(%esp)
  8008e3:	ff 55 08             	call   *0x8(%ebp)
        if(padc == '-'){
  8008e6:	83 7d d0 2d          	cmpl   $0x2d,-0x30(%ebp)
  8008ea:	74 54                	je     800940 <vprintfmt+0x514>
  8008ec:	e9 67 fb ff ff       	jmp    800458 <vprintfmt+0x2c>
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
  8008f1:	83 7d d0 2d          	cmpl   $0x2d,-0x30(%ebp)
  8008f5:	8d 76 00             	lea    0x0(%esi),%esi
  8008f8:	0f 84 2a 01 00 00    	je     800a28 <vprintfmt+0x5fc>
		while (--width > 0)
  8008fe:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800901:	83 ef 01             	sub    $0x1,%edi
  800904:	85 ff                	test   %edi,%edi
  800906:	0f 8e 5e 01 00 00    	jle    800a6a <vprintfmt+0x63e>
  80090c:	8b 4d b0             	mov    -0x50(%ebp),%ecx
  80090f:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
  800912:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  800915:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  800918:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80091b:	8b 75 0c             	mov    0xc(%ebp),%esi
			putch(padc, putdat);
  80091e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800922:	89 1c 24             	mov    %ebx,(%esp)
  800925:	ff 55 08             	call   *0x8(%ebp)
	if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
		while (--width > 0)
  800928:	83 ef 01             	sub    $0x1,%edi
  80092b:	85 ff                	test   %edi,%edi
  80092d:	7f ef                	jg     80091e <vprintfmt+0x4f2>
  80092f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800932:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800935:	89 45 b0             	mov    %eax,-0x50(%ebp)
  800938:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  80093b:	e9 2a 01 00 00       	jmp    800a6a <vprintfmt+0x63e>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
        if(padc == '-'){
           while (--width > 0)
  800940:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800943:	83 eb 01             	sub    $0x1,%ebx
  800946:	85 db                	test   %ebx,%ebx
  800948:	0f 8e 0a fb ff ff    	jle    800458 <vprintfmt+0x2c>
  80094e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800951:	89 7d d8             	mov    %edi,-0x28(%ebp)
  800954:	8b 7d 08             	mov    0x8(%ebp),%edi
			putch(' ', putdat);
  800957:	89 74 24 04          	mov    %esi,0x4(%esp)
  80095b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800962:	ff d7                	call   *%edi
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
        if(padc == '-'){
           while (--width > 0)
  800964:	83 eb 01             	sub    $0x1,%ebx
  800967:	85 db                	test   %ebx,%ebx
  800969:	7f ec                	jg     800957 <vprintfmt+0x52b>
  80096b:	8b 7d d8             	mov    -0x28(%ebp),%edi
  80096e:	e9 e8 fa ff ff       	jmp    80045b <vprintfmt+0x2f>
  800973:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
            char* n;
            if ((n = va_arg(ap, char *)) == NULL)
  800976:	8b 45 14             	mov    0x14(%ebp),%eax
  800979:	8d 50 04             	lea    0x4(%eax),%edx
  80097c:	89 55 14             	mov    %edx,0x14(%ebp)
  80097f:	8b 00                	mov    (%eax),%eax
  800981:	85 c0                	test   %eax,%eax
  800983:	75 2a                	jne    8009af <vprintfmt+0x583>
		  printfmt(putch,putdat,"%s",null_error);
  800985:	c7 44 24 0c a0 27 80 	movl   $0x8027a0,0xc(%esp)
  80098c:	00 
  80098d:	c7 44 24 08 81 26 80 	movl   $0x802681,0x8(%esp)
  800994:	00 
  800995:	8b 55 0c             	mov    0xc(%ebp),%edx
  800998:	89 54 24 04          	mov    %edx,0x4(%esp)
  80099c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80099f:	89 0c 24             	mov    %ecx,(%esp)
  8009a2:	e8 90 01 00 00       	call   800b37 <printfmt>
  8009a7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8009aa:	e9 ac fa ff ff       	jmp    80045b <vprintfmt+0x2f>
            else if((*(int*)putdat) > 127){
  8009af:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8009b2:	8b 13                	mov    (%ebx),%edx
  8009b4:	83 fa 7f             	cmp    $0x7f,%edx
  8009b7:	7e 29                	jle    8009e2 <vprintfmt+0x5b6>
                  *n = *(int*)putdat;
  8009b9:	88 10                	mov    %dl,(%eax)
                  printfmt(putch,putdat,"%s",overflow_error);
  8009bb:	c7 44 24 0c d8 27 80 	movl   $0x8027d8,0xc(%esp)
  8009c2:	00 
  8009c3:	c7 44 24 08 81 26 80 	movl   $0x802681,0x8(%esp)
  8009ca:	00 
  8009cb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d2:	89 04 24             	mov    %eax,(%esp)
  8009d5:	e8 5d 01 00 00       	call   800b37 <printfmt>
  8009da:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8009dd:	e9 79 fa ff ff       	jmp    80045b <vprintfmt+0x2f>
            }
            else
                  *n = *(int*)putdat;
  8009e2:	88 10                	mov    %dl,(%eax)
  8009e4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8009e7:	e9 6f fa ff ff       	jmp    80045b <vprintfmt+0x2f>
  8009ec:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8009ef:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            break;
        }
		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8009f2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009f5:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8009f9:	89 14 24             	mov    %edx,(%esp)
  8009fc:	ff 55 08             	call   *0x8(%ebp)
  8009ff:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;
  800a02:	e9 54 fa ff ff       	jmp    80045b <vprintfmt+0x2f>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800a07:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a0a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a0e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800a15:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800a18:	8d 47 ff             	lea    -0x1(%edi),%eax
  800a1b:	80 38 25             	cmpb   $0x25,(%eax)
  800a1e:	0f 84 37 fa ff ff    	je     80045b <vprintfmt+0x2f>
  800a24:	89 c7                	mov    %eax,%edi
  800a26:	eb f0                	jmp    800a18 <vprintfmt+0x5ec>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800a28:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a2b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a2f:	8b 74 24 04          	mov    0x4(%esp),%esi
  800a33:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800a36:	89 54 24 08          	mov    %edx,0x8(%esp)
  800a3a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800a41:	00 
  800a42:	8b 45 b0             	mov    -0x50(%ebp),%eax
  800a45:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  800a48:	89 04 24             	mov    %eax,(%esp)
  800a4b:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a4f:	e8 7c 1a 00 00       	call   8024d0 <__umoddi3>
  800a54:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a58:	0f be 80 67 26 80 00 	movsbl 0x802667(%eax),%eax
  800a5f:	89 04 24             	mov    %eax,(%esp)
  800a62:	ff 55 08             	call   *0x8(%ebp)
  800a65:	e9 d6 fe ff ff       	jmp    800940 <vprintfmt+0x514>
  800a6a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a6d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a71:	8b 74 24 04          	mov    0x4(%esp),%esi
  800a75:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800a78:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800a7c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800a83:	00 
  800a84:	8b 45 b0             	mov    -0x50(%ebp),%eax
  800a87:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  800a8a:	89 04 24             	mov    %eax,(%esp)
  800a8d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a91:	e8 3a 1a 00 00       	call   8024d0 <__umoddi3>
  800a96:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a9a:	0f be 80 67 26 80 00 	movsbl 0x802667(%eax),%eax
  800aa1:	89 04 24             	mov    %eax,(%esp)
  800aa4:	ff 55 08             	call   *0x8(%ebp)
  800aa7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800aaa:	e9 ac f9 ff ff       	jmp    80045b <vprintfmt+0x2f>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800aaf:	83 c4 6c             	add    $0x6c,%esp
  800ab2:	5b                   	pop    %ebx
  800ab3:	5e                   	pop    %esi
  800ab4:	5f                   	pop    %edi
  800ab5:	5d                   	pop    %ebp
  800ab6:	c3                   	ret    

00800ab7 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800ab7:	55                   	push   %ebp
  800ab8:	89 e5                	mov    %esp,%ebp
  800aba:	83 ec 28             	sub    $0x28,%esp
  800abd:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac0:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  800ac3:	85 c0                	test   %eax,%eax
  800ac5:	74 04                	je     800acb <vsnprintf+0x14>
  800ac7:	85 d2                	test   %edx,%edx
  800ac9:	7f 07                	jg     800ad2 <vsnprintf+0x1b>
  800acb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ad0:	eb 3b                	jmp    800b0d <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  800ad2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800ad5:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  800ad9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800adc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800ae3:	8b 45 14             	mov    0x14(%ebp),%eax
  800ae6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800aea:	8b 45 10             	mov    0x10(%ebp),%eax
  800aed:	89 44 24 08          	mov    %eax,0x8(%esp)
  800af1:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800af4:	89 44 24 04          	mov    %eax,0x4(%esp)
  800af8:	c7 04 24 0f 04 80 00 	movl   $0x80040f,(%esp)
  800aff:	e8 28 f9 ff ff       	call   80042c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800b04:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b07:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800b0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800b0d:	c9                   	leave  
  800b0e:	c3                   	ret    

00800b0f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800b0f:	55                   	push   %ebp
  800b10:	89 e5                	mov    %esp,%ebp
  800b12:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  800b15:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  800b18:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b1c:	8b 45 10             	mov    0x10(%ebp),%eax
  800b1f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b23:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b26:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b2a:	8b 45 08             	mov    0x8(%ebp),%eax
  800b2d:	89 04 24             	mov    %eax,(%esp)
  800b30:	e8 82 ff ff ff       	call   800ab7 <vsnprintf>
	va_end(ap);

	return rc;
}
  800b35:	c9                   	leave  
  800b36:	c3                   	ret    

00800b37 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800b37:	55                   	push   %ebp
  800b38:	89 e5                	mov    %esp,%ebp
  800b3a:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  800b3d:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  800b40:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b44:	8b 45 10             	mov    0x10(%ebp),%eax
  800b47:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b4b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b4e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b52:	8b 45 08             	mov    0x8(%ebp),%eax
  800b55:	89 04 24             	mov    %eax,(%esp)
  800b58:	e8 cf f8 ff ff       	call   80042c <vprintfmt>
	va_end(ap);
}
  800b5d:	c9                   	leave  
  800b5e:	c3                   	ret    
	...

00800b60 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800b60:	55                   	push   %ebp
  800b61:	89 e5                	mov    %esp,%ebp
  800b63:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800b66:	b8 00 00 00 00       	mov    $0x0,%eax
  800b6b:	80 3a 00             	cmpb   $0x0,(%edx)
  800b6e:	74 09                	je     800b79 <strlen+0x19>
		n++;
  800b70:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800b73:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800b77:	75 f7                	jne    800b70 <strlen+0x10>
		n++;
	return n;
}
  800b79:	5d                   	pop    %ebp
  800b7a:	c3                   	ret    

00800b7b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800b7b:	55                   	push   %ebp
  800b7c:	89 e5                	mov    %esp,%ebp
  800b7e:	53                   	push   %ebx
  800b7f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800b82:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b85:	85 c9                	test   %ecx,%ecx
  800b87:	74 19                	je     800ba2 <strnlen+0x27>
  800b89:	80 3b 00             	cmpb   $0x0,(%ebx)
  800b8c:	74 14                	je     800ba2 <strnlen+0x27>
  800b8e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800b93:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b96:	39 c8                	cmp    %ecx,%eax
  800b98:	74 0d                	je     800ba7 <strnlen+0x2c>
  800b9a:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  800b9e:	75 f3                	jne    800b93 <strnlen+0x18>
  800ba0:	eb 05                	jmp    800ba7 <strnlen+0x2c>
  800ba2:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800ba7:	5b                   	pop    %ebx
  800ba8:	5d                   	pop    %ebp
  800ba9:	c3                   	ret    

00800baa <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800baa:	55                   	push   %ebp
  800bab:	89 e5                	mov    %esp,%ebp
  800bad:	53                   	push   %ebx
  800bae:	8b 45 08             	mov    0x8(%ebp),%eax
  800bb1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800bb4:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800bb9:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800bbd:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800bc0:	83 c2 01             	add    $0x1,%edx
  800bc3:	84 c9                	test   %cl,%cl
  800bc5:	75 f2                	jne    800bb9 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800bc7:	5b                   	pop    %ebx
  800bc8:	5d                   	pop    %ebp
  800bc9:	c3                   	ret    

00800bca <strcat>:

char *
strcat(char *dst, const char *src)
{
  800bca:	55                   	push   %ebp
  800bcb:	89 e5                	mov    %esp,%ebp
  800bcd:	53                   	push   %ebx
  800bce:	83 ec 08             	sub    $0x8,%esp
  800bd1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800bd4:	89 1c 24             	mov    %ebx,(%esp)
  800bd7:	e8 84 ff ff ff       	call   800b60 <strlen>
	strcpy(dst + len, src);
  800bdc:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bdf:	89 54 24 04          	mov    %edx,0x4(%esp)
  800be3:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800be6:	89 04 24             	mov    %eax,(%esp)
  800be9:	e8 bc ff ff ff       	call   800baa <strcpy>
	return dst;
}
  800bee:	89 d8                	mov    %ebx,%eax
  800bf0:	83 c4 08             	add    $0x8,%esp
  800bf3:	5b                   	pop    %ebx
  800bf4:	5d                   	pop    %ebp
  800bf5:	c3                   	ret    

00800bf6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800bf6:	55                   	push   %ebp
  800bf7:	89 e5                	mov    %esp,%ebp
  800bf9:	56                   	push   %esi
  800bfa:	53                   	push   %ebx
  800bfb:	8b 45 08             	mov    0x8(%ebp),%eax
  800bfe:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c01:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800c04:	85 f6                	test   %esi,%esi
  800c06:	74 18                	je     800c20 <strncpy+0x2a>
  800c08:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800c0d:	0f b6 1a             	movzbl (%edx),%ebx
  800c10:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800c13:	80 3a 01             	cmpb   $0x1,(%edx)
  800c16:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800c19:	83 c1 01             	add    $0x1,%ecx
  800c1c:	39 ce                	cmp    %ecx,%esi
  800c1e:	77 ed                	ja     800c0d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800c20:	5b                   	pop    %ebx
  800c21:	5e                   	pop    %esi
  800c22:	5d                   	pop    %ebp
  800c23:	c3                   	ret    

00800c24 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800c24:	55                   	push   %ebp
  800c25:	89 e5                	mov    %esp,%ebp
  800c27:	56                   	push   %esi
  800c28:	53                   	push   %ebx
  800c29:	8b 75 08             	mov    0x8(%ebp),%esi
  800c2c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c2f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800c32:	89 f0                	mov    %esi,%eax
  800c34:	85 c9                	test   %ecx,%ecx
  800c36:	74 27                	je     800c5f <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  800c38:	83 e9 01             	sub    $0x1,%ecx
  800c3b:	74 1d                	je     800c5a <strlcpy+0x36>
  800c3d:	0f b6 1a             	movzbl (%edx),%ebx
  800c40:	84 db                	test   %bl,%bl
  800c42:	74 16                	je     800c5a <strlcpy+0x36>
			*dst++ = *src++;
  800c44:	88 18                	mov    %bl,(%eax)
  800c46:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800c49:	83 e9 01             	sub    $0x1,%ecx
  800c4c:	74 0e                	je     800c5c <strlcpy+0x38>
			*dst++ = *src++;
  800c4e:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800c51:	0f b6 1a             	movzbl (%edx),%ebx
  800c54:	84 db                	test   %bl,%bl
  800c56:	75 ec                	jne    800c44 <strlcpy+0x20>
  800c58:	eb 02                	jmp    800c5c <strlcpy+0x38>
  800c5a:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800c5c:	c6 00 00             	movb   $0x0,(%eax)
  800c5f:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800c61:	5b                   	pop    %ebx
  800c62:	5e                   	pop    %esi
  800c63:	5d                   	pop    %ebp
  800c64:	c3                   	ret    

00800c65 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800c65:	55                   	push   %ebp
  800c66:	89 e5                	mov    %esp,%ebp
  800c68:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c6b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800c6e:	0f b6 01             	movzbl (%ecx),%eax
  800c71:	84 c0                	test   %al,%al
  800c73:	74 15                	je     800c8a <strcmp+0x25>
  800c75:	3a 02                	cmp    (%edx),%al
  800c77:	75 11                	jne    800c8a <strcmp+0x25>
		p++, q++;
  800c79:	83 c1 01             	add    $0x1,%ecx
  800c7c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800c7f:	0f b6 01             	movzbl (%ecx),%eax
  800c82:	84 c0                	test   %al,%al
  800c84:	74 04                	je     800c8a <strcmp+0x25>
  800c86:	3a 02                	cmp    (%edx),%al
  800c88:	74 ef                	je     800c79 <strcmp+0x14>
  800c8a:	0f b6 c0             	movzbl %al,%eax
  800c8d:	0f b6 12             	movzbl (%edx),%edx
  800c90:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800c92:	5d                   	pop    %ebp
  800c93:	c3                   	ret    

00800c94 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800c94:	55                   	push   %ebp
  800c95:	89 e5                	mov    %esp,%ebp
  800c97:	53                   	push   %ebx
  800c98:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c9e:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800ca1:	85 c0                	test   %eax,%eax
  800ca3:	74 23                	je     800cc8 <strncmp+0x34>
  800ca5:	0f b6 1a             	movzbl (%edx),%ebx
  800ca8:	84 db                	test   %bl,%bl
  800caa:	74 25                	je     800cd1 <strncmp+0x3d>
  800cac:	3a 19                	cmp    (%ecx),%bl
  800cae:	75 21                	jne    800cd1 <strncmp+0x3d>
  800cb0:	83 e8 01             	sub    $0x1,%eax
  800cb3:	74 13                	je     800cc8 <strncmp+0x34>
		n--, p++, q++;
  800cb5:	83 c2 01             	add    $0x1,%edx
  800cb8:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800cbb:	0f b6 1a             	movzbl (%edx),%ebx
  800cbe:	84 db                	test   %bl,%bl
  800cc0:	74 0f                	je     800cd1 <strncmp+0x3d>
  800cc2:	3a 19                	cmp    (%ecx),%bl
  800cc4:	74 ea                	je     800cb0 <strncmp+0x1c>
  800cc6:	eb 09                	jmp    800cd1 <strncmp+0x3d>
  800cc8:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800ccd:	5b                   	pop    %ebx
  800cce:	5d                   	pop    %ebp
  800ccf:	90                   	nop
  800cd0:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800cd1:	0f b6 02             	movzbl (%edx),%eax
  800cd4:	0f b6 11             	movzbl (%ecx),%edx
  800cd7:	29 d0                	sub    %edx,%eax
  800cd9:	eb f2                	jmp    800ccd <strncmp+0x39>

00800cdb <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800cdb:	55                   	push   %ebp
  800cdc:	89 e5                	mov    %esp,%ebp
  800cde:	8b 45 08             	mov    0x8(%ebp),%eax
  800ce1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ce5:	0f b6 10             	movzbl (%eax),%edx
  800ce8:	84 d2                	test   %dl,%dl
  800cea:	74 18                	je     800d04 <strchr+0x29>
		if (*s == c)
  800cec:	38 ca                	cmp    %cl,%dl
  800cee:	75 0a                	jne    800cfa <strchr+0x1f>
  800cf0:	eb 17                	jmp    800d09 <strchr+0x2e>
  800cf2:	38 ca                	cmp    %cl,%dl
  800cf4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800cf8:	74 0f                	je     800d09 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800cfa:	83 c0 01             	add    $0x1,%eax
  800cfd:	0f b6 10             	movzbl (%eax),%edx
  800d00:	84 d2                	test   %dl,%dl
  800d02:	75 ee                	jne    800cf2 <strchr+0x17>
  800d04:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800d09:	5d                   	pop    %ebp
  800d0a:	c3                   	ret    

00800d0b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800d0b:	55                   	push   %ebp
  800d0c:	89 e5                	mov    %esp,%ebp
  800d0e:	8b 45 08             	mov    0x8(%ebp),%eax
  800d11:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800d15:	0f b6 10             	movzbl (%eax),%edx
  800d18:	84 d2                	test   %dl,%dl
  800d1a:	74 18                	je     800d34 <strfind+0x29>
		if (*s == c)
  800d1c:	38 ca                	cmp    %cl,%dl
  800d1e:	75 0a                	jne    800d2a <strfind+0x1f>
  800d20:	eb 12                	jmp    800d34 <strfind+0x29>
  800d22:	38 ca                	cmp    %cl,%dl
  800d24:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800d28:	74 0a                	je     800d34 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800d2a:	83 c0 01             	add    $0x1,%eax
  800d2d:	0f b6 10             	movzbl (%eax),%edx
  800d30:	84 d2                	test   %dl,%dl
  800d32:	75 ee                	jne    800d22 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800d34:	5d                   	pop    %ebp
  800d35:	c3                   	ret    

00800d36 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800d36:	55                   	push   %ebp
  800d37:	89 e5                	mov    %esp,%ebp
  800d39:	83 ec 0c             	sub    $0xc,%esp
  800d3c:	89 1c 24             	mov    %ebx,(%esp)
  800d3f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d43:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800d47:	8b 7d 08             	mov    0x8(%ebp),%edi
  800d4a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d4d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800d50:	85 c9                	test   %ecx,%ecx
  800d52:	74 30                	je     800d84 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800d54:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800d5a:	75 25                	jne    800d81 <memset+0x4b>
  800d5c:	f6 c1 03             	test   $0x3,%cl
  800d5f:	75 20                	jne    800d81 <memset+0x4b>
		c &= 0xFF;
  800d61:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800d64:	89 d3                	mov    %edx,%ebx
  800d66:	c1 e3 08             	shl    $0x8,%ebx
  800d69:	89 d6                	mov    %edx,%esi
  800d6b:	c1 e6 18             	shl    $0x18,%esi
  800d6e:	89 d0                	mov    %edx,%eax
  800d70:	c1 e0 10             	shl    $0x10,%eax
  800d73:	09 f0                	or     %esi,%eax
  800d75:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  800d77:	09 d8                	or     %ebx,%eax
  800d79:	c1 e9 02             	shr    $0x2,%ecx
  800d7c:	fc                   	cld    
  800d7d:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800d7f:	eb 03                	jmp    800d84 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800d81:	fc                   	cld    
  800d82:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800d84:	89 f8                	mov    %edi,%eax
  800d86:	8b 1c 24             	mov    (%esp),%ebx
  800d89:	8b 74 24 04          	mov    0x4(%esp),%esi
  800d8d:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800d91:	89 ec                	mov    %ebp,%esp
  800d93:	5d                   	pop    %ebp
  800d94:	c3                   	ret    

00800d95 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800d95:	55                   	push   %ebp
  800d96:	89 e5                	mov    %esp,%ebp
  800d98:	83 ec 08             	sub    $0x8,%esp
  800d9b:	89 34 24             	mov    %esi,(%esp)
  800d9e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800da2:	8b 45 08             	mov    0x8(%ebp),%eax
  800da5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800da8:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800dab:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800dad:	39 c6                	cmp    %eax,%esi
  800daf:	73 35                	jae    800de6 <memmove+0x51>
  800db1:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800db4:	39 d0                	cmp    %edx,%eax
  800db6:	73 2e                	jae    800de6 <memmove+0x51>
		s += n;
		d += n;
  800db8:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800dba:	f6 c2 03             	test   $0x3,%dl
  800dbd:	75 1b                	jne    800dda <memmove+0x45>
  800dbf:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800dc5:	75 13                	jne    800dda <memmove+0x45>
  800dc7:	f6 c1 03             	test   $0x3,%cl
  800dca:	75 0e                	jne    800dda <memmove+0x45>
			asm volatile("std; rep movsl\n"
  800dcc:	83 ef 04             	sub    $0x4,%edi
  800dcf:	8d 72 fc             	lea    -0x4(%edx),%esi
  800dd2:	c1 e9 02             	shr    $0x2,%ecx
  800dd5:	fd                   	std    
  800dd6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800dd8:	eb 09                	jmp    800de3 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800dda:	83 ef 01             	sub    $0x1,%edi
  800ddd:	8d 72 ff             	lea    -0x1(%edx),%esi
  800de0:	fd                   	std    
  800de1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800de3:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800de4:	eb 20                	jmp    800e06 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800de6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800dec:	75 15                	jne    800e03 <memmove+0x6e>
  800dee:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800df4:	75 0d                	jne    800e03 <memmove+0x6e>
  800df6:	f6 c1 03             	test   $0x3,%cl
  800df9:	75 08                	jne    800e03 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  800dfb:	c1 e9 02             	shr    $0x2,%ecx
  800dfe:	fc                   	cld    
  800dff:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e01:	eb 03                	jmp    800e06 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800e03:	fc                   	cld    
  800e04:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800e06:	8b 34 24             	mov    (%esp),%esi
  800e09:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800e0d:	89 ec                	mov    %ebp,%esp
  800e0f:	5d                   	pop    %ebp
  800e10:	c3                   	ret    

00800e11 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800e11:	55                   	push   %ebp
  800e12:	89 e5                	mov    %esp,%ebp
  800e14:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800e17:	8b 45 10             	mov    0x10(%ebp),%eax
  800e1a:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e1e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e21:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e25:	8b 45 08             	mov    0x8(%ebp),%eax
  800e28:	89 04 24             	mov    %eax,(%esp)
  800e2b:	e8 65 ff ff ff       	call   800d95 <memmove>
}
  800e30:	c9                   	leave  
  800e31:	c3                   	ret    

00800e32 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800e32:	55                   	push   %ebp
  800e33:	89 e5                	mov    %esp,%ebp
  800e35:	57                   	push   %edi
  800e36:	56                   	push   %esi
  800e37:	53                   	push   %ebx
  800e38:	8b 75 08             	mov    0x8(%ebp),%esi
  800e3b:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800e3e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e41:	85 c9                	test   %ecx,%ecx
  800e43:	74 36                	je     800e7b <memcmp+0x49>
		if (*s1 != *s2)
  800e45:	0f b6 06             	movzbl (%esi),%eax
  800e48:	0f b6 1f             	movzbl (%edi),%ebx
  800e4b:	38 d8                	cmp    %bl,%al
  800e4d:	74 20                	je     800e6f <memcmp+0x3d>
  800e4f:	eb 14                	jmp    800e65 <memcmp+0x33>
  800e51:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  800e56:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  800e5b:	83 c2 01             	add    $0x1,%edx
  800e5e:	83 e9 01             	sub    $0x1,%ecx
  800e61:	38 d8                	cmp    %bl,%al
  800e63:	74 12                	je     800e77 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  800e65:	0f b6 c0             	movzbl %al,%eax
  800e68:	0f b6 db             	movzbl %bl,%ebx
  800e6b:	29 d8                	sub    %ebx,%eax
  800e6d:	eb 11                	jmp    800e80 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e6f:	83 e9 01             	sub    $0x1,%ecx
  800e72:	ba 00 00 00 00       	mov    $0x0,%edx
  800e77:	85 c9                	test   %ecx,%ecx
  800e79:	75 d6                	jne    800e51 <memcmp+0x1f>
  800e7b:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800e80:	5b                   	pop    %ebx
  800e81:	5e                   	pop    %esi
  800e82:	5f                   	pop    %edi
  800e83:	5d                   	pop    %ebp
  800e84:	c3                   	ret    

00800e85 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800e85:	55                   	push   %ebp
  800e86:	89 e5                	mov    %esp,%ebp
  800e88:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800e8b:	89 c2                	mov    %eax,%edx
  800e8d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800e90:	39 d0                	cmp    %edx,%eax
  800e92:	73 15                	jae    800ea9 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800e94:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800e98:	38 08                	cmp    %cl,(%eax)
  800e9a:	75 06                	jne    800ea2 <memfind+0x1d>
  800e9c:	eb 0b                	jmp    800ea9 <memfind+0x24>
  800e9e:	38 08                	cmp    %cl,(%eax)
  800ea0:	74 07                	je     800ea9 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ea2:	83 c0 01             	add    $0x1,%eax
  800ea5:	39 c2                	cmp    %eax,%edx
  800ea7:	77 f5                	ja     800e9e <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ea9:	5d                   	pop    %ebp
  800eaa:	c3                   	ret    

00800eab <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800eab:	55                   	push   %ebp
  800eac:	89 e5                	mov    %esp,%ebp
  800eae:	57                   	push   %edi
  800eaf:	56                   	push   %esi
  800eb0:	53                   	push   %ebx
  800eb1:	83 ec 04             	sub    $0x4,%esp
  800eb4:	8b 55 08             	mov    0x8(%ebp),%edx
  800eb7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800eba:	0f b6 02             	movzbl (%edx),%eax
  800ebd:	3c 20                	cmp    $0x20,%al
  800ebf:	74 04                	je     800ec5 <strtol+0x1a>
  800ec1:	3c 09                	cmp    $0x9,%al
  800ec3:	75 0e                	jne    800ed3 <strtol+0x28>
		s++;
  800ec5:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ec8:	0f b6 02             	movzbl (%edx),%eax
  800ecb:	3c 20                	cmp    $0x20,%al
  800ecd:	74 f6                	je     800ec5 <strtol+0x1a>
  800ecf:	3c 09                	cmp    $0x9,%al
  800ed1:	74 f2                	je     800ec5 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ed3:	3c 2b                	cmp    $0x2b,%al
  800ed5:	75 0c                	jne    800ee3 <strtol+0x38>
		s++;
  800ed7:	83 c2 01             	add    $0x1,%edx
  800eda:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800ee1:	eb 15                	jmp    800ef8 <strtol+0x4d>
	else if (*s == '-')
  800ee3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800eea:	3c 2d                	cmp    $0x2d,%al
  800eec:	75 0a                	jne    800ef8 <strtol+0x4d>
		s++, neg = 1;
  800eee:	83 c2 01             	add    $0x1,%edx
  800ef1:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ef8:	85 db                	test   %ebx,%ebx
  800efa:	0f 94 c0             	sete   %al
  800efd:	74 05                	je     800f04 <strtol+0x59>
  800eff:	83 fb 10             	cmp    $0x10,%ebx
  800f02:	75 18                	jne    800f1c <strtol+0x71>
  800f04:	80 3a 30             	cmpb   $0x30,(%edx)
  800f07:	75 13                	jne    800f1c <strtol+0x71>
  800f09:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800f0d:	8d 76 00             	lea    0x0(%esi),%esi
  800f10:	75 0a                	jne    800f1c <strtol+0x71>
		s += 2, base = 16;
  800f12:	83 c2 02             	add    $0x2,%edx
  800f15:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800f1a:	eb 15                	jmp    800f31 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800f1c:	84 c0                	test   %al,%al
  800f1e:	66 90                	xchg   %ax,%ax
  800f20:	74 0f                	je     800f31 <strtol+0x86>
  800f22:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800f27:	80 3a 30             	cmpb   $0x30,(%edx)
  800f2a:	75 05                	jne    800f31 <strtol+0x86>
		s++, base = 8;
  800f2c:	83 c2 01             	add    $0x1,%edx
  800f2f:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800f31:	b8 00 00 00 00       	mov    $0x0,%eax
  800f36:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800f38:	0f b6 0a             	movzbl (%edx),%ecx
  800f3b:	89 cf                	mov    %ecx,%edi
  800f3d:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800f40:	80 fb 09             	cmp    $0x9,%bl
  800f43:	77 08                	ja     800f4d <strtol+0xa2>
			dig = *s - '0';
  800f45:	0f be c9             	movsbl %cl,%ecx
  800f48:	83 e9 30             	sub    $0x30,%ecx
  800f4b:	eb 1e                	jmp    800f6b <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  800f4d:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  800f50:	80 fb 19             	cmp    $0x19,%bl
  800f53:	77 08                	ja     800f5d <strtol+0xb2>
			dig = *s - 'a' + 10;
  800f55:	0f be c9             	movsbl %cl,%ecx
  800f58:	83 e9 57             	sub    $0x57,%ecx
  800f5b:	eb 0e                	jmp    800f6b <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  800f5d:	8d 5f bf             	lea    -0x41(%edi),%ebx
  800f60:	80 fb 19             	cmp    $0x19,%bl
  800f63:	77 15                	ja     800f7a <strtol+0xcf>
			dig = *s - 'A' + 10;
  800f65:	0f be c9             	movsbl %cl,%ecx
  800f68:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800f6b:	39 f1                	cmp    %esi,%ecx
  800f6d:	7d 0b                	jge    800f7a <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  800f6f:	83 c2 01             	add    $0x1,%edx
  800f72:	0f af c6             	imul   %esi,%eax
  800f75:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800f78:	eb be                	jmp    800f38 <strtol+0x8d>
  800f7a:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800f7c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800f80:	74 05                	je     800f87 <strtol+0xdc>
		*endptr = (char *) s;
  800f82:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800f85:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800f87:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800f8b:	74 04                	je     800f91 <strtol+0xe6>
  800f8d:	89 c8                	mov    %ecx,%eax
  800f8f:	f7 d8                	neg    %eax
}
  800f91:	83 c4 04             	add    $0x4,%esp
  800f94:	5b                   	pop    %ebx
  800f95:	5e                   	pop    %esi
  800f96:	5f                   	pop    %edi
  800f97:	5d                   	pop    %ebp
  800f98:	c3                   	ret    
  800f99:	00 00                	add    %al,(%eax)
	...

00800f9c <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  800f9c:	55                   	push   %ebp
  800f9d:	89 e5                	mov    %esp,%ebp
  800f9f:	83 ec 08             	sub    $0x8,%esp
  800fa2:	89 1c 24             	mov    %ebx,(%esp)
  800fa5:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800fa9:	ba 00 00 00 00       	mov    $0x0,%edx
  800fae:	b8 01 00 00 00       	mov    $0x1,%eax
  800fb3:	89 d1                	mov    %edx,%ecx
  800fb5:	89 d3                	mov    %edx,%ebx
  800fb7:	89 d7                	mov    %edx,%edi
  800fb9:	51                   	push   %ecx
  800fba:	52                   	push   %edx
  800fbb:	53                   	push   %ebx
  800fbc:	54                   	push   %esp
  800fbd:	55                   	push   %ebp
  800fbe:	56                   	push   %esi
  800fbf:	57                   	push   %edi
  800fc0:	54                   	push   %esp
  800fc1:	5d                   	pop    %ebp
  800fc2:	8d 35 ca 0f 80 00    	lea    0x800fca,%esi
  800fc8:	0f 34                	sysenter 
  800fca:	5f                   	pop    %edi
  800fcb:	5e                   	pop    %esi
  800fcc:	5d                   	pop    %ebp
  800fcd:	5c                   	pop    %esp
  800fce:	5b                   	pop    %ebx
  800fcf:	5a                   	pop    %edx
  800fd0:	59                   	pop    %ecx

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800fd1:	8b 1c 24             	mov    (%esp),%ebx
  800fd4:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800fd8:	89 ec                	mov    %ebp,%esp
  800fda:	5d                   	pop    %ebp
  800fdb:	c3                   	ret    

00800fdc <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800fdc:	55                   	push   %ebp
  800fdd:	89 e5                	mov    %esp,%ebp
  800fdf:	83 ec 08             	sub    $0x8,%esp
  800fe2:	89 1c 24             	mov    %ebx,(%esp)
  800fe5:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800fe9:	b8 00 00 00 00       	mov    $0x0,%eax
  800fee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ff1:	8b 55 08             	mov    0x8(%ebp),%edx
  800ff4:	89 c3                	mov    %eax,%ebx
  800ff6:	89 c7                	mov    %eax,%edi
  800ff8:	51                   	push   %ecx
  800ff9:	52                   	push   %edx
  800ffa:	53                   	push   %ebx
  800ffb:	54                   	push   %esp
  800ffc:	55                   	push   %ebp
  800ffd:	56                   	push   %esi
  800ffe:	57                   	push   %edi
  800fff:	54                   	push   %esp
  801000:	5d                   	pop    %ebp
  801001:	8d 35 09 10 80 00    	lea    0x801009,%esi
  801007:	0f 34                	sysenter 
  801009:	5f                   	pop    %edi
  80100a:	5e                   	pop    %esi
  80100b:	5d                   	pop    %ebp
  80100c:	5c                   	pop    %esp
  80100d:	5b                   	pop    %ebx
  80100e:	5a                   	pop    %edx
  80100f:	59                   	pop    %ecx

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  801010:	8b 1c 24             	mov    (%esp),%ebx
  801013:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801017:	89 ec                	mov    %ebp,%esp
  801019:	5d                   	pop    %ebp
  80101a:	c3                   	ret    

0080101b <sys_exec>:
sys_env_set_prior(envid_t envid, uint32_t prior){
         return syscall(SYS_env_set_prior,1,envid, prior, 0, 0, 0);
}

int 
sys_exec(void* vph, uint32_t phnum, uint32_t esp, uint32_t eip){
  80101b:	55                   	push   %ebp
  80101c:	89 e5                	mov    %esp,%ebp
  80101e:	83 ec 08             	sub    $0x8,%esp
  801021:	89 1c 24             	mov    %ebx,(%esp)
  801024:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801028:	b8 10 00 00 00       	mov    $0x10,%eax
  80102d:	8b 7d 14             	mov    0x14(%ebp),%edi
  801030:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801033:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801036:	8b 55 08             	mov    0x8(%ebp),%edx
  801039:	51                   	push   %ecx
  80103a:	52                   	push   %edx
  80103b:	53                   	push   %ebx
  80103c:	54                   	push   %esp
  80103d:	55                   	push   %ebp
  80103e:	56                   	push   %esi
  80103f:	57                   	push   %edi
  801040:	54                   	push   %esp
  801041:	5d                   	pop    %ebp
  801042:	8d 35 4a 10 80 00    	lea    0x80104a,%esi
  801048:	0f 34                	sysenter 
  80104a:	5f                   	pop    %edi
  80104b:	5e                   	pop    %esi
  80104c:	5d                   	pop    %ebp
  80104d:	5c                   	pop    %esp
  80104e:	5b                   	pop    %ebx
  80104f:	5a                   	pop    %edx
  801050:	59                   	pop    %ecx
}

int 
sys_exec(void* vph, uint32_t phnum, uint32_t esp, uint32_t eip){
         return syscall(SYS_exec, 0, (uint32_t)vph, phnum, esp, eip, 0);
}
  801051:	8b 1c 24             	mov    (%esp),%ebx
  801054:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801058:	89 ec                	mov    %ebp,%esp
  80105a:	5d                   	pop    %ebp
  80105b:	c3                   	ret    

0080105c <sys_env_set_prior>:
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}

int 
sys_env_set_prior(envid_t envid, uint32_t prior){
  80105c:	55                   	push   %ebp
  80105d:	89 e5                	mov    %esp,%ebp
  80105f:	83 ec 28             	sub    $0x28,%esp
  801062:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801065:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801068:	bb 00 00 00 00       	mov    $0x0,%ebx
  80106d:	b8 0f 00 00 00       	mov    $0xf,%eax
  801072:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801075:	8b 55 08             	mov    0x8(%ebp),%edx
  801078:	89 df                	mov    %ebx,%edi
  80107a:	51                   	push   %ecx
  80107b:	52                   	push   %edx
  80107c:	53                   	push   %ebx
  80107d:	54                   	push   %esp
  80107e:	55                   	push   %ebp
  80107f:	56                   	push   %esi
  801080:	57                   	push   %edi
  801081:	54                   	push   %esp
  801082:	5d                   	pop    %ebp
  801083:	8d 35 8b 10 80 00    	lea    0x80108b,%esi
  801089:	0f 34                	sysenter 
  80108b:	5f                   	pop    %edi
  80108c:	5e                   	pop    %esi
  80108d:	5d                   	pop    %ebp
  80108e:	5c                   	pop    %esp
  80108f:	5b                   	pop    %ebx
  801090:	5a                   	pop    %edx
  801091:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801092:	85 c0                	test   %eax,%eax
  801094:	7e 28                	jle    8010be <sys_env_set_prior+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  801096:	89 44 24 10          	mov    %eax,0x10(%esp)
  80109a:	c7 44 24 0c 0f 00 00 	movl   $0xf,0xc(%esp)
  8010a1:	00 
  8010a2:	c7 44 24 08 e0 29 80 	movl   $0x8029e0,0x8(%esp)
  8010a9:	00 
  8010aa:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8010b1:	00 
  8010b2:	c7 04 24 fd 29 80 00 	movl   $0x8029fd,(%esp)
  8010b9:	e8 02 f1 ff ff       	call   8001c0 <_panic>
}

int 
sys_env_set_prior(envid_t envid, uint32_t prior){
         return syscall(SYS_env_set_prior,1,envid, prior, 0, 0, 0);
}
  8010be:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8010c1:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8010c4:	89 ec                	mov    %ebp,%esp
  8010c6:	5d                   	pop    %ebp
  8010c7:	c3                   	ret    

008010c8 <sys_sbrk>:
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}

int
sys_sbrk(uint32_t inc)
{
  8010c8:	55                   	push   %ebp
  8010c9:	89 e5                	mov    %esp,%ebp
  8010cb:	83 ec 08             	sub    $0x8,%esp
  8010ce:	89 1c 24             	mov    %ebx,(%esp)
  8010d1:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8010d5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010da:	b8 11 00 00 00       	mov    $0x11,%eax
  8010df:	8b 55 08             	mov    0x8(%ebp),%edx
  8010e2:	89 cb                	mov    %ecx,%ebx
  8010e4:	89 cf                	mov    %ecx,%edi
  8010e6:	51                   	push   %ecx
  8010e7:	52                   	push   %edx
  8010e8:	53                   	push   %ebx
  8010e9:	54                   	push   %esp
  8010ea:	55                   	push   %ebp
  8010eb:	56                   	push   %esi
  8010ec:	57                   	push   %edi
  8010ed:	54                   	push   %esp
  8010ee:	5d                   	pop    %ebp
  8010ef:	8d 35 f7 10 80 00    	lea    0x8010f7,%esi
  8010f5:	0f 34                	sysenter 
  8010f7:	5f                   	pop    %edi
  8010f8:	5e                   	pop    %esi
  8010f9:	5d                   	pop    %ebp
  8010fa:	5c                   	pop    %esp
  8010fb:	5b                   	pop    %ebx
  8010fc:	5a                   	pop    %edx
  8010fd:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  8010fe:	8b 1c 24             	mov    (%esp),%ebx
  801101:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801105:	89 ec                	mov    %ebp,%esp
  801107:	5d                   	pop    %ebp
  801108:	c3                   	ret    

00801109 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  801109:	55                   	push   %ebp
  80110a:	89 e5                	mov    %esp,%ebp
  80110c:	83 ec 28             	sub    $0x28,%esp
  80110f:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801112:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801115:	b9 00 00 00 00       	mov    $0x0,%ecx
  80111a:	b8 0e 00 00 00       	mov    $0xe,%eax
  80111f:	8b 55 08             	mov    0x8(%ebp),%edx
  801122:	89 cb                	mov    %ecx,%ebx
  801124:	89 cf                	mov    %ecx,%edi
  801126:	51                   	push   %ecx
  801127:	52                   	push   %edx
  801128:	53                   	push   %ebx
  801129:	54                   	push   %esp
  80112a:	55                   	push   %ebp
  80112b:	56                   	push   %esi
  80112c:	57                   	push   %edi
  80112d:	54                   	push   %esp
  80112e:	5d                   	pop    %ebp
  80112f:	8d 35 37 11 80 00    	lea    0x801137,%esi
  801135:	0f 34                	sysenter 
  801137:	5f                   	pop    %edi
  801138:	5e                   	pop    %esi
  801139:	5d                   	pop    %ebp
  80113a:	5c                   	pop    %esp
  80113b:	5b                   	pop    %ebx
  80113c:	5a                   	pop    %edx
  80113d:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80113e:	85 c0                	test   %eax,%eax
  801140:	7e 28                	jle    80116a <sys_ipc_recv+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  801142:	89 44 24 10          	mov    %eax,0x10(%esp)
  801146:	c7 44 24 0c 0e 00 00 	movl   $0xe,0xc(%esp)
  80114d:	00 
  80114e:	c7 44 24 08 e0 29 80 	movl   $0x8029e0,0x8(%esp)
  801155:	00 
  801156:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80115d:	00 
  80115e:	c7 04 24 fd 29 80 00 	movl   $0x8029fd,(%esp)
  801165:	e8 56 f0 ff ff       	call   8001c0 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80116a:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80116d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801170:	89 ec                	mov    %ebp,%esp
  801172:	5d                   	pop    %ebp
  801173:	c3                   	ret    

00801174 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801174:	55                   	push   %ebp
  801175:	89 e5                	mov    %esp,%ebp
  801177:	83 ec 08             	sub    $0x8,%esp
  80117a:	89 1c 24             	mov    %ebx,(%esp)
  80117d:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801181:	b8 0d 00 00 00       	mov    $0xd,%eax
  801186:	8b 7d 14             	mov    0x14(%ebp),%edi
  801189:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80118c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80118f:	8b 55 08             	mov    0x8(%ebp),%edx
  801192:	51                   	push   %ecx
  801193:	52                   	push   %edx
  801194:	53                   	push   %ebx
  801195:	54                   	push   %esp
  801196:	55                   	push   %ebp
  801197:	56                   	push   %esi
  801198:	57                   	push   %edi
  801199:	54                   	push   %esp
  80119a:	5d                   	pop    %ebp
  80119b:	8d 35 a3 11 80 00    	lea    0x8011a3,%esi
  8011a1:	0f 34                	sysenter 
  8011a3:	5f                   	pop    %edi
  8011a4:	5e                   	pop    %esi
  8011a5:	5d                   	pop    %ebp
  8011a6:	5c                   	pop    %esp
  8011a7:	5b                   	pop    %ebx
  8011a8:	5a                   	pop    %edx
  8011a9:	59                   	pop    %ecx

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8011aa:	8b 1c 24             	mov    (%esp),%ebx
  8011ad:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8011b1:	89 ec                	mov    %ebp,%esp
  8011b3:	5d                   	pop    %ebp
  8011b4:	c3                   	ret    

008011b5 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8011b5:	55                   	push   %ebp
  8011b6:	89 e5                	mov    %esp,%ebp
  8011b8:	83 ec 28             	sub    $0x28,%esp
  8011bb:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8011be:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8011c1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011c6:	b8 0b 00 00 00       	mov    $0xb,%eax
  8011cb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011ce:	8b 55 08             	mov    0x8(%ebp),%edx
  8011d1:	89 df                	mov    %ebx,%edi
  8011d3:	51                   	push   %ecx
  8011d4:	52                   	push   %edx
  8011d5:	53                   	push   %ebx
  8011d6:	54                   	push   %esp
  8011d7:	55                   	push   %ebp
  8011d8:	56                   	push   %esi
  8011d9:	57                   	push   %edi
  8011da:	54                   	push   %esp
  8011db:	5d                   	pop    %ebp
  8011dc:	8d 35 e4 11 80 00    	lea    0x8011e4,%esi
  8011e2:	0f 34                	sysenter 
  8011e4:	5f                   	pop    %edi
  8011e5:	5e                   	pop    %esi
  8011e6:	5d                   	pop    %ebp
  8011e7:	5c                   	pop    %esp
  8011e8:	5b                   	pop    %ebx
  8011e9:	5a                   	pop    %edx
  8011ea:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8011eb:	85 c0                	test   %eax,%eax
  8011ed:	7e 28                	jle    801217 <sys_env_set_pgfault_upcall+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011ef:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011f3:	c7 44 24 0c 0b 00 00 	movl   $0xb,0xc(%esp)
  8011fa:	00 
  8011fb:	c7 44 24 08 e0 29 80 	movl   $0x8029e0,0x8(%esp)
  801202:	00 
  801203:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80120a:	00 
  80120b:	c7 04 24 fd 29 80 00 	movl   $0x8029fd,(%esp)
  801212:	e8 a9 ef ff ff       	call   8001c0 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801217:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80121a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80121d:	89 ec                	mov    %ebp,%esp
  80121f:	5d                   	pop    %ebp
  801220:	c3                   	ret    

00801221 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801221:	55                   	push   %ebp
  801222:	89 e5                	mov    %esp,%ebp
  801224:	83 ec 28             	sub    $0x28,%esp
  801227:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80122a:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80122d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801232:	b8 0a 00 00 00       	mov    $0xa,%eax
  801237:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80123a:	8b 55 08             	mov    0x8(%ebp),%edx
  80123d:	89 df                	mov    %ebx,%edi
  80123f:	51                   	push   %ecx
  801240:	52                   	push   %edx
  801241:	53                   	push   %ebx
  801242:	54                   	push   %esp
  801243:	55                   	push   %ebp
  801244:	56                   	push   %esi
  801245:	57                   	push   %edi
  801246:	54                   	push   %esp
  801247:	5d                   	pop    %ebp
  801248:	8d 35 50 12 80 00    	lea    0x801250,%esi
  80124e:	0f 34                	sysenter 
  801250:	5f                   	pop    %edi
  801251:	5e                   	pop    %esi
  801252:	5d                   	pop    %ebp
  801253:	5c                   	pop    %esp
  801254:	5b                   	pop    %ebx
  801255:	5a                   	pop    %edx
  801256:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801257:	85 c0                	test   %eax,%eax
  801259:	7e 28                	jle    801283 <sys_env_set_trapframe+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  80125b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80125f:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  801266:	00 
  801267:	c7 44 24 08 e0 29 80 	movl   $0x8029e0,0x8(%esp)
  80126e:	00 
  80126f:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801276:	00 
  801277:	c7 04 24 fd 29 80 00 	movl   $0x8029fd,(%esp)
  80127e:	e8 3d ef ff ff       	call   8001c0 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801283:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801286:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801289:	89 ec                	mov    %ebp,%esp
  80128b:	5d                   	pop    %ebp
  80128c:	c3                   	ret    

0080128d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80128d:	55                   	push   %ebp
  80128e:	89 e5                	mov    %esp,%ebp
  801290:	83 ec 28             	sub    $0x28,%esp
  801293:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801296:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801299:	bb 00 00 00 00       	mov    $0x0,%ebx
  80129e:	b8 09 00 00 00       	mov    $0x9,%eax
  8012a3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012a6:	8b 55 08             	mov    0x8(%ebp),%edx
  8012a9:	89 df                	mov    %ebx,%edi
  8012ab:	51                   	push   %ecx
  8012ac:	52                   	push   %edx
  8012ad:	53                   	push   %ebx
  8012ae:	54                   	push   %esp
  8012af:	55                   	push   %ebp
  8012b0:	56                   	push   %esi
  8012b1:	57                   	push   %edi
  8012b2:	54                   	push   %esp
  8012b3:	5d                   	pop    %ebp
  8012b4:	8d 35 bc 12 80 00    	lea    0x8012bc,%esi
  8012ba:	0f 34                	sysenter 
  8012bc:	5f                   	pop    %edi
  8012bd:	5e                   	pop    %esi
  8012be:	5d                   	pop    %ebp
  8012bf:	5c                   	pop    %esp
  8012c0:	5b                   	pop    %ebx
  8012c1:	5a                   	pop    %edx
  8012c2:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8012c3:	85 c0                	test   %eax,%eax
  8012c5:	7e 28                	jle    8012ef <sys_env_set_status+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012c7:	89 44 24 10          	mov    %eax,0x10(%esp)
  8012cb:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8012d2:	00 
  8012d3:	c7 44 24 08 e0 29 80 	movl   $0x8029e0,0x8(%esp)
  8012da:	00 
  8012db:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8012e2:	00 
  8012e3:	c7 04 24 fd 29 80 00 	movl   $0x8029fd,(%esp)
  8012ea:	e8 d1 ee ff ff       	call   8001c0 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8012ef:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8012f2:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8012f5:	89 ec                	mov    %ebp,%esp
  8012f7:	5d                   	pop    %ebp
  8012f8:	c3                   	ret    

008012f9 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  8012f9:	55                   	push   %ebp
  8012fa:	89 e5                	mov    %esp,%ebp
  8012fc:	83 ec 28             	sub    $0x28,%esp
  8012ff:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801302:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801305:	bb 00 00 00 00       	mov    $0x0,%ebx
  80130a:	b8 07 00 00 00       	mov    $0x7,%eax
  80130f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801312:	8b 55 08             	mov    0x8(%ebp),%edx
  801315:	89 df                	mov    %ebx,%edi
  801317:	51                   	push   %ecx
  801318:	52                   	push   %edx
  801319:	53                   	push   %ebx
  80131a:	54                   	push   %esp
  80131b:	55                   	push   %ebp
  80131c:	56                   	push   %esi
  80131d:	57                   	push   %edi
  80131e:	54                   	push   %esp
  80131f:	5d                   	pop    %ebp
  801320:	8d 35 28 13 80 00    	lea    0x801328,%esi
  801326:	0f 34                	sysenter 
  801328:	5f                   	pop    %edi
  801329:	5e                   	pop    %esi
  80132a:	5d                   	pop    %ebp
  80132b:	5c                   	pop    %esp
  80132c:	5b                   	pop    %ebx
  80132d:	5a                   	pop    %edx
  80132e:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80132f:	85 c0                	test   %eax,%eax
  801331:	7e 28                	jle    80135b <sys_page_unmap+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  801333:	89 44 24 10          	mov    %eax,0x10(%esp)
  801337:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80133e:	00 
  80133f:	c7 44 24 08 e0 29 80 	movl   $0x8029e0,0x8(%esp)
  801346:	00 
  801347:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80134e:	00 
  80134f:	c7 04 24 fd 29 80 00 	movl   $0x8029fd,(%esp)
  801356:	e8 65 ee ff ff       	call   8001c0 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80135b:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80135e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801361:	89 ec                	mov    %ebp,%esp
  801363:	5d                   	pop    %ebp
  801364:	c3                   	ret    

00801365 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  801365:	55                   	push   %ebp
  801366:	89 e5                	mov    %esp,%ebp
  801368:	83 ec 28             	sub    $0x28,%esp
  80136b:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80136e:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801371:	8b 7d 18             	mov    0x18(%ebp),%edi
  801374:	0b 7d 14             	or     0x14(%ebp),%edi
  801377:	b8 06 00 00 00       	mov    $0x6,%eax
  80137c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80137f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801382:	8b 55 08             	mov    0x8(%ebp),%edx
  801385:	51                   	push   %ecx
  801386:	52                   	push   %edx
  801387:	53                   	push   %ebx
  801388:	54                   	push   %esp
  801389:	55                   	push   %ebp
  80138a:	56                   	push   %esi
  80138b:	57                   	push   %edi
  80138c:	54                   	push   %esp
  80138d:	5d                   	pop    %ebp
  80138e:	8d 35 96 13 80 00    	lea    0x801396,%esi
  801394:	0f 34                	sysenter 
  801396:	5f                   	pop    %edi
  801397:	5e                   	pop    %esi
  801398:	5d                   	pop    %ebp
  801399:	5c                   	pop    %esp
  80139a:	5b                   	pop    %ebx
  80139b:	5a                   	pop    %edx
  80139c:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80139d:	85 c0                	test   %eax,%eax
  80139f:	7e 28                	jle    8013c9 <sys_page_map+0x64>
		panic("syscall %d returned %d (> 0)", num, ret);
  8013a1:	89 44 24 10          	mov    %eax,0x10(%esp)
  8013a5:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  8013ac:	00 
  8013ad:	c7 44 24 08 e0 29 80 	movl   $0x8029e0,0x8(%esp)
  8013b4:	00 
  8013b5:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8013bc:	00 
  8013bd:	c7 04 24 fd 29 80 00 	movl   $0x8029fd,(%esp)
  8013c4:	e8 f7 ed ff ff       	call   8001c0 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}
  8013c9:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8013cc:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8013cf:	89 ec                	mov    %ebp,%esp
  8013d1:	5d                   	pop    %ebp
  8013d2:	c3                   	ret    

008013d3 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8013d3:	55                   	push   %ebp
  8013d4:	89 e5                	mov    %esp,%ebp
  8013d6:	83 ec 28             	sub    $0x28,%esp
  8013d9:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8013dc:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8013df:	bf 00 00 00 00       	mov    $0x0,%edi
  8013e4:	b8 05 00 00 00       	mov    $0x5,%eax
  8013e9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8013ec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013ef:	8b 55 08             	mov    0x8(%ebp),%edx
  8013f2:	51                   	push   %ecx
  8013f3:	52                   	push   %edx
  8013f4:	53                   	push   %ebx
  8013f5:	54                   	push   %esp
  8013f6:	55                   	push   %ebp
  8013f7:	56                   	push   %esi
  8013f8:	57                   	push   %edi
  8013f9:	54                   	push   %esp
  8013fa:	5d                   	pop    %ebp
  8013fb:	8d 35 03 14 80 00    	lea    0x801403,%esi
  801401:	0f 34                	sysenter 
  801403:	5f                   	pop    %edi
  801404:	5e                   	pop    %esi
  801405:	5d                   	pop    %ebp
  801406:	5c                   	pop    %esp
  801407:	5b                   	pop    %ebx
  801408:	5a                   	pop    %edx
  801409:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80140a:	85 c0                	test   %eax,%eax
  80140c:	7e 28                	jle    801436 <sys_page_alloc+0x63>
		panic("syscall %d returned %d (> 0)", num, ret);
  80140e:	89 44 24 10          	mov    %eax,0x10(%esp)
  801412:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  801419:	00 
  80141a:	c7 44 24 08 e0 29 80 	movl   $0x8029e0,0x8(%esp)
  801421:	00 
  801422:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801429:	00 
  80142a:	c7 04 24 fd 29 80 00 	movl   $0x8029fd,(%esp)
  801431:	e8 8a ed ff ff       	call   8001c0 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  801436:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801439:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80143c:	89 ec                	mov    %ebp,%esp
  80143e:	5d                   	pop    %ebp
  80143f:	c3                   	ret    

00801440 <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
{
  801440:	55                   	push   %ebp
  801441:	89 e5                	mov    %esp,%ebp
  801443:	83 ec 08             	sub    $0x8,%esp
  801446:	89 1c 24             	mov    %ebx,(%esp)
  801449:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80144d:	ba 00 00 00 00       	mov    $0x0,%edx
  801452:	b8 0c 00 00 00       	mov    $0xc,%eax
  801457:	89 d1                	mov    %edx,%ecx
  801459:	89 d3                	mov    %edx,%ebx
  80145b:	89 d7                	mov    %edx,%edi
  80145d:	51                   	push   %ecx
  80145e:	52                   	push   %edx
  80145f:	53                   	push   %ebx
  801460:	54                   	push   %esp
  801461:	55                   	push   %ebp
  801462:	56                   	push   %esi
  801463:	57                   	push   %edi
  801464:	54                   	push   %esp
  801465:	5d                   	pop    %ebp
  801466:	8d 35 6e 14 80 00    	lea    0x80146e,%esi
  80146c:	0f 34                	sysenter 
  80146e:	5f                   	pop    %edi
  80146f:	5e                   	pop    %esi
  801470:	5d                   	pop    %ebp
  801471:	5c                   	pop    %esp
  801472:	5b                   	pop    %ebx
  801473:	5a                   	pop    %edx
  801474:	59                   	pop    %ecx

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  801475:	8b 1c 24             	mov    (%esp),%ebx
  801478:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80147c:	89 ec                	mov    %ebp,%esp
  80147e:	5d                   	pop    %ebp
  80147f:	c3                   	ret    

00801480 <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
{
  801480:	55                   	push   %ebp
  801481:	89 e5                	mov    %esp,%ebp
  801483:	83 ec 08             	sub    $0x8,%esp
  801486:	89 1c 24             	mov    %ebx,(%esp)
  801489:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80148d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801492:	b8 04 00 00 00       	mov    $0x4,%eax
  801497:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80149a:	8b 55 08             	mov    0x8(%ebp),%edx
  80149d:	89 df                	mov    %ebx,%edi
  80149f:	51                   	push   %ecx
  8014a0:	52                   	push   %edx
  8014a1:	53                   	push   %ebx
  8014a2:	54                   	push   %esp
  8014a3:	55                   	push   %ebp
  8014a4:	56                   	push   %esi
  8014a5:	57                   	push   %edi
  8014a6:	54                   	push   %esp
  8014a7:	5d                   	pop    %ebp
  8014a8:	8d 35 b0 14 80 00    	lea    0x8014b0,%esi
  8014ae:	0f 34                	sysenter 
  8014b0:	5f                   	pop    %edi
  8014b1:	5e                   	pop    %esi
  8014b2:	5d                   	pop    %ebp
  8014b3:	5c                   	pop    %esp
  8014b4:	5b                   	pop    %ebx
  8014b5:	5a                   	pop    %edx
  8014b6:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  8014b7:	8b 1c 24             	mov    (%esp),%ebx
  8014ba:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8014be:	89 ec                	mov    %ebp,%esp
  8014c0:	5d                   	pop    %ebp
  8014c1:	c3                   	ret    

008014c2 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  8014c2:	55                   	push   %ebp
  8014c3:	89 e5                	mov    %esp,%ebp
  8014c5:	83 ec 08             	sub    $0x8,%esp
  8014c8:	89 1c 24             	mov    %ebx,(%esp)
  8014cb:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8014cf:	ba 00 00 00 00       	mov    $0x0,%edx
  8014d4:	b8 02 00 00 00       	mov    $0x2,%eax
  8014d9:	89 d1                	mov    %edx,%ecx
  8014db:	89 d3                	mov    %edx,%ebx
  8014dd:	89 d7                	mov    %edx,%edi
  8014df:	51                   	push   %ecx
  8014e0:	52                   	push   %edx
  8014e1:	53                   	push   %ebx
  8014e2:	54                   	push   %esp
  8014e3:	55                   	push   %ebp
  8014e4:	56                   	push   %esi
  8014e5:	57                   	push   %edi
  8014e6:	54                   	push   %esp
  8014e7:	5d                   	pop    %ebp
  8014e8:	8d 35 f0 14 80 00    	lea    0x8014f0,%esi
  8014ee:	0f 34                	sysenter 
  8014f0:	5f                   	pop    %edi
  8014f1:	5e                   	pop    %esi
  8014f2:	5d                   	pop    %ebp
  8014f3:	5c                   	pop    %esp
  8014f4:	5b                   	pop    %ebx
  8014f5:	5a                   	pop    %edx
  8014f6:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8014f7:	8b 1c 24             	mov    (%esp),%ebx
  8014fa:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8014fe:	89 ec                	mov    %ebp,%esp
  801500:	5d                   	pop    %ebp
  801501:	c3                   	ret    

00801502 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  801502:	55                   	push   %ebp
  801503:	89 e5                	mov    %esp,%ebp
  801505:	83 ec 28             	sub    $0x28,%esp
  801508:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80150b:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80150e:	b9 00 00 00 00       	mov    $0x0,%ecx
  801513:	b8 03 00 00 00       	mov    $0x3,%eax
  801518:	8b 55 08             	mov    0x8(%ebp),%edx
  80151b:	89 cb                	mov    %ecx,%ebx
  80151d:	89 cf                	mov    %ecx,%edi
  80151f:	51                   	push   %ecx
  801520:	52                   	push   %edx
  801521:	53                   	push   %ebx
  801522:	54                   	push   %esp
  801523:	55                   	push   %ebp
  801524:	56                   	push   %esi
  801525:	57                   	push   %edi
  801526:	54                   	push   %esp
  801527:	5d                   	pop    %ebp
  801528:	8d 35 30 15 80 00    	lea    0x801530,%esi
  80152e:	0f 34                	sysenter 
  801530:	5f                   	pop    %edi
  801531:	5e                   	pop    %esi
  801532:	5d                   	pop    %ebp
  801533:	5c                   	pop    %esp
  801534:	5b                   	pop    %ebx
  801535:	5a                   	pop    %edx
  801536:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801537:	85 c0                	test   %eax,%eax
  801539:	7e 28                	jle    801563 <sys_env_destroy+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  80153b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80153f:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  801546:	00 
  801547:	c7 44 24 08 e0 29 80 	movl   $0x8029e0,0x8(%esp)
  80154e:	00 
  80154f:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801556:	00 
  801557:	c7 04 24 fd 29 80 00 	movl   $0x8029fd,(%esp)
  80155e:	e8 5d ec ff ff       	call   8001c0 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801563:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801566:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801569:	89 ec                	mov    %ebp,%esp
  80156b:	5d                   	pop    %ebp
  80156c:	c3                   	ret    
  80156d:	00 00                	add    %al,(%eax)
	...

00801570 <sfork>:
}

// Challenge!
int
sfork(void)
{
  801570:	55                   	push   %ebp
  801571:	89 e5                	mov    %esp,%ebp
  801573:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  801576:	c7 44 24 08 0b 2a 80 	movl   $0x802a0b,0x8(%esp)
  80157d:	00 
  80157e:	c7 44 24 04 8e 00 00 	movl   $0x8e,0x4(%esp)
  801585:	00 
  801586:	c7 04 24 21 2a 80 00 	movl   $0x802a21,(%esp)
  80158d:	e8 2e ec ff ff       	call   8001c0 <_panic>

00801592 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801592:	55                   	push   %ebp
  801593:	89 e5                	mov    %esp,%ebp
  801595:	57                   	push   %edi
  801596:	56                   	push   %esi
  801597:	53                   	push   %ebx
  801598:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
        set_pgfault_handler(pgfault);
  80159b:	c7 04 24 e7 17 80 00 	movl   $0x8017e7,(%esp)
  8015a2:	e8 7d 0d 00 00       	call   802324 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  8015a7:	ba 08 00 00 00       	mov    $0x8,%edx
  8015ac:	89 d0                	mov    %edx,%eax
  8015ae:	cd 30                	int    $0x30
  8015b0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        envid_t envid = sys_exofork();
        uint32_t addr;
        extern void _pgfault_upcall();
        int r = 0;
        if (envid < 0)
  8015b3:	85 c0                	test   %eax,%eax
  8015b5:	79 20                	jns    8015d7 <fork+0x45>
		panic("sys_exofork: %e", envid);
  8015b7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8015bb:	c7 44 24 08 2c 2a 80 	movl   $0x802a2c,0x8(%esp)
  8015c2:	00 
  8015c3:	c7 44 24 04 74 00 00 	movl   $0x74,0x4(%esp)
  8015ca:	00 
  8015cb:	c7 04 24 21 2a 80 00 	movl   $0x802a21,(%esp)
  8015d2:	e8 e9 eb ff ff       	call   8001c0 <_panic>
	if (envid == 0) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
  8015d7:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
        for(addr = 0; addr < USTACKTOP; addr += PGSIZE){
           if((vpd[PDX(addr)] & PTE_P) && (vpt[PGNUM(addr)] & PTE_P) && (vpt[PGNUM(addr)] & PTE_U))
  8015dc:	be 00 d0 7b ef       	mov    $0xef7bd000,%esi
  8015e1:	bf 00 00 40 ef       	mov    $0xef400000,%edi
        uint32_t addr;
        extern void _pgfault_upcall();
        int r = 0;
        if (envid < 0)
		panic("sys_exofork: %e", envid);
	if (envid == 0) {
  8015e6:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8015ea:	75 20                	jne    80160c <fork+0x7a>
		thisenv = &envs[ENVX(sys_getenvid())];
  8015ec:	e8 d1 fe ff ff       	call   8014c2 <sys_getenvid>
  8015f1:	25 ff 03 00 00       	and    $0x3ff,%eax
  8015f6:	89 c2                	mov    %eax,%edx
  8015f8:	c1 e2 07             	shl    $0x7,%edx
  8015fb:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  801602:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  801607:	e9 d0 01 00 00       	jmp    8017dc <fork+0x24a>
	}
        for(addr = 0; addr < USTACKTOP; addr += PGSIZE){
           if((vpd[PDX(addr)] & PTE_P) && (vpt[PGNUM(addr)] & PTE_P) && (vpt[PGNUM(addr)] & PTE_U))
  80160c:	89 d8                	mov    %ebx,%eax
  80160e:	c1 e8 16             	shr    $0x16,%eax
  801611:	8b 04 86             	mov    (%esi,%eax,4),%eax
  801614:	a8 01                	test   $0x1,%al
  801616:	0f 84 0d 01 00 00    	je     801729 <fork+0x197>
  80161c:	89 d8                	mov    %ebx,%eax
  80161e:	c1 e8 0c             	shr    $0xc,%eax
  801621:	8b 14 87             	mov    (%edi,%eax,4),%edx
  801624:	f6 c2 01             	test   $0x1,%dl
  801627:	0f 84 fc 00 00 00    	je     801729 <fork+0x197>
  80162d:	8b 14 87             	mov    (%edi,%eax,4),%edx
  801630:	f6 c2 04             	test   $0x4,%dl
  801633:	0f 84 f0 00 00 00    	je     801729 <fork+0x197>
duppage(envid_t envid, unsigned pn)
{
	int r;
        
	// LAB 4: Your code here.
        uint32_t addr = pn*PGSIZE;
  801639:	c1 e0 0c             	shl    $0xc,%eax
        pte_t pte = vpt[PGNUM(addr)];
  80163c:	89 c2                	mov    %eax,%edx
  80163e:	c1 ea 0c             	shr    $0xc,%edx
  801641:	8b 14 97             	mov    (%edi,%edx,4),%edx
        if(pte & PTE_P){
  801644:	f6 c2 01             	test   $0x1,%dl
  801647:	0f 84 dc 00 00 00    	je     801729 <fork+0x197>
          if((pte & PTE_W)|| (pte & PTE_COW)){
  80164d:	f7 c2 02 08 00 00    	test   $0x802,%edx
  801653:	0f 84 8d 00 00 00    	je     8016e6 <fork+0x154>
               r = sys_page_map(0,(void*)addr,envid,(void*)addr,PTE_P|PTE_U|PTE_COW);
  801659:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80165c:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  801663:	00 
  801664:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801668:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80166b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80166f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801673:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80167a:	e8 e6 fc ff ff       	call   801365 <sys_page_map>
               if(r<0)
  80167f:	85 c0                	test   %eax,%eax
  801681:	79 1c                	jns    80169f <fork+0x10d>
                 panic("map failed");
  801683:	c7 44 24 08 3c 2a 80 	movl   $0x802a3c,0x8(%esp)
  80168a:	00 
  80168b:	c7 44 24 04 49 00 00 	movl   $0x49,0x4(%esp)
  801692:	00 
  801693:	c7 04 24 21 2a 80 00 	movl   $0x802a21,(%esp)
  80169a:	e8 21 eb ff ff       	call   8001c0 <_panic>
               r = sys_page_map(0,(void*)addr,0,(void*)addr,PTE_P|PTE_U|PTE_COW);    //mark itself COW as well
  80169f:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  8016a6:	00 
  8016a7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8016aa:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8016ae:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8016b5:	00 
  8016b6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016ba:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016c1:	e8 9f fc ff ff       	call   801365 <sys_page_map>
               if(r<0)
  8016c6:	85 c0                	test   %eax,%eax
  8016c8:	79 5f                	jns    801729 <fork+0x197>
                 panic("map failed");
  8016ca:	c7 44 24 08 3c 2a 80 	movl   $0x802a3c,0x8(%esp)
  8016d1:	00 
  8016d2:	c7 44 24 04 4c 00 00 	movl   $0x4c,0x4(%esp)
  8016d9:	00 
  8016da:	c7 04 24 21 2a 80 00 	movl   $0x802a21,(%esp)
  8016e1:	e8 da ea ff ff       	call   8001c0 <_panic>
          }
          else{
               r = sys_page_map(0,(void*)addr,envid,(void*)addr,PTE_P|PTE_U);
  8016e6:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  8016ed:	00 
  8016ee:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8016f2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8016f5:	89 54 24 08          	mov    %edx,0x8(%esp)
  8016f9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016fd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801704:	e8 5c fc ff ff       	call   801365 <sys_page_map>
               if(r<0)
  801709:	85 c0                	test   %eax,%eax
  80170b:	79 1c                	jns    801729 <fork+0x197>
                 panic("map failed");
  80170d:	c7 44 24 08 3c 2a 80 	movl   $0x802a3c,0x8(%esp)
  801714:	00 
  801715:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  80171c:	00 
  80171d:	c7 04 24 21 2a 80 00 	movl   $0x802a21,(%esp)
  801724:	e8 97 ea ff ff       	call   8001c0 <_panic>
		panic("sys_exofork: %e", envid);
	if (envid == 0) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
        for(addr = 0; addr < USTACKTOP; addr += PGSIZE){
  801729:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80172f:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  801735:	0f 85 d1 fe ff ff    	jne    80160c <fork+0x7a>
           if((vpd[PDX(addr)] & PTE_P) && (vpt[PGNUM(addr)] & PTE_P) && (vpt[PGNUM(addr)] & PTE_U))
              duppage(envid,PGNUM(addr));
        }
        r = sys_page_alloc(envid, (void*)(UXSTACKTOP-PGSIZE),PTE_P|PTE_U|PTE_W);
  80173b:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801742:	00 
  801743:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80174a:	ee 
  80174b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80174e:	89 04 24             	mov    %eax,(%esp)
  801751:	e8 7d fc ff ff       	call   8013d3 <sys_page_alloc>
        if(r < 0)
  801756:	85 c0                	test   %eax,%eax
  801758:	79 1c                	jns    801776 <fork+0x1e4>
            panic("alloc failed");
  80175a:	c7 44 24 08 47 2a 80 	movl   $0x802a47,0x8(%esp)
  801761:	00 
  801762:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
  801769:	00 
  80176a:	c7 04 24 21 2a 80 00 	movl   $0x802a21,(%esp)
  801771:	e8 4a ea ff ff       	call   8001c0 <_panic>
        r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  801776:	c7 44 24 04 70 23 80 	movl   $0x802370,0x4(%esp)
  80177d:	00 
  80177e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801781:	89 14 24             	mov    %edx,(%esp)
  801784:	e8 2c fa ff ff       	call   8011b5 <sys_env_set_pgfault_upcall>
        if(r < 0)
  801789:	85 c0                	test   %eax,%eax
  80178b:	79 1c                	jns    8017a9 <fork+0x217>
            panic("set pgfault upcall failed");
  80178d:	c7 44 24 08 54 2a 80 	movl   $0x802a54,0x8(%esp)
  801794:	00 
  801795:	c7 44 24 04 82 00 00 	movl   $0x82,0x4(%esp)
  80179c:	00 
  80179d:	c7 04 24 21 2a 80 00 	movl   $0x802a21,(%esp)
  8017a4:	e8 17 ea ff ff       	call   8001c0 <_panic>
        r = sys_env_set_status(envid, ENV_RUNNABLE);
  8017a9:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8017b0:	00 
  8017b1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8017b4:	89 04 24             	mov    %eax,(%esp)
  8017b7:	e8 d1 fa ff ff       	call   80128d <sys_env_set_status>
        if(r < 0)
  8017bc:	85 c0                	test   %eax,%eax
  8017be:	79 1c                	jns    8017dc <fork+0x24a>
            panic("set status failed");
  8017c0:	c7 44 24 08 6e 2a 80 	movl   $0x802a6e,0x8(%esp)
  8017c7:	00 
  8017c8:	c7 44 24 04 85 00 00 	movl   $0x85,0x4(%esp)
  8017cf:	00 
  8017d0:	c7 04 24 21 2a 80 00 	movl   $0x802a21,(%esp)
  8017d7:	e8 e4 e9 ff ff       	call   8001c0 <_panic>
        return envid;
	//panic("fork not implemented");
}
  8017dc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8017df:	83 c4 3c             	add    $0x3c,%esp
  8017e2:	5b                   	pop    %ebx
  8017e3:	5e                   	pop    %esi
  8017e4:	5f                   	pop    %edi
  8017e5:	5d                   	pop    %ebp
  8017e6:	c3                   	ret    

008017e7 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  8017e7:	55                   	push   %ebp
  8017e8:	89 e5                	mov    %esp,%ebp
  8017ea:	53                   	push   %ebx
  8017eb:	83 ec 24             	sub    $0x24,%esp
  8017ee:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  8017f1:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at vpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        pte_t pte = vpt[PGNUM(addr)];
  8017f3:	89 da                	mov    %ebx,%edx
  8017f5:	c1 ea 0c             	shr    $0xc,%edx
  8017f8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
//
static void
pgfault(struct UTrapframe *utf)
{
	void *addr = (void *) utf->utf_fault_va;
	uint32_t err = utf->utf_err;
  8017ff:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  801803:	74 08                	je     80180d <pgfault+0x26>
	//   Use the read-only page table mappings at vpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        pte_t pte = vpt[PGNUM(addr)];
        if((!(err & FEC_WR)) ||(!(pte & (PTE_P | PTE_U |PTE_COW))))
  801805:	f7 c2 05 08 00 00    	test   $0x805,%edx
  80180b:	75 1c                	jne    801829 <pgfault+0x42>
           panic("pgfault error");
  80180d:	c7 44 24 08 80 2a 80 	movl   $0x802a80,0x8(%esp)
  801814:	00 
  801815:	c7 44 24 04 1e 00 00 	movl   $0x1e,0x4(%esp)
  80181c:	00 
  80181d:	c7 04 24 21 2a 80 00 	movl   $0x802a21,(%esp)
  801824:	e8 97 e9 ff ff       	call   8001c0 <_panic>
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 4: Your code here.
        if ((r = sys_page_alloc(0, (void*)PFTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801829:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801830:	00 
  801831:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801838:	00 
  801839:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801840:	e8 8e fb ff ff       	call   8013d3 <sys_page_alloc>
  801845:	85 c0                	test   %eax,%eax
  801847:	79 20                	jns    801869 <pgfault+0x82>
		panic("sys_page_alloc: %e", r);
  801849:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80184d:	c7 44 24 08 8e 2a 80 	movl   $0x802a8e,0x8(%esp)
  801854:	00 
  801855:	c7 44 24 04 29 00 00 	movl   $0x29,0x4(%esp)
  80185c:	00 
  80185d:	c7 04 24 21 2a 80 00 	movl   $0x802a21,(%esp)
  801864:	e8 57 e9 ff ff       	call   8001c0 <_panic>
        memmove(PFTEMP, (void*)((PGNUM(addr))<< PTXSHIFT), PGSIZE);
  801869:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  80186f:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  801876:	00 
  801877:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80187b:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  801882:	e8 0e f5 ff ff       	call   800d95 <memmove>
	if ((r = sys_page_map(0, (void*)PFTEMP, 0, (void*)((PGNUM(addr))<< PTXSHIFT), PTE_P|PTE_U|PTE_W)) < 0)
  801887:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  80188e:	00 
  80188f:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801893:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80189a:	00 
  80189b:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8018a2:	00 
  8018a3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018aa:	e8 b6 fa ff ff       	call   801365 <sys_page_map>
  8018af:	85 c0                	test   %eax,%eax
  8018b1:	79 20                	jns    8018d3 <pgfault+0xec>
		panic("sys_page_map: %e", r);	
  8018b3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8018b7:	c7 44 24 08 a1 2a 80 	movl   $0x802aa1,0x8(%esp)
  8018be:	00 
  8018bf:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  8018c6:	00 
  8018c7:	c7 04 24 21 2a 80 00 	movl   $0x802a21,(%esp)
  8018ce:	e8 ed e8 ff ff       	call   8001c0 <_panic>
        if ((r = sys_page_unmap(0, PFTEMP)) < 0)
  8018d3:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8018da:	00 
  8018db:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018e2:	e8 12 fa ff ff       	call   8012f9 <sys_page_unmap>
  8018e7:	85 c0                	test   %eax,%eax
  8018e9:	79 20                	jns    80190b <pgfault+0x124>
		panic("sys_page_unmap: %e", r);
  8018eb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8018ef:	c7 44 24 08 b2 2a 80 	movl   $0x802ab2,0x8(%esp)
  8018f6:	00 
  8018f7:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
  8018fe:	00 
  8018ff:	c7 04 24 21 2a 80 00 	movl   $0x802a21,(%esp)
  801906:	e8 b5 e8 ff ff       	call   8001c0 <_panic>
	//panic("pgfault not implemented");
}
  80190b:	83 c4 24             	add    $0x24,%esp
  80190e:	5b                   	pop    %ebx
  80190f:	5d                   	pop    %ebp
  801910:	c3                   	ret    
	...

00801920 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801920:	55                   	push   %ebp
  801921:	89 e5                	mov    %esp,%ebp
  801923:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801926:	8b 15 50 00 c0 ee    	mov    0xeec00050,%edx
  80192c:	b8 01 00 00 00       	mov    $0x1,%eax
  801931:	39 ca                	cmp    %ecx,%edx
  801933:	75 04                	jne    801939 <ipc_find_env+0x19>
  801935:	b0 00                	mov    $0x0,%al
  801937:	eb 12                	jmp    80194b <ipc_find_env+0x2b>
  801939:	89 c2                	mov    %eax,%edx
  80193b:	c1 e2 07             	shl    $0x7,%edx
  80193e:	8d 94 82 50 00 c0 ee 	lea    -0x113fffb0(%edx,%eax,4),%edx
  801945:	8b 12                	mov    (%edx),%edx
  801947:	39 ca                	cmp    %ecx,%edx
  801949:	75 10                	jne    80195b <ipc_find_env+0x3b>
			return envs[i].env_id;
  80194b:	89 c2                	mov    %eax,%edx
  80194d:	c1 e2 07             	shl    $0x7,%edx
  801950:	8d 84 82 48 00 c0 ee 	lea    -0x113fffb8(%edx,%eax,4),%eax
  801957:	8b 00                	mov    (%eax),%eax
  801959:	eb 0e                	jmp    801969 <ipc_find_env+0x49>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80195b:	83 c0 01             	add    $0x1,%eax
  80195e:	3d 00 04 00 00       	cmp    $0x400,%eax
  801963:	75 d4                	jne    801939 <ipc_find_env+0x19>
  801965:	66 b8 00 00          	mov    $0x0,%ax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  801969:	5d                   	pop    %ebp
  80196a:	c3                   	ret    

0080196b <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80196b:	55                   	push   %ebp
  80196c:	89 e5                	mov    %esp,%ebp
  80196e:	57                   	push   %edi
  80196f:	56                   	push   %esi
  801970:	53                   	push   %ebx
  801971:	83 ec 1c             	sub    $0x1c,%esp
  801974:	8b 75 08             	mov    0x8(%ebp),%esi
  801977:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80197a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        int ret;
        while(1){
           if(pg)
  80197d:	85 db                	test   %ebx,%ebx
  80197f:	74 19                	je     80199a <ipc_send+0x2f>
              ret = sys_ipc_try_send(to_env,val,pg,perm);
  801981:	8b 45 14             	mov    0x14(%ebp),%eax
  801984:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801988:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80198c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801990:	89 34 24             	mov    %esi,(%esp)
  801993:	e8 dc f7 ff ff       	call   801174 <sys_ipc_try_send>
  801998:	eb 1b                	jmp    8019b5 <ipc_send+0x4a>
           else
              ret = sys_ipc_try_send(to_env,val,(void*)UTOP,perm);
  80199a:	8b 45 14             	mov    0x14(%ebp),%eax
  80199d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8019a1:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  8019a8:	ee 
  8019a9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8019ad:	89 34 24             	mov    %esi,(%esp)
  8019b0:	e8 bf f7 ff ff       	call   801174 <sys_ipc_try_send>
           if(ret == 0)
  8019b5:	85 c0                	test   %eax,%eax
  8019b7:	74 28                	je     8019e1 <ipc_send+0x76>
              return;
           if(ret != -E_IPC_NOT_RECV)
  8019b9:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8019bc:	74 1c                	je     8019da <ipc_send+0x6f>
              panic("ipc send error");
  8019be:	c7 44 24 08 c5 2a 80 	movl   $0x802ac5,0x8(%esp)
  8019c5:	00 
  8019c6:	c7 44 24 04 46 00 00 	movl   $0x46,0x4(%esp)
  8019cd:	00 
  8019ce:	c7 04 24 d4 2a 80 00 	movl   $0x802ad4,(%esp)
  8019d5:	e8 e6 e7 ff ff       	call   8001c0 <_panic>
           sys_yield();
  8019da:	e8 61 fa ff ff       	call   801440 <sys_yield>
        }
  8019df:	eb 9c                	jmp    80197d <ipc_send+0x12>
	//panic("ipc_send not implemented");
}
  8019e1:	83 c4 1c             	add    $0x1c,%esp
  8019e4:	5b                   	pop    %ebx
  8019e5:	5e                   	pop    %esi
  8019e6:	5f                   	pop    %edi
  8019e7:	5d                   	pop    %ebp
  8019e8:	c3                   	ret    

008019e9 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8019e9:	55                   	push   %ebp
  8019ea:	89 e5                	mov    %esp,%ebp
  8019ec:	56                   	push   %esi
  8019ed:	53                   	push   %ebx
  8019ee:	83 ec 10             	sub    $0x10,%esp
  8019f1:	8b 75 08             	mov    0x8(%ebp),%esi
  8019f4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019f7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        int ret;
        if(!pg)
  8019fa:	85 c0                	test   %eax,%eax
  8019fc:	75 0e                	jne    801a0c <ipc_recv+0x23>
           ret = sys_ipc_recv((void*)UTOP);
  8019fe:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  801a05:	e8 ff f6 ff ff       	call   801109 <sys_ipc_recv>
  801a0a:	eb 08                	jmp    801a14 <ipc_recv+0x2b>
        else
           ret = sys_ipc_recv(pg);
  801a0c:	89 04 24             	mov    %eax,(%esp)
  801a0f:	e8 f5 f6 ff ff       	call   801109 <sys_ipc_recv>
        if(ret == 0){
  801a14:	85 c0                	test   %eax,%eax
  801a16:	75 26                	jne    801a3e <ipc_recv+0x55>
           if(from_env_store)
  801a18:	85 f6                	test   %esi,%esi
  801a1a:	74 0a                	je     801a26 <ipc_recv+0x3d>
              *from_env_store = thisenv->env_ipc_from;
  801a1c:	a1 04 40 80 00       	mov    0x804004,%eax
  801a21:	8b 40 78             	mov    0x78(%eax),%eax
  801a24:	89 06                	mov    %eax,(%esi)
           if(perm_store)
  801a26:	85 db                	test   %ebx,%ebx
  801a28:	74 0a                	je     801a34 <ipc_recv+0x4b>
              *perm_store = thisenv->env_ipc_perm;
  801a2a:	a1 04 40 80 00       	mov    0x804004,%eax
  801a2f:	8b 40 7c             	mov    0x7c(%eax),%eax
  801a32:	89 03                	mov    %eax,(%ebx)
           return thisenv->env_ipc_value;
  801a34:	a1 04 40 80 00       	mov    0x804004,%eax
  801a39:	8b 40 74             	mov    0x74(%eax),%eax
  801a3c:	eb 14                	jmp    801a52 <ipc_recv+0x69>
        }
        else{
           if(from_env_store)
  801a3e:	85 f6                	test   %esi,%esi
  801a40:	74 06                	je     801a48 <ipc_recv+0x5f>
              *from_env_store = 0;
  801a42:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
           if(perm_store)
  801a48:	85 db                	test   %ebx,%ebx
  801a4a:	74 06                	je     801a52 <ipc_recv+0x69>
              *perm_store = 0;
  801a4c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
           return ret;
        }
	//panic("ipc_recv not implemented");
	return 0;
}
  801a52:	83 c4 10             	add    $0x10,%esp
  801a55:	5b                   	pop    %ebx
  801a56:	5e                   	pop    %esi
  801a57:	5d                   	pop    %ebp
  801a58:	c3                   	ret    
  801a59:	00 00                	add    %al,(%eax)
  801a5b:	00 00                	add    %al,(%eax)
  801a5d:	00 00                	add    %al,(%eax)
	...

00801a60 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801a60:	55                   	push   %ebp
  801a61:	89 e5                	mov    %esp,%ebp
  801a63:	8b 45 08             	mov    0x8(%ebp),%eax
  801a66:	05 00 00 00 30       	add    $0x30000000,%eax
  801a6b:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  801a6e:	5d                   	pop    %ebp
  801a6f:	c3                   	ret    

00801a70 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801a70:	55                   	push   %ebp
  801a71:	89 e5                	mov    %esp,%ebp
  801a73:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801a76:	8b 45 08             	mov    0x8(%ebp),%eax
  801a79:	89 04 24             	mov    %eax,(%esp)
  801a7c:	e8 df ff ff ff       	call   801a60 <fd2num>
  801a81:	05 20 00 0d 00       	add    $0xd0020,%eax
  801a86:	c1 e0 0c             	shl    $0xc,%eax
}
  801a89:	c9                   	leave  
  801a8a:	c3                   	ret    

00801a8b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801a8b:	55                   	push   %ebp
  801a8c:	89 e5                	mov    %esp,%ebp
  801a8e:	57                   	push   %edi
  801a8f:	56                   	push   %esi
  801a90:	53                   	push   %ebx
  801a91:	8b 7d 08             	mov    0x8(%ebp),%edi
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  801a94:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  801a99:	a8 01                	test   $0x1,%al
  801a9b:	74 36                	je     801ad3 <fd_alloc+0x48>
  801a9d:	a1 00 00 74 ef       	mov    0xef740000,%eax
  801aa2:	a8 01                	test   $0x1,%al
  801aa4:	74 2d                	je     801ad3 <fd_alloc+0x48>
  801aa6:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  801aab:	b9 00 d0 7b ef       	mov    $0xef7bd000,%ecx
  801ab0:	be 00 00 40 ef       	mov    $0xef400000,%esi
  801ab5:	89 c3                	mov    %eax,%ebx
  801ab7:	89 c2                	mov    %eax,%edx
  801ab9:	c1 ea 16             	shr    $0x16,%edx
  801abc:	8b 14 91             	mov    (%ecx,%edx,4),%edx
  801abf:	f6 c2 01             	test   $0x1,%dl
  801ac2:	74 14                	je     801ad8 <fd_alloc+0x4d>
  801ac4:	89 c2                	mov    %eax,%edx
  801ac6:	c1 ea 0c             	shr    $0xc,%edx
  801ac9:	8b 14 96             	mov    (%esi,%edx,4),%edx
  801acc:	f6 c2 01             	test   $0x1,%dl
  801acf:	75 10                	jne    801ae1 <fd_alloc+0x56>
  801ad1:	eb 05                	jmp    801ad8 <fd_alloc+0x4d>
  801ad3:	bb 00 00 00 d0       	mov    $0xd0000000,%ebx
			*fd_store = fd;
  801ad8:	89 1f                	mov    %ebx,(%edi)
  801ada:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  801adf:	eb 17                	jmp    801af8 <fd_alloc+0x6d>
  801ae1:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801ae6:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801aeb:	75 c8                	jne    801ab5 <fd_alloc+0x2a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801aed:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  801af3:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  801af8:	5b                   	pop    %ebx
  801af9:	5e                   	pop    %esi
  801afa:	5f                   	pop    %edi
  801afb:	5d                   	pop    %ebp
  801afc:	c3                   	ret    

00801afd <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801afd:	55                   	push   %ebp
  801afe:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801b00:	8b 45 08             	mov    0x8(%ebp),%eax
  801b03:	83 f8 1f             	cmp    $0x1f,%eax
  801b06:	77 36                	ja     801b3e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801b08:	05 00 00 0d 00       	add    $0xd0000,%eax
  801b0d:	c1 e0 0c             	shl    $0xc,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
  801b10:	89 c2                	mov    %eax,%edx
  801b12:	c1 ea 16             	shr    $0x16,%edx
  801b15:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801b1c:	f6 c2 01             	test   $0x1,%dl
  801b1f:	74 1d                	je     801b3e <fd_lookup+0x41>
  801b21:	89 c2                	mov    %eax,%edx
  801b23:	c1 ea 0c             	shr    $0xc,%edx
  801b26:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801b2d:	f6 c2 01             	test   $0x1,%dl
  801b30:	74 0c                	je     801b3e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  801b32:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b35:	89 02                	mov    %eax,(%edx)
  801b37:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
  801b3c:	eb 05                	jmp    801b43 <fd_lookup+0x46>
  801b3e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801b43:	5d                   	pop    %ebp
  801b44:	c3                   	ret    

00801b45 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  801b45:	55                   	push   %ebp
  801b46:	89 e5                	mov    %esp,%ebp
  801b48:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b4b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801b4e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b52:	8b 45 08             	mov    0x8(%ebp),%eax
  801b55:	89 04 24             	mov    %eax,(%esp)
  801b58:	e8 a0 ff ff ff       	call   801afd <fd_lookup>
  801b5d:	85 c0                	test   %eax,%eax
  801b5f:	78 0e                	js     801b6f <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801b61:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801b64:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b67:	89 50 04             	mov    %edx,0x4(%eax)
  801b6a:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  801b6f:	c9                   	leave  
  801b70:	c3                   	ret    

00801b71 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801b71:	55                   	push   %ebp
  801b72:	89 e5                	mov    %esp,%ebp
  801b74:	56                   	push   %esi
  801b75:	53                   	push   %ebx
  801b76:	83 ec 10             	sub    $0x10,%esp
  801b79:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b7c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
// File functions
// --------------------------------------------------------------

static struct Dev *devtab[] =
{
	&devfile,
  801b7f:	b8 04 30 80 00       	mov    $0x803004,%eax
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  801b84:	ba 00 00 00 00       	mov    $0x0,%edx

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801b89:	be 60 2b 80 00       	mov    $0x802b60,%esi
		if (devtab[i]->dev_id == dev_id) {
  801b8e:	39 08                	cmp    %ecx,(%eax)
  801b90:	75 10                	jne    801ba2 <dev_lookup+0x31>
  801b92:	eb 04                	jmp    801b98 <dev_lookup+0x27>
  801b94:	39 08                	cmp    %ecx,(%eax)
  801b96:	75 0a                	jne    801ba2 <dev_lookup+0x31>
			*dev = devtab[i];
  801b98:	89 03                	mov    %eax,(%ebx)
  801b9a:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  801b9f:	90                   	nop
  801ba0:	eb 31                	jmp    801bd3 <dev_lookup+0x62>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801ba2:	83 c2 01             	add    $0x1,%edx
  801ba5:	8b 04 96             	mov    (%esi,%edx,4),%eax
  801ba8:	85 c0                	test   %eax,%eax
  801baa:	75 e8                	jne    801b94 <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801bac:	a1 04 40 80 00       	mov    0x804004,%eax
  801bb1:	8b 40 48             	mov    0x48(%eax),%eax
  801bb4:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801bb8:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bbc:	c7 04 24 e0 2a 80 00 	movl   $0x802ae0,(%esp)
  801bc3:	e8 b1 e6 ff ff       	call   800279 <cprintf>
	*dev = 0;
  801bc8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801bce:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  801bd3:	83 c4 10             	add    $0x10,%esp
  801bd6:	5b                   	pop    %ebx
  801bd7:	5e                   	pop    %esi
  801bd8:	5d                   	pop    %ebp
  801bd9:	c3                   	ret    

00801bda <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  801bda:	55                   	push   %ebp
  801bdb:	89 e5                	mov    %esp,%ebp
  801bdd:	53                   	push   %ebx
  801bde:	83 ec 24             	sub    $0x24,%esp
  801be1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801be4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801be7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801beb:	8b 45 08             	mov    0x8(%ebp),%eax
  801bee:	89 04 24             	mov    %eax,(%esp)
  801bf1:	e8 07 ff ff ff       	call   801afd <fd_lookup>
  801bf6:	85 c0                	test   %eax,%eax
  801bf8:	78 53                	js     801c4d <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801bfa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bfd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c01:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c04:	8b 00                	mov    (%eax),%eax
  801c06:	89 04 24             	mov    %eax,(%esp)
  801c09:	e8 63 ff ff ff       	call   801b71 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801c0e:	85 c0                	test   %eax,%eax
  801c10:	78 3b                	js     801c4d <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  801c12:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801c17:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c1a:	83 7a 14 00          	cmpl   $0x0,0x14(%edx)
  801c1e:	74 2d                	je     801c4d <fstat+0x73>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801c20:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801c23:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801c2a:	00 00 00 
	stat->st_isdir = 0;
  801c2d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801c34:	00 00 00 
	stat->st_dev = dev;
  801c37:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c3a:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801c40:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c44:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801c47:	89 14 24             	mov    %edx,(%esp)
  801c4a:	ff 50 14             	call   *0x14(%eax)
}
  801c4d:	83 c4 24             	add    $0x24,%esp
  801c50:	5b                   	pop    %ebx
  801c51:	5d                   	pop    %ebp
  801c52:	c3                   	ret    

00801c53 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  801c53:	55                   	push   %ebp
  801c54:	89 e5                	mov    %esp,%ebp
  801c56:	53                   	push   %ebx
  801c57:	83 ec 24             	sub    $0x24,%esp
  801c5a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801c5d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c60:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c64:	89 1c 24             	mov    %ebx,(%esp)
  801c67:	e8 91 fe ff ff       	call   801afd <fd_lookup>
  801c6c:	85 c0                	test   %eax,%eax
  801c6e:	78 5f                	js     801ccf <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801c70:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c73:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c77:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c7a:	8b 00                	mov    (%eax),%eax
  801c7c:	89 04 24             	mov    %eax,(%esp)
  801c7f:	e8 ed fe ff ff       	call   801b71 <dev_lookup>
ftruncate(int fdnum, off_t newsize)
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801c84:	85 c0                	test   %eax,%eax
  801c86:	78 47                	js     801ccf <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801c88:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801c8b:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  801c8f:	75 23                	jne    801cb4 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801c91:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801c96:	8b 40 48             	mov    0x48(%eax),%eax
  801c99:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801c9d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ca1:	c7 04 24 00 2b 80 00 	movl   $0x802b00,(%esp)
  801ca8:	e8 cc e5 ff ff       	call   800279 <cprintf>
  801cad:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801cb2:	eb 1b                	jmp    801ccf <ftruncate+0x7c>
	}
	if (!dev->dev_trunc)
  801cb4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cb7:	8b 48 18             	mov    0x18(%eax),%ecx
  801cba:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801cbf:	85 c9                	test   %ecx,%ecx
  801cc1:	74 0c                	je     801ccf <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801cc3:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cc6:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cca:	89 14 24             	mov    %edx,(%esp)
  801ccd:	ff d1                	call   *%ecx
}
  801ccf:	83 c4 24             	add    $0x24,%esp
  801cd2:	5b                   	pop    %ebx
  801cd3:	5d                   	pop    %ebp
  801cd4:	c3                   	ret    

00801cd5 <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801cd5:	55                   	push   %ebp
  801cd6:	89 e5                	mov    %esp,%ebp
  801cd8:	53                   	push   %ebx
  801cd9:	83 ec 24             	sub    $0x24,%esp
  801cdc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801cdf:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801ce2:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ce6:	89 1c 24             	mov    %ebx,(%esp)
  801ce9:	e8 0f fe ff ff       	call   801afd <fd_lookup>
  801cee:	85 c0                	test   %eax,%eax
  801cf0:	78 66                	js     801d58 <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801cf2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cf5:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cf9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cfc:	8b 00                	mov    (%eax),%eax
  801cfe:	89 04 24             	mov    %eax,(%esp)
  801d01:	e8 6b fe ff ff       	call   801b71 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801d06:	85 c0                	test   %eax,%eax
  801d08:	78 4e                	js     801d58 <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801d0a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801d0d:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  801d11:	75 23                	jne    801d36 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801d13:	a1 04 40 80 00       	mov    0x804004,%eax
  801d18:	8b 40 48             	mov    0x48(%eax),%eax
  801d1b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801d1f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d23:	c7 04 24 24 2b 80 00 	movl   $0x802b24,(%esp)
  801d2a:	e8 4a e5 ff ff       	call   800279 <cprintf>
  801d2f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801d34:	eb 22                	jmp    801d58 <write+0x83>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801d36:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d39:	8b 48 0c             	mov    0xc(%eax),%ecx
  801d3c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801d41:	85 c9                	test   %ecx,%ecx
  801d43:	74 13                	je     801d58 <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801d45:	8b 45 10             	mov    0x10(%ebp),%eax
  801d48:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d4c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d4f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d53:	89 14 24             	mov    %edx,(%esp)
  801d56:	ff d1                	call   *%ecx
}
  801d58:	83 c4 24             	add    $0x24,%esp
  801d5b:	5b                   	pop    %ebx
  801d5c:	5d                   	pop    %ebp
  801d5d:	c3                   	ret    

00801d5e <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801d5e:	55                   	push   %ebp
  801d5f:	89 e5                	mov    %esp,%ebp
  801d61:	53                   	push   %ebx
  801d62:	83 ec 24             	sub    $0x24,%esp
  801d65:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801d68:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d6b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d6f:	89 1c 24             	mov    %ebx,(%esp)
  801d72:	e8 86 fd ff ff       	call   801afd <fd_lookup>
  801d77:	85 c0                	test   %eax,%eax
  801d79:	78 6b                	js     801de6 <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801d7b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d7e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d82:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d85:	8b 00                	mov    (%eax),%eax
  801d87:	89 04 24             	mov    %eax,(%esp)
  801d8a:	e8 e2 fd ff ff       	call   801b71 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801d8f:	85 c0                	test   %eax,%eax
  801d91:	78 53                	js     801de6 <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801d93:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801d96:	8b 42 08             	mov    0x8(%edx),%eax
  801d99:	83 e0 03             	and    $0x3,%eax
  801d9c:	83 f8 01             	cmp    $0x1,%eax
  801d9f:	75 23                	jne    801dc4 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801da1:	a1 04 40 80 00       	mov    0x804004,%eax
  801da6:	8b 40 48             	mov    0x48(%eax),%eax
  801da9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801dad:	89 44 24 04          	mov    %eax,0x4(%esp)
  801db1:	c7 04 24 41 2b 80 00 	movl   $0x802b41,(%esp)
  801db8:	e8 bc e4 ff ff       	call   800279 <cprintf>
  801dbd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801dc2:	eb 22                	jmp    801de6 <read+0x88>
	}
	if (!dev->dev_read)
  801dc4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dc7:	8b 48 08             	mov    0x8(%eax),%ecx
  801dca:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801dcf:	85 c9                	test   %ecx,%ecx
  801dd1:	74 13                	je     801de6 <read+0x88>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801dd3:	8b 45 10             	mov    0x10(%ebp),%eax
  801dd6:	89 44 24 08          	mov    %eax,0x8(%esp)
  801dda:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ddd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801de1:	89 14 24             	mov    %edx,(%esp)
  801de4:	ff d1                	call   *%ecx
}
  801de6:	83 c4 24             	add    $0x24,%esp
  801de9:	5b                   	pop    %ebx
  801dea:	5d                   	pop    %ebp
  801deb:	c3                   	ret    

00801dec <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801dec:	55                   	push   %ebp
  801ded:	89 e5                	mov    %esp,%ebp
  801def:	57                   	push   %edi
  801df0:	56                   	push   %esi
  801df1:	53                   	push   %ebx
  801df2:	83 ec 1c             	sub    $0x1c,%esp
  801df5:	8b 7d 08             	mov    0x8(%ebp),%edi
  801df8:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801dfb:	ba 00 00 00 00       	mov    $0x0,%edx
  801e00:	bb 00 00 00 00       	mov    $0x0,%ebx
  801e05:	b8 00 00 00 00       	mov    $0x0,%eax
  801e0a:	85 f6                	test   %esi,%esi
  801e0c:	74 29                	je     801e37 <readn+0x4b>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801e0e:	89 f0                	mov    %esi,%eax
  801e10:	29 d0                	sub    %edx,%eax
  801e12:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e16:	03 55 0c             	add    0xc(%ebp),%edx
  801e19:	89 54 24 04          	mov    %edx,0x4(%esp)
  801e1d:	89 3c 24             	mov    %edi,(%esp)
  801e20:	e8 39 ff ff ff       	call   801d5e <read>
		if (m < 0)
  801e25:	85 c0                	test   %eax,%eax
  801e27:	78 0e                	js     801e37 <readn+0x4b>
			return m;
		if (m == 0)
  801e29:	85 c0                	test   %eax,%eax
  801e2b:	74 08                	je     801e35 <readn+0x49>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801e2d:	01 c3                	add    %eax,%ebx
  801e2f:	89 da                	mov    %ebx,%edx
  801e31:	39 f3                	cmp    %esi,%ebx
  801e33:	72 d9                	jb     801e0e <readn+0x22>
  801e35:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801e37:	83 c4 1c             	add    $0x1c,%esp
  801e3a:	5b                   	pop    %ebx
  801e3b:	5e                   	pop    %esi
  801e3c:	5f                   	pop    %edi
  801e3d:	5d                   	pop    %ebp
  801e3e:	c3                   	ret    

00801e3f <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801e3f:	55                   	push   %ebp
  801e40:	89 e5                	mov    %esp,%ebp
  801e42:	56                   	push   %esi
  801e43:	53                   	push   %ebx
  801e44:	83 ec 20             	sub    $0x20,%esp
  801e47:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801e4a:	89 34 24             	mov    %esi,(%esp)
  801e4d:	e8 0e fc ff ff       	call   801a60 <fd2num>
  801e52:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801e55:	89 54 24 04          	mov    %edx,0x4(%esp)
  801e59:	89 04 24             	mov    %eax,(%esp)
  801e5c:	e8 9c fc ff ff       	call   801afd <fd_lookup>
  801e61:	89 c3                	mov    %eax,%ebx
  801e63:	85 c0                	test   %eax,%eax
  801e65:	78 05                	js     801e6c <fd_close+0x2d>
  801e67:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801e6a:	74 0c                	je     801e78 <fd_close+0x39>
	    || fd != fd2)
		return (must_exist ? r : 0);
  801e6c:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  801e70:	19 c0                	sbb    %eax,%eax
  801e72:	f7 d0                	not    %eax
  801e74:	21 c3                	and    %eax,%ebx
  801e76:	eb 3d                	jmp    801eb5 <fd_close+0x76>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801e78:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801e7b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e7f:	8b 06                	mov    (%esi),%eax
  801e81:	89 04 24             	mov    %eax,(%esp)
  801e84:	e8 e8 fc ff ff       	call   801b71 <dev_lookup>
  801e89:	89 c3                	mov    %eax,%ebx
  801e8b:	85 c0                	test   %eax,%eax
  801e8d:	78 16                	js     801ea5 <fd_close+0x66>
		if (dev->dev_close)
  801e8f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e92:	8b 40 10             	mov    0x10(%eax),%eax
  801e95:	bb 00 00 00 00       	mov    $0x0,%ebx
  801e9a:	85 c0                	test   %eax,%eax
  801e9c:	74 07                	je     801ea5 <fd_close+0x66>
			r = (*dev->dev_close)(fd);
  801e9e:	89 34 24             	mov    %esi,(%esp)
  801ea1:	ff d0                	call   *%eax
  801ea3:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801ea5:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ea9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801eb0:	e8 44 f4 ff ff       	call   8012f9 <sys_page_unmap>
	return r;
}
  801eb5:	89 d8                	mov    %ebx,%eax
  801eb7:	83 c4 20             	add    $0x20,%esp
  801eba:	5b                   	pop    %ebx
  801ebb:	5e                   	pop    %esi
  801ebc:	5d                   	pop    %ebp
  801ebd:	c3                   	ret    

00801ebe <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801ebe:	55                   	push   %ebp
  801ebf:	89 e5                	mov    %esp,%ebp
  801ec1:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ec4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ec7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ecb:	8b 45 08             	mov    0x8(%ebp),%eax
  801ece:	89 04 24             	mov    %eax,(%esp)
  801ed1:	e8 27 fc ff ff       	call   801afd <fd_lookup>
  801ed6:	85 c0                	test   %eax,%eax
  801ed8:	78 13                	js     801eed <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801eda:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801ee1:	00 
  801ee2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ee5:	89 04 24             	mov    %eax,(%esp)
  801ee8:	e8 52 ff ff ff       	call   801e3f <fd_close>
}
  801eed:	c9                   	leave  
  801eee:	c3                   	ret    

00801eef <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  801eef:	55                   	push   %ebp
  801ef0:	89 e5                	mov    %esp,%ebp
  801ef2:	83 ec 18             	sub    $0x18,%esp
  801ef5:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801ef8:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801efb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801f02:	00 
  801f03:	8b 45 08             	mov    0x8(%ebp),%eax
  801f06:	89 04 24             	mov    %eax,(%esp)
  801f09:	e8 79 03 00 00       	call   802287 <open>
  801f0e:	89 c3                	mov    %eax,%ebx
  801f10:	85 c0                	test   %eax,%eax
  801f12:	78 1b                	js     801f2f <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  801f14:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f17:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f1b:	89 1c 24             	mov    %ebx,(%esp)
  801f1e:	e8 b7 fc ff ff       	call   801bda <fstat>
  801f23:	89 c6                	mov    %eax,%esi
	close(fd);
  801f25:	89 1c 24             	mov    %ebx,(%esp)
  801f28:	e8 91 ff ff ff       	call   801ebe <close>
  801f2d:	89 f3                	mov    %esi,%ebx
	return r;
}
  801f2f:	89 d8                	mov    %ebx,%eax
  801f31:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801f34:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801f37:	89 ec                	mov    %ebp,%esp
  801f39:	5d                   	pop    %ebp
  801f3a:	c3                   	ret    

00801f3b <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  801f3b:	55                   	push   %ebp
  801f3c:	89 e5                	mov    %esp,%ebp
  801f3e:	53                   	push   %ebx
  801f3f:	83 ec 14             	sub    $0x14,%esp
  801f42:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  801f47:	89 1c 24             	mov    %ebx,(%esp)
  801f4a:	e8 6f ff ff ff       	call   801ebe <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801f4f:	83 c3 01             	add    $0x1,%ebx
  801f52:	83 fb 20             	cmp    $0x20,%ebx
  801f55:	75 f0                	jne    801f47 <close_all+0xc>
		close(i);
}
  801f57:	83 c4 14             	add    $0x14,%esp
  801f5a:	5b                   	pop    %ebx
  801f5b:	5d                   	pop    %ebp
  801f5c:	c3                   	ret    

00801f5d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801f5d:	55                   	push   %ebp
  801f5e:	89 e5                	mov    %esp,%ebp
  801f60:	83 ec 58             	sub    $0x58,%esp
  801f63:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801f66:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801f69:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801f6c:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801f6f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801f72:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f76:	8b 45 08             	mov    0x8(%ebp),%eax
  801f79:	89 04 24             	mov    %eax,(%esp)
  801f7c:	e8 7c fb ff ff       	call   801afd <fd_lookup>
  801f81:	89 c3                	mov    %eax,%ebx
  801f83:	85 c0                	test   %eax,%eax
  801f85:	0f 88 e0 00 00 00    	js     80206b <dup+0x10e>
		return r;
	close(newfdnum);
  801f8b:	89 3c 24             	mov    %edi,(%esp)
  801f8e:	e8 2b ff ff ff       	call   801ebe <close>

	newfd = INDEX2FD(newfdnum);
  801f93:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801f99:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801f9c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f9f:	89 04 24             	mov    %eax,(%esp)
  801fa2:	e8 c9 fa ff ff       	call   801a70 <fd2data>
  801fa7:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801fa9:	89 34 24             	mov    %esi,(%esp)
  801fac:	e8 bf fa ff ff       	call   801a70 <fd2data>
  801fb1:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
  801fb4:	89 da                	mov    %ebx,%edx
  801fb6:	89 d8                	mov    %ebx,%eax
  801fb8:	c1 e8 16             	shr    $0x16,%eax
  801fbb:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801fc2:	a8 01                	test   $0x1,%al
  801fc4:	74 43                	je     802009 <dup+0xac>
  801fc6:	c1 ea 0c             	shr    $0xc,%edx
  801fc9:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801fd0:	a8 01                	test   $0x1,%al
  801fd2:	74 35                	je     802009 <dup+0xac>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801fd4:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801fdb:	25 07 0e 00 00       	and    $0xe07,%eax
  801fe0:	89 44 24 10          	mov    %eax,0x10(%esp)
  801fe4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801fe7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801feb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801ff2:	00 
  801ff3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801ff7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ffe:	e8 62 f3 ff ff       	call   801365 <sys_page_map>
  802003:	89 c3                	mov    %eax,%ebx
  802005:	85 c0                	test   %eax,%eax
  802007:	78 3f                	js     802048 <dup+0xeb>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  802009:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80200c:	89 c2                	mov    %eax,%edx
  80200e:	c1 ea 0c             	shr    $0xc,%edx
  802011:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  802018:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  80201e:	89 54 24 10          	mov    %edx,0x10(%esp)
  802022:	89 74 24 0c          	mov    %esi,0xc(%esp)
  802026:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80202d:	00 
  80202e:	89 44 24 04          	mov    %eax,0x4(%esp)
  802032:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802039:	e8 27 f3 ff ff       	call   801365 <sys_page_map>
  80203e:	89 c3                	mov    %eax,%ebx
  802040:	85 c0                	test   %eax,%eax
  802042:	78 04                	js     802048 <dup+0xeb>
  802044:	89 fb                	mov    %edi,%ebx
  802046:	eb 23                	jmp    80206b <dup+0x10e>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  802048:	89 74 24 04          	mov    %esi,0x4(%esp)
  80204c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802053:	e8 a1 f2 ff ff       	call   8012f9 <sys_page_unmap>
	sys_page_unmap(0, nva);
  802058:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80205b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80205f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802066:	e8 8e f2 ff ff       	call   8012f9 <sys_page_unmap>
	return r;
}
  80206b:	89 d8                	mov    %ebx,%eax
  80206d:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  802070:	8b 75 f8             	mov    -0x8(%ebp),%esi
  802073:	8b 7d fc             	mov    -0x4(%ebp),%edi
  802076:	89 ec                	mov    %ebp,%esp
  802078:	5d                   	pop    %ebp
  802079:	c3                   	ret    
	...

0080207c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80207c:	55                   	push   %ebp
  80207d:	89 e5                	mov    %esp,%ebp
  80207f:	83 ec 18             	sub    $0x18,%esp
  802082:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  802085:	89 75 fc             	mov    %esi,-0x4(%ebp)
  802088:	89 c3                	mov    %eax,%ebx
  80208a:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  80208c:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  802093:	75 11                	jne    8020a6 <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  802095:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  80209c:	e8 7f f8 ff ff       	call   801920 <ipc_find_env>
  8020a1:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8020a6:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8020ad:	00 
  8020ae:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  8020b5:	00 
  8020b6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8020ba:	a1 00 40 80 00       	mov    0x804000,%eax
  8020bf:	89 04 24             	mov    %eax,(%esp)
  8020c2:	e8 a4 f8 ff ff       	call   80196b <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8020c7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8020ce:	00 
  8020cf:	89 74 24 04          	mov    %esi,0x4(%esp)
  8020d3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020da:	e8 0a f9 ff ff       	call   8019e9 <ipc_recv>
}
  8020df:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8020e2:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8020e5:	89 ec                	mov    %ebp,%esp
  8020e7:	5d                   	pop    %ebp
  8020e8:	c3                   	ret    

008020e9 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8020e9:	55                   	push   %ebp
  8020ea:	89 e5                	mov    %esp,%ebp
  8020ec:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8020ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8020f2:	8b 40 0c             	mov    0xc(%eax),%eax
  8020f5:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8020fa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020fd:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  802102:	ba 00 00 00 00       	mov    $0x0,%edx
  802107:	b8 02 00 00 00       	mov    $0x2,%eax
  80210c:	e8 6b ff ff ff       	call   80207c <fsipc>
}
  802111:	c9                   	leave  
  802112:	c3                   	ret    

00802113 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  802113:	55                   	push   %ebp
  802114:	89 e5                	mov    %esp,%ebp
  802116:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  802119:	8b 45 08             	mov    0x8(%ebp),%eax
  80211c:	8b 40 0c             	mov    0xc(%eax),%eax
  80211f:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  802124:	ba 00 00 00 00       	mov    $0x0,%edx
  802129:	b8 06 00 00 00       	mov    $0x6,%eax
  80212e:	e8 49 ff ff ff       	call   80207c <fsipc>
}
  802133:	c9                   	leave  
  802134:	c3                   	ret    

00802135 <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  802135:	55                   	push   %ebp
  802136:	89 e5                	mov    %esp,%ebp
  802138:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80213b:	ba 00 00 00 00       	mov    $0x0,%edx
  802140:	b8 08 00 00 00       	mov    $0x8,%eax
  802145:	e8 32 ff ff ff       	call   80207c <fsipc>
}
  80214a:	c9                   	leave  
  80214b:	c3                   	ret    

0080214c <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80214c:	55                   	push   %ebp
  80214d:	89 e5                	mov    %esp,%ebp
  80214f:	53                   	push   %ebx
  802150:	83 ec 14             	sub    $0x14,%esp
  802153:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  802156:	8b 45 08             	mov    0x8(%ebp),%eax
  802159:	8b 40 0c             	mov    0xc(%eax),%eax
  80215c:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  802161:	ba 00 00 00 00       	mov    $0x0,%edx
  802166:	b8 05 00 00 00       	mov    $0x5,%eax
  80216b:	e8 0c ff ff ff       	call   80207c <fsipc>
  802170:	85 c0                	test   %eax,%eax
  802172:	78 2b                	js     80219f <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  802174:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  80217b:	00 
  80217c:	89 1c 24             	mov    %ebx,(%esp)
  80217f:	e8 26 ea ff ff       	call   800baa <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  802184:	a1 80 50 80 00       	mov    0x805080,%eax
  802189:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80218f:	a1 84 50 80 00       	mov    0x805084,%eax
  802194:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  80219a:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  80219f:	83 c4 14             	add    $0x14,%esp
  8021a2:	5b                   	pop    %ebx
  8021a3:	5d                   	pop    %ebp
  8021a4:	c3                   	ret    

008021a5 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8021a5:	55                   	push   %ebp
  8021a6:	89 e5                	mov    %esp,%ebp
  8021a8:	83 ec 18             	sub    $0x18,%esp
  8021ab:	8b 45 10             	mov    0x10(%ebp),%eax
  8021ae:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8021b3:	76 05                	jbe    8021ba <devfile_write+0x15>
  8021b5:	b8 f8 0f 00 00       	mov    $0xff8,%eax
	// bytes than requested.
	// LAB 5: Your code here
        int r;
        if(n > sizeof(fsipcbuf.write.req_buf))
            n = sizeof(fsipcbuf.write.req_buf);
        fsipcbuf.write.req_fileid = fd->fd_file.id;
  8021ba:	8b 55 08             	mov    0x8(%ebp),%edx
  8021bd:	8b 52 0c             	mov    0xc(%edx),%edx
  8021c0:	89 15 00 50 80 00    	mov    %edx,0x805000
        fsipcbuf.write.req_n = n;
  8021c6:	a3 04 50 80 00       	mov    %eax,0x805004
        memmove(fsipcbuf.write.req_buf,buf,n);  
  8021cb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8021cf:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021d2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021d6:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  8021dd:	e8 b3 eb ff ff       	call   800d95 <memmove>
        r = fsipc(FSREQ_WRITE,NULL);
  8021e2:	ba 00 00 00 00       	mov    $0x0,%edx
  8021e7:	b8 04 00 00 00       	mov    $0x4,%eax
  8021ec:	e8 8b fe ff ff       	call   80207c <fsipc>
        return r;
	//panic("devfile_write not implemented");
}
  8021f1:	c9                   	leave  
  8021f2:	c3                   	ret    

008021f3 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8021f3:	55                   	push   %ebp
  8021f4:	89 e5                	mov    %esp,%ebp
  8021f6:	53                   	push   %ebx
  8021f7:	83 ec 14             	sub    $0x14,%esp
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
        int r;
        fsipcbuf.read.req_fileid = fd->fd_file.id;
  8021fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8021fd:	8b 40 0c             	mov    0xc(%eax),%eax
  802200:	a3 00 50 80 00       	mov    %eax,0x805000
        fsipcbuf.read.req_n = n;
  802205:	8b 45 10             	mov    0x10(%ebp),%eax
  802208:	a3 04 50 80 00       	mov    %eax,0x805004
        r = fsipc(FSREQ_READ,NULL);
  80220d:	ba 00 00 00 00       	mov    $0x0,%edx
  802212:	b8 03 00 00 00       	mov    $0x3,%eax
  802217:	e8 60 fe ff ff       	call   80207c <fsipc>
  80221c:	89 c3                	mov    %eax,%ebx
        if(r < 0)
  80221e:	85 c0                	test   %eax,%eax
  802220:	78 17                	js     802239 <devfile_read+0x46>
           return r;
        memmove(buf,fsipcbuf.readRet.ret_buf,r);
  802222:	89 44 24 08          	mov    %eax,0x8(%esp)
  802226:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  80222d:	00 
  80222e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802231:	89 04 24             	mov    %eax,(%esp)
  802234:	e8 5c eb ff ff       	call   800d95 <memmove>
        return r;
	//panic("devfile_read not implemented");
}
  802239:	89 d8                	mov    %ebx,%eax
  80223b:	83 c4 14             	add    $0x14,%esp
  80223e:	5b                   	pop    %ebx
  80223f:	5d                   	pop    %ebp
  802240:	c3                   	ret    

00802241 <remove>:
}

// Delete a file
int
remove(const char *path)
{
  802241:	55                   	push   %ebp
  802242:	89 e5                	mov    %esp,%ebp
  802244:	53                   	push   %ebx
  802245:	83 ec 14             	sub    $0x14,%esp
  802248:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  80224b:	89 1c 24             	mov    %ebx,(%esp)
  80224e:	e8 0d e9 ff ff       	call   800b60 <strlen>
  802253:	89 c2                	mov    %eax,%edx
  802255:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  80225a:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
  802260:	7f 1f                	jg     802281 <remove+0x40>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  802262:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802266:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  80226d:	e8 38 e9 ff ff       	call   800baa <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  802272:	ba 00 00 00 00       	mov    $0x0,%edx
  802277:	b8 07 00 00 00       	mov    $0x7,%eax
  80227c:	e8 fb fd ff ff       	call   80207c <fsipc>
}
  802281:	83 c4 14             	add    $0x14,%esp
  802284:	5b                   	pop    %ebx
  802285:	5d                   	pop    %ebp
  802286:	c3                   	ret    

00802287 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  802287:	55                   	push   %ebp
  802288:	89 e5                	mov    %esp,%ebp
  80228a:	83 ec 28             	sub    $0x28,%esp
  80228d:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  802290:	89 75 fc             	mov    %esi,-0x4(%ebp)
  802293:	8b 75 08             	mov    0x8(%ebp),%esi
	// If any step after fd_alloc fails, use fd_close to free the
	// file descriptor.

	// LAB 5: Your code here.
        struct Fd* fd;
        if(strlen(path) > MAXPATHLEN)
  802296:	89 34 24             	mov    %esi,(%esp)
  802299:	e8 c2 e8 ff ff       	call   800b60 <strlen>
  80229e:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  8022a3:	3d 00 04 00 00       	cmp    $0x400,%eax
  8022a8:	7f 6d                	jg     802317 <open+0x90>
            return -E_BAD_PATH;
        int r;
        r = fd_alloc(&fd);
  8022aa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022ad:	89 04 24             	mov    %eax,(%esp)
  8022b0:	e8 d6 f7 ff ff       	call   801a8b <fd_alloc>
  8022b5:	89 c3                	mov    %eax,%ebx
        if(r < 0)
  8022b7:	85 c0                	test   %eax,%eax
  8022b9:	78 5c                	js     802317 <open+0x90>
           return r;
        fsipcbuf.open.req_omode = mode;
  8022bb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022be:	a3 00 54 80 00       	mov    %eax,0x805400
        memmove(fsipcbuf.open.req_path,path,strlen(path)+1);
  8022c3:	89 34 24             	mov    %esi,(%esp)
  8022c6:	e8 95 e8 ff ff       	call   800b60 <strlen>
  8022cb:	83 c0 01             	add    $0x1,%eax
  8022ce:	89 44 24 08          	mov    %eax,0x8(%esp)
  8022d2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8022d6:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  8022dd:	e8 b3 ea ff ff       	call   800d95 <memmove>
        r = fsipc(FSREQ_OPEN,(void*)fd);
  8022e2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8022e5:	b8 01 00 00 00       	mov    $0x1,%eax
  8022ea:	e8 8d fd ff ff       	call   80207c <fsipc>
  8022ef:	89 c3                	mov    %eax,%ebx
        if(r < 0){
  8022f1:	85 c0                	test   %eax,%eax
  8022f3:	79 15                	jns    80230a <open+0x83>
             fd_close(fd,0);
  8022f5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8022fc:	00 
  8022fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802300:	89 04 24             	mov    %eax,(%esp)
  802303:	e8 37 fb ff ff       	call   801e3f <fd_close>
             return r;
  802308:	eb 0d                	jmp    802317 <open+0x90>
        }
        return fd2num(fd);
  80230a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80230d:	89 04 24             	mov    %eax,(%esp)
  802310:	e8 4b f7 ff ff       	call   801a60 <fd2num>
  802315:	89 c3                	mov    %eax,%ebx
	//panic("open not implemented");
}
  802317:	89 d8                	mov    %ebx,%eax
  802319:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80231c:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80231f:	89 ec                	mov    %ebp,%esp
  802321:	5d                   	pop    %ebp
  802322:	c3                   	ret    
	...

00802324 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802324:	55                   	push   %ebp
  802325:	89 e5                	mov    %esp,%ebp
  802327:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  80232a:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  802331:	75 30                	jne    802363 <set_pgfault_handler+0x3f>
		// First time through!
		// LAB 4: Your code here.
                uint32_t ret = sys_page_alloc(0,(void*)(UXSTACKTOP-PGSIZE),PTE_P|PTE_U|PTE_W);
  802333:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80233a:	00 
  80233b:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  802342:	ee 
  802343:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80234a:	e8 84 f0 ff ff       	call   8013d3 <sys_page_alloc>
                if(ret < 0)
                  return;
                sys_env_set_pgfault_upcall(0,_pgfault_upcall);
  80234f:	c7 44 24 04 70 23 80 	movl   $0x802370,0x4(%esp)
  802356:	00 
  802357:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80235e:	e8 52 ee ff ff       	call   8011b5 <sys_env_set_pgfault_upcall>
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802363:	8b 45 08             	mov    0x8(%ebp),%eax
  802366:	a3 00 60 80 00       	mov    %eax,0x806000
}
  80236b:	c9                   	leave  
  80236c:	c3                   	ret    
  80236d:	00 00                	add    %al,(%eax)
	...

00802370 <_pgfault_upcall>:
  802370:	54                   	push   %esp
  802371:	a1 00 60 80 00       	mov    0x806000,%eax
  802376:	ff d0                	call   *%eax
  802378:	83 c4 04             	add    $0x4,%esp
  80237b:	8b 44 24 28          	mov    0x28(%esp),%eax
  80237f:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  802383:	83 e9 04             	sub    $0x4,%ecx
  802386:	89 01                	mov    %eax,(%ecx)
  802388:	89 4c 24 30          	mov    %ecx,0x30(%esp)
  80238c:	83 c4 08             	add    $0x8,%esp
  80238f:	61                   	popa   
  802390:	83 c4 04             	add    $0x4,%esp
  802393:	9d                   	popf   
  802394:	5c                   	pop    %esp
  802395:	c3                   	ret    
	...

008023a0 <__udivdi3>:
  8023a0:	55                   	push   %ebp
  8023a1:	89 e5                	mov    %esp,%ebp
  8023a3:	57                   	push   %edi
  8023a4:	56                   	push   %esi
  8023a5:	83 ec 10             	sub    $0x10,%esp
  8023a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8023ab:	8b 55 08             	mov    0x8(%ebp),%edx
  8023ae:	8b 75 10             	mov    0x10(%ebp),%esi
  8023b1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8023b4:	85 c0                	test   %eax,%eax
  8023b6:	89 55 f0             	mov    %edx,-0x10(%ebp)
  8023b9:	75 35                	jne    8023f0 <__udivdi3+0x50>
  8023bb:	39 fe                	cmp    %edi,%esi
  8023bd:	77 61                	ja     802420 <__udivdi3+0x80>
  8023bf:	85 f6                	test   %esi,%esi
  8023c1:	75 0b                	jne    8023ce <__udivdi3+0x2e>
  8023c3:	b8 01 00 00 00       	mov    $0x1,%eax
  8023c8:	31 d2                	xor    %edx,%edx
  8023ca:	f7 f6                	div    %esi
  8023cc:	89 c6                	mov    %eax,%esi
  8023ce:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  8023d1:	31 d2                	xor    %edx,%edx
  8023d3:	89 f8                	mov    %edi,%eax
  8023d5:	f7 f6                	div    %esi
  8023d7:	89 c7                	mov    %eax,%edi
  8023d9:	89 c8                	mov    %ecx,%eax
  8023db:	f7 f6                	div    %esi
  8023dd:	89 c1                	mov    %eax,%ecx
  8023df:	89 fa                	mov    %edi,%edx
  8023e1:	89 c8                	mov    %ecx,%eax
  8023e3:	83 c4 10             	add    $0x10,%esp
  8023e6:	5e                   	pop    %esi
  8023e7:	5f                   	pop    %edi
  8023e8:	5d                   	pop    %ebp
  8023e9:	c3                   	ret    
  8023ea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8023f0:	39 f8                	cmp    %edi,%eax
  8023f2:	77 1c                	ja     802410 <__udivdi3+0x70>
  8023f4:	0f bd d0             	bsr    %eax,%edx
  8023f7:	83 f2 1f             	xor    $0x1f,%edx
  8023fa:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8023fd:	75 39                	jne    802438 <__udivdi3+0x98>
  8023ff:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  802402:	0f 86 a0 00 00 00    	jbe    8024a8 <__udivdi3+0x108>
  802408:	39 f8                	cmp    %edi,%eax
  80240a:	0f 82 98 00 00 00    	jb     8024a8 <__udivdi3+0x108>
  802410:	31 ff                	xor    %edi,%edi
  802412:	31 c9                	xor    %ecx,%ecx
  802414:	89 c8                	mov    %ecx,%eax
  802416:	89 fa                	mov    %edi,%edx
  802418:	83 c4 10             	add    $0x10,%esp
  80241b:	5e                   	pop    %esi
  80241c:	5f                   	pop    %edi
  80241d:	5d                   	pop    %ebp
  80241e:	c3                   	ret    
  80241f:	90                   	nop
  802420:	89 d1                	mov    %edx,%ecx
  802422:	89 fa                	mov    %edi,%edx
  802424:	89 c8                	mov    %ecx,%eax
  802426:	31 ff                	xor    %edi,%edi
  802428:	f7 f6                	div    %esi
  80242a:	89 c1                	mov    %eax,%ecx
  80242c:	89 fa                	mov    %edi,%edx
  80242e:	89 c8                	mov    %ecx,%eax
  802430:	83 c4 10             	add    $0x10,%esp
  802433:	5e                   	pop    %esi
  802434:	5f                   	pop    %edi
  802435:	5d                   	pop    %ebp
  802436:	c3                   	ret    
  802437:	90                   	nop
  802438:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80243c:	89 f2                	mov    %esi,%edx
  80243e:	d3 e0                	shl    %cl,%eax
  802440:	89 45 ec             	mov    %eax,-0x14(%ebp)
  802443:	b8 20 00 00 00       	mov    $0x20,%eax
  802448:	2b 45 f4             	sub    -0xc(%ebp),%eax
  80244b:	89 c1                	mov    %eax,%ecx
  80244d:	d3 ea                	shr    %cl,%edx
  80244f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  802453:	0b 55 ec             	or     -0x14(%ebp),%edx
  802456:	d3 e6                	shl    %cl,%esi
  802458:	89 c1                	mov    %eax,%ecx
  80245a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  80245d:	89 fe                	mov    %edi,%esi
  80245f:	d3 ee                	shr    %cl,%esi
  802461:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  802465:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802468:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80246b:	d3 e7                	shl    %cl,%edi
  80246d:	89 c1                	mov    %eax,%ecx
  80246f:	d3 ea                	shr    %cl,%edx
  802471:	09 d7                	or     %edx,%edi
  802473:	89 f2                	mov    %esi,%edx
  802475:	89 f8                	mov    %edi,%eax
  802477:	f7 75 ec             	divl   -0x14(%ebp)
  80247a:	89 d6                	mov    %edx,%esi
  80247c:	89 c7                	mov    %eax,%edi
  80247e:	f7 65 e8             	mull   -0x18(%ebp)
  802481:	39 d6                	cmp    %edx,%esi
  802483:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802486:	72 30                	jb     8024b8 <__udivdi3+0x118>
  802488:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80248b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80248f:	d3 e2                	shl    %cl,%edx
  802491:	39 c2                	cmp    %eax,%edx
  802493:	73 05                	jae    80249a <__udivdi3+0xfa>
  802495:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  802498:	74 1e                	je     8024b8 <__udivdi3+0x118>
  80249a:	89 f9                	mov    %edi,%ecx
  80249c:	31 ff                	xor    %edi,%edi
  80249e:	e9 71 ff ff ff       	jmp    802414 <__udivdi3+0x74>
  8024a3:	90                   	nop
  8024a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8024a8:	31 ff                	xor    %edi,%edi
  8024aa:	b9 01 00 00 00       	mov    $0x1,%ecx
  8024af:	e9 60 ff ff ff       	jmp    802414 <__udivdi3+0x74>
  8024b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8024b8:	8d 4f ff             	lea    -0x1(%edi),%ecx
  8024bb:	31 ff                	xor    %edi,%edi
  8024bd:	89 c8                	mov    %ecx,%eax
  8024bf:	89 fa                	mov    %edi,%edx
  8024c1:	83 c4 10             	add    $0x10,%esp
  8024c4:	5e                   	pop    %esi
  8024c5:	5f                   	pop    %edi
  8024c6:	5d                   	pop    %ebp
  8024c7:	c3                   	ret    
	...

008024d0 <__umoddi3>:
  8024d0:	55                   	push   %ebp
  8024d1:	89 e5                	mov    %esp,%ebp
  8024d3:	57                   	push   %edi
  8024d4:	56                   	push   %esi
  8024d5:	83 ec 20             	sub    $0x20,%esp
  8024d8:	8b 55 14             	mov    0x14(%ebp),%edx
  8024db:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8024de:	8b 7d 10             	mov    0x10(%ebp),%edi
  8024e1:	8b 75 0c             	mov    0xc(%ebp),%esi
  8024e4:	85 d2                	test   %edx,%edx
  8024e6:	89 c8                	mov    %ecx,%eax
  8024e8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  8024eb:	75 13                	jne    802500 <__umoddi3+0x30>
  8024ed:	39 f7                	cmp    %esi,%edi
  8024ef:	76 3f                	jbe    802530 <__umoddi3+0x60>
  8024f1:	89 f2                	mov    %esi,%edx
  8024f3:	f7 f7                	div    %edi
  8024f5:	89 d0                	mov    %edx,%eax
  8024f7:	31 d2                	xor    %edx,%edx
  8024f9:	83 c4 20             	add    $0x20,%esp
  8024fc:	5e                   	pop    %esi
  8024fd:	5f                   	pop    %edi
  8024fe:	5d                   	pop    %ebp
  8024ff:	c3                   	ret    
  802500:	39 f2                	cmp    %esi,%edx
  802502:	77 4c                	ja     802550 <__umoddi3+0x80>
  802504:	0f bd ca             	bsr    %edx,%ecx
  802507:	83 f1 1f             	xor    $0x1f,%ecx
  80250a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80250d:	75 51                	jne    802560 <__umoddi3+0x90>
  80250f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  802512:	0f 87 e0 00 00 00    	ja     8025f8 <__umoddi3+0x128>
  802518:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80251b:	29 f8                	sub    %edi,%eax
  80251d:	19 d6                	sbb    %edx,%esi
  80251f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  802522:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802525:	89 f2                	mov    %esi,%edx
  802527:	83 c4 20             	add    $0x20,%esp
  80252a:	5e                   	pop    %esi
  80252b:	5f                   	pop    %edi
  80252c:	5d                   	pop    %ebp
  80252d:	c3                   	ret    
  80252e:	66 90                	xchg   %ax,%ax
  802530:	85 ff                	test   %edi,%edi
  802532:	75 0b                	jne    80253f <__umoddi3+0x6f>
  802534:	b8 01 00 00 00       	mov    $0x1,%eax
  802539:	31 d2                	xor    %edx,%edx
  80253b:	f7 f7                	div    %edi
  80253d:	89 c7                	mov    %eax,%edi
  80253f:	89 f0                	mov    %esi,%eax
  802541:	31 d2                	xor    %edx,%edx
  802543:	f7 f7                	div    %edi
  802545:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802548:	f7 f7                	div    %edi
  80254a:	eb a9                	jmp    8024f5 <__umoddi3+0x25>
  80254c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802550:	89 c8                	mov    %ecx,%eax
  802552:	89 f2                	mov    %esi,%edx
  802554:	83 c4 20             	add    $0x20,%esp
  802557:	5e                   	pop    %esi
  802558:	5f                   	pop    %edi
  802559:	5d                   	pop    %ebp
  80255a:	c3                   	ret    
  80255b:	90                   	nop
  80255c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802560:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802564:	d3 e2                	shl    %cl,%edx
  802566:	89 55 f4             	mov    %edx,-0xc(%ebp)
  802569:	ba 20 00 00 00       	mov    $0x20,%edx
  80256e:	2b 55 f0             	sub    -0x10(%ebp),%edx
  802571:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802574:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802578:	89 fa                	mov    %edi,%edx
  80257a:	d3 ea                	shr    %cl,%edx
  80257c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802580:	0b 55 f4             	or     -0xc(%ebp),%edx
  802583:	d3 e7                	shl    %cl,%edi
  802585:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802589:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80258c:	89 f2                	mov    %esi,%edx
  80258e:	89 7d e8             	mov    %edi,-0x18(%ebp)
  802591:	89 c7                	mov    %eax,%edi
  802593:	d3 ea                	shr    %cl,%edx
  802595:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802599:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80259c:	89 c2                	mov    %eax,%edx
  80259e:	d3 e6                	shl    %cl,%esi
  8025a0:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8025a4:	d3 ea                	shr    %cl,%edx
  8025a6:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8025aa:	09 d6                	or     %edx,%esi
  8025ac:	89 f0                	mov    %esi,%eax
  8025ae:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8025b1:	d3 e7                	shl    %cl,%edi
  8025b3:	89 f2                	mov    %esi,%edx
  8025b5:	f7 75 f4             	divl   -0xc(%ebp)
  8025b8:	89 d6                	mov    %edx,%esi
  8025ba:	f7 65 e8             	mull   -0x18(%ebp)
  8025bd:	39 d6                	cmp    %edx,%esi
  8025bf:	72 2b                	jb     8025ec <__umoddi3+0x11c>
  8025c1:	39 c7                	cmp    %eax,%edi
  8025c3:	72 23                	jb     8025e8 <__umoddi3+0x118>
  8025c5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8025c9:	29 c7                	sub    %eax,%edi
  8025cb:	19 d6                	sbb    %edx,%esi
  8025cd:	89 f0                	mov    %esi,%eax
  8025cf:	89 f2                	mov    %esi,%edx
  8025d1:	d3 ef                	shr    %cl,%edi
  8025d3:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8025d7:	d3 e0                	shl    %cl,%eax
  8025d9:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8025dd:	09 f8                	or     %edi,%eax
  8025df:	d3 ea                	shr    %cl,%edx
  8025e1:	83 c4 20             	add    $0x20,%esp
  8025e4:	5e                   	pop    %esi
  8025e5:	5f                   	pop    %edi
  8025e6:	5d                   	pop    %ebp
  8025e7:	c3                   	ret    
  8025e8:	39 d6                	cmp    %edx,%esi
  8025ea:	75 d9                	jne    8025c5 <__umoddi3+0xf5>
  8025ec:	2b 45 e8             	sub    -0x18(%ebp),%eax
  8025ef:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  8025f2:	eb d1                	jmp    8025c5 <__umoddi3+0xf5>
  8025f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8025f8:	39 f2                	cmp    %esi,%edx
  8025fa:	0f 82 18 ff ff ff    	jb     802518 <__umoddi3+0x48>
  802600:	e9 1d ff ff ff       	jmp    802522 <__umoddi3+0x52>
