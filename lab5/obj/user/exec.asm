
obj/user/exec.debug:     file format elf32-i386


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
  80002c:	e8 7b 00 00 00       	call   8000ac <libmain>
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
  800037:	83 ec 18             	sub    $0x18,%esp
	int r;
	cprintf("i am parent environment %08x\n", thisenv->env_id);
  80003a:	a1 04 50 80 00       	mov    0x805004,%eax
  80003f:	8b 40 48             	mov    0x48(%eax),%eax
  800042:	89 44 24 04          	mov    %eax,0x4(%esp)
  800046:	c7 04 24 40 2b 80 00 	movl   $0x802b40,(%esp)
  80004d:	e8 83 01 00 00       	call   8001d5 <cprintf>
	if ((r = execl("/init", "init", 0)) < 0)
  800052:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800059:	00 
  80005a:	c7 44 24 04 5f 2b 80 	movl   $0x802b5f,0x4(%esp)
  800061:	00 
  800062:	c7 04 24 5e 2b 80 00 	movl   $0x802b5e,(%esp)
  800069:	e8 1f 22 00 00       	call   80228d <execl>
  80006e:	85 c0                	test   %eax,%eax
  800070:	79 20                	jns    800092 <umain+0x5e>
		panic("exec(init) failed: %e", r);
  800072:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800076:	c7 44 24 08 64 2b 80 	movl   $0x802b64,0x8(%esp)
  80007d:	00 
  80007e:	c7 44 24 04 09 00 00 	movl   $0x9,0x4(%esp)
  800085:	00 
  800086:	c7 04 24 7a 2b 80 00 	movl   $0x802b7a,(%esp)
  80008d:	e8 8a 00 00 00       	call   80011c <_panic>
        cprintf("i am parent environment %08x\n", thisenv->env_id);
  800092:	a1 04 50 80 00       	mov    0x805004,%eax
  800097:	8b 40 48             	mov    0x48(%eax),%eax
  80009a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80009e:	c7 04 24 40 2b 80 00 	movl   $0x802b40,(%esp)
  8000a5:	e8 2b 01 00 00       	call   8001d5 <cprintf>
}
  8000aa:	c9                   	leave  
  8000ab:	c3                   	ret    

008000ac <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000ac:	55                   	push   %ebp
  8000ad:	89 e5                	mov    %esp,%ebp
  8000af:	83 ec 18             	sub    $0x18,%esp
  8000b2:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8000b5:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8000b8:	8b 75 08             	mov    0x8(%ebp),%esi
  8000bb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  8000be:	e8 5f 13 00 00       	call   801422 <sys_getenvid>
  8000c3:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000c8:	89 c2                	mov    %eax,%edx
  8000ca:	c1 e2 07             	shl    $0x7,%edx
  8000cd:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  8000d4:	a3 04 50 80 00       	mov    %eax,0x805004
        //cprintf("ENVX sys_get_envid(): %d\n",ENVX(sys_getenvid()));
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000d9:	85 f6                	test   %esi,%esi
  8000db:	7e 07                	jle    8000e4 <libmain+0x38>
		binaryname = argv[0];
  8000dd:	8b 03                	mov    (%ebx),%eax
  8000df:	a3 00 40 80 00       	mov    %eax,0x804000

	// call user main routine
	umain(argc, argv);
  8000e4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000e8:	89 34 24             	mov    %esi,(%esp)
  8000eb:	e8 44 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000f0:	e8 0b 00 00 00       	call   800100 <exit>
}
  8000f5:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8000f8:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8000fb:	89 ec                	mov    %ebp,%esp
  8000fd:	5d                   	pop    %ebp
  8000fe:	c3                   	ret    
	...

00800100 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800100:	55                   	push   %ebp
  800101:	89 e5                	mov    %esp,%ebp
  800103:	83 ec 18             	sub    $0x18,%esp
	close_all();
  800106:	e8 a0 18 00 00       	call   8019ab <close_all>
	sys_env_destroy(0);
  80010b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800112:	e8 4b 13 00 00       	call   801462 <sys_env_destroy>
}
  800117:	c9                   	leave  
  800118:	c3                   	ret    
  800119:	00 00                	add    %al,(%eax)
	...

0080011c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80011c:	55                   	push   %ebp
  80011d:	89 e5                	mov    %esp,%ebp
  80011f:	56                   	push   %esi
  800120:	53                   	push   %ebx
  800121:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  800124:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800127:	8b 1d 00 40 80 00    	mov    0x804000,%ebx
  80012d:	e8 f0 12 00 00       	call   801422 <sys_getenvid>
  800132:	8b 55 0c             	mov    0xc(%ebp),%edx
  800135:	89 54 24 10          	mov    %edx,0x10(%esp)
  800139:	8b 55 08             	mov    0x8(%ebp),%edx
  80013c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800140:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800144:	89 44 24 04          	mov    %eax,0x4(%esp)
  800148:	c7 04 24 90 2b 80 00 	movl   $0x802b90,(%esp)
  80014f:	e8 81 00 00 00       	call   8001d5 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800154:	89 74 24 04          	mov    %esi,0x4(%esp)
  800158:	8b 45 10             	mov    0x10(%ebp),%eax
  80015b:	89 04 24             	mov    %eax,(%esp)
  80015e:	e8 11 00 00 00       	call   800174 <vcprintf>
	cprintf("\n");
  800163:	c7 04 24 e4 2f 80 00 	movl   $0x802fe4,(%esp)
  80016a:	e8 66 00 00 00       	call   8001d5 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80016f:	cc                   	int3   
  800170:	eb fd                	jmp    80016f <_panic+0x53>
	...

00800174 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  800174:	55                   	push   %ebp
  800175:	89 e5                	mov    %esp,%ebp
  800177:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80017d:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800184:	00 00 00 
	b.cnt = 0;
  800187:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80018e:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800191:	8b 45 0c             	mov    0xc(%ebp),%eax
  800194:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800198:	8b 45 08             	mov    0x8(%ebp),%eax
  80019b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80019f:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001a5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001a9:	c7 04 24 ef 01 80 00 	movl   $0x8001ef,(%esp)
  8001b0:	e8 d7 01 00 00       	call   80038c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001b5:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8001bb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001bf:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001c5:	89 04 24             	mov    %eax,(%esp)
  8001c8:	e8 6f 0d 00 00       	call   800f3c <sys_cputs>

	return b.cnt;
}
  8001cd:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001d3:	c9                   	leave  
  8001d4:	c3                   	ret    

008001d5 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001d5:	55                   	push   %ebp
  8001d6:	89 e5                	mov    %esp,%ebp
  8001d8:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  8001db:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  8001de:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8001e5:	89 04 24             	mov    %eax,(%esp)
  8001e8:	e8 87 ff ff ff       	call   800174 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001ed:	c9                   	leave  
  8001ee:	c3                   	ret    

008001ef <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001ef:	55                   	push   %ebp
  8001f0:	89 e5                	mov    %esp,%ebp
  8001f2:	53                   	push   %ebx
  8001f3:	83 ec 14             	sub    $0x14,%esp
  8001f6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001f9:	8b 03                	mov    (%ebx),%eax
  8001fb:	8b 55 08             	mov    0x8(%ebp),%edx
  8001fe:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800202:	83 c0 01             	add    $0x1,%eax
  800205:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800207:	3d ff 00 00 00       	cmp    $0xff,%eax
  80020c:	75 19                	jne    800227 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80020e:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800215:	00 
  800216:	8d 43 08             	lea    0x8(%ebx),%eax
  800219:	89 04 24             	mov    %eax,(%esp)
  80021c:	e8 1b 0d 00 00       	call   800f3c <sys_cputs>
		b->idx = 0;
  800221:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800227:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80022b:	83 c4 14             	add    $0x14,%esp
  80022e:	5b                   	pop    %ebx
  80022f:	5d                   	pop    %ebp
  800230:	c3                   	ret    
	...

00800240 <printnum_v2>:
 */

static void 
printnum_v2(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800240:	55                   	push   %ebp
  800241:	89 e5                	mov    %esp,%ebp
  800243:	57                   	push   %edi
  800244:	56                   	push   %esi
  800245:	53                   	push   %ebx
  800246:	83 ec 4c             	sub    $0x4c,%esp
  800249:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80024c:	89 d6                	mov    %edx,%esi
  80024e:	8b 45 08             	mov    0x8(%ebp),%eax
  800251:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800254:	8b 55 0c             	mov    0xc(%ebp),%edx
  800257:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80025a:	8b 45 10             	mov    0x10(%ebp),%eax
  80025d:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800260:	8b 7d 18             	mov    0x18(%ebp),%edi
    if (num >= base) {
  800263:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800266:	b9 00 00 00 00       	mov    $0x0,%ecx
  80026b:	39 d1                	cmp    %edx,%ecx
  80026d:	72 07                	jb     800276 <printnum_v2+0x36>
  80026f:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800272:	39 d0                	cmp    %edx,%eax
  800274:	77 5f                	ja     8002d5 <printnum_v2+0x95>
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
  800276:	89 7c 24 10          	mov    %edi,0x10(%esp)
  80027a:	83 eb 01             	sub    $0x1,%ebx
  80027d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800281:	89 44 24 08          	mov    %eax,0x8(%esp)
  800285:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800289:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  80028d:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800290:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  800293:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800296:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80029a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002a1:	00 
  8002a2:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8002a5:	89 04 24             	mov    %eax,(%esp)
  8002a8:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8002ab:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002af:	e8 1c 26 00 00       	call   8028d0 <__udivdi3>
  8002b4:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8002b7:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8002ba:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8002be:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002c2:	89 04 24             	mov    %eax,(%esp)
  8002c5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002c9:	89 f2                	mov    %esi,%edx
  8002cb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002ce:	e8 6d ff ff ff       	call   800240 <printnum_v2>
  8002d3:	eb 1e                	jmp    8002f3 <printnum_v2+0xb3>
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
  8002d5:	83 ff 2d             	cmp    $0x2d,%edi
  8002d8:	74 19                	je     8002f3 <printnum_v2+0xb3>
		while (--width > 0)
  8002da:	83 eb 01             	sub    $0x1,%ebx
  8002dd:	85 db                	test   %ebx,%ebx
  8002df:	90                   	nop
  8002e0:	7e 11                	jle    8002f3 <printnum_v2+0xb3>
			putch(padc, putdat);
  8002e2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002e6:	89 3c 24             	mov    %edi,(%esp)
  8002e9:	ff 55 e4             	call   *-0x1c(%ebp)
    if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
		while (--width > 0)
  8002ec:	83 eb 01             	sub    $0x1,%ebx
  8002ef:	85 db                	test   %ebx,%ebx
  8002f1:	7f ef                	jg     8002e2 <printnum_v2+0xa2>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002f3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002f7:	8b 74 24 04          	mov    0x4(%esp),%esi
  8002fb:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002fe:	89 44 24 08          	mov    %eax,0x8(%esp)
  800302:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800309:	00 
  80030a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80030d:	89 14 24             	mov    %edx,(%esp)
  800310:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800313:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800317:	e8 e4 26 00 00       	call   802a00 <__umoddi3>
  80031c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800320:	0f be 80 b3 2b 80 00 	movsbl 0x802bb3(%eax),%eax
  800327:	89 04 24             	mov    %eax,(%esp)
  80032a:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80032d:	83 c4 4c             	add    $0x4c,%esp
  800330:	5b                   	pop    %ebx
  800331:	5e                   	pop    %esi
  800332:	5f                   	pop    %edi
  800333:	5d                   	pop    %ebp
  800334:	c3                   	ret    

00800335 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800335:	55                   	push   %ebp
  800336:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800338:	83 fa 01             	cmp    $0x1,%edx
  80033b:	7e 0e                	jle    80034b <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80033d:	8b 10                	mov    (%eax),%edx
  80033f:	8d 4a 08             	lea    0x8(%edx),%ecx
  800342:	89 08                	mov    %ecx,(%eax)
  800344:	8b 02                	mov    (%edx),%eax
  800346:	8b 52 04             	mov    0x4(%edx),%edx
  800349:	eb 22                	jmp    80036d <getuint+0x38>
	else if (lflag)
  80034b:	85 d2                	test   %edx,%edx
  80034d:	74 10                	je     80035f <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80034f:	8b 10                	mov    (%eax),%edx
  800351:	8d 4a 04             	lea    0x4(%edx),%ecx
  800354:	89 08                	mov    %ecx,(%eax)
  800356:	8b 02                	mov    (%edx),%eax
  800358:	ba 00 00 00 00       	mov    $0x0,%edx
  80035d:	eb 0e                	jmp    80036d <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80035f:	8b 10                	mov    (%eax),%edx
  800361:	8d 4a 04             	lea    0x4(%edx),%ecx
  800364:	89 08                	mov    %ecx,(%eax)
  800366:	8b 02                	mov    (%edx),%eax
  800368:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80036d:	5d                   	pop    %ebp
  80036e:	c3                   	ret    

0080036f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80036f:	55                   	push   %ebp
  800370:	89 e5                	mov    %esp,%ebp
  800372:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800375:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800379:	8b 10                	mov    (%eax),%edx
  80037b:	3b 50 04             	cmp    0x4(%eax),%edx
  80037e:	73 0a                	jae    80038a <sprintputch+0x1b>
		*b->buf++ = ch;
  800380:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800383:	88 0a                	mov    %cl,(%edx)
  800385:	83 c2 01             	add    $0x1,%edx
  800388:	89 10                	mov    %edx,(%eax)
}
  80038a:	5d                   	pop    %ebp
  80038b:	c3                   	ret    

0080038c <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80038c:	55                   	push   %ebp
  80038d:	89 e5                	mov    %esp,%ebp
  80038f:	57                   	push   %edi
  800390:	56                   	push   %esi
  800391:	53                   	push   %ebx
  800392:	83 ec 6c             	sub    $0x6c,%esp
  800395:	8b 7d 10             	mov    0x10(%ebp),%edi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800398:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  80039f:	eb 1a                	jmp    8003bb <vprintfmt+0x2f>
	int base, lflag, width, precision, altflag,signflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003a1:	85 c0                	test   %eax,%eax
  8003a3:	0f 84 66 06 00 00    	je     800a0f <vprintfmt+0x683>
				return;
			putch(ch, putdat);
  8003a9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003ac:	89 54 24 04          	mov    %edx,0x4(%esp)
  8003b0:	89 04 24             	mov    %eax,(%esp)
  8003b3:	ff 55 08             	call   *0x8(%ebp)
  8003b6:	eb 03                	jmp    8003bb <vprintfmt+0x2f>
  8003b8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag,signflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003bb:	0f b6 07             	movzbl (%edi),%eax
  8003be:	83 c7 01             	add    $0x1,%edi
  8003c1:	83 f8 25             	cmp    $0x25,%eax
  8003c4:	75 db                	jne    8003a1 <vprintfmt+0x15>
  8003c6:	c6 45 cc 20          	movb   $0x20,-0x34(%ebp)
  8003ca:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003cf:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  8003d6:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
  8003db:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8003e2:	be 00 00 00 00       	mov    $0x0,%esi
  8003e7:	eb 06                	jmp    8003ef <vprintfmt+0x63>
  8003e9:	c6 45 cc 2d          	movb   $0x2d,-0x34(%ebp)
  8003ed:	89 c7                	mov    %eax,%edi
		precision = -1;
		lflag = 0;
		altflag = 0;
                signflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ef:	0f b6 17             	movzbl (%edi),%edx
  8003f2:	0f b6 c2             	movzbl %dl,%eax
  8003f5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003f8:	8d 47 01             	lea    0x1(%edi),%eax
  8003fb:	83 ea 23             	sub    $0x23,%edx
  8003fe:	80 fa 55             	cmp    $0x55,%dl
  800401:	0f 87 60 05 00 00    	ja     800967 <vprintfmt+0x5db>
  800407:	0f b6 d2             	movzbl %dl,%edx
  80040a:	ff 24 95 a0 2d 80 00 	jmp    *0x802da0(,%edx,4)
  800411:	b9 01 00 00 00       	mov    $0x1,%ecx
  800416:	eb d5                	jmp    8003ed <vprintfmt+0x61>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800418:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80041b:	83 eb 30             	sub    $0x30,%ebx
				ch = *fmt;
  80041e:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  800421:	8d 7a d0             	lea    -0x30(%edx),%edi
  800424:	83 ff 09             	cmp    $0x9,%edi
  800427:	76 08                	jbe    800431 <vprintfmt+0xa5>
  800429:	eb 40                	jmp    80046b <vprintfmt+0xdf>
  80042b:	c6 45 cc 30          	movb   $0x30,-0x34(%ebp)
                        signflag = 1;
                        goto reswitch;
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
			goto reswitch;
  80042f:	eb bc                	jmp    8003ed <vprintfmt+0x61>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800431:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  800434:	8d 1c 9b             	lea    (%ebx,%ebx,4),%ebx
  800437:	8d 5c 5a d0          	lea    -0x30(%edx,%ebx,2),%ebx
				ch = *fmt;
  80043b:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  80043e:	8d 7a d0             	lea    -0x30(%edx),%edi
  800441:	83 ff 09             	cmp    $0x9,%edi
  800444:	76 eb                	jbe    800431 <vprintfmt+0xa5>
  800446:	eb 23                	jmp    80046b <vprintfmt+0xdf>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800448:	8b 55 14             	mov    0x14(%ebp),%edx
  80044b:	8d 5a 04             	lea    0x4(%edx),%ebx
  80044e:	89 5d 14             	mov    %ebx,0x14(%ebp)
  800451:	8b 1a                	mov    (%edx),%ebx
			goto process_precision;
  800453:	eb 16                	jmp    80046b <vprintfmt+0xdf>

		case '.':
			if (width < 0)
  800455:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800458:	c1 fa 1f             	sar    $0x1f,%edx
  80045b:	f7 d2                	not    %edx
  80045d:	21 55 d8             	and    %edx,-0x28(%ebp)
  800460:	eb 8b                	jmp    8003ed <vprintfmt+0x61>
  800462:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  800469:	eb 82                	jmp    8003ed <vprintfmt+0x61>

		process_precision:
			if (width < 0)
  80046b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80046f:	0f 89 78 ff ff ff    	jns    8003ed <vprintfmt+0x61>
  800475:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800478:	8b 5d c8             	mov    -0x38(%ebp),%ebx
  80047b:	e9 6d ff ff ff       	jmp    8003ed <vprintfmt+0x61>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800480:	83 c6 01             	add    $0x1,%esi
			goto reswitch;
  800483:	e9 65 ff ff ff       	jmp    8003ed <vprintfmt+0x61>
  800488:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80048b:	8b 45 14             	mov    0x14(%ebp),%eax
  80048e:	8d 50 04             	lea    0x4(%eax),%edx
  800491:	89 55 14             	mov    %edx,0x14(%ebp)
  800494:	8b 55 0c             	mov    0xc(%ebp),%edx
  800497:	89 54 24 04          	mov    %edx,0x4(%esp)
  80049b:	8b 00                	mov    (%eax),%eax
  80049d:	89 04 24             	mov    %eax,(%esp)
  8004a0:	ff 55 08             	call   *0x8(%ebp)
  8004a3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;
  8004a6:	e9 10 ff ff ff       	jmp    8003bb <vprintfmt+0x2f>
  8004ab:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b1:	8d 50 04             	lea    0x4(%eax),%edx
  8004b4:	89 55 14             	mov    %edx,0x14(%ebp)
  8004b7:	8b 00                	mov    (%eax),%eax
  8004b9:	89 c2                	mov    %eax,%edx
  8004bb:	c1 fa 1f             	sar    $0x1f,%edx
  8004be:	31 d0                	xor    %edx,%eax
  8004c0:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004c2:	83 f8 0f             	cmp    $0xf,%eax
  8004c5:	7f 0b                	jg     8004d2 <vprintfmt+0x146>
  8004c7:	8b 14 85 00 2f 80 00 	mov    0x802f00(,%eax,4),%edx
  8004ce:	85 d2                	test   %edx,%edx
  8004d0:	75 26                	jne    8004f8 <vprintfmt+0x16c>
				printfmt(putch, putdat, "error %d", err);
  8004d2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004d6:	c7 44 24 08 c4 2b 80 	movl   $0x802bc4,0x8(%esp)
  8004dd:	00 
  8004de:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8004e1:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8004e5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8004e8:	89 1c 24             	mov    %ebx,(%esp)
  8004eb:	e8 a7 05 00 00       	call   800a97 <printfmt>
  8004f0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004f3:	e9 c3 fe ff ff       	jmp    8003bb <vprintfmt+0x2f>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  8004f8:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004fc:	c7 44 24 08 45 30 80 	movl   $0x803045,0x8(%esp)
  800503:	00 
  800504:	8b 45 0c             	mov    0xc(%ebp),%eax
  800507:	89 44 24 04          	mov    %eax,0x4(%esp)
  80050b:	8b 55 08             	mov    0x8(%ebp),%edx
  80050e:	89 14 24             	mov    %edx,(%esp)
  800511:	e8 81 05 00 00       	call   800a97 <printfmt>
  800516:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800519:	e9 9d fe ff ff       	jmp    8003bb <vprintfmt+0x2f>
  80051e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800521:	89 c7                	mov    %eax,%edi
  800523:	89 d9                	mov    %ebx,%ecx
  800525:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800528:	89 45 c0             	mov    %eax,-0x40(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80052b:	8b 45 14             	mov    0x14(%ebp),%eax
  80052e:	8d 50 04             	lea    0x4(%eax),%edx
  800531:	89 55 14             	mov    %edx,0x14(%ebp)
  800534:	8b 30                	mov    (%eax),%esi
  800536:	85 f6                	test   %esi,%esi
  800538:	75 05                	jne    80053f <vprintfmt+0x1b3>
  80053a:	be cd 2b 80 00       	mov    $0x802bcd,%esi
				p = "(null)";
			if (width > 0 && padc != '-')
  80053f:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
  800543:	7e 06                	jle    80054b <vprintfmt+0x1bf>
  800545:	80 7d cc 2d          	cmpb   $0x2d,-0x34(%ebp)
  800549:	75 10                	jne    80055b <vprintfmt+0x1cf>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80054b:	0f be 06             	movsbl (%esi),%eax
  80054e:	85 c0                	test   %eax,%eax
  800550:	0f 85 a2 00 00 00    	jne    8005f8 <vprintfmt+0x26c>
  800556:	e9 92 00 00 00       	jmp    8005ed <vprintfmt+0x261>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80055b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80055f:	89 34 24             	mov    %esi,(%esp)
  800562:	e8 74 05 00 00       	call   800adb <strnlen>
  800567:	8b 55 c0             	mov    -0x40(%ebp),%edx
  80056a:	29 c2                	sub    %eax,%edx
  80056c:	89 55 d8             	mov    %edx,-0x28(%ebp)
  80056f:	85 d2                	test   %edx,%edx
  800571:	7e d8                	jle    80054b <vprintfmt+0x1bf>
					putch(padc, putdat);
  800573:	0f be 4d cc          	movsbl -0x34(%ebp),%ecx
  800577:	89 5d c0             	mov    %ebx,-0x40(%ebp)
  80057a:	89 d3                	mov    %edx,%ebx
  80057c:	89 75 d8             	mov    %esi,-0x28(%ebp)
  80057f:	89 7d bc             	mov    %edi,-0x44(%ebp)
  800582:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800585:	89 ce                	mov    %ecx,%esi
  800587:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80058b:	89 34 24             	mov    %esi,(%esp)
  80058e:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800591:	83 eb 01             	sub    $0x1,%ebx
  800594:	85 db                	test   %ebx,%ebx
  800596:	7f ef                	jg     800587 <vprintfmt+0x1fb>
  800598:	8b 5d c0             	mov    -0x40(%ebp),%ebx
  80059b:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80059e:	8b 7d bc             	mov    -0x44(%ebp),%edi
  8005a1:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8005a8:	eb a1                	jmp    80054b <vprintfmt+0x1bf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005aa:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  8005ae:	74 1b                	je     8005cb <vprintfmt+0x23f>
  8005b0:	8d 50 e0             	lea    -0x20(%eax),%edx
  8005b3:	83 fa 5e             	cmp    $0x5e,%edx
  8005b6:	76 13                	jbe    8005cb <vprintfmt+0x23f>
					putch('?', putdat);
  8005b8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005bb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005bf:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8005c6:	ff 55 08             	call   *0x8(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005c9:	eb 0d                	jmp    8005d8 <vprintfmt+0x24c>
					putch('?', putdat);
				else
					putch(ch, putdat);
  8005cb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8005ce:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005d2:	89 04 24             	mov    %eax,(%esp)
  8005d5:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005d8:	83 ef 01             	sub    $0x1,%edi
  8005db:	0f be 06             	movsbl (%esi),%eax
  8005de:	85 c0                	test   %eax,%eax
  8005e0:	74 05                	je     8005e7 <vprintfmt+0x25b>
  8005e2:	83 c6 01             	add    $0x1,%esi
  8005e5:	eb 1a                	jmp    800601 <vprintfmt+0x275>
  8005e7:	89 7d d8             	mov    %edi,-0x28(%ebp)
  8005ea:	8b 7d cc             	mov    -0x34(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005ed:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005f1:	7f 1f                	jg     800612 <vprintfmt+0x286>
  8005f3:	e9 c0 fd ff ff       	jmp    8003b8 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005f8:	83 c6 01             	add    $0x1,%esi
  8005fb:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8005fe:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800601:	85 db                	test   %ebx,%ebx
  800603:	78 a5                	js     8005aa <vprintfmt+0x21e>
  800605:	83 eb 01             	sub    $0x1,%ebx
  800608:	79 a0                	jns    8005aa <vprintfmt+0x21e>
  80060a:	89 7d d8             	mov    %edi,-0x28(%ebp)
  80060d:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800610:	eb db                	jmp    8005ed <vprintfmt+0x261>
  800612:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800615:	8b 75 0c             	mov    0xc(%ebp),%esi
  800618:	89 7d d8             	mov    %edi,-0x28(%ebp)
  80061b:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80061e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800622:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800629:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80062b:	83 eb 01             	sub    $0x1,%ebx
  80062e:	85 db                	test   %ebx,%ebx
  800630:	7f ec                	jg     80061e <vprintfmt+0x292>
  800632:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800635:	e9 81 fd ff ff       	jmp    8003bb <vprintfmt+0x2f>
  80063a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80063d:	83 fe 01             	cmp    $0x1,%esi
  800640:	7e 10                	jle    800652 <vprintfmt+0x2c6>
		return va_arg(*ap, long long);
  800642:	8b 45 14             	mov    0x14(%ebp),%eax
  800645:	8d 50 08             	lea    0x8(%eax),%edx
  800648:	89 55 14             	mov    %edx,0x14(%ebp)
  80064b:	8b 18                	mov    (%eax),%ebx
  80064d:	8b 70 04             	mov    0x4(%eax),%esi
  800650:	eb 26                	jmp    800678 <vprintfmt+0x2ec>
	else if (lflag)
  800652:	85 f6                	test   %esi,%esi
  800654:	74 12                	je     800668 <vprintfmt+0x2dc>
		return va_arg(*ap, long);
  800656:	8b 45 14             	mov    0x14(%ebp),%eax
  800659:	8d 50 04             	lea    0x4(%eax),%edx
  80065c:	89 55 14             	mov    %edx,0x14(%ebp)
  80065f:	8b 18                	mov    (%eax),%ebx
  800661:	89 de                	mov    %ebx,%esi
  800663:	c1 fe 1f             	sar    $0x1f,%esi
  800666:	eb 10                	jmp    800678 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  800668:	8b 45 14             	mov    0x14(%ebp),%eax
  80066b:	8d 50 04             	lea    0x4(%eax),%edx
  80066e:	89 55 14             	mov    %edx,0x14(%ebp)
  800671:	8b 18                	mov    (%eax),%ebx
  800673:	89 de                	mov    %ebx,%esi
  800675:	c1 fe 1f             	sar    $0x1f,%esi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
                        if(signflag == 1){
  800678:	83 f9 01             	cmp    $0x1,%ecx
  80067b:	75 1e                	jne    80069b <vprintfmt+0x30f>
                               if((long long)num > 0){
  80067d:	85 f6                	test   %esi,%esi
  80067f:	78 1a                	js     80069b <vprintfmt+0x30f>
  800681:	85 f6                	test   %esi,%esi
  800683:	7f 05                	jg     80068a <vprintfmt+0x2fe>
  800685:	83 fb 00             	cmp    $0x0,%ebx
  800688:	76 11                	jbe    80069b <vprintfmt+0x30f>
                                   putch('+',putdat);
  80068a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80068d:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800691:	c7 04 24 2b 00 00 00 	movl   $0x2b,(%esp)
  800698:	ff 55 08             	call   *0x8(%ebp)
                               }
                        }
			if ((long long) num < 0) {
  80069b:	85 f6                	test   %esi,%esi
  80069d:	78 13                	js     8006b2 <vprintfmt+0x326>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80069f:	89 5d b0             	mov    %ebx,-0x50(%ebp)
  8006a2:	89 75 b4             	mov    %esi,-0x4c(%ebp)
  8006a5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006a8:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006ad:	e9 da 00 00 00       	jmp    80078c <vprintfmt+0x400>
                               if((long long)num > 0){
                                   putch('+',putdat);
                               }
                        }
			if ((long long) num < 0) {
				putch('-', putdat);
  8006b2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006b5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006b9:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8006c0:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8006c3:	89 da                	mov    %ebx,%edx
  8006c5:	89 f1                	mov    %esi,%ecx
  8006c7:	f7 da                	neg    %edx
  8006c9:	83 d1 00             	adc    $0x0,%ecx
  8006cc:	f7 d9                	neg    %ecx
  8006ce:	89 55 b0             	mov    %edx,-0x50(%ebp)
  8006d1:	89 4d b4             	mov    %ecx,-0x4c(%ebp)
  8006d4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006d7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006dc:	e9 ab 00 00 00       	jmp    80078c <vprintfmt+0x400>
  8006e1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006e4:	89 f2                	mov    %esi,%edx
  8006e6:	8d 45 14             	lea    0x14(%ebp),%eax
  8006e9:	e8 47 fc ff ff       	call   800335 <getuint>
  8006ee:	89 45 b0             	mov    %eax,-0x50(%ebp)
  8006f1:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  8006f4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006f7:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
  8006fc:	e9 8b 00 00 00       	jmp    80078c <vprintfmt+0x400>
  800701:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			putch('0', putdat);
  800704:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800707:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80070b:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800712:	ff 55 08             	call   *0x8(%ebp)
			num = getuint(&ap,lflag);
  800715:	89 f2                	mov    %esi,%edx
  800717:	8d 45 14             	lea    0x14(%ebp),%eax
  80071a:	e8 16 fc ff ff       	call   800335 <getuint>
  80071f:	89 45 b0             	mov    %eax,-0x50(%ebp)
  800722:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  800725:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800728:	b8 08 00 00 00       	mov    $0x8,%eax
                        base = 8;
			goto number;
  80072d:	eb 5d                	jmp    80078c <vprintfmt+0x400>
  80072f:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
  800732:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800735:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800739:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800740:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800743:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800747:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80074e:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  800751:	8b 45 14             	mov    0x14(%ebp),%eax
  800754:	8d 50 04             	lea    0x4(%eax),%edx
  800757:	89 55 14             	mov    %edx,0x14(%ebp)
  80075a:	8b 10                	mov    (%eax),%edx
  80075c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800761:	89 55 b0             	mov    %edx,-0x50(%ebp)
  800764:	89 4d b4             	mov    %ecx,-0x4c(%ebp)
  800767:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80076a:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80076f:	eb 1b                	jmp    80078c <vprintfmt+0x400>
  800771:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800774:	89 f2                	mov    %esi,%edx
  800776:	8d 45 14             	lea    0x14(%ebp),%eax
  800779:	e8 b7 fb ff ff       	call   800335 <getuint>
  80077e:	89 45 b0             	mov    %eax,-0x50(%ebp)
  800781:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  800784:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800787:	b8 10 00 00 00       	mov    $0x10,%eax
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  80078c:	0f be 4d cc          	movsbl -0x34(%ebp),%ecx
  800790:	89 4d d0             	mov    %ecx,-0x30(%ebp)
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800793:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800796:	83 7d b4 00          	cmpl   $0x0,-0x4c(%ebp)
  80079a:	77 09                	ja     8007a5 <vprintfmt+0x419>
  80079c:	39 45 b0             	cmp    %eax,-0x50(%ebp)
  80079f:	0f 82 ac 00 00 00    	jb     800851 <vprintfmt+0x4c5>
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
  8007a5:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8007a8:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  8007ac:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007af:	83 ea 01             	sub    $0x1,%edx
  8007b2:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8007b6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007ba:	8b 44 24 08          	mov    0x8(%esp),%eax
  8007be:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8007c2:	89 45 c0             	mov    %eax,-0x40(%ebp)
  8007c5:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  8007c8:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8007cb:	89 54 24 08          	mov    %edx,0x8(%esp)
  8007cf:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8007d6:	00 
  8007d7:	8b 4d b0             	mov    -0x50(%ebp),%ecx
  8007da:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
  8007dd:	89 0c 24             	mov    %ecx,(%esp)
  8007e0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007e4:	e8 e7 20 00 00       	call   8028d0 <__udivdi3>
  8007e9:	8b 4d c0             	mov    -0x40(%ebp),%ecx
  8007ec:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  8007ef:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8007f3:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8007f7:	89 04 24             	mov    %eax,(%esp)
  8007fa:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007fe:	8b 55 0c             	mov    0xc(%ebp),%edx
  800801:	8b 45 08             	mov    0x8(%ebp),%eax
  800804:	e8 37 fa ff ff       	call   800240 <printnum_v2>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800809:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80080c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800810:	8b 74 24 04          	mov    0x4(%esp),%esi
  800814:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800817:	89 44 24 08          	mov    %eax,0x8(%esp)
  80081b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800822:	00 
  800823:	8b 55 b0             	mov    -0x50(%ebp),%edx
  800826:	8b 4d b4             	mov    -0x4c(%ebp),%ecx
  800829:	89 14 24             	mov    %edx,(%esp)
  80082c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800830:	e8 cb 21 00 00       	call   802a00 <__umoddi3>
  800835:	89 74 24 04          	mov    %esi,0x4(%esp)
  800839:	0f be 80 b3 2b 80 00 	movsbl 0x802bb3(%eax),%eax
  800840:	89 04 24             	mov    %eax,(%esp)
  800843:	ff 55 08             	call   *0x8(%ebp)
        if(padc == '-'){
  800846:	83 7d d0 2d          	cmpl   $0x2d,-0x30(%ebp)
  80084a:	74 54                	je     8008a0 <vprintfmt+0x514>
  80084c:	e9 67 fb ff ff       	jmp    8003b8 <vprintfmt+0x2c>
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
  800851:	83 7d d0 2d          	cmpl   $0x2d,-0x30(%ebp)
  800855:	8d 76 00             	lea    0x0(%esi),%esi
  800858:	0f 84 2a 01 00 00    	je     800988 <vprintfmt+0x5fc>
		while (--width > 0)
  80085e:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800861:	83 ef 01             	sub    $0x1,%edi
  800864:	85 ff                	test   %edi,%edi
  800866:	0f 8e 5e 01 00 00    	jle    8009ca <vprintfmt+0x63e>
  80086c:	8b 4d b0             	mov    -0x50(%ebp),%ecx
  80086f:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
  800872:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  800875:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  800878:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80087b:	8b 75 0c             	mov    0xc(%ebp),%esi
			putch(padc, putdat);
  80087e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800882:	89 1c 24             	mov    %ebx,(%esp)
  800885:	ff 55 08             	call   *0x8(%ebp)
	if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
		while (--width > 0)
  800888:	83 ef 01             	sub    $0x1,%edi
  80088b:	85 ff                	test   %edi,%edi
  80088d:	7f ef                	jg     80087e <vprintfmt+0x4f2>
  80088f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800892:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800895:	89 45 b0             	mov    %eax,-0x50(%ebp)
  800898:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  80089b:	e9 2a 01 00 00       	jmp    8009ca <vprintfmt+0x63e>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
        if(padc == '-'){
           while (--width > 0)
  8008a0:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  8008a3:	83 eb 01             	sub    $0x1,%ebx
  8008a6:	85 db                	test   %ebx,%ebx
  8008a8:	0f 8e 0a fb ff ff    	jle    8003b8 <vprintfmt+0x2c>
  8008ae:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008b1:	89 7d d8             	mov    %edi,-0x28(%ebp)
  8008b4:	8b 7d 08             	mov    0x8(%ebp),%edi
			putch(' ', putdat);
  8008b7:	89 74 24 04          	mov    %esi,0x4(%esp)
  8008bb:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8008c2:	ff d7                	call   *%edi
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
        if(padc == '-'){
           while (--width > 0)
  8008c4:	83 eb 01             	sub    $0x1,%ebx
  8008c7:	85 db                	test   %ebx,%ebx
  8008c9:	7f ec                	jg     8008b7 <vprintfmt+0x52b>
  8008cb:	8b 7d d8             	mov    -0x28(%ebp),%edi
  8008ce:	e9 e8 fa ff ff       	jmp    8003bb <vprintfmt+0x2f>
  8008d3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
            char* n;
            if ((n = va_arg(ap, char *)) == NULL)
  8008d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8008d9:	8d 50 04             	lea    0x4(%eax),%edx
  8008dc:	89 55 14             	mov    %edx,0x14(%ebp)
  8008df:	8b 00                	mov    (%eax),%eax
  8008e1:	85 c0                	test   %eax,%eax
  8008e3:	75 2a                	jne    80090f <vprintfmt+0x583>
		  printfmt(putch,putdat,"%s",null_error);
  8008e5:	c7 44 24 0c e8 2c 80 	movl   $0x802ce8,0xc(%esp)
  8008ec:	00 
  8008ed:	c7 44 24 08 45 30 80 	movl   $0x803045,0x8(%esp)
  8008f4:	00 
  8008f5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008f8:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008fc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008ff:	89 0c 24             	mov    %ecx,(%esp)
  800902:	e8 90 01 00 00       	call   800a97 <printfmt>
  800907:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80090a:	e9 ac fa ff ff       	jmp    8003bb <vprintfmt+0x2f>
            else if((*(int*)putdat) > 127){
  80090f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800912:	8b 13                	mov    (%ebx),%edx
  800914:	83 fa 7f             	cmp    $0x7f,%edx
  800917:	7e 29                	jle    800942 <vprintfmt+0x5b6>
                  *n = *(int*)putdat;
  800919:	88 10                	mov    %dl,(%eax)
                  printfmt(putch,putdat,"%s",overflow_error);
  80091b:	c7 44 24 0c 20 2d 80 	movl   $0x802d20,0xc(%esp)
  800922:	00 
  800923:	c7 44 24 08 45 30 80 	movl   $0x803045,0x8(%esp)
  80092a:	00 
  80092b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80092f:	8b 45 08             	mov    0x8(%ebp),%eax
  800932:	89 04 24             	mov    %eax,(%esp)
  800935:	e8 5d 01 00 00       	call   800a97 <printfmt>
  80093a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80093d:	e9 79 fa ff ff       	jmp    8003bb <vprintfmt+0x2f>
            }
            else
                  *n = *(int*)putdat;
  800942:	88 10                	mov    %dl,(%eax)
  800944:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800947:	e9 6f fa ff ff       	jmp    8003bb <vprintfmt+0x2f>
  80094c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80094f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            break;
        }
		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800952:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800955:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800959:	89 14 24             	mov    %edx,(%esp)
  80095c:	ff 55 08             	call   *0x8(%ebp)
  80095f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;
  800962:	e9 54 fa ff ff       	jmp    8003bb <vprintfmt+0x2f>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800967:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80096a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80096e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800975:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800978:	8d 47 ff             	lea    -0x1(%edi),%eax
  80097b:	80 38 25             	cmpb   $0x25,(%eax)
  80097e:	0f 84 37 fa ff ff    	je     8003bb <vprintfmt+0x2f>
  800984:	89 c7                	mov    %eax,%edi
  800986:	eb f0                	jmp    800978 <vprintfmt+0x5ec>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800988:	8b 45 0c             	mov    0xc(%ebp),%eax
  80098b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80098f:	8b 74 24 04          	mov    0x4(%esp),%esi
  800993:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800996:	89 54 24 08          	mov    %edx,0x8(%esp)
  80099a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8009a1:	00 
  8009a2:	8b 45 b0             	mov    -0x50(%ebp),%eax
  8009a5:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  8009a8:	89 04 24             	mov    %eax,(%esp)
  8009ab:	89 54 24 04          	mov    %edx,0x4(%esp)
  8009af:	e8 4c 20 00 00       	call   802a00 <__umoddi3>
  8009b4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8009b8:	0f be 80 b3 2b 80 00 	movsbl 0x802bb3(%eax),%eax
  8009bf:	89 04 24             	mov    %eax,(%esp)
  8009c2:	ff 55 08             	call   *0x8(%ebp)
  8009c5:	e9 d6 fe ff ff       	jmp    8008a0 <vprintfmt+0x514>
  8009ca:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009cd:	89 54 24 04          	mov    %edx,0x4(%esp)
  8009d1:	8b 74 24 04          	mov    0x4(%esp),%esi
  8009d5:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8009d8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8009dc:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8009e3:	00 
  8009e4:	8b 45 b0             	mov    -0x50(%ebp),%eax
  8009e7:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  8009ea:	89 04 24             	mov    %eax,(%esp)
  8009ed:	89 54 24 04          	mov    %edx,0x4(%esp)
  8009f1:	e8 0a 20 00 00       	call   802a00 <__umoddi3>
  8009f6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8009fa:	0f be 80 b3 2b 80 00 	movsbl 0x802bb3(%eax),%eax
  800a01:	89 04 24             	mov    %eax,(%esp)
  800a04:	ff 55 08             	call   *0x8(%ebp)
  800a07:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800a0a:	e9 ac f9 ff ff       	jmp    8003bb <vprintfmt+0x2f>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800a0f:	83 c4 6c             	add    $0x6c,%esp
  800a12:	5b                   	pop    %ebx
  800a13:	5e                   	pop    %esi
  800a14:	5f                   	pop    %edi
  800a15:	5d                   	pop    %ebp
  800a16:	c3                   	ret    

00800a17 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800a17:	55                   	push   %ebp
  800a18:	89 e5                	mov    %esp,%ebp
  800a1a:	83 ec 28             	sub    $0x28,%esp
  800a1d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a20:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  800a23:	85 c0                	test   %eax,%eax
  800a25:	74 04                	je     800a2b <vsnprintf+0x14>
  800a27:	85 d2                	test   %edx,%edx
  800a29:	7f 07                	jg     800a32 <vsnprintf+0x1b>
  800a2b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800a30:	eb 3b                	jmp    800a6d <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  800a32:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800a35:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  800a39:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a3c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800a43:	8b 45 14             	mov    0x14(%ebp),%eax
  800a46:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a4a:	8b 45 10             	mov    0x10(%ebp),%eax
  800a4d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a51:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800a54:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a58:	c7 04 24 6f 03 80 00 	movl   $0x80036f,(%esp)
  800a5f:	e8 28 f9 ff ff       	call   80038c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800a64:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800a67:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800a6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800a6d:	c9                   	leave  
  800a6e:	c3                   	ret    

00800a6f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800a6f:	55                   	push   %ebp
  800a70:	89 e5                	mov    %esp,%ebp
  800a72:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  800a75:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  800a78:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a7c:	8b 45 10             	mov    0x10(%ebp),%eax
  800a7f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a83:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a86:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a8a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a8d:	89 04 24             	mov    %eax,(%esp)
  800a90:	e8 82 ff ff ff       	call   800a17 <vsnprintf>
	va_end(ap);

	return rc;
}
  800a95:	c9                   	leave  
  800a96:	c3                   	ret    

00800a97 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800a97:	55                   	push   %ebp
  800a98:	89 e5                	mov    %esp,%ebp
  800a9a:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  800a9d:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  800aa0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800aa4:	8b 45 10             	mov    0x10(%ebp),%eax
  800aa7:	89 44 24 08          	mov    %eax,0x8(%esp)
  800aab:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aae:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ab2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab5:	89 04 24             	mov    %eax,(%esp)
  800ab8:	e8 cf f8 ff ff       	call   80038c <vprintfmt>
	va_end(ap);
}
  800abd:	c9                   	leave  
  800abe:	c3                   	ret    
	...

00800ac0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800ac0:	55                   	push   %ebp
  800ac1:	89 e5                	mov    %esp,%ebp
  800ac3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800ac6:	b8 00 00 00 00       	mov    $0x0,%eax
  800acb:	80 3a 00             	cmpb   $0x0,(%edx)
  800ace:	74 09                	je     800ad9 <strlen+0x19>
		n++;
  800ad0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800ad3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800ad7:	75 f7                	jne    800ad0 <strlen+0x10>
		n++;
	return n;
}
  800ad9:	5d                   	pop    %ebp
  800ada:	c3                   	ret    

00800adb <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800adb:	55                   	push   %ebp
  800adc:	89 e5                	mov    %esp,%ebp
  800ade:	53                   	push   %ebx
  800adf:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800ae2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800ae5:	85 c9                	test   %ecx,%ecx
  800ae7:	74 19                	je     800b02 <strnlen+0x27>
  800ae9:	80 3b 00             	cmpb   $0x0,(%ebx)
  800aec:	74 14                	je     800b02 <strnlen+0x27>
  800aee:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800af3:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800af6:	39 c8                	cmp    %ecx,%eax
  800af8:	74 0d                	je     800b07 <strnlen+0x2c>
  800afa:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  800afe:	75 f3                	jne    800af3 <strnlen+0x18>
  800b00:	eb 05                	jmp    800b07 <strnlen+0x2c>
  800b02:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800b07:	5b                   	pop    %ebx
  800b08:	5d                   	pop    %ebp
  800b09:	c3                   	ret    

00800b0a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800b0a:	55                   	push   %ebp
  800b0b:	89 e5                	mov    %esp,%ebp
  800b0d:	53                   	push   %ebx
  800b0e:	8b 45 08             	mov    0x8(%ebp),%eax
  800b11:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b14:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800b19:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800b1d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800b20:	83 c2 01             	add    $0x1,%edx
  800b23:	84 c9                	test   %cl,%cl
  800b25:	75 f2                	jne    800b19 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800b27:	5b                   	pop    %ebx
  800b28:	5d                   	pop    %ebp
  800b29:	c3                   	ret    

00800b2a <strcat>:

char *
strcat(char *dst, const char *src)
{
  800b2a:	55                   	push   %ebp
  800b2b:	89 e5                	mov    %esp,%ebp
  800b2d:	53                   	push   %ebx
  800b2e:	83 ec 08             	sub    $0x8,%esp
  800b31:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800b34:	89 1c 24             	mov    %ebx,(%esp)
  800b37:	e8 84 ff ff ff       	call   800ac0 <strlen>
	strcpy(dst + len, src);
  800b3c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b3f:	89 54 24 04          	mov    %edx,0x4(%esp)
  800b43:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800b46:	89 04 24             	mov    %eax,(%esp)
  800b49:	e8 bc ff ff ff       	call   800b0a <strcpy>
	return dst;
}
  800b4e:	89 d8                	mov    %ebx,%eax
  800b50:	83 c4 08             	add    $0x8,%esp
  800b53:	5b                   	pop    %ebx
  800b54:	5d                   	pop    %ebp
  800b55:	c3                   	ret    

00800b56 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800b56:	55                   	push   %ebp
  800b57:	89 e5                	mov    %esp,%ebp
  800b59:	56                   	push   %esi
  800b5a:	53                   	push   %ebx
  800b5b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b5e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b61:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b64:	85 f6                	test   %esi,%esi
  800b66:	74 18                	je     800b80 <strncpy+0x2a>
  800b68:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800b6d:	0f b6 1a             	movzbl (%edx),%ebx
  800b70:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800b73:	80 3a 01             	cmpb   $0x1,(%edx)
  800b76:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b79:	83 c1 01             	add    $0x1,%ecx
  800b7c:	39 ce                	cmp    %ecx,%esi
  800b7e:	77 ed                	ja     800b6d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800b80:	5b                   	pop    %ebx
  800b81:	5e                   	pop    %esi
  800b82:	5d                   	pop    %ebp
  800b83:	c3                   	ret    

00800b84 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800b84:	55                   	push   %ebp
  800b85:	89 e5                	mov    %esp,%ebp
  800b87:	56                   	push   %esi
  800b88:	53                   	push   %ebx
  800b89:	8b 75 08             	mov    0x8(%ebp),%esi
  800b8c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b8f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b92:	89 f0                	mov    %esi,%eax
  800b94:	85 c9                	test   %ecx,%ecx
  800b96:	74 27                	je     800bbf <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  800b98:	83 e9 01             	sub    $0x1,%ecx
  800b9b:	74 1d                	je     800bba <strlcpy+0x36>
  800b9d:	0f b6 1a             	movzbl (%edx),%ebx
  800ba0:	84 db                	test   %bl,%bl
  800ba2:	74 16                	je     800bba <strlcpy+0x36>
			*dst++ = *src++;
  800ba4:	88 18                	mov    %bl,(%eax)
  800ba6:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800ba9:	83 e9 01             	sub    $0x1,%ecx
  800bac:	74 0e                	je     800bbc <strlcpy+0x38>
			*dst++ = *src++;
  800bae:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800bb1:	0f b6 1a             	movzbl (%edx),%ebx
  800bb4:	84 db                	test   %bl,%bl
  800bb6:	75 ec                	jne    800ba4 <strlcpy+0x20>
  800bb8:	eb 02                	jmp    800bbc <strlcpy+0x38>
  800bba:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800bbc:	c6 00 00             	movb   $0x0,(%eax)
  800bbf:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800bc1:	5b                   	pop    %ebx
  800bc2:	5e                   	pop    %esi
  800bc3:	5d                   	pop    %ebp
  800bc4:	c3                   	ret    

00800bc5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800bc5:	55                   	push   %ebp
  800bc6:	89 e5                	mov    %esp,%ebp
  800bc8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bcb:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800bce:	0f b6 01             	movzbl (%ecx),%eax
  800bd1:	84 c0                	test   %al,%al
  800bd3:	74 15                	je     800bea <strcmp+0x25>
  800bd5:	3a 02                	cmp    (%edx),%al
  800bd7:	75 11                	jne    800bea <strcmp+0x25>
		p++, q++;
  800bd9:	83 c1 01             	add    $0x1,%ecx
  800bdc:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800bdf:	0f b6 01             	movzbl (%ecx),%eax
  800be2:	84 c0                	test   %al,%al
  800be4:	74 04                	je     800bea <strcmp+0x25>
  800be6:	3a 02                	cmp    (%edx),%al
  800be8:	74 ef                	je     800bd9 <strcmp+0x14>
  800bea:	0f b6 c0             	movzbl %al,%eax
  800bed:	0f b6 12             	movzbl (%edx),%edx
  800bf0:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800bf2:	5d                   	pop    %ebp
  800bf3:	c3                   	ret    

00800bf4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800bf4:	55                   	push   %ebp
  800bf5:	89 e5                	mov    %esp,%ebp
  800bf7:	53                   	push   %ebx
  800bf8:	8b 55 08             	mov    0x8(%ebp),%edx
  800bfb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bfe:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800c01:	85 c0                	test   %eax,%eax
  800c03:	74 23                	je     800c28 <strncmp+0x34>
  800c05:	0f b6 1a             	movzbl (%edx),%ebx
  800c08:	84 db                	test   %bl,%bl
  800c0a:	74 25                	je     800c31 <strncmp+0x3d>
  800c0c:	3a 19                	cmp    (%ecx),%bl
  800c0e:	75 21                	jne    800c31 <strncmp+0x3d>
  800c10:	83 e8 01             	sub    $0x1,%eax
  800c13:	74 13                	je     800c28 <strncmp+0x34>
		n--, p++, q++;
  800c15:	83 c2 01             	add    $0x1,%edx
  800c18:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800c1b:	0f b6 1a             	movzbl (%edx),%ebx
  800c1e:	84 db                	test   %bl,%bl
  800c20:	74 0f                	je     800c31 <strncmp+0x3d>
  800c22:	3a 19                	cmp    (%ecx),%bl
  800c24:	74 ea                	je     800c10 <strncmp+0x1c>
  800c26:	eb 09                	jmp    800c31 <strncmp+0x3d>
  800c28:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800c2d:	5b                   	pop    %ebx
  800c2e:	5d                   	pop    %ebp
  800c2f:	90                   	nop
  800c30:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800c31:	0f b6 02             	movzbl (%edx),%eax
  800c34:	0f b6 11             	movzbl (%ecx),%edx
  800c37:	29 d0                	sub    %edx,%eax
  800c39:	eb f2                	jmp    800c2d <strncmp+0x39>

00800c3b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800c3b:	55                   	push   %ebp
  800c3c:	89 e5                	mov    %esp,%ebp
  800c3e:	8b 45 08             	mov    0x8(%ebp),%eax
  800c41:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c45:	0f b6 10             	movzbl (%eax),%edx
  800c48:	84 d2                	test   %dl,%dl
  800c4a:	74 18                	je     800c64 <strchr+0x29>
		if (*s == c)
  800c4c:	38 ca                	cmp    %cl,%dl
  800c4e:	75 0a                	jne    800c5a <strchr+0x1f>
  800c50:	eb 17                	jmp    800c69 <strchr+0x2e>
  800c52:	38 ca                	cmp    %cl,%dl
  800c54:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800c58:	74 0f                	je     800c69 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800c5a:	83 c0 01             	add    $0x1,%eax
  800c5d:	0f b6 10             	movzbl (%eax),%edx
  800c60:	84 d2                	test   %dl,%dl
  800c62:	75 ee                	jne    800c52 <strchr+0x17>
  800c64:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800c69:	5d                   	pop    %ebp
  800c6a:	c3                   	ret    

00800c6b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800c6b:	55                   	push   %ebp
  800c6c:	89 e5                	mov    %esp,%ebp
  800c6e:	8b 45 08             	mov    0x8(%ebp),%eax
  800c71:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c75:	0f b6 10             	movzbl (%eax),%edx
  800c78:	84 d2                	test   %dl,%dl
  800c7a:	74 18                	je     800c94 <strfind+0x29>
		if (*s == c)
  800c7c:	38 ca                	cmp    %cl,%dl
  800c7e:	75 0a                	jne    800c8a <strfind+0x1f>
  800c80:	eb 12                	jmp    800c94 <strfind+0x29>
  800c82:	38 ca                	cmp    %cl,%dl
  800c84:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800c88:	74 0a                	je     800c94 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800c8a:	83 c0 01             	add    $0x1,%eax
  800c8d:	0f b6 10             	movzbl (%eax),%edx
  800c90:	84 d2                	test   %dl,%dl
  800c92:	75 ee                	jne    800c82 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800c94:	5d                   	pop    %ebp
  800c95:	c3                   	ret    

00800c96 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800c96:	55                   	push   %ebp
  800c97:	89 e5                	mov    %esp,%ebp
  800c99:	83 ec 0c             	sub    $0xc,%esp
  800c9c:	89 1c 24             	mov    %ebx,(%esp)
  800c9f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ca3:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800ca7:	8b 7d 08             	mov    0x8(%ebp),%edi
  800caa:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cad:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800cb0:	85 c9                	test   %ecx,%ecx
  800cb2:	74 30                	je     800ce4 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800cb4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800cba:	75 25                	jne    800ce1 <memset+0x4b>
  800cbc:	f6 c1 03             	test   $0x3,%cl
  800cbf:	75 20                	jne    800ce1 <memset+0x4b>
		c &= 0xFF;
  800cc1:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800cc4:	89 d3                	mov    %edx,%ebx
  800cc6:	c1 e3 08             	shl    $0x8,%ebx
  800cc9:	89 d6                	mov    %edx,%esi
  800ccb:	c1 e6 18             	shl    $0x18,%esi
  800cce:	89 d0                	mov    %edx,%eax
  800cd0:	c1 e0 10             	shl    $0x10,%eax
  800cd3:	09 f0                	or     %esi,%eax
  800cd5:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  800cd7:	09 d8                	or     %ebx,%eax
  800cd9:	c1 e9 02             	shr    $0x2,%ecx
  800cdc:	fc                   	cld    
  800cdd:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800cdf:	eb 03                	jmp    800ce4 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ce1:	fc                   	cld    
  800ce2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800ce4:	89 f8                	mov    %edi,%eax
  800ce6:	8b 1c 24             	mov    (%esp),%ebx
  800ce9:	8b 74 24 04          	mov    0x4(%esp),%esi
  800ced:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800cf1:	89 ec                	mov    %ebp,%esp
  800cf3:	5d                   	pop    %ebp
  800cf4:	c3                   	ret    

00800cf5 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800cf5:	55                   	push   %ebp
  800cf6:	89 e5                	mov    %esp,%ebp
  800cf8:	83 ec 08             	sub    $0x8,%esp
  800cfb:	89 34 24             	mov    %esi,(%esp)
  800cfe:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800d02:	8b 45 08             	mov    0x8(%ebp),%eax
  800d05:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800d08:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800d0b:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800d0d:	39 c6                	cmp    %eax,%esi
  800d0f:	73 35                	jae    800d46 <memmove+0x51>
  800d11:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800d14:	39 d0                	cmp    %edx,%eax
  800d16:	73 2e                	jae    800d46 <memmove+0x51>
		s += n;
		d += n;
  800d18:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d1a:	f6 c2 03             	test   $0x3,%dl
  800d1d:	75 1b                	jne    800d3a <memmove+0x45>
  800d1f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800d25:	75 13                	jne    800d3a <memmove+0x45>
  800d27:	f6 c1 03             	test   $0x3,%cl
  800d2a:	75 0e                	jne    800d3a <memmove+0x45>
			asm volatile("std; rep movsl\n"
  800d2c:	83 ef 04             	sub    $0x4,%edi
  800d2f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800d32:	c1 e9 02             	shr    $0x2,%ecx
  800d35:	fd                   	std    
  800d36:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d38:	eb 09                	jmp    800d43 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800d3a:	83 ef 01             	sub    $0x1,%edi
  800d3d:	8d 72 ff             	lea    -0x1(%edx),%esi
  800d40:	fd                   	std    
  800d41:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800d43:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800d44:	eb 20                	jmp    800d66 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d46:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800d4c:	75 15                	jne    800d63 <memmove+0x6e>
  800d4e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800d54:	75 0d                	jne    800d63 <memmove+0x6e>
  800d56:	f6 c1 03             	test   $0x3,%cl
  800d59:	75 08                	jne    800d63 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  800d5b:	c1 e9 02             	shr    $0x2,%ecx
  800d5e:	fc                   	cld    
  800d5f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d61:	eb 03                	jmp    800d66 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800d63:	fc                   	cld    
  800d64:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800d66:	8b 34 24             	mov    (%esp),%esi
  800d69:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800d6d:	89 ec                	mov    %ebp,%esp
  800d6f:	5d                   	pop    %ebp
  800d70:	c3                   	ret    

00800d71 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800d71:	55                   	push   %ebp
  800d72:	89 e5                	mov    %esp,%ebp
  800d74:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800d77:	8b 45 10             	mov    0x10(%ebp),%eax
  800d7a:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d7e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d81:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d85:	8b 45 08             	mov    0x8(%ebp),%eax
  800d88:	89 04 24             	mov    %eax,(%esp)
  800d8b:	e8 65 ff ff ff       	call   800cf5 <memmove>
}
  800d90:	c9                   	leave  
  800d91:	c3                   	ret    

00800d92 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800d92:	55                   	push   %ebp
  800d93:	89 e5                	mov    %esp,%ebp
  800d95:	57                   	push   %edi
  800d96:	56                   	push   %esi
  800d97:	53                   	push   %ebx
  800d98:	8b 75 08             	mov    0x8(%ebp),%esi
  800d9b:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800d9e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800da1:	85 c9                	test   %ecx,%ecx
  800da3:	74 36                	je     800ddb <memcmp+0x49>
		if (*s1 != *s2)
  800da5:	0f b6 06             	movzbl (%esi),%eax
  800da8:	0f b6 1f             	movzbl (%edi),%ebx
  800dab:	38 d8                	cmp    %bl,%al
  800dad:	74 20                	je     800dcf <memcmp+0x3d>
  800daf:	eb 14                	jmp    800dc5 <memcmp+0x33>
  800db1:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  800db6:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  800dbb:	83 c2 01             	add    $0x1,%edx
  800dbe:	83 e9 01             	sub    $0x1,%ecx
  800dc1:	38 d8                	cmp    %bl,%al
  800dc3:	74 12                	je     800dd7 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  800dc5:	0f b6 c0             	movzbl %al,%eax
  800dc8:	0f b6 db             	movzbl %bl,%ebx
  800dcb:	29 d8                	sub    %ebx,%eax
  800dcd:	eb 11                	jmp    800de0 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800dcf:	83 e9 01             	sub    $0x1,%ecx
  800dd2:	ba 00 00 00 00       	mov    $0x0,%edx
  800dd7:	85 c9                	test   %ecx,%ecx
  800dd9:	75 d6                	jne    800db1 <memcmp+0x1f>
  800ddb:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800de0:	5b                   	pop    %ebx
  800de1:	5e                   	pop    %esi
  800de2:	5f                   	pop    %edi
  800de3:	5d                   	pop    %ebp
  800de4:	c3                   	ret    

00800de5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800de5:	55                   	push   %ebp
  800de6:	89 e5                	mov    %esp,%ebp
  800de8:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800deb:	89 c2                	mov    %eax,%edx
  800ded:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800df0:	39 d0                	cmp    %edx,%eax
  800df2:	73 15                	jae    800e09 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800df4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800df8:	38 08                	cmp    %cl,(%eax)
  800dfa:	75 06                	jne    800e02 <memfind+0x1d>
  800dfc:	eb 0b                	jmp    800e09 <memfind+0x24>
  800dfe:	38 08                	cmp    %cl,(%eax)
  800e00:	74 07                	je     800e09 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800e02:	83 c0 01             	add    $0x1,%eax
  800e05:	39 c2                	cmp    %eax,%edx
  800e07:	77 f5                	ja     800dfe <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800e09:	5d                   	pop    %ebp
  800e0a:	c3                   	ret    

00800e0b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800e0b:	55                   	push   %ebp
  800e0c:	89 e5                	mov    %esp,%ebp
  800e0e:	57                   	push   %edi
  800e0f:	56                   	push   %esi
  800e10:	53                   	push   %ebx
  800e11:	83 ec 04             	sub    $0x4,%esp
  800e14:	8b 55 08             	mov    0x8(%ebp),%edx
  800e17:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e1a:	0f b6 02             	movzbl (%edx),%eax
  800e1d:	3c 20                	cmp    $0x20,%al
  800e1f:	74 04                	je     800e25 <strtol+0x1a>
  800e21:	3c 09                	cmp    $0x9,%al
  800e23:	75 0e                	jne    800e33 <strtol+0x28>
		s++;
  800e25:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e28:	0f b6 02             	movzbl (%edx),%eax
  800e2b:	3c 20                	cmp    $0x20,%al
  800e2d:	74 f6                	je     800e25 <strtol+0x1a>
  800e2f:	3c 09                	cmp    $0x9,%al
  800e31:	74 f2                	je     800e25 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800e33:	3c 2b                	cmp    $0x2b,%al
  800e35:	75 0c                	jne    800e43 <strtol+0x38>
		s++;
  800e37:	83 c2 01             	add    $0x1,%edx
  800e3a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800e41:	eb 15                	jmp    800e58 <strtol+0x4d>
	else if (*s == '-')
  800e43:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800e4a:	3c 2d                	cmp    $0x2d,%al
  800e4c:	75 0a                	jne    800e58 <strtol+0x4d>
		s++, neg = 1;
  800e4e:	83 c2 01             	add    $0x1,%edx
  800e51:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800e58:	85 db                	test   %ebx,%ebx
  800e5a:	0f 94 c0             	sete   %al
  800e5d:	74 05                	je     800e64 <strtol+0x59>
  800e5f:	83 fb 10             	cmp    $0x10,%ebx
  800e62:	75 18                	jne    800e7c <strtol+0x71>
  800e64:	80 3a 30             	cmpb   $0x30,(%edx)
  800e67:	75 13                	jne    800e7c <strtol+0x71>
  800e69:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800e6d:	8d 76 00             	lea    0x0(%esi),%esi
  800e70:	75 0a                	jne    800e7c <strtol+0x71>
		s += 2, base = 16;
  800e72:	83 c2 02             	add    $0x2,%edx
  800e75:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800e7a:	eb 15                	jmp    800e91 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800e7c:	84 c0                	test   %al,%al
  800e7e:	66 90                	xchg   %ax,%ax
  800e80:	74 0f                	je     800e91 <strtol+0x86>
  800e82:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800e87:	80 3a 30             	cmpb   $0x30,(%edx)
  800e8a:	75 05                	jne    800e91 <strtol+0x86>
		s++, base = 8;
  800e8c:	83 c2 01             	add    $0x1,%edx
  800e8f:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800e91:	b8 00 00 00 00       	mov    $0x0,%eax
  800e96:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800e98:	0f b6 0a             	movzbl (%edx),%ecx
  800e9b:	89 cf                	mov    %ecx,%edi
  800e9d:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800ea0:	80 fb 09             	cmp    $0x9,%bl
  800ea3:	77 08                	ja     800ead <strtol+0xa2>
			dig = *s - '0';
  800ea5:	0f be c9             	movsbl %cl,%ecx
  800ea8:	83 e9 30             	sub    $0x30,%ecx
  800eab:	eb 1e                	jmp    800ecb <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  800ead:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  800eb0:	80 fb 19             	cmp    $0x19,%bl
  800eb3:	77 08                	ja     800ebd <strtol+0xb2>
			dig = *s - 'a' + 10;
  800eb5:	0f be c9             	movsbl %cl,%ecx
  800eb8:	83 e9 57             	sub    $0x57,%ecx
  800ebb:	eb 0e                	jmp    800ecb <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  800ebd:	8d 5f bf             	lea    -0x41(%edi),%ebx
  800ec0:	80 fb 19             	cmp    $0x19,%bl
  800ec3:	77 15                	ja     800eda <strtol+0xcf>
			dig = *s - 'A' + 10;
  800ec5:	0f be c9             	movsbl %cl,%ecx
  800ec8:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800ecb:	39 f1                	cmp    %esi,%ecx
  800ecd:	7d 0b                	jge    800eda <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  800ecf:	83 c2 01             	add    $0x1,%edx
  800ed2:	0f af c6             	imul   %esi,%eax
  800ed5:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800ed8:	eb be                	jmp    800e98 <strtol+0x8d>
  800eda:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800edc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ee0:	74 05                	je     800ee7 <strtol+0xdc>
		*endptr = (char *) s;
  800ee2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ee5:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800ee7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800eeb:	74 04                	je     800ef1 <strtol+0xe6>
  800eed:	89 c8                	mov    %ecx,%eax
  800eef:	f7 d8                	neg    %eax
}
  800ef1:	83 c4 04             	add    $0x4,%esp
  800ef4:	5b                   	pop    %ebx
  800ef5:	5e                   	pop    %esi
  800ef6:	5f                   	pop    %edi
  800ef7:	5d                   	pop    %ebp
  800ef8:	c3                   	ret    
  800ef9:	00 00                	add    %al,(%eax)
	...

00800efc <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  800efc:	55                   	push   %ebp
  800efd:	89 e5                	mov    %esp,%ebp
  800eff:	83 ec 08             	sub    $0x8,%esp
  800f02:	89 1c 24             	mov    %ebx,(%esp)
  800f05:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800f09:	ba 00 00 00 00       	mov    $0x0,%edx
  800f0e:	b8 01 00 00 00       	mov    $0x1,%eax
  800f13:	89 d1                	mov    %edx,%ecx
  800f15:	89 d3                	mov    %edx,%ebx
  800f17:	89 d7                	mov    %edx,%edi
  800f19:	51                   	push   %ecx
  800f1a:	52                   	push   %edx
  800f1b:	53                   	push   %ebx
  800f1c:	54                   	push   %esp
  800f1d:	55                   	push   %ebp
  800f1e:	56                   	push   %esi
  800f1f:	57                   	push   %edi
  800f20:	54                   	push   %esp
  800f21:	5d                   	pop    %ebp
  800f22:	8d 35 2a 0f 80 00    	lea    0x800f2a,%esi
  800f28:	0f 34                	sysenter 
  800f2a:	5f                   	pop    %edi
  800f2b:	5e                   	pop    %esi
  800f2c:	5d                   	pop    %ebp
  800f2d:	5c                   	pop    %esp
  800f2e:	5b                   	pop    %ebx
  800f2f:	5a                   	pop    %edx
  800f30:	59                   	pop    %ecx

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800f31:	8b 1c 24             	mov    (%esp),%ebx
  800f34:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800f38:	89 ec                	mov    %ebp,%esp
  800f3a:	5d                   	pop    %ebp
  800f3b:	c3                   	ret    

00800f3c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800f3c:	55                   	push   %ebp
  800f3d:	89 e5                	mov    %esp,%ebp
  800f3f:	83 ec 08             	sub    $0x8,%esp
  800f42:	89 1c 24             	mov    %ebx,(%esp)
  800f45:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800f49:	b8 00 00 00 00       	mov    $0x0,%eax
  800f4e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f51:	8b 55 08             	mov    0x8(%ebp),%edx
  800f54:	89 c3                	mov    %eax,%ebx
  800f56:	89 c7                	mov    %eax,%edi
  800f58:	51                   	push   %ecx
  800f59:	52                   	push   %edx
  800f5a:	53                   	push   %ebx
  800f5b:	54                   	push   %esp
  800f5c:	55                   	push   %ebp
  800f5d:	56                   	push   %esi
  800f5e:	57                   	push   %edi
  800f5f:	54                   	push   %esp
  800f60:	5d                   	pop    %ebp
  800f61:	8d 35 69 0f 80 00    	lea    0x800f69,%esi
  800f67:	0f 34                	sysenter 
  800f69:	5f                   	pop    %edi
  800f6a:	5e                   	pop    %esi
  800f6b:	5d                   	pop    %ebp
  800f6c:	5c                   	pop    %esp
  800f6d:	5b                   	pop    %ebx
  800f6e:	5a                   	pop    %edx
  800f6f:	59                   	pop    %ecx

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800f70:	8b 1c 24             	mov    (%esp),%ebx
  800f73:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800f77:	89 ec                	mov    %ebp,%esp
  800f79:	5d                   	pop    %ebp
  800f7a:	c3                   	ret    

00800f7b <sys_exec>:
sys_env_set_prior(envid_t envid, uint32_t prior){
         return syscall(SYS_env_set_prior,1,envid, prior, 0, 0, 0);
}

int 
sys_exec(void* vph, uint32_t phnum, uint32_t esp, uint32_t eip){
  800f7b:	55                   	push   %ebp
  800f7c:	89 e5                	mov    %esp,%ebp
  800f7e:	83 ec 08             	sub    $0x8,%esp
  800f81:	89 1c 24             	mov    %ebx,(%esp)
  800f84:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800f88:	b8 10 00 00 00       	mov    $0x10,%eax
  800f8d:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f90:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f93:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f96:	8b 55 08             	mov    0x8(%ebp),%edx
  800f99:	51                   	push   %ecx
  800f9a:	52                   	push   %edx
  800f9b:	53                   	push   %ebx
  800f9c:	54                   	push   %esp
  800f9d:	55                   	push   %ebp
  800f9e:	56                   	push   %esi
  800f9f:	57                   	push   %edi
  800fa0:	54                   	push   %esp
  800fa1:	5d                   	pop    %ebp
  800fa2:	8d 35 aa 0f 80 00    	lea    0x800faa,%esi
  800fa8:	0f 34                	sysenter 
  800faa:	5f                   	pop    %edi
  800fab:	5e                   	pop    %esi
  800fac:	5d                   	pop    %ebp
  800fad:	5c                   	pop    %esp
  800fae:	5b                   	pop    %ebx
  800faf:	5a                   	pop    %edx
  800fb0:	59                   	pop    %ecx
}

int 
sys_exec(void* vph, uint32_t phnum, uint32_t esp, uint32_t eip){
         return syscall(SYS_exec, 0, (uint32_t)vph, phnum, esp, eip, 0);
}
  800fb1:	8b 1c 24             	mov    (%esp),%ebx
  800fb4:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800fb8:	89 ec                	mov    %ebp,%esp
  800fba:	5d                   	pop    %ebp
  800fbb:	c3                   	ret    

00800fbc <sys_env_set_prior>:
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}

int 
sys_env_set_prior(envid_t envid, uint32_t prior){
  800fbc:	55                   	push   %ebp
  800fbd:	89 e5                	mov    %esp,%ebp
  800fbf:	83 ec 28             	sub    $0x28,%esp
  800fc2:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800fc5:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800fc8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fcd:	b8 0f 00 00 00       	mov    $0xf,%eax
  800fd2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fd5:	8b 55 08             	mov    0x8(%ebp),%edx
  800fd8:	89 df                	mov    %ebx,%edi
  800fda:	51                   	push   %ecx
  800fdb:	52                   	push   %edx
  800fdc:	53                   	push   %ebx
  800fdd:	54                   	push   %esp
  800fde:	55                   	push   %ebp
  800fdf:	56                   	push   %esi
  800fe0:	57                   	push   %edi
  800fe1:	54                   	push   %esp
  800fe2:	5d                   	pop    %ebp
  800fe3:	8d 35 eb 0f 80 00    	lea    0x800feb,%esi
  800fe9:	0f 34                	sysenter 
  800feb:	5f                   	pop    %edi
  800fec:	5e                   	pop    %esi
  800fed:	5d                   	pop    %ebp
  800fee:	5c                   	pop    %esp
  800fef:	5b                   	pop    %ebx
  800ff0:	5a                   	pop    %edx
  800ff1:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  800ff2:	85 c0                	test   %eax,%eax
  800ff4:	7e 28                	jle    80101e <sys_env_set_prior+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ff6:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ffa:	c7 44 24 0c 0f 00 00 	movl   $0xf,0xc(%esp)
  801001:	00 
  801002:	c7 44 24 08 40 2f 80 	movl   $0x802f40,0x8(%esp)
  801009:	00 
  80100a:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801011:	00 
  801012:	c7 04 24 5d 2f 80 00 	movl   $0x802f5d,(%esp)
  801019:	e8 fe f0 ff ff       	call   80011c <_panic>
}

int 
sys_env_set_prior(envid_t envid, uint32_t prior){
         return syscall(SYS_env_set_prior,1,envid, prior, 0, 0, 0);
}
  80101e:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801021:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801024:	89 ec                	mov    %ebp,%esp
  801026:	5d                   	pop    %ebp
  801027:	c3                   	ret    

00801028 <sys_sbrk>:
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}

int
sys_sbrk(uint32_t inc)
{
  801028:	55                   	push   %ebp
  801029:	89 e5                	mov    %esp,%ebp
  80102b:	83 ec 08             	sub    $0x8,%esp
  80102e:	89 1c 24             	mov    %ebx,(%esp)
  801031:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801035:	b9 00 00 00 00       	mov    $0x0,%ecx
  80103a:	b8 11 00 00 00       	mov    $0x11,%eax
  80103f:	8b 55 08             	mov    0x8(%ebp),%edx
  801042:	89 cb                	mov    %ecx,%ebx
  801044:	89 cf                	mov    %ecx,%edi
  801046:	51                   	push   %ecx
  801047:	52                   	push   %edx
  801048:	53                   	push   %ebx
  801049:	54                   	push   %esp
  80104a:	55                   	push   %ebp
  80104b:	56                   	push   %esi
  80104c:	57                   	push   %edi
  80104d:	54                   	push   %esp
  80104e:	5d                   	pop    %ebp
  80104f:	8d 35 57 10 80 00    	lea    0x801057,%esi
  801055:	0f 34                	sysenter 
  801057:	5f                   	pop    %edi
  801058:	5e                   	pop    %esi
  801059:	5d                   	pop    %ebp
  80105a:	5c                   	pop    %esp
  80105b:	5b                   	pop    %ebx
  80105c:	5a                   	pop    %edx
  80105d:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  80105e:	8b 1c 24             	mov    (%esp),%ebx
  801061:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801065:	89 ec                	mov    %ebp,%esp
  801067:	5d                   	pop    %ebp
  801068:	c3                   	ret    

00801069 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  801069:	55                   	push   %ebp
  80106a:	89 e5                	mov    %esp,%ebp
  80106c:	83 ec 28             	sub    $0x28,%esp
  80106f:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801072:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801075:	b9 00 00 00 00       	mov    $0x0,%ecx
  80107a:	b8 0e 00 00 00       	mov    $0xe,%eax
  80107f:	8b 55 08             	mov    0x8(%ebp),%edx
  801082:	89 cb                	mov    %ecx,%ebx
  801084:	89 cf                	mov    %ecx,%edi
  801086:	51                   	push   %ecx
  801087:	52                   	push   %edx
  801088:	53                   	push   %ebx
  801089:	54                   	push   %esp
  80108a:	55                   	push   %ebp
  80108b:	56                   	push   %esi
  80108c:	57                   	push   %edi
  80108d:	54                   	push   %esp
  80108e:	5d                   	pop    %ebp
  80108f:	8d 35 97 10 80 00    	lea    0x801097,%esi
  801095:	0f 34                	sysenter 
  801097:	5f                   	pop    %edi
  801098:	5e                   	pop    %esi
  801099:	5d                   	pop    %ebp
  80109a:	5c                   	pop    %esp
  80109b:	5b                   	pop    %ebx
  80109c:	5a                   	pop    %edx
  80109d:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80109e:	85 c0                	test   %eax,%eax
  8010a0:	7e 28                	jle    8010ca <sys_ipc_recv+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010a2:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010a6:	c7 44 24 0c 0e 00 00 	movl   $0xe,0xc(%esp)
  8010ad:	00 
  8010ae:	c7 44 24 08 40 2f 80 	movl   $0x802f40,0x8(%esp)
  8010b5:	00 
  8010b6:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8010bd:	00 
  8010be:	c7 04 24 5d 2f 80 00 	movl   $0x802f5d,(%esp)
  8010c5:	e8 52 f0 ff ff       	call   80011c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8010ca:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8010cd:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8010d0:	89 ec                	mov    %ebp,%esp
  8010d2:	5d                   	pop    %ebp
  8010d3:	c3                   	ret    

008010d4 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8010d4:	55                   	push   %ebp
  8010d5:	89 e5                	mov    %esp,%ebp
  8010d7:	83 ec 08             	sub    $0x8,%esp
  8010da:	89 1c 24             	mov    %ebx,(%esp)
  8010dd:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8010e1:	b8 0d 00 00 00       	mov    $0xd,%eax
  8010e6:	8b 7d 14             	mov    0x14(%ebp),%edi
  8010e9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010ec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010ef:	8b 55 08             	mov    0x8(%ebp),%edx
  8010f2:	51                   	push   %ecx
  8010f3:	52                   	push   %edx
  8010f4:	53                   	push   %ebx
  8010f5:	54                   	push   %esp
  8010f6:	55                   	push   %ebp
  8010f7:	56                   	push   %esi
  8010f8:	57                   	push   %edi
  8010f9:	54                   	push   %esp
  8010fa:	5d                   	pop    %ebp
  8010fb:	8d 35 03 11 80 00    	lea    0x801103,%esi
  801101:	0f 34                	sysenter 
  801103:	5f                   	pop    %edi
  801104:	5e                   	pop    %esi
  801105:	5d                   	pop    %ebp
  801106:	5c                   	pop    %esp
  801107:	5b                   	pop    %ebx
  801108:	5a                   	pop    %edx
  801109:	59                   	pop    %ecx

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80110a:	8b 1c 24             	mov    (%esp),%ebx
  80110d:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801111:	89 ec                	mov    %ebp,%esp
  801113:	5d                   	pop    %ebp
  801114:	c3                   	ret    

00801115 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801115:	55                   	push   %ebp
  801116:	89 e5                	mov    %esp,%ebp
  801118:	83 ec 28             	sub    $0x28,%esp
  80111b:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80111e:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801121:	bb 00 00 00 00       	mov    $0x0,%ebx
  801126:	b8 0b 00 00 00       	mov    $0xb,%eax
  80112b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80112e:	8b 55 08             	mov    0x8(%ebp),%edx
  801131:	89 df                	mov    %ebx,%edi
  801133:	51                   	push   %ecx
  801134:	52                   	push   %edx
  801135:	53                   	push   %ebx
  801136:	54                   	push   %esp
  801137:	55                   	push   %ebp
  801138:	56                   	push   %esi
  801139:	57                   	push   %edi
  80113a:	54                   	push   %esp
  80113b:	5d                   	pop    %ebp
  80113c:	8d 35 44 11 80 00    	lea    0x801144,%esi
  801142:	0f 34                	sysenter 
  801144:	5f                   	pop    %edi
  801145:	5e                   	pop    %esi
  801146:	5d                   	pop    %ebp
  801147:	5c                   	pop    %esp
  801148:	5b                   	pop    %ebx
  801149:	5a                   	pop    %edx
  80114a:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80114b:	85 c0                	test   %eax,%eax
  80114d:	7e 28                	jle    801177 <sys_env_set_pgfault_upcall+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  80114f:	89 44 24 10          	mov    %eax,0x10(%esp)
  801153:	c7 44 24 0c 0b 00 00 	movl   $0xb,0xc(%esp)
  80115a:	00 
  80115b:	c7 44 24 08 40 2f 80 	movl   $0x802f40,0x8(%esp)
  801162:	00 
  801163:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80116a:	00 
  80116b:	c7 04 24 5d 2f 80 00 	movl   $0x802f5d,(%esp)
  801172:	e8 a5 ef ff ff       	call   80011c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801177:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80117a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80117d:	89 ec                	mov    %ebp,%esp
  80117f:	5d                   	pop    %ebp
  801180:	c3                   	ret    

00801181 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801181:	55                   	push   %ebp
  801182:	89 e5                	mov    %esp,%ebp
  801184:	83 ec 28             	sub    $0x28,%esp
  801187:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80118a:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80118d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801192:	b8 0a 00 00 00       	mov    $0xa,%eax
  801197:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80119a:	8b 55 08             	mov    0x8(%ebp),%edx
  80119d:	89 df                	mov    %ebx,%edi
  80119f:	51                   	push   %ecx
  8011a0:	52                   	push   %edx
  8011a1:	53                   	push   %ebx
  8011a2:	54                   	push   %esp
  8011a3:	55                   	push   %ebp
  8011a4:	56                   	push   %esi
  8011a5:	57                   	push   %edi
  8011a6:	54                   	push   %esp
  8011a7:	5d                   	pop    %ebp
  8011a8:	8d 35 b0 11 80 00    	lea    0x8011b0,%esi
  8011ae:	0f 34                	sysenter 
  8011b0:	5f                   	pop    %edi
  8011b1:	5e                   	pop    %esi
  8011b2:	5d                   	pop    %ebp
  8011b3:	5c                   	pop    %esp
  8011b4:	5b                   	pop    %ebx
  8011b5:	5a                   	pop    %edx
  8011b6:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8011b7:	85 c0                	test   %eax,%eax
  8011b9:	7e 28                	jle    8011e3 <sys_env_set_trapframe+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011bb:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011bf:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  8011c6:	00 
  8011c7:	c7 44 24 08 40 2f 80 	movl   $0x802f40,0x8(%esp)
  8011ce:	00 
  8011cf:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8011d6:	00 
  8011d7:	c7 04 24 5d 2f 80 00 	movl   $0x802f5d,(%esp)
  8011de:	e8 39 ef ff ff       	call   80011c <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8011e3:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8011e6:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8011e9:	89 ec                	mov    %ebp,%esp
  8011eb:	5d                   	pop    %ebp
  8011ec:	c3                   	ret    

008011ed <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8011ed:	55                   	push   %ebp
  8011ee:	89 e5                	mov    %esp,%ebp
  8011f0:	83 ec 28             	sub    $0x28,%esp
  8011f3:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8011f6:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8011f9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011fe:	b8 09 00 00 00       	mov    $0x9,%eax
  801203:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801206:	8b 55 08             	mov    0x8(%ebp),%edx
  801209:	89 df                	mov    %ebx,%edi
  80120b:	51                   	push   %ecx
  80120c:	52                   	push   %edx
  80120d:	53                   	push   %ebx
  80120e:	54                   	push   %esp
  80120f:	55                   	push   %ebp
  801210:	56                   	push   %esi
  801211:	57                   	push   %edi
  801212:	54                   	push   %esp
  801213:	5d                   	pop    %ebp
  801214:	8d 35 1c 12 80 00    	lea    0x80121c,%esi
  80121a:	0f 34                	sysenter 
  80121c:	5f                   	pop    %edi
  80121d:	5e                   	pop    %esi
  80121e:	5d                   	pop    %ebp
  80121f:	5c                   	pop    %esp
  801220:	5b                   	pop    %ebx
  801221:	5a                   	pop    %edx
  801222:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801223:	85 c0                	test   %eax,%eax
  801225:	7e 28                	jle    80124f <sys_env_set_status+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  801227:	89 44 24 10          	mov    %eax,0x10(%esp)
  80122b:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  801232:	00 
  801233:	c7 44 24 08 40 2f 80 	movl   $0x802f40,0x8(%esp)
  80123a:	00 
  80123b:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801242:	00 
  801243:	c7 04 24 5d 2f 80 00 	movl   $0x802f5d,(%esp)
  80124a:	e8 cd ee ff ff       	call   80011c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80124f:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801252:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801255:	89 ec                	mov    %ebp,%esp
  801257:	5d                   	pop    %ebp
  801258:	c3                   	ret    

00801259 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  801259:	55                   	push   %ebp
  80125a:	89 e5                	mov    %esp,%ebp
  80125c:	83 ec 28             	sub    $0x28,%esp
  80125f:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801262:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801265:	bb 00 00 00 00       	mov    $0x0,%ebx
  80126a:	b8 07 00 00 00       	mov    $0x7,%eax
  80126f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801272:	8b 55 08             	mov    0x8(%ebp),%edx
  801275:	89 df                	mov    %ebx,%edi
  801277:	51                   	push   %ecx
  801278:	52                   	push   %edx
  801279:	53                   	push   %ebx
  80127a:	54                   	push   %esp
  80127b:	55                   	push   %ebp
  80127c:	56                   	push   %esi
  80127d:	57                   	push   %edi
  80127e:	54                   	push   %esp
  80127f:	5d                   	pop    %ebp
  801280:	8d 35 88 12 80 00    	lea    0x801288,%esi
  801286:	0f 34                	sysenter 
  801288:	5f                   	pop    %edi
  801289:	5e                   	pop    %esi
  80128a:	5d                   	pop    %ebp
  80128b:	5c                   	pop    %esp
  80128c:	5b                   	pop    %ebx
  80128d:	5a                   	pop    %edx
  80128e:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80128f:	85 c0                	test   %eax,%eax
  801291:	7e 28                	jle    8012bb <sys_page_unmap+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  801293:	89 44 24 10          	mov    %eax,0x10(%esp)
  801297:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80129e:	00 
  80129f:	c7 44 24 08 40 2f 80 	movl   $0x802f40,0x8(%esp)
  8012a6:	00 
  8012a7:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8012ae:	00 
  8012af:	c7 04 24 5d 2f 80 00 	movl   $0x802f5d,(%esp)
  8012b6:	e8 61 ee ff ff       	call   80011c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8012bb:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8012be:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8012c1:	89 ec                	mov    %ebp,%esp
  8012c3:	5d                   	pop    %ebp
  8012c4:	c3                   	ret    

008012c5 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8012c5:	55                   	push   %ebp
  8012c6:	89 e5                	mov    %esp,%ebp
  8012c8:	83 ec 28             	sub    $0x28,%esp
  8012cb:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8012ce:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8012d1:	8b 7d 18             	mov    0x18(%ebp),%edi
  8012d4:	0b 7d 14             	or     0x14(%ebp),%edi
  8012d7:	b8 06 00 00 00       	mov    $0x6,%eax
  8012dc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8012df:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012e2:	8b 55 08             	mov    0x8(%ebp),%edx
  8012e5:	51                   	push   %ecx
  8012e6:	52                   	push   %edx
  8012e7:	53                   	push   %ebx
  8012e8:	54                   	push   %esp
  8012e9:	55                   	push   %ebp
  8012ea:	56                   	push   %esi
  8012eb:	57                   	push   %edi
  8012ec:	54                   	push   %esp
  8012ed:	5d                   	pop    %ebp
  8012ee:	8d 35 f6 12 80 00    	lea    0x8012f6,%esi
  8012f4:	0f 34                	sysenter 
  8012f6:	5f                   	pop    %edi
  8012f7:	5e                   	pop    %esi
  8012f8:	5d                   	pop    %ebp
  8012f9:	5c                   	pop    %esp
  8012fa:	5b                   	pop    %ebx
  8012fb:	5a                   	pop    %edx
  8012fc:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8012fd:	85 c0                	test   %eax,%eax
  8012ff:	7e 28                	jle    801329 <sys_page_map+0x64>
		panic("syscall %d returned %d (> 0)", num, ret);
  801301:	89 44 24 10          	mov    %eax,0x10(%esp)
  801305:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  80130c:	00 
  80130d:	c7 44 24 08 40 2f 80 	movl   $0x802f40,0x8(%esp)
  801314:	00 
  801315:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80131c:	00 
  80131d:	c7 04 24 5d 2f 80 00 	movl   $0x802f5d,(%esp)
  801324:	e8 f3 ed ff ff       	call   80011c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}
  801329:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80132c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80132f:	89 ec                	mov    %ebp,%esp
  801331:	5d                   	pop    %ebp
  801332:	c3                   	ret    

00801333 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801333:	55                   	push   %ebp
  801334:	89 e5                	mov    %esp,%ebp
  801336:	83 ec 28             	sub    $0x28,%esp
  801339:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80133c:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80133f:	bf 00 00 00 00       	mov    $0x0,%edi
  801344:	b8 05 00 00 00       	mov    $0x5,%eax
  801349:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80134c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80134f:	8b 55 08             	mov    0x8(%ebp),%edx
  801352:	51                   	push   %ecx
  801353:	52                   	push   %edx
  801354:	53                   	push   %ebx
  801355:	54                   	push   %esp
  801356:	55                   	push   %ebp
  801357:	56                   	push   %esi
  801358:	57                   	push   %edi
  801359:	54                   	push   %esp
  80135a:	5d                   	pop    %ebp
  80135b:	8d 35 63 13 80 00    	lea    0x801363,%esi
  801361:	0f 34                	sysenter 
  801363:	5f                   	pop    %edi
  801364:	5e                   	pop    %esi
  801365:	5d                   	pop    %ebp
  801366:	5c                   	pop    %esp
  801367:	5b                   	pop    %ebx
  801368:	5a                   	pop    %edx
  801369:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80136a:	85 c0                	test   %eax,%eax
  80136c:	7e 28                	jle    801396 <sys_page_alloc+0x63>
		panic("syscall %d returned %d (> 0)", num, ret);
  80136e:	89 44 24 10          	mov    %eax,0x10(%esp)
  801372:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  801379:	00 
  80137a:	c7 44 24 08 40 2f 80 	movl   $0x802f40,0x8(%esp)
  801381:	00 
  801382:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801389:	00 
  80138a:	c7 04 24 5d 2f 80 00 	movl   $0x802f5d,(%esp)
  801391:	e8 86 ed ff ff       	call   80011c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  801396:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801399:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80139c:	89 ec                	mov    %ebp,%esp
  80139e:	5d                   	pop    %ebp
  80139f:	c3                   	ret    

008013a0 <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
{
  8013a0:	55                   	push   %ebp
  8013a1:	89 e5                	mov    %esp,%ebp
  8013a3:	83 ec 08             	sub    $0x8,%esp
  8013a6:	89 1c 24             	mov    %ebx,(%esp)
  8013a9:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8013ad:	ba 00 00 00 00       	mov    $0x0,%edx
  8013b2:	b8 0c 00 00 00       	mov    $0xc,%eax
  8013b7:	89 d1                	mov    %edx,%ecx
  8013b9:	89 d3                	mov    %edx,%ebx
  8013bb:	89 d7                	mov    %edx,%edi
  8013bd:	51                   	push   %ecx
  8013be:	52                   	push   %edx
  8013bf:	53                   	push   %ebx
  8013c0:	54                   	push   %esp
  8013c1:	55                   	push   %ebp
  8013c2:	56                   	push   %esi
  8013c3:	57                   	push   %edi
  8013c4:	54                   	push   %esp
  8013c5:	5d                   	pop    %ebp
  8013c6:	8d 35 ce 13 80 00    	lea    0x8013ce,%esi
  8013cc:	0f 34                	sysenter 
  8013ce:	5f                   	pop    %edi
  8013cf:	5e                   	pop    %esi
  8013d0:	5d                   	pop    %ebp
  8013d1:	5c                   	pop    %esp
  8013d2:	5b                   	pop    %ebx
  8013d3:	5a                   	pop    %edx
  8013d4:	59                   	pop    %ecx

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8013d5:	8b 1c 24             	mov    (%esp),%ebx
  8013d8:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8013dc:	89 ec                	mov    %ebp,%esp
  8013de:	5d                   	pop    %ebp
  8013df:	c3                   	ret    

008013e0 <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
{
  8013e0:	55                   	push   %ebp
  8013e1:	89 e5                	mov    %esp,%ebp
  8013e3:	83 ec 08             	sub    $0x8,%esp
  8013e6:	89 1c 24             	mov    %ebx,(%esp)
  8013e9:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8013ed:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013f2:	b8 04 00 00 00       	mov    $0x4,%eax
  8013f7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013fa:	8b 55 08             	mov    0x8(%ebp),%edx
  8013fd:	89 df                	mov    %ebx,%edi
  8013ff:	51                   	push   %ecx
  801400:	52                   	push   %edx
  801401:	53                   	push   %ebx
  801402:	54                   	push   %esp
  801403:	55                   	push   %ebp
  801404:	56                   	push   %esi
  801405:	57                   	push   %edi
  801406:	54                   	push   %esp
  801407:	5d                   	pop    %ebp
  801408:	8d 35 10 14 80 00    	lea    0x801410,%esi
  80140e:	0f 34                	sysenter 
  801410:	5f                   	pop    %edi
  801411:	5e                   	pop    %esi
  801412:	5d                   	pop    %ebp
  801413:	5c                   	pop    %esp
  801414:	5b                   	pop    %ebx
  801415:	5a                   	pop    %edx
  801416:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  801417:	8b 1c 24             	mov    (%esp),%ebx
  80141a:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80141e:	89 ec                	mov    %ebp,%esp
  801420:	5d                   	pop    %ebp
  801421:	c3                   	ret    

00801422 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  801422:	55                   	push   %ebp
  801423:	89 e5                	mov    %esp,%ebp
  801425:	83 ec 08             	sub    $0x8,%esp
  801428:	89 1c 24             	mov    %ebx,(%esp)
  80142b:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80142f:	ba 00 00 00 00       	mov    $0x0,%edx
  801434:	b8 02 00 00 00       	mov    $0x2,%eax
  801439:	89 d1                	mov    %edx,%ecx
  80143b:	89 d3                	mov    %edx,%ebx
  80143d:	89 d7                	mov    %edx,%edi
  80143f:	51                   	push   %ecx
  801440:	52                   	push   %edx
  801441:	53                   	push   %ebx
  801442:	54                   	push   %esp
  801443:	55                   	push   %ebp
  801444:	56                   	push   %esi
  801445:	57                   	push   %edi
  801446:	54                   	push   %esp
  801447:	5d                   	pop    %ebp
  801448:	8d 35 50 14 80 00    	lea    0x801450,%esi
  80144e:	0f 34                	sysenter 
  801450:	5f                   	pop    %edi
  801451:	5e                   	pop    %esi
  801452:	5d                   	pop    %ebp
  801453:	5c                   	pop    %esp
  801454:	5b                   	pop    %ebx
  801455:	5a                   	pop    %edx
  801456:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  801457:	8b 1c 24             	mov    (%esp),%ebx
  80145a:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80145e:	89 ec                	mov    %ebp,%esp
  801460:	5d                   	pop    %ebp
  801461:	c3                   	ret    

00801462 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  801462:	55                   	push   %ebp
  801463:	89 e5                	mov    %esp,%ebp
  801465:	83 ec 28             	sub    $0x28,%esp
  801468:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80146b:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80146e:	b9 00 00 00 00       	mov    $0x0,%ecx
  801473:	b8 03 00 00 00       	mov    $0x3,%eax
  801478:	8b 55 08             	mov    0x8(%ebp),%edx
  80147b:	89 cb                	mov    %ecx,%ebx
  80147d:	89 cf                	mov    %ecx,%edi
  80147f:	51                   	push   %ecx
  801480:	52                   	push   %edx
  801481:	53                   	push   %ebx
  801482:	54                   	push   %esp
  801483:	55                   	push   %ebp
  801484:	56                   	push   %esi
  801485:	57                   	push   %edi
  801486:	54                   	push   %esp
  801487:	5d                   	pop    %ebp
  801488:	8d 35 90 14 80 00    	lea    0x801490,%esi
  80148e:	0f 34                	sysenter 
  801490:	5f                   	pop    %edi
  801491:	5e                   	pop    %esi
  801492:	5d                   	pop    %ebp
  801493:	5c                   	pop    %esp
  801494:	5b                   	pop    %ebx
  801495:	5a                   	pop    %edx
  801496:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801497:	85 c0                	test   %eax,%eax
  801499:	7e 28                	jle    8014c3 <sys_env_destroy+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  80149b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80149f:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  8014a6:	00 
  8014a7:	c7 44 24 08 40 2f 80 	movl   $0x802f40,0x8(%esp)
  8014ae:	00 
  8014af:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8014b6:	00 
  8014b7:	c7 04 24 5d 2f 80 00 	movl   $0x802f5d,(%esp)
  8014be:	e8 59 ec ff ff       	call   80011c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8014c3:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8014c6:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8014c9:	89 ec                	mov    %ebp,%esp
  8014cb:	5d                   	pop    %ebp
  8014cc:	c3                   	ret    
  8014cd:	00 00                	add    %al,(%eax)
	...

008014d0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8014d0:	55                   	push   %ebp
  8014d1:	89 e5                	mov    %esp,%ebp
  8014d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8014d6:	05 00 00 00 30       	add    $0x30000000,%eax
  8014db:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  8014de:	5d                   	pop    %ebp
  8014df:	c3                   	ret    

008014e0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8014e0:	55                   	push   %ebp
  8014e1:	89 e5                	mov    %esp,%ebp
  8014e3:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  8014e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8014e9:	89 04 24             	mov    %eax,(%esp)
  8014ec:	e8 df ff ff ff       	call   8014d0 <fd2num>
  8014f1:	05 20 00 0d 00       	add    $0xd0020,%eax
  8014f6:	c1 e0 0c             	shl    $0xc,%eax
}
  8014f9:	c9                   	leave  
  8014fa:	c3                   	ret    

008014fb <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8014fb:	55                   	push   %ebp
  8014fc:	89 e5                	mov    %esp,%ebp
  8014fe:	57                   	push   %edi
  8014ff:	56                   	push   %esi
  801500:	53                   	push   %ebx
  801501:	8b 7d 08             	mov    0x8(%ebp),%edi
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  801504:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  801509:	a8 01                	test   $0x1,%al
  80150b:	74 36                	je     801543 <fd_alloc+0x48>
  80150d:	a1 00 00 74 ef       	mov    0xef740000,%eax
  801512:	a8 01                	test   $0x1,%al
  801514:	74 2d                	je     801543 <fd_alloc+0x48>
  801516:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  80151b:	b9 00 d0 7b ef       	mov    $0xef7bd000,%ecx
  801520:	be 00 00 40 ef       	mov    $0xef400000,%esi
  801525:	89 c3                	mov    %eax,%ebx
  801527:	89 c2                	mov    %eax,%edx
  801529:	c1 ea 16             	shr    $0x16,%edx
  80152c:	8b 14 91             	mov    (%ecx,%edx,4),%edx
  80152f:	f6 c2 01             	test   $0x1,%dl
  801532:	74 14                	je     801548 <fd_alloc+0x4d>
  801534:	89 c2                	mov    %eax,%edx
  801536:	c1 ea 0c             	shr    $0xc,%edx
  801539:	8b 14 96             	mov    (%esi,%edx,4),%edx
  80153c:	f6 c2 01             	test   $0x1,%dl
  80153f:	75 10                	jne    801551 <fd_alloc+0x56>
  801541:	eb 05                	jmp    801548 <fd_alloc+0x4d>
  801543:	bb 00 00 00 d0       	mov    $0xd0000000,%ebx
			*fd_store = fd;
  801548:	89 1f                	mov    %ebx,(%edi)
  80154a:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  80154f:	eb 17                	jmp    801568 <fd_alloc+0x6d>
  801551:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801556:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80155b:	75 c8                	jne    801525 <fd_alloc+0x2a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80155d:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  801563:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  801568:	5b                   	pop    %ebx
  801569:	5e                   	pop    %esi
  80156a:	5f                   	pop    %edi
  80156b:	5d                   	pop    %ebp
  80156c:	c3                   	ret    

0080156d <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80156d:	55                   	push   %ebp
  80156e:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801570:	8b 45 08             	mov    0x8(%ebp),%eax
  801573:	83 f8 1f             	cmp    $0x1f,%eax
  801576:	77 36                	ja     8015ae <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801578:	05 00 00 0d 00       	add    $0xd0000,%eax
  80157d:	c1 e0 0c             	shl    $0xc,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
  801580:	89 c2                	mov    %eax,%edx
  801582:	c1 ea 16             	shr    $0x16,%edx
  801585:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80158c:	f6 c2 01             	test   $0x1,%dl
  80158f:	74 1d                	je     8015ae <fd_lookup+0x41>
  801591:	89 c2                	mov    %eax,%edx
  801593:	c1 ea 0c             	shr    $0xc,%edx
  801596:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80159d:	f6 c2 01             	test   $0x1,%dl
  8015a0:	74 0c                	je     8015ae <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  8015a2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015a5:	89 02                	mov    %eax,(%edx)
  8015a7:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
  8015ac:	eb 05                	jmp    8015b3 <fd_lookup+0x46>
  8015ae:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8015b3:	5d                   	pop    %ebp
  8015b4:	c3                   	ret    

008015b5 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  8015b5:	55                   	push   %ebp
  8015b6:	89 e5                	mov    %esp,%ebp
  8015b8:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015bb:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8015be:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8015c5:	89 04 24             	mov    %eax,(%esp)
  8015c8:	e8 a0 ff ff ff       	call   80156d <fd_lookup>
  8015cd:	85 c0                	test   %eax,%eax
  8015cf:	78 0e                	js     8015df <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8015d1:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8015d4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015d7:	89 50 04             	mov    %edx,0x4(%eax)
  8015da:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  8015df:	c9                   	leave  
  8015e0:	c3                   	ret    

008015e1 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8015e1:	55                   	push   %ebp
  8015e2:	89 e5                	mov    %esp,%ebp
  8015e4:	56                   	push   %esi
  8015e5:	53                   	push   %ebx
  8015e6:	83 ec 10             	sub    $0x10,%esp
  8015e9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8015ec:	8b 5d 0c             	mov    0xc(%ebp),%ebx
// File functions
// --------------------------------------------------------------

static struct Dev *devtab[] =
{
	&devfile,
  8015ef:	b8 04 40 80 00       	mov    $0x804004,%eax
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  8015f4:	ba 00 00 00 00       	mov    $0x0,%edx

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8015f9:	be e8 2f 80 00       	mov    $0x802fe8,%esi
		if (devtab[i]->dev_id == dev_id) {
  8015fe:	39 08                	cmp    %ecx,(%eax)
  801600:	75 10                	jne    801612 <dev_lookup+0x31>
  801602:	eb 04                	jmp    801608 <dev_lookup+0x27>
  801604:	39 08                	cmp    %ecx,(%eax)
  801606:	75 0a                	jne    801612 <dev_lookup+0x31>
			*dev = devtab[i];
  801608:	89 03                	mov    %eax,(%ebx)
  80160a:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  80160f:	90                   	nop
  801610:	eb 31                	jmp    801643 <dev_lookup+0x62>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801612:	83 c2 01             	add    $0x1,%edx
  801615:	8b 04 96             	mov    (%esi,%edx,4),%eax
  801618:	85 c0                	test   %eax,%eax
  80161a:	75 e8                	jne    801604 <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80161c:	a1 04 50 80 00       	mov    0x805004,%eax
  801621:	8b 40 48             	mov    0x48(%eax),%eax
  801624:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801628:	89 44 24 04          	mov    %eax,0x4(%esp)
  80162c:	c7 04 24 6c 2f 80 00 	movl   $0x802f6c,(%esp)
  801633:	e8 9d eb ff ff       	call   8001d5 <cprintf>
	*dev = 0;
  801638:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80163e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  801643:	83 c4 10             	add    $0x10,%esp
  801646:	5b                   	pop    %ebx
  801647:	5e                   	pop    %esi
  801648:	5d                   	pop    %ebp
  801649:	c3                   	ret    

0080164a <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  80164a:	55                   	push   %ebp
  80164b:	89 e5                	mov    %esp,%ebp
  80164d:	53                   	push   %ebx
  80164e:	83 ec 24             	sub    $0x24,%esp
  801651:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801654:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801657:	89 44 24 04          	mov    %eax,0x4(%esp)
  80165b:	8b 45 08             	mov    0x8(%ebp),%eax
  80165e:	89 04 24             	mov    %eax,(%esp)
  801661:	e8 07 ff ff ff       	call   80156d <fd_lookup>
  801666:	85 c0                	test   %eax,%eax
  801668:	78 53                	js     8016bd <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80166a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80166d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801671:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801674:	8b 00                	mov    (%eax),%eax
  801676:	89 04 24             	mov    %eax,(%esp)
  801679:	e8 63 ff ff ff       	call   8015e1 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80167e:	85 c0                	test   %eax,%eax
  801680:	78 3b                	js     8016bd <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  801682:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801687:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80168a:	83 7a 14 00          	cmpl   $0x0,0x14(%edx)
  80168e:	74 2d                	je     8016bd <fstat+0x73>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801690:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801693:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80169a:	00 00 00 
	stat->st_isdir = 0;
  80169d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016a4:	00 00 00 
	stat->st_dev = dev;
  8016a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016aa:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8016b0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8016b4:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8016b7:	89 14 24             	mov    %edx,(%esp)
  8016ba:	ff 50 14             	call   *0x14(%eax)
}
  8016bd:	83 c4 24             	add    $0x24,%esp
  8016c0:	5b                   	pop    %ebx
  8016c1:	5d                   	pop    %ebp
  8016c2:	c3                   	ret    

008016c3 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  8016c3:	55                   	push   %ebp
  8016c4:	89 e5                	mov    %esp,%ebp
  8016c6:	53                   	push   %ebx
  8016c7:	83 ec 24             	sub    $0x24,%esp
  8016ca:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016cd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016d0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016d4:	89 1c 24             	mov    %ebx,(%esp)
  8016d7:	e8 91 fe ff ff       	call   80156d <fd_lookup>
  8016dc:	85 c0                	test   %eax,%eax
  8016de:	78 5f                	js     80173f <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016e0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016e3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016ea:	8b 00                	mov    (%eax),%eax
  8016ec:	89 04 24             	mov    %eax,(%esp)
  8016ef:	e8 ed fe ff ff       	call   8015e1 <dev_lookup>
ftruncate(int fdnum, off_t newsize)
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016f4:	85 c0                	test   %eax,%eax
  8016f6:	78 47                	js     80173f <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016f8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8016fb:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  8016ff:	75 23                	jne    801724 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801701:	a1 04 50 80 00       	mov    0x805004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801706:	8b 40 48             	mov    0x48(%eax),%eax
  801709:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80170d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801711:	c7 04 24 8c 2f 80 00 	movl   $0x802f8c,(%esp)
  801718:	e8 b8 ea ff ff       	call   8001d5 <cprintf>
  80171d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801722:	eb 1b                	jmp    80173f <ftruncate+0x7c>
	}
	if (!dev->dev_trunc)
  801724:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801727:	8b 48 18             	mov    0x18(%eax),%ecx
  80172a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80172f:	85 c9                	test   %ecx,%ecx
  801731:	74 0c                	je     80173f <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801733:	8b 45 0c             	mov    0xc(%ebp),%eax
  801736:	89 44 24 04          	mov    %eax,0x4(%esp)
  80173a:	89 14 24             	mov    %edx,(%esp)
  80173d:	ff d1                	call   *%ecx
}
  80173f:	83 c4 24             	add    $0x24,%esp
  801742:	5b                   	pop    %ebx
  801743:	5d                   	pop    %ebp
  801744:	c3                   	ret    

00801745 <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801745:	55                   	push   %ebp
  801746:	89 e5                	mov    %esp,%ebp
  801748:	53                   	push   %ebx
  801749:	83 ec 24             	sub    $0x24,%esp
  80174c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80174f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801752:	89 44 24 04          	mov    %eax,0x4(%esp)
  801756:	89 1c 24             	mov    %ebx,(%esp)
  801759:	e8 0f fe ff ff       	call   80156d <fd_lookup>
  80175e:	85 c0                	test   %eax,%eax
  801760:	78 66                	js     8017c8 <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801762:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801765:	89 44 24 04          	mov    %eax,0x4(%esp)
  801769:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80176c:	8b 00                	mov    (%eax),%eax
  80176e:	89 04 24             	mov    %eax,(%esp)
  801771:	e8 6b fe ff ff       	call   8015e1 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801776:	85 c0                	test   %eax,%eax
  801778:	78 4e                	js     8017c8 <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80177a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80177d:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  801781:	75 23                	jne    8017a6 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801783:	a1 04 50 80 00       	mov    0x805004,%eax
  801788:	8b 40 48             	mov    0x48(%eax),%eax
  80178b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80178f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801793:	c7 04 24 ad 2f 80 00 	movl   $0x802fad,(%esp)
  80179a:	e8 36 ea ff ff       	call   8001d5 <cprintf>
  80179f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  8017a4:	eb 22                	jmp    8017c8 <write+0x83>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8017a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017a9:	8b 48 0c             	mov    0xc(%eax),%ecx
  8017ac:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8017b1:	85 c9                	test   %ecx,%ecx
  8017b3:	74 13                	je     8017c8 <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8017b5:	8b 45 10             	mov    0x10(%ebp),%eax
  8017b8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8017bc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017bf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017c3:	89 14 24             	mov    %edx,(%esp)
  8017c6:	ff d1                	call   *%ecx
}
  8017c8:	83 c4 24             	add    $0x24,%esp
  8017cb:	5b                   	pop    %ebx
  8017cc:	5d                   	pop    %ebp
  8017cd:	c3                   	ret    

008017ce <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8017ce:	55                   	push   %ebp
  8017cf:	89 e5                	mov    %esp,%ebp
  8017d1:	53                   	push   %ebx
  8017d2:	83 ec 24             	sub    $0x24,%esp
  8017d5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017d8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017db:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017df:	89 1c 24             	mov    %ebx,(%esp)
  8017e2:	e8 86 fd ff ff       	call   80156d <fd_lookup>
  8017e7:	85 c0                	test   %eax,%eax
  8017e9:	78 6b                	js     801856 <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017eb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017ee:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017f5:	8b 00                	mov    (%eax),%eax
  8017f7:	89 04 24             	mov    %eax,(%esp)
  8017fa:	e8 e2 fd ff ff       	call   8015e1 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017ff:	85 c0                	test   %eax,%eax
  801801:	78 53                	js     801856 <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801803:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801806:	8b 42 08             	mov    0x8(%edx),%eax
  801809:	83 e0 03             	and    $0x3,%eax
  80180c:	83 f8 01             	cmp    $0x1,%eax
  80180f:	75 23                	jne    801834 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801811:	a1 04 50 80 00       	mov    0x805004,%eax
  801816:	8b 40 48             	mov    0x48(%eax),%eax
  801819:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80181d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801821:	c7 04 24 ca 2f 80 00 	movl   $0x802fca,(%esp)
  801828:	e8 a8 e9 ff ff       	call   8001d5 <cprintf>
  80182d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801832:	eb 22                	jmp    801856 <read+0x88>
	}
	if (!dev->dev_read)
  801834:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801837:	8b 48 08             	mov    0x8(%eax),%ecx
  80183a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80183f:	85 c9                	test   %ecx,%ecx
  801841:	74 13                	je     801856 <read+0x88>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801843:	8b 45 10             	mov    0x10(%ebp),%eax
  801846:	89 44 24 08          	mov    %eax,0x8(%esp)
  80184a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80184d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801851:	89 14 24             	mov    %edx,(%esp)
  801854:	ff d1                	call   *%ecx
}
  801856:	83 c4 24             	add    $0x24,%esp
  801859:	5b                   	pop    %ebx
  80185a:	5d                   	pop    %ebp
  80185b:	c3                   	ret    

0080185c <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80185c:	55                   	push   %ebp
  80185d:	89 e5                	mov    %esp,%ebp
  80185f:	57                   	push   %edi
  801860:	56                   	push   %esi
  801861:	53                   	push   %ebx
  801862:	83 ec 1c             	sub    $0x1c,%esp
  801865:	8b 7d 08             	mov    0x8(%ebp),%edi
  801868:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80186b:	ba 00 00 00 00       	mov    $0x0,%edx
  801870:	bb 00 00 00 00       	mov    $0x0,%ebx
  801875:	b8 00 00 00 00       	mov    $0x0,%eax
  80187a:	85 f6                	test   %esi,%esi
  80187c:	74 29                	je     8018a7 <readn+0x4b>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80187e:	89 f0                	mov    %esi,%eax
  801880:	29 d0                	sub    %edx,%eax
  801882:	89 44 24 08          	mov    %eax,0x8(%esp)
  801886:	03 55 0c             	add    0xc(%ebp),%edx
  801889:	89 54 24 04          	mov    %edx,0x4(%esp)
  80188d:	89 3c 24             	mov    %edi,(%esp)
  801890:	e8 39 ff ff ff       	call   8017ce <read>
		if (m < 0)
  801895:	85 c0                	test   %eax,%eax
  801897:	78 0e                	js     8018a7 <readn+0x4b>
			return m;
		if (m == 0)
  801899:	85 c0                	test   %eax,%eax
  80189b:	74 08                	je     8018a5 <readn+0x49>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80189d:	01 c3                	add    %eax,%ebx
  80189f:	89 da                	mov    %ebx,%edx
  8018a1:	39 f3                	cmp    %esi,%ebx
  8018a3:	72 d9                	jb     80187e <readn+0x22>
  8018a5:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8018a7:	83 c4 1c             	add    $0x1c,%esp
  8018aa:	5b                   	pop    %ebx
  8018ab:	5e                   	pop    %esi
  8018ac:	5f                   	pop    %edi
  8018ad:	5d                   	pop    %ebp
  8018ae:	c3                   	ret    

008018af <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8018af:	55                   	push   %ebp
  8018b0:	89 e5                	mov    %esp,%ebp
  8018b2:	56                   	push   %esi
  8018b3:	53                   	push   %ebx
  8018b4:	83 ec 20             	sub    $0x20,%esp
  8018b7:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8018ba:	89 34 24             	mov    %esi,(%esp)
  8018bd:	e8 0e fc ff ff       	call   8014d0 <fd2num>
  8018c2:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8018c5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8018c9:	89 04 24             	mov    %eax,(%esp)
  8018cc:	e8 9c fc ff ff       	call   80156d <fd_lookup>
  8018d1:	89 c3                	mov    %eax,%ebx
  8018d3:	85 c0                	test   %eax,%eax
  8018d5:	78 05                	js     8018dc <fd_close+0x2d>
  8018d7:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8018da:	74 0c                	je     8018e8 <fd_close+0x39>
	    || fd != fd2)
		return (must_exist ? r : 0);
  8018dc:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  8018e0:	19 c0                	sbb    %eax,%eax
  8018e2:	f7 d0                	not    %eax
  8018e4:	21 c3                	and    %eax,%ebx
  8018e6:	eb 3d                	jmp    801925 <fd_close+0x76>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8018e8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018eb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018ef:	8b 06                	mov    (%esi),%eax
  8018f1:	89 04 24             	mov    %eax,(%esp)
  8018f4:	e8 e8 fc ff ff       	call   8015e1 <dev_lookup>
  8018f9:	89 c3                	mov    %eax,%ebx
  8018fb:	85 c0                	test   %eax,%eax
  8018fd:	78 16                	js     801915 <fd_close+0x66>
		if (dev->dev_close)
  8018ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801902:	8b 40 10             	mov    0x10(%eax),%eax
  801905:	bb 00 00 00 00       	mov    $0x0,%ebx
  80190a:	85 c0                	test   %eax,%eax
  80190c:	74 07                	je     801915 <fd_close+0x66>
			r = (*dev->dev_close)(fd);
  80190e:	89 34 24             	mov    %esi,(%esp)
  801911:	ff d0                	call   *%eax
  801913:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801915:	89 74 24 04          	mov    %esi,0x4(%esp)
  801919:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801920:	e8 34 f9 ff ff       	call   801259 <sys_page_unmap>
	return r;
}
  801925:	89 d8                	mov    %ebx,%eax
  801927:	83 c4 20             	add    $0x20,%esp
  80192a:	5b                   	pop    %ebx
  80192b:	5e                   	pop    %esi
  80192c:	5d                   	pop    %ebp
  80192d:	c3                   	ret    

0080192e <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80192e:	55                   	push   %ebp
  80192f:	89 e5                	mov    %esp,%ebp
  801931:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801934:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801937:	89 44 24 04          	mov    %eax,0x4(%esp)
  80193b:	8b 45 08             	mov    0x8(%ebp),%eax
  80193e:	89 04 24             	mov    %eax,(%esp)
  801941:	e8 27 fc ff ff       	call   80156d <fd_lookup>
  801946:	85 c0                	test   %eax,%eax
  801948:	78 13                	js     80195d <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  80194a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801951:	00 
  801952:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801955:	89 04 24             	mov    %eax,(%esp)
  801958:	e8 52 ff ff ff       	call   8018af <fd_close>
}
  80195d:	c9                   	leave  
  80195e:	c3                   	ret    

0080195f <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  80195f:	55                   	push   %ebp
  801960:	89 e5                	mov    %esp,%ebp
  801962:	83 ec 18             	sub    $0x18,%esp
  801965:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801968:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80196b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801972:	00 
  801973:	8b 45 08             	mov    0x8(%ebp),%eax
  801976:	89 04 24             	mov    %eax,(%esp)
  801979:	e8 79 03 00 00       	call   801cf7 <open>
  80197e:	89 c3                	mov    %eax,%ebx
  801980:	85 c0                	test   %eax,%eax
  801982:	78 1b                	js     80199f <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  801984:	8b 45 0c             	mov    0xc(%ebp),%eax
  801987:	89 44 24 04          	mov    %eax,0x4(%esp)
  80198b:	89 1c 24             	mov    %ebx,(%esp)
  80198e:	e8 b7 fc ff ff       	call   80164a <fstat>
  801993:	89 c6                	mov    %eax,%esi
	close(fd);
  801995:	89 1c 24             	mov    %ebx,(%esp)
  801998:	e8 91 ff ff ff       	call   80192e <close>
  80199d:	89 f3                	mov    %esi,%ebx
	return r;
}
  80199f:	89 d8                	mov    %ebx,%eax
  8019a1:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8019a4:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8019a7:	89 ec                	mov    %ebp,%esp
  8019a9:	5d                   	pop    %ebp
  8019aa:	c3                   	ret    

008019ab <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  8019ab:	55                   	push   %ebp
  8019ac:	89 e5                	mov    %esp,%ebp
  8019ae:	53                   	push   %ebx
  8019af:	83 ec 14             	sub    $0x14,%esp
  8019b2:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  8019b7:	89 1c 24             	mov    %ebx,(%esp)
  8019ba:	e8 6f ff ff ff       	call   80192e <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8019bf:	83 c3 01             	add    $0x1,%ebx
  8019c2:	83 fb 20             	cmp    $0x20,%ebx
  8019c5:	75 f0                	jne    8019b7 <close_all+0xc>
		close(i);
}
  8019c7:	83 c4 14             	add    $0x14,%esp
  8019ca:	5b                   	pop    %ebx
  8019cb:	5d                   	pop    %ebp
  8019cc:	c3                   	ret    

008019cd <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8019cd:	55                   	push   %ebp
  8019ce:	89 e5                	mov    %esp,%ebp
  8019d0:	83 ec 58             	sub    $0x58,%esp
  8019d3:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8019d6:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8019d9:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8019dc:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8019df:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8019e2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8019e9:	89 04 24             	mov    %eax,(%esp)
  8019ec:	e8 7c fb ff ff       	call   80156d <fd_lookup>
  8019f1:	89 c3                	mov    %eax,%ebx
  8019f3:	85 c0                	test   %eax,%eax
  8019f5:	0f 88 e0 00 00 00    	js     801adb <dup+0x10e>
		return r;
	close(newfdnum);
  8019fb:	89 3c 24             	mov    %edi,(%esp)
  8019fe:	e8 2b ff ff ff       	call   80192e <close>

	newfd = INDEX2FD(newfdnum);
  801a03:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801a09:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801a0c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a0f:	89 04 24             	mov    %eax,(%esp)
  801a12:	e8 c9 fa ff ff       	call   8014e0 <fd2data>
  801a17:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801a19:	89 34 24             	mov    %esi,(%esp)
  801a1c:	e8 bf fa ff ff       	call   8014e0 <fd2data>
  801a21:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
  801a24:	89 da                	mov    %ebx,%edx
  801a26:	89 d8                	mov    %ebx,%eax
  801a28:	c1 e8 16             	shr    $0x16,%eax
  801a2b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801a32:	a8 01                	test   $0x1,%al
  801a34:	74 43                	je     801a79 <dup+0xac>
  801a36:	c1 ea 0c             	shr    $0xc,%edx
  801a39:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801a40:	a8 01                	test   $0x1,%al
  801a42:	74 35                	je     801a79 <dup+0xac>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801a44:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801a4b:	25 07 0e 00 00       	and    $0xe07,%eax
  801a50:	89 44 24 10          	mov    %eax,0x10(%esp)
  801a54:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801a57:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801a5b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801a62:	00 
  801a63:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a67:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a6e:	e8 52 f8 ff ff       	call   8012c5 <sys_page_map>
  801a73:	89 c3                	mov    %eax,%ebx
  801a75:	85 c0                	test   %eax,%eax
  801a77:	78 3f                	js     801ab8 <dup+0xeb>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801a79:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a7c:	89 c2                	mov    %eax,%edx
  801a7e:	c1 ea 0c             	shr    $0xc,%edx
  801a81:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801a88:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801a8e:	89 54 24 10          	mov    %edx,0x10(%esp)
  801a92:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801a96:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801a9d:	00 
  801a9e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801aa2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801aa9:	e8 17 f8 ff ff       	call   8012c5 <sys_page_map>
  801aae:	89 c3                	mov    %eax,%ebx
  801ab0:	85 c0                	test   %eax,%eax
  801ab2:	78 04                	js     801ab8 <dup+0xeb>
  801ab4:	89 fb                	mov    %edi,%ebx
  801ab6:	eb 23                	jmp    801adb <dup+0x10e>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801ab8:	89 74 24 04          	mov    %esi,0x4(%esp)
  801abc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ac3:	e8 91 f7 ff ff       	call   801259 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801ac8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801acb:	89 44 24 04          	mov    %eax,0x4(%esp)
  801acf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ad6:	e8 7e f7 ff ff       	call   801259 <sys_page_unmap>
	return r;
}
  801adb:	89 d8                	mov    %ebx,%eax
  801add:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801ae0:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801ae3:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801ae6:	89 ec                	mov    %ebp,%esp
  801ae8:	5d                   	pop    %ebp
  801ae9:	c3                   	ret    
	...

00801aec <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801aec:	55                   	push   %ebp
  801aed:	89 e5                	mov    %esp,%ebp
  801aef:	83 ec 18             	sub    $0x18,%esp
  801af2:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801af5:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801af8:	89 c3                	mov    %eax,%ebx
  801afa:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801afc:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  801b03:	75 11                	jne    801b16 <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801b05:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801b0c:	e8 7f 0c 00 00       	call   802790 <ipc_find_env>
  801b11:	a3 00 50 80 00       	mov    %eax,0x805000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801b16:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801b1d:	00 
  801b1e:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  801b25:	00 
  801b26:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801b2a:	a1 00 50 80 00       	mov    0x805000,%eax
  801b2f:	89 04 24             	mov    %eax,(%esp)
  801b32:	e8 a4 0c 00 00       	call   8027db <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801b37:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801b3e:	00 
  801b3f:	89 74 24 04          	mov    %esi,0x4(%esp)
  801b43:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b4a:	e8 0a 0d 00 00       	call   802859 <ipc_recv>
}
  801b4f:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801b52:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801b55:	89 ec                	mov    %ebp,%esp
  801b57:	5d                   	pop    %ebp
  801b58:	c3                   	ret    

00801b59 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801b59:	55                   	push   %ebp
  801b5a:	89 e5                	mov    %esp,%ebp
  801b5c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801b5f:	8b 45 08             	mov    0x8(%ebp),%eax
  801b62:	8b 40 0c             	mov    0xc(%eax),%eax
  801b65:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  801b6a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b6d:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801b72:	ba 00 00 00 00       	mov    $0x0,%edx
  801b77:	b8 02 00 00 00       	mov    $0x2,%eax
  801b7c:	e8 6b ff ff ff       	call   801aec <fsipc>
}
  801b81:	c9                   	leave  
  801b82:	c3                   	ret    

00801b83 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801b83:	55                   	push   %ebp
  801b84:	89 e5                	mov    %esp,%ebp
  801b86:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801b89:	8b 45 08             	mov    0x8(%ebp),%eax
  801b8c:	8b 40 0c             	mov    0xc(%eax),%eax
  801b8f:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801b94:	ba 00 00 00 00       	mov    $0x0,%edx
  801b99:	b8 06 00 00 00       	mov    $0x6,%eax
  801b9e:	e8 49 ff ff ff       	call   801aec <fsipc>
}
  801ba3:	c9                   	leave  
  801ba4:	c3                   	ret    

00801ba5 <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  801ba5:	55                   	push   %ebp
  801ba6:	89 e5                	mov    %esp,%ebp
  801ba8:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801bab:	ba 00 00 00 00       	mov    $0x0,%edx
  801bb0:	b8 08 00 00 00       	mov    $0x8,%eax
  801bb5:	e8 32 ff ff ff       	call   801aec <fsipc>
}
  801bba:	c9                   	leave  
  801bbb:	c3                   	ret    

00801bbc <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801bbc:	55                   	push   %ebp
  801bbd:	89 e5                	mov    %esp,%ebp
  801bbf:	53                   	push   %ebx
  801bc0:	83 ec 14             	sub    $0x14,%esp
  801bc3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801bc6:	8b 45 08             	mov    0x8(%ebp),%eax
  801bc9:	8b 40 0c             	mov    0xc(%eax),%eax
  801bcc:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801bd1:	ba 00 00 00 00       	mov    $0x0,%edx
  801bd6:	b8 05 00 00 00       	mov    $0x5,%eax
  801bdb:	e8 0c ff ff ff       	call   801aec <fsipc>
  801be0:	85 c0                	test   %eax,%eax
  801be2:	78 2b                	js     801c0f <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801be4:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801beb:	00 
  801bec:	89 1c 24             	mov    %ebx,(%esp)
  801bef:	e8 16 ef ff ff       	call   800b0a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801bf4:	a1 80 60 80 00       	mov    0x806080,%eax
  801bf9:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801bff:	a1 84 60 80 00       	mov    0x806084,%eax
  801c04:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  801c0a:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  801c0f:	83 c4 14             	add    $0x14,%esp
  801c12:	5b                   	pop    %ebx
  801c13:	5d                   	pop    %ebp
  801c14:	c3                   	ret    

00801c15 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801c15:	55                   	push   %ebp
  801c16:	89 e5                	mov    %esp,%ebp
  801c18:	83 ec 18             	sub    $0x18,%esp
  801c1b:	8b 45 10             	mov    0x10(%ebp),%eax
  801c1e:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801c23:	76 05                	jbe    801c2a <devfile_write+0x15>
  801c25:	b8 f8 0f 00 00       	mov    $0xff8,%eax
	// bytes than requested.
	// LAB 5: Your code here
        int r;
        if(n > sizeof(fsipcbuf.write.req_buf))
            n = sizeof(fsipcbuf.write.req_buf);
        fsipcbuf.write.req_fileid = fd->fd_file.id;
  801c2a:	8b 55 08             	mov    0x8(%ebp),%edx
  801c2d:	8b 52 0c             	mov    0xc(%edx),%edx
  801c30:	89 15 00 60 80 00    	mov    %edx,0x806000
        fsipcbuf.write.req_n = n;
  801c36:	a3 04 60 80 00       	mov    %eax,0x806004
        memmove(fsipcbuf.write.req_buf,buf,n);  
  801c3b:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c3f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c42:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c46:	c7 04 24 08 60 80 00 	movl   $0x806008,(%esp)
  801c4d:	e8 a3 f0 ff ff       	call   800cf5 <memmove>
        r = fsipc(FSREQ_WRITE,NULL);
  801c52:	ba 00 00 00 00       	mov    $0x0,%edx
  801c57:	b8 04 00 00 00       	mov    $0x4,%eax
  801c5c:	e8 8b fe ff ff       	call   801aec <fsipc>
        return r;
	//panic("devfile_write not implemented");
}
  801c61:	c9                   	leave  
  801c62:	c3                   	ret    

00801c63 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801c63:	55                   	push   %ebp
  801c64:	89 e5                	mov    %esp,%ebp
  801c66:	53                   	push   %ebx
  801c67:	83 ec 14             	sub    $0x14,%esp
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
        int r;
        fsipcbuf.read.req_fileid = fd->fd_file.id;
  801c6a:	8b 45 08             	mov    0x8(%ebp),%eax
  801c6d:	8b 40 0c             	mov    0xc(%eax),%eax
  801c70:	a3 00 60 80 00       	mov    %eax,0x806000
        fsipcbuf.read.req_n = n;
  801c75:	8b 45 10             	mov    0x10(%ebp),%eax
  801c78:	a3 04 60 80 00       	mov    %eax,0x806004
        r = fsipc(FSREQ_READ,NULL);
  801c7d:	ba 00 00 00 00       	mov    $0x0,%edx
  801c82:	b8 03 00 00 00       	mov    $0x3,%eax
  801c87:	e8 60 fe ff ff       	call   801aec <fsipc>
  801c8c:	89 c3                	mov    %eax,%ebx
        if(r < 0)
  801c8e:	85 c0                	test   %eax,%eax
  801c90:	78 17                	js     801ca9 <devfile_read+0x46>
           return r;
        memmove(buf,fsipcbuf.readRet.ret_buf,r);
  801c92:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c96:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801c9d:	00 
  801c9e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ca1:	89 04 24             	mov    %eax,(%esp)
  801ca4:	e8 4c f0 ff ff       	call   800cf5 <memmove>
        return r;
	//panic("devfile_read not implemented");
}
  801ca9:	89 d8                	mov    %ebx,%eax
  801cab:	83 c4 14             	add    $0x14,%esp
  801cae:	5b                   	pop    %ebx
  801caf:	5d                   	pop    %ebp
  801cb0:	c3                   	ret    

00801cb1 <remove>:
}

// Delete a file
int
remove(const char *path)
{
  801cb1:	55                   	push   %ebp
  801cb2:	89 e5                	mov    %esp,%ebp
  801cb4:	53                   	push   %ebx
  801cb5:	83 ec 14             	sub    $0x14,%esp
  801cb8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  801cbb:	89 1c 24             	mov    %ebx,(%esp)
  801cbe:	e8 fd ed ff ff       	call   800ac0 <strlen>
  801cc3:	89 c2                	mov    %eax,%edx
  801cc5:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  801cca:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
  801cd0:	7f 1f                	jg     801cf1 <remove+0x40>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  801cd2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801cd6:	c7 04 24 00 60 80 00 	movl   $0x806000,(%esp)
  801cdd:	e8 28 ee ff ff       	call   800b0a <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  801ce2:	ba 00 00 00 00       	mov    $0x0,%edx
  801ce7:	b8 07 00 00 00       	mov    $0x7,%eax
  801cec:	e8 fb fd ff ff       	call   801aec <fsipc>
}
  801cf1:	83 c4 14             	add    $0x14,%esp
  801cf4:	5b                   	pop    %ebx
  801cf5:	5d                   	pop    %ebp
  801cf6:	c3                   	ret    

00801cf7 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801cf7:	55                   	push   %ebp
  801cf8:	89 e5                	mov    %esp,%ebp
  801cfa:	83 ec 28             	sub    $0x28,%esp
  801cfd:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801d00:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801d03:	8b 75 08             	mov    0x8(%ebp),%esi
	// If any step after fd_alloc fails, use fd_close to free the
	// file descriptor.

	// LAB 5: Your code here.
        struct Fd* fd;
        if(strlen(path) > MAXPATHLEN)
  801d06:	89 34 24             	mov    %esi,(%esp)
  801d09:	e8 b2 ed ff ff       	call   800ac0 <strlen>
  801d0e:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801d13:	3d 00 04 00 00       	cmp    $0x400,%eax
  801d18:	7f 6d                	jg     801d87 <open+0x90>
            return -E_BAD_PATH;
        int r;
        r = fd_alloc(&fd);
  801d1a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d1d:	89 04 24             	mov    %eax,(%esp)
  801d20:	e8 d6 f7 ff ff       	call   8014fb <fd_alloc>
  801d25:	89 c3                	mov    %eax,%ebx
        if(r < 0)
  801d27:	85 c0                	test   %eax,%eax
  801d29:	78 5c                	js     801d87 <open+0x90>
           return r;
        fsipcbuf.open.req_omode = mode;
  801d2b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d2e:	a3 00 64 80 00       	mov    %eax,0x806400
        memmove(fsipcbuf.open.req_path,path,strlen(path)+1);
  801d33:	89 34 24             	mov    %esi,(%esp)
  801d36:	e8 85 ed ff ff       	call   800ac0 <strlen>
  801d3b:	83 c0 01             	add    $0x1,%eax
  801d3e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d42:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d46:	c7 04 24 00 60 80 00 	movl   $0x806000,(%esp)
  801d4d:	e8 a3 ef ff ff       	call   800cf5 <memmove>
        r = fsipc(FSREQ_OPEN,(void*)fd);
  801d52:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801d55:	b8 01 00 00 00       	mov    $0x1,%eax
  801d5a:	e8 8d fd ff ff       	call   801aec <fsipc>
  801d5f:	89 c3                	mov    %eax,%ebx
        if(r < 0){
  801d61:	85 c0                	test   %eax,%eax
  801d63:	79 15                	jns    801d7a <open+0x83>
             fd_close(fd,0);
  801d65:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801d6c:	00 
  801d6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d70:	89 04 24             	mov    %eax,(%esp)
  801d73:	e8 37 fb ff ff       	call   8018af <fd_close>
             return r;
  801d78:	eb 0d                	jmp    801d87 <open+0x90>
        }
        return fd2num(fd);
  801d7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d7d:	89 04 24             	mov    %eax,(%esp)
  801d80:	e8 4b f7 ff ff       	call   8014d0 <fd2num>
  801d85:	89 c3                	mov    %eax,%ebx
	//panic("open not implemented");
}
  801d87:	89 d8                	mov    %ebx,%eax
  801d89:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801d8c:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801d8f:	89 ec                	mov    %ebp,%esp
  801d91:	5d                   	pop    %ebp
  801d92:	c3                   	ret    
	...

00801d94 <map_segment>:
}

static int
map_segment(envid_t child, uintptr_t va, size_t memsz,
	int fd, size_t filesz, off_t fileoffset, int perm)
{
  801d94:	55                   	push   %ebp
  801d95:	89 e5                	mov    %esp,%ebp
  801d97:	57                   	push   %edi
  801d98:	56                   	push   %esi
  801d99:	53                   	push   %ebx
  801d9a:	83 ec 3c             	sub    $0x3c,%esp
  801d9d:	89 45 dc             	mov    %eax,-0x24(%ebp)
  801da0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  801da3:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801da6:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801da9:	89 d0                	mov    %edx,%eax
  801dab:	25 ff 0f 00 00       	and    $0xfff,%eax
  801db0:	74 0d                	je     801dbf <map_segment+0x2b>
		va -= i;
  801db2:	29 c2                	sub    %eax,%edx
  801db4:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		memsz += i;
  801db7:	01 45 e0             	add    %eax,-0x20(%ebp)
		filesz += i;
  801dba:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  801dbc:	29 45 10             	sub    %eax,0x10(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801dbf:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801dc3:	0f 84 12 01 00 00    	je     801edb <map_segment+0x147>
  801dc9:	be 00 00 00 00       	mov    $0x0,%esi
  801dce:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (i >= filesz) {
  801dd3:	39 f7                	cmp    %esi,%edi
  801dd5:	77 26                	ja     801dfd <map_segment+0x69>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801dd7:	8b 45 14             	mov    0x14(%ebp),%eax
  801dda:	89 44 24 08          	mov    %eax,0x8(%esp)
  801dde:	03 75 e4             	add    -0x1c(%ebp),%esi
  801de1:	89 74 24 04          	mov    %esi,0x4(%esp)
  801de5:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801de8:	89 14 24             	mov    %edx,(%esp)
  801deb:	e8 43 f5 ff ff       	call   801333 <sys_page_alloc>
  801df0:	85 c0                	test   %eax,%eax
  801df2:	0f 89 d2 00 00 00    	jns    801eca <map_segment+0x136>
  801df8:	e9 e3 00 00 00       	jmp    801ee0 <map_segment+0x14c>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801dfd:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801e04:	00 
  801e05:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801e0c:	00 
  801e0d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e14:	e8 1a f5 ff ff       	call   801333 <sys_page_alloc>
  801e19:	85 c0                	test   %eax,%eax
  801e1b:	0f 88 bf 00 00 00    	js     801ee0 <map_segment+0x14c>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801e21:	8b 55 10             	mov    0x10(%ebp),%edx
  801e24:	8d 04 13             	lea    (%ebx,%edx,1),%eax
  801e27:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e2b:	8b 45 08             	mov    0x8(%ebp),%eax
  801e2e:	89 04 24             	mov    %eax,(%esp)
  801e31:	e8 7f f7 ff ff       	call   8015b5 <seek>
  801e36:	85 c0                	test   %eax,%eax
  801e38:	0f 88 a2 00 00 00    	js     801ee0 <map_segment+0x14c>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801e3e:	89 f8                	mov    %edi,%eax
  801e40:	29 f0                	sub    %esi,%eax
  801e42:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801e47:	76 05                	jbe    801e4e <map_segment+0xba>
  801e49:	b8 00 10 00 00       	mov    $0x1000,%eax
  801e4e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e52:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801e59:	00 
  801e5a:	8b 55 08             	mov    0x8(%ebp),%edx
  801e5d:	89 14 24             	mov    %edx,(%esp)
  801e60:	e8 f7 f9 ff ff       	call   80185c <readn>
  801e65:	85 c0                	test   %eax,%eax
  801e67:	78 77                	js     801ee0 <map_segment+0x14c>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801e69:	8b 45 14             	mov    0x14(%ebp),%eax
  801e6c:	89 44 24 10          	mov    %eax,0x10(%esp)
  801e70:	03 75 e4             	add    -0x1c(%ebp),%esi
  801e73:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801e77:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801e7a:	89 54 24 08          	mov    %edx,0x8(%esp)
  801e7e:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801e85:	00 
  801e86:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e8d:	e8 33 f4 ff ff       	call   8012c5 <sys_page_map>
  801e92:	85 c0                	test   %eax,%eax
  801e94:	79 20                	jns    801eb6 <map_segment+0x122>
				panic("spawn: sys_page_map data: %e", r);
  801e96:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e9a:	c7 44 24 08 f0 2f 80 	movl   $0x802ff0,0x8(%esp)
  801ea1:	00 
  801ea2:	c7 44 24 04 21 01 00 	movl   $0x121,0x4(%esp)
  801ea9:	00 
  801eaa:	c7 04 24 0d 30 80 00 	movl   $0x80300d,(%esp)
  801eb1:	e8 66 e2 ff ff       	call   80011c <_panic>
			sys_page_unmap(0, UTEMP);
  801eb6:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801ebd:	00 
  801ebe:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ec5:	e8 8f f3 ff ff       	call   801259 <sys_page_unmap>
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801eca:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801ed0:	89 de                	mov    %ebx,%esi
  801ed2:	39 5d e0             	cmp    %ebx,-0x20(%ebp)
  801ed5:	0f 87 f8 fe ff ff    	ja     801dd3 <map_segment+0x3f>
  801edb:	b8 00 00 00 00       	mov    $0x0,%eax
				panic("spawn: sys_page_map data: %e", r);
			sys_page_unmap(0, UTEMP);
		}
	}
	return 0;
}
  801ee0:	83 c4 3c             	add    $0x3c,%esp
  801ee3:	5b                   	pop    %ebx
  801ee4:	5e                   	pop    %esi
  801ee5:	5f                   	pop    %edi
  801ee6:	5d                   	pop    %ebp
  801ee7:	c3                   	ret    

00801ee8 <exec>:

int
exec(const char *prog, const char **argv)
{
  801ee8:	55                   	push   %ebp
  801ee9:	89 e5                	mov    %esp,%ebp
  801eeb:	57                   	push   %edi
  801eec:	56                   	push   %esi
  801eed:	53                   	push   %ebx
  801eee:	81 ec 4c 02 00 00    	sub    $0x24c,%esp
        struct Proghdr *ph;
        int perm;
        uint32_t tf_esp;
        uint32_t tmp = FTEMP;

        if ((r = open(prog, O_RDONLY)) < 0){
  801ef4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801efb:	00 
  801efc:	8b 45 08             	mov    0x8(%ebp),%eax
  801eff:	89 04 24             	mov    %eax,(%esp)
  801f02:	e8 f0 fd ff ff       	call   801cf7 <open>
  801f07:	89 85 e4 fd ff ff    	mov    %eax,-0x21c(%ebp)
  801f0d:	89 c7                	mov    %eax,%edi
  801f0f:	85 c0                	test   %eax,%eax
  801f11:	0f 88 69 03 00 00    	js     802280 <exec+0x398>
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
	    || elf->e_magic != ELF_MAGIC) {
  801f17:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  801f1e:	00 
  801f1f:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  801f25:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f29:	89 3c 24             	mov    %edi,(%esp)
  801f2c:	e8 2b f9 ff ff       	call   80185c <readn>
        }
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801f31:	3d 00 02 00 00       	cmp    $0x200,%eax
  801f36:	75 0c                	jne    801f44 <exec+0x5c>
	    || elf->e_magic != ELF_MAGIC) {
  801f38:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801f3f:	45 4c 46 
  801f42:	74 36                	je     801f7a <exec+0x92>
		close(fd);
  801f44:	8b 85 e4 fd ff ff    	mov    -0x21c(%ebp),%eax
  801f4a:	89 04 24             	mov    %eax,(%esp)
  801f4d:	e8 dc f9 ff ff       	call   80192e <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801f52:	c7 44 24 08 7f 45 4c 	movl   $0x464c457f,0x8(%esp)
  801f59:	46 
  801f5a:	8b 85 e8 fd ff ff    	mov    -0x218(%ebp),%eax
  801f60:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f64:	c7 04 24 19 30 80 00 	movl   $0x803019,(%esp)
  801f6b:	e8 65 e2 ff ff       	call   8001d5 <cprintf>
  801f70:	bf f2 ff ff ff       	mov    $0xfffffff2,%edi
		return -E_NOT_EXEC;
  801f75:	e9 06 03 00 00       	jmp    802280 <exec+0x398>
	}

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801f7a:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801f80:	66 83 bd 14 fe ff ff 	cmpw   $0x0,-0x1ec(%ebp)
  801f87:	00 
  801f88:	0f 84 a5 00 00 00    	je     802033 <exec+0x14b>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
		return -E_NOT_EXEC;
	}

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801f8e:	8d 9c 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%ebx
  801f95:	c7 85 e0 fd ff ff 00 	movl   $0xe0000000,-0x220(%ebp)
  801f9c:	00 00 e0 
  801f9f:	be 00 00 00 00       	mov    $0x0,%esi
  801fa4:	bf 00 00 00 e0       	mov    $0xe0000000,%edi
	for (i = 0; i < elf->e_phnum; i++, ph++) {
		if (ph->p_type != ELF_PROG_LOAD)
  801fa9:	83 3b 01             	cmpl   $0x1,(%ebx)
  801fac:	75 6f                	jne    80201d <exec+0x135>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801fae:	8b 43 18             	mov    0x18(%ebx),%eax
  801fb1:	83 e0 02             	and    $0x2,%eax
  801fb4:	83 f8 01             	cmp    $0x1,%eax
  801fb7:	19 c0                	sbb    %eax,%eax
  801fb9:	83 e0 fe             	and    $0xfffffffe,%eax
  801fbc:	83 c0 07             	add    $0x7,%eax
			perm |= PTE_W;
		if ((r = map_segment(0, tmp + PGOFF(ph->p_va), ph->p_memsz,
  801fbf:	8b 4b 14             	mov    0x14(%ebx),%ecx
  801fc2:	8b 53 08             	mov    0x8(%ebx),%edx
  801fc5:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
  801fcb:	8d 14 17             	lea    (%edi,%edx,1),%edx
  801fce:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801fd2:	8b 43 04             	mov    0x4(%ebx),%eax
  801fd5:	89 44 24 08          	mov    %eax,0x8(%esp)
  801fd9:	8b 43 10             	mov    0x10(%ebx),%eax
  801fdc:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fe0:	8b 85 e4 fd ff ff    	mov    -0x21c(%ebp),%eax
  801fe6:	89 04 24             	mov    %eax,(%esp)
  801fe9:	b8 00 00 00 00       	mov    $0x0,%eax
  801fee:	e8 a1 fd ff ff       	call   801d94 <map_segment>
  801ff3:	85 c0                	test   %eax,%eax
  801ff5:	79 0d                	jns    802004 <exec+0x11c>
  801ff7:	89 c7                	mov    %eax,%edi
  801ff9:	8b 9d e4 fd ff ff    	mov    -0x21c(%ebp),%ebx
  801fff:	e9 68 02 00 00       	jmp    80226c <exec+0x384>
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
                tmp += ROUNDUP(PGOFF(ph->p_va) + ph->p_memsz, PGSIZE);
  802004:	8b 53 14             	mov    0x14(%ebx),%edx
  802007:	8b 43 08             	mov    0x8(%ebx),%eax
  80200a:	25 ff 0f 00 00       	and    $0xfff,%eax
  80200f:	8d 84 02 ff 0f 00 00 	lea    0xfff(%edx,%eax,1),%eax
  802016:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80201b:	01 c7                	add    %eax,%edi
		return -E_NOT_EXEC;
	}

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  80201d:	83 c6 01             	add    $0x1,%esi
  802020:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  802027:	39 f0                	cmp    %esi,%eax
  802029:	7e 14                	jle    80203f <exec+0x157>
  80202b:	83 c3 20             	add    $0x20,%ebx
  80202e:	e9 76 ff ff ff       	jmp    801fa9 <exec+0xc1>
  802033:	c7 85 e0 fd ff ff 00 	movl   $0xe0000000,-0x220(%ebp)
  80203a:	00 00 e0 
  80203d:	eb 06                	jmp    802045 <exec+0x15d>
  80203f:	89 bd e0 fd ff ff    	mov    %edi,-0x220(%ebp)
		if ((r = map_segment(0, tmp + PGOFF(ph->p_va), ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
                tmp += ROUNDUP(PGOFF(ph->p_va) + ph->p_memsz, PGSIZE);
	}
	close(fd);
  802045:	8b 95 e4 fd ff ff    	mov    -0x21c(%ebp),%edx
  80204b:	89 14 24             	mov    %edx,(%esp)
  80204e:	e8 db f8 ff ff       	call   80192e <close>
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  802053:	8b 55 0c             	mov    0xc(%ebp),%edx
  802056:	8b 02                	mov    (%edx),%eax
  802058:	be 00 00 00 00       	mov    $0x0,%esi
  80205d:	bb 00 00 00 00       	mov    $0x0,%ebx
  802062:	85 c0                	test   %eax,%eax
  802064:	75 16                	jne    80207c <exec+0x194>
  802066:	c7 85 d0 fd ff ff 00 	movl   $0x0,-0x230(%ebp)
  80206d:	00 00 00 
  802070:	c7 85 cc fd ff ff 00 	movl   $0x0,-0x234(%ebp)
  802077:	00 00 00 
  80207a:	eb 2c                	jmp    8020a8 <exec+0x1c0>
  80207c:	8b 7d 0c             	mov    0xc(%ebp),%edi
		string_size += strlen(argv[argc]) + 1;
  80207f:	89 04 24             	mov    %eax,(%esp)
  802082:	e8 39 ea ff ff       	call   800ac0 <strlen>
  802087:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  80208b:	83 c3 01             	add    $0x1,%ebx
  80208e:	8d 14 9d 00 00 00 00 	lea    0x0(,%ebx,4),%edx
  802095:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  802098:	85 c0                	test   %eax,%eax
  80209a:	75 e3                	jne    80207f <exec+0x197>
  80209c:	89 95 d0 fd ff ff    	mov    %edx,-0x230(%ebp)
  8020a2:	89 9d cc fd ff ff    	mov    %ebx,-0x234(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  8020a8:	f7 de                	neg    %esi
  8020aa:	81 c6 00 10 40 00    	add    $0x401000,%esi
  8020b0:	89 b5 d8 fd ff ff    	mov    %esi,-0x228(%ebp)
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  8020b6:	89 f2                	mov    %esi,%edx
  8020b8:	83 e2 fc             	and    $0xfffffffc,%edx
  8020bb:	89 d8                	mov    %ebx,%eax
  8020bd:	f7 d0                	not    %eax
  8020bf:	8d 04 82             	lea    (%edx,%eax,4),%eax
  8020c2:	89 85 e4 fd ff ff    	mov    %eax,-0x21c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  8020c8:	83 e8 08             	sub    $0x8,%eax
  8020cb:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	return 0;

error:
	sys_env_destroy(0);
	close(fd);
	return r;
  8020d1:	bf fc ff ff ff       	mov    $0xfffffffc,%edi
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  8020d6:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  8020db:	0f 86 9f 01 00 00    	jbe    802280 <exec+0x398>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8020e1:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8020e8:	00 
  8020e9:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8020f0:	00 
  8020f1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020f8:	e8 36 f2 ff ff       	call   801333 <sys_page_alloc>
  8020fd:	89 c7                	mov    %eax,%edi
  8020ff:	85 c0                	test   %eax,%eax
  802101:	0f 88 79 01 00 00    	js     802280 <exec+0x398>
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  802107:	85 db                	test   %ebx,%ebx
  802109:	7e 52                	jle    80215d <exec+0x275>
  80210b:	be 00 00 00 00       	mov    $0x0,%esi
  802110:	89 9d dc fd ff ff    	mov    %ebx,-0x224(%ebp)
  802116:	8b bd d8 fd ff ff    	mov    -0x228(%ebp),%edi
  80211c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
		argv_store[i] = UTEMP2USTACK(string_store);
  80211f:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  802125:	8b 95 e4 fd ff ff    	mov    -0x21c(%ebp),%edx
  80212b:	89 04 b2             	mov    %eax,(%edx,%esi,4)
		strcpy(string_store, argv[i]);
  80212e:	8b 04 b3             	mov    (%ebx,%esi,4),%eax
  802131:	89 44 24 04          	mov    %eax,0x4(%esp)
  802135:	89 3c 24             	mov    %edi,(%esp)
  802138:	e8 cd e9 ff ff       	call   800b0a <strcpy>
		string_store += strlen(argv[i]) + 1;
  80213d:	8b 04 b3             	mov    (%ebx,%esi,4),%eax
  802140:	89 04 24             	mov    %eax,(%esp)
  802143:	e8 78 e9 ff ff       	call   800ac0 <strlen>
  802148:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  80214c:	83 c6 01             	add    $0x1,%esi
  80214f:	3b b5 dc fd ff ff    	cmp    -0x224(%ebp),%esi
  802155:	7c c8                	jl     80211f <exec+0x237>
  802157:	89 bd d8 fd ff ff    	mov    %edi,-0x228(%ebp)
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  80215d:	8b 95 e4 fd ff ff    	mov    -0x21c(%ebp),%edx
  802163:	8b 85 d0 fd ff ff    	mov    -0x230(%ebp),%eax
  802169:	c7 04 02 00 00 00 00 	movl   $0x0,(%edx,%eax,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  802170:	81 bd d8 fd ff ff 00 	cmpl   $0x401000,-0x228(%ebp)
  802177:	10 40 00 
  80217a:	74 24                	je     8021a0 <exec+0x2b8>
  80217c:	c7 44 24 0c 7c 30 80 	movl   $0x80307c,0xc(%esp)
  802183:	00 
  802184:	c7 44 24 08 33 30 80 	movl   $0x803033,0x8(%esp)
  80218b:	00 
  80218c:	c7 44 24 04 97 01 00 	movl   $0x197,0x4(%esp)
  802193:	00 
  802194:	c7 04 24 0d 30 80 00 	movl   $0x80300d,(%esp)
  80219b:	e8 7c df ff ff       	call   80011c <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  8021a0:	8b 85 e4 fd ff ff    	mov    -0x21c(%ebp),%eax
  8021a6:	2d 00 30 80 11       	sub    $0x11803000,%eax
  8021ab:	8b 95 e4 fd ff ff    	mov    -0x21c(%ebp),%edx
  8021b1:	89 42 fc             	mov    %eax,-0x4(%edx)
	argv_store[-2] = argc;
  8021b4:	8b 95 cc fd ff ff    	mov    -0x234(%ebp),%edx
  8021ba:	8b 85 d4 fd ff ff    	mov    -0x22c(%ebp),%eax
  8021c0:	89 10                	mov    %edx,(%eax)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, envid, (void*) stack, PTE_P | PTE_U | PTE_W)) < 0)
  8021c2:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  8021c9:	00 
  8021ca:	8b 85 e0 fd ff ff    	mov    -0x220(%ebp),%eax
  8021d0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8021d4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8021db:	00 
  8021dc:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8021e3:	00 
  8021e4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8021eb:	e8 d5 f0 ff ff       	call   8012c5 <sys_page_map>
  8021f0:	89 c7                	mov    %eax,%edi
  8021f2:	85 c0                	test   %eax,%eax
  8021f4:	78 1a                	js     802210 <exec+0x328>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  8021f6:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8021fd:	00 
  8021fe:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802205:	e8 4f f0 ff ff       	call   801259 <sys_page_unmap>
  80220a:	89 c7                	mov    %eax,%edi
  80220c:	85 c0                	test   %eax,%eax
  80220e:	79 16                	jns    802226 <exec+0x33e>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  802210:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  802217:	00 
  802218:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80221f:	e8 35 f0 ff ff       	call   801259 <sys_page_unmap>
  802224:	eb 5a                	jmp    802280 <exec+0x398>
	close(fd);
	fd = -1;
        if ((r = init_stack_2(0, argv, &tf_esp,tmp)) < 0)
		return r;

	if (sys_exec((void*)(elf_buf + elf->e_phoff), elf->e_phnum, tf_esp, elf->e_entry) < 0)
  802226:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  80222c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802230:	8b 85 e4 fd ff ff    	mov    -0x21c(%ebp),%eax
  802236:	2d 08 30 80 11       	sub    $0x11803008,%eax
  80223b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80223f:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  802246:	89 44 24 04          	mov    %eax,0x4(%esp)
  80224a:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  802250:	03 85 04 fe ff ff    	add    -0x1fc(%ebp),%eax
  802256:	89 04 24             	mov    %eax,(%esp)
  802259:	e8 1d ed ff ff       	call   800f7b <sys_exec>
  80225e:	bf 00 00 00 00       	mov    $0x0,%edi
  802263:	85 c0                	test   %eax,%eax
  802265:	79 19                	jns    802280 <exec+0x398>
  802267:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
		goto error;
	return 0;

error:
	sys_env_destroy(0);
  80226c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802273:	e8 ea f1 ff ff       	call   801462 <sys_env_destroy>
	close(fd);
  802278:	89 1c 24             	mov    %ebx,(%esp)
  80227b:	e8 ae f6 ff ff       	call   80192e <close>
	return r;
}
  802280:	89 f8                	mov    %edi,%eax
  802282:	81 c4 4c 02 00 00    	add    $0x24c,%esp
  802288:	5b                   	pop    %ebx
  802289:	5e                   	pop    %esi
  80228a:	5f                   	pop    %edi
  80228b:	5d                   	pop    %ebp
  80228c:	c3                   	ret    

0080228d <execl>:
	return r;
}

int
execl(const char *prog, const char *arg0, ...)
{
  80228d:	55                   	push   %ebp
  80228e:	89 e5                	mov    %esp,%ebp
  802290:	56                   	push   %esi
  802291:	53                   	push   %ebx
  802292:	83 ec 10             	sub    $0x10,%esp
  802295:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	sys_page_unmap(0, UTEMP);
	return r;
}

int
execl(const char *prog, const char *arg0, ...)
  802298:	8d 55 10             	lea    0x10(%ebp),%edx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  80229b:	83 3a 00             	cmpl   $0x0,(%edx)
  80229e:	74 5d                	je     8022fd <execl+0x70>
  8022a0:	b8 00 00 00 00       	mov    $0x0,%eax
		argc++;
  8022a5:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  8022a8:	83 3c 82 00          	cmpl   $0x0,(%edx,%eax,4)
  8022ac:	75 f7                	jne    8022a5 <execl+0x18>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  8022ae:	8d 14 85 26 00 00 00 	lea    0x26(,%eax,4),%edx
  8022b5:	83 e2 f0             	and    $0xfffffff0,%edx
  8022b8:	29 d4                	sub    %edx,%esp
  8022ba:	8d 4c 24 17          	lea    0x17(%esp),%ecx
  8022be:	83 e1 f0             	and    $0xfffffff0,%ecx
	argv[0] = arg0;
  8022c1:	89 19                	mov    %ebx,(%ecx)
	argv[argc+1] = NULL;
  8022c3:	c7 44 81 04 00 00 00 	movl   $0x0,0x4(%ecx,%eax,4)
  8022ca:	00 
	sys_page_unmap(0, UTEMP);
	return r;
}

int
execl(const char *prog, const char *arg0, ...)
  8022cb:	8d 75 10             	lea    0x10(%ebp),%esi
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  8022ce:	89 c3                	mov    %eax,%ebx
  8022d0:	85 c0                	test   %eax,%eax
  8022d2:	74 13                	je     8022e7 <execl+0x5a>
  8022d4:	b8 00 00 00 00       	mov    $0x0,%eax
		argv[i+1] = va_arg(vl, const char *);
  8022d9:	83 c0 01             	add    $0x1,%eax
  8022dc:	8b 54 86 fc          	mov    -0x4(%esi,%eax,4),%edx
  8022e0:	89 14 81             	mov    %edx,(%ecx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  8022e3:	39 d8                	cmp    %ebx,%eax
  8022e5:	72 f2                	jb     8022d9 <execl+0x4c>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return exec(prog, argv);
  8022e7:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8022eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8022ee:	89 04 24             	mov    %eax,(%esp)
  8022f1:	e8 f2 fb ff ff       	call   801ee8 <exec>
}
  8022f6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8022f9:	5b                   	pop    %ebx
  8022fa:	5e                   	pop    %esi
  8022fb:	5d                   	pop    %ebp
  8022fc:	c3                   	ret    
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  8022fd:	83 ec 20             	sub    $0x20,%esp
  802300:	8d 4c 24 17          	lea    0x17(%esp),%ecx
  802304:	83 e1 f0             	and    $0xfffffff0,%ecx
	argv[0] = arg0;
  802307:	89 19                	mov    %ebx,(%ecx)
	argv[argc+1] = NULL;
  802309:	c7 41 04 00 00 00 00 	movl   $0x0,0x4(%ecx)
  802310:	eb d5                	jmp    8022e7 <execl+0x5a>

00802312 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  802312:	55                   	push   %ebp
  802313:	89 e5                	mov    %esp,%ebp
  802315:	57                   	push   %edi
  802316:	56                   	push   %esi
  802317:	53                   	push   %ebx
  802318:	81 ec 9c 02 00 00    	sub    $0x29c,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  80231e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  802325:	00 
  802326:	8b 45 08             	mov    0x8(%ebp),%eax
  802329:	89 04 24             	mov    %eax,(%esp)
  80232c:	e8 c6 f9 ff ff       	call   801cf7 <open>
  802331:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  802337:	89 c7                	mov    %eax,%edi
  802339:	85 c0                	test   %eax,%eax
  80233b:	0f 88 ae 03 00 00    	js     8026ef <spawn+0x3dd>
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
	    || elf->e_magic != ELF_MAGIC) {
  802341:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  802348:	00 
  802349:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  80234f:	89 44 24 04          	mov    %eax,0x4(%esp)
  802353:	89 3c 24             	mov    %edi,(%esp)
  802356:	e8 01 f5 ff ff       	call   80185c <readn>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  80235b:	3d 00 02 00 00       	cmp    $0x200,%eax
  802360:	75 0c                	jne    80236e <spawn+0x5c>
	    || elf->e_magic != ELF_MAGIC) {
  802362:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  802369:	45 4c 46 
  80236c:	74 36                	je     8023a4 <spawn+0x92>
		close(fd);
  80236e:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  802374:	89 04 24             	mov    %eax,(%esp)
  802377:	e8 b2 f5 ff ff       	call   80192e <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  80237c:	c7 44 24 08 7f 45 4c 	movl   $0x464c457f,0x8(%esp)
  802383:	46 
  802384:	8b 85 e8 fd ff ff    	mov    -0x218(%ebp),%eax
  80238a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80238e:	c7 04 24 19 30 80 00 	movl   $0x803019,(%esp)
  802395:	e8 3b de ff ff       	call   8001d5 <cprintf>
  80239a:	bf f2 ff ff ff       	mov    $0xfffffff2,%edi
		return -E_NOT_EXEC;
  80239f:	e9 4b 03 00 00       	jmp    8026ef <spawn+0x3dd>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  8023a4:	ba 08 00 00 00       	mov    $0x8,%edx
  8023a9:	89 d0                	mov    %edx,%eax
  8023ab:	cd 30                	int    $0x30
  8023ad:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  8023b3:	85 c0                	test   %eax,%eax
  8023b5:	0f 88 2e 03 00 00    	js     8026e9 <spawn+0x3d7>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  8023bb:	25 ff 03 00 00       	and    $0x3ff,%eax
  8023c0:	89 c2                	mov    %eax,%edx
  8023c2:	c1 e2 07             	shl    $0x7,%edx
  8023c5:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  8023cb:	8d b4 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%esi
  8023d2:	b9 11 00 00 00       	mov    $0x11,%ecx
  8023d7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  8023d9:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  8023df:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  8023e5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8023e8:	8b 02                	mov    (%edx),%eax
  8023ea:	be 00 00 00 00       	mov    $0x0,%esi
  8023ef:	bb 00 00 00 00       	mov    $0x0,%ebx
  8023f4:	85 c0                	test   %eax,%eax
  8023f6:	75 16                	jne    80240e <spawn+0xfc>
  8023f8:	c7 85 7c fd ff ff 00 	movl   $0x0,-0x284(%ebp)
  8023ff:	00 00 00 
  802402:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  802409:	00 00 00 
  80240c:	eb 2c                	jmp    80243a <spawn+0x128>
  80240e:	8b 7d 0c             	mov    0xc(%ebp),%edi
		string_size += strlen(argv[argc]) + 1;
  802411:	89 04 24             	mov    %eax,(%esp)
  802414:	e8 a7 e6 ff ff       	call   800ac0 <strlen>
  802419:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  80241d:	83 c3 01             	add    $0x1,%ebx
  802420:	8d 14 9d 00 00 00 00 	lea    0x0(,%ebx,4),%edx
  802427:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  80242a:	85 c0                	test   %eax,%eax
  80242c:	75 e3                	jne    802411 <spawn+0xff>
  80242e:	89 95 7c fd ff ff    	mov    %edx,-0x284(%ebp)
  802434:	89 9d 78 fd ff ff    	mov    %ebx,-0x288(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  80243a:	f7 de                	neg    %esi
  80243c:	81 c6 00 10 40 00    	add    $0x401000,%esi
  802442:	89 b5 84 fd ff ff    	mov    %esi,-0x27c(%ebp)
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  802448:	89 f2                	mov    %esi,%edx
  80244a:	83 e2 fc             	and    $0xfffffffc,%edx
  80244d:	89 d8                	mov    %ebx,%eax
  80244f:	f7 d0                	not    %eax
  802451:	8d 04 82             	lea    (%edx,%eax,4),%eax
  802454:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  80245a:	83 e8 08             	sub    $0x8,%eax
  80245d:	89 85 80 fd ff ff    	mov    %eax,-0x280(%ebp)
	return child;

error:
	sys_env_destroy(child);
	close(fd);
	return r;
  802463:	bf fc ff ff ff       	mov    $0xfffffffc,%edi
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  802468:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  80246d:	0f 86 7c 02 00 00    	jbe    8026ef <spawn+0x3dd>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  802473:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80247a:	00 
  80247b:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  802482:	00 
  802483:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80248a:	e8 a4 ee ff ff       	call   801333 <sys_page_alloc>
  80248f:	89 c7                	mov    %eax,%edi
  802491:	85 c0                	test   %eax,%eax
  802493:	0f 88 56 02 00 00    	js     8026ef <spawn+0x3dd>
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  802499:	85 db                	test   %ebx,%ebx
  80249b:	7e 52                	jle    8024ef <spawn+0x1dd>
  80249d:	be 00 00 00 00       	mov    $0x0,%esi
  8024a2:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  8024a8:	8b bd 84 fd ff ff    	mov    -0x27c(%ebp),%edi
  8024ae:	8b 5d 0c             	mov    0xc(%ebp),%ebx
		argv_store[i] = UTEMP2USTACK(string_store);
  8024b1:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  8024b7:	8b 95 8c fd ff ff    	mov    -0x274(%ebp),%edx
  8024bd:	89 04 b2             	mov    %eax,(%edx,%esi,4)
		strcpy(string_store, argv[i]);
  8024c0:	8b 04 b3             	mov    (%ebx,%esi,4),%eax
  8024c3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8024c7:	89 3c 24             	mov    %edi,(%esp)
  8024ca:	e8 3b e6 ff ff       	call   800b0a <strcpy>
		string_store += strlen(argv[i]) + 1;
  8024cf:	8b 04 b3             	mov    (%ebx,%esi,4),%eax
  8024d2:	89 04 24             	mov    %eax,(%esp)
  8024d5:	e8 e6 e5 ff ff       	call   800ac0 <strlen>
  8024da:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  8024de:	83 c6 01             	add    $0x1,%esi
  8024e1:	3b b5 88 fd ff ff    	cmp    -0x278(%ebp),%esi
  8024e7:	7c c8                	jl     8024b1 <spawn+0x19f>
  8024e9:	89 bd 84 fd ff ff    	mov    %edi,-0x27c(%ebp)
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  8024ef:	8b 95 8c fd ff ff    	mov    -0x274(%ebp),%edx
  8024f5:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  8024fb:	c7 04 02 00 00 00 00 	movl   $0x0,(%edx,%eax,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  802502:	81 bd 84 fd ff ff 00 	cmpl   $0x401000,-0x27c(%ebp)
  802509:	10 40 00 
  80250c:	74 24                	je     802532 <spawn+0x220>
  80250e:	c7 44 24 0c 7c 30 80 	movl   $0x80307c,0xc(%esp)
  802515:	00 
  802516:	c7 44 24 08 33 30 80 	movl   $0x803033,0x8(%esp)
  80251d:	00 
  80251e:	c7 44 24 04 ee 00 00 	movl   $0xee,0x4(%esp)
  802525:	00 
  802526:	c7 04 24 0d 30 80 00 	movl   $0x80300d,(%esp)
  80252d:	e8 ea db ff ff       	call   80011c <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  802532:	8b 85 8c fd ff ff    	mov    -0x274(%ebp),%eax
  802538:	2d 00 30 80 11       	sub    $0x11803000,%eax
  80253d:	8b 95 8c fd ff ff    	mov    -0x274(%ebp),%edx
  802543:	89 42 fc             	mov    %eax,-0x4(%edx)
	argv_store[-2] = argc;
  802546:	8b 95 78 fd ff ff    	mov    -0x288(%ebp),%edx
  80254c:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  802552:	89 10                	mov    %edx,(%eax)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  802554:	8b 85 8c fd ff ff    	mov    -0x274(%ebp),%eax
  80255a:	2d 08 30 80 11       	sub    $0x11803008,%eax
  80255f:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  802565:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  80256c:	00 
  80256d:	c7 44 24 0c 00 d0 bf 	movl   $0xeebfd000,0xc(%esp)
  802574:	ee 
  802575:	8b 85 90 fd ff ff    	mov    -0x270(%ebp),%eax
  80257b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80257f:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  802586:	00 
  802587:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80258e:	e8 32 ed ff ff       	call   8012c5 <sys_page_map>
  802593:	89 c7                	mov    %eax,%edi
  802595:	85 c0                	test   %eax,%eax
  802597:	78 1a                	js     8025b3 <spawn+0x2a1>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  802599:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8025a0:	00 
  8025a1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8025a8:	e8 ac ec ff ff       	call   801259 <sys_page_unmap>
  8025ad:	89 c7                	mov    %eax,%edi
  8025af:	85 c0                	test   %eax,%eax
  8025b1:	79 19                	jns    8025cc <spawn+0x2ba>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  8025b3:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8025ba:	00 
  8025bb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8025c2:	e8 92 ec ff ff       	call   801259 <sys_page_unmap>
  8025c7:	e9 23 01 00 00       	jmp    8026ef <spawn+0x3dd>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  8025cc:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  8025d2:	66 83 bd 14 fe ff ff 	cmpw   $0x0,-0x1ec(%ebp)
  8025d9:	00 
  8025da:	74 69                	je     802645 <spawn+0x333>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  8025dc:	8d 9c 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%ebx
  8025e3:	be 00 00 00 00       	mov    $0x0,%esi
  8025e8:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
	for (i = 0; i < elf->e_phnum; i++, ph++) {
		if (ph->p_type != ELF_PROG_LOAD)
  8025ee:	83 3b 01             	cmpl   $0x1,(%ebx)
  8025f1:	75 3f                	jne    802632 <spawn+0x320>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  8025f3:	8b 43 18             	mov    0x18(%ebx),%eax
  8025f6:	83 e0 02             	and    $0x2,%eax
  8025f9:	83 f8 01             	cmp    $0x1,%eax
  8025fc:	19 c0                	sbb    %eax,%eax
  8025fe:	83 e0 fe             	and    $0xfffffffe,%eax
  802601:	83 c0 07             	add    $0x7,%eax
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  802604:	8b 4b 14             	mov    0x14(%ebx),%ecx
  802607:	8b 53 08             	mov    0x8(%ebx),%edx
  80260a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80260e:	8b 43 04             	mov    0x4(%ebx),%eax
  802611:	89 44 24 08          	mov    %eax,0x8(%esp)
  802615:	8b 43 10             	mov    0x10(%ebx),%eax
  802618:	89 44 24 04          	mov    %eax,0x4(%esp)
  80261c:	89 3c 24             	mov    %edi,(%esp)
  80261f:	8b 85 90 fd ff ff    	mov    -0x270(%ebp),%eax
  802625:	e8 6a f7 ff ff       	call   801d94 <map_segment>
  80262a:	85 c0                	test   %eax,%eax
  80262c:	0f 88 97 00 00 00    	js     8026c9 <spawn+0x3b7>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  802632:	83 c6 01             	add    $0x1,%esi
  802635:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  80263c:	39 f0                	cmp    %esi,%eax
  80263e:	7e 05                	jle    802645 <spawn+0x333>
  802640:	83 c3 20             	add    $0x20,%ebx
  802643:	eb a9                	jmp    8025ee <spawn+0x2dc>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  802645:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  80264b:	89 14 24             	mov    %edx,(%esp)
  80264e:	e8 db f2 ff ff       	call   80192e <close>
	fd = -1;

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  802653:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  802659:	89 44 24 04          	mov    %eax,0x4(%esp)
  80265d:	8b 85 90 fd ff ff    	mov    -0x270(%ebp),%eax
  802663:	89 04 24             	mov    %eax,(%esp)
  802666:	e8 16 eb ff ff       	call   801181 <sys_env_set_trapframe>
  80266b:	85 c0                	test   %eax,%eax
  80266d:	79 20                	jns    80268f <spawn+0x37d>
		panic("sys_env_set_trapframe: %e", r);
  80266f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802673:	c7 44 24 08 48 30 80 	movl   $0x803048,0x8(%esp)
  80267a:	00 
  80267b:	c7 44 24 04 82 00 00 	movl   $0x82,0x4(%esp)
  802682:	00 
  802683:	c7 04 24 0d 30 80 00 	movl   $0x80300d,(%esp)
  80268a:	e8 8d da ff ff       	call   80011c <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  80268f:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  802696:	00 
  802697:	8b 95 90 fd ff ff    	mov    -0x270(%ebp),%edx
  80269d:	89 14 24             	mov    %edx,(%esp)
  8026a0:	e8 48 eb ff ff       	call   8011ed <sys_env_set_status>
  8026a5:	85 c0                	test   %eax,%eax
  8026a7:	79 40                	jns    8026e9 <spawn+0x3d7>
		panic("sys_env_set_status: %e", r);
  8026a9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8026ad:	c7 44 24 08 62 30 80 	movl   $0x803062,0x8(%esp)
  8026b4:	00 
  8026b5:	c7 44 24 04 85 00 00 	movl   $0x85,0x4(%esp)
  8026bc:	00 
  8026bd:	c7 04 24 0d 30 80 00 	movl   $0x80300d,(%esp)
  8026c4:	e8 53 da ff ff       	call   80011c <_panic>
  8026c9:	89 c7                	mov    %eax,%edi

	return child;

error:
	sys_env_destroy(child);
  8026cb:	8b 85 90 fd ff ff    	mov    -0x270(%ebp),%eax
  8026d1:	89 04 24             	mov    %eax,(%esp)
  8026d4:	e8 89 ed ff ff       	call   801462 <sys_env_destroy>
	close(fd);
  8026d9:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  8026df:	89 14 24             	mov    %edx,(%esp)
  8026e2:	e8 47 f2 ff ff       	call   80192e <close>
	return r;
  8026e7:	eb 06                	jmp    8026ef <spawn+0x3dd>
  8026e9:	8b bd 90 fd ff ff    	mov    -0x270(%ebp),%edi
}
  8026ef:	89 f8                	mov    %edi,%eax
  8026f1:	81 c4 9c 02 00 00    	add    $0x29c,%esp
  8026f7:	5b                   	pop    %ebx
  8026f8:	5e                   	pop    %esi
  8026f9:	5f                   	pop    %edi
  8026fa:	5d                   	pop    %ebp
  8026fb:	c3                   	ret    

008026fc <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  8026fc:	55                   	push   %ebp
  8026fd:	89 e5                	mov    %esp,%ebp
  8026ff:	56                   	push   %esi
  802700:	53                   	push   %ebx
  802701:	83 ec 10             	sub    $0x10,%esp
  802704:	8b 5d 0c             	mov    0xc(%ebp),%ebx

// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
  802707:	8d 55 10             	lea    0x10(%ebp),%edx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  80270a:	83 3a 00             	cmpl   $0x0,(%edx)
  80270d:	74 5d                	je     80276c <spawnl+0x70>
  80270f:	b8 00 00 00 00       	mov    $0x0,%eax
		argc++;
  802714:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802717:	83 3c 82 00          	cmpl   $0x0,(%edx,%eax,4)
  80271b:	75 f7                	jne    802714 <spawnl+0x18>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  80271d:	8d 14 85 26 00 00 00 	lea    0x26(,%eax,4),%edx
  802724:	83 e2 f0             	and    $0xfffffff0,%edx
  802727:	29 d4                	sub    %edx,%esp
  802729:	8d 4c 24 17          	lea    0x17(%esp),%ecx
  80272d:	83 e1 f0             	and    $0xfffffff0,%ecx
	argv[0] = arg0;
  802730:	89 19                	mov    %ebx,(%ecx)
	argv[argc+1] = NULL;
  802732:	c7 44 81 04 00 00 00 	movl   $0x0,0x4(%ecx,%eax,4)
  802739:	00 

// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
  80273a:	8d 75 10             	lea    0x10(%ebp),%esi
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  80273d:	89 c3                	mov    %eax,%ebx
  80273f:	85 c0                	test   %eax,%eax
  802741:	74 13                	je     802756 <spawnl+0x5a>
  802743:	b8 00 00 00 00       	mov    $0x0,%eax
		argv[i+1] = va_arg(vl, const char *);
  802748:	83 c0 01             	add    $0x1,%eax
  80274b:	8b 54 86 fc          	mov    -0x4(%esi,%eax,4),%edx
  80274f:	89 14 81             	mov    %edx,(%ecx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  802752:	39 d8                	cmp    %ebx,%eax
  802754:	72 f2                	jb     802748 <spawnl+0x4c>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  802756:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80275a:	8b 45 08             	mov    0x8(%ebp),%eax
  80275d:	89 04 24             	mov    %eax,(%esp)
  802760:	e8 ad fb ff ff       	call   802312 <spawn>
}
  802765:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802768:	5b                   	pop    %ebx
  802769:	5e                   	pop    %esi
  80276a:	5d                   	pop    %ebp
  80276b:	c3                   	ret    
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  80276c:	83 ec 20             	sub    $0x20,%esp
  80276f:	8d 4c 24 17          	lea    0x17(%esp),%ecx
  802773:	83 e1 f0             	and    $0xfffffff0,%ecx
	argv[0] = arg0;
  802776:	89 19                	mov    %ebx,(%ecx)
	argv[argc+1] = NULL;
  802778:	c7 41 04 00 00 00 00 	movl   $0x0,0x4(%ecx)
  80277f:	eb d5                	jmp    802756 <spawnl+0x5a>
	...

00802790 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802790:	55                   	push   %ebp
  802791:	89 e5                	mov    %esp,%ebp
  802793:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  802796:	8b 15 50 00 c0 ee    	mov    0xeec00050,%edx
  80279c:	b8 01 00 00 00       	mov    $0x1,%eax
  8027a1:	39 ca                	cmp    %ecx,%edx
  8027a3:	75 04                	jne    8027a9 <ipc_find_env+0x19>
  8027a5:	b0 00                	mov    $0x0,%al
  8027a7:	eb 12                	jmp    8027bb <ipc_find_env+0x2b>
  8027a9:	89 c2                	mov    %eax,%edx
  8027ab:	c1 e2 07             	shl    $0x7,%edx
  8027ae:	8d 94 82 50 00 c0 ee 	lea    -0x113fffb0(%edx,%eax,4),%edx
  8027b5:	8b 12                	mov    (%edx),%edx
  8027b7:	39 ca                	cmp    %ecx,%edx
  8027b9:	75 10                	jne    8027cb <ipc_find_env+0x3b>
			return envs[i].env_id;
  8027bb:	89 c2                	mov    %eax,%edx
  8027bd:	c1 e2 07             	shl    $0x7,%edx
  8027c0:	8d 84 82 48 00 c0 ee 	lea    -0x113fffb8(%edx,%eax,4),%eax
  8027c7:	8b 00                	mov    (%eax),%eax
  8027c9:	eb 0e                	jmp    8027d9 <ipc_find_env+0x49>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8027cb:	83 c0 01             	add    $0x1,%eax
  8027ce:	3d 00 04 00 00       	cmp    $0x400,%eax
  8027d3:	75 d4                	jne    8027a9 <ipc_find_env+0x19>
  8027d5:	66 b8 00 00          	mov    $0x0,%ax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  8027d9:	5d                   	pop    %ebp
  8027da:	c3                   	ret    

008027db <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8027db:	55                   	push   %ebp
  8027dc:	89 e5                	mov    %esp,%ebp
  8027de:	57                   	push   %edi
  8027df:	56                   	push   %esi
  8027e0:	53                   	push   %ebx
  8027e1:	83 ec 1c             	sub    $0x1c,%esp
  8027e4:	8b 75 08             	mov    0x8(%ebp),%esi
  8027e7:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8027ea:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        int ret;
        while(1){
           if(pg)
  8027ed:	85 db                	test   %ebx,%ebx
  8027ef:	74 19                	je     80280a <ipc_send+0x2f>
              ret = sys_ipc_try_send(to_env,val,pg,perm);
  8027f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8027f4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8027f8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8027fc:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802800:	89 34 24             	mov    %esi,(%esp)
  802803:	e8 cc e8 ff ff       	call   8010d4 <sys_ipc_try_send>
  802808:	eb 1b                	jmp    802825 <ipc_send+0x4a>
           else
              ret = sys_ipc_try_send(to_env,val,(void*)UTOP,perm);
  80280a:	8b 45 14             	mov    0x14(%ebp),%eax
  80280d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802811:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  802818:	ee 
  802819:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80281d:	89 34 24             	mov    %esi,(%esp)
  802820:	e8 af e8 ff ff       	call   8010d4 <sys_ipc_try_send>
           if(ret == 0)
  802825:	85 c0                	test   %eax,%eax
  802827:	74 28                	je     802851 <ipc_send+0x76>
              return;
           if(ret != -E_IPC_NOT_RECV)
  802829:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80282c:	74 1c                	je     80284a <ipc_send+0x6f>
              panic("ipc send error");
  80282e:	c7 44 24 08 a4 30 80 	movl   $0x8030a4,0x8(%esp)
  802835:	00 
  802836:	c7 44 24 04 46 00 00 	movl   $0x46,0x4(%esp)
  80283d:	00 
  80283e:	c7 04 24 b3 30 80 00 	movl   $0x8030b3,(%esp)
  802845:	e8 d2 d8 ff ff       	call   80011c <_panic>
           sys_yield();
  80284a:	e8 51 eb ff ff       	call   8013a0 <sys_yield>
        }
  80284f:	eb 9c                	jmp    8027ed <ipc_send+0x12>
	//panic("ipc_send not implemented");
}
  802851:	83 c4 1c             	add    $0x1c,%esp
  802854:	5b                   	pop    %ebx
  802855:	5e                   	pop    %esi
  802856:	5f                   	pop    %edi
  802857:	5d                   	pop    %ebp
  802858:	c3                   	ret    

00802859 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802859:	55                   	push   %ebp
  80285a:	89 e5                	mov    %esp,%ebp
  80285c:	56                   	push   %esi
  80285d:	53                   	push   %ebx
  80285e:	83 ec 10             	sub    $0x10,%esp
  802861:	8b 75 08             	mov    0x8(%ebp),%esi
  802864:	8b 45 0c             	mov    0xc(%ebp),%eax
  802867:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        int ret;
        if(!pg)
  80286a:	85 c0                	test   %eax,%eax
  80286c:	75 0e                	jne    80287c <ipc_recv+0x23>
           ret = sys_ipc_recv((void*)UTOP);
  80286e:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  802875:	e8 ef e7 ff ff       	call   801069 <sys_ipc_recv>
  80287a:	eb 08                	jmp    802884 <ipc_recv+0x2b>
        else
           ret = sys_ipc_recv(pg);
  80287c:	89 04 24             	mov    %eax,(%esp)
  80287f:	e8 e5 e7 ff ff       	call   801069 <sys_ipc_recv>
        if(ret == 0){
  802884:	85 c0                	test   %eax,%eax
  802886:	75 26                	jne    8028ae <ipc_recv+0x55>
           if(from_env_store)
  802888:	85 f6                	test   %esi,%esi
  80288a:	74 0a                	je     802896 <ipc_recv+0x3d>
              *from_env_store = thisenv->env_ipc_from;
  80288c:	a1 04 50 80 00       	mov    0x805004,%eax
  802891:	8b 40 78             	mov    0x78(%eax),%eax
  802894:	89 06                	mov    %eax,(%esi)
           if(perm_store)
  802896:	85 db                	test   %ebx,%ebx
  802898:	74 0a                	je     8028a4 <ipc_recv+0x4b>
              *perm_store = thisenv->env_ipc_perm;
  80289a:	a1 04 50 80 00       	mov    0x805004,%eax
  80289f:	8b 40 7c             	mov    0x7c(%eax),%eax
  8028a2:	89 03                	mov    %eax,(%ebx)
           return thisenv->env_ipc_value;
  8028a4:	a1 04 50 80 00       	mov    0x805004,%eax
  8028a9:	8b 40 74             	mov    0x74(%eax),%eax
  8028ac:	eb 14                	jmp    8028c2 <ipc_recv+0x69>
        }
        else{
           if(from_env_store)
  8028ae:	85 f6                	test   %esi,%esi
  8028b0:	74 06                	je     8028b8 <ipc_recv+0x5f>
              *from_env_store = 0;
  8028b2:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
           if(perm_store)
  8028b8:	85 db                	test   %ebx,%ebx
  8028ba:	74 06                	je     8028c2 <ipc_recv+0x69>
              *perm_store = 0;
  8028bc:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
           return ret;
        }
	//panic("ipc_recv not implemented");
	return 0;
}
  8028c2:	83 c4 10             	add    $0x10,%esp
  8028c5:	5b                   	pop    %ebx
  8028c6:	5e                   	pop    %esi
  8028c7:	5d                   	pop    %ebp
  8028c8:	c3                   	ret    
  8028c9:	00 00                	add    %al,(%eax)
  8028cb:	00 00                	add    %al,(%eax)
  8028cd:	00 00                	add    %al,(%eax)
	...

008028d0 <__udivdi3>:
  8028d0:	55                   	push   %ebp
  8028d1:	89 e5                	mov    %esp,%ebp
  8028d3:	57                   	push   %edi
  8028d4:	56                   	push   %esi
  8028d5:	83 ec 10             	sub    $0x10,%esp
  8028d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8028db:	8b 55 08             	mov    0x8(%ebp),%edx
  8028de:	8b 75 10             	mov    0x10(%ebp),%esi
  8028e1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8028e4:	85 c0                	test   %eax,%eax
  8028e6:	89 55 f0             	mov    %edx,-0x10(%ebp)
  8028e9:	75 35                	jne    802920 <__udivdi3+0x50>
  8028eb:	39 fe                	cmp    %edi,%esi
  8028ed:	77 61                	ja     802950 <__udivdi3+0x80>
  8028ef:	85 f6                	test   %esi,%esi
  8028f1:	75 0b                	jne    8028fe <__udivdi3+0x2e>
  8028f3:	b8 01 00 00 00       	mov    $0x1,%eax
  8028f8:	31 d2                	xor    %edx,%edx
  8028fa:	f7 f6                	div    %esi
  8028fc:	89 c6                	mov    %eax,%esi
  8028fe:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  802901:	31 d2                	xor    %edx,%edx
  802903:	89 f8                	mov    %edi,%eax
  802905:	f7 f6                	div    %esi
  802907:	89 c7                	mov    %eax,%edi
  802909:	89 c8                	mov    %ecx,%eax
  80290b:	f7 f6                	div    %esi
  80290d:	89 c1                	mov    %eax,%ecx
  80290f:	89 fa                	mov    %edi,%edx
  802911:	89 c8                	mov    %ecx,%eax
  802913:	83 c4 10             	add    $0x10,%esp
  802916:	5e                   	pop    %esi
  802917:	5f                   	pop    %edi
  802918:	5d                   	pop    %ebp
  802919:	c3                   	ret    
  80291a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802920:	39 f8                	cmp    %edi,%eax
  802922:	77 1c                	ja     802940 <__udivdi3+0x70>
  802924:	0f bd d0             	bsr    %eax,%edx
  802927:	83 f2 1f             	xor    $0x1f,%edx
  80292a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80292d:	75 39                	jne    802968 <__udivdi3+0x98>
  80292f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  802932:	0f 86 a0 00 00 00    	jbe    8029d8 <__udivdi3+0x108>
  802938:	39 f8                	cmp    %edi,%eax
  80293a:	0f 82 98 00 00 00    	jb     8029d8 <__udivdi3+0x108>
  802940:	31 ff                	xor    %edi,%edi
  802942:	31 c9                	xor    %ecx,%ecx
  802944:	89 c8                	mov    %ecx,%eax
  802946:	89 fa                	mov    %edi,%edx
  802948:	83 c4 10             	add    $0x10,%esp
  80294b:	5e                   	pop    %esi
  80294c:	5f                   	pop    %edi
  80294d:	5d                   	pop    %ebp
  80294e:	c3                   	ret    
  80294f:	90                   	nop
  802950:	89 d1                	mov    %edx,%ecx
  802952:	89 fa                	mov    %edi,%edx
  802954:	89 c8                	mov    %ecx,%eax
  802956:	31 ff                	xor    %edi,%edi
  802958:	f7 f6                	div    %esi
  80295a:	89 c1                	mov    %eax,%ecx
  80295c:	89 fa                	mov    %edi,%edx
  80295e:	89 c8                	mov    %ecx,%eax
  802960:	83 c4 10             	add    $0x10,%esp
  802963:	5e                   	pop    %esi
  802964:	5f                   	pop    %edi
  802965:	5d                   	pop    %ebp
  802966:	c3                   	ret    
  802967:	90                   	nop
  802968:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80296c:	89 f2                	mov    %esi,%edx
  80296e:	d3 e0                	shl    %cl,%eax
  802970:	89 45 ec             	mov    %eax,-0x14(%ebp)
  802973:	b8 20 00 00 00       	mov    $0x20,%eax
  802978:	2b 45 f4             	sub    -0xc(%ebp),%eax
  80297b:	89 c1                	mov    %eax,%ecx
  80297d:	d3 ea                	shr    %cl,%edx
  80297f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  802983:	0b 55 ec             	or     -0x14(%ebp),%edx
  802986:	d3 e6                	shl    %cl,%esi
  802988:	89 c1                	mov    %eax,%ecx
  80298a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  80298d:	89 fe                	mov    %edi,%esi
  80298f:	d3 ee                	shr    %cl,%esi
  802991:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  802995:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802998:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80299b:	d3 e7                	shl    %cl,%edi
  80299d:	89 c1                	mov    %eax,%ecx
  80299f:	d3 ea                	shr    %cl,%edx
  8029a1:	09 d7                	or     %edx,%edi
  8029a3:	89 f2                	mov    %esi,%edx
  8029a5:	89 f8                	mov    %edi,%eax
  8029a7:	f7 75 ec             	divl   -0x14(%ebp)
  8029aa:	89 d6                	mov    %edx,%esi
  8029ac:	89 c7                	mov    %eax,%edi
  8029ae:	f7 65 e8             	mull   -0x18(%ebp)
  8029b1:	39 d6                	cmp    %edx,%esi
  8029b3:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8029b6:	72 30                	jb     8029e8 <__udivdi3+0x118>
  8029b8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8029bb:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8029bf:	d3 e2                	shl    %cl,%edx
  8029c1:	39 c2                	cmp    %eax,%edx
  8029c3:	73 05                	jae    8029ca <__udivdi3+0xfa>
  8029c5:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  8029c8:	74 1e                	je     8029e8 <__udivdi3+0x118>
  8029ca:	89 f9                	mov    %edi,%ecx
  8029cc:	31 ff                	xor    %edi,%edi
  8029ce:	e9 71 ff ff ff       	jmp    802944 <__udivdi3+0x74>
  8029d3:	90                   	nop
  8029d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8029d8:	31 ff                	xor    %edi,%edi
  8029da:	b9 01 00 00 00       	mov    $0x1,%ecx
  8029df:	e9 60 ff ff ff       	jmp    802944 <__udivdi3+0x74>
  8029e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8029e8:	8d 4f ff             	lea    -0x1(%edi),%ecx
  8029eb:	31 ff                	xor    %edi,%edi
  8029ed:	89 c8                	mov    %ecx,%eax
  8029ef:	89 fa                	mov    %edi,%edx
  8029f1:	83 c4 10             	add    $0x10,%esp
  8029f4:	5e                   	pop    %esi
  8029f5:	5f                   	pop    %edi
  8029f6:	5d                   	pop    %ebp
  8029f7:	c3                   	ret    
	...

00802a00 <__umoddi3>:
  802a00:	55                   	push   %ebp
  802a01:	89 e5                	mov    %esp,%ebp
  802a03:	57                   	push   %edi
  802a04:	56                   	push   %esi
  802a05:	83 ec 20             	sub    $0x20,%esp
  802a08:	8b 55 14             	mov    0x14(%ebp),%edx
  802a0b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802a0e:	8b 7d 10             	mov    0x10(%ebp),%edi
  802a11:	8b 75 0c             	mov    0xc(%ebp),%esi
  802a14:	85 d2                	test   %edx,%edx
  802a16:	89 c8                	mov    %ecx,%eax
  802a18:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  802a1b:	75 13                	jne    802a30 <__umoddi3+0x30>
  802a1d:	39 f7                	cmp    %esi,%edi
  802a1f:	76 3f                	jbe    802a60 <__umoddi3+0x60>
  802a21:	89 f2                	mov    %esi,%edx
  802a23:	f7 f7                	div    %edi
  802a25:	89 d0                	mov    %edx,%eax
  802a27:	31 d2                	xor    %edx,%edx
  802a29:	83 c4 20             	add    $0x20,%esp
  802a2c:	5e                   	pop    %esi
  802a2d:	5f                   	pop    %edi
  802a2e:	5d                   	pop    %ebp
  802a2f:	c3                   	ret    
  802a30:	39 f2                	cmp    %esi,%edx
  802a32:	77 4c                	ja     802a80 <__umoddi3+0x80>
  802a34:	0f bd ca             	bsr    %edx,%ecx
  802a37:	83 f1 1f             	xor    $0x1f,%ecx
  802a3a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  802a3d:	75 51                	jne    802a90 <__umoddi3+0x90>
  802a3f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  802a42:	0f 87 e0 00 00 00    	ja     802b28 <__umoddi3+0x128>
  802a48:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802a4b:	29 f8                	sub    %edi,%eax
  802a4d:	19 d6                	sbb    %edx,%esi
  802a4f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  802a52:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802a55:	89 f2                	mov    %esi,%edx
  802a57:	83 c4 20             	add    $0x20,%esp
  802a5a:	5e                   	pop    %esi
  802a5b:	5f                   	pop    %edi
  802a5c:	5d                   	pop    %ebp
  802a5d:	c3                   	ret    
  802a5e:	66 90                	xchg   %ax,%ax
  802a60:	85 ff                	test   %edi,%edi
  802a62:	75 0b                	jne    802a6f <__umoddi3+0x6f>
  802a64:	b8 01 00 00 00       	mov    $0x1,%eax
  802a69:	31 d2                	xor    %edx,%edx
  802a6b:	f7 f7                	div    %edi
  802a6d:	89 c7                	mov    %eax,%edi
  802a6f:	89 f0                	mov    %esi,%eax
  802a71:	31 d2                	xor    %edx,%edx
  802a73:	f7 f7                	div    %edi
  802a75:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802a78:	f7 f7                	div    %edi
  802a7a:	eb a9                	jmp    802a25 <__umoddi3+0x25>
  802a7c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802a80:	89 c8                	mov    %ecx,%eax
  802a82:	89 f2                	mov    %esi,%edx
  802a84:	83 c4 20             	add    $0x20,%esp
  802a87:	5e                   	pop    %esi
  802a88:	5f                   	pop    %edi
  802a89:	5d                   	pop    %ebp
  802a8a:	c3                   	ret    
  802a8b:	90                   	nop
  802a8c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802a90:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802a94:	d3 e2                	shl    %cl,%edx
  802a96:	89 55 f4             	mov    %edx,-0xc(%ebp)
  802a99:	ba 20 00 00 00       	mov    $0x20,%edx
  802a9e:	2b 55 f0             	sub    -0x10(%ebp),%edx
  802aa1:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802aa4:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802aa8:	89 fa                	mov    %edi,%edx
  802aaa:	d3 ea                	shr    %cl,%edx
  802aac:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802ab0:	0b 55 f4             	or     -0xc(%ebp),%edx
  802ab3:	d3 e7                	shl    %cl,%edi
  802ab5:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802ab9:	89 55 f4             	mov    %edx,-0xc(%ebp)
  802abc:	89 f2                	mov    %esi,%edx
  802abe:	89 7d e8             	mov    %edi,-0x18(%ebp)
  802ac1:	89 c7                	mov    %eax,%edi
  802ac3:	d3 ea                	shr    %cl,%edx
  802ac5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802ac9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  802acc:	89 c2                	mov    %eax,%edx
  802ace:	d3 e6                	shl    %cl,%esi
  802ad0:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802ad4:	d3 ea                	shr    %cl,%edx
  802ad6:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802ada:	09 d6                	or     %edx,%esi
  802adc:	89 f0                	mov    %esi,%eax
  802ade:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  802ae1:	d3 e7                	shl    %cl,%edi
  802ae3:	89 f2                	mov    %esi,%edx
  802ae5:	f7 75 f4             	divl   -0xc(%ebp)
  802ae8:	89 d6                	mov    %edx,%esi
  802aea:	f7 65 e8             	mull   -0x18(%ebp)
  802aed:	39 d6                	cmp    %edx,%esi
  802aef:	72 2b                	jb     802b1c <__umoddi3+0x11c>
  802af1:	39 c7                	cmp    %eax,%edi
  802af3:	72 23                	jb     802b18 <__umoddi3+0x118>
  802af5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802af9:	29 c7                	sub    %eax,%edi
  802afb:	19 d6                	sbb    %edx,%esi
  802afd:	89 f0                	mov    %esi,%eax
  802aff:	89 f2                	mov    %esi,%edx
  802b01:	d3 ef                	shr    %cl,%edi
  802b03:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802b07:	d3 e0                	shl    %cl,%eax
  802b09:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802b0d:	09 f8                	or     %edi,%eax
  802b0f:	d3 ea                	shr    %cl,%edx
  802b11:	83 c4 20             	add    $0x20,%esp
  802b14:	5e                   	pop    %esi
  802b15:	5f                   	pop    %edi
  802b16:	5d                   	pop    %ebp
  802b17:	c3                   	ret    
  802b18:	39 d6                	cmp    %edx,%esi
  802b1a:	75 d9                	jne    802af5 <__umoddi3+0xf5>
  802b1c:	2b 45 e8             	sub    -0x18(%ebp),%eax
  802b1f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  802b22:	eb d1                	jmp    802af5 <__umoddi3+0xf5>
  802b24:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802b28:	39 f2                	cmp    %esi,%edx
  802b2a:	0f 82 18 ff ff ff    	jb     802a48 <__umoddi3+0x48>
  802b30:	e9 1d ff ff ff       	jmp    802a52 <__umoddi3+0x52>
