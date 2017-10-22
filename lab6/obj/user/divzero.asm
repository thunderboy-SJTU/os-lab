
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
  80003a:	c7 05 08 40 80 00 00 	movl   $0x0,0x804008
  800041:	00 00 00 
	cprintf("1/0 is %08x!\n", 1/zero);
  800044:	ba 01 00 00 00       	mov    $0x1,%edx
  800049:	b9 00 00 00 00       	mov    $0x0,%ecx
  80004e:	89 d0                	mov    %edx,%eax
  800050:	c1 fa 1f             	sar    $0x1f,%edx
  800053:	f7 f9                	idiv   %ecx
  800055:	89 44 24 04          	mov    %eax,0x4(%esp)
  800059:	c7 04 24 60 27 80 00 	movl   $0x802760,(%esp)
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
  80007a:	e8 08 14 00 00       	call   801487 <sys_getenvid>
  80007f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800084:	89 c2                	mov    %eax,%edx
  800086:	c1 e2 07             	shl    $0x7,%edx
  800089:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  800090:	a3 0c 40 80 00       	mov    %eax,0x80400c
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
  8000c2:	e8 54 19 00 00       	call   801a1b <close_all>
	sys_env_destroy(0);
  8000c7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000ce:	e8 f4 13 00 00       	call   8014c7 <sys_env_destroy>
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
  80020f:	e8 dc 22 00 00       	call   8024f0 <__udivdi3>
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
  800277:	e8 a4 23 00 00       	call   802620 <__umoddi3>
  80027c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800280:	0f be 80 78 27 80 00 	movsbl 0x802778(%eax),%eax
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
  80036a:	ff 24 95 60 29 80 00 	jmp    *0x802960(,%edx,4)
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
  800427:	8b 14 85 c0 2a 80 00 	mov    0x802ac0(,%eax,4),%edx
  80042e:	85 d2                	test   %edx,%edx
  800430:	75 26                	jne    800458 <vprintfmt+0x16c>
				printfmt(putch, putdat, "error %d", err);
  800432:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800436:	c7 44 24 08 89 27 80 	movl   $0x802789,0x8(%esp)
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
  80045c:	c7 44 24 08 de 2b 80 	movl   $0x802bde,0x8(%esp)
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
  80049a:	be 92 27 80 00       	mov    $0x802792,%esi
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
  800744:	e8 a7 1d 00 00       	call   8024f0 <__udivdi3>
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
  800790:	e8 8b 1e 00 00       	call   802620 <__umoddi3>
  800795:	89 74 24 04          	mov    %esi,0x4(%esp)
  800799:	0f be 80 78 27 80 00 	movsbl 0x802778(%eax),%eax
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
  800845:	c7 44 24 0c ac 28 80 	movl   $0x8028ac,0xc(%esp)
  80084c:	00 
  80084d:	c7 44 24 08 de 2b 80 	movl   $0x802bde,0x8(%esp)
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
  80087b:	c7 44 24 0c e4 28 80 	movl   $0x8028e4,0xc(%esp)
  800882:	00 
  800883:	c7 44 24 08 de 2b 80 	movl   $0x802bde,0x8(%esp)
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
  80090f:	e8 0c 1d 00 00       	call   802620 <__umoddi3>
  800914:	89 74 24 04          	mov    %esi,0x4(%esp)
  800918:	0f be 80 78 27 80 00 	movsbl 0x802778(%eax),%eax
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
  800951:	e8 ca 1c 00 00       	call   802620 <__umoddi3>
  800956:	89 74 24 04          	mov    %esi,0x4(%esp)
  80095a:	0f be 80 78 27 80 00 	movsbl 0x802778(%eax),%eax
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

00800edb <sys_get_mac>:
sys_receive_packet(uint32_t addr,int* len){
         return syscall(SYS_receive_packet,0,(uint32_t)addr,(uint32_t)len,0,0,0);
}

int 
sys_get_mac(uint8_t* macaddr){
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
  800ee8:	b9 00 00 00 00       	mov    $0x0,%ecx
  800eed:	b8 13 00 00 00       	mov    $0x13,%eax
  800ef2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ef5:	89 cb                	mov    %ecx,%ebx
  800ef7:	89 cf                	mov    %ecx,%edi
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
sys_get_mac(uint8_t* macaddr){
         return syscall(SYS_get_mac,0,(uint32_t)macaddr,0,0,0,0);
}
  800f11:	8b 1c 24             	mov    (%esp),%ebx
  800f14:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800f18:	89 ec                	mov    %ebp,%esp
  800f1a:	5d                   	pop    %ebp
  800f1b:	c3                   	ret    

00800f1c <sys_receive_packet>:
sys_transmit_packet(uint32_t addr,int len){
         return syscall(SYS_transmit_packet,0,(uint32_t)addr,(uint32_t)len,0,0,0);
}

int 
sys_receive_packet(uint32_t addr,int* len){
  800f1c:	55                   	push   %ebp
  800f1d:	89 e5                	mov    %esp,%ebp
  800f1f:	83 ec 08             	sub    $0x8,%esp
  800f22:	89 1c 24             	mov    %ebx,(%esp)
  800f25:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800f29:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f2e:	b8 12 00 00 00       	mov    $0x12,%eax
  800f33:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f36:	8b 55 08             	mov    0x8(%ebp),%edx
  800f39:	89 df                	mov    %ebx,%edi
  800f3b:	51                   	push   %ecx
  800f3c:	52                   	push   %edx
  800f3d:	53                   	push   %ebx
  800f3e:	54                   	push   %esp
  800f3f:	55                   	push   %ebp
  800f40:	56                   	push   %esi
  800f41:	57                   	push   %edi
  800f42:	54                   	push   %esp
  800f43:	5d                   	pop    %ebp
  800f44:	8d 35 4c 0f 80 00    	lea    0x800f4c,%esi
  800f4a:	0f 34                	sysenter 
  800f4c:	5f                   	pop    %edi
  800f4d:	5e                   	pop    %esi
  800f4e:	5d                   	pop    %ebp
  800f4f:	5c                   	pop    %esp
  800f50:	5b                   	pop    %ebx
  800f51:	5a                   	pop    %edx
  800f52:	59                   	pop    %ecx
}

int 
sys_receive_packet(uint32_t addr,int* len){
         return syscall(SYS_receive_packet,0,(uint32_t)addr,(uint32_t)len,0,0,0);
}
  800f53:	8b 1c 24             	mov    (%esp),%ebx
  800f56:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800f5a:	89 ec                	mov    %ebp,%esp
  800f5c:	5d                   	pop    %ebp
  800f5d:	c3                   	ret    

00800f5e <sys_transmit_packet>:
sys_exec(void* vph, uint32_t phnum, uint32_t esp, uint32_t eip){
         return syscall(SYS_exec, 0, (uint32_t)vph, phnum, esp, eip, 0);
}

int 
sys_transmit_packet(uint32_t addr,int len){
  800f5e:	55                   	push   %ebp
  800f5f:	89 e5                	mov    %esp,%ebp
  800f61:	83 ec 08             	sub    $0x8,%esp
  800f64:	89 1c 24             	mov    %ebx,(%esp)
  800f67:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800f6b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f70:	b8 11 00 00 00       	mov    $0x11,%eax
  800f75:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f78:	8b 55 08             	mov    0x8(%ebp),%edx
  800f7b:	89 df                	mov    %ebx,%edi
  800f7d:	51                   	push   %ecx
  800f7e:	52                   	push   %edx
  800f7f:	53                   	push   %ebx
  800f80:	54                   	push   %esp
  800f81:	55                   	push   %ebp
  800f82:	56                   	push   %esi
  800f83:	57                   	push   %edi
  800f84:	54                   	push   %esp
  800f85:	5d                   	pop    %ebp
  800f86:	8d 35 8e 0f 80 00    	lea    0x800f8e,%esi
  800f8c:	0f 34                	sysenter 
  800f8e:	5f                   	pop    %edi
  800f8f:	5e                   	pop    %esi
  800f90:	5d                   	pop    %ebp
  800f91:	5c                   	pop    %esp
  800f92:	5b                   	pop    %ebx
  800f93:	5a                   	pop    %edx
  800f94:	59                   	pop    %ecx
}

int 
sys_transmit_packet(uint32_t addr,int len){
         return syscall(SYS_transmit_packet,0,(uint32_t)addr,(uint32_t)len,0,0,0);
}
  800f95:	8b 1c 24             	mov    (%esp),%ebx
  800f98:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800f9c:	89 ec                	mov    %ebp,%esp
  800f9e:	5d                   	pop    %ebp
  800f9f:	c3                   	ret    

00800fa0 <sys_exec>:
sys_env_set_prior(envid_t envid, uint32_t prior){
         return syscall(SYS_env_set_prior,1,envid, prior, 0, 0, 0);
}

int 
sys_exec(void* vph, uint32_t phnum, uint32_t esp, uint32_t eip){
  800fa0:	55                   	push   %ebp
  800fa1:	89 e5                	mov    %esp,%ebp
  800fa3:	83 ec 08             	sub    $0x8,%esp
  800fa6:	89 1c 24             	mov    %ebx,(%esp)
  800fa9:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800fad:	b8 10 00 00 00       	mov    $0x10,%eax
  800fb2:	8b 7d 14             	mov    0x14(%ebp),%edi
  800fb5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800fb8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fbb:	8b 55 08             	mov    0x8(%ebp),%edx
  800fbe:	51                   	push   %ecx
  800fbf:	52                   	push   %edx
  800fc0:	53                   	push   %ebx
  800fc1:	54                   	push   %esp
  800fc2:	55                   	push   %ebp
  800fc3:	56                   	push   %esi
  800fc4:	57                   	push   %edi
  800fc5:	54                   	push   %esp
  800fc6:	5d                   	pop    %ebp
  800fc7:	8d 35 cf 0f 80 00    	lea    0x800fcf,%esi
  800fcd:	0f 34                	sysenter 
  800fcf:	5f                   	pop    %edi
  800fd0:	5e                   	pop    %esi
  800fd1:	5d                   	pop    %ebp
  800fd2:	5c                   	pop    %esp
  800fd3:	5b                   	pop    %ebx
  800fd4:	5a                   	pop    %edx
  800fd5:	59                   	pop    %ecx
}

int 
sys_exec(void* vph, uint32_t phnum, uint32_t esp, uint32_t eip){
         return syscall(SYS_exec, 0, (uint32_t)vph, phnum, esp, eip, 0);
}
  800fd6:	8b 1c 24             	mov    (%esp),%ebx
  800fd9:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800fdd:	89 ec                	mov    %ebp,%esp
  800fdf:	5d                   	pop    %ebp
  800fe0:	c3                   	ret    

00800fe1 <sys_env_set_prior>:
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}


int 
sys_env_set_prior(envid_t envid, uint32_t prior){
  800fe1:	55                   	push   %ebp
  800fe2:	89 e5                	mov    %esp,%ebp
  800fe4:	83 ec 28             	sub    $0x28,%esp
  800fe7:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800fea:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800fed:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ff2:	b8 0f 00 00 00       	mov    $0xf,%eax
  800ff7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ffa:	8b 55 08             	mov    0x8(%ebp),%edx
  800ffd:	89 df                	mov    %ebx,%edi
  800fff:	51                   	push   %ecx
  801000:	52                   	push   %edx
  801001:	53                   	push   %ebx
  801002:	54                   	push   %esp
  801003:	55                   	push   %ebp
  801004:	56                   	push   %esi
  801005:	57                   	push   %edi
  801006:	54                   	push   %esp
  801007:	5d                   	pop    %ebp
  801008:	8d 35 10 10 80 00    	lea    0x801010,%esi
  80100e:	0f 34                	sysenter 
  801010:	5f                   	pop    %edi
  801011:	5e                   	pop    %esi
  801012:	5d                   	pop    %ebp
  801013:	5c                   	pop    %esp
  801014:	5b                   	pop    %ebx
  801015:	5a                   	pop    %edx
  801016:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801017:	85 c0                	test   %eax,%eax
  801019:	7e 28                	jle    801043 <sys_env_set_prior+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  80101b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80101f:	c7 44 24 0c 0f 00 00 	movl   $0xf,0xc(%esp)
  801026:	00 
  801027:	c7 44 24 08 00 2b 80 	movl   $0x802b00,0x8(%esp)
  80102e:	00 
  80102f:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801036:	00 
  801037:	c7 04 24 1d 2b 80 00 	movl   $0x802b1d,(%esp)
  80103e:	e8 d1 12 00 00       	call   802314 <_panic>


int 
sys_env_set_prior(envid_t envid, uint32_t prior){
         return syscall(SYS_env_set_prior,1,envid, prior, 0, 0, 0);
}
  801043:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801046:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801049:	89 ec                	mov    %ebp,%esp
  80104b:	5d                   	pop    %ebp
  80104c:	c3                   	ret    

0080104d <sys_time_msec>:
}


unsigned int
sys_time_msec(void)
{
  80104d:	55                   	push   %ebp
  80104e:	89 e5                	mov    %esp,%ebp
  801050:	83 ec 08             	sub    $0x8,%esp
  801053:	89 1c 24             	mov    %ebx,(%esp)
  801056:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80105a:	ba 00 00 00 00       	mov    $0x0,%edx
  80105f:	b8 15 00 00 00       	mov    $0x15,%eax
  801064:	89 d1                	mov    %edx,%ecx
  801066:	89 d3                	mov    %edx,%ebx
  801068:	89 d7                	mov    %edx,%edi
  80106a:	51                   	push   %ecx
  80106b:	52                   	push   %edx
  80106c:	53                   	push   %ebx
  80106d:	54                   	push   %esp
  80106e:	55                   	push   %ebp
  80106f:	56                   	push   %esi
  801070:	57                   	push   %edi
  801071:	54                   	push   %esp
  801072:	5d                   	pop    %ebp
  801073:	8d 35 7b 10 80 00    	lea    0x80107b,%esi
  801079:	0f 34                	sysenter 
  80107b:	5f                   	pop    %edi
  80107c:	5e                   	pop    %esi
  80107d:	5d                   	pop    %ebp
  80107e:	5c                   	pop    %esp
  80107f:	5b                   	pop    %ebx
  801080:	5a                   	pop    %edx
  801081:	59                   	pop    %ecx

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  801082:	8b 1c 24             	mov    (%esp),%ebx
  801085:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801089:	89 ec                	mov    %ebp,%esp
  80108b:	5d                   	pop    %ebp
  80108c:	c3                   	ret    

0080108d <sys_sbrk>:
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}

int
sys_sbrk(uint32_t inc)
{
  80108d:	55                   	push   %ebp
  80108e:	89 e5                	mov    %esp,%ebp
  801090:	83 ec 08             	sub    $0x8,%esp
  801093:	89 1c 24             	mov    %ebx,(%esp)
  801096:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80109a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80109f:	b8 14 00 00 00       	mov    $0x14,%eax
  8010a4:	8b 55 08             	mov    0x8(%ebp),%edx
  8010a7:	89 cb                	mov    %ecx,%ebx
  8010a9:	89 cf                	mov    %ecx,%edi
  8010ab:	51                   	push   %ecx
  8010ac:	52                   	push   %edx
  8010ad:	53                   	push   %ebx
  8010ae:	54                   	push   %esp
  8010af:	55                   	push   %ebp
  8010b0:	56                   	push   %esi
  8010b1:	57                   	push   %edi
  8010b2:	54                   	push   %esp
  8010b3:	5d                   	pop    %ebp
  8010b4:	8d 35 bc 10 80 00    	lea    0x8010bc,%esi
  8010ba:	0f 34                	sysenter 
  8010bc:	5f                   	pop    %edi
  8010bd:	5e                   	pop    %esi
  8010be:	5d                   	pop    %ebp
  8010bf:	5c                   	pop    %esp
  8010c0:	5b                   	pop    %ebx
  8010c1:	5a                   	pop    %edx
  8010c2:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  8010c3:	8b 1c 24             	mov    (%esp),%ebx
  8010c6:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8010ca:	89 ec                	mov    %ebp,%esp
  8010cc:	5d                   	pop    %ebp
  8010cd:	c3                   	ret    

008010ce <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  8010ce:	55                   	push   %ebp
  8010cf:	89 e5                	mov    %esp,%ebp
  8010d1:	83 ec 28             	sub    $0x28,%esp
  8010d4:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8010d7:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8010da:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010df:	b8 0e 00 00 00       	mov    $0xe,%eax
  8010e4:	8b 55 08             	mov    0x8(%ebp),%edx
  8010e7:	89 cb                	mov    %ecx,%ebx
  8010e9:	89 cf                	mov    %ecx,%edi
  8010eb:	51                   	push   %ecx
  8010ec:	52                   	push   %edx
  8010ed:	53                   	push   %ebx
  8010ee:	54                   	push   %esp
  8010ef:	55                   	push   %ebp
  8010f0:	56                   	push   %esi
  8010f1:	57                   	push   %edi
  8010f2:	54                   	push   %esp
  8010f3:	5d                   	pop    %ebp
  8010f4:	8d 35 fc 10 80 00    	lea    0x8010fc,%esi
  8010fa:	0f 34                	sysenter 
  8010fc:	5f                   	pop    %edi
  8010fd:	5e                   	pop    %esi
  8010fe:	5d                   	pop    %ebp
  8010ff:	5c                   	pop    %esp
  801100:	5b                   	pop    %ebx
  801101:	5a                   	pop    %edx
  801102:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801103:	85 c0                	test   %eax,%eax
  801105:	7e 28                	jle    80112f <sys_ipc_recv+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  801107:	89 44 24 10          	mov    %eax,0x10(%esp)
  80110b:	c7 44 24 0c 0e 00 00 	movl   $0xe,0xc(%esp)
  801112:	00 
  801113:	c7 44 24 08 00 2b 80 	movl   $0x802b00,0x8(%esp)
  80111a:	00 
  80111b:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801122:	00 
  801123:	c7 04 24 1d 2b 80 00 	movl   $0x802b1d,(%esp)
  80112a:	e8 e5 11 00 00       	call   802314 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80112f:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801132:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801135:	89 ec                	mov    %ebp,%esp
  801137:	5d                   	pop    %ebp
  801138:	c3                   	ret    

00801139 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801139:	55                   	push   %ebp
  80113a:	89 e5                	mov    %esp,%ebp
  80113c:	83 ec 08             	sub    $0x8,%esp
  80113f:	89 1c 24             	mov    %ebx,(%esp)
  801142:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801146:	b8 0d 00 00 00       	mov    $0xd,%eax
  80114b:	8b 7d 14             	mov    0x14(%ebp),%edi
  80114e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801151:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801154:	8b 55 08             	mov    0x8(%ebp),%edx
  801157:	51                   	push   %ecx
  801158:	52                   	push   %edx
  801159:	53                   	push   %ebx
  80115a:	54                   	push   %esp
  80115b:	55                   	push   %ebp
  80115c:	56                   	push   %esi
  80115d:	57                   	push   %edi
  80115e:	54                   	push   %esp
  80115f:	5d                   	pop    %ebp
  801160:	8d 35 68 11 80 00    	lea    0x801168,%esi
  801166:	0f 34                	sysenter 
  801168:	5f                   	pop    %edi
  801169:	5e                   	pop    %esi
  80116a:	5d                   	pop    %ebp
  80116b:	5c                   	pop    %esp
  80116c:	5b                   	pop    %ebx
  80116d:	5a                   	pop    %edx
  80116e:	59                   	pop    %ecx

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80116f:	8b 1c 24             	mov    (%esp),%ebx
  801172:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801176:	89 ec                	mov    %ebp,%esp
  801178:	5d                   	pop    %ebp
  801179:	c3                   	ret    

0080117a <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80117a:	55                   	push   %ebp
  80117b:	89 e5                	mov    %esp,%ebp
  80117d:	83 ec 28             	sub    $0x28,%esp
  801180:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801183:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801186:	bb 00 00 00 00       	mov    $0x0,%ebx
  80118b:	b8 0b 00 00 00       	mov    $0xb,%eax
  801190:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801193:	8b 55 08             	mov    0x8(%ebp),%edx
  801196:	89 df                	mov    %ebx,%edi
  801198:	51                   	push   %ecx
  801199:	52                   	push   %edx
  80119a:	53                   	push   %ebx
  80119b:	54                   	push   %esp
  80119c:	55                   	push   %ebp
  80119d:	56                   	push   %esi
  80119e:	57                   	push   %edi
  80119f:	54                   	push   %esp
  8011a0:	5d                   	pop    %ebp
  8011a1:	8d 35 a9 11 80 00    	lea    0x8011a9,%esi
  8011a7:	0f 34                	sysenter 
  8011a9:	5f                   	pop    %edi
  8011aa:	5e                   	pop    %esi
  8011ab:	5d                   	pop    %ebp
  8011ac:	5c                   	pop    %esp
  8011ad:	5b                   	pop    %ebx
  8011ae:	5a                   	pop    %edx
  8011af:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8011b0:	85 c0                	test   %eax,%eax
  8011b2:	7e 28                	jle    8011dc <sys_env_set_pgfault_upcall+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011b4:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011b8:	c7 44 24 0c 0b 00 00 	movl   $0xb,0xc(%esp)
  8011bf:	00 
  8011c0:	c7 44 24 08 00 2b 80 	movl   $0x802b00,0x8(%esp)
  8011c7:	00 
  8011c8:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8011cf:	00 
  8011d0:	c7 04 24 1d 2b 80 00 	movl   $0x802b1d,(%esp)
  8011d7:	e8 38 11 00 00       	call   802314 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8011dc:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8011df:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8011e2:	89 ec                	mov    %ebp,%esp
  8011e4:	5d                   	pop    %ebp
  8011e5:	c3                   	ret    

008011e6 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8011e6:	55                   	push   %ebp
  8011e7:	89 e5                	mov    %esp,%ebp
  8011e9:	83 ec 28             	sub    $0x28,%esp
  8011ec:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8011ef:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8011f2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011f7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8011fc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011ff:	8b 55 08             	mov    0x8(%ebp),%edx
  801202:	89 df                	mov    %ebx,%edi
  801204:	51                   	push   %ecx
  801205:	52                   	push   %edx
  801206:	53                   	push   %ebx
  801207:	54                   	push   %esp
  801208:	55                   	push   %ebp
  801209:	56                   	push   %esi
  80120a:	57                   	push   %edi
  80120b:	54                   	push   %esp
  80120c:	5d                   	pop    %ebp
  80120d:	8d 35 15 12 80 00    	lea    0x801215,%esi
  801213:	0f 34                	sysenter 
  801215:	5f                   	pop    %edi
  801216:	5e                   	pop    %esi
  801217:	5d                   	pop    %ebp
  801218:	5c                   	pop    %esp
  801219:	5b                   	pop    %ebx
  80121a:	5a                   	pop    %edx
  80121b:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80121c:	85 c0                	test   %eax,%eax
  80121e:	7e 28                	jle    801248 <sys_env_set_trapframe+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  801220:	89 44 24 10          	mov    %eax,0x10(%esp)
  801224:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  80122b:	00 
  80122c:	c7 44 24 08 00 2b 80 	movl   $0x802b00,0x8(%esp)
  801233:	00 
  801234:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80123b:	00 
  80123c:	c7 04 24 1d 2b 80 00 	movl   $0x802b1d,(%esp)
  801243:	e8 cc 10 00 00       	call   802314 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801248:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80124b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80124e:	89 ec                	mov    %ebp,%esp
  801250:	5d                   	pop    %ebp
  801251:	c3                   	ret    

00801252 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801252:	55                   	push   %ebp
  801253:	89 e5                	mov    %esp,%ebp
  801255:	83 ec 28             	sub    $0x28,%esp
  801258:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80125b:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80125e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801263:	b8 09 00 00 00       	mov    $0x9,%eax
  801268:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80126b:	8b 55 08             	mov    0x8(%ebp),%edx
  80126e:	89 df                	mov    %ebx,%edi
  801270:	51                   	push   %ecx
  801271:	52                   	push   %edx
  801272:	53                   	push   %ebx
  801273:	54                   	push   %esp
  801274:	55                   	push   %ebp
  801275:	56                   	push   %esi
  801276:	57                   	push   %edi
  801277:	54                   	push   %esp
  801278:	5d                   	pop    %ebp
  801279:	8d 35 81 12 80 00    	lea    0x801281,%esi
  80127f:	0f 34                	sysenter 
  801281:	5f                   	pop    %edi
  801282:	5e                   	pop    %esi
  801283:	5d                   	pop    %ebp
  801284:	5c                   	pop    %esp
  801285:	5b                   	pop    %ebx
  801286:	5a                   	pop    %edx
  801287:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801288:	85 c0                	test   %eax,%eax
  80128a:	7e 28                	jle    8012b4 <sys_env_set_status+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  80128c:	89 44 24 10          	mov    %eax,0x10(%esp)
  801290:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  801297:	00 
  801298:	c7 44 24 08 00 2b 80 	movl   $0x802b00,0x8(%esp)
  80129f:	00 
  8012a0:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8012a7:	00 
  8012a8:	c7 04 24 1d 2b 80 00 	movl   $0x802b1d,(%esp)
  8012af:	e8 60 10 00 00       	call   802314 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8012b4:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8012b7:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8012ba:	89 ec                	mov    %ebp,%esp
  8012bc:	5d                   	pop    %ebp
  8012bd:	c3                   	ret    

008012be <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  8012be:	55                   	push   %ebp
  8012bf:	89 e5                	mov    %esp,%ebp
  8012c1:	83 ec 28             	sub    $0x28,%esp
  8012c4:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8012c7:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8012ca:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012cf:	b8 07 00 00 00       	mov    $0x7,%eax
  8012d4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012d7:	8b 55 08             	mov    0x8(%ebp),%edx
  8012da:	89 df                	mov    %ebx,%edi
  8012dc:	51                   	push   %ecx
  8012dd:	52                   	push   %edx
  8012de:	53                   	push   %ebx
  8012df:	54                   	push   %esp
  8012e0:	55                   	push   %ebp
  8012e1:	56                   	push   %esi
  8012e2:	57                   	push   %edi
  8012e3:	54                   	push   %esp
  8012e4:	5d                   	pop    %ebp
  8012e5:	8d 35 ed 12 80 00    	lea    0x8012ed,%esi
  8012eb:	0f 34                	sysenter 
  8012ed:	5f                   	pop    %edi
  8012ee:	5e                   	pop    %esi
  8012ef:	5d                   	pop    %ebp
  8012f0:	5c                   	pop    %esp
  8012f1:	5b                   	pop    %ebx
  8012f2:	5a                   	pop    %edx
  8012f3:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8012f4:	85 c0                	test   %eax,%eax
  8012f6:	7e 28                	jle    801320 <sys_page_unmap+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012f8:	89 44 24 10          	mov    %eax,0x10(%esp)
  8012fc:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801303:	00 
  801304:	c7 44 24 08 00 2b 80 	movl   $0x802b00,0x8(%esp)
  80130b:	00 
  80130c:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801313:	00 
  801314:	c7 04 24 1d 2b 80 00 	movl   $0x802b1d,(%esp)
  80131b:	e8 f4 0f 00 00       	call   802314 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801320:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801323:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801326:	89 ec                	mov    %ebp,%esp
  801328:	5d                   	pop    %ebp
  801329:	c3                   	ret    

0080132a <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80132a:	55                   	push   %ebp
  80132b:	89 e5                	mov    %esp,%ebp
  80132d:	83 ec 28             	sub    $0x28,%esp
  801330:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801333:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801336:	8b 7d 18             	mov    0x18(%ebp),%edi
  801339:	0b 7d 14             	or     0x14(%ebp),%edi
  80133c:	b8 06 00 00 00       	mov    $0x6,%eax
  801341:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801344:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801347:	8b 55 08             	mov    0x8(%ebp),%edx
  80134a:	51                   	push   %ecx
  80134b:	52                   	push   %edx
  80134c:	53                   	push   %ebx
  80134d:	54                   	push   %esp
  80134e:	55                   	push   %ebp
  80134f:	56                   	push   %esi
  801350:	57                   	push   %edi
  801351:	54                   	push   %esp
  801352:	5d                   	pop    %ebp
  801353:	8d 35 5b 13 80 00    	lea    0x80135b,%esi
  801359:	0f 34                	sysenter 
  80135b:	5f                   	pop    %edi
  80135c:	5e                   	pop    %esi
  80135d:	5d                   	pop    %ebp
  80135e:	5c                   	pop    %esp
  80135f:	5b                   	pop    %ebx
  801360:	5a                   	pop    %edx
  801361:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801362:	85 c0                	test   %eax,%eax
  801364:	7e 28                	jle    80138e <sys_page_map+0x64>
		panic("syscall %d returned %d (> 0)", num, ret);
  801366:	89 44 24 10          	mov    %eax,0x10(%esp)
  80136a:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  801371:	00 
  801372:	c7 44 24 08 00 2b 80 	movl   $0x802b00,0x8(%esp)
  801379:	00 
  80137a:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801381:	00 
  801382:	c7 04 24 1d 2b 80 00 	movl   $0x802b1d,(%esp)
  801389:	e8 86 0f 00 00       	call   802314 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}
  80138e:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801391:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801394:	89 ec                	mov    %ebp,%esp
  801396:	5d                   	pop    %ebp
  801397:	c3                   	ret    

00801398 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801398:	55                   	push   %ebp
  801399:	89 e5                	mov    %esp,%ebp
  80139b:	83 ec 28             	sub    $0x28,%esp
  80139e:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8013a1:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8013a4:	bf 00 00 00 00       	mov    $0x0,%edi
  8013a9:	b8 05 00 00 00       	mov    $0x5,%eax
  8013ae:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8013b1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013b4:	8b 55 08             	mov    0x8(%ebp),%edx
  8013b7:	51                   	push   %ecx
  8013b8:	52                   	push   %edx
  8013b9:	53                   	push   %ebx
  8013ba:	54                   	push   %esp
  8013bb:	55                   	push   %ebp
  8013bc:	56                   	push   %esi
  8013bd:	57                   	push   %edi
  8013be:	54                   	push   %esp
  8013bf:	5d                   	pop    %ebp
  8013c0:	8d 35 c8 13 80 00    	lea    0x8013c8,%esi
  8013c6:	0f 34                	sysenter 
  8013c8:	5f                   	pop    %edi
  8013c9:	5e                   	pop    %esi
  8013ca:	5d                   	pop    %ebp
  8013cb:	5c                   	pop    %esp
  8013cc:	5b                   	pop    %ebx
  8013cd:	5a                   	pop    %edx
  8013ce:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8013cf:	85 c0                	test   %eax,%eax
  8013d1:	7e 28                	jle    8013fb <sys_page_alloc+0x63>
		panic("syscall %d returned %d (> 0)", num, ret);
  8013d3:	89 44 24 10          	mov    %eax,0x10(%esp)
  8013d7:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  8013de:	00 
  8013df:	c7 44 24 08 00 2b 80 	movl   $0x802b00,0x8(%esp)
  8013e6:	00 
  8013e7:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8013ee:	00 
  8013ef:	c7 04 24 1d 2b 80 00 	movl   $0x802b1d,(%esp)
  8013f6:	e8 19 0f 00 00       	call   802314 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8013fb:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8013fe:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801401:	89 ec                	mov    %ebp,%esp
  801403:	5d                   	pop    %ebp
  801404:	c3                   	ret    

00801405 <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
{
  801405:	55                   	push   %ebp
  801406:	89 e5                	mov    %esp,%ebp
  801408:	83 ec 08             	sub    $0x8,%esp
  80140b:	89 1c 24             	mov    %ebx,(%esp)
  80140e:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801412:	ba 00 00 00 00       	mov    $0x0,%edx
  801417:	b8 0c 00 00 00       	mov    $0xc,%eax
  80141c:	89 d1                	mov    %edx,%ecx
  80141e:	89 d3                	mov    %edx,%ebx
  801420:	89 d7                	mov    %edx,%edi
  801422:	51                   	push   %ecx
  801423:	52                   	push   %edx
  801424:	53                   	push   %ebx
  801425:	54                   	push   %esp
  801426:	55                   	push   %ebp
  801427:	56                   	push   %esi
  801428:	57                   	push   %edi
  801429:	54                   	push   %esp
  80142a:	5d                   	pop    %ebp
  80142b:	8d 35 33 14 80 00    	lea    0x801433,%esi
  801431:	0f 34                	sysenter 
  801433:	5f                   	pop    %edi
  801434:	5e                   	pop    %esi
  801435:	5d                   	pop    %ebp
  801436:	5c                   	pop    %esp
  801437:	5b                   	pop    %ebx
  801438:	5a                   	pop    %edx
  801439:	59                   	pop    %ecx

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80143a:	8b 1c 24             	mov    (%esp),%ebx
  80143d:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801441:	89 ec                	mov    %ebp,%esp
  801443:	5d                   	pop    %ebp
  801444:	c3                   	ret    

00801445 <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
{
  801445:	55                   	push   %ebp
  801446:	89 e5                	mov    %esp,%ebp
  801448:	83 ec 08             	sub    $0x8,%esp
  80144b:	89 1c 24             	mov    %ebx,(%esp)
  80144e:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801452:	bb 00 00 00 00       	mov    $0x0,%ebx
  801457:	b8 04 00 00 00       	mov    $0x4,%eax
  80145c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80145f:	8b 55 08             	mov    0x8(%ebp),%edx
  801462:	89 df                	mov    %ebx,%edi
  801464:	51                   	push   %ecx
  801465:	52                   	push   %edx
  801466:	53                   	push   %ebx
  801467:	54                   	push   %esp
  801468:	55                   	push   %ebp
  801469:	56                   	push   %esi
  80146a:	57                   	push   %edi
  80146b:	54                   	push   %esp
  80146c:	5d                   	pop    %ebp
  80146d:	8d 35 75 14 80 00    	lea    0x801475,%esi
  801473:	0f 34                	sysenter 
  801475:	5f                   	pop    %edi
  801476:	5e                   	pop    %esi
  801477:	5d                   	pop    %ebp
  801478:	5c                   	pop    %esp
  801479:	5b                   	pop    %ebx
  80147a:	5a                   	pop    %edx
  80147b:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  80147c:	8b 1c 24             	mov    (%esp),%ebx
  80147f:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801483:	89 ec                	mov    %ebp,%esp
  801485:	5d                   	pop    %ebp
  801486:	c3                   	ret    

00801487 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  801487:	55                   	push   %ebp
  801488:	89 e5                	mov    %esp,%ebp
  80148a:	83 ec 08             	sub    $0x8,%esp
  80148d:	89 1c 24             	mov    %ebx,(%esp)
  801490:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801494:	ba 00 00 00 00       	mov    $0x0,%edx
  801499:	b8 02 00 00 00       	mov    $0x2,%eax
  80149e:	89 d1                	mov    %edx,%ecx
  8014a0:	89 d3                	mov    %edx,%ebx
  8014a2:	89 d7                	mov    %edx,%edi
  8014a4:	51                   	push   %ecx
  8014a5:	52                   	push   %edx
  8014a6:	53                   	push   %ebx
  8014a7:	54                   	push   %esp
  8014a8:	55                   	push   %ebp
  8014a9:	56                   	push   %esi
  8014aa:	57                   	push   %edi
  8014ab:	54                   	push   %esp
  8014ac:	5d                   	pop    %ebp
  8014ad:	8d 35 b5 14 80 00    	lea    0x8014b5,%esi
  8014b3:	0f 34                	sysenter 
  8014b5:	5f                   	pop    %edi
  8014b6:	5e                   	pop    %esi
  8014b7:	5d                   	pop    %ebp
  8014b8:	5c                   	pop    %esp
  8014b9:	5b                   	pop    %ebx
  8014ba:	5a                   	pop    %edx
  8014bb:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8014bc:	8b 1c 24             	mov    (%esp),%ebx
  8014bf:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8014c3:	89 ec                	mov    %ebp,%esp
  8014c5:	5d                   	pop    %ebp
  8014c6:	c3                   	ret    

008014c7 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  8014c7:	55                   	push   %ebp
  8014c8:	89 e5                	mov    %esp,%ebp
  8014ca:	83 ec 28             	sub    $0x28,%esp
  8014cd:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8014d0:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8014d3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8014d8:	b8 03 00 00 00       	mov    $0x3,%eax
  8014dd:	8b 55 08             	mov    0x8(%ebp),%edx
  8014e0:	89 cb                	mov    %ecx,%ebx
  8014e2:	89 cf                	mov    %ecx,%edi
  8014e4:	51                   	push   %ecx
  8014e5:	52                   	push   %edx
  8014e6:	53                   	push   %ebx
  8014e7:	54                   	push   %esp
  8014e8:	55                   	push   %ebp
  8014e9:	56                   	push   %esi
  8014ea:	57                   	push   %edi
  8014eb:	54                   	push   %esp
  8014ec:	5d                   	pop    %ebp
  8014ed:	8d 35 f5 14 80 00    	lea    0x8014f5,%esi
  8014f3:	0f 34                	sysenter 
  8014f5:	5f                   	pop    %edi
  8014f6:	5e                   	pop    %esi
  8014f7:	5d                   	pop    %ebp
  8014f8:	5c                   	pop    %esp
  8014f9:	5b                   	pop    %ebx
  8014fa:	5a                   	pop    %edx
  8014fb:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8014fc:	85 c0                	test   %eax,%eax
  8014fe:	7e 28                	jle    801528 <sys_env_destroy+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  801500:	89 44 24 10          	mov    %eax,0x10(%esp)
  801504:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  80150b:	00 
  80150c:	c7 44 24 08 00 2b 80 	movl   $0x802b00,0x8(%esp)
  801513:	00 
  801514:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80151b:	00 
  80151c:	c7 04 24 1d 2b 80 00 	movl   $0x802b1d,(%esp)
  801523:	e8 ec 0d 00 00       	call   802314 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801528:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80152b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80152e:	89 ec                	mov    %ebp,%esp
  801530:	5d                   	pop    %ebp
  801531:	c3                   	ret    
	...

00801540 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801540:	55                   	push   %ebp
  801541:	89 e5                	mov    %esp,%ebp
  801543:	8b 45 08             	mov    0x8(%ebp),%eax
  801546:	05 00 00 00 30       	add    $0x30000000,%eax
  80154b:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  80154e:	5d                   	pop    %ebp
  80154f:	c3                   	ret    

00801550 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801550:	55                   	push   %ebp
  801551:	89 e5                	mov    %esp,%ebp
  801553:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801556:	8b 45 08             	mov    0x8(%ebp),%eax
  801559:	89 04 24             	mov    %eax,(%esp)
  80155c:	e8 df ff ff ff       	call   801540 <fd2num>
  801561:	05 20 00 0d 00       	add    $0xd0020,%eax
  801566:	c1 e0 0c             	shl    $0xc,%eax
}
  801569:	c9                   	leave  
  80156a:	c3                   	ret    

0080156b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80156b:	55                   	push   %ebp
  80156c:	89 e5                	mov    %esp,%ebp
  80156e:	57                   	push   %edi
  80156f:	56                   	push   %esi
  801570:	53                   	push   %ebx
  801571:	8b 7d 08             	mov    0x8(%ebp),%edi
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  801574:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  801579:	a8 01                	test   $0x1,%al
  80157b:	74 36                	je     8015b3 <fd_alloc+0x48>
  80157d:	a1 00 00 74 ef       	mov    0xef740000,%eax
  801582:	a8 01                	test   $0x1,%al
  801584:	74 2d                	je     8015b3 <fd_alloc+0x48>
  801586:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  80158b:	b9 00 d0 7b ef       	mov    $0xef7bd000,%ecx
  801590:	be 00 00 40 ef       	mov    $0xef400000,%esi
  801595:	89 c3                	mov    %eax,%ebx
  801597:	89 c2                	mov    %eax,%edx
  801599:	c1 ea 16             	shr    $0x16,%edx
  80159c:	8b 14 91             	mov    (%ecx,%edx,4),%edx
  80159f:	f6 c2 01             	test   $0x1,%dl
  8015a2:	74 14                	je     8015b8 <fd_alloc+0x4d>
  8015a4:	89 c2                	mov    %eax,%edx
  8015a6:	c1 ea 0c             	shr    $0xc,%edx
  8015a9:	8b 14 96             	mov    (%esi,%edx,4),%edx
  8015ac:	f6 c2 01             	test   $0x1,%dl
  8015af:	75 10                	jne    8015c1 <fd_alloc+0x56>
  8015b1:	eb 05                	jmp    8015b8 <fd_alloc+0x4d>
  8015b3:	bb 00 00 00 d0       	mov    $0xd0000000,%ebx
			*fd_store = fd;
  8015b8:	89 1f                	mov    %ebx,(%edi)
  8015ba:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  8015bf:	eb 17                	jmp    8015d8 <fd_alloc+0x6d>
  8015c1:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8015c6:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8015cb:	75 c8                	jne    801595 <fd_alloc+0x2a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8015cd:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  8015d3:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  8015d8:	5b                   	pop    %ebx
  8015d9:	5e                   	pop    %esi
  8015da:	5f                   	pop    %edi
  8015db:	5d                   	pop    %ebp
  8015dc:	c3                   	ret    

008015dd <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8015dd:	55                   	push   %ebp
  8015de:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8015e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8015e3:	83 f8 1f             	cmp    $0x1f,%eax
  8015e6:	77 36                	ja     80161e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8015e8:	05 00 00 0d 00       	add    $0xd0000,%eax
  8015ed:	c1 e0 0c             	shl    $0xc,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
  8015f0:	89 c2                	mov    %eax,%edx
  8015f2:	c1 ea 16             	shr    $0x16,%edx
  8015f5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8015fc:	f6 c2 01             	test   $0x1,%dl
  8015ff:	74 1d                	je     80161e <fd_lookup+0x41>
  801601:	89 c2                	mov    %eax,%edx
  801603:	c1 ea 0c             	shr    $0xc,%edx
  801606:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80160d:	f6 c2 01             	test   $0x1,%dl
  801610:	74 0c                	je     80161e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  801612:	8b 55 0c             	mov    0xc(%ebp),%edx
  801615:	89 02                	mov    %eax,(%edx)
  801617:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
  80161c:	eb 05                	jmp    801623 <fd_lookup+0x46>
  80161e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801623:	5d                   	pop    %ebp
  801624:	c3                   	ret    

00801625 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  801625:	55                   	push   %ebp
  801626:	89 e5                	mov    %esp,%ebp
  801628:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80162b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80162e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801632:	8b 45 08             	mov    0x8(%ebp),%eax
  801635:	89 04 24             	mov    %eax,(%esp)
  801638:	e8 a0 ff ff ff       	call   8015dd <fd_lookup>
  80163d:	85 c0                	test   %eax,%eax
  80163f:	78 0e                	js     80164f <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801641:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801644:	8b 55 0c             	mov    0xc(%ebp),%edx
  801647:	89 50 04             	mov    %edx,0x4(%eax)
  80164a:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  80164f:	c9                   	leave  
  801650:	c3                   	ret    

00801651 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801651:	55                   	push   %ebp
  801652:	89 e5                	mov    %esp,%ebp
  801654:	56                   	push   %esi
  801655:	53                   	push   %ebx
  801656:	83 ec 10             	sub    $0x10,%esp
  801659:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80165c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
// File functions
// --------------------------------------------------------------

static struct Dev *devtab[] =
{
	&devfile,
  80165f:	b8 04 30 80 00       	mov    $0x803004,%eax
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  801664:	ba 00 00 00 00       	mov    $0x0,%edx

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801669:	be a8 2b 80 00       	mov    $0x802ba8,%esi
		if (devtab[i]->dev_id == dev_id) {
  80166e:	39 08                	cmp    %ecx,(%eax)
  801670:	75 10                	jne    801682 <dev_lookup+0x31>
  801672:	eb 04                	jmp    801678 <dev_lookup+0x27>
  801674:	39 08                	cmp    %ecx,(%eax)
  801676:	75 0a                	jne    801682 <dev_lookup+0x31>
			*dev = devtab[i];
  801678:	89 03                	mov    %eax,(%ebx)
  80167a:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  80167f:	90                   	nop
  801680:	eb 31                	jmp    8016b3 <dev_lookup+0x62>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801682:	83 c2 01             	add    $0x1,%edx
  801685:	8b 04 96             	mov    (%esi,%edx,4),%eax
  801688:	85 c0                	test   %eax,%eax
  80168a:	75 e8                	jne    801674 <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80168c:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801691:	8b 40 48             	mov    0x48(%eax),%eax
  801694:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801698:	89 44 24 04          	mov    %eax,0x4(%esp)
  80169c:	c7 04 24 2c 2b 80 00 	movl   $0x802b2c,(%esp)
  8016a3:	e8 91 ea ff ff       	call   800139 <cprintf>
	*dev = 0;
  8016a8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8016ae:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  8016b3:	83 c4 10             	add    $0x10,%esp
  8016b6:	5b                   	pop    %ebx
  8016b7:	5e                   	pop    %esi
  8016b8:	5d                   	pop    %ebp
  8016b9:	c3                   	ret    

008016ba <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  8016ba:	55                   	push   %ebp
  8016bb:	89 e5                	mov    %esp,%ebp
  8016bd:	53                   	push   %ebx
  8016be:	83 ec 24             	sub    $0x24,%esp
  8016c1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016c4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016c7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8016ce:	89 04 24             	mov    %eax,(%esp)
  8016d1:	e8 07 ff ff ff       	call   8015dd <fd_lookup>
  8016d6:	85 c0                	test   %eax,%eax
  8016d8:	78 53                	js     80172d <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016da:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016e4:	8b 00                	mov    (%eax),%eax
  8016e6:	89 04 24             	mov    %eax,(%esp)
  8016e9:	e8 63 ff ff ff       	call   801651 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016ee:	85 c0                	test   %eax,%eax
  8016f0:	78 3b                	js     80172d <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  8016f2:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8016f7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016fa:	83 7a 14 00          	cmpl   $0x0,0x14(%edx)
  8016fe:	74 2d                	je     80172d <fstat+0x73>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801700:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801703:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80170a:	00 00 00 
	stat->st_isdir = 0;
  80170d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801714:	00 00 00 
	stat->st_dev = dev;
  801717:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80171a:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801720:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801724:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801727:	89 14 24             	mov    %edx,(%esp)
  80172a:	ff 50 14             	call   *0x14(%eax)
}
  80172d:	83 c4 24             	add    $0x24,%esp
  801730:	5b                   	pop    %ebx
  801731:	5d                   	pop    %ebp
  801732:	c3                   	ret    

00801733 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  801733:	55                   	push   %ebp
  801734:	89 e5                	mov    %esp,%ebp
  801736:	53                   	push   %ebx
  801737:	83 ec 24             	sub    $0x24,%esp
  80173a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80173d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801740:	89 44 24 04          	mov    %eax,0x4(%esp)
  801744:	89 1c 24             	mov    %ebx,(%esp)
  801747:	e8 91 fe ff ff       	call   8015dd <fd_lookup>
  80174c:	85 c0                	test   %eax,%eax
  80174e:	78 5f                	js     8017af <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801750:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801753:	89 44 24 04          	mov    %eax,0x4(%esp)
  801757:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80175a:	8b 00                	mov    (%eax),%eax
  80175c:	89 04 24             	mov    %eax,(%esp)
  80175f:	e8 ed fe ff ff       	call   801651 <dev_lookup>
ftruncate(int fdnum, off_t newsize)
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801764:	85 c0                	test   %eax,%eax
  801766:	78 47                	js     8017af <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801768:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80176b:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  80176f:	75 23                	jne    801794 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801771:	a1 0c 40 80 00       	mov    0x80400c,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801776:	8b 40 48             	mov    0x48(%eax),%eax
  801779:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80177d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801781:	c7 04 24 4c 2b 80 00 	movl   $0x802b4c,(%esp)
  801788:	e8 ac e9 ff ff       	call   800139 <cprintf>
  80178d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801792:	eb 1b                	jmp    8017af <ftruncate+0x7c>
	}
	if (!dev->dev_trunc)
  801794:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801797:	8b 48 18             	mov    0x18(%eax),%ecx
  80179a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80179f:	85 c9                	test   %ecx,%ecx
  8017a1:	74 0c                	je     8017af <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8017a3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017a6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017aa:	89 14 24             	mov    %edx,(%esp)
  8017ad:	ff d1                	call   *%ecx
}
  8017af:	83 c4 24             	add    $0x24,%esp
  8017b2:	5b                   	pop    %ebx
  8017b3:	5d                   	pop    %ebp
  8017b4:	c3                   	ret    

008017b5 <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8017b5:	55                   	push   %ebp
  8017b6:	89 e5                	mov    %esp,%ebp
  8017b8:	53                   	push   %ebx
  8017b9:	83 ec 24             	sub    $0x24,%esp
  8017bc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017bf:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017c2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017c6:	89 1c 24             	mov    %ebx,(%esp)
  8017c9:	e8 0f fe ff ff       	call   8015dd <fd_lookup>
  8017ce:	85 c0                	test   %eax,%eax
  8017d0:	78 66                	js     801838 <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017d2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017dc:	8b 00                	mov    (%eax),%eax
  8017de:	89 04 24             	mov    %eax,(%esp)
  8017e1:	e8 6b fe ff ff       	call   801651 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017e6:	85 c0                	test   %eax,%eax
  8017e8:	78 4e                	js     801838 <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8017ea:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8017ed:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  8017f1:	75 23                	jne    801816 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8017f3:	a1 0c 40 80 00       	mov    0x80400c,%eax
  8017f8:	8b 40 48             	mov    0x48(%eax),%eax
  8017fb:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8017ff:	89 44 24 04          	mov    %eax,0x4(%esp)
  801803:	c7 04 24 6d 2b 80 00 	movl   $0x802b6d,(%esp)
  80180a:	e8 2a e9 ff ff       	call   800139 <cprintf>
  80180f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801814:	eb 22                	jmp    801838 <write+0x83>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801816:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801819:	8b 48 0c             	mov    0xc(%eax),%ecx
  80181c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801821:	85 c9                	test   %ecx,%ecx
  801823:	74 13                	je     801838 <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801825:	8b 45 10             	mov    0x10(%ebp),%eax
  801828:	89 44 24 08          	mov    %eax,0x8(%esp)
  80182c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80182f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801833:	89 14 24             	mov    %edx,(%esp)
  801836:	ff d1                	call   *%ecx
}
  801838:	83 c4 24             	add    $0x24,%esp
  80183b:	5b                   	pop    %ebx
  80183c:	5d                   	pop    %ebp
  80183d:	c3                   	ret    

0080183e <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80183e:	55                   	push   %ebp
  80183f:	89 e5                	mov    %esp,%ebp
  801841:	53                   	push   %ebx
  801842:	83 ec 24             	sub    $0x24,%esp
  801845:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801848:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80184b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80184f:	89 1c 24             	mov    %ebx,(%esp)
  801852:	e8 86 fd ff ff       	call   8015dd <fd_lookup>
  801857:	85 c0                	test   %eax,%eax
  801859:	78 6b                	js     8018c6 <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80185b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80185e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801862:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801865:	8b 00                	mov    (%eax),%eax
  801867:	89 04 24             	mov    %eax,(%esp)
  80186a:	e8 e2 fd ff ff       	call   801651 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80186f:	85 c0                	test   %eax,%eax
  801871:	78 53                	js     8018c6 <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801873:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801876:	8b 42 08             	mov    0x8(%edx),%eax
  801879:	83 e0 03             	and    $0x3,%eax
  80187c:	83 f8 01             	cmp    $0x1,%eax
  80187f:	75 23                	jne    8018a4 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801881:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801886:	8b 40 48             	mov    0x48(%eax),%eax
  801889:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80188d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801891:	c7 04 24 8a 2b 80 00 	movl   $0x802b8a,(%esp)
  801898:	e8 9c e8 ff ff       	call   800139 <cprintf>
  80189d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  8018a2:	eb 22                	jmp    8018c6 <read+0x88>
	}
	if (!dev->dev_read)
  8018a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018a7:	8b 48 08             	mov    0x8(%eax),%ecx
  8018aa:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8018af:	85 c9                	test   %ecx,%ecx
  8018b1:	74 13                	je     8018c6 <read+0x88>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8018b3:	8b 45 10             	mov    0x10(%ebp),%eax
  8018b6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8018ba:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018c1:	89 14 24             	mov    %edx,(%esp)
  8018c4:	ff d1                	call   *%ecx
}
  8018c6:	83 c4 24             	add    $0x24,%esp
  8018c9:	5b                   	pop    %ebx
  8018ca:	5d                   	pop    %ebp
  8018cb:	c3                   	ret    

008018cc <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8018cc:	55                   	push   %ebp
  8018cd:	89 e5                	mov    %esp,%ebp
  8018cf:	57                   	push   %edi
  8018d0:	56                   	push   %esi
  8018d1:	53                   	push   %ebx
  8018d2:	83 ec 1c             	sub    $0x1c,%esp
  8018d5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8018d8:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8018db:	ba 00 00 00 00       	mov    $0x0,%edx
  8018e0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8018e5:	b8 00 00 00 00       	mov    $0x0,%eax
  8018ea:	85 f6                	test   %esi,%esi
  8018ec:	74 29                	je     801917 <readn+0x4b>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8018ee:	89 f0                	mov    %esi,%eax
  8018f0:	29 d0                	sub    %edx,%eax
  8018f2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8018f6:	03 55 0c             	add    0xc(%ebp),%edx
  8018f9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8018fd:	89 3c 24             	mov    %edi,(%esp)
  801900:	e8 39 ff ff ff       	call   80183e <read>
		if (m < 0)
  801905:	85 c0                	test   %eax,%eax
  801907:	78 0e                	js     801917 <readn+0x4b>
			return m;
		if (m == 0)
  801909:	85 c0                	test   %eax,%eax
  80190b:	74 08                	je     801915 <readn+0x49>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80190d:	01 c3                	add    %eax,%ebx
  80190f:	89 da                	mov    %ebx,%edx
  801911:	39 f3                	cmp    %esi,%ebx
  801913:	72 d9                	jb     8018ee <readn+0x22>
  801915:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801917:	83 c4 1c             	add    $0x1c,%esp
  80191a:	5b                   	pop    %ebx
  80191b:	5e                   	pop    %esi
  80191c:	5f                   	pop    %edi
  80191d:	5d                   	pop    %ebp
  80191e:	c3                   	ret    

0080191f <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80191f:	55                   	push   %ebp
  801920:	89 e5                	mov    %esp,%ebp
  801922:	56                   	push   %esi
  801923:	53                   	push   %ebx
  801924:	83 ec 20             	sub    $0x20,%esp
  801927:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80192a:	89 34 24             	mov    %esi,(%esp)
  80192d:	e8 0e fc ff ff       	call   801540 <fd2num>
  801932:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801935:	89 54 24 04          	mov    %edx,0x4(%esp)
  801939:	89 04 24             	mov    %eax,(%esp)
  80193c:	e8 9c fc ff ff       	call   8015dd <fd_lookup>
  801941:	89 c3                	mov    %eax,%ebx
  801943:	85 c0                	test   %eax,%eax
  801945:	78 05                	js     80194c <fd_close+0x2d>
  801947:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80194a:	74 0c                	je     801958 <fd_close+0x39>
	    || fd != fd2)
		return (must_exist ? r : 0);
  80194c:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  801950:	19 c0                	sbb    %eax,%eax
  801952:	f7 d0                	not    %eax
  801954:	21 c3                	and    %eax,%ebx
  801956:	eb 3d                	jmp    801995 <fd_close+0x76>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801958:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80195b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80195f:	8b 06                	mov    (%esi),%eax
  801961:	89 04 24             	mov    %eax,(%esp)
  801964:	e8 e8 fc ff ff       	call   801651 <dev_lookup>
  801969:	89 c3                	mov    %eax,%ebx
  80196b:	85 c0                	test   %eax,%eax
  80196d:	78 16                	js     801985 <fd_close+0x66>
		if (dev->dev_close)
  80196f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801972:	8b 40 10             	mov    0x10(%eax),%eax
  801975:	bb 00 00 00 00       	mov    $0x0,%ebx
  80197a:	85 c0                	test   %eax,%eax
  80197c:	74 07                	je     801985 <fd_close+0x66>
			r = (*dev->dev_close)(fd);
  80197e:	89 34 24             	mov    %esi,(%esp)
  801981:	ff d0                	call   *%eax
  801983:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801985:	89 74 24 04          	mov    %esi,0x4(%esp)
  801989:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801990:	e8 29 f9 ff ff       	call   8012be <sys_page_unmap>
	return r;
}
  801995:	89 d8                	mov    %ebx,%eax
  801997:	83 c4 20             	add    $0x20,%esp
  80199a:	5b                   	pop    %ebx
  80199b:	5e                   	pop    %esi
  80199c:	5d                   	pop    %ebp
  80199d:	c3                   	ret    

0080199e <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80199e:	55                   	push   %ebp
  80199f:	89 e5                	mov    %esp,%ebp
  8019a1:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8019a4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019a7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8019ae:	89 04 24             	mov    %eax,(%esp)
  8019b1:	e8 27 fc ff ff       	call   8015dd <fd_lookup>
  8019b6:	85 c0                	test   %eax,%eax
  8019b8:	78 13                	js     8019cd <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  8019ba:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8019c1:	00 
  8019c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019c5:	89 04 24             	mov    %eax,(%esp)
  8019c8:	e8 52 ff ff ff       	call   80191f <fd_close>
}
  8019cd:	c9                   	leave  
  8019ce:	c3                   	ret    

008019cf <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  8019cf:	55                   	push   %ebp
  8019d0:	89 e5                	mov    %esp,%ebp
  8019d2:	83 ec 18             	sub    $0x18,%esp
  8019d5:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8019d8:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8019db:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8019e2:	00 
  8019e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8019e6:	89 04 24             	mov    %eax,(%esp)
  8019e9:	e8 79 03 00 00       	call   801d67 <open>
  8019ee:	89 c3                	mov    %eax,%ebx
  8019f0:	85 c0                	test   %eax,%eax
  8019f2:	78 1b                	js     801a0f <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  8019f4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019f7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019fb:	89 1c 24             	mov    %ebx,(%esp)
  8019fe:	e8 b7 fc ff ff       	call   8016ba <fstat>
  801a03:	89 c6                	mov    %eax,%esi
	close(fd);
  801a05:	89 1c 24             	mov    %ebx,(%esp)
  801a08:	e8 91 ff ff ff       	call   80199e <close>
  801a0d:	89 f3                	mov    %esi,%ebx
	return r;
}
  801a0f:	89 d8                	mov    %ebx,%eax
  801a11:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801a14:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801a17:	89 ec                	mov    %ebp,%esp
  801a19:	5d                   	pop    %ebp
  801a1a:	c3                   	ret    

00801a1b <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  801a1b:	55                   	push   %ebp
  801a1c:	89 e5                	mov    %esp,%ebp
  801a1e:	53                   	push   %ebx
  801a1f:	83 ec 14             	sub    $0x14,%esp
  801a22:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  801a27:	89 1c 24             	mov    %ebx,(%esp)
  801a2a:	e8 6f ff ff ff       	call   80199e <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801a2f:	83 c3 01             	add    $0x1,%ebx
  801a32:	83 fb 20             	cmp    $0x20,%ebx
  801a35:	75 f0                	jne    801a27 <close_all+0xc>
		close(i);
}
  801a37:	83 c4 14             	add    $0x14,%esp
  801a3a:	5b                   	pop    %ebx
  801a3b:	5d                   	pop    %ebp
  801a3c:	c3                   	ret    

00801a3d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801a3d:	55                   	push   %ebp
  801a3e:	89 e5                	mov    %esp,%ebp
  801a40:	83 ec 58             	sub    $0x58,%esp
  801a43:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801a46:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801a49:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801a4c:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801a4f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801a52:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a56:	8b 45 08             	mov    0x8(%ebp),%eax
  801a59:	89 04 24             	mov    %eax,(%esp)
  801a5c:	e8 7c fb ff ff       	call   8015dd <fd_lookup>
  801a61:	89 c3                	mov    %eax,%ebx
  801a63:	85 c0                	test   %eax,%eax
  801a65:	0f 88 e0 00 00 00    	js     801b4b <dup+0x10e>
		return r;
	close(newfdnum);
  801a6b:	89 3c 24             	mov    %edi,(%esp)
  801a6e:	e8 2b ff ff ff       	call   80199e <close>

	newfd = INDEX2FD(newfdnum);
  801a73:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801a79:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801a7c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a7f:	89 04 24             	mov    %eax,(%esp)
  801a82:	e8 c9 fa ff ff       	call   801550 <fd2data>
  801a87:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801a89:	89 34 24             	mov    %esi,(%esp)
  801a8c:	e8 bf fa ff ff       	call   801550 <fd2data>
  801a91:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
  801a94:	89 da                	mov    %ebx,%edx
  801a96:	89 d8                	mov    %ebx,%eax
  801a98:	c1 e8 16             	shr    $0x16,%eax
  801a9b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801aa2:	a8 01                	test   $0x1,%al
  801aa4:	74 43                	je     801ae9 <dup+0xac>
  801aa6:	c1 ea 0c             	shr    $0xc,%edx
  801aa9:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801ab0:	a8 01                	test   $0x1,%al
  801ab2:	74 35                	je     801ae9 <dup+0xac>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801ab4:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801abb:	25 07 0e 00 00       	and    $0xe07,%eax
  801ac0:	89 44 24 10          	mov    %eax,0x10(%esp)
  801ac4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801ac7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801acb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801ad2:	00 
  801ad3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801ad7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ade:	e8 47 f8 ff ff       	call   80132a <sys_page_map>
  801ae3:	89 c3                	mov    %eax,%ebx
  801ae5:	85 c0                	test   %eax,%eax
  801ae7:	78 3f                	js     801b28 <dup+0xeb>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801ae9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801aec:	89 c2                	mov    %eax,%edx
  801aee:	c1 ea 0c             	shr    $0xc,%edx
  801af1:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801af8:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801afe:	89 54 24 10          	mov    %edx,0x10(%esp)
  801b02:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801b06:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801b0d:	00 
  801b0e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b12:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b19:	e8 0c f8 ff ff       	call   80132a <sys_page_map>
  801b1e:	89 c3                	mov    %eax,%ebx
  801b20:	85 c0                	test   %eax,%eax
  801b22:	78 04                	js     801b28 <dup+0xeb>
  801b24:	89 fb                	mov    %edi,%ebx
  801b26:	eb 23                	jmp    801b4b <dup+0x10e>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801b28:	89 74 24 04          	mov    %esi,0x4(%esp)
  801b2c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b33:	e8 86 f7 ff ff       	call   8012be <sys_page_unmap>
	sys_page_unmap(0, nva);
  801b38:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801b3b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b3f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b46:	e8 73 f7 ff ff       	call   8012be <sys_page_unmap>
	return r;
}
  801b4b:	89 d8                	mov    %ebx,%eax
  801b4d:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801b50:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801b53:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801b56:	89 ec                	mov    %ebp,%esp
  801b58:	5d                   	pop    %ebp
  801b59:	c3                   	ret    
	...

00801b5c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801b5c:	55                   	push   %ebp
  801b5d:	89 e5                	mov    %esp,%ebp
  801b5f:	83 ec 18             	sub    $0x18,%esp
  801b62:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801b65:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801b68:	89 c3                	mov    %eax,%ebx
  801b6a:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801b6c:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801b73:	75 11                	jne    801b86 <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801b75:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801b7c:	e8 ef 07 00 00       	call   802370 <ipc_find_env>
  801b81:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801b86:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801b8d:	00 
  801b8e:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801b95:	00 
  801b96:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801b9a:	a1 00 40 80 00       	mov    0x804000,%eax
  801b9f:	89 04 24             	mov    %eax,(%esp)
  801ba2:	e8 14 08 00 00       	call   8023bb <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801ba7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801bae:	00 
  801baf:	89 74 24 04          	mov    %esi,0x4(%esp)
  801bb3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801bba:	e8 7a 08 00 00       	call   802439 <ipc_recv>
}
  801bbf:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801bc2:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801bc5:	89 ec                	mov    %ebp,%esp
  801bc7:	5d                   	pop    %ebp
  801bc8:	c3                   	ret    

00801bc9 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801bc9:	55                   	push   %ebp
  801bca:	89 e5                	mov    %esp,%ebp
  801bcc:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801bcf:	8b 45 08             	mov    0x8(%ebp),%eax
  801bd2:	8b 40 0c             	mov    0xc(%eax),%eax
  801bd5:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801bda:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bdd:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801be2:	ba 00 00 00 00       	mov    $0x0,%edx
  801be7:	b8 02 00 00 00       	mov    $0x2,%eax
  801bec:	e8 6b ff ff ff       	call   801b5c <fsipc>
}
  801bf1:	c9                   	leave  
  801bf2:	c3                   	ret    

00801bf3 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801bf3:	55                   	push   %ebp
  801bf4:	89 e5                	mov    %esp,%ebp
  801bf6:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801bf9:	8b 45 08             	mov    0x8(%ebp),%eax
  801bfc:	8b 40 0c             	mov    0xc(%eax),%eax
  801bff:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801c04:	ba 00 00 00 00       	mov    $0x0,%edx
  801c09:	b8 06 00 00 00       	mov    $0x6,%eax
  801c0e:	e8 49 ff ff ff       	call   801b5c <fsipc>
}
  801c13:	c9                   	leave  
  801c14:	c3                   	ret    

00801c15 <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  801c15:	55                   	push   %ebp
  801c16:	89 e5                	mov    %esp,%ebp
  801c18:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801c1b:	ba 00 00 00 00       	mov    $0x0,%edx
  801c20:	b8 08 00 00 00       	mov    $0x8,%eax
  801c25:	e8 32 ff ff ff       	call   801b5c <fsipc>
}
  801c2a:	c9                   	leave  
  801c2b:	c3                   	ret    

00801c2c <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801c2c:	55                   	push   %ebp
  801c2d:	89 e5                	mov    %esp,%ebp
  801c2f:	53                   	push   %ebx
  801c30:	83 ec 14             	sub    $0x14,%esp
  801c33:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801c36:	8b 45 08             	mov    0x8(%ebp),%eax
  801c39:	8b 40 0c             	mov    0xc(%eax),%eax
  801c3c:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801c41:	ba 00 00 00 00       	mov    $0x0,%edx
  801c46:	b8 05 00 00 00       	mov    $0x5,%eax
  801c4b:	e8 0c ff ff ff       	call   801b5c <fsipc>
  801c50:	85 c0                	test   %eax,%eax
  801c52:	78 2b                	js     801c7f <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801c54:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801c5b:	00 
  801c5c:	89 1c 24             	mov    %ebx,(%esp)
  801c5f:	e8 06 ee ff ff       	call   800a6a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801c64:	a1 80 50 80 00       	mov    0x805080,%eax
  801c69:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801c6f:	a1 84 50 80 00       	mov    0x805084,%eax
  801c74:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  801c7a:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  801c7f:	83 c4 14             	add    $0x14,%esp
  801c82:	5b                   	pop    %ebx
  801c83:	5d                   	pop    %ebp
  801c84:	c3                   	ret    

00801c85 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801c85:	55                   	push   %ebp
  801c86:	89 e5                	mov    %esp,%ebp
  801c88:	83 ec 18             	sub    $0x18,%esp
  801c8b:	8b 45 10             	mov    0x10(%ebp),%eax
  801c8e:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801c93:	76 05                	jbe    801c9a <devfile_write+0x15>
  801c95:	b8 f8 0f 00 00       	mov    $0xff8,%eax
	// bytes than requested.
	// LAB 5: Your code here
        int r;
        if(n > sizeof(fsipcbuf.write.req_buf))
            n = sizeof(fsipcbuf.write.req_buf);
        fsipcbuf.write.req_fileid = fd->fd_file.id;
  801c9a:	8b 55 08             	mov    0x8(%ebp),%edx
  801c9d:	8b 52 0c             	mov    0xc(%edx),%edx
  801ca0:	89 15 00 50 80 00    	mov    %edx,0x805000
        fsipcbuf.write.req_n = n;
  801ca6:	a3 04 50 80 00       	mov    %eax,0x805004
        memmove(fsipcbuf.write.req_buf,buf,n);  
  801cab:	89 44 24 08          	mov    %eax,0x8(%esp)
  801caf:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cb2:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cb6:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  801cbd:	e8 93 ef ff ff       	call   800c55 <memmove>
        r = fsipc(FSREQ_WRITE,NULL);
  801cc2:	ba 00 00 00 00       	mov    $0x0,%edx
  801cc7:	b8 04 00 00 00       	mov    $0x4,%eax
  801ccc:	e8 8b fe ff ff       	call   801b5c <fsipc>
        return r;
	//panic("devfile_write not implemented");
}
  801cd1:	c9                   	leave  
  801cd2:	c3                   	ret    

00801cd3 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801cd3:	55                   	push   %ebp
  801cd4:	89 e5                	mov    %esp,%ebp
  801cd6:	53                   	push   %ebx
  801cd7:	83 ec 14             	sub    $0x14,%esp
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
        int r;
        fsipcbuf.read.req_fileid = fd->fd_file.id;
  801cda:	8b 45 08             	mov    0x8(%ebp),%eax
  801cdd:	8b 40 0c             	mov    0xc(%eax),%eax
  801ce0:	a3 00 50 80 00       	mov    %eax,0x805000
        fsipcbuf.read.req_n = n;
  801ce5:	8b 45 10             	mov    0x10(%ebp),%eax
  801ce8:	a3 04 50 80 00       	mov    %eax,0x805004
        r = fsipc(FSREQ_READ,NULL);
  801ced:	ba 00 00 00 00       	mov    $0x0,%edx
  801cf2:	b8 03 00 00 00       	mov    $0x3,%eax
  801cf7:	e8 60 fe ff ff       	call   801b5c <fsipc>
  801cfc:	89 c3                	mov    %eax,%ebx
        if(r < 0)
  801cfe:	85 c0                	test   %eax,%eax
  801d00:	78 17                	js     801d19 <devfile_read+0x46>
           return r;
        memmove(buf,fsipcbuf.readRet.ret_buf,r);
  801d02:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d06:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801d0d:	00 
  801d0e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d11:	89 04 24             	mov    %eax,(%esp)
  801d14:	e8 3c ef ff ff       	call   800c55 <memmove>
        return r;
	//panic("devfile_read not implemented");
}
  801d19:	89 d8                	mov    %ebx,%eax
  801d1b:	83 c4 14             	add    $0x14,%esp
  801d1e:	5b                   	pop    %ebx
  801d1f:	5d                   	pop    %ebp
  801d20:	c3                   	ret    

00801d21 <remove>:
}

// Delete a file
int
remove(const char *path)
{
  801d21:	55                   	push   %ebp
  801d22:	89 e5                	mov    %esp,%ebp
  801d24:	53                   	push   %ebx
  801d25:	83 ec 14             	sub    $0x14,%esp
  801d28:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  801d2b:	89 1c 24             	mov    %ebx,(%esp)
  801d2e:	e8 ed ec ff ff       	call   800a20 <strlen>
  801d33:	89 c2                	mov    %eax,%edx
  801d35:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  801d3a:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
  801d40:	7f 1f                	jg     801d61 <remove+0x40>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  801d42:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801d46:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801d4d:	e8 18 ed ff ff       	call   800a6a <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  801d52:	ba 00 00 00 00       	mov    $0x0,%edx
  801d57:	b8 07 00 00 00       	mov    $0x7,%eax
  801d5c:	e8 fb fd ff ff       	call   801b5c <fsipc>
}
  801d61:	83 c4 14             	add    $0x14,%esp
  801d64:	5b                   	pop    %ebx
  801d65:	5d                   	pop    %ebp
  801d66:	c3                   	ret    

00801d67 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801d67:	55                   	push   %ebp
  801d68:	89 e5                	mov    %esp,%ebp
  801d6a:	83 ec 28             	sub    $0x28,%esp
  801d6d:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801d70:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801d73:	8b 75 08             	mov    0x8(%ebp),%esi
	// If any step after fd_alloc fails, use fd_close to free the
	// file descriptor.

	// LAB 5: Your code here.
        struct Fd* fd;
        if(strlen(path) > MAXPATHLEN)
  801d76:	89 34 24             	mov    %esi,(%esp)
  801d79:	e8 a2 ec ff ff       	call   800a20 <strlen>
  801d7e:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801d83:	3d 00 04 00 00       	cmp    $0x400,%eax
  801d88:	7f 6d                	jg     801df7 <open+0x90>
            return -E_BAD_PATH;
        int r;
        r = fd_alloc(&fd);
  801d8a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d8d:	89 04 24             	mov    %eax,(%esp)
  801d90:	e8 d6 f7 ff ff       	call   80156b <fd_alloc>
  801d95:	89 c3                	mov    %eax,%ebx
        if(r < 0)
  801d97:	85 c0                	test   %eax,%eax
  801d99:	78 5c                	js     801df7 <open+0x90>
           return r;
        fsipcbuf.open.req_omode = mode;
  801d9b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d9e:	a3 00 54 80 00       	mov    %eax,0x805400
        memmove(fsipcbuf.open.req_path,path,strlen(path)+1);
  801da3:	89 34 24             	mov    %esi,(%esp)
  801da6:	e8 75 ec ff ff       	call   800a20 <strlen>
  801dab:	83 c0 01             	add    $0x1,%eax
  801dae:	89 44 24 08          	mov    %eax,0x8(%esp)
  801db2:	89 74 24 04          	mov    %esi,0x4(%esp)
  801db6:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801dbd:	e8 93 ee ff ff       	call   800c55 <memmove>
        r = fsipc(FSREQ_OPEN,(void*)fd);
  801dc2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801dc5:	b8 01 00 00 00       	mov    $0x1,%eax
  801dca:	e8 8d fd ff ff       	call   801b5c <fsipc>
  801dcf:	89 c3                	mov    %eax,%ebx
        if(r < 0){
  801dd1:	85 c0                	test   %eax,%eax
  801dd3:	79 15                	jns    801dea <open+0x83>
             fd_close(fd,0);
  801dd5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801ddc:	00 
  801ddd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801de0:	89 04 24             	mov    %eax,(%esp)
  801de3:	e8 37 fb ff ff       	call   80191f <fd_close>
             return r;
  801de8:	eb 0d                	jmp    801df7 <open+0x90>
        }
        return fd2num(fd);
  801dea:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ded:	89 04 24             	mov    %eax,(%esp)
  801df0:	e8 4b f7 ff ff       	call   801540 <fd2num>
  801df5:	89 c3                	mov    %eax,%ebx
	//panic("open not implemented");
}
  801df7:	89 d8                	mov    %ebx,%eax
  801df9:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801dfc:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801dff:	89 ec                	mov    %ebp,%esp
  801e01:	5d                   	pop    %ebp
  801e02:	c3                   	ret    
	...

00801e10 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801e10:	55                   	push   %ebp
  801e11:	89 e5                	mov    %esp,%ebp
  801e13:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  801e16:	c7 44 24 04 b4 2b 80 	movl   $0x802bb4,0x4(%esp)
  801e1d:	00 
  801e1e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e21:	89 04 24             	mov    %eax,(%esp)
  801e24:	e8 41 ec ff ff       	call   800a6a <strcpy>
	return 0;
}
  801e29:	b8 00 00 00 00       	mov    $0x0,%eax
  801e2e:	c9                   	leave  
  801e2f:	c3                   	ret    

00801e30 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801e30:	55                   	push   %ebp
  801e31:	89 e5                	mov    %esp,%ebp
  801e33:	53                   	push   %ebx
  801e34:	83 ec 14             	sub    $0x14,%esp
  801e37:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801e3a:	89 1c 24             	mov    %ebx,(%esp)
  801e3d:	e8 6a 06 00 00       	call   8024ac <pageref>
  801e42:	89 c2                	mov    %eax,%edx
  801e44:	b8 00 00 00 00       	mov    $0x0,%eax
  801e49:	83 fa 01             	cmp    $0x1,%edx
  801e4c:	75 0b                	jne    801e59 <devsock_close+0x29>
		return nsipc_close(fd->fd_sock.sockid);
  801e4e:	8b 43 0c             	mov    0xc(%ebx),%eax
  801e51:	89 04 24             	mov    %eax,(%esp)
  801e54:	e8 b9 02 00 00       	call   802112 <nsipc_close>
	else
		return 0;
}
  801e59:	83 c4 14             	add    $0x14,%esp
  801e5c:	5b                   	pop    %ebx
  801e5d:	5d                   	pop    %ebp
  801e5e:	c3                   	ret    

00801e5f <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801e5f:	55                   	push   %ebp
  801e60:	89 e5                	mov    %esp,%ebp
  801e62:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801e65:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801e6c:	00 
  801e6d:	8b 45 10             	mov    0x10(%ebp),%eax
  801e70:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e74:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e77:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e7b:	8b 45 08             	mov    0x8(%ebp),%eax
  801e7e:	8b 40 0c             	mov    0xc(%eax),%eax
  801e81:	89 04 24             	mov    %eax,(%esp)
  801e84:	e8 c5 02 00 00       	call   80214e <nsipc_send>
}
  801e89:	c9                   	leave  
  801e8a:	c3                   	ret    

00801e8b <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801e8b:	55                   	push   %ebp
  801e8c:	89 e5                	mov    %esp,%ebp
  801e8e:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801e91:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801e98:	00 
  801e99:	8b 45 10             	mov    0x10(%ebp),%eax
  801e9c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ea0:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ea3:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ea7:	8b 45 08             	mov    0x8(%ebp),%eax
  801eaa:	8b 40 0c             	mov    0xc(%eax),%eax
  801ead:	89 04 24             	mov    %eax,(%esp)
  801eb0:	e8 0c 03 00 00       	call   8021c1 <nsipc_recv>
}
  801eb5:	c9                   	leave  
  801eb6:	c3                   	ret    

00801eb7 <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  801eb7:	55                   	push   %ebp
  801eb8:	89 e5                	mov    %esp,%ebp
  801eba:	56                   	push   %esi
  801ebb:	53                   	push   %ebx
  801ebc:	83 ec 20             	sub    $0x20,%esp
  801ebf:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801ec1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ec4:	89 04 24             	mov    %eax,(%esp)
  801ec7:	e8 9f f6 ff ff       	call   80156b <fd_alloc>
  801ecc:	89 c3                	mov    %eax,%ebx
  801ece:	85 c0                	test   %eax,%eax
  801ed0:	78 21                	js     801ef3 <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801ed2:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801ed9:	00 
  801eda:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801edd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ee1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ee8:	e8 ab f4 ff ff       	call   801398 <sys_page_alloc>
  801eed:	89 c3                	mov    %eax,%ebx
alloc_sockfd(int sockid)
{
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801eef:	85 c0                	test   %eax,%eax
  801ef1:	79 0a                	jns    801efd <alloc_sockfd+0x46>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
		nsipc_close(sockid);
  801ef3:	89 34 24             	mov    %esi,(%esp)
  801ef6:	e8 17 02 00 00       	call   802112 <nsipc_close>
		return r;
  801efb:	eb 28                	jmp    801f25 <alloc_sockfd+0x6e>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801efd:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801f03:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f06:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801f08:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f0b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801f12:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f15:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801f18:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f1b:	89 04 24             	mov    %eax,(%esp)
  801f1e:	e8 1d f6 ff ff       	call   801540 <fd2num>
  801f23:	89 c3                	mov    %eax,%ebx
}
  801f25:	89 d8                	mov    %ebx,%eax
  801f27:	83 c4 20             	add    $0x20,%esp
  801f2a:	5b                   	pop    %ebx
  801f2b:	5e                   	pop    %esi
  801f2c:	5d                   	pop    %ebp
  801f2d:	c3                   	ret    

00801f2e <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801f2e:	55                   	push   %ebp
  801f2f:	89 e5                	mov    %esp,%ebp
  801f31:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801f34:	8b 45 10             	mov    0x10(%ebp),%eax
  801f37:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f3b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f3e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f42:	8b 45 08             	mov    0x8(%ebp),%eax
  801f45:	89 04 24             	mov    %eax,(%esp)
  801f48:	e8 79 01 00 00       	call   8020c6 <nsipc_socket>
  801f4d:	85 c0                	test   %eax,%eax
  801f4f:	78 05                	js     801f56 <socket+0x28>
		return r;
	return alloc_sockfd(r);
  801f51:	e8 61 ff ff ff       	call   801eb7 <alloc_sockfd>
}
  801f56:	c9                   	leave  
  801f57:	c3                   	ret    

00801f58 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801f58:	55                   	push   %ebp
  801f59:	89 e5                	mov    %esp,%ebp
  801f5b:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801f5e:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801f61:	89 54 24 04          	mov    %edx,0x4(%esp)
  801f65:	89 04 24             	mov    %eax,(%esp)
  801f68:	e8 70 f6 ff ff       	call   8015dd <fd_lookup>
  801f6d:	85 c0                	test   %eax,%eax
  801f6f:	78 15                	js     801f86 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801f71:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801f74:	8b 0a                	mov    (%edx),%ecx
  801f76:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801f7b:	3b 0d 20 30 80 00    	cmp    0x803020,%ecx
  801f81:	75 03                	jne    801f86 <fd2sockid+0x2e>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801f83:	8b 42 0c             	mov    0xc(%edx),%eax
}
  801f86:	c9                   	leave  
  801f87:	c3                   	ret    

00801f88 <listen>:
	return nsipc_connect(r, name, namelen);
}

int
listen(int s, int backlog)
{
  801f88:	55                   	push   %ebp
  801f89:	89 e5                	mov    %esp,%ebp
  801f8b:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801f8e:	8b 45 08             	mov    0x8(%ebp),%eax
  801f91:	e8 c2 ff ff ff       	call   801f58 <fd2sockid>
  801f96:	85 c0                	test   %eax,%eax
  801f98:	78 0f                	js     801fa9 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801f9a:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f9d:	89 54 24 04          	mov    %edx,0x4(%esp)
  801fa1:	89 04 24             	mov    %eax,(%esp)
  801fa4:	e8 47 01 00 00       	call   8020f0 <nsipc_listen>
}
  801fa9:	c9                   	leave  
  801faa:	c3                   	ret    

00801fab <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801fab:	55                   	push   %ebp
  801fac:	89 e5                	mov    %esp,%ebp
  801fae:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801fb1:	8b 45 08             	mov    0x8(%ebp),%eax
  801fb4:	e8 9f ff ff ff       	call   801f58 <fd2sockid>
  801fb9:	85 c0                	test   %eax,%eax
  801fbb:	78 16                	js     801fd3 <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  801fbd:	8b 55 10             	mov    0x10(%ebp),%edx
  801fc0:	89 54 24 08          	mov    %edx,0x8(%esp)
  801fc4:	8b 55 0c             	mov    0xc(%ebp),%edx
  801fc7:	89 54 24 04          	mov    %edx,0x4(%esp)
  801fcb:	89 04 24             	mov    %eax,(%esp)
  801fce:	e8 6e 02 00 00       	call   802241 <nsipc_connect>
}
  801fd3:	c9                   	leave  
  801fd4:	c3                   	ret    

00801fd5 <shutdown>:
	return nsipc_bind(r, name, namelen);
}

int
shutdown(int s, int how)
{
  801fd5:	55                   	push   %ebp
  801fd6:	89 e5                	mov    %esp,%ebp
  801fd8:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801fdb:	8b 45 08             	mov    0x8(%ebp),%eax
  801fde:	e8 75 ff ff ff       	call   801f58 <fd2sockid>
  801fe3:	85 c0                	test   %eax,%eax
  801fe5:	78 0f                	js     801ff6 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801fe7:	8b 55 0c             	mov    0xc(%ebp),%edx
  801fea:	89 54 24 04          	mov    %edx,0x4(%esp)
  801fee:	89 04 24             	mov    %eax,(%esp)
  801ff1:	e8 36 01 00 00       	call   80212c <nsipc_shutdown>
}
  801ff6:	c9                   	leave  
  801ff7:	c3                   	ret    

00801ff8 <bind>:
	return alloc_sockfd(r);
}

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801ff8:	55                   	push   %ebp
  801ff9:	89 e5                	mov    %esp,%ebp
  801ffb:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801ffe:	8b 45 08             	mov    0x8(%ebp),%eax
  802001:	e8 52 ff ff ff       	call   801f58 <fd2sockid>
  802006:	85 c0                	test   %eax,%eax
  802008:	78 16                	js     802020 <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  80200a:	8b 55 10             	mov    0x10(%ebp),%edx
  80200d:	89 54 24 08          	mov    %edx,0x8(%esp)
  802011:	8b 55 0c             	mov    0xc(%ebp),%edx
  802014:	89 54 24 04          	mov    %edx,0x4(%esp)
  802018:	89 04 24             	mov    %eax,(%esp)
  80201b:	e8 60 02 00 00       	call   802280 <nsipc_bind>
}
  802020:	c9                   	leave  
  802021:	c3                   	ret    

00802022 <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  802022:	55                   	push   %ebp
  802023:	89 e5                	mov    %esp,%ebp
  802025:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802028:	8b 45 08             	mov    0x8(%ebp),%eax
  80202b:	e8 28 ff ff ff       	call   801f58 <fd2sockid>
  802030:	85 c0                	test   %eax,%eax
  802032:	78 1f                	js     802053 <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  802034:	8b 55 10             	mov    0x10(%ebp),%edx
  802037:	89 54 24 08          	mov    %edx,0x8(%esp)
  80203b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80203e:	89 54 24 04          	mov    %edx,0x4(%esp)
  802042:	89 04 24             	mov    %eax,(%esp)
  802045:	e8 75 02 00 00       	call   8022bf <nsipc_accept>
  80204a:	85 c0                	test   %eax,%eax
  80204c:	78 05                	js     802053 <accept+0x31>
		return r;
	return alloc_sockfd(r);
  80204e:	e8 64 fe ff ff       	call   801eb7 <alloc_sockfd>
}
  802053:	c9                   	leave  
  802054:	c3                   	ret    
	...

00802060 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  802060:	55                   	push   %ebp
  802061:	89 e5                	mov    %esp,%ebp
  802063:	53                   	push   %ebx
  802064:	83 ec 14             	sub    $0x14,%esp
  802067:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  802069:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  802070:	75 11                	jne    802083 <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  802072:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  802079:	e8 f2 02 00 00       	call   802370 <ipc_find_env>
  80207e:	a3 04 40 80 00       	mov    %eax,0x804004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  802083:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80208a:	00 
  80208b:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  802092:	00 
  802093:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802097:	a1 04 40 80 00       	mov    0x804004,%eax
  80209c:	89 04 24             	mov    %eax,(%esp)
  80209f:	e8 17 03 00 00       	call   8023bb <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  8020a4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8020ab:	00 
  8020ac:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8020b3:	00 
  8020b4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020bb:	e8 79 03 00 00       	call   802439 <ipc_recv>
}
  8020c0:	83 c4 14             	add    $0x14,%esp
  8020c3:	5b                   	pop    %ebx
  8020c4:	5d                   	pop    %ebp
  8020c5:	c3                   	ret    

008020c6 <nsipc_socket>:
	return nsipc(NSREQ_SEND);
}

int
nsipc_socket(int domain, int type, int protocol)
{
  8020c6:	55                   	push   %ebp
  8020c7:	89 e5                	mov    %esp,%ebp
  8020c9:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  8020cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8020cf:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  8020d4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020d7:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  8020dc:	8b 45 10             	mov    0x10(%ebp),%eax
  8020df:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  8020e4:	b8 09 00 00 00       	mov    $0x9,%eax
  8020e9:	e8 72 ff ff ff       	call   802060 <nsipc>
}
  8020ee:	c9                   	leave  
  8020ef:	c3                   	ret    

008020f0 <nsipc_listen>:
	return nsipc(NSREQ_CONNECT);
}

int
nsipc_listen(int s, int backlog)
{
  8020f0:	55                   	push   %ebp
  8020f1:	89 e5                	mov    %esp,%ebp
  8020f3:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  8020f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8020f9:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  8020fe:	8b 45 0c             	mov    0xc(%ebp),%eax
  802101:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  802106:	b8 06 00 00 00       	mov    $0x6,%eax
  80210b:	e8 50 ff ff ff       	call   802060 <nsipc>
}
  802110:	c9                   	leave  
  802111:	c3                   	ret    

00802112 <nsipc_close>:
	return nsipc(NSREQ_SHUTDOWN);
}

int
nsipc_close(int s)
{
  802112:	55                   	push   %ebp
  802113:	89 e5                	mov    %esp,%ebp
  802115:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  802118:	8b 45 08             	mov    0x8(%ebp),%eax
  80211b:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  802120:	b8 04 00 00 00       	mov    $0x4,%eax
  802125:	e8 36 ff ff ff       	call   802060 <nsipc>
}
  80212a:	c9                   	leave  
  80212b:	c3                   	ret    

0080212c <nsipc_shutdown>:
	return nsipc(NSREQ_BIND);
}

int
nsipc_shutdown(int s, int how)
{
  80212c:	55                   	push   %ebp
  80212d:	89 e5                	mov    %esp,%ebp
  80212f:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  802132:	8b 45 08             	mov    0x8(%ebp),%eax
  802135:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  80213a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80213d:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  802142:	b8 03 00 00 00       	mov    $0x3,%eax
  802147:	e8 14 ff ff ff       	call   802060 <nsipc>
}
  80214c:	c9                   	leave  
  80214d:	c3                   	ret    

0080214e <nsipc_send>:
	return r;
}

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  80214e:	55                   	push   %ebp
  80214f:	89 e5                	mov    %esp,%ebp
  802151:	53                   	push   %ebx
  802152:	83 ec 14             	sub    $0x14,%esp
  802155:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  802158:	8b 45 08             	mov    0x8(%ebp),%eax
  80215b:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  802160:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  802166:	7e 24                	jle    80218c <nsipc_send+0x3e>
  802168:	c7 44 24 0c c0 2b 80 	movl   $0x802bc0,0xc(%esp)
  80216f:	00 
  802170:	c7 44 24 08 cc 2b 80 	movl   $0x802bcc,0x8(%esp)
  802177:	00 
  802178:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
  80217f:	00 
  802180:	c7 04 24 e1 2b 80 00 	movl   $0x802be1,(%esp)
  802187:	e8 88 01 00 00       	call   802314 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  80218c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802190:	8b 45 0c             	mov    0xc(%ebp),%eax
  802193:	89 44 24 04          	mov    %eax,0x4(%esp)
  802197:	c7 04 24 0c 60 80 00 	movl   $0x80600c,(%esp)
  80219e:	e8 b2 ea ff ff       	call   800c55 <memmove>
	nsipcbuf.send.req_size = size;
  8021a3:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  8021a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8021ac:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  8021b1:	b8 08 00 00 00       	mov    $0x8,%eax
  8021b6:	e8 a5 fe ff ff       	call   802060 <nsipc>
}
  8021bb:	83 c4 14             	add    $0x14,%esp
  8021be:	5b                   	pop    %ebx
  8021bf:	5d                   	pop    %ebp
  8021c0:	c3                   	ret    

008021c1 <nsipc_recv>:
	return nsipc(NSREQ_LISTEN);
}

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  8021c1:	55                   	push   %ebp
  8021c2:	89 e5                	mov    %esp,%ebp
  8021c4:	56                   	push   %esi
  8021c5:	53                   	push   %ebx
  8021c6:	83 ec 10             	sub    $0x10,%esp
  8021c9:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  8021cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8021cf:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  8021d4:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  8021da:	8b 45 14             	mov    0x14(%ebp),%eax
  8021dd:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  8021e2:	b8 07 00 00 00       	mov    $0x7,%eax
  8021e7:	e8 74 fe ff ff       	call   802060 <nsipc>
  8021ec:	89 c3                	mov    %eax,%ebx
  8021ee:	85 c0                	test   %eax,%eax
  8021f0:	78 46                	js     802238 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  8021f2:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  8021f7:	7f 04                	jg     8021fd <nsipc_recv+0x3c>
  8021f9:	39 c6                	cmp    %eax,%esi
  8021fb:	7d 24                	jge    802221 <nsipc_recv+0x60>
  8021fd:	c7 44 24 0c ed 2b 80 	movl   $0x802bed,0xc(%esp)
  802204:	00 
  802205:	c7 44 24 08 cc 2b 80 	movl   $0x802bcc,0x8(%esp)
  80220c:	00 
  80220d:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
  802214:	00 
  802215:	c7 04 24 e1 2b 80 00 	movl   $0x802be1,(%esp)
  80221c:	e8 f3 00 00 00       	call   802314 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  802221:	89 44 24 08          	mov    %eax,0x8(%esp)
  802225:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  80222c:	00 
  80222d:	8b 45 0c             	mov    0xc(%ebp),%eax
  802230:	89 04 24             	mov    %eax,(%esp)
  802233:	e8 1d ea ff ff       	call   800c55 <memmove>
	}

	return r;
}
  802238:	89 d8                	mov    %ebx,%eax
  80223a:	83 c4 10             	add    $0x10,%esp
  80223d:	5b                   	pop    %ebx
  80223e:	5e                   	pop    %esi
  80223f:	5d                   	pop    %ebp
  802240:	c3                   	ret    

00802241 <nsipc_connect>:
	return nsipc(NSREQ_CLOSE);
}

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  802241:	55                   	push   %ebp
  802242:	89 e5                	mov    %esp,%ebp
  802244:	53                   	push   %ebx
  802245:	83 ec 14             	sub    $0x14,%esp
  802248:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  80224b:	8b 45 08             	mov    0x8(%ebp),%eax
  80224e:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  802253:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802257:	8b 45 0c             	mov    0xc(%ebp),%eax
  80225a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80225e:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  802265:	e8 eb e9 ff ff       	call   800c55 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  80226a:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  802270:	b8 05 00 00 00       	mov    $0x5,%eax
  802275:	e8 e6 fd ff ff       	call   802060 <nsipc>
}
  80227a:	83 c4 14             	add    $0x14,%esp
  80227d:	5b                   	pop    %ebx
  80227e:	5d                   	pop    %ebp
  80227f:	c3                   	ret    

00802280 <nsipc_bind>:
	return r;
}

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802280:	55                   	push   %ebp
  802281:	89 e5                	mov    %esp,%ebp
  802283:	53                   	push   %ebx
  802284:	83 ec 14             	sub    $0x14,%esp
  802287:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  80228a:	8b 45 08             	mov    0x8(%ebp),%eax
  80228d:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  802292:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802296:	8b 45 0c             	mov    0xc(%ebp),%eax
  802299:	89 44 24 04          	mov    %eax,0x4(%esp)
  80229d:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  8022a4:	e8 ac e9 ff ff       	call   800c55 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  8022a9:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  8022af:	b8 02 00 00 00       	mov    $0x2,%eax
  8022b4:	e8 a7 fd ff ff       	call   802060 <nsipc>
}
  8022b9:	83 c4 14             	add    $0x14,%esp
  8022bc:	5b                   	pop    %ebx
  8022bd:	5d                   	pop    %ebp
  8022be:	c3                   	ret    

008022bf <nsipc_accept>:
	return ipc_recv(NULL, NULL, NULL);
}

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8022bf:	55                   	push   %ebp
  8022c0:	89 e5                	mov    %esp,%ebp
  8022c2:	83 ec 18             	sub    $0x18,%esp
  8022c5:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8022c8:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int r;

	nsipcbuf.accept.req_s = s;
  8022cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8022ce:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  8022d3:	b8 01 00 00 00       	mov    $0x1,%eax
  8022d8:	e8 83 fd ff ff       	call   802060 <nsipc>
  8022dd:	89 c3                	mov    %eax,%ebx
  8022df:	85 c0                	test   %eax,%eax
  8022e1:	78 25                	js     802308 <nsipc_accept+0x49>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  8022e3:	be 10 60 80 00       	mov    $0x806010,%esi
  8022e8:	8b 06                	mov    (%esi),%eax
  8022ea:	89 44 24 08          	mov    %eax,0x8(%esp)
  8022ee:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  8022f5:	00 
  8022f6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022f9:	89 04 24             	mov    %eax,(%esp)
  8022fc:	e8 54 e9 ff ff       	call   800c55 <memmove>
		*addrlen = ret->ret_addrlen;
  802301:	8b 16                	mov    (%esi),%edx
  802303:	8b 45 10             	mov    0x10(%ebp),%eax
  802306:	89 10                	mov    %edx,(%eax)
	}
	return r;
}
  802308:	89 d8                	mov    %ebx,%eax
  80230a:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80230d:	8b 75 fc             	mov    -0x4(%ebp),%esi
  802310:	89 ec                	mov    %ebp,%esp
  802312:	5d                   	pop    %ebp
  802313:	c3                   	ret    

00802314 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  802314:	55                   	push   %ebp
  802315:	89 e5                	mov    %esp,%ebp
  802317:	56                   	push   %esi
  802318:	53                   	push   %ebx
  802319:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  80231c:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80231f:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  802325:	e8 5d f1 ff ff       	call   801487 <sys_getenvid>
  80232a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80232d:	89 54 24 10          	mov    %edx,0x10(%esp)
  802331:	8b 55 08             	mov    0x8(%ebp),%edx
  802334:	89 54 24 0c          	mov    %edx,0xc(%esp)
  802338:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80233c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802340:	c7 04 24 04 2c 80 00 	movl   $0x802c04,(%esp)
  802347:	e8 ed dd ff ff       	call   800139 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80234c:	89 74 24 04          	mov    %esi,0x4(%esp)
  802350:	8b 45 10             	mov    0x10(%ebp),%eax
  802353:	89 04 24             	mov    %eax,(%esp)
  802356:	e8 7d dd ff ff       	call   8000d8 <vcprintf>
	cprintf("\n");
  80235b:	c7 04 24 6c 27 80 00 	movl   $0x80276c,(%esp)
  802362:	e8 d2 dd ff ff       	call   800139 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  802367:	cc                   	int3   
  802368:	eb fd                	jmp    802367 <_panic+0x53>
  80236a:	00 00                	add    %al,(%eax)
  80236c:	00 00                	add    %al,(%eax)
	...

00802370 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802370:	55                   	push   %ebp
  802371:	89 e5                	mov    %esp,%ebp
  802373:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  802376:	8b 15 50 00 c0 ee    	mov    0xeec00050,%edx
  80237c:	b8 01 00 00 00       	mov    $0x1,%eax
  802381:	39 ca                	cmp    %ecx,%edx
  802383:	75 04                	jne    802389 <ipc_find_env+0x19>
  802385:	b0 00                	mov    $0x0,%al
  802387:	eb 12                	jmp    80239b <ipc_find_env+0x2b>
  802389:	89 c2                	mov    %eax,%edx
  80238b:	c1 e2 07             	shl    $0x7,%edx
  80238e:	8d 94 82 50 00 c0 ee 	lea    -0x113fffb0(%edx,%eax,4),%edx
  802395:	8b 12                	mov    (%edx),%edx
  802397:	39 ca                	cmp    %ecx,%edx
  802399:	75 10                	jne    8023ab <ipc_find_env+0x3b>
			return envs[i].env_id;
  80239b:	89 c2                	mov    %eax,%edx
  80239d:	c1 e2 07             	shl    $0x7,%edx
  8023a0:	8d 84 82 48 00 c0 ee 	lea    -0x113fffb8(%edx,%eax,4),%eax
  8023a7:	8b 00                	mov    (%eax),%eax
  8023a9:	eb 0e                	jmp    8023b9 <ipc_find_env+0x49>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8023ab:	83 c0 01             	add    $0x1,%eax
  8023ae:	3d 00 04 00 00       	cmp    $0x400,%eax
  8023b3:	75 d4                	jne    802389 <ipc_find_env+0x19>
  8023b5:	66 b8 00 00          	mov    $0x0,%ax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  8023b9:	5d                   	pop    %ebp
  8023ba:	c3                   	ret    

008023bb <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8023bb:	55                   	push   %ebp
  8023bc:	89 e5                	mov    %esp,%ebp
  8023be:	57                   	push   %edi
  8023bf:	56                   	push   %esi
  8023c0:	53                   	push   %ebx
  8023c1:	83 ec 1c             	sub    $0x1c,%esp
  8023c4:	8b 75 08             	mov    0x8(%ebp),%esi
  8023c7:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8023ca:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        int ret;
        while(1){
           if(pg)
  8023cd:	85 db                	test   %ebx,%ebx
  8023cf:	74 19                	je     8023ea <ipc_send+0x2f>
              ret = sys_ipc_try_send(to_env,val,pg,perm);
  8023d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8023d4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8023d8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8023dc:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8023e0:	89 34 24             	mov    %esi,(%esp)
  8023e3:	e8 51 ed ff ff       	call   801139 <sys_ipc_try_send>
  8023e8:	eb 1b                	jmp    802405 <ipc_send+0x4a>
           else
              ret = sys_ipc_try_send(to_env,val,(void*)UTOP,perm);
  8023ea:	8b 45 14             	mov    0x14(%ebp),%eax
  8023ed:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8023f1:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  8023f8:	ee 
  8023f9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8023fd:	89 34 24             	mov    %esi,(%esp)
  802400:	e8 34 ed ff ff       	call   801139 <sys_ipc_try_send>
           if(ret == 0)
  802405:	85 c0                	test   %eax,%eax
  802407:	74 28                	je     802431 <ipc_send+0x76>
              return;
           if(ret != -E_IPC_NOT_RECV)
  802409:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80240c:	74 1c                	je     80242a <ipc_send+0x6f>
              panic("ipc send error");
  80240e:	c7 44 24 08 28 2c 80 	movl   $0x802c28,0x8(%esp)
  802415:	00 
  802416:	c7 44 24 04 46 00 00 	movl   $0x46,0x4(%esp)
  80241d:	00 
  80241e:	c7 04 24 37 2c 80 00 	movl   $0x802c37,(%esp)
  802425:	e8 ea fe ff ff       	call   802314 <_panic>
           sys_yield();
  80242a:	e8 d6 ef ff ff       	call   801405 <sys_yield>
        }
  80242f:	eb 9c                	jmp    8023cd <ipc_send+0x12>
	//panic("ipc_send not implemented");
}
  802431:	83 c4 1c             	add    $0x1c,%esp
  802434:	5b                   	pop    %ebx
  802435:	5e                   	pop    %esi
  802436:	5f                   	pop    %edi
  802437:	5d                   	pop    %ebp
  802438:	c3                   	ret    

00802439 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802439:	55                   	push   %ebp
  80243a:	89 e5                	mov    %esp,%ebp
  80243c:	56                   	push   %esi
  80243d:	53                   	push   %ebx
  80243e:	83 ec 10             	sub    $0x10,%esp
  802441:	8b 75 08             	mov    0x8(%ebp),%esi
  802444:	8b 45 0c             	mov    0xc(%ebp),%eax
  802447:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        int ret;
        if(!pg)
  80244a:	85 c0                	test   %eax,%eax
  80244c:	75 0e                	jne    80245c <ipc_recv+0x23>
           ret = sys_ipc_recv((void*)UTOP);
  80244e:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  802455:	e8 74 ec ff ff       	call   8010ce <sys_ipc_recv>
  80245a:	eb 08                	jmp    802464 <ipc_recv+0x2b>
        else
           ret = sys_ipc_recv(pg);
  80245c:	89 04 24             	mov    %eax,(%esp)
  80245f:	e8 6a ec ff ff       	call   8010ce <sys_ipc_recv>
        if(ret == 0){
  802464:	85 c0                	test   %eax,%eax
  802466:	75 26                	jne    80248e <ipc_recv+0x55>
           if(from_env_store)
  802468:	85 f6                	test   %esi,%esi
  80246a:	74 0a                	je     802476 <ipc_recv+0x3d>
              *from_env_store = thisenv->env_ipc_from;
  80246c:	a1 0c 40 80 00       	mov    0x80400c,%eax
  802471:	8b 40 78             	mov    0x78(%eax),%eax
  802474:	89 06                	mov    %eax,(%esi)
           if(perm_store)
  802476:	85 db                	test   %ebx,%ebx
  802478:	74 0a                	je     802484 <ipc_recv+0x4b>
              *perm_store = thisenv->env_ipc_perm;
  80247a:	a1 0c 40 80 00       	mov    0x80400c,%eax
  80247f:	8b 40 7c             	mov    0x7c(%eax),%eax
  802482:	89 03                	mov    %eax,(%ebx)
           return thisenv->env_ipc_value;
  802484:	a1 0c 40 80 00       	mov    0x80400c,%eax
  802489:	8b 40 74             	mov    0x74(%eax),%eax
  80248c:	eb 14                	jmp    8024a2 <ipc_recv+0x69>
        }
        else{
           if(from_env_store)
  80248e:	85 f6                	test   %esi,%esi
  802490:	74 06                	je     802498 <ipc_recv+0x5f>
              *from_env_store = 0;
  802492:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
           if(perm_store)
  802498:	85 db                	test   %ebx,%ebx
  80249a:	74 06                	je     8024a2 <ipc_recv+0x69>
              *perm_store = 0;
  80249c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
           return ret;
        }
	//panic("ipc_recv not implemented");
	return 0;
}
  8024a2:	83 c4 10             	add    $0x10,%esp
  8024a5:	5b                   	pop    %ebx
  8024a6:	5e                   	pop    %esi
  8024a7:	5d                   	pop    %ebp
  8024a8:	c3                   	ret    
  8024a9:	00 00                	add    %al,(%eax)
	...

008024ac <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8024ac:	55                   	push   %ebp
  8024ad:	89 e5                	mov    %esp,%ebp
	pte_t pte;

	if (!(vpd[PDX(v)] & PTE_P))
  8024af:	8b 45 08             	mov    0x8(%ebp),%eax
  8024b2:	89 c2                	mov    %eax,%edx
  8024b4:	c1 ea 16             	shr    $0x16,%edx
  8024b7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8024be:	f6 c2 01             	test   $0x1,%dl
  8024c1:	74 20                	je     8024e3 <pageref+0x37>
		return 0;
	pte = vpt[PGNUM(v)];
  8024c3:	c1 e8 0c             	shr    $0xc,%eax
  8024c6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8024cd:	a8 01                	test   $0x1,%al
  8024cf:	74 12                	je     8024e3 <pageref+0x37>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8024d1:	c1 e8 0c             	shr    $0xc,%eax
  8024d4:	ba 00 00 00 ef       	mov    $0xef000000,%edx
  8024d9:	0f b7 44 c2 04       	movzwl 0x4(%edx,%eax,8),%eax
  8024de:	0f b7 c0             	movzwl %ax,%eax
  8024e1:	eb 05                	jmp    8024e8 <pageref+0x3c>
  8024e3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8024e8:	5d                   	pop    %ebp
  8024e9:	c3                   	ret    
  8024ea:	00 00                	add    %al,(%eax)
  8024ec:	00 00                	add    %al,(%eax)
	...

008024f0 <__udivdi3>:
  8024f0:	55                   	push   %ebp
  8024f1:	89 e5                	mov    %esp,%ebp
  8024f3:	57                   	push   %edi
  8024f4:	56                   	push   %esi
  8024f5:	83 ec 10             	sub    $0x10,%esp
  8024f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8024fb:	8b 55 08             	mov    0x8(%ebp),%edx
  8024fe:	8b 75 10             	mov    0x10(%ebp),%esi
  802501:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802504:	85 c0                	test   %eax,%eax
  802506:	89 55 f0             	mov    %edx,-0x10(%ebp)
  802509:	75 35                	jne    802540 <__udivdi3+0x50>
  80250b:	39 fe                	cmp    %edi,%esi
  80250d:	77 61                	ja     802570 <__udivdi3+0x80>
  80250f:	85 f6                	test   %esi,%esi
  802511:	75 0b                	jne    80251e <__udivdi3+0x2e>
  802513:	b8 01 00 00 00       	mov    $0x1,%eax
  802518:	31 d2                	xor    %edx,%edx
  80251a:	f7 f6                	div    %esi
  80251c:	89 c6                	mov    %eax,%esi
  80251e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  802521:	31 d2                	xor    %edx,%edx
  802523:	89 f8                	mov    %edi,%eax
  802525:	f7 f6                	div    %esi
  802527:	89 c7                	mov    %eax,%edi
  802529:	89 c8                	mov    %ecx,%eax
  80252b:	f7 f6                	div    %esi
  80252d:	89 c1                	mov    %eax,%ecx
  80252f:	89 fa                	mov    %edi,%edx
  802531:	89 c8                	mov    %ecx,%eax
  802533:	83 c4 10             	add    $0x10,%esp
  802536:	5e                   	pop    %esi
  802537:	5f                   	pop    %edi
  802538:	5d                   	pop    %ebp
  802539:	c3                   	ret    
  80253a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802540:	39 f8                	cmp    %edi,%eax
  802542:	77 1c                	ja     802560 <__udivdi3+0x70>
  802544:	0f bd d0             	bsr    %eax,%edx
  802547:	83 f2 1f             	xor    $0x1f,%edx
  80254a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80254d:	75 39                	jne    802588 <__udivdi3+0x98>
  80254f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  802552:	0f 86 a0 00 00 00    	jbe    8025f8 <__udivdi3+0x108>
  802558:	39 f8                	cmp    %edi,%eax
  80255a:	0f 82 98 00 00 00    	jb     8025f8 <__udivdi3+0x108>
  802560:	31 ff                	xor    %edi,%edi
  802562:	31 c9                	xor    %ecx,%ecx
  802564:	89 c8                	mov    %ecx,%eax
  802566:	89 fa                	mov    %edi,%edx
  802568:	83 c4 10             	add    $0x10,%esp
  80256b:	5e                   	pop    %esi
  80256c:	5f                   	pop    %edi
  80256d:	5d                   	pop    %ebp
  80256e:	c3                   	ret    
  80256f:	90                   	nop
  802570:	89 d1                	mov    %edx,%ecx
  802572:	89 fa                	mov    %edi,%edx
  802574:	89 c8                	mov    %ecx,%eax
  802576:	31 ff                	xor    %edi,%edi
  802578:	f7 f6                	div    %esi
  80257a:	89 c1                	mov    %eax,%ecx
  80257c:	89 fa                	mov    %edi,%edx
  80257e:	89 c8                	mov    %ecx,%eax
  802580:	83 c4 10             	add    $0x10,%esp
  802583:	5e                   	pop    %esi
  802584:	5f                   	pop    %edi
  802585:	5d                   	pop    %ebp
  802586:	c3                   	ret    
  802587:	90                   	nop
  802588:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80258c:	89 f2                	mov    %esi,%edx
  80258e:	d3 e0                	shl    %cl,%eax
  802590:	89 45 ec             	mov    %eax,-0x14(%ebp)
  802593:	b8 20 00 00 00       	mov    $0x20,%eax
  802598:	2b 45 f4             	sub    -0xc(%ebp),%eax
  80259b:	89 c1                	mov    %eax,%ecx
  80259d:	d3 ea                	shr    %cl,%edx
  80259f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8025a3:	0b 55 ec             	or     -0x14(%ebp),%edx
  8025a6:	d3 e6                	shl    %cl,%esi
  8025a8:	89 c1                	mov    %eax,%ecx
  8025aa:	89 75 e8             	mov    %esi,-0x18(%ebp)
  8025ad:	89 fe                	mov    %edi,%esi
  8025af:	d3 ee                	shr    %cl,%esi
  8025b1:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8025b5:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8025b8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8025bb:	d3 e7                	shl    %cl,%edi
  8025bd:	89 c1                	mov    %eax,%ecx
  8025bf:	d3 ea                	shr    %cl,%edx
  8025c1:	09 d7                	or     %edx,%edi
  8025c3:	89 f2                	mov    %esi,%edx
  8025c5:	89 f8                	mov    %edi,%eax
  8025c7:	f7 75 ec             	divl   -0x14(%ebp)
  8025ca:	89 d6                	mov    %edx,%esi
  8025cc:	89 c7                	mov    %eax,%edi
  8025ce:	f7 65 e8             	mull   -0x18(%ebp)
  8025d1:	39 d6                	cmp    %edx,%esi
  8025d3:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8025d6:	72 30                	jb     802608 <__udivdi3+0x118>
  8025d8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8025db:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8025df:	d3 e2                	shl    %cl,%edx
  8025e1:	39 c2                	cmp    %eax,%edx
  8025e3:	73 05                	jae    8025ea <__udivdi3+0xfa>
  8025e5:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  8025e8:	74 1e                	je     802608 <__udivdi3+0x118>
  8025ea:	89 f9                	mov    %edi,%ecx
  8025ec:	31 ff                	xor    %edi,%edi
  8025ee:	e9 71 ff ff ff       	jmp    802564 <__udivdi3+0x74>
  8025f3:	90                   	nop
  8025f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8025f8:	31 ff                	xor    %edi,%edi
  8025fa:	b9 01 00 00 00       	mov    $0x1,%ecx
  8025ff:	e9 60 ff ff ff       	jmp    802564 <__udivdi3+0x74>
  802604:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802608:	8d 4f ff             	lea    -0x1(%edi),%ecx
  80260b:	31 ff                	xor    %edi,%edi
  80260d:	89 c8                	mov    %ecx,%eax
  80260f:	89 fa                	mov    %edi,%edx
  802611:	83 c4 10             	add    $0x10,%esp
  802614:	5e                   	pop    %esi
  802615:	5f                   	pop    %edi
  802616:	5d                   	pop    %ebp
  802617:	c3                   	ret    
	...

00802620 <__umoddi3>:
  802620:	55                   	push   %ebp
  802621:	89 e5                	mov    %esp,%ebp
  802623:	57                   	push   %edi
  802624:	56                   	push   %esi
  802625:	83 ec 20             	sub    $0x20,%esp
  802628:	8b 55 14             	mov    0x14(%ebp),%edx
  80262b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80262e:	8b 7d 10             	mov    0x10(%ebp),%edi
  802631:	8b 75 0c             	mov    0xc(%ebp),%esi
  802634:	85 d2                	test   %edx,%edx
  802636:	89 c8                	mov    %ecx,%eax
  802638:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80263b:	75 13                	jne    802650 <__umoddi3+0x30>
  80263d:	39 f7                	cmp    %esi,%edi
  80263f:	76 3f                	jbe    802680 <__umoddi3+0x60>
  802641:	89 f2                	mov    %esi,%edx
  802643:	f7 f7                	div    %edi
  802645:	89 d0                	mov    %edx,%eax
  802647:	31 d2                	xor    %edx,%edx
  802649:	83 c4 20             	add    $0x20,%esp
  80264c:	5e                   	pop    %esi
  80264d:	5f                   	pop    %edi
  80264e:	5d                   	pop    %ebp
  80264f:	c3                   	ret    
  802650:	39 f2                	cmp    %esi,%edx
  802652:	77 4c                	ja     8026a0 <__umoddi3+0x80>
  802654:	0f bd ca             	bsr    %edx,%ecx
  802657:	83 f1 1f             	xor    $0x1f,%ecx
  80265a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80265d:	75 51                	jne    8026b0 <__umoddi3+0x90>
  80265f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  802662:	0f 87 e0 00 00 00    	ja     802748 <__umoddi3+0x128>
  802668:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80266b:	29 f8                	sub    %edi,%eax
  80266d:	19 d6                	sbb    %edx,%esi
  80266f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  802672:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802675:	89 f2                	mov    %esi,%edx
  802677:	83 c4 20             	add    $0x20,%esp
  80267a:	5e                   	pop    %esi
  80267b:	5f                   	pop    %edi
  80267c:	5d                   	pop    %ebp
  80267d:	c3                   	ret    
  80267e:	66 90                	xchg   %ax,%ax
  802680:	85 ff                	test   %edi,%edi
  802682:	75 0b                	jne    80268f <__umoddi3+0x6f>
  802684:	b8 01 00 00 00       	mov    $0x1,%eax
  802689:	31 d2                	xor    %edx,%edx
  80268b:	f7 f7                	div    %edi
  80268d:	89 c7                	mov    %eax,%edi
  80268f:	89 f0                	mov    %esi,%eax
  802691:	31 d2                	xor    %edx,%edx
  802693:	f7 f7                	div    %edi
  802695:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802698:	f7 f7                	div    %edi
  80269a:	eb a9                	jmp    802645 <__umoddi3+0x25>
  80269c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8026a0:	89 c8                	mov    %ecx,%eax
  8026a2:	89 f2                	mov    %esi,%edx
  8026a4:	83 c4 20             	add    $0x20,%esp
  8026a7:	5e                   	pop    %esi
  8026a8:	5f                   	pop    %edi
  8026a9:	5d                   	pop    %ebp
  8026aa:	c3                   	ret    
  8026ab:	90                   	nop
  8026ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8026b0:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8026b4:	d3 e2                	shl    %cl,%edx
  8026b6:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8026b9:	ba 20 00 00 00       	mov    $0x20,%edx
  8026be:	2b 55 f0             	sub    -0x10(%ebp),%edx
  8026c1:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8026c4:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8026c8:	89 fa                	mov    %edi,%edx
  8026ca:	d3 ea                	shr    %cl,%edx
  8026cc:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8026d0:	0b 55 f4             	or     -0xc(%ebp),%edx
  8026d3:	d3 e7                	shl    %cl,%edi
  8026d5:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8026d9:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8026dc:	89 f2                	mov    %esi,%edx
  8026de:	89 7d e8             	mov    %edi,-0x18(%ebp)
  8026e1:	89 c7                	mov    %eax,%edi
  8026e3:	d3 ea                	shr    %cl,%edx
  8026e5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8026e9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8026ec:	89 c2                	mov    %eax,%edx
  8026ee:	d3 e6                	shl    %cl,%esi
  8026f0:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8026f4:	d3 ea                	shr    %cl,%edx
  8026f6:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8026fa:	09 d6                	or     %edx,%esi
  8026fc:	89 f0                	mov    %esi,%eax
  8026fe:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  802701:	d3 e7                	shl    %cl,%edi
  802703:	89 f2                	mov    %esi,%edx
  802705:	f7 75 f4             	divl   -0xc(%ebp)
  802708:	89 d6                	mov    %edx,%esi
  80270a:	f7 65 e8             	mull   -0x18(%ebp)
  80270d:	39 d6                	cmp    %edx,%esi
  80270f:	72 2b                	jb     80273c <__umoddi3+0x11c>
  802711:	39 c7                	cmp    %eax,%edi
  802713:	72 23                	jb     802738 <__umoddi3+0x118>
  802715:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802719:	29 c7                	sub    %eax,%edi
  80271b:	19 d6                	sbb    %edx,%esi
  80271d:	89 f0                	mov    %esi,%eax
  80271f:	89 f2                	mov    %esi,%edx
  802721:	d3 ef                	shr    %cl,%edi
  802723:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802727:	d3 e0                	shl    %cl,%eax
  802729:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80272d:	09 f8                	or     %edi,%eax
  80272f:	d3 ea                	shr    %cl,%edx
  802731:	83 c4 20             	add    $0x20,%esp
  802734:	5e                   	pop    %esi
  802735:	5f                   	pop    %edi
  802736:	5d                   	pop    %ebp
  802737:	c3                   	ret    
  802738:	39 d6                	cmp    %edx,%esi
  80273a:	75 d9                	jne    802715 <__umoddi3+0xf5>
  80273c:	2b 45 e8             	sub    -0x18(%ebp),%eax
  80273f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  802742:	eb d1                	jmp    802715 <__umoddi3+0xf5>
  802744:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802748:	39 f2                	cmp    %esi,%edx
  80274a:	0f 82 18 ff ff ff    	jb     802668 <__umoddi3+0x48>
  802750:	e9 1d ff ff ff       	jmp    802672 <__umoddi3+0x52>
