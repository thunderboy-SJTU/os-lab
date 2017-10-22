
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
  80003a:	a1 08 50 80 00       	mov    0x805008,%eax
  80003f:	8b 40 48             	mov    0x48(%eax),%eax
  800042:	89 44 24 04          	mov    %eax,0x4(%esp)
  800046:	c7 04 24 a0 31 80 00 	movl   $0x8031a0,(%esp)
  80004d:	e8 83 01 00 00       	call   8001d5 <cprintf>
	if ((r = execl("/init", "init", 0)) < 0)
  800052:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800059:	00 
  80005a:	c7 44 24 04 bf 31 80 	movl   $0x8031bf,0x4(%esp)
  800061:	00 
  800062:	c7 04 24 be 31 80 00 	movl   $0x8031be,(%esp)
  800069:	e8 2f 23 00 00       	call   80239d <execl>
  80006e:	85 c0                	test   %eax,%eax
  800070:	79 20                	jns    800092 <umain+0x5e>
		panic("exec(init) failed: %e", r);
  800072:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800076:	c7 44 24 08 c4 31 80 	movl   $0x8031c4,0x8(%esp)
  80007d:	00 
  80007e:	c7 44 24 04 09 00 00 	movl   $0x9,0x4(%esp)
  800085:	00 
  800086:	c7 04 24 da 31 80 00 	movl   $0x8031da,(%esp)
  80008d:	e8 8a 00 00 00       	call   80011c <_panic>
        cprintf("i am parent environment %08x\n", thisenv->env_id);
  800092:	a1 08 50 80 00       	mov    0x805008,%eax
  800097:	8b 40 48             	mov    0x48(%eax),%eax
  80009a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80009e:	c7 04 24 a0 31 80 00 	movl   $0x8031a0,(%esp)
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
  8000be:	e8 64 14 00 00       	call   801527 <sys_getenvid>
  8000c3:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000c8:	89 c2                	mov    %eax,%edx
  8000ca:	c1 e2 07             	shl    $0x7,%edx
  8000cd:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  8000d4:	a3 08 50 80 00       	mov    %eax,0x805008
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
  800106:	e8 b0 19 00 00       	call   801abb <close_all>
	sys_env_destroy(0);
  80010b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800112:	e8 50 14 00 00       	call   801567 <sys_env_destroy>
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
  80012d:	e8 f5 13 00 00       	call   801527 <sys_getenvid>
  800132:	8b 55 0c             	mov    0xc(%ebp),%edx
  800135:	89 54 24 10          	mov    %edx,0x10(%esp)
  800139:	8b 55 08             	mov    0x8(%ebp),%edx
  80013c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800140:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800144:	89 44 24 04          	mov    %eax,0x4(%esp)
  800148:	c7 04 24 f0 31 80 00 	movl   $0x8031f0,(%esp)
  80014f:	e8 81 00 00 00       	call   8001d5 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800154:	89 74 24 04          	mov    %esi,0x4(%esp)
  800158:	8b 45 10             	mov    0x10(%ebp),%eax
  80015b:	89 04 24             	mov    %eax,(%esp)
  80015e:	e8 11 00 00 00       	call   800174 <vcprintf>
	cprintf("\n");
  800163:	c7 04 24 44 36 80 00 	movl   $0x803644,(%esp)
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
  8002af:	e8 7c 2c 00 00       	call   802f30 <__udivdi3>
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
  800317:	e8 44 2d 00 00       	call   803060 <__umoddi3>
  80031c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800320:	0f be 80 13 32 80 00 	movsbl 0x803213(%eax),%eax
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
  80040a:	ff 24 95 00 34 80 00 	jmp    *0x803400(,%edx,4)
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
  8004c7:	8b 14 85 60 35 80 00 	mov    0x803560(,%eax,4),%edx
  8004ce:	85 d2                	test   %edx,%edx
  8004d0:	75 26                	jne    8004f8 <vprintfmt+0x16c>
				printfmt(putch, putdat, "error %d", err);
  8004d2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004d6:	c7 44 24 08 24 32 80 	movl   $0x803224,0x8(%esp)
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
  8004fc:	c7 44 24 08 a9 36 80 	movl   $0x8036a9,0x8(%esp)
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
  80053a:	be 2d 32 80 00       	mov    $0x80322d,%esi
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
  8007e4:	e8 47 27 00 00       	call   802f30 <__udivdi3>
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
  800830:	e8 2b 28 00 00       	call   803060 <__umoddi3>
  800835:	89 74 24 04          	mov    %esi,0x4(%esp)
  800839:	0f be 80 13 32 80 00 	movsbl 0x803213(%eax),%eax
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
  8008e5:	c7 44 24 0c 48 33 80 	movl   $0x803348,0xc(%esp)
  8008ec:	00 
  8008ed:	c7 44 24 08 a9 36 80 	movl   $0x8036a9,0x8(%esp)
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
  80091b:	c7 44 24 0c 80 33 80 	movl   $0x803380,0xc(%esp)
  800922:	00 
  800923:	c7 44 24 08 a9 36 80 	movl   $0x8036a9,0x8(%esp)
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
  8009af:	e8 ac 26 00 00       	call   803060 <__umoddi3>
  8009b4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8009b8:	0f be 80 13 32 80 00 	movsbl 0x803213(%eax),%eax
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
  8009f1:	e8 6a 26 00 00       	call   803060 <__umoddi3>
  8009f6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8009fa:	0f be 80 13 32 80 00 	movsbl 0x803213(%eax),%eax
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

00800f7b <sys_get_mac>:
sys_receive_packet(uint32_t addr,int* len){
         return syscall(SYS_receive_packet,0,(uint32_t)addr,(uint32_t)len,0,0,0);
}

int 
sys_get_mac(uint8_t* macaddr){
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
  800f88:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f8d:	b8 13 00 00 00       	mov    $0x13,%eax
  800f92:	8b 55 08             	mov    0x8(%ebp),%edx
  800f95:	89 cb                	mov    %ecx,%ebx
  800f97:	89 cf                	mov    %ecx,%edi
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
sys_get_mac(uint8_t* macaddr){
         return syscall(SYS_get_mac,0,(uint32_t)macaddr,0,0,0,0);
}
  800fb1:	8b 1c 24             	mov    (%esp),%ebx
  800fb4:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800fb8:	89 ec                	mov    %ebp,%esp
  800fba:	5d                   	pop    %ebp
  800fbb:	c3                   	ret    

00800fbc <sys_receive_packet>:
sys_transmit_packet(uint32_t addr,int len){
         return syscall(SYS_transmit_packet,0,(uint32_t)addr,(uint32_t)len,0,0,0);
}

int 
sys_receive_packet(uint32_t addr,int* len){
  800fbc:	55                   	push   %ebp
  800fbd:	89 e5                	mov    %esp,%ebp
  800fbf:	83 ec 08             	sub    $0x8,%esp
  800fc2:	89 1c 24             	mov    %ebx,(%esp)
  800fc5:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800fc9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fce:	b8 12 00 00 00       	mov    $0x12,%eax
  800fd3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fd6:	8b 55 08             	mov    0x8(%ebp),%edx
  800fd9:	89 df                	mov    %ebx,%edi
  800fdb:	51                   	push   %ecx
  800fdc:	52                   	push   %edx
  800fdd:	53                   	push   %ebx
  800fde:	54                   	push   %esp
  800fdf:	55                   	push   %ebp
  800fe0:	56                   	push   %esi
  800fe1:	57                   	push   %edi
  800fe2:	54                   	push   %esp
  800fe3:	5d                   	pop    %ebp
  800fe4:	8d 35 ec 0f 80 00    	lea    0x800fec,%esi
  800fea:	0f 34                	sysenter 
  800fec:	5f                   	pop    %edi
  800fed:	5e                   	pop    %esi
  800fee:	5d                   	pop    %ebp
  800fef:	5c                   	pop    %esp
  800ff0:	5b                   	pop    %ebx
  800ff1:	5a                   	pop    %edx
  800ff2:	59                   	pop    %ecx
}

int 
sys_receive_packet(uint32_t addr,int* len){
         return syscall(SYS_receive_packet,0,(uint32_t)addr,(uint32_t)len,0,0,0);
}
  800ff3:	8b 1c 24             	mov    (%esp),%ebx
  800ff6:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800ffa:	89 ec                	mov    %ebp,%esp
  800ffc:	5d                   	pop    %ebp
  800ffd:	c3                   	ret    

00800ffe <sys_transmit_packet>:
sys_exec(void* vph, uint32_t phnum, uint32_t esp, uint32_t eip){
         return syscall(SYS_exec, 0, (uint32_t)vph, phnum, esp, eip, 0);
}

int 
sys_transmit_packet(uint32_t addr,int len){
  800ffe:	55                   	push   %ebp
  800fff:	89 e5                	mov    %esp,%ebp
  801001:	83 ec 08             	sub    $0x8,%esp
  801004:	89 1c 24             	mov    %ebx,(%esp)
  801007:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80100b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801010:	b8 11 00 00 00       	mov    $0x11,%eax
  801015:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801018:	8b 55 08             	mov    0x8(%ebp),%edx
  80101b:	89 df                	mov    %ebx,%edi
  80101d:	51                   	push   %ecx
  80101e:	52                   	push   %edx
  80101f:	53                   	push   %ebx
  801020:	54                   	push   %esp
  801021:	55                   	push   %ebp
  801022:	56                   	push   %esi
  801023:	57                   	push   %edi
  801024:	54                   	push   %esp
  801025:	5d                   	pop    %ebp
  801026:	8d 35 2e 10 80 00    	lea    0x80102e,%esi
  80102c:	0f 34                	sysenter 
  80102e:	5f                   	pop    %edi
  80102f:	5e                   	pop    %esi
  801030:	5d                   	pop    %ebp
  801031:	5c                   	pop    %esp
  801032:	5b                   	pop    %ebx
  801033:	5a                   	pop    %edx
  801034:	59                   	pop    %ecx
}

int 
sys_transmit_packet(uint32_t addr,int len){
         return syscall(SYS_transmit_packet,0,(uint32_t)addr,(uint32_t)len,0,0,0);
}
  801035:	8b 1c 24             	mov    (%esp),%ebx
  801038:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80103c:	89 ec                	mov    %ebp,%esp
  80103e:	5d                   	pop    %ebp
  80103f:	c3                   	ret    

00801040 <sys_exec>:
sys_env_set_prior(envid_t envid, uint32_t prior){
         return syscall(SYS_env_set_prior,1,envid, prior, 0, 0, 0);
}

int 
sys_exec(void* vph, uint32_t phnum, uint32_t esp, uint32_t eip){
  801040:	55                   	push   %ebp
  801041:	89 e5                	mov    %esp,%ebp
  801043:	83 ec 08             	sub    $0x8,%esp
  801046:	89 1c 24             	mov    %ebx,(%esp)
  801049:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80104d:	b8 10 00 00 00       	mov    $0x10,%eax
  801052:	8b 7d 14             	mov    0x14(%ebp),%edi
  801055:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801058:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80105b:	8b 55 08             	mov    0x8(%ebp),%edx
  80105e:	51                   	push   %ecx
  80105f:	52                   	push   %edx
  801060:	53                   	push   %ebx
  801061:	54                   	push   %esp
  801062:	55                   	push   %ebp
  801063:	56                   	push   %esi
  801064:	57                   	push   %edi
  801065:	54                   	push   %esp
  801066:	5d                   	pop    %ebp
  801067:	8d 35 6f 10 80 00    	lea    0x80106f,%esi
  80106d:	0f 34                	sysenter 
  80106f:	5f                   	pop    %edi
  801070:	5e                   	pop    %esi
  801071:	5d                   	pop    %ebp
  801072:	5c                   	pop    %esp
  801073:	5b                   	pop    %ebx
  801074:	5a                   	pop    %edx
  801075:	59                   	pop    %ecx
}

int 
sys_exec(void* vph, uint32_t phnum, uint32_t esp, uint32_t eip){
         return syscall(SYS_exec, 0, (uint32_t)vph, phnum, esp, eip, 0);
}
  801076:	8b 1c 24             	mov    (%esp),%ebx
  801079:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80107d:	89 ec                	mov    %ebp,%esp
  80107f:	5d                   	pop    %ebp
  801080:	c3                   	ret    

00801081 <sys_env_set_prior>:
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}


int 
sys_env_set_prior(envid_t envid, uint32_t prior){
  801081:	55                   	push   %ebp
  801082:	89 e5                	mov    %esp,%ebp
  801084:	83 ec 28             	sub    $0x28,%esp
  801087:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80108a:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80108d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801092:	b8 0f 00 00 00       	mov    $0xf,%eax
  801097:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80109a:	8b 55 08             	mov    0x8(%ebp),%edx
  80109d:	89 df                	mov    %ebx,%edi
  80109f:	51                   	push   %ecx
  8010a0:	52                   	push   %edx
  8010a1:	53                   	push   %ebx
  8010a2:	54                   	push   %esp
  8010a3:	55                   	push   %ebp
  8010a4:	56                   	push   %esi
  8010a5:	57                   	push   %edi
  8010a6:	54                   	push   %esp
  8010a7:	5d                   	pop    %ebp
  8010a8:	8d 35 b0 10 80 00    	lea    0x8010b0,%esi
  8010ae:	0f 34                	sysenter 
  8010b0:	5f                   	pop    %edi
  8010b1:	5e                   	pop    %esi
  8010b2:	5d                   	pop    %ebp
  8010b3:	5c                   	pop    %esp
  8010b4:	5b                   	pop    %ebx
  8010b5:	5a                   	pop    %edx
  8010b6:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8010b7:	85 c0                	test   %eax,%eax
  8010b9:	7e 28                	jle    8010e3 <sys_env_set_prior+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010bb:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010bf:	c7 44 24 0c 0f 00 00 	movl   $0xf,0xc(%esp)
  8010c6:	00 
  8010c7:	c7 44 24 08 a0 35 80 	movl   $0x8035a0,0x8(%esp)
  8010ce:	00 
  8010cf:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8010d6:	00 
  8010d7:	c7 04 24 bd 35 80 00 	movl   $0x8035bd,(%esp)
  8010de:	e8 39 f0 ff ff       	call   80011c <_panic>


int 
sys_env_set_prior(envid_t envid, uint32_t prior){
         return syscall(SYS_env_set_prior,1,envid, prior, 0, 0, 0);
}
  8010e3:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8010e6:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8010e9:	89 ec                	mov    %ebp,%esp
  8010eb:	5d                   	pop    %ebp
  8010ec:	c3                   	ret    

008010ed <sys_time_msec>:
}


unsigned int
sys_time_msec(void)
{
  8010ed:	55                   	push   %ebp
  8010ee:	89 e5                	mov    %esp,%ebp
  8010f0:	83 ec 08             	sub    $0x8,%esp
  8010f3:	89 1c 24             	mov    %ebx,(%esp)
  8010f6:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8010fa:	ba 00 00 00 00       	mov    $0x0,%edx
  8010ff:	b8 15 00 00 00       	mov    $0x15,%eax
  801104:	89 d1                	mov    %edx,%ecx
  801106:	89 d3                	mov    %edx,%ebx
  801108:	89 d7                	mov    %edx,%edi
  80110a:	51                   	push   %ecx
  80110b:	52                   	push   %edx
  80110c:	53                   	push   %ebx
  80110d:	54                   	push   %esp
  80110e:	55                   	push   %ebp
  80110f:	56                   	push   %esi
  801110:	57                   	push   %edi
  801111:	54                   	push   %esp
  801112:	5d                   	pop    %ebp
  801113:	8d 35 1b 11 80 00    	lea    0x80111b,%esi
  801119:	0f 34                	sysenter 
  80111b:	5f                   	pop    %edi
  80111c:	5e                   	pop    %esi
  80111d:	5d                   	pop    %ebp
  80111e:	5c                   	pop    %esp
  80111f:	5b                   	pop    %ebx
  801120:	5a                   	pop    %edx
  801121:	59                   	pop    %ecx

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  801122:	8b 1c 24             	mov    (%esp),%ebx
  801125:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801129:	89 ec                	mov    %ebp,%esp
  80112b:	5d                   	pop    %ebp
  80112c:	c3                   	ret    

0080112d <sys_sbrk>:
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}

int
sys_sbrk(uint32_t inc)
{
  80112d:	55                   	push   %ebp
  80112e:	89 e5                	mov    %esp,%ebp
  801130:	83 ec 08             	sub    $0x8,%esp
  801133:	89 1c 24             	mov    %ebx,(%esp)
  801136:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80113a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80113f:	b8 14 00 00 00       	mov    $0x14,%eax
  801144:	8b 55 08             	mov    0x8(%ebp),%edx
  801147:	89 cb                	mov    %ecx,%ebx
  801149:	89 cf                	mov    %ecx,%edi
  80114b:	51                   	push   %ecx
  80114c:	52                   	push   %edx
  80114d:	53                   	push   %ebx
  80114e:	54                   	push   %esp
  80114f:	55                   	push   %ebp
  801150:	56                   	push   %esi
  801151:	57                   	push   %edi
  801152:	54                   	push   %esp
  801153:	5d                   	pop    %ebp
  801154:	8d 35 5c 11 80 00    	lea    0x80115c,%esi
  80115a:	0f 34                	sysenter 
  80115c:	5f                   	pop    %edi
  80115d:	5e                   	pop    %esi
  80115e:	5d                   	pop    %ebp
  80115f:	5c                   	pop    %esp
  801160:	5b                   	pop    %ebx
  801161:	5a                   	pop    %edx
  801162:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  801163:	8b 1c 24             	mov    (%esp),%ebx
  801166:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80116a:	89 ec                	mov    %ebp,%esp
  80116c:	5d                   	pop    %ebp
  80116d:	c3                   	ret    

0080116e <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  80116e:	55                   	push   %ebp
  80116f:	89 e5                	mov    %esp,%ebp
  801171:	83 ec 28             	sub    $0x28,%esp
  801174:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801177:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80117a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80117f:	b8 0e 00 00 00       	mov    $0xe,%eax
  801184:	8b 55 08             	mov    0x8(%ebp),%edx
  801187:	89 cb                	mov    %ecx,%ebx
  801189:	89 cf                	mov    %ecx,%edi
  80118b:	51                   	push   %ecx
  80118c:	52                   	push   %edx
  80118d:	53                   	push   %ebx
  80118e:	54                   	push   %esp
  80118f:	55                   	push   %ebp
  801190:	56                   	push   %esi
  801191:	57                   	push   %edi
  801192:	54                   	push   %esp
  801193:	5d                   	pop    %ebp
  801194:	8d 35 9c 11 80 00    	lea    0x80119c,%esi
  80119a:	0f 34                	sysenter 
  80119c:	5f                   	pop    %edi
  80119d:	5e                   	pop    %esi
  80119e:	5d                   	pop    %ebp
  80119f:	5c                   	pop    %esp
  8011a0:	5b                   	pop    %ebx
  8011a1:	5a                   	pop    %edx
  8011a2:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8011a3:	85 c0                	test   %eax,%eax
  8011a5:	7e 28                	jle    8011cf <sys_ipc_recv+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011a7:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011ab:	c7 44 24 0c 0e 00 00 	movl   $0xe,0xc(%esp)
  8011b2:	00 
  8011b3:	c7 44 24 08 a0 35 80 	movl   $0x8035a0,0x8(%esp)
  8011ba:	00 
  8011bb:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8011c2:	00 
  8011c3:	c7 04 24 bd 35 80 00 	movl   $0x8035bd,(%esp)
  8011ca:	e8 4d ef ff ff       	call   80011c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8011cf:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8011d2:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8011d5:	89 ec                	mov    %ebp,%esp
  8011d7:	5d                   	pop    %ebp
  8011d8:	c3                   	ret    

008011d9 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8011d9:	55                   	push   %ebp
  8011da:	89 e5                	mov    %esp,%ebp
  8011dc:	83 ec 08             	sub    $0x8,%esp
  8011df:	89 1c 24             	mov    %ebx,(%esp)
  8011e2:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8011e6:	b8 0d 00 00 00       	mov    $0xd,%eax
  8011eb:	8b 7d 14             	mov    0x14(%ebp),%edi
  8011ee:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8011f1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011f4:	8b 55 08             	mov    0x8(%ebp),%edx
  8011f7:	51                   	push   %ecx
  8011f8:	52                   	push   %edx
  8011f9:	53                   	push   %ebx
  8011fa:	54                   	push   %esp
  8011fb:	55                   	push   %ebp
  8011fc:	56                   	push   %esi
  8011fd:	57                   	push   %edi
  8011fe:	54                   	push   %esp
  8011ff:	5d                   	pop    %ebp
  801200:	8d 35 08 12 80 00    	lea    0x801208,%esi
  801206:	0f 34                	sysenter 
  801208:	5f                   	pop    %edi
  801209:	5e                   	pop    %esi
  80120a:	5d                   	pop    %ebp
  80120b:	5c                   	pop    %esp
  80120c:	5b                   	pop    %ebx
  80120d:	5a                   	pop    %edx
  80120e:	59                   	pop    %ecx

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80120f:	8b 1c 24             	mov    (%esp),%ebx
  801212:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801216:	89 ec                	mov    %ebp,%esp
  801218:	5d                   	pop    %ebp
  801219:	c3                   	ret    

0080121a <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80121a:	55                   	push   %ebp
  80121b:	89 e5                	mov    %esp,%ebp
  80121d:	83 ec 28             	sub    $0x28,%esp
  801220:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801223:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801226:	bb 00 00 00 00       	mov    $0x0,%ebx
  80122b:	b8 0b 00 00 00       	mov    $0xb,%eax
  801230:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801233:	8b 55 08             	mov    0x8(%ebp),%edx
  801236:	89 df                	mov    %ebx,%edi
  801238:	51                   	push   %ecx
  801239:	52                   	push   %edx
  80123a:	53                   	push   %ebx
  80123b:	54                   	push   %esp
  80123c:	55                   	push   %ebp
  80123d:	56                   	push   %esi
  80123e:	57                   	push   %edi
  80123f:	54                   	push   %esp
  801240:	5d                   	pop    %ebp
  801241:	8d 35 49 12 80 00    	lea    0x801249,%esi
  801247:	0f 34                	sysenter 
  801249:	5f                   	pop    %edi
  80124a:	5e                   	pop    %esi
  80124b:	5d                   	pop    %ebp
  80124c:	5c                   	pop    %esp
  80124d:	5b                   	pop    %ebx
  80124e:	5a                   	pop    %edx
  80124f:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801250:	85 c0                	test   %eax,%eax
  801252:	7e 28                	jle    80127c <sys_env_set_pgfault_upcall+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  801254:	89 44 24 10          	mov    %eax,0x10(%esp)
  801258:	c7 44 24 0c 0b 00 00 	movl   $0xb,0xc(%esp)
  80125f:	00 
  801260:	c7 44 24 08 a0 35 80 	movl   $0x8035a0,0x8(%esp)
  801267:	00 
  801268:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80126f:	00 
  801270:	c7 04 24 bd 35 80 00 	movl   $0x8035bd,(%esp)
  801277:	e8 a0 ee ff ff       	call   80011c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80127c:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80127f:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801282:	89 ec                	mov    %ebp,%esp
  801284:	5d                   	pop    %ebp
  801285:	c3                   	ret    

00801286 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801286:	55                   	push   %ebp
  801287:	89 e5                	mov    %esp,%ebp
  801289:	83 ec 28             	sub    $0x28,%esp
  80128c:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80128f:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801292:	bb 00 00 00 00       	mov    $0x0,%ebx
  801297:	b8 0a 00 00 00       	mov    $0xa,%eax
  80129c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80129f:	8b 55 08             	mov    0x8(%ebp),%edx
  8012a2:	89 df                	mov    %ebx,%edi
  8012a4:	51                   	push   %ecx
  8012a5:	52                   	push   %edx
  8012a6:	53                   	push   %ebx
  8012a7:	54                   	push   %esp
  8012a8:	55                   	push   %ebp
  8012a9:	56                   	push   %esi
  8012aa:	57                   	push   %edi
  8012ab:	54                   	push   %esp
  8012ac:	5d                   	pop    %ebp
  8012ad:	8d 35 b5 12 80 00    	lea    0x8012b5,%esi
  8012b3:	0f 34                	sysenter 
  8012b5:	5f                   	pop    %edi
  8012b6:	5e                   	pop    %esi
  8012b7:	5d                   	pop    %ebp
  8012b8:	5c                   	pop    %esp
  8012b9:	5b                   	pop    %ebx
  8012ba:	5a                   	pop    %edx
  8012bb:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8012bc:	85 c0                	test   %eax,%eax
  8012be:	7e 28                	jle    8012e8 <sys_env_set_trapframe+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012c0:	89 44 24 10          	mov    %eax,0x10(%esp)
  8012c4:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  8012cb:	00 
  8012cc:	c7 44 24 08 a0 35 80 	movl   $0x8035a0,0x8(%esp)
  8012d3:	00 
  8012d4:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8012db:	00 
  8012dc:	c7 04 24 bd 35 80 00 	movl   $0x8035bd,(%esp)
  8012e3:	e8 34 ee ff ff       	call   80011c <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8012e8:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8012eb:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8012ee:	89 ec                	mov    %ebp,%esp
  8012f0:	5d                   	pop    %ebp
  8012f1:	c3                   	ret    

008012f2 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8012f2:	55                   	push   %ebp
  8012f3:	89 e5                	mov    %esp,%ebp
  8012f5:	83 ec 28             	sub    $0x28,%esp
  8012f8:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8012fb:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8012fe:	bb 00 00 00 00       	mov    $0x0,%ebx
  801303:	b8 09 00 00 00       	mov    $0x9,%eax
  801308:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80130b:	8b 55 08             	mov    0x8(%ebp),%edx
  80130e:	89 df                	mov    %ebx,%edi
  801310:	51                   	push   %ecx
  801311:	52                   	push   %edx
  801312:	53                   	push   %ebx
  801313:	54                   	push   %esp
  801314:	55                   	push   %ebp
  801315:	56                   	push   %esi
  801316:	57                   	push   %edi
  801317:	54                   	push   %esp
  801318:	5d                   	pop    %ebp
  801319:	8d 35 21 13 80 00    	lea    0x801321,%esi
  80131f:	0f 34                	sysenter 
  801321:	5f                   	pop    %edi
  801322:	5e                   	pop    %esi
  801323:	5d                   	pop    %ebp
  801324:	5c                   	pop    %esp
  801325:	5b                   	pop    %ebx
  801326:	5a                   	pop    %edx
  801327:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801328:	85 c0                	test   %eax,%eax
  80132a:	7e 28                	jle    801354 <sys_env_set_status+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  80132c:	89 44 24 10          	mov    %eax,0x10(%esp)
  801330:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  801337:	00 
  801338:	c7 44 24 08 a0 35 80 	movl   $0x8035a0,0x8(%esp)
  80133f:	00 
  801340:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801347:	00 
  801348:	c7 04 24 bd 35 80 00 	movl   $0x8035bd,(%esp)
  80134f:	e8 c8 ed ff ff       	call   80011c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801354:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801357:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80135a:	89 ec                	mov    %ebp,%esp
  80135c:	5d                   	pop    %ebp
  80135d:	c3                   	ret    

0080135e <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  80135e:	55                   	push   %ebp
  80135f:	89 e5                	mov    %esp,%ebp
  801361:	83 ec 28             	sub    $0x28,%esp
  801364:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801367:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80136a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80136f:	b8 07 00 00 00       	mov    $0x7,%eax
  801374:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801377:	8b 55 08             	mov    0x8(%ebp),%edx
  80137a:	89 df                	mov    %ebx,%edi
  80137c:	51                   	push   %ecx
  80137d:	52                   	push   %edx
  80137e:	53                   	push   %ebx
  80137f:	54                   	push   %esp
  801380:	55                   	push   %ebp
  801381:	56                   	push   %esi
  801382:	57                   	push   %edi
  801383:	54                   	push   %esp
  801384:	5d                   	pop    %ebp
  801385:	8d 35 8d 13 80 00    	lea    0x80138d,%esi
  80138b:	0f 34                	sysenter 
  80138d:	5f                   	pop    %edi
  80138e:	5e                   	pop    %esi
  80138f:	5d                   	pop    %ebp
  801390:	5c                   	pop    %esp
  801391:	5b                   	pop    %ebx
  801392:	5a                   	pop    %edx
  801393:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801394:	85 c0                	test   %eax,%eax
  801396:	7e 28                	jle    8013c0 <sys_page_unmap+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  801398:	89 44 24 10          	mov    %eax,0x10(%esp)
  80139c:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8013a3:	00 
  8013a4:	c7 44 24 08 a0 35 80 	movl   $0x8035a0,0x8(%esp)
  8013ab:	00 
  8013ac:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8013b3:	00 
  8013b4:	c7 04 24 bd 35 80 00 	movl   $0x8035bd,(%esp)
  8013bb:	e8 5c ed ff ff       	call   80011c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8013c0:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8013c3:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8013c6:	89 ec                	mov    %ebp,%esp
  8013c8:	5d                   	pop    %ebp
  8013c9:	c3                   	ret    

008013ca <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8013ca:	55                   	push   %ebp
  8013cb:	89 e5                	mov    %esp,%ebp
  8013cd:	83 ec 28             	sub    $0x28,%esp
  8013d0:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8013d3:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8013d6:	8b 7d 18             	mov    0x18(%ebp),%edi
  8013d9:	0b 7d 14             	or     0x14(%ebp),%edi
  8013dc:	b8 06 00 00 00       	mov    $0x6,%eax
  8013e1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8013e4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013e7:	8b 55 08             	mov    0x8(%ebp),%edx
  8013ea:	51                   	push   %ecx
  8013eb:	52                   	push   %edx
  8013ec:	53                   	push   %ebx
  8013ed:	54                   	push   %esp
  8013ee:	55                   	push   %ebp
  8013ef:	56                   	push   %esi
  8013f0:	57                   	push   %edi
  8013f1:	54                   	push   %esp
  8013f2:	5d                   	pop    %ebp
  8013f3:	8d 35 fb 13 80 00    	lea    0x8013fb,%esi
  8013f9:	0f 34                	sysenter 
  8013fb:	5f                   	pop    %edi
  8013fc:	5e                   	pop    %esi
  8013fd:	5d                   	pop    %ebp
  8013fe:	5c                   	pop    %esp
  8013ff:	5b                   	pop    %ebx
  801400:	5a                   	pop    %edx
  801401:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801402:	85 c0                	test   %eax,%eax
  801404:	7e 28                	jle    80142e <sys_page_map+0x64>
		panic("syscall %d returned %d (> 0)", num, ret);
  801406:	89 44 24 10          	mov    %eax,0x10(%esp)
  80140a:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  801411:	00 
  801412:	c7 44 24 08 a0 35 80 	movl   $0x8035a0,0x8(%esp)
  801419:	00 
  80141a:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801421:	00 
  801422:	c7 04 24 bd 35 80 00 	movl   $0x8035bd,(%esp)
  801429:	e8 ee ec ff ff       	call   80011c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}
  80142e:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801431:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801434:	89 ec                	mov    %ebp,%esp
  801436:	5d                   	pop    %ebp
  801437:	c3                   	ret    

00801438 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801438:	55                   	push   %ebp
  801439:	89 e5                	mov    %esp,%ebp
  80143b:	83 ec 28             	sub    $0x28,%esp
  80143e:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801441:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801444:	bf 00 00 00 00       	mov    $0x0,%edi
  801449:	b8 05 00 00 00       	mov    $0x5,%eax
  80144e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801451:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801454:	8b 55 08             	mov    0x8(%ebp),%edx
  801457:	51                   	push   %ecx
  801458:	52                   	push   %edx
  801459:	53                   	push   %ebx
  80145a:	54                   	push   %esp
  80145b:	55                   	push   %ebp
  80145c:	56                   	push   %esi
  80145d:	57                   	push   %edi
  80145e:	54                   	push   %esp
  80145f:	5d                   	pop    %ebp
  801460:	8d 35 68 14 80 00    	lea    0x801468,%esi
  801466:	0f 34                	sysenter 
  801468:	5f                   	pop    %edi
  801469:	5e                   	pop    %esi
  80146a:	5d                   	pop    %ebp
  80146b:	5c                   	pop    %esp
  80146c:	5b                   	pop    %ebx
  80146d:	5a                   	pop    %edx
  80146e:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80146f:	85 c0                	test   %eax,%eax
  801471:	7e 28                	jle    80149b <sys_page_alloc+0x63>
		panic("syscall %d returned %d (> 0)", num, ret);
  801473:	89 44 24 10          	mov    %eax,0x10(%esp)
  801477:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  80147e:	00 
  80147f:	c7 44 24 08 a0 35 80 	movl   $0x8035a0,0x8(%esp)
  801486:	00 
  801487:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80148e:	00 
  80148f:	c7 04 24 bd 35 80 00 	movl   $0x8035bd,(%esp)
  801496:	e8 81 ec ff ff       	call   80011c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80149b:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80149e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8014a1:	89 ec                	mov    %ebp,%esp
  8014a3:	5d                   	pop    %ebp
  8014a4:	c3                   	ret    

008014a5 <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
{
  8014a5:	55                   	push   %ebp
  8014a6:	89 e5                	mov    %esp,%ebp
  8014a8:	83 ec 08             	sub    $0x8,%esp
  8014ab:	89 1c 24             	mov    %ebx,(%esp)
  8014ae:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8014b2:	ba 00 00 00 00       	mov    $0x0,%edx
  8014b7:	b8 0c 00 00 00       	mov    $0xc,%eax
  8014bc:	89 d1                	mov    %edx,%ecx
  8014be:	89 d3                	mov    %edx,%ebx
  8014c0:	89 d7                	mov    %edx,%edi
  8014c2:	51                   	push   %ecx
  8014c3:	52                   	push   %edx
  8014c4:	53                   	push   %ebx
  8014c5:	54                   	push   %esp
  8014c6:	55                   	push   %ebp
  8014c7:	56                   	push   %esi
  8014c8:	57                   	push   %edi
  8014c9:	54                   	push   %esp
  8014ca:	5d                   	pop    %ebp
  8014cb:	8d 35 d3 14 80 00    	lea    0x8014d3,%esi
  8014d1:	0f 34                	sysenter 
  8014d3:	5f                   	pop    %edi
  8014d4:	5e                   	pop    %esi
  8014d5:	5d                   	pop    %ebp
  8014d6:	5c                   	pop    %esp
  8014d7:	5b                   	pop    %ebx
  8014d8:	5a                   	pop    %edx
  8014d9:	59                   	pop    %ecx

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8014da:	8b 1c 24             	mov    (%esp),%ebx
  8014dd:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8014e1:	89 ec                	mov    %ebp,%esp
  8014e3:	5d                   	pop    %ebp
  8014e4:	c3                   	ret    

008014e5 <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
{
  8014e5:	55                   	push   %ebp
  8014e6:	89 e5                	mov    %esp,%ebp
  8014e8:	83 ec 08             	sub    $0x8,%esp
  8014eb:	89 1c 24             	mov    %ebx,(%esp)
  8014ee:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8014f2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014f7:	b8 04 00 00 00       	mov    $0x4,%eax
  8014fc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014ff:	8b 55 08             	mov    0x8(%ebp),%edx
  801502:	89 df                	mov    %ebx,%edi
  801504:	51                   	push   %ecx
  801505:	52                   	push   %edx
  801506:	53                   	push   %ebx
  801507:	54                   	push   %esp
  801508:	55                   	push   %ebp
  801509:	56                   	push   %esi
  80150a:	57                   	push   %edi
  80150b:	54                   	push   %esp
  80150c:	5d                   	pop    %ebp
  80150d:	8d 35 15 15 80 00    	lea    0x801515,%esi
  801513:	0f 34                	sysenter 
  801515:	5f                   	pop    %edi
  801516:	5e                   	pop    %esi
  801517:	5d                   	pop    %ebp
  801518:	5c                   	pop    %esp
  801519:	5b                   	pop    %ebx
  80151a:	5a                   	pop    %edx
  80151b:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  80151c:	8b 1c 24             	mov    (%esp),%ebx
  80151f:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801523:	89 ec                	mov    %ebp,%esp
  801525:	5d                   	pop    %ebp
  801526:	c3                   	ret    

00801527 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  801527:	55                   	push   %ebp
  801528:	89 e5                	mov    %esp,%ebp
  80152a:	83 ec 08             	sub    $0x8,%esp
  80152d:	89 1c 24             	mov    %ebx,(%esp)
  801530:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801534:	ba 00 00 00 00       	mov    $0x0,%edx
  801539:	b8 02 00 00 00       	mov    $0x2,%eax
  80153e:	89 d1                	mov    %edx,%ecx
  801540:	89 d3                	mov    %edx,%ebx
  801542:	89 d7                	mov    %edx,%edi
  801544:	51                   	push   %ecx
  801545:	52                   	push   %edx
  801546:	53                   	push   %ebx
  801547:	54                   	push   %esp
  801548:	55                   	push   %ebp
  801549:	56                   	push   %esi
  80154a:	57                   	push   %edi
  80154b:	54                   	push   %esp
  80154c:	5d                   	pop    %ebp
  80154d:	8d 35 55 15 80 00    	lea    0x801555,%esi
  801553:	0f 34                	sysenter 
  801555:	5f                   	pop    %edi
  801556:	5e                   	pop    %esi
  801557:	5d                   	pop    %ebp
  801558:	5c                   	pop    %esp
  801559:	5b                   	pop    %ebx
  80155a:	5a                   	pop    %edx
  80155b:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80155c:	8b 1c 24             	mov    (%esp),%ebx
  80155f:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801563:	89 ec                	mov    %ebp,%esp
  801565:	5d                   	pop    %ebp
  801566:	c3                   	ret    

00801567 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  801567:	55                   	push   %ebp
  801568:	89 e5                	mov    %esp,%ebp
  80156a:	83 ec 28             	sub    $0x28,%esp
  80156d:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801570:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801573:	b9 00 00 00 00       	mov    $0x0,%ecx
  801578:	b8 03 00 00 00       	mov    $0x3,%eax
  80157d:	8b 55 08             	mov    0x8(%ebp),%edx
  801580:	89 cb                	mov    %ecx,%ebx
  801582:	89 cf                	mov    %ecx,%edi
  801584:	51                   	push   %ecx
  801585:	52                   	push   %edx
  801586:	53                   	push   %ebx
  801587:	54                   	push   %esp
  801588:	55                   	push   %ebp
  801589:	56                   	push   %esi
  80158a:	57                   	push   %edi
  80158b:	54                   	push   %esp
  80158c:	5d                   	pop    %ebp
  80158d:	8d 35 95 15 80 00    	lea    0x801595,%esi
  801593:	0f 34                	sysenter 
  801595:	5f                   	pop    %edi
  801596:	5e                   	pop    %esi
  801597:	5d                   	pop    %ebp
  801598:	5c                   	pop    %esp
  801599:	5b                   	pop    %ebx
  80159a:	5a                   	pop    %edx
  80159b:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80159c:	85 c0                	test   %eax,%eax
  80159e:	7e 28                	jle    8015c8 <sys_env_destroy+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  8015a0:	89 44 24 10          	mov    %eax,0x10(%esp)
  8015a4:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  8015ab:	00 
  8015ac:	c7 44 24 08 a0 35 80 	movl   $0x8035a0,0x8(%esp)
  8015b3:	00 
  8015b4:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8015bb:	00 
  8015bc:	c7 04 24 bd 35 80 00 	movl   $0x8035bd,(%esp)
  8015c3:	e8 54 eb ff ff       	call   80011c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8015c8:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8015cb:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8015ce:	89 ec                	mov    %ebp,%esp
  8015d0:	5d                   	pop    %ebp
  8015d1:	c3                   	ret    
	...

008015e0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8015e0:	55                   	push   %ebp
  8015e1:	89 e5                	mov    %esp,%ebp
  8015e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8015e6:	05 00 00 00 30       	add    $0x30000000,%eax
  8015eb:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  8015ee:	5d                   	pop    %ebp
  8015ef:	c3                   	ret    

008015f0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8015f0:	55                   	push   %ebp
  8015f1:	89 e5                	mov    %esp,%ebp
  8015f3:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  8015f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8015f9:	89 04 24             	mov    %eax,(%esp)
  8015fc:	e8 df ff ff ff       	call   8015e0 <fd2num>
  801601:	05 20 00 0d 00       	add    $0xd0020,%eax
  801606:	c1 e0 0c             	shl    $0xc,%eax
}
  801609:	c9                   	leave  
  80160a:	c3                   	ret    

0080160b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80160b:	55                   	push   %ebp
  80160c:	89 e5                	mov    %esp,%ebp
  80160e:	57                   	push   %edi
  80160f:	56                   	push   %esi
  801610:	53                   	push   %ebx
  801611:	8b 7d 08             	mov    0x8(%ebp),%edi
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  801614:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  801619:	a8 01                	test   $0x1,%al
  80161b:	74 36                	je     801653 <fd_alloc+0x48>
  80161d:	a1 00 00 74 ef       	mov    0xef740000,%eax
  801622:	a8 01                	test   $0x1,%al
  801624:	74 2d                	je     801653 <fd_alloc+0x48>
  801626:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  80162b:	b9 00 d0 7b ef       	mov    $0xef7bd000,%ecx
  801630:	be 00 00 40 ef       	mov    $0xef400000,%esi
  801635:	89 c3                	mov    %eax,%ebx
  801637:	89 c2                	mov    %eax,%edx
  801639:	c1 ea 16             	shr    $0x16,%edx
  80163c:	8b 14 91             	mov    (%ecx,%edx,4),%edx
  80163f:	f6 c2 01             	test   $0x1,%dl
  801642:	74 14                	je     801658 <fd_alloc+0x4d>
  801644:	89 c2                	mov    %eax,%edx
  801646:	c1 ea 0c             	shr    $0xc,%edx
  801649:	8b 14 96             	mov    (%esi,%edx,4),%edx
  80164c:	f6 c2 01             	test   $0x1,%dl
  80164f:	75 10                	jne    801661 <fd_alloc+0x56>
  801651:	eb 05                	jmp    801658 <fd_alloc+0x4d>
  801653:	bb 00 00 00 d0       	mov    $0xd0000000,%ebx
			*fd_store = fd;
  801658:	89 1f                	mov    %ebx,(%edi)
  80165a:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  80165f:	eb 17                	jmp    801678 <fd_alloc+0x6d>
  801661:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801666:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80166b:	75 c8                	jne    801635 <fd_alloc+0x2a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80166d:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  801673:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  801678:	5b                   	pop    %ebx
  801679:	5e                   	pop    %esi
  80167a:	5f                   	pop    %edi
  80167b:	5d                   	pop    %ebp
  80167c:	c3                   	ret    

0080167d <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80167d:	55                   	push   %ebp
  80167e:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801680:	8b 45 08             	mov    0x8(%ebp),%eax
  801683:	83 f8 1f             	cmp    $0x1f,%eax
  801686:	77 36                	ja     8016be <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801688:	05 00 00 0d 00       	add    $0xd0000,%eax
  80168d:	c1 e0 0c             	shl    $0xc,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
  801690:	89 c2                	mov    %eax,%edx
  801692:	c1 ea 16             	shr    $0x16,%edx
  801695:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80169c:	f6 c2 01             	test   $0x1,%dl
  80169f:	74 1d                	je     8016be <fd_lookup+0x41>
  8016a1:	89 c2                	mov    %eax,%edx
  8016a3:	c1 ea 0c             	shr    $0xc,%edx
  8016a6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8016ad:	f6 c2 01             	test   $0x1,%dl
  8016b0:	74 0c                	je     8016be <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  8016b2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016b5:	89 02                	mov    %eax,(%edx)
  8016b7:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
  8016bc:	eb 05                	jmp    8016c3 <fd_lookup+0x46>
  8016be:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8016c3:	5d                   	pop    %ebp
  8016c4:	c3                   	ret    

008016c5 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  8016c5:	55                   	push   %ebp
  8016c6:	89 e5                	mov    %esp,%ebp
  8016c8:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8016cb:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8016ce:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8016d5:	89 04 24             	mov    %eax,(%esp)
  8016d8:	e8 a0 ff ff ff       	call   80167d <fd_lookup>
  8016dd:	85 c0                	test   %eax,%eax
  8016df:	78 0e                	js     8016ef <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8016e1:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8016e4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016e7:	89 50 04             	mov    %edx,0x4(%eax)
  8016ea:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  8016ef:	c9                   	leave  
  8016f0:	c3                   	ret    

008016f1 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8016f1:	55                   	push   %ebp
  8016f2:	89 e5                	mov    %esp,%ebp
  8016f4:	56                   	push   %esi
  8016f5:	53                   	push   %ebx
  8016f6:	83 ec 10             	sub    $0x10,%esp
  8016f9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016fc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
// File functions
// --------------------------------------------------------------

static struct Dev *devtab[] =
{
	&devfile,
  8016ff:	b8 04 40 80 00       	mov    $0x804004,%eax
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  801704:	ba 00 00 00 00       	mov    $0x0,%edx

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801709:	be 48 36 80 00       	mov    $0x803648,%esi
		if (devtab[i]->dev_id == dev_id) {
  80170e:	39 08                	cmp    %ecx,(%eax)
  801710:	75 10                	jne    801722 <dev_lookup+0x31>
  801712:	eb 04                	jmp    801718 <dev_lookup+0x27>
  801714:	39 08                	cmp    %ecx,(%eax)
  801716:	75 0a                	jne    801722 <dev_lookup+0x31>
			*dev = devtab[i];
  801718:	89 03                	mov    %eax,(%ebx)
  80171a:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  80171f:	90                   	nop
  801720:	eb 31                	jmp    801753 <dev_lookup+0x62>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801722:	83 c2 01             	add    $0x1,%edx
  801725:	8b 04 96             	mov    (%esi,%edx,4),%eax
  801728:	85 c0                	test   %eax,%eax
  80172a:	75 e8                	jne    801714 <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80172c:	a1 08 50 80 00       	mov    0x805008,%eax
  801731:	8b 40 48             	mov    0x48(%eax),%eax
  801734:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801738:	89 44 24 04          	mov    %eax,0x4(%esp)
  80173c:	c7 04 24 cc 35 80 00 	movl   $0x8035cc,(%esp)
  801743:	e8 8d ea ff ff       	call   8001d5 <cprintf>
	*dev = 0;
  801748:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80174e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  801753:	83 c4 10             	add    $0x10,%esp
  801756:	5b                   	pop    %ebx
  801757:	5e                   	pop    %esi
  801758:	5d                   	pop    %ebp
  801759:	c3                   	ret    

0080175a <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  80175a:	55                   	push   %ebp
  80175b:	89 e5                	mov    %esp,%ebp
  80175d:	53                   	push   %ebx
  80175e:	83 ec 24             	sub    $0x24,%esp
  801761:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801764:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801767:	89 44 24 04          	mov    %eax,0x4(%esp)
  80176b:	8b 45 08             	mov    0x8(%ebp),%eax
  80176e:	89 04 24             	mov    %eax,(%esp)
  801771:	e8 07 ff ff ff       	call   80167d <fd_lookup>
  801776:	85 c0                	test   %eax,%eax
  801778:	78 53                	js     8017cd <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80177a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80177d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801781:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801784:	8b 00                	mov    (%eax),%eax
  801786:	89 04 24             	mov    %eax,(%esp)
  801789:	e8 63 ff ff ff       	call   8016f1 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80178e:	85 c0                	test   %eax,%eax
  801790:	78 3b                	js     8017cd <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  801792:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801797:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80179a:	83 7a 14 00          	cmpl   $0x0,0x14(%edx)
  80179e:	74 2d                	je     8017cd <fstat+0x73>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8017a0:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8017a3:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8017aa:	00 00 00 
	stat->st_isdir = 0;
  8017ad:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8017b4:	00 00 00 
	stat->st_dev = dev;
  8017b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017ba:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8017c0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8017c4:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8017c7:	89 14 24             	mov    %edx,(%esp)
  8017ca:	ff 50 14             	call   *0x14(%eax)
}
  8017cd:	83 c4 24             	add    $0x24,%esp
  8017d0:	5b                   	pop    %ebx
  8017d1:	5d                   	pop    %ebp
  8017d2:	c3                   	ret    

008017d3 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  8017d3:	55                   	push   %ebp
  8017d4:	89 e5                	mov    %esp,%ebp
  8017d6:	53                   	push   %ebx
  8017d7:	83 ec 24             	sub    $0x24,%esp
  8017da:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017dd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017e0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017e4:	89 1c 24             	mov    %ebx,(%esp)
  8017e7:	e8 91 fe ff ff       	call   80167d <fd_lookup>
  8017ec:	85 c0                	test   %eax,%eax
  8017ee:	78 5f                	js     80184f <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017f0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017f3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017fa:	8b 00                	mov    (%eax),%eax
  8017fc:	89 04 24             	mov    %eax,(%esp)
  8017ff:	e8 ed fe ff ff       	call   8016f1 <dev_lookup>
ftruncate(int fdnum, off_t newsize)
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801804:	85 c0                	test   %eax,%eax
  801806:	78 47                	js     80184f <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801808:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80180b:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  80180f:	75 23                	jne    801834 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801811:	a1 08 50 80 00       	mov    0x805008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801816:	8b 40 48             	mov    0x48(%eax),%eax
  801819:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80181d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801821:	c7 04 24 ec 35 80 00 	movl   $0x8035ec,(%esp)
  801828:	e8 a8 e9 ff ff       	call   8001d5 <cprintf>
  80182d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801832:	eb 1b                	jmp    80184f <ftruncate+0x7c>
	}
	if (!dev->dev_trunc)
  801834:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801837:	8b 48 18             	mov    0x18(%eax),%ecx
  80183a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80183f:	85 c9                	test   %ecx,%ecx
  801841:	74 0c                	je     80184f <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801843:	8b 45 0c             	mov    0xc(%ebp),%eax
  801846:	89 44 24 04          	mov    %eax,0x4(%esp)
  80184a:	89 14 24             	mov    %edx,(%esp)
  80184d:	ff d1                	call   *%ecx
}
  80184f:	83 c4 24             	add    $0x24,%esp
  801852:	5b                   	pop    %ebx
  801853:	5d                   	pop    %ebp
  801854:	c3                   	ret    

00801855 <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801855:	55                   	push   %ebp
  801856:	89 e5                	mov    %esp,%ebp
  801858:	53                   	push   %ebx
  801859:	83 ec 24             	sub    $0x24,%esp
  80185c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80185f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801862:	89 44 24 04          	mov    %eax,0x4(%esp)
  801866:	89 1c 24             	mov    %ebx,(%esp)
  801869:	e8 0f fe ff ff       	call   80167d <fd_lookup>
  80186e:	85 c0                	test   %eax,%eax
  801870:	78 66                	js     8018d8 <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801872:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801875:	89 44 24 04          	mov    %eax,0x4(%esp)
  801879:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80187c:	8b 00                	mov    (%eax),%eax
  80187e:	89 04 24             	mov    %eax,(%esp)
  801881:	e8 6b fe ff ff       	call   8016f1 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801886:	85 c0                	test   %eax,%eax
  801888:	78 4e                	js     8018d8 <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80188a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80188d:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  801891:	75 23                	jne    8018b6 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801893:	a1 08 50 80 00       	mov    0x805008,%eax
  801898:	8b 40 48             	mov    0x48(%eax),%eax
  80189b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80189f:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018a3:	c7 04 24 0d 36 80 00 	movl   $0x80360d,(%esp)
  8018aa:	e8 26 e9 ff ff       	call   8001d5 <cprintf>
  8018af:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  8018b4:	eb 22                	jmp    8018d8 <write+0x83>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8018b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018b9:	8b 48 0c             	mov    0xc(%eax),%ecx
  8018bc:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8018c1:	85 c9                	test   %ecx,%ecx
  8018c3:	74 13                	je     8018d8 <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8018c5:	8b 45 10             	mov    0x10(%ebp),%eax
  8018c8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8018cc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018cf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018d3:	89 14 24             	mov    %edx,(%esp)
  8018d6:	ff d1                	call   *%ecx
}
  8018d8:	83 c4 24             	add    $0x24,%esp
  8018db:	5b                   	pop    %ebx
  8018dc:	5d                   	pop    %ebp
  8018dd:	c3                   	ret    

008018de <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8018de:	55                   	push   %ebp
  8018df:	89 e5                	mov    %esp,%ebp
  8018e1:	53                   	push   %ebx
  8018e2:	83 ec 24             	sub    $0x24,%esp
  8018e5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018e8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018eb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018ef:	89 1c 24             	mov    %ebx,(%esp)
  8018f2:	e8 86 fd ff ff       	call   80167d <fd_lookup>
  8018f7:	85 c0                	test   %eax,%eax
  8018f9:	78 6b                	js     801966 <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018fb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018fe:	89 44 24 04          	mov    %eax,0x4(%esp)
  801902:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801905:	8b 00                	mov    (%eax),%eax
  801907:	89 04 24             	mov    %eax,(%esp)
  80190a:	e8 e2 fd ff ff       	call   8016f1 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80190f:	85 c0                	test   %eax,%eax
  801911:	78 53                	js     801966 <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801913:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801916:	8b 42 08             	mov    0x8(%edx),%eax
  801919:	83 e0 03             	and    $0x3,%eax
  80191c:	83 f8 01             	cmp    $0x1,%eax
  80191f:	75 23                	jne    801944 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801921:	a1 08 50 80 00       	mov    0x805008,%eax
  801926:	8b 40 48             	mov    0x48(%eax),%eax
  801929:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80192d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801931:	c7 04 24 2a 36 80 00 	movl   $0x80362a,(%esp)
  801938:	e8 98 e8 ff ff       	call   8001d5 <cprintf>
  80193d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801942:	eb 22                	jmp    801966 <read+0x88>
	}
	if (!dev->dev_read)
  801944:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801947:	8b 48 08             	mov    0x8(%eax),%ecx
  80194a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80194f:	85 c9                	test   %ecx,%ecx
  801951:	74 13                	je     801966 <read+0x88>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801953:	8b 45 10             	mov    0x10(%ebp),%eax
  801956:	89 44 24 08          	mov    %eax,0x8(%esp)
  80195a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80195d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801961:	89 14 24             	mov    %edx,(%esp)
  801964:	ff d1                	call   *%ecx
}
  801966:	83 c4 24             	add    $0x24,%esp
  801969:	5b                   	pop    %ebx
  80196a:	5d                   	pop    %ebp
  80196b:	c3                   	ret    

0080196c <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80196c:	55                   	push   %ebp
  80196d:	89 e5                	mov    %esp,%ebp
  80196f:	57                   	push   %edi
  801970:	56                   	push   %esi
  801971:	53                   	push   %ebx
  801972:	83 ec 1c             	sub    $0x1c,%esp
  801975:	8b 7d 08             	mov    0x8(%ebp),%edi
  801978:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80197b:	ba 00 00 00 00       	mov    $0x0,%edx
  801980:	bb 00 00 00 00       	mov    $0x0,%ebx
  801985:	b8 00 00 00 00       	mov    $0x0,%eax
  80198a:	85 f6                	test   %esi,%esi
  80198c:	74 29                	je     8019b7 <readn+0x4b>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80198e:	89 f0                	mov    %esi,%eax
  801990:	29 d0                	sub    %edx,%eax
  801992:	89 44 24 08          	mov    %eax,0x8(%esp)
  801996:	03 55 0c             	add    0xc(%ebp),%edx
  801999:	89 54 24 04          	mov    %edx,0x4(%esp)
  80199d:	89 3c 24             	mov    %edi,(%esp)
  8019a0:	e8 39 ff ff ff       	call   8018de <read>
		if (m < 0)
  8019a5:	85 c0                	test   %eax,%eax
  8019a7:	78 0e                	js     8019b7 <readn+0x4b>
			return m;
		if (m == 0)
  8019a9:	85 c0                	test   %eax,%eax
  8019ab:	74 08                	je     8019b5 <readn+0x49>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8019ad:	01 c3                	add    %eax,%ebx
  8019af:	89 da                	mov    %ebx,%edx
  8019b1:	39 f3                	cmp    %esi,%ebx
  8019b3:	72 d9                	jb     80198e <readn+0x22>
  8019b5:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8019b7:	83 c4 1c             	add    $0x1c,%esp
  8019ba:	5b                   	pop    %ebx
  8019bb:	5e                   	pop    %esi
  8019bc:	5f                   	pop    %edi
  8019bd:	5d                   	pop    %ebp
  8019be:	c3                   	ret    

008019bf <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8019bf:	55                   	push   %ebp
  8019c0:	89 e5                	mov    %esp,%ebp
  8019c2:	56                   	push   %esi
  8019c3:	53                   	push   %ebx
  8019c4:	83 ec 20             	sub    $0x20,%esp
  8019c7:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8019ca:	89 34 24             	mov    %esi,(%esp)
  8019cd:	e8 0e fc ff ff       	call   8015e0 <fd2num>
  8019d2:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8019d5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8019d9:	89 04 24             	mov    %eax,(%esp)
  8019dc:	e8 9c fc ff ff       	call   80167d <fd_lookup>
  8019e1:	89 c3                	mov    %eax,%ebx
  8019e3:	85 c0                	test   %eax,%eax
  8019e5:	78 05                	js     8019ec <fd_close+0x2d>
  8019e7:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8019ea:	74 0c                	je     8019f8 <fd_close+0x39>
	    || fd != fd2)
		return (must_exist ? r : 0);
  8019ec:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  8019f0:	19 c0                	sbb    %eax,%eax
  8019f2:	f7 d0                	not    %eax
  8019f4:	21 c3                	and    %eax,%ebx
  8019f6:	eb 3d                	jmp    801a35 <fd_close+0x76>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8019f8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8019fb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019ff:	8b 06                	mov    (%esi),%eax
  801a01:	89 04 24             	mov    %eax,(%esp)
  801a04:	e8 e8 fc ff ff       	call   8016f1 <dev_lookup>
  801a09:	89 c3                	mov    %eax,%ebx
  801a0b:	85 c0                	test   %eax,%eax
  801a0d:	78 16                	js     801a25 <fd_close+0x66>
		if (dev->dev_close)
  801a0f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a12:	8b 40 10             	mov    0x10(%eax),%eax
  801a15:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a1a:	85 c0                	test   %eax,%eax
  801a1c:	74 07                	je     801a25 <fd_close+0x66>
			r = (*dev->dev_close)(fd);
  801a1e:	89 34 24             	mov    %esi,(%esp)
  801a21:	ff d0                	call   *%eax
  801a23:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801a25:	89 74 24 04          	mov    %esi,0x4(%esp)
  801a29:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a30:	e8 29 f9 ff ff       	call   80135e <sys_page_unmap>
	return r;
}
  801a35:	89 d8                	mov    %ebx,%eax
  801a37:	83 c4 20             	add    $0x20,%esp
  801a3a:	5b                   	pop    %ebx
  801a3b:	5e                   	pop    %esi
  801a3c:	5d                   	pop    %ebp
  801a3d:	c3                   	ret    

00801a3e <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801a3e:	55                   	push   %ebp
  801a3f:	89 e5                	mov    %esp,%ebp
  801a41:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a44:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a47:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a4b:	8b 45 08             	mov    0x8(%ebp),%eax
  801a4e:	89 04 24             	mov    %eax,(%esp)
  801a51:	e8 27 fc ff ff       	call   80167d <fd_lookup>
  801a56:	85 c0                	test   %eax,%eax
  801a58:	78 13                	js     801a6d <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801a5a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801a61:	00 
  801a62:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a65:	89 04 24             	mov    %eax,(%esp)
  801a68:	e8 52 ff ff ff       	call   8019bf <fd_close>
}
  801a6d:	c9                   	leave  
  801a6e:	c3                   	ret    

00801a6f <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  801a6f:	55                   	push   %ebp
  801a70:	89 e5                	mov    %esp,%ebp
  801a72:	83 ec 18             	sub    $0x18,%esp
  801a75:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801a78:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801a7b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801a82:	00 
  801a83:	8b 45 08             	mov    0x8(%ebp),%eax
  801a86:	89 04 24             	mov    %eax,(%esp)
  801a89:	e8 79 03 00 00       	call   801e07 <open>
  801a8e:	89 c3                	mov    %eax,%ebx
  801a90:	85 c0                	test   %eax,%eax
  801a92:	78 1b                	js     801aaf <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  801a94:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a97:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a9b:	89 1c 24             	mov    %ebx,(%esp)
  801a9e:	e8 b7 fc ff ff       	call   80175a <fstat>
  801aa3:	89 c6                	mov    %eax,%esi
	close(fd);
  801aa5:	89 1c 24             	mov    %ebx,(%esp)
  801aa8:	e8 91 ff ff ff       	call   801a3e <close>
  801aad:	89 f3                	mov    %esi,%ebx
	return r;
}
  801aaf:	89 d8                	mov    %ebx,%eax
  801ab1:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801ab4:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801ab7:	89 ec                	mov    %ebp,%esp
  801ab9:	5d                   	pop    %ebp
  801aba:	c3                   	ret    

00801abb <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  801abb:	55                   	push   %ebp
  801abc:	89 e5                	mov    %esp,%ebp
  801abe:	53                   	push   %ebx
  801abf:	83 ec 14             	sub    $0x14,%esp
  801ac2:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  801ac7:	89 1c 24             	mov    %ebx,(%esp)
  801aca:	e8 6f ff ff ff       	call   801a3e <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801acf:	83 c3 01             	add    $0x1,%ebx
  801ad2:	83 fb 20             	cmp    $0x20,%ebx
  801ad5:	75 f0                	jne    801ac7 <close_all+0xc>
		close(i);
}
  801ad7:	83 c4 14             	add    $0x14,%esp
  801ada:	5b                   	pop    %ebx
  801adb:	5d                   	pop    %ebp
  801adc:	c3                   	ret    

00801add <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801add:	55                   	push   %ebp
  801ade:	89 e5                	mov    %esp,%ebp
  801ae0:	83 ec 58             	sub    $0x58,%esp
  801ae3:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801ae6:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801ae9:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801aec:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801aef:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801af2:	89 44 24 04          	mov    %eax,0x4(%esp)
  801af6:	8b 45 08             	mov    0x8(%ebp),%eax
  801af9:	89 04 24             	mov    %eax,(%esp)
  801afc:	e8 7c fb ff ff       	call   80167d <fd_lookup>
  801b01:	89 c3                	mov    %eax,%ebx
  801b03:	85 c0                	test   %eax,%eax
  801b05:	0f 88 e0 00 00 00    	js     801beb <dup+0x10e>
		return r;
	close(newfdnum);
  801b0b:	89 3c 24             	mov    %edi,(%esp)
  801b0e:	e8 2b ff ff ff       	call   801a3e <close>

	newfd = INDEX2FD(newfdnum);
  801b13:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801b19:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801b1c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b1f:	89 04 24             	mov    %eax,(%esp)
  801b22:	e8 c9 fa ff ff       	call   8015f0 <fd2data>
  801b27:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801b29:	89 34 24             	mov    %esi,(%esp)
  801b2c:	e8 bf fa ff ff       	call   8015f0 <fd2data>
  801b31:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
  801b34:	89 da                	mov    %ebx,%edx
  801b36:	89 d8                	mov    %ebx,%eax
  801b38:	c1 e8 16             	shr    $0x16,%eax
  801b3b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801b42:	a8 01                	test   $0x1,%al
  801b44:	74 43                	je     801b89 <dup+0xac>
  801b46:	c1 ea 0c             	shr    $0xc,%edx
  801b49:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801b50:	a8 01                	test   $0x1,%al
  801b52:	74 35                	je     801b89 <dup+0xac>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801b54:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801b5b:	25 07 0e 00 00       	and    $0xe07,%eax
  801b60:	89 44 24 10          	mov    %eax,0x10(%esp)
  801b64:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801b67:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801b6b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801b72:	00 
  801b73:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801b77:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b7e:	e8 47 f8 ff ff       	call   8013ca <sys_page_map>
  801b83:	89 c3                	mov    %eax,%ebx
  801b85:	85 c0                	test   %eax,%eax
  801b87:	78 3f                	js     801bc8 <dup+0xeb>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801b89:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b8c:	89 c2                	mov    %eax,%edx
  801b8e:	c1 ea 0c             	shr    $0xc,%edx
  801b91:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801b98:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801b9e:	89 54 24 10          	mov    %edx,0x10(%esp)
  801ba2:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801ba6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801bad:	00 
  801bae:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bb2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801bb9:	e8 0c f8 ff ff       	call   8013ca <sys_page_map>
  801bbe:	89 c3                	mov    %eax,%ebx
  801bc0:	85 c0                	test   %eax,%eax
  801bc2:	78 04                	js     801bc8 <dup+0xeb>
  801bc4:	89 fb                	mov    %edi,%ebx
  801bc6:	eb 23                	jmp    801beb <dup+0x10e>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801bc8:	89 74 24 04          	mov    %esi,0x4(%esp)
  801bcc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801bd3:	e8 86 f7 ff ff       	call   80135e <sys_page_unmap>
	sys_page_unmap(0, nva);
  801bd8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801bdb:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bdf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801be6:	e8 73 f7 ff ff       	call   80135e <sys_page_unmap>
	return r;
}
  801beb:	89 d8                	mov    %ebx,%eax
  801bed:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801bf0:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801bf3:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801bf6:	89 ec                	mov    %ebp,%esp
  801bf8:	5d                   	pop    %ebp
  801bf9:	c3                   	ret    
	...

00801bfc <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801bfc:	55                   	push   %ebp
  801bfd:	89 e5                	mov    %esp,%ebp
  801bff:	83 ec 18             	sub    $0x18,%esp
  801c02:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801c05:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801c08:	89 c3                	mov    %eax,%ebx
  801c0a:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801c0c:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  801c13:	75 11                	jne    801c26 <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801c15:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801c1c:	e8 8f 11 00 00       	call   802db0 <ipc_find_env>
  801c21:	a3 00 50 80 00       	mov    %eax,0x805000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801c26:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801c2d:	00 
  801c2e:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  801c35:	00 
  801c36:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c3a:	a1 00 50 80 00       	mov    0x805000,%eax
  801c3f:	89 04 24             	mov    %eax,(%esp)
  801c42:	e8 b4 11 00 00       	call   802dfb <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801c47:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801c4e:	00 
  801c4f:	89 74 24 04          	mov    %esi,0x4(%esp)
  801c53:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c5a:	e8 1a 12 00 00       	call   802e79 <ipc_recv>
}
  801c5f:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801c62:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801c65:	89 ec                	mov    %ebp,%esp
  801c67:	5d                   	pop    %ebp
  801c68:	c3                   	ret    

00801c69 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801c69:	55                   	push   %ebp
  801c6a:	89 e5                	mov    %esp,%ebp
  801c6c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801c6f:	8b 45 08             	mov    0x8(%ebp),%eax
  801c72:	8b 40 0c             	mov    0xc(%eax),%eax
  801c75:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  801c7a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c7d:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801c82:	ba 00 00 00 00       	mov    $0x0,%edx
  801c87:	b8 02 00 00 00       	mov    $0x2,%eax
  801c8c:	e8 6b ff ff ff       	call   801bfc <fsipc>
}
  801c91:	c9                   	leave  
  801c92:	c3                   	ret    

00801c93 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801c93:	55                   	push   %ebp
  801c94:	89 e5                	mov    %esp,%ebp
  801c96:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801c99:	8b 45 08             	mov    0x8(%ebp),%eax
  801c9c:	8b 40 0c             	mov    0xc(%eax),%eax
  801c9f:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801ca4:	ba 00 00 00 00       	mov    $0x0,%edx
  801ca9:	b8 06 00 00 00       	mov    $0x6,%eax
  801cae:	e8 49 ff ff ff       	call   801bfc <fsipc>
}
  801cb3:	c9                   	leave  
  801cb4:	c3                   	ret    

00801cb5 <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  801cb5:	55                   	push   %ebp
  801cb6:	89 e5                	mov    %esp,%ebp
  801cb8:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801cbb:	ba 00 00 00 00       	mov    $0x0,%edx
  801cc0:	b8 08 00 00 00       	mov    $0x8,%eax
  801cc5:	e8 32 ff ff ff       	call   801bfc <fsipc>
}
  801cca:	c9                   	leave  
  801ccb:	c3                   	ret    

00801ccc <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801ccc:	55                   	push   %ebp
  801ccd:	89 e5                	mov    %esp,%ebp
  801ccf:	53                   	push   %ebx
  801cd0:	83 ec 14             	sub    $0x14,%esp
  801cd3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801cd6:	8b 45 08             	mov    0x8(%ebp),%eax
  801cd9:	8b 40 0c             	mov    0xc(%eax),%eax
  801cdc:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801ce1:	ba 00 00 00 00       	mov    $0x0,%edx
  801ce6:	b8 05 00 00 00       	mov    $0x5,%eax
  801ceb:	e8 0c ff ff ff       	call   801bfc <fsipc>
  801cf0:	85 c0                	test   %eax,%eax
  801cf2:	78 2b                	js     801d1f <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801cf4:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801cfb:	00 
  801cfc:	89 1c 24             	mov    %ebx,(%esp)
  801cff:	e8 06 ee ff ff       	call   800b0a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801d04:	a1 80 60 80 00       	mov    0x806080,%eax
  801d09:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801d0f:	a1 84 60 80 00       	mov    0x806084,%eax
  801d14:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  801d1a:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  801d1f:	83 c4 14             	add    $0x14,%esp
  801d22:	5b                   	pop    %ebx
  801d23:	5d                   	pop    %ebp
  801d24:	c3                   	ret    

00801d25 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801d25:	55                   	push   %ebp
  801d26:	89 e5                	mov    %esp,%ebp
  801d28:	83 ec 18             	sub    $0x18,%esp
  801d2b:	8b 45 10             	mov    0x10(%ebp),%eax
  801d2e:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801d33:	76 05                	jbe    801d3a <devfile_write+0x15>
  801d35:	b8 f8 0f 00 00       	mov    $0xff8,%eax
	// bytes than requested.
	// LAB 5: Your code here
        int r;
        if(n > sizeof(fsipcbuf.write.req_buf))
            n = sizeof(fsipcbuf.write.req_buf);
        fsipcbuf.write.req_fileid = fd->fd_file.id;
  801d3a:	8b 55 08             	mov    0x8(%ebp),%edx
  801d3d:	8b 52 0c             	mov    0xc(%edx),%edx
  801d40:	89 15 00 60 80 00    	mov    %edx,0x806000
        fsipcbuf.write.req_n = n;
  801d46:	a3 04 60 80 00       	mov    %eax,0x806004
        memmove(fsipcbuf.write.req_buf,buf,n);  
  801d4b:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d4f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d52:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d56:	c7 04 24 08 60 80 00 	movl   $0x806008,(%esp)
  801d5d:	e8 93 ef ff ff       	call   800cf5 <memmove>
        r = fsipc(FSREQ_WRITE,NULL);
  801d62:	ba 00 00 00 00       	mov    $0x0,%edx
  801d67:	b8 04 00 00 00       	mov    $0x4,%eax
  801d6c:	e8 8b fe ff ff       	call   801bfc <fsipc>
        return r;
	//panic("devfile_write not implemented");
}
  801d71:	c9                   	leave  
  801d72:	c3                   	ret    

00801d73 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801d73:	55                   	push   %ebp
  801d74:	89 e5                	mov    %esp,%ebp
  801d76:	53                   	push   %ebx
  801d77:	83 ec 14             	sub    $0x14,%esp
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
        int r;
        fsipcbuf.read.req_fileid = fd->fd_file.id;
  801d7a:	8b 45 08             	mov    0x8(%ebp),%eax
  801d7d:	8b 40 0c             	mov    0xc(%eax),%eax
  801d80:	a3 00 60 80 00       	mov    %eax,0x806000
        fsipcbuf.read.req_n = n;
  801d85:	8b 45 10             	mov    0x10(%ebp),%eax
  801d88:	a3 04 60 80 00       	mov    %eax,0x806004
        r = fsipc(FSREQ_READ,NULL);
  801d8d:	ba 00 00 00 00       	mov    $0x0,%edx
  801d92:	b8 03 00 00 00       	mov    $0x3,%eax
  801d97:	e8 60 fe ff ff       	call   801bfc <fsipc>
  801d9c:	89 c3                	mov    %eax,%ebx
        if(r < 0)
  801d9e:	85 c0                	test   %eax,%eax
  801da0:	78 17                	js     801db9 <devfile_read+0x46>
           return r;
        memmove(buf,fsipcbuf.readRet.ret_buf,r);
  801da2:	89 44 24 08          	mov    %eax,0x8(%esp)
  801da6:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801dad:	00 
  801dae:	8b 45 0c             	mov    0xc(%ebp),%eax
  801db1:	89 04 24             	mov    %eax,(%esp)
  801db4:	e8 3c ef ff ff       	call   800cf5 <memmove>
        return r;
	//panic("devfile_read not implemented");
}
  801db9:	89 d8                	mov    %ebx,%eax
  801dbb:	83 c4 14             	add    $0x14,%esp
  801dbe:	5b                   	pop    %ebx
  801dbf:	5d                   	pop    %ebp
  801dc0:	c3                   	ret    

00801dc1 <remove>:
}

// Delete a file
int
remove(const char *path)
{
  801dc1:	55                   	push   %ebp
  801dc2:	89 e5                	mov    %esp,%ebp
  801dc4:	53                   	push   %ebx
  801dc5:	83 ec 14             	sub    $0x14,%esp
  801dc8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  801dcb:	89 1c 24             	mov    %ebx,(%esp)
  801dce:	e8 ed ec ff ff       	call   800ac0 <strlen>
  801dd3:	89 c2                	mov    %eax,%edx
  801dd5:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  801dda:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
  801de0:	7f 1f                	jg     801e01 <remove+0x40>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  801de2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801de6:	c7 04 24 00 60 80 00 	movl   $0x806000,(%esp)
  801ded:	e8 18 ed ff ff       	call   800b0a <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  801df2:	ba 00 00 00 00       	mov    $0x0,%edx
  801df7:	b8 07 00 00 00       	mov    $0x7,%eax
  801dfc:	e8 fb fd ff ff       	call   801bfc <fsipc>
}
  801e01:	83 c4 14             	add    $0x14,%esp
  801e04:	5b                   	pop    %ebx
  801e05:	5d                   	pop    %ebp
  801e06:	c3                   	ret    

00801e07 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801e07:	55                   	push   %ebp
  801e08:	89 e5                	mov    %esp,%ebp
  801e0a:	83 ec 28             	sub    $0x28,%esp
  801e0d:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801e10:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801e13:	8b 75 08             	mov    0x8(%ebp),%esi
	// If any step after fd_alloc fails, use fd_close to free the
	// file descriptor.

	// LAB 5: Your code here.
        struct Fd* fd;
        if(strlen(path) > MAXPATHLEN)
  801e16:	89 34 24             	mov    %esi,(%esp)
  801e19:	e8 a2 ec ff ff       	call   800ac0 <strlen>
  801e1e:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801e23:	3d 00 04 00 00       	cmp    $0x400,%eax
  801e28:	7f 6d                	jg     801e97 <open+0x90>
            return -E_BAD_PATH;
        int r;
        r = fd_alloc(&fd);
  801e2a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e2d:	89 04 24             	mov    %eax,(%esp)
  801e30:	e8 d6 f7 ff ff       	call   80160b <fd_alloc>
  801e35:	89 c3                	mov    %eax,%ebx
        if(r < 0)
  801e37:	85 c0                	test   %eax,%eax
  801e39:	78 5c                	js     801e97 <open+0x90>
           return r;
        fsipcbuf.open.req_omode = mode;
  801e3b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e3e:	a3 00 64 80 00       	mov    %eax,0x806400
        memmove(fsipcbuf.open.req_path,path,strlen(path)+1);
  801e43:	89 34 24             	mov    %esi,(%esp)
  801e46:	e8 75 ec ff ff       	call   800ac0 <strlen>
  801e4b:	83 c0 01             	add    $0x1,%eax
  801e4e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e52:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e56:	c7 04 24 00 60 80 00 	movl   $0x806000,(%esp)
  801e5d:	e8 93 ee ff ff       	call   800cf5 <memmove>
        r = fsipc(FSREQ_OPEN,(void*)fd);
  801e62:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801e65:	b8 01 00 00 00       	mov    $0x1,%eax
  801e6a:	e8 8d fd ff ff       	call   801bfc <fsipc>
  801e6f:	89 c3                	mov    %eax,%ebx
        if(r < 0){
  801e71:	85 c0                	test   %eax,%eax
  801e73:	79 15                	jns    801e8a <open+0x83>
             fd_close(fd,0);
  801e75:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801e7c:	00 
  801e7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e80:	89 04 24             	mov    %eax,(%esp)
  801e83:	e8 37 fb ff ff       	call   8019bf <fd_close>
             return r;
  801e88:	eb 0d                	jmp    801e97 <open+0x90>
        }
        return fd2num(fd);
  801e8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e8d:	89 04 24             	mov    %eax,(%esp)
  801e90:	e8 4b f7 ff ff       	call   8015e0 <fd2num>
  801e95:	89 c3                	mov    %eax,%ebx
	//panic("open not implemented");
}
  801e97:	89 d8                	mov    %ebx,%eax
  801e99:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801e9c:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801e9f:	89 ec                	mov    %ebp,%esp
  801ea1:	5d                   	pop    %ebp
  801ea2:	c3                   	ret    
	...

00801ea4 <map_segment>:
}

static int
map_segment(envid_t child, uintptr_t va, size_t memsz,
	int fd, size_t filesz, off_t fileoffset, int perm)
{
  801ea4:	55                   	push   %ebp
  801ea5:	89 e5                	mov    %esp,%ebp
  801ea7:	57                   	push   %edi
  801ea8:	56                   	push   %esi
  801ea9:	53                   	push   %ebx
  801eaa:	83 ec 3c             	sub    $0x3c,%esp
  801ead:	89 45 dc             	mov    %eax,-0x24(%ebp)
  801eb0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  801eb3:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801eb6:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801eb9:	89 d0                	mov    %edx,%eax
  801ebb:	25 ff 0f 00 00       	and    $0xfff,%eax
  801ec0:	74 0d                	je     801ecf <map_segment+0x2b>
		va -= i;
  801ec2:	29 c2                	sub    %eax,%edx
  801ec4:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		memsz += i;
  801ec7:	01 45 e0             	add    %eax,-0x20(%ebp)
		filesz += i;
  801eca:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  801ecc:	29 45 10             	sub    %eax,0x10(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801ecf:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801ed3:	0f 84 12 01 00 00    	je     801feb <map_segment+0x147>
  801ed9:	be 00 00 00 00       	mov    $0x0,%esi
  801ede:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (i >= filesz) {
  801ee3:	39 f7                	cmp    %esi,%edi
  801ee5:	77 26                	ja     801f0d <map_segment+0x69>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801ee7:	8b 45 14             	mov    0x14(%ebp),%eax
  801eea:	89 44 24 08          	mov    %eax,0x8(%esp)
  801eee:	03 75 e4             	add    -0x1c(%ebp),%esi
  801ef1:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ef5:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801ef8:	89 14 24             	mov    %edx,(%esp)
  801efb:	e8 38 f5 ff ff       	call   801438 <sys_page_alloc>
  801f00:	85 c0                	test   %eax,%eax
  801f02:	0f 89 d2 00 00 00    	jns    801fda <map_segment+0x136>
  801f08:	e9 e3 00 00 00       	jmp    801ff0 <map_segment+0x14c>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801f0d:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801f14:	00 
  801f15:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801f1c:	00 
  801f1d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f24:	e8 0f f5 ff ff       	call   801438 <sys_page_alloc>
  801f29:	85 c0                	test   %eax,%eax
  801f2b:	0f 88 bf 00 00 00    	js     801ff0 <map_segment+0x14c>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801f31:	8b 55 10             	mov    0x10(%ebp),%edx
  801f34:	8d 04 13             	lea    (%ebx,%edx,1),%eax
  801f37:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f3b:	8b 45 08             	mov    0x8(%ebp),%eax
  801f3e:	89 04 24             	mov    %eax,(%esp)
  801f41:	e8 7f f7 ff ff       	call   8016c5 <seek>
  801f46:	85 c0                	test   %eax,%eax
  801f48:	0f 88 a2 00 00 00    	js     801ff0 <map_segment+0x14c>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801f4e:	89 f8                	mov    %edi,%eax
  801f50:	29 f0                	sub    %esi,%eax
  801f52:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801f57:	76 05                	jbe    801f5e <map_segment+0xba>
  801f59:	b8 00 10 00 00       	mov    $0x1000,%eax
  801f5e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f62:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801f69:	00 
  801f6a:	8b 55 08             	mov    0x8(%ebp),%edx
  801f6d:	89 14 24             	mov    %edx,(%esp)
  801f70:	e8 f7 f9 ff ff       	call   80196c <readn>
  801f75:	85 c0                	test   %eax,%eax
  801f77:	78 77                	js     801ff0 <map_segment+0x14c>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801f79:	8b 45 14             	mov    0x14(%ebp),%eax
  801f7c:	89 44 24 10          	mov    %eax,0x10(%esp)
  801f80:	03 75 e4             	add    -0x1c(%ebp),%esi
  801f83:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801f87:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801f8a:	89 54 24 08          	mov    %edx,0x8(%esp)
  801f8e:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801f95:	00 
  801f96:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f9d:	e8 28 f4 ff ff       	call   8013ca <sys_page_map>
  801fa2:	85 c0                	test   %eax,%eax
  801fa4:	79 20                	jns    801fc6 <map_segment+0x122>
				panic("spawn: sys_page_map data: %e", r);
  801fa6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801faa:	c7 44 24 08 54 36 80 	movl   $0x803654,0x8(%esp)
  801fb1:	00 
  801fb2:	c7 44 24 04 21 01 00 	movl   $0x121,0x4(%esp)
  801fb9:	00 
  801fba:	c7 04 24 71 36 80 00 	movl   $0x803671,(%esp)
  801fc1:	e8 56 e1 ff ff       	call   80011c <_panic>
			sys_page_unmap(0, UTEMP);
  801fc6:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801fcd:	00 
  801fce:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801fd5:	e8 84 f3 ff ff       	call   80135e <sys_page_unmap>
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801fda:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801fe0:	89 de                	mov    %ebx,%esi
  801fe2:	39 5d e0             	cmp    %ebx,-0x20(%ebp)
  801fe5:	0f 87 f8 fe ff ff    	ja     801ee3 <map_segment+0x3f>
  801feb:	b8 00 00 00 00       	mov    $0x0,%eax
				panic("spawn: sys_page_map data: %e", r);
			sys_page_unmap(0, UTEMP);
		}
	}
	return 0;
}
  801ff0:	83 c4 3c             	add    $0x3c,%esp
  801ff3:	5b                   	pop    %ebx
  801ff4:	5e                   	pop    %esi
  801ff5:	5f                   	pop    %edi
  801ff6:	5d                   	pop    %ebp
  801ff7:	c3                   	ret    

00801ff8 <exec>:

int
exec(const char *prog, const char **argv)
{
  801ff8:	55                   	push   %ebp
  801ff9:	89 e5                	mov    %esp,%ebp
  801ffb:	57                   	push   %edi
  801ffc:	56                   	push   %esi
  801ffd:	53                   	push   %ebx
  801ffe:	81 ec 4c 02 00 00    	sub    $0x24c,%esp
        struct Proghdr *ph;
        int perm;
        uint32_t tf_esp;
        uint32_t tmp = FTEMP;

        if ((r = open(prog, O_RDONLY)) < 0){
  802004:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80200b:	00 
  80200c:	8b 45 08             	mov    0x8(%ebp),%eax
  80200f:	89 04 24             	mov    %eax,(%esp)
  802012:	e8 f0 fd ff ff       	call   801e07 <open>
  802017:	89 85 e4 fd ff ff    	mov    %eax,-0x21c(%ebp)
  80201d:	89 c7                	mov    %eax,%edi
  80201f:	85 c0                	test   %eax,%eax
  802021:	0f 88 69 03 00 00    	js     802390 <exec+0x398>
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
	    || elf->e_magic != ELF_MAGIC) {
  802027:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  80202e:	00 
  80202f:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  802035:	89 44 24 04          	mov    %eax,0x4(%esp)
  802039:	89 3c 24             	mov    %edi,(%esp)
  80203c:	e8 2b f9 ff ff       	call   80196c <readn>
        }
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  802041:	3d 00 02 00 00       	cmp    $0x200,%eax
  802046:	75 0c                	jne    802054 <exec+0x5c>
	    || elf->e_magic != ELF_MAGIC) {
  802048:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  80204f:	45 4c 46 
  802052:	74 36                	je     80208a <exec+0x92>
		close(fd);
  802054:	8b 85 e4 fd ff ff    	mov    -0x21c(%ebp),%eax
  80205a:	89 04 24             	mov    %eax,(%esp)
  80205d:	e8 dc f9 ff ff       	call   801a3e <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  802062:	c7 44 24 08 7f 45 4c 	movl   $0x464c457f,0x8(%esp)
  802069:	46 
  80206a:	8b 85 e8 fd ff ff    	mov    -0x218(%ebp),%eax
  802070:	89 44 24 04          	mov    %eax,0x4(%esp)
  802074:	c7 04 24 7d 36 80 00 	movl   $0x80367d,(%esp)
  80207b:	e8 55 e1 ff ff       	call   8001d5 <cprintf>
  802080:	bf f2 ff ff ff       	mov    $0xfffffff2,%edi
		return -E_NOT_EXEC;
  802085:	e9 06 03 00 00       	jmp    802390 <exec+0x398>
	}

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  80208a:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  802090:	66 83 bd 14 fe ff ff 	cmpw   $0x0,-0x1ec(%ebp)
  802097:	00 
  802098:	0f 84 a5 00 00 00    	je     802143 <exec+0x14b>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
		return -E_NOT_EXEC;
	}

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  80209e:	8d 9c 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%ebx
  8020a5:	c7 85 e0 fd ff ff 00 	movl   $0xe0000000,-0x220(%ebp)
  8020ac:	00 00 e0 
  8020af:	be 00 00 00 00       	mov    $0x0,%esi
  8020b4:	bf 00 00 00 e0       	mov    $0xe0000000,%edi
	for (i = 0; i < elf->e_phnum; i++, ph++) {
		if (ph->p_type != ELF_PROG_LOAD)
  8020b9:	83 3b 01             	cmpl   $0x1,(%ebx)
  8020bc:	75 6f                	jne    80212d <exec+0x135>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  8020be:	8b 43 18             	mov    0x18(%ebx),%eax
  8020c1:	83 e0 02             	and    $0x2,%eax
  8020c4:	83 f8 01             	cmp    $0x1,%eax
  8020c7:	19 c0                	sbb    %eax,%eax
  8020c9:	83 e0 fe             	and    $0xfffffffe,%eax
  8020cc:	83 c0 07             	add    $0x7,%eax
			perm |= PTE_W;
		if ((r = map_segment(0, tmp + PGOFF(ph->p_va), ph->p_memsz,
  8020cf:	8b 4b 14             	mov    0x14(%ebx),%ecx
  8020d2:	8b 53 08             	mov    0x8(%ebx),%edx
  8020d5:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
  8020db:	8d 14 17             	lea    (%edi,%edx,1),%edx
  8020de:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8020e2:	8b 43 04             	mov    0x4(%ebx),%eax
  8020e5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8020e9:	8b 43 10             	mov    0x10(%ebx),%eax
  8020ec:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020f0:	8b 85 e4 fd ff ff    	mov    -0x21c(%ebp),%eax
  8020f6:	89 04 24             	mov    %eax,(%esp)
  8020f9:	b8 00 00 00 00       	mov    $0x0,%eax
  8020fe:	e8 a1 fd ff ff       	call   801ea4 <map_segment>
  802103:	85 c0                	test   %eax,%eax
  802105:	79 0d                	jns    802114 <exec+0x11c>
  802107:	89 c7                	mov    %eax,%edi
  802109:	8b 9d e4 fd ff ff    	mov    -0x21c(%ebp),%ebx
  80210f:	e9 68 02 00 00       	jmp    80237c <exec+0x384>
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
                tmp += ROUNDUP(PGOFF(ph->p_va) + ph->p_memsz, PGSIZE);
  802114:	8b 53 14             	mov    0x14(%ebx),%edx
  802117:	8b 43 08             	mov    0x8(%ebx),%eax
  80211a:	25 ff 0f 00 00       	and    $0xfff,%eax
  80211f:	8d 84 02 ff 0f 00 00 	lea    0xfff(%edx,%eax,1),%eax
  802126:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80212b:	01 c7                	add    %eax,%edi
		return -E_NOT_EXEC;
	}

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  80212d:	83 c6 01             	add    $0x1,%esi
  802130:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  802137:	39 f0                	cmp    %esi,%eax
  802139:	7e 14                	jle    80214f <exec+0x157>
  80213b:	83 c3 20             	add    $0x20,%ebx
  80213e:	e9 76 ff ff ff       	jmp    8020b9 <exec+0xc1>
  802143:	c7 85 e0 fd ff ff 00 	movl   $0xe0000000,-0x220(%ebp)
  80214a:	00 00 e0 
  80214d:	eb 06                	jmp    802155 <exec+0x15d>
  80214f:	89 bd e0 fd ff ff    	mov    %edi,-0x220(%ebp)
		if ((r = map_segment(0, tmp + PGOFF(ph->p_va), ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
                tmp += ROUNDUP(PGOFF(ph->p_va) + ph->p_memsz, PGSIZE);
	}
	close(fd);
  802155:	8b 95 e4 fd ff ff    	mov    -0x21c(%ebp),%edx
  80215b:	89 14 24             	mov    %edx,(%esp)
  80215e:	e8 db f8 ff ff       	call   801a3e <close>
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  802163:	8b 55 0c             	mov    0xc(%ebp),%edx
  802166:	8b 02                	mov    (%edx),%eax
  802168:	be 00 00 00 00       	mov    $0x0,%esi
  80216d:	bb 00 00 00 00       	mov    $0x0,%ebx
  802172:	85 c0                	test   %eax,%eax
  802174:	75 16                	jne    80218c <exec+0x194>
  802176:	c7 85 d0 fd ff ff 00 	movl   $0x0,-0x230(%ebp)
  80217d:	00 00 00 
  802180:	c7 85 cc fd ff ff 00 	movl   $0x0,-0x234(%ebp)
  802187:	00 00 00 
  80218a:	eb 2c                	jmp    8021b8 <exec+0x1c0>
  80218c:	8b 7d 0c             	mov    0xc(%ebp),%edi
		string_size += strlen(argv[argc]) + 1;
  80218f:	89 04 24             	mov    %eax,(%esp)
  802192:	e8 29 e9 ff ff       	call   800ac0 <strlen>
  802197:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  80219b:	83 c3 01             	add    $0x1,%ebx
  80219e:	8d 14 9d 00 00 00 00 	lea    0x0(,%ebx,4),%edx
  8021a5:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  8021a8:	85 c0                	test   %eax,%eax
  8021aa:	75 e3                	jne    80218f <exec+0x197>
  8021ac:	89 95 d0 fd ff ff    	mov    %edx,-0x230(%ebp)
  8021b2:	89 9d cc fd ff ff    	mov    %ebx,-0x234(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  8021b8:	f7 de                	neg    %esi
  8021ba:	81 c6 00 10 40 00    	add    $0x401000,%esi
  8021c0:	89 b5 d8 fd ff ff    	mov    %esi,-0x228(%ebp)
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  8021c6:	89 f2                	mov    %esi,%edx
  8021c8:	83 e2 fc             	and    $0xfffffffc,%edx
  8021cb:	89 d8                	mov    %ebx,%eax
  8021cd:	f7 d0                	not    %eax
  8021cf:	8d 04 82             	lea    (%edx,%eax,4),%eax
  8021d2:	89 85 e4 fd ff ff    	mov    %eax,-0x21c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  8021d8:	83 e8 08             	sub    $0x8,%eax
  8021db:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	return 0;

error:
	sys_env_destroy(0);
	close(fd);
	return r;
  8021e1:	bf fc ff ff ff       	mov    $0xfffffffc,%edi
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  8021e6:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  8021eb:	0f 86 9f 01 00 00    	jbe    802390 <exec+0x398>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8021f1:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8021f8:	00 
  8021f9:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  802200:	00 
  802201:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802208:	e8 2b f2 ff ff       	call   801438 <sys_page_alloc>
  80220d:	89 c7                	mov    %eax,%edi
  80220f:	85 c0                	test   %eax,%eax
  802211:	0f 88 79 01 00 00    	js     802390 <exec+0x398>
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  802217:	85 db                	test   %ebx,%ebx
  802219:	7e 52                	jle    80226d <exec+0x275>
  80221b:	be 00 00 00 00       	mov    $0x0,%esi
  802220:	89 9d dc fd ff ff    	mov    %ebx,-0x224(%ebp)
  802226:	8b bd d8 fd ff ff    	mov    -0x228(%ebp),%edi
  80222c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
		argv_store[i] = UTEMP2USTACK(string_store);
  80222f:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  802235:	8b 95 e4 fd ff ff    	mov    -0x21c(%ebp),%edx
  80223b:	89 04 b2             	mov    %eax,(%edx,%esi,4)
		strcpy(string_store, argv[i]);
  80223e:	8b 04 b3             	mov    (%ebx,%esi,4),%eax
  802241:	89 44 24 04          	mov    %eax,0x4(%esp)
  802245:	89 3c 24             	mov    %edi,(%esp)
  802248:	e8 bd e8 ff ff       	call   800b0a <strcpy>
		string_store += strlen(argv[i]) + 1;
  80224d:	8b 04 b3             	mov    (%ebx,%esi,4),%eax
  802250:	89 04 24             	mov    %eax,(%esp)
  802253:	e8 68 e8 ff ff       	call   800ac0 <strlen>
  802258:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  80225c:	83 c6 01             	add    $0x1,%esi
  80225f:	3b b5 dc fd ff ff    	cmp    -0x224(%ebp),%esi
  802265:	7c c8                	jl     80222f <exec+0x237>
  802267:	89 bd d8 fd ff ff    	mov    %edi,-0x228(%ebp)
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  80226d:	8b 95 e4 fd ff ff    	mov    -0x21c(%ebp),%edx
  802273:	8b 85 d0 fd ff ff    	mov    -0x230(%ebp),%eax
  802279:	c7 04 02 00 00 00 00 	movl   $0x0,(%edx,%eax,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  802280:	81 bd d8 fd ff ff 00 	cmpl   $0x401000,-0x228(%ebp)
  802287:	10 40 00 
  80228a:	74 24                	je     8022b0 <exec+0x2b8>
  80228c:	c7 44 24 0c e0 36 80 	movl   $0x8036e0,0xc(%esp)
  802293:	00 
  802294:	c7 44 24 08 97 36 80 	movl   $0x803697,0x8(%esp)
  80229b:	00 
  80229c:	c7 44 24 04 97 01 00 	movl   $0x197,0x4(%esp)
  8022a3:	00 
  8022a4:	c7 04 24 71 36 80 00 	movl   $0x803671,(%esp)
  8022ab:	e8 6c de ff ff       	call   80011c <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  8022b0:	8b 85 e4 fd ff ff    	mov    -0x21c(%ebp),%eax
  8022b6:	2d 00 30 80 11       	sub    $0x11803000,%eax
  8022bb:	8b 95 e4 fd ff ff    	mov    -0x21c(%ebp),%edx
  8022c1:	89 42 fc             	mov    %eax,-0x4(%edx)
	argv_store[-2] = argc;
  8022c4:	8b 95 cc fd ff ff    	mov    -0x234(%ebp),%edx
  8022ca:	8b 85 d4 fd ff ff    	mov    -0x22c(%ebp),%eax
  8022d0:	89 10                	mov    %edx,(%eax)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, envid, (void*) stack, PTE_P | PTE_U | PTE_W)) < 0)
  8022d2:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  8022d9:	00 
  8022da:	8b 85 e0 fd ff ff    	mov    -0x220(%ebp),%eax
  8022e0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8022e4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8022eb:	00 
  8022ec:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8022f3:	00 
  8022f4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8022fb:	e8 ca f0 ff ff       	call   8013ca <sys_page_map>
  802300:	89 c7                	mov    %eax,%edi
  802302:	85 c0                	test   %eax,%eax
  802304:	78 1a                	js     802320 <exec+0x328>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  802306:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  80230d:	00 
  80230e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802315:	e8 44 f0 ff ff       	call   80135e <sys_page_unmap>
  80231a:	89 c7                	mov    %eax,%edi
  80231c:	85 c0                	test   %eax,%eax
  80231e:	79 16                	jns    802336 <exec+0x33e>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  802320:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  802327:	00 
  802328:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80232f:	e8 2a f0 ff ff       	call   80135e <sys_page_unmap>
  802334:	eb 5a                	jmp    802390 <exec+0x398>
	close(fd);
	fd = -1;
        if ((r = init_stack_2(0, argv, &tf_esp,tmp)) < 0)
		return r;

	if (sys_exec((void*)(elf_buf + elf->e_phoff), elf->e_phnum, tf_esp, elf->e_entry) < 0)
  802336:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  80233c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802340:	8b 85 e4 fd ff ff    	mov    -0x21c(%ebp),%eax
  802346:	2d 08 30 80 11       	sub    $0x11803008,%eax
  80234b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80234f:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  802356:	89 44 24 04          	mov    %eax,0x4(%esp)
  80235a:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  802360:	03 85 04 fe ff ff    	add    -0x1fc(%ebp),%eax
  802366:	89 04 24             	mov    %eax,(%esp)
  802369:	e8 d2 ec ff ff       	call   801040 <sys_exec>
  80236e:	bf 00 00 00 00       	mov    $0x0,%edi
  802373:	85 c0                	test   %eax,%eax
  802375:	79 19                	jns    802390 <exec+0x398>
  802377:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
		goto error;
	return 0;

error:
	sys_env_destroy(0);
  80237c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802383:	e8 df f1 ff ff       	call   801567 <sys_env_destroy>
	close(fd);
  802388:	89 1c 24             	mov    %ebx,(%esp)
  80238b:	e8 ae f6 ff ff       	call   801a3e <close>
	return r;
}
  802390:	89 f8                	mov    %edi,%eax
  802392:	81 c4 4c 02 00 00    	add    $0x24c,%esp
  802398:	5b                   	pop    %ebx
  802399:	5e                   	pop    %esi
  80239a:	5f                   	pop    %edi
  80239b:	5d                   	pop    %ebp
  80239c:	c3                   	ret    

0080239d <execl>:
	return r;
}

int
execl(const char *prog, const char *arg0, ...)
{
  80239d:	55                   	push   %ebp
  80239e:	89 e5                	mov    %esp,%ebp
  8023a0:	56                   	push   %esi
  8023a1:	53                   	push   %ebx
  8023a2:	83 ec 10             	sub    $0x10,%esp
  8023a5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	sys_page_unmap(0, UTEMP);
	return r;
}

int
execl(const char *prog, const char *arg0, ...)
  8023a8:	8d 55 10             	lea    0x10(%ebp),%edx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  8023ab:	83 3a 00             	cmpl   $0x0,(%edx)
  8023ae:	74 5d                	je     80240d <execl+0x70>
  8023b0:	b8 00 00 00 00       	mov    $0x0,%eax
		argc++;
  8023b5:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  8023b8:	83 3c 82 00          	cmpl   $0x0,(%edx,%eax,4)
  8023bc:	75 f7                	jne    8023b5 <execl+0x18>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  8023be:	8d 14 85 26 00 00 00 	lea    0x26(,%eax,4),%edx
  8023c5:	83 e2 f0             	and    $0xfffffff0,%edx
  8023c8:	29 d4                	sub    %edx,%esp
  8023ca:	8d 4c 24 17          	lea    0x17(%esp),%ecx
  8023ce:	83 e1 f0             	and    $0xfffffff0,%ecx
	argv[0] = arg0;
  8023d1:	89 19                	mov    %ebx,(%ecx)
	argv[argc+1] = NULL;
  8023d3:	c7 44 81 04 00 00 00 	movl   $0x0,0x4(%ecx,%eax,4)
  8023da:	00 
	sys_page_unmap(0, UTEMP);
	return r;
}

int
execl(const char *prog, const char *arg0, ...)
  8023db:	8d 75 10             	lea    0x10(%ebp),%esi
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  8023de:	89 c3                	mov    %eax,%ebx
  8023e0:	85 c0                	test   %eax,%eax
  8023e2:	74 13                	je     8023f7 <execl+0x5a>
  8023e4:	b8 00 00 00 00       	mov    $0x0,%eax
		argv[i+1] = va_arg(vl, const char *);
  8023e9:	83 c0 01             	add    $0x1,%eax
  8023ec:	8b 54 86 fc          	mov    -0x4(%esi,%eax,4),%edx
  8023f0:	89 14 81             	mov    %edx,(%ecx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  8023f3:	39 d8                	cmp    %ebx,%eax
  8023f5:	72 f2                	jb     8023e9 <execl+0x4c>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return exec(prog, argv);
  8023f7:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8023fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8023fe:	89 04 24             	mov    %eax,(%esp)
  802401:	e8 f2 fb ff ff       	call   801ff8 <exec>
}
  802406:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802409:	5b                   	pop    %ebx
  80240a:	5e                   	pop    %esi
  80240b:	5d                   	pop    %ebp
  80240c:	c3                   	ret    
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  80240d:	83 ec 20             	sub    $0x20,%esp
  802410:	8d 4c 24 17          	lea    0x17(%esp),%ecx
  802414:	83 e1 f0             	and    $0xfffffff0,%ecx
	argv[0] = arg0;
  802417:	89 19                	mov    %ebx,(%ecx)
	argv[argc+1] = NULL;
  802419:	c7 41 04 00 00 00 00 	movl   $0x0,0x4(%ecx)
  802420:	eb d5                	jmp    8023f7 <execl+0x5a>

00802422 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  802422:	55                   	push   %ebp
  802423:	89 e5                	mov    %esp,%ebp
  802425:	57                   	push   %edi
  802426:	56                   	push   %esi
  802427:	53                   	push   %ebx
  802428:	81 ec 9c 02 00 00    	sub    $0x29c,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  80242e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  802435:	00 
  802436:	8b 45 08             	mov    0x8(%ebp),%eax
  802439:	89 04 24             	mov    %eax,(%esp)
  80243c:	e8 c6 f9 ff ff       	call   801e07 <open>
  802441:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  802447:	89 c7                	mov    %eax,%edi
  802449:	85 c0                	test   %eax,%eax
  80244b:	0f 88 ae 03 00 00    	js     8027ff <spawn+0x3dd>
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
	    || elf->e_magic != ELF_MAGIC) {
  802451:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  802458:	00 
  802459:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  80245f:	89 44 24 04          	mov    %eax,0x4(%esp)
  802463:	89 3c 24             	mov    %edi,(%esp)
  802466:	e8 01 f5 ff ff       	call   80196c <readn>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  80246b:	3d 00 02 00 00       	cmp    $0x200,%eax
  802470:	75 0c                	jne    80247e <spawn+0x5c>
	    || elf->e_magic != ELF_MAGIC) {
  802472:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  802479:	45 4c 46 
  80247c:	74 36                	je     8024b4 <spawn+0x92>
		close(fd);
  80247e:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  802484:	89 04 24             	mov    %eax,(%esp)
  802487:	e8 b2 f5 ff ff       	call   801a3e <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  80248c:	c7 44 24 08 7f 45 4c 	movl   $0x464c457f,0x8(%esp)
  802493:	46 
  802494:	8b 85 e8 fd ff ff    	mov    -0x218(%ebp),%eax
  80249a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80249e:	c7 04 24 7d 36 80 00 	movl   $0x80367d,(%esp)
  8024a5:	e8 2b dd ff ff       	call   8001d5 <cprintf>
  8024aa:	bf f2 ff ff ff       	mov    $0xfffffff2,%edi
		return -E_NOT_EXEC;
  8024af:	e9 4b 03 00 00       	jmp    8027ff <spawn+0x3dd>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  8024b4:	ba 08 00 00 00       	mov    $0x8,%edx
  8024b9:	89 d0                	mov    %edx,%eax
  8024bb:	cd 30                	int    $0x30
  8024bd:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  8024c3:	85 c0                	test   %eax,%eax
  8024c5:	0f 88 2e 03 00 00    	js     8027f9 <spawn+0x3d7>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  8024cb:	25 ff 03 00 00       	and    $0x3ff,%eax
  8024d0:	89 c2                	mov    %eax,%edx
  8024d2:	c1 e2 07             	shl    $0x7,%edx
  8024d5:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  8024db:	8d b4 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%esi
  8024e2:	b9 11 00 00 00       	mov    $0x11,%ecx
  8024e7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  8024e9:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  8024ef:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  8024f5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8024f8:	8b 02                	mov    (%edx),%eax
  8024fa:	be 00 00 00 00       	mov    $0x0,%esi
  8024ff:	bb 00 00 00 00       	mov    $0x0,%ebx
  802504:	85 c0                	test   %eax,%eax
  802506:	75 16                	jne    80251e <spawn+0xfc>
  802508:	c7 85 7c fd ff ff 00 	movl   $0x0,-0x284(%ebp)
  80250f:	00 00 00 
  802512:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  802519:	00 00 00 
  80251c:	eb 2c                	jmp    80254a <spawn+0x128>
  80251e:	8b 7d 0c             	mov    0xc(%ebp),%edi
		string_size += strlen(argv[argc]) + 1;
  802521:	89 04 24             	mov    %eax,(%esp)
  802524:	e8 97 e5 ff ff       	call   800ac0 <strlen>
  802529:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  80252d:	83 c3 01             	add    $0x1,%ebx
  802530:	8d 14 9d 00 00 00 00 	lea    0x0(,%ebx,4),%edx
  802537:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  80253a:	85 c0                	test   %eax,%eax
  80253c:	75 e3                	jne    802521 <spawn+0xff>
  80253e:	89 95 7c fd ff ff    	mov    %edx,-0x284(%ebp)
  802544:	89 9d 78 fd ff ff    	mov    %ebx,-0x288(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  80254a:	f7 de                	neg    %esi
  80254c:	81 c6 00 10 40 00    	add    $0x401000,%esi
  802552:	89 b5 84 fd ff ff    	mov    %esi,-0x27c(%ebp)
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  802558:	89 f2                	mov    %esi,%edx
  80255a:	83 e2 fc             	and    $0xfffffffc,%edx
  80255d:	89 d8                	mov    %ebx,%eax
  80255f:	f7 d0                	not    %eax
  802561:	8d 04 82             	lea    (%edx,%eax,4),%eax
  802564:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  80256a:	83 e8 08             	sub    $0x8,%eax
  80256d:	89 85 80 fd ff ff    	mov    %eax,-0x280(%ebp)
	return child;

error:
	sys_env_destroy(child);
	close(fd);
	return r;
  802573:	bf fc ff ff ff       	mov    $0xfffffffc,%edi
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  802578:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  80257d:	0f 86 7c 02 00 00    	jbe    8027ff <spawn+0x3dd>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  802583:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80258a:	00 
  80258b:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  802592:	00 
  802593:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80259a:	e8 99 ee ff ff       	call   801438 <sys_page_alloc>
  80259f:	89 c7                	mov    %eax,%edi
  8025a1:	85 c0                	test   %eax,%eax
  8025a3:	0f 88 56 02 00 00    	js     8027ff <spawn+0x3dd>
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  8025a9:	85 db                	test   %ebx,%ebx
  8025ab:	7e 52                	jle    8025ff <spawn+0x1dd>
  8025ad:	be 00 00 00 00       	mov    $0x0,%esi
  8025b2:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  8025b8:	8b bd 84 fd ff ff    	mov    -0x27c(%ebp),%edi
  8025be:	8b 5d 0c             	mov    0xc(%ebp),%ebx
		argv_store[i] = UTEMP2USTACK(string_store);
  8025c1:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  8025c7:	8b 95 8c fd ff ff    	mov    -0x274(%ebp),%edx
  8025cd:	89 04 b2             	mov    %eax,(%edx,%esi,4)
		strcpy(string_store, argv[i]);
  8025d0:	8b 04 b3             	mov    (%ebx,%esi,4),%eax
  8025d3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8025d7:	89 3c 24             	mov    %edi,(%esp)
  8025da:	e8 2b e5 ff ff       	call   800b0a <strcpy>
		string_store += strlen(argv[i]) + 1;
  8025df:	8b 04 b3             	mov    (%ebx,%esi,4),%eax
  8025e2:	89 04 24             	mov    %eax,(%esp)
  8025e5:	e8 d6 e4 ff ff       	call   800ac0 <strlen>
  8025ea:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  8025ee:	83 c6 01             	add    $0x1,%esi
  8025f1:	3b b5 88 fd ff ff    	cmp    -0x278(%ebp),%esi
  8025f7:	7c c8                	jl     8025c1 <spawn+0x19f>
  8025f9:	89 bd 84 fd ff ff    	mov    %edi,-0x27c(%ebp)
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  8025ff:	8b 95 8c fd ff ff    	mov    -0x274(%ebp),%edx
  802605:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  80260b:	c7 04 02 00 00 00 00 	movl   $0x0,(%edx,%eax,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  802612:	81 bd 84 fd ff ff 00 	cmpl   $0x401000,-0x27c(%ebp)
  802619:	10 40 00 
  80261c:	74 24                	je     802642 <spawn+0x220>
  80261e:	c7 44 24 0c e0 36 80 	movl   $0x8036e0,0xc(%esp)
  802625:	00 
  802626:	c7 44 24 08 97 36 80 	movl   $0x803697,0x8(%esp)
  80262d:	00 
  80262e:	c7 44 24 04 ee 00 00 	movl   $0xee,0x4(%esp)
  802635:	00 
  802636:	c7 04 24 71 36 80 00 	movl   $0x803671,(%esp)
  80263d:	e8 da da ff ff       	call   80011c <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  802642:	8b 85 8c fd ff ff    	mov    -0x274(%ebp),%eax
  802648:	2d 00 30 80 11       	sub    $0x11803000,%eax
  80264d:	8b 95 8c fd ff ff    	mov    -0x274(%ebp),%edx
  802653:	89 42 fc             	mov    %eax,-0x4(%edx)
	argv_store[-2] = argc;
  802656:	8b 95 78 fd ff ff    	mov    -0x288(%ebp),%edx
  80265c:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  802662:	89 10                	mov    %edx,(%eax)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  802664:	8b 85 8c fd ff ff    	mov    -0x274(%ebp),%eax
  80266a:	2d 08 30 80 11       	sub    $0x11803008,%eax
  80266f:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  802675:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  80267c:	00 
  80267d:	c7 44 24 0c 00 d0 bf 	movl   $0xeebfd000,0xc(%esp)
  802684:	ee 
  802685:	8b 85 90 fd ff ff    	mov    -0x270(%ebp),%eax
  80268b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80268f:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  802696:	00 
  802697:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80269e:	e8 27 ed ff ff       	call   8013ca <sys_page_map>
  8026a3:	89 c7                	mov    %eax,%edi
  8026a5:	85 c0                	test   %eax,%eax
  8026a7:	78 1a                	js     8026c3 <spawn+0x2a1>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  8026a9:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8026b0:	00 
  8026b1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8026b8:	e8 a1 ec ff ff       	call   80135e <sys_page_unmap>
  8026bd:	89 c7                	mov    %eax,%edi
  8026bf:	85 c0                	test   %eax,%eax
  8026c1:	79 19                	jns    8026dc <spawn+0x2ba>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  8026c3:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8026ca:	00 
  8026cb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8026d2:	e8 87 ec ff ff       	call   80135e <sys_page_unmap>
  8026d7:	e9 23 01 00 00       	jmp    8027ff <spawn+0x3dd>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  8026dc:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  8026e2:	66 83 bd 14 fe ff ff 	cmpw   $0x0,-0x1ec(%ebp)
  8026e9:	00 
  8026ea:	74 69                	je     802755 <spawn+0x333>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  8026ec:	8d 9c 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%ebx
  8026f3:	be 00 00 00 00       	mov    $0x0,%esi
  8026f8:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
	for (i = 0; i < elf->e_phnum; i++, ph++) {
		if (ph->p_type != ELF_PROG_LOAD)
  8026fe:	83 3b 01             	cmpl   $0x1,(%ebx)
  802701:	75 3f                	jne    802742 <spawn+0x320>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  802703:	8b 43 18             	mov    0x18(%ebx),%eax
  802706:	83 e0 02             	and    $0x2,%eax
  802709:	83 f8 01             	cmp    $0x1,%eax
  80270c:	19 c0                	sbb    %eax,%eax
  80270e:	83 e0 fe             	and    $0xfffffffe,%eax
  802711:	83 c0 07             	add    $0x7,%eax
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  802714:	8b 4b 14             	mov    0x14(%ebx),%ecx
  802717:	8b 53 08             	mov    0x8(%ebx),%edx
  80271a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80271e:	8b 43 04             	mov    0x4(%ebx),%eax
  802721:	89 44 24 08          	mov    %eax,0x8(%esp)
  802725:	8b 43 10             	mov    0x10(%ebx),%eax
  802728:	89 44 24 04          	mov    %eax,0x4(%esp)
  80272c:	89 3c 24             	mov    %edi,(%esp)
  80272f:	8b 85 90 fd ff ff    	mov    -0x270(%ebp),%eax
  802735:	e8 6a f7 ff ff       	call   801ea4 <map_segment>
  80273a:	85 c0                	test   %eax,%eax
  80273c:	0f 88 97 00 00 00    	js     8027d9 <spawn+0x3b7>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  802742:	83 c6 01             	add    $0x1,%esi
  802745:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  80274c:	39 f0                	cmp    %esi,%eax
  80274e:	7e 05                	jle    802755 <spawn+0x333>
  802750:	83 c3 20             	add    $0x20,%ebx
  802753:	eb a9                	jmp    8026fe <spawn+0x2dc>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  802755:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  80275b:	89 14 24             	mov    %edx,(%esp)
  80275e:	e8 db f2 ff ff       	call   801a3e <close>
	fd = -1;

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  802763:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  802769:	89 44 24 04          	mov    %eax,0x4(%esp)
  80276d:	8b 85 90 fd ff ff    	mov    -0x270(%ebp),%eax
  802773:	89 04 24             	mov    %eax,(%esp)
  802776:	e8 0b eb ff ff       	call   801286 <sys_env_set_trapframe>
  80277b:	85 c0                	test   %eax,%eax
  80277d:	79 20                	jns    80279f <spawn+0x37d>
		panic("sys_env_set_trapframe: %e", r);
  80277f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802783:	c7 44 24 08 ac 36 80 	movl   $0x8036ac,0x8(%esp)
  80278a:	00 
  80278b:	c7 44 24 04 82 00 00 	movl   $0x82,0x4(%esp)
  802792:	00 
  802793:	c7 04 24 71 36 80 00 	movl   $0x803671,(%esp)
  80279a:	e8 7d d9 ff ff       	call   80011c <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  80279f:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8027a6:	00 
  8027a7:	8b 95 90 fd ff ff    	mov    -0x270(%ebp),%edx
  8027ad:	89 14 24             	mov    %edx,(%esp)
  8027b0:	e8 3d eb ff ff       	call   8012f2 <sys_env_set_status>
  8027b5:	85 c0                	test   %eax,%eax
  8027b7:	79 40                	jns    8027f9 <spawn+0x3d7>
		panic("sys_env_set_status: %e", r);
  8027b9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8027bd:	c7 44 24 08 c6 36 80 	movl   $0x8036c6,0x8(%esp)
  8027c4:	00 
  8027c5:	c7 44 24 04 85 00 00 	movl   $0x85,0x4(%esp)
  8027cc:	00 
  8027cd:	c7 04 24 71 36 80 00 	movl   $0x803671,(%esp)
  8027d4:	e8 43 d9 ff ff       	call   80011c <_panic>
  8027d9:	89 c7                	mov    %eax,%edi

	return child;

error:
	sys_env_destroy(child);
  8027db:	8b 85 90 fd ff ff    	mov    -0x270(%ebp),%eax
  8027e1:	89 04 24             	mov    %eax,(%esp)
  8027e4:	e8 7e ed ff ff       	call   801567 <sys_env_destroy>
	close(fd);
  8027e9:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  8027ef:	89 14 24             	mov    %edx,(%esp)
  8027f2:	e8 47 f2 ff ff       	call   801a3e <close>
	return r;
  8027f7:	eb 06                	jmp    8027ff <spawn+0x3dd>
  8027f9:	8b bd 90 fd ff ff    	mov    -0x270(%ebp),%edi
}
  8027ff:	89 f8                	mov    %edi,%eax
  802801:	81 c4 9c 02 00 00    	add    $0x29c,%esp
  802807:	5b                   	pop    %ebx
  802808:	5e                   	pop    %esi
  802809:	5f                   	pop    %edi
  80280a:	5d                   	pop    %ebp
  80280b:	c3                   	ret    

0080280c <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  80280c:	55                   	push   %ebp
  80280d:	89 e5                	mov    %esp,%ebp
  80280f:	56                   	push   %esi
  802810:	53                   	push   %ebx
  802811:	83 ec 10             	sub    $0x10,%esp
  802814:	8b 5d 0c             	mov    0xc(%ebp),%ebx

// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
  802817:	8d 55 10             	lea    0x10(%ebp),%edx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  80281a:	83 3a 00             	cmpl   $0x0,(%edx)
  80281d:	74 5d                	je     80287c <spawnl+0x70>
  80281f:	b8 00 00 00 00       	mov    $0x0,%eax
		argc++;
  802824:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802827:	83 3c 82 00          	cmpl   $0x0,(%edx,%eax,4)
  80282b:	75 f7                	jne    802824 <spawnl+0x18>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  80282d:	8d 14 85 26 00 00 00 	lea    0x26(,%eax,4),%edx
  802834:	83 e2 f0             	and    $0xfffffff0,%edx
  802837:	29 d4                	sub    %edx,%esp
  802839:	8d 4c 24 17          	lea    0x17(%esp),%ecx
  80283d:	83 e1 f0             	and    $0xfffffff0,%ecx
	argv[0] = arg0;
  802840:	89 19                	mov    %ebx,(%ecx)
	argv[argc+1] = NULL;
  802842:	c7 44 81 04 00 00 00 	movl   $0x0,0x4(%ecx,%eax,4)
  802849:	00 

// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
  80284a:	8d 75 10             	lea    0x10(%ebp),%esi
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  80284d:	89 c3                	mov    %eax,%ebx
  80284f:	85 c0                	test   %eax,%eax
  802851:	74 13                	je     802866 <spawnl+0x5a>
  802853:	b8 00 00 00 00       	mov    $0x0,%eax
		argv[i+1] = va_arg(vl, const char *);
  802858:	83 c0 01             	add    $0x1,%eax
  80285b:	8b 54 86 fc          	mov    -0x4(%esi,%eax,4),%edx
  80285f:	89 14 81             	mov    %edx,(%ecx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  802862:	39 d8                	cmp    %ebx,%eax
  802864:	72 f2                	jb     802858 <spawnl+0x4c>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  802866:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80286a:	8b 45 08             	mov    0x8(%ebp),%eax
  80286d:	89 04 24             	mov    %eax,(%esp)
  802870:	e8 ad fb ff ff       	call   802422 <spawn>
}
  802875:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802878:	5b                   	pop    %ebx
  802879:	5e                   	pop    %esi
  80287a:	5d                   	pop    %ebp
  80287b:	c3                   	ret    
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  80287c:	83 ec 20             	sub    $0x20,%esp
  80287f:	8d 4c 24 17          	lea    0x17(%esp),%ecx
  802883:	83 e1 f0             	and    $0xfffffff0,%ecx
	argv[0] = arg0;
  802886:	89 19                	mov    %ebx,(%ecx)
	argv[argc+1] = NULL;
  802888:	c7 41 04 00 00 00 00 	movl   $0x0,0x4(%ecx)
  80288f:	eb d5                	jmp    802866 <spawnl+0x5a>
	...

008028a0 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  8028a0:	55                   	push   %ebp
  8028a1:	89 e5                	mov    %esp,%ebp
  8028a3:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  8028a6:	c7 44 24 04 08 37 80 	movl   $0x803708,0x4(%esp)
  8028ad:	00 
  8028ae:	8b 45 0c             	mov    0xc(%ebp),%eax
  8028b1:	89 04 24             	mov    %eax,(%esp)
  8028b4:	e8 51 e2 ff ff       	call   800b0a <strcpy>
	return 0;
}
  8028b9:	b8 00 00 00 00       	mov    $0x0,%eax
  8028be:	c9                   	leave  
  8028bf:	c3                   	ret    

008028c0 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  8028c0:	55                   	push   %ebp
  8028c1:	89 e5                	mov    %esp,%ebp
  8028c3:	53                   	push   %ebx
  8028c4:	83 ec 14             	sub    $0x14,%esp
  8028c7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  8028ca:	89 1c 24             	mov    %ebx,(%esp)
  8028cd:	e8 1a 06 00 00       	call   802eec <pageref>
  8028d2:	89 c2                	mov    %eax,%edx
  8028d4:	b8 00 00 00 00       	mov    $0x0,%eax
  8028d9:	83 fa 01             	cmp    $0x1,%edx
  8028dc:	75 0b                	jne    8028e9 <devsock_close+0x29>
		return nsipc_close(fd->fd_sock.sockid);
  8028de:	8b 43 0c             	mov    0xc(%ebx),%eax
  8028e1:	89 04 24             	mov    %eax,(%esp)
  8028e4:	e8 b9 02 00 00       	call   802ba2 <nsipc_close>
	else
		return 0;
}
  8028e9:	83 c4 14             	add    $0x14,%esp
  8028ec:	5b                   	pop    %ebx
  8028ed:	5d                   	pop    %ebp
  8028ee:	c3                   	ret    

008028ef <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  8028ef:	55                   	push   %ebp
  8028f0:	89 e5                	mov    %esp,%ebp
  8028f2:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8028f5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8028fc:	00 
  8028fd:	8b 45 10             	mov    0x10(%ebp),%eax
  802900:	89 44 24 08          	mov    %eax,0x8(%esp)
  802904:	8b 45 0c             	mov    0xc(%ebp),%eax
  802907:	89 44 24 04          	mov    %eax,0x4(%esp)
  80290b:	8b 45 08             	mov    0x8(%ebp),%eax
  80290e:	8b 40 0c             	mov    0xc(%eax),%eax
  802911:	89 04 24             	mov    %eax,(%esp)
  802914:	e8 c5 02 00 00       	call   802bde <nsipc_send>
}
  802919:	c9                   	leave  
  80291a:	c3                   	ret    

0080291b <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  80291b:	55                   	push   %ebp
  80291c:	89 e5                	mov    %esp,%ebp
  80291e:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  802921:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  802928:	00 
  802929:	8b 45 10             	mov    0x10(%ebp),%eax
  80292c:	89 44 24 08          	mov    %eax,0x8(%esp)
  802930:	8b 45 0c             	mov    0xc(%ebp),%eax
  802933:	89 44 24 04          	mov    %eax,0x4(%esp)
  802937:	8b 45 08             	mov    0x8(%ebp),%eax
  80293a:	8b 40 0c             	mov    0xc(%eax),%eax
  80293d:	89 04 24             	mov    %eax,(%esp)
  802940:	e8 0c 03 00 00       	call   802c51 <nsipc_recv>
}
  802945:	c9                   	leave  
  802946:	c3                   	ret    

00802947 <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  802947:	55                   	push   %ebp
  802948:	89 e5                	mov    %esp,%ebp
  80294a:	56                   	push   %esi
  80294b:	53                   	push   %ebx
  80294c:	83 ec 20             	sub    $0x20,%esp
  80294f:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  802951:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802954:	89 04 24             	mov    %eax,(%esp)
  802957:	e8 af ec ff ff       	call   80160b <fd_alloc>
  80295c:	89 c3                	mov    %eax,%ebx
  80295e:	85 c0                	test   %eax,%eax
  802960:	78 21                	js     802983 <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  802962:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802969:	00 
  80296a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80296d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802971:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802978:	e8 bb ea ff ff       	call   801438 <sys_page_alloc>
  80297d:	89 c3                	mov    %eax,%ebx
alloc_sockfd(int sockid)
{
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  80297f:	85 c0                	test   %eax,%eax
  802981:	79 0a                	jns    80298d <alloc_sockfd+0x46>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
		nsipc_close(sockid);
  802983:	89 34 24             	mov    %esi,(%esp)
  802986:	e8 17 02 00 00       	call   802ba2 <nsipc_close>
		return r;
  80298b:	eb 28                	jmp    8029b5 <alloc_sockfd+0x6e>
	}

	sfd->fd_dev_id = devsock.dev_id;
  80298d:	8b 15 20 40 80 00    	mov    0x804020,%edx
  802993:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802996:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  802998:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80299b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  8029a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8029a5:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  8029a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8029ab:	89 04 24             	mov    %eax,(%esp)
  8029ae:	e8 2d ec ff ff       	call   8015e0 <fd2num>
  8029b3:	89 c3                	mov    %eax,%ebx
}
  8029b5:	89 d8                	mov    %ebx,%eax
  8029b7:	83 c4 20             	add    $0x20,%esp
  8029ba:	5b                   	pop    %ebx
  8029bb:	5e                   	pop    %esi
  8029bc:	5d                   	pop    %ebp
  8029bd:	c3                   	ret    

008029be <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  8029be:	55                   	push   %ebp
  8029bf:	89 e5                	mov    %esp,%ebp
  8029c1:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  8029c4:	8b 45 10             	mov    0x10(%ebp),%eax
  8029c7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8029cb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8029ce:	89 44 24 04          	mov    %eax,0x4(%esp)
  8029d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8029d5:	89 04 24             	mov    %eax,(%esp)
  8029d8:	e8 79 01 00 00       	call   802b56 <nsipc_socket>
  8029dd:	85 c0                	test   %eax,%eax
  8029df:	78 05                	js     8029e6 <socket+0x28>
		return r;
	return alloc_sockfd(r);
  8029e1:	e8 61 ff ff ff       	call   802947 <alloc_sockfd>
}
  8029e6:	c9                   	leave  
  8029e7:	c3                   	ret    

008029e8 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  8029e8:	55                   	push   %ebp
  8029e9:	89 e5                	mov    %esp,%ebp
  8029eb:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  8029ee:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8029f1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8029f5:	89 04 24             	mov    %eax,(%esp)
  8029f8:	e8 80 ec ff ff       	call   80167d <fd_lookup>
  8029fd:	85 c0                	test   %eax,%eax
  8029ff:	78 15                	js     802a16 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  802a01:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802a04:	8b 0a                	mov    (%edx),%ecx
  802a06:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  802a0b:	3b 0d 20 40 80 00    	cmp    0x804020,%ecx
  802a11:	75 03                	jne    802a16 <fd2sockid+0x2e>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  802a13:	8b 42 0c             	mov    0xc(%edx),%eax
}
  802a16:	c9                   	leave  
  802a17:	c3                   	ret    

00802a18 <listen>:
	return nsipc_connect(r, name, namelen);
}

int
listen(int s, int backlog)
{
  802a18:	55                   	push   %ebp
  802a19:	89 e5                	mov    %esp,%ebp
  802a1b:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802a1e:	8b 45 08             	mov    0x8(%ebp),%eax
  802a21:	e8 c2 ff ff ff       	call   8029e8 <fd2sockid>
  802a26:	85 c0                	test   %eax,%eax
  802a28:	78 0f                	js     802a39 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  802a2a:	8b 55 0c             	mov    0xc(%ebp),%edx
  802a2d:	89 54 24 04          	mov    %edx,0x4(%esp)
  802a31:	89 04 24             	mov    %eax,(%esp)
  802a34:	e8 47 01 00 00       	call   802b80 <nsipc_listen>
}
  802a39:	c9                   	leave  
  802a3a:	c3                   	ret    

00802a3b <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  802a3b:	55                   	push   %ebp
  802a3c:	89 e5                	mov    %esp,%ebp
  802a3e:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802a41:	8b 45 08             	mov    0x8(%ebp),%eax
  802a44:	e8 9f ff ff ff       	call   8029e8 <fd2sockid>
  802a49:	85 c0                	test   %eax,%eax
  802a4b:	78 16                	js     802a63 <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  802a4d:	8b 55 10             	mov    0x10(%ebp),%edx
  802a50:	89 54 24 08          	mov    %edx,0x8(%esp)
  802a54:	8b 55 0c             	mov    0xc(%ebp),%edx
  802a57:	89 54 24 04          	mov    %edx,0x4(%esp)
  802a5b:	89 04 24             	mov    %eax,(%esp)
  802a5e:	e8 6e 02 00 00       	call   802cd1 <nsipc_connect>
}
  802a63:	c9                   	leave  
  802a64:	c3                   	ret    

00802a65 <shutdown>:
	return nsipc_bind(r, name, namelen);
}

int
shutdown(int s, int how)
{
  802a65:	55                   	push   %ebp
  802a66:	89 e5                	mov    %esp,%ebp
  802a68:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802a6b:	8b 45 08             	mov    0x8(%ebp),%eax
  802a6e:	e8 75 ff ff ff       	call   8029e8 <fd2sockid>
  802a73:	85 c0                	test   %eax,%eax
  802a75:	78 0f                	js     802a86 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  802a77:	8b 55 0c             	mov    0xc(%ebp),%edx
  802a7a:	89 54 24 04          	mov    %edx,0x4(%esp)
  802a7e:	89 04 24             	mov    %eax,(%esp)
  802a81:	e8 36 01 00 00       	call   802bbc <nsipc_shutdown>
}
  802a86:	c9                   	leave  
  802a87:	c3                   	ret    

00802a88 <bind>:
	return alloc_sockfd(r);
}

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802a88:	55                   	push   %ebp
  802a89:	89 e5                	mov    %esp,%ebp
  802a8b:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802a8e:	8b 45 08             	mov    0x8(%ebp),%eax
  802a91:	e8 52 ff ff ff       	call   8029e8 <fd2sockid>
  802a96:	85 c0                	test   %eax,%eax
  802a98:	78 16                	js     802ab0 <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  802a9a:	8b 55 10             	mov    0x10(%ebp),%edx
  802a9d:	89 54 24 08          	mov    %edx,0x8(%esp)
  802aa1:	8b 55 0c             	mov    0xc(%ebp),%edx
  802aa4:	89 54 24 04          	mov    %edx,0x4(%esp)
  802aa8:	89 04 24             	mov    %eax,(%esp)
  802aab:	e8 60 02 00 00       	call   802d10 <nsipc_bind>
}
  802ab0:	c9                   	leave  
  802ab1:	c3                   	ret    

00802ab2 <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  802ab2:	55                   	push   %ebp
  802ab3:	89 e5                	mov    %esp,%ebp
  802ab5:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802ab8:	8b 45 08             	mov    0x8(%ebp),%eax
  802abb:	e8 28 ff ff ff       	call   8029e8 <fd2sockid>
  802ac0:	85 c0                	test   %eax,%eax
  802ac2:	78 1f                	js     802ae3 <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  802ac4:	8b 55 10             	mov    0x10(%ebp),%edx
  802ac7:	89 54 24 08          	mov    %edx,0x8(%esp)
  802acb:	8b 55 0c             	mov    0xc(%ebp),%edx
  802ace:	89 54 24 04          	mov    %edx,0x4(%esp)
  802ad2:	89 04 24             	mov    %eax,(%esp)
  802ad5:	e8 75 02 00 00       	call   802d4f <nsipc_accept>
  802ada:	85 c0                	test   %eax,%eax
  802adc:	78 05                	js     802ae3 <accept+0x31>
		return r;
	return alloc_sockfd(r);
  802ade:	e8 64 fe ff ff       	call   802947 <alloc_sockfd>
}
  802ae3:	c9                   	leave  
  802ae4:	c3                   	ret    
	...

00802af0 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  802af0:	55                   	push   %ebp
  802af1:	89 e5                	mov    %esp,%ebp
  802af3:	53                   	push   %ebx
  802af4:	83 ec 14             	sub    $0x14,%esp
  802af7:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  802af9:	83 3d 04 50 80 00 00 	cmpl   $0x0,0x805004
  802b00:	75 11                	jne    802b13 <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  802b02:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  802b09:	e8 a2 02 00 00       	call   802db0 <ipc_find_env>
  802b0e:	a3 04 50 80 00       	mov    %eax,0x805004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  802b13:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  802b1a:	00 
  802b1b:	c7 44 24 08 00 70 80 	movl   $0x807000,0x8(%esp)
  802b22:	00 
  802b23:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802b27:	a1 04 50 80 00       	mov    0x805004,%eax
  802b2c:	89 04 24             	mov    %eax,(%esp)
  802b2f:	e8 c7 02 00 00       	call   802dfb <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  802b34:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  802b3b:	00 
  802b3c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  802b43:	00 
  802b44:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802b4b:	e8 29 03 00 00       	call   802e79 <ipc_recv>
}
  802b50:	83 c4 14             	add    $0x14,%esp
  802b53:	5b                   	pop    %ebx
  802b54:	5d                   	pop    %ebp
  802b55:	c3                   	ret    

00802b56 <nsipc_socket>:
	return nsipc(NSREQ_SEND);
}

int
nsipc_socket(int domain, int type, int protocol)
{
  802b56:	55                   	push   %ebp
  802b57:	89 e5                	mov    %esp,%ebp
  802b59:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  802b5c:	8b 45 08             	mov    0x8(%ebp),%eax
  802b5f:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  802b64:	8b 45 0c             	mov    0xc(%ebp),%eax
  802b67:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  802b6c:	8b 45 10             	mov    0x10(%ebp),%eax
  802b6f:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  802b74:	b8 09 00 00 00       	mov    $0x9,%eax
  802b79:	e8 72 ff ff ff       	call   802af0 <nsipc>
}
  802b7e:	c9                   	leave  
  802b7f:	c3                   	ret    

00802b80 <nsipc_listen>:
	return nsipc(NSREQ_CONNECT);
}

int
nsipc_listen(int s, int backlog)
{
  802b80:	55                   	push   %ebp
  802b81:	89 e5                	mov    %esp,%ebp
  802b83:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  802b86:	8b 45 08             	mov    0x8(%ebp),%eax
  802b89:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  802b8e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802b91:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  802b96:	b8 06 00 00 00       	mov    $0x6,%eax
  802b9b:	e8 50 ff ff ff       	call   802af0 <nsipc>
}
  802ba0:	c9                   	leave  
  802ba1:	c3                   	ret    

00802ba2 <nsipc_close>:
	return nsipc(NSREQ_SHUTDOWN);
}

int
nsipc_close(int s)
{
  802ba2:	55                   	push   %ebp
  802ba3:	89 e5                	mov    %esp,%ebp
  802ba5:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  802ba8:	8b 45 08             	mov    0x8(%ebp),%eax
  802bab:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  802bb0:	b8 04 00 00 00       	mov    $0x4,%eax
  802bb5:	e8 36 ff ff ff       	call   802af0 <nsipc>
}
  802bba:	c9                   	leave  
  802bbb:	c3                   	ret    

00802bbc <nsipc_shutdown>:
	return nsipc(NSREQ_BIND);
}

int
nsipc_shutdown(int s, int how)
{
  802bbc:	55                   	push   %ebp
  802bbd:	89 e5                	mov    %esp,%ebp
  802bbf:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  802bc2:	8b 45 08             	mov    0x8(%ebp),%eax
  802bc5:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  802bca:	8b 45 0c             	mov    0xc(%ebp),%eax
  802bcd:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  802bd2:	b8 03 00 00 00       	mov    $0x3,%eax
  802bd7:	e8 14 ff ff ff       	call   802af0 <nsipc>
}
  802bdc:	c9                   	leave  
  802bdd:	c3                   	ret    

00802bde <nsipc_send>:
	return r;
}

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  802bde:	55                   	push   %ebp
  802bdf:	89 e5                	mov    %esp,%ebp
  802be1:	53                   	push   %ebx
  802be2:	83 ec 14             	sub    $0x14,%esp
  802be5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  802be8:	8b 45 08             	mov    0x8(%ebp),%eax
  802beb:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  802bf0:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  802bf6:	7e 24                	jle    802c1c <nsipc_send+0x3e>
  802bf8:	c7 44 24 0c 14 37 80 	movl   $0x803714,0xc(%esp)
  802bff:	00 
  802c00:	c7 44 24 08 97 36 80 	movl   $0x803697,0x8(%esp)
  802c07:	00 
  802c08:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
  802c0f:	00 
  802c10:	c7 04 24 20 37 80 00 	movl   $0x803720,(%esp)
  802c17:	e8 00 d5 ff ff       	call   80011c <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  802c1c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802c20:	8b 45 0c             	mov    0xc(%ebp),%eax
  802c23:	89 44 24 04          	mov    %eax,0x4(%esp)
  802c27:	c7 04 24 0c 70 80 00 	movl   $0x80700c,(%esp)
  802c2e:	e8 c2 e0 ff ff       	call   800cf5 <memmove>
	nsipcbuf.send.req_size = size;
  802c33:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  802c39:	8b 45 14             	mov    0x14(%ebp),%eax
  802c3c:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  802c41:	b8 08 00 00 00       	mov    $0x8,%eax
  802c46:	e8 a5 fe ff ff       	call   802af0 <nsipc>
}
  802c4b:	83 c4 14             	add    $0x14,%esp
  802c4e:	5b                   	pop    %ebx
  802c4f:	5d                   	pop    %ebp
  802c50:	c3                   	ret    

00802c51 <nsipc_recv>:
	return nsipc(NSREQ_LISTEN);
}

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  802c51:	55                   	push   %ebp
  802c52:	89 e5                	mov    %esp,%ebp
  802c54:	56                   	push   %esi
  802c55:	53                   	push   %ebx
  802c56:	83 ec 10             	sub    $0x10,%esp
  802c59:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  802c5c:	8b 45 08             	mov    0x8(%ebp),%eax
  802c5f:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  802c64:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  802c6a:	8b 45 14             	mov    0x14(%ebp),%eax
  802c6d:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  802c72:	b8 07 00 00 00       	mov    $0x7,%eax
  802c77:	e8 74 fe ff ff       	call   802af0 <nsipc>
  802c7c:	89 c3                	mov    %eax,%ebx
  802c7e:	85 c0                	test   %eax,%eax
  802c80:	78 46                	js     802cc8 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  802c82:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  802c87:	7f 04                	jg     802c8d <nsipc_recv+0x3c>
  802c89:	39 c6                	cmp    %eax,%esi
  802c8b:	7d 24                	jge    802cb1 <nsipc_recv+0x60>
  802c8d:	c7 44 24 0c 2c 37 80 	movl   $0x80372c,0xc(%esp)
  802c94:	00 
  802c95:	c7 44 24 08 97 36 80 	movl   $0x803697,0x8(%esp)
  802c9c:	00 
  802c9d:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
  802ca4:	00 
  802ca5:	c7 04 24 20 37 80 00 	movl   $0x803720,(%esp)
  802cac:	e8 6b d4 ff ff       	call   80011c <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  802cb1:	89 44 24 08          	mov    %eax,0x8(%esp)
  802cb5:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  802cbc:	00 
  802cbd:	8b 45 0c             	mov    0xc(%ebp),%eax
  802cc0:	89 04 24             	mov    %eax,(%esp)
  802cc3:	e8 2d e0 ff ff       	call   800cf5 <memmove>
	}

	return r;
}
  802cc8:	89 d8                	mov    %ebx,%eax
  802cca:	83 c4 10             	add    $0x10,%esp
  802ccd:	5b                   	pop    %ebx
  802cce:	5e                   	pop    %esi
  802ccf:	5d                   	pop    %ebp
  802cd0:	c3                   	ret    

00802cd1 <nsipc_connect>:
	return nsipc(NSREQ_CLOSE);
}

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  802cd1:	55                   	push   %ebp
  802cd2:	89 e5                	mov    %esp,%ebp
  802cd4:	53                   	push   %ebx
  802cd5:	83 ec 14             	sub    $0x14,%esp
  802cd8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  802cdb:	8b 45 08             	mov    0x8(%ebp),%eax
  802cde:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  802ce3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802ce7:	8b 45 0c             	mov    0xc(%ebp),%eax
  802cea:	89 44 24 04          	mov    %eax,0x4(%esp)
  802cee:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  802cf5:	e8 fb df ff ff       	call   800cf5 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  802cfa:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  802d00:	b8 05 00 00 00       	mov    $0x5,%eax
  802d05:	e8 e6 fd ff ff       	call   802af0 <nsipc>
}
  802d0a:	83 c4 14             	add    $0x14,%esp
  802d0d:	5b                   	pop    %ebx
  802d0e:	5d                   	pop    %ebp
  802d0f:	c3                   	ret    

00802d10 <nsipc_bind>:
	return r;
}

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802d10:	55                   	push   %ebp
  802d11:	89 e5                	mov    %esp,%ebp
  802d13:	53                   	push   %ebx
  802d14:	83 ec 14             	sub    $0x14,%esp
  802d17:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  802d1a:	8b 45 08             	mov    0x8(%ebp),%eax
  802d1d:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  802d22:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802d26:	8b 45 0c             	mov    0xc(%ebp),%eax
  802d29:	89 44 24 04          	mov    %eax,0x4(%esp)
  802d2d:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  802d34:	e8 bc df ff ff       	call   800cf5 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  802d39:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  802d3f:	b8 02 00 00 00       	mov    $0x2,%eax
  802d44:	e8 a7 fd ff ff       	call   802af0 <nsipc>
}
  802d49:	83 c4 14             	add    $0x14,%esp
  802d4c:	5b                   	pop    %ebx
  802d4d:	5d                   	pop    %ebp
  802d4e:	c3                   	ret    

00802d4f <nsipc_accept>:
	return ipc_recv(NULL, NULL, NULL);
}

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  802d4f:	55                   	push   %ebp
  802d50:	89 e5                	mov    %esp,%ebp
  802d52:	83 ec 18             	sub    $0x18,%esp
  802d55:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  802d58:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int r;

	nsipcbuf.accept.req_s = s;
  802d5b:	8b 45 08             	mov    0x8(%ebp),%eax
  802d5e:	a3 00 70 80 00       	mov    %eax,0x807000
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  802d63:	b8 01 00 00 00       	mov    $0x1,%eax
  802d68:	e8 83 fd ff ff       	call   802af0 <nsipc>
  802d6d:	89 c3                	mov    %eax,%ebx
  802d6f:	85 c0                	test   %eax,%eax
  802d71:	78 25                	js     802d98 <nsipc_accept+0x49>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  802d73:	be 10 70 80 00       	mov    $0x807010,%esi
  802d78:	8b 06                	mov    (%esi),%eax
  802d7a:	89 44 24 08          	mov    %eax,0x8(%esp)
  802d7e:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  802d85:	00 
  802d86:	8b 45 0c             	mov    0xc(%ebp),%eax
  802d89:	89 04 24             	mov    %eax,(%esp)
  802d8c:	e8 64 df ff ff       	call   800cf5 <memmove>
		*addrlen = ret->ret_addrlen;
  802d91:	8b 16                	mov    (%esi),%edx
  802d93:	8b 45 10             	mov    0x10(%ebp),%eax
  802d96:	89 10                	mov    %edx,(%eax)
	}
	return r;
}
  802d98:	89 d8                	mov    %ebx,%eax
  802d9a:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  802d9d:	8b 75 fc             	mov    -0x4(%ebp),%esi
  802da0:	89 ec                	mov    %ebp,%esp
  802da2:	5d                   	pop    %ebp
  802da3:	c3                   	ret    
	...

00802db0 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802db0:	55                   	push   %ebp
  802db1:	89 e5                	mov    %esp,%ebp
  802db3:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  802db6:	8b 15 50 00 c0 ee    	mov    0xeec00050,%edx
  802dbc:	b8 01 00 00 00       	mov    $0x1,%eax
  802dc1:	39 ca                	cmp    %ecx,%edx
  802dc3:	75 04                	jne    802dc9 <ipc_find_env+0x19>
  802dc5:	b0 00                	mov    $0x0,%al
  802dc7:	eb 12                	jmp    802ddb <ipc_find_env+0x2b>
  802dc9:	89 c2                	mov    %eax,%edx
  802dcb:	c1 e2 07             	shl    $0x7,%edx
  802dce:	8d 94 82 50 00 c0 ee 	lea    -0x113fffb0(%edx,%eax,4),%edx
  802dd5:	8b 12                	mov    (%edx),%edx
  802dd7:	39 ca                	cmp    %ecx,%edx
  802dd9:	75 10                	jne    802deb <ipc_find_env+0x3b>
			return envs[i].env_id;
  802ddb:	89 c2                	mov    %eax,%edx
  802ddd:	c1 e2 07             	shl    $0x7,%edx
  802de0:	8d 84 82 48 00 c0 ee 	lea    -0x113fffb8(%edx,%eax,4),%eax
  802de7:	8b 00                	mov    (%eax),%eax
  802de9:	eb 0e                	jmp    802df9 <ipc_find_env+0x49>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802deb:	83 c0 01             	add    $0x1,%eax
  802dee:	3d 00 04 00 00       	cmp    $0x400,%eax
  802df3:	75 d4                	jne    802dc9 <ipc_find_env+0x19>
  802df5:	66 b8 00 00          	mov    $0x0,%ax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  802df9:	5d                   	pop    %ebp
  802dfa:	c3                   	ret    

00802dfb <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802dfb:	55                   	push   %ebp
  802dfc:	89 e5                	mov    %esp,%ebp
  802dfe:	57                   	push   %edi
  802dff:	56                   	push   %esi
  802e00:	53                   	push   %ebx
  802e01:	83 ec 1c             	sub    $0x1c,%esp
  802e04:	8b 75 08             	mov    0x8(%ebp),%esi
  802e07:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802e0a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        int ret;
        while(1){
           if(pg)
  802e0d:	85 db                	test   %ebx,%ebx
  802e0f:	74 19                	je     802e2a <ipc_send+0x2f>
              ret = sys_ipc_try_send(to_env,val,pg,perm);
  802e11:	8b 45 14             	mov    0x14(%ebp),%eax
  802e14:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802e18:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802e1c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802e20:	89 34 24             	mov    %esi,(%esp)
  802e23:	e8 b1 e3 ff ff       	call   8011d9 <sys_ipc_try_send>
  802e28:	eb 1b                	jmp    802e45 <ipc_send+0x4a>
           else
              ret = sys_ipc_try_send(to_env,val,(void*)UTOP,perm);
  802e2a:	8b 45 14             	mov    0x14(%ebp),%eax
  802e2d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802e31:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  802e38:	ee 
  802e39:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802e3d:	89 34 24             	mov    %esi,(%esp)
  802e40:	e8 94 e3 ff ff       	call   8011d9 <sys_ipc_try_send>
           if(ret == 0)
  802e45:	85 c0                	test   %eax,%eax
  802e47:	74 28                	je     802e71 <ipc_send+0x76>
              return;
           if(ret != -E_IPC_NOT_RECV)
  802e49:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802e4c:	74 1c                	je     802e6a <ipc_send+0x6f>
              panic("ipc send error");
  802e4e:	c7 44 24 08 41 37 80 	movl   $0x803741,0x8(%esp)
  802e55:	00 
  802e56:	c7 44 24 04 46 00 00 	movl   $0x46,0x4(%esp)
  802e5d:	00 
  802e5e:	c7 04 24 50 37 80 00 	movl   $0x803750,(%esp)
  802e65:	e8 b2 d2 ff ff       	call   80011c <_panic>
           sys_yield();
  802e6a:	e8 36 e6 ff ff       	call   8014a5 <sys_yield>
        }
  802e6f:	eb 9c                	jmp    802e0d <ipc_send+0x12>
	//panic("ipc_send not implemented");
}
  802e71:	83 c4 1c             	add    $0x1c,%esp
  802e74:	5b                   	pop    %ebx
  802e75:	5e                   	pop    %esi
  802e76:	5f                   	pop    %edi
  802e77:	5d                   	pop    %ebp
  802e78:	c3                   	ret    

00802e79 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802e79:	55                   	push   %ebp
  802e7a:	89 e5                	mov    %esp,%ebp
  802e7c:	56                   	push   %esi
  802e7d:	53                   	push   %ebx
  802e7e:	83 ec 10             	sub    $0x10,%esp
  802e81:	8b 75 08             	mov    0x8(%ebp),%esi
  802e84:	8b 45 0c             	mov    0xc(%ebp),%eax
  802e87:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        int ret;
        if(!pg)
  802e8a:	85 c0                	test   %eax,%eax
  802e8c:	75 0e                	jne    802e9c <ipc_recv+0x23>
           ret = sys_ipc_recv((void*)UTOP);
  802e8e:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  802e95:	e8 d4 e2 ff ff       	call   80116e <sys_ipc_recv>
  802e9a:	eb 08                	jmp    802ea4 <ipc_recv+0x2b>
        else
           ret = sys_ipc_recv(pg);
  802e9c:	89 04 24             	mov    %eax,(%esp)
  802e9f:	e8 ca e2 ff ff       	call   80116e <sys_ipc_recv>
        if(ret == 0){
  802ea4:	85 c0                	test   %eax,%eax
  802ea6:	75 26                	jne    802ece <ipc_recv+0x55>
           if(from_env_store)
  802ea8:	85 f6                	test   %esi,%esi
  802eaa:	74 0a                	je     802eb6 <ipc_recv+0x3d>
              *from_env_store = thisenv->env_ipc_from;
  802eac:	a1 08 50 80 00       	mov    0x805008,%eax
  802eb1:	8b 40 78             	mov    0x78(%eax),%eax
  802eb4:	89 06                	mov    %eax,(%esi)
           if(perm_store)
  802eb6:	85 db                	test   %ebx,%ebx
  802eb8:	74 0a                	je     802ec4 <ipc_recv+0x4b>
              *perm_store = thisenv->env_ipc_perm;
  802eba:	a1 08 50 80 00       	mov    0x805008,%eax
  802ebf:	8b 40 7c             	mov    0x7c(%eax),%eax
  802ec2:	89 03                	mov    %eax,(%ebx)
           return thisenv->env_ipc_value;
  802ec4:	a1 08 50 80 00       	mov    0x805008,%eax
  802ec9:	8b 40 74             	mov    0x74(%eax),%eax
  802ecc:	eb 14                	jmp    802ee2 <ipc_recv+0x69>
        }
        else{
           if(from_env_store)
  802ece:	85 f6                	test   %esi,%esi
  802ed0:	74 06                	je     802ed8 <ipc_recv+0x5f>
              *from_env_store = 0;
  802ed2:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
           if(perm_store)
  802ed8:	85 db                	test   %ebx,%ebx
  802eda:	74 06                	je     802ee2 <ipc_recv+0x69>
              *perm_store = 0;
  802edc:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
           return ret;
        }
	//panic("ipc_recv not implemented");
	return 0;
}
  802ee2:	83 c4 10             	add    $0x10,%esp
  802ee5:	5b                   	pop    %ebx
  802ee6:	5e                   	pop    %esi
  802ee7:	5d                   	pop    %ebp
  802ee8:	c3                   	ret    
  802ee9:	00 00                	add    %al,(%eax)
	...

00802eec <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802eec:	55                   	push   %ebp
  802eed:	89 e5                	mov    %esp,%ebp
	pte_t pte;

	if (!(vpd[PDX(v)] & PTE_P))
  802eef:	8b 45 08             	mov    0x8(%ebp),%eax
  802ef2:	89 c2                	mov    %eax,%edx
  802ef4:	c1 ea 16             	shr    $0x16,%edx
  802ef7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802efe:	f6 c2 01             	test   $0x1,%dl
  802f01:	74 20                	je     802f23 <pageref+0x37>
		return 0;
	pte = vpt[PGNUM(v)];
  802f03:	c1 e8 0c             	shr    $0xc,%eax
  802f06:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802f0d:	a8 01                	test   $0x1,%al
  802f0f:	74 12                	je     802f23 <pageref+0x37>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802f11:	c1 e8 0c             	shr    $0xc,%eax
  802f14:	ba 00 00 00 ef       	mov    $0xef000000,%edx
  802f19:	0f b7 44 c2 04       	movzwl 0x4(%edx,%eax,8),%eax
  802f1e:	0f b7 c0             	movzwl %ax,%eax
  802f21:	eb 05                	jmp    802f28 <pageref+0x3c>
  802f23:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802f28:	5d                   	pop    %ebp
  802f29:	c3                   	ret    
  802f2a:	00 00                	add    %al,(%eax)
  802f2c:	00 00                	add    %al,(%eax)
	...

00802f30 <__udivdi3>:
  802f30:	55                   	push   %ebp
  802f31:	89 e5                	mov    %esp,%ebp
  802f33:	57                   	push   %edi
  802f34:	56                   	push   %esi
  802f35:	83 ec 10             	sub    $0x10,%esp
  802f38:	8b 45 14             	mov    0x14(%ebp),%eax
  802f3b:	8b 55 08             	mov    0x8(%ebp),%edx
  802f3e:	8b 75 10             	mov    0x10(%ebp),%esi
  802f41:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802f44:	85 c0                	test   %eax,%eax
  802f46:	89 55 f0             	mov    %edx,-0x10(%ebp)
  802f49:	75 35                	jne    802f80 <__udivdi3+0x50>
  802f4b:	39 fe                	cmp    %edi,%esi
  802f4d:	77 61                	ja     802fb0 <__udivdi3+0x80>
  802f4f:	85 f6                	test   %esi,%esi
  802f51:	75 0b                	jne    802f5e <__udivdi3+0x2e>
  802f53:	b8 01 00 00 00       	mov    $0x1,%eax
  802f58:	31 d2                	xor    %edx,%edx
  802f5a:	f7 f6                	div    %esi
  802f5c:	89 c6                	mov    %eax,%esi
  802f5e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  802f61:	31 d2                	xor    %edx,%edx
  802f63:	89 f8                	mov    %edi,%eax
  802f65:	f7 f6                	div    %esi
  802f67:	89 c7                	mov    %eax,%edi
  802f69:	89 c8                	mov    %ecx,%eax
  802f6b:	f7 f6                	div    %esi
  802f6d:	89 c1                	mov    %eax,%ecx
  802f6f:	89 fa                	mov    %edi,%edx
  802f71:	89 c8                	mov    %ecx,%eax
  802f73:	83 c4 10             	add    $0x10,%esp
  802f76:	5e                   	pop    %esi
  802f77:	5f                   	pop    %edi
  802f78:	5d                   	pop    %ebp
  802f79:	c3                   	ret    
  802f7a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802f80:	39 f8                	cmp    %edi,%eax
  802f82:	77 1c                	ja     802fa0 <__udivdi3+0x70>
  802f84:	0f bd d0             	bsr    %eax,%edx
  802f87:	83 f2 1f             	xor    $0x1f,%edx
  802f8a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  802f8d:	75 39                	jne    802fc8 <__udivdi3+0x98>
  802f8f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  802f92:	0f 86 a0 00 00 00    	jbe    803038 <__udivdi3+0x108>
  802f98:	39 f8                	cmp    %edi,%eax
  802f9a:	0f 82 98 00 00 00    	jb     803038 <__udivdi3+0x108>
  802fa0:	31 ff                	xor    %edi,%edi
  802fa2:	31 c9                	xor    %ecx,%ecx
  802fa4:	89 c8                	mov    %ecx,%eax
  802fa6:	89 fa                	mov    %edi,%edx
  802fa8:	83 c4 10             	add    $0x10,%esp
  802fab:	5e                   	pop    %esi
  802fac:	5f                   	pop    %edi
  802fad:	5d                   	pop    %ebp
  802fae:	c3                   	ret    
  802faf:	90                   	nop
  802fb0:	89 d1                	mov    %edx,%ecx
  802fb2:	89 fa                	mov    %edi,%edx
  802fb4:	89 c8                	mov    %ecx,%eax
  802fb6:	31 ff                	xor    %edi,%edi
  802fb8:	f7 f6                	div    %esi
  802fba:	89 c1                	mov    %eax,%ecx
  802fbc:	89 fa                	mov    %edi,%edx
  802fbe:	89 c8                	mov    %ecx,%eax
  802fc0:	83 c4 10             	add    $0x10,%esp
  802fc3:	5e                   	pop    %esi
  802fc4:	5f                   	pop    %edi
  802fc5:	5d                   	pop    %ebp
  802fc6:	c3                   	ret    
  802fc7:	90                   	nop
  802fc8:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  802fcc:	89 f2                	mov    %esi,%edx
  802fce:	d3 e0                	shl    %cl,%eax
  802fd0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  802fd3:	b8 20 00 00 00       	mov    $0x20,%eax
  802fd8:	2b 45 f4             	sub    -0xc(%ebp),%eax
  802fdb:	89 c1                	mov    %eax,%ecx
  802fdd:	d3 ea                	shr    %cl,%edx
  802fdf:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  802fe3:	0b 55 ec             	or     -0x14(%ebp),%edx
  802fe6:	d3 e6                	shl    %cl,%esi
  802fe8:	89 c1                	mov    %eax,%ecx
  802fea:	89 75 e8             	mov    %esi,-0x18(%ebp)
  802fed:	89 fe                	mov    %edi,%esi
  802fef:	d3 ee                	shr    %cl,%esi
  802ff1:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  802ff5:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802ff8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802ffb:	d3 e7                	shl    %cl,%edi
  802ffd:	89 c1                	mov    %eax,%ecx
  802fff:	d3 ea                	shr    %cl,%edx
  803001:	09 d7                	or     %edx,%edi
  803003:	89 f2                	mov    %esi,%edx
  803005:	89 f8                	mov    %edi,%eax
  803007:	f7 75 ec             	divl   -0x14(%ebp)
  80300a:	89 d6                	mov    %edx,%esi
  80300c:	89 c7                	mov    %eax,%edi
  80300e:	f7 65 e8             	mull   -0x18(%ebp)
  803011:	39 d6                	cmp    %edx,%esi
  803013:	89 55 ec             	mov    %edx,-0x14(%ebp)
  803016:	72 30                	jb     803048 <__udivdi3+0x118>
  803018:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80301b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80301f:	d3 e2                	shl    %cl,%edx
  803021:	39 c2                	cmp    %eax,%edx
  803023:	73 05                	jae    80302a <__udivdi3+0xfa>
  803025:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  803028:	74 1e                	je     803048 <__udivdi3+0x118>
  80302a:	89 f9                	mov    %edi,%ecx
  80302c:	31 ff                	xor    %edi,%edi
  80302e:	e9 71 ff ff ff       	jmp    802fa4 <__udivdi3+0x74>
  803033:	90                   	nop
  803034:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803038:	31 ff                	xor    %edi,%edi
  80303a:	b9 01 00 00 00       	mov    $0x1,%ecx
  80303f:	e9 60 ff ff ff       	jmp    802fa4 <__udivdi3+0x74>
  803044:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803048:	8d 4f ff             	lea    -0x1(%edi),%ecx
  80304b:	31 ff                	xor    %edi,%edi
  80304d:	89 c8                	mov    %ecx,%eax
  80304f:	89 fa                	mov    %edi,%edx
  803051:	83 c4 10             	add    $0x10,%esp
  803054:	5e                   	pop    %esi
  803055:	5f                   	pop    %edi
  803056:	5d                   	pop    %ebp
  803057:	c3                   	ret    
	...

00803060 <__umoddi3>:
  803060:	55                   	push   %ebp
  803061:	89 e5                	mov    %esp,%ebp
  803063:	57                   	push   %edi
  803064:	56                   	push   %esi
  803065:	83 ec 20             	sub    $0x20,%esp
  803068:	8b 55 14             	mov    0x14(%ebp),%edx
  80306b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80306e:	8b 7d 10             	mov    0x10(%ebp),%edi
  803071:	8b 75 0c             	mov    0xc(%ebp),%esi
  803074:	85 d2                	test   %edx,%edx
  803076:	89 c8                	mov    %ecx,%eax
  803078:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80307b:	75 13                	jne    803090 <__umoddi3+0x30>
  80307d:	39 f7                	cmp    %esi,%edi
  80307f:	76 3f                	jbe    8030c0 <__umoddi3+0x60>
  803081:	89 f2                	mov    %esi,%edx
  803083:	f7 f7                	div    %edi
  803085:	89 d0                	mov    %edx,%eax
  803087:	31 d2                	xor    %edx,%edx
  803089:	83 c4 20             	add    $0x20,%esp
  80308c:	5e                   	pop    %esi
  80308d:	5f                   	pop    %edi
  80308e:	5d                   	pop    %ebp
  80308f:	c3                   	ret    
  803090:	39 f2                	cmp    %esi,%edx
  803092:	77 4c                	ja     8030e0 <__umoddi3+0x80>
  803094:	0f bd ca             	bsr    %edx,%ecx
  803097:	83 f1 1f             	xor    $0x1f,%ecx
  80309a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80309d:	75 51                	jne    8030f0 <__umoddi3+0x90>
  80309f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  8030a2:	0f 87 e0 00 00 00    	ja     803188 <__umoddi3+0x128>
  8030a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8030ab:	29 f8                	sub    %edi,%eax
  8030ad:	19 d6                	sbb    %edx,%esi
  8030af:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8030b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8030b5:	89 f2                	mov    %esi,%edx
  8030b7:	83 c4 20             	add    $0x20,%esp
  8030ba:	5e                   	pop    %esi
  8030bb:	5f                   	pop    %edi
  8030bc:	5d                   	pop    %ebp
  8030bd:	c3                   	ret    
  8030be:	66 90                	xchg   %ax,%ax
  8030c0:	85 ff                	test   %edi,%edi
  8030c2:	75 0b                	jne    8030cf <__umoddi3+0x6f>
  8030c4:	b8 01 00 00 00       	mov    $0x1,%eax
  8030c9:	31 d2                	xor    %edx,%edx
  8030cb:	f7 f7                	div    %edi
  8030cd:	89 c7                	mov    %eax,%edi
  8030cf:	89 f0                	mov    %esi,%eax
  8030d1:	31 d2                	xor    %edx,%edx
  8030d3:	f7 f7                	div    %edi
  8030d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8030d8:	f7 f7                	div    %edi
  8030da:	eb a9                	jmp    803085 <__umoddi3+0x25>
  8030dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8030e0:	89 c8                	mov    %ecx,%eax
  8030e2:	89 f2                	mov    %esi,%edx
  8030e4:	83 c4 20             	add    $0x20,%esp
  8030e7:	5e                   	pop    %esi
  8030e8:	5f                   	pop    %edi
  8030e9:	5d                   	pop    %ebp
  8030ea:	c3                   	ret    
  8030eb:	90                   	nop
  8030ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8030f0:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8030f4:	d3 e2                	shl    %cl,%edx
  8030f6:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8030f9:	ba 20 00 00 00       	mov    $0x20,%edx
  8030fe:	2b 55 f0             	sub    -0x10(%ebp),%edx
  803101:	89 55 ec             	mov    %edx,-0x14(%ebp)
  803104:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  803108:	89 fa                	mov    %edi,%edx
  80310a:	d3 ea                	shr    %cl,%edx
  80310c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  803110:	0b 55 f4             	or     -0xc(%ebp),%edx
  803113:	d3 e7                	shl    %cl,%edi
  803115:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  803119:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80311c:	89 f2                	mov    %esi,%edx
  80311e:	89 7d e8             	mov    %edi,-0x18(%ebp)
  803121:	89 c7                	mov    %eax,%edi
  803123:	d3 ea                	shr    %cl,%edx
  803125:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  803129:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80312c:	89 c2                	mov    %eax,%edx
  80312e:	d3 e6                	shl    %cl,%esi
  803130:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  803134:	d3 ea                	shr    %cl,%edx
  803136:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80313a:	09 d6                	or     %edx,%esi
  80313c:	89 f0                	mov    %esi,%eax
  80313e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  803141:	d3 e7                	shl    %cl,%edi
  803143:	89 f2                	mov    %esi,%edx
  803145:	f7 75 f4             	divl   -0xc(%ebp)
  803148:	89 d6                	mov    %edx,%esi
  80314a:	f7 65 e8             	mull   -0x18(%ebp)
  80314d:	39 d6                	cmp    %edx,%esi
  80314f:	72 2b                	jb     80317c <__umoddi3+0x11c>
  803151:	39 c7                	cmp    %eax,%edi
  803153:	72 23                	jb     803178 <__umoddi3+0x118>
  803155:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  803159:	29 c7                	sub    %eax,%edi
  80315b:	19 d6                	sbb    %edx,%esi
  80315d:	89 f0                	mov    %esi,%eax
  80315f:	89 f2                	mov    %esi,%edx
  803161:	d3 ef                	shr    %cl,%edi
  803163:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  803167:	d3 e0                	shl    %cl,%eax
  803169:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80316d:	09 f8                	or     %edi,%eax
  80316f:	d3 ea                	shr    %cl,%edx
  803171:	83 c4 20             	add    $0x20,%esp
  803174:	5e                   	pop    %esi
  803175:	5f                   	pop    %edi
  803176:	5d                   	pop    %ebp
  803177:	c3                   	ret    
  803178:	39 d6                	cmp    %edx,%esi
  80317a:	75 d9                	jne    803155 <__umoddi3+0xf5>
  80317c:	2b 45 e8             	sub    -0x18(%ebp),%eax
  80317f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  803182:	eb d1                	jmp    803155 <__umoddi3+0xf5>
  803184:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803188:	39 f2                	cmp    %esi,%edx
  80318a:	0f 82 18 ff ff ff    	jb     8030a8 <__umoddi3+0x48>
  803190:	e9 1d ff ff ff       	jmp    8030b2 <__umoddi3+0x52>
