
obj/user/faultread:     file format elf32-i386


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
  80002c:	e8 23 00 00 00       	call   800054 <libmain>
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
	cprintf("I read %08x from location 0!\n", *(unsigned*)0);
  80003a:	a1 00 00 00 00       	mov    0x0,%eax
  80003f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800043:	c7 04 24 40 16 80 00 	movl   $0x801640,(%esp)
  80004a:	e8 ce 00 00 00       	call   80011d <cprintf>
}
  80004f:	c9                   	leave  
  800050:	c3                   	ret    
  800051:	00 00                	add    %al,(%eax)
	...

00800054 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800054:	55                   	push   %ebp
  800055:	89 e5                	mov    %esp,%ebp
  800057:	83 ec 18             	sub    $0x18,%esp
  80005a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80005d:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800060:	8b 75 08             	mov    0x8(%ebp),%esi
  800063:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  800066:	e8 4a 12 00 00       	call   8012b5 <sys_getenvid>
  80006b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800070:	89 c2                	mov    %eax,%edx
  800072:	c1 e2 07             	shl    $0x7,%edx
  800075:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  80007c:	a3 04 20 80 00       	mov    %eax,0x802004
        //cprintf("ENVX sys_get_envid(): %d\n",ENVX(sys_getenvid()));
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800081:	85 f6                	test   %esi,%esi
  800083:	7e 07                	jle    80008c <libmain+0x38>
		binaryname = argv[0];
  800085:	8b 03                	mov    (%ebx),%eax
  800087:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80008c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800090:	89 34 24             	mov    %esi,(%esp)
  800093:	e8 9c ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800098:	e8 0b 00 00 00       	call   8000a8 <exit>
}
  80009d:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8000a0:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8000a3:	89 ec                	mov    %ebp,%esp
  8000a5:	5d                   	pop    %ebp
  8000a6:	c3                   	ret    
	...

008000a8 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a8:	55                   	push   %ebp
  8000a9:	89 e5                	mov    %esp,%ebp
  8000ab:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000ae:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000b5:	e8 3b 12 00 00       	call   8012f5 <sys_env_destroy>
}
  8000ba:	c9                   	leave  
  8000bb:	c3                   	ret    

008000bc <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  8000bc:	55                   	push   %ebp
  8000bd:	89 e5                	mov    %esp,%ebp
  8000bf:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8000c5:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8000cc:	00 00 00 
	b.cnt = 0;
  8000cf:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8000d6:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8000d9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000dc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8000e3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8000e7:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8000ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000f1:	c7 04 24 37 01 80 00 	movl   $0x800137,(%esp)
  8000f8:	e8 cf 01 00 00       	call   8002cc <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8000fd:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800103:	89 44 24 04          	mov    %eax,0x4(%esp)
  800107:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80010d:	89 04 24             	mov    %eax,(%esp)
  800110:	e8 67 0d 00 00       	call   800e7c <sys_cputs>

	return b.cnt;
}
  800115:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80011b:	c9                   	leave  
  80011c:	c3                   	ret    

0080011d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80011d:	55                   	push   %ebp
  80011e:	89 e5                	mov    %esp,%ebp
  800120:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  800123:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  800126:	89 44 24 04          	mov    %eax,0x4(%esp)
  80012a:	8b 45 08             	mov    0x8(%ebp),%eax
  80012d:	89 04 24             	mov    %eax,(%esp)
  800130:	e8 87 ff ff ff       	call   8000bc <vcprintf>
	va_end(ap);

	return cnt;
}
  800135:	c9                   	leave  
  800136:	c3                   	ret    

00800137 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800137:	55                   	push   %ebp
  800138:	89 e5                	mov    %esp,%ebp
  80013a:	53                   	push   %ebx
  80013b:	83 ec 14             	sub    $0x14,%esp
  80013e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800141:	8b 03                	mov    (%ebx),%eax
  800143:	8b 55 08             	mov    0x8(%ebp),%edx
  800146:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80014a:	83 c0 01             	add    $0x1,%eax
  80014d:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80014f:	3d ff 00 00 00       	cmp    $0xff,%eax
  800154:	75 19                	jne    80016f <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800156:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80015d:	00 
  80015e:	8d 43 08             	lea    0x8(%ebx),%eax
  800161:	89 04 24             	mov    %eax,(%esp)
  800164:	e8 13 0d 00 00       	call   800e7c <sys_cputs>
		b->idx = 0;
  800169:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80016f:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800173:	83 c4 14             	add    $0x14,%esp
  800176:	5b                   	pop    %ebx
  800177:	5d                   	pop    %ebp
  800178:	c3                   	ret    
  800179:	00 00                	add    %al,(%eax)
  80017b:	00 00                	add    %al,(%eax)
  80017d:	00 00                	add    %al,(%eax)
	...

00800180 <printnum_v2>:
 */

static void 
printnum_v2(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800180:	55                   	push   %ebp
  800181:	89 e5                	mov    %esp,%ebp
  800183:	57                   	push   %edi
  800184:	56                   	push   %esi
  800185:	53                   	push   %ebx
  800186:	83 ec 4c             	sub    $0x4c,%esp
  800189:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80018c:	89 d6                	mov    %edx,%esi
  80018e:	8b 45 08             	mov    0x8(%ebp),%eax
  800191:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800194:	8b 55 0c             	mov    0xc(%ebp),%edx
  800197:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80019a:	8b 45 10             	mov    0x10(%ebp),%eax
  80019d:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8001a0:	8b 7d 18             	mov    0x18(%ebp),%edi
    if (num >= base) {
  8001a3:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8001a6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001ab:	39 d1                	cmp    %edx,%ecx
  8001ad:	72 07                	jb     8001b6 <printnum_v2+0x36>
  8001af:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8001b2:	39 d0                	cmp    %edx,%eax
  8001b4:	77 5f                	ja     800215 <printnum_v2+0x95>
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
  8001b6:	89 7c 24 10          	mov    %edi,0x10(%esp)
  8001ba:	83 eb 01             	sub    $0x1,%ebx
  8001bd:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8001c1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001c5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8001c9:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  8001cd:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8001d0:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  8001d3:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8001d6:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001da:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001e1:	00 
  8001e2:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8001e5:	89 04 24             	mov    %eax,(%esp)
  8001e8:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8001eb:	89 54 24 04          	mov    %edx,0x4(%esp)
  8001ef:	e8 dc 11 00 00       	call   8013d0 <__udivdi3>
  8001f4:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8001f7:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8001fa:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8001fe:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800202:	89 04 24             	mov    %eax,(%esp)
  800205:	89 54 24 04          	mov    %edx,0x4(%esp)
  800209:	89 f2                	mov    %esi,%edx
  80020b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80020e:	e8 6d ff ff ff       	call   800180 <printnum_v2>
  800213:	eb 1e                	jmp    800233 <printnum_v2+0xb3>
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
  800215:	83 ff 2d             	cmp    $0x2d,%edi
  800218:	74 19                	je     800233 <printnum_v2+0xb3>
		while (--width > 0)
  80021a:	83 eb 01             	sub    $0x1,%ebx
  80021d:	85 db                	test   %ebx,%ebx
  80021f:	90                   	nop
  800220:	7e 11                	jle    800233 <printnum_v2+0xb3>
			putch(padc, putdat);
  800222:	89 74 24 04          	mov    %esi,0x4(%esp)
  800226:	89 3c 24             	mov    %edi,(%esp)
  800229:	ff 55 e4             	call   *-0x1c(%ebp)
    if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
		while (--width > 0)
  80022c:	83 eb 01             	sub    $0x1,%ebx
  80022f:	85 db                	test   %ebx,%ebx
  800231:	7f ef                	jg     800222 <printnum_v2+0xa2>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800233:	89 74 24 04          	mov    %esi,0x4(%esp)
  800237:	8b 74 24 04          	mov    0x4(%esp),%esi
  80023b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80023e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800242:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800249:	00 
  80024a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80024d:	89 14 24             	mov    %edx,(%esp)
  800250:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800253:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800257:	e8 a4 12 00 00       	call   801500 <__umoddi3>
  80025c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800260:	0f be 80 68 16 80 00 	movsbl 0x801668(%eax),%eax
  800267:	89 04 24             	mov    %eax,(%esp)
  80026a:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80026d:	83 c4 4c             	add    $0x4c,%esp
  800270:	5b                   	pop    %ebx
  800271:	5e                   	pop    %esi
  800272:	5f                   	pop    %edi
  800273:	5d                   	pop    %ebp
  800274:	c3                   	ret    

00800275 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800275:	55                   	push   %ebp
  800276:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800278:	83 fa 01             	cmp    $0x1,%edx
  80027b:	7e 0e                	jle    80028b <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80027d:	8b 10                	mov    (%eax),%edx
  80027f:	8d 4a 08             	lea    0x8(%edx),%ecx
  800282:	89 08                	mov    %ecx,(%eax)
  800284:	8b 02                	mov    (%edx),%eax
  800286:	8b 52 04             	mov    0x4(%edx),%edx
  800289:	eb 22                	jmp    8002ad <getuint+0x38>
	else if (lflag)
  80028b:	85 d2                	test   %edx,%edx
  80028d:	74 10                	je     80029f <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80028f:	8b 10                	mov    (%eax),%edx
  800291:	8d 4a 04             	lea    0x4(%edx),%ecx
  800294:	89 08                	mov    %ecx,(%eax)
  800296:	8b 02                	mov    (%edx),%eax
  800298:	ba 00 00 00 00       	mov    $0x0,%edx
  80029d:	eb 0e                	jmp    8002ad <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80029f:	8b 10                	mov    (%eax),%edx
  8002a1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002a4:	89 08                	mov    %ecx,(%eax)
  8002a6:	8b 02                	mov    (%edx),%eax
  8002a8:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002ad:	5d                   	pop    %ebp
  8002ae:	c3                   	ret    

008002af <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002af:	55                   	push   %ebp
  8002b0:	89 e5                	mov    %esp,%ebp
  8002b2:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002b5:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002b9:	8b 10                	mov    (%eax),%edx
  8002bb:	3b 50 04             	cmp    0x4(%eax),%edx
  8002be:	73 0a                	jae    8002ca <sprintputch+0x1b>
		*b->buf++ = ch;
  8002c0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002c3:	88 0a                	mov    %cl,(%edx)
  8002c5:	83 c2 01             	add    $0x1,%edx
  8002c8:	89 10                	mov    %edx,(%eax)
}
  8002ca:	5d                   	pop    %ebp
  8002cb:	c3                   	ret    

008002cc <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002cc:	55                   	push   %ebp
  8002cd:	89 e5                	mov    %esp,%ebp
  8002cf:	57                   	push   %edi
  8002d0:	56                   	push   %esi
  8002d1:	53                   	push   %ebx
  8002d2:	83 ec 6c             	sub    $0x6c,%esp
  8002d5:	8b 7d 10             	mov    0x10(%ebp),%edi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8002d8:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  8002df:	eb 1a                	jmp    8002fb <vprintfmt+0x2f>
	int base, lflag, width, precision, altflag,signflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002e1:	85 c0                	test   %eax,%eax
  8002e3:	0f 84 66 06 00 00    	je     80094f <vprintfmt+0x683>
				return;
			putch(ch, putdat);
  8002e9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002ec:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002f0:	89 04 24             	mov    %eax,(%esp)
  8002f3:	ff 55 08             	call   *0x8(%ebp)
  8002f6:	eb 03                	jmp    8002fb <vprintfmt+0x2f>
  8002f8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag,signflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002fb:	0f b6 07             	movzbl (%edi),%eax
  8002fe:	83 c7 01             	add    $0x1,%edi
  800301:	83 f8 25             	cmp    $0x25,%eax
  800304:	75 db                	jne    8002e1 <vprintfmt+0x15>
  800306:	c6 45 cc 20          	movb   $0x20,-0x34(%ebp)
  80030a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80030f:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  800316:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
  80031b:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800322:	be 00 00 00 00       	mov    $0x0,%esi
  800327:	eb 06                	jmp    80032f <vprintfmt+0x63>
  800329:	c6 45 cc 2d          	movb   $0x2d,-0x34(%ebp)
  80032d:	89 c7                	mov    %eax,%edi
		precision = -1;
		lflag = 0;
		altflag = 0;
                signflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80032f:	0f b6 17             	movzbl (%edi),%edx
  800332:	0f b6 c2             	movzbl %dl,%eax
  800335:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800338:	8d 47 01             	lea    0x1(%edi),%eax
  80033b:	83 ea 23             	sub    $0x23,%edx
  80033e:	80 fa 55             	cmp    $0x55,%dl
  800341:	0f 87 60 05 00 00    	ja     8008a7 <vprintfmt+0x5db>
  800347:	0f b6 d2             	movzbl %dl,%edx
  80034a:	ff 24 95 a0 17 80 00 	jmp    *0x8017a0(,%edx,4)
  800351:	b9 01 00 00 00       	mov    $0x1,%ecx
  800356:	eb d5                	jmp    80032d <vprintfmt+0x61>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800358:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80035b:	83 eb 30             	sub    $0x30,%ebx
				ch = *fmt;
  80035e:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  800361:	8d 7a d0             	lea    -0x30(%edx),%edi
  800364:	83 ff 09             	cmp    $0x9,%edi
  800367:	76 08                	jbe    800371 <vprintfmt+0xa5>
  800369:	eb 40                	jmp    8003ab <vprintfmt+0xdf>
  80036b:	c6 45 cc 30          	movb   $0x30,-0x34(%ebp)
                        signflag = 1;
                        goto reswitch;
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
			goto reswitch;
  80036f:	eb bc                	jmp    80032d <vprintfmt+0x61>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800371:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  800374:	8d 1c 9b             	lea    (%ebx,%ebx,4),%ebx
  800377:	8d 5c 5a d0          	lea    -0x30(%edx,%ebx,2),%ebx
				ch = *fmt;
  80037b:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  80037e:	8d 7a d0             	lea    -0x30(%edx),%edi
  800381:	83 ff 09             	cmp    $0x9,%edi
  800384:	76 eb                	jbe    800371 <vprintfmt+0xa5>
  800386:	eb 23                	jmp    8003ab <vprintfmt+0xdf>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800388:	8b 55 14             	mov    0x14(%ebp),%edx
  80038b:	8d 5a 04             	lea    0x4(%edx),%ebx
  80038e:	89 5d 14             	mov    %ebx,0x14(%ebp)
  800391:	8b 1a                	mov    (%edx),%ebx
			goto process_precision;
  800393:	eb 16                	jmp    8003ab <vprintfmt+0xdf>

		case '.':
			if (width < 0)
  800395:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800398:	c1 fa 1f             	sar    $0x1f,%edx
  80039b:	f7 d2                	not    %edx
  80039d:	21 55 d8             	and    %edx,-0x28(%ebp)
  8003a0:	eb 8b                	jmp    80032d <vprintfmt+0x61>
  8003a2:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  8003a9:	eb 82                	jmp    80032d <vprintfmt+0x61>

		process_precision:
			if (width < 0)
  8003ab:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8003af:	0f 89 78 ff ff ff    	jns    80032d <vprintfmt+0x61>
  8003b5:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8003b8:	8b 5d c8             	mov    -0x38(%ebp),%ebx
  8003bb:	e9 6d ff ff ff       	jmp    80032d <vprintfmt+0x61>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003c0:	83 c6 01             	add    $0x1,%esi
			goto reswitch;
  8003c3:	e9 65 ff ff ff       	jmp    80032d <vprintfmt+0x61>
  8003c8:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ce:	8d 50 04             	lea    0x4(%eax),%edx
  8003d1:	89 55 14             	mov    %edx,0x14(%ebp)
  8003d4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003d7:	89 54 24 04          	mov    %edx,0x4(%esp)
  8003db:	8b 00                	mov    (%eax),%eax
  8003dd:	89 04 24             	mov    %eax,(%esp)
  8003e0:	ff 55 08             	call   *0x8(%ebp)
  8003e3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;
  8003e6:	e9 10 ff ff ff       	jmp    8002fb <vprintfmt+0x2f>
  8003eb:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f1:	8d 50 04             	lea    0x4(%eax),%edx
  8003f4:	89 55 14             	mov    %edx,0x14(%ebp)
  8003f7:	8b 00                	mov    (%eax),%eax
  8003f9:	89 c2                	mov    %eax,%edx
  8003fb:	c1 fa 1f             	sar    $0x1f,%edx
  8003fe:	31 d0                	xor    %edx,%eax
  800400:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800402:	83 f8 08             	cmp    $0x8,%eax
  800405:	7f 0b                	jg     800412 <vprintfmt+0x146>
  800407:	8b 14 85 00 19 80 00 	mov    0x801900(,%eax,4),%edx
  80040e:	85 d2                	test   %edx,%edx
  800410:	75 26                	jne    800438 <vprintfmt+0x16c>
				printfmt(putch, putdat, "error %d", err);
  800412:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800416:	c7 44 24 08 79 16 80 	movl   $0x801679,0x8(%esp)
  80041d:	00 
  80041e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800421:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800425:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800428:	89 1c 24             	mov    %ebx,(%esp)
  80042b:	e8 a7 05 00 00       	call   8009d7 <printfmt>
  800430:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800433:	e9 c3 fe ff ff       	jmp    8002fb <vprintfmt+0x2f>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800438:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80043c:	c7 44 24 08 82 16 80 	movl   $0x801682,0x8(%esp)
  800443:	00 
  800444:	8b 45 0c             	mov    0xc(%ebp),%eax
  800447:	89 44 24 04          	mov    %eax,0x4(%esp)
  80044b:	8b 55 08             	mov    0x8(%ebp),%edx
  80044e:	89 14 24             	mov    %edx,(%esp)
  800451:	e8 81 05 00 00       	call   8009d7 <printfmt>
  800456:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800459:	e9 9d fe ff ff       	jmp    8002fb <vprintfmt+0x2f>
  80045e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800461:	89 c7                	mov    %eax,%edi
  800463:	89 d9                	mov    %ebx,%ecx
  800465:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800468:	89 45 c0             	mov    %eax,-0x40(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80046b:	8b 45 14             	mov    0x14(%ebp),%eax
  80046e:	8d 50 04             	lea    0x4(%eax),%edx
  800471:	89 55 14             	mov    %edx,0x14(%ebp)
  800474:	8b 30                	mov    (%eax),%esi
  800476:	85 f6                	test   %esi,%esi
  800478:	75 05                	jne    80047f <vprintfmt+0x1b3>
  80047a:	be 85 16 80 00       	mov    $0x801685,%esi
				p = "(null)";
			if (width > 0 && padc != '-')
  80047f:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
  800483:	7e 06                	jle    80048b <vprintfmt+0x1bf>
  800485:	80 7d cc 2d          	cmpb   $0x2d,-0x34(%ebp)
  800489:	75 10                	jne    80049b <vprintfmt+0x1cf>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80048b:	0f be 06             	movsbl (%esi),%eax
  80048e:	85 c0                	test   %eax,%eax
  800490:	0f 85 a2 00 00 00    	jne    800538 <vprintfmt+0x26c>
  800496:	e9 92 00 00 00       	jmp    80052d <vprintfmt+0x261>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80049b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80049f:	89 34 24             	mov    %esi,(%esp)
  8004a2:	e8 74 05 00 00       	call   800a1b <strnlen>
  8004a7:	8b 55 c0             	mov    -0x40(%ebp),%edx
  8004aa:	29 c2                	sub    %eax,%edx
  8004ac:	89 55 d8             	mov    %edx,-0x28(%ebp)
  8004af:	85 d2                	test   %edx,%edx
  8004b1:	7e d8                	jle    80048b <vprintfmt+0x1bf>
					putch(padc, putdat);
  8004b3:	0f be 4d cc          	movsbl -0x34(%ebp),%ecx
  8004b7:	89 5d c0             	mov    %ebx,-0x40(%ebp)
  8004ba:	89 d3                	mov    %edx,%ebx
  8004bc:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8004bf:	89 7d bc             	mov    %edi,-0x44(%ebp)
  8004c2:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8004c5:	89 ce                	mov    %ecx,%esi
  8004c7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004cb:	89 34 24             	mov    %esi,(%esp)
  8004ce:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004d1:	83 eb 01             	sub    $0x1,%ebx
  8004d4:	85 db                	test   %ebx,%ebx
  8004d6:	7f ef                	jg     8004c7 <vprintfmt+0x1fb>
  8004d8:	8b 5d c0             	mov    -0x40(%ebp),%ebx
  8004db:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8004de:	8b 7d bc             	mov    -0x44(%ebp),%edi
  8004e1:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8004e8:	eb a1                	jmp    80048b <vprintfmt+0x1bf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004ea:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  8004ee:	74 1b                	je     80050b <vprintfmt+0x23f>
  8004f0:	8d 50 e0             	lea    -0x20(%eax),%edx
  8004f3:	83 fa 5e             	cmp    $0x5e,%edx
  8004f6:	76 13                	jbe    80050b <vprintfmt+0x23f>
					putch('?', putdat);
  8004f8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004fb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004ff:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800506:	ff 55 08             	call   *0x8(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800509:	eb 0d                	jmp    800518 <vprintfmt+0x24c>
					putch('?', putdat);
				else
					putch(ch, putdat);
  80050b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80050e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800512:	89 04 24             	mov    %eax,(%esp)
  800515:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800518:	83 ef 01             	sub    $0x1,%edi
  80051b:	0f be 06             	movsbl (%esi),%eax
  80051e:	85 c0                	test   %eax,%eax
  800520:	74 05                	je     800527 <vprintfmt+0x25b>
  800522:	83 c6 01             	add    $0x1,%esi
  800525:	eb 1a                	jmp    800541 <vprintfmt+0x275>
  800527:	89 7d d8             	mov    %edi,-0x28(%ebp)
  80052a:	8b 7d cc             	mov    -0x34(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80052d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800531:	7f 1f                	jg     800552 <vprintfmt+0x286>
  800533:	e9 c0 fd ff ff       	jmp    8002f8 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800538:	83 c6 01             	add    $0x1,%esi
  80053b:	89 7d cc             	mov    %edi,-0x34(%ebp)
  80053e:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800541:	85 db                	test   %ebx,%ebx
  800543:	78 a5                	js     8004ea <vprintfmt+0x21e>
  800545:	83 eb 01             	sub    $0x1,%ebx
  800548:	79 a0                	jns    8004ea <vprintfmt+0x21e>
  80054a:	89 7d d8             	mov    %edi,-0x28(%ebp)
  80054d:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800550:	eb db                	jmp    80052d <vprintfmt+0x261>
  800552:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800555:	8b 75 0c             	mov    0xc(%ebp),%esi
  800558:	89 7d d8             	mov    %edi,-0x28(%ebp)
  80055b:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80055e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800562:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800569:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80056b:	83 eb 01             	sub    $0x1,%ebx
  80056e:	85 db                	test   %ebx,%ebx
  800570:	7f ec                	jg     80055e <vprintfmt+0x292>
  800572:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800575:	e9 81 fd ff ff       	jmp    8002fb <vprintfmt+0x2f>
  80057a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80057d:	83 fe 01             	cmp    $0x1,%esi
  800580:	7e 10                	jle    800592 <vprintfmt+0x2c6>
		return va_arg(*ap, long long);
  800582:	8b 45 14             	mov    0x14(%ebp),%eax
  800585:	8d 50 08             	lea    0x8(%eax),%edx
  800588:	89 55 14             	mov    %edx,0x14(%ebp)
  80058b:	8b 18                	mov    (%eax),%ebx
  80058d:	8b 70 04             	mov    0x4(%eax),%esi
  800590:	eb 26                	jmp    8005b8 <vprintfmt+0x2ec>
	else if (lflag)
  800592:	85 f6                	test   %esi,%esi
  800594:	74 12                	je     8005a8 <vprintfmt+0x2dc>
		return va_arg(*ap, long);
  800596:	8b 45 14             	mov    0x14(%ebp),%eax
  800599:	8d 50 04             	lea    0x4(%eax),%edx
  80059c:	89 55 14             	mov    %edx,0x14(%ebp)
  80059f:	8b 18                	mov    (%eax),%ebx
  8005a1:	89 de                	mov    %ebx,%esi
  8005a3:	c1 fe 1f             	sar    $0x1f,%esi
  8005a6:	eb 10                	jmp    8005b8 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  8005a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ab:	8d 50 04             	lea    0x4(%eax),%edx
  8005ae:	89 55 14             	mov    %edx,0x14(%ebp)
  8005b1:	8b 18                	mov    (%eax),%ebx
  8005b3:	89 de                	mov    %ebx,%esi
  8005b5:	c1 fe 1f             	sar    $0x1f,%esi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
                        if(signflag == 1){
  8005b8:	83 f9 01             	cmp    $0x1,%ecx
  8005bb:	75 1e                	jne    8005db <vprintfmt+0x30f>
                               if((long long)num > 0){
  8005bd:	85 f6                	test   %esi,%esi
  8005bf:	78 1a                	js     8005db <vprintfmt+0x30f>
  8005c1:	85 f6                	test   %esi,%esi
  8005c3:	7f 05                	jg     8005ca <vprintfmt+0x2fe>
  8005c5:	83 fb 00             	cmp    $0x0,%ebx
  8005c8:	76 11                	jbe    8005db <vprintfmt+0x30f>
                                   putch('+',putdat);
  8005ca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8005cd:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8005d1:	c7 04 24 2b 00 00 00 	movl   $0x2b,(%esp)
  8005d8:	ff 55 08             	call   *0x8(%ebp)
                               }
                        }
			if ((long long) num < 0) {
  8005db:	85 f6                	test   %esi,%esi
  8005dd:	78 13                	js     8005f2 <vprintfmt+0x326>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005df:	89 5d b0             	mov    %ebx,-0x50(%ebp)
  8005e2:	89 75 b4             	mov    %esi,-0x4c(%ebp)
  8005e5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005e8:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005ed:	e9 da 00 00 00       	jmp    8006cc <vprintfmt+0x400>
                               if((long long)num > 0){
                                   putch('+',putdat);
                               }
                        }
			if ((long long) num < 0) {
				putch('-', putdat);
  8005f2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005f5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005f9:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800600:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800603:	89 da                	mov    %ebx,%edx
  800605:	89 f1                	mov    %esi,%ecx
  800607:	f7 da                	neg    %edx
  800609:	83 d1 00             	adc    $0x0,%ecx
  80060c:	f7 d9                	neg    %ecx
  80060e:	89 55 b0             	mov    %edx,-0x50(%ebp)
  800611:	89 4d b4             	mov    %ecx,-0x4c(%ebp)
  800614:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800617:	b8 0a 00 00 00       	mov    $0xa,%eax
  80061c:	e9 ab 00 00 00       	jmp    8006cc <vprintfmt+0x400>
  800621:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800624:	89 f2                	mov    %esi,%edx
  800626:	8d 45 14             	lea    0x14(%ebp),%eax
  800629:	e8 47 fc ff ff       	call   800275 <getuint>
  80062e:	89 45 b0             	mov    %eax,-0x50(%ebp)
  800631:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  800634:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800637:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
  80063c:	e9 8b 00 00 00       	jmp    8006cc <vprintfmt+0x400>
  800641:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			putch('0', putdat);
  800644:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800647:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80064b:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800652:	ff 55 08             	call   *0x8(%ebp)
			num = getuint(&ap,lflag);
  800655:	89 f2                	mov    %esi,%edx
  800657:	8d 45 14             	lea    0x14(%ebp),%eax
  80065a:	e8 16 fc ff ff       	call   800275 <getuint>
  80065f:	89 45 b0             	mov    %eax,-0x50(%ebp)
  800662:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  800665:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800668:	b8 08 00 00 00       	mov    $0x8,%eax
                        base = 8;
			goto number;
  80066d:	eb 5d                	jmp    8006cc <vprintfmt+0x400>
  80066f:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
  800672:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800675:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800679:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800680:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800683:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800687:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80068e:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  800691:	8b 45 14             	mov    0x14(%ebp),%eax
  800694:	8d 50 04             	lea    0x4(%eax),%edx
  800697:	89 55 14             	mov    %edx,0x14(%ebp)
  80069a:	8b 10                	mov    (%eax),%edx
  80069c:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006a1:	89 55 b0             	mov    %edx,-0x50(%ebp)
  8006a4:	89 4d b4             	mov    %ecx,-0x4c(%ebp)
  8006a7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006aa:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006af:	eb 1b                	jmp    8006cc <vprintfmt+0x400>
  8006b1:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006b4:	89 f2                	mov    %esi,%edx
  8006b6:	8d 45 14             	lea    0x14(%ebp),%eax
  8006b9:	e8 b7 fb ff ff       	call   800275 <getuint>
  8006be:	89 45 b0             	mov    %eax,-0x50(%ebp)
  8006c1:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  8006c4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006c7:	b8 10 00 00 00       	mov    $0x10,%eax
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006cc:	0f be 4d cc          	movsbl -0x34(%ebp),%ecx
  8006d0:	89 4d d0             	mov    %ecx,-0x30(%ebp)
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8006d3:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8006d6:	83 7d b4 00          	cmpl   $0x0,-0x4c(%ebp)
  8006da:	77 09                	ja     8006e5 <vprintfmt+0x419>
  8006dc:	39 45 b0             	cmp    %eax,-0x50(%ebp)
  8006df:	0f 82 ac 00 00 00    	jb     800791 <vprintfmt+0x4c5>
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
  8006e5:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8006e8:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  8006ec:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8006ef:	83 ea 01             	sub    $0x1,%edx
  8006f2:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8006f6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006fa:	8b 44 24 08          	mov    0x8(%esp),%eax
  8006fe:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800702:	89 45 c0             	mov    %eax,-0x40(%ebp)
  800705:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  800708:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80070b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80070f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800716:	00 
  800717:	8b 4d b0             	mov    -0x50(%ebp),%ecx
  80071a:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
  80071d:	89 0c 24             	mov    %ecx,(%esp)
  800720:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800724:	e8 a7 0c 00 00       	call   8013d0 <__udivdi3>
  800729:	8b 4d c0             	mov    -0x40(%ebp),%ecx
  80072c:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  80072f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800733:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800737:	89 04 24             	mov    %eax,(%esp)
  80073a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80073e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800741:	8b 45 08             	mov    0x8(%ebp),%eax
  800744:	e8 37 fa ff ff       	call   800180 <printnum_v2>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800749:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80074c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800750:	8b 74 24 04          	mov    0x4(%esp),%esi
  800754:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800757:	89 44 24 08          	mov    %eax,0x8(%esp)
  80075b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800762:	00 
  800763:	8b 55 b0             	mov    -0x50(%ebp),%edx
  800766:	8b 4d b4             	mov    -0x4c(%ebp),%ecx
  800769:	89 14 24             	mov    %edx,(%esp)
  80076c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800770:	e8 8b 0d 00 00       	call   801500 <__umoddi3>
  800775:	89 74 24 04          	mov    %esi,0x4(%esp)
  800779:	0f be 80 68 16 80 00 	movsbl 0x801668(%eax),%eax
  800780:	89 04 24             	mov    %eax,(%esp)
  800783:	ff 55 08             	call   *0x8(%ebp)
        if(padc == '-'){
  800786:	83 7d d0 2d          	cmpl   $0x2d,-0x30(%ebp)
  80078a:	74 54                	je     8007e0 <vprintfmt+0x514>
  80078c:	e9 67 fb ff ff       	jmp    8002f8 <vprintfmt+0x2c>
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
  800791:	83 7d d0 2d          	cmpl   $0x2d,-0x30(%ebp)
  800795:	8d 76 00             	lea    0x0(%esi),%esi
  800798:	0f 84 2a 01 00 00    	je     8008c8 <vprintfmt+0x5fc>
		while (--width > 0)
  80079e:	8b 7d d8             	mov    -0x28(%ebp),%edi
  8007a1:	83 ef 01             	sub    $0x1,%edi
  8007a4:	85 ff                	test   %edi,%edi
  8007a6:	0f 8e 5e 01 00 00    	jle    80090a <vprintfmt+0x63e>
  8007ac:	8b 4d b0             	mov    -0x50(%ebp),%ecx
  8007af:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
  8007b2:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  8007b5:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  8007b8:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8007bb:	8b 75 0c             	mov    0xc(%ebp),%esi
			putch(padc, putdat);
  8007be:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007c2:	89 1c 24             	mov    %ebx,(%esp)
  8007c5:	ff 55 08             	call   *0x8(%ebp)
	if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
		while (--width > 0)
  8007c8:	83 ef 01             	sub    $0x1,%edi
  8007cb:	85 ff                	test   %edi,%edi
  8007cd:	7f ef                	jg     8007be <vprintfmt+0x4f2>
  8007cf:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8007d2:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8007d5:	89 45 b0             	mov    %eax,-0x50(%ebp)
  8007d8:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  8007db:	e9 2a 01 00 00       	jmp    80090a <vprintfmt+0x63e>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
        if(padc == '-'){
           while (--width > 0)
  8007e0:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  8007e3:	83 eb 01             	sub    $0x1,%ebx
  8007e6:	85 db                	test   %ebx,%ebx
  8007e8:	0f 8e 0a fb ff ff    	jle    8002f8 <vprintfmt+0x2c>
  8007ee:	8b 75 0c             	mov    0xc(%ebp),%esi
  8007f1:	89 7d d8             	mov    %edi,-0x28(%ebp)
  8007f4:	8b 7d 08             	mov    0x8(%ebp),%edi
			putch(' ', putdat);
  8007f7:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007fb:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800802:	ff d7                	call   *%edi
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
        if(padc == '-'){
           while (--width > 0)
  800804:	83 eb 01             	sub    $0x1,%ebx
  800807:	85 db                	test   %ebx,%ebx
  800809:	7f ec                	jg     8007f7 <vprintfmt+0x52b>
  80080b:	8b 7d d8             	mov    -0x28(%ebp),%edi
  80080e:	e9 e8 fa ff ff       	jmp    8002fb <vprintfmt+0x2f>
  800813:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
            char* n;
            if ((n = va_arg(ap, char *)) == NULL)
  800816:	8b 45 14             	mov    0x14(%ebp),%eax
  800819:	8d 50 04             	lea    0x4(%eax),%edx
  80081c:	89 55 14             	mov    %edx,0x14(%ebp)
  80081f:	8b 00                	mov    (%eax),%eax
  800821:	85 c0                	test   %eax,%eax
  800823:	75 2a                	jne    80084f <vprintfmt+0x583>
		  printfmt(putch,putdat,"%s",null_error);
  800825:	c7 44 24 0c 20 17 80 	movl   $0x801720,0xc(%esp)
  80082c:	00 
  80082d:	c7 44 24 08 82 16 80 	movl   $0x801682,0x8(%esp)
  800834:	00 
  800835:	8b 55 0c             	mov    0xc(%ebp),%edx
  800838:	89 54 24 04          	mov    %edx,0x4(%esp)
  80083c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80083f:	89 0c 24             	mov    %ecx,(%esp)
  800842:	e8 90 01 00 00       	call   8009d7 <printfmt>
  800847:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80084a:	e9 ac fa ff ff       	jmp    8002fb <vprintfmt+0x2f>
            else if((*(int*)putdat) > 127){
  80084f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800852:	8b 13                	mov    (%ebx),%edx
  800854:	83 fa 7f             	cmp    $0x7f,%edx
  800857:	7e 29                	jle    800882 <vprintfmt+0x5b6>
                  *n = *(int*)putdat;
  800859:	88 10                	mov    %dl,(%eax)
                  printfmt(putch,putdat,"%s",overflow_error);
  80085b:	c7 44 24 0c 58 17 80 	movl   $0x801758,0xc(%esp)
  800862:	00 
  800863:	c7 44 24 08 82 16 80 	movl   $0x801682,0x8(%esp)
  80086a:	00 
  80086b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80086f:	8b 45 08             	mov    0x8(%ebp),%eax
  800872:	89 04 24             	mov    %eax,(%esp)
  800875:	e8 5d 01 00 00       	call   8009d7 <printfmt>
  80087a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80087d:	e9 79 fa ff ff       	jmp    8002fb <vprintfmt+0x2f>
            }
            else
                  *n = *(int*)putdat;
  800882:	88 10                	mov    %dl,(%eax)
  800884:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800887:	e9 6f fa ff ff       	jmp    8002fb <vprintfmt+0x2f>
  80088c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80088f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            break;
        }
		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800892:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800895:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800899:	89 14 24             	mov    %edx,(%esp)
  80089c:	ff 55 08             	call   *0x8(%ebp)
  80089f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;
  8008a2:	e9 54 fa ff ff       	jmp    8002fb <vprintfmt+0x2f>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8008a7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8008aa:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008ae:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8008b5:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008b8:	8d 47 ff             	lea    -0x1(%edi),%eax
  8008bb:	80 38 25             	cmpb   $0x25,(%eax)
  8008be:	0f 84 37 fa ff ff    	je     8002fb <vprintfmt+0x2f>
  8008c4:	89 c7                	mov    %eax,%edi
  8008c6:	eb f0                	jmp    8008b8 <vprintfmt+0x5ec>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8008c8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008cb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008cf:	8b 74 24 04          	mov    0x4(%esp),%esi
  8008d3:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8008d6:	89 54 24 08          	mov    %edx,0x8(%esp)
  8008da:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8008e1:	00 
  8008e2:	8b 45 b0             	mov    -0x50(%ebp),%eax
  8008e5:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  8008e8:	89 04 24             	mov    %eax,(%esp)
  8008eb:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008ef:	e8 0c 0c 00 00       	call   801500 <__umoddi3>
  8008f4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8008f8:	0f be 80 68 16 80 00 	movsbl 0x801668(%eax),%eax
  8008ff:	89 04 24             	mov    %eax,(%esp)
  800902:	ff 55 08             	call   *0x8(%ebp)
  800905:	e9 d6 fe ff ff       	jmp    8007e0 <vprintfmt+0x514>
  80090a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80090d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800911:	8b 74 24 04          	mov    0x4(%esp),%esi
  800915:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800918:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80091c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800923:	00 
  800924:	8b 45 b0             	mov    -0x50(%ebp),%eax
  800927:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  80092a:	89 04 24             	mov    %eax,(%esp)
  80092d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800931:	e8 ca 0b 00 00       	call   801500 <__umoddi3>
  800936:	89 74 24 04          	mov    %esi,0x4(%esp)
  80093a:	0f be 80 68 16 80 00 	movsbl 0x801668(%eax),%eax
  800941:	89 04 24             	mov    %eax,(%esp)
  800944:	ff 55 08             	call   *0x8(%ebp)
  800947:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80094a:	e9 ac f9 ff ff       	jmp    8002fb <vprintfmt+0x2f>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  80094f:	83 c4 6c             	add    $0x6c,%esp
  800952:	5b                   	pop    %ebx
  800953:	5e                   	pop    %esi
  800954:	5f                   	pop    %edi
  800955:	5d                   	pop    %ebp
  800956:	c3                   	ret    

00800957 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800957:	55                   	push   %ebp
  800958:	89 e5                	mov    %esp,%ebp
  80095a:	83 ec 28             	sub    $0x28,%esp
  80095d:	8b 45 08             	mov    0x8(%ebp),%eax
  800960:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  800963:	85 c0                	test   %eax,%eax
  800965:	74 04                	je     80096b <vsnprintf+0x14>
  800967:	85 d2                	test   %edx,%edx
  800969:	7f 07                	jg     800972 <vsnprintf+0x1b>
  80096b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800970:	eb 3b                	jmp    8009ad <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  800972:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800975:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  800979:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80097c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800983:	8b 45 14             	mov    0x14(%ebp),%eax
  800986:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80098a:	8b 45 10             	mov    0x10(%ebp),%eax
  80098d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800991:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800994:	89 44 24 04          	mov    %eax,0x4(%esp)
  800998:	c7 04 24 af 02 80 00 	movl   $0x8002af,(%esp)
  80099f:	e8 28 f9 ff ff       	call   8002cc <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8009a4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8009a7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8009aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8009ad:	c9                   	leave  
  8009ae:	c3                   	ret    

008009af <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8009af:	55                   	push   %ebp
  8009b0:	89 e5                	mov    %esp,%ebp
  8009b2:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  8009b5:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  8009b8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009bc:	8b 45 10             	mov    0x10(%ebp),%eax
  8009bf:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009c3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009c6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8009cd:	89 04 24             	mov    %eax,(%esp)
  8009d0:	e8 82 ff ff ff       	call   800957 <vsnprintf>
	va_end(ap);

	return rc;
}
  8009d5:	c9                   	leave  
  8009d6:	c3                   	ret    

008009d7 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8009d7:	55                   	push   %ebp
  8009d8:	89 e5                	mov    %esp,%ebp
  8009da:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  8009dd:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  8009e0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009e4:	8b 45 10             	mov    0x10(%ebp),%eax
  8009e7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009eb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009ee:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f5:	89 04 24             	mov    %eax,(%esp)
  8009f8:	e8 cf f8 ff ff       	call   8002cc <vprintfmt>
	va_end(ap);
}
  8009fd:	c9                   	leave  
  8009fe:	c3                   	ret    
	...

00800a00 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a00:	55                   	push   %ebp
  800a01:	89 e5                	mov    %esp,%ebp
  800a03:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a06:	b8 00 00 00 00       	mov    $0x0,%eax
  800a0b:	80 3a 00             	cmpb   $0x0,(%edx)
  800a0e:	74 09                	je     800a19 <strlen+0x19>
		n++;
  800a10:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800a13:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a17:	75 f7                	jne    800a10 <strlen+0x10>
		n++;
	return n;
}
  800a19:	5d                   	pop    %ebp
  800a1a:	c3                   	ret    

00800a1b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a1b:	55                   	push   %ebp
  800a1c:	89 e5                	mov    %esp,%ebp
  800a1e:	53                   	push   %ebx
  800a1f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800a22:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a25:	85 c9                	test   %ecx,%ecx
  800a27:	74 19                	je     800a42 <strnlen+0x27>
  800a29:	80 3b 00             	cmpb   $0x0,(%ebx)
  800a2c:	74 14                	je     800a42 <strnlen+0x27>
  800a2e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800a33:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a36:	39 c8                	cmp    %ecx,%eax
  800a38:	74 0d                	je     800a47 <strnlen+0x2c>
  800a3a:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  800a3e:	75 f3                	jne    800a33 <strnlen+0x18>
  800a40:	eb 05                	jmp    800a47 <strnlen+0x2c>
  800a42:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800a47:	5b                   	pop    %ebx
  800a48:	5d                   	pop    %ebp
  800a49:	c3                   	ret    

00800a4a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a4a:	55                   	push   %ebp
  800a4b:	89 e5                	mov    %esp,%ebp
  800a4d:	53                   	push   %ebx
  800a4e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a51:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a54:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a59:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800a5d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800a60:	83 c2 01             	add    $0x1,%edx
  800a63:	84 c9                	test   %cl,%cl
  800a65:	75 f2                	jne    800a59 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800a67:	5b                   	pop    %ebx
  800a68:	5d                   	pop    %ebp
  800a69:	c3                   	ret    

00800a6a <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a6a:	55                   	push   %ebp
  800a6b:	89 e5                	mov    %esp,%ebp
  800a6d:	53                   	push   %ebx
  800a6e:	83 ec 08             	sub    $0x8,%esp
  800a71:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a74:	89 1c 24             	mov    %ebx,(%esp)
  800a77:	e8 84 ff ff ff       	call   800a00 <strlen>
	strcpy(dst + len, src);
  800a7c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a7f:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a83:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800a86:	89 04 24             	mov    %eax,(%esp)
  800a89:	e8 bc ff ff ff       	call   800a4a <strcpy>
	return dst;
}
  800a8e:	89 d8                	mov    %ebx,%eax
  800a90:	83 c4 08             	add    $0x8,%esp
  800a93:	5b                   	pop    %ebx
  800a94:	5d                   	pop    %ebp
  800a95:	c3                   	ret    

00800a96 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a96:	55                   	push   %ebp
  800a97:	89 e5                	mov    %esp,%ebp
  800a99:	56                   	push   %esi
  800a9a:	53                   	push   %ebx
  800a9b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a9e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800aa1:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800aa4:	85 f6                	test   %esi,%esi
  800aa6:	74 18                	je     800ac0 <strncpy+0x2a>
  800aa8:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800aad:	0f b6 1a             	movzbl (%edx),%ebx
  800ab0:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800ab3:	80 3a 01             	cmpb   $0x1,(%edx)
  800ab6:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ab9:	83 c1 01             	add    $0x1,%ecx
  800abc:	39 ce                	cmp    %ecx,%esi
  800abe:	77 ed                	ja     800aad <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800ac0:	5b                   	pop    %ebx
  800ac1:	5e                   	pop    %esi
  800ac2:	5d                   	pop    %ebp
  800ac3:	c3                   	ret    

00800ac4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800ac4:	55                   	push   %ebp
  800ac5:	89 e5                	mov    %esp,%ebp
  800ac7:	56                   	push   %esi
  800ac8:	53                   	push   %ebx
  800ac9:	8b 75 08             	mov    0x8(%ebp),%esi
  800acc:	8b 55 0c             	mov    0xc(%ebp),%edx
  800acf:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800ad2:	89 f0                	mov    %esi,%eax
  800ad4:	85 c9                	test   %ecx,%ecx
  800ad6:	74 27                	je     800aff <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  800ad8:	83 e9 01             	sub    $0x1,%ecx
  800adb:	74 1d                	je     800afa <strlcpy+0x36>
  800add:	0f b6 1a             	movzbl (%edx),%ebx
  800ae0:	84 db                	test   %bl,%bl
  800ae2:	74 16                	je     800afa <strlcpy+0x36>
			*dst++ = *src++;
  800ae4:	88 18                	mov    %bl,(%eax)
  800ae6:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800ae9:	83 e9 01             	sub    $0x1,%ecx
  800aec:	74 0e                	je     800afc <strlcpy+0x38>
			*dst++ = *src++;
  800aee:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800af1:	0f b6 1a             	movzbl (%edx),%ebx
  800af4:	84 db                	test   %bl,%bl
  800af6:	75 ec                	jne    800ae4 <strlcpy+0x20>
  800af8:	eb 02                	jmp    800afc <strlcpy+0x38>
  800afa:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800afc:	c6 00 00             	movb   $0x0,(%eax)
  800aff:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800b01:	5b                   	pop    %ebx
  800b02:	5e                   	pop    %esi
  800b03:	5d                   	pop    %ebp
  800b04:	c3                   	ret    

00800b05 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b05:	55                   	push   %ebp
  800b06:	89 e5                	mov    %esp,%ebp
  800b08:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b0b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800b0e:	0f b6 01             	movzbl (%ecx),%eax
  800b11:	84 c0                	test   %al,%al
  800b13:	74 15                	je     800b2a <strcmp+0x25>
  800b15:	3a 02                	cmp    (%edx),%al
  800b17:	75 11                	jne    800b2a <strcmp+0x25>
		p++, q++;
  800b19:	83 c1 01             	add    $0x1,%ecx
  800b1c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800b1f:	0f b6 01             	movzbl (%ecx),%eax
  800b22:	84 c0                	test   %al,%al
  800b24:	74 04                	je     800b2a <strcmp+0x25>
  800b26:	3a 02                	cmp    (%edx),%al
  800b28:	74 ef                	je     800b19 <strcmp+0x14>
  800b2a:	0f b6 c0             	movzbl %al,%eax
  800b2d:	0f b6 12             	movzbl (%edx),%edx
  800b30:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800b32:	5d                   	pop    %ebp
  800b33:	c3                   	ret    

00800b34 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b34:	55                   	push   %ebp
  800b35:	89 e5                	mov    %esp,%ebp
  800b37:	53                   	push   %ebx
  800b38:	8b 55 08             	mov    0x8(%ebp),%edx
  800b3b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b3e:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800b41:	85 c0                	test   %eax,%eax
  800b43:	74 23                	je     800b68 <strncmp+0x34>
  800b45:	0f b6 1a             	movzbl (%edx),%ebx
  800b48:	84 db                	test   %bl,%bl
  800b4a:	74 25                	je     800b71 <strncmp+0x3d>
  800b4c:	3a 19                	cmp    (%ecx),%bl
  800b4e:	75 21                	jne    800b71 <strncmp+0x3d>
  800b50:	83 e8 01             	sub    $0x1,%eax
  800b53:	74 13                	je     800b68 <strncmp+0x34>
		n--, p++, q++;
  800b55:	83 c2 01             	add    $0x1,%edx
  800b58:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b5b:	0f b6 1a             	movzbl (%edx),%ebx
  800b5e:	84 db                	test   %bl,%bl
  800b60:	74 0f                	je     800b71 <strncmp+0x3d>
  800b62:	3a 19                	cmp    (%ecx),%bl
  800b64:	74 ea                	je     800b50 <strncmp+0x1c>
  800b66:	eb 09                	jmp    800b71 <strncmp+0x3d>
  800b68:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800b6d:	5b                   	pop    %ebx
  800b6e:	5d                   	pop    %ebp
  800b6f:	90                   	nop
  800b70:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b71:	0f b6 02             	movzbl (%edx),%eax
  800b74:	0f b6 11             	movzbl (%ecx),%edx
  800b77:	29 d0                	sub    %edx,%eax
  800b79:	eb f2                	jmp    800b6d <strncmp+0x39>

00800b7b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b7b:	55                   	push   %ebp
  800b7c:	89 e5                	mov    %esp,%ebp
  800b7e:	8b 45 08             	mov    0x8(%ebp),%eax
  800b81:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b85:	0f b6 10             	movzbl (%eax),%edx
  800b88:	84 d2                	test   %dl,%dl
  800b8a:	74 18                	je     800ba4 <strchr+0x29>
		if (*s == c)
  800b8c:	38 ca                	cmp    %cl,%dl
  800b8e:	75 0a                	jne    800b9a <strchr+0x1f>
  800b90:	eb 17                	jmp    800ba9 <strchr+0x2e>
  800b92:	38 ca                	cmp    %cl,%dl
  800b94:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800b98:	74 0f                	je     800ba9 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b9a:	83 c0 01             	add    $0x1,%eax
  800b9d:	0f b6 10             	movzbl (%eax),%edx
  800ba0:	84 d2                	test   %dl,%dl
  800ba2:	75 ee                	jne    800b92 <strchr+0x17>
  800ba4:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800ba9:	5d                   	pop    %ebp
  800baa:	c3                   	ret    

00800bab <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800bab:	55                   	push   %ebp
  800bac:	89 e5                	mov    %esp,%ebp
  800bae:	8b 45 08             	mov    0x8(%ebp),%eax
  800bb1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800bb5:	0f b6 10             	movzbl (%eax),%edx
  800bb8:	84 d2                	test   %dl,%dl
  800bba:	74 18                	je     800bd4 <strfind+0x29>
		if (*s == c)
  800bbc:	38 ca                	cmp    %cl,%dl
  800bbe:	75 0a                	jne    800bca <strfind+0x1f>
  800bc0:	eb 12                	jmp    800bd4 <strfind+0x29>
  800bc2:	38 ca                	cmp    %cl,%dl
  800bc4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800bc8:	74 0a                	je     800bd4 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800bca:	83 c0 01             	add    $0x1,%eax
  800bcd:	0f b6 10             	movzbl (%eax),%edx
  800bd0:	84 d2                	test   %dl,%dl
  800bd2:	75 ee                	jne    800bc2 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800bd4:	5d                   	pop    %ebp
  800bd5:	c3                   	ret    

00800bd6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800bd6:	55                   	push   %ebp
  800bd7:	89 e5                	mov    %esp,%ebp
  800bd9:	83 ec 0c             	sub    $0xc,%esp
  800bdc:	89 1c 24             	mov    %ebx,(%esp)
  800bdf:	89 74 24 04          	mov    %esi,0x4(%esp)
  800be3:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800be7:	8b 7d 08             	mov    0x8(%ebp),%edi
  800bea:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bed:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800bf0:	85 c9                	test   %ecx,%ecx
  800bf2:	74 30                	je     800c24 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800bf4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800bfa:	75 25                	jne    800c21 <memset+0x4b>
  800bfc:	f6 c1 03             	test   $0x3,%cl
  800bff:	75 20                	jne    800c21 <memset+0x4b>
		c &= 0xFF;
  800c01:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800c04:	89 d3                	mov    %edx,%ebx
  800c06:	c1 e3 08             	shl    $0x8,%ebx
  800c09:	89 d6                	mov    %edx,%esi
  800c0b:	c1 e6 18             	shl    $0x18,%esi
  800c0e:	89 d0                	mov    %edx,%eax
  800c10:	c1 e0 10             	shl    $0x10,%eax
  800c13:	09 f0                	or     %esi,%eax
  800c15:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  800c17:	09 d8                	or     %ebx,%eax
  800c19:	c1 e9 02             	shr    $0x2,%ecx
  800c1c:	fc                   	cld    
  800c1d:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800c1f:	eb 03                	jmp    800c24 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c21:	fc                   	cld    
  800c22:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800c24:	89 f8                	mov    %edi,%eax
  800c26:	8b 1c 24             	mov    (%esp),%ebx
  800c29:	8b 74 24 04          	mov    0x4(%esp),%esi
  800c2d:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800c31:	89 ec                	mov    %ebp,%esp
  800c33:	5d                   	pop    %ebp
  800c34:	c3                   	ret    

00800c35 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c35:	55                   	push   %ebp
  800c36:	89 e5                	mov    %esp,%ebp
  800c38:	83 ec 08             	sub    $0x8,%esp
  800c3b:	89 34 24             	mov    %esi,(%esp)
  800c3e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800c42:	8b 45 08             	mov    0x8(%ebp),%eax
  800c45:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800c48:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800c4b:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800c4d:	39 c6                	cmp    %eax,%esi
  800c4f:	73 35                	jae    800c86 <memmove+0x51>
  800c51:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c54:	39 d0                	cmp    %edx,%eax
  800c56:	73 2e                	jae    800c86 <memmove+0x51>
		s += n;
		d += n;
  800c58:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c5a:	f6 c2 03             	test   $0x3,%dl
  800c5d:	75 1b                	jne    800c7a <memmove+0x45>
  800c5f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c65:	75 13                	jne    800c7a <memmove+0x45>
  800c67:	f6 c1 03             	test   $0x3,%cl
  800c6a:	75 0e                	jne    800c7a <memmove+0x45>
			asm volatile("std; rep movsl\n"
  800c6c:	83 ef 04             	sub    $0x4,%edi
  800c6f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c72:	c1 e9 02             	shr    $0x2,%ecx
  800c75:	fd                   	std    
  800c76:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c78:	eb 09                	jmp    800c83 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800c7a:	83 ef 01             	sub    $0x1,%edi
  800c7d:	8d 72 ff             	lea    -0x1(%edx),%esi
  800c80:	fd                   	std    
  800c81:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c83:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c84:	eb 20                	jmp    800ca6 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c86:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c8c:	75 15                	jne    800ca3 <memmove+0x6e>
  800c8e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c94:	75 0d                	jne    800ca3 <memmove+0x6e>
  800c96:	f6 c1 03             	test   $0x3,%cl
  800c99:	75 08                	jne    800ca3 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  800c9b:	c1 e9 02             	shr    $0x2,%ecx
  800c9e:	fc                   	cld    
  800c9f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ca1:	eb 03                	jmp    800ca6 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800ca3:	fc                   	cld    
  800ca4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ca6:	8b 34 24             	mov    (%esp),%esi
  800ca9:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800cad:	89 ec                	mov    %ebp,%esp
  800caf:	5d                   	pop    %ebp
  800cb0:	c3                   	ret    

00800cb1 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800cb1:	55                   	push   %ebp
  800cb2:	89 e5                	mov    %esp,%ebp
  800cb4:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800cb7:	8b 45 10             	mov    0x10(%ebp),%eax
  800cba:	89 44 24 08          	mov    %eax,0x8(%esp)
  800cbe:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cc1:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cc5:	8b 45 08             	mov    0x8(%ebp),%eax
  800cc8:	89 04 24             	mov    %eax,(%esp)
  800ccb:	e8 65 ff ff ff       	call   800c35 <memmove>
}
  800cd0:	c9                   	leave  
  800cd1:	c3                   	ret    

00800cd2 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800cd2:	55                   	push   %ebp
  800cd3:	89 e5                	mov    %esp,%ebp
  800cd5:	57                   	push   %edi
  800cd6:	56                   	push   %esi
  800cd7:	53                   	push   %ebx
  800cd8:	8b 75 08             	mov    0x8(%ebp),%esi
  800cdb:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800cde:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ce1:	85 c9                	test   %ecx,%ecx
  800ce3:	74 36                	je     800d1b <memcmp+0x49>
		if (*s1 != *s2)
  800ce5:	0f b6 06             	movzbl (%esi),%eax
  800ce8:	0f b6 1f             	movzbl (%edi),%ebx
  800ceb:	38 d8                	cmp    %bl,%al
  800ced:	74 20                	je     800d0f <memcmp+0x3d>
  800cef:	eb 14                	jmp    800d05 <memcmp+0x33>
  800cf1:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  800cf6:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  800cfb:	83 c2 01             	add    $0x1,%edx
  800cfe:	83 e9 01             	sub    $0x1,%ecx
  800d01:	38 d8                	cmp    %bl,%al
  800d03:	74 12                	je     800d17 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  800d05:	0f b6 c0             	movzbl %al,%eax
  800d08:	0f b6 db             	movzbl %bl,%ebx
  800d0b:	29 d8                	sub    %ebx,%eax
  800d0d:	eb 11                	jmp    800d20 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d0f:	83 e9 01             	sub    $0x1,%ecx
  800d12:	ba 00 00 00 00       	mov    $0x0,%edx
  800d17:	85 c9                	test   %ecx,%ecx
  800d19:	75 d6                	jne    800cf1 <memcmp+0x1f>
  800d1b:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800d20:	5b                   	pop    %ebx
  800d21:	5e                   	pop    %esi
  800d22:	5f                   	pop    %edi
  800d23:	5d                   	pop    %ebp
  800d24:	c3                   	ret    

00800d25 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800d25:	55                   	push   %ebp
  800d26:	89 e5                	mov    %esp,%ebp
  800d28:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800d2b:	89 c2                	mov    %eax,%edx
  800d2d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800d30:	39 d0                	cmp    %edx,%eax
  800d32:	73 15                	jae    800d49 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d34:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800d38:	38 08                	cmp    %cl,(%eax)
  800d3a:	75 06                	jne    800d42 <memfind+0x1d>
  800d3c:	eb 0b                	jmp    800d49 <memfind+0x24>
  800d3e:	38 08                	cmp    %cl,(%eax)
  800d40:	74 07                	je     800d49 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d42:	83 c0 01             	add    $0x1,%eax
  800d45:	39 c2                	cmp    %eax,%edx
  800d47:	77 f5                	ja     800d3e <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800d49:	5d                   	pop    %ebp
  800d4a:	c3                   	ret    

00800d4b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d4b:	55                   	push   %ebp
  800d4c:	89 e5                	mov    %esp,%ebp
  800d4e:	57                   	push   %edi
  800d4f:	56                   	push   %esi
  800d50:	53                   	push   %ebx
  800d51:	83 ec 04             	sub    $0x4,%esp
  800d54:	8b 55 08             	mov    0x8(%ebp),%edx
  800d57:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d5a:	0f b6 02             	movzbl (%edx),%eax
  800d5d:	3c 20                	cmp    $0x20,%al
  800d5f:	74 04                	je     800d65 <strtol+0x1a>
  800d61:	3c 09                	cmp    $0x9,%al
  800d63:	75 0e                	jne    800d73 <strtol+0x28>
		s++;
  800d65:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d68:	0f b6 02             	movzbl (%edx),%eax
  800d6b:	3c 20                	cmp    $0x20,%al
  800d6d:	74 f6                	je     800d65 <strtol+0x1a>
  800d6f:	3c 09                	cmp    $0x9,%al
  800d71:	74 f2                	je     800d65 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800d73:	3c 2b                	cmp    $0x2b,%al
  800d75:	75 0c                	jne    800d83 <strtol+0x38>
		s++;
  800d77:	83 c2 01             	add    $0x1,%edx
  800d7a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800d81:	eb 15                	jmp    800d98 <strtol+0x4d>
	else if (*s == '-')
  800d83:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800d8a:	3c 2d                	cmp    $0x2d,%al
  800d8c:	75 0a                	jne    800d98 <strtol+0x4d>
		s++, neg = 1;
  800d8e:	83 c2 01             	add    $0x1,%edx
  800d91:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d98:	85 db                	test   %ebx,%ebx
  800d9a:	0f 94 c0             	sete   %al
  800d9d:	74 05                	je     800da4 <strtol+0x59>
  800d9f:	83 fb 10             	cmp    $0x10,%ebx
  800da2:	75 18                	jne    800dbc <strtol+0x71>
  800da4:	80 3a 30             	cmpb   $0x30,(%edx)
  800da7:	75 13                	jne    800dbc <strtol+0x71>
  800da9:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800dad:	8d 76 00             	lea    0x0(%esi),%esi
  800db0:	75 0a                	jne    800dbc <strtol+0x71>
		s += 2, base = 16;
  800db2:	83 c2 02             	add    $0x2,%edx
  800db5:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800dba:	eb 15                	jmp    800dd1 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800dbc:	84 c0                	test   %al,%al
  800dbe:	66 90                	xchg   %ax,%ax
  800dc0:	74 0f                	je     800dd1 <strtol+0x86>
  800dc2:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800dc7:	80 3a 30             	cmpb   $0x30,(%edx)
  800dca:	75 05                	jne    800dd1 <strtol+0x86>
		s++, base = 8;
  800dcc:	83 c2 01             	add    $0x1,%edx
  800dcf:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800dd1:	b8 00 00 00 00       	mov    $0x0,%eax
  800dd6:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800dd8:	0f b6 0a             	movzbl (%edx),%ecx
  800ddb:	89 cf                	mov    %ecx,%edi
  800ddd:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800de0:	80 fb 09             	cmp    $0x9,%bl
  800de3:	77 08                	ja     800ded <strtol+0xa2>
			dig = *s - '0';
  800de5:	0f be c9             	movsbl %cl,%ecx
  800de8:	83 e9 30             	sub    $0x30,%ecx
  800deb:	eb 1e                	jmp    800e0b <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  800ded:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  800df0:	80 fb 19             	cmp    $0x19,%bl
  800df3:	77 08                	ja     800dfd <strtol+0xb2>
			dig = *s - 'a' + 10;
  800df5:	0f be c9             	movsbl %cl,%ecx
  800df8:	83 e9 57             	sub    $0x57,%ecx
  800dfb:	eb 0e                	jmp    800e0b <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  800dfd:	8d 5f bf             	lea    -0x41(%edi),%ebx
  800e00:	80 fb 19             	cmp    $0x19,%bl
  800e03:	77 15                	ja     800e1a <strtol+0xcf>
			dig = *s - 'A' + 10;
  800e05:	0f be c9             	movsbl %cl,%ecx
  800e08:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800e0b:	39 f1                	cmp    %esi,%ecx
  800e0d:	7d 0b                	jge    800e1a <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  800e0f:	83 c2 01             	add    $0x1,%edx
  800e12:	0f af c6             	imul   %esi,%eax
  800e15:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800e18:	eb be                	jmp    800dd8 <strtol+0x8d>
  800e1a:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800e1c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e20:	74 05                	je     800e27 <strtol+0xdc>
		*endptr = (char *) s;
  800e22:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800e25:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800e27:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800e2b:	74 04                	je     800e31 <strtol+0xe6>
  800e2d:	89 c8                	mov    %ecx,%eax
  800e2f:	f7 d8                	neg    %eax
}
  800e31:	83 c4 04             	add    $0x4,%esp
  800e34:	5b                   	pop    %ebx
  800e35:	5e                   	pop    %esi
  800e36:	5f                   	pop    %edi
  800e37:	5d                   	pop    %ebp
  800e38:	c3                   	ret    
  800e39:	00 00                	add    %al,(%eax)
	...

00800e3c <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  800e3c:	55                   	push   %ebp
  800e3d:	89 e5                	mov    %esp,%ebp
  800e3f:	83 ec 08             	sub    $0x8,%esp
  800e42:	89 1c 24             	mov    %ebx,(%esp)
  800e45:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800e49:	ba 00 00 00 00       	mov    $0x0,%edx
  800e4e:	b8 01 00 00 00       	mov    $0x1,%eax
  800e53:	89 d1                	mov    %edx,%ecx
  800e55:	89 d3                	mov    %edx,%ebx
  800e57:	89 d7                	mov    %edx,%edi
  800e59:	51                   	push   %ecx
  800e5a:	52                   	push   %edx
  800e5b:	53                   	push   %ebx
  800e5c:	54                   	push   %esp
  800e5d:	55                   	push   %ebp
  800e5e:	56                   	push   %esi
  800e5f:	57                   	push   %edi
  800e60:	54                   	push   %esp
  800e61:	5d                   	pop    %ebp
  800e62:	8d 35 6a 0e 80 00    	lea    0x800e6a,%esi
  800e68:	0f 34                	sysenter 
  800e6a:	5f                   	pop    %edi
  800e6b:	5e                   	pop    %esi
  800e6c:	5d                   	pop    %ebp
  800e6d:	5c                   	pop    %esp
  800e6e:	5b                   	pop    %ebx
  800e6f:	5a                   	pop    %edx
  800e70:	59                   	pop    %ecx

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800e71:	8b 1c 24             	mov    (%esp),%ebx
  800e74:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800e78:	89 ec                	mov    %ebp,%esp
  800e7a:	5d                   	pop    %ebp
  800e7b:	c3                   	ret    

00800e7c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
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
  800e89:	b8 00 00 00 00       	mov    $0x0,%eax
  800e8e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e91:	8b 55 08             	mov    0x8(%ebp),%edx
  800e94:	89 c3                	mov    %eax,%ebx
  800e96:	89 c7                	mov    %eax,%edi
  800e98:	51                   	push   %ecx
  800e99:	52                   	push   %edx
  800e9a:	53                   	push   %ebx
  800e9b:	54                   	push   %esp
  800e9c:	55                   	push   %ebp
  800e9d:	56                   	push   %esi
  800e9e:	57                   	push   %edi
  800e9f:	54                   	push   %esp
  800ea0:	5d                   	pop    %ebp
  800ea1:	8d 35 a9 0e 80 00    	lea    0x800ea9,%esi
  800ea7:	0f 34                	sysenter 
  800ea9:	5f                   	pop    %edi
  800eaa:	5e                   	pop    %esi
  800eab:	5d                   	pop    %ebp
  800eac:	5c                   	pop    %esp
  800ead:	5b                   	pop    %ebx
  800eae:	5a                   	pop    %edx
  800eaf:	59                   	pop    %ecx

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800eb0:	8b 1c 24             	mov    (%esp),%ebx
  800eb3:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800eb7:	89 ec                	mov    %ebp,%esp
  800eb9:	5d                   	pop    %ebp
  800eba:	c3                   	ret    

00800ebb <sys_env_set_prior>:
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}

int 
sys_env_set_prior(envid_t envid, uint32_t prior){
  800ebb:	55                   	push   %ebp
  800ebc:	89 e5                	mov    %esp,%ebp
  800ebe:	83 ec 28             	sub    $0x28,%esp
  800ec1:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800ec4:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800ec7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ecc:	b8 0e 00 00 00       	mov    $0xe,%eax
  800ed1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ed4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ed7:	89 df                	mov    %ebx,%edi
  800ed9:	51                   	push   %ecx
  800eda:	52                   	push   %edx
  800edb:	53                   	push   %ebx
  800edc:	54                   	push   %esp
  800edd:	55                   	push   %ebp
  800ede:	56                   	push   %esi
  800edf:	57                   	push   %edi
  800ee0:	54                   	push   %esp
  800ee1:	5d                   	pop    %ebp
  800ee2:	8d 35 ea 0e 80 00    	lea    0x800eea,%esi
  800ee8:	0f 34                	sysenter 
  800eea:	5f                   	pop    %edi
  800eeb:	5e                   	pop    %esi
  800eec:	5d                   	pop    %ebp
  800eed:	5c                   	pop    %esp
  800eee:	5b                   	pop    %ebx
  800eef:	5a                   	pop    %edx
  800ef0:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  800ef1:	85 c0                	test   %eax,%eax
  800ef3:	7e 28                	jle    800f1d <sys_env_set_prior+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ef5:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ef9:	c7 44 24 0c 0e 00 00 	movl   $0xe,0xc(%esp)
  800f00:	00 
  800f01:	c7 44 24 08 24 19 80 	movl   $0x801924,0x8(%esp)
  800f08:	00 
  800f09:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  800f10:	00 
  800f11:	c7 04 24 41 19 80 00 	movl   $0x801941,(%esp)
  800f18:	e8 43 04 00 00       	call   801360 <_panic>
}

int 
sys_env_set_prior(envid_t envid, uint32_t prior){
         return syscall(SYS_env_set_prior,1,envid, prior, 0, 0, 0);
}
  800f1d:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800f20:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f23:	89 ec                	mov    %ebp,%esp
  800f25:	5d                   	pop    %ebp
  800f26:	c3                   	ret    

00800f27 <sys_sbrk>:
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}

int
sys_sbrk(uint32_t inc)
{
  800f27:	55                   	push   %ebp
  800f28:	89 e5                	mov    %esp,%ebp
  800f2a:	83 ec 08             	sub    $0x8,%esp
  800f2d:	89 1c 24             	mov    %ebx,(%esp)
  800f30:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800f34:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f39:	b8 0f 00 00 00       	mov    $0xf,%eax
  800f3e:	8b 55 08             	mov    0x8(%ebp),%edx
  800f41:	89 cb                	mov    %ecx,%ebx
  800f43:	89 cf                	mov    %ecx,%edi
  800f45:	51                   	push   %ecx
  800f46:	52                   	push   %edx
  800f47:	53                   	push   %ebx
  800f48:	54                   	push   %esp
  800f49:	55                   	push   %ebp
  800f4a:	56                   	push   %esi
  800f4b:	57                   	push   %edi
  800f4c:	54                   	push   %esp
  800f4d:	5d                   	pop    %ebp
  800f4e:	8d 35 56 0f 80 00    	lea    0x800f56,%esi
  800f54:	0f 34                	sysenter 
  800f56:	5f                   	pop    %edi
  800f57:	5e                   	pop    %esi
  800f58:	5d                   	pop    %ebp
  800f59:	5c                   	pop    %esp
  800f5a:	5b                   	pop    %ebx
  800f5b:	5a                   	pop    %edx
  800f5c:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  800f5d:	8b 1c 24             	mov    (%esp),%ebx
  800f60:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800f64:	89 ec                	mov    %ebp,%esp
  800f66:	5d                   	pop    %ebp
  800f67:	c3                   	ret    

00800f68 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800f68:	55                   	push   %ebp
  800f69:	89 e5                	mov    %esp,%ebp
  800f6b:	83 ec 28             	sub    $0x28,%esp
  800f6e:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800f71:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800f74:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f79:	b8 0d 00 00 00       	mov    $0xd,%eax
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
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  800f9d:	85 c0                	test   %eax,%eax
  800f9f:	7e 28                	jle    800fc9 <sys_ipc_recv+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fa1:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fa5:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800fac:	00 
  800fad:	c7 44 24 08 24 19 80 	movl   $0x801924,0x8(%esp)
  800fb4:	00 
  800fb5:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  800fbc:	00 
  800fbd:	c7 04 24 41 19 80 00 	movl   $0x801941,(%esp)
  800fc4:	e8 97 03 00 00       	call   801360 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800fc9:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800fcc:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800fcf:	89 ec                	mov    %ebp,%esp
  800fd1:	5d                   	pop    %ebp
  800fd2:	c3                   	ret    

00800fd3 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800fd3:	55                   	push   %ebp
  800fd4:	89 e5                	mov    %esp,%ebp
  800fd6:	83 ec 08             	sub    $0x8,%esp
  800fd9:	89 1c 24             	mov    %ebx,(%esp)
  800fdc:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800fe0:	b8 0c 00 00 00       	mov    $0xc,%eax
  800fe5:	8b 7d 14             	mov    0x14(%ebp),%edi
  800fe8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800feb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fee:	8b 55 08             	mov    0x8(%ebp),%edx
  800ff1:	51                   	push   %ecx
  800ff2:	52                   	push   %edx
  800ff3:	53                   	push   %ebx
  800ff4:	54                   	push   %esp
  800ff5:	55                   	push   %ebp
  800ff6:	56                   	push   %esi
  800ff7:	57                   	push   %edi
  800ff8:	54                   	push   %esp
  800ff9:	5d                   	pop    %ebp
  800ffa:	8d 35 02 10 80 00    	lea    0x801002,%esi
  801000:	0f 34                	sysenter 
  801002:	5f                   	pop    %edi
  801003:	5e                   	pop    %esi
  801004:	5d                   	pop    %ebp
  801005:	5c                   	pop    %esp
  801006:	5b                   	pop    %ebx
  801007:	5a                   	pop    %edx
  801008:	59                   	pop    %ecx

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801009:	8b 1c 24             	mov    (%esp),%ebx
  80100c:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801010:	89 ec                	mov    %ebp,%esp
  801012:	5d                   	pop    %ebp
  801013:	c3                   	ret    

00801014 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801014:	55                   	push   %ebp
  801015:	89 e5                	mov    %esp,%ebp
  801017:	83 ec 28             	sub    $0x28,%esp
  80101a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80101d:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801020:	bb 00 00 00 00       	mov    $0x0,%ebx
  801025:	b8 0a 00 00 00       	mov    $0xa,%eax
  80102a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80102d:	8b 55 08             	mov    0x8(%ebp),%edx
  801030:	89 df                	mov    %ebx,%edi
  801032:	51                   	push   %ecx
  801033:	52                   	push   %edx
  801034:	53                   	push   %ebx
  801035:	54                   	push   %esp
  801036:	55                   	push   %ebp
  801037:	56                   	push   %esi
  801038:	57                   	push   %edi
  801039:	54                   	push   %esp
  80103a:	5d                   	pop    %ebp
  80103b:	8d 35 43 10 80 00    	lea    0x801043,%esi
  801041:	0f 34                	sysenter 
  801043:	5f                   	pop    %edi
  801044:	5e                   	pop    %esi
  801045:	5d                   	pop    %ebp
  801046:	5c                   	pop    %esp
  801047:	5b                   	pop    %ebx
  801048:	5a                   	pop    %edx
  801049:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80104a:	85 c0                	test   %eax,%eax
  80104c:	7e 28                	jle    801076 <sys_env_set_pgfault_upcall+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  80104e:	89 44 24 10          	mov    %eax,0x10(%esp)
  801052:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  801059:	00 
  80105a:	c7 44 24 08 24 19 80 	movl   $0x801924,0x8(%esp)
  801061:	00 
  801062:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801069:	00 
  80106a:	c7 04 24 41 19 80 00 	movl   $0x801941,(%esp)
  801071:	e8 ea 02 00 00       	call   801360 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801076:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801079:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80107c:	89 ec                	mov    %ebp,%esp
  80107e:	5d                   	pop    %ebp
  80107f:	c3                   	ret    

00801080 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801080:	55                   	push   %ebp
  801081:	89 e5                	mov    %esp,%ebp
  801083:	83 ec 28             	sub    $0x28,%esp
  801086:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801089:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80108c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801091:	b8 09 00 00 00       	mov    $0x9,%eax
  801096:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801099:	8b 55 08             	mov    0x8(%ebp),%edx
  80109c:	89 df                	mov    %ebx,%edi
  80109e:	51                   	push   %ecx
  80109f:	52                   	push   %edx
  8010a0:	53                   	push   %ebx
  8010a1:	54                   	push   %esp
  8010a2:	55                   	push   %ebp
  8010a3:	56                   	push   %esi
  8010a4:	57                   	push   %edi
  8010a5:	54                   	push   %esp
  8010a6:	5d                   	pop    %ebp
  8010a7:	8d 35 af 10 80 00    	lea    0x8010af,%esi
  8010ad:	0f 34                	sysenter 
  8010af:	5f                   	pop    %edi
  8010b0:	5e                   	pop    %esi
  8010b1:	5d                   	pop    %ebp
  8010b2:	5c                   	pop    %esp
  8010b3:	5b                   	pop    %ebx
  8010b4:	5a                   	pop    %edx
  8010b5:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8010b6:	85 c0                	test   %eax,%eax
  8010b8:	7e 28                	jle    8010e2 <sys_env_set_status+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010ba:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010be:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8010c5:	00 
  8010c6:	c7 44 24 08 24 19 80 	movl   $0x801924,0x8(%esp)
  8010cd:	00 
  8010ce:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8010d5:	00 
  8010d6:	c7 04 24 41 19 80 00 	movl   $0x801941,(%esp)
  8010dd:	e8 7e 02 00 00       	call   801360 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8010e2:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8010e5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8010e8:	89 ec                	mov    %ebp,%esp
  8010ea:	5d                   	pop    %ebp
  8010eb:	c3                   	ret    

008010ec <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  8010ec:	55                   	push   %ebp
  8010ed:	89 e5                	mov    %esp,%ebp
  8010ef:	83 ec 28             	sub    $0x28,%esp
  8010f2:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8010f5:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8010f8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010fd:	b8 07 00 00 00       	mov    $0x7,%eax
  801102:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801105:	8b 55 08             	mov    0x8(%ebp),%edx
  801108:	89 df                	mov    %ebx,%edi
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
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801122:	85 c0                	test   %eax,%eax
  801124:	7e 28                	jle    80114e <sys_page_unmap+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  801126:	89 44 24 10          	mov    %eax,0x10(%esp)
  80112a:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801131:	00 
  801132:	c7 44 24 08 24 19 80 	movl   $0x801924,0x8(%esp)
  801139:	00 
  80113a:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801141:	00 
  801142:	c7 04 24 41 19 80 00 	movl   $0x801941,(%esp)
  801149:	e8 12 02 00 00       	call   801360 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80114e:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801151:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801154:	89 ec                	mov    %ebp,%esp
  801156:	5d                   	pop    %ebp
  801157:	c3                   	ret    

00801158 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  801158:	55                   	push   %ebp
  801159:	89 e5                	mov    %esp,%ebp
  80115b:	83 ec 28             	sub    $0x28,%esp
  80115e:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801161:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801164:	8b 7d 18             	mov    0x18(%ebp),%edi
  801167:	0b 7d 14             	or     0x14(%ebp),%edi
  80116a:	b8 06 00 00 00       	mov    $0x6,%eax
  80116f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801172:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801175:	8b 55 08             	mov    0x8(%ebp),%edx
  801178:	51                   	push   %ecx
  801179:	52                   	push   %edx
  80117a:	53                   	push   %ebx
  80117b:	54                   	push   %esp
  80117c:	55                   	push   %ebp
  80117d:	56                   	push   %esi
  80117e:	57                   	push   %edi
  80117f:	54                   	push   %esp
  801180:	5d                   	pop    %ebp
  801181:	8d 35 89 11 80 00    	lea    0x801189,%esi
  801187:	0f 34                	sysenter 
  801189:	5f                   	pop    %edi
  80118a:	5e                   	pop    %esi
  80118b:	5d                   	pop    %ebp
  80118c:	5c                   	pop    %esp
  80118d:	5b                   	pop    %ebx
  80118e:	5a                   	pop    %edx
  80118f:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801190:	85 c0                	test   %eax,%eax
  801192:	7e 28                	jle    8011bc <sys_page_map+0x64>
		panic("syscall %d returned %d (> 0)", num, ret);
  801194:	89 44 24 10          	mov    %eax,0x10(%esp)
  801198:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  80119f:	00 
  8011a0:	c7 44 24 08 24 19 80 	movl   $0x801924,0x8(%esp)
  8011a7:	00 
  8011a8:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8011af:	00 
  8011b0:	c7 04 24 41 19 80 00 	movl   $0x801941,(%esp)
  8011b7:	e8 a4 01 00 00       	call   801360 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}
  8011bc:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8011bf:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8011c2:	89 ec                	mov    %ebp,%esp
  8011c4:	5d                   	pop    %ebp
  8011c5:	c3                   	ret    

008011c6 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8011c6:	55                   	push   %ebp
  8011c7:	89 e5                	mov    %esp,%ebp
  8011c9:	83 ec 28             	sub    $0x28,%esp
  8011cc:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8011cf:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8011d2:	bf 00 00 00 00       	mov    $0x0,%edi
  8011d7:	b8 05 00 00 00       	mov    $0x5,%eax
  8011dc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8011df:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011e2:	8b 55 08             	mov    0x8(%ebp),%edx
  8011e5:	51                   	push   %ecx
  8011e6:	52                   	push   %edx
  8011e7:	53                   	push   %ebx
  8011e8:	54                   	push   %esp
  8011e9:	55                   	push   %ebp
  8011ea:	56                   	push   %esi
  8011eb:	57                   	push   %edi
  8011ec:	54                   	push   %esp
  8011ed:	5d                   	pop    %ebp
  8011ee:	8d 35 f6 11 80 00    	lea    0x8011f6,%esi
  8011f4:	0f 34                	sysenter 
  8011f6:	5f                   	pop    %edi
  8011f7:	5e                   	pop    %esi
  8011f8:	5d                   	pop    %ebp
  8011f9:	5c                   	pop    %esp
  8011fa:	5b                   	pop    %ebx
  8011fb:	5a                   	pop    %edx
  8011fc:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8011fd:	85 c0                	test   %eax,%eax
  8011ff:	7e 28                	jle    801229 <sys_page_alloc+0x63>
		panic("syscall %d returned %d (> 0)", num, ret);
  801201:	89 44 24 10          	mov    %eax,0x10(%esp)
  801205:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  80120c:	00 
  80120d:	c7 44 24 08 24 19 80 	movl   $0x801924,0x8(%esp)
  801214:	00 
  801215:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80121c:	00 
  80121d:	c7 04 24 41 19 80 00 	movl   $0x801941,(%esp)
  801224:	e8 37 01 00 00       	call   801360 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  801229:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80122c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80122f:	89 ec                	mov    %ebp,%esp
  801231:	5d                   	pop    %ebp
  801232:	c3                   	ret    

00801233 <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
{
  801233:	55                   	push   %ebp
  801234:	89 e5                	mov    %esp,%ebp
  801236:	83 ec 08             	sub    $0x8,%esp
  801239:	89 1c 24             	mov    %ebx,(%esp)
  80123c:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801240:	ba 00 00 00 00       	mov    $0x0,%edx
  801245:	b8 0b 00 00 00       	mov    $0xb,%eax
  80124a:	89 d1                	mov    %edx,%ecx
  80124c:	89 d3                	mov    %edx,%ebx
  80124e:	89 d7                	mov    %edx,%edi
  801250:	51                   	push   %ecx
  801251:	52                   	push   %edx
  801252:	53                   	push   %ebx
  801253:	54                   	push   %esp
  801254:	55                   	push   %ebp
  801255:	56                   	push   %esi
  801256:	57                   	push   %edi
  801257:	54                   	push   %esp
  801258:	5d                   	pop    %ebp
  801259:	8d 35 61 12 80 00    	lea    0x801261,%esi
  80125f:	0f 34                	sysenter 
  801261:	5f                   	pop    %edi
  801262:	5e                   	pop    %esi
  801263:	5d                   	pop    %ebp
  801264:	5c                   	pop    %esp
  801265:	5b                   	pop    %ebx
  801266:	5a                   	pop    %edx
  801267:	59                   	pop    %ecx

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  801268:	8b 1c 24             	mov    (%esp),%ebx
  80126b:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80126f:	89 ec                	mov    %ebp,%esp
  801271:	5d                   	pop    %ebp
  801272:	c3                   	ret    

00801273 <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
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
  801280:	bb 00 00 00 00       	mov    $0x0,%ebx
  801285:	b8 04 00 00 00       	mov    $0x4,%eax
  80128a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80128d:	8b 55 08             	mov    0x8(%ebp),%edx
  801290:	89 df                	mov    %ebx,%edi
  801292:	51                   	push   %ecx
  801293:	52                   	push   %edx
  801294:	53                   	push   %ebx
  801295:	54                   	push   %esp
  801296:	55                   	push   %ebp
  801297:	56                   	push   %esi
  801298:	57                   	push   %edi
  801299:	54                   	push   %esp
  80129a:	5d                   	pop    %ebp
  80129b:	8d 35 a3 12 80 00    	lea    0x8012a3,%esi
  8012a1:	0f 34                	sysenter 
  8012a3:	5f                   	pop    %edi
  8012a4:	5e                   	pop    %esi
  8012a5:	5d                   	pop    %ebp
  8012a6:	5c                   	pop    %esp
  8012a7:	5b                   	pop    %ebx
  8012a8:	5a                   	pop    %edx
  8012a9:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  8012aa:	8b 1c 24             	mov    (%esp),%ebx
  8012ad:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8012b1:	89 ec                	mov    %ebp,%esp
  8012b3:	5d                   	pop    %ebp
  8012b4:	c3                   	ret    

008012b5 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  8012b5:	55                   	push   %ebp
  8012b6:	89 e5                	mov    %esp,%ebp
  8012b8:	83 ec 08             	sub    $0x8,%esp
  8012bb:	89 1c 24             	mov    %ebx,(%esp)
  8012be:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8012c2:	ba 00 00 00 00       	mov    $0x0,%edx
  8012c7:	b8 02 00 00 00       	mov    $0x2,%eax
  8012cc:	89 d1                	mov    %edx,%ecx
  8012ce:	89 d3                	mov    %edx,%ebx
  8012d0:	89 d7                	mov    %edx,%edi
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

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8012ea:	8b 1c 24             	mov    (%esp),%ebx
  8012ed:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8012f1:	89 ec                	mov    %ebp,%esp
  8012f3:	5d                   	pop    %ebp
  8012f4:	c3                   	ret    

008012f5 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  8012f5:	55                   	push   %ebp
  8012f6:	89 e5                	mov    %esp,%ebp
  8012f8:	83 ec 28             	sub    $0x28,%esp
  8012fb:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8012fe:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801301:	b9 00 00 00 00       	mov    $0x0,%ecx
  801306:	b8 03 00 00 00       	mov    $0x3,%eax
  80130b:	8b 55 08             	mov    0x8(%ebp),%edx
  80130e:	89 cb                	mov    %ecx,%ebx
  801310:	89 cf                	mov    %ecx,%edi
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
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80132a:	85 c0                	test   %eax,%eax
  80132c:	7e 28                	jle    801356 <sys_env_destroy+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  80132e:	89 44 24 10          	mov    %eax,0x10(%esp)
  801332:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  801339:	00 
  80133a:	c7 44 24 08 24 19 80 	movl   $0x801924,0x8(%esp)
  801341:	00 
  801342:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801349:	00 
  80134a:	c7 04 24 41 19 80 00 	movl   $0x801941,(%esp)
  801351:	e8 0a 00 00 00       	call   801360 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801356:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801359:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80135c:	89 ec                	mov    %ebp,%esp
  80135e:	5d                   	pop    %ebp
  80135f:	c3                   	ret    

00801360 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801360:	55                   	push   %ebp
  801361:	89 e5                	mov    %esp,%ebp
  801363:	56                   	push   %esi
  801364:	53                   	push   %ebx
  801365:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  801368:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	if (argv0)
  80136b:	a1 08 20 80 00       	mov    0x802008,%eax
  801370:	85 c0                	test   %eax,%eax
  801372:	74 10                	je     801384 <_panic+0x24>
		cprintf("%s: ", argv0);
  801374:	89 44 24 04          	mov    %eax,0x4(%esp)
  801378:	c7 04 24 4f 19 80 00 	movl   $0x80194f,(%esp)
  80137f:	e8 99 ed ff ff       	call   80011d <cprintf>
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801384:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  80138a:	e8 26 ff ff ff       	call   8012b5 <sys_getenvid>
  80138f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801392:	89 54 24 10          	mov    %edx,0x10(%esp)
  801396:	8b 55 08             	mov    0x8(%ebp),%edx
  801399:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80139d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8013a1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013a5:	c7 04 24 54 19 80 00 	movl   $0x801954,(%esp)
  8013ac:	e8 6c ed ff ff       	call   80011d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8013b1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8013b5:	8b 45 10             	mov    0x10(%ebp),%eax
  8013b8:	89 04 24             	mov    %eax,(%esp)
  8013bb:	e8 fc ec ff ff       	call   8000bc <vcprintf>
	cprintf("\n");
  8013c0:	c7 04 24 5c 16 80 00 	movl   $0x80165c,(%esp)
  8013c7:	e8 51 ed ff ff       	call   80011d <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8013cc:	cc                   	int3   
  8013cd:	eb fd                	jmp    8013cc <_panic+0x6c>
	...

008013d0 <__udivdi3>:
  8013d0:	55                   	push   %ebp
  8013d1:	89 e5                	mov    %esp,%ebp
  8013d3:	57                   	push   %edi
  8013d4:	56                   	push   %esi
  8013d5:	83 ec 10             	sub    $0x10,%esp
  8013d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8013db:	8b 55 08             	mov    0x8(%ebp),%edx
  8013de:	8b 75 10             	mov    0x10(%ebp),%esi
  8013e1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8013e4:	85 c0                	test   %eax,%eax
  8013e6:	89 55 f0             	mov    %edx,-0x10(%ebp)
  8013e9:	75 35                	jne    801420 <__udivdi3+0x50>
  8013eb:	39 fe                	cmp    %edi,%esi
  8013ed:	77 61                	ja     801450 <__udivdi3+0x80>
  8013ef:	85 f6                	test   %esi,%esi
  8013f1:	75 0b                	jne    8013fe <__udivdi3+0x2e>
  8013f3:	b8 01 00 00 00       	mov    $0x1,%eax
  8013f8:	31 d2                	xor    %edx,%edx
  8013fa:	f7 f6                	div    %esi
  8013fc:	89 c6                	mov    %eax,%esi
  8013fe:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  801401:	31 d2                	xor    %edx,%edx
  801403:	89 f8                	mov    %edi,%eax
  801405:	f7 f6                	div    %esi
  801407:	89 c7                	mov    %eax,%edi
  801409:	89 c8                	mov    %ecx,%eax
  80140b:	f7 f6                	div    %esi
  80140d:	89 c1                	mov    %eax,%ecx
  80140f:	89 fa                	mov    %edi,%edx
  801411:	89 c8                	mov    %ecx,%eax
  801413:	83 c4 10             	add    $0x10,%esp
  801416:	5e                   	pop    %esi
  801417:	5f                   	pop    %edi
  801418:	5d                   	pop    %ebp
  801419:	c3                   	ret    
  80141a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801420:	39 f8                	cmp    %edi,%eax
  801422:	77 1c                	ja     801440 <__udivdi3+0x70>
  801424:	0f bd d0             	bsr    %eax,%edx
  801427:	83 f2 1f             	xor    $0x1f,%edx
  80142a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80142d:	75 39                	jne    801468 <__udivdi3+0x98>
  80142f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  801432:	0f 86 a0 00 00 00    	jbe    8014d8 <__udivdi3+0x108>
  801438:	39 f8                	cmp    %edi,%eax
  80143a:	0f 82 98 00 00 00    	jb     8014d8 <__udivdi3+0x108>
  801440:	31 ff                	xor    %edi,%edi
  801442:	31 c9                	xor    %ecx,%ecx
  801444:	89 c8                	mov    %ecx,%eax
  801446:	89 fa                	mov    %edi,%edx
  801448:	83 c4 10             	add    $0x10,%esp
  80144b:	5e                   	pop    %esi
  80144c:	5f                   	pop    %edi
  80144d:	5d                   	pop    %ebp
  80144e:	c3                   	ret    
  80144f:	90                   	nop
  801450:	89 d1                	mov    %edx,%ecx
  801452:	89 fa                	mov    %edi,%edx
  801454:	89 c8                	mov    %ecx,%eax
  801456:	31 ff                	xor    %edi,%edi
  801458:	f7 f6                	div    %esi
  80145a:	89 c1                	mov    %eax,%ecx
  80145c:	89 fa                	mov    %edi,%edx
  80145e:	89 c8                	mov    %ecx,%eax
  801460:	83 c4 10             	add    $0x10,%esp
  801463:	5e                   	pop    %esi
  801464:	5f                   	pop    %edi
  801465:	5d                   	pop    %ebp
  801466:	c3                   	ret    
  801467:	90                   	nop
  801468:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80146c:	89 f2                	mov    %esi,%edx
  80146e:	d3 e0                	shl    %cl,%eax
  801470:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801473:	b8 20 00 00 00       	mov    $0x20,%eax
  801478:	2b 45 f4             	sub    -0xc(%ebp),%eax
  80147b:	89 c1                	mov    %eax,%ecx
  80147d:	d3 ea                	shr    %cl,%edx
  80147f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801483:	0b 55 ec             	or     -0x14(%ebp),%edx
  801486:	d3 e6                	shl    %cl,%esi
  801488:	89 c1                	mov    %eax,%ecx
  80148a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  80148d:	89 fe                	mov    %edi,%esi
  80148f:	d3 ee                	shr    %cl,%esi
  801491:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801495:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801498:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80149b:	d3 e7                	shl    %cl,%edi
  80149d:	89 c1                	mov    %eax,%ecx
  80149f:	d3 ea                	shr    %cl,%edx
  8014a1:	09 d7                	or     %edx,%edi
  8014a3:	89 f2                	mov    %esi,%edx
  8014a5:	89 f8                	mov    %edi,%eax
  8014a7:	f7 75 ec             	divl   -0x14(%ebp)
  8014aa:	89 d6                	mov    %edx,%esi
  8014ac:	89 c7                	mov    %eax,%edi
  8014ae:	f7 65 e8             	mull   -0x18(%ebp)
  8014b1:	39 d6                	cmp    %edx,%esi
  8014b3:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8014b6:	72 30                	jb     8014e8 <__udivdi3+0x118>
  8014b8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8014bb:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8014bf:	d3 e2                	shl    %cl,%edx
  8014c1:	39 c2                	cmp    %eax,%edx
  8014c3:	73 05                	jae    8014ca <__udivdi3+0xfa>
  8014c5:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  8014c8:	74 1e                	je     8014e8 <__udivdi3+0x118>
  8014ca:	89 f9                	mov    %edi,%ecx
  8014cc:	31 ff                	xor    %edi,%edi
  8014ce:	e9 71 ff ff ff       	jmp    801444 <__udivdi3+0x74>
  8014d3:	90                   	nop
  8014d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8014d8:	31 ff                	xor    %edi,%edi
  8014da:	b9 01 00 00 00       	mov    $0x1,%ecx
  8014df:	e9 60 ff ff ff       	jmp    801444 <__udivdi3+0x74>
  8014e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8014e8:	8d 4f ff             	lea    -0x1(%edi),%ecx
  8014eb:	31 ff                	xor    %edi,%edi
  8014ed:	89 c8                	mov    %ecx,%eax
  8014ef:	89 fa                	mov    %edi,%edx
  8014f1:	83 c4 10             	add    $0x10,%esp
  8014f4:	5e                   	pop    %esi
  8014f5:	5f                   	pop    %edi
  8014f6:	5d                   	pop    %ebp
  8014f7:	c3                   	ret    
	...

00801500 <__umoddi3>:
  801500:	55                   	push   %ebp
  801501:	89 e5                	mov    %esp,%ebp
  801503:	57                   	push   %edi
  801504:	56                   	push   %esi
  801505:	83 ec 20             	sub    $0x20,%esp
  801508:	8b 55 14             	mov    0x14(%ebp),%edx
  80150b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80150e:	8b 7d 10             	mov    0x10(%ebp),%edi
  801511:	8b 75 0c             	mov    0xc(%ebp),%esi
  801514:	85 d2                	test   %edx,%edx
  801516:	89 c8                	mov    %ecx,%eax
  801518:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80151b:	75 13                	jne    801530 <__umoddi3+0x30>
  80151d:	39 f7                	cmp    %esi,%edi
  80151f:	76 3f                	jbe    801560 <__umoddi3+0x60>
  801521:	89 f2                	mov    %esi,%edx
  801523:	f7 f7                	div    %edi
  801525:	89 d0                	mov    %edx,%eax
  801527:	31 d2                	xor    %edx,%edx
  801529:	83 c4 20             	add    $0x20,%esp
  80152c:	5e                   	pop    %esi
  80152d:	5f                   	pop    %edi
  80152e:	5d                   	pop    %ebp
  80152f:	c3                   	ret    
  801530:	39 f2                	cmp    %esi,%edx
  801532:	77 4c                	ja     801580 <__umoddi3+0x80>
  801534:	0f bd ca             	bsr    %edx,%ecx
  801537:	83 f1 1f             	xor    $0x1f,%ecx
  80153a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80153d:	75 51                	jne    801590 <__umoddi3+0x90>
  80153f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  801542:	0f 87 e0 00 00 00    	ja     801628 <__umoddi3+0x128>
  801548:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80154b:	29 f8                	sub    %edi,%eax
  80154d:	19 d6                	sbb    %edx,%esi
  80154f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801552:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801555:	89 f2                	mov    %esi,%edx
  801557:	83 c4 20             	add    $0x20,%esp
  80155a:	5e                   	pop    %esi
  80155b:	5f                   	pop    %edi
  80155c:	5d                   	pop    %ebp
  80155d:	c3                   	ret    
  80155e:	66 90                	xchg   %ax,%ax
  801560:	85 ff                	test   %edi,%edi
  801562:	75 0b                	jne    80156f <__umoddi3+0x6f>
  801564:	b8 01 00 00 00       	mov    $0x1,%eax
  801569:	31 d2                	xor    %edx,%edx
  80156b:	f7 f7                	div    %edi
  80156d:	89 c7                	mov    %eax,%edi
  80156f:	89 f0                	mov    %esi,%eax
  801571:	31 d2                	xor    %edx,%edx
  801573:	f7 f7                	div    %edi
  801575:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801578:	f7 f7                	div    %edi
  80157a:	eb a9                	jmp    801525 <__umoddi3+0x25>
  80157c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801580:	89 c8                	mov    %ecx,%eax
  801582:	89 f2                	mov    %esi,%edx
  801584:	83 c4 20             	add    $0x20,%esp
  801587:	5e                   	pop    %esi
  801588:	5f                   	pop    %edi
  801589:	5d                   	pop    %ebp
  80158a:	c3                   	ret    
  80158b:	90                   	nop
  80158c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801590:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801594:	d3 e2                	shl    %cl,%edx
  801596:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801599:	ba 20 00 00 00       	mov    $0x20,%edx
  80159e:	2b 55 f0             	sub    -0x10(%ebp),%edx
  8015a1:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8015a4:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8015a8:	89 fa                	mov    %edi,%edx
  8015aa:	d3 ea                	shr    %cl,%edx
  8015ac:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8015b0:	0b 55 f4             	or     -0xc(%ebp),%edx
  8015b3:	d3 e7                	shl    %cl,%edi
  8015b5:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8015b9:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8015bc:	89 f2                	mov    %esi,%edx
  8015be:	89 7d e8             	mov    %edi,-0x18(%ebp)
  8015c1:	89 c7                	mov    %eax,%edi
  8015c3:	d3 ea                	shr    %cl,%edx
  8015c5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8015c9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8015cc:	89 c2                	mov    %eax,%edx
  8015ce:	d3 e6                	shl    %cl,%esi
  8015d0:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8015d4:	d3 ea                	shr    %cl,%edx
  8015d6:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8015da:	09 d6                	or     %edx,%esi
  8015dc:	89 f0                	mov    %esi,%eax
  8015de:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8015e1:	d3 e7                	shl    %cl,%edi
  8015e3:	89 f2                	mov    %esi,%edx
  8015e5:	f7 75 f4             	divl   -0xc(%ebp)
  8015e8:	89 d6                	mov    %edx,%esi
  8015ea:	f7 65 e8             	mull   -0x18(%ebp)
  8015ed:	39 d6                	cmp    %edx,%esi
  8015ef:	72 2b                	jb     80161c <__umoddi3+0x11c>
  8015f1:	39 c7                	cmp    %eax,%edi
  8015f3:	72 23                	jb     801618 <__umoddi3+0x118>
  8015f5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8015f9:	29 c7                	sub    %eax,%edi
  8015fb:	19 d6                	sbb    %edx,%esi
  8015fd:	89 f0                	mov    %esi,%eax
  8015ff:	89 f2                	mov    %esi,%edx
  801601:	d3 ef                	shr    %cl,%edi
  801603:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801607:	d3 e0                	shl    %cl,%eax
  801609:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80160d:	09 f8                	or     %edi,%eax
  80160f:	d3 ea                	shr    %cl,%edx
  801611:	83 c4 20             	add    $0x20,%esp
  801614:	5e                   	pop    %esi
  801615:	5f                   	pop    %edi
  801616:	5d                   	pop    %ebp
  801617:	c3                   	ret    
  801618:	39 d6                	cmp    %edx,%esi
  80161a:	75 d9                	jne    8015f5 <__umoddi3+0xf5>
  80161c:	2b 45 e8             	sub    -0x18(%ebp),%eax
  80161f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  801622:	eb d1                	jmp    8015f5 <__umoddi3+0xf5>
  801624:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801628:	39 f2                	cmp    %esi,%edx
  80162a:	0f 82 18 ff ff ff    	jb     801548 <__umoddi3+0x48>
  801630:	e9 1d ff ff ff       	jmp    801552 <__umoddi3+0x52>
