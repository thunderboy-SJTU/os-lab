
obj/user/breakpoint.debug:     file format elf32-i386


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
  80002c:	e8 57 00 00 00       	call   800088 <libmain>
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
  800037:	83 ec 28             	sub    $0x28,%esp
	int a;
	a=10;
  80003a:	c7 45 f4 0a 00 00 00 	movl   $0xa,-0xc(%ebp)
	cprintf("At first , a equals %d\n",a);
  800041:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
  800048:	00 
  800049:	c7 04 24 80 27 80 00 	movl   $0x802780,(%esp)
  800050:	e8 04 01 00 00       	call   800159 <cprintf>
	cprintf("&a equals 0x%x\n",&a);
  800055:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800058:	89 44 24 04          	mov    %eax,0x4(%esp)
  80005c:	c7 04 24 98 27 80 00 	movl   $0x802798,(%esp)
  800063:	e8 f1 00 00 00       	call   800159 <cprintf>
	asm volatile("int $3");
  800068:	cc                   	int3   
	// Try single-step here
	a=20;
  800069:	c7 45 f4 14 00 00 00 	movl   $0x14,-0xc(%ebp)
	cprintf("Finally , a equals %d\n",a);
  800070:	c7 44 24 04 14 00 00 	movl   $0x14,0x4(%esp)
  800077:	00 
  800078:	c7 04 24 a8 27 80 00 	movl   $0x8027a8,(%esp)
  80007f:	e8 d5 00 00 00       	call   800159 <cprintf>
}
  800084:	c9                   	leave  
  800085:	c3                   	ret    
	...

00800088 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800088:	55                   	push   %ebp
  800089:	89 e5                	mov    %esp,%ebp
  80008b:	83 ec 18             	sub    $0x18,%esp
  80008e:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800091:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800094:	8b 75 08             	mov    0x8(%ebp),%esi
  800097:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  80009a:	e8 08 14 00 00       	call   8014a7 <sys_getenvid>
  80009f:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000a4:	89 c2                	mov    %eax,%edx
  8000a6:	c1 e2 07             	shl    $0x7,%edx
  8000a9:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  8000b0:	a3 08 40 80 00       	mov    %eax,0x804008
        //cprintf("ENVX sys_get_envid(): %d\n",ENVX(sys_getenvid()));
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000b5:	85 f6                	test   %esi,%esi
  8000b7:	7e 07                	jle    8000c0 <libmain+0x38>
		binaryname = argv[0];
  8000b9:	8b 03                	mov    (%ebx),%eax
  8000bb:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000c0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000c4:	89 34 24             	mov    %esi,(%esp)
  8000c7:	e8 68 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000cc:	e8 0b 00 00 00       	call   8000dc <exit>
}
  8000d1:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8000d4:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8000d7:	89 ec                	mov    %ebp,%esp
  8000d9:	5d                   	pop    %ebp
  8000da:	c3                   	ret    
	...

008000dc <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000dc:	55                   	push   %ebp
  8000dd:	89 e5                	mov    %esp,%ebp
  8000df:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8000e2:	e8 54 19 00 00       	call   801a3b <close_all>
	sys_env_destroy(0);
  8000e7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000ee:	e8 f4 13 00 00       	call   8014e7 <sys_env_destroy>
}
  8000f3:	c9                   	leave  
  8000f4:	c3                   	ret    
  8000f5:	00 00                	add    %al,(%eax)
	...

008000f8 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  8000f8:	55                   	push   %ebp
  8000f9:	89 e5                	mov    %esp,%ebp
  8000fb:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800101:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800108:	00 00 00 
	b.cnt = 0;
  80010b:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800112:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800115:	8b 45 0c             	mov    0xc(%ebp),%eax
  800118:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80011c:	8b 45 08             	mov    0x8(%ebp),%eax
  80011f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800123:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800129:	89 44 24 04          	mov    %eax,0x4(%esp)
  80012d:	c7 04 24 73 01 80 00 	movl   $0x800173,(%esp)
  800134:	e8 d3 01 00 00       	call   80030c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800139:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80013f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800143:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800149:	89 04 24             	mov    %eax,(%esp)
  80014c:	e8 6b 0d 00 00       	call   800ebc <sys_cputs>

	return b.cnt;
}
  800151:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800157:	c9                   	leave  
  800158:	c3                   	ret    

00800159 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800159:	55                   	push   %ebp
  80015a:	89 e5                	mov    %esp,%ebp
  80015c:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  80015f:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  800162:	89 44 24 04          	mov    %eax,0x4(%esp)
  800166:	8b 45 08             	mov    0x8(%ebp),%eax
  800169:	89 04 24             	mov    %eax,(%esp)
  80016c:	e8 87 ff ff ff       	call   8000f8 <vcprintf>
	va_end(ap);

	return cnt;
}
  800171:	c9                   	leave  
  800172:	c3                   	ret    

00800173 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800173:	55                   	push   %ebp
  800174:	89 e5                	mov    %esp,%ebp
  800176:	53                   	push   %ebx
  800177:	83 ec 14             	sub    $0x14,%esp
  80017a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80017d:	8b 03                	mov    (%ebx),%eax
  80017f:	8b 55 08             	mov    0x8(%ebp),%edx
  800182:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800186:	83 c0 01             	add    $0x1,%eax
  800189:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80018b:	3d ff 00 00 00       	cmp    $0xff,%eax
  800190:	75 19                	jne    8001ab <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800192:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800199:	00 
  80019a:	8d 43 08             	lea    0x8(%ebx),%eax
  80019d:	89 04 24             	mov    %eax,(%esp)
  8001a0:	e8 17 0d 00 00       	call   800ebc <sys_cputs>
		b->idx = 0;
  8001a5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001ab:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001af:	83 c4 14             	add    $0x14,%esp
  8001b2:	5b                   	pop    %ebx
  8001b3:	5d                   	pop    %ebp
  8001b4:	c3                   	ret    
	...

008001c0 <printnum_v2>:
 */

static void 
printnum_v2(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001c0:	55                   	push   %ebp
  8001c1:	89 e5                	mov    %esp,%ebp
  8001c3:	57                   	push   %edi
  8001c4:	56                   	push   %esi
  8001c5:	53                   	push   %ebx
  8001c6:	83 ec 4c             	sub    $0x4c,%esp
  8001c9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8001cc:	89 d6                	mov    %edx,%esi
  8001ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8001d1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001d4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001d7:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8001da:	8b 45 10             	mov    0x10(%ebp),%eax
  8001dd:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8001e0:	8b 7d 18             	mov    0x18(%ebp),%edi
    if (num >= base) {
  8001e3:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8001e6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001eb:	39 d1                	cmp    %edx,%ecx
  8001ed:	72 07                	jb     8001f6 <printnum_v2+0x36>
  8001ef:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8001f2:	39 d0                	cmp    %edx,%eax
  8001f4:	77 5f                	ja     800255 <printnum_v2+0x95>
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
  8001f6:	89 7c 24 10          	mov    %edi,0x10(%esp)
  8001fa:	83 eb 01             	sub    $0x1,%ebx
  8001fd:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800201:	89 44 24 08          	mov    %eax,0x8(%esp)
  800205:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800209:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  80020d:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800210:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  800213:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800216:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80021a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800221:	00 
  800222:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800225:	89 04 24             	mov    %eax,(%esp)
  800228:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80022b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80022f:	e8 dc 22 00 00       	call   802510 <__udivdi3>
  800234:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800237:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  80023a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80023e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800242:	89 04 24             	mov    %eax,(%esp)
  800245:	89 54 24 04          	mov    %edx,0x4(%esp)
  800249:	89 f2                	mov    %esi,%edx
  80024b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80024e:	e8 6d ff ff ff       	call   8001c0 <printnum_v2>
  800253:	eb 1e                	jmp    800273 <printnum_v2+0xb3>
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
  800255:	83 ff 2d             	cmp    $0x2d,%edi
  800258:	74 19                	je     800273 <printnum_v2+0xb3>
		while (--width > 0)
  80025a:	83 eb 01             	sub    $0x1,%ebx
  80025d:	85 db                	test   %ebx,%ebx
  80025f:	90                   	nop
  800260:	7e 11                	jle    800273 <printnum_v2+0xb3>
			putch(padc, putdat);
  800262:	89 74 24 04          	mov    %esi,0x4(%esp)
  800266:	89 3c 24             	mov    %edi,(%esp)
  800269:	ff 55 e4             	call   *-0x1c(%ebp)
    if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
		while (--width > 0)
  80026c:	83 eb 01             	sub    $0x1,%ebx
  80026f:	85 db                	test   %ebx,%ebx
  800271:	7f ef                	jg     800262 <printnum_v2+0xa2>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800273:	89 74 24 04          	mov    %esi,0x4(%esp)
  800277:	8b 74 24 04          	mov    0x4(%esp),%esi
  80027b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80027e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800282:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800289:	00 
  80028a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80028d:	89 14 24             	mov    %edx,(%esp)
  800290:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800293:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800297:	e8 a4 23 00 00       	call   802640 <__umoddi3>
  80029c:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002a0:	0f be 80 c9 27 80 00 	movsbl 0x8027c9(%eax),%eax
  8002a7:	89 04 24             	mov    %eax,(%esp)
  8002aa:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8002ad:	83 c4 4c             	add    $0x4c,%esp
  8002b0:	5b                   	pop    %ebx
  8002b1:	5e                   	pop    %esi
  8002b2:	5f                   	pop    %edi
  8002b3:	5d                   	pop    %ebp
  8002b4:	c3                   	ret    

008002b5 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002b5:	55                   	push   %ebp
  8002b6:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002b8:	83 fa 01             	cmp    $0x1,%edx
  8002bb:	7e 0e                	jle    8002cb <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002bd:	8b 10                	mov    (%eax),%edx
  8002bf:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002c2:	89 08                	mov    %ecx,(%eax)
  8002c4:	8b 02                	mov    (%edx),%eax
  8002c6:	8b 52 04             	mov    0x4(%edx),%edx
  8002c9:	eb 22                	jmp    8002ed <getuint+0x38>
	else if (lflag)
  8002cb:	85 d2                	test   %edx,%edx
  8002cd:	74 10                	je     8002df <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002cf:	8b 10                	mov    (%eax),%edx
  8002d1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002d4:	89 08                	mov    %ecx,(%eax)
  8002d6:	8b 02                	mov    (%edx),%eax
  8002d8:	ba 00 00 00 00       	mov    $0x0,%edx
  8002dd:	eb 0e                	jmp    8002ed <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002df:	8b 10                	mov    (%eax),%edx
  8002e1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002e4:	89 08                	mov    %ecx,(%eax)
  8002e6:	8b 02                	mov    (%edx),%eax
  8002e8:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002ed:	5d                   	pop    %ebp
  8002ee:	c3                   	ret    

008002ef <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002ef:	55                   	push   %ebp
  8002f0:	89 e5                	mov    %esp,%ebp
  8002f2:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002f5:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002f9:	8b 10                	mov    (%eax),%edx
  8002fb:	3b 50 04             	cmp    0x4(%eax),%edx
  8002fe:	73 0a                	jae    80030a <sprintputch+0x1b>
		*b->buf++ = ch;
  800300:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800303:	88 0a                	mov    %cl,(%edx)
  800305:	83 c2 01             	add    $0x1,%edx
  800308:	89 10                	mov    %edx,(%eax)
}
  80030a:	5d                   	pop    %ebp
  80030b:	c3                   	ret    

0080030c <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80030c:	55                   	push   %ebp
  80030d:	89 e5                	mov    %esp,%ebp
  80030f:	57                   	push   %edi
  800310:	56                   	push   %esi
  800311:	53                   	push   %ebx
  800312:	83 ec 6c             	sub    $0x6c,%esp
  800315:	8b 7d 10             	mov    0x10(%ebp),%edi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800318:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  80031f:	eb 1a                	jmp    80033b <vprintfmt+0x2f>
	int base, lflag, width, precision, altflag,signflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800321:	85 c0                	test   %eax,%eax
  800323:	0f 84 66 06 00 00    	je     80098f <vprintfmt+0x683>
				return;
			putch(ch, putdat);
  800329:	8b 55 0c             	mov    0xc(%ebp),%edx
  80032c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800330:	89 04 24             	mov    %eax,(%esp)
  800333:	ff 55 08             	call   *0x8(%ebp)
  800336:	eb 03                	jmp    80033b <vprintfmt+0x2f>
  800338:	8b 7d e4             	mov    -0x1c(%ebp),%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag,signflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80033b:	0f b6 07             	movzbl (%edi),%eax
  80033e:	83 c7 01             	add    $0x1,%edi
  800341:	83 f8 25             	cmp    $0x25,%eax
  800344:	75 db                	jne    800321 <vprintfmt+0x15>
  800346:	c6 45 cc 20          	movb   $0x20,-0x34(%ebp)
  80034a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80034f:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  800356:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
  80035b:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800362:	be 00 00 00 00       	mov    $0x0,%esi
  800367:	eb 06                	jmp    80036f <vprintfmt+0x63>
  800369:	c6 45 cc 2d          	movb   $0x2d,-0x34(%ebp)
  80036d:	89 c7                	mov    %eax,%edi
		precision = -1;
		lflag = 0;
		altflag = 0;
                signflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80036f:	0f b6 17             	movzbl (%edi),%edx
  800372:	0f b6 c2             	movzbl %dl,%eax
  800375:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800378:	8d 47 01             	lea    0x1(%edi),%eax
  80037b:	83 ea 23             	sub    $0x23,%edx
  80037e:	80 fa 55             	cmp    $0x55,%dl
  800381:	0f 87 60 05 00 00    	ja     8008e7 <vprintfmt+0x5db>
  800387:	0f b6 d2             	movzbl %dl,%edx
  80038a:	ff 24 95 a0 29 80 00 	jmp    *0x8029a0(,%edx,4)
  800391:	b9 01 00 00 00       	mov    $0x1,%ecx
  800396:	eb d5                	jmp    80036d <vprintfmt+0x61>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800398:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80039b:	83 eb 30             	sub    $0x30,%ebx
				ch = *fmt;
  80039e:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  8003a1:	8d 7a d0             	lea    -0x30(%edx),%edi
  8003a4:	83 ff 09             	cmp    $0x9,%edi
  8003a7:	76 08                	jbe    8003b1 <vprintfmt+0xa5>
  8003a9:	eb 40                	jmp    8003eb <vprintfmt+0xdf>
  8003ab:	c6 45 cc 30          	movb   $0x30,-0x34(%ebp)
                        signflag = 1;
                        goto reswitch;
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
			goto reswitch;
  8003af:	eb bc                	jmp    80036d <vprintfmt+0x61>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003b1:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  8003b4:	8d 1c 9b             	lea    (%ebx,%ebx,4),%ebx
  8003b7:	8d 5c 5a d0          	lea    -0x30(%edx,%ebx,2),%ebx
				ch = *fmt;
  8003bb:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  8003be:	8d 7a d0             	lea    -0x30(%edx),%edi
  8003c1:	83 ff 09             	cmp    $0x9,%edi
  8003c4:	76 eb                	jbe    8003b1 <vprintfmt+0xa5>
  8003c6:	eb 23                	jmp    8003eb <vprintfmt+0xdf>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003c8:	8b 55 14             	mov    0x14(%ebp),%edx
  8003cb:	8d 5a 04             	lea    0x4(%edx),%ebx
  8003ce:	89 5d 14             	mov    %ebx,0x14(%ebp)
  8003d1:	8b 1a                	mov    (%edx),%ebx
			goto process_precision;
  8003d3:	eb 16                	jmp    8003eb <vprintfmt+0xdf>

		case '.':
			if (width < 0)
  8003d5:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8003d8:	c1 fa 1f             	sar    $0x1f,%edx
  8003db:	f7 d2                	not    %edx
  8003dd:	21 55 d8             	and    %edx,-0x28(%ebp)
  8003e0:	eb 8b                	jmp    80036d <vprintfmt+0x61>
  8003e2:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  8003e9:	eb 82                	jmp    80036d <vprintfmt+0x61>

		process_precision:
			if (width < 0)
  8003eb:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8003ef:	0f 89 78 ff ff ff    	jns    80036d <vprintfmt+0x61>
  8003f5:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8003f8:	8b 5d c8             	mov    -0x38(%ebp),%ebx
  8003fb:	e9 6d ff ff ff       	jmp    80036d <vprintfmt+0x61>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800400:	83 c6 01             	add    $0x1,%esi
			goto reswitch;
  800403:	e9 65 ff ff ff       	jmp    80036d <vprintfmt+0x61>
  800408:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80040b:	8b 45 14             	mov    0x14(%ebp),%eax
  80040e:	8d 50 04             	lea    0x4(%eax),%edx
  800411:	89 55 14             	mov    %edx,0x14(%ebp)
  800414:	8b 55 0c             	mov    0xc(%ebp),%edx
  800417:	89 54 24 04          	mov    %edx,0x4(%esp)
  80041b:	8b 00                	mov    (%eax),%eax
  80041d:	89 04 24             	mov    %eax,(%esp)
  800420:	ff 55 08             	call   *0x8(%ebp)
  800423:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;
  800426:	e9 10 ff ff ff       	jmp    80033b <vprintfmt+0x2f>
  80042b:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  80042e:	8b 45 14             	mov    0x14(%ebp),%eax
  800431:	8d 50 04             	lea    0x4(%eax),%edx
  800434:	89 55 14             	mov    %edx,0x14(%ebp)
  800437:	8b 00                	mov    (%eax),%eax
  800439:	89 c2                	mov    %eax,%edx
  80043b:	c1 fa 1f             	sar    $0x1f,%edx
  80043e:	31 d0                	xor    %edx,%eax
  800440:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800442:	83 f8 0f             	cmp    $0xf,%eax
  800445:	7f 0b                	jg     800452 <vprintfmt+0x146>
  800447:	8b 14 85 00 2b 80 00 	mov    0x802b00(,%eax,4),%edx
  80044e:	85 d2                	test   %edx,%edx
  800450:	75 26                	jne    800478 <vprintfmt+0x16c>
				printfmt(putch, putdat, "error %d", err);
  800452:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800456:	c7 44 24 08 da 27 80 	movl   $0x8027da,0x8(%esp)
  80045d:	00 
  80045e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800461:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800465:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800468:	89 1c 24             	mov    %ebx,(%esp)
  80046b:	e8 a7 05 00 00       	call   800a17 <printfmt>
  800470:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800473:	e9 c3 fe ff ff       	jmp    80033b <vprintfmt+0x2f>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800478:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80047c:	c7 44 24 08 1e 2c 80 	movl   $0x802c1e,0x8(%esp)
  800483:	00 
  800484:	8b 45 0c             	mov    0xc(%ebp),%eax
  800487:	89 44 24 04          	mov    %eax,0x4(%esp)
  80048b:	8b 55 08             	mov    0x8(%ebp),%edx
  80048e:	89 14 24             	mov    %edx,(%esp)
  800491:	e8 81 05 00 00       	call   800a17 <printfmt>
  800496:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800499:	e9 9d fe ff ff       	jmp    80033b <vprintfmt+0x2f>
  80049e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004a1:	89 c7                	mov    %eax,%edi
  8004a3:	89 d9                	mov    %ebx,%ecx
  8004a5:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8004a8:	89 45 c0             	mov    %eax,-0x40(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ae:	8d 50 04             	lea    0x4(%eax),%edx
  8004b1:	89 55 14             	mov    %edx,0x14(%ebp)
  8004b4:	8b 30                	mov    (%eax),%esi
  8004b6:	85 f6                	test   %esi,%esi
  8004b8:	75 05                	jne    8004bf <vprintfmt+0x1b3>
  8004ba:	be e3 27 80 00       	mov    $0x8027e3,%esi
				p = "(null)";
			if (width > 0 && padc != '-')
  8004bf:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
  8004c3:	7e 06                	jle    8004cb <vprintfmt+0x1bf>
  8004c5:	80 7d cc 2d          	cmpb   $0x2d,-0x34(%ebp)
  8004c9:	75 10                	jne    8004db <vprintfmt+0x1cf>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004cb:	0f be 06             	movsbl (%esi),%eax
  8004ce:	85 c0                	test   %eax,%eax
  8004d0:	0f 85 a2 00 00 00    	jne    800578 <vprintfmt+0x26c>
  8004d6:	e9 92 00 00 00       	jmp    80056d <vprintfmt+0x261>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004db:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8004df:	89 34 24             	mov    %esi,(%esp)
  8004e2:	e8 74 05 00 00       	call   800a5b <strnlen>
  8004e7:	8b 55 c0             	mov    -0x40(%ebp),%edx
  8004ea:	29 c2                	sub    %eax,%edx
  8004ec:	89 55 d8             	mov    %edx,-0x28(%ebp)
  8004ef:	85 d2                	test   %edx,%edx
  8004f1:	7e d8                	jle    8004cb <vprintfmt+0x1bf>
					putch(padc, putdat);
  8004f3:	0f be 4d cc          	movsbl -0x34(%ebp),%ecx
  8004f7:	89 5d c0             	mov    %ebx,-0x40(%ebp)
  8004fa:	89 d3                	mov    %edx,%ebx
  8004fc:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8004ff:	89 7d bc             	mov    %edi,-0x44(%ebp)
  800502:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800505:	89 ce                	mov    %ecx,%esi
  800507:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80050b:	89 34 24             	mov    %esi,(%esp)
  80050e:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800511:	83 eb 01             	sub    $0x1,%ebx
  800514:	85 db                	test   %ebx,%ebx
  800516:	7f ef                	jg     800507 <vprintfmt+0x1fb>
  800518:	8b 5d c0             	mov    -0x40(%ebp),%ebx
  80051b:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80051e:	8b 7d bc             	mov    -0x44(%ebp),%edi
  800521:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800528:	eb a1                	jmp    8004cb <vprintfmt+0x1bf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80052a:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  80052e:	74 1b                	je     80054b <vprintfmt+0x23f>
  800530:	8d 50 e0             	lea    -0x20(%eax),%edx
  800533:	83 fa 5e             	cmp    $0x5e,%edx
  800536:	76 13                	jbe    80054b <vprintfmt+0x23f>
					putch('?', putdat);
  800538:	8b 45 0c             	mov    0xc(%ebp),%eax
  80053b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80053f:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800546:	ff 55 08             	call   *0x8(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800549:	eb 0d                	jmp    800558 <vprintfmt+0x24c>
					putch('?', putdat);
				else
					putch(ch, putdat);
  80054b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80054e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800552:	89 04 24             	mov    %eax,(%esp)
  800555:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800558:	83 ef 01             	sub    $0x1,%edi
  80055b:	0f be 06             	movsbl (%esi),%eax
  80055e:	85 c0                	test   %eax,%eax
  800560:	74 05                	je     800567 <vprintfmt+0x25b>
  800562:	83 c6 01             	add    $0x1,%esi
  800565:	eb 1a                	jmp    800581 <vprintfmt+0x275>
  800567:	89 7d d8             	mov    %edi,-0x28(%ebp)
  80056a:	8b 7d cc             	mov    -0x34(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80056d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800571:	7f 1f                	jg     800592 <vprintfmt+0x286>
  800573:	e9 c0 fd ff ff       	jmp    800338 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800578:	83 c6 01             	add    $0x1,%esi
  80057b:	89 7d cc             	mov    %edi,-0x34(%ebp)
  80057e:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800581:	85 db                	test   %ebx,%ebx
  800583:	78 a5                	js     80052a <vprintfmt+0x21e>
  800585:	83 eb 01             	sub    $0x1,%ebx
  800588:	79 a0                	jns    80052a <vprintfmt+0x21e>
  80058a:	89 7d d8             	mov    %edi,-0x28(%ebp)
  80058d:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800590:	eb db                	jmp    80056d <vprintfmt+0x261>
  800592:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800595:	8b 75 0c             	mov    0xc(%ebp),%esi
  800598:	89 7d d8             	mov    %edi,-0x28(%ebp)
  80059b:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80059e:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005a2:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8005a9:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005ab:	83 eb 01             	sub    $0x1,%ebx
  8005ae:	85 db                	test   %ebx,%ebx
  8005b0:	7f ec                	jg     80059e <vprintfmt+0x292>
  8005b2:	8b 7d d8             	mov    -0x28(%ebp),%edi
  8005b5:	e9 81 fd ff ff       	jmp    80033b <vprintfmt+0x2f>
  8005ba:	89 45 e4             	mov    %eax,-0x1c(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005bd:	83 fe 01             	cmp    $0x1,%esi
  8005c0:	7e 10                	jle    8005d2 <vprintfmt+0x2c6>
		return va_arg(*ap, long long);
  8005c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c5:	8d 50 08             	lea    0x8(%eax),%edx
  8005c8:	89 55 14             	mov    %edx,0x14(%ebp)
  8005cb:	8b 18                	mov    (%eax),%ebx
  8005cd:	8b 70 04             	mov    0x4(%eax),%esi
  8005d0:	eb 26                	jmp    8005f8 <vprintfmt+0x2ec>
	else if (lflag)
  8005d2:	85 f6                	test   %esi,%esi
  8005d4:	74 12                	je     8005e8 <vprintfmt+0x2dc>
		return va_arg(*ap, long);
  8005d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d9:	8d 50 04             	lea    0x4(%eax),%edx
  8005dc:	89 55 14             	mov    %edx,0x14(%ebp)
  8005df:	8b 18                	mov    (%eax),%ebx
  8005e1:	89 de                	mov    %ebx,%esi
  8005e3:	c1 fe 1f             	sar    $0x1f,%esi
  8005e6:	eb 10                	jmp    8005f8 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  8005e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005eb:	8d 50 04             	lea    0x4(%eax),%edx
  8005ee:	89 55 14             	mov    %edx,0x14(%ebp)
  8005f1:	8b 18                	mov    (%eax),%ebx
  8005f3:	89 de                	mov    %ebx,%esi
  8005f5:	c1 fe 1f             	sar    $0x1f,%esi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
                        if(signflag == 1){
  8005f8:	83 f9 01             	cmp    $0x1,%ecx
  8005fb:	75 1e                	jne    80061b <vprintfmt+0x30f>
                               if((long long)num > 0){
  8005fd:	85 f6                	test   %esi,%esi
  8005ff:	78 1a                	js     80061b <vprintfmt+0x30f>
  800601:	85 f6                	test   %esi,%esi
  800603:	7f 05                	jg     80060a <vprintfmt+0x2fe>
  800605:	83 fb 00             	cmp    $0x0,%ebx
  800608:	76 11                	jbe    80061b <vprintfmt+0x30f>
                                   putch('+',putdat);
  80060a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80060d:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800611:	c7 04 24 2b 00 00 00 	movl   $0x2b,(%esp)
  800618:	ff 55 08             	call   *0x8(%ebp)
                               }
                        }
			if ((long long) num < 0) {
  80061b:	85 f6                	test   %esi,%esi
  80061d:	78 13                	js     800632 <vprintfmt+0x326>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80061f:	89 5d b0             	mov    %ebx,-0x50(%ebp)
  800622:	89 75 b4             	mov    %esi,-0x4c(%ebp)
  800625:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800628:	b8 0a 00 00 00       	mov    $0xa,%eax
  80062d:	e9 da 00 00 00       	jmp    80070c <vprintfmt+0x400>
                               if((long long)num > 0){
                                   putch('+',putdat);
                               }
                        }
			if ((long long) num < 0) {
				putch('-', putdat);
  800632:	8b 45 0c             	mov    0xc(%ebp),%eax
  800635:	89 44 24 04          	mov    %eax,0x4(%esp)
  800639:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800640:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800643:	89 da                	mov    %ebx,%edx
  800645:	89 f1                	mov    %esi,%ecx
  800647:	f7 da                	neg    %edx
  800649:	83 d1 00             	adc    $0x0,%ecx
  80064c:	f7 d9                	neg    %ecx
  80064e:	89 55 b0             	mov    %edx,-0x50(%ebp)
  800651:	89 4d b4             	mov    %ecx,-0x4c(%ebp)
  800654:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800657:	b8 0a 00 00 00       	mov    $0xa,%eax
  80065c:	e9 ab 00 00 00       	jmp    80070c <vprintfmt+0x400>
  800661:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800664:	89 f2                	mov    %esi,%edx
  800666:	8d 45 14             	lea    0x14(%ebp),%eax
  800669:	e8 47 fc ff ff       	call   8002b5 <getuint>
  80066e:	89 45 b0             	mov    %eax,-0x50(%ebp)
  800671:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  800674:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800677:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
  80067c:	e9 8b 00 00 00       	jmp    80070c <vprintfmt+0x400>
  800681:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			putch('0', putdat);
  800684:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800687:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80068b:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800692:	ff 55 08             	call   *0x8(%ebp)
			num = getuint(&ap,lflag);
  800695:	89 f2                	mov    %esi,%edx
  800697:	8d 45 14             	lea    0x14(%ebp),%eax
  80069a:	e8 16 fc ff ff       	call   8002b5 <getuint>
  80069f:	89 45 b0             	mov    %eax,-0x50(%ebp)
  8006a2:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  8006a5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006a8:	b8 08 00 00 00       	mov    $0x8,%eax
                        base = 8;
			goto number;
  8006ad:	eb 5d                	jmp    80070c <vprintfmt+0x400>
  8006af:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
  8006b2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006b5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006b9:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8006c0:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8006c3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006c7:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8006ce:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  8006d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d4:	8d 50 04             	lea    0x4(%eax),%edx
  8006d7:	89 55 14             	mov    %edx,0x14(%ebp)
  8006da:	8b 10                	mov    (%eax),%edx
  8006dc:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006e1:	89 55 b0             	mov    %edx,-0x50(%ebp)
  8006e4:	89 4d b4             	mov    %ecx,-0x4c(%ebp)
  8006e7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006ea:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006ef:	eb 1b                	jmp    80070c <vprintfmt+0x400>
  8006f1:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006f4:	89 f2                	mov    %esi,%edx
  8006f6:	8d 45 14             	lea    0x14(%ebp),%eax
  8006f9:	e8 b7 fb ff ff       	call   8002b5 <getuint>
  8006fe:	89 45 b0             	mov    %eax,-0x50(%ebp)
  800701:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  800704:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800707:	b8 10 00 00 00       	mov    $0x10,%eax
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  80070c:	0f be 4d cc          	movsbl -0x34(%ebp),%ecx
  800710:	89 4d d0             	mov    %ecx,-0x30(%ebp)
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800713:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800716:	83 7d b4 00          	cmpl   $0x0,-0x4c(%ebp)
  80071a:	77 09                	ja     800725 <vprintfmt+0x419>
  80071c:	39 45 b0             	cmp    %eax,-0x50(%ebp)
  80071f:	0f 82 ac 00 00 00    	jb     8007d1 <vprintfmt+0x4c5>
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
  800725:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800728:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  80072c:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80072f:	83 ea 01             	sub    $0x1,%edx
  800732:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800736:	89 44 24 08          	mov    %eax,0x8(%esp)
  80073a:	8b 44 24 08          	mov    0x8(%esp),%eax
  80073e:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800742:	89 45 c0             	mov    %eax,-0x40(%ebp)
  800745:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  800748:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80074b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80074f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800756:	00 
  800757:	8b 4d b0             	mov    -0x50(%ebp),%ecx
  80075a:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
  80075d:	89 0c 24             	mov    %ecx,(%esp)
  800760:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800764:	e8 a7 1d 00 00       	call   802510 <__udivdi3>
  800769:	8b 4d c0             	mov    -0x40(%ebp),%ecx
  80076c:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  80076f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800773:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800777:	89 04 24             	mov    %eax,(%esp)
  80077a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80077e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800781:	8b 45 08             	mov    0x8(%ebp),%eax
  800784:	e8 37 fa ff ff       	call   8001c0 <printnum_v2>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800789:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80078c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800790:	8b 74 24 04          	mov    0x4(%esp),%esi
  800794:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800797:	89 44 24 08          	mov    %eax,0x8(%esp)
  80079b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8007a2:	00 
  8007a3:	8b 55 b0             	mov    -0x50(%ebp),%edx
  8007a6:	8b 4d b4             	mov    -0x4c(%ebp),%ecx
  8007a9:	89 14 24             	mov    %edx,(%esp)
  8007ac:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8007b0:	e8 8b 1e 00 00       	call   802640 <__umoddi3>
  8007b5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007b9:	0f be 80 c9 27 80 00 	movsbl 0x8027c9(%eax),%eax
  8007c0:	89 04 24             	mov    %eax,(%esp)
  8007c3:	ff 55 08             	call   *0x8(%ebp)
        if(padc == '-'){
  8007c6:	83 7d d0 2d          	cmpl   $0x2d,-0x30(%ebp)
  8007ca:	74 54                	je     800820 <vprintfmt+0x514>
  8007cc:	e9 67 fb ff ff       	jmp    800338 <vprintfmt+0x2c>
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
  8007d1:	83 7d d0 2d          	cmpl   $0x2d,-0x30(%ebp)
  8007d5:	8d 76 00             	lea    0x0(%esi),%esi
  8007d8:	0f 84 2a 01 00 00    	je     800908 <vprintfmt+0x5fc>
		while (--width > 0)
  8007de:	8b 7d d8             	mov    -0x28(%ebp),%edi
  8007e1:	83 ef 01             	sub    $0x1,%edi
  8007e4:	85 ff                	test   %edi,%edi
  8007e6:	0f 8e 5e 01 00 00    	jle    80094a <vprintfmt+0x63e>
  8007ec:	8b 4d b0             	mov    -0x50(%ebp),%ecx
  8007ef:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
  8007f2:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  8007f5:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  8007f8:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8007fb:	8b 75 0c             	mov    0xc(%ebp),%esi
			putch(padc, putdat);
  8007fe:	89 74 24 04          	mov    %esi,0x4(%esp)
  800802:	89 1c 24             	mov    %ebx,(%esp)
  800805:	ff 55 08             	call   *0x8(%ebp)
	if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
		while (--width > 0)
  800808:	83 ef 01             	sub    $0x1,%edi
  80080b:	85 ff                	test   %edi,%edi
  80080d:	7f ef                	jg     8007fe <vprintfmt+0x4f2>
  80080f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800812:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800815:	89 45 b0             	mov    %eax,-0x50(%ebp)
  800818:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  80081b:	e9 2a 01 00 00       	jmp    80094a <vprintfmt+0x63e>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
        if(padc == '-'){
           while (--width > 0)
  800820:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800823:	83 eb 01             	sub    $0x1,%ebx
  800826:	85 db                	test   %ebx,%ebx
  800828:	0f 8e 0a fb ff ff    	jle    800338 <vprintfmt+0x2c>
  80082e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800831:	89 7d d8             	mov    %edi,-0x28(%ebp)
  800834:	8b 7d 08             	mov    0x8(%ebp),%edi
			putch(' ', putdat);
  800837:	89 74 24 04          	mov    %esi,0x4(%esp)
  80083b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800842:	ff d7                	call   *%edi
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
        if(padc == '-'){
           while (--width > 0)
  800844:	83 eb 01             	sub    $0x1,%ebx
  800847:	85 db                	test   %ebx,%ebx
  800849:	7f ec                	jg     800837 <vprintfmt+0x52b>
  80084b:	8b 7d d8             	mov    -0x28(%ebp),%edi
  80084e:	e9 e8 fa ff ff       	jmp    80033b <vprintfmt+0x2f>
  800853:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
            char* n;
            if ((n = va_arg(ap, char *)) == NULL)
  800856:	8b 45 14             	mov    0x14(%ebp),%eax
  800859:	8d 50 04             	lea    0x4(%eax),%edx
  80085c:	89 55 14             	mov    %edx,0x14(%ebp)
  80085f:	8b 00                	mov    (%eax),%eax
  800861:	85 c0                	test   %eax,%eax
  800863:	75 2a                	jne    80088f <vprintfmt+0x583>
		  printfmt(putch,putdat,"%s",null_error);
  800865:	c7 44 24 0c fc 28 80 	movl   $0x8028fc,0xc(%esp)
  80086c:	00 
  80086d:	c7 44 24 08 1e 2c 80 	movl   $0x802c1e,0x8(%esp)
  800874:	00 
  800875:	8b 55 0c             	mov    0xc(%ebp),%edx
  800878:	89 54 24 04          	mov    %edx,0x4(%esp)
  80087c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80087f:	89 0c 24             	mov    %ecx,(%esp)
  800882:	e8 90 01 00 00       	call   800a17 <printfmt>
  800887:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80088a:	e9 ac fa ff ff       	jmp    80033b <vprintfmt+0x2f>
            else if((*(int*)putdat) > 127){
  80088f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800892:	8b 13                	mov    (%ebx),%edx
  800894:	83 fa 7f             	cmp    $0x7f,%edx
  800897:	7e 29                	jle    8008c2 <vprintfmt+0x5b6>
                  *n = *(int*)putdat;
  800899:	88 10                	mov    %dl,(%eax)
                  printfmt(putch,putdat,"%s",overflow_error);
  80089b:	c7 44 24 0c 34 29 80 	movl   $0x802934,0xc(%esp)
  8008a2:	00 
  8008a3:	c7 44 24 08 1e 2c 80 	movl   $0x802c1e,0x8(%esp)
  8008aa:	00 
  8008ab:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008af:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b2:	89 04 24             	mov    %eax,(%esp)
  8008b5:	e8 5d 01 00 00       	call   800a17 <printfmt>
  8008ba:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8008bd:	e9 79 fa ff ff       	jmp    80033b <vprintfmt+0x2f>
            }
            else
                  *n = *(int*)putdat;
  8008c2:	88 10                	mov    %dl,(%eax)
  8008c4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8008c7:	e9 6f fa ff ff       	jmp    80033b <vprintfmt+0x2f>
  8008cc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8008cf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            break;
        }
		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8008d2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008d5:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8008d9:	89 14 24             	mov    %edx,(%esp)
  8008dc:	ff 55 08             	call   *0x8(%ebp)
  8008df:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;
  8008e2:	e9 54 fa ff ff       	jmp    80033b <vprintfmt+0x2f>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8008e7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8008ea:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008ee:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8008f5:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008f8:	8d 47 ff             	lea    -0x1(%edi),%eax
  8008fb:	80 38 25             	cmpb   $0x25,(%eax)
  8008fe:	0f 84 37 fa ff ff    	je     80033b <vprintfmt+0x2f>
  800904:	89 c7                	mov    %eax,%edi
  800906:	eb f0                	jmp    8008f8 <vprintfmt+0x5ec>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800908:	8b 45 0c             	mov    0xc(%ebp),%eax
  80090b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80090f:	8b 74 24 04          	mov    0x4(%esp),%esi
  800913:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800916:	89 54 24 08          	mov    %edx,0x8(%esp)
  80091a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800921:	00 
  800922:	8b 45 b0             	mov    -0x50(%ebp),%eax
  800925:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  800928:	89 04 24             	mov    %eax,(%esp)
  80092b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80092f:	e8 0c 1d 00 00       	call   802640 <__umoddi3>
  800934:	89 74 24 04          	mov    %esi,0x4(%esp)
  800938:	0f be 80 c9 27 80 00 	movsbl 0x8027c9(%eax),%eax
  80093f:	89 04 24             	mov    %eax,(%esp)
  800942:	ff 55 08             	call   *0x8(%ebp)
  800945:	e9 d6 fe ff ff       	jmp    800820 <vprintfmt+0x514>
  80094a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80094d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800951:	8b 74 24 04          	mov    0x4(%esp),%esi
  800955:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800958:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80095c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800963:	00 
  800964:	8b 45 b0             	mov    -0x50(%ebp),%eax
  800967:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  80096a:	89 04 24             	mov    %eax,(%esp)
  80096d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800971:	e8 ca 1c 00 00       	call   802640 <__umoddi3>
  800976:	89 74 24 04          	mov    %esi,0x4(%esp)
  80097a:	0f be 80 c9 27 80 00 	movsbl 0x8027c9(%eax),%eax
  800981:	89 04 24             	mov    %eax,(%esp)
  800984:	ff 55 08             	call   *0x8(%ebp)
  800987:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80098a:	e9 ac f9 ff ff       	jmp    80033b <vprintfmt+0x2f>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  80098f:	83 c4 6c             	add    $0x6c,%esp
  800992:	5b                   	pop    %ebx
  800993:	5e                   	pop    %esi
  800994:	5f                   	pop    %edi
  800995:	5d                   	pop    %ebp
  800996:	c3                   	ret    

00800997 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800997:	55                   	push   %ebp
  800998:	89 e5                	mov    %esp,%ebp
  80099a:	83 ec 28             	sub    $0x28,%esp
  80099d:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a0:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  8009a3:	85 c0                	test   %eax,%eax
  8009a5:	74 04                	je     8009ab <vsnprintf+0x14>
  8009a7:	85 d2                	test   %edx,%edx
  8009a9:	7f 07                	jg     8009b2 <vsnprintf+0x1b>
  8009ab:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8009b0:	eb 3b                	jmp    8009ed <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  8009b2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8009b5:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  8009b9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8009bc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8009c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8009c6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009ca:	8b 45 10             	mov    0x10(%ebp),%eax
  8009cd:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009d1:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8009d4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009d8:	c7 04 24 ef 02 80 00 	movl   $0x8002ef,(%esp)
  8009df:	e8 28 f9 ff ff       	call   80030c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8009e4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8009e7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8009ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8009ed:	c9                   	leave  
  8009ee:	c3                   	ret    

008009ef <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8009ef:	55                   	push   %ebp
  8009f0:	89 e5                	mov    %esp,%ebp
  8009f2:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  8009f5:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  8009f8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009fc:	8b 45 10             	mov    0x10(%ebp),%eax
  8009ff:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a03:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a06:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a0a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0d:	89 04 24             	mov    %eax,(%esp)
  800a10:	e8 82 ff ff ff       	call   800997 <vsnprintf>
	va_end(ap);

	return rc;
}
  800a15:	c9                   	leave  
  800a16:	c3                   	ret    

00800a17 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800a17:	55                   	push   %ebp
  800a18:	89 e5                	mov    %esp,%ebp
  800a1a:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  800a1d:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  800a20:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a24:	8b 45 10             	mov    0x10(%ebp),%eax
  800a27:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a2b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a2e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a32:	8b 45 08             	mov    0x8(%ebp),%eax
  800a35:	89 04 24             	mov    %eax,(%esp)
  800a38:	e8 cf f8 ff ff       	call   80030c <vprintfmt>
	va_end(ap);
}
  800a3d:	c9                   	leave  
  800a3e:	c3                   	ret    
	...

00800a40 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a40:	55                   	push   %ebp
  800a41:	89 e5                	mov    %esp,%ebp
  800a43:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a46:	b8 00 00 00 00       	mov    $0x0,%eax
  800a4b:	80 3a 00             	cmpb   $0x0,(%edx)
  800a4e:	74 09                	je     800a59 <strlen+0x19>
		n++;
  800a50:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800a53:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a57:	75 f7                	jne    800a50 <strlen+0x10>
		n++;
	return n;
}
  800a59:	5d                   	pop    %ebp
  800a5a:	c3                   	ret    

00800a5b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a5b:	55                   	push   %ebp
  800a5c:	89 e5                	mov    %esp,%ebp
  800a5e:	53                   	push   %ebx
  800a5f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800a62:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a65:	85 c9                	test   %ecx,%ecx
  800a67:	74 19                	je     800a82 <strnlen+0x27>
  800a69:	80 3b 00             	cmpb   $0x0,(%ebx)
  800a6c:	74 14                	je     800a82 <strnlen+0x27>
  800a6e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800a73:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a76:	39 c8                	cmp    %ecx,%eax
  800a78:	74 0d                	je     800a87 <strnlen+0x2c>
  800a7a:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  800a7e:	75 f3                	jne    800a73 <strnlen+0x18>
  800a80:	eb 05                	jmp    800a87 <strnlen+0x2c>
  800a82:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800a87:	5b                   	pop    %ebx
  800a88:	5d                   	pop    %ebp
  800a89:	c3                   	ret    

00800a8a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a8a:	55                   	push   %ebp
  800a8b:	89 e5                	mov    %esp,%ebp
  800a8d:	53                   	push   %ebx
  800a8e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a91:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a94:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a99:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800a9d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800aa0:	83 c2 01             	add    $0x1,%edx
  800aa3:	84 c9                	test   %cl,%cl
  800aa5:	75 f2                	jne    800a99 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800aa7:	5b                   	pop    %ebx
  800aa8:	5d                   	pop    %ebp
  800aa9:	c3                   	ret    

00800aaa <strcat>:

char *
strcat(char *dst, const char *src)
{
  800aaa:	55                   	push   %ebp
  800aab:	89 e5                	mov    %esp,%ebp
  800aad:	53                   	push   %ebx
  800aae:	83 ec 08             	sub    $0x8,%esp
  800ab1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800ab4:	89 1c 24             	mov    %ebx,(%esp)
  800ab7:	e8 84 ff ff ff       	call   800a40 <strlen>
	strcpy(dst + len, src);
  800abc:	8b 55 0c             	mov    0xc(%ebp),%edx
  800abf:	89 54 24 04          	mov    %edx,0x4(%esp)
  800ac3:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800ac6:	89 04 24             	mov    %eax,(%esp)
  800ac9:	e8 bc ff ff ff       	call   800a8a <strcpy>
	return dst;
}
  800ace:	89 d8                	mov    %ebx,%eax
  800ad0:	83 c4 08             	add    $0x8,%esp
  800ad3:	5b                   	pop    %ebx
  800ad4:	5d                   	pop    %ebp
  800ad5:	c3                   	ret    

00800ad6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800ad6:	55                   	push   %ebp
  800ad7:	89 e5                	mov    %esp,%ebp
  800ad9:	56                   	push   %esi
  800ada:	53                   	push   %ebx
  800adb:	8b 45 08             	mov    0x8(%ebp),%eax
  800ade:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ae1:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ae4:	85 f6                	test   %esi,%esi
  800ae6:	74 18                	je     800b00 <strncpy+0x2a>
  800ae8:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800aed:	0f b6 1a             	movzbl (%edx),%ebx
  800af0:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800af3:	80 3a 01             	cmpb   $0x1,(%edx)
  800af6:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800af9:	83 c1 01             	add    $0x1,%ecx
  800afc:	39 ce                	cmp    %ecx,%esi
  800afe:	77 ed                	ja     800aed <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800b00:	5b                   	pop    %ebx
  800b01:	5e                   	pop    %esi
  800b02:	5d                   	pop    %ebp
  800b03:	c3                   	ret    

00800b04 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800b04:	55                   	push   %ebp
  800b05:	89 e5                	mov    %esp,%ebp
  800b07:	56                   	push   %esi
  800b08:	53                   	push   %ebx
  800b09:	8b 75 08             	mov    0x8(%ebp),%esi
  800b0c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b0f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b12:	89 f0                	mov    %esi,%eax
  800b14:	85 c9                	test   %ecx,%ecx
  800b16:	74 27                	je     800b3f <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  800b18:	83 e9 01             	sub    $0x1,%ecx
  800b1b:	74 1d                	je     800b3a <strlcpy+0x36>
  800b1d:	0f b6 1a             	movzbl (%edx),%ebx
  800b20:	84 db                	test   %bl,%bl
  800b22:	74 16                	je     800b3a <strlcpy+0x36>
			*dst++ = *src++;
  800b24:	88 18                	mov    %bl,(%eax)
  800b26:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800b29:	83 e9 01             	sub    $0x1,%ecx
  800b2c:	74 0e                	je     800b3c <strlcpy+0x38>
			*dst++ = *src++;
  800b2e:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800b31:	0f b6 1a             	movzbl (%edx),%ebx
  800b34:	84 db                	test   %bl,%bl
  800b36:	75 ec                	jne    800b24 <strlcpy+0x20>
  800b38:	eb 02                	jmp    800b3c <strlcpy+0x38>
  800b3a:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800b3c:	c6 00 00             	movb   $0x0,(%eax)
  800b3f:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800b41:	5b                   	pop    %ebx
  800b42:	5e                   	pop    %esi
  800b43:	5d                   	pop    %ebp
  800b44:	c3                   	ret    

00800b45 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b45:	55                   	push   %ebp
  800b46:	89 e5                	mov    %esp,%ebp
  800b48:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b4b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800b4e:	0f b6 01             	movzbl (%ecx),%eax
  800b51:	84 c0                	test   %al,%al
  800b53:	74 15                	je     800b6a <strcmp+0x25>
  800b55:	3a 02                	cmp    (%edx),%al
  800b57:	75 11                	jne    800b6a <strcmp+0x25>
		p++, q++;
  800b59:	83 c1 01             	add    $0x1,%ecx
  800b5c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800b5f:	0f b6 01             	movzbl (%ecx),%eax
  800b62:	84 c0                	test   %al,%al
  800b64:	74 04                	je     800b6a <strcmp+0x25>
  800b66:	3a 02                	cmp    (%edx),%al
  800b68:	74 ef                	je     800b59 <strcmp+0x14>
  800b6a:	0f b6 c0             	movzbl %al,%eax
  800b6d:	0f b6 12             	movzbl (%edx),%edx
  800b70:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800b72:	5d                   	pop    %ebp
  800b73:	c3                   	ret    

00800b74 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b74:	55                   	push   %ebp
  800b75:	89 e5                	mov    %esp,%ebp
  800b77:	53                   	push   %ebx
  800b78:	8b 55 08             	mov    0x8(%ebp),%edx
  800b7b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b7e:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800b81:	85 c0                	test   %eax,%eax
  800b83:	74 23                	je     800ba8 <strncmp+0x34>
  800b85:	0f b6 1a             	movzbl (%edx),%ebx
  800b88:	84 db                	test   %bl,%bl
  800b8a:	74 25                	je     800bb1 <strncmp+0x3d>
  800b8c:	3a 19                	cmp    (%ecx),%bl
  800b8e:	75 21                	jne    800bb1 <strncmp+0x3d>
  800b90:	83 e8 01             	sub    $0x1,%eax
  800b93:	74 13                	je     800ba8 <strncmp+0x34>
		n--, p++, q++;
  800b95:	83 c2 01             	add    $0x1,%edx
  800b98:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b9b:	0f b6 1a             	movzbl (%edx),%ebx
  800b9e:	84 db                	test   %bl,%bl
  800ba0:	74 0f                	je     800bb1 <strncmp+0x3d>
  800ba2:	3a 19                	cmp    (%ecx),%bl
  800ba4:	74 ea                	je     800b90 <strncmp+0x1c>
  800ba6:	eb 09                	jmp    800bb1 <strncmp+0x3d>
  800ba8:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800bad:	5b                   	pop    %ebx
  800bae:	5d                   	pop    %ebp
  800baf:	90                   	nop
  800bb0:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800bb1:	0f b6 02             	movzbl (%edx),%eax
  800bb4:	0f b6 11             	movzbl (%ecx),%edx
  800bb7:	29 d0                	sub    %edx,%eax
  800bb9:	eb f2                	jmp    800bad <strncmp+0x39>

00800bbb <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800bbb:	55                   	push   %ebp
  800bbc:	89 e5                	mov    %esp,%ebp
  800bbe:	8b 45 08             	mov    0x8(%ebp),%eax
  800bc1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800bc5:	0f b6 10             	movzbl (%eax),%edx
  800bc8:	84 d2                	test   %dl,%dl
  800bca:	74 18                	je     800be4 <strchr+0x29>
		if (*s == c)
  800bcc:	38 ca                	cmp    %cl,%dl
  800bce:	75 0a                	jne    800bda <strchr+0x1f>
  800bd0:	eb 17                	jmp    800be9 <strchr+0x2e>
  800bd2:	38 ca                	cmp    %cl,%dl
  800bd4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800bd8:	74 0f                	je     800be9 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800bda:	83 c0 01             	add    $0x1,%eax
  800bdd:	0f b6 10             	movzbl (%eax),%edx
  800be0:	84 d2                	test   %dl,%dl
  800be2:	75 ee                	jne    800bd2 <strchr+0x17>
  800be4:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800be9:	5d                   	pop    %ebp
  800bea:	c3                   	ret    

00800beb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800beb:	55                   	push   %ebp
  800bec:	89 e5                	mov    %esp,%ebp
  800bee:	8b 45 08             	mov    0x8(%ebp),%eax
  800bf1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800bf5:	0f b6 10             	movzbl (%eax),%edx
  800bf8:	84 d2                	test   %dl,%dl
  800bfa:	74 18                	je     800c14 <strfind+0x29>
		if (*s == c)
  800bfc:	38 ca                	cmp    %cl,%dl
  800bfe:	75 0a                	jne    800c0a <strfind+0x1f>
  800c00:	eb 12                	jmp    800c14 <strfind+0x29>
  800c02:	38 ca                	cmp    %cl,%dl
  800c04:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800c08:	74 0a                	je     800c14 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800c0a:	83 c0 01             	add    $0x1,%eax
  800c0d:	0f b6 10             	movzbl (%eax),%edx
  800c10:	84 d2                	test   %dl,%dl
  800c12:	75 ee                	jne    800c02 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800c14:	5d                   	pop    %ebp
  800c15:	c3                   	ret    

00800c16 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800c16:	55                   	push   %ebp
  800c17:	89 e5                	mov    %esp,%ebp
  800c19:	83 ec 0c             	sub    $0xc,%esp
  800c1c:	89 1c 24             	mov    %ebx,(%esp)
  800c1f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c23:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800c27:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c2a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c2d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800c30:	85 c9                	test   %ecx,%ecx
  800c32:	74 30                	je     800c64 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800c34:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c3a:	75 25                	jne    800c61 <memset+0x4b>
  800c3c:	f6 c1 03             	test   $0x3,%cl
  800c3f:	75 20                	jne    800c61 <memset+0x4b>
		c &= 0xFF;
  800c41:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800c44:	89 d3                	mov    %edx,%ebx
  800c46:	c1 e3 08             	shl    $0x8,%ebx
  800c49:	89 d6                	mov    %edx,%esi
  800c4b:	c1 e6 18             	shl    $0x18,%esi
  800c4e:	89 d0                	mov    %edx,%eax
  800c50:	c1 e0 10             	shl    $0x10,%eax
  800c53:	09 f0                	or     %esi,%eax
  800c55:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  800c57:	09 d8                	or     %ebx,%eax
  800c59:	c1 e9 02             	shr    $0x2,%ecx
  800c5c:	fc                   	cld    
  800c5d:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800c5f:	eb 03                	jmp    800c64 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c61:	fc                   	cld    
  800c62:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800c64:	89 f8                	mov    %edi,%eax
  800c66:	8b 1c 24             	mov    (%esp),%ebx
  800c69:	8b 74 24 04          	mov    0x4(%esp),%esi
  800c6d:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800c71:	89 ec                	mov    %ebp,%esp
  800c73:	5d                   	pop    %ebp
  800c74:	c3                   	ret    

00800c75 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c75:	55                   	push   %ebp
  800c76:	89 e5                	mov    %esp,%ebp
  800c78:	83 ec 08             	sub    $0x8,%esp
  800c7b:	89 34 24             	mov    %esi,(%esp)
  800c7e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800c82:	8b 45 08             	mov    0x8(%ebp),%eax
  800c85:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800c88:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800c8b:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800c8d:	39 c6                	cmp    %eax,%esi
  800c8f:	73 35                	jae    800cc6 <memmove+0x51>
  800c91:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c94:	39 d0                	cmp    %edx,%eax
  800c96:	73 2e                	jae    800cc6 <memmove+0x51>
		s += n;
		d += n;
  800c98:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c9a:	f6 c2 03             	test   $0x3,%dl
  800c9d:	75 1b                	jne    800cba <memmove+0x45>
  800c9f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800ca5:	75 13                	jne    800cba <memmove+0x45>
  800ca7:	f6 c1 03             	test   $0x3,%cl
  800caa:	75 0e                	jne    800cba <memmove+0x45>
			asm volatile("std; rep movsl\n"
  800cac:	83 ef 04             	sub    $0x4,%edi
  800caf:	8d 72 fc             	lea    -0x4(%edx),%esi
  800cb2:	c1 e9 02             	shr    $0x2,%ecx
  800cb5:	fd                   	std    
  800cb6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800cb8:	eb 09                	jmp    800cc3 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800cba:	83 ef 01             	sub    $0x1,%edi
  800cbd:	8d 72 ff             	lea    -0x1(%edx),%esi
  800cc0:	fd                   	std    
  800cc1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800cc3:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800cc4:	eb 20                	jmp    800ce6 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800cc6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800ccc:	75 15                	jne    800ce3 <memmove+0x6e>
  800cce:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800cd4:	75 0d                	jne    800ce3 <memmove+0x6e>
  800cd6:	f6 c1 03             	test   $0x3,%cl
  800cd9:	75 08                	jne    800ce3 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  800cdb:	c1 e9 02             	shr    $0x2,%ecx
  800cde:	fc                   	cld    
  800cdf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ce1:	eb 03                	jmp    800ce6 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800ce3:	fc                   	cld    
  800ce4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ce6:	8b 34 24             	mov    (%esp),%esi
  800ce9:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800ced:	89 ec                	mov    %ebp,%esp
  800cef:	5d                   	pop    %ebp
  800cf0:	c3                   	ret    

00800cf1 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800cf1:	55                   	push   %ebp
  800cf2:	89 e5                	mov    %esp,%ebp
  800cf4:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800cf7:	8b 45 10             	mov    0x10(%ebp),%eax
  800cfa:	89 44 24 08          	mov    %eax,0x8(%esp)
  800cfe:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d01:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d05:	8b 45 08             	mov    0x8(%ebp),%eax
  800d08:	89 04 24             	mov    %eax,(%esp)
  800d0b:	e8 65 ff ff ff       	call   800c75 <memmove>
}
  800d10:	c9                   	leave  
  800d11:	c3                   	ret    

00800d12 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800d12:	55                   	push   %ebp
  800d13:	89 e5                	mov    %esp,%ebp
  800d15:	57                   	push   %edi
  800d16:	56                   	push   %esi
  800d17:	53                   	push   %ebx
  800d18:	8b 75 08             	mov    0x8(%ebp),%esi
  800d1b:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800d1e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d21:	85 c9                	test   %ecx,%ecx
  800d23:	74 36                	je     800d5b <memcmp+0x49>
		if (*s1 != *s2)
  800d25:	0f b6 06             	movzbl (%esi),%eax
  800d28:	0f b6 1f             	movzbl (%edi),%ebx
  800d2b:	38 d8                	cmp    %bl,%al
  800d2d:	74 20                	je     800d4f <memcmp+0x3d>
  800d2f:	eb 14                	jmp    800d45 <memcmp+0x33>
  800d31:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  800d36:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  800d3b:	83 c2 01             	add    $0x1,%edx
  800d3e:	83 e9 01             	sub    $0x1,%ecx
  800d41:	38 d8                	cmp    %bl,%al
  800d43:	74 12                	je     800d57 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  800d45:	0f b6 c0             	movzbl %al,%eax
  800d48:	0f b6 db             	movzbl %bl,%ebx
  800d4b:	29 d8                	sub    %ebx,%eax
  800d4d:	eb 11                	jmp    800d60 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d4f:	83 e9 01             	sub    $0x1,%ecx
  800d52:	ba 00 00 00 00       	mov    $0x0,%edx
  800d57:	85 c9                	test   %ecx,%ecx
  800d59:	75 d6                	jne    800d31 <memcmp+0x1f>
  800d5b:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800d60:	5b                   	pop    %ebx
  800d61:	5e                   	pop    %esi
  800d62:	5f                   	pop    %edi
  800d63:	5d                   	pop    %ebp
  800d64:	c3                   	ret    

00800d65 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800d65:	55                   	push   %ebp
  800d66:	89 e5                	mov    %esp,%ebp
  800d68:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800d6b:	89 c2                	mov    %eax,%edx
  800d6d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800d70:	39 d0                	cmp    %edx,%eax
  800d72:	73 15                	jae    800d89 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d74:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800d78:	38 08                	cmp    %cl,(%eax)
  800d7a:	75 06                	jne    800d82 <memfind+0x1d>
  800d7c:	eb 0b                	jmp    800d89 <memfind+0x24>
  800d7e:	38 08                	cmp    %cl,(%eax)
  800d80:	74 07                	je     800d89 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d82:	83 c0 01             	add    $0x1,%eax
  800d85:	39 c2                	cmp    %eax,%edx
  800d87:	77 f5                	ja     800d7e <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800d89:	5d                   	pop    %ebp
  800d8a:	c3                   	ret    

00800d8b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d8b:	55                   	push   %ebp
  800d8c:	89 e5                	mov    %esp,%ebp
  800d8e:	57                   	push   %edi
  800d8f:	56                   	push   %esi
  800d90:	53                   	push   %ebx
  800d91:	83 ec 04             	sub    $0x4,%esp
  800d94:	8b 55 08             	mov    0x8(%ebp),%edx
  800d97:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d9a:	0f b6 02             	movzbl (%edx),%eax
  800d9d:	3c 20                	cmp    $0x20,%al
  800d9f:	74 04                	je     800da5 <strtol+0x1a>
  800da1:	3c 09                	cmp    $0x9,%al
  800da3:	75 0e                	jne    800db3 <strtol+0x28>
		s++;
  800da5:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800da8:	0f b6 02             	movzbl (%edx),%eax
  800dab:	3c 20                	cmp    $0x20,%al
  800dad:	74 f6                	je     800da5 <strtol+0x1a>
  800daf:	3c 09                	cmp    $0x9,%al
  800db1:	74 f2                	je     800da5 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800db3:	3c 2b                	cmp    $0x2b,%al
  800db5:	75 0c                	jne    800dc3 <strtol+0x38>
		s++;
  800db7:	83 c2 01             	add    $0x1,%edx
  800dba:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800dc1:	eb 15                	jmp    800dd8 <strtol+0x4d>
	else if (*s == '-')
  800dc3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800dca:	3c 2d                	cmp    $0x2d,%al
  800dcc:	75 0a                	jne    800dd8 <strtol+0x4d>
		s++, neg = 1;
  800dce:	83 c2 01             	add    $0x1,%edx
  800dd1:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800dd8:	85 db                	test   %ebx,%ebx
  800dda:	0f 94 c0             	sete   %al
  800ddd:	74 05                	je     800de4 <strtol+0x59>
  800ddf:	83 fb 10             	cmp    $0x10,%ebx
  800de2:	75 18                	jne    800dfc <strtol+0x71>
  800de4:	80 3a 30             	cmpb   $0x30,(%edx)
  800de7:	75 13                	jne    800dfc <strtol+0x71>
  800de9:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800ded:	8d 76 00             	lea    0x0(%esi),%esi
  800df0:	75 0a                	jne    800dfc <strtol+0x71>
		s += 2, base = 16;
  800df2:	83 c2 02             	add    $0x2,%edx
  800df5:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800dfa:	eb 15                	jmp    800e11 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800dfc:	84 c0                	test   %al,%al
  800dfe:	66 90                	xchg   %ax,%ax
  800e00:	74 0f                	je     800e11 <strtol+0x86>
  800e02:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800e07:	80 3a 30             	cmpb   $0x30,(%edx)
  800e0a:	75 05                	jne    800e11 <strtol+0x86>
		s++, base = 8;
  800e0c:	83 c2 01             	add    $0x1,%edx
  800e0f:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800e11:	b8 00 00 00 00       	mov    $0x0,%eax
  800e16:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800e18:	0f b6 0a             	movzbl (%edx),%ecx
  800e1b:	89 cf                	mov    %ecx,%edi
  800e1d:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800e20:	80 fb 09             	cmp    $0x9,%bl
  800e23:	77 08                	ja     800e2d <strtol+0xa2>
			dig = *s - '0';
  800e25:	0f be c9             	movsbl %cl,%ecx
  800e28:	83 e9 30             	sub    $0x30,%ecx
  800e2b:	eb 1e                	jmp    800e4b <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  800e2d:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  800e30:	80 fb 19             	cmp    $0x19,%bl
  800e33:	77 08                	ja     800e3d <strtol+0xb2>
			dig = *s - 'a' + 10;
  800e35:	0f be c9             	movsbl %cl,%ecx
  800e38:	83 e9 57             	sub    $0x57,%ecx
  800e3b:	eb 0e                	jmp    800e4b <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  800e3d:	8d 5f bf             	lea    -0x41(%edi),%ebx
  800e40:	80 fb 19             	cmp    $0x19,%bl
  800e43:	77 15                	ja     800e5a <strtol+0xcf>
			dig = *s - 'A' + 10;
  800e45:	0f be c9             	movsbl %cl,%ecx
  800e48:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800e4b:	39 f1                	cmp    %esi,%ecx
  800e4d:	7d 0b                	jge    800e5a <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  800e4f:	83 c2 01             	add    $0x1,%edx
  800e52:	0f af c6             	imul   %esi,%eax
  800e55:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800e58:	eb be                	jmp    800e18 <strtol+0x8d>
  800e5a:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800e5c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e60:	74 05                	je     800e67 <strtol+0xdc>
		*endptr = (char *) s;
  800e62:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800e65:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800e67:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800e6b:	74 04                	je     800e71 <strtol+0xe6>
  800e6d:	89 c8                	mov    %ecx,%eax
  800e6f:	f7 d8                	neg    %eax
}
  800e71:	83 c4 04             	add    $0x4,%esp
  800e74:	5b                   	pop    %ebx
  800e75:	5e                   	pop    %esi
  800e76:	5f                   	pop    %edi
  800e77:	5d                   	pop    %ebp
  800e78:	c3                   	ret    
  800e79:	00 00                	add    %al,(%eax)
	...

00800e7c <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  800e7c:	55                   	push   %ebp
  800e7d:	89 e5                	mov    %esp,%ebp
  800e7f:	83 ec 08             	sub    $0x8,%esp
  800e82:	89 1c 24             	mov    %ebx,(%esp)
  800e85:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800e89:	ba 00 00 00 00       	mov    $0x0,%edx
  800e8e:	b8 01 00 00 00       	mov    $0x1,%eax
  800e93:	89 d1                	mov    %edx,%ecx
  800e95:	89 d3                	mov    %edx,%ebx
  800e97:	89 d7                	mov    %edx,%edi
  800e99:	51                   	push   %ecx
  800e9a:	52                   	push   %edx
  800e9b:	53                   	push   %ebx
  800e9c:	54                   	push   %esp
  800e9d:	55                   	push   %ebp
  800e9e:	56                   	push   %esi
  800e9f:	57                   	push   %edi
  800ea0:	54                   	push   %esp
  800ea1:	5d                   	pop    %ebp
  800ea2:	8d 35 aa 0e 80 00    	lea    0x800eaa,%esi
  800ea8:	0f 34                	sysenter 
  800eaa:	5f                   	pop    %edi
  800eab:	5e                   	pop    %esi
  800eac:	5d                   	pop    %ebp
  800ead:	5c                   	pop    %esp
  800eae:	5b                   	pop    %ebx
  800eaf:	5a                   	pop    %edx
  800eb0:	59                   	pop    %ecx

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800eb1:	8b 1c 24             	mov    (%esp),%ebx
  800eb4:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800eb8:	89 ec                	mov    %ebp,%esp
  800eba:	5d                   	pop    %ebp
  800ebb:	c3                   	ret    

00800ebc <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ebc:	55                   	push   %ebp
  800ebd:	89 e5                	mov    %esp,%ebp
  800ebf:	83 ec 08             	sub    $0x8,%esp
  800ec2:	89 1c 24             	mov    %ebx,(%esp)
  800ec5:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800ec9:	b8 00 00 00 00       	mov    $0x0,%eax
  800ece:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ed1:	8b 55 08             	mov    0x8(%ebp),%edx
  800ed4:	89 c3                	mov    %eax,%ebx
  800ed6:	89 c7                	mov    %eax,%edi
  800ed8:	51                   	push   %ecx
  800ed9:	52                   	push   %edx
  800eda:	53                   	push   %ebx
  800edb:	54                   	push   %esp
  800edc:	55                   	push   %ebp
  800edd:	56                   	push   %esi
  800ede:	57                   	push   %edi
  800edf:	54                   	push   %esp
  800ee0:	5d                   	pop    %ebp
  800ee1:	8d 35 e9 0e 80 00    	lea    0x800ee9,%esi
  800ee7:	0f 34                	sysenter 
  800ee9:	5f                   	pop    %edi
  800eea:	5e                   	pop    %esi
  800eeb:	5d                   	pop    %ebp
  800eec:	5c                   	pop    %esp
  800eed:	5b                   	pop    %ebx
  800eee:	5a                   	pop    %edx
  800eef:	59                   	pop    %ecx

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ef0:	8b 1c 24             	mov    (%esp),%ebx
  800ef3:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800ef7:	89 ec                	mov    %ebp,%esp
  800ef9:	5d                   	pop    %ebp
  800efa:	c3                   	ret    

00800efb <sys_get_mac>:
sys_receive_packet(uint32_t addr,int* len){
         return syscall(SYS_receive_packet,0,(uint32_t)addr,(uint32_t)len,0,0,0);
}

int 
sys_get_mac(uint8_t* macaddr){
  800efb:	55                   	push   %ebp
  800efc:	89 e5                	mov    %esp,%ebp
  800efe:	83 ec 08             	sub    $0x8,%esp
  800f01:	89 1c 24             	mov    %ebx,(%esp)
  800f04:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800f08:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f0d:	b8 13 00 00 00       	mov    $0x13,%eax
  800f12:	8b 55 08             	mov    0x8(%ebp),%edx
  800f15:	89 cb                	mov    %ecx,%ebx
  800f17:	89 cf                	mov    %ecx,%edi
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
}

int 
sys_get_mac(uint8_t* macaddr){
         return syscall(SYS_get_mac,0,(uint32_t)macaddr,0,0,0,0);
}
  800f31:	8b 1c 24             	mov    (%esp),%ebx
  800f34:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800f38:	89 ec                	mov    %ebp,%esp
  800f3a:	5d                   	pop    %ebp
  800f3b:	c3                   	ret    

00800f3c <sys_receive_packet>:
sys_transmit_packet(uint32_t addr,int len){
         return syscall(SYS_transmit_packet,0,(uint32_t)addr,(uint32_t)len,0,0,0);
}

int 
sys_receive_packet(uint32_t addr,int* len){
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
  800f49:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f4e:	b8 12 00 00 00       	mov    $0x12,%eax
  800f53:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f56:	8b 55 08             	mov    0x8(%ebp),%edx
  800f59:	89 df                	mov    %ebx,%edi
  800f5b:	51                   	push   %ecx
  800f5c:	52                   	push   %edx
  800f5d:	53                   	push   %ebx
  800f5e:	54                   	push   %esp
  800f5f:	55                   	push   %ebp
  800f60:	56                   	push   %esi
  800f61:	57                   	push   %edi
  800f62:	54                   	push   %esp
  800f63:	5d                   	pop    %ebp
  800f64:	8d 35 6c 0f 80 00    	lea    0x800f6c,%esi
  800f6a:	0f 34                	sysenter 
  800f6c:	5f                   	pop    %edi
  800f6d:	5e                   	pop    %esi
  800f6e:	5d                   	pop    %ebp
  800f6f:	5c                   	pop    %esp
  800f70:	5b                   	pop    %ebx
  800f71:	5a                   	pop    %edx
  800f72:	59                   	pop    %ecx
}

int 
sys_receive_packet(uint32_t addr,int* len){
         return syscall(SYS_receive_packet,0,(uint32_t)addr,(uint32_t)len,0,0,0);
}
  800f73:	8b 1c 24             	mov    (%esp),%ebx
  800f76:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800f7a:	89 ec                	mov    %ebp,%esp
  800f7c:	5d                   	pop    %ebp
  800f7d:	c3                   	ret    

00800f7e <sys_transmit_packet>:
sys_exec(void* vph, uint32_t phnum, uint32_t esp, uint32_t eip){
         return syscall(SYS_exec, 0, (uint32_t)vph, phnum, esp, eip, 0);
}

int 
sys_transmit_packet(uint32_t addr,int len){
  800f7e:	55                   	push   %ebp
  800f7f:	89 e5                	mov    %esp,%ebp
  800f81:	83 ec 08             	sub    $0x8,%esp
  800f84:	89 1c 24             	mov    %ebx,(%esp)
  800f87:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800f8b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f90:	b8 11 00 00 00       	mov    $0x11,%eax
  800f95:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f98:	8b 55 08             	mov    0x8(%ebp),%edx
  800f9b:	89 df                	mov    %ebx,%edi
  800f9d:	51                   	push   %ecx
  800f9e:	52                   	push   %edx
  800f9f:	53                   	push   %ebx
  800fa0:	54                   	push   %esp
  800fa1:	55                   	push   %ebp
  800fa2:	56                   	push   %esi
  800fa3:	57                   	push   %edi
  800fa4:	54                   	push   %esp
  800fa5:	5d                   	pop    %ebp
  800fa6:	8d 35 ae 0f 80 00    	lea    0x800fae,%esi
  800fac:	0f 34                	sysenter 
  800fae:	5f                   	pop    %edi
  800faf:	5e                   	pop    %esi
  800fb0:	5d                   	pop    %ebp
  800fb1:	5c                   	pop    %esp
  800fb2:	5b                   	pop    %ebx
  800fb3:	5a                   	pop    %edx
  800fb4:	59                   	pop    %ecx
}

int 
sys_transmit_packet(uint32_t addr,int len){
         return syscall(SYS_transmit_packet,0,(uint32_t)addr,(uint32_t)len,0,0,0);
}
  800fb5:	8b 1c 24             	mov    (%esp),%ebx
  800fb8:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800fbc:	89 ec                	mov    %ebp,%esp
  800fbe:	5d                   	pop    %ebp
  800fbf:	c3                   	ret    

00800fc0 <sys_exec>:
sys_env_set_prior(envid_t envid, uint32_t prior){
         return syscall(SYS_env_set_prior,1,envid, prior, 0, 0, 0);
}

int 
sys_exec(void* vph, uint32_t phnum, uint32_t esp, uint32_t eip){
  800fc0:	55                   	push   %ebp
  800fc1:	89 e5                	mov    %esp,%ebp
  800fc3:	83 ec 08             	sub    $0x8,%esp
  800fc6:	89 1c 24             	mov    %ebx,(%esp)
  800fc9:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800fcd:	b8 10 00 00 00       	mov    $0x10,%eax
  800fd2:	8b 7d 14             	mov    0x14(%ebp),%edi
  800fd5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800fd8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fdb:	8b 55 08             	mov    0x8(%ebp),%edx
  800fde:	51                   	push   %ecx
  800fdf:	52                   	push   %edx
  800fe0:	53                   	push   %ebx
  800fe1:	54                   	push   %esp
  800fe2:	55                   	push   %ebp
  800fe3:	56                   	push   %esi
  800fe4:	57                   	push   %edi
  800fe5:	54                   	push   %esp
  800fe6:	5d                   	pop    %ebp
  800fe7:	8d 35 ef 0f 80 00    	lea    0x800fef,%esi
  800fed:	0f 34                	sysenter 
  800fef:	5f                   	pop    %edi
  800ff0:	5e                   	pop    %esi
  800ff1:	5d                   	pop    %ebp
  800ff2:	5c                   	pop    %esp
  800ff3:	5b                   	pop    %ebx
  800ff4:	5a                   	pop    %edx
  800ff5:	59                   	pop    %ecx
}

int 
sys_exec(void* vph, uint32_t phnum, uint32_t esp, uint32_t eip){
         return syscall(SYS_exec, 0, (uint32_t)vph, phnum, esp, eip, 0);
}
  800ff6:	8b 1c 24             	mov    (%esp),%ebx
  800ff9:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800ffd:	89 ec                	mov    %ebp,%esp
  800fff:	5d                   	pop    %ebp
  801000:	c3                   	ret    

00801001 <sys_env_set_prior>:
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}


int 
sys_env_set_prior(envid_t envid, uint32_t prior){
  801001:	55                   	push   %ebp
  801002:	89 e5                	mov    %esp,%ebp
  801004:	83 ec 28             	sub    $0x28,%esp
  801007:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80100a:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80100d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801012:	b8 0f 00 00 00       	mov    $0xf,%eax
  801017:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80101a:	8b 55 08             	mov    0x8(%ebp),%edx
  80101d:	89 df                	mov    %ebx,%edi
  80101f:	51                   	push   %ecx
  801020:	52                   	push   %edx
  801021:	53                   	push   %ebx
  801022:	54                   	push   %esp
  801023:	55                   	push   %ebp
  801024:	56                   	push   %esi
  801025:	57                   	push   %edi
  801026:	54                   	push   %esp
  801027:	5d                   	pop    %ebp
  801028:	8d 35 30 10 80 00    	lea    0x801030,%esi
  80102e:	0f 34                	sysenter 
  801030:	5f                   	pop    %edi
  801031:	5e                   	pop    %esi
  801032:	5d                   	pop    %ebp
  801033:	5c                   	pop    %esp
  801034:	5b                   	pop    %ebx
  801035:	5a                   	pop    %edx
  801036:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801037:	85 c0                	test   %eax,%eax
  801039:	7e 28                	jle    801063 <sys_env_set_prior+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  80103b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80103f:	c7 44 24 0c 0f 00 00 	movl   $0xf,0xc(%esp)
  801046:	00 
  801047:	c7 44 24 08 40 2b 80 	movl   $0x802b40,0x8(%esp)
  80104e:	00 
  80104f:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801056:	00 
  801057:	c7 04 24 5d 2b 80 00 	movl   $0x802b5d,(%esp)
  80105e:	e8 d1 12 00 00       	call   802334 <_panic>


int 
sys_env_set_prior(envid_t envid, uint32_t prior){
         return syscall(SYS_env_set_prior,1,envid, prior, 0, 0, 0);
}
  801063:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801066:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801069:	89 ec                	mov    %ebp,%esp
  80106b:	5d                   	pop    %ebp
  80106c:	c3                   	ret    

0080106d <sys_time_msec>:
}


unsigned int
sys_time_msec(void)
{
  80106d:	55                   	push   %ebp
  80106e:	89 e5                	mov    %esp,%ebp
  801070:	83 ec 08             	sub    $0x8,%esp
  801073:	89 1c 24             	mov    %ebx,(%esp)
  801076:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80107a:	ba 00 00 00 00       	mov    $0x0,%edx
  80107f:	b8 15 00 00 00       	mov    $0x15,%eax
  801084:	89 d1                	mov    %edx,%ecx
  801086:	89 d3                	mov    %edx,%ebx
  801088:	89 d7                	mov    %edx,%edi
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

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  8010a2:	8b 1c 24             	mov    (%esp),%ebx
  8010a5:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8010a9:	89 ec                	mov    %ebp,%esp
  8010ab:	5d                   	pop    %ebp
  8010ac:	c3                   	ret    

008010ad <sys_sbrk>:
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}

int
sys_sbrk(uint32_t inc)
{
  8010ad:	55                   	push   %ebp
  8010ae:	89 e5                	mov    %esp,%ebp
  8010b0:	83 ec 08             	sub    $0x8,%esp
  8010b3:	89 1c 24             	mov    %ebx,(%esp)
  8010b6:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8010ba:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010bf:	b8 14 00 00 00       	mov    $0x14,%eax
  8010c4:	8b 55 08             	mov    0x8(%ebp),%edx
  8010c7:	89 cb                	mov    %ecx,%ebx
  8010c9:	89 cf                	mov    %ecx,%edi
  8010cb:	51                   	push   %ecx
  8010cc:	52                   	push   %edx
  8010cd:	53                   	push   %ebx
  8010ce:	54                   	push   %esp
  8010cf:	55                   	push   %ebp
  8010d0:	56                   	push   %esi
  8010d1:	57                   	push   %edi
  8010d2:	54                   	push   %esp
  8010d3:	5d                   	pop    %ebp
  8010d4:	8d 35 dc 10 80 00    	lea    0x8010dc,%esi
  8010da:	0f 34                	sysenter 
  8010dc:	5f                   	pop    %edi
  8010dd:	5e                   	pop    %esi
  8010de:	5d                   	pop    %ebp
  8010df:	5c                   	pop    %esp
  8010e0:	5b                   	pop    %ebx
  8010e1:	5a                   	pop    %edx
  8010e2:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  8010e3:	8b 1c 24             	mov    (%esp),%ebx
  8010e6:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8010ea:	89 ec                	mov    %ebp,%esp
  8010ec:	5d                   	pop    %ebp
  8010ed:	c3                   	ret    

008010ee <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  8010ee:	55                   	push   %ebp
  8010ef:	89 e5                	mov    %esp,%ebp
  8010f1:	83 ec 28             	sub    $0x28,%esp
  8010f4:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8010f7:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8010fa:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010ff:	b8 0e 00 00 00       	mov    $0xe,%eax
  801104:	8b 55 08             	mov    0x8(%ebp),%edx
  801107:	89 cb                	mov    %ecx,%ebx
  801109:	89 cf                	mov    %ecx,%edi
  80110b:	51                   	push   %ecx
  80110c:	52                   	push   %edx
  80110d:	53                   	push   %ebx
  80110e:	54                   	push   %esp
  80110f:	55                   	push   %ebp
  801110:	56                   	push   %esi
  801111:	57                   	push   %edi
  801112:	54                   	push   %esp
  801113:	5d                   	pop    %ebp
  801114:	8d 35 1c 11 80 00    	lea    0x80111c,%esi
  80111a:	0f 34                	sysenter 
  80111c:	5f                   	pop    %edi
  80111d:	5e                   	pop    %esi
  80111e:	5d                   	pop    %ebp
  80111f:	5c                   	pop    %esp
  801120:	5b                   	pop    %ebx
  801121:	5a                   	pop    %edx
  801122:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801123:	85 c0                	test   %eax,%eax
  801125:	7e 28                	jle    80114f <sys_ipc_recv+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  801127:	89 44 24 10          	mov    %eax,0x10(%esp)
  80112b:	c7 44 24 0c 0e 00 00 	movl   $0xe,0xc(%esp)
  801132:	00 
  801133:	c7 44 24 08 40 2b 80 	movl   $0x802b40,0x8(%esp)
  80113a:	00 
  80113b:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801142:	00 
  801143:	c7 04 24 5d 2b 80 00 	movl   $0x802b5d,(%esp)
  80114a:	e8 e5 11 00 00       	call   802334 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80114f:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801152:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801155:	89 ec                	mov    %ebp,%esp
  801157:	5d                   	pop    %ebp
  801158:	c3                   	ret    

00801159 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801159:	55                   	push   %ebp
  80115a:	89 e5                	mov    %esp,%ebp
  80115c:	83 ec 08             	sub    $0x8,%esp
  80115f:	89 1c 24             	mov    %ebx,(%esp)
  801162:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801166:	b8 0d 00 00 00       	mov    $0xd,%eax
  80116b:	8b 7d 14             	mov    0x14(%ebp),%edi
  80116e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801171:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801174:	8b 55 08             	mov    0x8(%ebp),%edx
  801177:	51                   	push   %ecx
  801178:	52                   	push   %edx
  801179:	53                   	push   %ebx
  80117a:	54                   	push   %esp
  80117b:	55                   	push   %ebp
  80117c:	56                   	push   %esi
  80117d:	57                   	push   %edi
  80117e:	54                   	push   %esp
  80117f:	5d                   	pop    %ebp
  801180:	8d 35 88 11 80 00    	lea    0x801188,%esi
  801186:	0f 34                	sysenter 
  801188:	5f                   	pop    %edi
  801189:	5e                   	pop    %esi
  80118a:	5d                   	pop    %ebp
  80118b:	5c                   	pop    %esp
  80118c:	5b                   	pop    %ebx
  80118d:	5a                   	pop    %edx
  80118e:	59                   	pop    %ecx

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80118f:	8b 1c 24             	mov    (%esp),%ebx
  801192:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801196:	89 ec                	mov    %ebp,%esp
  801198:	5d                   	pop    %ebp
  801199:	c3                   	ret    

0080119a <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80119a:	55                   	push   %ebp
  80119b:	89 e5                	mov    %esp,%ebp
  80119d:	83 ec 28             	sub    $0x28,%esp
  8011a0:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8011a3:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8011a6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011ab:	b8 0b 00 00 00       	mov    $0xb,%eax
  8011b0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011b3:	8b 55 08             	mov    0x8(%ebp),%edx
  8011b6:	89 df                	mov    %ebx,%edi
  8011b8:	51                   	push   %ecx
  8011b9:	52                   	push   %edx
  8011ba:	53                   	push   %ebx
  8011bb:	54                   	push   %esp
  8011bc:	55                   	push   %ebp
  8011bd:	56                   	push   %esi
  8011be:	57                   	push   %edi
  8011bf:	54                   	push   %esp
  8011c0:	5d                   	pop    %ebp
  8011c1:	8d 35 c9 11 80 00    	lea    0x8011c9,%esi
  8011c7:	0f 34                	sysenter 
  8011c9:	5f                   	pop    %edi
  8011ca:	5e                   	pop    %esi
  8011cb:	5d                   	pop    %ebp
  8011cc:	5c                   	pop    %esp
  8011cd:	5b                   	pop    %ebx
  8011ce:	5a                   	pop    %edx
  8011cf:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8011d0:	85 c0                	test   %eax,%eax
  8011d2:	7e 28                	jle    8011fc <sys_env_set_pgfault_upcall+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011d4:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011d8:	c7 44 24 0c 0b 00 00 	movl   $0xb,0xc(%esp)
  8011df:	00 
  8011e0:	c7 44 24 08 40 2b 80 	movl   $0x802b40,0x8(%esp)
  8011e7:	00 
  8011e8:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8011ef:	00 
  8011f0:	c7 04 24 5d 2b 80 00 	movl   $0x802b5d,(%esp)
  8011f7:	e8 38 11 00 00       	call   802334 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8011fc:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8011ff:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801202:	89 ec                	mov    %ebp,%esp
  801204:	5d                   	pop    %ebp
  801205:	c3                   	ret    

00801206 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801206:	55                   	push   %ebp
  801207:	89 e5                	mov    %esp,%ebp
  801209:	83 ec 28             	sub    $0x28,%esp
  80120c:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80120f:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801212:	bb 00 00 00 00       	mov    $0x0,%ebx
  801217:	b8 0a 00 00 00       	mov    $0xa,%eax
  80121c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80121f:	8b 55 08             	mov    0x8(%ebp),%edx
  801222:	89 df                	mov    %ebx,%edi
  801224:	51                   	push   %ecx
  801225:	52                   	push   %edx
  801226:	53                   	push   %ebx
  801227:	54                   	push   %esp
  801228:	55                   	push   %ebp
  801229:	56                   	push   %esi
  80122a:	57                   	push   %edi
  80122b:	54                   	push   %esp
  80122c:	5d                   	pop    %ebp
  80122d:	8d 35 35 12 80 00    	lea    0x801235,%esi
  801233:	0f 34                	sysenter 
  801235:	5f                   	pop    %edi
  801236:	5e                   	pop    %esi
  801237:	5d                   	pop    %ebp
  801238:	5c                   	pop    %esp
  801239:	5b                   	pop    %ebx
  80123a:	5a                   	pop    %edx
  80123b:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80123c:	85 c0                	test   %eax,%eax
  80123e:	7e 28                	jle    801268 <sys_env_set_trapframe+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  801240:	89 44 24 10          	mov    %eax,0x10(%esp)
  801244:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  80124b:	00 
  80124c:	c7 44 24 08 40 2b 80 	movl   $0x802b40,0x8(%esp)
  801253:	00 
  801254:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80125b:	00 
  80125c:	c7 04 24 5d 2b 80 00 	movl   $0x802b5d,(%esp)
  801263:	e8 cc 10 00 00       	call   802334 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801268:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80126b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80126e:	89 ec                	mov    %ebp,%esp
  801270:	5d                   	pop    %ebp
  801271:	c3                   	ret    

00801272 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801272:	55                   	push   %ebp
  801273:	89 e5                	mov    %esp,%ebp
  801275:	83 ec 28             	sub    $0x28,%esp
  801278:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80127b:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80127e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801283:	b8 09 00 00 00       	mov    $0x9,%eax
  801288:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80128b:	8b 55 08             	mov    0x8(%ebp),%edx
  80128e:	89 df                	mov    %ebx,%edi
  801290:	51                   	push   %ecx
  801291:	52                   	push   %edx
  801292:	53                   	push   %ebx
  801293:	54                   	push   %esp
  801294:	55                   	push   %ebp
  801295:	56                   	push   %esi
  801296:	57                   	push   %edi
  801297:	54                   	push   %esp
  801298:	5d                   	pop    %ebp
  801299:	8d 35 a1 12 80 00    	lea    0x8012a1,%esi
  80129f:	0f 34                	sysenter 
  8012a1:	5f                   	pop    %edi
  8012a2:	5e                   	pop    %esi
  8012a3:	5d                   	pop    %ebp
  8012a4:	5c                   	pop    %esp
  8012a5:	5b                   	pop    %ebx
  8012a6:	5a                   	pop    %edx
  8012a7:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8012a8:	85 c0                	test   %eax,%eax
  8012aa:	7e 28                	jle    8012d4 <sys_env_set_status+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012ac:	89 44 24 10          	mov    %eax,0x10(%esp)
  8012b0:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8012b7:	00 
  8012b8:	c7 44 24 08 40 2b 80 	movl   $0x802b40,0x8(%esp)
  8012bf:	00 
  8012c0:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8012c7:	00 
  8012c8:	c7 04 24 5d 2b 80 00 	movl   $0x802b5d,(%esp)
  8012cf:	e8 60 10 00 00       	call   802334 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8012d4:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8012d7:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8012da:	89 ec                	mov    %ebp,%esp
  8012dc:	5d                   	pop    %ebp
  8012dd:	c3                   	ret    

008012de <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  8012de:	55                   	push   %ebp
  8012df:	89 e5                	mov    %esp,%ebp
  8012e1:	83 ec 28             	sub    $0x28,%esp
  8012e4:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8012e7:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8012ea:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012ef:	b8 07 00 00 00       	mov    $0x7,%eax
  8012f4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012f7:	8b 55 08             	mov    0x8(%ebp),%edx
  8012fa:	89 df                	mov    %ebx,%edi
  8012fc:	51                   	push   %ecx
  8012fd:	52                   	push   %edx
  8012fe:	53                   	push   %ebx
  8012ff:	54                   	push   %esp
  801300:	55                   	push   %ebp
  801301:	56                   	push   %esi
  801302:	57                   	push   %edi
  801303:	54                   	push   %esp
  801304:	5d                   	pop    %ebp
  801305:	8d 35 0d 13 80 00    	lea    0x80130d,%esi
  80130b:	0f 34                	sysenter 
  80130d:	5f                   	pop    %edi
  80130e:	5e                   	pop    %esi
  80130f:	5d                   	pop    %ebp
  801310:	5c                   	pop    %esp
  801311:	5b                   	pop    %ebx
  801312:	5a                   	pop    %edx
  801313:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801314:	85 c0                	test   %eax,%eax
  801316:	7e 28                	jle    801340 <sys_page_unmap+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  801318:	89 44 24 10          	mov    %eax,0x10(%esp)
  80131c:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801323:	00 
  801324:	c7 44 24 08 40 2b 80 	movl   $0x802b40,0x8(%esp)
  80132b:	00 
  80132c:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801333:	00 
  801334:	c7 04 24 5d 2b 80 00 	movl   $0x802b5d,(%esp)
  80133b:	e8 f4 0f 00 00       	call   802334 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801340:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801343:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801346:	89 ec                	mov    %ebp,%esp
  801348:	5d                   	pop    %ebp
  801349:	c3                   	ret    

0080134a <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80134a:	55                   	push   %ebp
  80134b:	89 e5                	mov    %esp,%ebp
  80134d:	83 ec 28             	sub    $0x28,%esp
  801350:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801353:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801356:	8b 7d 18             	mov    0x18(%ebp),%edi
  801359:	0b 7d 14             	or     0x14(%ebp),%edi
  80135c:	b8 06 00 00 00       	mov    $0x6,%eax
  801361:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801364:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801367:	8b 55 08             	mov    0x8(%ebp),%edx
  80136a:	51                   	push   %ecx
  80136b:	52                   	push   %edx
  80136c:	53                   	push   %ebx
  80136d:	54                   	push   %esp
  80136e:	55                   	push   %ebp
  80136f:	56                   	push   %esi
  801370:	57                   	push   %edi
  801371:	54                   	push   %esp
  801372:	5d                   	pop    %ebp
  801373:	8d 35 7b 13 80 00    	lea    0x80137b,%esi
  801379:	0f 34                	sysenter 
  80137b:	5f                   	pop    %edi
  80137c:	5e                   	pop    %esi
  80137d:	5d                   	pop    %ebp
  80137e:	5c                   	pop    %esp
  80137f:	5b                   	pop    %ebx
  801380:	5a                   	pop    %edx
  801381:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801382:	85 c0                	test   %eax,%eax
  801384:	7e 28                	jle    8013ae <sys_page_map+0x64>
		panic("syscall %d returned %d (> 0)", num, ret);
  801386:	89 44 24 10          	mov    %eax,0x10(%esp)
  80138a:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  801391:	00 
  801392:	c7 44 24 08 40 2b 80 	movl   $0x802b40,0x8(%esp)
  801399:	00 
  80139a:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8013a1:	00 
  8013a2:	c7 04 24 5d 2b 80 00 	movl   $0x802b5d,(%esp)
  8013a9:	e8 86 0f 00 00       	call   802334 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}
  8013ae:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8013b1:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8013b4:	89 ec                	mov    %ebp,%esp
  8013b6:	5d                   	pop    %ebp
  8013b7:	c3                   	ret    

008013b8 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8013b8:	55                   	push   %ebp
  8013b9:	89 e5                	mov    %esp,%ebp
  8013bb:	83 ec 28             	sub    $0x28,%esp
  8013be:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8013c1:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8013c4:	bf 00 00 00 00       	mov    $0x0,%edi
  8013c9:	b8 05 00 00 00       	mov    $0x5,%eax
  8013ce:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8013d1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013d4:	8b 55 08             	mov    0x8(%ebp),%edx
  8013d7:	51                   	push   %ecx
  8013d8:	52                   	push   %edx
  8013d9:	53                   	push   %ebx
  8013da:	54                   	push   %esp
  8013db:	55                   	push   %ebp
  8013dc:	56                   	push   %esi
  8013dd:	57                   	push   %edi
  8013de:	54                   	push   %esp
  8013df:	5d                   	pop    %ebp
  8013e0:	8d 35 e8 13 80 00    	lea    0x8013e8,%esi
  8013e6:	0f 34                	sysenter 
  8013e8:	5f                   	pop    %edi
  8013e9:	5e                   	pop    %esi
  8013ea:	5d                   	pop    %ebp
  8013eb:	5c                   	pop    %esp
  8013ec:	5b                   	pop    %ebx
  8013ed:	5a                   	pop    %edx
  8013ee:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8013ef:	85 c0                	test   %eax,%eax
  8013f1:	7e 28                	jle    80141b <sys_page_alloc+0x63>
		panic("syscall %d returned %d (> 0)", num, ret);
  8013f3:	89 44 24 10          	mov    %eax,0x10(%esp)
  8013f7:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  8013fe:	00 
  8013ff:	c7 44 24 08 40 2b 80 	movl   $0x802b40,0x8(%esp)
  801406:	00 
  801407:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80140e:	00 
  80140f:	c7 04 24 5d 2b 80 00 	movl   $0x802b5d,(%esp)
  801416:	e8 19 0f 00 00       	call   802334 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80141b:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80141e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801421:	89 ec                	mov    %ebp,%esp
  801423:	5d                   	pop    %ebp
  801424:	c3                   	ret    

00801425 <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
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
  801437:	b8 0c 00 00 00       	mov    $0xc,%eax
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

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80145a:	8b 1c 24             	mov    (%esp),%ebx
  80145d:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801461:	89 ec                	mov    %ebp,%esp
  801463:	5d                   	pop    %ebp
  801464:	c3                   	ret    

00801465 <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
{
  801465:	55                   	push   %ebp
  801466:	89 e5                	mov    %esp,%ebp
  801468:	83 ec 08             	sub    $0x8,%esp
  80146b:	89 1c 24             	mov    %ebx,(%esp)
  80146e:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801472:	bb 00 00 00 00       	mov    $0x0,%ebx
  801477:	b8 04 00 00 00       	mov    $0x4,%eax
  80147c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80147f:	8b 55 08             	mov    0x8(%ebp),%edx
  801482:	89 df                	mov    %ebx,%edi
  801484:	51                   	push   %ecx
  801485:	52                   	push   %edx
  801486:	53                   	push   %ebx
  801487:	54                   	push   %esp
  801488:	55                   	push   %ebp
  801489:	56                   	push   %esi
  80148a:	57                   	push   %edi
  80148b:	54                   	push   %esp
  80148c:	5d                   	pop    %ebp
  80148d:	8d 35 95 14 80 00    	lea    0x801495,%esi
  801493:	0f 34                	sysenter 
  801495:	5f                   	pop    %edi
  801496:	5e                   	pop    %esi
  801497:	5d                   	pop    %ebp
  801498:	5c                   	pop    %esp
  801499:	5b                   	pop    %ebx
  80149a:	5a                   	pop    %edx
  80149b:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  80149c:	8b 1c 24             	mov    (%esp),%ebx
  80149f:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8014a3:	89 ec                	mov    %ebp,%esp
  8014a5:	5d                   	pop    %ebp
  8014a6:	c3                   	ret    

008014a7 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  8014a7:	55                   	push   %ebp
  8014a8:	89 e5                	mov    %esp,%ebp
  8014aa:	83 ec 08             	sub    $0x8,%esp
  8014ad:	89 1c 24             	mov    %ebx,(%esp)
  8014b0:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8014b4:	ba 00 00 00 00       	mov    $0x0,%edx
  8014b9:	b8 02 00 00 00       	mov    $0x2,%eax
  8014be:	89 d1                	mov    %edx,%ecx
  8014c0:	89 d3                	mov    %edx,%ebx
  8014c2:	89 d7                	mov    %edx,%edi
  8014c4:	51                   	push   %ecx
  8014c5:	52                   	push   %edx
  8014c6:	53                   	push   %ebx
  8014c7:	54                   	push   %esp
  8014c8:	55                   	push   %ebp
  8014c9:	56                   	push   %esi
  8014ca:	57                   	push   %edi
  8014cb:	54                   	push   %esp
  8014cc:	5d                   	pop    %ebp
  8014cd:	8d 35 d5 14 80 00    	lea    0x8014d5,%esi
  8014d3:	0f 34                	sysenter 
  8014d5:	5f                   	pop    %edi
  8014d6:	5e                   	pop    %esi
  8014d7:	5d                   	pop    %ebp
  8014d8:	5c                   	pop    %esp
  8014d9:	5b                   	pop    %ebx
  8014da:	5a                   	pop    %edx
  8014db:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8014dc:	8b 1c 24             	mov    (%esp),%ebx
  8014df:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8014e3:	89 ec                	mov    %ebp,%esp
  8014e5:	5d                   	pop    %ebp
  8014e6:	c3                   	ret    

008014e7 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  8014e7:	55                   	push   %ebp
  8014e8:	89 e5                	mov    %esp,%ebp
  8014ea:	83 ec 28             	sub    $0x28,%esp
  8014ed:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8014f0:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8014f3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8014f8:	b8 03 00 00 00       	mov    $0x3,%eax
  8014fd:	8b 55 08             	mov    0x8(%ebp),%edx
  801500:	89 cb                	mov    %ecx,%ebx
  801502:	89 cf                	mov    %ecx,%edi
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
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80151c:	85 c0                	test   %eax,%eax
  80151e:	7e 28                	jle    801548 <sys_env_destroy+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  801520:	89 44 24 10          	mov    %eax,0x10(%esp)
  801524:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  80152b:	00 
  80152c:	c7 44 24 08 40 2b 80 	movl   $0x802b40,0x8(%esp)
  801533:	00 
  801534:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80153b:	00 
  80153c:	c7 04 24 5d 2b 80 00 	movl   $0x802b5d,(%esp)
  801543:	e8 ec 0d 00 00       	call   802334 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801548:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80154b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80154e:	89 ec                	mov    %ebp,%esp
  801550:	5d                   	pop    %ebp
  801551:	c3                   	ret    
	...

00801560 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801560:	55                   	push   %ebp
  801561:	89 e5                	mov    %esp,%ebp
  801563:	8b 45 08             	mov    0x8(%ebp),%eax
  801566:	05 00 00 00 30       	add    $0x30000000,%eax
  80156b:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  80156e:	5d                   	pop    %ebp
  80156f:	c3                   	ret    

00801570 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801570:	55                   	push   %ebp
  801571:	89 e5                	mov    %esp,%ebp
  801573:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801576:	8b 45 08             	mov    0x8(%ebp),%eax
  801579:	89 04 24             	mov    %eax,(%esp)
  80157c:	e8 df ff ff ff       	call   801560 <fd2num>
  801581:	05 20 00 0d 00       	add    $0xd0020,%eax
  801586:	c1 e0 0c             	shl    $0xc,%eax
}
  801589:	c9                   	leave  
  80158a:	c3                   	ret    

0080158b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80158b:	55                   	push   %ebp
  80158c:	89 e5                	mov    %esp,%ebp
  80158e:	57                   	push   %edi
  80158f:	56                   	push   %esi
  801590:	53                   	push   %ebx
  801591:	8b 7d 08             	mov    0x8(%ebp),%edi
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  801594:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  801599:	a8 01                	test   $0x1,%al
  80159b:	74 36                	je     8015d3 <fd_alloc+0x48>
  80159d:	a1 00 00 74 ef       	mov    0xef740000,%eax
  8015a2:	a8 01                	test   $0x1,%al
  8015a4:	74 2d                	je     8015d3 <fd_alloc+0x48>
  8015a6:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  8015ab:	b9 00 d0 7b ef       	mov    $0xef7bd000,%ecx
  8015b0:	be 00 00 40 ef       	mov    $0xef400000,%esi
  8015b5:	89 c3                	mov    %eax,%ebx
  8015b7:	89 c2                	mov    %eax,%edx
  8015b9:	c1 ea 16             	shr    $0x16,%edx
  8015bc:	8b 14 91             	mov    (%ecx,%edx,4),%edx
  8015bf:	f6 c2 01             	test   $0x1,%dl
  8015c2:	74 14                	je     8015d8 <fd_alloc+0x4d>
  8015c4:	89 c2                	mov    %eax,%edx
  8015c6:	c1 ea 0c             	shr    $0xc,%edx
  8015c9:	8b 14 96             	mov    (%esi,%edx,4),%edx
  8015cc:	f6 c2 01             	test   $0x1,%dl
  8015cf:	75 10                	jne    8015e1 <fd_alloc+0x56>
  8015d1:	eb 05                	jmp    8015d8 <fd_alloc+0x4d>
  8015d3:	bb 00 00 00 d0       	mov    $0xd0000000,%ebx
			*fd_store = fd;
  8015d8:	89 1f                	mov    %ebx,(%edi)
  8015da:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  8015df:	eb 17                	jmp    8015f8 <fd_alloc+0x6d>
  8015e1:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8015e6:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8015eb:	75 c8                	jne    8015b5 <fd_alloc+0x2a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8015ed:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  8015f3:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  8015f8:	5b                   	pop    %ebx
  8015f9:	5e                   	pop    %esi
  8015fa:	5f                   	pop    %edi
  8015fb:	5d                   	pop    %ebp
  8015fc:	c3                   	ret    

008015fd <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8015fd:	55                   	push   %ebp
  8015fe:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801600:	8b 45 08             	mov    0x8(%ebp),%eax
  801603:	83 f8 1f             	cmp    $0x1f,%eax
  801606:	77 36                	ja     80163e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801608:	05 00 00 0d 00       	add    $0xd0000,%eax
  80160d:	c1 e0 0c             	shl    $0xc,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
  801610:	89 c2                	mov    %eax,%edx
  801612:	c1 ea 16             	shr    $0x16,%edx
  801615:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80161c:	f6 c2 01             	test   $0x1,%dl
  80161f:	74 1d                	je     80163e <fd_lookup+0x41>
  801621:	89 c2                	mov    %eax,%edx
  801623:	c1 ea 0c             	shr    $0xc,%edx
  801626:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80162d:	f6 c2 01             	test   $0x1,%dl
  801630:	74 0c                	je     80163e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  801632:	8b 55 0c             	mov    0xc(%ebp),%edx
  801635:	89 02                	mov    %eax,(%edx)
  801637:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
  80163c:	eb 05                	jmp    801643 <fd_lookup+0x46>
  80163e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801643:	5d                   	pop    %ebp
  801644:	c3                   	ret    

00801645 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  801645:	55                   	push   %ebp
  801646:	89 e5                	mov    %esp,%ebp
  801648:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80164b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80164e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801652:	8b 45 08             	mov    0x8(%ebp),%eax
  801655:	89 04 24             	mov    %eax,(%esp)
  801658:	e8 a0 ff ff ff       	call   8015fd <fd_lookup>
  80165d:	85 c0                	test   %eax,%eax
  80165f:	78 0e                	js     80166f <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801661:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801664:	8b 55 0c             	mov    0xc(%ebp),%edx
  801667:	89 50 04             	mov    %edx,0x4(%eax)
  80166a:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  80166f:	c9                   	leave  
  801670:	c3                   	ret    

00801671 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801671:	55                   	push   %ebp
  801672:	89 e5                	mov    %esp,%ebp
  801674:	56                   	push   %esi
  801675:	53                   	push   %ebx
  801676:	83 ec 10             	sub    $0x10,%esp
  801679:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80167c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
// File functions
// --------------------------------------------------------------

static struct Dev *devtab[] =
{
	&devfile,
  80167f:	b8 04 30 80 00       	mov    $0x803004,%eax
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  801684:	ba 00 00 00 00       	mov    $0x0,%edx

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801689:	be e8 2b 80 00       	mov    $0x802be8,%esi
		if (devtab[i]->dev_id == dev_id) {
  80168e:	39 08                	cmp    %ecx,(%eax)
  801690:	75 10                	jne    8016a2 <dev_lookup+0x31>
  801692:	eb 04                	jmp    801698 <dev_lookup+0x27>
  801694:	39 08                	cmp    %ecx,(%eax)
  801696:	75 0a                	jne    8016a2 <dev_lookup+0x31>
			*dev = devtab[i];
  801698:	89 03                	mov    %eax,(%ebx)
  80169a:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  80169f:	90                   	nop
  8016a0:	eb 31                	jmp    8016d3 <dev_lookup+0x62>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8016a2:	83 c2 01             	add    $0x1,%edx
  8016a5:	8b 04 96             	mov    (%esi,%edx,4),%eax
  8016a8:	85 c0                	test   %eax,%eax
  8016aa:	75 e8                	jne    801694 <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8016ac:	a1 08 40 80 00       	mov    0x804008,%eax
  8016b1:	8b 40 48             	mov    0x48(%eax),%eax
  8016b4:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8016b8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016bc:	c7 04 24 6c 2b 80 00 	movl   $0x802b6c,(%esp)
  8016c3:	e8 91 ea ff ff       	call   800159 <cprintf>
	*dev = 0;
  8016c8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8016ce:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  8016d3:	83 c4 10             	add    $0x10,%esp
  8016d6:	5b                   	pop    %ebx
  8016d7:	5e                   	pop    %esi
  8016d8:	5d                   	pop    %ebp
  8016d9:	c3                   	ret    

008016da <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  8016da:	55                   	push   %ebp
  8016db:	89 e5                	mov    %esp,%ebp
  8016dd:	53                   	push   %ebx
  8016de:	83 ec 24             	sub    $0x24,%esp
  8016e1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016e4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016e7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8016ee:	89 04 24             	mov    %eax,(%esp)
  8016f1:	e8 07 ff ff ff       	call   8015fd <fd_lookup>
  8016f6:	85 c0                	test   %eax,%eax
  8016f8:	78 53                	js     80174d <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016fa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801701:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801704:	8b 00                	mov    (%eax),%eax
  801706:	89 04 24             	mov    %eax,(%esp)
  801709:	e8 63 ff ff ff       	call   801671 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80170e:	85 c0                	test   %eax,%eax
  801710:	78 3b                	js     80174d <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  801712:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801717:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80171a:	83 7a 14 00          	cmpl   $0x0,0x14(%edx)
  80171e:	74 2d                	je     80174d <fstat+0x73>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801720:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801723:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80172a:	00 00 00 
	stat->st_isdir = 0;
  80172d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801734:	00 00 00 
	stat->st_dev = dev;
  801737:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80173a:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801740:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801744:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801747:	89 14 24             	mov    %edx,(%esp)
  80174a:	ff 50 14             	call   *0x14(%eax)
}
  80174d:	83 c4 24             	add    $0x24,%esp
  801750:	5b                   	pop    %ebx
  801751:	5d                   	pop    %ebp
  801752:	c3                   	ret    

00801753 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  801753:	55                   	push   %ebp
  801754:	89 e5                	mov    %esp,%ebp
  801756:	53                   	push   %ebx
  801757:	83 ec 24             	sub    $0x24,%esp
  80175a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80175d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801760:	89 44 24 04          	mov    %eax,0x4(%esp)
  801764:	89 1c 24             	mov    %ebx,(%esp)
  801767:	e8 91 fe ff ff       	call   8015fd <fd_lookup>
  80176c:	85 c0                	test   %eax,%eax
  80176e:	78 5f                	js     8017cf <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801770:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801773:	89 44 24 04          	mov    %eax,0x4(%esp)
  801777:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80177a:	8b 00                	mov    (%eax),%eax
  80177c:	89 04 24             	mov    %eax,(%esp)
  80177f:	e8 ed fe ff ff       	call   801671 <dev_lookup>
ftruncate(int fdnum, off_t newsize)
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801784:	85 c0                	test   %eax,%eax
  801786:	78 47                	js     8017cf <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801788:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80178b:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  80178f:	75 23                	jne    8017b4 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801791:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801796:	8b 40 48             	mov    0x48(%eax),%eax
  801799:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80179d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017a1:	c7 04 24 8c 2b 80 00 	movl   $0x802b8c,(%esp)
  8017a8:	e8 ac e9 ff ff       	call   800159 <cprintf>
  8017ad:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8017b2:	eb 1b                	jmp    8017cf <ftruncate+0x7c>
	}
	if (!dev->dev_trunc)
  8017b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017b7:	8b 48 18             	mov    0x18(%eax),%ecx
  8017ba:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8017bf:	85 c9                	test   %ecx,%ecx
  8017c1:	74 0c                	je     8017cf <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8017c3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017c6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017ca:	89 14 24             	mov    %edx,(%esp)
  8017cd:	ff d1                	call   *%ecx
}
  8017cf:	83 c4 24             	add    $0x24,%esp
  8017d2:	5b                   	pop    %ebx
  8017d3:	5d                   	pop    %ebp
  8017d4:	c3                   	ret    

008017d5 <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8017d5:	55                   	push   %ebp
  8017d6:	89 e5                	mov    %esp,%ebp
  8017d8:	53                   	push   %ebx
  8017d9:	83 ec 24             	sub    $0x24,%esp
  8017dc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017df:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017e2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017e6:	89 1c 24             	mov    %ebx,(%esp)
  8017e9:	e8 0f fe ff ff       	call   8015fd <fd_lookup>
  8017ee:	85 c0                	test   %eax,%eax
  8017f0:	78 66                	js     801858 <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017f2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017f5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017fc:	8b 00                	mov    (%eax),%eax
  8017fe:	89 04 24             	mov    %eax,(%esp)
  801801:	e8 6b fe ff ff       	call   801671 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801806:	85 c0                	test   %eax,%eax
  801808:	78 4e                	js     801858 <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80180a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80180d:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  801811:	75 23                	jne    801836 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801813:	a1 08 40 80 00       	mov    0x804008,%eax
  801818:	8b 40 48             	mov    0x48(%eax),%eax
  80181b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80181f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801823:	c7 04 24 ad 2b 80 00 	movl   $0x802bad,(%esp)
  80182a:	e8 2a e9 ff ff       	call   800159 <cprintf>
  80182f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801834:	eb 22                	jmp    801858 <write+0x83>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801836:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801839:	8b 48 0c             	mov    0xc(%eax),%ecx
  80183c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801841:	85 c9                	test   %ecx,%ecx
  801843:	74 13                	je     801858 <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801845:	8b 45 10             	mov    0x10(%ebp),%eax
  801848:	89 44 24 08          	mov    %eax,0x8(%esp)
  80184c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80184f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801853:	89 14 24             	mov    %edx,(%esp)
  801856:	ff d1                	call   *%ecx
}
  801858:	83 c4 24             	add    $0x24,%esp
  80185b:	5b                   	pop    %ebx
  80185c:	5d                   	pop    %ebp
  80185d:	c3                   	ret    

0080185e <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80185e:	55                   	push   %ebp
  80185f:	89 e5                	mov    %esp,%ebp
  801861:	53                   	push   %ebx
  801862:	83 ec 24             	sub    $0x24,%esp
  801865:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801868:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80186b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80186f:	89 1c 24             	mov    %ebx,(%esp)
  801872:	e8 86 fd ff ff       	call   8015fd <fd_lookup>
  801877:	85 c0                	test   %eax,%eax
  801879:	78 6b                	js     8018e6 <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80187b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80187e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801882:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801885:	8b 00                	mov    (%eax),%eax
  801887:	89 04 24             	mov    %eax,(%esp)
  80188a:	e8 e2 fd ff ff       	call   801671 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80188f:	85 c0                	test   %eax,%eax
  801891:	78 53                	js     8018e6 <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801893:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801896:	8b 42 08             	mov    0x8(%edx),%eax
  801899:	83 e0 03             	and    $0x3,%eax
  80189c:	83 f8 01             	cmp    $0x1,%eax
  80189f:	75 23                	jne    8018c4 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8018a1:	a1 08 40 80 00       	mov    0x804008,%eax
  8018a6:	8b 40 48             	mov    0x48(%eax),%eax
  8018a9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8018ad:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018b1:	c7 04 24 ca 2b 80 00 	movl   $0x802bca,(%esp)
  8018b8:	e8 9c e8 ff ff       	call   800159 <cprintf>
  8018bd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  8018c2:	eb 22                	jmp    8018e6 <read+0x88>
	}
	if (!dev->dev_read)
  8018c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018c7:	8b 48 08             	mov    0x8(%eax),%ecx
  8018ca:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8018cf:	85 c9                	test   %ecx,%ecx
  8018d1:	74 13                	je     8018e6 <read+0x88>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8018d3:	8b 45 10             	mov    0x10(%ebp),%eax
  8018d6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8018da:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018e1:	89 14 24             	mov    %edx,(%esp)
  8018e4:	ff d1                	call   *%ecx
}
  8018e6:	83 c4 24             	add    $0x24,%esp
  8018e9:	5b                   	pop    %ebx
  8018ea:	5d                   	pop    %ebp
  8018eb:	c3                   	ret    

008018ec <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8018ec:	55                   	push   %ebp
  8018ed:	89 e5                	mov    %esp,%ebp
  8018ef:	57                   	push   %edi
  8018f0:	56                   	push   %esi
  8018f1:	53                   	push   %ebx
  8018f2:	83 ec 1c             	sub    $0x1c,%esp
  8018f5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8018f8:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8018fb:	ba 00 00 00 00       	mov    $0x0,%edx
  801900:	bb 00 00 00 00       	mov    $0x0,%ebx
  801905:	b8 00 00 00 00       	mov    $0x0,%eax
  80190a:	85 f6                	test   %esi,%esi
  80190c:	74 29                	je     801937 <readn+0x4b>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80190e:	89 f0                	mov    %esi,%eax
  801910:	29 d0                	sub    %edx,%eax
  801912:	89 44 24 08          	mov    %eax,0x8(%esp)
  801916:	03 55 0c             	add    0xc(%ebp),%edx
  801919:	89 54 24 04          	mov    %edx,0x4(%esp)
  80191d:	89 3c 24             	mov    %edi,(%esp)
  801920:	e8 39 ff ff ff       	call   80185e <read>
		if (m < 0)
  801925:	85 c0                	test   %eax,%eax
  801927:	78 0e                	js     801937 <readn+0x4b>
			return m;
		if (m == 0)
  801929:	85 c0                	test   %eax,%eax
  80192b:	74 08                	je     801935 <readn+0x49>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80192d:	01 c3                	add    %eax,%ebx
  80192f:	89 da                	mov    %ebx,%edx
  801931:	39 f3                	cmp    %esi,%ebx
  801933:	72 d9                	jb     80190e <readn+0x22>
  801935:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801937:	83 c4 1c             	add    $0x1c,%esp
  80193a:	5b                   	pop    %ebx
  80193b:	5e                   	pop    %esi
  80193c:	5f                   	pop    %edi
  80193d:	5d                   	pop    %ebp
  80193e:	c3                   	ret    

0080193f <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80193f:	55                   	push   %ebp
  801940:	89 e5                	mov    %esp,%ebp
  801942:	56                   	push   %esi
  801943:	53                   	push   %ebx
  801944:	83 ec 20             	sub    $0x20,%esp
  801947:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80194a:	89 34 24             	mov    %esi,(%esp)
  80194d:	e8 0e fc ff ff       	call   801560 <fd2num>
  801952:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801955:	89 54 24 04          	mov    %edx,0x4(%esp)
  801959:	89 04 24             	mov    %eax,(%esp)
  80195c:	e8 9c fc ff ff       	call   8015fd <fd_lookup>
  801961:	89 c3                	mov    %eax,%ebx
  801963:	85 c0                	test   %eax,%eax
  801965:	78 05                	js     80196c <fd_close+0x2d>
  801967:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80196a:	74 0c                	je     801978 <fd_close+0x39>
	    || fd != fd2)
		return (must_exist ? r : 0);
  80196c:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  801970:	19 c0                	sbb    %eax,%eax
  801972:	f7 d0                	not    %eax
  801974:	21 c3                	and    %eax,%ebx
  801976:	eb 3d                	jmp    8019b5 <fd_close+0x76>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801978:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80197b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80197f:	8b 06                	mov    (%esi),%eax
  801981:	89 04 24             	mov    %eax,(%esp)
  801984:	e8 e8 fc ff ff       	call   801671 <dev_lookup>
  801989:	89 c3                	mov    %eax,%ebx
  80198b:	85 c0                	test   %eax,%eax
  80198d:	78 16                	js     8019a5 <fd_close+0x66>
		if (dev->dev_close)
  80198f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801992:	8b 40 10             	mov    0x10(%eax),%eax
  801995:	bb 00 00 00 00       	mov    $0x0,%ebx
  80199a:	85 c0                	test   %eax,%eax
  80199c:	74 07                	je     8019a5 <fd_close+0x66>
			r = (*dev->dev_close)(fd);
  80199e:	89 34 24             	mov    %esi,(%esp)
  8019a1:	ff d0                	call   *%eax
  8019a3:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8019a5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8019a9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019b0:	e8 29 f9 ff ff       	call   8012de <sys_page_unmap>
	return r;
}
  8019b5:	89 d8                	mov    %ebx,%eax
  8019b7:	83 c4 20             	add    $0x20,%esp
  8019ba:	5b                   	pop    %ebx
  8019bb:	5e                   	pop    %esi
  8019bc:	5d                   	pop    %ebp
  8019bd:	c3                   	ret    

008019be <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8019be:	55                   	push   %ebp
  8019bf:	89 e5                	mov    %esp,%ebp
  8019c1:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8019c4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019c7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8019ce:	89 04 24             	mov    %eax,(%esp)
  8019d1:	e8 27 fc ff ff       	call   8015fd <fd_lookup>
  8019d6:	85 c0                	test   %eax,%eax
  8019d8:	78 13                	js     8019ed <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  8019da:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8019e1:	00 
  8019e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019e5:	89 04 24             	mov    %eax,(%esp)
  8019e8:	e8 52 ff ff ff       	call   80193f <fd_close>
}
  8019ed:	c9                   	leave  
  8019ee:	c3                   	ret    

008019ef <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  8019ef:	55                   	push   %ebp
  8019f0:	89 e5                	mov    %esp,%ebp
  8019f2:	83 ec 18             	sub    $0x18,%esp
  8019f5:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8019f8:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8019fb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801a02:	00 
  801a03:	8b 45 08             	mov    0x8(%ebp),%eax
  801a06:	89 04 24             	mov    %eax,(%esp)
  801a09:	e8 79 03 00 00       	call   801d87 <open>
  801a0e:	89 c3                	mov    %eax,%ebx
  801a10:	85 c0                	test   %eax,%eax
  801a12:	78 1b                	js     801a2f <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  801a14:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a17:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a1b:	89 1c 24             	mov    %ebx,(%esp)
  801a1e:	e8 b7 fc ff ff       	call   8016da <fstat>
  801a23:	89 c6                	mov    %eax,%esi
	close(fd);
  801a25:	89 1c 24             	mov    %ebx,(%esp)
  801a28:	e8 91 ff ff ff       	call   8019be <close>
  801a2d:	89 f3                	mov    %esi,%ebx
	return r;
}
  801a2f:	89 d8                	mov    %ebx,%eax
  801a31:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801a34:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801a37:	89 ec                	mov    %ebp,%esp
  801a39:	5d                   	pop    %ebp
  801a3a:	c3                   	ret    

00801a3b <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  801a3b:	55                   	push   %ebp
  801a3c:	89 e5                	mov    %esp,%ebp
  801a3e:	53                   	push   %ebx
  801a3f:	83 ec 14             	sub    $0x14,%esp
  801a42:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  801a47:	89 1c 24             	mov    %ebx,(%esp)
  801a4a:	e8 6f ff ff ff       	call   8019be <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801a4f:	83 c3 01             	add    $0x1,%ebx
  801a52:	83 fb 20             	cmp    $0x20,%ebx
  801a55:	75 f0                	jne    801a47 <close_all+0xc>
		close(i);
}
  801a57:	83 c4 14             	add    $0x14,%esp
  801a5a:	5b                   	pop    %ebx
  801a5b:	5d                   	pop    %ebp
  801a5c:	c3                   	ret    

00801a5d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801a5d:	55                   	push   %ebp
  801a5e:	89 e5                	mov    %esp,%ebp
  801a60:	83 ec 58             	sub    $0x58,%esp
  801a63:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801a66:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801a69:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801a6c:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801a6f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801a72:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a76:	8b 45 08             	mov    0x8(%ebp),%eax
  801a79:	89 04 24             	mov    %eax,(%esp)
  801a7c:	e8 7c fb ff ff       	call   8015fd <fd_lookup>
  801a81:	89 c3                	mov    %eax,%ebx
  801a83:	85 c0                	test   %eax,%eax
  801a85:	0f 88 e0 00 00 00    	js     801b6b <dup+0x10e>
		return r;
	close(newfdnum);
  801a8b:	89 3c 24             	mov    %edi,(%esp)
  801a8e:	e8 2b ff ff ff       	call   8019be <close>

	newfd = INDEX2FD(newfdnum);
  801a93:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801a99:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801a9c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a9f:	89 04 24             	mov    %eax,(%esp)
  801aa2:	e8 c9 fa ff ff       	call   801570 <fd2data>
  801aa7:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801aa9:	89 34 24             	mov    %esi,(%esp)
  801aac:	e8 bf fa ff ff       	call   801570 <fd2data>
  801ab1:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
  801ab4:	89 da                	mov    %ebx,%edx
  801ab6:	89 d8                	mov    %ebx,%eax
  801ab8:	c1 e8 16             	shr    $0x16,%eax
  801abb:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801ac2:	a8 01                	test   $0x1,%al
  801ac4:	74 43                	je     801b09 <dup+0xac>
  801ac6:	c1 ea 0c             	shr    $0xc,%edx
  801ac9:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801ad0:	a8 01                	test   $0x1,%al
  801ad2:	74 35                	je     801b09 <dup+0xac>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801ad4:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801adb:	25 07 0e 00 00       	and    $0xe07,%eax
  801ae0:	89 44 24 10          	mov    %eax,0x10(%esp)
  801ae4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801ae7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801aeb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801af2:	00 
  801af3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801af7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801afe:	e8 47 f8 ff ff       	call   80134a <sys_page_map>
  801b03:	89 c3                	mov    %eax,%ebx
  801b05:	85 c0                	test   %eax,%eax
  801b07:	78 3f                	js     801b48 <dup+0xeb>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801b09:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b0c:	89 c2                	mov    %eax,%edx
  801b0e:	c1 ea 0c             	shr    $0xc,%edx
  801b11:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801b18:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801b1e:	89 54 24 10          	mov    %edx,0x10(%esp)
  801b22:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801b26:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801b2d:	00 
  801b2e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b32:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b39:	e8 0c f8 ff ff       	call   80134a <sys_page_map>
  801b3e:	89 c3                	mov    %eax,%ebx
  801b40:	85 c0                	test   %eax,%eax
  801b42:	78 04                	js     801b48 <dup+0xeb>
  801b44:	89 fb                	mov    %edi,%ebx
  801b46:	eb 23                	jmp    801b6b <dup+0x10e>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801b48:	89 74 24 04          	mov    %esi,0x4(%esp)
  801b4c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b53:	e8 86 f7 ff ff       	call   8012de <sys_page_unmap>
	sys_page_unmap(0, nva);
  801b58:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801b5b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b5f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b66:	e8 73 f7 ff ff       	call   8012de <sys_page_unmap>
	return r;
}
  801b6b:	89 d8                	mov    %ebx,%eax
  801b6d:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801b70:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801b73:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801b76:	89 ec                	mov    %ebp,%esp
  801b78:	5d                   	pop    %ebp
  801b79:	c3                   	ret    
	...

00801b7c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801b7c:	55                   	push   %ebp
  801b7d:	89 e5                	mov    %esp,%ebp
  801b7f:	83 ec 18             	sub    $0x18,%esp
  801b82:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801b85:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801b88:	89 c3                	mov    %eax,%ebx
  801b8a:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801b8c:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801b93:	75 11                	jne    801ba6 <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801b95:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801b9c:	e8 ef 07 00 00       	call   802390 <ipc_find_env>
  801ba1:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801ba6:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801bad:	00 
  801bae:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801bb5:	00 
  801bb6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801bba:	a1 00 40 80 00       	mov    0x804000,%eax
  801bbf:	89 04 24             	mov    %eax,(%esp)
  801bc2:	e8 14 08 00 00       	call   8023db <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801bc7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801bce:	00 
  801bcf:	89 74 24 04          	mov    %esi,0x4(%esp)
  801bd3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801bda:	e8 7a 08 00 00       	call   802459 <ipc_recv>
}
  801bdf:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801be2:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801be5:	89 ec                	mov    %ebp,%esp
  801be7:	5d                   	pop    %ebp
  801be8:	c3                   	ret    

00801be9 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801be9:	55                   	push   %ebp
  801bea:	89 e5                	mov    %esp,%ebp
  801bec:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801bef:	8b 45 08             	mov    0x8(%ebp),%eax
  801bf2:	8b 40 0c             	mov    0xc(%eax),%eax
  801bf5:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801bfa:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bfd:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801c02:	ba 00 00 00 00       	mov    $0x0,%edx
  801c07:	b8 02 00 00 00       	mov    $0x2,%eax
  801c0c:	e8 6b ff ff ff       	call   801b7c <fsipc>
}
  801c11:	c9                   	leave  
  801c12:	c3                   	ret    

00801c13 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801c13:	55                   	push   %ebp
  801c14:	89 e5                	mov    %esp,%ebp
  801c16:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801c19:	8b 45 08             	mov    0x8(%ebp),%eax
  801c1c:	8b 40 0c             	mov    0xc(%eax),%eax
  801c1f:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801c24:	ba 00 00 00 00       	mov    $0x0,%edx
  801c29:	b8 06 00 00 00       	mov    $0x6,%eax
  801c2e:	e8 49 ff ff ff       	call   801b7c <fsipc>
}
  801c33:	c9                   	leave  
  801c34:	c3                   	ret    

00801c35 <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  801c35:	55                   	push   %ebp
  801c36:	89 e5                	mov    %esp,%ebp
  801c38:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801c3b:	ba 00 00 00 00       	mov    $0x0,%edx
  801c40:	b8 08 00 00 00       	mov    $0x8,%eax
  801c45:	e8 32 ff ff ff       	call   801b7c <fsipc>
}
  801c4a:	c9                   	leave  
  801c4b:	c3                   	ret    

00801c4c <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801c4c:	55                   	push   %ebp
  801c4d:	89 e5                	mov    %esp,%ebp
  801c4f:	53                   	push   %ebx
  801c50:	83 ec 14             	sub    $0x14,%esp
  801c53:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801c56:	8b 45 08             	mov    0x8(%ebp),%eax
  801c59:	8b 40 0c             	mov    0xc(%eax),%eax
  801c5c:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801c61:	ba 00 00 00 00       	mov    $0x0,%edx
  801c66:	b8 05 00 00 00       	mov    $0x5,%eax
  801c6b:	e8 0c ff ff ff       	call   801b7c <fsipc>
  801c70:	85 c0                	test   %eax,%eax
  801c72:	78 2b                	js     801c9f <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801c74:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801c7b:	00 
  801c7c:	89 1c 24             	mov    %ebx,(%esp)
  801c7f:	e8 06 ee ff ff       	call   800a8a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801c84:	a1 80 50 80 00       	mov    0x805080,%eax
  801c89:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801c8f:	a1 84 50 80 00       	mov    0x805084,%eax
  801c94:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  801c9a:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  801c9f:	83 c4 14             	add    $0x14,%esp
  801ca2:	5b                   	pop    %ebx
  801ca3:	5d                   	pop    %ebp
  801ca4:	c3                   	ret    

00801ca5 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801ca5:	55                   	push   %ebp
  801ca6:	89 e5                	mov    %esp,%ebp
  801ca8:	83 ec 18             	sub    $0x18,%esp
  801cab:	8b 45 10             	mov    0x10(%ebp),%eax
  801cae:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801cb3:	76 05                	jbe    801cba <devfile_write+0x15>
  801cb5:	b8 f8 0f 00 00       	mov    $0xff8,%eax
	// bytes than requested.
	// LAB 5: Your code here
        int r;
        if(n > sizeof(fsipcbuf.write.req_buf))
            n = sizeof(fsipcbuf.write.req_buf);
        fsipcbuf.write.req_fileid = fd->fd_file.id;
  801cba:	8b 55 08             	mov    0x8(%ebp),%edx
  801cbd:	8b 52 0c             	mov    0xc(%edx),%edx
  801cc0:	89 15 00 50 80 00    	mov    %edx,0x805000
        fsipcbuf.write.req_n = n;
  801cc6:	a3 04 50 80 00       	mov    %eax,0x805004
        memmove(fsipcbuf.write.req_buf,buf,n);  
  801ccb:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ccf:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cd2:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cd6:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  801cdd:	e8 93 ef ff ff       	call   800c75 <memmove>
        r = fsipc(FSREQ_WRITE,NULL);
  801ce2:	ba 00 00 00 00       	mov    $0x0,%edx
  801ce7:	b8 04 00 00 00       	mov    $0x4,%eax
  801cec:	e8 8b fe ff ff       	call   801b7c <fsipc>
        return r;
	//panic("devfile_write not implemented");
}
  801cf1:	c9                   	leave  
  801cf2:	c3                   	ret    

00801cf3 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801cf3:	55                   	push   %ebp
  801cf4:	89 e5                	mov    %esp,%ebp
  801cf6:	53                   	push   %ebx
  801cf7:	83 ec 14             	sub    $0x14,%esp
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
        int r;
        fsipcbuf.read.req_fileid = fd->fd_file.id;
  801cfa:	8b 45 08             	mov    0x8(%ebp),%eax
  801cfd:	8b 40 0c             	mov    0xc(%eax),%eax
  801d00:	a3 00 50 80 00       	mov    %eax,0x805000
        fsipcbuf.read.req_n = n;
  801d05:	8b 45 10             	mov    0x10(%ebp),%eax
  801d08:	a3 04 50 80 00       	mov    %eax,0x805004
        r = fsipc(FSREQ_READ,NULL);
  801d0d:	ba 00 00 00 00       	mov    $0x0,%edx
  801d12:	b8 03 00 00 00       	mov    $0x3,%eax
  801d17:	e8 60 fe ff ff       	call   801b7c <fsipc>
  801d1c:	89 c3                	mov    %eax,%ebx
        if(r < 0)
  801d1e:	85 c0                	test   %eax,%eax
  801d20:	78 17                	js     801d39 <devfile_read+0x46>
           return r;
        memmove(buf,fsipcbuf.readRet.ret_buf,r);
  801d22:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d26:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801d2d:	00 
  801d2e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d31:	89 04 24             	mov    %eax,(%esp)
  801d34:	e8 3c ef ff ff       	call   800c75 <memmove>
        return r;
	//panic("devfile_read not implemented");
}
  801d39:	89 d8                	mov    %ebx,%eax
  801d3b:	83 c4 14             	add    $0x14,%esp
  801d3e:	5b                   	pop    %ebx
  801d3f:	5d                   	pop    %ebp
  801d40:	c3                   	ret    

00801d41 <remove>:
}

// Delete a file
int
remove(const char *path)
{
  801d41:	55                   	push   %ebp
  801d42:	89 e5                	mov    %esp,%ebp
  801d44:	53                   	push   %ebx
  801d45:	83 ec 14             	sub    $0x14,%esp
  801d48:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  801d4b:	89 1c 24             	mov    %ebx,(%esp)
  801d4e:	e8 ed ec ff ff       	call   800a40 <strlen>
  801d53:	89 c2                	mov    %eax,%edx
  801d55:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  801d5a:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
  801d60:	7f 1f                	jg     801d81 <remove+0x40>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  801d62:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801d66:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801d6d:	e8 18 ed ff ff       	call   800a8a <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  801d72:	ba 00 00 00 00       	mov    $0x0,%edx
  801d77:	b8 07 00 00 00       	mov    $0x7,%eax
  801d7c:	e8 fb fd ff ff       	call   801b7c <fsipc>
}
  801d81:	83 c4 14             	add    $0x14,%esp
  801d84:	5b                   	pop    %ebx
  801d85:	5d                   	pop    %ebp
  801d86:	c3                   	ret    

00801d87 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801d87:	55                   	push   %ebp
  801d88:	89 e5                	mov    %esp,%ebp
  801d8a:	83 ec 28             	sub    $0x28,%esp
  801d8d:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801d90:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801d93:	8b 75 08             	mov    0x8(%ebp),%esi
	// If any step after fd_alloc fails, use fd_close to free the
	// file descriptor.

	// LAB 5: Your code here.
        struct Fd* fd;
        if(strlen(path) > MAXPATHLEN)
  801d96:	89 34 24             	mov    %esi,(%esp)
  801d99:	e8 a2 ec ff ff       	call   800a40 <strlen>
  801d9e:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801da3:	3d 00 04 00 00       	cmp    $0x400,%eax
  801da8:	7f 6d                	jg     801e17 <open+0x90>
            return -E_BAD_PATH;
        int r;
        r = fd_alloc(&fd);
  801daa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801dad:	89 04 24             	mov    %eax,(%esp)
  801db0:	e8 d6 f7 ff ff       	call   80158b <fd_alloc>
  801db5:	89 c3                	mov    %eax,%ebx
        if(r < 0)
  801db7:	85 c0                	test   %eax,%eax
  801db9:	78 5c                	js     801e17 <open+0x90>
           return r;
        fsipcbuf.open.req_omode = mode;
  801dbb:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dbe:	a3 00 54 80 00       	mov    %eax,0x805400
        memmove(fsipcbuf.open.req_path,path,strlen(path)+1);
  801dc3:	89 34 24             	mov    %esi,(%esp)
  801dc6:	e8 75 ec ff ff       	call   800a40 <strlen>
  801dcb:	83 c0 01             	add    $0x1,%eax
  801dce:	89 44 24 08          	mov    %eax,0x8(%esp)
  801dd2:	89 74 24 04          	mov    %esi,0x4(%esp)
  801dd6:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801ddd:	e8 93 ee ff ff       	call   800c75 <memmove>
        r = fsipc(FSREQ_OPEN,(void*)fd);
  801de2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801de5:	b8 01 00 00 00       	mov    $0x1,%eax
  801dea:	e8 8d fd ff ff       	call   801b7c <fsipc>
  801def:	89 c3                	mov    %eax,%ebx
        if(r < 0){
  801df1:	85 c0                	test   %eax,%eax
  801df3:	79 15                	jns    801e0a <open+0x83>
             fd_close(fd,0);
  801df5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801dfc:	00 
  801dfd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e00:	89 04 24             	mov    %eax,(%esp)
  801e03:	e8 37 fb ff ff       	call   80193f <fd_close>
             return r;
  801e08:	eb 0d                	jmp    801e17 <open+0x90>
        }
        return fd2num(fd);
  801e0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e0d:	89 04 24             	mov    %eax,(%esp)
  801e10:	e8 4b f7 ff ff       	call   801560 <fd2num>
  801e15:	89 c3                	mov    %eax,%ebx
	//panic("open not implemented");
}
  801e17:	89 d8                	mov    %ebx,%eax
  801e19:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801e1c:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801e1f:	89 ec                	mov    %ebp,%esp
  801e21:	5d                   	pop    %ebp
  801e22:	c3                   	ret    
	...

00801e30 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801e30:	55                   	push   %ebp
  801e31:	89 e5                	mov    %esp,%ebp
  801e33:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  801e36:	c7 44 24 04 f4 2b 80 	movl   $0x802bf4,0x4(%esp)
  801e3d:	00 
  801e3e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e41:	89 04 24             	mov    %eax,(%esp)
  801e44:	e8 41 ec ff ff       	call   800a8a <strcpy>
	return 0;
}
  801e49:	b8 00 00 00 00       	mov    $0x0,%eax
  801e4e:	c9                   	leave  
  801e4f:	c3                   	ret    

00801e50 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801e50:	55                   	push   %ebp
  801e51:	89 e5                	mov    %esp,%ebp
  801e53:	53                   	push   %ebx
  801e54:	83 ec 14             	sub    $0x14,%esp
  801e57:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801e5a:	89 1c 24             	mov    %ebx,(%esp)
  801e5d:	e8 6a 06 00 00       	call   8024cc <pageref>
  801e62:	89 c2                	mov    %eax,%edx
  801e64:	b8 00 00 00 00       	mov    $0x0,%eax
  801e69:	83 fa 01             	cmp    $0x1,%edx
  801e6c:	75 0b                	jne    801e79 <devsock_close+0x29>
		return nsipc_close(fd->fd_sock.sockid);
  801e6e:	8b 43 0c             	mov    0xc(%ebx),%eax
  801e71:	89 04 24             	mov    %eax,(%esp)
  801e74:	e8 b9 02 00 00       	call   802132 <nsipc_close>
	else
		return 0;
}
  801e79:	83 c4 14             	add    $0x14,%esp
  801e7c:	5b                   	pop    %ebx
  801e7d:	5d                   	pop    %ebp
  801e7e:	c3                   	ret    

00801e7f <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801e7f:	55                   	push   %ebp
  801e80:	89 e5                	mov    %esp,%ebp
  801e82:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801e85:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801e8c:	00 
  801e8d:	8b 45 10             	mov    0x10(%ebp),%eax
  801e90:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e94:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e97:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e9b:	8b 45 08             	mov    0x8(%ebp),%eax
  801e9e:	8b 40 0c             	mov    0xc(%eax),%eax
  801ea1:	89 04 24             	mov    %eax,(%esp)
  801ea4:	e8 c5 02 00 00       	call   80216e <nsipc_send>
}
  801ea9:	c9                   	leave  
  801eaa:	c3                   	ret    

00801eab <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801eab:	55                   	push   %ebp
  801eac:	89 e5                	mov    %esp,%ebp
  801eae:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801eb1:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801eb8:	00 
  801eb9:	8b 45 10             	mov    0x10(%ebp),%eax
  801ebc:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ec0:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ec3:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ec7:	8b 45 08             	mov    0x8(%ebp),%eax
  801eca:	8b 40 0c             	mov    0xc(%eax),%eax
  801ecd:	89 04 24             	mov    %eax,(%esp)
  801ed0:	e8 0c 03 00 00       	call   8021e1 <nsipc_recv>
}
  801ed5:	c9                   	leave  
  801ed6:	c3                   	ret    

00801ed7 <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  801ed7:	55                   	push   %ebp
  801ed8:	89 e5                	mov    %esp,%ebp
  801eda:	56                   	push   %esi
  801edb:	53                   	push   %ebx
  801edc:	83 ec 20             	sub    $0x20,%esp
  801edf:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801ee1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ee4:	89 04 24             	mov    %eax,(%esp)
  801ee7:	e8 9f f6 ff ff       	call   80158b <fd_alloc>
  801eec:	89 c3                	mov    %eax,%ebx
  801eee:	85 c0                	test   %eax,%eax
  801ef0:	78 21                	js     801f13 <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801ef2:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801ef9:	00 
  801efa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801efd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f01:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f08:	e8 ab f4 ff ff       	call   8013b8 <sys_page_alloc>
  801f0d:	89 c3                	mov    %eax,%ebx
alloc_sockfd(int sockid)
{
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801f0f:	85 c0                	test   %eax,%eax
  801f11:	79 0a                	jns    801f1d <alloc_sockfd+0x46>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
		nsipc_close(sockid);
  801f13:	89 34 24             	mov    %esi,(%esp)
  801f16:	e8 17 02 00 00       	call   802132 <nsipc_close>
		return r;
  801f1b:	eb 28                	jmp    801f45 <alloc_sockfd+0x6e>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801f1d:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801f23:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f26:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801f28:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f2b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801f32:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f35:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801f38:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f3b:	89 04 24             	mov    %eax,(%esp)
  801f3e:	e8 1d f6 ff ff       	call   801560 <fd2num>
  801f43:	89 c3                	mov    %eax,%ebx
}
  801f45:	89 d8                	mov    %ebx,%eax
  801f47:	83 c4 20             	add    $0x20,%esp
  801f4a:	5b                   	pop    %ebx
  801f4b:	5e                   	pop    %esi
  801f4c:	5d                   	pop    %ebp
  801f4d:	c3                   	ret    

00801f4e <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801f4e:	55                   	push   %ebp
  801f4f:	89 e5                	mov    %esp,%ebp
  801f51:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801f54:	8b 45 10             	mov    0x10(%ebp),%eax
  801f57:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f5b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f5e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f62:	8b 45 08             	mov    0x8(%ebp),%eax
  801f65:	89 04 24             	mov    %eax,(%esp)
  801f68:	e8 79 01 00 00       	call   8020e6 <nsipc_socket>
  801f6d:	85 c0                	test   %eax,%eax
  801f6f:	78 05                	js     801f76 <socket+0x28>
		return r;
	return alloc_sockfd(r);
  801f71:	e8 61 ff ff ff       	call   801ed7 <alloc_sockfd>
}
  801f76:	c9                   	leave  
  801f77:	c3                   	ret    

00801f78 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801f78:	55                   	push   %ebp
  801f79:	89 e5                	mov    %esp,%ebp
  801f7b:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801f7e:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801f81:	89 54 24 04          	mov    %edx,0x4(%esp)
  801f85:	89 04 24             	mov    %eax,(%esp)
  801f88:	e8 70 f6 ff ff       	call   8015fd <fd_lookup>
  801f8d:	85 c0                	test   %eax,%eax
  801f8f:	78 15                	js     801fa6 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801f91:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801f94:	8b 0a                	mov    (%edx),%ecx
  801f96:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801f9b:	3b 0d 20 30 80 00    	cmp    0x803020,%ecx
  801fa1:	75 03                	jne    801fa6 <fd2sockid+0x2e>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801fa3:	8b 42 0c             	mov    0xc(%edx),%eax
}
  801fa6:	c9                   	leave  
  801fa7:	c3                   	ret    

00801fa8 <listen>:
	return nsipc_connect(r, name, namelen);
}

int
listen(int s, int backlog)
{
  801fa8:	55                   	push   %ebp
  801fa9:	89 e5                	mov    %esp,%ebp
  801fab:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801fae:	8b 45 08             	mov    0x8(%ebp),%eax
  801fb1:	e8 c2 ff ff ff       	call   801f78 <fd2sockid>
  801fb6:	85 c0                	test   %eax,%eax
  801fb8:	78 0f                	js     801fc9 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801fba:	8b 55 0c             	mov    0xc(%ebp),%edx
  801fbd:	89 54 24 04          	mov    %edx,0x4(%esp)
  801fc1:	89 04 24             	mov    %eax,(%esp)
  801fc4:	e8 47 01 00 00       	call   802110 <nsipc_listen>
}
  801fc9:	c9                   	leave  
  801fca:	c3                   	ret    

00801fcb <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801fcb:	55                   	push   %ebp
  801fcc:	89 e5                	mov    %esp,%ebp
  801fce:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801fd1:	8b 45 08             	mov    0x8(%ebp),%eax
  801fd4:	e8 9f ff ff ff       	call   801f78 <fd2sockid>
  801fd9:	85 c0                	test   %eax,%eax
  801fdb:	78 16                	js     801ff3 <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  801fdd:	8b 55 10             	mov    0x10(%ebp),%edx
  801fe0:	89 54 24 08          	mov    %edx,0x8(%esp)
  801fe4:	8b 55 0c             	mov    0xc(%ebp),%edx
  801fe7:	89 54 24 04          	mov    %edx,0x4(%esp)
  801feb:	89 04 24             	mov    %eax,(%esp)
  801fee:	e8 6e 02 00 00       	call   802261 <nsipc_connect>
}
  801ff3:	c9                   	leave  
  801ff4:	c3                   	ret    

00801ff5 <shutdown>:
	return nsipc_bind(r, name, namelen);
}

int
shutdown(int s, int how)
{
  801ff5:	55                   	push   %ebp
  801ff6:	89 e5                	mov    %esp,%ebp
  801ff8:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801ffb:	8b 45 08             	mov    0x8(%ebp),%eax
  801ffe:	e8 75 ff ff ff       	call   801f78 <fd2sockid>
  802003:	85 c0                	test   %eax,%eax
  802005:	78 0f                	js     802016 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  802007:	8b 55 0c             	mov    0xc(%ebp),%edx
  80200a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80200e:	89 04 24             	mov    %eax,(%esp)
  802011:	e8 36 01 00 00       	call   80214c <nsipc_shutdown>
}
  802016:	c9                   	leave  
  802017:	c3                   	ret    

00802018 <bind>:
	return alloc_sockfd(r);
}

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802018:	55                   	push   %ebp
  802019:	89 e5                	mov    %esp,%ebp
  80201b:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80201e:	8b 45 08             	mov    0x8(%ebp),%eax
  802021:	e8 52 ff ff ff       	call   801f78 <fd2sockid>
  802026:	85 c0                	test   %eax,%eax
  802028:	78 16                	js     802040 <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  80202a:	8b 55 10             	mov    0x10(%ebp),%edx
  80202d:	89 54 24 08          	mov    %edx,0x8(%esp)
  802031:	8b 55 0c             	mov    0xc(%ebp),%edx
  802034:	89 54 24 04          	mov    %edx,0x4(%esp)
  802038:	89 04 24             	mov    %eax,(%esp)
  80203b:	e8 60 02 00 00       	call   8022a0 <nsipc_bind>
}
  802040:	c9                   	leave  
  802041:	c3                   	ret    

00802042 <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  802042:	55                   	push   %ebp
  802043:	89 e5                	mov    %esp,%ebp
  802045:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802048:	8b 45 08             	mov    0x8(%ebp),%eax
  80204b:	e8 28 ff ff ff       	call   801f78 <fd2sockid>
  802050:	85 c0                	test   %eax,%eax
  802052:	78 1f                	js     802073 <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  802054:	8b 55 10             	mov    0x10(%ebp),%edx
  802057:	89 54 24 08          	mov    %edx,0x8(%esp)
  80205b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80205e:	89 54 24 04          	mov    %edx,0x4(%esp)
  802062:	89 04 24             	mov    %eax,(%esp)
  802065:	e8 75 02 00 00       	call   8022df <nsipc_accept>
  80206a:	85 c0                	test   %eax,%eax
  80206c:	78 05                	js     802073 <accept+0x31>
		return r;
	return alloc_sockfd(r);
  80206e:	e8 64 fe ff ff       	call   801ed7 <alloc_sockfd>
}
  802073:	c9                   	leave  
  802074:	c3                   	ret    
	...

00802080 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  802080:	55                   	push   %ebp
  802081:	89 e5                	mov    %esp,%ebp
  802083:	53                   	push   %ebx
  802084:	83 ec 14             	sub    $0x14,%esp
  802087:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  802089:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  802090:	75 11                	jne    8020a3 <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  802092:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  802099:	e8 f2 02 00 00       	call   802390 <ipc_find_env>
  80209e:	a3 04 40 80 00       	mov    %eax,0x804004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  8020a3:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8020aa:	00 
  8020ab:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  8020b2:	00 
  8020b3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8020b7:	a1 04 40 80 00       	mov    0x804004,%eax
  8020bc:	89 04 24             	mov    %eax,(%esp)
  8020bf:	e8 17 03 00 00       	call   8023db <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  8020c4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8020cb:	00 
  8020cc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8020d3:	00 
  8020d4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020db:	e8 79 03 00 00       	call   802459 <ipc_recv>
}
  8020e0:	83 c4 14             	add    $0x14,%esp
  8020e3:	5b                   	pop    %ebx
  8020e4:	5d                   	pop    %ebp
  8020e5:	c3                   	ret    

008020e6 <nsipc_socket>:
	return nsipc(NSREQ_SEND);
}

int
nsipc_socket(int domain, int type, int protocol)
{
  8020e6:	55                   	push   %ebp
  8020e7:	89 e5                	mov    %esp,%ebp
  8020e9:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  8020ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8020ef:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  8020f4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020f7:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  8020fc:	8b 45 10             	mov    0x10(%ebp),%eax
  8020ff:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  802104:	b8 09 00 00 00       	mov    $0x9,%eax
  802109:	e8 72 ff ff ff       	call   802080 <nsipc>
}
  80210e:	c9                   	leave  
  80210f:	c3                   	ret    

00802110 <nsipc_listen>:
	return nsipc(NSREQ_CONNECT);
}

int
nsipc_listen(int s, int backlog)
{
  802110:	55                   	push   %ebp
  802111:	89 e5                	mov    %esp,%ebp
  802113:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  802116:	8b 45 08             	mov    0x8(%ebp),%eax
  802119:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  80211e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802121:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  802126:	b8 06 00 00 00       	mov    $0x6,%eax
  80212b:	e8 50 ff ff ff       	call   802080 <nsipc>
}
  802130:	c9                   	leave  
  802131:	c3                   	ret    

00802132 <nsipc_close>:
	return nsipc(NSREQ_SHUTDOWN);
}

int
nsipc_close(int s)
{
  802132:	55                   	push   %ebp
  802133:	89 e5                	mov    %esp,%ebp
  802135:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  802138:	8b 45 08             	mov    0x8(%ebp),%eax
  80213b:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  802140:	b8 04 00 00 00       	mov    $0x4,%eax
  802145:	e8 36 ff ff ff       	call   802080 <nsipc>
}
  80214a:	c9                   	leave  
  80214b:	c3                   	ret    

0080214c <nsipc_shutdown>:
	return nsipc(NSREQ_BIND);
}

int
nsipc_shutdown(int s, int how)
{
  80214c:	55                   	push   %ebp
  80214d:	89 e5                	mov    %esp,%ebp
  80214f:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  802152:	8b 45 08             	mov    0x8(%ebp),%eax
  802155:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  80215a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80215d:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  802162:	b8 03 00 00 00       	mov    $0x3,%eax
  802167:	e8 14 ff ff ff       	call   802080 <nsipc>
}
  80216c:	c9                   	leave  
  80216d:	c3                   	ret    

0080216e <nsipc_send>:
	return r;
}

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  80216e:	55                   	push   %ebp
  80216f:	89 e5                	mov    %esp,%ebp
  802171:	53                   	push   %ebx
  802172:	83 ec 14             	sub    $0x14,%esp
  802175:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  802178:	8b 45 08             	mov    0x8(%ebp),%eax
  80217b:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  802180:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  802186:	7e 24                	jle    8021ac <nsipc_send+0x3e>
  802188:	c7 44 24 0c 00 2c 80 	movl   $0x802c00,0xc(%esp)
  80218f:	00 
  802190:	c7 44 24 08 0c 2c 80 	movl   $0x802c0c,0x8(%esp)
  802197:	00 
  802198:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
  80219f:	00 
  8021a0:	c7 04 24 21 2c 80 00 	movl   $0x802c21,(%esp)
  8021a7:	e8 88 01 00 00       	call   802334 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  8021ac:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8021b0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021b3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021b7:	c7 04 24 0c 60 80 00 	movl   $0x80600c,(%esp)
  8021be:	e8 b2 ea ff ff       	call   800c75 <memmove>
	nsipcbuf.send.req_size = size;
  8021c3:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  8021c9:	8b 45 14             	mov    0x14(%ebp),%eax
  8021cc:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  8021d1:	b8 08 00 00 00       	mov    $0x8,%eax
  8021d6:	e8 a5 fe ff ff       	call   802080 <nsipc>
}
  8021db:	83 c4 14             	add    $0x14,%esp
  8021de:	5b                   	pop    %ebx
  8021df:	5d                   	pop    %ebp
  8021e0:	c3                   	ret    

008021e1 <nsipc_recv>:
	return nsipc(NSREQ_LISTEN);
}

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  8021e1:	55                   	push   %ebp
  8021e2:	89 e5                	mov    %esp,%ebp
  8021e4:	56                   	push   %esi
  8021e5:	53                   	push   %ebx
  8021e6:	83 ec 10             	sub    $0x10,%esp
  8021e9:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  8021ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8021ef:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  8021f4:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  8021fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8021fd:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  802202:	b8 07 00 00 00       	mov    $0x7,%eax
  802207:	e8 74 fe ff ff       	call   802080 <nsipc>
  80220c:	89 c3                	mov    %eax,%ebx
  80220e:	85 c0                	test   %eax,%eax
  802210:	78 46                	js     802258 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  802212:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  802217:	7f 04                	jg     80221d <nsipc_recv+0x3c>
  802219:	39 c6                	cmp    %eax,%esi
  80221b:	7d 24                	jge    802241 <nsipc_recv+0x60>
  80221d:	c7 44 24 0c 2d 2c 80 	movl   $0x802c2d,0xc(%esp)
  802224:	00 
  802225:	c7 44 24 08 0c 2c 80 	movl   $0x802c0c,0x8(%esp)
  80222c:	00 
  80222d:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
  802234:	00 
  802235:	c7 04 24 21 2c 80 00 	movl   $0x802c21,(%esp)
  80223c:	e8 f3 00 00 00       	call   802334 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  802241:	89 44 24 08          	mov    %eax,0x8(%esp)
  802245:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  80224c:	00 
  80224d:	8b 45 0c             	mov    0xc(%ebp),%eax
  802250:	89 04 24             	mov    %eax,(%esp)
  802253:	e8 1d ea ff ff       	call   800c75 <memmove>
	}

	return r;
}
  802258:	89 d8                	mov    %ebx,%eax
  80225a:	83 c4 10             	add    $0x10,%esp
  80225d:	5b                   	pop    %ebx
  80225e:	5e                   	pop    %esi
  80225f:	5d                   	pop    %ebp
  802260:	c3                   	ret    

00802261 <nsipc_connect>:
	return nsipc(NSREQ_CLOSE);
}

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  802261:	55                   	push   %ebp
  802262:	89 e5                	mov    %esp,%ebp
  802264:	53                   	push   %ebx
  802265:	83 ec 14             	sub    $0x14,%esp
  802268:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  80226b:	8b 45 08             	mov    0x8(%ebp),%eax
  80226e:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  802273:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802277:	8b 45 0c             	mov    0xc(%ebp),%eax
  80227a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80227e:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  802285:	e8 eb e9 ff ff       	call   800c75 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  80228a:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  802290:	b8 05 00 00 00       	mov    $0x5,%eax
  802295:	e8 e6 fd ff ff       	call   802080 <nsipc>
}
  80229a:	83 c4 14             	add    $0x14,%esp
  80229d:	5b                   	pop    %ebx
  80229e:	5d                   	pop    %ebp
  80229f:	c3                   	ret    

008022a0 <nsipc_bind>:
	return r;
}

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8022a0:	55                   	push   %ebp
  8022a1:	89 e5                	mov    %esp,%ebp
  8022a3:	53                   	push   %ebx
  8022a4:	83 ec 14             	sub    $0x14,%esp
  8022a7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  8022aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8022ad:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  8022b2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8022b6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022b9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022bd:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  8022c4:	e8 ac e9 ff ff       	call   800c75 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  8022c9:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  8022cf:	b8 02 00 00 00       	mov    $0x2,%eax
  8022d4:	e8 a7 fd ff ff       	call   802080 <nsipc>
}
  8022d9:	83 c4 14             	add    $0x14,%esp
  8022dc:	5b                   	pop    %ebx
  8022dd:	5d                   	pop    %ebp
  8022de:	c3                   	ret    

008022df <nsipc_accept>:
	return ipc_recv(NULL, NULL, NULL);
}

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8022df:	55                   	push   %ebp
  8022e0:	89 e5                	mov    %esp,%ebp
  8022e2:	83 ec 18             	sub    $0x18,%esp
  8022e5:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8022e8:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int r;

	nsipcbuf.accept.req_s = s;
  8022eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8022ee:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  8022f3:	b8 01 00 00 00       	mov    $0x1,%eax
  8022f8:	e8 83 fd ff ff       	call   802080 <nsipc>
  8022fd:	89 c3                	mov    %eax,%ebx
  8022ff:	85 c0                	test   %eax,%eax
  802301:	78 25                	js     802328 <nsipc_accept+0x49>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  802303:	be 10 60 80 00       	mov    $0x806010,%esi
  802308:	8b 06                	mov    (%esi),%eax
  80230a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80230e:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  802315:	00 
  802316:	8b 45 0c             	mov    0xc(%ebp),%eax
  802319:	89 04 24             	mov    %eax,(%esp)
  80231c:	e8 54 e9 ff ff       	call   800c75 <memmove>
		*addrlen = ret->ret_addrlen;
  802321:	8b 16                	mov    (%esi),%edx
  802323:	8b 45 10             	mov    0x10(%ebp),%eax
  802326:	89 10                	mov    %edx,(%eax)
	}
	return r;
}
  802328:	89 d8                	mov    %ebx,%eax
  80232a:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80232d:	8b 75 fc             	mov    -0x4(%ebp),%esi
  802330:	89 ec                	mov    %ebp,%esp
  802332:	5d                   	pop    %ebp
  802333:	c3                   	ret    

00802334 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  802334:	55                   	push   %ebp
  802335:	89 e5                	mov    %esp,%ebp
  802337:	56                   	push   %esi
  802338:	53                   	push   %ebx
  802339:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  80233c:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80233f:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  802345:	e8 5d f1 ff ff       	call   8014a7 <sys_getenvid>
  80234a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80234d:	89 54 24 10          	mov    %edx,0x10(%esp)
  802351:	8b 55 08             	mov    0x8(%ebp),%edx
  802354:	89 54 24 0c          	mov    %edx,0xc(%esp)
  802358:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80235c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802360:	c7 04 24 44 2c 80 00 	movl   $0x802c44,(%esp)
  802367:	e8 ed dd ff ff       	call   800159 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80236c:	89 74 24 04          	mov    %esi,0x4(%esp)
  802370:	8b 45 10             	mov    0x10(%ebp),%eax
  802373:	89 04 24             	mov    %eax,(%esp)
  802376:	e8 7d dd ff ff       	call   8000f8 <vcprintf>
	cprintf("\n");
  80237b:	c7 04 24 96 27 80 00 	movl   $0x802796,(%esp)
  802382:	e8 d2 dd ff ff       	call   800159 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  802387:	cc                   	int3   
  802388:	eb fd                	jmp    802387 <_panic+0x53>
  80238a:	00 00                	add    %al,(%eax)
  80238c:	00 00                	add    %al,(%eax)
	...

00802390 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802390:	55                   	push   %ebp
  802391:	89 e5                	mov    %esp,%ebp
  802393:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  802396:	8b 15 50 00 c0 ee    	mov    0xeec00050,%edx
  80239c:	b8 01 00 00 00       	mov    $0x1,%eax
  8023a1:	39 ca                	cmp    %ecx,%edx
  8023a3:	75 04                	jne    8023a9 <ipc_find_env+0x19>
  8023a5:	b0 00                	mov    $0x0,%al
  8023a7:	eb 12                	jmp    8023bb <ipc_find_env+0x2b>
  8023a9:	89 c2                	mov    %eax,%edx
  8023ab:	c1 e2 07             	shl    $0x7,%edx
  8023ae:	8d 94 82 50 00 c0 ee 	lea    -0x113fffb0(%edx,%eax,4),%edx
  8023b5:	8b 12                	mov    (%edx),%edx
  8023b7:	39 ca                	cmp    %ecx,%edx
  8023b9:	75 10                	jne    8023cb <ipc_find_env+0x3b>
			return envs[i].env_id;
  8023bb:	89 c2                	mov    %eax,%edx
  8023bd:	c1 e2 07             	shl    $0x7,%edx
  8023c0:	8d 84 82 48 00 c0 ee 	lea    -0x113fffb8(%edx,%eax,4),%eax
  8023c7:	8b 00                	mov    (%eax),%eax
  8023c9:	eb 0e                	jmp    8023d9 <ipc_find_env+0x49>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8023cb:	83 c0 01             	add    $0x1,%eax
  8023ce:	3d 00 04 00 00       	cmp    $0x400,%eax
  8023d3:	75 d4                	jne    8023a9 <ipc_find_env+0x19>
  8023d5:	66 b8 00 00          	mov    $0x0,%ax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  8023d9:	5d                   	pop    %ebp
  8023da:	c3                   	ret    

008023db <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8023db:	55                   	push   %ebp
  8023dc:	89 e5                	mov    %esp,%ebp
  8023de:	57                   	push   %edi
  8023df:	56                   	push   %esi
  8023e0:	53                   	push   %ebx
  8023e1:	83 ec 1c             	sub    $0x1c,%esp
  8023e4:	8b 75 08             	mov    0x8(%ebp),%esi
  8023e7:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8023ea:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        int ret;
        while(1){
           if(pg)
  8023ed:	85 db                	test   %ebx,%ebx
  8023ef:	74 19                	je     80240a <ipc_send+0x2f>
              ret = sys_ipc_try_send(to_env,val,pg,perm);
  8023f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8023f4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8023f8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8023fc:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802400:	89 34 24             	mov    %esi,(%esp)
  802403:	e8 51 ed ff ff       	call   801159 <sys_ipc_try_send>
  802408:	eb 1b                	jmp    802425 <ipc_send+0x4a>
           else
              ret = sys_ipc_try_send(to_env,val,(void*)UTOP,perm);
  80240a:	8b 45 14             	mov    0x14(%ebp),%eax
  80240d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802411:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  802418:	ee 
  802419:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80241d:	89 34 24             	mov    %esi,(%esp)
  802420:	e8 34 ed ff ff       	call   801159 <sys_ipc_try_send>
           if(ret == 0)
  802425:	85 c0                	test   %eax,%eax
  802427:	74 28                	je     802451 <ipc_send+0x76>
              return;
           if(ret != -E_IPC_NOT_RECV)
  802429:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80242c:	74 1c                	je     80244a <ipc_send+0x6f>
              panic("ipc send error");
  80242e:	c7 44 24 08 68 2c 80 	movl   $0x802c68,0x8(%esp)
  802435:	00 
  802436:	c7 44 24 04 46 00 00 	movl   $0x46,0x4(%esp)
  80243d:	00 
  80243e:	c7 04 24 77 2c 80 00 	movl   $0x802c77,(%esp)
  802445:	e8 ea fe ff ff       	call   802334 <_panic>
           sys_yield();
  80244a:	e8 d6 ef ff ff       	call   801425 <sys_yield>
        }
  80244f:	eb 9c                	jmp    8023ed <ipc_send+0x12>
	//panic("ipc_send not implemented");
}
  802451:	83 c4 1c             	add    $0x1c,%esp
  802454:	5b                   	pop    %ebx
  802455:	5e                   	pop    %esi
  802456:	5f                   	pop    %edi
  802457:	5d                   	pop    %ebp
  802458:	c3                   	ret    

00802459 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802459:	55                   	push   %ebp
  80245a:	89 e5                	mov    %esp,%ebp
  80245c:	56                   	push   %esi
  80245d:	53                   	push   %ebx
  80245e:	83 ec 10             	sub    $0x10,%esp
  802461:	8b 75 08             	mov    0x8(%ebp),%esi
  802464:	8b 45 0c             	mov    0xc(%ebp),%eax
  802467:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        int ret;
        if(!pg)
  80246a:	85 c0                	test   %eax,%eax
  80246c:	75 0e                	jne    80247c <ipc_recv+0x23>
           ret = sys_ipc_recv((void*)UTOP);
  80246e:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  802475:	e8 74 ec ff ff       	call   8010ee <sys_ipc_recv>
  80247a:	eb 08                	jmp    802484 <ipc_recv+0x2b>
        else
           ret = sys_ipc_recv(pg);
  80247c:	89 04 24             	mov    %eax,(%esp)
  80247f:	e8 6a ec ff ff       	call   8010ee <sys_ipc_recv>
        if(ret == 0){
  802484:	85 c0                	test   %eax,%eax
  802486:	75 26                	jne    8024ae <ipc_recv+0x55>
           if(from_env_store)
  802488:	85 f6                	test   %esi,%esi
  80248a:	74 0a                	je     802496 <ipc_recv+0x3d>
              *from_env_store = thisenv->env_ipc_from;
  80248c:	a1 08 40 80 00       	mov    0x804008,%eax
  802491:	8b 40 78             	mov    0x78(%eax),%eax
  802494:	89 06                	mov    %eax,(%esi)
           if(perm_store)
  802496:	85 db                	test   %ebx,%ebx
  802498:	74 0a                	je     8024a4 <ipc_recv+0x4b>
              *perm_store = thisenv->env_ipc_perm;
  80249a:	a1 08 40 80 00       	mov    0x804008,%eax
  80249f:	8b 40 7c             	mov    0x7c(%eax),%eax
  8024a2:	89 03                	mov    %eax,(%ebx)
           return thisenv->env_ipc_value;
  8024a4:	a1 08 40 80 00       	mov    0x804008,%eax
  8024a9:	8b 40 74             	mov    0x74(%eax),%eax
  8024ac:	eb 14                	jmp    8024c2 <ipc_recv+0x69>
        }
        else{
           if(from_env_store)
  8024ae:	85 f6                	test   %esi,%esi
  8024b0:	74 06                	je     8024b8 <ipc_recv+0x5f>
              *from_env_store = 0;
  8024b2:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
           if(perm_store)
  8024b8:	85 db                	test   %ebx,%ebx
  8024ba:	74 06                	je     8024c2 <ipc_recv+0x69>
              *perm_store = 0;
  8024bc:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
           return ret;
        }
	//panic("ipc_recv not implemented");
	return 0;
}
  8024c2:	83 c4 10             	add    $0x10,%esp
  8024c5:	5b                   	pop    %ebx
  8024c6:	5e                   	pop    %esi
  8024c7:	5d                   	pop    %ebp
  8024c8:	c3                   	ret    
  8024c9:	00 00                	add    %al,(%eax)
	...

008024cc <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8024cc:	55                   	push   %ebp
  8024cd:	89 e5                	mov    %esp,%ebp
	pte_t pte;

	if (!(vpd[PDX(v)] & PTE_P))
  8024cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8024d2:	89 c2                	mov    %eax,%edx
  8024d4:	c1 ea 16             	shr    $0x16,%edx
  8024d7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8024de:	f6 c2 01             	test   $0x1,%dl
  8024e1:	74 20                	je     802503 <pageref+0x37>
		return 0;
	pte = vpt[PGNUM(v)];
  8024e3:	c1 e8 0c             	shr    $0xc,%eax
  8024e6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8024ed:	a8 01                	test   $0x1,%al
  8024ef:	74 12                	je     802503 <pageref+0x37>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8024f1:	c1 e8 0c             	shr    $0xc,%eax
  8024f4:	ba 00 00 00 ef       	mov    $0xef000000,%edx
  8024f9:	0f b7 44 c2 04       	movzwl 0x4(%edx,%eax,8),%eax
  8024fe:	0f b7 c0             	movzwl %ax,%eax
  802501:	eb 05                	jmp    802508 <pageref+0x3c>
  802503:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802508:	5d                   	pop    %ebp
  802509:	c3                   	ret    
  80250a:	00 00                	add    %al,(%eax)
  80250c:	00 00                	add    %al,(%eax)
	...

00802510 <__udivdi3>:
  802510:	55                   	push   %ebp
  802511:	89 e5                	mov    %esp,%ebp
  802513:	57                   	push   %edi
  802514:	56                   	push   %esi
  802515:	83 ec 10             	sub    $0x10,%esp
  802518:	8b 45 14             	mov    0x14(%ebp),%eax
  80251b:	8b 55 08             	mov    0x8(%ebp),%edx
  80251e:	8b 75 10             	mov    0x10(%ebp),%esi
  802521:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802524:	85 c0                	test   %eax,%eax
  802526:	89 55 f0             	mov    %edx,-0x10(%ebp)
  802529:	75 35                	jne    802560 <__udivdi3+0x50>
  80252b:	39 fe                	cmp    %edi,%esi
  80252d:	77 61                	ja     802590 <__udivdi3+0x80>
  80252f:	85 f6                	test   %esi,%esi
  802531:	75 0b                	jne    80253e <__udivdi3+0x2e>
  802533:	b8 01 00 00 00       	mov    $0x1,%eax
  802538:	31 d2                	xor    %edx,%edx
  80253a:	f7 f6                	div    %esi
  80253c:	89 c6                	mov    %eax,%esi
  80253e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  802541:	31 d2                	xor    %edx,%edx
  802543:	89 f8                	mov    %edi,%eax
  802545:	f7 f6                	div    %esi
  802547:	89 c7                	mov    %eax,%edi
  802549:	89 c8                	mov    %ecx,%eax
  80254b:	f7 f6                	div    %esi
  80254d:	89 c1                	mov    %eax,%ecx
  80254f:	89 fa                	mov    %edi,%edx
  802551:	89 c8                	mov    %ecx,%eax
  802553:	83 c4 10             	add    $0x10,%esp
  802556:	5e                   	pop    %esi
  802557:	5f                   	pop    %edi
  802558:	5d                   	pop    %ebp
  802559:	c3                   	ret    
  80255a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802560:	39 f8                	cmp    %edi,%eax
  802562:	77 1c                	ja     802580 <__udivdi3+0x70>
  802564:	0f bd d0             	bsr    %eax,%edx
  802567:	83 f2 1f             	xor    $0x1f,%edx
  80256a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80256d:	75 39                	jne    8025a8 <__udivdi3+0x98>
  80256f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  802572:	0f 86 a0 00 00 00    	jbe    802618 <__udivdi3+0x108>
  802578:	39 f8                	cmp    %edi,%eax
  80257a:	0f 82 98 00 00 00    	jb     802618 <__udivdi3+0x108>
  802580:	31 ff                	xor    %edi,%edi
  802582:	31 c9                	xor    %ecx,%ecx
  802584:	89 c8                	mov    %ecx,%eax
  802586:	89 fa                	mov    %edi,%edx
  802588:	83 c4 10             	add    $0x10,%esp
  80258b:	5e                   	pop    %esi
  80258c:	5f                   	pop    %edi
  80258d:	5d                   	pop    %ebp
  80258e:	c3                   	ret    
  80258f:	90                   	nop
  802590:	89 d1                	mov    %edx,%ecx
  802592:	89 fa                	mov    %edi,%edx
  802594:	89 c8                	mov    %ecx,%eax
  802596:	31 ff                	xor    %edi,%edi
  802598:	f7 f6                	div    %esi
  80259a:	89 c1                	mov    %eax,%ecx
  80259c:	89 fa                	mov    %edi,%edx
  80259e:	89 c8                	mov    %ecx,%eax
  8025a0:	83 c4 10             	add    $0x10,%esp
  8025a3:	5e                   	pop    %esi
  8025a4:	5f                   	pop    %edi
  8025a5:	5d                   	pop    %ebp
  8025a6:	c3                   	ret    
  8025a7:	90                   	nop
  8025a8:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8025ac:	89 f2                	mov    %esi,%edx
  8025ae:	d3 e0                	shl    %cl,%eax
  8025b0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8025b3:	b8 20 00 00 00       	mov    $0x20,%eax
  8025b8:	2b 45 f4             	sub    -0xc(%ebp),%eax
  8025bb:	89 c1                	mov    %eax,%ecx
  8025bd:	d3 ea                	shr    %cl,%edx
  8025bf:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8025c3:	0b 55 ec             	or     -0x14(%ebp),%edx
  8025c6:	d3 e6                	shl    %cl,%esi
  8025c8:	89 c1                	mov    %eax,%ecx
  8025ca:	89 75 e8             	mov    %esi,-0x18(%ebp)
  8025cd:	89 fe                	mov    %edi,%esi
  8025cf:	d3 ee                	shr    %cl,%esi
  8025d1:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8025d5:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8025d8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8025db:	d3 e7                	shl    %cl,%edi
  8025dd:	89 c1                	mov    %eax,%ecx
  8025df:	d3 ea                	shr    %cl,%edx
  8025e1:	09 d7                	or     %edx,%edi
  8025e3:	89 f2                	mov    %esi,%edx
  8025e5:	89 f8                	mov    %edi,%eax
  8025e7:	f7 75 ec             	divl   -0x14(%ebp)
  8025ea:	89 d6                	mov    %edx,%esi
  8025ec:	89 c7                	mov    %eax,%edi
  8025ee:	f7 65 e8             	mull   -0x18(%ebp)
  8025f1:	39 d6                	cmp    %edx,%esi
  8025f3:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8025f6:	72 30                	jb     802628 <__udivdi3+0x118>
  8025f8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8025fb:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8025ff:	d3 e2                	shl    %cl,%edx
  802601:	39 c2                	cmp    %eax,%edx
  802603:	73 05                	jae    80260a <__udivdi3+0xfa>
  802605:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  802608:	74 1e                	je     802628 <__udivdi3+0x118>
  80260a:	89 f9                	mov    %edi,%ecx
  80260c:	31 ff                	xor    %edi,%edi
  80260e:	e9 71 ff ff ff       	jmp    802584 <__udivdi3+0x74>
  802613:	90                   	nop
  802614:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802618:	31 ff                	xor    %edi,%edi
  80261a:	b9 01 00 00 00       	mov    $0x1,%ecx
  80261f:	e9 60 ff ff ff       	jmp    802584 <__udivdi3+0x74>
  802624:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802628:	8d 4f ff             	lea    -0x1(%edi),%ecx
  80262b:	31 ff                	xor    %edi,%edi
  80262d:	89 c8                	mov    %ecx,%eax
  80262f:	89 fa                	mov    %edi,%edx
  802631:	83 c4 10             	add    $0x10,%esp
  802634:	5e                   	pop    %esi
  802635:	5f                   	pop    %edi
  802636:	5d                   	pop    %ebp
  802637:	c3                   	ret    
	...

00802640 <__umoddi3>:
  802640:	55                   	push   %ebp
  802641:	89 e5                	mov    %esp,%ebp
  802643:	57                   	push   %edi
  802644:	56                   	push   %esi
  802645:	83 ec 20             	sub    $0x20,%esp
  802648:	8b 55 14             	mov    0x14(%ebp),%edx
  80264b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80264e:	8b 7d 10             	mov    0x10(%ebp),%edi
  802651:	8b 75 0c             	mov    0xc(%ebp),%esi
  802654:	85 d2                	test   %edx,%edx
  802656:	89 c8                	mov    %ecx,%eax
  802658:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80265b:	75 13                	jne    802670 <__umoddi3+0x30>
  80265d:	39 f7                	cmp    %esi,%edi
  80265f:	76 3f                	jbe    8026a0 <__umoddi3+0x60>
  802661:	89 f2                	mov    %esi,%edx
  802663:	f7 f7                	div    %edi
  802665:	89 d0                	mov    %edx,%eax
  802667:	31 d2                	xor    %edx,%edx
  802669:	83 c4 20             	add    $0x20,%esp
  80266c:	5e                   	pop    %esi
  80266d:	5f                   	pop    %edi
  80266e:	5d                   	pop    %ebp
  80266f:	c3                   	ret    
  802670:	39 f2                	cmp    %esi,%edx
  802672:	77 4c                	ja     8026c0 <__umoddi3+0x80>
  802674:	0f bd ca             	bsr    %edx,%ecx
  802677:	83 f1 1f             	xor    $0x1f,%ecx
  80267a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80267d:	75 51                	jne    8026d0 <__umoddi3+0x90>
  80267f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  802682:	0f 87 e0 00 00 00    	ja     802768 <__umoddi3+0x128>
  802688:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80268b:	29 f8                	sub    %edi,%eax
  80268d:	19 d6                	sbb    %edx,%esi
  80268f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  802692:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802695:	89 f2                	mov    %esi,%edx
  802697:	83 c4 20             	add    $0x20,%esp
  80269a:	5e                   	pop    %esi
  80269b:	5f                   	pop    %edi
  80269c:	5d                   	pop    %ebp
  80269d:	c3                   	ret    
  80269e:	66 90                	xchg   %ax,%ax
  8026a0:	85 ff                	test   %edi,%edi
  8026a2:	75 0b                	jne    8026af <__umoddi3+0x6f>
  8026a4:	b8 01 00 00 00       	mov    $0x1,%eax
  8026a9:	31 d2                	xor    %edx,%edx
  8026ab:	f7 f7                	div    %edi
  8026ad:	89 c7                	mov    %eax,%edi
  8026af:	89 f0                	mov    %esi,%eax
  8026b1:	31 d2                	xor    %edx,%edx
  8026b3:	f7 f7                	div    %edi
  8026b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8026b8:	f7 f7                	div    %edi
  8026ba:	eb a9                	jmp    802665 <__umoddi3+0x25>
  8026bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8026c0:	89 c8                	mov    %ecx,%eax
  8026c2:	89 f2                	mov    %esi,%edx
  8026c4:	83 c4 20             	add    $0x20,%esp
  8026c7:	5e                   	pop    %esi
  8026c8:	5f                   	pop    %edi
  8026c9:	5d                   	pop    %ebp
  8026ca:	c3                   	ret    
  8026cb:	90                   	nop
  8026cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8026d0:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8026d4:	d3 e2                	shl    %cl,%edx
  8026d6:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8026d9:	ba 20 00 00 00       	mov    $0x20,%edx
  8026de:	2b 55 f0             	sub    -0x10(%ebp),%edx
  8026e1:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8026e4:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8026e8:	89 fa                	mov    %edi,%edx
  8026ea:	d3 ea                	shr    %cl,%edx
  8026ec:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8026f0:	0b 55 f4             	or     -0xc(%ebp),%edx
  8026f3:	d3 e7                	shl    %cl,%edi
  8026f5:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8026f9:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8026fc:	89 f2                	mov    %esi,%edx
  8026fe:	89 7d e8             	mov    %edi,-0x18(%ebp)
  802701:	89 c7                	mov    %eax,%edi
  802703:	d3 ea                	shr    %cl,%edx
  802705:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802709:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80270c:	89 c2                	mov    %eax,%edx
  80270e:	d3 e6                	shl    %cl,%esi
  802710:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802714:	d3 ea                	shr    %cl,%edx
  802716:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80271a:	09 d6                	or     %edx,%esi
  80271c:	89 f0                	mov    %esi,%eax
  80271e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  802721:	d3 e7                	shl    %cl,%edi
  802723:	89 f2                	mov    %esi,%edx
  802725:	f7 75 f4             	divl   -0xc(%ebp)
  802728:	89 d6                	mov    %edx,%esi
  80272a:	f7 65 e8             	mull   -0x18(%ebp)
  80272d:	39 d6                	cmp    %edx,%esi
  80272f:	72 2b                	jb     80275c <__umoddi3+0x11c>
  802731:	39 c7                	cmp    %eax,%edi
  802733:	72 23                	jb     802758 <__umoddi3+0x118>
  802735:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802739:	29 c7                	sub    %eax,%edi
  80273b:	19 d6                	sbb    %edx,%esi
  80273d:	89 f0                	mov    %esi,%eax
  80273f:	89 f2                	mov    %esi,%edx
  802741:	d3 ef                	shr    %cl,%edi
  802743:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802747:	d3 e0                	shl    %cl,%eax
  802749:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80274d:	09 f8                	or     %edi,%eax
  80274f:	d3 ea                	shr    %cl,%edx
  802751:	83 c4 20             	add    $0x20,%esp
  802754:	5e                   	pop    %esi
  802755:	5f                   	pop    %edi
  802756:	5d                   	pop    %ebp
  802757:	c3                   	ret    
  802758:	39 d6                	cmp    %edx,%esi
  80275a:	75 d9                	jne    802735 <__umoddi3+0xf5>
  80275c:	2b 45 e8             	sub    -0x18(%ebp),%eax
  80275f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  802762:	eb d1                	jmp    802735 <__umoddi3+0xf5>
  802764:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802768:	39 f2                	cmp    %esi,%edx
  80276a:	0f 82 18 ff ff ff    	jb     802688 <__umoddi3+0x48>
  802770:	e9 1d ff ff ff       	jmp    802692 <__umoddi3+0x52>
