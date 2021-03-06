
obj/user/faultdie:     file format elf32-i386


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
  80002c:	e8 63 00 00 00       	call   800094 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800040 <umain>:
	sys_env_destroy(sys_getenvid());
}

void
umain(int argc, char **argv)
{
  800040:	55                   	push   %ebp
  800041:	89 e5                	mov    %esp,%ebp
  800043:	83 ec 18             	sub    $0x18,%esp
	set_pgfault_handler(handler);
  800046:	c7 04 24 5e 00 80 00 	movl   $0x80005e,(%esp)
  80004d:	e8 4e 13 00 00       	call   8013a0 <set_pgfault_handler>
	*(int*)0xDeadBeef = 0;
  800052:	c7 05 ef be ad de 00 	movl   $0x0,0xdeadbeef
  800059:	00 00 00 
}
  80005c:	c9                   	leave  
  80005d:	c3                   	ret    

0080005e <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  80005e:	55                   	push   %ebp
  80005f:	89 e5                	mov    %esp,%ebp
  800061:	83 ec 18             	sub    $0x18,%esp
  800064:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void*)utf->utf_fault_va;
	uint32_t err = utf->utf_err;
	cprintf("i faulted at va %x, err %x\n", addr, err & 7);
  800067:	8b 50 04             	mov    0x4(%eax),%edx
  80006a:	83 e2 07             	and    $0x7,%edx
  80006d:	89 54 24 08          	mov    %edx,0x8(%esp)
  800071:	8b 00                	mov    (%eax),%eax
  800073:	89 44 24 04          	mov    %eax,0x4(%esp)
  800077:	c7 04 24 00 17 80 00 	movl   $0x801700,(%esp)
  80007e:	e8 da 00 00 00       	call   80015d <cprintf>
	sys_env_destroy(sys_getenvid());
  800083:	e8 6d 12 00 00       	call   8012f5 <sys_getenvid>
  800088:	89 04 24             	mov    %eax,(%esp)
  80008b:	e8 a5 12 00 00       	call   801335 <sys_env_destroy>
}
  800090:	c9                   	leave  
  800091:	c3                   	ret    
	...

00800094 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800094:	55                   	push   %ebp
  800095:	89 e5                	mov    %esp,%ebp
  800097:	83 ec 18             	sub    $0x18,%esp
  80009a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80009d:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8000a0:	8b 75 08             	mov    0x8(%ebp),%esi
  8000a3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  8000a6:	e8 4a 12 00 00       	call   8012f5 <sys_getenvid>
  8000ab:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000b0:	89 c2                	mov    %eax,%edx
  8000b2:	c1 e2 07             	shl    $0x7,%edx
  8000b5:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  8000bc:	a3 04 20 80 00       	mov    %eax,0x802004
        //cprintf("ENVX sys_get_envid(): %d\n",ENVX(sys_getenvid()));
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000c1:	85 f6                	test   %esi,%esi
  8000c3:	7e 07                	jle    8000cc <libmain+0x38>
		binaryname = argv[0];
  8000c5:	8b 03                	mov    (%ebx),%eax
  8000c7:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000cc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000d0:	89 34 24             	mov    %esi,(%esp)
  8000d3:	e8 68 ff ff ff       	call   800040 <umain>

	// exit gracefully
	exit();
  8000d8:	e8 0b 00 00 00       	call   8000e8 <exit>
}
  8000dd:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8000e0:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8000e3:	89 ec                	mov    %ebp,%esp
  8000e5:	5d                   	pop    %ebp
  8000e6:	c3                   	ret    
	...

008000e8 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000e8:	55                   	push   %ebp
  8000e9:	89 e5                	mov    %esp,%ebp
  8000eb:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000ee:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000f5:	e8 3b 12 00 00       	call   801335 <sys_env_destroy>
}
  8000fa:	c9                   	leave  
  8000fb:	c3                   	ret    

008000fc <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  8000fc:	55                   	push   %ebp
  8000fd:	89 e5                	mov    %esp,%ebp
  8000ff:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800105:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80010c:	00 00 00 
	b.cnt = 0;
  80010f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800116:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800119:	8b 45 0c             	mov    0xc(%ebp),%eax
  80011c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800120:	8b 45 08             	mov    0x8(%ebp),%eax
  800123:	89 44 24 08          	mov    %eax,0x8(%esp)
  800127:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80012d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800131:	c7 04 24 77 01 80 00 	movl   $0x800177,(%esp)
  800138:	e8 cf 01 00 00       	call   80030c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80013d:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800143:	89 44 24 04          	mov    %eax,0x4(%esp)
  800147:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80014d:	89 04 24             	mov    %eax,(%esp)
  800150:	e8 67 0d 00 00       	call   800ebc <sys_cputs>

	return b.cnt;
}
  800155:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80015b:	c9                   	leave  
  80015c:	c3                   	ret    

0080015d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80015d:	55                   	push   %ebp
  80015e:	89 e5                	mov    %esp,%ebp
  800160:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  800163:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  800166:	89 44 24 04          	mov    %eax,0x4(%esp)
  80016a:	8b 45 08             	mov    0x8(%ebp),%eax
  80016d:	89 04 24             	mov    %eax,(%esp)
  800170:	e8 87 ff ff ff       	call   8000fc <vcprintf>
	va_end(ap);

	return cnt;
}
  800175:	c9                   	leave  
  800176:	c3                   	ret    

00800177 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800177:	55                   	push   %ebp
  800178:	89 e5                	mov    %esp,%ebp
  80017a:	53                   	push   %ebx
  80017b:	83 ec 14             	sub    $0x14,%esp
  80017e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800181:	8b 03                	mov    (%ebx),%eax
  800183:	8b 55 08             	mov    0x8(%ebp),%edx
  800186:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80018a:	83 c0 01             	add    $0x1,%eax
  80018d:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80018f:	3d ff 00 00 00       	cmp    $0xff,%eax
  800194:	75 19                	jne    8001af <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800196:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80019d:	00 
  80019e:	8d 43 08             	lea    0x8(%ebx),%eax
  8001a1:	89 04 24             	mov    %eax,(%esp)
  8001a4:	e8 13 0d 00 00       	call   800ebc <sys_cputs>
		b->idx = 0;
  8001a9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001af:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001b3:	83 c4 14             	add    $0x14,%esp
  8001b6:	5b                   	pop    %ebx
  8001b7:	5d                   	pop    %ebp
  8001b8:	c3                   	ret    
  8001b9:	00 00                	add    %al,(%eax)
  8001bb:	00 00                	add    %al,(%eax)
  8001bd:	00 00                	add    %al,(%eax)
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
  80022f:	e8 5c 12 00 00       	call   801490 <__udivdi3>
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
  800297:	e8 24 13 00 00       	call   8015c0 <__umoddi3>
  80029c:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002a0:	0f be 80 26 17 80 00 	movsbl 0x801726(%eax),%eax
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
  80038a:	ff 24 95 60 18 80 00 	jmp    *0x801860(,%edx,4)
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
  800442:	83 f8 08             	cmp    $0x8,%eax
  800445:	7f 0b                	jg     800452 <vprintfmt+0x146>
  800447:	8b 14 85 c0 19 80 00 	mov    0x8019c0(,%eax,4),%edx
  80044e:	85 d2                	test   %edx,%edx
  800450:	75 26                	jne    800478 <vprintfmt+0x16c>
				printfmt(putch, putdat, "error %d", err);
  800452:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800456:	c7 44 24 08 37 17 80 	movl   $0x801737,0x8(%esp)
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
  80047c:	c7 44 24 08 40 17 80 	movl   $0x801740,0x8(%esp)
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
  8004ba:	be 43 17 80 00       	mov    $0x801743,%esi
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
  800764:	e8 27 0d 00 00       	call   801490 <__udivdi3>
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
  8007b0:	e8 0b 0e 00 00       	call   8015c0 <__umoddi3>
  8007b5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007b9:	0f be 80 26 17 80 00 	movsbl 0x801726(%eax),%eax
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
  800865:	c7 44 24 0c e0 17 80 	movl   $0x8017e0,0xc(%esp)
  80086c:	00 
  80086d:	c7 44 24 08 40 17 80 	movl   $0x801740,0x8(%esp)
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
  80089b:	c7 44 24 0c 18 18 80 	movl   $0x801818,0xc(%esp)
  8008a2:	00 
  8008a3:	c7 44 24 08 40 17 80 	movl   $0x801740,0x8(%esp)
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
  80092f:	e8 8c 0c 00 00       	call   8015c0 <__umoddi3>
  800934:	89 74 24 04          	mov    %esi,0x4(%esp)
  800938:	0f be 80 26 17 80 00 	movsbl 0x801726(%eax),%eax
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
  800971:	e8 4a 0c 00 00       	call   8015c0 <__umoddi3>
  800976:	89 74 24 04          	mov    %esi,0x4(%esp)
  80097a:	0f be 80 26 17 80 00 	movsbl 0x801726(%eax),%eax
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

00800efb <sys_env_set_prior>:
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}

int 
sys_env_set_prior(envid_t envid, uint32_t prior){
  800efb:	55                   	push   %ebp
  800efc:	89 e5                	mov    %esp,%ebp
  800efe:	83 ec 28             	sub    $0x28,%esp
  800f01:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800f04:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800f07:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f0c:	b8 0e 00 00 00       	mov    $0xe,%eax
  800f11:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f14:	8b 55 08             	mov    0x8(%ebp),%edx
  800f17:	89 df                	mov    %ebx,%edi
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
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  800f31:	85 c0                	test   %eax,%eax
  800f33:	7e 28                	jle    800f5d <sys_env_set_prior+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f35:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f39:	c7 44 24 0c 0e 00 00 	movl   $0xe,0xc(%esp)
  800f40:	00 
  800f41:	c7 44 24 08 e4 19 80 	movl   $0x8019e4,0x8(%esp)
  800f48:	00 
  800f49:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  800f50:	00 
  800f51:	c7 04 24 01 1a 80 00 	movl   $0x801a01,(%esp)
  800f58:	e8 b7 04 00 00       	call   801414 <_panic>
}

int 
sys_env_set_prior(envid_t envid, uint32_t prior){
         return syscall(SYS_env_set_prior,1,envid, prior, 0, 0, 0);
}
  800f5d:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800f60:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f63:	89 ec                	mov    %ebp,%esp
  800f65:	5d                   	pop    %ebp
  800f66:	c3                   	ret    

00800f67 <sys_sbrk>:
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}

int
sys_sbrk(uint32_t inc)
{
  800f67:	55                   	push   %ebp
  800f68:	89 e5                	mov    %esp,%ebp
  800f6a:	83 ec 08             	sub    $0x8,%esp
  800f6d:	89 1c 24             	mov    %ebx,(%esp)
  800f70:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800f74:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f79:	b8 0f 00 00 00       	mov    $0xf,%eax
  800f7e:	8b 55 08             	mov    0x8(%ebp),%edx
  800f81:	89 cb                	mov    %ecx,%ebx
  800f83:	89 cf                	mov    %ecx,%edi
  800f85:	51                   	push   %ecx
  800f86:	52                   	push   %edx
  800f87:	53                   	push   %ebx
  800f88:	54                   	push   %esp
  800f89:	55                   	push   %ebp
  800f8a:	56                   	push   %esi
  800f8b:	57                   	push   %edi
  800f8c:	54                   	push   %esp
  800f8d:	5d                   	pop    %ebp
  800f8e:	8d 35 96 0f 80 00    	lea    0x800f96,%esi
  800f94:	0f 34                	sysenter 
  800f96:	5f                   	pop    %edi
  800f97:	5e                   	pop    %esi
  800f98:	5d                   	pop    %ebp
  800f99:	5c                   	pop    %esp
  800f9a:	5b                   	pop    %ebx
  800f9b:	5a                   	pop    %edx
  800f9c:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  800f9d:	8b 1c 24             	mov    (%esp),%ebx
  800fa0:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800fa4:	89 ec                	mov    %ebp,%esp
  800fa6:	5d                   	pop    %ebp
  800fa7:	c3                   	ret    

00800fa8 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800fa8:	55                   	push   %ebp
  800fa9:	89 e5                	mov    %esp,%ebp
  800fab:	83 ec 28             	sub    $0x28,%esp
  800fae:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800fb1:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800fb4:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fb9:	b8 0d 00 00 00       	mov    $0xd,%eax
  800fbe:	8b 55 08             	mov    0x8(%ebp),%edx
  800fc1:	89 cb                	mov    %ecx,%ebx
  800fc3:	89 cf                	mov    %ecx,%edi
  800fc5:	51                   	push   %ecx
  800fc6:	52                   	push   %edx
  800fc7:	53                   	push   %ebx
  800fc8:	54                   	push   %esp
  800fc9:	55                   	push   %ebp
  800fca:	56                   	push   %esi
  800fcb:	57                   	push   %edi
  800fcc:	54                   	push   %esp
  800fcd:	5d                   	pop    %ebp
  800fce:	8d 35 d6 0f 80 00    	lea    0x800fd6,%esi
  800fd4:	0f 34                	sysenter 
  800fd6:	5f                   	pop    %edi
  800fd7:	5e                   	pop    %esi
  800fd8:	5d                   	pop    %ebp
  800fd9:	5c                   	pop    %esp
  800fda:	5b                   	pop    %ebx
  800fdb:	5a                   	pop    %edx
  800fdc:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  800fdd:	85 c0                	test   %eax,%eax
  800fdf:	7e 28                	jle    801009 <sys_ipc_recv+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fe1:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fe5:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800fec:	00 
  800fed:	c7 44 24 08 e4 19 80 	movl   $0x8019e4,0x8(%esp)
  800ff4:	00 
  800ff5:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  800ffc:	00 
  800ffd:	c7 04 24 01 1a 80 00 	movl   $0x801a01,(%esp)
  801004:	e8 0b 04 00 00       	call   801414 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801009:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80100c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80100f:	89 ec                	mov    %ebp,%esp
  801011:	5d                   	pop    %ebp
  801012:	c3                   	ret    

00801013 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801013:	55                   	push   %ebp
  801014:	89 e5                	mov    %esp,%ebp
  801016:	83 ec 08             	sub    $0x8,%esp
  801019:	89 1c 24             	mov    %ebx,(%esp)
  80101c:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801020:	b8 0c 00 00 00       	mov    $0xc,%eax
  801025:	8b 7d 14             	mov    0x14(%ebp),%edi
  801028:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80102b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80102e:	8b 55 08             	mov    0x8(%ebp),%edx
  801031:	51                   	push   %ecx
  801032:	52                   	push   %edx
  801033:	53                   	push   %ebx
  801034:	54                   	push   %esp
  801035:	55                   	push   %ebp
  801036:	56                   	push   %esi
  801037:	57                   	push   %edi
  801038:	54                   	push   %esp
  801039:	5d                   	pop    %ebp
  80103a:	8d 35 42 10 80 00    	lea    0x801042,%esi
  801040:	0f 34                	sysenter 
  801042:	5f                   	pop    %edi
  801043:	5e                   	pop    %esi
  801044:	5d                   	pop    %ebp
  801045:	5c                   	pop    %esp
  801046:	5b                   	pop    %ebx
  801047:	5a                   	pop    %edx
  801048:	59                   	pop    %ecx

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801049:	8b 1c 24             	mov    (%esp),%ebx
  80104c:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801050:	89 ec                	mov    %ebp,%esp
  801052:	5d                   	pop    %ebp
  801053:	c3                   	ret    

00801054 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801054:	55                   	push   %ebp
  801055:	89 e5                	mov    %esp,%ebp
  801057:	83 ec 28             	sub    $0x28,%esp
  80105a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80105d:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801060:	bb 00 00 00 00       	mov    $0x0,%ebx
  801065:	b8 0a 00 00 00       	mov    $0xa,%eax
  80106a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80106d:	8b 55 08             	mov    0x8(%ebp),%edx
  801070:	89 df                	mov    %ebx,%edi
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
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80108a:	85 c0                	test   %eax,%eax
  80108c:	7e 28                	jle    8010b6 <sys_env_set_pgfault_upcall+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  80108e:	89 44 24 10          	mov    %eax,0x10(%esp)
  801092:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  801099:	00 
  80109a:	c7 44 24 08 e4 19 80 	movl   $0x8019e4,0x8(%esp)
  8010a1:	00 
  8010a2:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8010a9:	00 
  8010aa:	c7 04 24 01 1a 80 00 	movl   $0x801a01,(%esp)
  8010b1:	e8 5e 03 00 00       	call   801414 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8010b6:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8010b9:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8010bc:	89 ec                	mov    %ebp,%esp
  8010be:	5d                   	pop    %ebp
  8010bf:	c3                   	ret    

008010c0 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8010c0:	55                   	push   %ebp
  8010c1:	89 e5                	mov    %esp,%ebp
  8010c3:	83 ec 28             	sub    $0x28,%esp
  8010c6:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8010c9:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8010cc:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010d1:	b8 09 00 00 00       	mov    $0x9,%eax
  8010d6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010d9:	8b 55 08             	mov    0x8(%ebp),%edx
  8010dc:	89 df                	mov    %ebx,%edi
  8010de:	51                   	push   %ecx
  8010df:	52                   	push   %edx
  8010e0:	53                   	push   %ebx
  8010e1:	54                   	push   %esp
  8010e2:	55                   	push   %ebp
  8010e3:	56                   	push   %esi
  8010e4:	57                   	push   %edi
  8010e5:	54                   	push   %esp
  8010e6:	5d                   	pop    %ebp
  8010e7:	8d 35 ef 10 80 00    	lea    0x8010ef,%esi
  8010ed:	0f 34                	sysenter 
  8010ef:	5f                   	pop    %edi
  8010f0:	5e                   	pop    %esi
  8010f1:	5d                   	pop    %ebp
  8010f2:	5c                   	pop    %esp
  8010f3:	5b                   	pop    %ebx
  8010f4:	5a                   	pop    %edx
  8010f5:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8010f6:	85 c0                	test   %eax,%eax
  8010f8:	7e 28                	jle    801122 <sys_env_set_status+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010fa:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010fe:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  801105:	00 
  801106:	c7 44 24 08 e4 19 80 	movl   $0x8019e4,0x8(%esp)
  80110d:	00 
  80110e:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801115:	00 
  801116:	c7 04 24 01 1a 80 00 	movl   $0x801a01,(%esp)
  80111d:	e8 f2 02 00 00       	call   801414 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801122:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801125:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801128:	89 ec                	mov    %ebp,%esp
  80112a:	5d                   	pop    %ebp
  80112b:	c3                   	ret    

0080112c <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  80112c:	55                   	push   %ebp
  80112d:	89 e5                	mov    %esp,%ebp
  80112f:	83 ec 28             	sub    $0x28,%esp
  801132:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801135:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801138:	bb 00 00 00 00       	mov    $0x0,%ebx
  80113d:	b8 07 00 00 00       	mov    $0x7,%eax
  801142:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801145:	8b 55 08             	mov    0x8(%ebp),%edx
  801148:	89 df                	mov    %ebx,%edi
  80114a:	51                   	push   %ecx
  80114b:	52                   	push   %edx
  80114c:	53                   	push   %ebx
  80114d:	54                   	push   %esp
  80114e:	55                   	push   %ebp
  80114f:	56                   	push   %esi
  801150:	57                   	push   %edi
  801151:	54                   	push   %esp
  801152:	5d                   	pop    %ebp
  801153:	8d 35 5b 11 80 00    	lea    0x80115b,%esi
  801159:	0f 34                	sysenter 
  80115b:	5f                   	pop    %edi
  80115c:	5e                   	pop    %esi
  80115d:	5d                   	pop    %ebp
  80115e:	5c                   	pop    %esp
  80115f:	5b                   	pop    %ebx
  801160:	5a                   	pop    %edx
  801161:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801162:	85 c0                	test   %eax,%eax
  801164:	7e 28                	jle    80118e <sys_page_unmap+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  801166:	89 44 24 10          	mov    %eax,0x10(%esp)
  80116a:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801171:	00 
  801172:	c7 44 24 08 e4 19 80 	movl   $0x8019e4,0x8(%esp)
  801179:	00 
  80117a:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801181:	00 
  801182:	c7 04 24 01 1a 80 00 	movl   $0x801a01,(%esp)
  801189:	e8 86 02 00 00       	call   801414 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80118e:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801191:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801194:	89 ec                	mov    %ebp,%esp
  801196:	5d                   	pop    %ebp
  801197:	c3                   	ret    

00801198 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  801198:	55                   	push   %ebp
  801199:	89 e5                	mov    %esp,%ebp
  80119b:	83 ec 28             	sub    $0x28,%esp
  80119e:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8011a1:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8011a4:	8b 7d 18             	mov    0x18(%ebp),%edi
  8011a7:	0b 7d 14             	or     0x14(%ebp),%edi
  8011aa:	b8 06 00 00 00       	mov    $0x6,%eax
  8011af:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8011b2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011b5:	8b 55 08             	mov    0x8(%ebp),%edx
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
  8011d2:	7e 28                	jle    8011fc <sys_page_map+0x64>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011d4:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011d8:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  8011df:	00 
  8011e0:	c7 44 24 08 e4 19 80 	movl   $0x8019e4,0x8(%esp)
  8011e7:	00 
  8011e8:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8011ef:	00 
  8011f0:	c7 04 24 01 1a 80 00 	movl   $0x801a01,(%esp)
  8011f7:	e8 18 02 00 00       	call   801414 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}
  8011fc:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8011ff:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801202:	89 ec                	mov    %ebp,%esp
  801204:	5d                   	pop    %ebp
  801205:	c3                   	ret    

00801206 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
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
  801212:	bf 00 00 00 00       	mov    $0x0,%edi
  801217:	b8 05 00 00 00       	mov    $0x5,%eax
  80121c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80121f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801222:	8b 55 08             	mov    0x8(%ebp),%edx
  801225:	51                   	push   %ecx
  801226:	52                   	push   %edx
  801227:	53                   	push   %ebx
  801228:	54                   	push   %esp
  801229:	55                   	push   %ebp
  80122a:	56                   	push   %esi
  80122b:	57                   	push   %edi
  80122c:	54                   	push   %esp
  80122d:	5d                   	pop    %ebp
  80122e:	8d 35 36 12 80 00    	lea    0x801236,%esi
  801234:	0f 34                	sysenter 
  801236:	5f                   	pop    %edi
  801237:	5e                   	pop    %esi
  801238:	5d                   	pop    %ebp
  801239:	5c                   	pop    %esp
  80123a:	5b                   	pop    %ebx
  80123b:	5a                   	pop    %edx
  80123c:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80123d:	85 c0                	test   %eax,%eax
  80123f:	7e 28                	jle    801269 <sys_page_alloc+0x63>
		panic("syscall %d returned %d (> 0)", num, ret);
  801241:	89 44 24 10          	mov    %eax,0x10(%esp)
  801245:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  80124c:	00 
  80124d:	c7 44 24 08 e4 19 80 	movl   $0x8019e4,0x8(%esp)
  801254:	00 
  801255:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80125c:	00 
  80125d:	c7 04 24 01 1a 80 00 	movl   $0x801a01,(%esp)
  801264:	e8 ab 01 00 00       	call   801414 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  801269:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80126c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80126f:	89 ec                	mov    %ebp,%esp
  801271:	5d                   	pop    %ebp
  801272:	c3                   	ret    

00801273 <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
{
  801273:	55                   	push   %ebp
  801274:	89 e5                	mov    %esp,%ebp
  801276:	83 ec 08             	sub    $0x8,%esp
  801279:	89 1c 24             	mov    %ebx,(%esp)
  80127c:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801280:	ba 00 00 00 00       	mov    $0x0,%edx
  801285:	b8 0b 00 00 00       	mov    $0xb,%eax
  80128a:	89 d1                	mov    %edx,%ecx
  80128c:	89 d3                	mov    %edx,%ebx
  80128e:	89 d7                	mov    %edx,%edi
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

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8012a8:	8b 1c 24             	mov    (%esp),%ebx
  8012ab:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8012af:	89 ec                	mov    %ebp,%esp
  8012b1:	5d                   	pop    %ebp
  8012b2:	c3                   	ret    

008012b3 <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
{
  8012b3:	55                   	push   %ebp
  8012b4:	89 e5                	mov    %esp,%ebp
  8012b6:	83 ec 08             	sub    $0x8,%esp
  8012b9:	89 1c 24             	mov    %ebx,(%esp)
  8012bc:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8012c0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012c5:	b8 04 00 00 00       	mov    $0x4,%eax
  8012ca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012cd:	8b 55 08             	mov    0x8(%ebp),%edx
  8012d0:	89 df                	mov    %ebx,%edi
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

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  8012ea:	8b 1c 24             	mov    (%esp),%ebx
  8012ed:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8012f1:	89 ec                	mov    %ebp,%esp
  8012f3:	5d                   	pop    %ebp
  8012f4:	c3                   	ret    

008012f5 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  8012f5:	55                   	push   %ebp
  8012f6:	89 e5                	mov    %esp,%ebp
  8012f8:	83 ec 08             	sub    $0x8,%esp
  8012fb:	89 1c 24             	mov    %ebx,(%esp)
  8012fe:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801302:	ba 00 00 00 00       	mov    $0x0,%edx
  801307:	b8 02 00 00 00       	mov    $0x2,%eax
  80130c:	89 d1                	mov    %edx,%ecx
  80130e:	89 d3                	mov    %edx,%ebx
  801310:	89 d7                	mov    %edx,%edi
  801312:	51                   	push   %ecx
  801313:	52                   	push   %edx
  801314:	53                   	push   %ebx
  801315:	54                   	push   %esp
  801316:	55                   	push   %ebp
  801317:	56                   	push   %esi
  801318:	57                   	push   %edi
  801319:	54                   	push   %esp
  80131a:	5d                   	pop    %ebp
  80131b:	8d 35 23 13 80 00    	lea    0x801323,%esi
  801321:	0f 34                	sysenter 
  801323:	5f                   	pop    %edi
  801324:	5e                   	pop    %esi
  801325:	5d                   	pop    %ebp
  801326:	5c                   	pop    %esp
  801327:	5b                   	pop    %ebx
  801328:	5a                   	pop    %edx
  801329:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80132a:	8b 1c 24             	mov    (%esp),%ebx
  80132d:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801331:	89 ec                	mov    %ebp,%esp
  801333:	5d                   	pop    %ebp
  801334:	c3                   	ret    

00801335 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  801335:	55                   	push   %ebp
  801336:	89 e5                	mov    %esp,%ebp
  801338:	83 ec 28             	sub    $0x28,%esp
  80133b:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80133e:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801341:	b9 00 00 00 00       	mov    $0x0,%ecx
  801346:	b8 03 00 00 00       	mov    $0x3,%eax
  80134b:	8b 55 08             	mov    0x8(%ebp),%edx
  80134e:	89 cb                	mov    %ecx,%ebx
  801350:	89 cf                	mov    %ecx,%edi
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
  80136c:	7e 28                	jle    801396 <sys_env_destroy+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  80136e:	89 44 24 10          	mov    %eax,0x10(%esp)
  801372:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  801379:	00 
  80137a:	c7 44 24 08 e4 19 80 	movl   $0x8019e4,0x8(%esp)
  801381:	00 
  801382:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801389:	00 
  80138a:	c7 04 24 01 1a 80 00 	movl   $0x801a01,(%esp)
  801391:	e8 7e 00 00 00       	call   801414 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801396:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801399:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80139c:	89 ec                	mov    %ebp,%esp
  80139e:	5d                   	pop    %ebp
  80139f:	c3                   	ret    

008013a0 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8013a0:	55                   	push   %ebp
  8013a1:	89 e5                	mov    %esp,%ebp
  8013a3:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  8013a6:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  8013ad:	75 30                	jne    8013df <set_pgfault_handler+0x3f>
		// First time through!
		// LAB 4: Your code here.
                uint32_t ret = sys_page_alloc(0,(void*)(UXSTACKTOP-PGSIZE),PTE_P|PTE_U|PTE_W);
  8013af:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8013b6:	00 
  8013b7:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8013be:	ee 
  8013bf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8013c6:	e8 3b fe ff ff       	call   801206 <sys_page_alloc>
                if(ret < 0)
                  return;
                sys_env_set_pgfault_upcall(0,_pgfault_upcall);
  8013cb:	c7 44 24 04 ec 13 80 	movl   $0x8013ec,0x4(%esp)
  8013d2:	00 
  8013d3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8013da:	e8 75 fc ff ff       	call   801054 <sys_env_set_pgfault_upcall>
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8013df:	8b 45 08             	mov    0x8(%ebp),%eax
  8013e2:	a3 08 20 80 00       	mov    %eax,0x802008
}
  8013e7:	c9                   	leave  
  8013e8:	c3                   	ret    
  8013e9:	00 00                	add    %al,(%eax)
	...

008013ec <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8013ec:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8013ed:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  8013f2:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8013f4:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
        movl 0x28(%esp),%eax
  8013f7:	8b 44 24 28          	mov    0x28(%esp),%eax
        movl 0x30(%esp),%ecx
  8013fb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
        subl $0x4,%ecx
  8013ff:	83 e9 04             	sub    $0x4,%ecx
        movl %eax,(%ecx)
  801402:	89 01                	mov    %eax,(%ecx)
        movl %ecx,0x30(%esp)
  801404:	89 4c 24 30          	mov    %ecx,0x30(%esp)
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
        addl $0x8,%esp
  801408:	83 c4 08             	add    $0x8,%esp
        popal
  80140b:	61                   	popa   
        addl $0x4,%esp
  80140c:	83 c4 04             	add    $0x4,%esp
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
        popfl
  80140f:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
        popl %esp
  801410:	5c                   	pop    %esp
        //subl $0x4,%esp   //CAN'T SUB HERE BECAUSE OF EFLAGS
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
        ret
  801411:	c3                   	ret    
	...

00801414 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801414:	55                   	push   %ebp
  801415:	89 e5                	mov    %esp,%ebp
  801417:	56                   	push   %esi
  801418:	53                   	push   %ebx
  801419:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  80141c:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	if (argv0)
  80141f:	a1 0c 20 80 00       	mov    0x80200c,%eax
  801424:	85 c0                	test   %eax,%eax
  801426:	74 10                	je     801438 <_panic+0x24>
		cprintf("%s: ", argv0);
  801428:	89 44 24 04          	mov    %eax,0x4(%esp)
  80142c:	c7 04 24 0f 1a 80 00 	movl   $0x801a0f,(%esp)
  801433:	e8 25 ed ff ff       	call   80015d <cprintf>
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801438:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  80143e:	e8 b2 fe ff ff       	call   8012f5 <sys_getenvid>
  801443:	8b 55 0c             	mov    0xc(%ebp),%edx
  801446:	89 54 24 10          	mov    %edx,0x10(%esp)
  80144a:	8b 55 08             	mov    0x8(%ebp),%edx
  80144d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801451:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801455:	89 44 24 04          	mov    %eax,0x4(%esp)
  801459:	c7 04 24 14 1a 80 00 	movl   $0x801a14,(%esp)
  801460:	e8 f8 ec ff ff       	call   80015d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801465:	89 74 24 04          	mov    %esi,0x4(%esp)
  801469:	8b 45 10             	mov    0x10(%ebp),%eax
  80146c:	89 04 24             	mov    %eax,(%esp)
  80146f:	e8 88 ec ff ff       	call   8000fc <vcprintf>
	cprintf("\n");
  801474:	c7 04 24 1a 17 80 00 	movl   $0x80171a,(%esp)
  80147b:	e8 dd ec ff ff       	call   80015d <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801480:	cc                   	int3   
  801481:	eb fd                	jmp    801480 <_panic+0x6c>
	...

00801490 <__udivdi3>:
  801490:	55                   	push   %ebp
  801491:	89 e5                	mov    %esp,%ebp
  801493:	57                   	push   %edi
  801494:	56                   	push   %esi
  801495:	83 ec 10             	sub    $0x10,%esp
  801498:	8b 45 14             	mov    0x14(%ebp),%eax
  80149b:	8b 55 08             	mov    0x8(%ebp),%edx
  80149e:	8b 75 10             	mov    0x10(%ebp),%esi
  8014a1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8014a4:	85 c0                	test   %eax,%eax
  8014a6:	89 55 f0             	mov    %edx,-0x10(%ebp)
  8014a9:	75 35                	jne    8014e0 <__udivdi3+0x50>
  8014ab:	39 fe                	cmp    %edi,%esi
  8014ad:	77 61                	ja     801510 <__udivdi3+0x80>
  8014af:	85 f6                	test   %esi,%esi
  8014b1:	75 0b                	jne    8014be <__udivdi3+0x2e>
  8014b3:	b8 01 00 00 00       	mov    $0x1,%eax
  8014b8:	31 d2                	xor    %edx,%edx
  8014ba:	f7 f6                	div    %esi
  8014bc:	89 c6                	mov    %eax,%esi
  8014be:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  8014c1:	31 d2                	xor    %edx,%edx
  8014c3:	89 f8                	mov    %edi,%eax
  8014c5:	f7 f6                	div    %esi
  8014c7:	89 c7                	mov    %eax,%edi
  8014c9:	89 c8                	mov    %ecx,%eax
  8014cb:	f7 f6                	div    %esi
  8014cd:	89 c1                	mov    %eax,%ecx
  8014cf:	89 fa                	mov    %edi,%edx
  8014d1:	89 c8                	mov    %ecx,%eax
  8014d3:	83 c4 10             	add    $0x10,%esp
  8014d6:	5e                   	pop    %esi
  8014d7:	5f                   	pop    %edi
  8014d8:	5d                   	pop    %ebp
  8014d9:	c3                   	ret    
  8014da:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8014e0:	39 f8                	cmp    %edi,%eax
  8014e2:	77 1c                	ja     801500 <__udivdi3+0x70>
  8014e4:	0f bd d0             	bsr    %eax,%edx
  8014e7:	83 f2 1f             	xor    $0x1f,%edx
  8014ea:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8014ed:	75 39                	jne    801528 <__udivdi3+0x98>
  8014ef:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  8014f2:	0f 86 a0 00 00 00    	jbe    801598 <__udivdi3+0x108>
  8014f8:	39 f8                	cmp    %edi,%eax
  8014fa:	0f 82 98 00 00 00    	jb     801598 <__udivdi3+0x108>
  801500:	31 ff                	xor    %edi,%edi
  801502:	31 c9                	xor    %ecx,%ecx
  801504:	89 c8                	mov    %ecx,%eax
  801506:	89 fa                	mov    %edi,%edx
  801508:	83 c4 10             	add    $0x10,%esp
  80150b:	5e                   	pop    %esi
  80150c:	5f                   	pop    %edi
  80150d:	5d                   	pop    %ebp
  80150e:	c3                   	ret    
  80150f:	90                   	nop
  801510:	89 d1                	mov    %edx,%ecx
  801512:	89 fa                	mov    %edi,%edx
  801514:	89 c8                	mov    %ecx,%eax
  801516:	31 ff                	xor    %edi,%edi
  801518:	f7 f6                	div    %esi
  80151a:	89 c1                	mov    %eax,%ecx
  80151c:	89 fa                	mov    %edi,%edx
  80151e:	89 c8                	mov    %ecx,%eax
  801520:	83 c4 10             	add    $0x10,%esp
  801523:	5e                   	pop    %esi
  801524:	5f                   	pop    %edi
  801525:	5d                   	pop    %ebp
  801526:	c3                   	ret    
  801527:	90                   	nop
  801528:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80152c:	89 f2                	mov    %esi,%edx
  80152e:	d3 e0                	shl    %cl,%eax
  801530:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801533:	b8 20 00 00 00       	mov    $0x20,%eax
  801538:	2b 45 f4             	sub    -0xc(%ebp),%eax
  80153b:	89 c1                	mov    %eax,%ecx
  80153d:	d3 ea                	shr    %cl,%edx
  80153f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801543:	0b 55 ec             	or     -0x14(%ebp),%edx
  801546:	d3 e6                	shl    %cl,%esi
  801548:	89 c1                	mov    %eax,%ecx
  80154a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  80154d:	89 fe                	mov    %edi,%esi
  80154f:	d3 ee                	shr    %cl,%esi
  801551:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801555:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801558:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80155b:	d3 e7                	shl    %cl,%edi
  80155d:	89 c1                	mov    %eax,%ecx
  80155f:	d3 ea                	shr    %cl,%edx
  801561:	09 d7                	or     %edx,%edi
  801563:	89 f2                	mov    %esi,%edx
  801565:	89 f8                	mov    %edi,%eax
  801567:	f7 75 ec             	divl   -0x14(%ebp)
  80156a:	89 d6                	mov    %edx,%esi
  80156c:	89 c7                	mov    %eax,%edi
  80156e:	f7 65 e8             	mull   -0x18(%ebp)
  801571:	39 d6                	cmp    %edx,%esi
  801573:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801576:	72 30                	jb     8015a8 <__udivdi3+0x118>
  801578:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80157b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80157f:	d3 e2                	shl    %cl,%edx
  801581:	39 c2                	cmp    %eax,%edx
  801583:	73 05                	jae    80158a <__udivdi3+0xfa>
  801585:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  801588:	74 1e                	je     8015a8 <__udivdi3+0x118>
  80158a:	89 f9                	mov    %edi,%ecx
  80158c:	31 ff                	xor    %edi,%edi
  80158e:	e9 71 ff ff ff       	jmp    801504 <__udivdi3+0x74>
  801593:	90                   	nop
  801594:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801598:	31 ff                	xor    %edi,%edi
  80159a:	b9 01 00 00 00       	mov    $0x1,%ecx
  80159f:	e9 60 ff ff ff       	jmp    801504 <__udivdi3+0x74>
  8015a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8015a8:	8d 4f ff             	lea    -0x1(%edi),%ecx
  8015ab:	31 ff                	xor    %edi,%edi
  8015ad:	89 c8                	mov    %ecx,%eax
  8015af:	89 fa                	mov    %edi,%edx
  8015b1:	83 c4 10             	add    $0x10,%esp
  8015b4:	5e                   	pop    %esi
  8015b5:	5f                   	pop    %edi
  8015b6:	5d                   	pop    %ebp
  8015b7:	c3                   	ret    
	...

008015c0 <__umoddi3>:
  8015c0:	55                   	push   %ebp
  8015c1:	89 e5                	mov    %esp,%ebp
  8015c3:	57                   	push   %edi
  8015c4:	56                   	push   %esi
  8015c5:	83 ec 20             	sub    $0x20,%esp
  8015c8:	8b 55 14             	mov    0x14(%ebp),%edx
  8015cb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8015ce:	8b 7d 10             	mov    0x10(%ebp),%edi
  8015d1:	8b 75 0c             	mov    0xc(%ebp),%esi
  8015d4:	85 d2                	test   %edx,%edx
  8015d6:	89 c8                	mov    %ecx,%eax
  8015d8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  8015db:	75 13                	jne    8015f0 <__umoddi3+0x30>
  8015dd:	39 f7                	cmp    %esi,%edi
  8015df:	76 3f                	jbe    801620 <__umoddi3+0x60>
  8015e1:	89 f2                	mov    %esi,%edx
  8015e3:	f7 f7                	div    %edi
  8015e5:	89 d0                	mov    %edx,%eax
  8015e7:	31 d2                	xor    %edx,%edx
  8015e9:	83 c4 20             	add    $0x20,%esp
  8015ec:	5e                   	pop    %esi
  8015ed:	5f                   	pop    %edi
  8015ee:	5d                   	pop    %ebp
  8015ef:	c3                   	ret    
  8015f0:	39 f2                	cmp    %esi,%edx
  8015f2:	77 4c                	ja     801640 <__umoddi3+0x80>
  8015f4:	0f bd ca             	bsr    %edx,%ecx
  8015f7:	83 f1 1f             	xor    $0x1f,%ecx
  8015fa:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8015fd:	75 51                	jne    801650 <__umoddi3+0x90>
  8015ff:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  801602:	0f 87 e0 00 00 00    	ja     8016e8 <__umoddi3+0x128>
  801608:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80160b:	29 f8                	sub    %edi,%eax
  80160d:	19 d6                	sbb    %edx,%esi
  80160f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801612:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801615:	89 f2                	mov    %esi,%edx
  801617:	83 c4 20             	add    $0x20,%esp
  80161a:	5e                   	pop    %esi
  80161b:	5f                   	pop    %edi
  80161c:	5d                   	pop    %ebp
  80161d:	c3                   	ret    
  80161e:	66 90                	xchg   %ax,%ax
  801620:	85 ff                	test   %edi,%edi
  801622:	75 0b                	jne    80162f <__umoddi3+0x6f>
  801624:	b8 01 00 00 00       	mov    $0x1,%eax
  801629:	31 d2                	xor    %edx,%edx
  80162b:	f7 f7                	div    %edi
  80162d:	89 c7                	mov    %eax,%edi
  80162f:	89 f0                	mov    %esi,%eax
  801631:	31 d2                	xor    %edx,%edx
  801633:	f7 f7                	div    %edi
  801635:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801638:	f7 f7                	div    %edi
  80163a:	eb a9                	jmp    8015e5 <__umoddi3+0x25>
  80163c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801640:	89 c8                	mov    %ecx,%eax
  801642:	89 f2                	mov    %esi,%edx
  801644:	83 c4 20             	add    $0x20,%esp
  801647:	5e                   	pop    %esi
  801648:	5f                   	pop    %edi
  801649:	5d                   	pop    %ebp
  80164a:	c3                   	ret    
  80164b:	90                   	nop
  80164c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801650:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801654:	d3 e2                	shl    %cl,%edx
  801656:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801659:	ba 20 00 00 00       	mov    $0x20,%edx
  80165e:	2b 55 f0             	sub    -0x10(%ebp),%edx
  801661:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801664:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801668:	89 fa                	mov    %edi,%edx
  80166a:	d3 ea                	shr    %cl,%edx
  80166c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801670:	0b 55 f4             	or     -0xc(%ebp),%edx
  801673:	d3 e7                	shl    %cl,%edi
  801675:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801679:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80167c:	89 f2                	mov    %esi,%edx
  80167e:	89 7d e8             	mov    %edi,-0x18(%ebp)
  801681:	89 c7                	mov    %eax,%edi
  801683:	d3 ea                	shr    %cl,%edx
  801685:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801689:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80168c:	89 c2                	mov    %eax,%edx
  80168e:	d3 e6                	shl    %cl,%esi
  801690:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801694:	d3 ea                	shr    %cl,%edx
  801696:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80169a:	09 d6                	or     %edx,%esi
  80169c:	89 f0                	mov    %esi,%eax
  80169e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8016a1:	d3 e7                	shl    %cl,%edi
  8016a3:	89 f2                	mov    %esi,%edx
  8016a5:	f7 75 f4             	divl   -0xc(%ebp)
  8016a8:	89 d6                	mov    %edx,%esi
  8016aa:	f7 65 e8             	mull   -0x18(%ebp)
  8016ad:	39 d6                	cmp    %edx,%esi
  8016af:	72 2b                	jb     8016dc <__umoddi3+0x11c>
  8016b1:	39 c7                	cmp    %eax,%edi
  8016b3:	72 23                	jb     8016d8 <__umoddi3+0x118>
  8016b5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8016b9:	29 c7                	sub    %eax,%edi
  8016bb:	19 d6                	sbb    %edx,%esi
  8016bd:	89 f0                	mov    %esi,%eax
  8016bf:	89 f2                	mov    %esi,%edx
  8016c1:	d3 ef                	shr    %cl,%edi
  8016c3:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8016c7:	d3 e0                	shl    %cl,%eax
  8016c9:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8016cd:	09 f8                	or     %edi,%eax
  8016cf:	d3 ea                	shr    %cl,%edx
  8016d1:	83 c4 20             	add    $0x20,%esp
  8016d4:	5e                   	pop    %esi
  8016d5:	5f                   	pop    %edi
  8016d6:	5d                   	pop    %ebp
  8016d7:	c3                   	ret    
  8016d8:	39 d6                	cmp    %edx,%esi
  8016da:	75 d9                	jne    8016b5 <__umoddi3+0xf5>
  8016dc:	2b 45 e8             	sub    -0x18(%ebp),%eax
  8016df:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  8016e2:	eb d1                	jmp    8016b5 <__umoddi3+0xf5>
  8016e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8016e8:	39 f2                	cmp    %esi,%edx
  8016ea:	0f 82 18 ff ff ff    	jb     801608 <__umoddi3+0x48>
  8016f0:	e9 1d ff ff ff       	jmp    801612 <__umoddi3+0x52>
