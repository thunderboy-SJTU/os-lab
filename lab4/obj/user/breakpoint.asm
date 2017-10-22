
obj/user/breakpoint:     file format elf32-i386


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
  800049:	c7 04 24 80 16 80 00 	movl   $0x801680,(%esp)
  800050:	e8 fc 00 00 00       	call   800151 <cprintf>
	cprintf("&a equals 0x%x\n",&a);
  800055:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800058:	89 44 24 04          	mov    %eax,0x4(%esp)
  80005c:	c7 04 24 98 16 80 00 	movl   $0x801698,(%esp)
  800063:	e8 e9 00 00 00       	call   800151 <cprintf>
	asm volatile("int $3");
  800068:	cc                   	int3   
	// Try single-step here
	a=20;
  800069:	c7 45 f4 14 00 00 00 	movl   $0x14,-0xc(%ebp)
	cprintf("Finally , a equals %d\n",a);
  800070:	c7 44 24 04 14 00 00 	movl   $0x14,0x4(%esp)
  800077:	00 
  800078:	c7 04 24 a8 16 80 00 	movl   $0x8016a8,(%esp)
  80007f:	e8 cd 00 00 00       	call   800151 <cprintf>
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
  80009a:	e8 46 12 00 00       	call   8012e5 <sys_getenvid>
  80009f:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000a4:	89 c2                	mov    %eax,%edx
  8000a6:	c1 e2 07             	shl    $0x7,%edx
  8000a9:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  8000b0:	a3 04 20 80 00       	mov    %eax,0x802004
        //cprintf("ENVX sys_get_envid(): %d\n",ENVX(sys_getenvid()));
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000b5:	85 f6                	test   %esi,%esi
  8000b7:	7e 07                	jle    8000c0 <libmain+0x38>
		binaryname = argv[0];
  8000b9:	8b 03                	mov    (%ebx),%eax
  8000bb:	a3 00 20 80 00       	mov    %eax,0x802000

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
	sys_env_destroy(0);
  8000e2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000e9:	e8 37 12 00 00       	call   801325 <sys_env_destroy>
}
  8000ee:	c9                   	leave  
  8000ef:	c3                   	ret    

008000f0 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  8000f0:	55                   	push   %ebp
  8000f1:	89 e5                	mov    %esp,%ebp
  8000f3:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8000f9:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800100:	00 00 00 
	b.cnt = 0;
  800103:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80010a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80010d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800110:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800114:	8b 45 08             	mov    0x8(%ebp),%eax
  800117:	89 44 24 08          	mov    %eax,0x8(%esp)
  80011b:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800121:	89 44 24 04          	mov    %eax,0x4(%esp)
  800125:	c7 04 24 6b 01 80 00 	movl   $0x80016b,(%esp)
  80012c:	e8 cb 01 00 00       	call   8002fc <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800131:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800137:	89 44 24 04          	mov    %eax,0x4(%esp)
  80013b:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800141:	89 04 24             	mov    %eax,(%esp)
  800144:	e8 63 0d 00 00       	call   800eac <sys_cputs>

	return b.cnt;
}
  800149:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80014f:	c9                   	leave  
  800150:	c3                   	ret    

00800151 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800151:	55                   	push   %ebp
  800152:	89 e5                	mov    %esp,%ebp
  800154:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  800157:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  80015a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80015e:	8b 45 08             	mov    0x8(%ebp),%eax
  800161:	89 04 24             	mov    %eax,(%esp)
  800164:	e8 87 ff ff ff       	call   8000f0 <vcprintf>
	va_end(ap);

	return cnt;
}
  800169:	c9                   	leave  
  80016a:	c3                   	ret    

0080016b <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80016b:	55                   	push   %ebp
  80016c:	89 e5                	mov    %esp,%ebp
  80016e:	53                   	push   %ebx
  80016f:	83 ec 14             	sub    $0x14,%esp
  800172:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800175:	8b 03                	mov    (%ebx),%eax
  800177:	8b 55 08             	mov    0x8(%ebp),%edx
  80017a:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80017e:	83 c0 01             	add    $0x1,%eax
  800181:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800183:	3d ff 00 00 00       	cmp    $0xff,%eax
  800188:	75 19                	jne    8001a3 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80018a:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800191:	00 
  800192:	8d 43 08             	lea    0x8(%ebx),%eax
  800195:	89 04 24             	mov    %eax,(%esp)
  800198:	e8 0f 0d 00 00       	call   800eac <sys_cputs>
		b->idx = 0;
  80019d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001a3:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001a7:	83 c4 14             	add    $0x14,%esp
  8001aa:	5b                   	pop    %ebx
  8001ab:	5d                   	pop    %ebp
  8001ac:	c3                   	ret    
  8001ad:	00 00                	add    %al,(%eax)
	...

008001b0 <printnum_v2>:
 */

static void 
printnum_v2(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001b0:	55                   	push   %ebp
  8001b1:	89 e5                	mov    %esp,%ebp
  8001b3:	57                   	push   %edi
  8001b4:	56                   	push   %esi
  8001b5:	53                   	push   %ebx
  8001b6:	83 ec 4c             	sub    $0x4c,%esp
  8001b9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8001bc:	89 d6                	mov    %edx,%esi
  8001be:	8b 45 08             	mov    0x8(%ebp),%eax
  8001c1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001c4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001c7:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8001ca:	8b 45 10             	mov    0x10(%ebp),%eax
  8001cd:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8001d0:	8b 7d 18             	mov    0x18(%ebp),%edi
    if (num >= base) {
  8001d3:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8001d6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001db:	39 d1                	cmp    %edx,%ecx
  8001dd:	72 07                	jb     8001e6 <printnum_v2+0x36>
  8001df:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8001e2:	39 d0                	cmp    %edx,%eax
  8001e4:	77 5f                	ja     800245 <printnum_v2+0x95>
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
  8001e6:	89 7c 24 10          	mov    %edi,0x10(%esp)
  8001ea:	83 eb 01             	sub    $0x1,%ebx
  8001ed:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8001f1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001f5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8001f9:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  8001fd:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800200:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  800203:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800206:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80020a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800211:	00 
  800212:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800215:	89 04 24             	mov    %eax,(%esp)
  800218:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80021b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80021f:	e8 dc 11 00 00       	call   801400 <__udivdi3>
  800224:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800227:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  80022a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80022e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800232:	89 04 24             	mov    %eax,(%esp)
  800235:	89 54 24 04          	mov    %edx,0x4(%esp)
  800239:	89 f2                	mov    %esi,%edx
  80023b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80023e:	e8 6d ff ff ff       	call   8001b0 <printnum_v2>
  800243:	eb 1e                	jmp    800263 <printnum_v2+0xb3>
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
  800245:	83 ff 2d             	cmp    $0x2d,%edi
  800248:	74 19                	je     800263 <printnum_v2+0xb3>
		while (--width > 0)
  80024a:	83 eb 01             	sub    $0x1,%ebx
  80024d:	85 db                	test   %ebx,%ebx
  80024f:	90                   	nop
  800250:	7e 11                	jle    800263 <printnum_v2+0xb3>
			putch(padc, putdat);
  800252:	89 74 24 04          	mov    %esi,0x4(%esp)
  800256:	89 3c 24             	mov    %edi,(%esp)
  800259:	ff 55 e4             	call   *-0x1c(%ebp)
    if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
		while (--width > 0)
  80025c:	83 eb 01             	sub    $0x1,%ebx
  80025f:	85 db                	test   %ebx,%ebx
  800261:	7f ef                	jg     800252 <printnum_v2+0xa2>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800263:	89 74 24 04          	mov    %esi,0x4(%esp)
  800267:	8b 74 24 04          	mov    0x4(%esp),%esi
  80026b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80026e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800272:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800279:	00 
  80027a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80027d:	89 14 24             	mov    %edx,(%esp)
  800280:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800283:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800287:	e8 a4 12 00 00       	call   801530 <__umoddi3>
  80028c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800290:	0f be 80 c9 16 80 00 	movsbl 0x8016c9(%eax),%eax
  800297:	89 04 24             	mov    %eax,(%esp)
  80029a:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80029d:	83 c4 4c             	add    $0x4c,%esp
  8002a0:	5b                   	pop    %ebx
  8002a1:	5e                   	pop    %esi
  8002a2:	5f                   	pop    %edi
  8002a3:	5d                   	pop    %ebp
  8002a4:	c3                   	ret    

008002a5 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002a5:	55                   	push   %ebp
  8002a6:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002a8:	83 fa 01             	cmp    $0x1,%edx
  8002ab:	7e 0e                	jle    8002bb <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002ad:	8b 10                	mov    (%eax),%edx
  8002af:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002b2:	89 08                	mov    %ecx,(%eax)
  8002b4:	8b 02                	mov    (%edx),%eax
  8002b6:	8b 52 04             	mov    0x4(%edx),%edx
  8002b9:	eb 22                	jmp    8002dd <getuint+0x38>
	else if (lflag)
  8002bb:	85 d2                	test   %edx,%edx
  8002bd:	74 10                	je     8002cf <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002bf:	8b 10                	mov    (%eax),%edx
  8002c1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002c4:	89 08                	mov    %ecx,(%eax)
  8002c6:	8b 02                	mov    (%edx),%eax
  8002c8:	ba 00 00 00 00       	mov    $0x0,%edx
  8002cd:	eb 0e                	jmp    8002dd <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002cf:	8b 10                	mov    (%eax),%edx
  8002d1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002d4:	89 08                	mov    %ecx,(%eax)
  8002d6:	8b 02                	mov    (%edx),%eax
  8002d8:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002dd:	5d                   	pop    %ebp
  8002de:	c3                   	ret    

008002df <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002df:	55                   	push   %ebp
  8002e0:	89 e5                	mov    %esp,%ebp
  8002e2:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002e5:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002e9:	8b 10                	mov    (%eax),%edx
  8002eb:	3b 50 04             	cmp    0x4(%eax),%edx
  8002ee:	73 0a                	jae    8002fa <sprintputch+0x1b>
		*b->buf++ = ch;
  8002f0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002f3:	88 0a                	mov    %cl,(%edx)
  8002f5:	83 c2 01             	add    $0x1,%edx
  8002f8:	89 10                	mov    %edx,(%eax)
}
  8002fa:	5d                   	pop    %ebp
  8002fb:	c3                   	ret    

008002fc <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002fc:	55                   	push   %ebp
  8002fd:	89 e5                	mov    %esp,%ebp
  8002ff:	57                   	push   %edi
  800300:	56                   	push   %esi
  800301:	53                   	push   %ebx
  800302:	83 ec 6c             	sub    $0x6c,%esp
  800305:	8b 7d 10             	mov    0x10(%ebp),%edi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800308:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  80030f:	eb 1a                	jmp    80032b <vprintfmt+0x2f>
	int base, lflag, width, precision, altflag,signflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800311:	85 c0                	test   %eax,%eax
  800313:	0f 84 66 06 00 00    	je     80097f <vprintfmt+0x683>
				return;
			putch(ch, putdat);
  800319:	8b 55 0c             	mov    0xc(%ebp),%edx
  80031c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800320:	89 04 24             	mov    %eax,(%esp)
  800323:	ff 55 08             	call   *0x8(%ebp)
  800326:	eb 03                	jmp    80032b <vprintfmt+0x2f>
  800328:	8b 7d e4             	mov    -0x1c(%ebp),%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag,signflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80032b:	0f b6 07             	movzbl (%edi),%eax
  80032e:	83 c7 01             	add    $0x1,%edi
  800331:	83 f8 25             	cmp    $0x25,%eax
  800334:	75 db                	jne    800311 <vprintfmt+0x15>
  800336:	c6 45 cc 20          	movb   $0x20,-0x34(%ebp)
  80033a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80033f:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  800346:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
  80034b:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800352:	be 00 00 00 00       	mov    $0x0,%esi
  800357:	eb 06                	jmp    80035f <vprintfmt+0x63>
  800359:	c6 45 cc 2d          	movb   $0x2d,-0x34(%ebp)
  80035d:	89 c7                	mov    %eax,%edi
		precision = -1;
		lflag = 0;
		altflag = 0;
                signflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80035f:	0f b6 17             	movzbl (%edi),%edx
  800362:	0f b6 c2             	movzbl %dl,%eax
  800365:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800368:	8d 47 01             	lea    0x1(%edi),%eax
  80036b:	83 ea 23             	sub    $0x23,%edx
  80036e:	80 fa 55             	cmp    $0x55,%dl
  800371:	0f 87 60 05 00 00    	ja     8008d7 <vprintfmt+0x5db>
  800377:	0f b6 d2             	movzbl %dl,%edx
  80037a:	ff 24 95 00 18 80 00 	jmp    *0x801800(,%edx,4)
  800381:	b9 01 00 00 00       	mov    $0x1,%ecx
  800386:	eb d5                	jmp    80035d <vprintfmt+0x61>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800388:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80038b:	83 eb 30             	sub    $0x30,%ebx
				ch = *fmt;
  80038e:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  800391:	8d 7a d0             	lea    -0x30(%edx),%edi
  800394:	83 ff 09             	cmp    $0x9,%edi
  800397:	76 08                	jbe    8003a1 <vprintfmt+0xa5>
  800399:	eb 40                	jmp    8003db <vprintfmt+0xdf>
  80039b:	c6 45 cc 30          	movb   $0x30,-0x34(%ebp)
                        signflag = 1;
                        goto reswitch;
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
			goto reswitch;
  80039f:	eb bc                	jmp    80035d <vprintfmt+0x61>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003a1:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  8003a4:	8d 1c 9b             	lea    (%ebx,%ebx,4),%ebx
  8003a7:	8d 5c 5a d0          	lea    -0x30(%edx,%ebx,2),%ebx
				ch = *fmt;
  8003ab:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  8003ae:	8d 7a d0             	lea    -0x30(%edx),%edi
  8003b1:	83 ff 09             	cmp    $0x9,%edi
  8003b4:	76 eb                	jbe    8003a1 <vprintfmt+0xa5>
  8003b6:	eb 23                	jmp    8003db <vprintfmt+0xdf>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003b8:	8b 55 14             	mov    0x14(%ebp),%edx
  8003bb:	8d 5a 04             	lea    0x4(%edx),%ebx
  8003be:	89 5d 14             	mov    %ebx,0x14(%ebp)
  8003c1:	8b 1a                	mov    (%edx),%ebx
			goto process_precision;
  8003c3:	eb 16                	jmp    8003db <vprintfmt+0xdf>

		case '.':
			if (width < 0)
  8003c5:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8003c8:	c1 fa 1f             	sar    $0x1f,%edx
  8003cb:	f7 d2                	not    %edx
  8003cd:	21 55 d8             	and    %edx,-0x28(%ebp)
  8003d0:	eb 8b                	jmp    80035d <vprintfmt+0x61>
  8003d2:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  8003d9:	eb 82                	jmp    80035d <vprintfmt+0x61>

		process_precision:
			if (width < 0)
  8003db:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8003df:	0f 89 78 ff ff ff    	jns    80035d <vprintfmt+0x61>
  8003e5:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8003e8:	8b 5d c8             	mov    -0x38(%ebp),%ebx
  8003eb:	e9 6d ff ff ff       	jmp    80035d <vprintfmt+0x61>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003f0:	83 c6 01             	add    $0x1,%esi
			goto reswitch;
  8003f3:	e9 65 ff ff ff       	jmp    80035d <vprintfmt+0x61>
  8003f8:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8003fe:	8d 50 04             	lea    0x4(%eax),%edx
  800401:	89 55 14             	mov    %edx,0x14(%ebp)
  800404:	8b 55 0c             	mov    0xc(%ebp),%edx
  800407:	89 54 24 04          	mov    %edx,0x4(%esp)
  80040b:	8b 00                	mov    (%eax),%eax
  80040d:	89 04 24             	mov    %eax,(%esp)
  800410:	ff 55 08             	call   *0x8(%ebp)
  800413:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;
  800416:	e9 10 ff ff ff       	jmp    80032b <vprintfmt+0x2f>
  80041b:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  80041e:	8b 45 14             	mov    0x14(%ebp),%eax
  800421:	8d 50 04             	lea    0x4(%eax),%edx
  800424:	89 55 14             	mov    %edx,0x14(%ebp)
  800427:	8b 00                	mov    (%eax),%eax
  800429:	89 c2                	mov    %eax,%edx
  80042b:	c1 fa 1f             	sar    $0x1f,%edx
  80042e:	31 d0                	xor    %edx,%eax
  800430:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800432:	83 f8 08             	cmp    $0x8,%eax
  800435:	7f 0b                	jg     800442 <vprintfmt+0x146>
  800437:	8b 14 85 60 19 80 00 	mov    0x801960(,%eax,4),%edx
  80043e:	85 d2                	test   %edx,%edx
  800440:	75 26                	jne    800468 <vprintfmt+0x16c>
				printfmt(putch, putdat, "error %d", err);
  800442:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800446:	c7 44 24 08 da 16 80 	movl   $0x8016da,0x8(%esp)
  80044d:	00 
  80044e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800451:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800455:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800458:	89 1c 24             	mov    %ebx,(%esp)
  80045b:	e8 a7 05 00 00       	call   800a07 <printfmt>
  800460:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800463:	e9 c3 fe ff ff       	jmp    80032b <vprintfmt+0x2f>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800468:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80046c:	c7 44 24 08 e3 16 80 	movl   $0x8016e3,0x8(%esp)
  800473:	00 
  800474:	8b 45 0c             	mov    0xc(%ebp),%eax
  800477:	89 44 24 04          	mov    %eax,0x4(%esp)
  80047b:	8b 55 08             	mov    0x8(%ebp),%edx
  80047e:	89 14 24             	mov    %edx,(%esp)
  800481:	e8 81 05 00 00       	call   800a07 <printfmt>
  800486:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800489:	e9 9d fe ff ff       	jmp    80032b <vprintfmt+0x2f>
  80048e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800491:	89 c7                	mov    %eax,%edi
  800493:	89 d9                	mov    %ebx,%ecx
  800495:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800498:	89 45 c0             	mov    %eax,-0x40(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80049b:	8b 45 14             	mov    0x14(%ebp),%eax
  80049e:	8d 50 04             	lea    0x4(%eax),%edx
  8004a1:	89 55 14             	mov    %edx,0x14(%ebp)
  8004a4:	8b 30                	mov    (%eax),%esi
  8004a6:	85 f6                	test   %esi,%esi
  8004a8:	75 05                	jne    8004af <vprintfmt+0x1b3>
  8004aa:	be e6 16 80 00       	mov    $0x8016e6,%esi
				p = "(null)";
			if (width > 0 && padc != '-')
  8004af:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
  8004b3:	7e 06                	jle    8004bb <vprintfmt+0x1bf>
  8004b5:	80 7d cc 2d          	cmpb   $0x2d,-0x34(%ebp)
  8004b9:	75 10                	jne    8004cb <vprintfmt+0x1cf>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004bb:	0f be 06             	movsbl (%esi),%eax
  8004be:	85 c0                	test   %eax,%eax
  8004c0:	0f 85 a2 00 00 00    	jne    800568 <vprintfmt+0x26c>
  8004c6:	e9 92 00 00 00       	jmp    80055d <vprintfmt+0x261>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004cb:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8004cf:	89 34 24             	mov    %esi,(%esp)
  8004d2:	e8 74 05 00 00       	call   800a4b <strnlen>
  8004d7:	8b 55 c0             	mov    -0x40(%ebp),%edx
  8004da:	29 c2                	sub    %eax,%edx
  8004dc:	89 55 d8             	mov    %edx,-0x28(%ebp)
  8004df:	85 d2                	test   %edx,%edx
  8004e1:	7e d8                	jle    8004bb <vprintfmt+0x1bf>
					putch(padc, putdat);
  8004e3:	0f be 4d cc          	movsbl -0x34(%ebp),%ecx
  8004e7:	89 5d c0             	mov    %ebx,-0x40(%ebp)
  8004ea:	89 d3                	mov    %edx,%ebx
  8004ec:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8004ef:	89 7d bc             	mov    %edi,-0x44(%ebp)
  8004f2:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8004f5:	89 ce                	mov    %ecx,%esi
  8004f7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004fb:	89 34 24             	mov    %esi,(%esp)
  8004fe:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800501:	83 eb 01             	sub    $0x1,%ebx
  800504:	85 db                	test   %ebx,%ebx
  800506:	7f ef                	jg     8004f7 <vprintfmt+0x1fb>
  800508:	8b 5d c0             	mov    -0x40(%ebp),%ebx
  80050b:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80050e:	8b 7d bc             	mov    -0x44(%ebp),%edi
  800511:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800518:	eb a1                	jmp    8004bb <vprintfmt+0x1bf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80051a:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  80051e:	74 1b                	je     80053b <vprintfmt+0x23f>
  800520:	8d 50 e0             	lea    -0x20(%eax),%edx
  800523:	83 fa 5e             	cmp    $0x5e,%edx
  800526:	76 13                	jbe    80053b <vprintfmt+0x23f>
					putch('?', putdat);
  800528:	8b 45 0c             	mov    0xc(%ebp),%eax
  80052b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80052f:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800536:	ff 55 08             	call   *0x8(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800539:	eb 0d                	jmp    800548 <vprintfmt+0x24c>
					putch('?', putdat);
				else
					putch(ch, putdat);
  80053b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80053e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800542:	89 04 24             	mov    %eax,(%esp)
  800545:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800548:	83 ef 01             	sub    $0x1,%edi
  80054b:	0f be 06             	movsbl (%esi),%eax
  80054e:	85 c0                	test   %eax,%eax
  800550:	74 05                	je     800557 <vprintfmt+0x25b>
  800552:	83 c6 01             	add    $0x1,%esi
  800555:	eb 1a                	jmp    800571 <vprintfmt+0x275>
  800557:	89 7d d8             	mov    %edi,-0x28(%ebp)
  80055a:	8b 7d cc             	mov    -0x34(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80055d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800561:	7f 1f                	jg     800582 <vprintfmt+0x286>
  800563:	e9 c0 fd ff ff       	jmp    800328 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800568:	83 c6 01             	add    $0x1,%esi
  80056b:	89 7d cc             	mov    %edi,-0x34(%ebp)
  80056e:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800571:	85 db                	test   %ebx,%ebx
  800573:	78 a5                	js     80051a <vprintfmt+0x21e>
  800575:	83 eb 01             	sub    $0x1,%ebx
  800578:	79 a0                	jns    80051a <vprintfmt+0x21e>
  80057a:	89 7d d8             	mov    %edi,-0x28(%ebp)
  80057d:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800580:	eb db                	jmp    80055d <vprintfmt+0x261>
  800582:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800585:	8b 75 0c             	mov    0xc(%ebp),%esi
  800588:	89 7d d8             	mov    %edi,-0x28(%ebp)
  80058b:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80058e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800592:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800599:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80059b:	83 eb 01             	sub    $0x1,%ebx
  80059e:	85 db                	test   %ebx,%ebx
  8005a0:	7f ec                	jg     80058e <vprintfmt+0x292>
  8005a2:	8b 7d d8             	mov    -0x28(%ebp),%edi
  8005a5:	e9 81 fd ff ff       	jmp    80032b <vprintfmt+0x2f>
  8005aa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005ad:	83 fe 01             	cmp    $0x1,%esi
  8005b0:	7e 10                	jle    8005c2 <vprintfmt+0x2c6>
		return va_arg(*ap, long long);
  8005b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b5:	8d 50 08             	lea    0x8(%eax),%edx
  8005b8:	89 55 14             	mov    %edx,0x14(%ebp)
  8005bb:	8b 18                	mov    (%eax),%ebx
  8005bd:	8b 70 04             	mov    0x4(%eax),%esi
  8005c0:	eb 26                	jmp    8005e8 <vprintfmt+0x2ec>
	else if (lflag)
  8005c2:	85 f6                	test   %esi,%esi
  8005c4:	74 12                	je     8005d8 <vprintfmt+0x2dc>
		return va_arg(*ap, long);
  8005c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c9:	8d 50 04             	lea    0x4(%eax),%edx
  8005cc:	89 55 14             	mov    %edx,0x14(%ebp)
  8005cf:	8b 18                	mov    (%eax),%ebx
  8005d1:	89 de                	mov    %ebx,%esi
  8005d3:	c1 fe 1f             	sar    $0x1f,%esi
  8005d6:	eb 10                	jmp    8005e8 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  8005d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005db:	8d 50 04             	lea    0x4(%eax),%edx
  8005de:	89 55 14             	mov    %edx,0x14(%ebp)
  8005e1:	8b 18                	mov    (%eax),%ebx
  8005e3:	89 de                	mov    %ebx,%esi
  8005e5:	c1 fe 1f             	sar    $0x1f,%esi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
                        if(signflag == 1){
  8005e8:	83 f9 01             	cmp    $0x1,%ecx
  8005eb:	75 1e                	jne    80060b <vprintfmt+0x30f>
                               if((long long)num > 0){
  8005ed:	85 f6                	test   %esi,%esi
  8005ef:	78 1a                	js     80060b <vprintfmt+0x30f>
  8005f1:	85 f6                	test   %esi,%esi
  8005f3:	7f 05                	jg     8005fa <vprintfmt+0x2fe>
  8005f5:	83 fb 00             	cmp    $0x0,%ebx
  8005f8:	76 11                	jbe    80060b <vprintfmt+0x30f>
                                   putch('+',putdat);
  8005fa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8005fd:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800601:	c7 04 24 2b 00 00 00 	movl   $0x2b,(%esp)
  800608:	ff 55 08             	call   *0x8(%ebp)
                               }
                        }
			if ((long long) num < 0) {
  80060b:	85 f6                	test   %esi,%esi
  80060d:	78 13                	js     800622 <vprintfmt+0x326>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80060f:	89 5d b0             	mov    %ebx,-0x50(%ebp)
  800612:	89 75 b4             	mov    %esi,-0x4c(%ebp)
  800615:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800618:	b8 0a 00 00 00       	mov    $0xa,%eax
  80061d:	e9 da 00 00 00       	jmp    8006fc <vprintfmt+0x400>
                               if((long long)num > 0){
                                   putch('+',putdat);
                               }
                        }
			if ((long long) num < 0) {
				putch('-', putdat);
  800622:	8b 45 0c             	mov    0xc(%ebp),%eax
  800625:	89 44 24 04          	mov    %eax,0x4(%esp)
  800629:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800630:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800633:	89 da                	mov    %ebx,%edx
  800635:	89 f1                	mov    %esi,%ecx
  800637:	f7 da                	neg    %edx
  800639:	83 d1 00             	adc    $0x0,%ecx
  80063c:	f7 d9                	neg    %ecx
  80063e:	89 55 b0             	mov    %edx,-0x50(%ebp)
  800641:	89 4d b4             	mov    %ecx,-0x4c(%ebp)
  800644:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800647:	b8 0a 00 00 00       	mov    $0xa,%eax
  80064c:	e9 ab 00 00 00       	jmp    8006fc <vprintfmt+0x400>
  800651:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800654:	89 f2                	mov    %esi,%edx
  800656:	8d 45 14             	lea    0x14(%ebp),%eax
  800659:	e8 47 fc ff ff       	call   8002a5 <getuint>
  80065e:	89 45 b0             	mov    %eax,-0x50(%ebp)
  800661:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  800664:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800667:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
  80066c:	e9 8b 00 00 00       	jmp    8006fc <vprintfmt+0x400>
  800671:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			putch('0', putdat);
  800674:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800677:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80067b:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800682:	ff 55 08             	call   *0x8(%ebp)
			num = getuint(&ap,lflag);
  800685:	89 f2                	mov    %esi,%edx
  800687:	8d 45 14             	lea    0x14(%ebp),%eax
  80068a:	e8 16 fc ff ff       	call   8002a5 <getuint>
  80068f:	89 45 b0             	mov    %eax,-0x50(%ebp)
  800692:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  800695:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800698:	b8 08 00 00 00       	mov    $0x8,%eax
                        base = 8;
			goto number;
  80069d:	eb 5d                	jmp    8006fc <vprintfmt+0x400>
  80069f:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
  8006a2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006a5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006a9:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8006b0:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8006b3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006b7:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8006be:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  8006c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c4:	8d 50 04             	lea    0x4(%eax),%edx
  8006c7:	89 55 14             	mov    %edx,0x14(%ebp)
  8006ca:	8b 10                	mov    (%eax),%edx
  8006cc:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006d1:	89 55 b0             	mov    %edx,-0x50(%ebp)
  8006d4:	89 4d b4             	mov    %ecx,-0x4c(%ebp)
  8006d7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006da:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006df:	eb 1b                	jmp    8006fc <vprintfmt+0x400>
  8006e1:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006e4:	89 f2                	mov    %esi,%edx
  8006e6:	8d 45 14             	lea    0x14(%ebp),%eax
  8006e9:	e8 b7 fb ff ff       	call   8002a5 <getuint>
  8006ee:	89 45 b0             	mov    %eax,-0x50(%ebp)
  8006f1:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  8006f4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006f7:	b8 10 00 00 00       	mov    $0x10,%eax
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006fc:	0f be 4d cc          	movsbl -0x34(%ebp),%ecx
  800700:	89 4d d0             	mov    %ecx,-0x30(%ebp)
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800703:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800706:	83 7d b4 00          	cmpl   $0x0,-0x4c(%ebp)
  80070a:	77 09                	ja     800715 <vprintfmt+0x419>
  80070c:	39 45 b0             	cmp    %eax,-0x50(%ebp)
  80070f:	0f 82 ac 00 00 00    	jb     8007c1 <vprintfmt+0x4c5>
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
  800715:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800718:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  80071c:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80071f:	83 ea 01             	sub    $0x1,%edx
  800722:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800726:	89 44 24 08          	mov    %eax,0x8(%esp)
  80072a:	8b 44 24 08          	mov    0x8(%esp),%eax
  80072e:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800732:	89 45 c0             	mov    %eax,-0x40(%ebp)
  800735:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  800738:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80073b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80073f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800746:	00 
  800747:	8b 4d b0             	mov    -0x50(%ebp),%ecx
  80074a:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
  80074d:	89 0c 24             	mov    %ecx,(%esp)
  800750:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800754:	e8 a7 0c 00 00       	call   801400 <__udivdi3>
  800759:	8b 4d c0             	mov    -0x40(%ebp),%ecx
  80075c:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  80075f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800763:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800767:	89 04 24             	mov    %eax,(%esp)
  80076a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80076e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800771:	8b 45 08             	mov    0x8(%ebp),%eax
  800774:	e8 37 fa ff ff       	call   8001b0 <printnum_v2>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800779:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80077c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800780:	8b 74 24 04          	mov    0x4(%esp),%esi
  800784:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800787:	89 44 24 08          	mov    %eax,0x8(%esp)
  80078b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800792:	00 
  800793:	8b 55 b0             	mov    -0x50(%ebp),%edx
  800796:	8b 4d b4             	mov    -0x4c(%ebp),%ecx
  800799:	89 14 24             	mov    %edx,(%esp)
  80079c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8007a0:	e8 8b 0d 00 00       	call   801530 <__umoddi3>
  8007a5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007a9:	0f be 80 c9 16 80 00 	movsbl 0x8016c9(%eax),%eax
  8007b0:	89 04 24             	mov    %eax,(%esp)
  8007b3:	ff 55 08             	call   *0x8(%ebp)
        if(padc == '-'){
  8007b6:	83 7d d0 2d          	cmpl   $0x2d,-0x30(%ebp)
  8007ba:	74 54                	je     800810 <vprintfmt+0x514>
  8007bc:	e9 67 fb ff ff       	jmp    800328 <vprintfmt+0x2c>
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
  8007c1:	83 7d d0 2d          	cmpl   $0x2d,-0x30(%ebp)
  8007c5:	8d 76 00             	lea    0x0(%esi),%esi
  8007c8:	0f 84 2a 01 00 00    	je     8008f8 <vprintfmt+0x5fc>
		while (--width > 0)
  8007ce:	8b 7d d8             	mov    -0x28(%ebp),%edi
  8007d1:	83 ef 01             	sub    $0x1,%edi
  8007d4:	85 ff                	test   %edi,%edi
  8007d6:	0f 8e 5e 01 00 00    	jle    80093a <vprintfmt+0x63e>
  8007dc:	8b 4d b0             	mov    -0x50(%ebp),%ecx
  8007df:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
  8007e2:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  8007e5:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  8007e8:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8007eb:	8b 75 0c             	mov    0xc(%ebp),%esi
			putch(padc, putdat);
  8007ee:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007f2:	89 1c 24             	mov    %ebx,(%esp)
  8007f5:	ff 55 08             	call   *0x8(%ebp)
	if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
		while (--width > 0)
  8007f8:	83 ef 01             	sub    $0x1,%edi
  8007fb:	85 ff                	test   %edi,%edi
  8007fd:	7f ef                	jg     8007ee <vprintfmt+0x4f2>
  8007ff:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800802:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800805:	89 45 b0             	mov    %eax,-0x50(%ebp)
  800808:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  80080b:	e9 2a 01 00 00       	jmp    80093a <vprintfmt+0x63e>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
        if(padc == '-'){
           while (--width > 0)
  800810:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800813:	83 eb 01             	sub    $0x1,%ebx
  800816:	85 db                	test   %ebx,%ebx
  800818:	0f 8e 0a fb ff ff    	jle    800328 <vprintfmt+0x2c>
  80081e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800821:	89 7d d8             	mov    %edi,-0x28(%ebp)
  800824:	8b 7d 08             	mov    0x8(%ebp),%edi
			putch(' ', putdat);
  800827:	89 74 24 04          	mov    %esi,0x4(%esp)
  80082b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800832:	ff d7                	call   *%edi
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
        if(padc == '-'){
           while (--width > 0)
  800834:	83 eb 01             	sub    $0x1,%ebx
  800837:	85 db                	test   %ebx,%ebx
  800839:	7f ec                	jg     800827 <vprintfmt+0x52b>
  80083b:	8b 7d d8             	mov    -0x28(%ebp),%edi
  80083e:	e9 e8 fa ff ff       	jmp    80032b <vprintfmt+0x2f>
  800843:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
            char* n;
            if ((n = va_arg(ap, char *)) == NULL)
  800846:	8b 45 14             	mov    0x14(%ebp),%eax
  800849:	8d 50 04             	lea    0x4(%eax),%edx
  80084c:	89 55 14             	mov    %edx,0x14(%ebp)
  80084f:	8b 00                	mov    (%eax),%eax
  800851:	85 c0                	test   %eax,%eax
  800853:	75 2a                	jne    80087f <vprintfmt+0x583>
		  printfmt(putch,putdat,"%s",null_error);
  800855:	c7 44 24 0c 80 17 80 	movl   $0x801780,0xc(%esp)
  80085c:	00 
  80085d:	c7 44 24 08 e3 16 80 	movl   $0x8016e3,0x8(%esp)
  800864:	00 
  800865:	8b 55 0c             	mov    0xc(%ebp),%edx
  800868:	89 54 24 04          	mov    %edx,0x4(%esp)
  80086c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80086f:	89 0c 24             	mov    %ecx,(%esp)
  800872:	e8 90 01 00 00       	call   800a07 <printfmt>
  800877:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80087a:	e9 ac fa ff ff       	jmp    80032b <vprintfmt+0x2f>
            else if((*(int*)putdat) > 127){
  80087f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800882:	8b 13                	mov    (%ebx),%edx
  800884:	83 fa 7f             	cmp    $0x7f,%edx
  800887:	7e 29                	jle    8008b2 <vprintfmt+0x5b6>
                  *n = *(int*)putdat;
  800889:	88 10                	mov    %dl,(%eax)
                  printfmt(putch,putdat,"%s",overflow_error);
  80088b:	c7 44 24 0c b8 17 80 	movl   $0x8017b8,0xc(%esp)
  800892:	00 
  800893:	c7 44 24 08 e3 16 80 	movl   $0x8016e3,0x8(%esp)
  80089a:	00 
  80089b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80089f:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a2:	89 04 24             	mov    %eax,(%esp)
  8008a5:	e8 5d 01 00 00       	call   800a07 <printfmt>
  8008aa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8008ad:	e9 79 fa ff ff       	jmp    80032b <vprintfmt+0x2f>
            }
            else
                  *n = *(int*)putdat;
  8008b2:	88 10                	mov    %dl,(%eax)
  8008b4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8008b7:	e9 6f fa ff ff       	jmp    80032b <vprintfmt+0x2f>
  8008bc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8008bf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            break;
        }
		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8008c2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008c5:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8008c9:	89 14 24             	mov    %edx,(%esp)
  8008cc:	ff 55 08             	call   *0x8(%ebp)
  8008cf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;
  8008d2:	e9 54 fa ff ff       	jmp    80032b <vprintfmt+0x2f>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8008d7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8008da:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008de:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8008e5:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008e8:	8d 47 ff             	lea    -0x1(%edi),%eax
  8008eb:	80 38 25             	cmpb   $0x25,(%eax)
  8008ee:	0f 84 37 fa ff ff    	je     80032b <vprintfmt+0x2f>
  8008f4:	89 c7                	mov    %eax,%edi
  8008f6:	eb f0                	jmp    8008e8 <vprintfmt+0x5ec>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8008f8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008fb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008ff:	8b 74 24 04          	mov    0x4(%esp),%esi
  800903:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800906:	89 54 24 08          	mov    %edx,0x8(%esp)
  80090a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800911:	00 
  800912:	8b 45 b0             	mov    -0x50(%ebp),%eax
  800915:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  800918:	89 04 24             	mov    %eax,(%esp)
  80091b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80091f:	e8 0c 0c 00 00       	call   801530 <__umoddi3>
  800924:	89 74 24 04          	mov    %esi,0x4(%esp)
  800928:	0f be 80 c9 16 80 00 	movsbl 0x8016c9(%eax),%eax
  80092f:	89 04 24             	mov    %eax,(%esp)
  800932:	ff 55 08             	call   *0x8(%ebp)
  800935:	e9 d6 fe ff ff       	jmp    800810 <vprintfmt+0x514>
  80093a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80093d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800941:	8b 74 24 04          	mov    0x4(%esp),%esi
  800945:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800948:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80094c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800953:	00 
  800954:	8b 45 b0             	mov    -0x50(%ebp),%eax
  800957:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  80095a:	89 04 24             	mov    %eax,(%esp)
  80095d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800961:	e8 ca 0b 00 00       	call   801530 <__umoddi3>
  800966:	89 74 24 04          	mov    %esi,0x4(%esp)
  80096a:	0f be 80 c9 16 80 00 	movsbl 0x8016c9(%eax),%eax
  800971:	89 04 24             	mov    %eax,(%esp)
  800974:	ff 55 08             	call   *0x8(%ebp)
  800977:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80097a:	e9 ac f9 ff ff       	jmp    80032b <vprintfmt+0x2f>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  80097f:	83 c4 6c             	add    $0x6c,%esp
  800982:	5b                   	pop    %ebx
  800983:	5e                   	pop    %esi
  800984:	5f                   	pop    %edi
  800985:	5d                   	pop    %ebp
  800986:	c3                   	ret    

00800987 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800987:	55                   	push   %ebp
  800988:	89 e5                	mov    %esp,%ebp
  80098a:	83 ec 28             	sub    $0x28,%esp
  80098d:	8b 45 08             	mov    0x8(%ebp),%eax
  800990:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  800993:	85 c0                	test   %eax,%eax
  800995:	74 04                	je     80099b <vsnprintf+0x14>
  800997:	85 d2                	test   %edx,%edx
  800999:	7f 07                	jg     8009a2 <vsnprintf+0x1b>
  80099b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8009a0:	eb 3b                	jmp    8009dd <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  8009a2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8009a5:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  8009a9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8009ac:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8009b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8009b6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009ba:	8b 45 10             	mov    0x10(%ebp),%eax
  8009bd:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009c1:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8009c4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009c8:	c7 04 24 df 02 80 00 	movl   $0x8002df,(%esp)
  8009cf:	e8 28 f9 ff ff       	call   8002fc <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8009d4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8009d7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8009da:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8009dd:	c9                   	leave  
  8009de:	c3                   	ret    

008009df <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8009df:	55                   	push   %ebp
  8009e0:	89 e5                	mov    %esp,%ebp
  8009e2:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  8009e5:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  8009e8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009ec:	8b 45 10             	mov    0x10(%ebp),%eax
  8009ef:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009f3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009f6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8009fd:	89 04 24             	mov    %eax,(%esp)
  800a00:	e8 82 ff ff ff       	call   800987 <vsnprintf>
	va_end(ap);

	return rc;
}
  800a05:	c9                   	leave  
  800a06:	c3                   	ret    

00800a07 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800a07:	55                   	push   %ebp
  800a08:	89 e5                	mov    %esp,%ebp
  800a0a:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  800a0d:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  800a10:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a14:	8b 45 10             	mov    0x10(%ebp),%eax
  800a17:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a1b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a1e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a22:	8b 45 08             	mov    0x8(%ebp),%eax
  800a25:	89 04 24             	mov    %eax,(%esp)
  800a28:	e8 cf f8 ff ff       	call   8002fc <vprintfmt>
	va_end(ap);
}
  800a2d:	c9                   	leave  
  800a2e:	c3                   	ret    
	...

00800a30 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a30:	55                   	push   %ebp
  800a31:	89 e5                	mov    %esp,%ebp
  800a33:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a36:	b8 00 00 00 00       	mov    $0x0,%eax
  800a3b:	80 3a 00             	cmpb   $0x0,(%edx)
  800a3e:	74 09                	je     800a49 <strlen+0x19>
		n++;
  800a40:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800a43:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a47:	75 f7                	jne    800a40 <strlen+0x10>
		n++;
	return n;
}
  800a49:	5d                   	pop    %ebp
  800a4a:	c3                   	ret    

00800a4b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a4b:	55                   	push   %ebp
  800a4c:	89 e5                	mov    %esp,%ebp
  800a4e:	53                   	push   %ebx
  800a4f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800a52:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a55:	85 c9                	test   %ecx,%ecx
  800a57:	74 19                	je     800a72 <strnlen+0x27>
  800a59:	80 3b 00             	cmpb   $0x0,(%ebx)
  800a5c:	74 14                	je     800a72 <strnlen+0x27>
  800a5e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800a63:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a66:	39 c8                	cmp    %ecx,%eax
  800a68:	74 0d                	je     800a77 <strnlen+0x2c>
  800a6a:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  800a6e:	75 f3                	jne    800a63 <strnlen+0x18>
  800a70:	eb 05                	jmp    800a77 <strnlen+0x2c>
  800a72:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800a77:	5b                   	pop    %ebx
  800a78:	5d                   	pop    %ebp
  800a79:	c3                   	ret    

00800a7a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a7a:	55                   	push   %ebp
  800a7b:	89 e5                	mov    %esp,%ebp
  800a7d:	53                   	push   %ebx
  800a7e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a81:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a84:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a89:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800a8d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800a90:	83 c2 01             	add    $0x1,%edx
  800a93:	84 c9                	test   %cl,%cl
  800a95:	75 f2                	jne    800a89 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800a97:	5b                   	pop    %ebx
  800a98:	5d                   	pop    %ebp
  800a99:	c3                   	ret    

00800a9a <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a9a:	55                   	push   %ebp
  800a9b:	89 e5                	mov    %esp,%ebp
  800a9d:	53                   	push   %ebx
  800a9e:	83 ec 08             	sub    $0x8,%esp
  800aa1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800aa4:	89 1c 24             	mov    %ebx,(%esp)
  800aa7:	e8 84 ff ff ff       	call   800a30 <strlen>
	strcpy(dst + len, src);
  800aac:	8b 55 0c             	mov    0xc(%ebp),%edx
  800aaf:	89 54 24 04          	mov    %edx,0x4(%esp)
  800ab3:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800ab6:	89 04 24             	mov    %eax,(%esp)
  800ab9:	e8 bc ff ff ff       	call   800a7a <strcpy>
	return dst;
}
  800abe:	89 d8                	mov    %ebx,%eax
  800ac0:	83 c4 08             	add    $0x8,%esp
  800ac3:	5b                   	pop    %ebx
  800ac4:	5d                   	pop    %ebp
  800ac5:	c3                   	ret    

00800ac6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800ac6:	55                   	push   %ebp
  800ac7:	89 e5                	mov    %esp,%ebp
  800ac9:	56                   	push   %esi
  800aca:	53                   	push   %ebx
  800acb:	8b 45 08             	mov    0x8(%ebp),%eax
  800ace:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ad1:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ad4:	85 f6                	test   %esi,%esi
  800ad6:	74 18                	je     800af0 <strncpy+0x2a>
  800ad8:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800add:	0f b6 1a             	movzbl (%edx),%ebx
  800ae0:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800ae3:	80 3a 01             	cmpb   $0x1,(%edx)
  800ae6:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ae9:	83 c1 01             	add    $0x1,%ecx
  800aec:	39 ce                	cmp    %ecx,%esi
  800aee:	77 ed                	ja     800add <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800af0:	5b                   	pop    %ebx
  800af1:	5e                   	pop    %esi
  800af2:	5d                   	pop    %ebp
  800af3:	c3                   	ret    

00800af4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800af4:	55                   	push   %ebp
  800af5:	89 e5                	mov    %esp,%ebp
  800af7:	56                   	push   %esi
  800af8:	53                   	push   %ebx
  800af9:	8b 75 08             	mov    0x8(%ebp),%esi
  800afc:	8b 55 0c             	mov    0xc(%ebp),%edx
  800aff:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b02:	89 f0                	mov    %esi,%eax
  800b04:	85 c9                	test   %ecx,%ecx
  800b06:	74 27                	je     800b2f <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  800b08:	83 e9 01             	sub    $0x1,%ecx
  800b0b:	74 1d                	je     800b2a <strlcpy+0x36>
  800b0d:	0f b6 1a             	movzbl (%edx),%ebx
  800b10:	84 db                	test   %bl,%bl
  800b12:	74 16                	je     800b2a <strlcpy+0x36>
			*dst++ = *src++;
  800b14:	88 18                	mov    %bl,(%eax)
  800b16:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800b19:	83 e9 01             	sub    $0x1,%ecx
  800b1c:	74 0e                	je     800b2c <strlcpy+0x38>
			*dst++ = *src++;
  800b1e:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800b21:	0f b6 1a             	movzbl (%edx),%ebx
  800b24:	84 db                	test   %bl,%bl
  800b26:	75 ec                	jne    800b14 <strlcpy+0x20>
  800b28:	eb 02                	jmp    800b2c <strlcpy+0x38>
  800b2a:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800b2c:	c6 00 00             	movb   $0x0,(%eax)
  800b2f:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800b31:	5b                   	pop    %ebx
  800b32:	5e                   	pop    %esi
  800b33:	5d                   	pop    %ebp
  800b34:	c3                   	ret    

00800b35 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b35:	55                   	push   %ebp
  800b36:	89 e5                	mov    %esp,%ebp
  800b38:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b3b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800b3e:	0f b6 01             	movzbl (%ecx),%eax
  800b41:	84 c0                	test   %al,%al
  800b43:	74 15                	je     800b5a <strcmp+0x25>
  800b45:	3a 02                	cmp    (%edx),%al
  800b47:	75 11                	jne    800b5a <strcmp+0x25>
		p++, q++;
  800b49:	83 c1 01             	add    $0x1,%ecx
  800b4c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800b4f:	0f b6 01             	movzbl (%ecx),%eax
  800b52:	84 c0                	test   %al,%al
  800b54:	74 04                	je     800b5a <strcmp+0x25>
  800b56:	3a 02                	cmp    (%edx),%al
  800b58:	74 ef                	je     800b49 <strcmp+0x14>
  800b5a:	0f b6 c0             	movzbl %al,%eax
  800b5d:	0f b6 12             	movzbl (%edx),%edx
  800b60:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800b62:	5d                   	pop    %ebp
  800b63:	c3                   	ret    

00800b64 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b64:	55                   	push   %ebp
  800b65:	89 e5                	mov    %esp,%ebp
  800b67:	53                   	push   %ebx
  800b68:	8b 55 08             	mov    0x8(%ebp),%edx
  800b6b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b6e:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800b71:	85 c0                	test   %eax,%eax
  800b73:	74 23                	je     800b98 <strncmp+0x34>
  800b75:	0f b6 1a             	movzbl (%edx),%ebx
  800b78:	84 db                	test   %bl,%bl
  800b7a:	74 25                	je     800ba1 <strncmp+0x3d>
  800b7c:	3a 19                	cmp    (%ecx),%bl
  800b7e:	75 21                	jne    800ba1 <strncmp+0x3d>
  800b80:	83 e8 01             	sub    $0x1,%eax
  800b83:	74 13                	je     800b98 <strncmp+0x34>
		n--, p++, q++;
  800b85:	83 c2 01             	add    $0x1,%edx
  800b88:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b8b:	0f b6 1a             	movzbl (%edx),%ebx
  800b8e:	84 db                	test   %bl,%bl
  800b90:	74 0f                	je     800ba1 <strncmp+0x3d>
  800b92:	3a 19                	cmp    (%ecx),%bl
  800b94:	74 ea                	je     800b80 <strncmp+0x1c>
  800b96:	eb 09                	jmp    800ba1 <strncmp+0x3d>
  800b98:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800b9d:	5b                   	pop    %ebx
  800b9e:	5d                   	pop    %ebp
  800b9f:	90                   	nop
  800ba0:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800ba1:	0f b6 02             	movzbl (%edx),%eax
  800ba4:	0f b6 11             	movzbl (%ecx),%edx
  800ba7:	29 d0                	sub    %edx,%eax
  800ba9:	eb f2                	jmp    800b9d <strncmp+0x39>

00800bab <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800bab:	55                   	push   %ebp
  800bac:	89 e5                	mov    %esp,%ebp
  800bae:	8b 45 08             	mov    0x8(%ebp),%eax
  800bb1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800bb5:	0f b6 10             	movzbl (%eax),%edx
  800bb8:	84 d2                	test   %dl,%dl
  800bba:	74 18                	je     800bd4 <strchr+0x29>
		if (*s == c)
  800bbc:	38 ca                	cmp    %cl,%dl
  800bbe:	75 0a                	jne    800bca <strchr+0x1f>
  800bc0:	eb 17                	jmp    800bd9 <strchr+0x2e>
  800bc2:	38 ca                	cmp    %cl,%dl
  800bc4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800bc8:	74 0f                	je     800bd9 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800bca:	83 c0 01             	add    $0x1,%eax
  800bcd:	0f b6 10             	movzbl (%eax),%edx
  800bd0:	84 d2                	test   %dl,%dl
  800bd2:	75 ee                	jne    800bc2 <strchr+0x17>
  800bd4:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800bd9:	5d                   	pop    %ebp
  800bda:	c3                   	ret    

00800bdb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800bdb:	55                   	push   %ebp
  800bdc:	89 e5                	mov    %esp,%ebp
  800bde:	8b 45 08             	mov    0x8(%ebp),%eax
  800be1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800be5:	0f b6 10             	movzbl (%eax),%edx
  800be8:	84 d2                	test   %dl,%dl
  800bea:	74 18                	je     800c04 <strfind+0x29>
		if (*s == c)
  800bec:	38 ca                	cmp    %cl,%dl
  800bee:	75 0a                	jne    800bfa <strfind+0x1f>
  800bf0:	eb 12                	jmp    800c04 <strfind+0x29>
  800bf2:	38 ca                	cmp    %cl,%dl
  800bf4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800bf8:	74 0a                	je     800c04 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800bfa:	83 c0 01             	add    $0x1,%eax
  800bfd:	0f b6 10             	movzbl (%eax),%edx
  800c00:	84 d2                	test   %dl,%dl
  800c02:	75 ee                	jne    800bf2 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800c04:	5d                   	pop    %ebp
  800c05:	c3                   	ret    

00800c06 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800c06:	55                   	push   %ebp
  800c07:	89 e5                	mov    %esp,%ebp
  800c09:	83 ec 0c             	sub    $0xc,%esp
  800c0c:	89 1c 24             	mov    %ebx,(%esp)
  800c0f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c13:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800c17:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c1a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c1d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800c20:	85 c9                	test   %ecx,%ecx
  800c22:	74 30                	je     800c54 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800c24:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c2a:	75 25                	jne    800c51 <memset+0x4b>
  800c2c:	f6 c1 03             	test   $0x3,%cl
  800c2f:	75 20                	jne    800c51 <memset+0x4b>
		c &= 0xFF;
  800c31:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800c34:	89 d3                	mov    %edx,%ebx
  800c36:	c1 e3 08             	shl    $0x8,%ebx
  800c39:	89 d6                	mov    %edx,%esi
  800c3b:	c1 e6 18             	shl    $0x18,%esi
  800c3e:	89 d0                	mov    %edx,%eax
  800c40:	c1 e0 10             	shl    $0x10,%eax
  800c43:	09 f0                	or     %esi,%eax
  800c45:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  800c47:	09 d8                	or     %ebx,%eax
  800c49:	c1 e9 02             	shr    $0x2,%ecx
  800c4c:	fc                   	cld    
  800c4d:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800c4f:	eb 03                	jmp    800c54 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c51:	fc                   	cld    
  800c52:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800c54:	89 f8                	mov    %edi,%eax
  800c56:	8b 1c 24             	mov    (%esp),%ebx
  800c59:	8b 74 24 04          	mov    0x4(%esp),%esi
  800c5d:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800c61:	89 ec                	mov    %ebp,%esp
  800c63:	5d                   	pop    %ebp
  800c64:	c3                   	ret    

00800c65 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c65:	55                   	push   %ebp
  800c66:	89 e5                	mov    %esp,%ebp
  800c68:	83 ec 08             	sub    $0x8,%esp
  800c6b:	89 34 24             	mov    %esi,(%esp)
  800c6e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800c72:	8b 45 08             	mov    0x8(%ebp),%eax
  800c75:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800c78:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800c7b:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800c7d:	39 c6                	cmp    %eax,%esi
  800c7f:	73 35                	jae    800cb6 <memmove+0x51>
  800c81:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c84:	39 d0                	cmp    %edx,%eax
  800c86:	73 2e                	jae    800cb6 <memmove+0x51>
		s += n;
		d += n;
  800c88:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c8a:	f6 c2 03             	test   $0x3,%dl
  800c8d:	75 1b                	jne    800caa <memmove+0x45>
  800c8f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c95:	75 13                	jne    800caa <memmove+0x45>
  800c97:	f6 c1 03             	test   $0x3,%cl
  800c9a:	75 0e                	jne    800caa <memmove+0x45>
			asm volatile("std; rep movsl\n"
  800c9c:	83 ef 04             	sub    $0x4,%edi
  800c9f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ca2:	c1 e9 02             	shr    $0x2,%ecx
  800ca5:	fd                   	std    
  800ca6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ca8:	eb 09                	jmp    800cb3 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800caa:	83 ef 01             	sub    $0x1,%edi
  800cad:	8d 72 ff             	lea    -0x1(%edx),%esi
  800cb0:	fd                   	std    
  800cb1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800cb3:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800cb4:	eb 20                	jmp    800cd6 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800cb6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800cbc:	75 15                	jne    800cd3 <memmove+0x6e>
  800cbe:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800cc4:	75 0d                	jne    800cd3 <memmove+0x6e>
  800cc6:	f6 c1 03             	test   $0x3,%cl
  800cc9:	75 08                	jne    800cd3 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  800ccb:	c1 e9 02             	shr    $0x2,%ecx
  800cce:	fc                   	cld    
  800ccf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800cd1:	eb 03                	jmp    800cd6 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800cd3:	fc                   	cld    
  800cd4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800cd6:	8b 34 24             	mov    (%esp),%esi
  800cd9:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800cdd:	89 ec                	mov    %ebp,%esp
  800cdf:	5d                   	pop    %ebp
  800ce0:	c3                   	ret    

00800ce1 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800ce1:	55                   	push   %ebp
  800ce2:	89 e5                	mov    %esp,%ebp
  800ce4:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800ce7:	8b 45 10             	mov    0x10(%ebp),%eax
  800cea:	89 44 24 08          	mov    %eax,0x8(%esp)
  800cee:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cf1:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cf5:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf8:	89 04 24             	mov    %eax,(%esp)
  800cfb:	e8 65 ff ff ff       	call   800c65 <memmove>
}
  800d00:	c9                   	leave  
  800d01:	c3                   	ret    

00800d02 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800d02:	55                   	push   %ebp
  800d03:	89 e5                	mov    %esp,%ebp
  800d05:	57                   	push   %edi
  800d06:	56                   	push   %esi
  800d07:	53                   	push   %ebx
  800d08:	8b 75 08             	mov    0x8(%ebp),%esi
  800d0b:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800d0e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d11:	85 c9                	test   %ecx,%ecx
  800d13:	74 36                	je     800d4b <memcmp+0x49>
		if (*s1 != *s2)
  800d15:	0f b6 06             	movzbl (%esi),%eax
  800d18:	0f b6 1f             	movzbl (%edi),%ebx
  800d1b:	38 d8                	cmp    %bl,%al
  800d1d:	74 20                	je     800d3f <memcmp+0x3d>
  800d1f:	eb 14                	jmp    800d35 <memcmp+0x33>
  800d21:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  800d26:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  800d2b:	83 c2 01             	add    $0x1,%edx
  800d2e:	83 e9 01             	sub    $0x1,%ecx
  800d31:	38 d8                	cmp    %bl,%al
  800d33:	74 12                	je     800d47 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  800d35:	0f b6 c0             	movzbl %al,%eax
  800d38:	0f b6 db             	movzbl %bl,%ebx
  800d3b:	29 d8                	sub    %ebx,%eax
  800d3d:	eb 11                	jmp    800d50 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d3f:	83 e9 01             	sub    $0x1,%ecx
  800d42:	ba 00 00 00 00       	mov    $0x0,%edx
  800d47:	85 c9                	test   %ecx,%ecx
  800d49:	75 d6                	jne    800d21 <memcmp+0x1f>
  800d4b:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800d50:	5b                   	pop    %ebx
  800d51:	5e                   	pop    %esi
  800d52:	5f                   	pop    %edi
  800d53:	5d                   	pop    %ebp
  800d54:	c3                   	ret    

00800d55 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800d55:	55                   	push   %ebp
  800d56:	89 e5                	mov    %esp,%ebp
  800d58:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800d5b:	89 c2                	mov    %eax,%edx
  800d5d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800d60:	39 d0                	cmp    %edx,%eax
  800d62:	73 15                	jae    800d79 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d64:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800d68:	38 08                	cmp    %cl,(%eax)
  800d6a:	75 06                	jne    800d72 <memfind+0x1d>
  800d6c:	eb 0b                	jmp    800d79 <memfind+0x24>
  800d6e:	38 08                	cmp    %cl,(%eax)
  800d70:	74 07                	je     800d79 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d72:	83 c0 01             	add    $0x1,%eax
  800d75:	39 c2                	cmp    %eax,%edx
  800d77:	77 f5                	ja     800d6e <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800d79:	5d                   	pop    %ebp
  800d7a:	c3                   	ret    

00800d7b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d7b:	55                   	push   %ebp
  800d7c:	89 e5                	mov    %esp,%ebp
  800d7e:	57                   	push   %edi
  800d7f:	56                   	push   %esi
  800d80:	53                   	push   %ebx
  800d81:	83 ec 04             	sub    $0x4,%esp
  800d84:	8b 55 08             	mov    0x8(%ebp),%edx
  800d87:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d8a:	0f b6 02             	movzbl (%edx),%eax
  800d8d:	3c 20                	cmp    $0x20,%al
  800d8f:	74 04                	je     800d95 <strtol+0x1a>
  800d91:	3c 09                	cmp    $0x9,%al
  800d93:	75 0e                	jne    800da3 <strtol+0x28>
		s++;
  800d95:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d98:	0f b6 02             	movzbl (%edx),%eax
  800d9b:	3c 20                	cmp    $0x20,%al
  800d9d:	74 f6                	je     800d95 <strtol+0x1a>
  800d9f:	3c 09                	cmp    $0x9,%al
  800da1:	74 f2                	je     800d95 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800da3:	3c 2b                	cmp    $0x2b,%al
  800da5:	75 0c                	jne    800db3 <strtol+0x38>
		s++;
  800da7:	83 c2 01             	add    $0x1,%edx
  800daa:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800db1:	eb 15                	jmp    800dc8 <strtol+0x4d>
	else if (*s == '-')
  800db3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800dba:	3c 2d                	cmp    $0x2d,%al
  800dbc:	75 0a                	jne    800dc8 <strtol+0x4d>
		s++, neg = 1;
  800dbe:	83 c2 01             	add    $0x1,%edx
  800dc1:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800dc8:	85 db                	test   %ebx,%ebx
  800dca:	0f 94 c0             	sete   %al
  800dcd:	74 05                	je     800dd4 <strtol+0x59>
  800dcf:	83 fb 10             	cmp    $0x10,%ebx
  800dd2:	75 18                	jne    800dec <strtol+0x71>
  800dd4:	80 3a 30             	cmpb   $0x30,(%edx)
  800dd7:	75 13                	jne    800dec <strtol+0x71>
  800dd9:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800ddd:	8d 76 00             	lea    0x0(%esi),%esi
  800de0:	75 0a                	jne    800dec <strtol+0x71>
		s += 2, base = 16;
  800de2:	83 c2 02             	add    $0x2,%edx
  800de5:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800dea:	eb 15                	jmp    800e01 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800dec:	84 c0                	test   %al,%al
  800dee:	66 90                	xchg   %ax,%ax
  800df0:	74 0f                	je     800e01 <strtol+0x86>
  800df2:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800df7:	80 3a 30             	cmpb   $0x30,(%edx)
  800dfa:	75 05                	jne    800e01 <strtol+0x86>
		s++, base = 8;
  800dfc:	83 c2 01             	add    $0x1,%edx
  800dff:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800e01:	b8 00 00 00 00       	mov    $0x0,%eax
  800e06:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800e08:	0f b6 0a             	movzbl (%edx),%ecx
  800e0b:	89 cf                	mov    %ecx,%edi
  800e0d:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800e10:	80 fb 09             	cmp    $0x9,%bl
  800e13:	77 08                	ja     800e1d <strtol+0xa2>
			dig = *s - '0';
  800e15:	0f be c9             	movsbl %cl,%ecx
  800e18:	83 e9 30             	sub    $0x30,%ecx
  800e1b:	eb 1e                	jmp    800e3b <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  800e1d:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  800e20:	80 fb 19             	cmp    $0x19,%bl
  800e23:	77 08                	ja     800e2d <strtol+0xb2>
			dig = *s - 'a' + 10;
  800e25:	0f be c9             	movsbl %cl,%ecx
  800e28:	83 e9 57             	sub    $0x57,%ecx
  800e2b:	eb 0e                	jmp    800e3b <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  800e2d:	8d 5f bf             	lea    -0x41(%edi),%ebx
  800e30:	80 fb 19             	cmp    $0x19,%bl
  800e33:	77 15                	ja     800e4a <strtol+0xcf>
			dig = *s - 'A' + 10;
  800e35:	0f be c9             	movsbl %cl,%ecx
  800e38:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800e3b:	39 f1                	cmp    %esi,%ecx
  800e3d:	7d 0b                	jge    800e4a <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  800e3f:	83 c2 01             	add    $0x1,%edx
  800e42:	0f af c6             	imul   %esi,%eax
  800e45:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800e48:	eb be                	jmp    800e08 <strtol+0x8d>
  800e4a:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800e4c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e50:	74 05                	je     800e57 <strtol+0xdc>
		*endptr = (char *) s;
  800e52:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800e55:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800e57:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800e5b:	74 04                	je     800e61 <strtol+0xe6>
  800e5d:	89 c8                	mov    %ecx,%eax
  800e5f:	f7 d8                	neg    %eax
}
  800e61:	83 c4 04             	add    $0x4,%esp
  800e64:	5b                   	pop    %ebx
  800e65:	5e                   	pop    %esi
  800e66:	5f                   	pop    %edi
  800e67:	5d                   	pop    %ebp
  800e68:	c3                   	ret    
  800e69:	00 00                	add    %al,(%eax)
	...

00800e6c <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  800e6c:	55                   	push   %ebp
  800e6d:	89 e5                	mov    %esp,%ebp
  800e6f:	83 ec 08             	sub    $0x8,%esp
  800e72:	89 1c 24             	mov    %ebx,(%esp)
  800e75:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800e79:	ba 00 00 00 00       	mov    $0x0,%edx
  800e7e:	b8 01 00 00 00       	mov    $0x1,%eax
  800e83:	89 d1                	mov    %edx,%ecx
  800e85:	89 d3                	mov    %edx,%ebx
  800e87:	89 d7                	mov    %edx,%edi
  800e89:	51                   	push   %ecx
  800e8a:	52                   	push   %edx
  800e8b:	53                   	push   %ebx
  800e8c:	54                   	push   %esp
  800e8d:	55                   	push   %ebp
  800e8e:	56                   	push   %esi
  800e8f:	57                   	push   %edi
  800e90:	54                   	push   %esp
  800e91:	5d                   	pop    %ebp
  800e92:	8d 35 9a 0e 80 00    	lea    0x800e9a,%esi
  800e98:	0f 34                	sysenter 
  800e9a:	5f                   	pop    %edi
  800e9b:	5e                   	pop    %esi
  800e9c:	5d                   	pop    %ebp
  800e9d:	5c                   	pop    %esp
  800e9e:	5b                   	pop    %ebx
  800e9f:	5a                   	pop    %edx
  800ea0:	59                   	pop    %ecx

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ea1:	8b 1c 24             	mov    (%esp),%ebx
  800ea4:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800ea8:	89 ec                	mov    %ebp,%esp
  800eaa:	5d                   	pop    %ebp
  800eab:	c3                   	ret    

00800eac <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800eac:	55                   	push   %ebp
  800ead:	89 e5                	mov    %esp,%ebp
  800eaf:	83 ec 08             	sub    $0x8,%esp
  800eb2:	89 1c 24             	mov    %ebx,(%esp)
  800eb5:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800eb9:	b8 00 00 00 00       	mov    $0x0,%eax
  800ebe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ec1:	8b 55 08             	mov    0x8(%ebp),%edx
  800ec4:	89 c3                	mov    %eax,%ebx
  800ec6:	89 c7                	mov    %eax,%edi
  800ec8:	51                   	push   %ecx
  800ec9:	52                   	push   %edx
  800eca:	53                   	push   %ebx
  800ecb:	54                   	push   %esp
  800ecc:	55                   	push   %ebp
  800ecd:	56                   	push   %esi
  800ece:	57                   	push   %edi
  800ecf:	54                   	push   %esp
  800ed0:	5d                   	pop    %ebp
  800ed1:	8d 35 d9 0e 80 00    	lea    0x800ed9,%esi
  800ed7:	0f 34                	sysenter 
  800ed9:	5f                   	pop    %edi
  800eda:	5e                   	pop    %esi
  800edb:	5d                   	pop    %ebp
  800edc:	5c                   	pop    %esp
  800edd:	5b                   	pop    %ebx
  800ede:	5a                   	pop    %edx
  800edf:	59                   	pop    %ecx

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ee0:	8b 1c 24             	mov    (%esp),%ebx
  800ee3:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800ee7:	89 ec                	mov    %ebp,%esp
  800ee9:	5d                   	pop    %ebp
  800eea:	c3                   	ret    

00800eeb <sys_env_set_prior>:
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}

int 
sys_env_set_prior(envid_t envid, uint32_t prior){
  800eeb:	55                   	push   %ebp
  800eec:	89 e5                	mov    %esp,%ebp
  800eee:	83 ec 28             	sub    $0x28,%esp
  800ef1:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800ef4:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800ef7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800efc:	b8 0e 00 00 00       	mov    $0xe,%eax
  800f01:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f04:	8b 55 08             	mov    0x8(%ebp),%edx
  800f07:	89 df                	mov    %ebx,%edi
  800f09:	51                   	push   %ecx
  800f0a:	52                   	push   %edx
  800f0b:	53                   	push   %ebx
  800f0c:	54                   	push   %esp
  800f0d:	55                   	push   %ebp
  800f0e:	56                   	push   %esi
  800f0f:	57                   	push   %edi
  800f10:	54                   	push   %esp
  800f11:	5d                   	pop    %ebp
  800f12:	8d 35 1a 0f 80 00    	lea    0x800f1a,%esi
  800f18:	0f 34                	sysenter 
  800f1a:	5f                   	pop    %edi
  800f1b:	5e                   	pop    %esi
  800f1c:	5d                   	pop    %ebp
  800f1d:	5c                   	pop    %esp
  800f1e:	5b                   	pop    %ebx
  800f1f:	5a                   	pop    %edx
  800f20:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  800f21:	85 c0                	test   %eax,%eax
  800f23:	7e 28                	jle    800f4d <sys_env_set_prior+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f25:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f29:	c7 44 24 0c 0e 00 00 	movl   $0xe,0xc(%esp)
  800f30:	00 
  800f31:	c7 44 24 08 84 19 80 	movl   $0x801984,0x8(%esp)
  800f38:	00 
  800f39:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  800f40:	00 
  800f41:	c7 04 24 a1 19 80 00 	movl   $0x8019a1,(%esp)
  800f48:	e8 43 04 00 00       	call   801390 <_panic>
}

int 
sys_env_set_prior(envid_t envid, uint32_t prior){
         return syscall(SYS_env_set_prior,1,envid, prior, 0, 0, 0);
}
  800f4d:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800f50:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f53:	89 ec                	mov    %ebp,%esp
  800f55:	5d                   	pop    %ebp
  800f56:	c3                   	ret    

00800f57 <sys_sbrk>:
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}

int
sys_sbrk(uint32_t inc)
{
  800f57:	55                   	push   %ebp
  800f58:	89 e5                	mov    %esp,%ebp
  800f5a:	83 ec 08             	sub    $0x8,%esp
  800f5d:	89 1c 24             	mov    %ebx,(%esp)
  800f60:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800f64:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f69:	b8 0f 00 00 00       	mov    $0xf,%eax
  800f6e:	8b 55 08             	mov    0x8(%ebp),%edx
  800f71:	89 cb                	mov    %ecx,%ebx
  800f73:	89 cf                	mov    %ecx,%edi
  800f75:	51                   	push   %ecx
  800f76:	52                   	push   %edx
  800f77:	53                   	push   %ebx
  800f78:	54                   	push   %esp
  800f79:	55                   	push   %ebp
  800f7a:	56                   	push   %esi
  800f7b:	57                   	push   %edi
  800f7c:	54                   	push   %esp
  800f7d:	5d                   	pop    %ebp
  800f7e:	8d 35 86 0f 80 00    	lea    0x800f86,%esi
  800f84:	0f 34                	sysenter 
  800f86:	5f                   	pop    %edi
  800f87:	5e                   	pop    %esi
  800f88:	5d                   	pop    %ebp
  800f89:	5c                   	pop    %esp
  800f8a:	5b                   	pop    %ebx
  800f8b:	5a                   	pop    %edx
  800f8c:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  800f8d:	8b 1c 24             	mov    (%esp),%ebx
  800f90:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800f94:	89 ec                	mov    %ebp,%esp
  800f96:	5d                   	pop    %ebp
  800f97:	c3                   	ret    

00800f98 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800f98:	55                   	push   %ebp
  800f99:	89 e5                	mov    %esp,%ebp
  800f9b:	83 ec 28             	sub    $0x28,%esp
  800f9e:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800fa1:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800fa4:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fa9:	b8 0d 00 00 00       	mov    $0xd,%eax
  800fae:	8b 55 08             	mov    0x8(%ebp),%edx
  800fb1:	89 cb                	mov    %ecx,%ebx
  800fb3:	89 cf                	mov    %ecx,%edi
  800fb5:	51                   	push   %ecx
  800fb6:	52                   	push   %edx
  800fb7:	53                   	push   %ebx
  800fb8:	54                   	push   %esp
  800fb9:	55                   	push   %ebp
  800fba:	56                   	push   %esi
  800fbb:	57                   	push   %edi
  800fbc:	54                   	push   %esp
  800fbd:	5d                   	pop    %ebp
  800fbe:	8d 35 c6 0f 80 00    	lea    0x800fc6,%esi
  800fc4:	0f 34                	sysenter 
  800fc6:	5f                   	pop    %edi
  800fc7:	5e                   	pop    %esi
  800fc8:	5d                   	pop    %ebp
  800fc9:	5c                   	pop    %esp
  800fca:	5b                   	pop    %ebx
  800fcb:	5a                   	pop    %edx
  800fcc:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  800fcd:	85 c0                	test   %eax,%eax
  800fcf:	7e 28                	jle    800ff9 <sys_ipc_recv+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fd1:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fd5:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800fdc:	00 
  800fdd:	c7 44 24 08 84 19 80 	movl   $0x801984,0x8(%esp)
  800fe4:	00 
  800fe5:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  800fec:	00 
  800fed:	c7 04 24 a1 19 80 00 	movl   $0x8019a1,(%esp)
  800ff4:	e8 97 03 00 00       	call   801390 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ff9:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800ffc:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800fff:	89 ec                	mov    %ebp,%esp
  801001:	5d                   	pop    %ebp
  801002:	c3                   	ret    

00801003 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801003:	55                   	push   %ebp
  801004:	89 e5                	mov    %esp,%ebp
  801006:	83 ec 08             	sub    $0x8,%esp
  801009:	89 1c 24             	mov    %ebx,(%esp)
  80100c:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801010:	b8 0c 00 00 00       	mov    $0xc,%eax
  801015:	8b 7d 14             	mov    0x14(%ebp),%edi
  801018:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80101b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80101e:	8b 55 08             	mov    0x8(%ebp),%edx
  801021:	51                   	push   %ecx
  801022:	52                   	push   %edx
  801023:	53                   	push   %ebx
  801024:	54                   	push   %esp
  801025:	55                   	push   %ebp
  801026:	56                   	push   %esi
  801027:	57                   	push   %edi
  801028:	54                   	push   %esp
  801029:	5d                   	pop    %ebp
  80102a:	8d 35 32 10 80 00    	lea    0x801032,%esi
  801030:	0f 34                	sysenter 
  801032:	5f                   	pop    %edi
  801033:	5e                   	pop    %esi
  801034:	5d                   	pop    %ebp
  801035:	5c                   	pop    %esp
  801036:	5b                   	pop    %ebx
  801037:	5a                   	pop    %edx
  801038:	59                   	pop    %ecx

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801039:	8b 1c 24             	mov    (%esp),%ebx
  80103c:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801040:	89 ec                	mov    %ebp,%esp
  801042:	5d                   	pop    %ebp
  801043:	c3                   	ret    

00801044 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801044:	55                   	push   %ebp
  801045:	89 e5                	mov    %esp,%ebp
  801047:	83 ec 28             	sub    $0x28,%esp
  80104a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80104d:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801050:	bb 00 00 00 00       	mov    $0x0,%ebx
  801055:	b8 0a 00 00 00       	mov    $0xa,%eax
  80105a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80105d:	8b 55 08             	mov    0x8(%ebp),%edx
  801060:	89 df                	mov    %ebx,%edi
  801062:	51                   	push   %ecx
  801063:	52                   	push   %edx
  801064:	53                   	push   %ebx
  801065:	54                   	push   %esp
  801066:	55                   	push   %ebp
  801067:	56                   	push   %esi
  801068:	57                   	push   %edi
  801069:	54                   	push   %esp
  80106a:	5d                   	pop    %ebp
  80106b:	8d 35 73 10 80 00    	lea    0x801073,%esi
  801071:	0f 34                	sysenter 
  801073:	5f                   	pop    %edi
  801074:	5e                   	pop    %esi
  801075:	5d                   	pop    %ebp
  801076:	5c                   	pop    %esp
  801077:	5b                   	pop    %ebx
  801078:	5a                   	pop    %edx
  801079:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80107a:	85 c0                	test   %eax,%eax
  80107c:	7e 28                	jle    8010a6 <sys_env_set_pgfault_upcall+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  80107e:	89 44 24 10          	mov    %eax,0x10(%esp)
  801082:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  801089:	00 
  80108a:	c7 44 24 08 84 19 80 	movl   $0x801984,0x8(%esp)
  801091:	00 
  801092:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801099:	00 
  80109a:	c7 04 24 a1 19 80 00 	movl   $0x8019a1,(%esp)
  8010a1:	e8 ea 02 00 00       	call   801390 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8010a6:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8010a9:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8010ac:	89 ec                	mov    %ebp,%esp
  8010ae:	5d                   	pop    %ebp
  8010af:	c3                   	ret    

008010b0 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8010b0:	55                   	push   %ebp
  8010b1:	89 e5                	mov    %esp,%ebp
  8010b3:	83 ec 28             	sub    $0x28,%esp
  8010b6:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8010b9:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8010bc:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010c1:	b8 09 00 00 00       	mov    $0x9,%eax
  8010c6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010c9:	8b 55 08             	mov    0x8(%ebp),%edx
  8010cc:	89 df                	mov    %ebx,%edi
  8010ce:	51                   	push   %ecx
  8010cf:	52                   	push   %edx
  8010d0:	53                   	push   %ebx
  8010d1:	54                   	push   %esp
  8010d2:	55                   	push   %ebp
  8010d3:	56                   	push   %esi
  8010d4:	57                   	push   %edi
  8010d5:	54                   	push   %esp
  8010d6:	5d                   	pop    %ebp
  8010d7:	8d 35 df 10 80 00    	lea    0x8010df,%esi
  8010dd:	0f 34                	sysenter 
  8010df:	5f                   	pop    %edi
  8010e0:	5e                   	pop    %esi
  8010e1:	5d                   	pop    %ebp
  8010e2:	5c                   	pop    %esp
  8010e3:	5b                   	pop    %ebx
  8010e4:	5a                   	pop    %edx
  8010e5:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8010e6:	85 c0                	test   %eax,%eax
  8010e8:	7e 28                	jle    801112 <sys_env_set_status+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010ea:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010ee:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8010f5:	00 
  8010f6:	c7 44 24 08 84 19 80 	movl   $0x801984,0x8(%esp)
  8010fd:	00 
  8010fe:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801105:	00 
  801106:	c7 04 24 a1 19 80 00 	movl   $0x8019a1,(%esp)
  80110d:	e8 7e 02 00 00       	call   801390 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801112:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801115:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801118:	89 ec                	mov    %ebp,%esp
  80111a:	5d                   	pop    %ebp
  80111b:	c3                   	ret    

0080111c <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  80111c:	55                   	push   %ebp
  80111d:	89 e5                	mov    %esp,%ebp
  80111f:	83 ec 28             	sub    $0x28,%esp
  801122:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801125:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801128:	bb 00 00 00 00       	mov    $0x0,%ebx
  80112d:	b8 07 00 00 00       	mov    $0x7,%eax
  801132:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801135:	8b 55 08             	mov    0x8(%ebp),%edx
  801138:	89 df                	mov    %ebx,%edi
  80113a:	51                   	push   %ecx
  80113b:	52                   	push   %edx
  80113c:	53                   	push   %ebx
  80113d:	54                   	push   %esp
  80113e:	55                   	push   %ebp
  80113f:	56                   	push   %esi
  801140:	57                   	push   %edi
  801141:	54                   	push   %esp
  801142:	5d                   	pop    %ebp
  801143:	8d 35 4b 11 80 00    	lea    0x80114b,%esi
  801149:	0f 34                	sysenter 
  80114b:	5f                   	pop    %edi
  80114c:	5e                   	pop    %esi
  80114d:	5d                   	pop    %ebp
  80114e:	5c                   	pop    %esp
  80114f:	5b                   	pop    %ebx
  801150:	5a                   	pop    %edx
  801151:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801152:	85 c0                	test   %eax,%eax
  801154:	7e 28                	jle    80117e <sys_page_unmap+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  801156:	89 44 24 10          	mov    %eax,0x10(%esp)
  80115a:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801161:	00 
  801162:	c7 44 24 08 84 19 80 	movl   $0x801984,0x8(%esp)
  801169:	00 
  80116a:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801171:	00 
  801172:	c7 04 24 a1 19 80 00 	movl   $0x8019a1,(%esp)
  801179:	e8 12 02 00 00       	call   801390 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80117e:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801181:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801184:	89 ec                	mov    %ebp,%esp
  801186:	5d                   	pop    %ebp
  801187:	c3                   	ret    

00801188 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  801188:	55                   	push   %ebp
  801189:	89 e5                	mov    %esp,%ebp
  80118b:	83 ec 28             	sub    $0x28,%esp
  80118e:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801191:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801194:	8b 7d 18             	mov    0x18(%ebp),%edi
  801197:	0b 7d 14             	or     0x14(%ebp),%edi
  80119a:	b8 06 00 00 00       	mov    $0x6,%eax
  80119f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8011a2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011a5:	8b 55 08             	mov    0x8(%ebp),%edx
  8011a8:	51                   	push   %ecx
  8011a9:	52                   	push   %edx
  8011aa:	53                   	push   %ebx
  8011ab:	54                   	push   %esp
  8011ac:	55                   	push   %ebp
  8011ad:	56                   	push   %esi
  8011ae:	57                   	push   %edi
  8011af:	54                   	push   %esp
  8011b0:	5d                   	pop    %ebp
  8011b1:	8d 35 b9 11 80 00    	lea    0x8011b9,%esi
  8011b7:	0f 34                	sysenter 
  8011b9:	5f                   	pop    %edi
  8011ba:	5e                   	pop    %esi
  8011bb:	5d                   	pop    %ebp
  8011bc:	5c                   	pop    %esp
  8011bd:	5b                   	pop    %ebx
  8011be:	5a                   	pop    %edx
  8011bf:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8011c0:	85 c0                	test   %eax,%eax
  8011c2:	7e 28                	jle    8011ec <sys_page_map+0x64>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011c4:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011c8:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  8011cf:	00 
  8011d0:	c7 44 24 08 84 19 80 	movl   $0x801984,0x8(%esp)
  8011d7:	00 
  8011d8:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8011df:	00 
  8011e0:	c7 04 24 a1 19 80 00 	movl   $0x8019a1,(%esp)
  8011e7:	e8 a4 01 00 00       	call   801390 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}
  8011ec:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8011ef:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8011f2:	89 ec                	mov    %ebp,%esp
  8011f4:	5d                   	pop    %ebp
  8011f5:	c3                   	ret    

008011f6 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8011f6:	55                   	push   %ebp
  8011f7:	89 e5                	mov    %esp,%ebp
  8011f9:	83 ec 28             	sub    $0x28,%esp
  8011fc:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8011ff:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801202:	bf 00 00 00 00       	mov    $0x0,%edi
  801207:	b8 05 00 00 00       	mov    $0x5,%eax
  80120c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80120f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801212:	8b 55 08             	mov    0x8(%ebp),%edx
  801215:	51                   	push   %ecx
  801216:	52                   	push   %edx
  801217:	53                   	push   %ebx
  801218:	54                   	push   %esp
  801219:	55                   	push   %ebp
  80121a:	56                   	push   %esi
  80121b:	57                   	push   %edi
  80121c:	54                   	push   %esp
  80121d:	5d                   	pop    %ebp
  80121e:	8d 35 26 12 80 00    	lea    0x801226,%esi
  801224:	0f 34                	sysenter 
  801226:	5f                   	pop    %edi
  801227:	5e                   	pop    %esi
  801228:	5d                   	pop    %ebp
  801229:	5c                   	pop    %esp
  80122a:	5b                   	pop    %ebx
  80122b:	5a                   	pop    %edx
  80122c:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80122d:	85 c0                	test   %eax,%eax
  80122f:	7e 28                	jle    801259 <sys_page_alloc+0x63>
		panic("syscall %d returned %d (> 0)", num, ret);
  801231:	89 44 24 10          	mov    %eax,0x10(%esp)
  801235:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  80123c:	00 
  80123d:	c7 44 24 08 84 19 80 	movl   $0x801984,0x8(%esp)
  801244:	00 
  801245:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80124c:	00 
  80124d:	c7 04 24 a1 19 80 00 	movl   $0x8019a1,(%esp)
  801254:	e8 37 01 00 00       	call   801390 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  801259:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80125c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80125f:	89 ec                	mov    %ebp,%esp
  801261:	5d                   	pop    %ebp
  801262:	c3                   	ret    

00801263 <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
{
  801263:	55                   	push   %ebp
  801264:	89 e5                	mov    %esp,%ebp
  801266:	83 ec 08             	sub    $0x8,%esp
  801269:	89 1c 24             	mov    %ebx,(%esp)
  80126c:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801270:	ba 00 00 00 00       	mov    $0x0,%edx
  801275:	b8 0b 00 00 00       	mov    $0xb,%eax
  80127a:	89 d1                	mov    %edx,%ecx
  80127c:	89 d3                	mov    %edx,%ebx
  80127e:	89 d7                	mov    %edx,%edi
  801280:	51                   	push   %ecx
  801281:	52                   	push   %edx
  801282:	53                   	push   %ebx
  801283:	54                   	push   %esp
  801284:	55                   	push   %ebp
  801285:	56                   	push   %esi
  801286:	57                   	push   %edi
  801287:	54                   	push   %esp
  801288:	5d                   	pop    %ebp
  801289:	8d 35 91 12 80 00    	lea    0x801291,%esi
  80128f:	0f 34                	sysenter 
  801291:	5f                   	pop    %edi
  801292:	5e                   	pop    %esi
  801293:	5d                   	pop    %ebp
  801294:	5c                   	pop    %esp
  801295:	5b                   	pop    %ebx
  801296:	5a                   	pop    %edx
  801297:	59                   	pop    %ecx

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  801298:	8b 1c 24             	mov    (%esp),%ebx
  80129b:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80129f:	89 ec                	mov    %ebp,%esp
  8012a1:	5d                   	pop    %ebp
  8012a2:	c3                   	ret    

008012a3 <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
{
  8012a3:	55                   	push   %ebp
  8012a4:	89 e5                	mov    %esp,%ebp
  8012a6:	83 ec 08             	sub    $0x8,%esp
  8012a9:	89 1c 24             	mov    %ebx,(%esp)
  8012ac:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8012b0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012b5:	b8 04 00 00 00       	mov    $0x4,%eax
  8012ba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012bd:	8b 55 08             	mov    0x8(%ebp),%edx
  8012c0:	89 df                	mov    %ebx,%edi
  8012c2:	51                   	push   %ecx
  8012c3:	52                   	push   %edx
  8012c4:	53                   	push   %ebx
  8012c5:	54                   	push   %esp
  8012c6:	55                   	push   %ebp
  8012c7:	56                   	push   %esi
  8012c8:	57                   	push   %edi
  8012c9:	54                   	push   %esp
  8012ca:	5d                   	pop    %ebp
  8012cb:	8d 35 d3 12 80 00    	lea    0x8012d3,%esi
  8012d1:	0f 34                	sysenter 
  8012d3:	5f                   	pop    %edi
  8012d4:	5e                   	pop    %esi
  8012d5:	5d                   	pop    %ebp
  8012d6:	5c                   	pop    %esp
  8012d7:	5b                   	pop    %ebx
  8012d8:	5a                   	pop    %edx
  8012d9:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  8012da:	8b 1c 24             	mov    (%esp),%ebx
  8012dd:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8012e1:	89 ec                	mov    %ebp,%esp
  8012e3:	5d                   	pop    %ebp
  8012e4:	c3                   	ret    

008012e5 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  8012e5:	55                   	push   %ebp
  8012e6:	89 e5                	mov    %esp,%ebp
  8012e8:	83 ec 08             	sub    $0x8,%esp
  8012eb:	89 1c 24             	mov    %ebx,(%esp)
  8012ee:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8012f2:	ba 00 00 00 00       	mov    $0x0,%edx
  8012f7:	b8 02 00 00 00       	mov    $0x2,%eax
  8012fc:	89 d1                	mov    %edx,%ecx
  8012fe:	89 d3                	mov    %edx,%ebx
  801300:	89 d7                	mov    %edx,%edi
  801302:	51                   	push   %ecx
  801303:	52                   	push   %edx
  801304:	53                   	push   %ebx
  801305:	54                   	push   %esp
  801306:	55                   	push   %ebp
  801307:	56                   	push   %esi
  801308:	57                   	push   %edi
  801309:	54                   	push   %esp
  80130a:	5d                   	pop    %ebp
  80130b:	8d 35 13 13 80 00    	lea    0x801313,%esi
  801311:	0f 34                	sysenter 
  801313:	5f                   	pop    %edi
  801314:	5e                   	pop    %esi
  801315:	5d                   	pop    %ebp
  801316:	5c                   	pop    %esp
  801317:	5b                   	pop    %ebx
  801318:	5a                   	pop    %edx
  801319:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80131a:	8b 1c 24             	mov    (%esp),%ebx
  80131d:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801321:	89 ec                	mov    %ebp,%esp
  801323:	5d                   	pop    %ebp
  801324:	c3                   	ret    

00801325 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  801325:	55                   	push   %ebp
  801326:	89 e5                	mov    %esp,%ebp
  801328:	83 ec 28             	sub    $0x28,%esp
  80132b:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80132e:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801331:	b9 00 00 00 00       	mov    $0x0,%ecx
  801336:	b8 03 00 00 00       	mov    $0x3,%eax
  80133b:	8b 55 08             	mov    0x8(%ebp),%edx
  80133e:	89 cb                	mov    %ecx,%ebx
  801340:	89 cf                	mov    %ecx,%edi
  801342:	51                   	push   %ecx
  801343:	52                   	push   %edx
  801344:	53                   	push   %ebx
  801345:	54                   	push   %esp
  801346:	55                   	push   %ebp
  801347:	56                   	push   %esi
  801348:	57                   	push   %edi
  801349:	54                   	push   %esp
  80134a:	5d                   	pop    %ebp
  80134b:	8d 35 53 13 80 00    	lea    0x801353,%esi
  801351:	0f 34                	sysenter 
  801353:	5f                   	pop    %edi
  801354:	5e                   	pop    %esi
  801355:	5d                   	pop    %ebp
  801356:	5c                   	pop    %esp
  801357:	5b                   	pop    %ebx
  801358:	5a                   	pop    %edx
  801359:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80135a:	85 c0                	test   %eax,%eax
  80135c:	7e 28                	jle    801386 <sys_env_destroy+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  80135e:	89 44 24 10          	mov    %eax,0x10(%esp)
  801362:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  801369:	00 
  80136a:	c7 44 24 08 84 19 80 	movl   $0x801984,0x8(%esp)
  801371:	00 
  801372:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801379:	00 
  80137a:	c7 04 24 a1 19 80 00 	movl   $0x8019a1,(%esp)
  801381:	e8 0a 00 00 00       	call   801390 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801386:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801389:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80138c:	89 ec                	mov    %ebp,%esp
  80138e:	5d                   	pop    %ebp
  80138f:	c3                   	ret    

00801390 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801390:	55                   	push   %ebp
  801391:	89 e5                	mov    %esp,%ebp
  801393:	56                   	push   %esi
  801394:	53                   	push   %ebx
  801395:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  801398:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	if (argv0)
  80139b:	a1 08 20 80 00       	mov    0x802008,%eax
  8013a0:	85 c0                	test   %eax,%eax
  8013a2:	74 10                	je     8013b4 <_panic+0x24>
		cprintf("%s: ", argv0);
  8013a4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013a8:	c7 04 24 af 19 80 00 	movl   $0x8019af,(%esp)
  8013af:	e8 9d ed ff ff       	call   800151 <cprintf>
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8013b4:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  8013ba:	e8 26 ff ff ff       	call   8012e5 <sys_getenvid>
  8013bf:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013c2:	89 54 24 10          	mov    %edx,0x10(%esp)
  8013c6:	8b 55 08             	mov    0x8(%ebp),%edx
  8013c9:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8013cd:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8013d1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013d5:	c7 04 24 b4 19 80 00 	movl   $0x8019b4,(%esp)
  8013dc:	e8 70 ed ff ff       	call   800151 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8013e1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8013e5:	8b 45 10             	mov    0x10(%ebp),%eax
  8013e8:	89 04 24             	mov    %eax,(%esp)
  8013eb:	e8 00 ed ff ff       	call   8000f0 <vcprintf>
	cprintf("\n");
  8013f0:	c7 04 24 96 16 80 00 	movl   $0x801696,(%esp)
  8013f7:	e8 55 ed ff ff       	call   800151 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8013fc:	cc                   	int3   
  8013fd:	eb fd                	jmp    8013fc <_panic+0x6c>
	...

00801400 <__udivdi3>:
  801400:	55                   	push   %ebp
  801401:	89 e5                	mov    %esp,%ebp
  801403:	57                   	push   %edi
  801404:	56                   	push   %esi
  801405:	83 ec 10             	sub    $0x10,%esp
  801408:	8b 45 14             	mov    0x14(%ebp),%eax
  80140b:	8b 55 08             	mov    0x8(%ebp),%edx
  80140e:	8b 75 10             	mov    0x10(%ebp),%esi
  801411:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801414:	85 c0                	test   %eax,%eax
  801416:	89 55 f0             	mov    %edx,-0x10(%ebp)
  801419:	75 35                	jne    801450 <__udivdi3+0x50>
  80141b:	39 fe                	cmp    %edi,%esi
  80141d:	77 61                	ja     801480 <__udivdi3+0x80>
  80141f:	85 f6                	test   %esi,%esi
  801421:	75 0b                	jne    80142e <__udivdi3+0x2e>
  801423:	b8 01 00 00 00       	mov    $0x1,%eax
  801428:	31 d2                	xor    %edx,%edx
  80142a:	f7 f6                	div    %esi
  80142c:	89 c6                	mov    %eax,%esi
  80142e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  801431:	31 d2                	xor    %edx,%edx
  801433:	89 f8                	mov    %edi,%eax
  801435:	f7 f6                	div    %esi
  801437:	89 c7                	mov    %eax,%edi
  801439:	89 c8                	mov    %ecx,%eax
  80143b:	f7 f6                	div    %esi
  80143d:	89 c1                	mov    %eax,%ecx
  80143f:	89 fa                	mov    %edi,%edx
  801441:	89 c8                	mov    %ecx,%eax
  801443:	83 c4 10             	add    $0x10,%esp
  801446:	5e                   	pop    %esi
  801447:	5f                   	pop    %edi
  801448:	5d                   	pop    %ebp
  801449:	c3                   	ret    
  80144a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801450:	39 f8                	cmp    %edi,%eax
  801452:	77 1c                	ja     801470 <__udivdi3+0x70>
  801454:	0f bd d0             	bsr    %eax,%edx
  801457:	83 f2 1f             	xor    $0x1f,%edx
  80145a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80145d:	75 39                	jne    801498 <__udivdi3+0x98>
  80145f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  801462:	0f 86 a0 00 00 00    	jbe    801508 <__udivdi3+0x108>
  801468:	39 f8                	cmp    %edi,%eax
  80146a:	0f 82 98 00 00 00    	jb     801508 <__udivdi3+0x108>
  801470:	31 ff                	xor    %edi,%edi
  801472:	31 c9                	xor    %ecx,%ecx
  801474:	89 c8                	mov    %ecx,%eax
  801476:	89 fa                	mov    %edi,%edx
  801478:	83 c4 10             	add    $0x10,%esp
  80147b:	5e                   	pop    %esi
  80147c:	5f                   	pop    %edi
  80147d:	5d                   	pop    %ebp
  80147e:	c3                   	ret    
  80147f:	90                   	nop
  801480:	89 d1                	mov    %edx,%ecx
  801482:	89 fa                	mov    %edi,%edx
  801484:	89 c8                	mov    %ecx,%eax
  801486:	31 ff                	xor    %edi,%edi
  801488:	f7 f6                	div    %esi
  80148a:	89 c1                	mov    %eax,%ecx
  80148c:	89 fa                	mov    %edi,%edx
  80148e:	89 c8                	mov    %ecx,%eax
  801490:	83 c4 10             	add    $0x10,%esp
  801493:	5e                   	pop    %esi
  801494:	5f                   	pop    %edi
  801495:	5d                   	pop    %ebp
  801496:	c3                   	ret    
  801497:	90                   	nop
  801498:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80149c:	89 f2                	mov    %esi,%edx
  80149e:	d3 e0                	shl    %cl,%eax
  8014a0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8014a3:	b8 20 00 00 00       	mov    $0x20,%eax
  8014a8:	2b 45 f4             	sub    -0xc(%ebp),%eax
  8014ab:	89 c1                	mov    %eax,%ecx
  8014ad:	d3 ea                	shr    %cl,%edx
  8014af:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8014b3:	0b 55 ec             	or     -0x14(%ebp),%edx
  8014b6:	d3 e6                	shl    %cl,%esi
  8014b8:	89 c1                	mov    %eax,%ecx
  8014ba:	89 75 e8             	mov    %esi,-0x18(%ebp)
  8014bd:	89 fe                	mov    %edi,%esi
  8014bf:	d3 ee                	shr    %cl,%esi
  8014c1:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8014c5:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8014c8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8014cb:	d3 e7                	shl    %cl,%edi
  8014cd:	89 c1                	mov    %eax,%ecx
  8014cf:	d3 ea                	shr    %cl,%edx
  8014d1:	09 d7                	or     %edx,%edi
  8014d3:	89 f2                	mov    %esi,%edx
  8014d5:	89 f8                	mov    %edi,%eax
  8014d7:	f7 75 ec             	divl   -0x14(%ebp)
  8014da:	89 d6                	mov    %edx,%esi
  8014dc:	89 c7                	mov    %eax,%edi
  8014de:	f7 65 e8             	mull   -0x18(%ebp)
  8014e1:	39 d6                	cmp    %edx,%esi
  8014e3:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8014e6:	72 30                	jb     801518 <__udivdi3+0x118>
  8014e8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8014eb:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8014ef:	d3 e2                	shl    %cl,%edx
  8014f1:	39 c2                	cmp    %eax,%edx
  8014f3:	73 05                	jae    8014fa <__udivdi3+0xfa>
  8014f5:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  8014f8:	74 1e                	je     801518 <__udivdi3+0x118>
  8014fa:	89 f9                	mov    %edi,%ecx
  8014fc:	31 ff                	xor    %edi,%edi
  8014fe:	e9 71 ff ff ff       	jmp    801474 <__udivdi3+0x74>
  801503:	90                   	nop
  801504:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801508:	31 ff                	xor    %edi,%edi
  80150a:	b9 01 00 00 00       	mov    $0x1,%ecx
  80150f:	e9 60 ff ff ff       	jmp    801474 <__udivdi3+0x74>
  801514:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801518:	8d 4f ff             	lea    -0x1(%edi),%ecx
  80151b:	31 ff                	xor    %edi,%edi
  80151d:	89 c8                	mov    %ecx,%eax
  80151f:	89 fa                	mov    %edi,%edx
  801521:	83 c4 10             	add    $0x10,%esp
  801524:	5e                   	pop    %esi
  801525:	5f                   	pop    %edi
  801526:	5d                   	pop    %ebp
  801527:	c3                   	ret    
	...

00801530 <__umoddi3>:
  801530:	55                   	push   %ebp
  801531:	89 e5                	mov    %esp,%ebp
  801533:	57                   	push   %edi
  801534:	56                   	push   %esi
  801535:	83 ec 20             	sub    $0x20,%esp
  801538:	8b 55 14             	mov    0x14(%ebp),%edx
  80153b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80153e:	8b 7d 10             	mov    0x10(%ebp),%edi
  801541:	8b 75 0c             	mov    0xc(%ebp),%esi
  801544:	85 d2                	test   %edx,%edx
  801546:	89 c8                	mov    %ecx,%eax
  801548:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80154b:	75 13                	jne    801560 <__umoddi3+0x30>
  80154d:	39 f7                	cmp    %esi,%edi
  80154f:	76 3f                	jbe    801590 <__umoddi3+0x60>
  801551:	89 f2                	mov    %esi,%edx
  801553:	f7 f7                	div    %edi
  801555:	89 d0                	mov    %edx,%eax
  801557:	31 d2                	xor    %edx,%edx
  801559:	83 c4 20             	add    $0x20,%esp
  80155c:	5e                   	pop    %esi
  80155d:	5f                   	pop    %edi
  80155e:	5d                   	pop    %ebp
  80155f:	c3                   	ret    
  801560:	39 f2                	cmp    %esi,%edx
  801562:	77 4c                	ja     8015b0 <__umoddi3+0x80>
  801564:	0f bd ca             	bsr    %edx,%ecx
  801567:	83 f1 1f             	xor    $0x1f,%ecx
  80156a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80156d:	75 51                	jne    8015c0 <__umoddi3+0x90>
  80156f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  801572:	0f 87 e0 00 00 00    	ja     801658 <__umoddi3+0x128>
  801578:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80157b:	29 f8                	sub    %edi,%eax
  80157d:	19 d6                	sbb    %edx,%esi
  80157f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801582:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801585:	89 f2                	mov    %esi,%edx
  801587:	83 c4 20             	add    $0x20,%esp
  80158a:	5e                   	pop    %esi
  80158b:	5f                   	pop    %edi
  80158c:	5d                   	pop    %ebp
  80158d:	c3                   	ret    
  80158e:	66 90                	xchg   %ax,%ax
  801590:	85 ff                	test   %edi,%edi
  801592:	75 0b                	jne    80159f <__umoddi3+0x6f>
  801594:	b8 01 00 00 00       	mov    $0x1,%eax
  801599:	31 d2                	xor    %edx,%edx
  80159b:	f7 f7                	div    %edi
  80159d:	89 c7                	mov    %eax,%edi
  80159f:	89 f0                	mov    %esi,%eax
  8015a1:	31 d2                	xor    %edx,%edx
  8015a3:	f7 f7                	div    %edi
  8015a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015a8:	f7 f7                	div    %edi
  8015aa:	eb a9                	jmp    801555 <__umoddi3+0x25>
  8015ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8015b0:	89 c8                	mov    %ecx,%eax
  8015b2:	89 f2                	mov    %esi,%edx
  8015b4:	83 c4 20             	add    $0x20,%esp
  8015b7:	5e                   	pop    %esi
  8015b8:	5f                   	pop    %edi
  8015b9:	5d                   	pop    %ebp
  8015ba:	c3                   	ret    
  8015bb:	90                   	nop
  8015bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8015c0:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8015c4:	d3 e2                	shl    %cl,%edx
  8015c6:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8015c9:	ba 20 00 00 00       	mov    $0x20,%edx
  8015ce:	2b 55 f0             	sub    -0x10(%ebp),%edx
  8015d1:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8015d4:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8015d8:	89 fa                	mov    %edi,%edx
  8015da:	d3 ea                	shr    %cl,%edx
  8015dc:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8015e0:	0b 55 f4             	or     -0xc(%ebp),%edx
  8015e3:	d3 e7                	shl    %cl,%edi
  8015e5:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8015e9:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8015ec:	89 f2                	mov    %esi,%edx
  8015ee:	89 7d e8             	mov    %edi,-0x18(%ebp)
  8015f1:	89 c7                	mov    %eax,%edi
  8015f3:	d3 ea                	shr    %cl,%edx
  8015f5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8015f9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8015fc:	89 c2                	mov    %eax,%edx
  8015fe:	d3 e6                	shl    %cl,%esi
  801600:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801604:	d3 ea                	shr    %cl,%edx
  801606:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80160a:	09 d6                	or     %edx,%esi
  80160c:	89 f0                	mov    %esi,%eax
  80160e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  801611:	d3 e7                	shl    %cl,%edi
  801613:	89 f2                	mov    %esi,%edx
  801615:	f7 75 f4             	divl   -0xc(%ebp)
  801618:	89 d6                	mov    %edx,%esi
  80161a:	f7 65 e8             	mull   -0x18(%ebp)
  80161d:	39 d6                	cmp    %edx,%esi
  80161f:	72 2b                	jb     80164c <__umoddi3+0x11c>
  801621:	39 c7                	cmp    %eax,%edi
  801623:	72 23                	jb     801648 <__umoddi3+0x118>
  801625:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801629:	29 c7                	sub    %eax,%edi
  80162b:	19 d6                	sbb    %edx,%esi
  80162d:	89 f0                	mov    %esi,%eax
  80162f:	89 f2                	mov    %esi,%edx
  801631:	d3 ef                	shr    %cl,%edi
  801633:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801637:	d3 e0                	shl    %cl,%eax
  801639:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80163d:	09 f8                	or     %edi,%eax
  80163f:	d3 ea                	shr    %cl,%edx
  801641:	83 c4 20             	add    $0x20,%esp
  801644:	5e                   	pop    %esi
  801645:	5f                   	pop    %edi
  801646:	5d                   	pop    %ebp
  801647:	c3                   	ret    
  801648:	39 d6                	cmp    %edx,%esi
  80164a:	75 d9                	jne    801625 <__umoddi3+0xf5>
  80164c:	2b 45 e8             	sub    -0x18(%ebp),%eax
  80164f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  801652:	eb d1                	jmp    801625 <__umoddi3+0xf5>
  801654:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801658:	39 f2                	cmp    %esi,%edx
  80165a:	0f 82 18 ff ff ff    	jb     801578 <__umoddi3+0x48>
  801660:	e9 1d ff ff ff       	jmp    801582 <__umoddi3+0x52>
