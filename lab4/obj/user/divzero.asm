
obj/user/divzero:     file format elf32-i386


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
  80003a:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800041:	00 00 00 
	cprintf("1/0 is %08x!\n", 1/zero);
  800044:	ba 01 00 00 00       	mov    $0x1,%edx
  800049:	b9 00 00 00 00       	mov    $0x0,%ecx
  80004e:	89 d0                	mov    %edx,%eax
  800050:	c1 fa 1f             	sar    $0x1f,%edx
  800053:	f7 f9                	idiv   %ecx
  800055:	89 44 24 04          	mov    %eax,0x4(%esp)
  800059:	c7 04 24 60 16 80 00 	movl   $0x801660,(%esp)
  800060:	e8 cc 00 00 00       	call   800131 <cprintf>
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
  80007a:	e8 46 12 00 00       	call   8012c5 <sys_getenvid>
  80007f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800084:	89 c2                	mov    %eax,%edx
  800086:	c1 e2 07             	shl    $0x7,%edx
  800089:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  800090:	a3 08 20 80 00       	mov    %eax,0x802008
        //cprintf("ENVX sys_get_envid(): %d\n",ENVX(sys_getenvid()));
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800095:	85 f6                	test   %esi,%esi
  800097:	7e 07                	jle    8000a0 <libmain+0x38>
		binaryname = argv[0];
  800099:	8b 03                	mov    (%ebx),%eax
  80009b:	a3 00 20 80 00       	mov    %eax,0x802000

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
	sys_env_destroy(0);
  8000c2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000c9:	e8 37 12 00 00       	call   801305 <sys_env_destroy>
}
  8000ce:	c9                   	leave  
  8000cf:	c3                   	ret    

008000d0 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  8000d0:	55                   	push   %ebp
  8000d1:	89 e5                	mov    %esp,%ebp
  8000d3:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8000d9:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8000e0:	00 00 00 
	b.cnt = 0;
  8000e3:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8000ea:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8000ed:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000f0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8000f7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8000fb:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800101:	89 44 24 04          	mov    %eax,0x4(%esp)
  800105:	c7 04 24 4b 01 80 00 	movl   $0x80014b,(%esp)
  80010c:	e8 cb 01 00 00       	call   8002dc <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800111:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800117:	89 44 24 04          	mov    %eax,0x4(%esp)
  80011b:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800121:	89 04 24             	mov    %eax,(%esp)
  800124:	e8 63 0d 00 00       	call   800e8c <sys_cputs>

	return b.cnt;
}
  800129:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80012f:	c9                   	leave  
  800130:	c3                   	ret    

00800131 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800131:	55                   	push   %ebp
  800132:	89 e5                	mov    %esp,%ebp
  800134:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  800137:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  80013a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80013e:	8b 45 08             	mov    0x8(%ebp),%eax
  800141:	89 04 24             	mov    %eax,(%esp)
  800144:	e8 87 ff ff ff       	call   8000d0 <vcprintf>
	va_end(ap);

	return cnt;
}
  800149:	c9                   	leave  
  80014a:	c3                   	ret    

0080014b <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80014b:	55                   	push   %ebp
  80014c:	89 e5                	mov    %esp,%ebp
  80014e:	53                   	push   %ebx
  80014f:	83 ec 14             	sub    $0x14,%esp
  800152:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800155:	8b 03                	mov    (%ebx),%eax
  800157:	8b 55 08             	mov    0x8(%ebp),%edx
  80015a:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80015e:	83 c0 01             	add    $0x1,%eax
  800161:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800163:	3d ff 00 00 00       	cmp    $0xff,%eax
  800168:	75 19                	jne    800183 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80016a:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800171:	00 
  800172:	8d 43 08             	lea    0x8(%ebx),%eax
  800175:	89 04 24             	mov    %eax,(%esp)
  800178:	e8 0f 0d 00 00       	call   800e8c <sys_cputs>
		b->idx = 0;
  80017d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800183:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800187:	83 c4 14             	add    $0x14,%esp
  80018a:	5b                   	pop    %ebx
  80018b:	5d                   	pop    %ebp
  80018c:	c3                   	ret    
  80018d:	00 00                	add    %al,(%eax)
	...

00800190 <printnum_v2>:
 */

static void 
printnum_v2(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800190:	55                   	push   %ebp
  800191:	89 e5                	mov    %esp,%ebp
  800193:	57                   	push   %edi
  800194:	56                   	push   %esi
  800195:	53                   	push   %ebx
  800196:	83 ec 4c             	sub    $0x4c,%esp
  800199:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80019c:	89 d6                	mov    %edx,%esi
  80019e:	8b 45 08             	mov    0x8(%ebp),%eax
  8001a1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001a4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001a7:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8001aa:	8b 45 10             	mov    0x10(%ebp),%eax
  8001ad:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8001b0:	8b 7d 18             	mov    0x18(%ebp),%edi
    if (num >= base) {
  8001b3:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8001b6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001bb:	39 d1                	cmp    %edx,%ecx
  8001bd:	72 07                	jb     8001c6 <printnum_v2+0x36>
  8001bf:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8001c2:	39 d0                	cmp    %edx,%eax
  8001c4:	77 5f                	ja     800225 <printnum_v2+0x95>
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
  8001c6:	89 7c 24 10          	mov    %edi,0x10(%esp)
  8001ca:	83 eb 01             	sub    $0x1,%ebx
  8001cd:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8001d1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001d5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8001d9:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  8001dd:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8001e0:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  8001e3:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8001e6:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001ea:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001f1:	00 
  8001f2:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8001f5:	89 04 24             	mov    %eax,(%esp)
  8001f8:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8001fb:	89 54 24 04          	mov    %edx,0x4(%esp)
  8001ff:	e8 dc 11 00 00       	call   8013e0 <__udivdi3>
  800204:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800207:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  80020a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80020e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800212:	89 04 24             	mov    %eax,(%esp)
  800215:	89 54 24 04          	mov    %edx,0x4(%esp)
  800219:	89 f2                	mov    %esi,%edx
  80021b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80021e:	e8 6d ff ff ff       	call   800190 <printnum_v2>
  800223:	eb 1e                	jmp    800243 <printnum_v2+0xb3>
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
  800225:	83 ff 2d             	cmp    $0x2d,%edi
  800228:	74 19                	je     800243 <printnum_v2+0xb3>
		while (--width > 0)
  80022a:	83 eb 01             	sub    $0x1,%ebx
  80022d:	85 db                	test   %ebx,%ebx
  80022f:	90                   	nop
  800230:	7e 11                	jle    800243 <printnum_v2+0xb3>
			putch(padc, putdat);
  800232:	89 74 24 04          	mov    %esi,0x4(%esp)
  800236:	89 3c 24             	mov    %edi,(%esp)
  800239:	ff 55 e4             	call   *-0x1c(%ebp)
    if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
		while (--width > 0)
  80023c:	83 eb 01             	sub    $0x1,%ebx
  80023f:	85 db                	test   %ebx,%ebx
  800241:	7f ef                	jg     800232 <printnum_v2+0xa2>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800243:	89 74 24 04          	mov    %esi,0x4(%esp)
  800247:	8b 74 24 04          	mov    0x4(%esp),%esi
  80024b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80024e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800252:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800259:	00 
  80025a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80025d:	89 14 24             	mov    %edx,(%esp)
  800260:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800263:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800267:	e8 a4 12 00 00       	call   801510 <__umoddi3>
  80026c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800270:	0f be 80 78 16 80 00 	movsbl 0x801678(%eax),%eax
  800277:	89 04 24             	mov    %eax,(%esp)
  80027a:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80027d:	83 c4 4c             	add    $0x4c,%esp
  800280:	5b                   	pop    %ebx
  800281:	5e                   	pop    %esi
  800282:	5f                   	pop    %edi
  800283:	5d                   	pop    %ebp
  800284:	c3                   	ret    

00800285 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800285:	55                   	push   %ebp
  800286:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800288:	83 fa 01             	cmp    $0x1,%edx
  80028b:	7e 0e                	jle    80029b <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80028d:	8b 10                	mov    (%eax),%edx
  80028f:	8d 4a 08             	lea    0x8(%edx),%ecx
  800292:	89 08                	mov    %ecx,(%eax)
  800294:	8b 02                	mov    (%edx),%eax
  800296:	8b 52 04             	mov    0x4(%edx),%edx
  800299:	eb 22                	jmp    8002bd <getuint+0x38>
	else if (lflag)
  80029b:	85 d2                	test   %edx,%edx
  80029d:	74 10                	je     8002af <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80029f:	8b 10                	mov    (%eax),%edx
  8002a1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002a4:	89 08                	mov    %ecx,(%eax)
  8002a6:	8b 02                	mov    (%edx),%eax
  8002a8:	ba 00 00 00 00       	mov    $0x0,%edx
  8002ad:	eb 0e                	jmp    8002bd <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002af:	8b 10                	mov    (%eax),%edx
  8002b1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002b4:	89 08                	mov    %ecx,(%eax)
  8002b6:	8b 02                	mov    (%edx),%eax
  8002b8:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002bd:	5d                   	pop    %ebp
  8002be:	c3                   	ret    

008002bf <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002bf:	55                   	push   %ebp
  8002c0:	89 e5                	mov    %esp,%ebp
  8002c2:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002c5:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002c9:	8b 10                	mov    (%eax),%edx
  8002cb:	3b 50 04             	cmp    0x4(%eax),%edx
  8002ce:	73 0a                	jae    8002da <sprintputch+0x1b>
		*b->buf++ = ch;
  8002d0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002d3:	88 0a                	mov    %cl,(%edx)
  8002d5:	83 c2 01             	add    $0x1,%edx
  8002d8:	89 10                	mov    %edx,(%eax)
}
  8002da:	5d                   	pop    %ebp
  8002db:	c3                   	ret    

008002dc <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002dc:	55                   	push   %ebp
  8002dd:	89 e5                	mov    %esp,%ebp
  8002df:	57                   	push   %edi
  8002e0:	56                   	push   %esi
  8002e1:	53                   	push   %ebx
  8002e2:	83 ec 6c             	sub    $0x6c,%esp
  8002e5:	8b 7d 10             	mov    0x10(%ebp),%edi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8002e8:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  8002ef:	eb 1a                	jmp    80030b <vprintfmt+0x2f>
	int base, lflag, width, precision, altflag,signflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002f1:	85 c0                	test   %eax,%eax
  8002f3:	0f 84 66 06 00 00    	je     80095f <vprintfmt+0x683>
				return;
			putch(ch, putdat);
  8002f9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002fc:	89 54 24 04          	mov    %edx,0x4(%esp)
  800300:	89 04 24             	mov    %eax,(%esp)
  800303:	ff 55 08             	call   *0x8(%ebp)
  800306:	eb 03                	jmp    80030b <vprintfmt+0x2f>
  800308:	8b 7d e4             	mov    -0x1c(%ebp),%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag,signflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80030b:	0f b6 07             	movzbl (%edi),%eax
  80030e:	83 c7 01             	add    $0x1,%edi
  800311:	83 f8 25             	cmp    $0x25,%eax
  800314:	75 db                	jne    8002f1 <vprintfmt+0x15>
  800316:	c6 45 cc 20          	movb   $0x20,-0x34(%ebp)
  80031a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80031f:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  800326:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
  80032b:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800332:	be 00 00 00 00       	mov    $0x0,%esi
  800337:	eb 06                	jmp    80033f <vprintfmt+0x63>
  800339:	c6 45 cc 2d          	movb   $0x2d,-0x34(%ebp)
  80033d:	89 c7                	mov    %eax,%edi
		precision = -1;
		lflag = 0;
		altflag = 0;
                signflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80033f:	0f b6 17             	movzbl (%edi),%edx
  800342:	0f b6 c2             	movzbl %dl,%eax
  800345:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800348:	8d 47 01             	lea    0x1(%edi),%eax
  80034b:	83 ea 23             	sub    $0x23,%edx
  80034e:	80 fa 55             	cmp    $0x55,%dl
  800351:	0f 87 60 05 00 00    	ja     8008b7 <vprintfmt+0x5db>
  800357:	0f b6 d2             	movzbl %dl,%edx
  80035a:	ff 24 95 c0 17 80 00 	jmp    *0x8017c0(,%edx,4)
  800361:	b9 01 00 00 00       	mov    $0x1,%ecx
  800366:	eb d5                	jmp    80033d <vprintfmt+0x61>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800368:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80036b:	83 eb 30             	sub    $0x30,%ebx
				ch = *fmt;
  80036e:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  800371:	8d 7a d0             	lea    -0x30(%edx),%edi
  800374:	83 ff 09             	cmp    $0x9,%edi
  800377:	76 08                	jbe    800381 <vprintfmt+0xa5>
  800379:	eb 40                	jmp    8003bb <vprintfmt+0xdf>
  80037b:	c6 45 cc 30          	movb   $0x30,-0x34(%ebp)
                        signflag = 1;
                        goto reswitch;
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
			goto reswitch;
  80037f:	eb bc                	jmp    80033d <vprintfmt+0x61>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800381:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  800384:	8d 1c 9b             	lea    (%ebx,%ebx,4),%ebx
  800387:	8d 5c 5a d0          	lea    -0x30(%edx,%ebx,2),%ebx
				ch = *fmt;
  80038b:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  80038e:	8d 7a d0             	lea    -0x30(%edx),%edi
  800391:	83 ff 09             	cmp    $0x9,%edi
  800394:	76 eb                	jbe    800381 <vprintfmt+0xa5>
  800396:	eb 23                	jmp    8003bb <vprintfmt+0xdf>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800398:	8b 55 14             	mov    0x14(%ebp),%edx
  80039b:	8d 5a 04             	lea    0x4(%edx),%ebx
  80039e:	89 5d 14             	mov    %ebx,0x14(%ebp)
  8003a1:	8b 1a                	mov    (%edx),%ebx
			goto process_precision;
  8003a3:	eb 16                	jmp    8003bb <vprintfmt+0xdf>

		case '.':
			if (width < 0)
  8003a5:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8003a8:	c1 fa 1f             	sar    $0x1f,%edx
  8003ab:	f7 d2                	not    %edx
  8003ad:	21 55 d8             	and    %edx,-0x28(%ebp)
  8003b0:	eb 8b                	jmp    80033d <vprintfmt+0x61>
  8003b2:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  8003b9:	eb 82                	jmp    80033d <vprintfmt+0x61>

		process_precision:
			if (width < 0)
  8003bb:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8003bf:	0f 89 78 ff ff ff    	jns    80033d <vprintfmt+0x61>
  8003c5:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8003c8:	8b 5d c8             	mov    -0x38(%ebp),%ebx
  8003cb:	e9 6d ff ff ff       	jmp    80033d <vprintfmt+0x61>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003d0:	83 c6 01             	add    $0x1,%esi
			goto reswitch;
  8003d3:	e9 65 ff ff ff       	jmp    80033d <vprintfmt+0x61>
  8003d8:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003db:	8b 45 14             	mov    0x14(%ebp),%eax
  8003de:	8d 50 04             	lea    0x4(%eax),%edx
  8003e1:	89 55 14             	mov    %edx,0x14(%ebp)
  8003e4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003e7:	89 54 24 04          	mov    %edx,0x4(%esp)
  8003eb:	8b 00                	mov    (%eax),%eax
  8003ed:	89 04 24             	mov    %eax,(%esp)
  8003f0:	ff 55 08             	call   *0x8(%ebp)
  8003f3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;
  8003f6:	e9 10 ff ff ff       	jmp    80030b <vprintfmt+0x2f>
  8003fb:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003fe:	8b 45 14             	mov    0x14(%ebp),%eax
  800401:	8d 50 04             	lea    0x4(%eax),%edx
  800404:	89 55 14             	mov    %edx,0x14(%ebp)
  800407:	8b 00                	mov    (%eax),%eax
  800409:	89 c2                	mov    %eax,%edx
  80040b:	c1 fa 1f             	sar    $0x1f,%edx
  80040e:	31 d0                	xor    %edx,%eax
  800410:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800412:	83 f8 08             	cmp    $0x8,%eax
  800415:	7f 0b                	jg     800422 <vprintfmt+0x146>
  800417:	8b 14 85 20 19 80 00 	mov    0x801920(,%eax,4),%edx
  80041e:	85 d2                	test   %edx,%edx
  800420:	75 26                	jne    800448 <vprintfmt+0x16c>
				printfmt(putch, putdat, "error %d", err);
  800422:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800426:	c7 44 24 08 89 16 80 	movl   $0x801689,0x8(%esp)
  80042d:	00 
  80042e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800431:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800435:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800438:	89 1c 24             	mov    %ebx,(%esp)
  80043b:	e8 a7 05 00 00       	call   8009e7 <printfmt>
  800440:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800443:	e9 c3 fe ff ff       	jmp    80030b <vprintfmt+0x2f>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800448:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80044c:	c7 44 24 08 92 16 80 	movl   $0x801692,0x8(%esp)
  800453:	00 
  800454:	8b 45 0c             	mov    0xc(%ebp),%eax
  800457:	89 44 24 04          	mov    %eax,0x4(%esp)
  80045b:	8b 55 08             	mov    0x8(%ebp),%edx
  80045e:	89 14 24             	mov    %edx,(%esp)
  800461:	e8 81 05 00 00       	call   8009e7 <printfmt>
  800466:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800469:	e9 9d fe ff ff       	jmp    80030b <vprintfmt+0x2f>
  80046e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800471:	89 c7                	mov    %eax,%edi
  800473:	89 d9                	mov    %ebx,%ecx
  800475:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800478:	89 45 c0             	mov    %eax,-0x40(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80047b:	8b 45 14             	mov    0x14(%ebp),%eax
  80047e:	8d 50 04             	lea    0x4(%eax),%edx
  800481:	89 55 14             	mov    %edx,0x14(%ebp)
  800484:	8b 30                	mov    (%eax),%esi
  800486:	85 f6                	test   %esi,%esi
  800488:	75 05                	jne    80048f <vprintfmt+0x1b3>
  80048a:	be 95 16 80 00       	mov    $0x801695,%esi
				p = "(null)";
			if (width > 0 && padc != '-')
  80048f:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
  800493:	7e 06                	jle    80049b <vprintfmt+0x1bf>
  800495:	80 7d cc 2d          	cmpb   $0x2d,-0x34(%ebp)
  800499:	75 10                	jne    8004ab <vprintfmt+0x1cf>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80049b:	0f be 06             	movsbl (%esi),%eax
  80049e:	85 c0                	test   %eax,%eax
  8004a0:	0f 85 a2 00 00 00    	jne    800548 <vprintfmt+0x26c>
  8004a6:	e9 92 00 00 00       	jmp    80053d <vprintfmt+0x261>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ab:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8004af:	89 34 24             	mov    %esi,(%esp)
  8004b2:	e8 74 05 00 00       	call   800a2b <strnlen>
  8004b7:	8b 55 c0             	mov    -0x40(%ebp),%edx
  8004ba:	29 c2                	sub    %eax,%edx
  8004bc:	89 55 d8             	mov    %edx,-0x28(%ebp)
  8004bf:	85 d2                	test   %edx,%edx
  8004c1:	7e d8                	jle    80049b <vprintfmt+0x1bf>
					putch(padc, putdat);
  8004c3:	0f be 4d cc          	movsbl -0x34(%ebp),%ecx
  8004c7:	89 5d c0             	mov    %ebx,-0x40(%ebp)
  8004ca:	89 d3                	mov    %edx,%ebx
  8004cc:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8004cf:	89 7d bc             	mov    %edi,-0x44(%ebp)
  8004d2:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8004d5:	89 ce                	mov    %ecx,%esi
  8004d7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004db:	89 34 24             	mov    %esi,(%esp)
  8004de:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004e1:	83 eb 01             	sub    $0x1,%ebx
  8004e4:	85 db                	test   %ebx,%ebx
  8004e6:	7f ef                	jg     8004d7 <vprintfmt+0x1fb>
  8004e8:	8b 5d c0             	mov    -0x40(%ebp),%ebx
  8004eb:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8004ee:	8b 7d bc             	mov    -0x44(%ebp),%edi
  8004f1:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8004f8:	eb a1                	jmp    80049b <vprintfmt+0x1bf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004fa:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  8004fe:	74 1b                	je     80051b <vprintfmt+0x23f>
  800500:	8d 50 e0             	lea    -0x20(%eax),%edx
  800503:	83 fa 5e             	cmp    $0x5e,%edx
  800506:	76 13                	jbe    80051b <vprintfmt+0x23f>
					putch('?', putdat);
  800508:	8b 45 0c             	mov    0xc(%ebp),%eax
  80050b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80050f:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800516:	ff 55 08             	call   *0x8(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800519:	eb 0d                	jmp    800528 <vprintfmt+0x24c>
					putch('?', putdat);
				else
					putch(ch, putdat);
  80051b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80051e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800522:	89 04 24             	mov    %eax,(%esp)
  800525:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800528:	83 ef 01             	sub    $0x1,%edi
  80052b:	0f be 06             	movsbl (%esi),%eax
  80052e:	85 c0                	test   %eax,%eax
  800530:	74 05                	je     800537 <vprintfmt+0x25b>
  800532:	83 c6 01             	add    $0x1,%esi
  800535:	eb 1a                	jmp    800551 <vprintfmt+0x275>
  800537:	89 7d d8             	mov    %edi,-0x28(%ebp)
  80053a:	8b 7d cc             	mov    -0x34(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80053d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800541:	7f 1f                	jg     800562 <vprintfmt+0x286>
  800543:	e9 c0 fd ff ff       	jmp    800308 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800548:	83 c6 01             	add    $0x1,%esi
  80054b:	89 7d cc             	mov    %edi,-0x34(%ebp)
  80054e:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800551:	85 db                	test   %ebx,%ebx
  800553:	78 a5                	js     8004fa <vprintfmt+0x21e>
  800555:	83 eb 01             	sub    $0x1,%ebx
  800558:	79 a0                	jns    8004fa <vprintfmt+0x21e>
  80055a:	89 7d d8             	mov    %edi,-0x28(%ebp)
  80055d:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800560:	eb db                	jmp    80053d <vprintfmt+0x261>
  800562:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800565:	8b 75 0c             	mov    0xc(%ebp),%esi
  800568:	89 7d d8             	mov    %edi,-0x28(%ebp)
  80056b:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80056e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800572:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800579:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80057b:	83 eb 01             	sub    $0x1,%ebx
  80057e:	85 db                	test   %ebx,%ebx
  800580:	7f ec                	jg     80056e <vprintfmt+0x292>
  800582:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800585:	e9 81 fd ff ff       	jmp    80030b <vprintfmt+0x2f>
  80058a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80058d:	83 fe 01             	cmp    $0x1,%esi
  800590:	7e 10                	jle    8005a2 <vprintfmt+0x2c6>
		return va_arg(*ap, long long);
  800592:	8b 45 14             	mov    0x14(%ebp),%eax
  800595:	8d 50 08             	lea    0x8(%eax),%edx
  800598:	89 55 14             	mov    %edx,0x14(%ebp)
  80059b:	8b 18                	mov    (%eax),%ebx
  80059d:	8b 70 04             	mov    0x4(%eax),%esi
  8005a0:	eb 26                	jmp    8005c8 <vprintfmt+0x2ec>
	else if (lflag)
  8005a2:	85 f6                	test   %esi,%esi
  8005a4:	74 12                	je     8005b8 <vprintfmt+0x2dc>
		return va_arg(*ap, long);
  8005a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a9:	8d 50 04             	lea    0x4(%eax),%edx
  8005ac:	89 55 14             	mov    %edx,0x14(%ebp)
  8005af:	8b 18                	mov    (%eax),%ebx
  8005b1:	89 de                	mov    %ebx,%esi
  8005b3:	c1 fe 1f             	sar    $0x1f,%esi
  8005b6:	eb 10                	jmp    8005c8 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  8005b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005bb:	8d 50 04             	lea    0x4(%eax),%edx
  8005be:	89 55 14             	mov    %edx,0x14(%ebp)
  8005c1:	8b 18                	mov    (%eax),%ebx
  8005c3:	89 de                	mov    %ebx,%esi
  8005c5:	c1 fe 1f             	sar    $0x1f,%esi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
                        if(signflag == 1){
  8005c8:	83 f9 01             	cmp    $0x1,%ecx
  8005cb:	75 1e                	jne    8005eb <vprintfmt+0x30f>
                               if((long long)num > 0){
  8005cd:	85 f6                	test   %esi,%esi
  8005cf:	78 1a                	js     8005eb <vprintfmt+0x30f>
  8005d1:	85 f6                	test   %esi,%esi
  8005d3:	7f 05                	jg     8005da <vprintfmt+0x2fe>
  8005d5:	83 fb 00             	cmp    $0x0,%ebx
  8005d8:	76 11                	jbe    8005eb <vprintfmt+0x30f>
                                   putch('+',putdat);
  8005da:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8005dd:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8005e1:	c7 04 24 2b 00 00 00 	movl   $0x2b,(%esp)
  8005e8:	ff 55 08             	call   *0x8(%ebp)
                               }
                        }
			if ((long long) num < 0) {
  8005eb:	85 f6                	test   %esi,%esi
  8005ed:	78 13                	js     800602 <vprintfmt+0x326>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005ef:	89 5d b0             	mov    %ebx,-0x50(%ebp)
  8005f2:	89 75 b4             	mov    %esi,-0x4c(%ebp)
  8005f5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005f8:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005fd:	e9 da 00 00 00       	jmp    8006dc <vprintfmt+0x400>
                               if((long long)num > 0){
                                   putch('+',putdat);
                               }
                        }
			if ((long long) num < 0) {
				putch('-', putdat);
  800602:	8b 45 0c             	mov    0xc(%ebp),%eax
  800605:	89 44 24 04          	mov    %eax,0x4(%esp)
  800609:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800610:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800613:	89 da                	mov    %ebx,%edx
  800615:	89 f1                	mov    %esi,%ecx
  800617:	f7 da                	neg    %edx
  800619:	83 d1 00             	adc    $0x0,%ecx
  80061c:	f7 d9                	neg    %ecx
  80061e:	89 55 b0             	mov    %edx,-0x50(%ebp)
  800621:	89 4d b4             	mov    %ecx,-0x4c(%ebp)
  800624:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800627:	b8 0a 00 00 00       	mov    $0xa,%eax
  80062c:	e9 ab 00 00 00       	jmp    8006dc <vprintfmt+0x400>
  800631:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800634:	89 f2                	mov    %esi,%edx
  800636:	8d 45 14             	lea    0x14(%ebp),%eax
  800639:	e8 47 fc ff ff       	call   800285 <getuint>
  80063e:	89 45 b0             	mov    %eax,-0x50(%ebp)
  800641:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  800644:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800647:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
  80064c:	e9 8b 00 00 00       	jmp    8006dc <vprintfmt+0x400>
  800651:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			putch('0', putdat);
  800654:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800657:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80065b:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800662:	ff 55 08             	call   *0x8(%ebp)
			num = getuint(&ap,lflag);
  800665:	89 f2                	mov    %esi,%edx
  800667:	8d 45 14             	lea    0x14(%ebp),%eax
  80066a:	e8 16 fc ff ff       	call   800285 <getuint>
  80066f:	89 45 b0             	mov    %eax,-0x50(%ebp)
  800672:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  800675:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800678:	b8 08 00 00 00       	mov    $0x8,%eax
                        base = 8;
			goto number;
  80067d:	eb 5d                	jmp    8006dc <vprintfmt+0x400>
  80067f:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
  800682:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800685:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800689:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800690:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800693:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800697:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80069e:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  8006a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a4:	8d 50 04             	lea    0x4(%eax),%edx
  8006a7:	89 55 14             	mov    %edx,0x14(%ebp)
  8006aa:	8b 10                	mov    (%eax),%edx
  8006ac:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006b1:	89 55 b0             	mov    %edx,-0x50(%ebp)
  8006b4:	89 4d b4             	mov    %ecx,-0x4c(%ebp)
  8006b7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006ba:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006bf:	eb 1b                	jmp    8006dc <vprintfmt+0x400>
  8006c1:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006c4:	89 f2                	mov    %esi,%edx
  8006c6:	8d 45 14             	lea    0x14(%ebp),%eax
  8006c9:	e8 b7 fb ff ff       	call   800285 <getuint>
  8006ce:	89 45 b0             	mov    %eax,-0x50(%ebp)
  8006d1:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  8006d4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006d7:	b8 10 00 00 00       	mov    $0x10,%eax
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006dc:	0f be 4d cc          	movsbl -0x34(%ebp),%ecx
  8006e0:	89 4d d0             	mov    %ecx,-0x30(%ebp)
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8006e3:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8006e6:	83 7d b4 00          	cmpl   $0x0,-0x4c(%ebp)
  8006ea:	77 09                	ja     8006f5 <vprintfmt+0x419>
  8006ec:	39 45 b0             	cmp    %eax,-0x50(%ebp)
  8006ef:	0f 82 ac 00 00 00    	jb     8007a1 <vprintfmt+0x4c5>
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
  8006f5:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8006f8:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  8006fc:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8006ff:	83 ea 01             	sub    $0x1,%edx
  800702:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800706:	89 44 24 08          	mov    %eax,0x8(%esp)
  80070a:	8b 44 24 08          	mov    0x8(%esp),%eax
  80070e:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800712:	89 45 c0             	mov    %eax,-0x40(%ebp)
  800715:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  800718:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80071b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80071f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800726:	00 
  800727:	8b 4d b0             	mov    -0x50(%ebp),%ecx
  80072a:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
  80072d:	89 0c 24             	mov    %ecx,(%esp)
  800730:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800734:	e8 a7 0c 00 00       	call   8013e0 <__udivdi3>
  800739:	8b 4d c0             	mov    -0x40(%ebp),%ecx
  80073c:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  80073f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800743:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800747:	89 04 24             	mov    %eax,(%esp)
  80074a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80074e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800751:	8b 45 08             	mov    0x8(%ebp),%eax
  800754:	e8 37 fa ff ff       	call   800190 <printnum_v2>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800759:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80075c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800760:	8b 74 24 04          	mov    0x4(%esp),%esi
  800764:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800767:	89 44 24 08          	mov    %eax,0x8(%esp)
  80076b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800772:	00 
  800773:	8b 55 b0             	mov    -0x50(%ebp),%edx
  800776:	8b 4d b4             	mov    -0x4c(%ebp),%ecx
  800779:	89 14 24             	mov    %edx,(%esp)
  80077c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800780:	e8 8b 0d 00 00       	call   801510 <__umoddi3>
  800785:	89 74 24 04          	mov    %esi,0x4(%esp)
  800789:	0f be 80 78 16 80 00 	movsbl 0x801678(%eax),%eax
  800790:	89 04 24             	mov    %eax,(%esp)
  800793:	ff 55 08             	call   *0x8(%ebp)
        if(padc == '-'){
  800796:	83 7d d0 2d          	cmpl   $0x2d,-0x30(%ebp)
  80079a:	74 54                	je     8007f0 <vprintfmt+0x514>
  80079c:	e9 67 fb ff ff       	jmp    800308 <vprintfmt+0x2c>
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
  8007a1:	83 7d d0 2d          	cmpl   $0x2d,-0x30(%ebp)
  8007a5:	8d 76 00             	lea    0x0(%esi),%esi
  8007a8:	0f 84 2a 01 00 00    	je     8008d8 <vprintfmt+0x5fc>
		while (--width > 0)
  8007ae:	8b 7d d8             	mov    -0x28(%ebp),%edi
  8007b1:	83 ef 01             	sub    $0x1,%edi
  8007b4:	85 ff                	test   %edi,%edi
  8007b6:	0f 8e 5e 01 00 00    	jle    80091a <vprintfmt+0x63e>
  8007bc:	8b 4d b0             	mov    -0x50(%ebp),%ecx
  8007bf:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
  8007c2:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  8007c5:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  8007c8:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8007cb:	8b 75 0c             	mov    0xc(%ebp),%esi
			putch(padc, putdat);
  8007ce:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007d2:	89 1c 24             	mov    %ebx,(%esp)
  8007d5:	ff 55 08             	call   *0x8(%ebp)
	if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
		while (--width > 0)
  8007d8:	83 ef 01             	sub    $0x1,%edi
  8007db:	85 ff                	test   %edi,%edi
  8007dd:	7f ef                	jg     8007ce <vprintfmt+0x4f2>
  8007df:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8007e2:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8007e5:	89 45 b0             	mov    %eax,-0x50(%ebp)
  8007e8:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  8007eb:	e9 2a 01 00 00       	jmp    80091a <vprintfmt+0x63e>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
        if(padc == '-'){
           while (--width > 0)
  8007f0:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  8007f3:	83 eb 01             	sub    $0x1,%ebx
  8007f6:	85 db                	test   %ebx,%ebx
  8007f8:	0f 8e 0a fb ff ff    	jle    800308 <vprintfmt+0x2c>
  8007fe:	8b 75 0c             	mov    0xc(%ebp),%esi
  800801:	89 7d d8             	mov    %edi,-0x28(%ebp)
  800804:	8b 7d 08             	mov    0x8(%ebp),%edi
			putch(' ', putdat);
  800807:	89 74 24 04          	mov    %esi,0x4(%esp)
  80080b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800812:	ff d7                	call   *%edi
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
        if(padc == '-'){
           while (--width > 0)
  800814:	83 eb 01             	sub    $0x1,%ebx
  800817:	85 db                	test   %ebx,%ebx
  800819:	7f ec                	jg     800807 <vprintfmt+0x52b>
  80081b:	8b 7d d8             	mov    -0x28(%ebp),%edi
  80081e:	e9 e8 fa ff ff       	jmp    80030b <vprintfmt+0x2f>
  800823:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
            char* n;
            if ((n = va_arg(ap, char *)) == NULL)
  800826:	8b 45 14             	mov    0x14(%ebp),%eax
  800829:	8d 50 04             	lea    0x4(%eax),%edx
  80082c:	89 55 14             	mov    %edx,0x14(%ebp)
  80082f:	8b 00                	mov    (%eax),%eax
  800831:	85 c0                	test   %eax,%eax
  800833:	75 2a                	jne    80085f <vprintfmt+0x583>
		  printfmt(putch,putdat,"%s",null_error);
  800835:	c7 44 24 0c 30 17 80 	movl   $0x801730,0xc(%esp)
  80083c:	00 
  80083d:	c7 44 24 08 92 16 80 	movl   $0x801692,0x8(%esp)
  800844:	00 
  800845:	8b 55 0c             	mov    0xc(%ebp),%edx
  800848:	89 54 24 04          	mov    %edx,0x4(%esp)
  80084c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80084f:	89 0c 24             	mov    %ecx,(%esp)
  800852:	e8 90 01 00 00       	call   8009e7 <printfmt>
  800857:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80085a:	e9 ac fa ff ff       	jmp    80030b <vprintfmt+0x2f>
            else if((*(int*)putdat) > 127){
  80085f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800862:	8b 13                	mov    (%ebx),%edx
  800864:	83 fa 7f             	cmp    $0x7f,%edx
  800867:	7e 29                	jle    800892 <vprintfmt+0x5b6>
                  *n = *(int*)putdat;
  800869:	88 10                	mov    %dl,(%eax)
                  printfmt(putch,putdat,"%s",overflow_error);
  80086b:	c7 44 24 0c 68 17 80 	movl   $0x801768,0xc(%esp)
  800872:	00 
  800873:	c7 44 24 08 92 16 80 	movl   $0x801692,0x8(%esp)
  80087a:	00 
  80087b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80087f:	8b 45 08             	mov    0x8(%ebp),%eax
  800882:	89 04 24             	mov    %eax,(%esp)
  800885:	e8 5d 01 00 00       	call   8009e7 <printfmt>
  80088a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80088d:	e9 79 fa ff ff       	jmp    80030b <vprintfmt+0x2f>
            }
            else
                  *n = *(int*)putdat;
  800892:	88 10                	mov    %dl,(%eax)
  800894:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800897:	e9 6f fa ff ff       	jmp    80030b <vprintfmt+0x2f>
  80089c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80089f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            break;
        }
		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8008a2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008a5:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8008a9:	89 14 24             	mov    %edx,(%esp)
  8008ac:	ff 55 08             	call   *0x8(%ebp)
  8008af:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;
  8008b2:	e9 54 fa ff ff       	jmp    80030b <vprintfmt+0x2f>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8008b7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8008ba:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008be:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8008c5:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008c8:	8d 47 ff             	lea    -0x1(%edi),%eax
  8008cb:	80 38 25             	cmpb   $0x25,(%eax)
  8008ce:	0f 84 37 fa ff ff    	je     80030b <vprintfmt+0x2f>
  8008d4:	89 c7                	mov    %eax,%edi
  8008d6:	eb f0                	jmp    8008c8 <vprintfmt+0x5ec>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8008d8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008db:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008df:	8b 74 24 04          	mov    0x4(%esp),%esi
  8008e3:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8008e6:	89 54 24 08          	mov    %edx,0x8(%esp)
  8008ea:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8008f1:	00 
  8008f2:	8b 45 b0             	mov    -0x50(%ebp),%eax
  8008f5:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  8008f8:	89 04 24             	mov    %eax,(%esp)
  8008fb:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008ff:	e8 0c 0c 00 00       	call   801510 <__umoddi3>
  800904:	89 74 24 04          	mov    %esi,0x4(%esp)
  800908:	0f be 80 78 16 80 00 	movsbl 0x801678(%eax),%eax
  80090f:	89 04 24             	mov    %eax,(%esp)
  800912:	ff 55 08             	call   *0x8(%ebp)
  800915:	e9 d6 fe ff ff       	jmp    8007f0 <vprintfmt+0x514>
  80091a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80091d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800921:	8b 74 24 04          	mov    0x4(%esp),%esi
  800925:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800928:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80092c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800933:	00 
  800934:	8b 45 b0             	mov    -0x50(%ebp),%eax
  800937:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  80093a:	89 04 24             	mov    %eax,(%esp)
  80093d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800941:	e8 ca 0b 00 00       	call   801510 <__umoddi3>
  800946:	89 74 24 04          	mov    %esi,0x4(%esp)
  80094a:	0f be 80 78 16 80 00 	movsbl 0x801678(%eax),%eax
  800951:	89 04 24             	mov    %eax,(%esp)
  800954:	ff 55 08             	call   *0x8(%ebp)
  800957:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80095a:	e9 ac f9 ff ff       	jmp    80030b <vprintfmt+0x2f>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  80095f:	83 c4 6c             	add    $0x6c,%esp
  800962:	5b                   	pop    %ebx
  800963:	5e                   	pop    %esi
  800964:	5f                   	pop    %edi
  800965:	5d                   	pop    %ebp
  800966:	c3                   	ret    

00800967 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800967:	55                   	push   %ebp
  800968:	89 e5                	mov    %esp,%ebp
  80096a:	83 ec 28             	sub    $0x28,%esp
  80096d:	8b 45 08             	mov    0x8(%ebp),%eax
  800970:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  800973:	85 c0                	test   %eax,%eax
  800975:	74 04                	je     80097b <vsnprintf+0x14>
  800977:	85 d2                	test   %edx,%edx
  800979:	7f 07                	jg     800982 <vsnprintf+0x1b>
  80097b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800980:	eb 3b                	jmp    8009bd <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  800982:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800985:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  800989:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80098c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800993:	8b 45 14             	mov    0x14(%ebp),%eax
  800996:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80099a:	8b 45 10             	mov    0x10(%ebp),%eax
  80099d:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009a1:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8009a4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009a8:	c7 04 24 bf 02 80 00 	movl   $0x8002bf,(%esp)
  8009af:	e8 28 f9 ff ff       	call   8002dc <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8009b4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8009b7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8009ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8009bd:	c9                   	leave  
  8009be:	c3                   	ret    

008009bf <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8009bf:	55                   	push   %ebp
  8009c0:	89 e5                	mov    %esp,%ebp
  8009c2:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  8009c5:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  8009c8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009cc:	8b 45 10             	mov    0x10(%ebp),%eax
  8009cf:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009d3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009d6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009da:	8b 45 08             	mov    0x8(%ebp),%eax
  8009dd:	89 04 24             	mov    %eax,(%esp)
  8009e0:	e8 82 ff ff ff       	call   800967 <vsnprintf>
	va_end(ap);

	return rc;
}
  8009e5:	c9                   	leave  
  8009e6:	c3                   	ret    

008009e7 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8009e7:	55                   	push   %ebp
  8009e8:	89 e5                	mov    %esp,%ebp
  8009ea:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  8009ed:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  8009f0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009f4:	8b 45 10             	mov    0x10(%ebp),%eax
  8009f7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009fb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009fe:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a02:	8b 45 08             	mov    0x8(%ebp),%eax
  800a05:	89 04 24             	mov    %eax,(%esp)
  800a08:	e8 cf f8 ff ff       	call   8002dc <vprintfmt>
	va_end(ap);
}
  800a0d:	c9                   	leave  
  800a0e:	c3                   	ret    
	...

00800a10 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a10:	55                   	push   %ebp
  800a11:	89 e5                	mov    %esp,%ebp
  800a13:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a16:	b8 00 00 00 00       	mov    $0x0,%eax
  800a1b:	80 3a 00             	cmpb   $0x0,(%edx)
  800a1e:	74 09                	je     800a29 <strlen+0x19>
		n++;
  800a20:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800a23:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a27:	75 f7                	jne    800a20 <strlen+0x10>
		n++;
	return n;
}
  800a29:	5d                   	pop    %ebp
  800a2a:	c3                   	ret    

00800a2b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a2b:	55                   	push   %ebp
  800a2c:	89 e5                	mov    %esp,%ebp
  800a2e:	53                   	push   %ebx
  800a2f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800a32:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a35:	85 c9                	test   %ecx,%ecx
  800a37:	74 19                	je     800a52 <strnlen+0x27>
  800a39:	80 3b 00             	cmpb   $0x0,(%ebx)
  800a3c:	74 14                	je     800a52 <strnlen+0x27>
  800a3e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800a43:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a46:	39 c8                	cmp    %ecx,%eax
  800a48:	74 0d                	je     800a57 <strnlen+0x2c>
  800a4a:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  800a4e:	75 f3                	jne    800a43 <strnlen+0x18>
  800a50:	eb 05                	jmp    800a57 <strnlen+0x2c>
  800a52:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800a57:	5b                   	pop    %ebx
  800a58:	5d                   	pop    %ebp
  800a59:	c3                   	ret    

00800a5a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a5a:	55                   	push   %ebp
  800a5b:	89 e5                	mov    %esp,%ebp
  800a5d:	53                   	push   %ebx
  800a5e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a61:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a64:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a69:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800a6d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800a70:	83 c2 01             	add    $0x1,%edx
  800a73:	84 c9                	test   %cl,%cl
  800a75:	75 f2                	jne    800a69 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800a77:	5b                   	pop    %ebx
  800a78:	5d                   	pop    %ebp
  800a79:	c3                   	ret    

00800a7a <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a7a:	55                   	push   %ebp
  800a7b:	89 e5                	mov    %esp,%ebp
  800a7d:	53                   	push   %ebx
  800a7e:	83 ec 08             	sub    $0x8,%esp
  800a81:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a84:	89 1c 24             	mov    %ebx,(%esp)
  800a87:	e8 84 ff ff ff       	call   800a10 <strlen>
	strcpy(dst + len, src);
  800a8c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a8f:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a93:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800a96:	89 04 24             	mov    %eax,(%esp)
  800a99:	e8 bc ff ff ff       	call   800a5a <strcpy>
	return dst;
}
  800a9e:	89 d8                	mov    %ebx,%eax
  800aa0:	83 c4 08             	add    $0x8,%esp
  800aa3:	5b                   	pop    %ebx
  800aa4:	5d                   	pop    %ebp
  800aa5:	c3                   	ret    

00800aa6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800aa6:	55                   	push   %ebp
  800aa7:	89 e5                	mov    %esp,%ebp
  800aa9:	56                   	push   %esi
  800aaa:	53                   	push   %ebx
  800aab:	8b 45 08             	mov    0x8(%ebp),%eax
  800aae:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ab1:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ab4:	85 f6                	test   %esi,%esi
  800ab6:	74 18                	je     800ad0 <strncpy+0x2a>
  800ab8:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800abd:	0f b6 1a             	movzbl (%edx),%ebx
  800ac0:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800ac3:	80 3a 01             	cmpb   $0x1,(%edx)
  800ac6:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ac9:	83 c1 01             	add    $0x1,%ecx
  800acc:	39 ce                	cmp    %ecx,%esi
  800ace:	77 ed                	ja     800abd <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800ad0:	5b                   	pop    %ebx
  800ad1:	5e                   	pop    %esi
  800ad2:	5d                   	pop    %ebp
  800ad3:	c3                   	ret    

00800ad4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800ad4:	55                   	push   %ebp
  800ad5:	89 e5                	mov    %esp,%ebp
  800ad7:	56                   	push   %esi
  800ad8:	53                   	push   %ebx
  800ad9:	8b 75 08             	mov    0x8(%ebp),%esi
  800adc:	8b 55 0c             	mov    0xc(%ebp),%edx
  800adf:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800ae2:	89 f0                	mov    %esi,%eax
  800ae4:	85 c9                	test   %ecx,%ecx
  800ae6:	74 27                	je     800b0f <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  800ae8:	83 e9 01             	sub    $0x1,%ecx
  800aeb:	74 1d                	je     800b0a <strlcpy+0x36>
  800aed:	0f b6 1a             	movzbl (%edx),%ebx
  800af0:	84 db                	test   %bl,%bl
  800af2:	74 16                	je     800b0a <strlcpy+0x36>
			*dst++ = *src++;
  800af4:	88 18                	mov    %bl,(%eax)
  800af6:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800af9:	83 e9 01             	sub    $0x1,%ecx
  800afc:	74 0e                	je     800b0c <strlcpy+0x38>
			*dst++ = *src++;
  800afe:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800b01:	0f b6 1a             	movzbl (%edx),%ebx
  800b04:	84 db                	test   %bl,%bl
  800b06:	75 ec                	jne    800af4 <strlcpy+0x20>
  800b08:	eb 02                	jmp    800b0c <strlcpy+0x38>
  800b0a:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800b0c:	c6 00 00             	movb   $0x0,(%eax)
  800b0f:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800b11:	5b                   	pop    %ebx
  800b12:	5e                   	pop    %esi
  800b13:	5d                   	pop    %ebp
  800b14:	c3                   	ret    

00800b15 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b15:	55                   	push   %ebp
  800b16:	89 e5                	mov    %esp,%ebp
  800b18:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b1b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800b1e:	0f b6 01             	movzbl (%ecx),%eax
  800b21:	84 c0                	test   %al,%al
  800b23:	74 15                	je     800b3a <strcmp+0x25>
  800b25:	3a 02                	cmp    (%edx),%al
  800b27:	75 11                	jne    800b3a <strcmp+0x25>
		p++, q++;
  800b29:	83 c1 01             	add    $0x1,%ecx
  800b2c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800b2f:	0f b6 01             	movzbl (%ecx),%eax
  800b32:	84 c0                	test   %al,%al
  800b34:	74 04                	je     800b3a <strcmp+0x25>
  800b36:	3a 02                	cmp    (%edx),%al
  800b38:	74 ef                	je     800b29 <strcmp+0x14>
  800b3a:	0f b6 c0             	movzbl %al,%eax
  800b3d:	0f b6 12             	movzbl (%edx),%edx
  800b40:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800b42:	5d                   	pop    %ebp
  800b43:	c3                   	ret    

00800b44 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b44:	55                   	push   %ebp
  800b45:	89 e5                	mov    %esp,%ebp
  800b47:	53                   	push   %ebx
  800b48:	8b 55 08             	mov    0x8(%ebp),%edx
  800b4b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b4e:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800b51:	85 c0                	test   %eax,%eax
  800b53:	74 23                	je     800b78 <strncmp+0x34>
  800b55:	0f b6 1a             	movzbl (%edx),%ebx
  800b58:	84 db                	test   %bl,%bl
  800b5a:	74 25                	je     800b81 <strncmp+0x3d>
  800b5c:	3a 19                	cmp    (%ecx),%bl
  800b5e:	75 21                	jne    800b81 <strncmp+0x3d>
  800b60:	83 e8 01             	sub    $0x1,%eax
  800b63:	74 13                	je     800b78 <strncmp+0x34>
		n--, p++, q++;
  800b65:	83 c2 01             	add    $0x1,%edx
  800b68:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b6b:	0f b6 1a             	movzbl (%edx),%ebx
  800b6e:	84 db                	test   %bl,%bl
  800b70:	74 0f                	je     800b81 <strncmp+0x3d>
  800b72:	3a 19                	cmp    (%ecx),%bl
  800b74:	74 ea                	je     800b60 <strncmp+0x1c>
  800b76:	eb 09                	jmp    800b81 <strncmp+0x3d>
  800b78:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800b7d:	5b                   	pop    %ebx
  800b7e:	5d                   	pop    %ebp
  800b7f:	90                   	nop
  800b80:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b81:	0f b6 02             	movzbl (%edx),%eax
  800b84:	0f b6 11             	movzbl (%ecx),%edx
  800b87:	29 d0                	sub    %edx,%eax
  800b89:	eb f2                	jmp    800b7d <strncmp+0x39>

00800b8b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b8b:	55                   	push   %ebp
  800b8c:	89 e5                	mov    %esp,%ebp
  800b8e:	8b 45 08             	mov    0x8(%ebp),%eax
  800b91:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b95:	0f b6 10             	movzbl (%eax),%edx
  800b98:	84 d2                	test   %dl,%dl
  800b9a:	74 18                	je     800bb4 <strchr+0x29>
		if (*s == c)
  800b9c:	38 ca                	cmp    %cl,%dl
  800b9e:	75 0a                	jne    800baa <strchr+0x1f>
  800ba0:	eb 17                	jmp    800bb9 <strchr+0x2e>
  800ba2:	38 ca                	cmp    %cl,%dl
  800ba4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800ba8:	74 0f                	je     800bb9 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800baa:	83 c0 01             	add    $0x1,%eax
  800bad:	0f b6 10             	movzbl (%eax),%edx
  800bb0:	84 d2                	test   %dl,%dl
  800bb2:	75 ee                	jne    800ba2 <strchr+0x17>
  800bb4:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800bb9:	5d                   	pop    %ebp
  800bba:	c3                   	ret    

00800bbb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800bbb:	55                   	push   %ebp
  800bbc:	89 e5                	mov    %esp,%ebp
  800bbe:	8b 45 08             	mov    0x8(%ebp),%eax
  800bc1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800bc5:	0f b6 10             	movzbl (%eax),%edx
  800bc8:	84 d2                	test   %dl,%dl
  800bca:	74 18                	je     800be4 <strfind+0x29>
		if (*s == c)
  800bcc:	38 ca                	cmp    %cl,%dl
  800bce:	75 0a                	jne    800bda <strfind+0x1f>
  800bd0:	eb 12                	jmp    800be4 <strfind+0x29>
  800bd2:	38 ca                	cmp    %cl,%dl
  800bd4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800bd8:	74 0a                	je     800be4 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800bda:	83 c0 01             	add    $0x1,%eax
  800bdd:	0f b6 10             	movzbl (%eax),%edx
  800be0:	84 d2                	test   %dl,%dl
  800be2:	75 ee                	jne    800bd2 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800be4:	5d                   	pop    %ebp
  800be5:	c3                   	ret    

00800be6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800be6:	55                   	push   %ebp
  800be7:	89 e5                	mov    %esp,%ebp
  800be9:	83 ec 0c             	sub    $0xc,%esp
  800bec:	89 1c 24             	mov    %ebx,(%esp)
  800bef:	89 74 24 04          	mov    %esi,0x4(%esp)
  800bf3:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800bf7:	8b 7d 08             	mov    0x8(%ebp),%edi
  800bfa:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bfd:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800c00:	85 c9                	test   %ecx,%ecx
  800c02:	74 30                	je     800c34 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800c04:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c0a:	75 25                	jne    800c31 <memset+0x4b>
  800c0c:	f6 c1 03             	test   $0x3,%cl
  800c0f:	75 20                	jne    800c31 <memset+0x4b>
		c &= 0xFF;
  800c11:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800c14:	89 d3                	mov    %edx,%ebx
  800c16:	c1 e3 08             	shl    $0x8,%ebx
  800c19:	89 d6                	mov    %edx,%esi
  800c1b:	c1 e6 18             	shl    $0x18,%esi
  800c1e:	89 d0                	mov    %edx,%eax
  800c20:	c1 e0 10             	shl    $0x10,%eax
  800c23:	09 f0                	or     %esi,%eax
  800c25:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  800c27:	09 d8                	or     %ebx,%eax
  800c29:	c1 e9 02             	shr    $0x2,%ecx
  800c2c:	fc                   	cld    
  800c2d:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800c2f:	eb 03                	jmp    800c34 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c31:	fc                   	cld    
  800c32:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800c34:	89 f8                	mov    %edi,%eax
  800c36:	8b 1c 24             	mov    (%esp),%ebx
  800c39:	8b 74 24 04          	mov    0x4(%esp),%esi
  800c3d:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800c41:	89 ec                	mov    %ebp,%esp
  800c43:	5d                   	pop    %ebp
  800c44:	c3                   	ret    

00800c45 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c45:	55                   	push   %ebp
  800c46:	89 e5                	mov    %esp,%ebp
  800c48:	83 ec 08             	sub    $0x8,%esp
  800c4b:	89 34 24             	mov    %esi,(%esp)
  800c4e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800c52:	8b 45 08             	mov    0x8(%ebp),%eax
  800c55:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800c58:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800c5b:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800c5d:	39 c6                	cmp    %eax,%esi
  800c5f:	73 35                	jae    800c96 <memmove+0x51>
  800c61:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c64:	39 d0                	cmp    %edx,%eax
  800c66:	73 2e                	jae    800c96 <memmove+0x51>
		s += n;
		d += n;
  800c68:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c6a:	f6 c2 03             	test   $0x3,%dl
  800c6d:	75 1b                	jne    800c8a <memmove+0x45>
  800c6f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c75:	75 13                	jne    800c8a <memmove+0x45>
  800c77:	f6 c1 03             	test   $0x3,%cl
  800c7a:	75 0e                	jne    800c8a <memmove+0x45>
			asm volatile("std; rep movsl\n"
  800c7c:	83 ef 04             	sub    $0x4,%edi
  800c7f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c82:	c1 e9 02             	shr    $0x2,%ecx
  800c85:	fd                   	std    
  800c86:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c88:	eb 09                	jmp    800c93 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800c8a:	83 ef 01             	sub    $0x1,%edi
  800c8d:	8d 72 ff             	lea    -0x1(%edx),%esi
  800c90:	fd                   	std    
  800c91:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c93:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c94:	eb 20                	jmp    800cb6 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c96:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c9c:	75 15                	jne    800cb3 <memmove+0x6e>
  800c9e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800ca4:	75 0d                	jne    800cb3 <memmove+0x6e>
  800ca6:	f6 c1 03             	test   $0x3,%cl
  800ca9:	75 08                	jne    800cb3 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  800cab:	c1 e9 02             	shr    $0x2,%ecx
  800cae:	fc                   	cld    
  800caf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800cb1:	eb 03                	jmp    800cb6 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800cb3:	fc                   	cld    
  800cb4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800cb6:	8b 34 24             	mov    (%esp),%esi
  800cb9:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800cbd:	89 ec                	mov    %ebp,%esp
  800cbf:	5d                   	pop    %ebp
  800cc0:	c3                   	ret    

00800cc1 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800cc1:	55                   	push   %ebp
  800cc2:	89 e5                	mov    %esp,%ebp
  800cc4:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800cc7:	8b 45 10             	mov    0x10(%ebp),%eax
  800cca:	89 44 24 08          	mov    %eax,0x8(%esp)
  800cce:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cd1:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cd5:	8b 45 08             	mov    0x8(%ebp),%eax
  800cd8:	89 04 24             	mov    %eax,(%esp)
  800cdb:	e8 65 ff ff ff       	call   800c45 <memmove>
}
  800ce0:	c9                   	leave  
  800ce1:	c3                   	ret    

00800ce2 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ce2:	55                   	push   %ebp
  800ce3:	89 e5                	mov    %esp,%ebp
  800ce5:	57                   	push   %edi
  800ce6:	56                   	push   %esi
  800ce7:	53                   	push   %ebx
  800ce8:	8b 75 08             	mov    0x8(%ebp),%esi
  800ceb:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800cee:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800cf1:	85 c9                	test   %ecx,%ecx
  800cf3:	74 36                	je     800d2b <memcmp+0x49>
		if (*s1 != *s2)
  800cf5:	0f b6 06             	movzbl (%esi),%eax
  800cf8:	0f b6 1f             	movzbl (%edi),%ebx
  800cfb:	38 d8                	cmp    %bl,%al
  800cfd:	74 20                	je     800d1f <memcmp+0x3d>
  800cff:	eb 14                	jmp    800d15 <memcmp+0x33>
  800d01:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  800d06:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  800d0b:	83 c2 01             	add    $0x1,%edx
  800d0e:	83 e9 01             	sub    $0x1,%ecx
  800d11:	38 d8                	cmp    %bl,%al
  800d13:	74 12                	je     800d27 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  800d15:	0f b6 c0             	movzbl %al,%eax
  800d18:	0f b6 db             	movzbl %bl,%ebx
  800d1b:	29 d8                	sub    %ebx,%eax
  800d1d:	eb 11                	jmp    800d30 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d1f:	83 e9 01             	sub    $0x1,%ecx
  800d22:	ba 00 00 00 00       	mov    $0x0,%edx
  800d27:	85 c9                	test   %ecx,%ecx
  800d29:	75 d6                	jne    800d01 <memcmp+0x1f>
  800d2b:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800d30:	5b                   	pop    %ebx
  800d31:	5e                   	pop    %esi
  800d32:	5f                   	pop    %edi
  800d33:	5d                   	pop    %ebp
  800d34:	c3                   	ret    

00800d35 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800d35:	55                   	push   %ebp
  800d36:	89 e5                	mov    %esp,%ebp
  800d38:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800d3b:	89 c2                	mov    %eax,%edx
  800d3d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800d40:	39 d0                	cmp    %edx,%eax
  800d42:	73 15                	jae    800d59 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d44:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800d48:	38 08                	cmp    %cl,(%eax)
  800d4a:	75 06                	jne    800d52 <memfind+0x1d>
  800d4c:	eb 0b                	jmp    800d59 <memfind+0x24>
  800d4e:	38 08                	cmp    %cl,(%eax)
  800d50:	74 07                	je     800d59 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d52:	83 c0 01             	add    $0x1,%eax
  800d55:	39 c2                	cmp    %eax,%edx
  800d57:	77 f5                	ja     800d4e <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800d59:	5d                   	pop    %ebp
  800d5a:	c3                   	ret    

00800d5b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d5b:	55                   	push   %ebp
  800d5c:	89 e5                	mov    %esp,%ebp
  800d5e:	57                   	push   %edi
  800d5f:	56                   	push   %esi
  800d60:	53                   	push   %ebx
  800d61:	83 ec 04             	sub    $0x4,%esp
  800d64:	8b 55 08             	mov    0x8(%ebp),%edx
  800d67:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d6a:	0f b6 02             	movzbl (%edx),%eax
  800d6d:	3c 20                	cmp    $0x20,%al
  800d6f:	74 04                	je     800d75 <strtol+0x1a>
  800d71:	3c 09                	cmp    $0x9,%al
  800d73:	75 0e                	jne    800d83 <strtol+0x28>
		s++;
  800d75:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d78:	0f b6 02             	movzbl (%edx),%eax
  800d7b:	3c 20                	cmp    $0x20,%al
  800d7d:	74 f6                	je     800d75 <strtol+0x1a>
  800d7f:	3c 09                	cmp    $0x9,%al
  800d81:	74 f2                	je     800d75 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800d83:	3c 2b                	cmp    $0x2b,%al
  800d85:	75 0c                	jne    800d93 <strtol+0x38>
		s++;
  800d87:	83 c2 01             	add    $0x1,%edx
  800d8a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800d91:	eb 15                	jmp    800da8 <strtol+0x4d>
	else if (*s == '-')
  800d93:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800d9a:	3c 2d                	cmp    $0x2d,%al
  800d9c:	75 0a                	jne    800da8 <strtol+0x4d>
		s++, neg = 1;
  800d9e:	83 c2 01             	add    $0x1,%edx
  800da1:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800da8:	85 db                	test   %ebx,%ebx
  800daa:	0f 94 c0             	sete   %al
  800dad:	74 05                	je     800db4 <strtol+0x59>
  800daf:	83 fb 10             	cmp    $0x10,%ebx
  800db2:	75 18                	jne    800dcc <strtol+0x71>
  800db4:	80 3a 30             	cmpb   $0x30,(%edx)
  800db7:	75 13                	jne    800dcc <strtol+0x71>
  800db9:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800dbd:	8d 76 00             	lea    0x0(%esi),%esi
  800dc0:	75 0a                	jne    800dcc <strtol+0x71>
		s += 2, base = 16;
  800dc2:	83 c2 02             	add    $0x2,%edx
  800dc5:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800dca:	eb 15                	jmp    800de1 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800dcc:	84 c0                	test   %al,%al
  800dce:	66 90                	xchg   %ax,%ax
  800dd0:	74 0f                	je     800de1 <strtol+0x86>
  800dd2:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800dd7:	80 3a 30             	cmpb   $0x30,(%edx)
  800dda:	75 05                	jne    800de1 <strtol+0x86>
		s++, base = 8;
  800ddc:	83 c2 01             	add    $0x1,%edx
  800ddf:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800de1:	b8 00 00 00 00       	mov    $0x0,%eax
  800de6:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800de8:	0f b6 0a             	movzbl (%edx),%ecx
  800deb:	89 cf                	mov    %ecx,%edi
  800ded:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800df0:	80 fb 09             	cmp    $0x9,%bl
  800df3:	77 08                	ja     800dfd <strtol+0xa2>
			dig = *s - '0';
  800df5:	0f be c9             	movsbl %cl,%ecx
  800df8:	83 e9 30             	sub    $0x30,%ecx
  800dfb:	eb 1e                	jmp    800e1b <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  800dfd:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  800e00:	80 fb 19             	cmp    $0x19,%bl
  800e03:	77 08                	ja     800e0d <strtol+0xb2>
			dig = *s - 'a' + 10;
  800e05:	0f be c9             	movsbl %cl,%ecx
  800e08:	83 e9 57             	sub    $0x57,%ecx
  800e0b:	eb 0e                	jmp    800e1b <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  800e0d:	8d 5f bf             	lea    -0x41(%edi),%ebx
  800e10:	80 fb 19             	cmp    $0x19,%bl
  800e13:	77 15                	ja     800e2a <strtol+0xcf>
			dig = *s - 'A' + 10;
  800e15:	0f be c9             	movsbl %cl,%ecx
  800e18:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800e1b:	39 f1                	cmp    %esi,%ecx
  800e1d:	7d 0b                	jge    800e2a <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  800e1f:	83 c2 01             	add    $0x1,%edx
  800e22:	0f af c6             	imul   %esi,%eax
  800e25:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800e28:	eb be                	jmp    800de8 <strtol+0x8d>
  800e2a:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800e2c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e30:	74 05                	je     800e37 <strtol+0xdc>
		*endptr = (char *) s;
  800e32:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800e35:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800e37:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800e3b:	74 04                	je     800e41 <strtol+0xe6>
  800e3d:	89 c8                	mov    %ecx,%eax
  800e3f:	f7 d8                	neg    %eax
}
  800e41:	83 c4 04             	add    $0x4,%esp
  800e44:	5b                   	pop    %ebx
  800e45:	5e                   	pop    %esi
  800e46:	5f                   	pop    %edi
  800e47:	5d                   	pop    %ebp
  800e48:	c3                   	ret    
  800e49:	00 00                	add    %al,(%eax)
	...

00800e4c <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  800e4c:	55                   	push   %ebp
  800e4d:	89 e5                	mov    %esp,%ebp
  800e4f:	83 ec 08             	sub    $0x8,%esp
  800e52:	89 1c 24             	mov    %ebx,(%esp)
  800e55:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800e59:	ba 00 00 00 00       	mov    $0x0,%edx
  800e5e:	b8 01 00 00 00       	mov    $0x1,%eax
  800e63:	89 d1                	mov    %edx,%ecx
  800e65:	89 d3                	mov    %edx,%ebx
  800e67:	89 d7                	mov    %edx,%edi
  800e69:	51                   	push   %ecx
  800e6a:	52                   	push   %edx
  800e6b:	53                   	push   %ebx
  800e6c:	54                   	push   %esp
  800e6d:	55                   	push   %ebp
  800e6e:	56                   	push   %esi
  800e6f:	57                   	push   %edi
  800e70:	54                   	push   %esp
  800e71:	5d                   	pop    %ebp
  800e72:	8d 35 7a 0e 80 00    	lea    0x800e7a,%esi
  800e78:	0f 34                	sysenter 
  800e7a:	5f                   	pop    %edi
  800e7b:	5e                   	pop    %esi
  800e7c:	5d                   	pop    %ebp
  800e7d:	5c                   	pop    %esp
  800e7e:	5b                   	pop    %ebx
  800e7f:	5a                   	pop    %edx
  800e80:	59                   	pop    %ecx

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800e81:	8b 1c 24             	mov    (%esp),%ebx
  800e84:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800e88:	89 ec                	mov    %ebp,%esp
  800e8a:	5d                   	pop    %ebp
  800e8b:	c3                   	ret    

00800e8c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800e8c:	55                   	push   %ebp
  800e8d:	89 e5                	mov    %esp,%ebp
  800e8f:	83 ec 08             	sub    $0x8,%esp
  800e92:	89 1c 24             	mov    %ebx,(%esp)
  800e95:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800e99:	b8 00 00 00 00       	mov    $0x0,%eax
  800e9e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ea1:	8b 55 08             	mov    0x8(%ebp),%edx
  800ea4:	89 c3                	mov    %eax,%ebx
  800ea6:	89 c7                	mov    %eax,%edi
  800ea8:	51                   	push   %ecx
  800ea9:	52                   	push   %edx
  800eaa:	53                   	push   %ebx
  800eab:	54                   	push   %esp
  800eac:	55                   	push   %ebp
  800ead:	56                   	push   %esi
  800eae:	57                   	push   %edi
  800eaf:	54                   	push   %esp
  800eb0:	5d                   	pop    %ebp
  800eb1:	8d 35 b9 0e 80 00    	lea    0x800eb9,%esi
  800eb7:	0f 34                	sysenter 
  800eb9:	5f                   	pop    %edi
  800eba:	5e                   	pop    %esi
  800ebb:	5d                   	pop    %ebp
  800ebc:	5c                   	pop    %esp
  800ebd:	5b                   	pop    %ebx
  800ebe:	5a                   	pop    %edx
  800ebf:	59                   	pop    %ecx

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ec0:	8b 1c 24             	mov    (%esp),%ebx
  800ec3:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800ec7:	89 ec                	mov    %ebp,%esp
  800ec9:	5d                   	pop    %ebp
  800eca:	c3                   	ret    

00800ecb <sys_env_set_prior>:
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}

int 
sys_env_set_prior(envid_t envid, uint32_t prior){
  800ecb:	55                   	push   %ebp
  800ecc:	89 e5                	mov    %esp,%ebp
  800ece:	83 ec 28             	sub    $0x28,%esp
  800ed1:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800ed4:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800ed7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800edc:	b8 0e 00 00 00       	mov    $0xe,%eax
  800ee1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ee4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ee7:	89 df                	mov    %ebx,%edi
  800ee9:	51                   	push   %ecx
  800eea:	52                   	push   %edx
  800eeb:	53                   	push   %ebx
  800eec:	54                   	push   %esp
  800eed:	55                   	push   %ebp
  800eee:	56                   	push   %esi
  800eef:	57                   	push   %edi
  800ef0:	54                   	push   %esp
  800ef1:	5d                   	pop    %ebp
  800ef2:	8d 35 fa 0e 80 00    	lea    0x800efa,%esi
  800ef8:	0f 34                	sysenter 
  800efa:	5f                   	pop    %edi
  800efb:	5e                   	pop    %esi
  800efc:	5d                   	pop    %ebp
  800efd:	5c                   	pop    %esp
  800efe:	5b                   	pop    %ebx
  800eff:	5a                   	pop    %edx
  800f00:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  800f01:	85 c0                	test   %eax,%eax
  800f03:	7e 28                	jle    800f2d <sys_env_set_prior+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f05:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f09:	c7 44 24 0c 0e 00 00 	movl   $0xe,0xc(%esp)
  800f10:	00 
  800f11:	c7 44 24 08 44 19 80 	movl   $0x801944,0x8(%esp)
  800f18:	00 
  800f19:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  800f20:	00 
  800f21:	c7 04 24 61 19 80 00 	movl   $0x801961,(%esp)
  800f28:	e8 43 04 00 00       	call   801370 <_panic>
}

int 
sys_env_set_prior(envid_t envid, uint32_t prior){
         return syscall(SYS_env_set_prior,1,envid, prior, 0, 0, 0);
}
  800f2d:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800f30:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f33:	89 ec                	mov    %ebp,%esp
  800f35:	5d                   	pop    %ebp
  800f36:	c3                   	ret    

00800f37 <sys_sbrk>:
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}

int
sys_sbrk(uint32_t inc)
{
  800f37:	55                   	push   %ebp
  800f38:	89 e5                	mov    %esp,%ebp
  800f3a:	83 ec 08             	sub    $0x8,%esp
  800f3d:	89 1c 24             	mov    %ebx,(%esp)
  800f40:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800f44:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f49:	b8 0f 00 00 00       	mov    $0xf,%eax
  800f4e:	8b 55 08             	mov    0x8(%ebp),%edx
  800f51:	89 cb                	mov    %ecx,%ebx
  800f53:	89 cf                	mov    %ecx,%edi
  800f55:	51                   	push   %ecx
  800f56:	52                   	push   %edx
  800f57:	53                   	push   %ebx
  800f58:	54                   	push   %esp
  800f59:	55                   	push   %ebp
  800f5a:	56                   	push   %esi
  800f5b:	57                   	push   %edi
  800f5c:	54                   	push   %esp
  800f5d:	5d                   	pop    %ebp
  800f5e:	8d 35 66 0f 80 00    	lea    0x800f66,%esi
  800f64:	0f 34                	sysenter 
  800f66:	5f                   	pop    %edi
  800f67:	5e                   	pop    %esi
  800f68:	5d                   	pop    %ebp
  800f69:	5c                   	pop    %esp
  800f6a:	5b                   	pop    %ebx
  800f6b:	5a                   	pop    %edx
  800f6c:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  800f6d:	8b 1c 24             	mov    (%esp),%ebx
  800f70:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800f74:	89 ec                	mov    %ebp,%esp
  800f76:	5d                   	pop    %ebp
  800f77:	c3                   	ret    

00800f78 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800f78:	55                   	push   %ebp
  800f79:	89 e5                	mov    %esp,%ebp
  800f7b:	83 ec 28             	sub    $0x28,%esp
  800f7e:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800f81:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800f84:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f89:	b8 0d 00 00 00       	mov    $0xd,%eax
  800f8e:	8b 55 08             	mov    0x8(%ebp),%edx
  800f91:	89 cb                	mov    %ecx,%ebx
  800f93:	89 cf                	mov    %ecx,%edi
  800f95:	51                   	push   %ecx
  800f96:	52                   	push   %edx
  800f97:	53                   	push   %ebx
  800f98:	54                   	push   %esp
  800f99:	55                   	push   %ebp
  800f9a:	56                   	push   %esi
  800f9b:	57                   	push   %edi
  800f9c:	54                   	push   %esp
  800f9d:	5d                   	pop    %ebp
  800f9e:	8d 35 a6 0f 80 00    	lea    0x800fa6,%esi
  800fa4:	0f 34                	sysenter 
  800fa6:	5f                   	pop    %edi
  800fa7:	5e                   	pop    %esi
  800fa8:	5d                   	pop    %ebp
  800fa9:	5c                   	pop    %esp
  800faa:	5b                   	pop    %ebx
  800fab:	5a                   	pop    %edx
  800fac:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  800fad:	85 c0                	test   %eax,%eax
  800faf:	7e 28                	jle    800fd9 <sys_ipc_recv+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fb1:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fb5:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800fbc:	00 
  800fbd:	c7 44 24 08 44 19 80 	movl   $0x801944,0x8(%esp)
  800fc4:	00 
  800fc5:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  800fcc:	00 
  800fcd:	c7 04 24 61 19 80 00 	movl   $0x801961,(%esp)
  800fd4:	e8 97 03 00 00       	call   801370 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800fd9:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800fdc:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800fdf:	89 ec                	mov    %ebp,%esp
  800fe1:	5d                   	pop    %ebp
  800fe2:	c3                   	ret    

00800fe3 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800fe3:	55                   	push   %ebp
  800fe4:	89 e5                	mov    %esp,%ebp
  800fe6:	83 ec 08             	sub    $0x8,%esp
  800fe9:	89 1c 24             	mov    %ebx,(%esp)
  800fec:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800ff0:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ff5:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ff8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ffb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ffe:	8b 55 08             	mov    0x8(%ebp),%edx
  801001:	51                   	push   %ecx
  801002:	52                   	push   %edx
  801003:	53                   	push   %ebx
  801004:	54                   	push   %esp
  801005:	55                   	push   %ebp
  801006:	56                   	push   %esi
  801007:	57                   	push   %edi
  801008:	54                   	push   %esp
  801009:	5d                   	pop    %ebp
  80100a:	8d 35 12 10 80 00    	lea    0x801012,%esi
  801010:	0f 34                	sysenter 
  801012:	5f                   	pop    %edi
  801013:	5e                   	pop    %esi
  801014:	5d                   	pop    %ebp
  801015:	5c                   	pop    %esp
  801016:	5b                   	pop    %ebx
  801017:	5a                   	pop    %edx
  801018:	59                   	pop    %ecx

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801019:	8b 1c 24             	mov    (%esp),%ebx
  80101c:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801020:	89 ec                	mov    %ebp,%esp
  801022:	5d                   	pop    %ebp
  801023:	c3                   	ret    

00801024 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801024:	55                   	push   %ebp
  801025:	89 e5                	mov    %esp,%ebp
  801027:	83 ec 28             	sub    $0x28,%esp
  80102a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80102d:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801030:	bb 00 00 00 00       	mov    $0x0,%ebx
  801035:	b8 0a 00 00 00       	mov    $0xa,%eax
  80103a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80103d:	8b 55 08             	mov    0x8(%ebp),%edx
  801040:	89 df                	mov    %ebx,%edi
  801042:	51                   	push   %ecx
  801043:	52                   	push   %edx
  801044:	53                   	push   %ebx
  801045:	54                   	push   %esp
  801046:	55                   	push   %ebp
  801047:	56                   	push   %esi
  801048:	57                   	push   %edi
  801049:	54                   	push   %esp
  80104a:	5d                   	pop    %ebp
  80104b:	8d 35 53 10 80 00    	lea    0x801053,%esi
  801051:	0f 34                	sysenter 
  801053:	5f                   	pop    %edi
  801054:	5e                   	pop    %esi
  801055:	5d                   	pop    %ebp
  801056:	5c                   	pop    %esp
  801057:	5b                   	pop    %ebx
  801058:	5a                   	pop    %edx
  801059:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80105a:	85 c0                	test   %eax,%eax
  80105c:	7e 28                	jle    801086 <sys_env_set_pgfault_upcall+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  80105e:	89 44 24 10          	mov    %eax,0x10(%esp)
  801062:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  801069:	00 
  80106a:	c7 44 24 08 44 19 80 	movl   $0x801944,0x8(%esp)
  801071:	00 
  801072:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801079:	00 
  80107a:	c7 04 24 61 19 80 00 	movl   $0x801961,(%esp)
  801081:	e8 ea 02 00 00       	call   801370 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801086:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801089:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80108c:	89 ec                	mov    %ebp,%esp
  80108e:	5d                   	pop    %ebp
  80108f:	c3                   	ret    

00801090 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801090:	55                   	push   %ebp
  801091:	89 e5                	mov    %esp,%ebp
  801093:	83 ec 28             	sub    $0x28,%esp
  801096:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801099:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80109c:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010a1:	b8 09 00 00 00       	mov    $0x9,%eax
  8010a6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010a9:	8b 55 08             	mov    0x8(%ebp),%edx
  8010ac:	89 df                	mov    %ebx,%edi
  8010ae:	51                   	push   %ecx
  8010af:	52                   	push   %edx
  8010b0:	53                   	push   %ebx
  8010b1:	54                   	push   %esp
  8010b2:	55                   	push   %ebp
  8010b3:	56                   	push   %esi
  8010b4:	57                   	push   %edi
  8010b5:	54                   	push   %esp
  8010b6:	5d                   	pop    %ebp
  8010b7:	8d 35 bf 10 80 00    	lea    0x8010bf,%esi
  8010bd:	0f 34                	sysenter 
  8010bf:	5f                   	pop    %edi
  8010c0:	5e                   	pop    %esi
  8010c1:	5d                   	pop    %ebp
  8010c2:	5c                   	pop    %esp
  8010c3:	5b                   	pop    %ebx
  8010c4:	5a                   	pop    %edx
  8010c5:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8010c6:	85 c0                	test   %eax,%eax
  8010c8:	7e 28                	jle    8010f2 <sys_env_set_status+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010ca:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010ce:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8010d5:	00 
  8010d6:	c7 44 24 08 44 19 80 	movl   $0x801944,0x8(%esp)
  8010dd:	00 
  8010de:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8010e5:	00 
  8010e6:	c7 04 24 61 19 80 00 	movl   $0x801961,(%esp)
  8010ed:	e8 7e 02 00 00       	call   801370 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8010f2:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8010f5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8010f8:	89 ec                	mov    %ebp,%esp
  8010fa:	5d                   	pop    %ebp
  8010fb:	c3                   	ret    

008010fc <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  8010fc:	55                   	push   %ebp
  8010fd:	89 e5                	mov    %esp,%ebp
  8010ff:	83 ec 28             	sub    $0x28,%esp
  801102:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801105:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801108:	bb 00 00 00 00       	mov    $0x0,%ebx
  80110d:	b8 07 00 00 00       	mov    $0x7,%eax
  801112:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801115:	8b 55 08             	mov    0x8(%ebp),%edx
  801118:	89 df                	mov    %ebx,%edi
  80111a:	51                   	push   %ecx
  80111b:	52                   	push   %edx
  80111c:	53                   	push   %ebx
  80111d:	54                   	push   %esp
  80111e:	55                   	push   %ebp
  80111f:	56                   	push   %esi
  801120:	57                   	push   %edi
  801121:	54                   	push   %esp
  801122:	5d                   	pop    %ebp
  801123:	8d 35 2b 11 80 00    	lea    0x80112b,%esi
  801129:	0f 34                	sysenter 
  80112b:	5f                   	pop    %edi
  80112c:	5e                   	pop    %esi
  80112d:	5d                   	pop    %ebp
  80112e:	5c                   	pop    %esp
  80112f:	5b                   	pop    %ebx
  801130:	5a                   	pop    %edx
  801131:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801132:	85 c0                	test   %eax,%eax
  801134:	7e 28                	jle    80115e <sys_page_unmap+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  801136:	89 44 24 10          	mov    %eax,0x10(%esp)
  80113a:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801141:	00 
  801142:	c7 44 24 08 44 19 80 	movl   $0x801944,0x8(%esp)
  801149:	00 
  80114a:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801151:	00 
  801152:	c7 04 24 61 19 80 00 	movl   $0x801961,(%esp)
  801159:	e8 12 02 00 00       	call   801370 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80115e:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801161:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801164:	89 ec                	mov    %ebp,%esp
  801166:	5d                   	pop    %ebp
  801167:	c3                   	ret    

00801168 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  801168:	55                   	push   %ebp
  801169:	89 e5                	mov    %esp,%ebp
  80116b:	83 ec 28             	sub    $0x28,%esp
  80116e:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801171:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801174:	8b 7d 18             	mov    0x18(%ebp),%edi
  801177:	0b 7d 14             	or     0x14(%ebp),%edi
  80117a:	b8 06 00 00 00       	mov    $0x6,%eax
  80117f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801182:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801185:	8b 55 08             	mov    0x8(%ebp),%edx
  801188:	51                   	push   %ecx
  801189:	52                   	push   %edx
  80118a:	53                   	push   %ebx
  80118b:	54                   	push   %esp
  80118c:	55                   	push   %ebp
  80118d:	56                   	push   %esi
  80118e:	57                   	push   %edi
  80118f:	54                   	push   %esp
  801190:	5d                   	pop    %ebp
  801191:	8d 35 99 11 80 00    	lea    0x801199,%esi
  801197:	0f 34                	sysenter 
  801199:	5f                   	pop    %edi
  80119a:	5e                   	pop    %esi
  80119b:	5d                   	pop    %ebp
  80119c:	5c                   	pop    %esp
  80119d:	5b                   	pop    %ebx
  80119e:	5a                   	pop    %edx
  80119f:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8011a0:	85 c0                	test   %eax,%eax
  8011a2:	7e 28                	jle    8011cc <sys_page_map+0x64>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011a4:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011a8:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  8011af:	00 
  8011b0:	c7 44 24 08 44 19 80 	movl   $0x801944,0x8(%esp)
  8011b7:	00 
  8011b8:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8011bf:	00 
  8011c0:	c7 04 24 61 19 80 00 	movl   $0x801961,(%esp)
  8011c7:	e8 a4 01 00 00       	call   801370 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}
  8011cc:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8011cf:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8011d2:	89 ec                	mov    %ebp,%esp
  8011d4:	5d                   	pop    %ebp
  8011d5:	c3                   	ret    

008011d6 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8011d6:	55                   	push   %ebp
  8011d7:	89 e5                	mov    %esp,%ebp
  8011d9:	83 ec 28             	sub    $0x28,%esp
  8011dc:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8011df:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8011e2:	bf 00 00 00 00       	mov    $0x0,%edi
  8011e7:	b8 05 00 00 00       	mov    $0x5,%eax
  8011ec:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8011ef:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011f2:	8b 55 08             	mov    0x8(%ebp),%edx
  8011f5:	51                   	push   %ecx
  8011f6:	52                   	push   %edx
  8011f7:	53                   	push   %ebx
  8011f8:	54                   	push   %esp
  8011f9:	55                   	push   %ebp
  8011fa:	56                   	push   %esi
  8011fb:	57                   	push   %edi
  8011fc:	54                   	push   %esp
  8011fd:	5d                   	pop    %ebp
  8011fe:	8d 35 06 12 80 00    	lea    0x801206,%esi
  801204:	0f 34                	sysenter 
  801206:	5f                   	pop    %edi
  801207:	5e                   	pop    %esi
  801208:	5d                   	pop    %ebp
  801209:	5c                   	pop    %esp
  80120a:	5b                   	pop    %ebx
  80120b:	5a                   	pop    %edx
  80120c:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80120d:	85 c0                	test   %eax,%eax
  80120f:	7e 28                	jle    801239 <sys_page_alloc+0x63>
		panic("syscall %d returned %d (> 0)", num, ret);
  801211:	89 44 24 10          	mov    %eax,0x10(%esp)
  801215:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  80121c:	00 
  80121d:	c7 44 24 08 44 19 80 	movl   $0x801944,0x8(%esp)
  801224:	00 
  801225:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80122c:	00 
  80122d:	c7 04 24 61 19 80 00 	movl   $0x801961,(%esp)
  801234:	e8 37 01 00 00       	call   801370 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  801239:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80123c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80123f:	89 ec                	mov    %ebp,%esp
  801241:	5d                   	pop    %ebp
  801242:	c3                   	ret    

00801243 <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
{
  801243:	55                   	push   %ebp
  801244:	89 e5                	mov    %esp,%ebp
  801246:	83 ec 08             	sub    $0x8,%esp
  801249:	89 1c 24             	mov    %ebx,(%esp)
  80124c:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801250:	ba 00 00 00 00       	mov    $0x0,%edx
  801255:	b8 0b 00 00 00       	mov    $0xb,%eax
  80125a:	89 d1                	mov    %edx,%ecx
  80125c:	89 d3                	mov    %edx,%ebx
  80125e:	89 d7                	mov    %edx,%edi
  801260:	51                   	push   %ecx
  801261:	52                   	push   %edx
  801262:	53                   	push   %ebx
  801263:	54                   	push   %esp
  801264:	55                   	push   %ebp
  801265:	56                   	push   %esi
  801266:	57                   	push   %edi
  801267:	54                   	push   %esp
  801268:	5d                   	pop    %ebp
  801269:	8d 35 71 12 80 00    	lea    0x801271,%esi
  80126f:	0f 34                	sysenter 
  801271:	5f                   	pop    %edi
  801272:	5e                   	pop    %esi
  801273:	5d                   	pop    %ebp
  801274:	5c                   	pop    %esp
  801275:	5b                   	pop    %ebx
  801276:	5a                   	pop    %edx
  801277:	59                   	pop    %ecx

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  801278:	8b 1c 24             	mov    (%esp),%ebx
  80127b:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80127f:	89 ec                	mov    %ebp,%esp
  801281:	5d                   	pop    %ebp
  801282:	c3                   	ret    

00801283 <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
{
  801283:	55                   	push   %ebp
  801284:	89 e5                	mov    %esp,%ebp
  801286:	83 ec 08             	sub    $0x8,%esp
  801289:	89 1c 24             	mov    %ebx,(%esp)
  80128c:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801290:	bb 00 00 00 00       	mov    $0x0,%ebx
  801295:	b8 04 00 00 00       	mov    $0x4,%eax
  80129a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80129d:	8b 55 08             	mov    0x8(%ebp),%edx
  8012a0:	89 df                	mov    %ebx,%edi
  8012a2:	51                   	push   %ecx
  8012a3:	52                   	push   %edx
  8012a4:	53                   	push   %ebx
  8012a5:	54                   	push   %esp
  8012a6:	55                   	push   %ebp
  8012a7:	56                   	push   %esi
  8012a8:	57                   	push   %edi
  8012a9:	54                   	push   %esp
  8012aa:	5d                   	pop    %ebp
  8012ab:	8d 35 b3 12 80 00    	lea    0x8012b3,%esi
  8012b1:	0f 34                	sysenter 
  8012b3:	5f                   	pop    %edi
  8012b4:	5e                   	pop    %esi
  8012b5:	5d                   	pop    %ebp
  8012b6:	5c                   	pop    %esp
  8012b7:	5b                   	pop    %ebx
  8012b8:	5a                   	pop    %edx
  8012b9:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  8012ba:	8b 1c 24             	mov    (%esp),%ebx
  8012bd:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8012c1:	89 ec                	mov    %ebp,%esp
  8012c3:	5d                   	pop    %ebp
  8012c4:	c3                   	ret    

008012c5 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  8012c5:	55                   	push   %ebp
  8012c6:	89 e5                	mov    %esp,%ebp
  8012c8:	83 ec 08             	sub    $0x8,%esp
  8012cb:	89 1c 24             	mov    %ebx,(%esp)
  8012ce:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8012d2:	ba 00 00 00 00       	mov    $0x0,%edx
  8012d7:	b8 02 00 00 00       	mov    $0x2,%eax
  8012dc:	89 d1                	mov    %edx,%ecx
  8012de:	89 d3                	mov    %edx,%ebx
  8012e0:	89 d7                	mov    %edx,%edi
  8012e2:	51                   	push   %ecx
  8012e3:	52                   	push   %edx
  8012e4:	53                   	push   %ebx
  8012e5:	54                   	push   %esp
  8012e6:	55                   	push   %ebp
  8012e7:	56                   	push   %esi
  8012e8:	57                   	push   %edi
  8012e9:	54                   	push   %esp
  8012ea:	5d                   	pop    %ebp
  8012eb:	8d 35 f3 12 80 00    	lea    0x8012f3,%esi
  8012f1:	0f 34                	sysenter 
  8012f3:	5f                   	pop    %edi
  8012f4:	5e                   	pop    %esi
  8012f5:	5d                   	pop    %ebp
  8012f6:	5c                   	pop    %esp
  8012f7:	5b                   	pop    %ebx
  8012f8:	5a                   	pop    %edx
  8012f9:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8012fa:	8b 1c 24             	mov    (%esp),%ebx
  8012fd:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801301:	89 ec                	mov    %ebp,%esp
  801303:	5d                   	pop    %ebp
  801304:	c3                   	ret    

00801305 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  801305:	55                   	push   %ebp
  801306:	89 e5                	mov    %esp,%ebp
  801308:	83 ec 28             	sub    $0x28,%esp
  80130b:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80130e:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801311:	b9 00 00 00 00       	mov    $0x0,%ecx
  801316:	b8 03 00 00 00       	mov    $0x3,%eax
  80131b:	8b 55 08             	mov    0x8(%ebp),%edx
  80131e:	89 cb                	mov    %ecx,%ebx
  801320:	89 cf                	mov    %ecx,%edi
  801322:	51                   	push   %ecx
  801323:	52                   	push   %edx
  801324:	53                   	push   %ebx
  801325:	54                   	push   %esp
  801326:	55                   	push   %ebp
  801327:	56                   	push   %esi
  801328:	57                   	push   %edi
  801329:	54                   	push   %esp
  80132a:	5d                   	pop    %ebp
  80132b:	8d 35 33 13 80 00    	lea    0x801333,%esi
  801331:	0f 34                	sysenter 
  801333:	5f                   	pop    %edi
  801334:	5e                   	pop    %esi
  801335:	5d                   	pop    %ebp
  801336:	5c                   	pop    %esp
  801337:	5b                   	pop    %ebx
  801338:	5a                   	pop    %edx
  801339:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80133a:	85 c0                	test   %eax,%eax
  80133c:	7e 28                	jle    801366 <sys_env_destroy+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  80133e:	89 44 24 10          	mov    %eax,0x10(%esp)
  801342:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  801349:	00 
  80134a:	c7 44 24 08 44 19 80 	movl   $0x801944,0x8(%esp)
  801351:	00 
  801352:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801359:	00 
  80135a:	c7 04 24 61 19 80 00 	movl   $0x801961,(%esp)
  801361:	e8 0a 00 00 00       	call   801370 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801366:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801369:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80136c:	89 ec                	mov    %ebp,%esp
  80136e:	5d                   	pop    %ebp
  80136f:	c3                   	ret    

00801370 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801370:	55                   	push   %ebp
  801371:	89 e5                	mov    %esp,%ebp
  801373:	56                   	push   %esi
  801374:	53                   	push   %ebx
  801375:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  801378:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	if (argv0)
  80137b:	a1 0c 20 80 00       	mov    0x80200c,%eax
  801380:	85 c0                	test   %eax,%eax
  801382:	74 10                	je     801394 <_panic+0x24>
		cprintf("%s: ", argv0);
  801384:	89 44 24 04          	mov    %eax,0x4(%esp)
  801388:	c7 04 24 6f 19 80 00 	movl   $0x80196f,(%esp)
  80138f:	e8 9d ed ff ff       	call   800131 <cprintf>
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801394:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  80139a:	e8 26 ff ff ff       	call   8012c5 <sys_getenvid>
  80139f:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013a2:	89 54 24 10          	mov    %edx,0x10(%esp)
  8013a6:	8b 55 08             	mov    0x8(%ebp),%edx
  8013a9:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8013ad:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8013b1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013b5:	c7 04 24 74 19 80 00 	movl   $0x801974,(%esp)
  8013bc:	e8 70 ed ff ff       	call   800131 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8013c1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8013c5:	8b 45 10             	mov    0x10(%ebp),%eax
  8013c8:	89 04 24             	mov    %eax,(%esp)
  8013cb:	e8 00 ed ff ff       	call   8000d0 <vcprintf>
	cprintf("\n");
  8013d0:	c7 04 24 6c 16 80 00 	movl   $0x80166c,(%esp)
  8013d7:	e8 55 ed ff ff       	call   800131 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8013dc:	cc                   	int3   
  8013dd:	eb fd                	jmp    8013dc <_panic+0x6c>
	...

008013e0 <__udivdi3>:
  8013e0:	55                   	push   %ebp
  8013e1:	89 e5                	mov    %esp,%ebp
  8013e3:	57                   	push   %edi
  8013e4:	56                   	push   %esi
  8013e5:	83 ec 10             	sub    $0x10,%esp
  8013e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8013eb:	8b 55 08             	mov    0x8(%ebp),%edx
  8013ee:	8b 75 10             	mov    0x10(%ebp),%esi
  8013f1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8013f4:	85 c0                	test   %eax,%eax
  8013f6:	89 55 f0             	mov    %edx,-0x10(%ebp)
  8013f9:	75 35                	jne    801430 <__udivdi3+0x50>
  8013fb:	39 fe                	cmp    %edi,%esi
  8013fd:	77 61                	ja     801460 <__udivdi3+0x80>
  8013ff:	85 f6                	test   %esi,%esi
  801401:	75 0b                	jne    80140e <__udivdi3+0x2e>
  801403:	b8 01 00 00 00       	mov    $0x1,%eax
  801408:	31 d2                	xor    %edx,%edx
  80140a:	f7 f6                	div    %esi
  80140c:	89 c6                	mov    %eax,%esi
  80140e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  801411:	31 d2                	xor    %edx,%edx
  801413:	89 f8                	mov    %edi,%eax
  801415:	f7 f6                	div    %esi
  801417:	89 c7                	mov    %eax,%edi
  801419:	89 c8                	mov    %ecx,%eax
  80141b:	f7 f6                	div    %esi
  80141d:	89 c1                	mov    %eax,%ecx
  80141f:	89 fa                	mov    %edi,%edx
  801421:	89 c8                	mov    %ecx,%eax
  801423:	83 c4 10             	add    $0x10,%esp
  801426:	5e                   	pop    %esi
  801427:	5f                   	pop    %edi
  801428:	5d                   	pop    %ebp
  801429:	c3                   	ret    
  80142a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801430:	39 f8                	cmp    %edi,%eax
  801432:	77 1c                	ja     801450 <__udivdi3+0x70>
  801434:	0f bd d0             	bsr    %eax,%edx
  801437:	83 f2 1f             	xor    $0x1f,%edx
  80143a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80143d:	75 39                	jne    801478 <__udivdi3+0x98>
  80143f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  801442:	0f 86 a0 00 00 00    	jbe    8014e8 <__udivdi3+0x108>
  801448:	39 f8                	cmp    %edi,%eax
  80144a:	0f 82 98 00 00 00    	jb     8014e8 <__udivdi3+0x108>
  801450:	31 ff                	xor    %edi,%edi
  801452:	31 c9                	xor    %ecx,%ecx
  801454:	89 c8                	mov    %ecx,%eax
  801456:	89 fa                	mov    %edi,%edx
  801458:	83 c4 10             	add    $0x10,%esp
  80145b:	5e                   	pop    %esi
  80145c:	5f                   	pop    %edi
  80145d:	5d                   	pop    %ebp
  80145e:	c3                   	ret    
  80145f:	90                   	nop
  801460:	89 d1                	mov    %edx,%ecx
  801462:	89 fa                	mov    %edi,%edx
  801464:	89 c8                	mov    %ecx,%eax
  801466:	31 ff                	xor    %edi,%edi
  801468:	f7 f6                	div    %esi
  80146a:	89 c1                	mov    %eax,%ecx
  80146c:	89 fa                	mov    %edi,%edx
  80146e:	89 c8                	mov    %ecx,%eax
  801470:	83 c4 10             	add    $0x10,%esp
  801473:	5e                   	pop    %esi
  801474:	5f                   	pop    %edi
  801475:	5d                   	pop    %ebp
  801476:	c3                   	ret    
  801477:	90                   	nop
  801478:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80147c:	89 f2                	mov    %esi,%edx
  80147e:	d3 e0                	shl    %cl,%eax
  801480:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801483:	b8 20 00 00 00       	mov    $0x20,%eax
  801488:	2b 45 f4             	sub    -0xc(%ebp),%eax
  80148b:	89 c1                	mov    %eax,%ecx
  80148d:	d3 ea                	shr    %cl,%edx
  80148f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801493:	0b 55 ec             	or     -0x14(%ebp),%edx
  801496:	d3 e6                	shl    %cl,%esi
  801498:	89 c1                	mov    %eax,%ecx
  80149a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  80149d:	89 fe                	mov    %edi,%esi
  80149f:	d3 ee                	shr    %cl,%esi
  8014a1:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8014a5:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8014a8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8014ab:	d3 e7                	shl    %cl,%edi
  8014ad:	89 c1                	mov    %eax,%ecx
  8014af:	d3 ea                	shr    %cl,%edx
  8014b1:	09 d7                	or     %edx,%edi
  8014b3:	89 f2                	mov    %esi,%edx
  8014b5:	89 f8                	mov    %edi,%eax
  8014b7:	f7 75 ec             	divl   -0x14(%ebp)
  8014ba:	89 d6                	mov    %edx,%esi
  8014bc:	89 c7                	mov    %eax,%edi
  8014be:	f7 65 e8             	mull   -0x18(%ebp)
  8014c1:	39 d6                	cmp    %edx,%esi
  8014c3:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8014c6:	72 30                	jb     8014f8 <__udivdi3+0x118>
  8014c8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8014cb:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8014cf:	d3 e2                	shl    %cl,%edx
  8014d1:	39 c2                	cmp    %eax,%edx
  8014d3:	73 05                	jae    8014da <__udivdi3+0xfa>
  8014d5:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  8014d8:	74 1e                	je     8014f8 <__udivdi3+0x118>
  8014da:	89 f9                	mov    %edi,%ecx
  8014dc:	31 ff                	xor    %edi,%edi
  8014de:	e9 71 ff ff ff       	jmp    801454 <__udivdi3+0x74>
  8014e3:	90                   	nop
  8014e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8014e8:	31 ff                	xor    %edi,%edi
  8014ea:	b9 01 00 00 00       	mov    $0x1,%ecx
  8014ef:	e9 60 ff ff ff       	jmp    801454 <__udivdi3+0x74>
  8014f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8014f8:	8d 4f ff             	lea    -0x1(%edi),%ecx
  8014fb:	31 ff                	xor    %edi,%edi
  8014fd:	89 c8                	mov    %ecx,%eax
  8014ff:	89 fa                	mov    %edi,%edx
  801501:	83 c4 10             	add    $0x10,%esp
  801504:	5e                   	pop    %esi
  801505:	5f                   	pop    %edi
  801506:	5d                   	pop    %ebp
  801507:	c3                   	ret    
	...

00801510 <__umoddi3>:
  801510:	55                   	push   %ebp
  801511:	89 e5                	mov    %esp,%ebp
  801513:	57                   	push   %edi
  801514:	56                   	push   %esi
  801515:	83 ec 20             	sub    $0x20,%esp
  801518:	8b 55 14             	mov    0x14(%ebp),%edx
  80151b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80151e:	8b 7d 10             	mov    0x10(%ebp),%edi
  801521:	8b 75 0c             	mov    0xc(%ebp),%esi
  801524:	85 d2                	test   %edx,%edx
  801526:	89 c8                	mov    %ecx,%eax
  801528:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80152b:	75 13                	jne    801540 <__umoddi3+0x30>
  80152d:	39 f7                	cmp    %esi,%edi
  80152f:	76 3f                	jbe    801570 <__umoddi3+0x60>
  801531:	89 f2                	mov    %esi,%edx
  801533:	f7 f7                	div    %edi
  801535:	89 d0                	mov    %edx,%eax
  801537:	31 d2                	xor    %edx,%edx
  801539:	83 c4 20             	add    $0x20,%esp
  80153c:	5e                   	pop    %esi
  80153d:	5f                   	pop    %edi
  80153e:	5d                   	pop    %ebp
  80153f:	c3                   	ret    
  801540:	39 f2                	cmp    %esi,%edx
  801542:	77 4c                	ja     801590 <__umoddi3+0x80>
  801544:	0f bd ca             	bsr    %edx,%ecx
  801547:	83 f1 1f             	xor    $0x1f,%ecx
  80154a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80154d:	75 51                	jne    8015a0 <__umoddi3+0x90>
  80154f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  801552:	0f 87 e0 00 00 00    	ja     801638 <__umoddi3+0x128>
  801558:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80155b:	29 f8                	sub    %edi,%eax
  80155d:	19 d6                	sbb    %edx,%esi
  80155f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801562:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801565:	89 f2                	mov    %esi,%edx
  801567:	83 c4 20             	add    $0x20,%esp
  80156a:	5e                   	pop    %esi
  80156b:	5f                   	pop    %edi
  80156c:	5d                   	pop    %ebp
  80156d:	c3                   	ret    
  80156e:	66 90                	xchg   %ax,%ax
  801570:	85 ff                	test   %edi,%edi
  801572:	75 0b                	jne    80157f <__umoddi3+0x6f>
  801574:	b8 01 00 00 00       	mov    $0x1,%eax
  801579:	31 d2                	xor    %edx,%edx
  80157b:	f7 f7                	div    %edi
  80157d:	89 c7                	mov    %eax,%edi
  80157f:	89 f0                	mov    %esi,%eax
  801581:	31 d2                	xor    %edx,%edx
  801583:	f7 f7                	div    %edi
  801585:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801588:	f7 f7                	div    %edi
  80158a:	eb a9                	jmp    801535 <__umoddi3+0x25>
  80158c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801590:	89 c8                	mov    %ecx,%eax
  801592:	89 f2                	mov    %esi,%edx
  801594:	83 c4 20             	add    $0x20,%esp
  801597:	5e                   	pop    %esi
  801598:	5f                   	pop    %edi
  801599:	5d                   	pop    %ebp
  80159a:	c3                   	ret    
  80159b:	90                   	nop
  80159c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8015a0:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8015a4:	d3 e2                	shl    %cl,%edx
  8015a6:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8015a9:	ba 20 00 00 00       	mov    $0x20,%edx
  8015ae:	2b 55 f0             	sub    -0x10(%ebp),%edx
  8015b1:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8015b4:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8015b8:	89 fa                	mov    %edi,%edx
  8015ba:	d3 ea                	shr    %cl,%edx
  8015bc:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8015c0:	0b 55 f4             	or     -0xc(%ebp),%edx
  8015c3:	d3 e7                	shl    %cl,%edi
  8015c5:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8015c9:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8015cc:	89 f2                	mov    %esi,%edx
  8015ce:	89 7d e8             	mov    %edi,-0x18(%ebp)
  8015d1:	89 c7                	mov    %eax,%edi
  8015d3:	d3 ea                	shr    %cl,%edx
  8015d5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8015d9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8015dc:	89 c2                	mov    %eax,%edx
  8015de:	d3 e6                	shl    %cl,%esi
  8015e0:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8015e4:	d3 ea                	shr    %cl,%edx
  8015e6:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8015ea:	09 d6                	or     %edx,%esi
  8015ec:	89 f0                	mov    %esi,%eax
  8015ee:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8015f1:	d3 e7                	shl    %cl,%edi
  8015f3:	89 f2                	mov    %esi,%edx
  8015f5:	f7 75 f4             	divl   -0xc(%ebp)
  8015f8:	89 d6                	mov    %edx,%esi
  8015fa:	f7 65 e8             	mull   -0x18(%ebp)
  8015fd:	39 d6                	cmp    %edx,%esi
  8015ff:	72 2b                	jb     80162c <__umoddi3+0x11c>
  801601:	39 c7                	cmp    %eax,%edi
  801603:	72 23                	jb     801628 <__umoddi3+0x118>
  801605:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801609:	29 c7                	sub    %eax,%edi
  80160b:	19 d6                	sbb    %edx,%esi
  80160d:	89 f0                	mov    %esi,%eax
  80160f:	89 f2                	mov    %esi,%edx
  801611:	d3 ef                	shr    %cl,%edi
  801613:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801617:	d3 e0                	shl    %cl,%eax
  801619:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80161d:	09 f8                	or     %edi,%eax
  80161f:	d3 ea                	shr    %cl,%edx
  801621:	83 c4 20             	add    $0x20,%esp
  801624:	5e                   	pop    %esi
  801625:	5f                   	pop    %edi
  801626:	5d                   	pop    %ebp
  801627:	c3                   	ret    
  801628:	39 d6                	cmp    %edx,%esi
  80162a:	75 d9                	jne    801605 <__umoddi3+0xf5>
  80162c:	2b 45 e8             	sub    -0x18(%ebp),%eax
  80162f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  801632:	eb d1                	jmp    801605 <__umoddi3+0xf5>
  801634:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801638:	39 f2                	cmp    %esi,%edx
  80163a:	0f 82 18 ff ff ff    	jb     801558 <__umoddi3+0x48>
  801640:	e9 1d ff ff ff       	jmp    801562 <__umoddi3+0x52>
