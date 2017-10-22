
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
  80003f:	c7 05 00 40 80 00 00 	movl   $0x802c00,0x804000
  800046:	2c 80 00 

	cprintf("icode startup\n");
  800049:	c7 04 24 06 2c 80 00 	movl   $0x802c06,(%esp)
  800050:	e8 30 02 00 00       	call   800285 <cprintf>

	cprintf("icode: open /motd\n");
  800055:	c7 04 24 15 2c 80 00 	movl   $0x802c15,(%esp)
  80005c:	e8 24 02 00 00       	call   800285 <cprintf>
	if ((fd = open("/motd", O_RDONLY)) < 0)
  800061:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800068:	00 
  800069:	c7 04 24 28 2c 80 00 	movl   $0x802c28,(%esp)
  800070:	e8 32 1d 00 00       	call   801da7 <open>
  800075:	89 c6                	mov    %eax,%esi
  800077:	85 c0                	test   %eax,%eax
  800079:	79 20                	jns    80009b <umain+0x67>
		panic("icode: open /motd: %e", fd);
  80007b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80007f:	c7 44 24 08 2e 2c 80 	movl   $0x802c2e,0x8(%esp)
  800086:	00 
  800087:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
  80008e:	00 
  80008f:	c7 04 24 44 2c 80 00 	movl   $0x802c44,(%esp)
  800096:	e8 31 01 00 00       	call   8001cc <_panic>

	cprintf("icode: read /motd\n");
  80009b:	c7 04 24 51 2c 80 00 	movl   $0x802c51,(%esp)
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
  8000ca:	e8 af 17 00 00       	call   80187e <read>
  8000cf:	85 c0                	test   %eax,%eax
  8000d1:	7f dc                	jg     8000af <umain+0x7b>
		sys_cputs(buf, n);

	cprintf("icode: close /motd\n");
  8000d3:	c7 04 24 64 2c 80 00 	movl   $0x802c64,(%esp)
  8000da:	e8 a6 01 00 00       	call   800285 <cprintf>
	close(fd);
  8000df:	89 34 24             	mov    %esi,(%esp)
  8000e2:	e8 f7 18 00 00       	call   8019de <close>

	cprintf("icode: spawn /init\n");
  8000e7:	c7 04 24 78 2c 80 00 	movl   $0x802c78,(%esp)
  8000ee:	e8 92 01 00 00       	call   800285 <cprintf>
	if ((r = spawnl("/init", "init", "initarg1", "initarg2", (char*)0)) < 0)
  8000f3:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8000fa:	00 
  8000fb:	c7 44 24 0c 8c 2c 80 	movl   $0x802c8c,0xc(%esp)
  800102:	00 
  800103:	c7 44 24 08 95 2c 80 	movl   $0x802c95,0x8(%esp)
  80010a:	00 
  80010b:	c7 44 24 04 9f 2c 80 	movl   $0x802c9f,0x4(%esp)
  800112:	00 
  800113:	c7 04 24 9e 2c 80 00 	movl   $0x802c9e,(%esp)
  80011a:	e8 8d 26 00 00       	call   8027ac <spawnl>
  80011f:	85 c0                	test   %eax,%eax
  800121:	79 20                	jns    800143 <umain+0x10f>
		panic("icode: spawn /init: %e", r);
  800123:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800127:	c7 44 24 08 a4 2c 80 	movl   $0x802ca4,0x8(%esp)
  80012e:	00 
  80012f:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  800136:	00 
  800137:	c7 04 24 44 2c 80 00 	movl   $0x802c44,(%esp)
  80013e:	e8 89 00 00 00       	call   8001cc <_panic>

	cprintf("icode: exiting\n");
  800143:	c7 04 24 bb 2c 80 00 	movl   $0x802cbb,(%esp)
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
  80016e:	e8 5f 13 00 00       	call   8014d2 <sys_getenvid>
  800173:	25 ff 03 00 00       	and    $0x3ff,%eax
  800178:	89 c2                	mov    %eax,%edx
  80017a:	c1 e2 07             	shl    $0x7,%edx
  80017d:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  800184:	a3 04 50 80 00       	mov    %eax,0x805004
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
  8001b6:	e8 a0 18 00 00       	call   801a5b <close_all>
	sys_env_destroy(0);
  8001bb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8001c2:	e8 4b 13 00 00       	call   801512 <sys_env_destroy>
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
  8001dd:	e8 f0 12 00 00       	call   8014d2 <sys_getenvid>
  8001e2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001e5:	89 54 24 10          	mov    %edx,0x10(%esp)
  8001e9:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ec:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8001f0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001f8:	c7 04 24 d8 2c 80 00 	movl   $0x802cd8,(%esp)
  8001ff:	e8 81 00 00 00       	call   800285 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800204:	89 74 24 04          	mov    %esi,0x4(%esp)
  800208:	8b 45 10             	mov    0x10(%ebp),%eax
  80020b:	89 04 24             	mov    %eax,(%esp)
  80020e:	e8 11 00 00 00       	call   800224 <vcprintf>
	cprintf("\n");
  800213:	c7 04 24 62 2c 80 00 	movl   $0x802c62,(%esp)
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
  80035f:	e8 1c 26 00 00       	call   802980 <__udivdi3>
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
  8003c7:	e8 e4 26 00 00       	call   802ab0 <__umoddi3>
  8003cc:	89 74 24 04          	mov    %esi,0x4(%esp)
  8003d0:	0f be 80 fb 2c 80 00 	movsbl 0x802cfb(%eax),%eax
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
  8004ba:	ff 24 95 e0 2e 80 00 	jmp    *0x802ee0(,%edx,4)
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
  800577:	8b 14 85 40 30 80 00 	mov    0x803040(,%eax,4),%edx
  80057e:	85 d2                	test   %edx,%edx
  800580:	75 26                	jne    8005a8 <vprintfmt+0x16c>
				printfmt(putch, putdat, "error %d", err);
  800582:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800586:	c7 44 24 08 0c 2d 80 	movl   $0x802d0c,0x8(%esp)
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
  8005ac:	c7 44 24 08 85 31 80 	movl   $0x803185,0x8(%esp)
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
  8005ea:	be 15 2d 80 00       	mov    $0x802d15,%esi
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
  800894:	e8 e7 20 00 00       	call   802980 <__udivdi3>
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
  8008e0:	e8 cb 21 00 00       	call   802ab0 <__umoddi3>
  8008e5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8008e9:	0f be 80 fb 2c 80 00 	movsbl 0x802cfb(%eax),%eax
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
  800995:	c7 44 24 0c 30 2e 80 	movl   $0x802e30,0xc(%esp)
  80099c:	00 
  80099d:	c7 44 24 08 85 31 80 	movl   $0x803185,0x8(%esp)
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
  8009cb:	c7 44 24 0c 68 2e 80 	movl   $0x802e68,0xc(%esp)
  8009d2:	00 
  8009d3:	c7 44 24 08 85 31 80 	movl   $0x803185,0x8(%esp)
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
  800a5f:	e8 4c 20 00 00       	call   802ab0 <__umoddi3>
  800a64:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a68:	0f be 80 fb 2c 80 00 	movsbl 0x802cfb(%eax),%eax
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
  800aa1:	e8 0a 20 00 00       	call   802ab0 <__umoddi3>
  800aa6:	89 74 24 04          	mov    %esi,0x4(%esp)
  800aaa:	0f be 80 fb 2c 80 00 	movsbl 0x802cfb(%eax),%eax
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

0080102b <sys_exec>:
sys_env_set_prior(envid_t envid, uint32_t prior){
         return syscall(SYS_env_set_prior,1,envid, prior, 0, 0, 0);
}

int 
sys_exec(void* vph, uint32_t phnum, uint32_t esp, uint32_t eip){
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
  801038:	b8 10 00 00 00       	mov    $0x10,%eax
  80103d:	8b 7d 14             	mov    0x14(%ebp),%edi
  801040:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801043:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801046:	8b 55 08             	mov    0x8(%ebp),%edx
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
sys_exec(void* vph, uint32_t phnum, uint32_t esp, uint32_t eip){
         return syscall(SYS_exec, 0, (uint32_t)vph, phnum, esp, eip, 0);
}
  801061:	8b 1c 24             	mov    (%esp),%ebx
  801064:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801068:	89 ec                	mov    %ebp,%esp
  80106a:	5d                   	pop    %ebp
  80106b:	c3                   	ret    

0080106c <sys_env_set_prior>:
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}

int 
sys_env_set_prior(envid_t envid, uint32_t prior){
  80106c:	55                   	push   %ebp
  80106d:	89 e5                	mov    %esp,%ebp
  80106f:	83 ec 28             	sub    $0x28,%esp
  801072:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801075:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801078:	bb 00 00 00 00       	mov    $0x0,%ebx
  80107d:	b8 0f 00 00 00       	mov    $0xf,%eax
  801082:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801085:	8b 55 08             	mov    0x8(%ebp),%edx
  801088:	89 df                	mov    %ebx,%edi
  80108a:	51                   	push   %ecx
  80108b:	52                   	push   %edx
  80108c:	53                   	push   %ebx
  80108d:	54                   	push   %esp
  80108e:	55                   	push   %ebp
  80108f:	56                   	push   %esi
  801090:	57                   	push   %edi
  801091:	54                   	push   %esp
  801092:	5d                   	pop    %ebp
  801093:	8d 35 9b 10 80 00    	lea    0x80109b,%esi
  801099:	0f 34                	sysenter 
  80109b:	5f                   	pop    %edi
  80109c:	5e                   	pop    %esi
  80109d:	5d                   	pop    %ebp
  80109e:	5c                   	pop    %esp
  80109f:	5b                   	pop    %ebx
  8010a0:	5a                   	pop    %edx
  8010a1:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8010a2:	85 c0                	test   %eax,%eax
  8010a4:	7e 28                	jle    8010ce <sys_env_set_prior+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010a6:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010aa:	c7 44 24 0c 0f 00 00 	movl   $0xf,0xc(%esp)
  8010b1:	00 
  8010b2:	c7 44 24 08 80 30 80 	movl   $0x803080,0x8(%esp)
  8010b9:	00 
  8010ba:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8010c1:	00 
  8010c2:	c7 04 24 9d 30 80 00 	movl   $0x80309d,(%esp)
  8010c9:	e8 fe f0 ff ff       	call   8001cc <_panic>
}

int 
sys_env_set_prior(envid_t envid, uint32_t prior){
         return syscall(SYS_env_set_prior,1,envid, prior, 0, 0, 0);
}
  8010ce:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8010d1:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8010d4:	89 ec                	mov    %ebp,%esp
  8010d6:	5d                   	pop    %ebp
  8010d7:	c3                   	ret    

008010d8 <sys_sbrk>:
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}

int
sys_sbrk(uint32_t inc)
{
  8010d8:	55                   	push   %ebp
  8010d9:	89 e5                	mov    %esp,%ebp
  8010db:	83 ec 08             	sub    $0x8,%esp
  8010de:	89 1c 24             	mov    %ebx,(%esp)
  8010e1:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8010e5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010ea:	b8 11 00 00 00       	mov    $0x11,%eax
  8010ef:	8b 55 08             	mov    0x8(%ebp),%edx
  8010f2:	89 cb                	mov    %ecx,%ebx
  8010f4:	89 cf                	mov    %ecx,%edi
  8010f6:	51                   	push   %ecx
  8010f7:	52                   	push   %edx
  8010f8:	53                   	push   %ebx
  8010f9:	54                   	push   %esp
  8010fa:	55                   	push   %ebp
  8010fb:	56                   	push   %esi
  8010fc:	57                   	push   %edi
  8010fd:	54                   	push   %esp
  8010fe:	5d                   	pop    %ebp
  8010ff:	8d 35 07 11 80 00    	lea    0x801107,%esi
  801105:	0f 34                	sysenter 
  801107:	5f                   	pop    %edi
  801108:	5e                   	pop    %esi
  801109:	5d                   	pop    %ebp
  80110a:	5c                   	pop    %esp
  80110b:	5b                   	pop    %ebx
  80110c:	5a                   	pop    %edx
  80110d:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  80110e:	8b 1c 24             	mov    (%esp),%ebx
  801111:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801115:	89 ec                	mov    %ebp,%esp
  801117:	5d                   	pop    %ebp
  801118:	c3                   	ret    

00801119 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  801119:	55                   	push   %ebp
  80111a:	89 e5                	mov    %esp,%ebp
  80111c:	83 ec 28             	sub    $0x28,%esp
  80111f:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801122:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801125:	b9 00 00 00 00       	mov    $0x0,%ecx
  80112a:	b8 0e 00 00 00       	mov    $0xe,%eax
  80112f:	8b 55 08             	mov    0x8(%ebp),%edx
  801132:	89 cb                	mov    %ecx,%ebx
  801134:	89 cf                	mov    %ecx,%edi
  801136:	51                   	push   %ecx
  801137:	52                   	push   %edx
  801138:	53                   	push   %ebx
  801139:	54                   	push   %esp
  80113a:	55                   	push   %ebp
  80113b:	56                   	push   %esi
  80113c:	57                   	push   %edi
  80113d:	54                   	push   %esp
  80113e:	5d                   	pop    %ebp
  80113f:	8d 35 47 11 80 00    	lea    0x801147,%esi
  801145:	0f 34                	sysenter 
  801147:	5f                   	pop    %edi
  801148:	5e                   	pop    %esi
  801149:	5d                   	pop    %ebp
  80114a:	5c                   	pop    %esp
  80114b:	5b                   	pop    %ebx
  80114c:	5a                   	pop    %edx
  80114d:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80114e:	85 c0                	test   %eax,%eax
  801150:	7e 28                	jle    80117a <sys_ipc_recv+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  801152:	89 44 24 10          	mov    %eax,0x10(%esp)
  801156:	c7 44 24 0c 0e 00 00 	movl   $0xe,0xc(%esp)
  80115d:	00 
  80115e:	c7 44 24 08 80 30 80 	movl   $0x803080,0x8(%esp)
  801165:	00 
  801166:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80116d:	00 
  80116e:	c7 04 24 9d 30 80 00 	movl   $0x80309d,(%esp)
  801175:	e8 52 f0 ff ff       	call   8001cc <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80117a:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80117d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801180:	89 ec                	mov    %ebp,%esp
  801182:	5d                   	pop    %ebp
  801183:	c3                   	ret    

00801184 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801184:	55                   	push   %ebp
  801185:	89 e5                	mov    %esp,%ebp
  801187:	83 ec 08             	sub    $0x8,%esp
  80118a:	89 1c 24             	mov    %ebx,(%esp)
  80118d:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801191:	b8 0d 00 00 00       	mov    $0xd,%eax
  801196:	8b 7d 14             	mov    0x14(%ebp),%edi
  801199:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80119c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80119f:	8b 55 08             	mov    0x8(%ebp),%edx
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

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8011ba:	8b 1c 24             	mov    (%esp),%ebx
  8011bd:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8011c1:	89 ec                	mov    %ebp,%esp
  8011c3:	5d                   	pop    %ebp
  8011c4:	c3                   	ret    

008011c5 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8011c5:	55                   	push   %ebp
  8011c6:	89 e5                	mov    %esp,%ebp
  8011c8:	83 ec 28             	sub    $0x28,%esp
  8011cb:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8011ce:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8011d1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011d6:	b8 0b 00 00 00       	mov    $0xb,%eax
  8011db:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011de:	8b 55 08             	mov    0x8(%ebp),%edx
  8011e1:	89 df                	mov    %ebx,%edi
  8011e3:	51                   	push   %ecx
  8011e4:	52                   	push   %edx
  8011e5:	53                   	push   %ebx
  8011e6:	54                   	push   %esp
  8011e7:	55                   	push   %ebp
  8011e8:	56                   	push   %esi
  8011e9:	57                   	push   %edi
  8011ea:	54                   	push   %esp
  8011eb:	5d                   	pop    %ebp
  8011ec:	8d 35 f4 11 80 00    	lea    0x8011f4,%esi
  8011f2:	0f 34                	sysenter 
  8011f4:	5f                   	pop    %edi
  8011f5:	5e                   	pop    %esi
  8011f6:	5d                   	pop    %ebp
  8011f7:	5c                   	pop    %esp
  8011f8:	5b                   	pop    %ebx
  8011f9:	5a                   	pop    %edx
  8011fa:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8011fb:	85 c0                	test   %eax,%eax
  8011fd:	7e 28                	jle    801227 <sys_env_set_pgfault_upcall+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011ff:	89 44 24 10          	mov    %eax,0x10(%esp)
  801203:	c7 44 24 0c 0b 00 00 	movl   $0xb,0xc(%esp)
  80120a:	00 
  80120b:	c7 44 24 08 80 30 80 	movl   $0x803080,0x8(%esp)
  801212:	00 
  801213:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80121a:	00 
  80121b:	c7 04 24 9d 30 80 00 	movl   $0x80309d,(%esp)
  801222:	e8 a5 ef ff ff       	call   8001cc <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801227:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80122a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80122d:	89 ec                	mov    %ebp,%esp
  80122f:	5d                   	pop    %ebp
  801230:	c3                   	ret    

00801231 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801231:	55                   	push   %ebp
  801232:	89 e5                	mov    %esp,%ebp
  801234:	83 ec 28             	sub    $0x28,%esp
  801237:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80123a:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80123d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801242:	b8 0a 00 00 00       	mov    $0xa,%eax
  801247:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80124a:	8b 55 08             	mov    0x8(%ebp),%edx
  80124d:	89 df                	mov    %ebx,%edi
  80124f:	51                   	push   %ecx
  801250:	52                   	push   %edx
  801251:	53                   	push   %ebx
  801252:	54                   	push   %esp
  801253:	55                   	push   %ebp
  801254:	56                   	push   %esi
  801255:	57                   	push   %edi
  801256:	54                   	push   %esp
  801257:	5d                   	pop    %ebp
  801258:	8d 35 60 12 80 00    	lea    0x801260,%esi
  80125e:	0f 34                	sysenter 
  801260:	5f                   	pop    %edi
  801261:	5e                   	pop    %esi
  801262:	5d                   	pop    %ebp
  801263:	5c                   	pop    %esp
  801264:	5b                   	pop    %ebx
  801265:	5a                   	pop    %edx
  801266:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801267:	85 c0                	test   %eax,%eax
  801269:	7e 28                	jle    801293 <sys_env_set_trapframe+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  80126b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80126f:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  801276:	00 
  801277:	c7 44 24 08 80 30 80 	movl   $0x803080,0x8(%esp)
  80127e:	00 
  80127f:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801286:	00 
  801287:	c7 04 24 9d 30 80 00 	movl   $0x80309d,(%esp)
  80128e:	e8 39 ef ff ff       	call   8001cc <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801293:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801296:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801299:	89 ec                	mov    %ebp,%esp
  80129b:	5d                   	pop    %ebp
  80129c:	c3                   	ret    

0080129d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80129d:	55                   	push   %ebp
  80129e:	89 e5                	mov    %esp,%ebp
  8012a0:	83 ec 28             	sub    $0x28,%esp
  8012a3:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8012a6:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8012a9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012ae:	b8 09 00 00 00       	mov    $0x9,%eax
  8012b3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012b6:	8b 55 08             	mov    0x8(%ebp),%edx
  8012b9:	89 df                	mov    %ebx,%edi
  8012bb:	51                   	push   %ecx
  8012bc:	52                   	push   %edx
  8012bd:	53                   	push   %ebx
  8012be:	54                   	push   %esp
  8012bf:	55                   	push   %ebp
  8012c0:	56                   	push   %esi
  8012c1:	57                   	push   %edi
  8012c2:	54                   	push   %esp
  8012c3:	5d                   	pop    %ebp
  8012c4:	8d 35 cc 12 80 00    	lea    0x8012cc,%esi
  8012ca:	0f 34                	sysenter 
  8012cc:	5f                   	pop    %edi
  8012cd:	5e                   	pop    %esi
  8012ce:	5d                   	pop    %ebp
  8012cf:	5c                   	pop    %esp
  8012d0:	5b                   	pop    %ebx
  8012d1:	5a                   	pop    %edx
  8012d2:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8012d3:	85 c0                	test   %eax,%eax
  8012d5:	7e 28                	jle    8012ff <sys_env_set_status+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012d7:	89 44 24 10          	mov    %eax,0x10(%esp)
  8012db:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8012e2:	00 
  8012e3:	c7 44 24 08 80 30 80 	movl   $0x803080,0x8(%esp)
  8012ea:	00 
  8012eb:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8012f2:	00 
  8012f3:	c7 04 24 9d 30 80 00 	movl   $0x80309d,(%esp)
  8012fa:	e8 cd ee ff ff       	call   8001cc <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8012ff:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801302:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801305:	89 ec                	mov    %ebp,%esp
  801307:	5d                   	pop    %ebp
  801308:	c3                   	ret    

00801309 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  801309:	55                   	push   %ebp
  80130a:	89 e5                	mov    %esp,%ebp
  80130c:	83 ec 28             	sub    $0x28,%esp
  80130f:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801312:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801315:	bb 00 00 00 00       	mov    $0x0,%ebx
  80131a:	b8 07 00 00 00       	mov    $0x7,%eax
  80131f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801322:	8b 55 08             	mov    0x8(%ebp),%edx
  801325:	89 df                	mov    %ebx,%edi
  801327:	51                   	push   %ecx
  801328:	52                   	push   %edx
  801329:	53                   	push   %ebx
  80132a:	54                   	push   %esp
  80132b:	55                   	push   %ebp
  80132c:	56                   	push   %esi
  80132d:	57                   	push   %edi
  80132e:	54                   	push   %esp
  80132f:	5d                   	pop    %ebp
  801330:	8d 35 38 13 80 00    	lea    0x801338,%esi
  801336:	0f 34                	sysenter 
  801338:	5f                   	pop    %edi
  801339:	5e                   	pop    %esi
  80133a:	5d                   	pop    %ebp
  80133b:	5c                   	pop    %esp
  80133c:	5b                   	pop    %ebx
  80133d:	5a                   	pop    %edx
  80133e:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80133f:	85 c0                	test   %eax,%eax
  801341:	7e 28                	jle    80136b <sys_page_unmap+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  801343:	89 44 24 10          	mov    %eax,0x10(%esp)
  801347:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80134e:	00 
  80134f:	c7 44 24 08 80 30 80 	movl   $0x803080,0x8(%esp)
  801356:	00 
  801357:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80135e:	00 
  80135f:	c7 04 24 9d 30 80 00 	movl   $0x80309d,(%esp)
  801366:	e8 61 ee ff ff       	call   8001cc <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80136b:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80136e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801371:	89 ec                	mov    %ebp,%esp
  801373:	5d                   	pop    %ebp
  801374:	c3                   	ret    

00801375 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  801375:	55                   	push   %ebp
  801376:	89 e5                	mov    %esp,%ebp
  801378:	83 ec 28             	sub    $0x28,%esp
  80137b:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80137e:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801381:	8b 7d 18             	mov    0x18(%ebp),%edi
  801384:	0b 7d 14             	or     0x14(%ebp),%edi
  801387:	b8 06 00 00 00       	mov    $0x6,%eax
  80138c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80138f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801392:	8b 55 08             	mov    0x8(%ebp),%edx
  801395:	51                   	push   %ecx
  801396:	52                   	push   %edx
  801397:	53                   	push   %ebx
  801398:	54                   	push   %esp
  801399:	55                   	push   %ebp
  80139a:	56                   	push   %esi
  80139b:	57                   	push   %edi
  80139c:	54                   	push   %esp
  80139d:	5d                   	pop    %ebp
  80139e:	8d 35 a6 13 80 00    	lea    0x8013a6,%esi
  8013a4:	0f 34                	sysenter 
  8013a6:	5f                   	pop    %edi
  8013a7:	5e                   	pop    %esi
  8013a8:	5d                   	pop    %ebp
  8013a9:	5c                   	pop    %esp
  8013aa:	5b                   	pop    %ebx
  8013ab:	5a                   	pop    %edx
  8013ac:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8013ad:	85 c0                	test   %eax,%eax
  8013af:	7e 28                	jle    8013d9 <sys_page_map+0x64>
		panic("syscall %d returned %d (> 0)", num, ret);
  8013b1:	89 44 24 10          	mov    %eax,0x10(%esp)
  8013b5:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  8013bc:	00 
  8013bd:	c7 44 24 08 80 30 80 	movl   $0x803080,0x8(%esp)
  8013c4:	00 
  8013c5:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8013cc:	00 
  8013cd:	c7 04 24 9d 30 80 00 	movl   $0x80309d,(%esp)
  8013d4:	e8 f3 ed ff ff       	call   8001cc <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}
  8013d9:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8013dc:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8013df:	89 ec                	mov    %ebp,%esp
  8013e1:	5d                   	pop    %ebp
  8013e2:	c3                   	ret    

008013e3 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8013e3:	55                   	push   %ebp
  8013e4:	89 e5                	mov    %esp,%ebp
  8013e6:	83 ec 28             	sub    $0x28,%esp
  8013e9:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8013ec:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8013ef:	bf 00 00 00 00       	mov    $0x0,%edi
  8013f4:	b8 05 00 00 00       	mov    $0x5,%eax
  8013f9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8013fc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013ff:	8b 55 08             	mov    0x8(%ebp),%edx
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
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80141a:	85 c0                	test   %eax,%eax
  80141c:	7e 28                	jle    801446 <sys_page_alloc+0x63>
		panic("syscall %d returned %d (> 0)", num, ret);
  80141e:	89 44 24 10          	mov    %eax,0x10(%esp)
  801422:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  801429:	00 
  80142a:	c7 44 24 08 80 30 80 	movl   $0x803080,0x8(%esp)
  801431:	00 
  801432:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801439:	00 
  80143a:	c7 04 24 9d 30 80 00 	movl   $0x80309d,(%esp)
  801441:	e8 86 ed ff ff       	call   8001cc <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  801446:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801449:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80144c:	89 ec                	mov    %ebp,%esp
  80144e:	5d                   	pop    %ebp
  80144f:	c3                   	ret    

00801450 <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
{
  801450:	55                   	push   %ebp
  801451:	89 e5                	mov    %esp,%ebp
  801453:	83 ec 08             	sub    $0x8,%esp
  801456:	89 1c 24             	mov    %ebx,(%esp)
  801459:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80145d:	ba 00 00 00 00       	mov    $0x0,%edx
  801462:	b8 0c 00 00 00       	mov    $0xc,%eax
  801467:	89 d1                	mov    %edx,%ecx
  801469:	89 d3                	mov    %edx,%ebx
  80146b:	89 d7                	mov    %edx,%edi
  80146d:	51                   	push   %ecx
  80146e:	52                   	push   %edx
  80146f:	53                   	push   %ebx
  801470:	54                   	push   %esp
  801471:	55                   	push   %ebp
  801472:	56                   	push   %esi
  801473:	57                   	push   %edi
  801474:	54                   	push   %esp
  801475:	5d                   	pop    %ebp
  801476:	8d 35 7e 14 80 00    	lea    0x80147e,%esi
  80147c:	0f 34                	sysenter 
  80147e:	5f                   	pop    %edi
  80147f:	5e                   	pop    %esi
  801480:	5d                   	pop    %ebp
  801481:	5c                   	pop    %esp
  801482:	5b                   	pop    %ebx
  801483:	5a                   	pop    %edx
  801484:	59                   	pop    %ecx

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  801485:	8b 1c 24             	mov    (%esp),%ebx
  801488:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80148c:	89 ec                	mov    %ebp,%esp
  80148e:	5d                   	pop    %ebp
  80148f:	c3                   	ret    

00801490 <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
{
  801490:	55                   	push   %ebp
  801491:	89 e5                	mov    %esp,%ebp
  801493:	83 ec 08             	sub    $0x8,%esp
  801496:	89 1c 24             	mov    %ebx,(%esp)
  801499:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80149d:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014a2:	b8 04 00 00 00       	mov    $0x4,%eax
  8014a7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014aa:	8b 55 08             	mov    0x8(%ebp),%edx
  8014ad:	89 df                	mov    %ebx,%edi
  8014af:	51                   	push   %ecx
  8014b0:	52                   	push   %edx
  8014b1:	53                   	push   %ebx
  8014b2:	54                   	push   %esp
  8014b3:	55                   	push   %ebp
  8014b4:	56                   	push   %esi
  8014b5:	57                   	push   %edi
  8014b6:	54                   	push   %esp
  8014b7:	5d                   	pop    %ebp
  8014b8:	8d 35 c0 14 80 00    	lea    0x8014c0,%esi
  8014be:	0f 34                	sysenter 
  8014c0:	5f                   	pop    %edi
  8014c1:	5e                   	pop    %esi
  8014c2:	5d                   	pop    %ebp
  8014c3:	5c                   	pop    %esp
  8014c4:	5b                   	pop    %ebx
  8014c5:	5a                   	pop    %edx
  8014c6:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  8014c7:	8b 1c 24             	mov    (%esp),%ebx
  8014ca:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8014ce:	89 ec                	mov    %ebp,%esp
  8014d0:	5d                   	pop    %ebp
  8014d1:	c3                   	ret    

008014d2 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  8014d2:	55                   	push   %ebp
  8014d3:	89 e5                	mov    %esp,%ebp
  8014d5:	83 ec 08             	sub    $0x8,%esp
  8014d8:	89 1c 24             	mov    %ebx,(%esp)
  8014db:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8014df:	ba 00 00 00 00       	mov    $0x0,%edx
  8014e4:	b8 02 00 00 00       	mov    $0x2,%eax
  8014e9:	89 d1                	mov    %edx,%ecx
  8014eb:	89 d3                	mov    %edx,%ebx
  8014ed:	89 d7                	mov    %edx,%edi
  8014ef:	51                   	push   %ecx
  8014f0:	52                   	push   %edx
  8014f1:	53                   	push   %ebx
  8014f2:	54                   	push   %esp
  8014f3:	55                   	push   %ebp
  8014f4:	56                   	push   %esi
  8014f5:	57                   	push   %edi
  8014f6:	54                   	push   %esp
  8014f7:	5d                   	pop    %ebp
  8014f8:	8d 35 00 15 80 00    	lea    0x801500,%esi
  8014fe:	0f 34                	sysenter 
  801500:	5f                   	pop    %edi
  801501:	5e                   	pop    %esi
  801502:	5d                   	pop    %ebp
  801503:	5c                   	pop    %esp
  801504:	5b                   	pop    %ebx
  801505:	5a                   	pop    %edx
  801506:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  801507:	8b 1c 24             	mov    (%esp),%ebx
  80150a:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80150e:	89 ec                	mov    %ebp,%esp
  801510:	5d                   	pop    %ebp
  801511:	c3                   	ret    

00801512 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  801512:	55                   	push   %ebp
  801513:	89 e5                	mov    %esp,%ebp
  801515:	83 ec 28             	sub    $0x28,%esp
  801518:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80151b:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80151e:	b9 00 00 00 00       	mov    $0x0,%ecx
  801523:	b8 03 00 00 00       	mov    $0x3,%eax
  801528:	8b 55 08             	mov    0x8(%ebp),%edx
  80152b:	89 cb                	mov    %ecx,%ebx
  80152d:	89 cf                	mov    %ecx,%edi
  80152f:	51                   	push   %ecx
  801530:	52                   	push   %edx
  801531:	53                   	push   %ebx
  801532:	54                   	push   %esp
  801533:	55                   	push   %ebp
  801534:	56                   	push   %esi
  801535:	57                   	push   %edi
  801536:	54                   	push   %esp
  801537:	5d                   	pop    %ebp
  801538:	8d 35 40 15 80 00    	lea    0x801540,%esi
  80153e:	0f 34                	sysenter 
  801540:	5f                   	pop    %edi
  801541:	5e                   	pop    %esi
  801542:	5d                   	pop    %ebp
  801543:	5c                   	pop    %esp
  801544:	5b                   	pop    %ebx
  801545:	5a                   	pop    %edx
  801546:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801547:	85 c0                	test   %eax,%eax
  801549:	7e 28                	jle    801573 <sys_env_destroy+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  80154b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80154f:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  801556:	00 
  801557:	c7 44 24 08 80 30 80 	movl   $0x803080,0x8(%esp)
  80155e:	00 
  80155f:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801566:	00 
  801567:	c7 04 24 9d 30 80 00 	movl   $0x80309d,(%esp)
  80156e:	e8 59 ec ff ff       	call   8001cc <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801573:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801576:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801579:	89 ec                	mov    %ebp,%esp
  80157b:	5d                   	pop    %ebp
  80157c:	c3                   	ret    
  80157d:	00 00                	add    %al,(%eax)
	...

00801580 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801580:	55                   	push   %ebp
  801581:	89 e5                	mov    %esp,%ebp
  801583:	8b 45 08             	mov    0x8(%ebp),%eax
  801586:	05 00 00 00 30       	add    $0x30000000,%eax
  80158b:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  80158e:	5d                   	pop    %ebp
  80158f:	c3                   	ret    

00801590 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801590:	55                   	push   %ebp
  801591:	89 e5                	mov    %esp,%ebp
  801593:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801596:	8b 45 08             	mov    0x8(%ebp),%eax
  801599:	89 04 24             	mov    %eax,(%esp)
  80159c:	e8 df ff ff ff       	call   801580 <fd2num>
  8015a1:	05 20 00 0d 00       	add    $0xd0020,%eax
  8015a6:	c1 e0 0c             	shl    $0xc,%eax
}
  8015a9:	c9                   	leave  
  8015aa:	c3                   	ret    

008015ab <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8015ab:	55                   	push   %ebp
  8015ac:	89 e5                	mov    %esp,%ebp
  8015ae:	57                   	push   %edi
  8015af:	56                   	push   %esi
  8015b0:	53                   	push   %ebx
  8015b1:	8b 7d 08             	mov    0x8(%ebp),%edi
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  8015b4:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  8015b9:	a8 01                	test   $0x1,%al
  8015bb:	74 36                	je     8015f3 <fd_alloc+0x48>
  8015bd:	a1 00 00 74 ef       	mov    0xef740000,%eax
  8015c2:	a8 01                	test   $0x1,%al
  8015c4:	74 2d                	je     8015f3 <fd_alloc+0x48>
  8015c6:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  8015cb:	b9 00 d0 7b ef       	mov    $0xef7bd000,%ecx
  8015d0:	be 00 00 40 ef       	mov    $0xef400000,%esi
  8015d5:	89 c3                	mov    %eax,%ebx
  8015d7:	89 c2                	mov    %eax,%edx
  8015d9:	c1 ea 16             	shr    $0x16,%edx
  8015dc:	8b 14 91             	mov    (%ecx,%edx,4),%edx
  8015df:	f6 c2 01             	test   $0x1,%dl
  8015e2:	74 14                	je     8015f8 <fd_alloc+0x4d>
  8015e4:	89 c2                	mov    %eax,%edx
  8015e6:	c1 ea 0c             	shr    $0xc,%edx
  8015e9:	8b 14 96             	mov    (%esi,%edx,4),%edx
  8015ec:	f6 c2 01             	test   $0x1,%dl
  8015ef:	75 10                	jne    801601 <fd_alloc+0x56>
  8015f1:	eb 05                	jmp    8015f8 <fd_alloc+0x4d>
  8015f3:	bb 00 00 00 d0       	mov    $0xd0000000,%ebx
			*fd_store = fd;
  8015f8:	89 1f                	mov    %ebx,(%edi)
  8015fa:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  8015ff:	eb 17                	jmp    801618 <fd_alloc+0x6d>
  801601:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801606:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80160b:	75 c8                	jne    8015d5 <fd_alloc+0x2a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80160d:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  801613:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  801618:	5b                   	pop    %ebx
  801619:	5e                   	pop    %esi
  80161a:	5f                   	pop    %edi
  80161b:	5d                   	pop    %ebp
  80161c:	c3                   	ret    

0080161d <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80161d:	55                   	push   %ebp
  80161e:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801620:	8b 45 08             	mov    0x8(%ebp),%eax
  801623:	83 f8 1f             	cmp    $0x1f,%eax
  801626:	77 36                	ja     80165e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801628:	05 00 00 0d 00       	add    $0xd0000,%eax
  80162d:	c1 e0 0c             	shl    $0xc,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
  801630:	89 c2                	mov    %eax,%edx
  801632:	c1 ea 16             	shr    $0x16,%edx
  801635:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80163c:	f6 c2 01             	test   $0x1,%dl
  80163f:	74 1d                	je     80165e <fd_lookup+0x41>
  801641:	89 c2                	mov    %eax,%edx
  801643:	c1 ea 0c             	shr    $0xc,%edx
  801646:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80164d:	f6 c2 01             	test   $0x1,%dl
  801650:	74 0c                	je     80165e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  801652:	8b 55 0c             	mov    0xc(%ebp),%edx
  801655:	89 02                	mov    %eax,(%edx)
  801657:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
  80165c:	eb 05                	jmp    801663 <fd_lookup+0x46>
  80165e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801663:	5d                   	pop    %ebp
  801664:	c3                   	ret    

00801665 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  801665:	55                   	push   %ebp
  801666:	89 e5                	mov    %esp,%ebp
  801668:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80166b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80166e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801672:	8b 45 08             	mov    0x8(%ebp),%eax
  801675:	89 04 24             	mov    %eax,(%esp)
  801678:	e8 a0 ff ff ff       	call   80161d <fd_lookup>
  80167d:	85 c0                	test   %eax,%eax
  80167f:	78 0e                	js     80168f <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801681:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801684:	8b 55 0c             	mov    0xc(%ebp),%edx
  801687:	89 50 04             	mov    %edx,0x4(%eax)
  80168a:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  80168f:	c9                   	leave  
  801690:	c3                   	ret    

00801691 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801691:	55                   	push   %ebp
  801692:	89 e5                	mov    %esp,%ebp
  801694:	56                   	push   %esi
  801695:	53                   	push   %ebx
  801696:	83 ec 10             	sub    $0x10,%esp
  801699:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80169c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
// File functions
// --------------------------------------------------------------

static struct Dev *devtab[] =
{
	&devfile,
  80169f:	b8 04 40 80 00       	mov    $0x804004,%eax
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  8016a4:	ba 00 00 00 00       	mov    $0x0,%edx

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8016a9:	be 28 31 80 00       	mov    $0x803128,%esi
		if (devtab[i]->dev_id == dev_id) {
  8016ae:	39 08                	cmp    %ecx,(%eax)
  8016b0:	75 10                	jne    8016c2 <dev_lookup+0x31>
  8016b2:	eb 04                	jmp    8016b8 <dev_lookup+0x27>
  8016b4:	39 08                	cmp    %ecx,(%eax)
  8016b6:	75 0a                	jne    8016c2 <dev_lookup+0x31>
			*dev = devtab[i];
  8016b8:	89 03                	mov    %eax,(%ebx)
  8016ba:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  8016bf:	90                   	nop
  8016c0:	eb 31                	jmp    8016f3 <dev_lookup+0x62>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8016c2:	83 c2 01             	add    $0x1,%edx
  8016c5:	8b 04 96             	mov    (%esi,%edx,4),%eax
  8016c8:	85 c0                	test   %eax,%eax
  8016ca:	75 e8                	jne    8016b4 <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8016cc:	a1 04 50 80 00       	mov    0x805004,%eax
  8016d1:	8b 40 48             	mov    0x48(%eax),%eax
  8016d4:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8016d8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016dc:	c7 04 24 ac 30 80 00 	movl   $0x8030ac,(%esp)
  8016e3:	e8 9d eb ff ff       	call   800285 <cprintf>
	*dev = 0;
  8016e8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8016ee:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  8016f3:	83 c4 10             	add    $0x10,%esp
  8016f6:	5b                   	pop    %ebx
  8016f7:	5e                   	pop    %esi
  8016f8:	5d                   	pop    %ebp
  8016f9:	c3                   	ret    

008016fa <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  8016fa:	55                   	push   %ebp
  8016fb:	89 e5                	mov    %esp,%ebp
  8016fd:	53                   	push   %ebx
  8016fe:	83 ec 24             	sub    $0x24,%esp
  801701:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801704:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801707:	89 44 24 04          	mov    %eax,0x4(%esp)
  80170b:	8b 45 08             	mov    0x8(%ebp),%eax
  80170e:	89 04 24             	mov    %eax,(%esp)
  801711:	e8 07 ff ff ff       	call   80161d <fd_lookup>
  801716:	85 c0                	test   %eax,%eax
  801718:	78 53                	js     80176d <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80171a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80171d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801721:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801724:	8b 00                	mov    (%eax),%eax
  801726:	89 04 24             	mov    %eax,(%esp)
  801729:	e8 63 ff ff ff       	call   801691 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80172e:	85 c0                	test   %eax,%eax
  801730:	78 3b                	js     80176d <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  801732:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801737:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80173a:	83 7a 14 00          	cmpl   $0x0,0x14(%edx)
  80173e:	74 2d                	je     80176d <fstat+0x73>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801740:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801743:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80174a:	00 00 00 
	stat->st_isdir = 0;
  80174d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801754:	00 00 00 
	stat->st_dev = dev;
  801757:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80175a:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801760:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801764:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801767:	89 14 24             	mov    %edx,(%esp)
  80176a:	ff 50 14             	call   *0x14(%eax)
}
  80176d:	83 c4 24             	add    $0x24,%esp
  801770:	5b                   	pop    %ebx
  801771:	5d                   	pop    %ebp
  801772:	c3                   	ret    

00801773 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  801773:	55                   	push   %ebp
  801774:	89 e5                	mov    %esp,%ebp
  801776:	53                   	push   %ebx
  801777:	83 ec 24             	sub    $0x24,%esp
  80177a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80177d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801780:	89 44 24 04          	mov    %eax,0x4(%esp)
  801784:	89 1c 24             	mov    %ebx,(%esp)
  801787:	e8 91 fe ff ff       	call   80161d <fd_lookup>
  80178c:	85 c0                	test   %eax,%eax
  80178e:	78 5f                	js     8017ef <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801790:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801793:	89 44 24 04          	mov    %eax,0x4(%esp)
  801797:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80179a:	8b 00                	mov    (%eax),%eax
  80179c:	89 04 24             	mov    %eax,(%esp)
  80179f:	e8 ed fe ff ff       	call   801691 <dev_lookup>
ftruncate(int fdnum, off_t newsize)
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017a4:	85 c0                	test   %eax,%eax
  8017a6:	78 47                	js     8017ef <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8017a8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8017ab:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  8017af:	75 23                	jne    8017d4 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8017b1:	a1 04 50 80 00       	mov    0x805004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8017b6:	8b 40 48             	mov    0x48(%eax),%eax
  8017b9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8017bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017c1:	c7 04 24 cc 30 80 00 	movl   $0x8030cc,(%esp)
  8017c8:	e8 b8 ea ff ff       	call   800285 <cprintf>
  8017cd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8017d2:	eb 1b                	jmp    8017ef <ftruncate+0x7c>
	}
	if (!dev->dev_trunc)
  8017d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017d7:	8b 48 18             	mov    0x18(%eax),%ecx
  8017da:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8017df:	85 c9                	test   %ecx,%ecx
  8017e1:	74 0c                	je     8017ef <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8017e3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017e6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017ea:	89 14 24             	mov    %edx,(%esp)
  8017ed:	ff d1                	call   *%ecx
}
  8017ef:	83 c4 24             	add    $0x24,%esp
  8017f2:	5b                   	pop    %ebx
  8017f3:	5d                   	pop    %ebp
  8017f4:	c3                   	ret    

008017f5 <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8017f5:	55                   	push   %ebp
  8017f6:	89 e5                	mov    %esp,%ebp
  8017f8:	53                   	push   %ebx
  8017f9:	83 ec 24             	sub    $0x24,%esp
  8017fc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017ff:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801802:	89 44 24 04          	mov    %eax,0x4(%esp)
  801806:	89 1c 24             	mov    %ebx,(%esp)
  801809:	e8 0f fe ff ff       	call   80161d <fd_lookup>
  80180e:	85 c0                	test   %eax,%eax
  801810:	78 66                	js     801878 <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801812:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801815:	89 44 24 04          	mov    %eax,0x4(%esp)
  801819:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80181c:	8b 00                	mov    (%eax),%eax
  80181e:	89 04 24             	mov    %eax,(%esp)
  801821:	e8 6b fe ff ff       	call   801691 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801826:	85 c0                	test   %eax,%eax
  801828:	78 4e                	js     801878 <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80182a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80182d:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  801831:	75 23                	jne    801856 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801833:	a1 04 50 80 00       	mov    0x805004,%eax
  801838:	8b 40 48             	mov    0x48(%eax),%eax
  80183b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80183f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801843:	c7 04 24 ed 30 80 00 	movl   $0x8030ed,(%esp)
  80184a:	e8 36 ea ff ff       	call   800285 <cprintf>
  80184f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801854:	eb 22                	jmp    801878 <write+0x83>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801856:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801859:	8b 48 0c             	mov    0xc(%eax),%ecx
  80185c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801861:	85 c9                	test   %ecx,%ecx
  801863:	74 13                	je     801878 <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801865:	8b 45 10             	mov    0x10(%ebp),%eax
  801868:	89 44 24 08          	mov    %eax,0x8(%esp)
  80186c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80186f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801873:	89 14 24             	mov    %edx,(%esp)
  801876:	ff d1                	call   *%ecx
}
  801878:	83 c4 24             	add    $0x24,%esp
  80187b:	5b                   	pop    %ebx
  80187c:	5d                   	pop    %ebp
  80187d:	c3                   	ret    

0080187e <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80187e:	55                   	push   %ebp
  80187f:	89 e5                	mov    %esp,%ebp
  801881:	53                   	push   %ebx
  801882:	83 ec 24             	sub    $0x24,%esp
  801885:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801888:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80188b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80188f:	89 1c 24             	mov    %ebx,(%esp)
  801892:	e8 86 fd ff ff       	call   80161d <fd_lookup>
  801897:	85 c0                	test   %eax,%eax
  801899:	78 6b                	js     801906 <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80189b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80189e:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018a5:	8b 00                	mov    (%eax),%eax
  8018a7:	89 04 24             	mov    %eax,(%esp)
  8018aa:	e8 e2 fd ff ff       	call   801691 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018af:	85 c0                	test   %eax,%eax
  8018b1:	78 53                	js     801906 <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8018b3:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8018b6:	8b 42 08             	mov    0x8(%edx),%eax
  8018b9:	83 e0 03             	and    $0x3,%eax
  8018bc:	83 f8 01             	cmp    $0x1,%eax
  8018bf:	75 23                	jne    8018e4 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8018c1:	a1 04 50 80 00       	mov    0x805004,%eax
  8018c6:	8b 40 48             	mov    0x48(%eax),%eax
  8018c9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8018cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018d1:	c7 04 24 0a 31 80 00 	movl   $0x80310a,(%esp)
  8018d8:	e8 a8 e9 ff ff       	call   800285 <cprintf>
  8018dd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  8018e2:	eb 22                	jmp    801906 <read+0x88>
	}
	if (!dev->dev_read)
  8018e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018e7:	8b 48 08             	mov    0x8(%eax),%ecx
  8018ea:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8018ef:	85 c9                	test   %ecx,%ecx
  8018f1:	74 13                	je     801906 <read+0x88>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8018f3:	8b 45 10             	mov    0x10(%ebp),%eax
  8018f6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8018fa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801901:	89 14 24             	mov    %edx,(%esp)
  801904:	ff d1                	call   *%ecx
}
  801906:	83 c4 24             	add    $0x24,%esp
  801909:	5b                   	pop    %ebx
  80190a:	5d                   	pop    %ebp
  80190b:	c3                   	ret    

0080190c <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80190c:	55                   	push   %ebp
  80190d:	89 e5                	mov    %esp,%ebp
  80190f:	57                   	push   %edi
  801910:	56                   	push   %esi
  801911:	53                   	push   %ebx
  801912:	83 ec 1c             	sub    $0x1c,%esp
  801915:	8b 7d 08             	mov    0x8(%ebp),%edi
  801918:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80191b:	ba 00 00 00 00       	mov    $0x0,%edx
  801920:	bb 00 00 00 00       	mov    $0x0,%ebx
  801925:	b8 00 00 00 00       	mov    $0x0,%eax
  80192a:	85 f6                	test   %esi,%esi
  80192c:	74 29                	je     801957 <readn+0x4b>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80192e:	89 f0                	mov    %esi,%eax
  801930:	29 d0                	sub    %edx,%eax
  801932:	89 44 24 08          	mov    %eax,0x8(%esp)
  801936:	03 55 0c             	add    0xc(%ebp),%edx
  801939:	89 54 24 04          	mov    %edx,0x4(%esp)
  80193d:	89 3c 24             	mov    %edi,(%esp)
  801940:	e8 39 ff ff ff       	call   80187e <read>
		if (m < 0)
  801945:	85 c0                	test   %eax,%eax
  801947:	78 0e                	js     801957 <readn+0x4b>
			return m;
		if (m == 0)
  801949:	85 c0                	test   %eax,%eax
  80194b:	74 08                	je     801955 <readn+0x49>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80194d:	01 c3                	add    %eax,%ebx
  80194f:	89 da                	mov    %ebx,%edx
  801951:	39 f3                	cmp    %esi,%ebx
  801953:	72 d9                	jb     80192e <readn+0x22>
  801955:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801957:	83 c4 1c             	add    $0x1c,%esp
  80195a:	5b                   	pop    %ebx
  80195b:	5e                   	pop    %esi
  80195c:	5f                   	pop    %edi
  80195d:	5d                   	pop    %ebp
  80195e:	c3                   	ret    

0080195f <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80195f:	55                   	push   %ebp
  801960:	89 e5                	mov    %esp,%ebp
  801962:	56                   	push   %esi
  801963:	53                   	push   %ebx
  801964:	83 ec 20             	sub    $0x20,%esp
  801967:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80196a:	89 34 24             	mov    %esi,(%esp)
  80196d:	e8 0e fc ff ff       	call   801580 <fd2num>
  801972:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801975:	89 54 24 04          	mov    %edx,0x4(%esp)
  801979:	89 04 24             	mov    %eax,(%esp)
  80197c:	e8 9c fc ff ff       	call   80161d <fd_lookup>
  801981:	89 c3                	mov    %eax,%ebx
  801983:	85 c0                	test   %eax,%eax
  801985:	78 05                	js     80198c <fd_close+0x2d>
  801987:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80198a:	74 0c                	je     801998 <fd_close+0x39>
	    || fd != fd2)
		return (must_exist ? r : 0);
  80198c:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  801990:	19 c0                	sbb    %eax,%eax
  801992:	f7 d0                	not    %eax
  801994:	21 c3                	and    %eax,%ebx
  801996:	eb 3d                	jmp    8019d5 <fd_close+0x76>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801998:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80199b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80199f:	8b 06                	mov    (%esi),%eax
  8019a1:	89 04 24             	mov    %eax,(%esp)
  8019a4:	e8 e8 fc ff ff       	call   801691 <dev_lookup>
  8019a9:	89 c3                	mov    %eax,%ebx
  8019ab:	85 c0                	test   %eax,%eax
  8019ad:	78 16                	js     8019c5 <fd_close+0x66>
		if (dev->dev_close)
  8019af:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019b2:	8b 40 10             	mov    0x10(%eax),%eax
  8019b5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8019ba:	85 c0                	test   %eax,%eax
  8019bc:	74 07                	je     8019c5 <fd_close+0x66>
			r = (*dev->dev_close)(fd);
  8019be:	89 34 24             	mov    %esi,(%esp)
  8019c1:	ff d0                	call   *%eax
  8019c3:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8019c5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8019c9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019d0:	e8 34 f9 ff ff       	call   801309 <sys_page_unmap>
	return r;
}
  8019d5:	89 d8                	mov    %ebx,%eax
  8019d7:	83 c4 20             	add    $0x20,%esp
  8019da:	5b                   	pop    %ebx
  8019db:	5e                   	pop    %esi
  8019dc:	5d                   	pop    %ebp
  8019dd:	c3                   	ret    

008019de <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8019de:	55                   	push   %ebp
  8019df:	89 e5                	mov    %esp,%ebp
  8019e1:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8019e4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019e7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8019ee:	89 04 24             	mov    %eax,(%esp)
  8019f1:	e8 27 fc ff ff       	call   80161d <fd_lookup>
  8019f6:	85 c0                	test   %eax,%eax
  8019f8:	78 13                	js     801a0d <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  8019fa:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801a01:	00 
  801a02:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a05:	89 04 24             	mov    %eax,(%esp)
  801a08:	e8 52 ff ff ff       	call   80195f <fd_close>
}
  801a0d:	c9                   	leave  
  801a0e:	c3                   	ret    

00801a0f <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  801a0f:	55                   	push   %ebp
  801a10:	89 e5                	mov    %esp,%ebp
  801a12:	83 ec 18             	sub    $0x18,%esp
  801a15:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801a18:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801a1b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801a22:	00 
  801a23:	8b 45 08             	mov    0x8(%ebp),%eax
  801a26:	89 04 24             	mov    %eax,(%esp)
  801a29:	e8 79 03 00 00       	call   801da7 <open>
  801a2e:	89 c3                	mov    %eax,%ebx
  801a30:	85 c0                	test   %eax,%eax
  801a32:	78 1b                	js     801a4f <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  801a34:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a37:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a3b:	89 1c 24             	mov    %ebx,(%esp)
  801a3e:	e8 b7 fc ff ff       	call   8016fa <fstat>
  801a43:	89 c6                	mov    %eax,%esi
	close(fd);
  801a45:	89 1c 24             	mov    %ebx,(%esp)
  801a48:	e8 91 ff ff ff       	call   8019de <close>
  801a4d:	89 f3                	mov    %esi,%ebx
	return r;
}
  801a4f:	89 d8                	mov    %ebx,%eax
  801a51:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801a54:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801a57:	89 ec                	mov    %ebp,%esp
  801a59:	5d                   	pop    %ebp
  801a5a:	c3                   	ret    

00801a5b <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  801a5b:	55                   	push   %ebp
  801a5c:	89 e5                	mov    %esp,%ebp
  801a5e:	53                   	push   %ebx
  801a5f:	83 ec 14             	sub    $0x14,%esp
  801a62:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  801a67:	89 1c 24             	mov    %ebx,(%esp)
  801a6a:	e8 6f ff ff ff       	call   8019de <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801a6f:	83 c3 01             	add    $0x1,%ebx
  801a72:	83 fb 20             	cmp    $0x20,%ebx
  801a75:	75 f0                	jne    801a67 <close_all+0xc>
		close(i);
}
  801a77:	83 c4 14             	add    $0x14,%esp
  801a7a:	5b                   	pop    %ebx
  801a7b:	5d                   	pop    %ebp
  801a7c:	c3                   	ret    

00801a7d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801a7d:	55                   	push   %ebp
  801a7e:	89 e5                	mov    %esp,%ebp
  801a80:	83 ec 58             	sub    $0x58,%esp
  801a83:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801a86:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801a89:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801a8c:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801a8f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801a92:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a96:	8b 45 08             	mov    0x8(%ebp),%eax
  801a99:	89 04 24             	mov    %eax,(%esp)
  801a9c:	e8 7c fb ff ff       	call   80161d <fd_lookup>
  801aa1:	89 c3                	mov    %eax,%ebx
  801aa3:	85 c0                	test   %eax,%eax
  801aa5:	0f 88 e0 00 00 00    	js     801b8b <dup+0x10e>
		return r;
	close(newfdnum);
  801aab:	89 3c 24             	mov    %edi,(%esp)
  801aae:	e8 2b ff ff ff       	call   8019de <close>

	newfd = INDEX2FD(newfdnum);
  801ab3:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801ab9:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801abc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801abf:	89 04 24             	mov    %eax,(%esp)
  801ac2:	e8 c9 fa ff ff       	call   801590 <fd2data>
  801ac7:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801ac9:	89 34 24             	mov    %esi,(%esp)
  801acc:	e8 bf fa ff ff       	call   801590 <fd2data>
  801ad1:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
  801ad4:	89 da                	mov    %ebx,%edx
  801ad6:	89 d8                	mov    %ebx,%eax
  801ad8:	c1 e8 16             	shr    $0x16,%eax
  801adb:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801ae2:	a8 01                	test   $0x1,%al
  801ae4:	74 43                	je     801b29 <dup+0xac>
  801ae6:	c1 ea 0c             	shr    $0xc,%edx
  801ae9:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801af0:	a8 01                	test   $0x1,%al
  801af2:	74 35                	je     801b29 <dup+0xac>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801af4:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801afb:	25 07 0e 00 00       	and    $0xe07,%eax
  801b00:	89 44 24 10          	mov    %eax,0x10(%esp)
  801b04:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801b07:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801b0b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801b12:	00 
  801b13:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801b17:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b1e:	e8 52 f8 ff ff       	call   801375 <sys_page_map>
  801b23:	89 c3                	mov    %eax,%ebx
  801b25:	85 c0                	test   %eax,%eax
  801b27:	78 3f                	js     801b68 <dup+0xeb>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801b29:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b2c:	89 c2                	mov    %eax,%edx
  801b2e:	c1 ea 0c             	shr    $0xc,%edx
  801b31:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801b38:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801b3e:	89 54 24 10          	mov    %edx,0x10(%esp)
  801b42:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801b46:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801b4d:	00 
  801b4e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b52:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b59:	e8 17 f8 ff ff       	call   801375 <sys_page_map>
  801b5e:	89 c3                	mov    %eax,%ebx
  801b60:	85 c0                	test   %eax,%eax
  801b62:	78 04                	js     801b68 <dup+0xeb>
  801b64:	89 fb                	mov    %edi,%ebx
  801b66:	eb 23                	jmp    801b8b <dup+0x10e>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801b68:	89 74 24 04          	mov    %esi,0x4(%esp)
  801b6c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b73:	e8 91 f7 ff ff       	call   801309 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801b78:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801b7b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b7f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b86:	e8 7e f7 ff ff       	call   801309 <sys_page_unmap>
	return r;
}
  801b8b:	89 d8                	mov    %ebx,%eax
  801b8d:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801b90:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801b93:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801b96:	89 ec                	mov    %ebp,%esp
  801b98:	5d                   	pop    %ebp
  801b99:	c3                   	ret    
	...

00801b9c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801b9c:	55                   	push   %ebp
  801b9d:	89 e5                	mov    %esp,%ebp
  801b9f:	83 ec 18             	sub    $0x18,%esp
  801ba2:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801ba5:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801ba8:	89 c3                	mov    %eax,%ebx
  801baa:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801bac:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  801bb3:	75 11                	jne    801bc6 <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801bb5:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801bbc:	e8 7f 0c 00 00       	call   802840 <ipc_find_env>
  801bc1:	a3 00 50 80 00       	mov    %eax,0x805000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801bc6:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801bcd:	00 
  801bce:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  801bd5:	00 
  801bd6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801bda:	a1 00 50 80 00       	mov    0x805000,%eax
  801bdf:	89 04 24             	mov    %eax,(%esp)
  801be2:	e8 a4 0c 00 00       	call   80288b <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801be7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801bee:	00 
  801bef:	89 74 24 04          	mov    %esi,0x4(%esp)
  801bf3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801bfa:	e8 0a 0d 00 00       	call   802909 <ipc_recv>
}
  801bff:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801c02:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801c05:	89 ec                	mov    %ebp,%esp
  801c07:	5d                   	pop    %ebp
  801c08:	c3                   	ret    

00801c09 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801c09:	55                   	push   %ebp
  801c0a:	89 e5                	mov    %esp,%ebp
  801c0c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801c0f:	8b 45 08             	mov    0x8(%ebp),%eax
  801c12:	8b 40 0c             	mov    0xc(%eax),%eax
  801c15:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  801c1a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c1d:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801c22:	ba 00 00 00 00       	mov    $0x0,%edx
  801c27:	b8 02 00 00 00       	mov    $0x2,%eax
  801c2c:	e8 6b ff ff ff       	call   801b9c <fsipc>
}
  801c31:	c9                   	leave  
  801c32:	c3                   	ret    

00801c33 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801c33:	55                   	push   %ebp
  801c34:	89 e5                	mov    %esp,%ebp
  801c36:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801c39:	8b 45 08             	mov    0x8(%ebp),%eax
  801c3c:	8b 40 0c             	mov    0xc(%eax),%eax
  801c3f:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801c44:	ba 00 00 00 00       	mov    $0x0,%edx
  801c49:	b8 06 00 00 00       	mov    $0x6,%eax
  801c4e:	e8 49 ff ff ff       	call   801b9c <fsipc>
}
  801c53:	c9                   	leave  
  801c54:	c3                   	ret    

00801c55 <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  801c55:	55                   	push   %ebp
  801c56:	89 e5                	mov    %esp,%ebp
  801c58:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801c5b:	ba 00 00 00 00       	mov    $0x0,%edx
  801c60:	b8 08 00 00 00       	mov    $0x8,%eax
  801c65:	e8 32 ff ff ff       	call   801b9c <fsipc>
}
  801c6a:	c9                   	leave  
  801c6b:	c3                   	ret    

00801c6c <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801c6c:	55                   	push   %ebp
  801c6d:	89 e5                	mov    %esp,%ebp
  801c6f:	53                   	push   %ebx
  801c70:	83 ec 14             	sub    $0x14,%esp
  801c73:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801c76:	8b 45 08             	mov    0x8(%ebp),%eax
  801c79:	8b 40 0c             	mov    0xc(%eax),%eax
  801c7c:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801c81:	ba 00 00 00 00       	mov    $0x0,%edx
  801c86:	b8 05 00 00 00       	mov    $0x5,%eax
  801c8b:	e8 0c ff ff ff       	call   801b9c <fsipc>
  801c90:	85 c0                	test   %eax,%eax
  801c92:	78 2b                	js     801cbf <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801c94:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801c9b:	00 
  801c9c:	89 1c 24             	mov    %ebx,(%esp)
  801c9f:	e8 16 ef ff ff       	call   800bba <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801ca4:	a1 80 60 80 00       	mov    0x806080,%eax
  801ca9:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801caf:	a1 84 60 80 00       	mov    0x806084,%eax
  801cb4:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  801cba:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  801cbf:	83 c4 14             	add    $0x14,%esp
  801cc2:	5b                   	pop    %ebx
  801cc3:	5d                   	pop    %ebp
  801cc4:	c3                   	ret    

00801cc5 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801cc5:	55                   	push   %ebp
  801cc6:	89 e5                	mov    %esp,%ebp
  801cc8:	83 ec 18             	sub    $0x18,%esp
  801ccb:	8b 45 10             	mov    0x10(%ebp),%eax
  801cce:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801cd3:	76 05                	jbe    801cda <devfile_write+0x15>
  801cd5:	b8 f8 0f 00 00       	mov    $0xff8,%eax
	// bytes than requested.
	// LAB 5: Your code here
        int r;
        if(n > sizeof(fsipcbuf.write.req_buf))
            n = sizeof(fsipcbuf.write.req_buf);
        fsipcbuf.write.req_fileid = fd->fd_file.id;
  801cda:	8b 55 08             	mov    0x8(%ebp),%edx
  801cdd:	8b 52 0c             	mov    0xc(%edx),%edx
  801ce0:	89 15 00 60 80 00    	mov    %edx,0x806000
        fsipcbuf.write.req_n = n;
  801ce6:	a3 04 60 80 00       	mov    %eax,0x806004
        memmove(fsipcbuf.write.req_buf,buf,n);  
  801ceb:	89 44 24 08          	mov    %eax,0x8(%esp)
  801cef:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cf2:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cf6:	c7 04 24 08 60 80 00 	movl   $0x806008,(%esp)
  801cfd:	e8 a3 f0 ff ff       	call   800da5 <memmove>
        r = fsipc(FSREQ_WRITE,NULL);
  801d02:	ba 00 00 00 00       	mov    $0x0,%edx
  801d07:	b8 04 00 00 00       	mov    $0x4,%eax
  801d0c:	e8 8b fe ff ff       	call   801b9c <fsipc>
        return r;
	//panic("devfile_write not implemented");
}
  801d11:	c9                   	leave  
  801d12:	c3                   	ret    

00801d13 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801d13:	55                   	push   %ebp
  801d14:	89 e5                	mov    %esp,%ebp
  801d16:	53                   	push   %ebx
  801d17:	83 ec 14             	sub    $0x14,%esp
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
        int r;
        fsipcbuf.read.req_fileid = fd->fd_file.id;
  801d1a:	8b 45 08             	mov    0x8(%ebp),%eax
  801d1d:	8b 40 0c             	mov    0xc(%eax),%eax
  801d20:	a3 00 60 80 00       	mov    %eax,0x806000
        fsipcbuf.read.req_n = n;
  801d25:	8b 45 10             	mov    0x10(%ebp),%eax
  801d28:	a3 04 60 80 00       	mov    %eax,0x806004
        r = fsipc(FSREQ_READ,NULL);
  801d2d:	ba 00 00 00 00       	mov    $0x0,%edx
  801d32:	b8 03 00 00 00       	mov    $0x3,%eax
  801d37:	e8 60 fe ff ff       	call   801b9c <fsipc>
  801d3c:	89 c3                	mov    %eax,%ebx
        if(r < 0)
  801d3e:	85 c0                	test   %eax,%eax
  801d40:	78 17                	js     801d59 <devfile_read+0x46>
           return r;
        memmove(buf,fsipcbuf.readRet.ret_buf,r);
  801d42:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d46:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801d4d:	00 
  801d4e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d51:	89 04 24             	mov    %eax,(%esp)
  801d54:	e8 4c f0 ff ff       	call   800da5 <memmove>
        return r;
	//panic("devfile_read not implemented");
}
  801d59:	89 d8                	mov    %ebx,%eax
  801d5b:	83 c4 14             	add    $0x14,%esp
  801d5e:	5b                   	pop    %ebx
  801d5f:	5d                   	pop    %ebp
  801d60:	c3                   	ret    

00801d61 <remove>:
}

// Delete a file
int
remove(const char *path)
{
  801d61:	55                   	push   %ebp
  801d62:	89 e5                	mov    %esp,%ebp
  801d64:	53                   	push   %ebx
  801d65:	83 ec 14             	sub    $0x14,%esp
  801d68:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  801d6b:	89 1c 24             	mov    %ebx,(%esp)
  801d6e:	e8 fd ed ff ff       	call   800b70 <strlen>
  801d73:	89 c2                	mov    %eax,%edx
  801d75:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  801d7a:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
  801d80:	7f 1f                	jg     801da1 <remove+0x40>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  801d82:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801d86:	c7 04 24 00 60 80 00 	movl   $0x806000,(%esp)
  801d8d:	e8 28 ee ff ff       	call   800bba <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  801d92:	ba 00 00 00 00       	mov    $0x0,%edx
  801d97:	b8 07 00 00 00       	mov    $0x7,%eax
  801d9c:	e8 fb fd ff ff       	call   801b9c <fsipc>
}
  801da1:	83 c4 14             	add    $0x14,%esp
  801da4:	5b                   	pop    %ebx
  801da5:	5d                   	pop    %ebp
  801da6:	c3                   	ret    

00801da7 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801da7:	55                   	push   %ebp
  801da8:	89 e5                	mov    %esp,%ebp
  801daa:	83 ec 28             	sub    $0x28,%esp
  801dad:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801db0:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801db3:	8b 75 08             	mov    0x8(%ebp),%esi
	// If any step after fd_alloc fails, use fd_close to free the
	// file descriptor.

	// LAB 5: Your code here.
        struct Fd* fd;
        if(strlen(path) > MAXPATHLEN)
  801db6:	89 34 24             	mov    %esi,(%esp)
  801db9:	e8 b2 ed ff ff       	call   800b70 <strlen>
  801dbe:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801dc3:	3d 00 04 00 00       	cmp    $0x400,%eax
  801dc8:	7f 6d                	jg     801e37 <open+0x90>
            return -E_BAD_PATH;
        int r;
        r = fd_alloc(&fd);
  801dca:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801dcd:	89 04 24             	mov    %eax,(%esp)
  801dd0:	e8 d6 f7 ff ff       	call   8015ab <fd_alloc>
  801dd5:	89 c3                	mov    %eax,%ebx
        if(r < 0)
  801dd7:	85 c0                	test   %eax,%eax
  801dd9:	78 5c                	js     801e37 <open+0x90>
           return r;
        fsipcbuf.open.req_omode = mode;
  801ddb:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dde:	a3 00 64 80 00       	mov    %eax,0x806400
        memmove(fsipcbuf.open.req_path,path,strlen(path)+1);
  801de3:	89 34 24             	mov    %esi,(%esp)
  801de6:	e8 85 ed ff ff       	call   800b70 <strlen>
  801deb:	83 c0 01             	add    $0x1,%eax
  801dee:	89 44 24 08          	mov    %eax,0x8(%esp)
  801df2:	89 74 24 04          	mov    %esi,0x4(%esp)
  801df6:	c7 04 24 00 60 80 00 	movl   $0x806000,(%esp)
  801dfd:	e8 a3 ef ff ff       	call   800da5 <memmove>
        r = fsipc(FSREQ_OPEN,(void*)fd);
  801e02:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801e05:	b8 01 00 00 00       	mov    $0x1,%eax
  801e0a:	e8 8d fd ff ff       	call   801b9c <fsipc>
  801e0f:	89 c3                	mov    %eax,%ebx
        if(r < 0){
  801e11:	85 c0                	test   %eax,%eax
  801e13:	79 15                	jns    801e2a <open+0x83>
             fd_close(fd,0);
  801e15:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801e1c:	00 
  801e1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e20:	89 04 24             	mov    %eax,(%esp)
  801e23:	e8 37 fb ff ff       	call   80195f <fd_close>
             return r;
  801e28:	eb 0d                	jmp    801e37 <open+0x90>
        }
        return fd2num(fd);
  801e2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e2d:	89 04 24             	mov    %eax,(%esp)
  801e30:	e8 4b f7 ff ff       	call   801580 <fd2num>
  801e35:	89 c3                	mov    %eax,%ebx
	//panic("open not implemented");
}
  801e37:	89 d8                	mov    %ebx,%eax
  801e39:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801e3c:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801e3f:	89 ec                	mov    %ebp,%esp
  801e41:	5d                   	pop    %ebp
  801e42:	c3                   	ret    
	...

00801e44 <map_segment>:
}

static int
map_segment(envid_t child, uintptr_t va, size_t memsz,
	int fd, size_t filesz, off_t fileoffset, int perm)
{
  801e44:	55                   	push   %ebp
  801e45:	89 e5                	mov    %esp,%ebp
  801e47:	57                   	push   %edi
  801e48:	56                   	push   %esi
  801e49:	53                   	push   %ebx
  801e4a:	83 ec 3c             	sub    $0x3c,%esp
  801e4d:	89 45 dc             	mov    %eax,-0x24(%ebp)
  801e50:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  801e53:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801e56:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801e59:	89 d0                	mov    %edx,%eax
  801e5b:	25 ff 0f 00 00       	and    $0xfff,%eax
  801e60:	74 0d                	je     801e6f <map_segment+0x2b>
		va -= i;
  801e62:	29 c2                	sub    %eax,%edx
  801e64:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		memsz += i;
  801e67:	01 45 e0             	add    %eax,-0x20(%ebp)
		filesz += i;
  801e6a:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  801e6c:	29 45 10             	sub    %eax,0x10(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801e6f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801e73:	0f 84 12 01 00 00    	je     801f8b <map_segment+0x147>
  801e79:	be 00 00 00 00       	mov    $0x0,%esi
  801e7e:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (i >= filesz) {
  801e83:	39 f7                	cmp    %esi,%edi
  801e85:	77 26                	ja     801ead <map_segment+0x69>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801e87:	8b 45 14             	mov    0x14(%ebp),%eax
  801e8a:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e8e:	03 75 e4             	add    -0x1c(%ebp),%esi
  801e91:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e95:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801e98:	89 14 24             	mov    %edx,(%esp)
  801e9b:	e8 43 f5 ff ff       	call   8013e3 <sys_page_alloc>
  801ea0:	85 c0                	test   %eax,%eax
  801ea2:	0f 89 d2 00 00 00    	jns    801f7a <map_segment+0x136>
  801ea8:	e9 e3 00 00 00       	jmp    801f90 <map_segment+0x14c>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801ead:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801eb4:	00 
  801eb5:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801ebc:	00 
  801ebd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ec4:	e8 1a f5 ff ff       	call   8013e3 <sys_page_alloc>
  801ec9:	85 c0                	test   %eax,%eax
  801ecb:	0f 88 bf 00 00 00    	js     801f90 <map_segment+0x14c>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801ed1:	8b 55 10             	mov    0x10(%ebp),%edx
  801ed4:	8d 04 13             	lea    (%ebx,%edx,1),%eax
  801ed7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801edb:	8b 45 08             	mov    0x8(%ebp),%eax
  801ede:	89 04 24             	mov    %eax,(%esp)
  801ee1:	e8 7f f7 ff ff       	call   801665 <seek>
  801ee6:	85 c0                	test   %eax,%eax
  801ee8:	0f 88 a2 00 00 00    	js     801f90 <map_segment+0x14c>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801eee:	89 f8                	mov    %edi,%eax
  801ef0:	29 f0                	sub    %esi,%eax
  801ef2:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801ef7:	76 05                	jbe    801efe <map_segment+0xba>
  801ef9:	b8 00 10 00 00       	mov    $0x1000,%eax
  801efe:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f02:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801f09:	00 
  801f0a:	8b 55 08             	mov    0x8(%ebp),%edx
  801f0d:	89 14 24             	mov    %edx,(%esp)
  801f10:	e8 f7 f9 ff ff       	call   80190c <readn>
  801f15:	85 c0                	test   %eax,%eax
  801f17:	78 77                	js     801f90 <map_segment+0x14c>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801f19:	8b 45 14             	mov    0x14(%ebp),%eax
  801f1c:	89 44 24 10          	mov    %eax,0x10(%esp)
  801f20:	03 75 e4             	add    -0x1c(%ebp),%esi
  801f23:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801f27:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801f2a:	89 54 24 08          	mov    %edx,0x8(%esp)
  801f2e:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801f35:	00 
  801f36:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f3d:	e8 33 f4 ff ff       	call   801375 <sys_page_map>
  801f42:	85 c0                	test   %eax,%eax
  801f44:	79 20                	jns    801f66 <map_segment+0x122>
				panic("spawn: sys_page_map data: %e", r);
  801f46:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f4a:	c7 44 24 08 30 31 80 	movl   $0x803130,0x8(%esp)
  801f51:	00 
  801f52:	c7 44 24 04 21 01 00 	movl   $0x121,0x4(%esp)
  801f59:	00 
  801f5a:	c7 04 24 4d 31 80 00 	movl   $0x80314d,(%esp)
  801f61:	e8 66 e2 ff ff       	call   8001cc <_panic>
			sys_page_unmap(0, UTEMP);
  801f66:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801f6d:	00 
  801f6e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f75:	e8 8f f3 ff ff       	call   801309 <sys_page_unmap>
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801f7a:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801f80:	89 de                	mov    %ebx,%esi
  801f82:	39 5d e0             	cmp    %ebx,-0x20(%ebp)
  801f85:	0f 87 f8 fe ff ff    	ja     801e83 <map_segment+0x3f>
  801f8b:	b8 00 00 00 00       	mov    $0x0,%eax
				panic("spawn: sys_page_map data: %e", r);
			sys_page_unmap(0, UTEMP);
		}
	}
	return 0;
}
  801f90:	83 c4 3c             	add    $0x3c,%esp
  801f93:	5b                   	pop    %ebx
  801f94:	5e                   	pop    %esi
  801f95:	5f                   	pop    %edi
  801f96:	5d                   	pop    %ebp
  801f97:	c3                   	ret    

00801f98 <exec>:

int
exec(const char *prog, const char **argv)
{
  801f98:	55                   	push   %ebp
  801f99:	89 e5                	mov    %esp,%ebp
  801f9b:	57                   	push   %edi
  801f9c:	56                   	push   %esi
  801f9d:	53                   	push   %ebx
  801f9e:	81 ec 4c 02 00 00    	sub    $0x24c,%esp
        struct Proghdr *ph;
        int perm;
        uint32_t tf_esp;
        uint32_t tmp = FTEMP;

        if ((r = open(prog, O_RDONLY)) < 0){
  801fa4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801fab:	00 
  801fac:	8b 45 08             	mov    0x8(%ebp),%eax
  801faf:	89 04 24             	mov    %eax,(%esp)
  801fb2:	e8 f0 fd ff ff       	call   801da7 <open>
  801fb7:	89 85 e4 fd ff ff    	mov    %eax,-0x21c(%ebp)
  801fbd:	89 c7                	mov    %eax,%edi
  801fbf:	85 c0                	test   %eax,%eax
  801fc1:	0f 88 69 03 00 00    	js     802330 <exec+0x398>
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
	    || elf->e_magic != ELF_MAGIC) {
  801fc7:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  801fce:	00 
  801fcf:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  801fd5:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fd9:	89 3c 24             	mov    %edi,(%esp)
  801fdc:	e8 2b f9 ff ff       	call   80190c <readn>
        }
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801fe1:	3d 00 02 00 00       	cmp    $0x200,%eax
  801fe6:	75 0c                	jne    801ff4 <exec+0x5c>
	    || elf->e_magic != ELF_MAGIC) {
  801fe8:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801fef:	45 4c 46 
  801ff2:	74 36                	je     80202a <exec+0x92>
		close(fd);
  801ff4:	8b 85 e4 fd ff ff    	mov    -0x21c(%ebp),%eax
  801ffa:	89 04 24             	mov    %eax,(%esp)
  801ffd:	e8 dc f9 ff ff       	call   8019de <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  802002:	c7 44 24 08 7f 45 4c 	movl   $0x464c457f,0x8(%esp)
  802009:	46 
  80200a:	8b 85 e8 fd ff ff    	mov    -0x218(%ebp),%eax
  802010:	89 44 24 04          	mov    %eax,0x4(%esp)
  802014:	c7 04 24 59 31 80 00 	movl   $0x803159,(%esp)
  80201b:	e8 65 e2 ff ff       	call   800285 <cprintf>
  802020:	bf f2 ff ff ff       	mov    $0xfffffff2,%edi
		return -E_NOT_EXEC;
  802025:	e9 06 03 00 00       	jmp    802330 <exec+0x398>
	}

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  80202a:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  802030:	66 83 bd 14 fe ff ff 	cmpw   $0x0,-0x1ec(%ebp)
  802037:	00 
  802038:	0f 84 a5 00 00 00    	je     8020e3 <exec+0x14b>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
		return -E_NOT_EXEC;
	}

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  80203e:	8d 9c 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%ebx
  802045:	c7 85 e0 fd ff ff 00 	movl   $0xe0000000,-0x220(%ebp)
  80204c:	00 00 e0 
  80204f:	be 00 00 00 00       	mov    $0x0,%esi
  802054:	bf 00 00 00 e0       	mov    $0xe0000000,%edi
	for (i = 0; i < elf->e_phnum; i++, ph++) {
		if (ph->p_type != ELF_PROG_LOAD)
  802059:	83 3b 01             	cmpl   $0x1,(%ebx)
  80205c:	75 6f                	jne    8020cd <exec+0x135>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  80205e:	8b 43 18             	mov    0x18(%ebx),%eax
  802061:	83 e0 02             	and    $0x2,%eax
  802064:	83 f8 01             	cmp    $0x1,%eax
  802067:	19 c0                	sbb    %eax,%eax
  802069:	83 e0 fe             	and    $0xfffffffe,%eax
  80206c:	83 c0 07             	add    $0x7,%eax
			perm |= PTE_W;
		if ((r = map_segment(0, tmp + PGOFF(ph->p_va), ph->p_memsz,
  80206f:	8b 4b 14             	mov    0x14(%ebx),%ecx
  802072:	8b 53 08             	mov    0x8(%ebx),%edx
  802075:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
  80207b:	8d 14 17             	lea    (%edi,%edx,1),%edx
  80207e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802082:	8b 43 04             	mov    0x4(%ebx),%eax
  802085:	89 44 24 08          	mov    %eax,0x8(%esp)
  802089:	8b 43 10             	mov    0x10(%ebx),%eax
  80208c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802090:	8b 85 e4 fd ff ff    	mov    -0x21c(%ebp),%eax
  802096:	89 04 24             	mov    %eax,(%esp)
  802099:	b8 00 00 00 00       	mov    $0x0,%eax
  80209e:	e8 a1 fd ff ff       	call   801e44 <map_segment>
  8020a3:	85 c0                	test   %eax,%eax
  8020a5:	79 0d                	jns    8020b4 <exec+0x11c>
  8020a7:	89 c7                	mov    %eax,%edi
  8020a9:	8b 9d e4 fd ff ff    	mov    -0x21c(%ebp),%ebx
  8020af:	e9 68 02 00 00       	jmp    80231c <exec+0x384>
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
                tmp += ROUNDUP(PGOFF(ph->p_va) + ph->p_memsz, PGSIZE);
  8020b4:	8b 53 14             	mov    0x14(%ebx),%edx
  8020b7:	8b 43 08             	mov    0x8(%ebx),%eax
  8020ba:	25 ff 0f 00 00       	and    $0xfff,%eax
  8020bf:	8d 84 02 ff 0f 00 00 	lea    0xfff(%edx,%eax,1),%eax
  8020c6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8020cb:	01 c7                	add    %eax,%edi
		return -E_NOT_EXEC;
	}

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  8020cd:	83 c6 01             	add    $0x1,%esi
  8020d0:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  8020d7:	39 f0                	cmp    %esi,%eax
  8020d9:	7e 14                	jle    8020ef <exec+0x157>
  8020db:	83 c3 20             	add    $0x20,%ebx
  8020de:	e9 76 ff ff ff       	jmp    802059 <exec+0xc1>
  8020e3:	c7 85 e0 fd ff ff 00 	movl   $0xe0000000,-0x220(%ebp)
  8020ea:	00 00 e0 
  8020ed:	eb 06                	jmp    8020f5 <exec+0x15d>
  8020ef:	89 bd e0 fd ff ff    	mov    %edi,-0x220(%ebp)
		if ((r = map_segment(0, tmp + PGOFF(ph->p_va), ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
                tmp += ROUNDUP(PGOFF(ph->p_va) + ph->p_memsz, PGSIZE);
	}
	close(fd);
  8020f5:	8b 95 e4 fd ff ff    	mov    -0x21c(%ebp),%edx
  8020fb:	89 14 24             	mov    %edx,(%esp)
  8020fe:	e8 db f8 ff ff       	call   8019de <close>
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  802103:	8b 55 0c             	mov    0xc(%ebp),%edx
  802106:	8b 02                	mov    (%edx),%eax
  802108:	be 00 00 00 00       	mov    $0x0,%esi
  80210d:	bb 00 00 00 00       	mov    $0x0,%ebx
  802112:	85 c0                	test   %eax,%eax
  802114:	75 16                	jne    80212c <exec+0x194>
  802116:	c7 85 d0 fd ff ff 00 	movl   $0x0,-0x230(%ebp)
  80211d:	00 00 00 
  802120:	c7 85 cc fd ff ff 00 	movl   $0x0,-0x234(%ebp)
  802127:	00 00 00 
  80212a:	eb 2c                	jmp    802158 <exec+0x1c0>
  80212c:	8b 7d 0c             	mov    0xc(%ebp),%edi
		string_size += strlen(argv[argc]) + 1;
  80212f:	89 04 24             	mov    %eax,(%esp)
  802132:	e8 39 ea ff ff       	call   800b70 <strlen>
  802137:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  80213b:	83 c3 01             	add    $0x1,%ebx
  80213e:	8d 14 9d 00 00 00 00 	lea    0x0(,%ebx,4),%edx
  802145:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  802148:	85 c0                	test   %eax,%eax
  80214a:	75 e3                	jne    80212f <exec+0x197>
  80214c:	89 95 d0 fd ff ff    	mov    %edx,-0x230(%ebp)
  802152:	89 9d cc fd ff ff    	mov    %ebx,-0x234(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  802158:	f7 de                	neg    %esi
  80215a:	81 c6 00 10 40 00    	add    $0x401000,%esi
  802160:	89 b5 d8 fd ff ff    	mov    %esi,-0x228(%ebp)
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  802166:	89 f2                	mov    %esi,%edx
  802168:	83 e2 fc             	and    $0xfffffffc,%edx
  80216b:	89 d8                	mov    %ebx,%eax
  80216d:	f7 d0                	not    %eax
  80216f:	8d 04 82             	lea    (%edx,%eax,4),%eax
  802172:	89 85 e4 fd ff ff    	mov    %eax,-0x21c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  802178:	83 e8 08             	sub    $0x8,%eax
  80217b:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	return 0;

error:
	sys_env_destroy(0);
	close(fd);
	return r;
  802181:	bf fc ff ff ff       	mov    $0xfffffffc,%edi
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  802186:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  80218b:	0f 86 9f 01 00 00    	jbe    802330 <exec+0x398>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  802191:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  802198:	00 
  802199:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8021a0:	00 
  8021a1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8021a8:	e8 36 f2 ff ff       	call   8013e3 <sys_page_alloc>
  8021ad:	89 c7                	mov    %eax,%edi
  8021af:	85 c0                	test   %eax,%eax
  8021b1:	0f 88 79 01 00 00    	js     802330 <exec+0x398>
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  8021b7:	85 db                	test   %ebx,%ebx
  8021b9:	7e 52                	jle    80220d <exec+0x275>
  8021bb:	be 00 00 00 00       	mov    $0x0,%esi
  8021c0:	89 9d dc fd ff ff    	mov    %ebx,-0x224(%ebp)
  8021c6:	8b bd d8 fd ff ff    	mov    -0x228(%ebp),%edi
  8021cc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
		argv_store[i] = UTEMP2USTACK(string_store);
  8021cf:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  8021d5:	8b 95 e4 fd ff ff    	mov    -0x21c(%ebp),%edx
  8021db:	89 04 b2             	mov    %eax,(%edx,%esi,4)
		strcpy(string_store, argv[i]);
  8021de:	8b 04 b3             	mov    (%ebx,%esi,4),%eax
  8021e1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021e5:	89 3c 24             	mov    %edi,(%esp)
  8021e8:	e8 cd e9 ff ff       	call   800bba <strcpy>
		string_store += strlen(argv[i]) + 1;
  8021ed:	8b 04 b3             	mov    (%ebx,%esi,4),%eax
  8021f0:	89 04 24             	mov    %eax,(%esp)
  8021f3:	e8 78 e9 ff ff       	call   800b70 <strlen>
  8021f8:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  8021fc:	83 c6 01             	add    $0x1,%esi
  8021ff:	3b b5 dc fd ff ff    	cmp    -0x224(%ebp),%esi
  802205:	7c c8                	jl     8021cf <exec+0x237>
  802207:	89 bd d8 fd ff ff    	mov    %edi,-0x228(%ebp)
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  80220d:	8b 95 e4 fd ff ff    	mov    -0x21c(%ebp),%edx
  802213:	8b 85 d0 fd ff ff    	mov    -0x230(%ebp),%eax
  802219:	c7 04 02 00 00 00 00 	movl   $0x0,(%edx,%eax,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  802220:	81 bd d8 fd ff ff 00 	cmpl   $0x401000,-0x228(%ebp)
  802227:	10 40 00 
  80222a:	74 24                	je     802250 <exec+0x2b8>
  80222c:	c7 44 24 0c bc 31 80 	movl   $0x8031bc,0xc(%esp)
  802233:	00 
  802234:	c7 44 24 08 73 31 80 	movl   $0x803173,0x8(%esp)
  80223b:	00 
  80223c:	c7 44 24 04 97 01 00 	movl   $0x197,0x4(%esp)
  802243:	00 
  802244:	c7 04 24 4d 31 80 00 	movl   $0x80314d,(%esp)
  80224b:	e8 7c df ff ff       	call   8001cc <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  802250:	8b 85 e4 fd ff ff    	mov    -0x21c(%ebp),%eax
  802256:	2d 00 30 80 11       	sub    $0x11803000,%eax
  80225b:	8b 95 e4 fd ff ff    	mov    -0x21c(%ebp),%edx
  802261:	89 42 fc             	mov    %eax,-0x4(%edx)
	argv_store[-2] = argc;
  802264:	8b 95 cc fd ff ff    	mov    -0x234(%ebp),%edx
  80226a:	8b 85 d4 fd ff ff    	mov    -0x22c(%ebp),%eax
  802270:	89 10                	mov    %edx,(%eax)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, envid, (void*) stack, PTE_P | PTE_U | PTE_W)) < 0)
  802272:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  802279:	00 
  80227a:	8b 85 e0 fd ff ff    	mov    -0x220(%ebp),%eax
  802280:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802284:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80228b:	00 
  80228c:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  802293:	00 
  802294:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80229b:	e8 d5 f0 ff ff       	call   801375 <sys_page_map>
  8022a0:	89 c7                	mov    %eax,%edi
  8022a2:	85 c0                	test   %eax,%eax
  8022a4:	78 1a                	js     8022c0 <exec+0x328>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  8022a6:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8022ad:	00 
  8022ae:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8022b5:	e8 4f f0 ff ff       	call   801309 <sys_page_unmap>
  8022ba:	89 c7                	mov    %eax,%edi
  8022bc:	85 c0                	test   %eax,%eax
  8022be:	79 16                	jns    8022d6 <exec+0x33e>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  8022c0:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8022c7:	00 
  8022c8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8022cf:	e8 35 f0 ff ff       	call   801309 <sys_page_unmap>
  8022d4:	eb 5a                	jmp    802330 <exec+0x398>
	close(fd);
	fd = -1;
        if ((r = init_stack_2(0, argv, &tf_esp,tmp)) < 0)
		return r;

	if (sys_exec((void*)(elf_buf + elf->e_phoff), elf->e_phnum, tf_esp, elf->e_entry) < 0)
  8022d6:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  8022dc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8022e0:	8b 85 e4 fd ff ff    	mov    -0x21c(%ebp),%eax
  8022e6:	2d 08 30 80 11       	sub    $0x11803008,%eax
  8022eb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8022ef:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  8022f6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022fa:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  802300:	03 85 04 fe ff ff    	add    -0x1fc(%ebp),%eax
  802306:	89 04 24             	mov    %eax,(%esp)
  802309:	e8 1d ed ff ff       	call   80102b <sys_exec>
  80230e:	bf 00 00 00 00       	mov    $0x0,%edi
  802313:	85 c0                	test   %eax,%eax
  802315:	79 19                	jns    802330 <exec+0x398>
  802317:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
		goto error;
	return 0;

error:
	sys_env_destroy(0);
  80231c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802323:	e8 ea f1 ff ff       	call   801512 <sys_env_destroy>
	close(fd);
  802328:	89 1c 24             	mov    %ebx,(%esp)
  80232b:	e8 ae f6 ff ff       	call   8019de <close>
	return r;
}
  802330:	89 f8                	mov    %edi,%eax
  802332:	81 c4 4c 02 00 00    	add    $0x24c,%esp
  802338:	5b                   	pop    %ebx
  802339:	5e                   	pop    %esi
  80233a:	5f                   	pop    %edi
  80233b:	5d                   	pop    %ebp
  80233c:	c3                   	ret    

0080233d <execl>:
	return r;
}

int
execl(const char *prog, const char *arg0, ...)
{
  80233d:	55                   	push   %ebp
  80233e:	89 e5                	mov    %esp,%ebp
  802340:	56                   	push   %esi
  802341:	53                   	push   %ebx
  802342:	83 ec 10             	sub    $0x10,%esp
  802345:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	sys_page_unmap(0, UTEMP);
	return r;
}

int
execl(const char *prog, const char *arg0, ...)
  802348:	8d 55 10             	lea    0x10(%ebp),%edx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  80234b:	83 3a 00             	cmpl   $0x0,(%edx)
  80234e:	74 5d                	je     8023ad <execl+0x70>
  802350:	b8 00 00 00 00       	mov    $0x0,%eax
		argc++;
  802355:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802358:	83 3c 82 00          	cmpl   $0x0,(%edx,%eax,4)
  80235c:	75 f7                	jne    802355 <execl+0x18>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  80235e:	8d 14 85 26 00 00 00 	lea    0x26(,%eax,4),%edx
  802365:	83 e2 f0             	and    $0xfffffff0,%edx
  802368:	29 d4                	sub    %edx,%esp
  80236a:	8d 4c 24 17          	lea    0x17(%esp),%ecx
  80236e:	83 e1 f0             	and    $0xfffffff0,%ecx
	argv[0] = arg0;
  802371:	89 19                	mov    %ebx,(%ecx)
	argv[argc+1] = NULL;
  802373:	c7 44 81 04 00 00 00 	movl   $0x0,0x4(%ecx,%eax,4)
  80237a:	00 
	sys_page_unmap(0, UTEMP);
	return r;
}

int
execl(const char *prog, const char *arg0, ...)
  80237b:	8d 75 10             	lea    0x10(%ebp),%esi
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  80237e:	89 c3                	mov    %eax,%ebx
  802380:	85 c0                	test   %eax,%eax
  802382:	74 13                	je     802397 <execl+0x5a>
  802384:	b8 00 00 00 00       	mov    $0x0,%eax
		argv[i+1] = va_arg(vl, const char *);
  802389:	83 c0 01             	add    $0x1,%eax
  80238c:	8b 54 86 fc          	mov    -0x4(%esi,%eax,4),%edx
  802390:	89 14 81             	mov    %edx,(%ecx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  802393:	39 d8                	cmp    %ebx,%eax
  802395:	72 f2                	jb     802389 <execl+0x4c>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return exec(prog, argv);
  802397:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80239b:	8b 45 08             	mov    0x8(%ebp),%eax
  80239e:	89 04 24             	mov    %eax,(%esp)
  8023a1:	e8 f2 fb ff ff       	call   801f98 <exec>
}
  8023a6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8023a9:	5b                   	pop    %ebx
  8023aa:	5e                   	pop    %esi
  8023ab:	5d                   	pop    %ebp
  8023ac:	c3                   	ret    
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  8023ad:	83 ec 20             	sub    $0x20,%esp
  8023b0:	8d 4c 24 17          	lea    0x17(%esp),%ecx
  8023b4:	83 e1 f0             	and    $0xfffffff0,%ecx
	argv[0] = arg0;
  8023b7:	89 19                	mov    %ebx,(%ecx)
	argv[argc+1] = NULL;
  8023b9:	c7 41 04 00 00 00 00 	movl   $0x0,0x4(%ecx)
  8023c0:	eb d5                	jmp    802397 <execl+0x5a>

008023c2 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  8023c2:	55                   	push   %ebp
  8023c3:	89 e5                	mov    %esp,%ebp
  8023c5:	57                   	push   %edi
  8023c6:	56                   	push   %esi
  8023c7:	53                   	push   %ebx
  8023c8:	81 ec 9c 02 00 00    	sub    $0x29c,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  8023ce:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8023d5:	00 
  8023d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8023d9:	89 04 24             	mov    %eax,(%esp)
  8023dc:	e8 c6 f9 ff ff       	call   801da7 <open>
  8023e1:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  8023e7:	89 c7                	mov    %eax,%edi
  8023e9:	85 c0                	test   %eax,%eax
  8023eb:	0f 88 ae 03 00 00    	js     80279f <spawn+0x3dd>
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
	    || elf->e_magic != ELF_MAGIC) {
  8023f1:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  8023f8:	00 
  8023f9:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  8023ff:	89 44 24 04          	mov    %eax,0x4(%esp)
  802403:	89 3c 24             	mov    %edi,(%esp)
  802406:	e8 01 f5 ff ff       	call   80190c <readn>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  80240b:	3d 00 02 00 00       	cmp    $0x200,%eax
  802410:	75 0c                	jne    80241e <spawn+0x5c>
	    || elf->e_magic != ELF_MAGIC) {
  802412:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  802419:	45 4c 46 
  80241c:	74 36                	je     802454 <spawn+0x92>
		close(fd);
  80241e:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  802424:	89 04 24             	mov    %eax,(%esp)
  802427:	e8 b2 f5 ff ff       	call   8019de <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  80242c:	c7 44 24 08 7f 45 4c 	movl   $0x464c457f,0x8(%esp)
  802433:	46 
  802434:	8b 85 e8 fd ff ff    	mov    -0x218(%ebp),%eax
  80243a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80243e:	c7 04 24 59 31 80 00 	movl   $0x803159,(%esp)
  802445:	e8 3b de ff ff       	call   800285 <cprintf>
  80244a:	bf f2 ff ff ff       	mov    $0xfffffff2,%edi
		return -E_NOT_EXEC;
  80244f:	e9 4b 03 00 00       	jmp    80279f <spawn+0x3dd>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  802454:	ba 08 00 00 00       	mov    $0x8,%edx
  802459:	89 d0                	mov    %edx,%eax
  80245b:	cd 30                	int    $0x30
  80245d:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  802463:	85 c0                	test   %eax,%eax
  802465:	0f 88 2e 03 00 00    	js     802799 <spawn+0x3d7>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  80246b:	25 ff 03 00 00       	and    $0x3ff,%eax
  802470:	89 c2                	mov    %eax,%edx
  802472:	c1 e2 07             	shl    $0x7,%edx
  802475:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  80247b:	8d b4 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%esi
  802482:	b9 11 00 00 00       	mov    $0x11,%ecx
  802487:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  802489:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  80248f:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  802495:	8b 55 0c             	mov    0xc(%ebp),%edx
  802498:	8b 02                	mov    (%edx),%eax
  80249a:	be 00 00 00 00       	mov    $0x0,%esi
  80249f:	bb 00 00 00 00       	mov    $0x0,%ebx
  8024a4:	85 c0                	test   %eax,%eax
  8024a6:	75 16                	jne    8024be <spawn+0xfc>
  8024a8:	c7 85 7c fd ff ff 00 	movl   $0x0,-0x284(%ebp)
  8024af:	00 00 00 
  8024b2:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  8024b9:	00 00 00 
  8024bc:	eb 2c                	jmp    8024ea <spawn+0x128>
  8024be:	8b 7d 0c             	mov    0xc(%ebp),%edi
		string_size += strlen(argv[argc]) + 1;
  8024c1:	89 04 24             	mov    %eax,(%esp)
  8024c4:	e8 a7 e6 ff ff       	call   800b70 <strlen>
  8024c9:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  8024cd:	83 c3 01             	add    $0x1,%ebx
  8024d0:	8d 14 9d 00 00 00 00 	lea    0x0(,%ebx,4),%edx
  8024d7:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  8024da:	85 c0                	test   %eax,%eax
  8024dc:	75 e3                	jne    8024c1 <spawn+0xff>
  8024de:	89 95 7c fd ff ff    	mov    %edx,-0x284(%ebp)
  8024e4:	89 9d 78 fd ff ff    	mov    %ebx,-0x288(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  8024ea:	f7 de                	neg    %esi
  8024ec:	81 c6 00 10 40 00    	add    $0x401000,%esi
  8024f2:	89 b5 84 fd ff ff    	mov    %esi,-0x27c(%ebp)
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  8024f8:	89 f2                	mov    %esi,%edx
  8024fa:	83 e2 fc             	and    $0xfffffffc,%edx
  8024fd:	89 d8                	mov    %ebx,%eax
  8024ff:	f7 d0                	not    %eax
  802501:	8d 04 82             	lea    (%edx,%eax,4),%eax
  802504:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  80250a:	83 e8 08             	sub    $0x8,%eax
  80250d:	89 85 80 fd ff ff    	mov    %eax,-0x280(%ebp)
	return child;

error:
	sys_env_destroy(child);
	close(fd);
	return r;
  802513:	bf fc ff ff ff       	mov    $0xfffffffc,%edi
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  802518:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  80251d:	0f 86 7c 02 00 00    	jbe    80279f <spawn+0x3dd>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  802523:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80252a:	00 
  80252b:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  802532:	00 
  802533:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80253a:	e8 a4 ee ff ff       	call   8013e3 <sys_page_alloc>
  80253f:	89 c7                	mov    %eax,%edi
  802541:	85 c0                	test   %eax,%eax
  802543:	0f 88 56 02 00 00    	js     80279f <spawn+0x3dd>
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  802549:	85 db                	test   %ebx,%ebx
  80254b:	7e 52                	jle    80259f <spawn+0x1dd>
  80254d:	be 00 00 00 00       	mov    $0x0,%esi
  802552:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  802558:	8b bd 84 fd ff ff    	mov    -0x27c(%ebp),%edi
  80255e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
		argv_store[i] = UTEMP2USTACK(string_store);
  802561:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  802567:	8b 95 8c fd ff ff    	mov    -0x274(%ebp),%edx
  80256d:	89 04 b2             	mov    %eax,(%edx,%esi,4)
		strcpy(string_store, argv[i]);
  802570:	8b 04 b3             	mov    (%ebx,%esi,4),%eax
  802573:	89 44 24 04          	mov    %eax,0x4(%esp)
  802577:	89 3c 24             	mov    %edi,(%esp)
  80257a:	e8 3b e6 ff ff       	call   800bba <strcpy>
		string_store += strlen(argv[i]) + 1;
  80257f:	8b 04 b3             	mov    (%ebx,%esi,4),%eax
  802582:	89 04 24             	mov    %eax,(%esp)
  802585:	e8 e6 e5 ff ff       	call   800b70 <strlen>
  80258a:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  80258e:	83 c6 01             	add    $0x1,%esi
  802591:	3b b5 88 fd ff ff    	cmp    -0x278(%ebp),%esi
  802597:	7c c8                	jl     802561 <spawn+0x19f>
  802599:	89 bd 84 fd ff ff    	mov    %edi,-0x27c(%ebp)
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  80259f:	8b 95 8c fd ff ff    	mov    -0x274(%ebp),%edx
  8025a5:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  8025ab:	c7 04 02 00 00 00 00 	movl   $0x0,(%edx,%eax,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  8025b2:	81 bd 84 fd ff ff 00 	cmpl   $0x401000,-0x27c(%ebp)
  8025b9:	10 40 00 
  8025bc:	74 24                	je     8025e2 <spawn+0x220>
  8025be:	c7 44 24 0c bc 31 80 	movl   $0x8031bc,0xc(%esp)
  8025c5:	00 
  8025c6:	c7 44 24 08 73 31 80 	movl   $0x803173,0x8(%esp)
  8025cd:	00 
  8025ce:	c7 44 24 04 ee 00 00 	movl   $0xee,0x4(%esp)
  8025d5:	00 
  8025d6:	c7 04 24 4d 31 80 00 	movl   $0x80314d,(%esp)
  8025dd:	e8 ea db ff ff       	call   8001cc <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  8025e2:	8b 85 8c fd ff ff    	mov    -0x274(%ebp),%eax
  8025e8:	2d 00 30 80 11       	sub    $0x11803000,%eax
  8025ed:	8b 95 8c fd ff ff    	mov    -0x274(%ebp),%edx
  8025f3:	89 42 fc             	mov    %eax,-0x4(%edx)
	argv_store[-2] = argc;
  8025f6:	8b 95 78 fd ff ff    	mov    -0x288(%ebp),%edx
  8025fc:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  802602:	89 10                	mov    %edx,(%eax)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  802604:	8b 85 8c fd ff ff    	mov    -0x274(%ebp),%eax
  80260a:	2d 08 30 80 11       	sub    $0x11803008,%eax
  80260f:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  802615:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  80261c:	00 
  80261d:	c7 44 24 0c 00 d0 bf 	movl   $0xeebfd000,0xc(%esp)
  802624:	ee 
  802625:	8b 85 90 fd ff ff    	mov    -0x270(%ebp),%eax
  80262b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80262f:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  802636:	00 
  802637:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80263e:	e8 32 ed ff ff       	call   801375 <sys_page_map>
  802643:	89 c7                	mov    %eax,%edi
  802645:	85 c0                	test   %eax,%eax
  802647:	78 1a                	js     802663 <spawn+0x2a1>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  802649:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  802650:	00 
  802651:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802658:	e8 ac ec ff ff       	call   801309 <sys_page_unmap>
  80265d:	89 c7                	mov    %eax,%edi
  80265f:	85 c0                	test   %eax,%eax
  802661:	79 19                	jns    80267c <spawn+0x2ba>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  802663:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  80266a:	00 
  80266b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802672:	e8 92 ec ff ff       	call   801309 <sys_page_unmap>
  802677:	e9 23 01 00 00       	jmp    80279f <spawn+0x3dd>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  80267c:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  802682:	66 83 bd 14 fe ff ff 	cmpw   $0x0,-0x1ec(%ebp)
  802689:	00 
  80268a:	74 69                	je     8026f5 <spawn+0x333>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  80268c:	8d 9c 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%ebx
  802693:	be 00 00 00 00       	mov    $0x0,%esi
  802698:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
	for (i = 0; i < elf->e_phnum; i++, ph++) {
		if (ph->p_type != ELF_PROG_LOAD)
  80269e:	83 3b 01             	cmpl   $0x1,(%ebx)
  8026a1:	75 3f                	jne    8026e2 <spawn+0x320>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  8026a3:	8b 43 18             	mov    0x18(%ebx),%eax
  8026a6:	83 e0 02             	and    $0x2,%eax
  8026a9:	83 f8 01             	cmp    $0x1,%eax
  8026ac:	19 c0                	sbb    %eax,%eax
  8026ae:	83 e0 fe             	and    $0xfffffffe,%eax
  8026b1:	83 c0 07             	add    $0x7,%eax
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  8026b4:	8b 4b 14             	mov    0x14(%ebx),%ecx
  8026b7:	8b 53 08             	mov    0x8(%ebx),%edx
  8026ba:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8026be:	8b 43 04             	mov    0x4(%ebx),%eax
  8026c1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8026c5:	8b 43 10             	mov    0x10(%ebx),%eax
  8026c8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8026cc:	89 3c 24             	mov    %edi,(%esp)
  8026cf:	8b 85 90 fd ff ff    	mov    -0x270(%ebp),%eax
  8026d5:	e8 6a f7 ff ff       	call   801e44 <map_segment>
  8026da:	85 c0                	test   %eax,%eax
  8026dc:	0f 88 97 00 00 00    	js     802779 <spawn+0x3b7>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  8026e2:	83 c6 01             	add    $0x1,%esi
  8026e5:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  8026ec:	39 f0                	cmp    %esi,%eax
  8026ee:	7e 05                	jle    8026f5 <spawn+0x333>
  8026f0:	83 c3 20             	add    $0x20,%ebx
  8026f3:	eb a9                	jmp    80269e <spawn+0x2dc>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  8026f5:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  8026fb:	89 14 24             	mov    %edx,(%esp)
  8026fe:	e8 db f2 ff ff       	call   8019de <close>
	fd = -1;

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  802703:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  802709:	89 44 24 04          	mov    %eax,0x4(%esp)
  80270d:	8b 85 90 fd ff ff    	mov    -0x270(%ebp),%eax
  802713:	89 04 24             	mov    %eax,(%esp)
  802716:	e8 16 eb ff ff       	call   801231 <sys_env_set_trapframe>
  80271b:	85 c0                	test   %eax,%eax
  80271d:	79 20                	jns    80273f <spawn+0x37d>
		panic("sys_env_set_trapframe: %e", r);
  80271f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802723:	c7 44 24 08 88 31 80 	movl   $0x803188,0x8(%esp)
  80272a:	00 
  80272b:	c7 44 24 04 82 00 00 	movl   $0x82,0x4(%esp)
  802732:	00 
  802733:	c7 04 24 4d 31 80 00 	movl   $0x80314d,(%esp)
  80273a:	e8 8d da ff ff       	call   8001cc <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  80273f:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  802746:	00 
  802747:	8b 95 90 fd ff ff    	mov    -0x270(%ebp),%edx
  80274d:	89 14 24             	mov    %edx,(%esp)
  802750:	e8 48 eb ff ff       	call   80129d <sys_env_set_status>
  802755:	85 c0                	test   %eax,%eax
  802757:	79 40                	jns    802799 <spawn+0x3d7>
		panic("sys_env_set_status: %e", r);
  802759:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80275d:	c7 44 24 08 a2 31 80 	movl   $0x8031a2,0x8(%esp)
  802764:	00 
  802765:	c7 44 24 04 85 00 00 	movl   $0x85,0x4(%esp)
  80276c:	00 
  80276d:	c7 04 24 4d 31 80 00 	movl   $0x80314d,(%esp)
  802774:	e8 53 da ff ff       	call   8001cc <_panic>
  802779:	89 c7                	mov    %eax,%edi

	return child;

error:
	sys_env_destroy(child);
  80277b:	8b 85 90 fd ff ff    	mov    -0x270(%ebp),%eax
  802781:	89 04 24             	mov    %eax,(%esp)
  802784:	e8 89 ed ff ff       	call   801512 <sys_env_destroy>
	close(fd);
  802789:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  80278f:	89 14 24             	mov    %edx,(%esp)
  802792:	e8 47 f2 ff ff       	call   8019de <close>
	return r;
  802797:	eb 06                	jmp    80279f <spawn+0x3dd>
  802799:	8b bd 90 fd ff ff    	mov    -0x270(%ebp),%edi
}
  80279f:	89 f8                	mov    %edi,%eax
  8027a1:	81 c4 9c 02 00 00    	add    $0x29c,%esp
  8027a7:	5b                   	pop    %ebx
  8027a8:	5e                   	pop    %esi
  8027a9:	5f                   	pop    %edi
  8027aa:	5d                   	pop    %ebp
  8027ab:	c3                   	ret    

008027ac <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  8027ac:	55                   	push   %ebp
  8027ad:	89 e5                	mov    %esp,%ebp
  8027af:	56                   	push   %esi
  8027b0:	53                   	push   %ebx
  8027b1:	83 ec 10             	sub    $0x10,%esp
  8027b4:	8b 5d 0c             	mov    0xc(%ebp),%ebx

// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
  8027b7:	8d 55 10             	lea    0x10(%ebp),%edx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  8027ba:	83 3a 00             	cmpl   $0x0,(%edx)
  8027bd:	74 5d                	je     80281c <spawnl+0x70>
  8027bf:	b8 00 00 00 00       	mov    $0x0,%eax
		argc++;
  8027c4:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  8027c7:	83 3c 82 00          	cmpl   $0x0,(%edx,%eax,4)
  8027cb:	75 f7                	jne    8027c4 <spawnl+0x18>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  8027cd:	8d 14 85 26 00 00 00 	lea    0x26(,%eax,4),%edx
  8027d4:	83 e2 f0             	and    $0xfffffff0,%edx
  8027d7:	29 d4                	sub    %edx,%esp
  8027d9:	8d 4c 24 17          	lea    0x17(%esp),%ecx
  8027dd:	83 e1 f0             	and    $0xfffffff0,%ecx
	argv[0] = arg0;
  8027e0:	89 19                	mov    %ebx,(%ecx)
	argv[argc+1] = NULL;
  8027e2:	c7 44 81 04 00 00 00 	movl   $0x0,0x4(%ecx,%eax,4)
  8027e9:	00 

// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
  8027ea:	8d 75 10             	lea    0x10(%ebp),%esi
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  8027ed:	89 c3                	mov    %eax,%ebx
  8027ef:	85 c0                	test   %eax,%eax
  8027f1:	74 13                	je     802806 <spawnl+0x5a>
  8027f3:	b8 00 00 00 00       	mov    $0x0,%eax
		argv[i+1] = va_arg(vl, const char *);
  8027f8:	83 c0 01             	add    $0x1,%eax
  8027fb:	8b 54 86 fc          	mov    -0x4(%esi,%eax,4),%edx
  8027ff:	89 14 81             	mov    %edx,(%ecx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  802802:	39 d8                	cmp    %ebx,%eax
  802804:	72 f2                	jb     8027f8 <spawnl+0x4c>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  802806:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80280a:	8b 45 08             	mov    0x8(%ebp),%eax
  80280d:	89 04 24             	mov    %eax,(%esp)
  802810:	e8 ad fb ff ff       	call   8023c2 <spawn>
}
  802815:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802818:	5b                   	pop    %ebx
  802819:	5e                   	pop    %esi
  80281a:	5d                   	pop    %ebp
  80281b:	c3                   	ret    
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  80281c:	83 ec 20             	sub    $0x20,%esp
  80281f:	8d 4c 24 17          	lea    0x17(%esp),%ecx
  802823:	83 e1 f0             	and    $0xfffffff0,%ecx
	argv[0] = arg0;
  802826:	89 19                	mov    %ebx,(%ecx)
	argv[argc+1] = NULL;
  802828:	c7 41 04 00 00 00 00 	movl   $0x0,0x4(%ecx)
  80282f:	eb d5                	jmp    802806 <spawnl+0x5a>
	...

00802840 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802840:	55                   	push   %ebp
  802841:	89 e5                	mov    %esp,%ebp
  802843:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  802846:	8b 15 50 00 c0 ee    	mov    0xeec00050,%edx
  80284c:	b8 01 00 00 00       	mov    $0x1,%eax
  802851:	39 ca                	cmp    %ecx,%edx
  802853:	75 04                	jne    802859 <ipc_find_env+0x19>
  802855:	b0 00                	mov    $0x0,%al
  802857:	eb 12                	jmp    80286b <ipc_find_env+0x2b>
  802859:	89 c2                	mov    %eax,%edx
  80285b:	c1 e2 07             	shl    $0x7,%edx
  80285e:	8d 94 82 50 00 c0 ee 	lea    -0x113fffb0(%edx,%eax,4),%edx
  802865:	8b 12                	mov    (%edx),%edx
  802867:	39 ca                	cmp    %ecx,%edx
  802869:	75 10                	jne    80287b <ipc_find_env+0x3b>
			return envs[i].env_id;
  80286b:	89 c2                	mov    %eax,%edx
  80286d:	c1 e2 07             	shl    $0x7,%edx
  802870:	8d 84 82 48 00 c0 ee 	lea    -0x113fffb8(%edx,%eax,4),%eax
  802877:	8b 00                	mov    (%eax),%eax
  802879:	eb 0e                	jmp    802889 <ipc_find_env+0x49>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80287b:	83 c0 01             	add    $0x1,%eax
  80287e:	3d 00 04 00 00       	cmp    $0x400,%eax
  802883:	75 d4                	jne    802859 <ipc_find_env+0x19>
  802885:	66 b8 00 00          	mov    $0x0,%ax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  802889:	5d                   	pop    %ebp
  80288a:	c3                   	ret    

0080288b <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80288b:	55                   	push   %ebp
  80288c:	89 e5                	mov    %esp,%ebp
  80288e:	57                   	push   %edi
  80288f:	56                   	push   %esi
  802890:	53                   	push   %ebx
  802891:	83 ec 1c             	sub    $0x1c,%esp
  802894:	8b 75 08             	mov    0x8(%ebp),%esi
  802897:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80289a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        int ret;
        while(1){
           if(pg)
  80289d:	85 db                	test   %ebx,%ebx
  80289f:	74 19                	je     8028ba <ipc_send+0x2f>
              ret = sys_ipc_try_send(to_env,val,pg,perm);
  8028a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8028a4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8028a8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8028ac:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8028b0:	89 34 24             	mov    %esi,(%esp)
  8028b3:	e8 cc e8 ff ff       	call   801184 <sys_ipc_try_send>
  8028b8:	eb 1b                	jmp    8028d5 <ipc_send+0x4a>
           else
              ret = sys_ipc_try_send(to_env,val,(void*)UTOP,perm);
  8028ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8028bd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8028c1:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  8028c8:	ee 
  8028c9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8028cd:	89 34 24             	mov    %esi,(%esp)
  8028d0:	e8 af e8 ff ff       	call   801184 <sys_ipc_try_send>
           if(ret == 0)
  8028d5:	85 c0                	test   %eax,%eax
  8028d7:	74 28                	je     802901 <ipc_send+0x76>
              return;
           if(ret != -E_IPC_NOT_RECV)
  8028d9:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8028dc:	74 1c                	je     8028fa <ipc_send+0x6f>
              panic("ipc send error");
  8028de:	c7 44 24 08 e4 31 80 	movl   $0x8031e4,0x8(%esp)
  8028e5:	00 
  8028e6:	c7 44 24 04 46 00 00 	movl   $0x46,0x4(%esp)
  8028ed:	00 
  8028ee:	c7 04 24 f3 31 80 00 	movl   $0x8031f3,(%esp)
  8028f5:	e8 d2 d8 ff ff       	call   8001cc <_panic>
           sys_yield();
  8028fa:	e8 51 eb ff ff       	call   801450 <sys_yield>
        }
  8028ff:	eb 9c                	jmp    80289d <ipc_send+0x12>
	//panic("ipc_send not implemented");
}
  802901:	83 c4 1c             	add    $0x1c,%esp
  802904:	5b                   	pop    %ebx
  802905:	5e                   	pop    %esi
  802906:	5f                   	pop    %edi
  802907:	5d                   	pop    %ebp
  802908:	c3                   	ret    

00802909 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802909:	55                   	push   %ebp
  80290a:	89 e5                	mov    %esp,%ebp
  80290c:	56                   	push   %esi
  80290d:	53                   	push   %ebx
  80290e:	83 ec 10             	sub    $0x10,%esp
  802911:	8b 75 08             	mov    0x8(%ebp),%esi
  802914:	8b 45 0c             	mov    0xc(%ebp),%eax
  802917:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        int ret;
        if(!pg)
  80291a:	85 c0                	test   %eax,%eax
  80291c:	75 0e                	jne    80292c <ipc_recv+0x23>
           ret = sys_ipc_recv((void*)UTOP);
  80291e:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  802925:	e8 ef e7 ff ff       	call   801119 <sys_ipc_recv>
  80292a:	eb 08                	jmp    802934 <ipc_recv+0x2b>
        else
           ret = sys_ipc_recv(pg);
  80292c:	89 04 24             	mov    %eax,(%esp)
  80292f:	e8 e5 e7 ff ff       	call   801119 <sys_ipc_recv>
        if(ret == 0){
  802934:	85 c0                	test   %eax,%eax
  802936:	75 26                	jne    80295e <ipc_recv+0x55>
           if(from_env_store)
  802938:	85 f6                	test   %esi,%esi
  80293a:	74 0a                	je     802946 <ipc_recv+0x3d>
              *from_env_store = thisenv->env_ipc_from;
  80293c:	a1 04 50 80 00       	mov    0x805004,%eax
  802941:	8b 40 78             	mov    0x78(%eax),%eax
  802944:	89 06                	mov    %eax,(%esi)
           if(perm_store)
  802946:	85 db                	test   %ebx,%ebx
  802948:	74 0a                	je     802954 <ipc_recv+0x4b>
              *perm_store = thisenv->env_ipc_perm;
  80294a:	a1 04 50 80 00       	mov    0x805004,%eax
  80294f:	8b 40 7c             	mov    0x7c(%eax),%eax
  802952:	89 03                	mov    %eax,(%ebx)
           return thisenv->env_ipc_value;
  802954:	a1 04 50 80 00       	mov    0x805004,%eax
  802959:	8b 40 74             	mov    0x74(%eax),%eax
  80295c:	eb 14                	jmp    802972 <ipc_recv+0x69>
        }
        else{
           if(from_env_store)
  80295e:	85 f6                	test   %esi,%esi
  802960:	74 06                	je     802968 <ipc_recv+0x5f>
              *from_env_store = 0;
  802962:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
           if(perm_store)
  802968:	85 db                	test   %ebx,%ebx
  80296a:	74 06                	je     802972 <ipc_recv+0x69>
              *perm_store = 0;
  80296c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
           return ret;
        }
	//panic("ipc_recv not implemented");
	return 0;
}
  802972:	83 c4 10             	add    $0x10,%esp
  802975:	5b                   	pop    %ebx
  802976:	5e                   	pop    %esi
  802977:	5d                   	pop    %ebp
  802978:	c3                   	ret    
  802979:	00 00                	add    %al,(%eax)
  80297b:	00 00                	add    %al,(%eax)
  80297d:	00 00                	add    %al,(%eax)
	...

00802980 <__udivdi3>:
  802980:	55                   	push   %ebp
  802981:	89 e5                	mov    %esp,%ebp
  802983:	57                   	push   %edi
  802984:	56                   	push   %esi
  802985:	83 ec 10             	sub    $0x10,%esp
  802988:	8b 45 14             	mov    0x14(%ebp),%eax
  80298b:	8b 55 08             	mov    0x8(%ebp),%edx
  80298e:	8b 75 10             	mov    0x10(%ebp),%esi
  802991:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802994:	85 c0                	test   %eax,%eax
  802996:	89 55 f0             	mov    %edx,-0x10(%ebp)
  802999:	75 35                	jne    8029d0 <__udivdi3+0x50>
  80299b:	39 fe                	cmp    %edi,%esi
  80299d:	77 61                	ja     802a00 <__udivdi3+0x80>
  80299f:	85 f6                	test   %esi,%esi
  8029a1:	75 0b                	jne    8029ae <__udivdi3+0x2e>
  8029a3:	b8 01 00 00 00       	mov    $0x1,%eax
  8029a8:	31 d2                	xor    %edx,%edx
  8029aa:	f7 f6                	div    %esi
  8029ac:	89 c6                	mov    %eax,%esi
  8029ae:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  8029b1:	31 d2                	xor    %edx,%edx
  8029b3:	89 f8                	mov    %edi,%eax
  8029b5:	f7 f6                	div    %esi
  8029b7:	89 c7                	mov    %eax,%edi
  8029b9:	89 c8                	mov    %ecx,%eax
  8029bb:	f7 f6                	div    %esi
  8029bd:	89 c1                	mov    %eax,%ecx
  8029bf:	89 fa                	mov    %edi,%edx
  8029c1:	89 c8                	mov    %ecx,%eax
  8029c3:	83 c4 10             	add    $0x10,%esp
  8029c6:	5e                   	pop    %esi
  8029c7:	5f                   	pop    %edi
  8029c8:	5d                   	pop    %ebp
  8029c9:	c3                   	ret    
  8029ca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8029d0:	39 f8                	cmp    %edi,%eax
  8029d2:	77 1c                	ja     8029f0 <__udivdi3+0x70>
  8029d4:	0f bd d0             	bsr    %eax,%edx
  8029d7:	83 f2 1f             	xor    $0x1f,%edx
  8029da:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8029dd:	75 39                	jne    802a18 <__udivdi3+0x98>
  8029df:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  8029e2:	0f 86 a0 00 00 00    	jbe    802a88 <__udivdi3+0x108>
  8029e8:	39 f8                	cmp    %edi,%eax
  8029ea:	0f 82 98 00 00 00    	jb     802a88 <__udivdi3+0x108>
  8029f0:	31 ff                	xor    %edi,%edi
  8029f2:	31 c9                	xor    %ecx,%ecx
  8029f4:	89 c8                	mov    %ecx,%eax
  8029f6:	89 fa                	mov    %edi,%edx
  8029f8:	83 c4 10             	add    $0x10,%esp
  8029fb:	5e                   	pop    %esi
  8029fc:	5f                   	pop    %edi
  8029fd:	5d                   	pop    %ebp
  8029fe:	c3                   	ret    
  8029ff:	90                   	nop
  802a00:	89 d1                	mov    %edx,%ecx
  802a02:	89 fa                	mov    %edi,%edx
  802a04:	89 c8                	mov    %ecx,%eax
  802a06:	31 ff                	xor    %edi,%edi
  802a08:	f7 f6                	div    %esi
  802a0a:	89 c1                	mov    %eax,%ecx
  802a0c:	89 fa                	mov    %edi,%edx
  802a0e:	89 c8                	mov    %ecx,%eax
  802a10:	83 c4 10             	add    $0x10,%esp
  802a13:	5e                   	pop    %esi
  802a14:	5f                   	pop    %edi
  802a15:	5d                   	pop    %ebp
  802a16:	c3                   	ret    
  802a17:	90                   	nop
  802a18:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  802a1c:	89 f2                	mov    %esi,%edx
  802a1e:	d3 e0                	shl    %cl,%eax
  802a20:	89 45 ec             	mov    %eax,-0x14(%ebp)
  802a23:	b8 20 00 00 00       	mov    $0x20,%eax
  802a28:	2b 45 f4             	sub    -0xc(%ebp),%eax
  802a2b:	89 c1                	mov    %eax,%ecx
  802a2d:	d3 ea                	shr    %cl,%edx
  802a2f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  802a33:	0b 55 ec             	or     -0x14(%ebp),%edx
  802a36:	d3 e6                	shl    %cl,%esi
  802a38:	89 c1                	mov    %eax,%ecx
  802a3a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  802a3d:	89 fe                	mov    %edi,%esi
  802a3f:	d3 ee                	shr    %cl,%esi
  802a41:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  802a45:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802a48:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802a4b:	d3 e7                	shl    %cl,%edi
  802a4d:	89 c1                	mov    %eax,%ecx
  802a4f:	d3 ea                	shr    %cl,%edx
  802a51:	09 d7                	or     %edx,%edi
  802a53:	89 f2                	mov    %esi,%edx
  802a55:	89 f8                	mov    %edi,%eax
  802a57:	f7 75 ec             	divl   -0x14(%ebp)
  802a5a:	89 d6                	mov    %edx,%esi
  802a5c:	89 c7                	mov    %eax,%edi
  802a5e:	f7 65 e8             	mull   -0x18(%ebp)
  802a61:	39 d6                	cmp    %edx,%esi
  802a63:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802a66:	72 30                	jb     802a98 <__udivdi3+0x118>
  802a68:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802a6b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  802a6f:	d3 e2                	shl    %cl,%edx
  802a71:	39 c2                	cmp    %eax,%edx
  802a73:	73 05                	jae    802a7a <__udivdi3+0xfa>
  802a75:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  802a78:	74 1e                	je     802a98 <__udivdi3+0x118>
  802a7a:	89 f9                	mov    %edi,%ecx
  802a7c:	31 ff                	xor    %edi,%edi
  802a7e:	e9 71 ff ff ff       	jmp    8029f4 <__udivdi3+0x74>
  802a83:	90                   	nop
  802a84:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802a88:	31 ff                	xor    %edi,%edi
  802a8a:	b9 01 00 00 00       	mov    $0x1,%ecx
  802a8f:	e9 60 ff ff ff       	jmp    8029f4 <__udivdi3+0x74>
  802a94:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802a98:	8d 4f ff             	lea    -0x1(%edi),%ecx
  802a9b:	31 ff                	xor    %edi,%edi
  802a9d:	89 c8                	mov    %ecx,%eax
  802a9f:	89 fa                	mov    %edi,%edx
  802aa1:	83 c4 10             	add    $0x10,%esp
  802aa4:	5e                   	pop    %esi
  802aa5:	5f                   	pop    %edi
  802aa6:	5d                   	pop    %ebp
  802aa7:	c3                   	ret    
	...

00802ab0 <__umoddi3>:
  802ab0:	55                   	push   %ebp
  802ab1:	89 e5                	mov    %esp,%ebp
  802ab3:	57                   	push   %edi
  802ab4:	56                   	push   %esi
  802ab5:	83 ec 20             	sub    $0x20,%esp
  802ab8:	8b 55 14             	mov    0x14(%ebp),%edx
  802abb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802abe:	8b 7d 10             	mov    0x10(%ebp),%edi
  802ac1:	8b 75 0c             	mov    0xc(%ebp),%esi
  802ac4:	85 d2                	test   %edx,%edx
  802ac6:	89 c8                	mov    %ecx,%eax
  802ac8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  802acb:	75 13                	jne    802ae0 <__umoddi3+0x30>
  802acd:	39 f7                	cmp    %esi,%edi
  802acf:	76 3f                	jbe    802b10 <__umoddi3+0x60>
  802ad1:	89 f2                	mov    %esi,%edx
  802ad3:	f7 f7                	div    %edi
  802ad5:	89 d0                	mov    %edx,%eax
  802ad7:	31 d2                	xor    %edx,%edx
  802ad9:	83 c4 20             	add    $0x20,%esp
  802adc:	5e                   	pop    %esi
  802add:	5f                   	pop    %edi
  802ade:	5d                   	pop    %ebp
  802adf:	c3                   	ret    
  802ae0:	39 f2                	cmp    %esi,%edx
  802ae2:	77 4c                	ja     802b30 <__umoddi3+0x80>
  802ae4:	0f bd ca             	bsr    %edx,%ecx
  802ae7:	83 f1 1f             	xor    $0x1f,%ecx
  802aea:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  802aed:	75 51                	jne    802b40 <__umoddi3+0x90>
  802aef:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  802af2:	0f 87 e0 00 00 00    	ja     802bd8 <__umoddi3+0x128>
  802af8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802afb:	29 f8                	sub    %edi,%eax
  802afd:	19 d6                	sbb    %edx,%esi
  802aff:	89 45 f4             	mov    %eax,-0xc(%ebp)
  802b02:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802b05:	89 f2                	mov    %esi,%edx
  802b07:	83 c4 20             	add    $0x20,%esp
  802b0a:	5e                   	pop    %esi
  802b0b:	5f                   	pop    %edi
  802b0c:	5d                   	pop    %ebp
  802b0d:	c3                   	ret    
  802b0e:	66 90                	xchg   %ax,%ax
  802b10:	85 ff                	test   %edi,%edi
  802b12:	75 0b                	jne    802b1f <__umoddi3+0x6f>
  802b14:	b8 01 00 00 00       	mov    $0x1,%eax
  802b19:	31 d2                	xor    %edx,%edx
  802b1b:	f7 f7                	div    %edi
  802b1d:	89 c7                	mov    %eax,%edi
  802b1f:	89 f0                	mov    %esi,%eax
  802b21:	31 d2                	xor    %edx,%edx
  802b23:	f7 f7                	div    %edi
  802b25:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802b28:	f7 f7                	div    %edi
  802b2a:	eb a9                	jmp    802ad5 <__umoddi3+0x25>
  802b2c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802b30:	89 c8                	mov    %ecx,%eax
  802b32:	89 f2                	mov    %esi,%edx
  802b34:	83 c4 20             	add    $0x20,%esp
  802b37:	5e                   	pop    %esi
  802b38:	5f                   	pop    %edi
  802b39:	5d                   	pop    %ebp
  802b3a:	c3                   	ret    
  802b3b:	90                   	nop
  802b3c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802b40:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802b44:	d3 e2                	shl    %cl,%edx
  802b46:	89 55 f4             	mov    %edx,-0xc(%ebp)
  802b49:	ba 20 00 00 00       	mov    $0x20,%edx
  802b4e:	2b 55 f0             	sub    -0x10(%ebp),%edx
  802b51:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802b54:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802b58:	89 fa                	mov    %edi,%edx
  802b5a:	d3 ea                	shr    %cl,%edx
  802b5c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802b60:	0b 55 f4             	or     -0xc(%ebp),%edx
  802b63:	d3 e7                	shl    %cl,%edi
  802b65:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802b69:	89 55 f4             	mov    %edx,-0xc(%ebp)
  802b6c:	89 f2                	mov    %esi,%edx
  802b6e:	89 7d e8             	mov    %edi,-0x18(%ebp)
  802b71:	89 c7                	mov    %eax,%edi
  802b73:	d3 ea                	shr    %cl,%edx
  802b75:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802b79:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  802b7c:	89 c2                	mov    %eax,%edx
  802b7e:	d3 e6                	shl    %cl,%esi
  802b80:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802b84:	d3 ea                	shr    %cl,%edx
  802b86:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802b8a:	09 d6                	or     %edx,%esi
  802b8c:	89 f0                	mov    %esi,%eax
  802b8e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  802b91:	d3 e7                	shl    %cl,%edi
  802b93:	89 f2                	mov    %esi,%edx
  802b95:	f7 75 f4             	divl   -0xc(%ebp)
  802b98:	89 d6                	mov    %edx,%esi
  802b9a:	f7 65 e8             	mull   -0x18(%ebp)
  802b9d:	39 d6                	cmp    %edx,%esi
  802b9f:	72 2b                	jb     802bcc <__umoddi3+0x11c>
  802ba1:	39 c7                	cmp    %eax,%edi
  802ba3:	72 23                	jb     802bc8 <__umoddi3+0x118>
  802ba5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802ba9:	29 c7                	sub    %eax,%edi
  802bab:	19 d6                	sbb    %edx,%esi
  802bad:	89 f0                	mov    %esi,%eax
  802baf:	89 f2                	mov    %esi,%edx
  802bb1:	d3 ef                	shr    %cl,%edi
  802bb3:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802bb7:	d3 e0                	shl    %cl,%eax
  802bb9:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802bbd:	09 f8                	or     %edi,%eax
  802bbf:	d3 ea                	shr    %cl,%edx
  802bc1:	83 c4 20             	add    $0x20,%esp
  802bc4:	5e                   	pop    %esi
  802bc5:	5f                   	pop    %edi
  802bc6:	5d                   	pop    %ebp
  802bc7:	c3                   	ret    
  802bc8:	39 d6                	cmp    %edx,%esi
  802bca:	75 d9                	jne    802ba5 <__umoddi3+0xf5>
  802bcc:	2b 45 e8             	sub    -0x18(%ebp),%eax
  802bcf:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  802bd2:	eb d1                	jmp    802ba5 <__umoddi3+0xf5>
  802bd4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802bd8:	39 f2                	cmp    %esi,%edx
  802bda:	0f 82 18 ff ff ff    	jb     802af8 <__umoddi3+0x48>
  802be0:	e9 1d ff ff ff       	jmp    802b02 <__umoddi3+0x52>
