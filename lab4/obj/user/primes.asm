
obj/user/primes:     file format elf32-i386


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
  800053:	e8 f1 18 00 00       	call   801949 <ipc_recv>
  800058:	89 c3                	mov    %eax,%ebx
	cprintf("CPU %d: %d ", thisenv->env_cpunum, p);
  80005a:	a1 04 30 80 00       	mov    0x803004,%eax
  80005f:	8b 40 5c             	mov    0x5c(%eax),%eax
  800062:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800066:	89 44 24 04          	mov    %eax,0x4(%esp)
  80006a:	c7 04 24 a0 1c 80 00 	movl   $0x801ca0,(%esp)
  800071:	e8 13 02 00 00       	call   800289 <cprintf>

	// fork a right neighbor to continue the chain
	if ((id = fork()) < 0)
  800076:	e8 77 14 00 00       	call   8014f2 <fork>
  80007b:	89 c7                	mov    %eax,%edi
  80007d:	85 c0                	test   %eax,%eax
  80007f:	79 20                	jns    8000a1 <primeproc+0x6d>
		panic("fork: %e", id);
  800081:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800085:	c7 44 24 08 17 20 80 	movl   $0x802017,0x8(%esp)
  80008c:	00 
  80008d:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  800094:	00 
  800095:	c7 04 24 ac 1c 80 00 	movl   $0x801cac,(%esp)
  80009c:	e8 17 01 00 00       	call   8001b8 <_panic>
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
  8000bb:	e8 89 18 00 00       	call   801949 <ipc_recv>
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
  8000e4:	e8 e2 17 00 00       	call   8018cb <ipc_send>
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
  8000f3:	e8 fa 13 00 00       	call   8014f2 <fork>
  8000f8:	89 c6                	mov    %eax,%esi
  8000fa:	85 c0                	test   %eax,%eax
  8000fc:	79 20                	jns    80011e <umain+0x33>
		panic("fork: %e", id);
  8000fe:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800102:	c7 44 24 08 17 20 80 	movl   $0x802017,0x8(%esp)
  800109:	00 
  80010a:	c7 44 24 04 2d 00 00 	movl   $0x2d,0x4(%esp)
  800111:	00 
  800112:	c7 04 24 ac 1c 80 00 	movl   $0x801cac,(%esp)
  800119:	e8 9a 00 00 00       	call   8001b8 <_panic>
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
  800143:	e8 83 17 00 00       	call   8018cb <ipc_send>
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
  800162:	e8 be 12 00 00       	call   801425 <sys_getenvid>
  800167:	25 ff 03 00 00       	and    $0x3ff,%eax
  80016c:	89 c2                	mov    %eax,%edx
  80016e:	c1 e2 07             	shl    $0x7,%edx
  800171:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  800178:	a3 04 30 80 00       	mov    %eax,0x803004
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
	sys_env_destroy(0);
  8001aa:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8001b1:	e8 af 12 00 00       	call   801465 <sys_env_destroy>
}
  8001b6:	c9                   	leave  
  8001b7:	c3                   	ret    

008001b8 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8001b8:	55                   	push   %ebp
  8001b9:	89 e5                	mov    %esp,%ebp
  8001bb:	56                   	push   %esi
  8001bc:	53                   	push   %ebx
  8001bd:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  8001c0:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	if (argv0)
  8001c3:	a1 08 30 80 00       	mov    0x803008,%eax
  8001c8:	85 c0                	test   %eax,%eax
  8001ca:	74 10                	je     8001dc <_panic+0x24>
		cprintf("%s: ", argv0);
  8001cc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001d0:	c7 04 24 c4 1c 80 00 	movl   $0x801cc4,(%esp)
  8001d7:	e8 ad 00 00 00       	call   800289 <cprintf>
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001dc:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  8001e2:	e8 3e 12 00 00       	call   801425 <sys_getenvid>
  8001e7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001ea:	89 54 24 10          	mov    %edx,0x10(%esp)
  8001ee:	8b 55 08             	mov    0x8(%ebp),%edx
  8001f1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8001f5:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001f9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001fd:	c7 04 24 cc 1c 80 00 	movl   $0x801ccc,(%esp)
  800204:	e8 80 00 00 00       	call   800289 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800209:	89 74 24 04          	mov    %esi,0x4(%esp)
  80020d:	8b 45 10             	mov    0x10(%ebp),%eax
  800210:	89 04 24             	mov    %eax,(%esp)
  800213:	e8 10 00 00 00       	call   800228 <vcprintf>
	cprintf("\n");
  800218:	c7 04 24 c9 1c 80 00 	movl   $0x801cc9,(%esp)
  80021f:	e8 65 00 00 00       	call   800289 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800224:	cc                   	int3   
  800225:	eb fd                	jmp    800224 <_panic+0x6c>
	...

00800228 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  800228:	55                   	push   %ebp
  800229:	89 e5                	mov    %esp,%ebp
  80022b:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800231:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800238:	00 00 00 
	b.cnt = 0;
  80023b:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800242:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800245:	8b 45 0c             	mov    0xc(%ebp),%eax
  800248:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80024c:	8b 45 08             	mov    0x8(%ebp),%eax
  80024f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800253:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800259:	89 44 24 04          	mov    %eax,0x4(%esp)
  80025d:	c7 04 24 a3 02 80 00 	movl   $0x8002a3,(%esp)
  800264:	e8 d3 01 00 00       	call   80043c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800269:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80026f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800273:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800279:	89 04 24             	mov    %eax,(%esp)
  80027c:	e8 6b 0d 00 00       	call   800fec <sys_cputs>

	return b.cnt;
}
  800281:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800287:	c9                   	leave  
  800288:	c3                   	ret    

00800289 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800289:	55                   	push   %ebp
  80028a:	89 e5                	mov    %esp,%ebp
  80028c:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  80028f:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  800292:	89 44 24 04          	mov    %eax,0x4(%esp)
  800296:	8b 45 08             	mov    0x8(%ebp),%eax
  800299:	89 04 24             	mov    %eax,(%esp)
  80029c:	e8 87 ff ff ff       	call   800228 <vcprintf>
	va_end(ap);

	return cnt;
}
  8002a1:	c9                   	leave  
  8002a2:	c3                   	ret    

008002a3 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8002a3:	55                   	push   %ebp
  8002a4:	89 e5                	mov    %esp,%ebp
  8002a6:	53                   	push   %ebx
  8002a7:	83 ec 14             	sub    $0x14,%esp
  8002aa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8002ad:	8b 03                	mov    (%ebx),%eax
  8002af:	8b 55 08             	mov    0x8(%ebp),%edx
  8002b2:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8002b6:	83 c0 01             	add    $0x1,%eax
  8002b9:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8002bb:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002c0:	75 19                	jne    8002db <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8002c2:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8002c9:	00 
  8002ca:	8d 43 08             	lea    0x8(%ebx),%eax
  8002cd:	89 04 24             	mov    %eax,(%esp)
  8002d0:	e8 17 0d 00 00       	call   800fec <sys_cputs>
		b->idx = 0;
  8002d5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8002db:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8002df:	83 c4 14             	add    $0x14,%esp
  8002e2:	5b                   	pop    %ebx
  8002e3:	5d                   	pop    %ebp
  8002e4:	c3                   	ret    
	...

008002f0 <printnum_v2>:
 */

static void 
printnum_v2(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002f0:	55                   	push   %ebp
  8002f1:	89 e5                	mov    %esp,%ebp
  8002f3:	57                   	push   %edi
  8002f4:	56                   	push   %esi
  8002f5:	53                   	push   %ebx
  8002f6:	83 ec 4c             	sub    $0x4c,%esp
  8002f9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002fc:	89 d6                	mov    %edx,%esi
  8002fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800301:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800304:	8b 55 0c             	mov    0xc(%ebp),%edx
  800307:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80030a:	8b 45 10             	mov    0x10(%ebp),%eax
  80030d:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800310:	8b 7d 18             	mov    0x18(%ebp),%edi
    if (num >= base) {
  800313:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800316:	b9 00 00 00 00       	mov    $0x0,%ecx
  80031b:	39 d1                	cmp    %edx,%ecx
  80031d:	72 07                	jb     800326 <printnum_v2+0x36>
  80031f:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800322:	39 d0                	cmp    %edx,%eax
  800324:	77 5f                	ja     800385 <printnum_v2+0x95>
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
  800326:	89 7c 24 10          	mov    %edi,0x10(%esp)
  80032a:	83 eb 01             	sub    $0x1,%ebx
  80032d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800331:	89 44 24 08          	mov    %eax,0x8(%esp)
  800335:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800339:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  80033d:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800340:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  800343:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800346:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80034a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800351:	00 
  800352:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800355:	89 04 24             	mov    %eax,(%esp)
  800358:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80035b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80035f:	e8 cc 16 00 00       	call   801a30 <__udivdi3>
  800364:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800367:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  80036a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80036e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800372:	89 04 24             	mov    %eax,(%esp)
  800375:	89 54 24 04          	mov    %edx,0x4(%esp)
  800379:	89 f2                	mov    %esi,%edx
  80037b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80037e:	e8 6d ff ff ff       	call   8002f0 <printnum_v2>
  800383:	eb 1e                	jmp    8003a3 <printnum_v2+0xb3>
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
  800385:	83 ff 2d             	cmp    $0x2d,%edi
  800388:	74 19                	je     8003a3 <printnum_v2+0xb3>
		while (--width > 0)
  80038a:	83 eb 01             	sub    $0x1,%ebx
  80038d:	85 db                	test   %ebx,%ebx
  80038f:	90                   	nop
  800390:	7e 11                	jle    8003a3 <printnum_v2+0xb3>
			putch(padc, putdat);
  800392:	89 74 24 04          	mov    %esi,0x4(%esp)
  800396:	89 3c 24             	mov    %edi,(%esp)
  800399:	ff 55 e4             	call   *-0x1c(%ebp)
    if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
		while (--width > 0)
  80039c:	83 eb 01             	sub    $0x1,%ebx
  80039f:	85 db                	test   %ebx,%ebx
  8003a1:	7f ef                	jg     800392 <printnum_v2+0xa2>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003a3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8003a7:	8b 74 24 04          	mov    0x4(%esp),%esi
  8003ab:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8003ae:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003b2:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8003b9:	00 
  8003ba:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8003bd:	89 14 24             	mov    %edx,(%esp)
  8003c0:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8003c3:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8003c7:	e8 94 17 00 00       	call   801b60 <__umoddi3>
  8003cc:	89 74 24 04          	mov    %esi,0x4(%esp)
  8003d0:	0f be 80 ef 1c 80 00 	movsbl 0x801cef(%eax),%eax
  8003d7:	89 04 24             	mov    %eax,(%esp)
  8003da:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8003dd:	83 c4 4c             	add    $0x4c,%esp
  8003e0:	5b                   	pop    %ebx
  8003e1:	5e                   	pop    %esi
  8003e2:	5f                   	pop    %edi
  8003e3:	5d                   	pop    %ebp
  8003e4:	c3                   	ret    

008003e5 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003e5:	55                   	push   %ebp
  8003e6:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003e8:	83 fa 01             	cmp    $0x1,%edx
  8003eb:	7e 0e                	jle    8003fb <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003ed:	8b 10                	mov    (%eax),%edx
  8003ef:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003f2:	89 08                	mov    %ecx,(%eax)
  8003f4:	8b 02                	mov    (%edx),%eax
  8003f6:	8b 52 04             	mov    0x4(%edx),%edx
  8003f9:	eb 22                	jmp    80041d <getuint+0x38>
	else if (lflag)
  8003fb:	85 d2                	test   %edx,%edx
  8003fd:	74 10                	je     80040f <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003ff:	8b 10                	mov    (%eax),%edx
  800401:	8d 4a 04             	lea    0x4(%edx),%ecx
  800404:	89 08                	mov    %ecx,(%eax)
  800406:	8b 02                	mov    (%edx),%eax
  800408:	ba 00 00 00 00       	mov    $0x0,%edx
  80040d:	eb 0e                	jmp    80041d <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80040f:	8b 10                	mov    (%eax),%edx
  800411:	8d 4a 04             	lea    0x4(%edx),%ecx
  800414:	89 08                	mov    %ecx,(%eax)
  800416:	8b 02                	mov    (%edx),%eax
  800418:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80041d:	5d                   	pop    %ebp
  80041e:	c3                   	ret    

0080041f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80041f:	55                   	push   %ebp
  800420:	89 e5                	mov    %esp,%ebp
  800422:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800425:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800429:	8b 10                	mov    (%eax),%edx
  80042b:	3b 50 04             	cmp    0x4(%eax),%edx
  80042e:	73 0a                	jae    80043a <sprintputch+0x1b>
		*b->buf++ = ch;
  800430:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800433:	88 0a                	mov    %cl,(%edx)
  800435:	83 c2 01             	add    $0x1,%edx
  800438:	89 10                	mov    %edx,(%eax)
}
  80043a:	5d                   	pop    %ebp
  80043b:	c3                   	ret    

0080043c <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80043c:	55                   	push   %ebp
  80043d:	89 e5                	mov    %esp,%ebp
  80043f:	57                   	push   %edi
  800440:	56                   	push   %esi
  800441:	53                   	push   %ebx
  800442:	83 ec 6c             	sub    $0x6c,%esp
  800445:	8b 7d 10             	mov    0x10(%ebp),%edi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800448:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  80044f:	eb 1a                	jmp    80046b <vprintfmt+0x2f>
	int base, lflag, width, precision, altflag,signflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800451:	85 c0                	test   %eax,%eax
  800453:	0f 84 66 06 00 00    	je     800abf <vprintfmt+0x683>
				return;
			putch(ch, putdat);
  800459:	8b 55 0c             	mov    0xc(%ebp),%edx
  80045c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800460:	89 04 24             	mov    %eax,(%esp)
  800463:	ff 55 08             	call   *0x8(%ebp)
  800466:	eb 03                	jmp    80046b <vprintfmt+0x2f>
  800468:	8b 7d e4             	mov    -0x1c(%ebp),%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag,signflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80046b:	0f b6 07             	movzbl (%edi),%eax
  80046e:	83 c7 01             	add    $0x1,%edi
  800471:	83 f8 25             	cmp    $0x25,%eax
  800474:	75 db                	jne    800451 <vprintfmt+0x15>
  800476:	c6 45 cc 20          	movb   $0x20,-0x34(%ebp)
  80047a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80047f:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  800486:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
  80048b:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800492:	be 00 00 00 00       	mov    $0x0,%esi
  800497:	eb 06                	jmp    80049f <vprintfmt+0x63>
  800499:	c6 45 cc 2d          	movb   $0x2d,-0x34(%ebp)
  80049d:	89 c7                	mov    %eax,%edi
		precision = -1;
		lflag = 0;
		altflag = 0;
                signflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049f:	0f b6 17             	movzbl (%edi),%edx
  8004a2:	0f b6 c2             	movzbl %dl,%eax
  8004a5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004a8:	8d 47 01             	lea    0x1(%edi),%eax
  8004ab:	83 ea 23             	sub    $0x23,%edx
  8004ae:	80 fa 55             	cmp    $0x55,%dl
  8004b1:	0f 87 60 05 00 00    	ja     800a17 <vprintfmt+0x5db>
  8004b7:	0f b6 d2             	movzbl %dl,%edx
  8004ba:	ff 24 95 40 1e 80 00 	jmp    *0x801e40(,%edx,4)
  8004c1:	b9 01 00 00 00       	mov    $0x1,%ecx
  8004c6:	eb d5                	jmp    80049d <vprintfmt+0x61>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004c8:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8004cb:	83 eb 30             	sub    $0x30,%ebx
				ch = *fmt;
  8004ce:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  8004d1:	8d 7a d0             	lea    -0x30(%edx),%edi
  8004d4:	83 ff 09             	cmp    $0x9,%edi
  8004d7:	76 08                	jbe    8004e1 <vprintfmt+0xa5>
  8004d9:	eb 40                	jmp    80051b <vprintfmt+0xdf>
  8004db:	c6 45 cc 30          	movb   $0x30,-0x34(%ebp)
                        signflag = 1;
                        goto reswitch;
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
			goto reswitch;
  8004df:	eb bc                	jmp    80049d <vprintfmt+0x61>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004e1:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  8004e4:	8d 1c 9b             	lea    (%ebx,%ebx,4),%ebx
  8004e7:	8d 5c 5a d0          	lea    -0x30(%edx,%ebx,2),%ebx
				ch = *fmt;
  8004eb:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  8004ee:	8d 7a d0             	lea    -0x30(%edx),%edi
  8004f1:	83 ff 09             	cmp    $0x9,%edi
  8004f4:	76 eb                	jbe    8004e1 <vprintfmt+0xa5>
  8004f6:	eb 23                	jmp    80051b <vprintfmt+0xdf>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004f8:	8b 55 14             	mov    0x14(%ebp),%edx
  8004fb:	8d 5a 04             	lea    0x4(%edx),%ebx
  8004fe:	89 5d 14             	mov    %ebx,0x14(%ebp)
  800501:	8b 1a                	mov    (%edx),%ebx
			goto process_precision;
  800503:	eb 16                	jmp    80051b <vprintfmt+0xdf>

		case '.':
			if (width < 0)
  800505:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800508:	c1 fa 1f             	sar    $0x1f,%edx
  80050b:	f7 d2                	not    %edx
  80050d:	21 55 d8             	and    %edx,-0x28(%ebp)
  800510:	eb 8b                	jmp    80049d <vprintfmt+0x61>
  800512:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  800519:	eb 82                	jmp    80049d <vprintfmt+0x61>

		process_precision:
			if (width < 0)
  80051b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80051f:	0f 89 78 ff ff ff    	jns    80049d <vprintfmt+0x61>
  800525:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800528:	8b 5d c8             	mov    -0x38(%ebp),%ebx
  80052b:	e9 6d ff ff ff       	jmp    80049d <vprintfmt+0x61>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800530:	83 c6 01             	add    $0x1,%esi
			goto reswitch;
  800533:	e9 65 ff ff ff       	jmp    80049d <vprintfmt+0x61>
  800538:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80053b:	8b 45 14             	mov    0x14(%ebp),%eax
  80053e:	8d 50 04             	lea    0x4(%eax),%edx
  800541:	89 55 14             	mov    %edx,0x14(%ebp)
  800544:	8b 55 0c             	mov    0xc(%ebp),%edx
  800547:	89 54 24 04          	mov    %edx,0x4(%esp)
  80054b:	8b 00                	mov    (%eax),%eax
  80054d:	89 04 24             	mov    %eax,(%esp)
  800550:	ff 55 08             	call   *0x8(%ebp)
  800553:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;
  800556:	e9 10 ff ff ff       	jmp    80046b <vprintfmt+0x2f>
  80055b:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  80055e:	8b 45 14             	mov    0x14(%ebp),%eax
  800561:	8d 50 04             	lea    0x4(%eax),%edx
  800564:	89 55 14             	mov    %edx,0x14(%ebp)
  800567:	8b 00                	mov    (%eax),%eax
  800569:	89 c2                	mov    %eax,%edx
  80056b:	c1 fa 1f             	sar    $0x1f,%edx
  80056e:	31 d0                	xor    %edx,%eax
  800570:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800572:	83 f8 08             	cmp    $0x8,%eax
  800575:	7f 0b                	jg     800582 <vprintfmt+0x146>
  800577:	8b 14 85 a0 1f 80 00 	mov    0x801fa0(,%eax,4),%edx
  80057e:	85 d2                	test   %edx,%edx
  800580:	75 26                	jne    8005a8 <vprintfmt+0x16c>
				printfmt(putch, putdat, "error %d", err);
  800582:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800586:	c7 44 24 08 00 1d 80 	movl   $0x801d00,0x8(%esp)
  80058d:	00 
  80058e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800591:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800595:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800598:	89 1c 24             	mov    %ebx,(%esp)
  80059b:	e8 a7 05 00 00       	call   800b47 <printfmt>
  8005a0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005a3:	e9 c3 fe ff ff       	jmp    80046b <vprintfmt+0x2f>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  8005a8:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005ac:	c7 44 24 08 09 1d 80 	movl   $0x801d09,0x8(%esp)
  8005b3:	00 
  8005b4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005b7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005bb:	8b 55 08             	mov    0x8(%ebp),%edx
  8005be:	89 14 24             	mov    %edx,(%esp)
  8005c1:	e8 81 05 00 00       	call   800b47 <printfmt>
  8005c6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005c9:	e9 9d fe ff ff       	jmp    80046b <vprintfmt+0x2f>
  8005ce:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8005d1:	89 c7                	mov    %eax,%edi
  8005d3:	89 d9                	mov    %ebx,%ecx
  8005d5:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005d8:	89 45 c0             	mov    %eax,-0x40(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005db:	8b 45 14             	mov    0x14(%ebp),%eax
  8005de:	8d 50 04             	lea    0x4(%eax),%edx
  8005e1:	89 55 14             	mov    %edx,0x14(%ebp)
  8005e4:	8b 30                	mov    (%eax),%esi
  8005e6:	85 f6                	test   %esi,%esi
  8005e8:	75 05                	jne    8005ef <vprintfmt+0x1b3>
  8005ea:	be 0c 1d 80 00       	mov    $0x801d0c,%esi
				p = "(null)";
			if (width > 0 && padc != '-')
  8005ef:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
  8005f3:	7e 06                	jle    8005fb <vprintfmt+0x1bf>
  8005f5:	80 7d cc 2d          	cmpb   $0x2d,-0x34(%ebp)
  8005f9:	75 10                	jne    80060b <vprintfmt+0x1cf>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005fb:	0f be 06             	movsbl (%esi),%eax
  8005fe:	85 c0                	test   %eax,%eax
  800600:	0f 85 a2 00 00 00    	jne    8006a8 <vprintfmt+0x26c>
  800606:	e9 92 00 00 00       	jmp    80069d <vprintfmt+0x261>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80060b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80060f:	89 34 24             	mov    %esi,(%esp)
  800612:	e8 74 05 00 00       	call   800b8b <strnlen>
  800617:	8b 55 c0             	mov    -0x40(%ebp),%edx
  80061a:	29 c2                	sub    %eax,%edx
  80061c:	89 55 d8             	mov    %edx,-0x28(%ebp)
  80061f:	85 d2                	test   %edx,%edx
  800621:	7e d8                	jle    8005fb <vprintfmt+0x1bf>
					putch(padc, putdat);
  800623:	0f be 4d cc          	movsbl -0x34(%ebp),%ecx
  800627:	89 5d c0             	mov    %ebx,-0x40(%ebp)
  80062a:	89 d3                	mov    %edx,%ebx
  80062c:	89 75 d8             	mov    %esi,-0x28(%ebp)
  80062f:	89 7d bc             	mov    %edi,-0x44(%ebp)
  800632:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800635:	89 ce                	mov    %ecx,%esi
  800637:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80063b:	89 34 24             	mov    %esi,(%esp)
  80063e:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800641:	83 eb 01             	sub    $0x1,%ebx
  800644:	85 db                	test   %ebx,%ebx
  800646:	7f ef                	jg     800637 <vprintfmt+0x1fb>
  800648:	8b 5d c0             	mov    -0x40(%ebp),%ebx
  80064b:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80064e:	8b 7d bc             	mov    -0x44(%ebp),%edi
  800651:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800658:	eb a1                	jmp    8005fb <vprintfmt+0x1bf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80065a:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  80065e:	74 1b                	je     80067b <vprintfmt+0x23f>
  800660:	8d 50 e0             	lea    -0x20(%eax),%edx
  800663:	83 fa 5e             	cmp    $0x5e,%edx
  800666:	76 13                	jbe    80067b <vprintfmt+0x23f>
					putch('?', putdat);
  800668:	8b 45 0c             	mov    0xc(%ebp),%eax
  80066b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80066f:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800676:	ff 55 08             	call   *0x8(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800679:	eb 0d                	jmp    800688 <vprintfmt+0x24c>
					putch('?', putdat);
				else
					putch(ch, putdat);
  80067b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80067e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800682:	89 04 24             	mov    %eax,(%esp)
  800685:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800688:	83 ef 01             	sub    $0x1,%edi
  80068b:	0f be 06             	movsbl (%esi),%eax
  80068e:	85 c0                	test   %eax,%eax
  800690:	74 05                	je     800697 <vprintfmt+0x25b>
  800692:	83 c6 01             	add    $0x1,%esi
  800695:	eb 1a                	jmp    8006b1 <vprintfmt+0x275>
  800697:	89 7d d8             	mov    %edi,-0x28(%ebp)
  80069a:	8b 7d cc             	mov    -0x34(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80069d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8006a1:	7f 1f                	jg     8006c2 <vprintfmt+0x286>
  8006a3:	e9 c0 fd ff ff       	jmp    800468 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006a8:	83 c6 01             	add    $0x1,%esi
  8006ab:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8006ae:	8b 7d d8             	mov    -0x28(%ebp),%edi
  8006b1:	85 db                	test   %ebx,%ebx
  8006b3:	78 a5                	js     80065a <vprintfmt+0x21e>
  8006b5:	83 eb 01             	sub    $0x1,%ebx
  8006b8:	79 a0                	jns    80065a <vprintfmt+0x21e>
  8006ba:	89 7d d8             	mov    %edi,-0x28(%ebp)
  8006bd:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8006c0:	eb db                	jmp    80069d <vprintfmt+0x261>
  8006c2:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  8006c5:	8b 75 0c             	mov    0xc(%ebp),%esi
  8006c8:	89 7d d8             	mov    %edi,-0x28(%ebp)
  8006cb:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006ce:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006d2:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8006d9:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006db:	83 eb 01             	sub    $0x1,%ebx
  8006de:	85 db                	test   %ebx,%ebx
  8006e0:	7f ec                	jg     8006ce <vprintfmt+0x292>
  8006e2:	8b 7d d8             	mov    -0x28(%ebp),%edi
  8006e5:	e9 81 fd ff ff       	jmp    80046b <vprintfmt+0x2f>
  8006ea:	89 45 e4             	mov    %eax,-0x1c(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006ed:	83 fe 01             	cmp    $0x1,%esi
  8006f0:	7e 10                	jle    800702 <vprintfmt+0x2c6>
		return va_arg(*ap, long long);
  8006f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f5:	8d 50 08             	lea    0x8(%eax),%edx
  8006f8:	89 55 14             	mov    %edx,0x14(%ebp)
  8006fb:	8b 18                	mov    (%eax),%ebx
  8006fd:	8b 70 04             	mov    0x4(%eax),%esi
  800700:	eb 26                	jmp    800728 <vprintfmt+0x2ec>
	else if (lflag)
  800702:	85 f6                	test   %esi,%esi
  800704:	74 12                	je     800718 <vprintfmt+0x2dc>
		return va_arg(*ap, long);
  800706:	8b 45 14             	mov    0x14(%ebp),%eax
  800709:	8d 50 04             	lea    0x4(%eax),%edx
  80070c:	89 55 14             	mov    %edx,0x14(%ebp)
  80070f:	8b 18                	mov    (%eax),%ebx
  800711:	89 de                	mov    %ebx,%esi
  800713:	c1 fe 1f             	sar    $0x1f,%esi
  800716:	eb 10                	jmp    800728 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  800718:	8b 45 14             	mov    0x14(%ebp),%eax
  80071b:	8d 50 04             	lea    0x4(%eax),%edx
  80071e:	89 55 14             	mov    %edx,0x14(%ebp)
  800721:	8b 18                	mov    (%eax),%ebx
  800723:	89 de                	mov    %ebx,%esi
  800725:	c1 fe 1f             	sar    $0x1f,%esi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
                        if(signflag == 1){
  800728:	83 f9 01             	cmp    $0x1,%ecx
  80072b:	75 1e                	jne    80074b <vprintfmt+0x30f>
                               if((long long)num > 0){
  80072d:	85 f6                	test   %esi,%esi
  80072f:	78 1a                	js     80074b <vprintfmt+0x30f>
  800731:	85 f6                	test   %esi,%esi
  800733:	7f 05                	jg     80073a <vprintfmt+0x2fe>
  800735:	83 fb 00             	cmp    $0x0,%ebx
  800738:	76 11                	jbe    80074b <vprintfmt+0x30f>
                                   putch('+',putdat);
  80073a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80073d:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800741:	c7 04 24 2b 00 00 00 	movl   $0x2b,(%esp)
  800748:	ff 55 08             	call   *0x8(%ebp)
                               }
                        }
			if ((long long) num < 0) {
  80074b:	85 f6                	test   %esi,%esi
  80074d:	78 13                	js     800762 <vprintfmt+0x326>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80074f:	89 5d b0             	mov    %ebx,-0x50(%ebp)
  800752:	89 75 b4             	mov    %esi,-0x4c(%ebp)
  800755:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800758:	b8 0a 00 00 00       	mov    $0xa,%eax
  80075d:	e9 da 00 00 00       	jmp    80083c <vprintfmt+0x400>
                               if((long long)num > 0){
                                   putch('+',putdat);
                               }
                        }
			if ((long long) num < 0) {
				putch('-', putdat);
  800762:	8b 45 0c             	mov    0xc(%ebp),%eax
  800765:	89 44 24 04          	mov    %eax,0x4(%esp)
  800769:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800770:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800773:	89 da                	mov    %ebx,%edx
  800775:	89 f1                	mov    %esi,%ecx
  800777:	f7 da                	neg    %edx
  800779:	83 d1 00             	adc    $0x0,%ecx
  80077c:	f7 d9                	neg    %ecx
  80077e:	89 55 b0             	mov    %edx,-0x50(%ebp)
  800781:	89 4d b4             	mov    %ecx,-0x4c(%ebp)
  800784:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800787:	b8 0a 00 00 00       	mov    $0xa,%eax
  80078c:	e9 ab 00 00 00       	jmp    80083c <vprintfmt+0x400>
  800791:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800794:	89 f2                	mov    %esi,%edx
  800796:	8d 45 14             	lea    0x14(%ebp),%eax
  800799:	e8 47 fc ff ff       	call   8003e5 <getuint>
  80079e:	89 45 b0             	mov    %eax,-0x50(%ebp)
  8007a1:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  8007a4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007a7:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
  8007ac:	e9 8b 00 00 00       	jmp    80083c <vprintfmt+0x400>
  8007b1:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			putch('0', putdat);
  8007b4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007b7:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8007bb:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8007c2:	ff 55 08             	call   *0x8(%ebp)
			num = getuint(&ap,lflag);
  8007c5:	89 f2                	mov    %esi,%edx
  8007c7:	8d 45 14             	lea    0x14(%ebp),%eax
  8007ca:	e8 16 fc ff ff       	call   8003e5 <getuint>
  8007cf:	89 45 b0             	mov    %eax,-0x50(%ebp)
  8007d2:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  8007d5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007d8:	b8 08 00 00 00       	mov    $0x8,%eax
                        base = 8;
			goto number;
  8007dd:	eb 5d                	jmp    80083c <vprintfmt+0x400>
  8007df:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
  8007e2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007e5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007e9:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8007f0:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8007f3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007f7:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8007fe:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  800801:	8b 45 14             	mov    0x14(%ebp),%eax
  800804:	8d 50 04             	lea    0x4(%eax),%edx
  800807:	89 55 14             	mov    %edx,0x14(%ebp)
  80080a:	8b 10                	mov    (%eax),%edx
  80080c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800811:	89 55 b0             	mov    %edx,-0x50(%ebp)
  800814:	89 4d b4             	mov    %ecx,-0x4c(%ebp)
  800817:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80081a:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80081f:	eb 1b                	jmp    80083c <vprintfmt+0x400>
  800821:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800824:	89 f2                	mov    %esi,%edx
  800826:	8d 45 14             	lea    0x14(%ebp),%eax
  800829:	e8 b7 fb ff ff       	call   8003e5 <getuint>
  80082e:	89 45 b0             	mov    %eax,-0x50(%ebp)
  800831:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  800834:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800837:	b8 10 00 00 00       	mov    $0x10,%eax
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  80083c:	0f be 4d cc          	movsbl -0x34(%ebp),%ecx
  800840:	89 4d d0             	mov    %ecx,-0x30(%ebp)
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800843:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800846:	83 7d b4 00          	cmpl   $0x0,-0x4c(%ebp)
  80084a:	77 09                	ja     800855 <vprintfmt+0x419>
  80084c:	39 45 b0             	cmp    %eax,-0x50(%ebp)
  80084f:	0f 82 ac 00 00 00    	jb     800901 <vprintfmt+0x4c5>
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
  800855:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800858:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  80085c:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80085f:	83 ea 01             	sub    $0x1,%edx
  800862:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800866:	89 44 24 08          	mov    %eax,0x8(%esp)
  80086a:	8b 44 24 08          	mov    0x8(%esp),%eax
  80086e:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800872:	89 45 c0             	mov    %eax,-0x40(%ebp)
  800875:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  800878:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80087b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80087f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800886:	00 
  800887:	8b 4d b0             	mov    -0x50(%ebp),%ecx
  80088a:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
  80088d:	89 0c 24             	mov    %ecx,(%esp)
  800890:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800894:	e8 97 11 00 00       	call   801a30 <__udivdi3>
  800899:	8b 4d c0             	mov    -0x40(%ebp),%ecx
  80089c:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  80089f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8008a3:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8008a7:	89 04 24             	mov    %eax,(%esp)
  8008aa:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008ae:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b4:	e8 37 fa ff ff       	call   8002f0 <printnum_v2>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8008b9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8008bc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008c0:	8b 74 24 04          	mov    0x4(%esp),%esi
  8008c4:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8008c7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008cb:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8008d2:	00 
  8008d3:	8b 55 b0             	mov    -0x50(%ebp),%edx
  8008d6:	8b 4d b4             	mov    -0x4c(%ebp),%ecx
  8008d9:	89 14 24             	mov    %edx,(%esp)
  8008dc:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8008e0:	e8 7b 12 00 00       	call   801b60 <__umoddi3>
  8008e5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8008e9:	0f be 80 ef 1c 80 00 	movsbl 0x801cef(%eax),%eax
  8008f0:	89 04 24             	mov    %eax,(%esp)
  8008f3:	ff 55 08             	call   *0x8(%ebp)
        if(padc == '-'){
  8008f6:	83 7d d0 2d          	cmpl   $0x2d,-0x30(%ebp)
  8008fa:	74 54                	je     800950 <vprintfmt+0x514>
  8008fc:	e9 67 fb ff ff       	jmp    800468 <vprintfmt+0x2c>
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
  800901:	83 7d d0 2d          	cmpl   $0x2d,-0x30(%ebp)
  800905:	8d 76 00             	lea    0x0(%esi),%esi
  800908:	0f 84 2a 01 00 00    	je     800a38 <vprintfmt+0x5fc>
		while (--width > 0)
  80090e:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800911:	83 ef 01             	sub    $0x1,%edi
  800914:	85 ff                	test   %edi,%edi
  800916:	0f 8e 5e 01 00 00    	jle    800a7a <vprintfmt+0x63e>
  80091c:	8b 4d b0             	mov    -0x50(%ebp),%ecx
  80091f:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
  800922:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  800925:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  800928:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80092b:	8b 75 0c             	mov    0xc(%ebp),%esi
			putch(padc, putdat);
  80092e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800932:	89 1c 24             	mov    %ebx,(%esp)
  800935:	ff 55 08             	call   *0x8(%ebp)
	if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
		while (--width > 0)
  800938:	83 ef 01             	sub    $0x1,%edi
  80093b:	85 ff                	test   %edi,%edi
  80093d:	7f ef                	jg     80092e <vprintfmt+0x4f2>
  80093f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800942:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800945:	89 45 b0             	mov    %eax,-0x50(%ebp)
  800948:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  80094b:	e9 2a 01 00 00       	jmp    800a7a <vprintfmt+0x63e>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
        if(padc == '-'){
           while (--width > 0)
  800950:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800953:	83 eb 01             	sub    $0x1,%ebx
  800956:	85 db                	test   %ebx,%ebx
  800958:	0f 8e 0a fb ff ff    	jle    800468 <vprintfmt+0x2c>
  80095e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800961:	89 7d d8             	mov    %edi,-0x28(%ebp)
  800964:	8b 7d 08             	mov    0x8(%ebp),%edi
			putch(' ', putdat);
  800967:	89 74 24 04          	mov    %esi,0x4(%esp)
  80096b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800972:	ff d7                	call   *%edi
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
        if(padc == '-'){
           while (--width > 0)
  800974:	83 eb 01             	sub    $0x1,%ebx
  800977:	85 db                	test   %ebx,%ebx
  800979:	7f ec                	jg     800967 <vprintfmt+0x52b>
  80097b:	8b 7d d8             	mov    -0x28(%ebp),%edi
  80097e:	e9 e8 fa ff ff       	jmp    80046b <vprintfmt+0x2f>
  800983:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
            char* n;
            if ((n = va_arg(ap, char *)) == NULL)
  800986:	8b 45 14             	mov    0x14(%ebp),%eax
  800989:	8d 50 04             	lea    0x4(%eax),%edx
  80098c:	89 55 14             	mov    %edx,0x14(%ebp)
  80098f:	8b 00                	mov    (%eax),%eax
  800991:	85 c0                	test   %eax,%eax
  800993:	75 2a                	jne    8009bf <vprintfmt+0x583>
		  printfmt(putch,putdat,"%s",null_error);
  800995:	c7 44 24 0c a8 1d 80 	movl   $0x801da8,0xc(%esp)
  80099c:	00 
  80099d:	c7 44 24 08 09 1d 80 	movl   $0x801d09,0x8(%esp)
  8009a4:	00 
  8009a5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009a8:	89 54 24 04          	mov    %edx,0x4(%esp)
  8009ac:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009af:	89 0c 24             	mov    %ecx,(%esp)
  8009b2:	e8 90 01 00 00       	call   800b47 <printfmt>
  8009b7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8009ba:	e9 ac fa ff ff       	jmp    80046b <vprintfmt+0x2f>
            else if((*(int*)putdat) > 127){
  8009bf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8009c2:	8b 13                	mov    (%ebx),%edx
  8009c4:	83 fa 7f             	cmp    $0x7f,%edx
  8009c7:	7e 29                	jle    8009f2 <vprintfmt+0x5b6>
                  *n = *(int*)putdat;
  8009c9:	88 10                	mov    %dl,(%eax)
                  printfmt(putch,putdat,"%s",overflow_error);
  8009cb:	c7 44 24 0c e0 1d 80 	movl   $0x801de0,0xc(%esp)
  8009d2:	00 
  8009d3:	c7 44 24 08 09 1d 80 	movl   $0x801d09,0x8(%esp)
  8009da:	00 
  8009db:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009df:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e2:	89 04 24             	mov    %eax,(%esp)
  8009e5:	e8 5d 01 00 00       	call   800b47 <printfmt>
  8009ea:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8009ed:	e9 79 fa ff ff       	jmp    80046b <vprintfmt+0x2f>
            }
            else
                  *n = *(int*)putdat;
  8009f2:	88 10                	mov    %dl,(%eax)
  8009f4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8009f7:	e9 6f fa ff ff       	jmp    80046b <vprintfmt+0x2f>
  8009fc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8009ff:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            break;
        }
		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800a02:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a05:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800a09:	89 14 24             	mov    %edx,(%esp)
  800a0c:	ff 55 08             	call   *0x8(%ebp)
  800a0f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;
  800a12:	e9 54 fa ff ff       	jmp    80046b <vprintfmt+0x2f>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800a17:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a1a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a1e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800a25:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800a28:	8d 47 ff             	lea    -0x1(%edi),%eax
  800a2b:	80 38 25             	cmpb   $0x25,(%eax)
  800a2e:	0f 84 37 fa ff ff    	je     80046b <vprintfmt+0x2f>
  800a34:	89 c7                	mov    %eax,%edi
  800a36:	eb f0                	jmp    800a28 <vprintfmt+0x5ec>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800a38:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a3b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a3f:	8b 74 24 04          	mov    0x4(%esp),%esi
  800a43:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800a46:	89 54 24 08          	mov    %edx,0x8(%esp)
  800a4a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800a51:	00 
  800a52:	8b 45 b0             	mov    -0x50(%ebp),%eax
  800a55:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  800a58:	89 04 24             	mov    %eax,(%esp)
  800a5b:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a5f:	e8 fc 10 00 00       	call   801b60 <__umoddi3>
  800a64:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a68:	0f be 80 ef 1c 80 00 	movsbl 0x801cef(%eax),%eax
  800a6f:	89 04 24             	mov    %eax,(%esp)
  800a72:	ff 55 08             	call   *0x8(%ebp)
  800a75:	e9 d6 fe ff ff       	jmp    800950 <vprintfmt+0x514>
  800a7a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a7d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a81:	8b 74 24 04          	mov    0x4(%esp),%esi
  800a85:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800a88:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800a8c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800a93:	00 
  800a94:	8b 45 b0             	mov    -0x50(%ebp),%eax
  800a97:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  800a9a:	89 04 24             	mov    %eax,(%esp)
  800a9d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800aa1:	e8 ba 10 00 00       	call   801b60 <__umoddi3>
  800aa6:	89 74 24 04          	mov    %esi,0x4(%esp)
  800aaa:	0f be 80 ef 1c 80 00 	movsbl 0x801cef(%eax),%eax
  800ab1:	89 04 24             	mov    %eax,(%esp)
  800ab4:	ff 55 08             	call   *0x8(%ebp)
  800ab7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800aba:	e9 ac f9 ff ff       	jmp    80046b <vprintfmt+0x2f>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800abf:	83 c4 6c             	add    $0x6c,%esp
  800ac2:	5b                   	pop    %ebx
  800ac3:	5e                   	pop    %esi
  800ac4:	5f                   	pop    %edi
  800ac5:	5d                   	pop    %ebp
  800ac6:	c3                   	ret    

00800ac7 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800ac7:	55                   	push   %ebp
  800ac8:	89 e5                	mov    %esp,%ebp
  800aca:	83 ec 28             	sub    $0x28,%esp
  800acd:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad0:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  800ad3:	85 c0                	test   %eax,%eax
  800ad5:	74 04                	je     800adb <vsnprintf+0x14>
  800ad7:	85 d2                	test   %edx,%edx
  800ad9:	7f 07                	jg     800ae2 <vsnprintf+0x1b>
  800adb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ae0:	eb 3b                	jmp    800b1d <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  800ae2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800ae5:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  800ae9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800aec:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800af3:	8b 45 14             	mov    0x14(%ebp),%eax
  800af6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800afa:	8b 45 10             	mov    0x10(%ebp),%eax
  800afd:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b01:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800b04:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b08:	c7 04 24 1f 04 80 00 	movl   $0x80041f,(%esp)
  800b0f:	e8 28 f9 ff ff       	call   80043c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800b14:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b17:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800b1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800b1d:	c9                   	leave  
  800b1e:	c3                   	ret    

00800b1f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800b1f:	55                   	push   %ebp
  800b20:	89 e5                	mov    %esp,%ebp
  800b22:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  800b25:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  800b28:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b2c:	8b 45 10             	mov    0x10(%ebp),%eax
  800b2f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b33:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b36:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b3a:	8b 45 08             	mov    0x8(%ebp),%eax
  800b3d:	89 04 24             	mov    %eax,(%esp)
  800b40:	e8 82 ff ff ff       	call   800ac7 <vsnprintf>
	va_end(ap);

	return rc;
}
  800b45:	c9                   	leave  
  800b46:	c3                   	ret    

00800b47 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800b47:	55                   	push   %ebp
  800b48:	89 e5                	mov    %esp,%ebp
  800b4a:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  800b4d:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  800b50:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b54:	8b 45 10             	mov    0x10(%ebp),%eax
  800b57:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b5b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b5e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b62:	8b 45 08             	mov    0x8(%ebp),%eax
  800b65:	89 04 24             	mov    %eax,(%esp)
  800b68:	e8 cf f8 ff ff       	call   80043c <vprintfmt>
	va_end(ap);
}
  800b6d:	c9                   	leave  
  800b6e:	c3                   	ret    
	...

00800b70 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800b70:	55                   	push   %ebp
  800b71:	89 e5                	mov    %esp,%ebp
  800b73:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800b76:	b8 00 00 00 00       	mov    $0x0,%eax
  800b7b:	80 3a 00             	cmpb   $0x0,(%edx)
  800b7e:	74 09                	je     800b89 <strlen+0x19>
		n++;
  800b80:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800b83:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800b87:	75 f7                	jne    800b80 <strlen+0x10>
		n++;
	return n;
}
  800b89:	5d                   	pop    %ebp
  800b8a:	c3                   	ret    

00800b8b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800b8b:	55                   	push   %ebp
  800b8c:	89 e5                	mov    %esp,%ebp
  800b8e:	53                   	push   %ebx
  800b8f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800b92:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b95:	85 c9                	test   %ecx,%ecx
  800b97:	74 19                	je     800bb2 <strnlen+0x27>
  800b99:	80 3b 00             	cmpb   $0x0,(%ebx)
  800b9c:	74 14                	je     800bb2 <strnlen+0x27>
  800b9e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800ba3:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800ba6:	39 c8                	cmp    %ecx,%eax
  800ba8:	74 0d                	je     800bb7 <strnlen+0x2c>
  800baa:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  800bae:	75 f3                	jne    800ba3 <strnlen+0x18>
  800bb0:	eb 05                	jmp    800bb7 <strnlen+0x2c>
  800bb2:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800bb7:	5b                   	pop    %ebx
  800bb8:	5d                   	pop    %ebp
  800bb9:	c3                   	ret    

00800bba <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800bba:	55                   	push   %ebp
  800bbb:	89 e5                	mov    %esp,%ebp
  800bbd:	53                   	push   %ebx
  800bbe:	8b 45 08             	mov    0x8(%ebp),%eax
  800bc1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800bc4:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800bc9:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800bcd:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800bd0:	83 c2 01             	add    $0x1,%edx
  800bd3:	84 c9                	test   %cl,%cl
  800bd5:	75 f2                	jne    800bc9 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800bd7:	5b                   	pop    %ebx
  800bd8:	5d                   	pop    %ebp
  800bd9:	c3                   	ret    

00800bda <strcat>:

char *
strcat(char *dst, const char *src)
{
  800bda:	55                   	push   %ebp
  800bdb:	89 e5                	mov    %esp,%ebp
  800bdd:	53                   	push   %ebx
  800bde:	83 ec 08             	sub    $0x8,%esp
  800be1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800be4:	89 1c 24             	mov    %ebx,(%esp)
  800be7:	e8 84 ff ff ff       	call   800b70 <strlen>
	strcpy(dst + len, src);
  800bec:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bef:	89 54 24 04          	mov    %edx,0x4(%esp)
  800bf3:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800bf6:	89 04 24             	mov    %eax,(%esp)
  800bf9:	e8 bc ff ff ff       	call   800bba <strcpy>
	return dst;
}
  800bfe:	89 d8                	mov    %ebx,%eax
  800c00:	83 c4 08             	add    $0x8,%esp
  800c03:	5b                   	pop    %ebx
  800c04:	5d                   	pop    %ebp
  800c05:	c3                   	ret    

00800c06 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800c06:	55                   	push   %ebp
  800c07:	89 e5                	mov    %esp,%ebp
  800c09:	56                   	push   %esi
  800c0a:	53                   	push   %ebx
  800c0b:	8b 45 08             	mov    0x8(%ebp),%eax
  800c0e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c11:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800c14:	85 f6                	test   %esi,%esi
  800c16:	74 18                	je     800c30 <strncpy+0x2a>
  800c18:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800c1d:	0f b6 1a             	movzbl (%edx),%ebx
  800c20:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800c23:	80 3a 01             	cmpb   $0x1,(%edx)
  800c26:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800c29:	83 c1 01             	add    $0x1,%ecx
  800c2c:	39 ce                	cmp    %ecx,%esi
  800c2e:	77 ed                	ja     800c1d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800c30:	5b                   	pop    %ebx
  800c31:	5e                   	pop    %esi
  800c32:	5d                   	pop    %ebp
  800c33:	c3                   	ret    

00800c34 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800c34:	55                   	push   %ebp
  800c35:	89 e5                	mov    %esp,%ebp
  800c37:	56                   	push   %esi
  800c38:	53                   	push   %ebx
  800c39:	8b 75 08             	mov    0x8(%ebp),%esi
  800c3c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c3f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800c42:	89 f0                	mov    %esi,%eax
  800c44:	85 c9                	test   %ecx,%ecx
  800c46:	74 27                	je     800c6f <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  800c48:	83 e9 01             	sub    $0x1,%ecx
  800c4b:	74 1d                	je     800c6a <strlcpy+0x36>
  800c4d:	0f b6 1a             	movzbl (%edx),%ebx
  800c50:	84 db                	test   %bl,%bl
  800c52:	74 16                	je     800c6a <strlcpy+0x36>
			*dst++ = *src++;
  800c54:	88 18                	mov    %bl,(%eax)
  800c56:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800c59:	83 e9 01             	sub    $0x1,%ecx
  800c5c:	74 0e                	je     800c6c <strlcpy+0x38>
			*dst++ = *src++;
  800c5e:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800c61:	0f b6 1a             	movzbl (%edx),%ebx
  800c64:	84 db                	test   %bl,%bl
  800c66:	75 ec                	jne    800c54 <strlcpy+0x20>
  800c68:	eb 02                	jmp    800c6c <strlcpy+0x38>
  800c6a:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800c6c:	c6 00 00             	movb   $0x0,(%eax)
  800c6f:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800c71:	5b                   	pop    %ebx
  800c72:	5e                   	pop    %esi
  800c73:	5d                   	pop    %ebp
  800c74:	c3                   	ret    

00800c75 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800c75:	55                   	push   %ebp
  800c76:	89 e5                	mov    %esp,%ebp
  800c78:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c7b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800c7e:	0f b6 01             	movzbl (%ecx),%eax
  800c81:	84 c0                	test   %al,%al
  800c83:	74 15                	je     800c9a <strcmp+0x25>
  800c85:	3a 02                	cmp    (%edx),%al
  800c87:	75 11                	jne    800c9a <strcmp+0x25>
		p++, q++;
  800c89:	83 c1 01             	add    $0x1,%ecx
  800c8c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800c8f:	0f b6 01             	movzbl (%ecx),%eax
  800c92:	84 c0                	test   %al,%al
  800c94:	74 04                	je     800c9a <strcmp+0x25>
  800c96:	3a 02                	cmp    (%edx),%al
  800c98:	74 ef                	je     800c89 <strcmp+0x14>
  800c9a:	0f b6 c0             	movzbl %al,%eax
  800c9d:	0f b6 12             	movzbl (%edx),%edx
  800ca0:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800ca2:	5d                   	pop    %ebp
  800ca3:	c3                   	ret    

00800ca4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800ca4:	55                   	push   %ebp
  800ca5:	89 e5                	mov    %esp,%ebp
  800ca7:	53                   	push   %ebx
  800ca8:	8b 55 08             	mov    0x8(%ebp),%edx
  800cab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cae:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800cb1:	85 c0                	test   %eax,%eax
  800cb3:	74 23                	je     800cd8 <strncmp+0x34>
  800cb5:	0f b6 1a             	movzbl (%edx),%ebx
  800cb8:	84 db                	test   %bl,%bl
  800cba:	74 25                	je     800ce1 <strncmp+0x3d>
  800cbc:	3a 19                	cmp    (%ecx),%bl
  800cbe:	75 21                	jne    800ce1 <strncmp+0x3d>
  800cc0:	83 e8 01             	sub    $0x1,%eax
  800cc3:	74 13                	je     800cd8 <strncmp+0x34>
		n--, p++, q++;
  800cc5:	83 c2 01             	add    $0x1,%edx
  800cc8:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800ccb:	0f b6 1a             	movzbl (%edx),%ebx
  800cce:	84 db                	test   %bl,%bl
  800cd0:	74 0f                	je     800ce1 <strncmp+0x3d>
  800cd2:	3a 19                	cmp    (%ecx),%bl
  800cd4:	74 ea                	je     800cc0 <strncmp+0x1c>
  800cd6:	eb 09                	jmp    800ce1 <strncmp+0x3d>
  800cd8:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800cdd:	5b                   	pop    %ebx
  800cde:	5d                   	pop    %ebp
  800cdf:	90                   	nop
  800ce0:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800ce1:	0f b6 02             	movzbl (%edx),%eax
  800ce4:	0f b6 11             	movzbl (%ecx),%edx
  800ce7:	29 d0                	sub    %edx,%eax
  800ce9:	eb f2                	jmp    800cdd <strncmp+0x39>

00800ceb <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800ceb:	55                   	push   %ebp
  800cec:	89 e5                	mov    %esp,%ebp
  800cee:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800cf5:	0f b6 10             	movzbl (%eax),%edx
  800cf8:	84 d2                	test   %dl,%dl
  800cfa:	74 18                	je     800d14 <strchr+0x29>
		if (*s == c)
  800cfc:	38 ca                	cmp    %cl,%dl
  800cfe:	75 0a                	jne    800d0a <strchr+0x1f>
  800d00:	eb 17                	jmp    800d19 <strchr+0x2e>
  800d02:	38 ca                	cmp    %cl,%dl
  800d04:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800d08:	74 0f                	je     800d19 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800d0a:	83 c0 01             	add    $0x1,%eax
  800d0d:	0f b6 10             	movzbl (%eax),%edx
  800d10:	84 d2                	test   %dl,%dl
  800d12:	75 ee                	jne    800d02 <strchr+0x17>
  800d14:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800d19:	5d                   	pop    %ebp
  800d1a:	c3                   	ret    

00800d1b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800d1b:	55                   	push   %ebp
  800d1c:	89 e5                	mov    %esp,%ebp
  800d1e:	8b 45 08             	mov    0x8(%ebp),%eax
  800d21:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800d25:	0f b6 10             	movzbl (%eax),%edx
  800d28:	84 d2                	test   %dl,%dl
  800d2a:	74 18                	je     800d44 <strfind+0x29>
		if (*s == c)
  800d2c:	38 ca                	cmp    %cl,%dl
  800d2e:	75 0a                	jne    800d3a <strfind+0x1f>
  800d30:	eb 12                	jmp    800d44 <strfind+0x29>
  800d32:	38 ca                	cmp    %cl,%dl
  800d34:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800d38:	74 0a                	je     800d44 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800d3a:	83 c0 01             	add    $0x1,%eax
  800d3d:	0f b6 10             	movzbl (%eax),%edx
  800d40:	84 d2                	test   %dl,%dl
  800d42:	75 ee                	jne    800d32 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800d44:	5d                   	pop    %ebp
  800d45:	c3                   	ret    

00800d46 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800d46:	55                   	push   %ebp
  800d47:	89 e5                	mov    %esp,%ebp
  800d49:	83 ec 0c             	sub    $0xc,%esp
  800d4c:	89 1c 24             	mov    %ebx,(%esp)
  800d4f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d53:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800d57:	8b 7d 08             	mov    0x8(%ebp),%edi
  800d5a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d5d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800d60:	85 c9                	test   %ecx,%ecx
  800d62:	74 30                	je     800d94 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800d64:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800d6a:	75 25                	jne    800d91 <memset+0x4b>
  800d6c:	f6 c1 03             	test   $0x3,%cl
  800d6f:	75 20                	jne    800d91 <memset+0x4b>
		c &= 0xFF;
  800d71:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800d74:	89 d3                	mov    %edx,%ebx
  800d76:	c1 e3 08             	shl    $0x8,%ebx
  800d79:	89 d6                	mov    %edx,%esi
  800d7b:	c1 e6 18             	shl    $0x18,%esi
  800d7e:	89 d0                	mov    %edx,%eax
  800d80:	c1 e0 10             	shl    $0x10,%eax
  800d83:	09 f0                	or     %esi,%eax
  800d85:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  800d87:	09 d8                	or     %ebx,%eax
  800d89:	c1 e9 02             	shr    $0x2,%ecx
  800d8c:	fc                   	cld    
  800d8d:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800d8f:	eb 03                	jmp    800d94 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800d91:	fc                   	cld    
  800d92:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800d94:	89 f8                	mov    %edi,%eax
  800d96:	8b 1c 24             	mov    (%esp),%ebx
  800d99:	8b 74 24 04          	mov    0x4(%esp),%esi
  800d9d:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800da1:	89 ec                	mov    %ebp,%esp
  800da3:	5d                   	pop    %ebp
  800da4:	c3                   	ret    

00800da5 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800da5:	55                   	push   %ebp
  800da6:	89 e5                	mov    %esp,%ebp
  800da8:	83 ec 08             	sub    $0x8,%esp
  800dab:	89 34 24             	mov    %esi,(%esp)
  800dae:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800db2:	8b 45 08             	mov    0x8(%ebp),%eax
  800db5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800db8:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800dbb:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800dbd:	39 c6                	cmp    %eax,%esi
  800dbf:	73 35                	jae    800df6 <memmove+0x51>
  800dc1:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800dc4:	39 d0                	cmp    %edx,%eax
  800dc6:	73 2e                	jae    800df6 <memmove+0x51>
		s += n;
		d += n;
  800dc8:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800dca:	f6 c2 03             	test   $0x3,%dl
  800dcd:	75 1b                	jne    800dea <memmove+0x45>
  800dcf:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800dd5:	75 13                	jne    800dea <memmove+0x45>
  800dd7:	f6 c1 03             	test   $0x3,%cl
  800dda:	75 0e                	jne    800dea <memmove+0x45>
			asm volatile("std; rep movsl\n"
  800ddc:	83 ef 04             	sub    $0x4,%edi
  800ddf:	8d 72 fc             	lea    -0x4(%edx),%esi
  800de2:	c1 e9 02             	shr    $0x2,%ecx
  800de5:	fd                   	std    
  800de6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800de8:	eb 09                	jmp    800df3 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800dea:	83 ef 01             	sub    $0x1,%edi
  800ded:	8d 72 ff             	lea    -0x1(%edx),%esi
  800df0:	fd                   	std    
  800df1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800df3:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800df4:	eb 20                	jmp    800e16 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800df6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800dfc:	75 15                	jne    800e13 <memmove+0x6e>
  800dfe:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800e04:	75 0d                	jne    800e13 <memmove+0x6e>
  800e06:	f6 c1 03             	test   $0x3,%cl
  800e09:	75 08                	jne    800e13 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  800e0b:	c1 e9 02             	shr    $0x2,%ecx
  800e0e:	fc                   	cld    
  800e0f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e11:	eb 03                	jmp    800e16 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800e13:	fc                   	cld    
  800e14:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800e16:	8b 34 24             	mov    (%esp),%esi
  800e19:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800e1d:	89 ec                	mov    %ebp,%esp
  800e1f:	5d                   	pop    %ebp
  800e20:	c3                   	ret    

00800e21 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800e21:	55                   	push   %ebp
  800e22:	89 e5                	mov    %esp,%ebp
  800e24:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800e27:	8b 45 10             	mov    0x10(%ebp),%eax
  800e2a:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e2e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e31:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e35:	8b 45 08             	mov    0x8(%ebp),%eax
  800e38:	89 04 24             	mov    %eax,(%esp)
  800e3b:	e8 65 ff ff ff       	call   800da5 <memmove>
}
  800e40:	c9                   	leave  
  800e41:	c3                   	ret    

00800e42 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800e42:	55                   	push   %ebp
  800e43:	89 e5                	mov    %esp,%ebp
  800e45:	57                   	push   %edi
  800e46:	56                   	push   %esi
  800e47:	53                   	push   %ebx
  800e48:	8b 75 08             	mov    0x8(%ebp),%esi
  800e4b:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800e4e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e51:	85 c9                	test   %ecx,%ecx
  800e53:	74 36                	je     800e8b <memcmp+0x49>
		if (*s1 != *s2)
  800e55:	0f b6 06             	movzbl (%esi),%eax
  800e58:	0f b6 1f             	movzbl (%edi),%ebx
  800e5b:	38 d8                	cmp    %bl,%al
  800e5d:	74 20                	je     800e7f <memcmp+0x3d>
  800e5f:	eb 14                	jmp    800e75 <memcmp+0x33>
  800e61:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  800e66:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  800e6b:	83 c2 01             	add    $0x1,%edx
  800e6e:	83 e9 01             	sub    $0x1,%ecx
  800e71:	38 d8                	cmp    %bl,%al
  800e73:	74 12                	je     800e87 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  800e75:	0f b6 c0             	movzbl %al,%eax
  800e78:	0f b6 db             	movzbl %bl,%ebx
  800e7b:	29 d8                	sub    %ebx,%eax
  800e7d:	eb 11                	jmp    800e90 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e7f:	83 e9 01             	sub    $0x1,%ecx
  800e82:	ba 00 00 00 00       	mov    $0x0,%edx
  800e87:	85 c9                	test   %ecx,%ecx
  800e89:	75 d6                	jne    800e61 <memcmp+0x1f>
  800e8b:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800e90:	5b                   	pop    %ebx
  800e91:	5e                   	pop    %esi
  800e92:	5f                   	pop    %edi
  800e93:	5d                   	pop    %ebp
  800e94:	c3                   	ret    

00800e95 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800e95:	55                   	push   %ebp
  800e96:	89 e5                	mov    %esp,%ebp
  800e98:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800e9b:	89 c2                	mov    %eax,%edx
  800e9d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ea0:	39 d0                	cmp    %edx,%eax
  800ea2:	73 15                	jae    800eb9 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ea4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800ea8:	38 08                	cmp    %cl,(%eax)
  800eaa:	75 06                	jne    800eb2 <memfind+0x1d>
  800eac:	eb 0b                	jmp    800eb9 <memfind+0x24>
  800eae:	38 08                	cmp    %cl,(%eax)
  800eb0:	74 07                	je     800eb9 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800eb2:	83 c0 01             	add    $0x1,%eax
  800eb5:	39 c2                	cmp    %eax,%edx
  800eb7:	77 f5                	ja     800eae <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800eb9:	5d                   	pop    %ebp
  800eba:	c3                   	ret    

00800ebb <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ebb:	55                   	push   %ebp
  800ebc:	89 e5                	mov    %esp,%ebp
  800ebe:	57                   	push   %edi
  800ebf:	56                   	push   %esi
  800ec0:	53                   	push   %ebx
  800ec1:	83 ec 04             	sub    $0x4,%esp
  800ec4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ec7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800eca:	0f b6 02             	movzbl (%edx),%eax
  800ecd:	3c 20                	cmp    $0x20,%al
  800ecf:	74 04                	je     800ed5 <strtol+0x1a>
  800ed1:	3c 09                	cmp    $0x9,%al
  800ed3:	75 0e                	jne    800ee3 <strtol+0x28>
		s++;
  800ed5:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ed8:	0f b6 02             	movzbl (%edx),%eax
  800edb:	3c 20                	cmp    $0x20,%al
  800edd:	74 f6                	je     800ed5 <strtol+0x1a>
  800edf:	3c 09                	cmp    $0x9,%al
  800ee1:	74 f2                	je     800ed5 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ee3:	3c 2b                	cmp    $0x2b,%al
  800ee5:	75 0c                	jne    800ef3 <strtol+0x38>
		s++;
  800ee7:	83 c2 01             	add    $0x1,%edx
  800eea:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800ef1:	eb 15                	jmp    800f08 <strtol+0x4d>
	else if (*s == '-')
  800ef3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800efa:	3c 2d                	cmp    $0x2d,%al
  800efc:	75 0a                	jne    800f08 <strtol+0x4d>
		s++, neg = 1;
  800efe:	83 c2 01             	add    $0x1,%edx
  800f01:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800f08:	85 db                	test   %ebx,%ebx
  800f0a:	0f 94 c0             	sete   %al
  800f0d:	74 05                	je     800f14 <strtol+0x59>
  800f0f:	83 fb 10             	cmp    $0x10,%ebx
  800f12:	75 18                	jne    800f2c <strtol+0x71>
  800f14:	80 3a 30             	cmpb   $0x30,(%edx)
  800f17:	75 13                	jne    800f2c <strtol+0x71>
  800f19:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800f1d:	8d 76 00             	lea    0x0(%esi),%esi
  800f20:	75 0a                	jne    800f2c <strtol+0x71>
		s += 2, base = 16;
  800f22:	83 c2 02             	add    $0x2,%edx
  800f25:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800f2a:	eb 15                	jmp    800f41 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800f2c:	84 c0                	test   %al,%al
  800f2e:	66 90                	xchg   %ax,%ax
  800f30:	74 0f                	je     800f41 <strtol+0x86>
  800f32:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800f37:	80 3a 30             	cmpb   $0x30,(%edx)
  800f3a:	75 05                	jne    800f41 <strtol+0x86>
		s++, base = 8;
  800f3c:	83 c2 01             	add    $0x1,%edx
  800f3f:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800f41:	b8 00 00 00 00       	mov    $0x0,%eax
  800f46:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800f48:	0f b6 0a             	movzbl (%edx),%ecx
  800f4b:	89 cf                	mov    %ecx,%edi
  800f4d:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800f50:	80 fb 09             	cmp    $0x9,%bl
  800f53:	77 08                	ja     800f5d <strtol+0xa2>
			dig = *s - '0';
  800f55:	0f be c9             	movsbl %cl,%ecx
  800f58:	83 e9 30             	sub    $0x30,%ecx
  800f5b:	eb 1e                	jmp    800f7b <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  800f5d:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  800f60:	80 fb 19             	cmp    $0x19,%bl
  800f63:	77 08                	ja     800f6d <strtol+0xb2>
			dig = *s - 'a' + 10;
  800f65:	0f be c9             	movsbl %cl,%ecx
  800f68:	83 e9 57             	sub    $0x57,%ecx
  800f6b:	eb 0e                	jmp    800f7b <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  800f6d:	8d 5f bf             	lea    -0x41(%edi),%ebx
  800f70:	80 fb 19             	cmp    $0x19,%bl
  800f73:	77 15                	ja     800f8a <strtol+0xcf>
			dig = *s - 'A' + 10;
  800f75:	0f be c9             	movsbl %cl,%ecx
  800f78:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800f7b:	39 f1                	cmp    %esi,%ecx
  800f7d:	7d 0b                	jge    800f8a <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  800f7f:	83 c2 01             	add    $0x1,%edx
  800f82:	0f af c6             	imul   %esi,%eax
  800f85:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800f88:	eb be                	jmp    800f48 <strtol+0x8d>
  800f8a:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800f8c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800f90:	74 05                	je     800f97 <strtol+0xdc>
		*endptr = (char *) s;
  800f92:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800f95:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800f97:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800f9b:	74 04                	je     800fa1 <strtol+0xe6>
  800f9d:	89 c8                	mov    %ecx,%eax
  800f9f:	f7 d8                	neg    %eax
}
  800fa1:	83 c4 04             	add    $0x4,%esp
  800fa4:	5b                   	pop    %ebx
  800fa5:	5e                   	pop    %esi
  800fa6:	5f                   	pop    %edi
  800fa7:	5d                   	pop    %ebp
  800fa8:	c3                   	ret    
  800fa9:	00 00                	add    %al,(%eax)
	...

00800fac <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  800fac:	55                   	push   %ebp
  800fad:	89 e5                	mov    %esp,%ebp
  800faf:	83 ec 08             	sub    $0x8,%esp
  800fb2:	89 1c 24             	mov    %ebx,(%esp)
  800fb5:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800fb9:	ba 00 00 00 00       	mov    $0x0,%edx
  800fbe:	b8 01 00 00 00       	mov    $0x1,%eax
  800fc3:	89 d1                	mov    %edx,%ecx
  800fc5:	89 d3                	mov    %edx,%ebx
  800fc7:	89 d7                	mov    %edx,%edi
  800fc9:	51                   	push   %ecx
  800fca:	52                   	push   %edx
  800fcb:	53                   	push   %ebx
  800fcc:	54                   	push   %esp
  800fcd:	55                   	push   %ebp
  800fce:	56                   	push   %esi
  800fcf:	57                   	push   %edi
  800fd0:	54                   	push   %esp
  800fd1:	5d                   	pop    %ebp
  800fd2:	8d 35 da 0f 80 00    	lea    0x800fda,%esi
  800fd8:	0f 34                	sysenter 
  800fda:	5f                   	pop    %edi
  800fdb:	5e                   	pop    %esi
  800fdc:	5d                   	pop    %ebp
  800fdd:	5c                   	pop    %esp
  800fde:	5b                   	pop    %ebx
  800fdf:	5a                   	pop    %edx
  800fe0:	59                   	pop    %ecx

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800fe1:	8b 1c 24             	mov    (%esp),%ebx
  800fe4:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800fe8:	89 ec                	mov    %ebp,%esp
  800fea:	5d                   	pop    %ebp
  800feb:	c3                   	ret    

00800fec <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800fec:	55                   	push   %ebp
  800fed:	89 e5                	mov    %esp,%ebp
  800fef:	83 ec 08             	sub    $0x8,%esp
  800ff2:	89 1c 24             	mov    %ebx,(%esp)
  800ff5:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800ff9:	b8 00 00 00 00       	mov    $0x0,%eax
  800ffe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801001:	8b 55 08             	mov    0x8(%ebp),%edx
  801004:	89 c3                	mov    %eax,%ebx
  801006:	89 c7                	mov    %eax,%edi
  801008:	51                   	push   %ecx
  801009:	52                   	push   %edx
  80100a:	53                   	push   %ebx
  80100b:	54                   	push   %esp
  80100c:	55                   	push   %ebp
  80100d:	56                   	push   %esi
  80100e:	57                   	push   %edi
  80100f:	54                   	push   %esp
  801010:	5d                   	pop    %ebp
  801011:	8d 35 19 10 80 00    	lea    0x801019,%esi
  801017:	0f 34                	sysenter 
  801019:	5f                   	pop    %edi
  80101a:	5e                   	pop    %esi
  80101b:	5d                   	pop    %ebp
  80101c:	5c                   	pop    %esp
  80101d:	5b                   	pop    %ebx
  80101e:	5a                   	pop    %edx
  80101f:	59                   	pop    %ecx

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  801020:	8b 1c 24             	mov    (%esp),%ebx
  801023:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801027:	89 ec                	mov    %ebp,%esp
  801029:	5d                   	pop    %ebp
  80102a:	c3                   	ret    

0080102b <sys_env_set_prior>:
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}

int 
sys_env_set_prior(envid_t envid, uint32_t prior){
  80102b:	55                   	push   %ebp
  80102c:	89 e5                	mov    %esp,%ebp
  80102e:	83 ec 28             	sub    $0x28,%esp
  801031:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801034:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801037:	bb 00 00 00 00       	mov    $0x0,%ebx
  80103c:	b8 0e 00 00 00       	mov    $0xe,%eax
  801041:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801044:	8b 55 08             	mov    0x8(%ebp),%edx
  801047:	89 df                	mov    %ebx,%edi
  801049:	51                   	push   %ecx
  80104a:	52                   	push   %edx
  80104b:	53                   	push   %ebx
  80104c:	54                   	push   %esp
  80104d:	55                   	push   %ebp
  80104e:	56                   	push   %esi
  80104f:	57                   	push   %edi
  801050:	54                   	push   %esp
  801051:	5d                   	pop    %ebp
  801052:	8d 35 5a 10 80 00    	lea    0x80105a,%esi
  801058:	0f 34                	sysenter 
  80105a:	5f                   	pop    %edi
  80105b:	5e                   	pop    %esi
  80105c:	5d                   	pop    %ebp
  80105d:	5c                   	pop    %esp
  80105e:	5b                   	pop    %ebx
  80105f:	5a                   	pop    %edx
  801060:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801061:	85 c0                	test   %eax,%eax
  801063:	7e 28                	jle    80108d <sys_env_set_prior+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  801065:	89 44 24 10          	mov    %eax,0x10(%esp)
  801069:	c7 44 24 0c 0e 00 00 	movl   $0xe,0xc(%esp)
  801070:	00 
  801071:	c7 44 24 08 c4 1f 80 	movl   $0x801fc4,0x8(%esp)
  801078:	00 
  801079:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801080:	00 
  801081:	c7 04 24 e1 1f 80 00 	movl   $0x801fe1,(%esp)
  801088:	e8 2b f1 ff ff       	call   8001b8 <_panic>
}

int 
sys_env_set_prior(envid_t envid, uint32_t prior){
         return syscall(SYS_env_set_prior,1,envid, prior, 0, 0, 0);
}
  80108d:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801090:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801093:	89 ec                	mov    %ebp,%esp
  801095:	5d                   	pop    %ebp
  801096:	c3                   	ret    

00801097 <sys_sbrk>:
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}

int
sys_sbrk(uint32_t inc)
{
  801097:	55                   	push   %ebp
  801098:	89 e5                	mov    %esp,%ebp
  80109a:	83 ec 08             	sub    $0x8,%esp
  80109d:	89 1c 24             	mov    %ebx,(%esp)
  8010a0:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8010a4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010a9:	b8 0f 00 00 00       	mov    $0xf,%eax
  8010ae:	8b 55 08             	mov    0x8(%ebp),%edx
  8010b1:	89 cb                	mov    %ecx,%ebx
  8010b3:	89 cf                	mov    %ecx,%edi
  8010b5:	51                   	push   %ecx
  8010b6:	52                   	push   %edx
  8010b7:	53                   	push   %ebx
  8010b8:	54                   	push   %esp
  8010b9:	55                   	push   %ebp
  8010ba:	56                   	push   %esi
  8010bb:	57                   	push   %edi
  8010bc:	54                   	push   %esp
  8010bd:	5d                   	pop    %ebp
  8010be:	8d 35 c6 10 80 00    	lea    0x8010c6,%esi
  8010c4:	0f 34                	sysenter 
  8010c6:	5f                   	pop    %edi
  8010c7:	5e                   	pop    %esi
  8010c8:	5d                   	pop    %ebp
  8010c9:	5c                   	pop    %esp
  8010ca:	5b                   	pop    %ebx
  8010cb:	5a                   	pop    %edx
  8010cc:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  8010cd:	8b 1c 24             	mov    (%esp),%ebx
  8010d0:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8010d4:	89 ec                	mov    %ebp,%esp
  8010d6:	5d                   	pop    %ebp
  8010d7:	c3                   	ret    

008010d8 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  8010d8:	55                   	push   %ebp
  8010d9:	89 e5                	mov    %esp,%ebp
  8010db:	83 ec 28             	sub    $0x28,%esp
  8010de:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8010e1:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8010e4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010e9:	b8 0d 00 00 00       	mov    $0xd,%eax
  8010ee:	8b 55 08             	mov    0x8(%ebp),%edx
  8010f1:	89 cb                	mov    %ecx,%ebx
  8010f3:	89 cf                	mov    %ecx,%edi
  8010f5:	51                   	push   %ecx
  8010f6:	52                   	push   %edx
  8010f7:	53                   	push   %ebx
  8010f8:	54                   	push   %esp
  8010f9:	55                   	push   %ebp
  8010fa:	56                   	push   %esi
  8010fb:	57                   	push   %edi
  8010fc:	54                   	push   %esp
  8010fd:	5d                   	pop    %ebp
  8010fe:	8d 35 06 11 80 00    	lea    0x801106,%esi
  801104:	0f 34                	sysenter 
  801106:	5f                   	pop    %edi
  801107:	5e                   	pop    %esi
  801108:	5d                   	pop    %ebp
  801109:	5c                   	pop    %esp
  80110a:	5b                   	pop    %ebx
  80110b:	5a                   	pop    %edx
  80110c:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80110d:	85 c0                	test   %eax,%eax
  80110f:	7e 28                	jle    801139 <sys_ipc_recv+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  801111:	89 44 24 10          	mov    %eax,0x10(%esp)
  801115:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  80111c:	00 
  80111d:	c7 44 24 08 c4 1f 80 	movl   $0x801fc4,0x8(%esp)
  801124:	00 
  801125:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80112c:	00 
  80112d:	c7 04 24 e1 1f 80 00 	movl   $0x801fe1,(%esp)
  801134:	e8 7f f0 ff ff       	call   8001b8 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801139:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80113c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80113f:	89 ec                	mov    %ebp,%esp
  801141:	5d                   	pop    %ebp
  801142:	c3                   	ret    

00801143 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801143:	55                   	push   %ebp
  801144:	89 e5                	mov    %esp,%ebp
  801146:	83 ec 08             	sub    $0x8,%esp
  801149:	89 1c 24             	mov    %ebx,(%esp)
  80114c:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801150:	b8 0c 00 00 00       	mov    $0xc,%eax
  801155:	8b 7d 14             	mov    0x14(%ebp),%edi
  801158:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80115b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80115e:	8b 55 08             	mov    0x8(%ebp),%edx
  801161:	51                   	push   %ecx
  801162:	52                   	push   %edx
  801163:	53                   	push   %ebx
  801164:	54                   	push   %esp
  801165:	55                   	push   %ebp
  801166:	56                   	push   %esi
  801167:	57                   	push   %edi
  801168:	54                   	push   %esp
  801169:	5d                   	pop    %ebp
  80116a:	8d 35 72 11 80 00    	lea    0x801172,%esi
  801170:	0f 34                	sysenter 
  801172:	5f                   	pop    %edi
  801173:	5e                   	pop    %esi
  801174:	5d                   	pop    %ebp
  801175:	5c                   	pop    %esp
  801176:	5b                   	pop    %ebx
  801177:	5a                   	pop    %edx
  801178:	59                   	pop    %ecx

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801179:	8b 1c 24             	mov    (%esp),%ebx
  80117c:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801180:	89 ec                	mov    %ebp,%esp
  801182:	5d                   	pop    %ebp
  801183:	c3                   	ret    

00801184 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801184:	55                   	push   %ebp
  801185:	89 e5                	mov    %esp,%ebp
  801187:	83 ec 28             	sub    $0x28,%esp
  80118a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80118d:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801190:	bb 00 00 00 00       	mov    $0x0,%ebx
  801195:	b8 0a 00 00 00       	mov    $0xa,%eax
  80119a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80119d:	8b 55 08             	mov    0x8(%ebp),%edx
  8011a0:	89 df                	mov    %ebx,%edi
  8011a2:	51                   	push   %ecx
  8011a3:	52                   	push   %edx
  8011a4:	53                   	push   %ebx
  8011a5:	54                   	push   %esp
  8011a6:	55                   	push   %ebp
  8011a7:	56                   	push   %esi
  8011a8:	57                   	push   %edi
  8011a9:	54                   	push   %esp
  8011aa:	5d                   	pop    %ebp
  8011ab:	8d 35 b3 11 80 00    	lea    0x8011b3,%esi
  8011b1:	0f 34                	sysenter 
  8011b3:	5f                   	pop    %edi
  8011b4:	5e                   	pop    %esi
  8011b5:	5d                   	pop    %ebp
  8011b6:	5c                   	pop    %esp
  8011b7:	5b                   	pop    %ebx
  8011b8:	5a                   	pop    %edx
  8011b9:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8011ba:	85 c0                	test   %eax,%eax
  8011bc:	7e 28                	jle    8011e6 <sys_env_set_pgfault_upcall+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011be:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011c2:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  8011c9:	00 
  8011ca:	c7 44 24 08 c4 1f 80 	movl   $0x801fc4,0x8(%esp)
  8011d1:	00 
  8011d2:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8011d9:	00 
  8011da:	c7 04 24 e1 1f 80 00 	movl   $0x801fe1,(%esp)
  8011e1:	e8 d2 ef ff ff       	call   8001b8 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8011e6:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8011e9:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8011ec:	89 ec                	mov    %ebp,%esp
  8011ee:	5d                   	pop    %ebp
  8011ef:	c3                   	ret    

008011f0 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8011f0:	55                   	push   %ebp
  8011f1:	89 e5                	mov    %esp,%ebp
  8011f3:	83 ec 28             	sub    $0x28,%esp
  8011f6:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8011f9:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8011fc:	bb 00 00 00 00       	mov    $0x0,%ebx
  801201:	b8 09 00 00 00       	mov    $0x9,%eax
  801206:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801209:	8b 55 08             	mov    0x8(%ebp),%edx
  80120c:	89 df                	mov    %ebx,%edi
  80120e:	51                   	push   %ecx
  80120f:	52                   	push   %edx
  801210:	53                   	push   %ebx
  801211:	54                   	push   %esp
  801212:	55                   	push   %ebp
  801213:	56                   	push   %esi
  801214:	57                   	push   %edi
  801215:	54                   	push   %esp
  801216:	5d                   	pop    %ebp
  801217:	8d 35 1f 12 80 00    	lea    0x80121f,%esi
  80121d:	0f 34                	sysenter 
  80121f:	5f                   	pop    %edi
  801220:	5e                   	pop    %esi
  801221:	5d                   	pop    %ebp
  801222:	5c                   	pop    %esp
  801223:	5b                   	pop    %ebx
  801224:	5a                   	pop    %edx
  801225:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801226:	85 c0                	test   %eax,%eax
  801228:	7e 28                	jle    801252 <sys_env_set_status+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  80122a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80122e:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  801235:	00 
  801236:	c7 44 24 08 c4 1f 80 	movl   $0x801fc4,0x8(%esp)
  80123d:	00 
  80123e:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801245:	00 
  801246:	c7 04 24 e1 1f 80 00 	movl   $0x801fe1,(%esp)
  80124d:	e8 66 ef ff ff       	call   8001b8 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801252:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801255:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801258:	89 ec                	mov    %ebp,%esp
  80125a:	5d                   	pop    %ebp
  80125b:	c3                   	ret    

0080125c <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  80125c:	55                   	push   %ebp
  80125d:	89 e5                	mov    %esp,%ebp
  80125f:	83 ec 28             	sub    $0x28,%esp
  801262:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801265:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801268:	bb 00 00 00 00       	mov    $0x0,%ebx
  80126d:	b8 07 00 00 00       	mov    $0x7,%eax
  801272:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801275:	8b 55 08             	mov    0x8(%ebp),%edx
  801278:	89 df                	mov    %ebx,%edi
  80127a:	51                   	push   %ecx
  80127b:	52                   	push   %edx
  80127c:	53                   	push   %ebx
  80127d:	54                   	push   %esp
  80127e:	55                   	push   %ebp
  80127f:	56                   	push   %esi
  801280:	57                   	push   %edi
  801281:	54                   	push   %esp
  801282:	5d                   	pop    %ebp
  801283:	8d 35 8b 12 80 00    	lea    0x80128b,%esi
  801289:	0f 34                	sysenter 
  80128b:	5f                   	pop    %edi
  80128c:	5e                   	pop    %esi
  80128d:	5d                   	pop    %ebp
  80128e:	5c                   	pop    %esp
  80128f:	5b                   	pop    %ebx
  801290:	5a                   	pop    %edx
  801291:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801292:	85 c0                	test   %eax,%eax
  801294:	7e 28                	jle    8012be <sys_page_unmap+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  801296:	89 44 24 10          	mov    %eax,0x10(%esp)
  80129a:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8012a1:	00 
  8012a2:	c7 44 24 08 c4 1f 80 	movl   $0x801fc4,0x8(%esp)
  8012a9:	00 
  8012aa:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8012b1:	00 
  8012b2:	c7 04 24 e1 1f 80 00 	movl   $0x801fe1,(%esp)
  8012b9:	e8 fa ee ff ff       	call   8001b8 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8012be:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8012c1:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8012c4:	89 ec                	mov    %ebp,%esp
  8012c6:	5d                   	pop    %ebp
  8012c7:	c3                   	ret    

008012c8 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8012c8:	55                   	push   %ebp
  8012c9:	89 e5                	mov    %esp,%ebp
  8012cb:	83 ec 28             	sub    $0x28,%esp
  8012ce:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8012d1:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8012d4:	8b 7d 18             	mov    0x18(%ebp),%edi
  8012d7:	0b 7d 14             	or     0x14(%ebp),%edi
  8012da:	b8 06 00 00 00       	mov    $0x6,%eax
  8012df:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8012e2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012e5:	8b 55 08             	mov    0x8(%ebp),%edx
  8012e8:	51                   	push   %ecx
  8012e9:	52                   	push   %edx
  8012ea:	53                   	push   %ebx
  8012eb:	54                   	push   %esp
  8012ec:	55                   	push   %ebp
  8012ed:	56                   	push   %esi
  8012ee:	57                   	push   %edi
  8012ef:	54                   	push   %esp
  8012f0:	5d                   	pop    %ebp
  8012f1:	8d 35 f9 12 80 00    	lea    0x8012f9,%esi
  8012f7:	0f 34                	sysenter 
  8012f9:	5f                   	pop    %edi
  8012fa:	5e                   	pop    %esi
  8012fb:	5d                   	pop    %ebp
  8012fc:	5c                   	pop    %esp
  8012fd:	5b                   	pop    %ebx
  8012fe:	5a                   	pop    %edx
  8012ff:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801300:	85 c0                	test   %eax,%eax
  801302:	7e 28                	jle    80132c <sys_page_map+0x64>
		panic("syscall %d returned %d (> 0)", num, ret);
  801304:	89 44 24 10          	mov    %eax,0x10(%esp)
  801308:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  80130f:	00 
  801310:	c7 44 24 08 c4 1f 80 	movl   $0x801fc4,0x8(%esp)
  801317:	00 
  801318:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80131f:	00 
  801320:	c7 04 24 e1 1f 80 00 	movl   $0x801fe1,(%esp)
  801327:	e8 8c ee ff ff       	call   8001b8 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}
  80132c:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80132f:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801332:	89 ec                	mov    %ebp,%esp
  801334:	5d                   	pop    %ebp
  801335:	c3                   	ret    

00801336 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801336:	55                   	push   %ebp
  801337:	89 e5                	mov    %esp,%ebp
  801339:	83 ec 28             	sub    $0x28,%esp
  80133c:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80133f:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801342:	bf 00 00 00 00       	mov    $0x0,%edi
  801347:	b8 05 00 00 00       	mov    $0x5,%eax
  80134c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80134f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801352:	8b 55 08             	mov    0x8(%ebp),%edx
  801355:	51                   	push   %ecx
  801356:	52                   	push   %edx
  801357:	53                   	push   %ebx
  801358:	54                   	push   %esp
  801359:	55                   	push   %ebp
  80135a:	56                   	push   %esi
  80135b:	57                   	push   %edi
  80135c:	54                   	push   %esp
  80135d:	5d                   	pop    %ebp
  80135e:	8d 35 66 13 80 00    	lea    0x801366,%esi
  801364:	0f 34                	sysenter 
  801366:	5f                   	pop    %edi
  801367:	5e                   	pop    %esi
  801368:	5d                   	pop    %ebp
  801369:	5c                   	pop    %esp
  80136a:	5b                   	pop    %ebx
  80136b:	5a                   	pop    %edx
  80136c:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80136d:	85 c0                	test   %eax,%eax
  80136f:	7e 28                	jle    801399 <sys_page_alloc+0x63>
		panic("syscall %d returned %d (> 0)", num, ret);
  801371:	89 44 24 10          	mov    %eax,0x10(%esp)
  801375:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  80137c:	00 
  80137d:	c7 44 24 08 c4 1f 80 	movl   $0x801fc4,0x8(%esp)
  801384:	00 
  801385:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80138c:	00 
  80138d:	c7 04 24 e1 1f 80 00 	movl   $0x801fe1,(%esp)
  801394:	e8 1f ee ff ff       	call   8001b8 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  801399:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80139c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80139f:	89 ec                	mov    %ebp,%esp
  8013a1:	5d                   	pop    %ebp
  8013a2:	c3                   	ret    

008013a3 <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
{
  8013a3:	55                   	push   %ebp
  8013a4:	89 e5                	mov    %esp,%ebp
  8013a6:	83 ec 08             	sub    $0x8,%esp
  8013a9:	89 1c 24             	mov    %ebx,(%esp)
  8013ac:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8013b0:	ba 00 00 00 00       	mov    $0x0,%edx
  8013b5:	b8 0b 00 00 00       	mov    $0xb,%eax
  8013ba:	89 d1                	mov    %edx,%ecx
  8013bc:	89 d3                	mov    %edx,%ebx
  8013be:	89 d7                	mov    %edx,%edi
  8013c0:	51                   	push   %ecx
  8013c1:	52                   	push   %edx
  8013c2:	53                   	push   %ebx
  8013c3:	54                   	push   %esp
  8013c4:	55                   	push   %ebp
  8013c5:	56                   	push   %esi
  8013c6:	57                   	push   %edi
  8013c7:	54                   	push   %esp
  8013c8:	5d                   	pop    %ebp
  8013c9:	8d 35 d1 13 80 00    	lea    0x8013d1,%esi
  8013cf:	0f 34                	sysenter 
  8013d1:	5f                   	pop    %edi
  8013d2:	5e                   	pop    %esi
  8013d3:	5d                   	pop    %ebp
  8013d4:	5c                   	pop    %esp
  8013d5:	5b                   	pop    %ebx
  8013d6:	5a                   	pop    %edx
  8013d7:	59                   	pop    %ecx

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8013d8:	8b 1c 24             	mov    (%esp),%ebx
  8013db:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8013df:	89 ec                	mov    %ebp,%esp
  8013e1:	5d                   	pop    %ebp
  8013e2:	c3                   	ret    

008013e3 <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
{
  8013e3:	55                   	push   %ebp
  8013e4:	89 e5                	mov    %esp,%ebp
  8013e6:	83 ec 08             	sub    $0x8,%esp
  8013e9:	89 1c 24             	mov    %ebx,(%esp)
  8013ec:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8013f0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013f5:	b8 04 00 00 00       	mov    $0x4,%eax
  8013fa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013fd:	8b 55 08             	mov    0x8(%ebp),%edx
  801400:	89 df                	mov    %ebx,%edi
  801402:	51                   	push   %ecx
  801403:	52                   	push   %edx
  801404:	53                   	push   %ebx
  801405:	54                   	push   %esp
  801406:	55                   	push   %ebp
  801407:	56                   	push   %esi
  801408:	57                   	push   %edi
  801409:	54                   	push   %esp
  80140a:	5d                   	pop    %ebp
  80140b:	8d 35 13 14 80 00    	lea    0x801413,%esi
  801411:	0f 34                	sysenter 
  801413:	5f                   	pop    %edi
  801414:	5e                   	pop    %esi
  801415:	5d                   	pop    %ebp
  801416:	5c                   	pop    %esp
  801417:	5b                   	pop    %ebx
  801418:	5a                   	pop    %edx
  801419:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  80141a:	8b 1c 24             	mov    (%esp),%ebx
  80141d:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801421:	89 ec                	mov    %ebp,%esp
  801423:	5d                   	pop    %ebp
  801424:	c3                   	ret    

00801425 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  801425:	55                   	push   %ebp
  801426:	89 e5                	mov    %esp,%ebp
  801428:	83 ec 08             	sub    $0x8,%esp
  80142b:	89 1c 24             	mov    %ebx,(%esp)
  80142e:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801432:	ba 00 00 00 00       	mov    $0x0,%edx
  801437:	b8 02 00 00 00       	mov    $0x2,%eax
  80143c:	89 d1                	mov    %edx,%ecx
  80143e:	89 d3                	mov    %edx,%ebx
  801440:	89 d7                	mov    %edx,%edi
  801442:	51                   	push   %ecx
  801443:	52                   	push   %edx
  801444:	53                   	push   %ebx
  801445:	54                   	push   %esp
  801446:	55                   	push   %ebp
  801447:	56                   	push   %esi
  801448:	57                   	push   %edi
  801449:	54                   	push   %esp
  80144a:	5d                   	pop    %ebp
  80144b:	8d 35 53 14 80 00    	lea    0x801453,%esi
  801451:	0f 34                	sysenter 
  801453:	5f                   	pop    %edi
  801454:	5e                   	pop    %esi
  801455:	5d                   	pop    %ebp
  801456:	5c                   	pop    %esp
  801457:	5b                   	pop    %ebx
  801458:	5a                   	pop    %edx
  801459:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80145a:	8b 1c 24             	mov    (%esp),%ebx
  80145d:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801461:	89 ec                	mov    %ebp,%esp
  801463:	5d                   	pop    %ebp
  801464:	c3                   	ret    

00801465 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  801465:	55                   	push   %ebp
  801466:	89 e5                	mov    %esp,%ebp
  801468:	83 ec 28             	sub    $0x28,%esp
  80146b:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80146e:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801471:	b9 00 00 00 00       	mov    $0x0,%ecx
  801476:	b8 03 00 00 00       	mov    $0x3,%eax
  80147b:	8b 55 08             	mov    0x8(%ebp),%edx
  80147e:	89 cb                	mov    %ecx,%ebx
  801480:	89 cf                	mov    %ecx,%edi
  801482:	51                   	push   %ecx
  801483:	52                   	push   %edx
  801484:	53                   	push   %ebx
  801485:	54                   	push   %esp
  801486:	55                   	push   %ebp
  801487:	56                   	push   %esi
  801488:	57                   	push   %edi
  801489:	54                   	push   %esp
  80148a:	5d                   	pop    %ebp
  80148b:	8d 35 93 14 80 00    	lea    0x801493,%esi
  801491:	0f 34                	sysenter 
  801493:	5f                   	pop    %edi
  801494:	5e                   	pop    %esi
  801495:	5d                   	pop    %ebp
  801496:	5c                   	pop    %esp
  801497:	5b                   	pop    %ebx
  801498:	5a                   	pop    %edx
  801499:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80149a:	85 c0                	test   %eax,%eax
  80149c:	7e 28                	jle    8014c6 <sys_env_destroy+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  80149e:	89 44 24 10          	mov    %eax,0x10(%esp)
  8014a2:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  8014a9:	00 
  8014aa:	c7 44 24 08 c4 1f 80 	movl   $0x801fc4,0x8(%esp)
  8014b1:	00 
  8014b2:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8014b9:	00 
  8014ba:	c7 04 24 e1 1f 80 00 	movl   $0x801fe1,(%esp)
  8014c1:	e8 f2 ec ff ff       	call   8001b8 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8014c6:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8014c9:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8014cc:	89 ec                	mov    %ebp,%esp
  8014ce:	5d                   	pop    %ebp
  8014cf:	c3                   	ret    

008014d0 <sfork>:
}

// Challenge!
int
sfork(void)
{
  8014d0:	55                   	push   %ebp
  8014d1:	89 e5                	mov    %esp,%ebp
  8014d3:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  8014d6:	c7 44 24 08 ef 1f 80 	movl   $0x801fef,0x8(%esp)
  8014dd:	00 
  8014de:	c7 44 24 04 8e 00 00 	movl   $0x8e,0x4(%esp)
  8014e5:	00 
  8014e6:	c7 04 24 05 20 80 00 	movl   $0x802005,(%esp)
  8014ed:	e8 c6 ec ff ff       	call   8001b8 <_panic>

008014f2 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8014f2:	55                   	push   %ebp
  8014f3:	89 e5                	mov    %esp,%ebp
  8014f5:	57                   	push   %edi
  8014f6:	56                   	push   %esi
  8014f7:	53                   	push   %ebx
  8014f8:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
        set_pgfault_handler(pgfault);
  8014fb:	c7 04 24 47 17 80 00 	movl   $0x801747,(%esp)
  801502:	e8 b5 04 00 00       	call   8019bc <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801507:	ba 08 00 00 00       	mov    $0x8,%edx
  80150c:	89 d0                	mov    %edx,%eax
  80150e:	cd 30                	int    $0x30
  801510:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        envid_t envid = sys_exofork();
        uint32_t addr;
        extern void _pgfault_upcall();
        int r = 0;
        if (envid < 0)
  801513:	85 c0                	test   %eax,%eax
  801515:	79 20                	jns    801537 <fork+0x45>
		panic("sys_exofork: %e", envid);
  801517:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80151b:	c7 44 24 08 10 20 80 	movl   $0x802010,0x8(%esp)
  801522:	00 
  801523:	c7 44 24 04 74 00 00 	movl   $0x74,0x4(%esp)
  80152a:	00 
  80152b:	c7 04 24 05 20 80 00 	movl   $0x802005,(%esp)
  801532:	e8 81 ec ff ff       	call   8001b8 <_panic>
	if (envid == 0) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
  801537:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
        for(addr = 0; addr < USTACKTOP; addr += PGSIZE){
           if((vpd[PDX(addr)] & PTE_P) && (vpt[PGNUM(addr)] & PTE_P) && (vpt[PGNUM(addr)] & PTE_U))
  80153c:	be 00 d0 7b ef       	mov    $0xef7bd000,%esi
  801541:	bf 00 00 40 ef       	mov    $0xef400000,%edi
        uint32_t addr;
        extern void _pgfault_upcall();
        int r = 0;
        if (envid < 0)
		panic("sys_exofork: %e", envid);
	if (envid == 0) {
  801546:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80154a:	75 20                	jne    80156c <fork+0x7a>
		thisenv = &envs[ENVX(sys_getenvid())];
  80154c:	e8 d4 fe ff ff       	call   801425 <sys_getenvid>
  801551:	25 ff 03 00 00       	and    $0x3ff,%eax
  801556:	89 c2                	mov    %eax,%edx
  801558:	c1 e2 07             	shl    $0x7,%edx
  80155b:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  801562:	a3 04 30 80 00       	mov    %eax,0x803004
		return 0;
  801567:	e9 d0 01 00 00       	jmp    80173c <fork+0x24a>
	}
        for(addr = 0; addr < USTACKTOP; addr += PGSIZE){
           if((vpd[PDX(addr)] & PTE_P) && (vpt[PGNUM(addr)] & PTE_P) && (vpt[PGNUM(addr)] & PTE_U))
  80156c:	89 d8                	mov    %ebx,%eax
  80156e:	c1 e8 16             	shr    $0x16,%eax
  801571:	8b 04 86             	mov    (%esi,%eax,4),%eax
  801574:	a8 01                	test   $0x1,%al
  801576:	0f 84 0d 01 00 00    	je     801689 <fork+0x197>
  80157c:	89 d8                	mov    %ebx,%eax
  80157e:	c1 e8 0c             	shr    $0xc,%eax
  801581:	8b 14 87             	mov    (%edi,%eax,4),%edx
  801584:	f6 c2 01             	test   $0x1,%dl
  801587:	0f 84 fc 00 00 00    	je     801689 <fork+0x197>
  80158d:	8b 14 87             	mov    (%edi,%eax,4),%edx
  801590:	f6 c2 04             	test   $0x4,%dl
  801593:	0f 84 f0 00 00 00    	je     801689 <fork+0x197>
duppage(envid_t envid, unsigned pn)
{
	int r;
        
	// LAB 4: Your code here.
        uint32_t addr = pn*PGSIZE;
  801599:	c1 e0 0c             	shl    $0xc,%eax
        pte_t pte = vpt[PGNUM(addr)];
  80159c:	89 c2                	mov    %eax,%edx
  80159e:	c1 ea 0c             	shr    $0xc,%edx
  8015a1:	8b 14 97             	mov    (%edi,%edx,4),%edx
        if(pte & PTE_P){
  8015a4:	f6 c2 01             	test   $0x1,%dl
  8015a7:	0f 84 dc 00 00 00    	je     801689 <fork+0x197>
          if((pte & PTE_W)|| (pte & PTE_COW)){
  8015ad:	f7 c2 02 08 00 00    	test   $0x802,%edx
  8015b3:	0f 84 8d 00 00 00    	je     801646 <fork+0x154>
               r = sys_page_map(0,(void*)addr,envid,(void*)addr,PTE_P|PTE_U|PTE_COW);
  8015b9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8015bc:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  8015c3:	00 
  8015c4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8015c8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8015cb:	89 54 24 08          	mov    %edx,0x8(%esp)
  8015cf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015d3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015da:	e8 e9 fc ff ff       	call   8012c8 <sys_page_map>
               if(r<0)
  8015df:	85 c0                	test   %eax,%eax
  8015e1:	79 1c                	jns    8015ff <fork+0x10d>
                 panic("map failed");
  8015e3:	c7 44 24 08 20 20 80 	movl   $0x802020,0x8(%esp)
  8015ea:	00 
  8015eb:	c7 44 24 04 49 00 00 	movl   $0x49,0x4(%esp)
  8015f2:	00 
  8015f3:	c7 04 24 05 20 80 00 	movl   $0x802005,(%esp)
  8015fa:	e8 b9 eb ff ff       	call   8001b8 <_panic>
               r = sys_page_map(0,(void*)addr,0,(void*)addr,PTE_P|PTE_U|PTE_COW);    //mark itself COW as well
  8015ff:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  801606:	00 
  801607:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80160a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80160e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801615:	00 
  801616:	89 44 24 04          	mov    %eax,0x4(%esp)
  80161a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801621:	e8 a2 fc ff ff       	call   8012c8 <sys_page_map>
               if(r<0)
  801626:	85 c0                	test   %eax,%eax
  801628:	79 5f                	jns    801689 <fork+0x197>
                 panic("map failed");
  80162a:	c7 44 24 08 20 20 80 	movl   $0x802020,0x8(%esp)
  801631:	00 
  801632:	c7 44 24 04 4c 00 00 	movl   $0x4c,0x4(%esp)
  801639:	00 
  80163a:	c7 04 24 05 20 80 00 	movl   $0x802005,(%esp)
  801641:	e8 72 eb ff ff       	call   8001b8 <_panic>
          }
          else{
               r = sys_page_map(0,(void*)addr,envid,(void*)addr,PTE_P|PTE_U);
  801646:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  80164d:	00 
  80164e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801652:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801655:	89 54 24 08          	mov    %edx,0x8(%esp)
  801659:	89 44 24 04          	mov    %eax,0x4(%esp)
  80165d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801664:	e8 5f fc ff ff       	call   8012c8 <sys_page_map>
               if(r<0)
  801669:	85 c0                	test   %eax,%eax
  80166b:	79 1c                	jns    801689 <fork+0x197>
                 panic("map failed");
  80166d:	c7 44 24 08 20 20 80 	movl   $0x802020,0x8(%esp)
  801674:	00 
  801675:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  80167c:	00 
  80167d:	c7 04 24 05 20 80 00 	movl   $0x802005,(%esp)
  801684:	e8 2f eb ff ff       	call   8001b8 <_panic>
		panic("sys_exofork: %e", envid);
	if (envid == 0) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
        for(addr = 0; addr < USTACKTOP; addr += PGSIZE){
  801689:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80168f:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  801695:	0f 85 d1 fe ff ff    	jne    80156c <fork+0x7a>
           if((vpd[PDX(addr)] & PTE_P) && (vpt[PGNUM(addr)] & PTE_P) && (vpt[PGNUM(addr)] & PTE_U))
              duppage(envid,PGNUM(addr));
        }
        r = sys_page_alloc(envid, (void*)(UXSTACKTOP-PGSIZE),PTE_P|PTE_U|PTE_W);
  80169b:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8016a2:	00 
  8016a3:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8016aa:	ee 
  8016ab:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8016ae:	89 04 24             	mov    %eax,(%esp)
  8016b1:	e8 80 fc ff ff       	call   801336 <sys_page_alloc>
        if(r < 0)
  8016b6:	85 c0                	test   %eax,%eax
  8016b8:	79 1c                	jns    8016d6 <fork+0x1e4>
            panic("alloc failed");
  8016ba:	c7 44 24 08 2b 20 80 	movl   $0x80202b,0x8(%esp)
  8016c1:	00 
  8016c2:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
  8016c9:	00 
  8016ca:	c7 04 24 05 20 80 00 	movl   $0x802005,(%esp)
  8016d1:	e8 e2 ea ff ff       	call   8001b8 <_panic>
        r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  8016d6:	c7 44 24 04 08 1a 80 	movl   $0x801a08,0x4(%esp)
  8016dd:	00 
  8016de:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8016e1:	89 14 24             	mov    %edx,(%esp)
  8016e4:	e8 9b fa ff ff       	call   801184 <sys_env_set_pgfault_upcall>
        if(r < 0)
  8016e9:	85 c0                	test   %eax,%eax
  8016eb:	79 1c                	jns    801709 <fork+0x217>
            panic("set pgfault upcall failed");
  8016ed:	c7 44 24 08 38 20 80 	movl   $0x802038,0x8(%esp)
  8016f4:	00 
  8016f5:	c7 44 24 04 82 00 00 	movl   $0x82,0x4(%esp)
  8016fc:	00 
  8016fd:	c7 04 24 05 20 80 00 	movl   $0x802005,(%esp)
  801704:	e8 af ea ff ff       	call   8001b8 <_panic>
        r = sys_env_set_status(envid, ENV_RUNNABLE);
  801709:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801710:	00 
  801711:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801714:	89 04 24             	mov    %eax,(%esp)
  801717:	e8 d4 fa ff ff       	call   8011f0 <sys_env_set_status>
        if(r < 0)
  80171c:	85 c0                	test   %eax,%eax
  80171e:	79 1c                	jns    80173c <fork+0x24a>
            panic("set status failed");
  801720:	c7 44 24 08 52 20 80 	movl   $0x802052,0x8(%esp)
  801727:	00 
  801728:	c7 44 24 04 85 00 00 	movl   $0x85,0x4(%esp)
  80172f:	00 
  801730:	c7 04 24 05 20 80 00 	movl   $0x802005,(%esp)
  801737:	e8 7c ea ff ff       	call   8001b8 <_panic>
        return envid;
	//panic("fork not implemented");
}
  80173c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80173f:	83 c4 3c             	add    $0x3c,%esp
  801742:	5b                   	pop    %ebx
  801743:	5e                   	pop    %esi
  801744:	5f                   	pop    %edi
  801745:	5d                   	pop    %ebp
  801746:	c3                   	ret    

00801747 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  801747:	55                   	push   %ebp
  801748:	89 e5                	mov    %esp,%ebp
  80174a:	53                   	push   %ebx
  80174b:	83 ec 24             	sub    $0x24,%esp
  80174e:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  801751:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at vpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        pte_t pte = vpt[PGNUM(addr)];
  801753:	89 da                	mov    %ebx,%edx
  801755:	c1 ea 0c             	shr    $0xc,%edx
  801758:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
//
static void
pgfault(struct UTrapframe *utf)
{
	void *addr = (void *) utf->utf_fault_va;
	uint32_t err = utf->utf_err;
  80175f:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  801763:	74 08                	je     80176d <pgfault+0x26>
	//   Use the read-only page table mappings at vpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        pte_t pte = vpt[PGNUM(addr)];
        if((!(err & FEC_WR)) ||(!(pte & (PTE_P | PTE_U |PTE_COW))))
  801765:	f7 c2 05 08 00 00    	test   $0x805,%edx
  80176b:	75 1c                	jne    801789 <pgfault+0x42>
           panic("pgfault error");
  80176d:	c7 44 24 08 64 20 80 	movl   $0x802064,0x8(%esp)
  801774:	00 
  801775:	c7 44 24 04 1e 00 00 	movl   $0x1e,0x4(%esp)
  80177c:	00 
  80177d:	c7 04 24 05 20 80 00 	movl   $0x802005,(%esp)
  801784:	e8 2f ea ff ff       	call   8001b8 <_panic>
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 4: Your code here.
        if ((r = sys_page_alloc(0, (void*)PFTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801789:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801790:	00 
  801791:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801798:	00 
  801799:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017a0:	e8 91 fb ff ff       	call   801336 <sys_page_alloc>
  8017a5:	85 c0                	test   %eax,%eax
  8017a7:	79 20                	jns    8017c9 <pgfault+0x82>
		panic("sys_page_alloc: %e", r);
  8017a9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8017ad:	c7 44 24 08 72 20 80 	movl   $0x802072,0x8(%esp)
  8017b4:	00 
  8017b5:	c7 44 24 04 29 00 00 	movl   $0x29,0x4(%esp)
  8017bc:	00 
  8017bd:	c7 04 24 05 20 80 00 	movl   $0x802005,(%esp)
  8017c4:	e8 ef e9 ff ff       	call   8001b8 <_panic>
        memmove(PFTEMP, (void*)((PGNUM(addr))<< PTXSHIFT), PGSIZE);
  8017c9:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  8017cf:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  8017d6:	00 
  8017d7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8017db:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  8017e2:	e8 be f5 ff ff       	call   800da5 <memmove>
	if ((r = sys_page_map(0, (void*)PFTEMP, 0, (void*)((PGNUM(addr))<< PTXSHIFT), PTE_P|PTE_U|PTE_W)) < 0)
  8017e7:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  8017ee:	00 
  8017ef:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8017f3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8017fa:	00 
  8017fb:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801802:	00 
  801803:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80180a:	e8 b9 fa ff ff       	call   8012c8 <sys_page_map>
  80180f:	85 c0                	test   %eax,%eax
  801811:	79 20                	jns    801833 <pgfault+0xec>
		panic("sys_page_map: %e", r);	
  801813:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801817:	c7 44 24 08 85 20 80 	movl   $0x802085,0x8(%esp)
  80181e:	00 
  80181f:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  801826:	00 
  801827:	c7 04 24 05 20 80 00 	movl   $0x802005,(%esp)
  80182e:	e8 85 e9 ff ff       	call   8001b8 <_panic>
        if ((r = sys_page_unmap(0, PFTEMP)) < 0)
  801833:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  80183a:	00 
  80183b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801842:	e8 15 fa ff ff       	call   80125c <sys_page_unmap>
  801847:	85 c0                	test   %eax,%eax
  801849:	79 20                	jns    80186b <pgfault+0x124>
		panic("sys_page_unmap: %e", r);
  80184b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80184f:	c7 44 24 08 96 20 80 	movl   $0x802096,0x8(%esp)
  801856:	00 
  801857:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
  80185e:	00 
  80185f:	c7 04 24 05 20 80 00 	movl   $0x802005,(%esp)
  801866:	e8 4d e9 ff ff       	call   8001b8 <_panic>
	//panic("pgfault not implemented");
}
  80186b:	83 c4 24             	add    $0x24,%esp
  80186e:	5b                   	pop    %ebx
  80186f:	5d                   	pop    %ebp
  801870:	c3                   	ret    
	...

00801880 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801880:	55                   	push   %ebp
  801881:	89 e5                	mov    %esp,%ebp
  801883:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801886:	8b 15 50 00 c0 ee    	mov    0xeec00050,%edx
  80188c:	b8 01 00 00 00       	mov    $0x1,%eax
  801891:	39 ca                	cmp    %ecx,%edx
  801893:	75 04                	jne    801899 <ipc_find_env+0x19>
  801895:	b0 00                	mov    $0x0,%al
  801897:	eb 12                	jmp    8018ab <ipc_find_env+0x2b>
  801899:	89 c2                	mov    %eax,%edx
  80189b:	c1 e2 07             	shl    $0x7,%edx
  80189e:	8d 94 82 50 00 c0 ee 	lea    -0x113fffb0(%edx,%eax,4),%edx
  8018a5:	8b 12                	mov    (%edx),%edx
  8018a7:	39 ca                	cmp    %ecx,%edx
  8018a9:	75 10                	jne    8018bb <ipc_find_env+0x3b>
			return envs[i].env_id;
  8018ab:	89 c2                	mov    %eax,%edx
  8018ad:	c1 e2 07             	shl    $0x7,%edx
  8018b0:	8d 84 82 48 00 c0 ee 	lea    -0x113fffb8(%edx,%eax,4),%eax
  8018b7:	8b 00                	mov    (%eax),%eax
  8018b9:	eb 0e                	jmp    8018c9 <ipc_find_env+0x49>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8018bb:	83 c0 01             	add    $0x1,%eax
  8018be:	3d 00 04 00 00       	cmp    $0x400,%eax
  8018c3:	75 d4                	jne    801899 <ipc_find_env+0x19>
  8018c5:	66 b8 00 00          	mov    $0x0,%ax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  8018c9:	5d                   	pop    %ebp
  8018ca:	c3                   	ret    

008018cb <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8018cb:	55                   	push   %ebp
  8018cc:	89 e5                	mov    %esp,%ebp
  8018ce:	57                   	push   %edi
  8018cf:	56                   	push   %esi
  8018d0:	53                   	push   %ebx
  8018d1:	83 ec 1c             	sub    $0x1c,%esp
  8018d4:	8b 75 08             	mov    0x8(%ebp),%esi
  8018d7:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8018da:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        int ret;
        while(1){
           if(pg)
  8018dd:	85 db                	test   %ebx,%ebx
  8018df:	74 19                	je     8018fa <ipc_send+0x2f>
              ret = sys_ipc_try_send(to_env,val,pg,perm);
  8018e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8018e4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8018e8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8018ec:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8018f0:	89 34 24             	mov    %esi,(%esp)
  8018f3:	e8 4b f8 ff ff       	call   801143 <sys_ipc_try_send>
  8018f8:	eb 1b                	jmp    801915 <ipc_send+0x4a>
           else
              ret = sys_ipc_try_send(to_env,val,(void*)UTOP,perm);
  8018fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8018fd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801901:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  801908:	ee 
  801909:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80190d:	89 34 24             	mov    %esi,(%esp)
  801910:	e8 2e f8 ff ff       	call   801143 <sys_ipc_try_send>
           if(ret == 0)
  801915:	85 c0                	test   %eax,%eax
  801917:	74 28                	je     801941 <ipc_send+0x76>
              return;
           if(ret != -E_IPC_NOT_RECV)
  801919:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80191c:	74 1c                	je     80193a <ipc_send+0x6f>
              panic("ipc send error");
  80191e:	c7 44 24 08 a9 20 80 	movl   $0x8020a9,0x8(%esp)
  801925:	00 
  801926:	c7 44 24 04 46 00 00 	movl   $0x46,0x4(%esp)
  80192d:	00 
  80192e:	c7 04 24 b8 20 80 00 	movl   $0x8020b8,(%esp)
  801935:	e8 7e e8 ff ff       	call   8001b8 <_panic>
           sys_yield();
  80193a:	e8 64 fa ff ff       	call   8013a3 <sys_yield>
        }
  80193f:	eb 9c                	jmp    8018dd <ipc_send+0x12>
	//panic("ipc_send not implemented");
}
  801941:	83 c4 1c             	add    $0x1c,%esp
  801944:	5b                   	pop    %ebx
  801945:	5e                   	pop    %esi
  801946:	5f                   	pop    %edi
  801947:	5d                   	pop    %ebp
  801948:	c3                   	ret    

00801949 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801949:	55                   	push   %ebp
  80194a:	89 e5                	mov    %esp,%ebp
  80194c:	56                   	push   %esi
  80194d:	53                   	push   %ebx
  80194e:	83 ec 10             	sub    $0x10,%esp
  801951:	8b 75 08             	mov    0x8(%ebp),%esi
  801954:	8b 45 0c             	mov    0xc(%ebp),%eax
  801957:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        int ret;
        if(!pg)
  80195a:	85 c0                	test   %eax,%eax
  80195c:	75 0e                	jne    80196c <ipc_recv+0x23>
           ret = sys_ipc_recv((void*)UTOP);
  80195e:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  801965:	e8 6e f7 ff ff       	call   8010d8 <sys_ipc_recv>
  80196a:	eb 08                	jmp    801974 <ipc_recv+0x2b>
        else
           ret = sys_ipc_recv(pg);
  80196c:	89 04 24             	mov    %eax,(%esp)
  80196f:	e8 64 f7 ff ff       	call   8010d8 <sys_ipc_recv>
        if(ret == 0){
  801974:	85 c0                	test   %eax,%eax
  801976:	75 26                	jne    80199e <ipc_recv+0x55>
           if(from_env_store)
  801978:	85 f6                	test   %esi,%esi
  80197a:	74 0a                	je     801986 <ipc_recv+0x3d>
              *from_env_store = thisenv->env_ipc_from;
  80197c:	a1 04 30 80 00       	mov    0x803004,%eax
  801981:	8b 40 78             	mov    0x78(%eax),%eax
  801984:	89 06                	mov    %eax,(%esi)
           if(perm_store)
  801986:	85 db                	test   %ebx,%ebx
  801988:	74 0a                	je     801994 <ipc_recv+0x4b>
              *perm_store = thisenv->env_ipc_perm;
  80198a:	a1 04 30 80 00       	mov    0x803004,%eax
  80198f:	8b 40 7c             	mov    0x7c(%eax),%eax
  801992:	89 03                	mov    %eax,(%ebx)
           return thisenv->env_ipc_value;
  801994:	a1 04 30 80 00       	mov    0x803004,%eax
  801999:	8b 40 74             	mov    0x74(%eax),%eax
  80199c:	eb 14                	jmp    8019b2 <ipc_recv+0x69>
        }
        else{
           if(from_env_store)
  80199e:	85 f6                	test   %esi,%esi
  8019a0:	74 06                	je     8019a8 <ipc_recv+0x5f>
              *from_env_store = 0;
  8019a2:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
           if(perm_store)
  8019a8:	85 db                	test   %ebx,%ebx
  8019aa:	74 06                	je     8019b2 <ipc_recv+0x69>
              *perm_store = 0;
  8019ac:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
           return ret;
        }
	//panic("ipc_recv not implemented");
	return 0;
}
  8019b2:	83 c4 10             	add    $0x10,%esp
  8019b5:	5b                   	pop    %ebx
  8019b6:	5e                   	pop    %esi
  8019b7:	5d                   	pop    %ebp
  8019b8:	c3                   	ret    
  8019b9:	00 00                	add    %al,(%eax)
	...

008019bc <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8019bc:	55                   	push   %ebp
  8019bd:	89 e5                	mov    %esp,%ebp
  8019bf:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  8019c2:	83 3d 0c 30 80 00 00 	cmpl   $0x0,0x80300c
  8019c9:	75 30                	jne    8019fb <set_pgfault_handler+0x3f>
		// First time through!
		// LAB 4: Your code here.
                uint32_t ret = sys_page_alloc(0,(void*)(UXSTACKTOP-PGSIZE),PTE_P|PTE_U|PTE_W);
  8019cb:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8019d2:	00 
  8019d3:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8019da:	ee 
  8019db:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019e2:	e8 4f f9 ff ff       	call   801336 <sys_page_alloc>
                if(ret < 0)
                  return;
                sys_env_set_pgfault_upcall(0,_pgfault_upcall);
  8019e7:	c7 44 24 04 08 1a 80 	movl   $0x801a08,0x4(%esp)
  8019ee:	00 
  8019ef:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019f6:	e8 89 f7 ff ff       	call   801184 <sys_env_set_pgfault_upcall>
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8019fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8019fe:	a3 0c 30 80 00       	mov    %eax,0x80300c
}
  801a03:	c9                   	leave  
  801a04:	c3                   	ret    
  801a05:	00 00                	add    %al,(%eax)
	...

00801a08 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801a08:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801a09:	a1 0c 30 80 00       	mov    0x80300c,%eax
	call *%eax
  801a0e:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801a10:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
        movl 0x28(%esp),%eax
  801a13:	8b 44 24 28          	mov    0x28(%esp),%eax
        movl 0x30(%esp),%ecx
  801a17:	8b 4c 24 30          	mov    0x30(%esp),%ecx
        subl $0x4,%ecx
  801a1b:	83 e9 04             	sub    $0x4,%ecx
        movl %eax,(%ecx)
  801a1e:	89 01                	mov    %eax,(%ecx)
        movl %ecx,0x30(%esp)
  801a20:	89 4c 24 30          	mov    %ecx,0x30(%esp)
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
        addl $0x8,%esp
  801a24:	83 c4 08             	add    $0x8,%esp
        popal
  801a27:	61                   	popa   
        addl $0x4,%esp
  801a28:	83 c4 04             	add    $0x4,%esp
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
        popfl
  801a2b:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
        popl %esp
  801a2c:	5c                   	pop    %esp
        //subl $0x4,%esp   //CAN'T SUB HERE BECAUSE OF EFLAGS
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
        ret
  801a2d:	c3                   	ret    
	...

00801a30 <__udivdi3>:
  801a30:	55                   	push   %ebp
  801a31:	89 e5                	mov    %esp,%ebp
  801a33:	57                   	push   %edi
  801a34:	56                   	push   %esi
  801a35:	83 ec 10             	sub    $0x10,%esp
  801a38:	8b 45 14             	mov    0x14(%ebp),%eax
  801a3b:	8b 55 08             	mov    0x8(%ebp),%edx
  801a3e:	8b 75 10             	mov    0x10(%ebp),%esi
  801a41:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801a44:	85 c0                	test   %eax,%eax
  801a46:	89 55 f0             	mov    %edx,-0x10(%ebp)
  801a49:	75 35                	jne    801a80 <__udivdi3+0x50>
  801a4b:	39 fe                	cmp    %edi,%esi
  801a4d:	77 61                	ja     801ab0 <__udivdi3+0x80>
  801a4f:	85 f6                	test   %esi,%esi
  801a51:	75 0b                	jne    801a5e <__udivdi3+0x2e>
  801a53:	b8 01 00 00 00       	mov    $0x1,%eax
  801a58:	31 d2                	xor    %edx,%edx
  801a5a:	f7 f6                	div    %esi
  801a5c:	89 c6                	mov    %eax,%esi
  801a5e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  801a61:	31 d2                	xor    %edx,%edx
  801a63:	89 f8                	mov    %edi,%eax
  801a65:	f7 f6                	div    %esi
  801a67:	89 c7                	mov    %eax,%edi
  801a69:	89 c8                	mov    %ecx,%eax
  801a6b:	f7 f6                	div    %esi
  801a6d:	89 c1                	mov    %eax,%ecx
  801a6f:	89 fa                	mov    %edi,%edx
  801a71:	89 c8                	mov    %ecx,%eax
  801a73:	83 c4 10             	add    $0x10,%esp
  801a76:	5e                   	pop    %esi
  801a77:	5f                   	pop    %edi
  801a78:	5d                   	pop    %ebp
  801a79:	c3                   	ret    
  801a7a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801a80:	39 f8                	cmp    %edi,%eax
  801a82:	77 1c                	ja     801aa0 <__udivdi3+0x70>
  801a84:	0f bd d0             	bsr    %eax,%edx
  801a87:	83 f2 1f             	xor    $0x1f,%edx
  801a8a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801a8d:	75 39                	jne    801ac8 <__udivdi3+0x98>
  801a8f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  801a92:	0f 86 a0 00 00 00    	jbe    801b38 <__udivdi3+0x108>
  801a98:	39 f8                	cmp    %edi,%eax
  801a9a:	0f 82 98 00 00 00    	jb     801b38 <__udivdi3+0x108>
  801aa0:	31 ff                	xor    %edi,%edi
  801aa2:	31 c9                	xor    %ecx,%ecx
  801aa4:	89 c8                	mov    %ecx,%eax
  801aa6:	89 fa                	mov    %edi,%edx
  801aa8:	83 c4 10             	add    $0x10,%esp
  801aab:	5e                   	pop    %esi
  801aac:	5f                   	pop    %edi
  801aad:	5d                   	pop    %ebp
  801aae:	c3                   	ret    
  801aaf:	90                   	nop
  801ab0:	89 d1                	mov    %edx,%ecx
  801ab2:	89 fa                	mov    %edi,%edx
  801ab4:	89 c8                	mov    %ecx,%eax
  801ab6:	31 ff                	xor    %edi,%edi
  801ab8:	f7 f6                	div    %esi
  801aba:	89 c1                	mov    %eax,%ecx
  801abc:	89 fa                	mov    %edi,%edx
  801abe:	89 c8                	mov    %ecx,%eax
  801ac0:	83 c4 10             	add    $0x10,%esp
  801ac3:	5e                   	pop    %esi
  801ac4:	5f                   	pop    %edi
  801ac5:	5d                   	pop    %ebp
  801ac6:	c3                   	ret    
  801ac7:	90                   	nop
  801ac8:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801acc:	89 f2                	mov    %esi,%edx
  801ace:	d3 e0                	shl    %cl,%eax
  801ad0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801ad3:	b8 20 00 00 00       	mov    $0x20,%eax
  801ad8:	2b 45 f4             	sub    -0xc(%ebp),%eax
  801adb:	89 c1                	mov    %eax,%ecx
  801add:	d3 ea                	shr    %cl,%edx
  801adf:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801ae3:	0b 55 ec             	or     -0x14(%ebp),%edx
  801ae6:	d3 e6                	shl    %cl,%esi
  801ae8:	89 c1                	mov    %eax,%ecx
  801aea:	89 75 e8             	mov    %esi,-0x18(%ebp)
  801aed:	89 fe                	mov    %edi,%esi
  801aef:	d3 ee                	shr    %cl,%esi
  801af1:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801af5:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801af8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801afb:	d3 e7                	shl    %cl,%edi
  801afd:	89 c1                	mov    %eax,%ecx
  801aff:	d3 ea                	shr    %cl,%edx
  801b01:	09 d7                	or     %edx,%edi
  801b03:	89 f2                	mov    %esi,%edx
  801b05:	89 f8                	mov    %edi,%eax
  801b07:	f7 75 ec             	divl   -0x14(%ebp)
  801b0a:	89 d6                	mov    %edx,%esi
  801b0c:	89 c7                	mov    %eax,%edi
  801b0e:	f7 65 e8             	mull   -0x18(%ebp)
  801b11:	39 d6                	cmp    %edx,%esi
  801b13:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801b16:	72 30                	jb     801b48 <__udivdi3+0x118>
  801b18:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801b1b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801b1f:	d3 e2                	shl    %cl,%edx
  801b21:	39 c2                	cmp    %eax,%edx
  801b23:	73 05                	jae    801b2a <__udivdi3+0xfa>
  801b25:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  801b28:	74 1e                	je     801b48 <__udivdi3+0x118>
  801b2a:	89 f9                	mov    %edi,%ecx
  801b2c:	31 ff                	xor    %edi,%edi
  801b2e:	e9 71 ff ff ff       	jmp    801aa4 <__udivdi3+0x74>
  801b33:	90                   	nop
  801b34:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801b38:	31 ff                	xor    %edi,%edi
  801b3a:	b9 01 00 00 00       	mov    $0x1,%ecx
  801b3f:	e9 60 ff ff ff       	jmp    801aa4 <__udivdi3+0x74>
  801b44:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801b48:	8d 4f ff             	lea    -0x1(%edi),%ecx
  801b4b:	31 ff                	xor    %edi,%edi
  801b4d:	89 c8                	mov    %ecx,%eax
  801b4f:	89 fa                	mov    %edi,%edx
  801b51:	83 c4 10             	add    $0x10,%esp
  801b54:	5e                   	pop    %esi
  801b55:	5f                   	pop    %edi
  801b56:	5d                   	pop    %ebp
  801b57:	c3                   	ret    
	...

00801b60 <__umoddi3>:
  801b60:	55                   	push   %ebp
  801b61:	89 e5                	mov    %esp,%ebp
  801b63:	57                   	push   %edi
  801b64:	56                   	push   %esi
  801b65:	83 ec 20             	sub    $0x20,%esp
  801b68:	8b 55 14             	mov    0x14(%ebp),%edx
  801b6b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b6e:	8b 7d 10             	mov    0x10(%ebp),%edi
  801b71:	8b 75 0c             	mov    0xc(%ebp),%esi
  801b74:	85 d2                	test   %edx,%edx
  801b76:	89 c8                	mov    %ecx,%eax
  801b78:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801b7b:	75 13                	jne    801b90 <__umoddi3+0x30>
  801b7d:	39 f7                	cmp    %esi,%edi
  801b7f:	76 3f                	jbe    801bc0 <__umoddi3+0x60>
  801b81:	89 f2                	mov    %esi,%edx
  801b83:	f7 f7                	div    %edi
  801b85:	89 d0                	mov    %edx,%eax
  801b87:	31 d2                	xor    %edx,%edx
  801b89:	83 c4 20             	add    $0x20,%esp
  801b8c:	5e                   	pop    %esi
  801b8d:	5f                   	pop    %edi
  801b8e:	5d                   	pop    %ebp
  801b8f:	c3                   	ret    
  801b90:	39 f2                	cmp    %esi,%edx
  801b92:	77 4c                	ja     801be0 <__umoddi3+0x80>
  801b94:	0f bd ca             	bsr    %edx,%ecx
  801b97:	83 f1 1f             	xor    $0x1f,%ecx
  801b9a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801b9d:	75 51                	jne    801bf0 <__umoddi3+0x90>
  801b9f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  801ba2:	0f 87 e0 00 00 00    	ja     801c88 <__umoddi3+0x128>
  801ba8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bab:	29 f8                	sub    %edi,%eax
  801bad:	19 d6                	sbb    %edx,%esi
  801baf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801bb2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bb5:	89 f2                	mov    %esi,%edx
  801bb7:	83 c4 20             	add    $0x20,%esp
  801bba:	5e                   	pop    %esi
  801bbb:	5f                   	pop    %edi
  801bbc:	5d                   	pop    %ebp
  801bbd:	c3                   	ret    
  801bbe:	66 90                	xchg   %ax,%ax
  801bc0:	85 ff                	test   %edi,%edi
  801bc2:	75 0b                	jne    801bcf <__umoddi3+0x6f>
  801bc4:	b8 01 00 00 00       	mov    $0x1,%eax
  801bc9:	31 d2                	xor    %edx,%edx
  801bcb:	f7 f7                	div    %edi
  801bcd:	89 c7                	mov    %eax,%edi
  801bcf:	89 f0                	mov    %esi,%eax
  801bd1:	31 d2                	xor    %edx,%edx
  801bd3:	f7 f7                	div    %edi
  801bd5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bd8:	f7 f7                	div    %edi
  801bda:	eb a9                	jmp    801b85 <__umoddi3+0x25>
  801bdc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801be0:	89 c8                	mov    %ecx,%eax
  801be2:	89 f2                	mov    %esi,%edx
  801be4:	83 c4 20             	add    $0x20,%esp
  801be7:	5e                   	pop    %esi
  801be8:	5f                   	pop    %edi
  801be9:	5d                   	pop    %ebp
  801bea:	c3                   	ret    
  801beb:	90                   	nop
  801bec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801bf0:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801bf4:	d3 e2                	shl    %cl,%edx
  801bf6:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801bf9:	ba 20 00 00 00       	mov    $0x20,%edx
  801bfe:	2b 55 f0             	sub    -0x10(%ebp),%edx
  801c01:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801c04:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801c08:	89 fa                	mov    %edi,%edx
  801c0a:	d3 ea                	shr    %cl,%edx
  801c0c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801c10:	0b 55 f4             	or     -0xc(%ebp),%edx
  801c13:	d3 e7                	shl    %cl,%edi
  801c15:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801c19:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801c1c:	89 f2                	mov    %esi,%edx
  801c1e:	89 7d e8             	mov    %edi,-0x18(%ebp)
  801c21:	89 c7                	mov    %eax,%edi
  801c23:	d3 ea                	shr    %cl,%edx
  801c25:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801c29:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  801c2c:	89 c2                	mov    %eax,%edx
  801c2e:	d3 e6                	shl    %cl,%esi
  801c30:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801c34:	d3 ea                	shr    %cl,%edx
  801c36:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801c3a:	09 d6                	or     %edx,%esi
  801c3c:	89 f0                	mov    %esi,%eax
  801c3e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  801c41:	d3 e7                	shl    %cl,%edi
  801c43:	89 f2                	mov    %esi,%edx
  801c45:	f7 75 f4             	divl   -0xc(%ebp)
  801c48:	89 d6                	mov    %edx,%esi
  801c4a:	f7 65 e8             	mull   -0x18(%ebp)
  801c4d:	39 d6                	cmp    %edx,%esi
  801c4f:	72 2b                	jb     801c7c <__umoddi3+0x11c>
  801c51:	39 c7                	cmp    %eax,%edi
  801c53:	72 23                	jb     801c78 <__umoddi3+0x118>
  801c55:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801c59:	29 c7                	sub    %eax,%edi
  801c5b:	19 d6                	sbb    %edx,%esi
  801c5d:	89 f0                	mov    %esi,%eax
  801c5f:	89 f2                	mov    %esi,%edx
  801c61:	d3 ef                	shr    %cl,%edi
  801c63:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801c67:	d3 e0                	shl    %cl,%eax
  801c69:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801c6d:	09 f8                	or     %edi,%eax
  801c6f:	d3 ea                	shr    %cl,%edx
  801c71:	83 c4 20             	add    $0x20,%esp
  801c74:	5e                   	pop    %esi
  801c75:	5f                   	pop    %edi
  801c76:	5d                   	pop    %ebp
  801c77:	c3                   	ret    
  801c78:	39 d6                	cmp    %edx,%esi
  801c7a:	75 d9                	jne    801c55 <__umoddi3+0xf5>
  801c7c:	2b 45 e8             	sub    -0x18(%ebp),%eax
  801c7f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  801c82:	eb d1                	jmp    801c55 <__umoddi3+0xf5>
  801c84:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c88:	39 f2                	cmp    %esi,%edx
  801c8a:	0f 82 18 ff ff ff    	jb     801ba8 <__umoddi3+0x48>
  801c90:	e9 1d ff ff ff       	jmp    801bb2 <__umoddi3+0x52>
