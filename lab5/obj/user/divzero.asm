
obj/user/divzero.debug:     file format elf32-i386


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
  80002c:	e8 37 00 00 00       	call   800068 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

int zero;

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	zero = 0;
  80003a:	c7 05 04 40 80 00 00 	movl   $0x0,0x804004
  800041:	00 00 00 
	cprintf("1/0 is %08x!\n", 1/zero);
  800044:	ba 01 00 00 00       	mov    $0x1,%edx
  800049:	b9 00 00 00 00       	mov    $0x0,%ecx
  80004e:	89 d0                	mov    %edx,%eax
  800050:	c1 fa 1f             	sar    $0x1f,%edx
  800053:	f7 f9                	idiv   %ecx
  800055:	89 44 24 04          	mov    %eax,0x4(%esp)
  800059:	c7 04 24 00 21 80 00 	movl   $0x802100,(%esp)
  800060:	e8 d4 00 00 00       	call   800139 <cprintf>
}
  800065:	c9                   	leave  
  800066:	c3                   	ret    
	...

00800068 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800068:	55                   	push   %ebp
  800069:	89 e5                	mov    %esp,%ebp
  80006b:	83 ec 18             	sub    $0x18,%esp
  80006e:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800071:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800074:	8b 75 08             	mov    0x8(%ebp),%esi
  800077:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  80007a:	e8 03 13 00 00       	call   801382 <sys_getenvid>
  80007f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800084:	89 c2                	mov    %eax,%edx
  800086:	c1 e2 07             	shl    $0x7,%edx
  800089:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  800090:	a3 08 40 80 00       	mov    %eax,0x804008
        //cprintf("ENVX sys_get_envid(): %d\n",ENVX(sys_getenvid()));
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800095:	85 f6                	test   %esi,%esi
  800097:	7e 07                	jle    8000a0 <libmain+0x38>
		binaryname = argv[0];
  800099:	8b 03                	mov    (%ebx),%eax
  80009b:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000a0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000a4:	89 34 24             	mov    %esi,(%esp)
  8000a7:	e8 88 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000ac:	e8 0b 00 00 00       	call   8000bc <exit>
}
  8000b1:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8000b4:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8000b7:	89 ec                	mov    %ebp,%esp
  8000b9:	5d                   	pop    %ebp
  8000ba:	c3                   	ret    
	...

008000bc <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000bc:	55                   	push   %ebp
  8000bd:	89 e5                	mov    %esp,%ebp
  8000bf:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8000c2:	e8 44 18 00 00       	call   80190b <close_all>
	sys_env_destroy(0);
  8000c7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000ce:	e8 ef 12 00 00       	call   8013c2 <sys_env_destroy>
}
  8000d3:	c9                   	leave  
  8000d4:	c3                   	ret    
  8000d5:	00 00                	add    %al,(%eax)
	...

008000d8 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  8000d8:	55                   	push   %ebp
  8000d9:	89 e5                	mov    %esp,%ebp
  8000db:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8000e1:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8000e8:	00 00 00 
	b.cnt = 0;
  8000eb:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8000f2:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8000f5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000f8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8000ff:	89 44 24 08          	mov    %eax,0x8(%esp)
  800103:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800109:	89 44 24 04          	mov    %eax,0x4(%esp)
  80010d:	c7 04 24 53 01 80 00 	movl   $0x800153,(%esp)
  800114:	e8 d3 01 00 00       	call   8002ec <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800119:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80011f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800123:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800129:	89 04 24             	mov    %eax,(%esp)
  80012c:	e8 6b 0d 00 00       	call   800e9c <sys_cputs>

	return b.cnt;
}
  800131:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800137:	c9                   	leave  
  800138:	c3                   	ret    

00800139 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800139:	55                   	push   %ebp
  80013a:	89 e5                	mov    %esp,%ebp
  80013c:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  80013f:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  800142:	89 44 24 04          	mov    %eax,0x4(%esp)
  800146:	8b 45 08             	mov    0x8(%ebp),%eax
  800149:	89 04 24             	mov    %eax,(%esp)
  80014c:	e8 87 ff ff ff       	call   8000d8 <vcprintf>
	va_end(ap);

	return cnt;
}
  800151:	c9                   	leave  
  800152:	c3                   	ret    

00800153 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800153:	55                   	push   %ebp
  800154:	89 e5                	mov    %esp,%ebp
  800156:	53                   	push   %ebx
  800157:	83 ec 14             	sub    $0x14,%esp
  80015a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80015d:	8b 03                	mov    (%ebx),%eax
  80015f:	8b 55 08             	mov    0x8(%ebp),%edx
  800162:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800166:	83 c0 01             	add    $0x1,%eax
  800169:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80016b:	3d ff 00 00 00       	cmp    $0xff,%eax
  800170:	75 19                	jne    80018b <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800172:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800179:	00 
  80017a:	8d 43 08             	lea    0x8(%ebx),%eax
  80017d:	89 04 24             	mov    %eax,(%esp)
  800180:	e8 17 0d 00 00       	call   800e9c <sys_cputs>
		b->idx = 0;
  800185:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80018b:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80018f:	83 c4 14             	add    $0x14,%esp
  800192:	5b                   	pop    %ebx
  800193:	5d                   	pop    %ebp
  800194:	c3                   	ret    
	...

008001a0 <printnum_v2>:
 */

static void 
printnum_v2(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001a0:	55                   	push   %ebp
  8001a1:	89 e5                	mov    %esp,%ebp
  8001a3:	57                   	push   %edi
  8001a4:	56                   	push   %esi
  8001a5:	53                   	push   %ebx
  8001a6:	83 ec 4c             	sub    $0x4c,%esp
  8001a9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8001ac:	89 d6                	mov    %edx,%esi
  8001ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8001b1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001b4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001b7:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8001ba:	8b 45 10             	mov    0x10(%ebp),%eax
  8001bd:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8001c0:	8b 7d 18             	mov    0x18(%ebp),%edi
    if (num >= base) {
  8001c3:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8001c6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001cb:	39 d1                	cmp    %edx,%ecx
  8001cd:	72 07                	jb     8001d6 <printnum_v2+0x36>
  8001cf:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8001d2:	39 d0                	cmp    %edx,%eax
  8001d4:	77 5f                	ja     800235 <printnum_v2+0x95>
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
  8001d6:	89 7c 24 10          	mov    %edi,0x10(%esp)
  8001da:	83 eb 01             	sub    $0x1,%ebx
  8001dd:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8001e1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001e5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8001e9:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  8001ed:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8001f0:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  8001f3:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8001f6:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001fa:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800201:	00 
  800202:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800205:	89 04 24             	mov    %eax,(%esp)
  800208:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80020b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80020f:	e8 7c 1c 00 00       	call   801e90 <__udivdi3>
  800214:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800217:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  80021a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80021e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800222:	89 04 24             	mov    %eax,(%esp)
  800225:	89 54 24 04          	mov    %edx,0x4(%esp)
  800229:	89 f2                	mov    %esi,%edx
  80022b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80022e:	e8 6d ff ff ff       	call   8001a0 <printnum_v2>
  800233:	eb 1e                	jmp    800253 <printnum_v2+0xb3>
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
  800235:	83 ff 2d             	cmp    $0x2d,%edi
  800238:	74 19                	je     800253 <printnum_v2+0xb3>
		while (--width > 0)
  80023a:	83 eb 01             	sub    $0x1,%ebx
  80023d:	85 db                	test   %ebx,%ebx
  80023f:	90                   	nop
  800240:	7e 11                	jle    800253 <printnum_v2+0xb3>
			putch(padc, putdat);
  800242:	89 74 24 04          	mov    %esi,0x4(%esp)
  800246:	89 3c 24             	mov    %edi,(%esp)
  800249:	ff 55 e4             	call   *-0x1c(%ebp)
    if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
		while (--width > 0)
  80024c:	83 eb 01             	sub    $0x1,%ebx
  80024f:	85 db                	test   %ebx,%ebx
  800251:	7f ef                	jg     800242 <printnum_v2+0xa2>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800253:	89 74 24 04          	mov    %esi,0x4(%esp)
  800257:	8b 74 24 04          	mov    0x4(%esp),%esi
  80025b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80025e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800262:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800269:	00 
  80026a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80026d:	89 14 24             	mov    %edx,(%esp)
  800270:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800273:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800277:	e8 44 1d 00 00       	call   801fc0 <__umoddi3>
  80027c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800280:	0f be 80 18 21 80 00 	movsbl 0x802118(%eax),%eax
  800287:	89 04 24             	mov    %eax,(%esp)
  80028a:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80028d:	83 c4 4c             	add    $0x4c,%esp
  800290:	5b                   	pop    %ebx
  800291:	5e                   	pop    %esi
  800292:	5f                   	pop    %edi
  800293:	5d                   	pop    %ebp
  800294:	c3                   	ret    

00800295 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800295:	55                   	push   %ebp
  800296:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800298:	83 fa 01             	cmp    $0x1,%edx
  80029b:	7e 0e                	jle    8002ab <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80029d:	8b 10                	mov    (%eax),%edx
  80029f:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002a2:	89 08                	mov    %ecx,(%eax)
  8002a4:	8b 02                	mov    (%edx),%eax
  8002a6:	8b 52 04             	mov    0x4(%edx),%edx
  8002a9:	eb 22                	jmp    8002cd <getuint+0x38>
	else if (lflag)
  8002ab:	85 d2                	test   %edx,%edx
  8002ad:	74 10                	je     8002bf <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002af:	8b 10                	mov    (%eax),%edx
  8002b1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002b4:	89 08                	mov    %ecx,(%eax)
  8002b6:	8b 02                	mov    (%edx),%eax
  8002b8:	ba 00 00 00 00       	mov    $0x0,%edx
  8002bd:	eb 0e                	jmp    8002cd <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002bf:	8b 10                	mov    (%eax),%edx
  8002c1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002c4:	89 08                	mov    %ecx,(%eax)
  8002c6:	8b 02                	mov    (%edx),%eax
  8002c8:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002cd:	5d                   	pop    %ebp
  8002ce:	c3                   	ret    

008002cf <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002cf:	55                   	push   %ebp
  8002d0:	89 e5                	mov    %esp,%ebp
  8002d2:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002d5:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002d9:	8b 10                	mov    (%eax),%edx
  8002db:	3b 50 04             	cmp    0x4(%eax),%edx
  8002de:	73 0a                	jae    8002ea <sprintputch+0x1b>
		*b->buf++ = ch;
  8002e0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002e3:	88 0a                	mov    %cl,(%edx)
  8002e5:	83 c2 01             	add    $0x1,%edx
  8002e8:	89 10                	mov    %edx,(%eax)
}
  8002ea:	5d                   	pop    %ebp
  8002eb:	c3                   	ret    

008002ec <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002ec:	55                   	push   %ebp
  8002ed:	89 e5                	mov    %esp,%ebp
  8002ef:	57                   	push   %edi
  8002f0:	56                   	push   %esi
  8002f1:	53                   	push   %ebx
  8002f2:	83 ec 6c             	sub    $0x6c,%esp
  8002f5:	8b 7d 10             	mov    0x10(%ebp),%edi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8002f8:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  8002ff:	eb 1a                	jmp    80031b <vprintfmt+0x2f>
	int base, lflag, width, precision, altflag,signflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800301:	85 c0                	test   %eax,%eax
  800303:	0f 84 66 06 00 00    	je     80096f <vprintfmt+0x683>
				return;
			putch(ch, putdat);
  800309:	8b 55 0c             	mov    0xc(%ebp),%edx
  80030c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800310:	89 04 24             	mov    %eax,(%esp)
  800313:	ff 55 08             	call   *0x8(%ebp)
  800316:	eb 03                	jmp    80031b <vprintfmt+0x2f>
  800318:	8b 7d e4             	mov    -0x1c(%ebp),%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag,signflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80031b:	0f b6 07             	movzbl (%edi),%eax
  80031e:	83 c7 01             	add    $0x1,%edi
  800321:	83 f8 25             	cmp    $0x25,%eax
  800324:	75 db                	jne    800301 <vprintfmt+0x15>
  800326:	c6 45 cc 20          	movb   $0x20,-0x34(%ebp)
  80032a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80032f:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  800336:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
  80033b:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800342:	be 00 00 00 00       	mov    $0x0,%esi
  800347:	eb 06                	jmp    80034f <vprintfmt+0x63>
  800349:	c6 45 cc 2d          	movb   $0x2d,-0x34(%ebp)
  80034d:	89 c7                	mov    %eax,%edi
		precision = -1;
		lflag = 0;
		altflag = 0;
                signflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80034f:	0f b6 17             	movzbl (%edi),%edx
  800352:	0f b6 c2             	movzbl %dl,%eax
  800355:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800358:	8d 47 01             	lea    0x1(%edi),%eax
  80035b:	83 ea 23             	sub    $0x23,%edx
  80035e:	80 fa 55             	cmp    $0x55,%dl
  800361:	0f 87 60 05 00 00    	ja     8008c7 <vprintfmt+0x5db>
  800367:	0f b6 d2             	movzbl %dl,%edx
  80036a:	ff 24 95 00 23 80 00 	jmp    *0x802300(,%edx,4)
  800371:	b9 01 00 00 00       	mov    $0x1,%ecx
  800376:	eb d5                	jmp    80034d <vprintfmt+0x61>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800378:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80037b:	83 eb 30             	sub    $0x30,%ebx
				ch = *fmt;
  80037e:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  800381:	8d 7a d0             	lea    -0x30(%edx),%edi
  800384:	83 ff 09             	cmp    $0x9,%edi
  800387:	76 08                	jbe    800391 <vprintfmt+0xa5>
  800389:	eb 40                	jmp    8003cb <vprintfmt+0xdf>
  80038b:	c6 45 cc 30          	movb   $0x30,-0x34(%ebp)
                        signflag = 1;
                        goto reswitch;
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
			goto reswitch;
  80038f:	eb bc                	jmp    80034d <vprintfmt+0x61>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800391:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  800394:	8d 1c 9b             	lea    (%ebx,%ebx,4),%ebx
  800397:	8d 5c 5a d0          	lea    -0x30(%edx,%ebx,2),%ebx
				ch = *fmt;
  80039b:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  80039e:	8d 7a d0             	lea    -0x30(%edx),%edi
  8003a1:	83 ff 09             	cmp    $0x9,%edi
  8003a4:	76 eb                	jbe    800391 <vprintfmt+0xa5>
  8003a6:	eb 23                	jmp    8003cb <vprintfmt+0xdf>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003a8:	8b 55 14             	mov    0x14(%ebp),%edx
  8003ab:	8d 5a 04             	lea    0x4(%edx),%ebx
  8003ae:	89 5d 14             	mov    %ebx,0x14(%ebp)
  8003b1:	8b 1a                	mov    (%edx),%ebx
			goto process_precision;
  8003b3:	eb 16                	jmp    8003cb <vprintfmt+0xdf>

		case '.':
			if (width < 0)
  8003b5:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8003b8:	c1 fa 1f             	sar    $0x1f,%edx
  8003bb:	f7 d2                	not    %edx
  8003bd:	21 55 d8             	and    %edx,-0x28(%ebp)
  8003c0:	eb 8b                	jmp    80034d <vprintfmt+0x61>
  8003c2:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  8003c9:	eb 82                	jmp    80034d <vprintfmt+0x61>

		process_precision:
			if (width < 0)
  8003cb:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8003cf:	0f 89 78 ff ff ff    	jns    80034d <vprintfmt+0x61>
  8003d5:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8003d8:	8b 5d c8             	mov    -0x38(%ebp),%ebx
  8003db:	e9 6d ff ff ff       	jmp    80034d <vprintfmt+0x61>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003e0:	83 c6 01             	add    $0x1,%esi
			goto reswitch;
  8003e3:	e9 65 ff ff ff       	jmp    80034d <vprintfmt+0x61>
  8003e8:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ee:	8d 50 04             	lea    0x4(%eax),%edx
  8003f1:	89 55 14             	mov    %edx,0x14(%ebp)
  8003f4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003f7:	89 54 24 04          	mov    %edx,0x4(%esp)
  8003fb:	8b 00                	mov    (%eax),%eax
  8003fd:	89 04 24             	mov    %eax,(%esp)
  800400:	ff 55 08             	call   *0x8(%ebp)
  800403:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;
  800406:	e9 10 ff ff ff       	jmp    80031b <vprintfmt+0x2f>
  80040b:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  80040e:	8b 45 14             	mov    0x14(%ebp),%eax
  800411:	8d 50 04             	lea    0x4(%eax),%edx
  800414:	89 55 14             	mov    %edx,0x14(%ebp)
  800417:	8b 00                	mov    (%eax),%eax
  800419:	89 c2                	mov    %eax,%edx
  80041b:	c1 fa 1f             	sar    $0x1f,%edx
  80041e:	31 d0                	xor    %edx,%eax
  800420:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800422:	83 f8 0f             	cmp    $0xf,%eax
  800425:	7f 0b                	jg     800432 <vprintfmt+0x146>
  800427:	8b 14 85 60 24 80 00 	mov    0x802460(,%eax,4),%edx
  80042e:	85 d2                	test   %edx,%edx
  800430:	75 26                	jne    800458 <vprintfmt+0x16c>
				printfmt(putch, putdat, "error %d", err);
  800432:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800436:	c7 44 24 08 29 21 80 	movl   $0x802129,0x8(%esp)
  80043d:	00 
  80043e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800441:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800445:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800448:	89 1c 24             	mov    %ebx,(%esp)
  80044b:	e8 a7 05 00 00       	call   8009f7 <printfmt>
  800450:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800453:	e9 c3 fe ff ff       	jmp    80031b <vprintfmt+0x2f>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800458:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80045c:	c7 44 24 08 32 21 80 	movl   $0x802132,0x8(%esp)
  800463:	00 
  800464:	8b 45 0c             	mov    0xc(%ebp),%eax
  800467:	89 44 24 04          	mov    %eax,0x4(%esp)
  80046b:	8b 55 08             	mov    0x8(%ebp),%edx
  80046e:	89 14 24             	mov    %edx,(%esp)
  800471:	e8 81 05 00 00       	call   8009f7 <printfmt>
  800476:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800479:	e9 9d fe ff ff       	jmp    80031b <vprintfmt+0x2f>
  80047e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800481:	89 c7                	mov    %eax,%edi
  800483:	89 d9                	mov    %ebx,%ecx
  800485:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800488:	89 45 c0             	mov    %eax,-0x40(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80048b:	8b 45 14             	mov    0x14(%ebp),%eax
  80048e:	8d 50 04             	lea    0x4(%eax),%edx
  800491:	89 55 14             	mov    %edx,0x14(%ebp)
  800494:	8b 30                	mov    (%eax),%esi
  800496:	85 f6                	test   %esi,%esi
  800498:	75 05                	jne    80049f <vprintfmt+0x1b3>
  80049a:	be 35 21 80 00       	mov    $0x802135,%esi
				p = "(null)";
			if (width > 0 && padc != '-')
  80049f:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
  8004a3:	7e 06                	jle    8004ab <vprintfmt+0x1bf>
  8004a5:	80 7d cc 2d          	cmpb   $0x2d,-0x34(%ebp)
  8004a9:	75 10                	jne    8004bb <vprintfmt+0x1cf>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004ab:	0f be 06             	movsbl (%esi),%eax
  8004ae:	85 c0                	test   %eax,%eax
  8004b0:	0f 85 a2 00 00 00    	jne    800558 <vprintfmt+0x26c>
  8004b6:	e9 92 00 00 00       	jmp    80054d <vprintfmt+0x261>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004bb:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8004bf:	89 34 24             	mov    %esi,(%esp)
  8004c2:	e8 74 05 00 00       	call   800a3b <strnlen>
  8004c7:	8b 55 c0             	mov    -0x40(%ebp),%edx
  8004ca:	29 c2                	sub    %eax,%edx
  8004cc:	89 55 d8             	mov    %edx,-0x28(%ebp)
  8004cf:	85 d2                	test   %edx,%edx
  8004d1:	7e d8                	jle    8004ab <vprintfmt+0x1bf>
					putch(padc, putdat);
  8004d3:	0f be 4d cc          	movsbl -0x34(%ebp),%ecx
  8004d7:	89 5d c0             	mov    %ebx,-0x40(%ebp)
  8004da:	89 d3                	mov    %edx,%ebx
  8004dc:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8004df:	89 7d bc             	mov    %edi,-0x44(%ebp)
  8004e2:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8004e5:	89 ce                	mov    %ecx,%esi
  8004e7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004eb:	89 34 24             	mov    %esi,(%esp)
  8004ee:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004f1:	83 eb 01             	sub    $0x1,%ebx
  8004f4:	85 db                	test   %ebx,%ebx
  8004f6:	7f ef                	jg     8004e7 <vprintfmt+0x1fb>
  8004f8:	8b 5d c0             	mov    -0x40(%ebp),%ebx
  8004fb:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8004fe:	8b 7d bc             	mov    -0x44(%ebp),%edi
  800501:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800508:	eb a1                	jmp    8004ab <vprintfmt+0x1bf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80050a:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  80050e:	74 1b                	je     80052b <vprintfmt+0x23f>
  800510:	8d 50 e0             	lea    -0x20(%eax),%edx
  800513:	83 fa 5e             	cmp    $0x5e,%edx
  800516:	76 13                	jbe    80052b <vprintfmt+0x23f>
					putch('?', putdat);
  800518:	8b 45 0c             	mov    0xc(%ebp),%eax
  80051b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80051f:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800526:	ff 55 08             	call   *0x8(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800529:	eb 0d                	jmp    800538 <vprintfmt+0x24c>
					putch('?', putdat);
				else
					putch(ch, putdat);
  80052b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80052e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800532:	89 04 24             	mov    %eax,(%esp)
  800535:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800538:	83 ef 01             	sub    $0x1,%edi
  80053b:	0f be 06             	movsbl (%esi),%eax
  80053e:	85 c0                	test   %eax,%eax
  800540:	74 05                	je     800547 <vprintfmt+0x25b>
  800542:	83 c6 01             	add    $0x1,%esi
  800545:	eb 1a                	jmp    800561 <vprintfmt+0x275>
  800547:	89 7d d8             	mov    %edi,-0x28(%ebp)
  80054a:	8b 7d cc             	mov    -0x34(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80054d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800551:	7f 1f                	jg     800572 <vprintfmt+0x286>
  800553:	e9 c0 fd ff ff       	jmp    800318 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800558:	83 c6 01             	add    $0x1,%esi
  80055b:	89 7d cc             	mov    %edi,-0x34(%ebp)
  80055e:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800561:	85 db                	test   %ebx,%ebx
  800563:	78 a5                	js     80050a <vprintfmt+0x21e>
  800565:	83 eb 01             	sub    $0x1,%ebx
  800568:	79 a0                	jns    80050a <vprintfmt+0x21e>
  80056a:	89 7d d8             	mov    %edi,-0x28(%ebp)
  80056d:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800570:	eb db                	jmp    80054d <vprintfmt+0x261>
  800572:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800575:	8b 75 0c             	mov    0xc(%ebp),%esi
  800578:	89 7d d8             	mov    %edi,-0x28(%ebp)
  80057b:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80057e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800582:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800589:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80058b:	83 eb 01             	sub    $0x1,%ebx
  80058e:	85 db                	test   %ebx,%ebx
  800590:	7f ec                	jg     80057e <vprintfmt+0x292>
  800592:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800595:	e9 81 fd ff ff       	jmp    80031b <vprintfmt+0x2f>
  80059a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80059d:	83 fe 01             	cmp    $0x1,%esi
  8005a0:	7e 10                	jle    8005b2 <vprintfmt+0x2c6>
		return va_arg(*ap, long long);
  8005a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a5:	8d 50 08             	lea    0x8(%eax),%edx
  8005a8:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ab:	8b 18                	mov    (%eax),%ebx
  8005ad:	8b 70 04             	mov    0x4(%eax),%esi
  8005b0:	eb 26                	jmp    8005d8 <vprintfmt+0x2ec>
	else if (lflag)
  8005b2:	85 f6                	test   %esi,%esi
  8005b4:	74 12                	je     8005c8 <vprintfmt+0x2dc>
		return va_arg(*ap, long);
  8005b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b9:	8d 50 04             	lea    0x4(%eax),%edx
  8005bc:	89 55 14             	mov    %edx,0x14(%ebp)
  8005bf:	8b 18                	mov    (%eax),%ebx
  8005c1:	89 de                	mov    %ebx,%esi
  8005c3:	c1 fe 1f             	sar    $0x1f,%esi
  8005c6:	eb 10                	jmp    8005d8 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  8005c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cb:	8d 50 04             	lea    0x4(%eax),%edx
  8005ce:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d1:	8b 18                	mov    (%eax),%ebx
  8005d3:	89 de                	mov    %ebx,%esi
  8005d5:	c1 fe 1f             	sar    $0x1f,%esi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
                        if(signflag == 1){
  8005d8:	83 f9 01             	cmp    $0x1,%ecx
  8005db:	75 1e                	jne    8005fb <vprintfmt+0x30f>
                               if((long long)num > 0){
  8005dd:	85 f6                	test   %esi,%esi
  8005df:	78 1a                	js     8005fb <vprintfmt+0x30f>
  8005e1:	85 f6                	test   %esi,%esi
  8005e3:	7f 05                	jg     8005ea <vprintfmt+0x2fe>
  8005e5:	83 fb 00             	cmp    $0x0,%ebx
  8005e8:	76 11                	jbe    8005fb <vprintfmt+0x30f>
                                   putch('+',putdat);
  8005ea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8005ed:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8005f1:	c7 04 24 2b 00 00 00 	movl   $0x2b,(%esp)
  8005f8:	ff 55 08             	call   *0x8(%ebp)
                               }
                        }
			if ((long long) num < 0) {
  8005fb:	85 f6                	test   %esi,%esi
  8005fd:	78 13                	js     800612 <vprintfmt+0x326>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005ff:	89 5d b0             	mov    %ebx,-0x50(%ebp)
  800602:	89 75 b4             	mov    %esi,-0x4c(%ebp)
  800605:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800608:	b8 0a 00 00 00       	mov    $0xa,%eax
  80060d:	e9 da 00 00 00       	jmp    8006ec <vprintfmt+0x400>
                               if((long long)num > 0){
                                   putch('+',putdat);
                               }
                        }
			if ((long long) num < 0) {
				putch('-', putdat);
  800612:	8b 45 0c             	mov    0xc(%ebp),%eax
  800615:	89 44 24 04          	mov    %eax,0x4(%esp)
  800619:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800620:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800623:	89 da                	mov    %ebx,%edx
  800625:	89 f1                	mov    %esi,%ecx
  800627:	f7 da                	neg    %edx
  800629:	83 d1 00             	adc    $0x0,%ecx
  80062c:	f7 d9                	neg    %ecx
  80062e:	89 55 b0             	mov    %edx,-0x50(%ebp)
  800631:	89 4d b4             	mov    %ecx,-0x4c(%ebp)
  800634:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800637:	b8 0a 00 00 00       	mov    $0xa,%eax
  80063c:	e9 ab 00 00 00       	jmp    8006ec <vprintfmt+0x400>
  800641:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800644:	89 f2                	mov    %esi,%edx
  800646:	8d 45 14             	lea    0x14(%ebp),%eax
  800649:	e8 47 fc ff ff       	call   800295 <getuint>
  80064e:	89 45 b0             	mov    %eax,-0x50(%ebp)
  800651:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  800654:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800657:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
  80065c:	e9 8b 00 00 00       	jmp    8006ec <vprintfmt+0x400>
  800661:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			putch('0', putdat);
  800664:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800667:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80066b:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800672:	ff 55 08             	call   *0x8(%ebp)
			num = getuint(&ap,lflag);
  800675:	89 f2                	mov    %esi,%edx
  800677:	8d 45 14             	lea    0x14(%ebp),%eax
  80067a:	e8 16 fc ff ff       	call   800295 <getuint>
  80067f:	89 45 b0             	mov    %eax,-0x50(%ebp)
  800682:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  800685:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800688:	b8 08 00 00 00       	mov    $0x8,%eax
                        base = 8;
			goto number;
  80068d:	eb 5d                	jmp    8006ec <vprintfmt+0x400>
  80068f:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
  800692:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800695:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800699:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8006a0:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8006a3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006a7:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8006ae:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  8006b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b4:	8d 50 04             	lea    0x4(%eax),%edx
  8006b7:	89 55 14             	mov    %edx,0x14(%ebp)
  8006ba:	8b 10                	mov    (%eax),%edx
  8006bc:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006c1:	89 55 b0             	mov    %edx,-0x50(%ebp)
  8006c4:	89 4d b4             	mov    %ecx,-0x4c(%ebp)
  8006c7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006ca:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006cf:	eb 1b                	jmp    8006ec <vprintfmt+0x400>
  8006d1:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006d4:	89 f2                	mov    %esi,%edx
  8006d6:	8d 45 14             	lea    0x14(%ebp),%eax
  8006d9:	e8 b7 fb ff ff       	call   800295 <getuint>
  8006de:	89 45 b0             	mov    %eax,-0x50(%ebp)
  8006e1:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  8006e4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006e7:	b8 10 00 00 00       	mov    $0x10,%eax
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006ec:	0f be 4d cc          	movsbl -0x34(%ebp),%ecx
  8006f0:	89 4d d0             	mov    %ecx,-0x30(%ebp)
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8006f3:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8006f6:	83 7d b4 00          	cmpl   $0x0,-0x4c(%ebp)
  8006fa:	77 09                	ja     800705 <vprintfmt+0x419>
  8006fc:	39 45 b0             	cmp    %eax,-0x50(%ebp)
  8006ff:	0f 82 ac 00 00 00    	jb     8007b1 <vprintfmt+0x4c5>
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
  800705:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800708:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  80070c:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80070f:	83 ea 01             	sub    $0x1,%edx
  800712:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800716:	89 44 24 08          	mov    %eax,0x8(%esp)
  80071a:	8b 44 24 08          	mov    0x8(%esp),%eax
  80071e:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800722:	89 45 c0             	mov    %eax,-0x40(%ebp)
  800725:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  800728:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80072b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80072f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800736:	00 
  800737:	8b 4d b0             	mov    -0x50(%ebp),%ecx
  80073a:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
  80073d:	89 0c 24             	mov    %ecx,(%esp)
  800740:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800744:	e8 47 17 00 00       	call   801e90 <__udivdi3>
  800749:	8b 4d c0             	mov    -0x40(%ebp),%ecx
  80074c:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  80074f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800753:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800757:	89 04 24             	mov    %eax,(%esp)
  80075a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80075e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800761:	8b 45 08             	mov    0x8(%ebp),%eax
  800764:	e8 37 fa ff ff       	call   8001a0 <printnum_v2>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800769:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80076c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800770:	8b 74 24 04          	mov    0x4(%esp),%esi
  800774:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800777:	89 44 24 08          	mov    %eax,0x8(%esp)
  80077b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800782:	00 
  800783:	8b 55 b0             	mov    -0x50(%ebp),%edx
  800786:	8b 4d b4             	mov    -0x4c(%ebp),%ecx
  800789:	89 14 24             	mov    %edx,(%esp)
  80078c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800790:	e8 2b 18 00 00       	call   801fc0 <__umoddi3>
  800795:	89 74 24 04          	mov    %esi,0x4(%esp)
  800799:	0f be 80 18 21 80 00 	movsbl 0x802118(%eax),%eax
  8007a0:	89 04 24             	mov    %eax,(%esp)
  8007a3:	ff 55 08             	call   *0x8(%ebp)
        if(padc == '-'){
  8007a6:	83 7d d0 2d          	cmpl   $0x2d,-0x30(%ebp)
  8007aa:	74 54                	je     800800 <vprintfmt+0x514>
  8007ac:	e9 67 fb ff ff       	jmp    800318 <vprintfmt+0x2c>
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
  8007b1:	83 7d d0 2d          	cmpl   $0x2d,-0x30(%ebp)
  8007b5:	8d 76 00             	lea    0x0(%esi),%esi
  8007b8:	0f 84 2a 01 00 00    	je     8008e8 <vprintfmt+0x5fc>
		while (--width > 0)
  8007be:	8b 7d d8             	mov    -0x28(%ebp),%edi
  8007c1:	83 ef 01             	sub    $0x1,%edi
  8007c4:	85 ff                	test   %edi,%edi
  8007c6:	0f 8e 5e 01 00 00    	jle    80092a <vprintfmt+0x63e>
  8007cc:	8b 4d b0             	mov    -0x50(%ebp),%ecx
  8007cf:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
  8007d2:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  8007d5:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  8007d8:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8007db:	8b 75 0c             	mov    0xc(%ebp),%esi
			putch(padc, putdat);
  8007de:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007e2:	89 1c 24             	mov    %ebx,(%esp)
  8007e5:	ff 55 08             	call   *0x8(%ebp)
	if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
		while (--width > 0)
  8007e8:	83 ef 01             	sub    $0x1,%edi
  8007eb:	85 ff                	test   %edi,%edi
  8007ed:	7f ef                	jg     8007de <vprintfmt+0x4f2>
  8007ef:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8007f2:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8007f5:	89 45 b0             	mov    %eax,-0x50(%ebp)
  8007f8:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  8007fb:	e9 2a 01 00 00       	jmp    80092a <vprintfmt+0x63e>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
        if(padc == '-'){
           while (--width > 0)
  800800:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800803:	83 eb 01             	sub    $0x1,%ebx
  800806:	85 db                	test   %ebx,%ebx
  800808:	0f 8e 0a fb ff ff    	jle    800318 <vprintfmt+0x2c>
  80080e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800811:	89 7d d8             	mov    %edi,-0x28(%ebp)
  800814:	8b 7d 08             	mov    0x8(%ebp),%edi
			putch(' ', putdat);
  800817:	89 74 24 04          	mov    %esi,0x4(%esp)
  80081b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800822:	ff d7                	call   *%edi
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
        if(padc == '-'){
           while (--width > 0)
  800824:	83 eb 01             	sub    $0x1,%ebx
  800827:	85 db                	test   %ebx,%ebx
  800829:	7f ec                	jg     800817 <vprintfmt+0x52b>
  80082b:	8b 7d d8             	mov    -0x28(%ebp),%edi
  80082e:	e9 e8 fa ff ff       	jmp    80031b <vprintfmt+0x2f>
  800833:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
            char* n;
            if ((n = va_arg(ap, char *)) == NULL)
  800836:	8b 45 14             	mov    0x14(%ebp),%eax
  800839:	8d 50 04             	lea    0x4(%eax),%edx
  80083c:	89 55 14             	mov    %edx,0x14(%ebp)
  80083f:	8b 00                	mov    (%eax),%eax
  800841:	85 c0                	test   %eax,%eax
  800843:	75 2a                	jne    80086f <vprintfmt+0x583>
		  printfmt(putch,putdat,"%s",null_error);
  800845:	c7 44 24 0c 50 22 80 	movl   $0x802250,0xc(%esp)
  80084c:	00 
  80084d:	c7 44 24 08 32 21 80 	movl   $0x802132,0x8(%esp)
  800854:	00 
  800855:	8b 55 0c             	mov    0xc(%ebp),%edx
  800858:	89 54 24 04          	mov    %edx,0x4(%esp)
  80085c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80085f:	89 0c 24             	mov    %ecx,(%esp)
  800862:	e8 90 01 00 00       	call   8009f7 <printfmt>
  800867:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80086a:	e9 ac fa ff ff       	jmp    80031b <vprintfmt+0x2f>
            else if((*(int*)putdat) > 127){
  80086f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800872:	8b 13                	mov    (%ebx),%edx
  800874:	83 fa 7f             	cmp    $0x7f,%edx
  800877:	7e 29                	jle    8008a2 <vprintfmt+0x5b6>
                  *n = *(int*)putdat;
  800879:	88 10                	mov    %dl,(%eax)
                  printfmt(putch,putdat,"%s",overflow_error);
  80087b:	c7 44 24 0c 88 22 80 	movl   $0x802288,0xc(%esp)
  800882:	00 
  800883:	c7 44 24 08 32 21 80 	movl   $0x802132,0x8(%esp)
  80088a:	00 
  80088b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80088f:	8b 45 08             	mov    0x8(%ebp),%eax
  800892:	89 04 24             	mov    %eax,(%esp)
  800895:	e8 5d 01 00 00       	call   8009f7 <printfmt>
  80089a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80089d:	e9 79 fa ff ff       	jmp    80031b <vprintfmt+0x2f>
            }
            else
                  *n = *(int*)putdat;
  8008a2:	88 10                	mov    %dl,(%eax)
  8008a4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8008a7:	e9 6f fa ff ff       	jmp    80031b <vprintfmt+0x2f>
  8008ac:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8008af:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            break;
        }
		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8008b2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008b5:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8008b9:	89 14 24             	mov    %edx,(%esp)
  8008bc:	ff 55 08             	call   *0x8(%ebp)
  8008bf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;
  8008c2:	e9 54 fa ff ff       	jmp    80031b <vprintfmt+0x2f>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8008c7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8008ca:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008ce:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8008d5:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008d8:	8d 47 ff             	lea    -0x1(%edi),%eax
  8008db:	80 38 25             	cmpb   $0x25,(%eax)
  8008de:	0f 84 37 fa ff ff    	je     80031b <vprintfmt+0x2f>
  8008e4:	89 c7                	mov    %eax,%edi
  8008e6:	eb f0                	jmp    8008d8 <vprintfmt+0x5ec>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8008e8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008eb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008ef:	8b 74 24 04          	mov    0x4(%esp),%esi
  8008f3:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8008f6:	89 54 24 08          	mov    %edx,0x8(%esp)
  8008fa:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800901:	00 
  800902:	8b 45 b0             	mov    -0x50(%ebp),%eax
  800905:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  800908:	89 04 24             	mov    %eax,(%esp)
  80090b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80090f:	e8 ac 16 00 00       	call   801fc0 <__umoddi3>
  800914:	89 74 24 04          	mov    %esi,0x4(%esp)
  800918:	0f be 80 18 21 80 00 	movsbl 0x802118(%eax),%eax
  80091f:	89 04 24             	mov    %eax,(%esp)
  800922:	ff 55 08             	call   *0x8(%ebp)
  800925:	e9 d6 fe ff ff       	jmp    800800 <vprintfmt+0x514>
  80092a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80092d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800931:	8b 74 24 04          	mov    0x4(%esp),%esi
  800935:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800938:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80093c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800943:	00 
  800944:	8b 45 b0             	mov    -0x50(%ebp),%eax
  800947:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  80094a:	89 04 24             	mov    %eax,(%esp)
  80094d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800951:	e8 6a 16 00 00       	call   801fc0 <__umoddi3>
  800956:	89 74 24 04          	mov    %esi,0x4(%esp)
  80095a:	0f be 80 18 21 80 00 	movsbl 0x802118(%eax),%eax
  800961:	89 04 24             	mov    %eax,(%esp)
  800964:	ff 55 08             	call   *0x8(%ebp)
  800967:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80096a:	e9 ac f9 ff ff       	jmp    80031b <vprintfmt+0x2f>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  80096f:	83 c4 6c             	add    $0x6c,%esp
  800972:	5b                   	pop    %ebx
  800973:	5e                   	pop    %esi
  800974:	5f                   	pop    %edi
  800975:	5d                   	pop    %ebp
  800976:	c3                   	ret    

00800977 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800977:	55                   	push   %ebp
  800978:	89 e5                	mov    %esp,%ebp
  80097a:	83 ec 28             	sub    $0x28,%esp
  80097d:	8b 45 08             	mov    0x8(%ebp),%eax
  800980:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  800983:	85 c0                	test   %eax,%eax
  800985:	74 04                	je     80098b <vsnprintf+0x14>
  800987:	85 d2                	test   %edx,%edx
  800989:	7f 07                	jg     800992 <vsnprintf+0x1b>
  80098b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800990:	eb 3b                	jmp    8009cd <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  800992:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800995:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  800999:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80099c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8009a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8009a6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009aa:	8b 45 10             	mov    0x10(%ebp),%eax
  8009ad:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009b1:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8009b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009b8:	c7 04 24 cf 02 80 00 	movl   $0x8002cf,(%esp)
  8009bf:	e8 28 f9 ff ff       	call   8002ec <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8009c4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8009c7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8009ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8009cd:	c9                   	leave  
  8009ce:	c3                   	ret    

008009cf <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8009cf:	55                   	push   %ebp
  8009d0:	89 e5                	mov    %esp,%ebp
  8009d2:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  8009d5:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  8009d8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009dc:	8b 45 10             	mov    0x10(%ebp),%eax
  8009df:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009e3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009e6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ed:	89 04 24             	mov    %eax,(%esp)
  8009f0:	e8 82 ff ff ff       	call   800977 <vsnprintf>
	va_end(ap);

	return rc;
}
  8009f5:	c9                   	leave  
  8009f6:	c3                   	ret    

008009f7 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8009f7:	55                   	push   %ebp
  8009f8:	89 e5                	mov    %esp,%ebp
  8009fa:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  8009fd:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  800a00:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a04:	8b 45 10             	mov    0x10(%ebp),%eax
  800a07:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a0b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a0e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a12:	8b 45 08             	mov    0x8(%ebp),%eax
  800a15:	89 04 24             	mov    %eax,(%esp)
  800a18:	e8 cf f8 ff ff       	call   8002ec <vprintfmt>
	va_end(ap);
}
  800a1d:	c9                   	leave  
  800a1e:	c3                   	ret    
	...

00800a20 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a20:	55                   	push   %ebp
  800a21:	89 e5                	mov    %esp,%ebp
  800a23:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a26:	b8 00 00 00 00       	mov    $0x0,%eax
  800a2b:	80 3a 00             	cmpb   $0x0,(%edx)
  800a2e:	74 09                	je     800a39 <strlen+0x19>
		n++;
  800a30:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800a33:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a37:	75 f7                	jne    800a30 <strlen+0x10>
		n++;
	return n;
}
  800a39:	5d                   	pop    %ebp
  800a3a:	c3                   	ret    

00800a3b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a3b:	55                   	push   %ebp
  800a3c:	89 e5                	mov    %esp,%ebp
  800a3e:	53                   	push   %ebx
  800a3f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800a42:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a45:	85 c9                	test   %ecx,%ecx
  800a47:	74 19                	je     800a62 <strnlen+0x27>
  800a49:	80 3b 00             	cmpb   $0x0,(%ebx)
  800a4c:	74 14                	je     800a62 <strnlen+0x27>
  800a4e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800a53:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a56:	39 c8                	cmp    %ecx,%eax
  800a58:	74 0d                	je     800a67 <strnlen+0x2c>
  800a5a:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  800a5e:	75 f3                	jne    800a53 <strnlen+0x18>
  800a60:	eb 05                	jmp    800a67 <strnlen+0x2c>
  800a62:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800a67:	5b                   	pop    %ebx
  800a68:	5d                   	pop    %ebp
  800a69:	c3                   	ret    

00800a6a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a6a:	55                   	push   %ebp
  800a6b:	89 e5                	mov    %esp,%ebp
  800a6d:	53                   	push   %ebx
  800a6e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a71:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a74:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a79:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800a7d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800a80:	83 c2 01             	add    $0x1,%edx
  800a83:	84 c9                	test   %cl,%cl
  800a85:	75 f2                	jne    800a79 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800a87:	5b                   	pop    %ebx
  800a88:	5d                   	pop    %ebp
  800a89:	c3                   	ret    

00800a8a <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a8a:	55                   	push   %ebp
  800a8b:	89 e5                	mov    %esp,%ebp
  800a8d:	53                   	push   %ebx
  800a8e:	83 ec 08             	sub    $0x8,%esp
  800a91:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a94:	89 1c 24             	mov    %ebx,(%esp)
  800a97:	e8 84 ff ff ff       	call   800a20 <strlen>
	strcpy(dst + len, src);
  800a9c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a9f:	89 54 24 04          	mov    %edx,0x4(%esp)
  800aa3:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800aa6:	89 04 24             	mov    %eax,(%esp)
  800aa9:	e8 bc ff ff ff       	call   800a6a <strcpy>
	return dst;
}
  800aae:	89 d8                	mov    %ebx,%eax
  800ab0:	83 c4 08             	add    $0x8,%esp
  800ab3:	5b                   	pop    %ebx
  800ab4:	5d                   	pop    %ebp
  800ab5:	c3                   	ret    

00800ab6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800ab6:	55                   	push   %ebp
  800ab7:	89 e5                	mov    %esp,%ebp
  800ab9:	56                   	push   %esi
  800aba:	53                   	push   %ebx
  800abb:	8b 45 08             	mov    0x8(%ebp),%eax
  800abe:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ac1:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ac4:	85 f6                	test   %esi,%esi
  800ac6:	74 18                	je     800ae0 <strncpy+0x2a>
  800ac8:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800acd:	0f b6 1a             	movzbl (%edx),%ebx
  800ad0:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800ad3:	80 3a 01             	cmpb   $0x1,(%edx)
  800ad6:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ad9:	83 c1 01             	add    $0x1,%ecx
  800adc:	39 ce                	cmp    %ecx,%esi
  800ade:	77 ed                	ja     800acd <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800ae0:	5b                   	pop    %ebx
  800ae1:	5e                   	pop    %esi
  800ae2:	5d                   	pop    %ebp
  800ae3:	c3                   	ret    

00800ae4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800ae4:	55                   	push   %ebp
  800ae5:	89 e5                	mov    %esp,%ebp
  800ae7:	56                   	push   %esi
  800ae8:	53                   	push   %ebx
  800ae9:	8b 75 08             	mov    0x8(%ebp),%esi
  800aec:	8b 55 0c             	mov    0xc(%ebp),%edx
  800aef:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800af2:	89 f0                	mov    %esi,%eax
  800af4:	85 c9                	test   %ecx,%ecx
  800af6:	74 27                	je     800b1f <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  800af8:	83 e9 01             	sub    $0x1,%ecx
  800afb:	74 1d                	je     800b1a <strlcpy+0x36>
  800afd:	0f b6 1a             	movzbl (%edx),%ebx
  800b00:	84 db                	test   %bl,%bl
  800b02:	74 16                	je     800b1a <strlcpy+0x36>
			*dst++ = *src++;
  800b04:	88 18                	mov    %bl,(%eax)
  800b06:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800b09:	83 e9 01             	sub    $0x1,%ecx
  800b0c:	74 0e                	je     800b1c <strlcpy+0x38>
			*dst++ = *src++;
  800b0e:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800b11:	0f b6 1a             	movzbl (%edx),%ebx
  800b14:	84 db                	test   %bl,%bl
  800b16:	75 ec                	jne    800b04 <strlcpy+0x20>
  800b18:	eb 02                	jmp    800b1c <strlcpy+0x38>
  800b1a:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800b1c:	c6 00 00             	movb   $0x0,(%eax)
  800b1f:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800b21:	5b                   	pop    %ebx
  800b22:	5e                   	pop    %esi
  800b23:	5d                   	pop    %ebp
  800b24:	c3                   	ret    

00800b25 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b25:	55                   	push   %ebp
  800b26:	89 e5                	mov    %esp,%ebp
  800b28:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b2b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800b2e:	0f b6 01             	movzbl (%ecx),%eax
  800b31:	84 c0                	test   %al,%al
  800b33:	74 15                	je     800b4a <strcmp+0x25>
  800b35:	3a 02                	cmp    (%edx),%al
  800b37:	75 11                	jne    800b4a <strcmp+0x25>
		p++, q++;
  800b39:	83 c1 01             	add    $0x1,%ecx
  800b3c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800b3f:	0f b6 01             	movzbl (%ecx),%eax
  800b42:	84 c0                	test   %al,%al
  800b44:	74 04                	je     800b4a <strcmp+0x25>
  800b46:	3a 02                	cmp    (%edx),%al
  800b48:	74 ef                	je     800b39 <strcmp+0x14>
  800b4a:	0f b6 c0             	movzbl %al,%eax
  800b4d:	0f b6 12             	movzbl (%edx),%edx
  800b50:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800b52:	5d                   	pop    %ebp
  800b53:	c3                   	ret    

00800b54 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b54:	55                   	push   %ebp
  800b55:	89 e5                	mov    %esp,%ebp
  800b57:	53                   	push   %ebx
  800b58:	8b 55 08             	mov    0x8(%ebp),%edx
  800b5b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b5e:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800b61:	85 c0                	test   %eax,%eax
  800b63:	74 23                	je     800b88 <strncmp+0x34>
  800b65:	0f b6 1a             	movzbl (%edx),%ebx
  800b68:	84 db                	test   %bl,%bl
  800b6a:	74 25                	je     800b91 <strncmp+0x3d>
  800b6c:	3a 19                	cmp    (%ecx),%bl
  800b6e:	75 21                	jne    800b91 <strncmp+0x3d>
  800b70:	83 e8 01             	sub    $0x1,%eax
  800b73:	74 13                	je     800b88 <strncmp+0x34>
		n--, p++, q++;
  800b75:	83 c2 01             	add    $0x1,%edx
  800b78:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b7b:	0f b6 1a             	movzbl (%edx),%ebx
  800b7e:	84 db                	test   %bl,%bl
  800b80:	74 0f                	je     800b91 <strncmp+0x3d>
  800b82:	3a 19                	cmp    (%ecx),%bl
  800b84:	74 ea                	je     800b70 <strncmp+0x1c>
  800b86:	eb 09                	jmp    800b91 <strncmp+0x3d>
  800b88:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800b8d:	5b                   	pop    %ebx
  800b8e:	5d                   	pop    %ebp
  800b8f:	90                   	nop
  800b90:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b91:	0f b6 02             	movzbl (%edx),%eax
  800b94:	0f b6 11             	movzbl (%ecx),%edx
  800b97:	29 d0                	sub    %edx,%eax
  800b99:	eb f2                	jmp    800b8d <strncmp+0x39>

00800b9b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b9b:	55                   	push   %ebp
  800b9c:	89 e5                	mov    %esp,%ebp
  800b9e:	8b 45 08             	mov    0x8(%ebp),%eax
  800ba1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ba5:	0f b6 10             	movzbl (%eax),%edx
  800ba8:	84 d2                	test   %dl,%dl
  800baa:	74 18                	je     800bc4 <strchr+0x29>
		if (*s == c)
  800bac:	38 ca                	cmp    %cl,%dl
  800bae:	75 0a                	jne    800bba <strchr+0x1f>
  800bb0:	eb 17                	jmp    800bc9 <strchr+0x2e>
  800bb2:	38 ca                	cmp    %cl,%dl
  800bb4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800bb8:	74 0f                	je     800bc9 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800bba:	83 c0 01             	add    $0x1,%eax
  800bbd:	0f b6 10             	movzbl (%eax),%edx
  800bc0:	84 d2                	test   %dl,%dl
  800bc2:	75 ee                	jne    800bb2 <strchr+0x17>
  800bc4:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800bc9:	5d                   	pop    %ebp
  800bca:	c3                   	ret    

00800bcb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800bcb:	55                   	push   %ebp
  800bcc:	89 e5                	mov    %esp,%ebp
  800bce:	8b 45 08             	mov    0x8(%ebp),%eax
  800bd1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800bd5:	0f b6 10             	movzbl (%eax),%edx
  800bd8:	84 d2                	test   %dl,%dl
  800bda:	74 18                	je     800bf4 <strfind+0x29>
		if (*s == c)
  800bdc:	38 ca                	cmp    %cl,%dl
  800bde:	75 0a                	jne    800bea <strfind+0x1f>
  800be0:	eb 12                	jmp    800bf4 <strfind+0x29>
  800be2:	38 ca                	cmp    %cl,%dl
  800be4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800be8:	74 0a                	je     800bf4 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800bea:	83 c0 01             	add    $0x1,%eax
  800bed:	0f b6 10             	movzbl (%eax),%edx
  800bf0:	84 d2                	test   %dl,%dl
  800bf2:	75 ee                	jne    800be2 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800bf4:	5d                   	pop    %ebp
  800bf5:	c3                   	ret    

00800bf6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800bf6:	55                   	push   %ebp
  800bf7:	89 e5                	mov    %esp,%ebp
  800bf9:	83 ec 0c             	sub    $0xc,%esp
  800bfc:	89 1c 24             	mov    %ebx,(%esp)
  800bff:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c03:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800c07:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c0a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c0d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800c10:	85 c9                	test   %ecx,%ecx
  800c12:	74 30                	je     800c44 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800c14:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c1a:	75 25                	jne    800c41 <memset+0x4b>
  800c1c:	f6 c1 03             	test   $0x3,%cl
  800c1f:	75 20                	jne    800c41 <memset+0x4b>
		c &= 0xFF;
  800c21:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800c24:	89 d3                	mov    %edx,%ebx
  800c26:	c1 e3 08             	shl    $0x8,%ebx
  800c29:	89 d6                	mov    %edx,%esi
  800c2b:	c1 e6 18             	shl    $0x18,%esi
  800c2e:	89 d0                	mov    %edx,%eax
  800c30:	c1 e0 10             	shl    $0x10,%eax
  800c33:	09 f0                	or     %esi,%eax
  800c35:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  800c37:	09 d8                	or     %ebx,%eax
  800c39:	c1 e9 02             	shr    $0x2,%ecx
  800c3c:	fc                   	cld    
  800c3d:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800c3f:	eb 03                	jmp    800c44 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c41:	fc                   	cld    
  800c42:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800c44:	89 f8                	mov    %edi,%eax
  800c46:	8b 1c 24             	mov    (%esp),%ebx
  800c49:	8b 74 24 04          	mov    0x4(%esp),%esi
  800c4d:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800c51:	89 ec                	mov    %ebp,%esp
  800c53:	5d                   	pop    %ebp
  800c54:	c3                   	ret    

00800c55 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c55:	55                   	push   %ebp
  800c56:	89 e5                	mov    %esp,%ebp
  800c58:	83 ec 08             	sub    $0x8,%esp
  800c5b:	89 34 24             	mov    %esi,(%esp)
  800c5e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800c62:	8b 45 08             	mov    0x8(%ebp),%eax
  800c65:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800c68:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800c6b:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800c6d:	39 c6                	cmp    %eax,%esi
  800c6f:	73 35                	jae    800ca6 <memmove+0x51>
  800c71:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c74:	39 d0                	cmp    %edx,%eax
  800c76:	73 2e                	jae    800ca6 <memmove+0x51>
		s += n;
		d += n;
  800c78:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c7a:	f6 c2 03             	test   $0x3,%dl
  800c7d:	75 1b                	jne    800c9a <memmove+0x45>
  800c7f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c85:	75 13                	jne    800c9a <memmove+0x45>
  800c87:	f6 c1 03             	test   $0x3,%cl
  800c8a:	75 0e                	jne    800c9a <memmove+0x45>
			asm volatile("std; rep movsl\n"
  800c8c:	83 ef 04             	sub    $0x4,%edi
  800c8f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c92:	c1 e9 02             	shr    $0x2,%ecx
  800c95:	fd                   	std    
  800c96:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c98:	eb 09                	jmp    800ca3 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800c9a:	83 ef 01             	sub    $0x1,%edi
  800c9d:	8d 72 ff             	lea    -0x1(%edx),%esi
  800ca0:	fd                   	std    
  800ca1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ca3:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ca4:	eb 20                	jmp    800cc6 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ca6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800cac:	75 15                	jne    800cc3 <memmove+0x6e>
  800cae:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800cb4:	75 0d                	jne    800cc3 <memmove+0x6e>
  800cb6:	f6 c1 03             	test   $0x3,%cl
  800cb9:	75 08                	jne    800cc3 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  800cbb:	c1 e9 02             	shr    $0x2,%ecx
  800cbe:	fc                   	cld    
  800cbf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800cc1:	eb 03                	jmp    800cc6 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800cc3:	fc                   	cld    
  800cc4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800cc6:	8b 34 24             	mov    (%esp),%esi
  800cc9:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800ccd:	89 ec                	mov    %ebp,%esp
  800ccf:	5d                   	pop    %ebp
  800cd0:	c3                   	ret    

00800cd1 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800cd1:	55                   	push   %ebp
  800cd2:	89 e5                	mov    %esp,%ebp
  800cd4:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800cd7:	8b 45 10             	mov    0x10(%ebp),%eax
  800cda:	89 44 24 08          	mov    %eax,0x8(%esp)
  800cde:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ce1:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ce5:	8b 45 08             	mov    0x8(%ebp),%eax
  800ce8:	89 04 24             	mov    %eax,(%esp)
  800ceb:	e8 65 ff ff ff       	call   800c55 <memmove>
}
  800cf0:	c9                   	leave  
  800cf1:	c3                   	ret    

00800cf2 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800cf2:	55                   	push   %ebp
  800cf3:	89 e5                	mov    %esp,%ebp
  800cf5:	57                   	push   %edi
  800cf6:	56                   	push   %esi
  800cf7:	53                   	push   %ebx
  800cf8:	8b 75 08             	mov    0x8(%ebp),%esi
  800cfb:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800cfe:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d01:	85 c9                	test   %ecx,%ecx
  800d03:	74 36                	je     800d3b <memcmp+0x49>
		if (*s1 != *s2)
  800d05:	0f b6 06             	movzbl (%esi),%eax
  800d08:	0f b6 1f             	movzbl (%edi),%ebx
  800d0b:	38 d8                	cmp    %bl,%al
  800d0d:	74 20                	je     800d2f <memcmp+0x3d>
  800d0f:	eb 14                	jmp    800d25 <memcmp+0x33>
  800d11:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  800d16:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  800d1b:	83 c2 01             	add    $0x1,%edx
  800d1e:	83 e9 01             	sub    $0x1,%ecx
  800d21:	38 d8                	cmp    %bl,%al
  800d23:	74 12                	je     800d37 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  800d25:	0f b6 c0             	movzbl %al,%eax
  800d28:	0f b6 db             	movzbl %bl,%ebx
  800d2b:	29 d8                	sub    %ebx,%eax
  800d2d:	eb 11                	jmp    800d40 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d2f:	83 e9 01             	sub    $0x1,%ecx
  800d32:	ba 00 00 00 00       	mov    $0x0,%edx
  800d37:	85 c9                	test   %ecx,%ecx
  800d39:	75 d6                	jne    800d11 <memcmp+0x1f>
  800d3b:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800d40:	5b                   	pop    %ebx
  800d41:	5e                   	pop    %esi
  800d42:	5f                   	pop    %edi
  800d43:	5d                   	pop    %ebp
  800d44:	c3                   	ret    

00800d45 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800d45:	55                   	push   %ebp
  800d46:	89 e5                	mov    %esp,%ebp
  800d48:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800d4b:	89 c2                	mov    %eax,%edx
  800d4d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800d50:	39 d0                	cmp    %edx,%eax
  800d52:	73 15                	jae    800d69 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d54:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800d58:	38 08                	cmp    %cl,(%eax)
  800d5a:	75 06                	jne    800d62 <memfind+0x1d>
  800d5c:	eb 0b                	jmp    800d69 <memfind+0x24>
  800d5e:	38 08                	cmp    %cl,(%eax)
  800d60:	74 07                	je     800d69 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d62:	83 c0 01             	add    $0x1,%eax
  800d65:	39 c2                	cmp    %eax,%edx
  800d67:	77 f5                	ja     800d5e <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800d69:	5d                   	pop    %ebp
  800d6a:	c3                   	ret    

00800d6b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d6b:	55                   	push   %ebp
  800d6c:	89 e5                	mov    %esp,%ebp
  800d6e:	57                   	push   %edi
  800d6f:	56                   	push   %esi
  800d70:	53                   	push   %ebx
  800d71:	83 ec 04             	sub    $0x4,%esp
  800d74:	8b 55 08             	mov    0x8(%ebp),%edx
  800d77:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d7a:	0f b6 02             	movzbl (%edx),%eax
  800d7d:	3c 20                	cmp    $0x20,%al
  800d7f:	74 04                	je     800d85 <strtol+0x1a>
  800d81:	3c 09                	cmp    $0x9,%al
  800d83:	75 0e                	jne    800d93 <strtol+0x28>
		s++;
  800d85:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d88:	0f b6 02             	movzbl (%edx),%eax
  800d8b:	3c 20                	cmp    $0x20,%al
  800d8d:	74 f6                	je     800d85 <strtol+0x1a>
  800d8f:	3c 09                	cmp    $0x9,%al
  800d91:	74 f2                	je     800d85 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800d93:	3c 2b                	cmp    $0x2b,%al
  800d95:	75 0c                	jne    800da3 <strtol+0x38>
		s++;
  800d97:	83 c2 01             	add    $0x1,%edx
  800d9a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800da1:	eb 15                	jmp    800db8 <strtol+0x4d>
	else if (*s == '-')
  800da3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800daa:	3c 2d                	cmp    $0x2d,%al
  800dac:	75 0a                	jne    800db8 <strtol+0x4d>
		s++, neg = 1;
  800dae:	83 c2 01             	add    $0x1,%edx
  800db1:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800db8:	85 db                	test   %ebx,%ebx
  800dba:	0f 94 c0             	sete   %al
  800dbd:	74 05                	je     800dc4 <strtol+0x59>
  800dbf:	83 fb 10             	cmp    $0x10,%ebx
  800dc2:	75 18                	jne    800ddc <strtol+0x71>
  800dc4:	80 3a 30             	cmpb   $0x30,(%edx)
  800dc7:	75 13                	jne    800ddc <strtol+0x71>
  800dc9:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800dcd:	8d 76 00             	lea    0x0(%esi),%esi
  800dd0:	75 0a                	jne    800ddc <strtol+0x71>
		s += 2, base = 16;
  800dd2:	83 c2 02             	add    $0x2,%edx
  800dd5:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800dda:	eb 15                	jmp    800df1 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ddc:	84 c0                	test   %al,%al
  800dde:	66 90                	xchg   %ax,%ax
  800de0:	74 0f                	je     800df1 <strtol+0x86>
  800de2:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800de7:	80 3a 30             	cmpb   $0x30,(%edx)
  800dea:	75 05                	jne    800df1 <strtol+0x86>
		s++, base = 8;
  800dec:	83 c2 01             	add    $0x1,%edx
  800def:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800df1:	b8 00 00 00 00       	mov    $0x0,%eax
  800df6:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800df8:	0f b6 0a             	movzbl (%edx),%ecx
  800dfb:	89 cf                	mov    %ecx,%edi
  800dfd:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800e00:	80 fb 09             	cmp    $0x9,%bl
  800e03:	77 08                	ja     800e0d <strtol+0xa2>
			dig = *s - '0';
  800e05:	0f be c9             	movsbl %cl,%ecx
  800e08:	83 e9 30             	sub    $0x30,%ecx
  800e0b:	eb 1e                	jmp    800e2b <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  800e0d:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  800e10:	80 fb 19             	cmp    $0x19,%bl
  800e13:	77 08                	ja     800e1d <strtol+0xb2>
			dig = *s - 'a' + 10;
  800e15:	0f be c9             	movsbl %cl,%ecx
  800e18:	83 e9 57             	sub    $0x57,%ecx
  800e1b:	eb 0e                	jmp    800e2b <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  800e1d:	8d 5f bf             	lea    -0x41(%edi),%ebx
  800e20:	80 fb 19             	cmp    $0x19,%bl
  800e23:	77 15                	ja     800e3a <strtol+0xcf>
			dig = *s - 'A' + 10;
  800e25:	0f be c9             	movsbl %cl,%ecx
  800e28:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800e2b:	39 f1                	cmp    %esi,%ecx
  800e2d:	7d 0b                	jge    800e3a <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  800e2f:	83 c2 01             	add    $0x1,%edx
  800e32:	0f af c6             	imul   %esi,%eax
  800e35:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800e38:	eb be                	jmp    800df8 <strtol+0x8d>
  800e3a:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800e3c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e40:	74 05                	je     800e47 <strtol+0xdc>
		*endptr = (char *) s;
  800e42:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800e45:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800e47:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800e4b:	74 04                	je     800e51 <strtol+0xe6>
  800e4d:	89 c8                	mov    %ecx,%eax
  800e4f:	f7 d8                	neg    %eax
}
  800e51:	83 c4 04             	add    $0x4,%esp
  800e54:	5b                   	pop    %ebx
  800e55:	5e                   	pop    %esi
  800e56:	5f                   	pop    %edi
  800e57:	5d                   	pop    %ebp
  800e58:	c3                   	ret    
  800e59:	00 00                	add    %al,(%eax)
	...

00800e5c <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  800e5c:	55                   	push   %ebp
  800e5d:	89 e5                	mov    %esp,%ebp
  800e5f:	83 ec 08             	sub    $0x8,%esp
  800e62:	89 1c 24             	mov    %ebx,(%esp)
  800e65:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800e69:	ba 00 00 00 00       	mov    $0x0,%edx
  800e6e:	b8 01 00 00 00       	mov    $0x1,%eax
  800e73:	89 d1                	mov    %edx,%ecx
  800e75:	89 d3                	mov    %edx,%ebx
  800e77:	89 d7                	mov    %edx,%edi
  800e79:	51                   	push   %ecx
  800e7a:	52                   	push   %edx
  800e7b:	53                   	push   %ebx
  800e7c:	54                   	push   %esp
  800e7d:	55                   	push   %ebp
  800e7e:	56                   	push   %esi
  800e7f:	57                   	push   %edi
  800e80:	54                   	push   %esp
  800e81:	5d                   	pop    %ebp
  800e82:	8d 35 8a 0e 80 00    	lea    0x800e8a,%esi
  800e88:	0f 34                	sysenter 
  800e8a:	5f                   	pop    %edi
  800e8b:	5e                   	pop    %esi
  800e8c:	5d                   	pop    %ebp
  800e8d:	5c                   	pop    %esp
  800e8e:	5b                   	pop    %ebx
  800e8f:	5a                   	pop    %edx
  800e90:	59                   	pop    %ecx

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800e91:	8b 1c 24             	mov    (%esp),%ebx
  800e94:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800e98:	89 ec                	mov    %ebp,%esp
  800e9a:	5d                   	pop    %ebp
  800e9b:	c3                   	ret    

00800e9c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800e9c:	55                   	push   %ebp
  800e9d:	89 e5                	mov    %esp,%ebp
  800e9f:	83 ec 08             	sub    $0x8,%esp
  800ea2:	89 1c 24             	mov    %ebx,(%esp)
  800ea5:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800ea9:	b8 00 00 00 00       	mov    $0x0,%eax
  800eae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eb1:	8b 55 08             	mov    0x8(%ebp),%edx
  800eb4:	89 c3                	mov    %eax,%ebx
  800eb6:	89 c7                	mov    %eax,%edi
  800eb8:	51                   	push   %ecx
  800eb9:	52                   	push   %edx
  800eba:	53                   	push   %ebx
  800ebb:	54                   	push   %esp
  800ebc:	55                   	push   %ebp
  800ebd:	56                   	push   %esi
  800ebe:	57                   	push   %edi
  800ebf:	54                   	push   %esp
  800ec0:	5d                   	pop    %ebp
  800ec1:	8d 35 c9 0e 80 00    	lea    0x800ec9,%esi
  800ec7:	0f 34                	sysenter 
  800ec9:	5f                   	pop    %edi
  800eca:	5e                   	pop    %esi
  800ecb:	5d                   	pop    %ebp
  800ecc:	5c                   	pop    %esp
  800ecd:	5b                   	pop    %ebx
  800ece:	5a                   	pop    %edx
  800ecf:	59                   	pop    %ecx

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ed0:	8b 1c 24             	mov    (%esp),%ebx
  800ed3:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800ed7:	89 ec                	mov    %ebp,%esp
  800ed9:	5d                   	pop    %ebp
  800eda:	c3                   	ret    

00800edb <sys_exec>:
sys_env_set_prior(envid_t envid, uint32_t prior){
         return syscall(SYS_env_set_prior,1,envid, prior, 0, 0, 0);
}

int 
sys_exec(void* vph, uint32_t phnum, uint32_t esp, uint32_t eip){
  800edb:	55                   	push   %ebp
  800edc:	89 e5                	mov    %esp,%ebp
  800ede:	83 ec 08             	sub    $0x8,%esp
  800ee1:	89 1c 24             	mov    %ebx,(%esp)
  800ee4:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800ee8:	b8 10 00 00 00       	mov    $0x10,%eax
  800eed:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ef0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ef3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ef6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ef9:	51                   	push   %ecx
  800efa:	52                   	push   %edx
  800efb:	53                   	push   %ebx
  800efc:	54                   	push   %esp
  800efd:	55                   	push   %ebp
  800efe:	56                   	push   %esi
  800eff:	57                   	push   %edi
  800f00:	54                   	push   %esp
  800f01:	5d                   	pop    %ebp
  800f02:	8d 35 0a 0f 80 00    	lea    0x800f0a,%esi
  800f08:	0f 34                	sysenter 
  800f0a:	5f                   	pop    %edi
  800f0b:	5e                   	pop    %esi
  800f0c:	5d                   	pop    %ebp
  800f0d:	5c                   	pop    %esp
  800f0e:	5b                   	pop    %ebx
  800f0f:	5a                   	pop    %edx
  800f10:	59                   	pop    %ecx
}

int 
sys_exec(void* vph, uint32_t phnum, uint32_t esp, uint32_t eip){
         return syscall(SYS_exec, 0, (uint32_t)vph, phnum, esp, eip, 0);
}
  800f11:	8b 1c 24             	mov    (%esp),%ebx
  800f14:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800f18:	89 ec                	mov    %ebp,%esp
  800f1a:	5d                   	pop    %ebp
  800f1b:	c3                   	ret    

00800f1c <sys_env_set_prior>:
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}

int 
sys_env_set_prior(envid_t envid, uint32_t prior){
  800f1c:	55                   	push   %ebp
  800f1d:	89 e5                	mov    %esp,%ebp
  800f1f:	83 ec 28             	sub    $0x28,%esp
  800f22:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800f25:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800f28:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f2d:	b8 0f 00 00 00       	mov    $0xf,%eax
  800f32:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f35:	8b 55 08             	mov    0x8(%ebp),%edx
  800f38:	89 df                	mov    %ebx,%edi
  800f3a:	51                   	push   %ecx
  800f3b:	52                   	push   %edx
  800f3c:	53                   	push   %ebx
  800f3d:	54                   	push   %esp
  800f3e:	55                   	push   %ebp
  800f3f:	56                   	push   %esi
  800f40:	57                   	push   %edi
  800f41:	54                   	push   %esp
  800f42:	5d                   	pop    %ebp
  800f43:	8d 35 4b 0f 80 00    	lea    0x800f4b,%esi
  800f49:	0f 34                	sysenter 
  800f4b:	5f                   	pop    %edi
  800f4c:	5e                   	pop    %esi
  800f4d:	5d                   	pop    %ebp
  800f4e:	5c                   	pop    %esp
  800f4f:	5b                   	pop    %ebx
  800f50:	5a                   	pop    %edx
  800f51:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  800f52:	85 c0                	test   %eax,%eax
  800f54:	7e 28                	jle    800f7e <sys_env_set_prior+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f56:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f5a:	c7 44 24 0c 0f 00 00 	movl   $0xf,0xc(%esp)
  800f61:	00 
  800f62:	c7 44 24 08 a0 24 80 	movl   $0x8024a0,0x8(%esp)
  800f69:	00 
  800f6a:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  800f71:	00 
  800f72:	c7 04 24 bd 24 80 00 	movl   $0x8024bd,(%esp)
  800f79:	e8 76 0d 00 00       	call   801cf4 <_panic>
}

int 
sys_env_set_prior(envid_t envid, uint32_t prior){
         return syscall(SYS_env_set_prior,1,envid, prior, 0, 0, 0);
}
  800f7e:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800f81:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f84:	89 ec                	mov    %ebp,%esp
  800f86:	5d                   	pop    %ebp
  800f87:	c3                   	ret    

00800f88 <sys_sbrk>:
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}

int
sys_sbrk(uint32_t inc)
{
  800f88:	55                   	push   %ebp
  800f89:	89 e5                	mov    %esp,%ebp
  800f8b:	83 ec 08             	sub    $0x8,%esp
  800f8e:	89 1c 24             	mov    %ebx,(%esp)
  800f91:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800f95:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f9a:	b8 11 00 00 00       	mov    $0x11,%eax
  800f9f:	8b 55 08             	mov    0x8(%ebp),%edx
  800fa2:	89 cb                	mov    %ecx,%ebx
  800fa4:	89 cf                	mov    %ecx,%edi
  800fa6:	51                   	push   %ecx
  800fa7:	52                   	push   %edx
  800fa8:	53                   	push   %ebx
  800fa9:	54                   	push   %esp
  800faa:	55                   	push   %ebp
  800fab:	56                   	push   %esi
  800fac:	57                   	push   %edi
  800fad:	54                   	push   %esp
  800fae:	5d                   	pop    %ebp
  800faf:	8d 35 b7 0f 80 00    	lea    0x800fb7,%esi
  800fb5:	0f 34                	sysenter 
  800fb7:	5f                   	pop    %edi
  800fb8:	5e                   	pop    %esi
  800fb9:	5d                   	pop    %ebp
  800fba:	5c                   	pop    %esp
  800fbb:	5b                   	pop    %ebx
  800fbc:	5a                   	pop    %edx
  800fbd:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  800fbe:	8b 1c 24             	mov    (%esp),%ebx
  800fc1:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800fc5:	89 ec                	mov    %ebp,%esp
  800fc7:	5d                   	pop    %ebp
  800fc8:	c3                   	ret    

00800fc9 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800fc9:	55                   	push   %ebp
  800fca:	89 e5                	mov    %esp,%ebp
  800fcc:	83 ec 28             	sub    $0x28,%esp
  800fcf:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800fd2:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800fd5:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fda:	b8 0e 00 00 00       	mov    $0xe,%eax
  800fdf:	8b 55 08             	mov    0x8(%ebp),%edx
  800fe2:	89 cb                	mov    %ecx,%ebx
  800fe4:	89 cf                	mov    %ecx,%edi
  800fe6:	51                   	push   %ecx
  800fe7:	52                   	push   %edx
  800fe8:	53                   	push   %ebx
  800fe9:	54                   	push   %esp
  800fea:	55                   	push   %ebp
  800feb:	56                   	push   %esi
  800fec:	57                   	push   %edi
  800fed:	54                   	push   %esp
  800fee:	5d                   	pop    %ebp
  800fef:	8d 35 f7 0f 80 00    	lea    0x800ff7,%esi
  800ff5:	0f 34                	sysenter 
  800ff7:	5f                   	pop    %edi
  800ff8:	5e                   	pop    %esi
  800ff9:	5d                   	pop    %ebp
  800ffa:	5c                   	pop    %esp
  800ffb:	5b                   	pop    %ebx
  800ffc:	5a                   	pop    %edx
  800ffd:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  800ffe:	85 c0                	test   %eax,%eax
  801000:	7e 28                	jle    80102a <sys_ipc_recv+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  801002:	89 44 24 10          	mov    %eax,0x10(%esp)
  801006:	c7 44 24 0c 0e 00 00 	movl   $0xe,0xc(%esp)
  80100d:	00 
  80100e:	c7 44 24 08 a0 24 80 	movl   $0x8024a0,0x8(%esp)
  801015:	00 
  801016:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80101d:	00 
  80101e:	c7 04 24 bd 24 80 00 	movl   $0x8024bd,(%esp)
  801025:	e8 ca 0c 00 00       	call   801cf4 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80102a:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80102d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801030:	89 ec                	mov    %ebp,%esp
  801032:	5d                   	pop    %ebp
  801033:	c3                   	ret    

00801034 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801034:	55                   	push   %ebp
  801035:	89 e5                	mov    %esp,%ebp
  801037:	83 ec 08             	sub    $0x8,%esp
  80103a:	89 1c 24             	mov    %ebx,(%esp)
  80103d:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801041:	b8 0d 00 00 00       	mov    $0xd,%eax
  801046:	8b 7d 14             	mov    0x14(%ebp),%edi
  801049:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80104c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80104f:	8b 55 08             	mov    0x8(%ebp),%edx
  801052:	51                   	push   %ecx
  801053:	52                   	push   %edx
  801054:	53                   	push   %ebx
  801055:	54                   	push   %esp
  801056:	55                   	push   %ebp
  801057:	56                   	push   %esi
  801058:	57                   	push   %edi
  801059:	54                   	push   %esp
  80105a:	5d                   	pop    %ebp
  80105b:	8d 35 63 10 80 00    	lea    0x801063,%esi
  801061:	0f 34                	sysenter 
  801063:	5f                   	pop    %edi
  801064:	5e                   	pop    %esi
  801065:	5d                   	pop    %ebp
  801066:	5c                   	pop    %esp
  801067:	5b                   	pop    %ebx
  801068:	5a                   	pop    %edx
  801069:	59                   	pop    %ecx

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80106a:	8b 1c 24             	mov    (%esp),%ebx
  80106d:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801071:	89 ec                	mov    %ebp,%esp
  801073:	5d                   	pop    %ebp
  801074:	c3                   	ret    

00801075 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801075:	55                   	push   %ebp
  801076:	89 e5                	mov    %esp,%ebp
  801078:	83 ec 28             	sub    $0x28,%esp
  80107b:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80107e:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801081:	bb 00 00 00 00       	mov    $0x0,%ebx
  801086:	b8 0b 00 00 00       	mov    $0xb,%eax
  80108b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80108e:	8b 55 08             	mov    0x8(%ebp),%edx
  801091:	89 df                	mov    %ebx,%edi
  801093:	51                   	push   %ecx
  801094:	52                   	push   %edx
  801095:	53                   	push   %ebx
  801096:	54                   	push   %esp
  801097:	55                   	push   %ebp
  801098:	56                   	push   %esi
  801099:	57                   	push   %edi
  80109a:	54                   	push   %esp
  80109b:	5d                   	pop    %ebp
  80109c:	8d 35 a4 10 80 00    	lea    0x8010a4,%esi
  8010a2:	0f 34                	sysenter 
  8010a4:	5f                   	pop    %edi
  8010a5:	5e                   	pop    %esi
  8010a6:	5d                   	pop    %ebp
  8010a7:	5c                   	pop    %esp
  8010a8:	5b                   	pop    %ebx
  8010a9:	5a                   	pop    %edx
  8010aa:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8010ab:	85 c0                	test   %eax,%eax
  8010ad:	7e 28                	jle    8010d7 <sys_env_set_pgfault_upcall+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010af:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010b3:	c7 44 24 0c 0b 00 00 	movl   $0xb,0xc(%esp)
  8010ba:	00 
  8010bb:	c7 44 24 08 a0 24 80 	movl   $0x8024a0,0x8(%esp)
  8010c2:	00 
  8010c3:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8010ca:	00 
  8010cb:	c7 04 24 bd 24 80 00 	movl   $0x8024bd,(%esp)
  8010d2:	e8 1d 0c 00 00       	call   801cf4 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8010d7:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8010da:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8010dd:	89 ec                	mov    %ebp,%esp
  8010df:	5d                   	pop    %ebp
  8010e0:	c3                   	ret    

008010e1 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8010e1:	55                   	push   %ebp
  8010e2:	89 e5                	mov    %esp,%ebp
  8010e4:	83 ec 28             	sub    $0x28,%esp
  8010e7:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8010ea:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8010ed:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010f2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8010f7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010fa:	8b 55 08             	mov    0x8(%ebp),%edx
  8010fd:	89 df                	mov    %ebx,%edi
  8010ff:	51                   	push   %ecx
  801100:	52                   	push   %edx
  801101:	53                   	push   %ebx
  801102:	54                   	push   %esp
  801103:	55                   	push   %ebp
  801104:	56                   	push   %esi
  801105:	57                   	push   %edi
  801106:	54                   	push   %esp
  801107:	5d                   	pop    %ebp
  801108:	8d 35 10 11 80 00    	lea    0x801110,%esi
  80110e:	0f 34                	sysenter 
  801110:	5f                   	pop    %edi
  801111:	5e                   	pop    %esi
  801112:	5d                   	pop    %ebp
  801113:	5c                   	pop    %esp
  801114:	5b                   	pop    %ebx
  801115:	5a                   	pop    %edx
  801116:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801117:	85 c0                	test   %eax,%eax
  801119:	7e 28                	jle    801143 <sys_env_set_trapframe+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  80111b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80111f:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  801126:	00 
  801127:	c7 44 24 08 a0 24 80 	movl   $0x8024a0,0x8(%esp)
  80112e:	00 
  80112f:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801136:	00 
  801137:	c7 04 24 bd 24 80 00 	movl   $0x8024bd,(%esp)
  80113e:	e8 b1 0b 00 00       	call   801cf4 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801143:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801146:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801149:	89 ec                	mov    %ebp,%esp
  80114b:	5d                   	pop    %ebp
  80114c:	c3                   	ret    

0080114d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80114d:	55                   	push   %ebp
  80114e:	89 e5                	mov    %esp,%ebp
  801150:	83 ec 28             	sub    $0x28,%esp
  801153:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801156:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801159:	bb 00 00 00 00       	mov    $0x0,%ebx
  80115e:	b8 09 00 00 00       	mov    $0x9,%eax
  801163:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801166:	8b 55 08             	mov    0x8(%ebp),%edx
  801169:	89 df                	mov    %ebx,%edi
  80116b:	51                   	push   %ecx
  80116c:	52                   	push   %edx
  80116d:	53                   	push   %ebx
  80116e:	54                   	push   %esp
  80116f:	55                   	push   %ebp
  801170:	56                   	push   %esi
  801171:	57                   	push   %edi
  801172:	54                   	push   %esp
  801173:	5d                   	pop    %ebp
  801174:	8d 35 7c 11 80 00    	lea    0x80117c,%esi
  80117a:	0f 34                	sysenter 
  80117c:	5f                   	pop    %edi
  80117d:	5e                   	pop    %esi
  80117e:	5d                   	pop    %ebp
  80117f:	5c                   	pop    %esp
  801180:	5b                   	pop    %ebx
  801181:	5a                   	pop    %edx
  801182:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801183:	85 c0                	test   %eax,%eax
  801185:	7e 28                	jle    8011af <sys_env_set_status+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  801187:	89 44 24 10          	mov    %eax,0x10(%esp)
  80118b:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  801192:	00 
  801193:	c7 44 24 08 a0 24 80 	movl   $0x8024a0,0x8(%esp)
  80119a:	00 
  80119b:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8011a2:	00 
  8011a3:	c7 04 24 bd 24 80 00 	movl   $0x8024bd,(%esp)
  8011aa:	e8 45 0b 00 00       	call   801cf4 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8011af:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8011b2:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8011b5:	89 ec                	mov    %ebp,%esp
  8011b7:	5d                   	pop    %ebp
  8011b8:	c3                   	ret    

008011b9 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  8011b9:	55                   	push   %ebp
  8011ba:	89 e5                	mov    %esp,%ebp
  8011bc:	83 ec 28             	sub    $0x28,%esp
  8011bf:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8011c2:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8011c5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011ca:	b8 07 00 00 00       	mov    $0x7,%eax
  8011cf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011d2:	8b 55 08             	mov    0x8(%ebp),%edx
  8011d5:	89 df                	mov    %ebx,%edi
  8011d7:	51                   	push   %ecx
  8011d8:	52                   	push   %edx
  8011d9:	53                   	push   %ebx
  8011da:	54                   	push   %esp
  8011db:	55                   	push   %ebp
  8011dc:	56                   	push   %esi
  8011dd:	57                   	push   %edi
  8011de:	54                   	push   %esp
  8011df:	5d                   	pop    %ebp
  8011e0:	8d 35 e8 11 80 00    	lea    0x8011e8,%esi
  8011e6:	0f 34                	sysenter 
  8011e8:	5f                   	pop    %edi
  8011e9:	5e                   	pop    %esi
  8011ea:	5d                   	pop    %ebp
  8011eb:	5c                   	pop    %esp
  8011ec:	5b                   	pop    %ebx
  8011ed:	5a                   	pop    %edx
  8011ee:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8011ef:	85 c0                	test   %eax,%eax
  8011f1:	7e 28                	jle    80121b <sys_page_unmap+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011f3:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011f7:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8011fe:	00 
  8011ff:	c7 44 24 08 a0 24 80 	movl   $0x8024a0,0x8(%esp)
  801206:	00 
  801207:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80120e:	00 
  80120f:	c7 04 24 bd 24 80 00 	movl   $0x8024bd,(%esp)
  801216:	e8 d9 0a 00 00       	call   801cf4 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80121b:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80121e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801221:	89 ec                	mov    %ebp,%esp
  801223:	5d                   	pop    %ebp
  801224:	c3                   	ret    

00801225 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  801225:	55                   	push   %ebp
  801226:	89 e5                	mov    %esp,%ebp
  801228:	83 ec 28             	sub    $0x28,%esp
  80122b:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80122e:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801231:	8b 7d 18             	mov    0x18(%ebp),%edi
  801234:	0b 7d 14             	or     0x14(%ebp),%edi
  801237:	b8 06 00 00 00       	mov    $0x6,%eax
  80123c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80123f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801242:	8b 55 08             	mov    0x8(%ebp),%edx
  801245:	51                   	push   %ecx
  801246:	52                   	push   %edx
  801247:	53                   	push   %ebx
  801248:	54                   	push   %esp
  801249:	55                   	push   %ebp
  80124a:	56                   	push   %esi
  80124b:	57                   	push   %edi
  80124c:	54                   	push   %esp
  80124d:	5d                   	pop    %ebp
  80124e:	8d 35 56 12 80 00    	lea    0x801256,%esi
  801254:	0f 34                	sysenter 
  801256:	5f                   	pop    %edi
  801257:	5e                   	pop    %esi
  801258:	5d                   	pop    %ebp
  801259:	5c                   	pop    %esp
  80125a:	5b                   	pop    %ebx
  80125b:	5a                   	pop    %edx
  80125c:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80125d:	85 c0                	test   %eax,%eax
  80125f:	7e 28                	jle    801289 <sys_page_map+0x64>
		panic("syscall %d returned %d (> 0)", num, ret);
  801261:	89 44 24 10          	mov    %eax,0x10(%esp)
  801265:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  80126c:	00 
  80126d:	c7 44 24 08 a0 24 80 	movl   $0x8024a0,0x8(%esp)
  801274:	00 
  801275:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80127c:	00 
  80127d:	c7 04 24 bd 24 80 00 	movl   $0x8024bd,(%esp)
  801284:	e8 6b 0a 00 00       	call   801cf4 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}
  801289:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80128c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80128f:	89 ec                	mov    %ebp,%esp
  801291:	5d                   	pop    %ebp
  801292:	c3                   	ret    

00801293 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801293:	55                   	push   %ebp
  801294:	89 e5                	mov    %esp,%ebp
  801296:	83 ec 28             	sub    $0x28,%esp
  801299:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80129c:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80129f:	bf 00 00 00 00       	mov    $0x0,%edi
  8012a4:	b8 05 00 00 00       	mov    $0x5,%eax
  8012a9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8012ac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012af:	8b 55 08             	mov    0x8(%ebp),%edx
  8012b2:	51                   	push   %ecx
  8012b3:	52                   	push   %edx
  8012b4:	53                   	push   %ebx
  8012b5:	54                   	push   %esp
  8012b6:	55                   	push   %ebp
  8012b7:	56                   	push   %esi
  8012b8:	57                   	push   %edi
  8012b9:	54                   	push   %esp
  8012ba:	5d                   	pop    %ebp
  8012bb:	8d 35 c3 12 80 00    	lea    0x8012c3,%esi
  8012c1:	0f 34                	sysenter 
  8012c3:	5f                   	pop    %edi
  8012c4:	5e                   	pop    %esi
  8012c5:	5d                   	pop    %ebp
  8012c6:	5c                   	pop    %esp
  8012c7:	5b                   	pop    %ebx
  8012c8:	5a                   	pop    %edx
  8012c9:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8012ca:	85 c0                	test   %eax,%eax
  8012cc:	7e 28                	jle    8012f6 <sys_page_alloc+0x63>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012ce:	89 44 24 10          	mov    %eax,0x10(%esp)
  8012d2:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  8012d9:	00 
  8012da:	c7 44 24 08 a0 24 80 	movl   $0x8024a0,0x8(%esp)
  8012e1:	00 
  8012e2:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8012e9:	00 
  8012ea:	c7 04 24 bd 24 80 00 	movl   $0x8024bd,(%esp)
  8012f1:	e8 fe 09 00 00       	call   801cf4 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8012f6:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8012f9:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8012fc:	89 ec                	mov    %ebp,%esp
  8012fe:	5d                   	pop    %ebp
  8012ff:	c3                   	ret    

00801300 <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
{
  801300:	55                   	push   %ebp
  801301:	89 e5                	mov    %esp,%ebp
  801303:	83 ec 08             	sub    $0x8,%esp
  801306:	89 1c 24             	mov    %ebx,(%esp)
  801309:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80130d:	ba 00 00 00 00       	mov    $0x0,%edx
  801312:	b8 0c 00 00 00       	mov    $0xc,%eax
  801317:	89 d1                	mov    %edx,%ecx
  801319:	89 d3                	mov    %edx,%ebx
  80131b:	89 d7                	mov    %edx,%edi
  80131d:	51                   	push   %ecx
  80131e:	52                   	push   %edx
  80131f:	53                   	push   %ebx
  801320:	54                   	push   %esp
  801321:	55                   	push   %ebp
  801322:	56                   	push   %esi
  801323:	57                   	push   %edi
  801324:	54                   	push   %esp
  801325:	5d                   	pop    %ebp
  801326:	8d 35 2e 13 80 00    	lea    0x80132e,%esi
  80132c:	0f 34                	sysenter 
  80132e:	5f                   	pop    %edi
  80132f:	5e                   	pop    %esi
  801330:	5d                   	pop    %ebp
  801331:	5c                   	pop    %esp
  801332:	5b                   	pop    %ebx
  801333:	5a                   	pop    %edx
  801334:	59                   	pop    %ecx

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  801335:	8b 1c 24             	mov    (%esp),%ebx
  801338:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80133c:	89 ec                	mov    %ebp,%esp
  80133e:	5d                   	pop    %ebp
  80133f:	c3                   	ret    

00801340 <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
{
  801340:	55                   	push   %ebp
  801341:	89 e5                	mov    %esp,%ebp
  801343:	83 ec 08             	sub    $0x8,%esp
  801346:	89 1c 24             	mov    %ebx,(%esp)
  801349:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80134d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801352:	b8 04 00 00 00       	mov    $0x4,%eax
  801357:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80135a:	8b 55 08             	mov    0x8(%ebp),%edx
  80135d:	89 df                	mov    %ebx,%edi
  80135f:	51                   	push   %ecx
  801360:	52                   	push   %edx
  801361:	53                   	push   %ebx
  801362:	54                   	push   %esp
  801363:	55                   	push   %ebp
  801364:	56                   	push   %esi
  801365:	57                   	push   %edi
  801366:	54                   	push   %esp
  801367:	5d                   	pop    %ebp
  801368:	8d 35 70 13 80 00    	lea    0x801370,%esi
  80136e:	0f 34                	sysenter 
  801370:	5f                   	pop    %edi
  801371:	5e                   	pop    %esi
  801372:	5d                   	pop    %ebp
  801373:	5c                   	pop    %esp
  801374:	5b                   	pop    %ebx
  801375:	5a                   	pop    %edx
  801376:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  801377:	8b 1c 24             	mov    (%esp),%ebx
  80137a:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80137e:	89 ec                	mov    %ebp,%esp
  801380:	5d                   	pop    %ebp
  801381:	c3                   	ret    

00801382 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  801382:	55                   	push   %ebp
  801383:	89 e5                	mov    %esp,%ebp
  801385:	83 ec 08             	sub    $0x8,%esp
  801388:	89 1c 24             	mov    %ebx,(%esp)
  80138b:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80138f:	ba 00 00 00 00       	mov    $0x0,%edx
  801394:	b8 02 00 00 00       	mov    $0x2,%eax
  801399:	89 d1                	mov    %edx,%ecx
  80139b:	89 d3                	mov    %edx,%ebx
  80139d:	89 d7                	mov    %edx,%edi
  80139f:	51                   	push   %ecx
  8013a0:	52                   	push   %edx
  8013a1:	53                   	push   %ebx
  8013a2:	54                   	push   %esp
  8013a3:	55                   	push   %ebp
  8013a4:	56                   	push   %esi
  8013a5:	57                   	push   %edi
  8013a6:	54                   	push   %esp
  8013a7:	5d                   	pop    %ebp
  8013a8:	8d 35 b0 13 80 00    	lea    0x8013b0,%esi
  8013ae:	0f 34                	sysenter 
  8013b0:	5f                   	pop    %edi
  8013b1:	5e                   	pop    %esi
  8013b2:	5d                   	pop    %ebp
  8013b3:	5c                   	pop    %esp
  8013b4:	5b                   	pop    %ebx
  8013b5:	5a                   	pop    %edx
  8013b6:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8013b7:	8b 1c 24             	mov    (%esp),%ebx
  8013ba:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8013be:	89 ec                	mov    %ebp,%esp
  8013c0:	5d                   	pop    %ebp
  8013c1:	c3                   	ret    

008013c2 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  8013c2:	55                   	push   %ebp
  8013c3:	89 e5                	mov    %esp,%ebp
  8013c5:	83 ec 28             	sub    $0x28,%esp
  8013c8:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8013cb:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8013ce:	b9 00 00 00 00       	mov    $0x0,%ecx
  8013d3:	b8 03 00 00 00       	mov    $0x3,%eax
  8013d8:	8b 55 08             	mov    0x8(%ebp),%edx
  8013db:	89 cb                	mov    %ecx,%ebx
  8013dd:	89 cf                	mov    %ecx,%edi
  8013df:	51                   	push   %ecx
  8013e0:	52                   	push   %edx
  8013e1:	53                   	push   %ebx
  8013e2:	54                   	push   %esp
  8013e3:	55                   	push   %ebp
  8013e4:	56                   	push   %esi
  8013e5:	57                   	push   %edi
  8013e6:	54                   	push   %esp
  8013e7:	5d                   	pop    %ebp
  8013e8:	8d 35 f0 13 80 00    	lea    0x8013f0,%esi
  8013ee:	0f 34                	sysenter 
  8013f0:	5f                   	pop    %edi
  8013f1:	5e                   	pop    %esi
  8013f2:	5d                   	pop    %ebp
  8013f3:	5c                   	pop    %esp
  8013f4:	5b                   	pop    %ebx
  8013f5:	5a                   	pop    %edx
  8013f6:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8013f7:	85 c0                	test   %eax,%eax
  8013f9:	7e 28                	jle    801423 <sys_env_destroy+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  8013fb:	89 44 24 10          	mov    %eax,0x10(%esp)
  8013ff:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  801406:	00 
  801407:	c7 44 24 08 a0 24 80 	movl   $0x8024a0,0x8(%esp)
  80140e:	00 
  80140f:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801416:	00 
  801417:	c7 04 24 bd 24 80 00 	movl   $0x8024bd,(%esp)
  80141e:	e8 d1 08 00 00       	call   801cf4 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801423:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801426:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801429:	89 ec                	mov    %ebp,%esp
  80142b:	5d                   	pop    %ebp
  80142c:	c3                   	ret    
  80142d:	00 00                	add    %al,(%eax)
	...

00801430 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801430:	55                   	push   %ebp
  801431:	89 e5                	mov    %esp,%ebp
  801433:	8b 45 08             	mov    0x8(%ebp),%eax
  801436:	05 00 00 00 30       	add    $0x30000000,%eax
  80143b:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  80143e:	5d                   	pop    %ebp
  80143f:	c3                   	ret    

00801440 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801440:	55                   	push   %ebp
  801441:	89 e5                	mov    %esp,%ebp
  801443:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801446:	8b 45 08             	mov    0x8(%ebp),%eax
  801449:	89 04 24             	mov    %eax,(%esp)
  80144c:	e8 df ff ff ff       	call   801430 <fd2num>
  801451:	05 20 00 0d 00       	add    $0xd0020,%eax
  801456:	c1 e0 0c             	shl    $0xc,%eax
}
  801459:	c9                   	leave  
  80145a:	c3                   	ret    

0080145b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80145b:	55                   	push   %ebp
  80145c:	89 e5                	mov    %esp,%ebp
  80145e:	57                   	push   %edi
  80145f:	56                   	push   %esi
  801460:	53                   	push   %ebx
  801461:	8b 7d 08             	mov    0x8(%ebp),%edi
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  801464:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  801469:	a8 01                	test   $0x1,%al
  80146b:	74 36                	je     8014a3 <fd_alloc+0x48>
  80146d:	a1 00 00 74 ef       	mov    0xef740000,%eax
  801472:	a8 01                	test   $0x1,%al
  801474:	74 2d                	je     8014a3 <fd_alloc+0x48>
  801476:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  80147b:	b9 00 d0 7b ef       	mov    $0xef7bd000,%ecx
  801480:	be 00 00 40 ef       	mov    $0xef400000,%esi
  801485:	89 c3                	mov    %eax,%ebx
  801487:	89 c2                	mov    %eax,%edx
  801489:	c1 ea 16             	shr    $0x16,%edx
  80148c:	8b 14 91             	mov    (%ecx,%edx,4),%edx
  80148f:	f6 c2 01             	test   $0x1,%dl
  801492:	74 14                	je     8014a8 <fd_alloc+0x4d>
  801494:	89 c2                	mov    %eax,%edx
  801496:	c1 ea 0c             	shr    $0xc,%edx
  801499:	8b 14 96             	mov    (%esi,%edx,4),%edx
  80149c:	f6 c2 01             	test   $0x1,%dl
  80149f:	75 10                	jne    8014b1 <fd_alloc+0x56>
  8014a1:	eb 05                	jmp    8014a8 <fd_alloc+0x4d>
  8014a3:	bb 00 00 00 d0       	mov    $0xd0000000,%ebx
			*fd_store = fd;
  8014a8:	89 1f                	mov    %ebx,(%edi)
  8014aa:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  8014af:	eb 17                	jmp    8014c8 <fd_alloc+0x6d>
  8014b1:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8014b6:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8014bb:	75 c8                	jne    801485 <fd_alloc+0x2a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8014bd:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  8014c3:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  8014c8:	5b                   	pop    %ebx
  8014c9:	5e                   	pop    %esi
  8014ca:	5f                   	pop    %edi
  8014cb:	5d                   	pop    %ebp
  8014cc:	c3                   	ret    

008014cd <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8014cd:	55                   	push   %ebp
  8014ce:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8014d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8014d3:	83 f8 1f             	cmp    $0x1f,%eax
  8014d6:	77 36                	ja     80150e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8014d8:	05 00 00 0d 00       	add    $0xd0000,%eax
  8014dd:	c1 e0 0c             	shl    $0xc,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
  8014e0:	89 c2                	mov    %eax,%edx
  8014e2:	c1 ea 16             	shr    $0x16,%edx
  8014e5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8014ec:	f6 c2 01             	test   $0x1,%dl
  8014ef:	74 1d                	je     80150e <fd_lookup+0x41>
  8014f1:	89 c2                	mov    %eax,%edx
  8014f3:	c1 ea 0c             	shr    $0xc,%edx
  8014f6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8014fd:	f6 c2 01             	test   $0x1,%dl
  801500:	74 0c                	je     80150e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  801502:	8b 55 0c             	mov    0xc(%ebp),%edx
  801505:	89 02                	mov    %eax,(%edx)
  801507:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
  80150c:	eb 05                	jmp    801513 <fd_lookup+0x46>
  80150e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801513:	5d                   	pop    %ebp
  801514:	c3                   	ret    

00801515 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  801515:	55                   	push   %ebp
  801516:	89 e5                	mov    %esp,%ebp
  801518:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80151b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80151e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801522:	8b 45 08             	mov    0x8(%ebp),%eax
  801525:	89 04 24             	mov    %eax,(%esp)
  801528:	e8 a0 ff ff ff       	call   8014cd <fd_lookup>
  80152d:	85 c0                	test   %eax,%eax
  80152f:	78 0e                	js     80153f <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801531:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801534:	8b 55 0c             	mov    0xc(%ebp),%edx
  801537:	89 50 04             	mov    %edx,0x4(%eax)
  80153a:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  80153f:	c9                   	leave  
  801540:	c3                   	ret    

00801541 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801541:	55                   	push   %ebp
  801542:	89 e5                	mov    %esp,%ebp
  801544:	56                   	push   %esi
  801545:	53                   	push   %ebx
  801546:	83 ec 10             	sub    $0x10,%esp
  801549:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80154c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
// File functions
// --------------------------------------------------------------

static struct Dev *devtab[] =
{
	&devfile,
  80154f:	b8 04 30 80 00       	mov    $0x803004,%eax
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  801554:	ba 00 00 00 00       	mov    $0x0,%edx

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801559:	be 48 25 80 00       	mov    $0x802548,%esi
		if (devtab[i]->dev_id == dev_id) {
  80155e:	39 08                	cmp    %ecx,(%eax)
  801560:	75 10                	jne    801572 <dev_lookup+0x31>
  801562:	eb 04                	jmp    801568 <dev_lookup+0x27>
  801564:	39 08                	cmp    %ecx,(%eax)
  801566:	75 0a                	jne    801572 <dev_lookup+0x31>
			*dev = devtab[i];
  801568:	89 03                	mov    %eax,(%ebx)
  80156a:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  80156f:	90                   	nop
  801570:	eb 31                	jmp    8015a3 <dev_lookup+0x62>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801572:	83 c2 01             	add    $0x1,%edx
  801575:	8b 04 96             	mov    (%esi,%edx,4),%eax
  801578:	85 c0                	test   %eax,%eax
  80157a:	75 e8                	jne    801564 <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80157c:	a1 08 40 80 00       	mov    0x804008,%eax
  801581:	8b 40 48             	mov    0x48(%eax),%eax
  801584:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801588:	89 44 24 04          	mov    %eax,0x4(%esp)
  80158c:	c7 04 24 cc 24 80 00 	movl   $0x8024cc,(%esp)
  801593:	e8 a1 eb ff ff       	call   800139 <cprintf>
	*dev = 0;
  801598:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80159e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  8015a3:	83 c4 10             	add    $0x10,%esp
  8015a6:	5b                   	pop    %ebx
  8015a7:	5e                   	pop    %esi
  8015a8:	5d                   	pop    %ebp
  8015a9:	c3                   	ret    

008015aa <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  8015aa:	55                   	push   %ebp
  8015ab:	89 e5                	mov    %esp,%ebp
  8015ad:	53                   	push   %ebx
  8015ae:	83 ec 24             	sub    $0x24,%esp
  8015b1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015b4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015b7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8015be:	89 04 24             	mov    %eax,(%esp)
  8015c1:	e8 07 ff ff ff       	call   8014cd <fd_lookup>
  8015c6:	85 c0                	test   %eax,%eax
  8015c8:	78 53                	js     80161d <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015ca:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015d4:	8b 00                	mov    (%eax),%eax
  8015d6:	89 04 24             	mov    %eax,(%esp)
  8015d9:	e8 63 ff ff ff       	call   801541 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015de:	85 c0                	test   %eax,%eax
  8015e0:	78 3b                	js     80161d <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  8015e2:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8015e7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015ea:	83 7a 14 00          	cmpl   $0x0,0x14(%edx)
  8015ee:	74 2d                	je     80161d <fstat+0x73>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8015f0:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8015f3:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8015fa:	00 00 00 
	stat->st_isdir = 0;
  8015fd:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801604:	00 00 00 
	stat->st_dev = dev;
  801607:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80160a:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801610:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801614:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801617:	89 14 24             	mov    %edx,(%esp)
  80161a:	ff 50 14             	call   *0x14(%eax)
}
  80161d:	83 c4 24             	add    $0x24,%esp
  801620:	5b                   	pop    %ebx
  801621:	5d                   	pop    %ebp
  801622:	c3                   	ret    

00801623 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  801623:	55                   	push   %ebp
  801624:	89 e5                	mov    %esp,%ebp
  801626:	53                   	push   %ebx
  801627:	83 ec 24             	sub    $0x24,%esp
  80162a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80162d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801630:	89 44 24 04          	mov    %eax,0x4(%esp)
  801634:	89 1c 24             	mov    %ebx,(%esp)
  801637:	e8 91 fe ff ff       	call   8014cd <fd_lookup>
  80163c:	85 c0                	test   %eax,%eax
  80163e:	78 5f                	js     80169f <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801640:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801643:	89 44 24 04          	mov    %eax,0x4(%esp)
  801647:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80164a:	8b 00                	mov    (%eax),%eax
  80164c:	89 04 24             	mov    %eax,(%esp)
  80164f:	e8 ed fe ff ff       	call   801541 <dev_lookup>
ftruncate(int fdnum, off_t newsize)
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801654:	85 c0                	test   %eax,%eax
  801656:	78 47                	js     80169f <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801658:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80165b:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  80165f:	75 23                	jne    801684 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801661:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801666:	8b 40 48             	mov    0x48(%eax),%eax
  801669:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80166d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801671:	c7 04 24 ec 24 80 00 	movl   $0x8024ec,(%esp)
  801678:	e8 bc ea ff ff       	call   800139 <cprintf>
  80167d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801682:	eb 1b                	jmp    80169f <ftruncate+0x7c>
	}
	if (!dev->dev_trunc)
  801684:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801687:	8b 48 18             	mov    0x18(%eax),%ecx
  80168a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80168f:	85 c9                	test   %ecx,%ecx
  801691:	74 0c                	je     80169f <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801693:	8b 45 0c             	mov    0xc(%ebp),%eax
  801696:	89 44 24 04          	mov    %eax,0x4(%esp)
  80169a:	89 14 24             	mov    %edx,(%esp)
  80169d:	ff d1                	call   *%ecx
}
  80169f:	83 c4 24             	add    $0x24,%esp
  8016a2:	5b                   	pop    %ebx
  8016a3:	5d                   	pop    %ebp
  8016a4:	c3                   	ret    

008016a5 <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8016a5:	55                   	push   %ebp
  8016a6:	89 e5                	mov    %esp,%ebp
  8016a8:	53                   	push   %ebx
  8016a9:	83 ec 24             	sub    $0x24,%esp
  8016ac:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016af:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016b2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016b6:	89 1c 24             	mov    %ebx,(%esp)
  8016b9:	e8 0f fe ff ff       	call   8014cd <fd_lookup>
  8016be:	85 c0                	test   %eax,%eax
  8016c0:	78 66                	js     801728 <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016c2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016c5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016cc:	8b 00                	mov    (%eax),%eax
  8016ce:	89 04 24             	mov    %eax,(%esp)
  8016d1:	e8 6b fe ff ff       	call   801541 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016d6:	85 c0                	test   %eax,%eax
  8016d8:	78 4e                	js     801728 <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016da:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8016dd:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  8016e1:	75 23                	jne    801706 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8016e3:	a1 08 40 80 00       	mov    0x804008,%eax
  8016e8:	8b 40 48             	mov    0x48(%eax),%eax
  8016eb:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8016ef:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016f3:	c7 04 24 0d 25 80 00 	movl   $0x80250d,(%esp)
  8016fa:	e8 3a ea ff ff       	call   800139 <cprintf>
  8016ff:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801704:	eb 22                	jmp    801728 <write+0x83>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801706:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801709:	8b 48 0c             	mov    0xc(%eax),%ecx
  80170c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801711:	85 c9                	test   %ecx,%ecx
  801713:	74 13                	je     801728 <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801715:	8b 45 10             	mov    0x10(%ebp),%eax
  801718:	89 44 24 08          	mov    %eax,0x8(%esp)
  80171c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80171f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801723:	89 14 24             	mov    %edx,(%esp)
  801726:	ff d1                	call   *%ecx
}
  801728:	83 c4 24             	add    $0x24,%esp
  80172b:	5b                   	pop    %ebx
  80172c:	5d                   	pop    %ebp
  80172d:	c3                   	ret    

0080172e <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80172e:	55                   	push   %ebp
  80172f:	89 e5                	mov    %esp,%ebp
  801731:	53                   	push   %ebx
  801732:	83 ec 24             	sub    $0x24,%esp
  801735:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801738:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80173b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80173f:	89 1c 24             	mov    %ebx,(%esp)
  801742:	e8 86 fd ff ff       	call   8014cd <fd_lookup>
  801747:	85 c0                	test   %eax,%eax
  801749:	78 6b                	js     8017b6 <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80174b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80174e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801752:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801755:	8b 00                	mov    (%eax),%eax
  801757:	89 04 24             	mov    %eax,(%esp)
  80175a:	e8 e2 fd ff ff       	call   801541 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80175f:	85 c0                	test   %eax,%eax
  801761:	78 53                	js     8017b6 <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801763:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801766:	8b 42 08             	mov    0x8(%edx),%eax
  801769:	83 e0 03             	and    $0x3,%eax
  80176c:	83 f8 01             	cmp    $0x1,%eax
  80176f:	75 23                	jne    801794 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801771:	a1 08 40 80 00       	mov    0x804008,%eax
  801776:	8b 40 48             	mov    0x48(%eax),%eax
  801779:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80177d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801781:	c7 04 24 2a 25 80 00 	movl   $0x80252a,(%esp)
  801788:	e8 ac e9 ff ff       	call   800139 <cprintf>
  80178d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801792:	eb 22                	jmp    8017b6 <read+0x88>
	}
	if (!dev->dev_read)
  801794:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801797:	8b 48 08             	mov    0x8(%eax),%ecx
  80179a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80179f:	85 c9                	test   %ecx,%ecx
  8017a1:	74 13                	je     8017b6 <read+0x88>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8017a3:	8b 45 10             	mov    0x10(%ebp),%eax
  8017a6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8017aa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017ad:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017b1:	89 14 24             	mov    %edx,(%esp)
  8017b4:	ff d1                	call   *%ecx
}
  8017b6:	83 c4 24             	add    $0x24,%esp
  8017b9:	5b                   	pop    %ebx
  8017ba:	5d                   	pop    %ebp
  8017bb:	c3                   	ret    

008017bc <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8017bc:	55                   	push   %ebp
  8017bd:	89 e5                	mov    %esp,%ebp
  8017bf:	57                   	push   %edi
  8017c0:	56                   	push   %esi
  8017c1:	53                   	push   %ebx
  8017c2:	83 ec 1c             	sub    $0x1c,%esp
  8017c5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8017c8:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8017cb:	ba 00 00 00 00       	mov    $0x0,%edx
  8017d0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8017d5:	b8 00 00 00 00       	mov    $0x0,%eax
  8017da:	85 f6                	test   %esi,%esi
  8017dc:	74 29                	je     801807 <readn+0x4b>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8017de:	89 f0                	mov    %esi,%eax
  8017e0:	29 d0                	sub    %edx,%eax
  8017e2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8017e6:	03 55 0c             	add    0xc(%ebp),%edx
  8017e9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8017ed:	89 3c 24             	mov    %edi,(%esp)
  8017f0:	e8 39 ff ff ff       	call   80172e <read>
		if (m < 0)
  8017f5:	85 c0                	test   %eax,%eax
  8017f7:	78 0e                	js     801807 <readn+0x4b>
			return m;
		if (m == 0)
  8017f9:	85 c0                	test   %eax,%eax
  8017fb:	74 08                	je     801805 <readn+0x49>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8017fd:	01 c3                	add    %eax,%ebx
  8017ff:	89 da                	mov    %ebx,%edx
  801801:	39 f3                	cmp    %esi,%ebx
  801803:	72 d9                	jb     8017de <readn+0x22>
  801805:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801807:	83 c4 1c             	add    $0x1c,%esp
  80180a:	5b                   	pop    %ebx
  80180b:	5e                   	pop    %esi
  80180c:	5f                   	pop    %edi
  80180d:	5d                   	pop    %ebp
  80180e:	c3                   	ret    

0080180f <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80180f:	55                   	push   %ebp
  801810:	89 e5                	mov    %esp,%ebp
  801812:	56                   	push   %esi
  801813:	53                   	push   %ebx
  801814:	83 ec 20             	sub    $0x20,%esp
  801817:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80181a:	89 34 24             	mov    %esi,(%esp)
  80181d:	e8 0e fc ff ff       	call   801430 <fd2num>
  801822:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801825:	89 54 24 04          	mov    %edx,0x4(%esp)
  801829:	89 04 24             	mov    %eax,(%esp)
  80182c:	e8 9c fc ff ff       	call   8014cd <fd_lookup>
  801831:	89 c3                	mov    %eax,%ebx
  801833:	85 c0                	test   %eax,%eax
  801835:	78 05                	js     80183c <fd_close+0x2d>
  801837:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80183a:	74 0c                	je     801848 <fd_close+0x39>
	    || fd != fd2)
		return (must_exist ? r : 0);
  80183c:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  801840:	19 c0                	sbb    %eax,%eax
  801842:	f7 d0                	not    %eax
  801844:	21 c3                	and    %eax,%ebx
  801846:	eb 3d                	jmp    801885 <fd_close+0x76>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801848:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80184b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80184f:	8b 06                	mov    (%esi),%eax
  801851:	89 04 24             	mov    %eax,(%esp)
  801854:	e8 e8 fc ff ff       	call   801541 <dev_lookup>
  801859:	89 c3                	mov    %eax,%ebx
  80185b:	85 c0                	test   %eax,%eax
  80185d:	78 16                	js     801875 <fd_close+0x66>
		if (dev->dev_close)
  80185f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801862:	8b 40 10             	mov    0x10(%eax),%eax
  801865:	bb 00 00 00 00       	mov    $0x0,%ebx
  80186a:	85 c0                	test   %eax,%eax
  80186c:	74 07                	je     801875 <fd_close+0x66>
			r = (*dev->dev_close)(fd);
  80186e:	89 34 24             	mov    %esi,(%esp)
  801871:	ff d0                	call   *%eax
  801873:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801875:	89 74 24 04          	mov    %esi,0x4(%esp)
  801879:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801880:	e8 34 f9 ff ff       	call   8011b9 <sys_page_unmap>
	return r;
}
  801885:	89 d8                	mov    %ebx,%eax
  801887:	83 c4 20             	add    $0x20,%esp
  80188a:	5b                   	pop    %ebx
  80188b:	5e                   	pop    %esi
  80188c:	5d                   	pop    %ebp
  80188d:	c3                   	ret    

0080188e <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80188e:	55                   	push   %ebp
  80188f:	89 e5                	mov    %esp,%ebp
  801891:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801894:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801897:	89 44 24 04          	mov    %eax,0x4(%esp)
  80189b:	8b 45 08             	mov    0x8(%ebp),%eax
  80189e:	89 04 24             	mov    %eax,(%esp)
  8018a1:	e8 27 fc ff ff       	call   8014cd <fd_lookup>
  8018a6:	85 c0                	test   %eax,%eax
  8018a8:	78 13                	js     8018bd <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  8018aa:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8018b1:	00 
  8018b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018b5:	89 04 24             	mov    %eax,(%esp)
  8018b8:	e8 52 ff ff ff       	call   80180f <fd_close>
}
  8018bd:	c9                   	leave  
  8018be:	c3                   	ret    

008018bf <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  8018bf:	55                   	push   %ebp
  8018c0:	89 e5                	mov    %esp,%ebp
  8018c2:	83 ec 18             	sub    $0x18,%esp
  8018c5:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8018c8:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8018cb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8018d2:	00 
  8018d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8018d6:	89 04 24             	mov    %eax,(%esp)
  8018d9:	e8 79 03 00 00       	call   801c57 <open>
  8018de:	89 c3                	mov    %eax,%ebx
  8018e0:	85 c0                	test   %eax,%eax
  8018e2:	78 1b                	js     8018ff <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  8018e4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018e7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018eb:	89 1c 24             	mov    %ebx,(%esp)
  8018ee:	e8 b7 fc ff ff       	call   8015aa <fstat>
  8018f3:	89 c6                	mov    %eax,%esi
	close(fd);
  8018f5:	89 1c 24             	mov    %ebx,(%esp)
  8018f8:	e8 91 ff ff ff       	call   80188e <close>
  8018fd:	89 f3                	mov    %esi,%ebx
	return r;
}
  8018ff:	89 d8                	mov    %ebx,%eax
  801901:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801904:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801907:	89 ec                	mov    %ebp,%esp
  801909:	5d                   	pop    %ebp
  80190a:	c3                   	ret    

0080190b <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  80190b:	55                   	push   %ebp
  80190c:	89 e5                	mov    %esp,%ebp
  80190e:	53                   	push   %ebx
  80190f:	83 ec 14             	sub    $0x14,%esp
  801912:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  801917:	89 1c 24             	mov    %ebx,(%esp)
  80191a:	e8 6f ff ff ff       	call   80188e <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80191f:	83 c3 01             	add    $0x1,%ebx
  801922:	83 fb 20             	cmp    $0x20,%ebx
  801925:	75 f0                	jne    801917 <close_all+0xc>
		close(i);
}
  801927:	83 c4 14             	add    $0x14,%esp
  80192a:	5b                   	pop    %ebx
  80192b:	5d                   	pop    %ebp
  80192c:	c3                   	ret    

0080192d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80192d:	55                   	push   %ebp
  80192e:	89 e5                	mov    %esp,%ebp
  801930:	83 ec 58             	sub    $0x58,%esp
  801933:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801936:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801939:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80193c:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80193f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801942:	89 44 24 04          	mov    %eax,0x4(%esp)
  801946:	8b 45 08             	mov    0x8(%ebp),%eax
  801949:	89 04 24             	mov    %eax,(%esp)
  80194c:	e8 7c fb ff ff       	call   8014cd <fd_lookup>
  801951:	89 c3                	mov    %eax,%ebx
  801953:	85 c0                	test   %eax,%eax
  801955:	0f 88 e0 00 00 00    	js     801a3b <dup+0x10e>
		return r;
	close(newfdnum);
  80195b:	89 3c 24             	mov    %edi,(%esp)
  80195e:	e8 2b ff ff ff       	call   80188e <close>

	newfd = INDEX2FD(newfdnum);
  801963:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801969:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  80196c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80196f:	89 04 24             	mov    %eax,(%esp)
  801972:	e8 c9 fa ff ff       	call   801440 <fd2data>
  801977:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801979:	89 34 24             	mov    %esi,(%esp)
  80197c:	e8 bf fa ff ff       	call   801440 <fd2data>
  801981:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
  801984:	89 da                	mov    %ebx,%edx
  801986:	89 d8                	mov    %ebx,%eax
  801988:	c1 e8 16             	shr    $0x16,%eax
  80198b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801992:	a8 01                	test   $0x1,%al
  801994:	74 43                	je     8019d9 <dup+0xac>
  801996:	c1 ea 0c             	shr    $0xc,%edx
  801999:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  8019a0:	a8 01                	test   $0x1,%al
  8019a2:	74 35                	je     8019d9 <dup+0xac>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8019a4:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  8019ab:	25 07 0e 00 00       	and    $0xe07,%eax
  8019b0:	89 44 24 10          	mov    %eax,0x10(%esp)
  8019b4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8019b7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8019bb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8019c2:	00 
  8019c3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8019c7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019ce:	e8 52 f8 ff ff       	call   801225 <sys_page_map>
  8019d3:	89 c3                	mov    %eax,%ebx
  8019d5:	85 c0                	test   %eax,%eax
  8019d7:	78 3f                	js     801a18 <dup+0xeb>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8019d9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8019dc:	89 c2                	mov    %eax,%edx
  8019de:	c1 ea 0c             	shr    $0xc,%edx
  8019e1:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8019e8:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8019ee:	89 54 24 10          	mov    %edx,0x10(%esp)
  8019f2:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8019f6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8019fd:	00 
  8019fe:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a02:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a09:	e8 17 f8 ff ff       	call   801225 <sys_page_map>
  801a0e:	89 c3                	mov    %eax,%ebx
  801a10:	85 c0                	test   %eax,%eax
  801a12:	78 04                	js     801a18 <dup+0xeb>
  801a14:	89 fb                	mov    %edi,%ebx
  801a16:	eb 23                	jmp    801a3b <dup+0x10e>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801a18:	89 74 24 04          	mov    %esi,0x4(%esp)
  801a1c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a23:	e8 91 f7 ff ff       	call   8011b9 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801a28:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801a2b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a2f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a36:	e8 7e f7 ff ff       	call   8011b9 <sys_page_unmap>
	return r;
}
  801a3b:	89 d8                	mov    %ebx,%eax
  801a3d:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801a40:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801a43:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801a46:	89 ec                	mov    %ebp,%esp
  801a48:	5d                   	pop    %ebp
  801a49:	c3                   	ret    
	...

00801a4c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801a4c:	55                   	push   %ebp
  801a4d:	89 e5                	mov    %esp,%ebp
  801a4f:	83 ec 18             	sub    $0x18,%esp
  801a52:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801a55:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801a58:	89 c3                	mov    %eax,%ebx
  801a5a:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801a5c:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801a63:	75 11                	jne    801a76 <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801a65:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801a6c:	e8 df 02 00 00       	call   801d50 <ipc_find_env>
  801a71:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801a76:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801a7d:	00 
  801a7e:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801a85:	00 
  801a86:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a8a:	a1 00 40 80 00       	mov    0x804000,%eax
  801a8f:	89 04 24             	mov    %eax,(%esp)
  801a92:	e8 04 03 00 00       	call   801d9b <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801a97:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801a9e:	00 
  801a9f:	89 74 24 04          	mov    %esi,0x4(%esp)
  801aa3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801aaa:	e8 6a 03 00 00       	call   801e19 <ipc_recv>
}
  801aaf:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801ab2:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801ab5:	89 ec                	mov    %ebp,%esp
  801ab7:	5d                   	pop    %ebp
  801ab8:	c3                   	ret    

00801ab9 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801ab9:	55                   	push   %ebp
  801aba:	89 e5                	mov    %esp,%ebp
  801abc:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801abf:	8b 45 08             	mov    0x8(%ebp),%eax
  801ac2:	8b 40 0c             	mov    0xc(%eax),%eax
  801ac5:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801aca:	8b 45 0c             	mov    0xc(%ebp),%eax
  801acd:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801ad2:	ba 00 00 00 00       	mov    $0x0,%edx
  801ad7:	b8 02 00 00 00       	mov    $0x2,%eax
  801adc:	e8 6b ff ff ff       	call   801a4c <fsipc>
}
  801ae1:	c9                   	leave  
  801ae2:	c3                   	ret    

00801ae3 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801ae3:	55                   	push   %ebp
  801ae4:	89 e5                	mov    %esp,%ebp
  801ae6:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801ae9:	8b 45 08             	mov    0x8(%ebp),%eax
  801aec:	8b 40 0c             	mov    0xc(%eax),%eax
  801aef:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801af4:	ba 00 00 00 00       	mov    $0x0,%edx
  801af9:	b8 06 00 00 00       	mov    $0x6,%eax
  801afe:	e8 49 ff ff ff       	call   801a4c <fsipc>
}
  801b03:	c9                   	leave  
  801b04:	c3                   	ret    

00801b05 <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  801b05:	55                   	push   %ebp
  801b06:	89 e5                	mov    %esp,%ebp
  801b08:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801b0b:	ba 00 00 00 00       	mov    $0x0,%edx
  801b10:	b8 08 00 00 00       	mov    $0x8,%eax
  801b15:	e8 32 ff ff ff       	call   801a4c <fsipc>
}
  801b1a:	c9                   	leave  
  801b1b:	c3                   	ret    

00801b1c <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801b1c:	55                   	push   %ebp
  801b1d:	89 e5                	mov    %esp,%ebp
  801b1f:	53                   	push   %ebx
  801b20:	83 ec 14             	sub    $0x14,%esp
  801b23:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801b26:	8b 45 08             	mov    0x8(%ebp),%eax
  801b29:	8b 40 0c             	mov    0xc(%eax),%eax
  801b2c:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801b31:	ba 00 00 00 00       	mov    $0x0,%edx
  801b36:	b8 05 00 00 00       	mov    $0x5,%eax
  801b3b:	e8 0c ff ff ff       	call   801a4c <fsipc>
  801b40:	85 c0                	test   %eax,%eax
  801b42:	78 2b                	js     801b6f <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801b44:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801b4b:	00 
  801b4c:	89 1c 24             	mov    %ebx,(%esp)
  801b4f:	e8 16 ef ff ff       	call   800a6a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801b54:	a1 80 50 80 00       	mov    0x805080,%eax
  801b59:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801b5f:	a1 84 50 80 00       	mov    0x805084,%eax
  801b64:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  801b6a:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  801b6f:	83 c4 14             	add    $0x14,%esp
  801b72:	5b                   	pop    %ebx
  801b73:	5d                   	pop    %ebp
  801b74:	c3                   	ret    

00801b75 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801b75:	55                   	push   %ebp
  801b76:	89 e5                	mov    %esp,%ebp
  801b78:	83 ec 18             	sub    $0x18,%esp
  801b7b:	8b 45 10             	mov    0x10(%ebp),%eax
  801b7e:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801b83:	76 05                	jbe    801b8a <devfile_write+0x15>
  801b85:	b8 f8 0f 00 00       	mov    $0xff8,%eax
	// bytes than requested.
	// LAB 5: Your code here
        int r;
        if(n > sizeof(fsipcbuf.write.req_buf))
            n = sizeof(fsipcbuf.write.req_buf);
        fsipcbuf.write.req_fileid = fd->fd_file.id;
  801b8a:	8b 55 08             	mov    0x8(%ebp),%edx
  801b8d:	8b 52 0c             	mov    0xc(%edx),%edx
  801b90:	89 15 00 50 80 00    	mov    %edx,0x805000
        fsipcbuf.write.req_n = n;
  801b96:	a3 04 50 80 00       	mov    %eax,0x805004
        memmove(fsipcbuf.write.req_buf,buf,n);  
  801b9b:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b9f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ba2:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ba6:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  801bad:	e8 a3 f0 ff ff       	call   800c55 <memmove>
        r = fsipc(FSREQ_WRITE,NULL);
  801bb2:	ba 00 00 00 00       	mov    $0x0,%edx
  801bb7:	b8 04 00 00 00       	mov    $0x4,%eax
  801bbc:	e8 8b fe ff ff       	call   801a4c <fsipc>
        return r;
	//panic("devfile_write not implemented");
}
  801bc1:	c9                   	leave  
  801bc2:	c3                   	ret    

00801bc3 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801bc3:	55                   	push   %ebp
  801bc4:	89 e5                	mov    %esp,%ebp
  801bc6:	53                   	push   %ebx
  801bc7:	83 ec 14             	sub    $0x14,%esp
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
        int r;
        fsipcbuf.read.req_fileid = fd->fd_file.id;
  801bca:	8b 45 08             	mov    0x8(%ebp),%eax
  801bcd:	8b 40 0c             	mov    0xc(%eax),%eax
  801bd0:	a3 00 50 80 00       	mov    %eax,0x805000
        fsipcbuf.read.req_n = n;
  801bd5:	8b 45 10             	mov    0x10(%ebp),%eax
  801bd8:	a3 04 50 80 00       	mov    %eax,0x805004
        r = fsipc(FSREQ_READ,NULL);
  801bdd:	ba 00 00 00 00       	mov    $0x0,%edx
  801be2:	b8 03 00 00 00       	mov    $0x3,%eax
  801be7:	e8 60 fe ff ff       	call   801a4c <fsipc>
  801bec:	89 c3                	mov    %eax,%ebx
        if(r < 0)
  801bee:	85 c0                	test   %eax,%eax
  801bf0:	78 17                	js     801c09 <devfile_read+0x46>
           return r;
        memmove(buf,fsipcbuf.readRet.ret_buf,r);
  801bf2:	89 44 24 08          	mov    %eax,0x8(%esp)
  801bf6:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801bfd:	00 
  801bfe:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c01:	89 04 24             	mov    %eax,(%esp)
  801c04:	e8 4c f0 ff ff       	call   800c55 <memmove>
        return r;
	//panic("devfile_read not implemented");
}
  801c09:	89 d8                	mov    %ebx,%eax
  801c0b:	83 c4 14             	add    $0x14,%esp
  801c0e:	5b                   	pop    %ebx
  801c0f:	5d                   	pop    %ebp
  801c10:	c3                   	ret    

00801c11 <remove>:
}

// Delete a file
int
remove(const char *path)
{
  801c11:	55                   	push   %ebp
  801c12:	89 e5                	mov    %esp,%ebp
  801c14:	53                   	push   %ebx
  801c15:	83 ec 14             	sub    $0x14,%esp
  801c18:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  801c1b:	89 1c 24             	mov    %ebx,(%esp)
  801c1e:	e8 fd ed ff ff       	call   800a20 <strlen>
  801c23:	89 c2                	mov    %eax,%edx
  801c25:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  801c2a:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
  801c30:	7f 1f                	jg     801c51 <remove+0x40>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  801c32:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c36:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801c3d:	e8 28 ee ff ff       	call   800a6a <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  801c42:	ba 00 00 00 00       	mov    $0x0,%edx
  801c47:	b8 07 00 00 00       	mov    $0x7,%eax
  801c4c:	e8 fb fd ff ff       	call   801a4c <fsipc>
}
  801c51:	83 c4 14             	add    $0x14,%esp
  801c54:	5b                   	pop    %ebx
  801c55:	5d                   	pop    %ebp
  801c56:	c3                   	ret    

00801c57 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801c57:	55                   	push   %ebp
  801c58:	89 e5                	mov    %esp,%ebp
  801c5a:	83 ec 28             	sub    $0x28,%esp
  801c5d:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801c60:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801c63:	8b 75 08             	mov    0x8(%ebp),%esi
	// If any step after fd_alloc fails, use fd_close to free the
	// file descriptor.

	// LAB 5: Your code here.
        struct Fd* fd;
        if(strlen(path) > MAXPATHLEN)
  801c66:	89 34 24             	mov    %esi,(%esp)
  801c69:	e8 b2 ed ff ff       	call   800a20 <strlen>
  801c6e:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801c73:	3d 00 04 00 00       	cmp    $0x400,%eax
  801c78:	7f 6d                	jg     801ce7 <open+0x90>
            return -E_BAD_PATH;
        int r;
        r = fd_alloc(&fd);
  801c7a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c7d:	89 04 24             	mov    %eax,(%esp)
  801c80:	e8 d6 f7 ff ff       	call   80145b <fd_alloc>
  801c85:	89 c3                	mov    %eax,%ebx
        if(r < 0)
  801c87:	85 c0                	test   %eax,%eax
  801c89:	78 5c                	js     801ce7 <open+0x90>
           return r;
        fsipcbuf.open.req_omode = mode;
  801c8b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c8e:	a3 00 54 80 00       	mov    %eax,0x805400
        memmove(fsipcbuf.open.req_path,path,strlen(path)+1);
  801c93:	89 34 24             	mov    %esi,(%esp)
  801c96:	e8 85 ed ff ff       	call   800a20 <strlen>
  801c9b:	83 c0 01             	add    $0x1,%eax
  801c9e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ca2:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ca6:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801cad:	e8 a3 ef ff ff       	call   800c55 <memmove>
        r = fsipc(FSREQ_OPEN,(void*)fd);
  801cb2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801cb5:	b8 01 00 00 00       	mov    $0x1,%eax
  801cba:	e8 8d fd ff ff       	call   801a4c <fsipc>
  801cbf:	89 c3                	mov    %eax,%ebx
        if(r < 0){
  801cc1:	85 c0                	test   %eax,%eax
  801cc3:	79 15                	jns    801cda <open+0x83>
             fd_close(fd,0);
  801cc5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801ccc:	00 
  801ccd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cd0:	89 04 24             	mov    %eax,(%esp)
  801cd3:	e8 37 fb ff ff       	call   80180f <fd_close>
             return r;
  801cd8:	eb 0d                	jmp    801ce7 <open+0x90>
        }
        return fd2num(fd);
  801cda:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cdd:	89 04 24             	mov    %eax,(%esp)
  801ce0:	e8 4b f7 ff ff       	call   801430 <fd2num>
  801ce5:	89 c3                	mov    %eax,%ebx
	//panic("open not implemented");
}
  801ce7:	89 d8                	mov    %ebx,%eax
  801ce9:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801cec:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801cef:	89 ec                	mov    %ebp,%esp
  801cf1:	5d                   	pop    %ebp
  801cf2:	c3                   	ret    
	...

00801cf4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801cf4:	55                   	push   %ebp
  801cf5:	89 e5                	mov    %esp,%ebp
  801cf7:	56                   	push   %esi
  801cf8:	53                   	push   %ebx
  801cf9:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  801cfc:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801cff:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  801d05:	e8 78 f6 ff ff       	call   801382 <sys_getenvid>
  801d0a:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d0d:	89 54 24 10          	mov    %edx,0x10(%esp)
  801d11:	8b 55 08             	mov    0x8(%ebp),%edx
  801d14:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801d18:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801d1c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d20:	c7 04 24 50 25 80 00 	movl   $0x802550,(%esp)
  801d27:	e8 0d e4 ff ff       	call   800139 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801d2c:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d30:	8b 45 10             	mov    0x10(%ebp),%eax
  801d33:	89 04 24             	mov    %eax,(%esp)
  801d36:	e8 9d e3 ff ff       	call   8000d8 <vcprintf>
	cprintf("\n");
  801d3b:	c7 04 24 0c 21 80 00 	movl   $0x80210c,(%esp)
  801d42:	e8 f2 e3 ff ff       	call   800139 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801d47:	cc                   	int3   
  801d48:	eb fd                	jmp    801d47 <_panic+0x53>
  801d4a:	00 00                	add    %al,(%eax)
  801d4c:	00 00                	add    %al,(%eax)
	...

00801d50 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801d50:	55                   	push   %ebp
  801d51:	89 e5                	mov    %esp,%ebp
  801d53:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801d56:	8b 15 50 00 c0 ee    	mov    0xeec00050,%edx
  801d5c:	b8 01 00 00 00       	mov    $0x1,%eax
  801d61:	39 ca                	cmp    %ecx,%edx
  801d63:	75 04                	jne    801d69 <ipc_find_env+0x19>
  801d65:	b0 00                	mov    $0x0,%al
  801d67:	eb 12                	jmp    801d7b <ipc_find_env+0x2b>
  801d69:	89 c2                	mov    %eax,%edx
  801d6b:	c1 e2 07             	shl    $0x7,%edx
  801d6e:	8d 94 82 50 00 c0 ee 	lea    -0x113fffb0(%edx,%eax,4),%edx
  801d75:	8b 12                	mov    (%edx),%edx
  801d77:	39 ca                	cmp    %ecx,%edx
  801d79:	75 10                	jne    801d8b <ipc_find_env+0x3b>
			return envs[i].env_id;
  801d7b:	89 c2                	mov    %eax,%edx
  801d7d:	c1 e2 07             	shl    $0x7,%edx
  801d80:	8d 84 82 48 00 c0 ee 	lea    -0x113fffb8(%edx,%eax,4),%eax
  801d87:	8b 00                	mov    (%eax),%eax
  801d89:	eb 0e                	jmp    801d99 <ipc_find_env+0x49>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801d8b:	83 c0 01             	add    $0x1,%eax
  801d8e:	3d 00 04 00 00       	cmp    $0x400,%eax
  801d93:	75 d4                	jne    801d69 <ipc_find_env+0x19>
  801d95:	66 b8 00 00          	mov    $0x0,%ax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  801d99:	5d                   	pop    %ebp
  801d9a:	c3                   	ret    

00801d9b <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801d9b:	55                   	push   %ebp
  801d9c:	89 e5                	mov    %esp,%ebp
  801d9e:	57                   	push   %edi
  801d9f:	56                   	push   %esi
  801da0:	53                   	push   %ebx
  801da1:	83 ec 1c             	sub    $0x1c,%esp
  801da4:	8b 75 08             	mov    0x8(%ebp),%esi
  801da7:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801daa:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        int ret;
        while(1){
           if(pg)
  801dad:	85 db                	test   %ebx,%ebx
  801daf:	74 19                	je     801dca <ipc_send+0x2f>
              ret = sys_ipc_try_send(to_env,val,pg,perm);
  801db1:	8b 45 14             	mov    0x14(%ebp),%eax
  801db4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801db8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801dbc:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801dc0:	89 34 24             	mov    %esi,(%esp)
  801dc3:	e8 6c f2 ff ff       	call   801034 <sys_ipc_try_send>
  801dc8:	eb 1b                	jmp    801de5 <ipc_send+0x4a>
           else
              ret = sys_ipc_try_send(to_env,val,(void*)UTOP,perm);
  801dca:	8b 45 14             	mov    0x14(%ebp),%eax
  801dcd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801dd1:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  801dd8:	ee 
  801dd9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801ddd:	89 34 24             	mov    %esi,(%esp)
  801de0:	e8 4f f2 ff ff       	call   801034 <sys_ipc_try_send>
           if(ret == 0)
  801de5:	85 c0                	test   %eax,%eax
  801de7:	74 28                	je     801e11 <ipc_send+0x76>
              return;
           if(ret != -E_IPC_NOT_RECV)
  801de9:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801dec:	74 1c                	je     801e0a <ipc_send+0x6f>
              panic("ipc send error");
  801dee:	c7 44 24 08 74 25 80 	movl   $0x802574,0x8(%esp)
  801df5:	00 
  801df6:	c7 44 24 04 46 00 00 	movl   $0x46,0x4(%esp)
  801dfd:	00 
  801dfe:	c7 04 24 83 25 80 00 	movl   $0x802583,(%esp)
  801e05:	e8 ea fe ff ff       	call   801cf4 <_panic>
           sys_yield();
  801e0a:	e8 f1 f4 ff ff       	call   801300 <sys_yield>
        }
  801e0f:	eb 9c                	jmp    801dad <ipc_send+0x12>
	//panic("ipc_send not implemented");
}
  801e11:	83 c4 1c             	add    $0x1c,%esp
  801e14:	5b                   	pop    %ebx
  801e15:	5e                   	pop    %esi
  801e16:	5f                   	pop    %edi
  801e17:	5d                   	pop    %ebp
  801e18:	c3                   	ret    

00801e19 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e19:	55                   	push   %ebp
  801e1a:	89 e5                	mov    %esp,%ebp
  801e1c:	56                   	push   %esi
  801e1d:	53                   	push   %ebx
  801e1e:	83 ec 10             	sub    $0x10,%esp
  801e21:	8b 75 08             	mov    0x8(%ebp),%esi
  801e24:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e27:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        int ret;
        if(!pg)
  801e2a:	85 c0                	test   %eax,%eax
  801e2c:	75 0e                	jne    801e3c <ipc_recv+0x23>
           ret = sys_ipc_recv((void*)UTOP);
  801e2e:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  801e35:	e8 8f f1 ff ff       	call   800fc9 <sys_ipc_recv>
  801e3a:	eb 08                	jmp    801e44 <ipc_recv+0x2b>
        else
           ret = sys_ipc_recv(pg);
  801e3c:	89 04 24             	mov    %eax,(%esp)
  801e3f:	e8 85 f1 ff ff       	call   800fc9 <sys_ipc_recv>
        if(ret == 0){
  801e44:	85 c0                	test   %eax,%eax
  801e46:	75 26                	jne    801e6e <ipc_recv+0x55>
           if(from_env_store)
  801e48:	85 f6                	test   %esi,%esi
  801e4a:	74 0a                	je     801e56 <ipc_recv+0x3d>
              *from_env_store = thisenv->env_ipc_from;
  801e4c:	a1 08 40 80 00       	mov    0x804008,%eax
  801e51:	8b 40 78             	mov    0x78(%eax),%eax
  801e54:	89 06                	mov    %eax,(%esi)
           if(perm_store)
  801e56:	85 db                	test   %ebx,%ebx
  801e58:	74 0a                	je     801e64 <ipc_recv+0x4b>
              *perm_store = thisenv->env_ipc_perm;
  801e5a:	a1 08 40 80 00       	mov    0x804008,%eax
  801e5f:	8b 40 7c             	mov    0x7c(%eax),%eax
  801e62:	89 03                	mov    %eax,(%ebx)
           return thisenv->env_ipc_value;
  801e64:	a1 08 40 80 00       	mov    0x804008,%eax
  801e69:	8b 40 74             	mov    0x74(%eax),%eax
  801e6c:	eb 14                	jmp    801e82 <ipc_recv+0x69>
        }
        else{
           if(from_env_store)
  801e6e:	85 f6                	test   %esi,%esi
  801e70:	74 06                	je     801e78 <ipc_recv+0x5f>
              *from_env_store = 0;
  801e72:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
           if(perm_store)
  801e78:	85 db                	test   %ebx,%ebx
  801e7a:	74 06                	je     801e82 <ipc_recv+0x69>
              *perm_store = 0;
  801e7c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
           return ret;
        }
	//panic("ipc_recv not implemented");
	return 0;
}
  801e82:	83 c4 10             	add    $0x10,%esp
  801e85:	5b                   	pop    %ebx
  801e86:	5e                   	pop    %esi
  801e87:	5d                   	pop    %ebp
  801e88:	c3                   	ret    
  801e89:	00 00                	add    %al,(%eax)
  801e8b:	00 00                	add    %al,(%eax)
  801e8d:	00 00                	add    %al,(%eax)
	...

00801e90 <__udivdi3>:
  801e90:	55                   	push   %ebp
  801e91:	89 e5                	mov    %esp,%ebp
  801e93:	57                   	push   %edi
  801e94:	56                   	push   %esi
  801e95:	83 ec 10             	sub    $0x10,%esp
  801e98:	8b 45 14             	mov    0x14(%ebp),%eax
  801e9b:	8b 55 08             	mov    0x8(%ebp),%edx
  801e9e:	8b 75 10             	mov    0x10(%ebp),%esi
  801ea1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801ea4:	85 c0                	test   %eax,%eax
  801ea6:	89 55 f0             	mov    %edx,-0x10(%ebp)
  801ea9:	75 35                	jne    801ee0 <__udivdi3+0x50>
  801eab:	39 fe                	cmp    %edi,%esi
  801ead:	77 61                	ja     801f10 <__udivdi3+0x80>
  801eaf:	85 f6                	test   %esi,%esi
  801eb1:	75 0b                	jne    801ebe <__udivdi3+0x2e>
  801eb3:	b8 01 00 00 00       	mov    $0x1,%eax
  801eb8:	31 d2                	xor    %edx,%edx
  801eba:	f7 f6                	div    %esi
  801ebc:	89 c6                	mov    %eax,%esi
  801ebe:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  801ec1:	31 d2                	xor    %edx,%edx
  801ec3:	89 f8                	mov    %edi,%eax
  801ec5:	f7 f6                	div    %esi
  801ec7:	89 c7                	mov    %eax,%edi
  801ec9:	89 c8                	mov    %ecx,%eax
  801ecb:	f7 f6                	div    %esi
  801ecd:	89 c1                	mov    %eax,%ecx
  801ecf:	89 fa                	mov    %edi,%edx
  801ed1:	89 c8                	mov    %ecx,%eax
  801ed3:	83 c4 10             	add    $0x10,%esp
  801ed6:	5e                   	pop    %esi
  801ed7:	5f                   	pop    %edi
  801ed8:	5d                   	pop    %ebp
  801ed9:	c3                   	ret    
  801eda:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801ee0:	39 f8                	cmp    %edi,%eax
  801ee2:	77 1c                	ja     801f00 <__udivdi3+0x70>
  801ee4:	0f bd d0             	bsr    %eax,%edx
  801ee7:	83 f2 1f             	xor    $0x1f,%edx
  801eea:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801eed:	75 39                	jne    801f28 <__udivdi3+0x98>
  801eef:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  801ef2:	0f 86 a0 00 00 00    	jbe    801f98 <__udivdi3+0x108>
  801ef8:	39 f8                	cmp    %edi,%eax
  801efa:	0f 82 98 00 00 00    	jb     801f98 <__udivdi3+0x108>
  801f00:	31 ff                	xor    %edi,%edi
  801f02:	31 c9                	xor    %ecx,%ecx
  801f04:	89 c8                	mov    %ecx,%eax
  801f06:	89 fa                	mov    %edi,%edx
  801f08:	83 c4 10             	add    $0x10,%esp
  801f0b:	5e                   	pop    %esi
  801f0c:	5f                   	pop    %edi
  801f0d:	5d                   	pop    %ebp
  801f0e:	c3                   	ret    
  801f0f:	90                   	nop
  801f10:	89 d1                	mov    %edx,%ecx
  801f12:	89 fa                	mov    %edi,%edx
  801f14:	89 c8                	mov    %ecx,%eax
  801f16:	31 ff                	xor    %edi,%edi
  801f18:	f7 f6                	div    %esi
  801f1a:	89 c1                	mov    %eax,%ecx
  801f1c:	89 fa                	mov    %edi,%edx
  801f1e:	89 c8                	mov    %ecx,%eax
  801f20:	83 c4 10             	add    $0x10,%esp
  801f23:	5e                   	pop    %esi
  801f24:	5f                   	pop    %edi
  801f25:	5d                   	pop    %ebp
  801f26:	c3                   	ret    
  801f27:	90                   	nop
  801f28:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801f2c:	89 f2                	mov    %esi,%edx
  801f2e:	d3 e0                	shl    %cl,%eax
  801f30:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801f33:	b8 20 00 00 00       	mov    $0x20,%eax
  801f38:	2b 45 f4             	sub    -0xc(%ebp),%eax
  801f3b:	89 c1                	mov    %eax,%ecx
  801f3d:	d3 ea                	shr    %cl,%edx
  801f3f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801f43:	0b 55 ec             	or     -0x14(%ebp),%edx
  801f46:	d3 e6                	shl    %cl,%esi
  801f48:	89 c1                	mov    %eax,%ecx
  801f4a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  801f4d:	89 fe                	mov    %edi,%esi
  801f4f:	d3 ee                	shr    %cl,%esi
  801f51:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801f55:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801f58:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801f5b:	d3 e7                	shl    %cl,%edi
  801f5d:	89 c1                	mov    %eax,%ecx
  801f5f:	d3 ea                	shr    %cl,%edx
  801f61:	09 d7                	or     %edx,%edi
  801f63:	89 f2                	mov    %esi,%edx
  801f65:	89 f8                	mov    %edi,%eax
  801f67:	f7 75 ec             	divl   -0x14(%ebp)
  801f6a:	89 d6                	mov    %edx,%esi
  801f6c:	89 c7                	mov    %eax,%edi
  801f6e:	f7 65 e8             	mull   -0x18(%ebp)
  801f71:	39 d6                	cmp    %edx,%esi
  801f73:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801f76:	72 30                	jb     801fa8 <__udivdi3+0x118>
  801f78:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801f7b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801f7f:	d3 e2                	shl    %cl,%edx
  801f81:	39 c2                	cmp    %eax,%edx
  801f83:	73 05                	jae    801f8a <__udivdi3+0xfa>
  801f85:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  801f88:	74 1e                	je     801fa8 <__udivdi3+0x118>
  801f8a:	89 f9                	mov    %edi,%ecx
  801f8c:	31 ff                	xor    %edi,%edi
  801f8e:	e9 71 ff ff ff       	jmp    801f04 <__udivdi3+0x74>
  801f93:	90                   	nop
  801f94:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801f98:	31 ff                	xor    %edi,%edi
  801f9a:	b9 01 00 00 00       	mov    $0x1,%ecx
  801f9f:	e9 60 ff ff ff       	jmp    801f04 <__udivdi3+0x74>
  801fa4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801fa8:	8d 4f ff             	lea    -0x1(%edi),%ecx
  801fab:	31 ff                	xor    %edi,%edi
  801fad:	89 c8                	mov    %ecx,%eax
  801faf:	89 fa                	mov    %edi,%edx
  801fb1:	83 c4 10             	add    $0x10,%esp
  801fb4:	5e                   	pop    %esi
  801fb5:	5f                   	pop    %edi
  801fb6:	5d                   	pop    %ebp
  801fb7:	c3                   	ret    
	...

00801fc0 <__umoddi3>:
  801fc0:	55                   	push   %ebp
  801fc1:	89 e5                	mov    %esp,%ebp
  801fc3:	57                   	push   %edi
  801fc4:	56                   	push   %esi
  801fc5:	83 ec 20             	sub    $0x20,%esp
  801fc8:	8b 55 14             	mov    0x14(%ebp),%edx
  801fcb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801fce:	8b 7d 10             	mov    0x10(%ebp),%edi
  801fd1:	8b 75 0c             	mov    0xc(%ebp),%esi
  801fd4:	85 d2                	test   %edx,%edx
  801fd6:	89 c8                	mov    %ecx,%eax
  801fd8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801fdb:	75 13                	jne    801ff0 <__umoddi3+0x30>
  801fdd:	39 f7                	cmp    %esi,%edi
  801fdf:	76 3f                	jbe    802020 <__umoddi3+0x60>
  801fe1:	89 f2                	mov    %esi,%edx
  801fe3:	f7 f7                	div    %edi
  801fe5:	89 d0                	mov    %edx,%eax
  801fe7:	31 d2                	xor    %edx,%edx
  801fe9:	83 c4 20             	add    $0x20,%esp
  801fec:	5e                   	pop    %esi
  801fed:	5f                   	pop    %edi
  801fee:	5d                   	pop    %ebp
  801fef:	c3                   	ret    
  801ff0:	39 f2                	cmp    %esi,%edx
  801ff2:	77 4c                	ja     802040 <__umoddi3+0x80>
  801ff4:	0f bd ca             	bsr    %edx,%ecx
  801ff7:	83 f1 1f             	xor    $0x1f,%ecx
  801ffa:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801ffd:	75 51                	jne    802050 <__umoddi3+0x90>
  801fff:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  802002:	0f 87 e0 00 00 00    	ja     8020e8 <__umoddi3+0x128>
  802008:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80200b:	29 f8                	sub    %edi,%eax
  80200d:	19 d6                	sbb    %edx,%esi
  80200f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  802012:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802015:	89 f2                	mov    %esi,%edx
  802017:	83 c4 20             	add    $0x20,%esp
  80201a:	5e                   	pop    %esi
  80201b:	5f                   	pop    %edi
  80201c:	5d                   	pop    %ebp
  80201d:	c3                   	ret    
  80201e:	66 90                	xchg   %ax,%ax
  802020:	85 ff                	test   %edi,%edi
  802022:	75 0b                	jne    80202f <__umoddi3+0x6f>
  802024:	b8 01 00 00 00       	mov    $0x1,%eax
  802029:	31 d2                	xor    %edx,%edx
  80202b:	f7 f7                	div    %edi
  80202d:	89 c7                	mov    %eax,%edi
  80202f:	89 f0                	mov    %esi,%eax
  802031:	31 d2                	xor    %edx,%edx
  802033:	f7 f7                	div    %edi
  802035:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802038:	f7 f7                	div    %edi
  80203a:	eb a9                	jmp    801fe5 <__umoddi3+0x25>
  80203c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802040:	89 c8                	mov    %ecx,%eax
  802042:	89 f2                	mov    %esi,%edx
  802044:	83 c4 20             	add    $0x20,%esp
  802047:	5e                   	pop    %esi
  802048:	5f                   	pop    %edi
  802049:	5d                   	pop    %ebp
  80204a:	c3                   	ret    
  80204b:	90                   	nop
  80204c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802050:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802054:	d3 e2                	shl    %cl,%edx
  802056:	89 55 f4             	mov    %edx,-0xc(%ebp)
  802059:	ba 20 00 00 00       	mov    $0x20,%edx
  80205e:	2b 55 f0             	sub    -0x10(%ebp),%edx
  802061:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802064:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802068:	89 fa                	mov    %edi,%edx
  80206a:	d3 ea                	shr    %cl,%edx
  80206c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802070:	0b 55 f4             	or     -0xc(%ebp),%edx
  802073:	d3 e7                	shl    %cl,%edi
  802075:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802079:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80207c:	89 f2                	mov    %esi,%edx
  80207e:	89 7d e8             	mov    %edi,-0x18(%ebp)
  802081:	89 c7                	mov    %eax,%edi
  802083:	d3 ea                	shr    %cl,%edx
  802085:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802089:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80208c:	89 c2                	mov    %eax,%edx
  80208e:	d3 e6                	shl    %cl,%esi
  802090:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802094:	d3 ea                	shr    %cl,%edx
  802096:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80209a:	09 d6                	or     %edx,%esi
  80209c:	89 f0                	mov    %esi,%eax
  80209e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8020a1:	d3 e7                	shl    %cl,%edi
  8020a3:	89 f2                	mov    %esi,%edx
  8020a5:	f7 75 f4             	divl   -0xc(%ebp)
  8020a8:	89 d6                	mov    %edx,%esi
  8020aa:	f7 65 e8             	mull   -0x18(%ebp)
  8020ad:	39 d6                	cmp    %edx,%esi
  8020af:	72 2b                	jb     8020dc <__umoddi3+0x11c>
  8020b1:	39 c7                	cmp    %eax,%edi
  8020b3:	72 23                	jb     8020d8 <__umoddi3+0x118>
  8020b5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8020b9:	29 c7                	sub    %eax,%edi
  8020bb:	19 d6                	sbb    %edx,%esi
  8020bd:	89 f0                	mov    %esi,%eax
  8020bf:	89 f2                	mov    %esi,%edx
  8020c1:	d3 ef                	shr    %cl,%edi
  8020c3:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8020c7:	d3 e0                	shl    %cl,%eax
  8020c9:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8020cd:	09 f8                	or     %edi,%eax
  8020cf:	d3 ea                	shr    %cl,%edx
  8020d1:	83 c4 20             	add    $0x20,%esp
  8020d4:	5e                   	pop    %esi
  8020d5:	5f                   	pop    %edi
  8020d6:	5d                   	pop    %ebp
  8020d7:	c3                   	ret    
  8020d8:	39 d6                	cmp    %edx,%esi
  8020da:	75 d9                	jne    8020b5 <__umoddi3+0xf5>
  8020dc:	2b 45 e8             	sub    -0x18(%ebp),%eax
  8020df:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  8020e2:	eb d1                	jmp    8020b5 <__umoddi3+0xf5>
  8020e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8020e8:	39 f2                	cmp    %esi,%edx
  8020ea:	0f 82 18 ff ff ff    	jb     802008 <__umoddi3+0x48>
  8020f0:	e9 1d ff ff ff       	jmp    802012 <__umoddi3+0x52>
