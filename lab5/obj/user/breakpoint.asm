
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
  800049:	c7 04 24 20 21 80 00 	movl   $0x802120,(%esp)
  800050:	e8 04 01 00 00       	call   800159 <cprintf>
	cprintf("&a equals 0x%x\n",&a);
  800055:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800058:	89 44 24 04          	mov    %eax,0x4(%esp)
  80005c:	c7 04 24 38 21 80 00 	movl   $0x802138,(%esp)
  800063:	e8 f1 00 00 00       	call   800159 <cprintf>
	asm volatile("int $3");
  800068:	cc                   	int3   
	// Try single-step here
	a=20;
  800069:	c7 45 f4 14 00 00 00 	movl   $0x14,-0xc(%ebp)
	cprintf("Finally , a equals %d\n",a);
  800070:	c7 44 24 04 14 00 00 	movl   $0x14,0x4(%esp)
  800077:	00 
  800078:	c7 04 24 48 21 80 00 	movl   $0x802148,(%esp)
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
  80009a:	e8 03 13 00 00       	call   8013a2 <sys_getenvid>
  80009f:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000a4:	89 c2                	mov    %eax,%edx
  8000a6:	c1 e2 07             	shl    $0x7,%edx
  8000a9:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  8000b0:	a3 04 40 80 00       	mov    %eax,0x804004
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
  8000e2:	e8 44 18 00 00       	call   80192b <close_all>
	sys_env_destroy(0);
  8000e7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000ee:	e8 ef 12 00 00       	call   8013e2 <sys_env_destroy>
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
  80022f:	e8 7c 1c 00 00       	call   801eb0 <__udivdi3>
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
  800297:	e8 44 1d 00 00       	call   801fe0 <__umoddi3>
  80029c:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002a0:	0f be 80 69 21 80 00 	movsbl 0x802169(%eax),%eax
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
  80038a:	ff 24 95 40 23 80 00 	jmp    *0x802340(,%edx,4)
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
  800447:	8b 14 85 a0 24 80 00 	mov    0x8024a0(,%eax,4),%edx
  80044e:	85 d2                	test   %edx,%edx
  800450:	75 26                	jne    800478 <vprintfmt+0x16c>
				printfmt(putch, putdat, "error %d", err);
  800452:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800456:	c7 44 24 08 7a 21 80 	movl   $0x80217a,0x8(%esp)
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
  80047c:	c7 44 24 08 83 21 80 	movl   $0x802183,0x8(%esp)
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
  8004ba:	be 86 21 80 00       	mov    $0x802186,%esi
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
  800764:	e8 47 17 00 00       	call   801eb0 <__udivdi3>
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
  8007b0:	e8 2b 18 00 00       	call   801fe0 <__umoddi3>
  8007b5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007b9:	0f be 80 69 21 80 00 	movsbl 0x802169(%eax),%eax
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
  800865:	c7 44 24 0c a0 22 80 	movl   $0x8022a0,0xc(%esp)
  80086c:	00 
  80086d:	c7 44 24 08 83 21 80 	movl   $0x802183,0x8(%esp)
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
  80089b:	c7 44 24 0c d8 22 80 	movl   $0x8022d8,0xc(%esp)
  8008a2:	00 
  8008a3:	c7 44 24 08 83 21 80 	movl   $0x802183,0x8(%esp)
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
  80092f:	e8 ac 16 00 00       	call   801fe0 <__umoddi3>
  800934:	89 74 24 04          	mov    %esi,0x4(%esp)
  800938:	0f be 80 69 21 80 00 	movsbl 0x802169(%eax),%eax
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
  800971:	e8 6a 16 00 00       	call   801fe0 <__umoddi3>
  800976:	89 74 24 04          	mov    %esi,0x4(%esp)
  80097a:	0f be 80 69 21 80 00 	movsbl 0x802169(%eax),%eax
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

00800efb <sys_exec>:
sys_env_set_prior(envid_t envid, uint32_t prior){
         return syscall(SYS_env_set_prior,1,envid, prior, 0, 0, 0);
}

int 
sys_exec(void* vph, uint32_t phnum, uint32_t esp, uint32_t eip){
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
  800f08:	b8 10 00 00 00       	mov    $0x10,%eax
  800f0d:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f10:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f13:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f16:	8b 55 08             	mov    0x8(%ebp),%edx
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
sys_exec(void* vph, uint32_t phnum, uint32_t esp, uint32_t eip){
         return syscall(SYS_exec, 0, (uint32_t)vph, phnum, esp, eip, 0);
}
  800f31:	8b 1c 24             	mov    (%esp),%ebx
  800f34:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800f38:	89 ec                	mov    %ebp,%esp
  800f3a:	5d                   	pop    %ebp
  800f3b:	c3                   	ret    

00800f3c <sys_env_set_prior>:
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}

int 
sys_env_set_prior(envid_t envid, uint32_t prior){
  800f3c:	55                   	push   %ebp
  800f3d:	89 e5                	mov    %esp,%ebp
  800f3f:	83 ec 28             	sub    $0x28,%esp
  800f42:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800f45:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800f48:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f4d:	b8 0f 00 00 00       	mov    $0xf,%eax
  800f52:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f55:	8b 55 08             	mov    0x8(%ebp),%edx
  800f58:	89 df                	mov    %ebx,%edi
  800f5a:	51                   	push   %ecx
  800f5b:	52                   	push   %edx
  800f5c:	53                   	push   %ebx
  800f5d:	54                   	push   %esp
  800f5e:	55                   	push   %ebp
  800f5f:	56                   	push   %esi
  800f60:	57                   	push   %edi
  800f61:	54                   	push   %esp
  800f62:	5d                   	pop    %ebp
  800f63:	8d 35 6b 0f 80 00    	lea    0x800f6b,%esi
  800f69:	0f 34                	sysenter 
  800f6b:	5f                   	pop    %edi
  800f6c:	5e                   	pop    %esi
  800f6d:	5d                   	pop    %ebp
  800f6e:	5c                   	pop    %esp
  800f6f:	5b                   	pop    %ebx
  800f70:	5a                   	pop    %edx
  800f71:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  800f72:	85 c0                	test   %eax,%eax
  800f74:	7e 28                	jle    800f9e <sys_env_set_prior+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f76:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f7a:	c7 44 24 0c 0f 00 00 	movl   $0xf,0xc(%esp)
  800f81:	00 
  800f82:	c7 44 24 08 e0 24 80 	movl   $0x8024e0,0x8(%esp)
  800f89:	00 
  800f8a:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  800f91:	00 
  800f92:	c7 04 24 fd 24 80 00 	movl   $0x8024fd,(%esp)
  800f99:	e8 76 0d 00 00       	call   801d14 <_panic>
}

int 
sys_env_set_prior(envid_t envid, uint32_t prior){
         return syscall(SYS_env_set_prior,1,envid, prior, 0, 0, 0);
}
  800f9e:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800fa1:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800fa4:	89 ec                	mov    %ebp,%esp
  800fa6:	5d                   	pop    %ebp
  800fa7:	c3                   	ret    

00800fa8 <sys_sbrk>:
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}

int
sys_sbrk(uint32_t inc)
{
  800fa8:	55                   	push   %ebp
  800fa9:	89 e5                	mov    %esp,%ebp
  800fab:	83 ec 08             	sub    $0x8,%esp
  800fae:	89 1c 24             	mov    %ebx,(%esp)
  800fb1:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800fb5:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fba:	b8 11 00 00 00       	mov    $0x11,%eax
  800fbf:	8b 55 08             	mov    0x8(%ebp),%edx
  800fc2:	89 cb                	mov    %ecx,%ebx
  800fc4:	89 cf                	mov    %ecx,%edi
  800fc6:	51                   	push   %ecx
  800fc7:	52                   	push   %edx
  800fc8:	53                   	push   %ebx
  800fc9:	54                   	push   %esp
  800fca:	55                   	push   %ebp
  800fcb:	56                   	push   %esi
  800fcc:	57                   	push   %edi
  800fcd:	54                   	push   %esp
  800fce:	5d                   	pop    %ebp
  800fcf:	8d 35 d7 0f 80 00    	lea    0x800fd7,%esi
  800fd5:	0f 34                	sysenter 
  800fd7:	5f                   	pop    %edi
  800fd8:	5e                   	pop    %esi
  800fd9:	5d                   	pop    %ebp
  800fda:	5c                   	pop    %esp
  800fdb:	5b                   	pop    %ebx
  800fdc:	5a                   	pop    %edx
  800fdd:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  800fde:	8b 1c 24             	mov    (%esp),%ebx
  800fe1:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800fe5:	89 ec                	mov    %ebp,%esp
  800fe7:	5d                   	pop    %ebp
  800fe8:	c3                   	ret    

00800fe9 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800fe9:	55                   	push   %ebp
  800fea:	89 e5                	mov    %esp,%ebp
  800fec:	83 ec 28             	sub    $0x28,%esp
  800fef:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800ff2:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800ff5:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ffa:	b8 0e 00 00 00       	mov    $0xe,%eax
  800fff:	8b 55 08             	mov    0x8(%ebp),%edx
  801002:	89 cb                	mov    %ecx,%ebx
  801004:	89 cf                	mov    %ecx,%edi
  801006:	51                   	push   %ecx
  801007:	52                   	push   %edx
  801008:	53                   	push   %ebx
  801009:	54                   	push   %esp
  80100a:	55                   	push   %ebp
  80100b:	56                   	push   %esi
  80100c:	57                   	push   %edi
  80100d:	54                   	push   %esp
  80100e:	5d                   	pop    %ebp
  80100f:	8d 35 17 10 80 00    	lea    0x801017,%esi
  801015:	0f 34                	sysenter 
  801017:	5f                   	pop    %edi
  801018:	5e                   	pop    %esi
  801019:	5d                   	pop    %ebp
  80101a:	5c                   	pop    %esp
  80101b:	5b                   	pop    %ebx
  80101c:	5a                   	pop    %edx
  80101d:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80101e:	85 c0                	test   %eax,%eax
  801020:	7e 28                	jle    80104a <sys_ipc_recv+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  801022:	89 44 24 10          	mov    %eax,0x10(%esp)
  801026:	c7 44 24 0c 0e 00 00 	movl   $0xe,0xc(%esp)
  80102d:	00 
  80102e:	c7 44 24 08 e0 24 80 	movl   $0x8024e0,0x8(%esp)
  801035:	00 
  801036:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80103d:	00 
  80103e:	c7 04 24 fd 24 80 00 	movl   $0x8024fd,(%esp)
  801045:	e8 ca 0c 00 00       	call   801d14 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80104a:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80104d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801050:	89 ec                	mov    %ebp,%esp
  801052:	5d                   	pop    %ebp
  801053:	c3                   	ret    

00801054 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801054:	55                   	push   %ebp
  801055:	89 e5                	mov    %esp,%ebp
  801057:	83 ec 08             	sub    $0x8,%esp
  80105a:	89 1c 24             	mov    %ebx,(%esp)
  80105d:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801061:	b8 0d 00 00 00       	mov    $0xd,%eax
  801066:	8b 7d 14             	mov    0x14(%ebp),%edi
  801069:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80106c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80106f:	8b 55 08             	mov    0x8(%ebp),%edx
  801072:	51                   	push   %ecx
  801073:	52                   	push   %edx
  801074:	53                   	push   %ebx
  801075:	54                   	push   %esp
  801076:	55                   	push   %ebp
  801077:	56                   	push   %esi
  801078:	57                   	push   %edi
  801079:	54                   	push   %esp
  80107a:	5d                   	pop    %ebp
  80107b:	8d 35 83 10 80 00    	lea    0x801083,%esi
  801081:	0f 34                	sysenter 
  801083:	5f                   	pop    %edi
  801084:	5e                   	pop    %esi
  801085:	5d                   	pop    %ebp
  801086:	5c                   	pop    %esp
  801087:	5b                   	pop    %ebx
  801088:	5a                   	pop    %edx
  801089:	59                   	pop    %ecx

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80108a:	8b 1c 24             	mov    (%esp),%ebx
  80108d:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801091:	89 ec                	mov    %ebp,%esp
  801093:	5d                   	pop    %ebp
  801094:	c3                   	ret    

00801095 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801095:	55                   	push   %ebp
  801096:	89 e5                	mov    %esp,%ebp
  801098:	83 ec 28             	sub    $0x28,%esp
  80109b:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80109e:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8010a1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010a6:	b8 0b 00 00 00       	mov    $0xb,%eax
  8010ab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010ae:	8b 55 08             	mov    0x8(%ebp),%edx
  8010b1:	89 df                	mov    %ebx,%edi
  8010b3:	51                   	push   %ecx
  8010b4:	52                   	push   %edx
  8010b5:	53                   	push   %ebx
  8010b6:	54                   	push   %esp
  8010b7:	55                   	push   %ebp
  8010b8:	56                   	push   %esi
  8010b9:	57                   	push   %edi
  8010ba:	54                   	push   %esp
  8010bb:	5d                   	pop    %ebp
  8010bc:	8d 35 c4 10 80 00    	lea    0x8010c4,%esi
  8010c2:	0f 34                	sysenter 
  8010c4:	5f                   	pop    %edi
  8010c5:	5e                   	pop    %esi
  8010c6:	5d                   	pop    %ebp
  8010c7:	5c                   	pop    %esp
  8010c8:	5b                   	pop    %ebx
  8010c9:	5a                   	pop    %edx
  8010ca:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8010cb:	85 c0                	test   %eax,%eax
  8010cd:	7e 28                	jle    8010f7 <sys_env_set_pgfault_upcall+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010cf:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010d3:	c7 44 24 0c 0b 00 00 	movl   $0xb,0xc(%esp)
  8010da:	00 
  8010db:	c7 44 24 08 e0 24 80 	movl   $0x8024e0,0x8(%esp)
  8010e2:	00 
  8010e3:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8010ea:	00 
  8010eb:	c7 04 24 fd 24 80 00 	movl   $0x8024fd,(%esp)
  8010f2:	e8 1d 0c 00 00       	call   801d14 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8010f7:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8010fa:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8010fd:	89 ec                	mov    %ebp,%esp
  8010ff:	5d                   	pop    %ebp
  801100:	c3                   	ret    

00801101 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801101:	55                   	push   %ebp
  801102:	89 e5                	mov    %esp,%ebp
  801104:	83 ec 28             	sub    $0x28,%esp
  801107:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80110a:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80110d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801112:	b8 0a 00 00 00       	mov    $0xa,%eax
  801117:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80111a:	8b 55 08             	mov    0x8(%ebp),%edx
  80111d:	89 df                	mov    %ebx,%edi
  80111f:	51                   	push   %ecx
  801120:	52                   	push   %edx
  801121:	53                   	push   %ebx
  801122:	54                   	push   %esp
  801123:	55                   	push   %ebp
  801124:	56                   	push   %esi
  801125:	57                   	push   %edi
  801126:	54                   	push   %esp
  801127:	5d                   	pop    %ebp
  801128:	8d 35 30 11 80 00    	lea    0x801130,%esi
  80112e:	0f 34                	sysenter 
  801130:	5f                   	pop    %edi
  801131:	5e                   	pop    %esi
  801132:	5d                   	pop    %ebp
  801133:	5c                   	pop    %esp
  801134:	5b                   	pop    %ebx
  801135:	5a                   	pop    %edx
  801136:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801137:	85 c0                	test   %eax,%eax
  801139:	7e 28                	jle    801163 <sys_env_set_trapframe+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  80113b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80113f:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  801146:	00 
  801147:	c7 44 24 08 e0 24 80 	movl   $0x8024e0,0x8(%esp)
  80114e:	00 
  80114f:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801156:	00 
  801157:	c7 04 24 fd 24 80 00 	movl   $0x8024fd,(%esp)
  80115e:	e8 b1 0b 00 00       	call   801d14 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801163:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801166:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801169:	89 ec                	mov    %ebp,%esp
  80116b:	5d                   	pop    %ebp
  80116c:	c3                   	ret    

0080116d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80116d:	55                   	push   %ebp
  80116e:	89 e5                	mov    %esp,%ebp
  801170:	83 ec 28             	sub    $0x28,%esp
  801173:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801176:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801179:	bb 00 00 00 00       	mov    $0x0,%ebx
  80117e:	b8 09 00 00 00       	mov    $0x9,%eax
  801183:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801186:	8b 55 08             	mov    0x8(%ebp),%edx
  801189:	89 df                	mov    %ebx,%edi
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
  8011a5:	7e 28                	jle    8011cf <sys_env_set_status+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011a7:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011ab:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8011b2:	00 
  8011b3:	c7 44 24 08 e0 24 80 	movl   $0x8024e0,0x8(%esp)
  8011ba:	00 
  8011bb:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8011c2:	00 
  8011c3:	c7 04 24 fd 24 80 00 	movl   $0x8024fd,(%esp)
  8011ca:	e8 45 0b 00 00       	call   801d14 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8011cf:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8011d2:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8011d5:	89 ec                	mov    %ebp,%esp
  8011d7:	5d                   	pop    %ebp
  8011d8:	c3                   	ret    

008011d9 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  8011d9:	55                   	push   %ebp
  8011da:	89 e5                	mov    %esp,%ebp
  8011dc:	83 ec 28             	sub    $0x28,%esp
  8011df:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8011e2:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8011e5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011ea:	b8 07 00 00 00       	mov    $0x7,%eax
  8011ef:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011f2:	8b 55 08             	mov    0x8(%ebp),%edx
  8011f5:	89 df                	mov    %ebx,%edi
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
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80120f:	85 c0                	test   %eax,%eax
  801211:	7e 28                	jle    80123b <sys_page_unmap+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  801213:	89 44 24 10          	mov    %eax,0x10(%esp)
  801217:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80121e:	00 
  80121f:	c7 44 24 08 e0 24 80 	movl   $0x8024e0,0x8(%esp)
  801226:	00 
  801227:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80122e:	00 
  80122f:	c7 04 24 fd 24 80 00 	movl   $0x8024fd,(%esp)
  801236:	e8 d9 0a 00 00       	call   801d14 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80123b:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80123e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801241:	89 ec                	mov    %ebp,%esp
  801243:	5d                   	pop    %ebp
  801244:	c3                   	ret    

00801245 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  801245:	55                   	push   %ebp
  801246:	89 e5                	mov    %esp,%ebp
  801248:	83 ec 28             	sub    $0x28,%esp
  80124b:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80124e:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801251:	8b 7d 18             	mov    0x18(%ebp),%edi
  801254:	0b 7d 14             	or     0x14(%ebp),%edi
  801257:	b8 06 00 00 00       	mov    $0x6,%eax
  80125c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80125f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801262:	8b 55 08             	mov    0x8(%ebp),%edx
  801265:	51                   	push   %ecx
  801266:	52                   	push   %edx
  801267:	53                   	push   %ebx
  801268:	54                   	push   %esp
  801269:	55                   	push   %ebp
  80126a:	56                   	push   %esi
  80126b:	57                   	push   %edi
  80126c:	54                   	push   %esp
  80126d:	5d                   	pop    %ebp
  80126e:	8d 35 76 12 80 00    	lea    0x801276,%esi
  801274:	0f 34                	sysenter 
  801276:	5f                   	pop    %edi
  801277:	5e                   	pop    %esi
  801278:	5d                   	pop    %ebp
  801279:	5c                   	pop    %esp
  80127a:	5b                   	pop    %ebx
  80127b:	5a                   	pop    %edx
  80127c:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80127d:	85 c0                	test   %eax,%eax
  80127f:	7e 28                	jle    8012a9 <sys_page_map+0x64>
		panic("syscall %d returned %d (> 0)", num, ret);
  801281:	89 44 24 10          	mov    %eax,0x10(%esp)
  801285:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  80128c:	00 
  80128d:	c7 44 24 08 e0 24 80 	movl   $0x8024e0,0x8(%esp)
  801294:	00 
  801295:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80129c:	00 
  80129d:	c7 04 24 fd 24 80 00 	movl   $0x8024fd,(%esp)
  8012a4:	e8 6b 0a 00 00       	call   801d14 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}
  8012a9:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8012ac:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8012af:	89 ec                	mov    %ebp,%esp
  8012b1:	5d                   	pop    %ebp
  8012b2:	c3                   	ret    

008012b3 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8012b3:	55                   	push   %ebp
  8012b4:	89 e5                	mov    %esp,%ebp
  8012b6:	83 ec 28             	sub    $0x28,%esp
  8012b9:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8012bc:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8012bf:	bf 00 00 00 00       	mov    $0x0,%edi
  8012c4:	b8 05 00 00 00       	mov    $0x5,%eax
  8012c9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8012cc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012cf:	8b 55 08             	mov    0x8(%ebp),%edx
  8012d2:	51                   	push   %ecx
  8012d3:	52                   	push   %edx
  8012d4:	53                   	push   %ebx
  8012d5:	54                   	push   %esp
  8012d6:	55                   	push   %ebp
  8012d7:	56                   	push   %esi
  8012d8:	57                   	push   %edi
  8012d9:	54                   	push   %esp
  8012da:	5d                   	pop    %ebp
  8012db:	8d 35 e3 12 80 00    	lea    0x8012e3,%esi
  8012e1:	0f 34                	sysenter 
  8012e3:	5f                   	pop    %edi
  8012e4:	5e                   	pop    %esi
  8012e5:	5d                   	pop    %ebp
  8012e6:	5c                   	pop    %esp
  8012e7:	5b                   	pop    %ebx
  8012e8:	5a                   	pop    %edx
  8012e9:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8012ea:	85 c0                	test   %eax,%eax
  8012ec:	7e 28                	jle    801316 <sys_page_alloc+0x63>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012ee:	89 44 24 10          	mov    %eax,0x10(%esp)
  8012f2:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  8012f9:	00 
  8012fa:	c7 44 24 08 e0 24 80 	movl   $0x8024e0,0x8(%esp)
  801301:	00 
  801302:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801309:	00 
  80130a:	c7 04 24 fd 24 80 00 	movl   $0x8024fd,(%esp)
  801311:	e8 fe 09 00 00       	call   801d14 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  801316:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801319:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80131c:	89 ec                	mov    %ebp,%esp
  80131e:	5d                   	pop    %ebp
  80131f:	c3                   	ret    

00801320 <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
{
  801320:	55                   	push   %ebp
  801321:	89 e5                	mov    %esp,%ebp
  801323:	83 ec 08             	sub    $0x8,%esp
  801326:	89 1c 24             	mov    %ebx,(%esp)
  801329:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80132d:	ba 00 00 00 00       	mov    $0x0,%edx
  801332:	b8 0c 00 00 00       	mov    $0xc,%eax
  801337:	89 d1                	mov    %edx,%ecx
  801339:	89 d3                	mov    %edx,%ebx
  80133b:	89 d7                	mov    %edx,%edi
  80133d:	51                   	push   %ecx
  80133e:	52                   	push   %edx
  80133f:	53                   	push   %ebx
  801340:	54                   	push   %esp
  801341:	55                   	push   %ebp
  801342:	56                   	push   %esi
  801343:	57                   	push   %edi
  801344:	54                   	push   %esp
  801345:	5d                   	pop    %ebp
  801346:	8d 35 4e 13 80 00    	lea    0x80134e,%esi
  80134c:	0f 34                	sysenter 
  80134e:	5f                   	pop    %edi
  80134f:	5e                   	pop    %esi
  801350:	5d                   	pop    %ebp
  801351:	5c                   	pop    %esp
  801352:	5b                   	pop    %ebx
  801353:	5a                   	pop    %edx
  801354:	59                   	pop    %ecx

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  801355:	8b 1c 24             	mov    (%esp),%ebx
  801358:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80135c:	89 ec                	mov    %ebp,%esp
  80135e:	5d                   	pop    %ebp
  80135f:	c3                   	ret    

00801360 <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
{
  801360:	55                   	push   %ebp
  801361:	89 e5                	mov    %esp,%ebp
  801363:	83 ec 08             	sub    $0x8,%esp
  801366:	89 1c 24             	mov    %ebx,(%esp)
  801369:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80136d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801372:	b8 04 00 00 00       	mov    $0x4,%eax
  801377:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80137a:	8b 55 08             	mov    0x8(%ebp),%edx
  80137d:	89 df                	mov    %ebx,%edi
  80137f:	51                   	push   %ecx
  801380:	52                   	push   %edx
  801381:	53                   	push   %ebx
  801382:	54                   	push   %esp
  801383:	55                   	push   %ebp
  801384:	56                   	push   %esi
  801385:	57                   	push   %edi
  801386:	54                   	push   %esp
  801387:	5d                   	pop    %ebp
  801388:	8d 35 90 13 80 00    	lea    0x801390,%esi
  80138e:	0f 34                	sysenter 
  801390:	5f                   	pop    %edi
  801391:	5e                   	pop    %esi
  801392:	5d                   	pop    %ebp
  801393:	5c                   	pop    %esp
  801394:	5b                   	pop    %ebx
  801395:	5a                   	pop    %edx
  801396:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  801397:	8b 1c 24             	mov    (%esp),%ebx
  80139a:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80139e:	89 ec                	mov    %ebp,%esp
  8013a0:	5d                   	pop    %ebp
  8013a1:	c3                   	ret    

008013a2 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  8013a2:	55                   	push   %ebp
  8013a3:	89 e5                	mov    %esp,%ebp
  8013a5:	83 ec 08             	sub    $0x8,%esp
  8013a8:	89 1c 24             	mov    %ebx,(%esp)
  8013ab:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8013af:	ba 00 00 00 00       	mov    $0x0,%edx
  8013b4:	b8 02 00 00 00       	mov    $0x2,%eax
  8013b9:	89 d1                	mov    %edx,%ecx
  8013bb:	89 d3                	mov    %edx,%ebx
  8013bd:	89 d7                	mov    %edx,%edi
  8013bf:	51                   	push   %ecx
  8013c0:	52                   	push   %edx
  8013c1:	53                   	push   %ebx
  8013c2:	54                   	push   %esp
  8013c3:	55                   	push   %ebp
  8013c4:	56                   	push   %esi
  8013c5:	57                   	push   %edi
  8013c6:	54                   	push   %esp
  8013c7:	5d                   	pop    %ebp
  8013c8:	8d 35 d0 13 80 00    	lea    0x8013d0,%esi
  8013ce:	0f 34                	sysenter 
  8013d0:	5f                   	pop    %edi
  8013d1:	5e                   	pop    %esi
  8013d2:	5d                   	pop    %ebp
  8013d3:	5c                   	pop    %esp
  8013d4:	5b                   	pop    %ebx
  8013d5:	5a                   	pop    %edx
  8013d6:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8013d7:	8b 1c 24             	mov    (%esp),%ebx
  8013da:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8013de:	89 ec                	mov    %ebp,%esp
  8013e0:	5d                   	pop    %ebp
  8013e1:	c3                   	ret    

008013e2 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  8013e2:	55                   	push   %ebp
  8013e3:	89 e5                	mov    %esp,%ebp
  8013e5:	83 ec 28             	sub    $0x28,%esp
  8013e8:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8013eb:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8013ee:	b9 00 00 00 00       	mov    $0x0,%ecx
  8013f3:	b8 03 00 00 00       	mov    $0x3,%eax
  8013f8:	8b 55 08             	mov    0x8(%ebp),%edx
  8013fb:	89 cb                	mov    %ecx,%ebx
  8013fd:	89 cf                	mov    %ecx,%edi
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
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801417:	85 c0                	test   %eax,%eax
  801419:	7e 28                	jle    801443 <sys_env_destroy+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  80141b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80141f:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  801426:	00 
  801427:	c7 44 24 08 e0 24 80 	movl   $0x8024e0,0x8(%esp)
  80142e:	00 
  80142f:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801436:	00 
  801437:	c7 04 24 fd 24 80 00 	movl   $0x8024fd,(%esp)
  80143e:	e8 d1 08 00 00       	call   801d14 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801443:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801446:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801449:	89 ec                	mov    %ebp,%esp
  80144b:	5d                   	pop    %ebp
  80144c:	c3                   	ret    
  80144d:	00 00                	add    %al,(%eax)
	...

00801450 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801450:	55                   	push   %ebp
  801451:	89 e5                	mov    %esp,%ebp
  801453:	8b 45 08             	mov    0x8(%ebp),%eax
  801456:	05 00 00 00 30       	add    $0x30000000,%eax
  80145b:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  80145e:	5d                   	pop    %ebp
  80145f:	c3                   	ret    

00801460 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801460:	55                   	push   %ebp
  801461:	89 e5                	mov    %esp,%ebp
  801463:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801466:	8b 45 08             	mov    0x8(%ebp),%eax
  801469:	89 04 24             	mov    %eax,(%esp)
  80146c:	e8 df ff ff ff       	call   801450 <fd2num>
  801471:	05 20 00 0d 00       	add    $0xd0020,%eax
  801476:	c1 e0 0c             	shl    $0xc,%eax
}
  801479:	c9                   	leave  
  80147a:	c3                   	ret    

0080147b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80147b:	55                   	push   %ebp
  80147c:	89 e5                	mov    %esp,%ebp
  80147e:	57                   	push   %edi
  80147f:	56                   	push   %esi
  801480:	53                   	push   %ebx
  801481:	8b 7d 08             	mov    0x8(%ebp),%edi
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  801484:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  801489:	a8 01                	test   $0x1,%al
  80148b:	74 36                	je     8014c3 <fd_alloc+0x48>
  80148d:	a1 00 00 74 ef       	mov    0xef740000,%eax
  801492:	a8 01                	test   $0x1,%al
  801494:	74 2d                	je     8014c3 <fd_alloc+0x48>
  801496:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  80149b:	b9 00 d0 7b ef       	mov    $0xef7bd000,%ecx
  8014a0:	be 00 00 40 ef       	mov    $0xef400000,%esi
  8014a5:	89 c3                	mov    %eax,%ebx
  8014a7:	89 c2                	mov    %eax,%edx
  8014a9:	c1 ea 16             	shr    $0x16,%edx
  8014ac:	8b 14 91             	mov    (%ecx,%edx,4),%edx
  8014af:	f6 c2 01             	test   $0x1,%dl
  8014b2:	74 14                	je     8014c8 <fd_alloc+0x4d>
  8014b4:	89 c2                	mov    %eax,%edx
  8014b6:	c1 ea 0c             	shr    $0xc,%edx
  8014b9:	8b 14 96             	mov    (%esi,%edx,4),%edx
  8014bc:	f6 c2 01             	test   $0x1,%dl
  8014bf:	75 10                	jne    8014d1 <fd_alloc+0x56>
  8014c1:	eb 05                	jmp    8014c8 <fd_alloc+0x4d>
  8014c3:	bb 00 00 00 d0       	mov    $0xd0000000,%ebx
			*fd_store = fd;
  8014c8:	89 1f                	mov    %ebx,(%edi)
  8014ca:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  8014cf:	eb 17                	jmp    8014e8 <fd_alloc+0x6d>
  8014d1:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8014d6:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8014db:	75 c8                	jne    8014a5 <fd_alloc+0x2a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8014dd:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  8014e3:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  8014e8:	5b                   	pop    %ebx
  8014e9:	5e                   	pop    %esi
  8014ea:	5f                   	pop    %edi
  8014eb:	5d                   	pop    %ebp
  8014ec:	c3                   	ret    

008014ed <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8014ed:	55                   	push   %ebp
  8014ee:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8014f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8014f3:	83 f8 1f             	cmp    $0x1f,%eax
  8014f6:	77 36                	ja     80152e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8014f8:	05 00 00 0d 00       	add    $0xd0000,%eax
  8014fd:	c1 e0 0c             	shl    $0xc,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
  801500:	89 c2                	mov    %eax,%edx
  801502:	c1 ea 16             	shr    $0x16,%edx
  801505:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80150c:	f6 c2 01             	test   $0x1,%dl
  80150f:	74 1d                	je     80152e <fd_lookup+0x41>
  801511:	89 c2                	mov    %eax,%edx
  801513:	c1 ea 0c             	shr    $0xc,%edx
  801516:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80151d:	f6 c2 01             	test   $0x1,%dl
  801520:	74 0c                	je     80152e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  801522:	8b 55 0c             	mov    0xc(%ebp),%edx
  801525:	89 02                	mov    %eax,(%edx)
  801527:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
  80152c:	eb 05                	jmp    801533 <fd_lookup+0x46>
  80152e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801533:	5d                   	pop    %ebp
  801534:	c3                   	ret    

00801535 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  801535:	55                   	push   %ebp
  801536:	89 e5                	mov    %esp,%ebp
  801538:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80153b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80153e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801542:	8b 45 08             	mov    0x8(%ebp),%eax
  801545:	89 04 24             	mov    %eax,(%esp)
  801548:	e8 a0 ff ff ff       	call   8014ed <fd_lookup>
  80154d:	85 c0                	test   %eax,%eax
  80154f:	78 0e                	js     80155f <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801551:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801554:	8b 55 0c             	mov    0xc(%ebp),%edx
  801557:	89 50 04             	mov    %edx,0x4(%eax)
  80155a:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  80155f:	c9                   	leave  
  801560:	c3                   	ret    

00801561 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801561:	55                   	push   %ebp
  801562:	89 e5                	mov    %esp,%ebp
  801564:	56                   	push   %esi
  801565:	53                   	push   %ebx
  801566:	83 ec 10             	sub    $0x10,%esp
  801569:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80156c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
// File functions
// --------------------------------------------------------------

static struct Dev *devtab[] =
{
	&devfile,
  80156f:	b8 04 30 80 00       	mov    $0x803004,%eax
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  801574:	ba 00 00 00 00       	mov    $0x0,%edx

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801579:	be 88 25 80 00       	mov    $0x802588,%esi
		if (devtab[i]->dev_id == dev_id) {
  80157e:	39 08                	cmp    %ecx,(%eax)
  801580:	75 10                	jne    801592 <dev_lookup+0x31>
  801582:	eb 04                	jmp    801588 <dev_lookup+0x27>
  801584:	39 08                	cmp    %ecx,(%eax)
  801586:	75 0a                	jne    801592 <dev_lookup+0x31>
			*dev = devtab[i];
  801588:	89 03                	mov    %eax,(%ebx)
  80158a:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  80158f:	90                   	nop
  801590:	eb 31                	jmp    8015c3 <dev_lookup+0x62>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801592:	83 c2 01             	add    $0x1,%edx
  801595:	8b 04 96             	mov    (%esi,%edx,4),%eax
  801598:	85 c0                	test   %eax,%eax
  80159a:	75 e8                	jne    801584 <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80159c:	a1 04 40 80 00       	mov    0x804004,%eax
  8015a1:	8b 40 48             	mov    0x48(%eax),%eax
  8015a4:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8015a8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015ac:	c7 04 24 0c 25 80 00 	movl   $0x80250c,(%esp)
  8015b3:	e8 a1 eb ff ff       	call   800159 <cprintf>
	*dev = 0;
  8015b8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8015be:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  8015c3:	83 c4 10             	add    $0x10,%esp
  8015c6:	5b                   	pop    %ebx
  8015c7:	5e                   	pop    %esi
  8015c8:	5d                   	pop    %ebp
  8015c9:	c3                   	ret    

008015ca <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  8015ca:	55                   	push   %ebp
  8015cb:	89 e5                	mov    %esp,%ebp
  8015cd:	53                   	push   %ebx
  8015ce:	83 ec 24             	sub    $0x24,%esp
  8015d1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015d4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015d7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015db:	8b 45 08             	mov    0x8(%ebp),%eax
  8015de:	89 04 24             	mov    %eax,(%esp)
  8015e1:	e8 07 ff ff ff       	call   8014ed <fd_lookup>
  8015e6:	85 c0                	test   %eax,%eax
  8015e8:	78 53                	js     80163d <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015ea:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015f4:	8b 00                	mov    (%eax),%eax
  8015f6:	89 04 24             	mov    %eax,(%esp)
  8015f9:	e8 63 ff ff ff       	call   801561 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015fe:	85 c0                	test   %eax,%eax
  801600:	78 3b                	js     80163d <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  801602:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801607:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80160a:	83 7a 14 00          	cmpl   $0x0,0x14(%edx)
  80160e:	74 2d                	je     80163d <fstat+0x73>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801610:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801613:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80161a:	00 00 00 
	stat->st_isdir = 0;
  80161d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801624:	00 00 00 
	stat->st_dev = dev;
  801627:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80162a:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801630:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801634:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801637:	89 14 24             	mov    %edx,(%esp)
  80163a:	ff 50 14             	call   *0x14(%eax)
}
  80163d:	83 c4 24             	add    $0x24,%esp
  801640:	5b                   	pop    %ebx
  801641:	5d                   	pop    %ebp
  801642:	c3                   	ret    

00801643 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  801643:	55                   	push   %ebp
  801644:	89 e5                	mov    %esp,%ebp
  801646:	53                   	push   %ebx
  801647:	83 ec 24             	sub    $0x24,%esp
  80164a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80164d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801650:	89 44 24 04          	mov    %eax,0x4(%esp)
  801654:	89 1c 24             	mov    %ebx,(%esp)
  801657:	e8 91 fe ff ff       	call   8014ed <fd_lookup>
  80165c:	85 c0                	test   %eax,%eax
  80165e:	78 5f                	js     8016bf <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801660:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801663:	89 44 24 04          	mov    %eax,0x4(%esp)
  801667:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80166a:	8b 00                	mov    (%eax),%eax
  80166c:	89 04 24             	mov    %eax,(%esp)
  80166f:	e8 ed fe ff ff       	call   801561 <dev_lookup>
ftruncate(int fdnum, off_t newsize)
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801674:	85 c0                	test   %eax,%eax
  801676:	78 47                	js     8016bf <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801678:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80167b:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  80167f:	75 23                	jne    8016a4 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801681:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801686:	8b 40 48             	mov    0x48(%eax),%eax
  801689:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80168d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801691:	c7 04 24 2c 25 80 00 	movl   $0x80252c,(%esp)
  801698:	e8 bc ea ff ff       	call   800159 <cprintf>
  80169d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8016a2:	eb 1b                	jmp    8016bf <ftruncate+0x7c>
	}
	if (!dev->dev_trunc)
  8016a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016a7:	8b 48 18             	mov    0x18(%eax),%ecx
  8016aa:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8016af:	85 c9                	test   %ecx,%ecx
  8016b1:	74 0c                	je     8016bf <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8016b3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016b6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016ba:	89 14 24             	mov    %edx,(%esp)
  8016bd:	ff d1                	call   *%ecx
}
  8016bf:	83 c4 24             	add    $0x24,%esp
  8016c2:	5b                   	pop    %ebx
  8016c3:	5d                   	pop    %ebp
  8016c4:	c3                   	ret    

008016c5 <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8016c5:	55                   	push   %ebp
  8016c6:	89 e5                	mov    %esp,%ebp
  8016c8:	53                   	push   %ebx
  8016c9:	83 ec 24             	sub    $0x24,%esp
  8016cc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016cf:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016d2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016d6:	89 1c 24             	mov    %ebx,(%esp)
  8016d9:	e8 0f fe ff ff       	call   8014ed <fd_lookup>
  8016de:	85 c0                	test   %eax,%eax
  8016e0:	78 66                	js     801748 <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016e2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016e5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016ec:	8b 00                	mov    (%eax),%eax
  8016ee:	89 04 24             	mov    %eax,(%esp)
  8016f1:	e8 6b fe ff ff       	call   801561 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016f6:	85 c0                	test   %eax,%eax
  8016f8:	78 4e                	js     801748 <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016fa:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8016fd:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  801701:	75 23                	jne    801726 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801703:	a1 04 40 80 00       	mov    0x804004,%eax
  801708:	8b 40 48             	mov    0x48(%eax),%eax
  80170b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80170f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801713:	c7 04 24 4d 25 80 00 	movl   $0x80254d,(%esp)
  80171a:	e8 3a ea ff ff       	call   800159 <cprintf>
  80171f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801724:	eb 22                	jmp    801748 <write+0x83>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801726:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801729:	8b 48 0c             	mov    0xc(%eax),%ecx
  80172c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801731:	85 c9                	test   %ecx,%ecx
  801733:	74 13                	je     801748 <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801735:	8b 45 10             	mov    0x10(%ebp),%eax
  801738:	89 44 24 08          	mov    %eax,0x8(%esp)
  80173c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80173f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801743:	89 14 24             	mov    %edx,(%esp)
  801746:	ff d1                	call   *%ecx
}
  801748:	83 c4 24             	add    $0x24,%esp
  80174b:	5b                   	pop    %ebx
  80174c:	5d                   	pop    %ebp
  80174d:	c3                   	ret    

0080174e <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80174e:	55                   	push   %ebp
  80174f:	89 e5                	mov    %esp,%ebp
  801751:	53                   	push   %ebx
  801752:	83 ec 24             	sub    $0x24,%esp
  801755:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801758:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80175b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80175f:	89 1c 24             	mov    %ebx,(%esp)
  801762:	e8 86 fd ff ff       	call   8014ed <fd_lookup>
  801767:	85 c0                	test   %eax,%eax
  801769:	78 6b                	js     8017d6 <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80176b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80176e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801772:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801775:	8b 00                	mov    (%eax),%eax
  801777:	89 04 24             	mov    %eax,(%esp)
  80177a:	e8 e2 fd ff ff       	call   801561 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80177f:	85 c0                	test   %eax,%eax
  801781:	78 53                	js     8017d6 <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801783:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801786:	8b 42 08             	mov    0x8(%edx),%eax
  801789:	83 e0 03             	and    $0x3,%eax
  80178c:	83 f8 01             	cmp    $0x1,%eax
  80178f:	75 23                	jne    8017b4 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801791:	a1 04 40 80 00       	mov    0x804004,%eax
  801796:	8b 40 48             	mov    0x48(%eax),%eax
  801799:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80179d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017a1:	c7 04 24 6a 25 80 00 	movl   $0x80256a,(%esp)
  8017a8:	e8 ac e9 ff ff       	call   800159 <cprintf>
  8017ad:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  8017b2:	eb 22                	jmp    8017d6 <read+0x88>
	}
	if (!dev->dev_read)
  8017b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017b7:	8b 48 08             	mov    0x8(%eax),%ecx
  8017ba:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8017bf:	85 c9                	test   %ecx,%ecx
  8017c1:	74 13                	je     8017d6 <read+0x88>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8017c3:	8b 45 10             	mov    0x10(%ebp),%eax
  8017c6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8017ca:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017d1:	89 14 24             	mov    %edx,(%esp)
  8017d4:	ff d1                	call   *%ecx
}
  8017d6:	83 c4 24             	add    $0x24,%esp
  8017d9:	5b                   	pop    %ebx
  8017da:	5d                   	pop    %ebp
  8017db:	c3                   	ret    

008017dc <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8017dc:	55                   	push   %ebp
  8017dd:	89 e5                	mov    %esp,%ebp
  8017df:	57                   	push   %edi
  8017e0:	56                   	push   %esi
  8017e1:	53                   	push   %ebx
  8017e2:	83 ec 1c             	sub    $0x1c,%esp
  8017e5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8017e8:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8017eb:	ba 00 00 00 00       	mov    $0x0,%edx
  8017f0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8017f5:	b8 00 00 00 00       	mov    $0x0,%eax
  8017fa:	85 f6                	test   %esi,%esi
  8017fc:	74 29                	je     801827 <readn+0x4b>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8017fe:	89 f0                	mov    %esi,%eax
  801800:	29 d0                	sub    %edx,%eax
  801802:	89 44 24 08          	mov    %eax,0x8(%esp)
  801806:	03 55 0c             	add    0xc(%ebp),%edx
  801809:	89 54 24 04          	mov    %edx,0x4(%esp)
  80180d:	89 3c 24             	mov    %edi,(%esp)
  801810:	e8 39 ff ff ff       	call   80174e <read>
		if (m < 0)
  801815:	85 c0                	test   %eax,%eax
  801817:	78 0e                	js     801827 <readn+0x4b>
			return m;
		if (m == 0)
  801819:	85 c0                	test   %eax,%eax
  80181b:	74 08                	je     801825 <readn+0x49>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80181d:	01 c3                	add    %eax,%ebx
  80181f:	89 da                	mov    %ebx,%edx
  801821:	39 f3                	cmp    %esi,%ebx
  801823:	72 d9                	jb     8017fe <readn+0x22>
  801825:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801827:	83 c4 1c             	add    $0x1c,%esp
  80182a:	5b                   	pop    %ebx
  80182b:	5e                   	pop    %esi
  80182c:	5f                   	pop    %edi
  80182d:	5d                   	pop    %ebp
  80182e:	c3                   	ret    

0080182f <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80182f:	55                   	push   %ebp
  801830:	89 e5                	mov    %esp,%ebp
  801832:	56                   	push   %esi
  801833:	53                   	push   %ebx
  801834:	83 ec 20             	sub    $0x20,%esp
  801837:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80183a:	89 34 24             	mov    %esi,(%esp)
  80183d:	e8 0e fc ff ff       	call   801450 <fd2num>
  801842:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801845:	89 54 24 04          	mov    %edx,0x4(%esp)
  801849:	89 04 24             	mov    %eax,(%esp)
  80184c:	e8 9c fc ff ff       	call   8014ed <fd_lookup>
  801851:	89 c3                	mov    %eax,%ebx
  801853:	85 c0                	test   %eax,%eax
  801855:	78 05                	js     80185c <fd_close+0x2d>
  801857:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80185a:	74 0c                	je     801868 <fd_close+0x39>
	    || fd != fd2)
		return (must_exist ? r : 0);
  80185c:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  801860:	19 c0                	sbb    %eax,%eax
  801862:	f7 d0                	not    %eax
  801864:	21 c3                	and    %eax,%ebx
  801866:	eb 3d                	jmp    8018a5 <fd_close+0x76>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801868:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80186b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80186f:	8b 06                	mov    (%esi),%eax
  801871:	89 04 24             	mov    %eax,(%esp)
  801874:	e8 e8 fc ff ff       	call   801561 <dev_lookup>
  801879:	89 c3                	mov    %eax,%ebx
  80187b:	85 c0                	test   %eax,%eax
  80187d:	78 16                	js     801895 <fd_close+0x66>
		if (dev->dev_close)
  80187f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801882:	8b 40 10             	mov    0x10(%eax),%eax
  801885:	bb 00 00 00 00       	mov    $0x0,%ebx
  80188a:	85 c0                	test   %eax,%eax
  80188c:	74 07                	je     801895 <fd_close+0x66>
			r = (*dev->dev_close)(fd);
  80188e:	89 34 24             	mov    %esi,(%esp)
  801891:	ff d0                	call   *%eax
  801893:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801895:	89 74 24 04          	mov    %esi,0x4(%esp)
  801899:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018a0:	e8 34 f9 ff ff       	call   8011d9 <sys_page_unmap>
	return r;
}
  8018a5:	89 d8                	mov    %ebx,%eax
  8018a7:	83 c4 20             	add    $0x20,%esp
  8018aa:	5b                   	pop    %ebx
  8018ab:	5e                   	pop    %esi
  8018ac:	5d                   	pop    %ebp
  8018ad:	c3                   	ret    

008018ae <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8018ae:	55                   	push   %ebp
  8018af:	89 e5                	mov    %esp,%ebp
  8018b1:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8018b4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018b7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8018be:	89 04 24             	mov    %eax,(%esp)
  8018c1:	e8 27 fc ff ff       	call   8014ed <fd_lookup>
  8018c6:	85 c0                	test   %eax,%eax
  8018c8:	78 13                	js     8018dd <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  8018ca:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8018d1:	00 
  8018d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018d5:	89 04 24             	mov    %eax,(%esp)
  8018d8:	e8 52 ff ff ff       	call   80182f <fd_close>
}
  8018dd:	c9                   	leave  
  8018de:	c3                   	ret    

008018df <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  8018df:	55                   	push   %ebp
  8018e0:	89 e5                	mov    %esp,%ebp
  8018e2:	83 ec 18             	sub    $0x18,%esp
  8018e5:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8018e8:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8018eb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8018f2:	00 
  8018f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8018f6:	89 04 24             	mov    %eax,(%esp)
  8018f9:	e8 79 03 00 00       	call   801c77 <open>
  8018fe:	89 c3                	mov    %eax,%ebx
  801900:	85 c0                	test   %eax,%eax
  801902:	78 1b                	js     80191f <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  801904:	8b 45 0c             	mov    0xc(%ebp),%eax
  801907:	89 44 24 04          	mov    %eax,0x4(%esp)
  80190b:	89 1c 24             	mov    %ebx,(%esp)
  80190e:	e8 b7 fc ff ff       	call   8015ca <fstat>
  801913:	89 c6                	mov    %eax,%esi
	close(fd);
  801915:	89 1c 24             	mov    %ebx,(%esp)
  801918:	e8 91 ff ff ff       	call   8018ae <close>
  80191d:	89 f3                	mov    %esi,%ebx
	return r;
}
  80191f:	89 d8                	mov    %ebx,%eax
  801921:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801924:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801927:	89 ec                	mov    %ebp,%esp
  801929:	5d                   	pop    %ebp
  80192a:	c3                   	ret    

0080192b <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  80192b:	55                   	push   %ebp
  80192c:	89 e5                	mov    %esp,%ebp
  80192e:	53                   	push   %ebx
  80192f:	83 ec 14             	sub    $0x14,%esp
  801932:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  801937:	89 1c 24             	mov    %ebx,(%esp)
  80193a:	e8 6f ff ff ff       	call   8018ae <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80193f:	83 c3 01             	add    $0x1,%ebx
  801942:	83 fb 20             	cmp    $0x20,%ebx
  801945:	75 f0                	jne    801937 <close_all+0xc>
		close(i);
}
  801947:	83 c4 14             	add    $0x14,%esp
  80194a:	5b                   	pop    %ebx
  80194b:	5d                   	pop    %ebp
  80194c:	c3                   	ret    

0080194d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80194d:	55                   	push   %ebp
  80194e:	89 e5                	mov    %esp,%ebp
  801950:	83 ec 58             	sub    $0x58,%esp
  801953:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801956:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801959:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80195c:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80195f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801962:	89 44 24 04          	mov    %eax,0x4(%esp)
  801966:	8b 45 08             	mov    0x8(%ebp),%eax
  801969:	89 04 24             	mov    %eax,(%esp)
  80196c:	e8 7c fb ff ff       	call   8014ed <fd_lookup>
  801971:	89 c3                	mov    %eax,%ebx
  801973:	85 c0                	test   %eax,%eax
  801975:	0f 88 e0 00 00 00    	js     801a5b <dup+0x10e>
		return r;
	close(newfdnum);
  80197b:	89 3c 24             	mov    %edi,(%esp)
  80197e:	e8 2b ff ff ff       	call   8018ae <close>

	newfd = INDEX2FD(newfdnum);
  801983:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801989:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  80198c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80198f:	89 04 24             	mov    %eax,(%esp)
  801992:	e8 c9 fa ff ff       	call   801460 <fd2data>
  801997:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801999:	89 34 24             	mov    %esi,(%esp)
  80199c:	e8 bf fa ff ff       	call   801460 <fd2data>
  8019a1:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
  8019a4:	89 da                	mov    %ebx,%edx
  8019a6:	89 d8                	mov    %ebx,%eax
  8019a8:	c1 e8 16             	shr    $0x16,%eax
  8019ab:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8019b2:	a8 01                	test   $0x1,%al
  8019b4:	74 43                	je     8019f9 <dup+0xac>
  8019b6:	c1 ea 0c             	shr    $0xc,%edx
  8019b9:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  8019c0:	a8 01                	test   $0x1,%al
  8019c2:	74 35                	je     8019f9 <dup+0xac>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8019c4:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  8019cb:	25 07 0e 00 00       	and    $0xe07,%eax
  8019d0:	89 44 24 10          	mov    %eax,0x10(%esp)
  8019d4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8019d7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8019db:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8019e2:	00 
  8019e3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8019e7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019ee:	e8 52 f8 ff ff       	call   801245 <sys_page_map>
  8019f3:	89 c3                	mov    %eax,%ebx
  8019f5:	85 c0                	test   %eax,%eax
  8019f7:	78 3f                	js     801a38 <dup+0xeb>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8019f9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8019fc:	89 c2                	mov    %eax,%edx
  8019fe:	c1 ea 0c             	shr    $0xc,%edx
  801a01:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801a08:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801a0e:	89 54 24 10          	mov    %edx,0x10(%esp)
  801a12:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801a16:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801a1d:	00 
  801a1e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a22:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a29:	e8 17 f8 ff ff       	call   801245 <sys_page_map>
  801a2e:	89 c3                	mov    %eax,%ebx
  801a30:	85 c0                	test   %eax,%eax
  801a32:	78 04                	js     801a38 <dup+0xeb>
  801a34:	89 fb                	mov    %edi,%ebx
  801a36:	eb 23                	jmp    801a5b <dup+0x10e>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801a38:	89 74 24 04          	mov    %esi,0x4(%esp)
  801a3c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a43:	e8 91 f7 ff ff       	call   8011d9 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801a48:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801a4b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a4f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a56:	e8 7e f7 ff ff       	call   8011d9 <sys_page_unmap>
	return r;
}
  801a5b:	89 d8                	mov    %ebx,%eax
  801a5d:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801a60:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801a63:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801a66:	89 ec                	mov    %ebp,%esp
  801a68:	5d                   	pop    %ebp
  801a69:	c3                   	ret    
	...

00801a6c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801a6c:	55                   	push   %ebp
  801a6d:	89 e5                	mov    %esp,%ebp
  801a6f:	83 ec 18             	sub    $0x18,%esp
  801a72:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801a75:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801a78:	89 c3                	mov    %eax,%ebx
  801a7a:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801a7c:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801a83:	75 11                	jne    801a96 <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801a85:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801a8c:	e8 df 02 00 00       	call   801d70 <ipc_find_env>
  801a91:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801a96:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801a9d:	00 
  801a9e:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801aa5:	00 
  801aa6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801aaa:	a1 00 40 80 00       	mov    0x804000,%eax
  801aaf:	89 04 24             	mov    %eax,(%esp)
  801ab2:	e8 04 03 00 00       	call   801dbb <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801ab7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801abe:	00 
  801abf:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ac3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801aca:	e8 6a 03 00 00       	call   801e39 <ipc_recv>
}
  801acf:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801ad2:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801ad5:	89 ec                	mov    %ebp,%esp
  801ad7:	5d                   	pop    %ebp
  801ad8:	c3                   	ret    

00801ad9 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801ad9:	55                   	push   %ebp
  801ada:	89 e5                	mov    %esp,%ebp
  801adc:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801adf:	8b 45 08             	mov    0x8(%ebp),%eax
  801ae2:	8b 40 0c             	mov    0xc(%eax),%eax
  801ae5:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801aea:	8b 45 0c             	mov    0xc(%ebp),%eax
  801aed:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801af2:	ba 00 00 00 00       	mov    $0x0,%edx
  801af7:	b8 02 00 00 00       	mov    $0x2,%eax
  801afc:	e8 6b ff ff ff       	call   801a6c <fsipc>
}
  801b01:	c9                   	leave  
  801b02:	c3                   	ret    

00801b03 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801b03:	55                   	push   %ebp
  801b04:	89 e5                	mov    %esp,%ebp
  801b06:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801b09:	8b 45 08             	mov    0x8(%ebp),%eax
  801b0c:	8b 40 0c             	mov    0xc(%eax),%eax
  801b0f:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801b14:	ba 00 00 00 00       	mov    $0x0,%edx
  801b19:	b8 06 00 00 00       	mov    $0x6,%eax
  801b1e:	e8 49 ff ff ff       	call   801a6c <fsipc>
}
  801b23:	c9                   	leave  
  801b24:	c3                   	ret    

00801b25 <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  801b25:	55                   	push   %ebp
  801b26:	89 e5                	mov    %esp,%ebp
  801b28:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801b2b:	ba 00 00 00 00       	mov    $0x0,%edx
  801b30:	b8 08 00 00 00       	mov    $0x8,%eax
  801b35:	e8 32 ff ff ff       	call   801a6c <fsipc>
}
  801b3a:	c9                   	leave  
  801b3b:	c3                   	ret    

00801b3c <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801b3c:	55                   	push   %ebp
  801b3d:	89 e5                	mov    %esp,%ebp
  801b3f:	53                   	push   %ebx
  801b40:	83 ec 14             	sub    $0x14,%esp
  801b43:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801b46:	8b 45 08             	mov    0x8(%ebp),%eax
  801b49:	8b 40 0c             	mov    0xc(%eax),%eax
  801b4c:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801b51:	ba 00 00 00 00       	mov    $0x0,%edx
  801b56:	b8 05 00 00 00       	mov    $0x5,%eax
  801b5b:	e8 0c ff ff ff       	call   801a6c <fsipc>
  801b60:	85 c0                	test   %eax,%eax
  801b62:	78 2b                	js     801b8f <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801b64:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801b6b:	00 
  801b6c:	89 1c 24             	mov    %ebx,(%esp)
  801b6f:	e8 16 ef ff ff       	call   800a8a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801b74:	a1 80 50 80 00       	mov    0x805080,%eax
  801b79:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801b7f:	a1 84 50 80 00       	mov    0x805084,%eax
  801b84:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  801b8a:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  801b8f:	83 c4 14             	add    $0x14,%esp
  801b92:	5b                   	pop    %ebx
  801b93:	5d                   	pop    %ebp
  801b94:	c3                   	ret    

00801b95 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801b95:	55                   	push   %ebp
  801b96:	89 e5                	mov    %esp,%ebp
  801b98:	83 ec 18             	sub    $0x18,%esp
  801b9b:	8b 45 10             	mov    0x10(%ebp),%eax
  801b9e:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801ba3:	76 05                	jbe    801baa <devfile_write+0x15>
  801ba5:	b8 f8 0f 00 00       	mov    $0xff8,%eax
	// bytes than requested.
	// LAB 5: Your code here
        int r;
        if(n > sizeof(fsipcbuf.write.req_buf))
            n = sizeof(fsipcbuf.write.req_buf);
        fsipcbuf.write.req_fileid = fd->fd_file.id;
  801baa:	8b 55 08             	mov    0x8(%ebp),%edx
  801bad:	8b 52 0c             	mov    0xc(%edx),%edx
  801bb0:	89 15 00 50 80 00    	mov    %edx,0x805000
        fsipcbuf.write.req_n = n;
  801bb6:	a3 04 50 80 00       	mov    %eax,0x805004
        memmove(fsipcbuf.write.req_buf,buf,n);  
  801bbb:	89 44 24 08          	mov    %eax,0x8(%esp)
  801bbf:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bc2:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bc6:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  801bcd:	e8 a3 f0 ff ff       	call   800c75 <memmove>
        r = fsipc(FSREQ_WRITE,NULL);
  801bd2:	ba 00 00 00 00       	mov    $0x0,%edx
  801bd7:	b8 04 00 00 00       	mov    $0x4,%eax
  801bdc:	e8 8b fe ff ff       	call   801a6c <fsipc>
        return r;
	//panic("devfile_write not implemented");
}
  801be1:	c9                   	leave  
  801be2:	c3                   	ret    

00801be3 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801be3:	55                   	push   %ebp
  801be4:	89 e5                	mov    %esp,%ebp
  801be6:	53                   	push   %ebx
  801be7:	83 ec 14             	sub    $0x14,%esp
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
        int r;
        fsipcbuf.read.req_fileid = fd->fd_file.id;
  801bea:	8b 45 08             	mov    0x8(%ebp),%eax
  801bed:	8b 40 0c             	mov    0xc(%eax),%eax
  801bf0:	a3 00 50 80 00       	mov    %eax,0x805000
        fsipcbuf.read.req_n = n;
  801bf5:	8b 45 10             	mov    0x10(%ebp),%eax
  801bf8:	a3 04 50 80 00       	mov    %eax,0x805004
        r = fsipc(FSREQ_READ,NULL);
  801bfd:	ba 00 00 00 00       	mov    $0x0,%edx
  801c02:	b8 03 00 00 00       	mov    $0x3,%eax
  801c07:	e8 60 fe ff ff       	call   801a6c <fsipc>
  801c0c:	89 c3                	mov    %eax,%ebx
        if(r < 0)
  801c0e:	85 c0                	test   %eax,%eax
  801c10:	78 17                	js     801c29 <devfile_read+0x46>
           return r;
        memmove(buf,fsipcbuf.readRet.ret_buf,r);
  801c12:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c16:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801c1d:	00 
  801c1e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c21:	89 04 24             	mov    %eax,(%esp)
  801c24:	e8 4c f0 ff ff       	call   800c75 <memmove>
        return r;
	//panic("devfile_read not implemented");
}
  801c29:	89 d8                	mov    %ebx,%eax
  801c2b:	83 c4 14             	add    $0x14,%esp
  801c2e:	5b                   	pop    %ebx
  801c2f:	5d                   	pop    %ebp
  801c30:	c3                   	ret    

00801c31 <remove>:
}

// Delete a file
int
remove(const char *path)
{
  801c31:	55                   	push   %ebp
  801c32:	89 e5                	mov    %esp,%ebp
  801c34:	53                   	push   %ebx
  801c35:	83 ec 14             	sub    $0x14,%esp
  801c38:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  801c3b:	89 1c 24             	mov    %ebx,(%esp)
  801c3e:	e8 fd ed ff ff       	call   800a40 <strlen>
  801c43:	89 c2                	mov    %eax,%edx
  801c45:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  801c4a:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
  801c50:	7f 1f                	jg     801c71 <remove+0x40>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  801c52:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c56:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801c5d:	e8 28 ee ff ff       	call   800a8a <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  801c62:	ba 00 00 00 00       	mov    $0x0,%edx
  801c67:	b8 07 00 00 00       	mov    $0x7,%eax
  801c6c:	e8 fb fd ff ff       	call   801a6c <fsipc>
}
  801c71:	83 c4 14             	add    $0x14,%esp
  801c74:	5b                   	pop    %ebx
  801c75:	5d                   	pop    %ebp
  801c76:	c3                   	ret    

00801c77 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801c77:	55                   	push   %ebp
  801c78:	89 e5                	mov    %esp,%ebp
  801c7a:	83 ec 28             	sub    $0x28,%esp
  801c7d:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801c80:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801c83:	8b 75 08             	mov    0x8(%ebp),%esi
	// If any step after fd_alloc fails, use fd_close to free the
	// file descriptor.

	// LAB 5: Your code here.
        struct Fd* fd;
        if(strlen(path) > MAXPATHLEN)
  801c86:	89 34 24             	mov    %esi,(%esp)
  801c89:	e8 b2 ed ff ff       	call   800a40 <strlen>
  801c8e:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801c93:	3d 00 04 00 00       	cmp    $0x400,%eax
  801c98:	7f 6d                	jg     801d07 <open+0x90>
            return -E_BAD_PATH;
        int r;
        r = fd_alloc(&fd);
  801c9a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c9d:	89 04 24             	mov    %eax,(%esp)
  801ca0:	e8 d6 f7 ff ff       	call   80147b <fd_alloc>
  801ca5:	89 c3                	mov    %eax,%ebx
        if(r < 0)
  801ca7:	85 c0                	test   %eax,%eax
  801ca9:	78 5c                	js     801d07 <open+0x90>
           return r;
        fsipcbuf.open.req_omode = mode;
  801cab:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cae:	a3 00 54 80 00       	mov    %eax,0x805400
        memmove(fsipcbuf.open.req_path,path,strlen(path)+1);
  801cb3:	89 34 24             	mov    %esi,(%esp)
  801cb6:	e8 85 ed ff ff       	call   800a40 <strlen>
  801cbb:	83 c0 01             	add    $0x1,%eax
  801cbe:	89 44 24 08          	mov    %eax,0x8(%esp)
  801cc2:	89 74 24 04          	mov    %esi,0x4(%esp)
  801cc6:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801ccd:	e8 a3 ef ff ff       	call   800c75 <memmove>
        r = fsipc(FSREQ_OPEN,(void*)fd);
  801cd2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801cd5:	b8 01 00 00 00       	mov    $0x1,%eax
  801cda:	e8 8d fd ff ff       	call   801a6c <fsipc>
  801cdf:	89 c3                	mov    %eax,%ebx
        if(r < 0){
  801ce1:	85 c0                	test   %eax,%eax
  801ce3:	79 15                	jns    801cfa <open+0x83>
             fd_close(fd,0);
  801ce5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801cec:	00 
  801ced:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cf0:	89 04 24             	mov    %eax,(%esp)
  801cf3:	e8 37 fb ff ff       	call   80182f <fd_close>
             return r;
  801cf8:	eb 0d                	jmp    801d07 <open+0x90>
        }
        return fd2num(fd);
  801cfa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cfd:	89 04 24             	mov    %eax,(%esp)
  801d00:	e8 4b f7 ff ff       	call   801450 <fd2num>
  801d05:	89 c3                	mov    %eax,%ebx
	//panic("open not implemented");
}
  801d07:	89 d8                	mov    %ebx,%eax
  801d09:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801d0c:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801d0f:	89 ec                	mov    %ebp,%esp
  801d11:	5d                   	pop    %ebp
  801d12:	c3                   	ret    
	...

00801d14 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801d14:	55                   	push   %ebp
  801d15:	89 e5                	mov    %esp,%ebp
  801d17:	56                   	push   %esi
  801d18:	53                   	push   %ebx
  801d19:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  801d1c:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801d1f:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  801d25:	e8 78 f6 ff ff       	call   8013a2 <sys_getenvid>
  801d2a:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d2d:	89 54 24 10          	mov    %edx,0x10(%esp)
  801d31:	8b 55 08             	mov    0x8(%ebp),%edx
  801d34:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801d38:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801d3c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d40:	c7 04 24 90 25 80 00 	movl   $0x802590,(%esp)
  801d47:	e8 0d e4 ff ff       	call   800159 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801d4c:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d50:	8b 45 10             	mov    0x10(%ebp),%eax
  801d53:	89 04 24             	mov    %eax,(%esp)
  801d56:	e8 9d e3 ff ff       	call   8000f8 <vcprintf>
	cprintf("\n");
  801d5b:	c7 04 24 36 21 80 00 	movl   $0x802136,(%esp)
  801d62:	e8 f2 e3 ff ff       	call   800159 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801d67:	cc                   	int3   
  801d68:	eb fd                	jmp    801d67 <_panic+0x53>
  801d6a:	00 00                	add    %al,(%eax)
  801d6c:	00 00                	add    %al,(%eax)
	...

00801d70 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801d70:	55                   	push   %ebp
  801d71:	89 e5                	mov    %esp,%ebp
  801d73:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801d76:	8b 15 50 00 c0 ee    	mov    0xeec00050,%edx
  801d7c:	b8 01 00 00 00       	mov    $0x1,%eax
  801d81:	39 ca                	cmp    %ecx,%edx
  801d83:	75 04                	jne    801d89 <ipc_find_env+0x19>
  801d85:	b0 00                	mov    $0x0,%al
  801d87:	eb 12                	jmp    801d9b <ipc_find_env+0x2b>
  801d89:	89 c2                	mov    %eax,%edx
  801d8b:	c1 e2 07             	shl    $0x7,%edx
  801d8e:	8d 94 82 50 00 c0 ee 	lea    -0x113fffb0(%edx,%eax,4),%edx
  801d95:	8b 12                	mov    (%edx),%edx
  801d97:	39 ca                	cmp    %ecx,%edx
  801d99:	75 10                	jne    801dab <ipc_find_env+0x3b>
			return envs[i].env_id;
  801d9b:	89 c2                	mov    %eax,%edx
  801d9d:	c1 e2 07             	shl    $0x7,%edx
  801da0:	8d 84 82 48 00 c0 ee 	lea    -0x113fffb8(%edx,%eax,4),%eax
  801da7:	8b 00                	mov    (%eax),%eax
  801da9:	eb 0e                	jmp    801db9 <ipc_find_env+0x49>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801dab:	83 c0 01             	add    $0x1,%eax
  801dae:	3d 00 04 00 00       	cmp    $0x400,%eax
  801db3:	75 d4                	jne    801d89 <ipc_find_env+0x19>
  801db5:	66 b8 00 00          	mov    $0x0,%ax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  801db9:	5d                   	pop    %ebp
  801dba:	c3                   	ret    

00801dbb <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801dbb:	55                   	push   %ebp
  801dbc:	89 e5                	mov    %esp,%ebp
  801dbe:	57                   	push   %edi
  801dbf:	56                   	push   %esi
  801dc0:	53                   	push   %ebx
  801dc1:	83 ec 1c             	sub    $0x1c,%esp
  801dc4:	8b 75 08             	mov    0x8(%ebp),%esi
  801dc7:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801dca:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        int ret;
        while(1){
           if(pg)
  801dcd:	85 db                	test   %ebx,%ebx
  801dcf:	74 19                	je     801dea <ipc_send+0x2f>
              ret = sys_ipc_try_send(to_env,val,pg,perm);
  801dd1:	8b 45 14             	mov    0x14(%ebp),%eax
  801dd4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801dd8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801ddc:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801de0:	89 34 24             	mov    %esi,(%esp)
  801de3:	e8 6c f2 ff ff       	call   801054 <sys_ipc_try_send>
  801de8:	eb 1b                	jmp    801e05 <ipc_send+0x4a>
           else
              ret = sys_ipc_try_send(to_env,val,(void*)UTOP,perm);
  801dea:	8b 45 14             	mov    0x14(%ebp),%eax
  801ded:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801df1:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  801df8:	ee 
  801df9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801dfd:	89 34 24             	mov    %esi,(%esp)
  801e00:	e8 4f f2 ff ff       	call   801054 <sys_ipc_try_send>
           if(ret == 0)
  801e05:	85 c0                	test   %eax,%eax
  801e07:	74 28                	je     801e31 <ipc_send+0x76>
              return;
           if(ret != -E_IPC_NOT_RECV)
  801e09:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801e0c:	74 1c                	je     801e2a <ipc_send+0x6f>
              panic("ipc send error");
  801e0e:	c7 44 24 08 b4 25 80 	movl   $0x8025b4,0x8(%esp)
  801e15:	00 
  801e16:	c7 44 24 04 46 00 00 	movl   $0x46,0x4(%esp)
  801e1d:	00 
  801e1e:	c7 04 24 c3 25 80 00 	movl   $0x8025c3,(%esp)
  801e25:	e8 ea fe ff ff       	call   801d14 <_panic>
           sys_yield();
  801e2a:	e8 f1 f4 ff ff       	call   801320 <sys_yield>
        }
  801e2f:	eb 9c                	jmp    801dcd <ipc_send+0x12>
	//panic("ipc_send not implemented");
}
  801e31:	83 c4 1c             	add    $0x1c,%esp
  801e34:	5b                   	pop    %ebx
  801e35:	5e                   	pop    %esi
  801e36:	5f                   	pop    %edi
  801e37:	5d                   	pop    %ebp
  801e38:	c3                   	ret    

00801e39 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e39:	55                   	push   %ebp
  801e3a:	89 e5                	mov    %esp,%ebp
  801e3c:	56                   	push   %esi
  801e3d:	53                   	push   %ebx
  801e3e:	83 ec 10             	sub    $0x10,%esp
  801e41:	8b 75 08             	mov    0x8(%ebp),%esi
  801e44:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e47:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        int ret;
        if(!pg)
  801e4a:	85 c0                	test   %eax,%eax
  801e4c:	75 0e                	jne    801e5c <ipc_recv+0x23>
           ret = sys_ipc_recv((void*)UTOP);
  801e4e:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  801e55:	e8 8f f1 ff ff       	call   800fe9 <sys_ipc_recv>
  801e5a:	eb 08                	jmp    801e64 <ipc_recv+0x2b>
        else
           ret = sys_ipc_recv(pg);
  801e5c:	89 04 24             	mov    %eax,(%esp)
  801e5f:	e8 85 f1 ff ff       	call   800fe9 <sys_ipc_recv>
        if(ret == 0){
  801e64:	85 c0                	test   %eax,%eax
  801e66:	75 26                	jne    801e8e <ipc_recv+0x55>
           if(from_env_store)
  801e68:	85 f6                	test   %esi,%esi
  801e6a:	74 0a                	je     801e76 <ipc_recv+0x3d>
              *from_env_store = thisenv->env_ipc_from;
  801e6c:	a1 04 40 80 00       	mov    0x804004,%eax
  801e71:	8b 40 78             	mov    0x78(%eax),%eax
  801e74:	89 06                	mov    %eax,(%esi)
           if(perm_store)
  801e76:	85 db                	test   %ebx,%ebx
  801e78:	74 0a                	je     801e84 <ipc_recv+0x4b>
              *perm_store = thisenv->env_ipc_perm;
  801e7a:	a1 04 40 80 00       	mov    0x804004,%eax
  801e7f:	8b 40 7c             	mov    0x7c(%eax),%eax
  801e82:	89 03                	mov    %eax,(%ebx)
           return thisenv->env_ipc_value;
  801e84:	a1 04 40 80 00       	mov    0x804004,%eax
  801e89:	8b 40 74             	mov    0x74(%eax),%eax
  801e8c:	eb 14                	jmp    801ea2 <ipc_recv+0x69>
        }
        else{
           if(from_env_store)
  801e8e:	85 f6                	test   %esi,%esi
  801e90:	74 06                	je     801e98 <ipc_recv+0x5f>
              *from_env_store = 0;
  801e92:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
           if(perm_store)
  801e98:	85 db                	test   %ebx,%ebx
  801e9a:	74 06                	je     801ea2 <ipc_recv+0x69>
              *perm_store = 0;
  801e9c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
           return ret;
        }
	//panic("ipc_recv not implemented");
	return 0;
}
  801ea2:	83 c4 10             	add    $0x10,%esp
  801ea5:	5b                   	pop    %ebx
  801ea6:	5e                   	pop    %esi
  801ea7:	5d                   	pop    %ebp
  801ea8:	c3                   	ret    
  801ea9:	00 00                	add    %al,(%eax)
  801eab:	00 00                	add    %al,(%eax)
  801ead:	00 00                	add    %al,(%eax)
	...

00801eb0 <__udivdi3>:
  801eb0:	55                   	push   %ebp
  801eb1:	89 e5                	mov    %esp,%ebp
  801eb3:	57                   	push   %edi
  801eb4:	56                   	push   %esi
  801eb5:	83 ec 10             	sub    $0x10,%esp
  801eb8:	8b 45 14             	mov    0x14(%ebp),%eax
  801ebb:	8b 55 08             	mov    0x8(%ebp),%edx
  801ebe:	8b 75 10             	mov    0x10(%ebp),%esi
  801ec1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801ec4:	85 c0                	test   %eax,%eax
  801ec6:	89 55 f0             	mov    %edx,-0x10(%ebp)
  801ec9:	75 35                	jne    801f00 <__udivdi3+0x50>
  801ecb:	39 fe                	cmp    %edi,%esi
  801ecd:	77 61                	ja     801f30 <__udivdi3+0x80>
  801ecf:	85 f6                	test   %esi,%esi
  801ed1:	75 0b                	jne    801ede <__udivdi3+0x2e>
  801ed3:	b8 01 00 00 00       	mov    $0x1,%eax
  801ed8:	31 d2                	xor    %edx,%edx
  801eda:	f7 f6                	div    %esi
  801edc:	89 c6                	mov    %eax,%esi
  801ede:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  801ee1:	31 d2                	xor    %edx,%edx
  801ee3:	89 f8                	mov    %edi,%eax
  801ee5:	f7 f6                	div    %esi
  801ee7:	89 c7                	mov    %eax,%edi
  801ee9:	89 c8                	mov    %ecx,%eax
  801eeb:	f7 f6                	div    %esi
  801eed:	89 c1                	mov    %eax,%ecx
  801eef:	89 fa                	mov    %edi,%edx
  801ef1:	89 c8                	mov    %ecx,%eax
  801ef3:	83 c4 10             	add    $0x10,%esp
  801ef6:	5e                   	pop    %esi
  801ef7:	5f                   	pop    %edi
  801ef8:	5d                   	pop    %ebp
  801ef9:	c3                   	ret    
  801efa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801f00:	39 f8                	cmp    %edi,%eax
  801f02:	77 1c                	ja     801f20 <__udivdi3+0x70>
  801f04:	0f bd d0             	bsr    %eax,%edx
  801f07:	83 f2 1f             	xor    $0x1f,%edx
  801f0a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801f0d:	75 39                	jne    801f48 <__udivdi3+0x98>
  801f0f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  801f12:	0f 86 a0 00 00 00    	jbe    801fb8 <__udivdi3+0x108>
  801f18:	39 f8                	cmp    %edi,%eax
  801f1a:	0f 82 98 00 00 00    	jb     801fb8 <__udivdi3+0x108>
  801f20:	31 ff                	xor    %edi,%edi
  801f22:	31 c9                	xor    %ecx,%ecx
  801f24:	89 c8                	mov    %ecx,%eax
  801f26:	89 fa                	mov    %edi,%edx
  801f28:	83 c4 10             	add    $0x10,%esp
  801f2b:	5e                   	pop    %esi
  801f2c:	5f                   	pop    %edi
  801f2d:	5d                   	pop    %ebp
  801f2e:	c3                   	ret    
  801f2f:	90                   	nop
  801f30:	89 d1                	mov    %edx,%ecx
  801f32:	89 fa                	mov    %edi,%edx
  801f34:	89 c8                	mov    %ecx,%eax
  801f36:	31 ff                	xor    %edi,%edi
  801f38:	f7 f6                	div    %esi
  801f3a:	89 c1                	mov    %eax,%ecx
  801f3c:	89 fa                	mov    %edi,%edx
  801f3e:	89 c8                	mov    %ecx,%eax
  801f40:	83 c4 10             	add    $0x10,%esp
  801f43:	5e                   	pop    %esi
  801f44:	5f                   	pop    %edi
  801f45:	5d                   	pop    %ebp
  801f46:	c3                   	ret    
  801f47:	90                   	nop
  801f48:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801f4c:	89 f2                	mov    %esi,%edx
  801f4e:	d3 e0                	shl    %cl,%eax
  801f50:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801f53:	b8 20 00 00 00       	mov    $0x20,%eax
  801f58:	2b 45 f4             	sub    -0xc(%ebp),%eax
  801f5b:	89 c1                	mov    %eax,%ecx
  801f5d:	d3 ea                	shr    %cl,%edx
  801f5f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801f63:	0b 55 ec             	or     -0x14(%ebp),%edx
  801f66:	d3 e6                	shl    %cl,%esi
  801f68:	89 c1                	mov    %eax,%ecx
  801f6a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  801f6d:	89 fe                	mov    %edi,%esi
  801f6f:	d3 ee                	shr    %cl,%esi
  801f71:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801f75:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801f78:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801f7b:	d3 e7                	shl    %cl,%edi
  801f7d:	89 c1                	mov    %eax,%ecx
  801f7f:	d3 ea                	shr    %cl,%edx
  801f81:	09 d7                	or     %edx,%edi
  801f83:	89 f2                	mov    %esi,%edx
  801f85:	89 f8                	mov    %edi,%eax
  801f87:	f7 75 ec             	divl   -0x14(%ebp)
  801f8a:	89 d6                	mov    %edx,%esi
  801f8c:	89 c7                	mov    %eax,%edi
  801f8e:	f7 65 e8             	mull   -0x18(%ebp)
  801f91:	39 d6                	cmp    %edx,%esi
  801f93:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801f96:	72 30                	jb     801fc8 <__udivdi3+0x118>
  801f98:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801f9b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801f9f:	d3 e2                	shl    %cl,%edx
  801fa1:	39 c2                	cmp    %eax,%edx
  801fa3:	73 05                	jae    801faa <__udivdi3+0xfa>
  801fa5:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  801fa8:	74 1e                	je     801fc8 <__udivdi3+0x118>
  801faa:	89 f9                	mov    %edi,%ecx
  801fac:	31 ff                	xor    %edi,%edi
  801fae:	e9 71 ff ff ff       	jmp    801f24 <__udivdi3+0x74>
  801fb3:	90                   	nop
  801fb4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801fb8:	31 ff                	xor    %edi,%edi
  801fba:	b9 01 00 00 00       	mov    $0x1,%ecx
  801fbf:	e9 60 ff ff ff       	jmp    801f24 <__udivdi3+0x74>
  801fc4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801fc8:	8d 4f ff             	lea    -0x1(%edi),%ecx
  801fcb:	31 ff                	xor    %edi,%edi
  801fcd:	89 c8                	mov    %ecx,%eax
  801fcf:	89 fa                	mov    %edi,%edx
  801fd1:	83 c4 10             	add    $0x10,%esp
  801fd4:	5e                   	pop    %esi
  801fd5:	5f                   	pop    %edi
  801fd6:	5d                   	pop    %ebp
  801fd7:	c3                   	ret    
	...

00801fe0 <__umoddi3>:
  801fe0:	55                   	push   %ebp
  801fe1:	89 e5                	mov    %esp,%ebp
  801fe3:	57                   	push   %edi
  801fe4:	56                   	push   %esi
  801fe5:	83 ec 20             	sub    $0x20,%esp
  801fe8:	8b 55 14             	mov    0x14(%ebp),%edx
  801feb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801fee:	8b 7d 10             	mov    0x10(%ebp),%edi
  801ff1:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ff4:	85 d2                	test   %edx,%edx
  801ff6:	89 c8                	mov    %ecx,%eax
  801ff8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801ffb:	75 13                	jne    802010 <__umoddi3+0x30>
  801ffd:	39 f7                	cmp    %esi,%edi
  801fff:	76 3f                	jbe    802040 <__umoddi3+0x60>
  802001:	89 f2                	mov    %esi,%edx
  802003:	f7 f7                	div    %edi
  802005:	89 d0                	mov    %edx,%eax
  802007:	31 d2                	xor    %edx,%edx
  802009:	83 c4 20             	add    $0x20,%esp
  80200c:	5e                   	pop    %esi
  80200d:	5f                   	pop    %edi
  80200e:	5d                   	pop    %ebp
  80200f:	c3                   	ret    
  802010:	39 f2                	cmp    %esi,%edx
  802012:	77 4c                	ja     802060 <__umoddi3+0x80>
  802014:	0f bd ca             	bsr    %edx,%ecx
  802017:	83 f1 1f             	xor    $0x1f,%ecx
  80201a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80201d:	75 51                	jne    802070 <__umoddi3+0x90>
  80201f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  802022:	0f 87 e0 00 00 00    	ja     802108 <__umoddi3+0x128>
  802028:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80202b:	29 f8                	sub    %edi,%eax
  80202d:	19 d6                	sbb    %edx,%esi
  80202f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  802032:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802035:	89 f2                	mov    %esi,%edx
  802037:	83 c4 20             	add    $0x20,%esp
  80203a:	5e                   	pop    %esi
  80203b:	5f                   	pop    %edi
  80203c:	5d                   	pop    %ebp
  80203d:	c3                   	ret    
  80203e:	66 90                	xchg   %ax,%ax
  802040:	85 ff                	test   %edi,%edi
  802042:	75 0b                	jne    80204f <__umoddi3+0x6f>
  802044:	b8 01 00 00 00       	mov    $0x1,%eax
  802049:	31 d2                	xor    %edx,%edx
  80204b:	f7 f7                	div    %edi
  80204d:	89 c7                	mov    %eax,%edi
  80204f:	89 f0                	mov    %esi,%eax
  802051:	31 d2                	xor    %edx,%edx
  802053:	f7 f7                	div    %edi
  802055:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802058:	f7 f7                	div    %edi
  80205a:	eb a9                	jmp    802005 <__umoddi3+0x25>
  80205c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802060:	89 c8                	mov    %ecx,%eax
  802062:	89 f2                	mov    %esi,%edx
  802064:	83 c4 20             	add    $0x20,%esp
  802067:	5e                   	pop    %esi
  802068:	5f                   	pop    %edi
  802069:	5d                   	pop    %ebp
  80206a:	c3                   	ret    
  80206b:	90                   	nop
  80206c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802070:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802074:	d3 e2                	shl    %cl,%edx
  802076:	89 55 f4             	mov    %edx,-0xc(%ebp)
  802079:	ba 20 00 00 00       	mov    $0x20,%edx
  80207e:	2b 55 f0             	sub    -0x10(%ebp),%edx
  802081:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802084:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802088:	89 fa                	mov    %edi,%edx
  80208a:	d3 ea                	shr    %cl,%edx
  80208c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802090:	0b 55 f4             	or     -0xc(%ebp),%edx
  802093:	d3 e7                	shl    %cl,%edi
  802095:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802099:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80209c:	89 f2                	mov    %esi,%edx
  80209e:	89 7d e8             	mov    %edi,-0x18(%ebp)
  8020a1:	89 c7                	mov    %eax,%edi
  8020a3:	d3 ea                	shr    %cl,%edx
  8020a5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8020a9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8020ac:	89 c2                	mov    %eax,%edx
  8020ae:	d3 e6                	shl    %cl,%esi
  8020b0:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8020b4:	d3 ea                	shr    %cl,%edx
  8020b6:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8020ba:	09 d6                	or     %edx,%esi
  8020bc:	89 f0                	mov    %esi,%eax
  8020be:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8020c1:	d3 e7                	shl    %cl,%edi
  8020c3:	89 f2                	mov    %esi,%edx
  8020c5:	f7 75 f4             	divl   -0xc(%ebp)
  8020c8:	89 d6                	mov    %edx,%esi
  8020ca:	f7 65 e8             	mull   -0x18(%ebp)
  8020cd:	39 d6                	cmp    %edx,%esi
  8020cf:	72 2b                	jb     8020fc <__umoddi3+0x11c>
  8020d1:	39 c7                	cmp    %eax,%edi
  8020d3:	72 23                	jb     8020f8 <__umoddi3+0x118>
  8020d5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8020d9:	29 c7                	sub    %eax,%edi
  8020db:	19 d6                	sbb    %edx,%esi
  8020dd:	89 f0                	mov    %esi,%eax
  8020df:	89 f2                	mov    %esi,%edx
  8020e1:	d3 ef                	shr    %cl,%edi
  8020e3:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8020e7:	d3 e0                	shl    %cl,%eax
  8020e9:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8020ed:	09 f8                	or     %edi,%eax
  8020ef:	d3 ea                	shr    %cl,%edx
  8020f1:	83 c4 20             	add    $0x20,%esp
  8020f4:	5e                   	pop    %esi
  8020f5:	5f                   	pop    %edi
  8020f6:	5d                   	pop    %ebp
  8020f7:	c3                   	ret    
  8020f8:	39 d6                	cmp    %edx,%esi
  8020fa:	75 d9                	jne    8020d5 <__umoddi3+0xf5>
  8020fc:	2b 45 e8             	sub    -0x18(%ebp),%eax
  8020ff:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  802102:	eb d1                	jmp    8020d5 <__umoddi3+0xf5>
  802104:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802108:	39 f2                	cmp    %esi,%edx
  80210a:	0f 82 18 ff ff ff    	jb     802028 <__umoddi3+0x48>
  802110:	e9 1d ff ff ff       	jmp    802032 <__umoddi3+0x52>
