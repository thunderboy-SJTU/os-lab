
obj/user/icode.debug:     file format elf32-i386


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
  80002c:	e8 2b 01 00 00       	call   80015c <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	81 ec 30 02 00 00    	sub    $0x230,%esp
	int fd, n, r;
	char buf[512+1];

	binaryname = "icode";
  80003f:	c7 05 00 40 80 00 60 	movl   $0x803260,0x804000
  800046:	32 80 00 

	cprintf("icode startup\n");
  800049:	c7 04 24 66 32 80 00 	movl   $0x803266,(%esp)
  800050:	e8 30 02 00 00       	call   800285 <cprintf>

	cprintf("icode: open /motd\n");
  800055:	c7 04 24 75 32 80 00 	movl   $0x803275,(%esp)
  80005c:	e8 24 02 00 00       	call   800285 <cprintf>
	if ((fd = open("/motd", O_RDONLY)) < 0)
  800061:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800068:	00 
  800069:	c7 04 24 88 32 80 00 	movl   $0x803288,(%esp)
  800070:	e8 42 1e 00 00       	call   801eb7 <open>
  800075:	89 c6                	mov    %eax,%esi
  800077:	85 c0                	test   %eax,%eax
  800079:	79 20                	jns    80009b <umain+0x67>
		panic("icode: open /motd: %e", fd);
  80007b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80007f:	c7 44 24 08 8e 32 80 	movl   $0x80328e,0x8(%esp)
  800086:	00 
  800087:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
  80008e:	00 
  80008f:	c7 04 24 a4 32 80 00 	movl   $0x8032a4,(%esp)
  800096:	e8 31 01 00 00       	call   8001cc <_panic>

	cprintf("icode: read /motd\n");
  80009b:	c7 04 24 b1 32 80 00 	movl   $0x8032b1,(%esp)
  8000a2:	e8 de 01 00 00       	call   800285 <cprintf>
	while ((n = read(fd, buf, sizeof buf-1)) > 0)
  8000a7:	8d 9d f7 fd ff ff    	lea    -0x209(%ebp),%ebx
  8000ad:	eb 0c                	jmp    8000bb <umain+0x87>
		sys_cputs(buf, n);
  8000af:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000b3:	89 1c 24             	mov    %ebx,(%esp)
  8000b6:	e8 31 0f 00 00       	call   800fec <sys_cputs>
	cprintf("icode: open /motd\n");
	if ((fd = open("/motd", O_RDONLY)) < 0)
		panic("icode: open /motd: %e", fd);

	cprintf("icode: read /motd\n");
	while ((n = read(fd, buf, sizeof buf-1)) > 0)
  8000bb:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  8000c2:	00 
  8000c3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000c7:	89 34 24             	mov    %esi,(%esp)
  8000ca:	e8 bf 18 00 00       	call   80198e <read>
  8000cf:	85 c0                	test   %eax,%eax
  8000d1:	7f dc                	jg     8000af <umain+0x7b>
		sys_cputs(buf, n);

	cprintf("icode: close /motd\n");
  8000d3:	c7 04 24 c4 32 80 00 	movl   $0x8032c4,(%esp)
  8000da:	e8 a6 01 00 00       	call   800285 <cprintf>
	close(fd);
  8000df:	89 34 24             	mov    %esi,(%esp)
  8000e2:	e8 07 1a 00 00       	call   801aee <close>

	cprintf("icode: spawn /init\n");
  8000e7:	c7 04 24 d8 32 80 00 	movl   $0x8032d8,(%esp)
  8000ee:	e8 92 01 00 00       	call   800285 <cprintf>
	if ((r = spawnl("/init", "init", "initarg1", "initarg2", (char*)0)) < 0)
  8000f3:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8000fa:	00 
  8000fb:	c7 44 24 0c ec 32 80 	movl   $0x8032ec,0xc(%esp)
  800102:	00 
  800103:	c7 44 24 08 f5 32 80 	movl   $0x8032f5,0x8(%esp)
  80010a:	00 
  80010b:	c7 44 24 04 ff 32 80 	movl   $0x8032ff,0x4(%esp)
  800112:	00 
  800113:	c7 04 24 fe 32 80 00 	movl   $0x8032fe,(%esp)
  80011a:	e8 9d 27 00 00       	call   8028bc <spawnl>
  80011f:	85 c0                	test   %eax,%eax
  800121:	79 20                	jns    800143 <umain+0x10f>
		panic("icode: spawn /init: %e", r);
  800123:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800127:	c7 44 24 08 04 33 80 	movl   $0x803304,0x8(%esp)
  80012e:	00 
  80012f:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  800136:	00 
  800137:	c7 04 24 a4 32 80 00 	movl   $0x8032a4,(%esp)
  80013e:	e8 89 00 00 00       	call   8001cc <_panic>

	cprintf("icode: exiting\n");
  800143:	c7 04 24 1b 33 80 00 	movl   $0x80331b,(%esp)
  80014a:	e8 36 01 00 00       	call   800285 <cprintf>
}
  80014f:	81 c4 30 02 00 00    	add    $0x230,%esp
  800155:	5b                   	pop    %ebx
  800156:	5e                   	pop    %esi
  800157:	5d                   	pop    %ebp
  800158:	c3                   	ret    
  800159:	00 00                	add    %al,(%eax)
	...

0080015c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80015c:	55                   	push   %ebp
  80015d:	89 e5                	mov    %esp,%ebp
  80015f:	83 ec 18             	sub    $0x18,%esp
  800162:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800165:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800168:	8b 75 08             	mov    0x8(%ebp),%esi
  80016b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  80016e:	e8 64 14 00 00       	call   8015d7 <sys_getenvid>
  800173:	25 ff 03 00 00       	and    $0x3ff,%eax
  800178:	89 c2                	mov    %eax,%edx
  80017a:	c1 e2 07             	shl    $0x7,%edx
  80017d:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  800184:	a3 08 50 80 00       	mov    %eax,0x805008
        //cprintf("ENVX sys_get_envid(): %d\n",ENVX(sys_getenvid()));
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800189:	85 f6                	test   %esi,%esi
  80018b:	7e 07                	jle    800194 <libmain+0x38>
		binaryname = argv[0];
  80018d:	8b 03                	mov    (%ebx),%eax
  80018f:	a3 00 40 80 00       	mov    %eax,0x804000

	// call user main routine
	umain(argc, argv);
  800194:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800198:	89 34 24             	mov    %esi,(%esp)
  80019b:	e8 94 fe ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8001a0:	e8 0b 00 00 00       	call   8001b0 <exit>
}
  8001a5:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8001a8:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8001ab:	89 ec                	mov    %ebp,%esp
  8001ad:	5d                   	pop    %ebp
  8001ae:	c3                   	ret    
	...

008001b0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001b0:	55                   	push   %ebp
  8001b1:	89 e5                	mov    %esp,%ebp
  8001b3:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8001b6:	e8 b0 19 00 00       	call   801b6b <close_all>
	sys_env_destroy(0);
  8001bb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8001c2:	e8 50 14 00 00       	call   801617 <sys_env_destroy>
}
  8001c7:	c9                   	leave  
  8001c8:	c3                   	ret    
  8001c9:	00 00                	add    %al,(%eax)
	...

008001cc <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8001cc:	55                   	push   %ebp
  8001cd:	89 e5                	mov    %esp,%ebp
  8001cf:	56                   	push   %esi
  8001d0:	53                   	push   %ebx
  8001d1:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  8001d4:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001d7:	8b 1d 00 40 80 00    	mov    0x804000,%ebx
  8001dd:	e8 f5 13 00 00       	call   8015d7 <sys_getenvid>
  8001e2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001e5:	89 54 24 10          	mov    %edx,0x10(%esp)
  8001e9:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ec:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8001f0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001f8:	c7 04 24 38 33 80 00 	movl   $0x803338,(%esp)
  8001ff:	e8 81 00 00 00       	call   800285 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800204:	89 74 24 04          	mov    %esi,0x4(%esp)
  800208:	8b 45 10             	mov    0x10(%ebp),%eax
  80020b:	89 04 24             	mov    %eax,(%esp)
  80020e:	e8 11 00 00 00       	call   800224 <vcprintf>
	cprintf("\n");
  800213:	c7 04 24 c2 32 80 00 	movl   $0x8032c2,(%esp)
  80021a:	e8 66 00 00 00       	call   800285 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80021f:	cc                   	int3   
  800220:	eb fd                	jmp    80021f <_panic+0x53>
	...

00800224 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  800224:	55                   	push   %ebp
  800225:	89 e5                	mov    %esp,%ebp
  800227:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80022d:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800234:	00 00 00 
	b.cnt = 0;
  800237:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80023e:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800241:	8b 45 0c             	mov    0xc(%ebp),%eax
  800244:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800248:	8b 45 08             	mov    0x8(%ebp),%eax
  80024b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80024f:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800255:	89 44 24 04          	mov    %eax,0x4(%esp)
  800259:	c7 04 24 9f 02 80 00 	movl   $0x80029f,(%esp)
  800260:	e8 d7 01 00 00       	call   80043c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800265:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80026b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80026f:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800275:	89 04 24             	mov    %eax,(%esp)
  800278:	e8 6f 0d 00 00       	call   800fec <sys_cputs>

	return b.cnt;
}
  80027d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800283:	c9                   	leave  
  800284:	c3                   	ret    

00800285 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800285:	55                   	push   %ebp
  800286:	89 e5                	mov    %esp,%ebp
  800288:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  80028b:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  80028e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800292:	8b 45 08             	mov    0x8(%ebp),%eax
  800295:	89 04 24             	mov    %eax,(%esp)
  800298:	e8 87 ff ff ff       	call   800224 <vcprintf>
	va_end(ap);

	return cnt;
}
  80029d:	c9                   	leave  
  80029e:	c3                   	ret    

0080029f <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80029f:	55                   	push   %ebp
  8002a0:	89 e5                	mov    %esp,%ebp
  8002a2:	53                   	push   %ebx
  8002a3:	83 ec 14             	sub    $0x14,%esp
  8002a6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8002a9:	8b 03                	mov    (%ebx),%eax
  8002ab:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ae:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8002b2:	83 c0 01             	add    $0x1,%eax
  8002b5:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8002b7:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002bc:	75 19                	jne    8002d7 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8002be:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8002c5:	00 
  8002c6:	8d 43 08             	lea    0x8(%ebx),%eax
  8002c9:	89 04 24             	mov    %eax,(%esp)
  8002cc:	e8 1b 0d 00 00       	call   800fec <sys_cputs>
		b->idx = 0;
  8002d1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8002d7:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8002db:	83 c4 14             	add    $0x14,%esp
  8002de:	5b                   	pop    %ebx
  8002df:	5d                   	pop    %ebp
  8002e0:	c3                   	ret    
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
  80035f:	e8 7c 2c 00 00       	call   802fe0 <__udivdi3>
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
  8003c7:	e8 44 2d 00 00       	call   803110 <__umoddi3>
  8003cc:	89 74 24 04          	mov    %esi,0x4(%esp)
  8003d0:	0f be 80 5b 33 80 00 	movsbl 0x80335b(%eax),%eax
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
  8004ba:	ff 24 95 40 35 80 00 	jmp    *0x803540(,%edx,4)
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
  800572:	83 f8 0f             	cmp    $0xf,%eax
  800575:	7f 0b                	jg     800582 <vprintfmt+0x146>
  800577:	8b 14 85 a0 36 80 00 	mov    0x8036a0(,%eax,4),%edx
  80057e:	85 d2                	test   %edx,%edx
  800580:	75 26                	jne    8005a8 <vprintfmt+0x16c>
				printfmt(putch, putdat, "error %d", err);
  800582:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800586:	c7 44 24 08 6c 33 80 	movl   $0x80336c,0x8(%esp)
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
  8005ac:	c7 44 24 08 e9 37 80 	movl   $0x8037e9,0x8(%esp)
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
  8005ea:	be 75 33 80 00       	mov    $0x803375,%esi
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
  800894:	e8 47 27 00 00       	call   802fe0 <__udivdi3>
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
  8008e0:	e8 2b 28 00 00       	call   803110 <__umoddi3>
  8008e5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8008e9:	0f be 80 5b 33 80 00 	movsbl 0x80335b(%eax),%eax
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
  800995:	c7 44 24 0c 90 34 80 	movl   $0x803490,0xc(%esp)
  80099c:	00 
  80099d:	c7 44 24 08 e9 37 80 	movl   $0x8037e9,0x8(%esp)
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
  8009cb:	c7 44 24 0c c8 34 80 	movl   $0x8034c8,0xc(%esp)
  8009d2:	00 
  8009d3:	c7 44 24 08 e9 37 80 	movl   $0x8037e9,0x8(%esp)
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
  800a5f:	e8 ac 26 00 00       	call   803110 <__umoddi3>
  800a64:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a68:	0f be 80 5b 33 80 00 	movsbl 0x80335b(%eax),%eax
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
  800aa1:	e8 6a 26 00 00       	call   803110 <__umoddi3>
  800aa6:	89 74 24 04          	mov    %esi,0x4(%esp)
  800aaa:	0f be 80 5b 33 80 00 	movsbl 0x80335b(%eax),%eax
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

0080102b <sys_get_mac>:
sys_receive_packet(uint32_t addr,int* len){
         return syscall(SYS_receive_packet,0,(uint32_t)addr,(uint32_t)len,0,0,0);
}

int 
sys_get_mac(uint8_t* macaddr){
  80102b:	55                   	push   %ebp
  80102c:	89 e5                	mov    %esp,%ebp
  80102e:	83 ec 08             	sub    $0x8,%esp
  801031:	89 1c 24             	mov    %ebx,(%esp)
  801034:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801038:	b9 00 00 00 00       	mov    $0x0,%ecx
  80103d:	b8 13 00 00 00       	mov    $0x13,%eax
  801042:	8b 55 08             	mov    0x8(%ebp),%edx
  801045:	89 cb                	mov    %ecx,%ebx
  801047:	89 cf                	mov    %ecx,%edi
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
}

int 
sys_get_mac(uint8_t* macaddr){
         return syscall(SYS_get_mac,0,(uint32_t)macaddr,0,0,0,0);
}
  801061:	8b 1c 24             	mov    (%esp),%ebx
  801064:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801068:	89 ec                	mov    %ebp,%esp
  80106a:	5d                   	pop    %ebp
  80106b:	c3                   	ret    

0080106c <sys_receive_packet>:
sys_transmit_packet(uint32_t addr,int len){
         return syscall(SYS_transmit_packet,0,(uint32_t)addr,(uint32_t)len,0,0,0);
}

int 
sys_receive_packet(uint32_t addr,int* len){
  80106c:	55                   	push   %ebp
  80106d:	89 e5                	mov    %esp,%ebp
  80106f:	83 ec 08             	sub    $0x8,%esp
  801072:	89 1c 24             	mov    %ebx,(%esp)
  801075:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801079:	bb 00 00 00 00       	mov    $0x0,%ebx
  80107e:	b8 12 00 00 00       	mov    $0x12,%eax
  801083:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801086:	8b 55 08             	mov    0x8(%ebp),%edx
  801089:	89 df                	mov    %ebx,%edi
  80108b:	51                   	push   %ecx
  80108c:	52                   	push   %edx
  80108d:	53                   	push   %ebx
  80108e:	54                   	push   %esp
  80108f:	55                   	push   %ebp
  801090:	56                   	push   %esi
  801091:	57                   	push   %edi
  801092:	54                   	push   %esp
  801093:	5d                   	pop    %ebp
  801094:	8d 35 9c 10 80 00    	lea    0x80109c,%esi
  80109a:	0f 34                	sysenter 
  80109c:	5f                   	pop    %edi
  80109d:	5e                   	pop    %esi
  80109e:	5d                   	pop    %ebp
  80109f:	5c                   	pop    %esp
  8010a0:	5b                   	pop    %ebx
  8010a1:	5a                   	pop    %edx
  8010a2:	59                   	pop    %ecx
}

int 
sys_receive_packet(uint32_t addr,int* len){
         return syscall(SYS_receive_packet,0,(uint32_t)addr,(uint32_t)len,0,0,0);
}
  8010a3:	8b 1c 24             	mov    (%esp),%ebx
  8010a6:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8010aa:	89 ec                	mov    %ebp,%esp
  8010ac:	5d                   	pop    %ebp
  8010ad:	c3                   	ret    

008010ae <sys_transmit_packet>:
sys_exec(void* vph, uint32_t phnum, uint32_t esp, uint32_t eip){
         return syscall(SYS_exec, 0, (uint32_t)vph, phnum, esp, eip, 0);
}

int 
sys_transmit_packet(uint32_t addr,int len){
  8010ae:	55                   	push   %ebp
  8010af:	89 e5                	mov    %esp,%ebp
  8010b1:	83 ec 08             	sub    $0x8,%esp
  8010b4:	89 1c 24             	mov    %ebx,(%esp)
  8010b7:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8010bb:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010c0:	b8 11 00 00 00       	mov    $0x11,%eax
  8010c5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010c8:	8b 55 08             	mov    0x8(%ebp),%edx
  8010cb:	89 df                	mov    %ebx,%edi
  8010cd:	51                   	push   %ecx
  8010ce:	52                   	push   %edx
  8010cf:	53                   	push   %ebx
  8010d0:	54                   	push   %esp
  8010d1:	55                   	push   %ebp
  8010d2:	56                   	push   %esi
  8010d3:	57                   	push   %edi
  8010d4:	54                   	push   %esp
  8010d5:	5d                   	pop    %ebp
  8010d6:	8d 35 de 10 80 00    	lea    0x8010de,%esi
  8010dc:	0f 34                	sysenter 
  8010de:	5f                   	pop    %edi
  8010df:	5e                   	pop    %esi
  8010e0:	5d                   	pop    %ebp
  8010e1:	5c                   	pop    %esp
  8010e2:	5b                   	pop    %ebx
  8010e3:	5a                   	pop    %edx
  8010e4:	59                   	pop    %ecx
}

int 
sys_transmit_packet(uint32_t addr,int len){
         return syscall(SYS_transmit_packet,0,(uint32_t)addr,(uint32_t)len,0,0,0);
}
  8010e5:	8b 1c 24             	mov    (%esp),%ebx
  8010e8:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8010ec:	89 ec                	mov    %ebp,%esp
  8010ee:	5d                   	pop    %ebp
  8010ef:	c3                   	ret    

008010f0 <sys_exec>:
sys_env_set_prior(envid_t envid, uint32_t prior){
         return syscall(SYS_env_set_prior,1,envid, prior, 0, 0, 0);
}

int 
sys_exec(void* vph, uint32_t phnum, uint32_t esp, uint32_t eip){
  8010f0:	55                   	push   %ebp
  8010f1:	89 e5                	mov    %esp,%ebp
  8010f3:	83 ec 08             	sub    $0x8,%esp
  8010f6:	89 1c 24             	mov    %ebx,(%esp)
  8010f9:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8010fd:	b8 10 00 00 00       	mov    $0x10,%eax
  801102:	8b 7d 14             	mov    0x14(%ebp),%edi
  801105:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801108:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80110b:	8b 55 08             	mov    0x8(%ebp),%edx
  80110e:	51                   	push   %ecx
  80110f:	52                   	push   %edx
  801110:	53                   	push   %ebx
  801111:	54                   	push   %esp
  801112:	55                   	push   %ebp
  801113:	56                   	push   %esi
  801114:	57                   	push   %edi
  801115:	54                   	push   %esp
  801116:	5d                   	pop    %ebp
  801117:	8d 35 1f 11 80 00    	lea    0x80111f,%esi
  80111d:	0f 34                	sysenter 
  80111f:	5f                   	pop    %edi
  801120:	5e                   	pop    %esi
  801121:	5d                   	pop    %ebp
  801122:	5c                   	pop    %esp
  801123:	5b                   	pop    %ebx
  801124:	5a                   	pop    %edx
  801125:	59                   	pop    %ecx
}

int 
sys_exec(void* vph, uint32_t phnum, uint32_t esp, uint32_t eip){
         return syscall(SYS_exec, 0, (uint32_t)vph, phnum, esp, eip, 0);
}
  801126:	8b 1c 24             	mov    (%esp),%ebx
  801129:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80112d:	89 ec                	mov    %ebp,%esp
  80112f:	5d                   	pop    %ebp
  801130:	c3                   	ret    

00801131 <sys_env_set_prior>:
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}


int 
sys_env_set_prior(envid_t envid, uint32_t prior){
  801131:	55                   	push   %ebp
  801132:	89 e5                	mov    %esp,%ebp
  801134:	83 ec 28             	sub    $0x28,%esp
  801137:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80113a:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80113d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801142:	b8 0f 00 00 00       	mov    $0xf,%eax
  801147:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80114a:	8b 55 08             	mov    0x8(%ebp),%edx
  80114d:	89 df                	mov    %ebx,%edi
  80114f:	51                   	push   %ecx
  801150:	52                   	push   %edx
  801151:	53                   	push   %ebx
  801152:	54                   	push   %esp
  801153:	55                   	push   %ebp
  801154:	56                   	push   %esi
  801155:	57                   	push   %edi
  801156:	54                   	push   %esp
  801157:	5d                   	pop    %ebp
  801158:	8d 35 60 11 80 00    	lea    0x801160,%esi
  80115e:	0f 34                	sysenter 
  801160:	5f                   	pop    %edi
  801161:	5e                   	pop    %esi
  801162:	5d                   	pop    %ebp
  801163:	5c                   	pop    %esp
  801164:	5b                   	pop    %ebx
  801165:	5a                   	pop    %edx
  801166:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801167:	85 c0                	test   %eax,%eax
  801169:	7e 28                	jle    801193 <sys_env_set_prior+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  80116b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80116f:	c7 44 24 0c 0f 00 00 	movl   $0xf,0xc(%esp)
  801176:	00 
  801177:	c7 44 24 08 e0 36 80 	movl   $0x8036e0,0x8(%esp)
  80117e:	00 
  80117f:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801186:	00 
  801187:	c7 04 24 fd 36 80 00 	movl   $0x8036fd,(%esp)
  80118e:	e8 39 f0 ff ff       	call   8001cc <_panic>


int 
sys_env_set_prior(envid_t envid, uint32_t prior){
         return syscall(SYS_env_set_prior,1,envid, prior, 0, 0, 0);
}
  801193:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801196:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801199:	89 ec                	mov    %ebp,%esp
  80119b:	5d                   	pop    %ebp
  80119c:	c3                   	ret    

0080119d <sys_time_msec>:
}


unsigned int
sys_time_msec(void)
{
  80119d:	55                   	push   %ebp
  80119e:	89 e5                	mov    %esp,%ebp
  8011a0:	83 ec 08             	sub    $0x8,%esp
  8011a3:	89 1c 24             	mov    %ebx,(%esp)
  8011a6:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8011aa:	ba 00 00 00 00       	mov    $0x0,%edx
  8011af:	b8 15 00 00 00       	mov    $0x15,%eax
  8011b4:	89 d1                	mov    %edx,%ecx
  8011b6:	89 d3                	mov    %edx,%ebx
  8011b8:	89 d7                	mov    %edx,%edi
  8011ba:	51                   	push   %ecx
  8011bb:	52                   	push   %edx
  8011bc:	53                   	push   %ebx
  8011bd:	54                   	push   %esp
  8011be:	55                   	push   %ebp
  8011bf:	56                   	push   %esi
  8011c0:	57                   	push   %edi
  8011c1:	54                   	push   %esp
  8011c2:	5d                   	pop    %ebp
  8011c3:	8d 35 cb 11 80 00    	lea    0x8011cb,%esi
  8011c9:	0f 34                	sysenter 
  8011cb:	5f                   	pop    %edi
  8011cc:	5e                   	pop    %esi
  8011cd:	5d                   	pop    %ebp
  8011ce:	5c                   	pop    %esp
  8011cf:	5b                   	pop    %ebx
  8011d0:	5a                   	pop    %edx
  8011d1:	59                   	pop    %ecx

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  8011d2:	8b 1c 24             	mov    (%esp),%ebx
  8011d5:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8011d9:	89 ec                	mov    %ebp,%esp
  8011db:	5d                   	pop    %ebp
  8011dc:	c3                   	ret    

008011dd <sys_sbrk>:
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}

int
sys_sbrk(uint32_t inc)
{
  8011dd:	55                   	push   %ebp
  8011de:	89 e5                	mov    %esp,%ebp
  8011e0:	83 ec 08             	sub    $0x8,%esp
  8011e3:	89 1c 24             	mov    %ebx,(%esp)
  8011e6:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8011ea:	b9 00 00 00 00       	mov    $0x0,%ecx
  8011ef:	b8 14 00 00 00       	mov    $0x14,%eax
  8011f4:	8b 55 08             	mov    0x8(%ebp),%edx
  8011f7:	89 cb                	mov    %ecx,%ebx
  8011f9:	89 cf                	mov    %ecx,%edi
  8011fb:	51                   	push   %ecx
  8011fc:	52                   	push   %edx
  8011fd:	53                   	push   %ebx
  8011fe:	54                   	push   %esp
  8011ff:	55                   	push   %ebp
  801200:	56                   	push   %esi
  801201:	57                   	push   %edi
  801202:	54                   	push   %esp
  801203:	5d                   	pop    %ebp
  801204:	8d 35 0c 12 80 00    	lea    0x80120c,%esi
  80120a:	0f 34                	sysenter 
  80120c:	5f                   	pop    %edi
  80120d:	5e                   	pop    %esi
  80120e:	5d                   	pop    %ebp
  80120f:	5c                   	pop    %esp
  801210:	5b                   	pop    %ebx
  801211:	5a                   	pop    %edx
  801212:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  801213:	8b 1c 24             	mov    (%esp),%ebx
  801216:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80121a:	89 ec                	mov    %ebp,%esp
  80121c:	5d                   	pop    %ebp
  80121d:	c3                   	ret    

0080121e <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  80121e:	55                   	push   %ebp
  80121f:	89 e5                	mov    %esp,%ebp
  801221:	83 ec 28             	sub    $0x28,%esp
  801224:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801227:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80122a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80122f:	b8 0e 00 00 00       	mov    $0xe,%eax
  801234:	8b 55 08             	mov    0x8(%ebp),%edx
  801237:	89 cb                	mov    %ecx,%ebx
  801239:	89 cf                	mov    %ecx,%edi
  80123b:	51                   	push   %ecx
  80123c:	52                   	push   %edx
  80123d:	53                   	push   %ebx
  80123e:	54                   	push   %esp
  80123f:	55                   	push   %ebp
  801240:	56                   	push   %esi
  801241:	57                   	push   %edi
  801242:	54                   	push   %esp
  801243:	5d                   	pop    %ebp
  801244:	8d 35 4c 12 80 00    	lea    0x80124c,%esi
  80124a:	0f 34                	sysenter 
  80124c:	5f                   	pop    %edi
  80124d:	5e                   	pop    %esi
  80124e:	5d                   	pop    %ebp
  80124f:	5c                   	pop    %esp
  801250:	5b                   	pop    %ebx
  801251:	5a                   	pop    %edx
  801252:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801253:	85 c0                	test   %eax,%eax
  801255:	7e 28                	jle    80127f <sys_ipc_recv+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  801257:	89 44 24 10          	mov    %eax,0x10(%esp)
  80125b:	c7 44 24 0c 0e 00 00 	movl   $0xe,0xc(%esp)
  801262:	00 
  801263:	c7 44 24 08 e0 36 80 	movl   $0x8036e0,0x8(%esp)
  80126a:	00 
  80126b:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801272:	00 
  801273:	c7 04 24 fd 36 80 00 	movl   $0x8036fd,(%esp)
  80127a:	e8 4d ef ff ff       	call   8001cc <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80127f:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801282:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801285:	89 ec                	mov    %ebp,%esp
  801287:	5d                   	pop    %ebp
  801288:	c3                   	ret    

00801289 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801289:	55                   	push   %ebp
  80128a:	89 e5                	mov    %esp,%ebp
  80128c:	83 ec 08             	sub    $0x8,%esp
  80128f:	89 1c 24             	mov    %ebx,(%esp)
  801292:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801296:	b8 0d 00 00 00       	mov    $0xd,%eax
  80129b:	8b 7d 14             	mov    0x14(%ebp),%edi
  80129e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8012a1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012a4:	8b 55 08             	mov    0x8(%ebp),%edx
  8012a7:	51                   	push   %ecx
  8012a8:	52                   	push   %edx
  8012a9:	53                   	push   %ebx
  8012aa:	54                   	push   %esp
  8012ab:	55                   	push   %ebp
  8012ac:	56                   	push   %esi
  8012ad:	57                   	push   %edi
  8012ae:	54                   	push   %esp
  8012af:	5d                   	pop    %ebp
  8012b0:	8d 35 b8 12 80 00    	lea    0x8012b8,%esi
  8012b6:	0f 34                	sysenter 
  8012b8:	5f                   	pop    %edi
  8012b9:	5e                   	pop    %esi
  8012ba:	5d                   	pop    %ebp
  8012bb:	5c                   	pop    %esp
  8012bc:	5b                   	pop    %ebx
  8012bd:	5a                   	pop    %edx
  8012be:	59                   	pop    %ecx

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8012bf:	8b 1c 24             	mov    (%esp),%ebx
  8012c2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8012c6:	89 ec                	mov    %ebp,%esp
  8012c8:	5d                   	pop    %ebp
  8012c9:	c3                   	ret    

008012ca <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8012ca:	55                   	push   %ebp
  8012cb:	89 e5                	mov    %esp,%ebp
  8012cd:	83 ec 28             	sub    $0x28,%esp
  8012d0:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8012d3:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8012d6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012db:	b8 0b 00 00 00       	mov    $0xb,%eax
  8012e0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012e3:	8b 55 08             	mov    0x8(%ebp),%edx
  8012e6:	89 df                	mov    %ebx,%edi
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
  801302:	7e 28                	jle    80132c <sys_env_set_pgfault_upcall+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  801304:	89 44 24 10          	mov    %eax,0x10(%esp)
  801308:	c7 44 24 0c 0b 00 00 	movl   $0xb,0xc(%esp)
  80130f:	00 
  801310:	c7 44 24 08 e0 36 80 	movl   $0x8036e0,0x8(%esp)
  801317:	00 
  801318:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80131f:	00 
  801320:	c7 04 24 fd 36 80 00 	movl   $0x8036fd,(%esp)
  801327:	e8 a0 ee ff ff       	call   8001cc <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80132c:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80132f:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801332:	89 ec                	mov    %ebp,%esp
  801334:	5d                   	pop    %ebp
  801335:	c3                   	ret    

00801336 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
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
  801342:	bb 00 00 00 00       	mov    $0x0,%ebx
  801347:	b8 0a 00 00 00       	mov    $0xa,%eax
  80134c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80134f:	8b 55 08             	mov    0x8(%ebp),%edx
  801352:	89 df                	mov    %ebx,%edi
  801354:	51                   	push   %ecx
  801355:	52                   	push   %edx
  801356:	53                   	push   %ebx
  801357:	54                   	push   %esp
  801358:	55                   	push   %ebp
  801359:	56                   	push   %esi
  80135a:	57                   	push   %edi
  80135b:	54                   	push   %esp
  80135c:	5d                   	pop    %ebp
  80135d:	8d 35 65 13 80 00    	lea    0x801365,%esi
  801363:	0f 34                	sysenter 
  801365:	5f                   	pop    %edi
  801366:	5e                   	pop    %esi
  801367:	5d                   	pop    %ebp
  801368:	5c                   	pop    %esp
  801369:	5b                   	pop    %ebx
  80136a:	5a                   	pop    %edx
  80136b:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80136c:	85 c0                	test   %eax,%eax
  80136e:	7e 28                	jle    801398 <sys_env_set_trapframe+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  801370:	89 44 24 10          	mov    %eax,0x10(%esp)
  801374:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  80137b:	00 
  80137c:	c7 44 24 08 e0 36 80 	movl   $0x8036e0,0x8(%esp)
  801383:	00 
  801384:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80138b:	00 
  80138c:	c7 04 24 fd 36 80 00 	movl   $0x8036fd,(%esp)
  801393:	e8 34 ee ff ff       	call   8001cc <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801398:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80139b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80139e:	89 ec                	mov    %ebp,%esp
  8013a0:	5d                   	pop    %ebp
  8013a1:	c3                   	ret    

008013a2 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8013a2:	55                   	push   %ebp
  8013a3:	89 e5                	mov    %esp,%ebp
  8013a5:	83 ec 28             	sub    $0x28,%esp
  8013a8:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8013ab:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8013ae:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013b3:	b8 09 00 00 00       	mov    $0x9,%eax
  8013b8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013bb:	8b 55 08             	mov    0x8(%ebp),%edx
  8013be:	89 df                	mov    %ebx,%edi
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
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8013d8:	85 c0                	test   %eax,%eax
  8013da:	7e 28                	jle    801404 <sys_env_set_status+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  8013dc:	89 44 24 10          	mov    %eax,0x10(%esp)
  8013e0:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8013e7:	00 
  8013e8:	c7 44 24 08 e0 36 80 	movl   $0x8036e0,0x8(%esp)
  8013ef:	00 
  8013f0:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8013f7:	00 
  8013f8:	c7 04 24 fd 36 80 00 	movl   $0x8036fd,(%esp)
  8013ff:	e8 c8 ed ff ff       	call   8001cc <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801404:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801407:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80140a:	89 ec                	mov    %ebp,%esp
  80140c:	5d                   	pop    %ebp
  80140d:	c3                   	ret    

0080140e <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  80140e:	55                   	push   %ebp
  80140f:	89 e5                	mov    %esp,%ebp
  801411:	83 ec 28             	sub    $0x28,%esp
  801414:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801417:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80141a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80141f:	b8 07 00 00 00       	mov    $0x7,%eax
  801424:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801427:	8b 55 08             	mov    0x8(%ebp),%edx
  80142a:	89 df                	mov    %ebx,%edi
  80142c:	51                   	push   %ecx
  80142d:	52                   	push   %edx
  80142e:	53                   	push   %ebx
  80142f:	54                   	push   %esp
  801430:	55                   	push   %ebp
  801431:	56                   	push   %esi
  801432:	57                   	push   %edi
  801433:	54                   	push   %esp
  801434:	5d                   	pop    %ebp
  801435:	8d 35 3d 14 80 00    	lea    0x80143d,%esi
  80143b:	0f 34                	sysenter 
  80143d:	5f                   	pop    %edi
  80143e:	5e                   	pop    %esi
  80143f:	5d                   	pop    %ebp
  801440:	5c                   	pop    %esp
  801441:	5b                   	pop    %ebx
  801442:	5a                   	pop    %edx
  801443:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801444:	85 c0                	test   %eax,%eax
  801446:	7e 28                	jle    801470 <sys_page_unmap+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  801448:	89 44 24 10          	mov    %eax,0x10(%esp)
  80144c:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801453:	00 
  801454:	c7 44 24 08 e0 36 80 	movl   $0x8036e0,0x8(%esp)
  80145b:	00 
  80145c:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801463:	00 
  801464:	c7 04 24 fd 36 80 00 	movl   $0x8036fd,(%esp)
  80146b:	e8 5c ed ff ff       	call   8001cc <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801470:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801473:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801476:	89 ec                	mov    %ebp,%esp
  801478:	5d                   	pop    %ebp
  801479:	c3                   	ret    

0080147a <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80147a:	55                   	push   %ebp
  80147b:	89 e5                	mov    %esp,%ebp
  80147d:	83 ec 28             	sub    $0x28,%esp
  801480:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801483:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801486:	8b 7d 18             	mov    0x18(%ebp),%edi
  801489:	0b 7d 14             	or     0x14(%ebp),%edi
  80148c:	b8 06 00 00 00       	mov    $0x6,%eax
  801491:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801494:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801497:	8b 55 08             	mov    0x8(%ebp),%edx
  80149a:	51                   	push   %ecx
  80149b:	52                   	push   %edx
  80149c:	53                   	push   %ebx
  80149d:	54                   	push   %esp
  80149e:	55                   	push   %ebp
  80149f:	56                   	push   %esi
  8014a0:	57                   	push   %edi
  8014a1:	54                   	push   %esp
  8014a2:	5d                   	pop    %ebp
  8014a3:	8d 35 ab 14 80 00    	lea    0x8014ab,%esi
  8014a9:	0f 34                	sysenter 
  8014ab:	5f                   	pop    %edi
  8014ac:	5e                   	pop    %esi
  8014ad:	5d                   	pop    %ebp
  8014ae:	5c                   	pop    %esp
  8014af:	5b                   	pop    %ebx
  8014b0:	5a                   	pop    %edx
  8014b1:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8014b2:	85 c0                	test   %eax,%eax
  8014b4:	7e 28                	jle    8014de <sys_page_map+0x64>
		panic("syscall %d returned %d (> 0)", num, ret);
  8014b6:	89 44 24 10          	mov    %eax,0x10(%esp)
  8014ba:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  8014c1:	00 
  8014c2:	c7 44 24 08 e0 36 80 	movl   $0x8036e0,0x8(%esp)
  8014c9:	00 
  8014ca:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8014d1:	00 
  8014d2:	c7 04 24 fd 36 80 00 	movl   $0x8036fd,(%esp)
  8014d9:	e8 ee ec ff ff       	call   8001cc <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}
  8014de:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8014e1:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8014e4:	89 ec                	mov    %ebp,%esp
  8014e6:	5d                   	pop    %ebp
  8014e7:	c3                   	ret    

008014e8 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8014e8:	55                   	push   %ebp
  8014e9:	89 e5                	mov    %esp,%ebp
  8014eb:	83 ec 28             	sub    $0x28,%esp
  8014ee:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8014f1:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8014f4:	bf 00 00 00 00       	mov    $0x0,%edi
  8014f9:	b8 05 00 00 00       	mov    $0x5,%eax
  8014fe:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801501:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801504:	8b 55 08             	mov    0x8(%ebp),%edx
  801507:	51                   	push   %ecx
  801508:	52                   	push   %edx
  801509:	53                   	push   %ebx
  80150a:	54                   	push   %esp
  80150b:	55                   	push   %ebp
  80150c:	56                   	push   %esi
  80150d:	57                   	push   %edi
  80150e:	54                   	push   %esp
  80150f:	5d                   	pop    %ebp
  801510:	8d 35 18 15 80 00    	lea    0x801518,%esi
  801516:	0f 34                	sysenter 
  801518:	5f                   	pop    %edi
  801519:	5e                   	pop    %esi
  80151a:	5d                   	pop    %ebp
  80151b:	5c                   	pop    %esp
  80151c:	5b                   	pop    %ebx
  80151d:	5a                   	pop    %edx
  80151e:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80151f:	85 c0                	test   %eax,%eax
  801521:	7e 28                	jle    80154b <sys_page_alloc+0x63>
		panic("syscall %d returned %d (> 0)", num, ret);
  801523:	89 44 24 10          	mov    %eax,0x10(%esp)
  801527:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  80152e:	00 
  80152f:	c7 44 24 08 e0 36 80 	movl   $0x8036e0,0x8(%esp)
  801536:	00 
  801537:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80153e:	00 
  80153f:	c7 04 24 fd 36 80 00 	movl   $0x8036fd,(%esp)
  801546:	e8 81 ec ff ff       	call   8001cc <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80154b:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80154e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801551:	89 ec                	mov    %ebp,%esp
  801553:	5d                   	pop    %ebp
  801554:	c3                   	ret    

00801555 <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
{
  801555:	55                   	push   %ebp
  801556:	89 e5                	mov    %esp,%ebp
  801558:	83 ec 08             	sub    $0x8,%esp
  80155b:	89 1c 24             	mov    %ebx,(%esp)
  80155e:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801562:	ba 00 00 00 00       	mov    $0x0,%edx
  801567:	b8 0c 00 00 00       	mov    $0xc,%eax
  80156c:	89 d1                	mov    %edx,%ecx
  80156e:	89 d3                	mov    %edx,%ebx
  801570:	89 d7                	mov    %edx,%edi
  801572:	51                   	push   %ecx
  801573:	52                   	push   %edx
  801574:	53                   	push   %ebx
  801575:	54                   	push   %esp
  801576:	55                   	push   %ebp
  801577:	56                   	push   %esi
  801578:	57                   	push   %edi
  801579:	54                   	push   %esp
  80157a:	5d                   	pop    %ebp
  80157b:	8d 35 83 15 80 00    	lea    0x801583,%esi
  801581:	0f 34                	sysenter 
  801583:	5f                   	pop    %edi
  801584:	5e                   	pop    %esi
  801585:	5d                   	pop    %ebp
  801586:	5c                   	pop    %esp
  801587:	5b                   	pop    %ebx
  801588:	5a                   	pop    %edx
  801589:	59                   	pop    %ecx

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80158a:	8b 1c 24             	mov    (%esp),%ebx
  80158d:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801591:	89 ec                	mov    %ebp,%esp
  801593:	5d                   	pop    %ebp
  801594:	c3                   	ret    

00801595 <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
{
  801595:	55                   	push   %ebp
  801596:	89 e5                	mov    %esp,%ebp
  801598:	83 ec 08             	sub    $0x8,%esp
  80159b:	89 1c 24             	mov    %ebx,(%esp)
  80159e:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8015a2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015a7:	b8 04 00 00 00       	mov    $0x4,%eax
  8015ac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8015af:	8b 55 08             	mov    0x8(%ebp),%edx
  8015b2:	89 df                	mov    %ebx,%edi
  8015b4:	51                   	push   %ecx
  8015b5:	52                   	push   %edx
  8015b6:	53                   	push   %ebx
  8015b7:	54                   	push   %esp
  8015b8:	55                   	push   %ebp
  8015b9:	56                   	push   %esi
  8015ba:	57                   	push   %edi
  8015bb:	54                   	push   %esp
  8015bc:	5d                   	pop    %ebp
  8015bd:	8d 35 c5 15 80 00    	lea    0x8015c5,%esi
  8015c3:	0f 34                	sysenter 
  8015c5:	5f                   	pop    %edi
  8015c6:	5e                   	pop    %esi
  8015c7:	5d                   	pop    %ebp
  8015c8:	5c                   	pop    %esp
  8015c9:	5b                   	pop    %ebx
  8015ca:	5a                   	pop    %edx
  8015cb:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  8015cc:	8b 1c 24             	mov    (%esp),%ebx
  8015cf:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8015d3:	89 ec                	mov    %ebp,%esp
  8015d5:	5d                   	pop    %ebp
  8015d6:	c3                   	ret    

008015d7 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  8015d7:	55                   	push   %ebp
  8015d8:	89 e5                	mov    %esp,%ebp
  8015da:	83 ec 08             	sub    $0x8,%esp
  8015dd:	89 1c 24             	mov    %ebx,(%esp)
  8015e0:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8015e4:	ba 00 00 00 00       	mov    $0x0,%edx
  8015e9:	b8 02 00 00 00       	mov    $0x2,%eax
  8015ee:	89 d1                	mov    %edx,%ecx
  8015f0:	89 d3                	mov    %edx,%ebx
  8015f2:	89 d7                	mov    %edx,%edi
  8015f4:	51                   	push   %ecx
  8015f5:	52                   	push   %edx
  8015f6:	53                   	push   %ebx
  8015f7:	54                   	push   %esp
  8015f8:	55                   	push   %ebp
  8015f9:	56                   	push   %esi
  8015fa:	57                   	push   %edi
  8015fb:	54                   	push   %esp
  8015fc:	5d                   	pop    %ebp
  8015fd:	8d 35 05 16 80 00    	lea    0x801605,%esi
  801603:	0f 34                	sysenter 
  801605:	5f                   	pop    %edi
  801606:	5e                   	pop    %esi
  801607:	5d                   	pop    %ebp
  801608:	5c                   	pop    %esp
  801609:	5b                   	pop    %ebx
  80160a:	5a                   	pop    %edx
  80160b:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80160c:	8b 1c 24             	mov    (%esp),%ebx
  80160f:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801613:	89 ec                	mov    %ebp,%esp
  801615:	5d                   	pop    %ebp
  801616:	c3                   	ret    

00801617 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  801617:	55                   	push   %ebp
  801618:	89 e5                	mov    %esp,%ebp
  80161a:	83 ec 28             	sub    $0x28,%esp
  80161d:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801620:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801623:	b9 00 00 00 00       	mov    $0x0,%ecx
  801628:	b8 03 00 00 00       	mov    $0x3,%eax
  80162d:	8b 55 08             	mov    0x8(%ebp),%edx
  801630:	89 cb                	mov    %ecx,%ebx
  801632:	89 cf                	mov    %ecx,%edi
  801634:	51                   	push   %ecx
  801635:	52                   	push   %edx
  801636:	53                   	push   %ebx
  801637:	54                   	push   %esp
  801638:	55                   	push   %ebp
  801639:	56                   	push   %esi
  80163a:	57                   	push   %edi
  80163b:	54                   	push   %esp
  80163c:	5d                   	pop    %ebp
  80163d:	8d 35 45 16 80 00    	lea    0x801645,%esi
  801643:	0f 34                	sysenter 
  801645:	5f                   	pop    %edi
  801646:	5e                   	pop    %esi
  801647:	5d                   	pop    %ebp
  801648:	5c                   	pop    %esp
  801649:	5b                   	pop    %ebx
  80164a:	5a                   	pop    %edx
  80164b:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80164c:	85 c0                	test   %eax,%eax
  80164e:	7e 28                	jle    801678 <sys_env_destroy+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  801650:	89 44 24 10          	mov    %eax,0x10(%esp)
  801654:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  80165b:	00 
  80165c:	c7 44 24 08 e0 36 80 	movl   $0x8036e0,0x8(%esp)
  801663:	00 
  801664:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80166b:	00 
  80166c:	c7 04 24 fd 36 80 00 	movl   $0x8036fd,(%esp)
  801673:	e8 54 eb ff ff       	call   8001cc <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801678:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80167b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80167e:	89 ec                	mov    %ebp,%esp
  801680:	5d                   	pop    %ebp
  801681:	c3                   	ret    
	...

00801690 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801690:	55                   	push   %ebp
  801691:	89 e5                	mov    %esp,%ebp
  801693:	8b 45 08             	mov    0x8(%ebp),%eax
  801696:	05 00 00 00 30       	add    $0x30000000,%eax
  80169b:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  80169e:	5d                   	pop    %ebp
  80169f:	c3                   	ret    

008016a0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8016a0:	55                   	push   %ebp
  8016a1:	89 e5                	mov    %esp,%ebp
  8016a3:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  8016a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8016a9:	89 04 24             	mov    %eax,(%esp)
  8016ac:	e8 df ff ff ff       	call   801690 <fd2num>
  8016b1:	05 20 00 0d 00       	add    $0xd0020,%eax
  8016b6:	c1 e0 0c             	shl    $0xc,%eax
}
  8016b9:	c9                   	leave  
  8016ba:	c3                   	ret    

008016bb <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8016bb:	55                   	push   %ebp
  8016bc:	89 e5                	mov    %esp,%ebp
  8016be:	57                   	push   %edi
  8016bf:	56                   	push   %esi
  8016c0:	53                   	push   %ebx
  8016c1:	8b 7d 08             	mov    0x8(%ebp),%edi
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  8016c4:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  8016c9:	a8 01                	test   $0x1,%al
  8016cb:	74 36                	je     801703 <fd_alloc+0x48>
  8016cd:	a1 00 00 74 ef       	mov    0xef740000,%eax
  8016d2:	a8 01                	test   $0x1,%al
  8016d4:	74 2d                	je     801703 <fd_alloc+0x48>
  8016d6:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  8016db:	b9 00 d0 7b ef       	mov    $0xef7bd000,%ecx
  8016e0:	be 00 00 40 ef       	mov    $0xef400000,%esi
  8016e5:	89 c3                	mov    %eax,%ebx
  8016e7:	89 c2                	mov    %eax,%edx
  8016e9:	c1 ea 16             	shr    $0x16,%edx
  8016ec:	8b 14 91             	mov    (%ecx,%edx,4),%edx
  8016ef:	f6 c2 01             	test   $0x1,%dl
  8016f2:	74 14                	je     801708 <fd_alloc+0x4d>
  8016f4:	89 c2                	mov    %eax,%edx
  8016f6:	c1 ea 0c             	shr    $0xc,%edx
  8016f9:	8b 14 96             	mov    (%esi,%edx,4),%edx
  8016fc:	f6 c2 01             	test   $0x1,%dl
  8016ff:	75 10                	jne    801711 <fd_alloc+0x56>
  801701:	eb 05                	jmp    801708 <fd_alloc+0x4d>
  801703:	bb 00 00 00 d0       	mov    $0xd0000000,%ebx
			*fd_store = fd;
  801708:	89 1f                	mov    %ebx,(%edi)
  80170a:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  80170f:	eb 17                	jmp    801728 <fd_alloc+0x6d>
  801711:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801716:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80171b:	75 c8                	jne    8016e5 <fd_alloc+0x2a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80171d:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  801723:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  801728:	5b                   	pop    %ebx
  801729:	5e                   	pop    %esi
  80172a:	5f                   	pop    %edi
  80172b:	5d                   	pop    %ebp
  80172c:	c3                   	ret    

0080172d <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80172d:	55                   	push   %ebp
  80172e:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801730:	8b 45 08             	mov    0x8(%ebp),%eax
  801733:	83 f8 1f             	cmp    $0x1f,%eax
  801736:	77 36                	ja     80176e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801738:	05 00 00 0d 00       	add    $0xd0000,%eax
  80173d:	c1 e0 0c             	shl    $0xc,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
  801740:	89 c2                	mov    %eax,%edx
  801742:	c1 ea 16             	shr    $0x16,%edx
  801745:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80174c:	f6 c2 01             	test   $0x1,%dl
  80174f:	74 1d                	je     80176e <fd_lookup+0x41>
  801751:	89 c2                	mov    %eax,%edx
  801753:	c1 ea 0c             	shr    $0xc,%edx
  801756:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80175d:	f6 c2 01             	test   $0x1,%dl
  801760:	74 0c                	je     80176e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  801762:	8b 55 0c             	mov    0xc(%ebp),%edx
  801765:	89 02                	mov    %eax,(%edx)
  801767:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
  80176c:	eb 05                	jmp    801773 <fd_lookup+0x46>
  80176e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801773:	5d                   	pop    %ebp
  801774:	c3                   	ret    

00801775 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  801775:	55                   	push   %ebp
  801776:	89 e5                	mov    %esp,%ebp
  801778:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80177b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80177e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801782:	8b 45 08             	mov    0x8(%ebp),%eax
  801785:	89 04 24             	mov    %eax,(%esp)
  801788:	e8 a0 ff ff ff       	call   80172d <fd_lookup>
  80178d:	85 c0                	test   %eax,%eax
  80178f:	78 0e                	js     80179f <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801791:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801794:	8b 55 0c             	mov    0xc(%ebp),%edx
  801797:	89 50 04             	mov    %edx,0x4(%eax)
  80179a:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  80179f:	c9                   	leave  
  8017a0:	c3                   	ret    

008017a1 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8017a1:	55                   	push   %ebp
  8017a2:	89 e5                	mov    %esp,%ebp
  8017a4:	56                   	push   %esi
  8017a5:	53                   	push   %ebx
  8017a6:	83 ec 10             	sub    $0x10,%esp
  8017a9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017ac:	8b 5d 0c             	mov    0xc(%ebp),%ebx
// File functions
// --------------------------------------------------------------

static struct Dev *devtab[] =
{
	&devfile,
  8017af:	b8 04 40 80 00       	mov    $0x804004,%eax
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  8017b4:	ba 00 00 00 00       	mov    $0x0,%edx

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8017b9:	be 88 37 80 00       	mov    $0x803788,%esi
		if (devtab[i]->dev_id == dev_id) {
  8017be:	39 08                	cmp    %ecx,(%eax)
  8017c0:	75 10                	jne    8017d2 <dev_lookup+0x31>
  8017c2:	eb 04                	jmp    8017c8 <dev_lookup+0x27>
  8017c4:	39 08                	cmp    %ecx,(%eax)
  8017c6:	75 0a                	jne    8017d2 <dev_lookup+0x31>
			*dev = devtab[i];
  8017c8:	89 03                	mov    %eax,(%ebx)
  8017ca:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  8017cf:	90                   	nop
  8017d0:	eb 31                	jmp    801803 <dev_lookup+0x62>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8017d2:	83 c2 01             	add    $0x1,%edx
  8017d5:	8b 04 96             	mov    (%esi,%edx,4),%eax
  8017d8:	85 c0                	test   %eax,%eax
  8017da:	75 e8                	jne    8017c4 <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8017dc:	a1 08 50 80 00       	mov    0x805008,%eax
  8017e1:	8b 40 48             	mov    0x48(%eax),%eax
  8017e4:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8017e8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017ec:	c7 04 24 0c 37 80 00 	movl   $0x80370c,(%esp)
  8017f3:	e8 8d ea ff ff       	call   800285 <cprintf>
	*dev = 0;
  8017f8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8017fe:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  801803:	83 c4 10             	add    $0x10,%esp
  801806:	5b                   	pop    %ebx
  801807:	5e                   	pop    %esi
  801808:	5d                   	pop    %ebp
  801809:	c3                   	ret    

0080180a <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  80180a:	55                   	push   %ebp
  80180b:	89 e5                	mov    %esp,%ebp
  80180d:	53                   	push   %ebx
  80180e:	83 ec 24             	sub    $0x24,%esp
  801811:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801814:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801817:	89 44 24 04          	mov    %eax,0x4(%esp)
  80181b:	8b 45 08             	mov    0x8(%ebp),%eax
  80181e:	89 04 24             	mov    %eax,(%esp)
  801821:	e8 07 ff ff ff       	call   80172d <fd_lookup>
  801826:	85 c0                	test   %eax,%eax
  801828:	78 53                	js     80187d <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80182a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80182d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801831:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801834:	8b 00                	mov    (%eax),%eax
  801836:	89 04 24             	mov    %eax,(%esp)
  801839:	e8 63 ff ff ff       	call   8017a1 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80183e:	85 c0                	test   %eax,%eax
  801840:	78 3b                	js     80187d <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  801842:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801847:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80184a:	83 7a 14 00          	cmpl   $0x0,0x14(%edx)
  80184e:	74 2d                	je     80187d <fstat+0x73>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801850:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801853:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80185a:	00 00 00 
	stat->st_isdir = 0;
  80185d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801864:	00 00 00 
	stat->st_dev = dev;
  801867:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80186a:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801870:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801874:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801877:	89 14 24             	mov    %edx,(%esp)
  80187a:	ff 50 14             	call   *0x14(%eax)
}
  80187d:	83 c4 24             	add    $0x24,%esp
  801880:	5b                   	pop    %ebx
  801881:	5d                   	pop    %ebp
  801882:	c3                   	ret    

00801883 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  801883:	55                   	push   %ebp
  801884:	89 e5                	mov    %esp,%ebp
  801886:	53                   	push   %ebx
  801887:	83 ec 24             	sub    $0x24,%esp
  80188a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80188d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801890:	89 44 24 04          	mov    %eax,0x4(%esp)
  801894:	89 1c 24             	mov    %ebx,(%esp)
  801897:	e8 91 fe ff ff       	call   80172d <fd_lookup>
  80189c:	85 c0                	test   %eax,%eax
  80189e:	78 5f                	js     8018ff <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018a0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018a3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018aa:	8b 00                	mov    (%eax),%eax
  8018ac:	89 04 24             	mov    %eax,(%esp)
  8018af:	e8 ed fe ff ff       	call   8017a1 <dev_lookup>
ftruncate(int fdnum, off_t newsize)
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018b4:	85 c0                	test   %eax,%eax
  8018b6:	78 47                	js     8018ff <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8018b8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8018bb:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  8018bf:	75 23                	jne    8018e4 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8018c1:	a1 08 50 80 00       	mov    0x805008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8018c6:	8b 40 48             	mov    0x48(%eax),%eax
  8018c9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8018cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018d1:	c7 04 24 2c 37 80 00 	movl   $0x80372c,(%esp)
  8018d8:	e8 a8 e9 ff ff       	call   800285 <cprintf>
  8018dd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8018e2:	eb 1b                	jmp    8018ff <ftruncate+0x7c>
	}
	if (!dev->dev_trunc)
  8018e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018e7:	8b 48 18             	mov    0x18(%eax),%ecx
  8018ea:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8018ef:	85 c9                	test   %ecx,%ecx
  8018f1:	74 0c                	je     8018ff <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8018f3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018f6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018fa:	89 14 24             	mov    %edx,(%esp)
  8018fd:	ff d1                	call   *%ecx
}
  8018ff:	83 c4 24             	add    $0x24,%esp
  801902:	5b                   	pop    %ebx
  801903:	5d                   	pop    %ebp
  801904:	c3                   	ret    

00801905 <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801905:	55                   	push   %ebp
  801906:	89 e5                	mov    %esp,%ebp
  801908:	53                   	push   %ebx
  801909:	83 ec 24             	sub    $0x24,%esp
  80190c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80190f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801912:	89 44 24 04          	mov    %eax,0x4(%esp)
  801916:	89 1c 24             	mov    %ebx,(%esp)
  801919:	e8 0f fe ff ff       	call   80172d <fd_lookup>
  80191e:	85 c0                	test   %eax,%eax
  801920:	78 66                	js     801988 <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801922:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801925:	89 44 24 04          	mov    %eax,0x4(%esp)
  801929:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80192c:	8b 00                	mov    (%eax),%eax
  80192e:	89 04 24             	mov    %eax,(%esp)
  801931:	e8 6b fe ff ff       	call   8017a1 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801936:	85 c0                	test   %eax,%eax
  801938:	78 4e                	js     801988 <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80193a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80193d:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  801941:	75 23                	jne    801966 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801943:	a1 08 50 80 00       	mov    0x805008,%eax
  801948:	8b 40 48             	mov    0x48(%eax),%eax
  80194b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80194f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801953:	c7 04 24 4d 37 80 00 	movl   $0x80374d,(%esp)
  80195a:	e8 26 e9 ff ff       	call   800285 <cprintf>
  80195f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801964:	eb 22                	jmp    801988 <write+0x83>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801966:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801969:	8b 48 0c             	mov    0xc(%eax),%ecx
  80196c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801971:	85 c9                	test   %ecx,%ecx
  801973:	74 13                	je     801988 <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801975:	8b 45 10             	mov    0x10(%ebp),%eax
  801978:	89 44 24 08          	mov    %eax,0x8(%esp)
  80197c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80197f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801983:	89 14 24             	mov    %edx,(%esp)
  801986:	ff d1                	call   *%ecx
}
  801988:	83 c4 24             	add    $0x24,%esp
  80198b:	5b                   	pop    %ebx
  80198c:	5d                   	pop    %ebp
  80198d:	c3                   	ret    

0080198e <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80198e:	55                   	push   %ebp
  80198f:	89 e5                	mov    %esp,%ebp
  801991:	53                   	push   %ebx
  801992:	83 ec 24             	sub    $0x24,%esp
  801995:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801998:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80199b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80199f:	89 1c 24             	mov    %ebx,(%esp)
  8019a2:	e8 86 fd ff ff       	call   80172d <fd_lookup>
  8019a7:	85 c0                	test   %eax,%eax
  8019a9:	78 6b                	js     801a16 <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8019ab:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019ae:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019b5:	8b 00                	mov    (%eax),%eax
  8019b7:	89 04 24             	mov    %eax,(%esp)
  8019ba:	e8 e2 fd ff ff       	call   8017a1 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8019bf:	85 c0                	test   %eax,%eax
  8019c1:	78 53                	js     801a16 <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8019c3:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8019c6:	8b 42 08             	mov    0x8(%edx),%eax
  8019c9:	83 e0 03             	and    $0x3,%eax
  8019cc:	83 f8 01             	cmp    $0x1,%eax
  8019cf:	75 23                	jne    8019f4 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8019d1:	a1 08 50 80 00       	mov    0x805008,%eax
  8019d6:	8b 40 48             	mov    0x48(%eax),%eax
  8019d9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8019dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019e1:	c7 04 24 6a 37 80 00 	movl   $0x80376a,(%esp)
  8019e8:	e8 98 e8 ff ff       	call   800285 <cprintf>
  8019ed:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  8019f2:	eb 22                	jmp    801a16 <read+0x88>
	}
	if (!dev->dev_read)
  8019f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019f7:	8b 48 08             	mov    0x8(%eax),%ecx
  8019fa:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8019ff:	85 c9                	test   %ecx,%ecx
  801a01:	74 13                	je     801a16 <read+0x88>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801a03:	8b 45 10             	mov    0x10(%ebp),%eax
  801a06:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a0a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a0d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a11:	89 14 24             	mov    %edx,(%esp)
  801a14:	ff d1                	call   *%ecx
}
  801a16:	83 c4 24             	add    $0x24,%esp
  801a19:	5b                   	pop    %ebx
  801a1a:	5d                   	pop    %ebp
  801a1b:	c3                   	ret    

00801a1c <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801a1c:	55                   	push   %ebp
  801a1d:	89 e5                	mov    %esp,%ebp
  801a1f:	57                   	push   %edi
  801a20:	56                   	push   %esi
  801a21:	53                   	push   %ebx
  801a22:	83 ec 1c             	sub    $0x1c,%esp
  801a25:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a28:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801a2b:	ba 00 00 00 00       	mov    $0x0,%edx
  801a30:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a35:	b8 00 00 00 00       	mov    $0x0,%eax
  801a3a:	85 f6                	test   %esi,%esi
  801a3c:	74 29                	je     801a67 <readn+0x4b>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801a3e:	89 f0                	mov    %esi,%eax
  801a40:	29 d0                	sub    %edx,%eax
  801a42:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a46:	03 55 0c             	add    0xc(%ebp),%edx
  801a49:	89 54 24 04          	mov    %edx,0x4(%esp)
  801a4d:	89 3c 24             	mov    %edi,(%esp)
  801a50:	e8 39 ff ff ff       	call   80198e <read>
		if (m < 0)
  801a55:	85 c0                	test   %eax,%eax
  801a57:	78 0e                	js     801a67 <readn+0x4b>
			return m;
		if (m == 0)
  801a59:	85 c0                	test   %eax,%eax
  801a5b:	74 08                	je     801a65 <readn+0x49>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801a5d:	01 c3                	add    %eax,%ebx
  801a5f:	89 da                	mov    %ebx,%edx
  801a61:	39 f3                	cmp    %esi,%ebx
  801a63:	72 d9                	jb     801a3e <readn+0x22>
  801a65:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801a67:	83 c4 1c             	add    $0x1c,%esp
  801a6a:	5b                   	pop    %ebx
  801a6b:	5e                   	pop    %esi
  801a6c:	5f                   	pop    %edi
  801a6d:	5d                   	pop    %ebp
  801a6e:	c3                   	ret    

00801a6f <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801a6f:	55                   	push   %ebp
  801a70:	89 e5                	mov    %esp,%ebp
  801a72:	56                   	push   %esi
  801a73:	53                   	push   %ebx
  801a74:	83 ec 20             	sub    $0x20,%esp
  801a77:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801a7a:	89 34 24             	mov    %esi,(%esp)
  801a7d:	e8 0e fc ff ff       	call   801690 <fd2num>
  801a82:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801a85:	89 54 24 04          	mov    %edx,0x4(%esp)
  801a89:	89 04 24             	mov    %eax,(%esp)
  801a8c:	e8 9c fc ff ff       	call   80172d <fd_lookup>
  801a91:	89 c3                	mov    %eax,%ebx
  801a93:	85 c0                	test   %eax,%eax
  801a95:	78 05                	js     801a9c <fd_close+0x2d>
  801a97:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801a9a:	74 0c                	je     801aa8 <fd_close+0x39>
	    || fd != fd2)
		return (must_exist ? r : 0);
  801a9c:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  801aa0:	19 c0                	sbb    %eax,%eax
  801aa2:	f7 d0                	not    %eax
  801aa4:	21 c3                	and    %eax,%ebx
  801aa6:	eb 3d                	jmp    801ae5 <fd_close+0x76>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801aa8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801aab:	89 44 24 04          	mov    %eax,0x4(%esp)
  801aaf:	8b 06                	mov    (%esi),%eax
  801ab1:	89 04 24             	mov    %eax,(%esp)
  801ab4:	e8 e8 fc ff ff       	call   8017a1 <dev_lookup>
  801ab9:	89 c3                	mov    %eax,%ebx
  801abb:	85 c0                	test   %eax,%eax
  801abd:	78 16                	js     801ad5 <fd_close+0x66>
		if (dev->dev_close)
  801abf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ac2:	8b 40 10             	mov    0x10(%eax),%eax
  801ac5:	bb 00 00 00 00       	mov    $0x0,%ebx
  801aca:	85 c0                	test   %eax,%eax
  801acc:	74 07                	je     801ad5 <fd_close+0x66>
			r = (*dev->dev_close)(fd);
  801ace:	89 34 24             	mov    %esi,(%esp)
  801ad1:	ff d0                	call   *%eax
  801ad3:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801ad5:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ad9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ae0:	e8 29 f9 ff ff       	call   80140e <sys_page_unmap>
	return r;
}
  801ae5:	89 d8                	mov    %ebx,%eax
  801ae7:	83 c4 20             	add    $0x20,%esp
  801aea:	5b                   	pop    %ebx
  801aeb:	5e                   	pop    %esi
  801aec:	5d                   	pop    %ebp
  801aed:	c3                   	ret    

00801aee <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801aee:	55                   	push   %ebp
  801aef:	89 e5                	mov    %esp,%ebp
  801af1:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801af4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801af7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801afb:	8b 45 08             	mov    0x8(%ebp),%eax
  801afe:	89 04 24             	mov    %eax,(%esp)
  801b01:	e8 27 fc ff ff       	call   80172d <fd_lookup>
  801b06:	85 c0                	test   %eax,%eax
  801b08:	78 13                	js     801b1d <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801b0a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801b11:	00 
  801b12:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b15:	89 04 24             	mov    %eax,(%esp)
  801b18:	e8 52 ff ff ff       	call   801a6f <fd_close>
}
  801b1d:	c9                   	leave  
  801b1e:	c3                   	ret    

00801b1f <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  801b1f:	55                   	push   %ebp
  801b20:	89 e5                	mov    %esp,%ebp
  801b22:	83 ec 18             	sub    $0x18,%esp
  801b25:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801b28:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801b2b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801b32:	00 
  801b33:	8b 45 08             	mov    0x8(%ebp),%eax
  801b36:	89 04 24             	mov    %eax,(%esp)
  801b39:	e8 79 03 00 00       	call   801eb7 <open>
  801b3e:	89 c3                	mov    %eax,%ebx
  801b40:	85 c0                	test   %eax,%eax
  801b42:	78 1b                	js     801b5f <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  801b44:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b47:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b4b:	89 1c 24             	mov    %ebx,(%esp)
  801b4e:	e8 b7 fc ff ff       	call   80180a <fstat>
  801b53:	89 c6                	mov    %eax,%esi
	close(fd);
  801b55:	89 1c 24             	mov    %ebx,(%esp)
  801b58:	e8 91 ff ff ff       	call   801aee <close>
  801b5d:	89 f3                	mov    %esi,%ebx
	return r;
}
  801b5f:	89 d8                	mov    %ebx,%eax
  801b61:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801b64:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801b67:	89 ec                	mov    %ebp,%esp
  801b69:	5d                   	pop    %ebp
  801b6a:	c3                   	ret    

00801b6b <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  801b6b:	55                   	push   %ebp
  801b6c:	89 e5                	mov    %esp,%ebp
  801b6e:	53                   	push   %ebx
  801b6f:	83 ec 14             	sub    $0x14,%esp
  801b72:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  801b77:	89 1c 24             	mov    %ebx,(%esp)
  801b7a:	e8 6f ff ff ff       	call   801aee <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801b7f:	83 c3 01             	add    $0x1,%ebx
  801b82:	83 fb 20             	cmp    $0x20,%ebx
  801b85:	75 f0                	jne    801b77 <close_all+0xc>
		close(i);
}
  801b87:	83 c4 14             	add    $0x14,%esp
  801b8a:	5b                   	pop    %ebx
  801b8b:	5d                   	pop    %ebp
  801b8c:	c3                   	ret    

00801b8d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801b8d:	55                   	push   %ebp
  801b8e:	89 e5                	mov    %esp,%ebp
  801b90:	83 ec 58             	sub    $0x58,%esp
  801b93:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801b96:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801b99:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801b9c:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801b9f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801ba2:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ba6:	8b 45 08             	mov    0x8(%ebp),%eax
  801ba9:	89 04 24             	mov    %eax,(%esp)
  801bac:	e8 7c fb ff ff       	call   80172d <fd_lookup>
  801bb1:	89 c3                	mov    %eax,%ebx
  801bb3:	85 c0                	test   %eax,%eax
  801bb5:	0f 88 e0 00 00 00    	js     801c9b <dup+0x10e>
		return r;
	close(newfdnum);
  801bbb:	89 3c 24             	mov    %edi,(%esp)
  801bbe:	e8 2b ff ff ff       	call   801aee <close>

	newfd = INDEX2FD(newfdnum);
  801bc3:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801bc9:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801bcc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801bcf:	89 04 24             	mov    %eax,(%esp)
  801bd2:	e8 c9 fa ff ff       	call   8016a0 <fd2data>
  801bd7:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801bd9:	89 34 24             	mov    %esi,(%esp)
  801bdc:	e8 bf fa ff ff       	call   8016a0 <fd2data>
  801be1:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
  801be4:	89 da                	mov    %ebx,%edx
  801be6:	89 d8                	mov    %ebx,%eax
  801be8:	c1 e8 16             	shr    $0x16,%eax
  801beb:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801bf2:	a8 01                	test   $0x1,%al
  801bf4:	74 43                	je     801c39 <dup+0xac>
  801bf6:	c1 ea 0c             	shr    $0xc,%edx
  801bf9:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801c00:	a8 01                	test   $0x1,%al
  801c02:	74 35                	je     801c39 <dup+0xac>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801c04:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801c0b:	25 07 0e 00 00       	and    $0xe07,%eax
  801c10:	89 44 24 10          	mov    %eax,0x10(%esp)
  801c14:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801c17:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c1b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801c22:	00 
  801c23:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c27:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c2e:	e8 47 f8 ff ff       	call   80147a <sys_page_map>
  801c33:	89 c3                	mov    %eax,%ebx
  801c35:	85 c0                	test   %eax,%eax
  801c37:	78 3f                	js     801c78 <dup+0xeb>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801c39:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c3c:	89 c2                	mov    %eax,%edx
  801c3e:	c1 ea 0c             	shr    $0xc,%edx
  801c41:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801c48:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801c4e:	89 54 24 10          	mov    %edx,0x10(%esp)
  801c52:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801c56:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801c5d:	00 
  801c5e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c62:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c69:	e8 0c f8 ff ff       	call   80147a <sys_page_map>
  801c6e:	89 c3                	mov    %eax,%ebx
  801c70:	85 c0                	test   %eax,%eax
  801c72:	78 04                	js     801c78 <dup+0xeb>
  801c74:	89 fb                	mov    %edi,%ebx
  801c76:	eb 23                	jmp    801c9b <dup+0x10e>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801c78:	89 74 24 04          	mov    %esi,0x4(%esp)
  801c7c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c83:	e8 86 f7 ff ff       	call   80140e <sys_page_unmap>
	sys_page_unmap(0, nva);
  801c88:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801c8b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c8f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c96:	e8 73 f7 ff ff       	call   80140e <sys_page_unmap>
	return r;
}
  801c9b:	89 d8                	mov    %ebx,%eax
  801c9d:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801ca0:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801ca3:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801ca6:	89 ec                	mov    %ebp,%esp
  801ca8:	5d                   	pop    %ebp
  801ca9:	c3                   	ret    
	...

00801cac <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801cac:	55                   	push   %ebp
  801cad:	89 e5                	mov    %esp,%ebp
  801caf:	83 ec 18             	sub    $0x18,%esp
  801cb2:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801cb5:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801cb8:	89 c3                	mov    %eax,%ebx
  801cba:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801cbc:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  801cc3:	75 11                	jne    801cd6 <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801cc5:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801ccc:	e8 8f 11 00 00       	call   802e60 <ipc_find_env>
  801cd1:	a3 00 50 80 00       	mov    %eax,0x805000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801cd6:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801cdd:	00 
  801cde:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  801ce5:	00 
  801ce6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801cea:	a1 00 50 80 00       	mov    0x805000,%eax
  801cef:	89 04 24             	mov    %eax,(%esp)
  801cf2:	e8 b4 11 00 00       	call   802eab <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801cf7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801cfe:	00 
  801cff:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d03:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d0a:	e8 1a 12 00 00       	call   802f29 <ipc_recv>
}
  801d0f:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801d12:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801d15:	89 ec                	mov    %ebp,%esp
  801d17:	5d                   	pop    %ebp
  801d18:	c3                   	ret    

00801d19 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801d19:	55                   	push   %ebp
  801d1a:	89 e5                	mov    %esp,%ebp
  801d1c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801d1f:	8b 45 08             	mov    0x8(%ebp),%eax
  801d22:	8b 40 0c             	mov    0xc(%eax),%eax
  801d25:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  801d2a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d2d:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801d32:	ba 00 00 00 00       	mov    $0x0,%edx
  801d37:	b8 02 00 00 00       	mov    $0x2,%eax
  801d3c:	e8 6b ff ff ff       	call   801cac <fsipc>
}
  801d41:	c9                   	leave  
  801d42:	c3                   	ret    

00801d43 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801d43:	55                   	push   %ebp
  801d44:	89 e5                	mov    %esp,%ebp
  801d46:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801d49:	8b 45 08             	mov    0x8(%ebp),%eax
  801d4c:	8b 40 0c             	mov    0xc(%eax),%eax
  801d4f:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801d54:	ba 00 00 00 00       	mov    $0x0,%edx
  801d59:	b8 06 00 00 00       	mov    $0x6,%eax
  801d5e:	e8 49 ff ff ff       	call   801cac <fsipc>
}
  801d63:	c9                   	leave  
  801d64:	c3                   	ret    

00801d65 <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  801d65:	55                   	push   %ebp
  801d66:	89 e5                	mov    %esp,%ebp
  801d68:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801d6b:	ba 00 00 00 00       	mov    $0x0,%edx
  801d70:	b8 08 00 00 00       	mov    $0x8,%eax
  801d75:	e8 32 ff ff ff       	call   801cac <fsipc>
}
  801d7a:	c9                   	leave  
  801d7b:	c3                   	ret    

00801d7c <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801d7c:	55                   	push   %ebp
  801d7d:	89 e5                	mov    %esp,%ebp
  801d7f:	53                   	push   %ebx
  801d80:	83 ec 14             	sub    $0x14,%esp
  801d83:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801d86:	8b 45 08             	mov    0x8(%ebp),%eax
  801d89:	8b 40 0c             	mov    0xc(%eax),%eax
  801d8c:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801d91:	ba 00 00 00 00       	mov    $0x0,%edx
  801d96:	b8 05 00 00 00       	mov    $0x5,%eax
  801d9b:	e8 0c ff ff ff       	call   801cac <fsipc>
  801da0:	85 c0                	test   %eax,%eax
  801da2:	78 2b                	js     801dcf <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801da4:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801dab:	00 
  801dac:	89 1c 24             	mov    %ebx,(%esp)
  801daf:	e8 06 ee ff ff       	call   800bba <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801db4:	a1 80 60 80 00       	mov    0x806080,%eax
  801db9:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801dbf:	a1 84 60 80 00       	mov    0x806084,%eax
  801dc4:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  801dca:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  801dcf:	83 c4 14             	add    $0x14,%esp
  801dd2:	5b                   	pop    %ebx
  801dd3:	5d                   	pop    %ebp
  801dd4:	c3                   	ret    

00801dd5 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801dd5:	55                   	push   %ebp
  801dd6:	89 e5                	mov    %esp,%ebp
  801dd8:	83 ec 18             	sub    $0x18,%esp
  801ddb:	8b 45 10             	mov    0x10(%ebp),%eax
  801dde:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801de3:	76 05                	jbe    801dea <devfile_write+0x15>
  801de5:	b8 f8 0f 00 00       	mov    $0xff8,%eax
	// bytes than requested.
	// LAB 5: Your code here
        int r;
        if(n > sizeof(fsipcbuf.write.req_buf))
            n = sizeof(fsipcbuf.write.req_buf);
        fsipcbuf.write.req_fileid = fd->fd_file.id;
  801dea:	8b 55 08             	mov    0x8(%ebp),%edx
  801ded:	8b 52 0c             	mov    0xc(%edx),%edx
  801df0:	89 15 00 60 80 00    	mov    %edx,0x806000
        fsipcbuf.write.req_n = n;
  801df6:	a3 04 60 80 00       	mov    %eax,0x806004
        memmove(fsipcbuf.write.req_buf,buf,n);  
  801dfb:	89 44 24 08          	mov    %eax,0x8(%esp)
  801dff:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e02:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e06:	c7 04 24 08 60 80 00 	movl   $0x806008,(%esp)
  801e0d:	e8 93 ef ff ff       	call   800da5 <memmove>
        r = fsipc(FSREQ_WRITE,NULL);
  801e12:	ba 00 00 00 00       	mov    $0x0,%edx
  801e17:	b8 04 00 00 00       	mov    $0x4,%eax
  801e1c:	e8 8b fe ff ff       	call   801cac <fsipc>
        return r;
	//panic("devfile_write not implemented");
}
  801e21:	c9                   	leave  
  801e22:	c3                   	ret    

00801e23 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801e23:	55                   	push   %ebp
  801e24:	89 e5                	mov    %esp,%ebp
  801e26:	53                   	push   %ebx
  801e27:	83 ec 14             	sub    $0x14,%esp
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
        int r;
        fsipcbuf.read.req_fileid = fd->fd_file.id;
  801e2a:	8b 45 08             	mov    0x8(%ebp),%eax
  801e2d:	8b 40 0c             	mov    0xc(%eax),%eax
  801e30:	a3 00 60 80 00       	mov    %eax,0x806000
        fsipcbuf.read.req_n = n;
  801e35:	8b 45 10             	mov    0x10(%ebp),%eax
  801e38:	a3 04 60 80 00       	mov    %eax,0x806004
        r = fsipc(FSREQ_READ,NULL);
  801e3d:	ba 00 00 00 00       	mov    $0x0,%edx
  801e42:	b8 03 00 00 00       	mov    $0x3,%eax
  801e47:	e8 60 fe ff ff       	call   801cac <fsipc>
  801e4c:	89 c3                	mov    %eax,%ebx
        if(r < 0)
  801e4e:	85 c0                	test   %eax,%eax
  801e50:	78 17                	js     801e69 <devfile_read+0x46>
           return r;
        memmove(buf,fsipcbuf.readRet.ret_buf,r);
  801e52:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e56:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801e5d:	00 
  801e5e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e61:	89 04 24             	mov    %eax,(%esp)
  801e64:	e8 3c ef ff ff       	call   800da5 <memmove>
        return r;
	//panic("devfile_read not implemented");
}
  801e69:	89 d8                	mov    %ebx,%eax
  801e6b:	83 c4 14             	add    $0x14,%esp
  801e6e:	5b                   	pop    %ebx
  801e6f:	5d                   	pop    %ebp
  801e70:	c3                   	ret    

00801e71 <remove>:
}

// Delete a file
int
remove(const char *path)
{
  801e71:	55                   	push   %ebp
  801e72:	89 e5                	mov    %esp,%ebp
  801e74:	53                   	push   %ebx
  801e75:	83 ec 14             	sub    $0x14,%esp
  801e78:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  801e7b:	89 1c 24             	mov    %ebx,(%esp)
  801e7e:	e8 ed ec ff ff       	call   800b70 <strlen>
  801e83:	89 c2                	mov    %eax,%edx
  801e85:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  801e8a:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
  801e90:	7f 1f                	jg     801eb1 <remove+0x40>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  801e92:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801e96:	c7 04 24 00 60 80 00 	movl   $0x806000,(%esp)
  801e9d:	e8 18 ed ff ff       	call   800bba <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  801ea2:	ba 00 00 00 00       	mov    $0x0,%edx
  801ea7:	b8 07 00 00 00       	mov    $0x7,%eax
  801eac:	e8 fb fd ff ff       	call   801cac <fsipc>
}
  801eb1:	83 c4 14             	add    $0x14,%esp
  801eb4:	5b                   	pop    %ebx
  801eb5:	5d                   	pop    %ebp
  801eb6:	c3                   	ret    

00801eb7 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801eb7:	55                   	push   %ebp
  801eb8:	89 e5                	mov    %esp,%ebp
  801eba:	83 ec 28             	sub    $0x28,%esp
  801ebd:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801ec0:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801ec3:	8b 75 08             	mov    0x8(%ebp),%esi
	// If any step after fd_alloc fails, use fd_close to free the
	// file descriptor.

	// LAB 5: Your code here.
        struct Fd* fd;
        if(strlen(path) > MAXPATHLEN)
  801ec6:	89 34 24             	mov    %esi,(%esp)
  801ec9:	e8 a2 ec ff ff       	call   800b70 <strlen>
  801ece:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801ed3:	3d 00 04 00 00       	cmp    $0x400,%eax
  801ed8:	7f 6d                	jg     801f47 <open+0x90>
            return -E_BAD_PATH;
        int r;
        r = fd_alloc(&fd);
  801eda:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801edd:	89 04 24             	mov    %eax,(%esp)
  801ee0:	e8 d6 f7 ff ff       	call   8016bb <fd_alloc>
  801ee5:	89 c3                	mov    %eax,%ebx
        if(r < 0)
  801ee7:	85 c0                	test   %eax,%eax
  801ee9:	78 5c                	js     801f47 <open+0x90>
           return r;
        fsipcbuf.open.req_omode = mode;
  801eeb:	8b 45 0c             	mov    0xc(%ebp),%eax
  801eee:	a3 00 64 80 00       	mov    %eax,0x806400
        memmove(fsipcbuf.open.req_path,path,strlen(path)+1);
  801ef3:	89 34 24             	mov    %esi,(%esp)
  801ef6:	e8 75 ec ff ff       	call   800b70 <strlen>
  801efb:	83 c0 01             	add    $0x1,%eax
  801efe:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f02:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f06:	c7 04 24 00 60 80 00 	movl   $0x806000,(%esp)
  801f0d:	e8 93 ee ff ff       	call   800da5 <memmove>
        r = fsipc(FSREQ_OPEN,(void*)fd);
  801f12:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801f15:	b8 01 00 00 00       	mov    $0x1,%eax
  801f1a:	e8 8d fd ff ff       	call   801cac <fsipc>
  801f1f:	89 c3                	mov    %eax,%ebx
        if(r < 0){
  801f21:	85 c0                	test   %eax,%eax
  801f23:	79 15                	jns    801f3a <open+0x83>
             fd_close(fd,0);
  801f25:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801f2c:	00 
  801f2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f30:	89 04 24             	mov    %eax,(%esp)
  801f33:	e8 37 fb ff ff       	call   801a6f <fd_close>
             return r;
  801f38:	eb 0d                	jmp    801f47 <open+0x90>
        }
        return fd2num(fd);
  801f3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f3d:	89 04 24             	mov    %eax,(%esp)
  801f40:	e8 4b f7 ff ff       	call   801690 <fd2num>
  801f45:	89 c3                	mov    %eax,%ebx
	//panic("open not implemented");
}
  801f47:	89 d8                	mov    %ebx,%eax
  801f49:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801f4c:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801f4f:	89 ec                	mov    %ebp,%esp
  801f51:	5d                   	pop    %ebp
  801f52:	c3                   	ret    
	...

00801f54 <map_segment>:
}

static int
map_segment(envid_t child, uintptr_t va, size_t memsz,
	int fd, size_t filesz, off_t fileoffset, int perm)
{
  801f54:	55                   	push   %ebp
  801f55:	89 e5                	mov    %esp,%ebp
  801f57:	57                   	push   %edi
  801f58:	56                   	push   %esi
  801f59:	53                   	push   %ebx
  801f5a:	83 ec 3c             	sub    $0x3c,%esp
  801f5d:	89 45 dc             	mov    %eax,-0x24(%ebp)
  801f60:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  801f63:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801f66:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801f69:	89 d0                	mov    %edx,%eax
  801f6b:	25 ff 0f 00 00       	and    $0xfff,%eax
  801f70:	74 0d                	je     801f7f <map_segment+0x2b>
		va -= i;
  801f72:	29 c2                	sub    %eax,%edx
  801f74:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		memsz += i;
  801f77:	01 45 e0             	add    %eax,-0x20(%ebp)
		filesz += i;
  801f7a:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  801f7c:	29 45 10             	sub    %eax,0x10(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801f7f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801f83:	0f 84 12 01 00 00    	je     80209b <map_segment+0x147>
  801f89:	be 00 00 00 00       	mov    $0x0,%esi
  801f8e:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (i >= filesz) {
  801f93:	39 f7                	cmp    %esi,%edi
  801f95:	77 26                	ja     801fbd <map_segment+0x69>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801f97:	8b 45 14             	mov    0x14(%ebp),%eax
  801f9a:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f9e:	03 75 e4             	add    -0x1c(%ebp),%esi
  801fa1:	89 74 24 04          	mov    %esi,0x4(%esp)
  801fa5:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801fa8:	89 14 24             	mov    %edx,(%esp)
  801fab:	e8 38 f5 ff ff       	call   8014e8 <sys_page_alloc>
  801fb0:	85 c0                	test   %eax,%eax
  801fb2:	0f 89 d2 00 00 00    	jns    80208a <map_segment+0x136>
  801fb8:	e9 e3 00 00 00       	jmp    8020a0 <map_segment+0x14c>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801fbd:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801fc4:	00 
  801fc5:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801fcc:	00 
  801fcd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801fd4:	e8 0f f5 ff ff       	call   8014e8 <sys_page_alloc>
  801fd9:	85 c0                	test   %eax,%eax
  801fdb:	0f 88 bf 00 00 00    	js     8020a0 <map_segment+0x14c>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801fe1:	8b 55 10             	mov    0x10(%ebp),%edx
  801fe4:	8d 04 13             	lea    (%ebx,%edx,1),%eax
  801fe7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801feb:	8b 45 08             	mov    0x8(%ebp),%eax
  801fee:	89 04 24             	mov    %eax,(%esp)
  801ff1:	e8 7f f7 ff ff       	call   801775 <seek>
  801ff6:	85 c0                	test   %eax,%eax
  801ff8:	0f 88 a2 00 00 00    	js     8020a0 <map_segment+0x14c>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801ffe:	89 f8                	mov    %edi,%eax
  802000:	29 f0                	sub    %esi,%eax
  802002:	3d 00 10 00 00       	cmp    $0x1000,%eax
  802007:	76 05                	jbe    80200e <map_segment+0xba>
  802009:	b8 00 10 00 00       	mov    $0x1000,%eax
  80200e:	89 44 24 08          	mov    %eax,0x8(%esp)
  802012:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  802019:	00 
  80201a:	8b 55 08             	mov    0x8(%ebp),%edx
  80201d:	89 14 24             	mov    %edx,(%esp)
  802020:	e8 f7 f9 ff ff       	call   801a1c <readn>
  802025:	85 c0                	test   %eax,%eax
  802027:	78 77                	js     8020a0 <map_segment+0x14c>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  802029:	8b 45 14             	mov    0x14(%ebp),%eax
  80202c:	89 44 24 10          	mov    %eax,0x10(%esp)
  802030:	03 75 e4             	add    -0x1c(%ebp),%esi
  802033:	89 74 24 0c          	mov    %esi,0xc(%esp)
  802037:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80203a:	89 54 24 08          	mov    %edx,0x8(%esp)
  80203e:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  802045:	00 
  802046:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80204d:	e8 28 f4 ff ff       	call   80147a <sys_page_map>
  802052:	85 c0                	test   %eax,%eax
  802054:	79 20                	jns    802076 <map_segment+0x122>
				panic("spawn: sys_page_map data: %e", r);
  802056:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80205a:	c7 44 24 08 94 37 80 	movl   $0x803794,0x8(%esp)
  802061:	00 
  802062:	c7 44 24 04 21 01 00 	movl   $0x121,0x4(%esp)
  802069:	00 
  80206a:	c7 04 24 b1 37 80 00 	movl   $0x8037b1,(%esp)
  802071:	e8 56 e1 ff ff       	call   8001cc <_panic>
			sys_page_unmap(0, UTEMP);
  802076:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  80207d:	00 
  80207e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802085:	e8 84 f3 ff ff       	call   80140e <sys_page_unmap>
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  80208a:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  802090:	89 de                	mov    %ebx,%esi
  802092:	39 5d e0             	cmp    %ebx,-0x20(%ebp)
  802095:	0f 87 f8 fe ff ff    	ja     801f93 <map_segment+0x3f>
  80209b:	b8 00 00 00 00       	mov    $0x0,%eax
				panic("spawn: sys_page_map data: %e", r);
			sys_page_unmap(0, UTEMP);
		}
	}
	return 0;
}
  8020a0:	83 c4 3c             	add    $0x3c,%esp
  8020a3:	5b                   	pop    %ebx
  8020a4:	5e                   	pop    %esi
  8020a5:	5f                   	pop    %edi
  8020a6:	5d                   	pop    %ebp
  8020a7:	c3                   	ret    

008020a8 <exec>:

int
exec(const char *prog, const char **argv)
{
  8020a8:	55                   	push   %ebp
  8020a9:	89 e5                	mov    %esp,%ebp
  8020ab:	57                   	push   %edi
  8020ac:	56                   	push   %esi
  8020ad:	53                   	push   %ebx
  8020ae:	81 ec 4c 02 00 00    	sub    $0x24c,%esp
        struct Proghdr *ph;
        int perm;
        uint32_t tf_esp;
        uint32_t tmp = FTEMP;

        if ((r = open(prog, O_RDONLY)) < 0){
  8020b4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8020bb:	00 
  8020bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8020bf:	89 04 24             	mov    %eax,(%esp)
  8020c2:	e8 f0 fd ff ff       	call   801eb7 <open>
  8020c7:	89 85 e4 fd ff ff    	mov    %eax,-0x21c(%ebp)
  8020cd:	89 c7                	mov    %eax,%edi
  8020cf:	85 c0                	test   %eax,%eax
  8020d1:	0f 88 69 03 00 00    	js     802440 <exec+0x398>
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
	    || elf->e_magic != ELF_MAGIC) {
  8020d7:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  8020de:	00 
  8020df:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  8020e5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020e9:	89 3c 24             	mov    %edi,(%esp)
  8020ec:	e8 2b f9 ff ff       	call   801a1c <readn>
        }
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  8020f1:	3d 00 02 00 00       	cmp    $0x200,%eax
  8020f6:	75 0c                	jne    802104 <exec+0x5c>
	    || elf->e_magic != ELF_MAGIC) {
  8020f8:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  8020ff:	45 4c 46 
  802102:	74 36                	je     80213a <exec+0x92>
		close(fd);
  802104:	8b 85 e4 fd ff ff    	mov    -0x21c(%ebp),%eax
  80210a:	89 04 24             	mov    %eax,(%esp)
  80210d:	e8 dc f9 ff ff       	call   801aee <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  802112:	c7 44 24 08 7f 45 4c 	movl   $0x464c457f,0x8(%esp)
  802119:	46 
  80211a:	8b 85 e8 fd ff ff    	mov    -0x218(%ebp),%eax
  802120:	89 44 24 04          	mov    %eax,0x4(%esp)
  802124:	c7 04 24 bd 37 80 00 	movl   $0x8037bd,(%esp)
  80212b:	e8 55 e1 ff ff       	call   800285 <cprintf>
  802130:	bf f2 ff ff ff       	mov    $0xfffffff2,%edi
		return -E_NOT_EXEC;
  802135:	e9 06 03 00 00       	jmp    802440 <exec+0x398>
	}

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  80213a:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  802140:	66 83 bd 14 fe ff ff 	cmpw   $0x0,-0x1ec(%ebp)
  802147:	00 
  802148:	0f 84 a5 00 00 00    	je     8021f3 <exec+0x14b>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
		return -E_NOT_EXEC;
	}

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  80214e:	8d 9c 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%ebx
  802155:	c7 85 e0 fd ff ff 00 	movl   $0xe0000000,-0x220(%ebp)
  80215c:	00 00 e0 
  80215f:	be 00 00 00 00       	mov    $0x0,%esi
  802164:	bf 00 00 00 e0       	mov    $0xe0000000,%edi
	for (i = 0; i < elf->e_phnum; i++, ph++) {
		if (ph->p_type != ELF_PROG_LOAD)
  802169:	83 3b 01             	cmpl   $0x1,(%ebx)
  80216c:	75 6f                	jne    8021dd <exec+0x135>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  80216e:	8b 43 18             	mov    0x18(%ebx),%eax
  802171:	83 e0 02             	and    $0x2,%eax
  802174:	83 f8 01             	cmp    $0x1,%eax
  802177:	19 c0                	sbb    %eax,%eax
  802179:	83 e0 fe             	and    $0xfffffffe,%eax
  80217c:	83 c0 07             	add    $0x7,%eax
			perm |= PTE_W;
		if ((r = map_segment(0, tmp + PGOFF(ph->p_va), ph->p_memsz,
  80217f:	8b 4b 14             	mov    0x14(%ebx),%ecx
  802182:	8b 53 08             	mov    0x8(%ebx),%edx
  802185:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
  80218b:	8d 14 17             	lea    (%edi,%edx,1),%edx
  80218e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802192:	8b 43 04             	mov    0x4(%ebx),%eax
  802195:	89 44 24 08          	mov    %eax,0x8(%esp)
  802199:	8b 43 10             	mov    0x10(%ebx),%eax
  80219c:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021a0:	8b 85 e4 fd ff ff    	mov    -0x21c(%ebp),%eax
  8021a6:	89 04 24             	mov    %eax,(%esp)
  8021a9:	b8 00 00 00 00       	mov    $0x0,%eax
  8021ae:	e8 a1 fd ff ff       	call   801f54 <map_segment>
  8021b3:	85 c0                	test   %eax,%eax
  8021b5:	79 0d                	jns    8021c4 <exec+0x11c>
  8021b7:	89 c7                	mov    %eax,%edi
  8021b9:	8b 9d e4 fd ff ff    	mov    -0x21c(%ebp),%ebx
  8021bf:	e9 68 02 00 00       	jmp    80242c <exec+0x384>
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
                tmp += ROUNDUP(PGOFF(ph->p_va) + ph->p_memsz, PGSIZE);
  8021c4:	8b 53 14             	mov    0x14(%ebx),%edx
  8021c7:	8b 43 08             	mov    0x8(%ebx),%eax
  8021ca:	25 ff 0f 00 00       	and    $0xfff,%eax
  8021cf:	8d 84 02 ff 0f 00 00 	lea    0xfff(%edx,%eax,1),%eax
  8021d6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8021db:	01 c7                	add    %eax,%edi
		return -E_NOT_EXEC;
	}

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  8021dd:	83 c6 01             	add    $0x1,%esi
  8021e0:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  8021e7:	39 f0                	cmp    %esi,%eax
  8021e9:	7e 14                	jle    8021ff <exec+0x157>
  8021eb:	83 c3 20             	add    $0x20,%ebx
  8021ee:	e9 76 ff ff ff       	jmp    802169 <exec+0xc1>
  8021f3:	c7 85 e0 fd ff ff 00 	movl   $0xe0000000,-0x220(%ebp)
  8021fa:	00 00 e0 
  8021fd:	eb 06                	jmp    802205 <exec+0x15d>
  8021ff:	89 bd e0 fd ff ff    	mov    %edi,-0x220(%ebp)
		if ((r = map_segment(0, tmp + PGOFF(ph->p_va), ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
                tmp += ROUNDUP(PGOFF(ph->p_va) + ph->p_memsz, PGSIZE);
	}
	close(fd);
  802205:	8b 95 e4 fd ff ff    	mov    -0x21c(%ebp),%edx
  80220b:	89 14 24             	mov    %edx,(%esp)
  80220e:	e8 db f8 ff ff       	call   801aee <close>
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  802213:	8b 55 0c             	mov    0xc(%ebp),%edx
  802216:	8b 02                	mov    (%edx),%eax
  802218:	be 00 00 00 00       	mov    $0x0,%esi
  80221d:	bb 00 00 00 00       	mov    $0x0,%ebx
  802222:	85 c0                	test   %eax,%eax
  802224:	75 16                	jne    80223c <exec+0x194>
  802226:	c7 85 d0 fd ff ff 00 	movl   $0x0,-0x230(%ebp)
  80222d:	00 00 00 
  802230:	c7 85 cc fd ff ff 00 	movl   $0x0,-0x234(%ebp)
  802237:	00 00 00 
  80223a:	eb 2c                	jmp    802268 <exec+0x1c0>
  80223c:	8b 7d 0c             	mov    0xc(%ebp),%edi
		string_size += strlen(argv[argc]) + 1;
  80223f:	89 04 24             	mov    %eax,(%esp)
  802242:	e8 29 e9 ff ff       	call   800b70 <strlen>
  802247:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  80224b:	83 c3 01             	add    $0x1,%ebx
  80224e:	8d 14 9d 00 00 00 00 	lea    0x0(,%ebx,4),%edx
  802255:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  802258:	85 c0                	test   %eax,%eax
  80225a:	75 e3                	jne    80223f <exec+0x197>
  80225c:	89 95 d0 fd ff ff    	mov    %edx,-0x230(%ebp)
  802262:	89 9d cc fd ff ff    	mov    %ebx,-0x234(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  802268:	f7 de                	neg    %esi
  80226a:	81 c6 00 10 40 00    	add    $0x401000,%esi
  802270:	89 b5 d8 fd ff ff    	mov    %esi,-0x228(%ebp)
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  802276:	89 f2                	mov    %esi,%edx
  802278:	83 e2 fc             	and    $0xfffffffc,%edx
  80227b:	89 d8                	mov    %ebx,%eax
  80227d:	f7 d0                	not    %eax
  80227f:	8d 04 82             	lea    (%edx,%eax,4),%eax
  802282:	89 85 e4 fd ff ff    	mov    %eax,-0x21c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  802288:	83 e8 08             	sub    $0x8,%eax
  80228b:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	return 0;

error:
	sys_env_destroy(0);
	close(fd);
	return r;
  802291:	bf fc ff ff ff       	mov    $0xfffffffc,%edi
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  802296:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  80229b:	0f 86 9f 01 00 00    	jbe    802440 <exec+0x398>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8022a1:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8022a8:	00 
  8022a9:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8022b0:	00 
  8022b1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8022b8:	e8 2b f2 ff ff       	call   8014e8 <sys_page_alloc>
  8022bd:	89 c7                	mov    %eax,%edi
  8022bf:	85 c0                	test   %eax,%eax
  8022c1:	0f 88 79 01 00 00    	js     802440 <exec+0x398>
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  8022c7:	85 db                	test   %ebx,%ebx
  8022c9:	7e 52                	jle    80231d <exec+0x275>
  8022cb:	be 00 00 00 00       	mov    $0x0,%esi
  8022d0:	89 9d dc fd ff ff    	mov    %ebx,-0x224(%ebp)
  8022d6:	8b bd d8 fd ff ff    	mov    -0x228(%ebp),%edi
  8022dc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
		argv_store[i] = UTEMP2USTACK(string_store);
  8022df:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  8022e5:	8b 95 e4 fd ff ff    	mov    -0x21c(%ebp),%edx
  8022eb:	89 04 b2             	mov    %eax,(%edx,%esi,4)
		strcpy(string_store, argv[i]);
  8022ee:	8b 04 b3             	mov    (%ebx,%esi,4),%eax
  8022f1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022f5:	89 3c 24             	mov    %edi,(%esp)
  8022f8:	e8 bd e8 ff ff       	call   800bba <strcpy>
		string_store += strlen(argv[i]) + 1;
  8022fd:	8b 04 b3             	mov    (%ebx,%esi,4),%eax
  802300:	89 04 24             	mov    %eax,(%esp)
  802303:	e8 68 e8 ff ff       	call   800b70 <strlen>
  802308:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  80230c:	83 c6 01             	add    $0x1,%esi
  80230f:	3b b5 dc fd ff ff    	cmp    -0x224(%ebp),%esi
  802315:	7c c8                	jl     8022df <exec+0x237>
  802317:	89 bd d8 fd ff ff    	mov    %edi,-0x228(%ebp)
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  80231d:	8b 95 e4 fd ff ff    	mov    -0x21c(%ebp),%edx
  802323:	8b 85 d0 fd ff ff    	mov    -0x230(%ebp),%eax
  802329:	c7 04 02 00 00 00 00 	movl   $0x0,(%edx,%eax,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  802330:	81 bd d8 fd ff ff 00 	cmpl   $0x401000,-0x228(%ebp)
  802337:	10 40 00 
  80233a:	74 24                	je     802360 <exec+0x2b8>
  80233c:	c7 44 24 0c 20 38 80 	movl   $0x803820,0xc(%esp)
  802343:	00 
  802344:	c7 44 24 08 d7 37 80 	movl   $0x8037d7,0x8(%esp)
  80234b:	00 
  80234c:	c7 44 24 04 97 01 00 	movl   $0x197,0x4(%esp)
  802353:	00 
  802354:	c7 04 24 b1 37 80 00 	movl   $0x8037b1,(%esp)
  80235b:	e8 6c de ff ff       	call   8001cc <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  802360:	8b 85 e4 fd ff ff    	mov    -0x21c(%ebp),%eax
  802366:	2d 00 30 80 11       	sub    $0x11803000,%eax
  80236b:	8b 95 e4 fd ff ff    	mov    -0x21c(%ebp),%edx
  802371:	89 42 fc             	mov    %eax,-0x4(%edx)
	argv_store[-2] = argc;
  802374:	8b 95 cc fd ff ff    	mov    -0x234(%ebp),%edx
  80237a:	8b 85 d4 fd ff ff    	mov    -0x22c(%ebp),%eax
  802380:	89 10                	mov    %edx,(%eax)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, envid, (void*) stack, PTE_P | PTE_U | PTE_W)) < 0)
  802382:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  802389:	00 
  80238a:	8b 85 e0 fd ff ff    	mov    -0x220(%ebp),%eax
  802390:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802394:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80239b:	00 
  80239c:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8023a3:	00 
  8023a4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8023ab:	e8 ca f0 ff ff       	call   80147a <sys_page_map>
  8023b0:	89 c7                	mov    %eax,%edi
  8023b2:	85 c0                	test   %eax,%eax
  8023b4:	78 1a                	js     8023d0 <exec+0x328>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  8023b6:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8023bd:	00 
  8023be:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8023c5:	e8 44 f0 ff ff       	call   80140e <sys_page_unmap>
  8023ca:	89 c7                	mov    %eax,%edi
  8023cc:	85 c0                	test   %eax,%eax
  8023ce:	79 16                	jns    8023e6 <exec+0x33e>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  8023d0:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8023d7:	00 
  8023d8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8023df:	e8 2a f0 ff ff       	call   80140e <sys_page_unmap>
  8023e4:	eb 5a                	jmp    802440 <exec+0x398>
	close(fd);
	fd = -1;
        if ((r = init_stack_2(0, argv, &tf_esp,tmp)) < 0)
		return r;

	if (sys_exec((void*)(elf_buf + elf->e_phoff), elf->e_phnum, tf_esp, elf->e_entry) < 0)
  8023e6:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  8023ec:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8023f0:	8b 85 e4 fd ff ff    	mov    -0x21c(%ebp),%eax
  8023f6:	2d 08 30 80 11       	sub    $0x11803008,%eax
  8023fb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8023ff:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  802406:	89 44 24 04          	mov    %eax,0x4(%esp)
  80240a:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  802410:	03 85 04 fe ff ff    	add    -0x1fc(%ebp),%eax
  802416:	89 04 24             	mov    %eax,(%esp)
  802419:	e8 d2 ec ff ff       	call   8010f0 <sys_exec>
  80241e:	bf 00 00 00 00       	mov    $0x0,%edi
  802423:	85 c0                	test   %eax,%eax
  802425:	79 19                	jns    802440 <exec+0x398>
  802427:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
		goto error;
	return 0;

error:
	sys_env_destroy(0);
  80242c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802433:	e8 df f1 ff ff       	call   801617 <sys_env_destroy>
	close(fd);
  802438:	89 1c 24             	mov    %ebx,(%esp)
  80243b:	e8 ae f6 ff ff       	call   801aee <close>
	return r;
}
  802440:	89 f8                	mov    %edi,%eax
  802442:	81 c4 4c 02 00 00    	add    $0x24c,%esp
  802448:	5b                   	pop    %ebx
  802449:	5e                   	pop    %esi
  80244a:	5f                   	pop    %edi
  80244b:	5d                   	pop    %ebp
  80244c:	c3                   	ret    

0080244d <execl>:
	return r;
}

int
execl(const char *prog, const char *arg0, ...)
{
  80244d:	55                   	push   %ebp
  80244e:	89 e5                	mov    %esp,%ebp
  802450:	56                   	push   %esi
  802451:	53                   	push   %ebx
  802452:	83 ec 10             	sub    $0x10,%esp
  802455:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	sys_page_unmap(0, UTEMP);
	return r;
}

int
execl(const char *prog, const char *arg0, ...)
  802458:	8d 55 10             	lea    0x10(%ebp),%edx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  80245b:	83 3a 00             	cmpl   $0x0,(%edx)
  80245e:	74 5d                	je     8024bd <execl+0x70>
  802460:	b8 00 00 00 00       	mov    $0x0,%eax
		argc++;
  802465:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802468:	83 3c 82 00          	cmpl   $0x0,(%edx,%eax,4)
  80246c:	75 f7                	jne    802465 <execl+0x18>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  80246e:	8d 14 85 26 00 00 00 	lea    0x26(,%eax,4),%edx
  802475:	83 e2 f0             	and    $0xfffffff0,%edx
  802478:	29 d4                	sub    %edx,%esp
  80247a:	8d 4c 24 17          	lea    0x17(%esp),%ecx
  80247e:	83 e1 f0             	and    $0xfffffff0,%ecx
	argv[0] = arg0;
  802481:	89 19                	mov    %ebx,(%ecx)
	argv[argc+1] = NULL;
  802483:	c7 44 81 04 00 00 00 	movl   $0x0,0x4(%ecx,%eax,4)
  80248a:	00 
	sys_page_unmap(0, UTEMP);
	return r;
}

int
execl(const char *prog, const char *arg0, ...)
  80248b:	8d 75 10             	lea    0x10(%ebp),%esi
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  80248e:	89 c3                	mov    %eax,%ebx
  802490:	85 c0                	test   %eax,%eax
  802492:	74 13                	je     8024a7 <execl+0x5a>
  802494:	b8 00 00 00 00       	mov    $0x0,%eax
		argv[i+1] = va_arg(vl, const char *);
  802499:	83 c0 01             	add    $0x1,%eax
  80249c:	8b 54 86 fc          	mov    -0x4(%esi,%eax,4),%edx
  8024a0:	89 14 81             	mov    %edx,(%ecx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  8024a3:	39 d8                	cmp    %ebx,%eax
  8024a5:	72 f2                	jb     802499 <execl+0x4c>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return exec(prog, argv);
  8024a7:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8024ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8024ae:	89 04 24             	mov    %eax,(%esp)
  8024b1:	e8 f2 fb ff ff       	call   8020a8 <exec>
}
  8024b6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8024b9:	5b                   	pop    %ebx
  8024ba:	5e                   	pop    %esi
  8024bb:	5d                   	pop    %ebp
  8024bc:	c3                   	ret    
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  8024bd:	83 ec 20             	sub    $0x20,%esp
  8024c0:	8d 4c 24 17          	lea    0x17(%esp),%ecx
  8024c4:	83 e1 f0             	and    $0xfffffff0,%ecx
	argv[0] = arg0;
  8024c7:	89 19                	mov    %ebx,(%ecx)
	argv[argc+1] = NULL;
  8024c9:	c7 41 04 00 00 00 00 	movl   $0x0,0x4(%ecx)
  8024d0:	eb d5                	jmp    8024a7 <execl+0x5a>

008024d2 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  8024d2:	55                   	push   %ebp
  8024d3:	89 e5                	mov    %esp,%ebp
  8024d5:	57                   	push   %edi
  8024d6:	56                   	push   %esi
  8024d7:	53                   	push   %ebx
  8024d8:	81 ec 9c 02 00 00    	sub    $0x29c,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  8024de:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8024e5:	00 
  8024e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8024e9:	89 04 24             	mov    %eax,(%esp)
  8024ec:	e8 c6 f9 ff ff       	call   801eb7 <open>
  8024f1:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  8024f7:	89 c7                	mov    %eax,%edi
  8024f9:	85 c0                	test   %eax,%eax
  8024fb:	0f 88 ae 03 00 00    	js     8028af <spawn+0x3dd>
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
	    || elf->e_magic != ELF_MAGIC) {
  802501:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  802508:	00 
  802509:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  80250f:	89 44 24 04          	mov    %eax,0x4(%esp)
  802513:	89 3c 24             	mov    %edi,(%esp)
  802516:	e8 01 f5 ff ff       	call   801a1c <readn>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  80251b:	3d 00 02 00 00       	cmp    $0x200,%eax
  802520:	75 0c                	jne    80252e <spawn+0x5c>
	    || elf->e_magic != ELF_MAGIC) {
  802522:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  802529:	45 4c 46 
  80252c:	74 36                	je     802564 <spawn+0x92>
		close(fd);
  80252e:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  802534:	89 04 24             	mov    %eax,(%esp)
  802537:	e8 b2 f5 ff ff       	call   801aee <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  80253c:	c7 44 24 08 7f 45 4c 	movl   $0x464c457f,0x8(%esp)
  802543:	46 
  802544:	8b 85 e8 fd ff ff    	mov    -0x218(%ebp),%eax
  80254a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80254e:	c7 04 24 bd 37 80 00 	movl   $0x8037bd,(%esp)
  802555:	e8 2b dd ff ff       	call   800285 <cprintf>
  80255a:	bf f2 ff ff ff       	mov    $0xfffffff2,%edi
		return -E_NOT_EXEC;
  80255f:	e9 4b 03 00 00       	jmp    8028af <spawn+0x3dd>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  802564:	ba 08 00 00 00       	mov    $0x8,%edx
  802569:	89 d0                	mov    %edx,%eax
  80256b:	cd 30                	int    $0x30
  80256d:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  802573:	85 c0                	test   %eax,%eax
  802575:	0f 88 2e 03 00 00    	js     8028a9 <spawn+0x3d7>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  80257b:	25 ff 03 00 00       	and    $0x3ff,%eax
  802580:	89 c2                	mov    %eax,%edx
  802582:	c1 e2 07             	shl    $0x7,%edx
  802585:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  80258b:	8d b4 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%esi
  802592:	b9 11 00 00 00       	mov    $0x11,%ecx
  802597:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  802599:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  80259f:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  8025a5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8025a8:	8b 02                	mov    (%edx),%eax
  8025aa:	be 00 00 00 00       	mov    $0x0,%esi
  8025af:	bb 00 00 00 00       	mov    $0x0,%ebx
  8025b4:	85 c0                	test   %eax,%eax
  8025b6:	75 16                	jne    8025ce <spawn+0xfc>
  8025b8:	c7 85 7c fd ff ff 00 	movl   $0x0,-0x284(%ebp)
  8025bf:	00 00 00 
  8025c2:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  8025c9:	00 00 00 
  8025cc:	eb 2c                	jmp    8025fa <spawn+0x128>
  8025ce:	8b 7d 0c             	mov    0xc(%ebp),%edi
		string_size += strlen(argv[argc]) + 1;
  8025d1:	89 04 24             	mov    %eax,(%esp)
  8025d4:	e8 97 e5 ff ff       	call   800b70 <strlen>
  8025d9:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  8025dd:	83 c3 01             	add    $0x1,%ebx
  8025e0:	8d 14 9d 00 00 00 00 	lea    0x0(,%ebx,4),%edx
  8025e7:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  8025ea:	85 c0                	test   %eax,%eax
  8025ec:	75 e3                	jne    8025d1 <spawn+0xff>
  8025ee:	89 95 7c fd ff ff    	mov    %edx,-0x284(%ebp)
  8025f4:	89 9d 78 fd ff ff    	mov    %ebx,-0x288(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  8025fa:	f7 de                	neg    %esi
  8025fc:	81 c6 00 10 40 00    	add    $0x401000,%esi
  802602:	89 b5 84 fd ff ff    	mov    %esi,-0x27c(%ebp)
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  802608:	89 f2                	mov    %esi,%edx
  80260a:	83 e2 fc             	and    $0xfffffffc,%edx
  80260d:	89 d8                	mov    %ebx,%eax
  80260f:	f7 d0                	not    %eax
  802611:	8d 04 82             	lea    (%edx,%eax,4),%eax
  802614:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  80261a:	83 e8 08             	sub    $0x8,%eax
  80261d:	89 85 80 fd ff ff    	mov    %eax,-0x280(%ebp)
	return child;

error:
	sys_env_destroy(child);
	close(fd);
	return r;
  802623:	bf fc ff ff ff       	mov    $0xfffffffc,%edi
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  802628:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  80262d:	0f 86 7c 02 00 00    	jbe    8028af <spawn+0x3dd>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  802633:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80263a:	00 
  80263b:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  802642:	00 
  802643:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80264a:	e8 99 ee ff ff       	call   8014e8 <sys_page_alloc>
  80264f:	89 c7                	mov    %eax,%edi
  802651:	85 c0                	test   %eax,%eax
  802653:	0f 88 56 02 00 00    	js     8028af <spawn+0x3dd>
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  802659:	85 db                	test   %ebx,%ebx
  80265b:	7e 52                	jle    8026af <spawn+0x1dd>
  80265d:	be 00 00 00 00       	mov    $0x0,%esi
  802662:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  802668:	8b bd 84 fd ff ff    	mov    -0x27c(%ebp),%edi
  80266e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
		argv_store[i] = UTEMP2USTACK(string_store);
  802671:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  802677:	8b 95 8c fd ff ff    	mov    -0x274(%ebp),%edx
  80267d:	89 04 b2             	mov    %eax,(%edx,%esi,4)
		strcpy(string_store, argv[i]);
  802680:	8b 04 b3             	mov    (%ebx,%esi,4),%eax
  802683:	89 44 24 04          	mov    %eax,0x4(%esp)
  802687:	89 3c 24             	mov    %edi,(%esp)
  80268a:	e8 2b e5 ff ff       	call   800bba <strcpy>
		string_store += strlen(argv[i]) + 1;
  80268f:	8b 04 b3             	mov    (%ebx,%esi,4),%eax
  802692:	89 04 24             	mov    %eax,(%esp)
  802695:	e8 d6 e4 ff ff       	call   800b70 <strlen>
  80269a:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  80269e:	83 c6 01             	add    $0x1,%esi
  8026a1:	3b b5 88 fd ff ff    	cmp    -0x278(%ebp),%esi
  8026a7:	7c c8                	jl     802671 <spawn+0x19f>
  8026a9:	89 bd 84 fd ff ff    	mov    %edi,-0x27c(%ebp)
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  8026af:	8b 95 8c fd ff ff    	mov    -0x274(%ebp),%edx
  8026b5:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  8026bb:	c7 04 02 00 00 00 00 	movl   $0x0,(%edx,%eax,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  8026c2:	81 bd 84 fd ff ff 00 	cmpl   $0x401000,-0x27c(%ebp)
  8026c9:	10 40 00 
  8026cc:	74 24                	je     8026f2 <spawn+0x220>
  8026ce:	c7 44 24 0c 20 38 80 	movl   $0x803820,0xc(%esp)
  8026d5:	00 
  8026d6:	c7 44 24 08 d7 37 80 	movl   $0x8037d7,0x8(%esp)
  8026dd:	00 
  8026de:	c7 44 24 04 ee 00 00 	movl   $0xee,0x4(%esp)
  8026e5:	00 
  8026e6:	c7 04 24 b1 37 80 00 	movl   $0x8037b1,(%esp)
  8026ed:	e8 da da ff ff       	call   8001cc <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  8026f2:	8b 85 8c fd ff ff    	mov    -0x274(%ebp),%eax
  8026f8:	2d 00 30 80 11       	sub    $0x11803000,%eax
  8026fd:	8b 95 8c fd ff ff    	mov    -0x274(%ebp),%edx
  802703:	89 42 fc             	mov    %eax,-0x4(%edx)
	argv_store[-2] = argc;
  802706:	8b 95 78 fd ff ff    	mov    -0x288(%ebp),%edx
  80270c:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  802712:	89 10                	mov    %edx,(%eax)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  802714:	8b 85 8c fd ff ff    	mov    -0x274(%ebp),%eax
  80271a:	2d 08 30 80 11       	sub    $0x11803008,%eax
  80271f:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  802725:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  80272c:	00 
  80272d:	c7 44 24 0c 00 d0 bf 	movl   $0xeebfd000,0xc(%esp)
  802734:	ee 
  802735:	8b 85 90 fd ff ff    	mov    -0x270(%ebp),%eax
  80273b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80273f:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  802746:	00 
  802747:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80274e:	e8 27 ed ff ff       	call   80147a <sys_page_map>
  802753:	89 c7                	mov    %eax,%edi
  802755:	85 c0                	test   %eax,%eax
  802757:	78 1a                	js     802773 <spawn+0x2a1>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  802759:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  802760:	00 
  802761:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802768:	e8 a1 ec ff ff       	call   80140e <sys_page_unmap>
  80276d:	89 c7                	mov    %eax,%edi
  80276f:	85 c0                	test   %eax,%eax
  802771:	79 19                	jns    80278c <spawn+0x2ba>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  802773:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  80277a:	00 
  80277b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802782:	e8 87 ec ff ff       	call   80140e <sys_page_unmap>
  802787:	e9 23 01 00 00       	jmp    8028af <spawn+0x3dd>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  80278c:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  802792:	66 83 bd 14 fe ff ff 	cmpw   $0x0,-0x1ec(%ebp)
  802799:	00 
  80279a:	74 69                	je     802805 <spawn+0x333>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  80279c:	8d 9c 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%ebx
  8027a3:	be 00 00 00 00       	mov    $0x0,%esi
  8027a8:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
	for (i = 0; i < elf->e_phnum; i++, ph++) {
		if (ph->p_type != ELF_PROG_LOAD)
  8027ae:	83 3b 01             	cmpl   $0x1,(%ebx)
  8027b1:	75 3f                	jne    8027f2 <spawn+0x320>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  8027b3:	8b 43 18             	mov    0x18(%ebx),%eax
  8027b6:	83 e0 02             	and    $0x2,%eax
  8027b9:	83 f8 01             	cmp    $0x1,%eax
  8027bc:	19 c0                	sbb    %eax,%eax
  8027be:	83 e0 fe             	and    $0xfffffffe,%eax
  8027c1:	83 c0 07             	add    $0x7,%eax
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  8027c4:	8b 4b 14             	mov    0x14(%ebx),%ecx
  8027c7:	8b 53 08             	mov    0x8(%ebx),%edx
  8027ca:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8027ce:	8b 43 04             	mov    0x4(%ebx),%eax
  8027d1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8027d5:	8b 43 10             	mov    0x10(%ebx),%eax
  8027d8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8027dc:	89 3c 24             	mov    %edi,(%esp)
  8027df:	8b 85 90 fd ff ff    	mov    -0x270(%ebp),%eax
  8027e5:	e8 6a f7 ff ff       	call   801f54 <map_segment>
  8027ea:	85 c0                	test   %eax,%eax
  8027ec:	0f 88 97 00 00 00    	js     802889 <spawn+0x3b7>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  8027f2:	83 c6 01             	add    $0x1,%esi
  8027f5:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  8027fc:	39 f0                	cmp    %esi,%eax
  8027fe:	7e 05                	jle    802805 <spawn+0x333>
  802800:	83 c3 20             	add    $0x20,%ebx
  802803:	eb a9                	jmp    8027ae <spawn+0x2dc>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  802805:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  80280b:	89 14 24             	mov    %edx,(%esp)
  80280e:	e8 db f2 ff ff       	call   801aee <close>
	fd = -1;

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  802813:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  802819:	89 44 24 04          	mov    %eax,0x4(%esp)
  80281d:	8b 85 90 fd ff ff    	mov    -0x270(%ebp),%eax
  802823:	89 04 24             	mov    %eax,(%esp)
  802826:	e8 0b eb ff ff       	call   801336 <sys_env_set_trapframe>
  80282b:	85 c0                	test   %eax,%eax
  80282d:	79 20                	jns    80284f <spawn+0x37d>
		panic("sys_env_set_trapframe: %e", r);
  80282f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802833:	c7 44 24 08 ec 37 80 	movl   $0x8037ec,0x8(%esp)
  80283a:	00 
  80283b:	c7 44 24 04 82 00 00 	movl   $0x82,0x4(%esp)
  802842:	00 
  802843:	c7 04 24 b1 37 80 00 	movl   $0x8037b1,(%esp)
  80284a:	e8 7d d9 ff ff       	call   8001cc <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  80284f:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  802856:	00 
  802857:	8b 95 90 fd ff ff    	mov    -0x270(%ebp),%edx
  80285d:	89 14 24             	mov    %edx,(%esp)
  802860:	e8 3d eb ff ff       	call   8013a2 <sys_env_set_status>
  802865:	85 c0                	test   %eax,%eax
  802867:	79 40                	jns    8028a9 <spawn+0x3d7>
		panic("sys_env_set_status: %e", r);
  802869:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80286d:	c7 44 24 08 06 38 80 	movl   $0x803806,0x8(%esp)
  802874:	00 
  802875:	c7 44 24 04 85 00 00 	movl   $0x85,0x4(%esp)
  80287c:	00 
  80287d:	c7 04 24 b1 37 80 00 	movl   $0x8037b1,(%esp)
  802884:	e8 43 d9 ff ff       	call   8001cc <_panic>
  802889:	89 c7                	mov    %eax,%edi

	return child;

error:
	sys_env_destroy(child);
  80288b:	8b 85 90 fd ff ff    	mov    -0x270(%ebp),%eax
  802891:	89 04 24             	mov    %eax,(%esp)
  802894:	e8 7e ed ff ff       	call   801617 <sys_env_destroy>
	close(fd);
  802899:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  80289f:	89 14 24             	mov    %edx,(%esp)
  8028a2:	e8 47 f2 ff ff       	call   801aee <close>
	return r;
  8028a7:	eb 06                	jmp    8028af <spawn+0x3dd>
  8028a9:	8b bd 90 fd ff ff    	mov    -0x270(%ebp),%edi
}
  8028af:	89 f8                	mov    %edi,%eax
  8028b1:	81 c4 9c 02 00 00    	add    $0x29c,%esp
  8028b7:	5b                   	pop    %ebx
  8028b8:	5e                   	pop    %esi
  8028b9:	5f                   	pop    %edi
  8028ba:	5d                   	pop    %ebp
  8028bb:	c3                   	ret    

008028bc <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  8028bc:	55                   	push   %ebp
  8028bd:	89 e5                	mov    %esp,%ebp
  8028bf:	56                   	push   %esi
  8028c0:	53                   	push   %ebx
  8028c1:	83 ec 10             	sub    $0x10,%esp
  8028c4:	8b 5d 0c             	mov    0xc(%ebp),%ebx

// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
  8028c7:	8d 55 10             	lea    0x10(%ebp),%edx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  8028ca:	83 3a 00             	cmpl   $0x0,(%edx)
  8028cd:	74 5d                	je     80292c <spawnl+0x70>
  8028cf:	b8 00 00 00 00       	mov    $0x0,%eax
		argc++;
  8028d4:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  8028d7:	83 3c 82 00          	cmpl   $0x0,(%edx,%eax,4)
  8028db:	75 f7                	jne    8028d4 <spawnl+0x18>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  8028dd:	8d 14 85 26 00 00 00 	lea    0x26(,%eax,4),%edx
  8028e4:	83 e2 f0             	and    $0xfffffff0,%edx
  8028e7:	29 d4                	sub    %edx,%esp
  8028e9:	8d 4c 24 17          	lea    0x17(%esp),%ecx
  8028ed:	83 e1 f0             	and    $0xfffffff0,%ecx
	argv[0] = arg0;
  8028f0:	89 19                	mov    %ebx,(%ecx)
	argv[argc+1] = NULL;
  8028f2:	c7 44 81 04 00 00 00 	movl   $0x0,0x4(%ecx,%eax,4)
  8028f9:	00 

// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
  8028fa:	8d 75 10             	lea    0x10(%ebp),%esi
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  8028fd:	89 c3                	mov    %eax,%ebx
  8028ff:	85 c0                	test   %eax,%eax
  802901:	74 13                	je     802916 <spawnl+0x5a>
  802903:	b8 00 00 00 00       	mov    $0x0,%eax
		argv[i+1] = va_arg(vl, const char *);
  802908:	83 c0 01             	add    $0x1,%eax
  80290b:	8b 54 86 fc          	mov    -0x4(%esi,%eax,4),%edx
  80290f:	89 14 81             	mov    %edx,(%ecx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  802912:	39 d8                	cmp    %ebx,%eax
  802914:	72 f2                	jb     802908 <spawnl+0x4c>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  802916:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80291a:	8b 45 08             	mov    0x8(%ebp),%eax
  80291d:	89 04 24             	mov    %eax,(%esp)
  802920:	e8 ad fb ff ff       	call   8024d2 <spawn>
}
  802925:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802928:	5b                   	pop    %ebx
  802929:	5e                   	pop    %esi
  80292a:	5d                   	pop    %ebp
  80292b:	c3                   	ret    
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  80292c:	83 ec 20             	sub    $0x20,%esp
  80292f:	8d 4c 24 17          	lea    0x17(%esp),%ecx
  802933:	83 e1 f0             	and    $0xfffffff0,%ecx
	argv[0] = arg0;
  802936:	89 19                	mov    %ebx,(%ecx)
	argv[argc+1] = NULL;
  802938:	c7 41 04 00 00 00 00 	movl   $0x0,0x4(%ecx)
  80293f:	eb d5                	jmp    802916 <spawnl+0x5a>
	...

00802950 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  802950:	55                   	push   %ebp
  802951:	89 e5                	mov    %esp,%ebp
  802953:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  802956:	c7 44 24 04 48 38 80 	movl   $0x803848,0x4(%esp)
  80295d:	00 
  80295e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802961:	89 04 24             	mov    %eax,(%esp)
  802964:	e8 51 e2 ff ff       	call   800bba <strcpy>
	return 0;
}
  802969:	b8 00 00 00 00       	mov    $0x0,%eax
  80296e:	c9                   	leave  
  80296f:	c3                   	ret    

00802970 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  802970:	55                   	push   %ebp
  802971:	89 e5                	mov    %esp,%ebp
  802973:	53                   	push   %ebx
  802974:	83 ec 14             	sub    $0x14,%esp
  802977:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  80297a:	89 1c 24             	mov    %ebx,(%esp)
  80297d:	e8 1a 06 00 00       	call   802f9c <pageref>
  802982:	89 c2                	mov    %eax,%edx
  802984:	b8 00 00 00 00       	mov    $0x0,%eax
  802989:	83 fa 01             	cmp    $0x1,%edx
  80298c:	75 0b                	jne    802999 <devsock_close+0x29>
		return nsipc_close(fd->fd_sock.sockid);
  80298e:	8b 43 0c             	mov    0xc(%ebx),%eax
  802991:	89 04 24             	mov    %eax,(%esp)
  802994:	e8 b9 02 00 00       	call   802c52 <nsipc_close>
	else
		return 0;
}
  802999:	83 c4 14             	add    $0x14,%esp
  80299c:	5b                   	pop    %ebx
  80299d:	5d                   	pop    %ebp
  80299e:	c3                   	ret    

0080299f <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  80299f:	55                   	push   %ebp
  8029a0:	89 e5                	mov    %esp,%ebp
  8029a2:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8029a5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8029ac:	00 
  8029ad:	8b 45 10             	mov    0x10(%ebp),%eax
  8029b0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8029b4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8029b7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8029bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8029be:	8b 40 0c             	mov    0xc(%eax),%eax
  8029c1:	89 04 24             	mov    %eax,(%esp)
  8029c4:	e8 c5 02 00 00       	call   802c8e <nsipc_send>
}
  8029c9:	c9                   	leave  
  8029ca:	c3                   	ret    

008029cb <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  8029cb:	55                   	push   %ebp
  8029cc:	89 e5                	mov    %esp,%ebp
  8029ce:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  8029d1:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8029d8:	00 
  8029d9:	8b 45 10             	mov    0x10(%ebp),%eax
  8029dc:	89 44 24 08          	mov    %eax,0x8(%esp)
  8029e0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8029e3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8029e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8029ea:	8b 40 0c             	mov    0xc(%eax),%eax
  8029ed:	89 04 24             	mov    %eax,(%esp)
  8029f0:	e8 0c 03 00 00       	call   802d01 <nsipc_recv>
}
  8029f5:	c9                   	leave  
  8029f6:	c3                   	ret    

008029f7 <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  8029f7:	55                   	push   %ebp
  8029f8:	89 e5                	mov    %esp,%ebp
  8029fa:	56                   	push   %esi
  8029fb:	53                   	push   %ebx
  8029fc:	83 ec 20             	sub    $0x20,%esp
  8029ff:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  802a01:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802a04:	89 04 24             	mov    %eax,(%esp)
  802a07:	e8 af ec ff ff       	call   8016bb <fd_alloc>
  802a0c:	89 c3                	mov    %eax,%ebx
  802a0e:	85 c0                	test   %eax,%eax
  802a10:	78 21                	js     802a33 <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  802a12:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802a19:	00 
  802a1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802a1d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802a21:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802a28:	e8 bb ea ff ff       	call   8014e8 <sys_page_alloc>
  802a2d:	89 c3                	mov    %eax,%ebx
alloc_sockfd(int sockid)
{
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  802a2f:	85 c0                	test   %eax,%eax
  802a31:	79 0a                	jns    802a3d <alloc_sockfd+0x46>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
		nsipc_close(sockid);
  802a33:	89 34 24             	mov    %esi,(%esp)
  802a36:	e8 17 02 00 00       	call   802c52 <nsipc_close>
		return r;
  802a3b:	eb 28                	jmp    802a65 <alloc_sockfd+0x6e>
	}

	sfd->fd_dev_id = devsock.dev_id;
  802a3d:	8b 15 20 40 80 00    	mov    0x804020,%edx
  802a43:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802a46:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  802a48:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802a4b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  802a52:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802a55:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  802a58:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802a5b:	89 04 24             	mov    %eax,(%esp)
  802a5e:	e8 2d ec ff ff       	call   801690 <fd2num>
  802a63:	89 c3                	mov    %eax,%ebx
}
  802a65:	89 d8                	mov    %ebx,%eax
  802a67:	83 c4 20             	add    $0x20,%esp
  802a6a:	5b                   	pop    %ebx
  802a6b:	5e                   	pop    %esi
  802a6c:	5d                   	pop    %ebp
  802a6d:	c3                   	ret    

00802a6e <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  802a6e:	55                   	push   %ebp
  802a6f:	89 e5                	mov    %esp,%ebp
  802a71:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  802a74:	8b 45 10             	mov    0x10(%ebp),%eax
  802a77:	89 44 24 08          	mov    %eax,0x8(%esp)
  802a7b:	8b 45 0c             	mov    0xc(%ebp),%eax
  802a7e:	89 44 24 04          	mov    %eax,0x4(%esp)
  802a82:	8b 45 08             	mov    0x8(%ebp),%eax
  802a85:	89 04 24             	mov    %eax,(%esp)
  802a88:	e8 79 01 00 00       	call   802c06 <nsipc_socket>
  802a8d:	85 c0                	test   %eax,%eax
  802a8f:	78 05                	js     802a96 <socket+0x28>
		return r;
	return alloc_sockfd(r);
  802a91:	e8 61 ff ff ff       	call   8029f7 <alloc_sockfd>
}
  802a96:	c9                   	leave  
  802a97:	c3                   	ret    

00802a98 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  802a98:	55                   	push   %ebp
  802a99:	89 e5                	mov    %esp,%ebp
  802a9b:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  802a9e:	8d 55 f4             	lea    -0xc(%ebp),%edx
  802aa1:	89 54 24 04          	mov    %edx,0x4(%esp)
  802aa5:	89 04 24             	mov    %eax,(%esp)
  802aa8:	e8 80 ec ff ff       	call   80172d <fd_lookup>
  802aad:	85 c0                	test   %eax,%eax
  802aaf:	78 15                	js     802ac6 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  802ab1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802ab4:	8b 0a                	mov    (%edx),%ecx
  802ab6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  802abb:	3b 0d 20 40 80 00    	cmp    0x804020,%ecx
  802ac1:	75 03                	jne    802ac6 <fd2sockid+0x2e>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  802ac3:	8b 42 0c             	mov    0xc(%edx),%eax
}
  802ac6:	c9                   	leave  
  802ac7:	c3                   	ret    

00802ac8 <listen>:
	return nsipc_connect(r, name, namelen);
}

int
listen(int s, int backlog)
{
  802ac8:	55                   	push   %ebp
  802ac9:	89 e5                	mov    %esp,%ebp
  802acb:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802ace:	8b 45 08             	mov    0x8(%ebp),%eax
  802ad1:	e8 c2 ff ff ff       	call   802a98 <fd2sockid>
  802ad6:	85 c0                	test   %eax,%eax
  802ad8:	78 0f                	js     802ae9 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  802ada:	8b 55 0c             	mov    0xc(%ebp),%edx
  802add:	89 54 24 04          	mov    %edx,0x4(%esp)
  802ae1:	89 04 24             	mov    %eax,(%esp)
  802ae4:	e8 47 01 00 00       	call   802c30 <nsipc_listen>
}
  802ae9:	c9                   	leave  
  802aea:	c3                   	ret    

00802aeb <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  802aeb:	55                   	push   %ebp
  802aec:	89 e5                	mov    %esp,%ebp
  802aee:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802af1:	8b 45 08             	mov    0x8(%ebp),%eax
  802af4:	e8 9f ff ff ff       	call   802a98 <fd2sockid>
  802af9:	85 c0                	test   %eax,%eax
  802afb:	78 16                	js     802b13 <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  802afd:	8b 55 10             	mov    0x10(%ebp),%edx
  802b00:	89 54 24 08          	mov    %edx,0x8(%esp)
  802b04:	8b 55 0c             	mov    0xc(%ebp),%edx
  802b07:	89 54 24 04          	mov    %edx,0x4(%esp)
  802b0b:	89 04 24             	mov    %eax,(%esp)
  802b0e:	e8 6e 02 00 00       	call   802d81 <nsipc_connect>
}
  802b13:	c9                   	leave  
  802b14:	c3                   	ret    

00802b15 <shutdown>:
	return nsipc_bind(r, name, namelen);
}

int
shutdown(int s, int how)
{
  802b15:	55                   	push   %ebp
  802b16:	89 e5                	mov    %esp,%ebp
  802b18:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802b1b:	8b 45 08             	mov    0x8(%ebp),%eax
  802b1e:	e8 75 ff ff ff       	call   802a98 <fd2sockid>
  802b23:	85 c0                	test   %eax,%eax
  802b25:	78 0f                	js     802b36 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  802b27:	8b 55 0c             	mov    0xc(%ebp),%edx
  802b2a:	89 54 24 04          	mov    %edx,0x4(%esp)
  802b2e:	89 04 24             	mov    %eax,(%esp)
  802b31:	e8 36 01 00 00       	call   802c6c <nsipc_shutdown>
}
  802b36:	c9                   	leave  
  802b37:	c3                   	ret    

00802b38 <bind>:
	return alloc_sockfd(r);
}

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802b38:	55                   	push   %ebp
  802b39:	89 e5                	mov    %esp,%ebp
  802b3b:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802b3e:	8b 45 08             	mov    0x8(%ebp),%eax
  802b41:	e8 52 ff ff ff       	call   802a98 <fd2sockid>
  802b46:	85 c0                	test   %eax,%eax
  802b48:	78 16                	js     802b60 <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  802b4a:	8b 55 10             	mov    0x10(%ebp),%edx
  802b4d:	89 54 24 08          	mov    %edx,0x8(%esp)
  802b51:	8b 55 0c             	mov    0xc(%ebp),%edx
  802b54:	89 54 24 04          	mov    %edx,0x4(%esp)
  802b58:	89 04 24             	mov    %eax,(%esp)
  802b5b:	e8 60 02 00 00       	call   802dc0 <nsipc_bind>
}
  802b60:	c9                   	leave  
  802b61:	c3                   	ret    

00802b62 <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  802b62:	55                   	push   %ebp
  802b63:	89 e5                	mov    %esp,%ebp
  802b65:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802b68:	8b 45 08             	mov    0x8(%ebp),%eax
  802b6b:	e8 28 ff ff ff       	call   802a98 <fd2sockid>
  802b70:	85 c0                	test   %eax,%eax
  802b72:	78 1f                	js     802b93 <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  802b74:	8b 55 10             	mov    0x10(%ebp),%edx
  802b77:	89 54 24 08          	mov    %edx,0x8(%esp)
  802b7b:	8b 55 0c             	mov    0xc(%ebp),%edx
  802b7e:	89 54 24 04          	mov    %edx,0x4(%esp)
  802b82:	89 04 24             	mov    %eax,(%esp)
  802b85:	e8 75 02 00 00       	call   802dff <nsipc_accept>
  802b8a:	85 c0                	test   %eax,%eax
  802b8c:	78 05                	js     802b93 <accept+0x31>
		return r;
	return alloc_sockfd(r);
  802b8e:	e8 64 fe ff ff       	call   8029f7 <alloc_sockfd>
}
  802b93:	c9                   	leave  
  802b94:	c3                   	ret    
	...

00802ba0 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  802ba0:	55                   	push   %ebp
  802ba1:	89 e5                	mov    %esp,%ebp
  802ba3:	53                   	push   %ebx
  802ba4:	83 ec 14             	sub    $0x14,%esp
  802ba7:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  802ba9:	83 3d 04 50 80 00 00 	cmpl   $0x0,0x805004
  802bb0:	75 11                	jne    802bc3 <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  802bb2:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  802bb9:	e8 a2 02 00 00       	call   802e60 <ipc_find_env>
  802bbe:	a3 04 50 80 00       	mov    %eax,0x805004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  802bc3:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  802bca:	00 
  802bcb:	c7 44 24 08 00 70 80 	movl   $0x807000,0x8(%esp)
  802bd2:	00 
  802bd3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802bd7:	a1 04 50 80 00       	mov    0x805004,%eax
  802bdc:	89 04 24             	mov    %eax,(%esp)
  802bdf:	e8 c7 02 00 00       	call   802eab <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  802be4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  802beb:	00 
  802bec:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  802bf3:	00 
  802bf4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802bfb:	e8 29 03 00 00       	call   802f29 <ipc_recv>
}
  802c00:	83 c4 14             	add    $0x14,%esp
  802c03:	5b                   	pop    %ebx
  802c04:	5d                   	pop    %ebp
  802c05:	c3                   	ret    

00802c06 <nsipc_socket>:
	return nsipc(NSREQ_SEND);
}

int
nsipc_socket(int domain, int type, int protocol)
{
  802c06:	55                   	push   %ebp
  802c07:	89 e5                	mov    %esp,%ebp
  802c09:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  802c0c:	8b 45 08             	mov    0x8(%ebp),%eax
  802c0f:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  802c14:	8b 45 0c             	mov    0xc(%ebp),%eax
  802c17:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  802c1c:	8b 45 10             	mov    0x10(%ebp),%eax
  802c1f:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  802c24:	b8 09 00 00 00       	mov    $0x9,%eax
  802c29:	e8 72 ff ff ff       	call   802ba0 <nsipc>
}
  802c2e:	c9                   	leave  
  802c2f:	c3                   	ret    

00802c30 <nsipc_listen>:
	return nsipc(NSREQ_CONNECT);
}

int
nsipc_listen(int s, int backlog)
{
  802c30:	55                   	push   %ebp
  802c31:	89 e5                	mov    %esp,%ebp
  802c33:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  802c36:	8b 45 08             	mov    0x8(%ebp),%eax
  802c39:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  802c3e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802c41:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  802c46:	b8 06 00 00 00       	mov    $0x6,%eax
  802c4b:	e8 50 ff ff ff       	call   802ba0 <nsipc>
}
  802c50:	c9                   	leave  
  802c51:	c3                   	ret    

00802c52 <nsipc_close>:
	return nsipc(NSREQ_SHUTDOWN);
}

int
nsipc_close(int s)
{
  802c52:	55                   	push   %ebp
  802c53:	89 e5                	mov    %esp,%ebp
  802c55:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  802c58:	8b 45 08             	mov    0x8(%ebp),%eax
  802c5b:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  802c60:	b8 04 00 00 00       	mov    $0x4,%eax
  802c65:	e8 36 ff ff ff       	call   802ba0 <nsipc>
}
  802c6a:	c9                   	leave  
  802c6b:	c3                   	ret    

00802c6c <nsipc_shutdown>:
	return nsipc(NSREQ_BIND);
}

int
nsipc_shutdown(int s, int how)
{
  802c6c:	55                   	push   %ebp
  802c6d:	89 e5                	mov    %esp,%ebp
  802c6f:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  802c72:	8b 45 08             	mov    0x8(%ebp),%eax
  802c75:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  802c7a:	8b 45 0c             	mov    0xc(%ebp),%eax
  802c7d:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  802c82:	b8 03 00 00 00       	mov    $0x3,%eax
  802c87:	e8 14 ff ff ff       	call   802ba0 <nsipc>
}
  802c8c:	c9                   	leave  
  802c8d:	c3                   	ret    

00802c8e <nsipc_send>:
	return r;
}

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  802c8e:	55                   	push   %ebp
  802c8f:	89 e5                	mov    %esp,%ebp
  802c91:	53                   	push   %ebx
  802c92:	83 ec 14             	sub    $0x14,%esp
  802c95:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  802c98:	8b 45 08             	mov    0x8(%ebp),%eax
  802c9b:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  802ca0:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  802ca6:	7e 24                	jle    802ccc <nsipc_send+0x3e>
  802ca8:	c7 44 24 0c 54 38 80 	movl   $0x803854,0xc(%esp)
  802caf:	00 
  802cb0:	c7 44 24 08 d7 37 80 	movl   $0x8037d7,0x8(%esp)
  802cb7:	00 
  802cb8:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
  802cbf:	00 
  802cc0:	c7 04 24 60 38 80 00 	movl   $0x803860,(%esp)
  802cc7:	e8 00 d5 ff ff       	call   8001cc <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  802ccc:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802cd0:	8b 45 0c             	mov    0xc(%ebp),%eax
  802cd3:	89 44 24 04          	mov    %eax,0x4(%esp)
  802cd7:	c7 04 24 0c 70 80 00 	movl   $0x80700c,(%esp)
  802cde:	e8 c2 e0 ff ff       	call   800da5 <memmove>
	nsipcbuf.send.req_size = size;
  802ce3:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  802ce9:	8b 45 14             	mov    0x14(%ebp),%eax
  802cec:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  802cf1:	b8 08 00 00 00       	mov    $0x8,%eax
  802cf6:	e8 a5 fe ff ff       	call   802ba0 <nsipc>
}
  802cfb:	83 c4 14             	add    $0x14,%esp
  802cfe:	5b                   	pop    %ebx
  802cff:	5d                   	pop    %ebp
  802d00:	c3                   	ret    

00802d01 <nsipc_recv>:
	return nsipc(NSREQ_LISTEN);
}

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  802d01:	55                   	push   %ebp
  802d02:	89 e5                	mov    %esp,%ebp
  802d04:	56                   	push   %esi
  802d05:	53                   	push   %ebx
  802d06:	83 ec 10             	sub    $0x10,%esp
  802d09:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  802d0c:	8b 45 08             	mov    0x8(%ebp),%eax
  802d0f:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  802d14:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  802d1a:	8b 45 14             	mov    0x14(%ebp),%eax
  802d1d:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  802d22:	b8 07 00 00 00       	mov    $0x7,%eax
  802d27:	e8 74 fe ff ff       	call   802ba0 <nsipc>
  802d2c:	89 c3                	mov    %eax,%ebx
  802d2e:	85 c0                	test   %eax,%eax
  802d30:	78 46                	js     802d78 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  802d32:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  802d37:	7f 04                	jg     802d3d <nsipc_recv+0x3c>
  802d39:	39 c6                	cmp    %eax,%esi
  802d3b:	7d 24                	jge    802d61 <nsipc_recv+0x60>
  802d3d:	c7 44 24 0c 6c 38 80 	movl   $0x80386c,0xc(%esp)
  802d44:	00 
  802d45:	c7 44 24 08 d7 37 80 	movl   $0x8037d7,0x8(%esp)
  802d4c:	00 
  802d4d:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
  802d54:	00 
  802d55:	c7 04 24 60 38 80 00 	movl   $0x803860,(%esp)
  802d5c:	e8 6b d4 ff ff       	call   8001cc <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  802d61:	89 44 24 08          	mov    %eax,0x8(%esp)
  802d65:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  802d6c:	00 
  802d6d:	8b 45 0c             	mov    0xc(%ebp),%eax
  802d70:	89 04 24             	mov    %eax,(%esp)
  802d73:	e8 2d e0 ff ff       	call   800da5 <memmove>
	}

	return r;
}
  802d78:	89 d8                	mov    %ebx,%eax
  802d7a:	83 c4 10             	add    $0x10,%esp
  802d7d:	5b                   	pop    %ebx
  802d7e:	5e                   	pop    %esi
  802d7f:	5d                   	pop    %ebp
  802d80:	c3                   	ret    

00802d81 <nsipc_connect>:
	return nsipc(NSREQ_CLOSE);
}

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  802d81:	55                   	push   %ebp
  802d82:	89 e5                	mov    %esp,%ebp
  802d84:	53                   	push   %ebx
  802d85:	83 ec 14             	sub    $0x14,%esp
  802d88:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  802d8b:	8b 45 08             	mov    0x8(%ebp),%eax
  802d8e:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  802d93:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802d97:	8b 45 0c             	mov    0xc(%ebp),%eax
  802d9a:	89 44 24 04          	mov    %eax,0x4(%esp)
  802d9e:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  802da5:	e8 fb df ff ff       	call   800da5 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  802daa:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  802db0:	b8 05 00 00 00       	mov    $0x5,%eax
  802db5:	e8 e6 fd ff ff       	call   802ba0 <nsipc>
}
  802dba:	83 c4 14             	add    $0x14,%esp
  802dbd:	5b                   	pop    %ebx
  802dbe:	5d                   	pop    %ebp
  802dbf:	c3                   	ret    

00802dc0 <nsipc_bind>:
	return r;
}

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802dc0:	55                   	push   %ebp
  802dc1:	89 e5                	mov    %esp,%ebp
  802dc3:	53                   	push   %ebx
  802dc4:	83 ec 14             	sub    $0x14,%esp
  802dc7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  802dca:	8b 45 08             	mov    0x8(%ebp),%eax
  802dcd:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  802dd2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802dd6:	8b 45 0c             	mov    0xc(%ebp),%eax
  802dd9:	89 44 24 04          	mov    %eax,0x4(%esp)
  802ddd:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  802de4:	e8 bc df ff ff       	call   800da5 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  802de9:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  802def:	b8 02 00 00 00       	mov    $0x2,%eax
  802df4:	e8 a7 fd ff ff       	call   802ba0 <nsipc>
}
  802df9:	83 c4 14             	add    $0x14,%esp
  802dfc:	5b                   	pop    %ebx
  802dfd:	5d                   	pop    %ebp
  802dfe:	c3                   	ret    

00802dff <nsipc_accept>:
	return ipc_recv(NULL, NULL, NULL);
}

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  802dff:	55                   	push   %ebp
  802e00:	89 e5                	mov    %esp,%ebp
  802e02:	83 ec 18             	sub    $0x18,%esp
  802e05:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  802e08:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int r;

	nsipcbuf.accept.req_s = s;
  802e0b:	8b 45 08             	mov    0x8(%ebp),%eax
  802e0e:	a3 00 70 80 00       	mov    %eax,0x807000
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  802e13:	b8 01 00 00 00       	mov    $0x1,%eax
  802e18:	e8 83 fd ff ff       	call   802ba0 <nsipc>
  802e1d:	89 c3                	mov    %eax,%ebx
  802e1f:	85 c0                	test   %eax,%eax
  802e21:	78 25                	js     802e48 <nsipc_accept+0x49>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  802e23:	be 10 70 80 00       	mov    $0x807010,%esi
  802e28:	8b 06                	mov    (%esi),%eax
  802e2a:	89 44 24 08          	mov    %eax,0x8(%esp)
  802e2e:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  802e35:	00 
  802e36:	8b 45 0c             	mov    0xc(%ebp),%eax
  802e39:	89 04 24             	mov    %eax,(%esp)
  802e3c:	e8 64 df ff ff       	call   800da5 <memmove>
		*addrlen = ret->ret_addrlen;
  802e41:	8b 16                	mov    (%esi),%edx
  802e43:	8b 45 10             	mov    0x10(%ebp),%eax
  802e46:	89 10                	mov    %edx,(%eax)
	}
	return r;
}
  802e48:	89 d8                	mov    %ebx,%eax
  802e4a:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  802e4d:	8b 75 fc             	mov    -0x4(%ebp),%esi
  802e50:	89 ec                	mov    %ebp,%esp
  802e52:	5d                   	pop    %ebp
  802e53:	c3                   	ret    
	...

00802e60 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802e60:	55                   	push   %ebp
  802e61:	89 e5                	mov    %esp,%ebp
  802e63:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  802e66:	8b 15 50 00 c0 ee    	mov    0xeec00050,%edx
  802e6c:	b8 01 00 00 00       	mov    $0x1,%eax
  802e71:	39 ca                	cmp    %ecx,%edx
  802e73:	75 04                	jne    802e79 <ipc_find_env+0x19>
  802e75:	b0 00                	mov    $0x0,%al
  802e77:	eb 12                	jmp    802e8b <ipc_find_env+0x2b>
  802e79:	89 c2                	mov    %eax,%edx
  802e7b:	c1 e2 07             	shl    $0x7,%edx
  802e7e:	8d 94 82 50 00 c0 ee 	lea    -0x113fffb0(%edx,%eax,4),%edx
  802e85:	8b 12                	mov    (%edx),%edx
  802e87:	39 ca                	cmp    %ecx,%edx
  802e89:	75 10                	jne    802e9b <ipc_find_env+0x3b>
			return envs[i].env_id;
  802e8b:	89 c2                	mov    %eax,%edx
  802e8d:	c1 e2 07             	shl    $0x7,%edx
  802e90:	8d 84 82 48 00 c0 ee 	lea    -0x113fffb8(%edx,%eax,4),%eax
  802e97:	8b 00                	mov    (%eax),%eax
  802e99:	eb 0e                	jmp    802ea9 <ipc_find_env+0x49>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802e9b:	83 c0 01             	add    $0x1,%eax
  802e9e:	3d 00 04 00 00       	cmp    $0x400,%eax
  802ea3:	75 d4                	jne    802e79 <ipc_find_env+0x19>
  802ea5:	66 b8 00 00          	mov    $0x0,%ax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  802ea9:	5d                   	pop    %ebp
  802eaa:	c3                   	ret    

00802eab <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802eab:	55                   	push   %ebp
  802eac:	89 e5                	mov    %esp,%ebp
  802eae:	57                   	push   %edi
  802eaf:	56                   	push   %esi
  802eb0:	53                   	push   %ebx
  802eb1:	83 ec 1c             	sub    $0x1c,%esp
  802eb4:	8b 75 08             	mov    0x8(%ebp),%esi
  802eb7:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802eba:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        int ret;
        while(1){
           if(pg)
  802ebd:	85 db                	test   %ebx,%ebx
  802ebf:	74 19                	je     802eda <ipc_send+0x2f>
              ret = sys_ipc_try_send(to_env,val,pg,perm);
  802ec1:	8b 45 14             	mov    0x14(%ebp),%eax
  802ec4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802ec8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802ecc:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802ed0:	89 34 24             	mov    %esi,(%esp)
  802ed3:	e8 b1 e3 ff ff       	call   801289 <sys_ipc_try_send>
  802ed8:	eb 1b                	jmp    802ef5 <ipc_send+0x4a>
           else
              ret = sys_ipc_try_send(to_env,val,(void*)UTOP,perm);
  802eda:	8b 45 14             	mov    0x14(%ebp),%eax
  802edd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802ee1:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  802ee8:	ee 
  802ee9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802eed:	89 34 24             	mov    %esi,(%esp)
  802ef0:	e8 94 e3 ff ff       	call   801289 <sys_ipc_try_send>
           if(ret == 0)
  802ef5:	85 c0                	test   %eax,%eax
  802ef7:	74 28                	je     802f21 <ipc_send+0x76>
              return;
           if(ret != -E_IPC_NOT_RECV)
  802ef9:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802efc:	74 1c                	je     802f1a <ipc_send+0x6f>
              panic("ipc send error");
  802efe:	c7 44 24 08 81 38 80 	movl   $0x803881,0x8(%esp)
  802f05:	00 
  802f06:	c7 44 24 04 46 00 00 	movl   $0x46,0x4(%esp)
  802f0d:	00 
  802f0e:	c7 04 24 90 38 80 00 	movl   $0x803890,(%esp)
  802f15:	e8 b2 d2 ff ff       	call   8001cc <_panic>
           sys_yield();
  802f1a:	e8 36 e6 ff ff       	call   801555 <sys_yield>
        }
  802f1f:	eb 9c                	jmp    802ebd <ipc_send+0x12>
	//panic("ipc_send not implemented");
}
  802f21:	83 c4 1c             	add    $0x1c,%esp
  802f24:	5b                   	pop    %ebx
  802f25:	5e                   	pop    %esi
  802f26:	5f                   	pop    %edi
  802f27:	5d                   	pop    %ebp
  802f28:	c3                   	ret    

00802f29 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802f29:	55                   	push   %ebp
  802f2a:	89 e5                	mov    %esp,%ebp
  802f2c:	56                   	push   %esi
  802f2d:	53                   	push   %ebx
  802f2e:	83 ec 10             	sub    $0x10,%esp
  802f31:	8b 75 08             	mov    0x8(%ebp),%esi
  802f34:	8b 45 0c             	mov    0xc(%ebp),%eax
  802f37:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        int ret;
        if(!pg)
  802f3a:	85 c0                	test   %eax,%eax
  802f3c:	75 0e                	jne    802f4c <ipc_recv+0x23>
           ret = sys_ipc_recv((void*)UTOP);
  802f3e:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  802f45:	e8 d4 e2 ff ff       	call   80121e <sys_ipc_recv>
  802f4a:	eb 08                	jmp    802f54 <ipc_recv+0x2b>
        else
           ret = sys_ipc_recv(pg);
  802f4c:	89 04 24             	mov    %eax,(%esp)
  802f4f:	e8 ca e2 ff ff       	call   80121e <sys_ipc_recv>
        if(ret == 0){
  802f54:	85 c0                	test   %eax,%eax
  802f56:	75 26                	jne    802f7e <ipc_recv+0x55>
           if(from_env_store)
  802f58:	85 f6                	test   %esi,%esi
  802f5a:	74 0a                	je     802f66 <ipc_recv+0x3d>
              *from_env_store = thisenv->env_ipc_from;
  802f5c:	a1 08 50 80 00       	mov    0x805008,%eax
  802f61:	8b 40 78             	mov    0x78(%eax),%eax
  802f64:	89 06                	mov    %eax,(%esi)
           if(perm_store)
  802f66:	85 db                	test   %ebx,%ebx
  802f68:	74 0a                	je     802f74 <ipc_recv+0x4b>
              *perm_store = thisenv->env_ipc_perm;
  802f6a:	a1 08 50 80 00       	mov    0x805008,%eax
  802f6f:	8b 40 7c             	mov    0x7c(%eax),%eax
  802f72:	89 03                	mov    %eax,(%ebx)
           return thisenv->env_ipc_value;
  802f74:	a1 08 50 80 00       	mov    0x805008,%eax
  802f79:	8b 40 74             	mov    0x74(%eax),%eax
  802f7c:	eb 14                	jmp    802f92 <ipc_recv+0x69>
        }
        else{
           if(from_env_store)
  802f7e:	85 f6                	test   %esi,%esi
  802f80:	74 06                	je     802f88 <ipc_recv+0x5f>
              *from_env_store = 0;
  802f82:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
           if(perm_store)
  802f88:	85 db                	test   %ebx,%ebx
  802f8a:	74 06                	je     802f92 <ipc_recv+0x69>
              *perm_store = 0;
  802f8c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
           return ret;
        }
	//panic("ipc_recv not implemented");
	return 0;
}
  802f92:	83 c4 10             	add    $0x10,%esp
  802f95:	5b                   	pop    %ebx
  802f96:	5e                   	pop    %esi
  802f97:	5d                   	pop    %ebp
  802f98:	c3                   	ret    
  802f99:	00 00                	add    %al,(%eax)
	...

00802f9c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802f9c:	55                   	push   %ebp
  802f9d:	89 e5                	mov    %esp,%ebp
	pte_t pte;

	if (!(vpd[PDX(v)] & PTE_P))
  802f9f:	8b 45 08             	mov    0x8(%ebp),%eax
  802fa2:	89 c2                	mov    %eax,%edx
  802fa4:	c1 ea 16             	shr    $0x16,%edx
  802fa7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802fae:	f6 c2 01             	test   $0x1,%dl
  802fb1:	74 20                	je     802fd3 <pageref+0x37>
		return 0;
	pte = vpt[PGNUM(v)];
  802fb3:	c1 e8 0c             	shr    $0xc,%eax
  802fb6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802fbd:	a8 01                	test   $0x1,%al
  802fbf:	74 12                	je     802fd3 <pageref+0x37>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802fc1:	c1 e8 0c             	shr    $0xc,%eax
  802fc4:	ba 00 00 00 ef       	mov    $0xef000000,%edx
  802fc9:	0f b7 44 c2 04       	movzwl 0x4(%edx,%eax,8),%eax
  802fce:	0f b7 c0             	movzwl %ax,%eax
  802fd1:	eb 05                	jmp    802fd8 <pageref+0x3c>
  802fd3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802fd8:	5d                   	pop    %ebp
  802fd9:	c3                   	ret    
  802fda:	00 00                	add    %al,(%eax)
  802fdc:	00 00                	add    %al,(%eax)
	...

00802fe0 <__udivdi3>:
  802fe0:	55                   	push   %ebp
  802fe1:	89 e5                	mov    %esp,%ebp
  802fe3:	57                   	push   %edi
  802fe4:	56                   	push   %esi
  802fe5:	83 ec 10             	sub    $0x10,%esp
  802fe8:	8b 45 14             	mov    0x14(%ebp),%eax
  802feb:	8b 55 08             	mov    0x8(%ebp),%edx
  802fee:	8b 75 10             	mov    0x10(%ebp),%esi
  802ff1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802ff4:	85 c0                	test   %eax,%eax
  802ff6:	89 55 f0             	mov    %edx,-0x10(%ebp)
  802ff9:	75 35                	jne    803030 <__udivdi3+0x50>
  802ffb:	39 fe                	cmp    %edi,%esi
  802ffd:	77 61                	ja     803060 <__udivdi3+0x80>
  802fff:	85 f6                	test   %esi,%esi
  803001:	75 0b                	jne    80300e <__udivdi3+0x2e>
  803003:	b8 01 00 00 00       	mov    $0x1,%eax
  803008:	31 d2                	xor    %edx,%edx
  80300a:	f7 f6                	div    %esi
  80300c:	89 c6                	mov    %eax,%esi
  80300e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  803011:	31 d2                	xor    %edx,%edx
  803013:	89 f8                	mov    %edi,%eax
  803015:	f7 f6                	div    %esi
  803017:	89 c7                	mov    %eax,%edi
  803019:	89 c8                	mov    %ecx,%eax
  80301b:	f7 f6                	div    %esi
  80301d:	89 c1                	mov    %eax,%ecx
  80301f:	89 fa                	mov    %edi,%edx
  803021:	89 c8                	mov    %ecx,%eax
  803023:	83 c4 10             	add    $0x10,%esp
  803026:	5e                   	pop    %esi
  803027:	5f                   	pop    %edi
  803028:	5d                   	pop    %ebp
  803029:	c3                   	ret    
  80302a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  803030:	39 f8                	cmp    %edi,%eax
  803032:	77 1c                	ja     803050 <__udivdi3+0x70>
  803034:	0f bd d0             	bsr    %eax,%edx
  803037:	83 f2 1f             	xor    $0x1f,%edx
  80303a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80303d:	75 39                	jne    803078 <__udivdi3+0x98>
  80303f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  803042:	0f 86 a0 00 00 00    	jbe    8030e8 <__udivdi3+0x108>
  803048:	39 f8                	cmp    %edi,%eax
  80304a:	0f 82 98 00 00 00    	jb     8030e8 <__udivdi3+0x108>
  803050:	31 ff                	xor    %edi,%edi
  803052:	31 c9                	xor    %ecx,%ecx
  803054:	89 c8                	mov    %ecx,%eax
  803056:	89 fa                	mov    %edi,%edx
  803058:	83 c4 10             	add    $0x10,%esp
  80305b:	5e                   	pop    %esi
  80305c:	5f                   	pop    %edi
  80305d:	5d                   	pop    %ebp
  80305e:	c3                   	ret    
  80305f:	90                   	nop
  803060:	89 d1                	mov    %edx,%ecx
  803062:	89 fa                	mov    %edi,%edx
  803064:	89 c8                	mov    %ecx,%eax
  803066:	31 ff                	xor    %edi,%edi
  803068:	f7 f6                	div    %esi
  80306a:	89 c1                	mov    %eax,%ecx
  80306c:	89 fa                	mov    %edi,%edx
  80306e:	89 c8                	mov    %ecx,%eax
  803070:	83 c4 10             	add    $0x10,%esp
  803073:	5e                   	pop    %esi
  803074:	5f                   	pop    %edi
  803075:	5d                   	pop    %ebp
  803076:	c3                   	ret    
  803077:	90                   	nop
  803078:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80307c:	89 f2                	mov    %esi,%edx
  80307e:	d3 e0                	shl    %cl,%eax
  803080:	89 45 ec             	mov    %eax,-0x14(%ebp)
  803083:	b8 20 00 00 00       	mov    $0x20,%eax
  803088:	2b 45 f4             	sub    -0xc(%ebp),%eax
  80308b:	89 c1                	mov    %eax,%ecx
  80308d:	d3 ea                	shr    %cl,%edx
  80308f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  803093:	0b 55 ec             	or     -0x14(%ebp),%edx
  803096:	d3 e6                	shl    %cl,%esi
  803098:	89 c1                	mov    %eax,%ecx
  80309a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  80309d:	89 fe                	mov    %edi,%esi
  80309f:	d3 ee                	shr    %cl,%esi
  8030a1:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8030a5:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8030a8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8030ab:	d3 e7                	shl    %cl,%edi
  8030ad:	89 c1                	mov    %eax,%ecx
  8030af:	d3 ea                	shr    %cl,%edx
  8030b1:	09 d7                	or     %edx,%edi
  8030b3:	89 f2                	mov    %esi,%edx
  8030b5:	89 f8                	mov    %edi,%eax
  8030b7:	f7 75 ec             	divl   -0x14(%ebp)
  8030ba:	89 d6                	mov    %edx,%esi
  8030bc:	89 c7                	mov    %eax,%edi
  8030be:	f7 65 e8             	mull   -0x18(%ebp)
  8030c1:	39 d6                	cmp    %edx,%esi
  8030c3:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8030c6:	72 30                	jb     8030f8 <__udivdi3+0x118>
  8030c8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8030cb:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8030cf:	d3 e2                	shl    %cl,%edx
  8030d1:	39 c2                	cmp    %eax,%edx
  8030d3:	73 05                	jae    8030da <__udivdi3+0xfa>
  8030d5:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  8030d8:	74 1e                	je     8030f8 <__udivdi3+0x118>
  8030da:	89 f9                	mov    %edi,%ecx
  8030dc:	31 ff                	xor    %edi,%edi
  8030de:	e9 71 ff ff ff       	jmp    803054 <__udivdi3+0x74>
  8030e3:	90                   	nop
  8030e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8030e8:	31 ff                	xor    %edi,%edi
  8030ea:	b9 01 00 00 00       	mov    $0x1,%ecx
  8030ef:	e9 60 ff ff ff       	jmp    803054 <__udivdi3+0x74>
  8030f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8030f8:	8d 4f ff             	lea    -0x1(%edi),%ecx
  8030fb:	31 ff                	xor    %edi,%edi
  8030fd:	89 c8                	mov    %ecx,%eax
  8030ff:	89 fa                	mov    %edi,%edx
  803101:	83 c4 10             	add    $0x10,%esp
  803104:	5e                   	pop    %esi
  803105:	5f                   	pop    %edi
  803106:	5d                   	pop    %ebp
  803107:	c3                   	ret    
	...

00803110 <__umoddi3>:
  803110:	55                   	push   %ebp
  803111:	89 e5                	mov    %esp,%ebp
  803113:	57                   	push   %edi
  803114:	56                   	push   %esi
  803115:	83 ec 20             	sub    $0x20,%esp
  803118:	8b 55 14             	mov    0x14(%ebp),%edx
  80311b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80311e:	8b 7d 10             	mov    0x10(%ebp),%edi
  803121:	8b 75 0c             	mov    0xc(%ebp),%esi
  803124:	85 d2                	test   %edx,%edx
  803126:	89 c8                	mov    %ecx,%eax
  803128:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80312b:	75 13                	jne    803140 <__umoddi3+0x30>
  80312d:	39 f7                	cmp    %esi,%edi
  80312f:	76 3f                	jbe    803170 <__umoddi3+0x60>
  803131:	89 f2                	mov    %esi,%edx
  803133:	f7 f7                	div    %edi
  803135:	89 d0                	mov    %edx,%eax
  803137:	31 d2                	xor    %edx,%edx
  803139:	83 c4 20             	add    $0x20,%esp
  80313c:	5e                   	pop    %esi
  80313d:	5f                   	pop    %edi
  80313e:	5d                   	pop    %ebp
  80313f:	c3                   	ret    
  803140:	39 f2                	cmp    %esi,%edx
  803142:	77 4c                	ja     803190 <__umoddi3+0x80>
  803144:	0f bd ca             	bsr    %edx,%ecx
  803147:	83 f1 1f             	xor    $0x1f,%ecx
  80314a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80314d:	75 51                	jne    8031a0 <__umoddi3+0x90>
  80314f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  803152:	0f 87 e0 00 00 00    	ja     803238 <__umoddi3+0x128>
  803158:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80315b:	29 f8                	sub    %edi,%eax
  80315d:	19 d6                	sbb    %edx,%esi
  80315f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  803162:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803165:	89 f2                	mov    %esi,%edx
  803167:	83 c4 20             	add    $0x20,%esp
  80316a:	5e                   	pop    %esi
  80316b:	5f                   	pop    %edi
  80316c:	5d                   	pop    %ebp
  80316d:	c3                   	ret    
  80316e:	66 90                	xchg   %ax,%ax
  803170:	85 ff                	test   %edi,%edi
  803172:	75 0b                	jne    80317f <__umoddi3+0x6f>
  803174:	b8 01 00 00 00       	mov    $0x1,%eax
  803179:	31 d2                	xor    %edx,%edx
  80317b:	f7 f7                	div    %edi
  80317d:	89 c7                	mov    %eax,%edi
  80317f:	89 f0                	mov    %esi,%eax
  803181:	31 d2                	xor    %edx,%edx
  803183:	f7 f7                	div    %edi
  803185:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803188:	f7 f7                	div    %edi
  80318a:	eb a9                	jmp    803135 <__umoddi3+0x25>
  80318c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803190:	89 c8                	mov    %ecx,%eax
  803192:	89 f2                	mov    %esi,%edx
  803194:	83 c4 20             	add    $0x20,%esp
  803197:	5e                   	pop    %esi
  803198:	5f                   	pop    %edi
  803199:	5d                   	pop    %ebp
  80319a:	c3                   	ret    
  80319b:	90                   	nop
  80319c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8031a0:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8031a4:	d3 e2                	shl    %cl,%edx
  8031a6:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8031a9:	ba 20 00 00 00       	mov    $0x20,%edx
  8031ae:	2b 55 f0             	sub    -0x10(%ebp),%edx
  8031b1:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8031b4:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8031b8:	89 fa                	mov    %edi,%edx
  8031ba:	d3 ea                	shr    %cl,%edx
  8031bc:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8031c0:	0b 55 f4             	or     -0xc(%ebp),%edx
  8031c3:	d3 e7                	shl    %cl,%edi
  8031c5:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8031c9:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8031cc:	89 f2                	mov    %esi,%edx
  8031ce:	89 7d e8             	mov    %edi,-0x18(%ebp)
  8031d1:	89 c7                	mov    %eax,%edi
  8031d3:	d3 ea                	shr    %cl,%edx
  8031d5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8031d9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8031dc:	89 c2                	mov    %eax,%edx
  8031de:	d3 e6                	shl    %cl,%esi
  8031e0:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8031e4:	d3 ea                	shr    %cl,%edx
  8031e6:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8031ea:	09 d6                	or     %edx,%esi
  8031ec:	89 f0                	mov    %esi,%eax
  8031ee:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8031f1:	d3 e7                	shl    %cl,%edi
  8031f3:	89 f2                	mov    %esi,%edx
  8031f5:	f7 75 f4             	divl   -0xc(%ebp)
  8031f8:	89 d6                	mov    %edx,%esi
  8031fa:	f7 65 e8             	mull   -0x18(%ebp)
  8031fd:	39 d6                	cmp    %edx,%esi
  8031ff:	72 2b                	jb     80322c <__umoddi3+0x11c>
  803201:	39 c7                	cmp    %eax,%edi
  803203:	72 23                	jb     803228 <__umoddi3+0x118>
  803205:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  803209:	29 c7                	sub    %eax,%edi
  80320b:	19 d6                	sbb    %edx,%esi
  80320d:	89 f0                	mov    %esi,%eax
  80320f:	89 f2                	mov    %esi,%edx
  803211:	d3 ef                	shr    %cl,%edi
  803213:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  803217:	d3 e0                	shl    %cl,%eax
  803219:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80321d:	09 f8                	or     %edi,%eax
  80321f:	d3 ea                	shr    %cl,%edx
  803221:	83 c4 20             	add    $0x20,%esp
  803224:	5e                   	pop    %esi
  803225:	5f                   	pop    %edi
  803226:	5d                   	pop    %ebp
  803227:	c3                   	ret    
  803228:	39 d6                	cmp    %edx,%esi
  80322a:	75 d9                	jne    803205 <__umoddi3+0xf5>
  80322c:	2b 45 e8             	sub    -0x18(%ebp),%eax
  80322f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  803232:	eb d1                	jmp    803205 <__umoddi3+0xf5>
  803234:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803238:	39 f2                	cmp    %esi,%edx
  80323a:	0f 82 18 ff ff ff    	jb     803158 <__umoddi3+0x48>
  803240:	e9 1d ff ff ff       	jmp    803162 <__umoddi3+0x52>
