
obj/user/hello.debug:     file format elf32-i386


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
  80002c:	e8 2f 00 00 00       	call   800060 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:
// hello, world
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	cprintf("hello, world\n");
  80003a:	c7 04 24 60 27 80 00 	movl   $0x802760,(%esp)
  800041:	e8 eb 00 00 00       	call   800131 <cprintf>
	cprintf("i am environment %08x\n", thisenv->env_id);
  800046:	a1 08 40 80 00       	mov    0x804008,%eax
  80004b:	8b 40 48             	mov    0x48(%eax),%eax
  80004e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800052:	c7 04 24 6e 27 80 00 	movl   $0x80276e,(%esp)
  800059:	e8 d3 00 00 00       	call   800131 <cprintf>
}
  80005e:	c9                   	leave  
  80005f:	c3                   	ret    

00800060 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800060:	55                   	push   %ebp
  800061:	89 e5                	mov    %esp,%ebp
  800063:	83 ec 18             	sub    $0x18,%esp
  800066:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800069:	89 75 fc             	mov    %esi,-0x4(%ebp)
  80006c:	8b 75 08             	mov    0x8(%ebp),%esi
  80006f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  800072:	e8 00 14 00 00       	call   801477 <sys_getenvid>
  800077:	25 ff 03 00 00       	and    $0x3ff,%eax
  80007c:	89 c2                	mov    %eax,%edx
  80007e:	c1 e2 07             	shl    $0x7,%edx
  800081:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  800088:	a3 08 40 80 00       	mov    %eax,0x804008
        //cprintf("ENVX sys_get_envid(): %d\n",ENVX(sys_getenvid()));
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80008d:	85 f6                	test   %esi,%esi
  80008f:	7e 07                	jle    800098 <libmain+0x38>
		binaryname = argv[0];
  800091:	8b 03                	mov    (%ebx),%eax
  800093:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800098:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80009c:	89 34 24             	mov    %esi,(%esp)
  80009f:	e8 90 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000a4:	e8 0b 00 00 00       	call   8000b4 <exit>
}
  8000a9:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8000ac:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8000af:	89 ec                	mov    %ebp,%esp
  8000b1:	5d                   	pop    %ebp
  8000b2:	c3                   	ret    
	...

008000b4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000b4:	55                   	push   %ebp
  8000b5:	89 e5                	mov    %esp,%ebp
  8000b7:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8000ba:	e8 4c 19 00 00       	call   801a0b <close_all>
	sys_env_destroy(0);
  8000bf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000c6:	e8 ec 13 00 00       	call   8014b7 <sys_env_destroy>
}
  8000cb:	c9                   	leave  
  8000cc:	c3                   	ret    
  8000cd:	00 00                	add    %al,(%eax)
	...

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
  8001ff:	e8 dc 22 00 00       	call   8024e0 <__udivdi3>
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
  800267:	e8 a4 23 00 00       	call   802610 <__umoddi3>
  80026c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800270:	0f be 80 8f 27 80 00 	movsbl 0x80278f(%eax),%eax
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
  80035a:	ff 24 95 60 29 80 00 	jmp    *0x802960(,%edx,4)
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
  800412:	83 f8 0f             	cmp    $0xf,%eax
  800415:	7f 0b                	jg     800422 <vprintfmt+0x146>
  800417:	8b 14 85 c0 2a 80 00 	mov    0x802ac0(,%eax,4),%edx
  80041e:	85 d2                	test   %edx,%edx
  800420:	75 26                	jne    800448 <vprintfmt+0x16c>
				printfmt(putch, putdat, "error %d", err);
  800422:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800426:	c7 44 24 08 a0 27 80 	movl   $0x8027a0,0x8(%esp)
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
  80044c:	c7 44 24 08 de 2b 80 	movl   $0x802bde,0x8(%esp)
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
  80048a:	be a9 27 80 00       	mov    $0x8027a9,%esi
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
  800734:	e8 a7 1d 00 00       	call   8024e0 <__udivdi3>
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
  800780:	e8 8b 1e 00 00       	call   802610 <__umoddi3>
  800785:	89 74 24 04          	mov    %esi,0x4(%esp)
  800789:	0f be 80 8f 27 80 00 	movsbl 0x80278f(%eax),%eax
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
  800835:	c7 44 24 0c c4 28 80 	movl   $0x8028c4,0xc(%esp)
  80083c:	00 
  80083d:	c7 44 24 08 de 2b 80 	movl   $0x802bde,0x8(%esp)
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
  80086b:	c7 44 24 0c fc 28 80 	movl   $0x8028fc,0xc(%esp)
  800872:	00 
  800873:	c7 44 24 08 de 2b 80 	movl   $0x802bde,0x8(%esp)
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
  8008ff:	e8 0c 1d 00 00       	call   802610 <__umoddi3>
  800904:	89 74 24 04          	mov    %esi,0x4(%esp)
  800908:	0f be 80 8f 27 80 00 	movsbl 0x80278f(%eax),%eax
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
  800941:	e8 ca 1c 00 00       	call   802610 <__umoddi3>
  800946:	89 74 24 04          	mov    %esi,0x4(%esp)
  80094a:	0f be 80 8f 27 80 00 	movsbl 0x80278f(%eax),%eax
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

00800ecb <sys_get_mac>:
sys_receive_packet(uint32_t addr,int* len){
         return syscall(SYS_receive_packet,0,(uint32_t)addr,(uint32_t)len,0,0,0);
}

int 
sys_get_mac(uint8_t* macaddr){
  800ecb:	55                   	push   %ebp
  800ecc:	89 e5                	mov    %esp,%ebp
  800ece:	83 ec 08             	sub    $0x8,%esp
  800ed1:	89 1c 24             	mov    %ebx,(%esp)
  800ed4:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800ed8:	b9 00 00 00 00       	mov    $0x0,%ecx
  800edd:	b8 13 00 00 00       	mov    $0x13,%eax
  800ee2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ee5:	89 cb                	mov    %ecx,%ebx
  800ee7:	89 cf                	mov    %ecx,%edi
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
}

int 
sys_get_mac(uint8_t* macaddr){
         return syscall(SYS_get_mac,0,(uint32_t)macaddr,0,0,0,0);
}
  800f01:	8b 1c 24             	mov    (%esp),%ebx
  800f04:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800f08:	89 ec                	mov    %ebp,%esp
  800f0a:	5d                   	pop    %ebp
  800f0b:	c3                   	ret    

00800f0c <sys_receive_packet>:
sys_transmit_packet(uint32_t addr,int len){
         return syscall(SYS_transmit_packet,0,(uint32_t)addr,(uint32_t)len,0,0,0);
}

int 
sys_receive_packet(uint32_t addr,int* len){
  800f0c:	55                   	push   %ebp
  800f0d:	89 e5                	mov    %esp,%ebp
  800f0f:	83 ec 08             	sub    $0x8,%esp
  800f12:	89 1c 24             	mov    %ebx,(%esp)
  800f15:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800f19:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f1e:	b8 12 00 00 00       	mov    $0x12,%eax
  800f23:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f26:	8b 55 08             	mov    0x8(%ebp),%edx
  800f29:	89 df                	mov    %ebx,%edi
  800f2b:	51                   	push   %ecx
  800f2c:	52                   	push   %edx
  800f2d:	53                   	push   %ebx
  800f2e:	54                   	push   %esp
  800f2f:	55                   	push   %ebp
  800f30:	56                   	push   %esi
  800f31:	57                   	push   %edi
  800f32:	54                   	push   %esp
  800f33:	5d                   	pop    %ebp
  800f34:	8d 35 3c 0f 80 00    	lea    0x800f3c,%esi
  800f3a:	0f 34                	sysenter 
  800f3c:	5f                   	pop    %edi
  800f3d:	5e                   	pop    %esi
  800f3e:	5d                   	pop    %ebp
  800f3f:	5c                   	pop    %esp
  800f40:	5b                   	pop    %ebx
  800f41:	5a                   	pop    %edx
  800f42:	59                   	pop    %ecx
}

int 
sys_receive_packet(uint32_t addr,int* len){
         return syscall(SYS_receive_packet,0,(uint32_t)addr,(uint32_t)len,0,0,0);
}
  800f43:	8b 1c 24             	mov    (%esp),%ebx
  800f46:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800f4a:	89 ec                	mov    %ebp,%esp
  800f4c:	5d                   	pop    %ebp
  800f4d:	c3                   	ret    

00800f4e <sys_transmit_packet>:
sys_exec(void* vph, uint32_t phnum, uint32_t esp, uint32_t eip){
         return syscall(SYS_exec, 0, (uint32_t)vph, phnum, esp, eip, 0);
}

int 
sys_transmit_packet(uint32_t addr,int len){
  800f4e:	55                   	push   %ebp
  800f4f:	89 e5                	mov    %esp,%ebp
  800f51:	83 ec 08             	sub    $0x8,%esp
  800f54:	89 1c 24             	mov    %ebx,(%esp)
  800f57:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800f5b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f60:	b8 11 00 00 00       	mov    $0x11,%eax
  800f65:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f68:	8b 55 08             	mov    0x8(%ebp),%edx
  800f6b:	89 df                	mov    %ebx,%edi
  800f6d:	51                   	push   %ecx
  800f6e:	52                   	push   %edx
  800f6f:	53                   	push   %ebx
  800f70:	54                   	push   %esp
  800f71:	55                   	push   %ebp
  800f72:	56                   	push   %esi
  800f73:	57                   	push   %edi
  800f74:	54                   	push   %esp
  800f75:	5d                   	pop    %ebp
  800f76:	8d 35 7e 0f 80 00    	lea    0x800f7e,%esi
  800f7c:	0f 34                	sysenter 
  800f7e:	5f                   	pop    %edi
  800f7f:	5e                   	pop    %esi
  800f80:	5d                   	pop    %ebp
  800f81:	5c                   	pop    %esp
  800f82:	5b                   	pop    %ebx
  800f83:	5a                   	pop    %edx
  800f84:	59                   	pop    %ecx
}

int 
sys_transmit_packet(uint32_t addr,int len){
         return syscall(SYS_transmit_packet,0,(uint32_t)addr,(uint32_t)len,0,0,0);
}
  800f85:	8b 1c 24             	mov    (%esp),%ebx
  800f88:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800f8c:	89 ec                	mov    %ebp,%esp
  800f8e:	5d                   	pop    %ebp
  800f8f:	c3                   	ret    

00800f90 <sys_exec>:
sys_env_set_prior(envid_t envid, uint32_t prior){
         return syscall(SYS_env_set_prior,1,envid, prior, 0, 0, 0);
}

int 
sys_exec(void* vph, uint32_t phnum, uint32_t esp, uint32_t eip){
  800f90:	55                   	push   %ebp
  800f91:	89 e5                	mov    %esp,%ebp
  800f93:	83 ec 08             	sub    $0x8,%esp
  800f96:	89 1c 24             	mov    %ebx,(%esp)
  800f99:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800f9d:	b8 10 00 00 00       	mov    $0x10,%eax
  800fa2:	8b 7d 14             	mov    0x14(%ebp),%edi
  800fa5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800fa8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fab:	8b 55 08             	mov    0x8(%ebp),%edx
  800fae:	51                   	push   %ecx
  800faf:	52                   	push   %edx
  800fb0:	53                   	push   %ebx
  800fb1:	54                   	push   %esp
  800fb2:	55                   	push   %ebp
  800fb3:	56                   	push   %esi
  800fb4:	57                   	push   %edi
  800fb5:	54                   	push   %esp
  800fb6:	5d                   	pop    %ebp
  800fb7:	8d 35 bf 0f 80 00    	lea    0x800fbf,%esi
  800fbd:	0f 34                	sysenter 
  800fbf:	5f                   	pop    %edi
  800fc0:	5e                   	pop    %esi
  800fc1:	5d                   	pop    %ebp
  800fc2:	5c                   	pop    %esp
  800fc3:	5b                   	pop    %ebx
  800fc4:	5a                   	pop    %edx
  800fc5:	59                   	pop    %ecx
}

int 
sys_exec(void* vph, uint32_t phnum, uint32_t esp, uint32_t eip){
         return syscall(SYS_exec, 0, (uint32_t)vph, phnum, esp, eip, 0);
}
  800fc6:	8b 1c 24             	mov    (%esp),%ebx
  800fc9:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800fcd:	89 ec                	mov    %ebp,%esp
  800fcf:	5d                   	pop    %ebp
  800fd0:	c3                   	ret    

00800fd1 <sys_env_set_prior>:
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}


int 
sys_env_set_prior(envid_t envid, uint32_t prior){
  800fd1:	55                   	push   %ebp
  800fd2:	89 e5                	mov    %esp,%ebp
  800fd4:	83 ec 28             	sub    $0x28,%esp
  800fd7:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800fda:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800fdd:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fe2:	b8 0f 00 00 00       	mov    $0xf,%eax
  800fe7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fea:	8b 55 08             	mov    0x8(%ebp),%edx
  800fed:	89 df                	mov    %ebx,%edi
  800fef:	51                   	push   %ecx
  800ff0:	52                   	push   %edx
  800ff1:	53                   	push   %ebx
  800ff2:	54                   	push   %esp
  800ff3:	55                   	push   %ebp
  800ff4:	56                   	push   %esi
  800ff5:	57                   	push   %edi
  800ff6:	54                   	push   %esp
  800ff7:	5d                   	pop    %ebp
  800ff8:	8d 35 00 10 80 00    	lea    0x801000,%esi
  800ffe:	0f 34                	sysenter 
  801000:	5f                   	pop    %edi
  801001:	5e                   	pop    %esi
  801002:	5d                   	pop    %ebp
  801003:	5c                   	pop    %esp
  801004:	5b                   	pop    %ebx
  801005:	5a                   	pop    %edx
  801006:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801007:	85 c0                	test   %eax,%eax
  801009:	7e 28                	jle    801033 <sys_env_set_prior+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  80100b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80100f:	c7 44 24 0c 0f 00 00 	movl   $0xf,0xc(%esp)
  801016:	00 
  801017:	c7 44 24 08 00 2b 80 	movl   $0x802b00,0x8(%esp)
  80101e:	00 
  80101f:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801026:	00 
  801027:	c7 04 24 1d 2b 80 00 	movl   $0x802b1d,(%esp)
  80102e:	e8 d1 12 00 00       	call   802304 <_panic>


int 
sys_env_set_prior(envid_t envid, uint32_t prior){
         return syscall(SYS_env_set_prior,1,envid, prior, 0, 0, 0);
}
  801033:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801036:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801039:	89 ec                	mov    %ebp,%esp
  80103b:	5d                   	pop    %ebp
  80103c:	c3                   	ret    

0080103d <sys_time_msec>:
}


unsigned int
sys_time_msec(void)
{
  80103d:	55                   	push   %ebp
  80103e:	89 e5                	mov    %esp,%ebp
  801040:	83 ec 08             	sub    $0x8,%esp
  801043:	89 1c 24             	mov    %ebx,(%esp)
  801046:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80104a:	ba 00 00 00 00       	mov    $0x0,%edx
  80104f:	b8 15 00 00 00       	mov    $0x15,%eax
  801054:	89 d1                	mov    %edx,%ecx
  801056:	89 d3                	mov    %edx,%ebx
  801058:	89 d7                	mov    %edx,%edi
  80105a:	51                   	push   %ecx
  80105b:	52                   	push   %edx
  80105c:	53                   	push   %ebx
  80105d:	54                   	push   %esp
  80105e:	55                   	push   %ebp
  80105f:	56                   	push   %esi
  801060:	57                   	push   %edi
  801061:	54                   	push   %esp
  801062:	5d                   	pop    %ebp
  801063:	8d 35 6b 10 80 00    	lea    0x80106b,%esi
  801069:	0f 34                	sysenter 
  80106b:	5f                   	pop    %edi
  80106c:	5e                   	pop    %esi
  80106d:	5d                   	pop    %ebp
  80106e:	5c                   	pop    %esp
  80106f:	5b                   	pop    %ebx
  801070:	5a                   	pop    %edx
  801071:	59                   	pop    %ecx

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  801072:	8b 1c 24             	mov    (%esp),%ebx
  801075:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801079:	89 ec                	mov    %ebp,%esp
  80107b:	5d                   	pop    %ebp
  80107c:	c3                   	ret    

0080107d <sys_sbrk>:
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}

int
sys_sbrk(uint32_t inc)
{
  80107d:	55                   	push   %ebp
  80107e:	89 e5                	mov    %esp,%ebp
  801080:	83 ec 08             	sub    $0x8,%esp
  801083:	89 1c 24             	mov    %ebx,(%esp)
  801086:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80108a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80108f:	b8 14 00 00 00       	mov    $0x14,%eax
  801094:	8b 55 08             	mov    0x8(%ebp),%edx
  801097:	89 cb                	mov    %ecx,%ebx
  801099:	89 cf                	mov    %ecx,%edi
  80109b:	51                   	push   %ecx
  80109c:	52                   	push   %edx
  80109d:	53                   	push   %ebx
  80109e:	54                   	push   %esp
  80109f:	55                   	push   %ebp
  8010a0:	56                   	push   %esi
  8010a1:	57                   	push   %edi
  8010a2:	54                   	push   %esp
  8010a3:	5d                   	pop    %ebp
  8010a4:	8d 35 ac 10 80 00    	lea    0x8010ac,%esi
  8010aa:	0f 34                	sysenter 
  8010ac:	5f                   	pop    %edi
  8010ad:	5e                   	pop    %esi
  8010ae:	5d                   	pop    %ebp
  8010af:	5c                   	pop    %esp
  8010b0:	5b                   	pop    %ebx
  8010b1:	5a                   	pop    %edx
  8010b2:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  8010b3:	8b 1c 24             	mov    (%esp),%ebx
  8010b6:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8010ba:	89 ec                	mov    %ebp,%esp
  8010bc:	5d                   	pop    %ebp
  8010bd:	c3                   	ret    

008010be <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  8010be:	55                   	push   %ebp
  8010bf:	89 e5                	mov    %esp,%ebp
  8010c1:	83 ec 28             	sub    $0x28,%esp
  8010c4:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8010c7:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8010ca:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010cf:	b8 0e 00 00 00       	mov    $0xe,%eax
  8010d4:	8b 55 08             	mov    0x8(%ebp),%edx
  8010d7:	89 cb                	mov    %ecx,%ebx
  8010d9:	89 cf                	mov    %ecx,%edi
  8010db:	51                   	push   %ecx
  8010dc:	52                   	push   %edx
  8010dd:	53                   	push   %ebx
  8010de:	54                   	push   %esp
  8010df:	55                   	push   %ebp
  8010e0:	56                   	push   %esi
  8010e1:	57                   	push   %edi
  8010e2:	54                   	push   %esp
  8010e3:	5d                   	pop    %ebp
  8010e4:	8d 35 ec 10 80 00    	lea    0x8010ec,%esi
  8010ea:	0f 34                	sysenter 
  8010ec:	5f                   	pop    %edi
  8010ed:	5e                   	pop    %esi
  8010ee:	5d                   	pop    %ebp
  8010ef:	5c                   	pop    %esp
  8010f0:	5b                   	pop    %ebx
  8010f1:	5a                   	pop    %edx
  8010f2:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8010f3:	85 c0                	test   %eax,%eax
  8010f5:	7e 28                	jle    80111f <sys_ipc_recv+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010f7:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010fb:	c7 44 24 0c 0e 00 00 	movl   $0xe,0xc(%esp)
  801102:	00 
  801103:	c7 44 24 08 00 2b 80 	movl   $0x802b00,0x8(%esp)
  80110a:	00 
  80110b:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801112:	00 
  801113:	c7 04 24 1d 2b 80 00 	movl   $0x802b1d,(%esp)
  80111a:	e8 e5 11 00 00       	call   802304 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80111f:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801122:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801125:	89 ec                	mov    %ebp,%esp
  801127:	5d                   	pop    %ebp
  801128:	c3                   	ret    

00801129 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801129:	55                   	push   %ebp
  80112a:	89 e5                	mov    %esp,%ebp
  80112c:	83 ec 08             	sub    $0x8,%esp
  80112f:	89 1c 24             	mov    %ebx,(%esp)
  801132:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801136:	b8 0d 00 00 00       	mov    $0xd,%eax
  80113b:	8b 7d 14             	mov    0x14(%ebp),%edi
  80113e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801141:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801144:	8b 55 08             	mov    0x8(%ebp),%edx
  801147:	51                   	push   %ecx
  801148:	52                   	push   %edx
  801149:	53                   	push   %ebx
  80114a:	54                   	push   %esp
  80114b:	55                   	push   %ebp
  80114c:	56                   	push   %esi
  80114d:	57                   	push   %edi
  80114e:	54                   	push   %esp
  80114f:	5d                   	pop    %ebp
  801150:	8d 35 58 11 80 00    	lea    0x801158,%esi
  801156:	0f 34                	sysenter 
  801158:	5f                   	pop    %edi
  801159:	5e                   	pop    %esi
  80115a:	5d                   	pop    %ebp
  80115b:	5c                   	pop    %esp
  80115c:	5b                   	pop    %ebx
  80115d:	5a                   	pop    %edx
  80115e:	59                   	pop    %ecx

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80115f:	8b 1c 24             	mov    (%esp),%ebx
  801162:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801166:	89 ec                	mov    %ebp,%esp
  801168:	5d                   	pop    %ebp
  801169:	c3                   	ret    

0080116a <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80116a:	55                   	push   %ebp
  80116b:	89 e5                	mov    %esp,%ebp
  80116d:	83 ec 28             	sub    $0x28,%esp
  801170:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801173:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801176:	bb 00 00 00 00       	mov    $0x0,%ebx
  80117b:	b8 0b 00 00 00       	mov    $0xb,%eax
  801180:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801183:	8b 55 08             	mov    0x8(%ebp),%edx
  801186:	89 df                	mov    %ebx,%edi
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
  8011a2:	7e 28                	jle    8011cc <sys_env_set_pgfault_upcall+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011a4:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011a8:	c7 44 24 0c 0b 00 00 	movl   $0xb,0xc(%esp)
  8011af:	00 
  8011b0:	c7 44 24 08 00 2b 80 	movl   $0x802b00,0x8(%esp)
  8011b7:	00 
  8011b8:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8011bf:	00 
  8011c0:	c7 04 24 1d 2b 80 00 	movl   $0x802b1d,(%esp)
  8011c7:	e8 38 11 00 00       	call   802304 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8011cc:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8011cf:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8011d2:	89 ec                	mov    %ebp,%esp
  8011d4:	5d                   	pop    %ebp
  8011d5:	c3                   	ret    

008011d6 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
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
  8011e2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011e7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8011ec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011ef:	8b 55 08             	mov    0x8(%ebp),%edx
  8011f2:	89 df                	mov    %ebx,%edi
  8011f4:	51                   	push   %ecx
  8011f5:	52                   	push   %edx
  8011f6:	53                   	push   %ebx
  8011f7:	54                   	push   %esp
  8011f8:	55                   	push   %ebp
  8011f9:	56                   	push   %esi
  8011fa:	57                   	push   %edi
  8011fb:	54                   	push   %esp
  8011fc:	5d                   	pop    %ebp
  8011fd:	8d 35 05 12 80 00    	lea    0x801205,%esi
  801203:	0f 34                	sysenter 
  801205:	5f                   	pop    %edi
  801206:	5e                   	pop    %esi
  801207:	5d                   	pop    %ebp
  801208:	5c                   	pop    %esp
  801209:	5b                   	pop    %ebx
  80120a:	5a                   	pop    %edx
  80120b:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80120c:	85 c0                	test   %eax,%eax
  80120e:	7e 28                	jle    801238 <sys_env_set_trapframe+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  801210:	89 44 24 10          	mov    %eax,0x10(%esp)
  801214:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  80121b:	00 
  80121c:	c7 44 24 08 00 2b 80 	movl   $0x802b00,0x8(%esp)
  801223:	00 
  801224:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80122b:	00 
  80122c:	c7 04 24 1d 2b 80 00 	movl   $0x802b1d,(%esp)
  801233:	e8 cc 10 00 00       	call   802304 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801238:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80123b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80123e:	89 ec                	mov    %ebp,%esp
  801240:	5d                   	pop    %ebp
  801241:	c3                   	ret    

00801242 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801242:	55                   	push   %ebp
  801243:	89 e5                	mov    %esp,%ebp
  801245:	83 ec 28             	sub    $0x28,%esp
  801248:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80124b:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80124e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801253:	b8 09 00 00 00       	mov    $0x9,%eax
  801258:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80125b:	8b 55 08             	mov    0x8(%ebp),%edx
  80125e:	89 df                	mov    %ebx,%edi
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
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801278:	85 c0                	test   %eax,%eax
  80127a:	7e 28                	jle    8012a4 <sys_env_set_status+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  80127c:	89 44 24 10          	mov    %eax,0x10(%esp)
  801280:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  801287:	00 
  801288:	c7 44 24 08 00 2b 80 	movl   $0x802b00,0x8(%esp)
  80128f:	00 
  801290:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801297:	00 
  801298:	c7 04 24 1d 2b 80 00 	movl   $0x802b1d,(%esp)
  80129f:	e8 60 10 00 00       	call   802304 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8012a4:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8012a7:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8012aa:	89 ec                	mov    %ebp,%esp
  8012ac:	5d                   	pop    %ebp
  8012ad:	c3                   	ret    

008012ae <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  8012ae:	55                   	push   %ebp
  8012af:	89 e5                	mov    %esp,%ebp
  8012b1:	83 ec 28             	sub    $0x28,%esp
  8012b4:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8012b7:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8012ba:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012bf:	b8 07 00 00 00       	mov    $0x7,%eax
  8012c4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012c7:	8b 55 08             	mov    0x8(%ebp),%edx
  8012ca:	89 df                	mov    %ebx,%edi
  8012cc:	51                   	push   %ecx
  8012cd:	52                   	push   %edx
  8012ce:	53                   	push   %ebx
  8012cf:	54                   	push   %esp
  8012d0:	55                   	push   %ebp
  8012d1:	56                   	push   %esi
  8012d2:	57                   	push   %edi
  8012d3:	54                   	push   %esp
  8012d4:	5d                   	pop    %ebp
  8012d5:	8d 35 dd 12 80 00    	lea    0x8012dd,%esi
  8012db:	0f 34                	sysenter 
  8012dd:	5f                   	pop    %edi
  8012de:	5e                   	pop    %esi
  8012df:	5d                   	pop    %ebp
  8012e0:	5c                   	pop    %esp
  8012e1:	5b                   	pop    %ebx
  8012e2:	5a                   	pop    %edx
  8012e3:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8012e4:	85 c0                	test   %eax,%eax
  8012e6:	7e 28                	jle    801310 <sys_page_unmap+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012e8:	89 44 24 10          	mov    %eax,0x10(%esp)
  8012ec:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8012f3:	00 
  8012f4:	c7 44 24 08 00 2b 80 	movl   $0x802b00,0x8(%esp)
  8012fb:	00 
  8012fc:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801303:	00 
  801304:	c7 04 24 1d 2b 80 00 	movl   $0x802b1d,(%esp)
  80130b:	e8 f4 0f 00 00       	call   802304 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801310:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801313:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801316:	89 ec                	mov    %ebp,%esp
  801318:	5d                   	pop    %ebp
  801319:	c3                   	ret    

0080131a <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80131a:	55                   	push   %ebp
  80131b:	89 e5                	mov    %esp,%ebp
  80131d:	83 ec 28             	sub    $0x28,%esp
  801320:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801323:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801326:	8b 7d 18             	mov    0x18(%ebp),%edi
  801329:	0b 7d 14             	or     0x14(%ebp),%edi
  80132c:	b8 06 00 00 00       	mov    $0x6,%eax
  801331:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801334:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801337:	8b 55 08             	mov    0x8(%ebp),%edx
  80133a:	51                   	push   %ecx
  80133b:	52                   	push   %edx
  80133c:	53                   	push   %ebx
  80133d:	54                   	push   %esp
  80133e:	55                   	push   %ebp
  80133f:	56                   	push   %esi
  801340:	57                   	push   %edi
  801341:	54                   	push   %esp
  801342:	5d                   	pop    %ebp
  801343:	8d 35 4b 13 80 00    	lea    0x80134b,%esi
  801349:	0f 34                	sysenter 
  80134b:	5f                   	pop    %edi
  80134c:	5e                   	pop    %esi
  80134d:	5d                   	pop    %ebp
  80134e:	5c                   	pop    %esp
  80134f:	5b                   	pop    %ebx
  801350:	5a                   	pop    %edx
  801351:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801352:	85 c0                	test   %eax,%eax
  801354:	7e 28                	jle    80137e <sys_page_map+0x64>
		panic("syscall %d returned %d (> 0)", num, ret);
  801356:	89 44 24 10          	mov    %eax,0x10(%esp)
  80135a:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  801361:	00 
  801362:	c7 44 24 08 00 2b 80 	movl   $0x802b00,0x8(%esp)
  801369:	00 
  80136a:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801371:	00 
  801372:	c7 04 24 1d 2b 80 00 	movl   $0x802b1d,(%esp)
  801379:	e8 86 0f 00 00       	call   802304 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}
  80137e:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801381:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801384:	89 ec                	mov    %ebp,%esp
  801386:	5d                   	pop    %ebp
  801387:	c3                   	ret    

00801388 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801388:	55                   	push   %ebp
  801389:	89 e5                	mov    %esp,%ebp
  80138b:	83 ec 28             	sub    $0x28,%esp
  80138e:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801391:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801394:	bf 00 00 00 00       	mov    $0x0,%edi
  801399:	b8 05 00 00 00       	mov    $0x5,%eax
  80139e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8013a1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013a4:	8b 55 08             	mov    0x8(%ebp),%edx
  8013a7:	51                   	push   %ecx
  8013a8:	52                   	push   %edx
  8013a9:	53                   	push   %ebx
  8013aa:	54                   	push   %esp
  8013ab:	55                   	push   %ebp
  8013ac:	56                   	push   %esi
  8013ad:	57                   	push   %edi
  8013ae:	54                   	push   %esp
  8013af:	5d                   	pop    %ebp
  8013b0:	8d 35 b8 13 80 00    	lea    0x8013b8,%esi
  8013b6:	0f 34                	sysenter 
  8013b8:	5f                   	pop    %edi
  8013b9:	5e                   	pop    %esi
  8013ba:	5d                   	pop    %ebp
  8013bb:	5c                   	pop    %esp
  8013bc:	5b                   	pop    %ebx
  8013bd:	5a                   	pop    %edx
  8013be:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8013bf:	85 c0                	test   %eax,%eax
  8013c1:	7e 28                	jle    8013eb <sys_page_alloc+0x63>
		panic("syscall %d returned %d (> 0)", num, ret);
  8013c3:	89 44 24 10          	mov    %eax,0x10(%esp)
  8013c7:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  8013ce:	00 
  8013cf:	c7 44 24 08 00 2b 80 	movl   $0x802b00,0x8(%esp)
  8013d6:	00 
  8013d7:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8013de:	00 
  8013df:	c7 04 24 1d 2b 80 00 	movl   $0x802b1d,(%esp)
  8013e6:	e8 19 0f 00 00       	call   802304 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8013eb:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8013ee:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8013f1:	89 ec                	mov    %ebp,%esp
  8013f3:	5d                   	pop    %ebp
  8013f4:	c3                   	ret    

008013f5 <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
{
  8013f5:	55                   	push   %ebp
  8013f6:	89 e5                	mov    %esp,%ebp
  8013f8:	83 ec 08             	sub    $0x8,%esp
  8013fb:	89 1c 24             	mov    %ebx,(%esp)
  8013fe:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801402:	ba 00 00 00 00       	mov    $0x0,%edx
  801407:	b8 0c 00 00 00       	mov    $0xc,%eax
  80140c:	89 d1                	mov    %edx,%ecx
  80140e:	89 d3                	mov    %edx,%ebx
  801410:	89 d7                	mov    %edx,%edi
  801412:	51                   	push   %ecx
  801413:	52                   	push   %edx
  801414:	53                   	push   %ebx
  801415:	54                   	push   %esp
  801416:	55                   	push   %ebp
  801417:	56                   	push   %esi
  801418:	57                   	push   %edi
  801419:	54                   	push   %esp
  80141a:	5d                   	pop    %ebp
  80141b:	8d 35 23 14 80 00    	lea    0x801423,%esi
  801421:	0f 34                	sysenter 
  801423:	5f                   	pop    %edi
  801424:	5e                   	pop    %esi
  801425:	5d                   	pop    %ebp
  801426:	5c                   	pop    %esp
  801427:	5b                   	pop    %ebx
  801428:	5a                   	pop    %edx
  801429:	59                   	pop    %ecx

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80142a:	8b 1c 24             	mov    (%esp),%ebx
  80142d:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801431:	89 ec                	mov    %ebp,%esp
  801433:	5d                   	pop    %ebp
  801434:	c3                   	ret    

00801435 <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
{
  801435:	55                   	push   %ebp
  801436:	89 e5                	mov    %esp,%ebp
  801438:	83 ec 08             	sub    $0x8,%esp
  80143b:	89 1c 24             	mov    %ebx,(%esp)
  80143e:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801442:	bb 00 00 00 00       	mov    $0x0,%ebx
  801447:	b8 04 00 00 00       	mov    $0x4,%eax
  80144c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80144f:	8b 55 08             	mov    0x8(%ebp),%edx
  801452:	89 df                	mov    %ebx,%edi
  801454:	51                   	push   %ecx
  801455:	52                   	push   %edx
  801456:	53                   	push   %ebx
  801457:	54                   	push   %esp
  801458:	55                   	push   %ebp
  801459:	56                   	push   %esi
  80145a:	57                   	push   %edi
  80145b:	54                   	push   %esp
  80145c:	5d                   	pop    %ebp
  80145d:	8d 35 65 14 80 00    	lea    0x801465,%esi
  801463:	0f 34                	sysenter 
  801465:	5f                   	pop    %edi
  801466:	5e                   	pop    %esi
  801467:	5d                   	pop    %ebp
  801468:	5c                   	pop    %esp
  801469:	5b                   	pop    %ebx
  80146a:	5a                   	pop    %edx
  80146b:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  80146c:	8b 1c 24             	mov    (%esp),%ebx
  80146f:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801473:	89 ec                	mov    %ebp,%esp
  801475:	5d                   	pop    %ebp
  801476:	c3                   	ret    

00801477 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  801477:	55                   	push   %ebp
  801478:	89 e5                	mov    %esp,%ebp
  80147a:	83 ec 08             	sub    $0x8,%esp
  80147d:	89 1c 24             	mov    %ebx,(%esp)
  801480:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801484:	ba 00 00 00 00       	mov    $0x0,%edx
  801489:	b8 02 00 00 00       	mov    $0x2,%eax
  80148e:	89 d1                	mov    %edx,%ecx
  801490:	89 d3                	mov    %edx,%ebx
  801492:	89 d7                	mov    %edx,%edi
  801494:	51                   	push   %ecx
  801495:	52                   	push   %edx
  801496:	53                   	push   %ebx
  801497:	54                   	push   %esp
  801498:	55                   	push   %ebp
  801499:	56                   	push   %esi
  80149a:	57                   	push   %edi
  80149b:	54                   	push   %esp
  80149c:	5d                   	pop    %ebp
  80149d:	8d 35 a5 14 80 00    	lea    0x8014a5,%esi
  8014a3:	0f 34                	sysenter 
  8014a5:	5f                   	pop    %edi
  8014a6:	5e                   	pop    %esi
  8014a7:	5d                   	pop    %ebp
  8014a8:	5c                   	pop    %esp
  8014a9:	5b                   	pop    %ebx
  8014aa:	5a                   	pop    %edx
  8014ab:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8014ac:	8b 1c 24             	mov    (%esp),%ebx
  8014af:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8014b3:	89 ec                	mov    %ebp,%esp
  8014b5:	5d                   	pop    %ebp
  8014b6:	c3                   	ret    

008014b7 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  8014b7:	55                   	push   %ebp
  8014b8:	89 e5                	mov    %esp,%ebp
  8014ba:	83 ec 28             	sub    $0x28,%esp
  8014bd:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8014c0:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8014c3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8014c8:	b8 03 00 00 00       	mov    $0x3,%eax
  8014cd:	8b 55 08             	mov    0x8(%ebp),%edx
  8014d0:	89 cb                	mov    %ecx,%ebx
  8014d2:	89 cf                	mov    %ecx,%edi
  8014d4:	51                   	push   %ecx
  8014d5:	52                   	push   %edx
  8014d6:	53                   	push   %ebx
  8014d7:	54                   	push   %esp
  8014d8:	55                   	push   %ebp
  8014d9:	56                   	push   %esi
  8014da:	57                   	push   %edi
  8014db:	54                   	push   %esp
  8014dc:	5d                   	pop    %ebp
  8014dd:	8d 35 e5 14 80 00    	lea    0x8014e5,%esi
  8014e3:	0f 34                	sysenter 
  8014e5:	5f                   	pop    %edi
  8014e6:	5e                   	pop    %esi
  8014e7:	5d                   	pop    %ebp
  8014e8:	5c                   	pop    %esp
  8014e9:	5b                   	pop    %ebx
  8014ea:	5a                   	pop    %edx
  8014eb:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8014ec:	85 c0                	test   %eax,%eax
  8014ee:	7e 28                	jle    801518 <sys_env_destroy+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  8014f0:	89 44 24 10          	mov    %eax,0x10(%esp)
  8014f4:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  8014fb:	00 
  8014fc:	c7 44 24 08 00 2b 80 	movl   $0x802b00,0x8(%esp)
  801503:	00 
  801504:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80150b:	00 
  80150c:	c7 04 24 1d 2b 80 00 	movl   $0x802b1d,(%esp)
  801513:	e8 ec 0d 00 00       	call   802304 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801518:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80151b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80151e:	89 ec                	mov    %ebp,%esp
  801520:	5d                   	pop    %ebp
  801521:	c3                   	ret    
	...

00801530 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801530:	55                   	push   %ebp
  801531:	89 e5                	mov    %esp,%ebp
  801533:	8b 45 08             	mov    0x8(%ebp),%eax
  801536:	05 00 00 00 30       	add    $0x30000000,%eax
  80153b:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  80153e:	5d                   	pop    %ebp
  80153f:	c3                   	ret    

00801540 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801540:	55                   	push   %ebp
  801541:	89 e5                	mov    %esp,%ebp
  801543:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801546:	8b 45 08             	mov    0x8(%ebp),%eax
  801549:	89 04 24             	mov    %eax,(%esp)
  80154c:	e8 df ff ff ff       	call   801530 <fd2num>
  801551:	05 20 00 0d 00       	add    $0xd0020,%eax
  801556:	c1 e0 0c             	shl    $0xc,%eax
}
  801559:	c9                   	leave  
  80155a:	c3                   	ret    

0080155b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80155b:	55                   	push   %ebp
  80155c:	89 e5                	mov    %esp,%ebp
  80155e:	57                   	push   %edi
  80155f:	56                   	push   %esi
  801560:	53                   	push   %ebx
  801561:	8b 7d 08             	mov    0x8(%ebp),%edi
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  801564:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  801569:	a8 01                	test   $0x1,%al
  80156b:	74 36                	je     8015a3 <fd_alloc+0x48>
  80156d:	a1 00 00 74 ef       	mov    0xef740000,%eax
  801572:	a8 01                	test   $0x1,%al
  801574:	74 2d                	je     8015a3 <fd_alloc+0x48>
  801576:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  80157b:	b9 00 d0 7b ef       	mov    $0xef7bd000,%ecx
  801580:	be 00 00 40 ef       	mov    $0xef400000,%esi
  801585:	89 c3                	mov    %eax,%ebx
  801587:	89 c2                	mov    %eax,%edx
  801589:	c1 ea 16             	shr    $0x16,%edx
  80158c:	8b 14 91             	mov    (%ecx,%edx,4),%edx
  80158f:	f6 c2 01             	test   $0x1,%dl
  801592:	74 14                	je     8015a8 <fd_alloc+0x4d>
  801594:	89 c2                	mov    %eax,%edx
  801596:	c1 ea 0c             	shr    $0xc,%edx
  801599:	8b 14 96             	mov    (%esi,%edx,4),%edx
  80159c:	f6 c2 01             	test   $0x1,%dl
  80159f:	75 10                	jne    8015b1 <fd_alloc+0x56>
  8015a1:	eb 05                	jmp    8015a8 <fd_alloc+0x4d>
  8015a3:	bb 00 00 00 d0       	mov    $0xd0000000,%ebx
			*fd_store = fd;
  8015a8:	89 1f                	mov    %ebx,(%edi)
  8015aa:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  8015af:	eb 17                	jmp    8015c8 <fd_alloc+0x6d>
  8015b1:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8015b6:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8015bb:	75 c8                	jne    801585 <fd_alloc+0x2a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8015bd:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  8015c3:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  8015c8:	5b                   	pop    %ebx
  8015c9:	5e                   	pop    %esi
  8015ca:	5f                   	pop    %edi
  8015cb:	5d                   	pop    %ebp
  8015cc:	c3                   	ret    

008015cd <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8015cd:	55                   	push   %ebp
  8015ce:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8015d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8015d3:	83 f8 1f             	cmp    $0x1f,%eax
  8015d6:	77 36                	ja     80160e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8015d8:	05 00 00 0d 00       	add    $0xd0000,%eax
  8015dd:	c1 e0 0c             	shl    $0xc,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
  8015e0:	89 c2                	mov    %eax,%edx
  8015e2:	c1 ea 16             	shr    $0x16,%edx
  8015e5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8015ec:	f6 c2 01             	test   $0x1,%dl
  8015ef:	74 1d                	je     80160e <fd_lookup+0x41>
  8015f1:	89 c2                	mov    %eax,%edx
  8015f3:	c1 ea 0c             	shr    $0xc,%edx
  8015f6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8015fd:	f6 c2 01             	test   $0x1,%dl
  801600:	74 0c                	je     80160e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  801602:	8b 55 0c             	mov    0xc(%ebp),%edx
  801605:	89 02                	mov    %eax,(%edx)
  801607:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
  80160c:	eb 05                	jmp    801613 <fd_lookup+0x46>
  80160e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801613:	5d                   	pop    %ebp
  801614:	c3                   	ret    

00801615 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  801615:	55                   	push   %ebp
  801616:	89 e5                	mov    %esp,%ebp
  801618:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80161b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80161e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801622:	8b 45 08             	mov    0x8(%ebp),%eax
  801625:	89 04 24             	mov    %eax,(%esp)
  801628:	e8 a0 ff ff ff       	call   8015cd <fd_lookup>
  80162d:	85 c0                	test   %eax,%eax
  80162f:	78 0e                	js     80163f <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801631:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801634:	8b 55 0c             	mov    0xc(%ebp),%edx
  801637:	89 50 04             	mov    %edx,0x4(%eax)
  80163a:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  80163f:	c9                   	leave  
  801640:	c3                   	ret    

00801641 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801641:	55                   	push   %ebp
  801642:	89 e5                	mov    %esp,%ebp
  801644:	56                   	push   %esi
  801645:	53                   	push   %ebx
  801646:	83 ec 10             	sub    $0x10,%esp
  801649:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80164c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
// File functions
// --------------------------------------------------------------

static struct Dev *devtab[] =
{
	&devfile,
  80164f:	b8 04 30 80 00       	mov    $0x803004,%eax
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  801654:	ba 00 00 00 00       	mov    $0x0,%edx

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801659:	be a8 2b 80 00       	mov    $0x802ba8,%esi
		if (devtab[i]->dev_id == dev_id) {
  80165e:	39 08                	cmp    %ecx,(%eax)
  801660:	75 10                	jne    801672 <dev_lookup+0x31>
  801662:	eb 04                	jmp    801668 <dev_lookup+0x27>
  801664:	39 08                	cmp    %ecx,(%eax)
  801666:	75 0a                	jne    801672 <dev_lookup+0x31>
			*dev = devtab[i];
  801668:	89 03                	mov    %eax,(%ebx)
  80166a:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  80166f:	90                   	nop
  801670:	eb 31                	jmp    8016a3 <dev_lookup+0x62>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801672:	83 c2 01             	add    $0x1,%edx
  801675:	8b 04 96             	mov    (%esi,%edx,4),%eax
  801678:	85 c0                	test   %eax,%eax
  80167a:	75 e8                	jne    801664 <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80167c:	a1 08 40 80 00       	mov    0x804008,%eax
  801681:	8b 40 48             	mov    0x48(%eax),%eax
  801684:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801688:	89 44 24 04          	mov    %eax,0x4(%esp)
  80168c:	c7 04 24 2c 2b 80 00 	movl   $0x802b2c,(%esp)
  801693:	e8 99 ea ff ff       	call   800131 <cprintf>
	*dev = 0;
  801698:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80169e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  8016a3:	83 c4 10             	add    $0x10,%esp
  8016a6:	5b                   	pop    %ebx
  8016a7:	5e                   	pop    %esi
  8016a8:	5d                   	pop    %ebp
  8016a9:	c3                   	ret    

008016aa <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  8016aa:	55                   	push   %ebp
  8016ab:	89 e5                	mov    %esp,%ebp
  8016ad:	53                   	push   %ebx
  8016ae:	83 ec 24             	sub    $0x24,%esp
  8016b1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016b4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016b7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8016be:	89 04 24             	mov    %eax,(%esp)
  8016c1:	e8 07 ff ff ff       	call   8015cd <fd_lookup>
  8016c6:	85 c0                	test   %eax,%eax
  8016c8:	78 53                	js     80171d <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016ca:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016d4:	8b 00                	mov    (%eax),%eax
  8016d6:	89 04 24             	mov    %eax,(%esp)
  8016d9:	e8 63 ff ff ff       	call   801641 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016de:	85 c0                	test   %eax,%eax
  8016e0:	78 3b                	js     80171d <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  8016e2:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8016e7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016ea:	83 7a 14 00          	cmpl   $0x0,0x14(%edx)
  8016ee:	74 2d                	je     80171d <fstat+0x73>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8016f0:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8016f3:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8016fa:	00 00 00 
	stat->st_isdir = 0;
  8016fd:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801704:	00 00 00 
	stat->st_dev = dev;
  801707:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80170a:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801710:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801714:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801717:	89 14 24             	mov    %edx,(%esp)
  80171a:	ff 50 14             	call   *0x14(%eax)
}
  80171d:	83 c4 24             	add    $0x24,%esp
  801720:	5b                   	pop    %ebx
  801721:	5d                   	pop    %ebp
  801722:	c3                   	ret    

00801723 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  801723:	55                   	push   %ebp
  801724:	89 e5                	mov    %esp,%ebp
  801726:	53                   	push   %ebx
  801727:	83 ec 24             	sub    $0x24,%esp
  80172a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80172d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801730:	89 44 24 04          	mov    %eax,0x4(%esp)
  801734:	89 1c 24             	mov    %ebx,(%esp)
  801737:	e8 91 fe ff ff       	call   8015cd <fd_lookup>
  80173c:	85 c0                	test   %eax,%eax
  80173e:	78 5f                	js     80179f <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801740:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801743:	89 44 24 04          	mov    %eax,0x4(%esp)
  801747:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80174a:	8b 00                	mov    (%eax),%eax
  80174c:	89 04 24             	mov    %eax,(%esp)
  80174f:	e8 ed fe ff ff       	call   801641 <dev_lookup>
ftruncate(int fdnum, off_t newsize)
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801754:	85 c0                	test   %eax,%eax
  801756:	78 47                	js     80179f <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801758:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80175b:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  80175f:	75 23                	jne    801784 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801761:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801766:	8b 40 48             	mov    0x48(%eax),%eax
  801769:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80176d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801771:	c7 04 24 4c 2b 80 00 	movl   $0x802b4c,(%esp)
  801778:	e8 b4 e9 ff ff       	call   800131 <cprintf>
  80177d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801782:	eb 1b                	jmp    80179f <ftruncate+0x7c>
	}
	if (!dev->dev_trunc)
  801784:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801787:	8b 48 18             	mov    0x18(%eax),%ecx
  80178a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80178f:	85 c9                	test   %ecx,%ecx
  801791:	74 0c                	je     80179f <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801793:	8b 45 0c             	mov    0xc(%ebp),%eax
  801796:	89 44 24 04          	mov    %eax,0x4(%esp)
  80179a:	89 14 24             	mov    %edx,(%esp)
  80179d:	ff d1                	call   *%ecx
}
  80179f:	83 c4 24             	add    $0x24,%esp
  8017a2:	5b                   	pop    %ebx
  8017a3:	5d                   	pop    %ebp
  8017a4:	c3                   	ret    

008017a5 <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8017a5:	55                   	push   %ebp
  8017a6:	89 e5                	mov    %esp,%ebp
  8017a8:	53                   	push   %ebx
  8017a9:	83 ec 24             	sub    $0x24,%esp
  8017ac:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017af:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017b2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017b6:	89 1c 24             	mov    %ebx,(%esp)
  8017b9:	e8 0f fe ff ff       	call   8015cd <fd_lookup>
  8017be:	85 c0                	test   %eax,%eax
  8017c0:	78 66                	js     801828 <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017c2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017c5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017cc:	8b 00                	mov    (%eax),%eax
  8017ce:	89 04 24             	mov    %eax,(%esp)
  8017d1:	e8 6b fe ff ff       	call   801641 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017d6:	85 c0                	test   %eax,%eax
  8017d8:	78 4e                	js     801828 <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8017da:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8017dd:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  8017e1:	75 23                	jne    801806 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8017e3:	a1 08 40 80 00       	mov    0x804008,%eax
  8017e8:	8b 40 48             	mov    0x48(%eax),%eax
  8017eb:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8017ef:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017f3:	c7 04 24 6d 2b 80 00 	movl   $0x802b6d,(%esp)
  8017fa:	e8 32 e9 ff ff       	call   800131 <cprintf>
  8017ff:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801804:	eb 22                	jmp    801828 <write+0x83>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801806:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801809:	8b 48 0c             	mov    0xc(%eax),%ecx
  80180c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801811:	85 c9                	test   %ecx,%ecx
  801813:	74 13                	je     801828 <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801815:	8b 45 10             	mov    0x10(%ebp),%eax
  801818:	89 44 24 08          	mov    %eax,0x8(%esp)
  80181c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80181f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801823:	89 14 24             	mov    %edx,(%esp)
  801826:	ff d1                	call   *%ecx
}
  801828:	83 c4 24             	add    $0x24,%esp
  80182b:	5b                   	pop    %ebx
  80182c:	5d                   	pop    %ebp
  80182d:	c3                   	ret    

0080182e <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80182e:	55                   	push   %ebp
  80182f:	89 e5                	mov    %esp,%ebp
  801831:	53                   	push   %ebx
  801832:	83 ec 24             	sub    $0x24,%esp
  801835:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801838:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80183b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80183f:	89 1c 24             	mov    %ebx,(%esp)
  801842:	e8 86 fd ff ff       	call   8015cd <fd_lookup>
  801847:	85 c0                	test   %eax,%eax
  801849:	78 6b                	js     8018b6 <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80184b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80184e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801852:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801855:	8b 00                	mov    (%eax),%eax
  801857:	89 04 24             	mov    %eax,(%esp)
  80185a:	e8 e2 fd ff ff       	call   801641 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80185f:	85 c0                	test   %eax,%eax
  801861:	78 53                	js     8018b6 <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801863:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801866:	8b 42 08             	mov    0x8(%edx),%eax
  801869:	83 e0 03             	and    $0x3,%eax
  80186c:	83 f8 01             	cmp    $0x1,%eax
  80186f:	75 23                	jne    801894 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801871:	a1 08 40 80 00       	mov    0x804008,%eax
  801876:	8b 40 48             	mov    0x48(%eax),%eax
  801879:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80187d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801881:	c7 04 24 8a 2b 80 00 	movl   $0x802b8a,(%esp)
  801888:	e8 a4 e8 ff ff       	call   800131 <cprintf>
  80188d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801892:	eb 22                	jmp    8018b6 <read+0x88>
	}
	if (!dev->dev_read)
  801894:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801897:	8b 48 08             	mov    0x8(%eax),%ecx
  80189a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80189f:	85 c9                	test   %ecx,%ecx
  8018a1:	74 13                	je     8018b6 <read+0x88>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8018a3:	8b 45 10             	mov    0x10(%ebp),%eax
  8018a6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8018aa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018ad:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018b1:	89 14 24             	mov    %edx,(%esp)
  8018b4:	ff d1                	call   *%ecx
}
  8018b6:	83 c4 24             	add    $0x24,%esp
  8018b9:	5b                   	pop    %ebx
  8018ba:	5d                   	pop    %ebp
  8018bb:	c3                   	ret    

008018bc <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8018bc:	55                   	push   %ebp
  8018bd:	89 e5                	mov    %esp,%ebp
  8018bf:	57                   	push   %edi
  8018c0:	56                   	push   %esi
  8018c1:	53                   	push   %ebx
  8018c2:	83 ec 1c             	sub    $0x1c,%esp
  8018c5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8018c8:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8018cb:	ba 00 00 00 00       	mov    $0x0,%edx
  8018d0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8018d5:	b8 00 00 00 00       	mov    $0x0,%eax
  8018da:	85 f6                	test   %esi,%esi
  8018dc:	74 29                	je     801907 <readn+0x4b>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8018de:	89 f0                	mov    %esi,%eax
  8018e0:	29 d0                	sub    %edx,%eax
  8018e2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8018e6:	03 55 0c             	add    0xc(%ebp),%edx
  8018e9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8018ed:	89 3c 24             	mov    %edi,(%esp)
  8018f0:	e8 39 ff ff ff       	call   80182e <read>
		if (m < 0)
  8018f5:	85 c0                	test   %eax,%eax
  8018f7:	78 0e                	js     801907 <readn+0x4b>
			return m;
		if (m == 0)
  8018f9:	85 c0                	test   %eax,%eax
  8018fb:	74 08                	je     801905 <readn+0x49>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8018fd:	01 c3                	add    %eax,%ebx
  8018ff:	89 da                	mov    %ebx,%edx
  801901:	39 f3                	cmp    %esi,%ebx
  801903:	72 d9                	jb     8018de <readn+0x22>
  801905:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801907:	83 c4 1c             	add    $0x1c,%esp
  80190a:	5b                   	pop    %ebx
  80190b:	5e                   	pop    %esi
  80190c:	5f                   	pop    %edi
  80190d:	5d                   	pop    %ebp
  80190e:	c3                   	ret    

0080190f <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80190f:	55                   	push   %ebp
  801910:	89 e5                	mov    %esp,%ebp
  801912:	56                   	push   %esi
  801913:	53                   	push   %ebx
  801914:	83 ec 20             	sub    $0x20,%esp
  801917:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80191a:	89 34 24             	mov    %esi,(%esp)
  80191d:	e8 0e fc ff ff       	call   801530 <fd2num>
  801922:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801925:	89 54 24 04          	mov    %edx,0x4(%esp)
  801929:	89 04 24             	mov    %eax,(%esp)
  80192c:	e8 9c fc ff ff       	call   8015cd <fd_lookup>
  801931:	89 c3                	mov    %eax,%ebx
  801933:	85 c0                	test   %eax,%eax
  801935:	78 05                	js     80193c <fd_close+0x2d>
  801937:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80193a:	74 0c                	je     801948 <fd_close+0x39>
	    || fd != fd2)
		return (must_exist ? r : 0);
  80193c:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  801940:	19 c0                	sbb    %eax,%eax
  801942:	f7 d0                	not    %eax
  801944:	21 c3                	and    %eax,%ebx
  801946:	eb 3d                	jmp    801985 <fd_close+0x76>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801948:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80194b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80194f:	8b 06                	mov    (%esi),%eax
  801951:	89 04 24             	mov    %eax,(%esp)
  801954:	e8 e8 fc ff ff       	call   801641 <dev_lookup>
  801959:	89 c3                	mov    %eax,%ebx
  80195b:	85 c0                	test   %eax,%eax
  80195d:	78 16                	js     801975 <fd_close+0x66>
		if (dev->dev_close)
  80195f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801962:	8b 40 10             	mov    0x10(%eax),%eax
  801965:	bb 00 00 00 00       	mov    $0x0,%ebx
  80196a:	85 c0                	test   %eax,%eax
  80196c:	74 07                	je     801975 <fd_close+0x66>
			r = (*dev->dev_close)(fd);
  80196e:	89 34 24             	mov    %esi,(%esp)
  801971:	ff d0                	call   *%eax
  801973:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801975:	89 74 24 04          	mov    %esi,0x4(%esp)
  801979:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801980:	e8 29 f9 ff ff       	call   8012ae <sys_page_unmap>
	return r;
}
  801985:	89 d8                	mov    %ebx,%eax
  801987:	83 c4 20             	add    $0x20,%esp
  80198a:	5b                   	pop    %ebx
  80198b:	5e                   	pop    %esi
  80198c:	5d                   	pop    %ebp
  80198d:	c3                   	ret    

0080198e <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80198e:	55                   	push   %ebp
  80198f:	89 e5                	mov    %esp,%ebp
  801991:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801994:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801997:	89 44 24 04          	mov    %eax,0x4(%esp)
  80199b:	8b 45 08             	mov    0x8(%ebp),%eax
  80199e:	89 04 24             	mov    %eax,(%esp)
  8019a1:	e8 27 fc ff ff       	call   8015cd <fd_lookup>
  8019a6:	85 c0                	test   %eax,%eax
  8019a8:	78 13                	js     8019bd <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  8019aa:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8019b1:	00 
  8019b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019b5:	89 04 24             	mov    %eax,(%esp)
  8019b8:	e8 52 ff ff ff       	call   80190f <fd_close>
}
  8019bd:	c9                   	leave  
  8019be:	c3                   	ret    

008019bf <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  8019bf:	55                   	push   %ebp
  8019c0:	89 e5                	mov    %esp,%ebp
  8019c2:	83 ec 18             	sub    $0x18,%esp
  8019c5:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8019c8:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8019cb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8019d2:	00 
  8019d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8019d6:	89 04 24             	mov    %eax,(%esp)
  8019d9:	e8 79 03 00 00       	call   801d57 <open>
  8019de:	89 c3                	mov    %eax,%ebx
  8019e0:	85 c0                	test   %eax,%eax
  8019e2:	78 1b                	js     8019ff <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  8019e4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019e7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019eb:	89 1c 24             	mov    %ebx,(%esp)
  8019ee:	e8 b7 fc ff ff       	call   8016aa <fstat>
  8019f3:	89 c6                	mov    %eax,%esi
	close(fd);
  8019f5:	89 1c 24             	mov    %ebx,(%esp)
  8019f8:	e8 91 ff ff ff       	call   80198e <close>
  8019fd:	89 f3                	mov    %esi,%ebx
	return r;
}
  8019ff:	89 d8                	mov    %ebx,%eax
  801a01:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801a04:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801a07:	89 ec                	mov    %ebp,%esp
  801a09:	5d                   	pop    %ebp
  801a0a:	c3                   	ret    

00801a0b <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  801a0b:	55                   	push   %ebp
  801a0c:	89 e5                	mov    %esp,%ebp
  801a0e:	53                   	push   %ebx
  801a0f:	83 ec 14             	sub    $0x14,%esp
  801a12:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  801a17:	89 1c 24             	mov    %ebx,(%esp)
  801a1a:	e8 6f ff ff ff       	call   80198e <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801a1f:	83 c3 01             	add    $0x1,%ebx
  801a22:	83 fb 20             	cmp    $0x20,%ebx
  801a25:	75 f0                	jne    801a17 <close_all+0xc>
		close(i);
}
  801a27:	83 c4 14             	add    $0x14,%esp
  801a2a:	5b                   	pop    %ebx
  801a2b:	5d                   	pop    %ebp
  801a2c:	c3                   	ret    

00801a2d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801a2d:	55                   	push   %ebp
  801a2e:	89 e5                	mov    %esp,%ebp
  801a30:	83 ec 58             	sub    $0x58,%esp
  801a33:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801a36:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801a39:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801a3c:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801a3f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801a42:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a46:	8b 45 08             	mov    0x8(%ebp),%eax
  801a49:	89 04 24             	mov    %eax,(%esp)
  801a4c:	e8 7c fb ff ff       	call   8015cd <fd_lookup>
  801a51:	89 c3                	mov    %eax,%ebx
  801a53:	85 c0                	test   %eax,%eax
  801a55:	0f 88 e0 00 00 00    	js     801b3b <dup+0x10e>
		return r;
	close(newfdnum);
  801a5b:	89 3c 24             	mov    %edi,(%esp)
  801a5e:	e8 2b ff ff ff       	call   80198e <close>

	newfd = INDEX2FD(newfdnum);
  801a63:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801a69:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801a6c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a6f:	89 04 24             	mov    %eax,(%esp)
  801a72:	e8 c9 fa ff ff       	call   801540 <fd2data>
  801a77:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801a79:	89 34 24             	mov    %esi,(%esp)
  801a7c:	e8 bf fa ff ff       	call   801540 <fd2data>
  801a81:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
  801a84:	89 da                	mov    %ebx,%edx
  801a86:	89 d8                	mov    %ebx,%eax
  801a88:	c1 e8 16             	shr    $0x16,%eax
  801a8b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801a92:	a8 01                	test   $0x1,%al
  801a94:	74 43                	je     801ad9 <dup+0xac>
  801a96:	c1 ea 0c             	shr    $0xc,%edx
  801a99:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801aa0:	a8 01                	test   $0x1,%al
  801aa2:	74 35                	je     801ad9 <dup+0xac>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801aa4:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801aab:	25 07 0e 00 00       	and    $0xe07,%eax
  801ab0:	89 44 24 10          	mov    %eax,0x10(%esp)
  801ab4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801ab7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801abb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801ac2:	00 
  801ac3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801ac7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ace:	e8 47 f8 ff ff       	call   80131a <sys_page_map>
  801ad3:	89 c3                	mov    %eax,%ebx
  801ad5:	85 c0                	test   %eax,%eax
  801ad7:	78 3f                	js     801b18 <dup+0xeb>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801ad9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801adc:	89 c2                	mov    %eax,%edx
  801ade:	c1 ea 0c             	shr    $0xc,%edx
  801ae1:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801ae8:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801aee:	89 54 24 10          	mov    %edx,0x10(%esp)
  801af2:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801af6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801afd:	00 
  801afe:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b02:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b09:	e8 0c f8 ff ff       	call   80131a <sys_page_map>
  801b0e:	89 c3                	mov    %eax,%ebx
  801b10:	85 c0                	test   %eax,%eax
  801b12:	78 04                	js     801b18 <dup+0xeb>
  801b14:	89 fb                	mov    %edi,%ebx
  801b16:	eb 23                	jmp    801b3b <dup+0x10e>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801b18:	89 74 24 04          	mov    %esi,0x4(%esp)
  801b1c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b23:	e8 86 f7 ff ff       	call   8012ae <sys_page_unmap>
	sys_page_unmap(0, nva);
  801b28:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801b2b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b2f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b36:	e8 73 f7 ff ff       	call   8012ae <sys_page_unmap>
	return r;
}
  801b3b:	89 d8                	mov    %ebx,%eax
  801b3d:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801b40:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801b43:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801b46:	89 ec                	mov    %ebp,%esp
  801b48:	5d                   	pop    %ebp
  801b49:	c3                   	ret    
	...

00801b4c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801b4c:	55                   	push   %ebp
  801b4d:	89 e5                	mov    %esp,%ebp
  801b4f:	83 ec 18             	sub    $0x18,%esp
  801b52:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801b55:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801b58:	89 c3                	mov    %eax,%ebx
  801b5a:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801b5c:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801b63:	75 11                	jne    801b76 <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801b65:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801b6c:	e8 ef 07 00 00       	call   802360 <ipc_find_env>
  801b71:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801b76:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801b7d:	00 
  801b7e:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801b85:	00 
  801b86:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801b8a:	a1 00 40 80 00       	mov    0x804000,%eax
  801b8f:	89 04 24             	mov    %eax,(%esp)
  801b92:	e8 14 08 00 00       	call   8023ab <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801b97:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801b9e:	00 
  801b9f:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ba3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801baa:	e8 7a 08 00 00       	call   802429 <ipc_recv>
}
  801baf:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801bb2:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801bb5:	89 ec                	mov    %ebp,%esp
  801bb7:	5d                   	pop    %ebp
  801bb8:	c3                   	ret    

00801bb9 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801bb9:	55                   	push   %ebp
  801bba:	89 e5                	mov    %esp,%ebp
  801bbc:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801bbf:	8b 45 08             	mov    0x8(%ebp),%eax
  801bc2:	8b 40 0c             	mov    0xc(%eax),%eax
  801bc5:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801bca:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bcd:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801bd2:	ba 00 00 00 00       	mov    $0x0,%edx
  801bd7:	b8 02 00 00 00       	mov    $0x2,%eax
  801bdc:	e8 6b ff ff ff       	call   801b4c <fsipc>
}
  801be1:	c9                   	leave  
  801be2:	c3                   	ret    

00801be3 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801be3:	55                   	push   %ebp
  801be4:	89 e5                	mov    %esp,%ebp
  801be6:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801be9:	8b 45 08             	mov    0x8(%ebp),%eax
  801bec:	8b 40 0c             	mov    0xc(%eax),%eax
  801bef:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801bf4:	ba 00 00 00 00       	mov    $0x0,%edx
  801bf9:	b8 06 00 00 00       	mov    $0x6,%eax
  801bfe:	e8 49 ff ff ff       	call   801b4c <fsipc>
}
  801c03:	c9                   	leave  
  801c04:	c3                   	ret    

00801c05 <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  801c05:	55                   	push   %ebp
  801c06:	89 e5                	mov    %esp,%ebp
  801c08:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801c0b:	ba 00 00 00 00       	mov    $0x0,%edx
  801c10:	b8 08 00 00 00       	mov    $0x8,%eax
  801c15:	e8 32 ff ff ff       	call   801b4c <fsipc>
}
  801c1a:	c9                   	leave  
  801c1b:	c3                   	ret    

00801c1c <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801c1c:	55                   	push   %ebp
  801c1d:	89 e5                	mov    %esp,%ebp
  801c1f:	53                   	push   %ebx
  801c20:	83 ec 14             	sub    $0x14,%esp
  801c23:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801c26:	8b 45 08             	mov    0x8(%ebp),%eax
  801c29:	8b 40 0c             	mov    0xc(%eax),%eax
  801c2c:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801c31:	ba 00 00 00 00       	mov    $0x0,%edx
  801c36:	b8 05 00 00 00       	mov    $0x5,%eax
  801c3b:	e8 0c ff ff ff       	call   801b4c <fsipc>
  801c40:	85 c0                	test   %eax,%eax
  801c42:	78 2b                	js     801c6f <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801c44:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801c4b:	00 
  801c4c:	89 1c 24             	mov    %ebx,(%esp)
  801c4f:	e8 06 ee ff ff       	call   800a5a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801c54:	a1 80 50 80 00       	mov    0x805080,%eax
  801c59:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801c5f:	a1 84 50 80 00       	mov    0x805084,%eax
  801c64:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  801c6a:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  801c6f:	83 c4 14             	add    $0x14,%esp
  801c72:	5b                   	pop    %ebx
  801c73:	5d                   	pop    %ebp
  801c74:	c3                   	ret    

00801c75 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801c75:	55                   	push   %ebp
  801c76:	89 e5                	mov    %esp,%ebp
  801c78:	83 ec 18             	sub    $0x18,%esp
  801c7b:	8b 45 10             	mov    0x10(%ebp),%eax
  801c7e:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801c83:	76 05                	jbe    801c8a <devfile_write+0x15>
  801c85:	b8 f8 0f 00 00       	mov    $0xff8,%eax
	// bytes than requested.
	// LAB 5: Your code here
        int r;
        if(n > sizeof(fsipcbuf.write.req_buf))
            n = sizeof(fsipcbuf.write.req_buf);
        fsipcbuf.write.req_fileid = fd->fd_file.id;
  801c8a:	8b 55 08             	mov    0x8(%ebp),%edx
  801c8d:	8b 52 0c             	mov    0xc(%edx),%edx
  801c90:	89 15 00 50 80 00    	mov    %edx,0x805000
        fsipcbuf.write.req_n = n;
  801c96:	a3 04 50 80 00       	mov    %eax,0x805004
        memmove(fsipcbuf.write.req_buf,buf,n);  
  801c9b:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c9f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ca2:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ca6:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  801cad:	e8 93 ef ff ff       	call   800c45 <memmove>
        r = fsipc(FSREQ_WRITE,NULL);
  801cb2:	ba 00 00 00 00       	mov    $0x0,%edx
  801cb7:	b8 04 00 00 00       	mov    $0x4,%eax
  801cbc:	e8 8b fe ff ff       	call   801b4c <fsipc>
        return r;
	//panic("devfile_write not implemented");
}
  801cc1:	c9                   	leave  
  801cc2:	c3                   	ret    

00801cc3 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801cc3:	55                   	push   %ebp
  801cc4:	89 e5                	mov    %esp,%ebp
  801cc6:	53                   	push   %ebx
  801cc7:	83 ec 14             	sub    $0x14,%esp
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
        int r;
        fsipcbuf.read.req_fileid = fd->fd_file.id;
  801cca:	8b 45 08             	mov    0x8(%ebp),%eax
  801ccd:	8b 40 0c             	mov    0xc(%eax),%eax
  801cd0:	a3 00 50 80 00       	mov    %eax,0x805000
        fsipcbuf.read.req_n = n;
  801cd5:	8b 45 10             	mov    0x10(%ebp),%eax
  801cd8:	a3 04 50 80 00       	mov    %eax,0x805004
        r = fsipc(FSREQ_READ,NULL);
  801cdd:	ba 00 00 00 00       	mov    $0x0,%edx
  801ce2:	b8 03 00 00 00       	mov    $0x3,%eax
  801ce7:	e8 60 fe ff ff       	call   801b4c <fsipc>
  801cec:	89 c3                	mov    %eax,%ebx
        if(r < 0)
  801cee:	85 c0                	test   %eax,%eax
  801cf0:	78 17                	js     801d09 <devfile_read+0x46>
           return r;
        memmove(buf,fsipcbuf.readRet.ret_buf,r);
  801cf2:	89 44 24 08          	mov    %eax,0x8(%esp)
  801cf6:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801cfd:	00 
  801cfe:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d01:	89 04 24             	mov    %eax,(%esp)
  801d04:	e8 3c ef ff ff       	call   800c45 <memmove>
        return r;
	//panic("devfile_read not implemented");
}
  801d09:	89 d8                	mov    %ebx,%eax
  801d0b:	83 c4 14             	add    $0x14,%esp
  801d0e:	5b                   	pop    %ebx
  801d0f:	5d                   	pop    %ebp
  801d10:	c3                   	ret    

00801d11 <remove>:
}

// Delete a file
int
remove(const char *path)
{
  801d11:	55                   	push   %ebp
  801d12:	89 e5                	mov    %esp,%ebp
  801d14:	53                   	push   %ebx
  801d15:	83 ec 14             	sub    $0x14,%esp
  801d18:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  801d1b:	89 1c 24             	mov    %ebx,(%esp)
  801d1e:	e8 ed ec ff ff       	call   800a10 <strlen>
  801d23:	89 c2                	mov    %eax,%edx
  801d25:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  801d2a:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
  801d30:	7f 1f                	jg     801d51 <remove+0x40>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  801d32:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801d36:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801d3d:	e8 18 ed ff ff       	call   800a5a <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  801d42:	ba 00 00 00 00       	mov    $0x0,%edx
  801d47:	b8 07 00 00 00       	mov    $0x7,%eax
  801d4c:	e8 fb fd ff ff       	call   801b4c <fsipc>
}
  801d51:	83 c4 14             	add    $0x14,%esp
  801d54:	5b                   	pop    %ebx
  801d55:	5d                   	pop    %ebp
  801d56:	c3                   	ret    

00801d57 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801d57:	55                   	push   %ebp
  801d58:	89 e5                	mov    %esp,%ebp
  801d5a:	83 ec 28             	sub    $0x28,%esp
  801d5d:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801d60:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801d63:	8b 75 08             	mov    0x8(%ebp),%esi
	// If any step after fd_alloc fails, use fd_close to free the
	// file descriptor.

	// LAB 5: Your code here.
        struct Fd* fd;
        if(strlen(path) > MAXPATHLEN)
  801d66:	89 34 24             	mov    %esi,(%esp)
  801d69:	e8 a2 ec ff ff       	call   800a10 <strlen>
  801d6e:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801d73:	3d 00 04 00 00       	cmp    $0x400,%eax
  801d78:	7f 6d                	jg     801de7 <open+0x90>
            return -E_BAD_PATH;
        int r;
        r = fd_alloc(&fd);
  801d7a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d7d:	89 04 24             	mov    %eax,(%esp)
  801d80:	e8 d6 f7 ff ff       	call   80155b <fd_alloc>
  801d85:	89 c3                	mov    %eax,%ebx
        if(r < 0)
  801d87:	85 c0                	test   %eax,%eax
  801d89:	78 5c                	js     801de7 <open+0x90>
           return r;
        fsipcbuf.open.req_omode = mode;
  801d8b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d8e:	a3 00 54 80 00       	mov    %eax,0x805400
        memmove(fsipcbuf.open.req_path,path,strlen(path)+1);
  801d93:	89 34 24             	mov    %esi,(%esp)
  801d96:	e8 75 ec ff ff       	call   800a10 <strlen>
  801d9b:	83 c0 01             	add    $0x1,%eax
  801d9e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801da2:	89 74 24 04          	mov    %esi,0x4(%esp)
  801da6:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801dad:	e8 93 ee ff ff       	call   800c45 <memmove>
        r = fsipc(FSREQ_OPEN,(void*)fd);
  801db2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801db5:	b8 01 00 00 00       	mov    $0x1,%eax
  801dba:	e8 8d fd ff ff       	call   801b4c <fsipc>
  801dbf:	89 c3                	mov    %eax,%ebx
        if(r < 0){
  801dc1:	85 c0                	test   %eax,%eax
  801dc3:	79 15                	jns    801dda <open+0x83>
             fd_close(fd,0);
  801dc5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801dcc:	00 
  801dcd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dd0:	89 04 24             	mov    %eax,(%esp)
  801dd3:	e8 37 fb ff ff       	call   80190f <fd_close>
             return r;
  801dd8:	eb 0d                	jmp    801de7 <open+0x90>
        }
        return fd2num(fd);
  801dda:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ddd:	89 04 24             	mov    %eax,(%esp)
  801de0:	e8 4b f7 ff ff       	call   801530 <fd2num>
  801de5:	89 c3                	mov    %eax,%ebx
	//panic("open not implemented");
}
  801de7:	89 d8                	mov    %ebx,%eax
  801de9:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801dec:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801def:	89 ec                	mov    %ebp,%esp
  801df1:	5d                   	pop    %ebp
  801df2:	c3                   	ret    
	...

00801e00 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801e00:	55                   	push   %ebp
  801e01:	89 e5                	mov    %esp,%ebp
  801e03:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  801e06:	c7 44 24 04 b4 2b 80 	movl   $0x802bb4,0x4(%esp)
  801e0d:	00 
  801e0e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e11:	89 04 24             	mov    %eax,(%esp)
  801e14:	e8 41 ec ff ff       	call   800a5a <strcpy>
	return 0;
}
  801e19:	b8 00 00 00 00       	mov    $0x0,%eax
  801e1e:	c9                   	leave  
  801e1f:	c3                   	ret    

00801e20 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801e20:	55                   	push   %ebp
  801e21:	89 e5                	mov    %esp,%ebp
  801e23:	53                   	push   %ebx
  801e24:	83 ec 14             	sub    $0x14,%esp
  801e27:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801e2a:	89 1c 24             	mov    %ebx,(%esp)
  801e2d:	e8 6a 06 00 00       	call   80249c <pageref>
  801e32:	89 c2                	mov    %eax,%edx
  801e34:	b8 00 00 00 00       	mov    $0x0,%eax
  801e39:	83 fa 01             	cmp    $0x1,%edx
  801e3c:	75 0b                	jne    801e49 <devsock_close+0x29>
		return nsipc_close(fd->fd_sock.sockid);
  801e3e:	8b 43 0c             	mov    0xc(%ebx),%eax
  801e41:	89 04 24             	mov    %eax,(%esp)
  801e44:	e8 b9 02 00 00       	call   802102 <nsipc_close>
	else
		return 0;
}
  801e49:	83 c4 14             	add    $0x14,%esp
  801e4c:	5b                   	pop    %ebx
  801e4d:	5d                   	pop    %ebp
  801e4e:	c3                   	ret    

00801e4f <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801e4f:	55                   	push   %ebp
  801e50:	89 e5                	mov    %esp,%ebp
  801e52:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801e55:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801e5c:	00 
  801e5d:	8b 45 10             	mov    0x10(%ebp),%eax
  801e60:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e64:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e67:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e6b:	8b 45 08             	mov    0x8(%ebp),%eax
  801e6e:	8b 40 0c             	mov    0xc(%eax),%eax
  801e71:	89 04 24             	mov    %eax,(%esp)
  801e74:	e8 c5 02 00 00       	call   80213e <nsipc_send>
}
  801e79:	c9                   	leave  
  801e7a:	c3                   	ret    

00801e7b <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801e7b:	55                   	push   %ebp
  801e7c:	89 e5                	mov    %esp,%ebp
  801e7e:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801e81:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801e88:	00 
  801e89:	8b 45 10             	mov    0x10(%ebp),%eax
  801e8c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e90:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e93:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e97:	8b 45 08             	mov    0x8(%ebp),%eax
  801e9a:	8b 40 0c             	mov    0xc(%eax),%eax
  801e9d:	89 04 24             	mov    %eax,(%esp)
  801ea0:	e8 0c 03 00 00       	call   8021b1 <nsipc_recv>
}
  801ea5:	c9                   	leave  
  801ea6:	c3                   	ret    

00801ea7 <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  801ea7:	55                   	push   %ebp
  801ea8:	89 e5                	mov    %esp,%ebp
  801eaa:	56                   	push   %esi
  801eab:	53                   	push   %ebx
  801eac:	83 ec 20             	sub    $0x20,%esp
  801eaf:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801eb1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801eb4:	89 04 24             	mov    %eax,(%esp)
  801eb7:	e8 9f f6 ff ff       	call   80155b <fd_alloc>
  801ebc:	89 c3                	mov    %eax,%ebx
  801ebe:	85 c0                	test   %eax,%eax
  801ec0:	78 21                	js     801ee3 <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801ec2:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801ec9:	00 
  801eca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ecd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ed1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ed8:	e8 ab f4 ff ff       	call   801388 <sys_page_alloc>
  801edd:	89 c3                	mov    %eax,%ebx
alloc_sockfd(int sockid)
{
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801edf:	85 c0                	test   %eax,%eax
  801ee1:	79 0a                	jns    801eed <alloc_sockfd+0x46>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
		nsipc_close(sockid);
  801ee3:	89 34 24             	mov    %esi,(%esp)
  801ee6:	e8 17 02 00 00       	call   802102 <nsipc_close>
		return r;
  801eeb:	eb 28                	jmp    801f15 <alloc_sockfd+0x6e>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801eed:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801ef3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ef6:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801ef8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801efb:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801f02:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f05:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801f08:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f0b:	89 04 24             	mov    %eax,(%esp)
  801f0e:	e8 1d f6 ff ff       	call   801530 <fd2num>
  801f13:	89 c3                	mov    %eax,%ebx
}
  801f15:	89 d8                	mov    %ebx,%eax
  801f17:	83 c4 20             	add    $0x20,%esp
  801f1a:	5b                   	pop    %ebx
  801f1b:	5e                   	pop    %esi
  801f1c:	5d                   	pop    %ebp
  801f1d:	c3                   	ret    

00801f1e <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801f1e:	55                   	push   %ebp
  801f1f:	89 e5                	mov    %esp,%ebp
  801f21:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801f24:	8b 45 10             	mov    0x10(%ebp),%eax
  801f27:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f2b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f2e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f32:	8b 45 08             	mov    0x8(%ebp),%eax
  801f35:	89 04 24             	mov    %eax,(%esp)
  801f38:	e8 79 01 00 00       	call   8020b6 <nsipc_socket>
  801f3d:	85 c0                	test   %eax,%eax
  801f3f:	78 05                	js     801f46 <socket+0x28>
		return r;
	return alloc_sockfd(r);
  801f41:	e8 61 ff ff ff       	call   801ea7 <alloc_sockfd>
}
  801f46:	c9                   	leave  
  801f47:	c3                   	ret    

00801f48 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801f48:	55                   	push   %ebp
  801f49:	89 e5                	mov    %esp,%ebp
  801f4b:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801f4e:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801f51:	89 54 24 04          	mov    %edx,0x4(%esp)
  801f55:	89 04 24             	mov    %eax,(%esp)
  801f58:	e8 70 f6 ff ff       	call   8015cd <fd_lookup>
  801f5d:	85 c0                	test   %eax,%eax
  801f5f:	78 15                	js     801f76 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801f61:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801f64:	8b 0a                	mov    (%edx),%ecx
  801f66:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801f6b:	3b 0d 20 30 80 00    	cmp    0x803020,%ecx
  801f71:	75 03                	jne    801f76 <fd2sockid+0x2e>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801f73:	8b 42 0c             	mov    0xc(%edx),%eax
}
  801f76:	c9                   	leave  
  801f77:	c3                   	ret    

00801f78 <listen>:
	return nsipc_connect(r, name, namelen);
}

int
listen(int s, int backlog)
{
  801f78:	55                   	push   %ebp
  801f79:	89 e5                	mov    %esp,%ebp
  801f7b:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801f7e:	8b 45 08             	mov    0x8(%ebp),%eax
  801f81:	e8 c2 ff ff ff       	call   801f48 <fd2sockid>
  801f86:	85 c0                	test   %eax,%eax
  801f88:	78 0f                	js     801f99 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801f8a:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f8d:	89 54 24 04          	mov    %edx,0x4(%esp)
  801f91:	89 04 24             	mov    %eax,(%esp)
  801f94:	e8 47 01 00 00       	call   8020e0 <nsipc_listen>
}
  801f99:	c9                   	leave  
  801f9a:	c3                   	ret    

00801f9b <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801f9b:	55                   	push   %ebp
  801f9c:	89 e5                	mov    %esp,%ebp
  801f9e:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801fa1:	8b 45 08             	mov    0x8(%ebp),%eax
  801fa4:	e8 9f ff ff ff       	call   801f48 <fd2sockid>
  801fa9:	85 c0                	test   %eax,%eax
  801fab:	78 16                	js     801fc3 <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  801fad:	8b 55 10             	mov    0x10(%ebp),%edx
  801fb0:	89 54 24 08          	mov    %edx,0x8(%esp)
  801fb4:	8b 55 0c             	mov    0xc(%ebp),%edx
  801fb7:	89 54 24 04          	mov    %edx,0x4(%esp)
  801fbb:	89 04 24             	mov    %eax,(%esp)
  801fbe:	e8 6e 02 00 00       	call   802231 <nsipc_connect>
}
  801fc3:	c9                   	leave  
  801fc4:	c3                   	ret    

00801fc5 <shutdown>:
	return nsipc_bind(r, name, namelen);
}

int
shutdown(int s, int how)
{
  801fc5:	55                   	push   %ebp
  801fc6:	89 e5                	mov    %esp,%ebp
  801fc8:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801fcb:	8b 45 08             	mov    0x8(%ebp),%eax
  801fce:	e8 75 ff ff ff       	call   801f48 <fd2sockid>
  801fd3:	85 c0                	test   %eax,%eax
  801fd5:	78 0f                	js     801fe6 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801fd7:	8b 55 0c             	mov    0xc(%ebp),%edx
  801fda:	89 54 24 04          	mov    %edx,0x4(%esp)
  801fde:	89 04 24             	mov    %eax,(%esp)
  801fe1:	e8 36 01 00 00       	call   80211c <nsipc_shutdown>
}
  801fe6:	c9                   	leave  
  801fe7:	c3                   	ret    

00801fe8 <bind>:
	return alloc_sockfd(r);
}

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801fe8:	55                   	push   %ebp
  801fe9:	89 e5                	mov    %esp,%ebp
  801feb:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801fee:	8b 45 08             	mov    0x8(%ebp),%eax
  801ff1:	e8 52 ff ff ff       	call   801f48 <fd2sockid>
  801ff6:	85 c0                	test   %eax,%eax
  801ff8:	78 16                	js     802010 <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  801ffa:	8b 55 10             	mov    0x10(%ebp),%edx
  801ffd:	89 54 24 08          	mov    %edx,0x8(%esp)
  802001:	8b 55 0c             	mov    0xc(%ebp),%edx
  802004:	89 54 24 04          	mov    %edx,0x4(%esp)
  802008:	89 04 24             	mov    %eax,(%esp)
  80200b:	e8 60 02 00 00       	call   802270 <nsipc_bind>
}
  802010:	c9                   	leave  
  802011:	c3                   	ret    

00802012 <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  802012:	55                   	push   %ebp
  802013:	89 e5                	mov    %esp,%ebp
  802015:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802018:	8b 45 08             	mov    0x8(%ebp),%eax
  80201b:	e8 28 ff ff ff       	call   801f48 <fd2sockid>
  802020:	85 c0                	test   %eax,%eax
  802022:	78 1f                	js     802043 <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  802024:	8b 55 10             	mov    0x10(%ebp),%edx
  802027:	89 54 24 08          	mov    %edx,0x8(%esp)
  80202b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80202e:	89 54 24 04          	mov    %edx,0x4(%esp)
  802032:	89 04 24             	mov    %eax,(%esp)
  802035:	e8 75 02 00 00       	call   8022af <nsipc_accept>
  80203a:	85 c0                	test   %eax,%eax
  80203c:	78 05                	js     802043 <accept+0x31>
		return r;
	return alloc_sockfd(r);
  80203e:	e8 64 fe ff ff       	call   801ea7 <alloc_sockfd>
}
  802043:	c9                   	leave  
  802044:	c3                   	ret    
	...

00802050 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  802050:	55                   	push   %ebp
  802051:	89 e5                	mov    %esp,%ebp
  802053:	53                   	push   %ebx
  802054:	83 ec 14             	sub    $0x14,%esp
  802057:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  802059:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  802060:	75 11                	jne    802073 <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  802062:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  802069:	e8 f2 02 00 00       	call   802360 <ipc_find_env>
  80206e:	a3 04 40 80 00       	mov    %eax,0x804004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  802073:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80207a:	00 
  80207b:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  802082:	00 
  802083:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802087:	a1 04 40 80 00       	mov    0x804004,%eax
  80208c:	89 04 24             	mov    %eax,(%esp)
  80208f:	e8 17 03 00 00       	call   8023ab <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  802094:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80209b:	00 
  80209c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8020a3:	00 
  8020a4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020ab:	e8 79 03 00 00       	call   802429 <ipc_recv>
}
  8020b0:	83 c4 14             	add    $0x14,%esp
  8020b3:	5b                   	pop    %ebx
  8020b4:	5d                   	pop    %ebp
  8020b5:	c3                   	ret    

008020b6 <nsipc_socket>:
	return nsipc(NSREQ_SEND);
}

int
nsipc_socket(int domain, int type, int protocol)
{
  8020b6:	55                   	push   %ebp
  8020b7:	89 e5                	mov    %esp,%ebp
  8020b9:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  8020bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8020bf:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  8020c4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020c7:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  8020cc:	8b 45 10             	mov    0x10(%ebp),%eax
  8020cf:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  8020d4:	b8 09 00 00 00       	mov    $0x9,%eax
  8020d9:	e8 72 ff ff ff       	call   802050 <nsipc>
}
  8020de:	c9                   	leave  
  8020df:	c3                   	ret    

008020e0 <nsipc_listen>:
	return nsipc(NSREQ_CONNECT);
}

int
nsipc_listen(int s, int backlog)
{
  8020e0:	55                   	push   %ebp
  8020e1:	89 e5                	mov    %esp,%ebp
  8020e3:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  8020e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8020e9:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  8020ee:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020f1:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  8020f6:	b8 06 00 00 00       	mov    $0x6,%eax
  8020fb:	e8 50 ff ff ff       	call   802050 <nsipc>
}
  802100:	c9                   	leave  
  802101:	c3                   	ret    

00802102 <nsipc_close>:
	return nsipc(NSREQ_SHUTDOWN);
}

int
nsipc_close(int s)
{
  802102:	55                   	push   %ebp
  802103:	89 e5                	mov    %esp,%ebp
  802105:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  802108:	8b 45 08             	mov    0x8(%ebp),%eax
  80210b:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  802110:	b8 04 00 00 00       	mov    $0x4,%eax
  802115:	e8 36 ff ff ff       	call   802050 <nsipc>
}
  80211a:	c9                   	leave  
  80211b:	c3                   	ret    

0080211c <nsipc_shutdown>:
	return nsipc(NSREQ_BIND);
}

int
nsipc_shutdown(int s, int how)
{
  80211c:	55                   	push   %ebp
  80211d:	89 e5                	mov    %esp,%ebp
  80211f:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  802122:	8b 45 08             	mov    0x8(%ebp),%eax
  802125:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  80212a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80212d:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  802132:	b8 03 00 00 00       	mov    $0x3,%eax
  802137:	e8 14 ff ff ff       	call   802050 <nsipc>
}
  80213c:	c9                   	leave  
  80213d:	c3                   	ret    

0080213e <nsipc_send>:
	return r;
}

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  80213e:	55                   	push   %ebp
  80213f:	89 e5                	mov    %esp,%ebp
  802141:	53                   	push   %ebx
  802142:	83 ec 14             	sub    $0x14,%esp
  802145:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  802148:	8b 45 08             	mov    0x8(%ebp),%eax
  80214b:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  802150:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  802156:	7e 24                	jle    80217c <nsipc_send+0x3e>
  802158:	c7 44 24 0c c0 2b 80 	movl   $0x802bc0,0xc(%esp)
  80215f:	00 
  802160:	c7 44 24 08 cc 2b 80 	movl   $0x802bcc,0x8(%esp)
  802167:	00 
  802168:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
  80216f:	00 
  802170:	c7 04 24 e1 2b 80 00 	movl   $0x802be1,(%esp)
  802177:	e8 88 01 00 00       	call   802304 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  80217c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802180:	8b 45 0c             	mov    0xc(%ebp),%eax
  802183:	89 44 24 04          	mov    %eax,0x4(%esp)
  802187:	c7 04 24 0c 60 80 00 	movl   $0x80600c,(%esp)
  80218e:	e8 b2 ea ff ff       	call   800c45 <memmove>
	nsipcbuf.send.req_size = size;
  802193:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  802199:	8b 45 14             	mov    0x14(%ebp),%eax
  80219c:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  8021a1:	b8 08 00 00 00       	mov    $0x8,%eax
  8021a6:	e8 a5 fe ff ff       	call   802050 <nsipc>
}
  8021ab:	83 c4 14             	add    $0x14,%esp
  8021ae:	5b                   	pop    %ebx
  8021af:	5d                   	pop    %ebp
  8021b0:	c3                   	ret    

008021b1 <nsipc_recv>:
	return nsipc(NSREQ_LISTEN);
}

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  8021b1:	55                   	push   %ebp
  8021b2:	89 e5                	mov    %esp,%ebp
  8021b4:	56                   	push   %esi
  8021b5:	53                   	push   %ebx
  8021b6:	83 ec 10             	sub    $0x10,%esp
  8021b9:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  8021bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8021bf:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  8021c4:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  8021ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8021cd:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  8021d2:	b8 07 00 00 00       	mov    $0x7,%eax
  8021d7:	e8 74 fe ff ff       	call   802050 <nsipc>
  8021dc:	89 c3                	mov    %eax,%ebx
  8021de:	85 c0                	test   %eax,%eax
  8021e0:	78 46                	js     802228 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  8021e2:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  8021e7:	7f 04                	jg     8021ed <nsipc_recv+0x3c>
  8021e9:	39 c6                	cmp    %eax,%esi
  8021eb:	7d 24                	jge    802211 <nsipc_recv+0x60>
  8021ed:	c7 44 24 0c ed 2b 80 	movl   $0x802bed,0xc(%esp)
  8021f4:	00 
  8021f5:	c7 44 24 08 cc 2b 80 	movl   $0x802bcc,0x8(%esp)
  8021fc:	00 
  8021fd:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
  802204:	00 
  802205:	c7 04 24 e1 2b 80 00 	movl   $0x802be1,(%esp)
  80220c:	e8 f3 00 00 00       	call   802304 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  802211:	89 44 24 08          	mov    %eax,0x8(%esp)
  802215:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  80221c:	00 
  80221d:	8b 45 0c             	mov    0xc(%ebp),%eax
  802220:	89 04 24             	mov    %eax,(%esp)
  802223:	e8 1d ea ff ff       	call   800c45 <memmove>
	}

	return r;
}
  802228:	89 d8                	mov    %ebx,%eax
  80222a:	83 c4 10             	add    $0x10,%esp
  80222d:	5b                   	pop    %ebx
  80222e:	5e                   	pop    %esi
  80222f:	5d                   	pop    %ebp
  802230:	c3                   	ret    

00802231 <nsipc_connect>:
	return nsipc(NSREQ_CLOSE);
}

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  802231:	55                   	push   %ebp
  802232:	89 e5                	mov    %esp,%ebp
  802234:	53                   	push   %ebx
  802235:	83 ec 14             	sub    $0x14,%esp
  802238:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  80223b:	8b 45 08             	mov    0x8(%ebp),%eax
  80223e:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  802243:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802247:	8b 45 0c             	mov    0xc(%ebp),%eax
  80224a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80224e:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  802255:	e8 eb e9 ff ff       	call   800c45 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  80225a:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  802260:	b8 05 00 00 00       	mov    $0x5,%eax
  802265:	e8 e6 fd ff ff       	call   802050 <nsipc>
}
  80226a:	83 c4 14             	add    $0x14,%esp
  80226d:	5b                   	pop    %ebx
  80226e:	5d                   	pop    %ebp
  80226f:	c3                   	ret    

00802270 <nsipc_bind>:
	return r;
}

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802270:	55                   	push   %ebp
  802271:	89 e5                	mov    %esp,%ebp
  802273:	53                   	push   %ebx
  802274:	83 ec 14             	sub    $0x14,%esp
  802277:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  80227a:	8b 45 08             	mov    0x8(%ebp),%eax
  80227d:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  802282:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802286:	8b 45 0c             	mov    0xc(%ebp),%eax
  802289:	89 44 24 04          	mov    %eax,0x4(%esp)
  80228d:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  802294:	e8 ac e9 ff ff       	call   800c45 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  802299:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  80229f:	b8 02 00 00 00       	mov    $0x2,%eax
  8022a4:	e8 a7 fd ff ff       	call   802050 <nsipc>
}
  8022a9:	83 c4 14             	add    $0x14,%esp
  8022ac:	5b                   	pop    %ebx
  8022ad:	5d                   	pop    %ebp
  8022ae:	c3                   	ret    

008022af <nsipc_accept>:
	return ipc_recv(NULL, NULL, NULL);
}

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8022af:	55                   	push   %ebp
  8022b0:	89 e5                	mov    %esp,%ebp
  8022b2:	83 ec 18             	sub    $0x18,%esp
  8022b5:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8022b8:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int r;

	nsipcbuf.accept.req_s = s;
  8022bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8022be:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  8022c3:	b8 01 00 00 00       	mov    $0x1,%eax
  8022c8:	e8 83 fd ff ff       	call   802050 <nsipc>
  8022cd:	89 c3                	mov    %eax,%ebx
  8022cf:	85 c0                	test   %eax,%eax
  8022d1:	78 25                	js     8022f8 <nsipc_accept+0x49>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  8022d3:	be 10 60 80 00       	mov    $0x806010,%esi
  8022d8:	8b 06                	mov    (%esi),%eax
  8022da:	89 44 24 08          	mov    %eax,0x8(%esp)
  8022de:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  8022e5:	00 
  8022e6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022e9:	89 04 24             	mov    %eax,(%esp)
  8022ec:	e8 54 e9 ff ff       	call   800c45 <memmove>
		*addrlen = ret->ret_addrlen;
  8022f1:	8b 16                	mov    (%esi),%edx
  8022f3:	8b 45 10             	mov    0x10(%ebp),%eax
  8022f6:	89 10                	mov    %edx,(%eax)
	}
	return r;
}
  8022f8:	89 d8                	mov    %ebx,%eax
  8022fa:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8022fd:	8b 75 fc             	mov    -0x4(%ebp),%esi
  802300:	89 ec                	mov    %ebp,%esp
  802302:	5d                   	pop    %ebp
  802303:	c3                   	ret    

00802304 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  802304:	55                   	push   %ebp
  802305:	89 e5                	mov    %esp,%ebp
  802307:	56                   	push   %esi
  802308:	53                   	push   %ebx
  802309:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  80230c:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80230f:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  802315:	e8 5d f1 ff ff       	call   801477 <sys_getenvid>
  80231a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80231d:	89 54 24 10          	mov    %edx,0x10(%esp)
  802321:	8b 55 08             	mov    0x8(%ebp),%edx
  802324:	89 54 24 0c          	mov    %edx,0xc(%esp)
  802328:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80232c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802330:	c7 04 24 04 2c 80 00 	movl   $0x802c04,(%esp)
  802337:	e8 f5 dd ff ff       	call   800131 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80233c:	89 74 24 04          	mov    %esi,0x4(%esp)
  802340:	8b 45 10             	mov    0x10(%ebp),%eax
  802343:	89 04 24             	mov    %eax,(%esp)
  802346:	e8 85 dd ff ff       	call   8000d0 <vcprintf>
	cprintf("\n");
  80234b:	c7 04 24 6c 27 80 00 	movl   $0x80276c,(%esp)
  802352:	e8 da dd ff ff       	call   800131 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  802357:	cc                   	int3   
  802358:	eb fd                	jmp    802357 <_panic+0x53>
  80235a:	00 00                	add    %al,(%eax)
  80235c:	00 00                	add    %al,(%eax)
	...

00802360 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802360:	55                   	push   %ebp
  802361:	89 e5                	mov    %esp,%ebp
  802363:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  802366:	8b 15 50 00 c0 ee    	mov    0xeec00050,%edx
  80236c:	b8 01 00 00 00       	mov    $0x1,%eax
  802371:	39 ca                	cmp    %ecx,%edx
  802373:	75 04                	jne    802379 <ipc_find_env+0x19>
  802375:	b0 00                	mov    $0x0,%al
  802377:	eb 12                	jmp    80238b <ipc_find_env+0x2b>
  802379:	89 c2                	mov    %eax,%edx
  80237b:	c1 e2 07             	shl    $0x7,%edx
  80237e:	8d 94 82 50 00 c0 ee 	lea    -0x113fffb0(%edx,%eax,4),%edx
  802385:	8b 12                	mov    (%edx),%edx
  802387:	39 ca                	cmp    %ecx,%edx
  802389:	75 10                	jne    80239b <ipc_find_env+0x3b>
			return envs[i].env_id;
  80238b:	89 c2                	mov    %eax,%edx
  80238d:	c1 e2 07             	shl    $0x7,%edx
  802390:	8d 84 82 48 00 c0 ee 	lea    -0x113fffb8(%edx,%eax,4),%eax
  802397:	8b 00                	mov    (%eax),%eax
  802399:	eb 0e                	jmp    8023a9 <ipc_find_env+0x49>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80239b:	83 c0 01             	add    $0x1,%eax
  80239e:	3d 00 04 00 00       	cmp    $0x400,%eax
  8023a3:	75 d4                	jne    802379 <ipc_find_env+0x19>
  8023a5:	66 b8 00 00          	mov    $0x0,%ax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  8023a9:	5d                   	pop    %ebp
  8023aa:	c3                   	ret    

008023ab <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8023ab:	55                   	push   %ebp
  8023ac:	89 e5                	mov    %esp,%ebp
  8023ae:	57                   	push   %edi
  8023af:	56                   	push   %esi
  8023b0:	53                   	push   %ebx
  8023b1:	83 ec 1c             	sub    $0x1c,%esp
  8023b4:	8b 75 08             	mov    0x8(%ebp),%esi
  8023b7:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8023ba:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        int ret;
        while(1){
           if(pg)
  8023bd:	85 db                	test   %ebx,%ebx
  8023bf:	74 19                	je     8023da <ipc_send+0x2f>
              ret = sys_ipc_try_send(to_env,val,pg,perm);
  8023c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8023c4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8023c8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8023cc:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8023d0:	89 34 24             	mov    %esi,(%esp)
  8023d3:	e8 51 ed ff ff       	call   801129 <sys_ipc_try_send>
  8023d8:	eb 1b                	jmp    8023f5 <ipc_send+0x4a>
           else
              ret = sys_ipc_try_send(to_env,val,(void*)UTOP,perm);
  8023da:	8b 45 14             	mov    0x14(%ebp),%eax
  8023dd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8023e1:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  8023e8:	ee 
  8023e9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8023ed:	89 34 24             	mov    %esi,(%esp)
  8023f0:	e8 34 ed ff ff       	call   801129 <sys_ipc_try_send>
           if(ret == 0)
  8023f5:	85 c0                	test   %eax,%eax
  8023f7:	74 28                	je     802421 <ipc_send+0x76>
              return;
           if(ret != -E_IPC_NOT_RECV)
  8023f9:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8023fc:	74 1c                	je     80241a <ipc_send+0x6f>
              panic("ipc send error");
  8023fe:	c7 44 24 08 28 2c 80 	movl   $0x802c28,0x8(%esp)
  802405:	00 
  802406:	c7 44 24 04 46 00 00 	movl   $0x46,0x4(%esp)
  80240d:	00 
  80240e:	c7 04 24 37 2c 80 00 	movl   $0x802c37,(%esp)
  802415:	e8 ea fe ff ff       	call   802304 <_panic>
           sys_yield();
  80241a:	e8 d6 ef ff ff       	call   8013f5 <sys_yield>
        }
  80241f:	eb 9c                	jmp    8023bd <ipc_send+0x12>
	//panic("ipc_send not implemented");
}
  802421:	83 c4 1c             	add    $0x1c,%esp
  802424:	5b                   	pop    %ebx
  802425:	5e                   	pop    %esi
  802426:	5f                   	pop    %edi
  802427:	5d                   	pop    %ebp
  802428:	c3                   	ret    

00802429 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802429:	55                   	push   %ebp
  80242a:	89 e5                	mov    %esp,%ebp
  80242c:	56                   	push   %esi
  80242d:	53                   	push   %ebx
  80242e:	83 ec 10             	sub    $0x10,%esp
  802431:	8b 75 08             	mov    0x8(%ebp),%esi
  802434:	8b 45 0c             	mov    0xc(%ebp),%eax
  802437:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        int ret;
        if(!pg)
  80243a:	85 c0                	test   %eax,%eax
  80243c:	75 0e                	jne    80244c <ipc_recv+0x23>
           ret = sys_ipc_recv((void*)UTOP);
  80243e:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  802445:	e8 74 ec ff ff       	call   8010be <sys_ipc_recv>
  80244a:	eb 08                	jmp    802454 <ipc_recv+0x2b>
        else
           ret = sys_ipc_recv(pg);
  80244c:	89 04 24             	mov    %eax,(%esp)
  80244f:	e8 6a ec ff ff       	call   8010be <sys_ipc_recv>
        if(ret == 0){
  802454:	85 c0                	test   %eax,%eax
  802456:	75 26                	jne    80247e <ipc_recv+0x55>
           if(from_env_store)
  802458:	85 f6                	test   %esi,%esi
  80245a:	74 0a                	je     802466 <ipc_recv+0x3d>
              *from_env_store = thisenv->env_ipc_from;
  80245c:	a1 08 40 80 00       	mov    0x804008,%eax
  802461:	8b 40 78             	mov    0x78(%eax),%eax
  802464:	89 06                	mov    %eax,(%esi)
           if(perm_store)
  802466:	85 db                	test   %ebx,%ebx
  802468:	74 0a                	je     802474 <ipc_recv+0x4b>
              *perm_store = thisenv->env_ipc_perm;
  80246a:	a1 08 40 80 00       	mov    0x804008,%eax
  80246f:	8b 40 7c             	mov    0x7c(%eax),%eax
  802472:	89 03                	mov    %eax,(%ebx)
           return thisenv->env_ipc_value;
  802474:	a1 08 40 80 00       	mov    0x804008,%eax
  802479:	8b 40 74             	mov    0x74(%eax),%eax
  80247c:	eb 14                	jmp    802492 <ipc_recv+0x69>
        }
        else{
           if(from_env_store)
  80247e:	85 f6                	test   %esi,%esi
  802480:	74 06                	je     802488 <ipc_recv+0x5f>
              *from_env_store = 0;
  802482:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
           if(perm_store)
  802488:	85 db                	test   %ebx,%ebx
  80248a:	74 06                	je     802492 <ipc_recv+0x69>
              *perm_store = 0;
  80248c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
           return ret;
        }
	//panic("ipc_recv not implemented");
	return 0;
}
  802492:	83 c4 10             	add    $0x10,%esp
  802495:	5b                   	pop    %ebx
  802496:	5e                   	pop    %esi
  802497:	5d                   	pop    %ebp
  802498:	c3                   	ret    
  802499:	00 00                	add    %al,(%eax)
	...

0080249c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80249c:	55                   	push   %ebp
  80249d:	89 e5                	mov    %esp,%ebp
	pte_t pte;

	if (!(vpd[PDX(v)] & PTE_P))
  80249f:	8b 45 08             	mov    0x8(%ebp),%eax
  8024a2:	89 c2                	mov    %eax,%edx
  8024a4:	c1 ea 16             	shr    $0x16,%edx
  8024a7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8024ae:	f6 c2 01             	test   $0x1,%dl
  8024b1:	74 20                	je     8024d3 <pageref+0x37>
		return 0;
	pte = vpt[PGNUM(v)];
  8024b3:	c1 e8 0c             	shr    $0xc,%eax
  8024b6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8024bd:	a8 01                	test   $0x1,%al
  8024bf:	74 12                	je     8024d3 <pageref+0x37>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8024c1:	c1 e8 0c             	shr    $0xc,%eax
  8024c4:	ba 00 00 00 ef       	mov    $0xef000000,%edx
  8024c9:	0f b7 44 c2 04       	movzwl 0x4(%edx,%eax,8),%eax
  8024ce:	0f b7 c0             	movzwl %ax,%eax
  8024d1:	eb 05                	jmp    8024d8 <pageref+0x3c>
  8024d3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8024d8:	5d                   	pop    %ebp
  8024d9:	c3                   	ret    
  8024da:	00 00                	add    %al,(%eax)
  8024dc:	00 00                	add    %al,(%eax)
	...

008024e0 <__udivdi3>:
  8024e0:	55                   	push   %ebp
  8024e1:	89 e5                	mov    %esp,%ebp
  8024e3:	57                   	push   %edi
  8024e4:	56                   	push   %esi
  8024e5:	83 ec 10             	sub    $0x10,%esp
  8024e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8024eb:	8b 55 08             	mov    0x8(%ebp),%edx
  8024ee:	8b 75 10             	mov    0x10(%ebp),%esi
  8024f1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8024f4:	85 c0                	test   %eax,%eax
  8024f6:	89 55 f0             	mov    %edx,-0x10(%ebp)
  8024f9:	75 35                	jne    802530 <__udivdi3+0x50>
  8024fb:	39 fe                	cmp    %edi,%esi
  8024fd:	77 61                	ja     802560 <__udivdi3+0x80>
  8024ff:	85 f6                	test   %esi,%esi
  802501:	75 0b                	jne    80250e <__udivdi3+0x2e>
  802503:	b8 01 00 00 00       	mov    $0x1,%eax
  802508:	31 d2                	xor    %edx,%edx
  80250a:	f7 f6                	div    %esi
  80250c:	89 c6                	mov    %eax,%esi
  80250e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  802511:	31 d2                	xor    %edx,%edx
  802513:	89 f8                	mov    %edi,%eax
  802515:	f7 f6                	div    %esi
  802517:	89 c7                	mov    %eax,%edi
  802519:	89 c8                	mov    %ecx,%eax
  80251b:	f7 f6                	div    %esi
  80251d:	89 c1                	mov    %eax,%ecx
  80251f:	89 fa                	mov    %edi,%edx
  802521:	89 c8                	mov    %ecx,%eax
  802523:	83 c4 10             	add    $0x10,%esp
  802526:	5e                   	pop    %esi
  802527:	5f                   	pop    %edi
  802528:	5d                   	pop    %ebp
  802529:	c3                   	ret    
  80252a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802530:	39 f8                	cmp    %edi,%eax
  802532:	77 1c                	ja     802550 <__udivdi3+0x70>
  802534:	0f bd d0             	bsr    %eax,%edx
  802537:	83 f2 1f             	xor    $0x1f,%edx
  80253a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80253d:	75 39                	jne    802578 <__udivdi3+0x98>
  80253f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  802542:	0f 86 a0 00 00 00    	jbe    8025e8 <__udivdi3+0x108>
  802548:	39 f8                	cmp    %edi,%eax
  80254a:	0f 82 98 00 00 00    	jb     8025e8 <__udivdi3+0x108>
  802550:	31 ff                	xor    %edi,%edi
  802552:	31 c9                	xor    %ecx,%ecx
  802554:	89 c8                	mov    %ecx,%eax
  802556:	89 fa                	mov    %edi,%edx
  802558:	83 c4 10             	add    $0x10,%esp
  80255b:	5e                   	pop    %esi
  80255c:	5f                   	pop    %edi
  80255d:	5d                   	pop    %ebp
  80255e:	c3                   	ret    
  80255f:	90                   	nop
  802560:	89 d1                	mov    %edx,%ecx
  802562:	89 fa                	mov    %edi,%edx
  802564:	89 c8                	mov    %ecx,%eax
  802566:	31 ff                	xor    %edi,%edi
  802568:	f7 f6                	div    %esi
  80256a:	89 c1                	mov    %eax,%ecx
  80256c:	89 fa                	mov    %edi,%edx
  80256e:	89 c8                	mov    %ecx,%eax
  802570:	83 c4 10             	add    $0x10,%esp
  802573:	5e                   	pop    %esi
  802574:	5f                   	pop    %edi
  802575:	5d                   	pop    %ebp
  802576:	c3                   	ret    
  802577:	90                   	nop
  802578:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80257c:	89 f2                	mov    %esi,%edx
  80257e:	d3 e0                	shl    %cl,%eax
  802580:	89 45 ec             	mov    %eax,-0x14(%ebp)
  802583:	b8 20 00 00 00       	mov    $0x20,%eax
  802588:	2b 45 f4             	sub    -0xc(%ebp),%eax
  80258b:	89 c1                	mov    %eax,%ecx
  80258d:	d3 ea                	shr    %cl,%edx
  80258f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  802593:	0b 55 ec             	or     -0x14(%ebp),%edx
  802596:	d3 e6                	shl    %cl,%esi
  802598:	89 c1                	mov    %eax,%ecx
  80259a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  80259d:	89 fe                	mov    %edi,%esi
  80259f:	d3 ee                	shr    %cl,%esi
  8025a1:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8025a5:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8025a8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8025ab:	d3 e7                	shl    %cl,%edi
  8025ad:	89 c1                	mov    %eax,%ecx
  8025af:	d3 ea                	shr    %cl,%edx
  8025b1:	09 d7                	or     %edx,%edi
  8025b3:	89 f2                	mov    %esi,%edx
  8025b5:	89 f8                	mov    %edi,%eax
  8025b7:	f7 75 ec             	divl   -0x14(%ebp)
  8025ba:	89 d6                	mov    %edx,%esi
  8025bc:	89 c7                	mov    %eax,%edi
  8025be:	f7 65 e8             	mull   -0x18(%ebp)
  8025c1:	39 d6                	cmp    %edx,%esi
  8025c3:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8025c6:	72 30                	jb     8025f8 <__udivdi3+0x118>
  8025c8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8025cb:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8025cf:	d3 e2                	shl    %cl,%edx
  8025d1:	39 c2                	cmp    %eax,%edx
  8025d3:	73 05                	jae    8025da <__udivdi3+0xfa>
  8025d5:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  8025d8:	74 1e                	je     8025f8 <__udivdi3+0x118>
  8025da:	89 f9                	mov    %edi,%ecx
  8025dc:	31 ff                	xor    %edi,%edi
  8025de:	e9 71 ff ff ff       	jmp    802554 <__udivdi3+0x74>
  8025e3:	90                   	nop
  8025e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8025e8:	31 ff                	xor    %edi,%edi
  8025ea:	b9 01 00 00 00       	mov    $0x1,%ecx
  8025ef:	e9 60 ff ff ff       	jmp    802554 <__udivdi3+0x74>
  8025f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8025f8:	8d 4f ff             	lea    -0x1(%edi),%ecx
  8025fb:	31 ff                	xor    %edi,%edi
  8025fd:	89 c8                	mov    %ecx,%eax
  8025ff:	89 fa                	mov    %edi,%edx
  802601:	83 c4 10             	add    $0x10,%esp
  802604:	5e                   	pop    %esi
  802605:	5f                   	pop    %edi
  802606:	5d                   	pop    %ebp
  802607:	c3                   	ret    
	...

00802610 <__umoddi3>:
  802610:	55                   	push   %ebp
  802611:	89 e5                	mov    %esp,%ebp
  802613:	57                   	push   %edi
  802614:	56                   	push   %esi
  802615:	83 ec 20             	sub    $0x20,%esp
  802618:	8b 55 14             	mov    0x14(%ebp),%edx
  80261b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80261e:	8b 7d 10             	mov    0x10(%ebp),%edi
  802621:	8b 75 0c             	mov    0xc(%ebp),%esi
  802624:	85 d2                	test   %edx,%edx
  802626:	89 c8                	mov    %ecx,%eax
  802628:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80262b:	75 13                	jne    802640 <__umoddi3+0x30>
  80262d:	39 f7                	cmp    %esi,%edi
  80262f:	76 3f                	jbe    802670 <__umoddi3+0x60>
  802631:	89 f2                	mov    %esi,%edx
  802633:	f7 f7                	div    %edi
  802635:	89 d0                	mov    %edx,%eax
  802637:	31 d2                	xor    %edx,%edx
  802639:	83 c4 20             	add    $0x20,%esp
  80263c:	5e                   	pop    %esi
  80263d:	5f                   	pop    %edi
  80263e:	5d                   	pop    %ebp
  80263f:	c3                   	ret    
  802640:	39 f2                	cmp    %esi,%edx
  802642:	77 4c                	ja     802690 <__umoddi3+0x80>
  802644:	0f bd ca             	bsr    %edx,%ecx
  802647:	83 f1 1f             	xor    $0x1f,%ecx
  80264a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80264d:	75 51                	jne    8026a0 <__umoddi3+0x90>
  80264f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  802652:	0f 87 e0 00 00 00    	ja     802738 <__umoddi3+0x128>
  802658:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80265b:	29 f8                	sub    %edi,%eax
  80265d:	19 d6                	sbb    %edx,%esi
  80265f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  802662:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802665:	89 f2                	mov    %esi,%edx
  802667:	83 c4 20             	add    $0x20,%esp
  80266a:	5e                   	pop    %esi
  80266b:	5f                   	pop    %edi
  80266c:	5d                   	pop    %ebp
  80266d:	c3                   	ret    
  80266e:	66 90                	xchg   %ax,%ax
  802670:	85 ff                	test   %edi,%edi
  802672:	75 0b                	jne    80267f <__umoddi3+0x6f>
  802674:	b8 01 00 00 00       	mov    $0x1,%eax
  802679:	31 d2                	xor    %edx,%edx
  80267b:	f7 f7                	div    %edi
  80267d:	89 c7                	mov    %eax,%edi
  80267f:	89 f0                	mov    %esi,%eax
  802681:	31 d2                	xor    %edx,%edx
  802683:	f7 f7                	div    %edi
  802685:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802688:	f7 f7                	div    %edi
  80268a:	eb a9                	jmp    802635 <__umoddi3+0x25>
  80268c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802690:	89 c8                	mov    %ecx,%eax
  802692:	89 f2                	mov    %esi,%edx
  802694:	83 c4 20             	add    $0x20,%esp
  802697:	5e                   	pop    %esi
  802698:	5f                   	pop    %edi
  802699:	5d                   	pop    %ebp
  80269a:	c3                   	ret    
  80269b:	90                   	nop
  80269c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8026a0:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8026a4:	d3 e2                	shl    %cl,%edx
  8026a6:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8026a9:	ba 20 00 00 00       	mov    $0x20,%edx
  8026ae:	2b 55 f0             	sub    -0x10(%ebp),%edx
  8026b1:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8026b4:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8026b8:	89 fa                	mov    %edi,%edx
  8026ba:	d3 ea                	shr    %cl,%edx
  8026bc:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8026c0:	0b 55 f4             	or     -0xc(%ebp),%edx
  8026c3:	d3 e7                	shl    %cl,%edi
  8026c5:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8026c9:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8026cc:	89 f2                	mov    %esi,%edx
  8026ce:	89 7d e8             	mov    %edi,-0x18(%ebp)
  8026d1:	89 c7                	mov    %eax,%edi
  8026d3:	d3 ea                	shr    %cl,%edx
  8026d5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8026d9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8026dc:	89 c2                	mov    %eax,%edx
  8026de:	d3 e6                	shl    %cl,%esi
  8026e0:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8026e4:	d3 ea                	shr    %cl,%edx
  8026e6:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8026ea:	09 d6                	or     %edx,%esi
  8026ec:	89 f0                	mov    %esi,%eax
  8026ee:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8026f1:	d3 e7                	shl    %cl,%edi
  8026f3:	89 f2                	mov    %esi,%edx
  8026f5:	f7 75 f4             	divl   -0xc(%ebp)
  8026f8:	89 d6                	mov    %edx,%esi
  8026fa:	f7 65 e8             	mull   -0x18(%ebp)
  8026fd:	39 d6                	cmp    %edx,%esi
  8026ff:	72 2b                	jb     80272c <__umoddi3+0x11c>
  802701:	39 c7                	cmp    %eax,%edi
  802703:	72 23                	jb     802728 <__umoddi3+0x118>
  802705:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802709:	29 c7                	sub    %eax,%edi
  80270b:	19 d6                	sbb    %edx,%esi
  80270d:	89 f0                	mov    %esi,%eax
  80270f:	89 f2                	mov    %esi,%edx
  802711:	d3 ef                	shr    %cl,%edi
  802713:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802717:	d3 e0                	shl    %cl,%eax
  802719:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80271d:	09 f8                	or     %edi,%eax
  80271f:	d3 ea                	shr    %cl,%edx
  802721:	83 c4 20             	add    $0x20,%esp
  802724:	5e                   	pop    %esi
  802725:	5f                   	pop    %edi
  802726:	5d                   	pop    %ebp
  802727:	c3                   	ret    
  802728:	39 d6                	cmp    %edx,%esi
  80272a:	75 d9                	jne    802705 <__umoddi3+0xf5>
  80272c:	2b 45 e8             	sub    -0x18(%ebp),%eax
  80272f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  802732:	eb d1                	jmp    802705 <__umoddi3+0xf5>
  802734:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802738:	39 f2                	cmp    %esi,%edx
  80273a:	0f 82 18 ff ff ff    	jb     802658 <__umoddi3+0x48>
  802740:	e9 1d ff ff ff       	jmp    802662 <__umoddi3+0x52>
