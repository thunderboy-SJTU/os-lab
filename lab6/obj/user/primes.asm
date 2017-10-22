
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
  800053:	e8 91 1a 00 00       	call   801ae9 <ipc_recv>
  800058:	89 c3                	mov    %eax,%ebx
	cprintf("CPU %d: %d ", thisenv->env_cpunum, p);
  80005a:	a1 08 50 80 00       	mov    0x805008,%eax
  80005f:	8b 40 5c             	mov    0x5c(%eax),%eax
  800062:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800066:	89 44 24 04          	mov    %eax,0x4(%esp)
  80006a:	c7 04 24 60 2c 80 00 	movl   $0x802c60,(%esp)
  800071:	e8 03 02 00 00       	call   800279 <cprintf>

	// fork a right neighbor to continue the chain
	if ((id = fork()) < 0)
  800076:	e8 1b 16 00 00       	call   801696 <fork>
  80007b:	89 c7                	mov    %eax,%edi
  80007d:	85 c0                	test   %eax,%eax
  80007f:	79 20                	jns    8000a1 <primeproc+0x6d>
		panic("fork: %e", id);
  800081:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800085:	c7 44 24 08 73 30 80 	movl   $0x803073,0x8(%esp)
  80008c:	00 
  80008d:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  800094:	00 
  800095:	c7 04 24 6c 2c 80 00 	movl   $0x802c6c,(%esp)
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
  8000bb:	e8 29 1a 00 00       	call   801ae9 <ipc_recv>
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
  8000e4:	e8 82 19 00 00       	call   801a6b <ipc_send>
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
  8000f3:	e8 9e 15 00 00       	call   801696 <fork>
  8000f8:	89 c6                	mov    %eax,%esi
  8000fa:	85 c0                	test   %eax,%eax
  8000fc:	79 20                	jns    80011e <umain+0x33>
		panic("fork: %e", id);
  8000fe:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800102:	c7 44 24 08 73 30 80 	movl   $0x803073,0x8(%esp)
  800109:	00 
  80010a:	c7 44 24 04 2d 00 00 	movl   $0x2d,0x4(%esp)
  800111:	00 
  800112:	c7 04 24 6c 2c 80 00 	movl   $0x802c6c,(%esp)
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
  800143:	e8 23 19 00 00       	call   801a6b <ipc_send>
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
  800162:	e8 60 14 00 00       	call   8015c7 <sys_getenvid>
  800167:	25 ff 03 00 00       	and    $0x3ff,%eax
  80016c:	89 c2                	mov    %eax,%edx
  80016e:	c1 e2 07             	shl    $0x7,%edx
  800171:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  800178:	a3 08 50 80 00       	mov    %eax,0x805008
        //cprintf("ENVX sys_get_envid(): %d\n",ENVX(sys_getenvid()));
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80017d:	85 f6                	test   %esi,%esi
  80017f:	7e 07                	jle    800188 <libmain+0x38>
		binaryname = argv[0];
  800181:	8b 03                	mov    (%ebx),%eax
  800183:	a3 00 40 80 00       	mov    %eax,0x804000

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
  8001aa:	e8 8c 1e 00 00       	call   80203b <close_all>
	sys_env_destroy(0);
  8001af:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8001b6:	e8 4c 14 00 00       	call   801607 <sys_env_destroy>
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
  8001cb:	8b 1d 00 40 80 00    	mov    0x804000,%ebx
  8001d1:	e8 f1 13 00 00       	call   8015c7 <sys_getenvid>
  8001d6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001d9:	89 54 24 10          	mov    %edx,0x10(%esp)
  8001dd:	8b 55 08             	mov    0x8(%ebp),%edx
  8001e0:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8001e4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001e8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001ec:	c7 04 24 84 2c 80 00 	movl   $0x802c84,(%esp)
  8001f3:	e8 81 00 00 00       	call   800279 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001f8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8001fc:	8b 45 10             	mov    0x10(%ebp),%eax
  8001ff:	89 04 24             	mov    %eax,(%esp)
  800202:	e8 11 00 00 00       	call   800218 <vcprintf>
	cprintf("\n");
  800207:	c7 04 24 9b 31 80 00 	movl   $0x80319b,(%esp)
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
  80034f:	e8 9c 26 00 00       	call   8029f0 <__udivdi3>
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
  8003b7:	e8 64 27 00 00       	call   802b20 <__umoddi3>
  8003bc:	89 74 24 04          	mov    %esi,0x4(%esp)
  8003c0:	0f be 80 a7 2c 80 00 	movsbl 0x802ca7(%eax),%eax
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
  8004aa:	ff 24 95 80 2e 80 00 	jmp    *0x802e80(,%edx,4)
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
  800567:	8b 14 85 e0 2f 80 00 	mov    0x802fe0(,%eax,4),%edx
  80056e:	85 d2                	test   %edx,%edx
  800570:	75 26                	jne    800598 <vprintfmt+0x16c>
				printfmt(putch, putdat, "error %d", err);
  800572:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800576:	c7 44 24 08 b8 2c 80 	movl   $0x802cb8,0x8(%esp)
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
  80059c:	c7 44 24 08 d6 31 80 	movl   $0x8031d6,0x8(%esp)
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
  8005da:	be c1 2c 80 00       	mov    $0x802cc1,%esi
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
  800884:	e8 67 21 00 00       	call   8029f0 <__udivdi3>
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
  8008d0:	e8 4b 22 00 00       	call   802b20 <__umoddi3>
  8008d5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8008d9:	0f be 80 a7 2c 80 00 	movsbl 0x802ca7(%eax),%eax
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
  800985:	c7 44 24 0c dc 2d 80 	movl   $0x802ddc,0xc(%esp)
  80098c:	00 
  80098d:	c7 44 24 08 d6 31 80 	movl   $0x8031d6,0x8(%esp)
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
  8009bb:	c7 44 24 0c 14 2e 80 	movl   $0x802e14,0xc(%esp)
  8009c2:	00 
  8009c3:	c7 44 24 08 d6 31 80 	movl   $0x8031d6,0x8(%esp)
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
  800a4f:	e8 cc 20 00 00       	call   802b20 <__umoddi3>
  800a54:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a58:	0f be 80 a7 2c 80 00 	movsbl 0x802ca7(%eax),%eax
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
  800a91:	e8 8a 20 00 00       	call   802b20 <__umoddi3>
  800a96:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a9a:	0f be 80 a7 2c 80 00 	movsbl 0x802ca7(%eax),%eax
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

0080101b <sys_get_mac>:
sys_receive_packet(uint32_t addr,int* len){
         return syscall(SYS_receive_packet,0,(uint32_t)addr,(uint32_t)len,0,0,0);
}

int 
sys_get_mac(uint8_t* macaddr){
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
  801028:	b9 00 00 00 00       	mov    $0x0,%ecx
  80102d:	b8 13 00 00 00       	mov    $0x13,%eax
  801032:	8b 55 08             	mov    0x8(%ebp),%edx
  801035:	89 cb                	mov    %ecx,%ebx
  801037:	89 cf                	mov    %ecx,%edi
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
sys_get_mac(uint8_t* macaddr){
         return syscall(SYS_get_mac,0,(uint32_t)macaddr,0,0,0,0);
}
  801051:	8b 1c 24             	mov    (%esp),%ebx
  801054:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801058:	89 ec                	mov    %ebp,%esp
  80105a:	5d                   	pop    %ebp
  80105b:	c3                   	ret    

0080105c <sys_receive_packet>:
sys_transmit_packet(uint32_t addr,int len){
         return syscall(SYS_transmit_packet,0,(uint32_t)addr,(uint32_t)len,0,0,0);
}

int 
sys_receive_packet(uint32_t addr,int* len){
  80105c:	55                   	push   %ebp
  80105d:	89 e5                	mov    %esp,%ebp
  80105f:	83 ec 08             	sub    $0x8,%esp
  801062:	89 1c 24             	mov    %ebx,(%esp)
  801065:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801069:	bb 00 00 00 00       	mov    $0x0,%ebx
  80106e:	b8 12 00 00 00       	mov    $0x12,%eax
  801073:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801076:	8b 55 08             	mov    0x8(%ebp),%edx
  801079:	89 df                	mov    %ebx,%edi
  80107b:	51                   	push   %ecx
  80107c:	52                   	push   %edx
  80107d:	53                   	push   %ebx
  80107e:	54                   	push   %esp
  80107f:	55                   	push   %ebp
  801080:	56                   	push   %esi
  801081:	57                   	push   %edi
  801082:	54                   	push   %esp
  801083:	5d                   	pop    %ebp
  801084:	8d 35 8c 10 80 00    	lea    0x80108c,%esi
  80108a:	0f 34                	sysenter 
  80108c:	5f                   	pop    %edi
  80108d:	5e                   	pop    %esi
  80108e:	5d                   	pop    %ebp
  80108f:	5c                   	pop    %esp
  801090:	5b                   	pop    %ebx
  801091:	5a                   	pop    %edx
  801092:	59                   	pop    %ecx
}

int 
sys_receive_packet(uint32_t addr,int* len){
         return syscall(SYS_receive_packet,0,(uint32_t)addr,(uint32_t)len,0,0,0);
}
  801093:	8b 1c 24             	mov    (%esp),%ebx
  801096:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80109a:	89 ec                	mov    %ebp,%esp
  80109c:	5d                   	pop    %ebp
  80109d:	c3                   	ret    

0080109e <sys_transmit_packet>:
sys_exec(void* vph, uint32_t phnum, uint32_t esp, uint32_t eip){
         return syscall(SYS_exec, 0, (uint32_t)vph, phnum, esp, eip, 0);
}

int 
sys_transmit_packet(uint32_t addr,int len){
  80109e:	55                   	push   %ebp
  80109f:	89 e5                	mov    %esp,%ebp
  8010a1:	83 ec 08             	sub    $0x8,%esp
  8010a4:	89 1c 24             	mov    %ebx,(%esp)
  8010a7:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8010ab:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010b0:	b8 11 00 00 00       	mov    $0x11,%eax
  8010b5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010b8:	8b 55 08             	mov    0x8(%ebp),%edx
  8010bb:	89 df                	mov    %ebx,%edi
  8010bd:	51                   	push   %ecx
  8010be:	52                   	push   %edx
  8010bf:	53                   	push   %ebx
  8010c0:	54                   	push   %esp
  8010c1:	55                   	push   %ebp
  8010c2:	56                   	push   %esi
  8010c3:	57                   	push   %edi
  8010c4:	54                   	push   %esp
  8010c5:	5d                   	pop    %ebp
  8010c6:	8d 35 ce 10 80 00    	lea    0x8010ce,%esi
  8010cc:	0f 34                	sysenter 
  8010ce:	5f                   	pop    %edi
  8010cf:	5e                   	pop    %esi
  8010d0:	5d                   	pop    %ebp
  8010d1:	5c                   	pop    %esp
  8010d2:	5b                   	pop    %ebx
  8010d3:	5a                   	pop    %edx
  8010d4:	59                   	pop    %ecx
}

int 
sys_transmit_packet(uint32_t addr,int len){
         return syscall(SYS_transmit_packet,0,(uint32_t)addr,(uint32_t)len,0,0,0);
}
  8010d5:	8b 1c 24             	mov    (%esp),%ebx
  8010d8:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8010dc:	89 ec                	mov    %ebp,%esp
  8010de:	5d                   	pop    %ebp
  8010df:	c3                   	ret    

008010e0 <sys_exec>:
sys_env_set_prior(envid_t envid, uint32_t prior){
         return syscall(SYS_env_set_prior,1,envid, prior, 0, 0, 0);
}

int 
sys_exec(void* vph, uint32_t phnum, uint32_t esp, uint32_t eip){
  8010e0:	55                   	push   %ebp
  8010e1:	89 e5                	mov    %esp,%ebp
  8010e3:	83 ec 08             	sub    $0x8,%esp
  8010e6:	89 1c 24             	mov    %ebx,(%esp)
  8010e9:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8010ed:	b8 10 00 00 00       	mov    $0x10,%eax
  8010f2:	8b 7d 14             	mov    0x14(%ebp),%edi
  8010f5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010f8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010fb:	8b 55 08             	mov    0x8(%ebp),%edx
  8010fe:	51                   	push   %ecx
  8010ff:	52                   	push   %edx
  801100:	53                   	push   %ebx
  801101:	54                   	push   %esp
  801102:	55                   	push   %ebp
  801103:	56                   	push   %esi
  801104:	57                   	push   %edi
  801105:	54                   	push   %esp
  801106:	5d                   	pop    %ebp
  801107:	8d 35 0f 11 80 00    	lea    0x80110f,%esi
  80110d:	0f 34                	sysenter 
  80110f:	5f                   	pop    %edi
  801110:	5e                   	pop    %esi
  801111:	5d                   	pop    %ebp
  801112:	5c                   	pop    %esp
  801113:	5b                   	pop    %ebx
  801114:	5a                   	pop    %edx
  801115:	59                   	pop    %ecx
}

int 
sys_exec(void* vph, uint32_t phnum, uint32_t esp, uint32_t eip){
         return syscall(SYS_exec, 0, (uint32_t)vph, phnum, esp, eip, 0);
}
  801116:	8b 1c 24             	mov    (%esp),%ebx
  801119:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80111d:	89 ec                	mov    %ebp,%esp
  80111f:	5d                   	pop    %ebp
  801120:	c3                   	ret    

00801121 <sys_env_set_prior>:
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}


int 
sys_env_set_prior(envid_t envid, uint32_t prior){
  801121:	55                   	push   %ebp
  801122:	89 e5                	mov    %esp,%ebp
  801124:	83 ec 28             	sub    $0x28,%esp
  801127:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80112a:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80112d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801132:	b8 0f 00 00 00       	mov    $0xf,%eax
  801137:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80113a:	8b 55 08             	mov    0x8(%ebp),%edx
  80113d:	89 df                	mov    %ebx,%edi
  80113f:	51                   	push   %ecx
  801140:	52                   	push   %edx
  801141:	53                   	push   %ebx
  801142:	54                   	push   %esp
  801143:	55                   	push   %ebp
  801144:	56                   	push   %esi
  801145:	57                   	push   %edi
  801146:	54                   	push   %esp
  801147:	5d                   	pop    %ebp
  801148:	8d 35 50 11 80 00    	lea    0x801150,%esi
  80114e:	0f 34                	sysenter 
  801150:	5f                   	pop    %edi
  801151:	5e                   	pop    %esi
  801152:	5d                   	pop    %ebp
  801153:	5c                   	pop    %esp
  801154:	5b                   	pop    %ebx
  801155:	5a                   	pop    %edx
  801156:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801157:	85 c0                	test   %eax,%eax
  801159:	7e 28                	jle    801183 <sys_env_set_prior+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  80115b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80115f:	c7 44 24 0c 0f 00 00 	movl   $0xf,0xc(%esp)
  801166:	00 
  801167:	c7 44 24 08 20 30 80 	movl   $0x803020,0x8(%esp)
  80116e:	00 
  80116f:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801176:	00 
  801177:	c7 04 24 3d 30 80 00 	movl   $0x80303d,(%esp)
  80117e:	e8 3d f0 ff ff       	call   8001c0 <_panic>


int 
sys_env_set_prior(envid_t envid, uint32_t prior){
         return syscall(SYS_env_set_prior,1,envid, prior, 0, 0, 0);
}
  801183:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801186:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801189:	89 ec                	mov    %ebp,%esp
  80118b:	5d                   	pop    %ebp
  80118c:	c3                   	ret    

0080118d <sys_time_msec>:
}


unsigned int
sys_time_msec(void)
{
  80118d:	55                   	push   %ebp
  80118e:	89 e5                	mov    %esp,%ebp
  801190:	83 ec 08             	sub    $0x8,%esp
  801193:	89 1c 24             	mov    %ebx,(%esp)
  801196:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80119a:	ba 00 00 00 00       	mov    $0x0,%edx
  80119f:	b8 15 00 00 00       	mov    $0x15,%eax
  8011a4:	89 d1                	mov    %edx,%ecx
  8011a6:	89 d3                	mov    %edx,%ebx
  8011a8:	89 d7                	mov    %edx,%edi
  8011aa:	51                   	push   %ecx
  8011ab:	52                   	push   %edx
  8011ac:	53                   	push   %ebx
  8011ad:	54                   	push   %esp
  8011ae:	55                   	push   %ebp
  8011af:	56                   	push   %esi
  8011b0:	57                   	push   %edi
  8011b1:	54                   	push   %esp
  8011b2:	5d                   	pop    %ebp
  8011b3:	8d 35 bb 11 80 00    	lea    0x8011bb,%esi
  8011b9:	0f 34                	sysenter 
  8011bb:	5f                   	pop    %edi
  8011bc:	5e                   	pop    %esi
  8011bd:	5d                   	pop    %ebp
  8011be:	5c                   	pop    %esp
  8011bf:	5b                   	pop    %ebx
  8011c0:	5a                   	pop    %edx
  8011c1:	59                   	pop    %ecx

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  8011c2:	8b 1c 24             	mov    (%esp),%ebx
  8011c5:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8011c9:	89 ec                	mov    %ebp,%esp
  8011cb:	5d                   	pop    %ebp
  8011cc:	c3                   	ret    

008011cd <sys_sbrk>:
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}

int
sys_sbrk(uint32_t inc)
{
  8011cd:	55                   	push   %ebp
  8011ce:	89 e5                	mov    %esp,%ebp
  8011d0:	83 ec 08             	sub    $0x8,%esp
  8011d3:	89 1c 24             	mov    %ebx,(%esp)
  8011d6:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8011da:	b9 00 00 00 00       	mov    $0x0,%ecx
  8011df:	b8 14 00 00 00       	mov    $0x14,%eax
  8011e4:	8b 55 08             	mov    0x8(%ebp),%edx
  8011e7:	89 cb                	mov    %ecx,%ebx
  8011e9:	89 cf                	mov    %ecx,%edi
  8011eb:	51                   	push   %ecx
  8011ec:	52                   	push   %edx
  8011ed:	53                   	push   %ebx
  8011ee:	54                   	push   %esp
  8011ef:	55                   	push   %ebp
  8011f0:	56                   	push   %esi
  8011f1:	57                   	push   %edi
  8011f2:	54                   	push   %esp
  8011f3:	5d                   	pop    %ebp
  8011f4:	8d 35 fc 11 80 00    	lea    0x8011fc,%esi
  8011fa:	0f 34                	sysenter 
  8011fc:	5f                   	pop    %edi
  8011fd:	5e                   	pop    %esi
  8011fe:	5d                   	pop    %ebp
  8011ff:	5c                   	pop    %esp
  801200:	5b                   	pop    %ebx
  801201:	5a                   	pop    %edx
  801202:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  801203:	8b 1c 24             	mov    (%esp),%ebx
  801206:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80120a:	89 ec                	mov    %ebp,%esp
  80120c:	5d                   	pop    %ebp
  80120d:	c3                   	ret    

0080120e <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  80120e:	55                   	push   %ebp
  80120f:	89 e5                	mov    %esp,%ebp
  801211:	83 ec 28             	sub    $0x28,%esp
  801214:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801217:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80121a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80121f:	b8 0e 00 00 00       	mov    $0xe,%eax
  801224:	8b 55 08             	mov    0x8(%ebp),%edx
  801227:	89 cb                	mov    %ecx,%ebx
  801229:	89 cf                	mov    %ecx,%edi
  80122b:	51                   	push   %ecx
  80122c:	52                   	push   %edx
  80122d:	53                   	push   %ebx
  80122e:	54                   	push   %esp
  80122f:	55                   	push   %ebp
  801230:	56                   	push   %esi
  801231:	57                   	push   %edi
  801232:	54                   	push   %esp
  801233:	5d                   	pop    %ebp
  801234:	8d 35 3c 12 80 00    	lea    0x80123c,%esi
  80123a:	0f 34                	sysenter 
  80123c:	5f                   	pop    %edi
  80123d:	5e                   	pop    %esi
  80123e:	5d                   	pop    %ebp
  80123f:	5c                   	pop    %esp
  801240:	5b                   	pop    %ebx
  801241:	5a                   	pop    %edx
  801242:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801243:	85 c0                	test   %eax,%eax
  801245:	7e 28                	jle    80126f <sys_ipc_recv+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  801247:	89 44 24 10          	mov    %eax,0x10(%esp)
  80124b:	c7 44 24 0c 0e 00 00 	movl   $0xe,0xc(%esp)
  801252:	00 
  801253:	c7 44 24 08 20 30 80 	movl   $0x803020,0x8(%esp)
  80125a:	00 
  80125b:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801262:	00 
  801263:	c7 04 24 3d 30 80 00 	movl   $0x80303d,(%esp)
  80126a:	e8 51 ef ff ff       	call   8001c0 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80126f:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801272:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801275:	89 ec                	mov    %ebp,%esp
  801277:	5d                   	pop    %ebp
  801278:	c3                   	ret    

00801279 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801279:	55                   	push   %ebp
  80127a:	89 e5                	mov    %esp,%ebp
  80127c:	83 ec 08             	sub    $0x8,%esp
  80127f:	89 1c 24             	mov    %ebx,(%esp)
  801282:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801286:	b8 0d 00 00 00       	mov    $0xd,%eax
  80128b:	8b 7d 14             	mov    0x14(%ebp),%edi
  80128e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801291:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801294:	8b 55 08             	mov    0x8(%ebp),%edx
  801297:	51                   	push   %ecx
  801298:	52                   	push   %edx
  801299:	53                   	push   %ebx
  80129a:	54                   	push   %esp
  80129b:	55                   	push   %ebp
  80129c:	56                   	push   %esi
  80129d:	57                   	push   %edi
  80129e:	54                   	push   %esp
  80129f:	5d                   	pop    %ebp
  8012a0:	8d 35 a8 12 80 00    	lea    0x8012a8,%esi
  8012a6:	0f 34                	sysenter 
  8012a8:	5f                   	pop    %edi
  8012a9:	5e                   	pop    %esi
  8012aa:	5d                   	pop    %ebp
  8012ab:	5c                   	pop    %esp
  8012ac:	5b                   	pop    %ebx
  8012ad:	5a                   	pop    %edx
  8012ae:	59                   	pop    %ecx

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8012af:	8b 1c 24             	mov    (%esp),%ebx
  8012b2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8012b6:	89 ec                	mov    %ebp,%esp
  8012b8:	5d                   	pop    %ebp
  8012b9:	c3                   	ret    

008012ba <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8012ba:	55                   	push   %ebp
  8012bb:	89 e5                	mov    %esp,%ebp
  8012bd:	83 ec 28             	sub    $0x28,%esp
  8012c0:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8012c3:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8012c6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012cb:	b8 0b 00 00 00       	mov    $0xb,%eax
  8012d0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012d3:	8b 55 08             	mov    0x8(%ebp),%edx
  8012d6:	89 df                	mov    %ebx,%edi
  8012d8:	51                   	push   %ecx
  8012d9:	52                   	push   %edx
  8012da:	53                   	push   %ebx
  8012db:	54                   	push   %esp
  8012dc:	55                   	push   %ebp
  8012dd:	56                   	push   %esi
  8012de:	57                   	push   %edi
  8012df:	54                   	push   %esp
  8012e0:	5d                   	pop    %ebp
  8012e1:	8d 35 e9 12 80 00    	lea    0x8012e9,%esi
  8012e7:	0f 34                	sysenter 
  8012e9:	5f                   	pop    %edi
  8012ea:	5e                   	pop    %esi
  8012eb:	5d                   	pop    %ebp
  8012ec:	5c                   	pop    %esp
  8012ed:	5b                   	pop    %ebx
  8012ee:	5a                   	pop    %edx
  8012ef:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8012f0:	85 c0                	test   %eax,%eax
  8012f2:	7e 28                	jle    80131c <sys_env_set_pgfault_upcall+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012f4:	89 44 24 10          	mov    %eax,0x10(%esp)
  8012f8:	c7 44 24 0c 0b 00 00 	movl   $0xb,0xc(%esp)
  8012ff:	00 
  801300:	c7 44 24 08 20 30 80 	movl   $0x803020,0x8(%esp)
  801307:	00 
  801308:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80130f:	00 
  801310:	c7 04 24 3d 30 80 00 	movl   $0x80303d,(%esp)
  801317:	e8 a4 ee ff ff       	call   8001c0 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80131c:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80131f:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801322:	89 ec                	mov    %ebp,%esp
  801324:	5d                   	pop    %ebp
  801325:	c3                   	ret    

00801326 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801326:	55                   	push   %ebp
  801327:	89 e5                	mov    %esp,%ebp
  801329:	83 ec 28             	sub    $0x28,%esp
  80132c:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80132f:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801332:	bb 00 00 00 00       	mov    $0x0,%ebx
  801337:	b8 0a 00 00 00       	mov    $0xa,%eax
  80133c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80133f:	8b 55 08             	mov    0x8(%ebp),%edx
  801342:	89 df                	mov    %ebx,%edi
  801344:	51                   	push   %ecx
  801345:	52                   	push   %edx
  801346:	53                   	push   %ebx
  801347:	54                   	push   %esp
  801348:	55                   	push   %ebp
  801349:	56                   	push   %esi
  80134a:	57                   	push   %edi
  80134b:	54                   	push   %esp
  80134c:	5d                   	pop    %ebp
  80134d:	8d 35 55 13 80 00    	lea    0x801355,%esi
  801353:	0f 34                	sysenter 
  801355:	5f                   	pop    %edi
  801356:	5e                   	pop    %esi
  801357:	5d                   	pop    %ebp
  801358:	5c                   	pop    %esp
  801359:	5b                   	pop    %ebx
  80135a:	5a                   	pop    %edx
  80135b:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80135c:	85 c0                	test   %eax,%eax
  80135e:	7e 28                	jle    801388 <sys_env_set_trapframe+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  801360:	89 44 24 10          	mov    %eax,0x10(%esp)
  801364:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  80136b:	00 
  80136c:	c7 44 24 08 20 30 80 	movl   $0x803020,0x8(%esp)
  801373:	00 
  801374:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80137b:	00 
  80137c:	c7 04 24 3d 30 80 00 	movl   $0x80303d,(%esp)
  801383:	e8 38 ee ff ff       	call   8001c0 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801388:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80138b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80138e:	89 ec                	mov    %ebp,%esp
  801390:	5d                   	pop    %ebp
  801391:	c3                   	ret    

00801392 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801392:	55                   	push   %ebp
  801393:	89 e5                	mov    %esp,%ebp
  801395:	83 ec 28             	sub    $0x28,%esp
  801398:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80139b:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80139e:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013a3:	b8 09 00 00 00       	mov    $0x9,%eax
  8013a8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013ab:	8b 55 08             	mov    0x8(%ebp),%edx
  8013ae:	89 df                	mov    %ebx,%edi
  8013b0:	51                   	push   %ecx
  8013b1:	52                   	push   %edx
  8013b2:	53                   	push   %ebx
  8013b3:	54                   	push   %esp
  8013b4:	55                   	push   %ebp
  8013b5:	56                   	push   %esi
  8013b6:	57                   	push   %edi
  8013b7:	54                   	push   %esp
  8013b8:	5d                   	pop    %ebp
  8013b9:	8d 35 c1 13 80 00    	lea    0x8013c1,%esi
  8013bf:	0f 34                	sysenter 
  8013c1:	5f                   	pop    %edi
  8013c2:	5e                   	pop    %esi
  8013c3:	5d                   	pop    %ebp
  8013c4:	5c                   	pop    %esp
  8013c5:	5b                   	pop    %ebx
  8013c6:	5a                   	pop    %edx
  8013c7:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8013c8:	85 c0                	test   %eax,%eax
  8013ca:	7e 28                	jle    8013f4 <sys_env_set_status+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  8013cc:	89 44 24 10          	mov    %eax,0x10(%esp)
  8013d0:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8013d7:	00 
  8013d8:	c7 44 24 08 20 30 80 	movl   $0x803020,0x8(%esp)
  8013df:	00 
  8013e0:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8013e7:	00 
  8013e8:	c7 04 24 3d 30 80 00 	movl   $0x80303d,(%esp)
  8013ef:	e8 cc ed ff ff       	call   8001c0 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8013f4:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8013f7:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8013fa:	89 ec                	mov    %ebp,%esp
  8013fc:	5d                   	pop    %ebp
  8013fd:	c3                   	ret    

008013fe <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  8013fe:	55                   	push   %ebp
  8013ff:	89 e5                	mov    %esp,%ebp
  801401:	83 ec 28             	sub    $0x28,%esp
  801404:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801407:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80140a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80140f:	b8 07 00 00 00       	mov    $0x7,%eax
  801414:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801417:	8b 55 08             	mov    0x8(%ebp),%edx
  80141a:	89 df                	mov    %ebx,%edi
  80141c:	51                   	push   %ecx
  80141d:	52                   	push   %edx
  80141e:	53                   	push   %ebx
  80141f:	54                   	push   %esp
  801420:	55                   	push   %ebp
  801421:	56                   	push   %esi
  801422:	57                   	push   %edi
  801423:	54                   	push   %esp
  801424:	5d                   	pop    %ebp
  801425:	8d 35 2d 14 80 00    	lea    0x80142d,%esi
  80142b:	0f 34                	sysenter 
  80142d:	5f                   	pop    %edi
  80142e:	5e                   	pop    %esi
  80142f:	5d                   	pop    %ebp
  801430:	5c                   	pop    %esp
  801431:	5b                   	pop    %ebx
  801432:	5a                   	pop    %edx
  801433:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801434:	85 c0                	test   %eax,%eax
  801436:	7e 28                	jle    801460 <sys_page_unmap+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  801438:	89 44 24 10          	mov    %eax,0x10(%esp)
  80143c:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801443:	00 
  801444:	c7 44 24 08 20 30 80 	movl   $0x803020,0x8(%esp)
  80144b:	00 
  80144c:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801453:	00 
  801454:	c7 04 24 3d 30 80 00 	movl   $0x80303d,(%esp)
  80145b:	e8 60 ed ff ff       	call   8001c0 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801460:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801463:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801466:	89 ec                	mov    %ebp,%esp
  801468:	5d                   	pop    %ebp
  801469:	c3                   	ret    

0080146a <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80146a:	55                   	push   %ebp
  80146b:	89 e5                	mov    %esp,%ebp
  80146d:	83 ec 28             	sub    $0x28,%esp
  801470:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801473:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801476:	8b 7d 18             	mov    0x18(%ebp),%edi
  801479:	0b 7d 14             	or     0x14(%ebp),%edi
  80147c:	b8 06 00 00 00       	mov    $0x6,%eax
  801481:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801484:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801487:	8b 55 08             	mov    0x8(%ebp),%edx
  80148a:	51                   	push   %ecx
  80148b:	52                   	push   %edx
  80148c:	53                   	push   %ebx
  80148d:	54                   	push   %esp
  80148e:	55                   	push   %ebp
  80148f:	56                   	push   %esi
  801490:	57                   	push   %edi
  801491:	54                   	push   %esp
  801492:	5d                   	pop    %ebp
  801493:	8d 35 9b 14 80 00    	lea    0x80149b,%esi
  801499:	0f 34                	sysenter 
  80149b:	5f                   	pop    %edi
  80149c:	5e                   	pop    %esi
  80149d:	5d                   	pop    %ebp
  80149e:	5c                   	pop    %esp
  80149f:	5b                   	pop    %ebx
  8014a0:	5a                   	pop    %edx
  8014a1:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8014a2:	85 c0                	test   %eax,%eax
  8014a4:	7e 28                	jle    8014ce <sys_page_map+0x64>
		panic("syscall %d returned %d (> 0)", num, ret);
  8014a6:	89 44 24 10          	mov    %eax,0x10(%esp)
  8014aa:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  8014b1:	00 
  8014b2:	c7 44 24 08 20 30 80 	movl   $0x803020,0x8(%esp)
  8014b9:	00 
  8014ba:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8014c1:	00 
  8014c2:	c7 04 24 3d 30 80 00 	movl   $0x80303d,(%esp)
  8014c9:	e8 f2 ec ff ff       	call   8001c0 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}
  8014ce:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8014d1:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8014d4:	89 ec                	mov    %ebp,%esp
  8014d6:	5d                   	pop    %ebp
  8014d7:	c3                   	ret    

008014d8 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8014d8:	55                   	push   %ebp
  8014d9:	89 e5                	mov    %esp,%ebp
  8014db:	83 ec 28             	sub    $0x28,%esp
  8014de:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8014e1:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8014e4:	bf 00 00 00 00       	mov    $0x0,%edi
  8014e9:	b8 05 00 00 00       	mov    $0x5,%eax
  8014ee:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8014f1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014f4:	8b 55 08             	mov    0x8(%ebp),%edx
  8014f7:	51                   	push   %ecx
  8014f8:	52                   	push   %edx
  8014f9:	53                   	push   %ebx
  8014fa:	54                   	push   %esp
  8014fb:	55                   	push   %ebp
  8014fc:	56                   	push   %esi
  8014fd:	57                   	push   %edi
  8014fe:	54                   	push   %esp
  8014ff:	5d                   	pop    %ebp
  801500:	8d 35 08 15 80 00    	lea    0x801508,%esi
  801506:	0f 34                	sysenter 
  801508:	5f                   	pop    %edi
  801509:	5e                   	pop    %esi
  80150a:	5d                   	pop    %ebp
  80150b:	5c                   	pop    %esp
  80150c:	5b                   	pop    %ebx
  80150d:	5a                   	pop    %edx
  80150e:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80150f:	85 c0                	test   %eax,%eax
  801511:	7e 28                	jle    80153b <sys_page_alloc+0x63>
		panic("syscall %d returned %d (> 0)", num, ret);
  801513:	89 44 24 10          	mov    %eax,0x10(%esp)
  801517:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  80151e:	00 
  80151f:	c7 44 24 08 20 30 80 	movl   $0x803020,0x8(%esp)
  801526:	00 
  801527:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80152e:	00 
  80152f:	c7 04 24 3d 30 80 00 	movl   $0x80303d,(%esp)
  801536:	e8 85 ec ff ff       	call   8001c0 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80153b:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80153e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801541:	89 ec                	mov    %ebp,%esp
  801543:	5d                   	pop    %ebp
  801544:	c3                   	ret    

00801545 <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
{
  801545:	55                   	push   %ebp
  801546:	89 e5                	mov    %esp,%ebp
  801548:	83 ec 08             	sub    $0x8,%esp
  80154b:	89 1c 24             	mov    %ebx,(%esp)
  80154e:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801552:	ba 00 00 00 00       	mov    $0x0,%edx
  801557:	b8 0c 00 00 00       	mov    $0xc,%eax
  80155c:	89 d1                	mov    %edx,%ecx
  80155e:	89 d3                	mov    %edx,%ebx
  801560:	89 d7                	mov    %edx,%edi
  801562:	51                   	push   %ecx
  801563:	52                   	push   %edx
  801564:	53                   	push   %ebx
  801565:	54                   	push   %esp
  801566:	55                   	push   %ebp
  801567:	56                   	push   %esi
  801568:	57                   	push   %edi
  801569:	54                   	push   %esp
  80156a:	5d                   	pop    %ebp
  80156b:	8d 35 73 15 80 00    	lea    0x801573,%esi
  801571:	0f 34                	sysenter 
  801573:	5f                   	pop    %edi
  801574:	5e                   	pop    %esi
  801575:	5d                   	pop    %ebp
  801576:	5c                   	pop    %esp
  801577:	5b                   	pop    %ebx
  801578:	5a                   	pop    %edx
  801579:	59                   	pop    %ecx

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80157a:	8b 1c 24             	mov    (%esp),%ebx
  80157d:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801581:	89 ec                	mov    %ebp,%esp
  801583:	5d                   	pop    %ebp
  801584:	c3                   	ret    

00801585 <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
{
  801585:	55                   	push   %ebp
  801586:	89 e5                	mov    %esp,%ebp
  801588:	83 ec 08             	sub    $0x8,%esp
  80158b:	89 1c 24             	mov    %ebx,(%esp)
  80158e:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801592:	bb 00 00 00 00       	mov    $0x0,%ebx
  801597:	b8 04 00 00 00       	mov    $0x4,%eax
  80159c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80159f:	8b 55 08             	mov    0x8(%ebp),%edx
  8015a2:	89 df                	mov    %ebx,%edi
  8015a4:	51                   	push   %ecx
  8015a5:	52                   	push   %edx
  8015a6:	53                   	push   %ebx
  8015a7:	54                   	push   %esp
  8015a8:	55                   	push   %ebp
  8015a9:	56                   	push   %esi
  8015aa:	57                   	push   %edi
  8015ab:	54                   	push   %esp
  8015ac:	5d                   	pop    %ebp
  8015ad:	8d 35 b5 15 80 00    	lea    0x8015b5,%esi
  8015b3:	0f 34                	sysenter 
  8015b5:	5f                   	pop    %edi
  8015b6:	5e                   	pop    %esi
  8015b7:	5d                   	pop    %ebp
  8015b8:	5c                   	pop    %esp
  8015b9:	5b                   	pop    %ebx
  8015ba:	5a                   	pop    %edx
  8015bb:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  8015bc:	8b 1c 24             	mov    (%esp),%ebx
  8015bf:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8015c3:	89 ec                	mov    %ebp,%esp
  8015c5:	5d                   	pop    %ebp
  8015c6:	c3                   	ret    

008015c7 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  8015c7:	55                   	push   %ebp
  8015c8:	89 e5                	mov    %esp,%ebp
  8015ca:	83 ec 08             	sub    $0x8,%esp
  8015cd:	89 1c 24             	mov    %ebx,(%esp)
  8015d0:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8015d4:	ba 00 00 00 00       	mov    $0x0,%edx
  8015d9:	b8 02 00 00 00       	mov    $0x2,%eax
  8015de:	89 d1                	mov    %edx,%ecx
  8015e0:	89 d3                	mov    %edx,%ebx
  8015e2:	89 d7                	mov    %edx,%edi
  8015e4:	51                   	push   %ecx
  8015e5:	52                   	push   %edx
  8015e6:	53                   	push   %ebx
  8015e7:	54                   	push   %esp
  8015e8:	55                   	push   %ebp
  8015e9:	56                   	push   %esi
  8015ea:	57                   	push   %edi
  8015eb:	54                   	push   %esp
  8015ec:	5d                   	pop    %ebp
  8015ed:	8d 35 f5 15 80 00    	lea    0x8015f5,%esi
  8015f3:	0f 34                	sysenter 
  8015f5:	5f                   	pop    %edi
  8015f6:	5e                   	pop    %esi
  8015f7:	5d                   	pop    %ebp
  8015f8:	5c                   	pop    %esp
  8015f9:	5b                   	pop    %ebx
  8015fa:	5a                   	pop    %edx
  8015fb:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8015fc:	8b 1c 24             	mov    (%esp),%ebx
  8015ff:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801603:	89 ec                	mov    %ebp,%esp
  801605:	5d                   	pop    %ebp
  801606:	c3                   	ret    

00801607 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  801607:	55                   	push   %ebp
  801608:	89 e5                	mov    %esp,%ebp
  80160a:	83 ec 28             	sub    $0x28,%esp
  80160d:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801610:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801613:	b9 00 00 00 00       	mov    $0x0,%ecx
  801618:	b8 03 00 00 00       	mov    $0x3,%eax
  80161d:	8b 55 08             	mov    0x8(%ebp),%edx
  801620:	89 cb                	mov    %ecx,%ebx
  801622:	89 cf                	mov    %ecx,%edi
  801624:	51                   	push   %ecx
  801625:	52                   	push   %edx
  801626:	53                   	push   %ebx
  801627:	54                   	push   %esp
  801628:	55                   	push   %ebp
  801629:	56                   	push   %esi
  80162a:	57                   	push   %edi
  80162b:	54                   	push   %esp
  80162c:	5d                   	pop    %ebp
  80162d:	8d 35 35 16 80 00    	lea    0x801635,%esi
  801633:	0f 34                	sysenter 
  801635:	5f                   	pop    %edi
  801636:	5e                   	pop    %esi
  801637:	5d                   	pop    %ebp
  801638:	5c                   	pop    %esp
  801639:	5b                   	pop    %ebx
  80163a:	5a                   	pop    %edx
  80163b:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80163c:	85 c0                	test   %eax,%eax
  80163e:	7e 28                	jle    801668 <sys_env_destroy+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  801640:	89 44 24 10          	mov    %eax,0x10(%esp)
  801644:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  80164b:	00 
  80164c:	c7 44 24 08 20 30 80 	movl   $0x803020,0x8(%esp)
  801653:	00 
  801654:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80165b:	00 
  80165c:	c7 04 24 3d 30 80 00 	movl   $0x80303d,(%esp)
  801663:	e8 58 eb ff ff       	call   8001c0 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801668:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80166b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80166e:	89 ec                	mov    %ebp,%esp
  801670:	5d                   	pop    %ebp
  801671:	c3                   	ret    
	...

00801674 <sfork>:
}

// Challenge!
int
sfork(void)
{
  801674:	55                   	push   %ebp
  801675:	89 e5                	mov    %esp,%ebp
  801677:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  80167a:	c7 44 24 08 4b 30 80 	movl   $0x80304b,0x8(%esp)
  801681:	00 
  801682:	c7 44 24 04 8e 00 00 	movl   $0x8e,0x4(%esp)
  801689:	00 
  80168a:	c7 04 24 61 30 80 00 	movl   $0x803061,(%esp)
  801691:	e8 2a eb ff ff       	call   8001c0 <_panic>

00801696 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801696:	55                   	push   %ebp
  801697:	89 e5                	mov    %esp,%ebp
  801699:	57                   	push   %edi
  80169a:	56                   	push   %esi
  80169b:	53                   	push   %ebx
  80169c:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
        set_pgfault_handler(pgfault);
  80169f:	c7 04 24 eb 18 80 00 	movl   $0x8018eb,(%esp)
  8016a6:	e8 89 12 00 00       	call   802934 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  8016ab:	ba 08 00 00 00       	mov    $0x8,%edx
  8016b0:	89 d0                	mov    %edx,%eax
  8016b2:	cd 30                	int    $0x30
  8016b4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        envid_t envid = sys_exofork();
        uint32_t addr;
        extern void _pgfault_upcall();
        int r = 0;
        if (envid < 0)
  8016b7:	85 c0                	test   %eax,%eax
  8016b9:	79 20                	jns    8016db <fork+0x45>
		panic("sys_exofork: %e", envid);
  8016bb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8016bf:	c7 44 24 08 6c 30 80 	movl   $0x80306c,0x8(%esp)
  8016c6:	00 
  8016c7:	c7 44 24 04 74 00 00 	movl   $0x74,0x4(%esp)
  8016ce:	00 
  8016cf:	c7 04 24 61 30 80 00 	movl   $0x803061,(%esp)
  8016d6:	e8 e5 ea ff ff       	call   8001c0 <_panic>
	if (envid == 0) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
  8016db:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
        for(addr = 0; addr < USTACKTOP; addr += PGSIZE){
           if((vpd[PDX(addr)] & PTE_P) && (vpt[PGNUM(addr)] & PTE_P) && (vpt[PGNUM(addr)] & PTE_U))
  8016e0:	be 00 d0 7b ef       	mov    $0xef7bd000,%esi
  8016e5:	bf 00 00 40 ef       	mov    $0xef400000,%edi
        uint32_t addr;
        extern void _pgfault_upcall();
        int r = 0;
        if (envid < 0)
		panic("sys_exofork: %e", envid);
	if (envid == 0) {
  8016ea:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8016ee:	75 20                	jne    801710 <fork+0x7a>
		thisenv = &envs[ENVX(sys_getenvid())];
  8016f0:	e8 d2 fe ff ff       	call   8015c7 <sys_getenvid>
  8016f5:	25 ff 03 00 00       	and    $0x3ff,%eax
  8016fa:	89 c2                	mov    %eax,%edx
  8016fc:	c1 e2 07             	shl    $0x7,%edx
  8016ff:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  801706:	a3 08 50 80 00       	mov    %eax,0x805008
		return 0;
  80170b:	e9 d0 01 00 00       	jmp    8018e0 <fork+0x24a>
	}
        for(addr = 0; addr < USTACKTOP; addr += PGSIZE){
           if((vpd[PDX(addr)] & PTE_P) && (vpt[PGNUM(addr)] & PTE_P) && (vpt[PGNUM(addr)] & PTE_U))
  801710:	89 d8                	mov    %ebx,%eax
  801712:	c1 e8 16             	shr    $0x16,%eax
  801715:	8b 04 86             	mov    (%esi,%eax,4),%eax
  801718:	a8 01                	test   $0x1,%al
  80171a:	0f 84 0d 01 00 00    	je     80182d <fork+0x197>
  801720:	89 d8                	mov    %ebx,%eax
  801722:	c1 e8 0c             	shr    $0xc,%eax
  801725:	8b 14 87             	mov    (%edi,%eax,4),%edx
  801728:	f6 c2 01             	test   $0x1,%dl
  80172b:	0f 84 fc 00 00 00    	je     80182d <fork+0x197>
  801731:	8b 14 87             	mov    (%edi,%eax,4),%edx
  801734:	f6 c2 04             	test   $0x4,%dl
  801737:	0f 84 f0 00 00 00    	je     80182d <fork+0x197>
duppage(envid_t envid, unsigned pn)
{
	int r;
        
	// LAB 4: Your code here.
        uint32_t addr = pn*PGSIZE;
  80173d:	c1 e0 0c             	shl    $0xc,%eax
        pte_t pte = vpt[PGNUM(addr)];
  801740:	89 c2                	mov    %eax,%edx
  801742:	c1 ea 0c             	shr    $0xc,%edx
  801745:	8b 14 97             	mov    (%edi,%edx,4),%edx
        if(pte & PTE_P){
  801748:	f6 c2 01             	test   $0x1,%dl
  80174b:	0f 84 dc 00 00 00    	je     80182d <fork+0x197>
          if((pte & PTE_W)|| (pte & PTE_COW)){
  801751:	f7 c2 02 08 00 00    	test   $0x802,%edx
  801757:	0f 84 8d 00 00 00    	je     8017ea <fork+0x154>
               r = sys_page_map(0,(void*)addr,envid,(void*)addr,PTE_P|PTE_U|PTE_COW);
  80175d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801760:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  801767:	00 
  801768:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80176c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80176f:	89 54 24 08          	mov    %edx,0x8(%esp)
  801773:	89 44 24 04          	mov    %eax,0x4(%esp)
  801777:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80177e:	e8 e7 fc ff ff       	call   80146a <sys_page_map>
               if(r<0)
  801783:	85 c0                	test   %eax,%eax
  801785:	79 1c                	jns    8017a3 <fork+0x10d>
                 panic("map failed");
  801787:	c7 44 24 08 7c 30 80 	movl   $0x80307c,0x8(%esp)
  80178e:	00 
  80178f:	c7 44 24 04 49 00 00 	movl   $0x49,0x4(%esp)
  801796:	00 
  801797:	c7 04 24 61 30 80 00 	movl   $0x803061,(%esp)
  80179e:	e8 1d ea ff ff       	call   8001c0 <_panic>
               r = sys_page_map(0,(void*)addr,0,(void*)addr,PTE_P|PTE_U|PTE_COW);    //mark itself COW as well
  8017a3:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  8017aa:	00 
  8017ab:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8017ae:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8017b2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8017b9:	00 
  8017ba:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017be:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017c5:	e8 a0 fc ff ff       	call   80146a <sys_page_map>
               if(r<0)
  8017ca:	85 c0                	test   %eax,%eax
  8017cc:	79 5f                	jns    80182d <fork+0x197>
                 panic("map failed");
  8017ce:	c7 44 24 08 7c 30 80 	movl   $0x80307c,0x8(%esp)
  8017d5:	00 
  8017d6:	c7 44 24 04 4c 00 00 	movl   $0x4c,0x4(%esp)
  8017dd:	00 
  8017de:	c7 04 24 61 30 80 00 	movl   $0x803061,(%esp)
  8017e5:	e8 d6 e9 ff ff       	call   8001c0 <_panic>
          }
          else{
               r = sys_page_map(0,(void*)addr,envid,(void*)addr,PTE_P|PTE_U);
  8017ea:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  8017f1:	00 
  8017f2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8017f6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8017f9:	89 54 24 08          	mov    %edx,0x8(%esp)
  8017fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801801:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801808:	e8 5d fc ff ff       	call   80146a <sys_page_map>
               if(r<0)
  80180d:	85 c0                	test   %eax,%eax
  80180f:	79 1c                	jns    80182d <fork+0x197>
                 panic("map failed");
  801811:	c7 44 24 08 7c 30 80 	movl   $0x80307c,0x8(%esp)
  801818:	00 
  801819:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  801820:	00 
  801821:	c7 04 24 61 30 80 00 	movl   $0x803061,(%esp)
  801828:	e8 93 e9 ff ff       	call   8001c0 <_panic>
		panic("sys_exofork: %e", envid);
	if (envid == 0) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
        for(addr = 0; addr < USTACKTOP; addr += PGSIZE){
  80182d:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801833:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  801839:	0f 85 d1 fe ff ff    	jne    801710 <fork+0x7a>
           if((vpd[PDX(addr)] & PTE_P) && (vpt[PGNUM(addr)] & PTE_P) && (vpt[PGNUM(addr)] & PTE_U))
              duppage(envid,PGNUM(addr));
        }
        r = sys_page_alloc(envid, (void*)(UXSTACKTOP-PGSIZE),PTE_P|PTE_U|PTE_W);
  80183f:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801846:	00 
  801847:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80184e:	ee 
  80184f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801852:	89 04 24             	mov    %eax,(%esp)
  801855:	e8 7e fc ff ff       	call   8014d8 <sys_page_alloc>
        if(r < 0)
  80185a:	85 c0                	test   %eax,%eax
  80185c:	79 1c                	jns    80187a <fork+0x1e4>
            panic("alloc failed");
  80185e:	c7 44 24 08 87 30 80 	movl   $0x803087,0x8(%esp)
  801865:	00 
  801866:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
  80186d:	00 
  80186e:	c7 04 24 61 30 80 00 	movl   $0x803061,(%esp)
  801875:	e8 46 e9 ff ff       	call   8001c0 <_panic>
        r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  80187a:	c7 44 24 04 80 29 80 	movl   $0x802980,0x4(%esp)
  801881:	00 
  801882:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801885:	89 14 24             	mov    %edx,(%esp)
  801888:	e8 2d fa ff ff       	call   8012ba <sys_env_set_pgfault_upcall>
        if(r < 0)
  80188d:	85 c0                	test   %eax,%eax
  80188f:	79 1c                	jns    8018ad <fork+0x217>
            panic("set pgfault upcall failed");
  801891:	c7 44 24 08 94 30 80 	movl   $0x803094,0x8(%esp)
  801898:	00 
  801899:	c7 44 24 04 82 00 00 	movl   $0x82,0x4(%esp)
  8018a0:	00 
  8018a1:	c7 04 24 61 30 80 00 	movl   $0x803061,(%esp)
  8018a8:	e8 13 e9 ff ff       	call   8001c0 <_panic>
        r = sys_env_set_status(envid, ENV_RUNNABLE);
  8018ad:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8018b4:	00 
  8018b5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8018b8:	89 04 24             	mov    %eax,(%esp)
  8018bb:	e8 d2 fa ff ff       	call   801392 <sys_env_set_status>
        if(r < 0)
  8018c0:	85 c0                	test   %eax,%eax
  8018c2:	79 1c                	jns    8018e0 <fork+0x24a>
            panic("set status failed");
  8018c4:	c7 44 24 08 ae 30 80 	movl   $0x8030ae,0x8(%esp)
  8018cb:	00 
  8018cc:	c7 44 24 04 85 00 00 	movl   $0x85,0x4(%esp)
  8018d3:	00 
  8018d4:	c7 04 24 61 30 80 00 	movl   $0x803061,(%esp)
  8018db:	e8 e0 e8 ff ff       	call   8001c0 <_panic>
        return envid;
	//panic("fork not implemented");
}
  8018e0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8018e3:	83 c4 3c             	add    $0x3c,%esp
  8018e6:	5b                   	pop    %ebx
  8018e7:	5e                   	pop    %esi
  8018e8:	5f                   	pop    %edi
  8018e9:	5d                   	pop    %ebp
  8018ea:	c3                   	ret    

008018eb <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  8018eb:	55                   	push   %ebp
  8018ec:	89 e5                	mov    %esp,%ebp
  8018ee:	53                   	push   %ebx
  8018ef:	83 ec 24             	sub    $0x24,%esp
  8018f2:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  8018f5:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at vpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        pte_t pte = vpt[PGNUM(addr)];
  8018f7:	89 da                	mov    %ebx,%edx
  8018f9:	c1 ea 0c             	shr    $0xc,%edx
  8018fc:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
//
static void
pgfault(struct UTrapframe *utf)
{
	void *addr = (void *) utf->utf_fault_va;
	uint32_t err = utf->utf_err;
  801903:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  801907:	74 08                	je     801911 <pgfault+0x26>
	//   Use the read-only page table mappings at vpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        pte_t pte = vpt[PGNUM(addr)];
        if((!(err & FEC_WR)) ||(!(pte & (PTE_P | PTE_U |PTE_COW))))
  801909:	f7 c2 05 08 00 00    	test   $0x805,%edx
  80190f:	75 1c                	jne    80192d <pgfault+0x42>
           panic("pgfault error");
  801911:	c7 44 24 08 c0 30 80 	movl   $0x8030c0,0x8(%esp)
  801918:	00 
  801919:	c7 44 24 04 1e 00 00 	movl   $0x1e,0x4(%esp)
  801920:	00 
  801921:	c7 04 24 61 30 80 00 	movl   $0x803061,(%esp)
  801928:	e8 93 e8 ff ff       	call   8001c0 <_panic>
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 4: Your code here.
        if ((r = sys_page_alloc(0, (void*)PFTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  80192d:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801934:	00 
  801935:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  80193c:	00 
  80193d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801944:	e8 8f fb ff ff       	call   8014d8 <sys_page_alloc>
  801949:	85 c0                	test   %eax,%eax
  80194b:	79 20                	jns    80196d <pgfault+0x82>
		panic("sys_page_alloc: %e", r);
  80194d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801951:	c7 44 24 08 ce 30 80 	movl   $0x8030ce,0x8(%esp)
  801958:	00 
  801959:	c7 44 24 04 29 00 00 	movl   $0x29,0x4(%esp)
  801960:	00 
  801961:	c7 04 24 61 30 80 00 	movl   $0x803061,(%esp)
  801968:	e8 53 e8 ff ff       	call   8001c0 <_panic>
        memmove(PFTEMP, (void*)((PGNUM(addr))<< PTXSHIFT), PGSIZE);
  80196d:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  801973:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  80197a:	00 
  80197b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80197f:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  801986:	e8 0a f4 ff ff       	call   800d95 <memmove>
	if ((r = sys_page_map(0, (void*)PFTEMP, 0, (void*)((PGNUM(addr))<< PTXSHIFT), PTE_P|PTE_U|PTE_W)) < 0)
  80198b:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801992:	00 
  801993:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801997:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80199e:	00 
  80199f:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8019a6:	00 
  8019a7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019ae:	e8 b7 fa ff ff       	call   80146a <sys_page_map>
  8019b3:	85 c0                	test   %eax,%eax
  8019b5:	79 20                	jns    8019d7 <pgfault+0xec>
		panic("sys_page_map: %e", r);	
  8019b7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8019bb:	c7 44 24 08 e1 30 80 	movl   $0x8030e1,0x8(%esp)
  8019c2:	00 
  8019c3:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  8019ca:	00 
  8019cb:	c7 04 24 61 30 80 00 	movl   $0x803061,(%esp)
  8019d2:	e8 e9 e7 ff ff       	call   8001c0 <_panic>
        if ((r = sys_page_unmap(0, PFTEMP)) < 0)
  8019d7:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8019de:	00 
  8019df:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019e6:	e8 13 fa ff ff       	call   8013fe <sys_page_unmap>
  8019eb:	85 c0                	test   %eax,%eax
  8019ed:	79 20                	jns    801a0f <pgfault+0x124>
		panic("sys_page_unmap: %e", r);
  8019ef:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8019f3:	c7 44 24 08 f2 30 80 	movl   $0x8030f2,0x8(%esp)
  8019fa:	00 
  8019fb:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
  801a02:	00 
  801a03:	c7 04 24 61 30 80 00 	movl   $0x803061,(%esp)
  801a0a:	e8 b1 e7 ff ff       	call   8001c0 <_panic>
	//panic("pgfault not implemented");
}
  801a0f:	83 c4 24             	add    $0x24,%esp
  801a12:	5b                   	pop    %ebx
  801a13:	5d                   	pop    %ebp
  801a14:	c3                   	ret    
	...

00801a20 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801a20:	55                   	push   %ebp
  801a21:	89 e5                	mov    %esp,%ebp
  801a23:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801a26:	8b 15 50 00 c0 ee    	mov    0xeec00050,%edx
  801a2c:	b8 01 00 00 00       	mov    $0x1,%eax
  801a31:	39 ca                	cmp    %ecx,%edx
  801a33:	75 04                	jne    801a39 <ipc_find_env+0x19>
  801a35:	b0 00                	mov    $0x0,%al
  801a37:	eb 12                	jmp    801a4b <ipc_find_env+0x2b>
  801a39:	89 c2                	mov    %eax,%edx
  801a3b:	c1 e2 07             	shl    $0x7,%edx
  801a3e:	8d 94 82 50 00 c0 ee 	lea    -0x113fffb0(%edx,%eax,4),%edx
  801a45:	8b 12                	mov    (%edx),%edx
  801a47:	39 ca                	cmp    %ecx,%edx
  801a49:	75 10                	jne    801a5b <ipc_find_env+0x3b>
			return envs[i].env_id;
  801a4b:	89 c2                	mov    %eax,%edx
  801a4d:	c1 e2 07             	shl    $0x7,%edx
  801a50:	8d 84 82 48 00 c0 ee 	lea    -0x113fffb8(%edx,%eax,4),%eax
  801a57:	8b 00                	mov    (%eax),%eax
  801a59:	eb 0e                	jmp    801a69 <ipc_find_env+0x49>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801a5b:	83 c0 01             	add    $0x1,%eax
  801a5e:	3d 00 04 00 00       	cmp    $0x400,%eax
  801a63:	75 d4                	jne    801a39 <ipc_find_env+0x19>
  801a65:	66 b8 00 00          	mov    $0x0,%ax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  801a69:	5d                   	pop    %ebp
  801a6a:	c3                   	ret    

00801a6b <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a6b:	55                   	push   %ebp
  801a6c:	89 e5                	mov    %esp,%ebp
  801a6e:	57                   	push   %edi
  801a6f:	56                   	push   %esi
  801a70:	53                   	push   %ebx
  801a71:	83 ec 1c             	sub    $0x1c,%esp
  801a74:	8b 75 08             	mov    0x8(%ebp),%esi
  801a77:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801a7a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        int ret;
        while(1){
           if(pg)
  801a7d:	85 db                	test   %ebx,%ebx
  801a7f:	74 19                	je     801a9a <ipc_send+0x2f>
              ret = sys_ipc_try_send(to_env,val,pg,perm);
  801a81:	8b 45 14             	mov    0x14(%ebp),%eax
  801a84:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801a88:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801a8c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801a90:	89 34 24             	mov    %esi,(%esp)
  801a93:	e8 e1 f7 ff ff       	call   801279 <sys_ipc_try_send>
  801a98:	eb 1b                	jmp    801ab5 <ipc_send+0x4a>
           else
              ret = sys_ipc_try_send(to_env,val,(void*)UTOP,perm);
  801a9a:	8b 45 14             	mov    0x14(%ebp),%eax
  801a9d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801aa1:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  801aa8:	ee 
  801aa9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801aad:	89 34 24             	mov    %esi,(%esp)
  801ab0:	e8 c4 f7 ff ff       	call   801279 <sys_ipc_try_send>
           if(ret == 0)
  801ab5:	85 c0                	test   %eax,%eax
  801ab7:	74 28                	je     801ae1 <ipc_send+0x76>
              return;
           if(ret != -E_IPC_NOT_RECV)
  801ab9:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801abc:	74 1c                	je     801ada <ipc_send+0x6f>
              panic("ipc send error");
  801abe:	c7 44 24 08 05 31 80 	movl   $0x803105,0x8(%esp)
  801ac5:	00 
  801ac6:	c7 44 24 04 46 00 00 	movl   $0x46,0x4(%esp)
  801acd:	00 
  801ace:	c7 04 24 14 31 80 00 	movl   $0x803114,(%esp)
  801ad5:	e8 e6 e6 ff ff       	call   8001c0 <_panic>
           sys_yield();
  801ada:	e8 66 fa ff ff       	call   801545 <sys_yield>
        }
  801adf:	eb 9c                	jmp    801a7d <ipc_send+0x12>
	//panic("ipc_send not implemented");
}
  801ae1:	83 c4 1c             	add    $0x1c,%esp
  801ae4:	5b                   	pop    %ebx
  801ae5:	5e                   	pop    %esi
  801ae6:	5f                   	pop    %edi
  801ae7:	5d                   	pop    %ebp
  801ae8:	c3                   	ret    

00801ae9 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801ae9:	55                   	push   %ebp
  801aea:	89 e5                	mov    %esp,%ebp
  801aec:	56                   	push   %esi
  801aed:	53                   	push   %ebx
  801aee:	83 ec 10             	sub    $0x10,%esp
  801af1:	8b 75 08             	mov    0x8(%ebp),%esi
  801af4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801af7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        int ret;
        if(!pg)
  801afa:	85 c0                	test   %eax,%eax
  801afc:	75 0e                	jne    801b0c <ipc_recv+0x23>
           ret = sys_ipc_recv((void*)UTOP);
  801afe:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  801b05:	e8 04 f7 ff ff       	call   80120e <sys_ipc_recv>
  801b0a:	eb 08                	jmp    801b14 <ipc_recv+0x2b>
        else
           ret = sys_ipc_recv(pg);
  801b0c:	89 04 24             	mov    %eax,(%esp)
  801b0f:	e8 fa f6 ff ff       	call   80120e <sys_ipc_recv>
        if(ret == 0){
  801b14:	85 c0                	test   %eax,%eax
  801b16:	75 26                	jne    801b3e <ipc_recv+0x55>
           if(from_env_store)
  801b18:	85 f6                	test   %esi,%esi
  801b1a:	74 0a                	je     801b26 <ipc_recv+0x3d>
              *from_env_store = thisenv->env_ipc_from;
  801b1c:	a1 08 50 80 00       	mov    0x805008,%eax
  801b21:	8b 40 78             	mov    0x78(%eax),%eax
  801b24:	89 06                	mov    %eax,(%esi)
           if(perm_store)
  801b26:	85 db                	test   %ebx,%ebx
  801b28:	74 0a                	je     801b34 <ipc_recv+0x4b>
              *perm_store = thisenv->env_ipc_perm;
  801b2a:	a1 08 50 80 00       	mov    0x805008,%eax
  801b2f:	8b 40 7c             	mov    0x7c(%eax),%eax
  801b32:	89 03                	mov    %eax,(%ebx)
           return thisenv->env_ipc_value;
  801b34:	a1 08 50 80 00       	mov    0x805008,%eax
  801b39:	8b 40 74             	mov    0x74(%eax),%eax
  801b3c:	eb 14                	jmp    801b52 <ipc_recv+0x69>
        }
        else{
           if(from_env_store)
  801b3e:	85 f6                	test   %esi,%esi
  801b40:	74 06                	je     801b48 <ipc_recv+0x5f>
              *from_env_store = 0;
  801b42:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
           if(perm_store)
  801b48:	85 db                	test   %ebx,%ebx
  801b4a:	74 06                	je     801b52 <ipc_recv+0x69>
              *perm_store = 0;
  801b4c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
           return ret;
        }
	//panic("ipc_recv not implemented");
	return 0;
}
  801b52:	83 c4 10             	add    $0x10,%esp
  801b55:	5b                   	pop    %ebx
  801b56:	5e                   	pop    %esi
  801b57:	5d                   	pop    %ebp
  801b58:	c3                   	ret    
  801b59:	00 00                	add    %al,(%eax)
  801b5b:	00 00                	add    %al,(%eax)
  801b5d:	00 00                	add    %al,(%eax)
	...

00801b60 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801b60:	55                   	push   %ebp
  801b61:	89 e5                	mov    %esp,%ebp
  801b63:	8b 45 08             	mov    0x8(%ebp),%eax
  801b66:	05 00 00 00 30       	add    $0x30000000,%eax
  801b6b:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  801b6e:	5d                   	pop    %ebp
  801b6f:	c3                   	ret    

00801b70 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801b70:	55                   	push   %ebp
  801b71:	89 e5                	mov    %esp,%ebp
  801b73:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801b76:	8b 45 08             	mov    0x8(%ebp),%eax
  801b79:	89 04 24             	mov    %eax,(%esp)
  801b7c:	e8 df ff ff ff       	call   801b60 <fd2num>
  801b81:	05 20 00 0d 00       	add    $0xd0020,%eax
  801b86:	c1 e0 0c             	shl    $0xc,%eax
}
  801b89:	c9                   	leave  
  801b8a:	c3                   	ret    

00801b8b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801b8b:	55                   	push   %ebp
  801b8c:	89 e5                	mov    %esp,%ebp
  801b8e:	57                   	push   %edi
  801b8f:	56                   	push   %esi
  801b90:	53                   	push   %ebx
  801b91:	8b 7d 08             	mov    0x8(%ebp),%edi
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  801b94:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  801b99:	a8 01                	test   $0x1,%al
  801b9b:	74 36                	je     801bd3 <fd_alloc+0x48>
  801b9d:	a1 00 00 74 ef       	mov    0xef740000,%eax
  801ba2:	a8 01                	test   $0x1,%al
  801ba4:	74 2d                	je     801bd3 <fd_alloc+0x48>
  801ba6:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  801bab:	b9 00 d0 7b ef       	mov    $0xef7bd000,%ecx
  801bb0:	be 00 00 40 ef       	mov    $0xef400000,%esi
  801bb5:	89 c3                	mov    %eax,%ebx
  801bb7:	89 c2                	mov    %eax,%edx
  801bb9:	c1 ea 16             	shr    $0x16,%edx
  801bbc:	8b 14 91             	mov    (%ecx,%edx,4),%edx
  801bbf:	f6 c2 01             	test   $0x1,%dl
  801bc2:	74 14                	je     801bd8 <fd_alloc+0x4d>
  801bc4:	89 c2                	mov    %eax,%edx
  801bc6:	c1 ea 0c             	shr    $0xc,%edx
  801bc9:	8b 14 96             	mov    (%esi,%edx,4),%edx
  801bcc:	f6 c2 01             	test   $0x1,%dl
  801bcf:	75 10                	jne    801be1 <fd_alloc+0x56>
  801bd1:	eb 05                	jmp    801bd8 <fd_alloc+0x4d>
  801bd3:	bb 00 00 00 d0       	mov    $0xd0000000,%ebx
			*fd_store = fd;
  801bd8:	89 1f                	mov    %ebx,(%edi)
  801bda:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  801bdf:	eb 17                	jmp    801bf8 <fd_alloc+0x6d>
  801be1:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801be6:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801beb:	75 c8                	jne    801bb5 <fd_alloc+0x2a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801bed:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  801bf3:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  801bf8:	5b                   	pop    %ebx
  801bf9:	5e                   	pop    %esi
  801bfa:	5f                   	pop    %edi
  801bfb:	5d                   	pop    %ebp
  801bfc:	c3                   	ret    

00801bfd <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801bfd:	55                   	push   %ebp
  801bfe:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801c00:	8b 45 08             	mov    0x8(%ebp),%eax
  801c03:	83 f8 1f             	cmp    $0x1f,%eax
  801c06:	77 36                	ja     801c3e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801c08:	05 00 00 0d 00       	add    $0xd0000,%eax
  801c0d:	c1 e0 0c             	shl    $0xc,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
  801c10:	89 c2                	mov    %eax,%edx
  801c12:	c1 ea 16             	shr    $0x16,%edx
  801c15:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801c1c:	f6 c2 01             	test   $0x1,%dl
  801c1f:	74 1d                	je     801c3e <fd_lookup+0x41>
  801c21:	89 c2                	mov    %eax,%edx
  801c23:	c1 ea 0c             	shr    $0xc,%edx
  801c26:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801c2d:	f6 c2 01             	test   $0x1,%dl
  801c30:	74 0c                	je     801c3e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  801c32:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c35:	89 02                	mov    %eax,(%edx)
  801c37:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
  801c3c:	eb 05                	jmp    801c43 <fd_lookup+0x46>
  801c3e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801c43:	5d                   	pop    %ebp
  801c44:	c3                   	ret    

00801c45 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  801c45:	55                   	push   %ebp
  801c46:	89 e5                	mov    %esp,%ebp
  801c48:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c4b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801c4e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c52:	8b 45 08             	mov    0x8(%ebp),%eax
  801c55:	89 04 24             	mov    %eax,(%esp)
  801c58:	e8 a0 ff ff ff       	call   801bfd <fd_lookup>
  801c5d:	85 c0                	test   %eax,%eax
  801c5f:	78 0e                	js     801c6f <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801c61:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801c64:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c67:	89 50 04             	mov    %edx,0x4(%eax)
  801c6a:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  801c6f:	c9                   	leave  
  801c70:	c3                   	ret    

00801c71 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801c71:	55                   	push   %ebp
  801c72:	89 e5                	mov    %esp,%ebp
  801c74:	56                   	push   %esi
  801c75:	53                   	push   %ebx
  801c76:	83 ec 10             	sub    $0x10,%esp
  801c79:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c7c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
// File functions
// --------------------------------------------------------------

static struct Dev *devtab[] =
{
	&devfile,
  801c7f:	b8 04 40 80 00       	mov    $0x804004,%eax
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  801c84:	ba 00 00 00 00       	mov    $0x0,%edx

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801c89:	be a0 31 80 00       	mov    $0x8031a0,%esi
		if (devtab[i]->dev_id == dev_id) {
  801c8e:	39 08                	cmp    %ecx,(%eax)
  801c90:	75 10                	jne    801ca2 <dev_lookup+0x31>
  801c92:	eb 04                	jmp    801c98 <dev_lookup+0x27>
  801c94:	39 08                	cmp    %ecx,(%eax)
  801c96:	75 0a                	jne    801ca2 <dev_lookup+0x31>
			*dev = devtab[i];
  801c98:	89 03                	mov    %eax,(%ebx)
  801c9a:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  801c9f:	90                   	nop
  801ca0:	eb 31                	jmp    801cd3 <dev_lookup+0x62>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801ca2:	83 c2 01             	add    $0x1,%edx
  801ca5:	8b 04 96             	mov    (%esi,%edx,4),%eax
  801ca8:	85 c0                	test   %eax,%eax
  801caa:	75 e8                	jne    801c94 <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801cac:	a1 08 50 80 00       	mov    0x805008,%eax
  801cb1:	8b 40 48             	mov    0x48(%eax),%eax
  801cb4:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801cb8:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cbc:	c7 04 24 20 31 80 00 	movl   $0x803120,(%esp)
  801cc3:	e8 b1 e5 ff ff       	call   800279 <cprintf>
	*dev = 0;
  801cc8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801cce:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  801cd3:	83 c4 10             	add    $0x10,%esp
  801cd6:	5b                   	pop    %ebx
  801cd7:	5e                   	pop    %esi
  801cd8:	5d                   	pop    %ebp
  801cd9:	c3                   	ret    

00801cda <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  801cda:	55                   	push   %ebp
  801cdb:	89 e5                	mov    %esp,%ebp
  801cdd:	53                   	push   %ebx
  801cde:	83 ec 24             	sub    $0x24,%esp
  801ce1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801ce4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801ce7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ceb:	8b 45 08             	mov    0x8(%ebp),%eax
  801cee:	89 04 24             	mov    %eax,(%esp)
  801cf1:	e8 07 ff ff ff       	call   801bfd <fd_lookup>
  801cf6:	85 c0                	test   %eax,%eax
  801cf8:	78 53                	js     801d4d <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801cfa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cfd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d01:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d04:	8b 00                	mov    (%eax),%eax
  801d06:	89 04 24             	mov    %eax,(%esp)
  801d09:	e8 63 ff ff ff       	call   801c71 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801d0e:	85 c0                	test   %eax,%eax
  801d10:	78 3b                	js     801d4d <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  801d12:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801d17:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801d1a:	83 7a 14 00          	cmpl   $0x0,0x14(%edx)
  801d1e:	74 2d                	je     801d4d <fstat+0x73>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801d20:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801d23:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801d2a:	00 00 00 
	stat->st_isdir = 0;
  801d2d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801d34:	00 00 00 
	stat->st_dev = dev;
  801d37:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d3a:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801d40:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801d44:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801d47:	89 14 24             	mov    %edx,(%esp)
  801d4a:	ff 50 14             	call   *0x14(%eax)
}
  801d4d:	83 c4 24             	add    $0x24,%esp
  801d50:	5b                   	pop    %ebx
  801d51:	5d                   	pop    %ebp
  801d52:	c3                   	ret    

00801d53 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  801d53:	55                   	push   %ebp
  801d54:	89 e5                	mov    %esp,%ebp
  801d56:	53                   	push   %ebx
  801d57:	83 ec 24             	sub    $0x24,%esp
  801d5a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801d5d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d60:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d64:	89 1c 24             	mov    %ebx,(%esp)
  801d67:	e8 91 fe ff ff       	call   801bfd <fd_lookup>
  801d6c:	85 c0                	test   %eax,%eax
  801d6e:	78 5f                	js     801dcf <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801d70:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d73:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d77:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d7a:	8b 00                	mov    (%eax),%eax
  801d7c:	89 04 24             	mov    %eax,(%esp)
  801d7f:	e8 ed fe ff ff       	call   801c71 <dev_lookup>
ftruncate(int fdnum, off_t newsize)
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801d84:	85 c0                	test   %eax,%eax
  801d86:	78 47                	js     801dcf <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801d88:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801d8b:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  801d8f:	75 23                	jne    801db4 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801d91:	a1 08 50 80 00       	mov    0x805008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801d96:	8b 40 48             	mov    0x48(%eax),%eax
  801d99:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801d9d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801da1:	c7 04 24 40 31 80 00 	movl   $0x803140,(%esp)
  801da8:	e8 cc e4 ff ff       	call   800279 <cprintf>
  801dad:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801db2:	eb 1b                	jmp    801dcf <ftruncate+0x7c>
	}
	if (!dev->dev_trunc)
  801db4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801db7:	8b 48 18             	mov    0x18(%eax),%ecx
  801dba:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801dbf:	85 c9                	test   %ecx,%ecx
  801dc1:	74 0c                	je     801dcf <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801dc3:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dc6:	89 44 24 04          	mov    %eax,0x4(%esp)
  801dca:	89 14 24             	mov    %edx,(%esp)
  801dcd:	ff d1                	call   *%ecx
}
  801dcf:	83 c4 24             	add    $0x24,%esp
  801dd2:	5b                   	pop    %ebx
  801dd3:	5d                   	pop    %ebp
  801dd4:	c3                   	ret    

00801dd5 <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801dd5:	55                   	push   %ebp
  801dd6:	89 e5                	mov    %esp,%ebp
  801dd8:	53                   	push   %ebx
  801dd9:	83 ec 24             	sub    $0x24,%esp
  801ddc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801ddf:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801de2:	89 44 24 04          	mov    %eax,0x4(%esp)
  801de6:	89 1c 24             	mov    %ebx,(%esp)
  801de9:	e8 0f fe ff ff       	call   801bfd <fd_lookup>
  801dee:	85 c0                	test   %eax,%eax
  801df0:	78 66                	js     801e58 <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801df2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801df5:	89 44 24 04          	mov    %eax,0x4(%esp)
  801df9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801dfc:	8b 00                	mov    (%eax),%eax
  801dfe:	89 04 24             	mov    %eax,(%esp)
  801e01:	e8 6b fe ff ff       	call   801c71 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801e06:	85 c0                	test   %eax,%eax
  801e08:	78 4e                	js     801e58 <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801e0a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801e0d:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  801e11:	75 23                	jne    801e36 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801e13:	a1 08 50 80 00       	mov    0x805008,%eax
  801e18:	8b 40 48             	mov    0x48(%eax),%eax
  801e1b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801e1f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e23:	c7 04 24 64 31 80 00 	movl   $0x803164,(%esp)
  801e2a:	e8 4a e4 ff ff       	call   800279 <cprintf>
  801e2f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801e34:	eb 22                	jmp    801e58 <write+0x83>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801e36:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e39:	8b 48 0c             	mov    0xc(%eax),%ecx
  801e3c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801e41:	85 c9                	test   %ecx,%ecx
  801e43:	74 13                	je     801e58 <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801e45:	8b 45 10             	mov    0x10(%ebp),%eax
  801e48:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e4c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e4f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e53:	89 14 24             	mov    %edx,(%esp)
  801e56:	ff d1                	call   *%ecx
}
  801e58:	83 c4 24             	add    $0x24,%esp
  801e5b:	5b                   	pop    %ebx
  801e5c:	5d                   	pop    %ebp
  801e5d:	c3                   	ret    

00801e5e <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801e5e:	55                   	push   %ebp
  801e5f:	89 e5                	mov    %esp,%ebp
  801e61:	53                   	push   %ebx
  801e62:	83 ec 24             	sub    $0x24,%esp
  801e65:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801e68:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801e6b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e6f:	89 1c 24             	mov    %ebx,(%esp)
  801e72:	e8 86 fd ff ff       	call   801bfd <fd_lookup>
  801e77:	85 c0                	test   %eax,%eax
  801e79:	78 6b                	js     801ee6 <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801e7b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e7e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e82:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e85:	8b 00                	mov    (%eax),%eax
  801e87:	89 04 24             	mov    %eax,(%esp)
  801e8a:	e8 e2 fd ff ff       	call   801c71 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801e8f:	85 c0                	test   %eax,%eax
  801e91:	78 53                	js     801ee6 <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801e93:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801e96:	8b 42 08             	mov    0x8(%edx),%eax
  801e99:	83 e0 03             	and    $0x3,%eax
  801e9c:	83 f8 01             	cmp    $0x1,%eax
  801e9f:	75 23                	jne    801ec4 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801ea1:	a1 08 50 80 00       	mov    0x805008,%eax
  801ea6:	8b 40 48             	mov    0x48(%eax),%eax
  801ea9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801ead:	89 44 24 04          	mov    %eax,0x4(%esp)
  801eb1:	c7 04 24 81 31 80 00 	movl   $0x803181,(%esp)
  801eb8:	e8 bc e3 ff ff       	call   800279 <cprintf>
  801ebd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801ec2:	eb 22                	jmp    801ee6 <read+0x88>
	}
	if (!dev->dev_read)
  801ec4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ec7:	8b 48 08             	mov    0x8(%eax),%ecx
  801eca:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801ecf:	85 c9                	test   %ecx,%ecx
  801ed1:	74 13                	je     801ee6 <read+0x88>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801ed3:	8b 45 10             	mov    0x10(%ebp),%eax
  801ed6:	89 44 24 08          	mov    %eax,0x8(%esp)
  801eda:	8b 45 0c             	mov    0xc(%ebp),%eax
  801edd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ee1:	89 14 24             	mov    %edx,(%esp)
  801ee4:	ff d1                	call   *%ecx
}
  801ee6:	83 c4 24             	add    $0x24,%esp
  801ee9:	5b                   	pop    %ebx
  801eea:	5d                   	pop    %ebp
  801eeb:	c3                   	ret    

00801eec <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801eec:	55                   	push   %ebp
  801eed:	89 e5                	mov    %esp,%ebp
  801eef:	57                   	push   %edi
  801ef0:	56                   	push   %esi
  801ef1:	53                   	push   %ebx
  801ef2:	83 ec 1c             	sub    $0x1c,%esp
  801ef5:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ef8:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801efb:	ba 00 00 00 00       	mov    $0x0,%edx
  801f00:	bb 00 00 00 00       	mov    $0x0,%ebx
  801f05:	b8 00 00 00 00       	mov    $0x0,%eax
  801f0a:	85 f6                	test   %esi,%esi
  801f0c:	74 29                	je     801f37 <readn+0x4b>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801f0e:	89 f0                	mov    %esi,%eax
  801f10:	29 d0                	sub    %edx,%eax
  801f12:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f16:	03 55 0c             	add    0xc(%ebp),%edx
  801f19:	89 54 24 04          	mov    %edx,0x4(%esp)
  801f1d:	89 3c 24             	mov    %edi,(%esp)
  801f20:	e8 39 ff ff ff       	call   801e5e <read>
		if (m < 0)
  801f25:	85 c0                	test   %eax,%eax
  801f27:	78 0e                	js     801f37 <readn+0x4b>
			return m;
		if (m == 0)
  801f29:	85 c0                	test   %eax,%eax
  801f2b:	74 08                	je     801f35 <readn+0x49>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801f2d:	01 c3                	add    %eax,%ebx
  801f2f:	89 da                	mov    %ebx,%edx
  801f31:	39 f3                	cmp    %esi,%ebx
  801f33:	72 d9                	jb     801f0e <readn+0x22>
  801f35:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801f37:	83 c4 1c             	add    $0x1c,%esp
  801f3a:	5b                   	pop    %ebx
  801f3b:	5e                   	pop    %esi
  801f3c:	5f                   	pop    %edi
  801f3d:	5d                   	pop    %ebp
  801f3e:	c3                   	ret    

00801f3f <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801f3f:	55                   	push   %ebp
  801f40:	89 e5                	mov    %esp,%ebp
  801f42:	56                   	push   %esi
  801f43:	53                   	push   %ebx
  801f44:	83 ec 20             	sub    $0x20,%esp
  801f47:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801f4a:	89 34 24             	mov    %esi,(%esp)
  801f4d:	e8 0e fc ff ff       	call   801b60 <fd2num>
  801f52:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801f55:	89 54 24 04          	mov    %edx,0x4(%esp)
  801f59:	89 04 24             	mov    %eax,(%esp)
  801f5c:	e8 9c fc ff ff       	call   801bfd <fd_lookup>
  801f61:	89 c3                	mov    %eax,%ebx
  801f63:	85 c0                	test   %eax,%eax
  801f65:	78 05                	js     801f6c <fd_close+0x2d>
  801f67:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801f6a:	74 0c                	je     801f78 <fd_close+0x39>
	    || fd != fd2)
		return (must_exist ? r : 0);
  801f6c:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  801f70:	19 c0                	sbb    %eax,%eax
  801f72:	f7 d0                	not    %eax
  801f74:	21 c3                	and    %eax,%ebx
  801f76:	eb 3d                	jmp    801fb5 <fd_close+0x76>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801f78:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801f7b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f7f:	8b 06                	mov    (%esi),%eax
  801f81:	89 04 24             	mov    %eax,(%esp)
  801f84:	e8 e8 fc ff ff       	call   801c71 <dev_lookup>
  801f89:	89 c3                	mov    %eax,%ebx
  801f8b:	85 c0                	test   %eax,%eax
  801f8d:	78 16                	js     801fa5 <fd_close+0x66>
		if (dev->dev_close)
  801f8f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f92:	8b 40 10             	mov    0x10(%eax),%eax
  801f95:	bb 00 00 00 00       	mov    $0x0,%ebx
  801f9a:	85 c0                	test   %eax,%eax
  801f9c:	74 07                	je     801fa5 <fd_close+0x66>
			r = (*dev->dev_close)(fd);
  801f9e:	89 34 24             	mov    %esi,(%esp)
  801fa1:	ff d0                	call   *%eax
  801fa3:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801fa5:	89 74 24 04          	mov    %esi,0x4(%esp)
  801fa9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801fb0:	e8 49 f4 ff ff       	call   8013fe <sys_page_unmap>
	return r;
}
  801fb5:	89 d8                	mov    %ebx,%eax
  801fb7:	83 c4 20             	add    $0x20,%esp
  801fba:	5b                   	pop    %ebx
  801fbb:	5e                   	pop    %esi
  801fbc:	5d                   	pop    %ebp
  801fbd:	c3                   	ret    

00801fbe <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801fbe:	55                   	push   %ebp
  801fbf:	89 e5                	mov    %esp,%ebp
  801fc1:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801fc4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fc7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fcb:	8b 45 08             	mov    0x8(%ebp),%eax
  801fce:	89 04 24             	mov    %eax,(%esp)
  801fd1:	e8 27 fc ff ff       	call   801bfd <fd_lookup>
  801fd6:	85 c0                	test   %eax,%eax
  801fd8:	78 13                	js     801fed <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801fda:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801fe1:	00 
  801fe2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fe5:	89 04 24             	mov    %eax,(%esp)
  801fe8:	e8 52 ff ff ff       	call   801f3f <fd_close>
}
  801fed:	c9                   	leave  
  801fee:	c3                   	ret    

00801fef <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  801fef:	55                   	push   %ebp
  801ff0:	89 e5                	mov    %esp,%ebp
  801ff2:	83 ec 18             	sub    $0x18,%esp
  801ff5:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801ff8:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801ffb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  802002:	00 
  802003:	8b 45 08             	mov    0x8(%ebp),%eax
  802006:	89 04 24             	mov    %eax,(%esp)
  802009:	e8 79 03 00 00       	call   802387 <open>
  80200e:	89 c3                	mov    %eax,%ebx
  802010:	85 c0                	test   %eax,%eax
  802012:	78 1b                	js     80202f <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  802014:	8b 45 0c             	mov    0xc(%ebp),%eax
  802017:	89 44 24 04          	mov    %eax,0x4(%esp)
  80201b:	89 1c 24             	mov    %ebx,(%esp)
  80201e:	e8 b7 fc ff ff       	call   801cda <fstat>
  802023:	89 c6                	mov    %eax,%esi
	close(fd);
  802025:	89 1c 24             	mov    %ebx,(%esp)
  802028:	e8 91 ff ff ff       	call   801fbe <close>
  80202d:	89 f3                	mov    %esi,%ebx
	return r;
}
  80202f:	89 d8                	mov    %ebx,%eax
  802031:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  802034:	8b 75 fc             	mov    -0x4(%ebp),%esi
  802037:	89 ec                	mov    %ebp,%esp
  802039:	5d                   	pop    %ebp
  80203a:	c3                   	ret    

0080203b <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  80203b:	55                   	push   %ebp
  80203c:	89 e5                	mov    %esp,%ebp
  80203e:	53                   	push   %ebx
  80203f:	83 ec 14             	sub    $0x14,%esp
  802042:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  802047:	89 1c 24             	mov    %ebx,(%esp)
  80204a:	e8 6f ff ff ff       	call   801fbe <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80204f:	83 c3 01             	add    $0x1,%ebx
  802052:	83 fb 20             	cmp    $0x20,%ebx
  802055:	75 f0                	jne    802047 <close_all+0xc>
		close(i);
}
  802057:	83 c4 14             	add    $0x14,%esp
  80205a:	5b                   	pop    %ebx
  80205b:	5d                   	pop    %ebp
  80205c:	c3                   	ret    

0080205d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80205d:	55                   	push   %ebp
  80205e:	89 e5                	mov    %esp,%ebp
  802060:	83 ec 58             	sub    $0x58,%esp
  802063:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  802066:	89 75 f8             	mov    %esi,-0x8(%ebp)
  802069:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80206c:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80206f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  802072:	89 44 24 04          	mov    %eax,0x4(%esp)
  802076:	8b 45 08             	mov    0x8(%ebp),%eax
  802079:	89 04 24             	mov    %eax,(%esp)
  80207c:	e8 7c fb ff ff       	call   801bfd <fd_lookup>
  802081:	89 c3                	mov    %eax,%ebx
  802083:	85 c0                	test   %eax,%eax
  802085:	0f 88 e0 00 00 00    	js     80216b <dup+0x10e>
		return r;
	close(newfdnum);
  80208b:	89 3c 24             	mov    %edi,(%esp)
  80208e:	e8 2b ff ff ff       	call   801fbe <close>

	newfd = INDEX2FD(newfdnum);
  802093:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  802099:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  80209c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80209f:	89 04 24             	mov    %eax,(%esp)
  8020a2:	e8 c9 fa ff ff       	call   801b70 <fd2data>
  8020a7:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8020a9:	89 34 24             	mov    %esi,(%esp)
  8020ac:	e8 bf fa ff ff       	call   801b70 <fd2data>
  8020b1:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
  8020b4:	89 da                	mov    %ebx,%edx
  8020b6:	89 d8                	mov    %ebx,%eax
  8020b8:	c1 e8 16             	shr    $0x16,%eax
  8020bb:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8020c2:	a8 01                	test   $0x1,%al
  8020c4:	74 43                	je     802109 <dup+0xac>
  8020c6:	c1 ea 0c             	shr    $0xc,%edx
  8020c9:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  8020d0:	a8 01                	test   $0x1,%al
  8020d2:	74 35                	je     802109 <dup+0xac>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8020d4:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  8020db:	25 07 0e 00 00       	and    $0xe07,%eax
  8020e0:	89 44 24 10          	mov    %eax,0x10(%esp)
  8020e4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8020e7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8020eb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8020f2:	00 
  8020f3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8020f7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020fe:	e8 67 f3 ff ff       	call   80146a <sys_page_map>
  802103:	89 c3                	mov    %eax,%ebx
  802105:	85 c0                	test   %eax,%eax
  802107:	78 3f                	js     802148 <dup+0xeb>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  802109:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80210c:	89 c2                	mov    %eax,%edx
  80210e:	c1 ea 0c             	shr    $0xc,%edx
  802111:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  802118:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  80211e:	89 54 24 10          	mov    %edx,0x10(%esp)
  802122:	89 74 24 0c          	mov    %esi,0xc(%esp)
  802126:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80212d:	00 
  80212e:	89 44 24 04          	mov    %eax,0x4(%esp)
  802132:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802139:	e8 2c f3 ff ff       	call   80146a <sys_page_map>
  80213e:	89 c3                	mov    %eax,%ebx
  802140:	85 c0                	test   %eax,%eax
  802142:	78 04                	js     802148 <dup+0xeb>
  802144:	89 fb                	mov    %edi,%ebx
  802146:	eb 23                	jmp    80216b <dup+0x10e>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  802148:	89 74 24 04          	mov    %esi,0x4(%esp)
  80214c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802153:	e8 a6 f2 ff ff       	call   8013fe <sys_page_unmap>
	sys_page_unmap(0, nva);
  802158:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80215b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80215f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802166:	e8 93 f2 ff ff       	call   8013fe <sys_page_unmap>
	return r;
}
  80216b:	89 d8                	mov    %ebx,%eax
  80216d:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  802170:	8b 75 f8             	mov    -0x8(%ebp),%esi
  802173:	8b 7d fc             	mov    -0x4(%ebp),%edi
  802176:	89 ec                	mov    %ebp,%esp
  802178:	5d                   	pop    %ebp
  802179:	c3                   	ret    
	...

0080217c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80217c:	55                   	push   %ebp
  80217d:	89 e5                	mov    %esp,%ebp
  80217f:	83 ec 18             	sub    $0x18,%esp
  802182:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  802185:	89 75 fc             	mov    %esi,-0x4(%ebp)
  802188:	89 c3                	mov    %eax,%ebx
  80218a:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  80218c:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  802193:	75 11                	jne    8021a6 <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  802195:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  80219c:	e8 7f f8 ff ff       	call   801a20 <ipc_find_env>
  8021a1:	a3 00 50 80 00       	mov    %eax,0x805000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8021a6:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8021ad:	00 
  8021ae:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  8021b5:	00 
  8021b6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8021ba:	a1 00 50 80 00       	mov    0x805000,%eax
  8021bf:	89 04 24             	mov    %eax,(%esp)
  8021c2:	e8 a4 f8 ff ff       	call   801a6b <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8021c7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8021ce:	00 
  8021cf:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021d3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8021da:	e8 0a f9 ff ff       	call   801ae9 <ipc_recv>
}
  8021df:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8021e2:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8021e5:	89 ec                	mov    %ebp,%esp
  8021e7:	5d                   	pop    %ebp
  8021e8:	c3                   	ret    

008021e9 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8021e9:	55                   	push   %ebp
  8021ea:	89 e5                	mov    %esp,%ebp
  8021ec:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8021ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8021f2:	8b 40 0c             	mov    0xc(%eax),%eax
  8021f5:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  8021fa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021fd:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  802202:	ba 00 00 00 00       	mov    $0x0,%edx
  802207:	b8 02 00 00 00       	mov    $0x2,%eax
  80220c:	e8 6b ff ff ff       	call   80217c <fsipc>
}
  802211:	c9                   	leave  
  802212:	c3                   	ret    

00802213 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  802213:	55                   	push   %ebp
  802214:	89 e5                	mov    %esp,%ebp
  802216:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  802219:	8b 45 08             	mov    0x8(%ebp),%eax
  80221c:	8b 40 0c             	mov    0xc(%eax),%eax
  80221f:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  802224:	ba 00 00 00 00       	mov    $0x0,%edx
  802229:	b8 06 00 00 00       	mov    $0x6,%eax
  80222e:	e8 49 ff ff ff       	call   80217c <fsipc>
}
  802233:	c9                   	leave  
  802234:	c3                   	ret    

00802235 <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  802235:	55                   	push   %ebp
  802236:	89 e5                	mov    %esp,%ebp
  802238:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80223b:	ba 00 00 00 00       	mov    $0x0,%edx
  802240:	b8 08 00 00 00       	mov    $0x8,%eax
  802245:	e8 32 ff ff ff       	call   80217c <fsipc>
}
  80224a:	c9                   	leave  
  80224b:	c3                   	ret    

0080224c <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80224c:	55                   	push   %ebp
  80224d:	89 e5                	mov    %esp,%ebp
  80224f:	53                   	push   %ebx
  802250:	83 ec 14             	sub    $0x14,%esp
  802253:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  802256:	8b 45 08             	mov    0x8(%ebp),%eax
  802259:	8b 40 0c             	mov    0xc(%eax),%eax
  80225c:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  802261:	ba 00 00 00 00       	mov    $0x0,%edx
  802266:	b8 05 00 00 00       	mov    $0x5,%eax
  80226b:	e8 0c ff ff ff       	call   80217c <fsipc>
  802270:	85 c0                	test   %eax,%eax
  802272:	78 2b                	js     80229f <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  802274:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  80227b:	00 
  80227c:	89 1c 24             	mov    %ebx,(%esp)
  80227f:	e8 26 e9 ff ff       	call   800baa <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  802284:	a1 80 60 80 00       	mov    0x806080,%eax
  802289:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80228f:	a1 84 60 80 00       	mov    0x806084,%eax
  802294:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  80229a:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  80229f:	83 c4 14             	add    $0x14,%esp
  8022a2:	5b                   	pop    %ebx
  8022a3:	5d                   	pop    %ebp
  8022a4:	c3                   	ret    

008022a5 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8022a5:	55                   	push   %ebp
  8022a6:	89 e5                	mov    %esp,%ebp
  8022a8:	83 ec 18             	sub    $0x18,%esp
  8022ab:	8b 45 10             	mov    0x10(%ebp),%eax
  8022ae:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8022b3:	76 05                	jbe    8022ba <devfile_write+0x15>
  8022b5:	b8 f8 0f 00 00       	mov    $0xff8,%eax
	// bytes than requested.
	// LAB 5: Your code here
        int r;
        if(n > sizeof(fsipcbuf.write.req_buf))
            n = sizeof(fsipcbuf.write.req_buf);
        fsipcbuf.write.req_fileid = fd->fd_file.id;
  8022ba:	8b 55 08             	mov    0x8(%ebp),%edx
  8022bd:	8b 52 0c             	mov    0xc(%edx),%edx
  8022c0:	89 15 00 60 80 00    	mov    %edx,0x806000
        fsipcbuf.write.req_n = n;
  8022c6:	a3 04 60 80 00       	mov    %eax,0x806004
        memmove(fsipcbuf.write.req_buf,buf,n);  
  8022cb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8022cf:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022d2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022d6:	c7 04 24 08 60 80 00 	movl   $0x806008,(%esp)
  8022dd:	e8 b3 ea ff ff       	call   800d95 <memmove>
        r = fsipc(FSREQ_WRITE,NULL);
  8022e2:	ba 00 00 00 00       	mov    $0x0,%edx
  8022e7:	b8 04 00 00 00       	mov    $0x4,%eax
  8022ec:	e8 8b fe ff ff       	call   80217c <fsipc>
        return r;
	//panic("devfile_write not implemented");
}
  8022f1:	c9                   	leave  
  8022f2:	c3                   	ret    

008022f3 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8022f3:	55                   	push   %ebp
  8022f4:	89 e5                	mov    %esp,%ebp
  8022f6:	53                   	push   %ebx
  8022f7:	83 ec 14             	sub    $0x14,%esp
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
        int r;
        fsipcbuf.read.req_fileid = fd->fd_file.id;
  8022fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8022fd:	8b 40 0c             	mov    0xc(%eax),%eax
  802300:	a3 00 60 80 00       	mov    %eax,0x806000
        fsipcbuf.read.req_n = n;
  802305:	8b 45 10             	mov    0x10(%ebp),%eax
  802308:	a3 04 60 80 00       	mov    %eax,0x806004
        r = fsipc(FSREQ_READ,NULL);
  80230d:	ba 00 00 00 00       	mov    $0x0,%edx
  802312:	b8 03 00 00 00       	mov    $0x3,%eax
  802317:	e8 60 fe ff ff       	call   80217c <fsipc>
  80231c:	89 c3                	mov    %eax,%ebx
        if(r < 0)
  80231e:	85 c0                	test   %eax,%eax
  802320:	78 17                	js     802339 <devfile_read+0x46>
           return r;
        memmove(buf,fsipcbuf.readRet.ret_buf,r);
  802322:	89 44 24 08          	mov    %eax,0x8(%esp)
  802326:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  80232d:	00 
  80232e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802331:	89 04 24             	mov    %eax,(%esp)
  802334:	e8 5c ea ff ff       	call   800d95 <memmove>
        return r;
	//panic("devfile_read not implemented");
}
  802339:	89 d8                	mov    %ebx,%eax
  80233b:	83 c4 14             	add    $0x14,%esp
  80233e:	5b                   	pop    %ebx
  80233f:	5d                   	pop    %ebp
  802340:	c3                   	ret    

00802341 <remove>:
}

// Delete a file
int
remove(const char *path)
{
  802341:	55                   	push   %ebp
  802342:	89 e5                	mov    %esp,%ebp
  802344:	53                   	push   %ebx
  802345:	83 ec 14             	sub    $0x14,%esp
  802348:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  80234b:	89 1c 24             	mov    %ebx,(%esp)
  80234e:	e8 0d e8 ff ff       	call   800b60 <strlen>
  802353:	89 c2                	mov    %eax,%edx
  802355:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  80235a:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
  802360:	7f 1f                	jg     802381 <remove+0x40>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  802362:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802366:	c7 04 24 00 60 80 00 	movl   $0x806000,(%esp)
  80236d:	e8 38 e8 ff ff       	call   800baa <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  802372:	ba 00 00 00 00       	mov    $0x0,%edx
  802377:	b8 07 00 00 00       	mov    $0x7,%eax
  80237c:	e8 fb fd ff ff       	call   80217c <fsipc>
}
  802381:	83 c4 14             	add    $0x14,%esp
  802384:	5b                   	pop    %ebx
  802385:	5d                   	pop    %ebp
  802386:	c3                   	ret    

00802387 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  802387:	55                   	push   %ebp
  802388:	89 e5                	mov    %esp,%ebp
  80238a:	83 ec 28             	sub    $0x28,%esp
  80238d:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  802390:	89 75 fc             	mov    %esi,-0x4(%ebp)
  802393:	8b 75 08             	mov    0x8(%ebp),%esi
	// If any step after fd_alloc fails, use fd_close to free the
	// file descriptor.

	// LAB 5: Your code here.
        struct Fd* fd;
        if(strlen(path) > MAXPATHLEN)
  802396:	89 34 24             	mov    %esi,(%esp)
  802399:	e8 c2 e7 ff ff       	call   800b60 <strlen>
  80239e:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  8023a3:	3d 00 04 00 00       	cmp    $0x400,%eax
  8023a8:	7f 6d                	jg     802417 <open+0x90>
            return -E_BAD_PATH;
        int r;
        r = fd_alloc(&fd);
  8023aa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8023ad:	89 04 24             	mov    %eax,(%esp)
  8023b0:	e8 d6 f7 ff ff       	call   801b8b <fd_alloc>
  8023b5:	89 c3                	mov    %eax,%ebx
        if(r < 0)
  8023b7:	85 c0                	test   %eax,%eax
  8023b9:	78 5c                	js     802417 <open+0x90>
           return r;
        fsipcbuf.open.req_omode = mode;
  8023bb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8023be:	a3 00 64 80 00       	mov    %eax,0x806400
        memmove(fsipcbuf.open.req_path,path,strlen(path)+1);
  8023c3:	89 34 24             	mov    %esi,(%esp)
  8023c6:	e8 95 e7 ff ff       	call   800b60 <strlen>
  8023cb:	83 c0 01             	add    $0x1,%eax
  8023ce:	89 44 24 08          	mov    %eax,0x8(%esp)
  8023d2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8023d6:	c7 04 24 00 60 80 00 	movl   $0x806000,(%esp)
  8023dd:	e8 b3 e9 ff ff       	call   800d95 <memmove>
        r = fsipc(FSREQ_OPEN,(void*)fd);
  8023e2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8023e5:	b8 01 00 00 00       	mov    $0x1,%eax
  8023ea:	e8 8d fd ff ff       	call   80217c <fsipc>
  8023ef:	89 c3                	mov    %eax,%ebx
        if(r < 0){
  8023f1:	85 c0                	test   %eax,%eax
  8023f3:	79 15                	jns    80240a <open+0x83>
             fd_close(fd,0);
  8023f5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8023fc:	00 
  8023fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802400:	89 04 24             	mov    %eax,(%esp)
  802403:	e8 37 fb ff ff       	call   801f3f <fd_close>
             return r;
  802408:	eb 0d                	jmp    802417 <open+0x90>
        }
        return fd2num(fd);
  80240a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80240d:	89 04 24             	mov    %eax,(%esp)
  802410:	e8 4b f7 ff ff       	call   801b60 <fd2num>
  802415:	89 c3                	mov    %eax,%ebx
	//panic("open not implemented");
}
  802417:	89 d8                	mov    %ebx,%eax
  802419:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80241c:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80241f:	89 ec                	mov    %ebp,%esp
  802421:	5d                   	pop    %ebp
  802422:	c3                   	ret    
	...

00802430 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  802430:	55                   	push   %ebp
  802431:	89 e5                	mov    %esp,%ebp
  802433:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  802436:	c7 44 24 04 ac 31 80 	movl   $0x8031ac,0x4(%esp)
  80243d:	00 
  80243e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802441:	89 04 24             	mov    %eax,(%esp)
  802444:	e8 61 e7 ff ff       	call   800baa <strcpy>
	return 0;
}
  802449:	b8 00 00 00 00       	mov    $0x0,%eax
  80244e:	c9                   	leave  
  80244f:	c3                   	ret    

00802450 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  802450:	55                   	push   %ebp
  802451:	89 e5                	mov    %esp,%ebp
  802453:	53                   	push   %ebx
  802454:	83 ec 14             	sub    $0x14,%esp
  802457:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  80245a:	89 1c 24             	mov    %ebx,(%esp)
  80245d:	e8 46 05 00 00       	call   8029a8 <pageref>
  802462:	89 c2                	mov    %eax,%edx
  802464:	b8 00 00 00 00       	mov    $0x0,%eax
  802469:	83 fa 01             	cmp    $0x1,%edx
  80246c:	75 0b                	jne    802479 <devsock_close+0x29>
		return nsipc_close(fd->fd_sock.sockid);
  80246e:	8b 43 0c             	mov    0xc(%ebx),%eax
  802471:	89 04 24             	mov    %eax,(%esp)
  802474:	e8 b9 02 00 00       	call   802732 <nsipc_close>
	else
		return 0;
}
  802479:	83 c4 14             	add    $0x14,%esp
  80247c:	5b                   	pop    %ebx
  80247d:	5d                   	pop    %ebp
  80247e:	c3                   	ret    

0080247f <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  80247f:	55                   	push   %ebp
  802480:	89 e5                	mov    %esp,%ebp
  802482:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  802485:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80248c:	00 
  80248d:	8b 45 10             	mov    0x10(%ebp),%eax
  802490:	89 44 24 08          	mov    %eax,0x8(%esp)
  802494:	8b 45 0c             	mov    0xc(%ebp),%eax
  802497:	89 44 24 04          	mov    %eax,0x4(%esp)
  80249b:	8b 45 08             	mov    0x8(%ebp),%eax
  80249e:	8b 40 0c             	mov    0xc(%eax),%eax
  8024a1:	89 04 24             	mov    %eax,(%esp)
  8024a4:	e8 c5 02 00 00       	call   80276e <nsipc_send>
}
  8024a9:	c9                   	leave  
  8024aa:	c3                   	ret    

008024ab <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  8024ab:	55                   	push   %ebp
  8024ac:	89 e5                	mov    %esp,%ebp
  8024ae:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  8024b1:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8024b8:	00 
  8024b9:	8b 45 10             	mov    0x10(%ebp),%eax
  8024bc:	89 44 24 08          	mov    %eax,0x8(%esp)
  8024c0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8024c3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8024c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8024ca:	8b 40 0c             	mov    0xc(%eax),%eax
  8024cd:	89 04 24             	mov    %eax,(%esp)
  8024d0:	e8 0c 03 00 00       	call   8027e1 <nsipc_recv>
}
  8024d5:	c9                   	leave  
  8024d6:	c3                   	ret    

008024d7 <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  8024d7:	55                   	push   %ebp
  8024d8:	89 e5                	mov    %esp,%ebp
  8024da:	56                   	push   %esi
  8024db:	53                   	push   %ebx
  8024dc:	83 ec 20             	sub    $0x20,%esp
  8024df:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  8024e1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8024e4:	89 04 24             	mov    %eax,(%esp)
  8024e7:	e8 9f f6 ff ff       	call   801b8b <fd_alloc>
  8024ec:	89 c3                	mov    %eax,%ebx
  8024ee:	85 c0                	test   %eax,%eax
  8024f0:	78 21                	js     802513 <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  8024f2:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8024f9:	00 
  8024fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  802501:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802508:	e8 cb ef ff ff       	call   8014d8 <sys_page_alloc>
  80250d:	89 c3                	mov    %eax,%ebx
alloc_sockfd(int sockid)
{
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  80250f:	85 c0                	test   %eax,%eax
  802511:	79 0a                	jns    80251d <alloc_sockfd+0x46>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
		nsipc_close(sockid);
  802513:	89 34 24             	mov    %esi,(%esp)
  802516:	e8 17 02 00 00       	call   802732 <nsipc_close>
		return r;
  80251b:	eb 28                	jmp    802545 <alloc_sockfd+0x6e>
	}

	sfd->fd_dev_id = devsock.dev_id;
  80251d:	8b 15 20 40 80 00    	mov    0x804020,%edx
  802523:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802526:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  802528:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80252b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  802532:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802535:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  802538:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80253b:	89 04 24             	mov    %eax,(%esp)
  80253e:	e8 1d f6 ff ff       	call   801b60 <fd2num>
  802543:	89 c3                	mov    %eax,%ebx
}
  802545:	89 d8                	mov    %ebx,%eax
  802547:	83 c4 20             	add    $0x20,%esp
  80254a:	5b                   	pop    %ebx
  80254b:	5e                   	pop    %esi
  80254c:	5d                   	pop    %ebp
  80254d:	c3                   	ret    

0080254e <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  80254e:	55                   	push   %ebp
  80254f:	89 e5                	mov    %esp,%ebp
  802551:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  802554:	8b 45 10             	mov    0x10(%ebp),%eax
  802557:	89 44 24 08          	mov    %eax,0x8(%esp)
  80255b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80255e:	89 44 24 04          	mov    %eax,0x4(%esp)
  802562:	8b 45 08             	mov    0x8(%ebp),%eax
  802565:	89 04 24             	mov    %eax,(%esp)
  802568:	e8 79 01 00 00       	call   8026e6 <nsipc_socket>
  80256d:	85 c0                	test   %eax,%eax
  80256f:	78 05                	js     802576 <socket+0x28>
		return r;
	return alloc_sockfd(r);
  802571:	e8 61 ff ff ff       	call   8024d7 <alloc_sockfd>
}
  802576:	c9                   	leave  
  802577:	c3                   	ret    

00802578 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  802578:	55                   	push   %ebp
  802579:	89 e5                	mov    %esp,%ebp
  80257b:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  80257e:	8d 55 f4             	lea    -0xc(%ebp),%edx
  802581:	89 54 24 04          	mov    %edx,0x4(%esp)
  802585:	89 04 24             	mov    %eax,(%esp)
  802588:	e8 70 f6 ff ff       	call   801bfd <fd_lookup>
  80258d:	85 c0                	test   %eax,%eax
  80258f:	78 15                	js     8025a6 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  802591:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802594:	8b 0a                	mov    (%edx),%ecx
  802596:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80259b:	3b 0d 20 40 80 00    	cmp    0x804020,%ecx
  8025a1:	75 03                	jne    8025a6 <fd2sockid+0x2e>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  8025a3:	8b 42 0c             	mov    0xc(%edx),%eax
}
  8025a6:	c9                   	leave  
  8025a7:	c3                   	ret    

008025a8 <listen>:
	return nsipc_connect(r, name, namelen);
}

int
listen(int s, int backlog)
{
  8025a8:	55                   	push   %ebp
  8025a9:	89 e5                	mov    %esp,%ebp
  8025ab:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8025ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8025b1:	e8 c2 ff ff ff       	call   802578 <fd2sockid>
  8025b6:	85 c0                	test   %eax,%eax
  8025b8:	78 0f                	js     8025c9 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  8025ba:	8b 55 0c             	mov    0xc(%ebp),%edx
  8025bd:	89 54 24 04          	mov    %edx,0x4(%esp)
  8025c1:	89 04 24             	mov    %eax,(%esp)
  8025c4:	e8 47 01 00 00       	call   802710 <nsipc_listen>
}
  8025c9:	c9                   	leave  
  8025ca:	c3                   	ret    

008025cb <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8025cb:	55                   	push   %ebp
  8025cc:	89 e5                	mov    %esp,%ebp
  8025ce:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8025d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8025d4:	e8 9f ff ff ff       	call   802578 <fd2sockid>
  8025d9:	85 c0                	test   %eax,%eax
  8025db:	78 16                	js     8025f3 <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  8025dd:	8b 55 10             	mov    0x10(%ebp),%edx
  8025e0:	89 54 24 08          	mov    %edx,0x8(%esp)
  8025e4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8025e7:	89 54 24 04          	mov    %edx,0x4(%esp)
  8025eb:	89 04 24             	mov    %eax,(%esp)
  8025ee:	e8 6e 02 00 00       	call   802861 <nsipc_connect>
}
  8025f3:	c9                   	leave  
  8025f4:	c3                   	ret    

008025f5 <shutdown>:
	return nsipc_bind(r, name, namelen);
}

int
shutdown(int s, int how)
{
  8025f5:	55                   	push   %ebp
  8025f6:	89 e5                	mov    %esp,%ebp
  8025f8:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8025fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8025fe:	e8 75 ff ff ff       	call   802578 <fd2sockid>
  802603:	85 c0                	test   %eax,%eax
  802605:	78 0f                	js     802616 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  802607:	8b 55 0c             	mov    0xc(%ebp),%edx
  80260a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80260e:	89 04 24             	mov    %eax,(%esp)
  802611:	e8 36 01 00 00       	call   80274c <nsipc_shutdown>
}
  802616:	c9                   	leave  
  802617:	c3                   	ret    

00802618 <bind>:
	return alloc_sockfd(r);
}

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802618:	55                   	push   %ebp
  802619:	89 e5                	mov    %esp,%ebp
  80261b:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80261e:	8b 45 08             	mov    0x8(%ebp),%eax
  802621:	e8 52 ff ff ff       	call   802578 <fd2sockid>
  802626:	85 c0                	test   %eax,%eax
  802628:	78 16                	js     802640 <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  80262a:	8b 55 10             	mov    0x10(%ebp),%edx
  80262d:	89 54 24 08          	mov    %edx,0x8(%esp)
  802631:	8b 55 0c             	mov    0xc(%ebp),%edx
  802634:	89 54 24 04          	mov    %edx,0x4(%esp)
  802638:	89 04 24             	mov    %eax,(%esp)
  80263b:	e8 60 02 00 00       	call   8028a0 <nsipc_bind>
}
  802640:	c9                   	leave  
  802641:	c3                   	ret    

00802642 <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  802642:	55                   	push   %ebp
  802643:	89 e5                	mov    %esp,%ebp
  802645:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802648:	8b 45 08             	mov    0x8(%ebp),%eax
  80264b:	e8 28 ff ff ff       	call   802578 <fd2sockid>
  802650:	85 c0                	test   %eax,%eax
  802652:	78 1f                	js     802673 <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  802654:	8b 55 10             	mov    0x10(%ebp),%edx
  802657:	89 54 24 08          	mov    %edx,0x8(%esp)
  80265b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80265e:	89 54 24 04          	mov    %edx,0x4(%esp)
  802662:	89 04 24             	mov    %eax,(%esp)
  802665:	e8 75 02 00 00       	call   8028df <nsipc_accept>
  80266a:	85 c0                	test   %eax,%eax
  80266c:	78 05                	js     802673 <accept+0x31>
		return r;
	return alloc_sockfd(r);
  80266e:	e8 64 fe ff ff       	call   8024d7 <alloc_sockfd>
}
  802673:	c9                   	leave  
  802674:	c3                   	ret    
	...

00802680 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  802680:	55                   	push   %ebp
  802681:	89 e5                	mov    %esp,%ebp
  802683:	53                   	push   %ebx
  802684:	83 ec 14             	sub    $0x14,%esp
  802687:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  802689:	83 3d 04 50 80 00 00 	cmpl   $0x0,0x805004
  802690:	75 11                	jne    8026a3 <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  802692:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  802699:	e8 82 f3 ff ff       	call   801a20 <ipc_find_env>
  80269e:	a3 04 50 80 00       	mov    %eax,0x805004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  8026a3:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8026aa:	00 
  8026ab:	c7 44 24 08 00 70 80 	movl   $0x807000,0x8(%esp)
  8026b2:	00 
  8026b3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8026b7:	a1 04 50 80 00       	mov    0x805004,%eax
  8026bc:	89 04 24             	mov    %eax,(%esp)
  8026bf:	e8 a7 f3 ff ff       	call   801a6b <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  8026c4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8026cb:	00 
  8026cc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8026d3:	00 
  8026d4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8026db:	e8 09 f4 ff ff       	call   801ae9 <ipc_recv>
}
  8026e0:	83 c4 14             	add    $0x14,%esp
  8026e3:	5b                   	pop    %ebx
  8026e4:	5d                   	pop    %ebp
  8026e5:	c3                   	ret    

008026e6 <nsipc_socket>:
	return nsipc(NSREQ_SEND);
}

int
nsipc_socket(int domain, int type, int protocol)
{
  8026e6:	55                   	push   %ebp
  8026e7:	89 e5                	mov    %esp,%ebp
  8026e9:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  8026ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8026ef:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  8026f4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8026f7:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  8026fc:	8b 45 10             	mov    0x10(%ebp),%eax
  8026ff:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  802704:	b8 09 00 00 00       	mov    $0x9,%eax
  802709:	e8 72 ff ff ff       	call   802680 <nsipc>
}
  80270e:	c9                   	leave  
  80270f:	c3                   	ret    

00802710 <nsipc_listen>:
	return nsipc(NSREQ_CONNECT);
}

int
nsipc_listen(int s, int backlog)
{
  802710:	55                   	push   %ebp
  802711:	89 e5                	mov    %esp,%ebp
  802713:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  802716:	8b 45 08             	mov    0x8(%ebp),%eax
  802719:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  80271e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802721:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  802726:	b8 06 00 00 00       	mov    $0x6,%eax
  80272b:	e8 50 ff ff ff       	call   802680 <nsipc>
}
  802730:	c9                   	leave  
  802731:	c3                   	ret    

00802732 <nsipc_close>:
	return nsipc(NSREQ_SHUTDOWN);
}

int
nsipc_close(int s)
{
  802732:	55                   	push   %ebp
  802733:	89 e5                	mov    %esp,%ebp
  802735:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  802738:	8b 45 08             	mov    0x8(%ebp),%eax
  80273b:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  802740:	b8 04 00 00 00       	mov    $0x4,%eax
  802745:	e8 36 ff ff ff       	call   802680 <nsipc>
}
  80274a:	c9                   	leave  
  80274b:	c3                   	ret    

0080274c <nsipc_shutdown>:
	return nsipc(NSREQ_BIND);
}

int
nsipc_shutdown(int s, int how)
{
  80274c:	55                   	push   %ebp
  80274d:	89 e5                	mov    %esp,%ebp
  80274f:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  802752:	8b 45 08             	mov    0x8(%ebp),%eax
  802755:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  80275a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80275d:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  802762:	b8 03 00 00 00       	mov    $0x3,%eax
  802767:	e8 14 ff ff ff       	call   802680 <nsipc>
}
  80276c:	c9                   	leave  
  80276d:	c3                   	ret    

0080276e <nsipc_send>:
	return r;
}

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  80276e:	55                   	push   %ebp
  80276f:	89 e5                	mov    %esp,%ebp
  802771:	53                   	push   %ebx
  802772:	83 ec 14             	sub    $0x14,%esp
  802775:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  802778:	8b 45 08             	mov    0x8(%ebp),%eax
  80277b:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  802780:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  802786:	7e 24                	jle    8027ac <nsipc_send+0x3e>
  802788:	c7 44 24 0c b8 31 80 	movl   $0x8031b8,0xc(%esp)
  80278f:	00 
  802790:	c7 44 24 08 c4 31 80 	movl   $0x8031c4,0x8(%esp)
  802797:	00 
  802798:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
  80279f:	00 
  8027a0:	c7 04 24 d9 31 80 00 	movl   $0x8031d9,(%esp)
  8027a7:	e8 14 da ff ff       	call   8001c0 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  8027ac:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8027b0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8027b3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8027b7:	c7 04 24 0c 70 80 00 	movl   $0x80700c,(%esp)
  8027be:	e8 d2 e5 ff ff       	call   800d95 <memmove>
	nsipcbuf.send.req_size = size;
  8027c3:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  8027c9:	8b 45 14             	mov    0x14(%ebp),%eax
  8027cc:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  8027d1:	b8 08 00 00 00       	mov    $0x8,%eax
  8027d6:	e8 a5 fe ff ff       	call   802680 <nsipc>
}
  8027db:	83 c4 14             	add    $0x14,%esp
  8027de:	5b                   	pop    %ebx
  8027df:	5d                   	pop    %ebp
  8027e0:	c3                   	ret    

008027e1 <nsipc_recv>:
	return nsipc(NSREQ_LISTEN);
}

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  8027e1:	55                   	push   %ebp
  8027e2:	89 e5                	mov    %esp,%ebp
  8027e4:	56                   	push   %esi
  8027e5:	53                   	push   %ebx
  8027e6:	83 ec 10             	sub    $0x10,%esp
  8027e9:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  8027ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8027ef:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  8027f4:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  8027fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8027fd:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  802802:	b8 07 00 00 00       	mov    $0x7,%eax
  802807:	e8 74 fe ff ff       	call   802680 <nsipc>
  80280c:	89 c3                	mov    %eax,%ebx
  80280e:	85 c0                	test   %eax,%eax
  802810:	78 46                	js     802858 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  802812:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  802817:	7f 04                	jg     80281d <nsipc_recv+0x3c>
  802819:	39 c6                	cmp    %eax,%esi
  80281b:	7d 24                	jge    802841 <nsipc_recv+0x60>
  80281d:	c7 44 24 0c e5 31 80 	movl   $0x8031e5,0xc(%esp)
  802824:	00 
  802825:	c7 44 24 08 c4 31 80 	movl   $0x8031c4,0x8(%esp)
  80282c:	00 
  80282d:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
  802834:	00 
  802835:	c7 04 24 d9 31 80 00 	movl   $0x8031d9,(%esp)
  80283c:	e8 7f d9 ff ff       	call   8001c0 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  802841:	89 44 24 08          	mov    %eax,0x8(%esp)
  802845:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  80284c:	00 
  80284d:	8b 45 0c             	mov    0xc(%ebp),%eax
  802850:	89 04 24             	mov    %eax,(%esp)
  802853:	e8 3d e5 ff ff       	call   800d95 <memmove>
	}

	return r;
}
  802858:	89 d8                	mov    %ebx,%eax
  80285a:	83 c4 10             	add    $0x10,%esp
  80285d:	5b                   	pop    %ebx
  80285e:	5e                   	pop    %esi
  80285f:	5d                   	pop    %ebp
  802860:	c3                   	ret    

00802861 <nsipc_connect>:
	return nsipc(NSREQ_CLOSE);
}

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  802861:	55                   	push   %ebp
  802862:	89 e5                	mov    %esp,%ebp
  802864:	53                   	push   %ebx
  802865:	83 ec 14             	sub    $0x14,%esp
  802868:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  80286b:	8b 45 08             	mov    0x8(%ebp),%eax
  80286e:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  802873:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802877:	8b 45 0c             	mov    0xc(%ebp),%eax
  80287a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80287e:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  802885:	e8 0b e5 ff ff       	call   800d95 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  80288a:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  802890:	b8 05 00 00 00       	mov    $0x5,%eax
  802895:	e8 e6 fd ff ff       	call   802680 <nsipc>
}
  80289a:	83 c4 14             	add    $0x14,%esp
  80289d:	5b                   	pop    %ebx
  80289e:	5d                   	pop    %ebp
  80289f:	c3                   	ret    

008028a0 <nsipc_bind>:
	return r;
}

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8028a0:	55                   	push   %ebp
  8028a1:	89 e5                	mov    %esp,%ebp
  8028a3:	53                   	push   %ebx
  8028a4:	83 ec 14             	sub    $0x14,%esp
  8028a7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  8028aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8028ad:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  8028b2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8028b6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8028b9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8028bd:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  8028c4:	e8 cc e4 ff ff       	call   800d95 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  8028c9:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  8028cf:	b8 02 00 00 00       	mov    $0x2,%eax
  8028d4:	e8 a7 fd ff ff       	call   802680 <nsipc>
}
  8028d9:	83 c4 14             	add    $0x14,%esp
  8028dc:	5b                   	pop    %ebx
  8028dd:	5d                   	pop    %ebp
  8028de:	c3                   	ret    

008028df <nsipc_accept>:
	return ipc_recv(NULL, NULL, NULL);
}

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8028df:	55                   	push   %ebp
  8028e0:	89 e5                	mov    %esp,%ebp
  8028e2:	83 ec 18             	sub    $0x18,%esp
  8028e5:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8028e8:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int r;

	nsipcbuf.accept.req_s = s;
  8028eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8028ee:	a3 00 70 80 00       	mov    %eax,0x807000
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  8028f3:	b8 01 00 00 00       	mov    $0x1,%eax
  8028f8:	e8 83 fd ff ff       	call   802680 <nsipc>
  8028fd:	89 c3                	mov    %eax,%ebx
  8028ff:	85 c0                	test   %eax,%eax
  802901:	78 25                	js     802928 <nsipc_accept+0x49>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  802903:	be 10 70 80 00       	mov    $0x807010,%esi
  802908:	8b 06                	mov    (%esi),%eax
  80290a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80290e:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  802915:	00 
  802916:	8b 45 0c             	mov    0xc(%ebp),%eax
  802919:	89 04 24             	mov    %eax,(%esp)
  80291c:	e8 74 e4 ff ff       	call   800d95 <memmove>
		*addrlen = ret->ret_addrlen;
  802921:	8b 16                	mov    (%esi),%edx
  802923:	8b 45 10             	mov    0x10(%ebp),%eax
  802926:	89 10                	mov    %edx,(%eax)
	}
	return r;
}
  802928:	89 d8                	mov    %ebx,%eax
  80292a:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80292d:	8b 75 fc             	mov    -0x4(%ebp),%esi
  802930:	89 ec                	mov    %ebp,%esp
  802932:	5d                   	pop    %ebp
  802933:	c3                   	ret    

00802934 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802934:	55                   	push   %ebp
  802935:	89 e5                	mov    %esp,%ebp
  802937:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  80293a:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  802941:	75 30                	jne    802973 <set_pgfault_handler+0x3f>
		// First time through!
		// LAB 4: Your code here.
                uint32_t ret = sys_page_alloc(0,(void*)(UXSTACKTOP-PGSIZE),PTE_P|PTE_U|PTE_W);
  802943:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80294a:	00 
  80294b:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  802952:	ee 
  802953:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80295a:	e8 79 eb ff ff       	call   8014d8 <sys_page_alloc>
                if(ret < 0)
                  return;
                sys_env_set_pgfault_upcall(0,_pgfault_upcall);
  80295f:	c7 44 24 04 80 29 80 	movl   $0x802980,0x4(%esp)
  802966:	00 
  802967:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80296e:	e8 47 e9 ff ff       	call   8012ba <sys_env_set_pgfault_upcall>
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802973:	8b 45 08             	mov    0x8(%ebp),%eax
  802976:	a3 00 80 80 00       	mov    %eax,0x808000
}
  80297b:	c9                   	leave  
  80297c:	c3                   	ret    
  80297d:	00 00                	add    %al,(%eax)
	...

00802980 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802980:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802981:	a1 00 80 80 00       	mov    0x808000,%eax
	call *%eax
  802986:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802988:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
        movl 0x28(%esp),%eax
  80298b:	8b 44 24 28          	mov    0x28(%esp),%eax
        movl 0x30(%esp),%ecx
  80298f:	8b 4c 24 30          	mov    0x30(%esp),%ecx
        subl $0x4,%ecx
  802993:	83 e9 04             	sub    $0x4,%ecx
        movl %eax,(%ecx)
  802996:	89 01                	mov    %eax,(%ecx)
        movl %ecx,0x30(%esp)
  802998:	89 4c 24 30          	mov    %ecx,0x30(%esp)
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
        addl $0x8,%esp
  80299c:	83 c4 08             	add    $0x8,%esp
        popal
  80299f:	61                   	popa   
        addl $0x4,%esp
  8029a0:	83 c4 04             	add    $0x4,%esp
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
        popfl
  8029a3:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
        popl %esp
  8029a4:	5c                   	pop    %esp
        //subl $0x4,%esp   //CAN'T SUB HERE BECAUSE OF EFLAGS
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
        ret
  8029a5:	c3                   	ret    
	...

008029a8 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8029a8:	55                   	push   %ebp
  8029a9:	89 e5                	mov    %esp,%ebp
	pte_t pte;

	if (!(vpd[PDX(v)] & PTE_P))
  8029ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8029ae:	89 c2                	mov    %eax,%edx
  8029b0:	c1 ea 16             	shr    $0x16,%edx
  8029b3:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8029ba:	f6 c2 01             	test   $0x1,%dl
  8029bd:	74 20                	je     8029df <pageref+0x37>
		return 0;
	pte = vpt[PGNUM(v)];
  8029bf:	c1 e8 0c             	shr    $0xc,%eax
  8029c2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8029c9:	a8 01                	test   $0x1,%al
  8029cb:	74 12                	je     8029df <pageref+0x37>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8029cd:	c1 e8 0c             	shr    $0xc,%eax
  8029d0:	ba 00 00 00 ef       	mov    $0xef000000,%edx
  8029d5:	0f b7 44 c2 04       	movzwl 0x4(%edx,%eax,8),%eax
  8029da:	0f b7 c0             	movzwl %ax,%eax
  8029dd:	eb 05                	jmp    8029e4 <pageref+0x3c>
  8029df:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8029e4:	5d                   	pop    %ebp
  8029e5:	c3                   	ret    
	...

008029f0 <__udivdi3>:
  8029f0:	55                   	push   %ebp
  8029f1:	89 e5                	mov    %esp,%ebp
  8029f3:	57                   	push   %edi
  8029f4:	56                   	push   %esi
  8029f5:	83 ec 10             	sub    $0x10,%esp
  8029f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8029fb:	8b 55 08             	mov    0x8(%ebp),%edx
  8029fe:	8b 75 10             	mov    0x10(%ebp),%esi
  802a01:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802a04:	85 c0                	test   %eax,%eax
  802a06:	89 55 f0             	mov    %edx,-0x10(%ebp)
  802a09:	75 35                	jne    802a40 <__udivdi3+0x50>
  802a0b:	39 fe                	cmp    %edi,%esi
  802a0d:	77 61                	ja     802a70 <__udivdi3+0x80>
  802a0f:	85 f6                	test   %esi,%esi
  802a11:	75 0b                	jne    802a1e <__udivdi3+0x2e>
  802a13:	b8 01 00 00 00       	mov    $0x1,%eax
  802a18:	31 d2                	xor    %edx,%edx
  802a1a:	f7 f6                	div    %esi
  802a1c:	89 c6                	mov    %eax,%esi
  802a1e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  802a21:	31 d2                	xor    %edx,%edx
  802a23:	89 f8                	mov    %edi,%eax
  802a25:	f7 f6                	div    %esi
  802a27:	89 c7                	mov    %eax,%edi
  802a29:	89 c8                	mov    %ecx,%eax
  802a2b:	f7 f6                	div    %esi
  802a2d:	89 c1                	mov    %eax,%ecx
  802a2f:	89 fa                	mov    %edi,%edx
  802a31:	89 c8                	mov    %ecx,%eax
  802a33:	83 c4 10             	add    $0x10,%esp
  802a36:	5e                   	pop    %esi
  802a37:	5f                   	pop    %edi
  802a38:	5d                   	pop    %ebp
  802a39:	c3                   	ret    
  802a3a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802a40:	39 f8                	cmp    %edi,%eax
  802a42:	77 1c                	ja     802a60 <__udivdi3+0x70>
  802a44:	0f bd d0             	bsr    %eax,%edx
  802a47:	83 f2 1f             	xor    $0x1f,%edx
  802a4a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  802a4d:	75 39                	jne    802a88 <__udivdi3+0x98>
  802a4f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  802a52:	0f 86 a0 00 00 00    	jbe    802af8 <__udivdi3+0x108>
  802a58:	39 f8                	cmp    %edi,%eax
  802a5a:	0f 82 98 00 00 00    	jb     802af8 <__udivdi3+0x108>
  802a60:	31 ff                	xor    %edi,%edi
  802a62:	31 c9                	xor    %ecx,%ecx
  802a64:	89 c8                	mov    %ecx,%eax
  802a66:	89 fa                	mov    %edi,%edx
  802a68:	83 c4 10             	add    $0x10,%esp
  802a6b:	5e                   	pop    %esi
  802a6c:	5f                   	pop    %edi
  802a6d:	5d                   	pop    %ebp
  802a6e:	c3                   	ret    
  802a6f:	90                   	nop
  802a70:	89 d1                	mov    %edx,%ecx
  802a72:	89 fa                	mov    %edi,%edx
  802a74:	89 c8                	mov    %ecx,%eax
  802a76:	31 ff                	xor    %edi,%edi
  802a78:	f7 f6                	div    %esi
  802a7a:	89 c1                	mov    %eax,%ecx
  802a7c:	89 fa                	mov    %edi,%edx
  802a7e:	89 c8                	mov    %ecx,%eax
  802a80:	83 c4 10             	add    $0x10,%esp
  802a83:	5e                   	pop    %esi
  802a84:	5f                   	pop    %edi
  802a85:	5d                   	pop    %ebp
  802a86:	c3                   	ret    
  802a87:	90                   	nop
  802a88:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  802a8c:	89 f2                	mov    %esi,%edx
  802a8e:	d3 e0                	shl    %cl,%eax
  802a90:	89 45 ec             	mov    %eax,-0x14(%ebp)
  802a93:	b8 20 00 00 00       	mov    $0x20,%eax
  802a98:	2b 45 f4             	sub    -0xc(%ebp),%eax
  802a9b:	89 c1                	mov    %eax,%ecx
  802a9d:	d3 ea                	shr    %cl,%edx
  802a9f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  802aa3:	0b 55 ec             	or     -0x14(%ebp),%edx
  802aa6:	d3 e6                	shl    %cl,%esi
  802aa8:	89 c1                	mov    %eax,%ecx
  802aaa:	89 75 e8             	mov    %esi,-0x18(%ebp)
  802aad:	89 fe                	mov    %edi,%esi
  802aaf:	d3 ee                	shr    %cl,%esi
  802ab1:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  802ab5:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802ab8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802abb:	d3 e7                	shl    %cl,%edi
  802abd:	89 c1                	mov    %eax,%ecx
  802abf:	d3 ea                	shr    %cl,%edx
  802ac1:	09 d7                	or     %edx,%edi
  802ac3:	89 f2                	mov    %esi,%edx
  802ac5:	89 f8                	mov    %edi,%eax
  802ac7:	f7 75 ec             	divl   -0x14(%ebp)
  802aca:	89 d6                	mov    %edx,%esi
  802acc:	89 c7                	mov    %eax,%edi
  802ace:	f7 65 e8             	mull   -0x18(%ebp)
  802ad1:	39 d6                	cmp    %edx,%esi
  802ad3:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802ad6:	72 30                	jb     802b08 <__udivdi3+0x118>
  802ad8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802adb:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  802adf:	d3 e2                	shl    %cl,%edx
  802ae1:	39 c2                	cmp    %eax,%edx
  802ae3:	73 05                	jae    802aea <__udivdi3+0xfa>
  802ae5:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  802ae8:	74 1e                	je     802b08 <__udivdi3+0x118>
  802aea:	89 f9                	mov    %edi,%ecx
  802aec:	31 ff                	xor    %edi,%edi
  802aee:	e9 71 ff ff ff       	jmp    802a64 <__udivdi3+0x74>
  802af3:	90                   	nop
  802af4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802af8:	31 ff                	xor    %edi,%edi
  802afa:	b9 01 00 00 00       	mov    $0x1,%ecx
  802aff:	e9 60 ff ff ff       	jmp    802a64 <__udivdi3+0x74>
  802b04:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802b08:	8d 4f ff             	lea    -0x1(%edi),%ecx
  802b0b:	31 ff                	xor    %edi,%edi
  802b0d:	89 c8                	mov    %ecx,%eax
  802b0f:	89 fa                	mov    %edi,%edx
  802b11:	83 c4 10             	add    $0x10,%esp
  802b14:	5e                   	pop    %esi
  802b15:	5f                   	pop    %edi
  802b16:	5d                   	pop    %ebp
  802b17:	c3                   	ret    
	...

00802b20 <__umoddi3>:
  802b20:	55                   	push   %ebp
  802b21:	89 e5                	mov    %esp,%ebp
  802b23:	57                   	push   %edi
  802b24:	56                   	push   %esi
  802b25:	83 ec 20             	sub    $0x20,%esp
  802b28:	8b 55 14             	mov    0x14(%ebp),%edx
  802b2b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802b2e:	8b 7d 10             	mov    0x10(%ebp),%edi
  802b31:	8b 75 0c             	mov    0xc(%ebp),%esi
  802b34:	85 d2                	test   %edx,%edx
  802b36:	89 c8                	mov    %ecx,%eax
  802b38:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  802b3b:	75 13                	jne    802b50 <__umoddi3+0x30>
  802b3d:	39 f7                	cmp    %esi,%edi
  802b3f:	76 3f                	jbe    802b80 <__umoddi3+0x60>
  802b41:	89 f2                	mov    %esi,%edx
  802b43:	f7 f7                	div    %edi
  802b45:	89 d0                	mov    %edx,%eax
  802b47:	31 d2                	xor    %edx,%edx
  802b49:	83 c4 20             	add    $0x20,%esp
  802b4c:	5e                   	pop    %esi
  802b4d:	5f                   	pop    %edi
  802b4e:	5d                   	pop    %ebp
  802b4f:	c3                   	ret    
  802b50:	39 f2                	cmp    %esi,%edx
  802b52:	77 4c                	ja     802ba0 <__umoddi3+0x80>
  802b54:	0f bd ca             	bsr    %edx,%ecx
  802b57:	83 f1 1f             	xor    $0x1f,%ecx
  802b5a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  802b5d:	75 51                	jne    802bb0 <__umoddi3+0x90>
  802b5f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  802b62:	0f 87 e0 00 00 00    	ja     802c48 <__umoddi3+0x128>
  802b68:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802b6b:	29 f8                	sub    %edi,%eax
  802b6d:	19 d6                	sbb    %edx,%esi
  802b6f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  802b72:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802b75:	89 f2                	mov    %esi,%edx
  802b77:	83 c4 20             	add    $0x20,%esp
  802b7a:	5e                   	pop    %esi
  802b7b:	5f                   	pop    %edi
  802b7c:	5d                   	pop    %ebp
  802b7d:	c3                   	ret    
  802b7e:	66 90                	xchg   %ax,%ax
  802b80:	85 ff                	test   %edi,%edi
  802b82:	75 0b                	jne    802b8f <__umoddi3+0x6f>
  802b84:	b8 01 00 00 00       	mov    $0x1,%eax
  802b89:	31 d2                	xor    %edx,%edx
  802b8b:	f7 f7                	div    %edi
  802b8d:	89 c7                	mov    %eax,%edi
  802b8f:	89 f0                	mov    %esi,%eax
  802b91:	31 d2                	xor    %edx,%edx
  802b93:	f7 f7                	div    %edi
  802b95:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802b98:	f7 f7                	div    %edi
  802b9a:	eb a9                	jmp    802b45 <__umoddi3+0x25>
  802b9c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802ba0:	89 c8                	mov    %ecx,%eax
  802ba2:	89 f2                	mov    %esi,%edx
  802ba4:	83 c4 20             	add    $0x20,%esp
  802ba7:	5e                   	pop    %esi
  802ba8:	5f                   	pop    %edi
  802ba9:	5d                   	pop    %ebp
  802baa:	c3                   	ret    
  802bab:	90                   	nop
  802bac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802bb0:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802bb4:	d3 e2                	shl    %cl,%edx
  802bb6:	89 55 f4             	mov    %edx,-0xc(%ebp)
  802bb9:	ba 20 00 00 00       	mov    $0x20,%edx
  802bbe:	2b 55 f0             	sub    -0x10(%ebp),%edx
  802bc1:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802bc4:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802bc8:	89 fa                	mov    %edi,%edx
  802bca:	d3 ea                	shr    %cl,%edx
  802bcc:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802bd0:	0b 55 f4             	or     -0xc(%ebp),%edx
  802bd3:	d3 e7                	shl    %cl,%edi
  802bd5:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802bd9:	89 55 f4             	mov    %edx,-0xc(%ebp)
  802bdc:	89 f2                	mov    %esi,%edx
  802bde:	89 7d e8             	mov    %edi,-0x18(%ebp)
  802be1:	89 c7                	mov    %eax,%edi
  802be3:	d3 ea                	shr    %cl,%edx
  802be5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802be9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  802bec:	89 c2                	mov    %eax,%edx
  802bee:	d3 e6                	shl    %cl,%esi
  802bf0:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802bf4:	d3 ea                	shr    %cl,%edx
  802bf6:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802bfa:	09 d6                	or     %edx,%esi
  802bfc:	89 f0                	mov    %esi,%eax
  802bfe:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  802c01:	d3 e7                	shl    %cl,%edi
  802c03:	89 f2                	mov    %esi,%edx
  802c05:	f7 75 f4             	divl   -0xc(%ebp)
  802c08:	89 d6                	mov    %edx,%esi
  802c0a:	f7 65 e8             	mull   -0x18(%ebp)
  802c0d:	39 d6                	cmp    %edx,%esi
  802c0f:	72 2b                	jb     802c3c <__umoddi3+0x11c>
  802c11:	39 c7                	cmp    %eax,%edi
  802c13:	72 23                	jb     802c38 <__umoddi3+0x118>
  802c15:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802c19:	29 c7                	sub    %eax,%edi
  802c1b:	19 d6                	sbb    %edx,%esi
  802c1d:	89 f0                	mov    %esi,%eax
  802c1f:	89 f2                	mov    %esi,%edx
  802c21:	d3 ef                	shr    %cl,%edi
  802c23:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802c27:	d3 e0                	shl    %cl,%eax
  802c29:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802c2d:	09 f8                	or     %edi,%eax
  802c2f:	d3 ea                	shr    %cl,%edx
  802c31:	83 c4 20             	add    $0x20,%esp
  802c34:	5e                   	pop    %esi
  802c35:	5f                   	pop    %edi
  802c36:	5d                   	pop    %ebp
  802c37:	c3                   	ret    
  802c38:	39 d6                	cmp    %edx,%esi
  802c3a:	75 d9                	jne    802c15 <__umoddi3+0xf5>
  802c3c:	2b 45 e8             	sub    -0x18(%ebp),%eax
  802c3f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  802c42:	eb d1                	jmp    802c15 <__umoddi3+0xf5>
  802c44:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802c48:	39 f2                	cmp    %esi,%edx
  802c4a:	0f 82 18 ff ff ff    	jb     802b68 <__umoddi3+0x48>
  802c50:	e9 1d ff ff ff       	jmp    802b72 <__umoddi3+0x52>
